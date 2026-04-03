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

    input       logic                       CoeffModq_ram_rd_en,       
    output      logic           [63 : 0]    CoeffModq_ori_coeff,       
    output      logic                       CoeffModq_ori_coeff_valid, 
    output      logic           [2 : 0]     CoeffModq_coeff_type,     
    output      logic                       CoeffModq_poly_start_pulse, 
    input       logic           [91 : 0]    CoeffModq_modq_coeff,      
    input       logic                       CoeffModq_modq_coeff_valid,

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

//* ==========================================================
//* 1. 参数与状态定义
//* ==========================================================

localparam  RHO_IN_PK_ADDR_START = `k * 256 * T1_BIT_LEN / 64;
localparam  RHO_IN_PK_ADDR_LEN = 32 * 8 / 64;
localparam  C_TILDE_IN_SIG_ADDR_START = 0;
localparam  C_TILDE_IN_SIG_ADDR_LEN = `c_tilde_bytes * 8 / 64;

typedef enum logic [2 : 0] { 
    S_IDLE,
    S_INIT,
    S_STAGE1,
    S_STAGE2, 
    S_STAGE3 
}state_t;

state_t                             state, state_d;

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
// 转载MU
logic                                           load_mu_start;
logic           [2 : 0]                         load_mu_start_d;
logic           [511 : 0]                       load_mu;
logic           [8 : 0]                         load_mu_cnt;
logic                                           load_process;
logic                                           load_mu_done;

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
logic           [11 : 0]                        ExpandC_store_addr;

//* ==========================================================
//* 3. 状态机
//* ==========================================================

always_ff @(posedge clk) begin
    if (!rstn) begin
        state <= S_IDLE;
        read_rho_start <= 1'b0;
        read_c_tilde_start <= 1'b0;
        // load_mu_start <= 1'b0;
        ExpandA_start <= 1'b0;
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
                // load_mu_start <= 1'b1;
                state <= S_STAGE1;
            end
            S_STAGE1 : begin
                read_rho_start <= 1'b0;
                read_c_tilde_start <= 1'b0;
                // load_mu_start <= 1'b0;
                if (read_rho_done && read_c_tilde_done) begin
                    ExpandA_start <= 1'b1;
                    state <= S_STAGE2;
                end
                else 
                    state <= S_STAGE1;
            end
            S_STAGE2 : begin
                ExpandA_start <= 1'b0;
                if (ExpandA_done) begin
                    state <= S_STAGE3;
                end                
                else
                    state <= S_STAGE2;
            end
            S_STAGE3: begin
                state <= S_STAGE3;
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

//* ==========================================================
//* 5. SHA3
//* ==========================================================
// always_comb begin
//     dout1 = 'd0;
//     dout_valid1 = 1'b0;
//     if (state == S_STAGE1) begin
//         dout1 = load_mu[511 : 504];
//         dout_valid1 = load_process;
//     end
// end
always_comb begin						// 扩展种子、矩阵A、向量S1、S2可能会复用端口 此处对端口进行分配 分配依据为状态机变量
    dout1 = 'd0; dout_valid1 = 'd0; dout_len1 = 'd0; mdlen1 = 'd0;
    init1 = 'd0; start1 = 'd0; start_out1 = 'd0; out_len1 = 'd0;
    
    dout2 = 'd0; dout_valid2 = 'd0; dout_len2 = 'd0; mdlen2 = 'd0;
    init2 = 'd0; start2 = 'd0; start_out2 = 'd0; out_len2 = 'd0;

    done_ExpandA = 'd0; done_out_ExpandA = 'd0; st_64bit_ExpandA = 'd0; st_64bit_valid_ExpandA = 'd0;

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

    // if (state == S_STAGE2) begin
    //     // ==========================================
    //     // 状态为 EXPAND_Y 时，SHA3-1 分配给 ExpandY
    //     // ==========================================
    //     dout1       = dout_ExpandY; 
    //     dout_valid1 = dout_valid_ExpandY; 
    //     dout_len1   = dout_len_ExpandY; 
    //     mdlen1      = mdlen_ExpandY; 
    //     init1       = init_ExpandY; 
    //     start1      = start_ExpandY; 
    //     start_out1  = start_out_ExpandY; 
    //     out_len1    = out_len_ExpandY; 
        
    //     done_ExpandY           = done1; 
    //     done_out_ExpandY       = done_out1; 
    //     st_64bit_ExpandY       = st_64bit1; 
    //     st_64bit_valid_ExpandY = st_64bit_valid1;
    // end

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

