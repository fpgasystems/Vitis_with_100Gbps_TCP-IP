/*
 * Copyright (c) 2019, Systems Group, ETH Zurich
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 * may be used to endorse or promote products derived from this software
 * without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
 * THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
`timescale 1ns / 1ps
`default_nettype none

`include "network_types.svh"
`include "network_intf.svh"

module scatter_role 
  #( 
  parameter integer  C_S_AXI_CONTROL_DATA_WIDTH = 32,
  parameter integer  C_S_AXI_CONTROL_ADDR_WIDTH = 12,
  // parameter integer  C_M_AXI_GMEM_ID_WIDTH = 1,
  parameter integer  C_M_AXI_GMEM_ADDR_WIDTH = 64,
  parameter integer  C_M_AXI_GMEM_DATA_WIDTH = 512
)
(
    input wire      ap_clk,
    input wire      ap_rst_n,


    // AXI4-Lite slave interface
    input  wire                                    s_axi_control_awvalid,
    output wire                                    s_axi_control_awready,
    input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_awaddr ,
    input  wire                                    s_axi_control_wvalid ,
    output wire                                    s_axi_control_wready ,
    input  wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_wdata  ,
    input  wire [C_S_AXI_CONTROL_DATA_WIDTH/8-1:0] s_axi_control_wstrb  ,
    input  wire                                    s_axi_control_arvalid,
    output wire                                    s_axi_control_arready,
    input  wire [C_S_AXI_CONTROL_ADDR_WIDTH-1:0]   s_axi_control_araddr ,
    output wire                                    s_axi_control_rvalid ,
    input  wire                                    s_axi_control_rready ,
    output wire [C_S_AXI_CONTROL_DATA_WIDTH-1:0]   s_axi_control_rdata  ,
    output wire [2-1:0]                            s_axi_control_rresp  ,
    output wire                                    s_axi_control_bvalid ,
    input  wire                                    s_axi_control_bready ,
    output wire [2-1:0]                            s_axi_control_bresp  ,

    /* NETWORK  - TCP/IP INTERFACE */
    //Network TCP/IP
    output  wire                                   m_axis_tcp_listen_port_tvalid ,
    input wire                                     m_axis_tcp_listen_port_tready ,
    output  wire [16-1:0]                          m_axis_tcp_listen_port_tdata  ,

    input wire                                     s_axis_tcp_port_status_tvalid ,
    output  wire                                   s_axis_tcp_port_status_tready ,
    input wire [8-1:0]                             s_axis_tcp_port_status_tdata  ,

    output  wire                                   m_axis_tcp_open_connection_tvalid ,
    input wire                                     m_axis_tcp_open_connection_tready ,
    output  wire [48-1:0]                          m_axis_tcp_open_connection_tdata  ,

    input wire                                     s_axis_tcp_open_status_tvalid ,
    output  wire                                   s_axis_tcp_open_status_tready ,
    input wire [128-1:0]                            s_axis_tcp_open_status_tdata  ,

    output  wire                                   m_axis_tcp_close_connection_tvalid ,
    input wire                                     m_axis_tcp_close_connection_tready ,
    output  wire [16-1:0]                          m_axis_tcp_close_connection_tdata  ,

    input wire                                     s_axis_tcp_notification_tvalid ,
    output  wire                                   s_axis_tcp_notification_tready ,
    input wire [88-1:0]                            s_axis_tcp_notification_tdata  ,

    output  wire                                   m_axis_tcp_read_pkg_tvalid ,
    input wire                                     m_axis_tcp_read_pkg_tready ,
    output  wire [32-1:0]                          m_axis_tcp_read_pkg_tdata  ,

    input wire                                     s_axis_tcp_rx_meta_tvalid ,
    output  wire                                   s_axis_tcp_rx_meta_tready ,
    input wire [16-1:0]                            s_axis_tcp_rx_meta_tdata  ,

    input wire                                     s_axis_tcp_rx_data_tvalid ,
    output  wire                                   s_axis_tcp_rx_data_tready ,
    input wire [NETWORK_STACK_WIDTH-1:0]           s_axis_tcp_rx_data_tdata  ,
    input wire [NETWORK_STACK_WIDTH/8-1:0]         s_axis_tcp_rx_data_tkeep  ,
    input wire                                     s_axis_tcp_rx_data_tlast  ,

    output  wire                                   m_axis_tcp_tx_meta_tvalid ,
    input wire                                     m_axis_tcp_tx_meta_tready ,
    output  wire [32-1:0]                          m_axis_tcp_tx_meta_tdata  ,

    output  wire                                   m_axis_tcp_tx_data_tvalid ,
    input wire                                     m_axis_tcp_tx_data_tready ,
    output  wire [NETWORK_STACK_WIDTH-1:0]         m_axis_tcp_tx_data_tdata  ,
    output  wire [NETWORK_STACK_WIDTH/8-1:0]       m_axis_tcp_tx_data_tkeep  ,
    output  wire                                   m_axis_tcp_tx_data_tlast  ,

    input wire                                     s_axis_tcp_tx_status_tvalid ,
    output  wire                                   s_axis_tcp_tx_status_tready ,
    input wire [64-1:0]                            s_axis_tcp_tx_status_tdata  
    


);

