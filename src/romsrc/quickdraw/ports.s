/*
 quickdraw/ports.s - color ports, color tables, pixmaps, icons, InitGraf
 From OPENCPORT (0x408300F0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* OPENCPORT: _OpenCPort: open a color port. */
trap_OpenCPort:
OPENCPORT:
    movel %sp@(4),%sp@-
    movel %sp@,%sp@-
    jsr %pc@(NEWPORT)
    jsr %pc@(INSPORTLIST)
    clrl %sp@-
    movew #50,%sp@-
    jsr %pc@(NEWHANDLE)
    moveal %sp@(8),%a0
    movel %sp@+,%a0@(2)
    clrl %a0@(32)
    clrl %a0@(58)
    clrl %a0@(62)
    clrl %a0@(8)
    movew #-16384,%a0@(6)

/* INITCPORT: _InitCPort. */
trap_InitCPort:
INITCPORT:
    movel %a2,%sp@-
    moveal %sp@(8),%a2
    tstw %a2@(6)
    bplw INITCPORT_34
    jsr %pc@(INITSHARED)
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %a2@(2),%a1
    moveal %a1@,%a1
    movew #24,%d0
INITCPORT_28:           /* copy the device pixmap into the port's pixmap; colors */
    movew %a0@+,%a1@+
    dbf %d0,INITCPORT_28
    movel %a2,%sp@-
    jsr %pc@(INITCOLORSTUFF)
INITCPORT_34:           /* return */
    moveal %sp@+,%a2
    movel %sp@+,%sp@
    rts

/* INITCOLORSTUFF: InitColorStuff(port): a new color port's colors: black foreground, white background (RGBForeColor/RGBBackColor), then the default patterns */
INITCOLORSTUFF:
    movel %a2,%sp@-
    moveal %sp@(8),%a2
    clrl %sp@-
    clrl %sp@-
    movel %sp,%sp@-
    pea %a2@(32)
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x1a44,%za0)@(0)	| 40830170
    notl %sp@
    notl %sp@(4)
    movel %sp,%sp@-
    pea %a2@(58)
    jsr @(0x1a44,%za0)@(0)	| 40830182
    movel %sp,%sp@-
    pea %a2@(62)
    jsr @(0x1a44,%za0)@(0)	| 4083018E
    addqw #8,%sp
    movel #33,%sp@-
    jsr @(0xf88,%za0)@(0)	| 4083019C
    movel #30,%sp@-
    jsr @(0xf8c,%za0)@(0)	| 408301A8
    movel #32768,%a2@(12)
    tstl %a2@(8)
    jbne INITCOLORSTUFF_66
    moveq #26,%d0
    jsr %pc@(RNEWHANDLE)
    movel %a0,%a2@(8)
INITCOLORSTUFF_66:      /* grafVars: op color black, hilite color from HiliteRGB (0xDA0) */
    moveal %a2@(8,%za0)@(0),%a0	| 408301C6
    clrl %a0@+
    clrw %a0@+
    movel HiliteRGB,%a0@+
    movew 0xda4,%a0@+
    moveal %sp@+,%a2
    movel %sp@+,%sp@
    rts
    .short  0x0000	| 408301DE

/* CLOSEPORT: _ClosePort. */
trap_ClosePort:
CLOSECPORT:
CLOSEPORT:
    movel %sp@(4),%sp@-
    jsr %pc@(DELPORTLIST)
    moveal %sp@(4),%a0
    moveal %a0@(28),%a0
    _DisposHandle
    moveal %sp@(4),%a0
    moveal %a0@(24),%a0
    _DisposHandle
    moveal %sp@(4),%a0
    tstw %a0@(6)
    jbpl CLOSECPORT_7C
    moveq #-1,%d0
    tstl %a0@(32)
    jbeq CLOSECPORT_34
    addqw #1,%d0
    movel %a0@(32),%sp@-
CLOSECPORT_34:          /* the pen pixpat */
    tstl %a0@(58)
    jbeq CLOSECPORT_40
    addqw #1,%d0
    movel %a0@(58),%sp@-
CLOSECPORT_40:          /* the fill pixpat */
    tstl %a0@(62)
    jbeq CLOSECPORT_4C
    addqw #1,%d0
    movel %a0@(62),%sp@-
CLOSECPORT_4C:          /* dispose of the pixpats not shared (DisposPixPat) */
    tstw %d0
    jbmi CLOSECPORT_68
CLOSECPORT_50:          /* next */
    moveal %sp@+,%a0
    tstw %a0@(0,%za0)@(0)	| 40830232
    jbne CLOSECPORT_64
    movew %d0,%sp@-
    movel %a0,%sp@-
    jsr @(0x1620,%za0)@(0x0)	| 4083023C
    movew %sp@+,%d0
CLOSECPORT_64:          /* next */
    dbf %d0,CLOSECPORT_50
CLOSECPORT_68:          /* dispose of the pixmap and grafVars */
    moveal %sp@(4),%a0
    moveal %a0@(2),%a0
    _DisposHandle
    moveal %sp@(4),%a0
    moveal %a0@(8),%a0
    _DisposHandle
CLOSECPORT_7C:          /* return */
    rtd #4

/* SETCPORTPIX: SetCPortPix(pm): a color port's portPixMap = pm; an old port: SetPortBits */
trap_SetPortPix:
SETCPORTPIX:
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(6)
    jbpl SETCPORTPIX_10
    movel %sp@(4),%a0@(2)
SETCPORTPIX_10:         /* return */
    rtd #4
    .long   0x00000000, 0x00000000, 0x00000000	| 40830274

/* NEWCTAB: new color table. */
NEWCTAB:
    clrl %sp@-
    movew #24,%sp@-
    jsr %pc@(NEWHANDLE)
    movel %sp@+,%sp@(4)
    rts

/* DISPOSCTABLE: _DisposCTable. */
trap_DisposCTable:
DISPOSCTABLE:
    moveal %sp@+,%a1
    movel %sp@+,%d0
    jbeq DISPOSCTABLE_A
    moveal %d0,%a0
    _DisposHandle
DISPOSCTABLE_A:         /* return */
    jmp %a1@
    .long   0x00000000	| 4083029C

/* GETCTSEED: _GetCTSeed. */
trap_GetCTSeed:
GETCTSEED:
    movel %d0,%sp@-
    movel TableSeed,%d0
    addql #1,%d0
    jbmi GETCTSEED_18
    cmpil #1023,%d0
    jbgt GETCTSEED_18
    movel #1023,%d0
GETCTSEED_18:           /* the next seed (at least 1024, in 0xD20) */
    movel %d0,TableSeed
    movel %sp@+,%d0
    movel TableSeed,%sp@(4)
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408302C6

/* OPENPIXMAP: OpenPixMap: a new 50-byte pixmap handle with an empty color table */
OPENPIXMAP:
    clrl %sp@-
    movew #50,%sp@-
    jsr %pc@(NEWHANDLE)
    clrl %sp@-
    jsr %pc@(NEWCTAB)
    movel %sp@+,%d0
    moveal %sp@+,%a0
    movel %a0,%sp@(4)
    moveal %a0@,%a0
    movel %d0,%a0@(42)
    rts

/* NEWPIXMAP: _NewPixMap. */
trap_NewPixMap:
NEWPIXMAP:
    clrl %sp@-
    jsr %pc@(OPENPIXMAP)
    movel %sp@,%sp@(8)
    jsr %pc@(INITPIXMAP)
    rts

/* DISPOSPIXMAP: _DisposPixMap. */
trap_DisposPixMap:
DISPOSPIXMAP:
    movel %sp@(4),%d0
    jbeq DISPOSPIXMAP_1E
    moveal %d0,%a1
    moveal %a1@,%a1
    movel %a1@(42),%d0
    jbeq DISPOSPIXMAP_18
    movel %d0,%sp@-
    jsr @(0x1690,%za0)@(0x0)	| 40830312
DISPOSPIXMAP_18:        /* dispose of its color table, then it */
    moveal %sp@(4),%a0
    _DisposHandle
DISPOSPIXMAP_1E:        /* return */
    movel %sp@+,%sp@
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40830322

/* INITPIXMAP: InitPixMap(pm): copy the current device's pixmap fields (TheGDevice) into pm, keeping pm's own color table */
INITPIXMAP:
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    moveal %sp@(4),%a1
    moveal %a1@,%a1
    movel %a1@(42),%sp@-
    movel %a1,%sp@-
    moveq #24,%d0
INITPIXMAP_1A:          /* copy, keep the color table; mark it a pixmap (rowBytes bit 15) */
    movew %a0@+,%a1@+
    dbf %d0,INITPIXMAP_1A
    moveal %sp@+,%a1
    movel %sp@+,%a1@(42)
    oriw #-32768,%a1@(4)
    movel %sp@+,%sp@
    rts

/* COPYPIXMAP: _CopyPixMap. */
trap_CopyPixMap:
COPYPIXMAP:
    moveal %sp@(8),%a0
    moveal %a0@,%a0
    moveal %sp@(4),%a1
    moveal %a1@,%a1
    moveq #20,%d0
COPYPIXMAP_E:           /* copy the fields, then the color table (CopyHandle) */
    movew %a0@+,%a1@+
    dbf %d0,COPYPIXMAP_E
    movel %a0@(4),%a1@(4)
    movel %a0@,%sp@-
    movel %a1@,%sp@-
    jsr @(0x1a14,%za0)@(0)	| 4083037E
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 4083038A

/* BITSTOPIX: BitsToPix(bitmap/pixmap, dst): a bitmap or (color port) pixmap as a full pixmap: plain bitmaps get the 1-bit fields; the screen's base address is checked against the QuickDraw globals' screenBits */
trap_BITSTOPIX:
BITSTOPIX:
    moveq #0,%d2
    movew %a1@(4),%d0
    jbpl BITSTOPIX_26
    btst #14,%d0
    jbeq BITSTOPIX_12
    moveal %a1@,%a1
    moveal %a1@,%a1
BITSTOPIX_12:           /* a pixmap handle: is it the screen? */
    movel %a1@(6),%d1
    moveal %a5@,%a0
    lea %a0@(-122),%a0
    movel %a0@,%d0
    cmpl %a1@,%d0
    jbne COPYPMAP
    jbra BITSTOPIX_36
BITSTOPIX_26:           /* a bitmap: is it the screen (screenBits)? */
    movel %a1@(6),%d1
    moveal %a5@,%a0
    lea %a0@(-122),%a0
    movel %a0@,%d0
    cmpl %a1@,%d0
    jbne BITSTOPIX_76
BITSTOPIX_36:           /* the screen: the device's pixmap, bounds offset to the bitmap's */
    moveq #1,%d2
    moveal TheGDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    movel %a0@+,%a2@+
    movew %a0@+,%a2@+
    cmpl %a1@(10),%d1
    jbne BITSTOPIX_56
    movel %d1,%a2@+
    movel %d1,%a2@+
    addql #8,%a0
    jbra BITSTOPIX_72
BITSTOPIX_56:           /* offset the bounds */
    movel %a0@+,%d0
    addw %d1,%d0
    swap %d0
    swap %d1
    addw %d1,%d0
    swap %d0
    movel %d0,%a2@+
    movel %a0@+,%d0
    swap %d0
    addw %d1,%d0
    swap %d0
    swap %d1
    addw %d1,%d0
    movel %d0,%a2@+
BITSTOPIX_72:           /* the rest of the fields */
    moveal %a0,%a1
    jbra COPYPMAP_16
BITSTOPIX_76:           /* an ordinary bitmap: 1-bit pixmap fields (ONEBITDATA, FILLONEBIT) */
    lea %pc@(ONEBITDATA),%a0
    pea %pc@(BITSTOPIX_A6)
    movel %a1@,%d0
    jsr @(0x644,%za0)@(0x0)	| 40830410
    movel %d0,%a2@+
    exg %a0,%a1
    lea %a1@(14),%a1
    addqw #4,%a0
    movew %a0@+,%d0
    andiw #32767,%d0
    muluw %a1@(18),%d0
    oriw #-32768,%d0
    movew %d0,%a2@+
    movel %a0@+,%a2@+
    movel %a0@+,%a2@+
    jbra COPYPMAP_16
BITSTOPIX_A6:           /* the fake color table */
    movel %a2,%a2@(-8)
    lea %a2@(4),%a0
    movel %a0,%a2@
    moveal %sp@+,%a1
    jmp %pc@(FILLONEBIT)
BITSTOPIX_B6:           /* a GWorld pixmap (pmVersion): base address through its handle / 32-bit */
    moveal %a1@+,%a0
    btst #1,%d0
    jbeq BITSTOPIX_C0
    moveal %a0@,%a0
BITSTOPIX_C0:           /* StripAddress or not */
    btst #2,%d0
    exg %d0,%a0
    jbeq COPYPMAP_8
    jbra COPYPMAP_E

/* COPYPMAP: CopyPMap: copy a pixmap's fields, the base address through StripAddress (vector 0x644) */
COPYPMAP:
    movew %a1@(14),%d0
    jbne BITSTOPIX_B6
    movel %a1@+,%d0
COPYPMAP_8:             /* StripAddress the base */
    jsr @(0x644,%za0)@(0x0)	| 40830462
COPYPMAP_E:             /* base, rowBytes, bounds */
    movel %d0,%a2@+
    movew %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
COPYPMAP_16:            /* the remaining fields */
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    movel %a1@+,%a2@+
    rts
/* ONEBITDATA: OneBitData: the fixed fields of a 1-bit pixmap (data) */
ONEBITDATA:
    .long   0x00000000, 0x00000000, 0x00000000	| 40830484
    .long   0x00000000, 0x00000000	| 40830490
    .long   trap_SetCPixel-.	| 40830498
    .long   0x00000048	| 4083049C
    .long   0x00000000, 0x00010001, 0x00010000, 0x00000000	| 408304A0
    .short  0x0000, 0x0000, 0x0000	| 408304B0

/* SHFTTBL: table. */
SHFTTBL:
    .byte   0x00, 0x00	| 408304B6
    btst %d0,%d0	| 408304B8
    andib #0,%d0	| 408304BA
    btst %d1,%d0	| 408304BE
    orib #0,%d0	| 408304C0
    .short  0x0000, 0x0400, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408304C4 orib #0,%d0
    .short  0x0000, 0x0500, 0x0000, 0x0000, 0x0000, 0x0000	| 408304D4 orib #0,%d0

/* SETCPIXEL: _SetCPixel. */
trap_SetCPixel:
SETCPIXEL:
    linkw %fp,#-24
    pea %fp@(-18)
    jsr @(0x1060,%za0)@(0x0)	| 408304E8
    pea %fp@(-24)
    jsr @(0x1664,%za0)@(0x0)	| 408304F2
    movel %fp@(8),%sp@-
    jsr @(0x1650,%za0)@(0x0)	| 408304FC
    jsr @(0x1078,%za0)@(0x0)
    movel %fp@(12),%sp@-
    jsr @(0x104c,%za0)@(0)	| 4083050C
    clrl %sp@-
    jsr @(0x1048,%za0)@(0x0)	| 40830514
    pea %fp@(-24)
    jsr @(0x1650,%za0)@(0x0)	| 4083051E
    pea %fp@(-18)
    jsr @(0x1064,%za0)@(0x0)	| 40830528
    unlk %fp
    rtd #8
    .long   0x00000000, 0x00000000, 0x00000000	| 40830534

/* HILITECOLOR: _HiliteColor. */
trap_HiliteColor:
HILITECOLOR:
    moveq #6,%d0
    jbra SETGRAFVARSCOMMON
    .long   0x00000000, 0x00000000, 0x00000000	| 40830544

/* OPCOLOR: _OpColor. */
trap_OpColor:
OPCOLOR:
    moveq #0,%d0
/* SETGRAFVARSCOMMON: SetGrafVarsCommon: store an RGB (6 bytes) at offset d0 of a color port's grafVars (rgbOpColor, rgbHiliteColor) */
SETGRAFVARSCOMMON:
    movel %sp@+,%d2
    moveal %sp@+,%a1
    moveal %a5@(0,%za0)@(0),%a0	| 40830556
    tstw %a0@(6)
    jbpl SETGRAFVARSCOMMON_1A
    moveal %a0@(8,%za0)@(0),%a0	| 40830560
    addaw %d0,%a0
    movel %a1@+,%a0@+
    movew %a1@,%a0@
SETGRAFVARSCOMMON_1A:   /* return */
    moveal %d2,%a0
    jmp %a0@

/* GETCCURSOR: _GetCCursor. */
trap_GetCCursor:
GETCCURSOR:
    movew %sp@(4),%d0
    movel #1668445042,%d1
    moveq #96,%d2
    jbra PATSHARE
    .short  0x0000	| 4083057E

/* GETPIXPAT: _GetPixPat. */
trap_GetPixPat:
GETPIXPAT:
    movew %sp@(4),%d0
    movel #1886413172,%d1
    moveq #28,%d2
/* PATSHARE: PatShare: get a 'ppat' resource (GetResource), detach it, and make a pixpat from it (GetPixPat, GetPPat) */
PATSHARE:
    linkw %fp,#0
    moveml %d3/%a2-%a4,%sp@-
    movel %d2,%d3
    clrl %fp@(10)
    subqw #4,%sp
    movel %d1,%sp@-
    movew %d0,%sp@-
    jsr @(0x1480,%za0)@(0x0)	| 408305A0
    moveal %sp@+,%a0
    movel %a0,%d0
    jbeq PATSHARE_F8
    jsr @(0x1584,%za0)@(0x0)	| 408305AE
    jbne PATSHARE_F8
    moveal %a0,%a3
    _HLock
    moveal %a3@,%a2
    moveal %a2,%a0
    addal %a2@(2),%a0
    moveq #50,%d0
    jsr @(0x158c,%za0)@(0)	| 408305C6
    jbne PATSHARE_F8
    moveal %a0,%a4
    moveal %a4@,%a1
    clrl %a1@(42)
    moveal %a2,%a0
    moveal %a2,%a1
    addal %a2@(2),%a1
    cmpiw #16,%a1@(30)
    jbeq PATSHARE_8A
    addal %a1@(42),%a0
    movew %a0@(6),%d0
    addqw #1,%d0
    muluw #8,%d0
    addqw #8,%d0
    extl %d0
    jsr @(0x158c,%za0)@(0)	| 408305FA
    bnew PATSHARE_F8
    moveal %a4@,%a1
    movel %a0,%a1@(42)
    clrl %sp@-
    jsr @(0x16a0,%za0)@(0)	| 4083060C
    moveal %a0@,%a0
    movel %sp@+,%a0@
