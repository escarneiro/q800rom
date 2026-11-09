/* ROM resource 'WDEF' 0: map entry at 0x408768C0, data at 0x408768F0, 2112 bytes

 Window definition 0: the standard document window and dialog boxes (window definition
 IDs 0-15: documentProc, dBoxProc, plainDBox, altDBoxProc, noGrowDocProc, movableDBoxProc;
 +8 adds the zoom box). The low 2 bits of the variation pick the frame style (d5), bit 3
 the zoom box (d6). Messages 0-6 dispatch through rsrc_WDEF_0_FC. On Color QuickDraw
 (ROM85) the colours come from the window's auxiliary record ('wctb'). Comments inferred
 from the code (and the window definition messages in Inside Macintosh).
*/

rsrc_WDEF_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 408768C0
    .long   rsrc_accl_0_entry-rom_start	| 408768C8
    .long   rsrc_WDEF_0-rom_start	| 408768CC
    .ascii  "WDEF"	| 408768D0
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408768D4
    .long   0x00000000, 0xC0A00000, 0x0000084C, 0x00000114	| 408768E0

/* Entry: a branch over the standard header ('WDEF', ID 0). */
rsrc_WDEF_0:
    jbra rsrc_WDEF_0_C
    .short  0x0000, 0x5744, 0x4546, 0x0000, 0x000B	| 408768F2

rsrc_WDEF_0_C:          /* WindowDefProc(varCode, theWindow, message, param): set up the port and colours, title bar height from the font (at least 19), a work region, call the routine for the message, restore */
    linkw %fp,#-34
    moveml %d3-%d7/%a1-%a4,%sp@-
    cmpiw #6,%fp@(12)
    jbgt rsrc_WDEF_0_C_E2
    cmpiw #0,%fp@(12)
    jbmi rsrc_WDEF_0_C_E2
    moveal %a5@,%a0
    movel %a0@,%sp@-
    cmpiw #16383,ROM85
    sls %fp@(-34)
    jbhi rsrc_WDEF_0_C_32
    jbsr rsrc_WDEF_0_10A
    jbra rsrc_WDEF_0_C_38
rsrc_WDEF_0_C_32:       /* set up and call _SetPort */
    movel WMgrPort,%sp@-
    _SetPort
rsrc_WDEF_0_C_38:       /* set up and call _GetFontInfo */
    lea %fp@(-8),%a3
    movel %a3,%sp@-
    _GetFontInfo
    movew %a3@+,%d7
    addw %a3@+,%d7
    addqw #4,%d7
    bset #0,%d7
    moveq #19,%d1
    cmpw %d1,%d7
    jbge rsrc_WDEF_0_C_5A
    subw %d7,%d1
    lsrw #1,%d1
    addw %d1,%fp@(-8)
    moveq #19,%d7
rsrc_WDEF_0_C_5A:       /* set %a3@+ */
    movew %d7,%a3@+
    movew %d7,%d0
    subiw #13,%d0
    lsrw #1,%d0
    movew %d0,%a3@
    clrl %sp@-
    _NewRgn
    movel %sp@+,%fp@(-12)
    tstb %fp@(-34)
    jbeq rsrc_WDEF_0_C_A2
    pea %fp@(-26)
    _GetForeColor
    pea %fp@(-32)
    _GetBackColor
    clrl %sp@-
    clrw %sp@-
    movel %fp@(14),%sp@-
    pea %sp@(6)
    _GetAuxWin
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    movel %a0,%fp@(-16)
    _HLock
    movel %a0@,%fp@(-20)
rsrc_WDEF_0_C_A2:       /* address %fp@(8) */
    lea %fp@(8),%a0
    movel %a0@+,%d3
    movew %a0@+,%d0
    moveal %a0@+,%a3
    movew %a0@+,%d5
    movew %d5,%d6
    andiw #3,%d5
    clrl %a0@
    addw %d0,%d0
    lea %pc@(rsrc_WDEF_0_FC),%a0
    addaw %pc@(rsrc_WDEF_0_FC,%d0:w),%a0
    jsr %a0@
    movel %fp@(-12),%sp@-
    _DisposRgn
    tstb %fp@(-34)
    jbeq rsrc_WDEF_0_C_E0
    moveal %fp@(-16),%a0
    _HUnlock
    pea %fp@(-32)
    _RGBBackColor
    pea %fp@(-26)
    _RGBForeColor
rsrc_WDEF_0_C_E0:       /* _SetPort */
    _SetPort
rsrc_WDEF_0_C_E2:       /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a1-%a4
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(12),%sp
    jmp %a0@
rsrc_WDEF_0_FC:         /* message table (offsets from here): 0 draw, 1 hit, 2 calculate regions, 3 new, 4 dispose, 5 grow, 6 draw grow icon */
    .short  rsrc_WDEF_0_230-rsrc_WDEF_0_FC	| 408769EC
    .short  rsrc_WDEF_0_560-rsrc_WDEF_0_FC	| 408769EE
    .short  rsrc_WDEF_0_636-rsrc_WDEF_0_FC	| 408769F0
    .short  rsrc_WDEF_0_142-rsrc_WDEF_0_FC	| 408769F2
    .short  rsrc_WDEF_0_1EE-rsrc_WDEF_0_FC	| 408769F4
    .short  rsrc_WDEF_0_6CE-rsrc_WDEF_0_FC	| 408769F6
    .short  rsrc_WDEF_0_780-rsrc_WDEF_0_FC	| 408769F8