wire ap_start, ap_done, ap_ready, ap_idle, interrupt;
wire [63:0] axi00_ptr0;
logic ap_start_pulse;
logic ap_start_r = 1'b0;
logic ap_idle_r = 1'b1;

logic       runExperiment;
logic       finishExperiment;

// create pulse when ap_start transitions to 1
always @(posedge ap_clk) begin
  begin
    ap_start_r <= ap_start;
  end
end

assign ap_start_pulse = ap_start & ~ap_start_r;
assign runExperiment = ap_start_pulse;

// ap_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse
// is asserted
always @(posedge ap_clk) begin
  if (~ap_rst_n) begin
    ap_idle_r <= 1'b1;
  end
  else begin
    ap_idle_r <= ap_done ? 1'b1 :
      ap_start_pulse ? 1'b0 : ap_idle;
  end
end

assign ap_idle = ap_idle_r;

// Done logic

assign ap_done = finishExperiment;

// Ready Logic (non-pipelined case)
assign ap_ready = ap_done;


/*
 * TCP/IP Benchmark
 */



logic[7:0] listenCounter;
logic[7:0] openReqCounter;
logic[7:0] closeReqCounter;
logic[7:0] successOpenCounter;
logic[7:0] openStatusCounter;
logic[63:0] scatter_execution_cycles;
logic[31:0] scatter_connections;
logic running;

wire [31:0] useConn, useIpAddr, pkgWordCount, basePort, usePort, expectedRespInKBPerCon, delayedCycles,baseIpAddress, expectedRespInKBTotal, clientPkgNum;

logic [15:0] UseIpAddrReg;
logic [15:0] useConnReg;
logic [15:0] regBasePort;
logic [15:0] pkgWordCountReg;
logic [31:0] baseIpAddressReg;
logic [15:0] usePortReg;
logic [15:0] expectedRespInKBPerConReg;
logic [31:0] expectedRespInKBTotalReg;
logic [31:0] delayedCyclesReg;
logic [31:0] clientPkgNumReg;

logic [31:0] regIpAddress [10:0];

reg[47:0] scatter_consumed_bytes;
reg[47:0] scatter_produced_bytes;
logic [47:0] expected_scatter_consumed_bytes;

reg [41:0] rdRqstByteCnt;
reg [31:0] rcvPktCnt;

reg [31:0] openConCycle; 



