/* ROM resource 'PICT' 105 "DiskMode 5": map entry at 0x40856CA0, data at 0x40856CD0, 197 bytes

 A QuickDraw picture: DiskMode 5.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_PICT_105_DiskMode_5_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40856CA0
    .long   rsrc_PICT_106_DiskMode_6_entry-rom_start	| 40856CA8
    .long   rsrc_PICT_105_DiskMode_5-rom_start	| 40856CAC
    .ascii  "PICT"	| 40856CB0
    .byte   0x00	| 40856CB4
    .ascii  "iX\012DiskMode 5\000\000"
    .long   0xC0A00000, 0x000000D1, 0x0000024C	| 40856CC4
rsrc_PICT_105_DiskMode_5:  /* the resource data */
    .long   0x00C50000, 0x00000024, 0x001C1101, 0x01000A00
    .long   0x00000000, 0x24001C98, 0x00040000, 0x00000024
    .long   0x001C0000, 0x00000024, 0x001C0000, 0x00000024
    .long   0x001C0000, 0x00000000, 0x00000000, 0x00000000
    .long   0x00000000, 0x00000000, 0x03FFFC00, 0x03FFFC00
    .long   0x03FFFC00, 0x03FFFC00, 0x03FFFC00, 0x03E00000
    .long   0x03E00000, 0x03E00000, 0x03FFC000, 0x03FFF000
    .long   0x03FFFC00, 0x03FFFE00, 0x0301FE00, 0x00007F00
    .long   0x00003F00, 0x00003F00, 0x00003F00, 0x00003F00
    .long   0x00003F00, 0x04007F00, 0x0781FE00, 0x07FFFC00
    .long   0x07FFF800, 0x07FFF000, 0x01FFC000, 0x00000000
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000
    .byte   0x00, 0x00, 0x00, 0x00, 0xFF
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
