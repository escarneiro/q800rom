/*
 quickdraw/gworld.s - offscreen graphics worlds
 From GETGWORLDDEVICE (0x40840060). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* GETGWORLDDEVICE: _GetGWorldDevice. */
GETGWORLDDEVICE:
    moveal %sp@(4),%a0
    movew %a0@(6),%d0
    andiw #-16383,%d0
    cmpiw #-16383,%d0
    beqs GETGWORLDDEVICE_1A
    movel TheGDevice,%sp@(8)
    bras GETGWORLDDEVICE_26
GETGWORLDDEVICE_1A:     /* a GWorld: its device (grafVars +26) */
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveal %a0@(8,%za0)@(0),%a0	| 4084007A
    movel %a0@(26),%sp@(8)
GETGWORLDDEVICE_26:     /* return */
    rtd #4
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 4084008E

/* UPDATEGWORLD: _UpdateGWorld. */
UPDATEGWORLD:
    linkw %fp,#-102
    moveml %d5-%d7/%a2-%a4,%sp@-
    movel %sp,%fp@(-64)
    clrl %fp@(30)
    clrl %fp@(-24)
    movel %fp@(8),%d0
    andil #-1879048193,%d0
    tstl %d0
    bnew UPDATEGWORLD_676_378+0xc	| 408400B0
    movel %fp@(8),%d0
    andil #805306368,%d0
    cmpil #805306368,%d0
    beqw UPDATEGWORLD_676_378+0xc	| 408400C4
    movel %fp@(8),%d0
    btst #30,%d0
    beqw UPDATEGWORLD_4E
    andil #805306368,%d0
    beqw UPDATEGWORLD_676_378+0xc	| 408400DA
UPDATEGWORLD_4E:        /* save the current port and device (GetGWorld, QDExtensions selector 5) */
    moveal %fp@(0x1a,%za0)@(0),%a3	| 408400DE
    pea %fp@(-36)
    pea %fp@(-40)
    moveq #5,%d0
    jsr @(0x1a74,%za0)@(0)	| 408400EE
    movel %fp@(12),%d0
    beqs UPDATEGWORLD_80
    moveal %d0,%a0
    moveal %a0@,%a0
    moveal %a0@(0x16,%za0)@(0x0),%a0	| 408400FE
    movew %a0@(32),%fp@(24)
    movel %a0@(42),%fp@(16)
UPDATEGWORLD_80:        /* the new depth: 0 keeps the old one, else 1..32 */
    moveal %fp@(20),%a0
    movew %fp@(24),%d7
    bltw UPDATEGWORLD_676_34C+0x8	| 40840118
    beqs UPDATEGWORLD_98
    cmpiw #32,%d7
    bgtw UPDATEGWORLD_676_34C+0x8	| 40840122
    bras UPDATEGWORLD_EE
UPDATEGWORLD_98:        /* depth 0: the deepest device under the rectangle (GetMaxDevice) */
    clrl %fp@(-48)
    movew %a0@(4),%d0
    subw %a0@,%d0
    movew %d0,%fp@(-44)
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    movew %d0,%fp@(-42)
    clrl %sp@-
    movel %fp@(20),%sp@-
    jsr @(0x169c,%za0)@(0)	| 40840148
    moveal %sp@+,%a0
    movel %a0,%fp@(-68)
    moveal %a0@,%a1
    moveal %a1@(0x16,%za0)@(0x0),%a0	| 40840156
    movew %a0@(32),%fp@(-50)
    moveal %a0@(0x2a,%za0)@(0),%a0	| 40840162
    movel %a0@,%fp@(-54)
    moveal %fp@(20),%a0
    movew %a0@(2),%d0
    subw %a1@(36),%d0
    movew %d0,%fp@(-56)
    bras UPDATEGWORLD_132
UPDATEGWORLD_EE:        /* the new rectangle and depth; the color table given, or a default for the depth */
    movel %a0@,%fp@(-48)
    movel %a0@(4),%fp@(-44)
    clrw %fp@(-56)
    movew %fp@(24),%fp@(-50)
    movel %fp@(16),%d0
    beqs UPDATEGWORLD_112
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@,%fp@(-54)
    bras UPDATEGWORLD_132
UPDATEGWORLD_112:       /* no table: 16-bit */
    movew %fp@(24),%d0
    cmpiw #16,%d0
    bnes UPDATEGWORLD_122
    movew #15,%d0
    bras UPDATEGWORLD_12C
UPDATEGWORLD_122:       /* 32-bit */
    cmpiw #32,%d0
    bnes UPDATEGWORLD_12C
    movew #24,%d0
UPDATEGWORLD_12C:       /* the direct pixel format */
    extl %d0
    movel %d0,%fp@(-54)
UPDATEGWORLD_132:       /* the pixel shift for the depth (SHIFTTABLE); alignment */
    movew %fp@(-50),%d7
    lea %pc@(SHIFTTABLE),%a0
    moveq #0,%d0
    moveb %a0@(0x0,%d7:w),%d7
    bmiw UPDATEGWORLD_676_34C+0x8	| 408401D0
    movew %fp@(-56),%d0
    lslw %d7,%d0
    andiw #31,%d0
    lsrw %d7,%d0
    movew %d0,%fp@(-56)
    moveal %a3@(2,%za0)@(0),%a0	| 408401E4
    movew %a0@(4),%d0
    andiw #32767,%d0
    movew %d0,%fp@(-58)
    clrb %fp@(-30)
    movel %a3@(16),%d0
    cmpl %fp@(-48),%d0
    bnes UPDATEGWORLD_188
    movel %a3@(20),%d0
    cmpl %fp@(-44),%d0
    bnes UPDATEGWORLD_188
    moveb #1,%fp@(-30)
    braw UPDATEGWORLD_200
UPDATEGWORLD_188:       /* same size as before? */
    movew %a3@(22),%d0
    subw %a3@(18),%d0
    movew %fp@(-42),%d1
    subw %fp@(-46),%d1
    cmpw %d0,%d1
    bnes UPDATEGWORLD_1B0
    movew %a3@(20),%d0
    subw %a3@(16),%d0
    movew %fp@(-44),%d1
    subw %fp@(-48),%d1
    cmpw %d0,%d1
    beqs UPDATEGWORLD_200
