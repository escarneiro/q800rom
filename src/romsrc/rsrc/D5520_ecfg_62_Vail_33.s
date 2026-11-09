/* ROM resource 'ecfg' 62 "Vail 33": map entry at 0x408D5520, data at 0x408D5550, 36 bytes

 Ethernet configuration for Vail 33: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_62_Vail_33_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5520
    .long   rsrc_ecfg_63_WLCD_33_entry-rom_start	| 408D5528
    .long   rsrc_ecfg_62_Vail_33-rom_start	| 408D552C
    .ascii  "ecfg"	| 408D5530
    .byte   0x00, 0x3E, 0x58	| 408D5534
    .byte   7	/* 408D5537 Pascal string length */
    .ascii  "Vail 33"	| 408D5538
    FILL_408D553F
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x9C	| 408D5544
rsrc_ecfg_62_Vail_33:   /* the resource data */
    .short  0x00E0	| 408D5550
    .long   0x0000FE00 /* number, not a label difference (was rsrc_DRVR_9__MPP_CC2-.) */	| 408D5552
    .short  0x0000, 0xFE40, 0x0000, 0x0000, 0x1003	| 408D5556
    .long   0x00001009, 0x00000000, 0x0E010000, 0x00000000	| 408D5560
    .byte   0x00, 0x00, 0x00, 0x00	| 408D5570
    FILL_408D5574
