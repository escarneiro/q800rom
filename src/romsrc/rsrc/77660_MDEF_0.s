/* ROM resource 'MDEF' 0: map entry at 0x40877660, data at 0x40877690, 3600 bytes

 Menu definition 0: the standard text menu (items with icons, marks, command keys, styles,
 dividers; scrolling when the menu is taller than the screen), in the menu's colours
 ('mctb', GetMCEntry) on Color QuickDraw. Messages 0-3 dispatch through rsrc_MDEF_0_60.
 Comments inferred from the code (and the menu definition messages in Inside Macintosh).
*/

rsrc_MDEF_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40877660
    .long   rsrc_WDEF_1_entry-rom_start	| 40877668
    .long   rsrc_MDEF_0-rom_start	| 4087766C
    .ascii  "MDEF"	| 40877670
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40877674
    .long   0x00000000, 0xC0A00000, 0x00000E1C, 0x00000104	| 40877680

/*
 Entry: a branch over the standard header ('MDEF', ID 0); MenuDefProc(message,
 theMenu, menuRect, hitPt, whichItem): locks the menu, calls the routine for the message.
*/
rsrc_MDEF_0:
    jbra rsrc_MDEF_0_C
    .short  0x0000, 0x4D44, 0x4546, 0x0000, 0x000C	| 40877692

rsrc_MDEF_0_C:          /* from here: linkw %fp,#-68 */
    linkw %fp,#-68
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveal %fp@(20),%a3
    moveal %a3,%a0
    _HLock
    clrw %fp@(-28)
    clrw %fp@(-30)
    clrw %fp@(-60)
    cmpiw #16383,ROM85
    sls %fp@(-60)
    lea %pc@(rsrc_MDEF_0_60),%a0
    movew %fp@(24),%d0
    cmpiw #3,%d0
    jbhi rsrc_MDEF_0_C_42
    cmpiw #0,%d0
    jbcs rsrc_MDEF_0_C_42
    addw %d0,%d0
    addaw %pc@(rsrc_MDEF_0_60,%d0:w),%a0
    jsr %a0@
rsrc_MDEF_0_C_42:       /* set up and call _HUnlock */
    moveal %a3,%a0
    _HUnlock
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(18),%sp
    jmp %a0@
rsrc_MDEF_0_60:         /* message table (offsets from here): 0 draw, 1 choose, 2 size, 3 pop-up */
    .short  rsrc_MDEF_0_4CE_68-rsrc_MDEF_0_60	| 408776F0
    .short  rsrc_MDEF_0_68-rsrc_MDEF_0_60	| 408776F2
    .short  rsrc_MDEF_0_A3A-rsrc_MDEF_0_60	| 408776F4
    .short  rsrc_MDEF_0_B32-rsrc_MDEF_0_60	| 408776F6

/*
 Message 1, choose: track the mouse in the menu (hitPt): highlight the item under it
 (enabled items only), scroll the menu when the mouse is at its top or bottom edge,
 return the item in whichItem (0 none).
*/
rsrc_MDEF_0_68:
    jbsr rsrc_MDEF_0_308	| 408776F8
    moveal %fp@(8),%a4	| 408776FC
    movew %a4@,%d3	| 40877700
    clrw %a4@	| 40877702
    moveal %fp@(16),%a2	| 40877704
    movel %a2@,%fp@(-52)	| 40877708
    movel %a2@(4),%fp@(-48)	| 4087770C
    clrl %fp@(-56)	| 40877712
    movew %fp@(-2),%d0	| 40877716
    asrw #1,%d0	| 4087771A
    movew %d0,%fp@(-58)	| 4087771C
    clrw %fp@(-32)	| 40877720
    movew %d3,%d0	| 40877724
    moveal %a3@,%a0	| 40877726
    jbsr rsrc_MDEF_0_9FA	| 40877728
    cmpib #27,%a1@(1)	| 4087772C
    jbne rsrc_MDEF_0_AA	| 40877732
    movew #1,%fp@(-32)	| 40877734
rsrc_MDEF_0_AA:         /* set %d4 */
    movew TopMenuItem,%d4	| 4087773A
    movel %fp@(12),%d5	| 4087773E
    jbeq rsrc_MDEF_0_170_D6	| 40877742
    movew AtMenuBottom,%d0	| 40877746
    cmpw %a2@(4),%d0	| 4087774A
    jble rsrc_MDEF_0_C8	| 4087774E
    movew %fp@(-2),%d0	| 40877750
    subw %d0,%a2@(4)	| 40877754
rsrc_MDEF_0_C8:         /* set %d0 */
    movew TopMenuItem,%d0	| 40877758
    cmpw %a2@,%d0	| 4087775C
    jbge rsrc_MDEF_0_D6	| 4087775E
    movew %fp@(-2),%d0	| 40877760
    addw %d0,%a2@	| 40877764
rsrc_MDEF_0_D6:         /* clear %sp@- */
    clrw %sp@-	| 40877766
    movel %d5,%sp@-	| 40877768
    movel %a2,%sp@-	| 4087776A
    _PtInRect	| 4087776C
    tstb %sp@+	| 4087776E
    jbne rsrc_MDEF_0_1EC	| 40877770
    cmpw %a2@(2),%d5	| 40877774
    jblt rsrc_MDEF_0_170_D6	| 40877778
    cmpw %a2@(6),%d5	| 4087777C
    jbgt rsrc_MDEF_0_170_D6	| 40877780
    movew %fp@(-2),%d7	| 40877784
    swap %d5	| 40877788
    cmpw %a2@,%d5	| 4087778A
    jbge rsrc_MDEF_0_1A8	| 4087778C
    addw %d7,%d4	| 40877790
    cmpw %a2@,%d4	| 40877792
    jbgt rsrc_MDEF_0_170_D6	| 40877794
    movew %a2@,%d0	| 40877798
    subw %d5,%d0	| 4087779A
    cmpw %fp@(-58),%d0	| 4087779C
    jbgt rsrc_MDEF_0_11A	| 408777A0
    movel #10,%fp@(-56)	| 408777A2
rsrc_MDEF_0_11A:        /* set %d0 */
    movew AtMenuBottom,%d0	| 408777AA
    cmpw %a2@(4),%d0	| 408777AE
    jbgt rsrc_MDEF_0_13C	| 408777B2
    addw %fp@(-2),%d0	| 408777B4
    cmpw %a2@(4),%d0	| 408777B8
    jble rsrc_MDEF_0_13C	| 408777BC
    moveal %a2,%a0	| 408777BE
    jbsr rsrc_MDEF_0_5C0	| 408777C0
    movew %fp@(-2),%d0	| 408777C4
    subw %d0,%a2@(4)	| 408777C8
rsrc_MDEF_0_13C:        /* loop: move */
    movew %d3,%d0	| 408777CC
    jbsr rsrc_MDEF_0_3D8	| 408777CE
    moveal 0xb5c,%a0	| 408777D2
    moveal %a0@,%a0	| 408777D6
    tstw %a0@(16)	| 408777D8
    jbne rsrc_MDEF_0_156	| 408777DC
    movew #1,%a0@(16)	| 408777DE
    jbra rsrc_MDEF_0_1A0	| 408777E4
rsrc_MDEF_0_156:        /* set 0xa0a */
    movew %d4,TopMenuItem	| 408777E6
    clrl %sp@-	| 408777EA
    _NewRgn	| 408777EC
    movel %sp@,%d6	| 408777EE
    clrl %sp@-	| 408777F0
    _NewRgn	| 408777F2
    jbsr rsrc_MDEF_0_C74	| 408777F4
    movew #10,%fp@(-26)	| 408777F8
    .byte   0x61, 0x00	| 408777FE

