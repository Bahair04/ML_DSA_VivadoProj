`include "../../param_conf.v"

module HintBitUnpack_64bit #(
    parameter K     = `k,
    parameter OMEGA = `omega
)(
    input  logic        clk,
    input  logic        rstn,
    input  logic        init,

    // --- 64-bit 宽总线输入 ---
    input  logic [63:0] unpack_in,
    input  logic        unpack_valid,

    // --- 还原输出 ---
    output logic [3:0]  hint_out,
    output logic        hint_valid,
    output logic [7:0]  hint_valid_cnt, // 0~255，与 Pack 端的输入对称
    
    // --- 状态与错误指示 ---
    output logic        unpack_done,
    output logic        decode_err      // FIPS 格式非法判定
);

// ==========================================
// 内部参数与信号定义 
// ==========================================
localparam TOTAL_BYTES  = OMEGA + K;
localparam TOTAL_CHUNKS = (TOTAL_BYTES + 7) / 8; 

// S_LOAD 阶段的接收缓存 (扁平化)
logic [7:0] packed_data [0 : TOTAL_BYTES - 1];

// 移位窗口与静态偏移量分离
logic [7:0] shift_coords   [0 : OMEGA - 1]; // 专门用于移位的坐标传送带
logic [7:0] static_offsets [0 : K - 1];     // 静态锁存的各个多项式偏移量

logic [7:0] coord_ptr;  // 记录全局已经消耗了几个 hint
logic [7:0] cnt_reg;    // 主干节拍器 (0 ~ K*64-1)

logic [7:0] j_base;
logic [1:0] poly_idx;

// 状态机
typedef enum logic [1:0] {
    S_IDLE   = 2'b00,
    S_LOAD   = 2'b01,
    S_CHECK  = 2'b10,
    S_UNPACK = 2'b11
} state_t;
state_t state, next_state;

logic [7:0] in_cnt;

// ==========================================
// 1. 数据截取拆装 (大端拆解)
// ==========================================
logic [7:0] in_bytes [0:7];
logic [7:0] current_base;

assign current_base = in_cnt << 3;

assign in_bytes[0] = unpack_in[63:56];
assign in_bytes[1] = unpack_in[55:48];
assign in_bytes[2] = unpack_in[47:40];
assign in_bytes[3] = unpack_in[39:32];
assign in_bytes[4] = unpack_in[31:24];
assign in_bytes[5] = unpack_in[23:16];
assign in_bytes[6] = unpack_in[15:8];
assign in_bytes[7] = unpack_in[7:0];

// ==========================================
// 2. FIPS 格式非法组合逻辑检查
// ==========================================
logic check_err;
always_comb begin
    check_err = 1'b0;
    // 检查 1：Offsets 必须单调递增，且 <= OMEGA
    for (int i = 0; i < K; i = i + 1) begin
        if (i == 0) begin
            if (packed_data[OMEGA] > OMEGA) check_err = 1'b1;
        end else begin
            if (packed_data[OMEGA + i] < packed_data[OMEGA + i - 1] || packed_data[OMEGA + i] > OMEGA) 
                check_err = 1'b1;
        end
    end
    // 检查 2：未使用的 Padding 必须全为 0
    for (int i = 0; i < OMEGA; i = i + 1) begin
        if (i >= packed_data[OMEGA + K - 1] && packed_data[i] != 8'd0)
            check_err = 1'b1;
    end
end

// ==========================================
// 3. 0-Latency 移位窗口寻址
// ==========================================
assign j_base   = {cnt_reg[5:0], 2'b00}; // 0, 4, 8 ... 252
assign poly_idx = cnt_reg[7:6];          // 0, 1, 2, 3

logic h0, h1, h2, h3;
logic [2:0] adv_hints; 

// 提取传送带最前面的 4 个元素（硬连线，完全没有 MUX 开销）
logic [7:0] sc0, sc1, sc2, sc3;
assign sc0 = shift_coords[0];
assign sc1 = shift_coords[1];
assign sc2 = shift_coords[2];
assign sc3 = shift_coords[3];

// 算出当前多项式还剩几个有效的提示点可以读
logic [7:0] rem_coords;
assign rem_coords = static_offsets[poly_idx] - coord_ptr;
logic [1:0] idx1;
logic [1:0] idx2;
logic [1:0] idx3;
// 极其扁平的组合逻辑树 (最高不超过 4选1 MUX)
always_comb begin
    h0 = 1'b0; h1 = 1'b0; h2 = 1'b0; h3 = 1'b0;

    // 第 0 个系数匹配
    if (rem_coords > 8'd0 && sc0 == j_base) 
        h0 = 1'b1;

    // 第 1 个系数匹配 (如果h0命中，看sc1；否则看sc0)
    idx1 = {1'b0, h0};
    if (rem_coords > {6'd0, idx1} && (idx1 == 2'd0 ? sc0 : sc1) == j_base + 8'd1) 
        h1 = 1'b1;

    // 第 2 个系数匹配
    idx2 = h0 + h1;
    if (rem_coords > {6'd0, idx2} && (idx2 == 2'd0 ? sc0 : idx2 == 2'd1 ? sc1 : sc2) == j_base + 8'd2) 
        h2 = 1'b1;

    // 第 3 个系数匹配
    idx3 = h0 + h1 + h2;
    if (rem_coords > {6'd0, idx3} && (idx3 == 2'd0 ? sc0 : idx3 == 2'd1 ? sc1 : idx3 == 2'd2 ? sc2 : sc3) == j_base + 8'd3) 
        h3 = 1'b1;

    adv_hints = h0 + h1 + h2 + h3;
end

// ==========================================
// 4. 状态机与流水线调度
// ==========================================
always_ff @(posedge clk) begin
    if (!rstn)     state <= S_IDLE;
    else if (init) state <= S_IDLE;
    else           state <= next_state;
end

always_comb begin
    next_state = state;
    case (state)
        S_IDLE:   if (unpack_valid) next_state = S_LOAD;
        S_LOAD:   if (unpack_valid && in_cnt == TOTAL_CHUNKS - 1) next_state = S_CHECK;
        S_CHECK:  if (check_err) next_state = S_IDLE; else next_state = S_UNPACK;
        S_UNPACK: begin
            // 隐式纠错防线：如果 64 拍结束时，游标没走到 offset 的终点，说明有乱序/重叠，直接打回！
            if (cnt_reg[5:0] == 6'd63 && (coord_ptr + adv_hints != static_offsets[poly_idx]))
                next_state = S_IDLE;
            else if (cnt_reg == K * 64 - 1)
                next_state = S_IDLE;
        end
        default: next_state = S_IDLE;
    endcase
end

// 核心数据通路控制
always_ff @(posedge clk) begin
    if (!rstn || init) begin
        in_cnt      <= 8'd0;
        cnt_reg     <= 8'd0;
        coord_ptr   <= 8'd0;
        hint_out    <= 4'd0;
        hint_valid  <= 1'b0;
        hint_valid_cnt <= 'd0;
        unpack_done <= 1'b0;
        decode_err  <= 1'b0;
        for (int i = 0; i < TOTAL_BYTES; i = i + 1) packed_data[i] <= 8'd0;
        for (int i = 0; i < OMEGA; i = i + 1) shift_coords[i] <= 8'd0;
        for (int i = 0; i < K; i = i + 1) static_offsets[i] <= 8'd0;
    end 
    else begin
        hint_valid  <= 1'b0;
        unpack_done <= 1'b0;

        case (state)
            S_IDLE: begin
                in_cnt    <= 8'd0;
                cnt_reg   <= 8'd0;
                coord_ptr <= 8'd0;
                if (unpack_valid) begin
                    for (int j = 0; j < 8; j = j + 1) begin
                        if ((0 + j) < TOTAL_BYTES) packed_data[j] <= in_bytes[j];
                    end
                    in_cnt <= 8'd1;
                end
            end

            S_LOAD: begin
                if (unpack_valid) begin
                    for (int j = 0; j < 8; j = j + 1) begin
                        if ((current_base + j) < TOTAL_BYTES) 
                            packed_data[current_base + j] <= in_bytes[j];
                    end
                    if (in_cnt != TOTAL_CHUNKS - 1)
                        in_cnt <= in_cnt + 8'd1;
                end
            end

            S_CHECK: begin
                if (check_err) begin
                    decode_err <= 1'b1;
                end else begin
                    // 把通过体检的数组，分别倒入“移位传送带”和“静态游标卡尺”
                    for (int i = 0; i < OMEGA; i = i + 1) shift_coords[i] <= packed_data[i];
                    for (int i = 0; i < K; i = i + 1) static_offsets[i] <= packed_data[OMEGA + i];
                end
            end

            S_UNPACK: begin
                if (cnt_reg[5:0] == 6'd63 && (coord_ptr + adv_hints != static_offsets[poly_idx])) begin
                    decode_err <= 1'b1;
                end 
                else begin
                    hint_out   <= {h3, h2, h1, h0};
                    hint_valid <= 1'b1;
                    hint_valid_cnt <= cnt_reg;
                    // 传送带瞬间左移 adv_hints 格，抛弃已经被消耗的坐标
                    for (int i = 0; i < OMEGA; i = i + 1) begin
                        if (i + adv_hints < OMEGA)
                            shift_coords[i] <= shift_coords[i + adv_hints];
                        else
                            shift_coords[i] <= 8'd0;
                    end
                    
                    coord_ptr <= coord_ptr + adv_hints;

                    if (cnt_reg == K * 64 - 1) begin
                        cnt_reg     <= 8'd0;
                        unpack_done <= 1'b1;
                    end else begin
                        cnt_reg     <= cnt_reg + 8'd1;
                    end
                end
            end
        endcase
    end
end

endmodule