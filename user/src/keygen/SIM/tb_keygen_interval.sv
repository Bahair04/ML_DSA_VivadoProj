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
logic               key_ready            ;
logic               done             ;
logic   [7 : 0]     pk               ;
logic   [7 : 0]     sk               ;
logic   [91 : 0]    coeff_rho_ExpandA ;
logic               coeff_valid_rho_ExpandA ;
logic   [15 : 0]    coeff_rho_ExpandS ;
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
    zeta <= 256'h450a0e8fa38ef58c96beba3dbffc1eb08a3a83da8d54eaa7b51ecb1d541bafc7;
    start <= 1'b1;
    @(posedge clk);
    start <= 1'b0;
    while (keygen_internal.state != 8) begin
        @(posedge clk);
    end
    $finish;
end

integer fid;
initial begin
    fid = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/keygen/output/tb_ExpandA_output.txt", "w");
end

integer i = 0;
always_ff @(posedge clk) begin
    if (keygen_internal.coeff_valid_ExpandA) begin
        $fwrite(fid, "%d : %d\t%d\t%d\t%d\t\n", i, keygen_internal.coeff_ExpandA[22 : 0], 
        keygen_internal.coeff_ExpandA[45: 23], keygen_internal.coeff_ExpandA[68 : 46], 
        keygen_internal.coeff_ExpandA[91 : 69]);
        i = i + 1;
    end
end

integer fid1;
initial begin
    fid1 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/keygen/output/tb_ExpandS_output.txt", "w");
    $fwrite(fid1, "[");
end

logic   [22 : 0]            conv0, conv1, conv2, conv3;
assign conv0 = keygen_internal.con_coeff[22 : 0];
assign conv1 = keygen_internal.con_coeff[45: 23];
assign conv2 = keygen_internal.con_coeff[68 : 46];
assign conv3 = keygen_internal.con_coeff[91 : 69];

integer i1 = 0;
always_ff @(posedge clk) begin
    if (keygen_internal.coeff_valid_ExpandS) begin
        $fwrite(fid1, "%0d, %0d, %0d, %0d", 
                        $signed(keygen_internal.coeff_raw[3 : 0]),
                        $signed(keygen_internal.coeff_raw[7 : 4]),
                        $signed(keygen_internal.coeff_raw[11 : 8]),
                        $signed(keygen_internal.coeff_raw[15 : 12])
                        );
                        // $signed(keygen_internal.coeff_ExpandS[22 : 0] > 1000 ? keygen_internal.coeff_ExpandS[22 : 0] - `q : keygen_internal.coeff_ExpandS[22 : 0]), 
                        // $signed(keygen_internal.coeff_ExpandS[45: 23] > 1000 ? keygen_internal.coeff_ExpandS[45: 23] - `q : keygen_internal.coeff_ExpandS[45: 23]), 
                        // $signed(keygen_internal.coeff_ExpandS[68 : 46] > 1000 ? keygen_internal.coeff_ExpandS[68 : 46] - `q : keygen_internal.coeff_ExpandS[68 : 46]), 
                        // $signed(keygen_internal.coeff_ExpandS[91 : 69] > 1000 ? keygen_internal.coeff_ExpandS[91 : 69] - `q : keygen_internal.coeff_ExpandS[91 : 69]));
        i1 = i1 + 1;
        if (i1 % 64 == 0)
            $fwrite(fid1, "]\n\n[");
        else 
            $fwrite(fid1, ", ");
    end
end

integer fid2;
initial begin
    fid2 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/keygen/output/tb_power2bound_output_t0.txt", "w");
    $fwrite(fid2, "[");
end
integer fid3;
initial begin
    fid3 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/keygen/output/tb_power2bound_output_t1.txt", "w");
    $fwrite(fid3, "[");
end

logic   [12 : 0]            t00, t01, t02, t03;
assign t00 = keygen_internal.t0_out_comb[13 * 0 +: 13];
assign t01 = keygen_internal.t0_out_comb[13 * 1 +: 13];
assign t02 = keygen_internal.t0_out_comb[13 * 2 +: 13];
assign t03 = keygen_internal.t0_out_comb[13 * 3 +: 13];

logic   [9 : 0]             t10, t11, t12, t13;
assign t10 = keygen_internal.t1_out_comb[10 * 0 +: 10];
assign t11 = keygen_internal.t1_out_comb[10 * 1 +: 10];
assign t12 = keygen_internal.t1_out_comb[10 * 2 +: 10];
assign t13 = keygen_internal.t1_out_comb[10 * 3 +: 10];

integer i4 = 0;
always_ff @(posedge clk) begin
    if (keygen_internal.final_t_valid) begin
        $fwrite(fid2, "%0d, %0d, %0d, %0d", 
                        $signed(t00),
                        $signed(t01),
                        $signed(t02),
                        $signed(t03)
                        );
        $fwrite(fid3, "%0d, %0d, %0d, %0d", 
                        t10,
                        t11,
                        t12,
                        t13
                        );
        i4 = i4 + 1;
        if (i4 % 64 == 0) begin
            $fwrite(fid2, "]\n\n[");
            $fwrite(fid3, "]\n\n[");
        end
        else begin
            $fwrite(fid2, ", ");
            $fwrite(fid3, ", ");
        end
        $fflush(fid2);
        $fflush(fid3);
    end
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

    .key_ready                ( key_ready                 ),
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