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

always_comb begin
    rom_addr1 = 'd0;
    rom_addr2 = 'd0;
    rom_addr3 = 'd0;
    if (rom_request) begin
        rom_addr1 = {j, 2'b10} << (stage << 1);
        rom_addr2 = {j, 1'b1} << (stage << 1);
        rom_addr3 = ({j, 1'b1} + (N >> 1)) << (stage << 1);
        if (mode_config == 1) begin
            rom_addr1 = 256 - rom_addr1;
            rom_addr2 = 256 - rom_addr2;
            rom_addr3 = 256 - rom_addr3;
        end
    end
end

always_ff @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        i <= 'd0;
        j <= 'd0;
        N <= 'd0;
        stage <= 'd0;
        interval <= 'd0;
        output_finish <= 1'b0;
    end
    else if (rom_request) begin
        if (mode_config == 0 && $signed(stage) >= 0) begin
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
            if (j == j_boundary - 1) begin
                j <= 'd0;
                if (i == i_boundary - 1) begin
                    i <= 'd0;
                    interval <= interval >> 2;
                    N <= N >> 2;
                    if ($signed(stage) == 3)
                        output_finish <= 1'b1;
                    stage <= stage + 1;
                end
                else 
                    i <= i + 1;
            end
            else 
                j <= j + 1;
        end
        else 
            output_finish <= 1'b0;
    end
    else begin
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
