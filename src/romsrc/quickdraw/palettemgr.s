/*
 quickdraw/palettemgr.s - Palette Manager
 From SYSCOLORS (0x4083D780). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* MASKEND: MASKEND, XPALETTES and SYSCOLORS share this address: pixel masks for 2, 4, 16 and 32 bits and constants (data) */
MASKEND:
XPALETTES:
SYSCOLORS:
    .long   0x00000003, 0x0000000F, 0x0000FFFF, 0xFFFFFFFF	| 4083D780
    .long   0x00010000, 0x00000000	| 4083D790
/* SYSCOLOREND: end of the system colors (data) */
SYSCOLOREND:
    .long   0x00000000, 0x00000000	| 4083D798

/* UPDATEPALETTE: UpdatePalette: ActivatePalette's body with "update" set: re-establish the palette's colors on every device (PMgrHandle, 0xDC8) */
UPDATEPALETTE:
    linkw %fp,#-116
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveq #1,%d3
    clrl %fp@(-4)
    moveal 0xdc8,%a2
    moveal %fp@(8),%a3
    jbra ACTIVATEPALETTE_58

/* ACTIVATEPALETTE: _ActivatePalette. */
trap_ActivatePalette:
ACTIVATEPALETTE:
    linkw %fp,#-116
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveq #1,%d3
    moveal 0xdc8,%a2
    cmpaw #-1,%a2
    jbeq ACTIVATEPALETTE_1D0
    moveal %a2@,%a0
    movew %a0@,%d0
    jbeq ACTIVATEPALETTE_1D0
    moveal %fp@(8),%a3
    cmpaw #0,%a3
    jbeq ACTIVATEPALETTE_1D0
    movel %a3,%fp@(-4)
    tstw %a3@(6)
    jbpl ACTIVATEPALETTE_44
    moveal %a3@(8),%a0
    moveal %a0@,%a0
    moveal %a0@(12),%a3
    cmpaw #0,%a3
    jbne ACTIVATEPALETTE_58
ACTIVATEPALETTE_44:     /* no window palette: the application's (0xDCC) or the system palette */
    moveal 0xdcc,%a3
    movel %a3,%d0
    jbne ACTIVATEPALETTE_58
    moveal %a2@,%a0
    moveal %a0@(12),%a3
    movel %a3,%d0
    jbeq ACTIVATEPALETTE_1D0
ACTIVATEPALETTE_58:     /* lock; count the tolerant and animating entries */
    moveal %a2,%a0
    _HLock
    moveal %a3,%a0
    movel %a3,%fp@(-8)
    _HLock
    moveal %a2@,%a4
    movel %a4,%fp@(-18)
    moveal %a4@(4),%a0
    _HLock
    movel %a0@,%fp@(-26)
    movew %a4@,%fp@(-34)
    lea %a4@(56),%a0
    movel %a0,%fp@(-22)
    movel TheGDevice,%fp@(-68)
    clrl %fp@(-60)
    moveal %a3@,%a4
    movel %a4,%fp@(-12)
    movew %a4@,%d4
    movew %d4,%fp@(-14)
    clrw %fp@(-72)
    clrw %fp@(-74)
    jsr %pc@(CALCDEVS)
    clrw %sp@-
    jsr %pc@(SCATTERDEVICES)
    tstl %fp@(-48)
    jbeq ACTIVATEPALETTE_146
    lea %a4@(16),%a4
    movew %fp@(-14),%d4
    jbra ACTIVATEPALETTE_EE
ACTIVATEPALETTE_BA:     /* each entry: animating (usage bit 2)? */
    movew %a4@(6),%d1
    btst #2,%d1
    jbeq ACTIVATEPALETTE_CA
    addqw #1,%fp@(-72)
    jbra ACTIVATEPALETTE_EA
ACTIVATEPALETTE_CA:     /* tolerant (bit 1) with a real color? */
    btst #1,%d1
    jbeq ACTIVATEPALETTE_E4
    movel %a4@,%d0
    moveb %a4@(4),%d0
    tstl %d0
    jbeq ACTIVATEPALETTE_E4
    addql #1,%d0
    jbeq ACTIVATEPALETTE_E4
    addqw #1,%fp@(-74)
    jbra ACTIVATEPALETTE_EA
ACTIVATEPALETTE_E4:     /* mark it handled */
    bset #15,%a4@(6)
ACTIVATEPALETTE_EA:     /* next entry */
    lea %a4@(16),%a4
ACTIVATEPALETTE_EE:     /* any to allocate: a 512-byte index list; for each device the window touches */
    dbf %d4,ACTIVATEPALETTE_BA
    movew %fp@(-72),%d0
    orw %fp@(-74),%d0
    beqw ACTIVATEPALETTE_146
    movel #512,%d0
    .short  0xA322	| 4083D8BC _NewHandle (flags 0x0300)
    jbne ACTIVATEPALETTE_18A
    movel %a0,%fp@(-60)
    _HLock
    moveal %a0@,%a0
    movel %a0,%fp@(-64)
    moveq #0,%d4
ACTIVATEPALETTE_118:    /* on this device? SETDEV: analyze, allocate, correlate */
    movel %fp@(-48),%d0
    btst %d4,%d0
    jbeq ACTIVATEPALETTE_138
    movew %fp@(-72),%fp@(-76)
    movew %fp@(-74),%fp@(-78)
    movew %d4,%fp@(-28)
    jsr %pc@(SETDEV)
    jbeq ACTIVATEPALETTE_138
    addqw #1,%d3
ACTIVATEPALETTE_138:    /* next device; restore TheGDevice */
    addqw #1,%d4
    cmpw %fp@(-34),%d4
    jbmi ACTIVATEPALETTE_118
    movel %fp@(-68),TheGDevice
ACTIVATEPALETTE_146:    /* devices the palette no longer touches (+8 mask, not in fp-44): release its reserved entries */
    moveal %fp@(-18),%a0
    moveal %a0@(4),%a0
    moveal %a0@,%a0
    moveal %fp@(-12),%a1
    movew %a1@(6),%d0
    andiw #4095,%d0
    movew %a0@(0x4,%d0:w:8),%d0
    jbeq ACTIVATEPALETTE_178
    moveal %fp@(-18),%a0
    movel %a1@(8),%d0
    movel %fp@(-44),%d1
    notl %d1
    andl %d1,%d0
    jbeq ACTIVATEPALETTE_178
    jsr %pc@(UNRESERVEDEVICES)
ACTIVATEPALETTE_178:    /* give back reserved entries, redraw the devices that changed */
    clrw %sp@-
    jsr %pc@(SCATTERDEVICES)
    jsr %pc@(UPDATEDEVICES)
    movel %fp@(-44),%a1@(8)
    subqw #1,%d3
ACTIVATEPALETTE_18A:    /* unlock; clear the entries' working flags */
    moveal %fp@(-18),%a0
    moveal %a0@(4),%a0
    _HUnlock
    moveal %a2,%a0
    _HUnlock
    moveal %fp@(-12),%a0
    bclr #13,%a0@(6)
    movew %a0@,%d0
    lea %a0@(16),%a0
    jbra ACTIVATEPALETTE_1BA
ACTIVATEPALETTE_1AA:    /* each entry */
    movew %a0@(6),%d1
    andiw #16143,%d1
    movew %d1,%a0@(6)
    addaw #16,%a0
ACTIVATEPALETTE_1BA:    /* next; dispose of the list */
    dbf %d0,ACTIVATEPALETTE_1AA
    moveal %a3,%a0
    _HUnlock
    moveal %fp@(-60),%a0
    cmpaw #0,%a0
    jbeq ACTIVATEPALETTE_1CE
    _DisposHandle
ACTIVATEPALETTE_1CE:    /* done: d3 = 0 */
    moveq #0,%d3
ACTIVATEPALETTE_1D0:    /* return */
    movel %d3,%d0
    moveml %sp@+,%d3-%d4/%a2-%a4
    unlk %fp
    rtd #4
    .long   0x00000000, 0x00000000, 0x00000000	| 4083D994

/* ALLOCATE: Allocate: give the tolerant and animating entries of the palette device indexes (inside ActivatePalette's frame) */
ALLOCATE:
    moveml %d3-%d4/%a2-%a3,%sp@-
    tstw %fp@(-76)
    jbeq ALLOCATE_9A
    moveal %fp@(-12),%a3
    moveq #0,%d4
    moveq #0,%d2
    moveq #0,%d3
    lea %a3@(16),%a2
    jbra ALLOCATE_96
ALLOCATE_1C:            /* each animating entry not yet done: already linked to an index on this device? */
    movew %a2@(10),%d0
    jbmi ALLOCATE_90
    btst #2,%d0
    jbeq ALLOCATE_90
    btst #3,%a2@(11)
    jbeq ALLOCATE_64
    movew %d4,%d3
    andw %fp@(-70),%d3
    jbeq ALLOCATE_90
    cmpw %fp@(-70),%d3
    jbeq ALLOCATE_90
    bftst %fp@(-116),%d3,1
    jbne ALLOCATE_90
    bfset %fp@(-116),%d3,1
    clrw %sp@-
    movew %a2@(12),%sp@-
    jsr %pc@(FINDLINK)
    movew %sp@+,%d2
    jbne ALLOCATE_8A
    movew %d3,%sp@-
    jsr %pc@(PILLAGE)
    movew %d3,%d2
    jbra ALLOCATE_7C
ALLOCATE_64:            /* no: a free index (GIMMEINDEX); none: take one (PILLAGE) */
    clrw %sp@-
    movew %a2@(12),%sp@-
    jsr %pc@(FINDLINK)
    movew %sp@+,%d2
    jbne ALLOCATE_8A
    subqw #2,%sp
    jbsr GIMMEINDEX
    movew %sp@+,%d2
    jbeq ALLOCATE_90
ALLOCATE_7C:            /* take it over and claim it */
    movew %d2,%sp@-
    jsr %pc@(PILLAGE)
    movew %d4,%d0
    moveal %a2,%a0
    jbsr CLAIMINDEX
ALLOCATE_8A:            /* mark it done */
    bset #15,%a2@(10)
ALLOCATE_90:            /* next entry */
    addaw #16,%a2
    addqw #1,%d4
ALLOCATE_96:            /* until the last */
    cmpw %a3@,%d4
    jblt ALLOCATE_1C
ALLOCATE_9A:            /* restore registers, return */
    moveml %sp@+,%d3-%d4/%a2-%a3
    rts

/* CHECKALLDEVICECLUTS: CheckAllDeviceCluts: for each device the Palette Manager tracks, check its color table against the saved one (CHECKDEVICECOLORS) */
CHECKALLDEVICECLUTS:
    moveml %d3-%d4/%a0-%a3,%sp@-
    moveal 0xdc8,%a2
    moveal %a2,%a0
    _HLock
    moveal %a2@,%a3
    movew %a3@,%d3
    subqw #1,%d3
    moveq #0,%d4
CHECKALLDEVICECLUTS_14: /* each device: changed? mark it in the mask */
    subqw #2,%sp
    movel %a3@(0x38,%d3:w:8),%sp@-
    jsr %pc@(CHECKDEVICECOLORS)
    tstw %sp@+
    jbeq CHECKALLDEVICECLUTS_24
    bset %d3,%d4
CHECKALLDEVICECLUTS_24: /* next; the changed devices into the update mask (+16) */
    dbf %d3,CHECKALLDEVICECLUTS_14
    orl %d4,%a3@(16)
    moveal %a2,%a0
    _HUnlock
    moveml %sp@+,%d3-%d4/%a0-%a3
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083DA76

/* CHECKFORJUGGLER: CheckForJuggler: d0 = -1 (ne) when OSDispatch (0xA88F) is the unimplemented trap (0xA89F), i.e. no MultiFinder; 0 when MultiFinder runs */
CHECKFORJUGGLER:
    movel %a0,%sp@-
    movew #-22385,%d0
    .short  0xA146	| 4083DA86 _GetTrapAddress (flags 0x0100)
    movel %a0,%sp@-
    movew #-22369,%d0
    .short  0xA146	| 4083DA8E _GetTrapAddress (flags 0x0100)
    cmpal %sp@+,%a0
    seq %d0
    extbl %d0
    moveal %sp@+,%a0
    rts
    .short  0x0000, 0x0000, 0x0000	| 4083DA9A
/* PMGREXIT: PMgrExit: application quit: check the device tables, scatter the reserved entries; under MultiFinder also update the devices and make the main device current */
PMGREXIT:
    cmpil #-1,0xdc8	| 4083DAA0
    beqs PMGREXIT_2A
    clrl 0xdcc
    jsr %pc@(DISPOSEAPPPALETTES)
    jsr %pc@(CHECKALLDEVICECLUTS)	| 4083DAB2
    clrw %sp@-	| 4083DAB6
    jsr %pc@(SCATTERDEVICES)	| 4083DAB8
    jbsr CHECKFORJUGGLER
    jbne PMGREXIT_2A
    jsr %pc@(UPDATEDEVICES)
    movel MainDevice,TheGDevice
PMGREXIT_2A:            /* return */
    rts
    .long   0x00000000	| 4083DACC

/* INSTALLMYEXITTOSHELL: InstallMyExitToShell: hook ExitToShell (vector 0x15D0) with MYEXITTOSHELL, once, when MultiFinder is running */
INSTALLMYEXITTOSHELL:
    jsr %pc@(CHECKFORJUGGLER)
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    lea %a0@(24),%a0
    orl %a0@,%d0
    jbne INSTALLMYEXITTOSHELL_1E
    movel 0x15d0,%a0@
    lea %pc@(MYEXITTOSHELL),%a0
    movel %a0,0x15d0
INSTALLMYEXITTOSHELL_1E:/* return */
    rts
/* MYEXITTOSHELL: MyExitToShell: the ExitToShell hook: through the Palette Manager's dispatch (PMgrHandle +24, selector 12) */
MYEXITTOSHELL:
    moveq #12,%d0	| 4083DAF0
    _PaletteDispatch	| 4083DAF2
    moveal 0xdc8,%a0	| 4083DAF4
    moveal %a0@,%a0	| 4083DAF8
    moveal %a0@(24),%a0	| 4083DAFA
    jmp %a0@	| 4083DAFE

/* RECORDPALETTE: RecordPalette(pal): note the palette in the Palette Manager's list of application palettes */
RECORDPALETTE:
    linkw %fp,#0
    moveml %d3/%a2-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal 0xdc8,%a2
    cmpaw #-1,%a2
    jbeq RECORDPALETTE_B2
    moveal %a2@,%a0
    moveal %a0@(4),%a3
    moveq #0,%d0
    movew %a0@(2),%d0
    .short  0xA322	| 4083DB24 _NewHandle (flags 0x0300)
    jbne RECORDPALETTE_B2
    moveal %a4@,%a1
    movel %a0,%a1@(12)
    moveal %a2@,%a1
    movew %a1@(10),%d0
    jbne RECORDPALETTE_74
    moveq #0,%d3
    movew %a1@(8),%d3
    movel %d3,%d0
    addiw #16,%d0
    jbmi RECORDPALETTE_B2
    lsll #3,%d0
    moveal %a3,%a0
    _SetHandleSize
    jbne RECORDPALETTE_B2
    moveal %a3,%a0
    moveal %a0@,%a0
    lea %a0@(0x0,%d3:w:8),%a0
    moveq #16,%d0
    jbra RECORDPALETTE_5E
RECORDPALETTE_5A:       /* grow the palette list, cleared */
    clrl %a0@+
    clrl %a0@+
RECORDPALETTE_5E:       /* next; the new slot */
    dbf %d0,RECORDPALETTE_5A
    addqw #1,%d3
    moveal %a3@,%a0
    lea %a0@(0x0,%d3:w:8),%a0
    moveal %a2@,%a1
    movew #15,%a1@(10)
    jbra RECORDPALETTE_94
RECORDPALETTE_74:       /* find a free slot */
    movew %a1@(8),%d0
    addw %a1@(10),%d0
    moveq #0,%d3
    moveal %a3@,%a0
    jbra RECORDPALETTE_8A
RECORDPALETTE_82:       /* free? */
    movel %a0@,%d1
    jbeq RECORDPALETTE_90
    addqw #8,%a0
    addqw #1,%d3
RECORDPALETTE_8A:       /* next; none: fail */
    dbf %d0,RECORDPALETTE_82
    jbra RECORDPALETTE_B2
RECORDPALETTE_90:       /* one fewer free */
    subqw #1,%a1@(10)
RECORDPALETTE_94:       /* store the palette and its slot number in its private field */
    addqw #1,%a1@(8)
    movel %a4,%a0@
    clrl %a0@(4)
    moveal %a4@,%a0
    movew %a0@(6),%d0
    andiw #-8192,%d0
    orw %d0,%d3
    movew %d3,%a0@(6)
    moveq #0,%d0
    jbra RECORDPALETTE_B8
RECORDPALETTE_B2:       /* failure: dispose of it */
    moveal %a4,%a0
    _DisposHandle
    moveq #1,%d0
RECORDPALETTE_B8:       /* return */
    tstl %d0
    moveml %sp@+,%d3/%a2-%a4
    unlk %fp
    rtd #4
    .long   0x00000000, 0x00000000, 0x00000000	| 4083DBC4

/* NEWPALETTE: _NewPalette. */
trap_NewPalette:
NEWPALETTE:
    linkw %fp,#0
    moveml %d3/%a2,%sp@-
    clrl %fp@(18)
    movew %fp@(16),%d3
    moveq #0,%d0
    movew %d3,%d0
    addqw #1,%d0
    lsll #4,%d0
    .short  0xA322	| 4083DBE8 _NewHandle (flags 0x0300)
    jbne NEWPALETTE_9A
    moveal %a0,%a2
    movel %a2,%sp@-
    jsr %pc@(RECORDPALETTE)
    jbne NEWPALETTE_9A
    movel %a2,%fp@(18)
    moveal %a2@,%a0
    movew %d3,%a0@
    clrl %a0@(2)
    movew %d3,%d0
    movew %fp@(10),%d1
    swap %d1
    movew %fp@(8),%d1
    lea %a0@(22),%a0
    jbra NEWPALETTE_4A
NEWPALETTE_44:          /* clear the entries */
    movel %d1,%a0@
    lea %a0@(16),%a0
NEWPALETTE_4A:          /* next; a source color table? copy its colors */
    dbf %d0,NEWPALETTE_44
    moveal %fp@(12),%a1
    cmpaw #0,%a1
    jbeq NEWPALETTE_98
    moveal %a1@,%a1
    movew %a1@(6),%d0
    addqw #1,%d0
    jble NEWPALETTE_98
    moveal %a2@,%a0
    addaw #16,%a0
    addaw #10,%a1
    cmpw %d0,%d3
    jbge NEWPALETTE_72
    movew %d3,%d0
