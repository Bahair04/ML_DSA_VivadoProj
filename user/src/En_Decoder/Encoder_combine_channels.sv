`include "../param_conf.v"
module Encoder_combine_channels
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
    input       logic   [255 : 0]                       rho,        // 256 位随机种子
    input       logic   [4 * T1_BIT_LEN - 1 : 0]        t1,         // t 的高位
    input       logic                                   t1_valid,

    // --- 私钥(sk) 编码信号 ---
    input       logic   [255 : 0]                       K,          // 256 位随机种子
    input       logic   [4 * 23 - 1 : 0]                s1,         // ExpandS 中使用`q进行归约 因此位宽为23 实际位宽原少于23
    input       logic                                   s1_valid,
    input       logic   [4 * 23 - 1 : 0]                s2,         // ExpandS 中使用`q进行归约 因此位宽为23 实际位宽原少于23
    input       logic                                   s2_valid,
    input       logic   [4 * T0_BIT_LEN - 1 : 0]        t0,         // t 的低位
    input       logic                                   t0_valid,

    // --- 签名(sig) 编码信号 ---
    input       logic   [4 * Z_BIT_LEN - 1 : 0]         z,
    input       logic                                   z_valid,
    input       logic   [4 * H_BIT_LEN - 1 : 0]         h,
    input       logic                                   h_valid,
    
    // --- 编码输出接口 输出位宽 8 个字节 ---
    output      logic   [63 : 0]                        encode,
    output      logic                                   encoder_valid
);

logic   [T1_BIT_LEN - 1 : 0] 	                        pk_encode [0 : 3];
logic                  	                                pk_encode_valid [0 : 3];
logic   [T0_BIT_LEN - 1 : 0] 	                        sk_encode [0 : 3];
logic                  	                                sk_encode_valid [0 : 3];
logic   [H_BIT_LEN - 1 : 0]  	                        sig_encode [0 : 3];
logic                  	                                sig_encode_valid [0 : 3];

genvar i;
generate
    for (i = 0 ; i < 4 ; i++) begin : initiate_four_channels
        Encoder_single_channel u_Encoder_single_channel(
            .clk              	( clk                                           ),
            .rstn             	( rstn                                          ),
            
            .t1               	( t1[i * T1_BIT_LEN +: T1_BIT_LEN]              ),
            .t1_valid         	( t1_valid                                      ),
            .pk_encode        	( pk_encode[i]                                  ),
            .pk_encode_valid  	( pk_encode_valid[i]                            ),
            
            .s1               	( s1[i * S1_S2_BIT_LEN +: S1_S2_BIT_LEN]        ),
            .s1_valid         	( s1_valid                                      ),
            .s2               	( s2[i * S1_S2_BIT_LEN +: S1_S2_BIT_LEN]        ),
            .s2_valid         	( s2_valid                                      ),
            .t0               	( t0[i * T0_BIT_LEN +: T0_BIT_LEN]              ),
            .t0_valid         	( t0_valid                                      ),
            .sk_encode        	( sk_encode[i]                                  ),
            .sk_encode_valid  	( sk_encode_valid[i]                            ),
            
            .z                	( z[i * Z_BIT_LEN +: Z_BIT_LEN]                 ),
            .z_valid          	( z_valid                                       ),
            .h                	( h[i * H_BIT_LEN +: H_BIT_LEN]                 ),
            .h_valid          	( h_valid                                       ),
            .sig_encode       	( sig_encode[i]                                 ),
            .sig_encode_valid 	( sig_encode_valid[i]                           )
        );
    end
endgenerate



endmodule
