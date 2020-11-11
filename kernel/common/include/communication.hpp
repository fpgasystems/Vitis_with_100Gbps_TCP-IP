
#include "ap_axi_sdata.h"
#include <ap_fixed.h>
#include "ap_int.h" 
#include "hls_stream.h"
#include "axi_utils.hpp"
#include "packet.hpp"
#include "toe.hpp"

#define DWIDTH512 512
#define DWIDTH256 256
#define DWIDTH128 128
#define DWIDTH64 64
#define DWIDTH32 32
#define DWIDTH16 16
#define DWIDTH8 8

typedef ap_axiu<DWIDTH512, 0, 0, 0> pkt512;
typedef ap_axiu<DWIDTH256, 0, 0, 0> pkt256;
typedef ap_axiu<DWIDTH128, 0, 0, 0> pkt128;
typedef ap_axiu<DWIDTH64, 0, 0, 0> pkt64;
typedef ap_axiu<DWIDTH32, 0, 0, 0> pkt32;
typedef ap_axiu<DWIDTH16, 0, 0, 0> pkt16;
typedef ap_axiu<DWIDTH8, 0, 0, 0> pkt8;

void openConnections(int useConn, int baseIpAddress, int basePort, hls::stream<pkt64>& m_axis_tcp_open_connection, hls::stream<pkt32>& s_axis_tcp_open_status, ap_uint<16>* sessionID);

void sendData(hls::stream<pkt32>& m_axis_tcp_tx_meta, 
               hls::stream<pkt512>& m_axis_tcp_tx_data, 
               hls::stream<pkt64>& s_axis_tcp_tx_status,
               ap_uint<16>* sessionID,
               int useConn,
               int expectedTxPkgCnt, 
               int pkgWordCount
                );

void listenPorts (int basePort, int useConn, hls::stream<pkt16>& m_axis_tcp_listen_port, 
               hls::stream<pkt8>& s_axis_tcp_port_status);

void recvData_handshake(int expectedRxByteCnt, 
               hls::stream<pkt128>& s_axis_tcp_notification, 
               hls::stream<pkt32>& m_axis_tcp_read_pkg,
               hls::stream<ap_uint<16> >& rxPacketLength);

void recvData_consumeData(int expectedRxByteCnt, 
               hls::stream<pkt16>& s_axis_tcp_rx_meta, 
               hls::stream<pkt512>& s_axis_tcp_rx_data,
               hls::stream<ap_uint<16> >& rxPacketLength);

void recvData(int expectedRxByteCnt, 
               hls::stream<pkt128>& s_axis_tcp_notification, 
               hls::stream<pkt32>& m_axis_tcp_read_pkg, 
               hls::stream<pkt16>& s_axis_tcp_rx_meta, 
               hls::stream<pkt512>& s_axis_tcp_rx_data );

void tie_off_udp(hls::stream<pkt512>& s_axis_udp_rx, 
               hls::stream<pkt512>& m_axis_udp_tx, 
               hls::stream<pkt256>& s_axis_udp_rx_meta, 
               hls::stream<pkt256>& m_axis_udp_tx_meta );

void tie_off_tcp_listen_port(hls::stream<pkt16>& m_axis_tcp_listen_port, hls::stream<pkt8>& s_axis_tcp_port_status);

void tie_off_tcp_rx(hls::stream<pkt128>& s_axis_tcp_notification, 
               hls::stream<pkt32>& m_axis_tcp_read_pkg, 
               hls::stream<pkt16>& s_axis_tcp_rx_meta, 
               hls::stream<pkt512>& s_axis_tcp_rx_data);

void tie_off_tcp_open_connection(hls::stream<pkt64>& m_axis_tcp_open_connection, 
               hls::stream<pkt32>& s_axis_tcp_open_status);


void tie_off_tcp_tx(hls::stream<pkt32>& m_axis_tcp_tx_meta, 
               hls::stream<pkt512>& m_axis_tcp_tx_data, 
               hls::stream<pkt64>& s_axis_tcp_tx_status);


void tie_off_tcp_close_con(hls::stream<pkt16>& m_axis_tcp_close_connection);



