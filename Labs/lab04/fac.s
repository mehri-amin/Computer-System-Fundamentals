#COMP1521 Lab 04 ... Simple MIPS assembler


### Global data

   .data
msg1:
   .asciiz "n: "
msg2:
   .asciiz "n! = "
eol:
   .asciiz "\n"

theNumber: # integer from user
   .word 0 # initialised to zero

theAnswer: # variable for the anser
   .word 0 # intialised to zero

### main() function

   .data
   .align 2
#main_ret_save:
 #  .word 4

   .text
   .globl main

main:
   #sw   $ra, main_ret_save

#  ... your code for main() goes here
   li $v0, 4
   la $a0, msg1 # print out the message to the screen
   syscall

   li $v0, 5 # read from keyboard
   syscall 
  
   sw $v0, theNumber # store word to theNumber
   
   # call the factorial function
   lw $a0, theNumber
   jal fac # jump to factorial function
   sw $v0, theAnswer # store word to theAnswer

   # display n! =
   li $v0, 4
   la $a0, msg2
   syscall 

   # print answer 
   li $v0, 1 
   lw $a0, theAnswer
   syscall
   
   #print \n
   la $a0, eol
   addi $v0, $0, 4
   syscall

   # tell the OS that this is the end of the program
   li $v0, 10
   syscall

.globl fac
fac:
    # have enough space to store 2 values 
    subu $sp, $sp, 8
    # storing value of returning value into stack
    sw $ra, ($sp)
    # storing local variable into second position of the stack
    sw $s0, 4($sp) #4 bytes apart

    #Base Case
    li $v0, 1
    # branch if equal to 0 to function factorialDone
    beq $a0, 0, factorialDone


    #Recursive step: Find factorial(theNumber-1)
    move $s0, $a0 
    sub $a0, $a0, 1
    jal fac # jump back to factorial function
  
    #multiply all numbers 
    mul $v0, $s0, $v0   

    factorialDone:
      lw $ra, ($sp) # loaded from stack
      lw $s0, 4($sp) # load value of local value of stack
      addu $sp, $sp, 8  #to restore the stack
      # because we initially subtracted 8 bytes of memory, so need to add back in. 
      # return from function.
      jr $ra

