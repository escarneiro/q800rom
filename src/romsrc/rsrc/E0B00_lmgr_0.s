/* ROM resource 'lmgr' 0: map entry at 0x408E0B00, data at 0x408E0B30, 7146 bytes

 The LAP Manager ('lmgr' 0, "lmgr v57.0.5f1", (c) Apple 1984-1992): installed at start-up
 (by 'INIT' 18 on System 6, by the System otherwise). It chooses the AppleTalk link (the
 network connection set in the Network control panel, from parameter RAM), loads its link
 code ('atlk', 'ltlk') and installs the real .MPP ('drvr' 9) in place of the stub, and
 provides the LAP Manager calls (link access, AppleTalk transition queue) to the rest of
 the system. Comments inferred from the code; routines summarised mechanically.
*/

rsrc_lmgr_0_entry:      /* map entry */
    .long   0x38000000, 0x00000000	| 408E0B00
    .long   rsrc_drvr_9_entry-rom_start	| 408E0B08
    .long   rsrc_lmgr_0-rom_start	| 408E0B0C
    .ascii  "lmgr"	| 408E0B10
    .byte   0x00, 0x00, 0x58, 0x00	| 408E0B14
    FILL_408E0B18
    .byte   0xC0, 0xA0, 0x00, 0x00	| 408E0B24
    .short  0x0000, 0x1BF6	| orib #0xf6,%d0
    .short  0x0000, 0x02C4	| orib #0xc4,%d0

/* Entry: install the LAP Manager (its code stays in the system heap). */
rsrc_lmgr_0:
    jbra rsrc_lmgr_0_4A
    bras rsrc_lmgr_0_4A_1A
    orib #8,%d0
    movew %d5,%a4@-
    orb %d1,%d0
    .short  0x0000, 0x0835	| orib #53,%d0
    .short  0x372E, 0x302E, 0x3566, 0x3100, 0x306C, 0x6D67, 0x7220, 0x7635	| 408E0B40
    .short  0x372E, 0x302E, 0x3566, 0x313B, 0x20A9	| 408E0B50
    .ascii  " Apple Computer, Inc. 1984-1992\000"

rsrc_lmgr_0_4A:         /* call rsrc_lmgr_0_68 */
    bsrw rsrc_lmgr_0_68
    movew %d0,%sp@-
    movel #0,%sp@-
    jbsr rsrc_lmgr_0_B52
    addqw #4,%sp
    movew %sp@+,%d0
    bsrw rsrc_lmgr_0_84
    rts
rsrc_lmgr_0_4A_1A:
    jmp %pc@(rsrc_lmgr_0_B52)

/* subroutine (10 instructions): low memory SysVersion, SysZone (mechanical summary) */
rsrc_lmgr_0_68:
    movew SysVersion,%d0
    cmpiw #1792,%d0
    jblt rsrc_lmgr_0_68_18
    moveal SysZone,%a0
    tstl %a0@(16)
    seq %d0
    extw %d0
    rts
rsrc_lmgr_0_68_18:      /* clear %d0 */
    clrw %d0
    rts

/* subroutine (5 instructions): low memory SysZone (mechanical summary) */
rsrc_lmgr_0_84:
    tstb %d0
    jbeq rsrc_lmgr_0_84_C
    moveal SysZone,%a0
    clrl %a0@(16)
rsrc_lmgr_0_84_C:       /* return */
    rts

/* subroutine (11 instructions): low memory UTableBase (mechanical summary) */
rsrc_lmgr_0_92:
    moveal UTableBase,%a1
    movew #36,%d0
    moveal %a1@(0x0,%d0:w),%a0
    movel %a0,%d0
    jbeq rsrc_lmgr_0_92_18
    moveal %a0@,%a1
    btst #5,%a1@(5)
rsrc_lmgr_0_92_18:      /* from here: sne %d0 */
    sne %d0
    extw %d0
    extl %d0
    rts

/* subroutine (5 instructions) (mechanical summary) */
rsrc_lmgr_0_B2:
    moveal %sp@(4),%a0
    moveml %d3-%d7/%a2-%a4,%sp@-
    jsr %a0@
    moveml %sp@+,%d3-%d7/%a2-%a4
    rts

/* subroutine (22 instructions): traps NewPtr; low memory ExpandMem, ATalkHk2 (mechanical summary) */
rsrc_lmgr_0_C2:
    linkw %fp,#0
    moveml %a2-%a3,%sp@-
    moveq #1,%d2
    moveq #16,%d0
    cmpib #127,%fp@(11)
    jbne rsrc_lmgr_0_C2_18
    moveq #8,%d2
    muluw %d2,%d0
rsrc_lmgr_0_C2_18:      /* from here: addiw #650,%d0 */
    addiw #650,%d0
    .short  0xA71E	| 408E0C0E _NewPtr (flags 0x0700)
    jbne rsrc_lmgr_0_C2_3C
    movew %d2,%a0@
    moveal ExpandMem,%a1
    lea %a1@(116),%a1
    movel %fp@(12),%a0@(494)
    movel %a0,%a1@
    moveal ATalkHk2,%a3
    moveq #16,%d0
    jsr %a3@(2)
rsrc_lmgr_0_C2_3C:      /* from here: extl %d0 */
    extl %d0
    moveml %sp@+,%a2-%a3
    unlk %fp
    rts

/* subroutine (25 instructions): traps GetResource, DetachResource, NewPtr; calls rsrc_lmgr_0_18F6; low memory ExpandMem (mechanical summary) */
rsrc_lmgr_0_108:
    movel %a3,%sp@-
    moveal ExpandMem,%a3
    moveal %a3@(116),%a3
    pea %a3@(6)
    movew #-16404,%sp@-
    movew #1,%sp@-
    jsr %pc@(rsrc_lmgr_0_18F6)
    clrl %sp@-
    movel #1398034979,%sp@-
    movew #-16408,%sp@-
    _GetResource
    movel %sp@,%sp@-
    _DetachResource
    moveal %sp@+,%a0
    movel %a0,%a3@(498)
    moveal %a0@,%a0
    moveq #1,%d0
    addb %a0@(2),%d0
    lea %a0@(0x2,%d0:w),%a0
    addb %a0@,%d0
    addib #32,%d0
    .short  0xA71E	| 408E0C7C _NewPtr (flags 0x0700)
    movel %a0,%a3@(632)
    moveq #0,%d0
    moveal %sp@+,%a3
    rts

/* subroutine (7 instructions): traps InitFonts, InitWindows, TEInit, InitDialogs; low memory DeskHook (mechanical summary) */
rsrc_lmgr_0_158:
    _InitFonts
    _InitWindows
    _TEInit
    clrl %sp@-
    _InitDialogs
    clrl DeskHook
    rts

/* subroutine (4 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_lmgr_0_168:
    moveq #33,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    rts

/* subroutine (34 instructions): traps ResrvMem, NewHandle, HUnlock, BlockMove, DisposHandle, HLock; low memory ROMBase, AGBHandle (mechanical summary) */
rsrc_lmgr_0_174:
    moveq #0,%d0
    moveal ROMBase,%a0
    cmpib #118,%a0@(9)
    jbcs rsrc_lmgr_0_174_5C
    moveal AGBHandle,%a0
    cmpaw #-1,%a0
    jbne rsrc_lmgr_0_174_28
    moveq #24,%d0
    .short  0xA440	| 408E0CBE _ResrvMem (flags 0x0400)
    moveq #24,%d0
    .short  0xA722	| 408E0CC2 _NewHandle (flags 0x0700)
    jbne rsrc_lmgr_0_174_5E
    movel %a0,AGBHandle
    jbra rsrc_lmgr_0_174_54
rsrc_lmgr_0_174_28:     /* _HUnlock */
    _HUnlock
    moveq #24,%d0
    .short  0xA440	| 408E0CD0 _ResrvMem (flags 0x0400)
    jbne rsrc_lmgr_0_174_5E
    moveq #24,%d0
    .short  0xA722	| 408E0CD6 _NewHandle (flags 0x0700)
    jbne rsrc_lmgr_0_174_5E
    movel %a0,%d1
    moveal %a0@,%a1
    moveal AGBHandle,%a0
    movel %a0@,%d0
    moveal %d0,%a0
    moveq #16,%d0
    _BlockMove
    moveal AGBHandle,%a0
    movel %d1,AGBHandle
    jbra rsrc_lmgr_0_174_52
    .short  0x2041	| 408E0CF4
rsrc_lmgr_0_174_52:     /* _DisposHandle */
    _DisposHandle
rsrc_lmgr_0_174_54:     /* set up and call _HLock */
    moveal AGBHandle,%a0
    _HLock
    moveq #0,%d0
rsrc_lmgr_0_174_5C:     /* return */
    rts
rsrc_lmgr_0_174_5E:     /* result -108 */
    moveq #-108,%d0
    rts

/* subroutine (44 instructions): traps Control, Close, RecoverHandle, DisposHandle, GetResource, DrvrRemove, DisposPtr; low memory ATalkHk2, MemErr, SysVersion, PortBUse, ExpandMem (mechanical summary) */
rsrc_lmgr_0_1D6:
    movel %a2,%sp@-
    subaw #50,%sp
    moveal %sp,%a0
    movew #247,%a0@(26)
    movew #-41,%a0@(24)
    _Control
    _Close
    movew #-10,%a0@(24)
    _Close
    lea %sp@(50),%sp
    moveq #4,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    movel %a0,%sp@-
    moveq #2,%d0
    jsr %a0@(2)
    moveal %sp@+,%a0
    .short  0xA128	| 408E0D3E _RecoverHandle (flags 0x0100)
    tstw MemErr
    jbne rsrc_lmgr_0_1D6_42
    _DisposHandle
rsrc_lmgr_0_1D6_42:     /* set %d0 */
    movew SysVersion,%d0
    cmpiw #1792,%d0
    jbcc rsrc_lmgr_0_1D6_5A
    clrl %sp@-
    movel #1229867348,%sp@-
    movew #22,%sp@-
    _GetResource
rsrc_lmgr_0_1D6_5A:     /* set up and call _DrvrRemove */
    st PortBUse
    moveq #-11,%d0
    _DrvrRemove
    moveq #-10,%d0
    _DrvrRemove
    moveq #-41,%d0
    _DrvrRemove
    moveal ExpandMem,%a1
    moveal %a1@(116),%a0
    movel %a0@(494),%d1
    _DisposPtr
    movel #-1,ATalkHk2
    moveal %sp@+,%a2
    moveal %sp@(4),%a1
    movel %d1,%a1@
    moveq #0,%d0
    rts

/* subroutine (11 instructions) (mechanical summary) */
rsrc_lmgr_0_262:
    moveal %sp@(4),%a0
    movel %sp@(8),%d1
    moveml %d2-%d4/%a0/%a2-%a3,%sp@-
    moveal %a0,%a3
    moveal %a0@,%a0
    moveq #0,%d4
    moveq #1,%d0
    jsr %a0@(2)
    moveml %sp@+,%d2-%d4/%a0/%a2-%a3
    tstw %d0
    rts

/* subroutine (12 instructions): low memory SPConfig (mechanical summary) */
rsrc_lmgr_0_282:
    linkw %fp,#0
    moveq #0,%d0
    moveb SPConfig,%d0
    moveq #15,%d1
    andb %d0,%d1
    moveq #0,%d0
    moveb %d1,%d0
    cmpiw #1,%d0
    seq %d0
    negb %d0
    unlk %fp
    rts

/* subroutine (24 instructions): low memory SPConfig (mechanical summary) */
rsrc_lmgr_0_2A0:
    linkw %fp,#0
    movel %d7,%sp@-
    moveb SPConfig,%d7
    andib #15,%d7
    moveq #0,%d0
    moveb %d7,%d0
    cmpiw #15,%d0
    jbeq rsrc_lmgr_0_2A0_20
    moveq #0,%d0
    moveb %d7,%d0
    tstl %d0
    jbne rsrc_lmgr_0_2A0_38
rsrc_lmgr_0_2A0_20:     /* clear %d0 */
    moveq #0,%d0
    moveb SPConfig,%d0
    movew #240,%d1
    andb %d0,%d1
    moveq #0,%d0
    moveb %d1,%d0
    moveq #1,%d1
    orb %d0,%d1
    moveb %d1,SPConfig
rsrc_lmgr_0_2A0_38:     /* set %d7 */
    movel %fp@(-4),%d7
    unlk %fp
    rts

/* subroutine (15 instructions): traps GetResource; low memory CurMap, ROMMapInsert (mechanical summary) */
rsrc_lmgr_0_2E0:
    linkw %fp,#0
    moveml %d7/%a4,%sp@-
    movew CurMap,%d7
    movew #1,CurMap
    movew #-1,ROMMapInsert
    subql #4,%sp
    movel %fp@(8),%sp@-
    movew %fp@(14),%sp@-
    _GetResource
    moveal %sp@+,%a4
    movew %d7,CurMap
    movel %a4,%d0
    moveml %fp@(-8),%d7/%a4
    unlk %fp
    rts

/* subroutine (26 instructions): calls rsrc_lmgr_0_1254, rsrc_lmgr_0_102C, rsrc_lmgr_0_1086 (mechanical summary) */
rsrc_lmgr_0_316:
    linkw %fp,#0
    moveml %d7/%a4,%sp@-
    movel %fp@(8),%d7
    subql #4,%sp
    movel #1146246738,%sp@-
    movew %d7,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    moveal %sp@+,%a4
    movel %a4,%d0
    jbne rsrc_lmgr_0_316_24
    moveq #-1,%d0
    jbra rsrc_lmgr_0_316_3E
