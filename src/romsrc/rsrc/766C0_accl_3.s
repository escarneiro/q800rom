/* ROM resource 'accl' 3: map entry at 0x408766C0, data at 0x408766F0, 34 bytes

 Mouse/trackball acceleration table 3 for the Cursor Device Manager (pairs of speed and
 gain values, inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_accl_3_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 408766C0
    .long   rsrc_accl_4_entry-rom_start	| 408766C8
    .long   rsrc_accl_3-rom_start	| 408766CC
    .ascii  "accl"	| 408766D0
    .byte   0x00, 0x03, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408766D4
    .long   0x00000000, 0xC0A00000, 0x0000002E, 0x00000134	| 408766E0
rsrc_accl_3:            /* the resource data */
    .long   0x00000003, 0x00020000, 0x00000001, 0x00010000	| 408766F0
    .long   0x00010000, 0x00010000, 0x00010001, 0x00000001	| 40876700
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40876710
