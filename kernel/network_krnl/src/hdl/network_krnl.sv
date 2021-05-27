/* (c) Copyright 2019 Xilinx, Inc. All rights reserved.
 This file contains confidential and proprietary information 
 of Xilinx, Inc. and is protected under U.S. and
 international copyright and other intellectual property 
 laws.
 
 DISCLAIMER
 This disclaimer is not a license and does not grant any 
 rights to the materials distributed herewith. Except as 
 otherwise provided in a valid license issued to you by 
 Xilinx, and to the maximum extent permitted by applicable
 law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
 WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES 
 AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING 
 BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
 INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and 
 (2) Xilinx shall not be liable (whether in contract or tort, 
 including negligence, or under any other theory of 
 liability) for any loss or damage of any kind or nature 
 related to, arising under or in connection with these 
 materials, including for any direct, or any indirect, 
 special, incidental, or consequential loss or damage 
 (including loss of data, profits, goodwill, or any type of 
 loss or damage suffered as a result of any action brought 
 by a third party) even if such damage or loss was 
 reasonably foreseeable or Xilinx had been advised of the 
 possibility of the same.
 
 CRITICAL APPLICATIONS
 Xilinx products are not designed or intended to be fail-
 safe, or for use in any application requiring fail-safe
 performance, such as life-support or safety devices or 
 systems, Class III medical devices, nuclear facilities, 
 applications related to the deployment of airbags, or any 
 other applications that could lead to death, personal 
 injury, or severe property or environmental damage 
 (individually and collectively, "Critical 
 Applications"). Customer assumes the sole risk and 
 liability of any use of Xilinx products in Critical 
 Applications, subject only to applicable laws and 
 regulations governing limitations on product liability.
 
 THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS 
 PART OF THIS FILE AT ALL TIMES.
*/

// This is a generated file. Use and modify at your own risk.
//////////////////////////////////////////////////////////////////////////////// 
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps

`include "network_types.svh"
`include "network_intf.svh"

