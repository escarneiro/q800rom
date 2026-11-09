/*
 quickdraw/colormgr.s - Color Manager
 From MAKEGRAYITAB (0x4083C144). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* MAKEGRAYITAB: table. */
trap_MAKEGRAYITAB:
MAKEGRAYITAB:
    moveq #-1,%d0
    moveq #63,%d1
MAKEGRAYITAB_4:         /* a 256-entry luminance-to-index table on the stack, all empty (-1) */
    movel %d0,%sp@-
    movel %d0,%sp@-
    dbf %d1,MAKEGRAYITAB_4
    clrw %sp@(510)
    movew #255,%sp@
    moveal %fp@(14),%a0
    moveal %a0@,%a0
    movew %a0@(6),%d0
    moveq #0,%d2
MAKEGRAYITAB_20:        /* each usable color table entry (not reserved, bit 6) claims the slot of its gray level (red byte) */
    movew %d0,%d1
    btst #6,%a0@(0x8,%d0:w:8)
    jbne MAKEGRAYITAB_32
    moveb %a0@(0xa,%d0:w:8),%d2
    movew %d1,%sp@(0x0,%d2:w:2)
MAKEGRAYITAB_32:        /* next entry */
    dbf %d0,MAKEGRAYITAB_20
    moveal %sp,%a1
    lea %a1@(512),%a1
MAKEGRAYITAB_3C:        /* fill the empty slots from their neighbours, upwards then downwards, until no change */
    moveq #0,%d1
    lea %sp@(2),%a0
MAKEGRAYITAB_42:        /* upwards: an empty slot takes the one below */
    cmpal %a0,%a1
    jble MAKEGRAYITAB_56
    tstw %a0@+
    jbpl MAKEGRAYITAB_42
    movew %a0@(-4),%a0@(-2)
    addqw #2,%a0
    st %d1
    jbra MAKEGRAYITAB_42
MAKEGRAYITAB_56:        /* downwards */
    subqw #2,%a0
MAKEGRAYITAB_58:        /* an empty slot takes the one above */
    cmpal %a0,%sp
    jbge MAKEGRAYITAB_6A
    tstw %a0@-
    jbpl MAKEGRAYITAB_58
    movew %a0@(2),%a0@
    subqw #2,%a0
    st %d1
    jbra MAKEGRAYITAB_58
MAKEGRAYITAB_6A:        /* repeat while something changed; then the inverse table header (seed, resolution) and the gray-level lookup */
    tstw %d1
    jbne MAKEGRAYITAB_3C
    moveal %fp@(10),%a1
    moveal %a1@,%a1
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveal %fp@(0xe,%za0)@(0),%a2	| 4083C1B8
    movel %a2@,%a1@
    movew %fp@(8),%a1@(4)
    addal %fp@(-20),%a1
    bset #15,%a1@(2)
    movew #255,%d0
    lea %a1@(262),%a3
MAKEGRAYITAB_94:        /* per gray level: its index and its luminance */
    moveb %sp@(0x1,%d0:w:2),%d1
    moveb %d1,%a1@(0x6,%d0:w)
    moveb %a2@(0xa,%d1:w:8),%a3@(0x0,%d0:w)
    dbf %d0,MAKEGRAYITAB_94
    lea %sp@(512),%sp
    moveal %fp@(0xa,%za0)@(0),%a0	| 4083C1EE
    moveq #1,%d0
    movew %a0@(4),%d2
    lsll %d2,%d0
    subqw #1,%d0
    lea %a0@(6),%a0
    lea %a1@(6),%a1
    movew #512,%d4
    lsrw %d2,%d4
    movew #2304,%d5
    lsrw %d2,%d5
    subiw #512,%d5
    movew #1280,%d6
    lsrw %d2,%d6
    subiw #2304,%d6
    subal %a2,%a2
    movew %d0,%d1
MAKEGRAYITAB_E0:        /* fill the inverse table: for each red */
    movew %d0,%d2
MAKEGRAYITAB_E2:        /* for each green */
    movew %d0,%d3
MAKEGRAYITAB_E4:        /* for each blue: the index of the gray nearest the color's luminance */
    movew %a2,%d7
    lsrw #4,%d7
    moveb %a1@(0x0,%d7:w),%a0@+
    addaw %d4,%a2
    dbf %d3,MAKEGRAYITAB_E4
    addaw %d5,%a2
    dbf %d2,MAKEGRAYITAB_E2
    addaw %d6,%a2
    dbf %d1,MAKEGRAYITAB_E0
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4083C244

/* ITABMATCH: table. */
trap_ITABMATCH:
ITABMATCH:
    linkw %fp,#-10
    movel %a2,%sp@-
    clrb %fp@(16)
    moveal @(TheGDevice,%za0)@(0),%a2	| 4083C25A
    moveal %a2@(0x16,%za0)@(0x0),%a1
    moveal %a1@(42),%a0
    movel %a0@(0,%za0)@(0),%d1	| 4083C26A
    movel %a2@(6,%za0)@(0),%d0
    cmpl @(0x0,%d0:l),%d1
    jbeq ITABMATCH_46
    movel %a0,%sp@-
    movel %a2@(6),%sp@-
    movew %a2@(10),%sp@-
    jsr @(0x16e4,%za0)@(0)	| 4083C284
    moveal @(TheGDevice,%za0)@(0),%a2
    movel %a2@(6,%za0)@(0),%d0
ITABMATCH_46:           /* the inverse table's resolution and the extra table after it; if that table is flagged (+2 negative): the index by luminance, done */
    moveal %d0,%a0
    moveq #1,%d0
    movew %a0@(4),%d2
    lsll %d2,%d0
    lsll %d2,%d0
    lsll %d2,%d0
    lea %a0@(0x6,%d0:l),%a1
    movel %a1,%fp@(-10)
    tstw %a1@(2)
    jbpl ITABMATCH_90
    moveal %fp@(12),%a0
    lea %a0@,%a0
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d2
    movew %a0@+,%d0
    movew %a0@+,%d1
    movew %a0@,%d2
    moveal %d1,%a0
    addl %d0,%d1
    lsrl #1,%d1
    addl %d2,%d1
    lsrl #1,%d1
    addl %d0,%d1
    lsrl #1,%d1
    addl %a0,%d1
    lsrl #1,%d1
    lsrl #8,%d1
    moveb %a1@(0x6,%d1:w),%d1
    jbra ITABMATCH_130
ITABMATCH_90:           /* the index from the high bits of R, G, B; an entry that links to itself in the extra table: done; else walk its chain */
    movew %a0@(4),%d2
    moveal %fp@(12),%a1
    bfextu %a1@,0,%d2,%d0
    lsll %d2,%d0
    bfextu %a1@(2),0,%d2,%d1
    orl %d1,%d0
    lsll %d2,%d0
    bfextu %a1@(4),0,%d2,%d1
    orl %d1,%d0
    moveb %a0@(0x6,%d0:w),%d1
    moveal %fp@(-10),%a1
    cmpb %a1@(0x6,%d1:w),%d1
    jbeq ITABMATCH_130
    moveal %fp@(12),%a0
    moveal @(TheGDevice,%za0)@(0),%a2	| 4083C312
    moveal %a2@(0x16,%za0)@(0x0),%a2
    moveal %a2@(0x2a,%za0)@(0),%a2
    movew %d1,%fp@(-2)
    movew %d1,%fp@(-6)
    movew #32767,%fp@(-4)
