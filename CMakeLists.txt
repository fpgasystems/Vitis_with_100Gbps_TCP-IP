cmake_minimum_required(VERSION 3.0)
project(vitis-network)

#
# Vivado
#

set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)

set(IPREPO_DIR ${CMAKE_BINARY_DIR}/fpga-network-stack/iprepo)
file(MAKE_DIRECTORY ${IPREPO_DIR})

# Device
if(FDEV_NAME STREQUAL "u280")
    set(FPGA_PART "xcu280-fsvh2892-2L-e" CACHE STRING "FPGA device")
# 	 set(DEVICE "/opt/xilinx/platforms/xilinx_u280_xdma_201920_3/xilinx_u280_xdma_201920_3.xpfm")
elseif(FDEV_NAME STREQUAL "u250")
	set(FPGA_PART "xcu250-figd2104-2L-e" CACHE STRING "FPGA device")
else()
    message(FATAL_ERROR "Target device not supported.")
endif()



# Config
set(NETWORK_BANDWIDTH 100 CACHE STRING "Network bandwidth")
set(NETWORK_INTERFACE 100 CACHE STRING "Network bandwidth")
set(DATA_WIDTH 64 CACHE STRING "Width of data path in bytes")
set(CLOCK_PERIOD 3.2 CACHE STRING "Target clock period in nanoseconds")
set(TCP_STACK_EN 1 CACHE BOOL "Enable TCP/IP stack")
set(UDP_STACK_EN 1 CACHE BOOL "Enable UDP/IP stack")
set(TCP_STACK_RX_DDR_BYPASS_EN 1 CACHE BOOL "Enabling DDR bypass on the RX path")
set(TCP_STACK_MSS 4096 CACHE STRING "Maximum Segment Size (MSS)")
set(TCP_STACK_WINDOW_SCALING_EN 0 CACHE STRING "Window Scaling")


# QSFP port     
set(QSFP_PORT 1 CACHE STRING "Network traffic route.")

#
# Network stack
#

add_subdirectory(fpga-network-stack)


#User kernel IPs
add_subdirectory(kernel/user_krnl/scatter_krnl/src/hls)
add_subdirectory(kernel/user_krnl/iperf_krnl/src/hls)

#
# Find Vivado
#

find_package(Vivado REQUIRED)
if (NOT VIVADO_FOUND)
   message(FATAL_ERROR "Vivado not found.")
endif()

#configure_file(${CMAKE_SOURCE_DIR}/scripts/package_network_krnl.tcl.in ${CMAKE_SOURCE_DIR}/scripts/package_network_krnl.tcl)
#configure_file(${CMAKE_SOURCE_DIR}/scripts/package_cmac_krnl.tcl.in ${CMAKE_SOURCE_DIR}/scripts/package_cmac_krnl.tcl)
#configure_file(${CMAKE_SOURCE_DIR}/scripts/package_scatter_krnl.tcl.in ${CMAKE_SOURCE_DIR}/scripts/package_scatter_krnl.tcl)
#configure_file(${CMAKE_SOURCE_DIR}/scripts/package_iperf_krnl.tcl.in ${CMAKE_SOURCE_DIR}/scripts/package_iperf_krnl.tcl)

configure_file(${CMAKE_SOURCE_DIR}/scripts/post_sys_link.tcl.in ${CMAKE_SOURCE_DIR}/scripts/post_sys_link.tcl)
configure_file(${CMAKE_SOURCE_DIR}/kernel/common/types/network_types.svh.in ${CMAKE_SOURCE_DIR}/kernel/common/types/network_types.svh)

#add_custom_target(shell COMMAND ${VIVADO_BINARY} -mode tcl -source ${CMAKE_BINARY_DIR}/shell.tcl)

