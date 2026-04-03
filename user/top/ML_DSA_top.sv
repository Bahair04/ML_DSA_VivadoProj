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

    // ==========================================
    // 顶层对外接口
    // ==========================================
    // --- KeyGen 接口 ---
    input       logic                       start_keygen,          
    output      logic                       key_ready_keygen,      
    output      logic                       done_keygen,           
    input       logic           [255 : 0]   zeta_keygen,           
    output      logic           [7 : 0]     pk_keygen,             
    output      logic           [7 : 0]     sk_keygen,             

    // --- Sign 接口 ---
    input       logic                       start_sign,          
    output      logic                       sign_ready,      
    output      logic                       done_sign,
    input       logic           [511 : 0]   mu,             // 64字节 预哈希消息
    input       logic           [255 : 0]   rnd,            // 32字节 随机数

    // --- 控制标志位 ---
    input       logic                       start_verify,          // 启动标志
    output      logic                       verify_ready,          // 准备标志
    output      logic                       done_verify,           // 完成标志
    input       logic           [511 : 0]   mu_verify              // 64字节 预哈希消息
);

// ==========================================================
// 模式仲裁控制 (动态切换算力池与BRAM的控制权)
// ==========================================================
logic           [1 : 0]     mode_config;

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) 
        mode_config <= 2'd0;
    else if (start_keygen)
        mode_config <= 2'd0;    // 0: KeyGen 接管
    else if (start_sign)
        mode_config <= 2'd1;    // 1: Sign 接管
    else if (start_verify)
        mode_config <= 2'd2;    // 2: Verify 接管
end

// ==========================================================
// 内部线网声明：KeyGen 专属线网
// ==========================================================
// --- init flag ---
logic                       reject_init;

// --- BRAM ---
logic           [91 : 0]    w_MatrixA_Coeff_keygen;
logic                       w_MatrixA_Coeff_valid_keygen;
logic           [11 : 0]    w_MatrixA_Coeff_addr_keygen;
logic           [91 : 0]    r_MatrixA_Coeff_keygen [0 : K - 1];
logic           [8 : 0]     r_MatrixA_Coeff_addr_keygen [0 : K - 1];

logic   signed  [91 : 0]    w_VectorS1_Coeff_keygen;                   
logic                       w_VectorS1_Coeff_valid_keygen;
logic           [8 : 0]     w_VectorS1_Coeff_addr_keygen;
logic           [91 : 0]    r_VectorS1_Coeff_keygen;                   
logic           [8 : 0]     r_VectorS1_Coeff_addr_keygen;

logic   signed  [91 : 0]    w_VectorS2_Coeff_keygen;                   
logic                       w_VectorS2_Coeff_valid_keygen;
logic           [8 : 0]     w_VectorS2_Coeff_addr_keygen;
logic           [91 : 0]    r_VectorS2_Coeff_keygen [0 : K - 1];       
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

// --- Compute ---
logic           [255 : 0]   rho_ExpandA_keygen;            
logic                       start_expand_ExpandA_keygen;   
logic           [91 : 0]    coeff_ExpandA_keygen;          
logic                       coeff_valid_ExpandA_keygen;    
logic                       expand_done_ExpandA_keygen;    

logic           [7 : 0]     dout_ExpandA_keygen;           
logic                       dout_valid_ExpandA_keygen;     
logic           [31 : 0]    dout_len_ExpandA_keygen;       
logic           [7 : 0]     mdlen_ExpandA_keygen;          
logic                       init_ExpandA_keygen;           
logic                       start_ExpandA_keygen;          
logic                       done_ExpandA_keygen;           
logic                       start_out_ExpandA_keygen;      
logic           [31 : 0]    out_len_ExpandA_keygen;        
logic                       done_out_ExpandA_keygen;       
logic           [63 : 0]    st_64bit_ExpandA_keygen;       
logic                       st_64bit_valid_ExpandA_keygen; 

logic           [91 : 0]    ori_coeff_keygen;               
logic                       ori_coeff_valid_keygen;     
logic                       request_keygen;                
logic           [91 : 0]    ext_operand_keygen;            
logic                       ext_operand_request_keygen;    
logic           [4 : 0]     mode_config_keygen;            
logic                       ready_keygen;                  
logic           [91 : 0]    con_coeff_keygen;               
logic                       con_coeff_valid_keygen;     

logic                       mac_valid_in_keygen;
logic           [91 : 0]    mac_data_in1_keygen [0 : K - 1];
logic           [91 : 0]    mac_data_in2_keygen;
logic           [91 : 0]    mac_data_in3_keygen [0 : K - 1];
logic                       mac_valid_out_keygen;
logic           [91 : 0]    mac_data_out_keygen [0 : K - 1];

// --- Encoder-0 ---
logic                                       system_done_0_keygen;
logic           [4 * T1_BIT_LEN - 1 : 0]    t1_0_keygen;         
logic                                       t1_valid_0_keygen;
logic           [4 * 23 - 1 : 0]            s1_0_keygen;         
logic                                       s1_valid_0_keygen;
logic           [4 * 23 - 1 : 0]            s2_0_keygen;        
logic                                       s2_valid_0_keygen;
logic           [4 * T0_BIT_LEN - 1 : 0]    t0_0_keygen;         
logic                                       t0_valid_0_keygen;
logic           [4 * 23 - 1 : 0]            z_0_keygen;
logic                                       z_valid_0_keygen;
logic           [63 : 0]                    encode_0_keygen;
logic                                       encoder_valid_0_keygen;

// --- Encoder-1 ---
logic                                       system_done_1_keygen;
logic           [4 * T1_BIT_LEN - 1 : 0]    t1_1_keygen;         
logic                                       t1_valid_1_keygen;
logic           [4 * 23 - 1 : 0]            s1_1_keygen;         
logic                                       s1_valid_1_keygen;
logic           [4 * 23 - 1 : 0]            s2_1_keygen;        
logic                                       s2_valid_1_keygen;
logic           [4 * T0_BIT_LEN - 1 : 0]    t0_1_keygen;         
logic                                       t0_valid_1_keygen;
logic           [4 * 23 - 1 : 0]            z_1_keygen;
logic                                       z_valid_1_keygen;
logic           [63 : 0]                    encode_1_keygen;
logic                                       encoder_valid_1_keygen;

// --- SHA3-1 ---
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

// --- SHA3-2 ---
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


