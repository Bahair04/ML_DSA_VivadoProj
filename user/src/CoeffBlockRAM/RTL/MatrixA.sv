module MatrixA(
    // --- 时钟和复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- Matrix A ---
    input       logic           [91 : 0]    w_MatrixA_Coeff,
    input       logic                       w_MatrixA_Coeff_valid,
    input       logic           [11 : 0]    w_MatrixA_Coeff_addr,
    output      logic           [22 : 0]    r_MatrixA_Coeff,
    input       logic                       r_MatrixA_Coeff_request,
    input       logic           [13 : 0]    r_MatrixA_Coeff_addr
);

logic   [22 : 0]    doutb;

MatrixA_CoeffRAM u_MatrixA_CoeffRAM (
  .clka(clk),    // input wire clka
  .ena(w_MatrixA_Coeff_valid),      // input wire ena
  .wea(w_MatrixA_Coeff_valid),      // input wire [0 : 0] wea
  .addra(w_MatrixA_Coeff_addr),  // input wire [11 : 0] addra
  .dina(w_MatrixA_Coeff),    // input wire [91 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(r_MatrixA_Coeff_request),      // input wire enb
  .addrb(r_MatrixA_Coeff_addr),  // input wire [13 : 0] addrb
  .doutb(doutb)  // output wire [22 : 0] doutb
);

assign r_MatrixA_Coeff = doutb;

endmodule
