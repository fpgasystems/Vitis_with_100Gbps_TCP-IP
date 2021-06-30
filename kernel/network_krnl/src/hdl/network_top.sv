`timescale 1ns / 1ps

`include "network_types.svh"
`include "network_intf.svh"

`define IP_VERSION4

module network_top #(parameter
    C_S_AXI_ADDR_WIDTH = 12,
    C_S_AXI_DATA_WIDTH = 32
)(
    // Pcie
    input  wire                 aclk,
    input  wire                 aresetn,

    // Net
    // input  wire                 sys_reset,  
    // input  wire                 dclk,             
    // input  wire                 gt_refclk_p,
    // input  wire                 gt_refclk_n,

    // // Phys.
    // input  wire [3:0]           gt_rxp_in,         
    // input  wire [3:0]           gt_rxn_in,            
    // output wire [3:0]           gt_txp_out,
    // output wire [3:0]           gt_txn_out,

    axi_stream.slave            axis_net_rx_data_aclk,
    axi_stream.master           axis_net_tx_data_aclk,

    // Init
    axi_lite.slave              s_axil,

    // TCP/IP
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

    //TCP/IP Application interface streams
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

    // UDP
    axis_meta.master            m_axis_udp_rx_metadata,
    axi_stream.master           m_axis_udp_rx_data,
    axis_meta.slave             s_axis_udp_tx_metadata,
    axi_stream.slave            s_axis_udp_tx_data,

    output wire [63:0]          tx_ddr_offset_addr,
    output wire [63:0]          rx_ddr_offset_addr
);

// /**
//  * Clock Generation
//  */
// logic network_init;

// // Network clock
// logic net_aresetn;
// logic net_clk;

// // Network reset
// BUFG bufg_aresetn(
//     .I(network_init),
//     .O(net_aresetn)
// );

/**
 * Network module
 */
// axi_stream axis_net_rx_data_nclk();
// axi_stream axis_net_tx_data_nclk();

// axi_stream axis_net_rx_data_aclk();
// axi_stream axis_net_tx_data_aclk();

// network_module inst_network_module
// (
//     .dclk (dclk),
//     .net_clk(net_clk),
//     .sys_reset (sys_reset),
//     .aresetn(net_aresetn),
//     .network_init_done(network_init),
    
//     .gt_refclk_p(gt_refclk_p),
//     .gt_refclk_n(gt_refclk_n),
    
//     .gt_rxp_in(gt_rxp_in),
//     .gt_rxn_in(gt_rxn_in),
//     .gt_txp_out(gt_txp_out),
//     .gt_txn_out(gt_txn_out),
    
//     .user_rx_reset(),
//     .user_tx_reset(),
//     .rx_aligned(),
    
//     //master 0
//     .m_axis_net_rx(axis_net_rx_data_nclk),
//     .s_axis_net_tx(axis_net_tx_data_nclk)
// );

// network_clk_cross inst_network_clk_cross (
//     .net_clk(net_clk),
//     .net_aresetn(net_aresetn),
//     .pcie_clk(aclk),
//     .pcie_aresetn(aresetn),

//     // NCLK
//     .m_axis_net_rx_nclk(axis_net_rx_data_nclk),
//     .s_axis_net_tx_nclk(axis_net_tx_data_nclk),

//     // ACLK
//     .m_axis_net_rx_aclk(axis_net_rx_data_aclk),
//     .s_axis_net_tx_aclk(axis_net_tx_data_aclk)
// );

/**
 * Network stack
 */

reg running;
reg [31:0] exe_cycle;
reg [31:0] writeCmdCnt;
reg [31:0] writeStatusCnt;
reg [31:0] writeDataCnt;

always @ (posedge aclk) begin
    if (aresetn==0) begin
        running <= '0;
        exe_cycle <= '0;
        writeCmdCnt <= '0;
        writeStatusCnt <= '0;
        writeDataCnt <= '0;
    end
    else begin
        if (running & exe_cycle == 750000000) begin
            running <= 1'b0;
        end
        else if (m_axis_write_cmd[0].ready & m_axis_write_cmd[0].valid & ~running) begin
            running <= 1'b1;
        end

        if (exe_cycle == 750000000) begin
            exe_cycle <= '0;
        end
        else if (running) begin
            exe_cycle <= exe_cycle + 1'b1;
        end

        if (running & exe_cycle == 750000000) begin
            writeCmdCnt <= '0;
            writeStatusCnt <= '0;
            writeDataCnt <= '0;
        end
        else begin
            if (m_axis_write_data[0].valid & m_axis_write_data[0].ready & m_axis_write_data[0].last) begin
                writeDataCnt <= writeDataCnt + 1;
            end

            if (m_axis_write_cmd[0].ready & m_axis_write_cmd[0].valid ) begin
                writeCmdCnt <= writeCmdCnt + 1;
            end

            if (s_axis_write_sts[0].valid & s_axis_write_sts[0].ready) begin
                writeStatusCnt <= writeStatusCnt + 1;
            end
        end

    end
