`include "../../param_conf.v"
module keygen_internal(
    // --- 时钟和复位信号 ---
	input       logic               clk,
    input       logic               rstn,

	// --- 控制标志位 ---
    input       logic               start,      // 启动标志
    output      logic               key_ready,		// 准备标志
	output		logic				done,		// 完成标志

	// --- 输入输出数据 ---
    input       logic   [255 : 0]   zeta,       // 32字节 种子
    output      logic   [7 : 0]     pk,         // 单字节 公钥
    output      logic   [7 : 0]     sk,         // 单字节 私钥

	output		logic   [91 : 0]    coeff_rho_ExpandA,          // 4*23bit 有效采样系数
	output		logic               coeff_valid_rho_ExpandA,    // 4*23bit 有效采样系数信号

	output		logic   [15 : 0]    coeff_rho_ExpandS,          // 4*4bit 有效采样系数
	output		logic               coeff_valid_rho_ExpandS,    // 4*4bit 有效采样系数信号

	// --- SHA3 控制接口 ---
    output      logic   [7 : 0]     dout1,           // SHA3 串行输入字节数据
    output      logic               dout_valid1,     // SHA3 串行输入字节有效信号
    output      logic   [31 : 0]    dout_len1,       // SHA3 串行输入字节长度
    output      logic   [7 : 0]     mdlen1,          // SHA3 Hash长度
    output      logic               init1,           // SHA3 初始化信号
    output      logic               start1,          // SHA3 开始装载数据
    input       logic               done1,           // SHA3 数据装载完成
    output      logic               start_out1,      // SHA3 开始挤出数据
    output      logic   [31 : 0]    out_len1,        // SHA3 挤出数据长度
    input       logic               done_out1,       // SHA3 挤出数据完成
    input       logic   [63 : 0]    st_64bit1,       // SHA3 挤出8字节数据
    input       logic               st_64bit_valid1, // SHA3 挤出8字节数据有效信号

	output      logic   [7 : 0]     dout2,           // SHA3 串行输入字节数据
    output      logic               dout_valid2,     // SHA3 串行输入字节有效信号
    output      logic   [31 : 0]    dout_len2,       // SHA3 串行输入字节长度
    output      logic   [7 : 0]     mdlen2,          // SHA3 Hash长度
    output      logic               init2,           // SHA3 初始化信号
    output      logic               start2,          // SHA3 开始装载数据
    input       logic               done2,           // SHA3 数据装载完成
    output      logic               start_out2,      // SHA3 开始挤出数据
    output      logic   [31 : 0]    out_len2,        // SHA3 挤出数据长度
    input       logic               done_out2,       // SHA3 挤出数据完成
    input       logic   [63 : 0]    st_64bit2,       // SHA3 挤出8字节数据
    input       logic               st_64bit_valid2  // SHA3 挤出8字节数据有效信号
);

// ==========================================================
// 参数与状态定义
// ==========================================================

typedef enum logic [4 : 0] {  
	S_IDLE,				// 空闲等待
	S_INIT,				// 初始化 存储种子[seed, `k, `l]
	S_LOAD,				// 给 SHA3 装载种子
	S_SQUEEZE,			// 挤出数据 获取扩展种子 用于生成矩阵A，向量S
	S_EXPAND,			// 生成矩阵 A 和向量 S 此状态给出起始信号
	S_STORE,			// 获得矩阵 A 和向量 S 并存入存储空间
	S_S1_NTT_ACK, 		// 当前模块与 Poly_PAU 模块的握手状态
	S_S1_NTT,			// 从存储空间中获得一组 S（256个系数） 存入 Poly_PAU 当中 并启动 NTT 转换
	S_S1_NTT_WAIT,		// 等待 NTT 转换完成 输出 64 个 92bits数据 (共256个系数)
	S_VECTOR_MULT,   	// 从存储空间中获得一组 A (256个系数，已在 NTT 空间) 与 向量 S 相乘 相同系数相累加 获得 T (256个系数 NTT空间) 
	S_T_INTT,			// 获得 T 并启动 INTT
	S_T_ADD_S2			// 在系数与 T + S2 获得最终的 T 同时给到 power_2_bound 获得 t0 和 t1
} state_t;
state_t 							state, state_d;

logic			[271 : 0]			seed_domain_sep;	 // 34 字节输入原始种子
logic			[1023 : 0]			seed_expand;		 // 128 字节扩展种子
logic			[7 : 0]				seed_expand_cnt;	 // 扩展种子字节计数器 一次输出8字节 所以计数器每次 +8
logic			[5 : 0]				seed_load_cnt;		 // 输入种子字节计数器

// --- SHA3 Expand seed ---
logic   		[7 : 0]     		dout_seed;           // SHA3 串行输入字节数据
logic               				dout_valid_seed;     // SHA3 串行输入字节有效信号
logic   		[31 : 0]    		dout_len_seed;       // SHA3 串行输入字节长度
logic   		[7 : 0]     		mdlen_seed;          // SHA3 Hash长度
logic               				init_seed;           // SHA3 初始化信号
logic               				start_seed;          // SHA3 开始装载数据
logic               				done_seed;           // SHA3 数据装载完成
logic               				start_out_seed;      // SHA3 开始挤出数据
logic   		[31 : 0]    		out_len_seed;        // SHA3 挤出数据长度
logic               				done_out_seed;       // SHA3 挤出数据完成
logic   		[63 : 0]    		st_64bit_seed;       // SHA3 挤出8字节数据
logic               				st_64bit_valid_seed; // SHA3 挤出8字节数据有效信号

// --- ExpandA ---
logic   		[255 : 0]   		rho_ExpandA;            // 256位随机种子
logic               				start_expand_ExpandA;   // 开始扩展A矩阵信号
logic   		[91 : 0]    		coeff_ExpandA;          // 4*23bit 有效采样系数
logic               				coeff_valid_ExpandA;    // 4*23bit 有效采样系数信号
logic               				expand_done_ExpandA;    // 扩展完成信号

logic   		[7 : 0]     		dout_ExpandA;           // SHA3 串行输入字节数据
logic               				dout_valid_ExpandA;     // SHA3 串行输入字节有效信号
logic   		[31 : 0]    		dout_len_ExpandA;       // SHA3 串行输入字节长度
logic   		[7 : 0]     		mdlen_ExpandA;          // SHA3 Hash长度
logic               				init_ExpandA;           // SHA3 初始化信号
logic               				start_ExpandA;          // SHA3 开始装载数据
logic               				done_ExpandA;           // SHA3 数据装载完成
logic               				start_out_ExpandA;      // SHA3 开始挤出数据
logic   		[31 : 0]    		out_len_ExpandA;        // SHA3 挤出数据长度
logic               				done_out_ExpandA;       // SHA3 挤出数据完成
logic   		[63 : 0]    		st_64bit_ExpandA;       // SHA3 挤出8字节数据
logic               				st_64bit_valid_ExpandA; // SHA3 挤出8字节数据有效信号

// --- ExpandS ---
logic   		[511 : 0]   		rho_ExpandS;            // 256位随机种子
logic               				start_expand_ExpandS;   // 开始扩展S矩阵信号
logic   		[91 : 0]    		coeff_ExpandS;          // 4*23bit 有效采样系数
logic               				coeff_valid_ExpandS;    // 4*23bit 有效采样系数信号
logic               				expand_done_ExpandS;    // 扩展完成信号
logic   		[15 : 0]    		nouce;         
logic   signed  [15 : 0] 			coeff_raw;

logic   		[7 : 0]     		dout_ExpandS;           // SHA3 串行输入字节数据
logic               				dout_valid_ExpandS;     // SHA3 串行输入字节有效信号
logic   		[31 : 0]    		dout_len_ExpandS;       // SHA3 串行输入字节长度
logic   		[7 : 0]     		mdlen_ExpandS;          // SHA3 Hash长度
logic               				init_ExpandS;           // SHA3 初始化信号
logic               				start_ExpandS;          // SHA3 开始装载数据
logic               				done_ExpandS;           // SHA3 数据装载完成
logic               				start_out_ExpandS;      // SHA3 开始挤出数据
logic   		[31 : 0]    		out_len_ExpandS;        // SHA3 挤出数据长度
logic               				done_out_ExpandS;       // SHA3 挤出数据完成
logic   		[63 : 0]    		st_64bit_ExpandS;       // SHA3 挤出8字节数据
logic               				st_64bit_valid_ExpandS; // SHA3 挤出8字节数据有效信号

// --- CoeffBlockRAM ---

// --- Matrix A ---
logic           [91 : 0]    		w_MatrixA_Coeff;
logic                       		w_MatrixA_Coeff_valid;
logic           [11 : 0]    		w_MatrixA_Coeff_addr;
logic           [91 : 0]    		r_MatrixA_Coeff;
logic           [11 : 0]    		r_MatrixA_Coeff_addr;

// --- Vector S ---
logic   signed  [15 : 0]    		w_VectorS_Coeff;            // 4*4bit有符号数
logic                       		w_VectorS_Coeff_valid;
logic           [9 : 0]     		w_VectorS_Coeff_addr;       // S1 [0 : 7*64-1] S2 [7*64 : 15*64-1]
logic           [91 : 0]    		r_VectorS_Coeff;            // 对q取模 无符号
logic           [9 : 0]     		r_VectorS_Coeff_addr;

// --- Vector Y ---
logic   signed  [79 : 0]    		w_VectorY_Coeff;            // 4*20bit有符号数
logic                       		w_VectorY_Coeff_valid;
logic           [5 : 0]     		w_VectorY_Coeff_addr;
logic           [91 : 0]    		r_VectorY_Coeff;            // 对q取模 无符号
logic           [5 : 0]     		r_VectorY_Coeff_addr;

// --- Vector T ---
logic           [91 : 0]    		w_VectorT_Coeff;
logic                       		w_VectorT_Coeff_valid;
logic           [8 : 0]     		w_VectorT_Coeff_addr;
logic           [91 : 0]    		r_VectorT_Coeff;
logic           [8 : 0]     		r_VectorT_Coeff_addr;

// --- Poly_PAU ---

// --- 原始系数(从存储矩阵中一次读取四个) ---
logic   		[91 : 0]        	ori_coeff;
logic                   			ori_coeff_valid;
logic                   			request;            		// 上游请求信号
logic   		[91 : 0]        	ext_operand;        		// 外部输入的计算数
logic                   			ext_operand_request;		// 请求获取外部输入的计算数  First World Fall Through
logic   		[4 : 0]         	mode_config;        		// 模式选择 0: NTT 1: INTT 2: 模乘 3: 模加 4: 模减

// --- NTT域系数(向存储矩阵中一次写入四个) ---
logic                   			ready;              		// 下游准备信号
logic   		[91 : 0]        	con_coeff;
logic                   			con_coeff_valid;

logic			[7 : 0]				con_coeff_cnt;				// 输出系数计数器(共 256 个)

always_ff @(posedge clk) begin
	if (!rstn)
		key_ready <= 1'b1;
	else if (state == S_IDLE)
		key_ready <= 1'b1;
	else 
		key_ready <= 1'b0;
end

assign out_len_seed = 'd128;
always_ff @(posedge clk) begin
	if (!rstn)
		start_seed <= 1'b0;
	else if (state == S_INIT)
		start_seed <= 1'b1;
	else
		start_seed <= 1'b0;
end

assign init_seed = (state == S_INIT);

always_ff @(posedge clk) begin
	if (!rstn) begin
		dout_seed <= 'd0;
		dout_valid_seed <= 1'b0;
		seed_domain_sep <= 'd0;
		seed_load_cnt <= 'd0;
	end
	else if (state == S_INIT) begin
		dout_seed <= 'd0;
		dout_valid_seed <= 1'b0;
		seed_domain_sep <= {zeta, `k, `l};
		seed_load_cnt <= 'd0;
	end
	else if (state == S_LOAD) begin
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
	else if (state_d == S_LOAD && state == S_SQUEEZE) 
		start_out_seed <= 1'b1;
	else 
		start_out_seed <= 1'b0;
end

always_ff @(posedge clk) begin
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

always_ff @(posedge clk) begin
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

// --------------------------------
// SHA3 MUX
// --------------------------------
assign dout_len_seed = 'd34;
assign mdlen_seed = 'd32;			// SHA256
always_comb begin
    // --- 默认赋初值，防止产生 Latch ---
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
        // 1. 本模块的输出 = 子模块(ExpandA)的输出
        dout1       = dout_ExpandA; 
        dout_valid1 = dout_valid_ExpandA; 
        dout_len1   = dout_len_ExpandA; 
        mdlen1      = mdlen_ExpandA; 
        init1       = init_ExpandA; 
        start1      = start_ExpandA; 
        start_out1  = start_out_ExpandA; 
        out_len1    = out_len_ExpandA; 
        
        // 2. 子模块(ExpandA)的输入 = 本模块的外部输入
        done_ExpandA           = done1; 
        done_out_ExpandA       = done_out1; 
        st_64bit_ExpandA       = st_64bit1; 
        st_64bit_valid_ExpandA = st_64bit_valid1; 
    
        // ==========================================
        // 状态为 EXPAND 时，SHA3-2 分配给 ExpandS
        // ==========================================
        // 1. 本模块的输出 = 子模块(ExpandS)的输出
        dout2       = dout_ExpandS;
        dout_valid2 = dout_valid_ExpandS;
        dout_len2   = dout_len_ExpandS;
        mdlen2      = mdlen_ExpandS;
        init2       = init_ExpandS;
        start2      = start_ExpandS;
        start_out2  = start_out_ExpandS;
        out_len2    = out_len_ExpandS;
        
        // 2. 子模块(ExpandS)的输入 = 本模块的外部输入
        done_ExpandS           = done2;
        done_out_ExpandS       = done_out2;
        st_64bit_ExpandS       = st_64bit2;
        st_64bit_valid_ExpandS = st_64bit_valid2;
    end
    else begin
        // ==========================================
        // 其他状态时，SHA3-1 分配给自身(Seed扩展)
        // ==========================================
        // 1. 本模块的输出 = Seed逻辑的输出
        dout1       = dout_seed; 
        dout_valid1 = dout_valid_seed; 
        dout_len1   = dout_len_seed; 
        mdlen1      = mdlen_seed; 
        init1       = init_seed; 
        start1      = start_seed; 
        start_out1  = start_out_seed; 
        out_len1    = out_len_seed; 
        
        // 2. Seed逻辑的输入 = 本模块的外部输入
        done_seed           = done1; 
        done_out_seed       = done_out1; 
        st_64bit_seed       = st_64bit1; 
        st_64bit_valid_seed = st_64bit_valid1; 
        
        // SHA3-2 在此状态下保持闲置 (依赖上面的默认赋初值)
    end
end

always_ff @(posedge clk) begin
	if (!rstn)
		done <= 1'b0;
	else if (expand_done_ExpandA)
		done <= 1'b1;
	else 
		done <= 1'b0;
end

// --------------------------------
// 状态机
// --------------------------------

always_ff @(posedge clk) begin
	if (!rstn)
		state <= S_IDLE;
	else begin
		case (state)
			S_IDLE : begin
				if (start && key_ready)
					state <= S_INIT;
				else 
					state <= S_IDLE;
			end
			S_INIT : begin
				state <= S_LOAD;
			end
			S_LOAD : begin
				if (done_seed)
					state <= S_SQUEEZE;
				else 
					state <= S_LOAD;
			end
			S_SQUEEZE : begin
				if (done_out_seed)
					state <= S_EXPAND;
				else 
					state <= S_SQUEEZE;
			end
			S_EXPAND : begin
				state <= S_STORE;
			end
			S_STORE : begin
				if (expand_done_ExpandA)
					state <= S_S1_NTT_ACK;
				else
					state <= S_STORE;
			end
			S_S1_NTT_ACK : begin
				if (ready == 1'b0 && request == 1'b1)
					state <= S_S1_NTT;
				else 
					state <= S_S1_NTT_ACK;
			end
			S_S1_NTT : begin
				if (r_VectorS_Coeff_addr > 0 && r_VectorS_Coeff_addr[5 : 0] == 0)  // r_VectorS_Coeff_addr % 64 == 0
					state <= S_S1_NTT_WAIT;
				else 
					state <= S_S1_NTT;
			end
			S_S1_NTT_WAIT : begin
				if (con_coeff_cnt[5 : 0] == 'd63) begin
					if (con_coeff_cnt == `l * 64 - 1)
						state <= S_T_INTT;
					else 
						state <= S_S1_NTT_ACK;
				end
				else 
					state <= S_S1_NTT_WAIT;
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

