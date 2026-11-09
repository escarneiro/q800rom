/* ROM resource 'PICT' 97 "DiskMode Arrow2": map entry at 0x40857520, data at 0x40857560, 304 bytes

 A QuickDraw picture: DiskMode Arrow2.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_PICT_97_DiskMode_Arrow2_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40857520
    .long   rsrc_PICT_98_DiskMode_Arrow3_entry-rom_start	| 40857528
    .long   rsrc_PICT_97_DiskMode_Arrow2-rom_start	| 4085752C
    .ascii  "PICT"	| 40857530
    .byte   0x00, 0x61, 0x58, 0x0F	| 40857534
    .ascii  "DiskMode Arrow2\000"
    .long   0x00000000, 0x00000000	| 40857548
    .long   0x00000000, 0xC0A00000, 0x0000013C, 0x0000020C	| 40857550
rsrc_PICT_97_DiskMode_Arrow2:  /* the resource data */
    .long   0x00F30000, 0x0000001B, 0x004C1101, 0x01000A00
    .long   0x00000000, 0x1B004C98, 0x000A0000, 0x0000001B
    .long   0x004C0000, 0x0000001B, 0x004C0000, 0x0000001B
    .long   0x004C0000, 0x02F70002, 0xF70002F7, 0x0006FA00
    .long   0x02800000, 0x06FA0002, 0xE0000006, 0xFA0002F0
    .long   0x000006FA, 0x0002FC00, 0x0006FA00, 0x02FE0000
    .long   0x06FA0002, 0xFF800006, 0xFA0002FF, 0xE00006FA
    .long   0x0002FFF0, 0x000B0900, 0x3FF00FFC, 0x03FFFFFC
    .long   0x000B0900, 0x3FF00FFC, 0x03FFFFFE, 0x000B0500
    .long   0x3FF00FFC, 0x03FEFF00, 0x800B0900, 0x3FF00FFC
    .long   0x03FFFFFE, 0x000B0900, 0x3FF00FFC, 0x03FFFFFC
    .long   0x0006FA00, 0x02FFF000, 0x06FA0002, 0xFFE00006
    .long   0xFA0002FF, 0x800006FA, 0x0002FE00, 0x0006FA00
    .long   0x02FC0000, 0x06FA0002, 0xF0000006, 0xFA0002E0
    .long   0x000006FA, 0x00028000, 0x0002F700, 0x02F70002
    .long   0xF700FF00, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
