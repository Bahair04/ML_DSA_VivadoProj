`timescale  1ns / 1ps

module tb_decompose;

// decompose Parameters
parameter PERIOD  = 10;


// decompose Inputs
logic               clk              = 0 ;
logic               rstn             = 0 ;
logic   [22 : 0]    t                = 0 ;
logic               t_valid          = 0 ;

// decompose Outputs
logic    [7 : 0]     o_t1             ;
logic               t1_valid         ;
logic   signed [18 : 0]    o_t0             ;
logic               t0_valid         ;


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
    
    t_valid <= 1'b1;
    t <= 2371444; @(posedge clk);
    t <= 2460085; @(posedge clk);
    t <= 5157799; @(posedge clk);
    t <= 5688843; @(posedge clk);
    t <= 2307437; @(posedge clk);
    t <= 971667; @(posedge clk);
    t <= 8309560; @(posedge clk);
    t <= 6773532; @(posedge clk);
    t <= 7212812; @(posedge clk);
    t <= 6851677; @(posedge clk);
    t <= 550709; @(posedge clk);
    t <= 4681524; @(posedge clk);
    t <= 6556353; @(posedge clk);
    t <= 4791093; @(posedge clk);
    t <= 3501182; @(posedge clk);
    t <= 3886785; @(posedge clk);
    t <= 3905055; @(posedge clk);
    t <= 542656; @(posedge clk);
    t <= 8117659; @(posedge clk);
    t <= 3342955; @(posedge clk);
    t <= 5261336; @(posedge clk);
    t <= 159163; @(posedge clk);
    t <= 5944080; @(posedge clk);
    t <= 5618615; @(posedge clk);
    t <= 6909473; @(posedge clk);
    t <= 8065824; @(posedge clk);
    t <= 3061577; @(posedge clk);
    t <= 198682; @(posedge clk);
    t <= 51795; @(posedge clk);
    t <= 2166755; @(posedge clk);
    t <= 8006175; @(posedge clk);
    t <= 6244389; @(posedge clk);
    t <= 5318; @(posedge clk);
    t <= 8364904; @(posedge clk);
    t <= 3689291; @(posedge clk);
    t <= 6408926; @(posedge clk);
    t <= 3932691; @(posedge clk);
    t <= 5944466; @(posedge clk);
    t <= 6294259; @(posedge clk);
    t <= 2531439; @(posedge clk);
    t <= 5999167; @(posedge clk);
    t <= 6959039; @(posedge clk);
    t <= 4844965; @(posedge clk);
    t <= 5493101; @(posedge clk);
    t <= 6441287; @(posedge clk);
    t <= 6051364; @(posedge clk);
    t <= 173631; @(posedge clk);
    t <= 6004968; @(posedge clk);
    t <= 3286642; @(posedge clk);
    t <= 2979906; @(posedge clk);
    t <= 10185; @(posedge clk);
    t <= 1920736; @(posedge clk);
    t <= 6604633; @(posedge clk);
    t <= 5348537; @(posedge clk);
    t <= 1147891; @(posedge clk);
    t <= 4025894; @(posedge clk);
    t <= 733972; @(posedge clk);
    t <= 1404636; @(posedge clk);
    t <= 1463857; @(posedge clk);
    t <= 3973426; @(posedge clk);
    t <= 2399173; @(posedge clk);
    t <= 1278204; @(posedge clk);
    t <= 3812553; @(posedge clk);
    t <= 4113961; @(posedge clk);
    t <= 1196877; @(posedge clk);
    t <= 2588181; @(posedge clk);
    t <= 7975523; @(posedge clk);
    t <= 1855550; @(posedge clk);
    t <= 1089744; @(posedge clk);
    t <= 1194892; @(posedge clk);
    t <= 5685304; @(posedge clk);
    t <= 6977975; @(posedge clk);
    t <= 1615411; @(posedge clk);
    t <= 2182168; @(posedge clk);
    t <= 1465218; @(posedge clk);
    t <= 4199031; @(posedge clk);
    t <= 7966871; @(posedge clk);
    t <= 6419460; @(posedge clk);
    t <= 1943898; @(posedge clk);
    t <= 4736669; @(posedge clk);
    t <= 6931403; @(posedge clk);
    t <= 497697; @(posedge clk);
    t <= 4762271; @(posedge clk);
    t <= 2532482; @(posedge clk);
    t <= 6807301; @(posedge clk);
    t <= 6293241; @(posedge clk);
    t <= 2236289; @(posedge clk);
    t <= 2758788; @(posedge clk);
    t <= 3364931; @(posedge clk);
    t <= 3832262; @(posedge clk);
    t <= 1751214; @(posedge clk);
    t <= 1711288; @(posedge clk);
    t <= 1581631; @(posedge clk);
    t <= 4677059; @(posedge clk);
    t <= 7937406; @(posedge clk);
    t <= 4652361; @(posedge clk);
    t <= 1683212; @(posedge clk);
    t <= 2725718; @(posedge clk);
    t <= 5929501; @(posedge clk);
    t <= 3467274; @(posedge clk);
    
    t_valid <= 1'b0;
    repeat (200) @(posedge clk);
    $finish;
end

integer fid1, fid2;
initial begin
    fid1 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Auxilary/output/tb_decompose_output_t1.txt", "w");
    fid2 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Auxilary/output/tb_decompose_output_t0.txt", "w");
    $fwrite(fid1, "[");
    $fwrite(fid2, "[");
end

integer i = 0;
always_ff @(posedge clk) begin
    if (t1_valid) begin
        $fwrite(fid1, "%0d, ", o_t1);
        $fwrite(fid2, "%0d, ", o_t0);
    end
end


decompose  u_decompose (
    .clk       ( clk        ),
    .rstn      ( rstn       ),
    .t         ( t          ),
    .t_valid   ( t_valid    ),

    .o_t1      ( o_t1       ),
    .t1_valid  ( t1_valid   ),
    .o_t0      ( o_t0       ),
    .t0_valid  ( t0_valid   )
);

endmodule