// ==========================================================
// 内部线网声明：Sign 专属线网
// ==========================================================
// --- BRAM ---
logic           [91 : 0]    w_MatrixA_Coeff_sign;
logic                       w_MatrixA_Coeff_valid_sign;
logic           [11 : 0]    w_MatrixA_Coeff_addr_sign;
logic           [91 : 0]    r_MatrixA_Coeff_sign [0 : K - 1];
logic           [8 : 0]     r_MatrixA_Coeff_addr_sign [0 : K - 1];

logic   signed  [91 : 0]    w_VectorS1_Coeff_sign;                   
logic                       w_VectorS1_Coeff_valid_sign;
logic           [8 : 0]     w_VectorS1_Coeff_addr_sign;
logic           [91 : 0]    r_VectorS1_Coeff_sign;                   
logic           [8 : 0]     r_VectorS1_Coeff_addr_sign;

logic   signed  [91 : 0]    w_VectorS2_Coeff_sign;                   
logic                       w_VectorS2_Coeff_valid_sign;
logic           [8 : 0]     w_VectorS2_Coeff_addr_sign;
logic           [91 : 0]    r_VectorS2_Coeff_sign [0 : K - 1];       
logic           [5 : 0]     r_VectorS2_Coeff_addr_sign [0 : K - 1];

logic   signed  [91 : 0]    w_VectorY_Coeff_sign;
logic                       w_VectorY_Coeff_valid_sign;
logic           [8 : 0]     w_VectorY_Coeff_addr_sign;
logic           [91 : 0]    r_VectorY_Coeff_sign;
logic           [8 : 0]     r_VectorY_Coeff_addr_sign;

logic           [91 : 0]    w_VectorT_Coeff_sign [0 : K - 1];
logic                       w_VectorT_Coeff_valid_sign [0 : K - 1];
logic           [5 : 0]     w_VectorT_Coeff_addr_sign [0 : K - 1];
logic           [91 : 0]    r_VectorT_Coeff_sign [0 : K - 1];
logic           [5 : 0]     r_VectorT_Coeff_addr_sign [0 : K - 1];

logic           [91 : 0]    w_VectorM_Coeff_sign [0 : K - 1];
logic                       w_VectorM_Coeff_valid_sign [0 : K - 1];
logic           [5 : 0]     w_VectorM_Coeff_addr_sign [0 : K - 1];
logic           [91 : 0]    r_VectorM_Coeff_sign [0 : K - 1];
logic           [5 : 0]     r_VectorM_Coeff_addr_sign [0 : K - 1];

logic           [63 : 0]    r_EncodeSK_Coeff_sign;           
logic           [9 : 0]     r_EncodeSK_Coeff_addr_sign;

logic           [63 : 0]    w_EncodeSig_Coeff_sign;       
logic                       w_EncodeSig_Coeff_valid_sign;
logic           [8 : 0]     w_EncodeSig_Coeff_addr_sign;

// --- Compute ---
logic           [255 : 0]   rho_ExpandA_sign;            
logic                       start_expand_ExpandA_sign;   
logic           [91 : 0]    coeff_ExpandA_sign;          
logic                       coeff_valid_ExpandA_sign;    
logic                       expand_done_ExpandA_sign;    

logic           [7 : 0]     dout_ExpandA_sign;           
logic                       dout_valid_ExpandA_sign;     
logic           [31 : 0]    dout_len_ExpandA_sign;       
logic           [7 : 0]     mdlen_ExpandA_sign;          
logic                       init_ExpandA_sign;           
logic                       start_ExpandA_sign;          
logic                       done_ExpandA_sign;           
logic                       start_out_ExpandA_sign;      
logic           [31 : 0]    out_len_ExpandA_sign;        
logic                       done_out_ExpandA_sign;       
logic           [63 : 0]    st_64bit_ExpandA_sign;       
logic                       st_64bit_valid_ExpandA_sign; 

logic           [91 : 0]    ori_coeff_sign;               
logic                       ori_coeff_valid_sign;     
logic                       request_sign;                
logic           [91 : 0]    ext_operand_sign;            
logic                       ext_operand_request_sign;    
logic           [4 : 0]     mode_config_sign;            
logic                       ready_sign;                  
logic           [91 : 0]    con_coeff_sign;               
logic                       con_coeff_valid_sign;     

logic                       mac_valid_in_sign;
logic           [91 : 0]    mac_data_in1_sign [0 : K - 1];
logic           [91 : 0]    mac_data_in2_sign;
logic           [91 : 0]    mac_data_in3_sign [0 : K - 1];
logic                       mac_valid_out_sign;
logic           [91 : 0]    mac_data_out_sign [0 : K - 1];

// --- SHA3-1 ---
logic           [7 : 0]     dout1_sign; 
logic                       dout_valid1_sign; 
logic           [31 : 0]    dout_len1_sign; 
logic           [7 : 0]     mdlen1_sign; 
logic                       init1_sign; 
logic                       start1_sign; 
logic                       done1_sign; 
logic                       start_out1_sign; 
logic           [31 : 0]    out_len1_sign; 
logic                       done_out1_sign; 
logic           [63 : 0]    st_64bit1_sign; 
logic                       st_64bit_valid1_sign;

// --- SHA3-2 ---
logic           [7 : 0]     dout2_sign; 
logic                       dout_valid2_sign; 
logic           [31 : 0]    dout_len2_sign; 
logic           [7 : 0]     mdlen2_sign; 
logic                       init2_sign; 
logic                       start2_sign; 
logic                       done2_sign; 
logic                       start_out2_sign; 
logic           [31 : 0]    out_len2_sign; 
logic                       done_out2_sign; 
logic           [63 : 0]    st_64bit2_sign; 
logic                       st_64bit_valid2_sign;

// --- coeffModq ---
logic                       CoeffModq_ram_rd_en_sign;       
logic           [63 : 0]    CoeffModq_ori_coeff_sign;       
logic                       CoeffModq_ori_coeff_valid_sign; 
logic           [2 : 0]     CoeffModq_coeff_type_sign;     
logic                       CoeffModq_poly_start_pulse_sign; 
logic           [91 : 0]    CoeffModq_modq_coeff_sign;      
logic                       CoeffModq_modq_coeff_valid_sign;

// ==========================================================
// 内部线网声明：Verify 专属线网
// ==========================================================
// --- BRAM 总线信号 ---
logic           [91 : 0]    w_MatrixA_Coeff_verify;
logic                       w_MatrixA_Coeff_valid_verify;
logic           [11 : 0]    w_MatrixA_Coeff_addr_verify;
logic           [91 : 0]    r_MatrixA_Coeff_verify [0 : K - 1];
logic           [8 : 0]     r_MatrixA_Coeff_addr_verify [0 : K - 1];

