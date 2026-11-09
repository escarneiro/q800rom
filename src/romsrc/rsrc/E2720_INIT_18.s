/* ROM resource 'INIT' 18: map entry at 0x408E2720, data at 0x408E2750, 388 bytes

 The AppleTalk loader for System 6 ('INIT' 18, "INIT 18 v57.0.4", (c) Apple 1984-1992):
 loads and runs the LAP Manager installer ('lmgr' 0) from the "AppleTalk" file in the
 System Folder, or from the ROM when the file has none, with the system heap allowed to
 grow while it runs. Under System 7 and later it does nothing (AppleTalk is set up
 elsewhere). Comments inferred from the code.
*/

rsrc_INIT_18_entry:     /* map entry */
    .long   0x38000000, 0x00000000	| 408E2720
    .long   rsrc_lmgr_0_entry-rom_start	| 408E2728
    .long   rsrc_INIT_18-rom_start	| 408E272C
    .ascii  "INIT"	| 408E2730
    .byte   0x00, 0x12, 0x58, 0x00	| 408E2734
    FILL_408E2738
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x01, 0x90, 0x00, 0x00, 0x02, 0xBC	| 408E2744

/* Entry: a branch over the standard header (flags, resource type and ID, version string). */
rsrc_INIT_18:
    jbra rsrc_INIT_18_4C
    .short  0x0000, 0x0000, 0x0008, 0x3904, 0x8000, 0x0000, 0x0835	| 408E2752
    .long   0x372E302E, 0x34202000, 0x33494E49, 0x54203138	| 408E2760
    .long   0x20763537, 0x2E302E34, 0x20203B20, 0xA9204170	| 408E2770
    .long   0x706C6520, 0x436F6D70, 0x75746572, 0x2C20496E	| 408E2780
    .long   0x632E2031, 0x3938342D, 0x31393932	| 408E2790

/*
 Only for System 6 (SysVersion below 7.0). Makes the system heap the current and
 application zone, installs rsrc_INIT_18_130 as its grow-zone procedure, opens
 "AppleTalk" and runs its 'lmgr' 0 (detached, then disposed of), or the ROM's 'lmgr' 0
 if the file cannot be opened or has none. Then restores the grow-zone procedure,
 re-creates the application zone below the system heap, and disposes of its own code
 (RecoverHandle of itself).
*/
rsrc_INIT_18_4C:
    cmpib #7,SysVersion
    jbcs rsrc_INIT_18_4C_A
    rts
rsrc_INIT_18_4C_A:      /* System 6: set up the zones */
    linkw %fp,#-10
    clrl %fp@(-4)
    movel TheZone,%d0
    cmpl SysZone,%d0
    jbne rsrc_INIT_18_4C_20
    movel %d0,%fp@(-4)
rsrc_INIT_18_4C_20:     /* system heap as current and application zone, grow-zone procedure */
    moveal SysZone,%a0
    movel %a0,TheZone
    movel %a0,ApplZone
    movel %a0@,HeapEnd
    movel %a0@(16),%fp@(-8)
    pea %pc@(rsrc_INIT_18_130)
    movel %sp@+,%a0@(16)
    jbsr rsrc_INIT_18_124
    movew %d0,%fp@(-10)
    jbmi rsrc_INIT_18_4C_AA
    clrl %sp@-
    movel #1819109234,%sp@-
    clrw %sp@-
    _Get1Resource
    movel %sp@+,%d0
    jbeq rsrc_INIT_18_4C_AA
    movel %d0,%sp@-
    movel %sp@,%sp@-
    _DetachResource
    moveal %sp@,%a0
    moveal %a0@,%a1
    jsr %a1@
    moveal %sp@+,%a0
    _DisposHandle
    movew %fp@(-10),%sp@-
    _CloseResFile
rsrc_INIT_18_4C_6E:     /* restore the grow-zone procedure and the application zone */
    moveal SysZone,%a0
    movel %fp@(-8),%a0@(16)
    movel %a0@,%d0
    _StripAddress
    moveal %d0,%a1
    movel %a1@,%d1
    andil #16777215,%d1
    pea %a1@(0x0,%d1:l)
    moveal %sp@+,%a0
    _SetApplBase
    _InitApplZone
    movel ApplZone,%d0
    tstl %fp@(-4)
    jbne rsrc_INIT_18_4C_9E
    movel %d0,TheZone
rsrc_INIT_18_4C_9E:     /* dispose of this code and return */
    unlk %fp
    lea %pc@(rsrc_INIT_18),%a0
    .short  0xA128	| 408E2840 _RecoverHandle (flags 0x0100)
    _DisposHandle
    rts
rsrc_INIT_18_4C_AA:     /* 'lmgr' 0 from the ROM (CurMap 1, ROMMapInsert) and run it */
    movew CurMap,%sp@-
    movew #1,CurMap
    movew #-1,ROMMapInsert
    clrl %sp@-
    movel #1819109234,%sp@-
    clrw %sp@-
    _Get1Resource
    movel %sp@+,%d0
    movew %sp@+,CurMap
    tstl %d0
    jbeq rsrc_INIT_18_4C_6E
    moveal %d0,%a0
    moveal %a0@,%a0
    jsr %a0@
    jbra rsrc_INIT_18_4C_6E

/* OpenResFile("AppleTalk"). Out: d0 = file reference number (negative: not opened). */
rsrc_INIT_18_124:
    clrw %sp@-
    pea %pc@(PSTR_AppleTalk)
    _OpenResFile
    movew %sp@+,%d0
    rts

/*
 Grow-zone procedure while the loader runs: moves the application zone base up so the
 system heap can grow by the amount asked plus 16 KB (at most up to BufPtr - 8 KB),
 then makes the system heap current again. Returns the amount gained.
*/
rsrc_INIT_18_130:
    movel %sp@(4),%d0
    movel %a2,%sp@-
    moveal SysZone,%a1
    moveal %a1@,%a0
    moveal %a0,%a2
    addil #16384,%d0
    lea %a0@(0x0,%d0:l),%a0
    movel %d0,%d1
    moveal BufPtr,%a1
    subaw #8192,%a1
    cmpal %a1,%a0
    jbls rsrc_INIT_18_130_2C
    movel %a1,%d1
    subl %a2,%d1
    moveal %a1,%a0
rsrc_INIT_18_130_2C:    /* move the application base, re-create the zones */
    _SetApplBase
    _InitApplZone
    moveal SysZone,%a1
    movel %a1,TheZone
    movel %a1,ApplZone
    movel %a1@,HeapEnd
    moveal %sp@+,%a2
    moveal %sp@+,%a0
    movel %sp@+,%d0
    movel %d1,%sp@
    jmp %a0@
PSTR_AppleTalk:         /* the file name */
    .ascii  "\011AppleTalk"
    FILL_408E28D4
