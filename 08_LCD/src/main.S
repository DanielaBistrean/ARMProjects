.syntax unified

.text
.global vectors
.section vectors
.word 0x20001000
.word main

#include "gpio_defs.S"

.global main

main:
	bl  lcd_init


loop:
	//mov R0, #0b00000001
	//bl  lcd_write_instruction

	//mov R0, #0b00000010
	//bl  lcd_write_instruction

	//bl  wait

	mov R0, #65
	bl  lcd_write_data

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
