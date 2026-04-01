`include "../param_conf.v"
module Encoder
#(
    parameter T1_BIT_LEN = $clog2(`q - 1) - `d,                     // default : 10
    parameter S1_S2_BIT_LEN = $clog2(2 * `eta) + 1,                 // default : 3
    parameter T0_BIT_LEN = `d,                                      // default : 13
    parameter Z_BIT_LEN = `bit_count,                               // default : 18
    parameter H_BIT_LEN = 'd1                             
)(
    // --- 时钟与复位信号 ---
    input       logic                                   clk,
    input       logic                                   rstn,

    input       logic                                   system_done,

    // --- 公钥(pk) 编码信号 ---
    input       logic   [4 * T1_BIT_LEN - 1 : 0]        t1,         // t 的高位
    input       logic                                   t1_valid,

    // --- 私钥(sk) 编码信号 ---
    input       logic   [4 * 23 - 1 : 0]                s1,         // ExpandS 中使用`q进行归约 因此位宽为23 实际位宽远少于23
    input       logic                                   s1_valid,
    input       logic   [4 * 23 - 1 : 0]                s2,         // ExpandS 中使用`q进行归约 因此位宽为23 实际位宽远少于23
    input       logic                                   s2_valid,
    input       logic   [4 * T0_BIT_LEN - 1 : 0]        t0,         // t 的低位
    input       logic                                   t0_valid,

    // --- 签名(sig) 编码信号 ---
    input       logic   [4 * 23 - 1 : 0]                z,
    input       logic                                   z_valid,
    
    // --- 编码输出接口 输出位宽 8 个字节 ---
    output      logic   [63 : 0]                        encode,
    output      logic                                   encoder_valid
);

logic   [T1_BIT_LEN - 1 : 0] 	                        pk_encode [0 : 3];              // 总长度 40 bit
logic                  	                                pk_encode_valid [0 : 3];
logic   [T0_BIT_LEN - 1 : 0] 	                        sk_encode [0 : 3];              // 总长度 12/16/52 bit
logic                  	                                sk_encode_valid [0 : 3];
logic   [4 : 0]                                         sk_encode_len [0 : 3];
logic   [Z_BIT_LEN - 1 : 0]  	                        sig_encode [0 : 3];             // 总长度 72 bit
logic                  	                                sig_encode_valid [0 : 3];

genvar i;
generate
    for (i = 0 ; i < 4 ; i++) begin : initiate_four_channels
        Encoder_single_channel u_Encoder_single_channel(
            .clk              	( clk                                           ),
            .rstn             	( rstn                                          ),
            
            .t1               	( t1[i * T1_BIT_LEN +: T1_BIT_LEN]              ),
            .t1_valid         	( t1_valid                                      ),
            .pk_encode        	( pk_encode[i]                                  ),
            .pk_encode_valid  	( pk_encode_valid[i]                            ),
            
            .s1               	( s1[i * 23 +: 23]                              ),
            .s1_valid         	( s1_valid                                      ),
            .s2               	( s2[i * 23 +: 23]                              ),
            .s2_valid         	( s2_valid                                      ),
            .t0               	( t0[i * T0_BIT_LEN +: T0_BIT_LEN]              ),
            .t0_valid         	( t0_valid                                      ),
            .sk_encode        	( sk_encode[i]                                  ),
            .sk_encode_valid  	( sk_encode_valid[i]                            ),
            .sk_encode_len      ( sk_encode_len[i]                              ),
            .z                	( z[i * 23 +: 23]                               ),
            .z_valid          	( z_valid                                       ),
            .sig_encode       	( sig_encode[i]                                 ),
            .sig_encode_valid 	( sig_encode_valid[i]                           )
        );
    end
endgenerate

// ==========================================================
// 变长比特拼接与 64-bit 总线打包器 (Bit Packer)
// ==========================================================

// 1. 预处理：合并 4 个通道的数据为一个宽位总线
logic [127 : 0] merged_data;     // 足够容纳一次产生的最大数据量 (4 * 18 = 72 < 128)
logic [6  : 0]  merged_len;      // 本次合并的数据总位宽 (0 ~ 127)
logic           merged_valid;

