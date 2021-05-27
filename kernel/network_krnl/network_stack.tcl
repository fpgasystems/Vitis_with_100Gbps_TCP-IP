#IPs used in network_stack.sv


#Register slices

create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name net_axis_register_slice_64 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {8} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1}] [get_ips net_axis_register_slice_64]

#FIFO / RX Buffer
create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_32_d1024
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.FIFO_DEPTH {1024} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1} CONFIG.Component_Name {axis_data_fifo_32_d1024}] [get_ips axis_data_fifo_32_d1024]

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_64_d1024
set_property -dict [list CONFIG.TDATA_NUM_BYTES {8} CONFIG.FIFO_DEPTH {1024} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1} CONFIG.Component_Name {axis_data_fifo_64_d1024}] [get_ips axis_data_fifo_64_d1024]

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_32_d256
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.FIFO_DEPTH {256} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1} CONFIG.Component_Name {axis_data_fifo_32_d256}] [get_ips axis_data_fifo_32_d256]

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_64_d256
set_property -dict [list CONFIG.TDATA_NUM_BYTES {8} CONFIG.FIFO_DEPTH {256} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1} CONFIG.Component_Name {axis_data_fifo_64_d256}] [get_ips axis_data_fifo_64_d256]

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_72_d256
set_property -dict [list CONFIG.TDATA_NUM_BYTES {9} CONFIG.FIFO_DEPTH {256} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1} CONFIG.Component_Name {axis_data_fifo_72_d256}] [get_ips axis_data_fifo_72_d256]

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_128_d1024 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {16} CONFIG.FIFO_DEPTH {1024} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1} CONFIG.Component_Name {axis_data_fifo_128_d1024}] [get_ips axis_data_fifo_128_d1024]

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_256_d1024 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {32} CONFIG.FIFO_DEPTH {1024} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1} CONFIG.Component_Name {axis_data_fifo_256_d1024}] [get_ips axis_data_fifo_256_d1024]

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_512_d1024 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {64} CONFIG.FIFO_DEPTH {1024} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1} CONFIG.Component_Name {axis_data_fifo_512_d1024}] [get_ips axis_data_fifo_512_d1024]


#Interconnects

create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_merger_256 
set_property -dict [list CONFIG.Component_Name {axis_interconnect_merger_256} CONFIG.C_NUM_SI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {32} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TKEEP {false} CONFIG.HAS_TLAST {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {false} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {32} CONFIG.S00_AXIS_TDATA_NUM_BYTES {32} CONFIG.S01_AXIS_TDATA_NUM_BYTES {32} CONFIG.M00_S01_CONNECTIVITY {true}] [get_ips axis_interconnect_merger_256]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_2to1 
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {8} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S01_AXIS_TDATA_NUM_BYTES {8} CONFIG.M00_S01_CONNECTIVITY {true}] [get_ips axis_interconnect_2to1]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_3to1 
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {3} CONFIG.SWITCH_TDATA_NUM_BYTES {8} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_S02_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S01_AXIS_TDATA_NUM_BYTES {8} CONFIG.S02_AXIS_TDATA_NUM_BYTES {8} CONFIG.M00_S01_CONNECTIVITY {true} CONFIG.M00_S02_CONNECTIVITY {true}] [get_ips axis_interconnect_3to1]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_4to1 
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {4} CONFIG.SWITCH_TDATA_NUM_BYTES {8} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_S02_AXIS_REG_CONFIG {1} CONFIG.C_S03_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S01_AXIS_TDATA_NUM_BYTES {8} CONFIG.S02_AXIS_TDATA_NUM_BYTES {8} CONFIG.S03_AXIS_TDATA_NUM_BYTES {8} CONFIG.M00_S01_CONNECTIVITY {true} CONFIG.M00_S02_CONNECTIVITY {true} CONFIG.M00_S03_CONNECTIVITY {true}] [get_ips axis_interconnect_4to1]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_128_2to1 
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {16} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {16} CONFIG.S00_AXIS_TDATA_NUM_BYTES {16} CONFIG.S01_AXIS_TDATA_NUM_BYTES {16} CONFIG.M00_S01_CONNECTIVITY {true}] [get_ips axis_interconnect_128_2to1]

