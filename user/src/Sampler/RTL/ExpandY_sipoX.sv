`include "../../param_conf.v"
module ExpandY_sipoX
#(
    parameter BIT_COUNT = `bit_count
)(
    // --- 时钟与复位接口 ---
    input       logic               clk,
    input       logic               rstn,

    // --- 顶层(ExpandA)传入的控制与数据接口 ---
    input       logic               init,
    input       logic   [63 : 0]    st_64bit,
    input       logic               st_64bit_valid,

    // --- 4 * `BIT_COUNT位并行输出接口 ---
    output      logic   [4 * `bit_count - 1 : 0]   
                                    sipo_o,
    output      logic               sipo_o_valid
);

generate
    if (BIT_COUNT == 'd18) begin // 18 * 4
        ExpandY_sipo72 u_ExpandY_sipo72(
            .clk                (clk            ),
            .rstn               (rstn           ),

            .init               (init           ),
            .st_64bit           (st_64bit       ),
            .st_64bit_valid     (st_64bit_valid ),

            .sipo_o             (sipo_o         ),
            .sipo_o_valid       (sipo_o_valid   )
        );
    end
    else begin // 20 * 4
        ExpandY_sipo80 u_ExpandY_sipo80(
            .clk                (clk            ),
            .rstn               (rstn           ),

            .init               (init           ),
            .st_64bit           (st_64bit       ),
            .st_64bit_valid     (st_64bit_valid ),

            .sipo_o             (sipo_o         ),
            .sipo_o_valid       (sipo_o_valid   )
        );
    end
endgenerate

endmodule