`define IP_VERSION4


// Top level of the kernel. Do not modify module name, parameters or ports.
module network_krnl #(
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH                = 12 ,
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH                = 32 ,
  parameter integer C_M00_AXI_ADDR_WIDTH                      = 64 ,
  parameter integer C_M00_AXI_DATA_WIDTH                      = 512,
  parameter integer C_M01_AXI_ADDR_WIDTH                      = 64 ,
  parameter integer C_M01_AXI_DATA_WIDTH                      = 512,
  parameter integer C_M_AXIS_UDP_RX_TDATA_WIDTH               = 512,
  parameter integer C_S_AXIS_UDP_TX_TDATA_WIDTH               = 512,
  parameter integer C_M_AXIS_UDP_RX_META_TDATA_WIDTH          = 256,
  parameter integer C_S_AXIS_UDP_TX_META_TDATA_WIDTH          = 256,
  parameter integer C_S_AXIS_TCP_LISTEN_PORT_TDATA_WIDTH      = 16 ,
  parameter integer C_M_AXIS_TCP_PORT_STATUS_TDATA_WIDTH      = 8  ,
  parameter integer C_S_AXIS_TCP_OPEN_CONNECTION_TDATA_WIDTH  = 64 ,
  parameter integer C_M_AXIS_TCP_OPEN_STATUS_TDATA_WIDTH      = 128 ,
  parameter integer C_S_AXIS_TCP_CLOSE_CONNECTION_TDATA_WIDTH = 16 ,
  parameter integer C_M_AXIS_TCP_NOTIFICATION_TDATA_WIDTH     = 128,
  parameter integer C_S_AXIS_TCP_READ_PKG_TDATA_WIDTH         = 32 ,
  parameter integer C_M_AXIS_TCP_RX_META_TDATA_WIDTH          = 16 ,
  parameter integer C_M_AXIS_TCP_RX_DATA_TDATA_WIDTH          = 512,
  parameter integer C_S_AXIS_TCP_TX_META_TDATA_WIDTH          = 32 ,
  parameter integer C_S_AXIS_TCP_TX_DATA_TDATA_WIDTH          = 512,
  parameter integer C_M_AXIS_TCP_TX_STATUS_TDATA_WIDTH        = 64 ,
  parameter integer C_AXIS_NET_TX_TDATA_WIDTH                 = 512,
  parameter integer C_AXIS_NET_RX_TDATA_WIDTH                 = 512
)
(
  // System Signals
  input  wire                                                   ap_clk                            ,
  input  wire                                                   ap_rst_n                          ,
  // input  wire                                                   ap_clk_2                            ,
  // input  wire                                                   ap_rst_n_2                          ,

  //  Note: A minimum subset of AXI4 memory mapped signals are declared.  AXI
  // signals omitted from these interfaces are automatically inferred with the
  // optimal values for Xilinx accleration platforms.  This allows Xilinx AXI4 Interconnects
  // within the system to be optimized by removing logic for AXI4 protocol
  // features that are not necessary. When adapting AXI4 masters within the RTL
  // kernel that have signals not declared below, it is suitable to add the
  // signals to the declarations below to connect them to the AXI4 Master.
  // 
  // List of ommited signals - effect
  // -------------------------------
  // ID - Transaction ID are used for multithreading and out of order
  // transactions.  This increases complexity. This saves logic and increases Fmax
  // in the system when ommited.
  // SIZE - Default value is log2(data width in bytes). Needed for subsize bursts.
  // This saves logic and increases Fmax in the system when ommited.
  // BURST - Default value (0b01) is incremental.  Wrap and fixed bursts are not
  // recommended. This saves logic and increases Fmax in the system when ommited.
  // LOCK - Not supported in AXI4
  // CACHE - Default value (0b0011) allows modifiable transactions. No benefit to
  // changing this.
  // PROT - Has no effect in current acceleration platforms.
  // QOS - Has no effect in current acceleration platforms.
  // REGION - Has no effect in current acceleration platforms.
  // USER - Has no effect in current acceleration platforms.
  // RESP - Not useful in most acceleration platforms.
  // 
  // AXI4 master interface m00_axi
  output wire                                                   m00_axi_awvalid                   ,
  input  wire                                                   m00_axi_awready                   ,
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]                        m00_axi_awaddr                    ,
  output wire [8-1:0]                                           m00_axi_awlen                     ,
  output wire                                                   m00_axi_wvalid                    ,
  input  wire                                                   m00_axi_wready                    ,
  output wire [C_M00_AXI_DATA_WIDTH-1:0]                        m00_axi_wdata                     ,
  output wire [C_M00_AXI_DATA_WIDTH/8-1:0]                      m00_axi_wstrb                     ,
  output wire                                                   m00_axi_wlast                     ,
  input  wire                                                   m00_axi_bvalid                    ,
  output wire                                                   m00_axi_bready                    ,
  output wire                                                   m00_axi_arvalid                   ,
  input  wire                                                   m00_axi_arready                   ,
  output wire [C_M00_AXI_ADDR_WIDTH-1:0]                        m00_axi_araddr                    ,
  output wire [8-1:0]                                           m00_axi_arlen                     ,
  input  wire                                                   m00_axi_rvalid                    ,
  output wire                                                   m00_axi_rready                    ,
  input  wire [C_M00_AXI_DATA_WIDTH-1:0]                        m00_axi_rdata                     ,
  input  wire                                                   m00_axi_rlast                     ,
  // AXI4 master interface m01_axi
  output wire                                                   m01_axi_awvalid                   ,
  input  wire                                                   m01_axi_awready                   ,
  output wire [C_M01_AXI_ADDR_WIDTH-1:0]                        m01_axi_awaddr                    ,
  output wire [8-1:0]                                           m01_axi_awlen                     ,
  output wire                                                   m01_axi_wvalid                    ,
  input  wire                                                   m01_axi_wready                    ,
  output wire [C_M01_AXI_DATA_WIDTH-1:0]                        m01_axi_wdata                     ,
  output wire [C_M01_AXI_DATA_WIDTH/8-1:0]                      m01_axi_wstrb                     ,
  output wire                                                   m01_axi_wlast                     ,
  input  wire                                                   m01_axi_bvalid                    ,
  output wire                                                   m01_axi_bready                    ,
  output wire                                                   m01_axi_arvalid                   ,
  input  wire                                                   m01_axi_arready                   ,
  output wire [C_M01_AXI_ADDR_WIDTH-1:0]                        m01_axi_araddr                    ,
  output wire [8-1:0]                                           m01_axi_arlen                     ,
  input  wire                                                   m01_axi_rvalid                    ,
  output wire                                                   m01_axi_rready                    ,
  input  wire [C_M01_AXI_DATA_WIDTH-1:0]                        m01_axi_rdata                     ,
  input  wire                                                   m01_axi_rlast                     ,
  /*// AXI4-Stream (master) interface m_axis_udp_rx
  output wire                                                   m_axis_udp_rx_tvalid              ,
  input  wire                                                   m_axis_udp_rx_tready              ,
  output wire [C_M_AXIS_UDP_RX_TDATA_WIDTH-1:0]                 m_axis_udp_rx_tdata               ,
  output wire [C_M_AXIS_UDP_RX_TDATA_WIDTH/8-1:0]               m_axis_udp_rx_tkeep               ,
  output wire                                                   m_axis_udp_rx_tlast               ,
  // AXI4-Stream (slave) interface s_axis_udp_tx
  input  wire                                                   s_axis_udp_tx_tvalid              ,
  output wire                                                   s_axis_udp_tx_tready              ,
  input  wire [C_S_AXIS_UDP_TX_TDATA_WIDTH-1:0]                 s_axis_udp_tx_tdata               ,
  input  wire [C_S_AXIS_UDP_TX_TDATA_WIDTH/8-1:0]               s_axis_udp_tx_tkeep               ,
  input  wire                                                   s_axis_udp_tx_tlast               ,
  // AXI4-Stream (master) interface m_axis_udp_rx_meta
  output wire                                                   m_axis_udp_rx_meta_tvalid         ,
  input  wire                                                   m_axis_udp_rx_meta_tready         ,
  output wire [C_M_AXIS_UDP_RX_META_TDATA_WIDTH-1:0]            m_axis_udp_rx_meta_tdata          ,
  output wire [C_M_AXIS_UDP_RX_META_TDATA_WIDTH/8-1:0]          m_axis_udp_rx_meta_tkeep          ,
  output wire                                                   m_axis_udp_rx_meta_tlast          ,
  // AXI4-Stream (slave) interface s_axis_udp_tx_meta
  input  wire                                                   s_axis_udp_tx_meta_tvalid         ,
  output wire                                                   s_axis_udp_tx_meta_tready         ,
  input  wire [C_S_AXIS_UDP_TX_META_TDATA_WIDTH-1:0]            s_axis_udp_tx_meta_tdata          ,
  input  wire [C_S_AXIS_UDP_TX_META_TDATA_WIDTH/8-1:0]          s_axis_udp_tx_meta_tkeep          ,
  input  wire                                                   s_axis_udp_tx_meta_tlast          ,*/
  // AXI4-Stream (slave) interface s_axis_tcp_listen_port
  input  wire                                                   s_axis_tcp_listen_port_tvalid     ,
  output wire                                                   s_axis_tcp_listen_port_tready     ,
  input  wire [C_S_AXIS_TCP_LISTEN_PORT_TDATA_WIDTH-1:0]        s_axis_tcp_listen_port_tdata      ,
  input  wire [C_S_AXIS_TCP_LISTEN_PORT_TDATA_WIDTH/8-1:0]      s_axis_tcp_listen_port_tkeep      ,
  input  wire                                                   s_axis_tcp_listen_port_tlast      ,
  // AXI4-Stream (master) interface m_axis_tcp_port_status
  output wire                                                   m_axis_tcp_port_status_tvalid     ,
  input  wire                                                   m_axis_tcp_port_status_tready     ,
  output wire [C_M_AXIS_TCP_PORT_STATUS_TDATA_WIDTH-1:0]        m_axis_tcp_port_status_tdata      ,
  output wire                                                   m_axis_tcp_port_status_tlast      ,
  // AXI4-Stream (slave) interface s_axis_tcp_open_connection
  input  wire                                                   s_axis_tcp_open_connection_tvalid ,
  output wire                                                   s_axis_tcp_open_connection_tready ,
  input  wire [C_S_AXIS_TCP_OPEN_CONNECTION_TDATA_WIDTH-1:0]    s_axis_tcp_open_connection_tdata  ,
  input  wire [C_S_AXIS_TCP_OPEN_CONNECTION_TDATA_WIDTH/8-1:0]  s_axis_tcp_open_connection_tkeep  ,
  input  wire                                                   s_axis_tcp_open_connection_tlast  ,
  // AXI4-Stream (master) interface m_axis_tcp_open_status
  output wire                                                   m_axis_tcp_open_status_tvalid     ,
  input  wire                                                   m_axis_tcp_open_status_tready     ,
  output wire [C_M_AXIS_TCP_OPEN_STATUS_TDATA_WIDTH-1:0]        m_axis_tcp_open_status_tdata      ,
  output wire [C_M_AXIS_TCP_OPEN_STATUS_TDATA_WIDTH/8-1:0]      m_axis_tcp_open_status_tkeep      ,
  output wire                                                   m_axis_tcp_open_status_tlast      ,
  // AXI4-Stream (slave) interface s_axis_tcp_close_connection
//  input  wire                                                   s_axis_tcp_close_connection_tvalid,
//  output wire                                                   s_axis_tcp_close_connection_tready,
//  input  wire [C_S_AXIS_TCP_CLOSE_CONNECTION_TDATA_WIDTH-1:0]   s_axis_tcp_close_connection_tdata ,
//  input  wire [C_S_AXIS_TCP_CLOSE_CONNECTION_TDATA_WIDTH/8-1:0] s_axis_tcp_close_connection_tkeep ,
//  input  wire                                                   s_axis_tcp_close_connection_tlast ,
  // AXI4-Stream (master) interface m_axis_tcp_notification
  output wire                                                   m_axis_tcp_notification_tvalid    ,
  input  wire                                                   m_axis_tcp_notification_tready    ,
  output wire [C_M_AXIS_TCP_NOTIFICATION_TDATA_WIDTH-1:0]       m_axis_tcp_notification_tdata     ,
  output wire [C_M_AXIS_TCP_NOTIFICATION_TDATA_WIDTH/8-1:0]     m_axis_tcp_notification_tkeep     ,
  output wire                                                   m_axis_tcp_notification_tlast     ,
  // AXI4-Stream (slave) interface s_axis_tcp_read_pkg
  input  wire                                                   s_axis_tcp_read_pkg_tvalid        ,
  output wire                                                   s_axis_tcp_read_pkg_tready        ,
  input  wire [C_S_AXIS_TCP_READ_PKG_TDATA_WIDTH-1:0]           s_axis_tcp_read_pkg_tdata         ,
  input  wire [C_S_AXIS_TCP_READ_PKG_TDATA_WIDTH/8-1:0]         s_axis_tcp_read_pkg_tkeep         ,
  input  wire                                                   s_axis_tcp_read_pkg_tlast         ,
  // AXI4-Stream (master) interface m_axis_tcp_rx_meta
  output wire                                                   m_axis_tcp_rx_meta_tvalid         ,
  input  wire                                                   m_axis_tcp_rx_meta_tready         ,
  output wire [C_M_AXIS_TCP_RX_META_TDATA_WIDTH-1:0]            m_axis_tcp_rx_meta_tdata          ,
  output wire [C_M_AXIS_TCP_RX_META_TDATA_WIDTH/8-1:0]          m_axis_tcp_rx_meta_tkeep          ,
  output wire                                                   m_axis_tcp_rx_meta_tlast          ,
  // AXI4-Stream (master) interface m_axis_tcp_rx_data
  output wire                                                   m_axis_tcp_rx_data_tvalid         ,
  input  wire                                                   m_axis_tcp_rx_data_tready         ,
  output wire [C_M_AXIS_TCP_RX_DATA_TDATA_WIDTH-1:0]            m_axis_tcp_rx_data_tdata          ,
  output wire [C_M_AXIS_TCP_RX_DATA_TDATA_WIDTH/8-1:0]          m_axis_tcp_rx_data_tkeep          ,
  output wire                                                   m_axis_tcp_rx_data_tlast          ,
  // AXI4-Stream (slave) interface s_axis_tcp_tx_meta
  input  wire                                                   s_axis_tcp_tx_meta_tvalid         ,
  output wire                                                   s_axis_tcp_tx_meta_tready         ,
  input  wire [C_S_AXIS_TCP_TX_META_TDATA_WIDTH-1:0]            s_axis_tcp_tx_meta_tdata          ,
  input  wire [C_S_AXIS_TCP_TX_META_TDATA_WIDTH/8-1:0]          s_axis_tcp_tx_meta_tkeep          ,
  input  wire                                                   s_axis_tcp_tx_meta_tlast          ,
  // AXI4-Stream (slave) interface s_axis_tcp_tx_data
  input  wire                                                   s_axis_tcp_tx_data_tvalid         ,
  output wire                                                   s_axis_tcp_tx_data_tready         ,
  input  wire [C_S_AXIS_TCP_TX_DATA_TDATA_WIDTH-1:0]            s_axis_tcp_tx_data_tdata          ,
  input  wire [C_S_AXIS_TCP_TX_DATA_TDATA_WIDTH/8-1:0]          s_axis_tcp_tx_data_tkeep          ,
  input  wire                                                   s_axis_tcp_tx_data_tlast          ,
  // AXI4-Stream (master) interface m_axis_tcp_tx_status
  output wire                                                   m_axis_tcp_tx_status_tvalid       ,
  input  wire                                                   m_axis_tcp_tx_status_tready       ,
  output wire [C_M_AXIS_TCP_TX_STATUS_TDATA_WIDTH-1:0]          m_axis_tcp_tx_status_tdata        ,
  output wire [C_M_AXIS_TCP_TX_STATUS_TDATA_WIDTH/8-1:0]        m_axis_tcp_tx_status_tkeep        ,
  output wire                                                   m_axis_tcp_tx_status_tlast        ,
  // AXI4-Stream (master) interface axis_net_tx
  output wire                                                   axis_net_tx_tvalid                ,
  input  wire                                                   axis_net_tx_tready                ,
  output wire [C_AXIS_NET_TX_TDATA_WIDTH-1:0]                   axis_net_tx_tdata                 ,
  output wire [C_AXIS_NET_TX_TDATA_WIDTH/8-1:0]                 axis_net_tx_tkeep                 ,
  output wire                                                   axis_net_tx_tlast                 ,
  // AXI4-Stream (slave) interface axis_net_rx
  input  wire                                                   axis_net_rx_tvalid                ,
  output wire                                                   axis_net_rx_tready                ,
  input  wire [C_AXIS_NET_RX_TDATA_WIDTH-1:0]                   axis_net_rx_tdata                 ,
  input  wire [C_AXIS_NET_RX_TDATA_WIDTH/8-1:0]                 axis_net_rx_tkeep                 ,
  input  wire                                                   axis_net_rx_tlast                 ,
  // AXI4-Lite slave interface
  input  wire                                                   s_axi_control_awvalid             ,
  output wire                                                   s_axi_control_awready             ,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]                  s_axi_control_awaddr              ,
  input  wire                                                   s_axi_control_wvalid              ,
  output wire                                                   s_axi_control_wready              ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]                  s_axi_control_wdata               ,
  input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0]                s_axi_control_wstrb               ,
  input  wire                                                   s_axi_control_arvalid             ,
  output wire                                                   s_axi_control_arready             ,
  input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]                  s_axi_control_araddr              ,
  output wire                                                   s_axi_control_rvalid              ,
  input  wire                                                   s_axi_control_rready              ,
  output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]                  s_axi_control_rdata               ,
  output wire [2-1:0]                                           s_axi_control_rresp               ,
  output wire                                                   s_axi_control_bvalid              ,
  input  wire                                                   s_axi_control_bready              ,
  output wire [2-1:0]                                           s_axi_control_bresp               ,
  output wire                                                   interrupt                         
);




///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
(* DONT_TOUCH = "yes" *)
logic areset = 1'b0;
logic areset_2 = 1'b0;
logic ap_rst_n_reg = 1'b1;
logic ap_rst_n_2_reg = 1'b1;

// Register and invert reset signal.
always @(posedge ap_clk) begin
  areset <= ~ap_rst_n;
  areset_2 <= ~ap_rst_n;
  ap_rst_n_reg <= ap_rst_n;
  ap_rst_n_2_reg <= ap_rst_n;
end

assign interrupt = 1'b0;

wire [63:0] rx_ddr_offset_addr, tx_ddr_offset_addr;
///////////////////////////////////////////////////////////////////////////////
// Stack
///////////////////////////////////////////////////////////////////////////////

// AXI ctrl
axi_lite s_axil ();

// axil_clock_converter axi_lite_clock_converter (
//   .s_axi_aclk(ap_clk),                    // input wire aclk
//   .s_axi_aresetn(ap_rst_n_reg),              // input wire aresetn
//   .s_axi_awaddr(s_axi_control_awaddr),    // input wire [31 : 0] s_axi_awaddr
//   .s_axi_awprot(3'b00),    // input wire [2 : 0] s_axi_awprot
//   .s_axi_awvalid(s_axi_control_awvalid),  // input wire s_axi_awvalid
//   .s_axi_awready(s_axi_control_awready),  // output wire s_axi_awready
//   .s_axi_wdata(s_axi_control_wdata),      // input wire [31 : 0] s_axi_wdata
//   .s_axi_wstrb(s_axi_control_wstrb),      // input wire [3 : 0] s_axi_wstrb
//   .s_axi_wvalid(s_axi_control_wvalid),    // input wire s_axi_wvalid
//   .s_axi_wready(s_axi_control_wready),    // output wire s_axi_wready
//   .s_axi_bresp(s_axi_control_bresp),      // output wire [1 : 0] s_axi_bresp
//   .s_axi_bvalid(s_axi_control_bvalid),    // output wire s_axi_bvalid
//   .s_axi_bready(s_axi_control_bready),    // input wire s_axi_bready
//   .s_axi_araddr(s_axi_control_araddr),    // input wire [31 : 0] s_axi_araddr
//   .s_axi_arprot(3'b00),    // input wire [2 : 0] s_axi_arprot
//   .s_axi_arvalid(s_axi_control_arvalid),  // input wire s_axi_arvalid
//   .s_axi_arready(s_axi_control_arready),  // output wire s_axi_arready
//   .s_axi_rdata(s_axi_control_rdata),      // output wire [31 : 0] s_axi_rdata
//   .s_axi_rresp(s_axi_control_rresp),      // output wire [1 : 0] s_axi_rresp
//   .s_axi_rvalid(s_axi_control_rvalid),    // output wire s_axi_rvalid
//   .s_axi_rready(s_axi_control_rready),    // input wire s_axi_rready

//   .m_axi_aclk(ap_clk),        // input wire m_axi_aclk
//   .m_axi_aresetn(ap_rst_n_2_reg),  // input wire m_axi_aresetn
//   .m_axi_awaddr(s_axil.awaddr),    // output wire [31 : 0] m_axi_awaddr
//   .m_axi_awprot(),    // output wire [2 : 0] m_axi_awprot
//   .m_axi_awvalid(s_axil.awvalid),  // output wire m_axi_awvalid
//   .m_axi_awready(s_axil.awready),  // input wire m_axi_awready
//   .m_axi_wdata(s_axil.wdata),      // output wire [31 : 0] m_axi_wdata
//   .m_axi_wstrb(s_axil.wstrb),      // output wire [3 : 0] m_axi_wstrb
//   .m_axi_wvalid(s_axil.wvalid),    // output wire m_axi_wvalid
//   .m_axi_wready(s_axil.wready),    // input wire m_axi_wready
//   .m_axi_bresp(s_axil.bresp),      // input wire [1 : 0] m_axi_bresp
//   .m_axi_bvalid(s_axil.bvalid),    // input wire m_axi_bvalid
//   .m_axi_bready(s_axil.bready),    // output wire m_axi_bready
//   .m_axi_araddr(s_axil.araddr),    // output wire [31 : 0] m_axi_araddr
//   .m_axi_arprot(),    // output wire [2 : 0] m_axi_arprot
//   .m_axi_arvalid(s_axil.arvalid),  // output wire m_axi_arvalid
//   .m_axi_arready(s_axil.arready),  // input wire m_axi_arready
//   .m_axi_rdata(s_axil.rdata),      // input wire [31 : 0] m_axi_rdata
//   .m_axi_rresp(s_axil.rresp),      // input wire [1 : 0] m_axi_rresp
//   .m_axi_rvalid(s_axil.rvalid),    // input wire m_axi_rvalid
//   .m_axi_rready(s_axil.rready)    // output wire m_axi_rready
// );

// UDP
axis_meta #(.WIDTH(176)) m_axis_udp_rx_metadata();

// axis_data_fifo_cc_256 m_axis_udp_rx_metadata_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_2_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(m_axis_udp_rx_metadata.valid),
//   .s_axis_tready(m_axis_udp_rx_metadata.ready),
//   .s_axis_tdata(m_axis_udp_rx_metadata.data),
//   .s_axis_tkeep('1),
//   .s_axis_tlast(1),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(m_axis_udp_rx_meta_tvalid),
//   .m_axis_tready(m_axis_udp_rx_meta_tready),
//   .m_axis_tdata(m_axis_udp_rx_meta_tdata),
//   .m_axis_tkeep(m_axis_udp_rx_meta_tkeep),
//   .m_axis_tlast(m_axis_udp_rx_meta_tlast)
// );


axis_meta #(.WIDTH(176)) s_axis_udp_tx_metadata();

// axis_data_fifo_cc_256 s_axis_udp_tx_metadata_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(s_axis_udp_tx_meta_tvalid),
//   .s_axis_tready(s_axis_udp_tx_meta_tready),
//   .s_axis_tdata(s_axis_udp_tx_meta_tdata),
//   .s_axis_tkeep(s_axis_udp_tx_meta_tkeep),
//   .s_axis_tlast(s_axis_udp_tx_meta_tlast),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(s_axis_udp_tx_metadata.valid),
//   .m_axis_tready(s_axis_udp_tx_metadata.ready),
//   .m_axis_tdata(s_axis_udp_tx_metadata.data),
//   .m_axis_tkeep(),
//   .m_axis_tlast()
// );

axi_stream #(.WIDTH(NETWORK_STACK_WIDTH)) m_axis_udp_rx_data();

// axis_data_fifo_cc_512 m_axis_udp_rx_data_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_2_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(m_axis_udp_rx_data.valid),
//   .s_axis_tready(m_axis_udp_rx_data.ready),
//   .s_axis_tdata(m_axis_udp_rx_data.data),
//   .s_axis_tkeep(m_axis_udp_rx_data.keep),
//   .s_axis_tlast(m_axis_udp_rx_data.last),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(m_axis_udp_rx_tvalid),
//   .m_axis_tready(m_axis_udp_rx_tready),
//   .m_axis_tdata(m_axis_udp_rx_tdata),
//   .m_axis_tkeep(m_axis_udp_rx_tkeep),
//   .m_axis_tlast(m_axis_udp_rx_tlast)
// );

axi_stream #(.WIDTH(NETWORK_STACK_WIDTH)) s_axis_udp_tx_data();

// axis_data_fifo_cc_512 s_axis_udp_tx_data_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(s_axis_udp_tx_tvalid),
//   .s_axis_tready(s_axis_udp_tx_tready),
//   .s_axis_tdata(s_axis_udp_tx_tdata),
//   .s_axis_tkeep(s_axis_udp_tx_tkeep),
//   .s_axis_tlast(s_axis_udp_tx_tlast),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(s_axis_udp_tx_data.valid),
//   .m_axis_tready(s_axis_udp_tx_data.ready),
//   .m_axis_tdata(s_axis_udp_tx_data.data),
//   .m_axis_tkeep(s_axis_udp_tx_data.keep),
//   .m_axis_tlast(s_axis_udp_tx_data.last)
// );

//TCP/IP
axis_meta #(.WIDTH(16))     s_axis_tcp_listen_port();

// axis_data_fifo_cc_16 s_axis_tcp_listen_port_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(s_axis_tcp_listen_port_tvalid),
//   .s_axis_tready(s_axis_tcp_listen_port_tready),
//   .s_axis_tdata(s_axis_tcp_listen_port_tdata),
//   .s_axis_tkeep(s_axis_tcp_listen_port_tkeep),
//   .s_axis_tlast(s_axis_tcp_listen_port_tlast),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(s_axis_tcp_listen_port.valid),
//   .m_axis_tready(s_axis_tcp_listen_port.ready),
//   .m_axis_tdata(s_axis_tcp_listen_port.data),
//   .m_axis_tkeep(),
//   .m_axis_tlast()
// );

//port status
axis_meta #(.WIDTH(8))      m_axis_tcp_port_status();

// axis_data_fifo_cc_8 m_axis_tcp_port_status_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_2_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(m_axis_tcp_port_status.valid),
//   .s_axis_tready(m_axis_tcp_port_status.ready),
//   .s_axis_tdata(m_axis_tcp_port_status.data),
//   .s_axis_tkeep('1),
//   .s_axis_tlast(1),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(m_axis_tcp_port_status_tvalid),
//   .m_axis_tready(m_axis_tcp_port_status_tready),
//   .m_axis_tdata(m_axis_tcp_port_status_tdata),
//   .m_axis_tkeep(),
//   .m_axis_tlast(m_axis_tcp_port_status_tlast)
// );

//open connection
axis_meta #(.WIDTH(48))     s_axis_tcp_open_connection();

axis_data_fifo_64_d256 s_axis_tcp_open_connection_fifo (
  //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
  .s_axis_aresetn(~areset),
  .s_axis_aclk(ap_clk),
  .s_axis_tvalid(s_axis_tcp_open_connection_tvalid),
  .s_axis_tready(s_axis_tcp_open_connection_tready),
  .s_axis_tdata(s_axis_tcp_open_connection_tdata),
  .s_axis_tkeep(s_axis_tcp_open_connection_tkeep),
  .s_axis_tlast(s_axis_tcp_open_connection_tlast),
  // .m_axis_aclk(ap_clk),
  .m_axis_tvalid(s_axis_tcp_open_connection.valid),
  .m_axis_tready(s_axis_tcp_open_connection.ready),
  .m_axis_tdata(s_axis_tcp_open_connection.data),
  .m_axis_tkeep(),
  .m_axis_tlast()
);


//open status
axis_meta #(.WIDTH(72))     m_axis_tcp_open_status();

axis_data_fifo_72_d256 m_axis_tcp_open_status_fifo (
  //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
  .s_axis_aresetn(~areset),
  .s_axis_aclk(ap_clk),
  .s_axis_tvalid(m_axis_tcp_open_status.valid),
  .s_axis_tready(m_axis_tcp_open_status.ready),
  .s_axis_tdata(m_axis_tcp_open_status.data),
  .s_axis_tkeep('1),
  .s_axis_tlast(1),
  // .m_axis_aclk(ap_clk),
  .m_axis_tvalid(m_axis_tcp_open_status_tvalid),
  .m_axis_tready(m_axis_tcp_open_status_tready),
  .m_axis_tdata(m_axis_tcp_open_status_tdata),
  .m_axis_tkeep(m_axis_tcp_open_status_tkeep),
  .m_axis_tlast(m_axis_tcp_open_status_tlast)
);

axis_meta #(.WIDTH(16))     s_axis_tcp_close_connection();

// axis_data_fifo_cc_16 s_axis_tcp_close_connection_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(s_axis_tcp_close_connection_tvalid),
//   .s_axis_tready(s_axis_tcp_close_connection_tready),
//   .s_axis_tdata(s_axis_tcp_close_connection_tdata),
//   .s_axis_tkeep(s_axis_tcp_close_connection_tkeep),
//   .s_axis_tlast(s_axis_tcp_close_connection_tlast),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(s_axis_tcp_close_connection.valid),
//   .m_axis_tready(s_axis_tcp_close_connection.ready),
//   .m_axis_tdata(s_axis_tcp_close_connection.data),
//   .m_axis_tkeep(),
//   .m_axis_tlast()
// );

//
axis_meta #(.WIDTH(88))     m_axis_tcp_notification();

// axis_data_fifo_cc_128 m_axis_tcp_notification_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_2_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(m_axis_tcp_notification.valid),
//   .s_axis_tready(m_axis_tcp_notification.ready),
//   .s_axis_tdata(m_axis_tcp_notification.data),
//   .s_axis_tkeep('1),
//   .s_axis_tlast(1),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(m_axis_tcp_notification_tvalid),
//   .m_axis_tready(m_axis_tcp_notification_tready),
//   .m_axis_tdata(m_axis_tcp_notification_tdata),
//   .m_axis_tkeep(m_axis_tcp_notification_tkeep),
//   .m_axis_tlast(m_axis_tcp_notification_tlast)
// );

axis_meta #(.WIDTH(32))     s_axis_tcp_read_pkg();

// axis_data_fifo_cc_32 s_axis_tcp_read_pkg_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(s_axis_tcp_read_pkg_tvalid),
//   .s_axis_tready(s_axis_tcp_read_pkg_tready),
//   .s_axis_tdata(s_axis_tcp_read_pkg_tdata),
//   .s_axis_tkeep(s_axis_tcp_read_pkg_tkeep),
//   .s_axis_tlast(s_axis_tcp_read_pkg_tlast),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(s_axis_tcp_read_pkg.valid),
//   .m_axis_tready(s_axis_tcp_read_pkg.ready),
//   .m_axis_tdata(s_axis_tcp_read_pkg.data),
//   .m_axis_tkeep(),
//   .m_axis_tlast()
// );

axis_meta #(.WIDTH(16))     m_axis_tcp_rx_meta();

// axis_data_fifo_cc_16 m_axis_tcp_rx_meta_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_2_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(m_axis_tcp_rx_meta.valid),
//   .s_axis_tready(m_axis_tcp_rx_meta.ready),
//   .s_axis_tdata(m_axis_tcp_rx_meta.data),
//   .s_axis_tkeep('1),
//   .s_axis_tlast(1),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(m_axis_tcp_rx_meta_tvalid),
//   .m_axis_tready(m_axis_tcp_rx_meta_tready),
//   .m_axis_tdata(m_axis_tcp_rx_meta_tdata),
//   .m_axis_tkeep(m_axis_tcp_rx_meta_tkeep),
//   .m_axis_tlast(m_axis_tcp_rx_meta_tlast)
// );

axi_stream #(.WIDTH(NETWORK_STACK_WIDTH))    m_axis_tcp_rx_data();

// axis_data_fifo_cc_512 m_axis_tcp_rx_data_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_2_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(m_axis_tcp_rx_data.valid),
//   .s_axis_tready(m_axis_tcp_rx_data.ready),
//   .s_axis_tdata(m_axis_tcp_rx_data.data),
//   .s_axis_tkeep(m_axis_tcp_rx_data.keep),
//   .s_axis_tlast(m_axis_tcp_rx_data.last),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(m_axis_tcp_rx_data_tvalid),
//   .m_axis_tready(m_axis_tcp_rx_data_tready),
//   .m_axis_tdata(m_axis_tcp_rx_data_tdata),
//   .m_axis_tkeep(m_axis_tcp_rx_data_tkeep),
//   .m_axis_tlast(m_axis_tcp_rx_data_tlast)
// );

axis_meta #(.WIDTH(32))     s_axis_tcp_tx_meta();

axis_data_fifo_32_d256 s_axis_tcp_tx_meta_fifo (
  //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
  .s_axis_aresetn(~areset),
  .s_axis_aclk(ap_clk),
  .s_axis_tvalid(s_axis_tcp_tx_meta_tvalid),
  .s_axis_tready(s_axis_tcp_tx_meta_tready),
  .s_axis_tdata(s_axis_tcp_tx_meta_tdata),
  .s_axis_tkeep(s_axis_tcp_tx_meta_tkeep),
  .s_axis_tlast(s_axis_tcp_tx_meta_tlast),
  // .m_axis_aclk(ap_clk),
  .m_axis_tvalid(s_axis_tcp_tx_meta.valid),
  .m_axis_tready(s_axis_tcp_tx_meta.ready),
  .m_axis_tdata(s_axis_tcp_tx_meta.data),
  .m_axis_tkeep(),
  .m_axis_tlast()
);

axi_stream #(.WIDTH(NETWORK_STACK_WIDTH))    s_axis_tcp_tx_data();

// axis_data_fifo_cc_512 s_axis_tcp_tx_data_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(s_axis_tcp_tx_data_tvalid),
//   .s_axis_tready(s_axis_tcp_tx_data_tready),
//   .s_axis_tdata(s_axis_tcp_tx_data_tdata),
//   .s_axis_tkeep(s_axis_tcp_tx_data_tkeep),
//   .s_axis_tlast(s_axis_tcp_tx_data_tlast),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(s_axis_tcp_tx_data.valid),
//   .m_axis_tready(s_axis_tcp_tx_data.ready),
//   .m_axis_tdata(s_axis_tcp_tx_data.data),
//   .m_axis_tkeep(s_axis_tcp_tx_data.keep),
//   .m_axis_tlast(s_axis_tcp_tx_data.last)
// );

axis_meta #(.WIDTH(64))     m_axis_tcp_tx_status();

axis_data_fifo_64_d256 m_axis_tcp_tx_status_fifo (
  //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
  .s_axis_aresetn(~areset),
  .s_axis_aclk(ap_clk),
  .s_axis_tvalid(m_axis_tcp_tx_status.valid),
  .s_axis_tready(m_axis_tcp_tx_status.ready),
  .s_axis_tdata(m_axis_tcp_tx_status.data),
  .s_axis_tkeep('1),
  .s_axis_tlast(1),
  // .m_axis_aclk(ap_clk),
  .m_axis_tvalid(m_axis_tcp_tx_status_tvalid),
  .m_axis_tready(m_axis_tcp_tx_status_tready),
  .m_axis_tdata(m_axis_tcp_tx_status_tdata),
  .m_axis_tkeep(m_axis_tcp_tx_status_tkeep),
  .m_axis_tlast(m_axis_tcp_tx_status_tlast)
);

//Net interface
axi_stream axis_net_rx_data_aclk();

// axis_data_fifo_cc_512 axis_net_rx_data_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(axis_net_rx_tvalid),
//   .s_axis_tready(axis_net_rx_tready),
//   .s_axis_tdata(axis_net_rx_tdata),
//   .s_axis_tkeep(axis_net_rx_tkeep),
//   .s_axis_tlast(axis_net_rx_tlast),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(axis_net_rx_data_aclk.valid),
//   .m_axis_tready(axis_net_rx_data_aclk.ready),
//   .m_axis_tdata(axis_net_rx_data_aclk.data),
//   .m_axis_tkeep(axis_net_rx_data_aclk.keep),
//   .m_axis_tlast(axis_net_rx_data_aclk.last)
// );

axi_stream axis_net_tx_data_aclk();

// axis_data_fifo_cc_512 axis_net_tx_data_crossing (
//   //.s_axis_aresetn(~(sys_reset | user_rx_reset)),
//   .s_axis_aresetn(ap_rst_n_2_reg),
//   .s_axis_aclk(ap_clk),
//   .s_axis_tvalid(axis_net_tx_data_aclk.valid),
//   .s_axis_tready(axis_net_tx_data_aclk.ready),
//   .s_axis_tdata(axis_net_tx_data_aclk.data),
//   .s_axis_tkeep(axis_net_tx_data_aclk.keep),
//   .s_axis_tlast(axis_net_tx_data_aclk.last),
//   .m_axis_aclk(ap_clk),
//   .m_axis_tvalid(axis_net_tx_tvalid),
//   .m_axis_tready(axis_net_tx_tready),
//   .m_axis_tdata(axis_net_tx_tdata),
//   .m_axis_tkeep(axis_net_tx_tkeep),
//   .m_axis_tlast(axis_net_tx_tlast)
// );

//TCP/IP DDR interface
axis_mem_cmd    axis_tcp_mem_read_cmd[NUM_TCP_CHANNELS]();
axi_stream      axis_tcp_mem_read_data[NUM_TCP_CHANNELS]();
axis_mem_status axis_tcp_mem_read_status[NUM_TCP_CHANNELS](); 

axis_mem_cmd    axis_tcp_mem_write_cmd[NUM_TCP_CHANNELS]();
axi_stream      axis_tcp_mem_write_data[NUM_TCP_CHANNELS]();
axis_mem_status axis_tcp_mem_write_status[NUM_TCP_CHANNELS]();

mem_single_inf #(
  `ifdef USE_DDR
      .ENABLE(1),
  `else
      .ENABLE(0),
  `endif
    .UNALIGNED(0 < NUM_TCP_CHANNELS)
    // .UNALIGNED(0)
) mem_inf_inst0 (
.user_clk(ap_clk),
.user_aresetn(ap_rst_n_2_reg),
.mem_clk(ap_clk),
.mem_aresetn(ap_rst_n_reg),

/* USER INTERFACE */
//memory read commands
.s_axis_mem_read_cmd(axis_tcp_mem_read_cmd[0]),
//memory read status
.m_axis_mem_read_status(axis_tcp_mem_read_status[0]),
//memory read stream
.m_axis_mem_read_data(axis_tcp_mem_read_data[0]),

//memory write commands
.s_axis_mem_write_cmd(axis_tcp_mem_write_cmd[0]),
//memory rite status
.m_axis_mem_write_status(axis_tcp_mem_write_status[0]),
//memory write stream
.s_axis_mem_write_data(axis_tcp_mem_write_data[0]),


/* DRIVER INTERFACE */
.m_axi_awid(),
.m_axi_awaddr(m00_axi_awaddr),
.m_axi_awlen(m00_axi_awlen),
.m_axi_awsize(),
.m_axi_awburst(),
.m_axi_awlock(),
.m_axi_awcache(),
.m_axi_awprot(),
.m_axi_awvalid(m00_axi_awvalid),
.m_axi_awready(m00_axi_awready),

.m_axi_wdata(m00_axi_wdata),
.m_axi_wstrb(m00_axi_wstrb),
.m_axi_wlast(m00_axi_wlast),
.m_axi_wvalid(m00_axi_wvalid),
.m_axi_wready(m00_axi_wready),

.m_axi_bready(m00_axi_bready),
.m_axi_bid(),
.m_axi_bresp(),
.m_axi_bvalid(m00_axi_bvalid),

.m_axi_arid(),
.m_axi_araddr(m00_axi_araddr),
.m_axi_arlen(m00_axi_arlen),
.m_axi_arsize(),
.m_axi_arburst(),
.m_axi_arlock(),
.m_axi_arcache(),
.m_axi_arprot(),
.m_axi_arvalid(m00_axi_arvalid),
.m_axi_arready(m00_axi_arready),

.m_axi_rready(m00_axi_rready),
.m_axi_rid(),
.m_axi_rdata(m00_axi_rdata),
.m_axi_rresp(),
.m_axi_rlast(m00_axi_rlast),
.m_axi_rvalid(m00_axi_rvalid),

.addr_offset(tx_ddr_offset_addr)
);