ITABMATCH_E2:           /* walk the chain of colors that share this cell: distance to each (largest component difference) */
    movew %a2@(0xa,%d1:w:8),%d0
    subw %a0@,%d0
    jbpl ITABMATCH_EC
    negw %d0
ITABMATCH_EC:           /* green */
    movew %a2@(0xc,%d1:w:8),%d2
    subw %a0@(2),%d2
    jbpl ITABMATCH_F8
    negw %d2
ITABMATCH_F8:           /* keep the larger */
    cmpw %d2,%d0
    jbge ITABMATCH_FE
    movew %d2,%d0
ITABMATCH_FE:           /* blue */
    movew %a2@(0xe,%d1:w:8),%d2
    subw %a0@(4),%d2
    jbpl ITABMATCH_10A
    negw %d2
ITABMATCH_10A:          /* keep the larger */
    cmpw %d2,%d0
    jbge ITABMATCH_110
    movew %d2,%d0
ITABMATCH_110:          /* exact: take it; else remember the closest so far */
    tstw %d0
    jbeq ITABMATCH_130
    cmpw %fp@(-4),%d0
    jbge ITABMATCH_122
    movew %d0,%fp@(-4)
    movew %d1,%fp@(-2)
ITABMATCH_122:          /* next color in the chain; back at the start: the closest */
    moveb %a1@(0x6,%d1:w),%d1
    cmpw %fp@(-6),%d1
    jbne ITABMATCH_E2
    movew %fp@(-2),%d1
ITABMATCH_130:          /* return the index, true */
    moveal %fp@(8),%a0
    extl %d1
    movel %d1,%a0@
    moveb #1,%fp@(16)
    moveal %sp@+,%a2
    unlk %fp
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083C396

/* COLORTHING2INDEX: ColorThing2Index(colorSpec): the device index for a palette color or an RGB (Color2Index); QDErr set on failure */
trap_COLORTHING2INDEX:
COLORTHING2INDEX:
    linkw %fp,#-4
    clrl %sp@-
    moveal %fp@(8),%a0
    movew %a0@+,%sp@-
    movel %a0,%fp@(8)
    moveq #0,%d0
    jsr @(0x1888,%za0)@(0x0)	| 4083C3B2
    movel %sp@+,%fp@(12)
    movew QDErr,%d0
    jbne COLOR2INDEX_4
    unlk %fp
    rtd #4

/* COLOR2INDEX: _Color2Index. */
trap_Color2Index:
COLOR2INDEX:
    linkw %fp,#-4
COLOR2INDEX_4:          /* the device's search procs (gdSearchProc, +12) first */
    movel %a2,%sp@-
    moveal @(TheGDevice,%za0)@(0),%a2	| 4083C3CE
    movel %a2@(12),%d0
COLOR2INDEX_10:         /* per search proc: call it, locked; true: found */
    jbeq COLOR2INDEX_48
    moveal %d0,%a2
    moveal %d0,%a0
    _HLock
    subqw #2,%sp
    movel %fp@(8),%sp@-
    pea %fp@(-4)
    moveal %a2@,%a0
    moveal %a0@(4),%a0
    jsr %a0@
    moveal %a2,%a0
    _HUnlock
    tstb %sp@+
    jbne COLOR2INDEX_38
    moveal %a2@,%a0
    movel %a0@,%d0
    jbra COLOR2INDEX_10
COLOR2INDEX_38:         /* return the index */
    movel %fp@(-4),%d0
    movel %d0,%fp@(12)
    moveal %sp@+,%a2
    unlk %fp
    rtd #4
COLOR2INDEX_48:         /* no proc answered: indexed devices: ITABMATCH through the inverse table */
    moveal @(TheGDevice,%za0)@(0),%a0	| 4083C410
    cmpiw #2,%a0@(4)
    jbeq COLOR2INDEX_6A
    clrb %sp@-
    movel %fp@(8),%sp@-
    pea %fp@(-4)
    jsr @(0x1c44,%za0)@(0)	| 4083C428
    tstb %sp@+
    jbra COLOR2INDEX_94
COLOR2INDEX_6A:         /* direct devices: the pixel value built from the high bits of R, G, B (component size) */
    moveal %a0@(0x16,%za0)@(0x0),%a1	| 4083C432
    movew %a1@(36),%d1
    moveal %fp@(8),%a0
    moveq #0,%d0
    moveb %a0@,%d0
    lsll %d1,%d0
    moveb %a0@(2),%d0
    lsll %d1,%d0
    moveb %a0@(4),%d0
    negw %d1
    addqw #8,%d1
    jble COLOR2INDEX_90
    lsrl %d1,%d0
COLOR2INDEX_90:         /* the value */
    movel %d0,%fp@(-4)
COLOR2INDEX_94:         /* return */
    jbra COLOR2INDEX_38
    .short  0x0000	| 4083C45E

/* INDEX2COLOR: _Index2Color. */
trap_Index2Color:
INDEX2COLOR:
    movel %sp@(8),%d0
    moveal %sp@(4),%a0
    moveal @(TheGDevice,%za0)@(0),%a1	| 4083C468
    moveal %a1@(0x16,%za0)@(0x0),%a1
    cmpiw #16,%a1@(30)
    jbeq INDEX2COLOR_40
    moveal %a1@(0x2a,%za0)@(0),%a1	| 4083C47C
    movew %a1@(6),%d1
    cmpw %d1,%d0
    jbgt INDEX2COLOR_38
    movew %a1@(0xa,%d0:l:8),%a0@
    movel %a1@(0xc,%d0:l:8),%a0@(2)
INDEX2COLOR_34:         /* return */
    rtd #8
INDEX2COLOR_38:         /* index beyond the table: cRangeErr (-153) */
    movew #-153,QDErr
    jbra INDEX2COLOR_34
INDEX2COLOR_40:         /* direct device: expand the pixel's components to 16 bits */
    moveq #8,%d1
    subw %a1@(36),%d1
    jbeq INDEX2COLOR_7E
    lsll %d1,%d0
    movew %a1@(36),%d1
    moveb %d0,%d2
    lslw %d1,%d2
    moveb %d0,%d2
    lsrw %d1,%d2
    moveb %d2,%a0@(4)
    moveb %d2,%a0@(5)
    movew %d0,%d2
    lsrl %d1,%d0
    moveb %d0,%d2
    lsrw %d1,%d2
    moveb %d2,%a0@(2)
    moveb %d2,%a0@(3)
    movew %d0,%d2
    lsrl %d1,%d0
    moveb %d0,%d2
    lsrw %d1,%d2
    moveb %d2,%a0@
    moveb %d2,%a0@(1)
    jbra INDEX2COLOR_34