create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_128_4to1 
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {4} CONFIG.SWITCH_TDATA_NUM_BYTES {16} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_S02_AXIS_REG_CONFIG {1} CONFIG.C_S03_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {16} CONFIG.S00_AXIS_TDATA_NUM_BYTES {16} CONFIG.S01_AXIS_TDATA_NUM_BYTES {16} CONFIG.S02_AXIS_TDATA_NUM_BYTES {16} CONFIG.S03_AXIS_TDATA_NUM_BYTES {16} CONFIG.M00_S01_CONNECTIVITY {true} CONFIG.M00_S02_CONNECTIVITY {true} CONFIG.M00_S03_CONNECTIVITY {true}] [get_ips axis_interconnect_128_4to1]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_256_2to1 
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {32} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {32} CONFIG.S00_AXIS_TDATA_NUM_BYTES {32} CONFIG.S01_AXIS_TDATA_NUM_BYTES {32} CONFIG.M00_S01_CONNECTIVITY {true}] [get_ips axis_interconnect_256_2to1]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_256_4to1 
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {4} CONFIG.SWITCH_TDATA_NUM_BYTES {32} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_S02_AXIS_REG_CONFIG {1} CONFIG.C_S03_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {32} CONFIG.S00_AXIS_TDATA_NUM_BYTES {32} CONFIG.S01_AXIS_TDATA_NUM_BYTES {32} CONFIG.S02_AXIS_TDATA_NUM_BYTES {32} CONFIG.S03_AXIS_TDATA_NUM_BYTES {32} CONFIG.M00_S01_CONNECTIVITY {true} CONFIG.M00_S02_CONNECTIVITY {true} CONFIG.M00_S03_CONNECTIVITY {true}] [get_ips axis_interconnect_256_4to1]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_512_2to1 
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {64} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {64} CONFIG.S00_AXIS_TDATA_NUM_BYTES {64} CONFIG.S01_AXIS_TDATA_NUM_BYTES {64} CONFIG.M00_S01_CONNECTIVITY {true}] [get_ips axis_interconnect_512_2to1]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_512_4to1 
set_property -dict [list CONFIG.C_NUM_SI_SLOTS {4} CONFIG.SWITCH_TDATA_NUM_BYTES {64} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.SWITCH_PACKET_MODE {true} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {0} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_S01_AXIS_REG_CONFIG {1} CONFIG.C_S02_AXIS_REG_CONFIG {1} CONFIG.C_S03_AXIS_REG_CONFIG {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {64} CONFIG.S00_AXIS_TDATA_NUM_BYTES {64} CONFIG.S01_AXIS_TDATA_NUM_BYTES {64} CONFIG.S02_AXIS_TDATA_NUM_BYTES {64} CONFIG.S03_AXIS_TDATA_NUM_BYTES {64} CONFIG.M00_S01_CONNECTIVITY {true} CONFIG.M00_S02_CONNECTIVITY {true} CONFIG.M00_S03_CONNECTIVITY {true}] [get_ips axis_interconnect_512_4to1]


#Data Width Converter

create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_64_to_512_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {8} CONFIG.M_TDATA_NUM_BYTES {64} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.TDEST_WIDTH {1} CONFIG.Component_Name {axis_64_to_512_converter}] [get_ips axis_64_to_512_converter]

create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_512_to_64_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {64} CONFIG.M_TDATA_NUM_BYTES {8} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.Component_Name {axis_512_to_64_converter}] [get_ips axis_512_to_64_converter]


create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_128_to_512_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {16} CONFIG.M_TDATA_NUM_BYTES {64} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.TDEST_WIDTH {1} CONFIG.Component_Name {axis_128_to_512_converter}] [get_ips axis_128_to_512_converter]


create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_512_to_128_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {64} CONFIG.M_TDATA_NUM_BYTES {16} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.Component_Name {axis_512_to_128_converter}] [get_ips axis_512_to_128_converter]


create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_256_to_512_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {32} CONFIG.M_TDATA_NUM_BYTES {64} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.TDEST_WIDTH {1} CONFIG.Component_Name {axis_256_to_512_converter}] [get_ips axis_256_to_512_converter]


create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_512_to_256_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {64} CONFIG.M_TDATA_NUM_BYTES {32} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.Component_Name {axis_512_to_256_converter}] [get_ips axis_512_to_256_converter]


create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_64_to_128_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {8} CONFIG.M_TDATA_NUM_BYTES {16} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.TDEST_WIDTH {1} CONFIG.Component_Name {axis_64_to_128_converter}] [get_ips axis_64_to_128_converter]


create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_128_to_64_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {16} CONFIG.M_TDATA_NUM_BYTES {8} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.Component_Name {axis_128_to_64_converter}] [get_ips axis_128_to_64_converter]


create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_64_to_256_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {8} CONFIG.M_TDATA_NUM_BYTES {32} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.TDEST_WIDTH {1} CONFIG.Component_Name {axis_64_to_256_converter}] [get_ips axis_64_to_256_converter]


