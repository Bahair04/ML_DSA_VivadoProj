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

    // --- ExpandA 信号 ---
    input       logic           [255 : 0]   rho_ExpandA_keygen,            
    input       logic                       start_expand_ExpandA_keygen,   
    output      logic           [91 : 0]    coeff_ExpandA_keygen,          
    output      logic                       coeff_valid_ExpandA_keygen,    
    output      logic                       expand_done_ExpandA_keygen,    

    output      logic           [7 : 0]     dout_ExpandA_keygen,          
    output      logic                       dout_valid_ExpandA_keygen,    
    output      logic           [31 : 0]    dout_len_ExpandA_keygen,      
    output      logic           [7 : 0]     mdlen_ExpandA_keygen,         
    output      logic                       init_ExpandA_keygen,          
    output      logic                       start_ExpandA_keygen,         
    input       logic                       done_ExpandA_keygen,          
    output      logic                       start_out_ExpandA_keygen,     
    output      logic           [31 : 0]    out_len_ExpandA_keygen,       
    input       logic                       done_out_ExpandA_keygen,      
    input       logic           [63 : 0]    st_64bit_ExpandA_keygen,      
    input       logic                       st_64bit_valid_ExpandA_keygen,

    // --- Poly_PAU 信号 ---
    input       logic           [91 : 0]    ori_coeff_keygen,				
    input       logic                       ori_coeff_valid_keygen,		
    input       logic                       request_keygen,                
    input       logic           [91 : 0]    ext_operand_keygen,            
    output      logic                       ext_operand_request_keygen,    
    input       logic           [4 : 0]     mode_config_keygen,            
    output      logic                       ready_keygen,                  
    output      logic           [91 : 0]    con_coeff_keygen,				
    output      logic                       con_coeff_valid_keygen,	

    // --- MAC 阵列信号 ---
    input       logic                       mac_valid_in_keygen,
    input       logic           [91 : 0]    mac_data_in1_keygen [0 : K - 1],
    input       logic           [91 : 0]    mac_data_in2_keygen,
    input       logic           [91 : 0]    mac_data_in3_keygen [0 : K - 1],
    output      logic                       mac_valid_out_keygen,
    output      logic           [91 : 0]    mac_data_out_keygen [0 : K - 1],

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

);

// ==========================================
// 1. 状态流回传：一对多 (广播机制)
// 物理上没有延时，直接把 SHA3 吐出的结果广播给所有控制器
// ==========================================

// --- ExpandA 内部线声明 ---
logic           [255 : 0]   rho_ExpandA;            
logic                       start_expand_ExpandA;   
logic           [91 : 0]    coeff_ExpandA;          
logic                       coeff_valid_ExpandA;    
logic                       expand_done_ExpandA;    

logic           [7 : 0]     dout_ExpandA;           
logic                       dout_valid_ExpandA;     
logic           [31 : 0]    dout_len_ExpandA;       
logic           [7 : 0]     mdlen_ExpandA;          
logic                       init_ExpandA;           
logic                       start_ExpandA;          
logic                       done_ExpandA;           
logic                       start_out_ExpandA;      
logic           [31 : 0]    out_len_ExpandA;        
logic                       done_out_ExpandA;       
logic           [63 : 0]    st_64bit_ExpandA;       
logic                       st_64bit_valid_ExpandA; 

// --- Poly_PAU 内部线声明 ---
logic           [91 : 0]    pau_ori_coeff;
logic                       pau_ori_coeff_valid;
logic                       pau_request;
logic           [91 : 0]    pau_ext_operand;
logic           [4 : 0]     pau_mode_config;
logic                       pau_ext_operand_request;
logic                       pau_ready;
logic           [91 : 0]    pau_con_coeff;
logic                       pau_con_coeff_valid;

// --- MAC_Pool 内部线声明 ---
logic                       mac_valid_in;
logic           [91 : 0]    mac_data_in1 [0 : K - 1];
logic           [91 : 0]    mac_data_in2;
logic           [91 : 0]    mac_data_in3 [0 : K - 1];
logic                       mac_valid_out;
logic           [91 : 0]    mac_data_out [0 : K - 1];

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

// --- ExpandA 回传给 KeyGen ---
assign coeff_ExpandA_keygen          = coeff_ExpandA;
assign coeff_valid_ExpandA_keygen    = coeff_valid_ExpandA;
assign expand_done_ExpandA_keygen    = expand_done_ExpandA;
assign dout_ExpandA_keygen           = dout_ExpandA;
assign dout_valid_ExpandA_keygen     = dout_valid_ExpandA;
assign dout_len_ExpandA_keygen       = dout_len_ExpandA;
assign mdlen_ExpandA_keygen          = mdlen_ExpandA;
assign init_ExpandA_keygen           = init_ExpandA;
assign start_ExpandA_keygen          = start_ExpandA;
assign start_out_ExpandA_keygen      = start_out_ExpandA;
assign out_len_ExpandA_keygen        = out_len_ExpandA;

// --- Poly_PAU 回传给 KeyGen ---
assign ext_operand_request_keygen = pau_ext_operand_request;
assign ready_keygen               = pau_ready;
assign con_coeff_keygen           = pau_con_coeff;
assign con_coeff_valid_keygen     = pau_con_coeff_valid;

