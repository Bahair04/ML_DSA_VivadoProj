module ExpandC(
    // --- 时钟与复位信号 ---
    input       wire                clk,
    input       wire                rstn,

    // --- ExpandC 数据接口 ---
    input       logic   [255 : 0]   seed,           // 512位随机种子
    input       logic   [7 : 0]     tau,            // 伪随机数初始值
    input       logic               start_expand,   // 开始扩展Y矩阵信号

    input       logic               low_rd_en,      // 低地址读取使能信号
    output      logic   [1 : 0]     coeff_low,      // 低地址 2 bit 有效采样系数
    input       logic   [7 : 0]     coeff_low_add,  // 低地址
    output      logic               coeff_low_valid,// 低地址 2 bit 有效采样系数信号

    input       logic               high_rd_en,     // 高地址读取使能信号
    output      logic   [1 : 0]     coeff_high,     // 高地址 2 bit 有效采样系数
    input       logic   [7 : 0]     coeff_high_add, // 高地址
    output      logic               coeff_high_valid,// 高地址 2 bit 有效采样系数信号

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
// 状态和参数定义
// ==========================================================
typedef enum logic [2 : 0] {  
    S_IDLE,                             // 空闲状态 等待开始扩展的信号
    S_INIT,                             // 初始化过程 维持 1 个时钟周期 之后切换到下一个状态
    S_NEW_SEED,                         // 装载随机种子
    S_LOAD,                             // 以字节为单位向shake256传输数据
    S_START_SQUEEZE,                    // 输出挤出数据的起始信号
    S_SQUEEZE,                          // 开始挤出数据 同时对数据的合法性进行判断 有效的数据拼接后输出
    S_OUTPUT                            // 串行输出系数
} state_t;
state_t state, state_d;

// --- 装载控制信号 ---
logic       [7 : 0]         load_cnt;
logic       [255 : 0]       seed_r;

// --- 下标寄存器 ---
logic       [8 : 0]         index;

// --- 符号字节数据 ---
logic       [63 : 0]        sign_byte;
logic       [3 : 0]         sign_byte_cnt;

// --- FIFO ---
logic                       rd_en;
logic       [7 : 0]         fifo_dout;
logic                       full;
logic                       empty;
logic       [9 : 0]         rd_data_count;

// --- True dual port RAM ---
logic                       ena;
logic       [0 : 0]         wea;
logic       [7 : 0]         addra;
logic       [1 : 0]         dina;
logic       [1 : 0]         douta;
logic                       enb;
logic       [0 : 0]         web;
logic       [7 : 0]         addrb;
logic       [1 : 0]         dinb;
logic       [1 : 0]         doutb;

logic                       ram_run_en;
logic                       ram_run_en_d;
logic       [7 : 0]         ram_run_data_i, ram_run_data_i_d;
logic       [7 : 0]         ram_run_data_j, ram_run_data_j_d;

// ==========================================================
// 具体控制逻辑实现
// ==========================================================

// --------------------------------
// 复位逻辑
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        init <= 1'b0;
    else if (state_d != S_INIT && state == S_INIT)
        init <= 1'b1;
    else 
        init <= 1'b0;
end

// --------------------------------
// 填充逻辑
// --------------------------------
assign dout_len = 'd32;                         // 32字节随机种子
assign out_len = 2 * tau + 8;                   // 拒绝采样方式 留有余量
assign mdlen = 'd32;                            // shake256
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        seed_r <= 'd0;
        load_cnt <= 'd0;
        dout <= 'd0;
        dout_valid <= 1'b0;
    end
    else if (state == S_NEW_SEED) begin
        seed_r <= seed;
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
            seed_r <= 'd0;
        end
        else begin
            dout_valid <= 1'b1;
            dout <= seed_r[7 : 0];
            seed_r <= seed_r >> 8;
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
// 控制读使能信号 从FIFO中读出8bit数据
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        rd_en <= 1'b0;
    else if (state != S_SQUEEZE || done_out)
        rd_en <= 1'b0;
    else if (rd_data_count >= 'd1 && empty == 1'b0) 
        rd_en <= 1'b1;
    else 
        rd_en <= 1'b0;
end

// --------------------------------
// 拒绝采样控制逻辑
// --------------------------------

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        index <= 'd0;
        ram_run_en <= 1'b0;
        ram_run_data_i <= 'd0;
        ram_run_data_j <= 'd0;
    end
    else if (state == S_IDLE) begin
        index <= 256 - tau;
        ram_run_en <= 1'b0;
        ram_run_data_i <= 'd0;
        ram_run_data_j <= 'd0;
    end
    else if (state == S_SQUEEZE && rd_en == 1'b1 && empty == 1'b0 && ram_run_en == 1'b0) begin
        if (index <= 'd255 && fifo_dout <= index && sign_byte_cnt == 'd8) begin
            ram_run_en <= 1'b1;
            index <= index + 1'b1;
            ram_run_data_i <= index;
            ram_run_data_j <= fifo_dout;
        end
        else begin
            ram_run_en <= 1'b0;
            index <= index;
        end
    end
    else 
        ram_run_en <= 1'b0;
end

// --- 信号延迟打拍 ---
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        ram_run_en_d <=  1'b0;
        ram_run_data_i_d <= 'd0;
        ram_run_data_j_d <= 'd0;
    end
    else begin
        ram_run_en_d <=  ram_run_en;
        ram_run_data_i_d <= ram_run_data_i;
        ram_run_data_j_d <= ram_run_data_j;
    end
end

// --- RAM 控制逻辑 ---
always_comb begin
    wea = 1'b0;
    web = 1'b0;
    ena = 1'b0;
    enb = 1'b0;
    addra = 'd0;
    addrb = 'd0;
    dina = 'd0;
    dinb = 'd0;
    if (state == S_SQUEEZE) begin
        ena = 1'b0;
        enb = 1'b0;
        if (ram_run_en) begin           // First : 读取第 j 个位置的数值; ram_run_en及其延时不会同时有效
            ena = 1'b1;
            addra = ram_run_data_j;
            wea = 1'b0;
        end
        if (ram_run_en_d) begin         // Secone : 把 First 读取的值写入第 i 个位置; 同时更新第 j 个位置的数值
            // i 和 j 相等时 只写 B 不写 A
            if (ram_run_data_i_d == ram_run_data_j_d) begin
                ena = 1'b0;
                enb = 1'b1;
            end
            else begin
                ena = 1'b1;
                enb = 1'b1;
            end
            addra = ram_run_data_i_d;
            wea = 1'b1;
            dina = douta;

            addrb = ram_run_data_j_d;
            web = 1'b1;
            dinb = sign_byte[0] ? 2'd2 : 2'd1;
        end
    end
    if (state == S_IDLE) begin
        ena = low_rd_en;
        wea = ~low_rd_en;
        addra = coeff_low_add;
        coeff_low = douta;

        enb = high_rd_en;
        web = ~high_rd_en;
        addrb = coeff_high_add;
        coeff_high = doutb;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        coeff_low_valid <= 1'b0;
        coeff_high_valid <= 1'b0;
    end
    else if (state == S_IDLE) begin
        if (low_rd_en)
            coeff_low_valid <= 1'b1;
        else 
            coeff_low_valid <= 1'b0;
        
        if (high_rd_en)
            coeff_high_valid <= 1'b1;
        else
            coeff_high_valid <= 1'b0;
    end
end

// --- 首先输出的8个字节组合成符号字节 ---
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        sign_byte <= 'd0;
        sign_byte_cnt <= 'd0;
    end
    else if (state == S_IDLE) begin
        sign_byte <= 'd0;
        sign_byte_cnt <= 'd0;
    end
    else if (ram_run_en_d) begin
        sign_byte <= sign_byte >> 1;
        sign_byte_cnt <= sign_byte_cnt;
    end
    else if (state == S_SQUEEZE && rd_en == 1'b1 && empty == 1'b0) begin
        if (sign_byte_cnt == 'd8) begin
            sign_byte_cnt <= 'd8;
            sign_byte <= sign_byte;
        end
        else begin
            sign_byte_cnt <= sign_byte_cnt + 1'b1;
            sign_byte <= {fifo_dout, sign_byte[63 : 8]};
        end
    end
end

// ==========================================================
// 状态机控制逻辑
// ==========================================================
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        state <= S_IDLE;
    end
    else begin
        case (state)
            S_IDLE : begin
                if (start_expand)
                    state <= S_INIT;
                else 
                    state <= S_IDLE;  
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
                    if (index == 'd256) begin           // 一个多项式的256个系数扩展完成
                        state <= S_IDLE;
                        expand_done <= 1'b1;
                    end
                    else begin
                        state <= S_START_SQUEEZE;
                        expand_done <= 1'b0;
                    end
                end
                else begin 
                    state <= S_SQUEEZE;
                    expand_done <= 1'b0;
                end
            end
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
ExpandC_sipo u_ExpandC_sipo (
  .clk              (clk                            ),                      // input wire clk
  .srst             (~rstn | init                   ),                      // input wire srst
  .din              (st_64bit                       ),                      // input wire [63 : 0] din
  .wr_en            (st_64bit_valid                 ),                      // input wire wr_en
  .rd_en            (rd_en  && ram_run_en == 1'b0   ),                      // input wire rd_en
  .dout             (fifo_dout                      ),                      // output wire [7 : 0] dout
  .full             (full                           ),                      // output wire full
  .empty            (empty                          ),                      // output wire empty
  .rd_data_count    (rd_data_count                  )                       // output wire [9 : 0] rd_data_count
);

// ==========================================================
// RAM : 存储多项式C的系数(256个)
// ==========================================================
ExpandC_coeff_ram u_ExpandC_coeff_ram (
  .clka             (clk        ),      // input wire clka
  .ena              (ena        ),      // input wire ena
  .wea              (wea        ),      // input wire [0 : 0] wea
  .addra            (addra      ),      // input wire [7 : 0] addra
  .dina             (dina       ),      // input wire [1 : 0] dina
  .douta            (douta      ),      // output wire [1 : 0] douta
  .clkb             (clk        ),      // input wire clkb
  .enb              (enb        ),      // input wire enb
  .web              (web        ),      // input wire [0 : 0] web
  .addrb            (addrb      ),      // input wire [7 : 0] addrb
  .dinb             (dinb       ),      // input wire [1 : 0] dinb
  .doutb            (doutb      )       // output wire [1 : 0] doutb
);
endmodule
