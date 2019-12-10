# Function call example: recursive Fibonacci

main: 
# Set up arguments for call to fib_test
addi  $a0, $zero, 4	# arg0 = 4
addi  $a1, $zero, 10	# arg1 = 10
jal   fib_test

# Print result
add   $a0, $zero, $v0	# Copy result into argument register a0
jal   print_result

# Jump to "exit", rather than falling through to subroutines
j     program_end

#------------------------------------------------------------------------------
# Fibonacci test function. Equivalent C code:
#     int fib_test(arg0, arg1) {
#         return Fibonacci(arg0) + Fibonacci(arg1);
#     }
# By MIPS calling convention, expects arguments in 
# registers a0 and a1, and returns result in register v0.
fib_test:
# We will use s0 and s1 registers in this function, plus the ra register 
# to return at the end. Save them to stack in case caller was using them.
addi  $sp, $sp, -12	# Allocate three words on stack at once for three pushes
sw    $ra, 8($sp)	# Push ra on the stack (will be overwritten by Fib function calls)
sw    $s0, 4($sp)	# Push s0 onto stack
sw    $s1, 0($sp)	# Push s1 onto stack

# a1 may be overwritten by called functions, so save it to s1 (saved temporary),
# which called function won't change, so we can use it later for the second fib call
add  $s1, $zero, $a1

# Call Fib(arg0), save result in s0
# arg0 is already in register a0, placed there by caller of fib_test
jal   fib		# Call fib(4), returns in register v0
add   $s0, $zero, $v0	# Move result to s0 so we can call fib again without overwriting

# Call Fib(arg1), save result in s1
add   $a0, $zero, $s1	# Move original arg1 into register a0 for function call
jal   fib
add   $s1, $zero, $v0	# Move result to s1

# Add Fib(arg0) and Fib(arg1) into v0 (return value for fib_test)
add   $v0, $s0, $s1

# Restore original values to s0 and s1 registers from stack before returning
lw    $s1, 0($sp)	# Pop s1 from stack
lw    $s0, 4($sp)	# Pop s0 from stack
lw    $ra, 8($sp)	# Pop ra from the stack so we can return to caller
addi  $sp, $sp, 12	# Adjust stack pointer to reflect pops

jr    $ra		# Return to caller

#------------------------------------------------------------------------------
# Recursive Fibonacci function. Equivalent C code:
#
#     int Fibonacci(int n) {
#         if (n == 0) return 0;  // Base case
#         if (n == 1) return 1;  // Base case
#         int fib_1 = Fibonacci(n - 1);
#         int fib_2 = Fibonacci(n - 2);
#         return fib_1+fib_2;
#     }
fib:
# Test base cases. If we're in a base case, return directly (no need to use stack)
bne   $a0, 0, testone
add   $v0, $zero, $zero		# a0 == 0 -> return 0
jr    $ra
testone:
bne   $a0, 1, fib_body
add   $v0, $zero, $a0		# a0 == 1 -> return 1
jr    $ra

fib_body:
# Create stack frame for fib: push ra and s0
addi  $sp, $sp, -8	# Allocate two words on stack at once for two pushes
sw    $ra, 4($sp)	# Push ra on the stack (will be overwritten by recursive function calls)
sw    $s0, 0($sp)	# Push s0 onto stack

# Call Fib(n-1), save result in s0
add   $s0, $zero, $a0	# Save a0 argument (n) in register s0
addi  $a0, $a0, -1	# a0 = n-1
jal   fib
add   $a0, $s0, -2	# a0 = n-2
add   $s0, $zero, $v0	# s0 = Fib(n-1)

# Call Fib(n-2), compute final result
jal   fib
add   $v0, $v0, $s0	# v0 = Fib(n-2) + Fib(n-1)

# Restore registers and pop stack frame
lw    $ra, 4($sp)
lw    $s0, 0($sp)
addi  $sp, $sp, 8

jr    $ra	# Return to caller

#------------------------------------------------------------------------------
# Utility function to print results
print_result:
# Create stack frame for ra and s0
addi  $sp, $sp, -8
sw    $ra, 4($sp)
sw    $s0, 0($sp)

add   $s0, $zero, $a0	# Save argument (integer to print) to s0

li    $v0, 4		# Service code to print string
la    $a0, result_str	# Argument is memory address of string to print
syscall

li    $v0, 1		# Service code to print integer
add   $a0, $zero, $s0	# Argument is integer to print
syscall

# Restore registers and pop stack frame
lw    $ra, 4($sp)
lw    $s0, 0($sp)
addi  $sp, $sp, 8

#------------------------------------------------------------------------------
# Jump loop to end execution, so we don't fall through to .data section
program_end:
j    program_end


#------------------------------------------------------------------------------
.data
# Null-terminated string to print as part of result
result_str: .asciiz "\nFib(4)+Fib(10) = "