// --------------------------------
// 装载MU
// --------------------------------
// assign              dout_len1   =   'd64;
// assign              mdlen1      =   'd32;
// assign              out_len1    =   `c_tilde_bytes;
// always_ff @(posedge clk) begin
//     if (!rstn)
//         load_mu <= 'd0;
//     else if (state == S_INIT)
//         load_mu <= mu;
//     else if (load_process)
//         load_mu <= load_mu << 8;
//     else 
//         load_mu <= load_mu;
// end
// always_ff @(posedge clk) begin
//     if (!rstn)
//         load_mu_cnt <= 'd0;
//     else if (state == S_INIT)
//         load_mu_cnt <= 'd0;
//     else if (load_process) begin
//         if (load_mu_cnt == 'd63)
//             load_mu_cnt <= 'd0;
//         else
//             load_mu_cnt <= load_mu_cnt + 1'b1;
//     end
//     else 
//         load_mu_cnt <= load_mu_cnt;
// end
// always_ff @(posedge clk) begin
//     if (!rstn)
//         load_mu_done <= 1'b0;
//     else if (state == S_INIT)
//         load_mu_done <= 1'b0;
//     else if (load_mu_cnt == 'd63)
//         load_mu_done <= 1'b1;
//     else if (state == S_STAGE2)
//         load_mu_done <= 1'b0;
// end
// always_ff @(posedge clk) begin
//     if (!rstn) begin
//         load_process <= 1'b0;
//         init1 <= 1'b0;
//         start1 <= 1'b0;
//     end
//     else if (load_mu_start) begin
//         load_process <= 1'b0;
//         init1 <= 1'b1;
//         start1 <= 1'b0;
//     end
//     else if (load_mu_start_d[0]) begin
//         load_process <= 1'b0;
//         init1 <= 1'b0;
//         start1 <= 1'b1;
//     end
//     else if (load_mu_start_d[1]) begin
//         load_process <= 1'b1;
//         init1 <= 1'b0;
//         start1 <= 1'b0;
//     end
//     else if (load_mu_cnt == 'd63) begin
//         load_process <= 1'b0;
//         init1 <= 1'b0;
//         start1 <= 1'b0;
//     end
//     else begin
//         load_process <= load_process;
//         init1 <= init1;
//         start1 <= start1;
//     end 
// end
// always_ff @(posedge clk) begin
//     if (!rstn)
//         load_mu_start_d <= 'd0;
//     else 
//         load_mu_start_d <= {load_mu_start_d[1 : 0], load_mu_start};
// end

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

//ExpandC
// always_ff @(posedge clk) begin
//     if (!rstn)
//         rho_ExpandC <= 'd0;
//     else if (state == S_INIT)
//         rho_ExpandC <= 'd0;
//     else if (ExpandC_start)
//         rho_ExpandC <= rho;
//     else
//         rho_ExpandC <= rho_ExpandC;
// end
// always_ff @(posedge clk) begin
//     if (!rstn)
//         start_expand_ExpandC <= 1'b0;
//     else if (state == S_INIT)
//         start_expand_ExpandC <= 1'b0;
//     else if (ExpandC_start_d[0])
//         start_expand_ExpandC <= 1'b1;
//     else
//         start_expand_ExpandC <= 1'b0;
// end
// always_ff @(posedge clk) begin
//     if (!rstn)
//         ExpandC_done <= 1'b0;
//     else if (state == S_INIT)
//         ExpandC_done <= 1'b0;
//     else if (expand_done_ExpandC)
//         ExpandC_done <= 1'b1;
//     else if (state == S_STCGE3)
//         ExpandC_done <= 1'b0;
// end
// always_ff @(posedge clk) begin
//     if (!rstn)
//         ExpandC_store_addr <= 'd0;
//     else if (state == S_INIT)
//         ExpandC_store_addr <= 'd0;
//     else if (coeff_valid_ExpandC) 
//         ExpandC_store_addr <= ExpandC_store_addr + 1'b1;
//     else if (state == S_STCGE3)
//         ExpandC_store_addr <= 'd0;
//     else
//         ExpandC_store_addr <= ExpandC_store_addr;
// end
// always_ff @(posedge clk) begin
//     if (!rstn)
//         ExpandC_start_d <= 'd0;
//     else
//         ExpandC_start_d <= {ExpandC_start_d[1 : 0], ExpandC_start};
// end
endmodule