rsrc_MDEF_0_170:        /* from here: bchg %d5,%a2@+ */
    bchg %d5,%a2@+
    jbsr rsrc_MDEF_0_278
    movel %a2,%sp@-
    clrw %sp@-
    movew %d7,%sp@-
    movel %d6,%sp@-
    _ScrollRect
    jbsr rsrc_MDEF_0_278_44
    jbsr rsrc_MDEF_0_CA8
    movel %sp@,%sp@-
    _GetClip
    movel %d6,%sp@-
    _SetClip
    jbsr rsrc_MDEF_0_4CE_12
    addw %d7,AtMenuBottom
    movel %sp@,%sp@-
    _SetClip
    _DisposRgn
    _DisposRgn
rsrc_MDEF_0_1A0:        /* clear 0xb56 */
    clrw 0xb56
    jbra rsrc_MDEF_0_170_FC
rsrc_MDEF_0_1A8:        /* set %d0 */
    movew %a2@(4),%d0	| 40877838
    cmpw %d0,%d5	| 4087783C
    jblt rsrc_MDEF_0_170_D6	| 4087783E
    cmpw AtMenuBottom,%d0	| 40877842
    jbge rsrc_MDEF_0_170_D6	| 40877846
    negw %d7	| 4087784A
    addw %d7,%d4	| 4087784C
    movew %d5,%d0	| 4087784E
    subw %a2@(4),%d0	| 40877850
    cmpw %fp@(-58),%d0	| 40877854
    jbgt rsrc_MDEF_0_1D2	| 40877858
    movel #10,%fp@(-56)	| 4087785A
rsrc_MDEF_0_1D2:        /* set %d0 */
    movew TopMenuItem,%d0	| 40877862
    cmpw %a2@,%d0	| 40877866
    jbne rsrc_MDEF_0_13C	| 40877868
    moveal %a2,%a0	| 4087786C
    jbsr rsrc_MDEF_0_5EA	| 4087786E
    movew %fp@(-2),%d0	| 40877872
    addw %d0,%a2@	| 40877876
    jbra rsrc_MDEF_0_13C	| 40877878
rsrc_MDEF_0_1EC:        /* test %a2@,%d4 */
    cmpw %a2@,%d4	| 4087787C
    jble rsrc_MDEF_0_1F6	| 4087787E
    cmpw %fp@(12),%d4	| 40877880
    jbgt rsrc_MDEF_0_170_D6	| 40877884
rsrc_MDEF_0_1F6:        /* set %d2 */
    movew %d4,%d2	| 40877886
    moveq #1,%d4	| 40877888
rsrc_MDEF_0_170_8A:     /* loop: movea */
    moveal %a3@,%a0
    movew %d4,%d0
    jbsr rsrc_MDEF_0_9FA
    jbeq rsrc_MDEF_0_170_D6
    jbsr rsrc_MDEF_0_3A4
    addw %d0,%d2
    cmpw %fp@(12),%d2
    jbgt rsrc_MDEF_0_170_A4
    addqw #1,%d4
    jbra rsrc_MDEF_0_170_8A
rsrc_MDEF_0_170_A4:     /* address Scratch8 */
    lea Scratch8,%a0
    moveal %fp@(16),%a1
    movel %a1@+,%a0@
    movel %a1@,%a0@(4)
    movew %d2,%a0@(4)
    subw %d0,%d2
    movew %d2,%a0@
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    movel Scratch8,%a0@(6)
    movel scratch8_4,%a0@(10)
    jbsr rsrc_MDEF_0_3B6
    jbeq rsrc_MDEF_0_170_D8
    movew %d4,%a4@
    jbra rsrc_MDEF_0_170_D8
rsrc_MDEF_0_170_D6:     /* clear %d4 */
    clrw %d4
rsrc_MDEF_0_170_D8:     /* test %a4@,%d3 */
    cmpw %a4@,%d3
    jbeq rsrc_MDEF_0_170_F0
    movew %d3,%d0
    jbsr rsrc_MDEF_0_3D8
    movew %a4@,%d0
    notw %fp@(-28)
    jbsr rsrc_MDEF_0_3D8
    clrw %fp@(-28)
rsrc_MDEF_0_170_F0:     /* set %a0 */
    moveal %a3@,%a0
    swap %d4
    movew %a0@,%d4
    swap %d4
    movel %d4,MenuDisable
rsrc_MDEF_0_170_FC:     /* set %a2@ */
    movel %fp@(-52),%a2@
    movel %fp@(-48),%a2@(4)
    rts

/* Scrolling pause: wait between scroll steps (TickCount) while the mouse stays at the edge. */
rsrc_MDEF_0_278:
    tstl %fp@(-56)
    jbeq rsrc_MDEF_0_278_42
    movel %d3,%sp@-
    subqw #4,%sp
    _TickCount
    movel %sp@+,%d3
    addl %fp@(-56),%d3
rsrc_MDEF_0_278_12:     /* set up and call _GetMouse (loop) */
    subqw #4,%sp
    movel %sp,%sp@-
    _GetMouse
    movel %sp@+,%d5
    swap %d5
    tstw %d7
    jbge rsrc_MDEF_0_278_2E
    movew %d5,%d0
    subw %a2@(4),%d0
    cmpw %fp@(-58),%d0
    jbgt rsrc_MDEF_0_278_40
    jbra rsrc_MDEF_0_278_38
rsrc_MDEF_0_278_2E:     /* set %d0 */
    movew %a2@,%d0
    subw %d5,%d0
    cmpw %fp@(-58),%d0
    jbgt rsrc_MDEF_0_278_40
rsrc_MDEF_0_278_38:     /* set up and call _TickCount */
    subqw #4,%sp
    _TickCount
    cmpl %sp@+,%d3
    jbgt rsrc_MDEF_0_278_12
rsrc_MDEF_0_278_40:     /* set %d3 */
    movel %sp@+,%d3
rsrc_MDEF_0_278_42:     /* return */
    rts

/* subroutine (28 instructions): traps EraseRgn (mechanical summary) */
rsrc_MDEF_0_278_44:
    tstw %d7
    jbge rsrc_MDEF_0_278_70
    movew %d7,%d0
    negw %d0
    addw %fp@(-2),%d0
    addw %a2@(4),%d0
    cmpw AtMenuBottom,%d0
    jblt rsrc_MDEF_0_278_6E
    moveal %d6,%a0
    moveal %a0@,%a0
    movew %fp@(-2),%d0
    addw %d0,%a0@(6)
    addw %d0,%a2@(4)
    movel %d6,%sp@-
    _EraseRgn
rsrc_MDEF_0_278_6E:     /* return */
    rts
rsrc_MDEF_0_278_70:     /* set %d0 */
    movew %a2@,%d0
    subw %fp@(-2),%d0
    cmpw TopMenuItem,%d0
    jbgt rsrc_MDEF_0_278_8E
    moveal %d6,%a0
    moveal %a0@,%a0
    movew %fp@(-2),%d0
    subw %d0,%a0@(2)
    subw %d0,%a2@
    movel %d6,%sp@-
    _EraseRgn
rsrc_MDEF_0_278_8E:     /* return */
    rts

/*
 Font metrics for the menu (GetFontInfo, CharWidth of the command key symbol): item height
 and widths.
*/
rsrc_MDEF_0_308:
    lea %fp@(-8),%a2
    movel %a2,%sp@-
    _GetFontInfo
    movew %a2@+,%d0
    addw %a2@+,%d0
    tstw ROM85
    jbmi rsrc_MDEF_0_308_18
    tstw SysFontFam
    jbne rsrc_MDEF_0_308_20
rsrc_MDEF_0_308_18:     /* test CurFMFamily */
    tstw CurFMFamily
    jbne rsrc_MDEF_0_308_20
    subqw #2,%a2@
rsrc_MDEF_0_308_20:     /* add 2 to %a2 */
    addqw #2,%a2
    addw %d0,%a2@
    subql #2,%sp
    movew #32,%sp@-
    _CharWidth
    movew %sp@+,%fp@(-10)
    rts

/* Get an item's icon ('cicn' or 'ICON', or the small 'SICN') by its icon number. */
rsrc_MDEF_0_33A:
    cmpib #28,%a1@(1)
    jbeq rsrc_MDEF_0_33A_C
    tstb %a1@
    jbne rsrc_MDEF_0_33A_10
