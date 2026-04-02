`include "../../param_conf.v"
module postMultCalc
#(
    parameter           K = `k,
    parameter           L = `l,
    parameter T1_BIT_LEN = $clog2(`q - 1) - `d,                     // default : 10
    parameter S1_S2_BIT_LEN = $clog2(2 * `eta) + 1,                 // default : 3
    parameter T0_BIT_LEN = `d,                                      // default : 13
    parameter Z_BIT_LEN = `bit_count,                               // default : 18
    parameter H_BIT_LEN = 'd1         
)(
    // --- 时钟和复位信号 ---
    input       logic                       clk,
    input       logic                       rstn,

    input       logic                       init,
    input       logic   [91 : 0]            y,
    input       logic   [91 : 0]            w,
    input       logic   [91 : 0]            c_coeff,     // 统一的乘积系数输入
    input       logic                       coeff_valid, // 统一的有效脉冲
    input       logic   [1 : 0]             mac_stage,

    output      logic   [91 : 0]            w_minus_c_s2,
    output      logic                       w_minus_c_s2_valid,
    output      logic   [63 : 0]            encode,
    output      logic                       encoder_valid,
    output      logic   [3 : 0]             hint,
    output      logic                       hint_valid,
    output      logic                       reject_flag,
    output      logic                       make_hint_done
);

localparam                              z_check_bound = `gamma_1 - `beta;
localparam                              r0_check_bound = `gamma_2 - `beta;
localparam                              c_t0_check_bound = `gamma_2;

logic           [91 : 0]                data1;
logic           [91 : 0]                data2;
logic                                   data_in_valid;
logic           [91 : 0]                data_res;
logic                                   data_out_valid;

logic           [91 : 0]                z;
logic                                   z_valid;
logic           [18 : 0]                r0 [0 : 3];
logic                                   r0_valid [0 : 3];
logic           [7 : 0]                 hint_valid_cnt;

// ==========================================
// 1. 利用 mac_stage 在内部进行数据路由
// ==========================================
always_comb begin
    data1 = 'd0;
    data2 = c_coeff; 
    data_in_valid = 1'b0;

    case (mac_stage)
        2'd0: begin                     // 阶段0：处理 z = y + c_s1
            data1 = y;
            data_in_valid = coeff_valid;
        end
        2'd1 : begin                    // 阶段1：处理 w - c_s2
            data1 = w;
            data_in_valid = coeff_valid;
        end
        2'd2 : begin
            data1 = w;
            data_in_valid = coeff_valid;
        end
        default: begin
            data1 = 'd0;
            data2 = 'd0;
            data_in_valid = 1'b0;
        end
    endcase
end

generate
    for (genvar i = 0 ; i < 4 ; i = i + 1) begin : gen_mac
        wire    [22 : 0]    data_in1 = data1[23 * i +: 23];
        wire    [22 : 0]    data_in2 = data2[23 * i +: 23];
        wire                valid_out_add, valid_out_sub;
        wire    [22 : 0]    data_out_add, data_out_sub;
        
        ModuleAdd u_ModuleAdd(
            .clk        ( clk               ),
            .rstn       ( rstn              ),
            .valid_in   ( data_in_valid     ),
            .data_in1   ( data_in1          ),
            .data_in2   ( data_in2          ),
            .valid_out  ( valid_out_add     ),
            .data_out   ( data_out_add      )
        );

        ModuleSub u_ModuleSub(
            .clk        ( clk               ),
            .rstn       ( rstn              ),
            .valid_in   ( data_in_valid     ),
            .data_in1   ( data_in1          ),
            .data_in2   ( data_in2          ),
            .valid_out  ( valid_out_sub     ),
            .data_out   ( data_out_sub      )
        );

        assign data_res[23 * i +: 23] = ((mac_stage == 2'd0) || (mac_stage == 2'd2)) ? data_out_add :
                                        (mac_stage == 2'd1) ? data_out_sub : 23'd0;
        if (i == 0) begin : gen_valid
            assign data_out_valid = ((mac_stage == 2'd0) || (mac_stage == 2'd2)) ? valid_out_add :
                                    (mac_stage == 2'd1) ? valid_out_sub : 1'b0;
        end
    end
endgenerate

assign w_minus_c_s2 = data_res;
assign w_minus_c_s2_valid = data_out_valid && (mac_stage == 2'd1);

generate                                            // r = low_bits(w - c_s2)
    for (genvar i = 0 ; i < 4 ; i = i + 1) begin : gen_decomp
        wire     [24 : 0]            r = {2'b0, data_res[23 * i +: 23]};
        wire                         r_valid = data_out_valid && (mac_stage == 2'd1);
        if (`gamma_2 == 95232) begin
            Decomposes u_Decomposes(
                .clk        ( clk          ),
                .rstn       ( rstn         ),
                .r          ( r            ),
                .r_valid    ( r_valid      ),
                .r0         ( r0[i]        ),
                .r0_valid   ( r0_valid[i]  )
            );
        end
        else begin
            Decomposes2 u_Decomposes2(
                .clk        ( clk          ),
                .rstn       ( rstn         ),
                .r          ( r            ),
                .r_valid    ( r_valid      ),
                .r0         ( r0[i]        ),
                .r0_valid   ( r0_valid[i]  )
            );
        end
    end
