/* ROM resource 'PICT' 101 "DiskMode 1": map entry at 0x408570A0, data at 0x408570D0, 197 bytes

 A QuickDraw picture: DiskMode 1.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_PICT_101_DiskMode_1_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 408570A0
    .long   rsrc_PICT_102_DiskMode_2_entry-rom_start	| 408570A8
    .long   rsrc_PICT_101_DiskMode_1-rom_start	| 408570AC
    .ascii  "PICT"	| 408570B0
    .byte   0x00	| 408570B4
    .ascii  "eX\012DiskMode 1\000\000"
    .long   0xC0A00000, 0x000000D1, 0x0000022C	| 408570C4
rsrc_PICT_101_DiskMode_1:  /* the resource data */
    .long   0x00C50000, 0x00000024, 0x001C1101, 0x01000A00
    .long   0x00000000, 0x24001C98, 0x00040000, 0x00000024
    .long   0x001C0000, 0x00000024, 0x001C0000, 0x00000024
    .long   0x001C0000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x007FC000, 0x03FFC000
    .long   0x03FFC000, 0x03FFC000, 0x03FFC000, 0x038FC000
    .long   0x000FC000, 0x000FC000, 0x000FC000, 0x000FC000
    .long   0x000FC000, 0x000FC000, 0x000FC000, 0x000FC000
    .long   0x000FC000, 0x000FC000, 0x000FC000, 0x000FC000
    .long   0x000FC000, 0x000FC000, 0x03FFFF00, 0x03FFFF00
    .long   0x03FFFF00, 0x03FFFF00, 0x03FFFF00, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .byte   0x00, 0x00, 0x00, 0x00, 0xFF
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
