/* ROM resource 'pslt' 58: map entry at 0x408D52E0, data at 0x408D5310, 20 bytes

 PDS slot table ('pslt' 58): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_58_entry_408D52E0:  /* map entry */
    .long   0x28000000, 0x00000000	| 408D52E0
    .long   rsrc_pslt_59_entry-rom_start	| 408D52E8
    .long   rsrc_pslt_58_408D5310-rom_start	| 408D52EC
    .ascii  "pslt"	| 408D52F0
    .byte   0x00, 0x3A, 0x58, 0x00	| 408D52F4
    FILL_408D52F8
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x03, 0xD4	| 408D5304
rsrc_pslt_58_408D5310:  /* (data) */
    .long   0x00030000, 0x00000000, 0x000C0001, 0x000D0002	| 408D5310
    .byte   0x00, 0x0E, 0x00, 0x03	| 408D5320
    FILL_408D5324
