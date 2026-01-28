`include "../../param_conf.v"
module ExpandS(
    // --- 时钟与复位信号 ---
    input       wire                clk,
    input       wire                rstn,

    // --- ExpandS 数据接口 ---
    input       logic   [511 : 0]   rho_prime,      // 512位随机种子
    input       logic               start_expand,   // 开始扩展S矩阵信号
    output      logic   [91 : 0]    coeff,          // 4*23bit 有效采样系数
    output      logic               coeff_valid,    // 4*23bit 有效采样系数信号
    output      logic               expand_done,    // 扩展完成信号
    output      logic   [15 : 0]    nouce,          // 伪随机种子 用于指示输出系数属于 s1 还是 s2 

    // --- SHA3 控制接口 ---
    output      logic   [7 : 0]     dout,           // SHA3 串行输入字节数据
    output      logic               dout_valid,     // SHA3 串行输入字节有效信号
    output      logic   [31 : 0]    dout_len,       // SHA3 串行输入字节长度
    output      logic   [7 : 0]     mdlen,          // SHA3 Hash长度
    output      logic               init,           // SHA3 初始化信号
    output      logic               start,          // SHA3 开始装载数据
    input       logic               done,           // SHA3 数据装载完成
    output      logic               start_out,      // SHA3 开始挤出数据
    output      logic   [31 : 0]    out_len,        // SHA3 挤出数据长度
    input       logic               done_out,       // SHA3 挤出数据完成
    input       logic   [63 : 0]    st_64bit,       // SHA3 挤出8字节数据
    input       logic               st_64bit_valid  // SHA3 挤出8字节数据有效信号
);

// ==========================================================
// 状态核参数定义
// ==========================================================
typedef enum logic [2 : 0] { 
    S_IDLE,                             // 空闲状态 等待开始扩展的信号
    S_INIT,                             // 初始化过程 维持 1 个时钟周期 之后切换到下一个状态
    S_NEW_SEED,                         // rho_prime 拼接伪随机种子信号
    S_LOAD,                             // 以字节为单位向shake256传输数据
    S_START_SQUEEZE,                    // 输出挤出数据的起始信号
    S_SQUEEZE,                          // 开始挤出数据 同时对数据的合法性进行判断 有效的数据拼接后输出
    S_UPDATE                            // 更新伪随机数 ( nouce )
}state_t;
state_t state, state_d;

// --- 拼接伪随机种子 ---
logic       [527 : 0]       seed;       // 64 + 2 字节伪随机种子

// --- 装载控制信号 ---
logic       [7 : 0]         load_cnt;

// --- 单个多项式系数计数信号 ---
logic       [9 : 0]         single_poly_cnt;

// --- 生成多项式计数信号 ---
logic       [7 : 0]         poly_cnt;

// --- FIFO ---
logic                       rd_en;
logic       [63 : 0]        fifo_dout;
logic                       full;
logic                       empty;
logic       [6 : 0]         rd_data_count;
logic       [6 : 0]         rd_data_count_d;

// ==========================================================
// 具体控制逻辑实现
// ==========================================================

// --------------------------------
// 复位逻辑
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        init <= 1'b0;
    else if (state_d == S_IDLE && state == S_INIT)
        init <= 1'b1;
    else 
        init <= 1'b0;
end

// --------------------------------
// 填充逻辑
// --------------------------------
assign dout_len = 'd66;             // 64字节随机种子 + 2字节 nouce
assign out_len = 'd560;             // 512Byte = 8 Byte * 70 (8 Byte中的6个半字节取出4个有效的半字节归约后输出)
assign mdlen = 'd32;                // shake256
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        seed <= 'd0;
        load_cnt <= 'd0;
        dout <= 'd0;
        dout_valid <= 1'b0;
    end
    else if (state == S_NEW_SEED) begin
        seed <= {nouce, rho_prime};
        load_cnt <= 'd0;
        dout <= 'd0;
        dout_valid <= 1'b0;
    end
    else if (state == S_LOAD) begin
        if (done)
            load_cnt <= 'd0;
        else if (load_cnt == dout_len)
            load_cnt <= dout_len;
        else 
            load_cnt <= load_cnt + 1'b1;
        if (load_cnt == dout_len) begin
            dout_valid <= 1'b0;
            dout <= 'd0;
            seed <= 'd0;
        end
        else begin
            dout_valid <= 1'b1;
            dout <= seed[7 : 0];
            seed <= seed >> 8;
        end
    end
end

// --------------------------------
// 输出开始装载数据的信号给SHA3
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        start <= 1'b0;
    else if (state_d == S_NEW_SEED && state == S_LOAD)
        start <= 1'b1;
    else 
        start <= 1'b0;
end

// --------------------------------
// 输出开始挤出数据的信号给SHA3
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        start_out <= 1'b0;
    else if (state == S_START_SQUEEZE)
        start_out <= 1'b1;
    else 
        start_out <= 1'b0;
end

// --------------------------------
// 控制读使能信号 从FIFO中读出128bit数据
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        rd_en <= 1'b0;
    else if (rd_data_count >= 'd1 && empty == 1'b0) 
        rd_en <= 1'b1;
    else 
        rd_en <= 1'b0;
end

// --------------------------------
// 合法性判断与归约处理
// --------------------------------
logic           [7 : 0]             raw_data [0 : 5];
logic           [5 : 0]             check;
logic           [22 : 0]            raw_data_reduction [0 : 5];
logic           [137 : 0]           valid_coeff_comb;               // 合法系数拼接寄存器
logic           [2 : 0]             valid_coeff_cnt;                // 合法系数计数器
logic                               sample_valid;
logic                               sample_valid_d;

assign sample_valid =  (rd_en == 1'b1) && (empty == 1'b0);
assign raw_data[0] = fifo_dout[3  : 0];
assign raw_data[1] = fifo_dout[7  : 4];
assign raw_data[2] = fifo_dout[11 : 8];
assign raw_data[3] = fifo_dout[15 : 12];
assign raw_data[4] = fifo_dout[19 : 16];
assign raw_data[5] = fifo_dout[23 : 20];

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        sample_valid_d <= 1'b0;
    else 
        sample_valid_d <= sample_valid;
end

// --- 合法性判断 : eta=2时一定合法; eta=4时如果原始数据小于9则合法 ---
always_ff @(posedge clk or negedge rstn) begin : validate
    integer i;
    if (!rstn)
        check <= 'd0;
    else if (sample_valid) begin
        for (i = 0 ; i < 6 ; i++) begin
            if (`eta == 2)
                check[i] <= 1'b1;
            if (`eta == 4)
                check[i] <= raw_data[i] < 9;
        end
    end
end

// --- 归约化处理 ---
// 查找表实现模 5
function logic [2 : 0] mod_5 (logic [3 : 0] x);
    case (x)
        'd0 : return 'd0;
        'd1 : return 'd1;
        'd2 : return 'd2;
        'd3 : return 'd3;
        'd4 : return 'd4;
        'd5 : return 'd0;
        'd6 : return 'd1;
        'd7 : return 'd2;
        'd8 : return 'd3;
        'd9 : return 'd4;
        'd10 : return 'd0;
        'd11 : return 'd1;
        'd12 : return 'd2;
        'd13 : return 'd3;
        'd14 : return 'd4;
        'd15 : return 'd0;
        default : return 'd0; // 防止仿真时的 X 态传播
    endcase
endfunction

// 归约处理 负数则 + q 保证在对 q 同余的条件下等价
always_ff @(posedge clk or negedge rstn) begin : reduction
    integer i;
    if (!rstn) begin
        for (i = 0 ; i < 6 ; i++) begin
            raw_data_reduction[i] <= 'd0;
        end
    end
    else if (sample_valid) begin
        for (i = 0 ; i < 6 ; i++) begin
            if (`eta == 2) begin
                if (mod_5(raw_data[i]) <= 2)
                    raw_data_reduction[i] <= 2 - mod_5(raw_data[i]);
                else 
                    raw_data_reduction[i] <= 2 - mod_5(raw_data[i]) + `q;
            end
            else begin
                if (raw_data[i] <= 4)
                    raw_data_reduction[i] <= 4 - raw_data[i];
                else 
                    raw_data_reduction[i] <= 4 - raw_data[i] + `q;
            end
        end
    end
