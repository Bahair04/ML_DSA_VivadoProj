module DSP_MultPipe(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [24 : 0]        data_in1,
    input       logic   [17 : 0]        data_in2,

    output      logic                   valid_out,
    output      logic   [42 : 0]        data_out
);

logic   [24 : 0]        a_reg;
logic   [24 : 0]        b_reg;
logic   [42 : 0]        m_reg;
logic   [42 : 0]        p_reg;

logic   [2 : 0]         valid_in_d;

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        a_reg <= 0;
        b_reg <= 0;
        m_reg <= 0;
        p_reg <= 0;
    end
    else begin
        a_reg <= data_in1;
        b_reg <= data_in2;
        m_reg <= a_reg * b_reg;
        p_reg <= m_reg;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        valid_in_d <= 'd0;
    else
        valid_in_d <= {valid_in_d[1 : 0], valid_in};
end

assign data_out = p_reg;
assign valid_out = valid_in_d[2];

endmodule