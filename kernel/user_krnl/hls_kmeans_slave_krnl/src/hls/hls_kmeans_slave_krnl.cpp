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

#include <assert.h>
#include <stdio.h>
#include <string.h>
#include <iostream>

#define DIMENSION_MAX 256
#define CENTERS_MAX  16
#define FP_MAX 256
// #define BUFFER_SIZE ((DIMENSION_MAX * CENTERS_MAX * 4 + CENTERS_MAX * 4 + 1023) / 1024) * 16
#define BUFFER_SIZE 2048

typedef ap_ufixed<32,1,AP_RND_ZERO,AP_SAT> data_cp;
typedef ap_ufixed<64,33,AP_RND_ZERO,AP_SAT> data_s;
typedef ap_fixed<32,8,AP_RND_ZERO,AP_SAT> data_d;
typedef int data_l;

typedef struct data_d8_struct{
    data_d dist[CENTERS_MAX];
} data_d8;


static void rd_point(data_cp *minibatch_gmem_buf_0, 
                        hls::stream<data_cp> &d_from_rd_point_to_cal_dist,
                        hls::stream<data_cp> &d_from_rd_point_to_upd_sum_n_len,
                        int ExNb, 
                        int Bt,
                        int Nb,
                        int D) {

    int actual_batch_index = 0; // which batch of the data set
    for (int actual_iter_index = 0; actual_iter_index < ExNb; actual_iter_index++){
        #pragma HLS loop_flatten off
        int bias = actual_batch_index * Bt * D;
        int BtxD_plus_bias = bias + Bt * D;
        for (int i = bias; i < BtxD_plus_bias; i++){
            #pragma HLS PIPELINE II=1  
            data_cp tmp_point_1d= minibatch_gmem_buf_0[i]; // read one dimension from the HBM
            //data_cp tmp_point_1d = tmp_index>>31;
            d_from_rd_point_to_cal_dist << tmp_point_1d; // send this dimension to cal_index function through fifo
            d_from_rd_point_to_upd_sum_n_len << tmp_point_1d; // send this dimension to upd_sum_n_len function through fifo 
        }
        if (actual_batch_index == Nb - 1){ // if all points of one batch is read in, set actual_batch_index 0
            actual_batch_index = 0;
        }
        else{
            actual_batch_index++;
        }        
    }
}


static void cal_dist(hls::stream<data_cp> &d_from_rd_point_to_cal_dist,
                hls::stream<data_d8> &dist_from_cal_dist_to_cal_index,
                data_cp center[][CENTERS_MAX],
                int Bt,
                int D){

    static data_d dist_0[CENTERS_MAX]; // to keep value，must be static
    static data_d dist_1[CENTERS_MAX];
    #pragma HLS ARRAY_PARTITION variable=dist_0 complete
    #pragma HLS ARRAY_PARTITION variable=dist_1 complete

    data_cp center_1d[CENTERS_MAX];
    #pragma HLS ARRAY_PARTITION variable=center_1d complete

    data_d8 tmp_dist8;
    #pragma HLS ARRAY_PARTITION variable=tmp_dist8.dist complete

    ap_uint<1> flag = 0;
    for (int i = 0; i < Bt * D; i++){ // process all dimensions of all points in one batch    
        #pragma HLS PIPELINE II=1     
        data_cp point_1d = d_from_rd_point_to_cal_dist.read(); // read one dimension from rd_point function through fifo

        int actual_d_index = i % D;

        for (int j = 0; j < CENTERS_MAX; j++){  
            #pragma HLS UNROLL
            center_1d[j] = center[actual_d_index][j]; // fetch one dimension of all centers from center array(bram)
        } 
        for (int k = 0; k < CENTERS_MAX; k++){  // calculate and accumulate distance
            #pragma HLS UNROLL
            data_d tmp_cal = point_1d - center_1d[k]; 
            data_d tmp_cal2 = tmp_cal * tmp_cal;
            if (flag == 1){
                dist_0[k] = dist_1[k] + tmp_cal2;
            }
            else{
                dist_1[k] = dist_0[k] + tmp_cal2;
            }
        }

        if (flag == 1){
            flag = 0;
        }
        else{
            flag = 1;
        }        

        if (actual_d_index == D - 1){ // if all dimensions of one point is processed, set actual_d_index 0 and find which center the point is closest to
            for (int k = 0; k < CENTERS_MAX; k++){  // calculate and accumulate distance
                #pragma HLS UNROLL
                tmp_dist8.dist[k] = (flag == 0) ? dist_0[k] : dist_1[k];
                dist_0[k] = 0;
                dist_1[k] = 0;
            }
            dist_from_cal_dist_to_cal_index << tmp_dist8; // send the index of the closest center to upd_sum_n_len function through fifo
        }
    }
}