PATSHARE_8A:            /* copy the pattern data from the resource into the pixpat */
    moveal %a2,%a0
    moveal %a2,%a1
    addal %a2@(2),%a1
    movel %a1@(42),%d0
    subl %a2@(6),%d0
    addal %a2@(6),%a0
    jsr @(0x158c,%za0)@(0)	| 4083062A
    bnew PATSHARE_F8
    movel %a0,%a2@(6)
    moveq #2,%d0
    .short  0xA122	| 4083063A _NewHandle (flags 0x0100)
    bnew PATSHARE_F8
    movel %a0,%a2@(10)
    cmpiw #96,%d3
    jbeq PATSHARE_CA
    moveq #22,%d0
    .short  0xA122	| 4083064C _NewHandle (flags 0x0100)
    bnew PATSHARE_F8
    movel %a0,%a2@(16)
PATSHARE_CA:            /* install it; shrink the resource copy */
    movel %a4,%a2@(2)
    moveal %a3,%a0
    _HUnlock
    movel %d3,%d0
    jsr %pc@(RSETHSIZE)
    cmpiw #96,%d3
    bnes PATSHARE_CA_24
    clrl %sp@-
    jsr @(0x16a0,%za0)@(0)	| 4083066C
    moveal %a3@,%a0
    movel %sp@+,%a0@(92)
    bras PATSHARE_CA_2A
PATSHARE_CA_24:         /* no pattern data: mark the pixpat as needing expansion (-1) */
    movew #-1,%a2@(14)
PATSHARE_CA_2A:         /* return the pixpat */
    movel %a3,%fp@(10)
PATSHARE_F8:            /* restore registers, return */
    moveml %sp@+,%d3/%a2-%a4
    unlk %fp
    rtd #2
    .short  0x0000	| 4083068E

/* NEWPIXPAT: _NewPixPat. */
trap_NewPixPat:
NEWPIXPAT:
    clrl %sp@-
    movew #22,%sp@-
    jsr %pc@(NEWHANDLE)
    clrl %sp@-
    movew #28,%sp@-
    jsr %pc@(NEWHANDLE)
    clrl %sp@-
    jsr @(0x160c,%za0)@(0)	| 408306A6
    moveal %sp@,%a0
    clrl %sp@-
    movew #8,%sp@-
    jsr %pc@(NEWHANDLE)
    clrl %sp@-
    clrw %sp@-
    jsr %pc@(NEWHANDLE)
    movel %sp@+,%d2
    movel %sp@+,%d1
    movel %sp@+,%d0
    moveal %sp@+,%a1
    movel %a1,%sp@(8)
    moveal %a1@,%a0
    movel %d0,%a0@(2)
    movel %d1,%a0@(6)
    movel %d2,%a0@(10)
    movel %sp@+,%a0@(16)
    movel #-1437226411,%d0
    movel %d0,%a0@(20)
    movel %d0,%a0@(24)
    movew #1,%a0@
    movew #-1,%a0@(14)
    rts
    .long   0x00000000, 0x00000000	| 408306F8

/* DISPOSPIXPAT: _DisposPixPat. */
trap_DisposPixPat:
DISPOSCCURSOR:
DISPOSPIXPAT:
    movel %sp@(4),%d0
    jbeq DISPOSCCURSOR_6E
DISPOSCCURSOR_6:        /* (DisposPixPat) not an old pattern: dispose of its data, expanded data, xmap and pixmap */
    moveal %d0,%a1
    movel %a1@,%d0
    jbeq DISPOSCCURSOR_6E
    moveal %d0,%a1
    movew %a1@,%sp@-
    jbmi DISPOSCCURSOR_18
    moveal %a1@(16),%a0
    _DisposHandle
DISPOSCCURSOR_18:       /* then clear it from the ports that use it (port list) */
    moveal %a1@(6),%a0
    _DisposHandle
    moveal %a1@(10),%a0
    _DisposHandle
    movel %a1@(2),%sp@-
    jsr @(0x1610,%za0)@(0x0)	| 40830728
    moveal %sp@(6),%a0
    movel %a0,%d2
    _DisposHandle
    tstw %sp@+
    jbmi DISPOSCCURSOR_6E
    moveal PortList,%a1
    moveal %a1@,%a1
    movew %a1@+,%d0
    jbra DISPOSCCURSOR_6A
DISPOSCCURSOR_44:       /* each color port: bkPixPat, pnPixPat, fillPixPat */
    moveal %a1@+,%a0
    tstw %a0@(6)
    jbpl DISPOSCCURSOR_6A
    cmpl %a0@(58),%d2
    jbne DISPOSCCURSOR_56
    clrl %a0@(58)
DISPOSCCURSOR_56:       /* pen */
    cmpl %a0@(32),%d2
    jbne DISPOSCCURSOR_60
    clrl %a0@(32)
DISPOSCCURSOR_60:       /* fill */
    cmpl %a0@(62),%d2
    jbne DISPOSCCURSOR_6A
    clrl %a0@(62)
DISPOSCCURSOR_6A:       /* next port */
    dbf %d0,DISPOSCCURSOR_44
DISPOSCCURSOR_6E:       /* return */
    movel %sp@+,%sp@
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40830772

/* SETFILLPAT: SetFillPat(pat): the port's fill pattern: a pixpat (color port) or an old pattern */
trap_SETFILLPAT:
SETFILLPAT:
    moveal %sp@(4),%a1
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %d0
    jbeq SETFILLPAT_14
    movel %a1,%sp@-
    jsr %pc@(PHILPIXPAT)
    jbra SETFILLPAT_30
SETFILLPAT_14:          /* old pattern to a color port: through OldPatToNew */
    tstw %a0@(6)
    jbpl SETFILLPAT_28
    movel %a1,%sp@-
    pea %a0@(62)
    jsr @(0x1a44,%za0)@(0)	| 408307A0
    jbra SETFILLPAT_30
SETFILLPAT_28:          /* old port: copy the pattern */
    lea %a0@(40),%a0
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
SETFILLPAT_30:          /* return */
    rtd #4
    .long   0x00000000, 0x00000000, 0x00000000	| 408307B4

/* PENPIXPAT: _PenPixPat. */
trap_PenPixPat:
PENPIXPAT:
    moveq #58,%d0
    moveq #58,%d1
    jbra BACKPIXPAT_4

/* PHILPIXPAT: PhilPixPat: set the fill pixpat (port offset 62, old pattern at 40) through BACKPIXPAT's common code */
PHILPIXPAT:
    moveq #62,%d0
    moveq #40,%d1
    jbra BACKPIXPAT_4

/* BACKPIXPAT: _BackPixPat. */
trap_BackPixPat:
BACKPIXPAT:
    moveq #32,%d0
    moveq #32,%d1
BACKPIXPAT_4:           /* old port: the pixpat's nearest gray (RGB type: PUTGRAY) as the old pattern */
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(6)
    jbmi BACKPIXPAT_42
    moveal %sp@(4),%a1
    moveal %a1@,%a1
    cmpiw #2,%a1@
    jbeq BACKPIXPAT_28
    lea %a1@(20),%a1
    lea %a0@(0x0,%d1:w),%a0
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    jbra BACKPIXPAT_66
BACKPIXPAT_28:          /* type 2: from the RGB */
    moveal %a1@(2),%a1
    moveal %a1@,%a1
    moveal %a1@(42),%a1
    moveal %a1@,%a1
    pea %a1@(42)
    pea %a0@(0x0,%d1:w)
    jsr %pc@(PUTGRAY)
    jbra BACKPIXPAT_66
BACKPIXPAT_42:          /* color port: dispose of an old type-0 pixpat it replaces */
    movel %a0@(0x0,%d0:w),%d1
    jbeq BACKPIXPAT_5C
    moveal %d1,%a0
    moveal %a0@,%a0
    tstw %a0@
    jbne BACKPIXPAT_5C
    movew %d0,%sp@-
    movel %d1,%sp@-
    jsr @(0x1620,%za0)@(0x0)	| 40830820
    movew %sp@+,%d0
BACKPIXPAT_5C:          /* store the handle */
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %sp@(4),%a0@(0x0,%d0:w)
BACKPIXPAT_66:          /* return */
    movel %sp@+,%sp@
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40830836

/* COPYPIXPAT: _CopyPixPat. */
trap_CopyPixPat:
COPYPIXPAT:
    moveq #4,%d0
    moveal %sp@(8),%a0
    moveal %a0@,%a0
    moveal %sp@(4),%a1
    moveal %a1@,%a1
    movew %a0@+,%a1@+
    movel %a0@+,%sp@-
    movel %a1@+,%sp@-
    movel %a0@+,%sp@-
    movel %a1@+,%sp@-
    movel %a0@+,%sp@-
    movel %a1@+,%sp@-
    movew %a0@+,%a1@+
    movel %a0@+,%sp@-
    movel %a1@+,%sp@-
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    jsr @(0x1a14,%za0)@(0)	| 40830866
    jsr @(0x1a14,%za0)@(0)
    jsr @(0x1a14,%za0)@(0)
    jsr @(0x1614,%za0)@(0x0)
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 40830884

/* OLDPATTONEW: OldPatToNew(pat, ppHandle): make or update a type 0 pixpat holding an old 8x8 pattern */
trap_OLDPATTONEW:
OLDPATTONEW:
    linkw %fp,#0
    moveml %a2-%a3,%sp@-
    moveal %fp@(8),%a0
    movel %a0@,%d0
    jbeq OLDPATTONEW_18
    moveal %d0,%a3
    moveal %a3@,%a1
    tstw %a1@
    jbeq OLDPATTONEW_3C
OLDPATTONEW_18:         /* no pixpat yet: a new one (NewPixPat) */
    clrl %sp@-
    jsr @(0x161c,%za0)@(0)	| 408308AA
    moveal %fp@(8),%a0
    movel %sp@+,%a0@
    moveal %a0@,%a3
    moveal %a3@,%a1
    clrw %a1@
    moveal %a1@(2),%a1
    moveal %a1@,%a1
    movel %a1@(42),%sp@-
    jsr %pc@(ONEBITCTABLE)
    moveal %a3@,%a1
OLDPATTONEW_3C:         /* type 0: the pattern in its data, both as pixel data and the old pattern */
    movew #-1,%a1@(14)
    moveal %a1@(6),%a0
    moveal %a0@,%a0
    moveal %fp@(12),%a1
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    moveal %a3@,%a2
    moveal %a2@(2),%a2
    moveal %a2@,%a2
    moveal %a2,%a3
    movel %a3@(42),%sp@-
    lea %pc@(ONEBITDATA),%a1
    jsr %pc@(COPYPMAP)
    movew #1,%a3@(4)
    clrl %a3@(6)
    movel #524296,%a3@(10)
    movel %sp@+,%a3@(42)
    moveml %sp@+,%a2-%a3
    unlk %fp
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40830916

/* PATEXPAND: PatExpand: expand the port's pattern into the stack frame of a drawing routine (fp-136) at the destination depth: old patterns with the fg/bk colors, pixpats from their expanded data (PATCONVERT when stale) */
trap_PATEXPAND:
PATEXPAND:
    tstb %fp@(-166)
    jbne PATEXPAND_118
    moveal %sp@+,%a0
    moveq #64,%d0
    movew %fp@(-118),%d1
    subqw #3,%d1
    jble PATEXPAND_16
    lslw %d1,%d0
PATEXPAND_16:           /* the expanded pattern buffer on the stack (64 bytes x depth) */
    subaw %d0,%sp
    movel %sp,%fp@(-136)
    movel %a0,%sp@-

PATEXPAND_1E:           /* expand: mode, fg/bk, depth, pattern row alignment */
    linkw %a4,#-32
    moveml %d3-%d6/%a2-%a3/%a5,%sp@-
    movew %fp@(-152),%d0
    movew %fp@(-236),%d2
    movel %fp@(-160),%d3
    movel %fp@(-164),%d4
    movew %fp@(-118),%d5
    moveal %fp@(-156),%a0
    lea %fp@(-142),%a1
    andiw #243,%d0
    jbeq PATEXPAND_52
    btst #5,%d0
    jbne PATEXPAND_52
    moveq #-1,%d3
    moveq #0,%d4
PATEXPAND_52:           /* rotate the pattern by the origin */
    moveal %a5@,%a3
    moveq #7,%d0
    andw %a3@(-168),%d0
    jbeq PATEXPAND_72
    movel %a0@,%a4@(-16)
    movel %a0@+,%a4@(-8)
    movel %a0@,%a4@(-12)
    movel %a0@,%a4@(-4)
    lea %a4@(-16),%a0
    addaw %d0,%a0
PATEXPAND_72:           /* 1-bit: copy (or invert) the rows */
    addw %a3@(-166),%d2
    moveq #7,%d6
    andw %d6,%d2
    tstw %d5
    jbne PATEXPAND_90
    moveal %a3@,%a3
    movew %a3@(90),%d0
    cmpiw #-2,%d0
    jbeq PATEXPAND_C8
    cmpiw #2,%d0
    jbeq PATEXPAND_9C
PATEXPAND_90:           /* deeper: the expansion routine for the depth (0x1AB8 table) */
    moveal 0x1ab8,%a2
    addal %a2@(0x0,%d5:w:4),%a2
    jsr %a2@
    jbra PATEXPAND_F0
PATEXPAND_9C:           /* 1-bit pattern with fg/bk colors: expand each byte */
    clrw %a1@+
    clrl %a1@+
    moveal %a1@,%a1
    clrw %d0
PATEXPAND_A4:           /* each byte through the nibble table */
    moveb %a0@+,%d0
    eorb %d7,%d0
    rolb %d2,%d0
    moveb %d0,%sp@-
    lsrb #4,%d0
    moveb %pc@(PATEXPAND_F8,%d0:w),%a1@+
    moveq #15,%d0
    andb %sp@+,%d0
    moveb %pc@(PATEXPAND_F8,%d0:w),%a1@+
    movew %a1@(-2),%a1@+
    movel %a1@(-4),%a1@+
    dbf %d6,PATEXPAND_A4
    jbra PATEXPAND_F0
PATEXPAND_C8:           /* 2-bit: expand each byte */
    clrw %a1@+
    clrl %a1@+
    moveal %a1@,%a1
    clrw %d0
PATEXPAND_D0:           /* each byte through the nibble table */
    moveb %a0@+,%d0
    eorb %d7,%d0
    rolb %d2,%d0
    moveb %d0,%sp@-
    lsrb #4,%d0
    moveb %pc@(PATEXPAND_108,%d0:w),%a1@+
    moveq #15,%d0
    andb %sp@+,%d0
    moveb %pc@(PATEXPAND_108,%d0:w),%a1@+
    movew %a1@(-2),%a1@+
    clrl %a1@+
    dbf %d6,PATEXPAND_D0
PATEXPAND_F0:           /* restore registers, return */
    moveml %sp@+,%d3-%d6/%a2-%a3/%a5
    unlk %a4
    rts
PATEXPAND_F8:           /* nibble tables (data) */
    .long   0x00030C0F, 0x30333C3F	| 40830A18
    .long   0xC0C3CCCF, 0xF0F3FCFF	| 40830A20
PATEXPAND_108:          /* nibble table for 2-bit (data) */
    .long   0x00010405, 0x10111415	| 40830A28
    .long   0x40414445, 0x50515455	| 40830A30
PATEXPAND_118:          /* a pixpat: up to date for this device? else PATCONVERT */
    linkw %a4,#-32
    moveml %d3-%d6/%a2-%a3/%a5,%sp@-
    movel %sp,%a4@(-20)
    moveal %a5@,%a3
    movel %a3,%a4@(-28)
    movel %a5,%a4@(-32)
    moveal %fp@(-156),%a0
    moveal %a0@,%a0
    moveal %a0@,%a0
    tstw %a0@
    jbne PATEXPAND_17E
    moveal %a0@(10),%a0
    moveq #64,%d0
    movew %fp@(-118),%d1
    subqw #3,%d1
    jble PATEXPAND_14A
    lsll %d1,%d0
PATEXPAND_14A:          /* grow its expanded data */
    jsr %pc@(RSETHSIZE)
    movel %a0@,%d0
    jsr @(0x644,%za0)@(0x0)	| 40830A70
    movel %d0,%fp@(-136)
    moveal %fp@(-156),%a0
    movel %a0,%sp@-
    moveal %a0@,%a0
    moveal %a0@,%a0
    moveal %a0@(6),%a0
    moveal %a0@,%a0
    movel %a0,%fp@(-156)
    jsr %pc@(PATEXPAND_1E)
    movel %sp@+,%fp@(-156)
PATEXPAND_176:          /* done */
    moveal %a4@(-20),%sp
    jbra PATEXPAND_F0
PATEXPAND_17E:          /* new depth or color table: reconvert */
    moveal %fp@(-156),%a0
    moveal %a0@,%a0
    moveal %a0@,%a2
    moveal TheGDevice,%a1
    moveal %a1@,%a1
    moveal %a1@(22),%a1
    moveal %a1@,%a1
    movew %a1@(32),%d1
    moveal %a2@(16),%a5
    moveal %a5@,%a5
    cmpw %a2@(14),%d1
    jbne PATEXPAND_1B6
    cmpiw #8,%d1
    jbgt PATEXPAND_1CA
    moveal %a1@(42),%a1
    moveal %a1@,%a1
    movel %a1@,%d0
    cmpl %a5@(6),%d0
    jbeq PATEXPAND_1CA
PATEXPAND_1B6:          /* PixPatChanged */
    movel %d0,%a5@(6)
    movew %d1,%a2@(14)
    movel %a0,%sp@-
    moveal %a4@(-32),%a5
    jsr @(0x1a4c,%za0)@(0)	| 40830AE4
