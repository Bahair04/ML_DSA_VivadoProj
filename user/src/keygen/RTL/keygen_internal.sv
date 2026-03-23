`include "../../param_conf.v"
module keygen_internal
#(
    parameter           K = `k,
    parameter           L = `l
)(
    // --- 时钟和复位信号 ---
	input       logic                       clk,
    input       logic                       rstn,

	// --- 控制标志位 ---
	input       logic                       start,          // 启动标志
	output      logic                       key_ready,      // 准备标志
	output      logic                       done,           // 完成标志

	// --- 输入输出数据 ---
	input       logic           [255 : 0]   zeta,           // 32字节 种子
	output      logic           [7 : 0]     pk,             // 单字节 公钥
	output      logic           [7 : 0]     sk,             // 单字节 私钥

    // --- BRAM 总线信号 ---
    output      logic           [91 : 0]    w_MatrixA_Coeff,
    output      logic                       w_MatrixA_Coeff_valid,
    output      logic           [11 : 0]    w_MatrixA_Coeff_addr,
    input       logic           [91 : 0]    r_MatrixA_Coeff [0 : K - 1],
    output      logic           [8 : 0]     r_MatrixA_Coeff_addr [0 : K - 1],

    output      logic   signed  [15 : 0]    w_VectorS1_Coeff,                   // 4*4bit有符号数
    output      logic                       w_VectorS1_Coeff_valid,
    output      logic           [8 : 0]     w_VectorS1_Coeff_addr,
    input       logic           [91 : 0]    r_VectorS1_Coeff,                   // 对q取模 无符号
    output      logic           [8 : 0]     r_VectorS1_Coeff_addr,

    output      logic   signed  [15 : 0]    w_VectorS2_Coeff,                   // 4*4bit有符号数
    output      logic                       w_VectorS2_Coeff_valid,
    output      logic           [8 : 0]     w_VectorS2_Coeff_addr,
    input       logic           [91 : 0]    r_VectorS2_Coeff [0 : K - 1],       // 对q取模 无符号
    output      logic           [5 : 0]     r_VectorS2_Coeff_addr [0 : K - 1],

    output      logic           [91 : 0]    w_VectorT_Coeff [0 : K - 1],
    output      logic                       w_VectorT_Coeff_valid [0 : K - 1],
    output      logic           [5 : 0]     w_VectorT_Coeff_addr [0 : K - 1],
    input       logic           [91 : 0]    r_VectorT_Coeff [0 : K - 1],
    output      logic           [5 : 0]     r_VectorT_Coeff_addr [0 : K - 1],

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
    output      logic           [91 : 0]    ori_coeff,					// 向Poly_PAU填充原始系数
    output      logic                       ori_coeff_valid,			// 原始系数有效信号
    output      logic                       request,                    // 上游请求信号
    output      logic           [91 : 0]    ext_operand,                // 外部输入的计算数
    input       logic                       ext_operand_request,        // 请求获取外部输入的计算数
    output      logic           [4 : 0]     mode_config,                // 模式选择 0: NTT 1: INTT 2: 模乘 3: 模加 4: 模减

    input       logic                       ready,                      // 下游准备信号
    input       logic           [91 : 0]    con_coeff,					// NTT/INTT 结果输出
    input       logic                       con_coeff_valid,			// NTT/INTT 输出有效信号

    // --- MAC 阵列接口 ---
    output      logic                       mac_valid_in_keygen,
    output      logic           [91 : 0]    mac_data_in1_keygen [0 : K - 1],
    output      logic           [91 : 0]    mac_data_in2_keygen,
    output      logic           [91 : 0]    mac_data_in3_keygen [0 : K - 1],
    input       logic                       mac_valid_out_keygen,
    input       logic           [91 : 0]    mac_data_out_keygen [0 : K - 1],

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

// ==========================================================
// 1. 参数与状态定义
// ==========================================================
typedef enum logic [4 : 0] {  
    S_IDLE,             // 空闲等待
    S_INIT,             // 初始化 存储种子[seed, `k, `l]
    S_LOAD,             // 给 SHA3 装载种子
    S_SQUEEZE,          // 挤出数据 获取扩展种子 用于生成矩阵A，向量S
    S_EXPAND,           // 生成矩阵 A 和向量 S 此状态给出起始信号
    S_STORE,            // 获得矩阵 A 和向量 S 并存入存储空间
    S_S1_NTT_ACK,       // 当前模块与 Poly_PAU 模块的握手状态
    S_S1_NTT,           // 从存储空间中获得一组 S（256个系数） 存入 Poly_PAU 当中 并启动 NTT 转换
    S_S1_NTT_WAIT,      // 等待 NTT 转换完成 输出 64 个 92bits数据 (共 `l * 64 个系数)
    S_MATRIX_MULT_WAIT, // 等待矩阵乘法完成 因为 ModuleMAC有 8 级流水线延迟 所以在 S_S1_NTT_WAIT 状态转到 S_MATRIX_MULT_WAIT 后 还要等待
                        // (7-1=)6个时钟周期才能到 S_T_INTT 状态 以开始注入 T 向量 并进行 INTT 变换
    S_T_INTT_ACK,       // 当前模块与 Poly_PAU 模块的握手状态
    S_T_INTT,           // 从存储空间中获得一组 T（256个系数） 存入 Poly_PAU 当中 并启动 INTT 变换
    S_T_INTT_WAIT,      // 等待 INTT 转换完成 输出 64 个 92bits数据 (共 `k * 64 个系数)
    S_T_ADD_S2          // 在系数与 T + S2 获得最终的 T 同时给到 power_2_bound 获得 t0 和 t1
} state_t;

