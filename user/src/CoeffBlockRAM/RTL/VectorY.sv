`include "../../param_conf.v"
module VectorY(
    // --- 时钟和复位信号 ---
    input       logic               clk,

    // --- Vector Y ---
    input       logic   signed  [91 : 0]    w_VectorY_Coeff,            // 4*20bit有符号数
    input       logic                       w_VectorY_Coeff_valid,
    input       logic           [8 : 0]     w_VectorY_Coeff_addr,
    output      logic           [91 : 0]    r_VectorY_Coeff,            // 对q取模 无符号
    input       logic           [8 : 0]     r_VectorY_Coeff_addr
);

localparam                  			DATA_WIDTH = 'd92;
logic   signed  [DATA_WIDTH - 1 : 0] 	rd_data;
inferred_bram #(
	.DEPTH      	( 448            ),          // l维向量 共`l*256个系数 每个地址存4个系数 共448个地址
	.ADDR_WIDTH 	( 9             ),          // 地址线宽：log2(448) = 9
	.DATA_WIDTH 	( DATA_WIDTH    ))          // 数据线宽：92 bit
u_inferred_bram(
	.clk     	( clk                       ),
	.we      	( w_VectorY_Coeff_valid     ),
	.wr_addr 	( w_VectorY_Coeff_addr      ),
	.wr_data 	( w_VectorY_Coeff           ),
	.rd_addr 	( r_VectorY_Coeff_addr      ),
	.rd_data 	( rd_data                   )
);

assign r_VectorY_Coeff = rd_data;
endmodule
