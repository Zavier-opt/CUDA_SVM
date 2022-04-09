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

void find_data(const int index, int &offset, bool &compute) {
  std::vector<DirectoryEntry>::iterator iCurrentEntry = directory.begin() + index;
  if (iCurrentEntry->status == DirectoryEntry::INCACHE) {
    hits++;
    if (iCurrentEntry->lruListEntry == lruList.begin()) {
      offset = iCurrentEntry->location;
      compute = false;
      return;
    }
    lruList.erase(iCurrentEntry->lruListEntry);
    lruList.push_front(index);
    iCurrentEntry->lruListEntry = lruList.begin();
    offset = iCurrentEntry->location;
    compute = false;
    return;
  }

  //Cache Miss
  if (occupancy < cacheSize) {
    //Cache has empty space
    compulsoryMisses++;
    iCurrentEntry->location = occupancy;
    iCurrentEntry->status = DirectoryEntry::INCACHE;
    lruList.push_front(index);
    iCurrentEntry->lruListEntry = lruList.begin();
    occupancy++;
    offset = iCurrentEntry->location;
    compute = true;
    return;
  }
 
  //Cache is full
  if (iCurrentEntry->status == DirectoryEntry::NEVER) {
    compulsoryMisses++;
  } else {
    capacityMisses++;
  }

  int expiredPoint = lruList.back();
  lruList.pop_back();
 
  directory[expiredPoint].status = DirectoryEntry::EVICTED;
  int expiredLine = directory[expiredPoint].location;
  iCurrentEntry->status = DirectoryEntry::INCACHE;
  iCurrentEntry->location = expiredLine;
  lruList.push_front(index);
  iCurrentEntry->lruListEntry = lruList.begin();

  offset = iCurrentEntry->location;
  compute = true;
  return;
}
