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
    input       logic                       CoeffModq_modq_coeff_valid

);

//* ==========================================================
//* 1. 参数与状态定义
//* ==========================================================

localparam  RHO_IN_PK_ADDR_START = `k * 256 * T1_BIT_LEN / 64;
localparam  RHO_IN_PK_ADDR_LEN = 32 * 8 / 64;
typedef enum logic [2 : 0] { 
    S_IDLE,
    S_INIT,
    S_PREPROC_GET_RHO,
    S_EXPAND_A,
    S_STORE_A

}state_t;
state_t                             state, state_d;

//* ==========================================================
//* 2. 内部信号统一定义
//* ==========================================================

// --- 读取rho ---
logic           [255 : 0]           rho;

//* ==========================================================
//* 3. 状态机
//* ==========================================================

always_ff @(posedge clk) begin
    if (!rstn)
        state <= S_IDLE;
    else begin
        case (state)
            S_IDLE : begin
                if (start && verify_ready)
                    state <= S_INIT;
                else 
                    state <= S_IDLE;
            end
            S_INIT : begin
                state <= S_PREPROC_GET_RHO;
            end
            S_PREPROC_GET_RHO : begin
                if (r_EncodePK_Coeff_addr == RHO_IN_PK_ADDR_START + RHO_IN_PK_ADDR_LEN)
                    state <= S_EXPAND_A;
                else
                    state <= S_PREPROC_GET_RHO;
            end
            S_EXPAND_A : begin
                
            end
            S_STORE_A : begin

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

always_ff @(posedge clk) begin
    if (!rstn) 
        r_EncodePK_Coeff_addr <= 'd0;
    else if (state == S_INIT)
        r_EncodePK_Coeff_addr <= RHO_IN_PK_ADDR_START;
    else if (state == S_PREPROC_GET_RHO) begin
        if (r_EncodePK_Coeff_addr == RHO_IN_PK_ADDR_START + RHO_IN_PK_ADDR_LEN)
            r_EncodePK_Coeff_addr <= 'd0;
        else
            r_EncodePK_Coeff_addr <= r_EncodePK_Coeff_addr + 1'b1;
    end
end


//* ==========================================================
//* 5. 读取RHO
//* ==========================================================

always_ff @(posedge clk) begin
    if (!rstn)
        rho <= 'd0;
    else if (state == S_INIT)
        rho <= 'd0;
    else if (state_d == S_PREPROC_GET_RHO && state == S_PREPROC_GET_RHO)
        rho <= (rho << 64) | r_EncodePK_Coeff;
    else 
        rho <= rho;
end

endmodule
