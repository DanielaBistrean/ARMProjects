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