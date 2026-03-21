`include "../../param_conf.v"
module MatrixA #(
	parameter                   K = 8,
    parameter                   L = 7
)(
    // --- 时钟和复位信号 ---
    input       logic                   clk,

    // --- Matrix A ---
    input       logic           [91 : 0]    w_MatrixA_Coeff,
    input       logic                       w_MatrixA_Coeff_valid,
    input       logic           [11 : 0]    w_MatrixA_Coeff_addr,
    
    output      logic           [91 : 0]    r_MatrixA_Coeff [0 : K - 1],
    input       logic           [8 : 0]     r_MatrixA_Coeff_addr [0 : K - 1]
);

localparam                          DATA_WIDTH = 'd92;
genvar i;
generate
    for (i = 0 ; i < K ; i = i + 1) begin : row_vector_bram
        logic                       we;
        logic   [8 : 0]             wr_addr;

        assign we = w_MatrixA_Coeff_valid && (i * (L * 64) <= w_MatrixA_Coeff_addr && w_MatrixA_Coeff_addr < (i + 1) * (L * 64));
        assign wr_addr = w_MatrixA_Coeff_addr - i * (L * 64);

        inferred_bram #(
            .DEPTH          ( 448           ),              // l维行向量 共l*256个系数 每个地址存4个系数 共448个地址 (l最大为7来计算)
            .ADDR_WIDTH     ( 9             ),              // 地址线宽：log2(448) = 9
            .DATA_WIDTH     ( DATA_WIDTH    ))              // 数据线宽：92 bit
        u_inferred_bram(
            .clk        ( clk                           ),
            .we         ( we                            ),
            .wr_addr    ( wr_addr                       ),
            .wr_data    ( w_MatrixA_Coeff               ),
            .rd_addr    ( r_MatrixA_Coeff_addr[i]       ),  
            .rd_data    ( r_MatrixA_Coeff[i]            )   
        );
    end
endgenerate

endmodule
