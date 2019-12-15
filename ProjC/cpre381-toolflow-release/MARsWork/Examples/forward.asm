# data section
.data

# code/instruction section
.text

addi  $1,  $0,  1 		# Place “1” in $1
addi  $2,  $0,  5			#2
add   $3, $1, $2
add   $4,  $3, $2
sub	  $2,  $4, $2
lui   $4, 16
sra   $5, $4, 2
addi  $2,  $0,  10              # Place "10" in $v0 to signal an "exit" or "halt"
nop
nop
nop
syscall                         # Actually cause the halt