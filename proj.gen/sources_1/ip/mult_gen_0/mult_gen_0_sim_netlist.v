// Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2021.1 (win64) Build 3247384 Thu Jun 10 19:36:33 MDT 2021
// Date        : Sat Jan 31 14:26:16 2026
// Host        : LAPTOP-EUGMKLPQ running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               d:/University/ML_DSA/vivado_proj/proj/proj.gen/sources_1/ip/mult_gen_0/mult_gen_0_sim_netlist.v
// Design      : mult_gen_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a200tfbg484-2L
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "mult_gen_0,mult_gen_v12_0_17,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "mult_gen_v12_0_17,Vivado 2021.1" *) 
(* NotValidForBitStream *)
module mult_gen_0
   (CLK,
    A,
    P);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 clk_intf CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME clk_intf, ASSOCIATED_BUSIF p_intf:b_intf:a_intf, ASSOCIATED_RESET sclr, ASSOCIATED_CLKEN ce, FREQ_HZ 10000000, FREQ_TOLERANCE_HZ 0, PHASE 0.0, INSERT_VIP 0" *) input CLK;
  (* x_interface_info = "xilinx.com:signal:data:1.0 a_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME a_intf, LAYERED_METADATA undef" *) input [22:0]A;
  (* x_interface_info = "xilinx.com:signal:data:1.0 p_intf DATA" *) (* x_interface_parameter = "XIL_INTERFACENAME p_intf, LAYERED_METADATA undef" *) output [39:0]P;

  wire \<const0> ;
  wire [22:0]A;
  wire CLK;
  wire [39:6]\^P ;
  wire [5:0]NLW_U0_P_UNCONNECTED;
  wire [47:0]NLW_U0_PCASC_UNCONNECTED;
  wire [1:0]NLW_U0_ZERO_DETECT_UNCONNECTED;

  assign P[39:6] = \^P [39:6];
  assign P[5] = \<const0> ;
  assign P[4] = \<const0> ;
  assign P[3] = \<const0> ;
  assign P[2] = \<const0> ;
  assign P[1] = \<const0> ;
  assign P[0] = \<const0> ;
  GND GND
       (.G(\<const0> ));
  (* C_A_TYPE = "1" *) 
  (* C_A_WIDTH = "23" *) 
  (* C_B_TYPE = "1" *) 
  (* C_B_VALUE = "10000000001000000" *) 
  (* C_B_WIDTH = "17" *) 
  (* C_CCM_IMP = "2" *) 
  (* C_CE_OVERRIDES_SCLR = "0" *) 
  (* C_HAS_CE = "0" *) 
  (* C_HAS_SCLR = "0" *) 
  (* C_HAS_ZERO_DETECT = "0" *) 
  (* C_LATENCY = "1" *) 
  (* C_MODEL_TYPE = "0" *) 
  (* C_MULT_TYPE = "2" *) 
  (* C_OPTIMIZE_GOAL = "1" *) 
  (* C_OUT_HIGH = "39" *) 
  (* C_OUT_LOW = "0" *) 
  (* C_ROUND_OUTPUT = "0" *) 
  (* C_ROUND_PT = "0" *) 
  (* C_VERBOSITY = "0" *) 
  (* C_XDEVICEFAMILY = "artix7" *) 
  (* downgradeipidentifiedwarnings = "yes" *) 
  (* is_du_within_envelope = "true" *) 
  mult_gen_0_mult_gen_v12_0_17 U0
       (.A(A),
        .B({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .CE(1'b1),
        .CLK(CLK),
        .P({\^P ,NLW_U0_P_UNCONNECTED[5:0]}),
        .PCASC(NLW_U0_PCASC_UNCONNECTED[47:0]),
        .SCLR(1'b0),
        .ZERO_DETECT(NLW_U0_ZERO_DETECT_UNCONNECTED[1:0]));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2021.1"
`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
OWAggS0mE6JxmIlB4IqLhyMXRYPJs2DDE2a2JuZy5MB/PdXC/CaU/QRB+AqcK6JP4szhXBycSS8z
iqxQxDTUg4A3iOIyJWDbM6Yncj1VoDx+K0dqn0H+Ux6ekz1SBdoBO4EU4Q5HLCtXLJW8EgM4jzqP
00dxe67N+SsT04R4oZY=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
W60eta8irdb38mdRDzCg4GlgwIYW3/Lru9l+tJih4ChBAcKfnfaR/vOiTL+ROuIZKJnwzJcrpzmt
gvCgGzHC7YTXilcaPZwKLJGNDJz1ephChHv+dU3RVUsAD/2hTtCy4ufxwBlvovQkfC/Lj1duYn0h
OSEhgHWR+DeMUPK2qQQbBb9ABKyCPg4Lz4jFlEL0WZOm0tl9WkZ2Rm3weM0zt1B539Waq4iEp23R
cjqiwLGibXKz4dVw0e8sQSzt2A1TAWBrBGX3u9QEmYGTRB5cP/N+EuOZmOBNhHzRMDgHUduPy9IS
T0HpKpqzIIZ0OwjalMVA697TIeOPpprjIuzHBQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
M3QC1E4EAgFwAqgbMpRj62ZSqGtwACtMfRQvzY5xpdVjwZ2o2aUOzqn08h+DpIbitujiMLpxPUyY
lcPiiMFuzADP0+HvnkKh+nqlni8Fnu+SpjDueyH4bQJ2dEx4L2m6E/ZRMYE/21qZ+IL9Mdwhy2zM
6J4NpTA3GU+XaQ48wh0=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Joy1pwH/OfLUGgLJRqMOST5TZobooPL/KHnb20ZjYwOKq7TVLXA6nkZ+J/8E9K70lSRvS1UpSRH0
t5Xf+iolfdIIM7/OPQhbsr7sGEWHdc0Q64eg+2GGAtSF2BZhsT705w77/DIW4nJKkUpC+VtMtRti
4i/AZB4v3m63KchVydIiWT2eypZaOcJdUaYuq7w3OS5NU1piGksgHh5Xb+szulbvxqFKE4Euv4Yx
O7uUo/+9PH/CzsgmGmKDh2HAp7VMhCk1Hmog74d7Pl7wyr3Y4dBrBBjw1c9mS9qqLDPt/gNTlehB
iOvhgs2sgiqrvmfcmcjLfXJB/a6mYZAOTPKzdA==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
g5GY+ruVbJTSNLBZAxKMjzWHqiIBBFLVm0mTIk/27vAJCn/7qN2eNybonN/BbLo0bhsIPnygWtUL
HnBzb30j9hTIkOmb4h3ghEtCopb8bWgen8W+K7lAXMMqSm7UP7SZS+oM+10KcJe73JRSORmhfQmO
1F9OJcu1SAirUVlJoJqHPQM+dVcXzqk6Cy0tnQfjOZzeDPrV6KdMtxexq8eq6tFX+nHwbh71bmwl
4OMHzfEhBHHlRAUDFfsH8FYwkZAH2dnFSqcyb8m+vXobKB4O1tVszhDIgza9r+ofijta9/KCeReP
oi5b+rs6mP4QE2kKqCEN3629NW5mbzUug9MxiA==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2021_01", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
HNsfBze5a6QtwiAVnGLfFdHHbrU0Oi1c4+CJlHFAOZfXnXZ/b0aEkATWnGGXfvTJAl/Vcr9Whmt+
ekNOhMdu6oXKJ+MJfm2u2jzE3biF+Xa2B9OUw2cnR3sWidPCSfrg1AS5LI2BdlfVD335L8jMJwSV
9dfiE+IthObOKpmZsPiY8zMjdsXwLNxi03pCI8Xly1WwfwvnPHx8W9QTlilHJGrd8NoS1J4RBmrZ
V4U7cpvPr5rFlz0kaBhufye7oY6yr+YRvjdzygxJ9Is4LecDDaRMF4r1PTAtwheEd5a3Fpb6OLzb
12VR4H77zZWEihgmoRyssQ/RlLdENnMf74PhDA==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
qajdWELb7xq5MRKDXqbY5G9KalZ6KvS/OFspNPgehavTLyCjfNFwOe7rD6u4OQ9DhpFj21XMOcHT
4IpirpdyiIXOWlDbI0L7UF7fg+oZhywH/4zzeLjKZ1VuNWMxku8tJIciokgfgS0Rc5zJRkFE1fFh
XqKbA8o5V2On2ZWFsxXRHCowiAVXpEbk4hoxIV8L5vuYfM+LmEAQrfNmzVr7ggxMKIAYY8HGsD5y
y68JxstiU/xG1rcmnjRIdeZIHXXBRuFGZjouuAthvqQCk4Aqa0dBLg1Pa5bvF8xwe+FNLdELWLsI
p4Imohkk8nqjgLE5kfHUvK6lNSUTJIGtfR7lWQ==

`pragma protect key_keyowner="Atrenta", key_keyname="ATR-SG-RSA-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=384)
`pragma protect key_block
G99JGOPeAWEzvhKOQHBjIJBTWpBqc6eHcwpnoconyJGsCO3rY4RPzw0sPWdTfUbZVf28/xzMdMAw
5Bl0VSYMJ3cfG3uenDKsZF2v9KBin+XsJwfKWs/gxK9A2D8qVJQyLd4ION84axXVPxfI5Gzv2FIm
d2V4C4p5YxpnLiGdskIrPJ2AAa4yZEeWuN01HCD/W+H9Ca3vsRn+2VmFDJbOHyec2GOMH66evWmZ
AlFNPDQSwT+6TVCHFXgpOYsFwwIg3mVZl2EBK7oPx1QESXZOnOLee+VELSumkJOFUI2v3kGFm4+2
yANu0tMCR+Ch57FICMokLG1y7s0yZ7DCuokjx1SKM3Ap/yHSSjBMyE6cOAjHL+oF9ZHdDbGV5v0U
s6Ses23kmJMCOcHQDKgORHBaU5DaZgcdobyCs2MMkJo9CarOL4u/Feim00de/2xjgBS0jQPmVxYI
DV5Y6z4b2qpXJD9yvkwweqY8ZifrG3dHasuUscjtRiYqbLIMonADOsos

`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="CDS_RSA_KEY_VER_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Yg8e7EeHtxErkKZVvi6QJXJCvHzYThtbtZDWYWwhr0hMZCh7wlRPMUDcoEsUXREL9HKBlNIU/8Ip
RFJXEQyG4fzyXOfxoqTV5aFAlBcJbbBITUlrf6b/PM/ef8SPakuJVxDFuGpznAfWV7MaQwD4pGCi
1hZVmFLCjiNVZ/pcZslIeU1yCGclZYjf4Ru+ChXq4zcRuRDybOhAnvOk6/sQJZHGiDiA/H5Lghki
plk50q2/VS4rx+xPeNogEvz/tKK3mUhK/3Sx0BqDTR9u+8Ltxs+0gK55oKH0CNj0HtBdvVId3fDy
w5WvPz8SmltzhMCYDtDP+iKXf+EKR9m/Co0FQA==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-PREC-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
jqXccf3FYTYIsjLFTWfGeXX9neNj9SzK+xwl8PZWHRxceOwes83g/TMd63nsGTue5T9vNgHH8fu6
4vnRukf7lPz12sTWg8Er9PEwbj0Dq3vyc+W/FASq7CLPbRfMJtpj71JLlAg/J+UxpHlYjQH20w7m
sp8/MEe3jdqqYRK3ZPtHzlRhAzZHI6/iAwV6o+tfCngegn0W2/svBdwOIxYUj3u4iIyqfHzUxgTW
VN/kdsxJqV1zxKTCnZOIgTjUlWpJYdx/SeFSzTO7+lW+nCqieofGXn0aiMeJhjESpDyO7Jzo6IEC
SoVsWK7rzAvX3prLChsZUR1WM4T+HS9XduMplw==

`pragma protect key_keyowner="Synplicity", key_keyname="SYNP15_1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
q4gPj3XlVr0ooh8QFK0FHQWDk+Pbc3eehA0w+ch3edp+2tvwHrK7NVKhi158rl/GoZZLMYADD7dC
kAwtr/lD7rAlk5/Xo+Gql2rQWvw1ajNLQOKnXkWaNIxEWGAi9vOCoSMq7NJhZCF62qJlpiPlVehH
8wSVQYmneegXioGhm6rN8SNPOuggjb5WMVH4R9TZa6Hdvf9xXcbUCJA1CpbI8/rImYkvsKxvopGu
NisMv37rIkQx80JbFO46l/eph3uF83Hj2pBDHH/cnxj2jQ7vye38xwoviPUqAzB4IRO2xr12hfoE
jy8SE/UVT4nFodEqdk4sUkA88Mu8qYwS9G8jig==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 12192)
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
