/* ROM resource 'ecfg' 20 "Quadra900": map entry at 0x408D5A10, data at 0x408D5A40, 36 bytes

 Ethernet configuration for Quadra900: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_20_Quadra900_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5A10
    .long   rsrc_ecfg_22_Quadra700_entry-rom_start	| 408D5A18
    .long   rsrc_ecfg_20_Quadra900-rom_start	| 408D5A1C
    .ascii  "ecfg"	| 408D5A20
    .byte   0x00, 0x14, 0x58	| 408D5A24
    .byte   9	/* 408D5A27 Pascal string length */
    .ascii  "Quadra900"	| 408D5A28
    .byte   0x2C, 0x20, 0x31, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x34	| 408D5A31
rsrc_ecfg_20_Quadra900:  /* the resource data */
    .long   0x50F0A000, 0x50F0A000, 0x50F08000, 0x00008023	| 408D5A40
    .long   0x0000802C, 0x00000000, 0x09010000, 0x00000000	| 408D5A50
    .byte   0x00, 0x00, 0x00, 0x00	| 408D5A60
    FILL_408D5A64
