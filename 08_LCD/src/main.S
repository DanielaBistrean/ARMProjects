.syntax unified

.text
.global vectors
.section vectors
.word 0x20001000
.word main

my_strings:
	.asciz "Hello, world!"

my_string:
	.asciz "a"

#include "gpio_defs.S"

.global main

main:
	bl  lcd_init
	bl  lcd_cursor_on


loop:
	//bl  lcd_clear
	//bl  lcd_return_home

	//bl  wait

	//bl  lcd_cursor_on



	ldr R0, =my_string
	//ldr R0, =0b01100101
	bl  lcd_print

	bl  wait

	ldr R0, =my_string
	bl  lcd_print

	//bl  lcd_cursor_on
	bl  wait


	bl  lcd_delete_char
	bl  wait


	b loop

// wait 1 millisecond
wait:
	push {R3, LR}
	ldr  R3, =1000000
	_wait_loop:
		nop
		nop
		nop
		nop
		subs  R3, #1
		bne _wait_loop
	pop  {R3, PC}
