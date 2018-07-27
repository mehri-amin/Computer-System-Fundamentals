# prog.s ... Game of Life on a NxN grid
#
# Needs to be combined with board.s
# The value of N and the board data
# structures come from board.s
#
# Written by Mehri Amin, September 2017

#-------------------------------------------#
   .data
main_ret_save: .space 4

#-------------to use in main----------------#
maxiters:     #int maxiters;
  .word 0

msg1:
  .asciiz "# Iterations: "

msg2:
  .asciiz "\n=== After iteration "

msg3:
  .asciiz " ===\n"

#----to use in function copyBackAndShow----#
dot:
  .asciiz "."

hash:
  .asciiz "#"

eol:
  .asciiz "\n"

  .text

###############################################################################################
############################ MAIN FUNCTION ####################################################
###############################################################################################

#------------------------------------------#
#        KEEPING TRACK OF REGISTERS        #
#------------------------------------------#
# t0= maxiters  t1= N  t2= n   t3= i  t4= j#
#                                          #
# t5= offset  t6= Board                    #
#                                          #
# t7= comparing number  t8=   t9= s0= nn   #   
#                                          #
# s1= newboard  s2=   s3=                  #  
#                                          #   
# s4=   s5=    s6=   s7=                   #
#                                          #
#------------------------------------------#

  .globl main
main:
  sw $ra, main_ret_save
  
  # printf("# Iterations: ");
  la $a0, msg1
  li $v0, 4
  syscall

  # scanf("%d", &maxiters);
  li $v0, 5
  syscall
  sw $v0, maxiters
  lw $t0, maxiters

  # for (int n = 1; n <= maxiters; n++) {
  lw $t1, N #N
  li $t2, 1 #n
  li $t3, 0 #i
  li $t4, 0 #j

  for_n:
    bgt $t2, $t0, exit_n

  # for (int i = 0; i < N; i++) {
    li $t3, 0 #i
    for_i:
      beq $t3, $t1, exit_i

  # for (int j = 0; j < N; j++) {
      li $t4, 0   #j
      for_j:
        beq $t4, $t1, exit_j

  # int nn = neighbours(i,j);
        move $a1, $t3
        move $a2, $t4
        jal neighbours
        move $s0, $v1   # nn

       # if (board[i][j] == 1) {

        # get offset: [i][j]
        mul $t5, $t1, $t3   # N*i
        add $t5, $t5, $t4   # (N*i)+j
        lb $t6, board($t5)  # board[i][j]
        lb $s1, newBoard($t5) #newboard[i][j]

        # using $t7 as a comparing number
        li $t7, 1
        bne $t7, $t6, checkif_nn_3

          # if (nn < 2)
          li $t7, 2
          blt $s0, $t7, set_0

          # else if (nn ==2 
          li $t7, 2
          beq $s0, $t7, set_1

          # || nn == 3)
          li $t7, 3
          beq $s0, $t7, set_1

          # else newboard[i][j] = 0;
          j set_0

        # else if (nn == 3)
        checkif_nn_3:
          li $t7, 3
          beq $t7, $s0, set_1

          #else newboard[i][j] = 0;
          j set_0

          # newboar[i][j] = 1
          set_1:
            li $s1, 1
            sb $s1, newBoard($t5)
            j iterate_j

          set_0:
            li $s1, 0
            sb $s1, newBoard($t5)
            j iterate_j
            
            # j++
            iterate_j:
              addi $t4, $t4, 1
              j for_j

        # i++
        exit_j:
          addi $t3, $t3, 1
          j for_i

      exit_i:
        # === After iteration %d 
        la $a0, msg2
        li $v0, 4
        syscall

        # ,n);
        move $a0, $t2
        li $v0, 1
        syscall

        # ===\n
        la $a0, msg3
        li $v0, 4
        syscall
        
        # copyBackAndShow()
        jal copyBackAndShow
        
        # n++
        addi $t2, $t2, 1
        j for_n

    exit_n:
      j end_main

end_main:
   lw   $ra, main_ret_save
   jr   $ra
   # return 0
   li $v0, 10
   syscall
###############################################################################################
############################ NEIGHBOURS #######################################################
###############################################################################################

