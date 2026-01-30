`include "../../param_conf.v"
module ExpandY(
    // --- 时钟与复位信号 ---
    input       wire                clk,
    input       wire                rstn,

    // --- ExpandS 数据接口 ---
    input       logic   [511 : 0]   rho_prime,      // 512位随机种子
    input       logic   [15 : 0]    kappa,          // 伪随机数初始值
    input       logic               start_expand,   // 开始扩展Y矩阵信号

    output      logic   [91 : 0]    coeff,          // 92 bit 有效采样系数
    output      logic               coeff_valid,    // 92 bit 有效采样系数信号

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
    S_NEW_SEED,                         // rho_prime 拼接伪随机种子信号
    S_LOAD,                             // 以字节为单位向shake256传输数据
    S_START_SQUEEZE,                    // 输出挤出数据的起始信号
    S_SQUEEZE,                          // 开始挤出数据 同时对数据的合法性进行判断 有效的数据拼接后输出
    S_UPDATE                            // 更新伪随机数 ( nouce )
} state_t;
state_t state, state_d;

// --- 拼接伪随机种子 ---
logic       [527 : 0]       seed;       // 64 + 2 字节伪随机种子
logic       [15 : 0]        nouce;      // 2字节伪随机种子

// --- 装载控制信号 ---
logic       [7 : 0]         load_cnt;

// --- 单个多项式系数计数信号 ---
logic       [9 : 0]         single_poly_cnt;

// --- 生成多项式计数信号 ---
logic       [7 : 0]         poly_cnt;

// --- 64bit -> 4*`bit_count ---
logic       [4 * `bit_count-1:0] 	    sipo_o;
logic                      	            sipo_o_valid;

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
assign dout_len = 'd66;                 // 64字节随机种子 + 2字节 nouce
assign out_len = (`total_bits >> 3) + 30;      // 非拒绝采样方式 因此输出值与预设值一致 无需留有余量
assign mdlen = 'd32;                    // shake256
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        seed <= 'd0;
        load_cnt <= 'd0;
        dout <= 'd0;
        dout_valid <= 1'b0;
    end
    else if (state == S_NEW_SEED) begin
        seed <= {kappa + nouce, rho_prime};
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
// 归约处理
// --------------------------------
logic           [`bit_count - 1 : 0]        raw_data [0 : 3];
assign raw_data[0] = sipo_o[`bit_count - 1 : 0];
assign raw_data[1] = sipo_o[2 * `bit_count - 1 : `bit_count];
assign raw_data[2] = sipo_o[3 * `bit_count - 1 : 2 * `bit_count];
assign raw_data[3] = sipo_o[4 * `bit_count - 1 : 3 * `bit_count];

always_ff @(posedge clk or negedge rstn) begin : reduction
    integer i;
    if (!rstn) begin
        coeff <= 'd0;
        coeff_valid <= 1'b0;
        single_poly_cnt <= 'd0;
    end
    else if (state == S_UPDATE) begin
        single_poly_cnt <= 'd0;
        coeff_valid <= 1'b0;
        coeff <= 'd0;
    end
    else if (sipo_o_valid && state == S_SQUEEZE) begin
        if (single_poly_cnt <= 'd63) begin
            for (i = 0 ; i < 4 ; i++) begin
                if (`gamma_1 > raw_data[i])
                    coeff[i * 23 +: 23] <= `gamma_1 - raw_data[i];
                else
                    coeff[i * 23 +: 23] <= `gamma_1 + `q - raw_data[i];
            end
            coeff_valid <= 1'b1;
        end
        else begin
            coeff <= 'd0;
            coeff_valid <= 1'b0;
        end
        single_poly_cnt <= single_poly_cnt + 'd1;
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
        if (nouce == `l - 1)
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
                expand_done <= 1'b0;
                poly_cnt <= 'd0;
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
                if (poly_cnt == `l - 1) begin          // 所有多项式扩展完成
                    state <= S_IDLE;
                    expand_done <= 1'b1;
                    poly_cnt <= 'd0;
                end
                else begin
                    state <= S_INIT;
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

ExpandY_sipoX #(
	.BIT_COUNT 	( `bit_count  ))
u_ExpandY_sipoX(
	.clk            	( clk             ),
	.rstn           	( rstn            ),
	.init           	( init            ),
	.st_64bit       	( st_64bit        ),
	.st_64bit_valid 	( st_64bit_valid  ),
	.sipo_o         	( sipo_o          ),
	.sipo_o_valid   	( sipo_o_valid    )
);

endmodule
