/* ROM resource 'ecfg' 53 "WLCD 25": map entry at 0x408D56B0, data at 0x408D56E0, 36 bytes

 Ethernet configuration for WLCD 25: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_53_WLCD_25_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D56B0
    .long   rsrc_ecfg_57_WLCD_Consumer_1_entry-rom_start	| 408D56B8
    .long   rsrc_ecfg_53_WLCD_25-rom_start	| 408D56BC
    .ascii  "ecfg"	| 408D56C0
    .byte   0x00, 0x35, 0x58	| 408D56C4
    .byte   7	/* 408D56C7 Pascal string length */
    .ascii  "WLCD 25"	| 408D56C8
    FILL_408D56CF
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x7C	| 408D56D4
rsrc_ecfg_53_WLCD_25:   /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D56E0
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D56F0
    .long   0x00000000	| 408D5700
    FILL_408D5704
