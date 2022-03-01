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
#define HEAD 1

int main(int argc, const char * argv[]) {
    // insert code here...
    FILE* fp;
    char a[1024][2];
    int line=0;
    int count=0;
    int c, i;
    
    //fp = fopen("/Users/dinglin/Desktop/Operations Research/ISyE6679 Computational Methods/Final Project/MUSK_testing.csv", "rt"); // rt means reading only
    fp = fopen("/Users/dinglin/Downloads/CUDA_SVM-main/Dataset/MUSK_original.csv","rt");
    if (fp == NULL) return 2;
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
     //*/
    
    while (fp != EOF && count < LONGLENGTH){
        /*if (HEAD == 1 && count < 1) {
            count += 1;
            continue;
        }
         /*/
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
    }
    
    fclose(fp);
    
    
    
    printf("Hello, World!\n");
    return 0;
}