rsrc_MDEF_0_33A_C:      /* clear %d1 */
    moveq #0,%d1
    rts
rsrc_MDEF_0_33A_10:     /* test %fp@(-60) */
    tstb %fp@(-60)
    jbeq rsrc_MDEF_0_33A_3E
    subql #4,%sp
    movel #1667851118,%sp@-
    movew #256,%d0
    moveb %a1@,%d0
    movew %d0,%sp@-
    _GetResource
    movel %sp@+,%d1
    jbeq rsrc_MDEF_0_33A_3E
    movel %d1,%sp@-
    _LoadResource
    moveal %d1,%a0
    moveal %a0@,%a0
    movel %a0@(10),%d1
    subl %a0@(6),%d1
    jbra rsrc_MDEF_0_33A_44
rsrc_MDEF_0_33A_3E:     /* set %d1 */
    movel #2097184,%d1
rsrc_MDEF_0_33A_44:     /* test #29,%a1@(1) */
    cmpib #29,%a1@(1)
    jbeq rsrc_MDEF_0_33A_54
    cmpib #30,%a1@(1)
    jbne rsrc_MDEF_0_33A_5A
rsrc_MDEF_0_33A_54:     /* from here: lsrl #1,%d1 */
    lsrl #1,%d1
    bclr #15,%d1
rsrc_MDEF_0_33A_5A:     /* return */
    rts

/* subroutine (5 instructions): calls rsrc_MDEF_0_3A4 (mechanical summary) */
rsrc_MDEF_0_396:
    moveml %a1,%sp@-
    moveal %a4,%a1
    jbsr rsrc_MDEF_0_3A4
    moveml %sp@+,%a1
    rts

/* subroutine (8 instructions): calls rsrc_MDEF_0_33A (mechanical summary) */
rsrc_MDEF_0_3A4:
    jbsr rsrc_MDEF_0_33A
    swap %d1
    movew %fp@(-2),%d0
    addqw #4,%d1
    cmpw %d0,%d1
    jblt rsrc_MDEF_0_3A4_10
    movew %d1,%d0
rsrc_MDEF_0_3A4_10:     /* return */
    rts

/* subroutine (12 instructions): calls rsrc_MDEF_0_9FA, rsrc_MDEF_0_69A (mechanical summary) */
rsrc_MDEF_0_3B6:
    moveal %a3@,%a0
    movel %a0@(10),%d0
    cmpiw #31,%d4
    jbgt rsrc_MDEF_0_3B6_10
    btst %d4,%d0
    jbeq rsrc_MDEF_0_3B6_20
rsrc_MDEF_0_3B6_10:     /* test bit 0 of %d0 */
    btst #0,%d0
    jbeq rsrc_MDEF_0_3B6_20
    movew %d4,%d0
    jbsr rsrc_MDEF_0_9FA
    jbsr rsrc_MDEF_0_69A
rsrc_MDEF_0_3B6_20:     /* return */
    rts

/* Highlight (invert, or redraw in the highlight colours) one item. */
rsrc_MDEF_0_3D8:
    moveml %d3-%d4,%sp@-
    movew %d0,%d3
    jbeq rsrc_MDEF_0_3D8_D0
    movew TopMenuItem,%d2
    moveq #1,%d4
rsrc_MDEF_0_3D8_10:     /* loop: move */
    movew %d4,%d0
    moveal %a3@,%a0
    jbsr rsrc_MDEF_0_9FA
    jbeq rsrc_MDEF_0_3D8_D0
    jbsr rsrc_MDEF_0_3A4
    cmpb %d3,%d4
    jbeq rsrc_MDEF_0_3D8_28
    addw %d0,%d2
    addqw #1,%d4
    jbra rsrc_MDEF_0_3D8_10
rsrc_MDEF_0_3D8_28:     /* set %d1 */
    moveb %a0@(1),%d1
    lea Scratch8,%a0
    moveal %fp@(16),%a1
    movel %a1@+,%a0@
    movel %a1@,%a0@(4)
    movew %d2,%a0@
    addw %d0,%d2
    movew %d2,%a0@(4)
    moveml %d3-%d7/%a2-%a4,%sp@-
    movew #1,%sp@-
    _TextMode
    subqw #4,%sp
    _NewRgn
    movel %sp@,%sp@-
    _GetClip
    subqw #2,%sp
    movel %fp@(16),%sp@-
    pea Scratch8
    pea %fp@(-44)
    _SectRect
    addqw #2,%sp
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    moveal %sp@+,%a0
    subqw #2,%sp
    pea %a0@(16)
    pea %fp@(-44)
    pea %fp@(-44)
    _SectRect
    addqw #2,%sp
    pea %fp@(-44)
    _ClipRect
    tstw %fp@(-30)
    jbne rsrc_MDEF_0_3D8_A0
    tstw %fp@(-60)
    jbne rsrc_MDEF_0_3D8_A0
    tstw %fp@(-32)
    jbne rsrc_MDEF_0_3D8_A0
    pea Scratch8
    _InverRect
    jbra rsrc_MDEF_0_3D8_C6
rsrc_MDEF_0_3D8_A0:     /* call rsrc_MDEF_0_C74 */
    jbsr rsrc_MDEF_0_C74
    movew #10,%fp@(-26)
    jbsr rsrc_MDEF_0_CCA
    pea Scratch8	| 40877B16
    _EraseRect
    bsrw rsrc_MDEF_0_CA8
    lea Scratch8,%a0
    movew %a0@,%d3
    addw %fp@(-8),%d3
    bsrw rsrc_MDEF_0_6AC
rsrc_MDEF_0_3D8_C6:     /* set up and call _SetClip */
    movel %sp@,%sp@-
    _SetClip
    _DisposRgn
    moveml %sp@+,%d3-%d7/%a2-%a4
rsrc_MDEF_0_3D8_D0:     /* restore registers, return */
    moveml %sp@+,%d3-%d4
    rts

/* subroutine (8 instructions): traps PenPat, PenMode; calls rsrc_MDEF_0_CCA (mechanical summary) */
rsrc_MDEF_0_4AE:
    movel %a0,%sp@-
    moveal %a5@,%a0
    pea %a0@(-24)
    _PenPat
    movew #11,%sp@-
    _PenMode
    movew #10,%fp@(-26)
    jbsr rsrc_MDEF_0_CCA
    _PaintRect
    _PenNormal
    rts

/* subroutine (8 instructions) (mechanical summary) */
rsrc_MDEF_0_4CE:
    movew %d5,%d2
    addw %d0,%d5
    tstb TESysJust_1
    jbpl rsrc_MDEF_0_4CE_10
    subw %d0,%d6
    subw %d0,%d5
    movew %d6,%d2
rsrc_MDEF_0_4CE_10:     /* return */
    rts

/* subroutine (34 instructions): calls rsrc_MDEF_0_9FA, rsrc_MDEF_0_3A4, rsrc_MDEF_0_3D8 (mechanical summary) */
rsrc_MDEF_0_4CE_12:
    movew %d4,%d2
    moveq #1,%d4
    tstw %d7
    jbge rsrc_MDEF_0_4CE_22
    movew %a2@(4),%d3
    subqw #1,%d3
    jbra rsrc_MDEF_0_4CE_26
rsrc_MDEF_0_4CE_22:     /* set %d3 */
    movew %a2@,%d3
    addqw #1,%d3
rsrc_MDEF_0_4CE_26:     /* loop: movea */
    moveal %a3@,%a0
    movew %d4,%d0
    jbsr rsrc_MDEF_0_9FA
    jbeq rsrc_MDEF_0_4CE_3E
    jbsr rsrc_MDEF_0_3A4
    addw %d0,%d2
    cmpw %d3,%d2
    jbgt rsrc_MDEF_0_4CE_40
    addqw #1,%d4
    jbra rsrc_MDEF_0_4CE_26
