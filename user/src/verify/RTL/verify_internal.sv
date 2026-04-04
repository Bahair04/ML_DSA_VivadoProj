`include "../../param_conf.v"
module verify_internal
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
    output      logic                       verify_ready,     // 准备标志
    output      logic                       done,           // 完成标志

    input       logic           [511 : 0]   mu,             // 64字节 预哈希消息

    // --- BRAM 总线信号 ---
    output      logic           [91 : 0]    w_MatrixA_Coeff,
    output      logic                       w_MatrixA_Coeff_valid,
    output      logic           [11 : 0]    w_MatrixA_Coeff_addr,
    input       logic           [91 : 0]    r_MatrixA_Coeff [0 : K - 1],
    output      logic           [8 : 0]     r_MatrixA_Coeff_addr [0 : K - 1],

    output      logic           [91 : 0]    w_VectorT_Coeff [0 : K - 1],
    output      logic                       w_VectorT_Coeff_valid [0 : K - 1],
    output      logic           [5 : 0]     w_VectorT_Coeff_addr [0 : K - 1],
    input       logic           [91 : 0]    r_VectorT_Coeff [0 : K - 1],
    output      logic           [5 : 0]     r_VectorT_Coeff_addr [0 : K - 1],

    input       logic           [63 : 0]    r_EncodePK_Coeff,           
    output      logic           [8 : 0]     r_EncodePK_Coeff_addr,

    input       logic           [63 : 0]    r_EncodeSig_Coeff,           
    output      logic           [9 : 0]     r_EncodeSig_Coeff_addr,

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

    // --- ExpandC ---
    output      logic           [255 : 0]   seed_ExpandC,           
    output      logic           [7 : 0]     tau_ExpandC,            
    output      logic                       start_expand_ExpandC,   
    output      logic                       low_rd_en_ExpandC,      
    input       logic           [1 : 0]     coeff_low_ExpandC,      
    output      logic           [7 : 0]     coeff_low_add_ExpandC,  
    input       logic                       coeff_low_valid_ExpandC,
    output      logic                       high_rd_en_ExpandC,     
    input       logic           [1 : 0]     coeff_high_ExpandC,     
    output      logic           [7 : 0]     coeff_high_add_ExpandC, 
    input       logic                       coeff_high_valid_ExpandC,
    input       logic                       expand_done_ExpandC,   

    input       logic           [7 : 0]     dout_ExpandC,           
    input       logic                       dout_valid_ExpandC,     
    input       logic           [31 : 0]    dout_len_ExpandC,       
    input       logic           [7 : 0]     mdlen_ExpandC,          
    input       logic                       init_ExpandC,           
    input       logic                       start_ExpandC,          
    output      logic                       done_ExpandC,           
    input       logic                       start_out_ExpandC,      
    input       logic           [31 : 0]    out_len_ExpandC,        
    output      logic                       done_out_ExpandC,       
    output      logic           [63 : 0]    st_64bit_ExpandC,       
    output      logic                       st_64bit_valid_ExpandC, 

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
    input       logic                       st_64bit_valid2,

    input       logic                       CoeffModq_ram_rd_en,       
    output      logic           [63 : 0]    CoeffModq_ori_coeff,       
    output      logic                       CoeffModq_ori_coeff_valid, 
    output      logic           [2 : 0]     CoeffModq_coeff_type,     
    output      logic                       CoeffModq_poly_start_pulse, 
    input       logic           [91 : 0]    CoeffModq_modq_coeff,      
    input       logic                       CoeffModq_modq_coeff_valid
);

//* ==========================================================
//* 1. 参数与状态定义
//* ==========================================================
localparam  T1_IN_PK_ADDR_START = 0;
localparam  T1_IN_PK_ADDR_LEN = `k * 256 * T1_BIT_LEN / 64;
localparam  RHO_IN_PK_ADDR_START = `k * 256 * T1_BIT_LEN / 64;
localparam  RHO_IN_PK_ADDR_LEN = 32 * 8 / 64;
localparam  C_TILDE_IN_SIG_ADDR_START = 0;
localparam  C_TILDE_IN_SIG_ADDR_LEN = `c_tilde_bytes * 8 / 64;
localparam  Z_IN_SIG_ADDR_START = C_TILDE_IN_SIG_ADDR_START + C_TILDE_IN_SIG_ADDR_LEN;
localparam  Z_IN_SIG_ADDR_LEN = `l * 256 * Z_BIT_LEN / 64;
localparam  H_IN_SIG_ADDR_START = Z_IN_SIG_ADDR_START + Z_IN_SIG_ADDR_LEN;
localparam  H_IN_SIG_ADDR_LEN = ((`omega + `k) * 8 + 32) / 64;

typedef enum logic [3 : 0] { 
    S_IDLE,
    S_INIT,
    S_STAGE1,
    S_STAGE2, 
    S_STAGE3,
    S_STAGE4,
    S_STAGE_ERROR 
}state_t;

typedef enum logic [2 : 0] { 
    S_SUB_IDLE,
    S_SUB_INIT,
    S_SUB_ACK,
    S_SUB_READ_LOAD,
    S_SUB_NTT_WAIT
}read_t_substate_t;

state_t                             state, state_d;
read_t_substate_t                   read_t_substate, read_t_substate_d;

//* ==========================================================
//* 2. 内部信号统一定义
//* ==========================================================

// --- STAGE1 ---
// 获取参数
logic           [255 : 0]                       rho;
logic                                           read_rho_start;
logic           [8 : 0]                         read_rho_from_pk_addr;
logic                                           read_rho_done;

logic                                           read_c_tilde_start;
logic           [`c_tilde_bytes * 8 - 1 : 0]    c_tilde;
logic           [9 : 0]                         read_c_tilde_from_sig_addr;
logic                                           read_c_tilde_done;

