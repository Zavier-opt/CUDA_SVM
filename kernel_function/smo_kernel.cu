#include "math.h"
#include <stdio.h>

__global__ void smo_kernel_initial(float *d_x, int *d_y, float *d_e, float *d_alpha, int *d_Iup, int *d_Ilow, int numOfData, int numOfAttr,float C);
__global__ void calculate_kernel_update_alpha(int low, int up, float *kernel_value, float *d_x, int *d_y, float *d_e,float *d_alpha, int *d_Iup, int *d_Ilow, int numOfData, int numOfAttr,bool cal_low, bool cal_up, int row_low, int row_up, char kernel_function_name[4], float Gamma, float C);
__device__ void cal_put_kernel(float x[], float support_vector[], int numOfAttr,int numOfData, int index, float *kernel_value, int row_pos, char kernel_function_name[4], float Gamma);
__device__ bool check(char name[4], char kernel_function_name[4]);
__device__ float RBF(float x[], float support_vector[],int numOfAttr,float Gamma);
__device__ float LINEAR(float x[], float support_vector[], int numOfAttr);
__device__ void update_alpha_e(int low, int up, float *d_e,float *d_alpha, int *d_y, float *kernel_value, int row_low, int row_up, int index, int numOfData);
__device__ int divideGroup(int y, float alpha, float C, bool isUp);
__global__ void write_kernel_to_memory(float *d_kernel_up, float *d_kernel_low, int row_up, int row_low, float *kernel_value,int numOfData);



__global__ void smo_kernel_initial(float *d_x, int *d_y, float *d_e, float *d_alpha, int *d_Iup, int *d_Ilow, int numOfData, int numOfAttr,float C ){
    // value preparation
    float C_local = C;
    int index = blockIdx.x*blockDim.x+threadIdx.x;
    // put data from global memory to shared memory
    if(index<numOfData){
        d_e[index] = -d_y[index];
        d_alpha[index] = 0;
        d_Iup[index] = divideGroup(d_y[index], d_alpha[index], C_local,true); // true: detect up; false: detect low
        d_Ilow[index] = divideGroup(d_y[index], d_alpha[index], C_local,false);// the value is 1 or 0;
        //printf("%d ",index);
   }
}
__global__ void calculate_kernel_update_alpha(int low, int up, float *kernel_value, float *d_x, int *d_y, float *d_e,float *d_alpha, int *d_Iup, int *d_Ilow, int numOfData, int numOfAttr,bool cal_low, bool cal_up, int row_low, int row_up, char kernel_function_name[4], float Gamma, float C){
    int index = blockIdx.x*blockDim.x+threadIdx.x;
    if(index<numOfData){
        //printf("%d", index);
        float local_x_data[256];
        float local_low_data[256];
        float local_up_data[256];
        float C_local = C;
        for(int i=0;i<numOfAttr;i++){
            local_x_data[i] = d_x[index*numOfAttr+i];
            local_low_data[i] = d_x[low*numOfAttr+i];
            local_up_data[i] = d_x[up*numOfAttr+i];
        }

 //       if (index == 3) {
 //          for (int i = 0; i < numOfAttr; i++) {
 //               printf("%.2f ", local_x_data[i]);
 //           }
 //           printf("\n");
 //           for (int i = 0; i < numOfAttr; i++) {
 //              printf("%.2f ", local_low_data[i]);
 //           }
 //           printf("\n");
 //           for (int i = 0; i < numOfAttr; i++) {
 //               printf("%.2f ", local_up_data[i]);
 //           }
 //           printf("\n");
 //       }

        if(cal_low){
            //printf("%d", index);
            cal_put_kernel(local_x_data,local_low_data, numOfAttr,numOfData,index,kernel_value,row_low,kernel_function_name, Gamma);
        }
        if(cal_up){
            cal_put_kernel(local_x_data,local_up_data, numOfAttr,numOfData,index,kernel_value,row_up,kernel_function_name, Gamma);
        }

        update_alpha_e(low,up,d_e,d_alpha,d_y, kernel_value,row_low,row_up,index, numOfData);

        d_Iup[index] = divideGroup(d_y[index], d_alpha[index], C_local,true); // true: detect up; false: detect low
        d_Ilow[index] = divideGroup(d_y[index], d_alpha[index], C_local,false);// the value is 1 or 0;
    }
}
__device__ void cal_put_kernel(float x[], float support_vector[], int numOfAttr,int numOfData, int index, float *kernel_value, int row_pos, char kernel_function_name[4], float Gamma){
    //printf("%d", index);
    char rbf[4] = "RBF";
    char lin[4] = "LIN";
    float value;
    //if(check(rbf,kernel_function_name)){
    //    value = RBF(x,support_vector,numOfAttr,Gamma);
    //}else{
    //    value = LINEAR(x,support_vector,numOfAttr);
    //}
    //bool temp = check(rbf, kernel_function_name);
    //printf("temp:%d\n", temp);

    value = RBF(x, support_vector, numOfAttr, Gamma);
    kernel_value[row_pos*numOfData+index]=value;
    
    //printf("pos:%d\n", row_pos * numOfData + index);
    //printf("value:%.4f\n", value);

}
__device__ bool check(char name[4], char kernel_function_name[4]){
    bool res = true;
    for(int i=0;i<4;i++){
        if(name[i]!=kernel_function_name[i]){
            res = false;
        }
    }
    return res;
}
__device__ float RBF(float x[], float support_vector[],int numOfAttr,float Gamma){
    //int index2 = blockIdx.x * blockDim.x + threadIdx.x;
    //if (index2 == 3) {
    //    for (int i = 0; i < numOfAttr; i++) {
    //        printf("%.2f ", x[i]);
    //    }
    //    for (int i = 0; i < numOfAttr; i++) {
    //        printf("%.2f ", support_vector[i]);
    //    }
    //}
    //printf("\n");
    float sum = 0;
    for(int i=0;i<numOfAttr;i++){
        sum+=(x[i]-support_vector[i])* (x[i] - support_vector[i]);
        //printf("%.2f\n", sum);
    }
    
    return exp(-sum*Gamma);
}

