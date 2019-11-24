.syntax unified
.thumb

.text

.global main
main:
	bl  button_cfg

	bl  USART1_init
	bl  lcd_init

	bl  clock_reset
	bl  print_time

	mov R0, #40
	bl  lcd_move_cursor

	bl  SysTick_init

loop:
	bl   USART1_getc
	cmp  R0, '\r'
	bleq lcd_clear_line2
	cmp  R0, '\r'
	blne lcd_write_data

	b  loop
