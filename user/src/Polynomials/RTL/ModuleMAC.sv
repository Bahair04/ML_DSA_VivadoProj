//* 7-latency
`include "../../param_conf.v"
module ModuleMAC(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [22 : 0]        data_in1,
    input       logic   [22 : 0]        data_in2,
    input       logic   [22 : 0]        data_in3,

    output      logic                   valid_out,
    output      logic   [22 : 0]        data_out
);

//* 7-latency
logic        	                    mult_valid_out;
logic           [22 : 0] 	        mult_data_out;
ModuleMult u_ModuleMult(
	.clk       	( clk               ),
	.rstn      	( rstn              ),
	.valid_in  	( valid_in          ),
	.data_in1  	( data_in1          ),
	.data_in2  	( data_in2          ),
	.valid_out 	( mult_valid_out    ),
	.data_out  	( mult_data_out     )
);


//* 0-latency
logic        	                    add_valid_out;
logic           [22 : 0] 	        add_data_out;
logic           [22 : 0]            data_in3_delay [6 : 0];

always_ff @(posedge clk) begin : data_in3_delay_block
    integer i;
    if (!rstn) begin
        for (i = 0 ; i < 7 ; i = i + 1)
            data_in3_delay[i] <= 'd0;
    end
    else begin
        data_in3_delay[0] <= data_in3;
        for (i = 1 ; i < 7 ; i = i + 1)
            data_in3_delay[i] <= data_in3_delay[i - 1];
    end
end

ModuleAdd u_ModuleAdd(
	.clk       	( clk               ),
	.rstn      	( rstn              ),
	.valid_in  	( mult_valid_out    ),
	.data_in1  	( mult_data_out     ),
	.data_in2  	( data_in3_delay[6] ),
	.valid_out 	( add_valid_out     ),
	.data_out  	( add_data_out      )
);

assign valid_out = add_valid_out;
assign data_out = add_data_out;


endmodule