always_comb begin
    merged_data  = 'd0;
    merged_len   = 'd0;
    merged_valid = 1'b0;

    // 优先级 1：公钥 t1 (固定 10 bit * 4 = 40 bit)
    if (pk_encode_valid[0]) begin
        merged_data  = {pk_encode[3], pk_encode[2], pk_encode[1], pk_encode[0]};
        merged_len   = 7'd40;
        merged_valid = 1'b1;
    end
    // 优先级 2：签名 z (固定 Z_BIT_LEN * 4)
    else if (sig_encode_valid[0]) begin
        merged_data  = {sig_encode[3], sig_encode[2], sig_encode[1], sig_encode[0]};
        merged_len   = {2'b00, Z_BIT_LEN[4:0]} << 2; // Z_BIT_LEN * 4
        merged_valid = 1'b1;
    end
    // 优先级 3：私钥 sk (变长 3/4/13 bit * 4)
    else if (sk_encode_valid[0]) begin
        // 因为不同情况 sk_encode 占据的是有效低位，我们需要用移位来动态拼接
        logic [127:0] d0 = sk_encode[0];
        logic [127:0] d1 = sk_encode[1];
        logic [127:0] d2 = sk_encode[2];
        logic [127:0] d3 = sk_encode[3];
        
        // 依次左移，叠罗汉式拼接
        merged_data  = d0 | 
                       (d1 << (sk_encode_len[0])) | 
                       (d2 << (sk_encode_len[0] * 2)) | 
                       (d3 << (sk_encode_len[0] * 3));
                       
        merged_len   = {2'b00, sk_encode_len[0]} << 2; // sk_encode_len * 4
        merged_valid = 1'b1;
    end
end

// 2. 蓄水池缓冲池逻辑 (Shift Register Buffer)
// 考虑到极端情况，水桶需要比 64 + 本次最大输入 (约 80) 更大，定义 256 位保平安
logic [255 : 0] buffer;
logic [8 : 0]   buffer_len;

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        buffer        <= 'd0;
        buffer_len    <= 'd0;
        encode        <= 'd0;
        encoder_valid <= 1'b0;
    end
    else begin
        // 默认不输出
        encoder_valid <= 1'b0;

        // 核心流水线状态机：进水与出水
        if (merged_valid) begin
            // 场景 A：进水后，水桶满了 64 滴水以上 -> 必须出水
            if (buffer_len + merged_len >= 9'd64) begin
                // 1. 把新来的数据拼接到当前水位之上，形成一个临时的“大水桶”
                logic [255:0] temp_buffer;
                temp_buffer = buffer | ({128'd0, merged_data} << buffer_len);
                
                // 2. 切出最底下的 64 位作为输出
                encode        <= temp_buffer[63 : 0];
                encoder_valid <= 1'b1;
                
                // 3. 剩下的水整体下沉 64 位，并更新水位长度
                buffer     <= temp_buffer >> 64;
                buffer_len <= (buffer_len + merged_len) - 9'd64;
            end
            // 场景 B：进水后，水桶还没满 64 滴水 -> 继续蓄水
            else begin
                buffer     <= buffer | ({128'd0, merged_data} << buffer_len);
                buffer_len <= buffer_len + merged_len;
            end
        end
        else begin
            // 当没有新数据来时，检查水桶里是否还有满 64 位的水没排出去
            // (应对突然停止输入，但池子里还有数据的情况)
            if (buffer_len >= 9'd64) begin
                encode        <= buffer[63 : 0];
                encoder_valid <= 1'b1;
                buffer     <= buffer >> 64;
                buffer_len <= buffer_len - 9'd64;
            end
            else if (system_done && buffer_len > 0) begin
                encode <= buffer[63:0]; // 高位天然为0
                encoder_valid <= 1'b1;
                buffer_len <= 'd0;
            end
        end
    end
end

endmodule
