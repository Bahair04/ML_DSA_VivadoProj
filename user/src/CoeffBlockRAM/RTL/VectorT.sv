`include "../../param_conf.v"
module VectorT(
    // --- 时钟和复位信号 ---
    input       logic               clk,

    // --- Vector T ---
    input       logic           [91 : 0]    w_VectorT_Coeff,
    input       logic                       w_VectorT_Coeff_valid,
    input       logic           [8 : 0]     w_VectorT_Coeff_addr,
    output      logic           [91 : 0]    r_VectorT_Coeff,
    input       logic           [8 : 0]     r_VectorT_Coeff_addr
);

localparam                  			DATA_WIDTH = 'd92;
logic 			[DATA_WIDTH - 1 : 0] 	rd_data;

inferred_bram #(
	.DEPTH      	( 512  		    ),
	.ADDR_WIDTH 	( 9   		    ),
	.DATA_WIDTH 	( DATA_WIDTH   	))
u_inferred_bram(
	.clk     	( clk      						),
	.we      	( w_VectorT_Coeff_valid       	),
	.wr_addr 	( w_VectorT_Coeff_addr  		),
	.wr_data 	( w_VectorT_Coeff  				),
	.rd_addr 	( r_VectorT_Coeff_addr  		),
	.rd_data 	( rd_data  						)
);

assign r_VectorT_Coeff = rd_data;

endmodule
