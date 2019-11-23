.syntax unified
.thumb

#include "gpio_defs.S"

.equ USART1_BASE_ADDR, 0x40013800
.equ USART_SR, 0x00
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
	push {R1-R2, LR}

	ldr  R1, =USART1_BASE_ADDR
_USART1_putc_busy:
	ldr  R2, [R1, #USART_SR]
	ands R2, #0x40
	beq  _USART1_putc_busy

	str  R0, [R1, #USART_DR]

	pop  {R1-R2, PC}

// R0 - number to be printted
// R1 - base
.global usart_print_number
usart_print_number:
	push {R0-R5, LR}

	mov  R5, #0
	mov  R2, R1

_usart_print_number_loop:

	// modulo
	udiv R1, R0, R2
	mul  R3, R1, R2
	sub  R4, R0, R3

	push {R4}
	add  R5, #1

	mov  R0, R1
	cmp  R0, #0
	bne  _usart_print_number_loop

_usart_print_dec_in_reverse:
	pop  {R0}
	bl   usart_print_1digit_hex
	subs R5, #1
	bne  _usart_print_dec_in_reverse

_usart_print_number_exit:
	pop  {R0-R5, PC}

// R0 - digit to be printted
.global usart_print_1digit_hex
usart_print_1digit_hex:
	push {R0, LR}

	cmp   R0, #9
	addle R0, R0, #48
	addgt R0, R0, #55
	bl    USART1_putc

_usart_print_1digit_hex_exit:
	pop  {R0, PC}

usart_print_1digit_noop:
	mov  PC, LR

.global usart_return_home
usart_return_home:
	push {R0, LR}
	mov  R0, '\r'
	bl   USART1_putc
	pop  {R0, PC}
