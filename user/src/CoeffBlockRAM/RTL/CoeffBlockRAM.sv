module CoeffBlockRAM(
    // --- 时钟和复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- Matrix A ---
    input       logic           [91 : 0]    w_MatrixA_Coeff,
    input       logic                       w_MatrixA_Coeff_valid,
    input       logic           [11 : 0]    w_MatrixA_Coeff_addr,
    output      logic           [22 : 0]    r_MatrixA_Coeff,
    input       logic                       r_MatrixA_Coeff_request,
    input       logic           [13 : 0]    r_MatrixA_Coeff_addr,

    // --- Vector S ---
    input       logic   signed  [15 : 0]    w_VectorS_Coeff,            // 4*4bit有符号数
    input       logic                       w_VectorS_Coeff_valid,
    input       logic           [9 : 0]     w_VectorS_Coeff_addr,
    output      logic           [22 : 0]    r_VectorS_Coeff,            // 对q取模 无符号
    input       logic                       r_VectorS_Coeff_request,
    input       logic           [11 : 0]    r_VectorS_Coeff_addr,

    // --- Vector Y ---
    input       logic   signed  [79 : 0]    w_VectorY_Coeff,            // 4*20bit有符号数
    input       logic                       w_VectorY_Coeff_valid,
    input       logic           [5 : 0]     w_VectorY_Coeff_addr,
    output      logic           [22 : 0]    r_VectorY_Coeff,            // 对q取模 无符号
    input       logic                       r_VectorY_Coeff_request,
    input       logic           [7 : 0]     r_VectorY_Coeff_addr
);

MatrixA u_MatrixA(
	.clk                     	( clk                      ),
	.rstn                    	( rstn                     ),
	.w_MatrixA_Coeff         	( w_MatrixA_Coeff          ),
	.w_MatrixA_Coeff_valid   	( w_MatrixA_Coeff_valid    ),
	.w_MatrixA_Coeff_addr    	( w_MatrixA_Coeff_addr     ),
	.r_MatrixA_Coeff         	( r_MatrixA_Coeff          ),
	.r_MatrixA_Coeff_request 	( r_MatrixA_Coeff_request  ),
	.r_MatrixA_Coeff_addr    	( r_MatrixA_Coeff_addr     )
);

VectorS u_VectorS(
	.clk                     	( clk                      ),
	.rstn                    	( rstn                     ),
	.w_VectorS_Coeff         	( w_VectorS_Coeff          ),
	.w_VectorS_Coeff_valid   	( w_VectorS_Coeff_valid    ),
	.w_VectorS_Coeff_addr    	( w_VectorS_Coeff_addr     ),
	.r_VectorS_Coeff         	( r_VectorS_Coeff          ),
	.r_VectorS_Coeff_request 	( r_VectorS_Coeff_request  ),
	.r_VectorS_Coeff_addr    	( r_VectorS_Coeff_addr     )
);

VectorY u_VectorY(
	.clk                     	( clk                      ),
	.rstn                    	( rstn                     ),
	.w_VectorY_Coeff         	( w_VectorY_Coeff          ),
	.w_VectorY_Coeff_valid   	( w_VectorY_Coeff_valid    ),
	.w_VectorY_Coeff_addr    	( w_VectorY_Coeff_addr     ),
	.r_VectorY_Coeff         	( r_VectorY_Coeff          ),
	.r_VectorY_Coeff_request 	( r_VectorY_Coeff_request  ),
	.r_VectorY_Coeff_addr    	( r_VectorY_Coeff_addr     )
);

endmodule
