`include "../param_conf.v"
//* 4-latency
module power2round(
    // --- 时钟与复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- 数据输入接口 ---
    input       logic   [22 : 0]    t_input,
    input       logic               t_valid_input,

    // --- 数据输出接口 ---
    output      logic   [9 : 0]     t1,             // 无符号   10位
    output      logic               t1_valid,
    output      logic   [12 : 0]    t0,             // 无符号   13位
    output      logic               t0_valid
);

// ==========================================================
// 参数定义
// ==========================================================
logic           [22 : 0]            add;
logic           [22 : 0]            y;
logic           [3 : 0]             t_valid_d;
logic   signed  [12 : 0]            x;
logic           [22 : 0]            t_d1, t_d2;

logic           [9 : 0]             shift;
logic           [9 : 0]             shift_d [2 : 0];

logic           [22 : 0]            t;
logic                               t_valid;

always_ff @(posedge clk or negedge rstn) begin      // 寄存一拍优化时序
    if (!rstn) begin
        t <= 'd0;
        t_valid <= 'd0;
    end
    else begin
        t <= t_input;
        t_valid <= t_valid_input;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        t_valid_d <= 'd0;
    else 
        t_valid_d <= {t_valid_d[2 : 0], t_valid};
end

always_ff @(posedge clk) begin
    if (t_valid)    
        t_d1 <= t;          // Stage 1: 和 add 同级
    if (t_valid_d[0]) 
        t_d2 <= t_d1;       // Stage 2: 和 y 同级
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        add <= 'd0;
    else if (t_valid)
        add <= t + 'd4095;          // 先加4095 便于后面移位以后的四舍五入
    else 
        add <= 'd0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        y <= 'd0;
    else if (t_valid_d[0])
        y <= add & (`q - 1);        // 与运算的结果是 低 13 位全部置0，高 10 位不变
    else 
        y <= 'd0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        x <= 'd0;
    else if (t_valid_d[1])
        x <= $signed(t_d2 - y);     // 高 10 位清 0，保留低 13 位 有符号数 (-4096, 4096]
    else 
        x <= 'd0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        t0 <= 'd0;
    else if (t_valid_d[2])
        t0 <= 4096 - x;             // 无符号数     [0, 8192)
    else 
        t0 <= 'd0;
end

assign t0_valid = t_valid_d[3];

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        shift <= 'd0;
    else if (t_valid_d[0])
        shift <= add >> 13;             // 23 位右移 13 位获得 10 位 取高10位为 t1 无符号数
    else 
        shift <= 'd0;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        shift_d[0] <= 'd0;
        shift_d[1] <= 'd0;
        shift_d[2] <= 'd0;
    end
    else begin
        shift_d[0] <= shift;
        shift_d[1] <= shift_d[0];
        shift_d[2] <= shift_d[1];
    end
end
assign t1 = shift_d[1];
assign t1_valid = t_valid_d[3];

endmodule
