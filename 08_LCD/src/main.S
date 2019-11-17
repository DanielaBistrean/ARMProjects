.syntax unified

.text
.global vectors
.section vectors
.word 0x20001000
.word main

my_string:
	.asciz "Hello, world!"

#include "gpio_defs.S"

.global main

main:
	bl  lcd_init


loop:
	bl  lcd_clear
	bl  lcd_return_home

	bl  wait

	ldr R0, =my_string
	bl  lcd_print

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
