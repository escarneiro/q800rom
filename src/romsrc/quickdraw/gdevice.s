/*
 quickdraw/gdevice.s - graphics devices and cursors
 From BLOCKHEAD (0x408277E0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* NEWGDEVICE: _NewGDevice. */
trap_NewGDevice:
BLOCKHEAD:
NEWGDEVICE:
    linkw %fp,#0
    moveml %a2-%a3,%sp@-
    clrl %fp@(14)
    movel TheZone,%sp@-
    movel SysZone,TheZone
    moveq #62,%d0
    _ResrvMem
    bnew BLOCKHEAD_98
    moveq #62,%d0
    .short  0xA322	| 40827800 _NewHandle (flags 0x0300)
    _HLock
    moveal %a0,%a2
    moveal %a2@,%a3
    moveq #2,%d0
    .short  0xA322	| 4082780A _NewHandle (flags 0x0300)
    bnew BLOCKHEAD_98
    movel %a0,%a3@(6)
    moveq #2,%d0
    .short  0xA322	| 40827816 _NewHandle (flags 0x0300)
    jbne BLOCKHEAD_98
    movel %a0,%a3@(50)
    moveq #2,%d0
    .short  0xA322	| 40827820 _NewHandle (flags 0x0300)
    jbne BLOCKHEAD_98
    movel %a0,%a3@(54)
    moveq #80,%d0
    _ResrvMem
    jbne BLOCKHEAD_98
    clrl %sp@-
    jbsr OPENPIXMAP
    movel %sp@,%a3@(22)
    moveal %sp@+,%a0
    _HLock
    movel %fp@(8),%d0
    cmpil #-1,%d0
    jbeq BLOCKHEAD_86
    cmpiw #128,%d0
    jbeq BLOCKHEAD_76
    bset #0,%a3@(21)
BLOCKHEAD_76:           /* InitGDevice for the given driver and mode */
    movew %fp@(12),%sp@-
    movel %fp@(8),%sp@-
    movel %a2,%sp@-
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x16b8,%za0)@(0)	| 40827860
BLOCKHEAD_86:           /* restore the zone, return the device */
    movel %sp@+,TheZone
    movel %a2,%fp@(14)
    moveml %sp@+,%a2-%a3
    unlk %fp
    rtd #6
BLOCKHEAD_98:           /* out of memory: dispose of what was made */
    movel %a2,%sp@-
    jsr %pc@(DISPOSGDHANDLES)
    jbra BLOCKHEAD_86

/* DISPOSGDEVICE: _DisposGDevice. */
trap_DisposGDevice:
DISPOSGDEVICE:
    moveal %sp@+,%a1
    movel %sp@,%sp@-
    jbsr DISPOSGDHANDLES
    moveal %sp@+,%a0
    _DisposHandle
    jmp %a1@

/* DISPOSGDHANDLES: DisposGDHandles(gd): dispose of a device's handles: pixmap, inverse table, expanded cursor buffers */
DISPOSGDHANDLES:        /* dispose of the device's color table handle (+6), its expanded cursor buffers (+50, +54), and the pixmap (DisposPixMap) */
    movel %a1,%sp@-
    moveal %sp@(8),%a1
    moveal %a1@,%a1
    movel %a1@(22),%sp@-
    movel %a1@(6),%d0
    jbeq DISPOSGDHANDLES_16
    moveal %d0,%a0
    _DisposHandle
DISPOSGDHANDLES_16:     /* cursor image buffer */
    movel %a1@(50),%d0
    jbeq DISPOSGDHANDLES_20
    moveal %d0,%a0
    _DisposHandle
DISPOSGDHANDLES_20:     /* cursor mask buffer */
    movel %a1@(54),%d0
    jbeq DISPOSGDHANDLES_2A
    moveal %d0,%a0
    _DisposHandle
DISPOSGDHANDLES_2A:     /* the pixmap */
    movel %sp@+,%d0
    jbeq DISPOSGDHANDLES_36
    movel %d0,%sp@-
    jsr @(0x1610,%za0)@(0x0)	| 408278BC
