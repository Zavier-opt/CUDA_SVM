__global__ void smo_kernel_initial(float *d_x, int *d_y, float *d_e, float *d_alpha, int *d_Iup, int *d_Ilow, int numOfData, int numOfAttr,float C ){
   if(initial){
       // value preparation
       float C_local = C;
       int index = blockIdx.x*blockDim.x+threadIdx.x;
       extern __shared__ float x_data[blockDim.x*numOfAttr];
       __shared__ int y_data[blockDim.x];
       __shared__ float e[blockDim.x];
       __shared__ float alpha[blockDim.x];
       __shared__ int Iup[blockDim.x];
       __shared__ int Ilow[blockDim.x];
 
       // put data from global memory to shared memory
       if(index<numOfData){
           for(int i=0;i<numOfAttr;i++){
               x_data[numOfAttr*threadIdx.x+i] = d_x[numOfAttr*index+i];
           }
           y_data[threadIdx.x] = d_y[index];
           e[threadIdx.x] = -y_data[threadIdx.x];
           alpha[threadIdx.x] = 0;
           Iup[threadIdx.x] = divideGroup(y_data[threadIdx.x], alpha[threadIdx.x], C_local,true); // true: detect up; false: detect low
           Ilow[threadIdx.x] = divideGroup(y_data[threadIdx.x], alpha[threadIdx.x], C_local,false);// if it is up/low, the value is 1, otherwise 0;
 
       }
 
   }
 
}
 
__device__ int divideGroup(int y, float alpha, float C, bool isUp){
   if(alpha>0 && alpha<C){
       return 1;
   }
   int res;
   if(isUp){
       if((y==1&&alpha==0)||(y==-1&&alpha==C)){
           res = 1;
       }else{
           res = 0;
       }
       return res;
   }else{
       if((y==1&&alpha==C)||(y==-1&&alpha==0)){
           res = 1;
       }else{
           res = 0;
       }
       return res;
   }
  
 
}
