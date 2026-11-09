/* ROM resource 'ecfg' 22 "Quadra700": map entry at 0x408D59B0, data at 0x408D59E0, 36 bytes

 Ethernet configuration for Quadra700: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_22_Quadra700_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D59B0
    .long   rsrc_ecfg_26_Quadra950_entry-rom_start	| 408D59B8
    .long   rsrc_ecfg_22_Quadra700-rom_start	| 408D59BC
    .ascii  "ecfg"	| 408D59C0
    .byte   0x00, 0x16, 0x58	| 408D59C4
    .byte   9	/* 408D59C7 Pascal string length */
    .ascii  "Quadra700"	| 408D59C8
    .byte   0x4D, 0x42, 0x50, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x3C	| 408D59D1
rsrc_ecfg_22_Quadra700:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D59E0
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D59F0
    .long   0x00000000	| 408D5A00
    FILL_408D5A04
