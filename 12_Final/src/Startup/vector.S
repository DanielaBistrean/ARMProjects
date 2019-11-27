.syntax unified
.thumb

.section .vector_table,"a",%progbits
.global vectors
vectors:
.word 0x20001000
.word main
.word 0
.word 0
.word 0
.word ISR_BusFault
.word 0
// 1C.. 2B => 16 bytes => 4 words
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word ISR_SysTick
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word ISR_EXTI0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0 //ISR_TIM1_BRK
.word 0 //ISR_TIM1_UP
.word 0 //ISR_TIM1_TRG_COM
.word 0 //ISR_TIM1_CC
.word 0 // ISR_TIM@
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word ISR_USART1
