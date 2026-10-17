/*
 * rom.ld - Linker Script for Macintosh Quadra 800 1MB ROM
 *
 * Maps bare-metal 68040 code into physical ROM address space at 0x40800000.
 */

OUTPUT_FORMAT("elf32-m68k")
OUTPUT_ARCH(m68k)
ENTRY(_rom_start)

MEMORY
{
    rom (rx) : ORIGIN = 0x40800000, LENGTH = 1048576
}

SECTIONS
{
    /* ROM Header and Reset Sequence at offset 0 (0x40800000) */
    .rom_head 0x40800000 : {
        KEEP(*boot/reset.o(.text .text.*))
    } > rom

    /* Trap Dispatcher, C managers and runtime text */
    .text : {
        *(.text)
        *(.text.*)
    } > rom

    /* Read-only data tables, trap tables, constants */
    .rodata : {
        *(.rodata)
        *(.rodata.*)
    } > rom

    .data : {
        *(.data)
        *(.data.*)
    } > rom

    .bss : {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    } > rom

    /* NuBus Declaration ROM structures (placed at upper memory) */
    .declrom 0x408F0000 : {
        KEEP(*declrom/*.o(.rodata .rodata.* .data .data.*))
    } > rom

    /* NuBus Declaration ROM Format Block at top of 1MB space (0x408FFFEC) */
    .format_block 0x408FFFEC : {
        LONG(-54088)        /* Directory offset: points to Motherboard sResource Directory */
        LONG(0x00000000)    /* Length */
        LONG(0x00000000)    /* CRC */
        BYTE(0x01)          /* NuBus Revision */
        BYTE(0x01)          /* Format version */
        LONG(0x5A932BC7)    /* Test Pattern ($5A932BC7) */
        BYTE(0x00)          /* Reserved */
        BYTE(0x0F)          /* ByteLanes: 32-bit word lanes ($0F) */
    } > rom
}