UPDATEGWORLD_1B0:       /* the new row bytes */
    movew %fp@(-42),%d0
    subw %fp@(-46),%d0
    extl %d0
    lsll %d7,%d0
    addil #30,%d0
    lsrl #5,%d0
    addqw #1,%d0
    lsll #2,%d0
    movew %d0,%fp@(-58)
    moveal %a3@(2,%za0)@(0),%a0	| 4084025C
    movew %a0@(4),%d1
    andiw #32767,%d1
    movew %d1,%fp@(-60)
    cmpw %d1,%d0
    beqs UPDATEGWORLD_1EA
    oril #524288,%fp@(30)
UPDATEGWORLD_1EA:       /* the result flags: reallocate (or clip/stretch per the flags) */
    movel %fp@(8),%d0
    andil #268435456,%d0
    bnes UPDATEGWORLD_1FC
    movel #536870912,%d0
UPDATEGWORLD_1FC:       /* store them */
    movel %d0,%fp@(30)
UPDATEGWORLD_200:       /* anything changed? a new GWorld for the new settings */
    moveal %a3@(2,%za0)@(0),%a0	| 40840290
    movew %a0@(8),%d0
    movew %fp@(-56),%d1
    negw %d1
    cmpw %d1,%d0
    .short  0x6708	| beqs 408402ac <UPDATEGWORLD_21A+0x2>
    .short  0x00AE, 0x0004, 0x0000	| 408402A4

UPDATEGWORLD_21A:       /* (UpdateGWorld: the first words here are left raw; they straddle an instruction boundary) */
    .short  0x001E, 0x426E	| orib #110,%fp@+
    .short  0xFFE0	| 408402AE
    .short  0x2073, 0x8161, 0x0002	| moveal %a3@(2)@(0),%a0
    movew %a0@(32),%d0
    cmpw %fp@(-50),%d0
    beqs UPDATEGWORLD_21A_38
    oril #131072,%fp@(30)
    movel %fp@(8),%d0
    andil #1073741824,%d0
    beqs UPDATEGWORLD_21A_38
    movew #64,%fp@(-32)
    oril #1073741824,%fp@(30)
UPDATEGWORLD_21A_38:    /* the color table changed (seed)? flag it */
    moveal %a0@(0x2a,%za0)@(0),%a0	| 408402E2
    movel %a0@,%d0
    cmpl %fp@(-54),%d0
    beqs UPDATEGWORLD_21A_4E
    oril #65536,%fp@(30)
UPDATEGWORLD_21A_4E:    /* the pixel state (GetPixelsState); unlock while working (selectors 13, 12) */
    clrl %sp@-
    movel %a3@(2),%sp@-
    moveq #13,%d0
    jsr @(0x1a74,%za0)@(0)	| 40840300
    movel %sp@+,%d0
    movel %d0,%fp@(-28)
    movel %a3@(2),%sp@-
    moveq #12,%d0
    jsr @(0x1a74,%za0)@(0)	| 40840312
    clrb %fp@(-29)
    clrl %sp@-
    movel %a3@(2),%sp@-
    moveq #15,%d0
    jsr @(0x1a74,%za0)@(0)	| 40840324
    movel %sp@+,%d0
    bnes UPDATEGWORLD_21A_A4
    oril #1,%fp@(-24)
    oril #1048576,%fp@(30)
    moveb #1,%fp@(-29)
    movel #64,%fp@(-28)
    bras UPDATEGWORLD_21A_B6
UPDATEGWORLD_21A_A4:    /* purgeable? note it */
    movel %fp@(-28),%d0
    btst #6,%d0
    beqs UPDATEGWORLD_21A_B6
    oril #1,%fp@(-24)
UPDATEGWORLD_21A_B6:    /* its own device? note it */
    moveal %a3@(8,%za0)@(0),%a0	| 40840360
    moveb %a0@(30),%d0
    bnes UPDATEGWORLD_21A_CA
    oril #2,%fp@(-24)
UPDATEGWORLD_21A_CA:    /* keep-local flag */
    tstb %a0@(31)
    beqs UPDATEGWORLD_21A_D8
    oril #4,%fp@(-24)
UPDATEGWORLD_21A_D8:    /* what changed: nothing, only purged (realloc), only the rectangle offset, or a depth/table change (clip/stretch/update per the flags) */
    movel %fp@(30),%d0
    beqs UPDATEGWORLD_21A_110
    cmpil #1048576,%d0
    beqs UPDATEGWORLD_21A_118
    tstl %fp@(8)
    beqw UPDATEGWORLD_21A_40A
    cmpil #65536,%d0
    bnes UPDATEGWORLD_21A_104
    tstb %fp@(-30)
    beqs UPDATEGWORLD_21A_104
    cmpiw #4,%d7
    bltw UPDATEGWORLD_21A_202
UPDATEGWORLD_21A_104:   /* depth change: rebuild */
    cmpil #262144,%d0
    beqs UPDATEGWORLD_21A_13C
    braw UPDATEGWORLD_21A_40A
UPDATEGWORLD_21A_110:   /* nothing to do */
    movel %a3,%fp@(-4)
    braw UPDATEGWORLD_676_2D0_A
UPDATEGWORLD_21A_118:   /* purged: reallocate the pixels */
    movew %fp@(-44),%d0
    subw %fp@(-48),%d0
    muluw %fp@(-58),%d0
    moveal %a3@(2,%za0)@(0),%a1	| 408403CE
    moveal %a1@,%a0
    _ReallocHandle
    bnew UPDATEGWORLD_676_34C
    _MoveHHi
    movel %a3,%fp@(-4)
    braw UPDATEGWORLD_676_2D0_A
UPDATEGWORLD_21A_13C:   /* offset only: shift the pixels in place */
    clrl %sp@-
    movel %a3@(2),%sp@-
    moveq #15,%d0
    jsr @(0x1a74,%za0)@(0)	| 408403EE
    moveal %sp@+,%a1
    movew %fp@(-44),%d0
    subw %fp@(-48),%d0
    movew %fp@(-58),%d1
    muluw %d1,%d0
    moveal %a1,%a4
    addal %d0,%a4
    moveal %a3@(2,%za0)@(0),%a0	| 40840408
    movew %a0@(8),%d6
    negw %d6
    subw %fp@(-56),%d6
    extl %d6
    lsll %d7,%d6
    blts UPDATEGWORLD_21A_180
UPDATEGWORLD_21A_174:   /* left: shift each long */
    bfextu %a1@,%d6,0,%d0
    movel %d0,%a1@+
    cmpal %a4,%a1
    blts UPDATEGWORLD_21A_174
    bras UPDATEGWORLD_21A_190