/*
 Colour set-up: the colour Window Manager port with the pen and background patterns and
 pen state of the Window Manager port.
*/
rsrc_WDEF_0_10A:
    movel ghost_WMgrCPort,%sp@-
    _SetPort
    moveal WMgrPort,%a0
    moveal ghost_WMgrCPort,%a1
    pea %a0@(32)
    pea %a0@(58)
    lea %a0@(48),%a0
    lea %a1@(48),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movew %a0@+,%a1@+
    addqw #8,%a0
    addqw #8,%a1
    movew #20,%d0
rsrc_WDEF_0_10A_2C:     /* set up and call _PenPat (loop) */
    movew %a0@+,%a1@+
    dbf %d0,rsrc_WDEF_0_10A_2C
    _PenPat
    _BackPat
    rts

/*
 Message 3, new: allocate the zoom state record (WStateData: user and standard states, 16
 bytes, NewHandle in the system heap, cleared) for a window with a zoom box.
*/
rsrc_WDEF_0_142:
    btst #3,%d6	| 40876A32
    jbeq rsrc_WDEF_0_19C	| 40876A36
    clrb %a3@(113)	| 40876A38
    tstw ROM85	| 40876A3C
    jbmi rsrc_WDEF_0_19C	| 40876A40
    moveq #16,%d0	| 40876A42
    .short  0xA322	| 40876A44 _NewHandle (flags 0x0300)
    jbne rsrc_WDEF_0_19C	| 40876A46
    addqb #1,%a3@(113)	| 40876A48
    movel %a0,%a3@(130)	| 40876A4C
    moveal %a0@,%a4	| 40876A50
    addqw #8,%a4	| 40876A52
    moveal %a5@,%a1	| 40876A54
    movel %a1@(-116),%a4@+	| 40876A56
    movel %a1@(-112),%a4@+	| 40876A5A
    moveq #3,%d0	| 40876A5E
    subw %d0,%a4@-	| 40876A60
    subw %d0,%a4@-	| 40876A62
    addw %d0,%a4@-	| 40876A64
    addw %d0,%a4@-	| 40876A66
    addw %d7,%a4@	| 40876A68
    addw %d7,%a4@	| 40876A6A
    moveal %a0@,%a4	| 40876A6C

/* subroutine (10 instructions): traps OffsetRect; calls rsrc_WDEF_0_222 (mechanical summary) */
rsrc_WDEF_0_17E:
    movel %a4,%sp@-
    movel %a3@(16),%a4@
    movel %a3@(20),%a4@(4)
    moveal %a3,%a0
    jbsr rsrc_WDEF_0_222
    movel %a0@(6),%sp@-
    negw %sp@
    negw %sp@(2)
    _OffsetRect
rsrc_WDEF_0_19C:        /* return */
    rts

/* subroutine (16 instructions): calls rsrc_WDEF_0_17E, rsrc_WDEF_0_1C2 (mechanical summary) */
rsrc_WDEF_0_19E:
    subqw #8,%sp
    moveal %sp,%a4
    jbsr rsrc_WDEF_0_17E
    moveal %a3@(130),%a0
    moveal %a0@,%a2
    addqw #8,%a2
    jbsr rsrc_WDEF_0_1C2
    jbne rsrc_WDEF_0_19E_16
    jbsr rsrc_WDEF_0_1C2
    jbeq rsrc_WDEF_0_19E_20
rsrc_WDEF_0_19E_16:     /* set %a0 */
    moveal %a3@(130),%a0
    moveal %a0@,%a4
    jbsr rsrc_WDEF_0_17E
    moveq #1,%d0
rsrc_WDEF_0_19E_20:     /* add 8 to %sp */
    addqw #8,%sp
    rts

/* subroutine (13 instructions): traps InsetRect, PtInRect (mechanical summary) */
rsrc_WDEF_0_1C2:
    movel %a2@,%sp@-
    movel %a2@+,%sp@-
    movel %sp,%sp@-
    movel #-393223,%sp@-
    _InsetRect
    clrw %sp@-
    movel %a4@+,%sp@-
    pea %sp@(6)
    _PtInRect
    subqb #1,%sp@
    moveb %sp@+,%d0
    addqw #8,%sp
    rts

/* subroutine (4 instructions) (mechanical summary) */
rsrc_WDEF_0_1E2:
    btst #3,%d6
    jbeq rsrc_WDEF_0_1E2_A
    tstb %a3@(113)
rsrc_WDEF_0_1E2_A:      /* return */
    rts

/* Message 4, dispose: free the zoom state record. */
rsrc_WDEF_0_1EE:
    jbsr rsrc_WDEF_0_1E2	| 40876ADE
    jbeq rsrc_WDEF_0_1F8	| 40876AE0
    moveal %a3@(130),%a0	| 40876AE2
    _DisposHandle	| 40876AE6
rsrc_WDEF_0_1F8:        /* return */
    rts	| 40876AE8

