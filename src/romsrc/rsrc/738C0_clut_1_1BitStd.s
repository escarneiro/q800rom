/* ROM resource 'clut' 1 "1BitStd": map entry at 0x408738C0, data at 0x408738F0, 24 bytes

 Colour table 1 "1BitStd": the standard colours for that pixel depth.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_clut_1_1BitStd_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 408738C0
    .long   rsrc_clut_2_2BitStd_entry-rom_start	| 408738C8
    .long   rsrc_clut_1_1BitStd-rom_start	| 408738CC
    .ascii  "clut"	| 408738D0
    .byte   0x00, 0x01, 0x58	| 408738D4
    .byte   7	/* 408738D7 Pascal string length */
    .ascii  "1BitStd"	| 408738D8
    .byte   0x00	| 408738DF
    .long   0x00000000, 0xC0A00000, 0x00000024, 0x00000164	| 408738E0
rsrc_clut_1_1BitStd:    /* the resource data */
    .long   0x00000001, 0x80000001, 0x0000FFFF, 0xFFFFFFFF	| 408738F0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40873900