end




// ila_network_top inst_ila_network_top (
//     .clk(aclk),
//     .probe0(s_axis_read_data[0].valid), //
//     .probe1(running),
//     .probe2(m_axis_write_data[0].valid), //
//     .probe3(m_axis_write_data[0].ready),
//     .probe4(m_axis_read_cmd[0].valid),
//     .probe5(m_axis_read_cmd[0].ready),
//     .probe6(m_axis_write_cmd[0].ready),
//     .probe7(m_axis_write_cmd[0].valid),
//     .probe8(s_axis_read_sts[0].valid),
//     .probe9(s_axis_read_sts[0].ready),
//     .probe10(s_axis_write_sts[0].valid),
//     .probe11(s_axis_write_sts[0].ready),
//     .probe12(writeDataCnt[31:0]), //32
//     .probe13(writeCmdCnt[31:0]), //32
//     .probe14(writeStatusCnt[31:0]) //32
// );



 ila_network_top2 inst_ila_network_top2 (
     .clk(aclk),
     .probe0(axis_net_rx_data_aclk.valid), //
     .probe1(axis_net_rx_data_aclk.ready),
     .probe2(axis_net_tx_data_aclk.valid), //
     .probe3(axis_net_tx_data_aclk.ready),
     .probe4(m_axis_read_cmd[0].valid),
     .probe5(m_axis_read_cmd[0].ready),
     .probe6(m_axis_write_cmd[0].ready),
     .probe7(m_axis_write_cmd[0].valid),
     .probe8(s_axis_read_sts[0].valid),
     .probe9(s_axis_read_sts[0].ready),
     .probe10(s_axis_write_sts[0].valid),
     .probe11(s_axis_write_sts[0].ready)//,
     //.probe12(axis_net_rx_data_aclk.data),//512
     //.probe13(axis_net_tx_data_aclk.data)//512
 );

network_stack #(
    .UDP_EN(UDP_STACK_EN), 
    .TCP_EN(TCP_STACK_EN),
    .RX_DDR_BYPASS_EN(TCP_RX_BYPASS_EN),
    .C_S_AXI_ADDR_WIDTH ( C_S_AXI_ADDR_WIDTH ),
    .C_S_AXI_DATA_WIDTH ( C_S_AXI_DATA_WIDTH )
) inst_network_stack (
    .net_clk(aclk),
    .net_aresetn(aresetn),
    //.pcie_clk(aclk),
    //.pcie_aresetn(aresetn),

    .s_axil(s_axil),

    .s_axis_net(axis_net_rx_data_aclk),
    .m_axis_net(axis_net_tx_data_aclk),

    .m_axis_read_cmd(m_axis_read_cmd),
    .m_axis_write_cmd(m_axis_write_cmd),
    .s_axis_read_sts(s_axis_read_sts),
    .s_axis_write_sts(s_axis_write_sts),
    .s_axis_read_data(s_axis_read_data),
    .m_axis_write_data(m_axis_write_data),

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

    .m_axis_udp_rx_metadata(m_axis_udp_rx_metadata),
    .m_axis_udp_rx_data(m_axis_udp_rx_data),
    .s_axis_udp_tx_metadata(s_axis_udp_tx_metadata),
    .s_axis_udp_tx_data(s_axis_udp_tx_data),
    .tx_ddr_offset_addr(tx_ddr_offset_addr),
    .rx_ddr_offset_addr(rx_ddr_offset_addr)
);


reg sent_first_tx_meta, rcvd_first_notification;
reg [63:0] tx_cycles, rx_cycles;
reg [63:0] txByteCnt, rxByteCnt;

reg sent_first_open_con_req;
reg [31:0] sentOpenConNum, rcvdOpenConNum;
reg [63:0] openConCycle;