static void cal_index(hls::stream<data_d8> &dist_from_cal_dist_to_cal_index,
                hls::stream<int> &index_from_cal_index_to_upd_sum_n_len,
                int Bt,
                int C){

    static data_d8 dist8;
    #pragma HLS ARRAY_PARTITION variable=dist8.dist complete

    static int min_index;
    static data_d min_dist; 

    for (int i = 0; i < Bt * C; i++){ // process all dimensions of all points in one batch    
        #pragma HLS PIPELINE II=1     

        int actual_center_index = i % C;

        if (actual_center_index == 0){
            dist8 = dist_from_cal_dist_to_cal_index.read();
            min_index = 0;
            min_dist = FP_MAX; 
        }

        data_d tmp_d = dist8.dist[actual_center_index];
        min_index = (tmp_d < min_dist) ? actual_center_index : min_index;
        min_dist = (tmp_d < min_dist) ? tmp_d : min_dist;

        if (actual_center_index == C - 1){
            index_from_cal_index_to_upd_sum_n_len << min_index; // send the index of the closest center to upd_sum_n_len function through fifo
        }
    }
}


static void upd_sum_n_len(hls::stream<data_cp> &d_from_rd_point_to_upd_sum_n_len,
                    hls::stream<int> &index_from_cal_index_to_upd_sum_n_len,
                    data_s sum[][CENTERS_MAX],
                    data_l len[],
                    int Bt,
                    int D){

    static int min_index = 0; // for min_index should keep its value within D clocks, it should be static
    int actual_d_index = 0;

    for (int i = 0; i < Bt * D; i++){ // process all dimensions of all points in one batch    
        #pragma HLS PIPELINE II=1     
        #pragma HLS DEPENDENCE variable=sum inter false
        #pragma HLS DEPENDENCE variable=len inter false
        if (actual_d_index == 0){ // before updating sum with the first dimension of each point, read the index of the closest center and meanwhile update len
            min_index = index_from_cal_index_to_upd_sum_n_len.read();
            len[min_index]++;
        }
        data_cp point_1d = d_from_rd_point_to_upd_sum_n_len.read(); // read one dimension from rd_points function through fifo
        sum[actual_d_index][min_index] += point_1d;
        if (actual_d_index == D - 1){
            actual_d_index = 0;
        }
        else{
            actual_d_index++;
        }
    }
}


static void upd_center(data_s sum[][CENTERS_MAX],
                        data_l len[], 
                        data_cp center[][CENTERS_MAX],
                        int C,
                        int D){
    for (int i = 0; i < D ; i++){
        for (int j = 0; j < CENTERS_MAX; j++){
            #pragma HLS PIPELINE II=1
            data_l tmp_len = len[j];
            data_s tmp_sum = sum[i][j];
            if (j < C && tmp_len > 0){
                data_cp tmp_c = tmp_sum / tmp_len;
                center[i][j] = tmp_c;
            }
            sum[i][j] = 0;
        } 
    }    
    for (int j = 0; j < CENTERS_MAX; j++){
        #pragma HLS PIPELINE II=1
        len[j] = 0;
    }     
}