create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_256_to_64_converter 
set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {32} CONFIG.M_TDATA_NUM_BYTES {8} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.Component_Name {axis_256to_64_converter}] [get_ips axis_256_to_64_converter]


#HLS IP cores

create_ip -name toe -vendor ethz.systems -library hls -version 1.6 -module_name toe_ip 
update_compile_order -fileset sources_1

create_ip -name ip_handler -vendor ethz.systems.fpga -library hls -version 2.0 -module_name ip_handler_ip 
update_compile_order -fileset sources_1

create_ip -name mac_ip_encode -vendor ethz.systems.fpga -library hls -version 2.0 -module_name mac_ip_encode_ip 
update_compile_order -fileset sources_1

create_ip -name icmp_server -vendor xilinx.labs -library hls -version 1.67 -module_name icmp_server_ip 
update_compile_order -fileset sources_1

#create_ip -name echo_server_application -vendor ethz.systems -library hls -version 1.2 -module_name echo_server_application_ip 

#create_ip -name iperf_client -vendor ethz.systems.fpga -library hls -version 1.0 -module_name iperf_client_ip 

create_ip -name arp_server_subnet -vendor ethz.systems.fpga -library hls -version 1.1 -module_name arp_server_subnet_ip 
update_compile_order -fileset sources_1

create_ip -name ipv4 -vendor ethz.systems.fpga -library hls -version 0.1 -module_name ipv4_ip 
update_compile_order -fileset sources_1

create_ip -name udp -vendor ethz.systems.fpga -library hls -version 0.4 -module_name udp_ip 
update_compile_order -fileset sources_1

#create_ip -name iperf_udp -vendor ethz.systems.fpga -library hls -version 0.9 -module_name iperf_udp_ip 

#create_ip -name udpAppMux -vendor xilinx.labs -library hls -version 1.05 -module_name udpAppMux_0 

create_ip -name dhcp_client -vendor xilinx.labs -library hls -version 1.05 -module_name dhcp_client_ip 
update_compile_order -fileset sources_1

#create_ip -name rocev2 -vendor ethz.systems.fpga -library hls -version 0.82 -module_name rocev2_ip 
# update_compile_order -fileset sources_1

create_ip -name hash_table -vendor ethz.systems.fpga -library hls -version 1.0 -module_name hash_table_ip 
update_compile_order -fileset sources_1

## Crossings
create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_cc_udp_meta
set_property -dict [list CONFIG.TDATA_NUM_BYTES {22} CONFIG.TDEST_WIDTH {1} CONFIG.FIFO_DEPTH {256} CONFIG.IS_ACLK_ASYNC {1} CONFIG.Component_Name {axis_data_fifo_cc_udp_meta}] [get_ips axis_data_fifo_cc_udp_meta]
update_compile_order -fileset sources_1

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_cc_udp_data
set_property -dict [list CONFIG.TDATA_NUM_BYTES {64} CONFIG.FIFO_DEPTH {256} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_data_fifo_cc_udp_data}] [get_ips axis_data_fifo_cc_udp_data]
update_compile_order -fileset sources_1

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_cc_512
set_property -dict [list CONFIG.TDATA_NUM_BYTES {64} CONFIG.FIFO_DEPTH {256} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_data_fifo_cc_512}] [get_ips axis_data_fifo_cc_512]
update_compile_order -fileset sources_1

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_cc_256
set_property -dict [list CONFIG.TDATA_NUM_BYTES {32} CONFIG.FIFO_DEPTH {256} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_data_fifo_cc_256}] [get_ips axis_data_fifo_cc_256]
update_compile_order -fileset sources_1

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_cc_128
set_property -dict [list CONFIG.TDATA_NUM_BYTES {16} CONFIG.FIFO_DEPTH {256} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_data_fifo_cc_128}] [get_ips axis_data_fifo_cc_128]
update_compile_order -fileset sources_1

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_cc_64
set_property -dict [list CONFIG.TDATA_NUM_BYTES {8} CONFIG.FIFO_DEPTH {256} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_data_fifo_cc_64}] [get_ips axis_data_fifo_cc_64]
update_compile_order -fileset sources_1

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_cc_32
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.FIFO_DEPTH {256} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_data_fifo_cc_32}] [get_ips axis_data_fifo_cc_32]
update_compile_order -fileset sources_1

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_cc_16
set_property -dict [list CONFIG.TDATA_NUM_BYTES {2} CONFIG.FIFO_DEPTH {256} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_data_fifo_cc_16}] [get_ips axis_data_fifo_cc_16]
update_compile_order -fileset sources_1

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_cc_8
set_property -dict [list CONFIG.TDATA_NUM_BYTES {1} CONFIG.FIFO_DEPTH {256} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_data_fifo_cc_8}] [get_ips axis_data_fifo_cc_8]
update_compile_order -fileset sources_1


