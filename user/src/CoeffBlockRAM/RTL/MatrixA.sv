`include "../../param_conf.v"
module MatrixA(
    // --- 时钟和复位信号 ---
    input       logic               clk,

    // --- Matrix A ---
    input       logic           [91 : 0]    w_MatrixA_Coeff,
    input       logic                       w_MatrixA_Coeff_valid,
    input       logic           [11 : 0]    w_MatrixA_Coeff_addr,
    output      logic           [91 : 0]    r_MatrixA_Coeff,
    input       logic           [11 : 0]    r_MatrixA_Coeff_addr
);

localparam                  			DATA_WIDTH = 'd92;
logic 			[DATA_WIDTH - 1 : 0] 	rd_data;

inferred_bram #(
	.DEPTH      	( 3584  		),
	.ADDR_WIDTH 	( 12    		),
	.DATA_WIDTH 	( DATA_WIDTH   	))
u_inferred_bram(
	.clk     	( clk      						),
	.we      	( w_MatrixA_Coeff_valid       	),
	.wr_addr 	( w_MatrixA_Coeff_addr  		),
	.wr_data 	( w_MatrixA_Coeff  				),
	.rd_addr 	( r_MatrixA_Coeff_addr  		),
	.rd_data 	( rd_data  						)
);

assign r_MatrixA_Coeff = rd_data;

endmodule
