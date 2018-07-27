# COMP1521 Practice Prac Exam #1
# (int dp, int n) dotProd(int *a1, int n1, int *a2, int n2)

   .text
   .globl dotProd

# params: a1=$a0, n1=$a1, a2=$a2, n2=$a3
dotProd:
# prologue
   addi $sp, $sp, -4
   sw   $fp, ($sp)
   la   $fp, ($sp)
   addi $sp, $sp, -4
   sw   $ra, ($sp)
   addi $sp, $sp, -4
   sw   $s0, ($sp)
   addi $sp, $sp, -4
   sw   $s1, ($sp)
   # if you need to save more $s? registers
   # add the code to save them here

# function body
# locals: ... $s0 = a1, $s1 = n1, $s2 = a2, $s3 = n2, $s4 = i,  $s5 = len, $s6 = sum

   # add code for your dotProd function here
   move $s0, $a0    # a1
   move $s1, $a1    # n1
   move $s2, $a2    # a2
   move $s3, $a3    # n2
   li   $s4, 0      # i
   li   $s5, 0      # len
   li $s6, 0     # sum

   #  if (n1 < n2) len = n1
   bge $s1, $s3, else
   move $s5, $s1
   j for

   #  else len = n2
   else:
     move $s5, $s3

   # for i=0; i<len; i++    sum = sum+a1[i]*a2[i]
   for:
     bge $s4, $s5, end

     #a1[i]*a2[i]
     move $t0, $s4
     mul $t0, $t0, 4
     add $t0, $t0, $s0
     lw $t0, ($t0)

     move $t1, $s4
     mul $t1, $t1, 4
     add $t1, $t1, $s2
     lw $t1, ($t1)
      
     #move $t0, $s4
     #li $t1, 4
     #mul $t0, $t0, $t1
     #add $t1, $t0, $s0
     #lw $t1, ($t1)

     #move $t2, $s2
     #add $t2, $t2, $s4
     #lb $t2, ($t2)
    
    #add $t2, $t0, $s2
    #lw $t2, ($t2)


     mul $t2, $t0, $t1

    #sum
     add $s6, $s6, $t2

     addi $s4, $s4, 1
     j for
   # return (sum, len);
   end:
     move $v0, $s6
     move $v1, $s5

# epilogue
   # if you saved more than two $s? registers
   # add the code to restore them here
   lw   $s1, ($sp)
   addi $sp, $sp, 4
   lw   $s0, ($sp)
   addi $sp, $sp, 4
   lw   $ra, ($sp)
   addi $sp, $sp, 4
   lw   $fp, ($sp)
   addi $sp, $sp, 4
   j    $ra

