/* ROM resource 'CURS' 2: map entry at 0x4087EB10, data at 0x4087EB40, 68 bytes

 Cursor 2: 16x16 image, mask and hot spot.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_CURS_2_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 4087EB10
    .long   rsrc_CURS_3_entry-rom_start	| 4087EB18
    .long   rsrc_CURS_2-rom_start	| 4087EB1C
    .ascii  "CURS"	| 4087EB20
    .byte   0x00, 0x02, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087EB24
    .long   0x00000000, 0xC0A00000, 0x00000050, 0x00000064	| 4087EB30
rsrc_CURS_2:            /* the resource data */
    .include "rsrc/icons/curs_2.s"
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087EB84