// --------------------------------
// 扩展模块
// --------------------------------

assign rho_ExpandA = {<<8{seed_expand[1023 : 768]}};
ExpandA u_ExpandA(
	.clk            	( clk             		  ),
	.rstn           	( rstn            		  ),
	.rho            	( rho_ExpandA             ),
	.start_expand   	( start_expand_ExpandA    ),
	.coeff          	( coeff_ExpandA           ),
	.coeff_valid    	( coeff_valid_ExpandA     ),
	.expand_done    	( expand_done_ExpandA     ),

	.dout           	( dout_ExpandA            ),
	.dout_valid     	( dout_valid_ExpandA      ),
	.dout_len       	( dout_len_ExpandA        ),
	.mdlen          	( mdlen_ExpandA           ),
	.init           	( init_ExpandA            ),
	.start          	( start_ExpandA           ),
	.done           	( done_ExpandA            ),
	.start_out      	( start_out_ExpandA       ),
	.out_len        	( out_len_ExpandA         ),
	.done_out       	( done_out_ExpandA        ),
	.st_64bit       	( st_64bit_ExpandA        ),
	.st_64bit_valid 	( st_64bit_valid_ExpandA  )
);

assign rho_ExpandS = {<<8{seed_expand[767 : 256]}};
ExpandS u_ExpandS(
	.clk            	( clk             		  ),
	.rstn           	( rstn            		  ),
	.rho_prime          ( rho_ExpandS             ),
	.start_expand   	( start_expand_ExpandS    ),
	.coeff          	( coeff_ExpandS           ),
	.coeff_valid    	( coeff_valid_ExpandS     ),
	.expand_done    	( expand_done_ExpandS     ),
	.nouce				( nouce					  ),
	.coeff_raw			( coeff_raw	      		  ),

	.dout           	( dout_ExpandS            ),
	.dout_valid     	( dout_valid_ExpandS      ),
	.dout_len       	( dout_len_ExpandS        ),
	.mdlen          	( mdlen_ExpandS           ),
	.init           	( init_ExpandS            ),
	.start          	( start_ExpandS           ),
	.done           	( done_ExpandS            ),
	.start_out      	( start_out_ExpandS       ),
	.out_len        	( out_len_ExpandS         ),
	.done_out       	( done_out_ExpandS        ),
	.st_64bit       	( st_64bit_ExpandS        ),
	.st_64bit_valid 	( st_64bit_valid_ExpandS  )
);