always @ (posedge ap_clk) begin
  if (~ap_rst_n) begin
    baseIpAddressReg <= '0;
    regBasePort <= '0;
    pkgWordCountReg <= '0;
    UseIpAddrReg <= '0;
    useConnReg <= '0;
    usePortReg <= '0;
    expectedRespInKBPerConReg <= '0;
    expectedRespInKBTotalReg <= '0;
    delayedCyclesReg <= '0;
    clientPkgNumReg <= '0;
  end
  else begin
    baseIpAddressReg <= baseIpAddress ;
    regBasePort <= basePort ;
    pkgWordCountReg <= pkgWordCount;
    UseIpAddrReg <= useIpAddr;
    useConnReg <= useConn ;
    usePortReg <= usePort;
    expectedRespInKBPerConReg <= expectedRespInKBPerCon;
    expectedRespInKBTotalReg <= expectedRespInKBTotal; //TODO: fix
    delayedCyclesReg <= delayedCycles;
    clientPkgNumReg <= clientPkgNum;
  end

  expected_scatter_consumed_bytes <= (expectedRespInKBTotalReg << 10);
  regIpAddress[0] <= baseIpAddressReg;
  regIpAddress[1] <= baseIpAddressReg+1;
  regIpAddress[2] <= baseIpAddressReg+2;
  regIpAddress[3] <= baseIpAddressReg+3;
  regIpAddress[4] <= baseIpAddressReg+4;
  regIpAddress[5] <= baseIpAddressReg+5;
  regIpAddress[6] <= baseIpAddressReg+6;
  regIpAddress[7] <= baseIpAddressReg+7;
  regIpAddress[8] <= baseIpAddressReg+8;
  regIpAddress[9] <= baseIpAddressReg+9;
  regIpAddress[10] <= baseIpAddressReg+10;

end

always @(posedge ap_clk) begin
   if (~ap_rst_n) begin
      running <= 1'b0;
      listenCounter <= '0;
      openReqCounter <= '0;
      closeReqCounter <= '0;
      successOpenCounter <= '0;
      scatter_connections <= '0;
      openStatusCounter <= '0;
      finishExperiment <= 1'b0;
      rdRqstByteCnt <= '0;
      rcvPktCnt <= '0;
      openConCycle <= '0;
   end
   else begin
      finishExperiment <= 1'b0;
      if (runExperiment) begin
         running <= 1'b1;
         scatter_execution_cycles <= '0;
         closeReqCounter <= '0;
         openReqCounter <= '0;
         successOpenCounter <= '0;
         openStatusCounter <= '0;
         rdRqstByteCnt <= '0;
         rcvPktCnt <= '0;
         openConCycle <= '0;
      end
      if (running) begin
        scatter_execution_cycles <= scatter_execution_cycles + 1;
      end
      if (running & successOpenCounter != useConnReg) begin
        openConCycle <= openConCycle + 1;
      end
      if (m_axis_tcp_listen_port_tvalid && m_axis_tcp_listen_port_tready) begin
        listenCounter <= listenCounter +1;
      end
      if (m_axis_tcp_close_connection_tvalid && m_axis_tcp_close_connection_tready) begin
        closeReqCounter <= closeReqCounter + 1;
      end

      // if ((rdRqstByteCnt == expected_scatter_consumed_bytes) & running & (expected_scatter_consumed_bytes!=0)) begin
      //   running <= 1'b0;
      //   finishExperiment <= 1'b1;
      // end

      if ((scatter_tx_pkg_counter == clientPkgNum /* *useConnReg */) & running & (clientPkgNum!=0)) begin
        running <= 1'b0;
        finishExperiment <= 1'b1;
      end

      // if (running & (scatter_execution_cycles == 250000000) ) begin
      //   running <= 1'b0;
      //   finishExperiment <= 1'b1;
      // end
      
      if (m_axis_tcp_open_connection_tvalid && m_axis_tcp_open_connection_tready) begin
        openReqCounter <= openReqCounter + 1;
      end
      if (s_axis_tcp_open_status_tvalid & s_axis_tcp_open_status_tready ) begin
        openStatusCounter <= openStatusCounter + 1'b1;
        if (s_axis_tcp_open_status_tdata[16]) begin
          successOpenCounter <= successOpenCounter + 1'b1;
        end
      end

      if (m_axis_tcp_read_pkg_tvalid & m_axis_tcp_read_pkg_tready) begin
        rdRqstByteCnt <= rdRqstByteCnt + m_axis_tcp_read_pkg_tdata[31:16];
      end

      if (s_axis_tcp_rx_data_tvalid & s_axis_tcp_rx_data_tready & s_axis_tcp_rx_data_tlast) begin
        rcvPktCnt <= rcvPktCnt + 1'b1;
      end

      scatter_connections <= {listenCounter,openReqCounter,successOpenCounter,closeReqCounter};
   end
end



