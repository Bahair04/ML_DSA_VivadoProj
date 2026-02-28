module ReconfigComputeUnit(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [22 : 0]        A,
    input       logic   [22 : 0]        B,
    input       logic   [22 : 0]        Z,

    output      logic                   valid_out,
    output      logic   [22 : 0]        U,
    output      logic   [22 : 0]        V
);

endmodule