DISPOSGDHANDLES_36:     /* return */
    moveal %sp@+,%a1
    movel %sp@+,%sp@
    rts
    .long   0x00000000, 0x00000000	| 408278C8

/* INITGDEVICE: _InitGDevice: set up a device for a video mode. */
trap_InitGDevice:
INITGDEVICE:
    linkw %fp,#-84
    moveml %d2/%a2-%a3,%sp@-
    moveal %fp@(8),%a0
    _HGetState
    movew %d0,%fp@(-78)
    _HLock
    moveal %a0@,%a2
    moveal %a2@(22),%a0
    _HGetState
    movew %d0,%fp@(-80)
    _HLock
    moveal %a0@,%a3
    movel TheGDevice,%fp@(-84)
    movew %fp@(16),%a2@
    movel %fp@(12),%d0
    cmpl MinusOne,%d0
    jbeq INITGDEVICE_106
    lea %fp@(-64),%a0
    clrl %a0@(12)
    clrw %a0@(22)
    movew %fp@(16),%a0@(24)
    lea %fp@(-76),%a1
    movel %a1,%a0@(28)
    cmpl %a2@(42),%d0
    beqw INITGDEVICE_9E
    movel %d0,%a2@(42)
    clrw %a2@(48)
    moveml %a0-%a1,%sp@-
    movew %fp@(16),%sp@-
    movel %fp@(12),%sp@-
    movel %a2@(22),%sp@-
    pea %a2@(4)
    jsr %pc@(GETDEVPIXMAP)
    moveml %sp@+,%a0-%a1
    movew #2,%a0@(26)
    movel %fp@(12),%d0
    movew %d0,%a1@
    clrw %a1@(6)
    clrl %a1@(2)
    .short  0xA204	| 40827964 _Control (flags 0x0200)
    movew #5,%a0@(26)
    .short  0xA204	| 4082796C _Control (flags 0x0200)
INITGDEVICE_9E:         /* gray or color through the driver (Control 6, SetGray) and, for a CLUT device, its colors (Control 3, SetEntries) */
    movew %a2@(20),%d0
    notw %d0
    andiw #1,%d0
    moveb %d0,%a1@
    movew #6,%a0@(26)
    .short  0xA204	| 40827980 _Control (flags 0x0200)
    cmpiw #0,%a2@(4)
    jbne INITGDEVICE_E8
    moveal %a3@(42),%a0
    _HLock
    moveal %a0@,%a0
    clrw %a1@(4)
    movew %a0@(6),%a1@(6)
    lea %a0@(8),%a0
    movel %a0,%a1@
    lea %fp@(-64),%a0
    movew #3,%a0@(26)
    movel %a1,%a0@(28)
    .short  0xA204	| 408279B0 _Control (flags 0x0200)
    moveal %a3@(42),%a0
    _HUnlock
INITGDEVICE_E8:         /* not a direct device: rebuild the inverse table (resolution 4) */
    cmpiw #2,%a2@(4)
    jbeq INITGDEVICE_106
    movel %a3@(42),%sp@-
    movel %a2@(6),%sp@-
    moveq #4,%d0
    movew %d0,%a2@(10)
    movew %d0,%sp@-
    jsr @(0x16e4,%za0)@(0)	| 408279D0
INITGDEVICE_106:        /* tell the Palette Manager (PaletteDispatch 2) */
    cmpil #-1,0xdc8
    jbeq INITGDEVICE_118
    moveq #2,%d0
    movel %fp@(8),%sp@-
    _PaletteDispatch
INITGDEVICE_118:        /* gdRect = pixmap bounds (bit 10: the other way round) */
    lea %a3@(6),%a0
    lea %a2@(34),%a1
    movew %a2@(20),%d0
    btst #10,%d0
    jbeq INITGDEVICE_12C
    exg %a0,%a1
INITGDEVICE_12C:        /* restore TheGDevice and the handle states */
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %fp@(-84),TheGDevice
    moveal %a2@(22),%a0
    movew %fp@(-80),%d0
    _HSetState
    moveal %fp@(8),%a0
    movew %fp@(-78),%d0
    _HSetState
    moveml %sp@+,%d2/%a2-%a3
    unlk %fp
    rtd #10
    .long   0x00000000, 0x00000000, 0x00000000	| 40827A24

