// PageTable.c ... implementation of Page Table operations
// COMP1521 17s2 Assignment 2
// Written by John Shepherd, September 2017
// Mehri Amin ~ z5113067

// pls dont kill me with the marking

#include <stdlib.h>
#include <stdio.h>
#include "Memory.h"
#include "Stats.h"
#include "PageTable.h"
#include <assert.h>

// Symbolic constants
#define NOT_USED 0
#define IN_MEMORY 1
#define ON_DISK 2

// PTE = Page Table Entry

typedef struct {
   char status;      // NOT_USED, IN_MEMORY, ON_DISK
   char modified;    // boolean: changed since loaded
   int  frame;       // memory frame holding this page
   int  accessTime;  // clock tick for last access
   int  loadTime;    // clock tick for last time loaded
   int  nPeeks;      // total number times this page read
   int  nPokes;      // total number times this page modified
   // TODO: add more fields here, if needed ...
} PTE;

// A structure to represent a queue for FIFO
// Took C program for generic array implementation of queue from:
// https://gist.github.com/orcnyilmaz/06a7b9b4a03580826e7619fd8381aa00
// Modified for this assignment! praying u dont think this is plagiarism... 
typedef struct Queue
{
  int front, rear, size; // first, last, nitems of Queue
  unsigned capacity; // max size of Queue
  int* pages; // array of pages

}Queue;

// A stucture to represent a doubly linked list for LRU
// Taken from COMP2521 Week03 Lab DLList.c
// http://www.cse.unsw.edu.au/~cs2521/17s2/labs/week03/code/DLList.c
// Modified for this assignment! praying u dont think this is plagiarism...
typedef struct DLListNode
{
  int item; // value of node
  struct DLListNode* prev;
  struct DLListNode* next;

}DLListNode;


// The virtual address space of the process is managed
//  by an array of Page Table Entries (PTEs)
// The Page Table is not directly accessible outside
//  this file (hence the static declaration)

static PTE *PageTable;      // array of page table entries
static int  nPages;         // # entries in page table
static int  replacePolicy;  // how to do page replacement
static int  fifoList;       // index of first PTE in FIFO list
static int  fifoLast;       // index of last PTE in FIFO list

// Forward refs for private functions
static Queue* fifo; // FIFO
static DLListNode *head, *tail; // LRU

// given
static int findVictim(int);

// Queue Functions
Queue* createQueue(unsigned);
void enqueue(struct Queue*, int);
int dequeue(struct Queue*);
int isFull(struct Queue*);
int isEmpty(struct Queue*);

// DLList Struct Functions
void InsertNode();
void deleteTail();
void deleteItem(int);

// initPageTable: create/initialise Page Table data structures

void initPageTable(int policy, int np)
{
   PageTable = malloc(np * sizeof(PTE));
   if (PageTable == NULL) {
      fprintf(stderr, "Can't initialise Memory\n");
      exit(EXIT_FAILURE);
   }
   replacePolicy = policy;
   nPages = np;
   fifoList = 0;
   fifoLast = nPages-1;
   for (int i = 0; i < nPages; i++) {
      PTE *p = &PageTable[i];
      p->status = NOT_USED;
      p->modified = 0;
      p->frame = NONE;
      p->accessTime = NONE;
      p->loadTime = NONE;
      p->nPeeks = p->nPokes = 0;
   }
   fifo = createQueue(nPages); // create Queue for FIFO replacement
}

// requestPage: request access to page pno in mode
// returns memory frame holding this page
// page may have to be loaded
// PTE(status,modified,frame,accessTime,nextPage,nPeeks,nWrites)

int requestPage(int pno, char mode, int time)
{
   if (pno < 0 || pno >= nPages) {
      fprintf(stderr,"Invalid page reference\n");
      exit(EXIT_FAILURE);
   }
   PTE *p = &PageTable[pno];
   int fno; // frame number
   switch (p->status) {
   case NOT_USED:
   case ON_DISK:
      // TODO: add stats collection
      countPageFault(); // increment page faults since ON_DISK
      fno = findFreeFrame();
      if (fno == NONE) {
         int vno = findVictim(time);
#ifdef DBUG
         printf("Evict page %d\n",vno);
#endif
         PTE *p = &PageTable[vno]; // create victim page
         // TODO:
         // if victim page modified, save its frame
         if(p->modified != 0){
           saveFrame(fno);
          }
         // collect frame# (fno) for victim page
         fno = p->frame;
         // update PTE for victim page
         // - new status
         // - no longer modified
         // - no frame mapping
         // - not accessed, not loaded
         p->status = ON_DISK;
         p->modified = 0;
         p->frame = NONE;
         p->accessTime = NONE;
         p->loadTime = NONE;
          }
      printf("Page %d given frame %d\n",pno,fno);
      // TODO:
      // load page pno into frame fno
      // update PTE for page
      // - new status
      // - not yet modified
      // - associated with frame fno
      // - just loaded  
      loadFrame(fno,pno,time);
      p->status = IN_MEMORY; // since it is loaded its in memory
      p->modified = 0;
      p->frame = fno;
      p->accessTime = time;
      p->loadTime = time;
      enqueue(fifo, pno); // since loaded, enter into fifo
    break;
   case IN_MEMORY:
      // TODO: add stats collection
      countPageHit();
      break;
   default:
      fprintf(stderr,"Invalid page status\n");
      exit(EXIT_FAILURE);
   }
   if (mode == 'r')
      p->nPeeks++;
   else if (mode == 'w') {
      p->nPokes++;
      p->modified = 1;
   }
   p->accessTime = time;
   deleteItem(pno); 
   InsertNode(pno);
   return p->frame;
}

