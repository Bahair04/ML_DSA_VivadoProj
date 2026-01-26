module sha3(
    // --- 时钟复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- 数据输入接口 ---
    input       logic   [7 : 0]     din,            // 8 - bit 串行输入数据
    input       logic               din_valid,      // 8 - bit 数据有效信号
    input       logic   [7 : 0]     din_len,        // 8 - bit 输入数据长度

    // --- SHA3 相关参数 ---
    input       logic   [7 : 0]     mdlen,          // 8 - bit 输出哈希值长度
    input       logic               init,           // 初始化信号
    input       logic               start,          // 开始数据信号  
    output      logic               done,           // update和xof完成信号 表示可以进行out了
    input       logic               start_out,      // 指示开始输出的信号
    input       logic   [7 : 0]     out_len,        // 8 - bit 输出数据长度

    // --- 数据输出接口 ---
    output      logic   [7 : 0]                 st_8bit,            // 8 - bit 串行输出数据                
    output      logic                           st_8bit_valid       // 8 - bit 串行输出有效信号 

);

// ==========================================================
// 状态和参数定义
// ==========================================================

// --------------------------------
// 状态定义
// --------------------------------
typedef enum logic [2 : 0] { 
    S_IDLE,  
    S_UPDATE,
    S_XOF,
    S_OUT,
    S_KACCAK,
    S_XOF_PAD,
    S_XOF_KACCAK,
    S_OUT_KACCAK
} state_t;

state_t state;
state_t state_d;

// --------------------------------
// 参数定义
// --------------------------------
typedef struct packed {
    logic   [7 : 0]                 mdlen;
    logic   [7 : 0]                 pt;
    logic   [7 : 0]                 rsiz;
    logic   [0 : 4][0 : 4][63 :0]   st;
} sha3_ctx_t;
sha3_ctx_t ctx;

// --- KACCAK控制信号 ---
logic                               start_perm;
logic                               perm_done;
logic       [7 : 0]                 pad_din;
logic                               pad_din_valid;
logic       [2 : 0]                 pad_din_row;
logic       [2 : 0]                 pad_din_col;
logic       [2 : 0]                 pad_din_pos;
logic                               pad_cnt;        // 用于记录填充阶段的计数器

// --- 展开位置记录计数器 ---
logic       [7 : 0]                 cnt;            // 原始8 - bit数据计数器
logic       [2 : 0]                 din_row;        // 数据输入行
logic       [2 : 0]                 din_col;        // 数据输入列
logic       [2 : 0]                 din_pos;        // 数据输入位置(即当前8 - bit在展开的64 - bit中的位置)
logic       [7 : 0]                 curr_pt;
assign curr_pt = din_pos + ((din_row * 5 + din_col) << 3);

// --- FIFO 相关信号 ---
logic                               wr_en;
logic                               rd_en;
logic       [7 : 0]                 dout;
logic                               empty;
logic                               full;
logic       [8 : 0]                 data_count;
logic       [8 : 0]                 data_count_d;

// --- 串行输出8 - bit信号 ---
logic       [7 : 0]                 st_8bit_cnt;

// ==========================================================
// 具体逻辑实现
// ==========================================================

// --------------------------------
// 8 - bit 计数
// --------------------------------

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        cnt <= 'd0;
    else if (state == S_UPDATE) begin
        if (rd_en) begin
            if (cnt == din_len - 1)
                cnt <= 'd0;
            else 
                cnt <= cnt + 1'b1;
        end
        else 
            cnt <= cnt;
    end 
    else 
        cnt <= cnt;
end