state_t                             state, state_d;

// ==========================================================
// 2. 内部信号统一定义
// ==========================================================

// --- Seed 处理信号 ---
logic           [271 : 0]           seed_domain_sep;     // 34 字节输入原始种子
logic           [1023 : 0]          seed_expand;         // 128 字节扩展种子
logic           [7 : 0]             seed_expand_cnt;     // 扩展种子字节计数器 一次输出8字节 所以计数器每次 +8
logic           [5 : 0]             seed_load_cnt;       // 输入种子字节计数器

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

// --- ExpandS 信号 ---
logic           [511 : 0]           rho_ExpandS;            // 256位随机种子
logic                               start_expand_ExpandS;   // 开始扩展S矩阵信号
logic           [91 : 0]            coeff_ExpandS;          // 4*23bit 有效采样系数
logic                               coeff_valid_ExpandS;    // 4*23bit 有效采样系数信号
logic                               expand_done_ExpandS;    // 扩展完成信号
logic           [15 : 0]            nouce;         
logic   signed  [15 : 0]            coeff_raw;

logic           [7 : 0]             dout_ExpandS;           // SHA3 串行输入字节数据
logic                               dout_valid_ExpandS;     // SHA3 串行输入字节有效信号
logic           [31 : 0]            dout_len_ExpandS;       // SHA3 串行输入字节长度
logic           [7 : 0]             mdlen_ExpandS;          // SHA3 Hash长度
logic                               init_ExpandS;           // SHA3 初始化信号
logic                               start_ExpandS;          // SHA3 开始装载数据
logic                               done_ExpandS;           // SHA3 数据装载完成
logic                               start_out_ExpandS;      // SHA3 开始挤出数据
logic           [31 : 0]            out_len_ExpandS;        // SHA3 挤出数据长度
logic                               done_out_ExpandS;       // SHA3 挤出数据完成
logic           [63 : 0]            st_64bit_ExpandS;       // SHA3 挤出8字节数据
logic                               st_64bit_valid_ExpandS; // SHA3 挤出8字节数据有效信号

// --- BRAM 总线信号 ---
logic                               w_VectorT_Coeff_valid_d [0 : K - 1];
logic           [91 : 0]            r_VectorT_Coeff_INTT;
logic           [8 : 0]             r_VectorT_Coeff_addr_INTT;
logic           [8 : 0]             r_VectorT_Coeff_addr_INTT_d;

// --- NTT/INTT (Poly_PAU) 信号 ---
logic           [8 : 0]             con_coeff_cnt;              // 输出系数计数器 (NTT输出个数为`l * 64，INTT输出个数为`k * 64)
logic           [8 : 0]             con_coeff_cnt_d;			// 同时作为矩阵 A 和向量 S2 的读取地址 由于存在一个时钟周期的读延迟
																// 所以转换结果con_coeff以及有效信号需要延迟一个时钟周期
																// 且S2需要选择读取端口(`k中的哪一个), con_coeff_cnt的高三位用于选择
// --- MAC 阵列信号 ---
logic           [91 : 0]            con_coeff_d;
logic                               con_coeff_valid_d;
logic           [22 : 0]            conv [0 : 3];				// 分解 NTT/INTT 输出结果 同时处理四个 每个位宽 23 bit
logic           [22 : 0]            temp0, temp1, temp2, temp3;	// 临时变量 用于分解观察 T向量 输出结果 同时输出4个23bit系数

// --- ADD 阵列信号 ---
logic			[22 : 0]			S2 [0 : 3];

// ==========================================================
// 3. 状态机
// ==========================================================

