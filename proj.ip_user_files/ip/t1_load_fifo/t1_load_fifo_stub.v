// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Tue Mar 24 15:44:46 2026
// Host        : LAPTOP-EUGMKLPQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/University/ML_DSA/vivado_proj/proj/proj.gen/sources_1/ip/t1_load_fifo/t1_load_fifo_stub.v
// Design      : t1_load_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a200tfbg484-2L
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2021.1" *)
module t1_load_fifo(clk, srst, din, wr_en, rd_en, dout, full, empty, 
  rd_data_count, wr_data_count)
/* synthesis syn_black_box black_box_pad_pin="clk,srst,din[63:0],wr_en,rd_en,dout[7:0],full,empty,rd_data_count[12:0],wr_data_count[9:0]" */;
  input clk;
  input srst;
  input [63:0]din;
  input wr_en;
  input rd_en;
  output [7:0]dout;
  output full;
  output empty;
  output [12:0]rd_data_count;
  output [9:0]wr_data_count;
endmodule
