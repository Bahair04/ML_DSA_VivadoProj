`timescale  1ns / 1ps
`include "../../param_conf.v"
module tb_ExpandY;

// ExpandY Parameters
parameter PERIOD  = 20;


// ExpandY Inputs
logic               clk              = 0 ;
logic               rstn             = 0 ;
logic   [511 : 0]   rho_prime        = 0 ;
logic   [15 : 0]    kappa            = 0 ;
logic               start_expand     = 0 ;
logic               done             = 0 ;
logic               done_out         = 0 ;
logic   [63 : 0]    st_64bit         = 0 ;
logic               st_64bit_valid   = 0 ;

// ExpandY Outputs
logic   [4 * `bit_count - 1 : 0] coeff ;
logic               coeff_valid      ;
logic               expand_done      ;
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
    kappa <= 'd0;
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
    fid = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Sampler/output/tb_ExpandY_output.txt", "w");
    $fwrite(fid, "[");
end

logic           [`bit_count - 1 : 0]        raw_data [0 : 3];
assign raw_data[0] = coeff[`bit_count - 1 : 0];
assign raw_data[1] = coeff[2 * `bit_count - 1 : `bit_count];
assign raw_data[2] = coeff[3 * `bit_count - 1 : 2 * `bit_count];
assign raw_data[3] = coeff[4 * `bit_count - 1 : 3 * `bit_count];

integer i = 0;
always_ff @(posedge clk) begin
    if (coeff_valid) begin
        $fwrite(fid, "%0d, %0d, %0d, %0d", 
                        $signed(raw_data[0] > 1000 ? raw_data[0] - `q : raw_data[0]), 
                        $signed(raw_data[1] > 1000 ? raw_data[1] - `q : raw_data[1]), 
                        $signed(raw_data[2] > 1000 ? raw_data[2] - `q : raw_data[2]), 
                        $signed(raw_data[3] > 1000 ? raw_data[3] - `q : raw_data[3]));
        i = i + 1;
        if (i % 64 == 0)
            $fwrite(fid, "]\n\n[");
        else 
            $fwrite(fid, ", ");
    end
end

ExpandY  u_ExpandY (
    .clk                    ( clk             ),
    .rstn                   ( rstn            ),
    .rho_prime              ( rho_prime       ),
    .kappa                  ( kappa           ),
    .start_expand           ( start_expand    ),
    .done                   ( done            ),
    .done_out               ( done_out        ),
    .st_64bit               ( st_64bit        ),
    .st_64bit_valid         ( st_64bit_valid  ),

    .coeff                  (  coeff          ),
    .coeff_valid            (  coeff_valid    ),
    .expand_done            (  expand_done    ),
    .dout                   (  dout           ),
    .dout_valid             (  dout_valid     ),
    .dout_len               (  dout_len       ),
    .mdlen                  (  mdlen          ),
    .init                   (  init           ),
    .start                  (  start          ),
    .start_out              (  start_out      ),
    .out_len                (  out_len        )
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