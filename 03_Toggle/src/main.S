.word 0x20001000                 // SP address
.word main

.equ RCC_BASE_ADDR, 0x40021000   // define the base addr for clock control register
.equ RCC_APB2ENR, 0x18           // define the address APB2ENR peripheral clock enable register

.equ PORTC_BASE_ADDR, 0x40011000 // define the base addr for PortC
.equ GPIOx_CRH, 0x4              // define addr for port configuration register high, because we choose the Pin12
.equ GPIOx_ODR, 0xc              // define addr for output data register (we will set the pin to output)

.equ PORTA_BASE_ADDR, 0x40010800 // define the base station for PortA (Button)
.equ GPIOx_CRL, 0x00             // define addr for port configuration register low (Pin 0)
.equ GPIOx_IDR, 0x08             // define addr for input data register (set the pin to input)

@ Mode [17:16] = 10
@ CNF  [19:18] = 00

//PortA
@ Mode [1:0]   = 00             // 00: Input mode
@ CNF  [3:2]   = 10             // 10: Input with pull-up / pull-down

.text
.global main

main:
	ldr  R0, =RCC_BASE_ADDR      // load the addr of clock control in R0

	ldr  R1, [R0, #RCC_APB2ENR]  // load APB2ENR value in R1 from base addr of clock control register + APB2ENR
	mov  R2, #0x14               // enable clock for Port C and Port A, set the coresponding bits (4 and 2)
	orr  R1, R2
	str  R1, [R0, #RCC_APB2ENR]

	ldr  R0, =PORTC_BASE_ADDR    // load base addr of PortC in R0

	// PortC
	ldr  R1, [R0, #GPIOx_CRH]    // load CRH value in R1 from base address of PortC + CRH offset
	ldr  R2, =0xfff0ffff         // clear bits 19:16
	and  R1, R2
	ldr  R2, =0x00030000         // set bit 17
	orr  R1, R2
	str  R1, [R0, #GPIOx_CRH]    // store config to CRH

	// PortA
	ldr  R0, =PORTA_BASE_ADDR    // load base addr of PortA in R0

	ldr  R1, [R0, #GPIOx_CRL]    // load CRH value in R1 from base address of PortA + CRL offset
	ldr  R2, =0xfffffff0         // clear bits 3:0
	and  R1, R2
	mov  R2, #0x8                // set bit 3
	orr  R1, R2
	str  R1, [R0, #GPIOx_CRL]    // store config to CRH

	mov  R2, #0x0                // initial button state
	mov  R4, #0x0                // initial led state
loop:
	bl  read_button
	cmp R1, R2
	beq loop
	mov R2, R1                   // R2 store the last state of the button
	cmp R1, #0x1
	bne loop
	cmp R4, #0x1
	beq L1
	bl  led_on                    // bl = store the addr of the next instruction into LR register
	mov R4, #0x1
	b   loop

L1:
	bl  led_off
	mov R4, #0x0
b loop

led_on:
	push {R2, LR}                    // push the LR into stack
	ldr  R0, =PORTC_BASE_ADDR
	ldr  R1, [R0, #GPIOx_ODR]
	movw R2, #0x1000             // turn on the Pin12
	orr  R1, R2
	str  R1, [R0, #GPIOx_ODR]
	pop  {R2, PC}                    // pop the stack => return to the next instr after the call (LR copied to PC)

led_off:
	push {R2, LR}                    // push the LR into stack
	ldr  R0, =PORTC_BASE_ADDR
	ldr  R1, [R0, #GPIOx_ODR]
	movw R2, #0x1000
	bic  R1, R2                  // turn off the Pin12
	str  R1, [R0, #GPIOx_ODR]
	pop {R2, PC}                     // pop the stack => return to the next instr after the call (LR copied to PC)

wait:
	push {LR}
	ldr  R3, =0x006a1200         // wait 1s
	_wait_loop:
		sub  R3, #1              // decr the addr of R3 with 1?
		bne _wait_loop           // repeat this operation untill the R3 is equal with 0
	pop  {PC}                    // pop the stack => return to the next instr after the call (LR copied to PC)

// read button state in R1
read_button:
	push {R2, LR}
	ldr  R0, =PORTA_BASE_ADDR
	ldr  R1, [R0, #GPIOx_IDR]
	mov  R2, #0x1
	and  R1, R2
	pop  {R2, PC}