UPDATEGWORLD_21A_180:   /* right */
    subil #32,%d6
UPDATEGWORLD_21A_186:   /* shift each long from the end */
    bfextu %a4@,%d6,0,%d0
    movel %d0,%a4@-
    cmpal %a4,%a1
    blts UPDATEGWORLD_21A_186
UPDATEGWORLD_21A_190:   /* the new bounds and portRect */
    moveal %a3@(2,%za0)@(0),%a0	| 4084043A
    movew %fp@(-48),%a0@(6)
    movew %fp@(-46),%d0
    subw %fp@(-56),%d0
    movew %d0,%a0@(8)
    movel %fp@(-44),%a0@(10)
    movel %fp@(-48),%a3@(16)
    movel %fp@(-44),%a3@(20)
    movel %a3@(24),%sp@-
    pea %a3@(16)
    jsr @(0x117c,%za0)@(0)	| 4084046C
    movel %a3,%fp@(-4)
    moveal %a3@(8,%za0)@(0),%a1	| 40840476
    moveb %a1@(30),%d0
    beqw UPDATEGWORLD_676_2D0_A
    moveal %a1@(0x1a,%za0)@(0),%a1	| 40840484
    movel %a0@(6),%a1@(34)
    movel %a0@(10),%a1@(38)
    moveal %a1@(0x16,%za0)@(0x0),%a1	| 40840496
    movel %a0@(6),%a1@(6)
    movel %a0@(10),%a1@(10)
    braw UPDATEGWORLD_676_2D0_A
UPDATEGWORLD_21A_202:   /* color table only: set the GWorld current, update its colors (PaletteDispatch) */
    movel TheGDevice,%fp@(-40)
    movel %a3,%fp@(-4)
    moveal %a3@(8,%za0)@(0),%a4	| 408404B6
    movel %a3,%sp@-
    clrl %sp@-
    moveq #6,%d0
    jsr @(0x1a74,%za0)@(0)	| 408404C2
    pea %fp@(-90)
    moveq #13,%d0
    _PaletteDispatch
    pea %fp@(-98)
    moveq #14,%d0
    _PaletteDispatch
    movel %fp@(-24),%d0
    andil #2,%d0
    beqs UPDATEGWORLD_21A_290
    movel %fp@(12),TheGDevice
    movel %a3@(2,%za0)@(0),%sp@-	| 408404EA
    movew #32,%sp@-
    jsr @(0x1a38,%za0)@(0)	| 408404F4
    moveal %a4@(26),%a0
    moveal %fp@(-40),%a1
    cmpal %a0,%a1
    bnes UPDATEGWORLD_21A_262
    movel %fp@(12),%fp@(-40)
UPDATEGWORLD_21A_262:   /* the device's table into the pixmap; restore TheGDevice */
    movel %a0,%sp@-
    jsr @(0x16c0,%za0)@(0)	| 4084050E
    moveal %fp@(12),%a0
    movel %a0,%a4@(26)
    moveal %a0@,%a0
    moveal %a0@(0x16,%za0)@(0x0),%a0	| 4084051E
    moveal %a3@(2,%za0)@(0),%a1
    movel %a0@(42),%a1@(42)
    movel %fp@(-40),TheGDevice
    braw UPDATEGWORLD_21A_38E
UPDATEGWORLD_21A_290:   /* a new color table: the given one or the default for the depth */
    moveal %a4@(0x1a,%za0)@(0),%a0	| 4084053A
    movew %a0@(10),%fp@(-78)
    moveal %fp@(16),%a0
    clrl %fp@(-76)
    tstw %fp@(24)
    beqs UPDATEGWORLD_21A_2C6
    cmpaw #0,%a0
    bnes UPDATEGWORLD_21A_2DC
    clrl %sp@-
    movew %fp@(24),%sp@-
    jsr @(0x1660,%za0)@(0x0)	| 40840560
    moveal %sp@+,%a0
    tstl %a0
    beqw UPDATEGWORLD_676_34C_12
    bras UPDATEGWORLD_21A_2E6
UPDATEGWORLD_21A_2C6:   /* the device's */
    moveal %fp@(0xffffffffffffffbc,%za0)@(0),%a0	| 40840570
    movel %a0@(6),%fp@(-76)
    moveal %a0@(0x16,%za0)@(0x0),%a0	| 4084057C
    moveal %a0@(42),%a0
UPDATEGWORLD_21A_2DC:   /* copy it */
    jsr @(0x1584,%za0)@(0x0)	| 40840586
    bnew UPDATEGWORLD_676_34C
UPDATEGWORLD_21A_2E6:   /* an inverse table: a device with the same table, or a new one */
    movel %a0,%fp@(-72)
    moveal %fp@(-76),%a0
    tstl %a0
    bnes UPDATEGWORLD_21A_328
    clrl %sp@-
    movel %fp@(-72),%sp@-
    jsr %pc@(FINDINVERSETABLE)
    moveal %sp@+,%a0
    tstl %a0
    bnes UPDATEGWORLD_21A_328
    moveq #2,%d0
    .short  0xA322	| 408405AE _NewHandle (flags 0x0300)
    bnew UPDATEGWORLD_676_34C
    movel %a0,%fp@(-76)
    movel %fp@(-72),%sp@-
    movel %a0,%sp@-
    movew %fp@(-78),%sp@-
    jsr @(0x16e4,%za0)@(0)	| 408405C2
    movew QDErr,%d0
    bnew UPDATEGWORLD_676_378_16
    bras UPDATEGWORLD_21A_336
UPDATEGWORLD_21A_328:   /* copy it */
    jsr @(0x1584,%za0)@(0x0)	| 408405D2
    bnew UPDATEGWORLD_676_34C
    movel %a0,%fp@(-76)
UPDATEGWORLD_21A_336:   /* install the new tables in the device and pixmap */
    moveal %a3@(8,%za0)@(0),%a4	| 408405E0
    moveal %a4@(0x1a,%za0)@(0),%a0
    moveal %a0@(6),%a0
    _DisposHandle
    moveal %a4@(0x1a,%za0)@(0),%a0	| 408405F2
    movel %fp@(-76),%a0@(6)
    moveal %a0@(0x16,%za0)@(0x0),%a0	| 408405FE
    movel %fp@(-72),%a0@(42)
    movel %a4@(26),TheGDevice
    movel %a3@(2,%za0)@(0),%sp@-	| 40840610
    movew #32,%sp@-
    jsr @(0x1a38,%za0)@(0)	| 4084061A
    movel %fp@(-40),TheGDevice
    moveal %a3@(2,%za0)@(0),%a4	| 40840626
    moveal %a4@(42),%a0
    _DisposHandle
    movel %fp@(-72),%a4@(42)
