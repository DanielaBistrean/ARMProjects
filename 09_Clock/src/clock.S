.syntax unified

.data
.align 1
hour:
	.byte 0
minutes:
	.byte 0
seconds:
	.byte 0

.text

.global clock_reset
clock_reset:
	push {R0, LR}

	ldr  R1, =hour
	mov  R0, #0
	strb R0, [R1]

	ldr  R1, =minutes
	strb R0, [R1]

	ldr  R1, =seconds
	strb R0, [R1]

	pop  {R0, PC}

.global print_time
print_time:
	push {R0, LR}

	ldr  R1, =hour
	ldrb R0, [R1]

	cmp  R0, #10
	bllt clock_fill_zero

	mov  R1, #10
	bl   lcd_print_number

	mov  R0, ':'
	bl   lcd_write_data

	ldr  R1, =minutes
	ldrb R0, [R1]

	cmp  R0, #10
	bllt clock_fill_zero

	mov  R1, #10
	bl   lcd_print_number

	mov  R0, ':'
	bl   lcd_write_data

	ldr  R1, =seconds
	ldrb R0, [R1]

	cmp  R0, #10
	bllt clock_fill_zero

	mov  R1, #10
	bl   lcd_print_number

	pop  {R0, PC}

clock_fill_zero:
	push {R0, LR}

	mov  R0, '0'
	bl   lcd_write_data

	pop  {R0, PC}

// R0
.global clock_tick
clock_tick:
	push {R0, LR}

	ldr    R0, =seconds
	ldrb   R1, [R0]

	add    R1, #1
	cmp    R1, #60
	strbne R1, [R0]
	bne    _clock_tick_exit

	mov    R1, #0
	strb   R1, [R0]

	ldr    R0, =minutes
	ldrb   R1, [R0]

	add    R1, #1
	cmp    R1, #60
	strbne R1, [R0]
	bne    _clock_tick_exit

	mov    R1, #0
	strb   R1, [R0]

	ldr    R0, =hour
	ldrb   R1, [R0]

	add    R1, #1
	cmp    R1, #24
	moveq  R1, #0
	strb   R1, [R0]

_clock_tick_exit:
	pop  {R0, PC}
