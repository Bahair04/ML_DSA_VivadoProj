`define ML_DSA_44

`ifdef ML_DSA_44

    `define n               256
    `define q               8380417
    `define d               13
    `define tau             39
    `define gamma_1         131072
    `define gamma_2         95232
    `define k               8'd4
    `define l               8'd4
    `define eta             2
    `define omega           80
    `define bit_count       18
    `define total_bits      4608        // 576 * 8
    `define c_tilde_bytes   32
    `define input_width     24

`endif

`ifdef ML_DSA_65

    `define n               256
    `define q               8380417
    `define d               13
    `define tau             49
    `define gamma_1         524288
    `define gamma_2         261888
    `define k               8'd6
    `define l               8'd5
    `define eta             4
    `define omega           55
    `define bit_count       20
    `define total_bits      5120        // 640 * 8
    `define c_tilde_bytes   48
    `define input_width     16

`endif

`ifdef ML_DSA_87

    `define n               256
    `define q               8380417
    `define d               13
    `define tau             60
    `define gamma_1         524288
    `define gamma_2         261888
    `define k               8'd8
    `define l               8'd7
    `define eta             2
    `define omega           75
    `define bit_count       20
    `define total_bits      5120        // 640 * 8
    `define c_tilde_bytes   64
    `define input_width     16

`endif

