#AXI Infrastructure (device independent)


#Clock Converters

create_ip -name axis_clock_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_clock_converter_32 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.Component_Name {axis_clock_converter_32}] [get_ips axis_clock_converter_32]


create_ip -name axis_clock_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_clock_converter_64 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {8} CONFIG.Component_Name {axis_clock_converter_64}] [get_ips axis_clock_converter_64]


create_ip -name axis_clock_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_clock_converter_96 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {12} CONFIG.Component_Name {axis_clock_converter_96}] [get_ips axis_clock_converter_96]


create_ip -name axis_clock_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_clock_converter_136 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {17} CONFIG.Component_Name {axis_clock_converter_136}] [get_ips axis_clock_converter_136]


create_ip -name axis_clock_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_clock_converter_144 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {18} CONFIG.Component_Name {axis_clock_converter_144}] [get_ips axis_clock_converter_144]


create_ip -name axis_clock_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_clock_converter_200 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {25} CONFIG.Component_Name {axis_clock_converter_200}] [get_ips axis_clock_converter_200]


create_ip -name axi_clock_converter -vendor xilinx.com -library ip -version 2.1 -module_name axil_clock_converter 
set_property -dict [list CONFIG.Component_Name {axil_clock_converter} CONFIG.PROTOCOL {AXI4LITE} CONFIG.DATA_WIDTH {32} CONFIG.ID_WIDTH {0} CONFIG.AWUSER_WIDTH {0} CONFIG.ARUSER_WIDTH {0} CONFIG.RUSER_WIDTH {0} CONFIG.WUSER_WIDTH {0} CONFIG.BUSER_WIDTH {0}] [get_ips axil_clock_converter]


create_ip -name axi_clock_converter -vendor xilinx.com -library ip -version 2.1 -module_name axil_net_ctrl_clock_converter 
set_property -dict [list CONFIG.Component_Name {axil_net_ctrl_clock_converter} CONFIG.PROTOCOL {AXI4LITE} CONFIG.ADDR_WIDTH {64} CONFIG.DATA_WIDTH {64} CONFIG.ID_WIDTH {0} CONFIG.AWUSER_WIDTH {0} CONFIG.ARUSER_WIDTH {0} CONFIG.RUSER_WIDTH {0} CONFIG.WUSER_WIDTH {0} CONFIG.BUSER_WIDTH {0}] [get_ips axil_net_ctrl_clock_converter]


#Data Width Converters

#create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_256_to_512_converter 
#set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {32} CONFIG.M_TDATA_NUM_BYTES {64} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.Component_Name {axis_256_to_512_converter}] [get_ips axis_256_to_512_converter]



#create_ip -name axis_dwidth_converter -vendor xilinx.com -library ip -version 1.1 -module_name axis_512_to_256_converter 
#set_property -dict [list CONFIG.S_TDATA_NUM_BYTES {64} CONFIG.M_TDATA_NUM_BYTES {32} CONFIG.HAS_TLAST {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_MI_TKEEP {1} CONFIG.Component_Name {axis_512_to_256_converter}] [get_ips axis_512_to_256_converter]



