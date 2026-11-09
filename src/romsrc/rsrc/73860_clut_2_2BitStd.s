/* ROM resource 'clut' 2 "2BitStd": map entry at 0x40873860, data at 0x40873890, 40 bytes

 Colour table 2 "2BitStd": the standard colours for that pixel depth.
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_clut_2_2BitStd_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40873860
    .long   rsrc_clut_4_4BitStd_entry-rom_start	| 40873868
    .long   rsrc_clut_2_2BitStd-rom_start	| 4087386C
    .ascii  "clut"	| 40873870
    .byte   0x00, 0x02, 0x58	| 40873874
    .byte   7	/* 40873877 Pascal string length */
    .ascii  "2BitStd"	| 40873878
    .byte   0x00	| 4087387F
    .long   0x00000000, 0xC0A00000, 0x00000034, 0x0000016C	| 40873880
rsrc_clut_2_2BitStd:    /* the resource data */
    .long   0x00000002, 0x80000003, 0x0000FFFF, 0xFFFFFFFF	| 40873890
    .long   0x0000ACAC, 0xACACACAC, 0x00005555, 0x55555555	| 408738A0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408738B0
