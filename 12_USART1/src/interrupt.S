.syntax unified

.text

.equ STK_BASE_ADDR, 0xE000E010
.equ STK_CTRL, 0x00
.equ STK_LOAD, 0x04
.equ STK_VAL,  0x08

.thumb_func
.global ISR_SysTick
ISR_SysTick:
	push {LR}

	bl   clock_tick
	mov R0, 'B'
	bl  USART1_putc

	pop  {PC}

.thumb_func
.global ISR_BusFault
ISR_BusFault:
	push {LR}
	pop  {PC}

.thumb_func
.global SysTick_init
SysTick_init:
	push {LR}

	ldr  R1, =STK_BASE_ADDR

	ldr  R0, =8000000 // 1ms
	str  R0, [R1, #STK_LOAD]

	mov  R0, #7
	str  R0, [R1, #STK_CTRL]

	pop  {PC}

// return into R0 the value of the countflag
.thumb_func
.global SysTick_getStatus
SysTick_getStatus:
	push {R1, LR}

	ldr  R1, =STK_BASE_ADDR
	ldr  R0, [R1, #STK_CTRL]
	lsr  R0, #16
	and  R0, #1

	pop  {R1, PC}

