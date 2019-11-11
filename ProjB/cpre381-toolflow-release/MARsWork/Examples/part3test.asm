#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text
addi  $1,  $0,  1 		# Place “1” in $1
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

addi  $2,  $0,  10              # Place "10" in $v0 to signal an "exit" or "halt"
syscall                         # Actually cause the halt
