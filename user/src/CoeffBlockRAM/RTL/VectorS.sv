module VectorS(
    // --- 时钟和复位信号 ---
    input       logic               clk,
    input       logic               rstn,

    // --- Vector S ---
    input       logic   signed  [15 : 0]    w_VectorS_Coeff,            // 4*4bit有符号数
    input       logic                       w_VectorS_Coeff_valid,
    input       logic           [9 : 0]     w_VectorS_Coeff_addr,
    output      logic           [22 : 0]    r_VectorS_Coeff,            // 对q取模 无符号
    input       logic                       r_VectorS_Coeff_request,
    input       logic           [11 : 0]    r_VectorS_Coeff_addr
);

logic   signed  [3 : 0]         doutb; 

VectorS_CoeffRAM u_VectorS_CoeffRAM (
  .clka(clk),    // input wire clka
  .ena(w_VectorS_Coeff_valid),      // input wire ena
  .wea(w_VectorS_Coeff_valid),      // input wire [0 : 0] wea
  .addra(w_VectorS_Coeff_addr),  // input wire [9 : 0] addra
  .dina(w_VectorS_Coeff),    // input wire [15 : 0] dina
  .clkb(clk),    // input wire clkb
  .enb(r_VectorS_Coeff_request),      // input wire enb
  .addrb(r_VectorS_Coeff_addr),  // input wire [11 : 0] addrb
  .doutb(doutb)  // output wire [3 : 0] doutb
);

always_comb begin
    if (doutb[3])
        r_VectorS_Coeff = {{19{doutb[3]}}, doutb} + `q;
    else 
        r_VectorS_Coeff = {{19{doutb[3]}}, doutb};
end

endmodule