// wire rsta_busy, rstb_busy;
// wire [3:0]s_axi_awid;
// wire [31:0]s_axi_awaddr;
// wire [7:0]s_axi_awlen;
// wire [2:0]s_axi_awsize;
// wire [1:0]s_axi_awburst;
// wire s_axi_awvalid;
// wire s_axi_awready;
// wire [255:0]s_axi_wdata;
// wire [31:0]s_axi_wstrb;
// wire s_axi_wlast;
// wire s_axi_wvalid;
// wire s_axi_wready;
// wire [3:0]s_axi_bid;
// wire [1:0]s_axi_bresp;
// wire s_axi_bvalid;
// wire s_axi_bready;
// wire [3:0]s_axi_arid;
// wire [31:0]s_axi_araddr;
// wire [7:0]s_axi_arlen;
// wire [2:0]s_axi_arsize;
// wire [1:0]s_axi_arburst;
// wire s_axi_arvalid;
// wire s_axi_arready;
// wire [3:0]s_axi_rid;
// wire [255:0]s_axi_rdata;
// wire [1:0]s_axi_rresp;
// wire s_axi_rlast;
// wire s_axi_rvalid;
// wire s_axi_rready;

//   assign                                                   m00_axi_awvalid  = '0 ;
//   assign                         m00_axi_awaddr   = '0 ;
//   assign                                            m00_axi_awlen    = '0 ;
//   assign                                                   m00_axi_wvalid   = '0 ;
//   assign                         m00_axi_wdata    = '0 ;
//   assign                       m00_axi_wstrb    = '0 ;
//   assign                                                   m00_axi_wlast    = '0 ;
//   assign                                                   m00_axi_bready   = '1 ;
//   assign                                                   m00_axi_arvalid  = '0 ;
//   assign                         m00_axi_araddr   = '0 ;
//   assign                                            m00_axi_arlen    = '0 ;
//   assign                                                   m00_axi_rready   = '1 ;

