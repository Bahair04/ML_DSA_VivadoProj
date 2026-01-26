`timescale  1ns / 1ps

module tb_sha3;

// sha3 Parameters
parameter PERIOD  = 10;


// sha3 Inputs
logic               clk              = 1 ;
logic               rstn             = 0 ;
logic   [7 : 0]     din              = 0 ;
logic               din_valid        = 0 ;
logic   [7 : 0]     din_len          = 0 ;
logic   [7 : 0]     mdlen            = 0 ;
logic               init             = 0 ;
logic               start            = 0 ;
logic               start_out        = 0 ;
logic   [7 : 0]     out_len          = 0 ;

// sha3 Outputs
logic               done             ;
logic   [7 : 0]                 st_8bit ;
logic                           st_8bit_valid ;


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
    mdlen <= 'd16; // shake128
    // mdlen <= 'd32; // shake256
    din_len <= 'd100;
    out_len <= 'd30;
    init <= 1'b1;
    @(posedge clk);
    init <= 1'b0;
    @(posedge clk);
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;
    din_valid <= 1'b1;
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din <= "A"; @(posedge clk);
    din_valid <= 1'b0;
    @(posedge done);
    repeat (10) @(posedge clk);
    start_out <= 1'b1; @(posedge clk);
    start_out <= 1'b0; @(posedge clk);
    repeat (200) @(posedge clk);
    $finish;
end

integer fid;
initial begin
    fid = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/shake/hashout.txt", "w");
end
always @(posedge clk) begin
    if (st_8bit_valid) begin
        $fwrite(fid, "%x", st_8bit);
    end
end

sha3  u_sha3 (
    .clk                        (clk      ),
    .rstn                       (rstn     ),
    .din                        (din             ),
    .din_valid                  (din_valid       ),
    .din_len                    (din_len         ),
    .mdlen                      (mdlen    ),
    .init                       (init            ),
    .start                      (start           ),
    .start_out                  (start_out       ),
    .out_len                    (out_len         ),
    .done                       (done            ),
    .st_8bit                    (st_8bit         ),
    .st_8bit_valid              (st_8bit_valid   )
);

endmodule