rsrc_lmgr_0_316_24:     /* set %d0 */
    moveq #40,%d0
    cmpl %d7,%d0
    jblt rsrc_lmgr_0_316_36
    movel %d7,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_102C)
    addqw #8,%sp
    jbra rsrc_lmgr_0_316_3E
rsrc_lmgr_0_316_36:     /* set %sp@- */
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_1086)
    addqw #4,%sp
rsrc_lmgr_0_316_3E:     /* restore registers, return */
    moveml %fp@(-8),%d7/%a4
    unlk %fp
    rts

/* subroutine (21 instructions): calls rsrc_lmgr_0_1B4A; low memory ATalkHk2 (mechanical summary) */
rsrc_lmgr_0_35E:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a3
    movel %a3,%d7
    moveal %d7,%a0
    movew %a0@(8),%d0
    extl %d0
    addl %d7,%d0
    moveal %d0,%a4
    subqw #2,%a4
    movew %a4@,%d0
    extl %d0
    addl %d7,%d0
    moveal %d0,%a4
    subql #4,%sp
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_1B4A)
    movel %sp@+,ATalkHk2
    moveml %fp@(-12),%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (20 instructions): traps DetachResource; calls rsrc_lmgr_0_1254, rsrc_lmgr_0_35E (mechanical summary) */
rsrc_lmgr_0_398:
    linkw %fp,#0
    movel %a4,%sp@-
    subql #4,%sp
    movel #1146246738,%sp@-
    moveq #9,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    moveal %sp@+,%a4
    movel %a4,%d0
    jbne rsrc_lmgr_0_398_20
    moveq #-1,%d0
    jbra rsrc_lmgr_0_398_2C
rsrc_lmgr_0_398_20:     /* set up and call _DetachResource */
    movel %a4,%sp@-
    _DetachResource
    movel %a4@,%sp@-
    jsr %pc@(rsrc_lmgr_0_35E)
    moveq #0,%d0
rsrc_lmgr_0_398_2C:     /* set %a4 */
    moveal %fp@(-4),%a4
    unlk %fp
    rts

/* subroutine (54 instructions): traps CautionAlert; calls rsrc_lmgr_0_17D4, rsrc_lmgr_0_181C, rsrc_lmgr_0_16EC, rsrc_lmgr_0_158, rsrc_lmgr_0_1794 (mechanical summary) */
rsrc_lmgr_0_3CC:
    linkw %fp,#-8
    moveml %d6-%d7,%sp@-
    movel %fp@(8),%d6
    pea %fp@(-4)
    movel %d6,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_17D4)
    movew %d0,%d7
    lea %sp@(12),%sp
    jbeq rsrc_lmgr_0_3CC_8E
    movel #255,%d0
    andl %d6,%d0
    movel %d0,%fp@(-8)
    jsr %pc@(rsrc_lmgr_0_181C)
    movel #255,%d1
    andl %d0,%d1
    movel %fp@(-8),%d0
    cmpl %d0,%d1
    jbeq rsrc_lmgr_0_3CC_8E
    jsr %pc@(rsrc_lmgr_0_16EC)
    moveq #3,%d1
    andl %d0,%d1
    moveq #3,%d0
    cmpl %d1,%d0
    jbne rsrc_lmgr_0_3CC_74
    jsr %pc@(rsrc_lmgr_0_158)
    subql #2,%sp
    cmpiw #-3,%d7
    jbne rsrc_lmgr_0_3CC_64
    movel #-16407,%d0
    jbra rsrc_lmgr_0_3CC_6A
rsrc_lmgr_0_3CC_64:     /* set %d0 */
    movel #-16406,%d0
rsrc_lmgr_0_3CC_6A:     /* set up and call _CautionAlert */
    movew %d0,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    _CautionAlert
    addqw #2,%sp
rsrc_lmgr_0_3CC_74:     /* call rsrc_lmgr_0_181C */
    jsr %pc@(rsrc_lmgr_0_181C)
    movel %d0,%d6
    pea %fp@(-4)
    movel %d6,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_17D4)
    movew %d0,%d7
    lea %sp@(12),%sp
rsrc_lmgr_0_3CC_8E:     /* set %sp@- */
    movel %fp@(-4),%sp@-
    jsr %pc@(rsrc_lmgr_0_1794)
    movew %d7,%d0
    addqw #4,%sp
    moveml %fp@(-16),%d6-%d7
    unlk %fp
    rts

/* subroutine (17 instructions): calls rsrc_lmgr_0_17F8; low memory PortBUse (mechanical summary) */
rsrc_lmgr_0_470:
    linkw %fp,#0
    moveml %d6-%d7,%sp@-
    movew %fp@(10),%d6
    moveb #0xff,PortBUse
    clrw %d7
    jbra rsrc_lmgr_0_470_24
rsrc_lmgr_0_470_16:     /* loop: ext */
    extl %d7
    movel %d7,%sp@-
    jsr %pc@(rsrc_lmgr_0_17F8)
    addqw #4,%sp
    movew %d7,%d0
    addqw #1,%d7
rsrc_lmgr_0_470_24:     /* test %d7,%d6 */
    cmpw %d7,%d6
    jbge rsrc_lmgr_0_470_16
    moveml %fp@(-8),%d6-%d7
    unlk %fp
    rts

/* subroutine (22 instructions): traps ParamText, CautionAlert; calls rsrc_lmgr_0_158, rsrc_lmgr_0_18F6 (mechanical summary) */
rsrc_lmgr_0_4A2:
    linkw %fp,#-256
    movel %a4,%sp@-
    lea %fp@(-256),%a4
    jsr %pc@(rsrc_lmgr_0_158)
    movel %a4,%sp@-
    movew #-16404,%sp@-
    movew %fp@(10),%sp@-
    jsr %pc@(rsrc_lmgr_0_18F6)
    movel %a4,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movel %d0,%sp@-
    movel %d0,%sp@-
    _ParamText
    subql #2,%sp
    movew #-16405,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    _CautionAlert
    moveal %fp@(-260),%a4
    unlk %fp
    rts

/* subroutine (122 instructions): traps GetResource, CloseResFile; calls rsrc_lmgr_0_193C, rsrc_lmgr_0_4A2, rsrc_lmgr_0_C2C, rsrc_lmgr_0_17D4, rsrc_lmgr_0_470 ...; low memory ResErr (mechanical summary) */
rsrc_lmgr_0_4DE:
    linkw %fp,#-4
    moveml %d3-%d7/%a3-%a4,%sp@-
    subql #2,%sp
    movel #1986863136,%sp@-
    pea %fp@(-4)
    jsr %pc@(rsrc_lmgr_0_193C)
    movew %sp@+,%d5
    jbne rsrc_lmgr_0_4DE_34
    moveq #1,%d0
    andl %fp@(-4),%d0
    jbeq rsrc_lmgr_0_4DE_34
    moveq #6,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_4A2)
    moveq #-1,%d0
    addqw #4,%sp
    jbra rsrc_lmgr_0_4DE_13E
rsrc_lmgr_0_4DE_34:     /* clear %d6 */
    clrw %d6
rsrc_lmgr_0_4DE_36:     /* call rsrc_lmgr_0_C2C (loop) */
    jsr %pc@(rsrc_lmgr_0_C2C)
    movew %d0,%d4
    cmpiw #-1,%d4
    jbne rsrc_lmgr_0_4DE_52
    moveq #4,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_4A2)
    moveq #-1,%d0
    addqw #4,%sp
    jbra rsrc_lmgr_0_4DE_13E
rsrc_lmgr_0_4DE_52:     /* set up and call _GetResource */
    subql #4,%sp
    movel #1886351988,%sp@-
    movew %d6,%sp@-
    _GetResource
    moveal %sp@+,%a4
    movel %a4,%d0
    jbeq rsrc_lmgr_0_4DE_CA
    moveal %a4@,%a0
    movel %a0@,%d7
    movew %d4,%sp@-
    _CloseResFile
    cmpil #1396900611,%d7
    jbne rsrc_lmgr_0_4DE_76
    moveq #3,%d7
rsrc_lmgr_0_4DE_76:     /* test #1396900097,%d7 */
    cmpil #1396900097,%d7
    jbne rsrc_lmgr_0_4DE_80
    moveq #1,%d7
rsrc_lmgr_0_4DE_80:     /* from here: pea %fp@(-4) */
    pea %fp@(-4)
    movel %d7,%sp@-
    extl %d6
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_17D4)
    movew %d0,%d5
    lea %sp@(12),%sp
    jbne rsrc_lmgr_0_4DE_9C
    cmpl %fp@(-4),%d7
    jbeq rsrc_lmgr_0_4DE_BE
rsrc_lmgr_0_4DE_9C:     /* from here: extl %d6 */
    extl %d6
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_470)
    cmpiw #-3,%d5
    jbne rsrc_lmgr_0_4DE_AE
    moveq #2,%d0
    jbra rsrc_lmgr_0_4DE_B0
rsrc_lmgr_0_4DE_AE:     /* set %d0 */
    moveq #3,%d0
rsrc_lmgr_0_4DE_B0:     /* set %sp@- */
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_4A2)
    moveq #-1,%d0
    addqw #8,%sp
    jbra rsrc_lmgr_0_4DE_13E
rsrc_lmgr_0_4DE_BE:     /* set %d0 */
    movew %d6,%d0
    addqw #1,%d6
    cmpiw #8,%d6
    jblt rsrc_lmgr_0_4DE_36
rsrc_lmgr_0_4DE_CA:     /* subtract 4 to %sp */
    subql #4,%sp
    movel #1651663975,%sp@-
    moveq #0,%d0
    movew %d0,%sp@-
    _GetResource
    moveal %sp@+,%a3
    tstw ResErr
    jbne rsrc_lmgr_0_4DE_E4
    movel %a3,%d0
    jbne rsrc_lmgr_0_4DE_FE
rsrc_lmgr_0_4DE_E4:     /* set up and call _CloseResFile */
    movew %d4,%sp@-
    _CloseResFile
    extl %d6
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_470)
    moveq #5,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_4A2)
    moveq #-1,%d0
    addqw #8,%sp
    jbra rsrc_lmgr_0_4DE_13E
rsrc_lmgr_0_4DE_FE:     /* call rsrc_lmgr_0_158 */
    jsr %pc@(rsrc_lmgr_0_158)
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1086_70)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a3@,%sp@-
    jsr %pc@(rsrc_lmgr_0_C40)
    movew %d0,%d5
    movew %d4,%sp@-
    _CloseResFile
    tstw %d5
    addqw #8,%sp
    jbeq rsrc_lmgr_0_4DE_12E
    extl %d6
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_470)
    movew %d5,%d0
    addqw #4,%sp
    jbra rsrc_lmgr_0_4DE_13E
rsrc_lmgr_0_4DE_12E:    /* call rsrc_lmgr_0_C54 */
    jsr %pc@(rsrc_lmgr_0_C54)
    moveq #7,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_180C)
    moveq #0,%d0
    addqw #4,%sp
rsrc_lmgr_0_4DE_13E:    /* restore registers, return */
    moveml %fp@(-32),%d3-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (85 instructions): calls rsrc_lmgr_0_398, rsrc_lmgr_0_1732, rsrc_lmgr_0_C2, rsrc_lmgr_0_174, rsrc_lmgr_0_108 ... (mechanical summary) */
rsrc_lmgr_0_626:
    linkw %fp,#0
    moveml %d6-%d7/%a3-%a4,%sp@-
    moveal %fp@(12),%a3
    jsr %pc@(rsrc_lmgr_0_398)
    movew %d0,%d7
    jbne rsrc_lmgr_0_626_DE
    jsr %pc@(rsrc_lmgr_0_1732)
    movel %d0,%d6
    movel %fp@(8),%sp@-
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_C2)
    movew %d0,%d7
    addqw #8,%sp
    jbne rsrc_lmgr_0_626_DE
    jsr %pc@(rsrc_lmgr_0_174)
    movew %d0,%d7
    jbne rsrc_lmgr_0_626_DE
    jsr %pc@(rsrc_lmgr_0_108)
    movew %d0,%d7
    jbne rsrc_lmgr_0_626_DE
    subql #4,%sp
    movel #1685223026,%sp@-
    moveq #9,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    moveal %sp@+,%a4
    movel %a4,%d0
    jbne rsrc_lmgr_0_626_5E
    moveq #-1,%d7
    jbra rsrc_lmgr_0_626_DE
rsrc_lmgr_0_626_5E:     /* set %d0 */
    moveq #9,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_102C)
    movew %d0,%d7
    moveq #10,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_316)
    movew %d0,%d7
    lea %sp@(12),%sp
    jbne rsrc_lmgr_0_626_DE
    moveq #40,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_316)
    movew %d0,%d7
    addqw #4,%sp
    jbne rsrc_lmgr_0_626_DE
    moveq #126,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_316)
    movew %d0,%d7
    addqw #4,%sp
    jbne rsrc_lmgr_0_626_DE
    jsr %pc@(rsrc_lmgr_0_168)
    movel #255,%d0
    andl %d6,%d0
    moveq #127,%d1
    cmpl %d0,%d1
    jbne rsrc_lmgr_0_626_C2
    jsr %pc@(rsrc_lmgr_0_4DE)
    movew %d0,%d7
    jbeq rsrc_lmgr_0_626_DE
    jsr %pc@(rsrc_lmgr_0_181C)
    movel %d0,%d6
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_3CC)
    movew %d0,%d7
    addqw #4,%sp
    jbra rsrc_lmgr_0_626_DE
