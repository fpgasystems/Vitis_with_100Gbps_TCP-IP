// This is a generated file. Use and modify at your own risk.
//////////////////////////////////////////////////////////////////////////////// 
// default_nettype of none prevents implicit wire declaration.
`default_nettype none
`timescale 1 ns / 1 ps
// Top level of the kernel. Do not modify module name, parameters or ports.
module cmac_krnl #(
  parameter integer C_S_AXI_CONTROL_ADDR_WIDTH = 12 ,
  parameter integer C_S_AXI_CONTROL_DATA_WIDTH = 32 ,
  parameter integer C_AXIS_NET_RX_TDATA_WIDTH  = 512,
  parameter integer C_AXIS_NET_TX_TDATA_WIDTH  = 512
)
(
  // System Signals
  input  wire                                    ap_clk               ,
  input  wire                                    ap_rst_n             ,
  // AXI4-Stream (master) interface axis_net_rx
  output wire                                    axis_net_rx_tvalid   ,
  input  wire                                    axis_net_rx_tready   ,
  output wire [C_AXIS_NET_RX_TDATA_WIDTH-1:0]    axis_net_rx_tdata    ,
  output wire [C_AXIS_NET_RX_TDATA_WIDTH/8-1:0]  axis_net_rx_tkeep    ,
  output wire                                    axis_net_rx_tlast    ,
  // AXI4-Stream (slave) interface axis_net_tx
  input  wire                                    axis_net_tx_tvalid   ,
  output wire                                    axis_net_tx_tready   ,
  input  wire [C_AXIS_NET_TX_TDATA_WIDTH-1:0]    axis_net_tx_tdata    ,
  input  wire [C_AXIS_NET_TX_TDATA_WIDTH/8-1:0]  axis_net_tx_tkeep    ,
  input  wire                                    axis_net_tx_tlast    ,

  // Network physical
  input  wire clk_gt_freerun,
  input  wire [3:0] gt_rxp_in,
  input  wire [3:0] gt_rxn_in,
  output wire [3:0] gt_txp_out,
  output wire [3:0] gt_txn_out, 
  input  wire gt_refclk0_p,
  input  wire gt_refclk0_n 
);

///////////////////////////////////////////////////////////////////////////////
// Local Parameters
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// Wires and Variables
///////////////////////////////////////////////////////////////////////////////
(* DONT_TOUCH = "yes" *)
reg                                 areset                         = 1'b0;

// Register and invert reset signal.
always @(posedge ap_clk) begin
  areset <= ~ap_rst_n;
end

///////////////////////////////////////////////////////////////////////////////
// Add kernel logic here.  Modify/remove example code as necessary.
///////////////////////////////////////////////////////////////////////////////


/**
 * Clock Generation
 */
logic network_init;

// Network clock
logic net_aresetn;
logic net_clk;

// Network reset
BUFG bufg_aresetn(
    .I(network_init),
    .O(net_aresetn)
);

reg net_aresetn_reg = 1'b1;

always @ (posedge net_clk) begin
  net_aresetn_reg <= net_aresetn;
end

/**
 * Network module
 */
axi_stream axis_net_rx_data_nclk();
axi_stream axis_net_tx_data_nclk();

axi_stream axis_net_rx_data_aclk();
axi_stream axis_net_tx_data_aclk();


network_module inst_network_module
(
    .dclk (clk_gt_freerun),
    .net_clk(net_clk),
    .sys_reset (1'b0),
    .aresetn(net_aresetn_reg),
    .network_init_done(network_init),
    
    .gt_refclk_p(gt_refclk0_p),
    .gt_refclk_n(gt_refclk0_n),
    
    .gt_rxp_in(gt_rxp_in),
    .gt_rxn_in(gt_rxn_in),
    .gt_txp_out(gt_txp_out),
    .gt_txn_out(gt_txn_out),
    
    .user_rx_reset(),
    .user_tx_reset(),
    .rx_aligned(),
    
    //master 0
    .m_axis_net_rx(axis_net_rx_data_nclk),
    .s_axis_net_tx(axis_net_tx_data_nclk)
);

network_clk_cross inst_network_clk_cross (
    .net_clk(net_clk),
    .net_aresetn(net_aresetn_reg),
    .pcie_clk(ap_clk),
    .pcie_aresetn(~areset),

    // NCLK
    .m_axis_net_rx_nclk(axis_net_rx_data_nclk),
    .s_axis_net_tx_nclk(axis_net_tx_data_nclk),

    // ACLK
    .m_axis_net_rx_aclk(axis_net_rx_data_aclk),
    .s_axis_net_tx_aclk(axis_net_tx_data_aclk)
);


axis_register_slice_512 slice_inst_axis_net_rx_data_aclk(
 .aclk(ap_clk),
 .aresetn(~areset),
 .s_axis_tvalid(axis_net_rx_data_aclk.valid),
 .s_axis_tready(axis_net_rx_data_aclk.ready),
 .s_axis_tdata(axis_net_rx_data_aclk.data),
 .s_axis_tkeep(axis_net_rx_data_aclk.keep),
 .s_axis_tlast(axis_net_rx_data_aclk.last),
 .m_axis_tvalid(axis_net_rx_tvalid),
 .m_axis_tready(axis_net_rx_tready),
 .m_axis_tdata(axis_net_rx_tdata),
 .m_axis_tkeep(axis_net_rx_tkeep),
 .m_axis_tlast(axis_net_rx_tlast)
);

axis_register_slice_512 slice_inst_axis_net_tx_data_aclk(
 .aclk(ap_clk),
 .aresetn(~areset),
 .s_axis_tvalid(axis_net_tx_tvalid),
 .s_axis_tready(axis_net_tx_tready),
 .s_axis_tdata(axis_net_tx_tdata),
 .s_axis_tkeep(axis_net_tx_tkeep),
 .s_axis_tlast(axis_net_tx_tlast),
 .m_axis_tvalid(axis_net_tx_data_aclk.valid),
 .m_axis_tready(axis_net_tx_data_aclk.ready),
 .m_axis_tdata(axis_net_tx_data_aclk.data),
 .m_axis_tkeep(axis_net_tx_data_aclk.keep),
 .m_axis_tlast(axis_net_tx_data_aclk.last)
);

// assign axis_net_rx_tvalid = axis_net_rx_data_aclk_reg.valid;
// assign axis_net_rx_tlast = axis_net_rx_data_aclk_reg.last;
// assign axis_net_rx_tkeep = axis_net_rx_data_aclk_reg.keep;
// assign axis_net_rx_tdata = axis_net_rx_data_aclk_reg.data;

// assign axis_net_rx_data_aclk_reg.ready = axis_net_rx_tready;

// assign axis_net_tx_data_aclk.valid = axis_net_tx_tvalid;
// assign axis_net_tx_data_aclk.data = axis_net_tx_tdata;
// assign axis_net_tx_data_aclk.keep = axis_net_tx_tkeep;
// assign axis_net_tx_data_aclk.last = axis_net_tx_tlast;

// assign axis_net_tx_tready = axis_net_tx_data_aclk.ready; 

endmodule
`default_nettype wire