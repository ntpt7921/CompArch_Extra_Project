# PROGRAM <name>
# DATA SEGMENT
###################################################################
.data
# VARIABLES

# put this here instead of inside the bitmap subpart 
# to make sure it is ordered first (at .data base address)
.globl display_mem_range
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
piece_count:
	.word	0

# DATA PROMPT



# CODE SEGMENT
###################################################################
.text
.globl main
main:
	
