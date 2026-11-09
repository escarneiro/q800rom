/* ROM resource 'clut' 4 "4BitStd": map entry at 0x408737A0, data at 0x408737D0, 136 bytes

 Colour table 4 "4BitStd": the standard colours for that pixel depth.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_clut_4_4BitStd_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 408737A0
    .long   rsrc_clut_8_8BitStd_entry-rom_start	| 408737A8
    .long   rsrc_clut_4_4BitStd-rom_start	| 408737AC
    .ascii  "clut"	| 408737B0
    .byte   0x00, 0x04, 0x58	| 408737B4
    .byte   7	/* 408737B7 Pascal string length */
    .ascii  "4BitStd"	| 408737B8
    .byte   0x00	| 408737BF
    .long   0x00000000, 0xC0A00000, 0x00000094	| 408737C0
    .long   0x00000174 /* number, not a label difference (was rsrc_PACK_4-.) */	| 408737CC
rsrc_clut_4_4BitStd:    /* the resource data */
    .long   0x00000004, 0x8000000F, 0x0000FFFF, 0xFFFFFFFF	| 408737D0
    .long   0x0000FC00, 0xF37D052F, 0x0000FFFF, 0x648A028C	| 408737E0
    .long   0x0000DD6B, 0x08C206A2, 0x0000F2D7, 0x085684EC	| 408737F0
    .long   0x000046E3, 0x0000A53E, 0x00000000, 0x0000D400	| 40873800
    .long   0x00000241, 0xAB54EAFF, 0x00001F21, 0xB7931431	| 40873810
    .long   0x00000000, 0x64AF11B0, 0x00005600, 0x2C9D0524	| 40873820
    .long   0x000090D7, 0x71603A34, 0x0000C000, 0xC000C000	| 40873830
    .long   0x00008000, 0x80008000, 0x00004000, 0x40004000	| 40873840
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40873850
