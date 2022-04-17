#include <stdio.h>
# include<stdlib.h>
#include <vector>
#include <algorithm>
#include <iostream>
# include <string.h>
#include "smo_kernel.cu"
#include "helper.cu"
#include "lru_list.cu"
#include "lru_list.h"

using namespace std;

    
int main(){
    
    // Read the File
    FILE* fp = fopen("..\\Dataset/MUSK_testing.csv", "r"); // rt means reading only
    if (fp == NULL) {
        printf("Can not open the file!\n");
        return 2;
    }
    else {
        printf("Sucdessfully open the file!\n");
    }

    // Get the size 
    int DATASIZE;
    int FEATURENUM;
    char* line, * record;
    char buffer[4096];
    if ((fp = fopen("..\\Dataset/MUSK_testing.csv", "r")) != NULL) {
        fseek(fp, 0, SEEK_SET);  //定位到第二行，每个英文字符大小为1
        char delims[] = ",";
        char* result = NULL;
        int j = 0;
        int i = 0;
        float record_float;
        while ((line = fgets(buffer, sizeof(buffer), fp)) != NULL) {//当没有读取到文件末尾时循环继续{
            record = strtok(line, ",");

            if (i == 0) {
                while (record != NULL)//读取每一行的数据
                {
                    if (strcmp(record, "Ps:") == 0)//当读取到Ps那一行时，不再继续读取
                        return 0;
                    //printf("%i, %i, %s \n", i, j, record);//将读取到的每一个数据打印出来
                    record = strtok(NULL, ",");
                    j++;
                    FEATURENUM = j - 1;
                }
            }
            //printf("\n");
            i++;
            j = 0;

        }
        fclose(fp);
        fp = NULL;
        DATASIZE = i - 1;

    }

    // Make the Declaration
    // float  X[DATASIZE][FEATURENUM];
    // float X_flat[DATASIZE*FEATURENUM];
    // int y[DATASIZE];
    vector<float> h_x(DATASIZE * FEATURENUM);
    vector<int> h_y(DATASIZE);

    //char *line,*record;
    //char buffer[4096];
    if ((fp = fopen("..\\Dataset/MUSK_testing.csv", "r")) != NULL) {
        fseek(fp, 0, SEEK_SET);  //定位到第二行，每个英文字符大小为1
        char delims[] = ",";
        char* result = NULL;
        int j = 0;
        int i = 0;
        float record_float;
        while ((line = fgets(buffer, sizeof(buffer), fp)) != NULL){//当没有读取到文件末尾时循环继续{
            record = strtok(line, ",");
            while (record != NULL)//读取每一行的数据
            {
                if (strcmp(record, "Ps:") == 0)//当读取到Ps那一行时，不再继续读取
                    return 0;
                //printf("%i, %i, %s \n", i, j, record);//将读取到的每一个数据打印出来

                if (i > 0 && j >= 0) {
                    if (j != 166) {
                        record_float = atof(record);
                        // X[i-1][j] = record_float;
                        //printf("%i, %i, %3f \n", i, j, record_float);

                        int index;
                        index = (i - 1) * 166 + j;
                        h_x[index] = record_float;
                    }
                    else {
                        record_float = atof(record);
                        if (record_float == 0.0)
                            record_float = -1;
                        h_y[i - 1] = record_float; // store label
                        //printf("%i, %i, %3f \n", i, j, y[i-1]);
                    }
                }

                //if (j == 167)  //只需读取前167列
                if (j == 166)
                    break;
                record = strtok(NULL, ",");
                j++;
            }
            //printf("\n");
            i++;
            j = 0;

        }
        fclose(fp);
        fp = NULL;

    }

    //cout << DATASIZE << endl;



    // In host, initialize a 2d matrix h_x (using a vector with size in numOfData*numOfAttr );
    // Input parameters:
    float C = 10;
    float slack = 0.1;
    char kernel_function_name[4] = "RBF";
    float Gamma = 0.001;


    // In host:
    int numOfData = DATASIZE;
    int numOfAttr = FEATURENUM;
    size_t bytesOfX = numOfData*numOfAttr*sizeof(float);
    size_t bytesOfY = numOfData*sizeof(int);
    //vector<float> h_x (numOfData*numOfAttr);
    //vector<int> h_y (numOfData);
    vector<float> h_e(numOfData);
    vector<float> h_alpha(numOfData);
    vector<int> h_Iup(numOfData);
    vector<int> h_Ilow(numOfData);
    
    // Initialize LRU List
    head = (struct node *)malloc(sizeof(struct node));
    head->next = NULL;
    
    //generate(h_x.begin(), h_x.end(), [](){return rand()%100;});
    //generate(h_y.begin(), h_y.end(), [](){return (rand()%2)*2-1;});
        
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

    cout << numOfData << endl;
    cout << BLOCKS << endl;

    // Go to device, Initial value
    smo_kernel_initial<<<BLOCKS, THREADS>>>(d_x,d_y,d_e, d_alpha,d_Iup, d_Ilow, numOfData,numOfAttr, C);
    cudaDeviceSynchronize();



    // Back to host
    cudaMemcpy(h_e.data(), d_e, bytesOfe, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_Ilow.data(),d_Ilow, bytesOfIlow, cudaMemcpyDeviceToHost);
    cudaMemcpy(h_Iup.data(),d_Iup, bytesOfIup, cudaMemcpyDeviceToHost);
    

     // Find low, up vector
    int low=-1;
    int up=-1;
    findSupportVector(h_e, h_Ilow, h_Iup, &low, &up);

    //cout << low << endl;
    //cout << up << endl;

    // First two nodes in LRU list
    struct node* second = (struct node *)malloc(sizeof(struct node));
    head->id = low;
    head->next = second;
    second->id = up;
    second->next = NULL;
    
    int row_low;
    int row_up;

    int iterations = 0;
    // Loop begin
    while(1){
        
        int temp;
        printf("next interations:");
        scanf("%d", &temp);

        //cout << "support vector index:" << endl;
        //cout << up << endl;
        //cout << low << endl;

        float bup = h_e[up];
        float blow = h_e[low];
        float diff = blow - bup;
        //cout << "b value:" << endl;
        //cout<< bup <<endl;
        //cout << blow << endl;

        iterations++;
        if (iterations % 20 == 1) {
            printf("Iteration: %d\n", iterations);
            printf("blow-bup: %0.2f\n", diff);
        }

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
 
        //row_low = push_id(low, head, &cal_low);
        //row_up = push_id(up, head, &cal_up);
        row_low = 0;
        row_up = 1;

        //cout << "support vector row value:" << endl;
        //cout << row_low << endl;
        //cout << row_up << endl;
        //cout << "support vector row status:" << endl;
        //cout << cal_low << endl;
        //cout << cal_up << endl;
      
        //cout << "blocks,threads:" << endl;
        //cout << BLOCKS << endl;
        //cout << THREADS << endl;
        calculate_kernel_update_alpha<<<BLOCKS, THREADS>>>(low, up, kernel_value,d_x, d_y, d_e, d_alpha,d_Iup, d_Ilow, numOfData,numOfAttr, cal_low,cal_up,row_low,row_up,kernel_function_name,Gamma,C);
        cudaDeviceSynchronize();
        // 1. get kernel value
        
        // 2. compute alpha, e and Iup Ilow

        // Go Back to host
        cudaMemcpy(h_e.data(), d_e, bytesOfe, cudaMemcpyDeviceToHost);
        cudaMemcpy(h_alpha.data(), d_alpha, bytesOfalpha, cudaMemcpyDeviceToHost);
        cudaMemcpy(h_Ilow.data(),d_Ilow, bytesOfIlow, cudaMemcpyDeviceToHost);
        cudaMemcpy(h_Iup.data(),d_Iup, bytesOfIup, cudaMemcpyDeviceToHost);
        //cout << "h_alpha values:" << endl;
        //for (int i = 0; i < numOfData; i++) {
        //    cout << h_alpha[i] << " ";
        //}
        //cout << "h_e values:" << endl;
        //for (int i = 0; i < numOfData; i++) {
        //    cout << h_e[i] << " ";
        //}
        //cout << "h_Ilow values:" << endl;
        //for (int i = 0; i < numOfData; i++) {
        //    cout << h_Ilow[i] << " ";
        //}
        //cout << "h_Iup values:" << endl;
        //for (int i = 0; i < numOfData; i++) {
        //    cout << h_Iup[i] << " ";
        //}

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
    cudaDeviceSynchronize();
    cudaMemcpy(h_kerel_up.data(),d_kernel_up,bytesOfSupportKernel,cudaMemcpyDeviceToHost);
    cudaMemcpy(h_kernel_low.data(),d_kernel_low,bytesOfSupportKernel,cudaMemcpyDeviceToHost);
    
    vector<int> predict_res(numOfData);
    make_prediction(predict_res,low,up, numOfData,C, h_kerel_up, h_kernel_low, h_alpha, h_y);

    //cout << "predict:" << endl;
    //for (int i = 0; i < numOfData; i++) {
    //    cout << predict_res[i] << " ";
    //}
    //cout << " " << endl;
    cout << "h_alpha:" << endl;
    for (int i = 0; i < numOfData; i++) {
       cout << h_alpha[i] << " ";
    }
    //cout << " " << endl;

    float training_accuracy = accuracy(predict_res, h_y, numOfData);
    printf("accuracy: %.2f", training_accuracy);
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

