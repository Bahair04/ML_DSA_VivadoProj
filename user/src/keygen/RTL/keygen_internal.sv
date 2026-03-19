`include "../../param_conf.v"
module keygen_internal(
    // --- 时钟和复位信号 ---
	input       logic               clk,
    input       logic               rstn,

	// --- 控制标志位 ---
    input       logic               start,      // 启动标志
    output      logic               ready,		// 准备标志
	output		logic				done,		// 完成标志

	// --- 输入输出数据 ---
    input       logic   [255 : 0]   zeta,       // 32字节 种子
    output      logic   [7 : 0]     pk,         // 单字节 公钥
    output      logic   [7 : 0]     sk,         // 单字节 私钥

	output		logic   [91 : 0]    coeff_rho_ExpandA,          // 4*23bit 有效采样系数
	output		logic               coeff_valid_rho_ExpandA,    // 4*23bit 有效采样系数信号

	output		logic   [91 : 0]    coeff_rho_ExpandS,          // 4*23bit 有效采样系数
	output		logic               coeff_valid_rho_ExpandS,    // 4*23bit 有效采样系数信号

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

typedef enum logic [3 : 0] {  
	S_IDLE,
	S_INIT,
	S_LOAD,
	S_SQUEEZE,
	S_EXPAND,
	S_STORE
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

always_ff @(posedge clk) begin
	if (!rstn)
		ready <= 1'b1;
	else if (state == S_IDLE)
		ready <= 1'b1;
	else 
		ready <= 1'b0;
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
		seed_domain_sep <= {zeta, `l, `k};
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

    if (state == S_EXPAND) begin
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

// --------------------------------
// 状态机
// --------------------------------

always_ff @(posedge clk) begin
	if (!rstn)
		state <= S_IDLE;
	else begin
		case (state)
			S_IDLE : begin
				if (start && ready)
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
				if (done_out_ExpandA)
					done <= 1'b1;
				else
					done <= 1'b0;
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


assign rho_ExpandA = seed_expand[1023 : 768];
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

assign rho_ExpandS = seed_expand[767 : 256];
ExpandS u_ExpandS(
	.clk            	( clk             		  ),
	.rstn           	( rstn            		  ),
	.rho_prime          ( rho_ExpandS             ),
	.start_expand   	( start_expand_ExpandS    ),
	.coeff          	( coeff_ExpandS           ),
	.coeff_valid    	( coeff_valid_ExpandS     ),
	.expand_done    	( expand_done_ExpandS     ),
	.nouce				( nouce					  ),
	.coeff_raw			( coeff_rawcoeff_raw      ),
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

endmodule