PATEXPAND_1CA:          /* the expanded data: base, sizes */
    moveal %fp@(-156),%a0
    moveal %a0@,%a0
    moveal %a0@,%a0
    moveal %a0@(16),%a5
    moveal %a5@,%a5
    movel %a0@(0xa,%za0)@(0),%d0	| 40830AF8
    jsr @(0x644,%za0)@(0x0)
    movel %d0,%fp@(-136)
    movew %a5@,%fp@(-142)
    movew %a5@(2),%fp@(-140)
    movew %a5@(4),%fp@(-138)
    lea %a5@(10),%a2
    moveal %a3@,%a1
    movew %a2@+,%d0
    cmpw %fp@(-236),%d0
    jbne PATEXPAND_23C
    cmpl %a2@+,%d7
    jbne PATEXPAND_23C
    movew %a3@(-168),%d0
    cmpw %a2@+,%d0
    jbne PATEXPAND_23C
    movew %a3@(-166),%d0
    cmpw %a2@+,%d0
    jbne PATEXPAND_23C
    movew %a1@(90),%d0
    cmpw %a2@+,%d0
    jbeq PATEXPAND_F0
PATEXPAND_224:          /* remember the depth, seed and origin */
    lea %a5@(12),%a2
    movel %d7,%a2@+
    moveal %a4@(-28),%a3
    movel %a3@(-168),%a2@+
    moveal %a3@,%a1
    movew %a1@(90),%a2@+
    jbra PATEXPAND_176
PATEXPAND_23C:          /* align to the origin: rotate the rows */
    movew %a5@,%d0
    jbne PATEXPAND_242
    moveq #4,%d0
PATEXPAND_242:          /* row size */
    moveal %a0@(2),%a1
    moveal %a1@,%a1
    movew %fp@(-118),%d1
    lslw #3,%d0
    movew %d0,%d3
    movew %d0,%d4
    lsrw %d1,%d4
    lsrw #5,%d0
PATEXPAND_256:          /* a row buffer */
    clrl %sp@-
    dbf %d0,PATEXPAND_256
    movew %fp@(-236),%d2
    addw %a3@(-166),%d2
    movew %d2,%d0
    subw %a5@(10),%d2
    movew %d0,%a5@(10)
    subqw #1,%d4
    andw %d4,%d2
    jbeq PATEXPAND_224
    lslw %d1,%d2
    movew %d2,%a4@(-24)
    movew %d3,%a4@(-22)
    moveal %a0@(10),%a3
    moveal %a3@,%a3
    moveq #32,%d6
    moveq #16,%d5
    tstw %a5@
    jbeq PATEXPAND_2EE
    movew %a1@(10),%d5
    subw %a1@(6),%d5
    moveq #0,%d3
    jbra PATEXPAND_2EE
PATEXPAND_298:          /* each row */
    moveal %sp,%a2
    movew %a4@(-22),%d3
    movew %a4@(-24),%d2
    movew %d2,%d7
    extl %d7
    subw %d7,%d3
PATEXPAND_2A8:          /* rotate by long */
    bfextu %a3@,%d7,0,%d0
    addl %d6,%d7
    subw %d6,%d3
    jbmi PATEXPAND_2B6
    movel %d0,%a2@+
    jbra PATEXPAND_2A8
PATEXPAND_2B6:          /* the wrap part */
    movel %d6,%d1
    addw %d3,%d1
    roll %d1,%d0
    bfins %d0,%a2@,0,%d1
    negw %d3
    bfextu %a3@,0,%d3,%d0
    bfins %d0,%a2@,%d1,%d3
    addqw #4,%a2
    subw %d3,%d2
    jble PATEXPAND_2DE
PATEXPAND_2D0:          /* the rest */
    bfextu %a3@,%d3,0,%d0
    addl %d6,%d3
    subw %d6,%d2
    jbmi PATEXPAND_2DE
    movel %d0,%a2@+
    jbra PATEXPAND_2D0
PATEXPAND_2DE:          /* copy back */
    moveal %sp,%a2
    movew %a4@(-22),%d0
    subqw #1,%d0
    lsrw #5,%d0
PATEXPAND_2E8:          /* copy */
    movel %a2@+,%a3@+
    dbf %d0,PATEXPAND_2E8
PATEXPAND_2EE:          /* next row */
    dbf %d5,PATEXPAND_298
    jbra PATEXPAND_224
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40830C16

/* PATCONVERT: PatConvert(pp): rebuild a pixpat's expanded data for the current device: depth, color table seed, RGB patterns dithered (PATDITHER) */
trap_PATCONVERT:
PATCONVERT:
    linkw %fp,#-64
    moveml %d3-%a0/%a2-%a4,%sp@-
    movel %sp,%fp@(-4)
    jbsr GETDEVPIX
    movew %a0@(32),%d6
    extl %d6
    moveal %fp@(8),%a4
    moveal %a4@,%a1
    movew %a1@,%d0
    jbmi PATCONVERT_3C
    moveal %a1@(16),%a0
    moveal %a0@,%a0
    clrw %a0@(10)
    cmpiw #2,%d0
    jbne PATCONVERT_3C
    movel %a4,%sp@-
    jsr @(0x1a50,%za0)@(0)	| 40830C54
    moveal %a4@,%a1
PATCONVERT_3C:          /* type 1: the source pixmap's geometry */
    moveal %a1@(2),%a3
    moveal %a3@,%a0
    movew %a0@(32),%d7
    extl %d7
    movew %a0@(4),%d0
    andiw #32767,%d0
    movew %d0,%fp@(-14)
    clrw %fp@(-10)
    clrw %fp@(-12)
    lea %a0@(12),%a2
    movew %a2@,%d4
    movew %a2@-,%d3
    subw %a2@-,%d4
    subw %a2@-,%d3
    movew %d4,%d0
    subqw #1,%d0
    movew %d0,%fp@(-6)
    movew %d3,%d0
    subqw #1,%d0
    movew %d0,%fp@(-8)
    movew %a1@,%d0
    jbpl PATCONVERT_82
    lsrw #3,%d4
    muluw %d6,%d4
    jbra PATCONVERT_C8
PATCONVERT_82:          /* the expanded size: at least 32 bits wide */
    moveal %a1@(16),%a2
    moveal %a2@,%a2
    muluw %d6,%d4
    moveq #32,%d0
    divuw %d4,%d0
    subqw #1,%d0
    jbmi PATCONVERT_AE
    movew %d0,%fp@(-10)
    clrw %a2@
    moveq #4,%d4
    moveq #16,%d0
    divuw %d3,%d0
    cmpiw #1,%d0
    jblt PATCONVERT_B0
    muluw %d0,%d3
    subqw #1,%d0
    movew %d0,%fp@(-12)
    jbra PATCONVERT_B2
PATCONVERT_AE:          /* bytes */
    lsrw #3,%d4
PATCONVERT_B0:          /* rowBytes */
    movew %d4,%a2@
PATCONVERT_B2:          /* masks */
    movew %d4,%d0
    subqw #1,%d0
    andiw #-4,%d0
    movew %d0,%a2@(2)
    movew %d4,%d0
    muluw %d3,%d0
    subqw #1,%d0
    movew %d0,%a2@(4)
PATCONVERT_C8:          /* size the expanded data; the pixel translation table (MAKESCALETBL) */
    movew %d4,%d0
    muluw %d3,%d0
    moveal %a4@,%a0
    moveal %a0@(10),%a0
    jsr %pc@(RSETHSIZE)
    cmpiw #8,%d7	| 40830CF6
    bgts PATCONVERT_12E+0xe
    movel %a3@,%sp@-	| 40830CFC
    movew #32,%sp@-	| 40830CFE
    jsr @(0x1a38,%za0)@(0)	| 40830D02
    moveal %a4@,%a1	| 40830D08
    moveal %a1@(0xa,%za0)@(0),%a2	| 40830D0A
    moveq #0,%d5	| 40830D10
PATCONVERT_F2:          /* map each pixel */
    moveal %a4@,%a1	| 40830D12
    moveal %a1@(6,%za0)@(0),%a3	| 40830D14
    movew %fp@(-8),%d3	| 40830D1A
PATCONVERT_FE:          /* each row */
    movew %fp@(-10),%d2	| 40830D1E
PATCONVERT_102:         /* each pixel */
    moveq #0,%d4	| 40830D22
    movew %fp@(-6),%d1	| 40830D24
PATCONVERT_108:         /* through the table */
    bfextu %a3@,%d4,%d7,%d0	| 40830D28
    movel %sp@(0,%d0:w:4),%d0	| 40830D2C
    bfins %d0,%a2@,%d5,%d6	| 40830D30
    addl %d7,%d4	| 40830D34
    addl %d6,%d5	| 40830D36
    dbf %d1,PATCONVERT_108	| 40830D38
    dbf %d2,PATCONVERT_102	| 40830D3C
    addaw %fp@(-14),%a3	| 40830D40
    dbf %d3,PATCONVERT_FE	| 40830D44
    subqw #1,%fp@(-12)	| 40830D48
    jbpl PATCONVERT_F2	| 40830D4C
PATCONVERT_12E:         /* return; (type 2: PATDITHER) */
    moveal %fp@(-4),%sp
    moveml %sp@+,%d3-%a0/%a2-%a4
    unlk %fp
    rtd #4
    moveal %a4@,%a0
    moveal %a0@(6),%a0
    moveal %a0@,%a0
    moveal %a3@,%a1
    movel %a0,%a1@
    jbsr GETDEVPIX
    lea %fp@(-64),%a1
    moveq #24,%d0
PATCONVERT_154:         /* copy the pixmap */
    movew %a0@+,%a1@+
    dbf %d0,PATCONVERT_154
    lea %fp@(-58),%a0
    clrl %a0@+
    movew %fp@(-8),%a0@
    addqw #1,%a0@+
    movew %fp@(-6),%a0@
    addqw #1,%a0@
    moveal %a4@,%a1
    moveal %a1@(10),%a0
    moveal %a0@,%a0
    movel %a0,%fp@(-64)
    oriw #-32768,%d4
    movew %d4,%fp@(-60)
    moveal %a3@,%a0
    movel %a3@,%sp@-
    clrl %sp@-
    pea %fp@(-64)
    pea %a0@(6)
    pea %fp@(-58)
    pea %fp@(-58)
    clrw %sp@-
    btst #1,%a1@(1)
    jbeq PATCONVERT_1A4
    addiw #64,%sp@
PATCONVERT_1A4:         /* or CopyBits it to the device depth */
    clrl %sp@-
    moveal %a5@,%a0
    movel %a0@(-130),%sp@-
    movel %sp@,%sp@-
    movel %sp@,%sp@-
    st %sp@-
    jsr @(0x1a9c,%za0)@(0)	| 40830DD2
    moveal %a4@,%a1
    moveal %a1@(0xa,%za0)@(0),%a2	| 40830DDA
    movew %fp@(-6),%d7
    addqw #1,%d7
    muluw %d6,%d7
    andiw #32767,%fp@(-60)
    movew %fp@(-8),%d3
PATCONVERT_1D2:         /* replicate to 32 bits wide */
    moveq #0,%d5
    movel %d7,%d4
    movew %fp@(-10),%d2
    jbra PATCONVERT_1F0
PATCONVERT_1DC:         /* each row */
    movew %fp@(-6),%d1
PATCONVERT_1E0:         /* copy */
    bfextu %a2@,%d5,%d6,%d0
    bfins %d0,%a2@,%d4,%d6
    addl %d6,%d4
    addl %d6,%d5
    dbf %d1,PATCONVERT_1E0
PATCONVERT_1F0:         /* next row; replicate vertically */
    dbf %d2,PATCONVERT_1DC
    addaw %fp@(-60),%a2
    dbf %d3,PATCONVERT_1D2
    moveal %a1@(0xa,%za0)@(0),%a0	| 40830E1C
    movew %fp@(-60),%d1
    movew %fp@(-8),%d2
    addqw #1,%d2
    muluw %d2,%d1
    lsrl #2,%d1
    subqw #1,%d1
    movew %fp@(-12),%d2
    jbra PATCONVERT_220
PATCONVERT_218:         /* each copy */
    movew %d1,%d0
PATCONVERT_21A:         /* copy */
    movel %a0@+,%a2@+
    dbf %d0,PATCONVERT_21A
PATCONVERT_220:         /* next */
    dbf %d2,PATCONVERT_218
    jbra PATCONVERT_12E
    .long   0x00000000, 0x00000000	| 40830E48

/* MAKESCALETBL: table. */
trap_MAKESCALETBL:
MAKESCALETBL:
    moveal %sp@+,%a0
    movew %sp@+,%d2
    moveal %sp@+,%a1
    movew %a1@(32),%d1
    moveq #1,%d0
    lslw %d1,%d0
    movew %d0,%d1
    subqw #1,%d0
MAKESCALETBL_12:        /* a table of 2^depth longs on the stack */
    movel #2147483647,%sp@-
    dbf %d0,MAKESCALETBL_12
    movel %a0,%sp@-
    moveml %d3-%d7/%a2,%sp@-
    movew %d2,%d7
    moveq #0,%d5
    movew %d1,%d5
    subqw #6,%sp
    clrw %sp@-
    moveq #-1,%d6
    movel %a1@(42),%d0
    jbeq MAKESCALETBL_AC
    moveal %d0,%a2
    movew %a2@(0,%za0)@(6),%d4	| 40830E86
    movew %a2@(0,%za0)@(4),%d3
    btst #14,%d3
    jbne MAKESCALETBL_7E
    moveq #0,%d6
    movew %d4,%d6
MAKESCALETBL_4C:        /* each source color: its index on the current device */
    moveal %a2@,%a0
    movew %d4,%d3
    tstw %a0@(4)
    jbmi MAKESCALETBL_5A
    movew %a0@(0x8,%d4:w:8),%d3
MAKESCALETBL_5A:        /* Color2Index */
    movew %a0@(0xa,%d4:w:8),%sp@(2)
    movel %a0@(0xc,%d4:w:8),%sp@(4)
    clrl %sp@-
    pea %sp@(6)
    jsr @(0x16cc,%za0)@(0)	| 40830EBC
    movel %sp@+,%d0
    movel %d0,%sp@(0x24,%d3:w:4)
    dbf %d4,MAKESCALETBL_4C
    jbra MAKESCALETBL_AC
MAKESCALETBL_7E:        /* colors to search */
    moveq #0,%d6
    movew %d4,%d6
MAKESCALETBL_82:        /* through the search procs */
    moveal %a2@,%a0
    movew %d4,%d3
    movew %a0@(0x8,%d4:w:8),%sp@
    movew %a0@(0xa,%d4:w:8),%sp@(2)
    movel %a0@(0xc,%d4:w:8),%sp@(4)
    clrl %sp@-
    pea %sp@(4)
    jsr @(0x1c48,%za0)@(0)	| 40830EEC
    movel %sp@+,%d0
    movel %d0,%sp@(0x24,%d3:w:4)
    dbf %d4,MAKESCALETBL_82
MAKESCALETBL_AC:        /* unused entries: fill from the gray ramp */
    addql #1,%d6
    subl %d5,%d6
    negl %d6
    jble MAKESCALETBL_158
    moveq #-1,%d0
    movel %d0,%sp@-
    movew %d0,%sp@-
    clrl %sp@-
    clrw %sp@-
    btst #5,%d7
    jbeq MAKESCALETBL_D8
    pea %sp@(6)
    jsr @(0x1668,%za0)@(0x0)	| 40830F1A
    movel %sp,%sp@-
    jsr @(0x1664,%za0)@(0x0)	| 40830F22
MAKESCALETBL_D8:        /* ramp */
    moveal %sp,%a1
    moveal %a1,%a2
    moveq #2,%d0
MAKESCALETBL_DE:        /* start and step */
    movew #-32768,%sp@-
    movew %a1@+,%sp@-
    dbf %d0,MAKESCALETBL_DE
    moveal %a2,%a1
    lea %sp@(0x3c,%d5:w:4),%a2
    subqw #1,%d6
    jbeq MAKESCALETBL_11A
    lea %a1@(6),%a0
    moveq #2,%d0
MAKESCALETBL_F8:        /* per component */
    moveq #0,%d1
    movew %a0@+,%d1
    subw %a1@+,%d1
    scs %d7
    jbcc MAKESCALETBL_104
    negw %d1
MAKESCALETBL_104:       /* step */
    swap %d1
    divull %d6,%d1,%d1
    tstb %d7
    jbeq MAKESCALETBL_110
    negl %d1
MAKESCALETBL_110:       /* next */
    movel %d1,%sp@-
    dbf %d0,MAKESCALETBL_F8
    moveml %sp@+,%d3-%d5
MAKESCALETBL_11A:       /* fill */
    cmpil #2147483647,%a2@-
    jbne MAKESCALETBL_11A
    movew %sp@(8),%sp@(12)
    movew %sp@(4),%sp@(14)
    movew %sp@,%sp@(16)
    clrl %sp@-
    pea %sp@(16)
    jsr @(0x16cc,%za0)@(0)	| 40830F88
    movel %sp@+,%d0
    movel %d0,%a2@
    moveml %sp@+,%d0-%d2
    addl %d3,%d0
    addl %d4,%d1
    addl %d5,%d2
    moveml %d0-%d2,%sp@-
    dbf %d6,MAKESCALETBL_11A
    lea %sp@(24),%sp
MAKESCALETBL_158:       /* restore registers, return */
    moveml %sp@+,%d0-%d1/%d3-%d7/%a2
    rts
    .short  0x0000	| 40830FAE

/* PATDITHER: PatDither(pp): a type 2 (RGB) pixpat: build an 8x8 dither of the nearest device colors for its RGB */
trap_PATDITHER:
PATDITHER:
    linkw %fp,#-30
    moveml %a4,%sp@-
    moveal %fp@(8),%a0
    moveal %a0@,%a2
    cmpiw #2,%a2@
    jbne PATDITHER_162
    moveal %a2@(2),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    lea %a0@(40),%a0
    lea %fp@(-12),%a2
    movel %a0@(2),%a2@+
    movew %a0@(6),%a2@
    clrl %sp@-
    pea %fp@(-12)
    jsr @(0x16cc,%za0)@(0)	| 40830FE8
    pea %fp@(-6)
    jsr @(0x16d0,%za0)@(0)	| 40830FF2
    movew %fp@(-12),%d0
    movew %fp@(-6),%d1
    jbsr PATDITHER_CA
    movew %d0,%fp@(-30)
    movew %fp@(-10),%d0
    movew %fp@(-4),%d1
    jbsr PATDITHER_CA
    movew %d0,%fp@(-28)
    movew %fp@(-8),%d0
    movew %fp@(-2),%d1
    jbsr PATDITHER_CA
    movew %d0,%fp@(-26)
    clrl %sp@-
    pea %fp@(-30)