// --- MAC_Pool 回传给 KeyGen ---
assign mac_valid_out_keygen = mac_valid_out;
assign mac_data_out_keygen  = mac_data_out;

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
    // 所有的 valid、init、start 等使能信号必须默认为 0

    rho_ExpandA                 = 'd0;
    start_expand_ExpandA        = 1'b0;
    done_ExpandA                = 1'b0;
    done_out_ExpandA            = 1'b0;
    st_64bit_ExpandA            = 'd0;
    st_64bit_valid_ExpandA      = 1'b0;

    pau_ori_coeff       = 'd0;
    pau_ori_coeff_valid = 1'b0;
    pau_request         = 1'b0;
    pau_ext_operand     = 'd0;
    pau_mode_config     = 'd0;

    mac_valid_in = 1'b0;
    mac_data_in2 = 'd0;
    for (int i=0; i<K; i++) begin
        mac_data_in1[i] = 'd0;
        mac_data_in3[i] = 'd0;
    end

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

    // 根据 mode_config，让对应的控制器接管 SHA3 阵列
    case (mode_config)
        2'd0: begin             // --- KeyGen 获取控制权 ---
            rho_ExpandA                 = rho_ExpandA_keygen;
            start_expand_ExpandA        = start_expand_ExpandA_keygen;
            done_ExpandA                = done_ExpandA_keygen;
            done_out_ExpandA            = done_out_ExpandA_keygen;
            st_64bit_ExpandA            = st_64bit_ExpandA_keygen;
            st_64bit_valid_ExpandA      = st_64bit_valid_ExpandA_keygen;

            pau_ori_coeff       = ori_coeff_keygen;
            pau_ori_coeff_valid = ori_coeff_valid_keygen;
            pau_request         = request_keygen;
            pau_ext_operand     = ext_operand_keygen;
            pau_mode_config     = mode_config_keygen;

            mac_valid_in = mac_valid_in_keygen;
            mac_data_in2 = mac_data_in2_keygen;
            for (int i=0; i<K; i++) begin
                mac_data_in1[i] = mac_data_in1_keygen[i];
                mac_data_in3[i] = mac_data_in3_keygen[i];
            end

            dout1                       = dout1_keygen;
            dout_valid1                 = dout_valid1_keygen;
            dout_len1                   = dout_len1_keygen;
            mdlen1                      = mdlen1_keygen;
            init1                       = init1_keygen;
            start1                      = start1_keygen;
            start_out1                  = start_out1_keygen;
            out_len1                    = out_len1_keygen;

            dout2                       = dout2_keygen;
            dout_valid2                 = dout_valid2_keygen;
            dout_len2                   = dout_len2_keygen;
            mdlen2                      = mdlen2_keygen;
            init2                       = init2_keygen;
            start2                      = start2_keygen;
            start_out2                  = start_out2_keygen;
            out_len2                    = out_len2_keygen;
        end
        
        default: ; // 默认所有控制信号为0，保持 SHA3 空闲
    endcase
end


// ==========================================
// 3. 例化算力池 (保持原样)
// ==========================================

ExpandA u_ExpandA(
    .clk                ( clk                     ),
    .rstn               ( rstn                    ),
    .rho                ( rho_ExpandA             ),
    .start_expand       ( start_expand_ExpandA    ),
    .coeff              ( coeff_ExpandA           ),
    .coeff_valid        ( coeff_valid_ExpandA     ),
    .expand_done        ( expand_done_ExpandA     ),

    .dout               ( dout_ExpandA            ),
    .dout_valid         ( dout_valid_ExpandA      ),
    .dout_len           ( dout_len_ExpandA        ),
    .mdlen              ( mdlen_ExpandA           ),
    .init               ( init_ExpandA            ),
    .start              ( start_ExpandA           ),
    .done               ( done_ExpandA            ),
    .start_out          ( start_out_ExpandA       ),
    .out_len            ( out_len_ExpandA         ),
    .done_out           ( done_out_ExpandA        ),
    .st_64bit           ( st_64bit_ExpandA        ),
    .st_64bit_valid     ( st_64bit_valid_ExpandA  )
);

assign ext_operand              = 'd0;
Poly_PAU u_Poly_PAU(
    .clk                    ( clk                     ),
    .rstn                   ( rstn                    ),
    .ori_coeff              ( pau_ori_coeff           ),
    .ori_coeff_valid        ( pau_ori_coeff_valid     ),
    .request                ( pau_request             ),
    .ext_operand            ( pau_ext_operand         ),
    .ext_operand_request    ( pau_ext_operand_request ),
    .mode_config            ( pau_mode_config         ),
    .ready                  ( pau_ready               ),
    .con_coeff              ( pau_con_coeff           ),
    .con_coeff_valid        ( pau_con_coeff_valid     )
);

MAC_Array_Pool #(
    .K ( K )
) u_MAC_Array_Pool(
    .clk        ( clk          ),
    .rstn       ( rstn         ),
    .valid_in   ( mac_valid_in ),
    .data_in1   ( mac_data_in1 ),
    .data_in2   ( mac_data_in2 ),
    .data_in3   ( mac_data_in3 ),
    .valid_out  ( mac_valid_out),
    .data_out   ( mac_data_out )
);

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