rsrc_lmgr_0_626_C2:     /* set %d0 */
    movel %a3,%d0
    jbne rsrc_lmgr_0_626_D2
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_3CC)
    movew %d0,%d7
    addqw #4,%sp
    jbra rsrc_lmgr_0_626_DE
rsrc_lmgr_0_626_D2:     /* set %sp@- */
    movel %d6,%sp@-
    movel %a3,%sp@-
    jsr %pc@(rsrc_lmgr_0_262)
    movew %d0,%d7
    addqw #8,%sp
rsrc_lmgr_0_626_DE:     /* set %d0 */
    movew %d7,%d0
    moveml %fp@(-16),%d6-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (52 instructions): traps NewPtr, DisposPtr; calls rsrc_lmgr_0_CAC, rsrc_lmgr_0_E0E, rsrc_lmgr_0_626, rsrc_lmgr_0_DFE; low memory SysVersion (mechanical summary) */
rsrc_lmgr_0_710:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    subql #4,%sp
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #0,%d1
    movew %d1,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movel #1095323209,%sp@-
    jsr %pc@(rsrc_lmgr_0_CAC)
    moveal %sp@,%a4
    movew #-32768,%sp@-
    moveq #-1,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_E0E)
    moveq #0,%d0
    movel %d0,%sp@-
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_626)
    movew %d0,%d7
    addqw #8,%sp
    jbeq rsrc_lmgr_0_710_46
    movew %d7,%d0
    jbra rsrc_lmgr_0_710_86
rsrc_lmgr_0_710_46:     /* set %sp@- */
    movel %a4,%sp@-
    moveq #0,%d0
    movew %d0,%sp@-
    movew #32767,%sp@-
    jsr %pc@(rsrc_lmgr_0_E0E)
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_DFE)
    moveq #0,%d0
    movew SysVersion,%d0
    movew #-256,%d1
    andw %d0,%d1
    moveq #0,%d0
    movew %d1,%d0
    cmpil #1536,%d0
    jbne rsrc_lmgr_0_710_84
    movel #25000,%d0
    .short  0xA11E	| 408E12B8 _NewPtr (flags 0x0100)
    moveal %a0,%a3
    movel %a3,%d0
    jbeq rsrc_lmgr_0_710_84
    moveal %a3,%a0
    _DisposPtr
rsrc_lmgr_0_710_84:     /* set %d0 */
    movew %d7,%d0
rsrc_lmgr_0_710_86:     /* restore registers, return */
    moveml %fp@(-12),%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (96 instructions): calls rsrc_lmgr_0_1732, rsrc_lmgr_0_398, rsrc_lmgr_0_C2, rsrc_lmgr_0_174, rsrc_lmgr_0_2E0 ... (mechanical summary) */
rsrc_lmgr_0_7A0:
    linkw %fp,#0
    moveml %d6-%d7/%a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_1732)
    movel %d0,%d6
    jsr %pc@(rsrc_lmgr_0_398)
    movew %d0,%d7
    jbne rsrc_lmgr_0_7A0_FC
    moveq #0,%d0
    movel %d0,%sp@-
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_C2)
    movew %d0,%d7
    addqw #8,%sp
    jbne rsrc_lmgr_0_7A0_FC
    jsr %pc@(rsrc_lmgr_0_174)
    movew %d0,%d7
    jbne rsrc_lmgr_0_7A0_FC
    moveq #9,%d0
    movel %d0,%sp@-
    movel #1685223026,%sp@-
    jsr %pc@(rsrc_lmgr_0_2E0)
    moveal %d0,%a4
    movel %a4,%d0
    addqw #8,%sp
    jbne rsrc_lmgr_0_7A0_50
    moveq #-1,%d7
    jbra rsrc_lmgr_0_7A0_FC
rsrc_lmgr_0_7A0_50:     /* set %d0 */
    moveq #9,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_102C)
    movew %d0,%d7
    moveq #10,%d0
    movel %d0,%sp@-
    movel #1146246738,%sp@-
    jsr %pc@(rsrc_lmgr_0_2E0)
    moveal %d0,%a4
    movel %a4,%d0
    lea %sp@(16),%sp
    jbne rsrc_lmgr_0_7A0_7A
    moveq #-1,%d7
    jbra rsrc_lmgr_0_7A0_FC
rsrc_lmgr_0_7A0_7A:     /* set %d0 */
    moveq #10,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_102C)
    movew %d0,%d7
    addqw #8,%sp
    jbne rsrc_lmgr_0_7A0_FC
    moveq #40,%d0
    movel %d0,%sp@-
    movel #1146246738,%sp@-
    jsr %pc@(rsrc_lmgr_0_2E0)
    moveal %d0,%a4
    movel %a4,%d0
    addqw #8,%sp
    jbne rsrc_lmgr_0_7A0_A4
    moveq #-1,%d7
    jbra rsrc_lmgr_0_7A0_FC
rsrc_lmgr_0_7A0_A4:     /* set %d0 */
    moveq #40,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_102C)
    movew %d0,%d7
    addqw #8,%sp
    jbne rsrc_lmgr_0_7A0_FC
    movel #255,%d0
    andl %d6,%d0
    moveq #127,%d1
    cmpl %d0,%d1
    jbne rsrc_lmgr_0_7A0_D0
    jsr %pc@(rsrc_lmgr_0_181C)
    movel %d0,%d6
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_177E)
    addqw #4,%sp
rsrc_lmgr_0_7A0_D0:     /* set %d0 */
    movel #255,%d0
    andl %d6,%d0
    movel %d0,%sp@-
    movel #1635019883,%sp@-
    jsr %pc@(rsrc_lmgr_0_2E0)
    moveal %d0,%a4
    movel %a4,%d0
    addqw #8,%sp
    jbne rsrc_lmgr_0_7A0_F0
    moveq #-1,%d7
    jbra rsrc_lmgr_0_7A0_FC
rsrc_lmgr_0_7A0_F0:     /* set %sp@- */
    movel %d6,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_262)
    movew %d0,%d7
    addqw #8,%sp
rsrc_lmgr_0_7A0_FC:     /* set %d0 */
    movew %d7,%d0
    moveml %fp@(-12),%d6-%d7/%a4
    unlk %fp
    rts

/* subroutine (57 instructions): calls rsrc_lmgr_0_CAC, rsrc_lmgr_0_E0E, rsrc_lmgr_0_1254, rsrc_lmgr_0_102C, rsrc_lmgr_0_35E ... (mechanical summary) */
rsrc_lmgr_0_8A8:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    subql #4,%sp
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #0,%d1
    movew %d1,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movel #1095323209,%sp@-
    jsr %pc@(rsrc_lmgr_0_CAC)
    moveal %sp@,%a3
    movew #-32768,%sp@-
    moveq #-1,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_E0E)
    subql #4,%sp
    movel #1146246738,%sp@-
    moveq #9,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    moveal %sp@+,%a4
    movel %a4,%d0
    jbne rsrc_lmgr_0_8A8_4C
    moveq #-1,%d7
    jbra rsrc_lmgr_0_8A8_7A
rsrc_lmgr_0_8A8_4C:     /* set %d0 */
    moveq #9,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_102C)
    movew %d0,%d7
    addqw #8,%sp
    jbne rsrc_lmgr_0_8A8_7A
    movel %a4@,%sp@-
    jsr %pc@(rsrc_lmgr_0_35E)
    moveq #0,%d0
    movel %d0,%sp@-
    movel %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_C2)
    movew %d0,%d7
    lea %sp@(12),%sp
    jbne rsrc_lmgr_0_8A8_7A
    jsr %pc@(rsrc_lmgr_0_174)
    movew %d0,%d7
rsrc_lmgr_0_8A8_7A:     /* set %sp@- */
    movel %a3,%sp@-
    moveq #0,%d0
    movew %d0,%sp@-
    movew #29499,%sp@-
    jsr %pc@(rsrc_lmgr_0_E0E)
    movel %a3,%sp@-
    jsr %pc@(rsrc_lmgr_0_DFE)
    moveq #0,%d0
    moveml %fp@(-12),%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (154 instructions): traps DetachResource, CloseResFile, HLock, GetResource; calls rsrc_lmgr_0_1254, rsrc_lmgr_0_1732, rsrc_lmgr_0_1678 (mechanical summary) */
rsrc_lmgr_0_942:
    linkw %fp,#-2
    moveml %d3/%d6-%d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    subql #4,%sp
    movel #1685223026,%sp@-
    moveq #9,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    subql #4,%sp
    movel #1146246738,%sp@-
    moveq #9,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    subql #4,%sp
    movel #1146246738,%sp@-
    moveq #10,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    subql #4,%sp
    movel #1146246738,%sp@-
    moveq #40,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    subql #4,%sp
    movel #1146246738,%sp@-
    moveq #126,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    jsr %pc@(rsrc_lmgr_0_1732)
    movel %d0,%d6
    andil #255,%d6
    subql #4,%sp
    pea %fp@(-2)
    movew %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_1678)
    movel %sp@,%a4@
    _DetachResource
    tstw %fp@(-2)
    lea %sp@(20),%sp
    jbeq rsrc_lmgr_0_942_88
    movew %fp@(-2),%sp@-
    _CloseResFile
rsrc_lmgr_0_942_88:     /* set %d0 */
    movel %d6,%d0
    subql #1,%d0
    jbeq rsrc_lmgr_0_942_94
    subql #2,%d0
    jbeq rsrc_lmgr_0_942_CA
    jbra rsrc_lmgr_0_942_100
rsrc_lmgr_0_942_94:     /* subtract 4 to %sp */
    subql #4,%sp
    movel #1819569259,%sp@-
    moveq #0,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    subql #4,%sp
    movel #1819569259,%sp@-
    moveq #1,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    subql #4,%sp
    movel #1768910947,%sp@-
    moveq #127,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    lea %sp@(12),%sp
    jbra rsrc_lmgr_0_942_124
rsrc_lmgr_0_942_CA:     /* subtract 4 to %sp */
    subql #4,%sp
    movel #1819569259,%sp@-
    moveq #2,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    subql #4,%sp
    movel #1819569259,%sp@-
    moveq #3,%d0
    movew %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    subql #4,%sp
    movel #1768910947,%sp@-
    movew #128,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    lea %sp@(12),%sp
    jbra rsrc_lmgr_0_942_124
rsrc_lmgr_0_942_100:    /* clear %d7 */
    moveq #0,%d7
rsrc_lmgr_0_942_102:    /* loop: subq */
    subql #4,%sp
    movel #1633776240,%sp@-
    movew %d7,%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    moveal %sp@+,%a4
    movel %a4,%d0
    jbeq rsrc_lmgr_0_942_11A
    moveal %a4,%a0
    _HLock
rsrc_lmgr_0_942_11A:    /* set %d0 */
    movel %d7,%d0
    addql #1,%d7
    moveq #15,%d0
    cmpl %d7,%d0
    jbge rsrc_lmgr_0_942_102
rsrc_lmgr_0_942_124:    /* set up and call _GetResource */
    subql #4,%sp
    movel #1635020914,%sp@-
    movew %d6,%sp@-
    _GetResource
    moveal %sp@+,%a3
    movel %a3,%d0
    jbeq rsrc_lmgr_0_942_178
    moveq #0,%d7
    jbra rsrc_lmgr_0_942_16E
rsrc_lmgr_0_942_13A:    /* loop: subq */
    subql #4,%sp
    moveal %a3@,%a0
    movel %d7,%d0
    addl %d0,%d0
    movel %d0,%d1
    addl %d1,%d1
    addl %d1,%d0
    movel %a0@(0x2,%d0:l),%sp@-
    moveal %a3@,%a0
    movel %d7,%d0
    addl %d0,%d0
    movel %d0,%d1
    addl %d1,%d1
    addl %d1,%d0
    movew %a0@(0x6,%d0:l),%sp@-
    jsr %pc@(rsrc_lmgr_0_1254)
    moveal %sp@+,%a4
    movel %a4,%d0
    jbeq rsrc_lmgr_0_942_16A
    moveal %a4,%a0
    _HLock
rsrc_lmgr_0_942_16A:    /* set %d0 */
    movel %d7,%d0
    addql #1,%d7
rsrc_lmgr_0_942_16E:    /* set %a0 */
    moveal %a3@,%a0
    movew %a0@,%d0
    extl %d0
    cmpl %d7,%d0
    jbgt rsrc_lmgr_0_942_13A
rsrc_lmgr_0_942_178:    /* set up and call _GetResource */
    subql #4,%sp
    movel #1398034979,%sp@-
    movew #-16408,%sp@-
    _GetResource
    moveal %sp@+,%a4
    movel %a4,%d0
    jbeq rsrc_lmgr_0_942_190
    moveal %a4,%a0
    _HLock
rsrc_lmgr_0_942_190:    /* set up and call _GetResource */
    subql #4,%sp
    movel #1398034979,%sp@-
    movew #-16404,%sp@-
    _GetResource
    moveal %sp@+,%a4
    movel %a4,%d0
    jbeq rsrc_lmgr_0_942_1A8
    moveal %a4,%a0
    _HLock
rsrc_lmgr_0_942_1A8:    /* restore registers, return */
    moveml %fp@(-22),%d3/%d6-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (33 instructions): traps SetResLoad; calls rsrc_lmgr_0_626, rsrc_lmgr_0_CAC, rsrc_lmgr_0_E0E, rsrc_lmgr_0_DFE (mechanical summary) */
