// /*******************************************************************************
// Copyright (c) 2018, Xilinx, Inc.
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification,
// are permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice,
// this list of conditions and the following disclaimer.
// 
// 
// 2. Redistributions in binary form must reproduce the above copyright notice,
// this list of conditions and the following disclaimer in the documentation
// and/or other materials provided with the distribution.
// 
// 
// 3. Neither the name of the copyright holder nor the names of its contributors
// may be used to endorse or promote products derived from this software
// without specific prior written permission.
// 
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
// ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,THE IMPLIED 
// WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
// INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
// BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY 
// OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
// EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// *******************************************************************************/

`timescale 1ns/1ps

`include "network_intf.svh"
`include "network_types.svh"

module network_control_s_axi
#(parameter
    C_S_AXI_ADDR_WIDTH = 6,
    C_S_AXI_DATA_WIDTH = 32
)(
    input  wire                          ACLK,
    input  wire                          ARESET,
    input  wire                          ACLK_EN,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] AWADDR,
    input  wire                          AWVALID,
    output wire                          AWREADY,
    input  wire [C_S_AXI_DATA_WIDTH-1:0] WDATA,
    input  wire [C_S_AXI_DATA_WIDTH/8-1:0] WSTRB,
    input  wire                          WVALID,
    output wire                          WREADY,
    output wire [1:0]                    BRESP,
    output wire                          BVALID,
    input  wire                          BREADY,
    input  wire [C_S_AXI_ADDR_WIDTH-1:0] ARADDR,
    input  wire                          ARVALID,
    output wire                          ARREADY,
    output wire [C_S_AXI_DATA_WIDTH-1:0] RDATA,
    output wire [1:0]                    RRESP,
    output wire                          RVALID,
    input  wire                          RREADY,
    output wire                          interrupt,
    output wire                          ap_start,
    input  wire                          ap_done,
    input  wire                          ap_ready,
    input  wire                          ap_idle,
    output wire [31:0]                   ip_addr,
    output wire [31:0]                   board_number,
    output wire [31:0]                   arp,
    output wire [63:0]                   axi00_ptr0,
    output wire [63:0]                   axi01_ptr0
);
//------------------------Address Info-------------------
// 0x00 : Control signals
//        bit 0  - ap_start (Read/Write/COH)
//        bit 1  - ap_done (Read/COR)
//        bit 2  - ap_idle (Read)
//        bit 3  - ap_ready (Read)
//        bit 7  - auto_restart (Read/Write)
//        others - reserved
// 0x04 : Global Interrupt Enable Register
//        bit 0  - Global Interrupt Enable (Read/Write)
//        others - reserved
// 0x08 : IP Interrupt Enable Register (Read/Write)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x0c : IP Interrupt Status Register (Read/TOW)
//        bit 0  - Channel 0 (ap_done)
//        bit 1  - Channel 1 (ap_ready)
//        others - reserved
// 0x10 : Data signal of ip_addr
//        bit 31~0 - ip_addr[31:0] (Read/Write)
// 0x14 : reserved
// 0x18 : Data signal of board_number
//        bit 31~0 - board_number[31:0] (Read/Write)
// 0x1c : reserved
// 0x20 : Data signal of arp
//        bit 31~0 - arp[31:0] (Read/Write)
// 0x24 : reserved
// 0x28 : Data signal of axi00_ptr0
//        bit 31~0 - axi00_ptr0[31:0] (Read/Write)
// 0x2c : Data signal of axi00_ptr0
//        bit 31~0 - axi00_ptr0[63:32] (Read/Write)
// 0x30 : reserved
// 0x34 : Data signal of axi01_ptr0
//        bit 31~0 - axi01_ptr0[31:0] (Read/Write)
// 0x38 : Data signal of axi01_ptr0
//        bit 31~0 - axi01_ptr0[63:32] (Read/Write)
// 0x3c : reserved
// (SC = Self Clear, COR = Clear on Read, TOW = Toggle on Write, COH = Clear on Handshake)

//------------------------Parameter----------------------
localparam
    ADDR_AP_CTRL             = 6'h00,
    ADDR_GIE                 = 6'h04,
    ADDR_IER                 = 6'h08,
    ADDR_ISR                 = 6'h0c,
    ADDR_IP_ADDR_DATA_0      = 6'h10,
    ADDR_IP_ADDR_CTRL        = 6'h14,
    ADDR_BOARD_NUMBER_DATA_0 = 6'h18,
    ADDR_BOARD_NUMBER_CTRL   = 6'h1c,
    ADDR_ARP_DATA_0          = 6'h20,
    ADDR_ARP_CTRL            = 6'h24,
    ADDR_AXI00_PTR0_DATA_0   = 6'h28,
    ADDR_AXI00_PTR0_DATA_1   = 6'h2c,
    ADDR_AXI00_PTR0_CTRL     = 6'h30,
    ADDR_AXI01_PTR0_DATA_0   = 6'h34,
    ADDR_AXI01_PTR0_DATA_1   = 6'h38,
    ADDR_AXI01_PTR0_CTRL     = 6'h3c,
    WRIDLE                   = 2'd0,
    WRDATA                   = 2'd1,
    WRRESP                   = 2'd2,
    WRRESET                  = 2'd3,
    RDIDLE                   = 2'd0,
    RDDATA                   = 2'd1,
    RDRESET                  = 2'd2,
    ADDR_BITS         = 6;

//------------------------Local signal-------------------
    reg  [1:0]                    wstate = WRRESET;
    reg  [1:0]                    wnext;
    reg  [ADDR_BITS-1:0]          waddr;
    wire [31:0]                   wmask;
    wire                          aw_hs;
    wire                          w_hs;
    reg  [1:0]                    rstate = RDRESET;
    reg  [1:0]                    rnext;
    reg  [31:0]                   rdata;
    wire                          ar_hs;
    wire [ADDR_BITS-1:0]          raddr;
    // internal registers
    reg                           int_ap_idle;
    reg                           int_ap_ready;
    reg                           int_ap_done = 1'b0;
    reg                           int_ap_start = 1'b0;
    reg                           int_auto_restart = 1'b0;
    reg                           int_gie = 1'b0;
    reg  [1:0]                    int_ier = 2'b0;
    reg  [1:0]                    int_isr = 2'b0;
    reg  [31:0]                   int_ip_addr = 'b0;
    reg  [31:0]                   int_board_number = 'b0;
    reg  [31:0]                   int_arp = 'b0;
    reg  [63:0]                   int_axi00_ptr0 = 'b0;
    reg  [63:0]                   int_axi01_ptr0 = 'b0;



//------------------------Instantiation------------------

//------------------------AXI write fsm------------------
assign AWREADY = (wstate == WRIDLE);
assign WREADY  = (wstate == WRDATA);
assign BRESP   = 2'b00;  // OKAY
assign BVALID  = (wstate == WRRESP);
assign wmask   = { {8{WSTRB[3]}}, {8{WSTRB[2]}}, {8{WSTRB[1]}}, {8{WSTRB[0]}} };
assign aw_hs   = AWVALID & AWREADY;
assign w_hs    = WVALID & WREADY;

// wstate
always @(posedge ACLK) begin
    if (ARESET)
        wstate <= WRRESET;
    else if (ACLK_EN)
        wstate <= wnext;
end

// wnext
always @(*) begin
    case (wstate)
        WRIDLE:
            if (AWVALID)
                wnext = WRDATA;
            else
                wnext = WRIDLE;
        WRDATA:
            if (WVALID)
                wnext = WRRESP;
            else
                wnext = WRDATA;
        WRRESP:
            if (BREADY)
                wnext = WRIDLE;
            else
                wnext = WRRESP;
        default:
            wnext = WRIDLE;
    endcase
end

// waddr
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (aw_hs)
            waddr <= AWADDR[ADDR_BITS-1:0];
    end
end

//------------------------AXI read fsm-------------------
assign ARREADY = (rstate == RDIDLE);
assign RDATA   = rdata;
assign RRESP   = 2'b00;  // OKAY
assign RVALID  = (rstate == RDDATA);
assign ar_hs   = ARVALID & ARREADY;
assign raddr   = ARADDR[ADDR_BITS-1:0];

// rstate
always @(posedge ACLK) begin
    if (ARESET)
        rstate <= RDRESET;
    else if (ACLK_EN)
        rstate <= rnext;
end

// rnext
always @(*) begin
    case (rstate)
        RDIDLE:
            if (ARVALID)
                rnext = RDDATA;
            else
                rnext = RDIDLE;
        RDDATA:
            if (RREADY & RVALID)
                rnext = RDIDLE;
            else
                rnext = RDDATA;
        default:
            rnext = RDIDLE;
    endcase
end

// rdata
always @(posedge ACLK) begin
    if (ACLK_EN) begin
        if (ar_hs) begin
            rdata <= 32'h0;
            case (raddr)
                ADDR_AP_CTRL: begin
                    rdata[0] <= int_ap_start;
                    rdata[1] <= int_ap_done;
                    rdata[2] <= int_ap_idle;
                    rdata[3] <= int_ap_ready;
                    rdata[7] <= int_auto_restart;
                end
                ADDR_GIE: begin
                    rdata <= int_gie;
                end
                ADDR_IER: begin
                    rdata <= int_ier;
                end
                ADDR_ISR: begin
                    rdata <= int_isr;
                end
                ADDR_IP_ADDR_DATA_0: begin
                    rdata <= int_ip_addr[31:0];
                end
                ADDR_BOARD_NUMBER_DATA_0: begin
                    rdata <= int_board_number[31:0];
                end
                ADDR_ARP_DATA_0: begin
                    rdata <= int_arp[31:0];
                end
                ADDR_AXI00_PTR0_DATA_0: begin
                    rdata <= int_axi00_ptr0[31:0];
                end
                ADDR_AXI00_PTR0_DATA_1: begin
                    rdata <= int_axi00_ptr0[63:32];
                end
                ADDR_AXI01_PTR0_DATA_0: begin
                    rdata <= int_axi01_ptr0[31:0];
                end
                ADDR_AXI01_PTR0_DATA_1: begin
                    rdata <= int_axi01_ptr0[63:32];
                end
            endcase
        end
    end
end


//------------------------Register logic-----------------
assign interrupt    = int_gie & (|int_isr);
assign ap_start     = int_ap_start;
assign ip_addr      = int_ip_addr;
assign board_number = int_board_number;
assign arp          = int_arp;
assign axi00_ptr0   = int_axi00_ptr0;
assign axi01_ptr0   = int_axi01_ptr0;
// int_ap_start
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_start <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0] && WDATA[0])
            int_ap_start <= 1'b1;
        else if (ap_ready)
            int_ap_start <= int_auto_restart; // clear on handshake/auto restart
    end
end

// int_ap_done
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_done <= 1'b0;
    else if (ACLK_EN) begin
        if (ap_done)
            int_ap_done <= 1'b1;
        else if (ar_hs && raddr == ADDR_AP_CTRL)
            int_ap_done <= 1'b0; // clear on read
    end
end

// int_ap_idle
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_idle <= 1'b0;
    else if (ACLK_EN) begin
            int_ap_idle <= ap_idle;
    end
end

// int_ap_ready
always @(posedge ACLK) begin
    if (ARESET)
        int_ap_ready <= 1'b0;
    else if (ACLK_EN) begin
            int_ap_ready <= ap_ready;
    end
end

// int_auto_restart
always @(posedge ACLK) begin
    if (ARESET)
        int_auto_restart <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AP_CTRL && WSTRB[0])
            int_auto_restart <=  WDATA[7];
    end
end

// int_gie
always @(posedge ACLK) begin
    if (ARESET)
        int_gie <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_GIE && WSTRB[0])
            int_gie <= WDATA[0];
    end
end

// int_ier
always @(posedge ACLK) begin
    if (ARESET)
        int_ier <= 1'b0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_IER && WSTRB[0])
            int_ier <= WDATA[1:0];
    end
end

// int_isr[0]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[0] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[0] & ap_done)
            int_isr[0] <= 1'b1;
        else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
            int_isr[0] <= int_isr[0] ^ WDATA[0]; // toggle on write
    end
end

// int_isr[1]
always @(posedge ACLK) begin
    if (ARESET)
        int_isr[1] <= 1'b0;
    else if (ACLK_EN) begin
        if (int_ier[1] & ap_ready)
            int_isr[1] <= 1'b1;
        else if (w_hs && waddr == ADDR_ISR && WSTRB[0])
            int_isr[1] <= int_isr[1] ^ WDATA[1]; // toggle on write
    end
end

// int_ip_addr[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_ip_addr[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_IP_ADDR_DATA_0)
            int_ip_addr[31:0] <= (WDATA[31:0] & wmask) | (int_ip_addr[31:0] & ~wmask);
    end
end

// int_board_number[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_board_number[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_BOARD_NUMBER_DATA_0)
            int_board_number[31:0] <= (WDATA[31:0] & wmask) | (int_board_number[31:0] & ~wmask);
    end
end

// int_arp[31:0]
// always @(posedge ACLK) begin
//     if (ARESET)
//         int_arp[31:0] <= 0;
//     else if (ACLK_EN) begin
//         if (w_hs && waddr == ADDR_ARP_DATA_0)
//             int_arp[31:0] <= (WDATA[31:0] & wmask) | (int_arp[31:0] & ~wmask);
//     end
// end

// int_arp[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_arp[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_ARP_DATA_0) begin
            for(int i = 0; i < 4; i++) begin
                 if(WSTRB[i]) begin
                    int_arp[(i*8)+:8] <= WDATA[(24-i*8)+:8];
                end
            end
        end
    end
end

// int_axi00_ptr0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_axi00_ptr0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AXI00_PTR0_DATA_0)
            int_axi00_ptr0[31:0] <= (WDATA[31:0] & wmask) | (int_axi00_ptr0[31:0] & ~wmask);
    end
end

// int_axi00_ptr0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_axi00_ptr0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AXI00_PTR0_DATA_1)
            int_axi00_ptr0[63:32] <= (WDATA[31:0] & wmask) | (int_axi00_ptr0[63:32] & ~wmask);
    end
end

// int_axi01_ptr0[31:0]
always @(posedge ACLK) begin
    if (ARESET)
        int_axi01_ptr0[31:0] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AXI01_PTR0_DATA_0)
            int_axi01_ptr0[31:0] <= (WDATA[31:0] & wmask) | (int_axi01_ptr0[31:0] & ~wmask);
    end
end

// int_axi01_ptr0[63:32]
always @(posedge ACLK) begin
    if (ARESET)
        int_axi01_ptr0[63:32] <= 0;
    else if (ACLK_EN) begin
        if (w_hs && waddr == ADDR_AXI01_PTR0_DATA_1)
            int_axi01_ptr0[63:32] <= (WDATA[31:0] & wmask) | (int_axi01_ptr0[63:32] & ~wmask);
    end
end


//------------------------Memory logic-------------------

endmodule
