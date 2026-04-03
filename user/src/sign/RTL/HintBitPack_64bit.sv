`include "../../param_conf.v"

module HintBitPack_64bit #(
    parameter K     = `k,
    parameter OMEGA = `omega
)(
    input  logic                clk,
    input  logic                rstn,
    input  logic                init,

    input  logic [3:0]          hint,
    input  logic                hint_valid,
    input  logic [7:0]          hint_valid_cnt, // 0~255
    input  logic                make_hint_done,

    output logic [63:0]         pack_out,
    output logic                pack_valid,
    output logic                pack_done,
    output logic [6:0]          pack_len_bits   // 新增：指示当前输出的有效比特长度 (最大64)
);

// ==========================================
// 内部参数与信号定义
// ==========================================
localparam TOTAL_BYTES  = OMEGA + K;
localparam TOTAL_CHUNKS = (TOTAL_BYTES + 7) / 8; // 按 8 字节分块数量向上取整

// 用于存储最终拼接好结果的寄存器组 (最大约 80+4 = 84 Byte)
logic [7:0] packed_data [0 : TOTAL_BYTES - 1];

// 伪代码中的 Index 追踪变量
logic [7:0] index_reg;

// 当前解析的位置和多项式编号
logic [7:0] j_base;
logic [1:0] poly_idx;
logic [2:0] n_hints;

// 分配写入目标地址
logic [7:0] pos0, pos1, pos2, pos3;

// 状态机
typedef enum logic [1:0] {
    S_IDLE    = 2'b00,
    S_COLLECT = 2'b01,
    S_OUTPUT  = 2'b10
} state_t;
state_t state, next_state;

logic [7:0] out_cnt;

// ==========================================
// 1. Hint 计数和相对位置解析
// ==========================================
assign n_hints  = hint[0] + hint[1] + hint[2] + hint[3];
assign j_base   = {hint_valid_cnt[5:0], 2'b00}; // 0, 4, 8 ... 252
assign poly_idx = hint_valid_cnt[7:6];          // 0, 1, 2, 3 (对应 i in 0 to k-1)

// 预计算可能写入的目标下标 Index
assign pos0 = index_reg;
assign pos1 = index_reg + hint[0];
assign pos2 = index_reg + hint[0] + hint[1];
assign pos3 = index_reg + hint[0] + hint[1] + hint[2];

// ==========================================
// 2. 收集逻辑 (核心映射 Algorithm 20)
// ==========================================
always_ff @(posedge clk) begin
    if (!rstn) begin
        index_reg <= 8'd0;
        for (int i = 0; i < TOTAL_BYTES; i = i + 1) packed_data[i] <= 8'd0;
    end 
    else if (init) begin
        index_reg <= 8'd0;
        // 初始化清零隐式实现了伪代码里的 Padding 补0动作
        for (int i = 0; i < TOTAL_BYTES; i = i + 1) packed_data[i] <= 8'd0;
    end 
    else if (hint_valid) begin
        // 写入非零系数的位置
        if (hint[0]) packed_data[pos0] <= j_base;
        if (hint[1]) packed_data[pos1] <= j_base + 8'd1;
        if (hint[2]) packed_data[pos2] <= j_base + 8'd2;
        if (hint[3]) packed_data[pos3] <= j_base + 8'd3;

        // 推进游标 Index ← Index + 当前周期非0个数
        index_reg <= index_reg + n_hints;

        // 如果当前多项式刚好迭代结束 (j from 0 to 255完成)，存储最终的 Index
        if (hint_valid_cnt[5:0] == 6'd63) begin
            // y[ω + i] ← Index
            packed_data[OMEGA + poly_idx] <= index_reg + n_hints;
        end
    end
end

// ==========================================
// 3. 输出状态机 (按 8 Bytes 打包传输)
// ==========================================
always_ff @(posedge clk) begin
    if (!rstn)     state <= S_IDLE;
    else if (init) state <= S_IDLE;
    else           state <= next_state;
end

always_comb begin
    next_state = state;
    case (state)
        S_IDLE: begin
            if (hint_valid) next_state = S_COLLECT;
        end
        S_COLLECT: begin
            // 最终数据落盘后拉高 make_hint_done
            if (make_hint_done) next_state = S_OUTPUT;
        end
        S_OUTPUT: begin
            if (out_cnt == TOTAL_CHUNKS - 1) next_state = S_IDLE;
        end
        default: next_state = S_IDLE;
    endcase
end

// 输出块计数器
always_ff @(posedge clk) begin
    if (!rstn || init) begin
        out_cnt <= 8'd0;
    end 
    else if (state == S_OUTPUT) begin
        if (out_cnt == TOTAL_CHUNKS - 1) 
            out_cnt <= 8'd0;
        else 
            out_cnt <= out_cnt + 8'd1;
    end
end

// ==========================================
// 4. 数据截取拼装与有效位长计算
// ==========================================
logic [7:0] out_bytes [0:7];
logic [7:0] current_base;
logic [3:0] valid_bytes_current; // 当前周期的有效字节数 (1~8)

assign current_base = out_cnt << 3; // 相当于 out_cnt * 8

always_comb begin
    // 动态判断当前块的有效字节数
    if ((current_base + 8) <= TOTAL_BYTES)
        valid_bytes_current = 4'd8;
    else
        valid_bytes_current = TOTAL_BYTES - current_base;

    for (int j = 0; j < 8; j = j + 1) begin
        // 越界部分自动拼 0 (例如最后一块不足 8 byte 时)
        if ((current_base + j) < TOTAL_BYTES)
            out_bytes[j] = packed_data[current_base + j];
        else
            out_bytes[j] = 8'd0;
    end
end

// 采用小端序拼装：低索引在前(byte0 到 [7:0])
assign pack_out = { out_bytes[0], out_bytes[1], out_bytes[2], out_bytes[3],
                    out_bytes[4], out_bytes[5], out_bytes[6], out_bytes[7] };

assign pack_valid = (state == S_OUTPUT);
assign pack_done  = (state == S_OUTPUT) && (out_cnt == TOTAL_CHUNKS - 1);

// 新增逻辑：计算有效输出的比特长度 (字节数 * 8)，非有效状态输出 0
assign pack_len_bits = (state == S_OUTPUT) ? ({3'b0, valid_bytes_current} << 3) : 7'd0;

endmodule