##ila

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_mem_inf
set_property -dict [list CONFIG.C_NUM_OF_PROBES {8} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1} ] [get_ips ila_mem_inf]
update_compile_order -fileset sources_1

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_network_top
set_property -dict [list CONFIG.C_NUM_OF_PROBES {15} CONFIG.C_PROBE14_WIDTH {32} CONFIG.C_PROBE13_WIDTH {32} CONFIG.C_PROBE12_WIDTH {32} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1}] [get_ips ila_network_top]
update_compile_order -fileset sources_1

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_network_top2
set_property -dict [list CONFIG.C_NUM_OF_PROBES {12} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1}] [get_ips ila_network_top2]
update_compile_order -fileset sources_1

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_network_controller
set_property -dict [list CONFIG.C_PROBE7_WIDTH {32} CONFIG.C_PROBE6_WIDTH {32} CONFIG.C_PROBE5_WIDTH {32} CONFIG.C_PROBE2_WIDTH {32} CONFIG.C_PROBE0_WIDTH {32} CONFIG.C_DATA_DEPTH {1024} CONFIG.C_NUM_OF_PROBES {15} CONFIG.Component_Name {ila_network_controller} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1}] [get_ips ila_network_controller]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_tasi
set_property -dict [list CONFIG.C_PROBE17_WIDTH {32} CONFIG.C_PROBE16_WIDTH {32} CONFIG.C_PROBE18_WIDTH {32} CONFIG.C_PROBE19_WIDTH {32} CONFIG.C_DATA_DEPTH {1024} CONFIG.C_NUM_OF_PROBES {23} CONFIG.Component_Name {ila_tasi} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1}] [get_ips ila_tasi]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_eventMerger
set_property -dict [list CONFIG.C_PROBE9_WIDTH {32} CONFIG.C_DATA_DEPTH {1024} CONFIG.C_NUM_OF_PROBES {10} CONFIG.Component_Name {ila_eventMerger} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1}] [get_ips ila_eventMerger]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_eventEngine
set_property -dict [list CONFIG.C_PROBE19_WIDTH {32} CONFIG.C_PROBE18_WIDTH {8} CONFIG.C_PROBE17_WIDTH {8} CONFIG.C_PROBE16_WIDTH {8} CONFIG.C_PROBE15_WIDTH {8} CONFIG.C_DATA_DEPTH {1024} CONFIG.C_NUM_OF_PROBES {20} CONFIG.Component_Name {ila_eventEngine} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1}] [get_ips ila_eventEngine]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_handler
set_property -dict [list CONFIG.C_PROBE12_WIDTH {16} CONFIG.C_PROBE11_WIDTH {18} CONFIG.C_PROBE10_WIDTH {16} CONFIG.C_PROBE9_WIDTH {32} CONFIG.C_PROBE8_WIDTH {32} CONFIG.C_PROBE7_WIDTH {2}  CONFIG.C_DATA_DEPTH {1024} CONFIG.C_NUM_OF_PROBES {13} CONFIG.Component_Name {ila_handler} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1}] [get_ips ila_handler]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_network_top_perf
set_property -dict [list CONFIG.C_PROBE31_WIDTH {64} CONFIG.C_PROBE30_WIDTH {32} CONFIG.C_PROBE29_WIDTH {32} CONFIG.C_PROBE27_WIDTH {64} CONFIG.C_PROBE26_WIDTH {64} CONFIG.C_PROBE25_WIDTH {64} CONFIG.C_PROBE24_WIDTH {64}  CONFIG.C_DATA_DEPTH {1024} CONFIG.C_NUM_OF_PROBES {32} CONFIG.Component_Name {ila_network_top_perf} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1} CONFIG.C_PROBE31_MU_CNT {2} CONFIG.C_PROBE30_MU_CNT {8} CONFIG.C_PROBE29_MU_CNT {8} CONFIG.C_PROBE28_MU_CNT {2} CONFIG.C_PROBE27_MU_CNT {2} CONFIG.C_PROBE26_MU_CNT {2} CONFIG.C_PROBE25_MU_CNT {8} CONFIG.C_PROBE24_MU_CNT {8} CONFIG.C_PROBE23_MU_CNT {2} CONFIG.C_PROBE22_MU_CNT {2} CONFIG.C_PROBE21_MU_CNT {2} CONFIG.C_PROBE20_MU_CNT {2} CONFIG.C_PROBE19_MU_CNT {2} CONFIG.C_PROBE18_MU_CNT {2} CONFIG.C_PROBE17_MU_CNT {2} CONFIG.C_PROBE16_MU_CNT {2} CONFIG.C_PROBE15_MU_CNT {2} CONFIG.C_PROBE14_MU_CNT {2} CONFIG.C_PROBE13_MU_CNT {2} CONFIG.C_PROBE12_MU_CNT {2} CONFIG.C_PROBE11_MU_CNT {2} CONFIG.C_PROBE10_MU_CNT {2} CONFIG.C_PROBE9_MU_CNT {2} CONFIG.C_PROBE8_MU_CNT {2} CONFIG.C_PROBE7_MU_CNT {2} CONFIG.C_PROBE6_MU_CNT {2} CONFIG.C_PROBE5_MU_CNT {2} CONFIG.C_PROBE4_MU_CNT {2} CONFIG.C_PROBE3_MU_CNT {2} CONFIG.C_PROBE2_MU_CNT {2} CONFIG.C_PROBE1_MU_CNT {2} CONFIG.C_PROBE0_MU_CNT {2} CONFIG.ALL_PROBE_SAME_MU {false} CONFIG.ALL_PROBE_SAME_MU_CNT {2}] [get_ips ila_network_top_perf]


