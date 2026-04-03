`include "../../src/param_conf.v"
`timescale  1ns / 1ps

module tb_ML_DSA_top;

// ML_DSA_top Parameters
parameter PERIOD = 10;
parameter K  = `k;
parameter L  = `l;

// ML_DSA_top Inputs
logic                       clk      = 0 ;
logic                       rstn     = 0 ;
logic                       start_keygen = 0 ;
logic           [255 : 0]   zeta_keygen = 0 ;

// ML_DSA_top Outputs
logic                       key_ready_keygen ;
logic                       done_keygen ;
logic           [7 : 0]     pk_keygen ;
logic           [7 : 0]     sk_keygen ;

logic                       start_sign = 1'b0;       
logic                       sign_ready;      
logic                       done_sign;
logic           [511 : 0]   mu = 'd0;
logic           [255 : 0]   rnd = 'd0;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

integer fid1, fid2, fid3;
initial begin
    repeat (60) @(posedge clk);
    zeta_keygen <= 256'ha1410bcab52ac745d4e140bb0c339c1af3dd575432040d9947c03aa711f7a531;
    start_keygen <= 1'b1;
    @(posedge clk);
    start_keygen <= 1'b0;
    while (u_ML_DSA_top.u_keygen_internal.state != 15) begin
        @(posedge clk);
    end
    repeat (1000) @(posedge clk);
    $fclose(fid1);
    $fclose(fid2);
    $fclose(fid3);
    start_sign <= 1'b1;
    @(posedge clk);
    mu <= 'hf25fbb7cca28a573ae8cbb2544744ab9bb67dab74df24252d358a4c3543a5b870fd07acf58c72c64b86c2bfd7b161ad04080a9a1b945f3bf2fc25aefaacb0cf2;
    rnd <= 'h4cd6425f5e3bca0f42f6e45a35024391b85d6fd9abb52fad7ad492a7ebbcb115;
    start_sign <= 1'b0;
    while (u_ML_DSA_top.u_sign_internal.make_hint_done != 1) begin
        @(posedge clk);
    end
    repeat (1000) @(posedge clk);
    $finish;
end

integer fid;
initial begin
    fid = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/top/output/tb_ExpandA_output.txt", "w");
end

integer i = 0;
always_ff @(posedge clk) begin
    if (u_ML_DSA_top.u_keygen_internal.coeff_valid_ExpandA) begin
        $fwrite(fid, "%d : %d\t%d\t%d\t%d\t\n", i, u_ML_DSA_top.u_keygen_internal.coeff_ExpandA[22 : 0], 
        u_ML_DSA_top.u_keygen_internal.coeff_ExpandA[45: 23], u_ML_DSA_top.u_keygen_internal.coeff_ExpandA[68 : 46], 
        u_ML_DSA_top.u_keygen_internal.coeff_ExpandA[91 : 69]);
        i = i + 1;
    end
end

initial begin
    fid1 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/top/output/tb_ExpandS_output.txt", "w");
    $fwrite(fid1, "[");
end

logic   [22 : 0]            conv0, conv1, conv2, conv3;
assign conv0 = u_ML_DSA_top.u_keygen_internal.con_coeff[22 : 0];
assign conv1 = u_ML_DSA_top.u_keygen_internal.con_coeff[45: 23];
assign conv2 = u_ML_DSA_top.u_keygen_internal.con_coeff[68 : 46];
assign conv3 = u_ML_DSA_top.u_keygen_internal.con_coeff[91 : 69];

integer i1 = 0;
always_ff @(posedge clk) begin
    if (u_ML_DSA_top.u_keygen_internal.coeff_valid_ExpandS) begin
        $fwrite(fid1, "%0d, %0d, %0d, %0d", 
                        $signed(u_ML_DSA_top.u_keygen_internal.coeff_raw[3 : 0]),
                        $signed(u_ML_DSA_top.u_keygen_internal.coeff_raw[7 : 4]),
                        $signed(u_ML_DSA_top.u_keygen_internal.coeff_raw[11 : 8]),
                        $signed(u_ML_DSA_top.u_keygen_internal.coeff_raw[15 : 12])
                        );
        i1 = i1 + 1;
        if (i1 % 64 == 0)
            $fwrite(fid1, "]\n\n[");
        else 
            $fwrite(fid1, ", ");
    end
end

initial begin
    fid2 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/top/output/tb_power2bound_output_t0.txt", "w");
    $fwrite(fid2, "[");
end
initial begin
    fid3 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/top/output/tb_power2bound_output_t1.txt", "w");
    $fwrite(fid3, "[");
end

logic   [12 : 0]            t00, t01, t02, t03;
assign t00 = u_ML_DSA_top.u_keygen_internal.t0_out_comb[13 * 0 +: 13];
assign t01 = u_ML_DSA_top.u_keygen_internal.t0_out_comb[13 * 1 +: 13];
assign t02 = u_ML_DSA_top.u_keygen_internal.t0_out_comb[13 * 2 +: 13];
assign t03 = u_ML_DSA_top.u_keygen_internal.t0_out_comb[13 * 3 +: 13];

logic   [9 : 0]             t10, t11, t12, t13;
assign t10 = u_ML_DSA_top.u_keygen_internal.t1_out_comb[10 * 0 +: 10];
assign t11 = u_ML_DSA_top.u_keygen_internal.t1_out_comb[10 * 1 +: 10];
assign t12 = u_ML_DSA_top.u_keygen_internal.t1_out_comb[10 * 2 +: 10];
assign t13 = u_ML_DSA_top.u_keygen_internal.t1_out_comb[10 * 3 +: 10];

integer i4 = 0;
always_ff @(posedge clk) begin
    if (u_ML_DSA_top.u_keygen_internal.final_t_valid) begin
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

ML_DSA_top #(
    .K ( K ),
    .L ( L ))
 u_ML_DSA_top (
    .clk               ( clk             ),
    .rstn              ( rstn            ),
    .start_keygen      ( start_keygen       ),
    .zeta_keygen       ( zeta_keygen        ),

    .key_ready_keygen  ( key_ready_keygen   ),
    .done_keygen       ( done_keygen        ),
    .pk_keygen         ( pk_keygen          ),
    .sk_keygen         ( sk_keygen          ),
    .start_sign        (start_sign),
    .sign_ready        (sign_ready),
    .done_sign         (done_sign),
    .mu                (mu),
    .rnd               (rnd)
);

endmodule