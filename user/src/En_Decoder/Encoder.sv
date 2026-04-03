`include "../param_conf.v"

module Encoder
#(
    parameter T1_BIT_LEN = $clog2(`q - 1) - `d,                     // default : 10
    parameter S1_S2_BIT_LEN = $clog2(2 * `eta) + 1,                 // default : 3
    parameter T0_BIT_LEN = `d,                                      // default : 13
    parameter Z_BIT_LEN = `bit_count,                               // default : 18
    parameter H_BIT_LEN = 'd1                             
)(
    input       logic                                   clk,
    input       logic                                   rstn,
    input       logic                                   system_done,

    // --- 公钥(pk) 编码信号 ---
    input       logic   [4 * T1_BIT_LEN - 1 : 0]        t1,         
    input       logic                                   t1_valid,

    // --- 私钥(sk) 编码信号 ---
    input       logic   [4 * 23 - 1 : 0]                s1,         
    input       logic                                   s1_valid,
    input       logic   [4 * 23 - 1 : 0]                s2,         
    input       logic                                   s2_valid,
    input       logic   [4 * T0_BIT_LEN - 1 : 0]        t0,         
    input       logic                                   t0_valid,

    // --- 签名(sig) 编码信号 ---
    input       logic   [4 * 23 - 1 : 0]                z,
    input       logic                                   z_valid,
    
    // --- 编码输出接口 输出位宽 8 个字节 ---
    output      logic   [63 : 0]                        encode,
    output      logic                                   encoder_valid
    // 如果上游支持反压，可暴露此信号；不支持则可不用，FIFO深度已足够吸收一次多项式运算
    // output   logic                                   encoder_ready 
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
// 1. 变长比特拼接 (合并 4 个通道的数据为一个宽位总线)
// ==========================================================
logic [127 : 0] merged_data;     // 足够容纳一次产生的最大数据量
logic [6  : 0]  merged_len;      // 本次合并的数据总位宽 (0 ~ 127)
logic           merged_valid;

always_comb begin
    merged_data  = 'd0;
    merged_len   = 'd0;
    merged_valid = 1'b0;

    if (pk_encode_valid[0]) begin
        merged_data  = {pk_encode[3], pk_encode[2], pk_encode[1], pk_encode[0]};
        merged_len   = 7'd40;
        merged_valid = 1'b1;
    end
    else if (sig_encode_valid[0]) begin
        merged_data  = {sig_encode[3], sig_encode[2], sig_encode[1], sig_encode[0]};
        merged_len   = {2'b00, Z_BIT_LEN[4:0]} << 2; // Z_BIT_LEN * 4
        merged_valid = 1'b1;
    end
    else if (sk_encode_valid[0]) begin
        logic [127:0] d0 = sk_encode[0];
        logic [127:0] d1 = sk_encode[1];
        logic [127:0] d2 = sk_encode[2];
        logic [127:0] d3 = sk_encode[3];
        
        merged_data  = d0 | 
                       (d1 << (sk_encode_len[0])) | 
                       (d2 << (sk_encode_len[0] * 2)) | 
                       (d3 << (sk_encode_len[0] * 3));
                       
        merged_len   = {2'b00, sk_encode_len[0]} << 2; 
        merged_valid = 1'b1;
    end
end

// ==========================================================
// 2. FIFO 缓冲层：吸收突发大流量，将逻辑寄存器转为 Block RAM
// ==========================================================
logic [134 : 0] fifo_din;        // 128 bit 数据 + 7 bit 长度 = 135 bit
logic [134 : 0] fifo_dout;
logic           fifo_wr_en;
logic           fifo_rd_en;
logic           fifo_empty;
logic           fifo_full;

assign fifo_din   = {merged_len, merged_data};
assign fifo_wr_en = merged_valid; 

// 例化 FWFT FIFO (深度 256 足以吸收 256 个多项式系数产生的残留)
sync_fifo_fwft #(
    .DATA_WIDTH(135), 
    .DEPTH(256)
) u_buffer_fifo (
    .clk    (clk),
    .rstn   (rstn),
    .wr_en  (fifo_wr_en),
    .din    (fifo_din),
    .rd_en  (fifo_rd_en),
    .dout   (fifo_dout),
    .empty  (fifo_empty),
    .full   (fifo_full)
);

// FIFO 读出的信号解析
logic [127:0] stage_data;
logic [6:0]   stage_len;
assign stage_len  = fifo_dout[134 : 128];
assign stage_data = fifo_dout[127 : 0];

// ==========================================================
// 3. 安全位宽截取器 (Safe Bit Packer)
// ==========================================================
// 由于有了 FIFO，这里的工作缓存只需要 256 位，并且永不溢出
logic [255 : 0] work_buffer;
logic [8 : 0]   work_len;

// FIFO 读取控制逻辑：只要工作桶里的水不满 128 且 FIFO 还有水，就继续进水
assign fifo_rd_en = !fifo_empty && (work_len < 9'd128);

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        work_buffer   <= 'd0;
        work_len      <= 'd0;
        encode        <= 'd0;
        encoder_valid <= 1'b0;
    end
    else begin
        encoder_valid <= 1'b0; // 默认不输出

        // ----- 第一步：处理当前工作桶的出水与进水 -----
        // 场景 A：桶里有超过 64 bit 的水，优先排干 64 bit
        if (work_len >= 9'd64) begin
            encode        <= work_buffer[63 : 0];
            encoder_valid <= 1'b1;
            
            // 如果同时还在从 FIFO 进水
            if (fifo_rd_en) begin
                // 出去 64，进来 stage_len，工作桶数据需要叠加
                work_buffer <= (work_buffer >> 64) | ({128'd0, stage_data} << (work_len - 9'd64));
                work_len    <= work_len - 9'd64 + stage_len;
            end
            else begin
                // 仅出水
                work_buffer <= work_buffer >> 64;
                work_len    <= work_len - 9'd64;
            end
        end
        // 场景 B：桶里的水不够 64 bit，但不影响 FIFO 进水
        else begin
            if (fifo_rd_en) begin
                work_buffer <= work_buffer | ({128'd0, stage_data} << work_len);
                work_len    <= work_len + stage_len;
            end
            // 如果没有新数据进来，但触发了 system_done (算法结束收尾阶段)
            else if (system_done && work_len > 0) begin
                encode        <= work_buffer[63 : 0]; // 剩余的不足 64 bit 直接输出，高位补 0
                encoder_valid <= 1'b1;
                work_len      <= 'd0;
            end
        end
    end
end

endmodule