// findVictim: find a page to be replaced
// uses the configured replacement policy

static int findVictim(int time)
{
   int victim = 0;
   switch (replacePolicy) {
   case REPL_LRU:
   victim =0;
      // TODO: implement LRU strategy
      victim = tail->item; // tail is oldest accessed page therefore victim 
      // will be the tail of the list. 
      deleteTail(); // taken from the list, we delete the tail.
      break;
   case REPL_FIFO:
      // TODO: implement FIFO strategy
      victim = dequeue(fifo); // dequeue will remove first added page
      break;
   case REPL_CLOCK:
      return 0;
   }
   return victim;
}

// showPageTableStatus: dump page table
// PTE(status,modified,frame,accessTime,nextPage,nPeeks,nWrites)

void showPageTableStatus(void)
{
   char *s;
   printf("%4s %6s %4s %6s %7s %7s %7s %7s\n",
          "Page","Status","Mod?","Frame","Acc(t)","Load(t)","#Peeks","#Pokes");
   for (int i = 0; i < nPages; i++) {
      PTE *p = &PageTable[i];
      printf("[%02d]", i);
      switch (p->status) {
      case NOT_USED:  s = "-"; break;
      case IN_MEMORY: s = "mem"; break;
      case ON_DISK:   s = "disk"; break;
      }
      printf(" %6s", s);
      printf(" %4s", p->modified ? "yes" : "no");
      if (p->frame == NONE)
         printf(" %6s", "-");
      else
         printf(" %6d", p->frame);
      if (p->accessTime == NONE)
         printf(" %7s", "-");
      else
         printf(" %7d", p->accessTime);
      if (p->loadTime == NONE)
         printf(" %7s", "-");
      else
         printf(" %7d", p->loadTime);
      printf(" %7d", p->nPeeks);
      printf(" %7d", p->nPokes);
      printf("\n");
   }
}



/////////// Queue Functions ////////////
Queue* createQueue(unsigned capacity)
{
    Queue* queue = malloc(sizeof(Queue));
    queue->capacity = capacity;
    queue->front = queue->size = 0; 
    queue->rear = capacity - 1;  // This is important, see the enqueue
    queue->pages = (int*) malloc(queue->capacity * sizeof(int));
    return queue;
}
 
// Queue is full when size becomes equal to the capacity 
int isFull(Queue* queue)
{  return (queue->size == queue->capacity);  }
 
// Queue is empty when size is 0
int isEmpty(Queue* queue)
{  return (queue->size == 0); }
 
// Function to add an item to the queue.  It changes rear and size
void enqueue(Queue* queue, int item)
{
    if (isFull(queue))
        return;
    queue->rear = (queue->rear + 1)%queue->capacity;
    queue->pages[queue->rear] = item;
    queue->size = queue->size + 1;
    printf("%d enqueued to queue\n", item);
}
 
// Function to remove an item from queue.  It changes front and size
int dequeue(Queue* queue)
{
    if (isEmpty(queue))
        return 0;
    int item = queue->pages[queue->front];
    queue->front = (queue->front + 1)%queue->capacity;
    queue->size = queue->size - 1;
    return item;
}
 
// Function to get front of queue
int front(Queue* queue)
{
    if (isEmpty(queue))
        return 0;
    return queue->pages[queue->front];
}
 
// Function to get rear of queue
int rear(Queue* queue)
{
    if (isEmpty(queue))
        return 0;
    return queue->pages[queue->rear];
}

/////// DLL Functions //////////

static DLListNode *newNode(int item)
{
  DLListNode *new = malloc(sizeof(DLListNode));
  assert(new != NULL);
  new->item = item;
  new->prev = new->next = NULL;
  return new;
}

// insert node at head of list
void InsertNode (int item)
{
  DLListNode *new = newNode(item);
  if(head == NULL){
    head = tail = new;
  }else{
    head->prev = new;
    new->next = head;
    head = new;
  }
}

// delete node at tail
void deleteTail()
{
  if(tail == NULL)
  {
    return;
  }
  else
  {
    tail = tail->prev;
    tail->next = NULL;
  }
}

// delete node at any point
void deleteItem(int item)
{
  DLListNode *curr = head;
  DLListNode *temp = NULL;

  while(curr != NULL){
    if(curr->item == item){

      //@ head of list
      if(curr->prev == NULL){
        head = curr->next;
        free(curr);
      }
      // @ tail of list
      else if(curr->next == NULL){
        deleteTail();
      // wherever else
      }else{
        temp = curr->prev;
        temp->next = curr->next;
        temp = curr->next;
        temp->prev = curr->prev;
        free(curr);
      }
    }
  curr = curr->next;
  }
}