void openConnections(int useConn, int baseIpAddress, int basePort, hls::stream<pkt64>& m_axis_tcp_open_connection, hls::stream<pkt32>& s_axis_tcp_open_status, ap_uint<16>* sessionID)
{
#pragma HLS dataflow

     int numOpenedCon = 0;
     pkt64 openConnection_pkt;
     for (int i = 0; i < useConn; ++i)
     {
     #pragma HLS PIPELINE II=1
          openConnection_pkt.data(31,0) = baseIpAddress;
          openConnection_pkt.data(47,32) = basePort+i;
          m_axis_tcp_open_connection.write(openConnection_pkt);
     }

     openStatus status;
     for (int i = 0; i < useConn; ++i)
     {
     #pragma HLS PIPELINE II=1
          pkt32 open_status_pkt = s_axis_tcp_open_status.read();
          status.sessionID = open_status_pkt.data(15,0);
          status.success = open_status_pkt.data(16,16);

          if (status.success)
          {
               sessionID[numOpenedCon] = status.sessionID;
               numOpenedCon++;
               std::cout << "Connection successfully opened." << std::endl;
          }
     }
}

void sendData(hls::stream<pkt32>& m_axis_tcp_tx_meta, 
               hls::stream<pkt512>& m_axis_tcp_tx_data, 
               hls::stream<pkt64>& s_axis_tcp_tx_status,
               ap_uint<16>* sessionID,
               hls::stream<ap_uint<512> >& s_data_in,
               int useConn,
               int expectedTxPkgCnt, 
               int pkgWordCount
                )
{
     bool first_round = true;
     int sentPkgCnt = 0;

     do{
          pkt32 tx_meta_pkt;
          appTxRsp resp;

          if (first_round)
          {
               
               for (int i = 0; i < useConn; ++i)
               {
               #pragma HLS PIPELINE II=1
                    tx_meta_pkt.data(15,0) = sessionID[i];
                    tx_meta_pkt.data(31,16) = pkgWordCount*(512/8);
                    m_axis_tcp_tx_meta.write(tx_meta_pkt);
               }
               first_round = false;
          }
          else
          {
               if (!s_axis_tcp_tx_status.empty())
               {
                    pkt64 txStatus_pkt = s_axis_tcp_tx_status.read();
                    resp.sessionID = txStatus_pkt.data(15,0);
                    resp.length = txStatus_pkt.data(31,16);
                    resp.remaining_space = txStatus_pkt.data(61,32);
                    resp.error = txStatus_pkt.data(63,62);

                    if (resp.error == 0)
                    {
                         if (sentPkgCnt < expectedTxPkgCnt-1)
                         {
                              tx_meta_pkt.data(15,0) = resp.sessionID;
                              tx_meta_pkt.data(31,16) = pkgWordCount*(512/8);
                              m_axis_tcp_tx_meta.write(tx_meta_pkt);
                         }
                         
                         for (int j = 0; j < pkgWordCount; ++j)
                         {
                         #pragma HLS PIPELINE II=1
                              ap_uint<512> s_data = s_data_in.read();
                              pkt512 currWord;
                              for (int i = 0; i < (512/64); i++) 
                              {
                                   #pragma HLS UNROLL
                                   currWord.data(i*64+63, i*64) = s_data(i*64+63, i*64);
                                   currWord.keep(i*8+7, i*8) = 0xff;
                              }
                              currWord.last = (j == pkgWordCount-1);
                              m_axis_tcp_tx_data.write(currWord);
                         }
                         sentPkgCnt++;

                    }
                    else
                    {
                         //Check if connection  was torn down
                         if (resp.error == 1)
                         {
                              std::cout << "Connection was torn down. " << resp.sessionID << std::endl;
                         }
                         else
                         {
                              tx_meta_pkt.data(15,0) = resp.sessionID;
                              tx_meta_pkt.data(31,16) = pkgWordCount*(512/8);
                              m_axis_tcp_tx_meta.write(tx_meta_pkt);
                         }
                    }
               }
          }
          
     }
     while(sentPkgCnt<expectedTxPkgCnt);
}


void listenPorts (int basePort, int useConn, hls::stream<pkt16>& m_axis_tcp_listen_port, 
               hls::stream<pkt8>& s_axis_tcp_port_status)
{
     #pragma HLS dataflow

     int success_open_port = 0;

     for (int i = 0; i < useConn; ++i)
     {
          pkt16 listen_port_pkt;
          listen_port_pkt.data(15,0) = basePort + i;
          m_axis_tcp_listen_port.write(listen_port_pkt);

          
     }

     for (int i = 0; i < useConn; ++i)
     {
          pkt8 port_status;
          s_axis_tcp_port_status.read(port_status);
          bool success = port_status.data(0,0);
          if (success)
          {
               success_open_port ++;
          }
     }
}