PATDITHER_78:           /* the RGB; the two nearest device colors */
    jsr @(0x16cc,%za0)@(0)	| 40831028
    pea %fp@(-24)
    jsr @(0x16d0,%za0)@(0)	| 40831032
    movew %fp@(-30),%d0
    movew %fp@(-24),%d1
    jbsr PATDITHER_CA
    movew %d0,%fp@(-24)
    movew %fp@(-28),%d0
    movew %fp@(-22),%d1
    jbsr PATDITHER_CA
    movew %d0,%fp@(-22)
    movew %fp@(-26),%d0
    movew %fp@(-20),%d1
    jbsr PATDITHER_CA
    movew %d0,%fp@(-20)
    clrl %sp@-
    pea %fp@(-24)
    jsr @(0x16cc,%za0)@(0)	| 40831068
    pea %fp@(-18)
    jsr @(0x16d0,%za0)@(0)	| 40831072
    jbra PATDITHER_DE

PATDITHER_CA:           /* compare a component against the target */
    addw %d0,%d0
    jbcs PATDITHER_D6
    subw %d1,%d0
    jbcc PATDITHER_DC
    moveq #0,%d0
    rts
PATDITHER_D6:           /* the other side */
    subw %d1,%d0
    jbcs PATDITHER_DC
    moveq #-1,%d0
PATDITHER_DC:           /* return */
    rts

PATDITHER_DE:           /* green */
    movew %fp@(-24),%d0
    movew %fp@(-18),%d1
    jbsr PATDITHER_CA
    movew %d0,%fp@(-18)
    movew %fp@(-22),%d0
    movew %fp@(-16),%d1
    jbsr PATDITHER_CA
    movew %d0,%fp@(-16)
PATDITHER_FA:           /* blue; the dither of the two colors */
    movew %fp@(-20),%d0
    movew %fp@(-14),%d1
    jbsr PATDITHER_CA
    movew %d0,%fp@(-14)
    clrl %sp@-
    pea %fp@(-18)
    jsr @(0x16cc,%za0)@(0)	| 408310BE
    pea %fp@(-18)
    jsr @(0x16d0,%za0)@(0)	| 408310C8
    moveal %fp@(8),%a2
    moveal %a2@,%a2
    moveal %a2@(2),%a2
    moveal %a2@,%a2
    moveal %a2@(42),%a2
    moveal %a2@,%a2
    lea %a2@(8),%a2
    clrw %a2@+
    movel %fp@(-6),%a2@+
    movew %fp@(-2),%a2@+
    movew #1,%a2@+
    movel %fp@(-18),%a2@+
    movew %fp@(-14),%a2@+
    movew #2,%a2@+
    movel %fp@(-24),%a2@+
    movew %fp@(-20),%a2@+
    movew #3,%a2@+
    movel %fp@(-30),%a2@+
    movew %fp@(-26),%a2@+
PATDITHER_162:          /* restore registers, return */
    moveml %sp@+,%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000	| 4083111A

/* MAKERGBPAT: _MakeRGBPat. */
trap_MakeRGBPat:
MAKERGBPAT:
    linkw %fp,#0
    moveml %a2-%a3,%sp@-
    moveal %fp@(12),%a1
    moveal %a1@,%a0
    movew #2,%a0@
    movew #-1,%a0@(14)
    movel #-1437226411,%d0
    movel %d0,%a0@(20)
    movel %d0,%a0@(24)
    moveal %a0@(2),%a3
    moveal %a3@,%a0
    moveal %a0@(42),%a0
    moveq #48,%d0
    jsr %pc@(RSETHSIZE)
    .short  0x2050, 0x42A7, 0x4EB0, 0x81E1, 0x16A0	| 40831156
    .long   0x209F4268	| 40831160
    .short  0x0004, 0x317C	| orib #124,%d4
    orib #6,%d4
    lea %a0@(40),%a0
    moveal %fp@(8),%a2
    movew #4,%a0@+
    movel %a2@+,%a0@+
    movew %a2@+,%a0@
    moveal %a1@,%a0
    moveal %a0@(6),%a0
    moveq #16,%d0
    jsr %pc@(RSETHSIZE)
    moveal %a0@,%a0
    movel #286374843,%d0
    movel %d0,%a0@+
    movel %d0,%a0@+
    movel %d0,%a0@+
    movel %d0,%a0@+
    moveal %a3@,%a2
    movel %a2@(42),%sp@-
    lea %pc@(ONEBITDATA),%a1
    jsr %pc@(COPYPMAP)
    moveal %a3@,%a2
    movel %sp@+,%a2@(42)
    movew #2,%a2@(4)
    clrl %a2@(6)
    movel #524296,%a2@(10)
    movew #2,%a2@(32)
    movew #2,%a2@(36)
    moveml %sp@+,%a2-%a3
    unlk %fp
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408311D4

/* GETCICON: _GetCIcon. */
trap_GetCIcon:
GETCICON:
    linkw %fp,#0
    moveml %d3-%d4/%a2-%a4,%sp@-
    clrl %fp@(10)
    subqw #4,%sp
    movel #1667851118,%sp@-
    movew %fp@(8),%sp@-
    jsr @(0x1480,%za0)@(0x0)	| 408311F8
    moveal %sp@+,%a0
    movel %a0,%d0
    jbeq GETCICON_AA
    jsr @(0x1584,%za0)@(0x0)	| 40831206
    moveal %a0,%a4
    _HLock
    moveal %a4@,%a3
    movew %a3@(10),%d4
    subw %a3@(6),%d4
    lea %a3@(82),%a2
    movew %a3@(54),%d0
    muluw %d4,%d0
    addaw %d0,%a2
    movew %a3@(68),%d0
    muluw %d4,%d0
    addaw %d0,%a2
    clrl %sp@-
    jsr @(0x16a0,%za0)@(0)	| 40831230
    movel %sp@+,%a2@
    moveal %a2,%a0
    movew %a2@(6),%d0
    addqw #1,%d0
    muluw #8,%d0
    addqw #8,%d0
    extl %d0
    movel %d0,%d3
    jsr @(0x158c,%za0)@(0)	| 4083124A
    bnew GETCICON_AA
    movel %a0,%a3@(42)
    moveal %a2,%a0
    addal %d3,%a0
    movew %a3@(4),%d0
    andiw #32767,%d0
    muluw %d4,%d0
    muluw %a3@(32),%d0
    jsr @(0x158c,%za0)@(0)	| 4083126A
    bnew GETCICON_AA
    movel %a0,%a3@(78)
    moveal %a4,%a0
    _HUnlock
    movel %a2,%d0
    subl %a3,%d0
    moveal %a4,%a0
    jsr %pc@(RSETHSIZE)
    movel %a4,%fp@(10)
GETCICON_AA:            /* restore registers, return */
    moveml %sp@+,%d3-%d4/%a2-%a4
    unlk %fp
    rtd #2
    .long   0x00000000, 0x00000000, 0x00000000	| 40831294

/* PLOTCICON: _PlotCIcon. */
trap_PlotCIcon:
PLOTCICON:
    linkw %fp,#-112
    moveml %d3/%a2-%a4,%sp@-
    pea %fp@(-6)
    jsr @(0x1664,%za0)@(0x0)	| 408312AC
    pea %fp@(-12)
    jsr @(0x1668,%za0)@(0x0)	| 408312B6
    moveq #33,%d0
    movel %d0,%sp@-
    jsr @(0xf88,%za0)@(0)	| 408312C0
    moveq #30,%d0
    movel %d0,%sp@-
    jsr @(0xf8c,%za0)@(0)	| 408312CA
    moveal %fp@(8),%a4
    moveal %a4,%a0
    _HLock
    moveal %a4@,%a3
    movew %a3@(10),%d3
    subw %a3@(6),%d3
    lea %a3@(82),%a0
    movel %a0,%a3@(50)
    movew %a3@(54),%d0
    muluw %d3,%d0
    addal %d0,%a0
    movel %a0,%a3@(64)
    moveal %a3@(78),%a0
    _HLock
    moveal %a0@,%a0
    movel %a0,%a3@
    moveal %a5@,%a0
    moveal %a0@,%a0
    lea %a0@(2),%a1
    lea %fp@(-90),%a2
    jsr @(0x1a08,%za0)@(0)	| 4083130C
    movew %fp@(-58),%d0
    subal %a0,%a0
    movew %d2,%d3
    jbeq PLOTCICON_F4
    moveal DeviceList,%a2
    moveal %a2@,%a1
    tstl %a1@(30)
    jbeq PLOTCICON_F4
    moveal %fp@(12),%a0
    lea %fp@(-98),%a1
    movel %a0@+,%a1@+
    movel %a0@,%a1@+
    movel %fp@(-84),%d0
    movew %d0,%d1
    swap %d0
    subw %d1,%a1@-
    subw %d0,%a1@-
    subw %d1,%a1@-
    subw %d0,%a1@-
    lea %fp@(-108),%a0
    movel %a0,%fp@(-112)
    movew #10,%a0@
PLOTCICON_B0:           /* each screen the icon touches */
    moveal %a2@,%a0
    tstw %a0@(20)
    jbpl PLOTCICON_124
    clrb %sp@-
    pea %fp@(-98)
    pea %a0@(34)
    pea %fp@(-106)
    jsr @(0x10a8,%za0)@(0)	| 40831366
    tstb %sp@+
    jbeq PLOTCICON_124
    movel %fp@(-84),%d0
    movew %d0,%d1
    swap %d0
    lea %fp@(-106),%a0
    addw %d0,%a0@+
    addw %d1,%a0@+
    addw %d0,%a0@+
    addw %d1,%a0@
    moveal %a2@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    movew %a0@(32),%d0
    lea %fp@(-112),%a0
PLOTCICON_F4:           /* deeper than 2 bits and a color image: CopyMask the color image, else the 1-bit one */
    lea %a3@(64),%a1
    tstw %a1@(4)
    jbeq PLOTCICON_104
    cmpiw #2,%d0
    jble PLOTCICON_106
PLOTCICON_104:          /* 1-bit */
    moveal %a3,%a1
PLOTCICON_106:          /* draw it (COPYCICON) */
    movel %a1,%sp@-
    pea %a3@(50)
    pea %fp@(-90)
    pea %a1@(6)
    pea %a3@(56)
    movel %fp@(12),%sp@-
    jbsr COPYCICON
    tstw %d3
    jbeq PLOTCICON_12E
PLOTCICON_124:          /* next device */
    moveal %a2@,%a0
    movel %a0@(30),%d0
    moveal %d0,%a2
    jbne PLOTCICON_B0
PLOTCICON_12E:          /* unlock, restore the colors */
    moveal %a3@(78),%a0
    _HUnlock
    moveal %a4,%a0
    _HUnlock
    pea %fp@(-6)
    jsr @(0x1650,%za0)@(0x0)	| 408313DC
    pea %fp@(-12)
    jsr @(0x1654,%za0)@(0x0)	| 408313E6
    moveml %sp@+,%d3/%a2-%a4
    unlk %fp
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408313F6

/* DISPOSCICON: _DisposCIcon. */
trap_DisposCIcon:
DISPOSCICON:
    moveal %sp@+,%a1
    moveal %sp@,%a0
    moveal %a0@,%a0
    movel %a0@(42),%sp@-
    moveal %a0@(78),%a0
    _DisposHandle
    moveal %sp@+,%a0
    _DisposHandle
    moveal %sp@+,%a0
    _DisposHandle
    jmp %a1@
    .short  0x0000, 0x0000, 0x0000	| 4083141A

/* NEWHANDLE: NewHandle(size) for QuickDraw: on failure (MemErr), Debugger error 25 (out of memory) */
NEWHANDLE:
    moveq #0,%d0
    moveal %sp@+,%a1
    movew %sp@+,%d0
    jbne NEWHANDLE_A
    moveq #2,%d0
NEWHANDLE_A:            /* NewHandle (clear); 0 bytes gets 2 */
    .short  0xA322	| 4083142A _NewHandle (flags 0x0300)
    jbne NEWHANDLE_12
    movel %a0,%sp@
    jmp %a1@
NEWHANDLE_12:           /* failed: Debugger error 25 (out of memory) */
    moveq #25,%d0
    jsr @(0x1524,%za0)@(0x0)	| 40831434

trap_JACKSONPOLLOCK:
JACKSONPOLLOCK:         /* _Debugger */
    _Debugger

RNEWHANDLE:             /* (_NewHandle (flags 0x0300)) */
    .short  0xA322	| 4083143C _NewHandle (flags 0x0300)
    jbne NEWHANDLE_12
    rts

/* SETHSIZE: SetHSize(h, size): SetHandleSize; on failure Debugger error 25 */
SETHSIZE:
    moveq #0,%d0
    moveal %sp@+,%a1
    movew %sp@+,%d0
    moveal %sp@+,%a0
    _SetHandleSize
    jbne NEWHANDLE_12
    jmp %a1@

RSETHSIZE:              /* _SetHandleSize */
    _SetHandleSize
    jbne NEWHANDLE_12
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40831456

/* NEWTEMPHANDLE: NewTempHandle(d0 size): a temporary memory handle (_OSDispatch 29, MFTempNewHandle) when MultiFinder is up, else none (a0 = 0) */
trap_NEWTEMPHANDLE:
NEWTEMPHANDLE:
    moveml %d1-%d3,%sp@-
    movel %d0,%d3
    movel 0x107c,%d0
    cmpl 0x103c,%d0
    jbne NEWTEMPHANDLE_16
    moveq #0,%d0
    moveal %d0,%a0
    jbra NEWTEMPHANDLE_2C
NEWTEMPHANDLE_16:       /* MFTempNewHandle */
    clrl %sp@-
    movel %d3,%sp@-
    pea MemErr
    movew #29,%sp@-
    _OSDispatch
    movel %sp@+,%d0
    moveal %d0,%a0
    jbeq NEWTEMPHANDLE_2C
    movel %d3,%d0
NEWTEMPHANDLE_2C:       /* restore registers, return */
    moveml %sp@+,%d1-%d3
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40831492

/* NEWTEMPBUFFER: NewTempBuffer(d0 size): a temporary memory buffer: MultiFinder temp memory (_OSDispatch 29) else the application heap */
trap_NEWTEMPBUFFER:
NEWTEMPBUFFER:
    moveml %d1-%d3,%sp@-
    movel %d0,%d3
    movel 0x107c,%d0
    cmpl 0x103c,%d0
    jbeq NEWTEMPBUFFER_6A
    clrl %sp@-
    movel %d3,%sp@-
    pea MemErr
    movew #29,%sp@-
    _OSDispatch
    movel %sp@+,%d0
    jbeq NEWTEMPBUFFER_3A
NEWTEMPBUFFER_22:       /* lock it (MFTempHLock) */
    movel %d0,%sp@-
    movel %d0,%sp@-
    pea MemErr
    movew #30,%sp@-
    _OSDispatch
    moveal %sp@+,%a0
    movel %d3,%d0
NEWTEMPBUFFER_34:       /* restore registers, return */
    moveml %sp@+,%d1-%d3
    rts
NEWTEMPBUFFER_3A:       /* MFFreeMem: the largest block */
    clrl %sp@-
    clrl %sp@-
    pea %sp@(4)
    movew #21,%sp@-
    _OSDispatch
    movel %sp@+,%d3
    addqw #4,%sp
    tstl %d3
    jble NEWTEMPBUFFER_6A
NEWTEMPBUFFER_50:       /* allocate; failing: try 4K less */
    clrl %sp@-
    movel %d3,%sp@-
    pea MemErr
    movew #29,%sp@-
    _OSDispatch
    movel %sp@+,%d0
    jbne NEWTEMPBUFFER_22
    subil #4096,%d3
    jbgt NEWTEMPBUFFER_50
NEWTEMPBUFFER_6A:       /* none */
    moveq #0,%d0
    moveal %d0,%a0
    jbra NEWTEMPBUFFER_34

/* DISPOSETEMPBUFFER: DisposeTempBuffer(a0): dispose of a NEWTEMPBUFFER handle (_OSDispatch 32, MFTempDisposHandle) */
trap_DISPOSETEMPBUFFER:
DISPOSETEMPBUFFER:
    movel %a0,%d0
    jbeq DISPOSETEMPBUFFER_10
    movel %a0,%sp@-
    pea MemErr
    movew #32,%sp@-
    _OSDispatch
DISPOSETEMPBUFFER_10:   /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40831522

/* INITGRAF: _InitGraf: QuickDraw globals (screenBits, patterns, random seed, the cursor). */
trap_InitGraf:
INITGRAF:
    linkw %fp,#0
    moveml %d2/%a2/%a4,%sp@-
    moveal %fp@(8),%a4
    movel %a4,%a5@
    clrb QDExist
    jsr @(0xf48,%za0)@(0)	| 40831542
    lea %a4@(-202),%a0
    lea %a4@(4),%a1
INITGRAF_20:            /* clear the QuickDraw globals */
    clrw %a0@+
    cmpal %a1,%a0
    jbne INITGRAF_20
    movew #1,%a4@(-158)
    lea %a4@(-144),%a4
    movel %a4,%d0
    movew #10,%a4@+
    movel #-2147385343,%a4@+
    movel #2147450879,%a4@+
    movel %a4,%d1
    movel %d0,%a4@+
    movel %d1,%a4@+
    moveq #1,%d0
    movel %d0,%a4@+
    movel %a4,%sp@-
    _ScrnBitMap
    lea %a4@(14),%a4
    moveq #26,%d0
    lea %pc@(ARROW_CURSOR),%a0