/* subroutine (14 instructions) (mechanical summary) */
rsrc_WDEF_0_1FA:
    movel %d1,%sp@-	| 40876AEA
    moveal %fp@(-20),%a0	| 40876AEC
    movew %a0@(6),%d1	| 40876AF0
    muluw #8,%d1	| 40876AF4
rsrc_WDEF_0_208:        /* loop: cmp */
    cmpw %a0@(8,%d1:w),%d0	| 40876AF8
    jbeq rsrc_WDEF_0_214	| 40876AFC
    subqw #8,%d1	| 40876AFE
    jbge rsrc_WDEF_0_208	| 40876B00
    moveq #0,%d1	| 40876B02
rsrc_WDEF_0_214:        /* (40876B04 lea %a0@(a,%d1:w),%a0) */
    lea %a0@(0xa,%d1:w),%a0	| 40876B04
    movel %a0,%d0	| 40876B08
    movel %sp@+,%d1	| 40876B0A
    moveal %sp@+,%a0	| 40876B0C
    movel %d0,%sp@-	| 40876B0E
    jmp %a0@	| 40876B10

/* subroutine (6 instructions) (mechanical summary) */
rsrc_WDEF_0_222:
    addqw #2,%a0
    tstw %a0@(4)
    jbpl rsrc_WDEF_0_222_C
    moveal %a0@,%a0
    moveal %a0@,%a0
rsrc_WDEF_0_222_C:      /* return */
    rts

/*
 Message 0, draw: the frame for the variation (document window: frame, title bar with its
 lines, close and zoom boxes, title; dialog boxes: single, double or shadowed frame).
 Param 4: toggle the close box, 5: toggle the zoom box. Nothing when the window is
 invisible.
*/
rsrc_WDEF_0_230:
    tstb %a3@(110)	| 40876B20
    jbeq rsrc_WDEF_0_3AC	| 40876B24
    cmpiw #4,%d3	| 40876B28
    jbge rsrc_WDEF_0_3D6	| 40876B2C
    _PenNormal	| 40876B30
    tstw %d5	| 40876B32
    jbne rsrc_WDEF_0_422	| 40876B34
    jbsr rsrc_WDEF_0_3B6	| 40876B38
    tstb %fp@(-34)	| 40876B3C
    jbeq rsrc_WDEF_0_262	| 40876B40
    movew #1,%d0	| 40876B42
    jbsr rsrc_WDEF_0_1FA	| 40876B46
    _RGBForeColor	| 40876B48
    movew #4,%d0	| 40876B4A
    jbsr rsrc_WDEF_0_1FA	| 40876B4E
    _RGBBackColor	| 40876B50
rsrc_WDEF_0_262:        /* from here: pea 0x9fa */
    pea Scratch8	| 40876B52
    movel %sp@,%sp@-	| 40876B56
    movel %sp@,%sp@-	| 40876B58
    _FrameRect	| 40876B5A
    movel OneOne,%sp@-	| 40876B5C
    _InsetRect	| 40876B60
    _EraseRect
    jbsr rsrc_WDEF_0_436	| 40876B64
    tstb %a3@(111)	| 40876B68
    jbeq rsrc_WDEF_0_31A	| 40876B6C
    tstb %fp@(-34)	| 40876B70
    jbeq rsrc_WDEF_0_29A	| 40876B74
    movew #4,%d0	| 40876B76
    jbsr rsrc_WDEF_0_1FA	| 40876B7A
    _RGBBackColor	| 40876B7E
    movew #3,%d0	| 40876B80
    jbsr rsrc_WDEF_0_1FA	| 40876B84
    _RGBForeColor	| 40876B88
rsrc_WDEF_0_29A:        /* from here: pea 0x9fa */
    pea Scratch8	| 40876B8A
    movew #1,%sp@-	| 40876B8E
    movew %fp@(-2),%sp@-	| 40876B92
    _InsetRect	| 40876B96
    movew scratch8_6,%sp@-	| 40876B98
    movew %d3,scratch8_6	| 40876B9C
    movel Scratch8,%d0	| 40876BA0
    andil #458759,%d0	| 40876BA4
    moveal %a5@,%a4	| 40876BAA
    movel %d0,%a4@(-168)	| 40876BAC
    pea Scratch8	| 40876BB0
    pea %pc@(rsrc_WDEF_0_3AE)	| 40876BB4
    _FillRect	| 40876BB8
    jbsr rsrc_WDEF_0_1E2	| 40876BBA
    jbeq rsrc_WDEF_0_2DC	| 40876BBE
    movew %sp@,%d0	| 40876BC0
    subiw #26,%d0	| 40876BC2
    cmpw %d4,%d0	| 40876BC6
    jbge rsrc_WDEF_0_2DC	| 40876BC8
    movew %d0,%d4	| 40876BCA
rsrc_WDEF_0_2DC:        /* set 0xa00 */
    movew %sp@+,scratch8_6	| 40876BCC
    movew %d4,scratch8_2	| 40876BD0
    pea Scratch8	| 40876BD4
    pea %pc@(rsrc_WDEF_0_3AE)	| 40876BD8
    _FillRect	| 40876BDC
    clrl %a4@(-168)	| 40876BDE
    tstb %a3@(112)	| 40876BE2
    jbeq rsrc_WDEF_0_306	| 40876BE6
    jbsr rsrc_WDEF_0_3B6	| 40876BE8
    lea %pc@(rsrc_WDEF_0_520),%a1	| 40876BEC
    moveq #0,%d0	| 40876BF0
    jbsr rsrc_WDEF_0_3FC	| 40876BF2
