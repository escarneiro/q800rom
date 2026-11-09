/* ROM resource 'pslt' 63: map entry at 0x408D5180, data at 0x408D51B0, 12 bytes

 PDS slot table ('pslt' 63): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_63_entry:     /* map entry */
    .long   0x28000000, 0x00000000	| 408D5180
    .long   rsrc_pslt_29_entry-rom_start	| 408D5188
    .long   rsrc_pslt_63-rom_start	| 408D518C
    .ascii  "pslt"	| 408D5190
    .byte   0x00, 0x3F, 0x58, 0x00	| 408D5194
    FILL_408D5198
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x03, 0xFC	| 408D51A4
rsrc_pslt_63:           /* the resource data */
    .byte   0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01	| 408D51B0
    FILL_408D51BC