rsrc_lmgr_0_AF4:
    linkw %fp,#0
    moveml %d7/%a4,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    _SetResLoad
    movel %fp@(12),%sp@-
    moveal %fp@(8),%a0
    movel %a0@,%sp@-
    jsr %pc@(rsrc_lmgr_0_626)
    movew %d0,%d7
    moveq #1,%d0
    moveb %d0,%sp@-
    _SetResLoad
    subql #4,%sp
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #0,%d1
    movew %d1,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movel #1095323209,%sp@-
    jsr %pc@(rsrc_lmgr_0_CAC)
    moveal %sp@,%a4
    movel #2147447612,%sp@-
    jsr %pc@(rsrc_lmgr_0_E0E)
    movel %a4,%sp@-
    jsr %pc@(rsrc_lmgr_0_DFE)
    movew %d7,%d0
    moveml %fp@(-8),%d7/%a4
    unlk %fp
    rts

/* subroutine (11 instructions): calls rsrc_lmgr_0_2A0 (mechanical summary) */
rsrc_lmgr_0_B52:
    linkw %fp,#-8
    moveml %d6-%d7,%sp@-
    movel %fp@(12),%d6
    jsr %pc@(rsrc_lmgr_0_2A0)
    movel %fp@(8),%d0
    jbmi rsrc_lmgr_0_C1E
    cmpil #6,%d0
    jbgt rsrc_lmgr_0_C1E
    addl %d0,%d0
    movew %pc@(rsrc_lmgr_0_B7E,%d0:l),%d0
rsrc_lmgr_0_B52_28:     /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
rsrc_lmgr_0_B7E:        /* (data) */
    .short  rsrc_lmgr_0_B8C-(rsrc_lmgr_0_B52_28+2)	| 408E16AE
    .short  rsrc_lmgr_0_C1E-(rsrc_lmgr_0_B52_28+2)	| 408E16B0
    .short  rsrc_lmgr_0_BDC-(rsrc_lmgr_0_B52_28+2)	| 408E16B2
    .short  rsrc_lmgr_0_BE4-(rsrc_lmgr_0_B52_28+2)	| 408E16B4
    .short  rsrc_lmgr_0_BF8-(rsrc_lmgr_0_B52_28+2)	| 408E16B6
    .short  rsrc_lmgr_0_C04-(rsrc_lmgr_0_B52_28+2)	| 408E16B8
    .short  rsrc_lmgr_0_C16-(rsrc_lmgr_0_B52_28+2)	| 408E16BA

/* subroutine (26 instructions): calls rsrc_lmgr_0_92, rsrc_lmgr_0_942, rsrc_lmgr_0_1D6, rsrc_lmgr_0_AF4, rsrc_lmgr_0_282 ...; low memory SysVersion (mechanical summary) */
rsrc_lmgr_0_B8C:
    jsr %pc@(rsrc_lmgr_0_92)
    tstl %d0
    jbeq rsrc_lmgr_0_BB8
    pea %fp@(-4)
    jsr %pc@(rsrc_lmgr_0_942)
    pea %fp@(-8)
    jsr %pc@(rsrc_lmgr_0_1D6)
    movel %fp@(-4),%sp@-
    pea %fp@(-8)
    jsr %pc@(rsrc_lmgr_0_AF4)
    movew %d0,%d7
    lea %sp@(16),%sp
    jbra rsrc_lmgr_0_C20
rsrc_lmgr_0_BB8:        /* clear %d0 */
    moveq #0,%d0
    movew SysVersion,%d0
    cmpiw #1808,%d0
    jbcs rsrc_lmgr_0_BD4
    jsr %pc@(rsrc_lmgr_0_282)
    tstb %d0
    jbne rsrc_lmgr_0_BD4
    jsr %pc@(rsrc_lmgr_0_8A8)
    movew %d0,%d7
    jbra rsrc_lmgr_0_C20
rsrc_lmgr_0_BD4:        /* call rsrc_lmgr_0_710 */
    jsr %pc@(rsrc_lmgr_0_710)
    movew %d0,%d7
    jbra rsrc_lmgr_0_C20

/* subroutine (3 instructions): calls rsrc_lmgr_0_7A0 (mechanical summary) */
rsrc_lmgr_0_BDC:
    jsr %pc@(rsrc_lmgr_0_7A0)
    movew %d0,%d7
    jbra rsrc_lmgr_0_C20

/* subroutine (7 instructions): calls rsrc_lmgr_0_942 (mechanical summary) */
rsrc_lmgr_0_BE4:
    pea %fp@(-4)
    jsr %pc@(rsrc_lmgr_0_942)
    moveal %d6,%a0
    movel %fp@(-4),%a0@
    clrw %d7
    addqw #4,%sp
    jbra rsrc_lmgr_0_C20

/* subroutine (5 instructions): calls rsrc_lmgr_0_1D6 (mechanical summary) */
rsrc_lmgr_0_BF8:
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_1D6)
    clrw %d7
    addqw #4,%sp
    jbra rsrc_lmgr_0_C20

/* subroutine (7 instructions): calls rsrc_lmgr_0_AF4 (mechanical summary) */
rsrc_lmgr_0_C04:
    moveal %fp@(16),%a0
    movel %a0@,%sp@-
    movel %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_AF4)
    movew %d0,%d7
    addqw #8,%sp
    jbra rsrc_lmgr_0_C20

/* subroutine (3 instructions): calls rsrc_lmgr_0_1110 (mechanical summary) */
rsrc_lmgr_0_C16:
    jsr %pc@(rsrc_lmgr_0_1110)
    movew %d0,%d7
    jbra rsrc_lmgr_0_C20

/* subroutine (5 instructions) (mechanical summary) */
rsrc_lmgr_0_C1E:
    moveq #-1,%d7
rsrc_lmgr_0_C20:        /* set %d0 */
    movew %d7,%d0
    moveml %fp@(-16),%d6-%d7
    unlk %fp
    rts

/* subroutine (7 instructions): traps OpenResFile; low memory ExpandMem (mechanical summary) */
rsrc_lmgr_0_C2C:
    moveal ExpandMem,%a0
    moveal %a0@(116),%a0
    subqw #2,%sp
    pea %a0@(6)
    _OpenResFile
    movew %sp@+,%d0
    rts

/* subroutine (6 instructions) (mechanical summary) */
rsrc_lmgr_0_C40:
    moveal %sp@(4),%a0
    movel %sp@(8),%d1
    moveml %d3-%d7/%a2-%fp,%sp@-
    jsr %a0@
    moveml %sp@+,%d3-%d7/%a2-%fp
    rts

/* subroutine (21 instructions): traps GetVolInfo, FSDispatch, Open; low memory BootDrive, ExpandMem (mechanical summary) */
rsrc_lmgr_0_C54:
    movel %a3,%sp@-
    subaw #122,%sp
    moveal %sp,%a0
    movew BootDrive,%a0@(22)
    clrw %a0@(28)
    clrl %a0@(18)
    .short  0xA207	| 408E179A _GetVolInfo (flags 0x0200)
    movel %a0@(90),%a0@(48)
    movel #1651663975,%a0@(28)
    moveq #1,%d0
    .short  0xA260	| 408E17AC _FSDispatch (flags 0x0200)
    moveal ExpandMem,%a3
    moveal %a3@(116),%a3
    movew %a0@(22),%a3@(2)
    lea %a3@(6),%a1
    movel %a1,%a0@(18)
    clrb %a0@(27)
    clrl %a0@(28)
    _Open
    movew %a0@(24),%a3@(4)
    lea %sp@(122),%sp
    moveal %sp@+,%a3
    rts

/* subroutine (114 instructions): traps GetIndResource, GetResInfo, OpenRFPerm, Get1IxResource, CloseResFile; calls rsrc_lmgr_0_E0E_BA, rsrc_lmgr_0_1B4A_1A, rsrc_lmgr_0_18CC_14; low memory ResLoad, ResErr (mechanical summary) */
rsrc_lmgr_0_CAC:
    linkw %fp,#-182
    moveml %d4-%d7/%a3-%a4,%sp@-
    movel %fp@(8),%d5
    movew %fp@(18),%d6
    moveal %fp@(20),%a3
    clrb %fp@(-70)
    clrb ResLoad
    moveq #1,%d7
rsrc_lmgr_0_CAC_1E:     /* set up and call _GetIndResource (loop) */
    subql #4,%sp
    movel %d5,%sp@-
    movew %d7,%sp@-
    _GetIndResource
    moveal %sp@+,%a4
    movel %a4,%d0
    jbeq rsrc_lmgr_0_CAC_68
    tstw ResErr
    jbne rsrc_lmgr_0_CAC_68
    movel %a4,%sp@-
    pea %fp@(-38)
    pea %fp@(-36)
    pea %fp@(-32)
    _GetResInfo
    pea %fp@(-70)
    moveq #0,%d0
    movel %d0,%sp@-
    movew %fp@(-38),%d1
    extl %d1
    movel %d1,%sp@-
    movel %fp@(-36),%sp@-
    movel %a3,%sp@-
    jsr %pc@(rsrc_lmgr_0_E0E_BA)
    moveal %d0,%a3
    lea %sp@(20),%sp
    movew %d7,%d0
    addqw #1,%d7
    jbra rsrc_lmgr_0_CAC_1E
rsrc_lmgr_0_CAC_68:     /* set ResLoad */
    moveb #1,ResLoad
    tstb %fp@(16)
    jbne rsrc_lmgr_0_CAC_13E
    moveq #1,%d4
rsrc_lmgr_0_CAC_78:     /* loop: moveq */
    moveq #108,%d0
    movel %d0,%sp@-
    moveq #0,%d1
    movel %d1,%sp@-
    pea %fp@(-180)
    jsr %pc@(rsrc_lmgr_0_1B4A_1A)
    clrb %fp@(-70)
    movew %d6,%fp@(-158)
    lea %fp@(-70),%a0
    movel %a0,%fp@(-162)
    movew %d4,%fp@(-152)
    subql #2,%sp
    pea %fp@(-180)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_18CC_14)
    movew %sp@+,%fp@(-182)
    lea %sp@(12),%sp
    jbne rsrc_lmgr_0_CAC_13E
    movel %fp@(-148),%d0
    cmpl %fp@(12),%d0
    jbne rsrc_lmgr_0_CAC_136
    subql #2,%sp
    pea %fp@(-70)
    movew %d6,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    _OpenRFPerm
    movew %sp@+,%fp@(-72)
    jbeq rsrc_lmgr_0_CAC_136
    tstw ResErr
    jbne rsrc_lmgr_0_CAC_136
    clrb ResLoad
    moveq #1,%d7
rsrc_lmgr_0_CAC_E0:     /* set up and call _Get1IxResource (loop) */
    subql #4,%sp
    movel %d5,%sp@-
    movew %d7,%sp@-
    _Get1IxResource
    moveal %sp@+,%a4
    movel %a4,%d0
    jbeq rsrc_lmgr_0_CAC_12A
    tstw ResErr
    jbne rsrc_lmgr_0_CAC_12A
    movel %a4,%sp@-
    pea %fp@(-38)
    pea %fp@(-36)
    pea %fp@(-32)
    _GetResInfo
    pea %fp@(-70)
    extl %d6
    movel %d6,%sp@-
    movew %fp@(-38),%d0
    extl %d0
    movel %d0,%sp@-
    movel %fp@(-36),%sp@-
    movel %a3,%sp@-
    jsr %pc@(rsrc_lmgr_0_E0E_BA)
    moveal %d0,%a3
    lea %sp@(20),%sp
    movew %d7,%d0
    addqw #1,%d7
    jbra rsrc_lmgr_0_CAC_E0
rsrc_lmgr_0_CAC_12A:    /* set up and call _CloseResFile */
    moveb #1,ResLoad
    movew %fp@(-72),%sp@-
    _CloseResFile
rsrc_lmgr_0_CAC_136:    /* set %d0 */
    movew %d4,%d0
    addqw #1,%d4
    jbra rsrc_lmgr_0_CAC_78
rsrc_lmgr_0_CAC_13E:    /* set %fp@(24) */
    movel %a3,%fp@(24)
    moveml %fp@(-206),%d4-%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(16),%sp
    jmp %a0@

/* subroutine (6 instructions): traps DisposPtr (mechanical summary) */
rsrc_lmgr_0_DFE:
    linkw %fp,#0
    moveal %fp@(8),%a0
    _DisposPtr
    unlk %fp
    movel %sp@+,%sp@
    rts

/* subroutine (68 instructions): traps OpenRFPerm, Get1Resource, GetResource, HLock, CloseResFile; calls rsrc_lmgr_0_B2; low memory ResErr (mechanical summary) */
rsrc_lmgr_0_E0E:
    linkw %fp,#0
    moveml %d4-%d7/%a3-%a4,%sp@-
    movew %fp@(8),%d4
    movew %fp@(10),%d5
    moveal %fp@(12),%a0
    movew %a0@(8),%d6
    jbra rsrc_lmgr_0_E0E_A6
