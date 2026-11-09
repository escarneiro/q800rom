/* ROM resource 'pslt' 29: map entry at 0x408D5140, data at 0x408D5170, 12 bytes

 PDS slot table ('pslt' 29): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_29_entry:     /* map entry */
    .long   0x78000000, 0x00000000	| 408D5140
    .long   rsrc_pslt_32_entry-rom_start	| 408D5148
    .long   rsrc_pslt_29-rom_start	| 408D514C
    .ascii  "pslt"	| 408D5150
    .byte   0x00, 0x1D, 0x58, 0x00	| 408D5154
    FILL_408D5158
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x04, 0x04	| 408D5164
rsrc_pslt_29:           /* the resource data */
    .byte   0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01	| 408D5170
    FILL_408D517C