void recvData_handshake(int expectedRxByteCnt, 
               hls::stream<pkt128>& s_axis_tcp_notification, 
               hls::stream<pkt32>& m_axis_tcp_read_pkg,
               hls::stream<ap_uint<16> >& rxPacketLength)
{
     int rxByteCnt = 0;

     do{
          if (!s_axis_tcp_notification.empty())
          {
               pkt128 tcp_notification_pkt = s_axis_tcp_notification.read();
               ap_uint<16> sessionID = tcp_notification_pkt.data(15,0);
               ap_uint<16> length = tcp_notification_pkt.data(31,16);
               ap_uint<32> ipAddress = tcp_notification_pkt.data(63,32);
               ap_uint<16> dstPort = tcp_notification_pkt.data(79,64);
               ap_uint<1> closed = tcp_notification_pkt.data(80,80);

               if (length!=0)
               {
                    pkt32 readRequest_pkt;
                    readRequest_pkt.data(15,0) = sessionID;
                    readRequest_pkt.data(31,16) = length;
                    m_axis_tcp_read_pkg.write(readRequest_pkt);
                    rxPacketLength.write(length);
                    rxByteCnt = rxByteCnt + length;
               }
          }

     }while(rxByteCnt < expectedRxByteCnt);
}

void recvData_consumeData(int expectedRxByteCnt, 
               hls::stream<pkt16>& s_axis_tcp_rx_meta, 
               hls::stream<pkt512>& s_axis_tcp_rx_data,
               hls::stream<ap_uint<16> >& rxPacketLength)
{
     int rxByteCnt = 0;
     ap_uint<16> length;

     do{
          if (!s_axis_tcp_rx_meta.empty() & !rxPacketLength.empty())
          {
               s_axis_tcp_rx_meta.read();
               length = rxPacketLength.read();
               bool lastWord = false;
               do{
                    pkt512 rx_data = s_axis_tcp_rx_data.read();
                    lastWord = rx_data.last;
               }while(lastWord == false);
               rxByteCnt = rxByteCnt + length;
          }

     }while(rxByteCnt < expectedRxByteCnt);
}

void recvData(int expectedRxByteCnt, 
               hls::stream<pkt128>& s_axis_tcp_notification, 
               hls::stream<pkt32>& m_axis_tcp_read_pkg, 
               hls::stream<pkt16>& s_axis_tcp_rx_meta, 
               hls::stream<pkt512>& s_axis_tcp_rx_data )
{
     #pragma HLS dataflow

     hls::stream<ap_uint<16> >    rxPacketLength;
     #pragma HLS STREAM variable=rxPacketLength depth=512

     recvData_handshake(expectedRxByteCnt, 
               s_axis_tcp_notification, 
               m_axis_tcp_read_pkg,
               rxPacketLength);

     recvData_consumeData(expectedRxByteCnt, 
               s_axis_tcp_rx_meta, 
               s_axis_tcp_rx_data,
               rxPacketLength);
}




void tie_off_udp(hls::stream<pkt512>& s_axis_udp_rx, 
               hls::stream<pkt512>& m_axis_udp_tx, 
               hls::stream<pkt256>& s_axis_udp_rx_meta, 
               hls::stream<pkt256>& m_axis_udp_tx_meta )
{
     if (!s_axis_udp_rx.empty())
     {
          pkt512 udp_rx = s_axis_udp_rx.read();
          m_axis_udp_tx.write(udp_rx);
     }

     if (!s_axis_udp_rx_meta.empty())
     {
          pkt256 udp_rx_meta = s_axis_udp_rx_meta.read();
          m_axis_udp_tx_meta.write(udp_rx_meta);
     }
}

void tie_off_tcp_listen_port(hls::stream<pkt16>& m_axis_tcp_listen_port, hls::stream<pkt8>& s_axis_tcp_port_status)
{
     hls::stream<ap_uint<16> > listenPort;
     pkt16 listenPort_pkt;
     if (!listenPort.empty())
     {
          ap_uint<16> listenPort_data = listenPort.read();
          listenPort_pkt.data = listenPort_data;
          m_axis_tcp_listen_port.write(listenPort_pkt);
     }

     if (!s_axis_tcp_port_status.empty())
     {
          pkt8 port_status_pkt = s_axis_tcp_port_status.read();
          bool port_status_data = (port_status_pkt.data == 1) ? true: false;
     }
}