UPDATEGWORLD_21A_38E:   /* remap the pixels to the new table: the translation table */
    moveq #1,%d0
    movew %fp@(-50),%d7
    lslw %d7,%d0
    moveq #0,%d1
    movew %d0,%d1
    lslw #2,%d1
    subqw #1,%d0
    moveal %sp,%a0
    addal %d1,%a0
UPDATEGWORLD_21A_3A2:   /* identity? nothing to remap */
    cmpl %a0@-,%d0
    dbne %d0,UPDATEGWORLD_21A_3A2
    beqw UPDATEGWORLD_676_2D0_A
    clrl %sp@-
    movel %a3@(2),%sp@-
    moveq #15,%d0
    jsr @(0x1a74,%za0)@(0)	| 4084065E
    moveal %sp@+,%a1
    moveal %a3@(2,%za0)@(0),%a0	| 40840666
    movew %a0@(4),%d1
    andiw #32767,%d1
    movew %a0@(10),%d0
    subw %a0@(6),%d0
    muluw %d1,%d0
    moveal %a1,%a4
    addal %d0,%a4
    moveq #0,%d6
    moveq #31,%d1
UPDATEGWORLD_21A_3DC:   /* each long */
    movel %a1@,%d5
UPDATEGWORLD_21A_3DE:   /* each pixel through the table */
    bfextu %d5,%d6,%d7,%d0
    movel %sp@(0x0,%d0:w:4),%d0
    bfins %d0,%d5,%d6,%d7
    addw %d7,%d6
    andw %d1,%d6
    bnes UPDATEGWORLD_21A_3DE
    movel %d5,%a1@+
    cmpal %a4,%a1
    blts UPDATEGWORLD_21A_3DC
    pea %fp@(-90)
    moveq #15,%d0
    _PaletteDispatch
    pea %fp@(-98)
    moveq #16,%d0
    _PaletteDispatch
    braw UPDATEGWORLD_676_2D0_A
UPDATEGWORLD_21A_40A:   /* a rebuild: flags for the new GWorld */
    movel %fp@(8),%d0
    bnes UPDATEGWORLD_21A_418
    andil #1048576,%fp@(30)
UPDATEGWORLD_21A_418:   /* keep the table? */
    movel %fp@(-24),%d0
    andil #2,%d0
    bnes UPDATEGWORLD_21A_428
    clrl %fp@(12)
UPDATEGWORLD_21A_428:   /* the old pixels needed for copying? lock them */
    clrl %fp@(-82)
    tstb %fp@(-29)
    bnes UPDATEGWORLD_21A_438
    movel %fp@(8),%d0
    bnes UPDATEGWORLD_21A_458
UPDATEGWORLD_21A_438:   /* unlock and detach the old pixels */
    moveal %a3@(2),%a4
    movel %a4,%sp@-
    moveq #2,%d0
    jsr @(0x1a74,%za0)@(0)	| 408406EA
    moveal %a4@,%a1
    moveal %a1@,%a4
    clrl %a1@
    moveal %a4,%a0
    _GetHandleSize
    movel %d0,%fp@(-82)
    moveal %a4,%a0
    _DisposHandle
UPDATEGWORLD_21A_458:   /* NewGWorld with the new settings */
    clrw %sp@-
    .byte   0x48, 0x6E	| 40840704
UPDATEGWORLD_676:       /* (starts with the last word of an instruction) NewGWorld with the settings; then the port's state and clip copied over */
    .byte   0xFF, 0xFC	| 40840706
    movew %fp@(24),%sp@-
    movel %fp@(20),%sp@-
    movel %fp@(16),%sp@-
    movel %fp@(12),%sp@-
    movel %fp@(-24),%sp@-
    moveq #0,%d0
    jsr @(0x1a74,%za0)@(0)	| 4084071E
    movew %sp@+,%d0
    bnew UPDATEGWORLD_676_3A4
    moveal %fp@(-4),%a4
    movew %a3@(12),%a4@(12)
    movew %a3@(14),%a4@(14)
    movel %a3@(28),%sp@-
    movel %a4@(28),%sp@-
    jsr @(0x1170,%za0)@(0x0)	| 40840742
    movel %fp@(8),%d0
    andil #268435456,%d0
    bnew UPDATEGWORLD_676_66
    movel %a4@(28),%sp@-
    pea %a3@(16)
    pea %a4@(16)
    jsr @(0x11ec,%za0)@(0)	| 40840762
    braw UPDATEGWORLD_676_84
UPDATEGWORLD_676_66:    /* move the old port state over: the origin */
    movel %a4@(28),%sp@-
    movew %a4@(18),%d0
    subw %a3@(18),%d0
    movew %d0,%sp@-
    movew %a4@(16),%d0
    subw %a3@(16),%d0
    movew %d0,%sp@-
    jsr @(0x1180,%za0)@(0x0)	| 40840784
UPDATEGWORLD_676_84:    /* the clip region */
    movel %a3@(32),%d0
    beqw UPDATEGWORLD_676_98
    movel %d0,%sp@-
    movel %a4@(32),%sp@-
    jsr @(0x1624,%za0)@(0x0)	| 40840798
UPDATEGWORLD_676_98:    /* pen and text state, the pixpats (CopyPixPat) */
    movel %a3@(36),%a4@(36)
    movel %a3@(40),%a4@(40)
    movel %a3@(44),%a4@(44)
    movel %a3@(48),%a4@(48)
    movel %a3@(52),%a4@(52)
    movew %a3@(56),%a4@(56)
    movel %a3@(58),%d0
    beqw UPDATEGWORLD_676_D0
    movel %d0,%sp@-
    movel %a4@(58),%sp@-
    jsr @(0x1624,%za0)@(0x0)	| 408407D0
UPDATEGWORLD_676_D0:    /* fill pixpat */
    movel %a3@(62),%d0
    beqw UPDATEGWORLD_676_E4
    movel %d0,%sp@-
    movel %a4@(62),%sp@-
    jsr @(0x1624,%za0)@(0x0)	| 408407E4
