# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
# structures come from board.s
#
# Written by Mehri Amin, September 2017

   .data
main_ret_save: .space 4

# to use in main
maxiters:     #int maxiters;
  .word 0

msg1:
  .asciiz "# Iterations: "

msg2:
  .asciiz "\n=== After iteration "

msg3:
  .asciiz " ===\n"

# to use in function copyBackAndShow
dot:
  .asciiz "."

hash:
  .asciiz "#"

eol:
  .asciiz "\n"

  .text


#-------------------------------------------------------------------------------------------#

   #$t0 = maxiters  $t1 = N  $t2 = n $t3 = i
   #$t4 = j   $t5 = offset    $t6 = board  $t7 = comparing number
   #$t8 =   $t9 =   
   #$s0 = nn  $s1 =   $s2 =   $s3 =
   #$s4 =   $s5 =   $s6 =   $s7 = newboard

.globl main
main:
  sw $ra, main_ret_save

  # print "# Iterations: "
  la $a0, msg1 
  li $v0, 4
  syscall

  # scans max iterations from stdin
  li $v0, 5
  syscall

  # saves value to integer variable maxiters
  sw $v0, maxiters

  # initialize/declare everything
  lw $t0, maxiters #maxiters
  lw $t1, N #N
  li $t2, 1  # n
  li $t3, 0 # i
  li $t4, 0 # j
  
  for_n:
    bgt $t2, $t0, exit_for_n
    
    li $t3, 0
    for_i:
      beq $t3, $t1, exit_for_i
      
      li $t4, 0
      for_j:
        beq $t4, $t1, exit_for_j 
        
        #else continue to if statements

        # int nn = neighbours(i,j)
        move $a1, $t3
        move $a2, $t4
        jal neighbours
    #
        move $s0, $v1 #nn 

        #offset
        mul $t5, $t1, $t3 # offset *N bytes for board1
        add $t5, $t5, $t4 #offset = offset + j
 
        lb $t6, board($t5) #board[][]
        lb $s7, newBoard($t5) #newBoard[][]
        

        li $t7, 1
      beq $t7, $s0, board_1

        li $t7, 3
        beq $t7, $t6, nn_3
       
       li $s7,0
       sb $s7, newBoard($t5)
       beq $t6, $zero, iterate_j


        board_1:
        li $t7, 2
        # nn < 2 
        blt $s0, $t7  nn_lt2
        # nn == 2 || n == 3
        beq $s0, $t7, nn_2_3
        li $t7, 3
        beq $s0, $t7, nn_2_3
        #else
        li $s7, 0
        sb $s7, newBoard($t5)
        beq $s7,$zero, iterate_j

   
     

       nn_2_3:
          li $s7, 1
          sb $s7, newBoard($t5)
          j iterate_j


        nn_lt2:
          li $s7, 0
          sb $s7, newBoard($t5)
          j iterate_j
    
       nn_3:
          li $s7, 1
         sb $s7, newBoard($t5)
          j iterate_j
    
        ##set_0:
         # li $s7, 0
         # sb $s7, newBoard($t5)
         # j iterate_j

        #set_1:
         #li $s7, 1
          #sb $s7, newBoard($t5)
         # j iterate_j

        iterate_j:
          addi $t4, $t4, 1 
          j for_j

     exit_for_j:
      addi $t3, $t3, 1
        j for_i
  
      exit_for_i:
        li $v0, 4
        la $a0, msg2
        syscall

        move $a0, $t2
        li $v0, 1
        syscall

        li $v0, 4
        la $a0, msg3
        syscall

        jal copyBackAndShow

        addi $t2, $t2, 1
        j for_n
  


   exit_for_n:
      beq $t2, $t0, main_f

 main_f:
    j end_main


end_main:
   lw   $ra, main_ret_save
   jr   $ra
   #EXIT CALL 
   li $v0, 10
   syscall
###############################################################################################
# The other functions go here
  .globl neighbours
neighbours:

  #$t0 = maxiters  $t1 = N  $t2 = n $t3 = i
  # $t4 = j   $t5 = nn    $t6 = constant  $t7 = x
  # $t8 = y   $t9 = comparing number
  # $s0 = nn  $s1 = i+x  $s2 = j+y   $s3 = offset
  # $s4 = board  $s5 = newboard   $s6 = N-1  $s7 = 

  li $t5, 0 # nn
 li $t6, 1 #constant
  li $t7, -1 #x
 li $t8, -1 #y 
  lw $s6, N
  li $t9, 1
  sub $t9, $s6, $t9 # N-1

  for_x:
    bgt $t7, $t6, exit_x
    li $t8, -1
    for_y:
      bgt $t8, $t6, exit_y
    
      # store i+x and j+y
     add $s1, $t7, $a1 # i+x
     add $s2, $t8, $a2 # j+y

      # i+x < 0 || i+x > N-1 continue
      blt $s1, $zero, continue
     bgt $s1, $t9, continue
    
      #j+y < 0 || j+y > N-1 continue
     blt $s2, $zero, continue
     bgt $s2, $t9, continue 

     bne $t7, $zero, offset
     beq $t8, $zero, continue
offset:
    mul $s4, $s6, $s1 # offset *N
    add $s4, $s4, $s2 #j+y
    lb $s5, board($s4) #offset = offset + (j+y)
      
    li $s6, 1
    bne $s5, $s6, continue #if(board[x+i][y+j] == 1 y++
    addi $t5, $t5, 1 #nn++
  continue:
  lw $s6, N
  addi $t8, $t8, 1
  j for_y
  
exit_y:
 addi $t7, $t7, 1
  j for_x

exit_x:
 move $v1,$t5  #return nn
  jr $ra
      
######################################################
 .globl copyBackAndShow
copyBackAndShow:

  # $t0 = maxiters  $t1 = N  $t2 = n $t3 = i
  # $t4 = j   $t5 = offset    $t6 =   $t7 = 
  # $t8 =    $t9 = 
  # $s0 = nn  $s1 = i+x  $s2 = j+y   $s3 = offset
  # $s4 = board  $s5 = newboard   $s6 = N-1  $s7 = 


#initialize
lw $t1, N
li $t6, 0 # i
li $t7, 0 # j

  for_first:  
    ble $t1, $t6, exit_first # if i > N exit loop
  li $t7, 0
  for_second:
   ble $t1, $t7, exit_second # if i > N exit loop
    
    #offset
   mul $s3, $t1, $t6 #i*N bytes
    add $s3, $s3, $t7 #add j
    lb $s1, board($s3) #board[i][j]
    lb $s2, newBoard($s3) #newBoard[i][j]


    #  move $a0, $s1
     #   li $v0, 1
      #  syscall 

#  move $a0, $s2
 #       li $v0, 1
  #     syscall


   sb $s2, board($s3)


# move $a0, $s2
 #       li $v0, 1
  #     syscall

    
     
    beq $s2, $zero, D_O_T

    #else hash
    H_A_S_H:
      li $v0, 4
      la $a0, hash
      syscall

      j for_2_continue
    
    D_O_T:
      li $v0, 4
     la $a0, dot
      syscall

  for_2_continue:
    addi $t7, $t7, 1
    j for_second

exit_second:
  li $v0, 4
  la $a0, eol
  syscall 
  addi $t6, $t6, 1
  j for_first

exit_first:
  jr $ra
  
 
