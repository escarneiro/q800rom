/* ROM resource 'CURS' 4: map entry at 0x4087EA10, data at 0x4087EA40, 68 bytes

 Cursor 4: 16x16 image, mask and hot spot.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_CURS_4_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 4087EA10
    .long   rsrc_FONT_0_Chicago_entry-rom_start	| 4087EA18
    .long   rsrc_CURS_4-rom_start	| 4087EA1C
    .ascii  "CURS"	| 4087EA20
    .byte   0x00, 0x04, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087EA24
    .long   0x00000000, 0xC0A00000, 0x00000050, 0x00000074	| 4087EA30
rsrc_CURS_4:            /* the resource data */
    .include "rsrc/icons/curs_4.s"
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087EA84