end

// 合法数据拼接处理 (MUX)
logic           [2 : 0]             pack_cnt;
logic           [137 : 0]           pack_comb;          
always_ff @(posedge clk or negedge rstn) begin : comb
    integer i;
    if (!rstn) begin
        valid_coeff_comb <= 'd0;
        valid_coeff_cnt <= 'd0;
    end
    else if (sample_valid_d) begin
        pack_comb = 'd0;
        pack_cnt = 'd0;
        for (i = 0 ; i < 6 ; i++) begin
            if (check[i]) begin
                pack_comb[pack_cnt * 23 +: 23] = raw_data_reduction[i];
                pack_cnt = pack_cnt + 1'b1;
            end
        end

        valid_coeff_comb <= pack_comb;
        valid_coeff_cnt <= pack_cnt;
    end
    else begin
        valid_coeff_comb <= 'd0;
        valid_coeff_cnt <= 'd0;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        coeff <= 'd0;
        coeff_valid <= 1'b0;
        single_poly_cnt <= 'd0;
    end
    else if (state == S_UPDATE)
        single_poly_cnt <= 'd0;
    else if (valid_coeff_cnt >= 'd4) begin
        if (single_poly_cnt <= 'd63) begin
            coeff <= valid_coeff_comb[91 : 0];
            coeff_valid <= 1'b1;
        end
        else begin
            coeff <= 'd0;
            coeff_valid <= 1'b0;
        end
        single_poly_cnt <= single_poly_cnt + 1'b1;
    end
    else begin
        coeff <= 'd0;
        coeff_valid <= 1'b0;
    end
end

// --------------------------------
// 伪随机数据更新逻辑
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) 
        nouce <= 'd0;
    else if (state == S_UPDATE) begin
        if (nouce == `k + `l - 1)
            nouce <= 'd0;
        else 
            nouce <= nouce + 1'b1;
    end
    else 
        nouce <= nouce;
end

// ==========================================================
// 状态机控制逻辑
// ==========================================================
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        state <= S_IDLE;
        expand_done <= 1'b0;
        poly_cnt <= 'd0;
    end
    else begin
        case (state)
            S_IDLE : begin
                if (start_expand)
                    state <= S_INIT;
                else 
                    state <= S_IDLE;  
                poly_cnt <= 'd0;
                expand_done <= 1'b0;  
            end
            S_INIT : begin
                if (init)
                    state <= S_NEW_SEED;
                else 
                    state <= S_INIT; 
            end
            S_NEW_SEED : begin
                state <= S_LOAD;
            end
            S_LOAD : begin
                if (done)                               // 加载完成信号拉高 进入开始挤出模式
                    state <= S_START_SQUEEZE;
                else 
                    state <= S_LOAD;
            end
            S_START_SQUEEZE : begin                     // 维持一个时钟周期 负责拉高开始挤出数据的控制信号
                state <= S_SQUEEZE; 
            end
            S_SQUEEZE : begin
                if (done_out) begin
                    if (single_poly_cnt >= 'd63)        // 一个多项式的256个系数扩展完成
                        state <= S_UPDATE;
                    else 
                        state <= S_START_SQUEEZE;
                end
                else 
                    state <= S_SQUEEZE;
            end
            S_UPDATE : begin
                if (poly_cnt == `l + `k - 1) begin          // 所有多项式扩展完成
                    state <= S_IDLE;
                    expand_done <= 1'b1;
                    poly_cnt <= 'd0;
                end
                else begin
                    state <= S_NEW_SEED;
                    expand_done <= 1'b0;
                    poly_cnt <= poly_cnt + 1'b1;
                end
            end
            default : state <= S_IDLE;
        endcase
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        state_d <= S_IDLE;
    else 
        state_d <= state;
end

// ==========================================================
// FIFO
// ==========================================================
ExpandS_sipo_1 u_ExpandS_sipo (
  .clk(clk),                                // input wire clk
  .srst(~rstn | init),                      // input wire srst
  .din(st_64bit),                           // input wire [63 : 0] din
  .wr_en(st_64bit_valid),                   // input wire wr_en
  .rd_en(rd_en),                            // input wire rd_en
  .dout(fifo_dout),                         // output wire [63 : 0] dout
  .full(full),                              // output wire full
  .empty(empty),                            // output wire empty
  .data_count(rd_data_count)                // output wire [6 : 0] data_count
);
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        rd_data_count_d <= 'd0;
    else 
        rd_data_count_d <= rd_data_count;
end

endmodule