NEWPALETTE_72:          /* start */
    moveq #0,%d1
    jbra NEWPALETTE_94
NEWPALETTE_76:          /* RGB, usage and tolerance per entry */
    movel %a1@,%a0@
    moveb %a1@,%a0@(1)
    moveb %a1@(2),%a0@(3)
    movew %a1@(4),%a0@(4)
    moveb %a1@(4),%a0@(5)
    addql #8,%a1
    addaw #16,%a0
NEWPALETTE_94:          /* next */
    dbf %d0,NEWPALETTE_76
NEWPALETTE_98:          /* result */
    moveq #0,%d0
NEWPALETTE_9A:          /* restore registers, return */
    moveml %sp@+,%d3/%a2
    unlk %fp
    rtd #10
    .long   0x00000000, 0x00000000, 0x00000000	| 4083DC74

/* GETNEWPALETTE: _GetNewPalette. */
trap_GetNewPalette:
GETNEWPALETTE:
    linkw %fp,#0
    movel %a2,%sp@-
    clrl %fp@(10)
    clrl %sp@-
    movel #1886155892,%sp@-
    movew %fp@(8),%sp@-
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x1480,%za0)@(0x0)	| 4083DC96
    movel %sp@+,%d1
    jbeq GETNEWPALETTE_58
    moveal %d1,%a2
    movel %d1,%sp@-
    jsr @(0x1448,%za0)@(0x0)	| 4083DCA4
    moveal %a2,%a0
    _HNoPurge
    tstw %d0
    jbne GETNEWPALETTE_58
    moveal %a2@,%a0
    movew #-16384,%d1
    movew %a0@(2),%d0
    jbpl GETNEWPALETTE_42
    addw %d0,%d0
    movew %d0,%d1
GETNEWPALETTE_42:       /* count; record it */
    movew %d1,%a0@(6)
    movel %a2,%sp@-
    jsr %pc@(RECORDPALETTE)
    jbne GETNEWPALETTE_58
    movel %a2,%fp@(10)
    moveal %a2@,%a2
    clrl %a2@(8)
GETNEWPALETTE_58:       /* return */
    moveal %sp@+,%a2
    unlk %fp
    rtd #2

/* CLAIMINDEX: ClaimIndex: reserve a device index for a palette entry (inside ActivatePalette's frame): link it, mark it used */
CLAIMINDEX:
    moveal %fp@(-40),%a1
    moveal %a1@,%a1
    subqw #4,%sp
    jsr @(0x16a0,%za0)@(0)	| 4083DCE8
    movel %sp@+,%a1@
    bset #15,%a0@(10)
    movel %a0@,%a1@(0xa,%d2:w:8)
    movew %a0@(4),%a1@(0xe,%d2:w:8)
    addqw #1,%fp@(-82)
    bset #6,%a1@(0x8,%d2:w:8)
    moveal %fp@(-32),%a1
    andiw #32767,%d0
    oriw #24576,%d0
    movew %d0,%a1@(0x2,%d2:w:4)
    movew %fp@(-28),%d0
    lslw #8,%d0
    orw %d2,%d0
    bset #15,%d0
    movew %a0@(12),%d1
    movew %d0,%a0@(12)
    tstw %d1
    jbne CLAIMINDEX_68
    moveal %fp@(-12),%a0
    movew %a0@(6),%d0
    andiw #4095,%d0
    oriw #24576,%d0
    movew %d0,%a1@(0x0,%d2:w:4)
    jbra CLAIMINDEX_84
CLAIMINDEX_68:          /* link the entry into the index's chain */
    movew %d1,%a1@(0x0,%d2:w:4)
    bfextu %d1,24,8,%d2
    bfextu %d1,19,5,%d1
    lslw #8,%d1
    addw %d2,%d1
    moveal %fp@(-18),%a1
    addaw #312,%a1
    movew %d0,%a1@(0x2,%d1:l:4)
CLAIMINDEX_84:          /* count it */
    moveal %fp@(-26),%a0
    moveal %fp@(-12),%a1
    movew %a1@(6),%d0
    andiw #4095,%d0
    addqw #1,%a0@(0x4,%d0:w:8)
    addqw #1,%fp@(-82)
    rts
    .short  0x0000	| 4083DD7E

/* CLEARPALETTE: ClearPalette(pal): release every device index the palette's entries hold */
CLEARPALETTE:
    linkw %fp,#0
    moveml %d2-%d4/%a2-%a4,%sp@-
    moveal 0xdc8,%a3
    cmpaw #-1,%a3
    jbeq CLEARPALETTE_80
    moveal %a3@,%a3
    moveal %fp@(8),%a1
    moveal %a1@,%a2
    movew %a2@(6),%d0
    andiw #4095,%d0
    moveal %a3@(4),%a0
    moveal %a0@,%a0
    cmpal %a0@(0x0,%d0:w:8),%a1
    jbne CLEARPALETTE_82
    movew %a0@(0x4,%d0:w:8),%d3
    clrl %a0@(0x4,%d0:w:8)
    clrl %a2@(8)
    moveal %a2@(12),%a0
    moveal %a0@,%a0
    movew %a3@(2),%d0
    lsrw #2,%d0
    jbra CLEARPALETTE_4A
CLEARPALETTE_48:        /* clear */
    clrl %a0@+
CLEARPALETTE_4A:        /* next; release each entry's links */
    dbf %d0,CLEARPALETTE_48
    tstw %d3
    jbeq CLEARPALETTE_80
    movew %a2@,%d0
    addaw #16,%a2
    lea %a3@(56),%a4
    addaw #312,%a3
    jbra CLEARPALETTE_7C
CLEARPALETTE_62:        /* linked? release the chain (CLEARSTRAND), mark the device */
    movew %a2@(12),%d3
    jbpl CLEARPALETTE_70
    jsr %pc@(CLEARSTRAND)
    orl %d4,%a3@(-296)
CLEARPALETTE_70:        /* clear the entry's links */
    clrw %a2@(10)
    clrl %a2@(12)
    addaw #16,%a2
CLEARPALETTE_7C:        /* next */
    dbf %d0,CLEARPALETTE_62
CLEARPALETTE_80:        /* d0 = 0 */
    moveq #0,%d0
CLEARPALETTE_82:        /* restore registers, return */
    moveml %sp@+,%d2-%d4/%a2-%a4
    unlk %fp
    rtd #4
    .long   0x00000000	| 4083DE0C

/* CLEARSTRAND: ClearStrand: release one entry's link to a device index (device number in bits 19..23, index in 24..31) */
CLEARSTRAND:
    moveq #0,%d4
CLEARSTRAND_2:          /* device and index from the link; the device's color table: free the entry */
    bfextu %d3,19,5,%d1
    bfextu %d3,24,8,%d2
    moveal %a4@(0x0,%d1:w:8),%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    cmpw %a0@(6),%d2
    jbhi CLEARSTRAND_2A
    movew #4096,%a0@(0x8,%d2:w:8)
    bset %d1,%d4
CLEARSTRAND_2A:         /* next link in the chain */
    lslw #8,%d1
    addw %d2,%d1
    lea %a3@(0x0,%d1:l:4),%a0
    movew %a0@,%d3
    clrl %a0@
    tstw %d3
    jbmi CLEARSTRAND_2
    rts
    .long   0x00000000	| 4083DE4C

/* ERASEPALETTE: ErasePalette(pal): dispose of its link table; clear it from the windows that use it */
ERASEPALETTE:
    linkw %fp,#0
    moveml %a2-%a3,%sp@-
    moveal %fp@(8),%a3
    moveal %a3@,%a2
    moveal %a2@(12),%a0
    cmpaw #0,%a0
    jbeq ERASEPALETTE_1A
    _DisposHandle
ERASEPALETTE_1A:        /* clear it from the windows */
    moveal WindowList,%a0
    jbra ERASEPALETTE_3E
ERASEPALETTE_20:        /* color window using it? clear */
    tstw %a0@(6)
    jbpl ERASEPALETTE_3A
    moveal %a0@(8),%a1
    moveal %a1@,%a1
    movel %a1@(12),%d0
    cmpl %fp@(8),%d0
    jbne ERASEPALETTE_3A
    clrl %a1@(12)
ERASEPALETTE_3A:        /* next window */
    moveal %a0@(144),%a0
ERASEPALETTE_3E:        /* the application palette? */
    movel %a0,%d0
    jbne ERASEPALETTE_20
    cmpal 0xdcc,%a3
    jbne ERASEPALETTE_4C
    clrl 0xdcc
ERASEPALETTE_4C:        /* free its slot in the palette list */
    movew %a2@(6),%d0
    andiw #4095,%d0
    moveal 0xdc8,%a2
    cmpaw #-1,%a2
    jbeq ERASEPALETTE_84
    moveal %a2@,%a2
    movew %a2@(8),%d1
    addw %a2@(10),%d1
    cmpw %d1,%d0
    jbpl ERASEPALETTE_84
    moveal %a2@(4),%a1
    moveal %a1@,%a1
    cmpal %a1@(0x0,%d0:w:8),%a3
    jbne ERASEPALETTE_84
    clrl %a1@(0x0,%d0:w:8)
    addqw #1,%a2@(10)
    subqw #1,%a2@(8)
ERASEPALETTE_84:        /* restore registers, return */
    moveml %sp@+,%a2-%a3
    unlk %fp
    rtd #4
    .short  0x0000	| 4083DEDE

/* CORRELATE: Correlate: for each palette entry find the nearest device color (ActivatePalette's frame) */
CORRELATE:
    moveml %d3-%d7/%a2-%a3,%sp@-
    tstw %fp@(-78)
    jbeq CORRELATE_152
    moveq #0,%d4
    moveal %fp@(-12),%a2
    lea %a2@(16),%a2
    moveal %fp@(-40),%a3
    moveal %a3,%a0
    _HLock
    moveal %a3@,%a3
    moveq #0,%d3
CORRELATE_22:           /* each tolerant, explicit entry: a fixed index */
    movew %a2@(6),%d7
    btst #1,%d7
    jbeq CORRELATE_90
    btst #3,%d7
    jbeq CORRELATE_90
    movew %d4,%d3
    andw %fp@(-70),%d3
    jbeq CORRELATE_90
    cmpw %fp@(-70),%d3
    jbeq CORRELATE_90
    bftst %fp@(-116),%d3,1
    jbne CORRELATE_90
    bfset %fp@(-116),%d3,1
    movew %d3,%sp@-
    jsr %pc@(PILLAGE)
    subqw #2,%sp
    pea %a2@
    pea %a3@(0xa,%d3:w:8)
    bsrl DELTARGB
    movew %sp@+,%d1
    cmpw %a2@(8),%d1
    jbls CORRELATE_8A
    lea %a3@(0x8,%d3:w:8),%a0
    movel %a2@,%a0@(2)
    movew %a2@(4),%a0@(6)
    bset #5,%a0@
    subqw #4,%sp
    jsr @(0x16a0,%za0)@(0)	| 4083DF5E
    movel %sp@+,%a3@
    addqw #1,%fp@(-82)
CORRELATE_8A:           /* done */
    bset #15,%a2@(10)
CORRELATE_90:           /* next; then the others */
    lea %a2@(16),%a2
    addqw #1,%d4
    cmpw %fp@(-14),%d4
    jblt CORRELATE_22
    moveal %fp@(-12),%a2
    lea %a2@(16),%a2
    moveq #0,%d7
    moveq #0,%d4
    movew %fp@(-70),%d5
CORRELATE_AC:           /* each tolerant entry not done: the nearest color within tolerance? */
    tstw %a2@(10)
    jbmi CORRELATE_13E
    btst #1,%a2@(7)
    beqw CORRELATE_13E
    movew %a2@(8),%d6
    cmpiw #33,%fp@(-78)
    jblt CORRELATE_D6
    btst #31,%d4
    jbeq CORRELATE_D6
    cmpiw #1024,%d6
    jbls CORRELATE_FC
CORRELATE_D6:           /* Color2Index and the distance */
    subqw #4,%sp
    pea %a2@
    jsr @(0x16cc,%za0)@(0)	| 4083DFBA
    movel %sp@+,%d7
    subqw #2,%sp
    pea %a2@
    pea %a3@(0xa,%d7:w:8)
    bsrl DELTARGB
    cmpw %sp@+,%d6
    jbcc CORRELATE_138
    bftst %fp@(-116),%d7,1
    jbeq CORRELATE_114
CORRELATE_FC:           /* too far: a free index (or take one) */
    subqw #2,%sp
    jbsr GIMMEINDEX
    movew %sp@+,%d7
    jbeq CORRELATE_14C
    bftst %fp@(-116),%d7,1
    jbne CORRELATE_FC
    movew %d7,%sp@-
    jsr %pc@(PILLAGE)
CORRELATE_114:          /* set the device color to the entry's RGB, new seed */
    lea %a3@(0x8,%d7:w:8),%a0
    movel %a2@,%a0@(2)
    movew %a2@(4),%a0@(6)
    bset #5,%a0@
    subqw #4,%sp
    jsr @(0x16a0,%za0)@(0)	| 4083E008
    movel %sp@+,%a3@
    addqw #1,%fp@(-82)
    bset #31,%d4
CORRELATE_138:          /* mark the index used */
    bfset %fp@(-116),%d7,1
CORRELATE_13E:          /* next */
    lea %a2@(16),%a2
    addqw #1,%d4
    cmpw %fp@(-14),%d4
    jbne CORRELATE_AC
CORRELATE_14C:          /* unlock */
    moveal %fp@(-40),%a0
    _HUnlock
CORRELATE_152:          /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a3
    rts
    .long   0x00000000, 0x00000000	| 4083E038
/* DISPOSEAPPPALETTES: DisposeAppPalettes: dispose of the palettes of the quitting application */
DISPOSEAPPPALETTES:
    moveml %d0-%d3/%a0-%a3,%sp@-
    moveal 0xdc8,%a2
    cmpal MinusOne,%a2
    beqw DISPOSEAPPPALETTES_50
    moveal %a2@,%a1
    moveal %a1@(4),%a0
    _HLock
    moveal %a0@,%a3
    movew %a1@(8),%d3
    beqs DISPOSEAPPPALETTES_48
    addw %a1@(10),%d3
    clrl WindowList
    bras DISPOSEAPPPALETTES_44
DISPOSEAPPPALETTES_2A:  /* each recorded palette in the application heap: DisposePalette */
    movel %a3@,%d1
    beqs DISPOSEAPPPALETTES_42
    cmpl ApplZone,%d1
    bcss DISPOSEAPPPALETTES_42
    cmpl HeapEnd,%d1
    bccs DISPOSEAPPPALETTES_42
    movel %d1,%sp@-
    jsr @(0x184c,%za0)@(0)	| 4083E07C
DISPOSEAPPPALETTES_42:  /* next */
    addqw #8,%a3
DISPOSEAPPPALETTES_44:  /* until the last */
    dbf %d3,DISPOSEAPPPALETTES_2A
DISPOSEAPPPALETTES_48:  /* unlock the list */
    moveal %a2@,%a1
    moveal %a1@(4),%a0
    _HUnlock
DISPOSEAPPPALETTES_50:  /* no application palette; return */
    clrl 0xdcc
    moveml %sp@+,%d0-%d3/%a0-%a3
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 4083E09E

/* DEVSETENTRIES: DevSetEntries: SetEntries on the device at a0 (made current for the call) */
DEVSETENTRIES:
    movel %a2,%sp@-
    movel TheGDevice,%sp@-
    moveal %a0@,%a2
    moveal %a2@(22),%a2
    moveal %a2@,%a2
    moveal %a2@(42),%a2
    moveal %a2@,%a2
    movel %a2@,%sp@-
    movel %a0,TheGDevice
    clrw %sp@-
    movew %a2@(6),%sp@-
    pea %a2@(8)
    jsr @(0x16fc,%za0)@(0)	| 4083E0C4
    movel %sp@+,%a2@
    movel %sp@+,TheGDevice
    moveal %sp@+,%a2
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4083E0D4

/* DISPOSEPALETTE: _DisposePalette. */
trap_DisposePalette:
DISPOSEPALETTE:
    linkw %fp,#0
    movel %a2,%sp@-
    moveal %fp@(8),%a2
    cmpaw #0,%a2
    jbeq DISPOSEPALETTE_22
    movel %a2,%sp@-
    jsr %pc@(CLEARPALETTE)
    jbne DISPOSEPALETTE_22
    movel %a2,%sp@-
    jsr %pc@(ERASEPALETTE)
    moveal %a2,%a0
    _DisposHandle
DISPOSEPALETTE_22:      /* return */
    moveal %sp@+,%a2
    unlk %fp
    rtd #4
    .byte   0x00, 0x00, 0x00, 0x00, 0x00	| 4083E10A
DISPOSEPALETTE_2F:      /* depth to table index (data) */
    .byte   0x00	| 4083E10F
    .byte   0x00, 0x01, 0x02, 0x03, 0x04, 0x00, 0x00, 0x05, 0x06	| 4083E110
DISPOSEPALETTE_39:      /* depth to clut id (data) */
    .byte   0x01, 0x22, 0x42, 0x24, 0x44, 0x28, 0x08	| 4083E119

/* GETCLUT: GetClut(device): a copy, in the system heap, of the device's default color table for its depth */
GETCLUT:
    linkw %fp,#-6
    moveml %d0-%d3/%a0-%a1,%sp@-
    .short  0xA11A	| 4083E128 _GetZone (flags 0x0100)
    movel %a0,%fp@(-4)
    moveal SysZone,%a0
    _SetZone
    moveal %fp@(8),%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a1
    moveal %a1@,%a1
    movew %a1@(32),%d0
    cmpiw #1,%d0
    jbeq GETCLUT_34
    btst #0,%a0@(21)
    jbeq GETCLUT_34
    addqw #1,%d0
GETCLUT_34:             /* the cached table for the depth; dispose of the old */
    lea %pc@(DISPOSEPALETTE_2F),%a1
    moveb %a1@(0x0,%d0:w),%d0
    movew %d0,%fp@(-6)
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    moveal %a0@(0x1c,%d0:w:4),%a0
    movel %a0,%d1
    jbeq GETCLUT_5E
    movel %a0@,%d1
    jbeq GETCLUT_58
    movel %a0,%fp@(12)
    jbra GETCLUT_BA
GETCLUT_58:             /* _DisposHandle */
    _DisposHandle
    movew %fp@(-6),%d0
