.syntax unified

.data
.align 1
time:
	.word 0

.text

.global clock_reset
clock_reset:
	push {R0-R1, LR}

	ldr  R1, =time
	mov  R0, #0
	str  R0, [R1]

	pop  {R0-R1, PC}

.global print_time
print_time:
	push {R0, LR}

	ldr  R1, =time
	ldr  R0, [R1]

	mov  R3, R0

	mov  R2, #3600
	udiv R0, R3, R2
	mov  R1, #24
	bl   compute_modulo

	cmp  R0, #10
	bllt clock_fill_zero

	mov  R1, #10
	bl   lcd_print_number
	bl   usart_print_number

	mov  R0, ':'
	bl   lcd_write_data
	bl   USART1_putc

	mov  R1, #60
	udiv R0, R3, R1
	bl   compute_modulo

	cmp  R0, #10
	bllt clock_fill_zero

	push {R1}
	mov  R1, #10
	bl   lcd_print_number
	bl   usart_print_number
	pop  {R1}

	mov  R0, ':'
	bl   lcd_write_data
	bl   USART1_putc

	mov  R0, R3
	mov  R1, #60
	bl   compute_modulo

	cmp  R0, #10
	bllt clock_fill_zero

	mov  R1, #10
	bl   lcd_print_number
	bl   usart_print_number

	pop  {R0, PC}

clock_fill_zero:
	push {R0, LR}

	mov  R0, '0'
	bl   lcd_write_data
	bl   USART1_putc

	pop  {R0, PC}

// inputs: R0, R1
// outputs:
//          R1 <- R0/R1
//          R0 <- R0%R1
compute_modulo:
	push {R2-R3, LR}

	mov  R3, R0

	udiv R0, R1

	mul  R2, R0, R1
	sub  R1, R3, R2

	mov  R3, R0
	mov  R0, R1
	mov  R1, R3

	pop  {R2-R3, PC}

.global clock_tick
clock_tick:
	push {R0-R1, LR}

	ldr  R0, =time
	ldr  R1, [R0]

	add  R1, #1

	str  R1, [R0]

	pop  {R0-R1, PC}
