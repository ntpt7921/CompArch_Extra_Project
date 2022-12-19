# PROGRAM <name>
# DATA SEGMENT
###################################################################
.data
# VARIABLES
latest_peice_position:
	 .byte 0

# CODE SEGMENT
###################################################################
.text

.globl initialize
initialize:
	li $t0, 0
	li $t1, 0
	sb $t0, end_game
	sb $t0, current_player
	sb $t0, winner
	sb $t0, piece_count
	init_loop:
		sb $t0, piece_position($t1)
		addi $t1, $t1, 1
		blt $t1, 42, init_loop
	li $t1, 0
	init_loop_height:
		sb $t0, column_height($t1)
		addi $t1, $t1, 1
		blt $t1, 7, init_loop_height
		
	addi	$sp, $sp, -4
	sw		$ra, 0($sp)
	jal update_display_clear
	lw		$ra, 0($sp)
	addi	$sp, $sp, 4
	
	jr $ra
	
.globl place_piece_into_column
place_piece_into_column:
	#lb $a0, next_piece_column
	#lb $a1, current_player
	#piece_position = column + column_height * 7
	lb $t3, column_height($a0)
	mul $t2, $t3, 7
	add $t1, $a0, $t2 #$t1: peice_position
	sb $a1, piece_position($t1)
	sb $t1, latest_peice_position 
	addi $t3, $t3, 1
	sb $t3, column_height($a0)
	jr $ra
	
.globl change_to_next_player_turn
change_to_next_player_turn:
	lb $t1, current_player
	beq $t1, 1, change_to_2
	li $t1, 1
	sb $t1, current_player
	jr $ra
change_to_2:
	li $t1, 2
	sb $t1, current_player
	jr $ra
	
.globl check_column_has_space
check_column_has_space:
	#$a0: column
	lb $t1, column_height($a0)
	bge $t1, 6, no_space
	li $v0, 1
	jr $ra
no_space:
	li $v0, 0
	jr $ra
	
.globl update_game_state
update_game_state:
	#$a0: coolumn
	lb $t0, latest_peice_position 
	lb $t1, piece_position($t0) #lastest player
	addi $t9, $0, 1 # count peice
	li $t7, 7 #$t7 = const 7
	#check vertically
	Down:
		blt $t0, 7, ExitDown
		addi $t0, $t0, -7
		lb $t3, piece_position($t0)
		bne $t3, $t1, ExitDown
		addi $t9, $t9, 1
		bgt $t9, 3, WinEndGame
		j Down
ExitDown:
	li $t9, 1
	lb $t0, latest_peice_position
	#check horizontally
	Left:
		div $t0, $t7
		mfhi $t3 #$t3 = $t0 % 7
		beqz $t3, ExitLeft #If $t3 = 0, then cannot check left
		addi $t0, $t0, -1
		lb $t4, piece_position($t0)
		bne $t4, $t1, ExitLeft
		addi $t9,$t9, 1
		bgt $t9, 3, WinEndGame
		j Left
ExitLeft:
	lb $t0, latest_peice_position
	Right:
		div $t0, $t7
		mfhi $t3 #$t3 = $t0 % 7
		beq $t3, 6, ExitRight #If $t3 = 6, then cannot check right
		addi $t0, $t0, 1
		lb $t4, piece_position($t0)
		bne $t4, $t1, ExitRight
		addi $t9,$t9, 1
		bgt $t9, 3, WinEndGame
		j Right
ExitRight:
	li $t9, 1
	lb $t0, latest_peice_position
	#check diagonal
	#UpperLeft to LowerRight
	UpperLeft:
		bgt $t0, 34, ExitUpperLeft
		div $t0, $t7
		mfhi $t3
		beqz $t3, ExitUpperLeft
		addi $t0, $t0, 6
		lb $t4, piece_position($t0)
		bne $t4, $t1, ExitUpperLeft
		addi $t9, $t9, 1
		bgt $t9, 3, WinEndGame
		j UpperLeft
ExitUpperLeft:
	lb $t0, latest_peice_position
	LowerRight:
		blt $t0, 7, ExitLowerRight
		div $t0, $t7
		mfhi $t3
		beq $t3, 6, ExitLowerRight
		addi $t0, $t0, -6
		lb $t4, piece_position($t0)
		bne $t4, $t1, ExitLowerRight
		addi $t9, $t9, 1
		bgt $t9, 3, WinEndGame
		j LowerRight
ExitLowerRight:
	li $t9, 1
	lb $t0, latest_peice_position	
	#UpperRigh to LowerLeft
	UpperRight:
		bgt $t0, 34, ExitUpperRight
		div $t0, $t7
		mfhi $t3
		beq $t3, 6, ExitUpperRight
		addi $t0, $t0, 8
		lb $t4, piece_position($t0)
		bne $t4, $t1, ExitUpperRight
		addi $t9, $t9, 1
		bgt $t9, 3, WinEndGame
		j UpperRight
ExitUpperRight:
	lb $t0, latest_peice_position
	LowerLeft:
		blt $t0, 7, ExitLowerLeft
		div $t0, $t7
		mfhi $t3
		beqz $t3, ExitLowerLeft
		addi $t0, $t0, -8
		lb $t4, piece_position($t0)
		bne $t4, $t1, ExitLowerLeft
		addi $t9, $t9, 1
		bgt $t9, 3, WinEndGame
		j LowerLeft
ExitLowerLeft:		
CheckDraw:
	lb $t2, piece_count
	beq $t2, 42, Draw
	jr $ra
WinEndGame:
	li $t0, 1
	sb $t0, end_game
	lb $t0, current_player
	sb $t0, winner
	jr $ra
Draw:
	li $t0, 1
	sb $t0, end_game
	lb $t0, 0
	sb $t0, winner
	jr $ra
