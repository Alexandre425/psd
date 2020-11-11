## This file is a general .xdc for the Lab2 Project
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

## Clock signal
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 15.000 -name sys_clk_pin -add [get_ports clk]

## Constraints on INPUTS and OUTPUTS ports
set_input_delay -clock [get_clocks *] 0.000 [get_ports * -filter { NAME !~ "clk" && DIRECTION == "IN" }]
set_output_delay -clock [get_clocks *] 0.000 [get_ports * -filter { NAME =~  "*" && DIRECTION == "OUT" }]

##
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]


#### Assign pin and other proprieties to FPGA external signals

set_property PACKAGE_PIN W5 [get_ports clk]
set_property PACKAGE_PIN D18 [get_ports reset]

set_property PACKAGE_PIN D17 [get_ports we]
set_property PACKAGE_PIN E19 [get_ports done]

set_property PACKAGE_PIN M1 [get_ports {addr[9]}]
set_property PACKAGE_PIN N2 [get_ports {addr[8]}]
set_property PACKAGE_PIN N1 [get_ports {addr[7]}]
set_property PACKAGE_PIN N3 [get_ports {addr[6]}]
set_property PACKAGE_PIN P3 [get_ports {addr[5]}]
set_property PACKAGE_PIN P1 [get_ports {addr[4]}]
set_property PACKAGE_PIN D19 [get_ports {addr[3]}]
set_property PACKAGE_PIN G18 [get_ports {addr[2]}]
set_property PACKAGE_PIN F18 [get_ports {addr[1]}]
set_property PACKAGE_PIN E18 [get_ports {addr[0]}]

set_property PACKAGE_PIN N19 [get_ports {dataOUT[31]}]
set_property PACKAGE_PIN P19 [get_ports {dataOUT[30]}]
set_property PACKAGE_PIN R19 [get_ports {dataOUT[29]}]
set_property PACKAGE_PIN M18 [get_ports {dataOUT[28]}]
set_property PACKAGE_PIN M19 [get_ports {dataOUT[27]}]
set_property PACKAGE_PIN L17 [get_ports {dataOUT[26]}]
set_property PACKAGE_PIN K17 [get_ports {dataOUT[25]}]
set_property PACKAGE_PIN N17 [get_ports {dataOUT[24]}]
set_property PACKAGE_PIN P17 [get_ports {dataOUT[23]}]
set_property PACKAGE_PIN P18 [get_ports {dataOUT[22]}]
set_property PACKAGE_PIN R18 [get_ports {dataOUT[21]}]
set_property PACKAGE_PIN U19 [get_ports {dataOUT[20]}]
set_property PACKAGE_PIN V19 [get_ports {dataOUT[19]}]
set_property PACKAGE_PIN W18 [get_ports {dataOUT[18]}]
set_property PACKAGE_PIN W19 [get_ports {dataOUT[17]}]
set_property PACKAGE_PIN T17 [get_ports {dataOUT[16]}]
set_property PACKAGE_PIN T18 [get_ports {dataOUT[15]}]
set_property PACKAGE_PIN U17 [get_ports {dataOUT[14]}]
set_property PACKAGE_PIN U18 [get_ports {dataOUT[13]}]
set_property PACKAGE_PIN V16 [get_ports {dataOUT[12]}]
set_property PACKAGE_PIN V17 [get_ports {dataOUT[11]}]
set_property PACKAGE_PIN W16 [get_ports {dataOUT[10]}]
set_property PACKAGE_PIN W17 [get_ports {dataOUT[9]}]
set_property PACKAGE_PIN V15 [get_ports {dataOUT[8]}]
set_property PACKAGE_PIN W15 [get_ports {dataOUT[7]}]
set_property PACKAGE_PIN W13 [get_ports {dataOUT[6]}]
set_property PACKAGE_PIN W14 [get_ports {dataOUT[5]}]
set_property PACKAGE_PIN U15 [get_ports {dataOUT[4]}]
set_property PACKAGE_PIN U16 [get_ports {dataOUT[3]}]
set_property PACKAGE_PIN V13 [get_ports {dataOUT[2]}]
set_property PACKAGE_PIN V14 [get_ports {dataOUT[1]}]
set_property PACKAGE_PIN U14 [get_ports {dataOUT[0]}]


set_property IOSTANDARD LVCMOS33 [get_ports *]

set_property DRIVE 12 [get_ports * -filter { NAME =~  "addr*" && DIRECTION == "OUT" }]
set_property DRIVE 12 [get_ports * -filter { NAME =~  "dataOUT*" && DIRECTION == "OUT" }]


