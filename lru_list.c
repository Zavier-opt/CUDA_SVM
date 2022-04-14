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
    /*
    pre没有意义，仅需要多保留一个尾结点
    p->pre = tail; //使pre指向前一个节点，循环可得到反向链表
    */
    p->next = NULL;
    tail->next = p;
    tail = p;
}

void fun(int n, int *sum, int *page_faults_number) {
    struct node *q;
    q = head;
    while (q->next != NULL)
    {
        if (q->next->id == p->id)//不缺页
        {
            PushBack();
            p = q->next;
            q->next = p->next;
            free(p);
            return; //执行完全部操作停掉
        }
        q = q->next;
    }
    printf("Not in the list %d\n",p->id);
    *page_faults_number +=1;
    PushBack();
    if (*sum < n) //cache未满，放至后面
    {
        *sum += 1; //并对cache+1
        printf("sun: %d", *sum);
        return;
    }
    //cache满,释放下最后一个节点
    p = head->next;
    head->next = p->next;
    free(p);
}

void create_node(int id_num) {
    p = (struct node *)malloc(sizeof(struct node));
    p->id = id_num;
}

int push_id(int find_ID, struct node *head) {
    int cur_pos = 0;
    int return_pos = -1;
    struct node *q;
    q = head;
    if (head->id == find_ID) {
        return head->location;
    }
    while (q->next != NULL) {
        if (q->next->id == find_ID) {
            return_pos = q->location;
            q->next = q->next->next;
            q->next->next = head->next;
            head = q->next;
            return return_pos;
        }
        q = q->next;
        cur_pos += 1;
    }
    q->id = find_ID;
    return q->location;
}

int sub_main(void) {
    int sum, n, data_faults_number;
    sum = 0;                        //初始cache内没有数据
    data_faults_number = 0;         //缺页次数清空
    //scanf("%d", &n); //读入页数
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
