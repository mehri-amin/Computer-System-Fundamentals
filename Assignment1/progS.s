# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
# structures come from board.s
#
# Written by <<YOU>>, August 2017
# cat board1.s prog.s > life.s
# load life.s into qtspim --> will run properly after this
# make sure you are actually calling assignments --> jal "function name" 
# no need for stack
# to load a value in the address for the argument
# lb $a0, flag($t5) <- t5 is the value from the function
   .data
main_ret_save: .space 4

   #.word 4

msg1:
   .asciiz "# Iterations: "
msg2:
   .asciiz "=== After iteration "
msg3:
   .asciiz " ===\n"
msg4:
   .asciiz "."
msg5:
   .asciiz "#"
eol:
   .asciiz "\n"
maxiters:
   .word 0 
n:
   .word 0
nn:
   .word 0
offset:
   .word 0

   .text
   .globl main
main:
   sw   $ra, main_ret_save

# Your main program code goes here

# printing number of iterations
   li   $v0, 4 # 4: str   
   la   $a0, msg1
   syscall

# scan in a number, maxiters
   li   $v0, 5 # 5: int
   syscall
   sw   $v0, maxiters

# VARIABLES DECLARED
   lw   $s0, maxiters           # int maxiters
   lw   $s1, N                  # N from the other file
   lw   $s2, n                 # int n = 1 (for loop1)
   lw   $s5, offset             # offset

# for loops --> while loops
   loop1:
      bgt  $s2, $s0, end1       # if n > maxiters, break
      li   $s3, 0               # i = 0 (for loop2)
   loop2:
      bge  $s3, $s1, end2       # if i >= N, break
      li   $s4, 0               # j = 0 (for loop3)
   loop3:
      bge  $s4, $s1, end3        # if j >= N, break
   # IF STATEMENTS GO HERE
      # nn = neighbours(i,j);
      move $s3, $a0              # load i into argument
      move $s4, $a1              # load j into argument
      
      jal  neighbours
      nop

      move $v0, $s7              # $s7 = nn = neighbours(i,j)
      
      # $s6 = board[i][j]
      li   $t3, 0
      mul  $t3, $s3, $s1         # i * N
      add  $t3, $t3, $s4         # (i * N) + j
      la   $t2, board            # get address of board
      add  $t3, $t3, $t2         # offset to [i][j]
      lb   $s6, ($t3)            # store s6 - [i][j]

      li   $t2, 0
      li   $t3, 0

      # use temp registers again to get value at newboard
      mul  $t3, $s3, $s1
      add  $t3, $t3, $s4

      la   $t2, newBoard
      add  $t3, $t3, $t2     
      
      la $t4, nn

      bne  $s6, 1, outElse1

         #... sub if statements
         bge $t4, 2, inElse1     # if nn is >=  2, go to inElse1
         li  $t4, 0
         sb  $t4, newBoard($s5)   # newboard[i][j] = 0
         li  $t4, 0
         li  $t3, 0
         li  $t2, 0
         j L1
         
         inElse1: 
         bne $s7, 2, inElse2     # if nn != 2, go to inElse2
         li  $t1, 1
         sb  $t1, newBoard($s5)  # newboard[i][j] = 1
         li  $t1, 0
         j L1

         inElse2: 
         bne $s7, 3, inElse3     # if nn != to 3, go to inElse3
         li  $t1, 1
         sb  $t1, newBoard($s5)  # newboard[i][j] = 1
         li  $t1, 0
         j L1

         inElse3:                # if above sub if's not satisfied
         li $t4, 0
         sb $t4, newBoard($s5)   # newboard[i][j] = 0
         li $t4, 0
         j   L1

      outElse1:                  
      bne $s7, 3, outElse2
      li  $t1, 1
      sb  $t1, board($s5)        # newboard[i][j] = 1
      li  $t1, 0
      j   L1

      outElse2:
      li $t4, 0
      sb $t4, newBoard($s5)      # newboard[i][j] = 0
      li $t4, 0
      j   L1
      
      L1: 
      addi $s4, $s4, 1           # j++
      j    loop3

   end3:
      li   $s4, 0                # set j = 0 after one iteration
      addi $s3, $s3, 1           # i++
      j    loop2
   
   end2:
      # print after iteration
      li   $v0, 4
      la   $a0, msg2
      syscall
      # get n
      move   $a0, $s1
      li   $v0, 1
      syscall
      # print the rest
      li   $v0, 4
      la   $a0, msg3
      syscall

      # call cbs function
      jal copy_back_and_show
      nop
      # closing last loop
      li   $s3, 0              # set i = 0 after one iteration
      addi $s2, $s2, 1         # n++
      sw   $t2, n
      j    loop1
   end1:
   
