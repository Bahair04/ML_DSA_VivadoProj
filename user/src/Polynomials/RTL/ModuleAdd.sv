//* 0-latency
`include "../../param_conf.v"
module ModuleAdd(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [22 : 0]        data_in1,
    input       logic   [22 : 0]        data_in2,

    output      logic                   valid_out,
    output      logic   [22 : 0]        data_out
);

logic   [23 : 0]            raw_add;
assign raw_add = {1'b0, data_in1} + {1'b0, data_in2};
always_comb begin
    if (raw_add > `q) begin
        logic [23 : 0] tmp = raw_add - `q;
        data_out = tmp[22 : 0];
    end
    else
        data_out = raw_add[22 : 0];
end
assign valid_out = valid_in;

endmodule
