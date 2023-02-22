extern void uart_init(void);
extern void uart_puts(char *s);
extern int uart_getc();
extern int uart_putc(char ch);

void start_kernel(void)
{
	uart_init();
	uart_puts("Hello, RVOS!\n");

	//配置uart输入寄存器，控制台相当于一个串口，等待值输入
	
	while (1) {
		char c=uart_getc();
		uart_putc(c);
		uart_putc('\n');
	}; // stop here!
}

