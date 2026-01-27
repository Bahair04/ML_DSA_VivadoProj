(* DONT_TOUCH = "TRUE" *)
module keccak(
    input   logic                   clk,
    input   logic                   rstn,

    // --- 控制接口 ---
    input   logic                   init,
    input   logic                   start_perm,
    output  logic                   perm_done,

    // --- 串行数据吸入接口  ---
    input   logic                   din_valid,  // 输入数据有效信号
    input   logic   [63 : 0]        din,        // 63-bit 输入数据
    input   logic   [2 : 0]         din_row,    // 写入位置 row (行)
    input   logic   [2 : 0]         din_col,    // 写入位置 col (列)
    input   logic   [2 : 0]         din_pos,    // 写入位置 pos (位) 用于在将64-bit按8-bit展开

    // --- 并行数据输出接口 ---
    output  logic   [0 : 4][0 : 4][63 : 0]  st_out
);

// ==========================================================
// 1. 状态与参数定义
// ==========================================================
// --- 定义状态机状态 ---
typedef enum logic [2 : 0] {
    S_IDLE,
    S_THETA,
    S_RHO_PI,
    S_CHI_IOTA,
    S_DONE
} state_t;

state_t state;

// --- 内部核心状态矩阵 (5x5x64 = 1600 bits) ---
// --- 既作为存储器，也作为计算中间变量 ---
logic   [0 : 4][0 : 4][63 : 0]      st;

// --- 轮数计数器 (0 ~ 23) ---
logic   [4 : 0]                     round_cnt;

// --- 中间计算变量 ---
logic   [0 : 4][63 : 0]             bc;                     // Theta 步骤的临时列异或值
logic   [0 : 4][0 : 4][63 : 0]      st_after_theta;         // Theta 后的状态
logic   [0 : 4][0 : 4][63 : 0]      st_after_rho_pi;        // Rho/Pi 后的状态
logic   [0 : 4][0 : 4][63 : 0]      st_after_chi;           // Chi 后的状态

// ==========================================================
// 2. 连续赋值与函数
// ==========================================================

// --- 并行输出直接连接到内部状态 ---
assign st_out = st;

// --- 轮常数查找表 (Round Constants) ---
function automatic logic [63 : 0] get_rndc (input logic [4 : 0] r);
    case (r)
        5'd0 : return 64'h0000000000000001;
        5'd1 : return 64'h0000000000008082;
        5'd2 : return 64'h800000000000808a;
        5'd3 : return 64'h8000000080008000;
        5'd4 : return 64'h000000000000808b;
        5'd5 : return 64'h0000000080000001;
        5'd6 : return 64'h8000000080008081;
        5'd7 : return 64'h8000000000008009;
        5'd8 : return 64'h000000000000008a;
        5'd9 : return 64'h0000000000000088;
        5'd10: return 64'h0000000080008009;
        5'd11: return 64'h000000008000000a;
        5'd12: return 64'h000000008000808b;
        5'd13: return 64'h800000000000008b;
        5'd14: return 64'h8000000000008089;
        5'd15: return 64'h8000000000008003;
        5'd16: return 64'h8000000000008002;
        5'd17: return 64'h8000000000000080;
        5'd18: return 64'h000000000000800a;
        5'd19: return 64'h800000008000000a;
        5'd20: return 64'h8000000080008081;
        5'd21: return 64'h8000000000008080;
        5'd22: return 64'h0000000080000001;
        5'd23: return 64'h8000000080008008;
        default: return 64'h0;
    endcase
endfunction

// --- 旋转位移量查找表 (Rotation Offsets) ---
function automatic logic [5 : 0] get_rotc(input logic [2 : 0] x, input logic [2 : 0] y);
    case ({x, y})
        {3'd0, 3'd0}: return 0;
        {3'd1, 3'd0}: return 1;
        {3'd2, 3'd0}: return 62;
        {3'd3, 3'd0}: return 28;
        {3'd4, 3'd0}: return 27;
        {3'd0, 3'd1}: return 36;
        {3'd1, 3'd1}: return 44;
        {3'd2, 3'd1}: return 6;
        {3'd3, 3'd1}: return 55;
        {3'd4, 3'd1}: return 20;
        {3'd0, 3'd2}: return 3;
        {3'd1, 3'd2}: return 10;
        {3'd2, 3'd2}: return 43;
        {3'd3, 3'd2}: return 25;
        {3'd4, 3'd2}: return 39;
        {3'd0, 3'd3}: return 41;
        {3'd1, 3'd3}: return 45;
        {3'd2, 3'd3}: return 15;
        {3'd3, 3'd3}: return 21;
        {3'd4, 3'd3}: return 8;
        {3'd0, 3'd4}: return 18;
        {3'd1, 3'd4}: return 2;
        {3'd2, 3'd4}: return 61;
        {3'd3, 3'd4}: return 56;
        {3'd4, 3'd4}: return 14;
        default:      return 0;
    endcase
