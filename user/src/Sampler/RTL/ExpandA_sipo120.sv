module ExpandA_sipo120(
    // --- 时钟与复位接口 ---
    input       logic               clk,
    input       logic               rstn,

    // --- 顶层(ExpandA)传入的控制与数据接口 ---
    input       logic               init,
    input       logic   [63 : 0]    st_64bit,
    input       logic               st_64bit_valid,

    // --- 120位并行输出接口 ---
    output      logic   [119 : 0]   sipo_o,
    output      logic               sipo_o_valid
);

// ==========================================================
// 参数定义
// ==========================================================

// --- FIFO ---
logic                       rd_en;
logic       [127 : 0]       fifo_dout_raw;
logic       [127 : 0]       fifo_dout;
logic                       full;
logic                       empty;
logic       [8 : 0]         rd_data_count;

// --- 移位寄存器 ---
logic       [255 : 0]       shift_reg;
logic       [7 : 0]         shift_reg_len;

// ==========================================================
// 具体逻辑实现
// ==========================================================
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        rd_en <= 1'b0;
    else if (rd_data_count >= 'd1 && empty == 1'b0)
        rd_en <= 1'b1;
    else 
        rd_en <= 1'b0;
end

assign fifo_dout = {fifo_dout_raw[63 : 0], fifo_dout_raw[127 : 64]};
assign sipo_o = shift_reg[119 : 0];

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        shift_reg_len <= 'd0;
        shift_reg <= 'd0;
    end
    else if (shift_reg_len == 'd120) begin
        shift_reg_len <= 'd0;
        sipo_o_valid <= 1'b1;
        shift_reg <= (shift_reg >> 120);
    end
    else if (rd_en == 1'b1 && empty == 1'b0) begin
        case (shift_reg_len)
            'd0   : shift_reg <= (shift_reg >> 120) | (fifo_dout << 0);
            'd8   : shift_reg <= (shift_reg >> 120) | (fifo_dout << 8);
            'd16  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 16);
            'd24  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 24);
            'd32  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 32);
            'd40  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 40);
            'd48  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 48);
            'd56  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 56);
            'd64  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 64);
            'd72  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 72);
            'd80  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 80);
            'd88  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 88);
            'd96  : shift_reg <= (shift_reg >> 120) | (fifo_dout << 96);
            'd104 : shift_reg <= (shift_reg >> 120) | (fifo_dout << 104);
            'd112 : shift_reg <= (shift_reg >> 120) | (fifo_dout << 112);
            default : shift_reg <= 'd0;
        endcase
        shift_reg_len <= shift_reg_len + 'd8;
        sipo_o_valid <= 1'b1;
    end
    else begin
        shift_reg_len <= shift_reg_len;
        sipo_o_valid <= 1'b0;
    end
end

// ==========================================================
// FIFO
// ==========================================================
ExpandA_sipo u_ExpandA_sipo (
  .clk(clk),                      // input wire clk
  .srst(~rstn | init),                    // input wire srst
  .din(st_64bit),                      // input wire [63 : 0] din
  .wr_en(st_64bit_valid),                  // input wire wr_en
  .rd_en(rd_en & (shift_reg_len < 120)),                  // input wire rd_en
  .dout(fifo_dout_raw),                    // output wire [127 : 0] dout
  .full(full),                    // output wire full
  .empty(empty),                  // output wire empty
  .rd_data_count(rd_data_count)  // output wire [8 : 0] rd_data_count
);

endmodule
