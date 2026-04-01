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

    input       logic   [91 : 0]            y,
    input       logic                       y_valid,
    input       logic   [91 : 0]            w,
    input       logic                       w_valid,
    input       logic   [91 : 0]            c_s1,
    input       logic                       c_s1_valid,
    input       logic   [91 : 0]            c_s2,
    input       logic                       c_s2_valid,
    input       logic   [91 : 0]            c_t0,
    input       logic                       c_t0_valid,
    input       logic   [1 : 0]             mac_stage,

    
    output      logic   [63:0]             	encode,
    output      logic                   	encoder_valid,
    output      logic                       reject_flag
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
logic           [3 : 0]                 reject_flag_i;
logic           [18 : 0]                r0 [0 : 3];
logic                                   r0_valid [0 : 3];

always_comb begin
    data1 = 'd0;
    data2 = 'd0;
    data_in_valid = 1'b0;
    case (mac_stage)
        'd0: begin                      // z = y + c_s1
            data1 = y;
            data2 = c_s1;
            data_in_valid = y_valid;
        end
        'd1 : begin                     // r0 = low_bits(w - c_s2)
            data1 = w;
            data2 = c_s2;
            data_in_valid = w_valid;
        end
        default: begin
            data1 = 'd0;
            data2 = 'd0;
            data_in_valid = 1'b0;
        end
    endcase
end

generate
    for (genvar i = 0 ; i < 4 ; i = i + 1) begin
        wire    [22 : 0]    data_in1 = data1[23 * i +: 23];
        wire    [22 : 0]    data_in2 = data2[23 * i +: 23];
        wire                valid_out_add, valid_out_sub;
        wire    [22 : 0]    data_out_add, data_out_sub;
        
        ModuleAdd u_ModuleAdd(                      // y + c_s1
            .clk       	( clk               ),
            .rstn      	( rstn              ),
            .valid_in  	( data_in_valid     ),
            .data_in1  	( data_in1          ),
            .data_in2  	( data_in2          ),
            .valid_out 	( valid_out_add     ),
            .data_out  	( data_out_add      )
        );

        ModuleSub u_ModuleSub(                      // w - c_s2
            .clk       	( clk               ),
            .rstn      	( rstn              ),
            .valid_in  	( data_in_valid     ),
            .data_in1  	( data_in1          ),
            .data_in2  	( data_in2          ),
            .valid_out 	( valid_out_sub     ),
            .data_out  	( data_out_sub      )
        );

        assign data_res[23 * i +: 23] = (mac_stage == 'd0) ? data_out_add :
                                        (mac_stage == 'd1) ? data_out_sub : 'd0;
        if (i == 0) begin : gen_valid
            assign data_out_valid = (mac_stage == 2'd0) ? valid_out_add :
                                    (mac_stage == 2'd1) ? valid_out_sub : 1'b0;
        end
    end
endgenerate

generate                                            // r = low_bits(w - c_s2)
    for (genvar i = 0 ; i < 4 ; i = i + 1) begin
        wire     [24 : 0]            r = {2'b0, data_res[23 * i +: 23]};
        wire                         r_valid = data_out_valid && (mac_stage == 'd1);
        if (`gamma_2 == 95232) begin
            Decomposes u_Decomposes(
                .clk      	( clk          ),
                .rstn     	( rstn         ),
                .r        	( r            ),
                .r_valid  	( r_valid      ),
                .r0       	( r0[i]        ),
                .r0_valid 	( r0_valid[i]  )
            );
        end
        else begin
            Decomposes2 u_Decomposes2(
                .clk      	( clk          ),
                .rstn     	( rstn         ),
                .r        	( r            ),
                .r_valid  	( r_valid      ),
                .r0       	( r0[i]        ),
                .r0_valid 	( r0_valid[i]  )
            );
        end
    end
endgenerate

always_ff @(posedge clk) begin
    if (!rstn) begin
        z <= 'd0;
        z_valid <= 1'b0;
    end
    else if (data_out_valid && mac_stage == 'd0) begin      // y + c_s1 阶段 加一级寄存器延迟 获得模q的z 送到Encoder中
        z <= data_res;
        z_valid <= 1'b1;
    end
    else begin
        z <= 'd0;
        z_valid <= 1'b0;
    end
end

Encoder u_Encoder(                                          // 获得pack(z) 用于顶层组成签名
	.clk           	( clk            ),
	.rstn          	( rstn           ),
	.system_done   	( system_done    ),
	.z             	( z              ),
	.z_valid       	( z_valid        ),
	.encode        	( encode         ),
	.encoder_valid 	( encoder_valid  )
);


logic   [3 : 0]                 reject_z;
logic   [3 : 0]                 reject_r0;
logic   [3 : 0]                 reject_ct0;
logic   [22 : 0]                z_i; 
logic   [22 : 0]                ct0_i;
logic   [18 : 0]                r0_i;
always_comb begin
    reject_z   = 4'b0;
    reject_r0  = 4'b0;
    reject_ct0 = 4'b0;

    for (int i = 0; i < 4; i = i + 1) begin
        // 1. 检查 z (23位无符号模 q 运算)
        z_i = z[23 * i +: 23]; 
        if ( z_i >= z_check_bound && z_i <= (`q - z_check_bound) ) begin
            reject_z[i] = 1'b1; // 掉入中间的非法区域
        end

        // 2. 检查 c_t0 (23位无符号模 q 运算)
        ct0_i = c_t0[23 * i +: 23];
        if ( ct0_i >= c_t0_check_bound && ct0_i <= (`q - c_t0_check_bound) ) begin
            reject_ct0[i] = 1'b1;
        end

        // 3. 检查 r0
        r0_i = r0[i];
        if ( $signed(r0_i) >= $signed(r0_check_bound) || 
             $signed(r0_i) <= -$signed(r0_check_bound) ) begin
            reject_r0[i] = 1'b1;
        end
    end
end

always_ff @(posedge clk) begin
    if (!rstn) begin
        reject_flag <= 1'b0;
    end
    else begin
        if (z_valid && (|reject_z))
            reject_flag <= 1'b1;
        else if (r0_valid[0] && (|reject_r0))
            reject_flag <= 1'b1;
        else if (c_t0_valid && (|reject_ct0))
            reject_flag <= 1'b1;
        else
            reject_flag <= 1'b0; 
    end
end
endmodule
