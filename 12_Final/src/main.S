.syntax unified
.thumb

.text

.global main
main:
	bl  button_cfg

	bl  USART1_init
	bl  lcd_init

	bl  lcd_write_1line

	bl  clock_reset
	bl  print_time

	bl  SysTick_init

loop:
	b  loop
