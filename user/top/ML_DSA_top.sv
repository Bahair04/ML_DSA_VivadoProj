`include "../src/param_conf.v"
module ML_DSA_top
#(
    parameter           K = `k,
    parameter           L = `l,
    parameter T1_BIT_LEN = $clog2(`q - 1) - `d,                     // default : 10
    parameter S1_S2_BIT_LEN = $clog2(2 * `eta) + 1,                 // default : 3
    parameter T0_BIT_LEN = `d,                                      // default : 13
    parameter Z_BIT_LEN = `bit_count,                               // default : 18
    parameter H_BIT_LEN = 'd1       
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

logic           [63 : 0]    w_EncodePK_Coeff_keygen;       
logic                       w_EncodePK_Coeff_valid_keygen;
logic           [8 : 0]     w_EncodePK_Coeff_addr_keygen;
logic           [63 : 0]    r_EncodePK_Coeff_keygen;           
logic           [8 : 0]     r_EncodePK_Coeff_addr_keygen;

logic           [63 : 0]    w_EncodeSK_Coeff_keygen;       
logic                       w_EncodeSK_Coeff_valid_keygen;
logic           [9 : 0]     w_EncodeSK_Coeff_addr_keygen;
logic           [63 : 0]    r_EncodeSK_Coeff_keygen;           
logic           [9 : 0]     r_EncodeSK_Coeff_addr_keygen;

// --------------------------------
// Compute
// --------------------------------

// --- ExpandA 信号 ---
logic           [255 : 0]   rho_ExpandA_keygen;            // 256位随机种子
logic                       start_expand_ExpandA_keygen;   // 开始扩展A矩阵信号
logic           [91 : 0]    coeff_ExpandA_keygen;          // 4*23bit 有效采样系数
logic                       coeff_valid_ExpandA_keygen;    // 4*23bit 有效采样系数信号
logic                       expand_done_ExpandA_keygen;    // 扩展完成信号

logic           [7 : 0]     dout_ExpandA_keygen;           // SHA3 串行输入字节数据
logic                       dout_valid_ExpandA_keygen;     // SHA3 串行输入字节有效信号
logic           [31 : 0]    dout_len_ExpandA_keygen;       // SHA3 串行输入字节长度
logic           [7 : 0]     mdlen_ExpandA_keygen;          // SHA3 Hash长度
logic                       init_ExpandA_keygen;           // SHA3 初始化信号
logic                       start_ExpandA_keygen;          // SHA3 开始装载数据
logic                       done_ExpandA_keygen;           // SHA3 数据装载完成
logic                       start_out_ExpandA_keygen;      // SHA3 开始挤出数据
logic           [31 : 0]    out_len_ExpandA_keygen;        // SHA3 挤出数据长度
logic                       done_out_ExpandA_keygen;       // SHA3 挤出数据完成
logic           [63 : 0]    st_64bit_ExpandA_keygen;       // SHA3 挤出8字节数据
logic                       st_64bit_valid_ExpandA_keygen; // SHA3 挤出8字节数据有效信号

// --- Poly_PAU 信号 ---
logic           [91 : 0]    ori_coeff_keygen;				
logic                       ori_coeff_valid_keygen;		
logic                       request_keygen;                
logic           [91 : 0]    ext_operand_keygen;            
logic                       ext_operand_request_keygen;    
logic           [4 : 0]     mode_config_keygen;            
logic                       ready_keygen;                  
logic           [91 : 0]    con_coeff_keygen;				
logic                       con_coeff_valid_keygen;		

// --- MAC 计算池 ---
logic                       mac_valid_in_keygen;
logic           [91 : 0]    mac_data_in1_keygen [0 : K - 1];
logic           [91 : 0]    mac_data_in2_keygen;
logic           [91 : 0]    mac_data_in3_keygen [0 : K - 1];
logic                       mac_valid_out_keygen;
logic           [91 : 0]    mac_data_out_keygen [0 : K - 1];

// --- Encoder 接口 ---

