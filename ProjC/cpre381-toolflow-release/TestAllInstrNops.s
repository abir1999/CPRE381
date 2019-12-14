.data
.text
.globl main

main:

	#Some instructions to set things up
	addi $24, $0, 1			#$25 <- 1
	lui $25, 32768			#$24 <- 0x8000 
	
	nop			#Nop
	nop			#Nop
	nop
	#-----------------------------------

	#Add
	add $8, $24, $25 		#$8 <- 0? or 0x8000_0001?  (mars is being weird)
	
	#Addi
	addi $9, $0, 2			#$9 <- 2
	
	#Addu
	addu $10, $24, $25		#$10 <- 0x8000_0001
	
	#Addiu
	addiu $11, $25, 2		#$11 <- 0x8000_0002
	
	
	#------------
	#Sub
	sub $12, $24, $24		#$12 <- 0x0000_0000
	
	#Subu
	subu $13, $25, $24		#$13 <- 0x7FFF_FFFF
	
	nop
	#-----------------------------------
	#And
	and $14, $11, $10		#$14 <- 0x8000_0000
	
	#Andi
	andi $15, $24, 3		#$15 <- 1
	
	#Or
	or $16, $25, $13		#$16 <- 0xFFFF_FFFF
	
	#Ori
	ori $17, $24, 2			#$17 <- 3
	
	nop			#Nop
	
	#Nor
	nor $18, $24, $0		#$18 <- 0xFFFF_FFFE
	
	nop
	
	#Xor
	xor $19, $24, $17		#$19 <- 2
	
	
	#-----------------------------------
	#Sll
	sll $20, $16, 4			#$20 <- 0xFFFF_FFF0
	
	#Srl
	srl $21, $16, 4			#$21 <- 0x0FFF_FFFF
	
	#Sra
	sra $22, $16, 4			#$22 <- 0xFFFF_FFFF
	
	#------------
	#Slt
	slt $23, $16, $24		#23 <- 1
	
	#Sltu
	sltu $8, $16, $24		#8 <- 0
	
	#Slti
	slti $9, $16, 1			#9 <- 1
	
	#Sltiu
	sltiu $10, $16, 1		#10 <- 0
	
	
	#-----------------------------------
	#Lui
	lui $11, 4097			#$11 <- 0x1001_0000
	
	nop
	nop
	nop
	
	#Sw
	sw $24, 0($11)			#Dmem @1 <- 1
	
	
	#Lw
	lw $12, 0($11)			#$11 <- 1
	
	nop
	nop
	#-----------------------------------
	#Beq
	beq $24, $23, beq		#Skip to beq:
	lui $1, 48879			#$1 <- 0xBEEF_0000
	
	beq:
	
	#Bne
	bne $24, $22, bne		#Skip to bne:
	lui $1, 65261			#$1 <- 0xFEED_0000
	
	bne:
	
	#-----------------------------------
	#J
	j jump					#Skip to jal
	lui $1, 47825			#$1 <- 0xBAD1_0000
	
	jump:
	
	#Jal
	jal jal					#Skip to jr
	
	
	# Exit program
    li $v0, 10				#addiu $2, $0, 10
    syscall
	
	
	jal:
	
	nop
	nop
	nop
	
	#Jr
	jr $31				#Return to jal to end program
	lui $1, 47827			#$1 <- 0xBAD3_0000
	
	
	
	
	
	
	
	
	
	
	
	# Exit program
    li $v0, 10
    syscall

	
	
	
	#Stall is blocking PC reg from updating on jr because jr was forwarded, possibly and pc stall with final jump/branch calculation?