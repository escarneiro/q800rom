/* ROM resource 'FONT' 396: map entry at 0x4087C460, data at 0x4087C490, 3176 bytes

 Bitmapped font 396.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_FONT_396_entry:    /* map entry */
    .long   0x78000000, 0x00000000	| 4087C460
    .long   rsrc_FONT_512_Monaco_entry-rom_start	| 4087C468
    .long   rsrc_FONT_396-rom_start	| 4087C46C
    .ascii  "FONT"	| 4087C470
    .byte   0x01, 0x8C, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087C474
    .long   0x00000000, 0xC0A00000, 0x00000C74, 0x0000009C	| 4087C480
rsrc_FONT_396:          /* the resource data */
    .include "rsrc/fonts/geneva12.s"
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087D0F8