endgenerate

always_ff @(posedge clk) begin
    if (!rstn) begin
        z <= 'd0;
        z_valid <= 1'b0;
    end
    else if (data_out_valid && mac_stage == 2'd0) begin      
        z <= data_res;
        z_valid <= 1'b1;
    end
    else begin
        z <= 'd0;
        z_valid <= 1'b0;
    end
end

logic           [63 : 0]            encode_temp;
Encoder u_Encoder(                                          
    .clk            ( clk            ),
    .rstn           ( rstn           ),
    .system_done    ( system_done    ), 
    .z              ( z              ),
    .z_valid        ( z_valid        ),
    .encode         ( encode_temp    ),
    .encoder_valid  ( encoder_valid  )
);
assign encode = {<<8{encode_temp}};

// ==========================================
// 拒绝判定模块 (Reject Logic)
// ==========================================
logic   [3 : 0]                 reject_z;
logic   [3 : 0]                 reject_r0;
logic   [3 : 0]                 reject_ct0;
logic   [22 : 0]                z_i; 
logic   [22 : 0]                ct0_i;
logic   [18 : 0]                r0_i;
logic   [7 : 0]                 hint_cnt;

always_comb begin
    reject_z   = 4'b0;
    reject_r0  = 4'b0;
    reject_ct0 = 4'b0;

    for (int i = 0; i < 4; i = i + 1) begin
        // 1. 检查 z 
        z_i = z[23 * i +: 23]; 
        if ( z_i >= z_check_bound && z_i <= (`q - z_check_bound) ) begin
            reject_z[i] = 1'b1; 
        end
        
        // 2. 检查 r0
        r0_i = r0[i];
        if ( $signed(r0_i) >= $signed(r0_check_bound) || 
             $signed(r0_i) <= -$signed(r0_check_bound) ) begin
            reject_r0[i] = 1'b1;
        end
        
        // 3. 检查 c_t0 (此时 c_coeff 就是 c_t0)
        // 只有当 mac_stage == 2，进来的 c_coeff 才是 c_t0
        ct0_i = c_coeff[23 * i +: 23];
        if ( ct0_i >= c_t0_check_bound && ct0_i <= (`q - c_t0_check_bound) ) begin
            reject_ct0[i] = 1'b1;
        end
    end
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        reject_flag <= 1'b0;
    end
    else begin
        // 判断条件加上了对应的 valid 触发与阶段指示
        if (z_valid && (|reject_z))
            reject_flag <= 1'b1;
        else if (r0_valid[0] && (|reject_r0))
            reject_flag <= 1'b1;
        else if (coeff_valid && (mac_stage == 2'd2) && (|reject_ct0))
            reject_flag <= 1'b1; // 仅在 stage 2 时检查 c_t0
        else if (hint_valid && (hint_cnt > `omega))
            reject_flag <= 1'b1; // 最终的 hint 计数检查
        else
            reject_flag <= 1'b0; 
    end
end

generate 
    for (genvar i = 0 ; i < 4 ; i = i + 1) begin : make_hint_block
        wire    [24 : 0]            r_d = {2'd0, w[23 * i +: 23]};
        wire    [24 : 0]            r_plus_z = {2'd0, data_res[23 * i +: 23]};
        wire                        i_valid = data_out_valid && (mac_stage == 'd2);
        wire                        o_hint;
        wire                        o_valid;
        make_hint u_make_hint(
            .clk      	( clk       ),
            .rstn     	( rstn      ),
            .r_d      	( r_d       ),
            .r_plus_z 	( r_plus_z  ),
            .i_valid  	( i_valid   ),
            .hint     	( o_hint    ),
            .o_valid  	( o_valid   )
        );
        assign hint[i] = o_hint;
        if (i == 0)
            assign hint_valid = o_valid;
    end
endgenerate

always_ff @(posedge clk) begin
    if (!rstn)
        hint_cnt <= 'd0;
    else if (init) 
        hint_cnt <= 'd0;
    else if (hint_valid) 
        hint_cnt <= hint_cnt + hint[0] + hint[1] + hint[2] + hint[3];
end

always_ff @(posedge clk) begin
    if (!rstn) 
        hint_valid_cnt <= 'd0;
    else if (init)
        hint_valid_cnt <= 'd0;
    else if (hint_valid) begin
        if (hint_valid_cnt == 'd255)
            hint_valid_cnt <= 'd0;
        else
            hint_valid_cnt <= hint_valid_cnt + 'd1;
    end
    else 
        hint_valid_cnt <= hint_valid_cnt;
end

always_ff @(posedge clk) begin
    if (!rstn)
        make_hint_done <= 1'b0;
    else if (hint_valid && hint_valid_cnt == 'd255)
        make_hint_done <= 1'b1;
    else 
        make_hint_done <= 1'b0;
end

endmodule