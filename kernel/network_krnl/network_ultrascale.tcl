create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name axis_sync_fifo 
set_property -dict [list CONFIG.INTERFACE_TYPE {AXI_STREAM} CONFIG.FIFO_Implementation_axis {Common_Clock_Block_RAM} CONFIG.TDATA_NUM_BYTES {8} CONFIG.TUSER_WIDTH {0} CONFIG.Enable_TLAST {true} CONFIG.HAS_TKEEP {true} CONFIG.Enable_Data_Counts_axis {true} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Full_Flags_Reset_Value {1} CONFIG.TSTRB_WIDTH {8} CONFIG.TKEEP_WIDTH {8} CONFIG.FIFO_Implementation_wach {Common_Clock_Distributed_RAM} CONFIG.Full_Threshold_Assert_Value_wach {15} CONFIG.Empty_Threshold_Assert_Value_wach {14} CONFIG.FIFO_Implementation_wrch {Common_Clock_Distributed_RAM} CONFIG.Full_Threshold_Assert_Value_wrch {15} CONFIG.Empty_Threshold_Assert_Value_wrch {14} CONFIG.FIFO_Implementation_rach {Common_Clock_Distributed_RAM} CONFIG.Full_Threshold_Assert_Value_rach {15} CONFIG.Empty_Threshold_Assert_Value_rach {14}] [get_ips axis_sync_fifo]

create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name cmd_fifo_xgemac_rxif 
set_property -dict [list CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} CONFIG.Input_Data_Width {16} CONFIG.Output_Data_Width {16} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Full_Flags_Reset_Value {1} CONFIG.Use_Embedded_Registers {false} CONFIG.Full_Threshold_Assert_Value {1022} CONFIG.Full_Threshold_Negate_Value {1021} CONFIG.Enable_Safety_Circuit {false}] [get_ips cmd_fifo_xgemac_rxif]

create_ip -name fifo_generator -vendor xilinx.com -library ip -version 13.2 -module_name cmd_fifo_xgemac_txif 
set_property -dict [list CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} CONFIG.Input_Data_Width {1} CONFIG.Output_Data_Width {1} CONFIG.Reset_Type {Asynchronous_Reset} CONFIG.Full_Flags_Reset_Value {1} CONFIG.Full_Threshold_Assert_Value {1022} CONFIG.Full_Threshold_Negate_Value {1021} CONFIG.Enable_Safety_Circuit {false}] [get_ips cmd_fifo_xgemac_txif]

#create_ip -name ethernet_frame_padding -vendor ethz.systems.fpga -library hls -version 0.1 -module_name ethernet_frame_padding_ip 

create_ip -name axis_data_fifo -vendor xilinx.com -library ip -version 2.0 -module_name axis_pkg_fifo_512 
set_property -dict [list CONFIG.TDATA_NUM_BYTES {64} CONFIG.FIFO_MODE {2} CONFIG.HAS_TKEEP {1} CONFIG.HAS_TLAST {1} CONFIG.Component_Name {axis_pkg_fifo_512}] [get_ips axis_pkg_fifo_512]