logic                                           system_done_0_keygen;
logic           [4 * T1_BIT_LEN - 1 : 0]        t1_0_keygen;         
logic                                           t1_valid_0_keygen;
logic           [4 * 23 - 1 : 0]                s1_0_keygen;         
logic                                           s1_valid_0_keygen;
logic           [4 * 23 - 1 : 0]                s2_0_keygen;        
logic                                           s2_valid_0_keygen;
logic           [4 * T0_BIT_LEN - 1 : 0]        t0_0_keygen;         
logic                                           t0_valid_0_keygen;
logic           [4 * Z_BIT_LEN - 1 : 0]         z_0_keygen;
logic                                           z_valid_0_keygen;
logic           [63 : 0]                        encode_0_keygen;
logic                                           encoder_valid_0_keygen;

logic                                           system_done_1_keygen;
logic           [4 * T1_BIT_LEN - 1 : 0]        t1_1_keygen;         
logic                                           t1_valid_1_keygen;
logic           [4 * 23 - 1 : 0]                s1_1_keygen;         
logic                                           s1_valid_1_keygen;
logic           [4 * 23 - 1 : 0]                s2_1_keygen;        
logic                                           s2_valid_1_keygen;
logic           [4 * T0_BIT_LEN - 1 : 0]        t0_1_keygen;         
logic                                           t0_valid_1_keygen;
logic           [4 * Z_BIT_LEN - 1 : 0]         z_1_keygen;
logic                                           z_valid_1_keygen;
logic           [63 : 0]                        encode_1_keygen;
logic                                           encoder_valid_1_keygen;

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

    .w_EncodePK_Coeff           ( w_EncodePK_Coeff_keygen        ),       
    .w_EncodePK_Coeff_valid     ( w_EncodePK_Coeff_valid_keygen  ),
    .w_EncodePK_Coeff_addr      ( w_EncodePK_Coeff_addr_keygen   ),
    .r_EncodePK_Coeff           ( r_EncodePK_Coeff_keygen        ),          
    .r_EncodePK_Coeff_addr      ( r_EncodePK_Coeff_addr_keygen   ),

    .w_EncodeSK_Coeff           ( w_EncodeSK_Coeff_keygen        ),       
    .w_EncodeSK_Coeff_valid     ( w_EncodeSK_Coeff_valid_keygen  ),
    .w_EncodeSK_Coeff_addr      ( w_EncodeSK_Coeff_addr_keygen   ),
    .r_EncodeSK_Coeff           ( r_EncodeSK_Coeff_keygen        ),          
    .r_EncodeSK_Coeff_addr      ( r_EncodeSK_Coeff_addr_keygen   ),

    .rho_ExpandA                ( rho_ExpandA_keygen             ),             
    .start_expand_ExpandA       ( start_expand_ExpandA_keygen    ),             
    .coeff_ExpandA              ( coeff_ExpandA_keygen           ),             
    .coeff_valid_ExpandA        ( coeff_valid_ExpandA_keygen     ),             
    .expand_done_ExpandA        ( expand_done_ExpandA_keygen     ),             

    .dout_ExpandA               ( dout_ExpandA_keygen            ),             
    .dout_valid_ExpandA         ( dout_valid_ExpandA_keygen      ),             
    .dout_len_ExpandA           ( dout_len_ExpandA_keygen        ),             
    .mdlen_ExpandA              ( mdlen_ExpandA_keygen           ),             
    .init_ExpandA               ( init_ExpandA_keygen            ),             
    .start_ExpandA              ( start_ExpandA_keygen           ),             
    .done_ExpandA               ( done_ExpandA_keygen            ),             
    .start_out_ExpandA          ( start_out_ExpandA_keygen       ),             
    .out_len_ExpandA            ( out_len_ExpandA_keygen         ),             
    .done_out_ExpandA           ( done_out_ExpandA_keygen        ),             
    .st_64bit_ExpandA           ( st_64bit_ExpandA_keygen        ),             
    .st_64bit_valid_ExpandA     ( st_64bit_valid_ExpandA_keygen  ),            

    .ori_coeff                  ( ori_coeff_keygen               ),
    .ori_coeff_valid            ( ori_coeff_valid_keygen         ),
    .request                    ( request_keygen                 ),
    .ext_operand                ( ext_operand_keygen             ),
    .ext_operand_request        ( ext_operand_request_keygen     ),
    .mode_config                ( mode_config_keygen             ),
    .ready                      ( ready_keygen                   ),
    .con_coeff                  ( con_coeff_keygen               ),
    .con_coeff_valid            ( con_coeff_valid_keygen         ),

    .mac_valid_in_keygen        ( mac_valid_in_keygen            ),
    .mac_data_in1_keygen        ( mac_data_in1_keygen            ),
    .mac_data_in2_keygen        ( mac_data_in2_keygen            ),
    .mac_data_in3_keygen        ( mac_data_in3_keygen            ),
    .mac_valid_out_keygen       ( mac_valid_out_keygen           ),
    .mac_data_out_keygen        ( mac_data_out_keygen            ),

    .system_done_0              ( system_done_0_keygen           ),
    .t1_0                       ( t1_0_keygen                    ),        
    .t1_valid_0                 ( t1_valid_0_keygen              ),
    .s1_0                       ( s1_0_keygen                    ),        
    .s1_valid_0                 ( s1_valid_0_keygen              ),
    .s2_0                       ( s2_0_keygen                    ),        
    .s2_valid_0                 ( s2_valid_0_keygen              ),
    .t0_0                       ( t0_0_keygen                    ),        
    .t0_valid_0                 ( t0_valid_0_keygen              ),
    .z_0                        ( z_0_keygen                     ),
    .z_valid_0                  ( z_valid_0_keygen               ),
    .encode_0                   ( encode_0_keygen                ),
    .encoder_valid_0            ( encoder_valid_0_keygen         ),

    .system_done_1              ( system_done_1_keygen           ),
    .t1_1                       ( t1_1_keygen                    ),        
    .t1_valid_1                 ( t1_valid_1_keygen              ),
    .s1_1                       ( s1_1_keygen                    ),        
    .s1_valid_1                 ( s1_valid_1_keygen              ),
    .s2_1                       ( s2_1_keygen                    ),        
    .s2_valid_1                 ( s2_valid_1_keygen              ),
    .t0_1                       ( t0_1_keygen                    ),        
    .t0_valid_1                 ( t0_valid_1_keygen              ),
    .z_1                        ( z_1_keygen                     ),
    .z_valid_1                  ( z_valid_1_keygen               ),
    .encode_1                   ( encode_1_keygen                ),
    .encoder_valid_1            ( encoder_valid_1_keygen         ),

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
    .r_VectorT_Coeff_addr_keygen   	(r_VectorT_Coeff_addr_keygen    ),

    .w_EncodePK_Coeff_keygen        (w_EncodePK_Coeff_keygen        ),       
    .w_EncodePK_Coeff_valid_keygen  (w_EncodePK_Coeff_valid_keygen  ),
    .w_EncodePK_Coeff_addr_keygen   (w_EncodePK_Coeff_addr_keygen   ),
    .r_EncodePK_Coeff_keygen        (r_EncodePK_Coeff_keygen        ),           
    .r_EncodePK_Coeff_addr_keygen   (r_EncodePK_Coeff_addr_keygen   ),

    .w_EncodeSK_Coeff_keygen        (w_EncodeSK_Coeff_keygen        ),       
    .w_EncodeSK_Coeff_valid_keygen  (w_EncodeSK_Coeff_valid_keygen  ),
    .w_EncodeSK_Coeff_addr_keygen   (w_EncodeSK_Coeff_addr_keygen   ),
    .r_EncodeSK_Coeff_keygen        (r_EncodeSK_Coeff_keygen        ),           
    .r_EncodeSK_Coeff_addr_keygen   (r_EncodeSK_Coeff_addr_keygen   )
);

