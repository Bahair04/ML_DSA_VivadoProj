`timescale 1ns / 1ps

module tb_keccak;

// --- 参数定义 ---
parameter PERIOD = 10;

// --- 信号定义 ---
logic           clk = 0;
logic           rstn = 0;
logic           init = 0;
logic           start_perm = 0;
logic           din_valid = 0;
logic [63:0]    din = 0;
logic [2:0]     din_row = 0;
logic [2:0]     din_col = 0;

// Output
logic           perm_done;
logic [0:4][0:4][63:0] st_out;

// --- 时钟生成 ---
initial begin
    forever #(PERIOD/2) clk = ~clk;
end

// --- 复位生成 ---
initial begin
    #(PERIOD*2) rstn = 1;
end

// --- 主测试流程 ---
initial begin
    // 1. 等待复位并初始化
    wait(rstn == 1);
    repeat (5) @(posedge clk);
    
    // 发送 init 脉冲确保状态机复位
    init <= 1;
    @(posedge clk);
    init <= 0;
    @(posedge clk);

    // 2. 开始写入数据 (DIN_VALID 拉高)
    din_valid <= 1'b1;

    // -----------------------------------------------------------
    // Row 0 (第 0 行)
    // -----------------------------------------------------------
    din <= 64'h0000111122223333; din_row <= 3'd0; din_col <= 3'd0; @(posedge clk);
    din <= 64'h4444555566667777; din_row <= 3'd0; din_col <= 3'd1; @(posedge clk);
    din <= 64'h88889999AAAABBBB; din_row <= 3'd0; din_col <= 3'd2; @(posedge clk);
    din <= 64'hCCCCDDDDEEEEFFFF; din_row <= 3'd0; din_col <= 3'd3; @(posedge clk);
    din <= 64'h0000111122223333; din_row <= 3'd0; din_col <= 3'd4; @(posedge clk);

    // -----------------------------------------------------------
    // Row 1 (第 1 行) - 补全这里
    // -----------------------------------------------------------
    din <= 64'h4444555566667777; din_row <= 3'd1; din_col <= 3'd0; @(posedge clk);
    din <= 64'h88889999AAAABBBB; din_row <= 3'd1; din_col <= 3'd1; @(posedge clk);
    din <= 64'hCCCCDDDDEEEEFFFF; din_row <= 3'd1; din_col <= 3'd2; @(posedge clk);
    din <= 64'h0000111122223333; din_row <= 3'd1; din_col <= 3'd3; @(posedge clk);
    din <= 64'h4444555566667777; din_row <= 3'd1; din_col <= 3'd4; @(posedge clk);

    // -----------------------------------------------------------
    // Row 2 (第 2 行) - 补全这里
    // -----------------------------------------------------------
    din <= 64'h88889999AAAABBBB; din_row <= 3'd2; din_col <= 3'd0; @(posedge clk);
    din <= 64'hCCCCDDDDEEEEFFFF; din_row <= 3'd2; din_col <= 3'd1; @(posedge clk);
    din <= 64'h0000111122223333; din_row <= 3'd2; din_col <= 3'd2; @(posedge clk);
    din <= 64'h4444555566667777; din_row <= 3'd2; din_col <= 3'd3; @(posedge clk);
    din <= 64'h88889999AAAABBBB; din_row <= 3'd2; din_col <= 3'd4; @(posedge clk);

    // -----------------------------------------------------------
    // Row 3 (第 3 行) - 补全这里
    // -----------------------------------------------------------
    din <= 64'hCCCCDDDDEEEEFFFF; din_row <= 3'd3; din_col <= 3'd0; @(posedge clk);
    din <= 64'h0000111122223333; din_row <= 3'd3; din_col <= 3'd1; @(posedge clk);
    din <= 64'h4444555566667777; din_row <= 3'd3; din_col <= 3'd2; @(posedge clk);
    din <= 64'h88889999AAAABBBB; din_row <= 3'd3; din_col <= 3'd3; @(posedge clk);
    din <= 64'hCCCCDDDDEEEEFFFF; din_row <= 3'd3; din_col <= 3'd4; @(posedge clk);

    // -----------------------------------------------------------
    // Row 4 (第 4 行) - 补全这里
    // -----------------------------------------------------------
    din <= 64'h0000111122223333; din_row <= 3'd4; din_col <= 3'd0; @(posedge clk);
    din <= 64'h4444555566667777; din_row <= 3'd4; din_col <= 3'd1; @(posedge clk);
    din <= 64'h88889999AAAABBBB; din_row <= 3'd4; din_col <= 3'd2; @(posedge clk);
    din <= 64'hCCCCDDDDEEEEFFFF; din_row <= 3'd4; din_col <= 3'd3; @(posedge clk);
    din <= 64'h0000111122223333; din_row <= 3'd4; din_col <= 3'd4; @(posedge clk);

    // // -----------------------------------------------------------
    // // Row 0 (第 0 行)
    // // -----------------------------------------------------------
    // din <= 64'd5931055232364332360; din_row <= 3'd0; din_col <= 3'd0; @(posedge clk);
    // din <= 64'd2049100; din_row <= 3'd0; din_col <= 3'd1; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd0; din_col <= 3'd2; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd0; din_col <= 3'd3; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd0; din_col <= 3'd4; @(posedge clk);

    // // -----------------------------------------------------------
    // // Row 1 (第 1 行) - 补全这里
    // // -----------------------------------------------------------
    // din <= 64'h0; din_row <= 3'd1; din_col <= 3'd0; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd1; din_col <= 3'd1; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd1; din_col <= 3'd2; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd1; din_col <= 3'd3; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd1; din_col <= 3'd4; @(posedge clk);

    // // -----------------------------------------------------------
    // // Row 2 (第 2 行) - 补全这里
    // // -----------------------------------------------------------
    // din <= 64'h0; din_row <= 3'd2; din_col <= 3'd0; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd2; din_col <= 3'd1; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd2; din_col <= 3'd2; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd2; din_col <= 3'd3; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd2; din_col <= 3'd4; @(posedge clk);

    // // -----------------------------------------------------------
    // // Row 3 (第 3 行) - 补全这里
    // // -----------------------------------------------------------
    // din <= 64'h0; din_row <= 3'd3; din_col <= 3'd0; @(posedge clk);
    // din <= 64'd9223372036854775808; din_row <= 3'd3; din_col <= 3'd1; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd3; din_col <= 3'd2; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd3; din_col <= 3'd3; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd3; din_col <= 3'd4; @(posedge clk);

    // // -----------------------------------------------------------
    // // Row 4 (第 4 行) - 补全这里
    // // -----------------------------------------------------------
    // din <= 64'h0; din_row <= 3'd4; din_col <= 3'd0; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd4; din_col <= 3'd1; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd4; din_col <= 3'd2; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd4; din_col <= 3'd3; @(posedge clk);
    // din <= 64'h0; din_row <= 3'd4; din_col <= 3'd4; @(posedge clk);

    // 3. 停止写入
    din_valid <= 0;
    din <= '0;
    @(posedge clk);

    // 4. ***关键步骤***：启动置换 (START)
    // 如果没有这一步，Keccak 永远不会开始计算
    start_perm <= 1; 
    @(posedge clk);
    start_perm <= 0;

    // 5. 等待完成信号
    wait(perm_done == 1);
    $display("Test Passed: Keccak Permutation Finished at time %t", $time);

    // 打印结果示例：查看中间的一个数据
    $display("Result Check: st_out[2][2] = %16h", st_out[2][2]);

    repeat (20) @(posedge clk);
    $finish;
end

// --- 模块实例化 ---
// 注意：模块名一定要和你设计文件里的名字一致 (这里假设是 keccakf)
keccak u_keccak (
    .clk        (clk),
    .rstn       (rstn),
    .init       (init),
    .start_perm (start_perm),
    .din_valid  (din_valid),
    .din        (din),
    .din_row    (din_row),
    .din_col    (din_col),
    .perm_done  (perm_done),
    .st_out     (st_out)
);

endmodule