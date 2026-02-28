module VectorY(
    // --- 时钟和复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- Vector Y ---
    input       logic   signed  [79 : 0]    w_VectorY_Coeff,            // 4*20bit有符号数
    input       logic                       w_VectorY_Coeff_valid,
    input       logic           [5 : 0]     w_VectorY_Coeff_addr,
    output      logic           [22 : 0]    r_VectorY_Coeff,            // 对q取模 无符号
    input       logic                       r_VectorY_Coeff_request,
    input       logic           [7 : 0]     r_VectorY_Coeff_addr
);

logic   signed  [19 : 0]        doutb;

VectorY_CoeffRAM u_VectorY_CoeffRAM (
  .clka(clk),    // input wire clka
  .ena(w_VectorY_Coeff_valid),      // input wire ena
  .wea(w_VectorY_Coeff_valid),      // input wire [0 : 0] wea
  .addra(w_VectorY_Coeff_addr),  // input wire [5 : 0] addra
  .dina(w_VectorY_Coeff),   // input wire [79 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(r_VectorY_Coeff_request),      // input wire enb
  .addrb(r_VectorY_Coeff_addr),  // input wire [7 : 0] addrb
  .doutb(doutb)  // output wire [19 : 0] doutb
);

always_comb begin
    if (doutb[19])
        r_VectorY_Coeff = {{3{doutb[19]}}, doutb} + `q;
    else 
        r_VectorY_Coeff = {{3{doutb[19]}}, doutb};
end

endmodule