GlobalComputeArbitration #(
    .K  ( K  ),
    .L  ( L  )
) u_GlobalComputeArbitration (
    .clk                            ( clk                            ),
    .rstn                           ( rstn                           ),
    .mode_config                    ( mode_config                    ), // 听从最高长官
    
    .rho_ExpandA_keygen             (rho_ExpandA_keygen              ),            
    .start_expand_ExpandA_keygen    (start_expand_ExpandA_keygen     ),   
    .coeff_ExpandA_keygen           (coeff_ExpandA_keygen            ),          
    .coeff_valid_ExpandA_keygen     (coeff_valid_ExpandA_keygen      ),    
    .expand_done_ExpandA_keygen     (expand_done_ExpandA_keygen      ),    

    .dout_ExpandA_keygen            (dout_ExpandA_keygen             ),          
    .dout_valid_ExpandA_keygen      (dout_valid_ExpandA_keygen       ),    
    .dout_len_ExpandA_keygen        (dout_len_ExpandA_keygen         ),      
    .mdlen_ExpandA_keygen           (mdlen_ExpandA_keygen            ),         
    .init_ExpandA_keygen            (init_ExpandA_keygen             ),          
    .start_ExpandA_keygen           (start_ExpandA_keygen            ),         
    .done_ExpandA_keygen            (done_ExpandA_keygen             ),          
    .start_out_ExpandA_keygen       (start_out_ExpandA_keygen        ),     
    .out_len_ExpandA_keygen         (out_len_ExpandA_keygen          ),       
    .done_out_ExpandA_keygen        (done_out_ExpandA_keygen         ),      
    .st_64bit_ExpandA_keygen        (st_64bit_ExpandA_keygen         ),      
    .st_64bit_valid_ExpandA_keygen  (st_64bit_valid_ExpandA_keygen   ),
    
    .ori_coeff_keygen               ( ori_coeff_keygen               ),				
    .ori_coeff_valid_keygen         ( ori_coeff_valid_keygen         ),		
    .request_keygen                 ( request_keygen                 ),                
    .ext_operand_keygen             ( ext_operand_keygen             ),            
    .ext_operand_request_keygen     ( ext_operand_request_keygen     ),    
    .mode_config_keygen             ( mode_config_keygen             ),            
    .ready_keygen                   ( ready_keygen                   ),                  
    .con_coeff_keygen               ( con_coeff_keygen               ),				
    .con_coeff_valid_keygen         ( con_coeff_valid_keygen         ),	

    .mac_valid_in_keygen            ( mac_valid_in_keygen            ),
    .mac_data_in1_keygen            ( mac_data_in1_keygen            ),
    .mac_data_in2_keygen            ( mac_data_in2_keygen            ),
    .mac_data_in3_keygen            ( mac_data_in3_keygen            ),
    .mac_valid_out_keygen           ( mac_valid_out_keygen           ),
    .mac_data_out_keygen            ( mac_data_out_keygen            ),

    // --- Encoder 接口 ---
    .system_done_0_keygen           ( system_done_0_keygen           ),
    .t1_0_keygen                    ( t1_0_keygen                    ),
    .t1_valid_0_keygen              ( t1_valid_0_keygen              ),
    .s1_0_keygen                    ( s1_0_keygen                    ),
    .s1_valid_0_keygen              ( s1_valid_0_keygen              ),
    .s2_0_keygen                    ( s2_0_keygen                    ),
    .s2_valid_0_keygen              ( s2_valid_0_keygen              ),
    .t0_0_keygen                    ( t0_0_keygen                    ),
    .t0_valid_0_keygen              ( t0_valid_0_keygen              ),
    .z_0_keygen                     ( z_0_keygen                     ),
    .z_valid_0_keygen               ( z_valid_0_keygen               ),
    .encode_0_keygen                ( encode_0_keygen                ),
    .encoder_valid_0_keygen         ( encoder_valid_0_keygen         ),

    .system_done_1_keygen           ( system_done_1_keygen           ),
    .t1_1_keygen                    ( t1_1_keygen                    ),
    .t1_valid_1_keygen              ( t1_valid_1_keygen              ),
    .s1_1_keygen                    ( s1_1_keygen                    ),
    .s1_valid_1_keygen              ( s1_valid_1_keygen              ),
    .s2_1_keygen                    ( s2_1_keygen                    ),
    .s2_valid_1_keygen              ( s2_valid_1_keygen              ),
    .t0_1_keygen                    ( t0_1_keygen                    ),
    .t0_valid_1_keygen              ( t0_valid_1_keygen              ),
    .z_1_keygen                     ( z_1_keygen                     ),
    .z_valid_1_keygen               ( z_valid_1_keygen               ),
    .encode_1_keygen                ( encode_1_keygen                ),
    .encoder_valid_1_keygen         ( encoder_valid_1_keygen         ),

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