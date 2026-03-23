`include "../src/param_conf.v"
module GlobalComputeArbitration
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
    // --- SHA3-1 控制接口 ---
    input       logic           [7 : 0]     dout1_keygen, 
    input       logic                       dout_valid1_keygen, 
    input       logic           [31 : 0]    dout_len1_keygen, 
    input       logic           [7 : 0]     mdlen1_keygen, 
    input       logic                       init1_keygen, 
    input       logic                       start1_keygen, 
    output      logic                       done1_keygen, 
    input       logic                       start_out1_keygen, 
    input       logic           [31 : 0]    out_len1_keygen, 
    output      logic                       done_out1_keygen, 
    output      logic           [63 : 0]    st_64bit1_keygen, 
    output      logic                       st_64bit_valid1_keygen,

    // --- SHA3-2 控制接口 ---
    input       logic           [7 : 0]     dout2_keygen, 
    input       logic                       dout_valid2_keygen, 
    input       logic           [31 : 0]    dout_len2_keygen, 
    input       logic           [7 : 0]     mdlen2_keygen, 
    input       logic                       init2_keygen, 
    input       logic                       start2_keygen, 
    output      logic                       done2_keygen, 
    input       logic                       start_out2_keygen, 
    input       logic           [31 : 0]    out_len2_keygen, 
    output      logic                       done_out2_keygen, 
    output      logic           [63 : 0]    st_64bit2_keygen, 
    output      logic                       st_64bit_valid2_keygen

    // 未来在这里增加 Sign 和 Verify 的输入输出引脚...
);


// ==========================================
// 1. 状态流回传：一对多 (广播机制)
// 物理上没有延时，直接把 SHA3 吐出的结果广播给所有控制器
// ==========================================

// SHA3-1 回传给 KeyGen
assign done1_keygen           = done1;
assign done_out1_keygen       = done_out1;
assign st_64bit1_keygen       = st_64bit1;
assign st_64bit_valid1_keygen = st_64bit_valid1;

// SHA3-2 回传给 KeyGen
assign done2_keygen           = done2;
assign done_out2_keygen       = done_out2;
assign st_64bit2_keygen       = st_64bit2;
assign st_64bit_valid2_keygen = st_64bit_valid2;

// 以后加了 Sign:
// assign done1_sign = done1;
// ...


// ==========================================
// 2. 指令与数据下发：多合一 (MUX仲裁)
// ==========================================
always_comb begin
    // 🌟 第一步：全局打底，防止产生 Latch！
    // 核心规则：所有的 valid、init、start 等使能信号必须默认为 0
    dout1       = 'd0;
    dout_valid1 = 1'b0;
    dout_len1   = 'd0;
    mdlen1      = 'd0;
    init1       = 1'b0;
    start1      = 1'b0;
    start_out1  = 1'b0;
    out_len1    = 'd0;

    dout2       = 'd0;
    dout_valid2 = 1'b0;
    dout_len2   = 'd0;
    mdlen2      = 'd0;
    init2       = 1'b0;
    start2      = 1'b0;
    start_out2  = 1'b0;
    out_len2    = 'd0;

    // 🌟 第二步：根据 mode_config，让对应的控制器接管 SHA3 阵列
    case (mode_config)
        2'd0: begin             // --- KeyGen 获取控制权 ---
            dout1       = dout1_keygen;
            dout_valid1 = dout_valid1_keygen;
            dout_len1   = dout_len1_keygen;
            mdlen1      = mdlen1_keygen;
            init1       = init1_keygen;
            start1      = start1_keygen;
            start_out1  = start_out1_keygen;
            out_len1    = out_len1_keygen;

            dout2       = dout2_keygen;
            dout_valid2 = dout_valid2_keygen;
            dout_len2   = dout_len2_keygen;
            mdlen2      = mdlen2_keygen;
            init2       = init2_keygen;
            start2      = start2_keygen;
            start_out2  = start_out2_keygen;
            out_len2    = out_len2_keygen;
        end
        
        // 2'd1: begin          // --- Sign 获取控制权 ---
        //     dout1       = dout1_sign;
        //     ...
        // end
        
        default: ; // 默认所有控制信号为0，保持 SHA3 空闲
    endcase
end


// ==========================================
// 3. 例化算力池 (保持原样)
// ==========================================

// --- SHA3-1 内部线声明 ---
logic           [7 : 0]     dout1; 
logic                       dout_valid1;
logic           [31 : 0]    dout_len1; 
logic           [7 : 0]     mdlen1; 
logic                       init1; 
logic                       start1; 
logic                       done1; 
logic                       start_out1; 
logic           [31 : 0]    out_len1; 
logic                       done_out1; 
logic           [63 : 0]    st_64bit1; 
logic                       st_64bit_valid1;

// --- SHA3-2 内部线声明 ---
logic           [7 : 0]     dout2; 
logic                       dout_valid2; 
logic           [31 : 0]    dout_len2; 
logic           [7 : 0]     mdlen2; 
logic                       init2; 
logic                       start2; 
logic                       done2; 
logic                       start_out2; 
logic           [31 : 0]    out_len2; 
logic                       done_out2; 
logic           [63 : 0]    st_64bit2; 
logic                       st_64bit_valid2;

sha3 u_sha3_1(
    .clk                ( clk             ),
    .rstn               ( rstn            ),
    .din                ( dout1           ),
    .din_valid          ( dout_valid1     ),
    .din_len            ( dout_len1       ),
    .mdlen              ( mdlen1          ),
    .init               ( init1           ),
    .start              ( start1          ),
    .done               ( done1           ),
    .start_out          ( start_out1      ),
    .out_len            ( out_len1        ),
    .done_out           ( done_out1       ),
    .st_64bit           ( st_64bit1       ),
    .st_64bit_valid     ( st_64bit_valid1 )
);

sha3 u_sha3_2(
    .clk                ( clk             ),
    .rstn               ( rstn            ),
    .din                ( dout2           ),
    .din_valid          ( dout_valid2     ),
    .din_len            ( dout_len2       ),
    .mdlen              ( mdlen2          ),
    .init               ( init2           ),
    .start              ( start2          ),
    .done               ( done2           ),
    .start_out          ( start_out2      ),
    .out_len            ( out_len2        ),
    .done_out           ( done_out2       ),
    .st_64bit           ( st_64bit2       ),
    .st_64bit_valid     ( st_64bit_valid2 )
);

endmodule