module Gen_A(
    // --- 时钟与复位接口 ---
    input       wire                clk,
    input       wire                rstn,

    // --- SHA3控制接口 ---
    input       wire                init,   // SHA复位信号
    
    // --- ExpandA控制接口 ---
    input       wire    [255 : 0]   rho,    // 256 - bit 随机种子                
    input       wire                start,  // 开始生成多项式矩阵
    output      wire                done,   // 多项式矩阵生成完成信号
    output      wire    [22 : 0]    coeff


);


endmodule