UPDATEGWORLD_676_E4:    /* the rest of the port fields */
    lea %a3@(66),%a0
    lea %a4@(66),%a1
    moveq #20,%d0
UPDATEGWORLD_676_EE:    /* copy; then the pixmap fields and grafVars */
    movew %a0@+,%a1@+
    dbf %d0,UPDATEGWORLD_676_EE
    moveal %a3@(2,%za0)@(0),%a0	| 408407FA
    moveal %a4@(2,%za0)@(0),%a1
    movew %a0@(16),%a1@(16)
    movel %a0@(18),%a1@(18)
    movel %a0@(22),%a1@(22)
    movel %a0@(26),%a1@(26)
    moveal %a3@(8,%za0)@(0),%a0	| 4084081E
    moveal %a4@(8,%za0)@(0),%a1
    moveq #12,%d0
UPDATEGWORLD_676_126:   /* copy; the device's fields */
    movew %a0@+,%a1@+
    dbf %d0,UPDATEGWORLD_676_126
    movel %a3@(104),%a4@(104)
    moveal %a3@(8,%za0)@(0),%a0	| 40840838
    moveal %a0@(0x1a,%za0)@(0),%a0
    moveal %a4@(8,%za0)@(0),%a1
    moveal %a1@(0x1a,%za0)@(0),%a1
    movel %a0@(12),%a1@(12)
    movel %a0@(16),%a1@(16)
    movel %a0@(26),%a1@(26)
    moveal %a0@(0x16,%za0)@(0x0),%a0	| 40840862
    moveal %a1@(0x16,%za0)@(0x0),%a1
    movew %a0@(16),%a1@(16)
    movel %a0@(18),%a1@(18)
    movel %a0@(22),%a1@(22)
    movel %a0@(26),%a1@(26)
    movel %a3,%sp@-
    clrl %sp@-
    moveq #6,%d0
    jsr @(0x1a74,%za0)@(0)	| 4084088C
    pea %fp@(-90)
    moveq #13,%d0
    _PaletteDispatch
    pea %fp@(-98)
    moveq #14,%d0
    _PaletteDispatch
    movel %a4,%sp@-
    clrl %sp@-
    moveq #6,%d0
    jsr @(0x1a74,%za0)@(0)	| 408408A8
    pea %fp@(-90)
    moveq #15,%d0
    _PaletteDispatch
    pea %fp@(-98)
    moveq #16,%d0
    _PaletteDispatch
    tstb %fp@(-29)
    bnew UPDATEGWORLD_676_2D0
    movel %fp@(8),%d0
    beqw UPDATEGWORLD_676_2D0
    clrb %sp@-
    movel %a3@(2),%sp@-
    moveq #1,%d0
    jsr @(0x1a74,%za0)@(0)	| 408408D6
    moveb %sp@+,%d0
    clrb %sp@-
    moveal %fp@(-4),%a0
    movel %a0@(2),%sp@-
    moveq #1,%d0
    jsr @(0x1a74,%za0)@(0)	| 408408EA
    moveb %sp@+,%d0
    beqw UPDATEGWORLD_676_378
    movel %fp@(-4),%sp@-
    clrl %sp@-
    moveq #6,%d0
    jsr @(0x1a74,%za0)@(0)	| 408408FE
    clrl %sp@-
    jsr @(0x1160,%za0)@(0x0)	| 40840906
    movel %sp@,%fp@(-102)
    jsr @(0xfe8,%za0)@(0)	| 40840910
    moveal %fp@(-4),%a0
    pea %a0@(16)
    jsr @(0xfec,%za0)@(0)	| 4084091E
    movel %a3@(2,%za0)@(0),%sp@-
    moveal %fp@(-4),%a1
    movel %a1@(2,%za0)@(0),%sp@-	| 4084092E
    lea %a3@(16),%a0
    lea %a1@(16),%a1
    movel %fp@(8),%d0
    btst #29,%d0
    bnes UPDATEGWORLD_676_29C
    movel %a0@,%fp@(-12)
    movel %a1@,%fp@(-20)
    movew %a0@(4),%d0
    subw %a0@,%d0
    movew %a1@(4),%d1
    subw %a1@,%d1
    cmpw %d0,%d1
    blts UPDATEGWORLD_676_25A
    movew %d0,%d1
UPDATEGWORLD_676_25A:   /* the old and new rectangles aligned to the old offset */
    movew %a0@,%d0
    addw %d1,%d0
    movew %d0,%fp@(-8)
    movew %a1@,%d0
    addw %d1,%d0
    movew %d0,%fp@(-16)
    movew %a0@(6),%d0
    subw %a0@(2),%d0
    movew %a1@(6),%d1
    subw %a1@(2),%d1
    cmpw %d0,%d1
    blts UPDATEGWORLD_676_280
    movew %d0,%d1
UPDATEGWORLD_676_280:   /* their tops */
    movew %a0@(2),%d0
    addw %d1,%d0
    movew %d0,%fp@(-6)
    movew %a1@(2),%d0
    addw %d1,%d0
    movew %d0,%fp@(-14)
    lea %fp@(-12),%a0
    lea %fp@(-20),%a1
UPDATEGWORLD_676_29C:   /* copy the old pixels into the new GWorld (CopyBits), then dispose of the old (DisposeGWorld) */
    movel %a0,%sp@-
    movel %a1,%sp@-
    movew %fp@(-32),%sp@-
    clrl %sp@-
    jsr @(0x11b0,%za0)@(0)	| 408409AC
    movel %fp@(-102),%sp@-
    jsr @(0xfe4,%za0)@(0)	| 408409B6
    movel %fp@(-102),%sp@-
    jsr @(0x1164,%za0)@(0x0)	| 408409C0
    moveal %fp@(-4),%a0
    movel %a0@(2),%sp@-
    moveq #2,%d0
    jsr @(0x1a74,%za0)@(0)	| 408409D0
UPDATEGWORLD_676_2D0:   /* dispose of the old GWorld */
    movel %a3,%sp@-
    moveq #4,%d0
    jsr @(0x1a74,%za0)@(0)	| 408409DA
UPDATEGWORLD_676_2D0_A: /* the GWorld to return */
    moveal %fp@(-4),%a3
