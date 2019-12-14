.data
# Arbitrary array of unsorted numbers, 0-9 for simplicity
array: .word 9,8,5,7,4,0,6,2,3,1

.text
.globl main
main:

	#la $8, array	# Store array location in $8
	lui $8, 4097	#Skips the above pseudo instruction, $8 <- 0x1001_0000
	
	# 'Print' array
	lw $16, 0($8)  		# $16 is A[0]
	lw $17, 4($8)  		# $17 is A[1]
	lw $18, 8($8)  		# $18 is A[2]
	lw $19, 12($8)  	# $19 is A[3]
	lw $20, 16($8)  	# $20 is A[4]
	lw $21, 20($8)  	# $21 is A[5]
	lw $22, 24($8)  	# $22 is A[6]
	lw $23, 28($8)  	# $23 is A[7]
	lw $24, 32($8)  	# $24 is A[8]
	lw $25, 36($8)  	# $25 is A[9]
	
	#For spacing
	nop		#No-op
	sll $0, $0, 0		#No-op
	sll $0, $0, 0		#No-op
	
	addi $9, $0, 9 		# Loop through 10 times, array is length n = 10
	addi $10, $0, 0 	# Counter 1 = i
	addi $11, $0, 0		# Counter 2 = j
	
	
loop: 
	
	sll $12, $11, 2		# Half of address computation
	
	sll $0, $0, 0		#No-op
	sll $0, $0, 0		#No-op
	
	add $12, $8, $12 	# New address A[j]
	
	sll $0, $0, 0		#No-op
	sll $0, $0, 0		#No-op
	
	lw $13, 0($12)  	# $t0 is A[j]
	
	sll $0, $0, 0		#No-op
	
	lw $14, 4($12)  	# $t1 is A[j+1]
	
	sll $0, $0, 0		#No-op
	sll $0, $0, 0		#No-op
	
	#bge $14, $13, if1	# if (A[j] <= A[j+1]), edited for control flow. Reality is if (A[j] > A[j+1])
	slt $1, $14, $13	
	
	sll $0, $0, 0		#No-op
	sll $0, $0, 0		#No-op
	
	beq $1, $0, if1		#Split the bge pseudo-instruction up
	
	sw $14, 0($12)  	#$14 is A[j]	
	sw $13, 4($12)  	#$13 is A[j+1]	
	
	if1:
		addi $11, $11, 1		#j++
		
		sub  $15, $9, $10 		#$15 is n-i-1
		
		sll $0, $0, 0		#No-op
		sll $0, $0, 0		#No-op
		
		bne  $11, $15, loop		
		addi $10, $10, 1 
		
		sll $0, $0, 0		#No-op
		
		addi $11, $0, 0 		#j = 0
		bne  $10, $9, loop
	
	
	
# Instead of actually printing, just going to throw array in the registers in order
print:

#For spacing
	sll $0, $0, 0		#No-op
	sll $0, $0, 0		#No-op
	sll $0, $0, 0		#No-op

# 'Print' array
	lw $16, 0($8)  		# $16 is A[0]
	lw $17, 4($8)  		# $17 is A[1]
	lw $18, 8($8)  		# $18 is A[2]
	lw $19, 12($8)  	# $19 is A[3]
	lw $20, 16($8)  	# $20 is A[4]
	lw $21, 20($8)  	# $21 is A[5]
	lw $22, 24($8)  	# $22 is A[6]
	lw $23, 28($8)  	# $23 is A[7]
	lw $24, 32($8)  	# $24 is A[8]
	lw $25, 36($8)  	# $25 is A[9]
	
#For spacing
	sll $0, $0, 0		#No-op
	sll $0, $0, 0		#No-op
	sll $0, $0, 0		#No-op


done:
li   $v0, 10          # system call for exit
syscall               # Exit!