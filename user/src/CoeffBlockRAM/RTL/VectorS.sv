`include "../../param_conf.v"
module VectorS(
    // --- 时钟和复位信号 ---
    input       logic               clk,

    // --- Vector S ---
    input       logic   signed  [15 : 0]    w_VectorS_Coeff,            // 4*4bit有符号数
    input       logic                       w_VectorS_Coeff_valid,
    input       logic           [9 : 0]     w_VectorS_Coeff_addr,
    output      logic           [91 : 0]    r_VectorS_Coeff,            // 对q取模 无符号
    input       logic           [9 : 0]     r_VectorS_Coeff_addr
);

localparam                  			DATA_WIDTH = 'd16;
logic   signed  [DATA_WIDTH - 1 : 0] 	rd_data;

inferred_bram #(
	.DEPTH      	( 960               ),
	.ADDR_WIDTH 	( 10                ),
	.DATA_WIDTH 	( DATA_WIDTH        ))
u_inferred_bram(
	.clk     	( clk                       ),
	.we      	( w_VectorS_Coeff_valid     ),
	.wr_addr 	( w_VectorS_Coeff_addr      ),
	.wr_data 	( w_VectorS_Coeff           ),
	.rd_addr 	( r_VectorS_Coeff_addr      ),
	.rd_data 	( rd_data                   )
);

logic           [22 : 0]                doutb [3 : 0];
always_comb begin
    for (int i = 0 ; i < 4 ; i = i + 1) begin
        logic   [3 : 0]                raw_slice;
        raw_slice = rd_data[i * 4 +: 4];
        if (raw_slice[3])
            doutb[i] = {{19{raw_slice[3]}}, raw_slice} + `q;
        else 
            doutb[i] = {{19{raw_slice[3]}}, raw_slice};
    end    
end
assign r_VectorS_Coeff = {doutb[3], doutb[2], doutb[1], doutb[0]};
endmodule
