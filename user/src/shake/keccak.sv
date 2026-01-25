module keccak (
    input  logic                clk,
    input  logic                rstn,

    // --- 控制接口 ---
    input  logic                init,          // 高电平有效：将内部状态彻底清零 (对应 sha3_init)
    input  logic                start_perm,    // 高电平有效：触发 24 轮置换 (对应 j >= rsiz 时的处理)
    output logic                perm_done,     // 高电平脉冲：置换完成，可以继续吸入数据

    // --- 串行数据吸入接口 (对应 sha3_update) ---
    input  logic                din_valid,     // 输入数据有效信号
    input  logic [63:0]         din,           // 64-bit 输入数据
    input  logic [2:0]          din_x,         // 写入位置 x (列) [0..4]
    input  logic [2:0]          din_y,         // 写入位置 y (行) [0..4]

    // --- 并行数据输出接口 (Squeeze) ---
    // 直接连出内部寄存器，外部模块可随时截取所需部分 (如前 256 bits)
    output logic [4:0][4:0][63:0] st_out
);

    // =========================================================================
    // 1. 参数与状态定义
    // =========================================================================

    // 定义状态机状态
    typedef enum logic [2:0] {
        S_IDLE,         // 空闲/吸入模式：等待数据输入或置换指令
        S_THETA,        // 置换步骤：Theta 计算
        S_RHO_PI,       // 置换步骤：Rho 和 Pi 变换
        S_CHI_IOTA,     // 置换步骤：Chi 和 Iota 变换（合并以优化时序）
        S_DONE          // 单次置换流程结束
    } state_t;

    state_t state;
    
    // 内部核心状态矩阵 (5x5x64 = 1600 bits)
    // 既作为存储器，也作为计算中间变量
    logic [4:0][4:0][63:0] st;

    // 轮数计数器 (0 ~ 23)
    logic [4:0] round_cnt;

    // 中间计算变量
    logic [63:0] bc [0:4];                    // Theta 步骤的临时列异或值
    logic [63:0] [4:0][4:0] st_after_theta;   // Theta 后的状态
    logic [63:0] [4:0][4:0] st_after_rho_pi;  // Rho/Pi 后的状态
    logic [63:0] [4:0][4:0] st_after_chi;     // Chi 后的状态

    // =========================================================================
    // 2. 连续赋值与函数
    // =========================================================================

    // 并行输出直接连接内部状态
    assign st_out = st;

    // 轮常数查找表 (Round Constants)
    function automatic logic [63:0] get_rndc(input logic [4:0] r);
        case(r)
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

    // 旋转位移量查找表 (Rotation Offsets)
    function automatic logic [5:0] get_rotc(input logic [2:0] x, input logic [2:0] y);
        case({x, y})
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

    // =========================================================================
    // 3. 组合逻辑：置换算法核心 (Datapath)
    // =========================================================================

    // ---------------------------------------------
    // Step 1: Theta (计算列奇偶性并扩散)
    // ---------------------------------------------
    // 1.1 计算每列的异或和 (BC)
    // 逻辑：bc[x] = st[x][0] ^ st[x][1] ^ ... ^ st[x][4]
    // 注意：这个逻辑在 always_ff 块里通过寄存器实现，为了优化关键路径
    
    // 1.2 Theta 扩散
    // 使用当前周期的寄存器值 bc 进行计算
    // st[x][y] ^= bc[x-1] ^ rot(bc[x+1], 1)
    always_comb begin
        for(int x=0; x<5; x++) begin
            logic [63:0] t;
            // 处理边界回绕 (x-1 和 x+1)
            logic [2:0] xm1, xp1; 
            xm1 = (x == 0) ? 3'd4 : (x - 1);
            xp1 = (x == 4) ? 3'd0 : (x + 1);

            // ROTL64(bc[xp1], 1)
            t = bc[xm1] ^ {bc[xp1][62:0], bc[xp1][63]}; 

            for(int y=0; y<5; y++) begin
                st_after_theta[x][y] = st[x][y] ^ t;
            end
        end
    end

    // ---------------------------------------------
    // Step 2 & 3: Rho (旋转) & Pi (置换)
    // ---------------------------------------------
    // 这两个步骤是纯连线变换，组合在一起写
    always_comb begin
        for(int x=0; x<5; x++) begin
            for(int y=0; y<5; y++) begin
                logic [2:0] new_x, new_y;
                logic [5:0] rot;
                
                // Pi 变换坐标计算
                // new_x = y
                // new_y = (2*x + 3*y) % 5
                new_x = y;
                // new_y 计算技巧: (2x + 3y) % 5
                // 使用简单的 case 或算术运算
                case ({x[2:0], y[2:0]})
                    {3'd0, 3'd0}: new_y = 0; {3'd1, 3'd0}: new_y = 2; {3'd2, 3'd0}: new_y = 4; {3'd3, 3'd0}: new_y = 1; {3'd4, 3'd0}: new_y = 3;
                    {3'd0, 3'd1}: new_y = 3; {3'd1, 3'd1}: new_y = 0; {3'd2, 3'd1}: new_y = 2; {3'd3, 3'd1}: new_y = 4; {3'd4, 3'd1}: new_y = 1;
                    {3'd0, 3'd2}: new_y = 1; {3'd1, 3'd2}: new_y = 3; {3'd2, 3'd2}: new_y = 0; {3'd3, 3'd2}: new_y = 2; {3'd4, 3'd2}: new_y = 4;
                    {3'd0, 3'd3}: new_y = 4; {3'd1, 3'd3}: new_y = 1; {3'd2, 3'd3}: new_y = 3; {3'd3, 3'd3}: new_y = 0; {3'd4, 3'd3}: new_y = 2;
                    {3'd0, 3'd4}: new_y = 2; {3'd1, 3'd4}: new_y = 4; {3'd2, 3'd4}: new_y = 1; {3'd3, 3'd4}: new_y = 3; {3'd4, 3'd4}: new_y = 0;
                    default:      new_y = 0;
                endcase

                // Rho 旋转量获取
                rot = get_rotc(x, y);

                // 执行旋转并放置到新坐标 (Pi)
                if (rot == 0)
                    st_after_rho_pi[new_y][new_x] = st[x][y]; // 注意：输入是用 st，但实际状态机里我们会用 st_after_theta 的结果
                else
                    // SystemVerilog 的位移操作符会自动处理
                    st_after_rho_pi[new_y][new_x] = (st[x][y] << rot) | (st[x][y] >> (64 - rot));
            end
        end
    end

    // ---------------------------------------------
    // Step 4: Chi (非线性混淆)
    // ---------------------------------------------
    always_comb begin
        for(int x=0; x<5; x++) begin
            for(int y=0; y<5; y++) begin
                logic [2:0] xp1, xp2;
                xp1 = (x == 4) ? 3'd0 : (x + 1);
                xp2 = (x == 3) ? 3'd0 : ((x == 4) ? 3'd1 : (x + 2));
                
                // Chi 公式: A[x] = A[x] ^ ((~A[x+1]) & A[x+2])
                // 注意：这里输入源必须是 Rho/Pi 之后的结果
                st_after_chi[x][y] = st_after_rho_pi[x][y] ^ ((~st_after_rho_pi[xp1][y]) & st_after_rho_pi[xp2][y]);
            end
        end
    end


    // =========================================================================
    // 4. 时序逻辑：主状态机 (FSM)
    // =========================================================================
    
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            st <= '{default:0}; // 快速清零整个 1600-bit 寄存器
            state <= S_IDLE;
            perm_done <= 1'b0;
            round_cnt <= 'd0;
            bc <= '{default:0};
        end
        else begin
            // 默认输出
            perm_done <= 1'b0;

            case (state)
                // -------------------------------------------------------------
                // 状态: IDLE (吸入模式)
                // 作用: 接受外部数据并异或，或等待置换开始指令
                // -------------------------------------------------------------
                S_IDLE: begin
                    if (init) begin
                        st <= '{default:0};
                        round_cnt <= 'd0;
                    end
                    else if (start_perm) begin
                        // 准备开始置换
                        // 在进入 THETA 前，必须先计算 BC 值，为第一轮做准备
                        // 这样可以省去一个专门的 PRE_CALC 状态
                        for(int x=0; x<5; x++) begin
                            bc[x] <= st[x][0] ^ st[x][1] ^ st[x][2] ^ st[x][3] ^ st[x][4];
                        end
                        state <= S_THETA;
                        round_cnt <= 'd0;
                    end
                    else if (din_valid) begin
                        // *** 核心：In-Place XOR Update ***
                        // 直接修改寄存器，无需搬运
                        st[din_x][din_y] <= st[din_x][din_y] ^ din;
                    end
                end

                // -------------------------------------------------------------
                // 状态: THETA (置换第 1 阶段)
                // -------------------------------------------------------------
                S_THETA: begin
                    // 应用 Theta 变换的结果，写入 st
                    // 注意：这里的组合逻辑 st_after_theta 使用了当前周期的 bc 值
                    st <= st_after_theta;
                    state <= S_RHO_PI;
                end

                // -------------------------------------------------------------
                // 状态: RHO_PI (置换第 2 阶段)
                // -------------------------------------------------------------
                S_RHO_PI: begin
                    // 注意：st_after_rho_pi 的组合逻辑输入需要根据状态机调整
                    // 为了简化代码，我们在组合逻辑块里是基于 'st' 计算的。
                    // 因为上个周期刚更新了 st (为 Theta 后的值)，
                    // 所以当前周期 st_after_rho_pi 已经是基于 Theta 结果计算出的正确 Rho/Pi 值。
                    
                    // 这里我们其实不需要显式地 st <= st_after_rho_pi
                    // 因为 Chi 的计算可以直接级联在 Rho/Pi 后面。
                    // 为了时序优化（流水线切割），我们可以在这里打一拍，
                    // 把 Rho/Pi 的结果存入 st。
                    st <= st_after_rho_pi;
                    
                    state <= S_CHI_IOTA;
                end

                // -------------------------------------------------------------
                // 状态: CHI_IOTA (置换第 3 阶段)
                // -------------------------------------------------------------
                S_CHI_IOTA: begin
                    // 1. 应用 Chi 变换
                    // st_after_chi 的输入是 st (此时 st 存的是 Rho/Pi 后的值)
                    
                    // 2. 应用 Iota (只影响 st[0][0]) 并更新所有 st
                    for(int x=0; x<5; x++) begin
                        for(int y=0; y<5; y++) begin
                            if (x==0 && y==0)
                                st[x][y] <= st_after_chi[x][y] ^ get_rndc(round_cnt);
                            else
                                st[x][y] <= st_after_chi[x][y];
                        end
                    end

                    // 3. 同时也为下一轮计算准备 BC 值 (Look-ahead)
                    // 下一轮是 S_THETA，需要基于 "Chi/Iota 后的新状态" 计算 BC
                    // 这是一个关键优化，避免多浪费一个周期算 BC
                    for(int x=0; x<5; x++) begin
                        // 临时变量保存当前列的计算结果
                        logic [63:0] new_col_0, new_col_1, new_col_2, new_col_3, new_col_4;
                        
                        // 由于 st 还未更新，我们需要引用 st_after_chi 组合逻辑
                        // 并对 [0][0] 特殊处理 Iota
                        new_col_0 = (x==0) ? (st_after_chi[0][0] ^ get_rndc(round_cnt)) : st_after_chi[x][0];
                        new_col_1 = st_after_chi[x][1];
                        new_col_2 = st_after_chi[x][2];
                        new_col_3 = st_after_chi[x][3];
                        new_col_4 = st_after_chi[x][4];

                        bc[x] <= new_col_0 ^ new_col_1 ^ new_col_2 ^ new_col_3 ^ new_col_4;
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