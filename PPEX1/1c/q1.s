# COMP1521 Practice Prac Exam #1
# int lowerfy(char *src, char *dest)

   .text
   .globl lowerfy

# params: src=$a0, dest=$a1
lowerfy:
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
# locals: ... $s0 = src, $s1 = dest, $s2 = i, $s3 = n, $t0 = ch


   # add code for your lowerfy function here
   move $s0, $a0  # src
   move $s1, $a1  # dest
   li   $s2,  0   # i
   li   $s3,  0   # n

  # get src[i]
  for: 
    move $t0, $s0
    add $t0, $t0, $s2
    lb $t0, ($t0)
    beqz $t0, end

    li $t1, 'A'
    blt $t0, $t1, next
    li $t1, 'Z'
    bgt $t0, $t1, next

    li $t1, 'a'
    add $t0, $t0, $t1
    li $t1, 'A'
    sub $t0, $t0, $t1

    addi $s3, $s3, 1

  next:
    #dest[i] = ch;
    move $t1, $s1
    add $t1, $t1, $s2
    sb $t0, ($t1)

    add $s2, $s2, 1
    j for

  end:
    #dest[i] = '\0'
    move $t0, $s1
    add $t0, $t0, $s2
    move $t1, $0
    sb $t1, ($t0)

    move $v0, $s3


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

