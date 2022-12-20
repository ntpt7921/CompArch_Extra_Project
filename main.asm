# PROGRAM <name>
# DATA SEGMENT
###################################################################
.data
# VARIABLES

# put this here instead of inside the bitmap subpart
# to make sure it is ordered first (at .data base address)
.globl display_mem_range
.align 2			# align to word boundary
display_mem_range:
	.space	256		# 8 * 8 * 4 byte = 64 word = 64 pixel

.globl end_game
end_game:
	.byte	0		# boolean

.globl current_player
current_player:
	.byte	0		# can be 1 or 2 for player #1 or #2

.globl winner
winner:
	.byte	0		# can be 1 or 2 for player #1 or #2, 0 when tie

# store the state of all position within the game
# a position can have 3 value: 0 (empty), 1 (player #1 piece), 2 (player #2 piece)
.globl piece_position
piece_position:
	.space	42		# 42 byte of 2-dimensional array (6 row * 7 column), each position is one byte

# since pieces stack, each column will have a height value
# this is used to find the position for the next piece
.globl column_height
column_height:
	.space	7		# array of 7 element (each one byte)

# piece count is used to determine if there is still space left
# the maximum value is COLUMN_NUM * ROW_NUM
.globl piece_count
.align 2			# align to word boundary
piece_count:
	.word	0

# DATA PROMPT



# CODE SEGMENT
###################################################################
.text
.globl main
main:
	jal initialize
	jal print_welcome_prompt
	jal ask_for_first_player		# v0 is the returned value
	sb $v0, current_player
LOOP:
	lb $t0, end_game
	beq $t0, 1, EXIT

	jal print_current_player_prompt

	jal ask_for_new_piece_column
	move $s0, $v0					# save the user selected column

	add $a0, $v0, $zero				# argument_1 (column)
	lb $a1, current_player			# argument_2 (player)
	jal place_piece_into_column		# a0,a1 is argument

	# piece_count++
	lw $t1, piece_count
	addi $t1, $t1, 1
	sw $t1, piece_count

	move $a0, $s0					# user selected column as argument 1
	lb $a1, current_player			# current player as argument 2
	jal update_display_add_new_piece# a0,a1 is argument

	move $a0, $s0					# user selected column as argument 1
	jal update_game_state			# a0 is argument

	jal change_to_next_player_turn
	j LOOP
EXIT:
	jal print_ending_prompt
	# exit
	li	$v0, 10
	syscall
