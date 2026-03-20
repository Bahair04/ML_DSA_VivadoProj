`include "../../param_conf.v"
module VectorY(
    // --- 时钟和复位信号 ---
    input       logic               clk,

    // --- Vector Y ---
    input       logic   signed  [79 : 0]    w_VectorY_Coeff,            // 4*20bit有符号数
    input       logic                       w_VectorY_Coeff_valid,
    input       logic           [5 : 0]     w_VectorY_Coeff_addr,
    output      logic           [91 : 0]    r_VectorY_Coeff,            // 对q取模 无符号
    input       logic           [5 : 0]     r_VectorY_Coeff_addr
);

localparam                  			DATA_WIDTH = 'd80;
logic   signed  [DATA_WIDTH - 1 : 0] 	rd_data;
inferred_bram #(
	.DEPTH      	( 64            ),          // 标量 共256个系数 每个地址存4个系数 共64个地址
	.ADDR_WIDTH 	( 6             ),          // 地址线宽：log2(64) = 6
	.DATA_WIDTH 	( DATA_WIDTH    ))          // 数据线宽：80 bit
u_inferred_bram(
	.clk     	( clk                       ),
	.we      	( w_VectorY_Coeff_valid     ),
	.wr_addr 	( w_VectorY_Coeff_addr      ),
	.wr_data 	( w_VectorY_Coeff           ),
	.rd_addr 	( r_VectorY_Coeff_addr      ),
	.rd_data 	( rd_data                   )
);

logic           [22 : 0]                doutb [3 : 0];
integer i;
always_comb begin
    for (i = 0 ; i < 4 ; i = i + 1) begin
        logic   [19 : 0]                raw_slice;
        raw_slice = rd_data[i * 20 +: 20];
        if (raw_slice[19])
            doutb[i] = {{3{raw_slice[19]}}, raw_slice} + `q;
        else 
            doutb[i] = {{3{raw_slice[19]}}, raw_slice};
    end    
end
assign r_VectorY_Coeff = {doutb[3], doutb[2], doutb[1], doutb[0]};
endmodule
