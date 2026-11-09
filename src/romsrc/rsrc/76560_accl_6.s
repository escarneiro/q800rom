/* ROM resource 'accl' 6: map entry at 0x40876560, data at 0x40876590, 98 bytes

 Mouse/trackball acceleration table 6 for the Cursor Device Manager (pairs of speed and
 gain values, inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_accl_6_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40876560
    .long   rsrc_accl_7_entry-rom_start	| 40876568
    .long   rsrc_accl_6-rom_start	| 4087656C
    .ascii  "accl"	| 40876570
    .byte   0x00, 0x06, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40876574
    .long   0x00000000, 0xC0A00000, 0x0000006E, 0x0000014C	| 40876580
rsrc_accl_6:            /* the resource data */
    .long   0x40323030, 0x00020000, 0x00000001, 0x00010000	| 40876590
    .long   0x00010000, 0x00010000, 0x00090000, 0x00000000	| 408765A0
    .long   0x00000000, 0x713B0000, 0x60000004, 0x4EC50010	| 408765B0
    .long   0x8000000C, 0x0000005F, 0x00000016, 0xEC4F008B	| 408765C0
    .long   0x0000001D, 0x3B140094, 0x80000022, 0x76270096	| 408765D0
    .long   0x00000024, 0x62760096, 0x00000028, 0x00000096	| 408765E0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408765F0
