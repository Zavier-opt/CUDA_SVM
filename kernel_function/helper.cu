#include<float.h>
#include <vector>


using namespace std;

void findSupportVector(vector<float> &h_e, vector<int> &h_Ilow,vector<int> &h_Iup,int *low, int *up){
    double min = DBL_MAX;
    double max = -DBL_MAX;
    for(int i=0;i<h_e.size();i++){
        if(h_Ilow[i]==1){ // it is in low group
            if(h_e[i]>max){
                max = h_e[i];
                *low = i;
            }
        }
        if(h_Iup[i]==1){ // it is in up group
            if(h_e[i]<min){
                min = h_e[i];
                *up = i;
            }
        }
    }
}

void make_prediction(vector<int> &predict_res, int low, int up,int numOfData,float C,vector<float> &kernel_up, vector<float> &kernel_low, vector<float> &alpha, vector<int> &y) {
    // cal b
    float b = 0;
    for (int i = 0; i < numOfData; i++) {
        if (alpha[i] < 0 || alpha[i] >= C) {
            continue;
        }
        float temp = y[i] - alpha[low] * y[low] * kernel_low[i] + alpha[up] * y[up] * kernel_up[i];
        b = b + temp;
    }
    for (int i = 0; i < numOfData; i++) {
        float decision = alpha[low] * y[low] * kernel_low[i] + alpha[up] * y[up] * kernel_up[i] + b;
        if (decision >= 0) {
            predict_res[i] = 1;
        }
        else {
            predict_res[i] = -1;
        }
    }
}

float accuracy(vector<int>& predict_res, vector<int>& y, int numOfData) {
    float countCorrect = 0;
    for (int i = 0; i < numOfData; i++) {
        if (predict_res[i] == y[i]) {
            countCorrect++;
        }
    }
    return countCorrect / numOfData;
}