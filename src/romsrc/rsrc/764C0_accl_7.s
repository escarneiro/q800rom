/* ROM resource 'accl' 7: map entry at 0x408764C0, data at 0x408764F0, 98 bytes

 Mouse/trackball acceleration table 7 for the Cursor Device Manager (pairs of speed and
 gain values, inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_accl_7_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 408764C0
    .long   rsrc_PACK_4_entry-rom_start	| 408764C8
    .long   rsrc_accl_7-rom_start	| 408764CC
    .ascii  "accl"	| 408764D0
    .byte   0x00, 0x07, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408764D4
    .long   0x00000000, 0xC0A00000, 0x0000006E, 0x00000154	| 408764E0
rsrc_accl_7:            /* the resource data */
    .byte   0x50, 0x47, 0x26, 0x45, 0x00, 0x02, 0x00, 0x00, 0x00, 0x00, 0x00	| 408764F0
rsrc_accl_7_B:          /* (data) */
    .byte   0x01, 0x00, 0x01, 0x00, 0x00	| 408764FB
    .short  0x0001, 0x0000, 0x0001, 0x0000, 0x0009	| 40876500
    .long   0x0000A762 /* number, not an address (F1) */	| 4087650A
    .long   0x00014000 /* number, not an address (F1) */	| 4087650E
    .long   0x00013B14 /* number, not an address (F1) */	| 40876512
    .long   0x0002A000 /* number, not an address (F1) */	| 40876516
    .long   0x0001A276 /* number, not an address (F1) */	| 4087651A
    .long   0x00048000 /* number, not an address (F1) */	| 4087651E
    .short  0x0001, 0xF627, 0x0008, 0xC000, 0x0002, 0x53B1, 0x0014	| 40876522
    .long   0x20000003, 0x00000031, 0x00000003, 0xEC4F004A	| 40876530
    .long   0x00000006, 0x9D8A0066, 0x80000026, 0x62760096	| 40876540
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40876550
