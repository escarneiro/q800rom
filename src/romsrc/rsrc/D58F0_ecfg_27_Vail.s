/* ROM resource 'ecfg' 27 "Vail": map entry at 0x408D58F0, data at 0x408D5920, 36 bytes

 Ethernet configuration for Vail: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_27_Vail_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D58F0
    .long   rsrc_ecfg_30_Wombat_25_entry-rom_start	| 408D58F8
    .long   rsrc_ecfg_27_Vail-rom_start	| 408D58FC
    .ascii  "ecfg"	| 408D5900
    .byte   0x00, 0x1B, 0x58	| 408D5904
    .byte   4	/* 408D5907 Pascal string length */
    .ascii  "Vail"	| 408D5908
    FILL_408D590C
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x4C	| 408D5914
rsrc_ecfg_27_Vail:      /* the resource data */
    .long   0x00E00000, 0xFE000000, 0xFE400000, 0x00001003	| 408D5920
    .long   0x00001009, 0x00000000, 0x0E010000, 0x00000000	| 408D5930
    .long   0x00000000	| 408D5940
    FILL_408D5944
