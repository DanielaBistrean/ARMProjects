.syntax unified
#include "gpio_defs.S"

// inputs: R0 - Bit index for the choosen Port Index
.text
.global gpio_clock_enable
gpio_clock_enable:
	push {R0, R1, R2, R3, LR}

	cmp  R0, #7
	bge  _gpio_clock_enable_exit

	add R0, #2

	ldr R1, =RCC_BASE_ADDR
	ldr R2, [R1, #RCC_APB2ENR]

	ldr R3, =1
	lsl R3, R3, R0
	orr R2, R3
	str R2, [R1, #RCC_APB2ENR]

_gpio_clock_enable_exit:
	pop  {R0, R1, R2, R3, PC}

// inputs: R0 - Port Index (0 = A, 1 = B, ...)
//         R1 - Pin  Index (0 to 15)
//         R2 - Pin configuration (last 4 bits according to ref. manual)
.global gpio_configure
gpio_configure:
	push  {R0, R1, R2, R3, R4, LR}

	cmp   R0, #7                 // check if the port is valid (has one of the following index: 0=A, 1=B, 2=C, 3=D, 4=E, 5=F, 6=G)
	bge   _gpio_configure_exit

	cmp   R1, #16                // check if the pin index is valid
	bge   _gpio_configure_exit

	ldr   R3, =PORTA_BASE_ADDR   // store into R3 the base addr for the first Port (PortA)
	ldr   R4, =0x400             // R4 store the difference between Ports (memory size of each Port)
	mla   R0, R4, R0, R3         // calculate in R0 the base address of the desired port as R0 = gpio mem size * index + base addr of PortA

	ldr   R3, =GPIOx_CRL         // R3 store the base addr for CRL
	cmp   R1, #7                 // check if Pin Index is grater than last pin from low registers
	addgt R3, R3, #4             // R3 = port configuration register depending on pin index (add value for the high registers addr)
	subgt R1, R1, #8             // update R1 - Pin Index

	lsl   R1, R1, #2             // R1 holds the number of bits to shift the config value

	ldr   R4, =0xf               // clear all bits except for configuration bits
	lsl   R2, R2, R1             // shift to the left
	lsl   R4, R4, R1
	and   R2, R4

	mvn   R4, R4
	ldr   R1, [R0, R3]
	and   R1, R4
	orr   R1, R2
	str   R1, [R0, R3]

_gpio_configure_exit:
	pop  {R0, R1, R2, R3, R4, PC}