static void cal_dist_n_cal_index_n_upd_sum_n_len(hls::stream<data_cp> &d_from_rd_point_to_cal_dist,
                                    hls::stream<data_cp> &d_from_rd_point_to_upd_sum_n_len,
                                    data_s sum[][CENTERS_MAX],
                                    data_l len[], 
                                    data_cp center[][CENTERS_MAX],
                                    int Bt,
                                    int C,
                                    int D){

        static hls::stream<data_d8> dist_from_cal_dist_to_cal_index;
        #pragma HLS stream variable = dist_from_cal_dist_to_cal_index depth = 1024
        #pragma HLS DATA_PACK variable = dist_from_cal_dist_to_cal_index

        static hls::stream<int> index_from_cal_index_to_upd_sum_n_len;
        #pragma HLS stream variable = index_from_cal_index_to_upd_sum_n_len depth = 1024

        #pragma HLS dataflow
        cal_dist(d_from_rd_point_to_cal_dist,
                dist_from_cal_dist_to_cal_index,
                center,
                Bt,
                D);
        cal_index(dist_from_cal_dist_to_cal_index,
                index_from_cal_index_to_upd_sum_n_len,
                Bt,
                C);
        upd_sum_n_len(d_from_rd_point_to_upd_sum_n_len,
                index_from_cal_index_to_upd_sum_n_len,
                sum,
                len,
                Bt,
                D);    
}


static void cluster(data_cp *merge_gmem_buf, 
                    hls::stream<data_cp> &d_from_rd_point_to_cal_dist,
                    hls::stream<data_cp> &d_from_rd_point_to_upd_sum_n_len,
                    data_s sum[][CENTERS_MAX],
                    data_l len[], 
                    data_cp center[][CENTERS_MAX],
                    int ExNb, 
                    int Bt,
                    int Nb,
                    int C,
                    int D) {

    

    // clean len/sum array and read centers from HBM
    for (int i = 0; i < D; i++){
        len[i] = 0;
        for (int k = 0; k < CENTERS_MAX; k++){
            #pragma HLS PIPELINE II=1
            if (k < C){
                data_cp tmp_c = merge_gmem_buf[k * D + i];
                center[i][k] = tmp_c;
            }
            else{
                center[i][k] = 0;
            }
            sum[i][k] = 0;
        }
    }
    // printf("ExNb:%d\n", ExNb);
    // int actual_batch_index = 0;
    // for (int actual_iter_index = 0; actual_iter_index < ExNb; actual_iter_index++){

    cal_dist_n_cal_index_n_upd_sum_n_len(d_from_rd_point_to_cal_dist, // include cal_index function and upd_sum_n_len function
                            d_from_rd_point_to_upd_sum_n_len, // cal_dist_n_cal_index_n_upd_sum_n_len function just opens an area for dataflow
                            sum, len, center,
                            Bt, C, D);

    // upd_center(sum, len, center, C, D);

    // // if (actual_batch_index == Nb - 1){
    // //     actual_batch_index = 0;
    // // }
    // // else{
    // //     actual_batch_index++;
    // // }        
    // // }

    // // write centers to HBM
    // for (int i = 0; i < D; i++){
    //     for (int k = 0; k < C; k++){
    //         #pragma HLS PIPELINE II=1
    //         merge_gmem_buf[k * D + i] = center[i][k];
    //     }
    // }    
}    

static void write_result(data_cp *merge_gmem_buf, data_cp center[][CENTERS_MAX], int D, int C)
{
    // write centers to HBM
    for (int i = 0; i < D; i++){
        for (int k = 0; k < C; k++){
            #pragma HLS PIPELINE II=1
            merge_gmem_buf[k * D + i] = center[i][k];
        }
    }    
} 