rsrc_lmgr_0_E0E_1C:     /* loop: ext */
    extl %d6
    moveal %fp@(12),%a0
    movel %d6,%d0
    movel %d0,%d1
    muluw #44,%d0
    swap %d1
    muluw #44,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a0@(0xa,%d0:l),%a4
    cmpw %a4@(2),%d5
    jbgt rsrc_lmgr_0_E0E_A4
    cmpw %a4@(2),%d4
    jblt rsrc_lmgr_0_E0E_A4
    clrw %d7
    tstw %a4@(8)
    jbeq rsrc_lmgr_0_E0E_7E
    subql #2,%sp
    pea %a4@(10)
    movew %a4@(8),%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    _OpenRFPerm
    movew %sp@+,%d7
    jbeq rsrc_lmgr_0_E0E_78
    tstw ResErr
    jbne rsrc_lmgr_0_E0E_78
    subql #4,%sp
    movel %a4@(4),%sp@-
    movew %a4@(2),%sp@-
    _Get1Resource
    moveal %sp@+,%a3
    jbra rsrc_lmgr_0_E0E_8C
rsrc_lmgr_0_E0E_78:     /* clear %d0 */
    moveq #0,%d0
    moveal %d0,%a3
    jbra rsrc_lmgr_0_E0E_8C
rsrc_lmgr_0_E0E_7E:     /* set up and call _GetResource */
    subql #4,%sp
    movel %a4@(4),%sp@-
    movew %a4@(2),%sp@-
    _GetResource
    moveal %sp@+,%a3
rsrc_lmgr_0_E0E_8C:     /* set up and call _HLock */
    movel %a3,%d0
    jbeq rsrc_lmgr_0_E0E_9C
    moveal %a3,%a0
    _HLock
    movel %a3@,%sp@-
    jsr %pc@(rsrc_lmgr_0_B2)
    addqw #4,%sp
rsrc_lmgr_0_E0E_9C:     /* set up and call _CloseResFile */
    tstw %d7
    jbeq rsrc_lmgr_0_E0E_A4
    movew %d7,%sp@-
    _CloseResFile
rsrc_lmgr_0_E0E_A4:     /* set %d6 */
    movew %a4@,%d6
rsrc_lmgr_0_E0E_A6:     /* test %d6 */
    tstw %d6
    jbge rsrc_lmgr_0_E0E_1C
    moveml %fp@(-24),%d4-%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* subroutine (117 instructions): traps NewPtr, BlockMove, DisposPtr; calls rsrc_lmgr_0_1B4A_7A (mechanical summary) */
rsrc_lmgr_0_E0E_BA:
    linkw %fp,#-4
    moveml %d5-%d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    movel %a4,%d0
    jbne rsrc_lmgr_0_E0E_EE
    movel #890,%d5
    movel %d5,%d0
    .short  0xA31E	| 408E1A10 _NewPtr (flags 0x0300)
    moveal %a0,%a4
    movel %a4,%d0
    jbne rsrc_lmgr_0_E0E_E0
    moveq #0,%d0
    jbra rsrc_lmgr_0_E0E_214
rsrc_lmgr_0_E0E_E0:     /* set %a4@(8) */
    movew #-1,%a4@(8)
    movel %d5,%a4@
    movew #20,%a4@(6)
rsrc_lmgr_0_E0E_EE:     /* set %d0 */
    movew %a4@(4),%d0
    cmpw %a4@(6),%d0
    jblt rsrc_lmgr_0_E0E_116
    movel %a4@,%d5
    .short  0xDABC, 0x0000, 0x037A	| 408E1A38 addl #890,%d5
    movel %d5,%d0
    .short  0xA31E	| 408E1A40 _NewPtr (flags 0x0300)
    moveal %a0,%a3
    moveal %a4,%a0
    moveal %a3,%a1
    movel %a4@,%d0
    _BlockMove
    movel %d5,%a3@
    moveal %a4,%a0
    _DisposPtr
    moveal %a3,%a4
rsrc_lmgr_0_E0E_116:    /* set %d5 */
    movew %a4@(4),%d5
    extl %d5
    movel %d5,%d0
    movel %d0,%d1
    muluw #44,%d0
    swap %d1
    muluw #44,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a4@(0xa,%d0:l),%a0
    movel %a0,%fp@(-4)
    movew %fp@(18),%a0@(2)
    moveal %fp@(-4),%a0
    movel %fp@(12),%a0@(4)
    moveal %fp@(-4),%a0
    movew %fp@(22),%a0@(8)
    subql #4,%sp
    moveal %fp@(-4),%a0
    pea %a0@(10)
    movel %fp@(24),%sp@-
    jsr %pc@(rsrc_lmgr_0_1B4A_7A)
    tstw %a4@(8)
    addqw #4,%sp
    jbge rsrc_lmgr_0_E0E_17C
    movew %d5,%a4@(8)
    moveal %fp@(-4),%a0
    movew #-1,%a0@
    jbra rsrc_lmgr_0_E0E_20E
rsrc_lmgr_0_E0E_17C:    /* set %d6 */
    moveq #-1,%d6
    movew %a4@(8),%d7
rsrc_lmgr_0_E0E_182:    /* loop: ext */
    extl %d7
    movel %d7,%d0
    movel %d0,%d1
    muluw #44,%d0
    swap %d1
    muluw #44,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a4@(0xa,%d0:l),%a3
    moveal %fp@(-4),%a0
    movew %a0@(2),%d0
    cmpw %a3@(2),%d0
    jbge rsrc_lmgr_0_E0E_1DC
    tstw %d6
    jbge rsrc_lmgr_0_E0E_1B8
    movew %a4@(8),%a0@
    movew %d5,%a4@(8)
    jbra rsrc_lmgr_0_E0E_20E
rsrc_lmgr_0_E0E_1B8:    /* set %a0 */
    moveal %fp@(-4),%a0
    movew %d7,%a0@
    extl %d6
    movel %d6,%d0
    movel %d0,%d1
    muluw #44,%d0
    swap %d1
    muluw #44,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a4@(0xa,%d0:l),%a3
    movew %d5,%a3@
    jbra rsrc_lmgr_0_E0E_20E
rsrc_lmgr_0_E0E_1DC:    /* set %d6 */
    movew %d7,%d6
    movew %a3@,%d7
    jbge rsrc_lmgr_0_E0E_208
    extl %d6
    movel %d6,%d0
    movel %d0,%d1
    muluw #44,%d0
    swap %d1
    muluw #44,%d1
    swap %d1
    clrw %d1
    addl %d1,%d0
    lea %a4@(0xa,%d0:l),%a3
    movew %d5,%a3@
    moveal %fp@(-4),%a0
    movew #-1,%a0@
    jbra rsrc_lmgr_0_E0E_20E
rsrc_lmgr_0_E0E_208:    /* test %d7 */
    tstw %d7
    jbge rsrc_lmgr_0_E0E_182
rsrc_lmgr_0_E0E_20E:    /* add 1 to %a4@(4) */
    addqw #1,%a4@(4)
    movel %a4,%d0
rsrc_lmgr_0_E0E_214:    /* restore registers, return */
    moveml %fp@(-24),%d5-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (30 instructions): traps DetachResource, DrvrInstall; low memory UTableBase (mechanical summary) */
rsrc_lmgr_0_102C:
    linkw %fp,#0
    movel %fp@(8),%sp@-
    _DetachResource
    movel %fp@(12),%d0
    notw %d0
    .short  0xA43D	| 408E1B6C _DrvrInstall (flags 0x0400)
    jbne rsrc_lmgr_0_102C_54
    moveal UTableBase,%a0
    movel %fp@(12),%d1
    lslw #2,%d1
    moveal %a0@(0x0,%d1:w),%a0
    moveal %a0@,%a0
    moveal %fp@(8),%a1
    moveal %a1@,%a1
    movel %a1,%a0@
    movew %a1@,%a0@(4)
    bclr #6,%a0@(5)
    movel %a2,%sp@-
    lea %a1@(18),%a2
    clrw %d0
    moveb %a2@,%d0
    addqw #2,%d0
    andiw #-2,%d0
    moveb %a2@(0x0,%d0:w),%a0@(7)
    moveal %sp@+,%a2
    moveq #0,%d0
    unlk %fp
    rts
rsrc_lmgr_0_102C_54:    /* from here: extl %d0 */
    extl %d0
    unlk %fp
    rts

/* subroutine (37 instructions): traps NewPtr, BlockMove, DisposPtr; calls rsrc_lmgr_0_102C; low memory UnitTableEntryCount, UTableBase (mechanical summary) */
rsrc_lmgr_0_1086:
    linkw %fp,#0
    movew #96,%d1
    cmpw UnitTableEntryCount,%d1
    jble rsrc_lmgr_0_1086_3E
    movew %d1,%d0
    muluw #4,%d0
    .short  0xA71E	| 408E1BCA _NewPtr (flags 0x0700)
    jbne rsrc_lmgr_0_1086_68
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    moveal %a0,%a1
    moveal UTableBase,%a0
    movew UnitTableEntryCount,%d0
    muluw #4,%d0
    _BlockMove
    _DisposPtr
    movel %a1,UTableBase
    movew %d1,UnitTableEntryCount
    movew %sp@+,%sr
rsrc_lmgr_0_1086_3E:    /* set %a1 */
    moveal UTableBase,%a1
    movew #192,%d1
    moveq #48,%d0
rsrc_lmgr_0_1086_48:    /* loop: cmp */
    cmpw UnitTableEntryCount,%d0
    jbgt rsrc_lmgr_0_1086_68
    tstl %a1@(0x0,%d1:w)
    jbeq rsrc_lmgr_0_1086_5A
    addqw #4,%d1
    addqw #1,%d0
    jbra rsrc_lmgr_0_1086_48
rsrc_lmgr_0_1086_5A:    /* set %sp@- */
    movel %d0,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(rsrc_lmgr_0_102C)
    unlk %fp
    rts
rsrc_lmgr_0_1086_68:    /* set %d0 */
    movel 0xffffffff,%d0
    unlk %fp
    rts

/* subroutine (7 instructions): low memory ExpandMem (mechanical summary) */
rsrc_lmgr_0_1086_70:
    moveal ExpandMem,%a0
    moveal %a0@(116),%a0
    movel %sp@(4),%d0
    muluw #16,%d0
    addiw #650,%d0
    movel %a0@(0x8,%d0:w),%d0
    rts

/* subroutine (48 instructions): traps DockingDispatch; calls rsrc_lmgr_0_182A; low memory ATalkHk2 (mechanical summary) */
rsrc_lmgr_0_1110:
    moveml %d1-%d4/%a1-%a2,%sp@-
    clrb %sp@-
    movew #-21929,%sp@-
    jbsr rsrc_lmgr_0_182A
    tstb %sp@+
    jbeq rsrc_lmgr_0_1110_96
    movew #9,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    jbne rsrc_lmgr_0_1110_96
    movel %d1,%d2
    movew #0,%d4
    movew #10,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    jbne rsrc_lmgr_0_1110_96
    subqw #4,%sp
    movel #1936487523,%sp@-
    clrl %sp@-
    _DockingDispatch
    movel %sp@+,%d0
    cmpib #3,%d2
    jble rsrc_lmgr_0_1110_4E
    tstl %d0
    jbne rsrc_lmgr_0_1110_6E
rsrc_lmgr_0_1110_4E:    /* set up and call _DockingDispatch */
    subqw #4,%sp
    movel #1935893283,%sp@-
    clrl %sp@-
    _DockingDispatch
    movel %sp@+,%d3
    cmpib #3,%d2
    jbeq rsrc_lmgr_0_1110_6E
    btst #1,%d3	| 408E1CA2
    bnes rsrc_lmgr_0_1110_4E_1E
    moveq #3,%d2
    jbra rsrc_lmgr_0_1110_6E
rsrc_lmgr_0_1110_4E_1E:
    moveq #1,%d2	| 408E1CAC
rsrc_lmgr_0_1110_6E:    /* test %d1,%d2 */
    cmpb %d1,%d2
    jbeq rsrc_lmgr_0_1110_96
    movel %d2,%sp@-
    movew #0,%d4
    movew #27,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    movew #0,%d4
    movel %sp@+,%d1
    movew #26,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
rsrc_lmgr_0_1110_96:    /* restore registers, return */
    moveml %sp@+,%d1-%d4/%a1-%a2
    rts

/* subroutine (35 instructions): traps SysEnvirons, AliasDispatch, FSDispatch (mechanical summary) */
rsrc_lmgr_0_11AC:
    linkw %fp,#-74
    lea %fp@(-68),%a0
    movew #1,%d0
    _SysEnvirons
    movew %fp@(-64),%d1
    cmpiw #1792,%d1
    jbcs rsrc_lmgr_0_11AC_66
    subqw #2,%sp
    movew #-32768,%sp@-
    movel %fp@(8),%sp@-
    movew #1,%sp@-
    pea %fp@(-70)
    pea %fp@(-74)
    moveq #0,%d0
    _AliasDispatch
    movew %sp@+,%d0
    moveq #0,%d0
    jbne rsrc_lmgr_0_11AC_6A
    lea %fp@(-52),%a0
    movew %fp@(-70),%a0@(22)
    movel %fp@(-74),%a0@(48)
    clrl %a0@(18)
    movel #1635019883,%a0@(28)
    moveq #1,%d0
    .short  0xA260	| 408E1D32 _FSDispatch (flags 0x0200)
    movew %a0@(16),%d0
    moveq #0,%d0
    jbne rsrc_lmgr_0_11AC_6A
    movew %a0@(22),%d0
    jbra rsrc_lmgr_0_11AC_6A
rsrc_lmgr_0_11AC_66:    /* set %d0 */
    movew %fp@(-54),%d0
rsrc_lmgr_0_11AC_6A:    /* return */
    unlk %fp
    moveal %sp@+,%a0
    addqw #4,%sp
    movew %d0,%sp@
    jmp %a0@

