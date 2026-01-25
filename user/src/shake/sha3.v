module sha3(
    input       wire                clk,
    input       wire                rstn,
    input       wire                req,
    output      reg                 ack,
    input       wire    [7 : 0]     mdlen,
    input       wire    [7 : 0]     


);

localparam                  IDLE = 'd0;
localparam                  ACK = 'd1;
localparam                  UPDATE = 'd2;

reg     [9 : 0]     state;

reg     [63 : 0]        q[4 : 0] [4 : 0];
reg     [7 : 0]         rsiz;
reg     [7 : 0]         pt;

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
                    state <= UPDATE;
                else 
                    state <= ACK;
            end
        endcase
    end
end

always @(posedge clk or negedge rstn) begin : init_block
    integer i, j;
    if (!rstn) begin
        rsiz <= 'd0;
        pt <= 'd0;
        for (i = 0; i < 5; i = i + 1) begin
            for (j = 0; j < 5; j = j + 1) begin
                q[i][j] <= 'd0;
            end
        end
    end
    else if (state == INIT) begin
            rsiz <= 200 - {mdlen, 1'b0};
            pt <= 'd0;
            for (i = 0; i < 5; i = i + 1) begin
                for (j = 0; j < 5; j = j + 1) begin
                    q[i][j] <= 'd0;
                end
            end
        end 

end

endmodule
