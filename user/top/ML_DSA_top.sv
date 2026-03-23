module ML_DSA_top
#(
    parameter           K = `k,
    parameter           L = `l
)(
    // --- 时钟和复位信号 ---
	input       logic                       clk,
    input       logic                       rstn,

    // keygen
    input       logic                       start_keygen,          // 启动标志
    output      logic                       key_ready_keygen,      // 准备标志
    output      logic                       done_keygen,           // 完成标志
    input       logic           [255 : 0]   zeta_keygen,           // 32字节 种子
    output      logic           [7 : 0]     pk_keygen,             // 单字节 公钥
    output      logic           [7 : 0]     sk_keygen              // 单字节 私钥

);

logic           [1 : 0]     mode_config;
assign                      mode_config = 'd0;

// ==========================================================
// keygen_internal
// ==========================================================

// --------------------------------
// BRAM
// --------------------------------
logic           [91 : 0]    w_MatrixA_Coeff_keygen;
logic                       w_MatrixA_Coeff_valid_keygen;
logic           [11 : 0]    w_MatrixA_Coeff_addr_keygen;
logic           [91 : 0]    r_MatrixA_Coeff_keygen [0 : K - 1];
logic           [8 : 0]     r_MatrixA_Coeff_addr_keygen [0 : K - 1];

logic   signed  [15 : 0]    w_VectorS1_Coeff_keygen;                   // 4*4bit有符号数
logic                       w_VectorS1_Coeff_valid_keygen;
logic           [8 : 0]     w_VectorS1_Coeff_addr_keygen;
logic           [91 : 0]    r_VectorS1_Coeff_keygen;                   // 对q取模 无符号
logic           [8 : 0]     r_VectorS1_Coeff_addr_keygen;

logic   signed  [15 : 0]    w_VectorS2_Coeff_keygen;                   // 4*4bit有符号数
logic                       w_VectorS2_Coeff_valid_keygen;
logic           [8 : 0]     w_VectorS2_Coeff_addr_keygen;
logic           [91 : 0]    r_VectorS2_Coeff_keygen [0 : K - 1];       // 对q取模 无符号
logic           [5 : 0]     r_VectorS2_Coeff_addr_keygen [0 : K - 1];

logic           [91 : 0]    w_VectorT_Coeff_keygen [0 : K - 1];
logic                       w_VectorT_Coeff_valid_keygen [0 : K - 1];
logic           [5 : 0]     w_VectorT_Coeff_addr_keygen [0 : K - 1];
logic           [91 : 0]    r_VectorT_Coeff_keygen [0 : K - 1];
logic           [5 : 0]     r_VectorT_Coeff_addr_keygen [0 : K - 1];

// --------------------------------
// Compute
// --------------------------------

// --- SHA3-1 控制接口 ---
logic           [7 : 0]     dout1_keygen; 
logic                       dout_valid1_keygen; 
logic           [31 : 0]    dout_len1_keygen; 
logic           [7 : 0]     mdlen1_keygen; 
logic                       init1_keygen; 
logic                       start1_keygen; 
logic                       done1_keygen; 
logic                       start_out1_keygen; 
logic           [31 : 0]    out_len1_keygen; 
logic                       done_out1_keygen; 
logic           [63 : 0]    st_64bit1_keygen; 
logic                       st_64bit_valid1_keygen;

// --- SHA3-2 控制接口 ---
logic           [7 : 0]     dout2_keygen; 
logic                       dout_valid2_keygen; 
logic           [31 : 0]    dout_len2_keygen; 
logic           [7 : 0]     mdlen2_keygen; 
logic                       init2_keygen; 
logic                       start2_keygen; 
logic                       done2_keygen; 
logic                       start_out2_keygen; 
logic           [31 : 0]    out_len2_keygen; 
logic                       done_out2_keygen; 
logic           [63 : 0]    st_64bit2_keygen; 
logic                       st_64bit_valid2_keygen;

keygen_internal #(
	.K 	( K  ),
	.L 	( L  ))
