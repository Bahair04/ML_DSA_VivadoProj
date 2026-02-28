module ReconfigComputeUnit(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [22 : 0]        A,
    input       logic   [22 : 0]        B,
    input       logic   [22 : 0]        Z,

    output      logic                   valid_out,
    output      logic   [22 : 0]        U,
    output      logic   [22 : 0]        V,

    // --- 可重构运算单元模式选择 ---
    input       logic                   mode_config
);

logic       	                NTT_BU_valid_out;
logic   [22 : 0] 	            NTT_BU_data_out1;
logic   [22 : 0] 	            NTT_BU_data_out2;
//* 8-latency
NTT_BU u_NTT_BU(
	.clk       	( clk               ),
	.rstn      	( rstn              ),
	.valid_in  	( valid_in          ),
	.data_in1  	( A                 ),
	.data_in2  	( B                 ),
	.zeta      	( Z                 ),
	.valid_out 	( NTT_BU_valid_out  ),
	.data_out1 	( NTT_BU_data_out1  ),
	.data_out2 	( NTT_BU_data_out2  )
);

logic       	                INTT_BU_valid_out;
logic   [22 : 0] 	            INTT_BU_data_out1;
logic   [22 : 0] 	            INTT_BU_data_out2;
//* 8-latency
INTT_BU u_INTT_BU(
	.clk       	( clk               ),
	.rstn      	( rstn              ),
	.valid_in  	( valid_in          ),
	.data_in1  	( A                 ),
	.data_in2  	( B                 ),
	.zeta      	( Z                 ),
	.valid_out 	( INTT_BU_valid_out ),
	.data_out1 	( INTT_BU_data_out1 ),
	.data_out2 	( INTT_BU_data_out2 )
);

logic                   ModuleMult_valid;
logic   [22 : 0]        ModuleMult_res;
//* 7-latency
ModuleMult u_ModuleMult(
	.clk       	( clk                   ),
	.rstn      	( rstn                  ),
	.valid_in  	( valid_in              ),
	.data_in1  	( A                     ),
	.data_in2  	( B                     ),
	.valid_out 	( ModuleMult_valid      ),
	.data_out  	( ModuleMult_res        )
);

logic                   ModuleAdd_valid;
logic   [22 : 0]        ModuleAdd_res;
//* 0-latency
ModuleAdd u_ModuleAdd(
	.clk       	( clk                       ),
	.rstn      	( rstn                      ),
	.valid_in  	( valid_in                  ),
	.data_in1  	( A                         ),
	.data_in2  	( B                         ),
	.valid_out 	( ModuleAdd_valid           ),
	.data_out  	( ModuleAdd_res             )
);

logic                   ModuleSub_valid;
logic   [22 : 0]        ModuleSub_res;
//* 0-latency
ModuleSub u_ModuleSub(
	.clk       	( clk                       ),
	.rstn      	( rstn                      ),
	.valid_in  	( valid_in                  ),
	.data_in1  	( A                         ),
	.data_in2  	( B                         ),
	.valid_out 	( ModuleSub_valid           ),
	.data_out  	( ModuleSub_res             )
);

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        valid_out <= 'd0;
        U <= 'd0;
        V <= 'd0;
    end
    else begin
        case (mode_config)
            'd0 : begin     // NTT
                valid_out <= NTT_BU_valid_out;
                U <= NTT_BU_data_out1;
                V <= NTT_BU_data_out2;
            end
            'd1 : begin     // INTT
                valid_out <= INTT_BU_valid_out;
                U <= INTT_BU_data_out1;
                V <= INTT_BU_data_out2;
            end
            'd2 : begin     // 模乘
                valid_out <= ModuleMult_valid;
                U <= ModuleMult_res;
                V <= 'd0;
            end
            'd3 : begin     // 模加
                valid_out <= ModuleAdd_valid;
                U <= ModuleAdd_res;
                V <= 'd0;
            end
            'd4 : begin     // 模减
                valid_out <= ModuleSub_valid;
                U <= ModuleSub_res;
                V <= 'd0;
            end
            default : begin
                valid_out <= 'd0;
                U <= 'd0;
                V <= 'd0;
            end
        endcase
    end
end

endmodule