logic           [91 : 0]    w_VectorT_Coeff_verify [0 : K - 1];
logic                       w_VectorT_Coeff_valid_verify [0 : K - 1];
logic           [5 : 0]     w_VectorT_Coeff_addr_verify [0 : K - 1];
logic           [91 : 0]    r_VectorT_Coeff_verify [0 : K - 1];
logic           [5 : 0]     r_VectorT_Coeff_addr_verify [0 : K - 1];

logic           [63 : 0]    r_EncodePK_Coeff_verify;           
logic           [8 : 0]     r_EncodePK_Coeff_addr_verify;

logic           [63 : 0]    r_EncodeSig_Coeff_verify;           
logic           [9 : 0]     r_EncodeSig_Coeff_addr_verify;

// --- CoeffModq ---
logic                       CoeffModq_ram_rd_en_verify;       
logic           [63 : 0]    CoeffModq_ori_coeff_verify;       
logic                       CoeffModq_ori_coeff_valid_verify; 
logic           [2 : 0]     CoeffModq_coeff_type_verify;     
logic                       CoeffModq_poly_start_pulse_verify; 
logic           [91 : 0]    CoeffModq_modq_coeff_verify;      
logic                       CoeffModq_modq_coeff_valid_verify;

// --- ExpandA 信号 ---
logic           [255 : 0]   rho_ExpandA_verify;            // 256位随机种子
logic                       start_expand_ExpandA_verify;   // 开始扩展A矩阵信号
logic           [91 : 0]    coeff_ExpandA_verify;          // 4*23bit 有效采样系数
logic                       coeff_valid_ExpandA_verify;    // 4*23bit 有效采样系数信号
logic                       expand_done_ExpandA_verify;    // 扩展完成信号

logic           [7 : 0]     dout_ExpandA_verify;           // SHA3 串行输入字节数据
logic                       dout_valid_ExpandA_verify;     // SHA3 串行输入字节有效信号
logic           [31 : 0]    dout_len_ExpandA_verify;       // SHA3 串行输入字节长度
logic           [7 : 0]     mdlen_ExpandA_verify;          // SHA3 Hash长度
logic                       init_ExpandA_verify;           // SHA3 初始化信号
logic                       start_ExpandA_verify;          // SHA3 开始装载数据
logic                       done_ExpandA_verify;           // SHA3 数据装载完成
logic                       start_out_ExpandA_verify;      // SHA3 开始挤出数据
logic           [31 : 0]    out_len_ExpandA_verify;        // SHA3 挤出数据长度
logic                       done_out_ExpandA_verify;       // SHA3 挤出数据完成
logic           [63 : 0]    st_64bit_ExpandA_verify;       // SHA3 挤出8字节数据
logic                       st_64bit_valid_ExpandA_verify; // SHA3 挤出8字节数据有效信号

// --- SHA3-1 控制接口 ---
logic           [7 : 0]     dout1_verify; 
logic                       dout_valid1_verify; 
logic           [31 : 0]    dout_len1_verify; 
logic           [7 : 0]     mdlen1_verify; 
logic                       init1_verify; 
logic                       start1_verify; 
logic                       done1_verify; 
logic                       start_out1_verify; 
logic           [31 : 0]    out_len1_verify; 
logic                       done_out1_verify; 
logic           [63 : 0]    st_64bit1_verify; 
logic                       st_64bit_valid1_verify;

// --- SHA3-2 控制接口 ---
logic           [7 : 0]     dout2_verify;
logic                       dout_valid2_verify;
logic           [31 : 0]    dout_len2_verify;
logic           [7 : 0]     mdlen2_verify;
logic                       init2_verify;
logic                       start2_verify;
logic                       done2_verify;
logic                       start_out2_verify;
logic           [31 : 0]    out_len2_verify;
logic                       done_out2_verify;
logic           [63 : 0]    st_64bit2_verify;
logic                       st_64bit_valid2_verify;

// ==========================================================
// 模块例化区
// ==========================================================

keygen_internal #(
    .K  ( K  ),
    .L  ( L  ))
u_keygen_internal(
    .clk                        ( clk                            ),
    .rstn                       ( rstn                           ),

    .start                      ( start_keygen                   ),
    .key_ready                  ( key_ready_keygen               ),
    .done                       ( done_keygen                    ),
    .zeta                       ( zeta_keygen                    ),

    .w_MatrixA_Coeff            ( w_MatrixA_Coeff_keygen         ),
    .w_MatrixA_Coeff_valid      ( w_MatrixA_Coeff_valid_keygen   ),
    .w_MatrixA_Coeff_addr       ( w_MatrixA_Coeff_addr_keygen    ),
    .r_MatrixA_Coeff            ( r_MatrixA_Coeff_keygen         ),
    .r_MatrixA_Coeff_addr       ( r_MatrixA_Coeff_addr_keygen    ),
    .w_VectorS1_Coeff           ( w_VectorS1_Coeff_keygen        ),
    .w_VectorS1_Coeff_valid     ( w_VectorS1_Coeff_valid_keygen  ),
    .w_VectorS1_Coeff_addr      ( w_VectorS1_Coeff_addr_keygen   ),
    .r_VectorS1_Coeff           ( r_VectorS1_Coeff_keygen        ),
    .r_VectorS1_Coeff_addr      ( r_VectorS1_Coeff_addr_keygen   ),
    .w_VectorS2_Coeff           ( w_VectorS2_Coeff_keygen        ),
    .w_VectorS2_Coeff_valid     ( w_VectorS2_Coeff_valid_keygen  ),
    .w_VectorS2_Coeff_addr      ( w_VectorS2_Coeff_addr_keygen   ),
    .r_VectorS2_Coeff           ( r_VectorS2_Coeff_keygen        ),
    .r_VectorS2_Coeff_addr      ( r_VectorS2_Coeff_addr_keygen   ),
    .w_VectorT_Coeff            ( w_VectorT_Coeff_keygen         ),
    .w_VectorT_Coeff_valid      ( w_VectorT_Coeff_valid_keygen   ),
    .w_VectorT_Coeff_addr       ( w_VectorT_Coeff_addr_keygen    ),
    .r_VectorT_Coeff            ( r_VectorT_Coeff_keygen         ),
    .r_VectorT_Coeff_addr       ( r_VectorT_Coeff_addr_keygen    ),

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

    .dout1                      ( dout1_keygen                   ), 
    .dout_valid1                ( dout_valid1_keygen             ), 
    .dout_len1                  ( dout_len1_keygen               ), 
    .mdlen1                     ( mdlen1_keygen                  ), 
    .init1                      ( init1_keygen                   ), 
    .start1                     ( start1_keygen                  ), 
    .done1                      ( done1_keygen                   ), 
    .start_out1                 ( start_out1_keygen              ), 
    .out_len1                   ( out_len1_keygen                ), 
    .done_out1                  ( done_out1_keygen               ), 
    .st_64bit1                  ( st_64bit1_keygen               ), 
    .st_64bit_valid1            ( st_64bit_valid1_keygen         ),

    .dout2                      ( dout2_keygen                   ), 
    .dout_valid2                ( dout_valid2_keygen             ), 
    .dout_len2                  ( dout_len2_keygen               ), 
    .mdlen2                     ( mdlen2_keygen                  ), 
    .init2                      ( init2_keygen                   ), 
    .start2                     ( start2_keygen                  ), 
    .done2                      ( done2_keygen                   ), 
    .start_out2                 ( start_out2_keygen              ), 
    .out_len2                   ( out_len2_keygen                ), 
    .done_out2                  ( done_out2_keygen               ), 
    .st_64bit2                  ( st_64bit2_keygen               ), 
    .st_64bit_valid2            ( st_64bit_valid2_keygen         )
);

