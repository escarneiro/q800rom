/* ROM resource 'accl' 5: map entry at 0x40876600, data at 0x40876630, 34 bytes

 Mouse/trackball acceleration table 5 for the Cursor Device Manager (pairs of speed and
 gain values, inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_accl_5_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40876600
    .long   rsrc_accl_6_entry-rom_start	| 40876608
    .long   rsrc_accl_5-rom_start	| 4087660C
    .ascii  "accl"	| 40876610
    .byte   0x00, 0x05, 0x58, 0x00, 0x00, 0x00, 0x00	| 40876614
rsrc_accl_6_8B:         /* the resource data */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00	| 4087661B
    .long   0x00000000, 0xC0A00000, 0x0000002E, 0x00000144	| 40876620
rsrc_accl_5:            /* (data) */
    .long   0x00000005, 0x00020000, 0x00000001, 0x00010000	| 40876630
    .long   0x00010000, 0x00010000, 0x00010001, 0x00000001	| 40876640
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40876650