GETCLUT_5E:             /* GetCTable for the depth */
    lea %pc@(DISPOSEPALETTE_39),%a0
    moveq #0,%d3
    moveb %a0@(0x0,%d0:w),%d3
    subqw #4,%sp
    movew %d3,%sp@-
    jsr @(0x1660,%za0)@(0x0)	| 4083E18C
    moveal %sp@+,%a0
    movel %a0,%fp@(12)
    jbeq GETCLUT_BA
    moveal %a0@,%a1
    cmpl %a1@,%d3
    jbne GETCLUT_A8
    subqw #4,%sp
    movel #1668052340,%sp@-
    movew %d3,%sp@-
    movel %a0,%d3
    movew #-1,ROMMapInsert
    jsr @(0xe7c,%za0)@(0)	| 4083E1B2
    movel %sp@+,%d2
    jbeq GETCLUT_A6
    movel %d2,%fp@(12)
    moveal %d3,%a0
    _DisposHandle
    jbra GETCLUT_AA
GETCLUT_A6:             /* purgeable */
    moveal %d3,%a0
GETCLUT_A8:             /* _HPurge */
    _HPurge
GETCLUT_AA:             /* cache it */
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    movew %fp@(-6),%d0
    movel %fp@(12),%a0@(0x1c,%d0:w:4)
GETCLUT_BA:             /* restore the zone */
    moveal %fp@(-4),%a0
    _SetZone
    moveml %sp@+,%d0-%d3/%a0-%a1
    unlk %fp
    rtd #4
    .short  0x0000, 0x0000, 0x0000	| 4083E1EA

/* INITPALETTES: _InitPalettes. */
trap_InitPalettes:
INITPALETTES:
    linkw %fp,#0
    moveml %d3-%d4/%a2-%a4,%sp@-
    movel 0xdc8,%d0
    cmpil #-1,%d0
    jbne INITPALETTES_146
    movel #312,%d4
    movel %d4,%d0
    .short  0xA722	| 4083E20E _NewHandle (flags 0x0700)
    jbne INITPALETTES_1E2
    moveal %a0,%a3
    movel %a0,0xdc8
    moveq #0,%d3
    moveal %a3@,%a4
    clrl %a4@(16)
    clrl %a4@(20)
    lea %a4@(56),%a4
    clrl %sp@-
    jsr @(0x16a4,%za0)@(0)	| 4083E22C
    moveal %sp@+,%a2
    jbra INITPALETTES_6C
INITPALETTES_46:        /* count the devices with the "has palette" flag (bit 13) */
    moveal %a2@,%a0
    movew %a0@(20),%d0
    btst #13,%d0
    jbeq INITPALETTES_68
    addqw #1,%d3
    movel %a2,%a4@
    clrl %a4@(4)
    addqw #8,%a4
    addil #1024,%d4
    cmpiw #32,%d3
    jbpl INITPALETTES_70
INITPALETTES_68:        /* next device */
    moveal %a0@(30),%a2
INITPALETTES_6C:        /* more? */
    movel %a2,%d0
    jbne INITPALETTES_46
INITPALETTES_70:        /* the header: device count, list size */
    moveal %a3@,%a4
    movew %d3,%a4@
    movew %d3,%d0
    jbne INITPALETTES_7A
    addqw #1,%d0
INITPALETTES_7A:        /* size it; failure: no Palette Manager */
    lslw #2,%d0
    movew %d0,%a4@(2)
    clrw %a4@(8)
    movew #16,%a4@(10)
    movel %d4,%d0
    moveal %a3,%a0
    _SetHandleSize
    jbne INITPALETTES_9E
    moveq #16,%d0
    lslw #3,%d0
    .short  0xA722	| 4083E286 _NewHandle (flags 0x0700)
    jbeq INITPALETTES_AA
    moveal %a3,%a0
    _DisposHandle
INITPALETTES_9E:        /* PMgrHandle = -1 */
    movel #-1,0xdc8
    jbra INITPALETTES_1E2
INITPALETTES_AA:        /* the palette list */
    moveal %a3@,%a4
    movel %a0,%a4@(4)
    moveal %a3,%a0
    _HLock
    moveal %a3@,%a4
    lea %a4@(28),%a0
    moveq #6,%d0
INITPALETTES_BC:        /* clear the caches */
    clrl %a0@+
    dbf %d0,INITPALETTES_BC
    movew %d3,%d0
    lslw #8,%d0
    lea %a4@(312),%a0
    jbra INITPALETTES_CE
INITPALETTES_CC:        /* clear the link table (256 per device) */
    clrl %a0@+
INITPALETTES_CE:        /* the system palette (GetNewPalette 0) in the system heap */
    dbf %d0,INITPALETTES_CC
    movel TheZone,%sp@-
    movel SysZone,TheZone
    clrl %sp@-
    clrw %sp@-
    jsr @(0x1848,%za0)@(0x0)	| 4083E2D0
    movel %sp@+,%a4@(12)
    jbne INITPALETTES_114
    lea %pc@(MASKEND),%a0
    moveq #24,%d0
    jsr @(0x158c,%za0)@(0)	| 4083E2E2
    movel %a0,%d3
    clrl %sp@-
    movew #2,%sp@-
    movel %a0,%sp@-
    clrw %sp@-
    clrw %sp@-
    jsr @(0x1844,%za0)@(0x0)	| 4083E2F6
    movel %sp@+,%a4@(12)
    moveal %d3,%a0
    _DisposHandle
INITPALETTES_114:       /* mark it */
    moveal %a4@(12),%a0
    cmpaw #0,%a0
    jbeq INITPALETTES_12C
    moveal %a0@,%a0
    bset #15,%a0@(6)
    bset #14,%a0@(6)
INITPALETTES_12C:       /* check the devices, scatter */
    movel %sp@+,TheZone
    moveal %a3,%a0
    _HUnlock
    jsr %pc@(CHECKALLDEVICECLUTS)
    movew #1,%sp@-
    jsr %pc@(SCATTERDEVICES)
    clrl 0xdcc
    jbra INITPALETTES_156
INITPALETTES_146:       /* already set up: the application palette left over? */
    movel 0xdcc,%d0
    jbeq INITPALETTES_156
    addql #1,%d0
    jbne INITPALETTES_1DA
    clrl 0xdcc
INITPALETTES_156:       /* the application's 'pltt' 0 resource as its default palette */
    tstw CurApRefNum
    jbeq INITPALETTES_1DA
    clrw %sp@-
    jsr @(0x1450,%za0)@(0x0)	| 4083E34E
    movew %sp@+,%d3
    cmpw CurApRefNum,%d3
    jbeq INITPALETTES_182
    movew CurApRefNum,%sp@-
    jsr @(0x1460,%za0)@(0x0)	| 4083E360
    clrw %sp@-
    jsr @(0x14bc,%za0)@(0)	| 4083E368
    movew %sp@+,%d0
    jbne INITPALETTES_1DA
INITPALETTES_182:       /* get it */
    clrl %sp@-
    movel #1886155892,%sp@-
    clrw %sp@-
    jsr @(0xe7c,%za0)@(0)	| 4083E37C
    moveal %sp@+,%a2
    movel %a2,%d0
    jbeq INITPALETTES_1CC
    movel %a2,%sp@-
    jsr @(0x1448,%za0)@(0x0)	| 4083E38A
    moveal %a2@,%a0
    movew #-16384,%d1
    movew %a0@(2),%d0
    jbpl INITPALETTES_1B0
    addw %d0,%d0
    movew %d0,%d1
INITPALETTES_1B0:       /* record it */
    movew %d1,%a0@(6)
    movel %a2,%sp@-
    jsr %pc@(RECORDPALETTE)
    jbne INITPALETTES_1CC
    movel %a2,0xdcc
    moveal %a2@,%a0
    bset #12,%a0@(6)
    clrl %a0@(8)
INITPALETTES_1CC:       /* restore the resource file */
    cmpw CurApRefNum,%d3
    jbeq INITPALETTES_1DA
    movew %d3,%sp@-
    jsr @(0x1460,%za0)@(0x0)	| 4083E3C4
INITPALETTES_1DA:       /* hook ExitToShell, update */
    jsr %pc@(INSTALLMYEXITTOSHELL)
    jsr %pc@(UPDATEDEVICES)
INITPALETTES_1E2:       /* restore registers, return */
    moveml %sp@+,%d3-%d4/%a2-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000	| 4083E3DA

/* CHECKDEVICECOLORS: CheckDeviceColors(device): has an active indexed device's color table changed? (seed compare) */
CHECKDEVICECOLORS:
    linkw %fp,#0
    moveml %d0-%d2/%a0-%a3,%sp@-
    clrw %d2
    moveal %fp@(8),%a2
    moveal %a2@,%a3
    tstw %a3@(4)
    jbne CHECKDEVICECOLORS_6A
    tstw %a3@(20)
    jbpl CHECKDEVICECOLORS_6A
    subqw #4,%sp
    movel %a2,%sp@-
    jsr %pc@(GETCLUT)
    moveal %sp@+,%a0
    moveal %a0@,%a0
    lea %a0@(10),%a0
    moveal %a3@(22),%a1
    moveal %a1@,%a1
    moveal %a1@(42),%a1
    moveal %a1@,%a1
    movew %a1@(6),%d0
    lea %a1@(8),%a1
CHECKDEVICECOLORS_40:   /* compare each entry with the saved table */
    btst #6,%a1@
    jbne CHECKDEVICECOLORS_62
    bset #3,%a1@
    movel %a0@,%d1
    cmpl %a1@(2),%d1
    jbne CHECKDEVICECOLORS_5C
    movew %a0@(4),%d1
    cmpw %a1@(6),%d1
    jbeq CHECKDEVICECOLORS_62
CHECKDEVICECOLORS_5C:   /* changed */
    bset #4,%a1@
    moveq #-1,%d2
CHECKDEVICECOLORS_62:   /* next */
    addqw #8,%a0
    addqw #8,%a1
    dbf %d0,CHECKDEVICECOLORS_40
CHECKDEVICECOLORS_6A:   /* result */
    movew %d2,%fp@(12)
    moveml %sp@+,%d0-%d2/%a0-%a3
    unlk %fp
    rtd #4
    .long   0x00000000, 0x00000000	| 4083E458

/* FINDLINK: FindLink: the palette entry linked to a device index, if any */
FINDLINK:
    linkw %a4,#0
    movel %d3,%sp@-
    clrw %a4@(10)
    movew %a4@(8),%d0
    bfextu %d0,16,3,%d1
    cmpiw #4,%d1
    jbne FINDLINK_4C
    movew %fp@(-34),%d3
    moveal %fp@(-18),%a0
    addaw #312,%a0
    jbra FINDLINK_3E
FINDLINK_26:            /* walk the chain: this device? */
    bfextu %d0,19,5,%d1
    bfextu %d0,24,8,%d2
    cmpw %fp@(-28),%d1
    jbeq FINDLINK_44
    lslw #8,%d1
    addw %d2,%d1
    movew %a0@(0x0,%d1:l:4),%d0
    jbpl FINDLINK_4C
FINDLINK_3E:            /* next */
    dbf %d3,FINDLINK_26
    jbra FINDLINK_4C
FINDLINK_44:            /* the index */
    andiw #255,%d2
    movew %d2,%a4@(10)
FINDLINK_4C:            /* return */
    movel %sp@+,%d3
    unlk %a4
    rtd #2
    .long   0x00000000, 0x00000000, 0x00000000	| 4083E4B4

/* ANALYZEDEV: AnalyzeDev: for the current device, which indexes are free, reserved or used by the palette */
ANALYZEDEV:
    moveml %d3-%d5/%a2-%a3,%sp@-
    lea %fp@(-116),%a2
    moveal %fp@(-40),%a3
    moveal %a3@,%a3
    moveq #0,%d3
    movew %fp@(-70),%d3
    clrw %d4
    jbsr ANALYZEDEV_FA
    moveal %fp@(-12),%a0
    moveq #0,%d0
    moveq #0,%d2
    lea %a0@(16),%a1
    jbra ANALYZEDEV_42
ANALYZEDEV_28:          /* mark the indexes the palette's explicit entries use */
    movew %a1@(10),%d1
    jbmi ANALYZEDEV_3C
    btst #3,%d1
    jbeq ANALYZEDEV_3C
    movew %d0,%d2
    andw %d3,%d2
    bfset %a2@,%d2,1
ANALYZEDEV_3C:          /* next */
    lea %a1@(16),%a1
    addqw #1,%d0
ANALYZEDEV_42:          /* until the last; then list the free indexes */
    cmpw %a0@,%d0
    jbcs ANALYZEDEV_28
    moveal %fp@(-64),%a1
    movew %d3,%d0
    moveq #0,%d1
ANALYZEDEV_4E:          /* each index */
    movew %d0,%d1
    btst #4,%d3
    jbeq ANALYZEDEV_58
    rorb #4,%d1
ANALYZEDEV_58:          /* unused and not reserved: free */
    bftst %a2@,%d1,1
    jbne ANALYZEDEV_72
    movew %a3@(0x8,%d1:w:8),%d2
    andiw #24576,%d2
    jbne ANALYZEDEV_72
    bfset %a2@,%d1,1
    movew %d1,%a1@(0x0,%d4:w:2)
    addqw #1,%d4
ANALYZEDEV_72:          /* next; then the unprotected ones */
    dbf %d0,ANALYZEDEV_4E
    movew %d3,%d0
ANALYZEDEV_78:          /* each index */
    movew %d0,%d1
    btst #4,%d3
    jbeq ANALYZEDEV_82
    rorb #4,%d1
ANALYZEDEV_82:          /* not protected: usable */
    bftst %a2@,%d1,1
    jbne ANALYZEDEV_9A
    btst #6,%a3@(0x8,%d1:w:8)
    jbne ANALYZEDEV_9A
    bfset %a2@,%d1,1
    movew %d1,%a1@(0x0,%d4:w:2)
    addqw #1,%d4
ANALYZEDEV_9A:          /* next; then the ones held by other palettes */
    dbf %d0,ANALYZEDEV_78
    movew %a0@(6),%d5
    andiw #4095,%d5
    moveal %fp@(-18),%a0
    addaw #312,%a0
    movew %d3,%d0
ANALYZEDEV_B0:          /* each index */
    movew %d0,%d1
    btst #4,%d3
    jbeq ANALYZEDEV_BA
    rorb #4,%d1
ANALYZEDEV_BA:          /* its chain */
    bftst %a2@,%d1,1
    jbne ANALYZEDEV_E6
    movew %fp@(-28),%d2
    lslw #8,%d2
    moveb %d1,%d2
ANALYZEDEV_C8:          /* held by another palette: usable */
    andiw #8191,%d2
    movew %a0@(0x0,%d2:w:4),%d2
    jbeq ANALYZEDEV_E6
    jbmi ANALYZEDEV_C8
    andiw #8191,%d2
    cmpw %d2,%d5
    jbeq ANALYZEDEV_E6
    bfset %a2@,%d1,1
    movew %d1,%a1@(0x0,%d4:w:2)
    addqw #1,%d4
ANALYZEDEV_E6:          /* next; the list count */
    dbf %d0,ANALYZEDEV_B0
    movew %d4,%fp@(-80)
    clrw %fp@(-84)
    jbsr ANALYZEDEV_FA
    moveml %sp@+,%d3-%d5/%a2-%a3
    rts

ANALYZEDEV_FA:          /* clear the bit map; mark black and white */
    moveq #7,%d0
ANALYZEDEV_FC:          /* clear */
    clrl %fp@(0xffffffffffffff8c,%d0:w:4)
    dbf %d0,ANALYZEDEV_FC
    bfset %fp@(-116),0,1
    bfset %fp@(-116),%d3,1
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083E5D2

/* PILLAGE: Pillage: take a device index from its current owner for this palette (ZAPLINKS on it) */
PILLAGE:
    linkw %a4,#0
    moveml %d3-%d4,%sp@-
    movew %a4@(8),%d3
    movew %fp@(-28),%d4
    lslw #8,%d4
    moveb %d3,%d4
    movew %d4,%sp@-
    jbsr ZAPLINKS
    moveal %fp@(-40),%a0
    moveal %a0@,%a0
    clrw %a0@(0x8,%d3:w:8)
    moveml %sp@+,%d3-%d4
    unlk %a4
    rtd #2
    .short  0x0000	| 4083E60E

/* GIMMEINDEX: GimmeIndex: the next free device index from the list built by ANALYZEDEV; 0 when none left */
GIMMEINDEX:
    clrw %d1
    movew %fp@(-84),%d0
    cmpw %fp@(-80),%d0
    jbeq GIMMEINDEX_18
    moveal %fp@(-64),%a0
    movew %a0@(0x0,%d0:w:2),%d1
    addqw #1,%fp@(-84)
GIMMEINDEX_18:          /* return it */
    movew %d1,%sp@(4)
    rts
    .short  0x0000	| 4083E62E

/* MARKDEVUBIT: MarkDevUBit: mark the current device as needing an update (bit in the Palette Manager's device mask, +20) */
MARKDEVUBIT:
    movew %fp@(-28),%d0
    moveal %fp@(-18),%a0
    movel %a0@(20),%d1
    bset %d0,%d1
    movel %d1,%a0@(20)
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4083E644

/* REDRAWDESKTOP: RedrawDesktop: repaint the desktop and windows after colors changed */
REDRAWDESKTOP:
    subqw #4,%sp
    jsr @(0x1160,%za0)@(0x0)	| 4083E652
    moveal %sp@,%a3
    movel %a2,%sp@-
    jsr @(0x117c,%za0)@(0)	| 4083E65C
    clrl %sp@-
    movel %a3,%sp@-
    jsr @(0x1230,%za0)@(0x0)	| 4083E666
    movel %a3,%sp@-
    jsr @(0x1164,%za0)@(0x0)	| 4083E66E
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083E676

/* DIRTYSEEDS: DirtySeeds(pal): mark the palette changed and every device's color table seed stale */
DIRTYSEEDS:
    linkw %fp,#0
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    movew %a0@(2),%d0
    lsrw #2,%d0
    subqw #1,%d0
    moveal %fp@(8),%a0
    moveal %a0@,%a0
    bset #13,%a0@(6)
    moveal %a0@(12),%a0
    moveal %a0@,%a0
DIRTYSEEDS_24:          /* clear the cached seeds */
    clrl %a0@+
    dbf %d0,DIRTYSEEDS_24
    unlk %fp
    rtd #4

/* SETPALETTE: _SetPalette. */
trap_SetPalette:
SETPALETTE:
    linkw %fp,#0
    movel %d3,%sp@-
    moveal 0xdc8,%a1
    cmpaw #-1,%a1
    jbeq SETPALETTE_E8
    moveal %fp@(14),%a0
    cmpaw #-1,%a0
    jbne SETPALETTE_70
    movel 0xdcc,%d0
    jbeq SETPALETTE_36
    moveal %d0,%a0
    moveal %a0@,%a0
    btst #12,%a0@(6)
    jbeq SETPALETTE_36
    movel %d0,%sp@-
    jsr @(0x184c,%za0)@(0)	| 4083E6E0
