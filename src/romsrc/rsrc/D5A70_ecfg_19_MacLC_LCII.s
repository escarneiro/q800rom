/* ROM resource 'ecfg' 19 "MacLC/LCII": map entry at 0x408D5A70, data at 0x408D5AA0, 36 bytes

 Ethernet configuration for MacLC LCII: base addresses of the built-in Ethernet hardware
 (the Ethernet controller, e.g. the SONIC at 0x50F0A000, and the Ethernet address PROM)
 and settings for that machine, read by the Ethernet driver (inferred from the values).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_ecfg_19_MacLC_LCII_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D5A70
    .long   rsrc_ecfg_20_Quadra900_entry-rom_start	| 408D5A78
    .long   rsrc_ecfg_19_MacLC_LCII-rom_start	| 408D5A7C
    .ascii  "ecfg"	| 408D5A80
    .byte   0x00, 0x13, 0x58	| 408D5A84
    .byte   10	/* 408D5A87 Pascal string length */
    .ascii  "MacLC/LCII"	| 408D5A88
    .byte   0x20, 0x43, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x30, 0x00, 0x00, 0x03, 0x2C	| 408D5A92
rsrc_ecfg_19_MacLC_LCII:  /* the resource data */
    .short  0x00E0	| 408D5AA0
    .long   0x0000FE00 /* number, not an address (F1) */	| 408D5AA2
    .long   0x0000FE40 /* number, not an address (F1) */	| 408D5AA6
    .short  0x0000, 0x0000	| 408D5AAA
    .long   0x00030000 /* number, not an address (F1) */	| 408D5AAE
    .long   0x00090000 /* number, not an address (F1) */	| 408D5AB2
    .long   0x00000E00 /* number, not an address (F1) */	| 408D5AB6
    .short  0x0000, 0x0000, 0x0000	| 408D5ABA
    .short  0x0000	| 408D5AC0
    .byte   0x00, 0x00	| 408D5AC2
    FILL_408D5AC4
