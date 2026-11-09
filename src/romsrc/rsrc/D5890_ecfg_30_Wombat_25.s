/* ROM resource 'ecfg' 30 "Wombat 25": map entry at 0x408D5890, data at 0x408D58C0, 36 bytes

 Ethernet configuration for Wombat 25: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_30_Wombat_25_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5890
    .long   rsrc_ecfg_35_Wombat_33F_entry-rom_start	| 408D5898
    .long   rsrc_ecfg_30_Wombat_25-rom_start	| 408D589C
    .ascii  "ecfg"	| 408D58A0
    .byte   0x00, 0x1E, 0x58	| 408D58A4
    .byte   9	/* 408D58A7 Pascal string length */
    .ascii  "Wombat 25"	| 408D58A8
    .byte   0x54, 0x57, 0x54, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x54	| 408D58B1
rsrc_ecfg_30_Wombat_25:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D58C0
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D58D0
    .byte   0x00, 0x00, 0x00, 0x00	| 408D58E0
    FILL_408D58E4
