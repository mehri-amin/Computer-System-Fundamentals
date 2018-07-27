// ADT for a FIFO queue
// COMP1521 17s2 Week01 Lab Exercise
// Written by John Shepherd, July 2017
// Modified by ... Mehri Amin & Sharon Soojin Park

#include <stdlib.h>
#include <stdio.h>
#include <assert.h>
#include "Queue.h"

typedef struct QueueNode {
   int jobid;  // unique job ID
   int size;   // size/duration of job
   struct QueueNode *next;
} QueueNode;

struct QueueRep {
   int nitems;      // # of nodes
   QueueNode *head; // first node
   QueueNode *tail; // last node
};


// TODO:
// remove the #if 0 and #endif
// once you've added code to use this function

// create a new node for a Queue
static
QueueNode *makeQueueNode(int id, int size)
{
   QueueNode *new;
   new = malloc(sizeof(struct QueueNode));
   assert(new != NULL);
   new->jobid = id;
   new->size = size;
   new->next = NULL;
   return new;
}

// make a new empty Queue
Queue makeQueue()
{
   Queue new;
   new = malloc(sizeof(struct QueueRep));
   assert(new != NULL);
   new->nitems = 0; new->head = new->tail = NULL;
   return new;
}

// release space used by Queue
void  freeQueue(Queue q)
{
  assert(q != NULL);
  QueueNode *curr = q->head;
  QueueNode *temp;
  while(curr != NULL){
    temp = curr;
    curr = curr->next;
    free(temp);
  }
  free(q);
}

// add a new item to tail of Queue
void  enterQueue(Queue q, int id, int size)
{
   assert(q != NULL);
   // TODO
   QueueNode *new = makeQueueNode(id, size);
   if(q->head == NULL)
     q->head = q->tail = new;
  
   else{
     q->tail->next = new;
     q->tail = new;
    }
  
  q->nitems++;
}

// remove item on head of Queue
int   leaveQueue(Queue q)
{
   assert(q != NULL);
   // TODO
   if(q->head == NULL) exit(0);
            
   QueueNode *temp; 
     temp = q->head;
     int num = temp->jobid;
     q->head = q->head->next;

     if(q->head == NULL) q->tail = NULL;

     free(temp);

     q->nitems--;
  
     return num;
}

// count # items in Queue
int   lengthQueue(Queue q)
{
   assert(q != NULL);
   return q->nitems;
}

// return total size in all Queue items
int   volumeQueue(Queue q)
{
   assert(q != NULL);
  
   QueueNode *curr = q->head;
   int total = 0;
  
   while(curr != NULL){
    total += curr->size;
    curr = curr->next;
   }
  
  return total;
}

// return size/duration of first job in Queue
int   nextDurationQueue(Queue q)
{
  assert(q != NULL);
  
  if(q->head == NULL) return 0;
  
  return q->head->size;
}


// display jobid's in Queue
void showQueue(Queue q)
{
   QueueNode *curr;
   curr = q->head;
   while (curr != NULL) {
      printf(" (%d,%d)", curr->jobid, curr->size);
      curr = curr->next;
   }
}
