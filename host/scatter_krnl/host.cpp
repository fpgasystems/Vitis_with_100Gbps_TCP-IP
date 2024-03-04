/**********
Copyright (c) 2019, Xilinx, Inc.
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
**********/
#include "xcl2.hpp"
#include <vector>
#include <chrono>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <cstdlib>
#include <sstream>
#include <iomanip> // For std::hex
#include <cstdint> // For uint64_t

#define DATA_SIZE 62500000

void wait_for_enter(const std::string &msg) {
    std::cout << msg << std::endl;
    std::cin.ignore(std::numeric_limits<std::streamsize>::max(), '\n');
}

uint32_t getIpEnv() {
    const char* env_var = getenv("DEVICE_1_IP_ADDRESS_HEX_0");

    if (env_var == NULL) {
        std::cerr << "Environment variable is not set." << std::endl;
        return 0; // Or handle the error as appropriate
    }

    uint32_t value;
    std::stringstream ss;

    ss << std::hex << env_var;
    if (!(ss >> value)) {
        std::cerr << "Failed to parse IP address." << std::endl;
        return 0; // Or handle the parsing error as appropriate
    }

    return value;
}

uint64_t getMacEnv() {
    const char* env_var = getenv("DEVICE_1_MAC_ADDRESS_0");

    if (env_var == NULL) {
        std::cerr << "Environment variable is not set." << std::endl;
        return 0; // Or handle the error as appropriate
    }

    uint64_t value;
    std::stringstream ss;

    ss << std::hex << env_var;
    if (!(ss >> value)) {
        std::cerr << "Failed to parse MAC address." << std::endl;
        return 0; // Or handle the parsing error as appropriate
    }

    return value;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " <XCLBIN File> [<IP address in format 10.1.212.121> <Base Port> <#Connection> <#Tx Pkg>]" << std::endl;
        return EXIT_FAILURE;
    }

    std::string binaryFile = argv[1];

    cl_int err;
    cl::CommandQueue q;
    cl::Context context;

    cl::Kernel user_kernel;
    cl::Kernel network_kernel;

    auto size = DATA_SIZE;
    
    //Allocate Memory in Host Memory
    auto vector_size_bytes = sizeof(int) * size;
    std::vector<int, aligned_allocator<int>> network_ptr0(size);
    std::vector<int, aligned_allocator<int>> network_ptr1(size);
    std::vector<int, aligned_allocator<int>> user_ptr0(size);

    //OPENCL HOST CODE AREA START
    //Create Program and Kernel
    auto devices = xcl::get_xil_devices();

    // read_binary_file() is a utility API which will load the binaryFile
    // and will return the pointer to file buffer.
    auto fileBuf = xcl::read_binary_file(binaryFile);
    cl::Program::Binaries bins{{fileBuf.data(), fileBuf.size()}};
    int valid_device = 0;
    for (unsigned int i = 0; i < devices.size(); i++) {
        auto device = devices[i];
        // Creating Context and Command Queue for selected Device
        OCL_CHECK(err, context = cl::Context({device}, NULL, NULL, NULL, &err));
        OCL_CHECK(err,
                  q = cl::CommandQueue(
                      context, {device}, CL_QUEUE_PROFILING_ENABLE, &err));

        std::cout << "Trying to program device[" << i
                  << "]: " << device.getInfo<CL_DEVICE_NAME>() << std::endl;
                  cl::Program program(context, {device}, bins, NULL, &err);
        if (err != CL_SUCCESS) {
            std::cout << "Failed to program device[" << i
                      << "] with xclbin file!\n";
        } else {
            std::cout << "Device[" << i << "]: program successful!\n";
            OCL_CHECK(err,
                      network_kernel = cl::Kernel(program, "network_krnl", &err));
            OCL_CHECK(err,
                      user_kernel = cl::Kernel(program, "scatter_krnl", &err));
            valid_device++;
            break; // we break because we found a valid device
        }
    }
    if (valid_device == 0) {
        std::cout << "Failed to program any device found, exit!\n";
        exit(EXIT_FAILURE);
    }
    
    wait_for_enter("\nPress ENTER to continue after setting up ILA trigger...");

    uint32_t local_IP = getIpEnv();
    uint64_t local_mac_addr = getMacEnv();

    std::cout<<std::hex<<"local IP:"<<local_IP<<", local MAC addr:"<<local_mac_addr<<std::endl;

    // Set network kernel arguments
    OCL_CHECK(err, err = network_kernel.setArg(0, local_IP)); // Default IP address
    OCL_CHECK(err, err = network_kernel.setArg(1, local_mac_addr)); // Mac Addr
    OCL_CHECK(err, err = network_kernel.setArg(2, local_IP)); // ARP lookup

    OCL_CHECK(err,
              cl::Buffer buffer_r1(context,
                                   CL_MEM_USE_HOST_PTR | CL_MEM_READ_WRITE,
                                   vector_size_bytes,
                                   network_ptr0.data(),
                                   &err));
    OCL_CHECK(err,
            cl::Buffer buffer_r2(context,
                                CL_MEM_USE_HOST_PTR | CL_MEM_READ_WRITE,
                                vector_size_bytes,
                                network_ptr1.data(),
                                &err));

    OCL_CHECK(err, err = network_kernel.setArg(3, buffer_r1));
    OCL_CHECK(err, err = network_kernel.setArg(4, buffer_r2));

    printf("enqueue network kernel...\n");
    OCL_CHECK(err, err = q.enqueueTask(network_kernel));
    
    //set user kernel argument
    uint32_t numPacketWord = 16; //each packet is 1 KB
    uint32_t connection = 1; //number of connection
    uint32_t numIpAddr = 1; //number of IP address used
    uint32_t responseInKB = 0;
    //uint32_t baseIpAddr = 0x0A01D479; //alveo1a
    uint32_t baseIpAddr = 0x0A01D46E; // alveo0
    //uint32_t baseIpAddr = 0x0A01D499; //fpga server
    //uint32_t baseIpAddr = 0x0A01D48C;//catapult10
    uint32_t basePort = 5001; 
    uint32_t delayedCycles = 0;
    uint32_t clientPkgNum = 100;

    double durationUs = 0.0;

    if (argc >= 3)
    {
        std::string s = argv[2];
        std::string delimiter = ".";
        int ip [4];
        size_t pos = 0;
        std::string token;
        int i = 0;
        while ((pos = s.find(delimiter)) != std::string::npos) {
            token = s.substr(0, pos);
            ip [i] = stoi(token);
            s.erase(0, pos + delimiter.length());
            i++;
        }
        ip[i] = stoi(s); 
        baseIpAddr = ip[3] | (ip[2] << 8) | (ip[1] << 16) | (ip[0] << 24);
    }

    if(argc >=4)
        basePort = strtol(argv[3], NULL, 10);

    if(argc >=5)
        connection = strtol(argv[4], NULL, 10);

    if(argc >= 6)
        clientPkgNum = strtol(argv[5], NULL, 10);

    printf("IP_ADDR:%x\n", baseIpAddr);
    printf("base Port:%d\n", basePort);
    printf("number of connection:%d\n",connection);
    printf("number of Tx pkg:%d\n", clientPkgNum);
    printf("Packet size[Byte]:%d\n", numPacketWord*64);

    uint32_t numPort = connection / numIpAddr;
    
    uint32_t expectedRespInKBTotal = connection * responseInKB;

    //Set user Kernel Arguments
    OCL_CHECK(err, err = user_kernel.setArg(0, connection));
    OCL_CHECK(err, err = user_kernel.setArg(1, numIpAddr));
    OCL_CHECK(err, err = user_kernel.setArg(2, numPacketWord));
    OCL_CHECK(err, err = user_kernel.setArg(3, basePort));
    OCL_CHECK(err, err = user_kernel.setArg(4, numPort));
    OCL_CHECK(err, err = user_kernel.setArg(5, responseInKB));
    OCL_CHECK(err, err = user_kernel.setArg(6, delayedCycles));
    OCL_CHECK(err, err = user_kernel.setArg(7, baseIpAddr));
    OCL_CHECK(err, err = user_kernel.setArg(8, expectedRespInKBTotal));
    OCL_CHECK(err, err = user_kernel.setArg(9, clientPkgNum));
    
    OCL_CHECK(err,
            cl::Buffer buffer_w(context,
                                CL_MEM_USE_HOST_PTR | CL_MEM_READ_WRITE,
                                vector_size_bytes,
                                user_ptr0.data(),
                                &err));

    OCL_CHECK(err, err = user_kernel.setArg(10, buffer_w));

    //Launch the Kernel
    printf("enqueue scatter kernel...\n");
    auto start = std::chrono::high_resolution_clock::now();
    OCL_CHECK(err, err = q.enqueueTask(user_kernel));
    
    OCL_CHECK(err, err = q.finish());
    auto end = std::chrono::high_resolution_clock::now();
    durationUs = (std::chrono::duration_cast<std::chrono::nanoseconds>(end-start).count() / 1000.0);
    printf("durationUs:%f\n",durationUs);
    //OPENCL HOST CODE AREA END
    

    std::cout << "EXIT recorded" << std::endl;
}
