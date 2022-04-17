# include<stdio.h>
# include<stdlib.h>
# include <string.h>
# include <vector>
using namespace std;



int main(){

    // Read the File
    FILE* fp = fopen("MUSK_testing.csv", "r"); // rt means reading only
    if (fp == NULL) {
        printf("Can not open the file!\n");
        return 2;
    }
    else{
        printf("Sucdessfully open the file!\n");
    }

    // Get the size 
    int DATASIZE;
    int FEATURENUM;
    char *line,*record;
    char buffer[4096];
    if ((fp = fopen("MUSK_testing.csv", "r")) != NULL) {
        fseek(fp, 0, SEEK_SET);  //定位到第二行，每个英文字符大小为1
        char delims[] = ",";
        char *result = NULL;
        int j = 0;
        int i = 0;
        float record_float;
        while ((line = fgets(buffer, sizeof(buffer), fp))!=NULL) {//当没有读取到文件末尾时循环继续{
                record = strtok(line, ",");

                if (i==0){
                    while (record != NULL)//读取每一行的数据
                    {
                    if (strcmp(record, "Ps:") == 0)//当读取到Ps那一行时，不再继续读取
                        return 0;
                    //printf("%i, %i, %s \n", i, j, record);//将读取到的每一个数据打印出来
                    record = strtok(NULL, ",");
                    j++;
                    FEATURENUM = j-1;
                    }
                }
                //printf("\n");
                i++;
                j = 0;
     
            }
            fclose(fp);
            fp = NULL;
            DATASIZE = i-1;
 
    }

    
    // Make the Declaration
    // float  X[DATASIZE][FEATURENUM];
    // float X_flat[DATASIZE*FEATURENUM];
    // int y[DATASIZE];
    vector<float> X_flat (DATASIZE*FEATURENUM);
    vector<int> y (DATASIZE);

    char* line_list,* ptr;
    char* p;
    //int N;
    //N = BUFFERSIZE;
    p = 0;
    //char buffer[BUFFERSIZE], s[BUFFERSIZE];
    const char* delim = ",";
    //int line=0;
    int count=0;
    int c, i;

    //char *line,*record;
    //char buffer[4096];
    if ((fp = fopen("MUSK_testing.csv", "r")) != NULL) {
        fseek(fp, 0, SEEK_SET);  //定位到第二行，每个英文字符大小为1
        char delims[] = ",";
        char *result = NULL;
        int j = 0;
        int i = 0;
        float record_float;
        while ((line = fgets(buffer, sizeof(buffer), fp))!=NULL) {//当没有读取到文件末尾时循环继续{
                record = strtok(line, ",");
                while (record != NULL)//读取每一行的数据
                {
                    if (strcmp(record, "Ps:") == 0)//当读取到Ps那一行时，不再继续读取
                        return 0;
                    // printf("%i, %i, %s \n", i, j, record);//将读取到的每一个数据打印出来

                    if (i>0 && j>=0) {
                        if (j!=166){
                            record_float = atof(record);
                            // X[i-1][j] = record_float;
                            //printf("%i, %i, %3f \n", i, j, record_float);

                            int index;
                            index = (i-1)*166 + j;
                            X_flat[index] = record_float;
                        }
                        else{  
                            record_float = atof(record);
                            if (record_float == 0.0)
                                record_float = -1;
                            y[i-1] = record_float; // store label
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
    
    fclose(fp);

    // for (int i = 0; i < DATASIZE; i++){
    //     for (int j = 0; j < FEATURENUM; j++){
    //         printf("%i,%i,%f \n", i,j,X[i][j]);
    //     }
    // }
    
    // for (int i = 0; i < DATASIZE; i++){
    //     printf("%i\n", y[i]);
    // }

    // for (int i = 0; i < DATASIZE*FEATURENUM; i++){
    //     if (i>DATASIZE*FEATURENUM-10)
    //         printf("%f\n", X_flat[i]);
    // }

    // printf("%i %i\n", DATASIZE, FEATURENUM);
}