rsrc_WDEF_0_306:        /* call rsrc_WDEF_0_1E2 */
    jbsr rsrc_WDEF_0_1E2	| 40876BF6
    jbeq rsrc_WDEF_0_31A	| 40876BFA
    jbsr rsrc_WDEF_0_3B6	| 40876BFC
    lea %pc@(rsrc_WDEF_0_4E0),%a1	| 40876C00
    moveq #0,%d0	| 40876C04
    jbsr rsrc_WDEF_0_3E6	| 40876C06
rsrc_WDEF_0_31A:        /* set %d4 */
    movel OneOne,%d4	| 40876C0A
rsrc_WDEF_0_31E:        /* loop: tst */
    tstb %fp@(-34)	| 40876C0E
    jbeq rsrc_WDEF_0_334	| 40876C12
    moveq #1,%d0	| 40876C14
    jbsr rsrc_WDEF_0_1FA	| 40876C16
    _RGBForeColor	| 40876C1A
    moveq #0,%d0	| 40876C1C
    jbsr rsrc_WDEF_0_1FA	| 40876C1E
    _RGBBackColor	| 40876C22
rsrc_WDEF_0_334:        /* set %a0 */
    moveal %a3@(114),%a0	| 40876C24
    moveal %a0@,%a0	| 40876C28
    lea %a0@(2),%a4	| 40876C2A
    subw %d4,%a4@(4)	| 40876C2E
    subw %d4,%a4@(6)	| 40876C32
    movel %a4,%sp@-	| 40876C36
    _FrameRect	| 40876C38
    cmpiw #3,%d5	| 40876C3A
    jbeq rsrc_WDEF_0_354	| 40876C3E
    tstw %d5	| 40876C40
    jbne rsrc_WDEF_0_358	| 40876C42
rsrc_WDEF_0_354:        /* call rsrc_WDEF_0_728 */
    jbsr rsrc_WDEF_0_728	| 40876C44
rsrc_WDEF_0_358:        /* test #1,%d5 */
    cmpiw #1,%d5	| 40876C48
    jbne rsrc_WDEF_0_3A4	| 40876C4C
    movel %a4@,Scratch8	| 40876C4E
    movel %a4@(4),scratch8_4	| 40876C52
    pea Scratch8	| 40876C58
    movel %sp@,%sp@-	| 40876C5C
    movel %sp@,%sp@-	| 40876C5E
    movel OneOne,%sp@-	| 40876C60
    _InsetRect	| 40876C64
    movel #458759,%sp@-	| 40876C66
    _PenSize	| 40876C6C
    moveal %a5@,%a0	| 40876C6E
    pea %a0@(-8)	| 40876C70
    _PenPat	| 40876C74
    _FrameRect
    moveal %a5@,%a0	| 40876C78
    pea %a0@(-16)	| 40876C7A
    _PenPat	| 40876C7E
    movel #131074,%sp@-	| 40876C80
    movel %sp@,%sp@-	| 40876C86
    _PenSize	| 40876C88
    _InsetRect
    pea Scratch8	| 40876C8C
    _FrameRect	| 40876C90
    _PenNormal
rsrc_WDEF_0_3A4:        /* from here: addw %d4,%a4@(4) */
    addw %d4,%a4@(4)	| 40876C94
    addw %d4,%a4@(6)	| 40876C98
rsrc_WDEF_0_3AC:        /* return */
    rts	| 40876C9C

/* subroutine (0 instructions) (mechanical summary) */
rsrc_WDEF_0_3AE:
    .byte   0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00, 0xFF, 0x00	| 40876C9E

/* subroutine (14 instructions): calls rsrc_WDEF_0_1E2, rsrc_WDEF_0_3B6; low memory Scratch8 (mechanical summary) */
rsrc_WDEF_0_3B6:
    lea Scratch8,%a0
    moveal %a3@(114),%a1
    moveal %a1@,%a1
    addqw #2,%a1
    movel %a1@+,%a0@
    movel %a1@,%a0@(4)
    movew %a0@,%d0
    addw %d7,%d0
    movew %d0,%a0@(4)	| 40876CBC
    subqw #1,%a0@(6)
    rts
rsrc_WDEF_0_3D6:        /* from here: jbeq rsrc_WDEF_0_3B6_3E */
    jbeq rsrc_WDEF_0_3B6_3E
    jbsr rsrc_WDEF_0_1E2
    jbeq rsrc_WDEF_0_3B6_6A
    jbsr rsrc_WDEF_0_3B6
    lea %pc@(rsrc_WDEF_0_500),%a1
    moveq #2,%d0

/* subroutine (7 instructions): calls rsrc_WDEF_0_3B6; low memory Scratch8 (mechanical summary) */
rsrc_WDEF_0_3E6:
    lea Scratch8,%a0
    movew %a0@(6),%a0@(2)
    moveq #-22,%d1
    jbra rsrc_WDEF_0_3B6_4C