INDEX2COLOR_7E:         /* 8-bit components: duplicate each byte */
    moveb %d0,%a0@(4)
    moveb %d0,%a0@(5)
    lsrw #8,%d0
    moveb %d0,%a0@(2)
    moveb %d0,%a0@(3)
    swap %d0
    moveb %d0,%a0@
    moveb %d0,%a0@(1)
    jbra INDEX2COLOR_34
    .short  0x0000, 0x0000, 0x0000	| 4083C4FA

/* INVERTCOLOR: _InvertColor. */
trap_InvertColor:
INVERTCOLOR:
    movel %a2,%sp@-
    moveal @(TheGDevice,%za0)@(0),%a2	| 4083C502
    movel %a2@(16),%d0
INVERTCOLOR_C:          /* each complement proc of the chain: lock its node, call it, unlock; true ends the search */
    jbeq INVERTCOLOR_36
    moveal %d0,%a2
    moveal %d0,%a0
    _HLock
    clrb %sp@-
    movel %sp@(8),%sp@-
    moveal %a0@,%a0
    moveal %a0@(4),%a0
    jsr %a0@
    moveal %a2,%a0
    _HUnlock
    tstb %sp@+
    jbne INVERTCOLOR_30
    moveal %a2@,%a0
    movel %a0@,%d0
    jbra INVERTCOLOR_C
INVERTCOLOR_30:         /* return */
    moveal %sp@+,%a2
    rtd #4
INVERTCOLOR_36:         /* no complement proc answered: complement each component */
    moveal %sp@(8),%a0
    notw %a0@+
    notw %a0@+
    notw %a0@
    jbra INVERTCOLOR_30
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083C542

/* RGBFORECOLOR: _RGBForeColor. */
trap_RGBForeColor:
RGBFORECOLOR:
    moveq #80,%d0
    moveq #36,%d1
RGBFORECOLOR_4:         /* d0 = the old color's offset (fgColor 80 / bkColor 84), d1 = the RGB's (36 / 42); old port: RGB2OLD */
    moveal %sp@(4),%a1
    moveal %a5@,%a0
    moveal %a0@,%a0
    pea %a0@(0x0,%d0:w)
    tstw %a0@(6)
    jbmi RGBFORECOLOR_1C
    jsr %pc@(RGB2OLD)
    jbra RGBFORECOLOR_62
RGBFORECOLOR_1C:        /* color port: clear the grafVars "palette color" flag of this color */
    movel %a0@(8),%d2
    jbeq RGBFORECOLOR_42
    moveal %d2,%a1
    moveal %a1@,%a1
    movew %a1@(24),%d2
    cmpiw #80,%d0
    jbne RGBFORECOLOR_36
    bclr #0,%d2
    jbra RGBFORECOLOR_3A
RGBFORECOLOR_36:        /* background: bit 1 */
    bclr #1,%d2
RGBFORECOLOR_3A:        /* store the flags */
    movew %d2,%a1@(24)
    moveal %sp@(8),%a1
RGBFORECOLOR_42:        /* store the RGB in the port; its index (Color2Index) */
    movel %a1@,%a0@(0x0,%d1:w)
    movew %a1@(4),%a0@(0x4,%d1:w)
    movel %a1@(2),%sp@-
    movew %a1@,%sp@-
    subqw #4,%sp
    pea %sp@(4)
    jsr @(0x16cc,%za0)@(0)	| 4083C5A8
    movel %sp@+,%d0
    addqw #6,%sp
RGBFORECOLOR_62:        /* store the index (or old color) in fgColor/bkColor */
    moveal %sp@+,%a0
    movel %d0,%a0@
    rtd #4

/* RGB2OLD: RGB2Old(rgb): the old-style color (black, white, red, green, blue, cyan, magenta, yellow) nearest to an RGB, from the high bits of R, G, B */
RGB2OLD:
    moveq #0,%d1
    movew %a1@+,%d1
    addl %d1,%d1
    movew %a1@+,%d1
    addl %d1,%d1
    movew %a1@+,%d1
    addl %d1,%d1
    swap %d1
    lea %pc@(RGB2OLD_1C),%a0
    moveq #0,%d0
    movew %a0@(0x0,%d1:w:2),%d0
    rts
RGB2OLD_1C:             /* the 8 old colors by their R, G, B high bits (data) */
    .short  0x0021, 0x0199, 0x0155, 0x0111, 0x00CD	| 4083C5D6
    .short  0x0089, 0x0045, 0x001E	| 4083C5E0

/* RGBBACKCOLOR: _RGBBackColor. */
trap_RGBBackColor:
RGBBACKCOLOR:
    moveq #84,%d0
    moveq #42,%d1
    jbra RGBFORECOLOR_4
    .short  0x0000	| 4083C5EE

/* GETFORECOLOR: _GetForeColor. */
trap_GetForeColor:
GETFORECOLOR:
    moveq #80,%d0
    moveq #36,%d1
GETFORECOLOR_4:         /* color port: the RGB from the port */
    moveal %sp@(4),%a1
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(6)
    jbpl GETFORECOLOR_22
    movel %a0@(0x0,%d1:w),%a1@
    movew %a0@(0x4,%d1:w),%a1@(4)
GETFORECOLOR_1C:        /* return */
    moveal %sp@+,%a0
    addqw #4,%sp
    jmp %a0@
GETFORECOLOR_22:        /* old port: the old color's RGB from QDColors (0x8B0) */
    movel %a0@(0x0,%d0:w),%d0
    lsrw #1,%d0
    jbcs GETFORECOLOR_2E
    oriw #224,%d0
GETFORECOLOR_2E:        /* the color number */
    lsrw #5,%d0
    andiw #7,%d0
    moveal QDColors,%a0
    lea %a0@(0x2,%d0:w:8),%a0
    movel %a0@+,%a1@+
    movew %a0@+,%a1@+
    jbra GETFORECOLOR_1C

/* GETBACKCOLOR: _GetBackColor. */
trap_GetBackColor:
GETBACKCOLOR:
    moveq #84,%d0
    moveq #42,%d1
    jbra GETFORECOLOR_4
    .long   0x00000000, 0x00000000	| 4083C638

/* REALCOLOR: _RealColor. */
trap_RealColor:
REALCOLOR:
    linkw %fp,#-6
    clrb %fp@(12)
    subqw #4,%sp
    movel %fp@(8),%sp@-
    jsr @(0x16cc,%za0)@(0)	| 4083C64E
    pea %fp@(-6)
    jsr @(0x16d0,%za0)@(0)	| 4083C658
    moveal @(TheGDevice,%za0)@(0),%a0
    moveal %a0@(6,%za0)@(0),%a0
    movew %a0@(4),%d2
    bfextu %fp@(8,%za0)@(0),0,%d2,%d0	| 4083C66E
    bfextu %fp@(-6),0,%d2,%d1
    cmpw %d0,%d1
    jbne REALCOLOR_6E
    bfextu %fp@(8,%za0)@(2),0,%d2,%d0	| 4083C680
    bfextu %fp@(-4),0,%d2,%d1
    cmpw %d0,%d1
    jbne REALCOLOR_6E
    bfextu %fp@(8,%za0)@(4),0,%d2,%d0	| 4083C694
    bfextu %fp@(-2),0,%d2,%d1
    cmpw %d0,%d1
    jbne REALCOLOR_6E
    moveb #1,%fp@(12)
