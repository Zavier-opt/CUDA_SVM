//
//  read_csv.c
//  read_csv
//
//  Created by Dinglin Xia on 2/27/22.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define LONGLENGTH 1024
#define BUFFERSIZE 10
#define HEAD 1

int main(int argc, const char * argv[]) {
    // Make the Declaration
    char a[1024][2];
    char* line_list,* ptr;
    char* p;
    int N;
    N = BUFFERSIZE;
    p = 0;
    //char buffer[BUFFERSIZE], s[BUFFERSIZE];
    const char* delim = ",";
    //int line=0;
    int count=0;
    int c, i;
    
    // Read the File
    FILE* fp;
    fp = fopen("/Users/dinglin/Desktop/Operations Research/ISyE6679 Computational Methods/Final Project/MUSK_testing.csv", "rt"); // rt means reading only
    //fp = fopen("/Users/dinglin/Downloads/CUDA_SVM-main/Dataset/MUSK_original.csv","rt");
    if (fp == NULL) return 2;
    
    // Method1: Get all the strings at once, then devide them by strtok
    // ----- Version 1 ------
    /*
    while(1) {
        i = 0;
        while (1) {
            fscanf(fp, "%s", &a[line][i]);
            printf("%s\n", &a[line][i]);
            c = getchar(); // cannot move on
            printf("%c", c);
            printf("%d,%d\n", line, i);
            i++;
            if (c == '\n'||c == EOF) break;
        }
        line ++;
        if (c == EOF) break;
    }
     
     for (i = 0; i < line; i++){
         for (c = 0; c < 10; c++){
             printf("%d", a[i][c]);
             printf("\n");
         }
     }
     */
    
    // ----- Version 2 ------
    /*
    fseek(fp, 0L, SEEK_SET);
    line_list = fgets(buffer,BUFFERSIZE,fp);
    strcpy(s, line_list); // convert pointer to constant
    printf("s=%s\n",s);
    line_list = fgets(buffer,BUFFERSIZE,fp);
    strcpy(s, line_list); // convert pointer to constant
    printf("s=%s\n",s);
     */
    
    // ----- Version 3 ------
    /*
    while (fp != EOF && count < LONGLENGTH){
        //*if (HEAD == 1 && count < 1) {
            count += 1;
            continue;
        }
         //*
        fgets(a, sizeof(a), fp);
        char* tmp = strdup(a);
        char* tok;
        tok = strtok(tmp, ",");
        tok = strtok(NULL, ",");
        a[count][0] = tok;
        printf("%d,0,%c\n", count, a[count][0]);
        tok = strtok(NULL, ",");
        //a[count][1] = atoi(tok);
        printf("%d,1,%c\n", count, a[count][1]);
        count++;
        free(tmp);
    }*/

    
    // Method2: Find the number before commas one by one
    /*
    for (int k = 0; k < N; k++){
        //fseek(fp, p, 1);
        line = fgets(buffer, sizeof(buffer), fp);
        record = strtok(line, ",");
        while (record != NULL) {
            if (strcmp(record, "Ps:") == 0)//当读取到Ps那一行时，不再继续读取
                return 0;
            printf("%s ", record);//将读取到的每一个数据打印出来
            if (p == 10)  //只需读取前9列
                break;
            record = strtok(NULL, ",");
            p++;
        }
        printf("\n");
        p = 0;
    }
     */
    char *line,*record;
    char buffer[1024];
    if ((fp = fopen("/Users/dinglin/Desktop/Operations Research/ISyE6679 Computational Methods/Final Project/MUSK_testing.csv", "rt")) != NULL) {
        fseek(fp, 0, SEEK_SET);  //定位到第二行，每个英文字符大小为1
        char delims[] = ",";
        char *result = NULL;
        int j = 0;
        while ((line = fgets(buffer, sizeof(buffer), fp))!=NULL) {//当没有读取到文件末尾时循环继续{
                record = strtok(line, ",");
                while (record != NULL)//读取每一行的数据
                {
                    if (strcmp(record, "Ps:") == 0)//当读取到Ps那一行时，不再继续读取
                        return 0;
                    printf("%s \n", record);//将读取到的每一个数据打印出来
                    if (j == 10)  //只需读取前9列
                        break;
                    record = strtok(NULL, ",");
                    j++;
                }
                printf("\n");
                j = 0;
     
            }
            fclose(fp);
            fp = NULL;
    }
    
    fclose(fp);
    
    
    
    printf("Hello, World!\n");
    return 0;
}
    
    
    
    printf("Hello, World!\n");
    return 0;
}
