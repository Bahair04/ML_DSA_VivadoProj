`include "../../param_conf.v"
module sign_internal
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

    // --- 控制标志位 ---
    input       logic                       start,          // 启动标志
    output      logic                       sign_ready,     // 准备标志
    output      logic                       done,           // 完成标志

    input       logic           [511 : 0]   mu,             // 64字节 预哈希消息
    input       logic           [255 : 0]   rnd,            // 32字节 随机数

    // --- BRAM 总线信号 ---
    output      logic           [91 : 0]    w_MatrixA_Coeff,
    output      logic                       w_MatrixA_Coeff_valid,
    output      logic           [11 : 0]    w_MatrixA_Coeff_addr,
    input       logic           [91 : 0]    r_MatrixA_Coeff [0 : K - 1],
    output      logic           [8 : 0]     r_MatrixA_Coeff_addr [0 : K - 1],

    output      logic           [91 : 0]    w_VectorS1_Coeff,                   
    output      logic                       w_VectorS1_Coeff_valid,
    output      logic           [8 : 0]     w_VectorS1_Coeff_addr,
    input       logic           [91 : 0]    r_VectorS1_Coeff,                   // 对q取模 无符号
    output      logic           [8 : 0]     r_VectorS1_Coeff_addr,

    output      logic           [91 : 0]    w_VectorS2_Coeff,                   
    output      logic                       w_VectorS2_Coeff_valid,
    output      logic           [8 : 0]     w_VectorS2_Coeff_addr,
    input       logic           [91 : 0]    r_VectorS2_Coeff [0 : K - 1],       // 对q取模 无符号
    output      logic           [5 : 0]     r_VectorS2_Coeff_addr [0 : K - 1],

    output      logic   signed  [91 : 0]    w_VectorY_Coeff,
    output      logic                       w_VectorY_Coeff_valid,
    output      logic           [8 : 0]     w_VectorY_Coeff_addr,
    input       logic           [91 : 0]    r_VectorY_Coeff,
    output      logic           [8 : 0]     r_VectorY_Coeff_addr,

    output      logic           [91 : 0]    w_VectorT_Coeff [0 : K - 1],
    output      logic                       w_VectorT_Coeff_valid [0 : K - 1],
    output      logic           [5 : 0]     w_VectorT_Coeff_addr [0 : K - 1],
    input       logic           [91 : 0]    r_VectorT_Coeff [0 : K - 1],
    output      logic           [5 : 0]     r_VectorT_Coeff_addr [0 : K - 1],

    output      logic           [91 : 0]    w_VectorM_Coeff [0 : K - 1],
    output      logic                       w_VectorM_Coeff_valid [0 : K - 1],
    output      logic           [5 : 0]     w_VectorM_Coeff_addr [0 : K - 1],
    input       logic           [91 : 0]    r_VectorM_Coeff [0 : K - 1],
    output      logic           [5 : 0]     r_VectorM_Coeff_addr [0 : K - 1],

    output      logic           [63 : 0]    w_EncodePK_Coeff,       
    output      logic                       w_EncodePK_Coeff_valid,
    output      logic           [8 : 0]     w_EncodePK_Coeff_addr,
    input       logic           [63 : 0]    r_EncodePK_Coeff,           
    output      logic           [8 : 0]     r_EncodePK_Coeff_addr,

    output      logic           [63 : 0]    w_EncodeSK_Coeff,       
    output      logic                       w_EncodeSK_Coeff_valid,
    output      logic           [9 : 0]     w_EncodeSK_Coeff_addr,
    input       logic           [63 : 0]    r_EncodeSK_Coeff,           
    output      logic           [9 : 0]     r_EncodeSK_Coeff_addr,

    // --- ExpandA 信号 ---
    output      logic           [255 : 0]   rho_ExpandA,            // 256位随机种子
    output      logic                       start_expand_ExpandA,   // 开始扩展A矩阵信号
    input       logic           [91 : 0]    coeff_ExpandA,          // 4*23bit 有效采样系数
    input       logic                       coeff_valid_ExpandA,    // 4*23bit 有效采样系数信号
    input       logic                       expand_done_ExpandA,    // 扩展完成信号

    input       logic           [7 : 0]     dout_ExpandA,           // SHA3 串行输入字节数据
    input       logic                       dout_valid_ExpandA,     // SHA3 串行输入字节有效信号
    input       logic           [31 : 0]    dout_len_ExpandA,       // SHA3 串行输入字节长度
    input       logic           [7 : 0]     mdlen_ExpandA,          // SHA3 Hash长度
    input       logic                       init_ExpandA,           // SHA3 初始化信号
    input       logic                       start_ExpandA,          // SHA3 开始装载数据
    output      logic                       done_ExpandA,           // SHA3 数据装载完成
    input       logic                       start_out_ExpandA,      // SHA3 开始挤出数据
    input       logic           [31 : 0]    out_len_ExpandA,        // SHA3 挤出数据长度
    output      logic                       done_out_ExpandA,       // SHA3 挤出数据完成
    output      logic           [63 : 0]    st_64bit_ExpandA,       // SHA3 挤出8字节数据
    output      logic                       st_64bit_valid_ExpandA, // SHA3 挤出8字节数据有效信号

    // --- Poly_PAU 输入输出接口 ---
    output      logic           [91 : 0]    ori_coeff,                  // 向Poly_PAU填充原始系数
    output      logic                       ori_coeff_valid,            // 原始系数有效信号
    output      logic                       request,                    // 上游请求信号
    output      logic           [91 : 0]    ext_operand,                // 外部输入的计算数
    input       logic                       ext_operand_request,        // 请求获取外部输入的计算数
    output      logic           [4 : 0]     mode_config,                // 模式选择 0: NTT 1: INTT 2: 模乘 3: 模加 4: 模减

    input       logic                       ready,                      // 下游准备信号
    input       logic           [91 : 0]    con_coeff,                  // NTT/INTT 结果输出
    input       logic                       con_coeff_valid,            // NTT/INTT 输出有效信号

    // --- MAC 阵列接口 ---
    output      logic                       mac_valid_in,
    output      logic           [91 : 0]    mac_data_in1 [0 : K - 1],
    output      logic           [91 : 0]    mac_data_in2,
    output      logic           [91 : 0]    mac_data_in3 [0 : K - 1],
    input       logic                       mac_valid_out,
    input       logic           [91 : 0]    mac_data_out [0 : K - 1],

    // --- SHA3-1 控制接口 ---
    output      logic           [7 : 0]     dout1, 
    output      logic                       dout_valid1, 
    output      logic           [31 : 0]    dout_len1, 
    output      logic           [7 : 0]     mdlen1, 
    output      logic                       init1, 
    output      logic                       start1, 
    input       logic                       done1, 
    output      logic                       start_out1, 
    output      logic           [31 : 0]    out_len1, 
    input       logic                       done_out1, 
    input       logic           [63 : 0]    st_64bit1, 
    input       logic                       st_64bit_valid1,

    // --- SHA3-2 控制接口 ---
    output      logic           [7 : 0]     dout2, 
    output      logic                       dout_valid2, 
    output      logic           [31 : 0]    dout_len2, 
    output      logic           [7 : 0]     mdlen2, 
    output      logic                       init2, 
    output      logic                       start2, 
    input       logic                       done2, 
    output      logic                       start_out2, 
    output      logic           [31 : 0]    out_len2, 
    input       logic                       done_out2, 
    input       logic           [63 : 0]    st_64bit2, 
    input       logic                       st_64bit_valid2
);

// 参数维度
// y - l维向量      --  新建存储区 
// w - k维向量      --  与t完全一致 使用与t完全一致存储区
// c_tilde - 32Byte -- 字节流
// c - 标量
// c_hat - 标量 - 需保存 后面分别于s1_hat s2_hat t0_hat进行标量乘法 然后逆变换获得系数 并立即判断范围

//* ==========================================================
//* 1. 参数与状态定义
//* ==========================================================
typedef enum logic [5 : 0] { 
    S_IDLE,                     // 空闲状态
    S_INIT,                     // 初始化状态
    S_PREPROC_NTT_ACK,          
    S_PREPROC_NTT_WAIT,
    S_PREPROC_NTT_STORE,
    S_PREPROC_GET_RHO,
    S_EXPAND_A,
    S_STORE_A,

    // 签名循环开始
    S_SIGN_LOOP_INIT,           
    
    // 扩展并存储Y多项式(l个)
    S_EXPAND_Y,
    S_STORE_Y,

    // 从BRAM中读出Y多项式并通过NTT变换到NTT域 获取NTT域系数的同时，从存储矩阵中读出k个A向量，使用ModuleMAC计算矩阵乘法 并将结果写回W矩阵
    S_Y_NTT_ACK,
    S_Y_NTT,
    S_Y_NTT_WAIT,
    S_MATRIX_MULT_WAIT,

    // 从W矩阵中读出多项式，并进行INTT逆变换 变换的结果同时取高位按字节pack后存入SHA3
    S_M_INTT_ACK, 
    S_M_INTT,     
    S_M_INTT_WAIT,
    S_M_INTT_END,
    S_DUMMY0,
    
    S_C_NTT_ACK,
    S_EXPAND_C,
    S_STORE_C,
    S_C_NTT,
    S_C_NTT_WAIT,
    
    S_MULT_INTT_ACK,
    S_MULT_INTT,
    S_MULT_INTT_WAIT

} state_t;

state_t                             state, state_d;

typedef enum logic [4 : 0] { 
    S_SUB_IDLE,
    S_SUB_INIT,
    S_SUB_LOAD,
    S_SUB_SQUEEZE,                  // 获得rho_prime(seed_expand)
    S_SUB_WAIT,
    S_SUB_INIT_C_TILDE,             // C_TILDE SHA3初始化
    S_SUB_LOAD_C_TILDE_MU,          // 加载MU
    S_SUB_LOAD_C_TILDE_W1_BYTES,    // 主状态机生成w时去高位获得w1，再通过pack模块获得字节流 子状态机将字节流载入SHA3
    S_SUB_SQUEEZE_C_TILDE           // 加载完MU和w1字节流之后 挤出C_TILDE 用于后续生成c多项式
} substate_t;

substate_t                          substate, substate_d;

localparam      S1_POLYS = L;
localparam      S2_POLYS = K;
localparam      T0_POLYS = K;
localparam      TOTAL_POLYS = S1_POLYS + S2_POLYS + T0_POLYS;

logic [4 : 0]   poly_cnt;

//* ==========================================================
//* 2. 内部信号统一定义
//* ==========================================================

// --- Seed 处理信号 ---
logic           [1023 : 0]          seed_domain_sep;     // 128 字节输入原始种子
logic           [511 : 0]           seed_expand;         // 64 字节扩展种子
logic           [7 : 0]             seed_expand_cnt;     // 扩展种子字节计数器 一次输出8字节 所以计数器每次 +8
logic           [7 : 0]             seed_load_cnt;       // 输入种子字节计数器

logic           [7 : 0]             dout_seed;           // SHA3 串行输入字节数据
logic                               dout_valid_seed;     // SHA3 串行输入字节有效信号
logic           [31 : 0]            dout_len_seed;       // SHA3 串行输入字节长度
logic           [7 : 0]             mdlen_seed;          // SHA3 Hash长度
logic                               init_seed;           // SHA3 初始化信号
logic                               start_seed;          // SHA3 开始装载数据
logic                               done_seed;           // SHA3 数据装载完成
logic                               start_out_seed;      // SHA3 开始挤出数据
logic           [31 : 0]            out_len_seed;        // SHA3 挤出数据长度
logic                               done_out_seed;       // SHA3 挤出数据完成
logic           [63 : 0]            st_64bit_seed;       // SHA3 挤出8字节数据
logic                               st_64bit_valid_seed; // SHA3 挤出8字节数据有效信号

// --- BRAM 信号 ---
logic           [511 : 0]           tr_seed;
logic           [255 : 0]           rho;
logic           [255 : 0]           k_seed;     // 保存 k_seed (32 bytes = 256 bits)

// --- 用于计算地址偏移的本地参数 ---
localparam S1_RAM_LEN = L * 256 * S1_S2_BIT_LEN / 64;
localparam S2_RAM_LEN = K * 256 * S1_S2_BIT_LEN / 64;
localparam T0_RAM_LEN = K * 256 * T0_BIT_LEN / 64;
localparam TR_RAM_LEN = 8; // TR 是 64 bytes = 512 bits = 8 个 64-bit 块

localparam TR_START_ADDR = S1_RAM_LEN + S2_RAM_LEN + T0_RAM_LEN;

// --- 读取 RHO 和 K_SEED 用的计数器 ---
logic           [4 : 0]             fetch_cnt;
logic                               fetch_valid;
logic           [4 : 0]             save_cnt;

// --- NTT/INTT (Poly_PAU) 信号 ---
logic           [8 : 0]             con_coeff_cnt;  
logic           [8 : 0]             con_coeff_cnt_d;

// --- coeffModq 控制信号 ---
logic                               ram_rd_en;
logic                               coeff_valid_d;
logic           [1 : 0]             current_coeff_type;

// --- Expand Y ---
logic           [511 : 0]           rho_prime_ExpandY;      
logic           [15 : 0]            kappa_ExpandY;          
logic                               start_expand_ExpandY;   
logic           [91 : 0]            coeff_ExpandY;          
logic                               coeff_valid_ExpandY;  
logic                               expand_done_ExpandY;   

logic           [7 : 0]             dout_ExpandY;           
logic                               dout_valid_ExpandY;     
logic           [31 : 0]            dout_len_ExpandY;       
logic           [7 : 0]             mdlen_ExpandY;          
logic                               init_ExpandY;           
logic                               start_ExpandY;          
logic                               done_ExpandY;           
logic                               start_out_ExpandY;      
logic           [31 : 0]            out_len_ExpandY;        
logic                               done_out_ExpandY;       
logic           [63 : 0]            st_64bit_ExpandY;       
logic                               st_64bit_valid_ExpandY;  

// --- mac ---
logic           [91 : 0]            con_coeff_d;
logic                               con_coeff_valid_d;
logic           [22 : 0]            conv [0 : 3];
logic                               w_VectorM_Coeff_valid_d [0 : K - 1];
logic           [91 : 0]            r_VectorM_Coeff_INTT;
logic           [8 : 0]             r_VectorM_Coeff_addr_INTT;
logic           [8 : 0]             r_VectorM_Coeff_addr_INTT_d;
logic                               m_valid;
logic           [91 : 0]            m;

logic           [10 : 0]            mac_cnt;   // 乘法次数计数器
logic           [1 : 0]             mac_stage; // 指示乘法阶段：0-s1*c 1-s2*c 2-t0*c
logic           [1 : 0]             mac_stage_d;
logic                               mac_valid; // 输入信号有效标志
logic           [2 : 0]             select;    // 确定选择S2和T的哪一行
logic                               valid_out [0 : K - 1];
logic           [91 : 0]            mac_out_comb [0 : K - 1];
logic                               mult_res_valid_d;

logic           [91 : 0]            mult_res;           // s1*c s2*c t0*c 阶段的乘法结果
logic                               mult_res_valid;     // 乘法结果有效标志

// --- high_bits(decompose) ---

logic   signed  [24 : 0]            r [0 : 3];
logic                               r_valid [0 : 3];

logic           [7 : 0]             r1 [0 : 3];                     // 无符号   8位
logic                               r1_valid [0 : 3];
logic   signed  [18 : 0]            r0 [0 : 3];                     // 有符号   19位
logic                               r0_valid [0 : 3];

// --- Serializer ---
logic           [7 : 0] 	        w_out;
logic      	                        w_out_valid;

// --- c_tilde ---
logic           [255 : 0]           c_tilde;

// --- ExpandC ---
logic           [255 : 0]           seed_ExpandC;           
logic           [7 : 0]             tau_ExpandC;            
logic                               start_expand_ExpandC;   
logic                               low_rd_en_ExpandC;      
logic           [1 : 0]             coeff_low_ExpandC;      
logic           [7 : 0]             coeff_low_add_ExpandC;  
logic                               coeff_low_valid_ExpandC;
logic                               high_rd_en_ExpandC;     
logic           [1 : 0]             coeff_high_ExpandC;     
logic           [7 : 0]             coeff_high_add_ExpandC; 
logic                               coeff_high_valid_ExpandC;
logic                               expand_done_ExpandC;   

logic           [7 : 0]             dout_ExpandC;           
logic                               dout_valid_ExpandC;     
logic           [31 : 0]            dout_len_ExpandC;       
logic           [7 : 0]             mdlen_ExpandC;          
logic                               init_ExpandC;           
logic                               start_ExpandC;          
logic                               done_ExpandC;           
logic                               start_out_ExpandC;      
logic           [31 : 0]            out_len_ExpandC;        
logic                               done_out_ExpandC;       
logic           [63 : 0]            st_64bit_ExpandC;       
logic                               st_64bit_valid_ExpandC;  

logic           [91 : 0]            data_out;       // 扩展C时用到的拼接器 连接模块
logic                               data_valid_out; // 扩展C时用到的拼接器有效信号 连接模块
logic           [5 : 0]             data_cnt;       // 扩展C时用到的拼接器计数器 连接模块
(* ram_style = "distributed" *) logic [91 : 0]    c_hat [0 : 63];
logic           [91 : 0]            r_c_hat;
logic           [5 : 0]             r_c_hat_addr;
logic           [8 : 0]             r_VectorS2_Coeff_addr_global;
logic           [8 : 0]             r_VectorT_Coeff_addr_global;
logic           [8 : 0]             r_VectorM_Coeff_addr_global;
logic           [8 : 0]             r_VectorS2_Coeff_addr_global_d;
logic           [8 : 0]             r_VectorT_Coeff_addr_global_d;
logic           [8 : 0]             r_VectorM_Coeff_addr_global_d;

// --- Rejection ---
logic           [63 : 0] 	        encode;
logic        	                    encoder_valid;
logic        	                    reject_flag;

//* ==========================================================
//* 3. 状态机
//* ==========================================================

always_ff @(posedge clk) begin
    if (!rstn) begin
        state <= S_IDLE;
        poly_cnt <= 'd0;
        kappa_ExpandY <= 'd0;
        mac_stage <= 'd0;
    end
    else begin
        case (state)
            S_IDLE: begin
                if (start && sign_ready) 
                    state <= S_INIT;
                else 
                    state <= S_IDLE;
            end
            S_INIT : begin
                poly_cnt <= 'd0;
                state <= S_PREPROC_NTT_ACK;
            end
            S_PREPROC_NTT_ACK : begin
                if (ready == 1'b0 && request == 1'b1)
                    state <= S_PREPROC_NTT_WAIT;
                else 
                    state <= S_PREPROC_NTT_ACK;
            end
            S_PREPROC_NTT_WAIT : begin
                if (con_coeff_valid && con_coeff_cnt == 9'd63) 
                    state <= S_PREPROC_NTT_STORE;
                else 
                    state <= S_PREPROC_NTT_WAIT;
            end
            S_PREPROC_NTT_STORE : begin
                if (poly_cnt == TOTAL_POLYS - 1) begin
                    state <= S_PREPROC_GET_RHO;
                end 
                else begin
                    poly_cnt <= poly_cnt + 1'b1;
                    state <= S_PREPROC_NTT_ACK;
                end
            end
            S_PREPROC_GET_RHO : begin           // 读取并保存完 16 个块 (4块tr + 4块rho + 4块k) 后进入下一步
                if (save_cnt == 5'd16)
                    state <= S_EXPAND_A;
                else
                    state <= S_PREPROC_GET_RHO;
            end
            S_EXPAND_A : begin
                state <= S_STORE_A;
            end
            S_STORE_A : begin
                if (expand_done_ExpandA)
                    state <= S_SIGN_LOOP_INIT;
                else 
                    state <= S_STORE_A;
            end
            S_SIGN_LOOP_INIT : begin
                state <= S_EXPAND_Y;                
                kappa_ExpandY <= 'd0; 
                mac_stage <= 'd0;
            end
            S_EXPAND_Y : begin
                state <= S_STORE_Y;
            end
            S_STORE_Y : begin
                if (expand_done_ExpandY) begin
                    state <= S_Y_NTT_ACK;
                    kappa_ExpandY <= kappa_ExpandY + L;
                end
                else
                    state <= S_STORE_Y;
            end
            S_Y_NTT_ACK : begin
                if (ready == 1'b0 && request == 1'b1)
                    state <= S_Y_NTT;
                else 
                    state <= S_Y_NTT_ACK;
            end
            S_Y_NTT : begin
                if (r_VectorY_Coeff_addr > 0 && r_VectorY_Coeff_addr[5 : 0] == 0)
                    state <= S_Y_NTT_WAIT;
                else
                    state <= S_Y_NTT;
            end
            S_Y_NTT_WAIT : begin
                if (con_coeff_cnt[5 : 0] == 'd63) begin
                    if (con_coeff_cnt == `l * 64 - 1)
                        state <= S_MATRIX_MULT_WAIT;
                    else
                        state <= S_Y_NTT_ACK;
                end
                else
                    state <= S_Y_NTT_WAIT;
            end
            S_MATRIX_MULT_WAIT : begin
                if (w_VectorM_Coeff_valid_d[0] && !w_VectorM_Coeff_valid[0])
                    state <= S_M_INTT_ACK;
                else 
                    state <= S_MATRIX_MULT_WAIT;
            end
            S_M_INTT_ACK : begin
                if (ready == 1'b0 && request == 1'b1)
                    state <= S_M_INTT;
                else 
                    state <= S_M_INTT_ACK;
            end
            S_M_INTT : begin
                if (r_VectorM_Coeff_addr_INTT > 0 && r_VectorM_Coeff_addr_INTT[5 : 0] == 0)  // r_VectorM_Coeff_addr % 64 == 0
                    state <= S_M_INTT_WAIT;
                else 
                    state <= S_M_INTT;
            end
            S_M_INTT_WAIT : begin
                if (con_coeff_cnt[5 : 0] == 'd63) begin
                    if (con_coeff_cnt == `k * 64 - 1)	// 一共`k组 全部转换完成后进入下一状态
                        state <= S_M_INTT_END;			
                    else 								// 否则就回到握手状态 准备下一组INTT变换
                        state <= S_M_INTT_ACK;
                end
                else 
                    state <= S_M_INTT_WAIT;
            end
            S_M_INTT_END : begin
                if (con_coeff_cnt == `k * 64)
                    state <= S_DUMMY0;
                else 
                    state <= S_M_INTT_END;
            end
            S_DUMMY0 : begin
                if (substate == S_SUB_SQUEEZE_C_TILDE && done_out_seed)
                    state <= S_C_NTT_ACK;
                else
                    state <= S_DUMMY0;
            end
            S_C_NTT_ACK : begin
                if (ready == 1'b0 && request == 1'b1)
                    state <= S_EXPAND_C;
                else
                    state <= S_C_NTT_ACK;
            end
            S_EXPAND_C : begin
                state <= S_STORE_C;
            end
            S_STORE_C : begin 
                if (expand_done_ExpandC)
                    state <= S_C_NTT;
                else 
                    state <= S_STORE_C;
            end
            S_C_NTT : begin
                if (data_cnt == 'd63 && data_valid_out)
                    state <= S_C_NTT_WAIT;
                else
                    state <= S_C_NTT;
            end
            S_C_NTT_WAIT : begin
                if (con_coeff_cnt == 'd63 && con_coeff_valid)
                    state <= S_MULT_INTT_ACK;
                else
                    state <= S_C_NTT_WAIT;
            end
            S_MULT_INTT_ACK : begin
                if (ready == 1'b0 && request == 1'b1)
                    state <= S_MULT_INTT;
                else 
                    state <= S_MULT_INTT_ACK;
            end
            S_MULT_INTT : begin
                if (mac_cnt == 'd63)
                    state <= S_MULT_INTT_WAIT;
                else 
                    state <= S_MULT_INTT;
            end
            S_MULT_INTT_WAIT : begin
                case (mac_stage)
                    'd0 : begin
                        if (con_coeff_cnt == `l * 64 - 1) begin
                            mac_stage <= 'd1;
                            state <= S_MULT_INTT_ACK;
                        end
                        else if (con_coeff_cnt[5 : 0] == 'd63)
                            state <= S_MULT_INTT_ACK;
                        else 
                            state <= S_MULT_INTT_WAIT;
                    end
                    'd1 : begin 
                        if (con_coeff_cnt == `k * 64 - 1) begin
                            mac_stage <= 'd2;
                            state <= S_MULT_INTT_ACK;
                        end
                        else if (con_coeff_cnt[5 : 0] == 'd63)
                            state <= S_MULT_INTT_ACK;
                        else 
                            state <= S_MULT_INTT_WAIT;
                    end
                    'd2 : begin 
                        if (con_coeff_cnt == `k * 64 - 1) begin
                            mac_stage <= 'd0;
                            state <= S_IDLE;
                        end
                        else if (con_coeff_cnt[5 : 0] == 'd63)  
                            state <= S_MULT_INTT_ACK;
                        else 
                            state <= S_MULT_INTT_WAIT;
                    end
                endcase
            end
            default : begin
                state <= S_IDLE;
            end
        endcase
    end
end

always_ff @(posedge clk) begin
    if (!rstn) 
        state_d <= S_IDLE;
    else 
        state_d <= state;
end

always_ff @(posedge clk) begin
    if (!rstn)
        mac_stage_d <= S_IDLE;
    else 
        mac_stage_d <= mac_stage;
end

always_ff @(posedge clk) begin
    if (!rstn)
        substate <= S_SUB_IDLE;
    else begin
        case (substate)
            S_SUB_IDLE : begin
                if (state == S_EXPAND_A)  
                    substate <= S_SUB_INIT;
                else
                    substate <= S_SUB_IDLE;
            end
            S_SUB_INIT : begin 
                substate <= S_SUB_LOAD;
            end
            S_SUB_LOAD : begin
                if (done_seed)
                    substate <= S_SUB_SQUEEZE;
                else 
                    substate <= S_SUB_LOAD;
            end
            S_SUB_SQUEEZE : begin
                if (done_out_seed)
                    substate <= S_SUB_WAIT;
                else 
                    substate <= S_SUB_SQUEEZE;
            end
            S_SUB_WAIT : begin
                if (state == S_EXPAND_Y)
                    substate <= S_SUB_INIT_C_TILDE;
                else 
                    substate <= S_SUB_WAIT;
            end
            S_SUB_INIT_C_TILDE : begin
                substate <= S_SUB_LOAD_C_TILDE_MU;
            end
            S_SUB_LOAD_C_TILDE_MU : begin
                if (seed_load_cnt == 'd64)
                    substate <= S_SUB_LOAD_C_TILDE_W1_BYTES;
                else
                    substate <= S_SUB_LOAD_C_TILDE_MU;
            end
            S_SUB_LOAD_C_TILDE_W1_BYTES : begin
                if (done_seed)
                    substate <= S_SUB_SQUEEZE_C_TILDE;
                else
                    substate <= S_SUB_LOAD_C_TILDE_W1_BYTES;
            end
            S_SUB_SQUEEZE_C_TILDE : begin
                if (done_out_seed)
                    substate <= S_SUB_IDLE;
                else 
                    substate <= S_SUB_SQUEEZE_C_TILDE;
            end
            default : begin
                substate <= S_SUB_IDLE;
            end
        endcase
    end
end

always_ff @(posedge clk) begin
    if (!rstn)
        substate_d <= S_SUB_IDLE;
    else 
        substate_d <= substate;
end

always_ff @(posedge clk) begin
    if (!rstn) 
        sign_ready <= 1'b1;
    else if (state == S_IDLE) 
        sign_ready <= 1'b1;
    else 
        sign_ready <= 1'b0;
end

//* ==========================================================
//* 4. BRAM 读取与 coeffModq 变速解包
//* ==========================================================

always_comb begin
    if (poly_cnt < S1_POLYS)
        current_coeff_type = 2'd0; // s1
    else if (poly_cnt < S1_POLYS + S2_POLYS)
        current_coeff_type = 2'd1; // s2
    else
        current_coeff_type = 2'd2; // t0
end

// 1. 核心读地址 MUX 仲裁
always_ff @(posedge clk) begin
    if (!rstn)
        r_EncodeSK_Coeff_addr <= 'd0;
    else if (state == S_INIT || state == S_IDLE)
        r_EncodeSK_Coeff_addr <= 'd0;
    // NTT 预处理阶段，受 coeffModq 反控 读取s1 s2 t0
    else if (ram_rd_en && state >= S_PREPROC_NTT_ACK && state <= S_PREPROC_NTT_STORE)
        r_EncodeSK_Coeff_addr <= r_EncodeSK_Coeff_addr + 1'b1;
    // 多项式全部处理完的瞬间，地址直接飞跃到 RHO 的起点 跳过tr 直接读取rho和k
    else if (state == S_PREPROC_NTT_STORE && poly_cnt == TOTAL_POLYS - 1)
        r_EncodeSK_Coeff_addr <= TR_START_ADDR;
    // 获取 TR, RHO 和 K 时，连读 16 拍
    else if (state == S_PREPROC_GET_RHO && fetch_cnt < 5'd16)
        r_EncodeSK_Coeff_addr <= r_EncodeSK_Coeff_addr + 1'b1;
end

// 2. 严格屏蔽 coeffModq 的有效信号，防止读取 RHO 时把数据误喂给多项式解包器
always_ff @(posedge clk) begin
    if (!rstn) 
        coeff_valid_d <= 1'b0;
    else 
        // 只有在 NTT 处理阶段才允许给 coeffModq 发送 valid
        coeff_valid_d <= (ram_rd_en && state >= S_PREPROC_NTT_ACK && state <= S_PREPROC_NTT_STORE);
end

logic           [63 : 0]            reverse_temp;
logic           [91 : 0]            ori_coeff_Modq;
logic                               ori_coeff_valid_Modq;
assign reverse_temp = {<<8{r_EncodeSK_Coeff}};
coeffModq u_coeffModq(
    .clk                ( clk                                                               ),
    .rstn               ( rstn                                                              ),
    .ram_rd_en          ( ram_rd_en                                                         ),
    .ori_coeff          ( reverse_temp                                                      ),
    .ori_coeff_valid    ( coeff_valid_d                                                     ),
    .coeff_type         ( current_coeff_type                                                ),
    .poly_start_pulse   ( state == S_PREPROC_NTT_ACK && ready == 1'b0 && request == 1'b1    ),
    .modq_coeff         ( ori_coeff_Modq                                                    ), 
    .modq_coeff_valid   ( ori_coeff_valid_Modq                                              )
);

always_ff @(posedge clk) begin
    if (!rstn)     
        r_VectorY_Coeff_addr <= 'd0;
    else if (state == S_INIT) 
        r_VectorY_Coeff_addr <= 'd0;
    else if (state == S_Y_NTT) begin
        if (r_VectorY_Coeff_addr == `l * 64)
            r_VectorY_Coeff_addr <= 'd0;
        else if (r_VectorY_Coeff_addr > 0 && r_VectorY_Coeff_addr[5 : 0] == 0)
            r_VectorY_Coeff_addr <= r_VectorY_Coeff_addr;
        else 
            r_VectorY_Coeff_addr <= r_VectorY_Coeff_addr + 1'b1;
    end
    else if (S_Y_NTT_WAIT >= state && state >= S_Y_NTT_ACK && ready == 1'b0 && request == 1'b1)
        r_VectorY_Coeff_addr <= r_VectorY_Coeff_addr + 1'b1;
    else if (state >= S_MULT_INTT && state <= S_MULT_INTT_WAIT && mac_stage == 'd0) begin
        if (con_coeff_valid) begin
            if (r_VectorY_Coeff_addr == `l * 64 - 1)
                r_VectorY_Coeff_addr <= 'd0;
            else
                r_VectorY_Coeff_addr <= r_VectorY_Coeff_addr + 1'b1;
        end
        else 
            r_VectorY_Coeff_addr <= r_VectorY_Coeff_addr;
    end
    else
        r_VectorY_Coeff_addr <= r_VectorY_Coeff_addr;
end

always_comb begin
    ori_coeff = 'd0;
    ori_coeff_valid = 1'b0;
    if (state <= S_PREPROC_NTT_STORE) begin
        ori_coeff = ori_coeff_Modq;
        ori_coeff_valid = ori_coeff_valid_Modq;
    end
    else if (state == S_Y_NTT) begin
        ori_coeff = r_VectorY_Coeff;
        ori_coeff_valid = 1'b1;
    end
    else if (state == S_M_INTT) begin
        ori_coeff = r_VectorM_Coeff_INTT;
        ori_coeff_valid = 1'b1;
    end
    else if (state == S_C_NTT) begin
        ori_coeff = data_out;
        ori_coeff_valid = data_valid_out;
    end
    else if (state >= S_MULT_INTT && state <= S_MULT_INTT_WAIT) begin
        ori_coeff = mult_res;
        ori_coeff_valid = mult_res_valid;
    end
end

//* ==========================================================
//* 5. Poly_PAU 控制逻辑
//* ==========================================================
assign ext_operand = 'd0;
always_comb begin
    if (state <= S_PREPROC_NTT_STORE)
        mode_config = 'd0;
    else if (state >= S_M_INTT_ACK && state <= S_M_INTT_WAIT)
        mode_config = 'd1;
    else if (state >= S_C_NTT && state <= S_C_NTT_WAIT)
        mode_config = 'd0;
    else if (state >= S_MULT_INTT && state <= S_MULT_INTT_WAIT)
        mode_config = 'd1;
end
always_ff @(posedge clk) begin
    if (!rstn)
        request <= 1'b0;
    else if (state == S_PREPROC_NTT_ACK || state == S_Y_NTT_ACK || state == S_M_INTT_ACK || 
             state == S_C_NTT_ACK || state == S_MULT_INTT_ACK) begin
        if (ready) 
            request <= 1'b1;
        else 
            request <= 1'b0;
    end
    else 
        request <= 1'b0;
end

always_ff @(posedge clk) begin
    if (!rstn)
        con_coeff_cnt <= 'd0;
    else if (state == S_PREPROC_NTT_ACK || state == S_SIGN_LOOP_INIT || state == S_MATRIX_MULT_WAIT || 
             state == S_DUMMY0)
        con_coeff_cnt <= 'd0;  // 每次握手前清零
    else if (con_coeff_valid) begin
        if (state <= S_Y_NTT_WAIT && con_coeff_cnt == `l * 64 - 1)
            con_coeff_cnt <= 'd0;
        else if (state > S_Y_NTT_WAIT && state <= S_M_INTT_WAIT && con_coeff_cnt == `k * 64)
            con_coeff_cnt <= 'd0;
        else if (state > S_M_INTT_WAIT && state <= S_C_NTT_WAIT && con_coeff_cnt == 64 - 1)
            con_coeff_cnt <= 'd0;
        else if (state >= S_MULT_INTT && state <= S_MULT_INTT_WAIT) begin
            if (mode_config == 'd0 && con_coeff_cnt == `l * 64 - 1)
                con_coeff_cnt <= 'd0;
            else if (mode_config == 'd1 && con_coeff_cnt == `k * 64 - 1)
                con_coeff_cnt <= 'd0;
            else if (mode_config == 'd2 && con_coeff_cnt == `k * 64 - 1)
                con_coeff_cnt <= 'd0;
            else 
                con_coeff_cnt <= con_coeff_cnt + 1'b1;
        end
        else
            con_coeff_cnt <= con_coeff_cnt + 1'b1;
    end
    else 
        con_coeff_cnt <= con_coeff_cnt;
end

always_ff @(posedge clk) begin
    if (!rstn)
        con_coeff_cnt_d <= 'd0;
    else 
        con_coeff_cnt_d <= con_coeff_cnt;
end

//* ==========================================================
//* 6. BRAM 回写分发 (Demux to BRAMs)
//* ==========================================================

logic [4:0] s2_idx;
logic [4:0] t0_idx;
assign s2_idx = poly_cnt - L[4:0];
assign t0_idx = poly_cnt - (L[4:0] + K[4:0]);

always_comb begin
    w_VectorS1_Coeff       = 92'd0;
    w_VectorS1_Coeff_valid = 1'b0;
    w_VectorS1_Coeff_addr  = 9'd0;

    w_VectorS2_Coeff       = 92'd0;
    w_VectorS2_Coeff_valid = 1'b0;
    w_VectorS2_Coeff_addr  = 9'd0;

    for (int i = 0; i < K; i++) begin
        w_VectorT_Coeff[i]       = 92'd0;
        w_VectorT_Coeff_valid[i] = 1'b0;
        w_VectorT_Coeff_addr[i]  = 6'd0;
    end

    // 当 Poly_PAU 输出有效时，进行回写
    if (state == S_PREPROC_NTT_WAIT && con_coeff_valid) begin
        
        if (poly_cnt < L) begin
            w_VectorS1_Coeff       = con_coeff;
            w_VectorS1_Coeff_valid = 1'b1;
            w_VectorS1_Coeff_addr  = {poly_cnt[2:0], con_coeff_cnt[5:0]}; 
        end
        else if (poly_cnt < L + K) begin
            w_VectorS2_Coeff       = con_coeff;
            w_VectorS2_Coeff_valid = 1'b1;
            w_VectorS2_Coeff_addr  = {s2_idx[2:0], con_coeff_cnt[5:0]};
        end
        else begin
            for (int i = 0; i < K; i++) begin
                if (i == t0_idx) begin
                    w_VectorT_Coeff[i]       = con_coeff;
                    w_VectorT_Coeff_valid[i] = 1'b1;
                    w_VectorT_Coeff_addr[i]  = con_coeff_cnt[5:0];
                end
            end
        end
    end
end

// --------------------------------
// 矩阵 A 回写分发 (Demux to BRAMs)
// --------------------------------
always_comb begin
    w_MatrixA_Coeff = 'd0;
    w_MatrixA_Coeff_valid = 1'b0;
    if (state == S_STORE_A) begin
        w_MatrixA_Coeff = coeff_ExpandA;
        w_MatrixA_Coeff_valid = coeff_valid_ExpandA;
    end
end

always_ff @(posedge clk) begin
    if (!rstn)
        w_MatrixA_Coeff_addr <= 'd0;
    else if (state == S_INIT)
        w_MatrixA_Coeff_addr <= 'd0;
    else if (state == S_STORE_A && coeff_valid_ExpandA)
        w_MatrixA_Coeff_addr <= w_MatrixA_Coeff_addr + 1'b1;
    else 
        w_MatrixA_Coeff_addr <= w_MatrixA_Coeff_addr;
end

// --------------------------------
// 矩阵 Y 回写分发 (Demux to BRAMs)
// --------------------------------
always_comb begin
    w_VectorY_Coeff = 'd0;
    w_VectorY_Coeff_valid = 1'b0;
    if (state == S_STORE_Y) begin
        w_VectorY_Coeff = coeff_ExpandY;
        w_VectorY_Coeff_valid = coeff_valid_ExpandY;
    end
end

always_ff @(posedge clk) begin
    if (!rstn)
        w_VectorY_Coeff_addr <= 'd0;
    else if (state == S_INIT)
        w_VectorY_Coeff_addr <= 'd0;
    else if (state == S_STORE_Y && coeff_valid_ExpandY)
        w_VectorY_Coeff_addr <= w_VectorY_Coeff_addr + 1'b1;
    else 
        w_VectorY_Coeff_addr <= w_VectorY_Coeff_addr;
end

//* ==========================================================
//* 7. SHA3 控制逻辑
//* ==========================================================

always_comb begin
    out_len_seed = out_len_seed;
    dout_len_seed = dout_len_seed;
    mdlen_seed = mdlen_seed;
    if (substate <= S_SUB_SQUEEZE) begin
        out_len_seed = 'd64;			// 原始种子扩展 扩展后为64Byte
        dout_len_seed = 'd128;			// 原始种子长度为 128Byte 需要按字节装载进SHA3
        mdlen_seed = 'd32;				// 32-SHA256 16-SHA128 这里为SHA256
    end
    else if (substate <= S_SUB_SQUEEZE_C_TILDE) begin
        out_len_seed = `c_tilde_bytes;
        if (K == 4)
            dout_len_seed = 'd768 + 'd64;
        else if (K == 6)
            dout_len_seed = 'd768 + 'd64;
        else 
            dout_len_seed = 'd1024 + 'd64;
        mdlen_seed = 'd32;
    end
    else begin
        out_len_seed = 'd64;			// 原始种子扩展 扩展后为64Byte
        dout_len_seed = 32 + 320 * K;	// 原始种子长度为 32 + 320 * K Byte 需要按字节装载进SHA3
        mdlen_seed = 'd32;				// 32-SHA256 16-SHA128 这里为SHA256
    end
end

always_ff @(posedge clk) begin
    if (!rstn)
        start_seed <= 1'b0;
    else if (substate == S_SUB_INIT || substate == S_SUB_INIT_C_TILDE)
        start_seed <= 1'b1;
    else
        start_seed <= 1'b0;
end
assign init_seed = (substate == S_SUB_INIT) || (substate == S_SUB_INIT_C_TILDE);

always_ff @(posedge clk) begin
    if (!rstn) begin
        dout_seed <= 'd0;
        dout_valid_seed <= 1'b0;
        seed_domain_sep <= 'd0;
        seed_load_cnt <= 'd0;
    end
    else if (substate == S_SUB_INIT) begin
        dout_seed <= 'd0;
        dout_valid_seed <= 1'b0;
        seed_domain_sep <= {k_seed, rnd, mu};
        seed_load_cnt <= 'd0;
    end
    else if (substate == S_SUB_INIT_C_TILDE) begin
        dout_seed <= 'd0;
        dout_valid_seed <= 1'b0;
        seed_domain_sep <= {mu, 512'd0};
        seed_load_cnt <= 'd0;
    end
    else if (substate == S_SUB_LOAD) begin
        if (done_seed)
            seed_load_cnt <= 'd0;
        else if (seed_load_cnt == dout_len_seed)
            seed_load_cnt <= dout_len_seed;
        else
            seed_load_cnt <= seed_load_cnt + 1'b1;
            
        if (seed_load_cnt == dout_len_seed) begin
            dout_seed <= 'd0;
            dout_valid_seed <= 1'b0;
        end
        else begin
            dout_seed <= seed_domain_sep[1023 : 1016];
            dout_valid_seed <= 1'b1;
            seed_domain_sep <= seed_domain_sep << 8;
        end
    end
    else if (substate == S_SUB_LOAD_C_TILDE_MU) begin
        seed_load_cnt <= seed_load_cnt + 1'b1;
        dout_seed <= seed_domain_sep[1023 : 1016];
        if (seed_load_cnt == 'd64)
            dout_valid_seed <= 1'b0;
        else
            dout_valid_seed <= 1'b1;
        seed_domain_sep <= seed_domain_sep << 8;
    end
    else if (substate == S_SUB_LOAD_C_TILDE_W1_BYTES) begin
        dout_seed <= w_out;
        dout_valid_seed <= w_out_valid;
    end
    else begin
        dout_seed <= 'd0;
        dout_valid_seed <= 1'b0;
    end
end

always_ff @(posedge clk) begin
    if (!rstn) 
        start_out_seed <= 1'b0;
    else if (substate_d == S_SUB_LOAD && substate == S_SUB_SQUEEZE)
        start_out_seed <= 1'b1;
    else if (substate_d == S_SUB_LOAD_C_TILDE_W1_BYTES && substate == S_SUB_SQUEEZE_C_TILDE)
        start_out_seed <= 1'b1;
    else 
        start_out_seed <= 1'b0;
end

always_ff @(posedge clk) begin			// 拼接扩展后的种子 一共128Byte，每次扩展输出8Byte
    if (!rstn) begin
        seed_expand <= 'd0;
        seed_expand_cnt <= 'd0;
    end
    else if (state == S_INIT) begin
        seed_expand <= 'd0;
        seed_expand_cnt <= 'd0;
    end
    else if (substate == S_SUB_SQUEEZE) begin		
        if (st_64bit_valid_seed) begin
            seed_expand <= (seed_expand << 64) | st_64bit_seed;
            seed_expand_cnt <= seed_expand_cnt + 'd8;
        end
    end
end

always_comb begin						// 扩展种子、矩阵A、向量S1、S2可能会复用端口 此处对端口进行分配 分配依据为状态机变量
    dout1 = 'd0; dout_valid1 = 'd0; dout_len1 = 'd0; mdlen1 = 'd0;
    init1 = 'd0; start1 = 'd0; start_out1 = 'd0; out_len1 = 'd0;
    
    dout2 = 'd0; dout_valid2 = 'd0; dout_len2 = 'd0; mdlen2 = 'd0;
    init2 = 'd0; start2 = 'd0; start_out2 = 'd0; out_len2 = 'd0;

    done_ExpandA = 'd0; done_out_ExpandA = 'd0; st_64bit_ExpandA = 'd0; st_64bit_valid_ExpandA = 'd0;
    done_seed    = 'd0; done_out_seed    = 'd0; st_64bit_seed    = 'd0; st_64bit_valid_seed    = 'd0;
    done_ExpandY = 'd0; done_out_ExpandY = 'd0; st_64bit_ExpandY = 'd0; st_64bit_valid_ExpandY = 'd0;
    
    if (state == S_EXPAND_A || state == S_STORE_A) begin
        // ==========================================
        // 状态为 EXPAND_A 时，SHA3-1 分配给 ExpandA
        // ==========================================
        dout1       = dout_ExpandA; 
        dout_valid1 = dout_valid_ExpandA; 
        dout_len1   = dout_len_ExpandA; 
        mdlen1      = mdlen_ExpandA; 
        init1       = init_ExpandA; 
        start1      = start_ExpandA; 
        start_out1  = start_out_ExpandA; 
        out_len1    = out_len_ExpandA; 
        
        done_ExpandA           = done1; 
        done_out_ExpandA       = done_out1; 
        st_64bit_ExpandA       = st_64bit1; 
        st_64bit_valid_ExpandA = st_64bit_valid1; 
    end

    if (state >= S_EXPAND_Y && state <= S_STORE_Y) begin
        // ==========================================
        // 状态为 EXPAND_Y 时，SHA3-1 分配给 ExpandY
        // ==========================================
        dout1       = dout_ExpandY; 
        dout_valid1 = dout_valid_ExpandY; 
        dout_len1   = dout_len_ExpandY; 
        mdlen1      = mdlen_ExpandY; 
        init1       = init_ExpandY; 
        start1      = start_ExpandY; 
        start_out1  = start_out_ExpandY; 
        out_len1    = out_len_ExpandY; 
        
        done_ExpandY           = done1; 
        done_out_ExpandY       = done_out1; 
        st_64bit_ExpandY       = st_64bit1; 
        st_64bit_valid_ExpandY = st_64bit_valid1;
    end

    if (substate <= S_SUB_SQUEEZE_C_TILDE) begin
        // ==========================================
        // 状态为 EXPAND_seed 时，SHA3-2 分配给 Expand_seed
        // ==========================================
        dout2       = dout_seed;
        dout_valid2 = dout_valid_seed;
        dout_len2   = dout_len_seed;
        mdlen2      = mdlen_seed;
        init2       = init_seed;
        start2      = start_seed;
        start_out2  = start_out_seed;
        out_len2    = out_len_seed;

        done_seed           = done2;
        done_out_seed       = done_out2;
        st_64bit_seed       = st_64bit2;
        st_64bit_valid_seed = st_64bit_valid2;    
    end

    if (state >= S_EXPAND_C && state <= S_STORE_C) begin
        // ==========================================
        // 状态为 EXPAND_C 时，SHA3-2 分配给 Expand_C
        // ==========================================
        dout2       = dout_ExpandC;
        dout_valid2 = dout_valid_ExpandC;
        dout_len2   = dout_len_ExpandC;
        mdlen2      = mdlen_ExpandC;
        init2       = init_ExpandC;
        start2      = start_ExpandC;
        start_out2  = start_out_ExpandC;
        out_len2    = out_len_ExpandC;

        done_ExpandC           = done2;
        done_out_ExpandC       = done_out2;
        st_64bit_ExpandC       = st_64bit2;
        st_64bit_valid_ExpandC = st_64bit_valid2;   
    end

end

//* ==========================================================
//* 8. 独立读取 RHO 和 K 种子的逻辑
//* ==========================================================
always_ff @(posedge clk) begin
    if (!rstn) begin
        fetch_cnt <= 'd0;
        fetch_valid <= 1'b0;
    end 
    else if (state == S_PREPROC_NTT_STORE && poly_cnt == TOTAL_POLYS - 1) begin
        fetch_cnt <= 'd0;
        fetch_valid <= 1'b0;
    end 
    else if (state == S_PREPROC_GET_RHO) begin
        // 发出 16 个读取请求，计数器加到 17 是为了覆盖 BRAM 的 1 拍读出延迟
        if (fetch_cnt < 5'd17) 
            fetch_cnt <= fetch_cnt + 1'b1;
            
        // 标记有效的数据接收窗口
        fetch_valid <= (fetch_cnt < 5'd16);
    end
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        rho <= 'd0;
        k_seed <= 'd0;
        save_cnt <= 'd0;
    end 
    else if (state == S_PREPROC_NTT_STORE && poly_cnt == TOTAL_POLYS - 1) begin
        save_cnt <= 'd0;
    end 
    else if (state == S_PREPROC_GET_RHO && fetch_valid) begin
        save_cnt <= save_cnt + 1'b1;
        if (save_cnt < 5'd8)
            tr_seed <= {tr_seed[447:0], r_EncodeSK_Coeff};
        else if (save_cnt < 5'd12)
            rho <= {rho[191:0], r_EncodeSK_Coeff};      // 前 4 块属于 rho
        else
            k_seed <= {k_seed[191:0], r_EncodeSK_Coeff};// 后 4 块属于 k_seed
    end
end

//* ==========================================================
//* 9. ExpandA 控制逻辑
//* ==========================================================
assign rho_ExpandA = {<<8{rho}};
always_ff @(posedge clk) begin
    if (!rstn)
        start_expand_ExpandA <= 1'b0;
    else if (state == S_EXPAND_A)  
        start_expand_ExpandA <= 1'b1;
    else 
        start_expand_ExpandA <= 1'b0;
end

//* ==========================================================
//* 10. ExpandY 控制逻辑
//* ==========================================================
assign rho_prime_ExpandY = {<<8{seed_expand}};
always_ff @(posedge clk) begin
    if (!rstn)
        start_expand_ExpandY <= 1'b0;
    else if (state == S_EXPAND_Y)  
        start_expand_ExpandY <= 1'b1;
    else 
        start_expand_ExpandY <= 1'b0;
end

ExpandY u_ExpandY(
	.clk            	( clk                     ),
	.rstn           	( rstn                    ),

	.rho_prime      	( rho_prime_ExpandY       ),
	.kappa          	( kappa_ExpandY           ),
	.start_expand   	( start_expand_ExpandY    ),

	.coeff          	( coeff_ExpandY           ),
	.coeff_valid    	( coeff_valid_ExpandY     ),

	.expand_done    	( expand_done_ExpandY     ),

	.dout           	( dout_ExpandY            ),
	.dout_valid     	( dout_valid_ExpandY      ),
	.dout_len       	( dout_len_ExpandY        ),
	.mdlen          	( mdlen_ExpandY           ),
	.init           	( init_ExpandY            ),
	.start          	( start_ExpandY           ),
	.done           	( done_ExpandY            ),
	.start_out      	( start_out_ExpandY       ),
	.out_len        	( out_len_ExpandY         ),
	.done_out       	( done_out_ExpandY        ),
	.st_64bit       	( st_64bit_ExpandY        ),
	.st_64bit_valid 	( st_64bit_valid_ExpandY  )
);

//* ==========================================================
//* 11. MAC 控制逻辑
//* ==========================================================
assign conv[0] = con_coeff_d[23 * 0 +: 23];
assign conv[1] = con_coeff_d[23 * 1 +: 23];
assign conv[2] = con_coeff_d[23 * 2 +: 23];
assign conv[3] = con_coeff_d[23 * 3 +: 23];
logic   [22 : 0]    temp0, temp1, temp2, temp3;
assign temp0 = r_VectorM_Coeff_INTT[23 * 0 +: 23];
assign temp1 = r_VectorM_Coeff_INTT[23 * 1 +: 23];
assign temp2 = r_VectorM_Coeff_INTT[23 * 2 +: 23];
assign temp3 = r_VectorM_Coeff_INTT[23 * 3 +: 23];

always_ff @(posedge clk) begin
    if (!rstn) begin
        con_coeff_d <= 'd0;
        con_coeff_valid_d <= 1'b0;
    end
    else begin
        con_coeff_d <= con_coeff;
        con_coeff_valid_d <= con_coeff_valid;
    end
end

always_comb begin
    if (state >= S_MULT_INTT && state <= S_MULT_INTT_WAIT) begin
        case (mac_stage)
            'd0 : begin 
                mac_data_in1[0] = r_c_hat;
                mac_data_in2 = r_VectorS1_Coeff;
                mac_data_in3[0] = 'd0;
            end
            'd1 : begin
                mac_data_in1[0] = r_c_hat;
                mac_data_in2 = r_VectorS2_Coeff[r_VectorS2_Coeff_addr_global_d[8 : 6]];
                mac_data_in3[0] = 'd0;
            end
            'd2 : begin
                mac_data_in1[0] = r_c_hat;
                mac_data_in2 = r_VectorT_Coeff[r_VectorT_Coeff_addr_global_d[8 : 6]];
                mac_data_in3[0] = 'd0;
            end
            default : begin
                mac_data_in1[0] = 'd0;
                mac_data_in2 = 'd0;
                mac_data_in3[0] = 'd0;
            end
        endcase
        mult_res = mac_data_out[0];
        mult_res_valid = mac_valid_out;
        mac_valid_in = mac_valid;
    end
    else begin
        for (int i = 0 ; i < K ; i = i + 1) begin
            // 输出给 MAC 的操作数
            mac_data_in1[i] = r_MatrixA_Coeff[i];
            mac_data_in3[i] = ('d1 <= con_coeff_cnt && con_coeff_cnt <= 'd64) ? 92'd0 : r_VectorM_Coeff[i];
            
            // 接收来自 MAC 的结果
            valid_out[i] = mac_valid_out;
            mac_out_comb[i] = mac_data_out[i];
        end
        mac_valid_in = con_coeff_valid_d && state < S_M_INTT_ACK;
        mac_data_in2 = con_coeff_d;
    end
end

always_ff @(posedge clk) begin
    if (!rstn)
        mult_res_valid_d <= 1'b0;
    else 
        mult_res_valid_d <= mult_res_valid;
end

always_comb begin
	for (int i = 0 ; i < K ; i = i + 1) begin
		w_VectorM_Coeff_valid[i] = 1'b0;
		w_VectorM_Coeff[i] = 'd0;
	end
	if (S_Y_NTT_ACK <= state && state <= S_MATRIX_MULT_WAIT) begin
		for (int i = 0 ; i < K ; i = i + 1) begin
			w_VectorM_Coeff_valid[i] = valid_out[i];
			w_VectorM_Coeff[i] = mac_out_comb[i];
 		end
	end
    else if (state <= S_DUMMY0) begin
        for (int i = 0 ; i < K ; i = i + 1) begin
            if (i == con_coeff_cnt[8 : 6])
                w_VectorM_Coeff_valid[i] = m_valid;
            else 
                w_VectorM_Coeff_valid[i] = 1'b0;
            
            w_VectorM_Coeff[i] = m;
        end
    end
end

always_ff @(posedge clk) begin : w_VectorW_Coeff_valid_delay
    if (!rstn) begin
		for (int i = 0 ; i < K ; i = i + 1)
        	w_VectorM_Coeff_valid_d[i] <= 1'b0;
	end
    else begin
		for (int i = 0 ; i < K ; i = i + 1)
        	w_VectorM_Coeff_valid_d[i] <= w_VectorM_Coeff_valid[i];
	end
end

always_ff @(posedge clk) begin
    if (!rstn)
        r_VectorM_Coeff_addr_global <= 'd0;
    else if (state >= S_MULT_INTT && state <= S_MULT_INTT_WAIT && mac_stage == 'd1) begin
        if (con_coeff_valid) begin
            if (r_VectorM_Coeff_addr_global == `k * 64 - 1)
                r_VectorM_Coeff_addr_global <= 'd0;
            else
                r_VectorM_Coeff_addr_global <= r_VectorM_Coeff_addr_global + 1'b1;
        end
        else
            r_VectorM_Coeff_addr_global <= r_VectorM_Coeff_addr_global;
    end
    else
        r_VectorM_Coeff_addr_global <= r_VectorM_Coeff_addr_global;
end

always_ff @(posedge clk) begin
    if (!rstn)
        r_VectorM_Coeff_addr_global_d <= 'd0;
    else 
        r_VectorM_Coeff_addr_global_d <= r_VectorM_Coeff_addr_global;
end

always_comb begin : matrix_A_vector_T_read_control
    for (int i = 0 ; i < K ; i = i + 1) begin
        r_MatrixA_Coeff_addr[i] = 'd0;
        r_VectorM_Coeff_addr[i] = 'd0;
    end
    if (S_Y_NTT_ACK <= state && state <= S_MATRIX_MULT_WAIT && con_coeff_valid) begin		// 取出 A 和上一阶段计算好的T 利用NTT(S1) 计算T_prime+A*S1的MAC结果
        for (int i = 0 ; i < K ; i = i + 1) begin	
            r_MatrixA_Coeff_addr[i] = con_coeff_cnt;
            r_VectorM_Coeff_addr[i] = con_coeff_cnt[5 : 0];
        end
    end
    if (state > S_MATRIX_MULT_WAIT && state <= S_M_INTT_WAIT)
        for (int i = 0 ; i < K ; i = i + 1) 
            r_VectorM_Coeff_addr[i] =  r_VectorM_Coeff_addr_INTT[5 : 0];
    if (state >= S_MULT_INTT && state <= S_MULT_INTT_WAIT)
        for (int i = 0 ; i < K ; i = i + 1) 
            r_VectorM_Coeff_addr[i] = r_VectorM_Coeff_addr_global[5 : 0];
end

always_ff @(posedge clk) begin : vector_m_write_control
    if (!rstn) begin
        for (int i = 0 ; i < K ; i = i + 1)
            w_VectorM_Coeff_addr[i] <= 'd0;
    end
    else if (state == S_IDLE) begin   
        for (int i = 0 ; i < K ; i = i + 1)
            w_VectorM_Coeff_addr[i] <= 'd0;
    end
    else if ((w_VectorM_Coeff_valid[0] && state <= S_MATRIX_MULT_WAIT) ) begin		// 矩阵乘法阶段 根据MAC的输出有效信号更新存储T的地址	
        for (int i = 0 ; i < K ; i = i + 1) begin
            if (w_VectorM_Coeff_addr[i] == 'd63)
                w_VectorM_Coeff_addr[i] <= 'd0;
            else
                w_VectorM_Coeff_addr[i] <= w_VectorM_Coeff_addr[i] + 1'b1;
        end
    end
    else if (state <= S_DUMMY0) begin
        for (int i = 0 ; i < K ; i = i + 1) begin
            if (m_valid)
                w_VectorM_Coeff_addr[i] <= w_VectorM_Coeff_addr[i] + 1'b1;
            else 
                w_VectorM_Coeff_addr[i] <= w_VectorM_Coeff_addr[i];
        end
    end
    else begin
        for (int i = 0 ; i < K ; i = i + 1)
            w_VectorM_Coeff_addr[i] <= w_VectorM_Coeff_addr[i];
    end
end

always_ff @(posedge clk) begin
    if (!rstn) 
        r_VectorM_Coeff_addr_INTT <= 'd0;
    else if (state == S_M_INTT) begin		// 从存储矩阵中读取 M 并装载到 SHA3 中 进行 INTT 变换
        if (r_VectorM_Coeff_addr_INTT == `k * 64) 
            r_VectorM_Coeff_addr_INTT <= 'd0;
        else if (r_VectorM_Coeff_addr_INTT > 0 && r_VectorM_Coeff_addr_INTT[5 : 0] == 0) 
            r_VectorM_Coeff_addr_INTT <= r_VectorM_Coeff_addr_INTT;
        else 
            r_VectorM_Coeff_addr_INTT <= r_VectorM_Coeff_addr_INTT + 1'b1;
    end
    else if (state > S_MATRIX_MULT_WAIT && ready == 1'b0 && request == 1'b1) 
        r_VectorM_Coeff_addr_INTT <= r_VectorM_Coeff_addr_INTT + 1'b1;
    else 
        r_VectorM_Coeff_addr_INTT <= r_VectorM_Coeff_addr_INTT;
end

always_ff @(posedge clk) begin				// 向量 M 存储时时按行存储的 低5位表示列 高3位表示行
    if (!rstn)
        r_VectorM_Coeff_addr_INTT_d <= 'd0;
    else 
        r_VectorM_Coeff_addr_INTT_d <= r_VectorM_Coeff_addr_INTT;
end

assign r_VectorM_Coeff_INTT = r_VectorM_Coeff[r_VectorM_Coeff_addr_INTT_d[8 : 6]]; // 读取需要一个时钟周期 因此这里对地址打一拍后再根据高三位取行
assign m_valid = con_coeff_valid & (state >= S_MATRIX_MULT_WAIT && state <= S_DUMMY0);
assign m = con_coeff;

// --- mult_intt ---

// mac计数器
always_ff @(posedge clk) begin
    if (!rstn) 
        mac_cnt <= 'd0;
    else if (state == S_SIGN_LOOP_INIT)
        mac_cnt <= 'd0;
    else if (state == S_MULT_INTT_WAIT)
        mac_cnt <= 'd0;
    else if (state == S_MULT_INTT) begin
        if (mac_cnt == 'd63)
            mac_cnt <= mac_cnt;
        else 
            mac_cnt <= mac_cnt + 1'b1;
    end
    else 
        mac_cnt <= mac_cnt;
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        r_VectorS1_Coeff_addr <= 'd0;
        r_VectorS2_Coeff_addr_global <= 'd0;
        r_VectorT_Coeff_addr_global <= 'd0;
    end
    else if (state == S_SIGN_LOOP_INIT) begin
        r_VectorS1_Coeff_addr <= 'd0;
        r_VectorS2_Coeff_addr_global <= 'd0;
        r_VectorT_Coeff_addr_global <= 'd0;
    end
    else if (state == S_MULT_INTT) begin
        if (r_VectorS1_Coeff_addr == `l * 64 - 1)
            r_VectorS1_Coeff_addr <= 'd0;
        else
            r_VectorS1_Coeff_addr <= r_VectorS1_Coeff_addr + 1'b1;
        if (r_VectorS2_Coeff_addr_global == `k * 64 - 1)
            r_VectorS2_Coeff_addr_global <= 'd0;
        else 
            r_VectorS2_Coeff_addr_global <= r_VectorS2_Coeff_addr_global + 1'b1;
        if (r_VectorT_Coeff_addr_global == `k * 64 - 1)
            r_VectorT_Coeff_addr_global <= 'd0;
        else 
            r_VectorT_Coeff_addr_global <= r_VectorT_Coeff_addr_global + 1'b1;
    end
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        r_VectorS2_Coeff_addr_global_d <= 'd0;
        r_VectorT_Coeff_addr_global_d <= 'd0;
    end
    else begin
        r_VectorS2_Coeff_addr_global_d <= r_VectorS2_Coeff_addr_global;
        r_VectorT_Coeff_addr_global_d <= r_VectorT_Coeff_addr_global;
    end
end

always_comb begin
    for (int i = 0 ; i < K ; i = i + 1) begin
        r_VectorS2_Coeff_addr[i] = 'd0;
        r_VectorT_Coeff_addr[i] = 'd0;
    end
    if (state == S_MULT_INTT) begin
        for (int i = 0 ; i < K ; i = i + 1) begin
            r_VectorS2_Coeff_addr[i] = r_VectorS2_Coeff_addr_global[5 : 0];
            r_VectorT_Coeff_addr[i] = r_VectorT_Coeff_addr_global[5 : 0];
        end
    end
end

assign r_c_hat_addr = mac_cnt;

always_ff @(posedge clk) begin
    if (!rstn)
        mac_valid <= 1'b0;
    else if (state == S_MULT_INTT)
        mac_valid <= 1'b1;
    else 
        mac_valid <= 1'b0;
end

//* ==========================================================
//* 12. high_bits(decompose)
//* ==========================================================
generate
    for (genvar i = 0 ; i < 4 ; i = i + 1) begin
        assign r[i] = {2'b0, m[23 * i +: 23]};
        assign r_valid[i] = m_valid;
        if (`gamma_2 == 95232) begin
            Decomposes u_Decomposes(
                .clk      	( clk          ),
                .rstn     	( rstn         ),
                .r        	( r[i]         ),
                .r_valid  	( r_valid[i]   ),
                .r1       	( r1[i]        ),
                .r1_valid 	( r1_valid[i]  ),
                .r0       	( r0[i]        ),
                .r0_valid 	( r0_valid[i]  )
            );
        end
        else begin
            Decomposes2 u_Decomposes2(
                .clk      	( clk          ),
                .rstn     	( rstn         ),
                .r        	( r[i]         ),
                .r_valid  	( r_valid[i]   ),
                .r1       	( r1[i]        ),
                .r1_valid 	( r1_valid[i]  ),
                .r0       	( r0[i]        ),
                .r0_valid 	( r0_valid[i]  )
            );
        end
    end
endgenerate

Serializer u_Serializer(
	.clk         	( clk          ),
	.rstn        	( rstn         ),
	.w_in_0      	( r1[0]        ),
	.w_in_1      	( r1[1]        ),
	.w_in_2      	( r1[2]        ),
	.w_in_3      	( r1[3]        ),
	.w_in_valid  	( r1_valid[0]  ),
	.w_out       	( w_out        ),
	.w_out_valid 	( w_out_valid  )
);

//* ==========================================================
//* 13. c_tilde
//* ==========================================================

always_ff @(posedge clk) begin
    if (!rstn)
        c_tilde <= 'd0;
    else if (state == S_SIGN_LOOP_INIT)
        c_tilde <= 'd0;
    else if (substate == S_SUB_SQUEEZE_C_TILDE) begin
        if (st_64bit_valid_seed)
            c_tilde <= (c_tilde << 64) | st_64bit_seed;
        else 
            c_tilde <= c_tilde;
    end
    else
        c_tilde <= c_tilde;
end

//* ==========================================================
//* 14. ExpandC
//* ==========================================================
assign tau_ExpandC = `tau;
assign seed_ExpandC = {<<8{c_tilde}};
always_ff @(posedge clk) begin
    if (!rstn)
        start_expand_ExpandC <= 1'b0;
    else if (state == S_EXPAND_C)   
        start_expand_ExpandC <= 1'b1;
    else 
        start_expand_ExpandC <= 1'b0;
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        low_rd_en_ExpandC <= 1'b0;
        high_rd_en_ExpandC <= 1'b0;
    end
    else if (state == S_SIGN_LOOP_INIT) begin
        low_rd_en_ExpandC <= 1'b0;
        high_rd_en_ExpandC <= 1'b0;
    end
    else if (state == S_C_NTT) begin
        low_rd_en_ExpandC <= 1'b1;
        high_rd_en_ExpandC <= 1'b1;
    end
    else begin
        low_rd_en_ExpandC <= 1'b0;
        high_rd_en_ExpandC <= 1'b0;
    end
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        coeff_low_add_ExpandC <= 'd0;
        coeff_high_add_ExpandC <= 'd1;
    end
    else if (state == S_SIGN_LOOP_INIT) begin
        coeff_low_add_ExpandC <= 'd0;
        coeff_high_add_ExpandC <= 'd1;
    end
    else if (state == S_C_NTT) begin
        if (low_rd_en_ExpandC) begin
            if (coeff_low_add_ExpandC == 254)
                coeff_low_add_ExpandC <= 'd0;
            else
                coeff_low_add_ExpandC <= coeff_low_add_ExpandC + 'd2;
        end
        if (high_rd_en_ExpandC) begin
            if (coeff_high_add_ExpandC == 255)
                coeff_high_add_ExpandC <= 'd1;
            else
                coeff_high_add_ExpandC <= coeff_high_add_ExpandC + 'd2;
        end
    end
    else begin
        coeff_low_add_ExpandC <= coeff_low_add_ExpandC;
        coeff_high_add_ExpandC <= coeff_high_add_ExpandC;
    end
end

always_ff @(posedge clk) begin
    if (!rstn)
        data_cnt <= 'd0;
    else if (state == S_SIGN_LOOP_INIT)
        data_cnt <= 'd0;
    else if (data_valid_out) begin
        if (data_cnt == 'd63)
            data_cnt <= 'd0;
        else
            data_cnt <= data_cnt + 'd1;
    end
    else 
        data_cnt <= data_cnt;
end

// --- c_hat 存储器 ---
initial begin
    for (int i = 0; i < 64; i = i + 1)
        c_hat[i] <= 'd0;
end

always_ff @(posedge clk) begin
    if (state == S_C_NTT_WAIT && con_coeff_valid)
        c_hat[con_coeff_cnt] <= con_coeff;
    else 
        c_hat[con_coeff_cnt] <= c_hat[con_coeff_cnt];
    r_c_hat <= c_hat[r_c_hat_addr];
end

// --- 每次只能同时读出2个C系数 这里将C系数对q取模并4个为一组进行输出 ---
Gearbox_2to4 u_Gearbox_2to4(
    .clk                (clk                        ),
    .rstn               (rstn                       ),
    .data_low           (coeff_low_ExpandC          ),
    .data_high          (coeff_high_ExpandC         ),
    .data_valid         (coeff_low_valid_ExpandC    ),
    .data_out           (data_out                   ),
    .data_valid_out     (data_valid_out             )
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

//* ==========================================================
//* 15. Rejection
//* ==========================================================

postMultCalc u_postMultCalc(
	.clk           	( clk                       ),
	.rstn          	( rstn                      ),
	.y             	( r_VectorY_Coeff           ),
	.y_valid       	( con_coeff_valid_d && (state_d >= S_MULT_INTT_ACK && state_d <= S_MULT_INTT_WAIT) && (mac_stage_d == 'd0)        ),
	.w             	( r_VectorM_Coeff[r_VectorM_Coeff_addr_global_d[8 : 6]]        ),
	.w_valid       	( con_coeff_valid_d && (state_d >= S_MULT_INTT_ACK && state_d <= S_MULT_INTT_WAIT) && (mac_stage_d == 'd1)        ),
	.c_s1          	( con_coeff_d                 ),
	.c_s1_valid    	( con_coeff_valid_d && (state_d >= S_MULT_INTT_ACK && state_d <= S_MULT_INTT_WAIT) && (mac_stage_d == 'd0)        ),
	.c_s2          	( con_coeff_d                 ),
	.c_s2_valid    	( con_coeff_valid_d && (state_d >= S_MULT_INTT_ACK && state_d <= S_MULT_INTT_WAIT) && (mac_stage_d == 'd1)        ),
	.c_t0          	( con_coeff_d                 ),
	.c_t0_valid    	( con_coeff_valid_d && (state_d >= S_MULT_INTT_ACK && state_d <= S_MULT_INTT_WAIT) && (mac_stage_d == 'd2)        ),
	.mac_stage     	( mac_stage_d                 ),
	.encode        	( encode                    ),
	.encoder_valid 	( encoder_valid             ),
	.reject_flag   	( reject_flag               )
);


endmodule