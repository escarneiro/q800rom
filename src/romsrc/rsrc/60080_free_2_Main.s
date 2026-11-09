/* ROM resource 'free' 2 "Main": map entry at 0x40860080, data at 0x408600B0, 43688 bytes

 Free space in the ROM (a placeholder resource, unused).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).
*/

rsrc_free_2_Main_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 40860080
    .long   rsrc_iopc_0_entry-rom_start	| 40860088
    .long   rsrc_free_2_Main-rom_start	| 4086008C
    .ascii  "free"	| 40860090
    .byte   0x00, 0x02, 0x58	| 40860094
    .byte   4	/* 40860097 Pascal string length */
    .ascii  "Main"	| 40860098
    .byte   0x00, 0x00, 0x00, 0x00	| 4086009C
    .long   0x00000000, 0xC0A00000, 0x0000AAB4, 0x000001BC	| 408600A0
rsrc_free_2_Main:       /* the resource data */
    .fill   0x656, 1, 0x00
rsrc_free_2_Main_656:   /* (unused, zeros) */
    .fill   0x2926, 1, 0x00
rsrc_free_2_Main_2F7C:  /* (unused, zeros) */
    .fill   0x207F, 1, 0x00
rsrc_free_2_Main_4FFB:  /* (unused, zeros) */
    .fill   0x1330, 1, 0x00
rsrc_free_2_Main_632B:  /* (unused, zeros) */
    .fill   0x120, 1, 0x00
rsrc_free_2_Main_644B:  /* (unused, zeros) */
    .fill   0x120, 1, 0x00
rsrc_free_2_Main_656B:  /* (unused, zeros) */
    .fill   0x120, 1, 0x00
rsrc_free_2_Main_668B:  /* (unused, zeros) */
    .fill   0x120, 1, 0x00
rsrc_free_2_Main_67AB:  /* (unused, zeros) */
    .fill   0xFA5, 1, 0x00
rsrc_free_2_Main_7750:  /* (unused, zeros) */
    .fill   0x1460, 1, 0x00
rsrc_free_2_Main_8BB0:  /* (unused, zeros) */
    .fill   0x80, 1, 0x00
rsrc_free_2_Main_8C30:  /* (unused, zeros) */
    .fill   0x80, 1, 0x00
rsrc_free_2_Main_8CB0:  /* (unused, zeros) */
    .fill   0xFF, 1, 0x00
rsrc_free_2_Main_8DAF:  /* (unused, zeros) */
    .fill   0x205, 1, 0x00
rsrc_free_2_Main_8FB4:  /* (unused, zeros) */
    .fill   0x80, 1, 0x00
rsrc_free_2_Main_9034:  /* (unused, zeros) */
    .fill   0x7F, 1, 0x00
rsrc_free_2_Main_90B3:  /* (data) */
    .byte   0x00	| 40869163
rsrc_free_2_Main_90B4:  /* (unused, zeros) */
    .fill   0x7F, 1, 0x00
rsrc_free_2_Main_9133:  /* (unused, zeros) */
    .fill   0x80, 1, 0x00
rsrc_free_2_Main_91B3:  /* (unused, zeros) */
    .fill   0x4AB, 1, 0x00
rsrc_free_2_Main_965E:  /* (unused, zeros) */
    .fill   0x120, 1, 0x00
rsrc_free_2_Main_977E:  /* (unused, zeros) */
    .fill   0x120, 1, 0x00
rsrc_free_2_Main_989E:  /* (unused, zeros) */
    .fill   0x120, 1, 0x00
rsrc_free_2_Main_99BE:  /* (unused, zeros) */
    .fill   0x48, 1, 0x00
rsrc_free_2_Main_9A06:  /* (unused, zeros) */
    .fill   0xD8, 1, 0x00
rsrc_free_2_Main_9ADE:  /* (unused, zeros) */
    .fill   0xFD2, 1, 0x00
