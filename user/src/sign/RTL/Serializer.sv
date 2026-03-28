`include  "../../param_conf.v"
module Serializer#(
    parameter K = `k,
    parameter L = `l,
    parameter T1_BIT_LEN = $clog2(`q - 1) - `d,                     // default : 10
    parameter S1_S2_BIT_LEN = $clog2(2 * `eta) + 1,                 // default : 3
    parameter T0_BIT_LEN = `d,                                      // default : 13
    parameter Z_BIT_LEN = `bit_count,                               // default : 18
    parameter H_BIT_LEN = 'd1,
    parameter INPUT_WIDTH = `input_width          
)(
    // --- 时钟和复位信号 ---
    input       logic                           clk,
    input       logic                           rstn,

    input       logic   [5 : 0]                 w_in_0,
    input       logic   [5 : 0]                 w_in_1,
    input       logic   [5 : 0]                 w_in_2,
    input       logic   [5 : 0]                 w_in_3,
    input       logic                           w_in_valid,

    output      logic   [7 : 0]                 w_out,
    output      logic                           w_out_valid                        
);

logic                                       srst;
logic           [INPUT_WIDTH - 1 : 0]       din;
logic                                       wr_en;
logic                                       rd_en;
logic           [INPUT_WIDTH - 1 : 0]       dout;
logic                                       full;
logic                                       empty;
logic           [9 : 0]                     data_count;
logic           [INPUT_WIDTH - 1 : 0]       dout_r;
logic           [1 : 0]                     output_cnt;

always_ff @(posedge clk) begin
    if (!rstn)
        rd_en <= 1'b0;
    else if (rd_en)
        rd_en <= 1'b0;
    else if (output_cnt == 'd0 && data_count > 0 && empty == 1'b0)
        rd_en <= 1'b1;
    else 
        rd_en <= 1'b0;
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        output_cnt <= 'd0;
        w_out_valid <= 1'b0;
        w_out <= 'd0;
        dout_r <= 'd0;
    end
    else if (rd_en) begin
        output_cnt <= output_cnt + 1'b1;
        w_out_valid <= 1'b1;
        w_out <= dout[7 : 0];
        dout_r <= dout;
    end
    else if (output_cnt > 0) begin
        if (output_cnt == INPUT_WIDTH / 8 - 1)
            output_cnt <= 'd0;
        else
            output_cnt <= output_cnt + 1'b1;
        w_out <= dout_r[output_cnt * 8 +: 8];
        w_out_valid <= 1'b1;
    end
    else begin
        output_cnt <= 'd0;
        w_out <= 'd0;
        w_out_valid <= 1'b0;
        dout_r <= 'd0;
    end
end

assign srst = ~rstn;
assign din = {
    w_in_3[INPUT_WIDTH / 4 - 1 : 0],
    w_in_2[INPUT_WIDTH / 4 - 1 : 0],
    w_in_1[INPUT_WIDTH / 4 - 1 : 0],
    w_in_0[INPUT_WIDTH / 4 - 1 : 0]
};
assign wr_en = w_in_valid;
generate // FIFO类型 : FWFT
    if (`input_width == 16) begin
        w1_bytes_fifo_16 u_w1_bytes_fifo_16 (
            .clk(clk),                // input wire clk
            .srst(srst),              // input wire srst
            .din(din),                // input wire [15 : 0] din
            .wr_en(wr_en),            // input wire wr_en
            .rd_en(rd_en),            // input wire rd_en
            .dout(dout),              // output wire [15 : 0] dout
            .full(full),              // output wire full
            .empty(empty),            // output wire empty
            .data_count(data_count)  // output wire [9 : 0] data_count
        );
    end
    else begin
        w1_bytes_fifo_24 your_instance_name (
            .clk(clk),                // input wire clk
            .srst(srst),              // input wire srst
            .din(din),                // input wire [23 : 0] din
            .wr_en(wr_en),            // input wire wr_en
            .rd_en(rd_en),            // input wire rd_en
            .dout(dout),              // output wire [23 : 0] dout
            .full(full),              // output wire full
            .empty(empty),            // output wire empty
            .data_count(data_count)  // output wire [9 : 0] data_count
        );
    end
endgenerate

endmodule