REALCOLOR_6E:           /* return */
    unlk %fp
    rtd #4
    .long   0x00000000, 0x00000000, 0x00000000	| 4083C6B4

/* SETENTRIES: _SetEntries. */
trap_SetEntries:
SETENTRIES:
    linkw %fp,#-40
    moveml %d3/%a2,%sp@-
    moveal @(TheGDevice,%za0)@(0),%a0	| 4083C6C8
    movew %a0@(2),%d2
    cmpiw #0,%a0@(4)
    jbne SETENTRIES_12C
    moveal %a0@(0x16,%za0)@(0x0),%a0	| 4083C6DC
    moveal %a0@(0x2a,%za0)@(0),%a2
    bset #13,%a2@(4)
    jbne SETENTRIES_68
    movew %fp@(12),%d1
    movew %fp@(14),%d0
    jbmi SETENTRIES_70
    addw %d1,%d0
    cmpw %a2@(6),%d0
    jbgt SETENTRIES_60
SETENTRIES_42:          /* sequential entries (start >= 0): any of them protected, or reserved by another client? error */
    btst #7,%a2@(0x8,%d0:w:8)
    jbne SETENTRIES_68
    btst #6,%a2@(0x8,%d0:w:8)
    jbeq SETENTRIES_58
    cmpb %a2@(0x9,%d0:w:8),%d2
    jbne SETENTRIES_68
SETENTRIES_58:          /* next entry */
    subqw #1,%d0
    dbf %d1,SETENTRIES_42
    jbra SETENTRIES_9C
SETENTRIES_60:          /* index out of range: cRangeErr (-153) */
    movew #-153,%d0
    jbra SETENTRIES_130
SETENTRIES_68:          /* protected or reserved: cProtectErr (-154) */
    movew #-154,%d0
    jbra SETENTRIES_130
SETENTRIES_70:          /* indexed entries (start = -1): check each index */
    moveal %fp@(8),%a0
SETENTRIES_74:          /* in range? protected? reserved by another client? */
    movew %a0@,%d0
    andiw #255,%d0
    cmpw %a2@(6),%d0
    jbgt SETENTRIES_60
    btst #7,%a2@(0x8,%d0:w:8)
    jbne SETENTRIES_68
    btst #6,%a2@(0x8,%d0:w:8)
    jbeq SETENTRIES_96
    cmpb %a2@(0x9,%d0:w:8),%d2
    jbne SETENTRIES_68
SETENTRIES_96:          /* next */
    addqw #8,%a0
    dbf %d1,SETENTRIES_74
SETENTRIES_9C:          /* the driver's SetEntries Control call (csCode 3), then the device's color table */
    movew %fp@(14),%fp@(-36)
    movew %fp@(12),%fp@(-34)
    movel %fp@(8),%fp@(-40)
    clrl %fp@(-20)
    clrw %fp@(-10)
    moveal @(TheGDevice,%za0)@(0),%a1	| 4083C776
    movew %a1@,%fp@(-8)
    movew #3,%fp@(-6)
    lea %fp@(-40),%a1
    movel %a1,%fp@(-4)
    lea %fp@(-32),%a0
    .short  0xA204	| 4083C792 _Control (flags 0x0200)
    tstw %d0
    jbne SETENTRIES_130
    moveal %fp@(8),%a0
    movew %fp@(12),%d0
    movew %fp@(14),%d1
    jbmi SETENTRIES_FA
    lea %a2@(0x8,%d1:w:8),%a1
SETENTRIES_EA:          /* copy the entries for the driver call */
    addqw #1,%a1
    moveb %d2,%a1@+
    movel %a0@+,%d3
    movew %d3,%a1@+
    movel %a0@+,%a1@+
    dbf %d0,SETENTRIES_EA
    jbra SETENTRIES_10C
SETENTRIES_FA:          /* copy them into the color table, with the client ID */
    movew %a0@+,%d3
    moveb %d2,%a2@(0x9,%d3:w:8)
    movew %a0@+,%a2@(0xa,%d3:w:8)
    movel %a0@+,%a2@(0xc,%d3:w:8)
    dbf %d0,SETENTRIES_FA
SETENTRIES_10C:         /* new seed; the cached inverse tables are stale (LastSPExtra = -1) */
    clrl %sp@-
    jsr @(0x16a0,%za0)@(0)	| 4083C7CE
    movel %sp@+,%a2@
    bclr #13,%a2@(4)
    movel MinusOne,LastSPExtra
SETENTRIES_122:         /* restore registers, return */
    moveml %sp@+,%d3/%a2
    unlk %fp
    rtd #8
SETENTRIES_12C:         /* not a CLUT device: cDevErr (-155) */
    movew #-155,%d0
SETENTRIES_130:         /* QDErr = the error */
    movew %d0,QDErr
    jbra SETENTRIES_122
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083C7F6

/* RESTOREENTRIES: _RestoreEntries. */
trap_RestoreEntries:
RESTOREENTRIES:
    linkw %fp,#-40
    moveml %d3/%a2-%a3,%sp@-
    clrw QDErr
    moveal %fp@(0x10,%za0)@(0x0),%a2	| 4083C80C
    moveal %fp@(8),%a1
    movew %a1@,%d2
    moveal @(TheGDevice,%za0)@(0),%a0	| 4083C818
    cmpiw #0,%a0@(4)
    jbne RESTOREENTRIES_100
    moveal %a0@(0x16,%za0)@(0x0),%a0	| 4083C828
    moveal %a0@(0x2a,%za0)@(0),%a0
    moveal %fp@(0xc,%za0)@(0),%a3
    cmpal %a0,%a3
    jbeq RESTOREENTRIES_46
    tstl %fp@(12)
    jbne RESTOREENTRIES_BE
    moveal %a0,%a3
RESTOREENTRIES_46:      /* save the table's value fields on the stack */
    moveq #0,%d1
    movew %d2,%d1
    addqw #1,%d1
    aslw #1,%d1
    subaw %d1,%sp
    movew %d2,%d0
RESTOREENTRIES_52:      /* save */
    movew %a2@(0x8,%d0:w:8),%sp@(0x0,%d0:w:2)
    dbf %d0,RESTOREENTRIES_52
    movew %d2,%d0
RESTOREENTRIES_5E:      /* set the target indexes from the request; out of range: error; then the driver call (csCode 3) */
    movew %a1@(0x2,%d0:w:2),%d3
    cmpw %a3@(6),%d3
    jbgt RESTOREENTRIES_108
    movew %d3,%a2@(0x8,%d0:w:8)
    dbf %d0,RESTOREENTRIES_5E
    clrl %fp@(-20)
    clrw %fp@(-10)
    moveal @(TheGDevice,%za0)@(0),%a0	| 4083C87A
    movew %a0@,%fp@(-8)
    movew #3,%fp@(-6)
    lea %fp@(-40),%a0
    movel %a0,%fp@(-4)
    lea %a2@(8),%a0
    movel %a0,%fp@(-40)
    movew #-1,%fp@(-36)
    movew %d2,%fp@(-34)
    lea %fp@(-32),%a0
    .short  0xA204	| 4083C8A8 _Control (flags 0x0200)
    jbeq RESTOREENTRIES_B0
    movew %d0,QDErr
