/* ROM resource 'PICT' 100 "DiskMode 0": map entry at 0x408571A0, data at 0x408571D0, 197 bytes

 A QuickDraw picture: DiskMode 0.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_PICT_100_DiskMode_0_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 408571A0
    .long   rsrc_PICT_101_DiskMode_1_entry-rom_start	| 408571A8
    .long   rsrc_PICT_100_DiskMode_0-rom_start	| 408571AC
    .ascii  "PICT"	| 408571B0
    .byte   0x00	| 408571B4
    .ascii  "dX\012DiskMode 0\000\000"
    .long   0xC0A00000, 0x000000D1, 0x00000224	| 408571C4
rsrc_PICT_100_DiskMode_0:  /* the resource data */
    .long   0x00C50000, 0x00000024, 0x001C1101, 0x01000A00
    .long   0x00000000, 0x24001C98, 0x00040000, 0x00000024
    .long   0x001C0000, 0x00000024, 0x001C0000, 0x00000024
    .long   0x001C0000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x001F8000, 0x00FFF000
    .long   0x01FFF800, 0x03FFFC00, 0x03F0FC00, 0x07E07E00
    .long   0x07E07E00, 0x07C03E00, 0x0FC03F00, 0x0FC03F00
    .long   0x0FC03F00, 0x0FC03F00, 0x0FC03F00, 0x0FC03F00
    .long   0x0FC03F00, 0x0FC03F00, 0x0FC03F00, 0x07C03E00
    .long   0x07E07E00, 0x07E07E00, 0x03F0FC00, 0x03FFFC00
    .long   0x01FFF800, 0x00FFE000, 0x001F8000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .byte   0x00, 0x00, 0x00, 0x00, 0xFF
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
