module keygen(
    input       wire                clk,
    input       wire                rstn,

    // 公钥 FIFO接口
    output      wire                fifo_empty_pk,
    output      wire    [7 : 0]     fifo_dout_pk,
    input       wire                fifo_en_pk,
    input       wire                fifo_clk_pk,

    // 私钥 FIFO接口
    output      wire                fifo_empty_sk,
    output      wire    [7 : 0]     fifo_dout_sk,
    input       wire                fifo_en_sk,
    input       wire                fifo_clk_sk,

    output      wire                keygen_done
);

wire        [255 : 0]   zeta; // 32字节 种子
wire        [7 : 0]     pk; // 单字节 公钥
wire        [7 : 0]     sk; // 单字节 私钥



endmodule