create_ip -name axi_crossbar -vendor xilinx.com -library ip -version 2.1 -module_name axil_controller_crossbar 
set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.CONNECTIVITY_MODE {SASD} CONFIG.R_REGISTER {1} CONFIG.NUM_MI {5} CONFIG.M01_A00_BASE_ADDR {0x0000000000001000} CONFIG.M02_A00_BASE_ADDR {0x0000000000002000} CONFIG.M03_A00_BASE_ADDR {0x0000000000003000} CONFIG.M04_A00_BASE_ADDR {0x0000000000004000} CONFIG.S00_WRITE_ACCEPTANCE {1} CONFIG.S01_WRITE_ACCEPTANCE {1} CONFIG.S02_WRITE_ACCEPTANCE {1} CONFIG.S03_WRITE_ACCEPTANCE {1} CONFIG.S04_WRITE_ACCEPTANCE {1} CONFIG.S05_WRITE_ACCEPTANCE {1} CONFIG.S06_WRITE_ACCEPTANCE {1} CONFIG.S07_WRITE_ACCEPTANCE {1} CONFIG.S08_WRITE_ACCEPTANCE {1} CONFIG.S09_WRITE_ACCEPTANCE {1} CONFIG.S10_WRITE_ACCEPTANCE {1} CONFIG.S11_WRITE_ACCEPTANCE {1} CONFIG.S12_WRITE_ACCEPTANCE {1} CONFIG.S13_WRITE_ACCEPTANCE {1} CONFIG.S14_WRITE_ACCEPTANCE {1} CONFIG.S15_WRITE_ACCEPTANCE {1} CONFIG.S00_READ_ACCEPTANCE {1} CONFIG.S01_READ_ACCEPTANCE {1} CONFIG.S02_READ_ACCEPTANCE {1} CONFIG.S03_READ_ACCEPTANCE {1} CONFIG.S04_READ_ACCEPTANCE {1} CONFIG.S05_READ_ACCEPTANCE {1} CONFIG.S06_READ_ACCEPTANCE {1} CONFIG.S07_READ_ACCEPTANCE {1} CONFIG.S08_READ_ACCEPTANCE {1} CONFIG.S09_READ_ACCEPTANCE {1} CONFIG.S10_READ_ACCEPTANCE {1} CONFIG.S11_READ_ACCEPTANCE {1} CONFIG.S12_READ_ACCEPTANCE {1} CONFIG.S13_READ_ACCEPTANCE {1} CONFIG.S14_READ_ACCEPTANCE {1} CONFIG.S15_READ_ACCEPTANCE {1} CONFIG.M00_WRITE_ISSUING {1} CONFIG.M01_WRITE_ISSUING {1} CONFIG.M02_WRITE_ISSUING {1} CONFIG.M03_WRITE_ISSUING {1} CONFIG.M04_WRITE_ISSUING {1} CONFIG.M05_WRITE_ISSUING {1} CONFIG.M06_WRITE_ISSUING {1} CONFIG.M07_WRITE_ISSUING {1} CONFIG.M08_WRITE_ISSUING {1} CONFIG.M09_WRITE_ISSUING {1} CONFIG.M10_WRITE_ISSUING {1} CONFIG.M11_WRITE_ISSUING {1} CONFIG.M12_WRITE_ISSUING {1} CONFIG.M13_WRITE_ISSUING {1} CONFIG.M14_WRITE_ISSUING {1} CONFIG.M15_WRITE_ISSUING {1} CONFIG.M00_READ_ISSUING {1} CONFIG.M01_READ_ISSUING {1} CONFIG.M02_READ_ISSUING {1} CONFIG.M03_READ_ISSUING {1} CONFIG.M04_READ_ISSUING {1} CONFIG.M05_READ_ISSUING {1} CONFIG.M06_READ_ISSUING {1} CONFIG.M07_READ_ISSUING {1} CONFIG.M08_READ_ISSUING {1} CONFIG.M09_READ_ISSUING {1} CONFIG.M10_READ_ISSUING {1} CONFIG.M11_READ_ISSUING {1} CONFIG.M12_READ_ISSUING {1} CONFIG.M13_READ_ISSUING {1} CONFIG.M14_READ_ISSUING {1} CONFIG.M15_READ_ISSUING {1} CONFIG.S00_SINGLE_THREAD {1} CONFIG.Component_Name {axil_controller_crossbar}] [get_ips axil_controller_crossbar]



#Register slices
create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_8 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {1} CONFIG.Component_Name {axis_register_slice_8}] [get_ips axis_register_slice_8]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_16 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {2} CONFIG.Component_Name {axis_register_slice_16}] [get_ips axis_register_slice_16]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_24 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {3} CONFIG.Component_Name {axis_register_slice_24}] [get_ips axis_register_slice_24]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_32 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.Component_Name {axis_register_slice_32}] [get_ips axis_register_slice_32]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_48 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {6} CONFIG.Component_Name {axis_register_slice_48}] [get_ips axis_register_slice_48]

create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_72
set_property -dict [list CONFIG.TDATA_NUM_BYTES {9} CONFIG.Component_Name {axis_register_slice_72}] [get_ips axis_register_slice_72]

create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_88 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {11} CONFIG.Component_Name {axis_register_slice_88}] [get_ips axis_register_slice_88]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_96 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {12} CONFIG.Component_Name {axis_register_slice_96}] [get_ips axis_register_slice_96]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_176 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {22} CONFIG.Component_Name {axis_register_slice_176}] [get_ips axis_register_slice_176]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_64 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {8} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_register_slice_64}] [get_ips axis_register_slice_64]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_128 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {16} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_register_slice_128}] [get_ips axis_register_slice_128]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_256 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {32} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_register_slice_256}] [get_ips axis_register_slice_256]


create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_512 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {64} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_register_slice_512}] [get_ips axis_register_slice_512]


#FIFOs

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_96 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {12} CONFIG.Component_Name {axis_data_fifo_96}] [get_ips axis_data_fifo_96]


create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_160 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {20} CONFIG.Component_Name {axis_data_fifo_160} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1}] [get_ips axis_data_fifo_160]


create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_160_cc 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {20} CONFIG.IS_ACLK_ASYNC {1} CONFIG.Component_Name {axis_data_fifo_160_cc} CONFIG.HAS_WR_DATA_COUNT {1} CONFIG.HAS_RD_DATA_COUNT {1}] [get_ips axis_data_fifo_160_cc]


