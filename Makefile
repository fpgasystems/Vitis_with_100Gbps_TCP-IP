.PHONY: help

help::
	$(ECHO) "Makefile Usage:"
	$(ECHO) "  make all TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform> HOST_ARCH=<aarch32/aarch64/x86> SYSROOT=<sysroot_path> USER_KRNL=<user_krnl_name> USER_KRNL_MODE=<rtl/hls>"
	$(ECHO) "      Command to generate the design for specified Target and Shell."
	$(ECHO) "      By default, HOST_ARCH=x86. HOST_ARCH and SYSROOT is required for SoC shells"
	$(ECHO) ""
	$(ECHO) "  make clean "
	$(ECHO) "      Command to remove the generated non-hardware files."
	$(ECHO) ""
	$(ECHO) "  make cleanall"
	$(ECHO) "      Command to remove all the generated files."
	$(ECHO) ""
	$(ECHO) "  make sd_card TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform> HOST_ARCH=<aarch32/aarch64/x86> SYSROOT=<sysroot_path>"
	$(ECHO) "      Command to prepare sd_card files."
	$(ECHO) "      By default, HOST_ARCH=x86. HOST_ARCH and SYSROOT is required for SoC shells"
	$(ECHO) ""
	$(ECHO) "  make check TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform> HOST_ARCH=<aarch32/aarch64/x86> SYSROOT=<sysroot_path>"
	$(ECHO) "      Command to run application in emulation."
	$(ECHO) "      By default, HOST_ARCH=x86. HOST_ARCH and SYSROOT is required for SoC shells"
	$(ECHO) ""
	$(ECHO) "  make build TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform> HOST_ARCH=<aarch32/aarch64/x86> SYSROOT=<sysroot_path>"
	$(ECHO) "      Command to build xclbin application."
	$(ECHO) "      By default, HOST_ARCH=x86. HOST_ARCH and SYSROOT is required for SoC shells"
	$(ECHO) ""

# Points to top directory of Git repository
COMMON_REPO = ./
PWD = $(shell readlink -f .)
ABS_COMMON_REPO = $(shell readlink -f $(COMMON_REPO))

TARGET := hw
HOST_ARCH := x86
SYSROOT :=
DEVICE ?= xilinx_u280_xdma_201920_3
VITIS_PLATFORM := ${DEVICE}


XCLBIN_NAME = network
KRNL_1 := network_krnl
KRNL_2 := ${USER_KRNL}
KRNL_3 := cmac_krnl

CMAC_KRNL=vitis_network/_x.hw.$(XSA)/cmac_krnl.xo
NETWORK_KRNL=vitis_network/_x.hw.$(XSA)/network_krnl.xo

USER_KRNL_MODE ?= rtl

include ./utils.mk
POSTSYSLINKTCL ?= $(shell readlink -f ./scripts/post_sys_link.tcl)
CONFIGLINKTCL ?= $(shell readlink -f ./scripts/compile.cfg)

IPREPOPATH ?= ./build/ip_repo

XSA := $(call device2xsa, $(DEVICE))
TEMP_DIR := ./_x.$(TARGET).$(XSA)
BUILD_DIR := ./build_dir.$(TARGET).$(XSA)

VPP := $(XILINX_VITIS)/bin/v++
SDCARD := sd_card

# Enable Profiling
REPORT := yes
PROFILE:= no


#Include Libraries
include $(ABS_COMMON_REPO)/common/includes/opencl/opencl.mk
include $(ABS_COMMON_REPO)/common/includes/xcl2/xcl2.mk

CXXFLAGS += $(xcl2_CXXFLAGS)
LDFLAGS += $(xcl2_LDFLAGS)
HOST_SRCS += $(xcl2_SRCS)
include config_$(USER_KRNL_MODE).mk

CXXFLAGS += $(opencl_CXXFLAGS) -Wall -O0 -g -std=gnu++14
CXXFLAGS +=  -DVITIS_PLATFORM=$(VITIS_PLATFORM)
LDFLAGS += $(opencl_LDFLAGS)

HOST_SRCS += host/${USER_KRNL}/host.cpp #host/${USER_KRNL}/*/*.cpp
# Host compiler global settings
CXXFLAGS += -fmessage-length=0
LDFLAGS += -lrt -lstdc++

ifneq ($(HOST_ARCH), x86)
  LDFLAGS += --sysroot=$(SYSROOT)
endif

