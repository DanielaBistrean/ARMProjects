.syntax unified

#include "Include/interrupt_defs.S"

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

	bl   lcd_get_cursor
	push {R0}

	mov  R0, #0
	bl   lcd_move_cursor

	bl   usart_return_home
	bl   print_time

	pop  {R0}
	bl   lcd_move_cursor

	pop  {PC}

.thumb_func
.global ISR_BusFault
ISR_BusFault:
	push {LR}
	pop  {PC}

.thumb_func
.global SysTick_init
SysTick_init:
	push {R0-R1, LR}

	ldr  R1, =STK_BASE_ADDR

	ldr  R0, =8000000 // 1ms
	str  R0, [R1, #STK_LOAD]

	mov  R0, #7
	str  R0, [R1, #STK_CTRL]

	pop  {R0-R1, PC}

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

.thumb_func
.global ISR_EXTI0
ISR_EXTI0:
	push {R0-R1, LR}

	bl   clock_reset

	bl   lcd_get_cursor
	push {R0}

	mov  R0, #0
	bl   lcd_move_cursor

	bl   usart_return_home
	bl   print_time

	pop  {R0}
	bl   lcd_move_cursor
	ldr  R0, =EXTI_BASE_ADDR
	mov  R1, #1
	str  R1, [R0, #EXTI_PR]

	pop  {R0-R1, PC}