SETPALETTE_36:          /* the application palette (window -1) */
    moveal %fp@(10),%a0
    movel %a0,0xdcc
    jbeq SETPALETTE_54
    moveal %a0@,%a0
    bset #14,%a0@(6)
    bset #15,%a0@(6)
    moveal %fp@(10),%a0
    jbra SETPALETTE_60
SETPALETTE_54:          /* none: the system palette */
    moveal %a1@,%a0
    moveal %a0@(12),%a0
    movel %a0,%d0
    jbeq SETPALETTE_E8
SETPALETTE_60:          /* mark it changed, activate the front window's */
    movel %a0,%sp@-
    jbsr DIRTYSEEDS
    clrl %sp@-
    jsr @(0x1290,%za0)@(0x0)	| 4083E718
    jbra SETPALETTE_E2
SETPALETTE_70:          /* a color window: its palette */
    tstw %a0@(6)
    jbpl SETPALETTE_E8
    movel %fp@(10),%d0
    moveal %a0@(8),%a1
    moveal %a1@,%a1
    movel %a1@(12),%d3
    movel %d0,%a1@(12)
    jbeq SETPALETTE_BE
    moveal %d0,%a1
    moveal %a1@,%a1
    bclr #14,%a1@(6)
    bset #15,%a1@(6)
    tstb %fp@(8)
    jbeq SETPALETTE_BE
    jbpl SETPALETTE_B8
    btst #14,%fp@(8)
    jbne SETPALETTE_B0
    bclr #15,%a1@(6)
SETPALETTE_B0:          /* cUpdates flag */
    btst #13,%fp@(8)
    jbeq SETPALETTE_BE
SETPALETTE_B8:          /* set */
    bset #14,%a1@(6)
SETPALETTE_BE:          /* changed? update the old one, activate */
    cmpl %d0,%d3
    jbeq SETPALETTE_E8
    movel %a0,%sp@-
    tstl %d3
    jbeq SETPALETTE_E2
    movel %d3,%sp@-
    jsr %pc@(UPDATEPALETTE)
    moveal %d3,%a0
    moveal %a0@,%a0
    btst #12,%a0@(6)
    jbeq SETPALETTE_E2
    movel %d3,%sp@-
    jsr @(0x184c,%za0)@(0)	| 4083E78C
SETPALETTE_E2:          /* ActivatePalette */
    jsr @(0x1850,%za0)@(0x0)	| 4083E792
SETPALETTE_E8:          /* return */
    movel %sp@+,%d3
    unlk %fp
    rtd #10

/* GETPALETTE: _GetPalette. */
trap_GetPalette:
GETPALETTE:
    linkw %fp,#0
    clrl %fp@(12)
    moveal 0xdc8,%a1
    cmpaw #-1,%a1
    jbeq GETPALETTE_82
    moveal %fp@(8),%a0
    cmpaw #0,%a0
    jbeq GETPALETTE_82
    cmpaw #-1,%a0
    jbne GETPALETTE_64
    movel 0xdcc,%fp@(12)
    jbne GETPALETTE_82
    moveal %a1@,%a1
    moveal %a1@(12),%a0
    movel %a0,%d0
    jbeq GETPALETTE_82
    jsr @(0x1584,%za0)@(0x0)	| 4083E7D4
    tstw %d0
    jbne GETPALETTE_82
    movel %a0,0xdcc
    movel %a0,%fp@(12)
    movel %a0,%sp@-
    moveal %a0@,%a0
    clrl %a0@(12)
    bclr #12,%a0@(6)
    jsr %pc@(RECORDPALETTE)
    jbeq GETPALETTE_82
    clrl 0xdcc
    clrl %fp@(12)
    jbra GETPALETTE_82
GETPALETTE_64:          /* the window's palette */
    tstw %a0@(6)
    jbpl GETPALETTE_82
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    moveal %a0@(12),%a0
    movel %a0,%fp@(12)
    jbeq GETPALETTE_82
    moveal %a0@,%a0
    bclr #12,%a0@(6)
GETPALETTE_82:          /* return */
    unlk %fp
    rtd #4
    .long   0x00000000, 0x00000000	| 4083E828
/* FINDINDEX: FindIndex: the device index of a palette entry */
FINDINDEX:
    moveml %d3-%d4,%sp@-
    movew %a3@(12),%d0
    bfextu %d0,16,3,%d1
    cmpiw #4,%d1
    bnes FINDINDEX_5A
    moveal 0xdc8,%a0
    cmpaw #-1,%a0
    beqs FINDINDEX_5A
    moveal %a0@,%a0
    movew %a0@,%d3
    beqs FINDINDEX_5A
    lea %a0@(56),%a1
    bras FINDINDEX_32
FINDINDEX_28:           /* find the current device in the Palette Manager's list */
    movel %a1@(0x0,%d3:w:8),%d4
    cmpl TheGDevice,%d4
    beqs FINDINDEX_38
FINDINDEX_32:           /* next device; not there: 0 */
    dbf %d3,FINDINDEX_28
    bras FINDINDEX_5A
FINDINDEX_38:           /* walk the entry's link chain */
    movew %a0@,%d4
    addaw #312,%a0
    bras FINDINDEX_56
FINDINDEX_40:           /* a link on this device? its index */
    bfextu %d0,19,5,%d1
    bfextu %d0,24,8,%d2
    cmpw %d3,%d1
    beqs FINDINDEX_5C
    lslw #8,%d1
    addw %d2,%d1
    movew %a0@(0x0,%d1:l:4),%d0
    bpls FINDINDEX_5A
FINDINDEX_56:           /* next link */
    dbf %d4,FINDINDEX_40
FINDINDEX_5A:           /* none */
    bras FINDINDEX_7A
FINDINDEX_5C:           /* the index, if within the device's table */
    andiw #255,%d2
    movew %d2,%d0
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    cmpw %a0@(6),%d0
    blts FINDINDEX_7C
FINDINDEX_7A:           /* 0 */
    moveq #0,%d0
FINDINDEX_7C:           /* return */
    moveml %sp@+,%d3-%d4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083E8B2
/* ENTRY2INDEX: Entry2Index: Palette2CTab helper: palette entry to device index */
ENTRY2INDEX:
    linkw %fp,#-4
    moveml %a2-%a3,%sp@-
    movew #1,QDErr
    clrl %fp@(10)
    moveal 0xdc8,%a1
    cmpaw #-1,%a1
    beqw ENTRY2INDEX_D0
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(6)
    bplw ENTRY2INDEX_D0
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    moveal %a0@(12),%a2
    movel %a2,%d0
    bnes ENTRY2INDEX_42
    moveal 0xdcc,%a2
    movel %a2,%d0
    beqw ENTRY2INDEX_D0
ENTRY2INDEX_42:         /* the entry: in range? */
    movel %a2,%fp@(-4)
    moveal %a2,%a0
    _HLock
    moveal %a2@,%a2
    moveq #0,%d0
    movew %fp@(8),%d0
    cmpw %a2@,%d0
    bccw ENTRY2INDEX_CA
    asll #4,%d0
    lea %a2@(0x10,%d0:l),%a3
    clrl %sp@-
    pea %a3@
    btst #2,%a3@(7)
    beqs ENTRY2INDEX_6C
    addql #1,%sp@
ENTRY2INDEX_6C:         /* default: Color2Index of its RGB; an indexed device with the Palette Manager? */
    jsr @(0x16cc,%za0)@(0)	| 4083E92C
    movel %sp@+,%fp@(10)
    clrw QDErr
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    movew %a0@(4),%d1
    beqs ENTRY2INDEX_8A
    subqw #1,%d1
    bnes ENTRY2INDEX_CA
ENTRY2INDEX_8A:         /* active device: animating entries use their reserved index (FINDINDEX) */
    tstw %a0@(20)
    bpls ENTRY2INDEX_CA
    movew %a3@(6),%d1
    moveq #0,%d0
    movew %fp@(8),%d0
    btst #2,%d1
    beqs ENTRY2INDEX_AA
    jsr %pc@(FINDINDEX)
    tstw %d0
    beqs ENTRY2INDEX_CA
    bras ENTRY2INDEX_C6
ENTRY2INDEX_AA:         /* explicit entries (not tolerant): the entry number modulo the table size */
    btst #3,%d1
    beqs ENTRY2INDEX_CA
    btst #1,%d1
    bnes ENTRY2INDEX_CA
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    andw %a0@(6),%d0
ENTRY2INDEX_C6:         /* the result */
    movel %d0,%fp@(10)
ENTRY2INDEX_CA:         /* unlock */
    moveal %fp@(-4),%a0
    _HUnlock
ENTRY2INDEX_D0:         /* return */
    moveml %sp@+,%a2-%a3
    unlk %fp
    rtd #2
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 4083E99E
/* INDEX2ENTRIES: Index2Entries */
INDEX2ENTRIES:
    linkw %fp,#0
    moveml %d3-%d7/%a2,%sp@-
    moveal %a5@,%a0
    movel %a0@,%d0
    beqs INDEX2ENTRIES_6E
    subqw #4,%sp
    movel %d0,%sp@-
    jsr @(0x1858,%za0)@(0x0)	| 4083E9B2
    movel %sp@+,%d0
    beqs INDEX2ENTRIES_6E
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %a0@,%d4
    movel %fp@(8),%d0
    beqs INDEX2ENTRIES_6E
    moveal %d0,%a0
    _HGetState
    moveb %d0,%d3
    _HNoPurge
    _HUnlock
    movew %d4,%d0
    addw %d0,%d0
    addqw #2,%d0
    extl %d0
    _SetHandleSize
    _HLock
    moveal %a0@,%a2
    moveq #0,%d5
    movel %fp@(12),%d6
    bras INDEX2ENTRIES_5A
INDEX2ENTRIES_48:       /* each entry: does it map to the index (PaletteDispatch 0)? add it to the list */
    subqw #4,%sp
    movew %d4,%sp@-
    moveq #0,%d0
    _PaletteDispatch
    cmpl %sp@+,%d6
    bnes INDEX2ENTRIES_5A
    addqw #1,%d5
    movew %d4,%a2@(0x0,%d5:w:2)
INDEX2ENTRIES_5A:       /* next; size the list, restore the handle state */
    dbf %d4,INDEX2ENTRIES_48
    moveal %fp@(8),%a0
    movel %d5,%d0
    addl %d0,%d0
    addql #2,%d0
    _SetHandleSize
    moveb %d3,%d0
    _HSetState
INDEX2ENTRIES_6E:       /* return */
    moveml %sp@+,%d3-%d6/%a2
    unlk %fp
    rtd #6
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4083EA18

/* PMFORECOLOR: _PMForeColor. */
trap_PmForeColor:
PMFORECOLOR:
    moveq #1,%d0
    jbra PMBACKCOLOR_2

/* PMBACKCOLOR: _PMBackColor. */
trap_PmBackColor:
PMBACKCOLOR:
    moveq #0,%d0
PMBACKCOLOR_2:          /* PmForeColor (d0 = 0) / PmBackColor (d0 = 1): the entry's index on the device (PaletteDispatch 0) */
    linkw %fp,#-2
    movew %d0,%fp@(-2)
    clrl %sp@-
    movew %fp@(8),%sp@-
    moveq #0,%d0
    _PaletteDispatch
    movel %sp@+,%d0
    tstw QDErr
    jbne PMBACKCOLOR_5E
    moveal %a5@,%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a1
    moveal %a1@,%a1
    movel %d0,%sp@-
    tstw %fp@(-2)
    jbeq PMBACKCOLOR_44
    movel %d0,%a0@(80)
    movew %fp@(8),%a1@(16)
    bset #0,%a1@(25)
    pea %a0@(36)
    jbra PMBACKCOLOR_58
PMBACKCOLOR_44:         /* background: bkColor, the entry number and flag in grafVars */
    movel %d0,%a0@(84)
    movew %fp@(8),%a1@(22)
    bset #1,%a1@(25)
    pea %a0@(42)
PMBACKCOLOR_58:         /* RGBBackColor */
    jsr @(0x16d0,%za0)@(0)	| 4083EA7C
PMBACKCOLOR_5E:         /* return */
    unlk %fp
    rtd #2
    .long   0x00000000, 0x00000000	| 4083EA88

/* ANIMATEENTRY: _AnimateEntry. */
trap_AnimateEntry:
ANIMATEENTRY:
    linkw %fp,#-14
    moveml %d3-%d5/%a2-%a4,%sp@-
    moveal 0xdc8,%a3
    cmpaw #-1,%a3
    jbeq ANIMATEENTRY_120
    moveal %fp@(14),%a0
    cmpaw #0,%a0
    jbeq ANIMATEENTRY_120
    tstw %a0@(6)
    jbpl ANIMATEENTRY_120
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    moveal %a0@(12),%a2
    movel %a2,%d0
    jbne ANIMATEENTRY_40
    moveal 0xdcc,%a2
    movel %a2,%d0
    jbeq ANIMATEENTRY_120
ANIMATEENTRY_40:        /* the entry; animating? set its color on every device that holds it */
    moveal %a2@,%a0
    movew %a0@,%d0
    moveq #0,%d1
    movew %fp@(12),%d1
    cmpw %d0,%d1
    jbcc ANIMATEENTRY_120
    lslw #4,%d1
    lea %a0@(0x10,%d1:l),%a2
    btst #2,%a2@(7)
    jbeq ANIMATEENTRY_120
    moveal %fp@(8),%a0
    movel %a0@,%d0
    movel %d0,%fp@(-10)
    rorl #8,%d0
    moveb %d0,%a2@(2)
    swap %d0
    moveb %d0,%a2@
    movew %a0@(4),%d0
    movew %d0,%fp@(-6)
    rorw #8,%d0
    moveb %d0,%a2@(4)
    movew %a2@(12),%d3
    bfextu %d3,16,3,%d1
    cmpiw #4,%d1
    jbne ANIMATEENTRY_120
    moveal %a3,%a0
    _HLock
    movel TheGDevice,%fp@(-4)
    moveal %a3@,%a2
    movew %a2@,%d5
    lea %a2@(56),%a4
    addaw #312,%a2
    movew %d3,%d0
    jbra ANIMATEENTRY_112
ANIMATEENTRY_AC:        /* each link: device and index; SetEntries */
    bfextu %d0,19,5,%d3
    bfextu %d0,24,8,%d4
    moveal %a4@(0x0,%d3:w:8),%a0
    movel %a0,TheGDevice
    moveal %a0@,%a0
    clrw %a0@(2)
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    movew %a0@(6),%d0
    cmpw %d4,%d0
    jble ANIMATEENTRY_10A
    movel %a0@,%fp@(-14)
    movel %fp@(-10),%a0@(0xa,%d4:w:8)
    movew %fp@(-6),%a0@(0xe,%d4:w:8)
    movew %d4,%sp@-
    clrw %sp@-
    pea %a0@(0x8,%d4:w:8)
    jsr @(0x16fc,%za0)@(0)	| 4083EB7E
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    movel %fp@(-14),%a0@
ANIMATEENTRY_10A:       /* next link */
    lslw #8,%d3
    addw %d4,%d3
    movew %a2@(0x0,%d3:l:4),%d0
ANIMATEENTRY_112:       /* next; restore TheGDevice */
    dbpl %d5,ANIMATEENTRY_AC
    movel %fp@(-4),TheGDevice
    moveal %a3,%a0
    _HUnlock
ANIMATEENTRY_120:       /* return */
    moveq #0,%d0
    moveml %sp@+,%d3-%d5/%a2-%a4
    unlk %fp
    rtd #10
    .long   0x00000000	| 4083EBBC

/* ANIMATEPALETTE: _AnimatePalette. */
trap_AnimatePalette:
ANIMATEPALETTE:
    linkw %fp,#-138
    moveml %d3-%d6/%a2-%a4,%sp@-
    moveal 0xdc8,%a4
    cmpaw #-1,%a4
    jbeq ANIMATEPALETTE_188
    moveal %fp@(18),%a0
    cmpaw #0,%a0
    jbeq ANIMATEPALETTE_188
    tstw %a0@(6)
    jbpl ANIMATEPALETTE_188
    moveal %a0@(8),%a0
    moveal %a0@,%a0
    moveal %a0@(12),%a2
    movel %a2,%d0
    jbne ANIMATEPALETTE_40
    moveal 0xdcc,%a2
    movel %a2,%d0
    jbeq ANIMATEPALETTE_188
ANIMATEPALETTE_40:      /* the range */
    moveal %fp@(14),%a3
    movel %a3,%d0
    jbeq ANIMATEPALETTE_188
    moveal %a2@,%a2
    movew %a2@,%d0
    jbeq ANIMATEPALETTE_188
    moveq #0,%d3
    movew %fp@(10),%d3
    cmpw %d0,%d3
    jbcc ANIMATEPALETTE_188
    moveal %a3@,%a3
    movew %fp@(12),%d4
    cmpw %a3@(6),%d4
    jbhi ANIMATEPALETTE_188
    subw %d3,%d0
    movew %d0,%d5
    movew %a3@(6),%d0
    addqw #1,%d0
    subw %d4,%d0
    cmpw %d0,%d5
    jbls ANIMATEPALETTE_7E
    movew %d0,%d5
ANIMATEPALETTE_7E:      /* pinned to the palette */
    cmpw %fp@(8),%d5
    jbls ANIMATEPALETTE_88
    movew %fp@(8),%d5
ANIMATEPALETTE_88:      /* per-device copies, cleared */
    moveal %a4@,%a1
    movew %a1@,%d0
    movew %d0,%fp@(-10)
    lea %a1@(56),%a4
    lea %fp@(-138),%a0
    jbra ANIMATEPALETTE_9C
ANIMATEPALETTE_9A:      /* clear */
    clrl %a0@+
ANIMATEPALETTE_9C:      /* next */
    dbf %d0,ANIMATEPALETTE_9A
    addaw #312,%a1
    lsll #4,%d3
    lea %a2@(0x10,%d3:l),%a2
    lea %a3@(0x8,%d4:w:8),%a3
    jbra ANIMATEPALETTE_140
ANIMATEPALETTE_B2:      /* each animating entry: the new color into each device table it is linked to */
    btst #2,%a2@(7)
    beqw ANIMATEPALETTE_13A
    moveb %a3@(2),%a2@
    moveb %a3@(4),%a2@(2)
    moveb %a3@(6),%a2@(4)
    movew %a2@(12),%d0
    bfextu %d0,16,3,%d1
    cmpiw #4,%d1
    jbne ANIMATEPALETTE_13A
    movew %fp@(-10),%d6
    subqw #1,%d6
