set_clock_latency 0.5  [get_clocks {clk_p_i}]
set_clock_latency -source -early -min -rise  -0.043629 [get_ports {clk_p_i}] -clock clk_p_i 
set_clock_latency -source -early -min -fall  0.0643837 [get_ports {clk_p_i}] -clock clk_p_i 
set_clock_latency -source -late -min -rise  -0.043629 [get_ports {clk_p_i}] -clock clk_p_i 
set_clock_latency -source -late -min -fall  0.0643837 [get_ports {clk_p_i}] -clock clk_p_i 
