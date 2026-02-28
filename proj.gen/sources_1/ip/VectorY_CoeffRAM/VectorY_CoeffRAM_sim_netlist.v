// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Sat Feb 28 10:22:26 2026
// Host        : LAPTOP-EUGMKLPQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/University/ML_DSA/vivado_proj/proj/proj.gen/sources_1/ip/VectorY_CoeffRAM/VectorY_CoeffRAM_sim_netlist.v
// Design      : VectorY_CoeffRAM
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg484-2L
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "VectorY_CoeffRAM,blk_mem_gen_v8_4_4,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *) 
(* NotValidForBitStream *)
module VectorY_CoeffRAM
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
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [5:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [79:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [7:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [19:0]doutb;

  wire [5:0]addra;
  wire [7:0]addrb;
  wire clka;
  wire clkb;
  wire [79:0]dina;
  wire [19:0]doutb;
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
  wire [79:0]NLW_U0_douta_UNCONNECTED;
  wire [7:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [19:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;

  (* C_ADDRA_WIDTH = "6" *) 
  (* C_ADDRB_WIDTH = "8" *) 
  (* C_ALGORITHM = "1" *) 
  (* C_AXI_ID_WIDTH = "4" *) 
  (* C_AXI_SLAVE_TYPE = "0" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_BYTE_SIZE = "9" *) 
  (* C_COMMON_CLK = "0" *) 
  (* C_COUNT_18K_BRAM = "1" *) 
  (* C_COUNT_36K_BRAM = "1" *) 
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     6.8776 mW" *) 
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
  (* C_INIT_FILE = "VectorY_CoeffRAM.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "1" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "4" *) 
  (* C_READ_DEPTH_A = "64" *) 
  (* C_READ_DEPTH_B = "256" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "80" *) 
  (* C_READ_WIDTH_B = "20" *) 
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
  (* C_WRITE_DEPTH_A = "64" *) 
  (* C_WRITE_DEPTH_B = "256" *) 
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "80" *) 
  (* C_WRITE_WIDTH_B = "20" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  VectorY_CoeffRAM_blk_mem_gen_v8_4_4 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .douta(NLW_U0_douta_UNCONNECTED[79:0]),
        .doutb(doutb),
        .eccpipece(1'b0),
        .ena(ena),
        .enb(enb),
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
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[19:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 40880)
`pragma protect data_block
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
gbql5g58GXtjJgg=
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
