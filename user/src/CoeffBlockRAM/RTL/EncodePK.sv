`include "../../param_conf.v"
module EncodePK(
    // --- 时钟和复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- Encode PK ---
    input       logic           [63 : 0]    w_EncodePK_Coeff,       
    input       logic                       w_EncodePK_Coeff_valid,
    input       logic           [8 : 0]     w_EncodePK_Coeff_addr,
    output      logic           [63 : 0]    r_EncodePK_Coeff,           
    input       logic           [8 : 0]     r_EncodePK_Coeff_addr
);

localparam                  			DATA_WIDTH = 'd64;
inferred_bram #(
	.DEPTH      	( 324           ),          // 标量 共2592个字节 每个地址存8个字节 共324个地址
	.ADDR_WIDTH 	( 9             ),          // 地址线宽：log2(324) = 9
	.DATA_WIDTH 	( DATA_WIDTH    ))          // 数据线宽：64 bit
u_inferred_bram(
	.clk     	( clk                       ),
	.we      	( w_EncodePK_Coeff_valid    ),
	.wr_addr 	( w_EncodePK_Coeff_addr     ),
	.wr_data 	( w_EncodePK_Coeff          ),
	.rd_addr 	( r_EncodePK_Coeff_addr     ),
	.rd_data 	( r_EncodePK_Coeff          )
);

endmodule