ANIMATEPALETTE_E0:      /* a device's table copy (made on first use) */
    bfextu %d0,19,5,%d3
    bfextu %d0,24,8,%d4
    lea %fp@(-138),%a0
    moveal %a0@(0x0,%d3:w:4),%a0
    cmpaw #0,%a0
    jbne ANIMATEPALETTE_114
    moveal %a4@(0x0,%d3:w:8),%a0
    moveal %a0@,%a0
    clrw %a0@(2)
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    movel %a0@(42),%d0
    lea %fp@(-138),%a0
    movel %d0,%a0@(0x0,%d3:w:4)
    moveal %d0,%a0
ANIMATEPALETTE_114:     /* set the entry */
    moveal %a0@,%a0
    movew %a0@(6),%d0
    cmpw %d4,%d0
    jble ANIMATEPALETTE_12E
    movew %a2@,%a0@(0xa,%d4:w:8)
    movew %a2@(2),%a0@(0xc,%d4:w:8)
    movew %a2@(4),%a0@(0xe,%d4:w:8)
ANIMATEPALETTE_12E:     /* next link */
    lslw #8,%d3
    addw %d4,%d3
    movew %a1@(0x0,%d3:l:4),%d0
    dbpl %d6,ANIMATEPALETTE_E0
ANIMATEPALETTE_13A:     /* next entry */
    addaw #16,%a2
    addql #8,%a3
ANIMATEPALETTE_140:     /* then SetEntries on each device changed */
    dbf %d5,ANIMATEPALETTE_B2
    movel TheGDevice,%fp@(-4)
    movew %fp@(-10),%d6
    lea %fp@(-138),%a2
    jbra ANIMATEPALETTE_17E
ANIMATEPALETTE_154:     /* this device */
    moveal %a2@+,%a3
    cmpaw #0,%a3
    jbeq ANIMATEPALETTE_17C
    movel %a4@,TheGDevice
    moveal %a3@,%a0
    movel %a0@,%fp@(-8)
    clrw %sp@-
    movew %a0@(6),%sp@-
    pea %a0@(8)
    jsr @(0x16fc,%za0)@(0)	| 4083ED30
    moveal %a3@,%a0
    movel %fp@(-8),%a0@
ANIMATEPALETTE_17C:     /* next */
    addql #8,%a4
ANIMATEPALETTE_17E:     /* until the last; restore */
    dbf %d6,ANIMATEPALETTE_154
    movel %fp@(-4),TheGDevice
ANIMATEPALETTE_188:     /* return */
    moveq #0,%d0
    moveml %sp@+,%d3-%d6/%a2-%a4
    unlk %fp
    rtd #14
    .long   0x00000000, 0x00000000, 0x00000000	| 4083ED54

/* GETENTRYCOLOR: _GetEntryColor. */
trap_GetEntryColor:
GETENTRYCOLOR:
    linkw %fp,#0
    moveal %fp@(14),%a0
    cmpaw #0,%a0
    jbeq GETENTRYCOLOR_2E
    moveal %a0@,%a0
    movew %a0@,%d0
    moveq #0,%d1
    movew %fp@(12),%d1
    cmpw %d0,%d1
    jbcc GETENTRYCOLOR_2E
    lsll #4,%d1
    lea %a0@(0x10,%d1:l),%a0
    moveal %fp@(8),%a1
    movel %a0@,%a1@
    movew %a0@(4),%a1@(4)
GETENTRYCOLOR_2E:       /* return */
    moveq #0,%d0
    unlk %fp
    rtd #10
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083ED96

/* SCATTERDEVICES: ScatterDevices: give reserved device indexes back, update the devices marked for it */
SCATTERDEVICES:
    linkw %fp,#0
    moveml %d1-%d5/%a0/%a2-%a4,%sp@-
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    movel %a0@(16),%d4
    jbeq SCATTERDEVICES_AE
    clrl %a0@(16)
    orl %d4,%a0@(20)
    movew %a0@,%d3
    subqw #1,%d3
    lea %a0@(56),%a2
SCATTERDEVICES_26:      /* each device marked: its default table */
    btst %d3,%d4
    beqw SCATTERDEVICES_AA
    subqw #4,%sp
    moveal %a2@(0x0,%d3:w:8),%a3
    movel %a3,%sp@-
    jsr %pc@(GETCLUT)
    moveal %sp@+,%a4
    moveal %a4@,%a4
    movel %a4@,%d2
    lea %a4@(10),%a4
    moveal %a3@,%a3
    moveal %a3@(22),%a3
    moveal %a3@,%a3
    moveal %a3@(42),%a3
    moveal %a3@,%a3
    movew %a3@(6),%d1
    lea %a3@(8),%a0
    clrw %d5
SCATTERDEVICES_5A:      /* count the entries in use */
    btst #3,%a0@
    jbeq SCATTERDEVICES_62
    addqw #1,%d5
SCATTERDEVICES_62:      /* entries freed: back to the default color */
    btst #4,%a0@
    jbeq SCATTERDEVICES_74
    clrw %a0@
    movel %a4@,%a0@(2)
    movew %a4@(4),%a0@(6)
SCATTERDEVICES_74:      /* next; too many: the default table */
    addqw #8,%a0
    addqw #8,%a4
    dbf %d1,SCATTERDEVICES_5A
    moveal %a2@(0x0,%d3:w:8),%a4
    cmpw %a3@(6),%d5
    jble SCATTERDEVICES_94
    movel %d2,%a3@
    moveal %a4@,%a0
    moveal %a0@(6),%a0
    moveal %a0@,%a0
    clrl %a0@
    jbra SCATTERDEVICES_9E
SCATTERDEVICES_94:      /* new seed */
    subqw #4,%sp
    jsr @(0x16a0,%za0)@(0)	| 4083EE36
    movel %sp@+,%a3@
SCATTERDEVICES_9E:      /* set them on the device */
    tstw %fp@(8)
    jbeq SCATTERDEVICES_AA
    moveal %a4,%a0
    jsr %pc@(DEVSETENTRIES)
SCATTERDEVICES_AA:      /* next device */
    dbf %d3,SCATTERDEVICES_26
SCATTERDEVICES_AE:      /* restore registers, return */
    moveml %sp@+,%d1-%d5/%a0/%a2-%a4
    unlk %fp
    rtd #2
    .short  0x0000, 0x0000, 0x0000	| 4083EE58
SCATTERDEVICES_BE:      /* data */
    .short  0x0000	| 4083EE5E
    .long   0x08090A0B, 0x00000C0D	| 4083EE60

/* SETDEV: SetDev: make the Palette Manager's device n current, set up its color table fields */
SETDEV:
    linkw %a4,#-12
    moveml %d3-%d5/%a2-%a3,%sp@-
    movew %fp@(-28),%d3
    moveal %fp@(-22),%a0
    moveal %a0@(0x0,%d3:w:8),%a0
    movel %a0,TheGDevice
    moveal %a0@,%a0
    tstw %a0@(4)
    jbne SETDEV_FA
    tstw %a0@(20)
    jbpl SETDEV_FA
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    movel %a0,%fp@(-40)
    moveal %a0@,%a0
    movew %a0@(6),%d0
    movew %d0,%fp@(-70)
    addqw #1,%d0
    movew %d0,%fp@(-36)
    movel %a0@,%d0
    moveal %fp@(-12),%a0
    btst #13,%a0@(6)
    jbne SETDEV_64
    moveal %a0@(12),%a0
    moveal %a0@,%a0
    cmpl %a0@(0x0,%d3:w:4),%d0
    jbeq SETDEV_FA
SETDEV_64:              /* the device's link table */
    moveal %fp@(-22),%a0
    lea %a0@(0x0,%d3:w:8),%a0
    moveal %fp@(-18),%a0
    addaw #312,%a0
    movew %d3,%d0
    lslw #8,%d0
    lea %a0@(0x0,%d0:w:4),%a0
    movel %a0,%fp@(-32)
    clrw %fp@(-82)
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    movew %a0@(20),%d3
    andiw #1,%d3
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    addw %a0@(32),%d3
    lea %pc@(SCATTERDEVICES_BE),%a0
    moveb %a0@(0x0,%d3:w),%d3
    movew %fp@(-14),%d0
    moveal %fp@(-12),%a0
    lea %a0@(16),%a0
    jbra SETDEV_C6
SETDEV_B2:              /* entries for this device (usage device bits) */
    movew %a0@(6),%d1
    btst %d3,%d1
    jbeq SETDEV_BE
    bset #15,%d1
SETDEV_BE:              /* store */
    movew %d1,%a0@(10)
    addaw #16,%a0
SETDEV_C6:              /* next; analyze, allocate, correlate; mark the device for update if changed */
    dbf %d0,SETDEV_B2
    jsr %pc@(ANALYZEDEV)
    jsr %pc@(ALLOCATE)
    jsr %pc@(CORRELATE)
    tstw %fp@(-82)
    jbeq SETDEV_E0
    jsr %pc@(MARKDEVUBIT)
SETDEV_E0:              /* record the table seed for the palette */
    moveal %fp@(-40),%a0
    moveal %a0@,%a0
    movel %a0@,%d0
    moveal %fp@(-12),%a0
    moveal %a0@(12),%a1
    moveal %a1@,%a1
    movew %fp@(-28),%d3
    movel %d0,%a1@(0x0,%d3:w:4)
SETDEV_FA:              /* return */
    moveq #0,%d0
    moveml %sp@+,%d3-%d5/%a2-%a3
    unlk %a4
    rts
    .long   0x00000000	| 4083EF6C

/* SETENTRYCOLOR: _SetEntryColor. */
trap_SetEntryColor:
SETENTRYCOLOR:
    linkw %fp,#0
    moveal %fp@(14),%a0
    cmpaw #0,%a0
    jbeq SETENTRYCOLOR_46
    moveal %a0@,%a0
    movew %a0@,%d0
    moveq #0,%d1
    movew %fp@(12),%d1
    cmpw %d0,%d1
    jbcc SETENTRYCOLOR_46
    lsll #4,%d1
    lea %a0@(0x10,%d1:l),%a0
    moveal %fp@(8),%a1
    movel %a1@,%a0@
    movew %a1@(4),%a0@(4)
    btst #2,%a0@(7)
    jbeq SETENTRYCOLOR_3E
    lea %a0@,%a0
    moveb %a0@+,%a0@+
    moveb %a0@+,%a0@+
    moveb %a0@+,%a0@+
SETENTRYCOLOR_3E:       /* mark the palette changed */
    movel %fp@(14),%sp@-
    jbsr DIRTYSEEDS
SETENTRYCOLOR_46:       /* return */
    moveq #0,%d0
    unlk %fp
    rtd #10
    .short  0x0000	| 4083EFBE

/* GETENTRYUSAGE: _GetEntryUsage. */
trap_GetEntryUsage:
GETENTRYUSAGE:
    linkw %fp,#0
    moveal %fp@(18),%a0
    cmpaw #0,%a0
    jbeq GETENTRYUSAGE_32
    moveal %a0@,%a0
    movew %a0@,%d0
    moveq #0,%d1
    movew %fp@(16),%d1
    cmpw %d0,%d1
    jbcc GETENTRYUSAGE_32
    lsll #4,%d1
    lea %a0@(0x10,%d1:l),%a0
    moveal %fp@(12),%a1
    movew %a0@(6),%a1@
    moveal %fp@(8),%a1
    movew %a0@(8),%a1@
GETENTRYUSAGE_32:       /* return */
    moveq #0,%d0
    unlk %fp
    rtd #14
    .short  0x0000, 0x0000, 0x0000	| 4083EFFA

/* SETENTRYUSAGE: _SetEntryUsage. */
trap_SetEntryUsage:
SETENTRYUSAGE:
    linkw %fp,#0
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveal %fp@(14),%a0
    cmpaw #0,%a0
    jbeq SETENTRYUSAGE_88
    moveal %a0@,%a0
    movew %a0@,%d0
    moveq #0,%d1
    movew %fp@(12),%d1
    cmpw %d0,%d1
    jbcc SETENTRYUSAGE_88
    lsll #4,%d1
    lea %a0@(0x10,%d1:l),%a2
    movew %a2@(6),%d0
    btst #2,%d0
    jbeq SETENTRYUSAGE_64
    movew %fp@(10),%d3
    eorw %d3,%d0
    andiw #16140,%d0
    jbeq SETENTRYUSAGE_64
    movew %a2@(12),%d3
    jbpl SETENTRYUSAGE_64
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    lea %a0@(312),%a3
    lea %a0@(56),%a4
    moveq #0,%d4
    jsr %pc@(CLEARSTRAND)
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    orl %d4,%a0@(16)
    clrw %a2@(12)
SETENTRYUSAGE_64:       /* animating: duplicate the high bytes of the RGB */
    movew %fp@(10),%d0
    btst #2,%d0
    jbeq SETENTRYUSAGE_76
    lea %a2@,%a0
    moveb %a0@+,%a0@+
    moveb %a0@+,%a0@+
    moveb %a0@+,%a0@+
SETENTRYUSAGE_76:       /* store usage and tolerance; mark changed */
    movew %d0,%a2@(6)
    movew %fp@(8),%a2@(8)
    movel %fp@(14),%sp@-
    jbsr DIRTYSEEDS
SETENTRYUSAGE_88:       /* return */
    moveq #0,%d0
    moveml %sp@+,%d3-%d4/%a2-%a4
    unlk %fp
    rtd #10
    .long   0x00000000, 0x00000000, 0x00000000	| 4083F094

/* CTAB2PALETTE: _CTab2Palette. */
trap_CTab2Palette:
CTAB2PALETTE:
    linkw %fp,#0
    moveml %d3/%a2-%a3,%sp@-
    moveal %fp@(12),%a2
    cmpaw #0,%a2
    jbeq CTAB2PALETTE_94
    movel %fp@(12),%sp@-
    jsr %pc@(CLEARPALETTE)
    jbne CTAB2PALETTE_94
    moveal %fp@(16),%a3
    cmpaw #0,%a3
    jbeq CTAB2PALETTE_94
    moveal %a3@,%a1
    moveq #0,%d3
    movew %a1@(6),%d3
    addqw #1,%d3
    moveal %a2,%a0
    movel %d3,%d0
    addqw #1,%d0
    aslw #4,%d0
    _SetHandleSize
    jbne CTAB2PALETTE_94
    movel %a2,%sp@-
    jbsr DIRTYSEEDS
    moveal %a2@,%a0
    movew %d3,%a0@
    addaw #16,%a0
    moveal %a3@,%a1
    addql #8,%a1
    movew %fp@(10),%d1
    swap %d1
    movew %fp@(8),%d1
    jbra CTAB2PALETTE_90
CTAB2PALETTE_5C:        /* each entry: RGB */
    movel %a1@(2),%a0@
    movew %a1@(6),%a0@(4)
    btst #18,%d1
    jbeq CTAB2PALETTE_7E
    moveb %a1@(2),%a0@(1)
    moveb %a1@(4),%a0@(3)
    moveb %a1@(6),%a0@(5)
CTAB2PALETTE_7E:        /* usage, tolerance; clear the private fields */
    movel %d1,%a0@(6)
    clrw %a0@(10)
    clrl %a0@(12)
    addaw #16,%a0
    addql #8,%a1
CTAB2PALETTE_90:        /* next */
    dbf %d3,CTAB2PALETTE_5C
CTAB2PALETTE_94:        /* return */
    moveq #0,%d0
    moveml %sp@+,%d3/%a2-%a3
    unlk %fp
    rtd #12

/* PALETTE2CTAB: _Palette2CTab. */
trap_Palette2CTab:
PALETTE2CTAB:
    linkw %fp,#0
    moveml %d3/%a2-%a3,%sp@-
    moveal %fp@(12),%a2
    cmpaw #0,%a2
    jbeq PALETTE2CTAB_62
    moveal %fp@(8),%a3
    cmpaw #0,%a3
    jbeq PALETTE2CTAB_62
    moveal %a2@,%a0
    moveq #0,%d3
    movew %a0@,%d3
    movel %d3,%d0
    addql #1,%d0
    lsll #3,%d0
    moveal %a3,%a0
    _SetHandleSize
    jbne PALETTE2CTAB_62
    moveal %a2@,%a0
    moveal %a3@,%a1
    movew %d3,%d0
    subqw #1,%d0
    clrl %a1@
    movew %d0,%a1@(6)
    clrw %a1@(4)
    addqw #8,%a1
    lea %a0@(16),%a0
    moveq #0,%d1
    jbra PALETTE2CTAB_5E
PALETTE2CTAB_4A:        /* each entry: value and RGB */
    movew %d1,%a1@
    movel %a0@,%a1@(2)
    movew %a0@(4),%a1@(6)
    addaw #16,%a0
    addql #8,%a1
    addqw #1,%d1
PALETTE2CTAB_5E:        /* next */
    dbf %d3,PALETTE2CTAB_4A
PALETTE2CTAB_62:        /* return */
    moveq #0,%d0
    moveml %sp@+,%d3/%a2-%a3
    unlk %fp
    rtd #8
    .short  0x0000	| 4083F1AE

/* CLEARONE: ClearOne(entry): release one palette entry's device link */
CLEARONE:
    linkw %fp,#0
    movel %a2,%sp@-
    moveal %fp@(8),%a0
    movel %a0@(12),%d0
    clrw %a0@(10)
    clrl %a0@(12)
    moveal %fp@(4),%a1
    lea %a1@(56),%a2
    addaw #312,%a1
CLEARONE_22:            /* device and index from the link: free it in the device table */
    bfextu %d0,19,5,%d1
    bfextu %d0,24,8,%d2
    moveal %a2@(0x0,%d1:w:8),%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    cmpw %a0@(6),%d2
    jbhi CLEARONE_46
    clrw %a0@(0x8,%d2:w:8)
CLEARONE_46:            /* next link */
    lslw #8,%d1
    addw %d2,%d1
    lea %a1@(0x0,%d1:l:4),%a0
    movew %a0@,%d0
    clrl %a0@
    tstw %d0
    jbmi CLEARONE_22
    moveal %sp@+,%a2
    unlk %fp
    rtd #4
    .short  0x0000	| 4083F20E

/* COPYPALETTE: _CopyPalette. */
trap_CopyPalette:
COPYPALETTE:
    linkw %fp,#-2
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveal 0xdc8,%a4
    cmpaw #-1,%a4
    jbeq COPYPALETTE_EA
    moveal %fp@(14),%a2
    cmpaw #0,%a2
    jbeq COPYPALETTE_EA
    moveal %fp@(18),%a3
    cmpaw #0,%a3
    jbeq COPYPALETTE_EA
    cmpal %a2,%a3
    jbeq COPYPALETTE_EA
    moveq #0,%d0
    movew %fp@(8),%d0
    jble COPYPALETTE_EA
    movel %d0,%d3
    addw %fp@(12),%d0
    moveal %a3@,%a1
    movew %a1@,%d1
    subw %d0,%d1
    jbpl COPYPALETTE_4C
    addw %d1,%d3