/* GETDEVPIXMAP: GetDevPixMap(refNum, mode, pm): fill a device's pixmap for a video mode from its slot resources (base, row bytes, bounds, depth) */
GETDEVPIXMAP:
    linkw %fp,#-58
    moveml %d3-%d5/%a2-%a4,%sp@-
    moveal %fp@(12),%a0
    _HGetState
    movew %d0,%fp@(-58)
    _HLock
    moveal %a0@,%a2
    movew %fp@(20),%d0
    notw %d0
    aslw #2,%d0
    moveal UTableBase,%a1
    moveal %a1@(0x0,%d0:w),%a3
    moveal %a3@,%a1
    lea %fp@(-56),%a0
    moveb %a1@(40),%a0@(49)
    moveb %a1@(41),%a0@(50)
    moveb %a1@(50),%a0@(51)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    jbne GETDEVPIXMAP_158
    movel %a1@(42),%d3
    movel %fp@(16),%d0
    moveb %d0,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne GETDEVPIXMAP_158
    moveal %a0@(4),%a4
    clrw %d4
    moveb #4,%a0@(50)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    jbne GETDEVPIXMAP_70
    movew %a0@(2),%d4
GETDEVPIXMAP_70:        /* from the mode's sResource: base address, row bytes, bounds, pixel fields */
    moveal %fp@(8),%a1
    movew %d4,%a1@
    moveb #1,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    jbne GETDEVPIXMAP_158
    moveal %a0@,%a1
    addl %a1@,%d3
    movel %d3,%a2@+
    movew %a1@(4),%d0
    oriw #-32768,%d0
    movew %d0,%a2@+
    movel %a1@(6),%a2@+
    movel %a1@(10),%a2@+
    movew %a1@(14),%a2@+
    clrw %a2@+
    clrl %a2@+
    movel %a1@(22),%a2@+
    movel %a1@(26),%a2@+
    movew %a1@(30),%a2@+
    movew %a1@(32),%d5
    movew %d5,%a2@+
    movew %a1@(34),%a2@+
    movew %a1@(36),%a2@+
    movel %a1@(38),%a2@+
    movel %a1,%a0@(4)
    moveq #23,%d0	/* _SlotManager 23: SLOTDISPOSPTR, sDisposePtr */
    _SlotManager
    movel %a4,%a0@(4)
    cmpiw #1,%d4
    jbeq GETDEVPIXMAP_FE
    cmpiw #0,%d4
    jbne GETDEVPIXMAP_132
GETDEVPIXMAP_DA:        /* the default color table for the depth: copy it into the pixmap's table */
    clrl %sp@-
    movew %d5,%sp@-
    jsr @(0x1660,%za0)@(0x0)	| 40827B0E
    movel %sp@+,%d0
    beqw GETDEVPIXMAP_148
    movel %d0,%sp@-
    movel %d0,%sp@-
    movel %a2@,%sp@-
    jsr @(0x1a14,%za0)@(0)	| 40827B20
    jsr @(0x1690,%za0)@(0x0)
    jbra GETDEVPIXMAP_148
GETDEVPIXMAP_FE:        /* a color table in the mode sResource: its size (sReadPBSize, 38), then the block itself (sReadStruct, 7) */
    moveb #2,%a0@(50)
    moveq #38,%d0	/* _SlotManager 38: READPBSIZE, sReadPBSize */
    _SlotManager
    jbne GETDEVPIXMAP_DA
    subql #4,%a0@(8)
    movel %a0@(8),%d0
    moveal %a2@,%a0
    _SetHandleSize
    moveal %a0@,%a1
    lea %fp@(-56),%a0
    movel %a1,%a0@
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */
    _SlotManager
    nop
    jbsr GETDEVPIXMAPPATCH
    movel %d0,%a1@
    movel %a4,%a0@(4)
    jbra GETDEVPIXMAP_148
GETDEVPIXMAP_132:       /* its size field */
    moveal %fp@(12),%a0
    moveal %a0@,%a0
    movew %a0@(36),%d0
    muluw %a0@(34),%d0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    movel %d0,%a0@
