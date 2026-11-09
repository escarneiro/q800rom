/* ROM resource 'ecfg' 57 "WLCD Consumer 1": map entry at 0x408D5640, data at 0x408D5680, 36 bytes

 Ethernet configuration for WLCD Consumer 1: base addresses of the built-in Ethernet
 hardware (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet
 address PROM) and settings for that machine, read by the Ethernet driver (inferred
 from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_57_WLCD_Consumer_1_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5640
    .long   rsrc_ecfg_58_Wombat_20_entry-rom_start	| 408D5648
    .long   rsrc_ecfg_57_WLCD_Consumer_1-rom_start	| 408D564C
    .ascii  "ecfg"	| 408D5650
    .byte   0x00, 0x39, 0x58	| 408D5654
    .byte   15	/* 408D5657 Pascal string length */
    .ascii  "WLCD Consumer 1"	| 408D5658
    FILL_408D5667
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x84	| 408D5674
rsrc_ecfg_57_WLCD_Consumer_1:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D5680
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D5690
    .byte   0x00, 0x00, 0x00, 0x00	| 408D56A0
    FILL_408D56A4
