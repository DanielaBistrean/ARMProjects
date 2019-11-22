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
	bl  lcd_cursor_on

	bl  lcd_write_1line
	//mov R0, #0b00100100
	//bl  lcd_write_instruction
	bl  clock_reset

loop:
	bl  wait

	bl  lcd_return_home
	bl  print_time
	bl  clock_tick

	bl  button_main

	b loop

// wait 1 second
.global wait
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

.global	print_registers_value
print_registers_value:
	push {R0-R12, LR}

	mov  R2, #0
	sub  R3, SP, #4
	mov  R4, #0

_print_registers_value_loop:

	cmp  R4, #0
	bleq lcd_clear
	//bl   lcd_return_home

	mov  R0, R4
	bl   lcd_move_cursor

	mov  R0, 'R'
	bl   lcd_write_data

	mov  R0, R2
	mov  R1, #10
	bl   lcd_print_number

	mov  R0, '='
	bl   lcd_write_data

	ldr  R0, [R3]
	mov  R1, #16
	bl   lcd_print_number

	bl   wait

	sub  R3, #4
	adds R2, #1

	add  R4, #40
	cmp  R4, #80
	moveq R4, #0

	cmp  R2, #13
	bne  _print_registers_value_loop

	pop  {R0-R12, PC}