// --- STAGE2 ---
// ExpandA
logic                                           ExpandA_start;
logic           [2 : 0]                         ExpandA_start_d;
logic                                           ExpandA_done;
logic           [11 : 0]                        ExpandA_store_addr;

// ExpandC
logic                                           ExpandC_start;
logic           [2 : 0]                         ExpandC_start_d;
logic                                           ExpandC_done;
logic           [91 : 0]                        data_out;       // 扩展C时用到的拼接器 连接模块
logic                                           data_valid_out; // 扩展C时用到的拼接器有效信号 连接模块
logic           [5 : 0]                         data_cnt;       // 扩展C时用到的拼接器计数器 连接模块
(* ram_style = "distributed" *) logic [91 : 0]  c_hat [0 : 63];
logic           [91 : 0]                        r_c_hat;
logic           [5 : 0]                         r_c_hat_addr;
logic           [5 : 0]                         con_coeff_cnt;

// 获得h
logic                                           read_h_start;
logic           [2 : 0]                         read_h_start_d;
(* ram_style = "distributed" *) logic [3 : 0]   hint [0 : K - 1] [63 : 0];
logic                                           init;
logic           [63 : 0]                        unpack_in;
logic                                           unpack_valid;
logic           [3 : 0]  	                    hint_out;
logic        	                                hint_valid;
logic           [7 : 0]  	                    hint_valid_cnt;
logic        	                                unpack_done;
logic       	                                decode_err;
logic                                           decode_err_flag;
logic           [9 : 0]                         read_h_from_sig_addr;
logic                                           read_h_done;

// --- STAGE3 ---
// load mu 后续扩展c_tilde
logic                                           init_expand_c_tilde;
logic                                           start_expand_c_tilde;
logic                                           start_out_expand_c_tilde;
logic                                           load_mu_start;
logic           [2 : 0]                         load_mu_start_d;
logic           [511 : 0]                       load_mu;
logic           [8 : 0]                         load_mu_cnt;
logic                                           load_process;
logic                                           load_mu_done;

// 读取t1
logic                                           read_t1_start;
logic           [2 : 0]                         read_t1_start_d;
logic           [8 : 0]                         read_t1_from_pk_addr;
logic                                           read_t1_done;
logic           [63 : 0]                        read_t1_CoeffModq_ori_coeff;       
logic                                           read_t1_CoeffModq_ori_coeff_valid; 
logic           [2 : 0]                         read_t1_CoeffModq_coeff_type;     
logic                                           read_t1_CoeffModq_poly_start_pulse; 
logic           [8 : 0]                         read_t1_CoeffModq_modq_coeff_valid_cnt;  
logic           [8 : 0]                         read_t1_ntt_cnt;

//* ==========================================================
//* 3. 状态机
//* ==========================================================

