/* ROM resource 'accl' 0: map entry at 0x40876860, data at 0x40876890, 34 bytes

 Mouse/trackball acceleration table 0 for the Cursor Device Manager (pairs of speed and
 gain values, inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_accl_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40876860
    .long   rsrc_accl_1_entry-rom_start	| 40876868
    .long   rsrc_accl_0-rom_start	| 4087686C
    .ascii  "accl"	| 40876870
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40876874
    .long   0x00000000, 0xC0A00000, 0x0000002E, 0x0000011C	| 40876880
rsrc_accl_0:            /* the resource data */
    .long   0x00000000, 0x00020000, 0x00000001, 0x00010000	| 40876890
    .long   0x00010000, 0x00010000, 0x00010001, 0x00000001	| 408768A0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408768B0
