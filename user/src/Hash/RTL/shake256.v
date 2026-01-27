module shake256(
    // --- 时钟与复位信号 ---
    input       wire                clk,
    input       wire                rstn,
    
    // --- 串行数据输入接口 ---
    input       wire    [7 : 0]     din,
    input       wire                din_valid,

    // --- 控制接口 ---
    input       wire                init,           // 复位信号上层模块控制
    input       wire                start,          // 开始更新数据信号 上层模块控制
    output      wire                done_out,       // 挤出数据结束信号

    // --- 串行数据输出接口 ---
    output      wire    [63 : 0]    st_64bit,
    output      wire                st_64bit_valid
    

);

// ==========================================================
// 参数定义
// ==========================================================
wire        	done;                   // update与xof完成信号
reg             start_out;              // 开始挤出数据
reg     [3 : 0] done_d;                 // 延时信号

// ==========================================================
// 控制逻辑实现
// ==========================================================
// --------------------------------
// 信号延时
// --------------------------------
always @(posedge clk or negedge rstn) begin
    if (!rstn)
        done_d <= 'd0;
    else 
        done_d <= {done_d[2 : 0], done};
end

// --------------------------------
// 延时3个时钟周期后开始挤出数据
// --------------------------------
always @(posedge clk or negedge rstn) begin
    if (!rstn)
        start_out <= 1'b0;
    else if (done_d[3])
        start_out <= 1'b1;
    else 
        start_out <= 1'b0;
end

// ==========================================================
// shake256 例化
// ==========================================================
sha3 u_shake256(
	.clk           	( clk                   ),
	.rstn          	( rstn                  ),
	.din           	( din                   ),
	.din_valid     	( din_valid             ),
	.din_len       	( 'd34                  ),
	.mdlen         	( 'd32                  ),
	.init          	( init                  ),
	.start         	( start                 ),
	.done          	( done                  ),
	.start_out     	( start_out             ),
	.out_len       	( 'd128                 ),
	.done_out      	( done_out              ),
	.st_64bit       ( st_64bit                     ),
	.st_64bit_valid ( st_64bit_valid               )
);


endmodule
