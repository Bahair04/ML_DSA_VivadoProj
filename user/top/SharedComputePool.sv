`include "../src/param_conf.v"
module SharedComputePool
#(
    parameter           K = `k,
    parameter           L = `l
)(
    // --- 时钟和复位信号 ---
	input       logic               clk,
    input       logic               rstn,

    // ==========================================================
    // SHA3(shake256/128)
    // ==========================================================

    // --- SHA3-1 控制接口 ---
    input       logic           [7 : 0]     dout1, 
    input       logic                       dout_valid1, 
    input       logic           [31 : 0]    dout_len1, 
    input       logic           [7 : 0]     mdlen1, 
    input       logic                       init1, 
    input       logic                       start1, 
    output      logic                       done1, 
    input       logic                       start_out1, 
    input       logic           [31 : 0]    out_len1, 
    output      logic                       done_out1, 
    output      logic           [63 : 0]    st_64bit1, 
    output      logic                       st_64bit_valid1,

    // --- SHA3-2 控制接口 ---
    input       logic           [7 : 0]     dout2, 
    input       logic                       dout_valid2, 
    input       logic           [31 : 0]    dout_len2, 
    input       logic           [7 : 0]     mdlen2, 
    input       logic                       init2, 
    input       logic                       start2, 
    output      logic                       done2, 
    input       logic                       start_out2, 
    input       logic           [31 : 0]    out_len2, 
    output      logic                       done_out2, 
    output      logic           [63 : 0]    st_64bit2, 
    output      logic                       st_64bit_valid2

);


// ==========================================================
// SHA3(shake256/128)
// ==========================================================

sha3 u_sha3_1(
	.clk            	( clk             ),
	.rstn           	( rstn            ),
	.din            	( dout1            ),
	.din_valid      	( dout_valid1      ),
	.din_len        	( dout_len1        ),
	.mdlen          	( mdlen1           ),
	.init           	( init1            ),
	.start          	( start1           ),
	.done           	( done1            ),
	.start_out      	( start_out1       ),
	.out_len        	( out_len1         ),
	.done_out       	( done_out1        ),
	.st_64bit       	( st_64bit1        ),
	.st_64bit_valid 	( st_64bit_valid1  )
);

sha3 u_sha3_2(
	.clk            	( clk             ),
	.rstn           	( rstn            ),
	.din            	( dout2            ),
	.din_valid      	( dout_valid2      ),
	.din_len        	( dout_len2        ),
	.mdlen          	( mdlen2           ),
	.init           	( init2            ),
	.start          	( start2           ),
	.done           	( done2            ),
	.start_out      	( start_out2       ),
	.out_len        	( out_len2         ),
	.done_out       	( done_out2        ),
	.st_64bit       	( st_64bit2        ),
	.st_64bit_valid 	( st_64bit_valid2  )
);


endmodule