# Kernel compiler global settings
CLFLAGS += -t $(TARGET) --platform $(DEVICE) --save-temps #--config $(CONFIGLINKTCL)
CLFLAGS += --kernel_frequency 200
ifneq ($(TARGET), hw)
  CLFLAGS += -g
endif

# Linker params
# Linker userPostSysLinkTcl param
#ifeq ($(DEVICE),$(findstring $(DEVICE), u280))
$(info $$DEVICE is [${DEVICE}])
$(info $$POSTSYSLINKTCL is [${POSTSYSLINKTCL}])
CLFLAGS += --advanced.param compiler.userPostSysLinkTcl=$(POSTSYSLINKTCL) #--xp param:compiler.userPostSysLinkTcl=$(POSTSYSLINKTCL)
CLFLAGS += --dk chipscope:network_krnl_1:m_axis_tcp_open_status --dk chipscope:network_krnl_1:s_axis_tcp_tx_meta --dk chipscope:network_krnl_1:m_axis_tcp_tx_status  --dk chipscope:network_krnl_1:s_axis_tcp_open_connection --dk chipscope:network_krnl_1:axis_net_tx --dk chipscope:network_krnl_1:m00_axi

CLFLAGS += --dk chipscope:network_krnl_1:m_axis_tcp_port_status --dk chipscope:network_krnl_1:m_axis_tcp_notification --dk chipscope:network_krnl_1:m_axis_tcp_rx_meta  --dk chipscope:network_krnl_1:s_axis_tcp_read_pkg  --dk chipscope:network_krnl_1:s_axis_tcp_listen_port --dk chipscope:network_krnl_1:axis_net_rx

CLFLAGS += --config ./kernel/user_krnl/${USER_KRNL}/config_sp_${USER_KRNL}.txt --config ./scripts/network_krnl_mem.txt --config ./scripts/cmac_krnl_slr.txt

# LDCLFLAGS += --kernel_frequency "0:250|1:250"
# LDCLFLAGS += --profile_kernel stall:${USER_KRNL}:all:all

#'estimate' for estimate report generation
#'system' for system report generation
ifneq ($(REPORT), no)
CLFLAGS += --report estimate
CLLDFLAGS += --report system
endif

#Generates profile summary report
ifeq ($(PROFILE), yes)
LDCLFLAGS += --profile_kernel data:${USER_KRNL}:all:all
LDCFLAGS += --profile_kernel  stall:${USER_KRNL}:all:all
LDCFALGS += --profile_kernel exec:${USER_KRNL}:all:all
endif

EXECUTABLE = ./host/host
CMD_ARGS = $(BUILD_DIR)/${XCLBIN_NAME}.xclbin
EMCONFIG_DIR = $(TEMP_DIR)
EMU_DIR = $(SDCARD)/data/emulation

BINARY_CONTAINERS += $(BUILD_DIR)/${XCLBIN_NAME}.xclbin
BINARY_CONTAINER_OBJS += $(TEMP_DIR)/${KRNL_1}.xo $(TEMP_DIR)/${KRNL_2}.xo $(TEMP_DIR)/${KRNL_3}.xo 

CP = cp -rf

.PHONY: all clean cleanall docs emconfig
all: check-devices $(EXECUTABLE) $(BINARY_CONTAINERS) emconfig sd_card

.PHONY: exe
exe: $(EXECUTABLE)

.PHONY: build
build: $(BINARY_CONTAINERS)

# Building kernel
$(BUILD_DIR)/${XCLBIN_NAME}.xclbin: $(BINARY_CONTAINER_OBJS)
	mkdir -p $(BUILD_DIR)
	$(VPP) $(CLFLAGS) --temp_dir $(BUILD_DIR) -l $(LDCLFLAGS) -o'$@' $(+)

# Building Host
.PHONY: compile
compile: $(EXECUTABLE)
$(EXECUTABLE): check-xrt $(HOST_SRCS) $(HOST_HDRS)
	$(CXX) $(CXXFLAGS) $(HOST_SRCS) $(HOST_HDRS) -o '$@' $(LDFLAGS)

emconfig:$(EMCONFIG_DIR)/emconfig.json
$(EMCONFIG_DIR)/emconfig.json:
	emconfigutil --platform $(DEVICE) --od $(EMCONFIG_DIR)

check: all
ifeq ($(TARGET),$(filter $(TARGET),sw_emu hw_emu))
ifeq ($(HOST_ARCH), x86)
	$(CP) $(EMCONFIG_DIR)/emconfig.json .
	XCL_EMULATION_MODE=$(TARGET) ./$(EXECUTABLE) $(BUILD_DIR)/${XCLBIN_NAME}.xclbin
