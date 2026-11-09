/* ROM resource 'pslt' 53: map entry at 0x408D5210, data at 0x408D5240, 12 bytes

 PDS slot table ('pslt' 53): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_53_entry:     /* map entry */
    .long   0x28000000, 0x00000000	| 408D5210
    .long   rsrc_pslt_58_entry-rom_start	| 408D5218
    .long   rsrc_pslt_53-rom_start	| 408D521C
    .ascii  "pslt"	| 408D5220
    .byte   0x00, 0x35, 0x58, 0x00	| 408D5224
    FILL_408D5228
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x03, 0xEC	| 408D5234
rsrc_pslt_53:           /* the resource data */
    .byte   0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01	| 408D5240
    FILL_408D524C
