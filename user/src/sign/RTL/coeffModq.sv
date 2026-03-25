`include "../../param_conf.v"
module coeffModq #(
    parameter S1_S2_BIT_LEN = $clog2(2 * `eta) + 1,
    parameter T0_BIT_LEN = `d
)(
    input  logic                clk,
    input  logic                rstn,

    // --- BRAM 读取接口 (反控顶层) ---
    output logic                ram_rd_en,       
    input  logic [63 : 0]       ori_coeff,       
    input  logic                ori_coeff_valid, 
    
    // --- 控制与状态 ---
    input  logic [1 : 0]        coeff_type,      

    // --- Poly_PAU 握手与输出接口 ---
    input  logic                poly_start_pulse, // 短脉冲握手条件: (ready == 1'b0 && request == 1'b1)
    output logic [91 : 0]       modq_coeff,      
    output logic                modq_coeff_valid
);

// =========================================================
// 0. 输出事务控制 (自主吐出 64 拍)
// =========================================================
logic           [6 : 0]             burst_cnt;    // 计数 0~64
logic                               is_bursting;  // 当前是否处于连续吐数据状态

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        burst_cnt   <= 'd0;
        is_bursting <= 1'b0;
    end 
    else begin
        // 收到握手脉冲，启动新一轮装载 (256个系数 = 64拍)
        if (poly_start_pulse) begin
            is_bursting <= 1'b1;
            burst_cnt   <= 'd0;
        end 
        // 在 Burst 状态下，只要成功吐出一次数据，计数器加 1
        else if (is_bursting && modq_coeff_valid) begin
            if (burst_cnt == 7'd63) begin
                is_bursting <= 1'b0; // 64 拍吐完，关闭阀门
                burst_cnt   <= 'd0;
            end 
            else begin
                burst_cnt <= burst_cnt + 1'b1;
            end
        end
    end
end


// =========================================================
// 1. 宽位蓄水池 (处理 64-bit 进，零碎 bit 出的速率差)
// =========================================================
logic [255 : 0] buffer;
logic [8 : 0]   buffer_len;
logic [7 : 0]   consume_len;

// 请求 BRAM 继续读水 (留足余量吃下 RAM 读延迟)
assign ram_rd_en = (buffer_len <= 9'd128);

always_comb begin
    if (coeff_type == 2'd2) 
        consume_len = T0_BIT_LEN * 4;
    else                    
        consume_len = S1_S2_BIT_LEN * 4;
end

logic [127 : 0] extracted_bits;
logic           extracted_valid;

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        buffer          <= 'd0;
        buffer_len      <= 'd0;
        extracted_bits  <= 'd0;
        extracted_valid <= 1'b0;
    end else begin
        logic [255 : 0] next_buffer;
        logic [8 : 0]   next_buffer_len;

        // 阶段 1: 进水 (如果 BRAM 数据有效)
        if (ori_coeff_valid) begin
            next_buffer     = buffer | ({192'd0, ori_coeff} << buffer_len);
            next_buffer_len = buffer_len + 9'd64;
        end else begin
            next_buffer     = buffer;
            next_buffer_len = buffer_len;
        end

        // 阶段 2: 出水 (自主判断：处于 Burst 状态且池子里水够)
        if (is_bursting && next_buffer_len >= consume_len) begin
            extracted_bits  <= next_buffer[127 : 0];
            extracted_valid <= 1'b1;
            // 剩余数据右移下沉
            buffer          <= next_buffer >> consume_len;
            buffer_len      <= next_buffer_len - consume_len;
        end else begin
            extracted_valid <= 1'b0;
            buffer          <= next_buffer;
            buffer_len      <= next_buffer_len;
        end
    end
end

// =========================================================
// 2. 解码、还原符号与 Mod q
// =========================================================
always_comb begin
    modq_coeff_valid = extracted_valid;
    modq_coeff       = 92'd0;

    for (int i = 0; i < 4; i++) begin
        logic [22 : 0] single_coeff;
        
        if (coeff_type == 2'd2) begin
            logic [12 : 0] packed_t0;
            logic signed [13 : 0] t0_signed; 
            
            packed_t0 = extracted_bits[i * T0_BIT_LEN +: T0_BIT_LEN];
            t0_signed = 14'd4096 - {1'b0, packed_t0};
            
            if (t0_signed < 0) 
                single_coeff = `q + t0_signed; 
            else 
                single_coeff = t0_signed;
        end 
        else begin
            logic [4 : 0] s_raw;
            s_raw = extracted_bits[i * S1_S2_BIT_LEN +: S1_S2_BIT_LEN];
            
            if (`eta >= s_raw)
                single_coeff = `eta - s_raw;
            else
                single_coeff = `q + `eta - s_raw;
        end
        
        modq_coeff[i * 23 +: 23] = single_coeff;
    end
end

endmodule