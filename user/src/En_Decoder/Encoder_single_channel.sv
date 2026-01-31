`include "../param_conf.v"
module Encoder_single_channel                                       // 编码模块 单通道
#(
    parameter T1_BIT_LEN = $clog2(`q - 1) - `d,                     // default : 10
    parameter S1_S2_BIT_LEN = $clog2(2 * `eta) + 1,                 // default : 3
    parameter T0_BIT_LEN = `d,                                      // default : 13
    parameter Z_BIT_LEN = 1 + $clog2(`gamma_1 - 1),                 // default : 18
    parameter H_BIT_LEN = 'd1                                       // 这个后面再写
)(
    // --- 时钟与复位信号 ---
    input       logic                                   clk,
    input       logic                                   rstn,

    // --- 公钥(pk) 编码信号 ---
    input       logic   [T1_BIT_LEN - 1 : 0]            t1,                 // t 的高位
    input       logic                                   t1_valid,
    output      logic   [T1_BIT_LEN - 1 : 0]            pk_encode,          // 公钥输出编码
    output      logic                                   pk_encode_valid,    // 公钥输出编码有效信号
    
    // --- 私钥(sk) 编码信号 ---
    input       logic   [23 - 1 : 0]                    s1,                 // ExpandS 中使用`q进行归约 因此位宽为23 实际位宽原少于23
    input       logic                                   s1_valid,
    input       logic   [23 - 1 : 0]                    s2,                 // ExpandS 中使用`q进行归约 因此位宽为23 实际位宽原少于23
    input       logic                                   s2_valid,
    input       logic   [T0_BIT_LEN - 1 : 0]            t0,                 // t 的低位
    input       logic                                   t0_valid,
    output      logic   [T0_BIT_LEN - 1 : 0]            sk_encode,          // 私钥输出编码(先拼s1 再拼s2 最后拼t0)
    output      logic                                   sk_encode_valid,    // 私钥输出编码有效信号
    
    // --- 签名(sig) 编码信号 ---
    input       logic   [Z_BIT_LEN - 1 : 0]             z,
    input       logic                                   z_valid,
    input       logic   [H_BIT_LEN - 1 : 0]             h,
    input       logic                                   h_valid,
    output      logic   [H_BIT_LEN - 1 : 0]             sig_encode,         // 签名编码输出(先拼z 再拼 Hint(h) )  位宽后面再改 
    output      logic                                   sig_encode_valid    // 签名编码输出有效信号
);

// ==========================================================
// 参数定义
// ==========================================================

// --- 私钥(sk) ---
logic           [S1_S2_BIT_LEN - 1 : 0]                 s1_useful;      // s1 有效位
logic           [S1_S2_BIT_LEN - 1 : 0]                 s2_useful;      // s2 有效位
logic                                                   s1_valid_d;     // s1 有效信号延迟
logic                                                   s2_valid_d;     // s2 有效信号延迟

// ==========================================================
// 具体编码逻辑
// ==========================================================

// --------------------------------
// 公钥(pk) 编码
// --------------------------------
assign pk_encode = t1;
assign pk_encode_valid = t1_valid;

// --------------------------------
// 私钥(sk) 编码
// --------------------------------

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        s1_valid_d <= 1'b0;
        s2_valid_d <= 1'b0;
    end
    else begin
        s1_valid_d <= s1_valid;
        s2_valid_d <= s2_valid;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        s1_useful <= 'd0;
        s2_useful <= 'd0;
    end
    else begin
        case ({s1_valid, s2_valid})
            2'b10 : begin
                s2_useful <= 'd0;
                if (s1 > `eta) 
                    s1_useful <= `eta + `q - s1;
                else 
                    s1_useful <= `eta - s1;    
            end
            2'b01 : begin
                s1_useful <= 'd0;
                if (s2 > `eta)
                    s2_useful <= `eta + `q - s2;
                else
                    s2_useful <= `eta - s2;    
            end
            default : begin
                s1_useful <= 'd0;
                s2_useful <= 'd0;
            end
        endcase
    end
end

always_comb begin
    sk_encode = 'd0;
    sk_encode_valid = 1'b0;
    case ({s1_valid, s2_valid, t0_valid})
        3'b100 : begin
            sk_encode = s1_useful;
            sk_encode_valid = s1_valid;
        end
        3'b010 : begin
            sk_encode = s2_useful;
            sk_encode_valid = s2_valid;
        end
        3'b001 : begin
            sk_encode = t0;
            sk_encode_valid = t0_valid;
        end
    endcase
end

endmodule
