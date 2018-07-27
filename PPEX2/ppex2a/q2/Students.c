// Students.c ... implementation of Students datatype

#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include "Students.h"

typedef struct _stu_rec {
	int   id;
	char  name[20];
	int   degree;
	float wam;
} sturec_t;

typedef struct _students {
    int    nstu;
    StuRec recs;
} students_t;

// build a collection of student records from a file descriptor
Students getStudents(int in)
{
    int ns;  // count of #students

	// Make a skeleton Students struct
	Students ss;
	if ((ss = malloc(sizeof (struct _students))) == NULL) {
		fprintf(stderr, "Can't allocate Students\n");
		return NULL;
	}

	// count how many student records
    int stu_size = sizeof(struct _stu_rec);
    sturec_t s;
	ns = 0;
    while (read(in, &s, stu_size) == stu_size) ns++;
    ss->nstu = ns;
    if ((ss->recs = malloc(ns*stu_size)) == NULL) {
		fprintf(stderr, "Can't allocate Students\n");
		free(ss);
		return NULL;
	}

	// read in the records
	lseek(in, 0L, SEEK_SET);
	for (int i = 0; i < ns; i++)
		read(in, &(ss->recs[i]), stu_size);

	close(in);
	return ss;
}

// show a list of student records pointed to by ss
void showStudents(Students ss)
{
	for (int i = 0; i < ss->nstu; i++)
		showStuRec(&(ss->recs[i]));
}

// show one student record pointed to by s
void showStuRec(StuRec s)
{
	printf("%7d %s %4d %0.1f\n", s->id, s->name, s->degree, s->wam);
}


int cmp(const void *a, const void *b)
{
  struct _stu_rec *aa = (struct _stu_rec *)a;
  struct _stu_rec *bb = (struct _stu_rec *)b;
  return strcmp(aa->name, bb->name);
}

void sortByName(Students ss)
{
	// TODO

/*  int nswaps;
  int last = ss->nstu;
 
  do {
    nswaps =0;
    // iterate through students
    for(int i = 1; i < last; i++){
      if(strcmp(ss->recs[i].name, ss->recs[i-1].name) < 0){
        // if current students name is "less" than previous swap order
        struct _stu_rec temp;
        temp = ss->recs[i]; // save current 
        ss->recs[i] = ss->recs[i-1]; 
        ss->recs[i-1] = temp; // restore
        nswaps++;
      }
    }
    last--;
  } while(nswaps >0 );
}*/

  qsort(ss->recs, ss->nstu, sizeof(struct _stu_rec), cmp);
}
