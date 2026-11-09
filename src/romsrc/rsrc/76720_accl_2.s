/* ROM resource 'accl' 2: map entry at 0x40876720, data at 0x40876750, 98 bytes

 Mouse/trackball acceleration table 2 for the Cursor Device Manager (pairs of speed and
 gain values, inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_accl_2_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40876720
    .long   rsrc_accl_3_entry-rom_start	| 40876728
    .long   rsrc_accl_2-rom_start	| 4087672C
    .ascii  "accl"	| 40876730
    .byte   0x00, 0x02, 0x58, 0x00, 0x00, 0x00, 0x00	| 40876734
rsrc_accl_3_4B:         /* the resource data */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00	| 4087673B
    .long   0x00000000, 0xC0A00000, 0x0000006E, 0x0000012C	| 40876740
rsrc_accl_2:            /* (data) */
    .long   0x00000002, 0x00020000, 0x00000001, 0x00010000	| 40876750
    .short  0x0001, 0x0000, 0x0001, 0x0000, 0x0009	| 40876760
    .long   0x0000A762 /* number, not an address (F1) */	| 4087676A
    .long   0x00014000 /* number, not an address (F1) */	| 4087676E
    .long   0x00013B14 /* number, not an address (F1) */	| 40876772
    .long   0x0002A000 /* number, not an address (F1) */	| 40876776
    .long   0x0001A276 /* number, not an address (F1) */	| 4087677A
    .long   0x00048000 /* number, not an address (F1) */	| 4087677E
    .short  0x0001, 0xF627, 0x0008, 0xC000, 0x0002, 0x53B1, 0x0014	| 40876782
    .long   0x20000003, 0x00000031, 0x00000003, 0xEC4F004A	| 40876790
    .long   0x00000006, 0x9D8A0066, 0x80000026, 0x62760096	| 408767A0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408767B0