/* subroutine (17 instructions): traps SysEnvirons, FSDispatch (mechanical summary) */
rsrc_lmgr_0_11AC_74:
    linkw %fp,#-68
    moveq #0,%d0
    lea %fp@(-68),%a0
    movew #1,%d0
    _SysEnvirons
    movew %fp@(8),%d1
    cmpw %fp@(-54),%d1
    jbeq rsrc_lmgr_0_11AC_9E
    lea %fp@(-52),%a0
    movew %d1,%a0@(22)
    moveq #2,%d0
    .short  0xA260	| 408E1D74 _FSDispatch (flags 0x0200)
    movew %a0@(16),%d0
rsrc_lmgr_0_11AC_9E:    /* return */
    unlk %fp
    moveal %sp@+,%a0
    addqw #2,%sp
    movew %d0,%sp@
    jmp %a0@

/* subroutine (58 instructions): traps Get1Resource, GetResource; calls rsrc_lmgr_0_1308; low memory CurMap, ROMMapInsert, ResErr, SysMap (mechanical summary) */
rsrc_lmgr_0_1254:
    linkw %fp,#-2
    moveml %d1-%d4/%a1-%a3,%sp@-
    movew CurMap,%fp@(-2)
    moveq #0,%d3
    moveq #0,%d4
    movew #1,CurMap
    movew #-1,ROMMapInsert
    clrl %sp@-
    movel %fp@(10),%sp@-
    movew %fp@(8),%sp@-
    _Get1Resource
    moveal %sp@+,%a2
    tstw ResErr
    jbeq rsrc_lmgr_0_1254_34
    subal %a2,%a2
rsrc_lmgr_0_1254_34:    /* set CurMap */
    movew SysMap,CurMap
    clrl %sp@-
    movel %fp@(10),%sp@-
    movew %fp@(8),%sp@-
    _Get1Resource
    moveal %sp@+,%a3
    tstw ResErr
    jbeq rsrc_lmgr_0_1254_50
    subal %a3,%a3
rsrc_lmgr_0_1254_50:    /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a2,%sp@-
    movel %a3,%sp@-
    movel %fp@(10),%sp@-
    bsrw rsrc_lmgr_0_1308
    moveal %sp@+,%a2
    movel %d0,%d3
    movew %fp@(-2),CurMap
    clrl %sp@-
    movel %fp@(10),%sp@-
    movew %fp@(8),%sp@-
    _GetResource
    moveal %sp@+,%a3
    tstw ResErr
    jbeq rsrc_lmgr_0_1254_7E
    subal %a3,%a3
rsrc_lmgr_0_1254_7E:    /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a2,%sp@-
    movel %a3,%sp@-
    movel %fp@(10),%sp@-
    bsrw rsrc_lmgr_0_1308
    moveal %sp@+,%a2
    movel %d0,%d3
    clrw ResErr
    movel %a2,%fp@(14)
    jbne rsrc_lmgr_0_1254_A0
    movew #-192,ResErr
rsrc_lmgr_0_1254_A0:    /* set %a0 */
    moveal %a2,%a0
    movel %d3,%d0
    moveml %sp@+,%d1-%d4/%a1-%a3
    movel %fp@(4),%fp@(10)
    unlk %fp
    addqw #6,%sp
    rts

/* subroutine (49 instructions): traps ReleaseResource; calls rsrc_lmgr_0_1390 (mechanical summary) */
rsrc_lmgr_0_1308:
    linkw %fp,#0
    moveml %d1-%d4/%a1-%a3,%sp@-
    moveal %fp@(16),%a2
    moveal %fp@(12),%a3
    subqw #4,%sp
    movel %a2,%sp@-
    movel %fp@(8),%sp@-
    bsrw rsrc_lmgr_0_1390
    movel %sp@+,%d3
    cmpiw #-32768,%d3
    jbne rsrc_lmgr_0_1308_28
    moveb #0xff,%d3
rsrc_lmgr_0_1308_28:    /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a3,%sp@-
    movel %fp@(8),%sp@-
    bsrw rsrc_lmgr_0_1390
    movel %sp@+,%d4
    cmpiw #-32768,%d4
    jbne rsrc_lmgr_0_1308_40
    moveb #0xff,%d4
rsrc_lmgr_0_1308_40:    /* test %d3,%d4 */
    cmpl %d3,%d4
    jbcs rsrc_lmgr_0_1308_58
    jbeq rsrc_lmgr_0_1308_48
    jbra rsrc_lmgr_0_1308_54
rsrc_lmgr_0_1308_48:    /* set %d0 */
    movel %a2,%d0
    jbne rsrc_lmgr_0_1308_4E
    jbra rsrc_lmgr_0_1308_54
rsrc_lmgr_0_1308_4E:    /* set %d0 */
    movel %a3,%d0
    jbeq rsrc_lmgr_0_1308_66
    jbra rsrc_lmgr_0_1308_58
rsrc_lmgr_0_1308_54:    /* from here: exg %a2,%a3 */
    exg %a2,%a3
    exg %d3,%d4
rsrc_lmgr_0_1308_58:    /* test %a2,%a3 */
    cmpal %a2,%a3
    jbeq rsrc_lmgr_0_1308_66
    cmpaw #0,%a3
    jbeq rsrc_lmgr_0_1308_66
    movel %a3,%sp@-
    _ReleaseResource
rsrc_lmgr_0_1308_66:    /* set %fp@(20) */
    movel %a2,%fp@(20)
    moveal %a2,%a0
    cmpiw #-32513,%d3
    jbne rsrc_lmgr_0_1308_74
    clrb %d3
rsrc_lmgr_0_1308_74:    /* set %d0 */
    movel %d3,%d0
    moveml %sp@+,%d1-%d4/%a1-%a3
    movel %fp@(4),%fp@(16)
    unlk %fp
    lea %sp@(12),%sp
    rts

/* subroutine (84 instructions): traps GetHandleSize; calls rsrc_lmgr_0_1496 (mechanical summary) */
rsrc_lmgr_0_1390:
    linkw %fp,#0
    moveml %d1-%d5/%a1-%a2,%sp@-
    moveq #0,%d4
    tstl %fp@(12)
    jbeq rsrc_lmgr_0_1390_EE
    moveal %fp@(12),%a0
    movel %a0@,%d5
    jbeq rsrc_lmgr_0_1390_EE
    moveal %fp@(12),%a0
    _GetHandleSize
    movel %d0,%d2
    jbmi rsrc_lmgr_0_1390_EE
    moveal %d5,%a2
    cmpil #1146246738,%fp@(8)
    jbeq rsrc_lmgr_0_1390_9A
    cmpil #1701733748,%fp@(8)
    jbeq rsrc_lmgr_0_1390_9A
    cmpil #1953459054,%fp@(8)
    jbeq rsrc_lmgr_0_1390_9A
    cmpil #1717855337,%fp@(8)
    jbeq rsrc_lmgr_0_1390_9A
    cmpil #1685223026,%fp@(8)
    jbeq rsrc_lmgr_0_1390_9A
    cmpil #8,%d2
    jbls rsrc_lmgr_0_1390_EE
    movew %a2@(6),%d4
    addaw %d4,%a2
    addil #11,%d4
    cmpl %d4,%d2
    jbls rsrc_lmgr_0_1390_EE
    moveq #0,%d3
    moveb %a2@,%d3
    asll #8,%d3
    moveb %a2@(1),%d3
    asll #8,%d3
    moveb %a2@(2),%d3
    asll #8,%d3
    moveb %a2@(3),%d3
    clrw %sp@-
    movel %a2,%sp@-
    bsrw rsrc_lmgr_0_1496
    tstw %sp@+
    jbne rsrc_lmgr_0_1390_F0
    jbra rsrc_lmgr_0_1390_EE
rsrc_lmgr_0_1390_9A:    /* set %d4 */
    movew #18,%d4
    cmpl %d4,%d2
    jbls rsrc_lmgr_0_1390_EE
    moveq #0,%d0
    moveb %a2@(0x0,%d4:w),%d0
    addqw #1,%d0
    btst #0,%d0
    jbeq rsrc_lmgr_0_1390_B2
    addqw #1,%d0
rsrc_lmgr_0_1390_B2:    /* from here: addw %d0,%d4 */
    addw %d0,%d4
    addaw %d4,%a2
    addil #11,%d4
    cmpl %d4,%d2
    jbls rsrc_lmgr_0_1390_EE
    moveq #0,%d3
    moveb %a2@,%d3
    asll #8,%d3
    moveb %a2@(1),%d3
    asll #8,%d3
    moveb %a2@(2),%d3
    asll #8,%d3
    moveb %a2@(3),%d3
    clrw %sp@-
    movel %a2,%sp@-
    bsrw rsrc_lmgr_0_1496
    tstw %sp@+
    jbne rsrc_lmgr_0_1390_EC
    movew %a2@,%d3
    clrb %d3
    swap %d3
    movew #-32768,%d3
rsrc_lmgr_0_1390_EC:    /* continue at rsrc_lmgr_0_1390_F0 */
    jbra rsrc_lmgr_0_1390_F0
rsrc_lmgr_0_1390_EE:    /* clear %d3 */
    moveq #0,%d3
rsrc_lmgr_0_1390_F0:    /* set %fp@(16) */
    movel %d3,%fp@(16)
    movel %d3,%d0
    moveml %sp@+,%d1-%d5/%a1-%a2
    movel %fp@(4),%fp@(12)
    unlk %fp
    addqw #8,%sp
    rts

/* subroutine (52 instructions): calls rsrc_lmgr_0_1534 (mechanical summary) */
rsrc_lmgr_0_1496:
    linkw %fp,#-16
    moveml %d1-%d4/%a1-%a2,%sp@-
    tstl %fp@(8)
    jbeq rsrc_lmgr_0_1496_84
    moveal %fp@(8),%a2
    moveq #0,%d3
    moveb %a2@,%d3
    asll #8,%d3
    moveb %a2@(1),%d3
    asll #8,%d3
    moveb %a2@(2),%d3
    asll #8,%d3
    moveb %a2@(3),%d3
    lea %fp@(-16),%a0
    movel %d3,%d0
    swap %d0
    lsrw #8,%d0
    andil #255,%d0
    bsrw rsrc_lmgr_0_1534
    moveq #0,%d0
    moveb %a0@+,%d0
    addaw %d0,%a0
    movel %d3,%d0
    swap %d0
    lsrw #4,%d0
    andil #15,%d0
    bsrw rsrc_lmgr_0_1534
    lea %fp@(-16),%a0
    moveq #0,%d0
    moveb %a0@,%d0
    addqw #1,%d0
    moveb #46,%a0@(0x0,%d0:w)
    movel %a0@,%d0
    andil #16777215,%d0
    lea %a2@(6),%a0
    moveq #0,%d1
    moveb %a0@(1),%d1
    asll #8,%d1
    moveb %a0@(2),%d1
    asll #8,%d1
    moveb %a0@(3),%d1
    cmpl %d0,%d1
    jbeq rsrc_lmgr_0_1496_88
rsrc_lmgr_0_1496_84:    /* result 0 */
    moveq #0,%d0
    jbra rsrc_lmgr_0_1496_8A
rsrc_lmgr_0_1496_88:    /* set %d0 */
    moveq #1,%d0
rsrc_lmgr_0_1496_8A:    /* set %fp@(12) */
    movew %d0,%fp@(12)
    moveml %sp@+,%d1-%d4/%a1-%a2
    movel %fp@(4),%fp@(8)
    unlk %fp
    addqw #4,%sp
    rts

/* subroutine (24 instructions) (mechanical summary) */
rsrc_lmgr_0_1534:
    movel %d0,%sp@-
    divuw #100,%d0
    addib #48,%d0
    moveb %d0,%a0@(1)
    swap %d0
    extl %d0
    divuw #10,%d0
    addib #48,%d0
    moveb %d0,%a0@(2)
    swap %d0
    addib #48,%d0
    moveb %d0,%a0@(3)
    moveb #3,%a0@
    cmpib #48,%a0@(1)
    jbne rsrc_lmgr_0_1534_56
    moveb #2,%a0@
    moveb %a0@(2),%a0@(1)
    moveb %a0@(3),%a0@(2)
    cmpib #48,%a0@(1)
    jbne rsrc_lmgr_0_1534_56
    moveb #1,%a0@
    moveb %a0@(2),%a0@(1)
rsrc_lmgr_0_1534_56:    /* set %d0 */
    movel %sp@+,%d0
    rts

/* subroutine (25 instructions): traps GetResource, DetachResource, CloseResFile; calls rsrc_lmgr_0_15CE (mechanical summary) */
rsrc_lmgr_0_158E:
    movew #-1,%sp@-
    clrl %sp@-
    subaw #32,%sp
    moveal %sp,%a1
    jbsr rsrc_lmgr_0_15CE
    lea %sp@(32),%sp
    movew %d0,%sp@(4)
    jbne rsrc_lmgr_0_158E_3A
    subqw #4,%sp
    movel #1635019883,%sp@-
    movew %d1,%sp@-
    clrb %sp@
    _GetResource
    movel %sp@+,%d0
    jbeq rsrc_lmgr_0_158E_36
    movel %d0,%sp@
    clrw %sp@(4)
    movel %d0,%sp@-
    _DetachResource
    jbra rsrc_lmgr_0_158E_3A
rsrc_lmgr_0_158E_36:    /* set up and call _CloseResFile */
    movew %d2,%sp@-
    _CloseResFile
rsrc_lmgr_0_158E_3A:    /* set %a0 */
    moveal %sp@+,%a0
    movew %sp@+,%d0
    rts

