module Poly_PAU(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 原始系数(从存储矩阵中一次读取四个) ---
    input       logic   [91 : 0]        ori_coeff,
    input       logic                   ori_coeff_valid,
    input       logic                   request,            // 上游请求信号

    input       logic   [91 : 0]        ext_operand,        // 外部输入的计算数
    output      logic                   ext_operand_request,// 请求获取外部输入的计算数  First World Fall Through
    input       logic   [4 : 0]         mode_config,        // 模式选择 0: NTT 1: INTT 2: 模乘 3: 模加 4: 模减

    // --- NTT域系数(向存储矩阵中一次写入四个) ---
    output      logic                   ready,              // 下游准备信号
    output      logic   [91 : 0]        con_coeff,
    output      logic                   con_coeff_valid
);

// ==========================================================
// 1. 寄存器和状态定义
// ==========================================================

(* ram_style = "distributed" *) logic   [22 : 0]    bramPing[3 : 0] [63 : 0] = '{default: '0};
(* ram_style = "distributed" *) logic   [22 : 0]    bramPong[3 : 0] [63 : 0] = '{default: '0};

logic   [5 : 0]                 bram_row_cnt;               // 用于 INPUT 和 OUTPUT 状态的计数器
logic   [5 : 0]                 conv_cnt;                   // 用于 CONV 状态的流水线计数器
logic   [1 : 0]                 stage_cnt;                  // NTT 阶段的计数器
logic   [5 : 0]                 wr_cnt;                     // 用于写入 BRAM 的计数器
logic                           rd_done;                    // 读取完成信号
logic   [22 : 0]                c0, c1, c2, c3;             // BU 的计算结果
logic   [22 : 0]                a0_d, a1_d, a2_d, a3_d;     // 从ROM中读取Zeta需要1个时钟周期 因此对a延迟一个时钟周期同步
logic                           ReconfigCompute_valid_in;   // 可重构计算模块输入数据有效信号
logic        	                ReconfigCompute_valid_out;  // 可重构计算模块输出数据有效信号
logic   [91 : 0] 	            ReconfigCompute_res;        // 可重构计算模块输出数据
logic   [7 : 0] 	            rom_addr_out1;              // Zeta1 索引
logic   [7 : 0] 	            rom_addr_out2;              // Zeta2 索引
logic   [7 : 0] 	            rom_addr_out3;              // Zeta3 索引
logic       	                output_finish;              // Zeta 输出完成信号
logic   [22 : 0]                zeta1, zeta2, zeta3;        // Zeta具体值

typedef enum logic [2 : 0] { 
    IDLE,
    ACK,
    INPUT,
    CONV,
    OUTPUT
} state_t;

state_t state;

// ==========================================================
// 2. 握手逻辑
// ==========================================================
always_ff @(posedge clk) begin
    if (!rstn)
        ready <= 1'b0;
    else if (request)
        ready <= 1'b0;
    else if (state == IDLE)
        ready <= 1'b1;
    else 
        ready <= 1'b0;
end