create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_data_fifo_512_cc 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {64} CONFIG.IS_ACLK_ASYNC {1} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_data_fifo_512_cc}] [get_ips axis_data_fifo_512_cc]


create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_generator_rdma_cmd 
set_property -dict [list CONFIG.Component_Name {fifo_generator_rdma_cmd} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Clock_Type_AXI {Independent_Clock} CONFIG.TDATA_NUM_BYTES {16} CONFIG.TUSER_WIDTH {0} CONFIG.TSTRB_WIDTH {16} CONFIG.TKEEP_WIDTH {16} CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} CONFIG.Full_Threshold_Assert_Value_wach {15} CONFIG.Empty_Threshold_Assert_Value_wach {13} CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Builtin_FIFO} CONFIG.Empty_Threshold_Assert_Value_wdch {1018} CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} CONFIG.Full_Threshold_Assert_Value_wrch {15} CONFIG.Empty_Threshold_Assert_Value_wrch {13} CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} CONFIG.Full_Threshold_Assert_Value_rach {15} CONFIG.Empty_Threshold_Assert_Value_rach {13} CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Builtin_FIFO} CONFIG.Empty_Threshold_Assert_Value_rdch {1018} CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} CONFIG.Input_Depth_axis {64} CONFIG.Full_Threshold_Assert_Value_axis {63} CONFIG.Empty_Threshold_Assert_Value_axis {61}] [get_ips fifo_generator_rdma_cmd]


create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name fifo_generator_rdma_data 
set_property -dict [list CONFIG.Component_Name {fifo_generator_rdma_data} CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Clock_Type_AXI {Independent_Clock} CONFIG.TDATA_NUM_BYTES {64} CONFIG.TUSER_WIDTH {0} CONFIG.Enable_TLAST {true} CONFIG.TSTRB_WIDTH {64} CONFIG.HAS_TKEEP {true} CONFIG.TKEEP_WIDTH {64} CONFIG.FIFO_Implementation_wach {Independent_Clocks_Distributed_RAM} CONFIG.Full_Threshold_Assert_Value_wach {15} CONFIG.Empty_Threshold_Assert_Value_wach {13} CONFIG.FIFO_Implementation_wdch {Independent_Clocks_Builtin_FIFO} CONFIG.Empty_Threshold_Assert_Value_wdch {1018} CONFIG.FIFO_Implementation_wrch {Independent_Clocks_Distributed_RAM} CONFIG.Full_Threshold_Assert_Value_wrch {15} CONFIG.Empty_Threshold_Assert_Value_wrch {13} CONFIG.FIFO_Implementation_rach {Independent_Clocks_Distributed_RAM} CONFIG.Full_Threshold_Assert_Value_rach {15} CONFIG.Empty_Threshold_Assert_Value_rach {13} CONFIG.FIFO_Implementation_rdch {Independent_Clocks_Builtin_FIFO} CONFIG.Empty_Threshold_Assert_Value_rdch {1018} CONFIG.FIFO_Implementation_axis {Independent_Clocks_Block_RAM} CONFIG.Input_Depth_axis {128} CONFIG.Full_Threshold_Assert_Value_axis {127} CONFIG.Empty_Threshold_Assert_Value_axis {125}] [get_ips fifo_generator_rdma_data]


create_ip -name axi_register_slice -vendor xilinx.com -library ip -version 2.1 -module_name axi_register_slice 
set_property -dict [list CONFIG.PROTOCOL {AXI4LITE} CONFIG.REG_W {7} CONFIG.REG_R {7} CONFIG.Component_Name {axi_register_slice}] [get_ips axi_register_slice]


