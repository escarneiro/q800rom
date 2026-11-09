/* ROM resource 'FONT' 512 "Monaco": map entry at 0x4087C430, data at 0x4087C460, 0 bytes

 Bitmapped font 512 "Monaco".
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_FONT_512_Monaco_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 4087C430
    .long   rsrc_FONT_521_entry-rom_start	| 4087C438
    .long   rsrc_FONT_396_entry-rom_start	| 4087C43C
    .ascii  "FONT"	| 4087C440
    .byte   0x02, 0x00, 0x58, 0x06	| 4087C444
    .ascii  "Monaco\000\000"
    .long   0x00000000, 0xC0A00000, 0x0000000C, 0x000000A4	| 4087C450
