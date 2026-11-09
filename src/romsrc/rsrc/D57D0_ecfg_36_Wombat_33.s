/* ROM resource 'ecfg' 36 "Wombat 33": map entry at 0x408D57D0, data at 0x408D5800, 36 bytes

 Ethernet configuration for Wombat 33: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_36_Wombat_33_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D57D0
    .long   rsrc_ecfg_51_Wombat_40_entry-rom_start	| 408D57D8
    .long   rsrc_ecfg_36_Wombat_33-rom_start	| 408D57DC
    .ascii  "ecfg"	| 408D57E0
    .byte   0x00, 0x24, 0x58	| 408D57E4
    .byte   9	/* 408D57E7 Pascal string length */
    .ascii  "Wombat 33"	| 408D57E8
    .byte   0x47, 0x44, 0x43, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x64	| 408D57F1
rsrc_ecfg_36_Wombat_33:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D5800
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D5810
    .byte   0x00, 0x00, 0x00, 0x00	| 408D5820
    FILL_408D5824