// ==========================================================
// 3. 计数器逻辑
// ==========================================================
always_ff @(posedge clk) begin
    if (!rstn) begin
        bram_row_cnt <= 'd0;
        conv_cnt     <= 'd0;
        stage_cnt    <= 'd0;
        wr_cnt       <= 'd0;
        rd_done      <= 1'b0;
    end 
    else begin
        if (state == INPUT && ori_coeff_valid)
            bram_row_cnt <= (bram_row_cnt == 'd63) ? 'd0 : bram_row_cnt + 1;
        else if (state == OUTPUT)
            bram_row_cnt <= (bram_row_cnt == 'd63) ? 'd0 : bram_row_cnt + 1;
        
        if (state == CONV) begin
            if (rd_done == 1'b0) begin
                conv_cnt <= conv_cnt + 1;       // 自然溢出回 0
                if (conv_cnt == 'd63)
                    rd_done <= 1'b1;
            end
            if (ReconfigCompute_valid_out) begin
                wr_cnt <= wr_cnt + 1;
                if (wr_cnt == 'd63) begin
                    rd_done <= 1'b0;            // 准备开启下一个阶段的狂奔
                    stage_cnt <= stage_cnt + 1; // 阶段 +1 (溢出回0)
                end
            end
        end
        else begin
            conv_cnt <= 'd0;
            wr_cnt <= 'd0;
            rd_done <= 1'b0;
        end
    end
end

// ==========================================================
// 4. 输出有效信号逻辑
// ==========================================================
assign con_coeff_valid = (state == OUTPUT);

// ==========================================================
// 5. 核心数据流：读交叉开关 (Read Crossbar)
// ==========================================================

logic   [5 : 0]     rd_addr_b0, rd_addr_b1, rd_addr_b2, rd_addr_b3; 
logic   [1 : 0]     rd_offset;

// --- INTT OUTPUT 阶段专用的乱序还原网络 ---
// 在最后输出时，跨行跨Bank精准抓取数据，拼成自然顺序！
wire [5:0] out_t = (state == OUTPUT) ? bram_row_cnt : '0;
wire [1:0] out_col = {out_t[4], out_t[5]}; // 逻辑列反转

wire [5:0] out_row_0 = {2'b00, out_t[0], out_t[1], out_t[2], out_t[3]};
wire [5:0] out_row_1 = {2'b10, out_t[0], out_t[1], out_t[2], out_t[3]};
wire [5:0] out_row_2 = {2'b01, out_t[0], out_t[1], out_t[2], out_t[3]};
wire [5:0] out_row_3 = {2'b11, out_t[0], out_t[1], out_t[2], out_t[3]};

// 计算这 4 个数据分别藏在哪个 Bank
wire [1:0] out_offset_0 = (out_row_0[5:4] + out_row_0[3:2] + out_row_0[1:0]) % 4;
wire [1:0] out_bank_0 = (out_col + out_offset_0) % 4;
wire [1:0] out_bank_1 = (out_bank_0 + 2) % 4;
wire [1:0] out_bank_2 = (out_bank_0 + 1) % 4;
wire [1:0] out_bank_3 = (out_bank_0 + 3) % 4;

always_comb begin
    if (state == OUTPUT && mode_config == 'd1) begin
        // INTT OUTPUT：允许4个Bank同时独立读取不同的行
        rd_addr_b0 = (out_bank_0 == 0) ? out_row_0 : (out_bank_1 == 0) ? out_row_1 : (out_bank_2 == 0) ? out_row_2 : out_row_3;
        rd_addr_b1 = (out_bank_0 == 1) ? out_row_0 : (out_bank_1 == 1) ? out_row_1 : (out_bank_2 == 1) ? out_row_2 : out_row_3;
        rd_addr_b2 = (out_bank_0 == 2) ? out_row_0 : (out_bank_1 == 2) ? out_row_1 : (out_bank_2 == 2) ? out_row_2 : out_row_3;
        rd_addr_b3 = (out_bank_0 == 3) ? out_row_0 : (out_bank_1 == 3) ? out_row_1 : (out_bank_2 == 3) ? out_row_2 : out_row_3;
        rd_offset = 2'd0;
    end else begin
        // NTT OUTPUT & 所有 CONV：4个Bank常规读同一行
        rd_addr_b0 = (state == OUTPUT) ? bram_row_cnt : conv_cnt;
        rd_addr_b1 = rd_addr_b0;
        rd_addr_b2 = rd_addr_b0;
        rd_addr_b3 = rd_addr_b0;
        rd_offset = (rd_addr_b0[5:4] + rd_addr_b0[3:2] + rd_addr_b0[1:0]) % 4;
    end
end

logic   [22 : 0]    out_b0, out_b1, out_b2, out_b3; 
logic   [22 : 0]    a0, a1, a2, a3;                 

wire read_ping = (state == OUTPUT) || (state == CONV && stage_cnt[0] == 1'b0);

assign out_b0 = read_ping ? bramPing[0][rd_addr_b0] : bramPong[0][rd_addr_b0];
assign out_b1 = read_ping ? bramPing[1][rd_addr_b1] : bramPong[1][rd_addr_b1];
assign out_b2 = read_ping ? bramPing[2][rd_addr_b2] : bramPong[2][rd_addr_b2];
assign out_b3 = read_ping ? bramPing[3][rd_addr_b3] : bramPong[3][rd_addr_b3];

always_comb begin
    if (state == OUTPUT && mode_config == 'd1) begin
        // INTT OUTPUT：按目标 Bank 重新组装成自然顺序
        a0 = (out_bank_0 == 0) ? out_b0 : (out_bank_0 == 1) ? out_b1 : (out_bank_0 == 2) ? out_b2 : out_b3;
        a1 = (out_bank_1 == 0) ? out_b0 : (out_bank_1 == 1) ? out_b1 : (out_bank_1 == 2) ? out_b2 : out_b3;
        a2 = (out_bank_2 == 0) ? out_b0 : (out_bank_2 == 1) ? out_b1 : (out_bank_2 == 2) ? out_b2 : out_b3;
        a3 = (out_bank_3 == 0) ? out_b0 : (out_bank_3 == 1) ? out_b1 : (out_bank_3 == 2) ? out_b2 : out_b3;
    end else if (mode_config == 'd1) begin
        // INTT CONV 模式：交叉互换 (注意这里 a1 和 a2 互换)
        case (rd_offset)
            2'd0: begin a0 = out_b0; a1 = out_b1; a2 = out_b2; a3 = out_b3; end
            2'd1: begin a0 = out_b1; a1 = out_b2; a2 = out_b3; a3 = out_b0; end
            2'd2: begin a0 = out_b2; a1 = out_b3; a2 = out_b0; a3 = out_b1; end
            2'd3: begin a0 = out_b3; a1 = out_b0; a2 = out_b1; a3 = out_b2; end
        endcase
    end 
    else begin
        // NTT 模式
        case (rd_offset)
            2'd0: begin a0 = out_b0; a1 = out_b1; a2 = out_b2; a3 = out_b3; end
            2'd1: begin a0 = out_b1; a1 = out_b2; a2 = out_b3; a3 = out_b0; end
            2'd2: begin a0 = out_b2; a1 = out_b3; a2 = out_b0; a3 = out_b1; end
            2'd3: begin a0 = out_b3; a1 = out_b0; a2 = out_b1; a3 = out_b2; end
        endcase
    end
end

assign con_coeff = {a3, a2, a1, a0};

// ==========================================================
// 6. 蝶形运算单元 (Butterfly Unit)
// ==========================================================
always_ff @(posedge clk) begin
    if (!rstn) begin
        a0_d <= 'd0;
        a1_d <= 'd0;
        a2_d <= 'd0;
        a3_d <= 'd0;
        ReconfigCompute_valid_in <= 1'b0;
    end
    else begin
        a0_d <= a0;
        a1_d <= a1;
        a2_d <= a2;
        a3_d <= a3;
        ReconfigCompute_valid_in <= (state == CONV) & (rd_done == 1'b0);
    end
end
assign ext_operand_request = ReconfigCompute_valid_in;
ReconfigCompute u_ReconfigCompute(
	.clk         	( clk                                   ),
	.rstn        	( rstn                                  ),
	.valid_in    	( ReconfigCompute_valid_in              ),
	.A           	( {a0_d, a2_d, a1_d, a3_d}              ),
	.B           	( ext_operand                           ),
	.Z           	( {zeta1, zeta2, zeta3, 23'd0}          ),
	.valid_out   	( ReconfigCompute_valid_out             ),
	.D           	( ReconfigCompute_res                   ),
	.mode_config 	( mode_config                           )
);

assign {c3, c2, c1, c0} = ReconfigCompute_res;

// assign ReconfigCompute_valid_out = ReconfigCompute_valid_in;
// assign {c3, c2, c1, c0} = {a3_d, a2_d, a1_d, a0_d};

//* 0-latency
ZetaRomAddrGen u_ZetaRomAddrGen(
	.clk           	( clk                           ),
	.rstn          	( rstn                          ),
	.mode_config   	( mode_config                   ),
	.rom_request   	( state == CONV && !rd_done     ),
	.rom_addr_out1 	( rom_addr_out1                 ),
	.rom_addr_out2 	( rom_addr_out2                 ),
	.rom_addr_out3 	( rom_addr_out3                 ),
	.output_finish 	( output_finish                 )
);

//* 1-latency
ZetaRaw_ROM Zeta1_ROM (
  .clka(clk),                           // input wire clka
  .ena(1'b1),                           // input wire ena
  .addra(rom_addr_out1),                // input wire [7 : 0] addra
  .douta(zeta1)                         // output wire [22 : 0] douta
);

ZetaRaw_ROM Zeta2_ROM (
  .clka(clk),                           // input wire clka
  .ena(1'b1),                           // input wire ena
  .addra(rom_addr_out2),                // input wire [7 : 0] addra
  .douta(zeta2)                         // output wire [22 : 0] douta
);

ZetaRaw_ROM Zeta3_ROM (
  .clka(clk),                           // input wire clka
  .ena(1'b1),                           // input wire ena
  .addra(rom_addr_out3),                // input wire [7 : 0] addra
  .douta(zeta3)                         // output wire [22 : 0] douta
);

// ==========================================================
// 7. 核心数据流：写交叉开关 (Write Crossbar) 与 BRAM 写入
// ==========================================================

// 7.1 NTT 模式下的写逻辑 (跨行散布)
wire [1:0] in_offset = (bram_row_cnt[5:4] + bram_row_cnt[3:2] + bram_row_cnt[1:0]) % 4;
wire [5:0] in_row_0 = {bram_row_cnt[3:0], 2'd0};
wire [5:0] in_row_1 = {bram_row_cnt[3:0], 2'd1};
wire [5:0] in_row_2 = {bram_row_cnt[3:0], 2'd2};
wire [5:0] in_row_3 = {bram_row_cnt[3:0], 2'd3};

// 7.2 INTT 模式：神级优化！(BR散布 + 1次Shuffle 的等效融合)
// 直接把 t 和 c 位反转。等效于在 INPUT 时瞬间完成了你说的“加一次 shuffle”！
wire [5:0] in_row_intt = {bram_row_cnt[0], bram_row_cnt[1], bram_row_cnt[2], bram_row_cnt[3], bram_row_cnt[4], bram_row_cnt[5]};
wire [1:0] in_offset_intt = (in_row_intt[5:4] + in_row_intt[3:2] + in_row_intt[1:0]) % 4;

// 7.3 CONV 状态的洗牌写逻辑 
wire [5:0] wr_row_c0 = {wr_cnt[3:0], 2'b00}; 
wire [5:0] wr_row_c1 = {wr_cnt[3:0], 2'b01};
wire [5:0] wr_row_c2 = {wr_cnt[3:0], 2'b10};
wire [5:0] wr_row_c3 = {wr_cnt[3:0], 2'b11};
wire [1:0] wr_offset = (wr_cnt[5:4] + wr_cnt[3:2] + wr_cnt[1:0]) % 4;

always_ff @(posedge clk) begin
    if (state == INPUT && ori_coeff_valid) begin
        if (mode_config == 'd0) begin
            // --- NTT 模式：Stride-64 散布写入 ---
            case (in_offset)
                2'd0: begin bramPing[0][in_row_0] <= ori_coeff[22:0]; bramPing[1][in_row_1] <= ori_coeff[45:23]; bramPing[2][in_row_2] <= ori_coeff[68:46]; bramPing[3][in_row_3] <= ori_coeff[91:69]; end
                2'd1: begin bramPing[1][in_row_0] <= ori_coeff[22:0]; bramPing[2][in_row_1] <= ori_coeff[45:23]; bramPing[3][in_row_2] <= ori_coeff[68:46]; bramPing[0][in_row_3] <= ori_coeff[91:69]; end
                2'd2: begin bramPing[2][in_row_0] <= ori_coeff[22:0]; bramPing[3][in_row_1] <= ori_coeff[45:23]; bramPing[0][in_row_2] <= ori_coeff[68:46]; bramPing[1][in_row_3] <= ori_coeff[91:69]; end
                2'd3: begin bramPing[3][in_row_0] <= ori_coeff[22:0]; bramPing[0][in_row_1] <= ori_coeff[45:23]; bramPing[1][in_row_2] <= ori_coeff[68:46]; bramPing[2][in_row_3] <= ori_coeff[91:69]; end
            endcase
        end else begin
            // --- INTT 模式：聚拢写入 ---
            // 注意！这里的 c=1 (ori_coeff[45:23]) 被写进了 Bank 2，c=2 被写进了 Bank 1。这就是 C 列的隐式翻转。
            case (in_offset_intt)
                2'd0: begin bramPing[0][in_row_intt] <= ori_coeff[22:0]; bramPing[2][in_row_intt] <= ori_coeff[45:23]; bramPing[1][in_row_intt] <= ori_coeff[68:46]; bramPing[3][in_row_intt] <= ori_coeff[91:69]; end
                2'd1: begin bramPing[1][in_row_intt] <= ori_coeff[22:0]; bramPing[3][in_row_intt] <= ori_coeff[45:23]; bramPing[2][in_row_intt] <= ori_coeff[68:46]; bramPing[0][in_row_intt] <= ori_coeff[91:69]; end
                2'd2: begin bramPing[2][in_row_intt] <= ori_coeff[22:0]; bramPing[0][in_row_intt] <= ori_coeff[45:23]; bramPing[3][in_row_intt] <= ori_coeff[68:46]; bramPing[1][in_row_intt] <= ori_coeff[91:69]; end
                2'd3: begin bramPing[3][in_row_intt] <= ori_coeff[22:0]; bramPing[1][in_row_intt] <= ori_coeff[45:23]; bramPing[0][in_row_intt] <= ori_coeff[68:46]; bramPing[2][in_row_intt] <= ori_coeff[91:69]; end
            endcase
        end
    end
    else if (state == CONV && ReconfigCompute_valid_out) begin
        if ((mode_config == 'd1) || (mode_config == 'd0 && stage_cnt != 'd3)) begin
            if (stage_cnt[0] == 1'b0) begin 
                case (wr_offset)
                    2'd0: begin bramPong[0][wr_row_c0] <= c0; bramPong[1][wr_row_c1] <= c1; bramPong[2][wr_row_c2] <= c2; bramPong[3][wr_row_c3] <= c3; end
                    2'd1: begin bramPong[1][wr_row_c0] <= c0; bramPong[2][wr_row_c1] <= c1; bramPong[3][wr_row_c2] <= c2; bramPong[0][wr_row_c3] <= c3; end
                    2'd2: begin bramPong[2][wr_row_c0] <= c0; bramPong[3][wr_row_c1] <= c1; bramPong[0][wr_row_c2] <= c2; bramPong[1][wr_row_c3] <= c3; end
                    2'd3: begin bramPong[3][wr_row_c0] <= c0; bramPong[0][wr_row_c1] <= c1; bramPong[1][wr_row_c2] <= c2; bramPong[2][wr_row_c3] <= c3; end
                endcase
            end else begin
                case (wr_offset)
                    2'd0: begin bramPing[0][wr_row_c0] <= c0; bramPing[1][wr_row_c1] <= c1; bramPing[2][wr_row_c2] <= c2; bramPing[3][wr_row_c3] <= c3; end
                    2'd1: begin bramPing[1][wr_row_c0] <= c0; bramPing[2][wr_row_c1] <= c1; bramPing[3][wr_row_c2] <= c2; bramPing[0][wr_row_c3] <= c3; end
                    2'd2: begin bramPing[2][wr_row_c0] <= c0; bramPing[3][wr_row_c1] <= c1; bramPing[0][wr_row_c2] <= c2; bramPing[1][wr_row_c3] <= c3; end
                    2'd3: begin bramPing[3][wr_row_c0] <= c0; bramPing[0][wr_row_c1] <= c1; bramPing[1][wr_row_c2] <= c2; bramPing[2][wr_row_c3] <= c3; end
                endcase
            end
        end 
        else begin
            case (wr_offset)
                2'd0: begin bramPing[0][wr_cnt] <= c0; bramPing[1][wr_cnt] <= c1; bramPing[2][wr_cnt] <= c2; bramPing[3][wr_cnt] <= c3; end
                2'd1: begin bramPing[1][wr_cnt] <= c0; bramPing[2][wr_cnt] <= c1; bramPing[3][wr_cnt] <= c2; bramPing[0][wr_cnt] <= c3; end
                2'd2: begin bramPing[2][wr_cnt] <= c0; bramPing[3][wr_cnt] <= c1; bramPing[0][wr_cnt] <= c2; bramPing[1][wr_cnt] <= c3; end
                2'd3: begin bramPing[3][wr_cnt] <= c0; bramPing[0][wr_cnt] <= c1; bramPing[1][wr_cnt] <= c2; bramPing[2][wr_cnt] <= c3; end
            endcase
        end
    end
end

// ==========================================================
// 8. 状态机
// ==========================================================
always_ff @(posedge clk) begin
    if (!rstn)
        state <= IDLE;
    else begin
        case (state)
            IDLE : begin 
                if (request)
                    state <= ACK;
                else 
                    state <= IDLE;
            end
            ACK : begin
                if (ready == 1'b0 && request == 1'b1)
                    state <= INPUT;
                else 
                    state <= ACK;
            end
            INPUT : begin
                if (ori_coeff_valid && bram_row_cnt == 'd63)
                    state <= CONV;
                else 
                    state <= INPUT;
            end
            CONV : begin
                if (ReconfigCompute_valid_out && wr_cnt == 'd63) begin
                    if (stage_cnt == 'd3)
                        state <= OUTPUT;
                    else 
                        state <= CONV;
                end
            end
            OUTPUT : begin
                if (bram_row_cnt == 'd63)
                    state <= IDLE;
                else 
                    state <= OUTPUT;
            end
            default : begin
                state <= IDLE;
            end
        endcase
    end
end

endmodule