GETDEVPIXMAP_148:       /* mark the table as a device table; clear the remaining fields */
    moveal %a2@,%a0
    moveal %a0@,%a0
    movew #-32768,%a0@(4)
    addqw #4,%a2
    clrl %a2@+
    nop
GETDEVPIXMAP_158:       /* restore the handle state, return */
    moveal %fp@(12),%a0
    movew %fp@(-58),%d0
    _HSetState
    moveml %sp@+,%d3-%d5/%a2-%a4
    unlk %fp
    rtd #14
    addqw #4,%sp
    bras GETDEVPIXMAP_158

/* CHECKDEVICES: CheckDevices: build the device list from the 'scrn' resource at start-up (skipped when the first device's flags bit 12 is set or the byte at 0xC2D is 0): match each video card to its entry, set modes, positions and color tables */
CHECKDEVICES:
    linkw %fp,#-136
    moveml %d6-%d7/%a2-%a4,%sp@-
    moveal DeviceList,%a0
    moveal %a0@,%a0
    movew %a0@(20),%d0
    btst #12,%d0
    jbne CHECKDEVICES_3DE
    tstb 0xc2d
    jbeq CHECKDEVICES_3DE
    clrl %sp@-
    movel #1935897198,%sp@-
    clrw %sp@-
    jsr @(0x1480,%za0)@(0x0)	| 40827BCC
    movel %sp@+,%d0
    jbeq CHECKDEVICES_3DE
    moveal DeviceList,%a0
    moveal %a0@,%a0
    bset #12,%a0@(20)
    movel %d0,%sp@-
    moveal %d0,%a0
    _HLock
    moveal %a0@,%a4
    movel %a4,%fp@(-136)
    movew %a4@+,%d7
    lea %fp@(-120),%a0
    movel #196609,%a0@(40)
    movew #1,%a0@(44)
    moveb #1,%a0@(48)
    clrb %a0@(49)
    clrb %a0@(50)
    clrb %a0@(51)
CHECKDEVICES_76:        /* for each 'scrn' entry: find the video card's sResource */
    lea %fp@(-120),%a0
    moveq #21,%d0	/* _SlotManager 21: NEXTTYPESRSRC, sNextTypesRsrc */
    _SlotManager
    jbeq CHECKDEVICES_88
    tstw %d7
    jbeq CHECKDEVICES_130
    jbra CHECKDEVICES_FE
CHECKDEVICES_88:        /* same type and ID? find its device by driver refNum */
    movew %a4@+,%d0
    cmpw %a0@(46),%d0
    jbne CHECKDEVICES_FE
    movew %a4@+,%d0
    cmpb %a0@(49),%d0
    jbne CHECKDEVICES_FE
    movew %a0@(38),%d0
    notw %d0
    aslw #2,%d0
    moveal UTableBase,%a1
    moveal %a1@(0x0,%d0:w),%a3
    moveal %a3@,%a1
    movel %a1@(42),%d0
    cmpl %a4@+,%d0
    jbne CHECKDEVICES_FE
    moveal DeviceList,%a3
    movew %a0@(38),%d1
CHECKDEVICES_BA:        /* next device */
    moveal %a3@,%a1
    cmpw %a1@,%d1
    jbeq CHECKDEVICES_CA
    movel %a1@(30),%d0
    moveal %d0,%a3
    jbne CHECKDEVICES_BA
    jbra CHECKDEVICES_FE
CHECKDEVICES_CA:        /* same size? skip the entry's controls */
    lea %a4@(10),%a4
    movew %a4@(4),%d0
    subw %a4@,%d0
    cmpw %a1@(38),%d0
    jbne CHECKDEVICES_FE
    movew %a4@(6),%d0
    subw %a4@(2),%d0
    cmpw %a1@(40),%d0
    jbne CHECKDEVICES_FE
    addqw #8,%a4
    movew %a4@+,%d0
    jbra CHECKDEVICES_F2
CHECKDEVICES_EE:        /* skip a control */
    movel %a4@+,%d1
    addaw %d1,%a4
