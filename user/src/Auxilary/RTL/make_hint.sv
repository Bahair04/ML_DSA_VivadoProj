`include "../../param_conf.v"
module make_hint(
    // --- 时钟与复位信号 ---
    input       logic                       clk,
    input       logic                       rstn,

    // --- 输入信号接口 ---
    input       logic   signed  [24 : 0]    r_d,
    input       logic   signed  [24 : 0]    r_plus_z,
    input       logic                       i_valid,

    // --- 输出信号接口 ---
    output      logic                       hint,
    output      logic                       o_valid     
);

logic           [7 : 0]             r1;
logic                               r1_valid;
logic           [7 : 0]             v1;
logic                               v1_valid;

genvar i;
generate
    if (`gamma_2 == 95232) begin
        Decomposes u_Decomposes_r(
            .clk      	( clk       ),
            .rstn     	( rstn      ),
            .r        	( r_d       ),
            .r_valid  	( i_valid   ),
            .r1       	( r1        ),
            .r1_valid 	( r1_valid  )
        );

        Decomposes u_Decomposes_v(
            .clk      	( clk       ),
            .rstn     	( rstn      ),
            .r        	( r_plus_z  ),
            .r_valid  	( i_valid   ),
            .r1       	( v1        ),
            .r1_valid 	( v1_valid  )
        );
    end
    else begin
        Decomposes2 u_Decomposes2_r(
            .clk      	( clk       ),
            .rstn     	( rstn      ),
            .r        	( r_d       ),
            .r_valid  	( i_valid   ),
            .r1       	( r1        ),
            .r1_valid 	( r1_valid  )
        );

        Decomposes2 u_Decomposes2_v(
            .clk      	( clk       ),
            .rstn     	( rstn      ),
            .r        	( r_plus_z  ),
            .r_valid  	( i_valid   ),
            .r1       	( v1        ),
            .r1_valid 	( v1_valid  )
        );
    end
endgenerate



//* 1-latency
always_ff @(posedge clk) begin
    if (!rstn) begin
        hint <= 1'b0;
        o_valid <= 1'b0;
    end
    else begin
        if (r1_valid) begin
            if (r1 != v1)
                hint <= 1'b1;
            else 
                hint <= 1'b0;
            end
        else 
            hint <= 1'b0;
        o_valid <= r1_valid;
    end
end

endmodule
