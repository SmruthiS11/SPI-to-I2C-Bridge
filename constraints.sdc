set EXTCLK "clk" ;
set_units -time 0.031ns;
set EXTCLK_PERIOD 20.0;
create_clock -name "$EXTCLK" -period "$EXTCLK_PERIOD" -waveform "0 [expr $EXTCLK_PERIOD/2]" [get_ports i_Clk]

set SKEW 0.200
set_clock_uncertainty $SKEW [get_clocks $EXTCLK]

set SRLATENCY 0.80
set SFLATENCY 0.75

set MINRISE  0.20
set MAXRISE  0.25
set MINFALL  0.15
set MAXFALL  0.10
set_clock_transition -rise -min $MINRISE [get_clocks $EXTCLK]
set_clock_transition -rise -max $MAXRISE [get_clocks $EXTCLK]
set_clock_transition -fall -min $MINFALL [get_clocks $EXTCLK]
set_clock_transition -fall -max $MAXFALL [get_clocks $EXTCLK]

set INPUT_DELAY 0.5
set OUTPUT_DELAY 0.5

set INPUT_DELAY 0.5
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports i_Rst_L]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports i_Clk]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports spi_clk]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports spi_mosi]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports i2c_clk]
set_input_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports i2c_address]



set OUTPUT_DELAY 0.5
set_output_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports i2c_sda]
set_output_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports i2c_scl]
set_output_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports o_rx_byte]
set_output_delay -clock [get_clocks $EXTCLK] -add_delay 0.3 [get_ports rx_dv]
