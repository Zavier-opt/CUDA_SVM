#include <stdio.h>
#include <iostream>

using namespace std;

__global__ void myKernel() 
{ 
  printf("Hello, world from the device!\n"); 
} 

int main() 
{ 
  myKernel<<<1,10>>>(); 
  cudaDeviceSynchronize();
  cout<<1<<endl;
} 