module CoeffBlockRAM
#(
	parameter                   K = 8,
	parameter					L = 7
)(
    // --- 时钟和复位信号 ---
    input       logic               clk,

    // --- Matrix A ---
    input       logic           [91 : 0]    w_MatrixA_Coeff,
    input       logic                       w_MatrixA_Coeff_valid,
    input       logic           [11 : 0]    w_MatrixA_Coeff_addr,
    
    output      logic           [91 : 0]    r_MatrixA_Coeff [0 : K - 1],
    input       logic           [8 : 0]     r_MatrixA_Coeff_addr [0 : K - 1],

    // --- Vector S ---
    input       logic   signed  [91 : 0]    w_VectorS1_Coeff,                           // 4*4bit有符号数
    input       logic                       w_VectorS1_Coeff_valid,
    input       logic           [8 : 0]     w_VectorS1_Coeff_addr,

    output      logic           [91 : 0]    r_VectorS1_Coeff,                           // 对q取模 无符号
    input       logic           [8 : 0]     r_VectorS1_Coeff_addr,
	input 		logic						ori_s1_coeff_en,

    input       logic   signed  [91 : 0]    w_VectorS2_Coeff,                           // 4*4bit有符号数
    input       logic                       w_VectorS2_Coeff_valid,
    input       logic           [8 : 0]     w_VectorS2_Coeff_addr,

    output      logic           [91 : 0]    r_VectorS2_Coeff [0 : K - 1],               // 对q取模 无符号
    input       logic           [5 : 0]     r_VectorS2_Coeff_addr [0 : K - 1],
	input 		logic						ori_s2_coeff_en,

    // --- Vector Y ---
    input       logic   signed  [79 : 0]    w_VectorY_Coeff,                            // 4*20bit有符号数
    input       logic                       w_VectorY_Coeff_valid,
    input       logic           [5 : 0]     w_VectorY_Coeff_addr,
    output      logic           [91 : 0]    r_VectorY_Coeff,                            // 对q取模 无符号
    input       logic           [5 : 0]     r_VectorY_Coeff_addr,

    // --- Vector T ---
    input       logic           [91 : 0]    w_VectorT_Coeff [0 : K - 1],
    input       logic                       w_VectorT_Coeff_valid [0 : K - 1],
    input       logic           [5 : 0]     w_VectorT_Coeff_addr [0 : K - 1],

    output      logic           [91 : 0]    r_VectorT_Coeff [0 : K - 1],
    input       logic           [5 : 0]     r_VectorT_Coeff_addr [0 : K - 1],

    // --- Encode PK ---
    input       logic           [63 : 0]    w_EncodePK_Coeff,       
    input       logic                       w_EncodePK_Coeff_valid,
    input       logic           [8 : 0]     w_EncodePK_Coeff_addr,
    output      logic           [63 : 0]    r_EncodePK_Coeff,           
    input       logic           [8 : 0]     r_EncodePK_Coeff_addr,

    // --- Encode SK ---
    input       logic           [63 : 0]    w_EncodeSK_Coeff,       
    input       logic                       w_EncodeSK_Coeff_valid,
    input       logic           [9 : 0]     w_EncodeSK_Coeff_addr,
    output      logic           [63 : 0]    r_EncodeSK_Coeff,           
    input       logic           [9 : 0]     r_EncodeSK_Coeff_addr
);

MatrixA #(
	.K 	( K  ),
	.L	( L  ))
u_MatrixA(
	.clk                   	( clk                    ),
	.w_MatrixA_Coeff       	( w_MatrixA_Coeff        ),
	.w_MatrixA_Coeff_valid 	( w_MatrixA_Coeff_valid  ),
	.w_MatrixA_Coeff_addr  	( w_MatrixA_Coeff_addr   ),
	.r_MatrixA_Coeff       	( r_MatrixA_Coeff        ),
	.r_MatrixA_Coeff_addr  	( r_MatrixA_Coeff_addr   )
);

VectorS1 u_VectorS1(
	.clk                    	( clk                     ),
	.w_VectorS1_Coeff       	( w_VectorS1_Coeff        ),
	.w_VectorS1_Coeff_valid 	( w_VectorS1_Coeff_valid  ),
	.w_VectorS1_Coeff_addr  	( w_VectorS1_Coeff_addr   ),
	.r_VectorS1_Coeff       	( r_VectorS1_Coeff        ),
	.r_VectorS1_Coeff_addr  	( r_VectorS1_Coeff_addr   ),
	.ori_s1_coeff_en			( ori_s1_coeff_en		  )
);

VectorS2 #(
	.K 	( K  ))
u_VectorS2(
	.clk                    	( clk                     ),
	.w_VectorS2_Coeff       	( w_VectorS2_Coeff        ),
	.w_VectorS2_Coeff_valid 	( w_VectorS2_Coeff_valid  ),
	.w_VectorS2_Coeff_addr  	( w_VectorS2_Coeff_addr   ),
	.r_VectorS2_Coeff       	( r_VectorS2_Coeff        ),
	.r_VectorS2_Coeff_addr  	( r_VectorS2_Coeff_addr   ),
	.ori_s2_coeff_en			( ori_s2_coeff_en		  )
);

VectorY u_VectorY(
	.clk                     	( clk                      ),
	.w_VectorY_Coeff         	( w_VectorY_Coeff          ),
	.w_VectorY_Coeff_valid   	( w_VectorY_Coeff_valid    ),
	.w_VectorY_Coeff_addr    	( w_VectorY_Coeff_addr     ),
	.r_VectorY_Coeff         	( r_VectorY_Coeff          ),
	.r_VectorY_Coeff_addr    	( r_VectorY_Coeff_addr     )
);

VectorT #(
	.K 	( K  ))
u_VectorT(
	.clk                   	( clk                    ),
	.w_VectorT_Coeff       	( w_VectorT_Coeff        ),
	.w_VectorT_Coeff_valid 	( w_VectorT_Coeff_valid  ),
	.w_VectorT_Coeff_addr  	( w_VectorT_Coeff_addr   ),
	.r_VectorT_Coeff       	( r_VectorT_Coeff        ),
	.r_VectorT_Coeff_addr  	( r_VectorT_Coeff_addr   )
);

EncodePK u_EncodePK(
	.clk                    	( clk                     ),
	.rstn                   	( rstn                    ),
	.w_EncodePK_Coeff       	( w_EncodePK_Coeff        ),
	.w_EncodePK_Coeff_valid 	( w_EncodePK_Coeff_valid  ),
	.w_EncodePK_Coeff_addr  	( w_EncodePK_Coeff_addr   ),
	.r_EncodePK_Coeff       	( r_EncodePK_Coeff        ),
	.r_EncodePK_Coeff_addr  	( r_EncodePK_Coeff_addr   )
);

EncodeSK u_EncodeSK(
	.clk                    	( clk                     ),
	.rstn                   	( rstn                    ),
	.w_EncodeSK_Coeff       	( w_EncodeSK_Coeff        ),
	.w_EncodeSK_Coeff_valid 	( w_EncodeSK_Coeff_valid  ),
	.w_EncodeSK_Coeff_addr  	( w_EncodeSK_Coeff_addr   ),
	.r_EncodeSK_Coeff       	( r_EncodeSK_Coeff        ),
	.r_EncodeSK_Coeff_addr  	( r_EncodeSK_Coeff_addr   )
);


endmodule