// --------------------------------
// 存储模块
// --------------------------------

assign coeff_rho_ExpandA = coeff_ExpandA;
assign coeff_valid_rho_ExpandA = coeff_valid_ExpandA;
assign coeff_rho_ExpandS = coeff_raw;
assign coeff_valid_rho_ExpandS = coeff_valid_ExpandS;

assign w_MatrixA_Coeff = coeff_ExpandA;
assign w_MatrixA_Coeff_valid = coeff_valid_ExpandA;

assign w_VectorS_Coeff = coeff_raw;
assign w_VectorS_Coeff_valid = coeff_valid_ExpandS;

always_ff @(posedge clk) begin
	if (!rstn) begin
		w_MatrixA_Coeff_addr <= 'd0;
		w_VectorS_Coeff_addr <= 'd0;
	end
	else begin
		if (w_MatrixA_Coeff_valid)
			w_MatrixA_Coeff_addr <= w_MatrixA_Coeff_addr + 1'b1;
		else
			w_MatrixA_Coeff_addr <= w_MatrixA_Coeff_addr;
		if (w_VectorS_Coeff_valid) 
			w_VectorS_Coeff_addr <= w_VectorS_Coeff_addr + 1'b1;
		else
			w_VectorS_Coeff_addr <= w_VectorS_Coeff_addr;
	end