RESTOREENTRIES_B0:      /* restore the value fields */
    movew %d2,%d0
RESTOREENTRIES_B2:      /* restore */
    movew %sp@(0x0,%d0:w:2),%a2@(0x8,%d0:w:8)
    dbf %d0,RESTOREENTRIES_B2
    addaw %d1,%sp
RESTOREENTRIES_BE:      /* copy the given entries into the device's table at their indexes */
    movew %a1@(0x2,%d2:w:2),%d0
    cmpiw #-1,%d0
    jbeq RESTOREENTRIES_DA
    cmpw %a3@(6),%d0
    jbgt RESTOREENTRIES_F8
    movel %a2@(0x8,%d2:w:8),%a3@(0x8,%d0:w:8)
    movel %a2@(0xc,%d2:w:8),%a3@(0xc,%d0:w:8)
RESTOREENTRIES_DA:      /* count down (loop) */
    dbf %d2,RESTOREENTRIES_BE
RESTOREENTRIES_DE:      /* no destination given: tell the Palette Manager (selector 18) */
    tstl %fp@(12)
    jbne RESTOREENTRIES_EE
    movel %fp@(8),%sp@-
    movew #18,%d0
    _PaletteDispatch
RESTOREENTRIES_EE:      /* restore registers, return */
    moveml %sp@+,%d3/%a2-%a3
    unlk %fp
    rtd #12
RESTOREENTRIES_F8:      /* index out of range */
    movew #-153,QDErr
    jbra RESTOREENTRIES_DA
RESTOREENTRIES_100:     /* not a CLUT device */
    movew #-155,QDErr
    jbra RESTOREENTRIES_EE
RESTOREENTRIES_108:     /* out of range: restore the value fields and stop */
    movew #-153,QDErr
    movew %d2,%d0
RESTOREENTRIES_110:     /* restore */
    movew %sp@(0x0,%d0:w:2),%a2@(0x8,%d0:w:8)
    dbf %d0,RESTOREENTRIES_110
    addaw %d1,%sp
    jbra RESTOREENTRIES_DE
    .short  0x0000	| 4083C91E

/* SAVEENTRIES: _SaveEntries. */
trap_SaveEntries:
SAVEENTRIES:
    linkw %fp,#0
    movel %a2,%sp@-
    clrw QDErr
    tstl %fp@(16)
    jbne SAVEENTRIES_2C
    moveal @(TheGDevice,%za0)@(0),%a0	| 4083C930
    cmpiw #0,%a0@(4)
    jbne SAVEENTRIES_96
    moveal %a0@(0x16,%za0)@(0x0),%a0	| 4083C93E
    moveal %a0@(0x2a,%za0)@(0),%a2
    jbra SAVEENTRIES_32
SAVEENTRIES_2C:         /* the source table given */
    moveal %fp@(0x10,%za0)@(0x0),%a2	| 4083C94C
SAVEENTRIES_32:         /* size the destination for the requested entries */
    moveal %fp@(8),%a1
    movew %a1@,%d2
    movew %d2,%d0
    addqw #1,%d0
    muluw #8,%d0
    addqw #8,%d0
    moveal %fp@(12),%a0
    tstl %a0@
    jbeq SAVEENTRIES_4E
    _SetHandleSize
    jbra SAVEENTRIES_50
SAVEENTRIES_4E:         /* _ReallocHandle */
    _ReallocHandle
SAVEENTRIES_50:         /* no memory: cNoMemErr (-152) */
    jbeq SAVEENTRIES_5A
    movew #-152,QDErr
    jbra SAVEENTRIES_80
SAVEENTRIES_5A:         /* header: seed 0, flags 0, count */
    moveal %a0@,%a0
    clrl %a0@
    clrw %a0@(4)
    movew %d2,%a0@(6)
SAVEENTRIES_66:         /* copy each requested entry */
    movew %a1@(0x2,%d2:w:2),%d0
    cmpw %a2@(6),%d0
    jbgt SAVEENTRIES_88
    movel %a2@(0x8,%d0:w:8),%a0@(0x8,%d2:w:8)
    movel %a2@(0xc,%d0:w:8),%a0@(0xc,%d2:w:8)
SAVEENTRIES_7C:         /* count down (loop) */
    dbf %d2,SAVEENTRIES_66
SAVEENTRIES_80:         /* return */
    moveal %sp@+,%a2
    unlk %fp
SAVEENTRIES_84:         /* return */
    rtd #12
SAVEENTRIES_88:         /* out of range: mark it -1, cRangeErr */
    movew #-1,%a1@(0x2,%d2:w:2)
    movew #-153,QDErr
    jbra SAVEENTRIES_7C
SAVEENTRIES_96:         /* not a CLUT device */
    movew #-155,QDErr
    jbra SAVEENTRIES_84
    .short  0x0000	| 4083C9BE

/* PROTECTENTRY: _ProtectEntry. */
trap_ProtectEntry:
PROTECTENTRY:
    moveq #7,%d2
    jbsr PROTECTENTRY_1A
PROTECTENTRY_4:         /* return */
    rtd #4
PROTECTENTRY_8:         /* already protected / reserved: cProtectErr */
    movew #-154,QDErr
    jbra PROTECTENTRY_16
PROTECTENTRY_10:        /* out of range: cRangeErr */
    movew #-153,QDErr
PROTECTENTRY_16:        /* drop the return, done */
    addqw #4,%sp
    jbra PROTECTENTRY_4

PROTECTENTRY_1A:        /* common: check the index; set or clear bit d2 (7 protect, 6 reserve) of the entry's flags */
    clrw QDErr
    moveal @(TheGDevice,%za0)@(0),%a0	| 4083C9DE
    moveal %a0@(0x16,%za0)@(0x0),%a0
    moveal %a0@(0x2a,%za0)@(0),%a0
    movew %sp@(10),%d0
    cmpw %a0@(6),%d0
    jbgt PROTECTENTRY_10
    tstb %sp@(8)
    jbeq PROTECTENTRY_4C
    btst %d2,%a0@(0x8,%d0:w:8)
    jbne PROTECTENTRY_8
    bset %d2,%a0@(0x8,%d0:w:8)
    jbra PROTECTENTRY_50
PROTECTENTRY_4C:        /* clear the flag */
    bclr %d2,%a0@(0x8,%d0:w:8)
PROTECTENTRY_50:        /* return */
    rts

/* RESERVEENTRY: _ReserveEntry. */
trap_ReserveEntry:
RESERVEENTRY:
    moveq #6,%d2
    jbsr PROTECTENTRY_1A
    tstb %sp@(4)
    jbeq RESERVEENTRY_1A
    movew %a0@(0x8,%d0:w:8),%d1
    moveal @(TheGDevice,%za0)@(0),%a1	| 4083CA20
    moveb %a1@(3),%a0@(0x9,%d0:w:8)
RESERVEENTRY_1A:        /* new seed */
    clrl %sp@-
    jsr @(0x16a0,%za0)@(0)	| 4083CA2E
    movel %sp@+,%a0@
    rtd #4
    .short  0x0000, 0x0000, 0x0000	| 4083CA3A