rsrc_WDEF_0_3B6_3E:     /* call rsrc_WDEF_0_3B6 */
    jbsr rsrc_WDEF_0_3B6
    lea %pc@(rsrc_WDEF_0_540),%a1
    moveq #2,%d0

/* subroutine (18 instructions): calls rsrc_WDEF_0_754; low memory Scratch8 (mechanical summary) */
rsrc_WDEF_0_3FC:
    lea Scratch8,%a0
    moveq #7,%d1
rsrc_WDEF_0_3B6_4C:     /* from here: addw %d1,%a0@(2) */
    addw %d1,%a0@(2)
    movew %fp@(-2),%d1
    addw %d1,%a0@
    subqw #1,%a0@
    movel %a0@+,%a0@
    moveq #16,%d1
    addw %d1,%a0@+
    addw %d1,%a0@
    movel #1048592,%d1
    jbsr rsrc_WDEF_0_754
rsrc_WDEF_0_3B6_6A:     /* return */
    rts
rsrc_WDEF_0_422:        /* set %d4 */
    movel #131074,%d4	| 40876D12
    cmpiw #3,%d5	| 40876D18
    jbeq rsrc_WDEF_0_31E	| 40876D1C
    moveq #0,%d4	| 40876D20
    jbra rsrc_WDEF_0_31E	| 40876D22

/*
 Draw the title, centred in the title bar between the close and zoom boxes and clipped to
 it, in the title colour on Color QuickDraw.
*/
rsrc_WDEF_0_436:
    movew scratch8_6,%d4	| 40876D26
    movew %d4,%d3	| 40876D2A
    subw scratch8_2,%d3	| 40876D2C
    subw %a3@(138),%d3	| 40876D30
    asrw #1,%d3	| 40876D34
    moveq #2,%d0	| 40876D36
    tstb %a3@(112)	| 40876D38
    jbeq rsrc_WDEF_0_450	| 40876D3C
    moveq #32,%d0	| 40876D3E
rsrc_WDEF_0_450:        /* test %d0,%d3 */
    cmpw %d0,%d3	| 40876D40
    jbge rsrc_WDEF_0_456	| 40876D42
    movew %d0,%d3	| 40876D44
rsrc_WDEF_0_456:        /* from here: addw 0x9fc,%d3 */
    addw scratch8_2,%d3	| 40876D46
    movew %d4,%sp@-	| 40876D4A
    jbsr rsrc_WDEF_0_1E2	| 40876D4C
    jbeq rsrc_WDEF_0_466	| 40876D50
    subiw #32,%d4	| 40876D52
rsrc_WDEF_0_466:        /* set %sp@- */
    movel %fp@(-12),%sp@-	| 40876D56
    movel %sp@,%sp@-	| 40876D5A
    _GetClip	| 40876D5C
    movew %d4,scratch8_6	| 40876D5E
    pea Scratch8	| 40876D62
    _ClipRect	| 40876D66
    moveal %a5@,%a0	| 40876D68
    moveal %a0@,%a0	| 40876D6A
    movel %a0@(28),%sp@-	| 40876D6C
    movel %sp@,%sp@-	| 40876D70
    _SectRgn	| 40876D72
    movew %sp@+,scratch8_6	| 40876D74
    movew %d3,%sp@-	| 40876D78
    movew Scratch8,%d0	| 40876D7A
    addw %fp@(-8),%d0	| 40876D7E
    addqw #1,%d0	| 40876D82
    movew %d0,%sp@-	| 40876D84
    _MoveTo	| 40876D86
    tstb %fp@(-34)	| 40876D88
    jbeq rsrc_WDEF_0_4B8	| 40876D8C
    movew #4,%d0	| 40876D8E
    jbsr rsrc_WDEF_0_1FA	| 40876D92
    _RGBBackColor	| 40876D96
    movew #2,%d0	| 40876D98
    jbsr rsrc_WDEF_0_1FA	| 40876D9C
    _RGBForeColor	| 40876DA0
    movew #1,%sp@-	| 40876DA2
    _TextMode	| 40876DA6
rsrc_WDEF_0_4B8:        /* set %a0 */
    moveal %a3@(134),%a0	| 40876DA8
    _HLock	| 40876DAC
    movel %a0@,%sp@-	| 40876DAE
    _DrawString	| 40876DB0
    moveal %a3@(134),%a0	| 40876DB2
    _HUnlock	| 40876DB6
    movel %fp@(-12),%sp@-	| 40876DB8
    _SetClip	| 40876DBC
    movew %d3,%d0	| 40876DBE
    subqw #6,%d3	| 40876DC0
    addw %a3@(138),%d0	| 40876DC2
    cmpw %d4,%d0	| 40876DC6
    jbge rsrc_WDEF_0_4DC	| 40876DC8
    movew %d0,%d4	| 40876DCA
rsrc_WDEF_0_4DC:        /* add 6 to %d4 */
    addqw #6,%d4	| 40876DCC
    rts	| 40876DCE
