module ExpandY_sipo80(
    // --- 时钟与复位信号 ---
    input       wire                clk,
    input       wire                rstn,

    // --- 顶层(ExpandA)传入的控制与数据接口 ---
    input       logic               init,
    input       logic   [63 : 0]    st_64bit,
    input       logic               st_64bit_valid,

    // --- 18*4位并行输出接口 ---
    output      logic   [79 : 0]    sipo_o,
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
logic       [4 : 0]         rd_data_count;

// --- 移位寄存器 ---
logic       [255 : 0]       shift_reg;
logic       [9 : 0]         shift_reg_len;

assign fifo_dout = {
    fifo_dout_raw[ 7: 0],
    fifo_dout_raw[15: 8],
    fifo_dout_raw[23:16],
    fifo_dout_raw[31:24],
    fifo_dout_raw[39:32],
    fifo_dout_raw[47:40],
    fifo_dout_raw[55:48],
    fifo_dout_raw[63:56],
    fifo_dout_raw[71:64],
    fifo_dout_raw[79:72],
    fifo_dout_raw[87:80],
    fifo_dout_raw[95:88],
    fifo_dout_raw[103:96],
    fifo_dout_raw[111:104],
    fifo_dout_raw[119:112],
    fifo_dout_raw[127:120]
};


always_comb begin
    if (init || !rstn)
        rd_en = 1'b0;
    else if (!empty && (shift_reg_len <= (256 - 128)))
        rd_en = 1'b1;
    else
        rd_en = 1'b0;
end

// ==========================================================
// 时序逻辑：数据搬运 (Gearbox)
// ==========================================================
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        shift_reg     <= 'd0;
        shift_reg_len <= 'd0;
        sipo_o_valid  <= 1'b0;
        sipo_o        <= 'd0;
    end
    else if (init) begin
        shift_reg     <= 'd0;
        shift_reg_len <= 'd0;
        sipo_o_valid  <= 1'b0;
        sipo_o        <= 'd0;
    end
    else begin
        // --- 临时变量，用于并行计算 ---
        logic [255:0] next_reg;
        logic [8:0]   next_len;
        
        // 1. 默认继承当前值
        next_reg = shift_reg;
        next_len = shift_reg_len;
        sipo_o_valid <= 1'b0; // 默认拉低

        // 2. 处理 Refill (补充数据)
        // 假设 FIFO 是 FWFT 模式，rd_en 拉高时 dout 已经有效
        // 如果是 Standard FIFO，这里逻辑要微调 (用 FIFO output valid 信号)
        if (rd_en) begin
            // 拼接到高位
            next_reg |= (fifo_dout << next_len); 
            next_len += 128;
        end

        // 3. 处理 Consume (输出数据)
        // 检查补充后的长度是否够输出
        if (next_len >= 80) begin
            sipo_o       <= next_reg[79:0]; // 截取低 80 位
            sipo_o_valid <= 1'b1;
            
            // 移位并更新长度
            // 注意：这里是对 next_reg 操作，实现了“同周期既读又写”
            shift_reg     <= next_reg >> 80;
            shift_reg_len <= next_len - 80;
        end
        else begin
            // 不够输出，仅更新补充后的值
            shift_reg     <= next_reg;
            shift_reg_len <= next_len;
            sipo_o        <= 'd0; // 可选
        end
    end
end

// ==========================================================
// FIFO
// ==========================================================
ExpandA_sipo u_ExpandA_sipo (
  .clk(clk),                                    // input wire clk
  .srst(~rstn | init),                          // input wire srst
  .din(st_64bit),                               // input wire [63 : 0] din
  .wr_en(st_64bit_valid),                       // input wire wr_en
  .rd_en(rd_en & (shift_reg_len < 80)),         // input wire rd_en
  .dout(fifo_dout_raw),                         // output wire [127 : 0] dout
  .full(full),                                  // output wire full
  .empty(empty),                                // output wire empty
  .rd_data_count(rd_data_count)                 // output wire [4 : 0] rd_data_count
);

endmodule
