/* ROM resource 'CURS' 3: map entry at 0x4087EA90, data at 0x4087EAC0, 68 bytes

 Cursor 3: 16x16 image, mask and hot spot.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_CURS_3_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 4087EA90
    .long   rsrc_CURS_4_entry-rom_start	| 4087EA98
    .long   rsrc_CURS_3-rom_start	| 4087EA9C
    .ascii  "CURS"	| 4087EAA0
    .byte   0x00, 0x03, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087EAA4
    .long   0x00000000, 0xC0A00000, 0x00000050, 0x0000006C	| 4087EAB0
rsrc_CURS_3:            /* the resource data */
    .include "rsrc/icons/curs_3.s"
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087EB04
