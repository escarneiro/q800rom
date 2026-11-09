/* ROM resource 'free' 0 "Main": map entry at 0x408568F0, data at 0x40856920, 640 bytes

 Free space in the ROM (a placeholder resource, unused).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_free_0_Main_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 408568F0
    .long   rsrc_DRVR_50__ATBOOT_entry-rom_start	| 408568F8
    .long   rsrc_free_0_Main-rom_start	| 408568FC
    .ascii  "free"	| 40856900
    .byte   0x00, 0x00, 0x58	| 40856904
    .byte   4	/* 40856907 Pascal string length */
    .ascii  "Main"	| 40856908
    .byte   0x00, 0x00, 0x00, 0x00	| 4085690C
    .long   0x00000000, 0xC0A00000, 0x0000028C, 0x0000025C	| 40856910
rsrc_free_0_Main:       /* the resource data */
    .fill   0x280, 1, 0x00
