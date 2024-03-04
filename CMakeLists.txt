cmake_minimum_required(VERSION 3.0)
project(vitis-network)


set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_SOURCE_DIR}/cmake)

set(IPREPO_DIR ${CMAKE_BINARY_DIR}/ip_repo)
file(MAKE_DIRECTORY ${IPREPO_DIR})


if(FDEV_NAME STREQUAL "u280")
	set(DEVICE_NAME "u280" CACHE STRING "device name")
    set(FNS_PLATFORM "xilinx_u280_xdma_201920_3" CACHE STRING "FPGA platform" FORCE)
    set(FNS_PLATFORM_PART "xcu280-fsvh2892-2L-e" CACHE STRING "FPGA platform part" FORCE)
    set(FPGA_PART "xcu280-fsvh2892-2L-e" CACHE STRING "FPGA device" FORCE)
    set(NETWORK_KRNL_MEM "HBM[15]" CACHE STRING "Network krnl mem bank" FORCE)
    set(CMAC_SLR "SLR2" CACHE STRING "Cmac krnl slr" FORCE)
elseif (FDEV_NAME STREQUAL "u250")
    set(DEVICE_NAME "u250" CACHE STRING "device name")
    set(FNS_PLATFORM "xilinx_u250_gen3x16_xdma_3_1_202020_1" CACHE STRING "FPGA platform" FORCE)
    set(FNS_PLATFORM_PART "xcu250-figd2104-2L-e" CACHE STRING "FPGA platform part" FORCE)
    set(FPGA_PART "xcu250-figd2104-2L-e" CACHE STRING "FPGA part" FORCE)
    set(NETWORK_KRNL_MEM "DDR[2]" CACHE STRING "Network krnl mem bank" FORCE)
    set(CMAC_SLR "SLR2" CACHE STRING "Cmac krnl slr" FORCE)
elseif (FDEV_NAME STREQUAL "u50")
    set(DEVICE_NAME "u50" CACHE STRING "device name")
    set(FNS_PLATFORM "xilinx_u50_gen3x16_xdma_5_202210_1" CACHE STRING "FPGA platform" FORCE)
    set(FNS_PLATFORM_PART "xcu50-fsvh2104-2-e" CACHE STRING "FPGA platform part" FORCE)
    set(FPGA_PART "xcu50-fsvh2104-2-e" CACHE STRING "FPGA part" FORCE)
    set(NETWORK_KRNL_MEM "HBM[15]" CACHE STRING "Network krnl mem bank" FORCE)
    set(CMAC_SLR "SLR1" CACHE STRING "Cmac krnl slr" FORCE)
elseif (FDEV_NAME STREQUAL "u55c")
    set(DEVICE_NAME "u55c" CACHE STRING "device name")
    set(FNS_PLATFORM "xilinx_u55c_gen3x16_xdma_3_202210_1" CACHE STRING "FPGA platform" FORCE)
    set(FNS_PLATFORM_PART "xcu55c-fsvh2892-2L-e" CACHE STRING "FPGA platform part" FORCE)
    set(FPGA_PART "xcu55c-fsvh2892-2L-e" CACHE STRING "FPGA part" FORCE)
    set(NETWORK_KRNL_MEM "HBM[15]" CACHE STRING "Network krnl mem bank" FORCE)
    set(CMAC_SLR "SLR1" CACHE STRING "Cmac krnl slr" FORCE)
endif()

set(NETWORK_BANDWIDTH 100 CACHE STRING "Network bandwidth")
set(NETWORK_INTERFACE 100 CACHE STRING "Network bandwidth")
set(DATA_WIDTH 64 CACHE STRING "Width of data path in bytes")
set(CLOCK_PERIOD 3.2 CACHE STRING "Target clock period in nanoseconds")

# Config
set(TCP_STACK_EN 0 CACHE BOOL "Enable TCP/IP stack")
set(UDP_STACK_EN 1 CACHE BOOL "Enable UDP/IP stack")
set(FNS_TCP_STACK_RX_DDR_BYPASS_EN 1 CACHE BOOL "Enabling DDR bypass on the RX path")
set(FNS_TCP_STACK_MSS 4096 CACHE STRING "Maximum Segment Size (MSS)")
set(FNS_TCP_STACK_WINDOW_SCALING_EN 1 CACHE STRING "Enabling TCP window scaling option")
set(FNS_TCP_STACK_MAX_SESSIONS 1000 CACHE STRING "Maximum number of sessions the TCP/IP stack can support")

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

configure_file(${CMAKE_SOURCE_DIR}/scripts/network_krnl_mem.txt.in ${CMAKE_SOURCE_DIR}/scripts/network_krnl_mem.txt)
configure_file(${CMAKE_SOURCE_DIR}/scripts/cmac_krnl_slr.txt.in ${CMAKE_SOURCE_DIR}/scripts/cmac_krnl_slr.txt)
configure_file(${CMAKE_SOURCE_DIR}/scripts/post_sys_link.tcl.in ${CMAKE_SOURCE_DIR}/scripts/post_sys_link.tcl)
configure_file(${CMAKE_SOURCE_DIR}/kernel/common/types/network_types.svh.in ${CMAKE_SOURCE_DIR}/kernel/common/types/network_types.svh)


