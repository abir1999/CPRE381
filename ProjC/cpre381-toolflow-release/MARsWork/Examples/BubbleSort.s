.data
array: .word 4,10,2,3,8,5,1,6,9,7

.text
.globl main
main:

	la $s4, array	# Store array's starting address in $s4
	
	lw $t0, 0($s4)  	# $t0 is A[0]
	lw $t1, 4($s4)  	# $t1 is A[1]
	lw $t2, 8($s4)  	# $t2 is A[2]
	lw $t3, 12($s4)  	# $t3 is A[3]
	lw $t4, 16($s4)  	# $t4 is A[4]
	lw $t5, 20($s4)  	# $t5 is A[5]
	lw $t6, 24($s4)  	# $t6 is A[6]
	lw $t7, 28($s4)  	# $t7 is A[7]
	lw $s0, 32($s4)  	# $t8 is A[8]
	lw $s1, 36($s4)  	# $t9 is A[9]

	li $s0, 0 	# i=0
	li $s1, 0 	# j=0
	li $s6, 9 	# storing the size n-1 i.e.9 here
	
	
loop: 
	
	sll $t7, $s1, 2		# multiply j's value with 4 so that address moves forward in increments of 4
	add $t7, $s4, $t7 	# j*4 + base address = address of A[j]
	lw $t0, 0($t7)  	# $t0 = A[j]
	lw $t1, 4($t7)  	# $t1 = A[j+1]
	
	bge $t1, $t0, ignore	# if (A[j] < A[j+1]) ignore and increment
	
	sw $t1, 0($t7)  	#$t0 = A[j]	
	sw $t0, 4($t7)  	#$t0 = A[j+1]	
	
	ignore:
		addi $s1, $s1, 1
		sub $s7, $s6, $s0 	#$s7 = N-i-1
		bne  $s1, $s7, loop
		addi $s0, $s0, 1 
		li $s1, 0 			# resetting  val of j to 0
		bne  $s0, $s6, loop

# Since we are directly modifying value at address, we can load from s4 address again
print:


	lw $t0, 0($s4)  	# $t0 is A[0]
	lw $t1, 4($s4)  	# $t1 is A[1]
	lw $t2, 8($s4)  	# $t2 is A[2]
	lw $t3, 12($s4)  	# $t3 is A[3]
	lw $t4, 16($s4)  	# $t4 is A[4]
	lw $t5, 20($s4)  	# $t5 is A[5]
	lw $t6, 24($s4)  	# $t6 is A[6]
	lw $t7, 28($s4)  	# $t7 is A[7]
	lw $s0, 32($s4)  	# $t8 is A[8]
	lw $s1, 36($s4)  	# $t9 is A[9]
	

li   $v0, 10          # system call to exit
syscall               # Exiting