rsrc_MDEF_0_4CE_3E:     /* subtract 1 to %d4 */
    subqw #1,%d4
rsrc_MDEF_0_4CE_40:     /* set %d0 */
    movew %d4,%d0
    movew #1,%fp@(-30)
    jbsr rsrc_MDEF_0_3D8
    tstw %d7
    jbge rsrc_MDEF_0_4CE_5A
    subqw #1,%d4
    movew %d4,%d0
    jbsr rsrc_MDEF_0_3D8
    jbra rsrc_MDEF_0_4CE_62
rsrc_MDEF_0_4CE_5A:     /* add 1 to %d4 */
    addqw #1,%d4
    movew %d4,%d0
    jbsr rsrc_MDEF_0_3D8
rsrc_MDEF_0_4CE_62:     /* clear %fp@(-30) */
    clrw %fp@(-30)
    rts

/* Message 0, draw: draw every item of the menu (rsrc_MDEF_0_6AC). */
rsrc_MDEF_0_4CE_68:
    jbsr rsrc_MDEF_0_308
    moveal %fp@(16),%a0
    clrw AtMenuBottom
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    clrw %a0@(16)
    jbsr rsrc_MDEF_0_552
    jbsr rsrc_MDEF_0_5A0
    rts

/* Set the item's text style and font for drawing. */
rsrc_MDEF_0_552:
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveq #1,%d4
    movew TopMenuItem,%d3
    addw %fp@(-8),%d3
    clrl %sp@-
    _TextFace
    _TextFont
    .short  0x3F3C	| 40877BF6
    .short  0x0001, 0xA889	| orib #0x89,%d1
rsrc_MDEF_0_552_1A:     /* loop: movea */
    moveal %fp@(16),%a0
    jbsr rsrc_MDEF_0_6AC
    jbeq rsrc_MDEF_0_552_40
    cmpib #28,%a4@(1)
    jbeq rsrc_MDEF_0_552_38
    tstb %a4@
    jbeq rsrc_MDEF_0_552_38
    movew %d7,%d0
    lsrw #1,%d0
    subw %d0,%d7
    addw %d7,%d3
rsrc_MDEF_0_552_38:     /* from here: addw %fp@(-2),%d3 */
    addw %fp@(-2),%d3
    addqw #1,%d4
    jbra rsrc_MDEF_0_552_1A
rsrc_MDEF_0_552_40:     /* from here: subw %fp@(-8),%d3 */
    subw %fp@(-8),%d3
    movew %d3,AtMenuBottom
    moveml %sp@+,%d3-%d7/%a2-%a4
    rts

/* subroutine (11 instructions): calls rsrc_MDEF_0_5C0, rsrc_MDEF_0_5EA (mechanical summary) */
rsrc_MDEF_0_5A0:
    moveal %fp@(16),%a0
    movew AtMenuBottom,%d0
    cmpw %a0@(4),%d0
    jble rsrc_MDEF_0_5A0_10
    jbsr rsrc_MDEF_0_5C0
rsrc_MDEF_0_5A0_10:     /* set %a0 */
    moveal %fp@(16),%a0
    movew TopMenuItem,%d0
    cmpw %a0@,%d0
    jbge rsrc_MDEF_0_5A0_1E
    jbsr rsrc_MDEF_0_5EA
rsrc_MDEF_0_5A0_1E:     /* return */
    rts

/* subroutine (9 instructions) (mechanical summary) */
rsrc_MDEF_0_5C0:
    moveml %d4/%a3-%a4,%sp@-
    movew %a0@(4),%fp@(-40)
    movew %a0@(4),%fp@(-44)
    movew %fp@(-2),%d0
    subw %d0,%fp@(-44)
    movew %a0@(2),%fp@(-42)
    movew %a0@(6),%fp@(-38)
    lea %pc@(rsrc_MDEF_0_DCE),%a4
    jbra rsrc_MDEF_0_5EA_24

/* subroutine (12 instructions): calls rsrc_MDEF_0_C74, rsrc_MDEF_0_CCA (mechanical summary) */
rsrc_MDEF_0_5EA:
    moveml %d4/%a3-%a4,%sp@-
    movew %a0@,%fp@(-44)
    movew %a0@,%fp@(-40)
    movew %fp@(-2),%d0
    addw %d0,%fp@(-40)
    movew %a0@(2),%fp@(-42)
    movew %a0@(6),%fp@(-38)
    lea %pc@(rsrc_MDEF_0_DEE),%a4
rsrc_MDEF_0_5EA_24:     /* call rsrc_MDEF_0_C74 */
    jbsr rsrc_MDEF_0_C74
    movew #-1,%d4
    movew #10,%fp@(-26)
    jbsr rsrc_MDEF_0_CCA
    .long   0x486EFFD4, 0xA8A3700E, 0xA122A029, 0x2650377C	| 40877CB0
    .short  0x0002, 0x0004, 0x42AB	| 40877CC0
    .long   0x0006277C /* number, not a label difference (was rsrc_ltlk_2_C92-.) */	| 40877CC6
    orib #16,%a0@
    .short  0x000A	| .short 0x000a
    movel %a4,%a3@
    movew %fp@(-4),%d0
    addw %fp@(-42),%d0
    movew %d0,%fp@(-42)
    movew %d0,%fp@(-38)
    moveq #16,%d0
    cmpw %fp@(-2),%d0
    bges rsrc_MDEF_0_5EA_24_50
    movew %fp@(-2),%d0
rsrc_MDEF_0_5EA_24_50:
    addw %d0,%fp@(-38)
    movew %fp@(-44),%fp@(-40)
    addw %d0,%fp@(-40)
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    moveal %sp@+,%a0
    movel %a3,%sp@-
    pea %a0@(2)
    pea %a3@(6)
    pea %fp@(-44)
    movew #1,%sp@-
    clrl %sp@-
    _CopyBits
    moveal %a3,%a0
    .short  0xA128	| 40877D1C _RecoverHandle (flags 0x0100)
    _DisposHandle
    moveml %sp@+,%d4/%a3-%a4
    bsrw rsrc_MDEF_0_CA8
    rts

/* subroutine (6 instructions) (mechanical summary) */
rsrc_MDEF_0_69A:
    cmpib #45,%a0@(1)
    jbne rsrc_MDEF_0_69A_10
    tstb %a1@
    jbne rsrc_MDEF_0_69A_10
    tstb %a1@(1)
rsrc_MDEF_0_69A_10:     /* return */
    rts

/*
 Draw one item: mark, icon (colour icon on Color QuickDraw), text in its style, the
 command key or the submenu arrow, dimmed when disabled; a divider line for "-" items.
*/
rsrc_MDEF_0_6AC:
    movew %a0@(2),%d5
    movew %a0@(6),%d6
    movew %d4,%d0
    moveal %a3@,%a0
    jbsr rsrc_MDEF_0_9FA
    jbeq rsrc_MDEF_0_6AC_274
    moveal %a0,%a2
    moveal %a1,%a4
    jbsr rsrc_MDEF_0_C74
    moveal %a2,%a0
    moveal %a4,%a1
    jbsr rsrc_MDEF_0_69A
    jbne rsrc_MDEF_0_6AC_58
    movew #10,%fp@(-26)
    jbsr rsrc_MDEF_0_CCA
    moveal %a5@,%a0
    pea %a0@(-24)
    _PenPat
    movew %d3,%sp@-
    movew %d5,%sp@-
    movew %fp@(-2),%d0
    lsrw #1,%d0
    subw %fp@(-8),%d0
    addw %d0,%d3
    movew %d3,%sp@-
    _MoveTo
    movew %d6,%sp@-
    movew %d3,%sp@-
    .short  0xA891	| 40877D8A _LineTo
    movew %sp@+,%d3
    _PenNormal
    braw rsrc_MDEF_0_6AC_26E
