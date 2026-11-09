/* ROM resource 'free' 1 "Main": map entry at 0x40859500, data at 0x40859530, 4656 bytes

 Free space in the ROM (a placeholder resource, unused).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_free_1_Main_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40859500
    .long   rsrc_attx_1_entry-rom_start	| 40859508
    .long   rsrc_free_1_Main-rom_start	| 4085950C
    .ascii  "free"	| 40859510
    .byte   0x00, 0x01, 0x58	| 40859514
    .byte   4	/* 40859517 Pascal string length */
    .ascii  "Main"	| 40859518
    .byte   0x00, 0x00, 0x00, 0x00	| 4085951C
    .long   0x00000000, 0xC0A00000, 0x0000123C, 0x000001E4	| 40859520
rsrc_free_1_Main:       /* the resource data */
    .fill   0x1230, 1, 0x00