trap_SetClientID:
SETCLIENTID:            /* SetClientID(id): the current device client ID */
    moveal @(TheGDevice,%za0)@(0),%a0	| 4083CA40
    movew %sp@(4),%a0@(2)
    rtd #2

/* ADDSEARCH: _AddSearch. */
trap_AddSearch:
ADDSEARCH:
    clrw QDErr
    movel %sp@+,%d2
    movel %sp@+,%d1
    jbeq ADDSEARCH_2E
    moveq #8,%d0
    .short  0xA122	| 4083CA5C _NewHandle (flags 0x0100)
    jbne ADDSEARCH_32
    movel %d1,%d0
    jsr @(0x644,%za0)@(0x0)	| 4083CA62
    moveal @(TheGDevice,%za0)@(0),%a1
    movel %a1@(12),%d1
    movel %a0,%a1@(12)
    moveal %a0@,%a0
    movel %d0,%a0@(4)
    movel %d1,%a0@
ADDSEARCH_2E:           /* return */
    jmp @(0x0,%d2:l)
ADDSEARCH_32:           /* cNoMemErr */
    movew #-152,QDErr
    jbra ADDSEARCH_2E

/* ADDCOMP: _AddComp. */
trap_AddComp:
ADDCOMP:
    clrw QDErr
    movel %sp@+,%d2
    movel %sp@+,%d1
    jbeq ADDCOMP_2E
    moveq #8,%d0
    .short  0xA122	| 4083CA96 _NewHandle (flags 0x0100)
    jbne ADDSEARCH_32
    movel %d1,%d0
    jsr @(0x644,%za0)@(0x0)	| 4083CA9C
    moveal @(TheGDevice,%za0)@(0),%a1
    movel %a1@(16),%d1
    movel %a0,%a1@(16)
    moveal %a0@,%a0
    movel %d0,%a0@(4)
    movel %d1,%a0@
ADDCOMP_2E:             /* return */
    jmp @(0x0,%d2:l)
    .long   0x00000000	| 4083CABC

/* DELSEARCH: _DelSearch. */
trap_DelSearch:
DELSEARCH:
    movel %sp@(4),%d1
    moveal @(TheGDevice,%za0)@(0),%a1	| 4083CAC4
    lea %a1@(12),%a1
    movel %a1@,%d2
DELSEARCH_10:           /* find the proc in the device's search chain */
    jbeq DELSEARCH_28
    moveal %d2,%a0
    moveal %a0@,%a0
    cmpl %a0@(4),%d1
    jbeq DELSEARCH_22
    lea %a0@,%a1
    movel %a0@,%d2
    jbra DELSEARCH_10
DELSEARCH_22:           /* unlink and dispose of it */
    movel %a0@,%a1@
    moveal %d2,%a0
    _DisposHandle
DELSEARCH_28:           /* return */
    rtd #4
    .long   0x00000000	| 4083CAEC

/* DELCOMP: _DelComp. */
trap_DelComp:
DELCOMP:
    movel %sp@(4),%d1
    moveal @(TheGDevice,%za0)@(0),%a1	| 4083CAF4
    lea %a1@(16),%a1
    movel %a1@,%d2
DELCOMP_10:             /* find the proc in the complement chain */
    jbeq DELCOMP_28
    moveal %d2,%a0
    moveal %a0@,%a0
    cmpl %a0@(4),%d1
    jbeq DELCOMP_22
    lea %a0@,%a1
    movel %a0@,%d2
    jbra DELCOMP_10
DELCOMP_22:             /* unlink and dispose of it */
    movel %a0@,%a1@
    moveal %d2,%a0
    _DisposHandle
DELCOMP_28:             /* return */
    rtd #4
    .long   0x00000000	| 4083CB1C

/* GETSUBTABLE: _GetSubTable. */
trap_GetSubTable:
GETSUBTABLE:
    linkw %fp,#-12
    moveml %d3/%a2,%sp@-
    tstl %fp@(8)
    jbeq GETSUBTABLE_5E
    .short  0xA166	| 4083CB2E _NewEmptyHandle (flags 0x0100)
    movel %a0,%fp@(-4)
    movel %fp@(8),%sp@-
    movel %a0,%sp@-
    movew %fp@(12),%sp@-
    jsr @(0x16e4,%za0)@(0)	| 4083CB3E
    tstw QDErr
    jbne GETSUBTABLE_A4
    moveal @(TheGDevice,%za0)@(0),%a1	| 4083CB4A
    movel %a1@(6),%fp@(-8)
    movel %fp@(-4),%a1@(6)
    moveal %a1@(0x16,%za0)@(0x0),%a1	| 4083CB5C
    movel %a1@(42),%fp@(-12)
    movel %fp@(14),%a1@(42)
    moveal %a1@(0x2a,%za0)@(0),%a1	| 4083CB6E
    movel %a1@,%d0
    moveal %fp@(0xfffffffffffffffc,%za0)@(0),%a1	| 4083CB76
    movel %d0,%a1@
GETSUBTABLE_5E:         /* for each entry of the table: Color2Index through the device (or the given table's inverse table) */
    moveal %fp@(14),%a0
    _HLock
    moveal %a0@,%a2
    movew %a2@(6),%d3
GETSUBTABLE_6A:         /* next entry */
    subqw #4,%sp
    pea %a2@(0xa,%d3:w:8)
    jsr @(0x16cc,%za0)@(0)	| 4083CB90
    addqw #2,%sp
    movew %sp@+,%a2@(0x8,%d3:w:8)
    dbf %d3,GETSUBTABLE_6A
    moveal %fp@(14),%a0
    _HUnlock
    tstl %fp@(8)
    jbeq GETSUBTABLE_AA
    moveal @(TheGDevice,%za0)@(0),%a1	| 4083CBAC
    movel %fp@(-8),%a1@(6)
    moveal %a1@(0x16,%za0)@(0x0),%a1	| 4083CBB8
    movel %fp@(-12),%a1@(42)
GETSUBTABLE_A4:         /* dispose of the temporary inverse table */
    moveal %fp@(-4),%a0
    _DisposHandle
GETSUBTABLE_AA:         /* restore registers, return */
    moveml %sp@+,%d3/%a2
    unlk %fp
    rtd #10
    .long   0x00000000, 0x00000000, 0x00000000	| 4083CBD4

/* QDERROR: _QDError. */
trap_QDError:
QDERROR:
    movew QDErr,%sp@(4)
    clrw QDErr
    rts
    .long   0x00000000	| 4083CBEC

/* DELTARGB: color distance. */
DELTARGB:
    linkw %fp,#0
    moveml %d0-%d1/%a0-%a1,%sp@-
    moveal %fp@(12),%a0
    moveal %fp@(8),%a1
    movew %a1@+,%d0
    subw %a0@+,%d0
    jbcc DELTARGB_18
    negw %d0
DELTARGB_18:            /* green */
    movew %a1@+,%d1
    subw %a0@+,%d1
    jbcc DELTARGB_20
    negw %d1
DELTARGB_20:            /* keep the larger */
    cmpw %d0,%d1
    jbcs DELTARGB_26
    movew %d1,%d0
