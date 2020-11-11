/************************************************
Copyright (c) 2018, Systems Group, ETH Zurich.
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

1. Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice,
this list of conditions and the following disclaimer in the documentation
and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors
may be used to endorse or promote products derived from this software
without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
************************************************/
#include "scatter_config.hpp"
#include "scatter.hpp"
#include <iostream>

//Buffers open status coming from the TCP stack
void openStatus_handler(hls::stream<openStatus>&				openConStatus,
							hls::stream<openStatus>&	openConStatusBuffer)
{
#pragma HLS PIPELINE II=1
#pragma HLS INLINE off

	if (!openConStatus.empty())
	{
		openStatus resp = openConStatus.read();
		openConStatusBuffer.write(resp);
	}
}

void txMetaData_handler(hls::stream<appTxMeta>&	txMetaDataBuffer, 
							hls::stream<appTxMeta>& txMetaData)
{
#pragma HLS PIPELINE II=1
#pragma HLS INLINE off

	if (!txMetaDataBuffer.empty())
	{
		appTxMeta metaDataReq = txMetaDataBuffer.read();
		txMetaData.write(metaDataReq);
	}
}


void txStatus_handler(hls::stream<appTxRsp>&	txStatus, 
							hls::stream<appTxRsp>& txStatusBuffer)
{
#pragma HLS PIPELINE II=1
#pragma HLS INLINE off

	if (!txStatus.empty())
	{
		appTxRsp resp = txStatus.read();
		txStatusBuffer.write(resp);
	}
}

//sends out close connection when the whole application finishes
//the connection buffer size should larger than the maximum connection number
void closeConnection_handler(hls::stream<ap_uint<16> >& closeConnectionBuffer,
								hls::stream<ap_uint<16> >&	closeConnection,
								ap_uint<1>		finishExperiment,
								ap_uint<16>		useConn)						
{
#pragma HLS PIPELINE II=1
#pragma HLS INLINE off

	// enum closeConnection_handlerFsmStateType {IDLE, CLOSE_CON};
	// static closeConnection_handlerFsmStateType closeConnection_handlerFsmState = IDLE;

	// static ap_uint<16> closeIt = 0;

	// switch(closeConnection_handlerFsmState)
	// {
	// 	case IDLE:
	// 		closeIt = 0;
	// 		if (finishExperiment)
	// 		{
	// 			closeConnection_handlerFsmState = CLOSE_CON;
	// 		}
	// 		break;
	// 	case CLOSE_CON:
			if (!closeConnectionBuffer.empty())
			{
				ap_uint<16> closeConnectionReq = closeConnectionBuffer.read();
				closeConnection.write(closeConnectionReq);
				// closeIt ++;
			}
	// 		if (closeIt == useConn)
	// 		{
	// 			closeConnection_handlerFsmState = IDLE;
	// 		}
	// 		break;
	// }//switch
	
}


