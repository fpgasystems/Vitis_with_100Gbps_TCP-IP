`include "network_types.svh"
`include "network_intf.svh"

module network_clk_cross (
    input  wire             net_clk,
    input  wire             net_aresetn,
    input  wire             pcie_clk,
    input  wire             pcie_aresetn,
    
    // NCLK
    axi_stream.slave        m_axis_net_rx_nclk,
    axi_stream.master       s_axis_net_tx_nclk,

    // ACLK
    axi_stream.master       m_axis_net_rx_aclk,
    axi_stream.slave        s_axis_net_tx_aclk
);


reg net_aresetn_reg = 1'b1;
always @ (posedge net_clk) begin
  net_aresetn_reg <= net_aresetn;
end

reg pcie_aresetn_reg = 1'b1;
always @ (posedge pcie_clk) begin
  pcie_aresetn_reg <= pcie_aresetn;
end

//
// Crossings init
//

axi_stream m_axis_net_rx_nclk_r ();
axi_stream s_axis_net_tx_nclk_r ();

axi_stream m_axis_net_rx_aclk_r ();
axi_stream s_axis_net_tx_aclk_r ();

// Might be an overkill
axis_data_reg_array #(.N_STAGES(8)) inst_reg_data_nclk1 (.aclk(net_clk), .aresetn(net_aresetn_reg), .s_axis(m_axis_net_rx_nclk), .m_axis(m_axis_net_rx_nclk_r));
axis_data_reg_array #(.N_STAGES(8)) inst_reg_data_nclk2 (.aclk(net_clk), .aresetn(net_aresetn_reg), .s_axis(s_axis_net_tx_nclk_r), .m_axis(s_axis_net_tx_nclk));
axis_data_reg_array #(.N_STAGES(8)) inst_reg_data_aclk1 (.aclk(pcie_clk), .aresetn(pcie_aresetn_reg), .s_axis(m_axis_net_rx_aclk_r), .m_axis(m_axis_net_rx_aclk));
axis_data_reg_array #(.N_STAGES(8)) inst_reg_data_aclk2 (.aclk(pcie_clk), .aresetn(pcie_aresetn_reg), .s_axis(s_axis_net_tx_aclk), .m_axis(s_axis_net_tx_aclk_r));

// Data
axis_data_fifo_cc_udp_data inst_cc_udp_data_rx (
    .m_axis_aclk(pcie_clk),
    .s_axis_aclk(net_clk),
    .s_axis_aresetn(net_aresetn_reg),
    .s_axis_tvalid(m_axis_net_rx_nclk_r.valid),
    .s_axis_tready(m_axis_net_rx_nclk_r.ready),
    .s_axis_tdata(m_axis_net_rx_nclk_r.data),
    .s_axis_tlast(m_axis_net_rx_nclk_r.last),
    .s_axis_tkeep(m_axis_net_rx_nclk_r.keep),
    .m_axis_tvalid(m_axis_net_rx_aclk_r.valid),
    .m_axis_tready(m_axis_net_rx_aclk_r.ready),
    .m_axis_tdata(m_axis_net_rx_aclk_r.data),
    .m_axis_tlast(m_axis_net_rx_aclk_r.last),
    .m_axis_tkeep(m_axis_net_rx_aclk_r.keep)
);

axis_data_fifo_cc_udp_data inst_cc_udp_data_tx (
    .m_axis_aclk(net_clk),
    .s_axis_aclk(pcie_clk),
    .s_axis_aresetn(pcie_aresetn_reg),
    .s_axis_tvalid(s_axis_net_tx_aclk_r.valid),
    .s_axis_tready(s_axis_net_tx_aclk_r.ready),
    .s_axis_tdata(s_axis_net_tx_aclk_r.data),
    .s_axis_tlast(s_axis_net_tx_aclk_r.last),
    .s_axis_tkeep(s_axis_net_tx_aclk_r.keep),
    .m_axis_tvalid(s_axis_net_tx_nclk_r.valid),
    .m_axis_tready(s_axis_net_tx_nclk_r.ready),
    .m_axis_tdata(s_axis_net_tx_nclk_r.data),
    .m_axis_tlast(s_axis_net_tx_nclk_r.last),
    .m_axis_tkeep(s_axis_net_tx_nclk_r.keep)
);



endmodule