endfunction

// ==========================================================
// 3. 组合逻辑：置换算法核心 (Datapath)
// ==========================================================

// --------------------------------
// Step 1: Theta (计算列奇偶性并扩散)
// --------------------------------
// 1.1 计算每列的异或和 (BC)
// 逻辑：bc[x] = st[x][0] ^ st[x][1] ^ ... ^ st[x][4]
// 注意：这个逻辑在 always_ff 块里通过寄存器实现，为了优化关键路径

// 1.2 Theta 扩散
// 使用当前周期的寄存器值 bc 进行计算
// st[x][y] ^= bc[x-1] ^ rot(bc[x+1], 1)
always_comb begin
    for (int i = 0 ; i < 5 ; i++) begin
        logic [63:0] t;
        // 处理边界回绕 (x-1 和 x+1)
        logic [2:0] xm1, xp1; 
        xm1 = (i == 0) ? 3'd4 : (i - 1);
        xp1 = (i == 4) ? 3'd0 : (i + 1);

        // ROTL64(bc[xp1], 1)
        t = bc[xm1] ^ {bc[xp1][62:0], bc[xp1][63]}; 

        for (int j = 0 ; j < 5 ; j++) begin
            st_after_theta[j][i] = st[j][i] ^ t;
        end
    end
end

// ---------------------------------------------
// Step 2 & 3: Rho (旋转) & Pi (置换)
// ---------------------------------------------
// 这两个步骤是纯连线变换，组合在一起写
always_comb begin
    for (int i = 0 ; i < 5 ; i++) begin
        for (int j = 0 ; j < 5 ; j++) begin
            logic [2 : 0] new_x, new_y;
            logic [5 : 0] rot;

            new_x = i;
            new_y = (2 * j + 3 * i) % 5;

            rot = get_rotc(j, i);
            if (rot == 0)
                st_after_rho_pi[new_y][new_x] = st[i][j];
            else
                st_after_rho_pi[new_y][new_x] = (st[i][j] << rot) | (st[i][j] >> (64 - rot));
        end
    end
end

// ---------------------------------------------
// Step 4: Chi (非线性混淆)
// ---------------------------------------------
always_comb begin
    for (int i = 0 ; i < 5 ; i++) begin
        for (int j = 0 ; j < 5 ; j++) begin
            logic [2:0] xp1, xp2;
            xp1 = (j == 4) ? 3'd0 : (j + 1);
            xp2 = (j == 3) ? 3'd0 : ((j == 4) ? 3'd1 : (j + 2));

            // Chi 公式: A[x] = A[x] ^ ((~A[x+1]) & A[x+2])
            st_after_chi[i][j] = st[i][j] ^ ((~st[i][xp1]) & st[i][xp2]);
        end
    end
end

