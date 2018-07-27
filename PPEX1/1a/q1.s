# COMP1521 Practice Prac Exam #1
# int rmOdd(int *src, int n, int*dest)

   .text
   .globl rmOdd

# params: src=$a0, n=$a1, dest=$a2
rmOdd:
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
# locals: ... $s0 = src, $s1 = n, $s2 = dest, $s3 = i, $s4 = j

  move $s0, $a0   # src
  move $s1, $a1   # n
  move $s2, $a2   # dest
  li   $s3, 0     # i
  li   $s4, 0     # j

  for:
    beq $s3, $s1, end # if i = n break for loop

    # if statement
    move $t0, $s3
    mul $t0, $t0, 4 # byte offset
    add $t0, $t0, $s0 # get src[i]
    lw  $t0,  ($t0)   # save word at src[i] tp $t0

    move $t1, $t0 # t1 = t0

    li $t2, 1
    and $t0, $t0, $t2 # t0=t0&1 check if odd or even

    bnez  $t0, skip # if its odd skip to next number

    # else if even copy to dest[i]
    move $t0, $s4 #j
    mul $t0, $t0, 4
    add $t0, $t0, $s2
    sw  $t1, ($t0)

    addi $s4, $s4, 1

  skip:
    addi $s3, $s3, 1
    j for

  end:
    move $v0, $s4





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

