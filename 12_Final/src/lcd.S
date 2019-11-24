.syntax unified

#include "Include/gpio_defs.S"

.equ LCD_RS, 1
.equ LCD_RW, 0
.equ LCD_EN, 8

.equ LCD_DATA_PORT, 2
.equ LCD_CTRL_PORT, 1

.data
.align 1
lcd_cursor:
	.byte 0

.text
.global lcd_init
lcd_init:
	push {R0, R1, R2, LR}

	// enable control port clock
	mov  R0, #LCD_CTRL_PORT
	bl   gpio_clock_enable

	// configure to output the control lines
	mov  R1, #LCD_RS
	mov  R2, #0b0010
	bl   gpio_configure

	mov  R1, #LCD_RW
	bl   gpio_configure

	mov  R1, #LCD_EN
	bl   gpio_configure

	// enable the data port clock
	mov  R0, #LCD_DATA_PORT
	bl   gpio_clock_enable

	mov  R0, #100
	bl   lcd_wait

	mov  R0, #0b0011
	bl   lcd_write_4bits

	mov  R0, #5
	bl   lcd_wait

	mov  R0, #0b0011
	bl   lcd_write_4bits

	mov  R0, #100
	bl   lcd_wait

	mov  R0, #0b0011
	bl   lcd_write_4bits

	mov  R0, #100
	bl   lcd_wait

	mov  R0, #0b0010
	bl   lcd_write_4bits

	mov  R0, #100
	bl   lcd_wait

	// prepare the function set instruction into R0
	mov  R0, #0b00101000
	bl   lcd_write_instruction

	// display on/off instruction
	mov  R0, #0b00001000
	bl   lcd_write_instruction

	// clear display
	bl   lcd_clear

	// entry mode set instruction
	mov  R0, #0b00000110
	bl   lcd_write_instruction

	// display on/off instruction
	mov  R0, #0b00001100
	bl   lcd_write_instruction

	ldr  R0, =lcd_cursor
	mov  R1, #0
	strb R1, [R0]

	pop  {R0, R1, R2, PC}

lcd_set_data_in:
	push {R0, R1, R2, LR}

	mov  R0, #LCD_DATA_PORT
	mov  R1, #0
	mov  R2, #0b0100
	bl   gpio_configure

	mov  R1, #1
	bl   gpio_configure

	mov  R1, #2
	bl   gpio_configure

	mov  R1, #3
	bl   gpio_configure

	pop  {R0, R1, R2, PC}

lcd_set_data_out:
	push {R0, R1, R2, LR}

	mov  R0, #LCD_DATA_PORT
	mov  R1, #0
	mov  R2, #0b0010
	bl   gpio_configure

	mov  R1, #1
	bl   gpio_configure

	mov  R1, #2
	bl   gpio_configure

	mov  R1, #3
	bl   gpio_configure

	pop  {R0, R1, R2, PC}

lcd_busy_wait:
	push  {R0-R2, LR}

	// R2 holds the status register of the LCD
	mov  R2, #0

	mov  R0, #0b01
	bl   lcd_set_control

	bl   lcd_set_data_in

