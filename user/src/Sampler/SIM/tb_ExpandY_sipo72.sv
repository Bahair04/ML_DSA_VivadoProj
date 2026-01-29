`timescale  1ns / 1ps

module tb_ExpandY_sipo72;

// ExpandA_sipo Parameters
parameter PERIOD  = 20;


// ExpandA_sipo Inputs
logic               clk              = 0 ;
logic               rstn             = 0 ;
logic               init             = 0 ;
logic   [63 : 0]    st_64bit         = 0 ;
logic               st_64bit_valid   = 0 ;

// ExpandA_sipo Outputs
logic   [71 : 0]    sipo_o           ;
logic               sipo_o_valid     ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

initial begin
    repeat (60) @(posedge clk);
    init <= 1'b1;
    @(posedge clk);
    init <= 1'b0;

    st_64bit_valid <= 1'b1;
    st_64bit <= 64'h0000000000000000; @(posedge clk);
    st_64bit <= 64'h0011111111111111; @(posedge clk);
    st_64bit <= 64'h1111222222222222; @(posedge clk);

    st_64bit <= 64'h2222223333333333; @(posedge clk);
    st_64bit <= 64'h3333333344444444; @(posedge clk);
    st_64bit <= 64'h4444444444555555; @(posedge clk);
    
    st_64bit <= 64'h5555555555556666; @(posedge clk);
    st_64bit <= 64'h6666666666666677; @(posedge clk);
    st_64bit <= 64'h7777777777777777; @(posedge clk);
    
    st_64bit <= 64'h0000000000000000; @(posedge clk);
    st_64bit <= 64'h0011111111111111; @(posedge clk);
    st_64bit <= 64'h1111222222222222; @(posedge clk);

    st_64bit <= 64'h2222223333333333; @(posedge clk);
    st_64bit <= 64'h3333333344444444; @(posedge clk);
    st_64bit <= 64'h4444444444555555; @(posedge clk);
    
    st_64bit <= 64'h5555555555556666; @(posedge clk);
    st_64bit <= 64'h6666666666666677; @(posedge clk);
    st_64bit <= 64'h7777777777777777; @(posedge clk);

    st_64bit <= 64'h0000000000000000; @(posedge clk);
    st_64bit <= 64'h0011111111111111; @(posedge clk);
    st_64bit <= 64'h1111222222222222; @(posedge clk);

    st_64bit <= 64'h2222223333333333; @(posedge clk);
    st_64bit <= 64'h3333333344444444; @(posedge clk);
    st_64bit <= 64'h4444444444555555; @(posedge clk);
    
    st_64bit <= 64'h5555555555556666; @(posedge clk);
    st_64bit <= 64'h6666666666666677; @(posedge clk);
    st_64bit <= 64'h7777777777777777; @(posedge clk);
 
    st_64bit_valid <= 1'b0;
    
    repeat (200) @(posedge clk);
    $finish;
end


ExpandY_sipo72  u_ExpandY_sipo72 (
    .clk             ( clk              ),
    .rstn            ( rstn             ),
    .init            ( init             ),
    .st_64bit        ( st_64bit         ),
    .st_64bit_valid  ( st_64bit_valid   ),

    .sipo_o          ( sipo_o           ),
    .sipo_o_valid    ( sipo_o_valid     )
);
endmodule