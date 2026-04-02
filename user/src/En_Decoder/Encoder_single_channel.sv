`include "../param_conf.v"
module Encoder_single_channel                                       // 编码模块 单通道
#(
    parameter T1_BIT_LEN = $clog2(`q - 1) - `d,                     // default : 10
    parameter S1_S2_BIT_LEN = $clog2(2 * `eta) + 1,                 // default : 3
    parameter T0_BIT_LEN = `d,                                      // default : 13
    parameter Z_BIT_LEN = `bit_count,                               // default : 18
    parameter H_BIT_LEN = 'd1                                   
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
    input       logic   [23 - 1 : 0]                    s1,                 // ExpandS 中使用`q进行归约 因此位宽为23 实际位宽远少于23
    input       logic                                   s1_valid,
    input       logic   [23 - 1 : 0]                    s2,                 // ExpandS 中使用`q进行归约 因此位宽为23 实际位宽远少于23
    input       logic                                   s2_valid,
    input       logic   [T0_BIT_LEN - 1 : 0]            t0,                 // t 的低位
    input       logic                                   t0_valid,
    output      logic   [T0_BIT_LEN - 1 : 0]            sk_encode,          // 私钥输出编码(先拼s1 再拼s2 最后拼t0)
    output      logic                                   sk_encode_valid,    // 私钥输出编码有效信号
    output      logic   [4 : 0]                         sk_encode_len,
    
    // --- 签名(sig) 编码信号 ---
    input       logic   [23 - 1 : 0]                    z,                  // 这里传递进来的还是有符号数 所以在内部需要先将z转为无符号数
    input       logic                                   z_valid,            
    output      logic   [Z_BIT_LEN - 1 : 0]             sig_encode,         // 签名编码输出(先拼z 再拼 Hint(h))
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

// --- 签名(sig) ---
logic           [Z_BIT_LEN - 1 : 0]                     z_useful;
logic                                                   z_valid_d;

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
    sk_encode_len = 'd0;
    
    case ({s1_valid_d, s2_valid_d, t0_valid})
        3'b100 : begin
            sk_encode = s1_useful;
            sk_encode_valid = s1_valid_d;
            sk_encode_len = S1_S2_BIT_LEN[4 : 0];
        end
        3'b010 : begin
            sk_encode = s2_useful;
            sk_encode_valid = s2_valid_d;
            sk_encode_len = S1_S2_BIT_LEN[4 : 0];
        end
        3'b001 : begin
            sk_encode = t0;
            sk_encode_valid = t0_valid;
            sk_encode_len = T0_BIT_LEN[4 : 0];
        end
    endcase
end

// --------------------------------
// 签名(sig) 编码
// --------------------------------

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) 
        z_valid_d <= 1'b0;
    else       
        z_valid_d <= z_valid;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        z_useful <= 'd0;
    end
    else if (z_valid) begin
        if (z > (`q >> 1)) // 如果 z 是负数
            z_useful <= `gamma_1 + (`q - z);
        else               // 如果 z 是正数
            z_useful <= `gamma_1 - z;
    end
end
assign sig_encode       = z_useful;
assign sig_encode_valid = z_valid_d;

endmodule
