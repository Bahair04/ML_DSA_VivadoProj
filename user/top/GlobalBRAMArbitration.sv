`include "../src/param_conf.v"
module GlobalBRAMArbitration
#(
    parameter           K = `k,
    parameter           L = `l
)(
    // --- 时钟和复位信号 ---
	input       logic                       clk,
    input       logic                       rstn,
    input       logic           [1 : 0]     mode_config,

    // ==========================================
    // KeyGen 控制器接口
    // ==========================================
    // --- BRAM 总线信号 ---
    input       logic           [91 : 0]    w_MatrixA_Coeff_keygen,
    input       logic                       w_MatrixA_Coeff_valid_keygen,
    input       logic           [11 : 0]    w_MatrixA_Coeff_addr_keygen,
    output      logic           [91 : 0]    r_MatrixA_Coeff_keygen [0 : K - 1],
    input       logic           [8 : 0]     r_MatrixA_Coeff_addr_keygen [0 : K - 1],

    input       logic   signed  [91 : 0]    w_VectorS1_Coeff_keygen,                   // 4*4bit有符号数
    input       logic                       w_VectorS1_Coeff_valid_keygen,
    input       logic           [8 : 0]     w_VectorS1_Coeff_addr_keygen,
    output      logic           [91 : 0]    r_VectorS1_Coeff_keygen,                   // 对q取模 无符号
    input       logic           [8 : 0]     r_VectorS1_Coeff_addr_keygen,

    input       logic   signed  [91 : 0]    w_VectorS2_Coeff_keygen,                   // 4*4bit有符号数
    input       logic                       w_VectorS2_Coeff_valid_keygen,
    input       logic           [8 : 0]     w_VectorS2_Coeff_addr_keygen,
    output      logic           [91 : 0]    r_VectorS2_Coeff_keygen [0 : K - 1],       // 对q取模 无符号
    input       logic           [5 : 0]     r_VectorS2_Coeff_addr_keygen [0 : K - 1],

    input       logic           [91 : 0]    w_VectorT_Coeff_keygen [0 : K - 1],
    input       logic                       w_VectorT_Coeff_valid_keygen [0 : K - 1],
    input       logic           [5 : 0]     w_VectorT_Coeff_addr_keygen [0 : K - 1],
    output      logic           [91 : 0]    r_VectorT_Coeff_keygen [0 : K - 1],
    input       logic           [5 : 0]     r_VectorT_Coeff_addr_keygen [0 : K - 1],


    input       logic           [63 : 0]    w_EncodePK_Coeff_keygen,       
    input       logic                       w_EncodePK_Coeff_valid_keygen,
    input       logic           [8 : 0]     w_EncodePK_Coeff_addr_keygen,
    output      logic           [63 : 0]    r_EncodePK_Coeff_keygen,           
    input       logic           [8 : 0]     r_EncodePK_Coeff_addr_keygen,

    input       logic           [63 : 0]    w_EncodeSK_Coeff_keygen,       
    input       logic                       w_EncodeSK_Coeff_valid_keygen,
    input       logic           [9 : 0]     w_EncodeSK_Coeff_addr_keygen,
    output      logic           [63 : 0]    r_EncodeSK_Coeff_keygen,           
    input       logic           [9 : 0]     r_EncodeSK_Coeff_addr_keygen

);

// ==========================================
// 内部 BRAM 总线
// ==========================================
logic           [91 : 0]    w_MatrixA_Coeff;
logic                       w_MatrixA_Coeff_valid;
logic           [11 : 0]    w_MatrixA_Coeff_addr;
logic           [91 : 0]    r_MatrixA_Coeff [0 : K - 1];
logic           [8 : 0]     r_MatrixA_Coeff_addr [0 : K - 1];

logic   signed  [91 : 0]    w_VectorS1_Coeff;                   // 4*4bit有符号数
logic                       w_VectorS1_Coeff_valid;
logic           [8 : 0]     w_VectorS1_Coeff_addr;
logic           [91 : 0]    r_VectorS1_Coeff;                   // 对q取模 无符号
logic           [8 : 0]     r_VectorS1_Coeff_addr;
logic                       ori_s1_coeff_en;

logic   signed  [91 : 0]    w_VectorS2_Coeff;                   // 4*4bit有符号数
logic                       w_VectorS2_Coeff_valid;
logic           [8 : 0]     w_VectorS2_Coeff_addr;
logic           [91 : 0]    r_VectorS2_Coeff [0 : K - 1];       // 对q取模 无符号
logic           [5 : 0]     r_VectorS2_Coeff_addr [0 : K - 1];
logic                       ori_s2_coeff_en;

logic   signed  [79 : 0]    w_VectorY_Coeff;
logic                       w_VectorY_Coeff_valid;
logic           [5 : 0]     w_VectorY_Coeff_addr;
logic           [91 : 0]    r_VectorY_Coeff;
logic           [5 : 0]     r_VectorY_Coeff_addr;

logic           [91 : 0]    w_VectorT_Coeff [0 : K - 1];
logic                       w_VectorT_Coeff_valid [0 : K - 1];
logic           [5 : 0]     w_VectorT_Coeff_addr [0 : K - 1];
logic           [91 : 0]    r_VectorT_Coeff [0 : K - 1];
logic           [5 : 0]     r_VectorT_Coeff_addr [0 : K - 1];

logic           [63 : 0]    w_EncodePK_Coeff;       
logic                       w_EncodePK_Coeff_valid;
logic           [8 : 0]     w_EncodePK_Coeff_addr;
logic           [63 : 0]    r_EncodePK_Coeff;           
logic           [8 : 0]     r_EncodePK_Coeff_addr;

logic           [63 : 0]    w_EncodeSK_Coeff;       
logic                       w_EncodeSK_Coeff_valid;
logic           [9 : 0]     w_EncodeSK_Coeff_addr;
logic           [63 : 0]    r_EncodeSK_Coeff;           
logic           [9 : 0]     r_EncodeSK_Coeff_addr;

assign r_MatrixA_Coeff_keygen = r_MatrixA_Coeff;
assign r_VectorS1_Coeff_keygen = r_VectorS1_Coeff;
assign r_VectorS2_Coeff_keygen = r_VectorS2_Coeff;
assign r_VectorT_Coeff_keygen = r_VectorT_Coeff;
assign r_EncodePK_Coeff_keygen = r_EncodePK_Coeff;
assign r_EncodeSK_Coeff_keygen = r_EncodeSK_Coeff;

always_comb begin

    w_MatrixA_Coeff_valid  = 1'b0;
    w_VectorS1_Coeff_valid = 1'b0;
    w_VectorS2_Coeff_valid = 1'b0;
    w_VectorY_Coeff_valid  = 1'b0;
    w_EncodePK_Coeff_valid = 1'b0;
    w_EncodeSK_Coeff_valid = 1'b0;

    for (int i=0; i<K; i++) w_VectorT_Coeff_valid[i] = 1'b0;

    w_MatrixA_Coeff       = 'd0;
    w_MatrixA_Coeff_addr  = 'd0;
    w_VectorS1_Coeff      = 'd0;
    w_VectorS1_Coeff_addr = 'd0;
    w_VectorS2_Coeff      = 'd0;
    w_VectorS2_Coeff_addr = 'd0;
    w_VectorY_Coeff       = 'd0;
    w_VectorY_Coeff_addr  = 'd0;
    r_VectorS1_Coeff_addr = 'd0;
    r_VectorY_Coeff_addr  = 'd0;
    w_EncodePK_Coeff      = 'd0;
    w_EncodePK_Coeff_addr = 'd0;
    r_EncodePK_Coeff_addr = 'd0;
    w_EncodeSK_Coeff      = 'd0;
    w_EncodeSK_Coeff_addr = 'd0;
    r_EncodeSK_Coeff_addr = 'd0;

    for (int i = 0; i < K; i++) begin
        r_MatrixA_Coeff_addr[i]  = 'd0;
        r_VectorS2_Coeff_addr[i] = 'd0;
        r_VectorT_Coeff_addr[i]  = 'd0;
        w_VectorT_Coeff[i]       = 'd0;
        w_VectorT_Coeff_addr[i]  = 'd0;
    end

    ori_s1_coeff_en = 1'b0;
    ori_s2_coeff_en = 1'b0;

    case (mode_config)
        'd0: begin              // keygen
            w_MatrixA_Coeff         = w_MatrixA_Coeff_keygen;
            w_MatrixA_Coeff_valid   = w_MatrixA_Coeff_valid_keygen;
            w_MatrixA_Coeff_addr    = w_MatrixA_Coeff_addr_keygen;
            r_MatrixA_Coeff_addr    = r_MatrixA_Coeff_addr_keygen;

            w_VectorS1_Coeff        = w_VectorS1_Coeff_keygen;
            w_VectorS1_Coeff_valid  = w_VectorS1_Coeff_valid_keygen;
            w_VectorS1_Coeff_addr   = w_VectorS1_Coeff_addr_keygen;
            r_VectorS1_Coeff_addr   = r_VectorS1_Coeff_addr_keygen;
            ori_s1_coeff_en         = 1'b0;

            w_VectorS2_Coeff        = w_VectorS2_Coeff_keygen;
            w_VectorS2_Coeff_valid  = w_VectorS2_Coeff_valid_keygen;
            w_VectorS2_Coeff_addr   = w_VectorS2_Coeff_addr_keygen;
            r_VectorS2_Coeff_addr   = r_VectorS2_Coeff_addr_keygen;
            ori_s2_coeff_en         = 1'b0;

            w_VectorT_Coeff         = w_VectorT_Coeff_keygen;
            w_VectorT_Coeff_valid   = w_VectorT_Coeff_valid_keygen;
            w_VectorT_Coeff_addr    = w_VectorT_Coeff_addr_keygen;
            r_VectorT_Coeff_addr    = r_VectorT_Coeff_addr_keygen;
            
            w_EncodePK_Coeff        = w_EncodePK_Coeff_keygen;
            w_EncodePK_Coeff_valid  = w_EncodePK_Coeff_valid_keygen;
            w_EncodePK_Coeff_addr   = w_EncodePK_Coeff_addr_keygen;
            r_EncodePK_Coeff_addr   = r_EncodePK_Coeff_addr_keygen;

            w_EncodeSK_Coeff        = w_EncodeSK_Coeff_keygen;
            w_EncodeSK_Coeff_valid  = w_EncodeSK_Coeff_valid_keygen;
            w_EncodeSK_Coeff_addr   = w_EncodeSK_Coeff_addr_keygen;
            r_EncodeSK_Coeff_addr   = r_EncodeSK_Coeff_addr_keygen;
        end
    endcase
end

SharedBRAMPool #(
    .K 	(K  ),
    .L 	(L  ))
u_SharedBRAMPool(
    .clk                    	(clk                     ),
    .rstn                   	(rstn                    ),

    .w_MatrixA_Coeff        	(w_MatrixA_Coeff         ),
    .w_MatrixA_Coeff_valid  	(w_MatrixA_Coeff_valid   ),
    .w_MatrixA_Coeff_addr   	(w_MatrixA_Coeff_addr    ),
    .r_MatrixA_Coeff        	(r_MatrixA_Coeff         ),
    .r_MatrixA_Coeff_addr   	(r_MatrixA_Coeff_addr    ),
    
    .w_VectorS1_Coeff       	(w_VectorS1_Coeff        ),
    .w_VectorS1_Coeff_valid 	(w_VectorS1_Coeff_valid  ),
    .w_VectorS1_Coeff_addr  	(w_VectorS1_Coeff_addr   ),
    .r_VectorS1_Coeff       	(r_VectorS1_Coeff        ),
    .r_VectorS1_Coeff_addr  	(r_VectorS1_Coeff_addr   ),
    .ori_s1_coeff_en            (ori_s1_coeff_en         ),

    .w_VectorS2_Coeff       	(w_VectorS2_Coeff        ),
    .w_VectorS2_Coeff_valid 	(w_VectorS2_Coeff_valid  ),
    .w_VectorS2_Coeff_addr  	(w_VectorS2_Coeff_addr   ),
    .r_VectorS2_Coeff       	(r_VectorS2_Coeff        ),
    .r_VectorS2_Coeff_addr  	(r_VectorS2_Coeff_addr   ),
    .ori_s2_coeff_en            (ori_s2_coeff_en         ),

    .w_VectorY_Coeff        	(w_VectorY_Coeff         ),
    .w_VectorY_Coeff_valid  	(w_VectorY_Coeff_valid   ),
    .w_VectorY_Coeff_addr   	(w_VectorY_Coeff_addr    ),
    .r_VectorY_Coeff        	(r_VectorY_Coeff         ),
    .r_VectorY_Coeff_addr   	(r_VectorY_Coeff_addr    ),
    
    .w_VectorT_Coeff        	(w_VectorT_Coeff         ),
    .w_VectorT_Coeff_valid  	(w_VectorT_Coeff_valid   ),
    .w_VectorT_Coeff_addr   	(w_VectorT_Coeff_addr    ),
    .r_VectorT_Coeff        	(r_VectorT_Coeff         ),
    .r_VectorT_Coeff_addr   	(r_VectorT_Coeff_addr    ),

	.w_EncodePK_Coeff       	( w_EncodePK_Coeff       ),
	.w_EncodePK_Coeff_valid 	( w_EncodePK_Coeff_valid ),
	.w_EncodePK_Coeff_addr  	( w_EncodePK_Coeff_addr  ),
	.r_EncodePK_Coeff       	( r_EncodePK_Coeff       ),
	.r_EncodePK_Coeff_addr  	( r_EncodePK_Coeff_addr  ),

    .w_EncodeSK_Coeff       	( w_EncodeSK_Coeff       ),
	.w_EncodeSK_Coeff_valid 	( w_EncodeSK_Coeff_valid ),
	.w_EncodeSK_Coeff_addr  	( w_EncodeSK_Coeff_addr  ),
	.r_EncodeSK_Coeff       	( r_EncodeSK_Coeff       ),
	.r_EncodeSK_Coeff_addr  	( r_EncodeSK_Coeff_addr  )
);


endmodule
