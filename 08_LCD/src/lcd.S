.syntax unified

#include "gpio_defs.S"

.equ LCD_RS, 1
.equ LCD_RW, 0
.equ LCD_EN, 8

.equ LCD_DATA_PORT, 2
.equ LCD_CTRL_PORT, 1

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

	// prepare the function set instruction into R0
	mov  R0, #0b00101000
	bl   lcd_write_instruction

	// display on/off instruction
	mov  R0, #0b00001110
	//bl   lcd_write_instruction

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
	bl   lcd_wait
	ldr  R0, =PORTC_BASE_ADDR
	ldr  R1, [R0, #GPIOx_IDR]
	bl   lcd_enable_low

	bfi  R2, R1, #4, #4

	bl   lcd_wait

	// read the last 4 bits
	bl   lcd_enable_high
	bl   lcd_wait
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
	push {R0-R2, LR}

	bl   lcd_busy_wait

	// configure to output the data lines
	bl   lcd_set_data_out

	mov  R2, R0
	mov  R0, #0b10
	bl   lcd_set_control

	ldr  R0, =PORTC_BASE_ADDR
	ldr  R1, [R0, #GPIOx_ODR]
	bfi  R1, R2, #4, #4
	str  R1, [R0, #GPIOx_ODR]

	bl   lcd_enable_high
	bl   lcd_wait
	bl   lcd_enable_low

	ldr  R1, [R0, #GPIOx_ODR]
	bfi  R1, R2, #0, #4
	str  R1, [R0, #GPIOx_ODR]

	bl   lcd_enable_high
	bl   lcd_wait
	bl   lcd_enable_low

	pop  {R0-R2, PC}

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

	ldr  R0, =PORTC_BASE_ADDR
	ldr  R1, [R0, #GPIOx_ODR]
	bfi  R1, R2, #4, #4
	str  R1, [R0, #GPIOx_ODR]

	bl   lcd_enable_high
	bl   lcd_wait
	bl   lcd_enable_low

	ldr  R1, [R0, #GPIOx_ODR]
	bfi  R1, R2, #0, #4
	str  R1, [R0, #GPIOx_ODR]

	bl   lcd_enable_high
	bl   lcd_wait
	bl   lcd_enable_low

	pop  {R0-R2, PC}

	// wait 1 millisecond
lcd_wait:
	push {R3, LR}
	ldr  R3, =1000
	_wait_loop:
		subs  R3, #1
		bne _wait_loop
	pop  {R3, PC}