else
	mkdir -p $(EMU_DIR)
	$(CP) $(XILINX_VITIS)/data/emulation/unified $(EMU_DIR)
	mkfatimg $(SDCARD) $(SDCARD).img 500000
	launch_emulator -no-reboot -runtime ocl -t $(TARGET) -sd-card-image $(SDCARD).img -device-family $(DEV_FAM)
endif
else
ifeq ($(HOST_ARCH), x86)
	./$(EXECUTABLE) $(BUILD_DIR)/${XCLBIN_NAME}.xclbin
endif
endif
ifneq ($(TARGET),$(findstring $(TARGET), hw hw_emu))
$(warning WARNING:Application supports only hw hw_emu TARGET. Please use the target for running the application)
endif


ifeq ($(HOST_ARCH), x86)
	perf_analyze profile -i profile_summary.csv -f html
endif

sd_card: $(EXECUTABLE) $(BINARY_CONTAINERS) emconfig
ifneq ($(HOST_ARCH), x86)
	mkdir -p $(SDCARD)/$(BUILD_DIR)
	$(CP) $(B_NAME)/sw/$(XSA)/boot/generic.readme $(B_NAME)/sw/$(XSA)/xrt/image/* xrt.ini $(EXECUTABLE) $(SDCARD)
	$(CP) $(BUILD_DIR)/*.xclbin $(SDCARD)/$(BUILD_DIR)/
ifeq ($(TARGET),$(filter $(TARGET),sw_emu hw_emu))
	$(ECHO) 'cd /mnt/' >> $(SDCARD)/init.sh
	$(ECHO) 'export XILINX_VITIS=$$PWD' >> $(SDCARD)/init.sh
	$(ECHO) 'export XCL_EMULATION_MODE=$(TARGET)' >> $(SDCARD)/init.sh
	$(ECHO) './$(EXECUTABLE) $(CMD_ARGS)' >> $(SDCARD)/init.sh
	$(ECHO) 'reboot' >> $(SDCARD)/init.sh
else
	[ -f $(SDCARD)/BOOT.BIN ] && echo "INFO: BOOT.BIN already exists" || $(CP) $(BUILD_DIR)/sd_card/BOOT.BIN $(SDCARD)/
	$(ECHO) './$(EXECUTABLE) $(CMD_ARGS)' >> $(SDCARD)/init.sh
endif
endif

# Cleaning stuff
clean:
	-$(RMDIR) $(EXECUTABLE) $(XCLBIN)/{*sw_emu*,*hw_emu*} 
	-$(RMDIR) profile_* TempConfig system_estimate.xtxt *.rpt *.csv .run
	-$(RMDIR) src/*.ll *v++* .Xil emconfig.json dltmp* xmltmp* *.log *.jou *.wcfg *.wdb

cleanall: clean
	-$(RMDIR) build_dir* sd_card*
	-$(RMDIR) _x.* *xclbin.run_summary qemu-memory-_* emulation/ _vimage/ pl* start_simulation.sh *.xclbin _x
	-$(RMDIR) ./tmp_kernel_pack* ./packaged_kernel* 

cmac_krnl: $(CMAC_KRNL)
network_krnl: $(NETWORK_KRNL)

$(CMAC_KRNL): kernel/cmac_krnl/cmac_krnl.xml kernel/cmac_krnl/package_cmac_krnl.tcl scripts/gen_xo.tcl kernel/cmac_krnl/src/hdl/*.sv
	mkdir -p $(TEMP_DIR)
	vivado -mode batch -source scripts/gen_xo.tcl -tclargs $(TEMP_DIR)/cmac_krnl.xo cmac_krnl $(TARGET) $(DEVICE) $(XSA) kernel/cmac_krnl/cmac_krnl.xml kernel/cmac_krnl/package_cmac_krnl.tcl

$(NETWORK_KRNL): kernel/network_krnl/network_krnl.xml kernel/network_krnl/package_network_krnl.tcl scripts/gen_xo.tcl kernel/network_krnl/src/hdl/*.sv
	mkdir -p $(TEMP_DIR)
	vivado -mode batch -source scripts/gen_xo.tcl -tclargs $(TEMP_DIR)/network_krnl.xo network_krnl $(TARGET) $(DEVICE) $(XSA) kernel/network_krnl/network_krnl.xml kernel/network_krnl/package_network_krnl.tcl