rsrc_MDEF_0_6AC_58:     /* add 2 to %d5 */
    addqw #2,%d5
    cmpib #28,%a4@(1)
    jbeq rsrc_MDEF_0_6AC_74
    moveb %a4@,%d0
    jbeq rsrc_MDEF_0_6AC_74
    jbsr rsrc_MDEF_0_396
    subw %fp@(-2),%d0
    movew %d0,%d7
    lsrw #1,%d0
    addw %d0,%d3
rsrc_MDEF_0_6AC_74:     /* set %d0 */
    movew %fp@(-4),%d0
    jbsr rsrc_MDEF_0_4CE
    cmpib #27,%a4@(1)
    jbeq rsrc_MDEF_0_6AC_A4
    tstb %a4@(2)
    jbeq rsrc_MDEF_0_6AC_A4
    movew %d2,%sp@-
    movew %d3,%sp@-
    _MoveTo
    movew #4,%fp@(-26)
    jbsr rsrc_MDEF_0_CCA
    clrw %d0	| 40877DD6
    moveb %a4@(2),%d0
    movew %d0,%sp@-
    _DrawChar
rsrc_MDEF_0_6AC_A4:     /* set %a1 */
    moveal %a4,%a1
    jbsr rsrc_MDEF_0_33A
    tstl %d1
    jbeq rsrc_MDEF_0_6AC_184
    lea Scratch8,%a0
    movel %a0,%sp@-
    movel %d1,%sp@-
    movew %d3,%d1
    movew %d7,%d0
    lsrw #1,%d0
    subw %d0,%d1
    subw %fp@(-8),%d1
    addqw #2,%d1
    movel %sp@+,%d0
    movew %d1,%a0@+
    movew %d5,%d2
    tstb TESysJust_1
    jbpl rsrc_MDEF_0_6AC_D6
    movew %d6,%d2
    subw %d0,%d2
rsrc_MDEF_0_6AC_D6:     /* set %a0@+ */
    movew %d2,%a0@+
    movel %a0@(-4),%a0@
    addl %d0,%a0@
    addw %fp@(-10),%d0
    jbsr rsrc_MDEF_0_4CE
    tstb %fp@(-60)
    jbeq rsrc_MDEF_0_6AC_13A
    subqw #4,%sp
    movew #256,%d0
    moveb %a4@,%d0
    movew %d0,%sp@-
    _GetCIcon
    movel %sp@+,%fp@(-36)
    jbeq rsrc_MDEF_0_6AC_13A
    cmpiw #4,%fp@(-24)
    jblt rsrc_MDEF_0_6AC_114
    pea RGBBlack
    _RGBForeColor
    pea RGBWhite
    _RGBBackColor
    jbra rsrc_MDEF_0_6AC_12C
rsrc_MDEF_0_6AC_114:    /* from here: pea 0xc10 */
    pea RGBBlack
    pea RGBWhite
    tstw %fp@(-28)
    jbne rsrc_MDEF_0_6AC_128
    _RGBBackColor
    _RGBForeColor
    jbra rsrc_MDEF_0_6AC_12C
rsrc_MDEF_0_6AC_128:    /* _RGBForeColor */
    _RGBForeColor
    _RGBBackColor
rsrc_MDEF_0_6AC_12C:    /* set up and call _PlotCIcon */
    movel %fp@(-36),%sp@-
    _PlotCIcon
    movel %fp@(-36),%sp@-
    _DisposCIcon
    jbra rsrc_MDEF_0_6AC_184
rsrc_MDEF_0_6AC_13A:    /* test #30,%a4@(1) */
    cmpib #30,%a4@(1)
    jbne rsrc_MDEF_0_6AC_14C
    clrl %sp@-
    movel #1397310286,%sp@-
    jbra rsrc_MDEF_0_6AC_154
rsrc_MDEF_0_6AC_14C:    /* clear %sp@- */
    clrl %sp@-
    movel #1229147982,%sp@-
rsrc_MDEF_0_6AC_154:    /* set up and call _GetResource */
    movew #256,%d0
    moveb %a4@,%d0
    movew %d0,%sp@-
    _GetResource
    movel #1048592,%d0
    moveq #2,%d1
    cmpib #30,%a4@(1)
    jbeq rsrc_MDEF_0_6AC_172
    addl %d0,%d0
    addl %d1,%d1
rsrc_MDEF_0_6AC_172:    /* set %sp@- */
    movel %d0,%sp@-
    movew %d1,%sp@-
    movew #10,%fp@(-26)
    jbsr rsrc_MDEF_0_CCA
    bsrw rsrc_MDEF_0_CCA_A4+0x2	| 40877EBC
rsrc_MDEF_0_6AC_184:    /* test %a4@(1) */
    tstb %a4@(1)
    jbeq rsrc_MDEF_0_6AC_200
    cmpib #28,%a4@(1)
    jbeq rsrc_MDEF_0_6AC_200
    cmpib #29,%a4@(1)
    jbeq rsrc_MDEF_0_6AC_200
    cmpib #30,%a4@(1)
    jbeq rsrc_MDEF_0_6AC_200
    movew #16,%fp@(-26)
    jbsr rsrc_MDEF_0_CCA
    movew %fp@(-4),%d0
    addw %d0,%d0
    subw %d0,%d6
    movew %d6,%sp@-
    tstb TESysJust_1
    bpls rsrc_MDEF_0_6AC_184_40
    addqw #2,%d5
    movew %d5,%sp@
    addw %d0,%d5
    addw %d0,%d6
rsrc_MDEF_0_6AC_184_40:
    movew %d3,%sp@-
    _MoveTo
    cmpib #27,%a4@(1)
    bnes rsrc_MDEF_0_6AC_184_52
    bsrw rsrc_MDEF_0_97E
    bras rsrc_MDEF_0_6AC_200
rsrc_MDEF_0_6AC_184_52:
    moveb TESysJust_1,%d1
    extw %d1
    bnes rsrc_MDEF_0_6AC_184_6C
    movew #17,%sp@-
    _DrawChar
    clrw %d0
    moveb %a4@(1),%d0
    movew %d0,%sp@-
    _DrawChar
    bras rsrc_MDEF_0_6AC_200
rsrc_MDEF_0_6AC_184_6C:
    clrw %d0
    moveb %a4@(1),%d0
    movew %d0,%sp@-
    _DrawChar
    movew #17,%sp@-
    _DrawChar	| 40877F3A
rsrc_MDEF_0_6AC_200:    /* set %fp@(-26) */
    movew #10,%fp@(-26)
    jbsr rsrc_MDEF_0_CCA
    clrw %d0
    moveb %a4@(3),%d0
    movew %d0,%sp@-
    _TextFace
    cmpib #28,%a4@(1)
    bnes rsrc_MDEF_0_6AC_200_22
    moveb %a4@,%d0
    bsrw rsrc_MDEF_0_960
rsrc_MDEF_0_6AC_200_22:
    moveb TESysJust_1,%d1
    extw %d1
    bnes rsrc_MDEF_0_6AC_200_36
    movew %d5,%sp@-
    movew %d3,%sp@-
    _MoveTo
    movel %a2,%sp@-
    _DrawString
    bras rsrc_MDEF_0_6AC_200_60
rsrc_MDEF_0_6AC_200_36:
    lea Scratch8,%a0
    subqw #1,%d5
    movew %d3,%a0@
    movew %fp@(-8),%d0
    subw %d0,%a0@+
    movew %d5,%a0@+
    movew %d3,%a0@
    movew %fp@(-6),%d0
    addw %d0,%a0@+
    movew %d6,%a0@
    moveq #0,%d0
    moveb %a2@+,%d0
    movel %a2,%sp@-
    movel %d0,%sp@-
    pea Scratch8
    movew %d1,%sp@-
    _TextBox
rsrc_MDEF_0_6AC_200_60:
    clrl %sp@-
    _TextFace
    _TextFont
    jbsr rsrc_MDEF_0_3B6
    jbne rsrc_MDEF_0_6AC_26E
    jbsr rsrc_MDEF_0_922
rsrc_MDEF_0_6AC_26E:    /* call rsrc_MDEF_0_CA8 */
    jbsr rsrc_MDEF_0_CA8
    moveq #1,%d0
