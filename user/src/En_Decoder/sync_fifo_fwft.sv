module sync_fifo_fwft #(
    parameter DATA_WIDTH = 135,
    parameter DEPTH      = 256
)(
    input  logic                    clk,
    input  logic                    rstn,
    
    input  logic                    wr_en,
    input  logic [DATA_WIDTH-1 : 0] din,
    
    input  logic                    rd_en,
    output logic [DATA_WIDTH-1 : 0] dout,
    output logic                    empty,
    output logic                    full
);

localparam ADDR_WIDTH = $clog2(DEPTH);

// 强制使用 BRAM 以节省寄存器资源
(* ram_style = "block" *) logic [DATA_WIDTH-1 : 0] mem [0 : DEPTH-1];

logic [ADDR_WIDTH : 0] wr_ptr;
logic [ADDR_WIDTH : 0] rd_ptr;

// 写逻辑
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        wr_ptr <= 'd0;
    end 
    else if (wr_en && !full) begin
        mem[wr_ptr[ADDR_WIDTH-1 : 0]] <= din;
        wr_ptr <= wr_ptr + 1'b1;
    end
end

// 读指针逻辑
always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        rd_ptr <= 'd0;
    end 
    else if (rd_en && !empty) begin
        rd_ptr <= rd_ptr + 1'b1;
    end
end

// 空满判定
assign empty = (wr_ptr == rd_ptr);
assign full  = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) && 
                (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

// FWFT 输出：读指针直接索引当前最新的头部数据
assign dout = mem[rd_ptr[ADDR_WIDTH-1 : 0]];

endmodule