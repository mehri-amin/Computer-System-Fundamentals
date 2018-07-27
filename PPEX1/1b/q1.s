# COMP1521 Practice Prac Exam #1
# int everyKth(int *src, int n, int k, int*dest)

   .text
   .globl everyKth

# params: src=$a0, n=$a1, k=$a2, dest=$a3
everyKth:
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
# locals: ... $s0 = src, $s1 = n, $s2 = k, $s3 = dest, $s4 = i, $s5 = j

  # add code for your everyKth function here
  move $s0, $a0   # src
  move $s1, $a1   # n
  move $s2, $a2   # k
  move $s3, $a3   # dest
  li   $s4, 0     # i
  li   $s5, 0     # j

  for:
    beq $s4, $s1, end # if i = n break for loop

    # if statement
    div $s4, $s2  # i%k
    mfhi $t0
    bnez $t0, skip  # if i%k != 0, skip to next i

    # else get src[i] 
    move $t0, $s4
    mul $t0, $t0, 4
    add $t0, $t0, $s0 # src[i]
    lw  $t1, ($t0)

    # get dest[j]
    move $t0, $s5
    mul $t0, $t0, 4
    add $t0, $t0, $s3 #dest[j]
    sw $t1, ($t0) # dest[j]=src[i]

    addi $s5, $s5, 1

  skip:
    addi $s4, $s4, 1
    j for

  end:
    move $v0, $s5   # return j;

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

