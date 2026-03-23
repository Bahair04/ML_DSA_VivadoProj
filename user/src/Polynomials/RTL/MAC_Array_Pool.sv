`include "../../param_conf.v"

module MAC_Array_Pool #(
    parameter K = `k
)(
    input  logic                clk,
    input  logic                rstn,
    
    // --- 控制与数据输入 ---
    input  logic                valid_in,
    input  logic    [91:0]      data_in1 [0 : K-1], // Matrix A
    input  logic    [91:0]      data_in2,           // NTT(S1) 
    input  logic    [91:0]      data_in3 [0 : K-1], // Vector T (或 0)

    // --- 数据输出 ---
    output logic                valid_out,
    output logic    [91:0]      data_out [0 : K-1]
);

    logic valid_out_matrix [0 : K-1] [0 : 3];

    generate
        for (genvar i = 0 ; i < K ; i = i + 1) begin : row_mac_inst
            wire [91:0] row_data_out;
            for (genvar j = 0 ; j < 4 ; j = j + 1) begin : col_mac_inst
                wire [22:0] mac_out;
                ModuleMAC u_ModuleMAC(
                    .clk        ( clk ),
                    .rstn       ( rstn ),
                    .valid_in   ( valid_in ),
                    .data_in1   ( data_in1[i][23 * j +: 23] ),
                    .data_in2   ( data_in2[23 * j +: 23] ),
                    .data_in3   ( data_in3[i][23 * j +: 23] ),
                    .valid_out  ( valid_out_matrix[i][j] ),
                    .data_out   ( mac_out )
                );
                assign row_data_out[23 * j +: 23] = mac_out;
            end
            assign data_out[i] = row_data_out;
        end
    endgenerate

    // 所有流水线延时相同，取第一个的 valid 即可
    assign valid_out = valid_out_matrix[0][0];

endmodule