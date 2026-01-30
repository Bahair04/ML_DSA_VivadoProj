`include "../../param_conf.v"
`timescale  1ns / 1ps

module tb_ExpandC;

// ExpandC Parameters
parameter PERIOD  = 20;


// ExpandC Inputs
logic               clk              = 0 ;
logic               rstn             = 0 ;
logic   [255 : 0]   seed             = 0 ;
logic   [7 : 0]     tau              = `tau ;
logic               start_expand     = 0 ;
logic               low_rd_en        = 0 ;
logic               high_rd_en       = 0 ;
logic               done             = 0 ;
logic               done_out         = 0 ;
logic   [63 : 0]    st_64bit         = 0 ;
logic               st_64bit_valid   = 0 ;

// ExpandC Outputs
logic   [1 : 0]     coeff_low        ;
logic   [7 : 0]     coeff_low_add    = 0   ;
logic               coeff_low_valid  ;
logic   [1 : 0]     coeff_high       ;
logic   [7 : 0]     coeff_high_add   = 0   ;
logic               coeff_high_valid ;
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
    seed <= 256'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
    @(posedge clk);
    start_expand <= 1'b1;
    @(posedge clk);
    start_expand <= 1'b0;
end

integer i = 0;
initial begin
    @(posedge expand_done);
    repeat (20) @(posedge clk);
    low_rd_en <= 1'b1;
    high_rd_en <= 1'b1;
    for (i = 0 ; i < 256 ; i = i + 2) begin
        coeff_low_add <= i;
        coeff_high_add <= i + 1;
        @(posedge clk);
    end
    low_rd_en <= 1'b0;
    high_rd_en <= 1'b0;
    repeat (20) @(posedge clk);
    $finish;
end

integer fid;
initial begin
    fid = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Sampler/output/tb_ExpandC_output.txt", "w");
    $fwrite(fid, "[");
end

integer j = 0;
always_ff @(posedge clk) begin
    if (coeff_high_valid) begin
        $fwrite(fid, "%0d, %0d", $signed(coeff_low == 'd2 ? -1 : coeff_low), 
                                 $signed(coeff_high == 'd2 ? -1 : coeff_high));
        j = j + 2;
        if (j % 256 == 0)
            $fwrite(fid, "]");
        else 
            $fwrite(fid, ", ");
    end
end

ExpandC  u_ExpandC (
    .clk               ( clk                                    ),
    .rstn              ( rstn                                   ),
    .seed              ( seed                                   ),
    .tau               ( tau                                    ),
    .start_expand      ( start_expand                           ),
    .low_rd_en         ( low_rd_en                              ),
    .high_rd_en        ( high_rd_en                             ),
    .done              ( done                                   ),
    .done_out          ( done_out                               ),
    .st_64bit          ( st_64bit                               ),
    .st_64bit_valid    ( st_64bit_valid                         ),

    .coeff_low         ( coeff_low                              ),
    .coeff_low_add     ( coeff_low_add                          ),
    .coeff_low_valid   ( coeff_low_valid                        ),
    .coeff_high        ( coeff_high                             ),
    .coeff_high_add    ( coeff_high_add                         ),
    .coeff_high_valid  ( coeff_high_valid                       ),
    .expand_done       ( expand_done                            ),
    .dout              ( dout                                   ),
    .dout_valid        ( dout_valid                             ),
    .dout_len          ( dout_len                               ),
    .mdlen             ( mdlen                                  ),
    .init              ( init                                   ),
    .start             ( start                                  ),
    .start_out         ( start_out                              ),
    .out_len           ( out_len                                )
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