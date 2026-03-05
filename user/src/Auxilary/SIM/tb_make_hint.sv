`timescale  1ns / 1ps

module tb_make_hint;

// make_hint Parameters
parameter PERIOD  = 10;


// make_hint Inputs
logic               clk              = 0 ;
logic               rstn             = 0 ;
logic   [23 : 0]    z                = 0 ;
logic   [23 : 0]    r                = 0 ;
logic               i_valid          = 0 ;

// make_hint Outputs
logic               hint             ;
logic               o_valid          ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

integer fid_write, fid_read0, fid_read1;

initial begin
    fid_write = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Auxilary/output/tb_make_hint_output.txt", "w");
    fid_read0 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Auxilary/SIM/HintSimurNp.txt", "r");
    fid_read1 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Auxilary/SIM/HintSimuzNp.txt", "r");
end

integer i = 0;
logic   signed  [23 : 0]    tmp0, tmp1;
initial begin
    repeat (20) @(posedge clk);
    i_valid <= 1;
    for (i = 0 ; i < 500 ; i = i + 1) begin
        $fscanf(fid_read0, "%d", tmp0);
        $fscanf(fid_read1, "%d", tmp1);
        r <= tmp0;
        z <= tmp1;
        @(posedge clk);
    end
    i_valid <= 0;
    repeat (200) @(posedge clk);
    $finish;
end

always_ff @(posedge clk) begin
    if (o_valid)
        $fwrite(fid_write, "%d\n", hint);
end


make_hint  u_make_hint (
    .clk      ( clk       ),
    .rstn     ( rstn      ),
    .z        ( z         ),
    .r        ( r         ),
    .i_valid  ( i_valid   ),

    .hint     ( hint      ),
    .o_valid  ( o_valid   )
);

endmodule