rsrc_WDEF_0_4E0:        /* (data) */
    .byte   0x00, 0x00, 0x00, 0x00, 0xBF, 0xFB, 0x20, 0x88, 0xA0, 0x8B, 0x20, 0x88, 0xA0, 0x8B, 0x20, 0x88	| 40876DD0
    .byte   0xBF, 0x8B, 0x20, 0x08, 0xA0, 0x0B, 0x20, 0x08, 0xBF, 0xFB, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40876DE0
rsrc_WDEF_0_500:        /* (data) */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x80, 0x09, 0xA0, 0x05, 0xC0, 0x00, 0x80, 0x1C, 0xF0	| 40876DF0
    .byte   0x1F, 0x80, 0x05, 0x40, 0x09, 0x20, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40876E00
rsrc_WDEF_0_520:        /* (data) */
    .byte   0x00, 0x00, 0x00, 0x00, 0xBF, 0xFB, 0x20, 0x08, 0xA0, 0x0B, 0x20, 0x08, 0xA0, 0x0B, 0x20, 0x08	| 40876E10
    .byte   0xA0, 0x0B, 0x20, 0x08, 0xA0, 0x0B, 0x20, 0x08, 0xBF, 0xFB, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40876E20
rsrc_WDEF_0_540:        /* (data) */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x09, 0x20, 0x05, 0x40, 0x00, 0x00, 0x1C, 0x70	| 40876E30
    .byte   0x00, 0x00, 0x05, 0x40, 0x09, 0x20, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40876E40

/*
 Message 1, hit test (param = the point): 1 inContent, 2 inDrag (title bar), 3 inGrow, 4
 inGoAway, 5 inZoomIn or 6 inZoomOut (by the current state), 0 outside.
*/
rsrc_WDEF_0_560:
    clrw %sp@-	| 40876E50
    movel %d3,%sp@-	| 40876E52
    movel %a3@(118),%sp@-	| 40876E54
    _PtInRgn	| 40876E58
    tstb %sp@+	| 40876E5A
    jbeq rsrc_WDEF_0_5A6	| 40876E5C
    tstw %d5	| 40876E5E
    jbne rsrc_WDEF_0_5A0	| 40876E60
    btst #2,%d6	| 40876E62
    jbgt rsrc_WDEF_0_5A0	| 40876E66
    tstb %a3@(111)	| 40876E68
    jbeq rsrc_WDEF_0_5A0	| 40876E6C
    moveal %a3@(118),%a0	| 40876E6E
    moveal %a0@,%a0	| 40876E72
    movel %a0@(6),%d0	| 40876E74
    moveq #14,%d4	| 40876E78
    subw %d4,%d0	| 40876E7A
    cmpw %d0,%d3	| 40876E7C
    jblt rsrc_WDEF_0_5A0	| 40876E7E
    swap %d0	| 40876E80
    subw %d4,%d0	| 40876E82
    swap %d3	| 40876E84
    cmpw %d0,%d3	| 40876E86
    jblt rsrc_WDEF_0_5A0	| 40876E88
    moveq #3,%d0	| 40876E8A
    jbra rsrc_WDEF_0_630	| 40876E8C
rsrc_WDEF_0_5A0:        /* result 1 */
    moveq #1,%d0	| 40876E90
    jbra rsrc_WDEF_0_630	| 40876E92
rsrc_WDEF_0_5A6:        /* test %d5 */
    tstw %d5	| 40876E96
    jbne rsrc_WDEF_0_634	| 40876E98
    jbsr rsrc_WDEF_0_3B6	| 40876E9C
    clrw %sp@-	| 40876EA0
    movel %d3,%sp@-	| 40876EA2
    movel %a0,%sp@-	| 40876EA4
    _PtInRect	| 40876EA6
    tstb %sp@+	| 40876EA8
    jbeq rsrc_WDEF_0_634	| 40876EAA
    tstb %a3@(111)
    jbeq rsrc_WDEF_0_62E
    movel %d3,%d0
    swap %d0
    moveal %a3,%a0
    jbsr rsrc_WDEF_0_222
    addw %a0@(6),%d0
    subw %a3@(16),%d0
    addw %fp@(-2),%d0
    jbpl rsrc_WDEF_0_62E
    addiw #11,%d0
    jbmi rsrc_WDEF_0_62E
    tstb %a3@(112)
    jbeq rsrc_WDEF_0_5FE
    movel %d3,%d0
    addw %a0@(8),%d0
    subw %a3@(18),%d0
    cmpiw #18,%d0
    jbgt rsrc_WDEF_0_5FE
    subqw #8,%d0
    jbmi rsrc_WDEF_0_62E
    moveq #4,%d0
    jbra rsrc_WDEF_0_630
rsrc_WDEF_0_5FE:        /* call rsrc_WDEF_0_1E2 */
    jbsr rsrc_WDEF_0_1E2
    jbeq rsrc_WDEF_0_62E
    movew %d3,%d0
    moveal %a3,%a0
    jbsr rsrc_WDEF_0_222
    addw %a0@(8),%d0
    subw %a3@(22),%d0
    cmpiw #-19,%d0
    jblt rsrc_WDEF_0_62E
    cmpiw #-9,%d0
    jbgt rsrc_WDEF_0_62E
    jbsr rsrc_WDEF_0_19E
    jbeq rsrc_WDEF_0_62A
    moveq #6,%d0
    jbra rsrc_WDEF_0_630