sign_internal #(
    .K              ( K ),
    .L              ( L ),
    .T1_BIT_LEN     ( T1_BIT_LEN ),
    .S1_S2_BIT_LEN  ( S1_S2_BIT_LEN ),
    .T0_BIT_LEN     ( T0_BIT_LEN ),
    .Z_BIT_LEN      ( Z_BIT_LEN ),
    .H_BIT_LEN      ( H_BIT_LEN ))
u_sign_internal(
    .clk                        ( clk                     ),
    .rstn                       ( rstn                    ),
    
    .start                      ( start_sign              ),
    .sign_ready                 ( sign_ready              ),
    .done                       ( done_sign               ),
    .mu                         ( mu                      ),
    .rnd                        ( rnd                     ),
    .reject_init                ( reject_init             ),

    .w_MatrixA_Coeff            ( w_MatrixA_Coeff_sign         ),
    .w_MatrixA_Coeff_valid      ( w_MatrixA_Coeff_valid_sign   ),
    .w_MatrixA_Coeff_addr       ( w_MatrixA_Coeff_addr_sign    ),
    .r_MatrixA_Coeff            ( r_MatrixA_Coeff_sign         ),
    .r_MatrixA_Coeff_addr       ( r_MatrixA_Coeff_addr_sign    ),
    
    .w_VectorS1_Coeff           ( w_VectorS1_Coeff_sign        ),
    .w_VectorS1_Coeff_valid     ( w_VectorS1_Coeff_valid_sign  ),
    .w_VectorS1_Coeff_addr      ( w_VectorS1_Coeff_addr_sign   ),
    .r_VectorS1_Coeff           ( r_VectorS1_Coeff_sign        ),
    .r_VectorS1_Coeff_addr      ( r_VectorS1_Coeff_addr_sign   ),
    
    .w_VectorS2_Coeff           ( w_VectorS2_Coeff_sign        ),
    .w_VectorS2_Coeff_valid     ( w_VectorS2_Coeff_valid_sign  ),
    .w_VectorS2_Coeff_addr      ( w_VectorS2_Coeff_addr_sign   ),
    .r_VectorS2_Coeff           ( r_VectorS2_Coeff_sign        ),
    .r_VectorS2_Coeff_addr      ( r_VectorS2_Coeff_addr_sign   ),
    
    .w_VectorY_Coeff            (w_VectorY_Coeff_sign          ),
    .w_VectorY_Coeff_valid      (w_VectorY_Coeff_valid_sign    ),
    .w_VectorY_Coeff_addr       (w_VectorY_Coeff_addr_sign     ),
    .r_VectorY_Coeff            (r_VectorY_Coeff_sign          ),
    .r_VectorY_Coeff_addr       (r_VectorY_Coeff_addr_sign     ),

    .w_VectorT_Coeff            ( w_VectorT_Coeff_sign         ),
    .w_VectorT_Coeff_valid      ( w_VectorT_Coeff_valid_sign   ),
    .w_VectorT_Coeff_addr       ( w_VectorT_Coeff_addr_sign    ),
    .r_VectorT_Coeff            ( r_VectorT_Coeff_sign         ),
    .r_VectorT_Coeff_addr       ( r_VectorT_Coeff_addr_sign    ),
    
    .w_VectorM_Coeff            (w_VectorM_Coeff_sign          ),
    .w_VectorM_Coeff_valid      (w_VectorM_Coeff_valid_sign    ),
    .w_VectorM_Coeff_addr       (w_VectorM_Coeff_addr_sign     ),
    .r_VectorM_Coeff            (r_VectorM_Coeff_sign          ),
    .r_VectorM_Coeff_addr       (r_VectorM_Coeff_addr_sign     ),

    .r_EncodeSK_Coeff           ( r_EncodeSK_Coeff_sign        ),
    .r_EncodeSK_Coeff_addr      ( r_EncodeSK_Coeff_addr_sign   ),

    .w_EncodeSig_Coeff          ( w_EncodeSig_Coeff_sign       ),
    .w_EncodeSig_Coeff_valid    ( w_EncodeSig_Coeff_valid_sign ),
    .w_EncodeSig_Coeff_addr     ( w_EncodeSig_Coeff_addr_sign  ),

    .rho_ExpandA                ( rho_ExpandA_sign             ),
    .start_expand_ExpandA       ( start_expand_ExpandA_sign    ),
    .coeff_ExpandA              ( coeff_ExpandA_sign           ),
    .coeff_valid_ExpandA        ( coeff_valid_ExpandA_sign     ),
    .expand_done_ExpandA        ( expand_done_ExpandA_sign     ),
    .dout_ExpandA               ( dout_ExpandA_sign            ),
    .dout_valid_ExpandA         ( dout_valid_ExpandA_sign      ),
    .dout_len_ExpandA           ( dout_len_ExpandA_sign        ),
    .mdlen_ExpandA              ( mdlen_ExpandA_sign           ),
    .init_ExpandA               ( init_ExpandA_sign            ),
    .start_ExpandA              ( start_ExpandA_sign           ),
    .done_ExpandA               ( done_ExpandA_sign            ),
    .start_out_ExpandA          ( start_out_ExpandA_sign       ),
    .out_len_ExpandA            ( out_len_ExpandA_sign         ),
    .done_out_ExpandA           ( done_out_ExpandA_sign        ),
    .st_64bit_ExpandA           ( st_64bit_ExpandA_sign        ),
    .st_64bit_valid_ExpandA     ( st_64bit_valid_ExpandA_sign  ),
    
    .ori_coeff                  ( ori_coeff_sign               ),
    .ori_coeff_valid            ( ori_coeff_valid_sign         ),
    .request                    ( request_sign                 ),
    .ext_operand                ( ext_operand_sign             ),
    .ext_operand_request        ( ext_operand_request_sign     ),
    .mode_config                ( mode_config_sign             ),
    .ready                      ( ready_sign                   ),
    .con_coeff                  ( con_coeff_sign               ),
    .con_coeff_valid            ( con_coeff_valid_sign         ),
    
    .mac_valid_in               ( mac_valid_in_sign            ),
    .mac_data_in1               ( mac_data_in1_sign            ),
    .mac_data_in2               ( mac_data_in2_sign            ),
    .mac_data_in3               ( mac_data_in3_sign            ),
    .mac_valid_out              ( mac_valid_out_sign           ),
    .mac_data_out               ( mac_data_out_sign            ),
    
    .dout1                      ( dout1_sign                   ),
    .dout_valid1                ( dout_valid1_sign             ),
    .dout_len1                  ( dout_len1_sign               ),
    .mdlen1                     ( mdlen1_sign                  ),
    .init1                      ( init1_sign                   ),
    .start1                     ( start1_sign                  ),
    .done1                      ( done1_sign                   ),
    .start_out1                 ( start_out1_sign              ),
    .out_len1                   ( out_len1_sign                ),
    .done_out1                  ( done_out1_sign               ),
    .st_64bit1                  ( st_64bit1_sign               ),
    .st_64bit_valid1            ( st_64bit_valid1_sign         ),
    
    .dout2                      ( dout2_sign                   ),
    .dout_valid2                ( dout_valid2_sign             ),
    .dout_len2                  ( dout_len2_sign               ),
    .mdlen2                     ( mdlen2_sign                  ),
    .init2                      ( init2_sign                   ),
    .start2                     ( start2_sign                  ),
    .done2                      ( done2_sign                   ),
    .start_out2                 ( start_out2_sign              ),
    .out_len2                   ( out_len2_sign                ),
    .done_out2                  ( done_out2_sign               ),
    .st_64bit2                  ( st_64bit2_sign               ),
    .st_64bit_valid2            ( st_64bit_valid2_sign         ),

    .CoeffModq_ram_rd_en        ( CoeffModq_ram_rd_en_sign     ),
    .CoeffModq_ori_coeff        ( CoeffModq_ori_coeff_sign     ),
    .CoeffModq_ori_coeff_valid  ( CoeffModq_ori_coeff_valid_sign ),
    .CoeffModq_coeff_type       ( CoeffModq_coeff_type_sign    ),
    .CoeffModq_poly_start_pulse ( CoeffModq_poly_start_pulse_sign ),
    .CoeffModq_modq_coeff       ( CoeffModq_modq_coeff_sign    ),
    .CoeffModq_modq_coeff_valid ( CoeffModq_modq_coeff_valid_sign )
);