UPDATEGWORLD_676_2DE:   /* restore the pixel state (SetPixelsState); a saved port that was the old GWorld becomes the new one */
    movel %a3@(2),%sp@-
    movel %fp@(-28),%sp@-
    moveq #14,%d0
    jsr @(0x1a74,%za0)@(0)	| 408409EE
    moveal %fp@(26),%a0
    moveal %a0@,%a0
    cmpal %fp@(-36),%a0
    bnes UPDATEGWORLD_676_2FE
    movel %a3,%fp@(-36)
UPDATEGWORLD_676_2FE:   /* the saved device likewise */
    moveal %a0@(8,%za0)@(0),%a0	| 40840A04
    moveal %a0@(26),%a0
    cmpal %fp@(-40),%a0
    bnes UPDATEGWORLD_676_31A
    moveal %a3@(8,%za0)@(0),%a0	| 40840A14
    movel %a0@(26),%fp@(-40)
UPDATEGWORLD_676_31A:   /* SetGWorld back; return the new GWorld */
    movel %fp@(-36),%sp@-
    movel %fp@(-40),%sp@-
    moveq #6,%d0
    jsr @(0x1a74,%za0)@(0)	| 40840A2A
    moveal %fp@(26),%a0
    movel %a3,%a0@
UPDATEGWORLD_676_330:   /* QDErr from the result */
    clrw QDErr
    movel %fp@(30),%d0
    bpls UPDATEGWORLD_676_33E
    movew %d0,QDErr
UPDATEGWORLD_676_33E:   /* return */
    moveal %fp@(-64),%sp
    moveml %sp@+,%d5-%d7/%a2-%a4
    unlk %fp
    rtd #22
UPDATEGWORLD_676_34C:   /* error exits: the error into the result (-157 depth, -152 memory, -50 param) */
    extl %d0
    movel %d0,%fp@(30)
    bras UPDATEGWORLD_676_2DE
    movel #-157,%fp@(30)
    bras UPDATEGWORLD_676_330
UPDATEGWORLD_676_34C_12:/* an error from QDErr or MemErr */
    movew QDErr,%d0
    bnes UPDATEGWORLD_676_34C
    movew MemErr,%d0
    bnes UPDATEGWORLD_676_34C
    clrw %sp@-
    jsr @(0x14bc,%za0)@(0)	| 40840A72
    movew %sp@+,%d0
    braw UPDATEGWORLD_676_2DE
UPDATEGWORLD_676_378:   /* memory error */
    movel #-152,%fp@(30)
    braw UPDATEGWORLD_676_2DE
    movel #-50,%fp@(30)
    bras UPDATEGWORLD_676_330
UPDATEGWORLD_676_378_16:/* dispose of the new tables */
    extl %d0
    movel %d0,%fp@(30)
    moveal %fp@(-72),%a0
    _DisposHandle
    moveal %fp@(-76),%a0
    _DisposHandle
    braw UPDATEGWORLD_676_2DE
UPDATEGWORLD_676_3A4:   /* purgeable pixels lost? reallocate them (temp memory or the heap) */
    movel %fp@(-82),%d1
    beqs UPDATEGWORLD_676_34C
    movew %d0,%d7
    movel %d1,%d0
    moveal %a3@(8,%za0)@(0),%a0	| 40840AB4
    tstb %a0@(31)
    beqs UPDATEGWORLD_676_3C8
    jsr @(0x1ab4,%za0)@(0)	| 40840AC0
    tstl %d0
    bnes UPDATEGWORLD_676_3CC
    movew %d7,%d0
    bras UPDATEGWORLD_676_34C
UPDATEGWORLD_676_3C8:   /* ReallocHandle */
    .short  0xA122	| 40840ACE _NewHandle (flags 0x0100)
    bnes UPDATEGWORLD_676_34C
UPDATEGWORLD_676_3CC:   /* the new pixels into the pixmap */
    moveal %a3@(2,%za0)@(0),%a1	| 40840AD2
    movel %a0,%a1@
    movew %d7,%d0
    braw UPDATEGWORLD_676_34C

/* QDDONE: QDDone(port): drawing is synchronous here, always true */
QDDONE:                 /* drawing is synchronous: always true */
    moveb #1,%sp@(8)
    rtd #4
    .short  0x0000, 0x0000, 0x0000	| 40840AEA

/* LOCKPIXELS: _LockPixels. */
LOCKPIXELS:             /* result true; a purgeable pixel handle (state 2): dereference it (StripAddress); purged: false */
    moveb #1,%sp@(8)
    moveal %sp@(4,%za0)@(0),%a1	| 40840AF6
    movew %a1@(14),%d0
    cmpiw #2,%d0
    jbne LOCKPIXELS_34
    moveal %a1@,%a0
    movel %a0@,%d0
    jsr @(0x644,%za0)@(0x0)	| 40840B0A
    tstl %d0
    jbne LOCKPIXELS_2A
    clrb %sp@(8)
    jbra LOCKPIXELS_34
LOCKPIXELS_2A:          /* store the pointer, state 1 (locked), lock the handle */
    movel %d0,%a1@
    movew #1,%a1@(14)
    _HLock
LOCKPIXELS_34:          /* return */
    rtd #4
    .long   0x00000000, 0x00000000	| 40840B28

/* UNLOCKPIXELS: _UnlockPixels. */
UNLOCKPIXELS:           /* locked (state 1)? back to the handle (RecoverHandle), unlock it, state 2 */
    moveal %sp@(4,%za0)@(0),%a1	| 40840B30
    movew %a1@(14),%d0
    cmpiw #1,%d0
    jbne UNLOCKPIXELS_24
    moveal %a1@,%a0
    .short  0xA128	| 40840B42 _RecoverHandle (flags 0x0100)
    _HUnlock
    moveal %sp@(4,%za0)@(0),%a1	| 40840B46
    movel %a0,%a1@
    movew #2,%a1@(14)
UNLOCKPIXELS_24:        /* return */
    rtd #4
    .long   0x00000000, 0x00000000	| 40840B58

/* PORTCHANGED: _PortChanged. */
PORTCHANGED:
    rtd #4
    .long   0x00000000, 0x00000000, 0x00000000	| 40840B64

/* PIXPATCHANGED: _PixPatChanged. */
PIXPATCHANGED:
    moveal %sp@(4),%a0
    moveal %a0@,%a0
    movew #-1,%a0@(14)
    rtd #4

