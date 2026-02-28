module ReconfigCompute(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 输入和输出信号 ---
    input       logic                   valid_in,
    input       logic   [91 : 0]        A,
    input       logic   [91 : 0]        B,
    input       logic   [91 : 0]        Z,

    output      logic                   valid_out,
    output      logic   [91 : 0]        D,

    // --- 可重构运算单元模式选择 ---
    input       logic                   mode_config     // 0: NTT 1: INTT 2: ModuleMult 3: ModuleAdd 4: ModuleSub
);

logic       [22 : 0]            a1, a2, a3, a4;
logic       [22 : 0]            b1, b2, b3, b4;
logic       [22 : 0]            z1, z2, z3, z4;
logic       [22 : 0]            d1, d2, d3, d4;

assign {a1, a2, a3, a4} = A;
assign {b1, b2, b3, b4} = B;
assign {z1, z2, z3, z4} = Z;
assign D = {d1, d2, d3, d4};

logic                           valid_in_1, valid_in_2, valid_in_3, valid_in_4;
logic       [22 : 0]            A_1, A_2, A_3, A_4;
logic       [22 : 0]            B_1, B_2, B_3, B_4;
logic       [22 : 0]            Z_1, Z_2, Z_3, Z_4;
logic        	                valid_out_1, valid_out_2, valid_out_3, valid_out_4;
logic       [22 : 0] 	        U_1, U_2, U_3, U_4;
logic       [22 : 0] 	        V_1, V_2, V_3, V_4;

always_comb begin
    
    case (mode_config)
        'd0 : begin         // NTT
            valid_in_1 = valid_in;
            valid_in_2 = valid_in;
            valid_in_3 = valid_out_1;
            valid_in_4 = valid_out_2;
            
            A_1 = a1;
            B_1 = a2;
            Z_1 = z1;

            A_2 = a3;
            B_2 = a4;
            Z_2 = z1;

            A_3 = U_1;
            B_3 = U_2;
            Z_3 = z2;

            A_4 = V_1;
            B_4 = V_2;
            Z_4 = z3;

            d1 = U_3;
            d2 = U_4;
            d3 = V_3;
            d4 = V_4;

            valid_out = valid_out_3 | valid_out_4;
        end
        'd1 : begin         // INTT
            valid_in_1 = valid_in;
            valid_in_2 = valid_in;
            valid_in_3 = valid_out_1;
            valid_in_4 = valid_out_2;
            
            A_1 = a1;
            B_1 = a2;
            Z_1 = z2;

            A_2 = a3;
            B_2 = a4;
            Z_2 = z3;

            A_3 = U_1;
            B_3 = U_2;
            Z_3 = z1;

            A_4 = V_1;
            B_4 = V_2;
            Z_4 = z1;

            d1 = U_3;
            d2 = V_3;
            d3 = U_4;
            d4 = V_4;

            valid_out = valid_out_3 | valid_out_4;
        end
        'd2 : begin             // ModuleMult
            valid_in_1 = valid_in;
            valid_in_2 = valid_in;
            valid_in_3 = valid_in;
            valid_in_4 = valid_in;
            
            A_1 = a1;
            B_1 = b1;
            Z_1 = z1;

            A_2 = a2;
            B_2 = b2;
            Z_2 = z2;

            A_3 = a3;
            B_3 = b3;
            Z_3 = z3;

            A_4 = a4;
            B_4 = b4;
            Z_4 = z4;

            d1 = U_1;
            d2 = U_2;
            d3 = U_3;
            d4 = U_4;

            valid_out = valid_out_1 | valid_out_2 | valid_out_3 | valid_out_4;
        end
        'd3, 'd4 : begin         // ModuleAdd, ModuleSub
            valid_in_1 = valid_in;
            valid_in_2 = valid_in;
            valid_in_3 = valid_in;
            valid_in_4 = valid_in;
            
            A_1 = a1;
            B_1 = b1;
            Z_1 = 'd0;

            A_2 = a2;
            B_2 = b2;
            Z_2 = 'd0;

            A_3 = a3;
            B_3 = b3;
            Z_3 = 'd0;

            A_4 = a4;
            B_4 = b4;
            Z_4 = 'd0;

            d1 = U_1;
            d2 = U_2;
            d3 = U_3;
            d4 = U_4;

            valid_out = valid_out_1 | valid_out_2 | valid_out_3 | valid_out_4;
        end
    endcase
end

ReconfigComputeUnit u_ReconfigComputeUnit_1(
	.clk         	( clk           ),
	.rstn        	( rstn          ),
	.valid_in    	( valid_in_1    ),
	.A           	( A_1           ),
	.B           	( B_1           ),
	.Z           	( Z_1           ),
	.valid_out   	( valid_out_1   ),
	.U           	( U_1           ),
	.V           	( V_1           ),
	.mode_config 	( mode_config   )
);

ReconfigComputeUnit u_ReconfigComputeUnit_2(
	.clk         	( clk           ),
	.rstn        	( rstn          ),
	.valid_in    	( valid_in_2    ),
	.A           	( A_2           ),
	.B           	( B_2           ),
	.Z           	( Z_2           ),
	.valid_out   	( valid_out_2   ),
	.U           	( U_2           ),
	.V           	( V_2           ),
	.mode_config 	( mode_config   )
);

ReconfigComputeUnit u_ReconfigComputeUnit_3(
    .clk         	( clk           ),
    .rstn        	( rstn          ),
    .valid_in    	( valid_in_3    ),
    .A           	( A_3           ),
    .B           	( B_3           ),
    .Z           	( Z_3           ),
    .valid_out   	( valid_out_3   ),
    .U           	( U_3           ),
    .V           	( V_3           ),
    .mode_config 	( mode_config   )
);

ReconfigComputeUnit u_ReconfigComputeUnit_4(
	.clk         	( clk           ),
	.rstn        	( rstn          ),
	.valid_in    	( valid_in_4    ),
	.A           	( A_4           ),
	.B           	( B_4           ),
	.Z           	( Z_4           ),
	.valid_out   	( valid_out_4   ),
	.U           	( U_4           ),
	.V           	( V_4           ),
	.mode_config 	( mode_config   )
);


endmodule
