# BITMAP DISPLAY MODULE
# CONSTANT
###################################################################
# color in 24 bit RGB (8 bit for red, 8 for green, 8 for blue)
.eqv	COLOR_BLACK		0x000000
.eqv	COLOR_WHITE		0xFFFFFF
.eqv	COLOR_RED		0xFF0000
.eqv	COLOR_BLUE		0x0000FF
.eqv	COLOR_GREY		0xAAAAAA

.eqv	COLOR_PLAYER_1	COLOR_RED
.eqv 	COLOR_PLAYER_2	COLOR_BLUE

# size of the board is 8 by 8 pixel, each pixel can contains a piece
# since the game size is 6 row by 7 colukn, there will be some unused space
.eqv	SCREEN_SIZE		8
.eqv	ROW_NUM			6
.eqv	COLUMN_NUM		7
.eqv	COLOR_UNUSED	COLOR_GREY

# various macro will make use of the temp reg, some will have fixed use
# within this module
.eqv	MEMORY_BASE_REG	$t7
.eqv	COLOR_REG		$t8
.eqv	TEMP_REG		$t9

# MACRO
###################################################################
# the bitmap display originally count row and column for the upper left corner
# but we want to do indexing from the bottom left
# meaning that the row index must be inverted
# this macro get row index from row_reg and store the inverted result to TEMP_REG
.macro	M_INVERT_ROW_INDEX(%row_reg)
li		TEMP_REG, 7
sub		TEMP_REG, TEMP_REG, %row_reg
.end_macro

# get address (byte addressable) from array index (col index stored in col_reg,
# row index stored in row_reg, base address of memory region stored in membase_reg,
# result address is stored in result_reg)
.macro	M_GET_PIXEL_ADDR(%col_reg, %row_reg, %membase_reg, %result_reg)
sll		%result_reg, %row_reg, 3					#result_reg = row_reg * SCREEN_SIZE
add		%result_reg, %result_reg, %col_reg			#result_reg = row_reg * SCREEN_SIZE + col_reg
sll		%result_reg, %result_reg, 2					#change result_reg to byte offset
add		%result_reg, %result_reg, %membase_reg		#add memory base address
.end_macro

# set the pixel color given pixel address and color
.macro	M_SET_PIXEL_COLOR(%addr_reg, %color)
li		COLOR_REG, %color
sw		COLOR_REG, 0(%addr_reg)
.end_macro

# set all visible pixel to specified color
.macro	M_PAINT_ALL_SCREEN(%color)
li		$t1, SCREEN_SIZE
la		MEMORY_BASE_REG, display_mem_range

li 		$t2, 0
begin_loop_outer:
slt		$t4, $t2, $t1
beqz	$t4, exit_loop_outer

	# outer loop body
	li 		$t3, 0
	begin_loop_inner:
	slt		$t4, $t3, $t1
	beqz	$t4, exit_loop_inner

		# inner loop body
		M_INVERT_ROW_INDEX($t2)
		M_GET_PIXEL_ADDR($t3, TEMP_REG, MEMORY_BASE_REG, $t5)
		M_SET_PIXEL_COLOR($t5, %color)

	addi	$t3, $t3, 1
	j		begin_loop_inner
	exit_loop_inner:

addi	$t2, $t2, 1
j		begin_loop_outer
exit_loop_outer:
.end_macro

# the bottom and top row will be unused
# they will be paint with altenating color1 and color2
.macro	M_PAINT_UNUSED_ROW(%color1, %color2)
li		$t1, SCREEN_SIZE
la		MEMORY_BASE_REG, display_mem_range

