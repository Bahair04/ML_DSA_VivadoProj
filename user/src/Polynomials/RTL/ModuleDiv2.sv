//* 0-latency
`include "../../param_conf.v"
module ModuleDiv2(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [22 : 0]        data_in,

    output      logic                   valid_out,
    output      logic   [22 : 0]        data_out
);

localparam Q_PRIME = (`q + 1) >> 1;
always_comb begin
    if (data_in[0]) 
        data_out = Q_PRIME + (data_in >> 1);
    else
        data_out = data_in >> 1;
end
assign valid_out = valid_in;

endmodule
