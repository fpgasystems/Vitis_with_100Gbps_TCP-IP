/*
 * Copyright (c) 2020, Systems Group, ETH Zurich
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
#include "ap_axi_sdata.h"
#include <ap_fixed.h>
#include "ap_int.h" 
#include "../../../../common/include/communication.hpp"
#include "hls_stream.h"

void establish_con(int useConn, int destIpAddress, int destPort, ap_uint<16>* sessionID, int listenPort, hls::stream<pkt64>& m_axis_tcp_open_connection, 
               hls::stream<pkt128>& s_axis_tcp_open_status, 
               hls::stream<pkt16>& m_axis_tcp_listen_port, 
               hls::stream<pkt8>& s_axis_tcp_port_status)
{

     // static hls::stream<ap_uint<1> > success_open_port;
     // #pragma HLS STREAM variable=success_open_port depth=2

     int success_open_port = 0;

     listenPorts (listenPort, useConn, success_open_port, m_axis_tcp_listen_port, 
               s_axis_tcp_port_status);

     openConnections( useConn, destIpAddress, destPort, m_axis_tcp_open_connection, s_axis_tcp_open_status, sessionID);
     
}

void traffic_gen(int pkgWordCount, int expectedTxPkgCnt, hls::stream<ap_uint<512> >& s_data_in)
{
#pragma HLS dataflow

     for (int i = 0; i < expectedTxPkgCnt; ++i)
     {
          for (int j = 0; j < pkgWordCount; ++j)
          {

               ap_uint<512> s_data;
               for (int k = 0; k < (512/32); k++)
               {
                    #pragma HLS UNROLL
                    s_data(k*32+31, k*32) = i*pkgWordCount+j;
               }
               s_data_in.write(s_data);
          }
     }
}

void send_recv_dataflow(int expectedRxByteCnt, ap_uint<16> sessionID, int pkgWordCount, 
               hls::stream<pkt32>& m_axis_tcp_tx_meta, 
               hls::stream<pkt512>& m_axis_tcp_tx_data, 
               hls::stream<pkt64>& s_axis_tcp_tx_status, 
               hls::stream<pkt128>& s_axis_tcp_notification, 
               hls::stream<pkt32>& m_axis_tcp_read_pkg, 
               hls::stream<pkt16>& s_axis_tcp_rx_meta, 
               hls::stream<pkt512>& s_axis_tcp_rx_data)
{
// #pragma HLS dataflow disable_start_propagation

     static hls::stream<ap_uint<512> >    s_data_out;
     #pragma HLS STREAM variable=s_data_out depth=512

      int iter = (expectedRxByteCnt + 32767) >> 15;
      int remainingByte = expectedRxByteCnt;
      int currentByte = 0;

      for (int i = 0; i < iter; ++i)
      {
          if (remainingByte >= 32768)
          {
              currentByte = 32768;
              remainingByte = remainingByte - 32768;
          }
          else{
              currentByte = remainingByte;
              remainingByte = 0;
          }

         recvData(currentByte, 
              s_data_out,
              s_axis_tcp_notification, 
              m_axis_tcp_read_pkg, 
              s_axis_tcp_rx_meta, 
              s_axis_tcp_rx_data
              );

         sendDataSingleCon( m_axis_tcp_tx_meta, 
                        m_axis_tcp_tx_data, 
                        s_axis_tcp_tx_status,
                        s_data_out,
                        sessionID,
                        1,
                        currentByte, 
                        pkgWordCount);
     }

}


extern "C" {
void hls_recv_send_krnl(
               // Internal Stream
               hls::stream<pkt512>& s_axis_udp_rx, 
               hls::stream<pkt512>& m_axis_udp_tx, 
               hls::stream<pkt256>& s_axis_udp_rx_meta, 
               hls::stream<pkt256>& m_axis_udp_tx_meta, 
               
               hls::stream<pkt16>& m_axis_tcp_listen_port, 
               hls::stream<pkt8>& s_axis_tcp_port_status, 
               hls::stream<pkt64>& m_axis_tcp_open_connection, 
               hls::stream<pkt128>& s_axis_tcp_open_status, 
               hls::stream<pkt16>& m_axis_tcp_close_connection, 
               hls::stream<pkt128>& s_axis_tcp_notification, 
               hls::stream<pkt32>& m_axis_tcp_read_pkg, 
               hls::stream<pkt16>& s_axis_tcp_rx_meta, 
               hls::stream<pkt512>& s_axis_tcp_rx_data, 
               hls::stream<pkt32>& m_axis_tcp_tx_meta, 
               hls::stream<pkt512>& m_axis_tcp_tx_data, 
               hls::stream<pkt64>& s_axis_tcp_tx_status,
               int useConn, 
               int listenPort, 
               int expectedRxByteCnt,
               int destIpAddress,
               int destPort
                      ) {


#pragma HLS INTERFACE axis port = s_axis_udp_rx
#pragma HLS INTERFACE axis port = m_axis_udp_tx
#pragma HLS INTERFACE axis port = s_axis_udp_rx_meta
#pragma HLS INTERFACE axis port = m_axis_udp_tx_meta
#pragma HLS INTERFACE axis port = m_axis_tcp_listen_port
#pragma HLS INTERFACE axis port = s_axis_tcp_port_status
#pragma HLS INTERFACE axis port = m_axis_tcp_open_connection
#pragma HLS INTERFACE axis port = s_axis_tcp_open_status
#pragma HLS INTERFACE axis port = m_axis_tcp_close_connection
#pragma HLS INTERFACE axis port = s_axis_tcp_notification
#pragma HLS INTERFACE axis port = m_axis_tcp_read_pkg
#pragma HLS INTERFACE axis port = s_axis_tcp_rx_meta
#pragma HLS INTERFACE axis port = s_axis_tcp_rx_data
#pragma HLS INTERFACE axis port = m_axis_tcp_tx_meta
#pragma HLS INTERFACE axis port = m_axis_tcp_tx_data
#pragma HLS INTERFACE axis port = s_axis_tcp_tx_status
#pragma HLS INTERFACE s_axilite port=useConn bundle = control
#pragma HLS INTERFACE s_axilite port=listenPort bundle = control
#pragma HLS INTERFACE s_axilite port=expectedRxByteCnt bundle = control
#pragma HLS INTERFACE s_axilite port=destIpAddress bundle = control
#pragma HLS INTERFACE s_axilite port=destPort bundle = control
#pragma HLS INTERFACE s_axilite port = return bundle = control

// #pragma HLS INTERFACE ap_control_non

static hls::stream<ap_uint<512> >    s_test;
#pragma HLS STREAM variable=s_test depth=32

// #pragma HLS dataflow disable_start_propagation

          ap_uint<16> sessionID [32];
          const int pkgWordCount = 16;

          listenPorts (listenPort, useConn, m_axis_tcp_listen_port, 
               s_axis_tcp_port_status);

          // recvData(1024, 
          //      s_axis_tcp_notification, 
          //      m_axis_tcp_read_pkg, 
          //      s_axis_tcp_rx_meta, 
          //      s_axis_tcp_rx_data );

          volatile int wait_counter = 0;
     
           for (int i = 0; i < 100; ++i)
           {
                wait_counter++;
           }

          openConnections( useConn, destIpAddress, destPort, m_axis_tcp_open_connection, s_axis_tcp_open_status, sessionID);

          // traffic_gen(16, 1, s_test);

          // sendDataSingleCon( m_axis_tcp_tx_meta, m_axis_tcp_tx_data, s_axis_tcp_tx_status, s_test, sessionID[0], 1, 1024, pkgWordCount);


          send_recv_dataflow( expectedRxByteCnt, sessionID[0], pkgWordCount, 
                m_axis_tcp_tx_meta, 
                m_axis_tcp_tx_data, 
                s_axis_tcp_tx_status, 
                s_axis_tcp_notification, 
                m_axis_tcp_read_pkg, 
                s_axis_tcp_rx_meta, 
                s_axis_tcp_rx_data);

          // tie_off_tcp_open_connection(m_axis_tcp_open_connection, 
          //      s_axis_tcp_open_status);


          // tie_off_tcp_tx(m_axis_tcp_tx_meta, 
          //                m_axis_tcp_tx_data, 
          //                s_axis_tcp_tx_status);

          tie_off_udp(s_axis_udp_rx, 
               m_axis_udp_tx, 
               s_axis_udp_rx_meta, 
               m_axis_udp_tx_meta);
    
          tie_off_tcp_close_con(m_axis_tcp_close_connection);

// static hls::stream<ap_uint<512> >    s_data_out;
// #pragma HLS STREAM variable=s_data_out depth=512

// #pragma HLS dataflow disable_start_propagation

//           ap_uint<16> sessionID [4];
//           const int pkgWordCount = 16;
          
//           // listenPorts (listenPort, useConn, m_axis_tcp_listen_port, 
//           //      s_axis_tcp_port_status);

//           establish_con(useConn, destIpAddress, destPort, sessionID, listenPort, m_axis_tcp_open_connection, 
//                 s_axis_tcp_open_status, 
//                 m_axis_tcp_listen_port, 
//                 s_axis_tcp_port_status);

//           recvData(expectedRxByteCnt, 
//                s_data_out,
//                s_axis_tcp_notification, 
//                m_axis_tcp_read_pkg, 
//                s_axis_tcp_rx_meta, 
//                s_axis_tcp_rx_data
//                );

//           sendData( m_axis_tcp_tx_meta, m_axis_tcp_tx_data, s_axis_tcp_tx_status, s_data_out, sessionID, useConn, expectedRxByteCnt, pkgWordCount);

//           // tie_off_tcp_open_connection(m_axis_tcp_open_connection, 
//           //      s_axis_tcp_open_status);


//           // tie_off_tcp_tx(m_axis_tcp_tx_meta, 
//           //                m_axis_tcp_tx_data, 
//           //                s_axis_tcp_tx_status);

//           tie_off_udp(s_axis_udp_rx, 
//                m_axis_udp_tx, 
//                s_axis_udp_rx_meta, 
//                m_axis_udp_tx_meta);
    
//           tie_off_tcp_close_con(m_axis_tcp_close_connection);

     }
}