always @ (posedge aclk) begin
    if (aresetn==0) begin
        sent_first_tx_meta <= '0;
        rcvd_first_notification <= '0;
        tx_cycles <= '0;
        rx_cycles <= '0;
        txByteCnt <= '0;
        rxByteCnt <= '0;
        sent_first_open_con_req <= '0;
        sentOpenConNum <= '0;
        rcvdOpenConNum <= '0;
        openConCycle <= '0;
    end
    else begin
        //rcvd cycle
        if (rcvd_first_notification & rx_cycles == 750000000) begin
            rcvd_first_notification <= 1'b0;
        end
        else if (m_axis_notifications.valid & m_axis_notifications.ready & ~rcvd_first_notification) begin
            rcvd_first_notification <= 1'b1;
        end

        if (rx_cycles == 750000000) begin
            rx_cycles <= '0;
        end
        else if (rcvd_first_notification) begin
            rx_cycles <= rx_cycles + 1'b1;
        end

        //tx_cycles
        if (sent_first_tx_meta & tx_cycles == 750000000) begin
            sent_first_tx_meta <= 1'b0;
        end
        else if (s_axis_tx_metadata.valid & s_axis_tx_metadata.ready & ~sent_first_tx_meta) begin
            sent_first_tx_meta <= 1'b1;
        end

        if (tx_cycles == 750000000) begin
            tx_cycles <= '0;
        end
        else if (sent_first_tx_meta) begin
            tx_cycles <= tx_cycles + 1'b1;
        end


        if (rx_cycles == 750000000) begin
            rxByteCnt <= '0;
        end
        else if (tx_cycles == 750000000) begin
            txByteCnt <= '0;
        end
        else begin
            if (s_axis_read_package.valid & s_axis_read_package.ready) begin
                rxByteCnt <= rxByteCnt + s_axis_read_package.data[31:16];
            end

            if (m_axis_tx_status.ready & m_axis_tx_status.valid & (m_axis_tx_status.data[63:61] == 0)) begin
                txByteCnt <= txByteCnt + m_axis_tx_status.data[31:16];
            end
        end

        //open con cycles
        if (sent_first_open_con_req & openConCycle == 75000000) begin
            sent_first_open_con_req <= '0;
        end
        else if (s_axis_open_connection.valid & s_axis_open_connection.ready & ~sent_first_open_con_req  ) begin
            sent_first_open_con_req <= 1'b1;
        end

        if (openConCycle == 75000000) begin
            openConCycle <= '0;
        end
        else if (sent_first_open_con_req) begin
            openConCycle <= openConCycle + 1'b1;
        end

        if (openConCycle == 75000000) begin
            sentOpenConNum <= '0;
            rcvdOpenConNum <= '0;
        end
        else begin
            if (s_axis_open_connection.valid & s_axis_open_connection.ready) begin
                sentOpenConNum <= sentOpenConNum + 1;
            end

            if (m_axis_open_status.ready & m_axis_open_status.valid) begin
                rcvdOpenConNum <= rcvdOpenConNum + 1;
            end
        end

    end
end


ila_network_top_perf ila_network_top_perf (
    .clk(aclk),
    .probe0(s_axis_open_connection.valid), //
    .probe1(s_axis_open_connection.ready),
    .probe2(m_axis_open_status.valid), //
    .probe3(m_axis_open_status.ready),
    .probe4(s_axis_tx_metadata.valid),
    .probe5(s_axis_tx_metadata.ready),
    .probe6(m_axis_tx_status.ready),
    .probe7(m_axis_tx_status.valid),
    .probe8(s_axis_tx_data.valid),
    .probe9(s_axis_tx_data.ready),
    .probe10(s_axis_listen_port.valid),
    .probe11(s_axis_listen_port.ready),
    .probe12(m_axis_listen_port_status.valid),
    .probe13(m_axis_listen_port_status.ready),
    .probe14(m_axis_notifications.valid),
    .probe15(m_axis_notifications.ready),
    .probe16(s_axis_read_package.valid),
    .probe17(s_axis_read_package.ready),
    .probe18(m_axis_rx_metadata.valid),
    .probe19(m_axis_rx_metadata.ready),
    .probe20(m_axis_rx_data.valid),
    .probe21(m_axis_rx_data.ready),
    .probe22(sent_first_tx_meta),
    .probe23(rcvd_first_notification),
    .probe24(rxByteCnt), //64
    .probe25(txByteCnt), //64
    .probe26(tx_cycles), //64
    .probe27(rx_cycles),//64

    .probe28(sent_first_open_con_req),
    .probe29(rcvdOpenConNum), //32
    .probe30(sentOpenConNum), //32
    .probe31(openConCycle) //64
);

endmodule
