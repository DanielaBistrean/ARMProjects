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

	b  loop
