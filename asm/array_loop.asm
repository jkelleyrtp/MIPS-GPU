# Problem statement: Add 5 to each element in an array

# Preconditions: 
#    Array base address stored in register $t0
#    Array size (# of words) stored in register $t1
la 	$t0, my_array		# Store array base address in register (la pseudoinstruction)
addi	$t1, $zero, 16		# 16 elements in array


# Solution pseudocode:
#    i = 0;
#    while i < 16 {
#      my_array[i] = my_array[i] + 5

# Initialize variables
addi	$t2, $zero, 0		# i, the current array element being accessed
addi	$t3, $t0, 0		# address of my_array[i] (starts from base address for i=0)

LOOPSTART:
beq 	$t2, $t1, LOOPEND	# if i == 16: GOTO DONE

lw	$t5, 0($t3)		# temp = my_array[i]		{LOAD FROM MEMORY}
addi	$t5, $t5, 5		# Add 5 to element temp		{MODIFY IN REGISTER}
sw	$t5, 0($t3)		# my_array[i] = temp		{STORE TO MEMORY}

addi	$t2, $t2, 1		# increment i counter
addi	$t3, $t3, 4		# increment address by 1 word
j	LOOPSTART		# GOTO start of loop
LOOPEND:
j	LOOPEND			# Jump trap prevents falling off end of program



# Pre-populate array data in memory
#  Note that I have given the data values a distinctive pattern to help with debugging
.data 
my_array:
0x00000000	# my_array[0]
0x11110000
0x22220000
0x33330000
0x44440000
0x55550000
0x66660000
0x77770000
0x88880000
0x99990000
0xAAAA0000
0xBBBB0000
0xCCCC0000
0xDDDD0000
0xEEEE0000
0xFFFF0000
