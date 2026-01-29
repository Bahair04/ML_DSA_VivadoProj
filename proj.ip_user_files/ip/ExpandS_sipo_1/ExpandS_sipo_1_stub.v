// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Thu Jan 29 18:52:52 2026
// Host        : LAPTOP-EUGMKLPQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/University/ML_DSA/vivado_proj/proj/proj.gen/sources_1/ip/ExpandS_sipo_1/ExpandS_sipo_1_stub.v
// Design      : ExpandS_sipo_1
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2021.1" *)
module ExpandS_sipo_1(clk, srst, din, wr_en, rd_en, dout, full, empty, 
  rd_data_count)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[63:0],wr_en,rd_en,dout[15:0],full,empty,rd_data_count[10:0]" */;
  input clk;
  input srst;
  input [63:0]din;
  input wr_en;
  input rd_en;
  output [15:0]dout;
  output full;
  output empty;
  output [10:0]rd_data_count;
endmodule
