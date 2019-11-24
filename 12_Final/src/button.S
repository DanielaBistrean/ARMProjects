.syntax unified

#include "Include/gpio_defs.S"
#include "Include/interrupt_defs.S"

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

	bl   button_irq_init

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

.global button_irq_init
button_irq_init:
	push {R0-R1, LR}

	ldr  R0, =RCC_BASE_ADDR
	ldr  R1, [R0, #RCC_APB2ENR]
	orr  R1, #1
	str  R1, [R0, #RCC_APB2ENR]

	// to configure the port for EXTI0,
	// write to: AFIO_EXTICR1

	ldr  R0, =EXTI_BASE_ADDR
	ldr  R1, [R0, #EXTI_FTSR]
	orr  R1, #1
	str  R1, [R0, #EXTI_FTSR]

	ldr  R1, [R0, #EXTI_IMR]
	orr  R1, #1
	str  R1, [R0, #EXTI_IMR]

	ldr  R0, =NVIC_BASE_ADDR
	ldr  R1, [R0, #NVIC_ISER0]
	orr  R1, #0x40
	str  R1, [R0, #NVIC_ISER0]

	pop  {R0-R1, PC}
