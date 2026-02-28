//* 8-latency
`include "../../param_conf.v"
module NTT_BU(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [22 : 0]        data_in1,
    input       logic   [22 : 0]        data_in2,
    input       logic   [22 : 0]        zeta,

    output      logic                   valid_out,
    output      logic   [22 : 0]        data_out1,  // 模加 + 模乘
    output      logic   [22 : 0]        data_out2   // 模加 - 模乘
);

logic                   ModuleMult_valid;
logic   [22 : 0]        ModuleMult_res;

logic   [22 : 0]        data_in1_d [6 : 0];

//* 7-latency
ModuleMult u_ModuleMult(
	.clk       	( clk                   ),
	.rstn      	( rstn                  ),
	.valid_in  	( valid_in              ),
	.data_in1  	( data_in2              ),
	.data_in2  	( zeta                  ),
	.valid_out 	( ModuleMult_valid ),
	.data_out  	( ModuleMult_res   )
);

always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (!rstn) begin
        for (i = 0 ; i < 7 ; i = i + 1)
            data_in1_d[i] <= 'd0; 
    end
    else begin
        data_in1_d[0] <= data_in1;
        for (i = 1 ; i < 7 ; i = i + 1)
            data_in1_d[i] <= data_in1_d[i - 1];
    end
end

logic                   ModuleAdd_valid;
logic   [22 : 0]        ModuleAdd_res;
ModuleAdd u_ModuleAdd(
	.clk       	( clk                       ),
	.rstn      	( rstn                      ),
	.valid_in  	( ModuleMult_valid          ),
	.data_in1  	( data_in1_d[6]             ),
	.data_in2  	( ModuleMult_res            ),
	.valid_out 	( ModuleAdd_valid           ),
	.data_out  	( ModuleAdd_res             )
);

logic                   ModuleSub_valid;
logic   [22 : 0]        ModuleSub_res;
ModuleSub u_ModuleSub(
	.clk       	( clk                       ),
	.rstn      	( rstn                      ),
	.valid_in  	( ModuleMult_valid          ),
	.data_in1  	( data_in1_d[6]             ),
	.data_in2  	( ModuleMult_res            ),
	.valid_out 	( ModuleSub_valid           ),
	.data_out  	( ModuleSub_res             )
);

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        valid_out <= 'd0;
        data_out1 <= 'd0;
        data_out2 <= 'd0;
    end
    else begin
        valid_out <= ModuleAdd_valid | ModuleSub_valid;
        data_out1 <= ModuleAdd_res;
        data_out2 <= ModuleSub_res;
    end
end

endmodule