scatter_ip scatter_ip (
   .m_axis_close_connection_V_V_TVALID(m_axis_tcp_close_connection_tvalid),      // output wire m_axis_close_connection_TVALID
   .m_axis_close_connection_V_V_TREADY(m_axis_tcp_close_connection_tready),      // input wire m_axis_close_connection_TREADY
   .m_axis_close_connection_V_V_TDATA(m_axis_tcp_close_connection_tdata),        // output wire [15 : 0] m_axis_close_connection_TDATA
   .m_axis_listen_port_V_V_TVALID(m_axis_tcp_listen_port_tvalid),                // output wire m_axis_listen_port_TVALID
   .m_axis_listen_port_V_V_TREADY(m_axis_tcp_listen_port_tready),                // input wire m_axis_listen_port_TREADY
   .m_axis_listen_port_V_V_TDATA(m_axis_tcp_listen_port_tdata),                  // output wire [15 : 0] m_axis_listen_port_TDATA
   .m_axis_open_connection_V_TVALID(m_axis_tcp_open_connection_tvalid),        // output wire m_axis_open_connection_TVALID
   .m_axis_open_connection_V_TREADY(m_axis_tcp_open_connection_tready),        // input wire m_axis_open_connection_TREADY
   .m_axis_open_connection_V_TDATA(m_axis_tcp_open_connection_tdata),          // output wire [47 : 0] m_axis_open_connection_TDATA
   .m_axis_read_package_V_TVALID(m_axis_tcp_read_pkg_tvalid),              // output wire m_axis_read_package_TVALID
   .m_axis_read_package_V_TREADY(m_axis_tcp_read_pkg_tready),              // input wire m_axis_read_package_TREADY
   .m_axis_read_package_V_TDATA(m_axis_tcp_read_pkg_tdata),                // output wire [31 : 0] m_axis_read_package_TDATA
   .m_axis_tx_data_TVALID(m_axis_tcp_tx_data_tvalid),                        // output wire m_axis_tx_data_TVALID
   .m_axis_tx_data_TREADY(m_axis_tcp_tx_data_tready),                        // input wire m_axis_tx_data_TREADY
   .m_axis_tx_data_TDATA(m_axis_tcp_tx_data_tdata),                          // output wire [63 : 0] m_axis_tx_data_TDATA
   .m_axis_tx_data_TKEEP(m_axis_tcp_tx_data_tkeep),                          // output wire [7 : 0] m_axis_tx_data_TKEEP
   .m_axis_tx_data_TLAST(m_axis_tcp_tx_data_tlast),                          // output wire [0 : 0] m_axis_tx_data_TLAST
   .m_axis_tx_metadata_V_TVALID(m_axis_tcp_tx_meta_tvalid),                // output wire m_axis_tx_metadata_TVALID
   .m_axis_tx_metadata_V_TREADY(m_axis_tcp_tx_meta_tready),                // input wire m_axis_tx_metadata_TREADY
   .m_axis_tx_metadata_V_TDATA(m_axis_tcp_tx_meta_tdata),                  // output wire [15 : 0] m_axis_tx_metadata_TDATA
   .s_axis_listen_port_status_V_TVALID(s_axis_tcp_port_status_tvalid),  // input wire s_axis_listen_port_status_TVALID
   .s_axis_listen_port_status_V_TREADY(s_axis_tcp_port_status_tready),  // output wire s_axis_listen_port_status_TREADY
   .s_axis_listen_port_status_V_TDATA(s_axis_tcp_port_status_tdata),    // input wire [7 : 0] s_axis_listen_port_status_TDATA
   .s_axis_notifications_V_TVALID(s_axis_tcp_notification_tvalid),            // input wire s_axis_notifications_TVALID
   .s_axis_notifications_V_TREADY(s_axis_tcp_notification_tready),            // output wire s_axis_notifications_TREADY
   .s_axis_notifications_V_TDATA(s_axis_tcp_notification_tdata),              // input wire [87 : 0] s_axis_notifications_TDATA
   .s_axis_open_status_V_TVALID(s_axis_tcp_open_status_tvalid),                // input wire s_axis_open_status_TVALID
   .s_axis_open_status_V_TREADY(s_axis_tcp_open_status_tready),                // output wire s_axis_open_status_TREADY
   .s_axis_open_status_V_TDATA(s_axis_tcp_open_status_tdata),                  // input wire [23 : 0] s_axis_open_status_TDATA
   .s_axis_rx_data_TVALID(s_axis_tcp_rx_data_tvalid),                        // input wire s_axis_rx_data_TVALID
   .s_axis_rx_data_TREADY(s_axis_tcp_rx_data_tready),                        // output wire s_axis_rx_data_TREADY
   .s_axis_rx_data_TDATA(s_axis_tcp_rx_data_tdata),                          // input wire [63 : 0] s_axis_rx_data_TDATA
   .s_axis_rx_data_TKEEP(s_axis_tcp_rx_data_tkeep),                          // input wire [7 : 0] s_axis_rx_data_TKEEP
   .s_axis_rx_data_TLAST(s_axis_tcp_rx_data_tlast),                          // input wire [0 : 0] s_axis_rx_data_TLAST
   .s_axis_rx_metadata_V_V_TVALID(s_axis_tcp_rx_meta_tvalid),                // input wire s_axis_rx_metadata_TVALID
   .s_axis_rx_metadata_V_V_TREADY(s_axis_tcp_rx_meta_tready),                // output wire s_axis_rx_metadata_TREADY
   .s_axis_rx_metadata_V_V_TDATA(s_axis_tcp_rx_meta_tdata),                  // input wire [15 : 0] s_axis_rx_metadata_TDATA
   .s_axis_tx_status_V_TVALID(s_axis_tcp_tx_status_tvalid),                    // input wire s_axis_tx_status_TVALID
   .s_axis_tx_status_V_TREADY(s_axis_tcp_tx_status_tready),                    // output wire s_axis_tx_status_TREADY
   .s_axis_tx_status_V_TDATA(s_axis_tcp_tx_status_tdata),                      // input wire [23 : 0] s_axis_tx_status_TDATA
   
   //Client only
    .runExperiment_V(runExperiment),
    .useConn_V(useConnReg),
    .useIpAddr_V(UseIpAddrReg),
    .pkgWordCount_V(pkgWordCountReg),
    .regBasePort_V(regBasePort),
    .usePort_V(usePortReg),
    .expectedRespInKB_V(expectedRespInKBPerConReg),
    .finishExperiment_V(finishExperiment),
    // .delayedCycles_V(delayedCyclesReg),
    .clientPkgNum_V(clientPkgNumReg),
    .regIpAddress0_V(regIpAddress[0]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress1_V(regIpAddress[1]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress2_V(regIpAddress[2]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress3_V(regIpAddress[3]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress4_V(regIpAddress[4]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress5_V(regIpAddress[5]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress6_V(regIpAddress[6]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress7_V(regIpAddress[7]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress8_V(regIpAddress[8]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress9_V(regIpAddress[9]),                                    // input wire [31 : 0] regIpAddress1_V
    .regIpAddress10_V(regIpAddress[10]),                                    // input wire [31 : 0] regIpAddress1_V

   .ap_clk(ap_clk),                                                          // input wire aclk
   .ap_rst_n(ap_rst_n)                                                    // input wire aresetn
 );
 



/*
 * Role Controller
 */

// AXI4-Lite slave interface
user_krnl_control_s_axi #(
  .C_S_AXI_ADDR_WIDTH ( C_S_AXI_CONTROL_ADDR_WIDTH ),
  .C_S_AXI_DATA_WIDTH ( C_S_AXI_CONTROL_DATA_WIDTH )
)
inst_control_s_axi (
  .ACLK                   ( ap_clk                 ),
  .ARESET                 ( ~ap_rst_n              ),
  .ACLK_EN                ( 1'b1                   ),
  .AWVALID                ( s_axi_control_awvalid  ), 
  .AWREADY                ( s_axi_control_awready  ),
  .AWADDR                 ( s_axi_control_awaddr   ),
  .WVALID                 ( s_axi_control_wvalid   ),
  .WREADY                 ( s_axi_control_wready   ),
  .WDATA                  ( s_axi_control_wdata    ),
  .WSTRB                  ( s_axi_control_wstrb    ),
  .ARVALID                ( s_axi_control_arvalid  ),
  .ARREADY                ( s_axi_control_arready  ),
  .ARADDR                 ( s_axi_control_araddr   ),
  .RVALID                 ( s_axi_control_rvalid   ),
  .RREADY                 ( s_axi_control_rready   ),
  .RDATA                  ( s_axi_control_rdata    ),
  .RRESP                  ( s_axi_control_rresp    ),
  .BVALID                 ( s_axi_control_bvalid   ),
  .BREADY                 ( s_axi_control_bready   ),
  .BRESP                  ( s_axi_control_bresp    ),
  .interrupt              ( interrupt              ),
  .ap_start               ( ap_start               ),
  .ap_done                ( ap_done                ),
  .ap_ready               ( ap_ready               ),
  .ap_idle                ( ap_idle                ),
  .useConn                ( useConn                ),
  .useIpAddr              ( useIpAddr              ),
  .pkgWordCount           ( pkgWordCount           ),
  .basePort               ( basePort               ),
  .usePort                ( usePort                ),
  .expectedRespInKBPerCon ( expectedRespInKBPerCon ),
  .delayedCycles          ( delayedCycles          ),
  .clientPkgNum           ( clientPkgNum           ),
  .baseIpAddress          ( baseIpAddress          ),
  .expectedRespInKBTotal  (expectedRespInKBTotal   ),
  .axi00_ptr0             ( axi00_ptr0             )
);


/*
 * Statistics
 */


always @(posedge ap_clk) begin
    if (~ap_rst_n) begin
        scatter_consumed_bytes <= '0;
        scatter_produced_bytes <= '0;
    end
    else begin
        if (ap_start_pulse) begin
          scatter_consumed_bytes <= '0;
          scatter_produced_bytes <= '0;
        end

        if (s_axis_tcp_rx_data_tvalid && s_axis_tcp_rx_data_tready) begin
            case (s_axis_tcp_rx_data_tkeep)
                64'h1: scatter_consumed_bytes <= scatter_consumed_bytes + 1;
                64'h3: scatter_consumed_bytes <= scatter_consumed_bytes + 2;
                64'h7: scatter_consumed_bytes <= scatter_consumed_bytes + 4;
                64'hF: scatter_consumed_bytes <= scatter_consumed_bytes + 4;
                64'h1F: scatter_consumed_bytes <= scatter_consumed_bytes + 5;
                64'h3F: scatter_consumed_bytes <= scatter_consumed_bytes + 6;
                64'h7F: scatter_consumed_bytes <= scatter_consumed_bytes + 7;
                64'hFF: scatter_consumed_bytes <= scatter_consumed_bytes + 8;
                64'hFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 16;
                64'hFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 20;
                64'hFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 24;
                64'hFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 28;
                64'hFFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 32;
                64'hFFFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 36;
                64'hFFFFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 40;
                64'hFFFFFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 44;
                64'hFFFFFFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 48;
                64'hFFFFFFFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 52;
                64'hFFFFFFFFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 56;
                64'hFFFFFFFFFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 60;
                64'hFFFFFFFFFFFFFFFF: scatter_consumed_bytes <= scatter_consumed_bytes + 64;
            endcase
        end

        if (m_axis_tcp_tx_data_tvalid && m_axis_tcp_tx_data_tready) begin
            case (m_axis_tcp_tx_data_tkeep)
                64'hF: scatter_produced_bytes <= scatter_produced_bytes + 4;
                64'hFF: scatter_produced_bytes <= scatter_produced_bytes + 8;
                64'hFFFF: scatter_produced_bytes <= scatter_produced_bytes + 16;
                64'hFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 20;
                64'hFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 24;
                64'hFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 28;
                64'hFFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 32;
                64'hFFFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 36;
                64'hFFFFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 40;
                64'hFFFFFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 44;
                64'hFFFFFFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 48;
                64'hFFFFFFFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 52;
                64'hFFFFFFFFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 56;
                64'hFFFFFFFFFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 60;
                64'hFFFFFFFFFFFFFFFF: scatter_produced_bytes <= scatter_produced_bytes + 64;
            endcase
        end

    end
end


logic[31:0] scatter_tx_cmd_counter;
logic[31:0] scatter_tx_pkg_counter;
logic[31:0] scatter_tx_sts_counter;
logic[31:0] scatter_tx_sts_good_counter;
logic[31:0] scatter_tx_sts_bad_counter;
logic[31:0] tx_data_down_cycle;
always @(posedge ap_clk) begin
    if (~ap_rst_n | ap_start_pulse) begin
        scatter_tx_cmd_counter <= '0;
        scatter_tx_pkg_counter <= '0;
        scatter_tx_sts_counter <= '0;
        scatter_tx_sts_good_counter <= '0;
        scatter_tx_sts_bad_counter <= '0;
        tx_data_down_cycle <= '0;
    end
    else begin
        if (m_axis_tcp_tx_meta_tvalid && m_axis_tcp_tx_meta_tready) begin
            scatter_tx_cmd_counter <= scatter_tx_cmd_counter + 1;
        end
        if (m_axis_tcp_tx_data_tvalid && m_axis_tcp_tx_data_tready && m_axis_tcp_tx_data_tlast) begin
            scatter_tx_pkg_counter <= scatter_tx_pkg_counter + 1;
        end
        if (s_axis_tcp_tx_status_tvalid && s_axis_tcp_tx_status_tready) begin
            scatter_tx_sts_counter <= scatter_tx_sts_counter + 1;
            if (s_axis_tcp_tx_status_tdata[63:62] == 0) begin
                scatter_tx_sts_good_counter <= scatter_tx_sts_good_counter + 1;
            end
            else begin
              scatter_tx_sts_bad_counter <= scatter_tx_sts_bad_counter + 1;
            end
        end
        if (m_axis_tcp_tx_data_tvalid && ~m_axis_tcp_tx_data_tready) begin
          tx_data_down_cycle <= tx_data_down_cycle + 1'b1;
        end
    end
end
`define DEBUG
`ifdef DEBUG


ila_scatter benchmark_debug (
  .clk(ap_clk), // input wire clk

  .probe0(m_axis_tcp_open_connection_tvalid), // input wire [0:0]  probe0  
  .probe1(m_axis_tcp_open_connection_tready), // input wire [0:0]  probe1  
  .probe2(s_axis_tcp_open_status_tvalid), // input wire [0:0]  probe2     
  .probe3(s_axis_tcp_open_status_tready), // input wire [0:0]  probe3    
  .probe4(s_axis_tcp_rx_data_tvalid), // input wire [0:0]  probe4    
  .probe5(s_axis_tcp_rx_data_tready), // input wire [0:0]  probe5                        
  .probe6(s_axis_tcp_notification_tvalid), // input wire [0:0]  probe6                        
  .probe7(s_axis_tcp_notification_tready), // input wire [0:0]  probe7                        
  .probe8(m_axis_tcp_tx_data_tvalid),    //1                                                
  .probe9(m_axis_tcp_tx_data_tready),//1
  .probe10(s_axis_tcp_port_status_tready),//1
  .probe11(m_axis_tcp_tx_meta_tvalid),//1
  .probe12(m_axis_tcp_tx_meta_tready),//1
  .probe13(running), //1
  .probe14(s_axis_tcp_open_status_tdata[16]), //1    
  .probe15(s_axis_tcp_tx_status_tdata[63:62]), //2
  .probe16(scatter_produced_bytes[15:0]), // 16
  .probe17(scatter_produced_bytes[31:16]), // input wire [15:0]  
  .probe18(s_axis_tcp_open_status_tdata[15:0]),// input wire [15:0]  
  .probe19(rdRqstByteCnt[15:0]), // input wire [15:0]  
  .probe20(rdRqstByteCnt[31:16]), // input wire [15:0]  
  .probe21(rcvPktCnt[15:0]), // input wire [15:0]
  .probe22(ap_start),
  .probe23(ap_done),
  .probe24(s_axis_tcp_tx_status_tready),
  .probe25(s_axis_tcp_tx_status_tvalid),
  .probe26(scatter_execution_cycles[15:0]), //16
  .probe27(scatter_execution_cycles[31:16]), //16
  .probe28(scatter_produced_bytes[47:32]),//16
  .probe29(scatter_tx_pkg_counter[31:0]), //32
  .probe30(openConCycle) //32
);
`endif

endmodule
`default_nettype wire