static void read_and_cluster_assign(
                    data_cp *minibatch_gmem_buf_0, 
                    data_cp *merge_gmem_buf, 
                    hls::stream<data_cp> &d_from_rd_point_to_cal_dist,
                    hls::stream<data_cp> &d_from_rd_point_to_upd_sum_n_len,
                    data_s sum[][CENTERS_MAX],
                    data_l len[], 
                    data_cp center[][CENTERS_MAX],
                    int ExNb, 
                    int Bt,
                    int Nb,
                    int C,
                    int D )
{
    #pragma HLS dataflow
    // read points from HBM
    rd_point(minibatch_gmem_buf_0, 
                d_from_rd_point_to_cal_dist,
                d_from_rd_point_to_upd_sum_n_len,
                ExNb,
                Bt,
                Nb,
                D);
    // calculate index and update sum/len/center
    cluster(merge_gmem_buf, 
            d_from_rd_point_to_cal_dist,
            d_from_rd_point_to_upd_sum_n_len,
            sum,
            len,
            center,
            ExNb, 
            Bt,
            Nb,
            C,
            D);
} 


extern "C" {
void hls_kmeans_slave_krnl(data_cp *minibatch_gmem_buf_0,
            data_cp *merge_gmem_buf, 
            int N, int C, int D,
            int E, int B, int Bt,
            int Nb, int ExNb,
            int useConn, 
            int listenPort, 
            int expectedRxByteCnt,
            int destIpAddress,
            int destPort,
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
          hls::stream<pkt64>& s_axis_tcp_tx_status
          ) {

    // N = number of points in the data set (temporarily no used)
    // C = number of centers
    // D = number of features(dimensions) of one point or one center
    // E = number of epochs (temporarily no used)
    // B = batch size (temporarily no used)
    // Bt = batch size each thread (temporarily thread = 1 so Bt = B)
    // Nb = number of batches in the data set
    // ExNb = number of epochs(E) x number of batches(Nb)


    #pragma HLS INTERFACE m_axi port = minibatch_gmem_buf_0 offset = slave bundle = gmem0
    #pragma HLS INTERFACE m_axi port = merge_gmem_buf offset = slave bundle = gmem1

    #pragma HLS INTERFACE s_axilite port=N bundle = control
    #pragma HLS INTERFACE s_axilite port=C bundle = control
    #pragma HLS INTERFACE s_axilite port=D bundle = control
    #pragma HLS INTERFACE s_axilite port=E bundle = control
    #pragma HLS INTERFACE s_axilite port=B bundle = control
    #pragma HLS INTERFACE s_axilite port=Bt bundle = control
    #pragma HLS INTERFACE s_axilite port=Nb bundle = control
    #pragma HLS INTERFACE s_axilite port=ExNb bundle = control

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

    static hls::stream<data_cp> d_from_rd_point_to_cal_dist;
    #pragma HLS stream variable = d_from_rd_point_to_cal_dist depth = 1024

    static hls::stream<data_cp> d_from_rd_point_to_upd_sum_n_len;
    #pragma HLS stream variable = d_from_rd_point_to_upd_sum_n_len depth = 1024

    static data_cp center[DIMENSION_MAX][CENTERS_MAX]; 
    static data_l len[CENTERS_MAX];
    static data_s sum[DIMENSION_MAX][CENTERS_MAX];

    #pragma HLS ARRAY_PARTITION variable=center dim=2 complete
    //#pragma HLS ARRAY_PARTITION variable=len complete
    //#pragma HLS ARRAY_PARTITION variable=sum dim=2 complete

    #pragma HLS RESOURCE variable=center core=RAM_2P_BRAM
    #pragma HLS RESOURCE variable=len core=RAM_2P_BRAM
    #pragma HLS RESOURCE variable=sum core=RAM_2P_BRAM

    static ap_uint<512> result [BUFFER_SIZE];

    ap_uint<16> sessionTable [32];
    int pkgWordCount = 16;

    openConnections( useConn, destIpAddress, destPort, m_axis_tcp_open_connection, s_axis_tcp_open_status, sessionTable);

    read_and_cluster_assign(
                    minibatch_gmem_buf_0, 
                    merge_gmem_buf, 
                    d_from_rd_point_to_cal_dist,
                    d_from_rd_point_to_upd_sum_n_len,
                    sum,
                    len, 
                    center,
                    ExNb, 
                    Bt,
                    Nb,
                    C,
                    D );

    sendDataPtr( m_axis_tcp_tx_meta, 
        m_axis_tcp_tx_data, 
        s_axis_tcp_tx_status, 
        result, 
        sessionTable, 
        useConn, 
        expectedRxByteCnt, 
        pkgWordCount);

    recvDataPtr(expectedRxByteCnt, 
           result,
           s_axis_tcp_notification, 
           m_axis_tcp_read_pkg, 
           s_axis_tcp_rx_meta, 
           s_axis_tcp_rx_data );

    sendDataPtr( m_axis_tcp_tx_meta, 
        m_axis_tcp_tx_data, 
        s_axis_tcp_tx_status, 
        result, 
        sessionTable, 
        useConn, 
        expectedRxByteCnt, 
        pkgWordCount);

    recvDataPtr(expectedRxByteCnt, 
           result,
           s_axis_tcp_notification, 
           m_axis_tcp_read_pkg, 
           s_axis_tcp_rx_meta, 
           s_axis_tcp_rx_data );

    sendDataPtr( m_axis_tcp_tx_meta, 
        m_axis_tcp_tx_data, 
        s_axis_tcp_tx_status, 
        result, 
        sessionTable, 
        useConn, 
        expectedRxByteCnt, 
        pkgWordCount);

    recvDataPtr(expectedRxByteCnt, 
           result,
           s_axis_tcp_notification, 
           m_axis_tcp_read_pkg, 
           s_axis_tcp_rx_meta, 
           s_axis_tcp_rx_data );

    sendDataPtr( m_axis_tcp_tx_meta, 
        m_axis_tcp_tx_data, 
        s_axis_tcp_tx_status, 
        result, 
        sessionTable, 
        useConn, 
        expectedRxByteCnt, 
        pkgWordCount);

    recvDataPtr(expectedRxByteCnt, 
           result,
           s_axis_tcp_notification, 
           m_axis_tcp_read_pkg, 
           s_axis_tcp_rx_meta, 
           s_axis_tcp_rx_data );

    // static int iter = (expectedRxByteCnt + 65535) >> 16;
    // int remainingByte = expectedRxByteCnt;
    // int currentByte = 0;

    // for (int i = 0; i < iter; ++i)
    // {
    //     if (remainingByte >= 65536)
    //     {
    //         currentByte = 65536;
    //         remainingByte = remainingByte - 65536;
    //     }
    //     else{
    //         currentByte = remainingByte;
    //         remainingByte = 0;
    //     }

    //     sendDataPtr( m_axis_tcp_tx_meta, 
    //     m_axis_tcp_tx_data, 
    //     s_axis_tcp_tx_status, 
    //     result, 
    //     sessionTable, 
    //     useConn, 
    //     currentByte, 
    //     pkgWordCount);

    //     recvDataPtr(currentByte, 
    //            result,
    //            s_axis_tcp_notification, 
    //            m_axis_tcp_read_pkg, 
    //            s_axis_tcp_rx_meta, 
    //            s_axis_tcp_rx_data );
    // }

    
   

    upd_center(sum, len, center, C, D);

    write_result(merge_gmem_buf, center, D, C);


    //tie off network interface
    tie_off_udp(s_axis_udp_rx, 
               m_axis_udp_tx, 
               s_axis_udp_rx_meta, 
               m_axis_udp_tx_meta);


     tie_off_tcp_listen_port( m_axis_tcp_listen_port, 
          s_axis_tcp_port_status);

     
     // tie_off_tcp_rx(s_axis_tcp_notification, 
     //      m_axis_tcp_read_pkg, 
     //      s_axis_tcp_rx_meta, 
     //      s_axis_tcp_rx_data);

     // tie_off_tcp_open_connection(m_axis_tcp_open_connection, 
     //           s_axis_tcp_open_status);


     // tie_off_tcp_tx(m_axis_tcp_tx_meta, 
     //                m_axis_tcp_tx_data, 
     //                s_axis_tcp_tx_status);

     tie_off_tcp_close_con(m_axis_tcp_close_connection);
}
}