// mem_single_inf #(
//   `ifdef USE_DDR
//       .ENABLE(1),
//   `else
//       .ENABLE(0),
//   `endif
//     .UNALIGNED(0 < NUM_TCP_CHANNELS)
// ) mem_inf_inst0 (
// .user_clk(ap_clk),
// .user_aresetn(ap_rst_n_2_reg),
// .mem_clk(ap_clk),
// .mem_aresetn(ap_rst_n_reg),

// /* USER INTERFACE */
// //memory read commands
// .s_axis_mem_read_cmd(axis_tcp_mem_read_cmd[0]),
// //memory read status
// .m_axis_mem_read_status(axis_tcp_mem_read_status[0]),
// //memory read stream
// .m_axis_mem_read_data(axis_tcp_mem_read_data[0]),

// //memory write commands
// .s_axis_mem_write_cmd(axis_tcp_mem_write_cmd[0]),
// //memory rite status
// .m_axis_mem_write_status(axis_tcp_mem_write_status[0]),
// //memory write stream
// .s_axis_mem_write_data(axis_tcp_mem_write_data[0]),


// /* DRIVER INTERFACE */
// .m_axi_awid(),
// .m_axi_awaddr(s_axi_awaddr),
// .m_axi_awlen(s_axi_awlen),
// .m_axi_awsize(),
// .m_axi_awburst(),
// .m_axi_awlock(),
// .m_axi_awcache(),
// .m_axi_awprot(),
// .m_axi_awvalid(s_axi_awvalid),
// .m_axi_awready(s_axi_awready),