always_ff @(posedge clk) begin
    if (!rstn)
        state <= S_IDLE;
    else begin
        case (state)
            S_IDLE : begin								// 等待起始信号 key_ready为输出信号 只有在空闲时才允许接收start信号 并进入处理状态
                if (start && key_ready)
                    state <= S_INIT;
                else 
                    state <= S_IDLE;
            end
            S_INIT : begin								// 初始化扩展种子的原始种子 并产生一个初始化信号给SHA3模块 准备装载SHA3
                state <= S_LOAD;
            end
            S_LOAD : begin								// 装载原始种子（32zeta+1`k+1`l）
                if (done_seed)
                    state <= S_SQUEEZE;
                else 
                    state <= S_LOAD;
            end
            S_SQUEEZE : begin							// 挤出数据 获取扩展种子 (128Byte)
                if (done_out_seed)
                    state <= S_EXPAND;
                else 
                    state <= S_SQUEEZE;
            end
            S_EXPAND : begin							// 扩展矩阵 A 和 向量 S1 S2
                state <= S_STORE;
            end
            S_STORE : begin								// 等待矩阵 A 扩展完成 然后取出 S1 NTT变换
                if (expand_done_ExpandA)
                    state <= S_S1_NTT_ACK;
                else
                    state <= S_STORE;
            end
            S_S1_NTT_ACK : begin						// 握手准备状态
                if (ready == 1'b0 && request == 1'b1)
                    state <= S_S1_NTT;
                else 
                    state <= S_S1_NTT_ACK;
            end
            S_S1_NTT : begin							// 取出 S1 进行装载
                if (r_VectorS1_Coeff_addr > 0 && r_VectorS1_Coeff_addr[5 : 0] == 0)  // r_VectorS1_Coeff_addr % 64 == 0
                    state <= S_S1_NTT_WAIT;
                else 
                    state <= S_S1_NTT;
            end
            S_S1_NTT_WAIT : begin						// 一组(256个系数)的NTT变换输出
                if (con_coeff_cnt[5 : 0] == 'd63) begin
                    if (con_coeff_cnt == `l * 64 - 1)	// `l 组变换完成就进入到下一状态 等待矩阵乘法完成
                        state <= S_MATRIX_MULT_WAIT;	// 因为 NTT结果输出和矩阵乘法是同时进行的 而矩阵乘法存在一定的延时
                    else 								// 故这里先进入一个等待过渡状态 同时也把S_MATRIX_MULT_WAIT这一状态作为一个分界线 
                        state <= S_S1_NTT_ACK;			// 用于区分后续从S2中取出数据并于T的INTT变换结果求和的类似过程
                end										// 否则就回到握手状态 准备下一组NTT变换
                else 
                    state <= S_S1_NTT_WAIT;
            end
            S_MATRIX_MULT_WAIT : begin					// w_VectorT_Coeff_valid为Module_MAC的输出有效信号 如果出现下降沿 则表明 MAC计算结束 进入下一个状态
                if (w_VectorT_Coeff_valid_d[0] && !w_VectorT_Coeff_valid[0])
                    state <= S_T_INTT_ACK;
                else 
                    state <= S_MATRIX_MULT_WAIT;
            end
            S_T_INTT_ACK : begin						// 握手准备状态
                if (ready == 1'b0 && request == 1'b1)
                    state <= S_T_INTT;
                else 
                    state <= S_T_INTT_ACK;
            end
            S_T_INTT : begin 					// 在A和NTT(S1)做矩阵乘法的过程中 计算结果T向量被同时存入了存储矩阵 
												// 此阶段就是从矩阵中取出一组t(每次取4个系数，一共256个系数，一共`k组) 
												// 装载入Poly_PAU模块 准备进行INTT变换
                if (r_VectorT_Coeff_addr_INTT > 0 && r_VectorT_Coeff_addr_INTT[5 : 0] == 0)  // r_VectorT_Coeff_addr % 64 == 0
                    state <= S_T_INTT_WAIT;
                else 
                    state <= S_T_INTT;
            end
            S_T_INTT_WAIT : begin				// 一组(256个系数)的INTT变换输出 同时从存储矩阵中取出S2与INTT(T)做加法运算再存回T的存储矩阵中
                if (con_coeff_cnt[5 : 0] == 'd63) begin
                    if (con_coeff_cnt == `k * 64 - 1)	// 一共`k组 全部转换完成后进入下一状态
                        state <= S_T_ADD_S2;			
                    else 								// 否则就回到握手状态 准备下一组INTT变换
                        state <= S_T_INTT_ACK;
                end
                else 
                    state <= S_T_INTT_WAIT;
            end
            S_T_ADD_S2 : begin
                state <= S_T_ADD_S2;   //*  pack/sha3 思路：生成s1和s2的同时使用一个pack0模块(先s1再s2，二者不会同时)
            end                        //*  t0和t1同时生成，分别用pack0和pack1模块生成字节流 存入BRAM
            default : begin            //*  s1和s2生成完毕后的接下来的阶段 同时把pk装载到SHA3中 再生成t1的时候，由于相邻两组t1之间存在着间隙
                state <= S_IDLE;       //*  可以再生成当前组t1的同时进行pack，pack的结果(8字节)存入FIFO 当FIFO非空时 从中取出单字节 装载入sha3
            end                        //*  由于相邻两个t的时钟周期约为(19+64)*4=332  而装载256*10字节为320个时钟周期  所以时间上是允许的
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
        key_ready <= 1'b1;
    else if (state == S_IDLE)
        key_ready <= 1'b1;G
    else 
        key_ready <= 1'b0;
end

always_ff @(posedge clk) begin
    if (!rstn)
        done <= 1'b0;
    else if (expand_done_ExpandA)
        done <= 1'b1;
    else 
        done <= 1'b0;
end


// ==========================================================
// 4. SHA3 控制逻辑与数据路由
// ==========================================================
assign out_len_seed = 'd128;			// 原始种子扩展 扩展后为128Byte
assign dout_len_seed = 'd34;			// 原始种子长度为 34Byte 需要按字节装载进SHA3
assign mdlen_seed = 'd32;				// 32-SHA256 16-SHA128 这里为SHA256

always_ff @(posedge clk) begin
    if (!rstn)
        start_seed <= 1'b0;
    else if (state == S_INIT)			// 起始信号 传递给SHA3
        start_seed <= 1'b1;
    else
        start_seed <= 1'b0;
end

assign init_seed = (state == S_INIT);	// 初始化信号 传递给SHA3 组合逻辑 比start_seedt提前一个时钟周期

always_ff @(posedge clk) begin
    if (!rstn) begin
        dout_seed <= 'd0;
        dout_valid_seed <= 1'b0;
        seed_domain_sep <= 'd0;
        seed_load_cnt <= 'd0;
    end
    else if (state == S_INIT) begin		// 扩展种子初始化过程
        dout_seed <= 'd0;
        dout_valid_seed <= 1'b0;
        seed_domain_sep <= {zeta, `k, `l};
        seed_load_cnt <= 'd0;
    end
    else if (state == S_LOAD) begin		// 扩展种子装载过程
        if (done)
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
            dout_seed <= seed_domain_sep[271 : 264];
            dout_valid_seed <= 1'b1;
            seed_domain_sep <= seed_domain_sep << 8;
        end
    end
    else begin
        dout_seed <= 'd0;
        dout_valid_seed <= 1'b0;
    end
end

always_ff @(posedge clk) begin
    if (!rstn) 
        start_out_seed <= 1'b0;
    else if (state_d == S_LOAD && state == S_SQUEEZE) 	// 开始挤出信号 传递给SHA3
        start_out_seed <= 1'b1;
    else 
        start_out_seed <= 1'b0;
end

always_ff @(posedge clk) begin			// 拼接扩展后的种子 一共128Byte，每次扩展输出8Byte
    if (!rstn) begin
        seed_expand <= 'd0;
        seed_expand_cnt <= 'd0;
    end
    else if (state == S_SQUEEZE) begin		
        if (st_64bit_valid_seed) begin
            seed_expand <= (seed_expand << 64) | st_64bit_seed;
            seed_expand_cnt <= seed_expand_cnt + 'd8;
        end
    end
end

always_ff @(posedge clk) begin			// 矩阵A和向量 S1 S2的挤出信号 指示SHA3开始扩展矩阵和向量
    if (!rstn) begin
        start_expand_ExpandA <= 1'b0;
        start_expand_ExpandS <= 1'b0;
    end
    else if (state == S_EXPAND) begin
        start_expand_ExpandA <= 1'b1;
        start_expand_ExpandS <= 1'b1;
    end
    else begin
        start_expand_ExpandA <= 1'b0;
        start_expand_ExpandS <= 1'b0;
    end
end

always_comb begin						// 扩展种子、矩阵A、向量S1、S2可能会复用端口 此处对端口进行分配 分配依据为状态机变量
    dout1 = 'd0; dout_valid1 = 'd0; dout_len1 = 'd0; mdlen1 = 'd0;
    init1 = 'd0; start1 = 'd0; start_out1 = 'd0; out_len1 = 'd0;
    
    dout2 = 'd0; dout_valid2 = 'd0; dout_len2 = 'd0; mdlen2 = 'd0;
    init2 = 'd0; start2 = 'd0; start_out2 = 'd0; out_len2 = 'd0;

    done_ExpandA = 'd0; done_out_ExpandA = 'd0; st_64bit_ExpandA = 'd0; st_64bit_valid_ExpandA = 'd0;
    done_ExpandS = 'd0; done_out_ExpandS = 'd0; st_64bit_ExpandS = 'd0; st_64bit_valid_ExpandS = 'd0;
    done_seed    = 'd0; done_out_seed    = 'd0; st_64bit_seed    = 'd0; st_64bit_valid_seed    = 'd0;

    if (state == S_EXPAND || state == S_STORE) begin
        // ==========================================
        // 状态为 EXPAND 时，SHA3-1 分配给 ExpandA
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
    
        // ==========================================
        // 状态为 EXPAND 时，SHA3-2 分配给 ExpandS
        // ==========================================
        dout2       = dout_ExpandS;
        dout_valid2 = dout_valid_ExpandS;
        dout_len2   = dout_len_ExpandS;
        mdlen2      = mdlen_ExpandS;
        init2       = init_ExpandS;
        start2      = start_ExpandS;
        start_out2  = start_out_ExpandS;
        out_len2    = out_len_ExpandS;
        
        done_ExpandS           = done2;
        done_out_ExpandS       = done_out2;
        st_64bit_ExpandS       = st_64bit2;
        st_64bit_valid_ExpandS = st_64bit_valid2;
    end
    else begin
        // ==========================================
        // 其他状态时，SHA3-1 分配给自身(Seed扩展)
        // ==========================================
        dout1       = dout_seed; 
        dout_valid1 = dout_valid_seed; 
        dout_len1   = dout_len_seed; 
        mdlen1      = mdlen_seed; 
        init1       = init_seed; 
        start1      = start_seed; 
        start_out1  = start_out_seed; 
        out_len1    = out_len_seed; 
        
        done_seed              = done1; 
        done_out_seed          = done_out1; 
        st_64bit_seed          = st_64bit1; 
        st_64bit_valid_seed    = st_64bit_valid1; 
        
        // SHA3-2 在此状态下保持闲置
    end
end

// ==========================================================
// 5. 扩展模块 (ExpandA / ExpandS)
// ==========================================================
assign rho_ExpandA = {<<8{seed_expand[1023 : 768]}};		// 种子按字节倒取 32Byte

//* ExpandA 放到顶层便于复用

assign rho_ExpandS = {<<8{seed_expand[767 : 256]}};			// 种子按字节倒取 64Byte	

ExpandS u_ExpandS(
    .clk                ( clk                     ),
    .rstn               ( rstn                    ),
    .rho_prime          ( rho_ExpandS             ),
    .start_expand       ( start_expand_ExpandS    ),
    .coeff              ( coeff_ExpandS           ),
    .coeff_valid        ( coeff_valid_ExpandS     ),
    .expand_done        ( expand_done_ExpandS     ),
    .nouce              ( nouce                   ),
    .coeff_raw          ( coeff_raw               ),

    .dout               ( dout_ExpandS            ),
    .dout_valid         ( dout_valid_ExpandS      ),
    .dout_len           ( dout_len_ExpandS        ),
    .mdlen              ( mdlen_ExpandS           ),
    .init               ( init_ExpandS            ),
    .start              ( start_ExpandS           ),
    .done               ( done_ExpandS            ),
    .start_out          ( start_out_ExpandS       ),
    .out_len            ( out_len_ExpandS         ),
    .done_out           ( done_out_ExpandS        ),
    .st_64bit           ( st_64bit_ExpandS        ),
    .st_64bit_valid     ( st_64bit_valid_ExpandS  )
);


// ==========================================================
// 6. 存储控制与 CoeffBlockRAM 例化
// ==========================================================
assign w_MatrixA_Coeff = coeff_ExpandA;											// 存储扩展后的A矩阵
assign w_MatrixA_Coeff_valid = coeff_valid_ExpandA;								// 有效信号

assign w_VectorS1_Coeff = coeff_raw;											// 此处存储模q前的原始S值 从而减小位宽
assign w_VectorS1_Coeff_valid = coeff_valid_ExpandS & (nouce <= `l - 1);		// nounce用于区分当前正在扩展 S1 还是 S2

assign w_VectorS2_Coeff = coeff_raw;
assign w_VectorS2_Coeff_valid = coeff_valid_ExpandS & (nouce > `l - 1);

always_ff @(posedge clk) begin													// 根据扩展模块输出的有效信号更新写地址
    if (!rstn) begin
        w_MatrixA_Coeff_addr <= 'd0;
        w_VectorS1_Coeff_addr <= 'd0;
        w_VectorS2_Coeff_addr <= 'd0;
    end
    else begin
        if (w_MatrixA_Coeff_valid)
            w_MatrixA_Coeff_addr <= w_MatrixA_Coeff_addr + 1'b1;
        else
            w_MatrixA_Coeff_addr <= w_MatrixA_Coeff_addr;
            
        if (w_VectorS1_Coeff_valid) 
            w_VectorS1_Coeff_addr <= w_VectorS1_Coeff_addr + 1'b1;
        else
            w_VectorS1_Coeff_addr <= w_VectorS1_Coeff_addr;
            
        if (w_VectorS2_Coeff_valid) 
            w_VectorS2_Coeff_addr <= w_VectorS2_Coeff_addr + 1'b1;
        else
            w_VectorS2_Coeff_addr <= w_VectorS2_Coeff_addr;
    end
end

always_comb begin : matrix_A_vector_T_read_control
    for (int i = 0 ; i < K ; i = i + 1) begin
        r_MatrixA_Coeff_addr[i] = 'd0;
        r_VectorT_Coeff_addr[i] = 'd0;
    end
    if (state <= S_MATRIX_MULT_WAIT && con_coeff_valid) begin		// 取出 A 和上一阶段计算好的T 利用NTT(S1) 计算T_prime+A*S1的MAC结果
        for (int i = 0 ; i < K ; i = i + 1) begin	
            r_MatrixA_Coeff_addr[i] = con_coeff_cnt;
            r_VectorT_Coeff_addr[i] = con_coeff_cnt[5 : 0];
        end
    end
    if (state > S_MATRIX_MULT_WAIT) begin								// 从存储矩阵中取出T 装载入Poly_PAU模块进行INTT变换 
        for (int i = 0 ; i < K ; i = i + 1) 							// 向量T在存储矩阵中按行存储 每行的地址范围是 0 - 63 这里的策略是 每一行都设定为相同的地址（即同一列）
            r_VectorT_Coeff_addr[i] = r_VectorT_Coeff_addr_INTT[5 : 0];	// 然后根据地址的高3位来确定是哪一行
    end
end

always_comb begin : r_VectorS2_control
    for (int i = 0 ; i < K ; i = i + 1)
        r_VectorS2_Coeff_addr[i] <= 'd0;
    if (state == S_T_INTT_WAIT) begin								// INTT(T)变换输出结果的过程中从存储矩阵中读出S2 计算 INTT(T)+S2
        for (int i = 0 ; i < K ; i = i + 1)							// S2是按行存储的 所以r_VectorS2_Coeff_addr是一个23位的一维矩阵 矩阵的宽度为 `k
            r_VectorS2_Coeff_addr[i] <= con_coeff_cnt[5 : 0];		// 这里给所有的矩阵都赋予同样的地址 地址就是INTT(T)输出的索引
    end																// 后面需要根据con_coeff_cnt的高3位来判断应该选择r_VectorS2_Coeff`k个中的哪一个
end

always_ff @(posedge clk) begin : vector_t_write_control
    if (!rstn) begin
        for (int i = 0 ; i < K ; i = i + 1)
            w_VectorT_Coeff_addr[i] <= 'd0;
    end
    else if ((w_VectorT_Coeff_valid[0] && state <= S_MATRIX_MULT_WAIT) ) begin		// 矩阵乘法阶段 根据MAC的输出有效信号更新存储T的地址	
        for (int i = 0 ; i < K ; i = i + 1) begin
            if (w_VectorT_Coeff_addr[i] == 'd63)
                w_VectorT_Coeff_addr[i] <= 'd0;
            else
                w_VectorT_Coeff_addr[i] <= w_VectorT_Coeff_addr[i] + 1'b1;
        end
    end
    else begin
        for (int i = 0 ; i < K ; i = i + 1)
            w_VectorT_Coeff_addr[i] <= w_VectorT_Coeff_addr[i];
    end
end

//* CoeffBlockRAM 放到顶层便于复用

// ==========================================================
// 7. NTT/INTT (Poly_PAU 控制与例化)
// ==========================================================

always_ff @(posedge clk) begin				// 握手逻辑
    if (!rstn)
        request <= 1'b0;
    else if (state == S_S1_NTT_ACK || state == S_T_INTT_ACK) begin
        if (ready)
            request <= 1'b1;
        else 
            request <= 1'b0;
    end
    else 
        request <= 1'b0;
end

assign mode_config = (state == S_S1_NTT || state == S_S1_NTT_WAIT) ? 1'b0 : 1'b1;		// 根据状态选择NTT还是INTT

always_ff @(posedge clk) begin
    if (!rstn) 
        r_VectorS1_Coeff_addr <= 'd0;
    else if (state == S_S1_NTT) begin		// 从存储矩阵中读取 S1 并装载到 SHA3 中 进行 NTT 变换
        if (r_VectorS1_Coeff_addr == `l * 64) 
            r_VectorS1_Coeff_addr <= 'd0;
        else if (r_VectorS1_Coeff_addr > 0 && r_VectorS1_Coeff_addr[5 : 0] == 0) 
            r_VectorS1_Coeff_addr <= r_VectorS1_Coeff_addr;
        else 
            r_VectorS1_Coeff_addr <= r_VectorS1_Coeff_addr + 1'b1;
    end
    else if (state <= S_MATRIX_MULT_WAIT && ready == 1'b0 && request == 1'b1) 
        r_VectorS1_Coeff_addr <= r_VectorS1_Coeff_addr + 1'b1;
    else 
        r_VectorS1_Coeff_addr <= r_VectorS1_Coeff_addr;
end

always_ff @(posedge clk) begin
    if (!rstn) 
        r_VectorT_Coeff_addr_INTT <= 'd0;
    else if (state == S_T_INTT) begin		// 从存储矩阵中读取 T 并装载到 SHA3 中 进行 INTT 变换
        if (r_VectorT_Coeff_addr_INTT == `l * 64) 
            r_VectorT_Coeff_addr_INTT <= 'd0;
        else if (r_VectorT_Coeff_addr_INTT > 0 && r_VectorT_Coeff_addr_INTT[5 : 0] == 0) 
            r_VectorT_Coeff_addr_INTT <= r_VectorT_Coeff_addr_INTT;
        else 
            r_VectorT_Coeff_addr_INTT <= r_VectorT_Coeff_addr_INTT + 1'b1;
    end
    else if (state > S_MATRIX_MULT_WAIT && ready == 1'b0 && request == 1'b1) 
        r_VectorT_Coeff_addr_INTT <= r_VectorT_Coeff_addr_INTT + 1'b1;
    else 
        r_VectorT_Coeff_addr_INTT <= r_VectorT_Coeff_addr_INTT;
end

always_ff @(posedge clk) begin				// 向量 T 存储时时按行存储的 低5位表示列 高3位表示行
    if (!rstn)
        r_VectorT_Coeff_addr_INTT_d <= 'd0;
    else 
        r_VectorT_Coeff_addr_INTT_d <= r_VectorT_Coeff_addr_INTT;
end

assign r_VectorT_Coeff_INTT = r_VectorT_Coeff[r_VectorT_Coeff_addr_INTT_d[8 : 6]]; // 读取需要一个时钟周期 因此这里对地址打一拍后再根据高三位取行

always_ff @(posedge clk) begin
    if (!rstn) 
        ori_coeff_valid <= 1'b0;
    else if (state == S_S1_NTT) begin		// 取出原始系数有效信号 传递到Poly_PAU
        if (r_VectorS1_Coeff_addr == `l * 64) 
            ori_coeff_valid <= 1'b0;
        else if (r_VectorS1_Coeff_addr > 0 && r_VectorS1_Coeff_addr[5 : 0] == 0) 
            ori_coeff_valid <= 1'b0;
        else 
            ori_coeff_valid <= 1'b1;
    end
    else if (state == S_T_INTT) begin
        if (r_VectorT_Coeff_addr_INTT == `k * 64)
            ori_coeff_valid <= 1'b0;
        else if (r_VectorT_Coeff_addr_INTT > 0 && r_VectorT_Coeff_addr_INTT[5 : 0] == 0) 
            ori_coeff_valid <= 1'b0;
        else 
            ori_coeff_valid <= 1'b1;
    end
    else if (ready == 1'b0 && request == 1'b1) 
        ori_coeff_valid <= 1'b1;
    else 
        ori_coeff_valid <= 1'b0;
end

assign ori_coeff = (state <= S_MATRIX_MULT_WAIT) ? r_VectorS1_Coeff : r_VectorT_Coeff_INTT;	// 根据状态选择最终的给到Poly_PAU的原始系数

always_ff @(posedge clk) begin
    if (!rstn)
        con_coeff_cnt <= 'd0;
    else if (con_coeff_valid) begin						// 转换完成系数计数器 同时作为读取T和S2的地址
        if (con_coeff_cnt == `l * 64 - 1)
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

//* Poly_PAU 放到顶层便于复用

// ==========================================================
// 8. 矩阵乘加网络 (ModuleMAC 阵列)
// ==========================================================
assign conv[0] = con_coeff_d[22 : 0];				// NTT/INTT 结果
assign conv[1] = con_coeff_d[45: 23];
assign conv[2] = con_coeff_d[68 : 46];
assign conv[3] = con_coeff_d[91 : 69];

assign temp0 = r_VectorT_Coeff_INTT[23 * 0 +: 23];
assign temp1 = r_VectorT_Coeff_INTT[23 * 1 +: 23];
assign temp2 = r_VectorT_Coeff_INTT[23 * 2 +: 23];
assign temp3 = r_VectorT_Coeff_INTT[23 * 3 +: 23];

always_ff @(posedge clk) begin 
    if (!rstn) begin
        con_coeff_d <= 'd0;
        con_coeff_valid_d <= 1'b0;
    end
    else begin
        con_coeff_d <= con_coeff;					// 由于从存储矩阵中读取要延时一拍 所以这里对读取数据和读取有效信号都延时一拍处理
        con_coeff_valid_d <= con_coeff_valid;
    end
end

// MAC-T = A * NTT(S1) + T
logic                   valid_out [0 : K - 1];
logic   [91 : 0]        mac_out_comb [0 : K - 1];

assign mac_valid_in_keygen = con_coeff_valid_d;
assign mac_data_in2_keygen = con_coeff_d;

always_comb begin
    for (int i = 0 ; i < K ; i = i + 1) begin
        // 输出给 MAC 的操作数
        mac_data_in1_keygen[i] = r_MatrixA_Coeff[i];
        mac_data_in3_keygen[i] = ('d1 <= con_coeff_cnt && con_coeff_cnt <= 'd64) ? 92'd0 : r_VectorT_Coeff[i];
        
        // 接收来自 MAC 的结果
        valid_out[i] = mac_valid_out_keygen;
        mac_out_comb[i] = mac_data_out_keygen[i];
    end
end

// Module Add-T = S2 + INTT(T)
assign S2[0] = r_VectorS2_Coeff[con_coeff_cnt_d[8 : 6]][23 * 0 +: 23];
assign S2[1] = r_VectorS2_Coeff[con_coeff_cnt_d[8 : 6]][23 * 1 +: 23];
assign S2[2] = r_VectorS2_Coeff[con_coeff_cnt_d[8 : 6]][23 * 2 +: 23];
assign S2[3] = r_VectorS2_Coeff[con_coeff_cnt_d[8 : 6]][23 * 3 +: 23];
logic 				add_valid_out [0 : 3];
logic	[91 : 0]	add_out_comb;
generate
	for (genvar i = 0 ; i < 4 ; i = i + 1) begin : row_add_inst
		wire	[22 : 0]	add_out;
		ModuleAdd u_ModuleAdd(
			.clk       	( clk        ),
			.rstn      	( rstn       ),
			.valid_in  	( con_coeff_valid_d   ),
			.data_in1  	( conv[i]   ),
			.data_in2  	( S2[i]   ),
			.valid_out 	( add_valid_out[i]  ),
			.data_out  	( add_out   )
		);
		assign add_out_comb[23 * i +: 23] = add_out;
	end
endgenerate

always_comb begin
	for (int i = 0 ; i < K ; i = i + 1) begin
		w_VectorT_Coeff_valid[i] = 1'b0;
		w_VectorT_Coeff[i] = 'd0;
	end
	if (state <= S_MATRIX_MULT_WAIT) begin
		for (int i = 0 ; i < K ; i = i + 1) begin
			w_VectorT_Coeff_valid[i] = valid_out[i];
			w_VectorT_Coeff[i] = mac_out_comb[i];
 		end
	end
end

always_ff @(posedge clk) begin : w_VectorT_Coeff_valid_delay
    if (!rstn) begin
		for (int i = 0 ; i < K ; i = i + 1)
        	w_VectorT_Coeff_valid_d[i] <= 1'b0;
	end
    else begin
		for (int i = 0 ; i < K ; i = i + 1)
        	w_VectorT_Coeff_valid_d[i] <= w_VectorT_Coeff_valid[i];
	end
end

// ==========================================================
// 9. power2round
// ==========================================================

logic [39 : 0] t1_out_comb;      
logic [51 : 0] t0_out_comb;      
logic [3 : 0]  t1_valid_out_vec; 
logic [3 : 0]  t0_valid_out_vec;

generate
    for (genvar i = 0 ; i < 4 ; i = i + 1) begin : row_power2round_inst    
        wire [22 : 0] t_in = add_out_comb[23 * i +: 23];
        wire          t_valid_in = add_valid_out[0]; 
		wire [9 : 0]  t1_out;
		wire [12 : 0] t0_out_prime;
		wire [12 : 0] t0_out = t0_out_prime;
        power2round u_power2round(
            .clk            ( clk 					),
            .rstn           ( rstn 					),
            .t_input        ( t_in 					),
            .t_valid_input  ( t_valid_in 			),
            .t1             ( t1_out 				), 
            .t1_valid       ( t1_valid_out_vec[i] 	),
            .t0             ( t0_out_prime 			),  
            .t0_valid       ( t0_valid_out_vec[i] 	)
        );  
		assign t0_out_comb[13 * i +: 13] = t0_out;
		assign t1_out_comb[10 * i +: 10] = t1_out;
    end
endgenerate

wire final_t_valid = t1_valid_out_vec[0] & state > S_MATRIX_MULT_WAIT;

endmodule