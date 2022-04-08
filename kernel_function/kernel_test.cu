#include <stdio.h>
#include <vector>
#include <algorithm>
#include <iostream>
#include "smo_kernel.cu"
#include "helper.cu"

using namespace std;
    
int main(){
    
    // In host, initialize a 2d matrix h_x (using a vector with size in numOfData*numOfAttr );
    // parameters:
    float C = 0.1;
    float slack = 0.1;

    // In host:
    int numOfData = 10;
    int numOfAttr = 5;
    size_t bytesOfX = numOfData*numOfAttr*sizeof(float);
    size_t bytesOfY = numOfData*sizeof(int);
    vector<float> h_x (numOfData*numOfAttr);
    vector<int> h_y (numOfData);
    vector<float> h_e(numOfData);
    vector<float> h_Iup(numOfData);
    vector<float> h_Ilow(numOfData);
    
    
    // initialize h_x, h_y
    generate(h_x.begin(), h_x.end(), [](){return rand()%100;});
    generate(h_y.begin(), h_y.end(), [](){return (rand()%2)*2-1;});
    
    
    // In device, allocate memory to device, transform from host to device
    float *d_x;
    int *d_y;
    float *d_e;
    float *d_alpha;
    int *d_Iup;
    int *d_Ilow;
    float *kernel_value;
    int numOfRowInKernel = 500;
    size_t bytesOfe = numOfData*sizeof(float);
    size_t bytesOfalpha = numOfData*size(float);
    size_t bytesOfIup = numOfData*sizeof(int);
    size_t bytesOfIlow = numOfData*sizeof(int);
    size_t bytesOfkernel_value = numOfData*numOfRowInKernel*sizeof(float);
    cudaMalloc(&d_x, bytesOfX);    // cudaMalloc(void**, devPtr, size_t, size)
    cudaMalloc(&d_y, bytesOfY);
    cudaMalloc(&d_e, bytesOfe);
    cudaMalloc(&d_alpha, bytesOfalpha);
    cudaMalloc(&d_Iup, bytesOfIup);
    cudaMalloc(&d_Ilow, bytesOfIlow);
    cudaMalloc(&kernel_value,bytesOfkernel_value); // allocate memory of kernel value in device
    
    // from host to device
    cudaMemcpy(d_x, h_x.data(), bytesOfX, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y.data(), bytesOfY, cudaMemcpyHostToDevice);
    
    //
    // test
    // for(int i=0; i<h_y.size();i++){
    //     cout<<h_y[i]<<",";
    // }
        // define num of threads and num of blocks
    int THREADS = 512;
    int BLOCKS;
    if(numOfData%THREADS==0){
        BLOCKS = numOfData/THREADS;
    }else{
        BLOCKS = numOfData/THREADS+1;
    }

    // Go to device, Initial value
    smo_kernel_initial<<BLOCKS, THREADS>>(d_x,d_y,d_e, d_alpha,d_Iup, d_Ilow, numOfData,numOfAttr, C);
    
    // Back to host
    cudaMemcpy(h_e.data(), d_e, bytesOfe, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_Ilow.data(),d_Ilow, bytesOfIlow, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_Iup.data(),d_Iup, bytesOfIup, cudaMemcpyDeviceToHost);
    
     // Find low, up vector
    int low=-1;
    int up=-1;
    findSupportVector(h_e, h_Ilow, h_Iup, &low, &up);

    // Loop begin
    while(1){
        float bup = h_e[up];
        float blow = h_e[low];
        if(blow<=bup+2*slack){
            break;
        }
        // Go to device

        // 1. get kernel value

        // 2. compute alpha, e and Iup Ilow

        // Back to host
        

    }

    

    // free memory
    cudaFree(d_x);
    cudaFree(d_y);
    
}

