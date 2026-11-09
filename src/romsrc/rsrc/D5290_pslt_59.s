/* ROM resource 'pslt' 59: map entry at 0x408D5290, data at 0x408D52C0, 20 bytes

 PDS slot table ('pslt' 59): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_59_entry:     /* map entry */
    .long   0x28000000, 0x00000000	| 408D5290
    .long   rsrc_pslt_52_entry-rom_start	| 408D5298
    .long   rsrc_pslt_59-rom_start	| 408D529C
    .ascii  "pslt"	| 408D52A0
    .byte   0x00, 0x3B, 0x58, 0x00	| 408D52A4
    FILL_408D52A8
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x03, 0xDC	| 408D52B4
rsrc_pslt_59:           /* the resource data */
    .long   0x00030002, 0x00000000, 0x000C0001, 0x000D0002	| 408D52C0
    .long   0x000E0003	| 408D52D0
    FILL_408D52D4