verify_internal u_verify_internal(
	.clk                        	( clk                                ),
	.rstn                       	( rstn                               ),
	.start                      	( start_verify                       ),
	.verify_ready               	( verify_ready                       ),
	.done                       	( done_verify                        ),
	.mu                         	( mu_verify                          ),
	
    .w_MatrixA_Coeff            	( w_MatrixA_Coeff_verify             ),
	.w_MatrixA_Coeff_valid      	( w_MatrixA_Coeff_valid_verify       ),
	.w_MatrixA_Coeff_addr       	( w_MatrixA_Coeff_addr_verify        ),
	.r_MatrixA_Coeff            	( r_MatrixA_Coeff_verify             ),
	.r_MatrixA_Coeff_addr       	( r_MatrixA_Coeff_addr_verify        ),
	
    .w_VectorT_Coeff            	( w_VectorT_Coeff_verify             ),
	.w_VectorT_Coeff_valid      	( w_VectorT_Coeff_valid_verify       ),
	.w_VectorT_Coeff_addr       	( w_VectorT_Coeff_addr_verify        ),
	.r_VectorT_Coeff            	( r_VectorT_Coeff_verify             ),
	.r_VectorT_Coeff_addr       	( r_VectorT_Coeff_addr_verify        ),

	.r_EncodePK_Coeff           	( r_EncodePK_Coeff_verify            ),
	.r_EncodePK_Coeff_addr      	( r_EncodePK_Coeff_addr_verify       ),

	.r_EncodeSig_Coeff         	    ( r_EncodeSig_Coeff_verify           ),
	.r_EncodeSig_Coeff_addr    	    ( r_EncodeSig_Coeff_addr_verify      ),

	.CoeffModq_ram_rd_en        	( CoeffModq_ram_rd_en_verify         ),
	.CoeffModq_ori_coeff        	( CoeffModq_ori_coeff_verify         ),
	.CoeffModq_ori_coeff_valid  	( CoeffModq_ori_coeff_valid_verify   ),
	.CoeffModq_coeff_type       	( CoeffModq_coeff_type_verify        ),
	.CoeffModq_poly_start_pulse 	( CoeffModq_poly_start_pulse_verify  ),
	.CoeffModq_modq_coeff       	( CoeffModq_modq_coeff_verify        ),
	.CoeffModq_modq_coeff_valid 	( CoeffModq_modq_coeff_valid_verify  ),

    .rho_ExpandA                    (rho_ExpandA_verify                 ),
    .start_expand_ExpandA           (start_expand_ExpandA_verify        ),
    .coeff_ExpandA                  (coeff_ExpandA_verify               ),
    .coeff_valid_ExpandA            (coeff_valid_ExpandA_verify         ),
    .expand_done_ExpandA            (expand_done_ExpandA_verify         ),
    .dout_ExpandA                   (dout_ExpandA_verify                ),
    .dout_valid_ExpandA             (dout_valid_ExpandA_verify          ),
    .dout_len_ExpandA               (dout_len_ExpandA_verify            ),
    .mdlen_ExpandA                  (mdlen_ExpandA_verify               ),
    .init_ExpandA                   (init_ExpandA_verify                ),
    .start_ExpandA                  (start_ExpandA_verify               ),
    .done_ExpandA                   (done_ExpandA_verify                ),
    .start_out_ExpandA              (start_out_ExpandA_verify           ),
    .out_len_ExpandA                (out_len_ExpandA_verify             ),
    .done_out_ExpandA               (done_out_ExpandA_verify            ),
    .st_64bit_ExpandA               (st_64bit_ExpandA_verify            ),
    .st_64bit_valid_ExpandA         (st_64bit_valid_ExpandA_verify      ),

    // --- SHA3-1 控制接口 ---
    .dout1                          (dout1_verify                              ), 
    .dout_valid1                    (dout_valid1_verify                        ), 
    .dout_len1                      (dout_len1_verify                          ), 
    .mdlen1                         (mdlen1_verify                             ), 
    .init1                          (init1_verify                              ), 
    .start1                         (start1_verify                             ), 
    .done1                          (done1_verify                              ), 
    .start_out1                     (start_out1_verify                         ), 
    .out_len1                       (out_len1_verify                           ), 
    .done_out1                      (done_out1_verify                          ), 
    .st_64bit1                      (st_64bit1_verify                          ), 
    .st_64bit_valid1                (st_64bit_valid1_verify                    ),

    // --- SHA3-2 控制接口 ---
    .dout2                          (dout2_verify                              ), 
    .dout_valid2                    (dout_valid2_verify                        ), 
    .dout_len2                      (dout_len2_verify                          ), 
    .mdlen2                         (mdlen2_verify                             ), 
    .init2                          (init2_verify                              ), 
    .start2                         (start2_verify                             ), 
    .done2                          (done2_verify                              ), 
    .start_out2                     (start_out2_verify                         ), 
    .out_len2                       (out_len2_verify                           ), 
    .done_out2                      (done_out2_verify                          ), 
    .st_64bit2                      (st_64bit2_verify                          ), 
    .st_64bit_valid2                (st_64bit_valid2_verify                    )
);


