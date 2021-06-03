###############################################################
#  Generated by:      Cadence Innovus 17.11-s080_1
#  OS:                Linux x86_64(Host ID cad29)
#  Generated on:      Thu Jun  3 19:41:54 2021
#  Design:            CHIP
#  Command:           saveDesign DBS/route
###############################################################
current_design CHIP
create_clock [get_ports {clk_p_i}]  -name clk_p_i -period 10.000000 -waveform {0.000000 5.000000}
set_propagated_clock  [get_ports {clk_p_i}]
set_drive 1  [get_ports {clk_p_i}]
set_drive 1  [get_ports {reset_n_i}]
set_drive 1  [get_ports {data_i[20]}]
set_drive 1  [get_ports {data_i[19]}]
set_drive 1  [get_ports {data_i[18]}]
set_drive 1  [get_ports {data_i[17]}]
set_drive 1  [get_ports {data_i[16]}]
set_drive 1  [get_ports {data_i[15]}]
set_drive 1  [get_ports {data_i[14]}]
set_drive 1  [get_ports {data_i[13]}]
set_drive 1  [get_ports {data_i[12]}]
set_drive 1  [get_ports {data_i[11]}]
set_drive 1  [get_ports {data_i[10]}]
set_drive 1  [get_ports {data_i[9]}]
set_drive 1  [get_ports {data_i[8]}]
set_drive 1  [get_ports {data_i[7]}]
set_drive 1  [get_ports {data_i[6]}]
set_drive 1  [get_ports {data_i[5]}]
set_drive 1  [get_ports {data_i[4]}]
set_drive 1  [get_ports {data_i[3]}]
set_drive 1  [get_ports {data_i[2]}]
set_drive 1  [get_ports {data_i[1]}]
set_drive 1  [get_ports {data_i[0]}]
set_drive 1  [get_ports {start_i}]
set_load -pin_load -max  1  [get_ports {data_o[4]}]
set_load -pin_load -min  1  [get_ports {data_o[4]}]
set_load -pin_load -max  1  [get_ports {data_o[3]}]
set_load -pin_load -min  1  [get_ports {data_o[3]}]
set_load -pin_load -max  1  [get_ports {data_o[2]}]
set_load -pin_load -min  1  [get_ports {data_o[2]}]
set_load -pin_load -max  1  [get_ports {data_o[1]}]
set_load -pin_load -min  1  [get_ports {data_o[1]}]
set_load -pin_load -max  1  [get_ports {data_o[0]}]
set_load -pin_load -min  1  [get_ports {data_o[0]}]
set_load -pin_load -max  1  [get_ports {done_o}]
set_load -pin_load -min  1  [get_ports {done_o}]
set_max_fanout 6  [get_designs {CHIP}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[6]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[4]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[2]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[18]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[0]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[16]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {reset_n_i}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[14]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[12]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {start_i}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[10]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[9]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[7]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[5]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[3]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[19]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[1]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[17]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[15]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[13]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[20]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[11]}]
set_input_delay -add_delay 1 -max -clock [get_clocks {clk_p_i}] [get_ports {data_i[8]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk_p_i}] [get_ports {data_o[3]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk_p_i}] [get_ports {data_o[1]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk_p_i}] [get_ports {data_o[4]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk_p_i}] [get_ports {data_o[2]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk_p_i}] [get_ports {data_o[0]}]
set_output_delay -add_delay 0.5 -min -clock [get_clocks {clk_p_i}] [get_ports {done_o}]
set_clock_uncertainty 0.1 [get_clocks {clk_p_i}]
