/* This will work with STM32 type of microcontrollers.    *
 * The sizes of RAM and flash are specified smaller than  *
 * what most of the STM32 provide to ensure that the demo *
 * program will run on ANY STM32.                         */
MEMORY
{
    ram (rwx) : ORIGIN = 0x20000000, LENGTH = 8K
    rom (rx)  : ORIGIN = 0x08000000, LENGTH = 128K
}

/* this is a hack, need to have an entry point that performs .data and .bss
 * init before calling C */
ENTRY(main)

SECTIONS
{
	.vector_table :
	{
	  . = ALIGN(4);
	  KEEP (*(.vector_table))
	  . = ALIGN(4);
	} >rom

    .text :
    {
	__rom_start__ = .;
        *(.text)      /* Program code */
        *(.rodata)    /* Read only data */
	. = ALIGN(4);
	__rom_end__ = .;
    } >rom

    .data :
    {
        __data_start__ = .;
        *(.data)      /* Data memory */
	. = ALIGN(4);
        __data_end__ = .;
    } >ram AT >rom

    /* startup code must copy __data_size__ bytes from __data_loadaddr__ to
     * __data_start__ before calling C */
    __data_loadaddr__ = LOADADDR(.data);

    .bss :
    {
        __bss_start__ = .;
        *(.bss)       /* Zero-filled run time allocate data memory */
	. = ALIGN(4);
        __bss_end__ = .;
    } >ram
}

__data_size__ = SIZEOF(.data);
__bss_size__ = SIZEOF(.bss);
