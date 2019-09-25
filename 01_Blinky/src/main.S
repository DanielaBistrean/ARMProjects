.word 0x20001000
.word main

.equ RCC_BASE_ADDR, 0x40021000
.equ RCC_APB2ENR, 0x18

.equ PORTC_BASE_ADDR, 0x40011000
.equ GPIOx_CRH, 0x4
.equ GPIOx_ODR, 0xc

@ Mode [17:16] = 10
@ CNF  [19:18] = 00

.text
.global main
.align 2

main:
	ldr  R0, =RCC_BASE_ADDR

	ldr  R1, [R0, #RCC_APB2ENR]
	mov  R2, #0x10
	orr  R1, R2
	str  R1, [R0, #RCC_APB2ENR]

	ldr  R0, =PORTC_BASE_ADDR    // load base addr of PortC in R0

	ldr  R1, [R0, #GPIOx_CRH]    // load CRH value in R1 from base address of PortC + CRH offset
	ldr  R2, =0xfff0ffff         // clear bits 19:16
	and  R1, R2
	ldr  R2, =0x00030000         // set bit 17
	orr  R1, R2
	str  R1, [R0, #GPIOx_CRH]    // store config to CRH

loop:
	bl led_on
	bl wait
	bl led_off
	bl wait
b loop

led_on:
	push {LR}
	ldr  R1, [R0, #GPIOx_ODR]
	movw R2, #0x1000
	orr  R1, R2
	str  R1, [R0, #GPIOx_ODR]
	pop  {PC}

led_off:
	push {LR}
	ldr  R1, [R0, #GPIOx_ODR]
	movw R2, #0x1000
	bic  R1, R2
	str  R1, [R0, #GPIOx_ODR]
	pop {PC}

wait:
	push {LR}
	ldr  R3, =0x006a1200
	_wait_loop:
		sub  R3, #1
		bne _wait_loop
	pop  {PC}
