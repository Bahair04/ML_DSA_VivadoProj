`timescale  1ns / 1ps

module tb_ModuleCompute;

// ModuleAdd Parameters
parameter PERIOD  = 10;


// ModuleAdd Inputs
logic                   clk          = 0 ;
logic                   rstn         = 0 ;
logic                   valid_in_add = 0 ;
logic                   valid_in_sub = 0 ;
logic                   valid_in_mult= 0 ;
logic   [22 : 0]        data_in1     = 0 ;
logic   [22 : 0]        data_in2     = 0 ;

// ModuleAdd Outputs
logic                   valid_out_add    ;
logic   [22 : 0]        data_out_add     ;

logic                   valid_out_sub    ;
logic   [22 : 0]        data_out_sub     ;

logic                   valid_out_mult    ;
logic   [22 : 0]        data_out_mult     ;

initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rstn  =  1;
end

initial begin
    repeat (10) @(posedge clk);
    valid_in_add <= 1'b1;
    
    data_in1 <= 6813727;
    data_in2 <= 8251461;
    @(posedge clk);data_in1 <= 5314991;
    data_in2 <= 800359;
    @(posedge clk);data_in1 <= 5429690;
    data_in2 <= 6998688;
    @(posedge clk);data_in1 <= 3687811;
    data_in2 <= 6372738;
    @(posedge clk);data_in1 <= 1040201;
    data_in2 <= 2634464;
    @(posedge clk);data_in1 <= 8110358;
    data_in2 <= 5571063;
    @(posedge clk);data_in1 <= 8099263;
    data_in2 <= 7563042;
    @(posedge clk);data_in1 <= 5169311;
    data_in2 <= 1393854;
    @(posedge clk);data_in1 <= 3284824;
    data_in2 <= 1166671;
    @(posedge clk);data_in1 <= 7391742;
    data_in2 <= 1699234;
    @(posedge clk);data_in1 <= 6710929;
    data_in2 <= 566691;
    @(posedge clk);data_in1 <= 6263398;
    data_in2 <= 1163095;
    @(posedge clk);data_in1 <= 3304991;
    data_in2 <= 5133318;
    @(posedge clk);data_in1 <= 3445892;
    data_in2 <= 1145919;
    @(posedge clk);data_in1 <= 8331689;
    data_in2 <= 6601599;
    @(posedge clk);data_in1 <= 649102;
    data_in2 <= 4463401;
    @(posedge clk);data_in1 <= 713632;
    data_in2 <= 3538496;
    @(posedge clk);data_in1 <= 4151668;
    data_in2 <= 7986808;
    @(posedge clk);data_in1 <= 4225699;
    data_in2 <= 1113984;
    @(posedge clk);data_in1 <= 4046244;
    data_in2 <= 286772;
    @(posedge clk);data_in1 <= 1538814;
    data_in2 <= 4753355;
    @(posedge clk);data_in1 <= 7724929;
    data_in2 <= 6396338;
    @(posedge clk);data_in1 <= 6060823;
    data_in2 <= 2422852;
    @(posedge clk);data_in1 <= 5383986;
    data_in2 <= 283204;
    @(posedge clk);data_in1 <= 3926734;
    data_in2 <= 1900552;
    @(posedge clk);data_in1 <= 3476014;
    data_in2 <= 833159;
    @(posedge clk);data_in1 <= 7057889;
    data_in2 <= 5452279;
    @(posedge clk);data_in1 <= 5314559;
    data_in2 <= 4781542;
    @(posedge clk);data_in1 <= 4408628;
    data_in2 <= 3033408;
    @(posedge clk);data_in1 <= 3560758;
    data_in2 <= 7101983;
    @(posedge clk);data_in1 <= 2793675;
    data_in2 <= 4244098;
    @(posedge clk);data_in1 <= 4406873;
    data_in2 <= 7355495;
    @(posedge clk);data_in1 <= 8298471;
    data_in2 <= 5179837;
    @(posedge clk);data_in1 <= 2023016;
    data_in2 <= 7110147;
    @(posedge clk);data_in1 <= 4877932;
    data_in2 <= 6794422;
    @(posedge clk);data_in1 <= 5489615;
    data_in2 <= 7935818;
    @(posedge clk);data_in1 <= 4164944;
    data_in2 <= 7868288;
    @(posedge clk);data_in1 <= 910160;
    data_in2 <= 1303536;
    @(posedge clk);data_in1 <= 6016220;
    data_in2 <= 7070373;
    @(posedge clk);data_in1 <= 5445859;
    data_in2 <= 1511870;
    @(posedge clk);data_in1 <= 5269218;
    data_in2 <= 5099663;
    @(posedge clk);data_in1 <= 236167;
    data_in2 <= 1142291;
    @(posedge clk);data_in1 <= 2668924;
    data_in2 <= 5046060;
    @(posedge clk);data_in1 <= 1192160;
    data_in2 <= 8319460;
    @(posedge clk);data_in1 <= 7101000;
    data_in2 <= 3367921;
    @(posedge clk);data_in1 <= 3572717;
    data_in2 <= 3319739;
    @(posedge clk);data_in1 <= 2475643;
    data_in2 <= 1221893;
    @(posedge clk);data_in1 <= 4578319;
    data_in2 <= 1410510;
    @(posedge clk);data_in1 <= 93662;
    data_in2 <= 86516;
    @(posedge clk);data_in1 <= 8002774;
    data_in2 <= 5492633;
    @(posedge clk);

    valid_in_add <= 1'b0;
    repeat (20) @(posedge clk);
    $fwrite(fid1, "]");
    $fwrite(fid2, "]");
    $fwrite(fid3, "]");
    $finish;

end 

ModuleAdd  u_ModuleAdd (
    .clk        ( clk         ),
    .rstn       ( rstn        ),
    .valid_in   ( valid_in_add    ),
    .data_in1   ( data_in1    ),
    .data_in2   ( data_in2    ),

    .valid_out  ( valid_out_add   ),
    .data_out   ( data_out_add    )
);

ModuleSub  u_ModuleSub (
    .clk        ( clk         ),
    .rstn       ( rstn        ),
    .valid_in   ( valid_in_add    ),
    .data_in1   ( data_in1    ),
    .data_in2   ( data_in2    ),

    .valid_out  ( valid_out_sub   ),
    .data_out   ( data_out_sub    )
);

ModuleMult  u_ModuleMult (
    .clk        ( clk         ),
    .rstn       ( rstn        ),
    .valid_in   ( valid_in_add    ),
    .data_in1   ( data_in1    ),
    .data_in2   ( data_in2    ),

    .valid_out  ( valid_out_mult   ),
    .data_out   ( data_out_mult    )
);

integer fid1, fid2, fid3;
initial begin
    fid1 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/ModuleAdd.txt", "w");
    fid2 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/ModuleSub.txt", "w");
    fid3 = $fopen("D:/University/ML_DSA/vivado_proj/proj/user/src/Polynomials/SIM/ModuleMult.txt", "w");
    $fwrite(fid1, "[");
    $fwrite(fid2, "[");
    $fwrite(fid3, "[");
end

always @(posedge clk) begin
    if (valid_out_add) begin
        $fwrite(fid1, "%d, ", data_out_add);
    end
    if (valid_out_sub) begin
        $fwrite(fid2, "%d, ", data_out_sub);
    end
    if (valid_out_mult) begin
        $fwrite(fid3, "%d, ", data_out_mult);
    end
end

endmodule