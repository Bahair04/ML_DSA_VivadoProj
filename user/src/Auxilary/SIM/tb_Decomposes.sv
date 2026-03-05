`timescale  1ns / 1ps

module tb_Decomposes;

// Decomposes Parameters
parameter PERIOD  = 10;


// Decomposes Inputs
logic                       clk      = 0 ;
logic                       rstn     = 0 ;
logic   signed  [24 : 0]    r        = 0 ;
logic                       r_valid  = 0 ;

// Decomposes Outputs
logic           [7 : 0]     r1       ;
logic                       r1_valid ;
logic   signed  [18 : 0]    r0       ;
logic                       r0_valid ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

integer fid_read, fid_write0, fid_write1;

initial begin
    fid_read = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Auxilary/SIM/Decompose_input.txt", "r");
    fid_write0 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Auxilary/output/tb_decompose_output_t0.txt", "w");
    fid_write1 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Auxilary/output/tb_decompose_output_t1.txt", "w");
end

integer i = 0;
logic   signed  [24 : 0]    tmp;
initial begin
    repeat (20) @(posedge clk);
    r_valid <= 1;
    for (i = 0 ; i < 400 ; i = i + 1) begin
        $fscanf(fid_read, "%d", tmp);
        r <= tmp;
        @(posedge clk);
    end
    r_valid <= 0;
    repeat (200) @(posedge clk);
    $finish;
end

always_ff @(posedge clk) begin
    if (r0_valid)
        $fwrite(fid_write0, "%d\n", r0);
    if (r1_valid)
        $fwrite(fid_write1, "%d\n", r1);
end

Decomposes2  u_Decomposes (
    .clk       ( clk        ),
    .rstn      ( rstn       ),
    .r         ( r          ),
    .r_valid   ( r_valid    ),

    .r1        ( r1         ),
    .r1_valid  ( r1_valid   ),
    .r0        ( r0         ),
    .r0_valid  ( r0_valid   )
);

endmodule