rsrc_MDEF_0_6AC_274:    /* return */
    rts

/* subroutine (20 instructions): calls rsrc_MDEF_0_396, rsrc_MDEF_0_4AE; low memory Scratch8 (mechanical summary) */
rsrc_MDEF_0_922:
    moveml %d3/%d7,%sp@-
    tstb %a4@
    jbeq rsrc_MDEF_0_922_10
    movew %d7,%d0
    lsrw #1,%d0
    subw %d0,%d7
    addw %d7,%d3
rsrc_MDEF_0_922_10:     /* from here: addw %fp@(-2),%d3 */
    addw %fp@(-2),%d3
    lea Scratch8,%a0
    moveal %fp@(16),%a1
    movel %a1@,%a0@
    movel %a1@(4),%a0@(4)
    subw %fp@(-8),%d3
    movew %d3,%a0@(4)
    jbsr rsrc_MDEF_0_396
    subw %d0,%d3
    movew %d3,%a0@
    jbsr rsrc_MDEF_0_4AE
    moveml %sp@+,%d3/%d7
    rts

/* Draw dimmed text: through an off-screen bitmap, gray pattern (CopyBits). */
rsrc_MDEF_0_960:
    clrl %sp@-	| 40877FF0
    andiw #255,%d0	| 40877FF2
    movew %d0,%sp@-	| 40877FF6
    movew #12,%sp@-	| 40877FF8
    .byte   0x2F, 0x3C, 0x84, 0x04	| 40877FFC
rsrc_MDEF_0_970:        /* (data) */
    .byte   0x00, 0x0C	| 40878000
    _ScriptUtil	| 40878002
    movel %sp@+,%d0
    blts rsrc_MDEF_0_970_C
    movew %d0,%sp@-
    _TextFont
rsrc_MDEF_0_970_C:
    rts	| 4087800C

rsrc_MDEF_0_97E:        /* set up and call _GetPen */
    moveml %d4/%a3,%sp@-
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPen
    movel %sp@+,%d4
    swap %d4
    subw %fp@(-8),%d4
    swap %d4
    movel %d4,%fp@(-44)
    movel %d4,%fp@(-40)
    movew %fp@(-2),%d4
    cmpiw #16,%d4
    jble rsrc_MDEF_0_97E_2A
    movew #16,%d4
rsrc_MDEF_0_97E_2A:     /* from here: addw %d4,%fp@(-40) */
    addw %d4,%fp@(-40)
    addw %d4,%fp@(-38)
    moveq #14,%d0
    .short  0xA122	| 40878042 _NewHandle (flags 0x0100)
    _HLock
    moveal %a0@,%a3
    movew #2,%a3@(4)
    clrl %a3@(6)
    movel #1048592,%a3@(10)
    lea %pc@(rsrc_MDEF_0_DAE),%a1
    movel %a1,%a3@
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    moveal %sp@+,%a0
    movel %a3,%sp@-
    pea %a0@(2)
    pea %a3@(6)
    pea %fp@(-44)
    movew #1,%sp@-
    clrl %sp@-
    _CopyBits
    moveal %a3,%a0
    .short  0xA128	| 40878080 _RecoverHandle (flags 0x0100)
    _DisposHandle
    moveml %sp@+,%d4/%a3
    rts

/* Find item d0: its text, attributes and position (walks the menu record's item list). */
rsrc_MDEF_0_9FA:
    tstw %d0
    jble rsrc_MDEF_0_9FA_1C
    moveq #0,%d1
    lea %a0@(14),%a1
    moveb %a1@+,%d1
    addaw %d1,%a1
rsrc_MDEF_0_9FA_E:      /* loop: subq */
    subqw #1,%d0
    jbeq rsrc_MDEF_0_9FA_2C
    moveb %a1@+,%d1
    jbeq rsrc_MDEF_0_9FA_1C
    addqw #4,%d1
    addaw %d1,%a1
    jbra rsrc_MDEF_0_9FA_E
rsrc_MDEF_0_9FA_1C:     /* loop: suba */
    subal %a0,%a0
    moveal %a0,%a1
    movel %a0,%d0
    clrl %fp@(-64)
    clrl %fp@(-68)
    rts
rsrc_MDEF_0_9FA_2C:     /* test %a1@ */
    tstb %a1@
    jbeq rsrc_MDEF_0_9FA_1C
    moveal %a1,%a0
    moveb %a1@+,%d1
    addaw %d1,%a1
    movel %a0,%fp@(-64)
    movel %a1,%fp@(-68)
    rts

/*
 Message 2, size: compute the menu's width and height (widest item, icons, command keys)
 into the menu record.
*/
rsrc_MDEF_0_A3A:
    clrw %sp@-	| 408780CA
    _TextFont	| 408780CC
    jbsr rsrc_MDEF_0_308	| 408780CE
    subql #4,%sp	| 408780D2
    movel %sp,%sp@-	| 408780D4
    _GetPort	| 408780D6
    moveal %sp@+,%a0	| 408780D8
    movew %a0@(20),%d5	| 408780DA
    subw %a0@(16),%d5	| 408780DE
    tstw ROM85	| 408780E2
    jbmi rsrc_MDEF_0_A5E	| 408780E6
    subw MBarHeight,%d5	| 408780E8
    jbne rsrc_MDEF_0_A62	| 408780EC
rsrc_MDEF_0_A5E:        /* from here: subiw #20,%d5 */
    subiw #20,%d5	| 408780EE
rsrc_MDEF_0_A62:        /* from here: subiw #16,%d5 */
    subiw #16,%d5	| 408780F2
    moveq #0,%d6	| 408780F6
    moveq #1,%d0	| 408780F8
    moveal %a3@,%a0	| 408780FA
    jbsr rsrc_MDEF_0_9FA	| 408780FC
    jbeq rsrc_MDEF_0_B06	| 408780FE
    moveal %a0,%a4	| 40878102
rsrc_MDEF_0_A74:        /* loop: moveq */
    moveq #0,%d7	| 40878104
    moveal %a3@,%a0	| 40878106
    moveq #0,%d0	| 40878108
    moveb %a4@,%d0	| 4087810A
    jbeq rsrc_MDEF_0_B04	| 4087810C
    lea %a4@(1,%d0:w),%a1	| 40878110
    jbsr rsrc_MDEF_0_3A4	| 40878114
    swap %d1	| 40878118
    movew %d1,%d7	| 4087811A
    addw %fp@(-10),%d7	| 4087811C
    swap %d6	| 40878120
    addw %d0,%d6	| 40878122
    cmpw %d5,%d6	| 40878124
    jblt rsrc_MDEF_0_A9A	| 40878126
    subw %d0,%d6	| 40878128
rsrc_MDEF_0_A9A:        /* from here: swap %d6 */
    swap %d6	| 4087812A
    movew %fp@(-4),%d1	| 4087812C
    addw %d1,%d7	| 40878130
    cmpib #28,%a1@(1)	| 40878132
    jbeq rsrc_MDEF_0_AC6	| 40878138
    cmpib #29,%a1@(1)	| 4087813A
    jbeq rsrc_MDEF_0_AC6	| 40878140
    cmpib #30,%a1@(1)	| 40878142
    jbeq rsrc_MDEF_0_AC6	| 40878148
    tstb %a1@(1)	| 4087814A
    jbeq rsrc_MDEF_0_AC6	| 4087814E
    addw %d1,%d7	| 40878150
    addw %d1,%d7	| 40878152
    addqw #8,%d7	| 40878154
rsrc_MDEF_0_AC6:        /* clear %d1 */
    moveq #0,%d1	| 40878156
    moveb %a1@(3),%d1	| 40878158
    movew %d1,%sp@-	| 4087815C
    _TextFace	| 4087815E
    cmpib #28,%a1@(1)	| 40878160
    jbne rsrc_MDEF_0_AEA	| 40878166
    moveb %a1@,%d0	| 40878168
    jbsr rsrc_MDEF_0_960	| 4087816A
    clrw %sp@-	| 4087816E
    movel %a4,%sp@-	| 40878170
    _StringWidth	| 40878172
    clrw %sp@-	| 40878174
    _TextFont	| 40878176
    jbra rsrc_MDEF_0_AF0	| 40878178