template <int WIDTH>
void client(	hls::stream<ipTuple>&		openConnection,
            	hls::stream<openStatus>& 	openConStatusBuffer,
				hls::stream<ap_uint<16> >&	closeConnectionBuffer,
				hls::stream<appTxMeta>&		txMetaDataBuffer,
				hls::stream<net_axis<WIDTH> >& txData,
				hls::stream<appTxRsp>&	txStatusBuffer,
				ap_uint<1>		runExperiment,
				ap_uint<16>		useConn, //total number of connection
				ap_uint<16>		useIpAddr, //total ip addr used
				ap_uint<16> 	pkgWordCount,
            	ap_uint<16>		regBasePort,
            	ap_uint<16>		expectedRespInKB,
            	// ap_uint<32>		delayedCycles,
            	ap_uint<32>		clientPkgNum,
				ap_uint<32>		regIpAddress0,
				ap_uint<32>		regIpAddress1,
				ap_uint<32>		regIpAddress2,
				ap_uint<32>		regIpAddress3,
				ap_uint<32>		regIpAddress4,
				ap_uint<32>		regIpAddress5,
				ap_uint<32>		regIpAddress6,
				ap_uint<32>		regIpAddress7,
				ap_uint<32>		regIpAddress8,
				ap_uint<32>		regIpAddress9,
				ap_uint<32>		regIpAddress10
				)
{
#pragma HLS PIPELINE II=1
#pragma HLS INLINE off

	enum scatterFsmStateType {IDLE, INIT_CON, WAIT_CON, CHECK_REQ, WRITE_PKG, CLOSE_CON};
	static scatterFsmStateType scatterFsmState = IDLE;

	static ap_uint<16> numConnections = 0;
	static ap_uint<16> currentSessionID;
	static ap_uint<16> sessionIt = 0;
	static ap_uint<16> closeIt = 0;
	static ap_uint<16> wordCount = 0;
	static ap_uint<16> ipAddressIdx = 0;
	static ap_uint<16> currentPort;
	// static ap_uint<32> delayedCyclesCnt = 0;
	static ap_uint<32> clientPkgCnt = 0;	
	static bool sentFirstWord = false;

	//support max 128 connections
	ap_uint<16> sessionIDTable [128];

	/*
	 * CLIENT FSM
	 */
	switch (scatterFsmState)
	{
	case IDLE:
		sessionIt = 0;
		closeIt = 0;
		numConnections = 0;
		ipAddressIdx = 0;
		currentPort = 0;
		// delayedCyclesCnt = 0;
		clientPkgCnt = 0;
		sentFirstWord = false;
		if (runExperiment)
		{
			scatterFsmState = INIT_CON;
			currentPort = regBasePort;
		}
		break;
	case INIT_CON:
		if (sessionIt < useConn)
		{
			ipTuple openTuple;
			switch (ipAddressIdx)
			{
			case 0:
				openTuple.ip_address = regIpAddress0;
				break;
			case 1:
				openTuple.ip_address = regIpAddress1;
				break;
			case 2:
				openTuple.ip_address = regIpAddress2;
				break;
			case 3:
				openTuple.ip_address = regIpAddress3;
				break;
			case 4:
				openTuple.ip_address = regIpAddress4;
				break;
			case 5:
				openTuple.ip_address = regIpAddress5;
				break;
			case 6:
				openTuple.ip_address = regIpAddress6;
				break;
			case 7:
				openTuple.ip_address = regIpAddress7;
				break;
			case 8:
				openTuple.ip_address = regIpAddress8;
				break;
			case 9:
				openTuple.ip_address = regIpAddress9;
				break;
			case 10:
				openTuple.ip_address = regIpAddress10;
				break;
			}
			openTuple.ip_port = currentPort;
			openConnection.write(openTuple);
			ipAddressIdx++;
			if (ipAddressIdx == useIpAddr)
			{
 				ipAddressIdx = 0;
 				currentPort++;
			}
		}
		sessionIt++;
		if (sessionIt == useConn)
		{
			sessionIt = 0;
			currentPort = 0;
			scatterFsmState = WAIT_CON;
		}
		break;
	case WAIT_CON:
		if (!openConStatusBuffer.empty())
		{
			openStatus status = openConStatusBuffer.read();
			if (status.success)
			{
				std::cout << "Connection successfully opened." << std::endl;
				txMetaDataBuffer.write(appTxMeta(status.sessionID, pkgWordCount*(WIDTH/8)));
				sessionIDTable[numConnections] = status.sessionID;
				numConnections++;

			}
			else
			{
				std::cout << "Connection could not be opened." << std::endl;
			}
			sessionIt++;
			if (sessionIt == useConn) 
			{
				sessionIt = 0;
				scatterFsmState = CHECK_REQ;
			}
		}
		break;
	case CHECK_REQ:
		if (!txStatusBuffer.empty())
		{
			appTxRsp resp = txStatusBuffer.read();
			if (resp.error == 0)
			{
				currentSessionID = resp.sessionID;
				scatterFsmState = WRITE_PKG;
			}
			else
			{
				//Check if connection  was torn down
				if (resp.error == 1)
				{
					std::cout << "Connection was torn down. " << resp.sessionID << std::endl;
					numConnections--;
				}
				else
				{
					txMetaDataBuffer.write(appTxMeta(resp.sessionID, pkgWordCount*(WIDTH/8)));
				}
			}
		}
		break;
	case WRITE_PKG:
	{
		wordCount++;
		net_axis<WIDTH> currWord;
		if ((sentFirstWord == false) & (clientPkgCnt < (clientPkgNum -1)))
		{
			txMetaDataBuffer.write(appTxMeta(currentSessionID, pkgWordCount*(WIDTH/8)));
			sentFirstWord = true;
		}
		for (int i = 0; i < (WIDTH/64); i++) 
		{
			#pragma HLS UNROLL
			currWord.data(i*64+63, i*64) = expectedRespInKB;
			currWord.keep(i*8+7, i*8) = 0xff;
		}
		currWord.last = (wordCount == pkgWordCount);
		txData.write(currWord);
		if (currWord.last)
		{
			wordCount = 0;
			clientPkgCnt++;
			sentFirstWord = false;
			if (clientPkgCnt == clientPkgNum)
			{
				clientPkgCnt = 0;
				scatterFsmState = CLOSE_CON;
			}
			else
			{
				scatterFsmState = CHECK_REQ;
			}
		}
	}
		break;
	case CLOSE_CON:
		if (closeIt == numConnections)
		{
			scatterFsmState = IDLE;
		}
		else
		{
			ap_uint<16> closeSessionID = sessionIDTable[closeIt];
			closeConnectionBuffer.write(closeSessionID);
			closeIt++;
		
			if (closeIt != numConnections)
			{
				scatterFsmState = CLOSE_CON;
			}
		}
		break;
	} //switch
	
}

