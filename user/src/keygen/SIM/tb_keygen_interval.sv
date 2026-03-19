`timescale  1ns / 1ps

module tb_keygen_internal;

// keygen_internal Parameters
parameter PERIOD  = 20;


// keygen_internal Inputs
logic               clk              = 1 ;
logic               rstn             = 0 ;
logic               start            = 0 ;
logic   [255 : 0]   zeta             = 0 ;
logic               done1            = 0 ;
logic               done_out1        = 0 ;
logic   [63 : 0]    st_64bit1        = 0 ;
logic               st_64bit_valid1  = 0 ;
logic               done2            = 0 ;
logic               done_out2        = 0 ;
logic   [63 : 0]    st_64bit2        = 0 ;
logic               st_64bit_valid2  = 0 ;

// keygen_internal Outputs
logic               ready            ;
logic               done             ;
logic   [7 : 0]     pk               ;
logic   [7 : 0]     sk               ;
logic   [91 : 0]    coeff_rho_ExpandA ;
logic               coeff_valid_rho_ExpandA ;
logic   [91 : 0]    coeff_rho_ExpandS ;
logic               coeff_valid_rho_ExpandS ;
logic   [7 : 0]     dout1            ;
logic               dout_valid1      ;
logic   [31 : 0]    dout_len1        ;
logic   [7 : 0]     mdlen1           ;
logic               init1            ;
logic               start1           ;
logic               start_out1       ;
logic   [31 : 0]    out_len1         ;
logic   [7 : 0]     dout2            ;
logic               dout_valid2      ;
logic   [31 : 0]    dout_len2        ;
logic   [7 : 0]     mdlen2           ;
logic               init2            ;
logic               start2           ;
logic               start_out2       ;
logic   [31 : 0]    out_len2         ;


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
    zeta <= 256'h8691a380d927dad25b905f78ca3ee32dd665ae54237846938386ad913fd0a9dd;
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;
    @(posedge done);
end

keygen_internal  u_keygen_internal (
    .clk                      ( clk                       ),
    .rstn                     ( rstn                      ),
    .start                    ( start                     ),
    .zeta                     ( zeta                      ),
    .done1                    ( done1                     ),
    .done_out1                ( done_out1                 ),
    .st_64bit1                ( st_64bit1                 ),
    .st_64bit_valid1          ( st_64bit_valid1           ),
    .done2                    ( done2                     ),
    .done_out2                ( done_out2                 ),
    .st_64bit2                ( st_64bit2                 ),
    .st_64bit_valid2          ( st_64bit_valid2           ),

    .ready                    ( ready                     ),
    .done                     ( done                      ),
    .pk                       ( pk                        ),
    .sk                       ( sk                        ),
    .coeff_rho_ExpandA        ( coeff_rho_ExpandA         ),
    .coeff_valid_rho_ExpandA  ( coeff_valid_rho_ExpandA   ),
    .coeff_rho_ExpandS        ( coeff_rho_ExpandS         ),
    .coeff_valid_rho_ExpandS  ( coeff_valid_rho_ExpandS   ),
    .dout1                    ( dout1                     ),
    .dout_valid1              ( dout_valid1               ),
    .dout_len1                ( dout_len1                 ),
    .mdlen1                   ( mdlen1                    ),
    .init1                    ( init1                     ),
    .start1                   ( start1                    ),
    .start_out1               ( start_out1                ),
    .out_len1                 ( out_len1                  ),
    .dout2                    ( dout2                     ),
    .dout_valid2              ( dout_valid2               ),
    .dout_len2                ( dout_len2                 ),
    .mdlen2                   ( mdlen2                    ),
    .init2                    ( init2                     ),
    .start2                   ( start2                    ),
    .start_out2               ( start_out2                ),
    .out_len2                 ( out_len2                  )
);

sha3 u_sha3_1(
	.clk            	( clk             ),
	.rstn           	( rstn            ),
	.din            	( dout1            ),
	.din_valid      	( dout_valid1      ),
	.din_len        	( dout_len1        ),
	.mdlen          	( mdlen1           ),
	.init           	( init1            ),
	.start          	( start1           ),
	.done           	( done1            ),
	.start_out      	( start_out1       ),
	.out_len        	( out_len1         ),
	.done_out       	( done_out1        ),
	.st_64bit       	( st_64bit1        ),
	.st_64bit_valid 	( st_64bit_valid1  )
);

sha3 u_sha3_2(
	.clk            	( clk             ),
	.rstn           	( rstn            ),
	.din            	( dout2            ),
	.din_valid      	( dout_valid2      ),
	.din_len        	( dout_len2        ),
	.mdlen          	( mdlen2           ),
	.init           	( init2            ),
	.start          	( start2           ),
	.done           	( done2            ),
	.start_out      	( start_out2       ),
	.out_len        	( out_len2         ),
	.done_out       	( done_out2        ),
	.st_64bit       	( st_64bit2        ),
	.st_64bit_valid 	( st_64bit_valid2  )
);

endmodule