// .m_axi_wdata(s_axi_wdata),
// .m_axi_wstrb(s_axi_wstrb),
// .m_axi_wlast(s_axi_wlast),
// .m_axi_wvalid(s_axi_wvalid),
// .m_axi_wready(s_axi_wready),

// .m_axi_bready(s_axi_bready),
// .m_axi_bid(),
// .m_axi_bresp(),
// .m_axi_bvalid(s_axi_bvalid),

// .m_axi_arid(),
// .m_axi_araddr(s_axi_araddr),
// .m_axi_arlen(s_axi_arlen),
// .m_axi_arsize(),
// .m_axi_arburst(),
// .m_axi_arlock(),
// .m_axi_arcache(),
// .m_axi_arprot(),
// .m_axi_arvalid(s_axi_arvalid),
// .m_axi_arready(s_axi_arready),

// .m_axi_rready(s_axi_rready),
// .m_axi_rid(),
// .m_axi_rdata(s_axi_rdata),
// .m_axi_rresp(),
// .m_axi_rlast(s_axi_rlast),
// .m_axi_rvalid(s_axi_rvalid),

// .addr_offset(tx_ddr_offset_addr)
// );



// blk_mem_gen_0 blk_mem_gen
// (
// .rsta_busy    (rsta_busy),
// .rstb_busy    (rstb_busy),
// .s_aclk       (ap_clk),
// .s_aresetn    (ap_rst_n_reg),
// .s_axi_awid   (),
// .s_axi_awaddr (s_axi_awaddr),
// .s_axi_awlen  (s_axi_awlen),
// .s_axi_awsize (),
// .s_axi_awburst(),
// .s_axi_awvalid(s_axi_awvalid),
// .s_axi_awready(s_axi_awready),
// .s_axi_wdata  (s_axi_wdata),
// .s_axi_wstrb  (s_axi_wstrb),
// .s_axi_wlast  (s_axi_wlast),
// .s_axi_wvalid (s_axi_wvalid),
// .s_axi_wready (s_axi_wready),
// .s_axi_bid    (),
// .s_axi_bresp  (),
// .s_axi_bvalid (s_axi_bvalid),
// .s_axi_bready (s_axi_bready),
// .s_axi_arid   (),
// .s_axi_araddr (s_axi_araddr),
// .s_axi_arlen  (s_axi_arlen),
// .s_axi_arsize (),
// .s_axi_arburst(),
// .s_axi_arvalid(s_axi_arvalid),
// .s_axi_arready(s_axi_arready),
// .s_axi_rid    (),
// .s_axi_rdata  (s_axi_rdata),
// .s_axi_rresp  (),
// .s_axi_rlast  (s_axi_rlast),
// .s_axi_rvalid (s_axi_rvalid),
// .s_axi_rready (s_axi_rready)
//   );


