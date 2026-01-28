`include "../../param_conf.v"
module ExpandA(
    // --- 时钟与复位接口 ---
    input       logic               clk,
    input       logic               rstn,

    // --- ExpandA 数据接口 ---
    input       logic   [255 : 0]   rho,            // 256位随机种子
    input       logic               start_expand,   // 开始扩展A矩阵信号
    output      logic   [91 : 0]    coeff,          // 4*23bit 有效采样系数
    output      logic               coeff_valid,    // 4*23bit 有效采样系数信号
    output      logic               expand_done,    // 扩展完成信号

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
// 状态与参数定义
// ==========================================================
typedef enum logic [2 : 0] {
    S_IDLE,
    S_INIT,
    S_NEW_SEED,
    S_LOAD,
    S_START_SQUEEZE,
    S_SQUEEZE,
    S_UPDATE
} state_t;
state_t state, state_d;

// --- 伪随机信号 ---
logic       [2 : 0]         row;
logic       [2 : 0]         col;
logic       [271 : 0]       seed;

// --- 装载控制信号 ---
logic       [7 : 0]         load_cnt;

// --- 有效Hash值拼接、计数信号 ---
logic       [114 : 0]       valid_coeff_comb;
logic       [2 : 0]         valid_coeff_cnt;
logic       [4 : 0]         check;

// --- 单个多项式系数计数信号 ---
logic       [7 : 0]         single_poly_cnt;

// --- 生成多项式计数信号 ---
logic       [7 : 0]         poly_cnt;

// --- FIFO ---
logic                       rd_en;
logic       [127 : 0]       fifo_dout;
logic                       full;
logic                       empty;
logic       [4 : 0]         rd_data_count;

// ==========================================================
// 具体控制逻辑实现
// ==========================================================

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        init <= 1'b0;
    else if (state_d == S_IDLE && state == S_INIT)
        init <= 1'b1;
    else 
        init <= 1'b0;
end

assign dout_len = 'd34;
assign out_len = 'd16;
assign mdlen = 'd16;
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        seed <= 'd0;
        load_cnt <= 'd0;
        dout <= 'd0;
        dout_valid <= 1'b0;
    end
    else if (state == S_NEW_SEED) begin
        seed <= {row, col, rho};
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

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        start <= 1'b0;
    else if (state_d == S_NEW_SEED && state == S_LOAD)
        start <= 1'b1;
    else 
        start <= 1'b0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        start_out <= 1'b0;
    else if (state == S_START_SQUEEZE)
        start_out <= 1'b1;
    else 
        start_out <= 1'b0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        rd_en <= 1'b0;
    else if (rd_data_count >= 'd1 && empty == 1'b0) 
        rd_en <= 1'b1;
    else 
        rd_en <= 1'b0;
end

logic [22:0] raw_data [0:4];
assign raw_data[0] = fifo_dout[22 : 0];
assign raw_data[1] = fifo_dout[46 : 24];
assign raw_data[2] = fifo_dout[70 : 48];
assign raw_data[3] = fifo_dout[94 : 72];
assign raw_data[4] = fifo_dout[118 : 96];

always_comb begin
    check <= 'd0;
    if (raw_data[0] < 23'd8380417) check[0] <= 1'b1;
    else check[0] <= 1'b0;
    if (raw_data[1] < 23'd8380417) check[1] <= 1'b1;
    else check[1] <= 1'b0;
    if (raw_data[2] < 23'd8380417) check[2] <= 1'b1;
    else check[2] <= 1'b0;
    if (raw_data[3] < 23'd8380417) check[3] <= 1'b1;
    else check[3] <= 1'b0;
    if (raw_data[4] < 23'd8380417) check[4] <= 1'b1;
    else check[4] <= 1'b0;
end

integer i;
logic [2:0]   pack_cnt;  // 临时变量：记录当前包里装了几个
logic [114:0] pack_comb; // 临时变量：暂存打包好的数据
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        valid_coeff_comb <= 'd0;
        valid_coeff_cnt <= 'd0;
    end
    else if (rd_en && empty == 1'b0) begin
        // --- 初始化临时变量 ---
        pack_cnt  = 0;
        pack_comb = 'd0;

        // --- 循环扫描 5 个输入通道 ---
        // 综合器会将其展开为并行的多路选择逻辑 (Priority Encoder Mux)
        for(i = 0; i < 5; i = i + 1) begin
            if (check[i]) begin
                // 如果当前通道数据有效 (< Q)，则将其“推入”输出堆栈
                // [base +: width] 是 SystemVerilog 的位切片语法
                pack_comb[pack_cnt * 23 +: 23] = raw_data[i];
                
                // 计数器加一，指向下一个空位
                pack_cnt = pack_cnt + 1;
            end
        end

        // --- 将计算结果更新到寄存器 ---
        valid_coeff_comb <= pack_comb;
        valid_coeff_cnt  <= pack_cnt;
    end
    else begin
        valid_coeff_comb <= 'd0;
        valid_coeff_cnt  <= 'd0;
    end
end
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        coeff <= 'd0;
        coeff_valid <= 1'b0;
        single_poly_cnt <= 'd0;
    end
    else if (valid_coeff_cnt >= 'd4) begin
        coeff <= pack_comb[91 : 0];
        coeff_valid <= 1'b1;
        single_poly_cnt <= single_poly_cnt + 1'b1;
    end
    else begin
        coeff <= 'd0;
        coeff_valid <= 1'b0;
        if (state == S_UPDATE)
            single_poly_cnt <= 'd0;
        else
            single_poly_cnt <= single_poly_cnt;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        row <= 'd0;
        col <= 'd0;
    end
    else if (state == S_UPDATE) begin
        if (col == `l - 1) begin
            col <= 'd0;
            if (row == `k - 1)
                row <= 'd0;
            else 
                row <= row + 1'b1;
        end
        else 
            col <= col + 1'b1;
    end
end

// ==========================================================
// 状态机控制逻辑
// ==========================================================
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        state <= S_IDLE;
        poly_cnt <= 'd0;
        expand_done <= 1'b0;
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
                if (done)
                    state <= S_START_SQUEEZE;
                else    
                    state <= S_LOAD;
            end
            S_START_SQUEEZE : begin
                state <= S_SQUEEZE;
            end
            S_SQUEEZE : begin
                if (done_out) begin
                    if (single_poly_cnt >= 'd63) 
                        state <= S_UPDATE;
                    else 
                        state <= S_START_SQUEEZE;
                end
                else 
                    state <= S_SQUEEZE;
            end
            S_UPDATE : begin
                if (poly_cnt == 'd255) begin
                    state <= S_IDLE;
                    expand_done <= 1'b1;
                    poly_cnt <= 'd0;
                end
                else begin
                    state <= S_NEW_SEED;
                    poly_cnt <= poly_cnt + 1'b1;
                    expand_done <= 1'b0;
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

ExpandA_sipo u_ExpandA_sipo (
  .clk(clk),                      // input wire clk
  .srst(~rstn | init),                    // input wire srst
  .din(st_64bit),                      // input wire [63 : 0] din
  .wr_en(st_64bit_valid),                  // input wire wr_en
  .rd_en(rd_en),                  // input wire rd_en
  .dout(fifo_dout),                    // output wire [127 : 0] dout
  .full(full),                    // output wire full
  .empty(empty),                  // output wire empty
  .rd_data_count(rd_data_count)  // output wire [4 : 0] rd_data_count
);

endmodule
