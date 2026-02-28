// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Sat Feb 28 10:14:35 2026
// Host        : LAPTOP-EUGMKLPQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/University/ML_DSA/vivado_proj/proj/proj.gen/sources_1/ip/VectorS_CoeffRAM/VectorS_CoeffRAM_sim_netlist.v
// Design      : VectorS_CoeffRAM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg484-2L
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "VectorS_CoeffRAM,blk_mem_gen_v8_4_4,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *) 
(* NotValidForBitStream *)
module VectorS_CoeffRAM
   (clka,
    ena,
    wea,
    addra,
    dina,
    clkb,
    enb,
    addrb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [9:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [15:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [11:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [3:0]doutb;

  wire [9:0]addra;
  wire [11:0]addrb;
  wire clka;
  wire clkb;
  wire [15:0]dina;
  wire [3:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
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
  wire [15:0]NLW_U0_douta_UNCONNECTED;
  wire [11:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [11:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "10" *) 
  (* C_ADDRB_WIDTH = "12" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.3004 mW" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_ENA = "1" *) 
  (* C_HAS_ENB = "1" *) 
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
  (* C_INIT_FILE = "VectorS_CoeffRAM.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "1024" *) 
  (* C_READ_DEPTH_B = "4096" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "16" *) 
  (* C_READ_WIDTH_B = "4" *) 
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
  (* C_WRITE_DEPTH_A = "1024" *) 
  (* C_WRITE_DEPTH_B = "4096" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "16" *) 
  (* C_WRITE_WIDTH_B = "4" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  VectorS_CoeffRAM_blk_mem_gen_v8_4_4 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[15:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .rdaddrecc(NLW_U0_rdaddrecc_UNCONNECTED[11:0]),
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
        .s_axi_rdaddrecc(NLW_U0_s_axi_rdaddrecc_UNCONNECTED[11:0]),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[3:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 19664)
`pragma protect data_block
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
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