rsrc_WDEF_0_62A:        /* result 5 */
    moveq #5,%d0
    jbra rsrc_WDEF_0_630
rsrc_WDEF_0_62E:        /* set %d0 */
    moveq #2,%d0
rsrc_WDEF_0_630:        /* set %fp@(20) */
    movel %d0,%fp@(20)
rsrc_WDEF_0_634:        /* return */
    rts

/*
 Message 2, calculate regions: content region (port rectangle in global coordinates) and
 structure region (content plus frame, title bar, shadow for the variation).
*/
rsrc_WDEF_0_636:
    jbsr rsrc_WDEF_0_1E2	| 40876F26
    jbeq rsrc_WDEF_0_640	| 40876F2A
    jbsr rsrc_WDEF_0_19E	| 40876F2C
rsrc_WDEF_0_640:        /* address 0x9fa */
    lea Scratch8,%a0	| 40876F30
    movel %a0,%sp@-	| 40876F34
    movel %a3@(16),%a0@+	| 40876F36
    movel %a3@(20),%a0@	| 40876F3A
    moveal %a3,%a0	| 40876F3E
    jbsr rsrc_WDEF_0_222	| 40876F40
    movel %a0@(6),%sp@-	| 40876F44
    negw %sp@	| 40876F48
    negw %sp@(2)	| 40876F4A
    _OffsetRect	| 40876F4E
    movel %a3@(118),%sp@-	| 40876F50
    pea Scratch8	| 40876F54
    _RectRgn	| 40876F58
    movel #131074,%d4	| 40876F5A
    movel %a3@(114),%sp@-	| 40876F60
    pea Scratch8	| 40876F64
    movel %sp@,%sp@-	| 40876F68
    movel MinusOne,%sp@-	| 40876F6A
    _InsetRect	| 40876F6E
    tstw %d5	| 40876F70
    jbne rsrc_WDEF_0_6BA	| 40876F72
    movew %d7,%d0	| 40876F74
    subqw #1,%d0	| 40876F76
    subw %d0,Scratch8	| 40876F78
    lsrl #1,%d4	| 40876F7C
rsrc_WDEF_0_68E:        /* (40876F7E A-line trap) */
    _RectRgn	| 40876F7E
    tstw %d5	| 40876F80
    jbeq rsrc_WDEF_0_69A	| 40876F82
    cmpiw #3,%d5	| 40876F84
    jbne rsrc_WDEF_0_6B8	| 40876F88
rsrc_WDEF_0_69A:        /* set %sp@- */
    movel %fp@(-12),%sp@-	| 40876F8A
    pea Scratch8	| 40876F8E
    movel %sp@,%sp@-	| 40876F92
    movel %d4,%sp@-	| 40876F94
    _OffsetRect	| 40876F96
    _RectRgn
    movel %a3@(114),%sp@-	| 40876F9A
    movel %fp@(-12),%sp@-	| 40876F9E
    movel %a3@(114),%sp@-	| 40876FA2
    _UnionRgn	| 40876FA6
rsrc_WDEF_0_6B8:        /* return */
    rts	| 40876FA8
rsrc_WDEF_0_6BA:        /* test #1,%d5 */
    cmpiw #1,%d5	| 40876FAA
    jbne rsrc_WDEF_0_68E	| 40876FAE
    pea Scratch8	| 40876FB0
    movel #-393223,%sp@-	| 40876FB4
    _InsetRect	| 40876FBA
    jbra rsrc_WDEF_0_68E	| 40876FBC

/*
 Message 5, grow: the outline drawn while the window is resized (param = the rectangle):
 frame, title bar line and scroll bar lines.
*/
rsrc_WDEF_0_6CE:
    movel %d3,%sp@-	| 40876FBE
    movel MinusOne,%sp@-	| 40876FC0
    _InsetRect	| 40876FC4
    moveal %d3,%a3	| 40876FC6
    movel %a3@,%sp@-	| 40876FC8
    movew %d7,%d0	| 40876FCA
    subqw #1,%d0	| 40876FCC
    subw %d0,%a3@	| 40876FCE
    movel %d3,%sp@-	| 40876FD0
    _FrameRect	| 40876FD2
    movew %a3@(2),%sp@-	| 40876FD4
    movew %a3@(4),%sp@-	| 40876FD8
    subiw #16,%sp@	| 40876FDC
    movel %sp@,%sp@-	| 40876FE0
    _MoveTo	| 40876FE2
    movew %a3@(6),%sp@(2)	| 40876FE4
    .short  0xA891	| 40876FEA _LineTo
    movel %sp@,%a3@	| 40876FEC
    movel %sp@,%sp@-	| 40876FEE
    _MoveTo	| 40876FF0
    movew %a3@(6),%sp@(2)	| 40876FF2
    .short  0xA891	| 40876FF8 _LineTo
    movew %a3@(6),%sp@-	| 40876FFA
    subiw #16,%sp@	| 40876FFE
    movew %a3@,%sp@-	| 40877002
    movel %sp@,%sp@-	| 40877004
    _MoveTo	| 40877006
    movew %a3@(4),%sp@	| 40877008
    .short  0xA891	| 4087700C _LineTo
    movel %d3,%sp@-	| 4087700E
    movel OneOne,%sp@-	| 40877010
    _InsetRect	| 40877014
    rts	| 40877016

