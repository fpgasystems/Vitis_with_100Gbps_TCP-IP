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

`define IP_VERSION4

`include "network_intf.svh"

module network_stack #(
    parameter NET_BANDWIDTH = 100,
    parameter WIDTH = 512,
    parameter MAC_ADDRESS = 48'hE59D02350A00, // LSB first, 00:0A:35:02:9D:E5
    parameter IPV6_ADDRESS= 128'hE59D_02FF_FF35_0A02_0000_0000_0000_80FE, //LSB first: FE80_0000_0000_0000_020A_35FF_FF02_9DE5,
    parameter IP_SUBNET_MASK = 32'h00FFFFFF,
    parameter IP_DEFAULT_GATEWAY = 32'h00000000,
    parameter DHCP_EN   = 0,
    parameter TCP_EN = 0,
    parameter RX_DDR_BYPASS_EN = 0,
    parameter UDP_EN = 1,
    parameter ROCE_EN = 0,
    parameter C_S_AXI_ADDR_WIDTH = 12,
    parameter C_S_AXI_DATA_WIDTH = 32
)(
    input wire                  net_clk,
    input wire                  net_aresetn,
    //input wire                  pcie_clk,
    //input wire                  pcie_aresetn,

    /* CONTROL INTERFACE */
    axi_lite.slave              s_axil,

    // network interface streams
    axi_stream.slave            s_axis_net,
    axi_stream.master           m_axis_net,

    //TCP/IP Interface
    // memory cmd streams
    axis_mem_cmd.master         m_axis_read_cmd[NUM_TCP_CHANNELS],
    axis_mem_cmd.master         m_axis_write_cmd[NUM_TCP_CHANNELS],
    //// memory sts streams
    axis_mem_status.slave       s_axis_read_sts[NUM_TCP_CHANNELS],
    axis_mem_status.slave       s_axis_write_sts[NUM_TCP_CHANNELS],
    //// memory data streams
    axi_stream.slave            s_axis_read_data[NUM_TCP_CHANNELS],
    axi_stream.master           m_axis_write_data[NUM_TCP_CHANNELS],

    //Application interface streams
    axis_meta.slave             s_axis_listen_port,
    axis_meta.master            m_axis_listen_port_status,
    axis_meta.slave             s_axis_open_connection,
    axis_meta.master            m_axis_open_status,
    axis_meta.slave             s_axis_close_connection,
    axis_meta.master            m_axis_notifications,
    axis_meta.slave             s_axis_read_package,
    axis_meta.master            m_axis_rx_metadata,
    axi_stream.master           m_axis_rx_data,
    axis_meta.slave             s_axis_tx_metadata,
    axi_stream.slave            s_axis_tx_data,
    axis_meta.master            m_axis_tx_status,
    
    //UDP/IP Interface
    axis_meta.master            m_axis_udp_rx_metadata,
    axi_stream.master           m_axis_udp_rx_data,
    axis_meta.slave             s_axis_udp_tx_metadata,
    axi_stream.slave            s_axis_udp_tx_data,

    output reg [63:0]          tx_ddr_offset_addr,
    output reg [63:0]          rx_ddr_offset_addr
 );

// Sync the reset (timing)
(* DONT_TOUCH = "yes" *)
logic net_aresetn_r = 1'b1;

always_ff @(posedge net_clk) begin
  net_aresetn_r <= net_aresetn;
end

// Tie off RDMA
axis_meta m_axis_roce_read_cmd ();
axis_meta m_axis_roce_write_cmd ();
axi_stream s_axis_roce_read_data ();
axi_stream m_axis_roce_write_data ();
axis_meta s_axis_roce_role_tx_meta ();
axi_stream s_axis_roce_role_tx_data ();

always_comb m_axis_roce_read_cmd.tie_off_slave();
always_comb m_axis_roce_write_cmd.tie_off_slave();
always_comb s_axis_roce_read_data.tie_off_master();
always_comb m_axis_roce_write_data.tie_off_slave();
always_comb s_axis_roce_role_tx_meta.tie_off_master();
always_comb s_axis_roce_role_tx_data.tie_off_master();
 
// DDR ports

localparam ddrPortNetworkRx = 1;
localparam ddrPortNetworkTx = 0;

// IP Handler Outputs
axi_stream #(.WIDTH(WIDTH))     axis_iph_to_arp_slice();
axi_stream #(.WIDTH(WIDTH))     axis_iph_to_icmp_slice();
axi_stream #(.WIDTH(WIDTH))     axis_iph_to_icmpv6_slice();
axi_stream #(.WIDTH(WIDTH))     axis_iph_to_rocev6_slice();

//Slice connections on RX path
axi_stream #(.WIDTH(WIDTH))     axis_arp_slice_to_arp();
axi_stream #(.WIDTH(64))        axis_icmp_slice_to_icmp();
axi_stream #(.WIDTH(WIDTH))     axis_iph_to_toe();

// MAC-IP Encode Inputs
axi_stream #(.WIDTH(WIDTH))     axis_intercon_to_mie();
axi_stream #(.WIDTH(WIDTH))     axis_mie_to_intercon();

//Slice connections on RX path
axi_stream #(.WIDTH(WIDTH))     axis_arp_to_arp_slice();
axi_stream #(.WIDTH(64))        axis_icmp_to_icmp_slice(); //TODO

// ICMP
axi_stream #(.WIDTH(512))       axis_icmp_slice_to_merge();

//TCP
axi_stream #(.WIDTH(WIDTH))     axis_iph_to_toe_slice();
axi_stream #(.WIDTH(WIDTH))     axis_toe_slice_to_toe();
axi_stream #(.WIDTH(WIDTH))     axis_toe_slice_to_merge();

//UDP
axi_stream #(.WIDTH(WIDTH))     axis_udp_to_udp_slice();
axi_stream #(.WIDTH(WIDTH))     axis_udp_slice_to_merge();
axi_stream #(.WIDTH(WIDTH))     axis_iph_to_udp_slice();
axi_stream #(.WIDTH(WIDTH))     axis_udp_slice_to_udp();

//ROCE
axi_stream #(.WIDTH(WIDTH))     axis_roce_to_roce_slice();
axi_stream #(.WIDTH(WIDTH))     axis_roce_slice_to_merge();
axi_stream #(.WIDTH(WIDTH))     axis_iph_to_roce_slice();

axi_stream #(.WIDTH(WIDTH))     axis_slice_to_ibh();
axi_stream #(.WIDTH(WIDTH))     axis_toe_to_toe_slice();

//ICMPv6
axi_stream #(.WIDTH(WIDTH))     axis_ipv6_to_ethen();
axi_stream #(.WIDTH(WIDTH))     axis_ethencode_to_intercon();

// DHCP Client IP address output //
wire[31:0]  dhcpAddressOut;

//IPV6
axi_stream #(.WIDTH(WIDTH))     axis_icmpv6_to_intercon();
axi_stream #(.WIDTH(WIDTH))     axis_ipv6_to_intercon();

//ARP
axis_meta #(.WIDTH(56)) axis_host_arp_lookup_reply ();
axis_meta #(.WIDTH(32)) axis_host_arp_lookup_request ();

axis_meta #(.WIDTH(56)) axis_arp_lookup_reply ();
axis_meta #(.WIDTH(32)) axis_arp_lookup_request ();

axis_meta #(.WIDTH(56)) axis_arp_lookup_reply_r ();
axis_meta #(.WIDTH(32)) axis_arp_lookup_request_r ();

// IP and board number
wire set_ip_addr_valid;
wire [31:0] set_ip_addr_data;
reg[31:0] local_ip_address;
wire[31:0]ip_address_used;

wire set_board_number_valid;
wire[3:0] set_board_number_data;
reg[3:0] board_number;

