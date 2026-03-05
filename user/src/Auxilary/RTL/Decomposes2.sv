`include "../../param_conf.v"
//* 9-latency γ2 = 261888
module Decomposes2(
    // --- 时钟与复位信号 ---
    input       logic                       clk,
    input       logic                       rstn,

    // --- 输入信号 ---
    input       logic   signed  [23 : 0]    r,
    input       logic                       r_valid,

    // --- 输出信号 ---
    output      logic           [7 : 0]     r1,                     // 无符号   8位
    output      logic                       r1_valid,
    output      logic   signed  [18 : 0]    r0,                     // 有符号   19位
    output      logic                       r0_valid
);

logic   signed  [23 : 0]            r_prime;
logic   signed  [23 : 0]            r_prime_d [1 : 0];
logic           [1 : 0]             V;
logic           [1 : 0]             V_d;
logic           [12 : 0]            V1;
logic           [3 : 0]             V2;
logic           [26 : 0]            V_concat;
logic           [2 : 0]             U;
logic           [2 : 0]             U_d;
logic           [13 : 0]            U1;
logic           [26 : 0]            X;
logic           [23 : 0]            rp;
logic           [23 : 0]            rp_d [2 : 0];
logic           [6 : 0]             rp_shift1;
logic           [17 : 0]            rp_v1;
logic           [25 : 0]            rp_con1;
logic           [6 : 0]             rp_con1_clip;
logic           [17 : 0]            rp_con1_clip_p1;
logic           [27 : 0]            rp_mult1;
logic   signed  [23 : 0]            rp_sub1;
logic   signed  [23 : 0]            r0_1;
logic   signed  [23 : 0]            r0_1_d;
logic   signed  [23 : 0]            r1_sub;
logic           [9 : 0]             r_valid_d;

//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn)
        r_prime <= 'd0;
    else begin
        if (r < 0)
            r_prime <= r + `q;
        else 
            r_prime <= r;
    end
end

assign V = r_prime[23 : 22];

//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn) begin
        V1 <= 'd0;
        V2 <= 'd0;
    end
    else begin
        V1 <= {1'b0, V, 10'd0} + {11'd0, V};
        V2 <= {1'b0, V, 1'b0} + V + V[1];
    end
end

assign V_concat = {1'b0, V1, 8'd0, V2, V_d[0]};
assign U = V_concat[26 : 24];

//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn)
        U1 <= 'd0;
    else begin
        U1 <= {1'b0, U, 10'd0} - {1'b0, U};
    end
end

assign X = (U1 << 13) + U_d;

//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn)
        rp <= 'd0;
    else begin
        if (r_prime_d[1] - $signed({1'b0, X}) > `q)
            rp <= r_prime_d[1] - X - `q;
        else 
            rp <= r_prime_d[1] - X;
    end
end

assign rp_shift1 = rp[23 : 17];

//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn)
        rp_v1 <= 'd0;
    else 
        rp_v1 <= (rp_shift1 << 10) + rp_shift1;
end
assign rp_con1 = rp_v1 << 7;
assign rp_con1_clip = rp_con1[25 : 19];

//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn) begin
        rp_con1_clip_p1 <= 'd0;
    end
    else begin
        rp_con1_clip_p1 <= (rp_con1_clip << 10) - rp_con1_clip;
    end
end
assign rp_mult1 = rp_con1_clip_p1 << 9;
assign rp_sub1 = (rp_d[1] - {1'b0, rp_mult1[22 : 0]} > 2 * `gamma_2) ? (rp_d[1] - {1'b0, rp_mult1[22 : 0]} - 2 * `gamma_2):
                    rp_d[1] - {1'b0, rp_mult1[22 : 0]};

//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn)
        r0_1 <= 'd0;
    else if (rp_sub1 > `gamma_2)
        r0_1 <= rp_sub1 - `gamma_2 * 2;
    else 
        r0_1 <= rp_sub1;
end

//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn)
        r1_sub <= 'd0;
    else 
        r1_sub <= rp_d[2] - r0_1;
end

//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn) begin
        r1 <= 'd0;
        r0 <= 'd0;
    end
    else begin
        if (r1_sub == `q - 1) begin
            r1 <= 'd0;
            r0 <= r0_1_d - 1;
        end
        else begin
            r1 <= r1_sub / (2 * `gamma_2);
            r0 <= r0_1_d;
        end
    end
end

always_ff @(posedge clk) begin : DelayBlock
    integer i;
    if (!rstn) begin
        V_d <= 'd0;
        U_d <= 'd0;
        r_prime_d[0] <= 'd0;
        r_prime_d[1] <= 'd0;
        rp_d[0] <= 'd0;
        rp_d[1] <= 'd0;
        rp_d[2] <= 'd0;
        r0_1_d <= 'd0;
        for (i = 0; i < 10; i = i + 1)
            r_valid_d[i] <= 'd0;
    end
    else begin
        V_d <= V;
        U_d <= U;
        r_prime_d[0] <= r_prime;
        r_prime_d[1] <= r_prime_d[0];
        rp_d[0] <= rp;
        rp_d[1] <= rp_d[0];
        rp_d[2] <= rp_d[1];
        r0_1_d <= r0_1;
        r_valid_d[0] <= r_valid;
        for (i = 1 ; i < 10 ; i = i + 1)
            r_valid_d[i] <= r_valid_d[i - 1];
    end
end
assign r0_valid = r_valid_d[8];
assign r1_valid = r_valid_d[8];
endmodule