CHECKDEVICES_F2:        /* next entry; all matched: apply the 'scrn' resource */
    dbf %d0,CHECKDEVICES_EE
    subqw #1,%d7
    jbmi CHECKDEVICES_FE
    jbra CHECKDEVICES_76
CHECKDEVICES_FE:        /* mismatch: lay the devices out side by side from the main one */
    moveal DeviceList,%a0
    moveal %a0@,%a0
    movew %a0@(40),%d1
CHECKDEVICES_108:       /* next device: move it right of the previous */
    movel %a0@(30),%d0
    jbeq CHECKDEVICES_3D8
    moveal %d0,%a0
    moveal %a0@,%a0
    addw %d1,%a0@(36)
    addw %d1,%a0@(40)
    moveal %a0@(22),%a1
    moveal %a1@,%a1
    addw %d1,%a1@(8)
    addw %d1,%a1@(12)
    movew %a0@(40),%d1
    jbra CHECKDEVICES_108
CHECKDEVICES_130:       /* hide the cursor, mouse to the main device's coordinates */
    jsr @(0xf48,%za0)@(0)	| 40827CD0
    moveb #1,CrsrBusy
    moveal CrsrDevice,%a0
    moveal %a0@,%a0
    movel %a0@(34),%d0
    subw %d0,Mouse_h
    swap %d0
    subw %d0,Mouse_v
    movel Mouse_v,MTemp_v
    movel Mouse_v,RawMouse_v
    moveal %fp@(-136),%a4
    movew %a4@+,%d7
    subqw #1,%d7
CHECKDEVICES_164:       /* next entry: the card's video sResource */
    lea %fp@(-120),%a0
    movel #196609,%a0@(40)
    movew #1,%a0@(44)
    movew %a4@+,%a0@(46)
    clrb %a0@(48)
    movew %a4@+,%d0
    moveb %d0,%a0@(49)
    clrb %a0@(50)
    clrb %a0@(51)
    moveq #21,%d0	/* _SlotManager 21: NEXTTYPESRSRC, sNextTypesRsrc */
    _SlotManager
    jbne CHECKDEVICES_FE
    movew %a0@(38),%d1
    moveal DeviceList,%a3
CHECKDEVICES_19C:       /* its device */
    moveal %a3@,%a0
    cmpw %a0@,%d1
    jbeq CHECKDEVICES_1AE
    movel %a0@(30),%d0
    moveal %d0,%a3
    jbne CHECKDEVICES_19C
    jbra CHECKDEVICES_FE
CHECKDEVICES_1AE:       /* the flags from the entry; the main screen: make it the main device */
    movel %a4@+,%d0
    moveal %a3@,%a1
    movew %a1@(20),%d0
    andw %a4@(2),%d0
    orw %a4@(4),%d0
    bset #10,%d0
    bset #13,%d0
    movew %d0,%a1@(20)
    movew %a1@(20),%d0
    btst #11,%d0
    jbeq CHECKDEVICES_224
    movel %a3,MainDevice
    movel %a3,TheGDevice
    movel %a3,SrcDevice
    moveal %a3@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    movel %a0@,%d0
    movel %d0,ScrnBase
    lea %fp@(-120),%a0
    movew %a4@,%d0
    moveb #0x80,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    moveb #1,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    moveal %a0@,%a1
    movew %a1@(4),ScreenRow
    movew %a1@(22),ScrHRes
    movew %a1@(26),ScrVRes
    movel %a1,%a0@(4)
    moveq #23,%d0	/* _SlotManager 23: SLOTDISPOSPTR, sDisposePtr */
    _SlotManager
CHECKDEVICES_224:       /* InitGDevice with the entry's mode; color table resource: none, default (-2) or 'clut' id */
    movew %d1,%sp@-
    movew %a4@+,%sp@-
    clrw %sp@-
    movel %a3,%sp@-
    jsr @(0x16b8,%za0)@(0)	| 40827DCC
    addqw #4,%a4
    movew %a4@(2),%d0
    cmpiw #-1,%d0
    jbeq CHECKDEVICES_29C
    cmpiw #-2,%d0
    jbne CHECKDEVICES_24E
    lea %fp@(-132),%a1
    clrl %a1@
    jbsr CHECKDEVICES_27C
    jbra CHECKDEVICES_29C
