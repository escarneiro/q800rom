/* ROM resource 'CURS' 1: map entry at 0x4087EB90, data at 0x4087EBC0, 68 bytes

 Cursor 1: 16x16 image, mask and hot spot.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_CURS_1_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 4087EB90
    .long   rsrc_CURS_2_entry-rom_start	| 4087EB98
    .long   rsrc_CURS_1-rom_start	| 4087EB9C
    .ascii  "CURS"	| 4087EBA0
    .byte   0x00, 0x01, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087EBA4
    .long   0x00000000, 0xC0A00000, 0x00000050, 0x0000005C	| 4087EBB0
rsrc_CURS_1:            /* the resource data */
    .include "rsrc/icons/curs_1.s"
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087EC04