u_keygen_internal(
	.clk                    	( clk                            ),
	.rstn                   	( rstn                           ),

	.start                  	( start_keygen                   ),
	.key_ready              	( key_ready_keygen               ),
	.done                   	( done_keygen                    ),
	.zeta                   	( zeta_keygen                    ),
	.pk                     	( pk_keygen                      ),
	.sk                     	( sk_keygen                      ),

	.w_MatrixA_Coeff        	( w_MatrixA_Coeff_keygen         ),
	.w_MatrixA_Coeff_valid  	( w_MatrixA_Coeff_valid_keygen   ),
	.w_MatrixA_Coeff_addr   	( w_MatrixA_Coeff_addr_keygen    ),
	.r_MatrixA_Coeff        	( r_MatrixA_Coeff_keygen         ),
	.r_MatrixA_Coeff_addr   	( r_MatrixA_Coeff_addr_keygen    ),
	.w_VectorS1_Coeff       	( w_VectorS1_Coeff_keygen        ),
	.w_VectorS1_Coeff_valid 	( w_VectorS1_Coeff_valid_keygen  ),
	.w_VectorS1_Coeff_addr  	( w_VectorS1_Coeff_addr_keygen   ),
	.r_VectorS1_Coeff       	( r_VectorS1_Coeff_keygen        ),
	.r_VectorS1_Coeff_addr  	( r_VectorS1_Coeff_addr_keygen   ),
	.w_VectorS2_Coeff       	( w_VectorS2_Coeff_keygen        ),
	.w_VectorS2_Coeff_valid 	( w_VectorS2_Coeff_valid_keygen  ),
	.w_VectorS2_Coeff_addr  	( w_VectorS2_Coeff_addr_keygen   ),
	.r_VectorS2_Coeff       	( r_VectorS2_Coeff_keygen        ),
	.r_VectorS2_Coeff_addr  	( r_VectorS2_Coeff_addr_keygen   ),
	.w_VectorT_Coeff        	( w_VectorT_Coeff_keygen         ),
	.w_VectorT_Coeff_valid  	( w_VectorT_Coeff_valid_keygen   ),
	.w_VectorT_Coeff_addr   	( w_VectorT_Coeff_addr_keygen    ),
	.r_VectorT_Coeff        	( r_VectorT_Coeff_keygen         ),
	.r_VectorT_Coeff_addr   	( r_VectorT_Coeff_addr_keygen    ),

	.dout1                  	( dout1_keygen                   ),
	.dout_valid1            	( dout_valid1_keygen             ),
	.dout_len1              	( dout_len1_keygen               ),
	.mdlen1                 	( mdlen1_keygen                  ),
	.init1                  	( init1_keygen                   ),
	.start1                 	( start1_keygen                  ),
	.done1                  	( done1_keygen                   ),
	.start_out1             	( start_out1_keygen              ),
	.out_len1               	( out_len1_keygen                ),
	.done_out1              	( done_out1_keygen               ),
	.st_64bit1              	( st_64bit1_keygen               ),
	.st_64bit_valid1        	( st_64bit_valid1_keygen         ),

	.dout2                  	( dout2_keygen                   ),
	.dout_valid2            	( dout_valid2_keygen             ),
	.dout_len2              	( dout_len2_keygen               ),
	.mdlen2                 	( mdlen2_keygen                  ),
	.init2                  	( init2_keygen                   ),
	.start2                 	( start2_keygen                  ),
	.done2                  	( done2_keygen                   ),
	.start_out2             	( start_out2_keygen              ),
	.out_len2               	( out_len2_keygen                ),
	.done_out2              	( done_out2_keygen               ),
	.st_64bit2              	( st_64bit2_keygen               ),
	.st_64bit_valid2        	( st_64bit_valid2_keygen         )
);

GlobalBRAMArbitration #(
    .K 	( K  ),
    .L 	( L  ))