CHECKDEVICES_24E:       /* GetResource 'gama' and hand it to the driver */
    clrl %sp@-
    movel #1734438241,%sp@-
    movew %d0,%sp@-
    jsr @(0x1480,%za0)@(0x0)	| 40827DF8
    movel %sp@+,%d0
    jbeq CHECKDEVICES_29C
    movel %d0,%sp@-
    moveal %d0,%a0
    _HLock
    lea %fp@(-132),%a1
    movel %a0@,%a1@
    jbsr CHECKDEVICES_27C
    moveal %sp@,%a0
    _HUnlock
    jsr @(0x148c,%za0)@(0)	| 40827E14
    jbra CHECKDEVICES_29C
CHECKDEVICES_27C:       /* Control 4 (SetEntries) on the device's driver */
    lea %fp@(-64),%a0
    movel %a1,%a0@(28)
    movew #4,%a0@(26)
    clrl %a0@(12)
    clrw %a0@(22)
    moveal %a3@,%a1
    movew %a1@,%a0@(24)
    .short  0xA204	| 40827E38 _Control (flags 0x0200)
    rts
CHECKDEVICES_29C:       /* no table given: the default for the depth (gray or color by the flags) */
    moveal %a3@,%a1
    moveal %a1@(22),%a0
    moveal %a0@,%a0
    movew %a0@(32),%d0
    cmpiw #2,%a1@(4)
    jbeq CHECKDEVICES_364
    btst #0,%a1@(21)
    jbne CHECKDEVICES_2C6
    cmpiw #2,%d0
    jble CHECKDEVICES_2D4
    addiw #32,%d0
    jbra CHECKDEVICES_2E6
CHECKDEVICES_2C6:       /* monochrome flag: gray tables */
    movew %d0,%d1
    andiw #9,%d1
    jbne CHECKDEVICES_2D4
    addiw #64,%d0
    jbra CHECKDEVICES_2E6
CHECKDEVICES_2D4:       /* no table and no default asked: skip */
    movew %a4@,%d1
    cmpiw #-1,%d1
    bnew CHECKDEVICES_2E6
    cmpiw #-1,%a4@(2)
    jbeq CHECKDEVICES_364
CHECKDEVICES_2E6:       /* GetCTable and install it */
    clrl %sp@-
    movew %d0,%sp@-
    jsr @(0x1660,%za0)@(0x0)	| 40827E8A
    movel %sp@+,%d0
    jbeq CHECKDEVICES_364
    moveal %a3@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    movel %a0@(42),%sp@-
    movel %d0,%sp@-
    movel %d0,%sp@-
    movel %a0@(42),%sp@-
    jsr @(0x1a14,%za0)@(0)	| 40827EA8
    jsr @(0x1690,%za0)@(0x0)
    moveal %sp@,%a0
    _HLock
    lea %fp@(-132),%a1
    moveal %a0@,%a0
    clrw %a1@(4)
    movew %a0@(6),%a1@(6)
    lea %a0@(8),%a0
    movel %a0,%a1@
    lea %fp@(-64),%a0
    movel %a1,%a0@(28)
    movew #3,%a0@(26)
    clrl %a0@(12)
    clrw %a0@(22)
    moveal %a3@,%a1
    movew %a1@,%a0@(24)
    .short  0xA204	| 40827EEA _Control (flags 0x0200)
    moveal %sp@,%a0
    _HUnlock
    moveal %a3@,%a1
    movel %a1@(6),%sp@-
    moveq #4,%d0
    movew %d0,%a1@(10)
    movew %d0,%sp@-
    jsr @(0x16e4,%za0)@(0)	| 40827EFE
CHECKDEVICES_364:       /* the device's position (gdRect and bounds) from the entry; then its control calls */
    addqw #4,%a4
    moveal %a3@,%a0
    moveal %a0@(22),%a1
    moveal %a1@,%a1
    addqw #6,%a1
    lea %a0@(34),%a0
    movel %a4@+,%d0
    movel %d0,%a1@+
    movel %d0,%a0@+
    movel %a4@,%a1@
    movel %a4@+,%a0@+
    movew %a4@+,%d6
    jbra CHECKDEVICES_3A6