template <int WIDTH>
void server(	hls::stream<ap_uint<16> >&		listenPort,
				hls::stream<bool>&				listenPortStatus,
				hls::stream<appNotification>&	notifications,
				hls::stream<appReadRequest>&	readRequest,
				hls::stream<ap_uint<16> >&		rxMetaData,
				hls::stream<net_axis<WIDTH> >&	rxData,

				ap_uint<1>		runExperiment,
				ap_uint<16>		usePort, //total number of listen port
            	ap_uint<16>		regBasePort)
{
	#pragma HLS PIPELINE II=1
	#pragma HLS INLINE off

   	enum listenFsmStateType {IDLE, OPEN_PORT, WAIT_PORT_STATUS};
   	static listenFsmStateType listenState = IDLE;
	enum consumeFsmStateType {WAIT_PKG, CONSUME};
	static consumeFsmStateType  serverFsmState = WAIT_PKG;
	#pragma HLS RESET variable=listenState


	static ap_uint<16> currentPort = 0;
	static ap_uint<16> openedPort = 0;

	switch (listenState)
	{
	case IDLE:
		currentPort = 0;
		openedPort = 0;
		if (runExperiment)
		{
			currentPort = regBasePort;
			listenState = OPEN_PORT;
		}

		break;
	case OPEN_PORT:
		// Open Port 
		listenPort.write(currentPort);
		listenState = WAIT_PORT_STATUS;
		std::cout << "Open listen request on port "<< currentPort<< std::endl;
		break;
	case WAIT_PORT_STATUS:
		if (!listenPortStatus.empty())
		{
			bool open = listenPortStatus.read();
			if (!open)
			{
				listenState = OPEN_PORT;
				std::cout << "failed open listen port "<< currentPort<< std::endl;
			}
			else
			{
				std::cout << "successfully open listen port "<< currentPort<< std::endl;
				currentPort++;
				openedPort ++;
				if (openedPort == usePort)
				{
					listenState = IDLE;
					openedPort = 0;
					currentPort = 0;
				}
				else
					listenState = OPEN_PORT;
			}
		}
		break;
	}
	
	if (!notifications.empty())
	{
		appNotification notification = notifications.read();

		if (notification.length != 0)
		{
			readRequest.write(appReadRequest(notification.sessionID, notification.length));
		}
	}

	switch (serverFsmState)
	{
	case WAIT_PKG:
		if (!rxMetaData.empty() && !rxData.empty())
		{
			rxMetaData.read();
			net_axis<WIDTH> receiveWord = rxData.read();
			if (!receiveWord.last)
			{
				serverFsmState = CONSUME;
			}
		}
		break;
	case CONSUME:
		if (!rxData.empty())
		{
			net_axis<WIDTH> receiveWord = rxData.read();
			if (receiveWord.last)
			{
				serverFsmState = WAIT_PKG;
			}
		}
		break;
	}
}




void scatter(	hls::stream<ap_uint<16> >& listenPort,
					hls::stream<bool>& listenPortStatus,
					hls::stream<appNotification>& notifications,
					hls::stream<appReadRequest>& readRequest,
					hls::stream<ap_uint<16> >& rxMetaData,
					hls::stream<net_axis<DATA_WIDTH> >& rxData,
					hls::stream<ipTuple>& openConnection,
					hls::stream<openStatus>& openConStatus,
					hls::stream<ap_uint<16> >& closeConnection,
					hls::stream<appTxMeta>& txMetaData,
					hls::stream<net_axis<DATA_WIDTH> >& txData,
					hls::stream<appTxRsp>& txStatus,
					ap_uint<1>		runExperiment,
					ap_uint<16>		useConn,
					ap_uint<16>		useIpAddr,
					ap_uint<16>		pkgWordCount,
					ap_uint<16>		regBasePort,
					ap_uint<16>		usePort,
					ap_uint<16>		expectedRespInKB,
					ap_uint<1>		finishExperiment,
	            	// ap_uint<32>		delayedCycles,
	            	ap_uint<32> 	clientPkgNum,
					ap_uint<32>		regIpAddress0,
					ap_uint<32>		regIpAddress1,
					ap_uint<32>		regIpAddress2,
					ap_uint<32>		regIpAddress3,
					ap_uint<32>		regIpAddress4,
					ap_uint<32>		regIpAddress5,
					ap_uint<32>		regIpAddress6,
					ap_uint<32>		regIpAddress7,
					ap_uint<32>		regIpAddress8,
					ap_uint<32>		regIpAddress9,
					ap_uint<32>		regIpAddress10)

