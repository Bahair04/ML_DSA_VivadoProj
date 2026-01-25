`include "../param_conf.v"
module _keygen_internal(
    input       wire                clk,
    input       wire                rstn,

    input       wire    [255 : 0]   zeta, // 32字节 种子
    output      wire    [7 : 0]     pk, // 单字节 公钥
    output      wire    [7 : 0]     sk // 单字节 私钥
);

wire    [271 : 0]               seed_domain_sep = {zeta, `k, `l};
wire    [127 : 0]               seed_bytes;
wire    [31 : 0]                rho;
wire    [63 : 0]                rho_prime;
wire    [31 : 0]                K;
assign {rho, rho_prime, K} = seed_bytes[127 : 0];


endmodule