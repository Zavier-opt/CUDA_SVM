#include <stdio.h>
#include <vector>
#include <algorithm>
#include <iostream>
#include "smo_kernel.cu"
#include "helper.cu"
#include "lru_list.cu"
#include "lru_list.h"
//#include "support.h"

using namespace std;

    
int main(){
    
    // In host, initialize a 2d matrix h_x (using a vector with size in numOfData*numOfAttr );
    // Input parameters:
    float C = 0.1;
    float slack = 0.1;
    char kernel_function_name[4] = "RBF";
    float Gamma = 0.01;

    // In host:
    int numOfData = 10;
    int numOfAttr = 5;
    size_t bytesOfX = numOfData*numOfAttr*sizeof(float);
    size_t bytesOfY = numOfData*sizeof(int);
    vector<float> h_x (numOfData*numOfAttr);
    vector<int> h_y (numOfData);
    vector<float> h_e(numOfData);
    vector<float> h_alpha(numOfData);
    vector<int> h_Iup(numOfData);
    vector<int> h_Ilow(numOfData);
    
    // Initialize LRU List
    head = (struct node *)malloc(sizeof(struct node));
    head->next = NULL;
    
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
    int numOfRowInKernel = LRUSIZE;
    size_t bytesOfe = numOfData*sizeof(float);
    size_t bytesOfalpha = numOfData*sizeof(float);
    size_t bytesOfIup = numOfData*sizeof(int);
    size_t bytesOfIlow = numOfData*sizeof(int);
    size_t bytesOfkernel_value = numOfData*numOfRowInKernel*sizeof(float); // kernel value: [k1:[x1,x2,...],k2:[x1,x2,...]]
    // cudaError_t cuda_ret;
    // cuda_ret = cudaMalloc(&d_x, bytesOfX);    // cudaMalloc(void**, devPtr, size_t, size)
    // if(cuda_ret!=cudaSuccess){
    //     cout<<"wrong"<<endl;
    // }
    cudaMalloc(&d_x, bytesOfX);
    cudaMalloc(&d_y, bytesOfY);
    cudaMalloc(&d_e, bytesOfe);
    cudaMalloc(&d_alpha, bytesOfalpha);
    cudaMalloc(&d_Iup, bytesOfIup);
    cudaMalloc(&d_Ilow, bytesOfIlow);
    cudaMalloc(&kernel_value,bytesOfkernel_value); // allocate memory of kernel value in device
    
    // from host to device
    cudaMemcpy(d_x, h_x.data(), bytesOfX, cudaMemcpyHostToDevice);
    cudaMemcpy(d_y, h_y.data(), bytesOfY, cudaMemcpyHostToDevice);
    
    int THREADS = 512;
    int BLOCKS;
    if(numOfData%THREADS==0){
        BLOCKS = (int)numOfData/THREADS;
    }else{
        BLOCKS = (int)numOfData/THREADS+1;
    } 

    cudaDeviceSynchronize();
    // Go to device, Initial value
    smo_kernel_initial<<<BLOCKS, THREADS>>>(d_x,d_y,d_e, d_alpha,d_Iup, d_Ilow, numOfData,numOfAttr, C);
    cudaDeviceSynchronize();



    // Back to host
    cudaMemcpy(h_e.data(), d_e, bytesOfe, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_Ilow.data(),d_Ilow, bytesOfIlow, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_Iup.data(),d_Iup, bytesOfIup, cudaMemcpyDeviceToHost);
    
    for(int i=0;i<numOfData;i++){
        cout<<h_e[i]<<endl;
    }  

     // Find low, up vector
    int low=-1;
    int up=-1;
    findSupportVector(h_e, h_Ilow, h_Iup, &low, &up);



    // First two nodes in LRU list
    struct node* second = (struct node *)malloc(sizeof(struct node));
    head->id = low;
    head->next = second;
    second->id = up;
    second->next = NULL;
    
    int row_low;
    int row_up;

    // Loop begin
    while(1){
        //cout<<1<<endl;
        float bup = h_e[up];
        float blow = h_e[low];
        if(blow<=bup+2*slack){
            break;
        }
        // Go to device
        // Need LRU function:
        // Input: up, low (they are index of support vector);
        // Output: 
        // cal_low/up (whether we should calculate them)
        // row_low/up (the index of row in kernel values matrix)
        //row_low = 0; // if cal_low/up is true, row_low/up is the posOfRow they should be
        //row_up = 1;// if cal_low/up is false, row_low/up is the posOfRow they have been
        bool cal_low = true;
        bool cal_up = true;
        row_low = push_id(low, head, &cal_low);
        row_up = push_id(up, head, &cal_up);
      
        calculate_kernel_update_alpha<<<BLOCKS, THREADS>>>(low, up, kernel_value,d_x, d_y, d_e, d_alpha,d_Iup, d_Ilow, numOfData,numOfAttr, cal_low,cal_up,row_low,row_up,kernel_function_name,Gamma,C);
        // 1. get kernel value
        
        // 2. compute alpha, e and Iup Ilow

        // Go Back to host
        cudaMemcpy(h_e.data(), d_e, bytesOfe, cudaMemcpyDeviceToHost);
        cudaMemcpy(h_Ilow.data(),d_Ilow, bytesOfIlow, cudaMemcpyDeviceToHost);
        cudaMemcpy(h_Iup.data(),d_Iup, bytesOfIup, cudaMemcpyDeviceToHost);

        // Find low, up vector
        findSupportVector(h_e, h_Ilow, h_Iup, &low, &up);

    }

    // recieve results
    cudaMemcpy(h_alpha.data(), d_alpha,bytesOfalpha,cudaMemcpyDeviceToHost);
    vector<float> h_kerel_up(numOfData);
    vector<float> h_kernel_low(numOfData);
    float *d_kernel_up;
    float *d_kernel_low;
    size_t bytesOfSupportKernel = numOfData*sizeof(float);
    cudaMalloc(&d_kernel_up,bytesOfSupportKernel);
    cudaMalloc(&d_kernel_low,bytesOfSupportKernel);
    write_kernel_to_memory<<<BLOCKS, THREADS>>>(d_kernel_up,d_kernel_low,row_up,row_low,kernel_value,numOfData);
    cudaMemcpy(h_kerel_up.data(),d_kernel_up,bytesOfSupportKernel,cudaMemcpyDeviceToHost);
    cudaMemcpy(h_kernel_low.data(),d_kernel_low,bytesOfSupportKernel,cudaMemcpyDeviceToHost);
 
    // Output results for prediction:
    // low, up kernel values:   h_kerel_up, h_kernel_low;
    // low, up support vector:  row_low, row_up;
    // alhps:                   h_alpha;
    // final group:             h_Ilow, h_Iup;

    // Next step: use parameters to make prediction

    // free memory

    // cout<<"h_alpha:"<<endl;
    // for(int i=0;i<numOfData;i++){
    //     cout<<h_alpha[i]<<endl;
    // }

    // cout<<"kernel up:"<<endl;
    // for(int i=0;i<numOfData;i++){
    //     cout<<h_kerel_up[i]<<endl;
    // }
    // cout<<"\n";
    // cout<<"kernel up:"<<endl;
    // for(int i=0;i<numOfData;i++){
    //     cout<<h_kerel_up[i]<<endl;
    // }

    cudaFree(d_x);
    cudaFree(d_y);
    cudaFree(d_e);
    cudaFree(d_alpha);
    cudaFree(d_Iup);
    cudaFree(d_Ilow);
    cudaFree(kernel_value); 
    
}

