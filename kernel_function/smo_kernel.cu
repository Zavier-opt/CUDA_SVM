#include "string.h"
#include "math.h"
__global__ void smo_kernel_initial(float *d_x, int *d_y, float *d_e, float *d_alpha, int *d_Iup, int *d_Ilow, int numOfData, int numOfAttr,float C ){
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
__global__ void calculate_kernel_update_alpha(int low, int up, float *kernel_value, float *d_x, float *d_e,float *d_alpha, int numOfData, int numOfAttr,bool cal_low, bool cal_up, int row_low, int row_up, char[] kernel_function, float gamma){
    int index = blockIdx.x*blockDim.x+threadIdx.x;
    if(index<numOfData){
        float local_x_data[numOfAttr];
        float local_low_data[numOfAttr];
        float local_up_data[numOfAttr];
        for(int i=0;i<local_data;i++){
            local_x_data[i] = d_x[index*numOfAttr+i];
            local_low_data[i] = d_x[low*numOfAttr+i];
            local_up_data[i] = d_x[up*numOfAttr+i];
        }
        if(cal_low){
            cal_put_kernel(local_x_data,local_low_data, numOfAttr,index,kernel_value,row_low,kernel_function, gamma);
        }
        if(cal_up){
            cal_put_kernel(local_x_data,local_up_data, numOfAttr,index,kernel_value,row_up,kernel_function, gamma);
        }

        update_alpha_e(d_e,d_alpha,kernel_value,row_low,row_up,index);
    }
}
__device__ void cal_put_kernel(float x[], float support_vector[], int numOfAttr, int index, float *kernel_value, int row_pos, char[] kernel_function, float gamma){
    char[] rbf = "RBF";
    char[] lin = "LINEAR";
    float value;
    if(strcmp(rbf,kernel_function)==0){
        value = RBF(x,support_vector,numOfAttr,gamma);
    }else{
        value = LINEAR(x,support_vector,numOfAttr);
    }
    kernel_value[row_pos*numOfData+index]=value;

}

__device__ float RBF(float x[], float support_vector[],int numOfAttr,float gamma){
    float sum = 0;
    for(int i=0;i<numOfAttr;i++){
        sum+=pow((x[i]-support_vector[i]),2);
    }
    return exp(-sum*gamma);
}

__device__ float LINEAR(float x[], float support_vector[], int numOfAttr){
    float sum=0;
    for(int i=0;i<numOfAttr;i++){
        sum+=x[i]*support_vector[i];
    }
    return sum;
}
 
__device__ void update_alpha_e(float *d_e,float *d_alpha, float *kernel_value, int row_low, int row_up, int index){
    float low_kernel_value = 
    float up_kernel_value =
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