rsrc_MDEF_0_AEA:        /* clear %sp@- */
    clrw %sp@-	| 4087817A
    movel %a4,%sp@-	| 4087817C
    _StringWidth	| 4087817E
rsrc_MDEF_0_AF0:        /* from here: addw %sp@+,%d7 */
    addw %sp@+,%d7	| 40878180
    cmpw %d7,%d6	| 40878182
    jbge rsrc_MDEF_0_AF8	| 40878184
    movew %d7,%d6	| 40878186
rsrc_MDEF_0_AF8:        /* clear %d0 */
    moveq #0,%d0	| 40878188
    moveb %a4@,%d0	| 4087818A
    lea %a4@(5,%d0:w),%a4	| 4087818C
    jbra rsrc_MDEF_0_A74	| 40878190
rsrc_MDEF_0_B04:        /* add 4 to %d6 */
    addqw #4,%d6	| 40878194
rsrc_MDEF_0_B06:        /* subtract 4 to %sp */
    subql #4,%sp	| 40878196
    movel %sp,%sp@-	| 40878198
    _GetPort	| 4087819A
    moveal %sp@+,%a0	| 4087819C
    movew %a0@(22),%d0	| 4087819E
    subw %a0@(18),%d0	| 408781A2
    subiw #16,%d0	| 408781A6
    cmpw %d0,%d6	| 408781AA
    jble rsrc_MDEF_0_B20	| 408781AC
    movew %d0,%d6	| 408781AE
rsrc_MDEF_0_B20:        /* set %a0 */
    moveal %a3@,%a0	| 408781B0
    movew %d6,%a0@(2)	| 408781B2
    swap %d6	| 408781B6
    movew %d6,%a0@(4)	| 408781B8
    clrw %sp@-	| 408781BC
    _TextFace	| 408781BE
    rts	| 408781C0

/*
 Message 3, pop-up: place a pop-up menu so that the item whichItem is at hitPt, kept on
 the screen; the top in whichItem on return.
*/
rsrc_MDEF_0_B32:
    jbsr rsrc_MDEF_0_308	| 408781C2
    moveal %fp@(8),%a4	| 408781C6
    movew %a4@,%d3	| 408781CA
    clrw %d2	| 408781CC
    clrw %d6	| 408781CE
    moveq #1,%d4	| 408781D0
rsrc_MDEF_0_B42:        /* loop: cmp */
    cmpw %d3,%d4	| 408781D2
    jbgt rsrc_MDEF_0_B48	| 408781D4
    movew %d6,%d2	| 408781D6
rsrc_MDEF_0_B48:        /* set %a0 */
    moveal %a3@,%a0	| 408781D8
    movew %d4,%d0	| 408781DA
    jbsr rsrc_MDEF_0_9FA	| 408781DC
    jbeq rsrc_MDEF_0_B5C	| 408781E0
    jbsr rsrc_MDEF_0_3A4	| 408781E2
    addw %d0,%d6	| 408781E6
    addqw #1,%d4	| 408781E8
    jbra rsrc_MDEF_0_B42	| 408781EA
rsrc_MDEF_0_B5C:        /* test %d2 */
    tstw %d2	| 408781EC
    jbne rsrc_MDEF_0_B62	| 408781EE
    moveq #1,%d4	| 408781F0
rsrc_MDEF_0_B62:        /* set %a0 */
    moveal %a3@,%a0	| 408781F2
    tstl %a0@(2)	| 408781F4
    jbpl rsrc_MDEF_0_B72	| 408781F8
    movel %d2,%sp@-	| 408781FA
    movel %a3,%sp@-	| 408781FC
    _CalcMenuSize	| 408781FE
    movel %sp@+,%d2	| 40878200
rsrc_MDEF_0_B72:        /* subtract 4 to %sp */
    subqw #4,%sp	| 40878202
    movel %sp,%sp@-	| 40878204
    _GetPort	| 40878206
    moveal %sp@+,%a1	| 40878208
    moveal %fp@(16),%a0	| 4087820A
    moveal %a3@,%a2	| 4087820E
    movew %fp@(14),%d5	| 40878210
    movew %d5,%d4	| 40878214
    subw %d2,%d4	| 40878216
    cmpiw #0,%d3	| 40878218
    jbne rsrc_MDEF_0_B9C	| 4087821C
    movew %a1@(20),%d0	| 4087821E
    subw %d5,%d0	| 40878222
    subqw #8,%d0	| 40878224
    cmpw %d6,%d0	| 40878226
    jblt rsrc_MDEF_0_BF8	| 40878228
    jbra rsrc_MDEF_0_BAA	| 4087822A
rsrc_MDEF_0_B9C:        /* set %d0 */
    movew %a1@(20),%d0	| 4087822C
    subw %a1@(16),%d0	| 40878230
    subqw #8,%d0	| 40878234
    cmpw %d6,%d0	| 40878236
    jblt rsrc_MDEF_0_BF8	| 40878238
rsrc_MDEF_0_BAA:        /* set %a0@ */
    movew %d4,%a0@	| 4087823A
    movew %d4,%a4@	| 4087823C
    movew %d4,%a0@(4)	| 4087823E
    addw %d6,%a0@(4)	| 40878242
    movew %a1@(16),%d0	| 40878246
    addw MBarHeight,%d0	| 4087824A
    addqw #2,%d0	| 4087824E
    cmpw %d0,%d4	| 40878250
    jbge rsrc_MDEF_0_BD8	| 40878252
    movew %d4,%d1	| 40878254
rsrc_MDEF_0_BC6:        /* loop: add */
    addw %fp@(-2),%d1	| 40878256
    cmpw %d0,%d1	| 4087825A
    jblt rsrc_MDEF_0_BC6	| 4087825C
    movew %d1,%a0@	| 4087825E
    addw %d6,%d1	| 40878260
    movew %d1,%a0@(4)	| 40878262
    jbra rsrc_MDEF_0_C42	| 40878266
rsrc_MDEF_0_BD8:        /* set %d0 */
    movew %d4,%d0	| 40878268
    addw %d6,%d0	| 4087826A
    movew %a1@(20),%d1	| 4087826C
    subqw #5,%d1	| 40878270
    cmpw %d1,%d0	| 40878272
    jble rsrc_MDEF_0_C42	| 40878274
rsrc_MDEF_0_BE6:        /* loop: su */
    subw %fp@(-2),%d0	| 40878276
    cmpw %d1,%d0	| 4087827A
    jbgt rsrc_MDEF_0_BE6	| 4087827C
    movew %d0,%a0@(4)	| 4087827E
    subw %d6,%d0	| 40878282
    movew %d0,%a0@	| 40878284
    jbra rsrc_MDEF_0_C42	| 40878286
rsrc_MDEF_0_BF8:        /* set %a4@ */
    movew %d4,%a4@	| 40878288
    movew %d4,%d1	| 4087828A
    movew %d1,%a0@	| 4087828C
    cmpiw #0,%d3	| 4087828E
    jbeq rsrc_MDEF_0_C2C	| 40878292
    movew %a1@(16),%d0	| 40878294
    addqw #2,%d0	| 40878298
    cmpw %d0,%d4	| 4087829A
    jble rsrc_MDEF_0_C20	| 4087829C
    movew %d4,%d1	| 4087829E
rsrc_MDEF_0_C10:        /* loop: su */
    subw %fp@(-2),%d1	| 408782A0
    cmpw %d0,%d1	| 408782A4
    jbge rsrc_MDEF_0_C10	| 408782A6
    addw %fp@(-2),%d1	| 408782A8
    movew %d1,%a0@	| 408782AC
    jbra rsrc_MDEF_0_C2C	| 408782AE
