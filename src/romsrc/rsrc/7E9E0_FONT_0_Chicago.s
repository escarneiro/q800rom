/* ROM resource 'FONT' 0 "Chicago": map entry at 0x4087E9E0, data at 0x4087EA10, 0 bytes

 Bitmapped font 0 "Chicago".
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_FONT_0_Chicago_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 4087E9E0
    .long   rsrc_FONT_12_entry-rom_start	| 4087E9E8
    .long   rsrc_CURS_4_entry-rom_start	| 4087E9EC
    .ascii  "FONT"	| 4087E9F0
    .byte   0x00, 0x00, 0x58, 0x07	| 4087E9F4
    .ascii  "Chicago\000"
    .long   0x00000000, 0xC0A00000, 0x0000000C, 0x0000007C	| 4087EA00