INITGRAF_5A:            /* the standard patterns; the hilite color (PRAM); the devices (CHECKDEVICES) */
    movel %a0@+,%a4@+
    dbf %d0,INITGRAF_5A
    movel #393346,%d0
    lea HiliteRGB,%a0
    _ReadXPRam
    jbsr CHECKDEVICES
    moveal MainDevice,%a0
    movel %a0,TheGDevice
    movel %a0,SrcDevice
    movel QDColors,%d0
    moveal %d0,%a0
    jbgt INITGRAF_AE
    subqw #4,%sp
    movew #127,%sp@-
    jsr @(0x1660,%za0)@(0x0)	| 408315BC
    moveq #64,%d0
    .short  0xA71E	| 408315C4 _NewPtr (flags 0x0700)
    movel %a0,QDColors
    moveal %sp@,%a1
    moveal %a1@,%a1
    addqw #8,%a1
    moveq #15,%d0
INITGRAF_A2:            /* the arrow cursor */
    movel %a1@+,%a0@+
    dbf %d0,INITGRAF_A2
    jsr @(0x1690,%za0)@(0x0)	| 408315D8
INITGRAF_AE:            /* QDColors fixes */
    moveal QDColors,%a0
    cmpiw #25775,%a0@(44)
    jbne INITGRAF_C0
    movew #-32768,%a0@(44)
INITGRAF_C0:            /* the port list */
    moveq #-1,%d0
    moveal PortList,%a0
    cmpl %a0,%d0
    jbne INITGRAF_D4
    moveq #2,%d0
    jsr %pc@(RNEWHANDLE)
    movel %a0,PortList
INITGRAF_D4:            /* screenBits from the main device */
    jbsr GETDEVPIX
    moveal %a0,%a4
    moveal %a5@,%a1
    lea %a1@(-122),%a1
    movel %a0@+,%a1@+
    movew %a0@+,%d2
    andiw #32767,%d2
    movew %a4@(32),%d1
    movew %d2,%d0
    extl %d0
    divuw %d1,%d0
    movew %d0,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    jsr @(0x1674,%za0)@(0x0)	| 4083162A
    movel TheGDevice,LastTxGDevice
    jsr @(0x11f8,%za0)@(0)	| 40831636
    jsr @(0xf4c,%za0)@(0)
    moveml %sp@+,%d2/%a2/%a4
    unlk %fp
    rtd #4
    .include "quickdraw/arrow.s"
    .long   0x77DD77DD, 0x77DD77DD, 0x88228822, 0x88228822	| 40831690
    .long   0xAA55AA55, 0xAA55AA55, 0xFFFFFFFF, 0xFFFFFFFF	| 408316A0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408316B0

/* NEWPORT: NewPort(port): new empty visRgn and clipRgn for the port */
NEWPORT:
    clrl %sp@-
    jsr @(0x1160,%za0)@(0x0)	| 408316C2
    clrl %sp@-
    jsr @(0x1160,%za0)@(0x0)	| 408316CA
    moveal %sp@(12),%a0
    movel %sp@+,%a0@(28)
    movel %sp@+,%a0@(24)
    movel %sp@+,%sp@
    rts

/* OPENPORT: _OpenPort. */
trap_OpenPort:
OPENPORT:
    movel %sp@(4),%sp@-
    movel %sp@,%sp@-
    jsr %pc@(NEWPORT)
    jsr %pc@(INSPORTLIST)

/* INITPORT: _InitPort. */
trap_InitPort:
INITPORT:
    movel %a2,%sp@-
    moveal %sp@(8),%a2
    moveal %a5@,%a0
    lea %a0@(-122),%a0
    lea %a2@(2),%a1
    movel %a0@+,%a1@+
    movew %a0@+,%a1@+
    movel %a0@,%a1@+
    movel %a0@(4),%a1@+
    jsr %pc@(INITSHARED)
    lea %a2@(32),%a1
    clrl %a1@+
    clrl %a1@+
    moveq #-1,%d0
    movel %d0,%a1@+
    movel %d0,%a1@+
    lea %a2@(58),%a1
    movel %d0,%a1@+
    movel %d0,%a1@+
    lea %a2@(80),%a1
    movel #33,%a1@+
    movel #30,%a1@+
    moveal %sp@+,%a2
    movel %sp@+,%sp@
    rts
    .long   0x00000000, 0x00000000	| 40831738

/* INITSHARED: InitShared: OpenPort/InitPort common part: thePort, portBits from screenBits, portRect, regions, pen and colors */
INITSHARED:
    moveal %a5@,%a0
    movel %a2,%a0@
    clrw %a2@
    lea %a0@(-116),%a0
    lea %a2@(16),%a1
    movel %a0@,%a1@+
    movel %a0@(4),%a1@+
    movel %a1@+,%sp@-
    movel %a0,%sp@-
    jsr @(0x117c,%za0)@(0)	| 40831758
    moveal %a5@,%a0
    movel %a0@(-130),%sp@-
    movel %a2@(28),%sp@-
    jsr @(0x1170,%za0)@(0x0)	| 40831768
    lea %a2@(48),%a1
    clrl %a1@+
    movel #65537,%a1@+
    movew #8,%a1@+
    lea %a2@(66),%a1
    clrw %a1@+
    clrl %a1@+
    movew #1,%a1@+
    clrw %a1@+
    clrl %a1@+
    lea %a2@(88),%a1
    clrl %a1@+
    clrl %a1@+
    clrl %a1@+
    clrl %a1@+
    clrl %a1@+
    rts
    .short  0x0000	| 4083179E

/* SETSTDPROCS: _SetStdProcs. */
trap_SetStdProcs:
SETSTDPROCS:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel 0x1008,%a1@+
    movel 0x1040,%a1@+
    movel 0x1080,%a1@+
    movel 0x10bc,%a1@+
    movel 0x10d8,%a1@+
    movel 0x10f4,%a1@+
    movel 0x1114,%a1@+
    movel 0x1144,%a1@+
    movel 0x11ac,%a1@+
    movel 0x11c4,%a1@+
    movel 0x11b4,%a1@+
    movel 0x11b8,%a1@+
    movel 0x11c0,%a1@+
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 408317DA

/* SETSTDCPROCS: _SetStdCProcs. */
trap_SetStdCProcs:
SETSTDCPROCS:
    movel %sp@(4),%sp@-
    jsr @(0x11a8,%za0)@(0)	| 408317E4
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    lea %a1@(52),%a1
    movel 0x1de0,%a1@+
    moveq #5,%d0
SETSTDCPROCS_18:        /* clear the new color procs */
    clrl %a1@+
    dbf %d0,SETSTDCPROCS_18
    jmp %a0@

/* LOCALTOGLOBAL: _LocalToGlobal. */
trap_LocalToGlobal:
LOCALTOGLOBAL:
    moveml %d0-%d2/%a0-%a1,%sp@-
    moveq #1,%d2
    jbra GLOBALTOLOCAL_6

/* GLOBALTOLOCAL: _GlobalToLocal. */
trap_GlobalToLocal:
GLOBALTOLOCAL:
    moveml %d0-%d2/%a0-%a1,%sp@-
    moveq #0,%d2
GLOBALTOLOCAL_6:        /* by the port's origin */
    moveal %a5@,%a0
    moveal %a0@,%a0
    jsr @(0x1a5c,%za0)@(0)	| 40831812
    moveal %sp@(24),%a1
    movew %a0@(6),%d0
    movew %a0@(8),%d1
    jbsr GLOBALTOLOCAL_24
    moveml %sp@+,%d0-%d2/%a0-%a1
    jbra SUBPT_1A

GLOBALTOLOCAL_24:       /* add or subtract */
    tstw %d2
    jbeq GLOBALTOLOCAL_2C
    negw %d0
    negw %d1
GLOBALTOLOCAL_2C:       /* store */
    addw %d0,%a1@+
    addw %d1,%a1@+
    rts

/* ADDPT: _AddPt. */
trap_AddPt:
ADDPT:
    moveml %d0-%d2/%a1,%sp@-
    moveq #0,%d2
    jbra SUBPT_6

/* SUBPT: _SubPt. */
trap_SubPt:
SUBPT:
    moveml %d0-%d2/%a1,%sp@-
    moveq #1,%d2
SUBPT_6:                /* SubPt / LocalToGlobal: the negative offset */
    moveal %sp@(20),%a1
    movew %sp@(24),%d0
    movew %sp@(26),%d1
    jbsr GLOBALTOLOCAL_24
    moveml %sp@+,%d0-%d2/%a1
    movel %sp@+,%sp@
SUBPT_1A:               /* return */
    movel %sp@+,%sp@
    rts

/* SETPORT: _SetPort. */
trap_SetPort:
SETPORT:
    moveal %a5@,%a0
    movel %sp@(4),%a0@
    jbra SUBPT_1A

/* GETPORT: _GetPort. */
trap_GetPort:
GETPORT:
    moveal %a5@,%a0
    moveal %sp@(4),%a1
    movel %a0@,%a1@
    jbra SUBPT_1A
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40831872

/* GRAFDEVICE: GrafDevice(device): the port's device field (offset 0) */
trap_GrafDevice:
GRAFDEVICE:
    moveq #0,%d0
    jmp %pc@(PORTWORD)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40831886

/* SETPORTBITS: _SetPortBits. */
trap_SetPBits:
SETPORTBITS:
    moveal %a5@,%a0
    moveal %a0@,%a0
    lea %a0@(2),%a0
    tstw %a0@(4)
    jbmi SETPORTBITS_1A
    moveal %sp@(4),%a1
    movel %a1@+,%a0@+
    movew %a1@+,%a0@+
SETPORTBITS_16:         /* copy the bitmap */
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
SETPORTBITS_1A:         /* return */
    movel %sp@+,%sp@
    rts

/* BACKPAT: _BackPat. */
trap_BackPat:
BACKPAT:
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstw %a0@(6)
    jbmi BACKPAT_14
    lea %a0@(32),%a0
    moveal %sp@(4),%a1
    jbra SETPORTBITS_16
BACKPAT_14:             /* color port: through OldPatToNew */
    movel %sp@(4),%sp@-
    pea %a0@(32)
    jsr @(0x1a44,%za0)@(0)	| 408318CA
    jbra SETPORTBITS_1A
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408318D2

/* PORTSIZE: _PortSize. */
trap_PortSize:
PORTSIZE:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movew %a0@(18),%d0
    addw %sp@(6),%d0
    movew %d0,%a0@(22)
    movew %a0@(16),%d0
    addw %sp@(4),%d0
    movew %d0,%a0@(20)
    movel %sp@+,%sp@
    rts

/* MOVEPORTTO: _MovePortTo. */
trap_MovePortTo:
MOVEPORTTO:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movew %a0@(18),%d0
    movew %a0@(16),%d1
    jsr @(0x1a5c,%za0)@(0)	| 4083190C
    subw %a0@(8),%d0
    subw %sp@(6),%d0
    subw %a0@(6),%d1
    subw %sp@(4),%d1
    movel %sp@+,%sp@

MOVEPORTTO_24:          /* the rectangle */
    addqw #6,%a0

MOVEPORTTO_26:          /* offset it */
    addw %d1,%a0@+
    addw %d0,%a0@+
    addw %d1,%a0@+
    addw %d0,%a0@+
    rts

/* SETORIGIN: _SetOrigin. */
trap_SetOrigin:
SETORIGIN:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %sp@(4),%d0
    cmpl %a0@(16),%d0
    jbeq SETORIGIN_3C
    movew %sp@(6),%d0
    subw %a0@(18),%d0
    movew %sp@(4),%d1
    subw %a0@(16),%d1
    movel %a0@(24),%sp@-
    movew %d0,%sp@-
    movew %d1,%sp@-
    pea %a0@(16)
    jsr @(0x1a5c,%za0)@(0)	| 4083195A
    jbsr MOVEPORTTO_24
    moveal %sp@+,%a0
    jbsr MOVEPORTTO_26
    jsr @(0x1180,%za0)@(0x0)	| 40831966
SETORIGIN_3C:           /* return */
    movel %sp@+,%sp@
    rts

/* CLIPRECT: _ClipRect. */
trap_ClipRect:
CLIPRECT:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(28),%sp@-
    movel %sp@(8),%sp@-
    jsr @(0x117c,%za0)@(0)	| 4083197C
    jbra SETORIGIN_3C
    .long   0x00000000, 0x00000000, 0x00000000	| 40831984

/* SETCLIP: _SetClip. */
trap_SetClip:
SETCLIP:
    moveal %sp@+,%a0
    moveal %a5@,%a1
    moveal %a1@,%a1
    movel %a1@(28),%sp@-
    jbra GETCLIP_E

/* GETCLIP: _GetClip. */
trap_GetClip:
GETCLIP:
    moveal %sp@+,%a0
    movel %sp@+,%d0
    moveal %a5@,%a1
    moveal %a1@,%a1
    movel %a1@(28),%sp@-
    movel %d0,%sp@-
GETCLIP_E:              /* CopyRgn(clipRgn, rgn) */
    movel %a0,%sp@-
    jmp %pc@(trap_CopyRgn)

/* SETPT: _SetPt. */
trap_SetPt:
SETPT:
    moveal %sp@+,%a0
    movel %sp@+,%d0
    moveal %sp@+,%a1
    movel %d0,%a1@
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 408319BA

/* EQUALPT: _EqualPt. */
trap_EqualPt:
EQUALPT:
    moveal %sp@+,%a0
    movel %sp@+,%d0
    cmpl %sp@+,%d0
    seq %sp@
    negb %sp@
    jmp %a0@
    .long   0x00000000	| 408319CC

/* INSPORTLIST: InsPortList(port): add the port to the port list (PortList, 0xD66) with Munger */
INSPORTLIST:
    clrl %sp@-
    movel PortList,%sp@-
    moveq #2,%d0
    movel %d0,%sp@-
    clrl %sp@-
    clrl %sp@-
    pea %sp@(24)
    moveq #4,%d0
    movel %d0,%sp@-
    jsr @(0x1580,%za0)@(0x0)	| 408319E6
    movel %sp@+,%d0
    moveal PortList,%a0
    moveal %a0@,%a0
    addqw #1,%a0@
    movel %sp@+,%sp@
    rts
    .short  0x0000, 0x0000, 0x0000	| 408319FA

/* DELPORTLIST: DelPortList(port): remove the port from the port list */
DELPORTLIST:
    moveal PortList,%a0
    moveal %a0@,%a0
    tstw %a0@
    jbeq DELPORTLIST_2C
    subqw #1,%a0@
    clrl %sp@-
    movel PortList,%sp@-
    moveq #2,%d0
    movel %d0,%sp@-
    pea %sp@(16)
    moveq #4,%d0
    movel %d0,%sp@-
    pea %pc@(DELPORTLIST_2C)
    clrl %sp@-
    jsr @(0x1580,%za0)@(0x0)	| 40831A24
    movel %sp@+,%d0
DELPORTLIST_2C:         /* return */
    movel %sp@+,%sp@
    rts

/* STDCOMMENT: StdComment: the picture comment bottleneck. */
trap_StdComment:
STDCOMMENT:
    linkw %fp,#0
    moveml %d6-%d7,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    tstl %a0@(92)
    jbeq STDCOMMENT_54
    movew %fp@(14),%d6
    movew %fp@(12),%d7
    jbgt STDCOMMENT_2C
    movew #160,%d0
    jsr %pc@(trap_DPUTPICOP)
    movew %d6,%sp@-
    jsr %pc@(PUTPICWORD)
    jbra STDCOMMENT_54
STDCOMMENT_2C:          /* LongComment (0xA1): kind, size, data */
    movew #161,%d0
    jsr %pc@(trap_DPUTPICOP)
    movew %d6,%sp@-
    jsr %pc@(PUTPICWORD)
    movew %d7,%sp@-
    jsr %pc@(PUTPICWORD)
    moveal %fp@(8),%a0
    _HLock
    movel %a0@,%sp@-
    movew %d7,%sp@-
    jsr %pc@(PUTPICDATA)
    moveal %fp@(8),%a0
    _HUnlock
STDCOMMENT_54:          /* restore registers, return */
    moveml %sp@+,%d6-%d7
    unlk %fp
    rtd #8
    .short  0x0000	| 40831A8E

/* STDGETPIC: StdGetPic: read picture data. */
trap_StdGetPic:
STDGETPIC:
    moveal %sp@+,%a0
    movew %sp@+,%d1
    moveal %sp@+,%a1
    movel %a0,%sp@-
    moveal %a5@,%a0
    movel %a0@(-180),%d0
    moveal %a0@(-156),%a0
    moveal %a0@,%a0
    addal %d0,%a0
    jbra STDGETPIC_1A
STDGETPIC_18:           /* copy the bytes */
    moveb %a0@+,%a1@+
STDGETPIC_1A:           /* next */
    dbf %d1,STDGETPIC_18
    rts

/* STDPUTPIC: StdPutPic: write picture data. */
trap_StdPutPic:
STDPUTPIC:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a4
    tstl %a4@(92)
    jbeq STDPUTPIC_74
    moveal %a4@(92),%a4
    moveal %a4@,%a1
    movel %a1@(8),%d7
    jbeq STDPUTPIC_74
    moveal %a1@,%a3
    movew %fp@(8),%d0
    extl %d0
    addl %d7,%d0
    movel %d0,%a1@(8)
    moveal %a3@,%a0
    movew %d0,%a0@
    cmpl %a1@(4),%d0
    jble STDPUTPIC_5E
    addil #512,%d0
    movel %d0,%a1@(4)
    moveal %a3,%a0
    _SetHandleSize
    moveal %a4@,%a1
    jbeq STDPUTPIC_5E
    clrl %a1@(8)
    moveq #10,%d0
    moveal %a3,%a0
    _SetHandleSize
    moveal %a3@,%a0
    movew #-1,%a0@+
    clrl %a0@+
    clrl %a0@+
    jbra STDPUTPIC_74
STDPUTPIC_5E:           /* append */
    moveal %a1@,%a1
    moveal %a1@,%a1
    addal %d7,%a1
    moveal %fp@(10),%a0
    movew %fp@(8),%d0
    jbra STDPUTPIC_70
STDPUTPIC_6E:           /* copy */
    moveb %a0@+,%a1@+
STDPUTPIC_70:           /* next */
    dbf %d0,STDPUTPIC_6E
