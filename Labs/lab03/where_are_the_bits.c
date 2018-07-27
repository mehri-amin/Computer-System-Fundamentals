// where_are_the_bits.c ... determine bit-field order
// COMP1521 Lab 03 Exercise
// Written by ...

#include <stdio.h>
#include <stdlib.h>

struct _bit_fields {
   unsigned int a : 4,
                b : 8,
                c : 20;
};

int main(void)
{
   struct _bit_fields x;

   printf("%ul\n",sizeof(x));

   unsigned int *ptr;
   x.a = 0;
   x.b = 0;
   x.c = 0;
   
   printf("%d\n", x.a);
   printf("%d\n", x.b);
   printf("%d\n", x.c);

   ptr = (unsigned int *)&x;
   (*ptr)++;
   
   printf("%d\n", x.a);
   printf("%d\n", x.b);
   printf("%d\n", x.c);

// A B C

   return 0;
}


