`timescale  1ns / 1ps

module tb_ExpandA_sipo120;

// ExpandA_sipo Parameters
parameter PERIOD  = 20;


// ExpandA_sipo Inputs
logic               clk              = 0 ;
logic               rstn             = 0 ;
logic               init             = 0 ;
logic   [63 : 0]    st_64bit         = 0 ;
logic               st_64bit_valid   = 0 ;

// ExpandA_sipo Outputs
logic   [119 : 0]   sipo_o           ;
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
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);

    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
    
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
    
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
    
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
    
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
    
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);

    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
    
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
    
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
    
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
    
    st_64bit <= 64'h5444333222111000; @(posedge clk);
    st_64bit <= 64'hAA99988877766655; @(posedge clk);
    st_64bit <= 64'hFFFEEEDDDCCCBBBA; @(posedge clk);
 
    st_64bit_valid <= 1'b0;
    
    repeat (200) @(posedge clk);
    $finish;
end


ExpandA_sipo120  u_ExpandA_sipo120 (
    .clk             ( clk              ),
    .rstn            ( rstn             ),
    .init            ( init             ),
    .st_64bit        ( st_64bit         ),
    .st_64bit_valid  ( st_64bit_valid   ),

    .sipo_o          ( sipo_o           ),
    .sipo_o_valid    ( sipo_o_valid     )
);
endmodule