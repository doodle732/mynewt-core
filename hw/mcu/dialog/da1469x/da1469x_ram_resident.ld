/* Linker script for Nordic Semiconductor nRF5 devices
 *
 * Version: Sourcery G++ 4.5-1
 * Support: https://support.codesourcery.com/GNUToolchain/
 *
 * Copyright (c) 2007, 2008, 2009, 2010 CodeSourcery, Inc.
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions.  No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 */
OUTPUT_FORMAT ("elf32-littlearm", "elf32-bigarm", "elf32-littlearm")

ENTRY(Reset_Handler)

SECTIONS
{
    .text :
    {
        __text = .;
        __intvect_start__ = .;
        __isr_vector_start = .;
        KEEP(*(.isr_vector))
        /* ISR vector shall have exactly 512 bytes */
        . = __isr_vector_start + 0x200;
        __isr_vector_end = .;
        *(.text*)

        KEEP(*(.init))
        KEEP(*(.fini))

        . = ALIGN(4);
        /* preinit data */
        PROVIDE_HIDDEN (__preinit_array_start = .);
        KEEP(*(.preinit_array))
        PROVIDE_HIDDEN (__preinit_array_end = .);

        . = ALIGN(4);
        /* init data */
        PROVIDE_HIDDEN (__init_array_start = .);
        KEEP(*(SORT(.init_array.*)))
        KEEP(*(.init_array))
        PROVIDE_HIDDEN (__init_array_end = .);

        . = ALIGN(4);
        /* finit data */
        PROVIDE_HIDDEN (__fini_array_start = .);
        KEEP(*(SORT(.fini_array.*)))
        KEEP(*(.fini_array))
        PROVIDE_HIDDEN (__fini_array_end = .);

        /* .ctors */
        *crtbegin.o(.ctors)
        *crtbegin?.o(.ctors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .ctors)
        *(SORT(.ctors.*))
        *(.ctors)

        /* .dtors */
        *crtbegin.o(.dtors)
        *crtbegin?.o(.dtors)
        *(EXCLUDE_FILE(*crtend?.o *crtend.o) .dtors)
        *(SORT(.dtors.*))
        *(.dtors)

INCLUDE "link_tables.ld.h"
        *(.rodata*)

        *(.eh_frame*)
        . = ALIGN(4);
        PROVIDE(mynewt_main = main);
    } > RAM

    .ARM.extab :
    {
        *(.ARM.extab* .gnu.linkonce.armextab.*)
        . = ALIGN(4);
    } > RAM

    __exidx_start = .;
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
        . = ALIGN(4);
    } > RAM
    __exidx_end = .;

    /* This section will be zeroed by RTT package init */
    .rtt (NOLOAD):
    {
        . = ALIGN(4);
        *(.rtt)
        . = ALIGN(4);
    } > RAM

    .text_ram :
    {
        . = ALIGN(4);
        __text_ram_start__ = .;
        *(.text_ram*)
        . = ALIGN(4);
        __text_ram_end__ = .;
    } > RAM

    .data :
    {
        __data_start__ = .;
        *(vtable)
        *(.data*)

        *(.jcr)
        . = ALIGN(4);
        /* All data end */
        __data_end__ = .;
    } > RAM

    .bssnz :
    {
        . = ALIGN(4);
        __bssnz_start__ = .;
        *(.bss.core.nz*)
        . = ALIGN(4);
        __bssnz_end__ = .;
    } > RAM

    .bss :
    {
        . = ALIGN(4);
        __bss_start__ = .;
        *(.bss*)
        *(COMMON)
        . = ALIGN(4);
        __bss_end__ = .;
    } > RAM

    /* Heap starts after BSS */
    . = ALIGN(8);
    __HeapBase = .;

    /* .stack_dummy section doesn't contains any symbols. It is only
     * used for linker to calculate size of stack sections, and assign
     * values to stack symbols later */
    .stack_dummy (COPY):
    {
        *(.stack*)
    } > RAM

    _ram_start = ORIGIN(RAM);

    /* Set stack top to end of RAM, and stack limit move down by
     * size of stack_dummy section */
    __StackTop = ORIGIN(RAM) + LENGTH(RAM);
    __StackLimit = __StackTop - SIZEOF(.stack_dummy);
    PROVIDE(__stack = __StackTop);

    /* Top of head is the bottom of the stack */
    __HeapLimit = __StackLimit;

    /* Check if data + heap + stack exceeds RAM limit */
    ASSERT(__HeapBase <= __HeapLimit, "region RAM overflowed with stack")

    /* Check that intvect is at the beginning of RAM */
    ASSERT(__intvect_start__ == ORIGIN(RAM), "intvect is not at beginning of RAM")
}