COPYPALETTE_4C:         /* the destination large enough? grow it */
    moveal %a2@,%a0
    movew %a0@,%d4
    movew %fp@(10),%d0
    addw %d3,%d0
    cmpw %d4,%d0
    jble COPYPALETTE_8A
    movew %d0,%d4
    moveal %a2,%a0
    addqw #1,%d0
    aslw #4,%d0
    _SetHandleSize
    jbne COPYPALETTE_EA
    moveal %a2@,%a0
    movew %d4,%d2
    moveq #0,%d1
    movew %a0@,%d1
    subw %d1,%d2
    movew %d4,%a0@
    lea %a0@(16),%a1
    aslw #4,%d1
    addal %d1,%a1
    jbra COPYPALETTE_86
COPYPALETTE_7E:         /* clear the new entries */
    clrl %a1@+
    clrl %a1@+
    clrl %a1@+
    clrl %a1@+
COPYPALETTE_86:         /* next */
    dbf %d2,COPYPALETTE_7E
COPYPALETTE_8A:         /* copy the range */
    cmpal %a2,%a3
    jbeq COPYPALETTE_EA
    movel %a3,%sp@-
    jbsr DIRTYSEEDS
    moveal %a3@,%a1
    moveq #0,%d0
    movew %fp@(10),%d0
    asll #4,%d0
    moveal %a2@,%a0
    lea %a0@(0x10,%d0:w),%a0
    moveq #0,%d1
    movew %fp@(12),%d0
    asll #4,%d0
    lea %a1@(0x10,%d0:w),%a1
    jbra COPYPALETTE_E6
COPYPALETTE_B2:         /* a linked destination entry: release it */
    movel %a0@(12),%d0
    jbeq COPYPALETTE_C8
    moveml %a0-%a1,%sp@-
    movel %a0,%sp@-
    movel %a4@,%sp@-
    jsr %pc@(CLEARONE)
    moveml %sp@+,%a0-%a1
COPYPALETTE_C8:         /* copy RGB, usage, tolerance */
    movel %a1@,%a0@
    movel %a1@(4),%a0@(4)
    movew %a1@(8),%a0@(8)
    clrw %a0@(10)
    clrl %a0@(12)
    addaw #16,%a0
    addaw #16,%a1
COPYPALETTE_E6:         /* next */
    dbf %d3,COPYPALETTE_B2
COPYPALETTE_EA:         /* return */
    moveq #0,%d0
    moveml %sp@+,%d3-%d4/%a2-%a4
    unlk %fp
    rtd #14
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083F306

/* UPDATEDEVICE: UpdateDevice(n): redraw the windows on device n after its colors changed (InvalRect over its rectangle) */
UPDATEDEVICE:
    linkw %fp,#-14
    moveml %d0-%d3/%a0-%a3,%sp@-
    subqw #4,%sp
    jsr @(0x1290,%za0)@(0x0)	| 4083F31A
    movel %sp@+,%d3
    pea %fp@(-4)
    jsr @(0xfd0,%za0)@(0)	| 4083F326
    moveal 0xdc8,%a1
    moveal %a1@,%a1
    movew %fp@(8),%d0
    moveal %a1@(0x38,%d0:w:8),%a2
    moveal %a2,%a0
    jsr %pc@(DEVSETENTRIES)
    moveal %a2@,%a0
    lea %a0@(34),%a2
    movew %a0@(20),%d0
    btst #11,%d0
    jbeq UPDATEDEVICE_52
    movel MenuList,%d0
    jbeq UPDATEDEVICE_52
    moveal %d0,%a0
    tstl %a0@
    jbeq UPDATEDEVICE_52
    jsr @(0x12dc,%za0)@(0)	| 4083F35C
UPDATEDEVICE_52:        /* the palette's update flags */
    moveq #0,%d0
    moveal 0xdcc,%a0
    movel %a0,%d1
    jbne UPDATEDEVICE_6A
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    moveal %a0@(12),%a0
    movel %a0,%d1
    jbeq UPDATEDEVICE_74
UPDATEDEVICE_6A:        /* flags */
    moveal %a0@,%a0
    movew %a0@(6),%d0
    andiw #-16384,%d0
UPDATEDEVICE_74:        /* MultiFinder: tell the other layers (OSDispatch 37) */
    movew %d0,%fp@(-14)
    jsr %pc@(CHECKFORJUGGLER)
    jbne UPDATEDEVICE_92
    movel %a2,%sp@-
    movew %fp@(8),%sp@-
    movew %fp@(-14),%sp@-
    movew #37,%sp@-
    _OSDispatch
    jbra UPDATEDEVICE_150
UPDATEDEVICE_92:        /* the windows */
    moveal WindowList,%a3
    cmpaw #-1,%a3
    jbeq UPDATEDEVICE_150
    jbra UPDATEDEVICE_144
UPDATEDEVICE_A2:        /* front window or the others (flag bit 14 / 15) */
    movew %fp@(-14),%d1
    movew #14,%d0
    cmpal %d3,%a3
    jbne UPDATEDEVICE_B2
    movew #15,%d0
UPDATEDEVICE_B2:        /* visible; a color window with its own palette? */
    tstb %a3@(110)
    jbeq UPDATEDEVICE_140
    tstw %a3@(6)
    jbpl UPDATEDEVICE_D6
    moveal %a3@(8),%a0
    moveal %a0@,%a0
    moveal %a0@(12),%a0
    cmpaw #0,%a0
    jbeq UPDATEDEVICE_D6
    moveal %a0@,%a0
    movew %a0@(6),%d1
UPDATEDEVICE_D6:        /* update requested? its rectangle on the device: InvalRect */
    btst %d0,%d1
    jbeq UPDATEDEVICE_140
    lea %a3@(2),%a0
    tstw %a0@(4)
    jbpl UPDATEDEVICE_E8
    moveal %a0@,%a0
    moveal %a0@,%a0
UPDATEDEVICE_E8:        /* intersect with the device */
    lea %a0@(6),%a0
    movew %a2@,%d0
    addw %a0@,%d0
    cmpw %a3@(20),%d0
    jbge UPDATEDEVICE_140
    movew %d0,%fp@(-12)
    movew %a2@(2),%d0
    addw %a0@(2),%d0
    cmpw %a3@(22),%d0
    jbge UPDATEDEVICE_140
    movew %d0,%fp@(-10)
    movew %a2@(4),%d0
    addw %a0@,%d0
    cmpw %a3@(16),%d0
    jble UPDATEDEVICE_140
    movew %d0,%fp@(-8)
    movew %a2@(6),%d0
    addw %a0@(2),%d0
    cmpw %a3@(18),%d0
    jble UPDATEDEVICE_140
    movew %d0,%fp@(-6)
    movel %a3,%sp@-
    jsr @(0xfcc,%za0)@(0)	| 4083F440
    pea %fp@(-12)
    jsr @(0x12a0,%za0)@(0)	| 4083F44A
UPDATEDEVICE_140:       /* next window */
    moveal %a3@(144),%a3
UPDATEDEVICE_144:       /* until the end; the desktop too */
    cmpaw #0,%a3
    jbne UPDATEDEVICE_A2
    jbsr REDRAWDESKTOP
UPDATEDEVICE_150:       /* restore the port, return */
    movel %fp@(-4),%sp@-
    jsr @(0xfcc,%za0)@(0)	| 4083F464
    moveq #0,%d0
    moveml %sp@+,%d0-%d3/%a0-%a3
    unlk %fp
    rtd #2
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083F476

/* UPDATEDEVICES: UpdateDevices: for each device marked for update: UPDATEDEVICE (needs WindowList and an application) */
UPDATEDEVICES:
    moveml %d0-%d1/%a0,%sp@-
    cmpil #-1,WindowList
    jbeq UPDATEDEVICES_3E
    cmpil #-1,CurApName
    jbeq UPDATEDEVICES_3E
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    movew %a0@,%d0
    subqw #1,%d0
    movel %a0@(20),%d1
    jbeq UPDATEDEVICES_3E
    clrl %a0@(20)
UPDATEDEVICES_2C:       /* each device marked */
    btst %d0,%d1
    jbeq UPDATEDEVICES_36
    movew %d0,%sp@-
    jsr %pc@(UPDATEDEVICE)
UPDATEDEVICES_36:       /* next; PaletteDispatch 17 */
    dbf %d0,UPDATEDEVICES_2C
    moveq #17,%d0
    _PaletteDispatch
UPDATEDEVICES_3E:       /* restore registers, return */
    moveml %sp@+,%d0-%d1/%a0
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4083F4C4

/* WHATPAL: WhatPal: the palette of the window at a2: its own, the application's default (0xDCC), or the system palette */
WHATPAL:
    tstw %a2@(6)
    jbpl WHATPAL_12
    moveal %a2@(8),%a0
    moveal %a0@,%a0
    movel %a0@(12),%d0
    jbne WHATPAL_22
WHATPAL_12:             /* the application palette, or the system one */
    movel 0xdcc,%d0
    jbne WHATPAL_22
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    movel %a0@(12),%d0
WHATPAL_22:             /* a0 = it, flags set */
    moveal %d0,%a0
    tstl %d0
    rts
    .long   0x00000000, 0x00000000	| 4083F4F8

/* CALCDEVS: CalcDevs: which devices each visible window touches */
CALCDEVS:
    moveml %d3-%d7/%a2-%a3,%sp@-
    subqw #8,%sp
    moveal WindowList,%a2
    moveq #0,%d3
    moveq #0,%d4
    clrl %sp@-
    jsr @(0x1290,%za0)@(0x0)	| 4083F510
    movel %sp@+,%d6
    jbra CALCDEVS_B2
CALCDEVS_1C:            /* each visible window with this palette */
    tstb %a2@(110)
    bsrw WHATPAL
    cmpal %fp@(-8),%a0
    jbne CALCDEVS_AE
    lea %a2@(2),%a0
    tstw %a0@(4)
    bplw CALCDEVS_3C
    moveal %a0@,%a0
    moveal %a0@,%a0
CALCDEVS_3C:            /* its global rectangle */
    movel %a0@(6),%d0
    movel %a2@(16),%d1
    subw %d0,%d1
    swap %d0
    swap %d1
    subw %d0,%d1
    swap %d0
    swap %d1
    movel %d1,%fp@(-56)
    movel %a2@(20),%d1
    subw %d0,%d1
    swap %d0
    swap %d1
    subw %d0,%d1
    swap %d1
    movel %d1,%fp@(-52)
    moveal %fp@(-18),%a0
    movew %a0@,%d5
    subqw #1,%d5
    lea %a0@(56),%a3
CALCDEVS_72:            /* each device: intersects? */
    moveal %a3@(0x0,%d5:w:8),%a0
    moveal %a0@,%a0
    clrw %sp@-
    pea %a0@(34)
    pea %fp@(-56)
    pea %sp@(10)
    jsr @(0x10a8,%za0)@(0)	| 4083F586
    tstw %sp@+
    jbeq CALCDEVS_AA
    bset %d5,%d3
    tstb %a2@(111)
    jbeq CALCDEVS_AA
    cmpl %a2,%d6
    jbne CALCDEVS_A2
    movel %a2,%a3@(0x4,%d5:w:8)
    jbra CALCDEVS_A8
CALCDEVS_A2:            /* the front window */
    cmpal %a3@(0x4,%d5:w:8),%a2
    jbne CALCDEVS_AA
CALCDEVS_A8:            /* mark */
    bset %d5,%d4
CALCDEVS_AA:            /* next device */
    dbf %d5,CALCDEVS_72
CALCDEVS_AE:            /* next window */
    moveal %a2@(144),%a2
CALCDEVS_B2:            /* until the end; the device masks */
    movel %a2,%d0
    jbne CALCDEVS_1C
    movel %d3,%fp@(-44)
    movel %d4,%fp@(-48)
    addql #8,%sp
    moveml %sp@+,%d3-%d7/%a2-%a3
    rts
    .long   0x00000000, 0x00000000	| 4083F5C8
/* UNHOOKDEVICE: UnhookDevice: release all 256 indexes of a device (ZAPLINKS each) */
UNHOOKDEVICE:
    linkw %fp,#-116
    moveml %d2-%d4/%a2,%sp@-
    moveal 0xdc8,%a0
    cmpaw #-1,%a0
    beqs UNHOOKDEVICE_72
    moveal %a0@,%a0
    movew %a0@,%d3
    lea %a0@(56),%a1
    movel %fp@(8),%d1
    subqw #1,%d3
UNHOOKDEVICE_20:        /* find the device in the list */
    cmpl %a1@(0x0,%d3:w:8),%d1
    beqs UNHOOKDEVICE_2C
    dbf %d3,UNHOOKDEVICE_20
    bras UNHOOKDEVICE_72
UNHOOKDEVICE_2C:        /* its color table: release all 256 indexes */
    lslw #8,%d3
    moveal %d1,%a2
    moveal %a2@,%a2
    moveal %a2@(22),%a2
    moveal %a2@,%a2
    moveal %a2@(42),%a2
    moveal %a2@,%a2
    movew #255,%d4
UNHOOKDEVICE_42:        /* release each index */
    moveb %d4,%d3
    movew %d3,%sp@-
    jbsr ZAPLINKS
    dbf %d4,UNHOOKDEVICE_42
    subqw #2,%sp
    movel %d1,%sp@-
    jsr %pc@(CHECKDEVICECOLORS)
    tstw %sp@+
    jbeq UNHOOKDEVICE_72
    moveq #0,%d0
    lsrw #8,%d3
    bset %d3,%d0
    orl %d0,%a0@(16)
    movew #1,%sp@-
    jsr %pc@(SCATTERDEVICES)
    movew %d3,%sp@-
    jsr %pc@(UPDATEDEVICE)
UNHOOKDEVICE_72:        /* restore registers, return */
    moveml %sp@+,%d2-%d4/%a2
    unlk %fp
    rtd #4
    .long   0x00000000	| 4083F64C

/* UNRESERVEDEVICES: UnreserveDevices: un-reserve the indexes held by a palette on the given devices */
UNRESERVEDEVICES:
    moveml %d1-%d4/%a2-%a4,%sp@-
    lea %a0@(312),%a2
    movew %a1@,%d1
    lea %a1@(16),%a3
    moveq #0,%d4
    jbra UNRESERVEDEVICES_58
UNRESERVEDEVICES_12:    /* each entry linked */
    movew %a3@(12),%d2
    jbpl UNRESERVEDEVICES_54
UNRESERVEDEVICES_18:    /* on one of the devices: release it, back to the default color */
    bfextu %d2,19,5,%d3
    btst %d3,%d0
    jbeq UNRESERVEDEVICES_4A
    bset %d3,%d4
    movew %d2,%sp@-
    jsr %pc@(ZAPLINKS)
    moveal %a0@(0x38,%d3:w:8),%a4
    bfextu %d2,24,8,%d3
    moveal %a4@,%a4
    moveal %a4@(22),%a4
    moveal %a4@,%a4
    moveal %a4@(42),%a4
    moveal %a4@,%a4
    cmpw %a4@(6),%d3
    jbhi UNRESERVEDEVICES_4A
    movew #4096,%a4@(0x8,%d3:w:8)
UNRESERVEDEVICES_4A:    /* next link */
    andiw #8191,%d2
    movew %a2@(0x0,%d2:w:4),%d2
    jbmi UNRESERVEDEVICES_18
UNRESERVEDEVICES_54:    /* next entry */
    lea %a3@(16),%a3
UNRESERVEDEVICES_58:    /* until the last; mark the devices */
    dbf %d1,UNRESERVEDEVICES_12
    orl %d4,%a0@(16)
    moveml %sp@+,%d1-%d4/%a2-%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083F6B6

/* ZAPLINKS: ZapLinks(device:index): remove every palette link to that device index */
ZAPLINKS:
    linkw %fp,#0
    moveml %d0-%d4/%a0-%a2,%sp@-
    moveal 0xdc8,%a1
    moveal %a1@,%a1
    lea %a1@(312),%a0
    moveal %a1@(4),%a2
    moveal %a2@,%a2
    movew %fp@(8),%d0
    andiw #8191,%d0
    movew %d0,%d1
    lsrw #8,%d1
    moveal %a1@(0x38,%d1:w:8),%a1
    moveal %a1@,%a1
    moveal %a1@(22),%a1
    moveal %a1@,%a1
    movel %a1@(42),%d1
    jbeq ZAPLINKS_4A
    moveal %d1,%a1
    moveal %a1@,%a1
    clrw %d1
    moveb %d0,%d1
    cmpw %a1@(6),%d0
    jbhi ZAPLINKS_4A
    bclr #6,%a1@(0x8,%d1:w:8)
ZAPLINKS_4A:            /* the index's chain: unlink it from both directions */
    movew %a0@(0x0,%d0:w:4),%d3
    jbeq ZAPLINKS_13C
    movew %a0@(0x2,%d0:w:4),%d4
    clrl %a0@(0x0,%d0:w:4)
    tstw %d3
    jbmi ZAPLINKS_80
    tstw %d4
    jbmi ZAPLINKS_CC
    andiw #8191,%d3
    subqw #1,%a2@(0x4,%d3:w:8)
    moveal %a2@(0x0,%d3:w:8),%a0
    moveal %a0@,%a0
    andil #8191,%d4
    lsll #4,%d4
    clrl %a0@(0x1c,%d4:l)
    jbra ZAPLINKS_13C
ZAPLINKS_80:            /* head of a chain */
    tstw %d4
    jbmi ZAPLINKS_F8
    movew %d3,%d0
    bfextu %d3,19,5,%d1
    bfextu %d3,24,8,%d2
    lslw #8,%d1
    addw %d2,%d1
    lea %a0@(0x0,%d1:l:4),%a1
    movew %d4,%a1@(2)
    movew %a1@,%d3
    jbpl ZAPLINKS_B0
ZAPLINKS_9E:            /* walk to the end */
    bfextu %d3,19,5,%d1
    bfextu %d3,24,8,%d2
    lslw #8,%d1
    addw %d2,%d1
    movew %a0@(0x0,%d1:l:4),%d3
    jbmi ZAPLINKS_9E
ZAPLINKS_B0:            /* count down; the entry's link */
    andiw #8191,%d3
    subqw #1,%a2@(0x4,%d3:w:8)
    moveal %a2@(0x0,%d3:w:8),%a0
    moveal %a0@,%a0
    andil #8191,%d4
    lsll #4,%d4
    movew %d0,%a0@(0x1c,%d4:l)
    jbra ZAPLINKS_13C
ZAPLINKS_CC:            /* middle */
    bfextu %d4,19,5,%d1
    bfextu %d4,24,8,%d2
    lslw #8,%d1
    addw %d2,%d1
    lea %a0@(0x0,%d1:l:4),%a1
    movew %d3,%a1@
    movew %a1@(2),%d4
    jbpl ZAPLINKS_134
