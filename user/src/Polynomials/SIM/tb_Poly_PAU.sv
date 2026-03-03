`timescale  1ns / 1ps

module tb_Poly_PAU;

// Poly_PAU Parameters
parameter PERIOD  = 10;


// Poly_PAU Inputs
logic                   clk          = 1 ;
logic                   rstn         = 0 ;
logic   [91 : 0]        ori_coeff    = 0 ;
logic                   ori_coeff_valid = 0 ;
logic                   request      = 0 ;
logic   [91 : 0]        ext_operand  = 0 ;
logic   [4 : 0]         mode_config  = 0 ;

// Poly_PAU Outputs
logic                   ext_operand_request ;
logic                   ready        ;
logic   [91 : 0]        con_coeff    ;
logic                   con_coeff_valid ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

integer i = 0;
initial begin
    repeat (20) @(posedge clk);
    mode_config <= 'd0;
    while (!ready) begin
        @(posedge clk);
    end
    request <= 1'b1;
    while (ready) begin
        @(posedge clk);
    end
    request <= 1'b0;
    repeat (5) @(posedge clk);
    ori_coeff_valid <= 1'b1;
    for (i = 0 ; i < 256 ; i = i + 4) begin
        ori_coeff <= {
            23'(i + 3),
            23'(i + 2),
            23'(i + 1),
            23'(i)
        };
        @(posedge clk);
    end
    ori_coeff_valid <= 1'b0;
    while (!ready) begin
        @(posedge clk);
    end
    $finish;
end

integer fid;
initial begin
    fid = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/Poly_PAU_ntt_res.txt", "w");
end

always @(posedge clk) begin
    if (con_coeff_valid)
        $fwrite(fid, "%d\n%d\n%d\n%d\n", con_coeff[22 : 0], con_coeff[45 : 23], con_coeff[68 : 46], con_coeff[91 : 69]);
end

Poly_PAU  u_Poly_PAU (
    .clk                  ( clk                   ),
    .rstn                 ( rstn                  ),
    .ori_coeff            ( ori_coeff             ),
    .ori_coeff_valid      ( ori_coeff_valid       ),
    .request              ( request               ),
    .ext_operand          ( ext_operand           ),
    .mode_config          ( mode_config           ),

    .ext_operand_request  ( ext_operand_request   ),
    .ready                ( ready                 ),
    .con_coeff            ( con_coeff             ),
    .con_coeff_valid      ( con_coeff_valid       )
);
endmodule