void tie_off_tcp_rx(hls::stream<pkt128>& s_axis_tcp_notification, 
               hls::stream<pkt32>& m_axis_tcp_read_pkg, 
               hls::stream<pkt16>& s_axis_tcp_rx_meta, 
               hls::stream<pkt512>& s_axis_tcp_rx_data)
{
     
     appNotification tcp_notification_data;
     if (!s_axis_tcp_notification.empty())
     {
          pkt128 tcp_notification_pkt = s_axis_tcp_notification.read();
          tcp_notification_data.sessionID = tcp_notification_pkt.data(15,0);
          tcp_notification_data.length = tcp_notification_pkt.data(31,16);
          tcp_notification_data.ipAddress = tcp_notification_pkt.data(63,32);
          tcp_notification_data.dstPort = tcp_notification_pkt.data(79,64);
          tcp_notification_data.closed = tcp_notification_pkt.data(80,80);
     }

     hls::stream<appReadRequest> readRequest;
     pkt32 readRequest_pkt;
     if (!readRequest.empty())
     {
          appReadRequest readRequest_data = readRequest.read();
          readRequest_pkt.data(15,0) = readRequest_data.sessionID;
          readRequest_pkt.data(31,16) = readRequest_data.length;
          m_axis_tcp_read_pkg.write(readRequest_pkt);
     }

     if (!s_axis_tcp_rx_meta.empty())
     {
          pkt16 tcp_rx_meta_pkt = s_axis_tcp_rx_meta.read();
          ap_uint<16> tcp_rx_meta_data = tcp_rx_meta_pkt.data;
     }

     net_axis<512> tcp_rx_data;
     if (!s_axis_tcp_rx_data.empty())
     {
          pkt512 tcp_rx_pkt = s_axis_tcp_rx_data.read();
          tcp_rx_data.data = tcp_rx_pkt.data;
          tcp_rx_data.keep = tcp_rx_pkt.keep;
          tcp_rx_data.last = tcp_rx_pkt.last;
     }

}

void tie_off_tcp_open_connection(hls::stream<pkt64>& m_axis_tcp_open_connection, 
               hls::stream<pkt32>& s_axis_tcp_open_status)
{
     hls::stream<ipTuple> openConnection;
     pkt64 openConnection_pkt;
     if (!openConnection.empty())
     {
          ipTuple openConnection_data = openConnection.read();
          openConnection_pkt.data(31,0) = openConnection_data.ip_address;
          openConnection_pkt.data(47,32) = openConnection_data.ip_port;
          m_axis_tcp_open_connection.write(openConnection_pkt);
     }

     openStatus open_status_data;
     if (!s_axis_tcp_open_status.empty())
     {
          pkt32 open_status_pkt = s_axis_tcp_open_status.read();
          open_status_data.sessionID = open_status_pkt.data(15,0);
          open_status_data.success = open_status_pkt.data(16,16);
     }
}

void tie_off_tcp_tx(hls::stream<pkt32>& m_axis_tcp_tx_meta, 
               hls::stream<pkt512>& m_axis_tcp_tx_data, 
               hls::stream<pkt64>& s_axis_tcp_tx_status)
{
     hls::stream<appTxMeta> txMetaData;
     pkt32 tx_meta_pkt;
     if (!txMetaData.empty())
     {
          appTxMeta tx_meta_data = txMetaData.read();
          tx_meta_pkt.data(15,0) = tx_meta_data.sessionID;
          tx_meta_pkt.data(31,16) = tx_meta_data.length;
          m_axis_tcp_tx_meta.write(tx_meta_pkt);
     }

     hls::stream<net_axis<512> > txData;
     pkt512 txData_pkt;
     if (!txData.empty())
     {
          net_axis<512> tx_data = txData.read();
          txData_pkt.data = tx_data.data;
          txData_pkt.keep = tx_data.keep;
          txData_pkt.last = tx_data.last;
          m_axis_tcp_tx_data.write(txData_pkt);
     }

     appTxRsp tx_status_data;
     if (!s_axis_tcp_tx_status.empty())
     {
          pkt64 txStatus_pkt = s_axis_tcp_tx_status.read();
          tx_status_data.sessionID = txStatus_pkt.data(15,0);
          tx_status_data.length = txStatus_pkt.data(31,16);
          tx_status_data.remaining_space = txStatus_pkt.data(61,32);
          tx_status_data.error = txStatus_pkt.data(63,62);
     }
}
          
void tie_off_tcp_close_con(hls::stream<pkt16>& m_axis_tcp_close_connection)
{
     hls::stream<ap_uint<16> > closeConnection;
     pkt16 close_connection_pkt;
     if (!closeConnection.empty())
     {
          close_connection_pkt.data = closeConnection.read();
          m_axis_tcp_close_connection.write(close_connection_pkt);
     }
}