/* subroutine (57 instructions): traps GetFileInfo, OpenRFPerm, Get1Resource, CloseResFile; calls rsrc_lmgr_0_11AC, rsrc_lmgr_0_11AC_74; low memory ResLoad, ResErr (mechanical summary) */
rsrc_lmgr_0_15CE:
    movew ResLoad,%sp@-
    clrw ResLoad
    moveml %d1/%a1,%sp@-
    subqw #2,%sp
    movel #1702392942,%sp@-
    jbsr rsrc_lmgr_0_11AC
    movew %sp@+,%d0
    moveml %sp@+,%d1/%a1
    movew %d0,%sp@-
    subaw #122,%sp
    moveal %sp,%a2
    movew %d0,%a2@(22)
    movel %a1,%a2@(18)
    clrw %a2@(28)
    tstb %d1
    jbne rsrc_lmgr_0_15CE_3A
    movew %d3,%a2@(28)
rsrc_lmgr_0_15CE_3A:    /* set up and call _GetFileInfo (loop) */
    moveal %a2,%a0
    clrw %a0@(26)
    addqw #1,%a0@(28)
    _GetFileInfo
    jbne rsrc_lmgr_0_15CE_8A
    movel %a0@(32),%d0
    cmpil #1633969526,%d0
    jbne rsrc_lmgr_0_15CE_3A
    clrw %sp@-
    movel %a1,%sp@-
    movew %a0@(22),%sp@-
    clrb %sp@-
    _OpenRFPerm
    movew %sp@+,%d2
    movew ResErr,%d0
    jbne rsrc_lmgr_0_15CE_3A
    tstb %d1
    jbeq rsrc_lmgr_0_15CE_86
    subqw #4,%sp
    movel #1635019883,%sp@-
    movew %d1,%sp@-
    clrb %sp@
    _Get1Resource
    moveq #0,%d0
    tstl %sp@+
    jbne rsrc_lmgr_0_15CE_8A
    movew %d2,%sp@-
    _CloseResFile
    jbra rsrc_lmgr_0_15CE_3A
rsrc_lmgr_0_15CE_86:    /* set %d3 */
    movew %a2@(28),%d3
rsrc_lmgr_0_15CE_8A:    /* address %sp@(122) */
    lea %sp@(122),%sp
    moveml %d0-%d2,%sp@-
    subqw #2,%sp
    movew %sp@(14),%sp@-
    jbsr rsrc_lmgr_0_11AC_74
    movew %sp@+,%d0
    moveml %sp@+,%d0-%d2
    addqw #2,%sp
    movew %sp@+,ResLoad
    rts

/* subroutine (41 instructions): traps CloseResFile; calls rsrc_lmgr_0_1254, rsrc_lmgr_0_158E, rsrc_lmgr_0_1308 (mechanical summary) */
rsrc_lmgr_0_1678:
    linkw %fp,#0
    moveml %d1-%d2/%a1,%sp@-
    moveal %fp@(10),%a1
    clrw %a1@
    clrw %d1
    moveb %fp@(9),%d1
    subqw #4,%sp
    movel #1635019883,%sp@-
    movew %d1,%sp@-
    jbsr rsrc_lmgr_0_1254
    jbsr rsrc_lmgr_0_158E
    tstw %d0
    jbne rsrc_lmgr_0_1678_60
    moveal %sp@+,%a1
    movew %d2,%sp@-
    movel %a0,%sp@-
    subqw #4,%sp
    movel %a1,%sp@-
    movel %a0,%sp@-
    movel #1635019883,%sp@-
    jbsr rsrc_lmgr_0_1308
    movel %sp@+,%d0
    moveal %sp@+,%a0
    movew %sp@+,%d2
    moveal %fp@(10),%a1
    cmpl %a0,%d0
    jbne rsrc_lmgr_0_1678_56
    movew %d2,%a1@
rsrc_lmgr_0_1678_50:    /* loop: move */
    movel %d0,%fp@(14)
    jbra rsrc_lmgr_0_1678_64
rsrc_lmgr_0_1678_56:    /* set up and call _CloseResFile */
    movel %d0,%sp@-
    movew %d2,%sp@-
    _CloseResFile
    movel %sp@+,%d0
    jbra rsrc_lmgr_0_1678_50
rsrc_lmgr_0_1678_60:    /* set %fp@(14) */
    movel %sp@+,%fp@(14)
rsrc_lmgr_0_1678_64:    /* restore registers, return */
    moveml %sp@+,%d1-%d2/%a1
    movel %fp@(4),%fp@(10)
    unlk %fp
    addqw #6,%sp
    rts

/* subroutine (16 instructions): traps DockingDispatch; calls rsrc_lmgr_0_182A (mechanical summary) */
rsrc_lmgr_0_16EC:
    moveml %d1-%d2/%a1-%a2,%sp@-
    clrb %sp@-
    movew #-21929,%sp@-
    jbsr rsrc_lmgr_0_182A
    tstb %sp@+
    jbeq rsrc_lmgr_0_16EC_26
    subqw #4,%sp
    movel #1935893283,%sp@-
    clrl %sp@-
    _DockingDispatch
    movel %sp@+,%d0
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts
rsrc_lmgr_0_16EC_26:    /* set %d0 */
    moveq #3,%d0
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts

/* subroutine (8 instructions): traps ReadXPRam; low memory HWCfgFlags (mechanical summary) */
rsrc_lmgr_0_171A:
    clrl %sp@-
    btst #14,HWCfgFlags
    jbeq rsrc_lmgr_0_171A_14
    moveal %sp,%a0
    movel #262368,%d0
    _ReadXPRam
rsrc_lmgr_0_171A_14:    /* set %d0 */
    movel %sp@+,%d0
    rts

/* subroutine (26 instructions): calls rsrc_lmgr_0_171A, rsrc_lmgr_0_16EC (mechanical summary) */
rsrc_lmgr_0_1732:
    bsrw rsrc_lmgr_0_171A
    tstl %d0
    jbne rsrc_lmgr_0_1732_A
    moveq #1,%d0
rsrc_lmgr_0_1732_A:     /* test #1,%d0 */
    cmpib #1,%d0
    jbeq rsrc_lmgr_0_1732_16
    cmpib #3,%d0
    jbne rsrc_lmgr_0_1732_4A
rsrc_lmgr_0_1732_16:    /* save registers */
    moveml %d0-%d2/%a1-%a2,%sp@-
    bsrw rsrc_lmgr_0_16EC
    andiw #3,%d0
    cmpiw #3,%d0
    jbeq rsrc_lmgr_0_1732_46
    btst #0,%d0
    moveml %sp@+,%d0-%d2/%a1-%a2
    jbne rsrc_lmgr_0_1732_3C
    cmpib #1,%d0
    jbeq rsrc_lmgr_0_1732_4A
    moveq #1,%d0
    rts
rsrc_lmgr_0_1732_3C:    /* test #3,%d0 */
    cmpib #3,%d0
    jbeq rsrc_lmgr_0_1732_4A
    moveq #3,%d0
    rts
rsrc_lmgr_0_1732_46:    /* restore registers */
    moveml %sp@+,%d0-%d2/%a1-%a2
rsrc_lmgr_0_1732_4A:    /* return */
    rts

/* subroutine (8 instructions): traps WriteXPRam (mechanical summary) */
rsrc_lmgr_0_177E:
    movel %d0,%sp@-
    movel %a0,%sp@-
    lea %sp@(12),%a0
    movel #262368,%d0
    _WriteXPRam
    moveal %sp@+,%a0
    movel %sp@+,%d0
    rts

/* subroutine (19 instructions): calls rsrc_lmgr_0_16EC, rsrc_lmgr_0_177E (mechanical summary) */
rsrc_lmgr_0_1794:
    linkw %fp,#0
    moveml %d0-%d2/%a0-%a2,%sp@-
    jbsr rsrc_lmgr_0_16EC
    andiw #3,%d0
    cmpiw #3,%d0
    jbeq rsrc_lmgr_0_1794_2E
    btst #0,%d0
    jbne rsrc_lmgr_0_1794_26
    cmpib #1,%fp@(11)
    jbeq rsrc_lmgr_0_1794_38
    jbra rsrc_lmgr_0_1794_2E
rsrc_lmgr_0_1794_26:    /* test #3,%fp@(11) */
    cmpib #3,%fp@(11)
    jbeq rsrc_lmgr_0_1794_38
rsrc_lmgr_0_1794_2E:    /* set %sp@- */
    movel %fp@(8),%sp@-
    bsrw rsrc_lmgr_0_177E
    addqw #4,%sp
rsrc_lmgr_0_1794_38:    /* set %d0-%d2/%a0-%a2 */
    moveml %sp@,%d0-%d2/%a0-%a2
    unlk %fp
    rts

/* subroutine (12 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_lmgr_0_17D4:
    linkw %fp,#0
    movel %d4,%sp@-
    movel %fp@(8),%d4
    movel %fp@(12),%d1
    moveq #26,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    movel %sp@+,%d4
    moveal %fp@(16),%a0
    movel %d1,%a0@
    unlk %fp
    rts

/* subroutine (7 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_lmgr_0_17F8:
    movel %d4,%sp@-
    movel %sp@(8),%d4
    moveq #27,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    movel %sp@+,%d4
    rts

/* subroutine (5 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_lmgr_0_180C:
    movel %sp@(8),%d1
    moveq #30,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    rts

/* subroutine (5 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_lmgr_0_181C:
    moveq #32,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    movel %d1,%d0
    rts

/* subroutine (59 instructions): calls rsrc_lmgr_0_18CC (mechanical summary) */
rsrc_lmgr_0_182A:
    linkw %fp,#0
    moveml %d6-%d7,%sp@-
    movew %fp@(8),%d7
    movew #2048,%d0
    andw %d7,%d0
    jbeq rsrc_lmgr_0_182A_18
    moveq #1,%d0
    jbra rsrc_lmgr_0_182A_1A
rsrc_lmgr_0_182A_18:    /* clear %d0 */
    moveq #0,%d0
rsrc_lmgr_0_182A_1A:    /* set %d6 */
    moveb %d0,%d6
    moveq #0,%d0
    moveb %d6,%d0
    cmpiw #1,%d0
    jbne rsrc_lmgr_0_182A_6C
    movew #2047,%d0
    andw %d7,%d0
    movew %d0,%d7
    extl %d7
    subql #4,%sp
    movew #-22418,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_18CC)
    subql #4,%sp
    movew #-21906,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_18CC)
    movel %sp@+,%d0
    cmpl %sp@+,%d0
    jbne rsrc_lmgr_0_182A_5A
    movel #512,%d0
    jbra rsrc_lmgr_0_182A_60
rsrc_lmgr_0_182A_5A:    /* set %d0 */
    movel #1024,%d0
rsrc_lmgr_0_182A_60:    /* from here: extl %d0 */
    extl %d0
    cmpw %d7,%d0
    jbgt rsrc_lmgr_0_182A_6C
    clrb %fp@(10)
    jbra rsrc_lmgr_0_182A_94
rsrc_lmgr_0_182A_6C:    /* subtract 4 to %sp */
    subql #4,%sp
    movew %d7,%sp@-
    moveb %d6,%sp@-
    jsr %pc@(rsrc_lmgr_0_18CC)
    subql #4,%sp
    movew #-22369,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_lmgr_0_18CC)
    movel %sp@+,%d0
    cmpl %sp@+,%d0
    sne %d0
    andiw #1,%d0
    extl %d0
    moveb %d0,%fp@(10)
rsrc_lmgr_0_182A_94:    /* restore registers, return */
    moveml %fp@(-8),%d6-%d7
    unlk %fp
    moveal %sp@+,%a0
    addqw #2,%sp
    jmp %a0@

/* subroutine (8 instructions): traps GetTrapAddress (mechanical summary) */
rsrc_lmgr_0_18CC:
    moveal %sp@+,%a1
    moveb %sp@+,%d1
    movew %sp@+,%d0
    tstb %d1
    jbeq rsrc_lmgr_0_18CC_E
    .short  0xA746	| 408E2406 _GetTrapAddress (flags 0x0700)
    jbra rsrc_lmgr_0_18CC_10
rsrc_lmgr_0_18CC_E:     /* (_GetTrapAddress (flags 0x0300)) */
    .short  0xA346	| 408E240A _GetTrapAddress (flags 0x0300)
rsrc_lmgr_0_18CC_10:    /* set %sp@ */
    movel %a0,%sp@
    jmp %a1@

/* subroutine (9 instructions): traps FSDispatch (mechanical summary) */
rsrc_lmgr_0_18CC_14:
    moveal %sp@+,%a1
    moveb %sp@+,%d0
    moveal %sp@+,%a0
    jbne rsrc_lmgr_0_18CC_22
    moveq #9,%d0
    .short  0xA260	| 408E241A _FSDispatch (flags 0x0200)
    jbra rsrc_lmgr_0_18CC_26
rsrc_lmgr_0_18CC_22:    /* set %d0 */
    moveq #9,%d0
    .short  0xA660	| 408E2420 _FSDispatch (flags 0x0600)
rsrc_lmgr_0_18CC_26:    /* set %sp@ */
    movew %d0,%sp@
    jmp %a1@

