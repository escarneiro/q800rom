/* ROM resource 'PICT' 106 "DiskMode 6": map entry at 0x40856BA0, data at 0x40856BD0, 197 bytes

 A QuickDraw picture: DiskMode 6.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_PICT_106_DiskMode_6_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40856BA0
    .long   rsrc_free_0_Main_entry-rom_start	| 40856BA8
    .long   rsrc_PICT_106_DiskMode_6-rom_start	| 40856BAC
    .ascii  "PICT"	| 40856BB0
    .byte   0x00	| 40856BB4
    .ascii  "jX\012DiskMode 6\000\000"
    .long   0xC0A00000, 0x000000D1, 0x00000254	| 40856BC4
rsrc_PICT_106_DiskMode_6:  /* the resource data */
    .long   0x00C50000, 0x00000024, 0x001C1101, 0x01000A00
    .long   0x00000000, 0x24001C98, 0x00040000, 0x00000024
    .long   0x001C0000, 0x00000024, 0x001C0000, 0x00000024
    .long   0x001C0000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x000FFC00, 0x007FFC00
    .long   0x00FFFC00, 0x01FFFC00, 0x03F80C00, 0x03F00000
    .long   0x07E00000, 0x07C00000, 0x0FCFE000, 0x0FFFF800
    .long   0x0FFFFC00, 0x0FFFFE00, 0x0FF8FE00, 0x0FF07F00
    .long   0x0FE03F00, 0x0FE03F00, 0x0FE03F00, 0x07E03F00
    .long   0x07E03F00, 0x07F07E00, 0x03F8FE00, 0x03FFFC00
    .long   0x01FFF800, 0x007FF000, 0x001FC000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .byte   0x00, 0x00, 0x00, 0x00, 0xFF
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
