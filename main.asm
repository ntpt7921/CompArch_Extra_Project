# PROGRAM <name>
# DATA SEGMENT
###################################################################
.data
# VARIABLES

# put this here instead of inside the bitmap subpart 
# to make sure it is ordered first (at .data base address)
.globl display_memory_range
display_memory_range:
	# the amount of space is subjected to change
	.space 10000

# DATA PROMPT



# CODE SEGMENT
###################################################################
.text
.globl main
main:
	# call function print_test_string in file print_and_ask.asm
	jal	print_test_string
	# terminate
	li	$v0, 10
	syscall