STDPUTPIC_74:           /* restore registers, return */
    moveml %sp@+,%d7/%a3-%a4
    unlk %fp
    rtd #6
    .short  0x0000	| 40831B2E

/* STDOPCODEPROC: StdOpcodeProc: unknown picture opcodes. */
trap_StdOpcodeProc:
STDOPCODEPROC:
    linkw %fp,#0
    moveml %d6-%d7,%sp@-
    movel #256,%d6
    subal %d6,%sp
    movew %fp@(10),%d0
    jbmi STDOPCODEPROC_1E
    lsrw #8,%d0
    addw %d0,%d0
    extl %d0
    jbra STDOPCODEPROC_28
STDOPCODEPROC_1E:       /* skip the data of an unknown opcode: its size (long) */
    andiw #32512,%d0
    jbeq STDOPCODEPROC_3E
    jsr %pc@(GETLONG)
STDOPCODEPROC_28:       /* size */
    movel %d0,%d7
STDOPCODEPROC_2A:       /* in 256-byte pieces */
    movew %d6,%d0
    cmpl %d6,%d7
    jbge STDOPCODEPROC_32
    movew %d7,%d0
STDOPCODEPROC_32:       /* read */
    movel %sp,%sp@-
    movew %d0,%sp@-
    jsr %pc@(GETPICDATA)
    subl %d6,%d7
    jbgt STDOPCODEPROC_2A
STDOPCODEPROC_3E:       /* return */
    addal %d6,%sp
    moveml %sp@+,%d6-%d7
    unlk %fp
    rtd #12
    .short  0x0000, 0x0000, 0x0000	| 40831B7A

/* PICCOMMENT: _PicComment. */
trap_PicComment:
PICCOMMENT:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x11c4,%a0
    jbeq PICCOMMENT_14
    moveal %d0,%a0
    moveal %a0@(36),%a0
PICCOMMENT_14:          /* through the port's commentProc */
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40831B96

/* OPENCPICTURE: OpenCPicture(params): open an extended version 2 picture (version 0x2FF) */
trap_OpenCPicture:
OPENCPICTURE:
    linkw %fp,#-2
    movew #767,%fp@(-2)
    jmp %pc@(OPSHARE)
    .short  0x0000	| 40831BAE

/* OPENPICTURE: OpenPicture(frame): open a picture (version 1; version 2 in a color port) */
trap_OpenPicture:
OPENPICTURE:
    linkw %fp,#-2
    movew #1,%fp@(-2)
/* OPSHARE: OpenPicture common part: picture handle (1000 bytes to start), picture state record (picSave, port offset 92), header opcodes, hide the pen */
OPSHARE:
    moveml %d3/%a3-%a4,%sp@-
    clrl %fp@(12)
    moveal %a5@,%a4
    moveal %a4@,%a3
    tstl %a3@(92)
    jbne OPSHARE_158
    jsr @(0x1058,%za0)@(0x0)	| 40831BCE
    tstw %a3@(6)
    jbpl OPSHARE_34
    movew #767,%fp@(-2)
    movel #1000,%d0
    .short  0xA122	| 40831BE6 _NewHandle (flags 0x0100)
    jbne OPSHARE_158
    _DisposHandle
OPSHARE_34:             /* the picture state (140 bytes), the picture handle (256 to start), the saved port state */
    movel #140,%d0
    .short  0xA122	| 40831BF4 _NewHandle (flags 0x0100)
    moveal %a0,%a4
    movel %a4,%a3@(92)
    clrl %sp@-
    jsr @(0x1160,%za0)@(0x0)	| 40831BFE
    movel #256,%d0
    .short  0xA122	| 40831C0A _NewHandle (flags 0x0100)
    moveal %a0,%a1
    movel %a1,%fp@(12)
    moveal %a4@,%a4
    movel %a1,%a4@+
    moveal %a1@,%a1
    movew #10,%a1@+
    moveal %fp@(8),%a0
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel #256,%a4@+
    movel #10,%a4@+
    movel %sp@+,%a4@+
    clrl %a4@+
    clrl %a4@+
    clrl %a4@+
    movew #1,%a4@+
    clrw %a4@+
    clrl %a4@+
    movel #65537,%d0
    movel %d0,%a4@+
    movel %d0,%a4@+
    clrl %a4@+
    clrl %a4@+
    movel %d0,%a4@+
    movew #8,%a4@+
    moveq #-1,%d0
    movel %d0,%a4@+
    movel %d0,%a4@+
    movel %d0,%a4@+
    movel %d0,%a4@+
    clrl %a4@+
    clrl %a4@+
    clrl %a4@+
    movel %a3@(16),%a4@+
    movel #33,%a4@+
    movel #30,%a4@+
    movew %fp@(-2),%a4@+
    clrl %a4@+
    clrw %a4@+
    movel %d0,%a4@+
    movew %d0,%a4@+
    movel #32768,%a4@+
    clrl %a4@+
    clrw %a4@+
    clrl %a4@+
    clrw %a4@+
    cmpiw #1,%fp@(-2)
    jbeq OPSHARE_FE
    moveq #2,%d3
OPSHARE_DE:             /* pixpats for the state */
    clrl %sp@-
    subal %a3@(0x5c,%za0)@(0),%a4	| 40831C9A
    jsr @(0x161c,%za0)@(0)
    moveal %sp@+,%a0
    addal %a3@(0x5c,%za0)@(0),%a4	| 40831CA8
    movel %a0,%a4@+
    moveal %a0@,%a0
    clrw %a0@
    dbf %d3,OPSHARE_DE
OPSHARE_FE:             /* header: version opcode (0x11) and version */
    moveq #17,%d0
    jsr %pc@(trap_DPUTPICOP)
    movew %fp@(-2),%d0
    cmpiw #1,%d0
    jbne OPSHARE_114
    jsr %pc@(trap_DPUTPICBYTE)
    jbra OPSHARE_158
OPSHARE_114:            /* version 2: the header opcode (0x0C00) with the frame and resolution */
    movew %d0,%sp@-
    jsr %pc@(PUTPICWORD)
    movew #3072,%d0
    jsr %pc@(trap_DPUTPICOP)
    clrl %sp@-
    moveal %fp@(8),%a0
    movel %a0@(4),%d0
    clrw %d0
    movel %d0,%sp@-
    movel %a0@(6),%d0
    clrw %d0
    movel %d0,%sp@-
    movel %a0@,%d0
    clrw %d0
    movel %d0,%sp@-
    movel %a0@(2),%d0
    clrw %d0
    movel %d0,%sp@-
    moveq #-1,%d0
    movel %d0,%sp@-
    movel %sp,%sp@-
    movew #24,%sp@-
    jsr %pc@(PUTPICDATA)
    lea %sp@(24),%sp
OPSHARE_158:            /* restore registers, return */
    moveml %sp@+,%d3/%a3-%a4
    unlk %fp
    rtd #4
    .long   0x00000000	| 40831D1C

/* CLOSEPICTURE: ClosePicture: write the end opcode (0xFF), trim the handle to its size, restore the pen and the port's procs, dispose of the state */
trap_ClosePicture:
CLOSEPICTURE:
    moveml %d6-%d7/%a3,%sp@-
    moveal %a5@,%a3
    moveal %a3@,%a3
    movel %a3@(92),%d7
    jbeq CLOSEPICTURE_62
    movew #255,%sp@-
    jsr %pc@(PUTPICOP)
    moveal %d7,%a0
    moveal %a0@,%a0
    movel %a0@(12),%d6
    movel %a0@(8),%d0
    jbeq CLOSEPICTURE_28
    moveal %a0@,%a0
    _SetHandleSize
CLOSEPICTURE_28:        /* dispose of the state's regions and pixpats */
    moveal %d6,%a0
    _DisposHandle
    moveal %d7,%a0
    moveal %a0@,%a0
    cmpiw #1,%a0@(98)
    jbeq CLOSEPICTURE_54
    lea %a0@(128),%a0
    movel %a0@+,%sp@-
    movel %a0@+,%sp@-
    movel %a0@+,%sp@-
    jsr @(0x1620,%za0)@(0x0)	| 40831D62
    jsr @(0x1620,%za0)@(0x0)
    jsr @(0x1620,%za0)@(0x0)
CLOSEPICTURE_54:        /* dispose of the state, show the pen */
    moveal %d7,%a0
    _DisposHandle
    clrl %a3@(92)
    jsr @(0x105c,%za0)@(0)	| 40831D7C
CLOSEPICTURE_62:        /* restore registers, return */
    moveml %sp@+,%d6-%d7/%a3
    rts
    .long   0x00000000, 0x00000000	| 40831D88

/* KILLPICTURE: KillPicture(pic): DisposHandle */
trap_KillPicture:
KILLPICTURE:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _DisposHandle
    jmp %a1@
    .long   0x00000000, 0x00000000	| 40831D98

/* DRAWPICTURE: DrawPicture(pic, dstRect): play the picture's opcodes (PICITEM1) scaled from its frame to dstRect, saving and restoring the port state */
trap_DrawPicture:
DRAWPICTURE:
    linkw %fp,#-170
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a3
    tstl %fp@(12)
    jbeq DRAWPICTURE_1B2
    moveal %fp@(8),%a0
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    jble DRAWPICTURE_1B2
    movew %d0,%fp@(-24)
    movew %a0@(4),%d0
    subw %a0@,%d0
    jble DRAWPICTURE_1B2
    movew %d0,%fp@(-26)
    lea %fp@(-34),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %fp@(12),%a0
    moveal %a0@,%a0
    lea %a0@(2),%a0
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    jble DRAWPICTURE_1B2
    movew %d0,%fp@(-20)
    movew %a0@(4),%d0
    subw %a0@,%d0
    jble DRAWPICTURE_1B2
    movew %d0,%fp@(-22)
    lea %fp@(-42),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %a3,%a0
    lea %fp@(-170),%a1
    moveq #53,%d0
DRAWPICTURE_76:         /* save the port; the picture read state */
    movew %a0@+,%a1@+
    dbf %d0,DRAWPICTURE_76
    clrl %a4@(-168)
    movel %fp@(12),%a4@(-156)
    movel #10,%a4@(-180)
    lea %fp@(-62),%a0
    clrl %a0@+
    clrl %a0@+
    clrl %a0@+
    clrl %a0@+
    clrl %a0@+
    movel %a3@(28),%fp@(-14)
    clrl %sp@-
    jsr @(0x1160,%za0)@(0x0)	| 40831E44
    movel %sp@+,%fp@(-18)
    movew #-32768,%d0
    movew %d0,%fp@(-8)
    movew %d0,%fp@(-6)
    clrl %sp@-
    jsr @(0x1160,%za0)@(0x0)	| 40831E5C
    movel %sp@+,%a3@(28)
    lea %a3@(32),%a0
    clrl %a0@+
    clrl %a0@+
    moveq #-1,%d0
    movel %d0,%a0@+
    movel %d0,%a0@+
    clrl %a0@+
    movel #65537,%d1
    movel %d1,%a0@+
    movew #8,%a0@+
    movel %d0,%a0@+
    movel %d0,%a0@+
    addqw #2,%a0
    clrl %a0@+
    movew #1,%a0@+
    clrw %a0@+
    clrl %a0@+
    movel #33,%a0@+
    movel #30,%a0@+
    pea %a3@(52)
    pea %fp@(-42)
    pea %fp@(-34)
    jsr @(0x11e0,%za0)@(0)	| 40831EAA
    tstw %a3@(6)
    jbmi DRAWPICTURE_124
    clrl %sp@-
    jsr @(0x161c,%za0)@(0)	| 40831EB8
    movel %sp@+,%fp@(-4)
    jbra DRAWPICTURE_136
DRAWPICTURE_124:        /* color port: fresh pixpats */
    clrl %a3@(32)
    clrl %a3@(58)
    clrl %a3@(62)
    movel %a3,%sp@-
    jsr %pc@(INITCOLORSTUFF)
DRAWPICTURE_136:        /* lock the picture */
    movew #1,%fp@(-10)
    moveal %fp@(12),%a0
    _HGetState
    movew %d0,%sp@-
    _HLock
DRAWPICTURE_146:        /* PICITEM1 until the end */
    clrb %sp@-
    pea %fp@(-62)
    jsr @(0x1c68,%za0)@(0)	| 40831EEC
    moveb %sp@+,%d0
    jbne DRAWPICTURE_146
    moveal %fp@(12),%a0
    movew %sp@+,%d0
    _HSetState
    moveal %fp@(-18),%a0
    _DisposHandle
    tstw %a3@(6)
    jbmi DRAWPICTURE_176
    movel %fp@(-4),%sp@-
    jsr @(0x1620,%za0)@(0x0)	| 40831F0E
    jbra DRAWPICTURE_194
DRAWPICTURE_176:        /* dispose of the pixpats */
    movel %a3@(32),%sp@-
    jsr @(0x1620,%za0)@(0x0)	| 40831F1A
    movel %a3@(58),%sp@-
    jsr @(0x1620,%za0)@(0x0)	| 40831F24
    movel %a3@(62),%sp@-
    jsr @(0x1620,%za0)@(0x0)	| 40831F2E
DRAWPICTURE_194:        /* restore the port */
    moveal %a3@(28),%a0
    _DisposHandle
    lea %fp@(-170),%a0
    moveq #53,%d0
DRAWPICTURE_1A0:        /* copy back */
    movew %a0@+,%a3@+
    dbf %d0,DRAWPICTURE_1A0
    clrl %a4@(-168)
    clrl %a4@(-156)
    clrl %a4@(-180)
DRAWPICTURE_1B2:        /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #8
    .long   0x00000000	| 40831F5C

/* PICITEM1: PicItem1: read and draw one picture opcode; returns false at the end opcode (0xFF) */
trap_PICITEM1:
PICITEM1:
    linkw %fp,#-366
    moveml %d3-%d7/%a2-%a4,%sp@-
    movel %sp,%fp@(-366)
    clrl %fp@(-12)
    moveal %a5@,%a4
    moveal %a4@,%a3
    moveal %fp@(8),%a2
    clrb %fp@(12)
    jbsr PICITEM1_B5E
    movew %d0,%d7
    cmpiw #255,%d7
    jbeq PICITEM1_BE8
    jbcs PICITEM1_5C
    movel %a3@(104),%d0
    moveal 0x1de0,%a0
    jbeq PICITEM1_42
    tstw %a3@(6)
    jbpl PICITEM1_42
    moveal %d0,%a0
    moveal %a0@(52),%a0
PICITEM1_42:            /* through the port's opcode proc */
    pea %a2@(20)
    pea %a2@(28)
    movew %d7,%sp@-
    movew %a2@(52),%sp@-
    jsr %a0@
    moveb #1,%fp@(12)
    jbra PICITEM1_BE8
PICITEM1_5C:            /* opcodes 0x20 and up: by the high nibble, bit 3 the "same shape" form */
    moveb #1,%fp@(12)
    cmpiw #32,%d7
    jbcs PICITEM1_A4
    moveb %d7,%d0
    andiw #240,%d0
    btst #3,%d7
    sne %fp@(-94)
    andiw #7,%d7
    lsrw #3,%d0
    movew %pc@(PICITEM1_84,%d0:w),%d0
    jmp %pc@(PICITEM1_84,%d0:w)
PICITEM1_84:            /* dispatch table for shape opcodes (data) */
    .short  PICITEM1_BE8-PICITEM1_84	| 40831FE4
    .short  PICITEM1_BE8-PICITEM1_84	| 40831FE6
    .short  PICITEM1_44A-PICITEM1_84	| 40831FE8
    .short  PICITEM1_5A8-PICITEM1_84	| 40831FEA
    .short  PICITEM1_5D2-PICITEM1_84	| 40831FEC
    .short  PICITEM1_604-PICITEM1_84	| 40831FEE
    .short  PICITEM1_62E-PICITEM1_84	| 40831FF0
    .short  PICITEM1_664-PICITEM1_84	| 40831FF2
    .short  PICITEM1_6AE-PICITEM1_84	| 40831FF4
    .short  PICITEM1_6F8-PICITEM1_84	| 40831FF6
    .short  PICITEM1_A2C-PICITEM1_84	| 40831FF8
    .short  PICITEM1_BE8-PICITEM1_84	| 40831FFA
    .short  PICITEM1_BE8-PICITEM1_84	| 40831FFC
    .short  PICITEM1_40E-PICITEM1_84	| 40831FFE
    .short  PICITEM1_408-PICITEM1_84	| 40832000
    .short  PICITEM1_408-PICITEM1_84	| 40832002
PICITEM1_A4:            /* opcodes 0..31: dispatch table */
    andiw #31,%d7
    addw %d7,%d7
    movew %pc@(PICITEM1_B2,%d7:w),%d0
    jmp %pc@(PICITEM1_B2,%d0:w)
PICITEM1_B2:            /* opcode 0..31 dispatch offsets (data) */
    .short  PICITEM1_BE8-PICITEM1_B2	| 40832012
    .short  PICITEM1_F2-PICITEM1_B2	| 40832014
    .short  PICITEM1_18A-PICITEM1_B2	| 40832016
    .short  PICITEM1_1E0-PICITEM1_B2	| 40832018
    .short  PICITEM1_1E8-PICITEM1_B2	| 4083201A
    .short  PICITEM1_1F2-PICITEM1_B2	| 4083201C
    .short  PICITEM1_202-PICITEM1_B2	| 4083201E
    .short  PICITEM1_20A-PICITEM1_B2	| 40832020
    .short  PICITEM1_288-PICITEM1_B2	| 40832022
    .short  PICITEM1_1A4-PICITEM1_B2	| 40832024
    .short  PICITEM1_1B4-PICITEM1_B2	| 40832026
    .short  PICITEM1_2BA-PICITEM1_B2	| 40832028
    .short  PICITEM1_2DC-PICITEM1_B2	| 4083202A
    .short  PICITEM1_1FA-PICITEM1_B2	| 4083202C
    .short  PICITEM1_1C4-PICITEM1_B2	| 4083202E
    .short  PICITEM1_1D2-PICITEM1_B2	| 40832030
    .short  PICITEM1_22C-PICITEM1_B2	| 40832032
    .short  PICITEM1_266-PICITEM1_B2	| 40832034
    .short  PICITEM1_34A-PICITEM1_B2	| 40832036
    .short  PICITEM1_354-PICITEM1_B2	| 40832038
    .short  PICITEM1_35E-PICITEM1_B2	| 4083203A
    .short  PICITEM1_36E-PICITEM1_B2	| 4083203C
    .short  PICITEM1_384-PICITEM1_B2	| 4083203E
    .short  PICITEM1_BE8-PICITEM1_B2	| 40832040
    .short  PICITEM1_BE8-PICITEM1_B2	| 40832042
    .short  PICITEM1_BE8-PICITEM1_B2	| 40832044
    .short  PICITEM1_312-PICITEM1_B2	| 40832046
    .short  PICITEM1_32E-PICITEM1_B2	| 40832048
    .short  PICITEM1_396-PICITEM1_B2	| 4083204A
    .short  PICITEM1_3A0-PICITEM1_B2	| 4083204C
    .short  PICITEM1_3C2-PICITEM1_B2	| 4083204E
    .short  PICITEM1_3DE-PICITEM1_B2	| 40832050