u_GlobalBRAMArbitration(
    .clk                           	(clk                            ),
    .rstn                          	(rstn                           ),
    .mode_config                   	(mode_config                    ),
    .w_MatrixA_Coeff_keygen        	(w_MatrixA_Coeff_keygen         ),
    .w_MatrixA_Coeff_valid_keygen  	(w_MatrixA_Coeff_valid_keygen   ),
    .w_MatrixA_Coeff_addr_keygen   	(w_MatrixA_Coeff_addr_keygen    ),
    .r_MatrixA_Coeff_keygen        	(r_MatrixA_Coeff_keygen         ),
    .r_MatrixA_Coeff_addr_keygen   	(r_MatrixA_Coeff_addr_keygen    ),
    .w_VectorS1_Coeff_keygen       	(w_VectorS1_Coeff_keygen        ),
    .w_VectorS1_Coeff_valid_keygen 	(w_VectorS1_Coeff_valid_keygen  ),
    .w_VectorS1_Coeff_addr_keygen  	(w_VectorS1_Coeff_addr_keygen   ),
    .r_VectorS1_Coeff_keygen       	(r_VectorS1_Coeff_keygen        ),
    .r_VectorS1_Coeff_addr_keygen  	(r_VectorS1_Coeff_addr_keygen   ),
    .w_VectorS2_Coeff_keygen       	(w_VectorS2_Coeff_keygen        ),
    .w_VectorS2_Coeff_valid_keygen 	(w_VectorS2_Coeff_valid_keygen  ),
    .w_VectorS2_Coeff_addr_keygen  	(w_VectorS2_Coeff_addr_keygen   ),
    .r_VectorS2_Coeff_keygen       	(r_VectorS2_Coeff_keygen        ),
    .r_VectorS2_Coeff_addr_keygen  	(r_VectorS2_Coeff_addr_keygen   ),
    .w_VectorT_Coeff_keygen        	(w_VectorT_Coeff_keygen         ),
    .w_VectorT_Coeff_valid_keygen  	(w_VectorT_Coeff_valid_keygen   ),
    .w_VectorT_Coeff_addr_keygen   	(w_VectorT_Coeff_addr_keygen    ),
    .r_VectorT_Coeff_keygen        	(r_VectorT_Coeff_keygen         ),
    .r_VectorT_Coeff_addr_keygen   	(r_VectorT_Coeff_addr_keygen    )
);

GlobalComputeArbitration #(
    .K  ( K  ),
    .L  ( L  )
) u_GlobalComputeArbitration (
    .clk                            ( clk                            ),
    .rstn                           ( rstn                           ),
    .mode_config                    ( mode_config                    ), // 听从最高长官
    
    // KeyGen 数据流对接
    .dout1_keygen                   ( dout1_keygen                   ), 
    .dout_valid1_keygen             ( dout_valid1_keygen             ), 
    .dout_len1_keygen               ( dout_len1_keygen               ), 
    .mdlen1_keygen                  ( mdlen1_keygen                  ), 
    .init1_keygen                   ( init1_keygen                   ), 
    .start1_keygen                  ( start1_keygen                  ), 
    .done1_keygen                   ( done1_keygen                   ), 
    .start_out1_keygen              ( start_out1_keygen              ), 
    .out_len1_keygen                ( out_len1_keygen                ), 
    .done_out1_keygen               ( done_out1_keygen               ), 
    .st_64bit1_keygen               ( st_64bit1_keygen               ), 
    .st_64bit_valid1_keygen         ( st_64bit_valid1_keygen         ),

    .dout2_keygen                   ( dout2_keygen                   ), 
    .dout_valid2_keygen             ( dout_valid2_keygen             ), 
    .dout_len2_keygen               ( dout_len2_keygen               ), 
    .mdlen2_keygen                  ( mdlen2_keygen                  ), 
    .init2_keygen                   ( init2_keygen                   ), 
    .start2_keygen                  ( start2_keygen                  ), 
    .done2_keygen                   ( done2_keygen                   ), 
    .start_out2_keygen              ( start_out2_keygen              ), 
    .out_len2_keygen                ( out_len2_keygen                ), 
    .done_out2_keygen               ( done_out2_keygen               ), 
    .st_64bit2_keygen               ( st_64bit2_keygen               ), 
    .st_64bit_valid2_keygen         ( st_64bit_valid2_keygen         )
);

endmodule