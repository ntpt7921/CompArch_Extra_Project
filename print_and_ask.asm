# PROGRAM <name>
# DATA SEGMENT
###################################################################
.data
# VARIABLES
test_string:
	.asciiz "This is the test string"



# CODE SEGMENT
###################################################################
.text
.globl print_test_string
print_test_string:
	li	$v0, 4
	la	$a0, test_string
	syscall
	jr	$ra