DELTARGB_26:            /* blue */
    movew %a1@,%d1
    subw %a0@,%d1
    jbcc DELTARGB_2E
    negw %d1
DELTARGB_2E:            /* keep the larger */
    cmpw %d0,%d1
    jbcs DELTARGB_34
    movew %d1,%d0
DELTARGB_34:            /* return the largest component difference */
    movew %d0,%fp@(16)
    moveml %sp@+,%d0-%d1/%a0-%a1
    unlk %fp
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083CC32
DELTARGB_4E:            /* GetCTable data: the gray step per depth */
    .short  0x0000	| 4083CC3E
    .long   0xFFFF5555, 0x00001111, 0x00000000, 0x00000101	| 4083CC40
DELTARGB_60:            /* GetCTable for the gray ids (32 + depth): a gray ramp of 2^depth entries */
    andiw #15,%d0
    movew %d0,%sp@(4)
    moveq #0,%d1
    addqw #3,%d0
    bset %d0,%d1
    addql #8,%d1
    movel %d1,%d0
    .short  0xA122	| 4083CC62 _NewHandle (flags 0x0100)
    jbeq DELTARGB_7E
    clrl %sp@(6)
    rtd #2
DELTARGB_7E:            /* build it: from white down to black */
    movew %sp@(4),%d0
    lea %pc@(DELTARGB_4E),%a1
    movew %a1@(0x0,%d0:w:2),%d1
    movew %d1,%d2
    swap %d2
    movew %d1,%d2
    moveal %a0@,%a1
    movew #-32768,%a1@(4)
    clrw %d1
    bset %d0,%d1
    subqw #1,%d1
    movew %d1,%a1@(6)	| 4083CC8E
    cmpiw #3,%d0
    blts DELTARGB_7E+0x2e
    addiw #32,%d0
    movel %d0,%a1@
    lea %a1@(8),%a1
    moveq #-1,%d0
    moveq #0,%d1
DELTARGB_B6:            /* one entry */
    movew %d1,%a1@+
    addqw #1,%d1
    movel %d0,%a1@+
    movew %d0,%a1@+
    subl %d2,%d0
    jbcc DELTARGB_B6
    jbra GETCTABLE_A
DELTARGB_C6:            /* GetCTable for 64 + depth (color with the hilite color): the standard table with the hilite color in it */
    andiw #15,%d0
    movew %d0,%sp@-
    jbsr GETCTABLE_38
    movel %a0,%d0
    jbeq GETCTABLE_A
    moveal %a0@,%a1
    subqw #4,%sp
    jsr @(0x16a0,%za0)@(0)	| 4083CCCA
    movel %sp@+,%a1@
    movew %sp@(4),%d0
    btst #1,%d0
    jbeq DELTARGB_11E
    lea HiliteRGB,%a1
    moveb %a1@,%d1
    cmpb %a1@(2),%d1
    jbne DELTARGB_100
    cmpb %a1@(4),%d1
    jbeq GETCTABLE_A
DELTARGB_100:           /* 2-bit: entries are white, hilite, ... (one replaced by the hilite color) */
    moveal %a0@,%a1
    lea %a1@(18),%a1
    movel #2147450879,%a1@+
    movew #32767,%a1@+
    addqw #2,%a1
    movel HiliteRGB,%a1@+
    movew 0xda4,%a1@
    jbra GETCTABLE_A
DELTARGB_11E:           /* 4-bit: the entry closest to the hilite color */
    btst #2,%d0
    beqw GETCTABLE_A
    movew #14,%d2
    movel #131071,%d1
DELTARGB_130:           /* distance of each entry to the hilite color */
    subqw #2,%sp
    pea HiliteRGB
    pea %a1@(0xa,%d2:w:8)
    jsr %pc@(DELTARGB)
    movew %sp@+,%d0
    cmpw %d0,%d1
    jbls DELTARGB_14C
    movew %d0,%d1
    swap %d1
    movew %d2,%d1
    swap %d1
DELTARGB_14C:           /* next; not close enough: leave the table */
    subqw #1,%d2
    jbne DELTARGB_130
    cmpiw #12288,%d1
    jbls GETCTABLE_A
    swap %d1
    lea %a1@(0xa,%d1:w:8),%a1
DELTARGB_15C:           /* replace it with the average of it and the hilite color */
    movel HiliteRGB,%d0
    swap %d0
    addw %a1@,%d0
    roxrw #1,%d0
    movew %d0,%a1@
    swap %d0
    addw %a1@(2),%d0
    roxrw #1,%d0
    movew %d0,%a1@(2)
    movew 0xda4,%d0
    addw %a1@(4),%d0
    roxrw #1,%d0
    movew %d0,%a1@(4)
    subqw #2,%sp
    pea HiliteRGB
    pea %a1@
    jsr %pc@(DELTARGB)
    cmpiw #12288,%sp@+
    jbhi DELTARGB_15C
    jbra GETCTABLE_A

/* GETCTABLE: _GetCTable. */
trap_GetCTable:
GETCTABLE:
    movew %sp@(4),%sp@-
    jbsr GETCTABLE_38
    movel %a0,%d0
    jbeq GETCTABLE_12
GETCTABLE_A:            /* return the table */
    movel %a0,%sp@(6)
GETCTABLE_E:            /* return */
    rtd #2
GETCTABLE_12:           /* no 'clut' resource: the synthesized ones (ids 1,2,4,8 + 32 gray, + 64 hilite) */
    movew %sp@(4),%d0
    cmpiw #72,%d0
    jbhi GETCTABLE_E
    movel #278,%d1
    btst %d0,%d1
    jbeq GETCTABLE_E
    btst #5,%d0
    jbne DELTARGB_60
    btst #6,%d0
    jbne DELTARGB_C6
    jbra GETCTABLE_E

GETCTABLE_38:           /* GetResource 'clut' (detached copy); none: the ROM's */
    subqw #4,%sp
    movel #1668052340,%sp@-
    movew %sp@(12),%sp@-
    jsr @(0x1480,%za0)@(0x0)	| 4083CDCA
    movel %sp@+,%d0
    jbeq GETCTABLE_6A
    movel %d0,%sp@-
    movel %d0,%sp@-
    jsr @(0x1448,%za0)@(0x0)	| 4083CDD8
    moveal %sp@+,%a0
    _HNoPurge
    moveal %a0@,%a1
    subqw #4,%sp
    jsr @(0x16a0,%za0)@(0)	| 4083CDE6
    movel %sp@+,%a1@
    jbra GETCTABLE_92
GETCTABLE_6A:           /* from the ROM resources (ROMMapInsert) */
    movew #-1,ROMMapInsert
    subqw #4,%sp
    movel #1668052340,%sp@-
    movew %sp@(12),%sp@-
    jsr @(0x1480,%za0)@(0x0)	| 4083CE02
    movel %sp@+,%d0
    jbeq GETCTABLE_90
    moveal %d0,%a0
    jsr @(0x1584,%za0)@(0x0)	| 4083CE0E
    jbeq GETCTABLE_92
GETCTABLE_90:           /* none */
    subal %a0,%a0