/* CTABCHANGED: _CTabChanged. */
CTABCHANGED:
    clrl %sp@-
    jsr @(0x16a0,%za0)@(0)	| 40840B82
    movel %sp@+,%d0
    moveal %sp@(4,%za0)@(0),%a0	| 40840B8A
    movel %d0,%a0@
    rtd #4
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40840B96

/* GDEVICECHANGED: _GDeviceChanged. */
GDEVICECHANGED:
    rtd #4
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40840BA4

/* ALLOWPURGEPIXELS: _AllowPurgePixels. */
ALLOWPURGEPIXELS:
    moveal %sp@(4,%za0)@(0),%a1	| 40840BB0
    moveal %a1@,%a0
    movew %a1@(14),%d0
    cmpiw #2,%d0
    beqs ALLOWPURGEPIXELS_1A
    cmpiw #1,%d0
    bnes ALLOWPURGEPIXELS_1C
    .short  0xA128	| 40840BC8 _RecoverHandle (flags 0x0100)
ALLOWPURGEPIXELS_1A:    /* purgeable */
    _HPurge
ALLOWPURGEPIXELS_1C:    /* return */
    rtd #4

/* NOPURGEPIXELS: _NoPurgePixels. */
NOPURGEPIXELS:
    moveal %sp@(4,%za0)@(0),%a1	| 40840BD0
    moveal %a1@,%a0
    movew %a1@(14),%d0
    cmpiw #2,%d0
    beqs NOPURGEPIXELS_1A
    cmpiw #1,%d0
    bnes NOPURGEPIXELS_1C
    .short  0xA128	| 40840BE8 _RecoverHandle (flags 0x0100)
NOPURGEPIXELS_1A:       /* not purgeable */
    _HNoPurge
NOPURGEPIXELS_1C:       /* return */
    rtd #4

/* GETPIXELSSTATE: _GetPixelsState. */
GETPIXELSSTATE:
    clrl %sp@(8)
    moveal %sp@(4,%za0)@(0),%a1	| 40840BF4
    moveal %a1@,%a0
    movew %a1@(14),%d0
    cmpiw #2,%d0
    beqs GETPIXELSSTATE_1E
    cmpiw #1,%d0
    bnes GETPIXELSSTATE_24
    .short  0xA128	| 40840C0C _RecoverHandle (flags 0x0100)
GETPIXELSSTATE_1E:      /* the handle state as the result */
    _HGetState
    movel %d0,%sp@(8)
GETPIXELSSTATE_24:      /* return */
    rtd #4
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40840C18

/* SETPIXELSSTATE: _SetPixelsState. */
SETPIXELSSTATE:
    movel %sp@(4),%d0
    btst #6,%d0
    bnes SETPIXELSSTATE_1A
    movel %sp@(8),%sp@-
    moveq #12,%d0
    jsr @(0x1a74,%za0)@(0)	| 40840C30
    braw SETPIXELSSTATE_26
SETPIXELSSTATE_1A:      /* purgeable or not (AllowPurgePixels / NoPurgePixels, selectors 11 / 12) */
    movel %sp@(8),%sp@-
    moveq #11,%d0
    jsr @(0x1a74,%za0)@(0)	| 40840C40
SETPIXELSSTATE_26:      /* locked bit: LockPixels or UnlockPixels (selectors 1 / 2) */
    movel %sp@(4),%d0
    btst #7,%d0
    bnes SETPIXELSSTATE_3E
    movel %sp@(8),%sp@-
    moveq #2,%d0
    jsr @(0x1a74,%za0)@(0)	| 40840C56
    bras SETPIXELSSTATE_50
SETPIXELSSTATE_3E:      /* lock */
    moveal %sp@(8),%a0
    clrb %sp@-
    movel %a0,%sp@-
    moveq #1,%d0
    jsr @(0x1a74,%za0)@(0)	| 40840C68
    moveb %sp@+,%d0
SETPIXELSSTATE_50:      /* return */
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40840C74

/* GETPIXBASEADDR: _GetPixBaseAddr. */
GETPIXBASEADDR:         /* the pixmap's base address; a handle (state 2): dereferenced, 32-bit clean; no state: check whether it is a screen */
    moveal %sp@(4,%za0)@(0),%a1	| 40840C80
    moveal %a1@,%a0
    movel %a0,%sp@(8)
    movew %a1@(14),%d0
    jbeq GETPIXBASEADDR_28
    btst #1,%d0
    jbeq GETPIXBASEADDR_24
    movel %a0@,%d0
GETPIXBASEADDR_1A:      /* StripAddress */
    jsr @(0x644,%za0)@(0x0)	| 40840C9A
    movel %d0,%sp@(8)
GETPIXBASEADDR_24:      /* return */
    rtd #4
GETPIXBASEADDR_28:      /* a screen's base address is returned as it is */
    movel %a0,%d0
    moveal DeviceList,%a1
GETPIXBASEADDR_2E:      /* next device: is it its pixmap's base? */
    moveal %a1@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    cmpl %a0@,%d0
    jbeq GETPIXBASEADDR_24
    moveal %a1@,%a0
    movel %a0@(30),%d1
    moveal %d1,%a1
    jbne GETPIXBASEADDR_2E
    jbra GETPIXBASEADDR_1A
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40840CC6

/* NEWSCREENBUFFER: _NewScreenBuffer. */
NEWSCREENBUFFER:
    clrb %d0
    jbra NEWTEMPSCREENBUFFER_4

/* NEWTEMPSCREENBUFFER: _NewTempScreenBuffer. */
NEWTEMPSCREENBUFFER:    /* temporary memory (d0 = 1) */
    moveb #1,%d0
