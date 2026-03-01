// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Sun Mar  1 20:10:29 2026
// Host        : LAPTOP-EUGMKLPQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/University/ML_DSA/vivado_proj/proj/proj.gen/sources_1/ip/ZetaRaw_ROM/ZetaRaw_ROM_stub.v
// Design      : ZetaRaw_ROM
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *)
module ZetaRaw_ROM(clka, ena, addra, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,addra[7:0],douta[22:0]" */;
  input clka;
  input ena;
  input [7:0]addra;
  output [22:0]douta;
endmodule