/* subroutine (29 instructions): traps GetResource, BlockMove (mechanical summary) */
rsrc_lmgr_0_18F6:
    linkw %fp,#0
    subqw #4,%sp
    movel #1398034979,%sp@-
    movew %fp@(10),%sp@-
    _GetResource
    moveal %fp@(12),%a1
    clrb %a1@
    movel %sp@+,%d0
    jbeq rsrc_lmgr_0_18F6_3E
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %a0@+,%d0
    movew %fp@(8),%d1
    jbeq rsrc_lmgr_0_18F6_3E
    cmpw %d0,%d1
    jbhi rsrc_lmgr_0_18F6_3E
    moveq #0,%d0
rsrc_lmgr_0_18F6_2E:    /* loop: subq */
    subqw #1,%d1
    jbeq rsrc_lmgr_0_18F6_38
    moveb %a0@+,%d0
    addal %d0,%a0
    jbra rsrc_lmgr_0_18F6_2E
rsrc_lmgr_0_18F6_38:    /* set up and call _BlockMove */
    moveb %a0@,%d0
    addqw #1,%d0
    _BlockMove
rsrc_lmgr_0_18F6_3E:    /* return */
    unlk %fp
    moveal %sp@+,%a0
    addql #8,%sp
    jmp %a0@

/* subroutine (40 instructions): traps GetTrapAddress, Gestalt; calls rsrc_lmgr_0_1A5D (mechanical summary) */
rsrc_lmgr_0_193C:
    linkw %fp,#0
    movel #43167,%d0
    .short  0xA746	| 408E2476 _GetTrapAddress (flags 0x0700)
    movel %a0,%sp@-
    movel #41133,%d0
    .short  0xA346	| 408E2480 _GetTrapAddress (flags 0x0300)
    cmpal %sp@+,%a0
    jbeq rsrc_lmgr_0_193C_28
    movel %fp@(12),%d0
    .short  0xA1AD	| 408E248A _Gestalt (flags 0x0100)
    moveal %fp@(8),%a1
    movel %a0,%a1@
    jbra rsrc_lmgr_0_193C_4E
rsrc_lmgr_0_193C_28:    /* address %pc@(rsrc_lmgr_0_199C) */
    lea %pc@(rsrc_lmgr_0_199C),%a0
    movew #-5551,%d0
    movel %fp@(12),%d1
rsrc_lmgr_0_193C_34:    /* loop: cmp */
    cmpl %a0@+,%d1
    jbeq rsrc_lmgr_0_193C_3E
    tstl %a0@+
    jbeq rsrc_lmgr_0_193C_4E
    jbra rsrc_lmgr_0_193C_34
rsrc_lmgr_0_193C_3E:    /* address %pc@(rsrc_lmgr_0_199C) */
    lea %pc@(rsrc_lmgr_0_199C),%a1
    addal %a0@,%a1
    jmp %a1@
rsrc_lmgr_0_193C_46:    /* loop: movea */
    moveal %fp@(8),%a1
    movel %d0,%a1@
    clrw %d0
rsrc_lmgr_0_193C_4E:    /* set %fp@(16) */
    movew %d0,%fp@(16)
    unlk %fp
    moveal %sp@+,%a0
    addql #8,%sp
    jmp %a0@
rsrc_lmgr_0_193C_4E_C:
    movew #-5550,%d0
    bras rsrc_lmgr_0_193C_4E
rsrc_lmgr_0_199C:       /* string "vers" */
    .ascii  "vers"	| 408E24CC
    .byte   0x00, 0x00, 0x00, 0x60	| 408E24D0
    .ascii  "mach"	| 408E24D4
    .byte   0x00, 0x00, 0x00, 0x64	| 408E24D8
    .ascii  "sysv"	| 408E24DC
    .byte   0x00, 0x00, 0x00, 0x88	| 408E24E0
    .ascii  "proc"	| 408E24E4
    .byte   0x00, 0x00, 0x00, 0x92	| 408E24E8
    .ascii  "fpu "	| 408E24EC
    .byte   0x00, 0x00, 0x00, 0x9E	| 408E24F0
    .ascii  "qd  "	| 408E24F4
    .byte   0x00, 0x00, 0x00, 0xE8	| 408E24F8
    .ascii  "kbd "	| 408E24FC
    .byte   0x00, 0x00, 0x01, 0x1A	| 408E2500
    .ascii  "atlk"	| 408E2504
    .byte   0x00, 0x00, 0x01, 0x42	| 408E2508
    .ascii  "mmu "	| 408E250C
    .short  0x0000, 0x0164	| orib #100,%d0
    moveq #97,%d1
    jblt rsrc_lmgr_0_1A08
    .short  0x0000, 0x0188	| orib #0x88,%d0
    jbge rsrc_lmgr_0_1A60
    jbsr rsrc_lmgr_0_1A5D
    .short  0x0000, 0x0188	| orib #0x88,%d0
    .long   0x00000000, 0x00000000	| 408E2524
    moveq #1,%d0
    jbra rsrc_lmgr_0_193C_46
    .long   0x227802AE, 0x70040C69	| 408E2530
rsrc_lmgr_0_1A08:       /* from here: oriw #8,%a5@(0x0,%d6:w:8)@(0xc69) */
    oriw #8,%a5@(0x0,%d6:w:8)@(0xc69)
    andiw #8,%fp@(0x4,%d6:w:8)
    addqw #1,%d0
    jbra rsrc_lmgr_0_1A20
    .short  0x1038, 0x0CB3, 0x5C80	| 408E254A
rsrc_lmgr_0_1A20:       /* continue at rsrc_lmgr_0_193C_46 */
    jbra rsrc_lmgr_0_193C_46
    moveq #0,%d0
    movew SysVersion,%d0
    braw rsrc_lmgr_0_193C_46
    moveq #0,%d0
    moveb CPUFlag,%d0
    addqw #1,%d0
    braw rsrc_lmgr_0_193C_46
    cmpib #4,CPUFlag
    beqs rsrc_lmgr_0_1A76_4
    btst #4,HWCfgFlags
    beqs rsrc_lmgr_0_1A76_8
    moveal %sp,%a0
    fnop
    .byte   0xF3, 0x27, 0x30, 0x17, 0x2E, 0x48, 0x0C, 0x40, 0x1F, 0x18, 0x67, 0x16, 0x0C	| 408E2580

/* subroutine (29 instructions): low memory CPUFlag (mechanical summary) */
rsrc_lmgr_0_1A5D:
    .byte   0x40, 0x3F, 0x18	| 408E258D
rsrc_lmgr_0_1A60:       /* from here: jbeq rsrc_lmgr_0_1A72 */
    jbeq rsrc_lmgr_0_1A72
    cmpiw #16184,%d0
    jbeq rsrc_lmgr_0_1A76
    cmpiw #7992,%d0
    jbeq rsrc_lmgr_0_1A76
    moveq #0,%d0
    jbra rsrc_lmgr_0_1A80
rsrc_lmgr_0_1A72:       /* result 1 */
    moveq #1,%d0
    jbra rsrc_lmgr_0_1A80
rsrc_lmgr_0_1A76:       /* result 2 */
    moveq #2,%d0
    jbra rsrc_lmgr_0_1A80
rsrc_lmgr_0_1A76_4:
    moveq #3,%d0
    jbra rsrc_lmgr_0_1A80
rsrc_lmgr_0_1A76_8:
    moveq #0,%d0	| 408E25AE
rsrc_lmgr_0_1A80:       /* continue at rsrc_lmgr_0_193C_46 */
    jbra rsrc_lmgr_0_193C_46
    cmpiw #16383,ROM85
    bgts rsrc_lmgr_0_1A80_28
    movew #-22369,%d0
    .short  0xA746	| 408E25C0 _GetTrapAddress (flags 0x0700)
    movel %a0,%d2
    movel #43779,%d0
    .short  0xA746	| _GetTrapAddress (flags 0x0700)
    movel #256,%d0
    cmpl %a0,%d2
    bnes rsrc_lmgr_0_1A80_2C
    bras rsrc_lmgr_0_1AB2
rsrc_lmgr_0_1A80_28:
    moveq #0,%d0
    jbra rsrc_lmgr_0_1AB2
rsrc_lmgr_0_1A80_2C:
    movel #512,%d0	| 408E25DC
rsrc_lmgr_0_1AB2:       /* continue at rsrc_lmgr_0_193C_46 */
    jbra rsrc_lmgr_0_193C_46
    moveb KbdType,%d0
    lea %pc@(rsrc_lmgr_0_1AB2_20),%a0
    moveal %a0,%a1
rsrc_lmgr_0_1AB2_E:
    moveb %a0@+,%d1
    beqw rsrc_lmgr_0_193C_4E_C
    cmpb %d0,%d1
    bnes rsrc_lmgr_0_1AB2_E
    subal %a1,%a0
    movel %a0,%d0
    braw rsrc_lmgr_0_193C_46
rsrc_lmgr_0_1AB2_20:
    btst %d1,%a3@
    btst %d5,%d2
    btst %d0,%d6
    btst %d3,%d4
    movepw %a0@(2304),%d2
    moveq #0,%d0
    tstb PortBUse
    bmis rsrc_lmgr_0_1AB2_4A
    moveb SPConfig,%d1
    andib #15,%d1
    cmpib #1,%d1
    bnes rsrc_lmgr_0_1AB2_4A
    moveal ABusVars_dce,%a0
    moveb %a0@(7),%d0
rsrc_lmgr_0_1AB2_4A:
    braw rsrc_lmgr_0_193C_46
    cmpib #2,CPUFlag
    jblt rsrc_lmgr_0_1B1E
    moveq #0,%d0
    moveb MMUType,%d0
    cmpib #1,%d0
    jbeq rsrc_lmgr_0_1B20
    cmpib #3,%d0
    jblt rsrc_lmgr_0_1B1E
    subqw #1,%d0
    jbra rsrc_lmgr_0_1B20
rsrc_lmgr_0_1B1E:       /* clear %d0 */
    moveq #0,%d0
rsrc_lmgr_0_1B20:       /* continue at rsrc_lmgr_0_193C_46 */
    jbra rsrc_lmgr_0_193C_46
    movew #-22369,%d0
    .short  0xA746	| 408E2658 _GetTrapAddress (flags 0x0700)
    movel %a0,%d2
    movel #43151,%d0
    .short  0xA746	| _GetTrapAddress (flags 0x0700)
    movel MemTop,%d0
    cmpl %a0,%d2
    beqs rsrc_lmgr_0_1B20_26
    subql #4,%sp
    movew #22,%sp@-
    _OSDispatch
    movel %sp@+,%d0
rsrc_lmgr_0_1B20_26:
    braw rsrc_lmgr_0_193C_46

/* subroutine (10 instructions): traps StripAddress; low memory ROM85, Lo3Bytes (mechanical summary) */
rsrc_lmgr_0_1B4A:
    moveal %sp@+,%a1
    movel %sp@+,%d0
    btst #6,ROM85
    jbne rsrc_lmgr_0_1B4A_12
    _StripAddress
    movel %d0,%sp@
    jmp %a1@
rsrc_lmgr_0_1B4A_12:    /* from here: andl Lo3Bytes,%d0 */
    andl Lo3Bytes,%d0
    movel %d0,%sp@
    jmp %a1@

/* subroutine (35 instructions) (mechanical summary) */
rsrc_lmgr_0_1B4A_1A:
    moveal %sp@(4),%a0
    moveml %sp@(8),%d0-%d1
    cmpil #19,%d1
    jblt rsrc_lmgr_0_1B4A_66
    moveq #0,%d2
    moveb %d0,%d2
    lslw #8,%d0
    orw %d0,%d2
    movel %d2,%d0
    swap %d2
    orl %d2,%d0
    movel %a0,%d2
    lsrb #1,%d2
    jbcc rsrc_lmgr_0_1B4A_44
    moveb %d0,%a0@+
    subql #1,%d1
rsrc_lmgr_0_1B4A_44:    /* from here: lsrb #1,%d2 */
    lsrb #1,%d2
    jbcc rsrc_lmgr_0_1B4A_4C
    movew %d0,%a0@+
    subql #2,%d1
rsrc_lmgr_0_1B4A_4C:    /* set %d2 */
    movel %d1,%d2
    lsrl #4,%d2
    subql #1,%d2
rsrc_lmgr_0_1B4A_52:    /* loop: move */
    movel %d0,%a0@+
    movel %d0,%a0@+
    movel %d0,%a0@+
    movel %d0,%a0@+
    subql #1,%d2
    jbcc rsrc_lmgr_0_1B4A_52
    andiw #15,%d1
    jbra rsrc_lmgr_0_1B4A_66
rsrc_lmgr_0_1B4A_64:    /* loop: move */
    moveb %d0,%a0@+
rsrc_lmgr_0_1B4A_66:    /* count down */
    dbf %d1,rsrc_lmgr_0_1B4A_64
    movel %sp@(4),%d0
    rts
    .byte   0x86	| 408E26EA
    .ascii  "memset\000\000\000"

/* subroutine (13 instructions): low memory PLStrCpy (mechanical summary) */
rsrc_lmgr_0_1B4A_7A:
    movel %sp@+,%d0
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    movel %a0,%sp@
    movel %d0,%sp@-
    moveq #0,%d0
    moveb %a1@+,%d0
    moveb %d0,%a0@+
    jbra rsrc_lmgr_0_1B4A_8E
rsrc_lmgr_0_1B4A_8C:    /* loop: move */
    moveb %a1@+,%a0@+
rsrc_lmgr_0_1B4A_8E:    /* count down */
    dbf %d0,rsrc_lmgr_0_1B4A_8C
    rts
    .byte   0x88	| 408E270E
    .ascii  "PLStrCpy\000"
    .byte   0x00, 0x00	| 408E2718
    FILL_408E271A
