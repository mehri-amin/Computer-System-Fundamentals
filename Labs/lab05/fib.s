# MIPS assembler to compute Fibonacci numbers

   .data
msg1:
   .asciiz "n = "
msg2:
   .asciiz "fib(n) = "
newline:
   .asciiz "\n"
errormsg:
   .asciiz "n must be > 0\n"

   .text

# int main(void)
# {
#    int n;
#    printf("n = ");
#    scanf("%d", &n);
#    if (n >= 1)
#       printf("fib(n) = %d\n", fib(n));
#    else {
#       printf("n must be > 0\n");
#       exit(1);
#    }
#    return 0;
# }

   .globl main
main:
   # prologue
   subu $sp, $sp, 8 
   sw   $ra, ($sp) 
   sw   $s0, 4($sp)

   # function body
   la   $a0, msg1       # printf("n = ");
   li   $v0, 4
   syscall

   li   $v0, 5          # scanf("%d", &n);
   syscall
   move $a0, $v0

   # ... add code to check (n >= 1)
   # ... print an error message, if needed
   # ... and return a suitable value from main()

   bgtz $a0, continue # if greater than zero, go to continue function

   #else print error
   la   $a0, errormsg
   li   $v0, 4
   syscall
   
   # and jump to end
   j returnError


#if greater than zero
continue:
   
   jal  fib             # $s0 = fib(n);
   nop
   move $s0, $v0

   la   $a0, msg2       # printf((fib(n) = ");
   li   $v0, 4
   syscall

   move $a0, $s0        # printf("%d", $s0);
   li   $v0, 1
   syscall

   la   $a0, newline       # printf("\n");
   li   $v0, 4
   syscall

returnError:
   # epilogue
   lw   $ra, ($sp)
   lw   $s0, 4($sp)
   addu $sp, $sp, 8
   jr   $ra


# int fib(int n)
# {
#    if (n < 1)
#       return 0;
#    else if (n == 1)
#       return 1;
#    else
#       return fib(n-1) + fib(n-2);
# }

fib:
   # function body
   bgt $a0, 1, fib_recurse #if $a0 greater than 1, go to recursive function
   move $v0, $a0 # move to register $v0 where return value is put
   jr $ra # jump register return $ra
   
fib_recurse:
   sub $sp, $sp, 12 # allocating stack frame of 12 bytes
   sw  $ra, 0($sp) # save return address 

   sw  $a0, 4($sp) # save n 
   add $a0, $a0, -1 # n-1
   jal fib # first recursive call
   lw  $a0, 4($sp) # restore n 
   sw  $v0, 8($sp) # save return value of fib(n-1)

   add $a0, $a0, -2 # second call: n-2
   jal fib # second recursive call
  
   lw $t0, 8($sp) # restore return value of fib(n-1)
   add $v0, $t0, $v0 # add values up 

   # restore the return address back into register
   lw $ra, 0($sp) 
   # deallocate stack frame
   add $sp, $sp, 12
   
   jr $ra