end_main:
   lw   $ra, main_ret_save
   jr   $ra

   move $a0, $v0
   li $v0, 10
   syscall

### copy_back_and_show() function
.globl copy_back_and_show
copy_back_and_show:
   #sw   $ra, copy_back_and_show_ret_save

   # DECLARE VARIABLES
   li   $s3, 0                    # i = 0
   lw   $s1, N                    # N
   li   $s5, 0                    # offset

   other_loop1:
      bge $s3, $s1, end_other_1   # when i >= N, go to end_other_1
      li  $s4, 0                  # j = 0
   other_loop2:
      bge $s4, $s1, end_other_2   # when j >= N, go to end_other_2
      
      # board[i][j] = newboard[i][j]
      mul $s5, $s3, $s1           # offset = i * N
      add $s5, $s5, $s4           # offset = i * N + j
      lb  $s6, board($s5)         # s6 = board[i][j]
      lb  $s7, newBoard($s5)      # s7 = newboard[i][j]
      sb  $s7, board($s5)         # mem[Add] = s7
      
      # IF STATMENTS GO HERE
      bne $s6, $zero, else    # if board[i][j] != 0, go else
      li  $v0, 4
      la  $a0, msg4           # print '.'
      syscall
      j   M1
      else: 
         li $v0, 4
         la $a0, msg5          # print '#'
         syscall
         j  M1
      M1: 
      addi $s4, $s4, 1
      j    other_loop2
  
   end_other_2:
      li   $s4, 0             # set j = 0 after one iteration
      # print new line
      li $v0, 4
      la $a0, eol
      syscall

      addi $s3, $s3, 1        # i++   
      j    other_loop1
   
   end_other_1:   
   #lw   $ra, copy_back_and_show_ret_save
   jr   $ra
   li $v0, 10
   syscall
### neighbours function
.globl neighbours
neighbours:
   #sw   $ra, neighbours_ret_save
   # DECLARE VARIABLES
   lw   $s7, nn                   # nn
   li   $t5, -1                   # x (for loop 1)
   li   $s5, 0                    # offset
   lw   $s1, N                    # N from the other file
   sub  $s1, $s1, 1               # N = N - 1
   move $s3, $a0                  # load i from arg                
   move $s4, $a1                  # load j from arg
   
   last_loop1:
      bgt  $t5, 1, end_last1      # if x > 1, go to end_last1
      li   $t2, -1                # y (for loop 2)
   
   last_loop2:
      bgt  $t2, 1, end_last2    # if y > 1, go to end_last2
      # IF STATEMENTS GO HERE
      add  $t7, $t5, $s3          # (x + i) is stored in $t7  
      bltz $t7, continue          # if (i + x < 0), continue
      
      bgt  $t7, $s1, continue     # if (i + x > N - 1) continue
      
      add  $t6, $t2, $s4          # (j + y) is stored in $t6
      bltz $t6, continue          # if (j + y < 0), continue
      
      bgt  $t6, $s1, continue     # if (j + y > N - 1) continue
      
      beq  $t5, $zero, continue
      
      beq  $t2, $zero, continue

      # board[i+x][i+y]
      lw   $s1, N                 # store s1 to N again
      mul  $s5, $s1, $t7          # s5: (i + x) * N
      add  $s5, $s5, $t6          # ((i + x) * N) + (j + y)
      lb   $s6, board($s5)        # get board[i+x][j+y]
      bne  $s6, 1, continue       # if != 1, continue
      add  $s7, $s7, 1            # otherwise, nn+
      
      continue: 
      addi $t2, $t2, 1            # y++
      j    last_loop2
   end_last2:
      addi $t2, -1           # reset y to -1 after one iteration
      addi $t5, $t5, 1       # x++
      j    last_loop1
   end_last1:
   
   li     $t2, 0
   li     $t5, 0
   li     $t6, 0
   li     $t7, 0
   move   $v0, $s2             # to return nn
   #lw   $ra, neighbours_ret_save
   jr   $ra

