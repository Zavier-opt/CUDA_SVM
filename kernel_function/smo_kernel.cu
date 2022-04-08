__global__ void smo_kernel_initial(float *d_x, int *d_y, float *d_e, float *d_alpha, int *d_Iup, int *d_Ilow, int numOfData, int numOfAttr,float C ){
   if(initial){
       // value preparation
       float C_local = C;
       int index = blockIdx.x*blockDim.x+threadIdx.x;
 
       // put data from global memory to shared memory
       if(index<numOfData){
           d_e[index] = -d_y[index];
           d_alpha[index] = 0;
           d_Iup[index] = divideGroup(d_y[index], alpha[index], C_local,true); // true: detect up; false: detect low
           d_Ilow[index] = divideGroup(d_y[index], alpha[index], C_local,false);// if it is up/low, the value is 1, otherwise 0;
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
