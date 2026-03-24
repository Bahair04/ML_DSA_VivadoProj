# 定义一个名为 sys_clk 的时钟，绑定到顶层端口 clk 上，周期为 10.0ns (即 100MHz)
create_clock -period 10.000 -name sys_clk [get_ports clk]