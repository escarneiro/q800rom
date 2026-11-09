/* ROM resource 'ecfg' 51 "Wombat 40": map entry at 0x408D5770, data at 0x408D57A0, 36 bytes

 Ethernet configuration for Wombat 40: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_51_Wombat_40_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5770
    .long   rsrc_ecfg_52_WLCD_20_entry-rom_start	| 408D5778
    .long   rsrc_ecfg_51_Wombat_40-rom_start	| 408D577C
    .ascii  "ecfg"	| 408D5780
    .byte   0x00, 0x33, 0x58	| 408D5784
    .byte   9	/* 408D5787 Pascal string length */
    .ascii  "Wombat 40"	| 408D5788
    .byte   0x53, 0x41, 0x4D, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x6C	| 408D5791
rsrc_ecfg_51_Wombat_40:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D57A0
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D57B0
    .byte   0x00, 0x00, 0x00, 0x00	| 408D57C0
    FILL_408D57C4
