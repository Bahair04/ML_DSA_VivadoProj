module sha3(
    input       wire                clk,
    input       wire                rstn,
    input       wire                req,
    output      reg                 ack,
    input       wire    [7 : 0]     mdlen,      // 哈希输出字节数
    input       wire    [7 : 0]     q_s,        // 单字节数据
    input       wire                q_s_valid,  // 单字节数据有效标志
    input       wire    [7 : 0]     q_s_len     // 输入单字节数


);

localparam                  IDLE = 'd0;
localparam                  ACK = 'd1;
localparam                  STORE = 'd2;
localparam                  UPDATE = 'd3;

reg     [9 : 0]             state;

reg     [63 : 0]            q[4 : 0] [4 : 0];
reg     [7 : 0]             rsiz;
reg     [7 : 0]             pt;
reg     [7 : 0]             q_s_cnt;        // 数据字节计数
reg                         q_s_comb_cnt;   // 数据拼接计数（将单字节拼接成8字节）
reg                         q_s_comb_valid; // 数据拼接有效标志
reg     [63 : 0]            q_comb;
reg     [7 : 0]             q_comb_row;     // 拼接数据行计数
reg     [7 : 0]             q_comb_col;     // 拼接数据列计数

always @(posedge clk or negedge rstn) begin
    if (!rstn)
        state <= IDLE;
    else begin
        case (state)
            IDLE : begin
                if (req)
                    state <= ACK;
                else 
                    state <= IDLE;
            end
            ACK : begin
                if (req == 1'b0 && ack == 1'b1)
                    state <= STORE;
                else 
                    state <= ACK;
            end
            STORE : begin
                if (q_s_cnt == q_s_len - 1 && q_s_valid)
                    state <= UPDATE;
                else 
                    state <= STORE;
            end
        endcase
    end
end

//* 握手过程
always @(posedge clk or negedge rstn) begin
    if (!rstn)
        ack <= 1'b0;
    else if (state == ACK) begin
        if (req)
            ack <= 1'b1;
        else 
            ack <= 1'b0;
    end
    else 
        ack <= 1'b0;
end

//* 对输入的单字节数据计数
always @(posedge clk or negedge rstn) begin
    if (!rstn)
        q_s_cnt <= 'd0;
    else if (state == STORE) begin
        if (q_s_valid) begin
            if (q_s_cnt == q_s_len - 1)
                q_s_cnt <= 'd0;
            else 
                q_s_cnt <= q_s_cnt + 1'b1;
        end
        else
            q_s_cnt <= q_s_cnt;
    end
    else 
        q_s_cnt <= 'd0;
end

//* 对输入的单字节数据进行拼接 按小端序 先输入的在最低位
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        q_s_comb_cnt <= 'd0;
        q_s_comb_valid <= 1'b0;
        q_comb <= 'd0;
    end
    else if (state == STORE) begin
        if (q_s_valid) begin
            q_comb <= {q_s, q_comb[63 : 8]}; // 小端序 先到达的在低位
            if (q_s_comb_cnt == 'd7)
                q_s_comb_cnt <= 'd0;
            else 
                q_s_comb_cnt <= q_s_comb_cnt + 1'b1;
            if (q_s_comb_cnt == 'd7)
                q_s_comb_valid <= 1'b1;
            else 
                q_s_comb_valid <= 1'b0;
        end
        else begin
            q_s_comb_cnt <= q_s_comb_cnt;
            q_s_comb_valid <= q_s_comb_valid;
            q_comb <= q_comb;
        end
    end
    else begin
        q_s_comb_cnt <= 'd0;
        q_s_comb_valid <= 1'b0;
        q_comb <= 'd0;
    end
end

//* 行列计数 用于记录存入64位数据的位置
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        q_comb_row <= 'd0;
        q_comb_col <= 'd0;
    end
    else if (state == STORE) begin
        if (q_s_comb_valid) begin
            if (q_comb_col == 'd4) begin
                if (q_comb_row == 'd4)
                    q_comb_row <= q_comb_row + 1'b1;
                else 
                    q_comb_row <= 'd0;
                q_comb_col <= 'd0;
            end
            else 
                q_comb_col <= q_comb_col + 1'b1;
        end
        else begin
            q_comb_row <= q_comb_row;
            q_comb_col <= q_comb_col;
        end
    end
    else begin
        q_comb_row <= 'd0;
        q_comb_col <= 'd0;
    end
end

always @(posedge clk or negedge rstn) begin : init_block
    integer i, j;
    if (!rstn) begin // 数据复位
        rsiz <= 'd0;
        pt <= 'd0;
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                q[i][j] <= 'd0;
            end
        end
    end
    else if (state == ACK) begin // 握手应答过程
            rsiz <= 200 - {mdlen, 1'b0};
            pt <= 'd0;
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    q[i][j] <= 'd0;
                end
            end
        end 
    else if (state == STORE) begin
        if (q_s_comb_valid) // 赋值拼接的64位数据
            q[q_comb_row][q_comb_col] <= q[q_comb_row][q_comb_col] ^ q_comb;
        else if (q_s_len[2 : 0] && q_s_cnt == q_s_len - 1'b1 && q_s_valid) begin // 如果q_s_len不是8的整数倍 就会超出一部分 这部分单独赋值
            case (q_s_len[2 : 0])
                'd1 : q[q_comb_row][q_comb_col] <= q[q_comb_row][q_comb_col] ^ {56'd0, q_s};
                'd2 : q[q_comb_row][q_comb_col] <= q[q_comb_row][q_comb_col] ^ {48'd0, q_s, q_comb[63 : 56]};
                'd3 : q[q_comb_row][q_comb_col] <= q[q_comb_row][q_comb_col] ^ {40'd0, q_s, q_comb[63 : 48]};
                'd4 : q[q_comb_row][q_comb_col] <= q[q_comb_row][q_comb_col] ^ {32'd0, q_s, q_comb[63 : 40]};
                'd5 : q[q_comb_row][q_comb_col] <= q[q_comb_row][q_comb_col] ^ {24'd0, q_s, q_comb[63 : 32]};
                'd6 : q[q_comb_row][q_comb_col] <= q[q_comb_row][q_comb_col] ^ {16'd0, q_s, q_comb[63 : 24]};
                'd7 : q[q_comb_row][q_comb_col] <= q[q_comb_row][q_comb_col] ^ {8'd0,  q_s, q_comb[63 : 16]};
                default : q[q_comb_row][q_comb_col] <= q[q_comb_row][q_comb_col];
            endcase
        end
    end 
end

endmodule
