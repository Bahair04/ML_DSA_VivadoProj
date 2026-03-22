// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2021.1" *)
module ExpandA_sipo(clk, srst, din, wr_en, rd_en, dout, full, empty, 
  rd_data_count);
  input clk;
  input srst;
  input [63:0]din;
  input wr_en;
  input rd_en;
  output [127:0]dout;
  output full;
  output empty;
  output [8:0]rd_data_count;
endmodule
