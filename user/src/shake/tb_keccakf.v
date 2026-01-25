`timescale  1ns / 1ps

module tb_keccakf;

// keccakf Parameters
parameter PERIOD  = 20;


// keccakf Inputs
reg   clk                                  = 1 ;
reg   rstn                                 = 0 ;
reg   req                                  = 0 ;
reg   [63 : 0]  st_s                       = 0 ;
reg   st_s_valid                           = 0 ;

// keccakf Outputs
wire  ack                                  ;


initial
begin
    forever #(PERIOD/2)  clk = ~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

initial begin
    repeat (60) @(posedge clk);
    req <= 1'b1;
    @(posedge ack);
    req <= 1'b0;
    @(posedge clk);
    st_s_valid <= 1'b1;

    st_s <= 64'hFFFFFFFFFFFFFFFF;
    @(posedge clk);
    st_s <= 64'h4444555566667777;
    @(posedge clk);
    st_s <= 64'h88889999AAAABBBB;
    @(posedge clk);
    st_s <= 64'hCCCCDDDDEEEEFFFF;

    @(posedge clk);
    st_s <= 64'h0000111122223333;
    @(posedge clk);
    st_s <= 64'h4444555566667777;
    @(posedge clk);
    st_s <= 64'h88889999AAAABBBB;
    @(posedge clk);
    st_s <= 64'hCCCCDDDDEEEEFFFF;

    @(posedge clk);
    st_s <= 64'h0000111122223333;
    @(posedge clk);
    st_s <= 64'h4444555566667777;
    @(posedge clk);
    st_s <= 64'h88889999AAAABBBB;
    @(posedge clk);
    st_s <= 64'hCCCCDDDDEEEEFFFF;

    @(posedge clk);
    st_s <= 64'h0000111122223333;
    @(posedge clk);
    st_s <= 64'h4444555566667777;
    @(posedge clk);
    st_s <= 64'h88889999AAAABBBB;
    @(posedge clk);
    st_s <= 64'hCCCCDDDDEEEEFFFF;

    @(posedge clk);
    st_s <= 64'h0000111122223333;
    @(posedge clk);
    st_s <= 64'h4444555566667777;
    @(posedge clk);
    st_s <= 64'h88889999AAAABBBB;
    @(posedge clk);
    st_s <= 64'hCCCCDDDDEEEEFFFF;

    @(posedge clk);
    st_s <= 64'h0000111122223333;
    @(posedge clk);
    st_s <= 64'h4444555566667777;
    @(posedge clk);
    st_s <= 64'h88889999AAAABBBB;
    @(posedge clk);
    st_s <= 64'hCCCCDDDDEEEEFFFF;

    @(posedge clk);
    st_s <= 64'h0000111122223333;
    @(posedge clk);
    repeat (200) @(posedge clk);
    $finish;
end

keccakf  u_keccakf (
    .clk                     ( clk                  ),
    .rstn                    ( rstn                 ),
    .req                     ( req                  ),
    .st_s                    ( st_s        [63 : 0] ),
    .st_s_valid              ( st_s_valid           ),

    .ack                     ( ack                  )
);


endmodule