#Interconnects
create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_96_1to2 
set_property -dict [list CONFIG.Component_Name {axis_interconnect_96_1to2} CONFIG.C_NUM_MI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {12} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TKEEP {false} CONFIG.HAS_TLAST {false} CONFIG.HAS_TID {false} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_M01_AXIS_REG_CONFIG {1} CONFIG.HAS_TDEST {true} CONFIG.C_SWITCH_TDEST_WIDTH {1} CONFIG.SWITCH_PACKET_MODE {false} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {12} CONFIG.S00_AXIS_TDATA_NUM_BYTES {12} CONFIG.M01_AXIS_TDATA_NUM_BYTES {12} CONFIG.C_M00_AXIS_BASETDEST {0x00000000} CONFIG.C_M00_AXIS_HIGHTDEST {0x00000000} CONFIG.C_M01_AXIS_BASETDEST {0x00000001} CONFIG.C_M01_AXIS_HIGHTDEST {0x00000001} CONFIG.M01_S00_CONNECTIVITY {true}] [get_ips axis_interconnect_96_1to2]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_160_2to1 
set_property -dict [list CONFIG.Component_Name {axis_interconnect_160_2to1} CONFIG.C_NUM_SI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {20} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TKEEP {false} CONFIG.HAS_TLAST {false} CONFIG.HAS_TID {false} CONFIG.HAS_TDEST {false} CONFIG.C_SWITCH_MAX_XFERS_PER_ARB {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {20} CONFIG.S00_AXIS_TDATA_NUM_BYTES {20} CONFIG.S01_AXIS_TDATA_NUM_BYTES {20} CONFIG.M00_S01_CONNECTIVITY {true}] [get_ips axis_interconnect_160_2to1]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_64_1to2 
set_property -dict [list CONFIG.Component_Name {axis_interconnect_64_1to2} CONFIG.C_NUM_MI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {8} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_M01_AXIS_REG_CONFIG {1} CONFIG.HAS_TDEST {true} CONFIG.C_SWITCH_TDEST_WIDTH {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {8} CONFIG.S00_AXIS_TDATA_NUM_BYTES {8} CONFIG.M01_AXIS_TDATA_NUM_BYTES {8} CONFIG.C_M00_AXIS_BASETDEST {0x00000000} CONFIG.C_M00_AXIS_HIGHTDEST {0x00000000} CONFIG.C_M01_AXIS_BASETDEST {0x00000001} CONFIG.C_M01_AXIS_HIGHTDEST {0x00000001} CONFIG.M01_S00_CONNECTIVITY {true}] [get_ips axis_interconnect_64_1to2]


create_ip -name axis_interconnect -vendor xilinx.com -library ip -version 1.1 -module_name axis_interconnect_512_1to2 
set_property -dict [list CONFIG.Component_Name {axis_interconnect_512_1to2} CONFIG.C_NUM_MI_SLOTS {2} CONFIG.SWITCH_TDATA_NUM_BYTES {64} CONFIG.HAS_TSTRB {false} CONFIG.HAS_TID {false} CONFIG.C_M00_AXIS_REG_CONFIG {1} CONFIG.C_S00_AXIS_REG_CONFIG {1} CONFIG.C_M01_AXIS_REG_CONFIG {1} CONFIG.HAS_TDEST {true} CONFIG.C_SWITCH_TDEST_WIDTH {1} CONFIG.C_SWITCH_NUM_CYCLES_TIMEOUT {0} CONFIG.M00_AXIS_TDATA_NUM_BYTES {64} CONFIG.S00_AXIS_TDATA_NUM_BYTES {64} CONFIG.M01_AXIS_TDATA_NUM_BYTES {64} CONFIG.C_M00_AXIS_BASETDEST {0x00000000} CONFIG.C_M00_AXIS_HIGHTDEST {0x00000000} CONFIG.C_M01_AXIS_BASETDEST {0x00000001} CONFIG.C_M01_AXIS_HIGHTDEST {0x00000001} CONFIG.M01_S00_CONNECTIVITY {true}] [get_ips axis_interconnect_512_1to2]

create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_meta_56_0
set_property -dict [list CONFIG.TDATA_NUM_BYTES {7} CONFIG.REG_CONFIG {8} CONFIG.Component_Name {axis_register_slice_meta_56_0}] [get_ips axis_register_slice_meta_56_0]

create_ip -name axis_register_slice -vendor xilinx.com -library ip -version 1.1 -module_name axis_register_slice_meta_32_0
set_property -dict [list CONFIG.TDATA_NUM_BYTES {4} CONFIG.REG_CONFIG {8} CONFIG.Component_Name {axis_register_slice_meta_32_0}] [get_ips axis_register_slice_meta_32_0]


create_ip -name blk_mem_gen -vendor xilinx.com -library ip -version 8.4 -module_name blk_mem_gen_0
set_property -dict [list CONFIG.Interface_Type {AXI4} CONFIG.Use_AXI_ID {true} CONFIG.Memory_Type {Simple_Dual_Port_RAM} CONFIG.Use_Byte_Write_Enable {true} CONFIG.Byte_Size {8} CONFIG.Assume_Synchronous_Clk {true} CONFIG.Write_Width_A {256} CONFIG.Write_Depth_A {1024} CONFIG.Read_Width_A {256} CONFIG.Operating_Mode_A {READ_FIRST} CONFIG.Write_Width_B {256} CONFIG.Read_Width_B {256} CONFIG.Operating_Mode_B {READ_FIRST} CONFIG.Enable_B {Use_ENB_Pin} CONFIG.Register_PortA_Output_of_Memory_Primitives {false} CONFIG.Use_RSTB_Pin {true} CONFIG.Reset_Type {ASYNC} CONFIG.Port_B_Clock {100} CONFIG.Port_B_Enable_Rate {100} CONFIG.EN_SAFETY_CKT {true}] [get_ips blk_mem_gen_0]
