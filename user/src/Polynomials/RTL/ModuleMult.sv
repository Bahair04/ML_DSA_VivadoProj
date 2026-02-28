//* 7-latency
module ModuleMult(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [22 : 0]        data_in1,
    input       logic   [22 : 0]        data_in2,

    output      logic                   valid_out,
    output      logic   [22 : 0]        data_out
);

logic       [42 : 0]            mult_res1;
logic       [42 : 0]            mult_res2;
logic                           mult_valid;
logic       [3 : 0]             mult_valid_d;

logic       [45 : 0]            U;
logic       [45 : 0]            U_d [1 : 0];
localparam  [31 : 0]            T = 8396807;
logic       [23 : 0]            V;
logic       [23 : 0]            V_d;
logic       [34 : 0]            V1;
logic       [25 : 0]            V2;
logic       [47 : 0]            V_concat;
logic       [23 : 0]            W;
logic       [23 : 0]            W_d;
logic       [46 : 0]            D;
logic       [34 : 0]            D1;
logic       [23 : 0]            res;

DSP_MultPipe u_DSP_MultPipe_1(
	.clk       	( clk        ),
	.rstn      	( rstn       ),
	.valid_in  	( valid_in   ),
	.data_in1  	( {2'd0, data_in1}             ),
	.data_in2  	( {12'd0, data_in2[22 : 17]}   ),
	.valid_out 	( mult_valid  ),
	.data_out  	( mult_res1   )
);

DSP_MultPipe u_DSP_MultPipe_2(
	.clk       	( clk        ),
	.rstn      	( rstn       ),
	.valid_in  	( valid_in   ),
	.data_in1  	( {2'd0, data_in1}             ),
	.data_in2  	( {1'b0, data_in2[16 : 0]}          ),
	.data_out 	( mult_res2  )
);

//* 1 pipline
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        U <= 'd0;
    else 
        U <= {mult_res1[28 : 0], 17'd0} + mult_res2[39 : 0];
end

assign V = U[45 : 22];
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        V_d <= 'd0;
    else 
        V_d <= V;
end

//* 1 pipline
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        V1 <= 'd0;
        V2 <= 'd0;
    end
    else begin
        V1 <= {V, 10'd0} + V;
        V2 <= {V, 1'b0} + V + V[23 : 1];
    end
end

assign V_concat = {V1 + V2[25 : 12], V2[11 : 0], V_d[0]};
assign W = V_concat[47 : 24];

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        W_d <= 'd0;
    else 
        W_d <= W;
end

//* 1 pipline
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        D1 <= 'd0;
    else 
        D1 <= {W, 10'd0} - W + W[23 : 13];
end

assign D = {D1, W_d[12 : 0]};

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        U_d[0] <= 'd0;
        U_d[1] <= 'd0;
    end
    else begin
        U_d[0] <= U;
        U_d[1] <= U_d[0];
    end
end

//* 1 pipline
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        res <= 'd0;
    else begin
        logic [23 : 0] temp = U_d[1][23 : 0]- D[23 : 0];
        if (temp >= `q)
            res <= temp - `q;
        else 
            res <= temp;
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        mult_valid_d <= 'd0;
    else 
        mult_valid_d <= {mult_valid_d[2 : 0], mult_valid};
end

assign data_out = res[22 : 0];
assign valid_out = mult_valid_d[3];
endmodule
