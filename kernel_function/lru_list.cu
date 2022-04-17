//
//  lru_list.c
//  parallel_svm
//
//  Created by Dinglin Xia on 4/6/22.
//

#include "lru_list.h"
#include <stdio.h>
#include <stdlib.h>

#define LRUSIZE 256

/*
struct node
{
    int id;
    int status;
    int location;
    struct node *next;
} * head, *tail, *p;
*/

void PushBack(void) {

    p->next = NULL;
    tail->next = p;
    tail = p;
}

void fun(int n, int *sum, int *page_faults_number) {
    struct node *q;
    q = head;
    while (q->next != NULL)
    {
        if (q->next->id == p->id)
        {
            PushBack();
            p = q->next;
            q->next = p->next;
            free(p);
            return; 
        }
        q = q->next;
    }
    printf("Not in the list %d\n",p->id);
    *page_faults_number +=1;
    PushBack();
    if (*sum < n) 
    {
        *sum += 1; 
        printf("sun: %d", *sum);
        return;
    }

    p = head->next;
    head->next = p->next;
    free(p);
}

void create_node(int id_num) {
    p = (struct node *)malloc(sizeof(struct node));
    p->id = id_num;
}

int push_id(int find_ID, struct node *head, bool *cal_bool) {
    int cur_pos = 0;
    int return_pos = -1;
    struct node *q;
    q = head;
    if (head->id == find_ID) {
        *cal_bool = true;
        return head->location;
    }
    while (q->next != NULL) {
        if (q->next->id == find_ID) {
            return_pos = q->location;
            q->next = q->next->next;
            q->next->next = head->next;
            head = q->next;
            *cal_bool = true;
            return return_pos;
        }
        q = q->next;
        cur_pos += 1;
    }
    q->id = find_ID;
    *cal_bool = false;
    return q->location;
}

int sub_main(void) {
    int sum, n, data_faults_number;
    sum = 0;                      
    data_faults_number = 0;        

    n = LRUSIZE;
    head = (struct node *)malloc(sizeof(struct node));
    head->next = NULL;
    tail = head;
    while (1)
    {
        p = (struct node *)malloc(sizeof(struct node));
        scanf("%d", &p->id);
        if (p->id < 0)
        {
            break;
        }
        else
        {
            fun(n,&sum,&data_faults_number);
        }
    }
    printf("Not in the list: %d\n",data_faults_number);
    return 0;
}
