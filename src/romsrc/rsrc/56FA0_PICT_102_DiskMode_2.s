/* ROM resource 'PICT' 102 "DiskMode 2": map entry at 0x40856FA0, data at 0x40856FD0, 197 bytes

 A QuickDraw picture: DiskMode 2.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_PICT_102_DiskMode_2_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40856FA0
    .long   rsrc_PICT_103_DiskMode_3_entry-rom_start	| 40856FA8
    .long   rsrc_PICT_102_DiskMode_2-rom_start	| 40856FAC
    .ascii  "PICT"	| 40856FB0
    .byte   0x00	| 40856FB4
    .ascii  "fX\012DiskMode 2\000\000"
    .long   0xC0A00000, 0x000000D1, 0x00000234	| 40856FC4
rsrc_PICT_102_DiskMode_2:  /* the resource data */
    .long   0x00C50000, 0x00000024, 0x001C1101, 0x01000A00
    .long   0x00000000, 0x24001C98, 0x00040000, 0x00000024
    .long   0x001C0000, 0x00000024, 0x001C0000, 0x00000024
    .long   0x001C0000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00FFC000, 0x07FFF000
    .long   0x07FFF800, 0x07FFFC00, 0x0781FE00, 0x0400FE00
    .long   0x00007E00, 0x00007E00, 0x00007E00, 0x00007E00
    .long   0x0000FE00, 0x0001FC00, 0x0003FC00, 0x000FF800
    .long   0x001FF000, 0x003FE000, 0x007FC000, 0x00FF8000
    .long   0x01FF0000, 0x03FE0000, 0x07FFFE00, 0x07FFFE00
    .long   0x07FFFE00, 0x07FFFE00, 0x07FFFE00, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .byte   0x00, 0x00, 0x00, 0x00, 0xFF
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
