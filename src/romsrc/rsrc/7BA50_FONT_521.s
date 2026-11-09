/* ROM resource 'FONT' 521: map entry at 0x4087BA50, data at 0x4087BA80, 2468 bytes

 Bitmapped font 521.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_FONT_521_entry:    /* map entry */
    .long   0x78000000, 0x00000000	| 4087BA50
    .long   rsrc_KCHR_0_entry-rom_start	| 4087BA58
    .long   rsrc_FONT_521-rom_start	| 4087BA5C
    .ascii  "FONT"	| 4087BA60
    .byte   0x02, 0x09, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087BA64
    .long   0x00000000, 0xC0A00000, 0x000009B0, 0x000000AC	| 4087BA70
rsrc_FONT_521:          /* the resource data */
    .include "rsrc/fonts/monaco9.s"
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087C424