// IPv6 lookup
wire axis_ipv6_res_rsp_TVALID;
wire axis_ipv6_res_rsp_TREADY;
wire [55:0] axis_ipv6_res_rsp_TDATA;

wire axis_ipv6_res_req_TVALID;
wire axis_ipv6_res_req_TREADY;
wire [127:0] axis_ipv6_res_req_TDATA;


// Register and distribute ip address
wire[31:0]  dhcp_ip_address;
wire        dhcp_ip_address_en;
reg[47:0]   mie_mac_address;
reg[47:0]   arp_mac_address;
reg[47:0]   ipv6_mac_address;
reg[31:0]   iph_ip_address;
reg[31:0]   arp_ip_address;
reg[31:0]   toe_ip_address;
reg[31:0]   ip_subnet_mask;
reg[31:0]   ip_default_gateway;
reg[127:0] link_local_ipv6_address;

logic       session_count_valid;
logic[15:0] session_count_data;

// Statistics
logic[31:0] rx_word_counter; 
logic[31:0] rx_pkg_counter; 
logic[31:0] tx_word_counter; 
logic[31:0] tx_pkg_counter;

logic[31:0] tcp_rx_pkg_counter;
logic[31:0] tcp_tx_pkg_counter;
logic[31:0] udp_rx_pkg_counter;
logic[31:0] udp_tx_pkg_counter;

logic[31:0] arp_rx_pkg_counter;
logic[31:0] arp_tx_pkg_counter;
logic[31:0] icmp_rx_pkg_counter;
logic[31:0] icmp_tx_pkg_counter;

reg[7:0]  axis_stream_down_counter;
reg axis_stream_down;
reg[7:0]  output_stream_down_counter;
reg output_stream_down;

//assign dhcp_ip_address_en = 1'b1;
//assign dhcp_ip_address = 32'hD1D4010A;

