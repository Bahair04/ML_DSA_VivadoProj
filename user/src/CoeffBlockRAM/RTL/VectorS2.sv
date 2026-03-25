`include "../../param_conf.v"
module VectorS2 #(
	parameter                   K = 8
)(
    // --- 时钟和复位信号 ---
    input       logic               clk,

    // --- Vector S ---
    input       logic   signed  [91 : 0]    w_VectorS2_Coeff,            // 4*4bit有符号数
    input       logic                       w_VectorS2_Coeff_valid,
    input       logic           [8 : 0]     w_VectorS2_Coeff_addr,

    output      logic           [91 : 0]    r_VectorS2_Coeff [0 : K - 1],            // 对q取模 无符号
    input       logic           [5 : 0]     r_VectorS2_Coeff_addr [0 : K - 1],
    input       logic                       ori_s2_coeff_en
);

logic           [91 : 0]            VectorS2_Coeff [0 : K - 1];            // 4*4bit有符号数
localparam                  		DATA_WIDTH = 'd92;
genvar i;
generate
	for (i = 0 ; i < K ; i = i + 1) begin : row_vector_bram
        logic                       we;
        logic   [5 : 0]             wr_addr;

        assign we = w_VectorS2_Coeff_valid && (i * 64 <= w_VectorS2_Coeff_addr && w_VectorS2_Coeff_addr < (i + 1) * 64);
        assign wr_addr = w_VectorS2_Coeff_addr - i * 64;
		inferred_bram #(
			.DEPTH      	( 64  		    ),				// 标量 共256个系数 每个地址存4个系数 共64个地址
			.ADDR_WIDTH 	( 6  		    ),				// 地址线宽：log2(64) = 6
			.DATA_WIDTH 	( DATA_WIDTH   	))				// 数据线宽：16 bit
		u_inferred_bram(
			.clk     	( clk      						    ),
			.we      	( we                                ),
			.wr_addr 	( wr_addr  		                    ),
			.wr_data 	( w_VectorS2_Coeff  			    ),
			.rd_addr 	( r_VectorS2_Coeff_addr[i]  		),
			.rd_data 	( VectorS2_Coeff[i]  			    )
		);
	end
endgenerate

always_comb begin
    for (int i = 0 ; i < K ; i = i + 1) begin
        if (!ori_s2_coeff_en) begin
            for (int j = 0 ; j < 4 ; j = j + 1) begin
                logic   [3 : 0]                raw_slice;
                raw_slice = VectorS2_Coeff[i][j * 23 +: 4];
                if (raw_slice[3])
                    r_VectorS2_Coeff[i][j * 23 +: 23] = {{19{raw_slice[3]}}, raw_slice} + `q;
                else
                    r_VectorS2_Coeff[i][j * 23 +: 23] = {{19{raw_slice[3]}}, raw_slice};
            end
        end
        else begin
            r_VectorS2_Coeff[i] = VectorS2_Coeff[i];
        end
    end    
end

endmodule
