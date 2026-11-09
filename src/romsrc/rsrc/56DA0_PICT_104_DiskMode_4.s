/* ROM resource 'PICT' 104 "DiskMode 4": map entry at 0x40856DA0, data at 0x40856DD0, 197 bytes

 A QuickDraw picture: DiskMode 4.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_PICT_104_DiskMode_4_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40856DA0
    .long   rsrc_PICT_105_DiskMode_5_entry-rom_start	| 40856DA8
    .long   rsrc_PICT_104_DiskMode_4-rom_start	| 40856DAC
    .ascii  "PICT"	| 40856DB0
    .byte   0x00	| 40856DB4
    .ascii  "hX\012DiskMode 4\000\000"
    .long   0xC0A00000, 0x000000D1, 0x00000244	| 40856DC4
rsrc_PICT_104_DiskMode_4:  /* the resource data */
    .long   0x00C50000, 0x00000024, 0x001C1101, 0x01000A00
    .long   0x00000000, 0x24001C98, 0x00040000, 0x00000024
    .long   0x001C0000, 0x00000024, 0x001C0000, 0x00000024
    .long   0x001C0000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x0003F800, 0x0007F800
    .long   0x000FF800, 0x000FF800, 0x001FF800, 0x003FF800
    .long   0x003DF800, 0x007DF800, 0x00F9F800, 0x00F9F800
    .long   0x01F1F800, 0x03E1F800, 0x03E1F800, 0x07C1F800
    .long   0x0781F800, 0x0F81F800, 0x0FFFFF80, 0x0FFFFF80
    .long   0x0FFFFF80, 0x0FFFFF80, 0x0FFFFF80, 0x0001F800
    .long   0x0001F800, 0x0001F800, 0x0001F800, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .byte   0x00, 0x00, 0x00, 0x00, 0xFF
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
