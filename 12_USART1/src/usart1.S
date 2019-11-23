.syntax unified
.thumb

#include "gpio_defs.S"

.equ USART1_BASE_ADDR, 0x40013800
.equ USART_DR, 0x04
.equ USART_BRR, 0x08
.equ USART_CR1, 0x0C

.text

.global USART1_init
USART1_init:
	push  {R0-R1, LR}

	mov   R0, #0
	bl    gpio_clock_enable
	
	ldr   R0, =RCC_BASE_ADDR
	ldr   R1, =0x4001 // enable AFIO + USART clock
	ldr   R2, [R0, #RCC_APB2ENR]
	orr   R2, R1
	str   R2, [R0, #RCC_APB2ENR]

	mov   R0, #0
	mov   R1, #9
	mov   R2, #0b1010 // alternate output
	bl    gpio_configure

	mov   R1, #10
	mov   R2, #0b0100 // input floating
	bl    gpio_configure

	ldr   R0, =USART1_BASE_ADDR
	mov   R1, #0x45
	str   R1, [R0, #USART_BRR]

	ldr   R0, =USART1_BASE_ADDR
	mov   R1, #0x200C // enable UE + TE + RE
	str   R1, [R0, #USART_CR1]

	mov   R1, #3
	str   R1, [R0, #USART_DR]

	pop   {R0-R1, PC}

// inputs: R0 - the desired char
.global USART1_putc
USART1_putc:
	push {R1, LR}

	ldr  R1, =USART1_BASE_ADDR
	str  R0, [R1, #USART_DR]

	pop  {R1, PC}
