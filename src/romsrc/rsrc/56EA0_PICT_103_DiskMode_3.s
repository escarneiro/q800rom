/* ROM resource 'PICT' 103 "DiskMode 3": map entry at 0x40856EA0, data at 0x40856ED0, 197 bytes

 A QuickDraw picture: DiskMode 3.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_PICT_103_DiskMode_3_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40856EA0
    .long   rsrc_PICT_104_DiskMode_4_entry-rom_start	| 40856EA8
    .long   rsrc_PICT_103_DiskMode_3-rom_start	| 40856EAC
    .ascii  "PICT"	| 40856EB0
    .byte   0x00	| 40856EB4
    .ascii  "gX\012DiskMode 3\000\000"
    .long   0xC0A00000, 0x000000D1, 0x0000023C	| 40856EC4
rsrc_PICT_103_DiskMode_3:  /* the resource data */
    .long   0x00C50000, 0x00000024, 0x001C1101, 0x01000A00
    .long   0x00000000, 0x24001C98, 0x00040000, 0x00000024
    .long   0x001C0000, 0x00000024, 0x001C0000, 0x00000024
    .long   0x001C0000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x07FF8000, 0x07FFE000
    .long   0x07FFF800, 0x07FFF800, 0x0603FC00, 0x0001FC00
    .long   0x0000FC00, 0x0000FC00, 0x0000FC00, 0x0001F800
    .long   0x0003F800, 0x00FFF000, 0x00FFC000, 0x00FFF800
    .long   0x00FFFC00, 0x0001FC00, 0x0000FE00, 0x00007E00
    .long   0x00007E00, 0x0800FE00, 0x0F01FE00, 0x0FFFFC00
    .long   0x0FFFF800, 0x0FFFF000, 0x03FF8000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .byte   0x00, 0x00, 0x00, 0x00, 0xFF
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