{
	#pragma HLS DATAFLOW disable_start_propagation
	#pragma HLS INTERFACE ap_ctrl_none port=return

	#pragma HLS INTERFACE axis register port=listenPort name=m_axis_listen_port
	#pragma HLS INTERFACE axis register port=listenPortStatus name=s_axis_listen_port_status

	#pragma HLS INTERFACE axis register port=notifications name=s_axis_notifications
	#pragma HLS INTERFACE axis register port=readRequest name=m_axis_read_package
	#pragma HLS DATA_PACK variable=notifications
	#pragma HLS DATA_PACK variable=readRequest

	#pragma HLS INTERFACE axis register port=rxMetaData name=s_axis_rx_metadata
	#pragma HLS INTERFACE axis register port=rxData name=s_axis_rx_data

	#pragma HLS INTERFACE axis register port=openConnection name=m_axis_open_connection
	#pragma HLS INTERFACE axis register port=openConStatus name=s_axis_open_status
	#pragma HLS DATA_PACK variable=openConnection
	#pragma HLS DATA_PACK variable=openConStatus

	#pragma HLS INTERFACE axis register port=closeConnection name=m_axis_close_connection

	#pragma HLS INTERFACE axis register port=txMetaData name=m_axis_tx_metadata
	#pragma HLS INTERFACE axis register port=txData name=m_axis_tx_data
	#pragma HLS INTERFACE axis register port=txStatus name=s_axis_tx_status
	#pragma HLS DATA_PACK variable=txMetaData
	#pragma HLS DATA_PACK variable=txStatus



	#pragma HLS INTERFACE ap_none register port=runExperiment
	#pragma HLS INTERFACE ap_none register port=useConn
	#pragma HLS INTERFACE ap_none register port=pkgWordCount
	#pragma HLS INTERFACE ap_none register port=useIpAddr
	#pragma HLS INTERFACE ap_none register port=regBasePort
	#pragma HLS INTERFACE ap_none register port=usePort
	#pragma HLS INTERFACE ap_none register port=expectedRespInKB
	#pragma HLS INTERFACE ap_none register port=finishExperiment
	// #pragma HLS INTERFACE ap_none register port=delayedCycles
	#pragma HLS INTERFACE ap_none register port=clientPkgNum
	#pragma HLS INTERFACE ap_none register port=regIpAddress0
	#pragma HLS INTERFACE ap_none register port=regIpAddress1
	#pragma HLS INTERFACE ap_none register port=regIpAddress2
	#pragma HLS INTERFACE ap_none register port=regIpAddress3
	#pragma HLS INTERFACE ap_none register port=regIpAddress4
	#pragma HLS INTERFACE ap_none register port=regIpAddress5
	#pragma HLS INTERFACE ap_none register port=regIpAddress6
	#pragma HLS INTERFACE ap_none register port=regIpAddress7
	#pragma HLS INTERFACE ap_none register port=regIpAddress8
	#pragma HLS INTERFACE ap_none register port=regIpAddress9
	#pragma HLS INTERFACE ap_none register port=regIpAddress10

	static hls::stream<openStatus>	openConStatusBuffer("openConStatusBuffer");
	#pragma HLS STREAM variable=openConStatusBuffer depth=512

	static hls::stream<appTxMeta>	txMetaDataBuffer("txMetaDataBuffer");
	#pragma HLS STREAM variable=txMetaDataBuffer depth=512

	static hls::stream<appTxRsp>	txStatusBuffer("txStatusBuffer");
	#pragma HLS STREAM variable=txStatusBuffer depth=512

	static hls::stream<ap_uint<16> >	closeConnectionBuffer("closeConnectionBuffer");
	#pragma HLS STREAM variable=closeConnectionBuffer depth=512

	/*
	 * Client
	 */

	openStatus_handler(openConStatus, openConStatusBuffer);
	txStatus_handler(txStatus, txStatusBuffer);

	client<DATA_WIDTH>(	openConnection,
			openConStatusBuffer,
			closeConnectionBuffer,
			txMetaDataBuffer,
			txData,
			txStatusBuffer,
			runExperiment,
			useConn,
			useIpAddr,
			pkgWordCount,
			regBasePort,
			expectedRespInKB,
			// delayedCycles,
			clientPkgNum,
			regIpAddress0,
			regIpAddress1,
			regIpAddress2,
			regIpAddress3,
			regIpAddress4,
			regIpAddress5,
			regIpAddress6,
			regIpAddress7,
			regIpAddress8,
			regIpAddress9,
			regIpAddress10);

	txMetaData_handler(txMetaDataBuffer, txMetaData);
	closeConnection_handler(closeConnectionBuffer, closeConnection, finishExperiment, useConn);
	/*
	 * Server
	 */
	server<DATA_WIDTH>(	listenPort,
			listenPortStatus,
			notifications,
			readRequest,
			rxMetaData,
			rxData,
			runExperiment,
			usePort, //total number of listen port
            regBasePort);

}