end

//* 后面记得放顶层
CoeffBlockRAM u_CoeffBlockRAM(
	.clk                   	( clk                    ),
	.w_MatrixA_Coeff       	( w_MatrixA_Coeff        ),
	.w_MatrixA_Coeff_valid 	( w_MatrixA_Coeff_valid  ),
	.w_MatrixA_Coeff_addr  	( w_MatrixA_Coeff_addr   ),
	.r_MatrixA_Coeff       	( r_MatrixA_Coeff        ),
	.r_MatrixA_Coeff_addr  	( r_MatrixA_Coeff_addr   ),
	.w_VectorS_Coeff       	( w_VectorS_Coeff        ),
	.w_VectorS_Coeff_valid 	( w_VectorS_Coeff_valid  ),
	.w_VectorS_Coeff_addr  	( w_VectorS_Coeff_addr   ),
	.r_VectorS_Coeff       	( r_VectorS_Coeff        ),
	.r_VectorS_Coeff_addr  	( r_VectorS_Coeff_addr   ),
	.w_VectorY_Coeff       	( w_VectorY_Coeff        ),
	.w_VectorY_Coeff_valid 	( w_VectorY_Coeff_valid  ),
	.w_VectorY_Coeff_addr  	( w_VectorY_Coeff_addr   ),
	.r_VectorY_Coeff       	( r_VectorY_Coeff        ),
	.r_VectorY_Coeff_addr  	( r_VectorY_Coeff_addr   ),
	.w_VectorT_Coeff       	( w_VectorT_Coeff        ),
	.w_VectorT_Coeff_valid 	( w_VectorT_Coeff_valid  ),
	.w_VectorT_Coeff_addr  	( w_VectorT_Coeff_addr   ),
	.r_VectorT_Coeff       	( r_VectorT_Coeff        ),
	.r_VectorT_Coeff_addr  	( r_VectorT_Coeff_addr   )
);