PICITEM1_F2:            /* ClipRgn (1): read the region, map it to the destination */
    jbsr PICITEM1_B86
    moveal %fp@(8),%a2
    movel %fp@(-4),%sp@-
    movel %a2@(44),%sp@-
PICITEM1_102:           /* rectangular: just map the box */
    jsr @(0x1170,%za0)@(0x0)	| 40832062
    moveal %fp@(8),%a2
    moveal %fp@(-4),%a0
    moveal %a0@,%a0
    cmpiw #10,%a0@+
    jbne PICITEM1_128
    cmpil #-2147385343,%a0@+
    jbne PICITEM1_128
    cmpil #2147450879,%a0@+
    jbra PICITEM1_13A
PICITEM1_128:           /* MapRgn */
    movel %fp@(-4),%sp@-
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11ec,%za0)@(0)	| 40832094
PICITEM1_13A:           /* SectRgn with the saved clip into the port */
    moveal %fp@(8),%a2
    movel %fp@(-4),%sp@-
    movel %a2@(48),%sp@-
    movel %a3@(28),%sp@-
    jsr @(0x1190,%za0)@(0x0)	| 408320AA
    jbra PICITEM1_BC0
    moveq #8,%d6
    braw PICITEM1_B04
PICITEM1_15A:           /* read 4 bytes */
    moveq #4,%d6
    jbra PICITEM1_B04
PICITEM1_160:           /* read 2 bytes */
    moveq #2,%d6
    jbra PICITEM1_B04

PICITEM1_166:           /* color port: dispose of the old pixpat first */
    tstw %a3@(6)
    jbmi PICITEM1_16E
    rts
PICITEM1_16E:           /* dispose */
    movel %a0,%sp@-
    jsr @(0x1620,%za0)@(0x0)	| 408320D0
    rts

PICITEM1_178:           /* read an 8-byte pattern onto the stack */
    moveal %sp@+,%a0
    moveq #8,%d0
    subaw %d0,%sp
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew %d0,%sp@-
    movel %a0,%sp@-
    jmp %pc@(GETPICDATA)
PICITEM1_18A:           /* BkPat (2) */
    moveal %a3@(32),%a0
    jbsr PICITEM1_166
    jbsr PICITEM1_178
    jsr @(0xff0,%za0)@(0)	| 408320F2
PICITEM1_198:           /* pop */
    addqw #8,%sp
PICITEM1_19A:           /* done */
    moveb #1,%fp@(12)
    jbra PICITEM1_BE8
PICITEM1_1A4:           /* PnPat (9) */
    moveal %a3@(58),%a0
    jbsr PICITEM1_166
    jbsr PICITEM1_178
    jsr @(0x1074,%za0)@(0x0)	| 4083210C
    jbra PICITEM1_198
PICITEM1_1B4:           /* FillPat (0x0A) */
    moveal %a3@(62),%a0
    jbsr PICITEM1_166
    jbsr PICITEM1_178
    moveq #0,%d0
    jsr %pc@(trap_SETFILLPAT)
    jbra PICITEM1_198
PICITEM1_1C4:           /* FgColor (0x0E) */
    jsr %pc@(GETLONG)
    movel %d0,%sp@-
    jsr @(0xf88,%za0)@(0)	| 4083212A
    jbra PICITEM1_19A
PICITEM1_1D2:           /* BkColor (0x0F) */
    jsr %pc@(GETLONG)
    movel %d0,%sp@-
    jsr @(0xf8c,%za0)@(0)	| 40832138
    jbra PICITEM1_19A
PICITEM1_1E0:           /* TxFont (3) */
    lea %a3@(68),%a3
    jbra PICITEM1_160
PICITEM1_1E8:           /* TxFace (4) */
    lea %a3@(70),%a3
    moveq #1,%d6
    jbra PICITEM1_B04
PICITEM1_1F2:           /* TxMode (5) */
    pea %a3@(72)
    jbra PICITEM1_28C
PICITEM1_1FA:           /* TxSize (0x0D) */
    lea %a3@(74),%a3
    jbra PICITEM1_160
PICITEM1_202:           /* SpExtra (6) */
    lea %a3@(76),%a3
    jbra PICITEM1_15A
PICITEM1_20A:           /* PnSize (7), scaled */
    jsr %pc@(GETLONG)
    movel %d0,%a3@(52)
    pea %a3@(52)
    moveal %fp@(8),%a2
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11e0,%za0)@(0)	| 40832182
    jbra PICITEM1_BE8
PICITEM1_22C:           /* TxRatio (0x10) */
    moveal %fp@(8),%a3
    jsr %pc@(GETLONG)
    movel %d0,%a3@(36)
    jsr %pc@(GETLONG)
    movel %d0,%a3@(40)
    pea %a3@(36)
    pea %a3@(40)
    pea %a3@(20)
    jsr %pc@(MAPRATIO)
    pea %a3@(36)
    pea %a3@(20)
    pea %a3@(28)
    jsr @(0x11e0,%za0)@(0)	| 408321BC
    jbra PICITEM1_BE8
PICITEM1_266:           /* Version (0x11) */
    jsr %pc@(GETUBYTE)
    cmpiw #1,%d0
    jbeq PICITEM1_27C
    movew %d0,%d6
    lslw #8,%d6
    jsr %pc@(GETUBYTE)
    moveb %d0,%d6
    movew %d6,%d0
PICITEM1_27C:           /* store it */
    moveal %fp@(8),%a3
    movew %d0,%a3@(52)
    jbra PICITEM1_BE8
PICITEM1_288:           /* PnMode (8) */
    pea %a3@(56)
PICITEM1_28C:           /* the mode; arithmetic modes in old ports become boolean */
    jsr %pc@(GETWORD)
    tstw %a3@(6)
    jbmi PICITEM1_2AA
    tstl %a3@(104)
    jbeq PICITEM1_2AA
    btst #5,%d0
    jbeq PICITEM1_2AA
    andiw #7,%d0
    moveb %pc@(PICITEM1_2B2,%d0:w),%d0
PICITEM1_2AA:           /* store */
    moveal %sp@+,%a0
    movew %d0,%a0@
    jbra PICITEM1_BE8
PICITEM1_2B2:           /* data */
    .short  0x0003, 0x0201, 0x0103, 0x0201	| 40832212
PICITEM1_2BA:           /* OvSize (0x0B), scaled */
    jsr %pc@(GETLONG)
    moveal %fp@(8),%a2
    movel %d0,%a2@(16)
    pea %a2@(16)
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11e0,%za0)@(0)	| 40832232
    jbra PICITEM1_BE8
PICITEM1_2DC:           /* Origin (0x0C) */
    jsr %pc@(GETLONG)
    moveal %fp@(8),%a2
    addw %d0,%a2@(20)
    addw %d0,%a2@(24)
    addw %d0,%a4@(-168)
    swap %d0
    addw %d0,%a2@(22)
    addw %d0,%a2@(26)
    addw %d0,%a4@(-166)
    movel %a2@(44),%sp@-
    clrl %sp@-
    jsr @(0x1160,%za0)@(0x0)	| 40832264
    movel %sp@,%fp@(-4)
    jbra PICITEM1_102
PICITEM1_312:           /* RGBFgCol (0x1A) */
    jsr %pc@(GETLONG)
    movel %d0,%d6
    jsr %pc@(GETWORD)
    movew %d0,%sp@-
    movel %d6,%sp@-
    movel %sp,%sp@-
    jsr @(0x1650,%za0)@(0x0)	| 40832282
    addqw #6,%sp
    jbra PICITEM1_BE8
PICITEM1_32E:           /* RGBBkCol (0x1B) */
    jsr %pc@(GETLONG)
    movel %d0,%d6
    jsr %pc@(GETWORD)
    movew %d0,%sp@-
    movel %d6,%sp@-
    movel %sp,%sp@-
    jsr @(0x1654,%za0)@(0x0)	| 4083229E
    addqw #6,%sp
    jbra PICITEM1_BE8
PICITEM1_34A:           /* BkPixPat (0x12) */
    pea %a3@(32)
    movel %a3@(32),%sp@-
    jbra PICITEM1_366
PICITEM1_354:           /* PnPixPat (0x13) */
    pea %a3@(58)
    movel %a3@(58),%sp@-
    jbra PICITEM1_366
PICITEM1_35E:           /* FillPixPat (0x14) */
    pea %a3@(40)
    movel %a3@(62),%sp@-
PICITEM1_366:           /* read it */
    jsr %pc@(GETPICPIXPAT)
    jbra PICITEM1_BE8
PICITEM1_36E:           /* PnLocHFrac (0x15) */
    jsr %pc@(GETWORD)
    tstw %a3@(6)
    jbpl PICITEM1_380
    moveal %fp@(8),%a2
    movew %d0,%a2@(56)
PICITEM1_380:           /* done */
    jbra PICITEM1_BE8
PICITEM1_384:           /* ChExtra (0x16) */
    jsr %pc@(GETWORD)
    tstw %a3@(6)
    jbpl PICITEM1_380
    movew %d0,%a3@(12)
    jbra PICITEM1_BE8
PICITEM1_396:           /* HiliteMode (0x1C) */
    bclr #7,HiliteMode
    jbra PICITEM1_BE8
PICITEM1_3A0:           /* HiliteColor (0x1D) */
    jsr %pc@(GETLONG)
    movel %d0,%d6
    jsr %pc@(GETWORD)
    tstw %a3@(6)
    jbpl PICITEM1_3BE
    moveal %a3@(8),%a0
    moveal %a0@,%a0
    movel %d6,%a0@(6)
    movew %d0,%a0@(10)
PICITEM1_3BE:           /* done */
    jbra PICITEM1_BE8
PICITEM1_3C2:           /* DefHilite (0x1E) */
    tstw %a3@(6)
    jbpl PICITEM1_3DA
    moveal %a3@(8),%a0
    moveal %a0@,%a0
    movel HiliteRGB,%a0@(6)
    movew 0xda4,%a0@(10)
PICITEM1_3DA:           /* done */
    jbra PICITEM1_BE8
PICITEM1_3DE:           /* OpColor (0x1F) */
    jsr %pc@(GETLONG)
    movel %d0,%d6
    jsr %pc@(GETWORD)
    tstw %a3@(6)
    jbpl PICITEM1_3FA
    moveal %a3@(8),%a0
    moveal %a0@,%a0
    movel %d6,%a0@
    movew %d0,%a0@(4)
PICITEM1_3FA:           /* done */
    jbra PICITEM1_BE8
PICITEM1_3FE:           /* skip a reserved opcode's data (size in d0, or d1 for the "same" form) */
    tstb %fp@(-94)
    jbeq PICITEM1_418
    movel %d1,%d0
    jbra PICITEM1_418
PICITEM1_408:           /* size in a long */
    jsr %pc@(GETLONG)
    jbra PICITEM1_418
PICITEM1_40E:           /* size in a word */
    jsr %pc@(GETWORD)
    swap %d0
    clrw %d0
    swap %d0
PICITEM1_418:           /* skip */
    jbsr PICITEM1_41E
    jbra PICITEM1_BE8

PICITEM1_41E:           /* skip d0 bytes in 256-byte pieces */
    moveml %d6-%d7,%sp@-
    movel #256,%d6
    subal %d6,%sp
    movel %d0,%d7
    jbeq PICITEM1_442
PICITEM1_42E:           /* piece */
    movew %d6,%d0
    cmpl %d6,%d7
    jbge PICITEM1_436
    movew %d7,%d0
PICITEM1_436:           /* read */
    movel %sp,%sp@-
    movew %d0,%sp@-
    jsr %pc@(GETPICDATA)
    subl %d6,%d7
    jbgt PICITEM1_42E
PICITEM1_442:           /* return */
    addal %d6,%sp
    moveml %sp@+,%d6-%d7
    rts
PICITEM1_44A:           /* lines (0x20..0x23): Line, LineFrom, ShortLine, ShortLineFrom */
    cmpiw #3,%d7
    jbgt PICITEM1_40E
    tstb %fp@(-94)
    jbne PICITEM1_4D8
    moveal %fp@(8),%a2
    movel %a2@(8),%d0
    rorw #1,%d7
    jbcs PICITEM1_468
    jsr %pc@(GETLONG)
PICITEM1_468:           /* the start point */
    movel %d0,%a3@(48)
    movel %d0,%fp@(-98)
    moveal %fp@(8),%a2
    pea %a3@(48)
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11e4,%za0)@(0)	| 408323E0
    rorw #1,%d7
    jbcs PICITEM1_494
    jsr %pc@(GETLONG)
    movel %d0,%fp@(-98)
    jbra PICITEM1_4A4
PICITEM1_494:           /* short: byte offsets */
    jbsr PICITEM1_B10
    addw %d0,%fp@(-96)
    jbsr PICITEM1_B10
    addw %d0,%fp@(-98)
PICITEM1_4A4:           /* the end point; LineTo through the port's lineProc */
    moveal %fp@(8),%a2
    movel %fp@(-98),%a2@(8)
    pea %fp@(-98)
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11e4,%za0)@(0)	| 4083241A
    movel %fp@(-98),%sp@-
    moveal 0x1040,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_4D4
    moveal %d0,%a0
    moveal %a0@(4),%a0
PICITEM1_4D4:           /* done */
    jbra PICITEM1_BB2
PICITEM1_4D8:           /* text (0x28..0x2B): LongText, DHText, DVText, DHDVText */
    moveal %fp@(8),%a2
    movew %a2@(56),%a2@(54)
    movew #-32768,%a2@(56)
    andiw #3,%d7
    jbeq PICITEM1_510
    rorw #1,%d7
    jbcc PICITEM1_4FE
    jsr %pc@(GETUBYTE)
    moveal %fp@(8),%a2
    addw %d0,%a2@(14)
PICITEM1_4FE:           /* dv */
    rorw #1,%d7
    jbcc PICITEM1_51C
    jsr %pc@(GETUBYTE)
    moveal %fp@(8),%a2
    addw %d0,%a2@(12)
    jbra PICITEM1_51C
PICITEM1_510:           /* LongText: the point */
    jsr %pc@(GETLONG)
    moveal %fp@(8),%a2
    movel %d0,%a2@(12)
PICITEM1_51C:           /* the characters */
    jsr %pc@(GETUBYTE)
    movew %d0,%d6
    pea %fp@(-354)
    movew %d6,%sp@-
    jsr %pc@(GETPICDATA)
    movel %a2@(12),%a3@(48)
    moveal %fp@(8),%a2
    cmpiw #1,%a2@(52)
    jbeq PICITEM1_572
    tstw %a3@(6)
    jbpl PICITEM1_572
    movew %a2@(54),%sp@-
    movew %a2@(14),%sp@-
    movew #-32768,%sp@-
    movew %a2@(12),%sp@-
    movel %sp,%sp@-
    pea %a2@(20)
    pea %a2@(28)
    jsr %pc@(MAPFIXPT)
    movew %sp@+,%a3@(48)
    movew %sp@+,%d0
    movew %sp@+,%a3@(50)
    movew %sp@+,%a3@(14)
    jbra PICITEM1_584
PICITEM1_572:           /* map the location */
    pea %a3@(48)
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11e4,%za0)@(0)	| 408324DE
PICITEM1_584:           /* draw through the port's textProc, scaled */
    movew %d6,%sp@-
    pea %fp@(-354)
    moveal %fp@(8),%a2
    movel %a2@(36),%sp@-
    movel %a2@(40),%sp@-
    moveal 0x1008,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_5A4
    moveal %d0,%a0
    moveal %a0@,%a0
PICITEM1_5A4:           /* done */
    jbra PICITEM1_BB2
PICITEM1_5A8:           /* rectangles (0x30..0x34); 0x35..0x37 reserved */
    cmpiw #4,%d7
    blew PICITEM1_5B8
    moveq #8,%d0
    moveq #0,%d1
    jbra PICITEM1_3FE
PICITEM1_5B8:           /* the rectangle; rectProc */
    moveb %d7,%sp@-
    jbsr PICITEM1_B22
    moveal 0x1080,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_5CE
    moveal %d0,%a0
    moveal %a0@(8),%a0
PICITEM1_5CE:           /* done */
    jbra PICITEM1_BB2
PICITEM1_5D2:           /* rounded rectangles (0x40..) */
    cmpiw #4,%d7
    blew PICITEM1_5E2
    moveq #8,%d0
    moveq #0,%d1
    jbra PICITEM1_3FE
PICITEM1_5E2:           /* the rectangle and oval size; rRectProc */
    moveb %d7,%sp@-
    jbsr PICITEM1_B22
    moveal %fp@(8),%a2
    movel %a2@(16),%sp@-
    moveal 0x10bc,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_600
    moveal %d0,%a0
    moveal %a0@(12),%a0
PICITEM1_600:           /* done */
    jbra PICITEM1_BB2
PICITEM1_604:           /* ovals (0x50..) */
    cmpiw #4,%d7
    blew PICITEM1_614
    moveq #8,%d0
    moveq #0,%d1
    jbra PICITEM1_3FE
PICITEM1_614:           /* the rectangle; ovalProc */
    moveb %d7,%sp@-
    jbsr PICITEM1_B22
    moveal 0x10d8,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_62A
    moveal %d0,%a0
    moveal %a0@(16),%a0
