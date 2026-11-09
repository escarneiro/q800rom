/* ROM resource 'pslt' 30: map entry at 0x408D5420, data at 0x408D5450, 20 bytes

 PDS slot table ('pslt' 30): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_30_entry:     /* map entry */
    .long   0x28000000, 0x00000000	| 408D5420
    .long   rsrc_pslt_35_entry-rom_start	| 408D5428
    .long   rsrc_pslt_30-rom_start	| 408D542C
    .ascii  "pslt"	| 408D5430
    .byte   0x00, 0x1E, 0x58, 0x00	| 408D5434
    FILL_408D5438
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x03, 0xB4	| 408D5444
rsrc_pslt_30:           /* the resource data */
    .long   0x00030000, 0x00000000, 0x000C0001, 0x000D0002	| 408D5450
    .byte   0x00, 0x0E, 0x00, 0x03	| 408D5460
    FILL_408D5464
