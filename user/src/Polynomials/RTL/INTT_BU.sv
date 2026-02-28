//* 8-latency
`include "../../param_conf.v"
module INTT_BU(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [22 : 0]        data_in1,
    input       logic   [22 : 0]        data_in2,
    input       logic   [22 : 0]        zeta,

    output      logic                   valid_out,
    output      logic   [22 : 0]        data_out1,  // 模加 -> 模除 
    output      logic   [22 : 0]        data_out2   // 模减 -> 模乘 -> 模除
);

logic                   ModuleAdd_valid;
logic   [22 : 0]        ModuleAdd_res;
ModuleAdd u_ModuleAdd(
	.clk       	( clk                       ),
	.rstn      	( rstn                      ),
	.valid_in  	( valid_in                  ),
	.data_in1  	( data_in1                  ),
	.data_in2  	( data_in2                  ),
	.valid_out 	( ModuleAdd_valid           ),
	.data_out  	( ModuleAdd_res             )
);

logic                   ModuleSub_valid;
logic   [22 : 0]        ModuleSub_res;
ModuleSub u_ModuleSub(
	.clk       	( clk                       ),
	.rstn      	( rstn                      ),
	.valid_in  	( valid_in                  ),
	.data_in1  	( data_in1                  ),
	.data_in2  	( data_in2                  ),
	.valid_out 	( ModuleSub_valid           ),
	.data_out  	( ModuleSub_res             )
);

logic                   ModuleMult_valid;
logic   [22 : 0]        ModuleMult_res;
//* 7-latency
ModuleMult u_ModuleMult(
	.clk       	( clk                   ),
	.rstn      	( rstn                  ),
	.valid_in  	( ModuleSub_valid       ),
	.data_in1  	( ModuleSub_res         ),
	.data_in2  	( zeta                  ),
	.valid_out 	( ModuleMult_valid      ),
	.data_out  	( ModuleMult_res        )
);

logic   [22 : 0]        ModuleAdd_res_d [6 : 0];
logic   [6 : 0]         ModuleAdd_valid_d;
always_ff @(posedge clk or negedge rstn) begin
    integer i;
    if (!rstn) begin
        for (i = 0 ; i < 7 ; i = i + 1)
            ModuleAdd_res_d[i] <= 'd0; 
        ModuleAdd_valid_d <= 'd0;
    end
    else begin
        ModuleAdd_res_d[0] <= ModuleAdd_res;
        for (i = 1 ; i < 7 ; i = i + 1)
            ModuleAdd_res_d[i] <= ModuleAdd_res_d[i - 1];
        ModuleAdd_valid_d <= {ModuleAdd_valid_d[5 : 0], ModuleAdd_valid};
    end
end

logic                   ModuleDiv2_add_valid;
logic   [22 : 0]        ModuleDiv2_add_res;

ModuleDiv2 u_ModuleDiv2_add(
	.clk       	( clk                       ),
	.rstn      	( rstn                      ),
	.valid_in  	( ModuleAdd_valid_d[6]      ),
	.data_in   	( ModuleAdd_res_d[6]        ),
	.valid_out 	( ModuleDiv2_add_valid      ),
	.data_out  	( ModuleDiv2_add_res        )
);

logic                   ModuleDiv2_sub_valid;
logic   [22 : 0]        ModuleDiv2_sub_res;

ModuleDiv2 u_ModuleDiv2_sub(
	.clk       	( clk                       ),
	.rstn      	( rstn                      ),
	.valid_in  	( ModuleMult_valid          ),
	.data_in   	( ModuleMult_res            ),
	.valid_out 	( ModuleDiv2_sub_valid      ),
	.data_out  	( ModuleDiv2_sub_res        )
);

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        valid_out <= 'd0;
        data_out1 <= 'd0;
        data_out2 <= 'd0;
    end
    else begin
        valid_out <= ModuleDiv2_add_valid | ModuleDiv2_sub_valid;
        data_out1 <= ModuleDiv2_add_res;
        data_out2 <= ModuleDiv2_sub_res;
    end
end

endmodule