ZAPLINKS_E4:            /* walk */
    bfextu %d4,19,5,%d1
    bfextu %d4,24,8,%d2
    lslw #8,%d1
    addw %d2,%d1
    movew %a0@(0x2,%d1:l:4),%d4
    jbmi ZAPLINKS_E4
    jbra ZAPLINKS_134
ZAPLINKS_F8:            /* tail */
    bfextu %d4,19,5,%d1
    bfextu %d4,24,8,%d2
    lslw #8,%d1
    addw %d2,%d1
    lea %a0@(0x0,%d1:l:4),%a1
    movew %d3,%a1@
    bfextu %d3,19,5,%d1
    bfextu %d3,24,8,%d2
    lslw #8,%d1
    addw %d2,%d1
    lea %a0@(0x0,%d1:l:4),%a1
    movew %d4,%a1@(2)
    movew %a1@,%d3
    jbpl ZAPLINKS_134
ZAPLINKS_122:           /* walk */
    bfextu %d3,19,5,%d1
    bfextu %d3,24,8,%d2
    lslw #8,%d1
    addw %d2,%d1
    movew %a0@(0x0,%d1:l:4),%d3
    jbmi ZAPLINKS_122
ZAPLINKS_134:           /* one fewer link on the entry */
    andiw #8191,%d3
    subqw #1,%a2@(0x4,%d3:w:8)
ZAPLINKS_13C:           /* restore registers */
    moveml %sp@+,%d0-%d4/%a0-%a2
ZAPLINKS_140:           /* return */
    unlk %fp
    rtd #2
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083F806

/* RESIZEPALETTE: _ResizePalette. */
RESIZEPALETTE:
    .byte   0x4E, 0x56, 0x00, 0x00, 0x48, 0xE7, 0x18, 0x20	| 4083F810
    moveal %fp@(10),%a0	| 4083F818
    movel %a0,%d0	| 4083F81C
    addql #1,%d0	| 4083F81E
    jbne RESIZEPALETTE_16	| 4083F820
    moveal 0xdcc,%a0	| 4083F822
RESIZEPALETTE_16:       /* the new size: shrink or grow */
    moveal %a0@,%a2	| 4083F826
    movew %fp@(8),%d3	| 4083F828
    movew %a2@,%d4	| 4083F82C
    cmpw %d4,%d3	| 4083F82E
    jbeq RESIZEPALETTE_82	| 4083F830
    jbhi RESIZEPALETTE_58	| 4083F832
    _HLock	| 4083F834
    moveal %a0@,%a2	| 4083F836
    movew %d4,%d0	| 4083F838
    lslw #4,%d0	| 4083F83A
    lea %a2@(0x10,%d0:w),%a2	| 4083F83C
RESIZEPALETTE_30:       /* shrinking: release the dropped entries */
    subaw #16,%a2	| 4083F840
    subqw #1,%d4	| 4083F844
    movew %a2@(6),%d0	| 4083F846
    andiw #6,%d0	| 4083F84A
    jbeq RESIZEPALETTE_4E	| 4083F84E
    movel %fp@(10),%sp@-	| 4083F850
    movew %d4,%sp@-	| 4083F854
    clrl %sp@-	| 4083F856
    jsr @(0x1878,%za0)@(0x0)	| 4083F858
RESIZEPALETTE_4E:       /* until the new size */
    cmpw %d4,%d3	| 4083F85E
    jbne RESIZEPALETTE_30	| 4083F860
    moveal %fp@(10),%a0	| 4083F862
    _HUnlock	| 4083F866
RESIZEPALETTE_58:       /* growing: resize the handle */
    movew %d3,%d0	| 4083F868
    extl %d0	| 4083F86A
    lsll #4,%d0	| 4083F86C
    addil #16,%d0	| 4083F86E
    _SetHandleSize	| 4083F874
    jbne RESIZEPALETTE_82	| 4083F876
    moveal %a0@,%a2	| 4083F878
    movew %d3,%a2@	| 4083F87A
    cmpl %d3,%d4	| 4083F87C
    jbcc RESIZEPALETTE_82	| 4083F87E
    subl %d4,%d3	| 4083F880
    lslw #4,%d4	| 4083F882
    lea %a2@(0x10,%d4:w),%a0	| 4083F884
    lslw #2,%d3	| 4083F888
    subqw #1,%d3	| 4083F88A
RESIZEPALETTE_7C:       /* clear the new entries */
    clrl %a0@+	| 4083F88C
    dbf %d3,RESIZEPALETTE_7C	| 4083F88E
RESIZEPALETTE_82:       /* restore registers, return */
    moveml %sp@+,%d3-%d4/%a2	| 4083F892
    unlk %fp	| 4083F896
    rtd #6	| 4083F898
    .byte   0x00, 0x00, 0x00, 0x00	| 4083F89C
/* RESTOREDEVICECLUT: RestoreDeviceClut(device or nil for all): restore the color tables */
RESTOREDEVICECLUT:
    tstl %sp@(4)
    bnew UNHOOKDEVICE
    movel %a3,%sp@-
    movel DeviceList,%d0
    bras RESTOREDEVICECLUT_1E
RESTOREDEVICECLUT_10:   /* each device: UnhookDevice */
    moveal %d0,%a3
    movel %a3,%sp@-
    jsr %pc@(UNHOOKDEVICE)
    moveal %a3@,%a3
    movel %a3@(30),%d0
RESTOREDEVICECLUT_1E:   /* next; return */
    bnes RESTOREDEVICECLUT_10
    moveal %sp@+,%a3
    rtd #4
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083F8C6
/* NEWHILITECOLOR: NewHiliteColor: the hilite color changed: drop the cached inverse tables and update */
NEWHILITECOLOR:
    movel 0xdc8,%d1
    beqs NEWHILITECOLOR_38
    moveal %d1,%a1
    moveal %a1@,%a1
    movel %a1@(36),%d0
    beqs NEWHILITECOLOR_18
    clrl %a1@(36)
    moveal %d0,%a0
    _DisposHandle
NEWHILITECOLOR_18:      /* each device: drop its cached hilite inverse table */
    moveal %d1,%a1
    moveal %a1@,%a1
    movel %a1@(44),%d0
    beqs NEWHILITECOLOR_2A
    clrl %a1@(44)
    moveal %d0,%a0
    _DisposHandle
NEWHILITECOLOR_2A:      /* check, scatter and update the devices */
    jsr %pc@(CHECKALLDEVICECLUTS)
    clrw %sp@-
    jsr %pc@(SCATTERDEVICES)
    jsr %pc@(UPDATEDEVICES)
NEWHILITECOLOR_38:      /* return */
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 4083F90E

/* SAVEFORE: SaveFore(cs): save the port's foreground color (RGB or palette index) */
SAVEFORE:
    moveq #0,%d0
    jbra SAVEBACK_2

/* SAVEBACK: SaveBack(cs): save the port's background color; SAVEFORE comes here with d0 = 0 */
SAVEBACK:
    moveq #1,%d0
SAVEBACK_2:             /* (SaveFore d0 = 0, SaveBack 1) a palette color? its entry number */
    moveal %sp@(4),%a1
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(6)
    jbpl SAVEBACK_3A
    movel %a0@(8),%d1
    jbeq SAVEBACK_3A
    moveal %d1,%a0
    moveal %a0@,%a0
    btst %d0,%a0@(25)
    jbeq SAVEBACK_3A
    movew #1,%a1@
    tstw %d0
    jbeq SAVEBACK_30
    movew %a0@(22),%a1@(2)
    jbra SAVEBACK_36
SAVEBACK_30:            /* entry */
    movew %a0@(16),%a1@(2)
SAVEBACK_36:            /* return */
    rtd #4
SAVEBACK_3A:            /* an RGB: GetForeColor / GetBackColor */
    clrw %a1@
    pea %a1@(2)
    tstw %d0
    jbeq SAVEBACK_4C
    jsr @(0x1668,%za0)@(0x0)	| 4083F958
    jbra SAVEBACK_36
SAVEBACK_4C:            /* foreground */
    jsr @(0x1664,%za0)@(0x0)	| 4083F960
    jbra SAVEBACK_36
    .long   0x00000000, 0x00000000	| 4083F968

/* RESTOREFORE: RestoreFore(cs): RGBForeColor or PmForeColor from the saved record */
RESTOREFORE:
    moveal %sp@(4),%a1
    tstw %a1@+
    jbne RESTOREFORE_14
    pea %a1@
    jsr @(0x1650,%za0)@(0x0)	| 4083F97A
RESTOREFORE_10:         /* return */
    rtd #4
RESTOREFORE_14:         /* PmForeColor */
    movew %a1@,%sp@-
    jsr @(0x185c,%za0)@(0)	| 4083F986
    jbra RESTOREFORE_10

/* RESTOREBACK: RestoreBack(cs): RGBBackColor or PmBackColor from the saved record */
RESTOREBACK:
    moveal %sp@(4),%a1
    tstw %a1@+
    jbne RESTOREBACK_12
    pea %a1@
    jsr @(0x1654,%za0)@(0x0)	| 4083F998
    jbra RESTOREFORE_10
RESTOREBACK_12:         /* PmBackColor */
    movew %a1@,%sp@-
    jsr @(0x1860,%za0)@(0x0)	| 4083F9A2
    jbra RESTOREFORE_10
    .short  0x0000, 0x0000, 0x0000	| 4083F9AA
/* REINSTANTIATECOLORS: ReinstantiateColors: does nothing here (saves and restores registers) */
REINSTANTIATECOLORS:
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveml %sp@+,%d3-%d4/%a2-%a4
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 4083F9BE
/* RELEASELIST: ReleaseList: release the current device's entries held by the palette list */
RELEASELIST:
    tstl 0xdc8
    beqs RELEASELIST_40_4
    moveml %d3-%d4/%a2,%sp@-
    moveal %sp@(16),%a2
    moveal 0xdc8,%a0
    moveal %a0@,%a0
    movew %a0@,%d0
    lea %a0@(56),%a0
    clrw %d3
    movel TheGDevice,%d1
RELEASELIST_20:         /* find the current device */
    cmpl %a0@(0x0,%d3:w:8),%d1
    jbeq RELEASELIST_2E
    addqw #1,%d3
    cmpw %d0,%d3
    jbcs RELEASELIST_20
    jbra RELEASELIST_40
RELEASELIST_2E:         /* release each listed index */
    lslw #8,%d3
    movew %a2@+,%d4
RELEASELIST_32:         /* ZapLinks */
    movew %a2@+,%d0
    moveb %d0,%d3
    movew %d3,%sp@-
    jbsr ZAPLINKS
    dbf %d4,RELEASELIST_32
RELEASELIST_40:         /* restore registers */
    moveml %sp@+,%d3-%d4/%a2
RELEASELIST_40_4:       /* return */
    rtd #4
    .long   0x00000000, 0x00000000	| 4083FA08
RELEASELIST_50:         /* PaletteDispatch offsets (data) */
    .long   0xEEB0EF90, 0xFE90FE00, 0x00000000, 0x00000000	| 4083FA10
    .long   0x00000000, 0xD1E0FEC0, 0xE090FF00, 0xFF04FF60	| 4083FA20
    .short  0xFF7E, 0xFFA0, 0xFFB0	| 4083FA30

trap_PaletteDispatch:
PMGRDISPATCH:           /* PaletteDispatch: d0 = selector (low byte) and parameter size (high byte) */
    cmpib #19,%d0
    jbcc PMGRDISPATCH_14
    lea %pc@(RELEASELIST_50),%a0
    movew %a0@(0x0,%d0:w:2),%d0
    jbeq PMGRDISPATCH_14
    addaw %d0,%a0
    jmp %a0@
PMGRDISPATCH_14:        /* unknown: pop the parameters, -1 */
    lsrw #8,%d0
    moveal %sp@+,%a0
    addaw %d0,%sp
    moveq #-1,%d0
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 4083FA54

trap_QDExtensions:
QDEXTDISPATCHER:        /* QDExtensions dispatch (GWorld calls): selector in d0 */
    cmpiw #21,%d0
    jbhi QDEXTDISPATCHER_62
    jmp %pc@(QDEXTDISPATCHER_A,%d0:w:4)
QDEXTDISPATCHER_A:      /* jump table (LockPixels, UnlockPixels, NewGWorld, DisposeGWorld, ...) */
    .short  0x4EFA	| 4083FA6A
    .short  NEWGWORLD-.	| 4083FA6C
    jmp %pc@(LOCKPIXELS)
    jmp %pc@(UNLOCKPIXELS)
    .short  0x4EFA	| 4083FA76
    .short  UPDATEGWORLD-.	| 4083FA78
    jmp %pc@(DISPOSEGWORLD)
    .short  0x4EFA	| 4083FA7E
    .short  GETGWORLD-.	| 4083FA80
    jmp %pc@(SETGWORLD)
    jmp %pc@(CTABCHANGED)
    .short  0x4EFA	| 4083FA8A
    .short  PIXPATCHANGED-.	| 4083FA8C
    jmp %pc@(PORTCHANGED)
    .short  0x4EFA	| 4083FA92
    .short  GDEVICECHANGED-.	| 4083FA94
    .short  0x4EFA	| 4083FA96
    .short  ALLOWPURGEPIXELS-.	| 4083FA98
    .short  0x4EFA	| 4083FA9A
    .short  NOPURGEPIXELS-.	| 4083FA9C
    .short  0x4EFA	| 4083FA9E
    .short  GETPIXELSSTATE-.	| 4083FAA0
    .short  0x4EFA	| 4083FAA2
    .short  SETPIXELSSTATE-.	| 4083FAA4
    jmp %pc@(GETPIXBASEADDR)
    jmp %pc@(NEWSCREENBUFFER)
    jmp %pc@(DISPOSESCREENBUFFER)
    .short  0x4EFA	| 4083FAB2
    .short  GETGWORLDDEVICE-.	| 4083FAB4
    jmp %pc@(QDDONE)
    .short  0x4EFA	| 4083FABA
    .short  OFFSCREENVERSION-.	| 4083FABC
    jmp %pc@(NEWTEMPSCREENBUFFER)
QDEXTDISPATCHER_62:     /* unknown selector: pop, paramErr */
    moveal %sp@+,%a0
    swap %d0
    extl %d0
    addal %d0,%sp
    movew #-50,%d0
    movew %d0,QDErr
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 4083FAD4
/* NEWGWORLD: NewGWorld(offscreen, depth, rect, ctab, device, flags): the body: device, pixmap, port and pixel buffer for an offscreen world */
NEWGWORLD:
    linkw %fp,#-62	| 4083FAE0
    moveml %d3-%d7/%a2-%a4,%sp@-
    clrw %fp@(30)
    clrl %fp@(-10)
    clrl %fp@(-14)
    clrl %fp@(-18)
    clrl %fp@(-22)
    clrl %fp@(-26)
    clrl %fp@(-30)
    /* _EmptyRect (through its trap vector): empty is an error */
    clrb %sp@-
    movel %fp@(20),%sp@-
    jsr @(0x10b8,%za0)@(0)
    moveb %sp@+,%d0
    bnew NEWGWORLD_3FE+0x8
    /* current device in fp-38; the port: 108 locked bytes (fp-30), their address in fp-34 */
    movel TheGDevice,%fp@(-38)
    moveq #108,%d0
    _ResrvMem
    bnew NEWGWORLD_40E
    moveq #108,%d0
    .short  0xA122	| _NewHandle (flags 0x0100)
    bnew NEWGWORLD_40E
    movel %a0,%fp@(-30)
    _HLock
    movel %a0@,%d0
    _StripAddress
    movel %d0,%fp@(-34)
    moveal %d0,%a0
    clrw %a0@(6)
    /* flags in d3, depth in d7: negative or over 32 is an error; 0 is taken from _GetMaxDevice */
    movel %fp@(8),%d3
    movew %fp@(24),%d7
    bmiw NEWGWORLD_3FE
    beqs NEWGWORLD+0x9c
    cmpiw #32,%d7
    bgtw NEWGWORLD_3FE
    clrw %fp@(-46)
    moveal %fp@(20),%a0
    movel %a0@,%fp@(-62)
    movel %a0@(4),%fp@(-58)
    /* noNewDevice (flags bit 1): the device given (fp-12); none is an error */
    btst #1,%d3
    beqs NEWGWORLD_9A
    movel %fp@(12),%d0
    beqw NEWGWORLD_3FE+0x8
    movel %d0,%fp@(-38)
NEWGWORLD_9A:
    bras NEWGWORLD+0xea	| 4083FB7A
    clrl %sp@-	| 4083FB7C
    movel %fp@(20),%sp@-	| 4083FB7E
    jsr @(0x169c,%za0)@(0)	| 4083FB82
    moveal %sp@+,%a0	| 4083FB88
    movel %a0,%fp@(-38)	| 4083FB8A
    moveal %a0@,%a0	| 4083FB8E
    moveal %fp@(20),%a1	| 4083FB90
    movew %a1@(2),%d0	| 4083FB94
    subw %a0@(36),%d0	| 4083FB98
    movew %d0,%fp@(-46)	| 4083FB9C
    movew %a1@(6),%d0	| 4083FBA0
    subw %a1@(2),%d0	| 4083FBA4
    movew %d0,%fp@(-56)	| 4083FBA8
    movew %a1@(4),%d0	| 4083FBAC
    subw %a1@,%d0	| 4083FBB0
    movew %d0,%fp@(-58)	| 4083FBB2
    clrl %fp@(-62)	| 4083FBB6
    moveal %fp@(0xffffffffffffffda,%za0)@(0),%a0	| 4083FBBA
    moveal %a0@(0x16,%za0)@(0x0),%a1
    movew %a1@(32),%d7	| 4083FBC6
    lea %pc@(SHIFTTABLE),%a0	| 4083FBCA
    moveq #0,%d0	| 4083FBCE
    moveb %a0@(0,%d7:w),%d0	| 4083FBD0
    jbmi NEWGWORLD_3FE	| 4083FBD4
    movew %d0,%fp@(-2)	| 4083FBD8
    movew %fp@(-62),%fp@(-54)	| 4083FBDC
    movew %fp@(-46),%d1	| 4083FBE2
    lslw %d0,%d1	| 4083FBE6
    andiw #31,%d1	| 4083FBE8
    lsrw %d0,%d1	| 4083FBEC
    movew %fp@(-60),%d0	| 4083FBEE
    subw %d1,%d0	| 4083FBF2
    movew %d0,%fp@(-52)	| 4083FBF4
    movel %fp@(-58),%fp@(-50)	| 4083FBF8
    movew %fp@(-56),%d0	| 4083FBFE
    subw %fp@(-60),%d0	| 4083FC02
    extl %d0	| 4083FC06
    movew %fp@(-2),%d1	| 4083FC08
    lsll %d1,%d0	| 4083FC0C
    addil #30,%d0	| 4083FC0E
    lsrl #5,%d0	| 4083FC14
    addqw #1,%d0	| 4083FC16
    lsll #2,%d0	| 4083FC18
    movew %d0,%fp@(-6)	| 4083FC1A
    movew %fp@(-58),%d1	| 4083FC1E
    subw %fp@(-62),%d1	| 4083FC22
    muluw %d1,%d0	| 4083FC26
    btst #2,%d3	| 4083FC28
    jbeq NEWGWORLD_160	| 4083FC2C
    jsr @(0x1ab4,%za0)@(0)	| 4083FC2E
    tstl %d0	| 4083FC34
    jbne NEWGWORLD_166	| 4083FC36
    movew #-151,%d0	| 4083FC38
    jbra NEWGWORLD_40E	| 4083FC3C
