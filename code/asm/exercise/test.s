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

.macro get_struct struct

	la x5, \struct
	lw x6,0(x5)
	lw x7,4(x5)

.endm

	.text			# Define beginning of text section
	.global	_start		# Define entry _start

_start:
	li x6,0x12345678
	li x7,0x87654321
	set_struct S
	li x6,0
	li x7,0
	get_struct S

stop:
	j stop			# Infinite loop to stop execution

S:
	.word 0,0

	.end			# End of file
