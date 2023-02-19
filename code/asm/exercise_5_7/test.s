# Add
# Format:
#	ADD RD, RS1, RS2
# Description:
#	The contents of RS1 is added to the contents of RS2 and the result is 
#	placed in RD.

.macro set_struct struct

	la x5, \struct
	sw x6,0(x5)
	sw x7,4(x5) 
  
.endm

.macro inc reg

	addi \reg , \reg , 1

.endm

	.text			# Define beginning of text section
	.global	_start		# Define entry _start

_start:
	la x5,S			   
	li x6,0			
	li x7,0			# x7 is len
loop:	lb x6,0(x5)
	beqz x6,outloop
	inc x5
	inc x7
	j loop
outloop:
	

stop:
	j stop			# Infinite loop to stop execution

S:
	.string "hello,world!\0"

	.end			# End of file
