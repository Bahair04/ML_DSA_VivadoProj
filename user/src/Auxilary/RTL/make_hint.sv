`include "../../param_conf.v"
module make_hint(
    // --- 时钟与复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- 输入信号接口 ---
    input       logic   [22 : 0]    z,
    input       logic   [22 : 0]    t,
    input       logic               i_valid,

    // --- 输出信号接口 ---
    output      logic               hint,
    output      logic               o_valid     
);

endmodule
