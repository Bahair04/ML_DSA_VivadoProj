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

    input       logic           [63 : 0]    r_EncodeSign_Coeff,           
    output      logic           [9 : 0]     r_EncodeSign_Coeff_addr

);

typedef enum logic [2 : 0] { 
    S_IDLE

}state_t;

state_t                             state, state_d;

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

endmodule
