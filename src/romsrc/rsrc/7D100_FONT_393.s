/* ROM resource 'FONT' 393: map entry at 0x4087D100, data at 0x4087D130, 2594 bytes

 Bitmapped font 393.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_FONT_393_entry:    /* map entry */
    .long   0x78000000, 0x00000000	| 4087D100
    .long   rsrc_FONT_396_entry-rom_start	| 4087D108
    .long   rsrc_FONT_393-rom_start	| 4087D10C
    .ascii  "FONT"	| 4087D110
    .byte   0x01, 0x89, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087D114
    .long   0x00000000, 0xC0A00000, 0x00000A2E, 0x00000094	| 4087D120
rsrc_FONT_393:          /* the resource data */
    .include "rsrc/fonts/geneva9.s"
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087DB52
