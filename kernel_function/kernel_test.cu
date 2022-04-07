#include <stdio.h>
#include <vector>
#include <algorithm>
#include <iostream>
#include "smo_kernel.cu"
 
using namespace std;
 
int main(){
 
   // In host, initialize a 2d matrix h_x (using a vector with size in numOfData*numOfAttr );
   // parameters:
   float C = 0.1;
   // data:
   int numOfData = 10;
   int numOfAttr = 5;
   size_t bytesOfX = numOfData*numOfAttr*sizeof(float);
   size_t bytesOfY = numOfData*sizeof(int);
   vector<float> h_x (numOfData*numOfAttr);
   vector<int> h_y (numOfData);
 
   // initialize h_x, h_y
   generate(h_x.begin(), h_x.end(), [](){return rand()%100;});
   generate(h_y.begin(), h_y.end(), [](){return (rand()%2)*2-1;});
 
 
   // In device, allocate memory to device, transform from host to device
   int *d_x, *d_y;
   cudaMalloc(&d_x, bytesOfX);    // cudaMalloc(void**, devPtr, size_t, size)
   cudaMalloc(&d_y, bytesOfY);
 
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
 
   bool initial = 1;
   smo_kernel<<BLOCKS, THREADS>>(d_x,d_y,initial,numOfData,numOfAttr);
 
   // free memory
   cudaFree(d_x);
   cudaFree(d_y);
 
}
