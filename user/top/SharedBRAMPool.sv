`include "../src/param_conf.v"
module SharedBRAMPool
#(
    parameter           K = `k,
    parameter           L = `l
)(
    // --- 时钟和复位信号 ---
	input       logic               clk,
    input       logic               rstn,

    // --- BRAM 总线信号 ---
    input       logic           [91 : 0]    w_MatrixA_Coeff,
    input       logic                       w_MatrixA_Coeff_valid,
    input       logic           [11 : 0]    w_MatrixA_Coeff_addr,
    output      logic           [91 : 0]    r_MatrixA_Coeff [0 : K - 1],
    input       logic           [8 : 0]     r_MatrixA_Coeff_addr [0 : K - 1],

    input       logic   signed  [15 : 0]    w_VectorS1_Coeff,                   // 4*4bit有符号数
    input       logic                       w_VectorS1_Coeff_valid,
    input       logic           [8 : 0]     w_VectorS1_Coeff_addr,
    output      logic           [91 : 0]    r_VectorS1_Coeff,                   // 对q取模 无符号
    input       logic           [8 : 0]     r_VectorS1_Coeff_addr,

    input       logic   signed  [15 : 0]    w_VectorS2_Coeff,                   // 4*4bit有符号数
    input       logic                       w_VectorS2_Coeff_valid,
    input       logic           [8 : 0]     w_VectorS2_Coeff_addr,
    output      logic           [91 : 0]    r_VectorS2_Coeff [0 : K - 1],       // 对q取模 无符号
    input       logic           [5 : 0]     r_VectorS2_Coeff_addr [0 : K - 1],

    input       logic   signed  [79 : 0]    w_VectorY_Coeff,
    input       logic                       w_VectorY_Coeff_valid,
    input       logic           [5 : 0]     w_VectorY_Coeff_addr,
    output      logic           [91 : 0]    r_VectorY_Coeff,
    input       logic           [5 : 0]     r_VectorY_Coeff_addr,

    input       logic           [91 : 0]    w_VectorT_Coeff [0 : K - 1],
    input       logic                       w_VectorT_Coeff_valid [0 : K - 1],
    input       logic           [5 : 0]     w_VectorT_Coeff_addr [0 : K - 1],
    output      logic           [91 : 0]    r_VectorT_Coeff [0 : K - 1],
    input       logic           [5 : 0]     r_VectorT_Coeff_addr [0 : K - 1]

);

CoeffBlockRAM #(
    .K  ( K  ),
    .L  ( L  )
)u_CoeffBlockRAM(
    // --- 时钟和复位信号 ---
    .clk                            (clk                        ),

    // --- Matrix A ---
    .w_MatrixA_Coeff                (w_MatrixA_Coeff            ),
    .w_MatrixA_Coeff_valid          (w_MatrixA_Coeff_valid      ),
    .w_MatrixA_Coeff_addr           (w_MatrixA_Coeff_addr       ),
    .r_MatrixA_Coeff                (r_MatrixA_Coeff            ),
    .r_MatrixA_Coeff_addr           (r_MatrixA_Coeff_addr       ),

    // --- Vector S ---
    .w_VectorS1_Coeff               (w_VectorS1_Coeff           ),
    .w_VectorS1_Coeff_valid         (w_VectorS1_Coeff_valid     ),
    .w_VectorS1_Coeff_addr          (w_VectorS1_Coeff_addr      ),
    .r_VectorS1_Coeff               (r_VectorS1_Coeff           ),
    .r_VectorS1_Coeff_addr          (r_VectorS1_Coeff_addr      ),

    .w_VectorS2_Coeff               (w_VectorS2_Coeff           ),
    .w_VectorS2_Coeff_valid         (w_VectorS2_Coeff_valid     ),
    .w_VectorS2_Coeff_addr          (w_VectorS2_Coeff_addr      ),
    .r_VectorS2_Coeff               (r_VectorS2_Coeff           ),
    .r_VectorS2_Coeff_addr          (r_VectorS2_Coeff_addr      ),

    // --- Vector Y ---
    .w_VectorY_Coeff                (w_VectorY_Coeff            ),
    .w_VectorY_Coeff_valid          (w_VectorY_Coeff_valid      ),
    .w_VectorY_Coeff_addr           (w_VectorY_Coeff_addr       ),
    .r_VectorY_Coeff                (r_VectorY_Coeff            ),
    .r_VectorY_Coeff_addr           (r_VectorY_Coeff_addr       ),

    // --- Vector T ---
    .w_VectorT_Coeff                (w_VectorT_Coeff            ),
    .w_VectorT_Coeff_valid          (w_VectorT_Coeff_valid      ),
    .w_VectorT_Coeff_addr           (w_VectorT_Coeff_addr       ),
    .r_VectorT_Coeff                (r_VectorT_Coeff            ),
    .r_VectorT_Coeff_addr           (r_VectorT_Coeff_addr       )
);

endmodule
