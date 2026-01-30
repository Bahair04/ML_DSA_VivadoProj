// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Fri Jan 30 12:19:27 2026
// Host        : LAPTOP-EUGMKLPQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/University/ML_DSA/vivado_proj/proj/proj.gen/sources_1/ip/ExpandC_coeff_ram/ExpandC_coeff_ram_sim_netlist.v
// Design      : ExpandC_coeff_ram
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg484-2L
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "ExpandC_coeff_ram,blk_mem_gen_v8_4_4,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "blk_mem_gen_v8_4_4,Vivado 2021.1" *) 
(* NotValidForBitStream *)
module ExpandC_coeff_ram
   (clka,
    ena,
    wea,
    addra,
    dina,
    douta,
    clkb,
    enb,
    web,
    addrb,
    dinb,
    doutb);
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTA, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clka;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA EN" *) input ena;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA WE" *) input [0:0]wea;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA ADDR" *) input [7:0]addra;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DIN" *) input [1:0]dina;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTA DOUT" *) output [1:0]douta;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME BRAM_PORTB, MEM_SIZE 8192, MEM_WIDTH 32, MEM_ECC NONE, MASTER_TYPE OTHER, READ_LATENCY 1" *) input clkb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB EN" *) input enb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB WE" *) input [0:0]web;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB ADDR" *) input [7:0]addrb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DIN" *) input [1:0]dinb;
  (* x_interface_info = "xilinx.com:interface:bram:1.0 BRAM_PORTB DOUT" *) output [1:0]doutb;

  wire [7:0]addra;
  wire [7:0]addrb;
  wire clka;
  wire clkb;
  wire [1:0]dina;
  wire [1:0]dinb;
  wire [1:0]douta;
  wire [1:0]doutb;
  wire ena;
  wire enb;
  wire [0:0]wea;
  wire [0:0]web;
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
  wire [7:0]NLW_U0_rdaddrecc_UNCONNECTED;
  wire [3:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [7:0]NLW_U0_s_axi_rdaddrecc_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rdata_UNCONNECTED;
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
  (* C_EST_POWER_SUMMARY = "Estimated Power for IP     :     2.220834 mW" *) 
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
  (* C_INIT_FILE = "ExpandC_coeff_ram.mem" *) 
  (* C_INIT_FILE_NAME = "no_coe_file_loaded" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_LOAD_INIT_FILE = "0" *) 
  (* C_MEM_TYPE = "2" *) 
  (* C_MUX_PIPELINE_STAGES = "0" *) 
  (* C_PRIM_TYPE = "1" *) 
  (* C_READ_DEPTH_A = "256" *) 
  (* C_READ_DEPTH_B = "256" *) 
  (* C_READ_LATENCY_A = "1" *) 
  (* C_READ_LATENCY_B = "1" *) 
  (* C_READ_WIDTH_A = "2" *) 
  (* C_READ_WIDTH_B = "2" *) 
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
  (* C_WRITE_MODE_A = "NO_CHANGE" *) 
  (* C_WRITE_MODE_B = "WRITE_FIRST" *) 
  (* C_WRITE_WIDTH_A = "2" *) 
  (* C_WRITE_WIDTH_B = "2" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  ExpandC_coeff_ram_blk_mem_gen_v8_4_4 U0
       (.addra(addra),
        .addrb(addrb),
        .clka(clka),
        .clkb(clkb),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .deepsleep(1'b0),
        .dina(dina),
        .dinb(dinb),
        .douta(douta),
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
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[1:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[3:0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_sbiterr(NLW_U0_s_axi_sbiterr_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0}),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb(1'b0),
        .s_axi_wvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .shutdown(1'b0),
        .sleep(1'b0),
        .wea(wea),
        .web(web));
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 23376)
`pragma protect data_block
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
EspKhFnO
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
