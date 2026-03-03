//* Mode: First Word Fall through 0 - latency
//* 可以同时生成3个zeta地址，给到ROM中 延迟为0，产生output_finish表示结束。一共生成256个地址 
//* mode_config配置必须提前于rom_request至少一个时钟周期
module ZetaRomAddrGen(
    // --- 时钟和复位信号 ---
    input       logic                   clk,
    input       logic                   rstn,

    // --- 旋转因子地址产生单元模式选择 ---
    input       logic                   mode_config,        // 0: NTT 1: INTT

    // --- 输入输出端口 ---
    input       logic                   rom_request,
    output      logic   [7 : 0]         rom_addr_out1,
    output      logic   [7 : 0]         rom_addr_out2,
    output      logic   [7 : 0]         rom_addr_out3,
    output      logic                   output_finish
);

logic   [7 : 0]             interval;
logic   [7 : 0]             i;
logic   [7 : 0]             j;
logic   [8 : 0]             N;
logic   signed  [3 : 0]     stage;
logic   [7 : 0]             rom_addr1, rom_addr2, rom_addr3;

logic   [7 : 0]             i_boundary;
logic   [7 : 0]             j_boundary;

always_comb begin
    i_boundary = 1'b0;
    j_boundary = 1'b0;
    if (rom_request) begin
        case (interval)
            'd1 : i_boundary = 'd64;
            'd4 : i_boundary = 'd16;
            'd16: i_boundary = 'd4;
            'd64: i_boundary = 'd1;
        endcase
        j_boundary = interval;
    end
end

logic   [5 : 0]             j_rev;
logic   [5 : 0]             j_eff; 

always_comb begin
    // 根据不同的 stage (interval的位宽不同)，对计数器 j 进行不同位数的倒序
    case (stage)
        'd3: j_rev = 6'd0;                                     // Interval = 1, j=0
        'd2: j_rev = {4'd0, j[0], j[1]};                       // Interval = 4, 2-bit倒序
        'd1: j_rev = {2'd0, j[0], j[1], j[2], j[3]};           // Interval = 16, 4-bit倒序
        'd0: j_rev = {j[0], j[1], j[2], j[3], j[4], j[5]};     // Interval = 64, 6-bit倒序
        default: j_rev = 6'd0;
    endcase
end

// NTT 使用倒序的 j_rev，而 INTT 使用线性的 j
assign j_eff = (mode_config == 0) ? j_rev : j[5:0];

always_comb begin
    rom_addr1 = 'd0;
    rom_addr2 = 'd0;
    rom_addr3 = 'd0;
    if (rom_request) begin
        // 统一用 j_eff 代替原有的 j_rev
        rom_addr1 = {j_eff, 2'b10} << (stage << 1);
        rom_addr2 = {j_eff, 1'b1} << (stage << 1);
        rom_addr3 = ({j_eff, 1'b1} + (N >> 1)) << (stage << 1);
        if (mode_config == 1) begin
            rom_addr1 = 256 - rom_addr1;
            rom_addr2 = 256 - rom_addr2;
            rom_addr3 = 256 - rom_addr3;
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        if (mode_config == 0) begin
            stage <= 'd3;
            interval <= 'd1;
            N <= 'd4;
            i <= 'd0;
            j <= 'd0;
        end
        else if (mode_config == 1) begin
            stage <= 'd0;
            interval <= 'd64;
            N <= 'd256;
            i <= 'd0;
            j <= 'd0;
        end
        output_finish <= 1'b0;
    end
    else if (rom_request) begin
        if (mode_config == 0 && $signed(stage) >= 0) begin
            // 【NTT 模式】：j 是内层循环 (交替输出不同地址)，i 是外层循环
            if (j == j_boundary - 1) begin
                j <= 'd0;
                if (i == i_boundary - 1) begin
                    i <= 'd0;
                    interval <= interval << 2;
                    N <= N << 2;
                    if ($signed(stage) == 0)
                        output_finish <= 1'b1;
                    stage <= stage - 1;
                end
                else 
                    i <= i + 1;
            end
            else 
                j <= j + 1;
        end
        else if (mode_config == 1 && $signed(stage) <= 3) begin
            // 【INTT 模式】：i 是内层循环 (连续输出相同地址)，j 是外层循环 (矩阵转置效果)
            if (i == i_boundary - 1) begin
                i <= 'd0;
                if (j == j_boundary - 1) begin
                    j <= 'd0;
                    interval <= interval >> 2;
                    N <= N >> 2;
                    if ($signed(stage) == 3)
                        output_finish <= 1'b1;
                    stage <= stage + 1;
                end
                else 
                    j <= j + 1;
            end
            else 
                i <= i + 1;
        end
        else 
            output_finish <= 1'b0;
    end
    else if (output_finish) begin
        if (mode_config == 0) begin
            stage <= 'd3;
            interval <= 'd1;
            N <= 'd4;
            i <= 'd0;
            j <= 'd0;
        end
        else if (mode_config == 1) begin
            stage <= 'd0;
            interval <= 'd64;
            N <= 'd256;
            i <= 'd0;
            j <= 'd0;
        end
        output_finish <= 1'b0;
    end
end

always_comb begin
    rom_addr_out1 = 'd0;
    rom_addr_out2 = 'd0;
    rom_addr_out3 = 'd0;
    if (rom_request) begin
        rom_addr_out1 = rom_addr1;
        rom_addr_out2 = rom_addr2;
        rom_addr_out3 = rom_addr3;
    end
    else begin
        if (mode_config == 0) begin
            rom_addr_out1 = 'd128;
            rom_addr_out2 = 'd64;
            rom_addr_out3 = 'd192;
        end
        else if (mode_config == 1) begin
            rom_addr_out1 = 'd254;
            rom_addr_out2 = 'd255;
            rom_addr_out3 = 'd127;
        end
        else begin
            rom_addr_out1 = 'd0;
            rom_addr_out2 = 'd0;
            rom_addr_out3 = 'd0;
        end
    end
end

endmodule