GlobalBRAMArbitration #(
    .K  ( K  ),
    .L  ( L  ))
u_GlobalBRAMArbitration(
    .clk                            (clk                            ),
    .rstn                           (rstn                           ),
    .mode_config                    (mode_config                    ),
    
    // --- KeyGen BRAM Ports ---
    .w_MatrixA_Coeff_keygen         (w_MatrixA_Coeff_keygen         ),
    .w_MatrixA_Coeff_valid_keygen   (w_MatrixA_Coeff_valid_keygen   ),
    .w_MatrixA_Coeff_addr_keygen    (w_MatrixA_Coeff_addr_keygen    ),
    .r_MatrixA_Coeff_keygen         (r_MatrixA_Coeff_keygen         ),
    .r_MatrixA_Coeff_addr_keygen    (r_MatrixA_Coeff_addr_keygen    ),
    
    .w_VectorS1_Coeff_keygen        (w_VectorS1_Coeff_keygen        ),
    .w_VectorS1_Coeff_valid_keygen  (w_VectorS1_Coeff_valid_keygen  ),
    .w_VectorS1_Coeff_addr_keygen   (w_VectorS1_Coeff_addr_keygen   ),
    .r_VectorS1_Coeff_keygen        (r_VectorS1_Coeff_keygen        ),
    .r_VectorS1_Coeff_addr_keygen   (r_VectorS1_Coeff_addr_keygen   ),
    
    .w_VectorS2_Coeff_keygen        (w_VectorS2_Coeff_keygen        ),
    .w_VectorS2_Coeff_valid_keygen  (w_VectorS2_Coeff_valid_keygen  ),
    .w_VectorS2_Coeff_addr_keygen   (w_VectorS2_Coeff_addr_keygen   ),
    .r_VectorS2_Coeff_keygen        (r_VectorS2_Coeff_keygen        ),
    .r_VectorS2_Coeff_addr_keygen   (r_VectorS2_Coeff_addr_keygen   ),
    
    .w_VectorT_Coeff_keygen         (w_VectorT_Coeff_keygen         ),
    .w_VectorT_Coeff_valid_keygen   (w_VectorT_Coeff_valid_keygen   ),
    .w_VectorT_Coeff_addr_keygen    (w_VectorT_Coeff_addr_keygen    ),
    .r_VectorT_Coeff_keygen         (r_VectorT_Coeff_keygen         ),
    .r_VectorT_Coeff_addr_keygen    (r_VectorT_Coeff_addr_keygen    ),

    .w_EncodePK_Coeff_keygen        (w_EncodePK_Coeff_keygen        ),       
    .w_EncodePK_Coeff_valid_keygen  (w_EncodePK_Coeff_valid_keygen  ),
    .w_EncodePK_Coeff_addr_keygen   (w_EncodePK_Coeff_addr_keygen   ),
    .r_EncodePK_Coeff_keygen        (r_EncodePK_Coeff_keygen        ),           
    .r_EncodePK_Coeff_addr_keygen   (r_EncodePK_Coeff_addr_keygen   ),

    .w_EncodeSK_Coeff_keygen        (w_EncodeSK_Coeff_keygen        ),       
    .w_EncodeSK_Coeff_valid_keygen  (w_EncodeSK_Coeff_valid_keygen  ),
    .w_EncodeSK_Coeff_addr_keygen   (w_EncodeSK_Coeff_addr_keygen   ),
    .r_EncodeSK_Coeff_keygen        (r_EncodeSK_Coeff_keygen        ),           
    .r_EncodeSK_Coeff_addr_keygen   (r_EncodeSK_Coeff_addr_keygen   ),

    // --- Sign BRAM Ports  ---
    .w_MatrixA_Coeff_sign           (w_MatrixA_Coeff_sign           ),
    .w_MatrixA_Coeff_valid_sign     (w_MatrixA_Coeff_valid_sign     ),
    .w_MatrixA_Coeff_addr_sign      (w_MatrixA_Coeff_addr_sign      ),
    .r_MatrixA_Coeff_sign           (r_MatrixA_Coeff_sign           ),
    .r_MatrixA_Coeff_addr_sign      (r_MatrixA_Coeff_addr_sign      ),
    
    .w_VectorS1_Coeff_sign          (w_VectorS1_Coeff_sign          ),
    .w_VectorS1_Coeff_valid_sign    (w_VectorS1_Coeff_valid_sign    ),
    .w_VectorS1_Coeff_addr_sign     (w_VectorS1_Coeff_addr_sign     ),
    .r_VectorS1_Coeff_sign          (r_VectorS1_Coeff_sign          ),
    .r_VectorS1_Coeff_addr_sign     (r_VectorS1_Coeff_addr_sign     ),
    
    .w_VectorS2_Coeff_sign          (w_VectorS2_Coeff_sign          ),
    .w_VectorS2_Coeff_valid_sign    (w_VectorS2_Coeff_valid_sign    ),
    .w_VectorS2_Coeff_addr_sign     (w_VectorS2_Coeff_addr_sign     ),
    .r_VectorS2_Coeff_sign          (r_VectorS2_Coeff_sign          ),
    .r_VectorS2_Coeff_addr_sign     (r_VectorS2_Coeff_addr_sign     ),
    
    .w_VectorY_Coeff_sign           (w_VectorY_Coeff_sign           ),
    .w_VectorY_Coeff_valid_sign     (w_VectorY_Coeff_valid_sign     ),
    .w_VectorY_Coeff_addr_sign      (w_VectorY_Coeff_addr_sign      ),
    .r_VectorY_Coeff_sign           (r_VectorY_Coeff_sign           ),
    .r_VectorY_Coeff_addr_sign      (r_VectorY_Coeff_addr_sign      ),

    .w_VectorT_Coeff_sign           (w_VectorT_Coeff_sign           ),
    .w_VectorT_Coeff_valid_sign     (w_VectorT_Coeff_valid_sign     ),
    .w_VectorT_Coeff_addr_sign      (w_VectorT_Coeff_addr_sign      ),
    .r_VectorT_Coeff_sign           (r_VectorT_Coeff_sign           ),
    .r_VectorT_Coeff_addr_sign      (r_VectorT_Coeff_addr_sign      ),

    .w_VectorM_Coeff_sign           (w_VectorM_Coeff_sign           ),
    .w_VectorM_Coeff_valid_sign     (w_VectorM_Coeff_valid_sign     ),
    .w_VectorM_Coeff_addr_sign      (w_VectorM_Coeff_addr_sign      ),
    .r_VectorM_Coeff_sign           (r_VectorM_Coeff_sign           ),
    .r_VectorM_Coeff_addr_sign      (r_VectorM_Coeff_addr_sign      ),

    .r_EncodeSK_Coeff_sign          (r_EncodeSK_Coeff_sign          ),           
    .r_EncodeSK_Coeff_addr_sign     (r_EncodeSK_Coeff_addr_sign     ),

    .w_EncodeSig_Coeff_sign          (w_EncodeSig_Coeff_sign          ),
    .w_EncodeSig_Coeff_valid_sign    (w_EncodeSig_Coeff_valid_sign    ),
    .w_EncodeSig_Coeff_addr_sign     (w_EncodeSig_Coeff_addr_sign     ),

    // --- Verify BRAM Ports  ---
    .w_MatrixA_Coeff_verify       	( w_MatrixA_Coeff_verify             ),
	.w_MatrixA_Coeff_valid_verify  	( w_MatrixA_Coeff_valid_verify       ),
	.w_MatrixA_Coeff_addr_verify   	( w_MatrixA_Coeff_addr_verify        ),
	.r_MatrixA_Coeff_verify        	( r_MatrixA_Coeff_verify             ),
	.r_MatrixA_Coeff_addr_verify   	( r_MatrixA_Coeff_addr_verify        ),

	.w_VectorT_Coeff_verify        	( w_VectorT_Coeff_verify             ),
	.w_VectorT_Coeff_valid_verify  	( w_VectorT_Coeff_valid_verify       ),
	.w_VectorT_Coeff_addr_verify   	( w_VectorT_Coeff_addr_verify        ),
	.r_VectorT_Coeff_verify        	( r_VectorT_Coeff_verify             ),
	.r_VectorT_Coeff_addr_verify   	( r_VectorT_Coeff_addr_verify        ),

	.r_EncodePK_Coeff_verify       	( r_EncodePK_Coeff_verify            ),
	.r_EncodePK_Coeff_addr_verify  	( r_EncodePK_Coeff_addr_verify       ),

	.r_EncodeSig_Coeff_verify     	( r_EncodeSig_Coeff_verify          ),
	.r_EncodeSig_Coeff_addr_verify  ( r_EncodeSig_Coeff_addr_verify     )
);

