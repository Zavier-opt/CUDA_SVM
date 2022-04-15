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