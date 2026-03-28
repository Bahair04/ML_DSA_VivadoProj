`include "../../param_conf.v"
module Gearbox_2to4(
    input       logic               clk,
    input       logic               rstn,

    input       logic   [1 : 0]     data_low,
    input       logic   [1 : 0]     data_high,
    input       logic               data_valid,

    output      logic   [91 : 0]    data_out,
    output      logic               data_valid_out
);

logic                               data_count;
logic           [22 : 0]            temp [0 : 3];
logic                               data_valid_d;
logic                               data_count_d;

function logic [22 : 0] data_modq (input logic [1 : 0] data);
    case (data)
        2'd0: data_modq = 23'd0;
        2'd1: data_modq = 23'd1;
        2'd2: data_modq = 23'd8380416; // q - 1
        default: data_modq = 23'd0;    // 兜底保平安
    endcase
endfunction

always_ff @(posedge clk) begin
    if (!rstn) 
        data_count <= 'd0;        
    else if (data_valid) begin
        if (data_count == 'd1)
            data_count <= 'd0;
        else 
            data_count <= data_count + 'd1;
    end
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        data_valid_d <= 1'b0;
        data_count_d <= 'd0;
    end
    else begin 
        data_valid_d <= data_valid;
        data_count_d <= data_count;
    end
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        for (int i = 0 ; i < 4 ; i = i + 1)
            temp[i] <= 'd0;
    end
    else if (data_valid) begin 
        if (data_count == 'd0) begin
            temp[0] <= data_modq(data_low);
            temp[1] <= data_modq(data_high);
        end
        else begin
            temp[2] <= data_modq(data_low);
            temp[3] <= data_modq(data_high);
        end
    end
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        data_out <= 'd0;
        data_valid_out <= 1'b0;
    end
    else if (data_valid_d && data_count_d) begin
        data_out <= {temp[3], temp[2], temp[1], temp[0]};
        data_valid_out <= 1'b1;
    end
    else begin
        data_out <= 'd0;
        data_valid_out <= 1'b0;
    end
end

endmodule
