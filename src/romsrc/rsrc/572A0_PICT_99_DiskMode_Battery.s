/* ROM resource 'PICT' 99 "DiskMode Battery": map entry at 0x408572A0, data at 0x408572E0, 197 bytes

 A QuickDraw picture: DiskMode Battery.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_PICT_99_DiskMode_Battery_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 408572A0
    .long   rsrc_PICT_100_DiskMode_0_entry-rom_start	| 408572A8
    .long   rsrc_PICT_99_DiskMode_Battery-rom_start	| 408572AC
    .ascii  "PICT"	| 408572B0
    .byte   0x00, 0x63, 0x58, 0x10	| 408572B4
    .ascii  "DiskMode Battery\000\000\000\000"
    .long   0x00000000	| 408572CC
    .long   0x00000000, 0xC0A00000, 0x000000D1, 0x0000021C	| 408572D0
rsrc_PICT_99_DiskMode_Battery:  /* the resource data */
    .long   0x00C50000, 0x00000018, 0x00211101, 0x01000A00
    .long   0x00000000, 0x18002198, 0x00060000, 0x00000018
    .long   0x00210000, 0x00000018, 0x00210000, 0x00000018
    .long   0x00210000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x7FFFFFF8
    .long   0x00004000, 0x00080000, 0x40000008, 0x00004F9F
    .long   0x3E080000, 0x4F9F3E08, 0x00004F9F, 0x3E0F0000
    .long   0x4F9F3E0F, 0x00004F9F, 0x3E0F0000, 0x4F9F3E0F
    .long   0x00004F9F, 0x3E0F0000, 0x4F9F3E0F, 0x00004F9F
    .long   0x3E080000, 0x4F9F3E08, 0x00004000, 0x00080000
    .long   0x40000008, 0x00007FFF, 0xFFF80000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .byte   0x00, 0x00, 0x00, 0x00, 0xFF
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