/* subroutine (17 instructions): traps PenSize, MoveTo, Line, PenNormal (mechanical summary) */
rsrc_WDEF_0_728:
    movel %d4,%sp@-	| 40877018
    _PenSize	| 4087701A
    movew %a4@(6),%d0	| 4087701C
    movew %d0,%sp@-	| 40877020
    movew %a4@,%sp@-	| 40877022
    movew %d0,%sp@-	| 40877024
    movew %a4@(4),%d0	| 40877026
    movew %d0,%sp@-	| 4087702A
    movew %a4@(2),%sp@-	| 4087702C
    movew %d0,%sp@-	| 40877030
    addw %d4,%sp@(2)	| 40877032
    addw %d4,%sp@(8)	| 40877036
    _MoveTo	| 4087703A
    .short  0xA891	| _LineTo
    .short  0xA891	| _LineTo
    _PenNormal
    rts	| 40877042

/* CopyBits of a 16x16 image (close or zoom box, normal or pressed) into the title bar. */
rsrc_WDEF_0_754:
    lea IconBitmap,%a0
    movel %a1,%a0@+
    movew #2,%a0@+
    clrl %a0@+
    movel %d1,%a0@
    pea IconBitmap
    moveal %sp@,%a0
    moveal %a5@,%a1
    moveal %a1@,%a1
    pea %a1@(2)
    pea %a0@(6)
    pea Scratch8
    movew %d0,%sp@-
    clrl %sp@-
    _CopyBits
    rts

/*
 Message 6, draw the grow icon (size box) in the bottom right corner, or erase it when the
 window is inactive.
*/
rsrc_WDEF_0_780:
    moveal %a5@,%a0	| 40877070
    movel %a0@,%sp@-	| 40877072
    movel %a3,%sp@-	| 40877074
    _SetPort	| 40877076
    tstb %fp@(-34)	| 40877078
    jbeq rsrc_WDEF_0_7AC	| 4087707C
    subqw #6,%sp	| 4087707E
    movel %sp,%sp@-	| 40877080
    _GetForeColor	| 40877082
    subqw #6,%sp	| 40877084
    movel %sp,%sp@-	| 40877086
    _GetBackColor	| 40877088
    clrw %d0	| 4087708A
    jbsr rsrc_WDEF_0_1FA	| 4087708C
    _RGBBackColor	| 40877090
    movew #1,%d0	| 40877092
    jbsr rsrc_WDEF_0_1FA	| 40877096
    _RGBForeColor	| 4087709A
rsrc_WDEF_0_7AC:        /* address 0x9fa */
    lea Scratch8,%a4	| 4087709C
    movel %a3@(20),%a4@(4)	| 408770A0
    movel %a4@(4),%a4@	| 408770A6
    subiw #15,%a4@	| 408770AA
    subiw #15,%a4@(2)	| 408770AE
    tstb %a3@(111)	| 408770B4
    jbeq rsrc_WDEF_0_812	| 408770B8
    lea %pc@(rsrc_WDEF_0_81A),%a1	| 408770BA
    moveq #0,%d0	| 408770BE
    movel #1048592,%d1	| 408770C0
    jbsr rsrc_WDEF_0_754	| 408770C6
rsrc_WDEF_0_7DA:        /* loop: move */
    movew %a4@(2),%sp@-	| 408770CA
    movew %sp@,%sp@-	| 408770CE
    movew %a3@(16),%sp@-	| 408770D0
    _MoveTo	| 408770D4
    movew %a3@(20),%sp@-	| 408770D6
    .short  0xA891	| 408770DA _LineTo
    movew %a3@(18),%sp@-	| 408770DC
    movew %a4@,%sp@-	| 408770E0
    _MoveTo	| 408770E2
    movew %a3@(22),%sp@-	| 408770E4
    movew %a4@,%sp@-	| 408770E8
    .short  0xA891	| 408770EA _LineTo
    tstb %fp@(-34)	| 408770EC
    jbeq rsrc_WDEF_0_80E	| 408770F0
    movel %sp,%sp@-	| 408770F2
    _RGBBackColor	| 408770F4
    addqw #6,%sp	| 408770F6
    movel %sp,%sp@-	| 408770F8
    _RGBForeColor	| 408770FA
    addqw #6,%sp	| 408770FC
rsrc_WDEF_0_80E:        /* (408770FE A-line trap) */
    _SetPort	| 408770FE
    rts	| 40877100
rsrc_WDEF_0_812:        /* from here: pea 0x9fa */
    pea Scratch8	| 40877102
    _EraseRect	| 40877106
    jbra rsrc_WDEF_0_7DA	| 40877108
rsrc_WDEF_0_81A:        /* (data) */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x1F, 0xE0, 0x10, 0x20, 0x10, 0x3E, 0x10, 0x22, 0x10, 0x22	| 4087710A
    .byte   0x10, 0x22, 0x10, 0x22, 0x1F, 0xE2, 0x04, 0x02, 0x04, 0x02, 0x04, 0x02, 0x07, 0xFE, 0x00, 0x00	| 4087711A
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4087712A
