#Add
# Format:
#	ADD RD, RS1, RS2
# Description:
#	The contents of RS1 is added to the contents of RS2 and the result is 
#	placed in RD.

	.text 
	.global _start

.macro inc reg
	addi \reg,\reg,1
.endm

_start:
	la sp,stack_end
	li a0,3
	call sum_square

stop:
	j stop


#int sum_squares(unsigned int i)
#return sum
sum_square:
	#prologue
	addi sp,sp,-4
	sw ra,0(sp)

	mv s0,a0	#s0 is i 
	li s1,0		#sum
	li s2,1		#j
loop:
	bgt s2,s0,loop_end
	mv a0,s2
	call square
	add s1,s1,a0
	inc s2	
	j loop
loop_end:
	
	#epilogue
	lw ra,0(sp)
	addi sp,sp,4
	ret

#int square(unsigned int i)
square:
	#prologue
	addi sp,sp,-12
	sw s0,0(sp)
	sw s1,4(sp)
	sw s2,8(sp)
	
	mv s0,a0
	mul s1,s0,s0
	mv a0,s1

	#epilogue
	lw s0,0(sp)
	lw s1,4(sp)
	lw s2,8(sp)
	addi sp,sp,12

	ret

	nop
	

stack_start:
	.rept 12
	.word 0
	.endr
stack_end:
	
	.end
