`include "../../param_conf.v"
module EncodeSig(
    // --- 时钟和复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- Encode PK ---
    input       logic           [63 : 0]    w_EncodeSig_Coeff,       
    input       logic                       w_EncodeSig_Coeff_valid,
    input       logic           [9 : 0]     w_EncodeSig_Coeff_addr,
    output      logic           [63 : 0]    r_EncodeSig_Coeff,           
    input       logic           [9 : 0]     r_EncodeSig_Coeff_addr
);

localparam                  			DATA_WIDTH = 'd64;
inferred_bram #(
	.DEPTH      	( 579           ),          // 标量 共4627个字节 每个地址存8个字节 共579个地址
	.ADDR_WIDTH 	( 10            ),          // 地址线宽：log2(579) = 10
	.DATA_WIDTH 	( DATA_WIDTH    ))          // 数据线宽：64 bit
u_inferred_bram(
	.clk     	( clk                       ),
	.we      	( w_EncodeSig_Coeff_valid    ),
	.wr_addr 	( w_EncodeSig_Coeff_addr     ),
	.wr_data 	( w_EncodeSig_Coeff          ),
	.rd_addr 	( r_EncodeSig_Coeff_addr     ),
	.rd_data 	( r_EncodeSig_Coeff          )
);

endmodule
