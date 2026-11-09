/* ROM resource 'ecfg' 26 "Quadra950": map entry at 0x408D5950, data at 0x408D5980, 36 bytes

 Ethernet configuration for Quadra950: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_26_Quadra950_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5950
    .long   rsrc_ecfg_27_Vail_entry-rom_start	| 408D5958
    .long   rsrc_ecfg_26_Quadra950-rom_start	| 408D595C
    .ascii  "ecfg"	| 408D5960
    .byte   0x00, 0x1A, 0x58	| 408D5964
    .byte   9	/* 408D5967 Pascal string length */
    .ascii  "Quadra950"	| 408D5968
    .byte   0x65, 0x20, 0x43, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x44	| 408D5971
rsrc_ecfg_26_Quadra950:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D5980
    .long   0x0000802C /* number, not a label difference (was rsrc_drvr_9_60C-.) */	| 408D5990
    .long   0x00000000, 0x09010000, 0x00000000	| 408D5994
    .byte   0x00, 0x00, 0x00, 0x00	| 408D59A0
    FILL_408D59A4
