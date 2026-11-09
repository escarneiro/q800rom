/* ROM resource 'ecfg' 52 "WLCD 20": map entry at 0x408D5710, data at 0x408D5740, 36 bytes

 Ethernet configuration for WLCD 20: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_52_WLCD_20_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5710
    .long   rsrc_ecfg_53_WLCD_25_entry-rom_start	| 408D5718
    .long   rsrc_ecfg_52_WLCD_20-rom_start	| 408D571C
    .ascii  "ecfg"	| 408D5720
    .byte   0x00, 0x34, 0x58	| 408D5724
    .byte   7	/* 408D5727 Pascal string length */
    .ascii  "WLCD 20"	| 408D5728
    FILL_408D572F
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x74	| 408D5734
rsrc_ecfg_52_WLCD_20:   /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D5740
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D5750
    .long   0x00000000	| 408D5760
    FILL_408D5764
