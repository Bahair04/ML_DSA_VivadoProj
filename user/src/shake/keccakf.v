module keccakf(
    input   wire                clk,
    input   wire                rstn,
    input   wire                req,
    output  reg                 ack,
    input   wire    [63 : 0]    st_s,
    input   wire                st_s_valid
);

localparam                  IDLE = 'd0;
localparam                  ACK = 'd1;
localparam                  STORE = 'd2;
localparam                  THETA_BC = 'd3;
localparam                  THETA_UPDATE = 'd4;
localparam                  CHI_IOTA_UPDATE = 'd5;

reg     [9 : 0]             state; // 状态机变量
reg     [4 : 0]             st_row; // st行计数
reg     [4 : 0]             st_col; // st列计数
reg     [63 : 0]            st [0 : 4] [0 : 4];
reg     [63 : 0]            bc [0 : 4];
reg     [63 : 0]            st_after_rho_pi [0 : 4] [0 : 4];
reg     [63 : 0]            st_after_chi [0 : 4] [0 : 4];
reg     [4 : 0]             global_round;

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        state <= IDLE;
        global_round <= 'd0;
    end
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
                if (st_row == 'd4 && st_col == 'd4 && st_s_valid)
                    state <= THETA_BC;
                else 
                    state <= STORE;
            end
            THETA_BC : begin
                state <= THETA_UPDATE;
            end
            THETA_UPDATE : begin
                state <= CHI_IOTA_UPDATE;
            end
            CHI_IOTA_UPDATE : begin
                if (global_round == 'd23) begin
                    state <= IDLE;
                    global_round <= 'd0;
                end
                else begin
                    state <= THETA_BC;
                    global_round <= global_round + 1'b1;
                end
            end
        endcase
    end
end

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

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        st_row <= 'd0;
        st_col <= 'd0;
    end
    else if (state == STORE) begin
        if (st_s_valid) begin
            if (st_col == 'd4) begin
                st_col <= 'd0;
                if (st_row == 'd4)
                    st_row <= 'd0;
                else 
                    st_row <= st_row + 1'b1;
            end     
            else 
                st_col <= st_col + 1'b1;
        end
        else begin
            st_col <= st_col;
            st_row <= st_row;
        end
    end
    else begin
        st_row <= 'd0;
        st_col <= 'd0;
    end
end

function [5:0] keccakf_rotc;
    input [2:0] x_idx, y_idx;
    begin
        case({x_idx, y_idx})
            {3'd0, 3'd0}: keccakf_rotc = 0;
            {3'd1, 3'd0}: keccakf_rotc = 1;
            {3'd2, 3'd0}: keccakf_rotc = 62;
            {3'd3, 3'd0}: keccakf_rotc = 28;
            {3'd4, 3'd0}: keccakf_rotc = 27;
            {3'd0, 3'd1}: keccakf_rotc = 36;
            {3'd1, 3'd1}: keccakf_rotc = 44;
            {3'd2, 3'd1}: keccakf_rotc = 6;
            {3'd3, 3'd1}: keccakf_rotc = 55;
            {3'd4, 3'd1}: keccakf_rotc = 20;
            {3'd0, 3'd2}: keccakf_rotc = 3;
            {3'd1, 3'd2}: keccakf_rotc = 10;
            {3'd2, 3'd2}: keccakf_rotc = 43;
            {3'd3, 3'd2}: keccakf_rotc = 25;
            {3'd4, 3'd2}: keccakf_rotc = 39;
            {3'd0, 3'd3}: keccakf_rotc = 41;
            {3'd1, 3'd3}: keccakf_rotc = 45;
            {3'd2, 3'd3}: keccakf_rotc = 15;
            {3'd3, 3'd3}: keccakf_rotc = 21;
            {3'd4, 3'd3}: keccakf_rotc = 8;
            {3'd0, 3'd4}: keccakf_rotc = 18;
            {3'd1, 3'd4}: keccakf_rotc = 2;
            {3'd2, 3'd4}: keccakf_rotc = 61;
            {3'd3, 3'd4}: keccakf_rotc = 56;
            {3'd4, 3'd4}: keccakf_rotc = 14;
            default:      keccakf_rotc = 0;
        endcase
    end
endfunction

function [63 : 0] keccakf_rndc;
    input [4 : 0]   global_round;
    begin
        case(global_round)
            5'd0 : keccakf_rndc = 64'h0000000000000001;
            5'd1 : keccakf_rndc = 64'h0000000000008082;
            5'd2 : keccakf_rndc = 64'h800000000000808a;
            5'd3 : keccakf_rndc = 64'h8000000080008000;
            5'd4 : keccakf_rndc = 64'h000000000000808b;
            5'd5 : keccakf_rndc = 64'h0000000080000001;
            5'd6 : keccakf_rndc = 64'h8000000080008081;
            5'd7 : keccakf_rndc = 64'h8000000000008009;
            5'd8 : keccakf_rndc = 64'h000000000000008a;
            5'd9 : keccakf_rndc = 64'h0000000000000088;
            5'd10: keccakf_rndc = 64'h0000000080008009;
            5'd11: keccakf_rndc = 64'h000000008000000a;
            5'd12: keccakf_rndc = 64'h000000008000808b;
            5'd13: keccakf_rndc = 64'h800000000000008b;
            5'd14: keccakf_rndc = 64'h8000000000008089;
            5'd15: keccakf_rndc = 64'h8000000000008003;
            5'd16: keccakf_rndc = 64'h8000000000008002;
            5'd17: keccakf_rndc = 64'h8000000000000080;
            5'd18: keccakf_rndc = 64'h000000000000800a;
            5'd19: keccakf_rndc = 64'h800000008000000a;
            5'd20: keccakf_rndc = 64'h8000000080008081;
            5'd21: keccakf_rndc = 64'h8000000000008080;
            5'd22: keccakf_rndc = 64'h0000000080000001;
            5'd23: keccakf_rndc = 64'h8000000080008008;
            default: keccakf_rndc = 64'h0000000000000000; // 防止产生Latch，虽然理论上跑不到这里
        endcase
    end
endfunction

always @(posedge clk or negedge rstn) begin : bc_block
    integer i, j;
    reg     [63 : 0]                t;
    if (!rstn) begin
        for (i = 0 ; i < 5 ; i = i + 1)
            bc[i] <= 'd0;
        for (i = 0 ; i < 5 ; i = i + 1)
            for (j = 0 ; j < 5 ; j = j + 1)
                st[i][j] <= 'd0;
    end
    else if (state == STORE && st_s_valid) begin
        st[st_row][st_col] <= st_s;
    end
    else if (state == THETA_BC) begin
        for (i = 0 ; i < 5 ; i = i + 1)
            bc[i] <= st[0][i] ^ st[1][i] ^ st[2][i] ^ st[3][i] ^ st[4][i];
    end
    else if (state == THETA_UPDATE) begin
        for (i = 0 ; i < 5 ; i = i + 1) begin
            t = bc[(i + 4) % 5] ^ ((bc[(i + 1) % 5] << 1) | (bc[(i + 1) % 5] >> 63));
            for (j = 0 ; j < 5 ; j = j + 1)
                st[j][i] <= st[j][i] ^ t;
        end
    end
    else if (state == CHI_IOTA_UPDATE) begin
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                if (i == 0 && j == 0) begin
                    st[i][j] <= st_after_chi[i][j] ^ keccakf_rndc(global_round);
                end
                else begin
                    st[i][j] <= st_after_chi[i][j];
                end
            end
        end
    end
end

always @(*) begin : st_after_rho_pi_block
    integer i, j;
    reg [2 : 0] new_x;
    reg [2 : 0] new_y;
    reg [5 : 0] r;
    for (i = 0 ; i < 5 ; i = i + 1) begin
        for (j = 0 ; j < 5 ; j = j + 1) begin
            
            new_x = i;
            new_y = (2 * j + 3 * i) % 5;
            r = keccakf_rotc(j, i);

            if (r == 0)
                st_after_rho_pi[new_y][new_x] = st[i][j];
            else 
                st_after_rho_pi[new_y][new_x] = (st[i][j] << r) | (st[i][j] >> (64 - r));
        end
    end
end

always @(*) begin : chi_block
    integer i, j;
    for (i = 0; i < 5; i = i + 1) begin
        for (j = 0; j < 5; j = j + 1) begin
            st_after_chi[i][j] = st_after_rho_pi[i][j] ^ 
                                 ((~st_after_rho_pi[i][(j + 1) % 5]) & st_after_rho_pi[i][(j + 2) % 5]);
        end
    end
end

endmodule
