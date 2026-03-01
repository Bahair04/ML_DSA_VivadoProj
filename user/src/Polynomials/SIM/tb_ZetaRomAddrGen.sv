//~ `New testbench
`timescale  1ns / 1ps

module tb_ZetaRomAddrGen;

// ZetaRomAddrGen Parameters
parameter PERIOD  = 10;


// ZetaRomAddrGen Inputs
logic                   clk          = 1 ;
logic                   rstn         = 0 ;
logic                   mode_config  = 0 ;
logic                   rom_request  = 0 ;

// ZetaRomAddrGen Outputs
logic   [7 : 0]         rom_addr_out1 ;
logic   [7 : 0]         rom_addr_out2 ;
logic   [7 : 0]         rom_addr_out3 ;
logic                   output_finish ;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

initial begin
    repeat (10) @(posedge clk);
    mode_config <= 0;
    @(posedge clk);
    rom_request <= 1;
    @(posedge output_finish);
    rom_request <= 0;
    repeat (10) @(posedge clk);
    mode_config <= 1;
    @(posedge clk);
    rom_request <= 1;
    @(posedge output_finish);
    rom_request <= 0;
    repeat (10) @(posedge clk);
    $finish;
end

integer fid1, fid2;
initial begin
    fid1 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/ZetaRomAddrGen0.txt", "w");
    fid2 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/ZetaRomAddrGen1.txt", "w");
end

always_ff @(posedge clk or negedge rstn) begin
    if (rom_request) begin
        if (mode_config == 0)
            $fwrite(fid1, "%d, %d, %d\n", rom_addr_out1, rom_addr_out2, rom_addr_out3);
        else 
            $fwrite(fid2, "%d, %d, %d\n", rom_addr_out1, rom_addr_out2, rom_addr_out3);
    end
end

ZetaRomAddrGen  u_ZetaRomAddrGen (
    .clk            ( clk             ),    
    .rstn           ( rstn            ),    
    .mode_config    ( mode_config     ),    
    .rom_request    ( rom_request     ),    

    .rom_addr_out1  ( rom_addr_out1   ),    
    .rom_addr_out2  ( rom_addr_out2   ),    
    .rom_addr_out3  ( rom_addr_out3   ),
    .output_finish  ( output_finish   )     
);


endmodule