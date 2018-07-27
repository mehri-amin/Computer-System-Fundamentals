// ADT for Bit-strings
// COMP1521 17s2 Week02 Lab Exercise
// Written by John Shepherd, July 2017
// Modified by ... Mehri Amin and Sharon Soojin Park

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <assert.h>
#include "Bits.h"
#include <stdint.h>

// assumes that an unsigned int is 32 bits
#define BITS_PER_WORD 32
// A bit-string is an array of unsigned ints (each a 32-bit Word)
// The number of bits (hence Words) is determined at creation time
// Words are indexed from right-to-left
// words[0] contains the most significant bits
// words[nwords-1] contains the least significant bits
// Within each Word, bits are indexed right-to-left
// Bit position 0 in the Word is the least significant bit
// Bit position 31 in the Word is the most significant bit

typedef unsigned int Word;

struct BitsRep {
   int nwords;   // # of Words
   Word *words;  // array of Words
};

// make a new empty Bits with space for at least nbits
// rounds up to nearest multiple of BITS_PER_WORD
Bits makeBits(int nbits)
{
   Bits new;
   new = malloc(sizeof(struct BitsRep));
   assert(new != NULL);
   int  nwords;
   if (nbits%BITS_PER_WORD == 0)
      nwords = nbits/BITS_PER_WORD;
   else
      nwords = 1+nbits/BITS_PER_WORD;
   new->nwords = nwords;
   // calloc sets to all 0's
   new->words = calloc(nwords, sizeof(Word));
   assert(new->words != NULL);
   return new;
}

// release space used by Bits
void  freeBits(Bits b)
{
   assert(b != NULL && b->words != NULL);
   free(b->words);
   free(b);
}

// form bit-wise AND of two Bits a,b
// store result in res Bits
void andBits(Bits a, Bits b, Bits res)
{
   // TODO
  int i = 0;
  
  while(i < b->nwords){
    res->words[i] = a->words[i] & b->words[i];
    i++;
  }

}

// form bit-wise OR of two Bits a,b
// store result in res Bits
void orBits(Bits a, Bits b, Bits res)
{
   // TODO
   int i = 0;
   
   while(i < b->nwords){
     res->words[i] = a->words[i] | b->words[i];
     i++;
    }    

}

// form bit-wise negation of Bits a,b
// store result in res Bits
void invertBits(Bits a, Bits res)
{
   // TODO
   int i = 0;

   while(i < a->nwords){
     res->words[i] = ~a->words[i];
     i++;
   }

}

// left shift Bits
void leftShiftBits(Bits b, int shift, Bits res)
{
   // challenge problem
  
}

// right shift Bits
void rightShiftBits(Bits b, int shift, Bits res)
{
   // challenge problem
}

// copy value from one Bits object to another
void setBitsFromBits(Bits from, Bits to)
{
   // TODO
   int i = 0;

   while(i < from->nwords){
     to->words[i] = from->words[i];
     i++;
   }

}

// assign a bit-string (sequence of 0's and 1's) to Bits
// if the bit-string is longer than the size of Bits, truncate higher-order bits
void setBitsFromString(Bits b, char *bitseq)
{
  
  int bit = strlen(bitseq) - 1; // Start at the right of bit sequence
  int i,j,k; 
  unsigned int mask = 0;

  // To reset b->words
  for(k = 0; k < b->nwords; k++){
    b->words[k] = 0;
  }
 
  // Iterate down b->nwords right from left.
  for(i = b->nwords-1; i>=0; i--){
    // Iterate up of b->words left to right for comparison
    // And ensure bit >= 0 (valid access)
    for(j=0; j<BITS_PER_WORD && bit >= 0; j++){
      
      if(bitseq[bit] == '1'){
        mask = 1u<<j; // shift j down if bit = 1
      
      }else{
        mask=0; // set mask to 0
      }
      
      // Bit Operator OR
      b->words[i] = b->words[i] | mask;
      bit--; // decrement bit to move down bit sequence
    }
  }
}

// display a Bits value as sequence of 0's and 1's
void showBits(Bits b)
{
   // TODO
  int i,j;
  
  // Iterate through b->nwords, left to right 
  for(i=0; i < b->nwords; i++){ 
    // Iterate through BITS_PER_WORD right to left
    for (j = BITS_PER_WORD-1; j >= 0; j--) { 
      // Create bit mask that shifts left of j
      unsigned mask = 1u<<j;
      // Use bit AND operator to check whether a bit is set. If true return 1 else 0.
      printf("%u", b->words[i]&mask?1:0);  
    }
  }
}
