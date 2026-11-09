/* ROM resource 'ecfg' 59 "Wombat 40F": map entry at 0x408D5580, data at 0x408D55B0, 36 bytes

 Ethernet configuration for Wombat 40F: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_59_Wombat_40F_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5580
    .long   rsrc_ecfg_62_Vail_33_entry-rom_start	| 408D5588
    .long   rsrc_ecfg_59_Wombat_40F-rom_start	| 408D558C
    .ascii  "ecfg"	| 408D5590
    .byte   0x00, 0x3B, 0x58	| 408D5594
    .byte   10	/* 408D5597 Pascal string length */
    .ascii  "Wombat 40F"	| 408D5598
    .byte   0x52, 0x4C, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x94	| 408D55A2
rsrc_ecfg_59_Wombat_40F:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D55B0
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D55C0
    .long   0x00000000	| 408D55D0
    FILL_408D55D4
