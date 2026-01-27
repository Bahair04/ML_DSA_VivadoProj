`timescale  1ns / 1ps

module tb_shake256;

// _h Parameters
parameter PERIOD  = 10;


// _h Inputs
reg   clk                                  = 0 ;
reg   rstn                                 = 0 ;
reg   [7 : 0]  din                         = 0 ;
reg   din_valid                            = 0 ;
reg   init                                 = 0 ;
reg   start                                = 0 ;

// _h Outputs
wire  done_out                             ;
wire  [63 : 0]  st_64bit                     ;
wire  st_64bit_valid                        ;


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
    din_valid <= 1'b1;
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk); din <= "A"; @(posedge clk); din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din_valid <= 1'b0;
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;
    @(posedge done_out);
    $finish;
end

integer fid;
initial begin
    fid = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Hash/output/tb_shake256_output.txt", "w");
end

always @(posedge clk) begin
    if (st_64bit_valid)
        $fwrite(fid, "%x", st_64bit);
end

shake256  u_shake256 (
    .clk                     ( clk                    ),
    .rstn                    ( rstn                   ),
    .din                     ( din            [7 : 0] ),
    .din_valid               ( din_valid              ),
    .init                    ( init                   ),
    .start                   ( start                  ),

    .done_out                ( done_out               ),
    .st_64bit                 ( st_64bit        [63 : 0] ),
    .st_64bit_valid           ( st_64bit_valid          )
);

endmodule