// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Sun Mar  1 20:10:29 2026
// Host        : LAPTOP-EUGMKLPQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/University/ML_DSA/vivado_proj/proj/proj.gen/sources_1/ip/ZetaRaw_ROM/ZetaRaw_ROM_sim_netlist.v
// Design      : ZetaRaw_ROM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg484-2L
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "ZetaRaw_ROM,blk_mem_gen_v8_4_4,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *) 
(* NotValidForBitStream *)
module ZetaRaw_ROM
   (clka,
    ena,
    addra,
    douta);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [7:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [22:0]douta;

  wire [7:0]addra;
  wire clka;
  wire [22:0]douta;
  wire ena;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_rsta_busy_UNCONNECTED;
  wire NLW_U0_rstb_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_dbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_sbiterr_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire [22:0]NLW_U0_doutb_UNCONNECTED;
  wire [7:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [22:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "8" *) 
  (* C_ADDRB_WIDTH = "8" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "0" *) 
  (* C_CTRL_ECC_ALGO = "NONE" *) 
  (* C_DEFAULT_DATA = "0" *) 
  (* C_DISABLE_WARN_BHV_COLL = "0" *) 
  (* C_DISABLE_WARN_BHV_RANGE = "0" *) 
  (* C_ELABORATION_DIR = "./" *) 
  (* C_ENABLE_32BIT_ADDRESS = "0" *) 
  (* C_EN_DEEPSLEEP_PIN = "0" *) 
  (* C_EN_ECC_PIPE = "0" *) 
  (* C_EN_RDADDRA_CHG = "0" *) 
  (* C_EN_RDADDRB_CHG = "0" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_EN_SHUTDOWN_PIN = "0" *) 
  (* C_EN_SLEEP_PIN = "0" *) 
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     3.0008 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "0" *) 
  (* C_HAS_INJECTERR = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MEM_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_A = "0" *) 
  (* C_HAS_MUX_OUTPUT_REGS_B = "0" *) 
  (* C_HAS_REGCEA = "0" *) 
  (* C_HAS_REGCEB = "0" *) 
  (* C_HAS_RSTA = "0" *) 
  (* C_HAS_RSTB = "0" *) 
  (* C_HAS_SOFTECC_INPUT_REGS_A = "0" *) 
  (* C_HAS_SOFTECC_OUTPUT_REGS_B = "0" *) 
  (* C_INITA_VAL = "0" *) 
  (* C_INITB_VAL = "0" *) 
  (* C_INIT_FILE = "ZetaRaw_ROM.mem" *) 
  (* C_INIT_FILE_NAME = "ZetaRaw_ROM.mif" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "1" *) 
  (* C_MEM_TYPE = "3" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "256" *) 
  (* C_READ_DEPTH_B = "256" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "23" *) 
  (* C_READ_WIDTH_B = "23" *) 
  (* C_RSTRAM_A = "0" *) 
  (* C_RSTRAM_B = "0" *) 
  (* C_RST_PRIORITY_A = "CE" *) 
  (* C_RST_PRIORITY_B = "CE" *) 
  (* C_SIM_COLLISION_CHECK = "ALL" *) 
  (* C_USE_BRAM_BLOCK = "0" *) 
  (* C_USE_BYTE_WEA = "0" *) 
  (* C_USE_BYTE_WEB = "0" *) 
  (* C_USE_DEFAULT_DATA = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_SOFTECC = "0" *) 
  (* C_USE_URAM = "0" *) 
  (* C_WEA_WIDTH = "1" *) 
  (* C_WEB_WIDTH = "1" *) 
  (* C_WRITE_DEPTH_A = "256" *) 
  (* C_WRITE_DEPTH_B = "256" *) 
  (* C_WRITE_MODE_A = "WRITE_FIRST" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "23" *) 
  (* C_WRITE_WIDTH_B = "23" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  ZetaRaw_ROM_blk_mem_gen_v8_4_4 U0
       (.addra(addra),
        .addrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .clka(clka),
        .clkb(1'b0),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(douta),
        .doutb(NLW_U0_doutb_UNCONNECTED[22:0]),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(1'b0),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[7:0]),
        .regcea(1'b0),
        .regceb(1'b0),
        .rsta(1'b0),
        .rsta_busy(NLW_U0_rsta_busy_UNCONNECTED),
        .rstb(1'b0),
        .rstb_busy(NLW_U0_rstb_busy_UNCONNECTED),
        .s_aclk(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awid({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[3:0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_dbiterr(NLW_U0_s_axi_dbiterr_UNCONNECTED),
        .s_axi_injectdbiterr(1'b0),
        .s_axi_injectsbiterr(1'b0),
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[7:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[22:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(1'b0),
        .web(1'b0));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2021.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
sbNGmomEbP78s1hfxgX3P1Jo01EKJk0i0C7iGpF+Yibr9EK0s4mcIifHDN/ag4jpPwW3bPllMHvn
U8AEY3mO8hCXVVoilrcRuCaEna/98GycCzy4G7FnYMfowsJb5k9ifRdE2jnurzeTLFbupUSpDF0H
Rl3Ci3DTGeExAZZ9UQE=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
zZZZoIprBFYfDWmCCcduELBM7HU98/+rvP9g8+y1mYyD3r3HEDm4ZwehwZvPoYWqoGXYoFqWZh3h
utt0abIfUW9/oF2vJ9hXn7nArtcm/Eui18rPYqp3aj/AItPNVXojk9zp7uFZLPTqcyig5v3Jtenl
qPnLi1Z84ZCW7NIRw6Y0bgmw6z26E8VPbYrZHs+0YW8Sztjo6CdIrQeEL5WBDolA0aHoKHWRZyFs
l5eRDmBAolj2uF07t/3eY3J7cYJmEDaoZ0TR1qcz25VFNu0OlcrEJ19IT+QdAxTah4jqJtknGZrT
6lUMwDZ7dBQwF1EuaE6p90gGNERhGAsbHLdvaw==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
KUbz0Iu2faeWqD6HFeuGLtSOAlqZmpKCCJfzym8tkcWUUNgNMn2mYvx6PTM7j4tyig8JdUG3uZYs
NfPgAsNXQtTI7b19u9CkMks9jR+oEzX1rW7QtTvSj/nHZLg2smoFwuB5Ieb7/B8IIs1NTUrIz6Rc
itLQVG+L+GMziamsrx4=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
G7XYdRx9VGclyxTEtwMG+rjJHV8bfBxEGdkcN82UL3koN3Dt0M5AWkzEvHcskt1W0hTOjyYgmvYj
/p70w1nz96tlg226+e4UubpRmBH9QXBBX6UmqIwSiHj9H+XI1yNfTIdlwBKGQvfzwCAMwBwrrrGL
/804k5Ux3RhWRvwezZB4+sj9DFm4akREVXmNpfeqjI2X02LU/MxWMUbKxvjJnD9YxikAAO6ccTd6
8DKv76V76MEFVyXc7E2FeQDToW3lqkRTa6MTpIXbYSekRihQC+qPVuhPUneA4kepvQDfgFYE8/Ir
gu5gK+s/qNfuXhJUAqyLjslrUcY4+XD9ckpSvQ==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
YXkYRXpUPv/tETnwnThdQ46UaPmI23lN9vrxHQjIOhq3WNJCuz7TYZK9hyzSdo6k0U6QE9ihQy2L
rYZg68RGbrK8bzlcnQ41r18LZb4GYlAn9PH7IrF1B+aHm3578doOZHf8wzUE2s+d1aHQIn6VIZjL
14pCTAjErJfMO13fgX6h8sgxb4GFC3eIORmkrq2J/fB9HALyh/qdGiLi7DejMfmdsssbOcPQTZUh
6Belf7fHTkIEr9B44rFZgMyrMVx4N9p0XpXD3JPe7Xeg6a3jxdqxHATaMuLdIa4s+ZiAz1TRx0EO
FFihCnLLb7weBBITQyTIncRL817BrF/ZXZD8Yw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_01", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
g7FbNw1ywd4TBNHq8OmK/4zoKI/t7vKmyT8R8SeiyUtKywhn0/7DZ/lV0Lf4IhY8X5MYsKtOQ5l6
DIl3fxtOhxpi8NHn9Nw3Nfb8NnS38Zuy6DSpwOL0f/GSmUSf2/YdB5Ben6xibQT0Oy//oBl5/1kR
pV5fWjj8WRgI6cnmfyj3g1MxepxPu1A/UHxlm1/i9yUHHi114N/hEQ0iujjrn6GxfZSiJUVF+r6c
rnxD//eOAl/YaxhdU/KhUkfsMn+MxtA5m6hTYYE0bnze8rpmEU5UGYKyY0p8KUs+MgsdTe+m/7gV
HSf6puBqQmEa1qksRfl742aL9B9y169or7Jp9Q==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kd1A2zIphLxXB0RyfHIqLkHXfWl0n38vROERuDghYrhK0ItcWGEP0XBrri6k1VZCSPYwiSu//pM6
83BfcPKbk09/A+ksvDIa3xS8Tg7DJK2AS+0pdnzBSjVWh+QD+glA3Hjk6LG9OMbjXyqD3hnMKacA
VRMwxKktV+KT5NXj5a7fMxXjo9exc0xM+woUJiSYs8onoUSwfBeH5/xhUy+iu+w0/OOydQE2LXZ0
1y+RObiz5C22dD4GGCfuvUCGAthYpUf633ZxRYN45mmAn5PxPsH4o+l2GhH/50Gu/VPVoAWDhgXQ
e93oPri++HinkK2uvDhDl4PI9HtRkq11Ky3uXQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
gDrrFgXHVyBo+Cn0bYn+SOSOCXPg7besukY6l0JmA/nu4gap105Wxbg11c7TJZ9ctHVLc5DXAxr+
EIvFpAIepoZBREtMjTlaIdNJ8k1nUpwAv2jaQeseq1TudTjugV1jtOYYk0RKd88z/6SJ8t9urDW0
yKqsfEWU3PwGcUGHOWtTn2hfAceNznmEIFWLmFmzSQJ1hQNdsIQn3jHnfMVYu8cAz5xvPVQWYyJW
pMHXhNYk6GyAjIshh991slb1g01K1ilR2tKD1EmxH5WGrX9BEUqBjHQo6uluC/d3mvcEQ5nJ1v+P
hIlj4qzUQT1wXjpk6d/BvNx7LyWmj5iq35dzNm+cdhfGwaFGG//vgmB6D/dFfs2BYSjHsa6VlpVM
7e2OgoFenuG9p1SVPI6gAs2MuFtnDKfxW7jS3RGhvsquS3tg1iFCDH/OU7E5aWfY7twF3yyN6G10
l72RZw62DfNoCdyUMG9sA8nc4qf6dEhyrr5S6XxpJhoBDJvkeq0TCUQZ

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
XR7vRF1m+9DS2Pv4r/O4uHwmvtXkChnKbsJCYczn1dvkZbcZSbBm/2UH78dXUaNorOh9XAuCvSjb
ER73y7e0anAfaIf1tJ9Y9pIb8EuNxGS/Pqdvg36cWarwGac9tsscdv/HWfb5Z+qWEk0/uFcLI7pH
CZO7fF2/ONQjA0NtUFBjW4idlx8WrySIuJgDs4jyGkMhbHR3U/ghF1YhMhwgwsbbcptfC1XLrIqQ
OecZnZu8E2hyc5eK/ccYdKcHnXoL55z1p5amI6Fuvz0wKTz2QQ/mwXodfGjEC1ZRWwTn7zCFM91M
qrA1Is49i6pSa7/VICjgn8ULMT1oKGfJLPm7hg==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19552)
`pragma protect data_block
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
OA==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