GETCTABLE_92:           /* return */
    rtd #2
    .long   0x00000000	| 4083CE1C

/* ANGLEFROMSLOPE: _AngleFromSlope. */
trap_AngleFromSlope:
ANGLEFROMSLOPE:
    movel %sp@(4),%d0
    smi %d2
    jbpl ANGLEFROMSLOPE_A
    negl %d0
ANGLEFROMSLOPE_A:       /* search the angles 0.. until the slope table passes the value */
    subil #500,%d0
    movel %d0,%sp@(4)
    lea %pc@(ANGLEFROMSLOPE_22),%a0
    moveq #-1,%d1
ANGLEFROMSLOPE_1A:      /* next angle: its slope (SlopeFromAngle) */
    addqw #1,%d1
    movew %d1,%d0
    clrl %sp@-
    jbra SLOPEFROMANGLE_18
ANGLEFROMSLOPE_22:      /* past it? the angle (sign from the slope) */
    movel %sp@(8),%d0	| 4083CE42
    cmpl %sp@+,%d0	| 4083CE46
    jbgt ANGLEFROMSLOPE_1A	| 4083CE48
    movew #180,%d0	| 4083CE4A
    subw %d1,%d0	| 4083CE4E
    tstb %d2	| 4083CE50
    jbpl ANGLEFROMSLOPE_36	| 4083CE52
    movew %d1,%d0	| 4083CE54
ANGLEFROMSLOPE_36:      /* return */
    movel %sp@+,%sp@	| 4083CE56
    movew %d0,%sp@(4)	| 4083CE58
    rts	| 4083CE5C

/* SLOPEFROMANGLE: _SlopeFromAngle. */
trap_SlopeFromAngle:
SLOPEFROMANGLE:
    moveal %sp@+,%a0
    movew %sp@+,%d0
    extl %d0
    divsw #180,%d0
    swap %d0
    tstw %d0
    jbpl SLOPEFROMANGLE_14
SLOPEFROMANGLE_10:      /* negative remainder */
    addiw #180,%d0
SLOPEFROMANGLE_14:      /* angle mod 180 */
    movew #-32768,%sp@
SLOPEFROMANGLE_18:      /* above 90: mirror (negative slope) */
    cmpiw #90,%d0
    jble SLOPEFROMANGLE_26
    clrw %sp@
    subiw #180,%d0
    negw %d0
SLOPEFROMANGLE_26:      /* integer part from the table above 45 degrees */
    cmpiw #45,%d0
    jblt SLOPEFROMANGLE_40
    addqw #1,%sp@
    cmpiw #64,%d0
    jblt SLOPEFROMANGLE_40
    moveb %pc@(SLOPEFROMANGLE_13,%d0:w),%sp@(1)
    jbpl SLOPEFROMANGLE_40
    orib #127,%sp@
SLOPEFROMANGLE_40:      /* fraction from the table; negate */
    addw %d0,%d0
    movew %pc@(SLOPEFROMANGLE_6E,%d0:w),%sp@(2)
    bclr #7,%sp@
    jbeq SLOPEFROMANGLE_50
    negl %sp@
SLOPEFROMANGLE_50:      /* return */
    jmp %a0@
    .long   0x01020202, 0x02020202, 0x02030303, 0x03040404	| 4083CEB0
    .long   0x05050607, 0x08090B0E, 0x131C39FF	| 4083CEC0
SLOPEFROMANGLE_6E:      /* tangent fractions by degree (data) */
    .long   0x00000478	| 4083CECC
    .long   0x08F10D6B, 0x11E71666, 0x1AE81F6F, 0x23FA288C	| 4083CED0
    .long   0x2D2431C3, 0x366A3B1A, 0x3FD44498, 0x49684E44	| 4083CEE0
    .long   0x532E5826, 0x5D2D6245, 0x676E6CAA, 0x71FB7760	| 4083CEF0
    .long   0x7CDC8270, 0x881E8DE7, 0x93CD99D2, 0x9FF7A640	| 4083CF00
    .long   0xACADB341, 0xB9FFC0E9, 0xC802CF4E, 0xD6CFDE8A	| 4083CF10
    .long   0xE681EEB9, 0xF7370000, 0x09191287, 0x1C51267F	| 4083CF20
    .long   0x31173C22, 0x47AA53B9, 0x605B6D9B, 0x7B898A35	| 4083CF30
    .long   0x99AFAA0E, 0xBB68CDD6, 0xE177F66E, 0x0CE124FE	| 4083CF40
    .long   0x3EFC5B19, 0x799F9AE7, 0xBF5BE77A, 0x13E34556	| 4083CF50
    .long   0x7CC7BB68, 0x02C254DB, 0xB4622501, 0xABD95051	| 4083CF60
    .long   0x1D8824F3, 0x83AD6E17, 0x4CF514BD, 0xA2D74A30	| 4083CF70
    .long   0xFFFF0000, 0x00000000, 0x00000000, 0x00000000	| 4083CF80

/* PTTOANGLE: _PtToAngle. */
trap_PtToAngle:
PTTOANGLE:
    linkw %fp,#0
    moveml %d6-%d7/%a4,%sp@-
    moveal %fp@(16),%a4
    movew %a4@(4),%d0
    addw %a4@,%d0
    asrw #1,%d0
    movew %fp@(12),%d1
    subw %d0,%d1
    movew %a4@(6),%d0
    addw %a4@(2),%d0
    asrw #1,%d0
    movew %fp@(14),%d7
    subw %d0,%d7
    jbne PTTOANGLE_36
    tstw %d1
    jble PTTOANGLE_88
    movew #180,%d0
    jbra PTTOANGLE_8A
PTTOANGLE_36:           /* FixRatio of the offsets scaled by the rectangle's aspect; the angle from the slope */
    clrl %sp@-
    movew %d7,%sp@-
    movew %d1,%sp@-
    jsr @(0xfa4,%za0)@(0)	| 4083CFCC
    movel %sp@+,%d6
    clrl %sp@-
    movew %a4@(4),%d0
    subw %a4@,%d0
    movew %d0,%sp@-
    movew %a4@(6),%d0
    subw %a4@(2),%d0
    movew %d0,%sp@-
    jsr @(0xfa4,%za0)@(0)	| 4083CFE8
    movel %sp@+,%d0
    clrl %sp@-
    movel %d6,%sp@-
    movel %d0,%sp@-
    jsr @(0xfa0,%za0)@(0)	| 4083CFF6
    movel %sp@+,%d0
    clrw %sp@-
    movel %d0,%sp@-
    jsr @(0x1110,%za0)@(0x0)	| 4083D002
    movew %sp@+,%d0
    tstw %d7
    jbpl PTTOANGLE_8A
    addiw #180,%d0
    cmpiw #360,%d0
    jbne PTTOANGLE_8A
PTTOANGLE_88:           /* zero */
    clrw %d0
PTTOANGLE_8A:           /* return the angle */
    moveal %fp@(8),%a0
    movew %d0,%a0@
    moveml %sp@+,%d6-%d7/%a4
    unlk %fp
    rtd #12
    .short  0x0000, 0x0000, 0x0000	| 4083D02A