always @(posedge net_clk)
begin
    if (net_aresetn_r == 0) begin
        mie_mac_address <= 48'h000000000000;
        arp_mac_address <= 48'h000000000000;
        ipv6_mac_address <= 48'h000000000000;
        iph_ip_address <= 32'h00000000;
        arp_ip_address <= 32'h00000000;
        toe_ip_address <= 32'h00000000;
        ip_subnet_mask <= 32'h00000000;
        ip_default_gateway <= 32'h00000000;
        link_local_ipv6_address <= 0;
    end
    else begin
        mie_mac_address <= {MAC_ADDRESS[47:44], (MAC_ADDRESS[43:40]+board_number), MAC_ADDRESS[39:0]};
        arp_mac_address <= {MAC_ADDRESS[47:44], (MAC_ADDRESS[43:40]+board_number), MAC_ADDRESS[39:0]};
        ipv6_mac_address <= {MAC_ADDRESS[47:44], (MAC_ADDRESS[43:40]+board_number), MAC_ADDRESS[39:0]};
        //link_local_ipv6_address[127:80] <= ipv6_mac_address;
        //link_local_ipv6_address[15:0] <= 16'h80fe; // fe80
        //link_local_ipv6_address[79:16] <= 64'h0000_0000_0000_0000;
        link_local_ipv6_address <= {IPV6_ADDRESS[127:120]+board_number, IPV6_ADDRESS[119:0]};
        if (DHCP_EN == 1) begin
            if (dhcp_ip_address_en == 1'b1) begin
                iph_ip_address <= dhcp_ip_address;
                arp_ip_address <= dhcp_ip_address;
                toe_ip_address <= dhcp_ip_address;
            end
        end
        else begin
            iph_ip_address <= local_ip_address;
            arp_ip_address <= local_ip_address;
            toe_ip_address <= local_ip_address;
            ip_subnet_mask <= IP_SUBNET_MASK;
            ip_default_gateway <= {local_ip_address[31:28], 8'h01, local_ip_address[23:0]};
        end
    end
end
// ip address output
assign ip_address_used = iph_ip_address;

/**
 * IP handler
 */

axis_data_reg inst_reg_net_in (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(s_axis_net), .m_axis(axis_slice_to_ibh));
 
ip_handler_ip ip_handler_inst (
.m_axis_arp_TVALID(axis_iph_to_arp_slice.valid), // output AXI4Stream_M_TVALID
.m_axis_arp_TREADY(axis_iph_to_arp_slice.ready), // input AXI4Stream_M_TREADY
.m_axis_arp_TDATA(axis_iph_to_arp_slice.data), // output [63 : 0] AXI4Stream_M_TDATA
.m_axis_arp_TKEEP(axis_iph_to_arp_slice.keep), // output [7 : 0] AXI4Stream_M_TSTRB
.m_axis_arp_TLAST(axis_iph_to_arp_slice.last), // output [0 : 0] AXI4Stream_M_TLAST

.m_axis_icmp_TVALID(axis_iph_to_icmp_slice.valid), // output AXI4Stream_M_TVALID
.m_axis_icmp_TREADY(axis_iph_to_icmp_slice.ready), // input AXI4Stream_M_TREADY
.m_axis_icmp_TDATA(axis_iph_to_icmp_slice.data), // output [63 : 0] AXI4Stream_M_TDATA
.m_axis_icmp_TKEEP(axis_iph_to_icmp_slice.keep), // output [7 : 0] AXI4Stream_M_TSTRB
.m_axis_icmp_TLAST(axis_iph_to_icmp_slice.last), // output [0 : 0] AXI4Stream_M_TLAST

.m_axis_icmpv6_TVALID(axis_iph_to_icmpv6_slice.valid),
.m_axis_icmpv6_TREADY(axis_iph_to_icmpv6_slice.ready),
.m_axis_icmpv6_TDATA(axis_iph_to_icmpv6_slice.data),
.m_axis_icmpv6_TKEEP(axis_iph_to_icmpv6_slice.keep),
.m_axis_icmpv6_TLAST(axis_iph_to_icmpv6_slice.last),

.m_axis_ipv6udp_TVALID(axis_iph_to_rocev6_slice.valid),
.m_axis_ipv6udp_TREADY(axis_iph_to_rocev6_slice.ready),
.m_axis_ipv6udp_TDATA(axis_iph_to_rocev6_slice.data), 
.m_axis_ipv6udp_TKEEP(axis_iph_to_rocev6_slice.keep),
.m_axis_ipv6udp_TLAST(axis_iph_to_rocev6_slice.last),

.m_axis_udp_TVALID(axis_iph_to_udp_slice.valid),
.m_axis_udp_TREADY(axis_iph_to_udp_slice.ready),
.m_axis_udp_TDATA(axis_iph_to_udp_slice.data),
.m_axis_udp_TKEEP(axis_iph_to_udp_slice.keep),
.m_axis_udp_TLAST(axis_iph_to_udp_slice.last),

.m_axis_tcp_TVALID(axis_iph_to_toe_slice.valid),
.m_axis_tcp_TREADY(axis_iph_to_toe_slice.ready),
.m_axis_tcp_TDATA(axis_iph_to_toe_slice.data),
.m_axis_tcp_TKEEP(axis_iph_to_toe_slice.keep),
.m_axis_tcp_TLAST(axis_iph_to_toe_slice.last),

.m_axis_roce_TVALID(axis_iph_to_roce_slice.valid),
.m_axis_roce_TREADY(axis_iph_to_roce_slice.ready),
.m_axis_roce_TDATA(axis_iph_to_roce_slice.data),
.m_axis_roce_TKEEP(axis_iph_to_roce_slice.keep),
.m_axis_roce_TLAST(axis_iph_to_roce_slice.last),

.s_axis_raw_TVALID(axis_slice_to_ibh.valid),
.s_axis_raw_TREADY(axis_slice_to_ibh.ready),
.s_axis_raw_TDATA(axis_slice_to_ibh.data),
.s_axis_raw_TKEEP(axis_slice_to_ibh.keep),
.s_axis_raw_TLAST(axis_slice_to_ibh.last),

.myIpAddress_V(iph_ip_address),

.ap_clk(net_clk), // input aclk
.ap_rst_n(net_aresetn_r) // input aresetn
);

`ifndef IP_VERSION4
//IPv4
assign axis_iph_to_udp_tready = 1'b1;
assign axis_udp_to_merge_tvalid = 1'b0;
assign axis_udp_to_merge_tdata = 0;
assign axis_udp_to_merge_tkeep = 0;
assign axis_udp_to_merge_tlast = 1'b0;
`else
// IPv6
assign axis_iph_to_rocev6_slice.ready = 1'b1;
assign axis_ipv6_to_intercon.valid = 1'b0;
assign axis_ipv6_to_intercon.data = 0;
assign axis_ipv6_to_intercon.keep = 0;
assign axis_ipv6_to_intercon.last = 1'b0;
`endif

// IP handler -> out slices

// ARP
axis_data_reg inst_reg_arp_in (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(axis_iph_to_arp_slice), .m_axis(axis_arp_slice_to_arp));

// ICMP
axis_512_to_64_converter icmp_in_data_converter (
  .aclk(net_clk),
  .aresetn(net_aresetn_r),
  .s_axis_tvalid(axis_iph_to_icmp_slice.valid),
  .s_axis_tready(axis_iph_to_icmp_slice.ready),
  .s_axis_tdata(axis_iph_to_icmp_slice.data),
  .s_axis_tkeep(axis_iph_to_icmp_slice.keep),
  .s_axis_tlast(axis_iph_to_icmp_slice.last),
  .m_axis_tvalid(axis_icmp_slice_to_icmp.valid),
  .m_axis_tready(axis_icmp_slice_to_icmp.ready),
  .m_axis_tdata(axis_icmp_slice_to_icmp.data),
  .m_axis_tkeep(axis_icmp_slice_to_icmp.keep),
  .m_axis_tlast(axis_icmp_slice_to_icmp.last)
);

icmp_server_ip icmp_server_inst (
  .s_axis_TVALID(axis_icmp_slice_to_icmp.valid),    // input wire dataIn_TVALID
  .s_axis_TREADY(axis_icmp_slice_to_icmp.ready),    // output wire dataIn_TREADY
  .s_axis_TDATA(axis_icmp_slice_to_icmp.data),      // input wire [63 : 0] dataIn_TDATA
  .s_axis_TKEEP(axis_icmp_slice_to_icmp.keep),      // input wire [7 : 0] dataIn_TKEEP
  .s_axis_TLAST(axis_icmp_slice_to_icmp.last),      // input wire [0 : 0] dataIn_TLAST
  .udpIn_TVALID(1'b0),//(axis_udp_to_icmp_tvalid),           // input wire udpIn_TVALID
  .udpIn_TREADY(),           // output wire udpIn_TREADY
  .udpIn_TDATA(0),//(axis_udp_to_icmp_tdata),             // input wire [63 : 0] udpIn_TDATA
  .udpIn_TKEEP(0),//(axis_udp_to_icmp_tkeep),             // input wire [7 : 0] udpIn_TKEEP
  .udpIn_TLAST(0),//(axis_udp_to_icmp_tlast),             // input wire [0 : 0] udpIn_TLAST
  .ttlIn_TVALID(1'b0),//(axis_ttl_to_icmp_tvalid),           // input wire ttlIn_TVALID
  .ttlIn_TREADY(),           // output wire ttlIn_TREADY
  .ttlIn_TDATA(0),//(axis_ttl_to_icmp_tdata),             // input wire [63 : 0] ttlIn_TDATA
  .ttlIn_TKEEP(0),//(axis_ttl_to_icmp_tkeep),             // input wire [7 : 0] ttlIn_TKEEP
  .ttlIn_TLAST(0),//(axis_ttl_to_icmp_tlast),             // input wire [0 : 0] ttlIn_TLAST
  .m_axis_TVALID(axis_icmp_to_icmp_slice.valid),   // output wire dataOut_TVALID
  .m_axis_TREADY(axis_icmp_to_icmp_slice.ready),   // input wire dataOut_TREADY
  .m_axis_TDATA(axis_icmp_to_icmp_slice.data),     // output wire [63 : 0] dataOut_TDATA
  .m_axis_TKEEP(axis_icmp_to_icmp_slice.keep),     // output wire [7 : 0] dataOut_TKEEP
  .m_axis_TLAST(axis_icmp_to_icmp_slice.last),     // output wire [0 : 0] dataOut_TLAST
  .ap_clk(net_clk),                                    // input wire ap_clk
  .ap_rst_n(net_aresetn_r)                                // input wire ap_rst_n
);

axis_64_to_512_converter icmp_out_data_converter (
  .aclk(net_clk),
  .aresetn(net_aresetn_r),
  .s_axis_tvalid(axis_icmp_to_icmp_slice.valid),
  .s_axis_tready(axis_icmp_to_icmp_slice.ready),
  .s_axis_tdata(axis_icmp_to_icmp_slice.data),
  .s_axis_tkeep(axis_icmp_to_icmp_slice.keep),
  .s_axis_tlast(axis_icmp_to_icmp_slice.last),
  .s_axis_tdest(0),
  .m_axis_tvalid(axis_icmp_slice_to_merge.valid),
  .m_axis_tready(axis_icmp_slice_to_merge.ready),
  .m_axis_tdata(axis_icmp_slice_to_merge.data),
  .m_axis_tkeep(axis_icmp_slice_to_merge.keep),
  .m_axis_tlast(axis_icmp_slice_to_merge.last),
  .m_axis_tdest()
);

// UDP Input Slice
axis_data_reg inst_reg_udp_in (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(axis_iph_to_udp_slice), .m_axis(axis_udp_slice_to_udp));

// TOE Input Slice

axis_data_reg inst_reg_toe_in (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(axis_iph_to_toe_slice), .m_axis(axis_toe_slice_to_toe));

// assign axis_iph_to_toe_slice.ready = 1'b0;

// ROCE
assign axis_iph_to_roce_slice.ready = 1'b1;

// TX

// UDP Output Slice
axis_data_reg inst_reg_udp_out (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(axis_udp_to_udp_slice), .m_axis(axis_udp_slice_to_merge));

// TOE Output Slice

axis_data_reg inst_reg_toe_out (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(axis_toe_to_toe_slice), .m_axis(axis_toe_slice_to_merge));

// assign axis_toe_slice_to_merge.valid = 1'b0;
// assign axis_toe_slice_to_merge.data = 0;
// assign axis_toe_slice_to_merge.keep = 0;
// assign axis_toe_slice_to_merge.last = 1'b0;

// ROCE
assign axis_roce_slice_to_merge.valid = 1'b0;
assign axis_roce_slice_to_merge.data = 0;
assign axis_roce_slice_to_merge.keep = 0;
assign axis_roce_slice_to_merge.last = 1'b0;

// Merger out
axis_interconnect_512_4to1 ip_merger (
  .ACLK(net_clk),                                  // input wire ACLK
  .ARESETN(net_aresetn_r),                            // input wire ARESETN
  .S00_AXIS_ACLK(net_clk),                // input wire S00_AXIS_ACLK
  .S01_AXIS_ACLK(net_clk),                // input wire S01_AXIS_ACLK
  .S02_AXIS_ACLK(net_clk),                // input wire S02_AXIS_ACLK
  .S03_AXIS_ACLK(net_clk),                // input wire S03_AXIS_ACLK
  .S00_AXIS_ARESETN(net_aresetn_r),          // input wire S00_AXIS_ARESETN
  .S01_AXIS_ARESETN(net_aresetn_r),          // input wire S01_AXIS_ARESETN
  .S02_AXIS_ARESETN(net_aresetn_r),          // input wire S02_AXIS_ARESETN
  .S03_AXIS_ARESETN(net_aresetn_r),          // input wire S03_AXIS_ARESETN
  
  .S00_AXIS_TVALID(axis_icmp_slice_to_merge.valid),            // input wire S00_AXIS_TVALID
  .S00_AXIS_TREADY(axis_icmp_slice_to_merge.ready),            // output wire S00_AXIS_TREADY
  .S00_AXIS_TDATA(axis_icmp_slice_to_merge.data),              // input wire [63 : 0] S00_AXIS_TDATA
  .S00_AXIS_TKEEP(axis_icmp_slice_to_merge.keep),              // input wire [7 : 0] S00_AXIS_TKEEP
  .S00_AXIS_TLAST(axis_icmp_slice_to_merge.last),              // input wire S00_AXIS_TLAST

  .S01_AXIS_TVALID(axis_udp_slice_to_merge.valid),            // input wire S01_AXIS_TVALID
  .S01_AXIS_TREADY(axis_udp_slice_to_merge.ready),            // output wire S01_AXIS_TREADY
  .S01_AXIS_TDATA(axis_udp_slice_to_merge.data),              // input wire [63 : 0] S01_AXIS_TDATA
  .S01_AXIS_TKEEP(axis_udp_slice_to_merge.keep),              // input wire [7 : 0] S01_AXIS_TKEEP
  .S01_AXIS_TLAST(axis_udp_slice_to_merge.last),              // input wire S01_AXIS_TLAST

  .S02_AXIS_TVALID(axis_toe_slice_to_merge.valid),            // input wire S02_AXIS_TVALID
  .S02_AXIS_TREADY(axis_toe_slice_to_merge.ready),            // output wire S02_AXIS_TREADY
  .S02_AXIS_TDATA(axis_toe_slice_to_merge.data),              // input wire [63 : 0] S02_AXIS_TDATA
  .S02_AXIS_TKEEP(axis_toe_slice_to_merge.keep),              // input wire [7 : 0] S02_AXIS_TKEEP
  .S02_AXIS_TLAST(axis_toe_slice_to_merge.last),              // input wire S02_AXIS_TLAST

  .S03_AXIS_TVALID(axis_roce_slice_to_merge.valid),            // input wire S01_AXIS_TVALID
  .S03_AXIS_TREADY(axis_roce_slice_to_merge.ready),            // output wire S01_AXIS_TREADY
  .S03_AXIS_TDATA(axis_roce_slice_to_merge.data),              // input wire [63 : 0] S01_AXIS_TDATA
  .S03_AXIS_TKEEP(axis_roce_slice_to_merge.keep),              // input wire [7 : 0] S01_AXIS_TKEEP
  .S03_AXIS_TLAST(axis_roce_slice_to_merge.last),              // input wire S01_AXIS_TLAST

  .M00_AXIS_ACLK(net_clk),                // input wire M00_AXIS_ACLK
  .M00_AXIS_ARESETN(net_aresetn_r),          // input wire M00_AXIS_ARESETN
  .M00_AXIS_TVALID(axis_intercon_to_mie.valid),            // output wire M00_AXIS_TVALID
  .M00_AXIS_TREADY(axis_intercon_to_mie.ready),            // input wire M00_AXIS_TREADY
  .M00_AXIS_TDATA(axis_intercon_to_mie.data),              // output wire [63 : 0] M00_AXIS_TDATA
  .M00_AXIS_TKEEP(axis_intercon_to_mie.keep),              // output wire [7 : 0] M00_AXIS_TKEEP
  .M00_AXIS_TLAST(axis_intercon_to_mie.last),              // output wire M00_AXIS_TLAST
  .S00_ARB_REQ_SUPPRESS(1'b0),  // input wire S00_ARB_REQ_SUPPRESS
  .S01_ARB_REQ_SUPPRESS(1'b0),  // input wire S01_ARB_REQ_SUPPRESS
  .S02_ARB_REQ_SUPPRESS(1'b0),  // input wire S02_ARB_REQ_SUPPRESS
  .S03_ARB_REQ_SUPPRESS(1'b0)  // input wire S02_ARB_REQ_SUPPRESS
);

/**
 * ARP lookup
 */

axis_meta_reg #(.WIDTH(32)) inst_meta_slice_0 (.aclk(net_clk), .aresetn(net_aresetn_r), .meta_in(axis_arp_lookup_request), .meta_out(axis_arp_lookup_request_r));
axis_meta_reg #(.WIDTH(56)) inst_meta_slice_1 (.aclk(net_clk), .aresetn(net_aresetn_r), .meta_in(axis_arp_lookup_reply), .meta_out(axis_arp_lookup_reply_r));


mac_ip_encode_ip mac_ip_encode_inst (
.m_axis_ip_TVALID(axis_mie_to_intercon.valid),
.m_axis_ip_TREADY(axis_mie_to_intercon.ready),
.m_axis_ip_TDATA(axis_mie_to_intercon.data),
.m_axis_ip_TKEEP(axis_mie_to_intercon.keep),
.m_axis_ip_TLAST(axis_mie_to_intercon.last),
.m_axis_arp_lookup_request_V_V_TVALID(axis_arp_lookup_request.valid),
.m_axis_arp_lookup_request_V_V_TREADY(axis_arp_lookup_request.ready),
.m_axis_arp_lookup_request_V_V_TDATA(axis_arp_lookup_request.data),
.s_axis_ip_TVALID(axis_intercon_to_mie.valid),
.s_axis_ip_TREADY(axis_intercon_to_mie.ready),
.s_axis_ip_TDATA(axis_intercon_to_mie.data),
.s_axis_ip_TKEEP(axis_intercon_to_mie.keep),
.s_axis_ip_TLAST(axis_intercon_to_mie.last),
.s_axis_arp_lookup_reply_V_TVALID(axis_arp_lookup_reply_r.valid),
.s_axis_arp_lookup_reply_V_TREADY(axis_arp_lookup_reply_r.ready),
.s_axis_arp_lookup_reply_V_TDATA(axis_arp_lookup_reply_r.data),

.myMacAddress_V(mie_mac_address),                                    // input wire [47 : 0] regMacAddress_V
.regSubNetMask_V(ip_subnet_mask),                                    // input wire [31 : 0] regSubNetMask_V
.regDefaultGateway_V(ip_default_gateway),                            // input wire [31 : 0] regDefaultGateway_V
  
.ap_clk(net_clk), // input aclk
.ap_rst_n(net_aresetn_r) // input aresetn
);

/**
 * Merges IP and ARP 
 */

axis_interconnect_512_2to1 mac_merger (
  .ACLK(net_clk), // input ACLK
  .ARESETN(net_aresetn_r), // input ARESETN
  .S00_AXIS_ACLK(net_clk), // input S00_AXIS_ACLK
  .S01_AXIS_ACLK(net_clk), // input S01_AXIS_ACLK
  //.S02_AXIS_ACLK(net_clk), // input S01_AXIS_ACLK
  .S00_AXIS_ARESETN(net_aresetn_r), // input S00_AXIS_ARESETN
  .S01_AXIS_ARESETN(net_aresetn_r), // input S01_AXIS_ARESETN
  //.S02_AXIS_ARESETN(net_aresetn_r), // input S01_AXIS_ARESETN
  .S00_AXIS_TVALID(axis_arp_to_arp_slice.valid), // input S00_AXIS_TVALID
  .S00_AXIS_TREADY(axis_arp_to_arp_slice.ready), // output S00_AXIS_TREADY
  .S00_AXIS_TDATA(axis_arp_to_arp_slice.data), // input [63 : 0] S00_AXIS_TDATA
  .S00_AXIS_TKEEP(axis_arp_to_arp_slice.keep), // input [7 : 0] S00_AXIS_TKEEP
  .S00_AXIS_TLAST(axis_arp_to_arp_slice.last), // input S00_AXIS_TLAST
  
  .S01_AXIS_TVALID(axis_mie_to_intercon.valid), // input S01_AXIS_TVALID
  .S01_AXIS_TREADY(axis_mie_to_intercon.ready), // output S01_AXIS_TREADY
  .S01_AXIS_TDATA(axis_mie_to_intercon.data), // input [63 : 0] S01_AXIS_TDATA
  .S01_AXIS_TKEEP(axis_mie_to_intercon.keep), // input [7 : 0] S01_AXIS_TKEEP
  .S01_AXIS_TLAST(axis_mie_to_intercon.last), // input S01_AXIS_TLAST
  
  /*.S02_AXIS_TVALID(axis_ethencode_to_intercon.valid), // input S01_AXIS_TVALID
  .S02_AXIS_TREADY(axis_ethencode_to_intercon.ready), // output S01_AXIS_TREADY
  .S02_AXIS_TDATA(axis_ethencode_to_intercon.data), // input [63 : 0] S01_AXIS_TDATA
  .S02_AXIS_TKEEP(axis_ethencode_to_intercon.keep), // input [7 : 0] S01_AXIS_TKEEP
  .S02_AXIS_TLAST(axis_ethencode_to_intercon.last), // input S01_AXIS_TLAST*/
  
  .M00_AXIS_ACLK(net_clk), // input M00_AXIS_ACLK
  .M00_AXIS_ARESETN(net_aresetn_r), // input M00_AXIS_ARESETN
  .M00_AXIS_TVALID(m_axis_net.valid), // output M00_AXIS_TVALID
  .M00_AXIS_TREADY(m_axis_net.ready), // input M00_AXIS_TREADY
  .M00_AXIS_TDATA(m_axis_net.data), // output [63 : 0] M00_AXIS_TDATA
  .M00_AXIS_TKEEP(m_axis_net.keep), // output [7 : 0] M00_AXIS_TKEEP
  .M00_AXIS_TLAST(m_axis_net.last), // output M00_AXIS_TLAST
  .S00_ARB_REQ_SUPPRESS(1'b0), // input S00_ARB_REQ_SUPPRESS
  .S01_ARB_REQ_SUPPRESS(1'b0) // input S01_ARB_REQ_SUPPRESS
  //.S02_ARB_REQ_SUPPRESS(1'b0) // input S01_ARB_REQ_SUPPRESS
);

logic[15:0] arp_request_pkg_counter;
logic[15:0] arp_reply_pkg_counter;

arp_server_subnet_ip arp_server_inst(
.m_axis_TVALID(axis_arp_to_arp_slice.valid),
.m_axis_TREADY(axis_arp_to_arp_slice.ready),
.m_axis_TDATA(axis_arp_to_arp_slice.data),
.m_axis_TKEEP(axis_arp_to_arp_slice.keep),
.m_axis_TLAST(axis_arp_to_arp_slice.last),
.m_axis_arp_lookup_reply_V_TVALID(axis_arp_lookup_reply.valid),
.m_axis_arp_lookup_reply_V_TREADY(axis_arp_lookup_reply.ready),
.m_axis_arp_lookup_reply_V_TDATA(axis_arp_lookup_reply.data),
.m_axis_host_arp_lookup_reply_V_TVALID(axis_host_arp_lookup_reply.valid),
.m_axis_host_arp_lookup_reply_V_TREADY(axis_host_arp_lookup_reply.ready),
.m_axis_host_arp_lookup_reply_V_TDATA(axis_host_arp_lookup_reply.data),
.s_axis_TVALID(axis_arp_slice_to_arp.valid),
.s_axis_TREADY(axis_arp_slice_to_arp.ready),
.s_axis_TDATA(axis_arp_slice_to_arp.data),
.s_axis_TKEEP(axis_arp_slice_to_arp.keep),
.s_axis_TLAST(axis_arp_slice_to_arp.last),
.s_axis_arp_lookup_request_V_V_TVALID(axis_arp_lookup_request_r.valid),
.s_axis_arp_lookup_request_V_V_TREADY(axis_arp_lookup_request_r.ready),
.s_axis_arp_lookup_request_V_V_TDATA(axis_arp_lookup_request_r.data),
.s_axis_host_arp_lookup_request_V_V_TVALID(axis_host_arp_lookup_request.valid),
.s_axis_host_arp_lookup_request_V_V_TREADY(axis_host_arp_lookup_request.ready),
.s_axis_host_arp_lookup_request_V_V_TDATA(axis_host_arp_lookup_request.data),

.myMacAddress_V(arp_mac_address),
.myIpAddress_V(arp_ip_address),
.regRequestCount_V(arp_request_pkg_counter),
.regRequestCount_V_ap_vld(),
.regReplyCount_V(arp_reply_pkg_counter),
.regReplyCount_V_ap_vld(),

.ap_clk(net_clk), // input aclk
.ap_rst_n(net_aresetn_r) // input aresetn
);

// IP and board number
always @(posedge net_clk) begin
    if (~net_aresetn_r) begin
        local_ip_address <= 32'hD1D4010B;
        board_number <= 0;
    end
    else begin
        if (set_ip_addr_valid) begin
            local_ip_address[7:0] <= set_ip_addr_data[31:24];
            local_ip_address[15:8] <= set_ip_addr_data[23:16];
            local_ip_address[23:16] <= set_ip_addr_data[15:8];
            local_ip_address[31:24] <= set_ip_addr_data[7:0];
        end
        if (set_board_number_valid) begin
            board_number <= set_board_number_data;
        end
    end
end

/*
 * TCP/IP
 */ 

tcp_stack #(
     .TCP_EN(TCP_EN),
     .WIDTH(WIDTH),
     .RX_DDR_BYPASS_EN(RX_DDR_BYPASS_EN)
 ) tcp_stack_inst(
     .net_clk(net_clk), // input aclk
     .net_aresetn(net_aresetn_r), // input aresetn
     
     // streams to network
     .s_axis_rx_data(axis_toe_slice_to_toe),
     .m_axis_tx_data(axis_toe_to_toe_slice),
     
     // memory cmd streams
     .m_axis_mem_read_cmd(m_axis_read_cmd),
     .m_axis_mem_write_cmd(m_axis_write_cmd),
     // memory sts streams
     .s_axis_mem_read_sts(s_axis_read_sts),
     .s_axis_mem_write_sts(s_axis_write_sts),
     // memory data streams
     .s_axis_mem_read_data(s_axis_read_data),
     .m_axis_mem_write_data(m_axis_write_data),
     
     //Application
     .s_axis_listen_port(s_axis_listen_port),
     .m_axis_listen_port_status(m_axis_listen_port_status),
     
     .s_axis_open_connection(s_axis_open_connection),
     .m_axis_open_status(m_axis_open_status),
     .s_axis_close_connection(s_axis_close_connection),
     
     .m_axis_notifications(m_axis_notifications),
     .s_axis_read_package(s_axis_read_package),
     
     .m_axis_rx_metadata(m_axis_rx_metadata),
     .m_axis_rx_data(m_axis_rx_data),
     
     .s_axis_tx_metadata(s_axis_tx_metadata),
     .s_axis_tx_data(s_axis_tx_data),
     .m_axis_tx_status(m_axis_tx_status),
     
     .local_ip_address(toe_ip_address),
     .session_count_valid(session_count_valid),
     .session_count_data(session_count_data)
);


/*
 * UDP/IP
 */
axis_meta #(.WIDTH(UDP_META_WIDTH))    m_axis_udp_rx_metadata_r();
axis_meta #(.WIDTH(UDP_META_WIDTH))    s_axis_udp_tx_metadata_r();

axi_stream #(.WIDTH(NETWORK_STACK_WIDTH)) m_axis_udp_rx_data_r();
axi_stream #(.WIDTH(NETWORK_STACK_WIDTH)) s_axis_udp_tx_data_r();

udp_stack #(
      .UDP_EN(UDP_EN),
      .WIDTH(WIDTH)
  ) udp_stack_inst(
      .net_clk(net_clk), // input aclk
      .net_aresetn(net_aresetn_r), // input aresetn
      
      // streams to network
      .s_axis_rx_data(axis_udp_slice_to_udp),
      .m_axis_tx_data(axis_udp_to_udp_slice),
      
      // Role
      .m_axis_udp_rx_metadata(m_axis_udp_rx_metadata_r),
      .m_axis_udp_rx_data(m_axis_udp_rx_data_r),
      .s_axis_udp_tx_metadata(s_axis_udp_tx_metadata_r),
      .s_axis_udp_tx_data(s_axis_udp_tx_data_r),
      
      .local_ip_address(local_ip_address[31:0]),
      .listen_port(16'h1389)
      
);

axis_data_reg inst_reg_udp_data_m (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(m_axis_udp_rx_data_r), .m_axis(m_axis_udp_rx_data));
axis_data_reg inst_reg_udp_data_s (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(s_axis_udp_tx_data), .m_axis(s_axis_udp_tx_data_r));
axis_udp_meta_reg inst_reg_udp_meta_m (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(m_axis_udp_rx_metadata_r), .m_axis(m_axis_udp_rx_metadata));
axis_udp_meta_reg inst_reg_udp_meta_s (.aclk(net_clk), .aresetn(net_aresetn_r), .s_axis(s_axis_udp_tx_metadata), .m_axis(s_axis_udp_tx_metadata_r));

`ifdef IP_VERSION4

assign axis_ethencode_to_intercon.valid = 1'b0;
assign axis_ethencode_to_intercon.data = 0;
assign axis_ethencode_to_intercon.keep = 0;
assign axis_ethencode_to_intercon.last = 1'b0;

assign axis_iph_to_icmpv6_slice.ready = 1'b1;

`else

eth_encode_ip eth_encode_inst (
.m_axis_eth_data_TVALID(axis_ethencode_to_intercon.valid),
.m_axis_eth_data_TREADY(axis_ethencode_to_intercon.ready),
.m_axis_eth_data_TDATA(axis_ethencode_to_intercon.data),
.m_axis_eth_data_TKEEP(axis_ethencode_to_intercon.keep),
.m_axis_eth_data_TLAST(axis_ethencode_to_intercon.last),
.m_axis_ndp_lookup_request_TVALID(axis_ipv6_res_req_TVALID),
.m_axis_ndp_lookup_request_TREADY(axis_ipv6_res_req_TREADY),
.m_axis_ndp_lookup_request_TDATA(axis_ipv6_res_req_TDATA),
.s_axis_ipv6_data_TVALID(axis_ipv6_to_ethen.valid),
.s_axis_ipv6_data_TREADY(axis_ipv6_to_ethen.ready),
.s_axis_ipv6_data_TDATA(axis_ipv6_to_ethen.data),
.s_axis_ipv6_data_TKEEP(axis_ipv6_to_ethen.keep),
.s_axis_ipv6_data_TLAST(axis_ipv6_to_ethen.last),
.s_axis_ndp_lookup_reply_TVALID(axis_ipv6_res_rsp_TVALID),
.s_axis_ndp_lookup_reply_TREADY(axis_ipv6_res_rsp_TREADY),
.s_axis_ndp_lookup_reply_TDATA(axis_ipv6_res_rsp_TDATA),

.localMacAddress_V(mie_mac_address),  
.aclk(net_clk), // input aclk
.aresetn(net_aresetn_r) // input aresetn
);

// merges icmpv6 & ipv6
axis_interconnect_2to1 ipv6_merger (
  .ACLK(net_clk), // input ACLK
  .ARESETN(aresetn_reg), // input ARESETN
  .S00_AXIS_ACLK(net_clk), // input S00_AXIS_ACLK
  .S01_AXIS_ACLK(net_clk), // input S01_AXIS_ACLK
  .S00_AXIS_ARESETN(aresetn_reg), // input S00_AXIS_ARESETN
  .S01_AXIS_ARESETN(aresetn_reg), // input S01_AXIS_ARESETN
  
  .S00_AXIS_TVALID(axis_icmpv6_to_intercon.valid), // input S00_AXIS_TVALID
  .S00_AXIS_TREADY(axis_icmpv6_to_intercon.ready), // output S00_AXIS_TREADY
  .S00_AXIS_TDATA(axis_icmpv6_to_intercon.data), // input [63 : 0] S00_AXIS_TDATA
  .S00_AXIS_TKEEP(axis_icmpv6_to_intercon.keep), // input [7 : 0] S00_AXIS_TKEEP
  .S00_AXIS_TLAST(axis_icmpv6_to_intercon.last), // input S00_AXIS_TLAST
  
  .S01_AXIS_TVALID(axis_ipv6_to_intercon.valid), // input S01_AXIS_TVALID
  .S01_AXIS_TREADY(axis_ipv6_to_intercon.ready), // output S01_AXIS_TREADY
  .S01_AXIS_TDATA(axis_ipv6_to_intercon.data), // input [63 : 0] S01_AXIS_TDATA
  .S01_AXIS_TKEEP(axis_ipv6_to_intercon.keep), // input [7 : 0] S01_AXIS_TKEEP
  .S01_AXIS_TLAST(axis_ipv6_to_intercon.last), // input S01_AXIS_TLAST
  
  .M00_AXIS_ACLK(net_clk), // input M00_AXIS_ACLK
  .M00_AXIS_ARESETN(aresetn_reg), // input M00_AXIS_ARESETN
  .M00_AXIS_TVALID(axis_ipv6_to_ethen.valid), // output M00_AXIS_TVALID
  .M00_AXIS_TREADY(axis_ipv6_to_ethen.ready), // input M00_AXIS_TREADY
  .M00_AXIS_TDATA(axis_ipv6_to_ethen.data), // output [63 : 0] M00_AXIS_TDATA
  .M00_AXIS_TKEEP(axis_ipv6_to_ethen.keep), // output [7 : 0] M00_AXIS_TKEEP
  .M00_AXIS_TLAST(axis_ipv6_to_ethen.last), // output M00_AXIS_TLAST
  .S00_ARB_REQ_SUPPRESS(1'b0), // input S00_ARB_REQ_SUPPRESS
  .S01_ARB_REQ_SUPPRESS(1'b0) // input S01_ARB_REQ_SUPPRESS
);

ipv6_ip ipv6_inst(

.m_axis_rx_meta_TVALID(axi_ipv6_to_icmpv6_meta.valid,  // output wire m_axis_rx_meta_TVALID
.m_axis_rx_meta_TREADY(axi_ipv6_to_icmpv6_meta.ready,  // input wire m_axis_rx_meta_TREADY
.m_axis_rx_meta_TDATA(axi_ipv6_to_icmpv6_meta.data,    // output wire [151 : 0] m_axis_rx_meta_TDATA


.m_axis_rx_data_TVALID(axi_ipv6_to_icmpv6_data.valid,  // output wire m_axis_rx_data_TVALID
.m_axis_rx_data_TREADY(axi_ipv6_to_icmpv6_data.ready,  // input wire m_axis_rx_data_TREADY
.m_axis_rx_data_TDATA(axi_ipv6_to_icmpv6_data.data,    // output wire [63 : 0] m_axis_rx_data_TDATA
.m_axis_rx_data_TKEEP(axi_ipv6_to_icmpv6_data.keep,    // output wire [7 : 0] m_axis_rx_data_TKEEP
.m_axis_rx_data_TLAST(axi_ipv6_to_icmpv6_data.last,    // output wire [0 : 0] m_axis_rx_data_TLAST

.s_axis_rx_data_TVALID(axi_iph_to_icmpv6_slice.valid,
.s_axis_rx_data_TREADY(axi_iph_to_icmpv6_slice.ready,
.s_axis_rx_data_TDATA(axi_iph_to_icmpv6_slice.data,
.s_axis_rx_data_TKEEP(axi_iph_to_icmpv6_slice.keep,
.s_axis_rx_data_TLAST(axi_iph_to_icmpv6_slice.last,


.m_axis_tx_data_TVALID(axi_icmpv6_to_intercon.valid,  // output wire m_axis_tx_data_TVALID
.m_axis_tx_data_TREADY(axi_icmpv6_to_intercon.ready,  // input wire m_axis_tx_data_TREADY
.m_axis_tx_data_TDATA(axi_icmpv6_to_intercon.data,    // output wire [63 : 0] m_axis_tx_data_TDATA
.m_axis_tx_data_TKEEP(axi_icmpv6_to_intercon.keep,    // output wire [7 : 0] m_axis_tx_data_TKEEP
.m_axis_tx_data_TLAST(axi_icmpv6_to_intercon.last, 

.s_axis_tx_meta_TVALID(axi_icmpv6_to_ipv6_meta.valid,
.s_axis_tx_meta_TREADY(axi_icmpv6_to_ipv6_meta.ready,
.s_axis_tx_meta_TDATA(axi_icmpv6_to_ipv6_meta.data,
.s_axis_tx_data_TVALID(axi_icmpv6_to_ipv6_data.valid,        // input wire s_axis_data_TVALID
.s_axis_tx_data_TREADY(axi_icmpv6_to_ipv6_data.ready,        // output wire s_axis_data_TREADY
.s_axis_tx_data_TDATA(axi_icmpv6_to_ipv6_data.data,          // input wire [63 : 0] s_axis_data_TDATA
.s_axis_tx_data_TKEEP(axi_icmpv6_to_ipv6_data.keep,          // input wire [7 : 0] s_axis_data_TKEEP
.s_axis_tx_data_TLAST(axi_icmpv6_to_ipv6_data.last,          // input wire [0 : 0] s_axis_data_TLAST
 
.reg_ip_address_V(link_local_ipv6_address),
 
.ap_clk(net_clk),                                    // input wire aclk
.ap_rst_n(aresetn_reg)                              // input wire aresetn
);

icmpv6_server_ip icmpv6_server_inst (
  .m_axis_data_TVALID(axi_icmpv6_to_ipv6_data.valid,        // output wire m_axis_data_TVALID
  .m_axis_data_TREADY(axi_icmpv6_to_ipv6_data.ready,        // input wire m_axis_data_TREADY
  .m_axis_data_TDATA(axi_icmpv6_to_ipv6_data.data,          // output wire [63 : 0] m_axis_data_TDATA
  .m_axis_data_TKEEP(axi_icmpv6_to_ipv6_data.keep,          // output wire [7 : 0] m_axis_data_TKEEP
  .m_axis_data_TLAST(axi_icmpv6_to_ipv6_data.last,          // output wire [0 : 0] m_axis_data_TLAST
  .m_axis_meta_TVALID(axi_icmpv6_to_ipv6_meta.valid,        // output wire m_axis_meta_TVALID
  .m_axis_meta_TREADY(axi_icmpv6_to_ipv6_meta.ready,        // input wire m_axis_meta_TREADY
  .m_axis_meta_TDATA(axi_icmpv6_to_ipv6_meta.data,          // output wire [151 : 0] m_axis_meta_TDATA
  
  .m_ipv6_res_rsp_TVALID(axis_ipv6_res_rsp_TVALID),  // output wire m_ipv6_res_rsp_TVALID
  .m_ipv6_res_rsp_TREADY(axis_ipv6_res_rsp_TREADY),  // input wire m_ipv6_res_rsp_TREADY
  .m_ipv6_res_rsp_TDATA(axis_ipv6_res_rsp_TDATA),    // output wire [55 : 0] m_ipv6_res_rsp_TDATA
  
  .s_axis_data_TVALID(axi_ipv6_to_icmpv6_data.valid,        // input wire s_axis_data_TVALID
  .s_axis_data_TREADY(axi_ipv6_to_icmpv6_data.ready,        // output wire s_axis_data_TREADY
  .s_axis_data_TDATA(axi_ipv6_to_icmpv6_data.data,          // input wire [63 : 0] s_axis_data_TDATA
  .s_axis_data_TKEEP(axi_ipv6_to_icmpv6_data.keep,          // input wire [7 : 0] s_axis_data_TKEEP
  .s_axis_data_TLAST(axi_ipv6_to_icmpv6_data.last,          // input wire [0 : 0] s_axis_data_TLAST
  .s_axis_meta_TVALID(axi_ipv6_to_icmpv6_meta.valid,        // input wire s_axis_meta_TVALID
  .s_axis_meta_TREADY(axi_ipv6_to_icmpv6_meta.ready,        // output wire s_axis_meta_TREADY
  .s_axis_meta_TDATA(axi_ipv6_to_icmpv6_meta.data,          // input wire [151 : 0] s_axis_meta_TDATA
  
  .s_ipv6_res_req_TVALID(axis_ipv6_res_req_TVALID),  // input wire s_ipv6_res_req_TVALID
  .s_ipv6_res_req_TREADY(axis_ipv6_res_req_TREADY),  // output wire s_ipv6_res_req_TREADY
  .s_ipv6_res_req_TDATA(axis_ipv6_res_req_TDATA),    // input wire [127 : 0] s_ipv6_res_req_TDATA
  
  .local_mac_address_V(ipv6_mac_address),      // input wire [47 : 0] local_mac_address_V
  .local_ipv6_address_V(link_local_ipv6_address),    // input wire [127 : 0] local_ipv6_address_V
   
  .ap_clk(net_clk),                                    // input wire aclk
  .ap_rst_n(aresetn_reg)                              // input wire aresetn
);

`endif

/*
 * Network Controller
 */

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
(* KEEP = "yes" *)
logic interrupt;
logic [63:0] axi00_ptr0, axi01_ptr0;
logic ap_start;
logic ap_idle;
logic ap_done;
logic ap_ready;

logic ap_start_r= 1'b0;
logic ap_idle_r= 1'b1;
logic ap_start_pulse;


// create pulse when ap_start transitions to 1
always @(posedge net_clk) begin
  begin
    ap_start_r <= ap_start;
  end
end

assign ap_start_pulse = ap_start & ~ap_start_r;

// ap_idle is asserted when done is asserted, it is de-asserted when ap_start_pulse
// is asserted
always @(posedge net_clk) begin
  if (~net_aresetn_r) begin
    ap_idle_r <= 1'b1;
  end
  else begin
    ap_idle_r <= ap_done ? 1'b1 :
      ap_start_pulse ? 1'b0 : ap_idle;
  end
end

assign ap_idle = ap_idle_r;

// assert ap_done after one second
localparam integer TIMER = 250000000;
reg [31:0] run_counter;

always @ (posedge net_clk ) begin
  if (~net_aresetn_r) begin
    run_counter <= '0;
    ap_done <= 1'b0;
  end
  else begin
    ap_done <= 1'b0;
    if (run_counter == TIMER) begin
      run_counter <= '0;
      ap_done <= 1'b1;
    end
    else if (ap_start) begin
      run_counter <= run_counter + 1'b1;
    end
  end
end

// assign ap_done = axis_host_arp_lookup_reply.valid & axis_host_arp_lookup_reply.ready; //check this done signal

// Ready Logic (non-pipelined case)
assign ap_ready = ap_done;


assign set_ip_addr_valid = ap_start_pulse;
assign set_board_number_valid = ap_start_pulse;
assign axis_host_arp_lookup_request.valid = ap_start_pulse; //TODO: what about axis_host_arp_lookup_request.ready?
assign axis_host_arp_lookup_reply.ready = 1'b1;



network_control_s_axi #(
  .C_S_AXI_ADDR_WIDTH ( C_S_AXI_ADDR_WIDTH ),
  .C_S_AXI_DATA_WIDTH ( C_S_AXI_DATA_WIDTH )
)controller_inst (
    .ACLK(net_clk),
    .ARESET(~net_aresetn_r),
    .ACLK_EN( 1'b1),
     // AXI Lite Master Interface connections
    .AWADDR(s_axil.awaddr),
    .AWVALID(s_axil.awvalid),
    .AWREADY(s_axil.awready),
    .WDATA(s_axil.wdata),
    .WSTRB(s_axil.wstrb),
    .WVALID(s_axil.wvalid),
    .WREADY(s_axil.wready),
    .BRESP(s_axil.bresp),
    .BVALID(s_axil.bvalid),
    .BREADY(s_axil.bready),
    .ARADDR(s_axil.araddr),
    .ARVALID(s_axil.arvalid),
    .ARREADY(s_axil.arready),
    .RDATA(s_axil.rdata),
    .RRESP(s_axil.rresp),
    .RVALID(s_axil.rvalid),
    .RREADY(s_axil.rready),
    .interrupt(interrupt),

    .ip_addr(set_ip_addr_data),
    .board_number(set_board_number_data),
    .arp(axis_host_arp_lookup_request.data),
    .axi00_ptr0(axi00_ptr0),
    .axi01_ptr0(axi01_ptr0),
    .ap_start(ap_start ),
    .ap_done(ap_done),
    .ap_ready(ap_ready),
    .ap_idle(ap_idle)
);

always @ (posedge net_clk) begin
  tx_ddr_offset_addr <= axi00_ptr0;
  rx_ddr_offset_addr <= axi01_ptr0;
end

logic [47:0] exe_cycle, write_cmd_ready_down_0, write_sts_ready_down_0, write_data_ready_down_0;

always @ (posedge net_clk) begin
  if (~net_aresetn_r | ap_start_pulse) begin
    exe_cycle <= '0;
    write_cmd_ready_down_0 <= '0;
    write_sts_ready_down_0 <= '0;
    write_data_ready_down_0 <= '0;
  end
  else begin
    if (ap_start) begin
      exe_cycle <= exe_cycle + 1;
    end
    if (m_axis_write_cmd[0].valid && ~m_axis_write_cmd[0].ready) begin
      write_cmd_ready_down_0 <= write_cmd_ready_down_0 + 1;
    end
    if (s_axis_write_sts[0].valid && ~ s_axis_write_sts[0].ready) begin
      write_sts_ready_down_0 <= write_sts_ready_down_0 + 1;
    end
    if (m_axis_write_data[0].valid && ~m_axis_write_data[0].ready) begin
      write_data_ready_down_0 <= write_data_ready_down_0 + 1;
    end
  end
end

 ila_network_controller inst_ila_network_crtl (
     .clk(net_clk),
     .probe0(exe_cycle[31:0]), //32
     .probe1(s_axil.awvalid),
     .probe2(write_cmd_ready_down_0[31:0]), //32
     .probe3(ap_start),
     .probe4(ap_done),
     .probe5(set_ip_addr_data), //32
     .probe6(axis_host_arp_lookup_request.data), //32
     .probe7(set_board_number_data), //32
     .probe8(ap_start_pulse),
     .probe9(interrupt),
     .probe10(ap_ready),
     .probe11(ap_idle),
     .probe12(s_axil.awready), 
     .probe13(s_axil.wvalid),
     .probe14(s_axil.wready)
 );

/*
 * Statistics
 */

always @(posedge net_clk) begin
    if (~net_aresetn_r) begin
        rx_word_counter <= '0;
        rx_pkg_counter <= '0;
        tx_word_counter <= '0;
        tx_pkg_counter <= '0;

        tcp_rx_pkg_counter <= '0;
        tcp_tx_pkg_counter <= '0;

        arp_rx_pkg_counter <= '0;
        arp_tx_pkg_counter <= '0;
        
        udp_rx_pkg_counter <= '0;
        udp_tx_pkg_counter <= '0;

        axis_stream_down_counter <= '0;
        axis_stream_down <= 1'b0;
    end
    else begin
        if (s_axis_net.ready) begin
            axis_stream_down_counter <= '0;
        end
        if (s_axis_net.valid && ~s_axis_net.ready) begin
            axis_stream_down_counter <= axis_stream_down_counter + 1;
        end
        if (axis_stream_down_counter > 2) begin
            axis_stream_down <= 1'b1;
        end
        if (s_axis_net.valid && s_axis_net.ready) begin
            rx_word_counter <= rx_word_counter + 1;
            if (s_axis_net.last) begin
                rx_pkg_counter <= rx_pkg_counter + 1;
            end
        end
        if (m_axis_net.valid && m_axis_net.ready) begin
            tx_word_counter <= tx_word_counter + 1;
            if (m_axis_net.last) begin
                tx_pkg_counter <= tx_pkg_counter + 1;
            end
        end
        //arp
        if (axis_arp_slice_to_arp.valid && axis_arp_slice_to_arp.ready) begin
            if (axis_arp_slice_to_arp.last) begin
                arp_rx_pkg_counter <= arp_rx_pkg_counter + 1;
            end
        end
        if (axis_arp_to_arp_slice.valid && axis_arp_to_arp_slice.ready) begin
            if (axis_arp_to_arp_slice.last) begin
                arp_tx_pkg_counter <= arp_tx_pkg_counter + 1;
            end
        end
        //icmp
        if (axis_icmp_slice_to_icmp.valid && axis_icmp_slice_to_icmp.ready) begin
            if (axis_icmp_slice_to_icmp.last) begin
                icmp_rx_pkg_counter <= icmp_rx_pkg_counter + 1;
            end
        end
        if (axis_icmp_to_icmp_slice.valid && axis_icmp_to_icmp_slice.ready) begin
            if (axis_icmp_to_icmp_slice.last) begin
                icmp_tx_pkg_counter <= icmp_tx_pkg_counter + 1;
            end
        end
        //tcp
        if (axis_toe_slice_to_toe.valid && axis_toe_slice_to_toe.ready) begin
            if (axis_toe_slice_to_toe.last) begin
                tcp_rx_pkg_counter <= tcp_rx_pkg_counter + 1;
            end
        end
        if (axis_toe_to_toe_slice.valid && axis_toe_to_toe_slice.ready) begin
            if (axis_toe_to_toe_slice.last) begin
                tcp_tx_pkg_counter <= tcp_tx_pkg_counter + 1;
            end
        end
        //udp
        if (axis_udp_slice_to_udp.valid && axis_udp_slice_to_udp.ready) begin
            if (axis_udp_slice_to_udp.last) begin
                udp_rx_pkg_counter <= udp_rx_pkg_counter + 1;
            end
        end
        if (axis_udp_to_udp_slice.valid && axis_udp_to_udp_slice.ready) begin
            if (axis_udp_to_udp_slice.last) begin
                udp_tx_pkg_counter <= udp_tx_pkg_counter + 1;
            end
        end
    end
end

endmodule

`default_nettype wire