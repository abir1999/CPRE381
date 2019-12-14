#
# First part of the Lab 3 test program
#

# data section
.data
str1: .asciiz "apple"

# code/instruction section
.text
la $a0, str1 #store address of str1 variable in dmem
lw $s0, 0($a0) 

##########################
addi  $1,  $0,  1 		# Place “1” in $1
lui   $1,4097			#prepare base address of data memory
addi  $2, $0, 2019		#reg 2 holds a value to be stored in memory
sw    $2, 4($1)			# store 2019 in Dmem index 2
lw    $3, 4($1)			#read this value from the memory and store in register 3
addi  $2,  $0,  4		# Place “5” in $2
add	  $3,  $1, 	$2		# $3 = $1 + $2 = 5
sub   $4,  $3,	$1 		# $4 = $3 - $1 = 4
addiu $4,  $0,	10		# Place "10" in $4
and	  $5,  $4,  $3		# $4  AND $3 store in $5
lui	  $6,  150			# shift left 16 150, store in $6
#sw	  $6,  0($2)		# store $6 in value(address)in $2
xor   $7,  $6 ,$4
xori  $7,  $7 ,1234
or	  $8,  $7 , $2
ori	  $8,  $8 , 5555
slt	  $9,  $6 , $6
slt   $9,  $6 , $2
slti  $10, $2 , 9000
addi  $10, $0 , 13
sltiu $11, $4, 13		#check if $4 = 10, is less than 13 
sltu  $11, $4, $10      #same thing, but with register
sll   $11, $6, 2
srl	  $11, $11, 4
addi  $12, $0, -54
sra   $11, $12, 5
sllv  $13, $11, $2
srlv  $13, $11, $4
srav  $14, $13 , $1
##########phase 2##############

addi $1, $0, 10  # $1 stores 10

incr :
addi $2, $2, 1  #increment $2 by 1 (originally value is 4)
bne $2, $1, incr


compare :
beq $2, $0, jumptest # shouldn't branch to jumptest
beq $2, $1, jumptest  #goto jumptest if they are equal(should be equal)


branchcheck:
addi $6, $0, 100   #if not branching properly, then $6 would have value 100

jumptest :
jal linked
j exit		#now you've returned from linked, exit the program##


linked :
##just do something, and then go back to where left off##
addi $5, $0, 100
jr $ra





exit:
addi  $2,  $0,  10              # Place "10" in $v0 to signal an "exit" or "halt"
syscall                         # Actually cause the halt
