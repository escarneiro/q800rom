/* ROM resource 'pslt' 51: map entry at 0x408D5330, data at 0x408D5360, 20 bytes

 PDS slot table ('pslt' 51): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_51_entry:     /* map entry */
    .long   0x28000000, 0x00000000	| 408D5330
    .long   rsrc_pslt_58_entry_408D52E0-rom_start	| 408D5338
    .long   rsrc_pslt_51-rom_start	| 408D533C
    .ascii  "pslt"	| 408D5340
    .byte   0x00, 0x33, 0x58, 0x00	| 408D5344
    FILL_408D5348
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x03, 0xCC	| 408D5354
rsrc_pslt_51:           /* the resource data */
    .long   0x00030000, 0x00000000, 0x000C0001, 0x000D0002	| 408D5360
    .long   0x000E0003	| 408D5370
    FILL_408D5374