CHECKDEVICES_382:       /* one control call from the entry */
    lea %fp@(-64),%a0
    lea %a4@(4),%a1
    movel %a1,%a0@(28)
    movew %a4@+,%a0@(26)
    clrl %a0@(12)
    clrw %a0@(22)
    moveal %a3@,%a1
    movew %a1@,%a0@(24)
    .short  0xA204	| 40827F40 _Control (flags 0x0200)
    movew %a4@+,%d0
    addaw %d0,%a4
CHECKDEVICES_3A6:       /* next control; next entry; mouse back to global coordinates, show the cursor */
    dbf %d6,CHECKDEVICES_382
    dbf %d7,CHECKDEVICES_164
    moveal CrsrDevice,%a0
    moveal %a0@,%a0
    movel %a0@(34),%d0
    addw %d0,Mouse_h
    swap %d0
    addw %d0,Mouse_v
    movel Mouse_v,MTemp_v
    movel Mouse_v,RawMouse_v
    clrb CrsrBusy
    jsr @(0xf4c,%za0)@(0)	| 40827F72
CHECKDEVICES_3D8:       /* release the resource */
    jsr @(0x148c,%za0)@(0)	| 40827F78
CHECKDEVICES_3DE:       /* return */
    moveml %sp@+,%d6-%d7/%a2-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40827F86

/* GETGDEVICE: _GetGDevice. */
trap_GetGDevice:
GETGDEVICE:
    moveal %sp@+,%a0
    movel TheGDevice,%sp@
    jmp %a0@
    .long   0x00000000, 0x00000000	| 40827F98

/* SETGDEVICE: _SetGDevice. */
trap_SetGDevice:
SETGDEVICE:
    moveal %sp@+,%a0
    movel %sp@+,TheGDevice
    jmp %a0@
    .long   0x00000000, 0x00000000	| 40827FA8

/* GETDEVICELIST: _GetDeviceList. */
trap_GetDeviceList:
GETDEVICELIST:
    moveal %sp@+,%a0
    movel DeviceList,%sp@
    jmp %a0@
    .long   0x00000000, 0x00000000	| 40827FB8

/* GETMAINDEVICE: _GetMainDevice. */
trap_GetMainDevice:
GETMAINDEVICE:
    moveal %sp@+,%a0
    movel MainDevice,%sp@
    jmp %a0@
    .long   0x00000000, 0x00000000	| 40827FC8

/* GETNEXTDEVICE: _GetNextDevice. */
trap_GetNextDevice:
GETNEXTDEVICE:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    moveal %a1@,%a1
    movel %a1@(30),%sp@
    jmp %a0@
    .long   0x00000000	| 40827FDC

/* TESTDEVICEATTRIBUTE: _TestDeviceAttribute. */
trap_TestDeviceAttribute:
TESTDEVICEATTRIBUTE:
    moveal %sp@+,%a1
    movew %sp@+,%d0
    moveal %sp@+,%a0
    clrb %sp@
    moveal %a0@,%a0
    movew %a0@(20),%d1
    btst %d0,%d1
    jbeq TESTDEVICEATTRIBUTE_14
    addqb #1,%sp@
TESTDEVICEATTRIBUTE_14: /* return */
    jmp %a1@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40827FF6

/* SETDEVICEATTRIBUTE: _SetDeviceAttribute. */
trap_SetDeviceAttribute:
SETDEVICEATTRIBUTE:
    moveal %sp@+,%a1
    moveb %sp@+,%d0
    movew %sp@+,%d1
    moveal %sp@+,%a0
    moveal %a0@,%a0
    movew %a0@(20),%d2
    tstb %d0
    jbne SETDEVICEATTRIBUTE_16
    bclr %d1,%d2
    jbra SETDEVICEATTRIBUTE_18
SETDEVICEATTRIBUTE_16:  /* set */
    bset %d1,%d2
SETDEVICEATTRIBUTE_18:  /* store, return */
    movew %d2,%a0@(20)
    jmp %a1@
    .short  0x0000	| 4082801E

