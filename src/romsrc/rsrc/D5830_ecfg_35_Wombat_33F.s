/* ROM resource 'ecfg' 35 "Wombat 33F": map entry at 0x408D5830, data at 0x408D5860, 36 bytes

 Ethernet configuration for Wombat 33F: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_35_Wombat_33F_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5830
    .long   rsrc_ecfg_36_Wombat_33_entry-rom_start	| 408D5838
    .long   rsrc_ecfg_35_Wombat_33F-rom_start	| 408D583C
    .ascii  "ecfg"	| 408D5840
    .byte   0x00, 0x23, 0x58	| 408D5844
    .byte   10	/* 408D5847 Pascal string length */
    .ascii  "Wombat 33F"	| 408D5848
    .byte   0x31, 0x39, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x5C	| 408D5852
rsrc_ecfg_35_Wombat_33F:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D5860
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D5870
    .byte   0x00, 0x00, 0x00, 0x00	| 408D5880
    FILL_408D5884
