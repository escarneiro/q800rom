/* ROM resource 'FONT' 384 "Geneva": map entry at 0x4087DB60, data at 0x4087DB90, 0 bytes

 Bitmapped font 384 "Geneva".
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_FONT_384_Geneva_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 4087DB60
    .long   rsrc_FONT_393_entry-rom_start	| 4087DB68
    .long   rsrc_FONT_12_entry-rom_start	| 4087DB6C
    .ascii  "FONT"	| 4087DB70
    .byte   0x01, 0x80, 0x58, 0x06	| 4087DB74
    .ascii  "Geneva\000\000"
    .long   0x00000000, 0xC0A00000, 0x0000000C, 0x0000008C	| 4087DB80
