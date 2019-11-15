.syntax unified

.word 0x20001000
.word main

// clock enable register
.equ RCC_BASE_ADDR, 0x40021000
.equ RCC_APB2ENR, 0x18

.equ GPIOx_CRH, 0x4
.equ GPIOx_ODR, 0xc

.equ PORTA_BASE_ADDR, 0x40010800
.equ PORTB_BASE_ADDR, 0x40010C00
.equ PORTC_BASE_ADDR, 0x40011000
.equ GPIOx_CRL, 0x00
.equ GPIOx_IDR, 0x08

@ Mode [x:x] = 10
@ CNF  [x:x] = 00

.text
.global main

main:
	// enable the clock for Port A
	mov  R0, #0
	bl   gpio_clock_enable

	// enable the clock for Port B
	mov  R0, #1
	bl   gpio_clock_enable

	// enable the clock for Port C
	mov  R0, #2
	bl   gpio_clock_enable

	// configure Pin 8 from Port A
	mov  R0, #0
	mov  R1, #8
	mov  R2, #0b0010
	bl   gpio_configure

	// configure Pin 10 from Port C
	mov  R0, #2
	mov  R1, #10
	mov  R2, #0b0010
	bl   gpio_configure

	// configure Pin 8 from Port B
	mov  R0, #1
	mov  R1, #8
	mov  R2, #0b0010
	bl   gpio_configure

	// the leds are on at the start
	// turn them off
	mov R0, #0
	bl red_onOff
	bl yellow_onOff
	bl green_onOff

loop:
	//turn on the red light for 3 seconds
	mov R0, #1
	bl red_onOff
	bl wait
	bl wait

	// turn on the yellow light for 1 second
	mov R0, #1
	bl yellow_onOff
	bl wait

	// turn off the red and the yellow lights
	mov R0, #0
	bl red_onOff
	bl yellow_onOff

	//turn on the green light for 3 seconds
	mov R0, #1
	bl green_onOff
	bl wait
	bl wait

	mov R0, #1
	bl yellow_onOff
	bl wait

	mov R0, #0
	bl green_onOff
	bl yellow_onOff

	b loop

// inputs: R0 - parameter
// R0 - turn on/off the led
//    - on ->  0x1
//    - off -> 0x0
// turn on the Pin8 from Port A
green_onOff:
	push {R0, R1, R2, LR}
	ldr  R1, =PORTA_BASE_ADDR
	ldr  R2, [R1, #GPIOx_ODR]
	mvn  R0, R0
	bfi  R2, R0, #8, #1
	str  R2, [R1, #GPIOx_ODR]
	pop  {R0, R1, R2, PC}

// inputs: R0 - parameter
// R0 - turn on/off the led
//    - on ->  0x1
//    - off -> 0x0
// turn on the Pin8 from Port A
yellow_onOff:
	push {R0, R1, R2, LR}
	ldr  R1, =PORTB_BASE_ADDR
	ldr  R2, [R1, #GPIOx_ODR]
	mvn  R0, R0
	bfi  R2, R0, #8, #1
	str  R2, [R1, #GPIOx_ODR]
	pop  {R0, R1, R2, PC}

// inputs: R0 - parameter
// R0 - turn on/off the led
//    - on ->  0x1
//    - off -> 0x0
// turn on the Pin8 from Port A
red_onOff:
	push {R0, R1, R2, LR}
	ldr  R1, =PORTC_BASE_ADDR
	ldr  R2, [R1, #GPIOx_ODR]
	mvn  R0, R0
	bfi  R2, R0, #10, #1
	str  R2, [R1, #GPIOx_ODR]
	pop  {R0, R1, R2, PC}

// wait 1 second
wait:
	push {R3, LR}
	ldr  R3, =1000000
	_wait_loop:
		nop
		nop
		nop
		nop
		nop
		nop
		subs  R3, #1
		bne _wait_loop
	pop  {R3, PC}

// inputs: R0 - Bit index for the choosen Port Index
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
