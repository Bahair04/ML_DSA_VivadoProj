`timescale  1ns / 1ps

module tb_BU;

// NTT_BU Parameters
parameter PERIOD  = 20;


// NTT_BU Inputs
logic                   clk          = 1 ;
logic                   rstn         = 0 ;
logic                   valid_in     = 0 ;
logic   [22 : 0]        data_in1     = 0 ;
logic   [22 : 0]        data_in2     = 0 ;
logic   [22 : 0]        zeta         = 0 ;

// NTT_BU Outputs
logic                   valid_out_ntt    ;
logic   [22 : 0]        data_out1_ntt    ;
logic   [22 : 0]        data_out2_ntt    ;
logic                   valid_out_intt    ;
logic   [22 : 0]        data_out1_intt    ;
logic   [22 : 0]        data_out2_intt    ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

integer fid1, fid2, fid3, fid4;

initial begin
    repeat (10) @(posedge clk);
    valid_in <= 1'b1;
    
    data_in1 <= 5554378; data_in2 <= 4289036; zeta <= 118989; @(posedge clk);
    data_in1 <= 1527997; data_in2 <= 2764431; zeta <= 7014286; @(posedge clk);
    data_in1 <= 2239384; data_in2 <= 7665234; zeta <= 4934502; @(posedge clk);
    data_in1 <= 4764935; data_in2 <= 5322442; zeta <= 2442753; @(posedge clk);
    data_in1 <= 6396636; data_in2 <= 5487425; zeta <= 1294252; @(posedge clk);
    data_in1 <= 2759863; data_in2 <= 737508; zeta <= 258480; @(posedge clk);
    data_in1 <= 4759622; data_in2 <= 2819481; zeta <= 8211835; @(posedge clk);
    data_in1 <= 2015317; data_in2 <= 1050386; zeta <= 3947543; @(posedge clk);
    data_in1 <= 648600; data_in2 <= 4777998; zeta <= 3235351; @(posedge clk);
    data_in1 <= 30844; data_in2 <= 1753680; zeta <= 55006; @(posedge clk);
    data_in1 <= 8283167; data_in2 <= 8135352; zeta <= 835835; @(posedge clk);
    data_in1 <= 7111044; data_in2 <= 1748082; zeta <= 7382843; @(posedge clk);
    data_in1 <= 6710146; data_in2 <= 4364906; zeta <= 1222624; @(posedge clk);
    data_in1 <= 463063; data_in2 <= 1594953; zeta <= 1310249; @(posedge clk);
    data_in1 <= 6673982; data_in2 <= 5115572; zeta <= 5480521; @(posedge clk);
    data_in1 <= 6749664; data_in2 <= 1034408; zeta <= 1386003; @(posedge clk);
    data_in1 <= 6434382; data_in2 <= 2976960; zeta <= 5309646; @(posedge clk);
    data_in1 <= 4943577; data_in2 <= 3413043; zeta <= 669029; @(posedge clk);
    data_in1 <= 8193390; data_in2 <= 5575114; zeta <= 6268542; @(posedge clk);
    data_in1 <= 7010665; data_in2 <= 1533673; zeta <= 1830294; @(posedge clk);
    data_in1 <= 3677593; data_in2 <= 6643103; zeta <= 5563120; @(posedge clk);
    data_in1 <= 295092; data_in2 <= 5033720; zeta <= 522925; @(posedge clk);
    data_in1 <= 6968637; data_in2 <= 5256900; zeta <= 7471609; @(posedge clk);
    data_in1 <= 2215174; data_in2 <= 278433; zeta <= 7175589; @(posedge clk);
    data_in1 <= 6534295; data_in2 <= 168999; zeta <= 1781639; @(posedge clk);
    data_in1 <= 4761885; data_in2 <= 205832; zeta <= 7612081; @(posedge clk);
    data_in1 <= 1192687; data_in2 <= 4225881; zeta <= 6014680; @(posedge clk);
    data_in1 <= 4659397; data_in2 <= 6858821; zeta <= 1450086; @(posedge clk);
    data_in1 <= 5557488; data_in2 <= 3094253; zeta <= 6871223; @(posedge clk);
    data_in1 <= 6259265; data_in2 <= 724389; zeta <= 5751720; @(posedge clk);
    data_in1 <= 3530614; data_in2 <= 1669234; zeta <= 5737221; @(posedge clk);
    data_in1 <= 4697604; data_in2 <= 1140463; zeta <= 4876208; @(posedge clk);
    data_in1 <= 5981154; data_in2 <= 6296666; zeta <= 1182110; @(posedge clk);
    data_in1 <= 7538160; data_in2 <= 5601690; zeta <= 7644762; @(posedge clk);
    data_in1 <= 2579629; data_in2 <= 293454; zeta <= 2329548; @(posedge clk);
    data_in1 <= 4762853; data_in2 <= 3447513; zeta <= 2167992; @(posedge clk);
    data_in1 <= 2215355; data_in2 <= 2818371; zeta <= 8239954; @(posedge clk);
    data_in1 <= 31921; data_in2 <= 4252811; zeta <= 467361; @(posedge clk);
    data_in1 <= 1042025; data_in2 <= 3987823; zeta <= 6408549; @(posedge clk);
    data_in1 <= 2093793; data_in2 <= 2314235; zeta <= 5757996; @(posedge clk);
    data_in1 <= 7549869; data_in2 <= 5287541; zeta <= 7251519; @(posedge clk);
    data_in1 <= 5027712; data_in2 <= 4148883; zeta <= 1029266; @(posedge clk);
    data_in1 <= 6901179; data_in2 <= 1097718; zeta <= 2842062; @(posedge clk);
    data_in1 <= 1047466; data_in2 <= 616936; zeta <= 7906382; @(posedge clk);
    data_in1 <= 4536066; data_in2 <= 3480261; zeta <= 6370322; @(posedge clk);
    data_in1 <= 7291467; data_in2 <= 6686160; zeta <= 4202791; @(posedge clk);
    data_in1 <= 4565264; data_in2 <= 5596285; zeta <= 4882493; @(posedge clk);
    data_in1 <= 485610; data_in2 <= 1162689; zeta <= 4137052; @(posedge clk);
    data_in1 <= 1178765; data_in2 <= 2966924; zeta <= 6692401; @(posedge clk);
    data_in1 <= 7001443; data_in2 <= 7863766; zeta <= 168698; @(posedge clk);

    valid_in <= 1'b0;
    repeat (20) @(posedge clk);
    $fwrite(fid1, "]");
    $fwrite(fid2, "]");
    $fwrite(fid3, "]");
    $fwrite(fid4, "]");
    $finish;

end 

NTT_BU  u_NTT_BU (
    .clk        ( clk         ),
    .rstn       ( rstn        ),
    .valid_in   ( valid_in    ),
    .data_in1   ( data_in1    ),
    .data_in2   ( data_in2    ),
    .zeta       ( zeta        ),

    .valid_out  ( valid_out_ntt   ),
    .data_out1  ( data_out1_ntt   ),
    .data_out2  ( data_out2_ntt   )
);

INTT_BU  u_INTT_BU (
    .clk        ( clk         ),
    .rstn       ( rstn        ),
    .valid_in   ( valid_in    ),
    .data_in1   ( data_in1    ),
    .data_in2   ( data_in2    ),
    .zeta       ( zeta        ),

    .valid_out  ( valid_out_intt   ),
    .data_out1  ( data_out1_intt   ),
    .data_out2  ( data_out2_intt   )
);

initial begin
    fid1 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/NTT1.txt", "w");
    fid2 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/NTT2.txt", "w");
    fid3 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/INTT1.txt", "w");
    fid4 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/INTT2.txt", "w");
    $fwrite(fid1, "[");
    $fwrite(fid2, "[");
    $fwrite(fid3, "[");
    $fwrite(fid4, "[");
end

always @(posedge clk) begin
    if (valid_out_ntt) begin
        $fwrite(fid1, "%d, ", data_out1_ntt);
    end
    if (valid_out_ntt) begin
        $fwrite(fid2, "%d, ", data_out2_ntt);
    end
    if (valid_out_intt) begin
        $fwrite(fid3, "%d, ", data_out1_intt);
    end
    if (valid_out_intt) begin
        $fwrite(fid4, "%d, ", data_out2_intt);
    end
end


endmodule