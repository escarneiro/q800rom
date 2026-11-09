/* ROM resource 'pslt' 35: map entry at 0x408D53D0, data at 0x408D5400, 20 bytes

 PDS slot table ('pslt' 35): which NuBus slot number a processor-direct-slot card
 answers as, on one machine (inferred).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_pslt_35_entry:     /* map entry */
    .long   0x28000000, 0x00000000	| 408D53D0
    .long   rsrc_pslt_36_entry-rom_start	| 408D53D8
    .long   rsrc_pslt_35-rom_start	| 408D53DC
    .ascii  "pslt"	| 408D53E0
    .byte   0x00, 0x23, 0x58, 0x00	| 408D53E4
    FILL_408D53E8
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x20, 0x00, 0x00, 0x03, 0xBC	| 408D53F4
rsrc_pslt_35:           /* the resource data */
    .long   0x00030002, 0x00000000, 0x000C0001, 0x000D0002	| 408D5400
    .long   0x000E0003	| 408D5410
    FILL_408D5414
