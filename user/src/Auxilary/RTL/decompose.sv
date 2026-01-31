`include "../../param_conf.v"
module decompose(
    // --- 时钟与复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- 输入信号 ---
    input       logic   [22 : 0]    t,
    input       logic               t_valid,

    // --- 输出信号 ---
    output      logic   [7 : 0]     o_t1,                     // 无符号   8位
    output      logic               t1_valid,
    output      logic   signed [18 : 0]    o_t0,              // 有符号   19位
    output      logic               t0_valid
);
logic           [39 : 0]            mult_1;
logic                               shift_1;
logic           [22 : 0]            tp;
logic           [22 : 0]            tp_d [0 : 3];
logic           [22 : 0]            t_d;

logic           [44 : 0]            mult_2;
logic           [43 : 0]            mult_3;
logic           [5 : 0]             shift_2;

logic           [22 : 0]            mult_gamma2;
logic   signed  [22 : 0]            t0;
logic   signed  [22 : 0]            t0_d;
logic   signed  [23 : 0]            t1;

logic           [7 : 0]             valid_d;

mult_gen_0 u_mult_gen_0 (                           // t * 2^39 / 8380417 = t * 65600
  .CLK(clk),        // input wire CLK
  .A(t),            // input wire [22 : 0] A
  .P(mult_1)        // output wire [39 : 0] P
);
assign shift_1 = mult_1 >> 39;

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        t_d <= 'd0;
    else 
        t_d <= t;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        tp <= 'd0;
    else begin
        if (shift_1)
            tp <= t_d - `q;
        else 
            tp <= t_d; 
    end
end

mult_gen_1 u_mult_gen_1 (                           // tp * 2^39 / (2 * 95232) = t * 2886402
  .CLK(clk),            // input wire CLK
  .A(tp),               // input wire [22 : 0] A
  .P(mult_2)            // output wire [44 : 0] P
);

mult_gen_2 u_mult_gen_2 (                           // tp * 2^39 / (2 * 261888) = t * 1049601
  .CLK(clk),            // input wire CLK
  .A(tp),               // input wire [22 : 0] A
  .P(mult_3)            // output wire [43 : 0] P
);

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        shift_2 <= 'd0;
    else begin
        case (`gamma_2)
            'd95232  : shift_2 <= (mult_2 + (1 << 29)) >> 39;
            'd261888 : shift_2 <= (mult_3 + (1 << 29)) >> 39;
            default : shift_2 <= 'd0;
        endcase
    end
end

// --- 523776 = 2^19 - 2^9 ---
// --- 190464 = 2 ^ 11 * 93 ---
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        mult_gamma2 <= 'd0;
    else begin
        case (`gamma_2)
            'd95232 : mult_gamma2 <= (shift_2 << 11) * 'd93;
            'd261888 : mult_gamma2 <= (shift_2 << 19) - (shift_2 << 9);
            default : mult_gamma2 <= 'd0;
        endcase
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        tp_d[0] <= 'd0;
        tp_d[1] <= 'd0;
        tp_d[2] <= 'd0;
        tp_d[3] <= 'd0;
    end
    else begin
        tp_d[0] <= tp;
        tp_d[1] <= tp_d[0];
        tp_d[2] <= tp_d[1];
        tp_d[3] <= tp_d[2];
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        t0 <= 'd0;
    else begin
        if (tp_d[2] - mult_gamma2 > `gamma_2)
            t0 <= $signed(tp_d[2] - mult_gamma2 - (`gamma_2 << 1));
        else 
            t0 <= $signed(tp_d[2] - mult_gamma2);
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        t1 <= 'd0;
    else 
        t1 <= $signed({1'b0, tp_d[3]} - {t0[22], t0});
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        t0_d <= 'd0;
    else 
        t0_d <= t0;
end


logic   [44 : 0]            tmp;
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        o_t1 <= 'd0;
        o_t0 <= 'd0;
    end
    else begin
        if (t1 == `q - 1) begin
            o_t1 <= 'd0;
            o_t0 <= t0_d - 1;
        end
        else begin
            o_t0 <= t0_d;
            case (`gamma_2)
                'd95232 : tmp = t1 * 'd2886402;
                'd261888 : tmp = t1 * 'd1049601;
                default : tmp = 'd0;
            endcase
            o_t1 <= (tmp + (1 << 29)) >> 39;          // o_t1 = round(t1 // gamma2)   这里+1/1024四舍五入
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        valid_d <= 'd0;
    else 
        valid_d <= {valid_d[6 : 0], t_valid};
end
assign t1_valid = valid_d[7];
assign t0_valid = valid_d[7];

endmodule
