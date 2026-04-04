`include "../src/param_conf.v"
module GlobalComputeArbitration
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
    input       logic           [1 : 0]     mode_config,
    
    // ==========================================
    // KeyGen 控制器接口
    // ==========================================    

    // --- ExpandA 信号 ---
    input       logic           [255 : 0]   rho_ExpandA_keygen,            
    input       logic                       start_expand_ExpandA_keygen,   
    output      logic           [91 : 0]    coeff_ExpandA_keygen,          
    output      logic                       coeff_valid_ExpandA_keygen,    
    output      logic                       expand_done_ExpandA_keygen,    

    output      logic           [7 : 0]     dout_ExpandA_keygen,          
    output      logic                       dout_valid_ExpandA_keygen,    
    output      logic           [31 : 0]    dout_len_ExpandA_keygen,      
    output      logic           [7 : 0]     mdlen_ExpandA_keygen,         
    output      logic                       init_ExpandA_keygen,          
    output      logic                       start_ExpandA_keygen,         
    input       logic                       done_ExpandA_keygen,          
    output      logic                       start_out_ExpandA_keygen,     
    output      logic           [31 : 0]    out_len_ExpandA_keygen,       
    input       logic                       done_out_ExpandA_keygen,      
    input       logic           [63 : 0]    st_64bit_ExpandA_keygen,      
    input       logic                       st_64bit_valid_ExpandA_keygen,

    // --- Poly_PAU 信号 ---
    input       logic           [91 : 0]    ori_coeff_keygen,               
    input       logic                       ori_coeff_valid_keygen,     
    input       logic                       request_keygen,                
    input       logic           [91 : 0]    ext_operand_keygen,            
    output      logic                       ext_operand_request_keygen,    
    input       logic           [4 : 0]     mode_config_keygen,            
    output      logic                       ready_keygen,                  
    output      logic           [91 : 0]    con_coeff_keygen,               
    output      logic                       con_coeff_valid_keygen, 

    // --- MAC 阵列信号 ---
    input       logic                       mac_valid_in_keygen,
    input       logic           [91 : 0]    mac_data_in1_keygen [0 : K - 1],
    input       logic           [91 : 0]    mac_data_in2_keygen,
    input       logic           [91 : 0]    mac_data_in3_keygen [0 : K - 1],
    output      logic                       mac_valid_out_keygen,
    output      logic           [91 : 0]    mac_data_out_keygen [0 : K - 1],

    // --- Encoder 接口 ---
    input       logic                                       system_done_0_keygen,
    input       logic           [4 * T1_BIT_LEN - 1 : 0]    t1_0_keygen,         
    input       logic                                       t1_valid_0_keygen,

    input       logic           [4 * 23 - 1 : 0]            s1_0_keygen,         
    input       logic                                       s1_valid_0_keygen,
    input       logic           [4 * 23 - 1 : 0]            s2_0_keygen,        
    input       logic                                       s2_valid_0_keygen,
    input       logic           [4 * T0_BIT_LEN - 1 : 0]    t0_0_keygen,         
    input       logic                                       t0_valid_0_keygen,

    input       logic           [4 * 23 - 1 : 0]            z_0_keygen,
    input       logic                                       z_valid_0_keygen,

    output      logic           [63 : 0]    encode_0_keygen,
    output      logic                       encoder_valid_0_keygen,
    
    input       logic                                       system_done_1_keygen,
    input       logic           [4 * T1_BIT_LEN - 1 : 0]    t1_1_keygen,         
    input       logic                                       t1_valid_1_keygen,

    input       logic           [4 * 23 - 1 : 0]            s1_1_keygen,         
    input       logic                                       s1_valid_1_keygen,
    input       logic           [4 * 23 - 1 : 0]            s2_1_keygen,        
    input       logic                                       s2_valid_1_keygen,
    input       logic           [4 * T0_BIT_LEN - 1 : 0]    t0_1_keygen,         
    input       logic                                       t0_valid_1_keygen,

    input       logic           [4 * 23 - 1 : 0]            z_1_keygen,
    input       logic                                       z_valid_1_keygen,

    output      logic           [63 : 0]    encode_1_keygen,
    output      logic                       encoder_valid_1_keygen,

    // --- SHA3-1 控制接口 ---
    input       logic           [7 : 0]     dout1_keygen, 
    input       logic                       dout_valid1_keygen, 
    input       logic           [31 : 0]    dout_len1_keygen, 
    input       logic           [7 : 0]     mdlen1_keygen, 
    input       logic                       init1_keygen, 
    input       logic                       start1_keygen, 
    output      logic                       done1_keygen, 
    input       logic                       start_out1_keygen, 
    input       logic           [31 : 0]    out_len1_keygen, 
    output      logic                       done_out1_keygen, 
    output      logic           [63 : 0]    st_64bit1_keygen, 
    output      logic                       st_64bit_valid1_keygen,

    // --- SHA3-2 控制接口 ---
    input       logic           [7 : 0]     dout2_keygen, 
    input       logic                       dout_valid2_keygen, 
    input       logic           [31 : 0]    dout_len2_keygen, 
    input       logic           [7 : 0]     mdlen2_keygen, 
    input       logic                       init2_keygen, 
    input       logic                       start2_keygen, 
    output      logic                       done2_keygen, 
    input       logic                       start_out2_keygen, 
    input       logic           [31 : 0]    out_len2_keygen, 
    output      logic                       done_out2_keygen, 
    output      logic           [63 : 0]    st_64bit2_keygen, 
    output      logic                       st_64bit_valid2_keygen,

    // ==========================================
    // Sign 控制器接口
    // ==========================================   

    // --- ExpandA 信号 ---
    input       logic           [255 : 0]   rho_ExpandA_sign,            
    input       logic                       start_expand_ExpandA_sign,   
    output      logic           [91 : 0]    coeff_ExpandA_sign,          
    output      logic                       coeff_valid_ExpandA_sign,    
    output      logic                       expand_done_ExpandA_sign,    

    output      logic           [7 : 0]     dout_ExpandA_sign,           
    output      logic                       dout_valid_ExpandA_sign,     
    output      logic           [31 : 0]    dout_len_ExpandA_sign,       
    output      logic           [7 : 0]     mdlen_ExpandA_sign,          
    output      logic                       init_ExpandA_sign,           
    output      logic                       start_ExpandA_sign,          
    input       logic                       done_ExpandA_sign,           
    output      logic                       start_out_ExpandA_sign,      
    output      logic           [31 : 0]    out_len_ExpandA_sign,        
    input       logic                       done_out_ExpandA_sign,       
    input       logic           [63 : 0]    st_64bit_ExpandA_sign,       
    input       logic                       st_64bit_valid_ExpandA_sign, 

    // --- ExpandC 数据接口 ---
    input       logic           [255 : 0]   seed_ExpandC_sign,           // 512位随机种子
    input       logic           [7 : 0]     tau_ExpandC_sign,            // 伪随机数初始值
    input       logic                       start_expand_ExpandC_sign,   // 开始扩展Y矩阵信号

    input       logic                       low_rd_en_ExpandC_sign,      // 低地址读取使能信号
    output      logic           [1 : 0]     coeff_low_ExpandC_sign,      // 低地址 2 bit 有效采样系数
    input       logic           [7 : 0]     coeff_low_add_ExpandC_sign,  // 低地址
    output      logic                       coeff_low_valid_ExpandC_sign,// 低地址 2 bit 有效采样系数信号

    input       logic                       high_rd_en_ExpandC_sign,     // 高地址读取使能信号
    output      logic           [1 : 0]     coeff_high_ExpandC_sign,     // 高地址 2 bit 有效采样系数
    input       logic           [7 : 0]     coeff_high_add_ExpandC_sign, // 高地址
    output      logic                       coeff_high_valid_ExpandC_sign,// 高地址 2 bit 有效采样系数信号

    output      logic                       expand_done_ExpandC_sign,    // 扩展完成信号

    // --- SHA3 控制接口 ---
    output      logic           [7 : 0]     dout_ExpandC_sign,           // SHA3 串行输入字节数据
    output      logic                       dout_valid_ExpandC_sign,     // SHA3 串行输入字节有效信号
    output      logic           [31 : 0]    dout_len_ExpandC_sign,       // SHA3 串行输入字节长度
    output      logic           [7 : 0]     mdlen_ExpandC_sign,          // SHA3 Hash长度
    output      logic                       init_ExpandC_sign,           // SHA3 初始化信号
    output      logic                       start_ExpandC_sign,          // SHA3 开始装载数据
    input       logic                       done_ExpandC_sign,           // SHA3 数据装载完成
    output      logic                       start_out_ExpandC_sign,      // SHA3 开始挤出数据
    output      logic           [31 : 0]    out_len_ExpandC_sign,        // SHA3 挤出数据长度
    input       logic                       done_out_ExpandC_sign,       // SHA3 挤出数据完成
    input       logic           [63 : 0]    st_64bit_ExpandC_sign,       // SHA3 挤出8字节数据
    input       logic                       st_64bit_valid_ExpandC_sign,  // SHA3 挤出8字节数据有效信号

    // --- Poly_PAU 输入输出接口 ---
    input       logic           [91 : 0]    ori_coeff_sign,                  
    input       logic                       ori_coeff_valid_sign,            
    input       logic                       request_sign,                    
    input       logic           [91 : 0]    ext_operand_sign,                
    output      logic                       ext_operand_request_sign,        
    input       logic           [4 : 0]     mode_config_sign,                

    output      logic                       ready_sign,                      
    output      logic           [91 : 0]    con_coeff_sign,                  
    output      logic                       con_coeff_valid_sign,            

    // --- MAC 阵列接口 ---
    input       logic                       mac_valid_in_sign,
    input       logic           [91 : 0]    mac_data_in1_sign [0 : K - 1],
    input       logic           [91 : 0]    mac_data_in2_sign,
    input       logic           [91 : 0]    mac_data_in3_sign [0 : K - 1],
    output      logic                       mac_valid_out_sign,
    output      logic           [91 : 0]    mac_data_out_sign [0 : K - 1],

    // --- SHA3-1 控制接口 ---
    input       logic           [7 : 0]     dout1_sign, 
    input       logic                       dout_valid1_sign, 
    input       logic           [31 : 0]    dout_len1_sign, 
    input       logic           [7 : 0]     mdlen1_sign, 
    input       logic                       init1_sign, 
    input       logic                       start1_sign, 
    output      logic                       done1_sign, 
    input       logic                       start_out1_sign, 
    input       logic           [31 : 0]    out_len1_sign, 
    output      logic                       done_out1_sign, 
    output      logic           [63 : 0]    st_64bit1_sign, 
    output      logic                       st_64bit_valid1_sign,

    // --- SHA3-2 控制接口 ---
    input       logic           [7 : 0]     dout2_sign, 
    input       logic                       dout_valid2_sign, 
    input       logic           [31 : 0]    dout_len2_sign, 
    input       logic           [7 : 0]     mdlen2_sign, 
    input       logic                       init2_sign, 
    input       logic                       start2_sign, 
    output      logic                       done2_sign, 
    input       logic                       start_out2_sign, 
    input       logic           [31 : 0]    out_len2_sign, 
    output      logic                       done_out2_sign, 
    output      logic           [63 : 0]    st_64bit2_sign, 
    output      logic                       st_64bit_valid2_sign,

    // --- CoeffModq ---
    output      logic                       CoeffModq_ram_rd_en_sign,       
    input       logic           [63 : 0]    CoeffModq_ori_coeff_sign,       
    input       logic                       CoeffModq_ori_coeff_valid_sign, 
    input       logic           [2 : 0]     CoeffModq_coeff_type_sign,     
    input       logic                       CoeffModq_poly_start_pulse_sign, 
    output      logic           [91 : 0]    CoeffModq_modq_coeff_sign,      
    output      logic                       CoeffModq_modq_coeff_valid_sign,

    // ==========================================
    // Verify 控制器接口
    // ==========================================  
    // --- ExpandA 信号 ---
    input       logic           [255 : 0]   rho_ExpandA_verify,            
    input       logic                       start_expand_ExpandA_verify,   
    output      logic           [91 : 0]    coeff_ExpandA_verify,          
    output      logic                       coeff_valid_ExpandA_verify,    
    output      logic                       expand_done_ExpandA_verify,    

    output      logic           [7 : 0]     dout_ExpandA_verify,           
    output      logic                       dout_valid_ExpandA_verify,     
    output      logic           [31 : 0]    dout_len_ExpandA_verify,       
    output      logic           [7 : 0]     mdlen_ExpandA_verify,          
    output      logic                       init_ExpandA_verify,           
    output      logic                       start_ExpandA_verify,          
    input       logic                       done_ExpandA_verify,           
    output      logic                       start_out_ExpandA_verify,      
    output      logic           [31 : 0]    out_len_ExpandA_verify,        
    input       logic                       done_out_ExpandA_verify,       
    input       logic           [63 : 0]    st_64bit_ExpandA_verify,       
    input       logic                       st_64bit_valid_ExpandA_verify,

    // --- ExpandC 信号 ---
    input       logic           [255 : 0]   seed_ExpandC_verify,           // 512位随机种子
    input       logic           [7 : 0]     tau_ExpandC_verify,            // 伪随机数初始值
    input       logic                       start_expand_ExpandC_verify,   // 开始扩展Y矩阵信号
    input       logic                       low_rd_en_ExpandC_verify,      // 低地址读取使能信号
    output      logic           [1 : 0]     coeff_low_ExpandC_verify,      // 低地址 2 bit 有效采样系数
    input       logic           [7 : 0]     coeff_low_add_ExpandC_verify,  // 低地址
    output      logic                       coeff_low_valid_ExpandC_verify,// 低地址 2 bit 有效采样系数信号
    input       logic                       high_rd_en_ExpandC_verify,     // 高地址读取使能信号
    output      logic           [1 : 0]     coeff_high_ExpandC_verify,     // 高地址 2 bit 有效采样系数
    input       logic           [7 : 0]     coeff_high_add_ExpandC_verify, // 高地址
    output      logic                       coeff_high_valid_ExpandC_verify,// 高地址 2 bit 有效采样系数信号
    output      logic                       expand_done_ExpandC_verify,    // 扩展完成信号

    output      logic           [7 : 0]     dout_ExpandC_verify,           // SHA3 串行输入字节数据
    output      logic                       dout_valid_ExpandC_verify,     // SHA3 串行输入字节有效信号
    output      logic           [31 : 0]    dout_len_ExpandC_verify,       // SHA3 串行输入字节长度
    output      logic           [7 : 0]     mdlen_ExpandC_verify,          // SHA3 Hash长度
    output      logic                       init_ExpandC_verify,           // SHA3 初始化信号
    output      logic                       start_ExpandC_verify,          // SHA3 开始装载数据
    input       logic                       done_ExpandC_verify,           // SHA3 数据装载完成
    output      logic                       start_out_ExpandC_verify,      // SHA3 开始挤出数据
    output      logic           [31 : 0]    out_len_ExpandC_verify,        // SHA3 挤出数据长度
    input       logic                       done_out_ExpandC_verify,       // SHA3 挤出数据完成
    input       logic           [63 : 0]    st_64bit_ExpandC_verify,       // SHA3 挤出8字节数据
    input       logic                       st_64bit_valid_ExpandC_verify,  // SHA3 挤出8字节数据有效信号

    // --- Poly_PAU 输入输出接口 ---
    input       logic           [91 : 0]    ori_coeff_verify,                  
    input       logic                       ori_coeff_valid_verify,            
    input       logic                       request_verify,                    
    input       logic           [91 : 0]    ext_operand_verify,                
    output      logic                       ext_operand_request_verify,        
    input       logic           [4 : 0]     mode_config_verify,                

    output      logic                       ready_verify,                      
    output      logic           [91 : 0]    con_coeff_verify,                  
    output      logic                       con_coeff_valid_verify,   

    // --- SHA3-1 控制接口 ---
    input       logic           [7 : 0]     dout1_verify, 
    input       logic                       dout_valid1_verify, 
    input       logic           [31 : 0]    dout_len1_verify, 
    input       logic           [7 : 0]     mdlen1_verify, 
    input       logic                       init1_verify, 
    input       logic                       start1_verify, 
    output      logic                       done1_verify, 
    input       logic                       start_out1_verify, 
    input       logic           [31 : 0]    out_len1_verify, 
    output      logic                       done_out1_verify, 
    output      logic           [63 : 0]    st_64bit1_verify, 
    output      logic                       st_64bit_valid1_verify,

    // --- SHA3-2 控制接口 ---
    input       logic           [7 : 0]     dout2_verify, 
    input       logic                       dout_valid2_verify, 
    input       logic           [31 : 0]    dout_len2_verify, 
    input       logic           [7 : 0]     mdlen2_verify, 
    input       logic                       init2_verify, 
    input       logic                       start2_verify, 
    output      logic                       done2_verify, 
    input       logic                       start_out2_verify, 
    input       logic           [31 : 0]    out_len2_verify, 
    output      logic                       done_out2_verify, 
    output      logic           [63 : 0]    st_64bit2_verify, 
    output      logic                       st_64bit_valid2_verify,

    // --- CoeffModq ---
    output      logic                       CoeffModq_ram_rd_en_verify,       
    input       logic           [63 : 0]    CoeffModq_ori_coeff_verify,       
    input       logic                       CoeffModq_ori_coeff_valid_verify, 
    input       logic           [2 : 0]     CoeffModq_coeff_type_verify,     
    input       logic                       CoeffModq_poly_start_pulse_verify, 
    output      logic           [91 : 0]    CoeffModq_modq_coeff_verify,      
    output      logic                       CoeffModq_modq_coeff_valid_verify
);

// ==========================================
// 1. 状态流回传：一对多 (广播机制)
// 物理上没有延时，直接把共享算力池吐出的结果广播给所有控制器
// ==========================================

// --- ExpandA 内部线声明 ---
logic           [255 : 0]   rho_ExpandA;            
logic                       start_expand_ExpandA;   
logic           [91 : 0]    coeff_ExpandA;          
logic                       coeff_valid_ExpandA;    
logic                       expand_done_ExpandA;    

logic           [7 : 0]     dout_ExpandA;           
logic                       dout_valid_ExpandA;     
logic           [31 : 0]    dout_len_ExpandA;       
logic           [7 : 0]     mdlen_ExpandA;          
logic                       init_ExpandA;           
logic                       start_ExpandA;          
logic                       done_ExpandA;           
logic                       start_out_ExpandA;      
logic           [31 : 0]    out_len_ExpandA;        
logic                       done_out_ExpandA;       
logic           [63 : 0]    st_64bit_ExpandA;       
logic                       st_64bit_valid_ExpandA; 

// --- ExpandC ---
logic           [255 : 0]   seed_ExpandC;           
logic           [7 : 0]     tau_ExpandC;            
logic                       start_expand_ExpandC;   
logic                       low_rd_en_ExpandC;      
logic           [1 : 0]     coeff_low_ExpandC;      
logic           [7 : 0]     coeff_low_add_ExpandC;  
logic                       coeff_low_valid_ExpandC;
logic                       high_rd_en_ExpandC;     
logic           [1 : 0]     coeff_high_ExpandC;     
logic           [7 : 0]     coeff_high_add_ExpandC; 
logic                       coeff_high_valid_ExpandC;
logic                       expand_done_ExpandC;   

logic           [7 : 0]     dout_ExpandC;           
logic                       dout_valid_ExpandC;     
logic           [31 : 0]    dout_len_ExpandC;       
logic           [7 : 0]     mdlen_ExpandC;          
logic                       init_ExpandC;           
logic                       start_ExpandC;          
logic                       done_ExpandC;           
logic                       start_out_ExpandC;      
logic           [31 : 0]    out_len_ExpandC;        
logic                       done_out_ExpandC;       
logic           [63 : 0]    st_64bit_ExpandC;       
logic                       st_64bit_valid_ExpandC;  

// --- Poly_PAU 内部线声明 ---
logic           [91 : 0]    pau_ori_coeff;
logic                       pau_ori_coeff_valid;
logic                       pau_request;
logic           [91 : 0]    pau_ext_operand;
logic           [4 : 0]     pau_mode_config;
logic                       pau_ext_operand_request;
logic                       pau_ready;
logic           [91 : 0]    pau_con_coeff;
logic                       pau_con_coeff_valid;

// --- MAC_Pool 内部线声明 ---
logic                       mac_valid_in;
logic           [91 : 0]    mac_data_in1 [0 : K - 1];
logic           [91 : 0]    mac_data_in2;
logic           [91 : 0]    mac_data_in3 [0 : K - 1];
logic                       mac_valid_out;
logic           [91 : 0]    mac_data_out [0 : K - 1];

// --- Encoder-0 内部线声明 ---
logic           [4 * T1_BIT_LEN - 1 : 0]        t1_0;         
logic                                           system_done_0;
logic                                           t1_valid_0;
logic           [4 * 23 - 1 : 0]                s1_0;         
logic                                           s1_valid_0;
logic           [4 * 23 - 1 : 0]                s2_0;         
logic                                           s2_valid_0;
logic           [4 * T0_BIT_LEN - 1 : 0]        t0_0;         
logic                                           t0_valid_0;
logic           [4 * 23 - 1 : 0]                z_0;
logic                                           z_valid_0;
logic           [63 : 0]                        encode_0;
logic                                           encoder_valid_0;

// --- Encoder-1 内部线声明 ---
logic           [4 * T1_BIT_LEN - 1 : 0]        t1_1;         
logic                                           system_done_1;
logic                                           t1_valid_1;
logic           [4 * 23 - 1 : 0]                s1_1;         
logic                                           s1_valid_1;
logic           [4 * 23 - 1 : 0]                s2_1;         
logic                                           s2_valid_1;
logic           [4 * T0_BIT_LEN - 1 : 0]        t0_1;         
logic                                           t0_valid_1;
logic           [4 * 23 - 1 : 0]                z_1;
logic                                           z_valid_1;
logic           [63 : 0]                        encode_1;
logic                                           encoder_valid_1;

// --- SHA3-1 内部线声明 ---
logic           [7 : 0]     dout1; 
logic                       dout_valid1;
logic           [31 : 0]    dout_len1; 
logic           [7 : 0]     mdlen1; 
logic                       init1; 
logic                       start1; 
logic                       done1; 
logic                       start_out1; 
logic           [31 : 0]    out_len1; 
logic                       done_out1; 
logic           [63 : 0]    st_64bit1; 
logic                       st_64bit_valid1;

// --- SHA3-2 内部线声明 ---
logic           [7 : 0]     dout2; 
logic                       dout_valid2; 
logic           [31 : 0]    dout_len2; 
logic           [7 : 0]     mdlen2; 
logic                       init2; 
logic                       start2; 
logic                       done2; 
logic                       start_out2; 
logic           [31 : 0]    out_len2; 
logic                       done_out2; 
logic           [63 : 0]    st_64bit2; 
logic                       st_64bit_valid2;

// --- CoeffModq 内部线声明 ---
logic                       CoeffModq_ram_rd_en;       
logic           [63 : 0]    CoeffModq_ori_coeff;       
logic                       CoeffModq_ori_coeff_valid; 
logic           [2 : 0]     CoeffModq_coeff_type;      
logic                       CoeffModq_poly_start_pulse; 
logic           [91 : 0]    CoeffModq_modq_coeff;      
logic                       CoeffModq_modq_coeff_valid;

// ==========================================
// 广播赋值: 回传给 KeyGen
// ==========================================
assign coeff_ExpandA_keygen          = coeff_ExpandA;
assign coeff_valid_ExpandA_keygen    = coeff_valid_ExpandA;
assign expand_done_ExpandA_keygen    = expand_done_ExpandA;
assign dout_ExpandA_keygen           = dout_ExpandA;
assign dout_valid_ExpandA_keygen     = dout_valid_ExpandA;
assign dout_len_ExpandA_keygen       = dout_len_ExpandA;
assign mdlen_ExpandA_keygen          = mdlen_ExpandA;
assign init_ExpandA_keygen           = init_ExpandA;
assign start_ExpandA_keygen          = start_ExpandA;
assign start_out_ExpandA_keygen      = start_out_ExpandA;
assign out_len_ExpandA_keygen        = out_len_ExpandA;

assign ext_operand_request_keygen    = pau_ext_operand_request;
assign ready_keygen                  = pau_ready;
assign con_coeff_keygen              = pau_con_coeff;
assign con_coeff_valid_keygen        = pau_con_coeff_valid;

assign mac_valid_out_keygen          = mac_valid_out;
assign mac_data_out_keygen           = mac_data_out;

assign encode_0_keygen               = encode_0;
assign encoder_valid_0_keygen        = encoder_valid_0;
assign encode_1_keygen               = encode_1;
assign encoder_valid_1_keygen        = encoder_valid_1;

assign done1_keygen                  = done1;
assign done_out1_keygen              = done_out1;
assign st_64bit1_keygen              = st_64bit1;
assign st_64bit_valid1_keygen        = st_64bit_valid1;

assign done2_keygen                  = done2;
assign done_out2_keygen              = done_out2;
assign st_64bit2_keygen              = st_64bit2;
assign st_64bit_valid2_keygen        = st_64bit_valid2;

// ==========================================
// 广播赋值: 回传给 Sign
// ==========================================
assign coeff_ExpandA_sign            = coeff_ExpandA;
assign coeff_valid_ExpandA_sign      = coeff_valid_ExpandA;
assign expand_done_ExpandA_sign      = expand_done_ExpandA;
assign dout_ExpandA_sign             = dout_ExpandA;
assign dout_valid_ExpandA_sign       = dout_valid_ExpandA;
assign dout_len_ExpandA_sign         = dout_len_ExpandA;
assign mdlen_ExpandA_sign            = mdlen_ExpandA;
assign init_ExpandA_sign             = init_ExpandA;
assign start_ExpandA_sign            = start_ExpandA;
assign start_out_ExpandA_sign        = start_out_ExpandA;
assign out_len_ExpandA_sign          = out_len_ExpandA;

assign ext_operand_request_sign      = pau_ext_operand_request;
assign ready_sign                    = pau_ready;
assign con_coeff_sign                = pau_con_coeff;
assign con_coeff_valid_sign          = pau_con_coeff_valid;

assign mac_valid_out_sign            = mac_valid_out;
assign mac_data_out_sign             = mac_data_out;

assign done1_sign                    = done1;
assign done_out1_sign                = done_out1;
assign st_64bit1_sign                = st_64bit1;
assign st_64bit_valid1_sign          = st_64bit_valid1;

assign done2_sign                    = done2;
assign done_out2_sign                = done_out2;
assign st_64bit2_sign                = st_64bit2;
assign st_64bit_valid2_sign          = st_64bit_valid2;

assign CoeffModq_ram_rd_en_sign      = CoeffModq_ram_rd_en;
assign CoeffModq_modq_coeff_sign     = CoeffModq_modq_coeff;
assign CoeffModq_modq_coeff_valid_sign = CoeffModq_modq_coeff_valid;

assign coeff_low_ExpandC_sign       = coeff_low_ExpandC;
assign coeff_low_valid_ExpandC_sign = coeff_low_valid_ExpandC;
assign coeff_high_ExpandC_sign      = coeff_high_ExpandC;
assign coeff_high_valid_ExpandC_sign= coeff_high_valid_ExpandC;
assign expand_done_ExpandC_sign     = expand_done_ExpandC;
assign dout_ExpandC_sign            = dout_ExpandC;
assign dout_valid_ExpandC_sign      = dout_valid_ExpandC;
assign dout_len_ExpandC_sign        = dout_len_ExpandC;
assign mdlen_ExpandC_sign           = mdlen_ExpandC;
assign init_ExpandC_sign            = init_ExpandC;
assign start_ExpandC_sign           = start_ExpandC;
assign start_out_ExpandC_sign       = start_out_ExpandC;
assign out_len_ExpandC_sign         = out_len_ExpandC;

// ==========================================
// 广播赋值: 回传给 Verify
// ==========================================
assign coeff_ExpandA_verify            = coeff_ExpandA;
assign coeff_valid_ExpandA_verify      = coeff_valid_ExpandA;
assign expand_done_ExpandA_verify      = expand_done_ExpandA;
assign dout_ExpandA_verify             = dout_ExpandA;
assign dout_valid_ExpandA_verify       = dout_valid_ExpandA;
assign dout_len_ExpandA_verify         = dout_len_ExpandA;
assign mdlen_ExpandA_verify            = mdlen_ExpandA;
assign init_ExpandA_verify             = init_ExpandA;
assign start_ExpandA_verify            = start_ExpandA;
assign start_out_ExpandA_verify        = start_out_ExpandA;
assign out_len_ExpandA_verify          = out_len_ExpandA;

assign coeff_low_ExpandC_verify        = coeff_low_ExpandC;
assign coeff_low_valid_ExpandC_verify  = coeff_low_valid_ExpandC;
assign coeff_high_ExpandC_verify       = coeff_high_ExpandC;
assign coeff_high_valid_ExpandC_verify = coeff_high_valid_ExpandC;
assign expand_done_ExpandC_verify      = expand_done_ExpandC;
assign dout_ExpandC_verify             = dout_ExpandC;
assign dout_valid_ExpandC_verify       = dout_valid_ExpandC;
assign dout_len_ExpandC_verify         = dout_len_ExpandC;
assign mdlen_ExpandC_verify            = mdlen_ExpandC;
assign init_ExpandC_verify             = init_ExpandC;
assign start_ExpandC_verify            = start_ExpandC;
assign start_out_ExpandC_verify        = start_out_ExpandC;
assign out_len_ExpandC_verify          = out_len_ExpandC;

assign ext_operand_request_verify      = pau_ext_operand_request;
assign ready_verify                    = pau_ready;
assign con_coeff_verify                = pau_con_coeff;
assign con_coeff_valid_verify          = pau_con_coeff_valid;

assign done1_verify                    = done1;
assign done_out1_verify                = done_out1;
assign st_64bit1_verify                = st_64bit1;
assign st_64bit_valid1_verify          = st_64bit_valid1;

assign done2_verify                    = done2;
assign done_out2_verify                = done_out2;
assign st_64bit2_verify                = st_64bit2;
assign st_64bit_valid2_verify          = st_64bit_valid2;

assign CoeffModq_ram_rd_en_verify      = CoeffModq_ram_rd_en;
assign CoeffModq_modq_coeff_verify     = CoeffModq_modq_coeff;
assign CoeffModq_modq_coeff_valid_verify = CoeffModq_modq_coeff_valid;

// ==========================================
// 2. 指令与数据下发：多合一 (MUX仲裁)
// ==========================================
always_comb begin
    // 所有的 valid、init、start 等使能信号必须默认为 0

    rho_ExpandA                 = 'd0;
    start_expand_ExpandA        = 1'b0;
    done_ExpandA                = 1'b0;
    done_out_ExpandA            = 1'b0;
    st_64bit_ExpandA            = 'd0;
    st_64bit_valid_ExpandA      = 1'b0;

    seed_ExpandC                = 'd0;
    tau_ExpandC                 = 'd0;
    start_expand_ExpandC        = 'd0;
    low_rd_en_ExpandC           = 'd0;
    coeff_low_add_ExpandC       = 'd0;
    high_rd_en_ExpandC          = 'd0;
    coeff_high_add_ExpandC      = 'd0;
    done_ExpandC                = 'd0;
    done_out_ExpandC            = 'd0;
    st_64bit_ExpandC            = 'd0;
    st_64bit_valid_ExpandC      = 'd0;

    pau_ori_coeff       = 'd0;
    pau_ori_coeff_valid = 1'b0;
    pau_request         = 1'b0;
    pau_ext_operand     = 'd0;
    pau_mode_config     = 'd0;

    mac_valid_in = 1'b0;
    mac_data_in2 = 'd0;
    for (int i=0; i<K; i++) begin
        mac_data_in1[i] = 'd0;
        mac_data_in3[i] = 'd0;
    end

    system_done_0 = 1'b0;
    t1_0        = 'd0;
    t1_valid_0  = 1'b0;
    s1_0        = 'd0;
    s1_valid_0  = 1'b0;
    s2_0        = 'd0;
    s2_valid_0  = 1'b0;
    t0_0        = 'd0;
    t0_valid_0  = 1'b0;
    z_0         = 'd0;
    z_valid_0   = 1'b0;

    system_done_1 = 1'b0;
    t1_1        = 'd0;
    t1_valid_1  = 1'b0;
    s1_1        = 'd0;
    s1_valid_1  = 1'b0;
    s2_1        = 'd0;
    s2_valid_1  = 1'b0;
    t0_1        = 'd0;
    t0_valid_1  = 1'b0;
    z_1         = 'd0;
    z_valid_1   = 1'b0;

    dout1       = 'd0;
    dout_valid1 = 1'b0;
    dout_len1   = 'd0;
    mdlen1      = 'd0;
    init1       = 1'b0;
    start1      = 1'b0;
    start_out1  = 1'b0;
    out_len1    = 'd0;

    dout2       = 'd0;
    dout_valid2 = 1'b0;
    dout_len2   = 'd0;
    mdlen2      = 'd0;
    init2       = 1'b0;
    start2      = 1'b0;
    start_out2  = 1'b0;
    out_len2    = 'd0;

    CoeffModq_ori_coeff    = 'd0;
    CoeffModq_ori_coeff_valid = 1'b0;
    CoeffModq_coeff_type = 'd0;
    CoeffModq_poly_start_pulse = 1'b0;

    // 根据 mode_config，让对应的控制器接管算力池
    case (mode_config)
        2'd0: begin             // --- KeyGen 获取控制权 ---
            rho_ExpandA                 = rho_ExpandA_keygen;
            start_expand_ExpandA        = start_expand_ExpandA_keygen;
            done_ExpandA                = done_ExpandA_keygen;
            done_out_ExpandA            = done_out_ExpandA_keygen;
            st_64bit_ExpandA            = st_64bit_ExpandA_keygen;
            st_64bit_valid_ExpandA      = st_64bit_valid_ExpandA_keygen;

            pau_ori_coeff       = ori_coeff_keygen;
            pau_ori_coeff_valid = ori_coeff_valid_keygen;
            pau_request         = request_keygen;
            pau_ext_operand     = ext_operand_keygen;
            pau_mode_config     = mode_config_keygen;

            mac_valid_in = mac_valid_in_keygen;
            mac_data_in2 = mac_data_in2_keygen;
            for (int i=0; i<K; i++) begin
                mac_data_in1[i] = mac_data_in1_keygen[i];
                mac_data_in3[i] = mac_data_in3_keygen[i];
            end

            system_done_0 = system_done_0_keygen;
            t1_0        = t1_0_keygen;
            t1_valid_0  = t1_valid_0_keygen;
            s1_0        = s1_0_keygen;
            s1_valid_0  = s1_valid_0_keygen;
            s2_0        = s2_0_keygen;
            s2_valid_0  = s2_valid_0_keygen;
            t0_0        = t0_0_keygen;
            t0_valid_0  = t0_valid_0_keygen;
            z_0         = z_0_keygen;
            z_valid_0   = z_valid_0_keygen;

            system_done_1 = system_done_1_keygen;
            t1_1        = t1_1_keygen;
            t1_valid_1  = t1_valid_1_keygen;
            s1_1        = s1_1_keygen;
            s1_valid_1  = s1_valid_1_keygen;
            s2_1        = s2_1_keygen;
            s2_valid_1  = s2_valid_1_keygen;
            t0_1        = t0_1_keygen;
            t0_valid_1  = t0_valid_1_keygen;
            z_1         = z_1_keygen;
            z_valid_1   = z_valid_1_keygen;

            dout1                       = dout1_keygen;
            dout_valid1                 = dout_valid1_keygen;
            dout_len1                   = dout_len1_keygen;
            mdlen1                      = mdlen1_keygen;
            init1                       = init1_keygen;
            start1                      = start1_keygen;
            start_out1                  = start_out1_keygen;
            out_len1                    = out_len1_keygen;

            dout2                       = dout2_keygen;
            dout_valid2                 = dout_valid2_keygen;
            dout_len2                   = dout_len2_keygen;
            mdlen2                      = mdlen2_keygen;
            init2                       = init2_keygen;
            start2                      = start2_keygen;
            start_out2                  = start_out2_keygen;
            out_len2                    = out_len2_keygen;
        end
        
        2'd1: begin             // --- Sign 获取控制权 ---
            rho_ExpandA                 = rho_ExpandA_sign;
            start_expand_ExpandA        = start_expand_ExpandA_sign;
            done_ExpandA                = done_ExpandA_sign;
            done_out_ExpandA            = done_out_ExpandA_sign;
            st_64bit_ExpandA            = st_64bit_ExpandA_sign;
            st_64bit_valid_ExpandA      = st_64bit_valid_ExpandA_sign;

            seed_ExpandC                = seed_ExpandC_sign;
            tau_ExpandC                 = tau_ExpandC_sign;
            start_expand_ExpandC        = start_expand_ExpandC_sign;
            low_rd_en_ExpandC           = low_rd_en_ExpandC_sign;
            coeff_low_add_ExpandC       = coeff_low_add_ExpandC_sign;
            high_rd_en_ExpandC          = high_rd_en_ExpandC_sign;
            coeff_high_add_ExpandC      = coeff_high_add_ExpandC_sign;
            done_ExpandC                = done_ExpandC_sign;
            done_out_ExpandC            = done_out_ExpandC_sign;
            st_64bit_ExpandC            = st_64bit_ExpandC_sign;
            st_64bit_valid_ExpandC      = st_64bit_valid_ExpandC_sign;

            pau_ori_coeff       = ori_coeff_sign;
            pau_ori_coeff_valid = ori_coeff_valid_sign;
            pau_request         = request_sign;
            pau_ext_operand     = ext_operand_sign;
            pau_mode_config     = mode_config_sign;

            mac_valid_in = mac_valid_in_sign;
            mac_data_in2 = mac_data_in2_sign;
            for (int i=0; i<K; i++) begin
                mac_data_in1[i] = mac_data_in1_sign[i];
                mac_data_in3[i] = mac_data_in3_sign[i];
            end

            dout1                       = dout1_sign;
            dout_valid1                 = dout_valid1_sign;
            dout_len1                   = dout_len1_sign;
            mdlen1                      = mdlen1_sign;
            init1                       = init1_sign;
            start1                      = start1_sign;
            start_out1                  = start_out1_sign;
            out_len1                    = out_len1_sign;

            dout2                       = dout2_sign;
            dout_valid2                 = dout_valid2_sign;
            dout_len2                   = dout_len2_sign;
            mdlen2                      = mdlen2_sign;
            init2                       = init2_sign;
            start2                      = start2_sign;
            start_out2                  = start_out2_sign;
            out_len2                    = out_len2_sign;

            CoeffModq_ori_coeff = CoeffModq_ori_coeff_sign;
            CoeffModq_ori_coeff_valid = CoeffModq_ori_coeff_valid_sign;
            CoeffModq_coeff_type = CoeffModq_coeff_type_sign;
            CoeffModq_poly_start_pulse = CoeffModq_poly_start_pulse_sign;
        end

        2'd2: begin             // --- Verify 获取控制权 ---
            rho_ExpandA                 = rho_ExpandA_verify;
            start_expand_ExpandA        = start_expand_ExpandA_verify;
            done_ExpandA                = done_ExpandA_verify;
            done_out_ExpandA            = done_out_ExpandA_verify;
            st_64bit_ExpandA            = st_64bit_ExpandA_verify;
            st_64bit_valid_ExpandA      = st_64bit_valid_ExpandA_verify;

            seed_ExpandC                = seed_ExpandC_verify;
            tau_ExpandC                 = tau_ExpandC_verify;
            start_expand_ExpandC        = start_expand_ExpandC_verify;
            low_rd_en_ExpandC           = low_rd_en_ExpandC_verify;
            coeff_low_add_ExpandC       = coeff_low_add_ExpandC_verify;
            high_rd_en_ExpandC          = high_rd_en_ExpandC_verify;
            coeff_high_add_ExpandC      = coeff_high_add_ExpandC_verify;
            done_ExpandC                = done_ExpandC_verify;
            done_out_ExpandC            = done_out_ExpandC_verify;
            st_64bit_ExpandC            = st_64bit_ExpandC_verify;
            st_64bit_valid_ExpandC      = st_64bit_valid_ExpandC_verify;

            pau_ori_coeff               = ori_coeff_verify;
            pau_ori_coeff_valid         = ori_coeff_valid_verify;
            pau_request                 = request_verify;
            pau_ext_operand             = ext_operand_verify;
            pau_mode_config             = mode_config_verify;

            dout1                       = dout1_verify;
            dout_valid1                 = dout_valid1_verify;
            dout_len1                   = dout_len1_verify;
            mdlen1                      = mdlen1_verify;
            init1                       = init1_verify;
            start1                      = start1_verify;
            start_out1                  = start_out1_verify;
            out_len1                    = out_len1_verify;

            dout2                       = dout2_verify;
            dout_valid2                 = dout_valid2_verify;
            dout_len2                   = dout_len2_verify;
            mdlen2                      = mdlen2_verify;
            init2                       = init2_verify;
            start2                      = start2_verify;
            start_out2                  = start_out2_verify;
            out_len2                    = out_len2_verify;

            CoeffModq_ori_coeff = CoeffModq_ori_coeff_verify;
            CoeffModq_ori_coeff_valid = CoeffModq_ori_coeff_valid_verify;
            CoeffModq_coeff_type = CoeffModq_coeff_type_verify;
            CoeffModq_poly_start_pulse = CoeffModq_poly_start_pulse_verify;

        end
        default: ; // 默认所有控制信号为0，保持空闲
    endcase
end


// ==========================================
// 3. 例化算力池 (保持原样)
// ==========================================

ExpandA u_ExpandA(
    .clk                ( clk                     ),
    .rstn               ( rstn                    ),
    .rho                ( rho_ExpandA             ),
    .start_expand       ( start_expand_ExpandA    ),
    .coeff              ( coeff_ExpandA           ),
    .coeff_valid        ( coeff_valid_ExpandA     ),
    .expand_done        ( expand_done_ExpandA     ),

    .dout               ( dout_ExpandA            ),
    .dout_valid         ( dout_valid_ExpandA      ),
    .dout_len           ( dout_len_ExpandA        ),
    .mdlen              ( mdlen_ExpandA           ),
    .init               ( init_ExpandA            ),
    .start              ( start_ExpandA           ),
    .done               ( done_ExpandA            ),
    .start_out          ( start_out_ExpandA       ),
    .out_len            ( out_len_ExpandA         ),
    .done_out           ( done_out_ExpandA        ),
    .st_64bit           ( st_64bit_ExpandA        ),
    .st_64bit_valid     ( st_64bit_valid_ExpandA  )
);

ExpandC u_ExpandC(
	.clk              	( clk                       ),
	.rstn             	( rstn                      ),
	.seed             	( seed_ExpandC              ),

	.tau              	( tau_ExpandC               ),
	.start_expand     	( start_expand_ExpandC      ),

	.low_rd_en        	( low_rd_en_ExpandC         ),
	.coeff_low        	( coeff_low_ExpandC         ),
	.coeff_low_add    	( coeff_low_add_ExpandC     ),
	.coeff_low_valid  	( coeff_low_valid_ExpandC   ),
	.high_rd_en       	( high_rd_en_ExpandC        ),
	.coeff_high       	( coeff_high_ExpandC        ),
	.coeff_high_add   	( coeff_high_add_ExpandC    ),
	.coeff_high_valid 	( coeff_high_valid_ExpandC  ),

	.expand_done      	( expand_done_ExpandC       ),
	.dout             	( dout_ExpandC              ),
	.dout_valid       	( dout_valid_ExpandC        ),
	.dout_len         	( dout_len_ExpandC          ),
	.mdlen            	( mdlen_ExpandC             ),
	.init             	( init_ExpandC              ),
	.start            	( start_ExpandC             ),
	.done             	( done_ExpandC              ),
	.start_out        	( start_out_ExpandC         ),
	.out_len          	( out_len_ExpandC           ),
	.done_out         	( done_out_ExpandC          ),
	.st_64bit         	( st_64bit_ExpandC          ),
	.st_64bit_valid   	( st_64bit_valid_ExpandC    )
);

assign ext_operand              = 'd0;
Poly_PAU u_Poly_PAU(
    .clk                    ( clk                     ),
    .rstn                   ( rstn                    ),
    .ori_coeff              ( pau_ori_coeff           ),
    .ori_coeff_valid        ( pau_ori_coeff_valid     ),
    .request                ( pau_request             ),
    .ext_operand            ( pau_ext_operand         ),
    .ext_operand_request    ( pau_ext_operand_request ),
    .mode_config            ( pau_mode_config         ),
    .ready                  ( pau_ready               ),
    .con_coeff              ( pau_con_coeff           ),
    .con_coeff_valid        ( pau_con_coeff_valid     )
);

MAC_Array_Pool #(
    .K ( K )
) u_MAC_Array_Pool(
    .clk        ( clk          ),
    .rstn       ( rstn         ),
    .valid_in   ( mac_valid_in ),
    .data_in1   ( mac_data_in1 ),
    .data_in2   ( mac_data_in2 ),
    .data_in3   ( mac_data_in3 ),
    .valid_out  ( mac_valid_out),
    .data_out   ( mac_data_out )
);

Encoder u_Encoder_0(
    .clk            ( clk              ),
    .rstn           ( rstn             ),
    .system_done    ( system_done_0    ),
    .t1             ( t1_0             ),
    .t1_valid       ( t1_valid_0       ),
    .s1             ( s1_0             ),
    .s1_valid       ( s1_valid_0       ),
    .s2             ( s2_0             ),
    .s2_valid       ( s2_valid_0       ),
    .t0             ( t0_0             ),
    .t0_valid       ( t0_valid_0       ),
    .z              ( z_0              ),
    .z_valid        ( z_valid_0        ),
    .encode         ( encode_0         ),
    .encoder_valid  ( encoder_valid_0  )
);

Encoder u_Encoder_1(
    .clk            ( clk              ),
    .rstn           ( rstn             ),
    .system_done    ( system_done_1    ),
    .t1             ( t1_1             ),
    .t1_valid       ( t1_valid_1       ),
    .s1             ( s1_1             ),
    .s1_valid       ( s1_valid_1       ),
    .s2             ( s2_1             ),
    .s2_valid       ( s2_valid_1       ),
    .t0             ( t0_1             ),
    .t0_valid       ( t0_valid_1       ),
    .z              ( z_1              ),
    .z_valid        ( z_valid_1        ),
    .encode         ( encode_1         ),
    .encoder_valid  ( encoder_valid_1  )
);


sha3 u_sha3_1(
    .clk                ( clk             ),
    .rstn               ( rstn            ),
    .din                ( dout1           ),
    .din_valid          ( dout_valid1     ),
    .din_len            ( dout_len1       ),
    .mdlen              ( mdlen1          ),
    .init               ( init1           ),
    .start              ( start1          ),
    .done               ( done1           ),
    .start_out          ( start_out1      ),
    .out_len            ( out_len1        ),
    .done_out           ( done_out1       ),
    .st_64bit           ( st_64bit1       ),
    .st_64bit_valid     ( st_64bit_valid1 )
);

sha3 u_sha3_2(
    .clk                ( clk             ),
    .rstn               ( rstn            ),
    .din                ( dout2           ),
    .din_valid          ( dout_valid2     ),
    .din_len            ( dout_len2       ),
    .mdlen              ( mdlen2          ),
    .init               ( init2           ),
    .start              ( start2          ),
    .done               ( done2           ),
    .start_out          ( start_out2      ),
    .out_len            ( out_len2        ),
    .done_out           ( done_out2       ),
    .st_64bit           ( st_64bit2       ),
    .st_64bit_valid     ( st_64bit_valid2 )
);

coeffModq u_coeffModq(
    .clk                ( clk                         ),
    .rstn               ( rstn                        ),
    .ram_rd_en          ( CoeffModq_ram_rd_en         ),
    .ori_coeff          ( CoeffModq_ori_coeff         ),
    .ori_coeff_valid    ( CoeffModq_ori_coeff_valid   ),
    .coeff_type         ( CoeffModq_coeff_type        ),
    .poly_start_pulse   ( CoeffModq_poly_start_pulse  ),
    .modq_coeff         ( CoeffModq_modq_coeff        ), 
    .modq_coeff_valid   ( CoeffModq_modq_coeff_valid  )
);

endmodule