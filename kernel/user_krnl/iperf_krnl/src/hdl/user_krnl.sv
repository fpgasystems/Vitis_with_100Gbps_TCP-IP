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

//////////////////////////////////////////////////////////////////////////////// 
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps

`include "network_types.svh"
`include "network_intf.svh"

// Top level of the kernel. Do not modify module name, parameters or ports.
module user_krnl #(
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH                = 12 ,
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH                = 32 ,
  parameter integer C_S_AXIS_UDP_RX_TDATA_WIDTH               = 512,
  parameter integer C_M_AXIS_UDP_TX_TDATA_WIDTH               = 512,
  parameter integer C_S_AXIS_UDP_RX_META_TDATA_WIDTH          = 256,
  parameter integer C_M_AXIS_UDP_TX_META_TDATA_WIDTH          = 256,
  parameter integer C_M_AXIS_TCP_LISTEN_PORT_TDATA_WIDTH      = 16 ,
  parameter integer C_S_AXIS_TCP_PORT_STATUS_TDATA_WIDTH      = 8  ,
  parameter integer C_M_AXIS_TCP_OPEN_CONNECTION_TDATA_WIDTH  = 64 ,
  parameter integer C_S_AXIS_TCP_OPEN_STATUS_TDATA_WIDTH      = 32 ,
  parameter integer C_M_AXIS_TCP_CLOSE_CONNECTION_TDATA_WIDTH = 16 ,
  parameter integer C_S_AXIS_TCP_NOTIFICATION_TDATA_WIDTH     = 128,
  parameter integer C_M_AXIS_TCP_READ_PKG_TDATA_WIDTH         = 32 ,
  parameter integer C_S_AXIS_TCP_RX_META_TDATA_WIDTH          = 16 ,
  parameter integer C_S_AXIS_TCP_RX_DATA_TDATA_WIDTH          = 512,
  parameter integer C_M_AXIS_TCP_TX_META_TDATA_WIDTH          = 32 ,
  parameter integer C_M_AXIS_TCP_TX_DATA_TDATA_WIDTH          = 512,
  parameter integer C_S_AXIS_TCP_TX_STATUS_TDATA_WIDTH        = 64 
)
(
  // System Signals
  input  wire                                                   ap_clk                            ,
  input  wire                                                   ap_rst_n                          ,
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
  // AXI4-Stream (slave) interface s_axis_udp_rx
  input  wire                                                   s_axis_udp_rx_tvalid              ,
  output wire                                                   s_axis_udp_rx_tready              ,
  input  wire [C_S_AXIS_UDP_RX_TDATA_WIDTH-1:0]                 s_axis_udp_rx_tdata               ,
  input  wire [C_S_AXIS_UDP_RX_TDATA_WIDTH/8-1:0]               s_axis_udp_rx_tkeep               ,
  input  wire                                                   s_axis_udp_rx_tlast               ,
  // AXI4-Stream (master) interface m_axis_udp_tx
  output wire                                                   m_axis_udp_tx_tvalid              ,
  input  wire                                                   m_axis_udp_tx_tready              ,
  output wire [C_M_AXIS_UDP_TX_TDATA_WIDTH-1:0]                 m_axis_udp_tx_tdata               ,
  output wire [C_M_AXIS_UDP_TX_TDATA_WIDTH/8-1:0]               m_axis_udp_tx_tkeep               ,
  output wire                                                   m_axis_udp_tx_tlast               ,
  // AXI4-Stream (slave) interface s_axis_udp_rx_meta
  input  wire                                                   s_axis_udp_rx_meta_tvalid         ,
  output wire                                                   s_axis_udp_rx_meta_tready         ,
  input  wire [C_S_AXIS_UDP_RX_META_TDATA_WIDTH-1:0]            s_axis_udp_rx_meta_tdata          ,
  input  wire [C_S_AXIS_UDP_RX_META_TDATA_WIDTH/8-1:0]          s_axis_udp_rx_meta_tkeep          ,
  input  wire                                                   s_axis_udp_rx_meta_tlast          ,
  // AXI4-Stream (master) interface m_axis_udp_tx_meta
  output wire                                                   m_axis_udp_tx_meta_tvalid         ,
  input  wire                                                   m_axis_udp_tx_meta_tready         ,
  output wire [C_M_AXIS_UDP_TX_META_TDATA_WIDTH-1:0]            m_axis_udp_tx_meta_tdata          ,
  output wire [C_M_AXIS_UDP_TX_META_TDATA_WIDTH/8-1:0]          m_axis_udp_tx_meta_tkeep          ,
  output wire                                                   m_axis_udp_tx_meta_tlast          ,
  // AXI4-Stream (master) interface m_axis_tcp_listen_port
  output wire                                                   m_axis_tcp_listen_port_tvalid     ,
  input  wire                                                   m_axis_tcp_listen_port_tready     ,
  output wire [C_M_AXIS_TCP_LISTEN_PORT_TDATA_WIDTH-1:0]        m_axis_tcp_listen_port_tdata      ,
  output wire [C_M_AXIS_TCP_LISTEN_PORT_TDATA_WIDTH/8-1:0]      m_axis_tcp_listen_port_tkeep      ,
  output wire                                                   m_axis_tcp_listen_port_tlast      ,
  // AXI4-Stream (slave) interface s_axis_tcp_port_status
  input  wire                                                   s_axis_tcp_port_status_tvalid     ,
  output wire                                                   s_axis_tcp_port_status_tready     ,
  input  wire [C_S_AXIS_TCP_PORT_STATUS_TDATA_WIDTH-1:0]        s_axis_tcp_port_status_tdata      ,
  input  wire                                                   s_axis_tcp_port_status_tlast      ,
  // AXI4-Stream (master) interface m_axis_tcp_open_connection
  output wire                                                   m_axis_tcp_open_connection_tvalid ,
  input  wire                                                   m_axis_tcp_open_connection_tready ,
  output wire [C_M_AXIS_TCP_OPEN_CONNECTION_TDATA_WIDTH-1:0]    m_axis_tcp_open_connection_tdata  ,
  output wire [C_M_AXIS_TCP_OPEN_CONNECTION_TDATA_WIDTH/8-1:0]  m_axis_tcp_open_connection_tkeep  ,
  output wire                                                   m_axis_tcp_open_connection_tlast  ,
  // AXI4-Stream (slave) interface s_axis_tcp_open_status
  input  wire                                                   s_axis_tcp_open_status_tvalid     ,
  output wire                                                   s_axis_tcp_open_status_tready     ,
  input  wire [C_S_AXIS_TCP_OPEN_STATUS_TDATA_WIDTH-1:0]        s_axis_tcp_open_status_tdata      ,
  input  wire [C_S_AXIS_TCP_OPEN_STATUS_TDATA_WIDTH/8-1:0]      s_axis_tcp_open_status_tkeep      ,
  input  wire                                                   s_axis_tcp_open_status_tlast      ,
  // AXI4-Stream (master) interface m_axis_tcp_close_connection
  output wire                                                   m_axis_tcp_close_connection_tvalid,
  input  wire                                                   m_axis_tcp_close_connection_tready,
  output wire [C_M_AXIS_TCP_CLOSE_CONNECTION_TDATA_WIDTH-1:0]   m_axis_tcp_close_connection_tdata ,
  output wire [C_M_AXIS_TCP_CLOSE_CONNECTION_TDATA_WIDTH/8-1:0] m_axis_tcp_close_connection_tkeep ,
  output wire                                                   m_axis_tcp_close_connection_tlast ,
  // AXI4-Stream (slave) interface s_axis_tcp_notification
  input  wire                                                   s_axis_tcp_notification_tvalid    ,
  output wire                                                   s_axis_tcp_notification_tready    ,
  input  wire [C_S_AXIS_TCP_NOTIFICATION_TDATA_WIDTH-1:0]       s_axis_tcp_notification_tdata     ,
  input  wire [C_S_AXIS_TCP_NOTIFICATION_TDATA_WIDTH/8-1:0]     s_axis_tcp_notification_tkeep     ,
  input  wire                                                   s_axis_tcp_notification_tlast     ,
  // AXI4-Stream (master) interface m_axis_tcp_read_pkg
  output wire                                                   m_axis_tcp_read_pkg_tvalid        ,
  input  wire                                                   m_axis_tcp_read_pkg_tready        ,
  output wire [C_M_AXIS_TCP_READ_PKG_TDATA_WIDTH-1:0]           m_axis_tcp_read_pkg_tdata         ,
  output wire [C_M_AXIS_TCP_READ_PKG_TDATA_WIDTH/8-1:0]         m_axis_tcp_read_pkg_tkeep         ,
  output wire                                                   m_axis_tcp_read_pkg_tlast         ,
  // AXI4-Stream (slave) interface s_axis_tcp_rx_meta
  input  wire                                                   s_axis_tcp_rx_meta_tvalid         ,
  output wire                                                   s_axis_tcp_rx_meta_tready         ,
  input  wire [C_S_AXIS_TCP_RX_META_TDATA_WIDTH-1:0]            s_axis_tcp_rx_meta_tdata          ,
  input  wire [C_S_AXIS_TCP_RX_META_TDATA_WIDTH/8-1:0]          s_axis_tcp_rx_meta_tkeep          ,
  input  wire                                                   s_axis_tcp_rx_meta_tlast          ,
  // AXI4-Stream (slave) interface s_axis_tcp_rx_data
  input  wire                                                   s_axis_tcp_rx_data_tvalid         ,
  output wire                                                   s_axis_tcp_rx_data_tready         ,
  input  wire [C_S_AXIS_TCP_RX_DATA_TDATA_WIDTH-1:0]            s_axis_tcp_rx_data_tdata          ,
  input  wire [C_S_AXIS_TCP_RX_DATA_TDATA_WIDTH/8-1:0]          s_axis_tcp_rx_data_tkeep          ,
  input  wire                                                   s_axis_tcp_rx_data_tlast          ,
  // AXI4-Stream (master) interface m_axis_tcp_tx_meta
  output wire                                                   m_axis_tcp_tx_meta_tvalid         ,
  input  wire                                                   m_axis_tcp_tx_meta_tready         ,
  output wire [C_M_AXIS_TCP_TX_META_TDATA_WIDTH-1:0]            m_axis_tcp_tx_meta_tdata          ,
  output wire [C_M_AXIS_TCP_TX_META_TDATA_WIDTH/8-1:0]          m_axis_tcp_tx_meta_tkeep          ,
  output wire                                                   m_axis_tcp_tx_meta_tlast          ,
  // AXI4-Stream (master) interface m_axis_tcp_tx_data
  output wire                                                   m_axis_tcp_tx_data_tvalid         ,
  input  wire                                                   m_axis_tcp_tx_data_tready         ,
  output wire [C_M_AXIS_TCP_TX_DATA_TDATA_WIDTH-1:0]            m_axis_tcp_tx_data_tdata          ,
  output wire [C_M_AXIS_TCP_TX_DATA_TDATA_WIDTH/8-1:0]          m_axis_tcp_tx_data_tkeep          ,
  output wire                                                   m_axis_tcp_tx_data_tlast          ,
  // AXI4-Stream (slave) interface s_axis_tcp_tx_status
  input  wire                                                   s_axis_tcp_tx_status_tvalid       ,
  output wire                                                   s_axis_tcp_tx_status_tready       ,
  input  wire [C_S_AXIS_TCP_TX_STATUS_TDATA_WIDTH-1:0]          s_axis_tcp_tx_status_tdata        ,
  input  wire [C_S_AXIS_TCP_TX_STATUS_TDATA_WIDTH/8-1:0]        s_axis_tcp_tx_status_tkeep        ,
  input  wire                                                   s_axis_tcp_tx_status_tlast        ,
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

// Register and invert reset signal.
always @(posedge ap_clk) begin
  areset <= ~ap_rst_n;
end

assign interrupt = 1'b0;
///////////////////////////////////////////////////////////////////////////////
// User stack
///////////////////////////////////////////////////////////////////////////////

assign s_axis_udp_rx_tready = 1'b1;
assign m_axis_udp_tx_tvalid = 1'b0;
assign s_axis_udp_rx_meta_tready = 1'b1;
assign m_axis_udp_tx_meta_tvalid = 1'b0;

assign m_axis_tcp_listen_port_tkeep = '1;
assign m_axis_tcp_listen_port_tlast = 1;

assign m_axis_tcp_open_connection_tkeep = '1;
assign m_axis_tcp_open_connection_tlast = 1;

assign m_axis_tcp_close_connection_tkeep = '1;
assign m_axis_tcp_close_connection_tlast = 1;

assign m_axis_tcp_read_pkg_tkeep = '1;
assign m_axis_tcp_read_pkg_tlast = 1;

assign m_axis_tcp_tx_meta_tkeep = '1;
assign m_axis_tcp_tx_meta_tlast = 1;

// // assign m_axis_tcp_listen_port_tvalid = 1'b0;
// // assign s_axis_tcp_port_status_tready = 1'b1;
// // assign m_axis_tcp_open_connection_tvalid = 1'b0;
// // assign s_axis_tcp_open_status_tready = 1'b1;
// // assign m_axis_tcp_close_connection_tvalid = 1'b0;
// // assign s_axis_tcp_notification_tready = 1'b1;
// // assign m_axis_tcp_read_pkg_tvalid = 1'b0;
// // assign s_axis_tcp_rx_meta_tready = 1'b1;
// // assign s_axis_tcp_rx_data_tready = 1'b1;
// // assign m_axis_tcp_tx_meta_tvalid = 1'b0;
// // assign m_axis_tcp_tx_data_tvalid = 1'b0;
// // assign s_axis_tcp_tx_status_tready = 1'b1;

iperf_role #( 
  .C_S_AXI_CONTROL_DATA_WIDTH(C_S_AXI_CONTROL_DATA_WIDTH),  
  .C_S_AXI_CONTROL_ADDR_WIDTH(C_S_AXI_CONTROL_ADDR_WIDTH)
)user_role (
    .ap_clk(ap_clk),
    .ap_rst_n(~areset),

    /* CONTROL INTERFACE */
    // LITE interface
    .s_axi_control_awvalid             (s_axi_control_awvalid),
    .s_axi_control_awready             (s_axi_control_awready),
    .s_axi_control_awaddr              (s_axi_control_awaddr),
    .s_axi_control_wvalid              (s_axi_control_wvalid),
    .s_axi_control_wready              (s_axi_control_wready),
    .s_axi_control_wdata               (s_axi_control_wdata),
    .s_axi_control_wstrb               (s_axi_control_wstrb),
    .s_axi_control_arvalid             (s_axi_control_arvalid),
    .s_axi_control_arready             (s_axi_control_arready),
    .s_axi_control_araddr              (s_axi_control_araddr),
    .s_axi_control_rvalid              (s_axi_control_rvalid),
    .s_axi_control_rready              (s_axi_control_rready),
    .s_axi_control_rdata               (s_axi_control_rdata),
    .s_axi_control_rresp               (s_axi_control_rresp),
    .s_axi_control_bvalid              (s_axi_control_bvalid),
    .s_axi_control_bready              (s_axi_control_bready),
    .s_axi_control_bresp               (s_axi_control_bresp),


    .m_axis_tcp_listen_port_tvalid     (m_axis_tcp_listen_port_tvalid),
    .m_axis_tcp_listen_port_tready     (m_axis_tcp_listen_port_tready),
    .m_axis_tcp_listen_port_tdata      (m_axis_tcp_listen_port_tdata),
    .s_axis_tcp_port_status_tvalid     (s_axis_tcp_port_status_tvalid),
    .s_axis_tcp_port_status_tready     (s_axis_tcp_port_status_tready),
    .s_axis_tcp_port_status_tdata      (s_axis_tcp_port_status_tdata),
    .m_axis_tcp_open_connection_tvalid (m_axis_tcp_open_connection_tvalid),
    .m_axis_tcp_open_connection_tready (m_axis_tcp_open_connection_tready),
    .m_axis_tcp_open_connection_tdata  (m_axis_tcp_open_connection_tdata),
    .s_axis_tcp_open_status_tvalid     (s_axis_tcp_open_status_tvalid),
    .s_axis_tcp_open_status_tready     (s_axis_tcp_open_status_tready),
    .s_axis_tcp_open_status_tdata      (s_axis_tcp_open_status_tdata),
    .m_axis_tcp_close_connection_tvalid(m_axis_tcp_close_connection_tvalid),
    .m_axis_tcp_close_connection_tready(m_axis_tcp_close_connection_tready),
    .m_axis_tcp_close_connection_tdata (m_axis_tcp_close_connection_tdata),
    .s_axis_tcp_notification_tvalid    (s_axis_tcp_notification_tvalid),
    .s_axis_tcp_notification_tready    (s_axis_tcp_notification_tready),
    .s_axis_tcp_notification_tdata     (s_axis_tcp_notification_tdata),
    .m_axis_tcp_read_pkg_tvalid        (m_axis_tcp_read_pkg_tvalid),
    .m_axis_tcp_read_pkg_tready        (m_axis_tcp_read_pkg_tready),
    .m_axis_tcp_read_pkg_tdata         (m_axis_tcp_read_pkg_tdata),
    .s_axis_tcp_rx_meta_tvalid         (s_axis_tcp_rx_meta_tvalid),
    .s_axis_tcp_rx_meta_tready         (s_axis_tcp_rx_meta_tready),
    .s_axis_tcp_rx_meta_tdata          (s_axis_tcp_rx_meta_tdata),
    .s_axis_tcp_rx_data_tvalid         (s_axis_tcp_rx_data_tvalid),
    .s_axis_tcp_rx_data_tready         (s_axis_tcp_rx_data_tready),
    .s_axis_tcp_rx_data_tdata          (s_axis_tcp_rx_data_tdata),
    .s_axis_tcp_rx_data_tkeep          (s_axis_tcp_rx_data_tkeep),
    .s_axis_tcp_rx_data_tlast          (s_axis_tcp_rx_data_tlast),
    .m_axis_tcp_tx_meta_tvalid         (m_axis_tcp_tx_meta_tvalid),
    .m_axis_tcp_tx_meta_tready         (m_axis_tcp_tx_meta_tready),
    .m_axis_tcp_tx_meta_tdata          (m_axis_tcp_tx_meta_tdata),
    .m_axis_tcp_tx_data_tvalid         (m_axis_tcp_tx_data_tvalid),
    .m_axis_tcp_tx_data_tready         (m_axis_tcp_tx_data_tready),
    .m_axis_tcp_tx_data_tdata          (m_axis_tcp_tx_data_tdata),
    .m_axis_tcp_tx_data_tkeep          (m_axis_tcp_tx_data_tkeep),
    .m_axis_tcp_tx_data_tlast          (m_axis_tcp_tx_data_tlast),
    .s_axis_tcp_tx_status_tvalid       (s_axis_tcp_tx_status_tvalid),
    .s_axis_tcp_tx_status_tready       (s_axis_tcp_tx_status_tready),
    .s_axis_tcp_tx_status_tdata        (s_axis_tcp_tx_status_tdata)

);




endmodule
`default_nettype wire