/* GETMAXDEVICE: _GetMaxDevice. */
trap_GetMaxDevice:
GETMAXDEVICE:
    linkw %fp,#-8
    moveml %d3/%a3,%sp@-
    clrl %fp@(12)
    moveq #0,%d3
    moveal DeviceList,%a3
GETMAXDEVICE_12:        /* next active device: intersects the rectangle? deeper than the best so far? */
    moveal %a3@,%a0
    tstw %a0@(20)
    jbpl GETMAXDEVICE_48
    clrb %sp@-
    movel %fp@(8),%sp@-
    pea %a0@(34)
    pea %fp@(-8)
    jsr @(0x10a8,%za0)@(0)	| 40828048
    tstb %sp@+
    jbeq GETMAXDEVICE_48
    moveal %a3@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    movew %a0@(32),%d0
    cmpw %d3,%d0
    jble GETMAXDEVICE_48
    movew %d0,%d3
    movel %a3,%fp@(12)
GETMAXDEVICE_48:        /* next device; return the deepest */
    moveal %a3@,%a0
    movel %a0@(30),%d0
    moveal %d0,%a3
    jbne GETMAXDEVICE_12
    moveml %sp@+,%d3/%a3
    unlk %fp
    rtd #4
    .long   0x00000000	| 4082807C

/* GETDEVPIX: GetDevPix: a0 = TheGDevice's pixmap pointer */
GETDEVPIX:
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    rts
    .short  0x0000	| 4082808E

/* ALLOCCURSOR: _AllocCursor. */
trap_AllocCursor:
ALLOCCURSOR:
    lea %pc@(ALLOCCRSR),%a0
    movel CrsrSave,%d0
    jbeq ALLOCCURSOR_C
    moveal %d0,%a0
ALLOCCURSOR_C:          /* through CrsrSave's patched routine if any */
    jmp %a0@
    .short  0x0000	| 4082809E

/* INITCURSOR: _InitCursor. */
trap_InitCursor:
INITCURSOR:
    moveal %a5@,%a0
    pea %a0@(-108)
    jsr @(0xf44,%za0)@(0)	| 408280A6
    moveal JInitCrsr,%a0
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408280B2

/* SETCURSOR: _SetCursor. */
trap_SetCursor:
SETCURSOR:
    moveal %sp@(4),%a0
    movel %a0@(64),%sp@-
    movew #16,%sp@-
    pea %a0@
    pea %a0@(32)
    moveal JSetCrsr,%a0
    jsr %a0@
    movel %sp@+,%sp@
    rts
    .long   0x00000000	| 408280DC

/* SETCCURSOR: _SetCCursor. */
trap_SetCCursor:
SETCCURSOR:
    movel %sp@(4),%sp@-
    moveal JSetCCrsr,%a0
    jsr %a0@
    movel %sp@+,%sp@
    rts
    .short  0x0000	| 408280EE

/* HIDECURSOR: _HideCursor. */
trap_HideCursor:
HIDECURSOR:
    movel GrafBegin_JHideCursor,%sp@-
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408280F6

/* SHOWCURSOR: _ShowCursor. */
trap_ShowCursor:
SHOWCURSOR:
    movel JShowCursor,%sp@-
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40828106

/* SHIELDCURSOR: _ShieldCursor. */
trap_ShieldCursor:
SHIELDCURSOR:
    moveml %d0-%d3/%a0-%a1,%sp@-
    moveal %sp@(32),%a0
    movemw %a0@+,%d0-%d3
    lea %sp@(28),%a1
    subw %a1@,%d0
    subw %a1@+,%d2
    subw %a1@,%d1
    subw %a1@,%d3
    movew %d1,%sp@-
    movew %d0,%sp@-
    movew %d3,%sp@-
    movew %d2,%sp@-
    moveal JShieldCursor,%a0
    jsr %a0@
    moveml %sp@+,%d0-%d3/%a0-%a1
    movel %sp@+,%sp@
    movel %sp@+,%sp@
    rts

/* OBSCURECURSOR: _ObscureCursor. */
trap_ObscureCursor:
OBSCURECURSOR:
    moveal JCrsrObscure,%a0
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40828146
