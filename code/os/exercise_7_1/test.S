#include "platform.h"

.macro inc reg

	addi \reg,\reg,1

.endm

	# size of each hart's stack is 1024 bytes
	.equ	STACK_SIZE, 1024

	.global	_start

	.text
_start:
	# park harts with id != 0
	csrr	t0, mhartid		# read current hart id
	mv	tp, t0			# keep CPU's hartid in its tp for later usage.
	bnez	t0, park		# if we're not on the hart 0
					# we park the hart
	# Setup stacks, the stack grows from bottom to top, so we put the
	# stack pointer to the very end of the stack range.
	slli	t0, t0, 10		# shift left the hart id by 1024
	la	sp, stacks + STACK_SIZE	# set the initial stack pointer
					# to the end of the first stack space
	add	sp, sp, t0		# move the current hart stack pointer
					# to its place in the stack space

	j	start_kernel		# hart 0 jump to c

park:
	wfi
	j	park


start_kernel:
	call uart_init
	la a0,hello_str
	call uart_puts

stop:
	j stop

# #define uart_read_reg(reg) (*(UART_REG(reg)))
uart_read:                  #读UART寄存器，a0传入寄存器

	li t0,UART0
	add t0,t0,a0
	lb a0,0(t0)

	ret

# #define uart_write_reg(reg, v) (*(UART_REG(reg)) = (v))
uart_write:                  #写UART寄存器，a0传入寄存器，a1传入要写的值

	li t0,UART0
	add t0,t0,a0
	sb a1,0(t0)

	ret
	
uart_init:
	addi sp,sp,-4
	sw ra,0(sp)

# uart_write_reg(IER, 0x00);
	li a0,IER           
	li a1,0
	call uart_write

# uint8_t lcr = uart_read_reg(LCR); s0保存lcr
	li a0,LCR
	call uart_read
	mv s0,a0

# uart_write_reg(LCR, lcr | (1 << 7));
	li a0,LCR
	li t0,0x80
	OR a1,s0,t0
	call uart_write

# uart_write_reg(DLL, 0x03);
	li a0,DLL
	li a1,0x03
	call uart_write

# uart_write_reg(DLM, 0x00);
	li a0,DLM
	li a1,0x00
	call uart_write

# lcr = 0;
	li s0,0

# uart_write_reg(LCR, lcr | (3 << 0));
	li a0,LCR
	li t0,3
	OR a1,s0,t0
	call uart_write


	lw ra,0(sp)
	addi sp,sp,4
	ret

# int uart_putc(char ch)
# {
# 	while ((uart_read_reg(LSR) & LSR_TX_IDLE) == 0);
# 	return uart_write_reg(THR, ch);
# }
# 使用a1传递ch
uart_putc:
	addi sp,sp,-12
	sw ra,0(sp)
	sw s0,4(sp)
	sw s1,8(sp)

loop_put:
	li a0,LSR
	call uart_read
	mv s0,a0
	andi s0,s0,0x20
	beqz s0,loop_put
	
	li a0,THR
	call uart_write

	lw s1,8(sp)
	lw s0,4(sp)
	lw ra,0(sp)
	addi sp,sp,4
	ret

# void uart_puts(char *s)
# {
# 	while (*s) {
# 		uart_putc(*s++);
# 	}
# }
uart_puts:
	addi sp,sp,-8
	sw ra,0(sp)
	sw a0,4(sp)


# 加载初始值
	lw s0,4(sp)

loop_puts:
	lb a1,0(s0)
	beqz a1,loop_puts_end
	call uart_putc
	inc s0
	j loop_puts
loop_puts_end:

	lw ra,0(sp)
	addi sp,sp,4
	ret


hello_str:
	.string "Hello,RVOS!\0"

stacks:
	.skip	STACK_SIZE * MAXNUM_CPU # allocate space for all the harts stacks

	.end				# End of file
