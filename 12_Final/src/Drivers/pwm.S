.syntax unified
.thumb

#include "../Include/gpio_defs.S"
#include "../Include/pwm_defs.S"

.thumb_func
.global pwm_init
pwm_init:
	push {LR}

	//enable the clock for TIM1 and AFIO
	ldr   R0, =RCC_BASE_ADDR
	ldr   R1, [R0, #RCC_APB2ENR]
	mov   R2, #(1 | (1 << 11))
	orr   R1, R2
	str   R1, [R0, #RCC_APB2ENR]

	mov  R0, #0
	bl   gpio_clock_enable

	mov  R1, #8
	mov  R2, #0b1011
	bl   gpio_configure

	// auto-reload register - frequency
	ldr  R0, =TIM1_BASE_ADDR
	ldr  R1, =0x29A9  // (system clocl/750) - 1
	strh R1, [R0, #TIMx_ARR]

	// capture/compare register - duty cycle
	mov  R1, #0x14D4  // ((5 * (frequency - 1)) / 10)
	strh R1, [R0, #TIMx_CCR1]

	// set PWM mode 1
	ldrh R1, [R0, #TIMx_CCMR1]
	mov  R2, #0b111
	bfi  R1, R1, #4, #3
	orr  R1, #(1 << 3)
	strh R1, [R0, #TIMx_CCMR1]

	// enable UG update generation
	ldrh R1, [R0, #TIMx_EGR]
	orr  R1, #(1 << 0)
	strh R1, [R0, #TIMx_EGR]

	// enable CC1
	ldrh R1, [R0, #TIMx_BDTR]
	orr  R1, #((1 << 10) | (1 << 11) | (1 << 15))
	strh R1, [R0, #TIMx_BDTR]

	ldrh R1, [R0, #TIMx_CCER]
	orr  R1, #((1 << 0) | (1 << 2))
	strh R1, [R0, #TIMx_CCER]

	// enable counter and set auto-reload
	ldrh R1, [R0, #TIMx_CR1]
	orr  R1, #((1 << 7) | (1 << 0))
	strh R1, [R0, #TIMx_CR1]

	pop  {PC}

ISR_TIM1_CC:
	bx LR
