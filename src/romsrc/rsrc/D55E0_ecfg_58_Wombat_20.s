/* ROM resource 'ecfg' 58 "Wombat 20": map entry at 0x408D55E0, data at 0x408D5610, 36 bytes

 Ethernet configuration for Wombat 20: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_58_Wombat_20_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D55E0
    .long   rsrc_ecfg_59_Wombat_40F_entry-rom_start	| 408D55E8
    .long   rsrc_ecfg_58_Wombat_20-rom_start	| 408D55EC
    .ascii  "ecfg"	| 408D55F0
    .byte   0x00, 0x3A, 0x58	| 408D55F4
    .byte   9	/* 408D55F7 Pascal string length */
    .ascii  "Wombat 20"	| 408D55F8
    .byte   0x2C, 0x20, 0x4F, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x8C	| 408D5601
rsrc_ecfg_58_Wombat_20:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D5610
    .long   0x0000802C /* number, not a label difference (was thunk_FUN_408dd652-.) */	| 408D5620
    .long   0x00000000, 0x09010000, 0x00000000	| 408D5624
    .long   0x00000000	| 408D5630
    FILL_408D5634
