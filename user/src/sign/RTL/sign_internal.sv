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
typedef enum logic [4 : 0] { 
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
    S_Y_NTT_WAIT,
    S_Y_NTT,
    S_Y_NTT_STORE
    // 从W矩阵中读出多项式，并进行INTT逆变换 变换的结果同时取高位按字节pack后存入SHA3

} state_t;

state_t                             state, state_d;

typedef enum logic [4 : 0] { 
    S_SUB_IDLE,
    S_SUB_INIT,
    S_SUB_LOAD,
    S_SUB_SQUEEZE,                  // 获得rho_prime(seed_expand)
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

//* ==========================================================
//* 3. 状态机
//* ==========================================================

always_ff @(posedge clk) begin
    if (!rstn) begin
        state <= S_IDLE;
        poly_cnt <= 'd0;
        kappa_ExpandY <= 'd0;
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
            end
            S_EXPAND_Y : begin
                state <= S_STORE_Y;
            end
            S_STORE_Y : begin
                if (expand_done_ExpandY)
                    state <= S_Y_NTT_ACK;
                else
                    state <= S_STORE_Y;
            end
            S_Y_NTT_ACK : begin
                if (ready == 1'b0 && request == 1'b1)
                    state <= S_Y_NTT;
                else 
                    state <= S_Y_NTT_ACK;
                kappa_ExpandY <= kappa_ExpandY + L;
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
                        state <= S_IDLE;
                    else
                        state <= S_Y_NTT_ACK;
                end
                else
                    state <= S_Y_NTT_WAIT;
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
                    substate <= S_SUB_INIT_C_TILDE;
                else 
                    substate <= S_SUB_SQUEEZE;
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
    else if (state >= S_Y_NTT_ACK && ready == 1'b0 && request == 1'b1)
        r_VectorY_Coeff_addr <= r_VectorY_Coeff_addr + 1'b1;
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
end

//* ==========================================================
//* 5. Poly_PAU 控制逻辑
//* ==========================================================
assign ext_operand = 'd0;
assign mode_config = 'd0; // 预处理阶段都是 NTT (0)

always_ff @(posedge clk) begin
    if (!rstn)
        request <= 1'b0;
    else if (state == S_PREPROC_NTT_ACK || state == S_Y_NTT_ACK) begin
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
    else if (state == S_PREPROC_NTT_ACK || state == S_SIGN_LOOP_INIT)
        con_coeff_cnt <= 'd0;  // 每次握手前清零
    else if (con_coeff_valid) begin
        if (state <= S_Y_NTT_WAIT && con_coeff_cnt == `l * 64 - 1)
            con_coeff_cnt <= 'd0;
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
        out_len_seed = 'd32;
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
        dout_valid_seed <= 1'b1;
        seed_domain_sep <= seed_domain_sep << 8;
    end
    else if (substate == S_SUB_LOAD_C_TILDE_W1_BYTES) begin
        //**********************************!
        dout_valid_seed <= 1'b0;
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
        // 状态为 EXPAND_Y 时，SHA3-1 分配给 ExpandA
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

endmodule