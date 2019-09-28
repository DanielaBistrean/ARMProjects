// set the led status using a function by giving a parameter

.word 0x20001000
.word _start

.text
.global _start

.equ PORTC_BASE_ADDR, 0x40011000
.equ RCC_APB2ENR, 0x18 				// activate the clock for port C
.equ RCC_CR, 0x40021000				// activate the clock

.equ GPIOx_CRH, 0x04				// set the pin to output
.equ GPIOx_ODR, 0x0C				// write pin value
// Mode [17:16]: 10
// CNF [19:18]: 00


_start:
	ldr R0, =RCC_CR					// activate the clock
	ldr R1, [R0, #RCC_APB2ENR]
	ldr R2, =0x10
	orr R1, R2
	str R1, [R0, #RCC_APB2ENR]

	ldr R0, =PORTC_BASE_ADDR
	ldr R1, [R0, #GPIOx_CRH]
	ldr R2, =0xfff0ffff				// clear all bits from 19 to 16
	and R1, R2
	ldr R2, =0x20000				// set bit 17 to 1
	orr R1, R2
	str R1, [R0, #GPIOx_CRH]		// put the value in memory

	mov R2, #0x0
	bl led_status

loop:
	b loop


// R2 is the parameter for the bellow function
led_status:
	push {R0, R1, LR}
	ldr R0, =PORTC_BASE_ADDR
	ldr R1, [R0, #GPIOx_ODR]		// write pin value
	cmp R2, #0x0					// the logic is reverst because the led is pulled-up
	beq off
	bfc R1, #12, #1
	b led_status_exit

off:
	mvn R2, R2						// prepare R2 with all ones
	bfi R1, R2, #12, #1				// copy and set one bit from R2 to the 12 bit of R1

led_status_exit:
	str R1, [R0, #GPIOx_ODR]
	pop {R0, R1, PC}