create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_listen_port_table
set_property -dict [list CONFIG.C_PROBE0_WIDTH {16} CONFIG.C_PROBE3_WIDTH {15}  CONFIG.C_DATA_DEPTH {1024} CONFIG.C_NUM_OF_PROBES {12} CONFIG.Component_Name {ila_listen_port_table} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1}] [get_ips ila_listen_port_table]

create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name ila_rx_app_if
set_property -dict [list CONFIG.C_PROBE4_WIDTH {16} CONFIG.C_PROBE8_WIDTH {16} CONFIG.C_PROBE10_WIDTH {8} CONFIG.C_DATA_DEPTH {1024} CONFIG.C_NUM_OF_PROBES {13} CONFIG.Component_Name {ila_rx_app_if} CONFIG.C_EN_STRG_QUAL {1} CONFIG.C_ADV_TRIGGER {true} CONFIG.C_INPUT_PIPE_STAGES {1}] [get_ips ila_rx_app_if]


#DDR
create_ip -name axi_datamover -vendor xilinx.com -library ip -version 5.1 -module_name axi_datamover_mem 
set_property -dict [list CONFIG.Component_Name {axi_datamover_mem} CONFIG.c_mm2s_stscmd_is_async {true} CONFIG.c_m_axi_mm2s_data_width {512} CONFIG.c_m_axis_mm2s_tdata_width {512} CONFIG.c_mm2s_burst_size {64} CONFIG.c_mm2s_btt_used {23} CONFIG.c_s2mm_stscmd_is_async {true} CONFIG.c_m_axi_s2mm_data_width {512} CONFIG.c_s_axis_s2mm_tdata_width {512} CONFIG.c_s2mm_burst_size {64} CONFIG.c_s2mm_btt_used {23} CONFIG.c_s2mm_include_sf {false} CONFIG.c_m_axi_mm2s_id_width {1} CONFIG.c_m_axi_s2mm_id_width {1} CONFIG.c_addr_width {64}] [get_ips axi_datamover_mem]
update_compile_order -fileset sources_1

create_ip -name axi_datamover -vendor xilinx.com -library ip -version 5.1 -module_name axi_datamover_mem_unaligned 
set_property -dict [list CONFIG.Component_Name {axi_datamover_mem_unaligned} CONFIG.c_mm2s_stscmd_is_async {true} CONFIG.c_m_axi_mm2s_data_width {512} CONFIG.c_m_axis_mm2s_tdata_width {512} CONFIG.c_include_mm2s_dre {true} CONFIG.c_mm2s_burst_size {64} CONFIG.c_mm2s_btt_used {23} CONFIG.c_s2mm_stscmd_is_async {true} CONFIG.c_m_axi_s2mm_data_width {512} CONFIG.c_s_axis_s2mm_tdata_width {512} CONFIG.c_include_s2mm_dre {true} CONFIG.c_s2mm_burst_size {64} CONFIG.c_s2mm_btt_used {23} CONFIG.c_s2mm_include_sf {false} CONFIG.c_m_axi_mm2s_id_width {1} CONFIG.c_m_axi_s2mm_id_width {1} CONFIG.c_addr_width {64}] [get_ips axi_datamover_mem_unaligned]
update_compile_order -fileset sources_1