_lcd_busy_loop:
	// read the first 4 bits
	bl   lcd_enable_high
	ldr  R0, =PORTC_BASE_ADDR
	ldr  R1, [R0, #GPIOx_IDR]
	bl   lcd_enable_low

	bfi  R2, R1, #4, #4

	mov  R0, #1
	bl   lcd_wait

	// read the last 4 bits
	bl   lcd_enable_high
	ldr  R0, =PORTC_BASE_ADDR
	ldr  R1, [R0, #GPIOx_IDR]
	bl   lcd_enable_low

	bfi  R2, R1, #0, #4

	//check the status bit
	ands R2, #0x80
	bne  _lcd_busy_loop

	pop  {R0-R2, PC}

lcd_enable_high:
	push {R0, R1, R2, LR}

	ldr  R0, =PORTB_BASE_ADDR
	ldr  R1, [R0, #GPIOx_ODR]
	mov  R2, #1
	bfi  R1, R2, #LCD_EN, #1
	str  R1, [R0, #GPIOx_ODR]

	pop  {R0, R1, R2, PC}

lcd_enable_low:
	push {R0, R1, LR}

	ldr  R0, =PORTB_BASE_ADDR
	ldr  R1, [R0, #GPIOx_ODR]
	bfc  R1, #LCD_EN, #1
	str  R1, [R0, #GPIOx_ODR]

	pop  {R0, R1, PC}

// R0 - value of the RW, RS control lines
lcd_set_control:
	push {R1, R2, LR}

	ldr  R1, =PORTB_BASE_ADDR
	ldr  R2, [R1, #GPIOx_ODR]
	bfi  R2, R0, #LCD_RW, #2
	str  R2, [R1, #GPIOx_ODR]

	pop  {R1, R2, PC}

// R0 - one byte of data to send
.global lcd_write_data
lcd_write_data:
	push {R0-R3, LR}

	bl   lcd_busy_wait

	// configure to output the data lines
	bl   lcd_set_data_out

	mov  R2, R0
	mov  R0, #0b10
	bl   lcd_set_control

	lsr  R0, R2, #4
	bl   lcd_write_4bits

	mov  R0, R2
	bl   lcd_write_4bits

	// R2 = current cursor position
	ldr   R3, =lcd_cursor
	ldrb  R2, [R3]
	// increment the cursor value
	add   R2, #1
	strb  R2, [R3]

	pop  {R0-R3, PC}

// R0 - one byte of data to send
.global lcd_write_instruction
lcd_write_instruction:
	push {R0-R2, LR}

	bl   lcd_busy_wait

	// configure to output the data lines
	bl   lcd_set_data_out

	mov  R2, R0
	mov  R0, #0b00
	bl   lcd_set_control

	lsr  R0, R2, #4
	bl   lcd_write_4bits

	mov  R0, R2
	bl   lcd_write_4bits

	pop  {R0-R2, PC}

// R0 - no of miliseconds
// 1 ms
.global lcd_wait
lcd_wait:
	push {R3, LR}
	ldr  R3, =4000
	mul  R3, R0
	_wait_loop:
		subs  R3, #1
		bne _wait_loop
	pop  {R3, PC}

lcd_enable_toggle:
	push {LR}

	bl   lcd_enable_high
	//mov  R0, #1
	//bl   lcd_wait
	bl   lcd_enable_low

	pop  {PC}

// R0 - 4 bits to be written
lcd_write_4bits:
	push {R0-R2, LR}

	// store in R2 the current value of PORTC
	ldr  R1, =PORTC_BASE_ADDR
	ldr  R2, [R1, #GPIOx_ODR]
	bfi  R2, R0, #0, #4
	str  R2, [R1, #GPIOx_ODR]

	bl   lcd_enable_toggle

	pop  {R0-R2, PC}

// R0 - address to the beginning of a zero terminated string
.global lcd_print
lcd_print:
	push  {R0-R3, LR}

	mov   R1, R0

_print:
	// load only one byte
	ldrb  R0, [R1]
	cmp   R0, #0
	beq   _exit

	bl    lcd_write_data

	// go to the next char
	add   R1, #1
	b     _print

_exit:
	pop   {R0-R3, PC}

.global lcd_clear
lcd_clear:
	push  {R0, LR}
	mov   R0, #0b00000001
	bl    lcd_write_instruction
	pop   {R0, PC}

.global lcd_return_home
lcd_return_home:
	push  {R0, R1, LR}
	mov   R0, #0b00000010
	bl    lcd_write_instruction

	ldr   R1, =lcd_cursor
	mov   R0, #0
	strb  R0, [R1]

	pop   {R0, R1, PC}

lcd_write_2lines:
	push  {R0, LR}

	// prepare the function set instruction into R0
	mov   R0, #0b00101000
	bl    lcd_write_instruction

	pop   {R0, PC}

.global lcd_write_1line
lcd_write_1line:
	push  {R0, LR}

	// prepare the function set instruction into R0
	mov   R0, #0b00100000
	bl    lcd_write_instruction

	pop   {R0, PC}

.global lcd_move_cursor_left
lcd_move_cursor_left:
	push  {R0, R1, LR}

	mov   R0, #0b00010000
	bl    lcd_write_instruction

	ldr   R1, =lcd_cursor
	ldrb  R0, [R1]
	sub   R0, #1
	strb  R0, [R1]

	pop   {R0, R1, PC}

.global lcd_move_cursor_right
lcd_move_cursor_right:
	push  {R0, R1, LR}

	mov   R0, #0b00010100
	bl    lcd_write_instruction

	ldr   R1, =lcd_cursor
	ldrb  R0, [R1]
	add   R1, #1
	strb  R0, [R1]

	pop   {R0, R1, PC}

.global lcd_cursor_on
lcd_cursor_on:
	push  {R0, LR}

	mov   R0, #0b00001110
	bl    lcd_write_instruction

	pop   {R0, PC}

.global lcd_delete_char
lcd_delete_char:
	push  {R0, LR}

	bl   lcd_move_cursor_left

	mov  R0, #0b0010000
	bl   lcd_write_data

	bl   lcd_move_cursor_left

	pop   {R0, PC}

.global lcd_goto_next_line
lcd_goto_next_line:
	push  {R0, R1, LR}

	ldr   R0, =lcd_cursor
	ldrb  R1, [R0]

	cmp   R1, #40
	beq   _lcd_goto_next_line_exit

_goto_next_line_loop:
	bl    lcd_move_cursor_right
	add   R1, #1

	cmp   R1, #80
	moveq R1, #0

	cmp   R1, #40
	bne   _goto_next_line_loop

_lcd_goto_next_line_exit:
	strb  R1, [R0]
	pop   {R0, R1, PC}

// R0 - digit to be printted
lcd_print_1digit_dec:
	push {R0, LR}

	add  R0, R0, #48
	bl   lcd_write_data

	pop  {R0, PC}

// R0 - number to be printted
// R1 - base
.global lcd_print_number
lcd_print_number:
	push {R0-R5, LR}

	mov  R5, #0
	mov  R2, R1

_lcd_print_number_loop:

	// modulo
	udiv R1, R0, R2
	mul  R3, R1, R2
	sub  R4, R0, R3

	push {R4}
	add  R5, #1

	mov  R0, R1
	cmp  R0, #0
	bne  _lcd_print_number_loop

_lcd_print_dec_in_reverse:
	pop  {R0}
	bl   lcd_print_1digit_hex
	subs R5, #1
	bne  _lcd_print_dec_in_reverse

_lcd_print_number_exit:
	pop  {R0-R5, PC}

// R0 - digit to be printted
.global lcd_print_1digit_hex
lcd_print_1digit_hex:
	push {R0, LR}

	cmp   R0, #9
	addle R0, R0, #48
	addgt R0, R0, #55
	bl    lcd_write_data

_lcd_print_1digit_hex_exit:
	pop  {R0, PC}

lcd_print_1digit_noop:
	mov  PC, LR

// R0 - decimal digit
.global lcd_print_number_hex
lcd_print_number_hex:
	push {R0-R5, LR}

	mov  R5, #0

_lcd_print_number_hex_loop:
	mov  R2, #16

	udiv R1, R0, R2
	mul  R3, R1, R2
	sub  R4, R0, R3

	push {R4}
	add  R5, #1

	mov  R0, R1
	cmp  R0, #0
	bne  _lcd_print_number_hex_loop

_lcd_print_hex_in_reverse:
	pop  {R0}
	bl   lcd_print_1digit_hex
	subs R5, #1
	bne  _lcd_print_hex_in_reverse

_lcd_print_number_hex_exit:
	pop  {R0-R5, PC}

.global lcd_move_cursor
lcd_move_cursor:
	push {R0, LR}

	orr  R0, #0x80
	bl   lcd_write_instruction

	pop   {R0, PC}

// put the current cursor possition in R0
.global lcd_get_cursor
lcd_get_cursor:
	push  {R1-R2, LR}

	// R2 holds the status register of the LCD
	mov  R2, #0

	mov  R0, #0b01
	bl   lcd_set_control

	bl   lcd_set_data_in

	// read the first 4 bits
	bl   lcd_enable_high
	ldr  R0, =PORTC_BASE_ADDR
	ldr  R1, [R0, #GPIOx_IDR]
	bl   lcd_enable_low

	bfi  R2, R1, #4, #4

	mov  R0, #1
	bl   lcd_wait

	// read the last 4 bits
	bl   lcd_enable_high
	ldr  R0, =PORTC_BASE_ADDR
	ldr  R1, [R0, #GPIOx_IDR]
	bl   lcd_enable_low

	bfi  R2, R1, #0, #4

	//clear the status bit
	and  R0, R2, #0x7f

	pop  {R1-R2, PC}

.global lcd_clear_line2
lcd_clear_line2:
	push {R0-R1, LR}

	mov  R0, #40
	bl   lcd_move_cursor

	mov  R1, #0
	mov  R0, ' '

_lcd_clear_line2_loop:
	bl   lcd_write_data
	adds R1, #1
	cmp  R1, #40
	bne  _lcd_clear_line2_loop

	mov  R0, #40
	bl   lcd_move_cursor

	pop  {R0-R1, PC}