li 		$t2, 0
li		$t3, 0
begin_loop_outer:
slt		$t4, $t2, $t1
beqz	$t4, exit_loop_outer

	# outer loop body
	M_INVERT_ROW_INDEX($0)
	M_GET_PIXEL_ADDR($t2, TEMP_REG, MEMORY_BASE_REG, $t5)
	M_GET_PIXEL_ADDR($t2, $0, MEMORY_BASE_REG, $t6)

	beqz	$t3, set_second_color
	M_SET_PIXEL_COLOR($t5, %color1)
	M_SET_PIXEL_COLOR($t6, %color1)
	j end_set_color
	set_second_color:
	M_SET_PIXEL_COLOR($t5, %color2)
	M_SET_PIXEL_COLOR($t6, %color2)
	end_set_color:
	xori	$t3, $t3, 1		#invert bit 1 of t3 (0 -> 1, 1 -> 0)

addi	$t2, $t2, 1
j		begin_loop_outer
exit_loop_outer:
.end_macro

# paint all unused column to specified color
.macro	M_PAINT_UNUSED_COL(%col_limit, %color)
li		$t1, SCREEN_SIZE
la		MEMORY_BASE_REG, display_mem_range

li 		$t2, %col_limit
begin_loop_outer:
slt		$t4, $t2, $t1
beqz	$t4, exit_loop_outer

	# outer loop body
	li 		$t3, 0
	begin_loop_inner:
	slt		$t4, $t3, $t1
	beqz	$t4, exit_loop_inner

		# inner loop body
		M_INVERT_ROW_INDEX($t3)
		M_GET_PIXEL_ADDR($t2, TEMP_REG, MEMORY_BASE_REG, $t5)
		M_SET_PIXEL_COLOR($t5, %color)

	addi	$t3, $t3, 1
	j		begin_loop_inner
	exit_loop_inner:

addi	$t2, $t2, 1
j		begin_loop_outer
exit_loop_outer:
.end_macro

# DATA SEGMENT
###################################################################
.data
# VARIABLES


# CODE SEGMENT
###################################################################
.text
j	test_program

# void update_display_clear(void)
.globl update_display_clear
update_display_clear:
M_PAINT_ALL_SCREEN(COLOR_WHITE)
M_PAINT_UNUSED_ROW(COLOR_BLACK, COLOR_GREY)
M_PAINT_UNUSED_COL(COLUMN_NUM, COLOR_UNUSED)
jr		$ra

# void update_display_add_new_piece(word_t column, byte_t player)
# column is pass in $a0, player in $a1
.globl update_display_add_new_piece
update_display_add_new_piece:
la		MEMORY_BASE_REG, display_mem_range
li		$t3, 1
li		$t4, 2
# $t1 = column_height[column]
la		$t1, column_height
add		$t1, $t1, $a0
lbu		$t1, 0($t1)
# invert row index
M_INVERT_ROW_INDEX($t1)
M_GET_PIXEL_ADDR($a0, TEMP_REG, MEMORY_BASE_REG, $t2)
# set the color base on $a1 (player) value
beq		$a1, $t3, set_color_for_first_player
beq		$a1, $t4, set_color_for_second_player
j		no_player_matched
set_color_for_first_player:
M_SET_PIXEL_COLOR($t2, COLOR_PLAYER_1)
j		end_if_set_color_base_on_player
set_color_for_second_player:
M_SET_PIXEL_COLOR($t2, COLOR_PLAYER_2)
j		end_if_set_color_base_on_player

no_player_matched:
end_if_set_color_base_on_player:
jr		$ra


# test program
test_program:
jal	update_display_clear
li	$t1, 1
la	$t2, column_height
sb	$t1, 0($t2)
sb	$t1, 1($t2)
sb	$t1, 2($t2)
sb	$t1, 3($t2)
sb	$t1, 4($t2)
sb	$t1, 5($t2)
sb	$t1, 6($t2)

li	$a0, 1
li	$a1, 1
jal update_display_add_new_piece
li	$a0, 2
li	$a1, 2
jal update_display_add_new_piece
li	$a0, 3
li	$a1, 1
jal update_display_add_new_piece
li	$a0, 4
li	$a1, 2
jal update_display_add_new_piece
# terminate
li	$v0, 10
syscall