always_ff @(posedge clk) begin
    if (!rstn) begin
        state <= S_IDLE;
        read_rho_start <= 1'b0;
        read_c_tilde_start <= 1'b0;
        ExpandA_start <= 1'b0;
        ExpandC_start <= 1'b0;
        load_mu_start <= 1'b0;
        read_t1_start <= 1'b0;
    end
    else begin
        case (state)
            S_IDLE : begin
                if (start && verify_ready)
                    state <= S_INIT;
                else
                    state <= S_IDLE;
            end
            S_INIT : begin
                read_rho_start <= 1'b1;
                read_c_tilde_start <= 1'b1;

                state <= S_STAGE1;
            end
            S_STAGE1 : begin
                read_rho_start <= 1'b0;
                read_c_tilde_start <= 1'b0;
                if (read_rho_done && read_c_tilde_done) begin
                    ExpandA_start <= 1'b1;
                    ExpandC_start <= 1'b1;
                    read_h_start <= 1'b1;
                    state <= S_STAGE2;
                end
                else 
                    state <= S_STAGE1;
            end
            S_STAGE2 : begin
                ExpandA_start <= 1'b0;
                ExpandC_start <= 1'b0;
                read_h_start <= 1'b0;
                if (decode_err_flag)
                    state <= S_STAGE_ERROR;
                else if (ExpandA_done && ExpandC_done && read_h_done) begin                
                    load_mu_start <= 1'b1;
                    read_t1_start <= 1'b1;
                    state <= S_STAGE3;
                end                
                else
                    state <= S_STAGE2;
            end
            S_STAGE3: begin
                load_mu_start <= 1'b0;
                if (load_mu_done && read_t1_done) begin
                    state <= S_STAGE4;
                end
                else 
                    state <= S_STAGE3;
            end
            S_STAGE4 : begin
                state <= S_STAGE4;
            end
            S_STAGE_ERROR : begin
                state <= S_STAGE_ERROR;
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
        verify_ready <= 1'b1;
    else if (state == S_IDLE)
        verify_ready <= 1'b1;
    else 
        verify_ready <= 1'b0;
end

