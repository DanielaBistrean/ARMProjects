.syntax unified

#include "gpio_defs.S"

.text
.global button_cfg
button_cfg:
	push {R0-R2, LR}

	mov  R0, #0
	bl   gpio_clock_enable

	mov  R0, #0
	mov  R1, #0
	mov  R2, #0b1000
	bl   gpio_configure

	pop  {R0-R2, PC}

// R0 - button state
.global read_button_state
read_button_state:
	push {R1, LR}

	ldr  R1, =PORTA_BASE_ADDR
	ldr  R0, [R1, #GPIOx_IDR]

	mvn  R0, R0
	and  R0, #1

	pop  {R1, PC}
