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

    // --- BRAM 总线信号 ---
    output      logic           [91 : 0]    w_MatrixA_Coeff,
    output      logic                       w_MatrixA_Coeff_valid,
    output      logic           [11 : 0]    w_MatrixA_Coeff_addr,
    input       logic           [91 : 0]    r_MatrixA_Coeff [0 : K - 1],
    output      logic           [8 : 0]     r_MatrixA_Coeff_addr [0 : K - 1],

    // 【修改点1】：写位宽改为 92 位，以存储 NTT 变换后的结果
    output      logic           [91 : 0]    w_VectorS1_Coeff,                   
    output      logic                       w_VectorS1_Coeff_valid,
    output      logic           [8 : 0]     w_VectorS1_Coeff_addr,
    input       logic           [91 : 0]    r_VectorS1_Coeff,                   // 对q取模 无符号
    output      logic           [8 : 0]     r_VectorS1_Coeff_addr,

    // 【修改点1】：写位宽改为 92 位，以存储 NTT 变换后的结果
    output      logic           [91 : 0]    w_VectorS2_Coeff,                   
    output      logic                       w_VectorS2_Coeff_valid,
    output      logic           [8 : 0]     w_VectorS2_Coeff_addr,
    input       logic           [91 : 0]    r_VectorS2_Coeff [0 : K - 1],       // 对q取模 无符号
    output      logic           [5 : 0]     r_VectorS2_Coeff_addr [0 : K - 1],

    output      logic           [91 : 0]    w_VectorT_Coeff [0 : K - 1],
    output      logic                       w_VectorT_Coeff_valid [0 : K - 1],
    output      logic           [5 : 0]     w_VectorT_Coeff_addr [0 : K - 1],
    input       logic           [91 : 0]    r_VectorT_Coeff [0 : K - 1],
    output      logic           [5 : 0]     r_VectorT_Coeff_addr [0 : K - 1],

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

//* ==========================================================
//* 1. 参数与状态定义
//* ==========================================================
typedef enum logic [4 : 0] { 
    S_IDLE,                     // 空闲状态
    S_INIT,                     // 初始化状态
    S_PREPROC_NTT_ACK,          
    S_PREPROC_NTT_WAIT,
    S_PREPROC_NTT_STORE,
    S_EXPAND_A
} state_t;

state_t                             state, state_d;

localparam      S1_POLYS = L;
localparam      S2_POLYS = K;
localparam      T0_POLYS = K;
localparam      TOTAL_POLYS = S1_POLYS + S2_POLYS + T0_POLYS;

logic [4 : 0]   poly_cnt;

//* ==========================================================
//* 2. 内部信号统一定义
//* ==========================================================

// --- NTT/INTT (Poly_PAU) 信号 ---
logic           [8 : 0]             con_coeff_cnt;  
logic           [8 : 0]             con_coeff_cnt_d;

// --- coeffModq 控制信号 ---
logic                               ram_rd_en;
logic                               coeff_valid_d;
logic           [1 : 0]             current_coeff_type;

//* ==========================================================
//* 3. 状态机
//* ==========================================================

always_ff @(posedge clk) begin
    if (!rstn) begin
        state <= S_IDLE;
        poly_cnt <= 'd0;
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
                if (con_coeff_valid && con_coeff_cnt == 9'd63) begin
                    state <= S_PREPROC_NTT_STORE;
                end
                else begin
                    state <= S_PREPROC_NTT_WAIT;
                end
            end
            S_PREPROC_NTT_STORE : begin
                if (poly_cnt == TOTAL_POLYS - 1) begin
                    state <= S_EXPAND_A;
                end 
                else begin
                    poly_cnt <= poly_cnt + 1'b1;
                    state <= S_PREPROC_NTT_ACK;
                end
            end
            S_EXPAND_A : begin
                // 占位，留给后续扩展矩阵 A 等逻辑
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

always_ff @(posedge clk) begin
    if (!rstn)
        r_EncodeSK_Coeff_addr <= 'd0;
    else if (state == S_INIT || state == S_IDLE)
        r_EncodeSK_Coeff_addr <= 'd0;
    else if (ram_rd_en && state >= S_PREPROC_NTT_ACK)
        r_EncodeSK_Coeff_addr <= r_EncodeSK_Coeff_addr + 1;
end

always_ff @(posedge clk) begin
    if (!rstn) coeff_valid_d <= 1'b0;
    else coeff_valid_d <= (ram_rd_en && state >= S_PREPROC_NTT_ACK);
end

coeffModq u_coeffModq(
    .clk                ( clk ),
    .rstn               ( rstn ),
    .ram_rd_en          ( ram_rd_en ),
    .ori_coeff          ( r_EncodeSK_Coeff ),
    .ori_coeff_valid    ( coeff_valid_d ),
    .coeff_type         ( current_coeff_type ),
    .poly_start_pulse   ( state == S_PREPROC_NTT_ACK && ready == 1'b0 && request == 1'b1 ),
    .modq_coeff         ( ori_coeff ), 
    .modq_coeff_valid   ( ori_coeff_valid )
);

//* ==========================================================
//* 5. Poly_PAU 控制逻辑
//* ==========================================================
assign ext_operand = 'd0;
assign mode_config = 'd0; // 预处理阶段都是 NTT (0)

always_ff @(posedge clk) begin
    if (!rstn)
        request <= 1'b0;
    else if (state == S_PREPROC_NTT_ACK) begin
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
    else if (state == S_PREPROC_NTT_ACK)
        con_coeff_cnt <= 'd0;  // 每次握手前清零
    else if (con_coeff_valid)
        con_coeff_cnt <= con_coeff_cnt + 1'b1;
end

always_ff @(posedge clk) begin
    if (!rstn)
        con_coeff_cnt_d <= 'd0;
    else 
        con_coeff_cnt_d <= con_coeff_cnt;
end

//* ==========================================================
//* 6. NTT 结果回写分发 (Demux to BRAMs)
//* ==========================================================

logic [4:0] s2_idx;
logic [4:0] t0_idx;
assign s2_idx = poly_cnt - L[4:0];
assign t0_idx = poly_cnt - (L[4:0] + K[4:0]);

always_comb begin
    // 默认全零，防止产生锁存器
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

endmodule