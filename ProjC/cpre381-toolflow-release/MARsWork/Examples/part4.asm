#
# First part of the Lab 3 test program
#

# data section
.data

# code/instruction section
.text

##########phase 2##############

addi $1, $0, 10  # $1 stores 10

incr :
addi $2, $2, 1  #increment $2 by 1
bne $2, $1, incr


compare :
beq $2, $1, jumptest  #goto jumptest if they are equal


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