logic                       init_rstn;

always_comb begin
    case (mode_config)
        'd0: init_rstn = 1'b1;
        'd1: init_rstn = ~reject_init;
    endcase
end

GlobalComputeArbitration #(
    .K  ( K  ),
    .L  ( L  )
) u_GlobalComputeArbitration (
    .clk                            ( clk                            ),
    .rstn                           ( rstn & init_rstn               ),
    .mode_config                    ( mode_config                    ), 
    
    // --- KeyGen Compute Ports ---
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
    .st_64bit_valid2_keygen         ( st_64bit_valid2_keygen         ),

    // --- Sign Compute Ports ---
    .rho_ExpandA_sign               (rho_ExpandA_sign                ),            
    .start_expand_ExpandA_sign      (start_expand_ExpandA_sign       ),   
    .coeff_ExpandA_sign             (coeff_ExpandA_sign              ),          
    .coeff_valid_ExpandA_sign       (coeff_valid_ExpandA_sign        ),    
    .expand_done_ExpandA_sign       (expand_done_ExpandA_sign        ),    

    .dout_ExpandA_sign              (dout_ExpandA_sign               ),          
    .dout_valid_ExpandA_sign        (dout_valid_ExpandA_sign         ),    
    .dout_len_ExpandA_sign          (dout_len_ExpandA_sign           ),      
    .mdlen_ExpandA_sign             (mdlen_ExpandA_sign              ),         
    .init_ExpandA_sign              (init_ExpandA_sign               ),          
    .start_ExpandA_sign             (start_ExpandA_sign              ),         
    .done_ExpandA_sign              (done_ExpandA_sign               ),          
    .start_out_ExpandA_sign         (start_out_ExpandA_sign          ),     
    .out_len_ExpandA_sign           (out_len_ExpandA_sign            ),       
    .done_out_ExpandA_sign          (done_out_ExpandA_sign           ),      
    .st_64bit_ExpandA_sign          (st_64bit_ExpandA_sign           ),      
    .st_64bit_valid_ExpandA_sign    (st_64bit_valid_ExpandA_sign     ),
    
    .ori_coeff_sign                 ( ori_coeff_sign                 ),             
    .ori_coeff_valid_sign           ( ori_coeff_valid_sign           ),     
    .request_sign                   ( request_sign                   ),                
    .ext_operand_sign               ( ext_operand_sign               ),            
    .ext_operand_request_sign       ( ext_operand_request_sign       ),    
    .mode_config_sign               ( mode_config_sign               ),            
    .ready_sign                     ( ready_sign                     ),                  
    .con_coeff_sign                 ( con_coeff_sign                 ),             
    .con_coeff_valid_sign           ( con_coeff_valid_sign           ), 

    .mac_valid_in_sign              ( mac_valid_in_sign              ),
    .mac_data_in1_sign              ( mac_data_in1_sign              ),
    .mac_data_in2_sign              ( mac_data_in2_sign              ),
    .mac_data_in3_sign              ( mac_data_in3_sign              ),
    .mac_valid_out_sign             ( mac_valid_out_sign             ),
    .mac_data_out_sign              ( mac_data_out_sign              ),

    .dout1_sign                     ( dout1_sign                     ), 
    .dout_valid1_sign               ( dout_valid1_sign               ), 
    .dout_len1_sign                 ( dout_len1_sign                 ), 
    .mdlen1_sign                    ( mdlen1_sign                    ), 
    .init1_sign                     ( init1_sign                     ), 
    .start1_sign                    ( start1_sign                    ), 
    .done1_sign                     ( done1_sign                     ), 
    .start_out1_sign                ( start_out1_sign                ), 
    .out_len1_sign                  ( out_len1_sign                  ), 
    .done_out1_sign                 ( done_out1_sign                 ), 
    .st_64bit1_sign                 ( st_64bit1_sign                 ), 
    .st_64bit_valid1_sign           ( st_64bit_valid1_sign           ),

    .dout2_sign                     ( dout2_sign                     ), 
    .dout_valid2_sign               ( dout_valid2_sign               ), 
    .dout_len2_sign                 ( dout_len2_sign                 ), 
    .mdlen2_sign                    ( mdlen2_sign                    ), 
    .init2_sign                     ( init2_sign                     ), 
    .start2_sign                    ( start2_sign                    ), 
    .done2_sign                     ( done2_sign                     ), 
    .start_out2_sign                ( start_out2_sign                ), 
    .out_len2_sign                  ( out_len2_sign                  ), 
    .done_out2_sign                 ( done_out2_sign                 ), 
    .st_64bit2_sign                 ( st_64bit2_sign                 ), 
    .st_64bit_valid2_sign           ( st_64bit_valid2_sign           ),

    .CoeffModq_ram_rd_en_sign       ( CoeffModq_ram_rd_en_sign       ),
    .CoeffModq_ori_coeff_sign       ( CoeffModq_ori_coeff_sign       ),
    .CoeffModq_ori_coeff_valid_sign ( CoeffModq_ori_coeff_valid_sign ),
    .CoeffModq_coeff_type_sign      ( CoeffModq_coeff_type_sign      ),
    .CoeffModq_poly_start_pulse_sign( CoeffModq_poly_start_pulse_sign),
    .CoeffModq_modq_coeff_sign      ( CoeffModq_modq_coeff_sign      ),
    .CoeffModq_modq_coeff_valid_sign( CoeffModq_modq_coeff_valid_sign),

    .rho_ExpandA_verify             (rho_ExpandA_verify                 ),
    .start_expand_ExpandA_verify    (start_expand_ExpandA_verify        ),
    .coeff_ExpandA_verify           (coeff_ExpandA_verify               ),
    .coeff_valid_ExpandA_verify     (coeff_valid_ExpandA_verify         ),
    .expand_done_ExpandA_verify     (expand_done_ExpandA_verify         ),
    .dout_ExpandA_verify            (dout_ExpandA_verify                ),
    .dout_valid_ExpandA_verify      (dout_valid_ExpandA_verify          ),
    .dout_len_ExpandA_verify        (dout_len_ExpandA_verify            ),
    .mdlen_ExpandA_verify           (mdlen_ExpandA_verify               ),
    .init_ExpandA_verify            (init_ExpandA_verify                ),
    .start_ExpandA_verify           (start_ExpandA_verify               ),
    .done_ExpandA_verify            (done_ExpandA_verify                ),
    .start_out_ExpandA_verify       (start_out_ExpandA_verify           ),
    .out_len_ExpandA_verify         (out_len_ExpandA_verify             ),
    .done_out_ExpandA_verify        (done_out_ExpandA_verify            ),
    .st_64bit_ExpandA_verify        (st_64bit_ExpandA_verify            ),
    .st_64bit_valid_ExpandA_verify  (st_64bit_valid_ExpandA_verify      ),

    .dout1_verify                   (dout1_verify                              ), 
    .dout_valid1_verify             (dout_valid1_verify                        ), 
    .dout_len1_verify               (dout_len1_verify                          ), 
    .mdlen1_verify                  (mdlen1_verify                             ), 
    .init1_verify                   (init1_verify                              ), 
    .start1_verify                  (start1_verify                             ), 
    .done1_verify                   (done1_verify                              ), 
    .start_out1_verify              (start_out1_verify                         ), 
    .out_len1_verify                (out_len1_verify                           ), 
    .done_out1_verify               (done_out1_verify                          ), 
    .st_64bit1_verify               (st_64bit1_verify                          ), 
    .st_64bit_valid1_verify         (st_64bit_valid1_verify                    ),

    .dout2_verify                   (dout2_verify                              ), 
    .dout_valid2_verify             (dout_valid2_verify                        ), 
    .dout_len2_verify               (dout_len2_verify                          ), 
    .mdlen2_verify                  (mdlen2_verify                             ), 
    .init2_verify                   (init2_verify                              ), 
    .start2_verify                  (start2_verify                             ), 
    .done2_verify                   (done2_verify                              ), 
    .start_out2_verify              (start_out2_verify                         ), 
    .out_len2_verify                (out_len2_verify                           ), 
    .done_out2_verify               (done_out2_verify                          ), 
    .st_64bit2_verify               (st_64bit2_verify                          ), 
    .st_64bit_valid2_verify         (st_64bit_valid2_verify                    )
);

endmodule