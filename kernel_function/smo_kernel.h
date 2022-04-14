__global__ void smo_kernel_initial(float *d_x, int *d_y, float *d_e, float *d_alpha, int *d_Iup, int *d_Ilow, int numOfData, int numOfAttr,float C );
__global__ void calculate_kernel_update_alpha(int low, int up, float *kernel_value, float *d_x, int *d_y, float *d_e,float *d_alpha, int numOfData, int numOfAttr,bool cal_low, bool cal_up, int row_low, int row_up, char[] kernel_function, float Gamma, float C);
__device__ void cal_put_kernel(float x[], float support_vector[], int numOfAttr, int index, float *kernel_value, int row_pos, char[] kernel_function, float Gamma);
__device__ float RBF(float x[], float support_vector[],int numOfAttr,float Gamma);
__device__ float LINEAR(float x[], float support_vector[], int numOfAttr);
__device__ void update_alpha_e(float *d_e,float *d_alpha, int *d_y, float *kernel_value, int row_low, int row_up, int index, int numOfData);
__device__ int divideGroup(int y, float alpha, float C, bool isUp);
__global__ void write_kernel_to_memory(float *d_kernel_up, float *d_kernel_low, int row_up, int row_low, float *kernel_value,int numOfData);