// =========================================================================
// 4. 时序逻辑：主状态机 (FSM)
// =========================================================================
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        st <= '{default:0};
        state <= S_IDLE;
        perm_done <= 1'b0;
        round_cnt <= 'd0;
        bc <= '{default:0};
    end
    else begin
        perm_done <= 1'b0;
        case (state)
            // -------------------------------------------------------------
            // 状态: IDLE (吸入模式)
            // 作用: 接受外部数据并异或，或等待置换开始指令
            // -------------------------------------------------------------
            S_IDLE : begin
                if (init) begin
                    st <= '{default:0};
                    round_cnt <= 'd0;
                    state <= S_IDLE;
                end
                else if (start_perm) begin
                    // 准备开始置换
                    // 在进入 THETA 前，必须先计算 BC 值，为第一轮做准备
                    // 这样可以省去一个专门的 PRE_CALC 状态
                    for (int i = 0 ; i < 5 ; i++)
                        bc[i] <= st[0][i] ^ st[1][i] ^ st[2][i] ^ st[3][i] ^ st[4][i];
                    state <= S_THETA;
                    round_cnt <= 'd0;
                end
                else if (din_valid) begin
                    // *** 核心：In-Place XOR Update ***
                    st[din_row][din_col] <= din;
                    // case (din_pos)
                    //     3'd0 : st[din_row][din_col][7:0]   <= st[din_row][din_col][7:0]   ^ din;
                    //     3'd1 : st[din_row][din_col][15:8]  <= st[din_row][din_col][15:8]  ^ din;
                    //     3'd2 : st[din_row][din_col][23:16] <= st[din_row][din_col][23:16] ^ din;
                    //     3'd3 : st[din_row][din_col][31:24] <= st[din_row][din_col][31:24] ^ din;
                    //     3'd4 : st[din_row][din_col][39:32] <= st[din_row][din_col][39:32] ^ din;
                    //     3'd5 : st[din_row][din_col][47:40] <= st[din_row][din_col][47:40] ^ din;
                    //     3'd6 : st[din_row][din_col][55:48] <= st[din_row][din_col][55:48] ^ din;
                    //     3'd7 : st[din_row][din_col][63:56] <= st[din_row][din_col][63:56] ^ din;
                    // endcase
                    state <= S_IDLE;
                end
            end

            // -------------------------------------------------------------
            // 状态: THETA (置换第 1 阶段)
            // -------------------------------------------------------------
            S_THETA : begin
                st <= st_after_theta;
                state <= S_RHO_PI;
            end

            // -------------------------------------------------------------
            // 状态: RHO_PI (置换第 2 阶段)
            // -------------------------------------------------------------
            S_RHO_PI : begin
                st <= st_after_rho_pi;
                state <= S_CHI_IOTA;
            end

            // -------------------------------------------------------------
            // 状态: CHI_IOTA (置换第 3 阶段)
            // -------------------------------------------------------------
            S_CHI_IOTA : begin
                // 1. 应用 Chi 变换
                // st_after_chi 的输入是 st (此时 st 存的是 Rho/Pi 后的值)
                
                // 2. 应用 Iota (只影响 st[0][0]) 并更新所有 st
                for(int i = 0 ; i < 5 ; i++) begin
                    for(int j = 0 ; j < 5 ; j++) begin
                        if (i==0 && j==0)
                            st[i][j] <= st_after_chi[i][j] ^ get_rndc(round_cnt);
                        else
                            st[i][j] <= st_after_chi[i][j];
                    end
                end

                // 3. 同时也为下一轮计算准备 BC 值 (Look-ahead)
                // 下一轮是 S_THETA，需要基于 "Chi/Iota 后的新状态" 计算 BC
                // 这是一个关键优化，避免多浪费一个周期算 BC
                for(int i = 0 ; i < 5 ; i++) begin
                    // 临时变量保存当前列的计算结果
                    logic [63:0] new_col_0, new_col_1, new_col_2, new_col_3, new_col_4;
                    
                    // 由于 st 还未更新，我们需要引用 st_after_chi 组合逻辑
                    // 并对 [0][0] 特殊处理 Iota
                    new_col_0 = (i==0) ? (st_after_chi[0][0] ^ get_rndc(round_cnt)) : st_after_chi[0][i];
                    new_col_1 = st_after_chi[1][i];
                    new_col_2 = st_after_chi[2][i];
                    new_col_3 = st_after_chi[3][i];
                    new_col_4 = st_after_chi[4][i];

                    bc[i] <= new_col_0 ^ new_col_1 ^ new_col_2 ^ new_col_3 ^ new_col_4;
                end

                // 4. 轮数判断
                if (round_cnt == 'd23) begin
                    state <= S_DONE;
                end else begin
                    round_cnt <= round_cnt + 1'b1;
                    state <= S_THETA;
                end
            end
            // -------------------------------------------------------------
            // 状态: DONE (完成)
            // -------------------------------------------------------------
            S_DONE: begin
                perm_done <= 1'b1;
                state <= S_IDLE; // 回到 IDLE，保留当前状态，等待下一次吸入或读取
            end
        endcase
    end
end

endmodule
