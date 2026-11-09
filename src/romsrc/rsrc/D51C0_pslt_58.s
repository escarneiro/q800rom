/* ROM resource 'pslt' 58: map entry at 0x408D51C0, data at 0x408D51F0, 20 bytes

 PDS slot table ('pslt' 58): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_58_entry:     /* map entry */
    .long   0x28000000, 0x00000000	| 408D51C0
    .long   rsrc_pslt_63_entry-rom_start	| 408D51C8
    .long   rsrc_pslt_58-rom_start	| 408D51CC
    .ascii  "pslt"	| 408D51D0
    .byte   0x00, 0x3A, 0x58, 0x00	| 408D51D4
    FILL_408D51D8
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x03, 0xF4	| 408D51E4
rsrc_pslt_58:           /* the resource data */
    .long   0x00030000, 0x00000000, 0x000C0001, 0x000D0002	| 408D51F0
    .byte   0x00, 0x0E, 0x00, 0x03	| 408D5200
    FILL_408D5204
