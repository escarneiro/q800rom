/* ROM resource 'free' 4 "Main": map entry at 0x408E6370, data at 0x408E63A0, 4400 bytes

 Free space in the ROM (a placeholder resource, unused).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_free_4_Main_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 408E6370
    .long   rsrc_DRVR_3__Sound_entry-rom_start	| 408E6378
    .long   rsrc_free_4_Main-rom_start	| 408E637C
    .ascii  "free"	| 408E6380
    .byte   0x00, 0x04, 0x58	| 408E6384
    .byte   4	/* 408E6387 Pascal string length */
    .ascii  "Main"	| 408E6388
    FILL_408E638C
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x11, 0x3C, 0x00, 0x00, 0x02, 0x94	| 408E6394
rsrc_free_4_Main:       /* the resource data */
    .fill   0x1130, 1, 0x00