rsrc_MDEF_0_C20:        /* set %d1 */
    movew %d4,%d1	| 408782B0
rsrc_MDEF_0_C22:        /* loop: add */
    addw %fp@(-2),%d1	| 408782B2
    cmpw %d0,%d1	| 408782B6
    jblt rsrc_MDEF_0_C22	| 408782B8
    movew %d1,%a0@	| 408782BA
rsrc_MDEF_0_C2C:        /* set %d0 */
    movew %a1@(20),%d0	| 408782BC
    subqw #5,%d0	| 408782C0
rsrc_MDEF_0_C32:        /* loop: add */
    addw %fp@(-2),%d1	| 408782C2
    cmpw %d0,%d1	| 408782C6
    jble rsrc_MDEF_0_C32	| 408782C8
    subw %fp@(-2),%d1	| 408782CA
    movew %d1,%a0@(4)	| 408782CE
rsrc_MDEF_0_C42:        /* set %d0 */
    movew %fp@(12),%d0	| 408782D2
    movew %a1@(18),%d2	| 408782D6
    addqw #4,%d2	| 408782DA
    cmpw %d2,%d0	| 408782DC
    jbge rsrc_MDEF_0_C52	| 408782DE
    movew %d2,%d0	| 408782E0
rsrc_MDEF_0_C52:        /* set %d1 */
    movew %d0,%d1	| 408782E2
    addw %a2@(2),%d1	| 408782E4
    movew %a1@(22),%d2	| 408782E8
    subqw #4,%d2	| 408782EC
    cmpw %d2,%d1	| 408782EE
    jble rsrc_MDEF_0_C6A	| 408782F0
    movew %d2,%d1	| 408782F2
    movew %d1,%d0	| 408782F4
    subw %a2@(2),%d0	| 408782F6
rsrc_MDEF_0_C6A:        /* set %a0@(2) */
    movew %d0,%a0@(2)	| 408782FA
    movew %d1,%a0@(6)	| 408782FE
    rts	| 40878302

/* Save the port's colours (and the deepest screen's depth). */
rsrc_MDEF_0_C74:
    tstb %fp@(-60)
    jbeq rsrc_MDEF_0_C74_32
    pea %fp@(-16)
    pea %fp@(-22)
    _GetBackColor
    _GetForeColor
    subqw #4,%sp
    movel %sp,%sp@-
    _GetPort
    moveal %sp@+,%a0
    subqw #4,%sp
    pea %a0@(16)
    _GetMaxDevice
    moveal %sp@+,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a1
    moveal %a1@,%a1
    movew %a1@(32),%fp@(-24)
rsrc_MDEF_0_C74_32:     /* return */
    rts

/* Restore the saved colours. */
rsrc_MDEF_0_CA8:
    tstb %fp@(-60)
    jbeq rsrc_MDEF_0_CA8_14
    pea %fp@(-16)
    pea %fp@(-22)
    _RGBBackColor
    _RGBForeColor
    jbra rsrc_MDEF_0_CA8_20
rsrc_MDEF_0_CA8_14:     /* set up and call _ForeColor */
    moveq #33,%d0
    movel %d0,%sp@-
    _ForeColor
    moveq #30,%d0
    movel %d0,%sp@-
    _BackColor
rsrc_MDEF_0_CA8_20:     /* return */
    rts

/*
 Colours of a menu item from the menu colour table (GetMCEntry: item, menu title, bar
 defaults).
*/
rsrc_MDEF_0_CCA:
    tstb %fp@(-60)
    jbeq rsrc_MDEF_0_CCA_8C
    cmpiw #2,%fp@(-24)
    jblt rsrc_MDEF_0_CCA_72
    tstw %fp@(-28)
    jbeq rsrc_MDEF_0_CCA_1C
    movew #10,%fp@(-26)
rsrc_MDEF_0_CCA_1C:     /* subtract 4 to %sp */
    subqw #4,%sp
    moveal %a3@,%a0
    movew %a0@,%sp@-
    movew %d4,%sp@-
    _GetMCEntry
    movel %sp@+,%d1
    jbeq rsrc_MDEF_0_CCA_3A
    moveal %d1,%a0
    movew %fp@(-26),%d0
    pea %a0@(0x0,%d0:w)
    pea %a0@(22)
    jbra rsrc_MDEF_0_CCA_7A
rsrc_MDEF_0_CCA_3A:     /* subtract 4 to %sp */
    subqw #4,%sp
    moveal %a3@,%a0
    movew %a0@,%sp@-
    clrw %sp@-
    _GetMCEntry
    movel %sp@+,%d1
    jbeq rsrc_MDEF_0_CCA_58
    moveal %d1,%a0
    movew #16,%d0
    pea %a0@(0x0,%d0:w)
    pea %a0@(22)
    jbra rsrc_MDEF_0_CCA_7A
rsrc_MDEF_0_CCA_58:     /* set up and call _GetMCEntry */
    subqw #4,%sp
    clrl %sp@-
    _GetMCEntry
    movel %sp@+,%d1
    jbeq rsrc_MDEF_0_CCA_72
    moveal %d1,%a0
    movew #16,%d0
    pea %a0@(0x0,%d0:w)
    pea %a0@(10)
    jbra rsrc_MDEF_0_CCA_7A
rsrc_MDEF_0_CCA_72:     /* from here: pea 0xc10 */
    pea RGBBlack
    pea RGBWhite
rsrc_MDEF_0_CCA_7A:     /* set up and call _RGBForeColor */
    tstw %fp@(-28)
    jbeq rsrc_MDEF_0_CCA_86
    _RGBForeColor
    _RGBBackColor
    jbra rsrc_MDEF_0_CCA_A4
rsrc_MDEF_0_CCA_86:     /* _RGBBackColor */
    _RGBBackColor
    _RGBForeColor
    jbra rsrc_MDEF_0_CCA_A4
rsrc_MDEF_0_CCA_8C:     /* set %d0 */
    moveq #33,%d0
    movel %d0,%sp@-
    moveq #30,%d0
    movel %d0,%sp@-
    tstw %fp@(-28)
    jbeq rsrc_MDEF_0_CCA_A0
    _ForeColor
    _BackColor
    jbra rsrc_MDEF_0_CCA_A4
rsrc_MDEF_0_CCA_A0:     /* _BackColor */
    _BackColor
    _ForeColor
rsrc_MDEF_0_CCA_A4:     /* return */
    rts
    lea IconBitmap,%a1
    movel %sp@(10),%d0
    beqs rsrc_MDEF_0_CCA_A4_38
    moveal %d0,%a0
    movel %a0@,%a1@+
    movew %sp@(4),%a1@+
    clrl %a1@+
    movel %sp@(6),%a1@
    movel %sp@(14),%d1
    lea IconBitmap,%a1
    movel %a1,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    pea %a0@(2)
    pea %a1@(6)
    movel %d1,%sp@-
    clrw %sp@-
    clrl %sp@-
    _CopyBits
rsrc_MDEF_0_CCA_A4_38:
    moveal %sp@+,%a0
    lea %sp@(14),%sp
    jmp %a0@
rsrc_MDEF_0_DAE:        /* (data) */
    .short  0x0000	| 4087843E
    .long   0x00000020, 0x00300038, 0x003C003E, 0x003F003E	| 40878440
    .short  0x003C, 0x0038, 0x0030, 0x0020, 0x0000, 0x0000, 0x0000	| 40878450
rsrc_MDEF_0_DCE:        /* (data) */
    .short  0x0000	| 4087845E
    .long   0x00000000, 0x00000000, 0x7FF03FE0, 0x1FC00F80	| 40878460
    .short  0x0700, 0x0200, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40878470
rsrc_MDEF_0_DEE:        /* (data) */
    .short  0x0000	| 4087847E
    .long   0x00000000, 0x00000000, 0x02000700, 0x0F801FC0	| 40878480
    .long   0x3FE07FF0, 0x00000000, 0x00000000, 0x00000000	| 40878490