__device__ float LINEAR(float x[], float support_vector[], int numOfAttr){
    float sum=0;
    for(int i=0;i<numOfAttr;i++){
        sum+=x[i]*support_vector[i];
    }
    return sum;
}
 
__device__ void update_alpha_e(int low, int up, float *d_e,float *d_alpha, int *d_y, float *kernel_value, int row_low, int row_up, int index, int numOfData){
    int index3 = blockIdx.x * blockDim.x + threadIdx.x;
    int y_up = d_y[up];
    int y_low = d_y[low];
    float alpha_low = d_alpha[low];
    float alpha_up = d_alpha[up];
    float alpha_low_new;
    float alpha_up_new;
    int s = y_up * y_low;
    float k_low_low = kernel_value[row_low * numOfData + low];
    float k_up_up = kernel_value[row_up * numOfData + up];
    float k_low_up = kernel_value[row_low * numOfData + up];
    float miu = k_low_low + k_up_up - 2 * k_low_up;
    if (index3 == 0) {
        printf("y_up:%d", y_up);
        printf("y_low:%d", y_low);
        printf("e_low:%0.2f", d_e[low]);
        printf("e_up:%0.2f", d_e[up]);
        printf("miu: %.2f", miu);
    }
    alpha_up_new = alpha_up + y_up * (d_e[low] - d_e[up]) / miu;
    alpha_low_new = alpha_low + s * (alpha_up - alpha_up_new);
    float kernel_low_i = kernel_value[row_low * numOfData + index];
    float kernel_up_i = kernel_value[row_up * numOfData + index];
    float e_i = d_e[index];
    d_e[index] = e_i + (alpha_low_new - alpha_low) * y_low * kernel_low_i + (alpha_up_new - alpha_up) * y_up * kernel_up_i;
    __syncthreads();
    if(index == row_up){
        d_alpha[up]=alpha_up_new;
        d_alpha[low]=alpha_low_new;
    }
    __syncthreads();
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

__global__ void write_kernel_to_memory(float *d_kernel_up, float *d_kernel_low, int row_up, int row_low, float *kernel_value,int numOfData){
    int index = blockIdx.x*blockDim.x+threadIdx.x;
    if(index<numOfData){
        d_kernel_up[index]=kernel_value[row_up*numOfData+index];
        d_kernel_low[index]=kernel_value[row_low*numOfData+index];
    }
}