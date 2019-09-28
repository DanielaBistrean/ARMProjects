// TIM2
.word 0x20001000
.word main

.equ TIM2_BASE_ADDR, 0x40000000

.equ RCC_BASE_ADDR, 0x40021000

.equ RCC_APB1ENR, 0x1C
.equ TIMx_CR1, 0x0
.equ TIMx_CNT, 0x24
.equ TIMx_PSC, 0x28
.equ TIMx_ARR, 0x2C

.text
.global main

main:
	ldr R0, =RCC_BASE_ADDR
	ldr R1, [R0, #RCC_APB1ENR]
	mov R2, #1
	orr R1, R2
	str R1, [R0, #RCC_APB1ENR]


	ldr R0, =TIM2_BASE_ADDR

	//ldrh R2, [R0, #TIMx_CNT]
	ldr R1, =1000
	//mov R1, #1000
	strh R1, [R0, #TIMx_CNT]
	strh R1, [R0, #TIMx_ARR]

	//mov R1, #8000
	ldr R1, =8000
	strh R1, [R0, #TIMx_PSC]

	ldrh R1, [R0, #TIMx_CR1]
	mov R2, #0x1
	orr R1, R2
	strh R1, [R0, #TIMx_CR1]

loop:
	b loop