PICITEM1_62A:           /* done */
    jbra PICITEM1_BB2
PICITEM1_62E:           /* arcs (0x60..) */
    cmpiw #4,%d7
    blew PICITEM1_63E
    moveq #12,%d0
    moveq #4,%d1
    jbra PICITEM1_3FE
PICITEM1_63E:           /* rectangle and angles; arcProc */
    moveb %d7,%sp@-
    jbsr PICITEM1_B22
    jsr %pc@(GETWORD)
    movew %d0,%sp@-
    jsr %pc@(GETWORD)
    movew %d0,%sp@-
    moveal 0x10f4,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_660
    moveal %d0,%a0
    moveal %a0@(20),%a0
PICITEM1_660:           /* done */
    jbra PICITEM1_BB2
PICITEM1_664:           /* polygons (0x70..) */
    cmpiw #4,%d7
    blew PICITEM1_67A
    tstb %fp@(-94)
    jbne PICITEM1_676
    jbsr PICITEM1_B86
PICITEM1_676:           /* done */
    jbra PICITEM1_BE8
PICITEM1_67A:           /* read and map the polygon; polyProc */
    jbsr PICITEM1_B86
    movel %fp@(-4),%sp@-
    moveal %fp@(8),%a2
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11f0,%za0)@(0)	| 408325EE
    moveb %d7,%sp@-
    movel %fp@(-4),%sp@-
    moveal 0x1114,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_6AA
    moveal %d0,%a0
    moveal %a0@(24),%a0
PICITEM1_6AA:           /* done */
    jbra PICITEM1_BB6
PICITEM1_6AE:           /* regions (0x80..) */
    cmpiw #4,%d7
    blew PICITEM1_6C4
    tstb %fp@(-94)
    jbne PICITEM1_6C0
    jbsr PICITEM1_B86
PICITEM1_6C0:           /* done */
    jbra PICITEM1_BE8
PICITEM1_6C4:           /* read and map the region; rgnProc */
    jbsr PICITEM1_B86
    movel %fp@(-4),%sp@-
    moveal %fp@(8),%a2
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11ec,%za0)@(0)	| 40832638
    moveb %d7,%sp@-
    movel %fp@(-4),%sp@-
    moveal 0x1144,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_6F4
    moveal %d0,%a0
    moveal %a0@(28),%a0
PICITEM1_6F4:           /* done */
    jbra PICITEM1_BB6
PICITEM1_6F8:           /* bits (0x90, 0x91, 0x98, 0x99, 0x9A, 0x9B) */
    cmpiw #3,%d7
    jbgt PICITEM1_40E
    cmpiw #1,%d7
    jble PICITEM1_70A
    jsr %pc@(GETLONG)
PICITEM1_70A:           /* rowBytes: a pixmap (bit 15) or a bitmap */
    jsr %pc@(GETWORD)
    movew %d0,%fp@(-74)
    moveq #8,%d1
    movew %d0,%d6
    jbpl PICITEM1_71A
    moveq #44,%d1
PICITEM1_71A:           /* the pixmap record and its color table */
    pea %fp@(-72)
    movew %d1,%sp@-
    jsr %pc@(GETPICDATA)
    clrw %fp@(-64)
    tstw %d6
    jbpl PICITEM1_746
    clrl %fp@(-36)
    btst #1,%d7
    jbne PICITEM1_746
    moveq #8,%d0
    jsr %pc@(RNEWHANDLE)
    movel %a0,%fp@(-36)
    movel %a0,%sp@-
    jsr %pc@(GETPICTABLE)
PICITEM1_746:           /* rectangles and mode; map the destination */
    pea %fp@(-28)
    movew #16,%sp@-
    jsr %pc@(GETPICDATA)
    moveal %fp@(8),%a2
    pea %fp@(-20)
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11e8,%za0)@(0)	| 408326C2
    pea %fp@(-78)
    pea %fp@(-28)
    pea %fp@(-20)
    jsr %pc@(GETWORD)
    movew %d0,%sp@-
    clrl %sp@-
    btst #0,%d7
    jbeq PICITEM1_7A6
    jbsr PICITEM1_B86
    movel %fp@(-4),%sp@-
    moveal %fp@(8),%a2
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11ec,%za0)@(0)	| 408326F6
    movel %fp@(-4),%sp@
    movel %fp@(-4),%fp@(-8)
PICITEM1_7A6:           /* the pixel data size; a buffer (temporary memory if needed) */
    movew %fp@(-68),%d6
    subw %fp@(-72),%d6
    movew %d6,%d5
    movew %fp@(-74),%d0
    andiw #32767,%d0
    muluw %d0,%d5
    movel %d5,%d0
    .short  0xA122	| 4083271C _NewHandle (flags 0x0100)
    jbne PICITEM1_86A
    movel %a0,%fp@(-4)
    _HLock
PICITEM1_7C8:           /* read the data (GETPMDATA); bitsProc */
    pea %fp@(-78)
    movel %a0,%sp@-
    jsr %pc@(GETPMDATA)
    moveal %fp@(-4),%a0
    movel %a0@,%fp@(-78)
    moveal 0x11ac,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_84C
    exg %d0,%a0
    cmpl %a0@(32),%d0
    jbeq PICITEM1_848
    tstw %fp@(-74)
    jbpl PICITEM1_848
    tstw %a3@(6)
    jbmi PICITEM1_848
    lea %fp@(-74),%a0
    moveq #0,%d0
    movew %a0@+,%d0
    andiw #32767,%d0
    lsll #3,%d0
    divuw %fp@(-46),%d0
    addiw #15,%d0
    lsrl #4,%d0
    jbeq PICITEM1_84E
    addw %d0,%d0
    lea %fp@(-88),%a1
    movew %d0,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %fp@(-78),%fp@(-92)
    pea %fp@(-78)
    pea %fp@(-92)
    pea %fp@(-72)
    movel %sp@,%sp@-
    clrw %sp@-
    clrl %sp@-
    jsr @(0x11b0,%za0)@(0)	| 40832796
    lea %fp@(-92),%a0
    movel %a0,%sp@(14)
    moveal %a3@(104),%a0
PICITEM1_848:           /* the port's proc */
    moveal %a0@(32),%a0
PICITEM1_84C:           /* call */
    jsr %a0@
PICITEM1_84E:           /* dispose of the color table */
    tstw %fp@(-74)
    jbpl PICITEM1_85E
    movel %fp@(-36),%d0
    jbeq PICITEM1_85E
    moveal %d0,%a0
    _DisposHandle
PICITEM1_85E:           /* a mask region (odd opcodes)? */
    btst #0,%d7
    jbeq PICITEM1_BC0
    jbra PICITEM1_BBA
PICITEM1_86A:           /* too big: in bands */
    movel %d5,%d0
    jsr @(0x1a70,%za0)@(0)	| 408327CC
    movel %a0,%fp@(-12)
    movel %a0,%fp@(-4)
    movel %d0,%d4
    cmpl %d5,%d0
    jbge PICITEM1_7C8
    movew %fp@(-74),%d5
    andiw #32767,%d5
    extl %d5
    .short  0xA162	| 408327EC _PurgeSpace (flags 0x0100)
    movel %a0,%d3
    cmpl %d3,%d4
    jble PICITEM1_8A0
    movel %d4,%d3
    divull %d5,%d3,%d3
    jbne PICITEM1_8C8
    jbra PICITEM1_BDA
PICITEM1_8A0:           /* band height */
    moveal %fp@(-12),%a0
    jsr @(0x1a78,%za0)@(0)	| 40832804
    clrl %fp@(-12)
    divull %d5,%d3,%d3
    jbeq PICITEM1_BDA
    movel %d5,%d0
    mulul %d3,%d0
    .short  0xA122	| 4083281C _NewHandle (flags 0x0100)
    jbne PICITEM1_BDA
    movel %a0,%fp@(-4)
    _HLock
PICITEM1_8C8:           /* each band: adjust the rectangles */
    movew %fp@(-68),%d6
    movew %fp@(-72),%d0
    addw %d3,%d0
    movew %d0,%fp@(-68)
    movew %fp@(-28),%d0
    addw %d3,%d0
    movew %d0,%fp@(-24)
    movew %fp@(-16),%d5
    movew %d5,%d4
    subw %fp@(-20),%d4
    clrl %sp@-
    movew %d4,%sp@-
    movew %d6,%sp@-
    movew %fp@(-72),%d0
    subw %d0,%sp@
    jsr @(0xfa4,%za0)@(0)	| 40832856
    movel %sp@+,%d0
    movel %d0,%d4
    .short  0x4C03, 0x4004	| 40832860 mulul %d3,%d4
    movew %fp@(-20),%d2
    swap %d2
    clrw %d2
    addl %d4,%d2
    swap %d2
    movew %d2,%fp@(-16)
    swap %d2
    moveal %fp@(-4),%a0
    movel %a0@,%fp@(-78)
    moveal 0x11ac,%a4
    bclr #31,%d7
    movel %a3@(104),%d0
    jbeq PICITEM1_97E
    moveal %d0,%a0
    movel %a0@(32),%d0
    cmpl %a4,%d0
    jbeq PICITEM1_97E
    moveal %d0,%a4
    tstw %fp@(-74)
    jbpl PICITEM1_97E
    tstw %a3@(6)
    jbmi PICITEM1_97E
    bset #31,%d7
    lea %fp@(-74),%a0
    moveq #0,%d0
    movew %a0@+,%d0
    andiw #32767,%d0
    lsll #3,%d0
    divuw %fp@(-46),%d0
    addiw #15,%d0
    lsrl #4,%d0
    jbeq PICITEM1_84E
    addw %d0,%d0
    lea %fp@(-88),%a1
    movew %d0,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %fp@(-78),%fp@(-92)
    lea %fp@(-92),%a0
    movel %a0,%sp@(14)
PICITEM1_97E:           /* read the band */
    pea %fp@(-78)
    movel %fp@(-4),%sp@-
    moveal %d2,%a2
    jsr %pc@(GETPMDATA)
    tstl %d7
    jbpl PICITEM1_9A8
    pea %fp@(-78)
    pea %fp@(-92)
    pea %fp@(-72)
    movel %sp@,%sp@-
    clrw %sp@-
    clrl %sp@-
    jsr @(0x11b0,%za0)@(0)	| 40832902
PICITEM1_9A8:           /* draw it */
    movel %sp@(14),%sp@-
    movel %sp@(14),%sp@-
    movel %sp@(14),%sp@-
    movew %sp@(16),%sp@-
    movel %sp@(14),%sp@-
    jsr %a4@
    movel %a2,%d2
    addw %d3,%fp@(-72)
    addw %d3,%fp@(-68)
    addw %d3,%fp@(-86)
    addw %d3,%fp@(-82)
    addw %d3,%fp@(-28)
    addw %d3,%fp@(-24)
    movew %fp@(-16),%fp@(-20)
    addl %d4,%d2
    swap %d2
    movew %d2,%fp@(-16)
    swap %d2
    cmpw %fp@(-68),%d6
    jbgt PICITEM1_97E
    movew %d5,%fp@(-16)
    movew %d6,%fp@(-68)
    movew %d6,%fp@(-82)
    movew %d6,%fp@(-24)
    pea %fp@(-78)
    movel %fp@(-4),%sp@-
    jsr %pc@(GETPMDATA)
    tstl %d7
    jbpl PICITEM1_A26
    pea %fp@(-78)
    pea %fp@(-92)
    pea %fp@(-72)
    movel %sp@,%sp@-
    clrw %sp@-
    clrl %sp@-
    jsr @(0x11b0,%za0)@(0)	| 40832980
PICITEM1_A26:           /* last band */
    jsr %a4@
    jbra PICITEM1_84E
PICITEM1_A2C:           /* comments (0xA0 ShortComment, 0xA1 LongComment) */
    tstb %fp@(-94)
    jbne PICITEM1_40E
    cmpiw #1,%d7
    jbgt PICITEM1_40E
    jsr %pc@(GETWORD)
    movew %d0,%sp@-
    tstb %d7
    jbne PICITEM1_A5E
    clrw %sp@-
    clrl %sp@-
    moveal 0x11c4,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_A5A
    moveal %d0,%a0
    moveal %a0@(36),%a0
PICITEM1_A5A:           /* done */
    jbra PICITEM1_BB2
PICITEM1_A5E:           /* long comment: read it into a handle; commentProc */
    jsr %pc@(GETWORD)
    movew %d0,%sp@-
    clrw %d4
    jbsr PICITEM1_B8C
    movel %fp@(-4),%sp@-
    moveal 0x11c4,%a0
    movel %a3@(104),%d0
    jbeq PICITEM1_A7E
    moveal %d0,%a0
    moveal %a0@(36),%a0
PICITEM1_A7E:           /* done */
    jbra PICITEM1_BB6
    moveal %a5@,%a0	| 408329E2
    moveal %a0@(-122),%a1
    movew %a0@(-118),%d0
    andiw #32767,%d0
    lea %pc@(PICITEM1_A7E_22),%a0
    moveq #24,%d1
PICITEM1_A7E_18:
    movel %a0@+,%a1@	| 408329F6
    addaw %d0,%a1
    dbf %d1,PICITEM1_A7E_18
PICITEM1_A7E_20:
    bras PICITEM1_A7E_20	| 408329FE
PICITEM1_A7E_22:
    .byte   0x00, 0x00, 0x00, 0x00, 0x7E, 0xE9, 0xD2, 0x00, 0x44, 0xA9, 0x1A, 0x00, 0x74, 0xA9, 0x96, 0x10	| 40832A00
    .byte   0x14, 0xA9, 0x12, 0x30, 0x74, 0xEF, 0xD2, 0x60, 0x00, 0x00, 0x00, 0x40, 0x77, 0x74, 0x43, 0x58	| 40832A10
    .byte   0x45, 0x57, 0xC7, 0xFC, 0x77, 0x55, 0x4F, 0xFE, 0x46, 0x54, 0x4F, 0xF8, 0x45, 0x74, 0x4F, 0xF0	| 40832A20
    .byte   0x00, 0x00, 0x0F, 0xF0, 0x77, 0x74, 0xEF, 0xF8, 0x55, 0x54, 0x8F, 0xFE, 0x77, 0x74, 0xCF, 0xFE	| 40832A30
    .byte   0x54, 0x44, 0x87, 0xBC, 0x54, 0x47, 0xE3, 0x18, 0x00, 0x00, 0x00, 0x00, 0x77, 0x45, 0xD7, 0xFE	| 40832A40
    .byte   0x45, 0x6D, 0x55, 0x4A, 0x45, 0x55, 0xD5, 0x6E, 0x45, 0x45, 0x15, 0x4C, 0x77, 0x45, 0x1D, 0x7A	| 40832A50
    .byte   0x00, 0x00, 0x00, 0x00	| 40832A60

PICITEM1_B04:           /* read d6 bytes into the port field at a3 */
    movel %a3,%sp@-
    movew %d6,%sp@-
    jsr %pc@(GETPICDATA)
    jbra PICITEM1_BE8

PICITEM1_B10:           /* read a signed byte */
    clrb %sp@-
    movel %sp,%sp@-
    movew #1,%sp@-
    jsr %pc@(GETPICDATA)
    moveb %sp@+,%d0
    extw %d0
    rts

PICITEM1_B22:           /* shapes: a new rectangle, or the last one for the "same" form; map it */
    tstb %fp@(-94)
    jbne PICITEM1_B36
    moveal %fp@(8),%a2
    pea %a2@
    movew #8,%sp@-
    jsr %pc@(GETPICDATA)
PICITEM1_B36:           /* map the rectangle */
    moveal %fp@(8),%a2
    movel %a2@,%fp@(-20)
    movel %a2@(4),%fp@(-16)
    pea %fp@(-20)
    pea %a2@(20)
    pea %a2@(28)
    jsr @(0x11e8,%za0)@(0)	| 40832AB0
    moveal %sp@+,%a0
    pea %fp@(-20)
    jmp %a0@

PICITEM1_B5E:           /* the next opcode: a byte (version 1) or a word, word aligned */
    moveal %fp@(8),%a2
    cmpiw #1,%a2@(52)
    jbeq PICITEM1_B80
    moveal %a5@,%a0
    movel %a0@(-180),%d0
    btst #0,%d0
    jbeq PICITEM1_B7A
    jsr %pc@(GETUBYTE)
PICITEM1_B7A:           /* word */
    jsr %pc@(GETWORD)
    rts
PICITEM1_B80:           /* byte */
    jsr %pc@(GETUBYTE)
    rts

PICITEM1_B86:           /* read a polygon/region into a handle (size word first) */
    moveq #2,%d4
    jsr %pc@(GETWORD)

PICITEM1_B8C:           /* allocate, read */
    extl %d0
    movel %d0,%d5
    .short  0xA122	| 40832AF0 _NewHandle (flags 0x0100)
    jbne PICITEM1_BDA
    movel %a0,%fp@(-4)
    _HLock
    moveal %a0@,%a0
    movew %d5,%a0@
    subw %d4,%d5
    pea %a0@(0x0,%d4:w)
    movew %d5,%sp@-
    jsr %pc@(GETPICDATA)
    moveal %fp@(-4),%a0
    _HUnlock
    rts

PICITEM1_BB2:           /* call the proc */
    jsr %a0@
    jbra PICITEM1_BE8

PICITEM1_BB6:           /* call it, then dispose */
    jsr %a0@
    jbra PICITEM1_BC0

PICITEM1_BBA:           /* dispose of the mask region */
    moveal %fp@(-8),%a0
    _DisposHandle

PICITEM1_BC0:           /* dispose of the data buffer */
    tstl %fp@(-12)
    jbeq PICITEM1_BD2
    moveal %fp@(-12),%a0
    jsr @(0x1a78,%za0)@(0)	| 40832B2A
    jbra PICITEM1_BE8
PICITEM1_BD2:           /* dispose */
    moveal %fp@(-4),%a0
    _DisposHandle
    jbra PICITEM1_BE8
PICITEM1_BDA:           /* out of memory: QDErr = noMemForPictPlaybackErr (-145) */
    moveal %fp@(-366),%sp
    clrb %fp@(12)
    movew #-145,QDErr
PICITEM1_BE8:           /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #4
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40832B52