#------------------------------------------#
#        KEEPING TRACK OF REGISTERS        #
#------------------------------------------#
# t0= maxiters  t1= N  t2= n   t3= i  t4= j#
#                                          #
# t5= nn  t6= x t7= y t8= 1 t9= N-1        #
#                                          #
# s0= nn s1= newboard  s2= x+i  s3= j+y    #
#                                          #
# s4= offset s5= board   s6= N  s7=        #
#                                          #
#------------------------------------------#

  .globl neighbours
neighbours:

  # int nn = 0;
  li $t5, 0   
  
  # for (int x = -1; x <= 1; x++) {
  li $t6, -1    #x
  li $t7, -1    #y
  li $t8,  1    # for condition
  
  # for N-1
  lw $s6,N 
  li $t9, 1
  addi $t9, $s6,-1

  for_x:
    bgt $t6, $t8, exit_x

    # for (int y = -1; y <= 1; y++) {
    li $t7, -1    #y
    for_y:
      bgt $t7, $t8, exit_y

      ########### IF STATEMENTS ##############
      #--------------------------------------#

      # i+x
      add $s2, $t6, $a1   # a1 = i from main
      
      # if (i+x < 0 ) continue;
      blt $s2, $zero, continue

      # if (i+x > N-1) continue;
      bgt $s2, $t9, continue

      # j+y
      add $s3, $t7, $a2   # a2 = j from main

      # if (j+y < 0 ) continue
      blt $s3, $zero, continue
      
      # if (j+y > N-1) continue;
      bgt $s3, $t9, continue

      # if (x != 0) offset
      bne $t6, $zero, offset
 
      # if (y != 0) offset
      beq $t7, $zero, continue
      

      #-------------------------------------#

      # if (board[i+x][j+y] == 1) nn++;
      offset:
       mul $s4, $s6, $s2  # N*(i+x)
       add $s4, $s4, $s3  # N*(i+x) + (j+y)
       lb $s5, board($s4) # board[i+x][j+y]

       li $t8, 1
       bne $s5, $t8, continue

       # else nn++
       addi $t5, $t5, 1
       
      # y++
      continue:
        addi $t7, $t7, 1
        j for_y

      # x++
      exit_y:
        addi $t6, $t6, 1
        j for_x

    exit_x:
      move $v1, $t5 #$t5 = nn
      jr $ra


###############################################################################################
############################ COPYBACKANDSHOW ##################################################
###############################################################################################

#------------------------------------------#
#        KEEPING TRACK OF REGISTERS        #
#------------------------------------------#
# t0= maxiters  t1= N  t2= n   t3= i  t4= j#
#                                          #
# t5=  t6= i  t7= j  t8=   t9=             #
#                                          #
# s0= offset s1= newboard s2= board  s3=   #
#                                          #
# s4=  s5=   s6=  s7=                      #
#                                          #
#------------------------------------------#

     

.globl copyBackAndShow
copyBackAndShow:
  
  lw $t1, N   #N
  li $t3, 0   #i
  lw $t4, 0   #j
  
  # for (int i = 0; i < N; i++) {
  for_one:
    ble $t1, $t3, exit_one
    
  # for (int j = 0; j < N; j++) {
    li $t4, 0 #j
    for_two:
      ble $t1, $t4, exit_two 

      # OFFSET
      mul $s0, $t1, $t3 # N*i
      add $s0, $s0, $t4 # (N*i)+j

      lb $s1, board($s0)
      lb $s2, newBoard($s0)

      # board[i][j] = newboard[i][j];
      sb $s2, board($s0)
      # if (board[i][j] == 0) putchar '.'
      beq $s2, $zero, putchar_dot
      
      putchar_hash:
        la $a0, hash
        li $v0, 4
        syscall
        j for_continue
    
      putchar_dot:
        la $a0, dot
        li $v0, 4
        syscall
        j for_continue

      # j++
      for_continue:
        addi $t4, $t4, 1
        j for_two

    exit_two:
      la $a0, eol
      li $v0, 4
      syscall 
      
      # i++
      addi $t3, $t3, 1
      j for_one

  exit_one:
    jr $ra
  
