`include "../../param_conf.v"
module use_hint(
    // --- 时钟与复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- 输入信号接口 ---
    input       logic               h,
    input       logic   [22 : 0]    t,
    input       logic               i_valid,

    // --- 输出信号接口 ---
    output      logic   [7 : 0]     t1,
    output      logic               o_valid     
);

localparam      M = (`q - 1) / (2 * `gamma_2);

logic               [7 : 0]                 t1_raw;
logic                                       t1_valid;
logic   signed      [18 : 0]                t0;
logic                                       t0_valid;

logic               [8 : 0]                 h_d;
logic   signed      [8 : 0]                 t1_prime;
logic                                       valid_d;

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        h_d <= 'd0;
    else 
        h_d <= {h_d[7 : 0], h}; 
end

always_comb begin
    t1_prime = $signed({1'b0, t1_raw});
    if (t1_valid && h_d[8]) begin 
        if (t0 > 0) 
            t1_prime = t1_prime + 1'b1;
        else 
            t1_prime = t1_prime - 1'b1;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        t1 <= 'd0;
    else begin
        if (t1_prime < 0)
            t1 <= t1_prime + M;
        else if (t1_prime >= M)
            t1 <= t1_prime - M;
        else 
            t1 <= t1_prime;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        valid_d <= 1'b0;
    else 
        valid_d <= t1_valid;
end

assign o_valid = valid_d;

generate
    if (`gamma_2 == 95232) begin
        Decomposes u_Decomposes_r(
            .clk        ( clk       ),
            .rstn       ( rstn      ),
            .r          ( {2'b0, t} ),
            .r_valid    ( i_valid   ),
            .r1         ( t1_raw    ),
            .r1_valid   ( t1_valid  ),
            .r0         ( t0        ),
            .r0_valid   ( t0_valid  ) 
        );
    end
    else begin
        Decomposes2 u_Decomposes2_r(
            .clk        ( clk       ),
            .rstn       ( rstn      ),
            .r          ( {2'b0, t} ),
            .r_valid    ( i_valid   ),
            .r1         ( t1_raw    ),
            .r1_valid   ( t1_valid  ),
            .r0         ( t0        ),
            .r0_valid   ( t0_valid  )
        );
    end
endgenerate

endmodule