.syntax unified
.thumb

.section .vector_table,"a",%progbits
.global vectors
vectors:
.word 0x20001000
.word main
.word 0
.word 0
.word 0
.word ISR_BusFault
.word 0
// 1C.. 2B => 16 bytes => 4 words
.word 0
.word 0
.word 0
.word 0

.word 0
.word 0
.word 0
.word 0
.word ISR_SysTick

#include "gpio_defs.S"

.text

.global main
main:
	bl  button_cfg

	bl  lcd_init

	bl  lcd_write_1line

	bl  clock_reset
	bl  print_time

	bl  SysTick_init

	bl  USART1_init
	mov R0, 'B'
	bl  USART1_putc

loop:
	bl   read_button_state

	cmp  R0, #1
	bleq clock_reset
	beq  _update_time

	bl   SysTick_getStatus
	cmp  R0, #1
	bne  loop

_update_time:
	bl   lcd_return_home
	bl   print_time

	b  loop