NEWTEMPSCREENBUFFER_4:  /* the bounds must not be empty; GetMaxDevice for the rectangle; the pixel size and row bytes */
    linkw %fp,#-42
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveb %d0,%fp@(-42)
    clrw %fp@(22)
    clrl %fp@(-8)
    clrl %fp@(-12)
    clrb %sp@-
    movel %fp@(18),%sp@-
    jsr @(0x10b8,%za0)@(0)	| 40840CF6
    moveb %sp@+,%d0
    jbne NEWTEMPSCREENBUFFER_1B4
    clrl %sp@-
    movel %fp@(18),%sp@-
    jsr @(0x169c,%za0)@(0)	| 40840D08
    moveal %sp@+,%a0
    movel %a0,%fp@(-16)
    moveal %a0@,%a0
    moveal %fp@(18),%a1
    movew %a1@(2),%d0
    subw %a0@(36),%d0
    movew %d0,%fp@(-24)
    movew %a1@(6),%d0
    subw %a1@(2),%d0
    movew %d0,%fp@(-34)
    movew %a1@(4),%d0
    subw %a1@,%d0
    movew %d0,%fp@(-36)
    clrl %fp@(-40)
    moveal %fp@(0xfffffffffffffff0,%za0)@(0),%a0	| 40840D40
    moveal %a0@(0x16,%za0)@(0x0),%a1
    movew %a1@(32),%d7
    lea %pc@(SHIFTTABLE),%a0
    moveq #0,%d0
    moveb %a0@(0x0,%d7:w),%d0
    jbmi NEWTEMPSCREENBUFFER_1AC
    movew %d0,%fp@(-2)
    movew %fp@(-40),%fp@(-32)
    movew %fp@(-24),%d1
    lslw %d0,%d1
    andiw #31,%d1
    lsrw %d0,%d1
    movew %fp@(-38),%d0
    subw %d1,%d0
    movew %d0,%fp@(-30)
    movel %fp@(-36),%fp@(-28)
    movew %fp@(-34),%d0
    subw %fp@(-38),%d0
    extl %d0
    movew %fp@(-2),%d1
    lsll %d1,%d0
    addil #30,%d0
    lsrl #5,%d0
    addqw #1,%d0
    lsll #2,%d0
    movew %d0,%fp@(-4)
    movew %fp@(-36),%d1
    subw %fp@(-40),%d1
    muluw %d1,%d0
    tstb %fp@(-42)
    jbeq NEWTEMPSCREENBUFFER_F2
    jsr @(0x1ab4,%za0)@(0)	| 40840DB4
    tstl %d0
    jbne NEWTEMPSCREENBUFFER_F8
    movew #-151,%d0
    jbra NEWTEMPSCREENBUFFER_1BC
NEWTEMPSCREENBUFFER_F2: /* the pixel buffer */
    .short  0xA122	| 40840DC6 _NewHandle (flags 0x0100)
    jbne NEWTEMPSCREENBUFFER_1BC
NEWTEMPSCREENBUFFER_F8: /* high in the heap; purgeable if asked */
    movel %a0,%fp@(-8)
    _MoveHHi
    tstb %fp@(16)
    jbeq NEWTEMPSCREENBUFFER_106
    _HPurge
NEWTEMPSCREENBUFFER_106:/* the pixmap (50 bytes): base, row bytes, bounds, 72 dpi, pixel type and size from the device */
    moveq #50,%d0
    .short  0xA322	| 40840DDC _NewHandle (flags 0x0300)
    jbne NEWTEMPSCREENBUFFER_1BC
    movel %a0,%fp@(-12)
    moveal %a0@,%a1
    movel %fp@(-8),%a1@
    movew %fp@(-4),%d0
    oriw #-32768,%d0
    movew %d0,%a1@(4)
    movel %fp@(-32),%a1@(6)
    movel %fp@(-28),%a1@(10)
    movew #2,%a1@(14)
    movew #72,%a1@(22)
    movew #72,%a1@(26)
    movew %d7,%a1@(32)
    cmpiw #16,%d7
    jblt NEWTEMPSCREENBUFFER_168
    movew #16,%a1@(30)
    movew #3,%a1@(34)
    moveq #8,%d0
    cmpiw #32,%d7
    jbeq NEWTEMPSCREENBUFFER_162
    moveq #5,%d0
NEWTEMPSCREENBUFFER_162:/* direct: component size */
    movew %d0,%a1@(36)
    jbra NEWTEMPSCREENBUFFER_176
NEWTEMPSCREENBUFFER_168:/* indexed: one component of the pixel size */
    clrw %a1@(30)
    movew #1,%a1@(34)
    movew %d7,%a1@(36)
NEWTEMPSCREENBUFFER_176:/* the device's color table; return the pixmap and the device */
    moveal %fp@(0xfffffffffffffff0,%za0)@(0),%a0	| 40840E4A
    moveal %a0@(0x16,%za0)@(0x0),%a0
    movel %a0@(42),%a1@(42)
    moveal %fp@(8),%a0
    movel %fp@(-12),%a0@
    moveal %fp@(12),%a0
    movel %fp@(-16),%a0@
NEWTEMPSCREENBUFFER_198:/* QDErr = the result; return */
    movew %fp@(22),%d0
    extl %d0
    movew %d0,QDErr
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #14
NEWTEMPSCREENBUFFER_1AC:/* error -157 (cDepthErr) */
    movew #-157,%fp@(22)
    jbra NEWTEMPSCREENBUFFER_1CA
NEWTEMPSCREENBUFFER_1B4:/* empty rectangle: paramErr */
    movew #-50,%fp@(22)
    jbra NEWTEMPSCREENBUFFER_1CA
NEWTEMPSCREENBUFFER_1BC:/* memory error */
    movew %d0,%fp@(22)
    jbra NEWTEMPSCREENBUFFER_1CA
    .short  0x3D78, 0x0D6E, 0x0016, 0x4E71	| 40840E96
NEWTEMPSCREENBUFFER_1CA:/* dispose of what was allocated */
    movel %fp@(-8),%d0
    _DisposHandle
    movel %fp@(-12),%d0
    _DisposHandle
    jbra NEWTEMPSCREENBUFFER_198
    .long   0x00000000	| 40840EAC

/* DISPOSESCREENBUFFER: _DisposeScreenBuffer. */
DISPOSESCREENBUFFER:    /* dispose of the pixels (a locked one through its handle) and the pixmap */
    moveal %sp@(4,%za0)@(0),%a1	| 40840EB0
    moveal %a1@,%a0
    movew %a1@(14),%d0
    cmpiw #2,%d0
    jbeq DISPOSESCREENBUFFER_1A
    cmpiw #1,%d0
    jbne DISPOSESCREENBUFFER_22
    .short  0xA128	| 40840EC8 _RecoverHandle (flags 0x0100)
DISPOSESCREENBUFFER_1A:  /* _DisposHandle */
    _DisposHandle
    moveal %sp@(4),%a0
    _DisposHandle
DISPOSESCREENBUFFER_22: /* return */
    rtd #4
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40840ED6

/* OFFSCREENVERSION: _OffscreenVersion. */
OFFSCREENVERSION:
    movel #257,%sp@(4)
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 40840EEE
