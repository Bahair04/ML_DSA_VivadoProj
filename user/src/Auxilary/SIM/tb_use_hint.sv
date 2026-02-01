`timescale  1ns / 1ps

module tb_use_hint;

// use_hint Parameters
parameter PERIOD  = 20;


// use_hint Inputs
logic               clk              = 0 ;
logic               rstn             = 0 ;
logic               h                = 0 ;
logic   [22 : 0]    t                = 0 ;
logic               i_valid          = 0 ;

// use_hint Outputs
logic   [7 : 0]     t1               ;
logic               o_valid          ;


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
    i_valid <= 1'b1;
    t <= 2371444; h <= 0; @(posedge clk);
    t <= 2460085; h <= 0; @(posedge clk);
    t <= 5157799; h <= 0; @(posedge clk);
    t <= 5688843; h <= 0; @(posedge clk);
    t <= 2307437; h <= 1; @(posedge clk);
    t <= 971667; h <= 0; @(posedge clk);
    t <= 8309560; h <= 1; @(posedge clk);
    t <= 6773532; h <= 0; @(posedge clk);
    t <= 7212812; h <= 0; @(posedge clk);
    t <= 6851677; h <= 1; @(posedge clk);
    t <= 550709; h <= 0; @(posedge clk);
    t <= 4681524; h <= 1; @(posedge clk);
    t <= 6556353; h <= 1; @(posedge clk);
    t <= 4791093; h <= 0; @(posedge clk);
    t <= 3501182; h <= 1; @(posedge clk);
    t <= 3886785; h <= 0; @(posedge clk);
    t <= 3905055; h <= 1; @(posedge clk);
    t <= 542656; h <= 1; @(posedge clk);
    t <= 8117659; h <= 0; @(posedge clk);
    t <= 3342955; h <= 0; @(posedge clk);
    t <= 5261336; h <= 0; @(posedge clk);
    t <= 159163; h <= 0; @(posedge clk);
    t <= 5944080; h <= 1; @(posedge clk);
    t <= 5618615; h <= 1; @(posedge clk);
    t <= 6909473; h <= 1; @(posedge clk);
    t <= 8065824; h <= 1; @(posedge clk);
    t <= 3061577; h <= 1; @(posedge clk);
    t <= 198682; h <= 0; @(posedge clk);
    t <= 51795; h <= 1; @(posedge clk);
    t <= 2166755; h <= 1; @(posedge clk);
    t <= 8006175; h <= 0; @(posedge clk);
    t <= 6244389; h <= 1; @(posedge clk);
    t <= 5318; h <= 0; @(posedge clk);
    t <= 8364904; h <= 0; @(posedge clk);
    t <= 3689291; h <= 1; @(posedge clk);
    t <= 6408926; h <= 1; @(posedge clk);
    t <= 3932691; h <= 0; @(posedge clk);
    t <= 5944466; h <= 1; @(posedge clk);
    t <= 6294259; h <= 0; @(posedge clk);
    t <= 2531439; h <= 0; @(posedge clk);
    t <= 5999167; h <= 0; @(posedge clk);
    t <= 6959039; h <= 0; @(posedge clk);
    t <= 4844965; h <= 0; @(posedge clk);
    t <= 5493101; h <= 0; @(posedge clk);
    t <= 6441287; h <= 1; @(posedge clk);
    t <= 6051364; h <= 0; @(posedge clk);
    t <= 173631; h <= 0; @(posedge clk);
    t <= 6004968; h <= 0; @(posedge clk);
    t <= 3286642; h <= 0; @(posedge clk);
    t <= 2979906; h <= 1; @(posedge clk);
    t <= 10185; h <= 1; @(posedge clk);
    t <= 1920736; h <= 0; @(posedge clk);
    t <= 6604633; h <= 1; @(posedge clk);
    t <= 5348537; h <= 1; @(posedge clk);
    t <= 1147891; h <= 1; @(posedge clk);
    t <= 4025894; h <= 0; @(posedge clk);
    t <= 733972; h <= 0; @(posedge clk);
    t <= 1404636; h <= 1; @(posedge clk);
    t <= 1463857; h <= 1; @(posedge clk);
    t <= 3973426; h <= 1; @(posedge clk);
    t <= 2399173; h <= 1; @(posedge clk);
    t <= 1278204; h <= 0; @(posedge clk);
    t <= 3812553; h <= 0; @(posedge clk);
    t <= 4113961; h <= 0; @(posedge clk);
    t <= 1196877; h <= 0; @(posedge clk);
    t <= 2588181; h <= 0; @(posedge clk);
    t <= 7975523; h <= 1; @(posedge clk);
    t <= 1855550; h <= 0; @(posedge clk);
    t <= 1089744; h <= 1; @(posedge clk);
    t <= 1194892; h <= 0; @(posedge clk);
    t <= 5685304; h <= 1; @(posedge clk);
    t <= 6977975; h <= 1; @(posedge clk);
    t <= 1615411; h <= 0; @(posedge clk);
    t <= 2182168; h <= 0; @(posedge clk);
    t <= 1465218; h <= 1; @(posedge clk);
    t <= 4199031; h <= 1; @(posedge clk);
    t <= 7966871; h <= 0; @(posedge clk);
    t <= 6419460; h <= 1; @(posedge clk);
    t <= 1943898; h <= 1; @(posedge clk);
    t <= 4736669; h <= 1; @(posedge clk);
    t <= 6931403; h <= 1; @(posedge clk);
    t <= 497697; h <= 0; @(posedge clk);
    t <= 4762271; h <= 1; @(posedge clk);
    t <= 2532482; h <= 1; @(posedge clk);
    t <= 6807301; h <= 0; @(posedge clk);
    t <= 6293241; h <= 1; @(posedge clk);
    t <= 2236289; h <= 0; @(posedge clk);
    t <= 2758788; h <= 0; @(posedge clk);
    t <= 3364931; h <= 1; @(posedge clk);
    t <= 3832262; h <= 1; @(posedge clk);
    t <= 1751214; h <= 1; @(posedge clk);
    t <= 1711288; h <= 1; @(posedge clk);
    t <= 1581631; h <= 1; @(posedge clk);
    t <= 4677059; h <= 1; @(posedge clk);
    t <= 7937406; h <= 0; @(posedge clk);
    t <= 4652361; h <= 1; @(posedge clk);
    t <= 1683212; h <= 1; @(posedge clk);
    t <= 2725718; h <= 0; @(posedge clk);
    t <= 5929501; h <= 1; @(posedge clk);
    t <= 3467274; h <= 0; @(posedge clk);
    i_valid <= 1'b0;
    
    repeat (200) @(posedge clk);
    $finish;
end

integer fid1;
initial begin
    fid1 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Auxilary/output/tb_use_hint_output.txt", "w");
    $fwrite(fid1, "[");
end

integer i = 0;
always_ff @(posedge clk) begin
    if (o_valid) begin
        $fwrite(fid1, "%0d, ", t1);
    end
end

use_hint  u_use_hint (
    .clk      ( clk       ),
    .rstn     ( rstn      ),
    .h        ( h         ),
    .t        ( t         ),
    .i_valid  ( i_valid   ),

    .t1       ( t1        ),
    .o_valid  ( o_valid   )
);

endmodule