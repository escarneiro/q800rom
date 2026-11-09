/* ROM resource 'accl' 4: map entry at 0x40876660, data at 0x40876690, 34 bytes

 Mouse/trackball acceleration table 4 for the Cursor Device Manager (pairs of speed and
 gain values, inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_accl_4_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40876660
    .long   rsrc_accl_5_entry-rom_start	| 40876668
    .long   rsrc_accl_4-rom_start	| 4087666C
    .ascii  "accl"	| 40876670
    .byte   0x00, 0x04, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40876674
    .long   0x00000000, 0xC0A00000, 0x0000002E, 0x0000013C	| 40876680
rsrc_accl_4:            /* the resource data */
    .long   0x00000004, 0x00020000, 0x00000001, 0x00010000	| 40876690
    .long   0x00010000, 0x00010000, 0x00010001, 0x00000001	| 408766A0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408766B0