always_ff @(posedge clk) begin
    if (!rstn)
        read_t_substate <= S_SUB_IDLE;
    else begin
        case (read_t_substate)
            S_SUB_IDLE : begin
                if (read_t1_start)
                    read_t_substate <= S_SUB_INIT;
                else 
                    read_t_substate <= S_SUB_IDLE;
            end
            S_SUB_INIT : begin
                read_t_substate <= S_SUB_ACK;
            end
            S_SUB_ACK : begin
                if (ready == 1'b0 && request)
                    read_t_substate <= S_SUB_READ_LOAD;
                else 
                    read_t_substate <= S_SUB_ACK;
            end
            S_SUB_READ_LOAD : begin
                if (read_t1_CoeffModq_modq_coeff_valid_cnt[5 : 0] == 'd63) 
                    read_t_substate <= S_SUB_NTT_WAIT;
                else 
                    read_t_substate <= S_SUB_READ_LOAD;
            end
            S_SUB_NTT_WAIT : begin
                if (read_t1_ntt_cnt == `k * 64 - 1)
                    read_t_substate <= S_SUB_IDLE;
                else if (read_t1_ntt_cnt[5 : 0] == 'd63 && con_coeff_valid) 
                    read_t_substate <= S_SUB_ACK;
                else 
                    read_t_substate <= S_SUB_NTT_WAIT;
            end
        endcase
    end
end

always_ff @(posedge clk) begin
    if (!rstn)
        read_t_substate_d <= S_SUB_IDLE;
    else 
        read_t_substate_d <= read_t_substate;
end

//* ==========================================================
//* 4. BRAM
//* ==========================================================
always_comb begin
    r_EncodePK_Coeff_addr    = 'd0;
    r_EncodeSig_Coeff_addr   = 'd0;

    if (state == S_STAGE1) begin
        r_EncodePK_Coeff_addr    = read_rho_from_pk_addr;
        r_EncodeSig_Coeff_addr   = read_c_tilde_from_sig_addr;
    end

    if (state == S_STAGE2) begin
        r_EncodeSig_Coeff_addr   = read_h_from_sig_addr;
    end

    if (state == S_STAGE3) begin
        r_EncodePK_Coeff_addr = read_t1_from_pk_addr;
    end

end
always_comb begin
    w_MatrixA_Coeff = 'd0;
    w_MatrixA_Coeff_valid = 1'b0;
    w_MatrixA_Coeff_addr = 'd0;
    if (state == S_STAGE2) begin
        w_MatrixA_Coeff = coeff_ExpandA;
        w_MatrixA_Coeff_valid = coeff_valid_ExpandA;
        w_MatrixA_Coeff_addr = ExpandA_store_addr;
    end
end

initial begin
    for (int i = 0; i < 64; i = i + 1)
        c_hat[i] <= 'd0;
end
always_ff @(posedge clk) begin
    if (state == S_STAGE2 && con_coeff_valid)
        c_hat[con_coeff_cnt] <= con_coeff;
    else 
        c_hat[con_coeff_cnt] <= c_hat[con_coeff_cnt];
    r_c_hat <= c_hat[r_c_hat_addr]; 
end

initial begin
    for (int i = 0; i < K; i = i + 1) begin
        for (int j = 0 ; j < 64 ; j = j + 1)
            hint[i][j] <= 'd0;     
    end
end
always_ff @(posedge clk) begin
    if (hint_valid) begin
        automatic logic [1 : 0] current_poly = hint_valid_cnt[7 : 6]; 
        automatic logic [5 : 0] current_group = hint_valid_cnt[5 : 0];
        
        automatic logic coeff_0 = hint_out[0];
        automatic logic coeff_1 = hint_out[1];
        automatic logic coeff_2 = hint_out[2];
        automatic logic coeff_3 = hint_out[3];
        
        hint[current_poly][current_group] <= hint_out;
    end
end

//* ==========================================================
//* 5. MUX : SHA3 & Poly_PAU & CoeffModq
//* ==========================================================
always_comb begin						// 扩展种子、矩阵A、向量S1、S2可能会复用端口 此处对端口进行分配 分配依据为状态机变量
    dout1 = 'd0; dout_valid1 = 'd0; dout_len1 = 'd0; mdlen1 = 'd0;
    init1 = 'd0; start1 = 'd0; start_out1 = 'd0; out_len1 = 'd0;
    
    dout2 = 'd0; dout_valid2 = 'd0; dout_len2 = 'd0; mdlen2 = 'd0;
    init2 = 'd0; start2 = 'd0; start_out2 = 'd0; out_len2 = 'd0;

    done_ExpandA = 'd0; done_out_ExpandA = 'd0; st_64bit_ExpandA = 'd0; st_64bit_valid_ExpandA = 'd0;
    done_ExpandC = 'd0; done_out_ExpandC = 'd0; st_64bit_ExpandC = 'd0; st_64bit_valid_ExpandC = 'd0;

    if (state == S_STAGE2) begin
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

    if (state == S_STAGE2) begin
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

    if (state == S_STAGE3) begin
        dout1       = load_mu[511 : 504];
        dout_valid1 = load_process;
        dout_len1   = 'd64;
        mdlen1      = 'd32;
        init1       = init_expand_c_tilde;
        start1      = start_expand_c_tilde;
        start_out1  = start_out_expand_c_tilde;
        out_len1    =   `c_tilde_bytes;
    end
end

always_comb begin
    mode_config = 'd0;
    ext_operand = 'd0;
    ori_coeff = 'd0;
    ori_coeff_valid = 1'b0;
    if (state == S_STAGE2) begin
        mode_config = 'd0;
        ori_coeff = data_out;
        ori_coeff_valid = data_valid_out;
    end

    if (state == S_STAGE3) begin
        mode_config = 'd0;
        for (int i = 0; i < 4; i = i + 1) begin
            ori_coeff[i * 23 +: 23] = CoeffModq_modq_coeff[i * 23 +: 23] << `d;
        end
        ori_coeff_valid = CoeffModq_modq_coeff_valid;
    end
end
always_ff @(posedge clk) begin
    if (!rstn)
        request <= 1'b0;
    else if (ready && ExpandC_start)
        request <= 1'b1;
    else if (ready && read_t_substate == S_SUB_ACK)
        request <= 1'b1;
    else if (!ready)
        request <= 1'b0;
    else 
        request <= request;
end

always_comb begin
    CoeffModq_ori_coeff             = 'd0;
    CoeffModq_ori_coeff_valid       = 1'b0;
    CoeffModq_coeff_type            = 'd0;
    CoeffModq_poly_start_pulse      = 'd0;
    if (state == S_STAGE3) begin
        CoeffModq_ori_coeff = read_t1_CoeffModq_ori_coeff;
        CoeffModq_ori_coeff_valid = read_t1_CoeffModq_ori_coeff_valid;
        CoeffModq_coeff_type = read_t1_CoeffModq_coeff_type;
        CoeffModq_poly_start_pulse = read_t1_CoeffModq_poly_start_pulse;
    end
end

//* ==========================================================
//* 6. STAGE1
//* ==========================================================

// --------------------------------
// 获得 rho
// --------------------------------
always_ff @(posedge clk) begin
    if (!rstn) 
        read_rho_from_pk_addr <= RHO_IN_PK_ADDR_START;
    else if (state == S_INIT)
        read_rho_from_pk_addr <= RHO_IN_PK_ADDR_START;
    else if (read_rho_start)
        read_rho_from_pk_addr <= read_rho_from_pk_addr + 1'b1;
    else if (read_rho_from_pk_addr > RHO_IN_PK_ADDR_START) begin
        if (read_rho_from_pk_addr == RHO_IN_PK_ADDR_START + RHO_IN_PK_ADDR_LEN)
            read_rho_from_pk_addr <= RHO_IN_PK_ADDR_START;
        else 
            read_rho_from_pk_addr <= read_rho_from_pk_addr + 1'b1;
    end
end
always_ff @(posedge clk) begin
    if (!rstn)
        read_rho_done <= 1'b0;
    else if (state == S_INIT)
        read_rho_done <= 1'b0;
    else if (read_rho_from_pk_addr == RHO_IN_PK_ADDR_START + RHO_IN_PK_ADDR_LEN)
        read_rho_done <= 1'b1;
    else if (state == S_STAGE2)
        read_rho_done <= 1'b0;
end
always_ff @(posedge clk) begin
    if (!rstn)
        rho <= 'd0;
    else if (state == S_INIT)
        rho <= 'd0;
    else if (read_rho_from_pk_addr > RHO_IN_PK_ADDR_START)
        rho <= (rho << 64) | r_EncodePK_Coeff;
    else 
        rho <= rho;
end

// --------------------------------
// 获得 c_tilde
// --------------------------------
always_ff @(posedge clk) begin
    if (!rstn)
        read_c_tilde_from_sig_addr <= C_TILDE_IN_SIG_ADDR_START;
    else if (state == S_INIT)
        read_c_tilde_from_sig_addr <= C_TILDE_IN_SIG_ADDR_START;
    else if (read_c_tilde_start)
        read_c_tilde_from_sig_addr <= read_c_tilde_from_sig_addr + 1'b1;
    else if (read_c_tilde_from_sig_addr > C_TILDE_IN_SIG_ADDR_START) begin
        if (read_c_tilde_from_sig_addr == C_TILDE_IN_SIG_ADDR_START + C_TILDE_IN_SIG_ADDR_LEN)
            read_c_tilde_from_sig_addr <= C_TILDE_IN_SIG_ADDR_START;
        else 
            read_c_tilde_from_sig_addr <= read_c_tilde_from_sig_addr + 1'b1;
    end
end
always_ff @(posedge clk) begin
    if (!rstn)
        read_c_tilde_done <= 1'b0;
    else if (state == S_INIT)
        read_c_tilde_done <= 1'b0;
    else if (read_c_tilde_from_sig_addr == C_TILDE_IN_SIG_ADDR_START + C_TILDE_IN_SIG_ADDR_LEN)
        read_c_tilde_done <= 1'b1;
    else if (state == S_STAGE2)
        read_c_tilde_done <= 1'b0;
end
always_ff @(posedge clk) begin
    if (!rstn)
        c_tilde <= 'd0;
    else if (state == S_INIT)
        c_tilde <= 'd0;
    else if (read_c_tilde_from_sig_addr > C_TILDE_IN_SIG_ADDR_START)
        c_tilde <= (c_tilde << 64) | r_EncodeSig_Coeff;
    else 
        c_tilde <= c_tilde;
end

//* ==========================================================
//* 7. STAGE2
//* ==========================================================
// ExpandA
always_ff @(posedge clk) begin
    if (!rstn)
        rho_ExpandA <= 'd0;
    else if (state == S_INIT)
        rho_ExpandA <= 'd0;
    else if (ExpandA_start)
        rho_ExpandA <= {<<8{rho}};
    else
        rho_ExpandA <= rho_ExpandA;
end
always_ff @(posedge clk) begin
    if (!rstn)
        start_expand_ExpandA <= 1'b0;
    else if (state == S_INIT)
        start_expand_ExpandA <= 1'b0;
    else if (ExpandA_start_d[0])
        start_expand_ExpandA <= 1'b1;
    else
        start_expand_ExpandA <= 1'b0;
end
always_ff @(posedge clk) begin
    if (!rstn)
        ExpandA_done <= 1'b0;
    else if (state == S_INIT)
        ExpandA_done <= 1'b0;
    else if (expand_done_ExpandA)
        ExpandA_done <= 1'b1;
    else if (state == S_STAGE3)
        ExpandA_done <= 1'b0;
end
always_ff @(posedge clk) begin
    if (!rstn)
        ExpandA_store_addr <= 'd0;
    else if (state == S_INIT)
        ExpandA_store_addr <= 'd0;
    else if (coeff_valid_ExpandA) 
        ExpandA_store_addr <= ExpandA_store_addr + 1'b1;
    else if (state == S_STAGE3)
        ExpandA_store_addr <= 'd0;
    else
        ExpandA_store_addr <= ExpandA_store_addr;
end
always_ff @(posedge clk) begin
    if (!rstn)
        ExpandA_start_d <= 'd0;
    else
        ExpandA_start_d <= {ExpandA_start_d[1 : 0], ExpandA_start};
end

// ExpandC
always_ff @(posedge clk) begin
    if (!rstn) begin
        seed_ExpandC <= 'd0;
        tau_ExpandC <= 'd0;
    end
    else if (state == S_INIT) begin
        seed_ExpandC <= 'd0;
        tau_ExpandC <= 'd0;
    end
    else if (ExpandC_start) begin
        seed_ExpandC <= {<<8{c_tilde}};
        tau_ExpandC <= `tau;
    end
    else begin
        seed_ExpandC <= seed_ExpandC;
        tau_ExpandC <= tau_ExpandC;
    end
end
always_ff @(posedge clk) begin
    if (!rstn)
        start_expand_ExpandC <= 1'b0;
    else if (state == S_INIT)
        start_expand_ExpandC <= 1'b0;
    else if (ExpandC_start_d[0])
        start_expand_ExpandC <= 1'b1;
    else
        start_expand_ExpandC <= 1'b0;
end
always_ff @(posedge clk) begin
    if (!rstn) begin
        low_rd_en_ExpandC <= 1'b0;
        high_rd_en_ExpandC <= 1'b0;
    end
    else if (state == S_INIT) begin
        low_rd_en_ExpandC <= 1'b0;
        high_rd_en_ExpandC <= 1'b0;
    end
    else if (expand_done_ExpandC) begin
        low_rd_en_ExpandC <= 1'b1;
        high_rd_en_ExpandC <= 1'b1;
    end 
    else if (coeff_low_add_ExpandC == 'd254 && coeff_high_add_ExpandC == 'd255) begin
        low_rd_en_ExpandC <= 1'b0;
        high_rd_en_ExpandC <= 1'b0;
    end
    else begin
        low_rd_en_ExpandC <= low_rd_en_ExpandC;
        high_rd_en_ExpandC <= high_rd_en_ExpandC;
    end
end
always_ff @(posedge clk) begin
    if (!rstn) begin
        coeff_low_add_ExpandC <= 'd0;
        coeff_high_add_ExpandC <= 'd1;
    end
    else if (state == S_INIT) begin
        coeff_low_add_ExpandC <= 'd0;
        coeff_high_add_ExpandC <= 'd1;
    end
    else begin
        if (low_rd_en_ExpandC) begin
            if (coeff_low_add_ExpandC == 'd254)
                coeff_low_add_ExpandC <= 'd0;
            else 
                coeff_low_add_ExpandC <= coeff_low_add_ExpandC + 'd2;
        end
        else 
            coeff_low_add_ExpandC <= coeff_low_add_ExpandC;
        if (high_rd_en_ExpandC) begin
            if (coeff_high_add_ExpandC == 'd255)
                coeff_high_add_ExpandC <= 'd1;
            else 
                coeff_high_add_ExpandC <= coeff_high_add_ExpandC + 'd2;
        end
        else 
            coeff_high_add_ExpandC <= coeff_high_add_ExpandC;
    end
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
always_ff @(posedge clk) begin
    if (!rstn)
        data_cnt <= 'd0;
    else if (state == S_INIT)
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
always_ff @(posedge clk) begin
    if (!rstn)
        con_coeff_cnt <= 'd0;
    else if (state == S_INIT)
        con_coeff_cnt <= 'd0;
    else if (con_coeff_valid) begin
        if (con_coeff_cnt == 'd63)
            con_coeff_cnt <= 'd0;
        else
            con_coeff_cnt <= con_coeff_cnt + 'd1; 
    end
    else 
        con_coeff_cnt <= con_coeff_cnt;
end
always_ff @(posedge clk) begin
    if (!rstn)
        ExpandC_done <= 1'b0;
    else if (state == S_INIT)
        ExpandC_done <= 1'b0;
    else if (con_coeff_cnt == 'd63 && con_coeff_valid)
        ExpandC_done <= 1'b1;
    else if (state == S_STAGE3)
        ExpandC_done <= 1'b0;
end
always_ff @(posedge clk) begin
    if (!rstn)
        ExpandC_start_d <= 'd0;
    else
        ExpandC_start_d <= {ExpandC_start_d[1 : 0], ExpandC_start};
end

// 获得h
always_ff @(posedge clk) begin
    if (!rstn)
        init <= 1'b0;
    else if (state == S_INIT)
        init <= 1'b0;
    else if (read_h_start)
        init <= 1'b1;
    else 
        init <= 1'b0;
end
always_ff @(posedge clk) begin
    if (!rstn)
        read_h_from_sig_addr <= H_IN_SIG_ADDR_START;
    else if (state == S_INIT)
        read_h_from_sig_addr <= H_IN_SIG_ADDR_START;
    else if (read_h_start_d[0])
        read_h_from_sig_addr <= read_h_from_sig_addr + 'd1;
    else if (read_h_from_sig_addr > H_IN_SIG_ADDR_START) begin
        if (read_h_from_sig_addr == H_IN_SIG_ADDR_START + H_IN_SIG_ADDR_LEN)
            read_h_from_sig_addr <= H_IN_SIG_ADDR_START;
        else
            read_h_from_sig_addr <= read_h_from_sig_addr + 'd1; 
    end
end
assign unpack_in = r_EncodeSig_Coeff;
assign unpack_valid = (read_h_from_sig_addr > H_IN_SIG_ADDR_START) && (read_h_from_sig_addr <= H_IN_SIG_ADDR_START + H_IN_SIG_ADDR_LEN);
always_ff @(posedge clk) begin
    if (!rstn)
        read_h_start_d <= 'd0;
    else 
        read_h_start_d <= {read_h_start_d[1 : 0], read_h_start};
end
always_ff @(posedge clk) begin
    if (!rstn)
        read_h_done <= 1'b0;
    else if (state == S_INIT)
        read_h_done <= 1'b0;
    else if (hint_valid && hint_valid_cnt[7 : 6] == `k - 1 && hint_valid_cnt[5 : 0] == 'd63)
        read_h_done <= 1'b1; 
    else if (state == S_STAGE3)
        read_h_done <= 1'b0;
    else 
        read_h_done <= read_h_done;
end
always_ff @(posedge clk) begin
    if (!rstn)
        decode_err_flag <= 1'b0;
    else if (state == S_INIT)
        decode_err_flag <= 1'b0;
    else if (decode_err)
        decode_err_flag <= 1'b1;
    else 
        decode_err_flag <= decode_err_flag;
end
HintBitUnpack_64bit u_HintBitUnpack_64bit(
	.clk            	( clk             ),
	.rstn           	( rstn            ),
	.init           	( init            ),
	.unpack_in      	( unpack_in       ),
	.unpack_valid   	( unpack_valid    ),
	.hint_out       	( hint_out        ),
	.hint_valid     	( hint_valid      ),
	.hint_valid_cnt 	( hint_valid_cnt  ),
	.unpack_done    	( unpack_done     ),
	.decode_err     	( decode_err      )
);


//* ==========================================================
//* 8. STAGE3
//* ==========================================================
// load_mu 后续扩展c_tilde
always_ff @(posedge clk) begin
    if (!rstn)
        load_mu <= 'd0;
    else if (state == S_INIT)
        load_mu <= mu;
    else if (load_process)
        load_mu <= load_mu << 8;
    else 
        load_mu <= load_mu;
end
always_ff @(posedge clk) begin
    if (!rstn)
        load_mu_cnt <= 'd0;
    else if (state == S_INIT)
        load_mu_cnt <= 'd0;
    else if (load_process) begin
        if (load_mu_cnt == 'd63)
            load_mu_cnt <= 'd0;
        else
            load_mu_cnt <= load_mu_cnt + 1'b1;
    end
    else 
        load_mu_cnt <= load_mu_cnt;
end
always_ff @(posedge clk) begin
    if (!rstn)
        load_mu_done <= 1'b0;
    else if (state == S_INIT)
        load_mu_done <= 1'b0;
    else if (load_mu_cnt == 'd63)
        load_mu_done <= 1'b1;
    else if (state == S_STAGE2)
        load_mu_done <= 1'b0;
end
always_ff @(posedge clk) begin
    if (!rstn) begin
        load_process <= 1'b0;
        init_expand_c_tilde <= 1'b0;
        start_expand_c_tilde <= 1'b0;
    end
    else if (load_mu_start) begin
        load_process <= 1'b0;
        init_expand_c_tilde <= 1'b1;
        start_expand_c_tilde <= 1'b0;
    end
    else if (load_mu_start_d[0]) begin
        load_process <= 1'b0;
        init_expand_c_tilde <= 1'b0;
        start_expand_c_tilde <= 1'b1;
    end
    else if (load_mu_start_d[1]) begin
        load_process <= 1'b1;
        init_expand_c_tilde <= 1'b0;
        start_expand_c_tilde <= 1'b0;
    end
    else if (load_mu_cnt == 'd63) begin
        load_process <= 1'b0;
        init_expand_c_tilde <= 1'b0;
        start_expand_c_tilde <= 1'b0;
    end
    else begin
        load_process <= load_process;
        init_expand_c_tilde <= init_expand_c_tilde;
        start_expand_c_tilde <= start_expand_c_tilde;
    end 
end
always_ff @(posedge clk) begin
    if (!rstn)
        load_mu_start_d <= 'd0;
    else 
        load_mu_start_d <= {load_mu_start_d[1 : 0], load_mu_start};
end

// 读取t1 同时完成scale NTT并存入BRAM
assign read_t1_CoeffModq_coeff_type = 'd4;
assign read_t1_CoeffModq_ori_coeff = {<<8{r_EncodePK_Coeff}};
always_ff @(posedge clk) begin
    if (!rstn)
        read_t1_CoeffModq_poly_start_pulse <= 1'b0;
    else if (read_t_substate == S_SUB_INIT)
        read_t1_CoeffModq_poly_start_pulse <= 1'b0;
    else if (read_t_substate_d == S_SUB_ACK && read_t_substate == S_SUB_READ_LOAD)
        read_t1_CoeffModq_poly_start_pulse <= 1'b1;
    else 
        read_t1_CoeffModq_poly_start_pulse <= 1'b0;
end
always_ff @(posedge clk) begin
    if (!rstn)
        read_t1_from_pk_addr <= T1_IN_PK_ADDR_START;
    else if (read_t_substate == S_SUB_INIT)
        read_t1_from_pk_addr <= T1_IN_PK_ADDR_START;
    else if (CoeffModq_ram_rd_en && read_t_substate == S_SUB_READ_LOAD) begin
        if (read_t1_from_pk_addr == T1_IN_PK_ADDR_START + T1_IN_PK_ADDR_LEN)
            read_t1_from_pk_addr <= T1_IN_PK_ADDR_START;
        else 
            read_t1_from_pk_addr <= read_t1_from_pk_addr + 'd1;
    end
    else
        read_t1_from_pk_addr <= read_t1_from_pk_addr;
end
always_ff @(posedge clk) begin
    if (!rstn)
        read_t1_CoeffModq_ori_coeff_valid <= 1'b0;
    else 
        read_t1_CoeffModq_ori_coeff_valid <= CoeffModq_ram_rd_en && read_t_substate == S_SUB_READ_LOAD; 
end
always_ff @(posedge clk) begin
    if (!rstn)
        read_t1_CoeffModq_modq_coeff_valid_cnt <= 'd0;
    else if (read_t_substate == S_SUB_INIT)
        read_t1_CoeffModq_modq_coeff_valid_cnt <= 'd0;
    else if (CoeffModq_modq_coeff_valid) begin
        if (read_t1_CoeffModq_modq_coeff_valid_cnt == `k * 64 - 1)
            read_t1_CoeffModq_modq_coeff_valid_cnt <= 'd0;
        else
            read_t1_CoeffModq_modq_coeff_valid_cnt <= read_t1_CoeffModq_modq_coeff_valid_cnt + 1;
    end
    else 
        read_t1_CoeffModq_modq_coeff_valid_cnt <= read_t1_CoeffModq_modq_coeff_valid_cnt;
end
always_ff @(posedge clk) begin
    if (!rstn)
        read_t1_ntt_cnt <= 'd0;
    else if (read_t_substate == S_SUB_INIT)
        read_t1_ntt_cnt <= 'd0;
    else if (read_t_substate == S_SUB_NTT_WAIT && con_coeff_valid) begin
        if (read_t1_ntt_cnt == `k * 64 - 1)
            read_t1_ntt_cnt <= 'd0;
        else 
            read_t1_ntt_cnt <= read_t1_ntt_cnt + 1; 
    end
    else
        read_t1_ntt_cnt <= read_t1_ntt_cnt;
end
// always_ff @(posedge clk) begin
//     if (!rstn)
//         read_t1_done <= 1'b0;
//     else if (state == S_INIT)
//         read_t1_done <= 1'b0;
//     else if ((read_t1_from_pk_addr == T1_IN_PK_ADDR_START + T1_IN_PK_ADDR_LEN) && CoeffModq_ram_rd_en && state == S_STAGE3)
//         read_t1_done <= 1'b1;
//     else if (state == S_STAGE4)
//         read_t1_done <= 1'b0;
//     else
//         read_t1_done <= read_t1_done;
// end
always_ff @(posedge clk) begin
    if (!rstn)
        read_t1_start_d <= 'd0;
    else
        read_t1_start_d <= {read_t1_start_d[1 : 0], read_t1_start};
end
endmodule
