/* ROM resource 'ecfg' 63 "WLCD 33": map entry at 0x408D54C0, data at 0x408D54F0, 36 bytes

 Ethernet configuration for WLCD 33: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_63_WLCD_33_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D54C0
    .long   rsrc_pslt_26_entry-rom_start	| 408D54C8
    .long   rsrc_ecfg_63_WLCD_33-rom_start	| 408D54CC
    .ascii  "ecfg"	| 408D54D0
    .byte   0x00, 0x3F, 0x58	| 408D54D4
    .byte   7	/* 408D54D7 Pascal string length */
    .ascii  "WLCD 33"	| 408D54D8
    FILL_408D54DF
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0xA4	| 408D54E4
rsrc_ecfg_63_WLCD_33:   /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D54F0
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D5500
    .byte   0x00, 0x00, 0x00, 0x00	| 408D5510
    FILL_408D5514