// --------------------------------
// 行、列、位置计数
// --------------------------------

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        din_row <= 'd0;
        din_col <= 'd0;
        din_pos <= 'd0;
        rd_en <= 1'b0;
    end
    else if (start_out) begin
        din_pos <= ctx.pt[2 : 0]; // pt % 8
        din_col <= ctx.pt[7 : 3] % 5; // pt / 8 % 5
        din_row <= ctx.pt[7 : 3] / 5; // pt / 8 / 5
    end
    else if ((state_d == S_IDLE || state_d == S_KACCAK) && state == S_UPDATE) begin
        din_pos <= ctx.pt[2 : 0]; // pt % 8
        din_col <= ctx.pt[7 : 3] % 5; // pt / 8 % 5
        din_row <= ctx.pt[7 : 3] / 5; // pt / 8 / 5
        rd_en <= 1'b0;
    end
    else if (state == S_UPDATE) begin
        if (empty == 1'b0 && rd_en == 1'b0) // FIFO非空并且读信号未使能
            rd_en <= 1'b1;                  // 那么就开始读取
        else if (data_count_d == 'd2 && data_count == 'd1)
            rd_en <= 1'b0;
        else 
            rd_en <= rd_en;
        if (rd_en) begin // 更新8-bit在展开的64-bit中的位置
            if (din_pos == 'd7) begin
                din_pos <= 'd0;
                if (din_col == 'd4) begin
                    din_col <= 'd0;
                    if (din_row == 'd4)
                        din_row <= 'd0;
                    else 
                        din_row <= din_row + 1'b1;
                end
                else 
                    din_col <= din_col + 1'b1;
            end
            else 
                din_pos <= din_pos + 1'b1;
        end
    end
    else if (state == S_KACCAK || state == S_OUT_KACCAK) begin
        din_pos <= 'd0;
        din_col <= 'd0;
        din_row <= 'd0;
    end
    else if (state == S_OUT) begin
        if (curr_pt < ctx.rsiz) begin // 更新读取的位置
            if (din_pos == 'd7) begin
                din_pos <= 'd0;
                if (din_col == 'd4) begin
                    din_col <= 'd0;
                    if (din_row == 'd4)
                        din_row <= 'd0;
                    else 
                        din_row <= din_row + 1'b1;
                end
                else 
                    din_col <= din_col + 1'b1;
            end
            else 
                din_pos <= din_pos + 1'b1;
        end
    end
end


// --------------------------------
// KACCAK 产生起始置换信号
// --------------------------------

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        start_perm <= 1'b0;
    else if (state_d == S_UPDATE && state == S_KACCAK)
        start_perm <= 1'b1;
    else if (state_d == S_XOF_PAD && state == S_XOF_KACCAK)
        start_perm <= 1'b1;
    else if (state_d == S_OUT && state == S_OUT_KACCAK)
        start_perm <= 1'b1;
    else 
        start_perm <= 1'b0;
end

// ==========================================================
// XOF 填充数据
// ==========================================================

// --------------------------------
// 填充计数器 确定填充阶段
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        pad_cnt <= 1'b0;
    else if (state == S_XOF_PAD) 
        pad_cnt <= pad_cnt ? 1'b0 : 1'b1;
    else 
        pad_cnt <= 1'b0;
end

// --------------------------------
// 填充具体数据
// --------------------------------
always_comb begin
    if (state == S_XOF_PAD) begin
        case (pad_cnt)
            1'b0 : begin
                pad_din = 8'h1F; // 填充数据的第一个字节
                pad_din_valid = 1'b1;
                pad_din_pos = ctx.pt[2 : 0]; // pt % 8
                pad_din_col = ctx.pt[7 : 3] % 5; // pt / 8 % 5
                pad_din_row = ctx.pt[7 : 3] / 5; // pt / 8 / 5
            end
            1'b1 : begin
                pad_din = 8'h80; // 填充数据的第二个字节
                pad_din_valid = 1'b1;
                case (mdlen)
                    'd16 : begin
                        pad_din_pos = 'd7;
                        pad_din_row = 'd4;
                        pad_din_col = 'd0;
                    end 
                    'd32 : begin
                        pad_din_pos = 'd7;
                        pad_din_row = 'd3;
                        pad_din_col = 'd1;
                    end
                    default: begin
                        pad_din_pos = 'd0;
                        pad_din_row = 'd0;
                        pad_din_col = 'd0;
                    end
                endcase
            end
            default : begin
                pad_din = 'd0;
                pad_din_valid = 1'b0;
                pad_din_pos = 'd0;
                pad_din_col = 'd0;
                pad_din_row = 'd0;
            end
        endcase
    end
end

// ==========================================================
// 输出update & xof 结束信号
// ==========================================================
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        done <= 1'b0;
    else if (state_d == S_XOF_KACCAK && state == S_IDLE)
        done <= 1'b1;
    else 
        done <= 1'b0;
end

// ==========================================================
// 串行输出8 - bit信号
// ==========================================================

// --------------------------------
// 输出数据计数器
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        st_8bit_cnt <= 'd0;
    else if (state == S_OUT) begin
        if (curr_pt < ctx.rsiz) begin
            if (st_8bit_cnt == out_len - 1)
                st_8bit_cnt <= 'd0;
            else 
                st_8bit_cnt <= st_8bit_cnt + 1'b1;
        end
        else 
            st_8bit_cnt <= st_8bit_cnt;
    end
    else 
        st_8bit_cnt <= 'd0;
end

// --------------------------------
// 输出数据与有效信号
// --------------------------------
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        st_8bit <= 'd0;
        st_8bit_valid <= 1'b0;
    end
    else if (state == S_OUT) begin
        if (curr_pt < ctx.rsiz) begin
            case (din_pos)
                'd0 : st_8bit <= ctx.st[din_row][din_col][7  : 0];
                'd1 : st_8bit <= ctx.st[din_row][din_col][15 : 8];
                'd2 : st_8bit <= ctx.st[din_row][din_col][23 : 16];
                'd3 : st_8bit <= ctx.st[din_row][din_col][31 : 24];
                'd4 : st_8bit <= ctx.st[din_row][din_col][39 : 32];
                'd5 : st_8bit <= ctx.st[din_row][din_col][47 : 40];
                'd6 : st_8bit <= ctx.st[din_row][din_col][55 : 48];
                'd7 : st_8bit <= ctx.st[din_row][din_col][63 : 56];
            endcase
            st_8bit_valid <= 1'b1;
        end
    end
    else 
        st_8bit_valid <= 1'b0;
end


// ==========================================================
// 有限状态机(FSM)
// ==========================================================
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        state_d <= S_IDLE;
    else 
        state_d <= state;
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        state <= S_IDLE;
    else begin
        case (state)
            S_IDLE : begin
                if (init) begin
                    ctx.pt <= 'd0;                      // 8-bit 数据指针(计数器)
                    ctx.rsiz <= 200 - (mdlen << 1);
                    ctx.mdlen <= mdlen;
                    state <= S_IDLE;
                end
                if (start)
                    state <= S_UPDATE;
                else if (start_out)
                    state <= S_OUT;
                else
                    state <= S_IDLE;
            end
            S_UPDATE : begin
                if (cnt == din_len - 1 && rd_en) begin
                    state <= S_XOF_PAD;
                    ctx.pt <= curr_pt + 1;
                end
                else if (curr_pt >= ctx.rsiz)
                    state <= S_KACCAK;
                else
                    state <= S_UPDATE;
            end
            S_KACCAK : begin
                if (perm_done) begin
                    state <= S_UPDATE;
                    ctx.pt <= 'd0;
                end
                else 
                    state <= S_KACCAK;
            end
            S_XOF_PAD : begin
                if (pad_cnt == 1'b1)
                    state <= S_XOF_KACCAK;
                else 
                    state <= S_XOF_PAD;
            end
            S_XOF_KACCAK : begin
                if (perm_done) begin
                    ctx.pt <= 'd0;
                    state <= S_IDLE;
                end
                else 
                    state <= S_XOF_KACCAK;
            end
            S_OUT : begin
                if (curr_pt >= ctx.rsiz)
                    state <= S_OUT_KACCAK;
                else if (st_8bit_cnt == out_len - 1) begin
                    state <= S_IDLE;
                    ctx.pt <= curr_pt + 1;
                end
                else 
                    state <= S_OUT;
            end
            S_OUT_KACCAK : begin
                if (perm_done) begin
                    ctx.pt <= 'd0;
                    state <= S_OUT;
                end
                else 
                    state <= S_OUT_KACCAK;
            end
        endcase
    end
end


keccak u_keccak(
	.clk        	( clk                                               ),
	.rstn       	( rstn                                              ),
	.init       	( init                                              ),
	.start_perm 	( start_perm                                        ),
	.perm_done  	( perm_done                                         ),
	.din_valid  	( (state == S_XOF_PAD) ? pad_din_valid  : rd_en     ),
	.din        	( (state == S_XOF_PAD) ? pad_din        : dout      ),
	.din_row    	( (state == S_XOF_PAD) ? pad_din_row    : din_row   ),
	.din_col    	( (state == S_XOF_PAD) ? pad_din_col    : din_col   ),
    .din_pos    	( (state == S_XOF_PAD) ? pad_din_pos    : din_pos   ),
	.st_out     	( ctx.st                                            )
);

sha3_din_fifo u_sha3_din_fifo (
  .clk              (clk),      // input wire clk
  .srst             (~rstn),    // input wire srst
  .din              (din),      // input wire [7 : 0] din
  .wr_en            (din_valid),// input wire wr_en
  .rd_en            (rd_en),    // input wire rd_en
  .dout             (dout),     // output wire [7 : 0] dout
  .full             (full),     // output wire full
  .empty            (empty),    // output wire empty
  .data_count       (data_count)// output wire [8 : 0] data_count
);

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn)
        data_count_d <= 'd0;
    else 
        data_count_d <= data_count;
end

endmodule
