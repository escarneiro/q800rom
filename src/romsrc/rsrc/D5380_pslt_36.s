/* ROM resource 'pslt' 36: map entry at 0x408D5380, data at 0x408D53B0, 20 bytes

 PDS slot table ('pslt' 36): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_36_entry:     /* map entry */
    .long   0x28000000, 0x00000000	| 408D5380
    .long   rsrc_pslt_51_entry-rom_start	| 408D5388
    .long   rsrc_pslt_36-rom_start	| 408D538C
    .ascii  "pslt"	| 408D5390
    .byte   0x00, 0x24, 0x58, 0x00	| 408D5394
    FILL_408D5398
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x03, 0xC4	| 408D53A4
rsrc_pslt_36:           /* the resource data */
    .long   0x00030000, 0x00000000, 0x000C0001, 0x000D0002	| 408D53B0
    .byte   0x00, 0x0E, 0x00, 0x03	| 408D53C0
    FILL_408D53C4
