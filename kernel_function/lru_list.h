//
//  lru_list.h
//  parallel_svm
//
//  Created by Dinglin Xia on 4/6/22.
//

#ifndef lru_list_h
#define lru_list_h

#include <stdio.h>
struct node
{
    int id;
    int status;
    int location;
    struct node *next;
} * head, *tail, *p;

void fun(int n, int *sum, int *page_faults_number);

#endif /* lru_list_h */