mem_single_inf #(
  `ifdef USE_DDR
      .ENABLE(1),
  `else
      .ENABLE(0),
  `endif
    .UNALIGNED(0 < NUM_TCP_CHANNELS)
    // .UNALIGNED(0)
) mem_inf_inst1 (
.user_clk(ap_clk),
.user_aresetn(ap_rst_n_2_reg),
.mem_clk(ap_clk),
.mem_aresetn(ap_rst_n_reg),

/* USER INTERFACE */
//memory read commands
.s_axis_mem_read_cmd(axis_tcp_mem_read_cmd[1]),
//memory read status
.m_axis_mem_read_status(axis_tcp_mem_read_status[1]),
//memory read stream
.m_axis_mem_read_data(axis_tcp_mem_read_data[1]),

//memory write commands
.s_axis_mem_write_cmd(axis_tcp_mem_write_cmd[1]),
//memory rite status
.m_axis_mem_write_status(axis_tcp_mem_write_status[1]),
//memory write stream
.s_axis_mem_write_data(axis_tcp_mem_write_data[1]),


/* DRIVER INTERFACE */
.m_axi_awid(),
.m_axi_awaddr(m01_axi_awaddr),
.m_axi_awlen(m01_axi_awlen),
.m_axi_awsize(),
.m_axi_awburst(),
.m_axi_awlock(),
.m_axi_awcache(),
.m_axi_awprot(),
.m_axi_awvalid(m01_axi_awvalid),
.m_axi_awready(m01_axi_awready),

.m_axi_wdata(m01_axi_wdata),
.m_axi_wstrb(m01_axi_wstrb),
.m_axi_wlast(m01_axi_wlast),
.m_axi_wvalid(m01_axi_wvalid),
.m_axi_wready(m01_axi_wready),

.m_axi_bready(m01_axi_bready),
.m_axi_bid(),
.m_axi_bresp(),
.m_axi_bvalid(m01_axi_bvalid),

.m_axi_arid(),
.m_axi_araddr(m01_axi_araddr),
.m_axi_arlen(m01_axi_arlen),
.m_axi_arsize(),
.m_axi_arburst(),
.m_axi_arlock(),
.m_axi_arcache(),
.m_axi_arprot(),
.m_axi_arvalid(m01_axi_arvalid),
.m_axi_arready(m01_axi_arready),

.m_axi_rready(m01_axi_rready),
.m_axi_rid(),
.m_axi_rdata(m01_axi_rdata),
.m_axi_rresp(),
.m_axi_rlast(m01_axi_rlast),
.m_axi_rvalid(m01_axi_rvalid),

.addr_offset(rx_ddr_offset_addr)
);


// NETWORK STACK
network_top #(
  .C_S_AXI_ADDR_WIDTH ( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_S_AXI_DATA_WIDTH ( C_S_AXI_CONTROL_DATA_WIDTH )
)inst_network_top (
  .aclk(ap_clk),
  .aresetn(ap_rst_n_2_reg),
  // .sys_reset(1'b0),  
  
  .axis_net_rx_data_aclk(axis_net_rx_data_aclk),
  .axis_net_tx_data_aclk(axis_net_tx_data_aclk),
  
  .s_axil(s_axil),

  .m_axis_read_cmd(axis_tcp_mem_read_cmd),
  .m_axis_write_cmd(axis_tcp_mem_write_cmd),
  .s_axis_read_sts(axis_tcp_mem_read_status),
  .s_axis_write_sts(axis_tcp_mem_write_status),
  .s_axis_read_data(axis_tcp_mem_read_data),
  .m_axis_write_data(axis_tcp_mem_write_data),


  .s_axis_listen_port(s_axis_tcp_listen_port),
  .m_axis_listen_port_status(m_axis_tcp_port_status),
  .s_axis_open_connection(s_axis_tcp_open_connection),
  .m_axis_open_status(m_axis_tcp_open_status),
  .s_axis_close_connection(s_axis_tcp_close_connection),
  .m_axis_notifications(m_axis_tcp_notification),
  .s_axis_read_package(s_axis_tcp_read_pkg),
  .m_axis_rx_metadata(m_axis_tcp_rx_meta),
  .m_axis_rx_data(m_axis_tcp_rx_data),
  .s_axis_tx_metadata(s_axis_tcp_tx_meta),
  .s_axis_tx_data(s_axis_tcp_tx_data),
  .m_axis_tx_status(m_axis_tcp_tx_status),


  .m_axis_udp_rx_metadata(m_axis_udp_rx_metadata),
  .m_axis_udp_rx_data(m_axis_udp_rx_data),
  .s_axis_udp_tx_metadata(s_axis_udp_tx_metadata),
  .s_axis_udp_tx_data(s_axis_udp_tx_data),
  
  .tx_ddr_offset_addr(tx_ddr_offset_addr),
  .rx_ddr_offset_addr(rx_ddr_offset_addr)
);


///////////////////////////////////////////////////////////////////////////////
// Assign
///////////////////////////////////////////////////////////////////////////////

// Control
assign  s_axil.awvalid                = s_axi_control_awvalid;
assign  s_axil.awaddr                 = s_axi_control_awaddr;
assign  s_axil.arvalid                = s_axi_control_arvalid;
assign  s_axil.araddr                 = s_axi_control_araddr;
assign  s_axil.wvalid                 = s_axi_control_wvalid;
assign  s_axil.wdata                  = s_axi_control_wdata;
assign  s_axil.wstrb                  = s_axi_control_wstrb;
assign  s_axil.rready                 = s_axi_control_rready;
assign  s_axil.bready                 = s_axi_control_bready;

assign  s_axi_control_awready         = s_axil.awready;
assign  s_axi_control_arready         = s_axil.arready;
assign  s_axi_control_wready          = s_axil.wready;
assign  s_axi_control_rvalid          = s_axil.rvalid;
assign  s_axi_control_rdata           = s_axil.rdata;
assign  s_axi_control_rresp           = s_axil.rresp;
assign  s_axi_control_bvalid          = s_axil.bvalid;
assign  s_axi_control_bresp           = s_axil.bresp;

// Network streams

//Cmac interface

assign axis_net_tx_tvalid = axis_net_tx_data_aclk.valid;
assign axis_net_tx_tdata = axis_net_tx_data_aclk.data;
assign axis_net_tx_tkeep = axis_net_tx_data_aclk.keep;
assign axis_net_tx_tlast = axis_net_tx_data_aclk.last;

assign axis_net_tx_data_aclk.ready = axis_net_tx_tready;

assign axis_net_rx_data_aclk.valid = axis_net_rx_tvalid;
assign axis_net_rx_data_aclk.data = axis_net_rx_tdata;
assign axis_net_rx_data_aclk.keep = axis_net_rx_tkeep;
assign axis_net_rx_data_aclk.last = axis_net_rx_tlast;

assign axis_net_rx_tready = axis_net_rx_data_aclk.ready;

// //UDP
// // Data rx
//assign m_axis_udp_rx_tvalid           = m_axis_udp_rx_data.valid;
//assign m_axis_udp_rx_tdata            = m_axis_udp_rx_data.data;
//assign m_axis_udp_rx_tkeep            = m_axis_udp_rx_data.keep;
//assign m_axis_udp_rx_tlast            = m_axis_udp_rx_data.last;

//assign m_axis_udp_rx_data.ready       = m_axis_udp_rx_tready;

assign m_axis_udp_rx_data.ready       = 1'b1;

// Data tx
//assign s_axis_udp_tx_data.valid       = s_axis_udp_tx_tvalid;
//assign s_axis_udp_tx_data.data        = s_axis_udp_tx_tdata;
//assign s_axis_udp_tx_data.keep        = s_axis_udp_tx_tkeep;
//assign s_axis_udp_tx_data.last        = s_axis_udp_tx_tlast;

//assign s_axis_udp_tx_tready           = s_axis_udp_tx_data.ready;

assign s_axis_udp_tx_data.valid = 1'b0; 

// Meta rx
//assign m_axis_udp_rx_meta_tvalid      = m_axis_udp_rx_metadata.valid;
//assign m_axis_udp_rx_meta_tdata       = m_axis_udp_rx_metadata.data;
//assign m_axis_udp_rx_meta_tkeep       = '1;
//assign m_axis_udp_rx_meta_tlast       = 1;

//assign m_axis_udp_rx_metadata.ready   = m_axis_udp_rx_meta_tready;

assign m_axis_udp_rx_metadata.ready = 1'b1;

// Meta tx
//assign s_axis_udp_tx_metadata.valid   = s_axis_udp_tx_meta_tvalid;
//assign s_axis_udp_tx_metadata.data    = s_axis_udp_tx_meta_tdata;

//assign s_axis_udp_tx_meta_tready      = s_axis_udp_tx_metadata.ready;

assign s_axis_udp_tx_metadata.valid   = 1'b0;

//TCP/IP

//listen port
assign s_axis_tcp_listen_port.valid   = s_axis_tcp_listen_port_tvalid;
assign s_axis_tcp_listen_port.data    = s_axis_tcp_listen_port_tdata;

assign s_axis_tcp_listen_port_tready  = s_axis_tcp_listen_port.ready;

//listen port status
assign m_axis_tcp_port_status_tvalid  = m_axis_tcp_port_status.valid;
assign m_axis_tcp_port_status_tdata   = m_axis_tcp_port_status.data;
assign m_axis_tcp_port_status_tlast   = 1;

assign m_axis_tcp_port_status.ready   = m_axis_tcp_port_status_tready;

// //open connection
// assign s_axis_tcp_open_connection.valid   = s_axis_tcp_open_connection_tvalid;
// assign s_axis_tcp_open_connection.data    = s_axis_tcp_open_connection_tdata;

// assign s_axis_tcp_open_connection_tready  = s_axis_tcp_open_connection.ready;

// //open status
// assign m_axis_tcp_open_status_tvalid      = m_axis_tcp_open_status.valid;
// assign m_axis_tcp_open_status_tdata       = m_axis_tcp_open_status.data;
// assign m_axis_tcp_open_status_tkeep       = '1;
// assign m_axis_tcp_open_status_tlast       = 1;

// assign m_axis_tcp_open_status.ready   = m_axis_tcp_open_status_tready;

//close connection
//assign s_axis_tcp_close_connection.valid   = s_axis_tcp_close_connection_tvalid;
//assign s_axis_tcp_close_connection.data    = s_axis_tcp_close_connection_tdata;

//assign s_axis_tcp_close_connection_tready      = s_axis_tcp_close_connection.ready;

assign s_axis_tcp_close_connection.valid =  1'b0;

//notification
assign m_axis_tcp_notification_tvalid      = m_axis_tcp_notification.valid;
assign m_axis_tcp_notification_tdata       = m_axis_tcp_notification.data;
assign m_axis_tcp_notification_tkeep       = '1;
assign m_axis_tcp_notification_tlast       = 1;

assign m_axis_tcp_notification.ready   = m_axis_tcp_notification_tready;

//read pkg
assign s_axis_tcp_read_pkg.valid   = s_axis_tcp_read_pkg_tvalid;
assign s_axis_tcp_read_pkg.data    = s_axis_tcp_read_pkg_tdata;

assign s_axis_tcp_read_pkg_tready      = s_axis_tcp_read_pkg.ready;

//rx meta
assign m_axis_tcp_rx_meta_tvalid      = m_axis_tcp_rx_meta.valid;
assign m_axis_tcp_rx_meta_tdata       = m_axis_tcp_rx_meta.data;
assign m_axis_tcp_rx_meta_tkeep       = '1;
assign m_axis_tcp_rx_meta_tlast       = 1;

assign m_axis_tcp_rx_meta.ready   = m_axis_tcp_rx_meta_tready;

//rx data
assign m_axis_tcp_rx_data_tvalid           = m_axis_tcp_rx_data.valid;
assign m_axis_tcp_rx_data_tdata            = m_axis_tcp_rx_data.data;
assign m_axis_tcp_rx_data_tkeep            = m_axis_tcp_rx_data.keep;
assign m_axis_tcp_rx_data_tlast            = m_axis_tcp_rx_data.last;

assign m_axis_tcp_rx_data.ready       = m_axis_tcp_rx_data_tready;

// //tx meta
// assign s_axis_tcp_tx_meta.valid   = s_axis_tcp_tx_meta_tvalid;
// assign s_axis_tcp_tx_meta.data    = s_axis_tcp_tx_meta_tdata;

// assign s_axis_tcp_tx_meta_tready      = s_axis_tcp_tx_meta.ready;

//tx data
assign s_axis_tcp_tx_data.valid       = s_axis_tcp_tx_data_tvalid;
assign s_axis_tcp_tx_data.data        = s_axis_tcp_tx_data_tdata;
assign s_axis_tcp_tx_data.keep        = s_axis_tcp_tx_data_tkeep;
assign s_axis_tcp_tx_data.last        = s_axis_tcp_tx_data_tlast;

assign s_axis_tcp_tx_data_tready           = s_axis_tcp_tx_data.ready;

// //tx status
// assign m_axis_tcp_tx_status_tvalid      = m_axis_tcp_tx_status.valid;
// assign m_axis_tcp_tx_status_tdata       = m_axis_tcp_tx_status.data;
// assign m_axis_tcp_tx_status_tkeep       = '1;
// assign m_axis_tcp_tx_status_tlast       = 1;

// assign m_axis_tcp_tx_status.ready   = m_axis_tcp_tx_status_tready;




endmodule
`default_nettype wire
