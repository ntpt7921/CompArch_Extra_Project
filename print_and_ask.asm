# PROGRAM <name>
# DATA SEGMENT
###################################################################
.data
#Cac dinh nghia bien
int_col: .word 7
int_row: .word 6
#Cac cau in du lieu
welcome: .asciiz "Welcome to the game of Connect Four\n"
start1: .asciiz "In this game, two player (1 and 2) will take turn to place new pieces into a arbitrary column. There will be 7 columns, each with 6 rows.\n"
start2: .asciiz "When put into a column, the piece will naturally fall to the lowest position. Pieces within each column will stack.\n"
start3: .asciiz "The game ends when 4 pieces of a player form a horizontal, vertical or diagonal line. In such case, that player is the winner."
start4: .asciiz "In the case there is to space left to place new piece, the result is a draw between two player.\n"

currentPlayer: .asciiz "Now is the turn of player "

placeCol: .asciiz "In which column do you want to place the next piece (0 to 6):\n"

ending: .asciiz "The game ended as a "
draw: .asciiz "draw.\n"
win1: .asciiz "win for player #1.\n"
win2: .asciiz "win for player #2.\n"

askPlayer: .asciiz "Please input the player that will go first (1 or 2):\n"
notAccept: .asciiz "Accepted value is 1 or 2.\n"

outrange: .asciiz "Accepted value is within range (0 - 6).\n"
colfull: .asciiz "The column chosen is full, please choose another column.\n"

# CODE SEGMENT
###################################################################
.text
.globl  print_welcome_prompt
print_welcome_prompt:
    la $a0, welcome
	li $v0, 4
	syscall

	la $a0, start1
	li $v0, 4
	syscall

	la $a0, start2
	li $v0, 4
	syscall

	la $a0, start3
	li $v0, 4
	syscall

	la $a0, start4
	li $v0, 4
	syscall

        jr $ra

.globl  print_current_player_prompt
print_current_player_prompt:
  	la $a0, currentPlayer
	li $v0, 4
	syscall

	lb $a0, current_player
	li $v0, 1
	syscall

	la $a0, '\n'
	li $v0, 11
	syscall

	jr $ra

.globl  print_placement_column_prompt
print_placement_column_prompt:

      	la $a0, placeCol
	li $v0, 4
	syscall

	jr $ra

.globl  print_ending_prompt
print_ending_prompt:

  	la $a0, ending
	li $v0, 4
	syscall

  	lb $t0, winner
  	beq $t0,$zero,drawstate
  	li $t1, 1
  	beq $t0,$t1,win1state
  	la $a0, win2
	li $v0, 4
	syscall
	j exit

    drawstate:
    	la $a0, draw
	li $v0, 4
	syscall
	j exit
    win1state:
        la $a0, win1
	li $v0, 4
	syscall
	j exit
    exit: jr $ra

.globl  ask_for_first_player
ask_for_first_player:
    	la $a0, askPlayer
	li $v0, 4
	syscall

	addi $sp, $sp, -4
	sw $t0, 0($sp)
    loop:
       	li $v0, 5
       	syscall

       	li $t1, 1
       	beq $v0,$t1,accept
       	li $t1, 2
       	beq $v0,$t1,accept
       	la $a0, notAccept
	li $v0, 4
	syscall
	j loop
    accept:
    	lw $t0, 0($sp)
    	addi $sp,$sp,4
    	jr $ra

.globl  ask_for_new_piece_column
ask_for_new_piece_column:
	addi $sp, $sp, -8
	sw $s0, 0($sp)
	sw $ra, 4($sp)
	
    la $a0, placeCol
	li $v0, 4
	syscall
    reenter:
        li $v0, 5
        syscall
        move $s0, $v0

        lw $t0,int_col
		slt $t1,$s0,$t0
        beqz $t1,retry

    	move $a0, $s0
    	jal check_column_has_space
    	beqz $v0,recol
    	move $v0, $s0

		lw $ra, 4($sp)
		lw $s0, 0($sp)
    	addi $sp,$sp,8
    	jr $ra

    retry:
    	la $a0,outrange
    	li $v0,4
    	syscall
    	j reenter
    recol:
      	la $a0,colfull
    	li $v0,4
    	syscall
    	j reenter
