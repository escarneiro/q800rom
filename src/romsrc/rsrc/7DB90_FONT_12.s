/* ROM resource 'FONT' 12: map entry at 0x4087DB90, data at 0x4087DBC0, 3614 bytes

 Bitmapped font 12.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_FONT_12_entry:     /* map entry */
    .long   0x78000000, 0x00000000	| 4087DB90
    .long   rsrc_FONT_384_Geneva_entry-rom_start	| 4087DB98
    .long   rsrc_FONT_12-rom_start	| 4087DB9C
    .ascii  "FONT"	| 4087DBA0
    .byte   0x00, 0x0C, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087DBA4
    .long   0x00000000, 0xC0A00000, 0x00000E2A, 0x00000084	| 4087DBB0
rsrc_FONT_12:           /* the resource data */
    .include "rsrc/fonts/chicago12.s"
    .byte   0x00, 0x00	| 4087E9DE
