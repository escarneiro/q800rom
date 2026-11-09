/* ROM resource 'pslt' 52: map entry at 0x408D5250, data at 0x408D5280, 12 bytes

 PDS slot table ('pslt' 52): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_52_entry:     /* map entry */
    .long   0x28000000, 0x00000000	| 408D5250
    .long   rsrc_pslt_53_entry-rom_start	| 408D5258
    .long   rsrc_pslt_52-rom_start	| 408D525C
    .ascii  "pslt"	| 408D5260
    .byte   0x00, 0x34, 0x58, 0x00	| 408D5264
    FILL_408D5268
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x18, 0x00, 0x00, 0x03, 0xE4	| 408D5274
rsrc_pslt_52:           /* the resource data */
    .byte   0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0E, 0x00, 0x01	| 408D5280
    FILL_408D528C