NEWGWORLD_160:          /* error */
    .short  0xA122	| 4083FC40 _NewHandle (flags 0x0100)
    jbne NEWGWORLD_40E	| 4083FC42
NEWGWORLD_166:          /* the pixel buffer; temporary memory if asked */
    movel %a0,%fp@(-10)	| 4083FC46
    _MoveHHi	| 4083FC4A
    btst #0,%d3	| 4083FC4C
    jbeq NEWGWORLD_174	| 4083FC50
    _HPurge	| 4083FC52
NEWGWORLD_174:          /* the pixmap */
    moveal %fp@(0xffffffffffffffda,%za0)@(0),%a0	| 4083FC54
    movew %a0@(10),%fp@(-4)	| 4083FC5A
    moveq #50,%d0	| 4083FC60
    .short  0xA322	| 4083FC62 _NewHandle (flags 0x0300)
    jbne NEWGWORLD_40E	| 4083FC64
    movel %a0,%fp@(-14)	| 4083FC68
    moveal %a0@,%a1	| 4083FC6C
    movel %fp@(-10),%a1@	| 4083FC6E
    movew %fp@(-6),%d0	| 4083FC72
    oriw #-32768,%d0	| 4083FC76
    movew %d0,%a1@(4)	| 4083FC7A
    movel %fp@(-54),%a1@(6)	| 4083FC7E
    movel %fp@(-50),%a1@(10)	| 4083FC84
    movew #2,%a1@(14)	| 4083FC8A
    movew #72,%a1@(22)	| 4083FC90
    movew #72,%a1@(26)	| 4083FC96
    movew %d7,%a1@(32)	| 4083FC9C
    cmpiw #16,%d7	| 4083FCA0
    jblt NEWGWORLD_21C	| 4083FCA4
    movew #2,%fp@(-44)	| 4083FCA6
    movew #16,%a1@(30)	| 4083FCAC
    movew #3,%a1@(34)	| 4083FCB2
    moveq #8,%d0	| 4083FCB8
    cmpiw #32,%d7	| 4083FCBA
    jbeq NEWGWORLD_1E2	| 4083FCBE
    moveq #5,%d0	| 4083FCC0
NEWGWORLD_1E2:          /* its color table */
    movew %d0,%a1@(36)	| 4083FCC2
    movew #8,%d0	| 4083FCC6
    .short  0xA322	| 4083FCCA _NewHandle (flags 0x0300)
    jbne NEWGWORLD_40E	| 4083FCCC
    movel %a0,%fp@(-18)	| 4083FCD0
    moveal %fp@(0xfffffffffffffff2,%za0)@(0),%a1	| 4083FCD4
    movel %a0,%a1@(42)	| 4083FCDA
    moveal %a0@,%a0	| 4083FCDE
    moveq #24,%d0	| 4083FCE0
    cmpiw #32,%d7	| 4083FCE2
    jbeq NEWGWORLD_20A	| 4083FCE6
    moveq #15,%d0	| 4083FCE8
NEWGWORLD_20A:          /* error */
    movel %d0,%a0@	| 4083FCEA
    moveq #2,%d0	| 4083FCEC
    .short  0xA322	| 4083FCEE _NewHandle (flags 0x0300)
    jbne NEWGWORLD_40E	| 4083FCF0
    movel %a0,%fp@(-26)	| 4083FCF4
    jbra NEWGWORLD_2F0	| 4083FCF8
NEWGWORLD_21C:          /* indexed: the table from the device or the given one */
    clrw %fp@(-44)	| 4083FCFC
    clrw %a1@(30)	| 4083FD00
    movew #1,%a1@(34)	| 4083FD04
    movew %d7,%a1@(36)	| 4083FD0A
    moveal %fp@(16),%a0	| 4083FD0E
    subal %a4,%a4	| 4083FD12
    btst #1,%d3	| 4083FD14
    jbeq NEWGWORLD_25C	| 4083FD18
    moveal %fp@(0xffffffffffffffda,%za0)@(0),%a0	| 4083FD1A
    moveal %a0@(0x16,%za0)@(0x0),%a0
    moveal %a0@(42),%a0	| 4083FD26
    movel %a0,%fp@(-18)	| 4083FD2A
    moveal %fp@(0xfffffffffffffff2,%za0)@(0),%a1	| 4083FD2E
    movel %a0,%a1@(42)	| 4083FD34
    jbra NEWGWORLD_348	| 4083FD38
NEWGWORLD_25C:          /* GetCTable for the depth */
    tstw %fp@(24)	| 4083FD3C
    jbeq NEWGWORLD_27A	| 4083FD40
    cmpaw #0,%a0	| 4083FD42
    jbne NEWGWORLD_28E	| 4083FD46
    clrl %sp@-	| 4083FD48
    movew %fp@(24),%sp@-	| 4083FD4A
    jsr @(0x1660,%za0)@(0x0)	| 4083FD4E
    moveal %sp@+,%a0	| 4083FD54
    tstl %a0	| 4083FD56
    jbne NEWGWORLD_298	| 4083FD58
NEWGWORLD_27A:          /* the device's */
    moveal %fp@(0xffffffffffffffda,%za0)@(0),%a0	| 4083FD5A
    moveal %a0@(6),%a4	| 4083FD60
    moveal %a0@(0x16,%za0)@(0x0),%a0	| 4083FD64
    moveal %a0@(42),%a0	| 4083FD6A
NEWGWORLD_28E:          /* error */
    jsr @(0x1584,%za0)@(0x0)	| 4083FD6E
    jbne NEWGWORLD_40E	| 4083FD74
NEWGWORLD_298:          /* copy it */
    movel %a0,%fp@(-18)	| 4083FD78
    moveal %fp@(0xfffffffffffffff2,%za0)@(0),%a1	| 4083FD7C
    movel %a0,%a1@(42)	| 4083FD82
    moveal %a4,%a0	| 4083FD86
    tstl %a0	| 4083FD88
    jbne NEWGWORLD_2E2	| 4083FD8A
    clrl %sp@-	| 4083FD8C
    movel %fp@(-18),%sp@-	| 4083FD8E
    jsr %pc@(FINDINVERSETABLE)	| 4083FD92
    moveal %sp@+,%a0	| 4083FD96
    tstl %a0	| 4083FD98
    jbne NEWGWORLD_2E2	| 4083FD9A
    moveq #2,%d0	| 4083FD9C
    .short  0xA322	| 4083FD9E _NewHandle (flags 0x0300)
    jbne NEWGWORLD_40E	| 4083FDA0
    movel %a0,%fp@(-26)	| 4083FDA4
    movel %fp@(-18),%sp@-	| 4083FDA8
    movel %a0,%sp@-	| 4083FDAC
    movew %fp@(-4),%sp@-	| 4083FDAE
    jsr @(0x16e4,%za0)@(0)	| 4083FDB2
    movew QDErr,%d0	| 4083FDB8
    jbne NEWGWORLD_40E	| 4083FDBC
    jbra NEWGWORLD_2F0	| 4083FDC0
NEWGWORLD_2E2:          /* error */
    jsr @(0x1584,%za0)@(0x0)	| 4083FDC2
    jbne NEWGWORLD_40E	| 4083FDC8
    movel %a0,%fp@(-26)	| 4083FDCC
NEWGWORLD_2F0:          /* a new device (unless noNewDevice, flags bit 1): its fields */
    btst #1,%d3	| 4083FDD0
    jbne NEWGWORLD_348	| 4083FDD4
    moveq #62,%d0	| 4083FDD6
    .short  0xA322	| 4083FDD8 _NewHandle (flags 0x0300)
    jbne NEWGWORLD_40E	| 4083FDDA
    movel %a0,%fp@(-22)	| 4083FDDE
    moveal %a0@,%a0	| 4083FDE2
    movew %fp@(-44),%a0@(4)	| 4083FDE4
    movel %fp@(-26),%a0@(6)	| 4083FDEA
    movew %fp@(-4),%a0@(10)	| 4083FDF0
    movew #16384,%d0	| 4083FDF6
    cmpiw #1,%d7	| 4083FDFA
    jbeq NEWGWORLD_324	| 4083FDFE
    oriw #1,%d0	| 4083FE00
NEWGWORLD_324:          /* the device's pixmap and rectangle */
    movew %d0,%a0@(20)	| 4083FE04
    movel %fp@(-14),%a0@(22)	| 4083FE08
    movel %fp@(-54),%a0@(34)	| 4083FE0E
    movel %fp@(-50),%a0@(38)	| 4083FE14
    movel #-1,%a0@(42)	| 4083FE1A
    movel %fp@(-22),%fp@(-38)	| 4083FE22
NEWGWORLD_348:          /* OpenCPort on it */
    movel TheGDevice,%fp@(-42)	| 4083FE28
    movel %fp@(-38),TheGDevice	| 4083FE2E
    movel %fp@(-34),%sp@-	| 4083FE34
    jsr @(0x1600,%za0)@(0x0)	| 4083FE38
    movel %fp@(-42),TheGDevice	| 4083FE3E
    btst #1,%d3	| 4083FE44
    jbeq NEWGWORLD_380	| 4083FE48
    moveal %fp@(-34),%a0	| 4083FE4A
    moveal %a0@(2),%a0	| 4083FE4E
    _DisposHandle	| 4083FE52
    moveal %fp@(-14),%a0	| 4083FE54
    moveal %fp@(-34),%a1	| 4083FE58
    movel %a0,%a1@(2)	| 4083FE5C
NEWGWORLD_380:          /* portRect, clip */
    moveal %fp@(-34),%a1	| 4083FE60
    movel %fp@(-62),%a1@(16)	| 4083FE64
    movel %fp@(-58),%a1@(20)	| 4083FE6A
    movel %a1@(24),%sp@-	| 4083FE70
    pea %a1@(16)	| 4083FE74
    jsr @(0x117c,%za0)@(0)	| 4083FE78
    moveal %fp@(-34),%a0	| 4083FE7E
    moveal %a0@(8),%a0	| 4083FE82
    moveq #32,%d0	| 4083FE86
    _SetHandleSize	| 4083FE88
    jbne NEWGWORLD_40E	| 4083FE8A
    moveal %fp@(-34),%a0	| 4083FE8C
    moveal %a0@(8,%za0)@(0),%a0	| 4083FE90
    movel %fp@(-38),%a0@(26)	| 4083FE96
    moveq #1,%d0	| 4083FE9C
    btst #1,%d3	| 4083FE9E
    jbeq NEWGWORLD_3C6	| 4083FEA2
    moveq #0,%d0	| 4083FEA4
NEWGWORLD_3C6:          /* flags */
    moveb %d0,%a0@(30)	| 4083FEA6
    moveq #0,%d0	| 4083FEAA
    btst #2,%d3	| 4083FEAC
    jbeq NEWGWORLD_3D4	| 4083FEB0
    moveq #1,%d0	| 4083FEB2
NEWGWORLD_3D4:          /* mark it a GWorld; return it */
    moveb %d0,%a0@(31)	| 4083FEB4
    moveal %fp@(-34),%a0	| 4083FEB8
    oriw #1,%a0@(6)	| 4083FEBC
    moveal %fp@(26),%a0	| 4083FEC2
    movel %fp@(-34),%a0@	| 4083FEC6
NEWGWORLD_3EA:          /* QDErr, return */
    movew %fp@(30),%d0	| 4083FECA
    extl %d0	| 4083FECE
    movew %d0,QDErr	| 4083FED0
    moveml %sp@+,%d3-%d7/%a2-%a4	| 4083FED4
    unlk %fp	| 4083FED8
    rtd #22	| 4083FEDA
NEWGWORLD_3FE:          /* errors */
    movew #-157,%fp@(30)	| 4083FEDE
    jbra NEWGWORLD_414	| 4083FEE4
    movew #-50,%fp@(30)	| 4083FEE6
    jbra NEWGWORLD_414	| 4083FEEC
NEWGWORLD_40E:          /* error */
    movew %d0,%fp@(30)	| 4083FEEE
    nop	| 4083FEF2
NEWGWORLD_414:          /* dispose of what was made */
    moveal %fp@(-10),%a0	| 4083FEF4
    _DisposHandle	| 4083FEF8
    moveal %fp@(-14),%a0	| 4083FEFA
    _DisposHandle	| 4083FEFE
    moveal %fp@(-18),%a0	| 4083FF00
    _DisposHandle	| 4083FF04
    moveal %fp@(-22),%a0	| 4083FF06
    _DisposHandle	| 4083FF0A
    moveal %fp@(-26),%a0	| 4083FF0C
    _DisposHandle	| 4083FF10
    movel %fp@(-30),%d7	| 4083FF12
    jbeq NEWGWORLD_3EA	| 4083FF16
    moveal %d7,%a0	| 4083FF18
    moveal %a0@,%a0	| 4083FF1A
    movew %a0@(6),%d0	| 4083FF1C
    andiw #-16384,%d0	| 4083FF20
    cmpiw #-16384,%d0	| 4083FF24
    bnew NEWGWORLD_454	| 4083FF28
    movel %a0@,%sp@-	| 4083FF2C
    jsr @(0x1608,%za0)@(0x0)	| 4083FF2E
NEWGWORLD_454:          /* done */
    moveal %d7,%a0	| 4083FF34
    _DisposHandle	| 4083FF36
    jbra NEWGWORLD_3EA	| 4083FF38

/* SHIFTTABLE: table. */
SHIFTTABLE:
    .short  0xFF00, 0x01FF, 0x02FF	| 4083FF3A
    .long   0xFFFF03FF, 0xFFFFFFFF, 0xFFFF04FF, 0xFFFFFFFF	| 4083FF40
    .long   0xFFFFFFFF, 0xFFFFFFFF, 0xFFFF0500, 0x00000000	| 4083FF50

/* FINDINVERSETABLE: table. */
FINDINVERSETABLE:
    moveal %sp@(4,%za0)@(0),%a0	| 4083FF60
    movel %a0@,%d0	| 4083FF66
    moveal DeviceList,%a0	| 4083FF68
    tstl %a0	| 4083FF6C
    jbeq FINDINVERSETABLE_26	| 4083FF6E
FINDINVERSETABLE_10:    /* a device with the same color table seed: its inverse table */
    moveal %a0@,%a0	| 4083FF70
    moveal %a0@(6),%a2	| 4083FF72
    moveal %a2@,%a1	| 4083FF76
    cmpl %a1@,%d0	| 4083FF78
    jbeq FINDINVERSETABLE_26	| 4083FF7A
    moveal %a0@(30),%a0	| 4083FF7C
    tstl %a0	| 4083FF80
    jbne FINDINVERSETABLE_10	| 4083FF82
    subal %a2,%a2	| 4083FF84
FINDINVERSETABLE_26:    /* return it */
    movel %a2,%sp@(8)	| 4083FF86
    rtd #4	| 4083FF8A
    .byte   0x00, 0x00	| 4083FF8E
/* GETGWORLD: GetGWorld(&port, &device): thePort and TheGDevice */
GETGWORLD:
    moveal %sp@(8),%a0
    moveal %a5@,%a1
    movel %a1@,%a0@
    moveal %sp@(4),%a0
    movel TheGDevice,%a0@
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083FFA4

/* SETGWORLD: SetGWorld(port, device): thePort = port; for a GWorld its device, else the given one */
SETGWORLD:
    moveal %a5@,%a0
    movel %sp@(8),%a0@
    moveal %sp@(4),%a1
    moveal %sp@(8),%a0
    movew %a0@(6),%d0
    andiw #-16383,%d0
    cmpiw #-16383,%d0
    jbne SETGWORLD_26
    moveal %a0@(8,%za0)@(0),%a0	| 4083FFCC
    moveal %a0@(26),%a1
SETGWORLD_26:           /* none: the main device */
    tstl %a1
    jbne SETGWORLD_2E
    moveal MainDevice,%a1
SETGWORLD_2E:           /* TheGDevice */
    movel %a1,TheGDevice
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4083FFE6

/* DISPOSEGWORLD: DisposeGWorld(gw): dispose of the port, pixmap, pixels and the device it owns */
DISPOSEGWORLD:
    moveal %sp@(4),%a0
    movew %a0@(6),%d0
    andiw #-16383,%d0
    cmpiw #-16383,%d0

    jbne DISPOSEGWORLD_68
    moveal %a0@(2,%za0)@(0),%a1	| 40840002
    moveal %a1@,%a0
    movew %a1@(14),%d0
    cmpiw #2,%d0
    jbeq DISPOSEGWORLD_2C
DISPOSEGWORLD_24:       /* locked: back to the handle */
    cmpiw #1,%d0
    jbne DISPOSEGWORLD_2E
    .short  0xA128	| 4084001A _RecoverHandle (flags 0x0100)
DISPOSEGWORLD_2C:       /* _DisposHandle */
    _DisposHandle
DISPOSEGWORLD_2E:       /* the device it owns */
    moveal %sp@(4),%a0
    moveal %a0@(8,%za0)@(0),%a0	| 40840022
DISPOSEGWORLD_38:       /* owned? not current; dispose */
    moveb %a0@(30),%d0
    jbeq DISPOSEGWORLD_56
    moveal %a0@(26),%a0
    cmpal TheGDevice,%a0
    jbne DISPOSEGWORLD_4E
    movel MainDevice,TheGDevice
DISPOSEGWORLD_4E:       /* DisposGDevice */
    movel %a0,%sp@-
    jsr @(0x16c0,%za0)@(0)	| 40840040
DISPOSEGWORLD_56:       /* CloseCPort */
    movel %sp@(4),%sp@-
    jsr @(0x1608,%za0)@(0x0)	| 4084004A
DISPOSEGWORLD_60:       /* free the port */
    moveal %sp@(4),%a0
    .short  0xA128	| 40840054 _RecoverHandle (flags 0x0100)
    _DisposHandle
DISPOSEGWORLD_68:       /* return */
    rtd #4
    .long   0x00000000	| 4084005C
