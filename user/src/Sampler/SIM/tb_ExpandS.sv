`timescale  1ns / 1ps

module tb_ExpandS;

// ExpandS Parameters
parameter PERIOD  = 10;


// ExpandS Inputs
logic   clk                                  = 0 ;
logic   rstn                                 = 0 ;
logic   [511 : 0]   rho_prime        = 0 ;
logic               start_expand     = 0 ;
logic               done             = 0 ;
logic               done_out         = 0 ;
logic   [63 : 0]    st_64bit         = 0 ;
logic               st_64bit_valid   = 0 ;

// ExpandS Outputs
logic   [91 : 0]    coeff            ;
logic               coeff_valid      ;
logic               expand_done      ;
logic   [3 : 0]     nouce            ;
logic   [7 : 0]     dout             ;
logic               dout_valid       ;
logic   [31 : 0]    dout_len         ;
logic   [7 : 0]     mdlen            ;
logic               init             ;
logic               start            ;
logic               start_out        ;
logic   [31 : 0]    out_len          ;


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
    rho_prime <= 512'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    @(posedge clk);
    start_expand <= 1'b1;
    @(posedge clk);
    start_expand <= 1'b0;
    @(posedge expand_done);
    repeat (20) @(posedge clk);
    $finish;
end

integer fid;
initial begin
    fid = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Sampler/output/tb_ExpandB_output.txt", "w");
end

always_ff @(posedge clk) begin
    if (st_64bit_valid)
        $fwrite(fid, "%x", st_64bit);
end

ExpandS  u_ExpandS (
    .clk             ( clk                                  ),
    .rstn            ( rstn                                 ),
    .rho_prime       ( rho_prime        ),
    .start_expand    ( start_expand     ),
    .done            ( done             ),
    .done_out        ( done_out         ),
    .st_64bit        ( st_64bit         ),
    .st_64bit_valid  ( st_64bit_valid   ),

    .coeff           ( coeff            ),
    .coeff_valid     ( coeff_valid      ),
    .expand_done     ( expand_done      ),
    .nouce           ( nouce            ),
    .dout            ( dout             ),
    .dout_valid      ( dout_valid       ),
    .dout_len        ( dout_len         ),
    .mdlen           ( mdlen            ),
    .init            ( init             ),
    .start           ( start            ),
    .start_out       ( start_out        ),
    .out_len         ( out_len          )
);

sha3 u_sha3(
	.clk            	( clk             ),
	.rstn           	( rstn            ),
	.din            	( dout            ),
	.din_valid      	( dout_valid      ),
	.din_len        	( dout_len        ),
	.mdlen          	( mdlen           ),
	.init           	( init            ),
	.start          	( start           ),
	.done           	( done            ),
	.start_out      	( start_out       ),
	.out_len        	( out_len         ),
	.done_out       	( done_out        ),
	.st_64bit       	( st_64bit        ),
	.st_64bit_valid 	( st_64bit_valid  )
);


endmodule