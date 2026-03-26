`include "../../param_conf.v"
module VectorM #(
	parameter                   K = 8
)(
    // --- 时钟和复位信号 ---
    input       logic               clk,

    // --- Vector M ---
    input       logic           [91 : 0]    w_VectorM_Coeff [0 : K - 1],
    input       logic                       w_VectorM_Coeff_valid [0 : K - 1],
    input       logic           [5 : 0]     w_VectorM_Coeff_addr [0 : K - 1],

    output      logic           [91 : 0]    r_VectorM_Coeff [0 : K - 1],
    input       logic           [5 : 0]     r_VectorM_Coeff_addr [0 : K - 1]
);

localparam                  			DATA_WIDTH = 'd92;
genvar i;
generate
	for (i = 0 ; i < K ; i = i + 1) begin : row_vector_bram
		inferred_bram #(
			.DEPTH      	( 64  		    ),				// 标量 共256个系数 每个地址存4个系数 共64个地址
			.ADDR_WIDTH 	( 6   		    ),				// 地址线宽：log2(64) = 6
			.DATA_WIDTH 	( DATA_WIDTH   	))				// 数据线宽：92 bit
		u_inferred_bram(
			.clk     	( clk      						),
			.we      	( w_VectorM_Coeff_valid[i]      ),
			.wr_addr 	( w_VectorM_Coeff_addr[i]  		),
			.wr_data 	( w_VectorM_Coeff[i]  			),
			.rd_addr 	( r_VectorM_Coeff_addr[i]  		),
			.rd_data 	( r_VectorM_Coeff[i]  			)
		);
	end
endgenerate

endmodule