// --------------------------------
// NTT/INTT模块
// --------------------------------

always_ff @(posedge clk) begin
	if (!rstn)
		request <= 1'b0;
	else if (state == S_S1_NTT_ACK) begin
		if (ready)
			request <= 1'b1;
		else 
			request <= 1'b0;
	end
	else 
		request <= 1'b0;
end

assign mode_config = (state == S_S1_NTT || state == S_S1_NTT_WAIT) ? 1'b0 : 1'b1;

always_ff @(posedge clk) begin
	if (!rstn) begin
		r_VectorS_Coeff_addr <= 'd0;
		ori_coeff_valid <= 1'b0;
	end
	else if (state == S_S1_NTT) begin
		if (r_VectorS_Coeff_addr == `l * 64) begin
			r_VectorS_Coeff_addr <= 'd0;
			ori_coeff_valid <= 1'b0;
		end
		else if (r_VectorS_Coeff_addr > 0 && r_VectorS_Coeff_addr[5 : 0] == 0) begin
			r_VectorS_Coeff_addr <= r_VectorS_Coeff_addr;
			ori_coeff_valid <= 1'b0;
		end
		else begin
			r_VectorS_Coeff_addr <= r_VectorS_Coeff_addr + 1'b1;
			ori_coeff_valid <= 1'b1;
		end
	end
	else if (ready == 1'b0 && request == 1'b1) begin
		r_VectorS_Coeff_addr <= r_VectorS_Coeff_addr + 1'b1;
		ori_coeff_valid <= 1'b1;
	end
	else begin
		r_VectorS_Coeff_addr <= r_VectorS_Coeff_addr;
		ori_coeff_valid <= 1'b0;
	end
end
assign ori_coeff = r_VectorS_Coeff;

always_ff @(posedge clk) begin
	if (!rstn)
		con_coeff_cnt <= 'd0;
	else if (con_coeff_valid) begin
		if (con_coeff_cnt == `l * 64 - 1)
			con_coeff_cnt <= 'd0;
		else
			con_coeff_cnt <= con_coeff_cnt + 1'b1;
	end
	else 
		con_coeff_cnt <= con_coeff_cnt;
end

//* 后面记得放顶层
Poly_PAU u_Poly_PAU(
	.clk                 	( clk                  ),
	.rstn                	( rstn                 ),
	.ori_coeff           	( ori_coeff            ),
	.ori_coeff_valid     	( ori_coeff_valid      ),
	.request             	( request              ),
	.ext_operand         	( ext_operand          ),
	.ext_operand_request 	( ext_operand_request  ),
	.mode_config         	( mode_config          ),
	.ready               	( ready                ),
	.con_coeff           	( con_coeff            ),
	.con_coeff_valid     	( con_coeff_valid      )
);


endmodule
