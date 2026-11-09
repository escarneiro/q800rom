/* ROM resource 'accl' 1: map entry at 0x408767C0, data at 0x408767F0, 98 bytes

 Mouse/trackball acceleration table 1 for the Cursor Device Manager (pairs of speed and
 gain values, inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_accl_1_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 408767C0
    .long   rsrc_accl_2_entry-rom_start	| 408767C8
    .long   rsrc_accl_1-rom_start	| 408767CC
    .ascii  "accl"	| 408767D0
    .byte   0x00, 0x01, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408767D4
    .long   0x00000000, 0xC0A00000, 0x0000006E, 0x00000124	| 408767E0
rsrc_accl_1:            /* the resource data */
    .long   0x00000001, 0x00020000, 0x00000001, 0x00010000	| 408767F0
    .long   0x00010000, 0x00010000, 0x00090000, 0x00000000	| 40876800
    .long   0x00000000, 0x713B0000, 0x60000004, 0x4EC50010	| 40876810
    .long   0x8000000C, 0x0000005F, 0x00000016, 0xEC4F008B	| 40876820
    .long   0x0000001D, 0x3B140094, 0x80000022, 0x76270096	| 40876830
    .long   0x00000024, 0x62760096, 0x00000028, 0x00000096	| 40876840
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40876850
rsrc_accl_1_6B:         /* (data) */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00	| 4087685B
