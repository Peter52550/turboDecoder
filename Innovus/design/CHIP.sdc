###################################################################

# Created by write_sdc on Thu Jun  3 00:40:45 2021

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -voltage V -current mA
set_max_fanout 6 [current_design]
set_max_area 0
set_load -pin_load 1 [get_ports {data_o[4]}]
set_load -pin_load 1 [get_ports {data_o[3]}]
set_load -pin_load 1 [get_ports {data_o[2]}]
set_load -pin_load 1 [get_ports {data_o[1]}]
set_load -pin_load 1 [get_ports {data_o[0]}]
set_load -pin_load 1 [get_ports done_o]
create_clock [get_ports clk_p_i]  -period 10  -waveform {0 5}
set_clock_latency 0.5  [get_clocks clk_p_i]
set_clock_uncertainty 0.1  [get_clocks clk_p_i]
set_input_delay -clock clk_p_i  -max 1  [get_ports clk_p_i]
set_input_delay -clock clk_p_i  -max 1  [get_ports reset_n_i]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[20]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[19]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[18]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[17]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[16]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[15]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[14]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[13]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[12]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[11]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[10]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[9]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[8]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[7]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[6]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[5]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[4]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[3]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[2]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[1]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports {data_i[0]}]
set_input_delay -clock clk_p_i  -max 1  [get_ports start_i]
set_output_delay -clock clk_p_i  -min 0.5  [get_ports {data_o[4]}]
set_output_delay -clock clk_p_i  -min 0.5  [get_ports {data_o[3]}]
set_output_delay -clock clk_p_i  -min 0.5  [get_ports {data_o[2]}]
set_output_delay -clock clk_p_i  -min 0.5  [get_ports {data_o[1]}]
set_output_delay -clock clk_p_i  -min 0.5  [get_ports {data_o[0]}]
set_output_delay -clock clk_p_i  -min 0.5  [get_ports done_o]
set_drive 1  [get_ports clk_p_i]
set_drive 1  [get_ports reset_n_i]
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
set_drive 1  [get_ports start_i]
