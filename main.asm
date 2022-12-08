# PROGRAM <name>
# DATA SEGMENT
###################################################################
.data
# VARIABLES


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