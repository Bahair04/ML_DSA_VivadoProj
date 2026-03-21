`timescale 1ns / 1ps

module inferred_bram #(
    parameter DEPTH = 4096,      // 深度：4096
    parameter ADDR_WIDTH = 12,   // 地址线宽：log2(4096) = 12
    parameter DATA_WIDTH = 23    // 数据线宽：23 bit
)(
    input  logic                    clk,
    
    // --- 写端口 (Port A) ---
    input  logic                    we,         // 写使能
    input  logic [ADDR_WIDTH-1:0]   wr_addr,    // 写地址
    input  logic [DATA_WIDTH-1:0]   wr_data,    // 写数据
    
    // --- 读端口 (Port B) ---
    input  logic [ADDR_WIDTH-1:0]   rd_addr,    // 读地址
    output logic [DATA_WIDTH-1:0]   rd_data     // 读数据 (延迟1拍输出)
);

// 核心 1：声明内存数组，并强制施加 BRAM 属性约束
(* ram_style = "block" *) logic [DATA_WIDTH-1:0] poly_matrix [0 : DEPTH-1];

initial begin
    for (int i = 0; i < DEPTH; i = i + 1) begin
        poly_matrix[i] = 'd0; 
    end
end

// 核心 2：纯同步的读写行为描述
always_ff @(posedge clk) begin
    // 同步写
    if (we) begin
        poly_matrix[wr_addr] <= wr_data;
    end
    
    // 同步读（必须和时钟沿同步！）
    rd_data <= poly_matrix[rd_addr]; 
end

endmodule