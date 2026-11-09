/* ROM resource 'MBDF' 0: map entry at 0x408784A0, data at 0x408784D0, 3520 bytes

 Menu bar definition 0: draws and tracks the menu bar and saves and restores the screen
 behind menus, in the menu colours ('mctb') on Color QuickDraw. Messages 0-13 dispatch
 through rsrc_MBDF_0_9A. Comments inferred from the code (and the menu bar definition
 messages in Inside Macintosh).
*/

rsrc_MBDF_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 408784A0
    .long   rsrc_MDEF_0_entry-rom_start	| 408784A8
    .long   rsrc_MBDF_0-rom_start	| 408784AC
    .ascii  "MBDF"	| 408784B0
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408784B4
    .long   0x00000000, 0xC0A00000, 0x00000DCC, 0x000000FC	| 408784C0

/*
 Entry: a branch over the standard header ('MBDF', ID 0); MBarDefProc(selector,
 message, parameter1, parameter2): sets up the Window Manager port and system font, calls
 the routine for the message (out of range: SysError).
*/
rsrc_MBDF_0:
    jbra rsrc_MBDF_0_C
    .short  0x0000, 0x4D42, 0x4446, 0x0000, 0x000C	| 408784D2

rsrc_MBDF_0_C:          /* from here: linkw %fp,#-66 */
    linkw %fp,#-66
    moveml %d3-%d5/%a2-%a4,%sp@-
    moveal %a5@,%a0
    movel %a0@,%sp@-
    clrw %fp@(-58)
    cmpiw #16383,ROM85
    sls %fp@(-58)
    moveal ROMBase,%a0
    cmpib #3,%a0@(8)
    jbne rsrc_MBDF_0_C_32
    tstb NTSC
    jbne rsrc_MBDF_0_C_32
    bset #7,%fp@(-57)
rsrc_MBDF_0_C_32:       /* test %fp@(-58) */
    tstb %fp@(-58)
    jbeq rsrc_MBDF_0_C_3E
    moveal ghost_WMgrCPort,%a2
    jbra rsrc_MBDF_0_C_42
rsrc_MBDF_0_C_3E:       /* set %a2 */
    moveal WMgrPort,%a2
rsrc_MBDF_0_C_42:       /* set up and call _SetPort */
    movel %a2,%sp@-
    _SetPort
    clrl %sp@-
    _TextFont
    _TextFace
    moveal MenuList,%a0
    tstl %a0@
    jbne rsrc_MBDF_0_C_58
    moveq #84,%d0
    _SysError
rsrc_MBDF_0_C_58:       /* _HLock */
    _HLock
    moveal %a0@,%a3
    lea %pc@(rsrc_MBDF_0_9A),%a0
    movew %fp@(14),%d0
    cmpiw #13,%d0
    jbhi rsrc_MBDF_0_C_78
    cmpiw #0,%d0
    jbcs rsrc_MBDF_0_C_78
    addw %d0,%d0
    addaw %pc@(rsrc_MBDF_0_9A,%d0:w),%a0
    jsr %a0@
rsrc_MBDF_0_C_78:       /* _SetPort */
    _SetPort
    moveal MenuList,%a0
    _HUnlock
    moveml %sp@+,%d3-%d5/%a2-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw #10,%sp
    jmp %a0@
rsrc_MBDF_0_9A:         /* message table (offsets from here): 0 draw, 1 hit, 2 calculate, 3 init, 4 dispose, 5 hilite, 6 height, 7 save, 8 restore, 9 rectangle, 10 save alternate, 11 reset alternate, 12 menu bar region, 13 (later addition) */
    .short  rsrc_MBDF_0_134-rsrc_MBDF_0_9A	| 4087856A
    .short  rsrc_MBDF_0_458-rsrc_MBDF_0_9A	| 4087856C
    .short  rsrc_MBDF_0_4E0-rsrc_MBDF_0_9A	| 4087856E
    .short  rsrc_MBDF_0_C0-rsrc_MBDF_0_9A	| 40878570
    .short  rsrc_MBDF_0_E0-rsrc_MBDF_0_9A	| 40878572
    .short  rsrc_MBDF_0_524-rsrc_MBDF_0_9A	| 40878574
    .short  rsrc_MBDF_0_E2-rsrc_MBDF_0_9A	| 40878576
    .short  rsrc_MBDF_0_68C-rsrc_MBDF_0_9A	| 40878578
    .short  rsrc_MBDF_0_ADA-rsrc_MBDF_0_9A	| 4087857A
    .short  rsrc_MBDF_0_B98-rsrc_MBDF_0_9A	| 4087857C
    .short  rsrc_MBDF_0_BD8-rsrc_MBDF_0_9A	| 4087857E
    .short  rsrc_MBDF_0_C02-rsrc_MBDF_0_9A	| 40878580
    .short  rsrc_MBDF_0_C2C-rsrc_MBDF_0_9A	| 40878582
    .short  rsrc_MBDF_0_C50-rsrc_MBDF_0_9A	| 40878584

/* Restore the clip region. */
rsrc_MBDF_0_B6:
    moveal %a5@,%a0	| 40878586
    movel %a0@(-130),%sp@-	| 40878588
    _SetClip	| 4087858C
    rts	| 4087858E

/* Message 3, init: allocate the save-bits list. */
rsrc_MBDF_0_C0:
    cmpil #-1,0xb5c	| 40878590
    jbne rsrc_MBDF_0_D6	| 40878598
    movel #168,%d0	| 4087859A
    .short  0xA722	| 408785A0 _NewHandle (flags 0x0700)
    movel %a0,0xb5c	| 408785A2
rsrc_MBDF_0_D6:         /* set %a0 */
    moveal 0xb5c,%a0	| 408785A6
    moveal %a0@,%a0	| 408785AA
    clrw %a0@	| 408785AC
    rts	| 408785AE

/* Message 4, dispose: nothing. */
rsrc_MBDF_0_E0:
    rts	| 408785B0

/* Message 6, height: the menu bar height from the system font (MBarHeight). */
rsrc_MBDF_0_E2:
    jbsr rsrc_MBDF_0_F2
    moveq #3,%d1
    addw %d0,%d1
    swap %d0
    addw %d0,%d1
    movew %d1,MBarHeight
    rts

/* subroutine (10 instructions): traps GetFontInfo (mechanical summary) */
rsrc_MBDF_0_F2:
    subqw #8,%sp
    movel %sp,%sp@-
    _GetFontInfo
    movel %sp@+,%d0
    swap %d0
    addw %sp@(2),%d0
    addqw #1,%d0
    swap %d0
    addqw #4,%sp
    rts

/* subroutine (6 instructions): calls rsrc_MBDF_0_F2 (mechanical summary) */
rsrc_MBDF_0_108:
    jbsr rsrc_MBDF_0_F2
    swap %d0
    addw %a2@(16),%d0
    moveq #0,%d4
    movew %d0,%d4
    rts

/* subroutine (9 instructions): traps SetRecRgn (mechanical summary) */
rsrc_MBDF_0_116:
    movel %a2@(28),%sp@-	| 408785E6
    movew %a2@(18),%sp@-	| 408785EA
    movew %a2@(16),%sp@-	| 408785EE
    movew %a2@(22),%sp@-	| 408785F2
    movew %a2@(16),%sp@-	| 408785F6
    movew MBarHeight,%d0	| 408785FA
    addw %d0,%sp@	| 408785FE
    _SetRecRgn	| 40878600
    rts	| 40878602

/*
 Message 0, draw: the menu bar (rounded top corners on the main screen), each menu title
 (text or colour icon), dimmed titles of disabled menus, the bottom line.
*/
rsrc_MBDF_0_134:
    jbsr rsrc_MBDF_0_116	| 40878604
    movel %fp@(8),%d3	| 40878606
    jbgt rsrc_MBDF_0_26A	| 4087860A
    tstb %fp@(-58)	| 4087860E
    jbeq rsrc_MBDF_0_17A	| 40878612
    jbsr rsrc_MBDF_0_2AC_86	| 40878614
    jbsr rsrc_MBDF_0_40E_2E	| 40878618
    cmpiw #2,%fp@(-30)	| 4087861C
    jblt rsrc_MBDF_0_17A	| 40878622
    subqw #4,%sp	| 40878624
    clrl %sp@-	| 40878626
    _GetMCEntry	| 40878628
    movel %sp@+,%d0	| 4087862A
    jbeq rsrc_MBDF_0_16E	| 4087862C
    moveal %d0,%a0	| 4087862E
    pea %a0@(4)	| 40878630
    pea %a0@(22)	| 40878634
    _RGBBackColor	| 40878638
    _RGBForeColor
    jbra rsrc_MBDF_0_17A	| 4087863C
rsrc_MBDF_0_16E:        /* from here: pea 0xc10 */
    pea RGBBlack	| 4087863E
    pea RGBWhite	| 40878642
    _RGBBackColor	| 40878646
    _RGBForeColor
rsrc_MBDF_0_17A:        /* from here: pea %a2@(16) */
    pea %a2@(16)	| 4087864A
    btst #7,%fp@(-57)	| 4087864E
    jbeq rsrc_MBDF_0_18A	| 40878654
    _EraseRect	| 40878656
    jbra rsrc_MBDF_0_192	| 40878658
rsrc_MBDF_0_18A:        /* set %sp@- */
    movel #1048592,%sp@-	| 4087865A
    .short  0xA8B2	| 40878660 _EraseRoundRect
rsrc_MBDF_0_192:        /* test %fp@(-58) */
    tstb %fp@(-58)	| 40878662
    jbeq rsrc_MBDF_0_1A4	| 40878666
    pea RGBBlack	| 40878668
    pea RGBWhite	| 4087866C
    _RGBBackColor	| 40878670
    _RGBForeColor
rsrc_MBDF_0_1A4:        /* set 0x9fa */
    movel %a2@(16),Scratch8	| 40878674
    movel %a2@(20),scratch8_4	| 4087867A
    lea Scratch8,%a0	| 40878680
    btst #7,%fp@(-57)	| 40878684
    jbne rsrc_MBDF_0_1DC	| 4087868A
    movel %a0,%sp@-	| 4087868C
    movel #-131075,%sp@-	| 4087868E
    _InsetRect	| 40878694
    movel #196611,%sp@-	| 40878696
    _PenSize	| 4087869C
    lea Scratch8,%a0	| 4087869E
    movel %a0,%sp@-	| 408786A2
    movel #1441814,%sp@-	| 408786A4
    _FrameRoundRect	| 408786AA
rsrc_MBDF_0_1DC:        /* (408786AC A-line trap) */
    _PenNormal	| 408786AC
    movew %a2@(22),%sp@-	| 408786AE
    movew %a2@(18),%d0	| 408786B2
    swap %d0	| 408786B6
    movew %a2@(16),%d0	| 408786B8
    addw MBarHeight,%d0	| 408786BC
    subqw #1,%d0	| 408786C0
    movew %d0,%sp@-	| 408786C2
    swap %d0	| 408786C4
    movel %d0,%sp@-	| 408786C6
    _MoveTo	| 408786C8
    .short  0xA891	| _LineTo
    jbsr rsrc_MBDF_0_3EC	| 408786CC
    cmpil #-1,%fp@(8)	| 408786D0
    jbeq rsrc_MBDF_0_294	| 408786D8
    tstw %a3@	| 408786DC
    beqw rsrc_MBDF_0_290	| 408786DE
    clrw %fp@(-56)	| 408786E2
    moveq #6,%d3	| 408786E6
rsrc_MBDF_0_218:        /* loop: move */
    movew %d3,%d0	| 408786E8
    jbsr rsrc_MBDF_0_62E	| 408786EA
    moveal %a3@(0,%d3:w),%a0	| 408786EE
    _HLock	| 408786F2
    moveal %a0@,%a4	| 408786F4
    jbsr rsrc_MBDF_0_296	| 408786F6
    movew TheMenu,%d0	| 408786F8
    moveal %a3@(0,%d3:w),%a4	| 408786FC
    moveal %a4@,%a4	| 40878700
    cmpw %a4@,%d0	| 40878702
    jbne rsrc_MBDF_0_23A	| 40878704
    movew %d3,%fp@(-56)	| 40878706
rsrc_MBDF_0_23A:        /* set %a0 */
    moveal %a3@(0,%d3:w),%a0	| 4087870A
    _HUnlock	| 4087870E
    addqw #6,%d3	| 40878710
    cmpw %a3@,%d3	| 40878712
    jble rsrc_MBDF_0_218	| 40878714
    movew %fp@(-56),%d0	| 40878716
    jbeq rsrc_MBDF_0_290	| 4087871A
    movew %fp@(-56),%d0	| 4087871C
    movew %d0,%d3	| 40878720
    jbsr rsrc_MBDF_0_62E	| 40878722
    moveal %a3@(0,%d3:w),%a0	| 40878726
    _HLock	| 4087872A
    moveal %a0@,%a4	| 4087872C
    jbsr rsrc_MBDF_0_594	| 4087872E
    moveal %a3@(0,%d3:w),%a0	| 40878732
    _HUnlock	| 40878736
    jbra rsrc_MBDF_0_290	| 40878738
rsrc_MBDF_0_26A:        /* test %a3@,%d3 */
    cmpw %a3@,%d3	| 4087873A
    jbgt rsrc_MBDF_0_290	| 4087873C
    movel %d3,%d0	| 4087873E
    jbsr rsrc_MBDF_0_62E	| 40878740
    moveal %a3@(0,%d3:w),%a0	| 40878744
    _HLock	| 40878748
    moveal %a0@,%a4	| 4087874A
    jbsr rsrc_MBDF_0_296	| 4087874C
    movew TheMenu,%d0	| 4087874E
    cmpw %a4@,%d0	| 40878752
    jbne rsrc_MBDF_0_28A	| 40878754
    jbsr rsrc_MBDF_0_594	| 40878756
rsrc_MBDF_0_28A:        /* set %a0 */
    moveal %a3@(0,%d3:w),%a0	| 4087875A
    _HUnlock	| 4087875E
rsrc_MBDF_0_290:        /* call rsrc_MBDF_0_B6 */
    jbsr rsrc_MBDF_0_B6	| 40878760
rsrc_MBDF_0_294:        /* return */
    rts	| 40878764

/* subroutine (6 instructions) (mechanical summary) */
rsrc_MBDF_0_296:
    clrw %fp@(-26)	| 40878766
    cmpiw #6,%d3	| 4087876A
    jbne rsrc_MBDF_0_2AC	| 4087876E
    moveal 0xb5c,%a0	| 40878770
    moveal %a0@,%a0	| 40878774
    movew #-1,%a0@(18)	| 40878776

/* subroutine (11 instructions): traps MoveTo, EraseRect; calls rsrc_MBDF_0_108, rsrc_MBDF_0_2AC_94; low memory Scratch8 (mechanical summary) */
rsrc_MBDF_0_2AC:
    jbsr rsrc_MBDF_0_108
    movew %a3@(0x4,%d3:w),%sp@-
    movew %a2@(18),%d0
    addw %d0,%sp@
    addqw #8,%sp@
    movew %d4,%sp@-
    _MoveTo
    clrw %fp@(-28)
    jbsr rsrc_MBDF_0_2AC_94
    pea Scratch8
    _EraseRect

/*
 Draw one menu title (string, or a colour icon for an icon title such as the Apple or
 Help menu).
*/
rsrc_MBDF_0_2CC:
    movew #1,%sp@-
    _TextMode
    tstb %fp@(-58)
    jbeq rsrc_MBDF_0_2AC_76
    cmpiw #276,%a4@(14)
    jbne rsrc_MBDF_0_2AC_76
    jbsr rsrc_MBDF_0_40E_2E
    cmpiw #4,%fp@(-30)
    jblt rsrc_MBDF_0_2AC_76
    subql #4,%sp
    movew #20,%sp@-
    _GetCIcon
    movel %sp@+,%d0
    jbeq rsrc_MBDF_0_2AC_76
    moveal %d0,%a1
    moveal %a1@,%a0
    moveml %a0@(6),%d0-%d1
    moveml %d0-%d1,%fp@(-20)
    movel %a1,%sp@-
    pea %fp@(-20)
    movel %a1,%sp@-
    pea %fp@(-20)
    subql #4,%sp
    movel %sp,%sp@-
    _GetPen
    _OffsetRect
    _PlotCIcon
    _DisposCIcon
    jbra rsrc_MBDF_0_2AC_7C
rsrc_MBDF_0_2AC_76:     /* set up and call _DrawString */
    pea %a4@(14)
    _DrawString
rsrc_MBDF_0_2AC_7C:     /* call rsrc_MBDF_0_40E */
    jbsr rsrc_MBDF_0_40E
    jbsr rsrc_MBDF_0_3EC
    rts

/* subroutine (5 instructions): traps GetBackColor, GetForeColor (mechanical summary) */
rsrc_MBDF_0_2AC_86:
    pea %fp@(-44)
    _GetBackColor
    pea %fp@(-50)
    _GetForeColor
    rts

/* subroutine (62 instructions): traps GetMCEntry, RGBBackColor, RGBForeColor, BackColor, ForeColor; calls rsrc_MBDF_0_2AC_86, rsrc_MBDF_0_440 (mechanical summary) */
rsrc_MBDF_0_2AC_94:
    tstb %fp@(-58)
    jbeq rsrc_MBDF_0_2AC_126
    jbsr rsrc_MBDF_0_2AC_86
    tstw %fp@(-28)
    jbeq rsrc_MBDF_0_2AC_AA
    lea %fp@(-8),%a0
    jbra rsrc_MBDF_0_2AC_AE
rsrc_MBDF_0_2AC_AA:     /* address %a2@(16) */
    lea %a2@(16),%a0
rsrc_MBDF_0_2AC_AE:     /* call rsrc_MBDF_0_440 */
    jbsr rsrc_MBDF_0_440
    cmpiw #2,%fp@(-30)
    jblt rsrc_MBDF_0_2AC_108
    subqw #4,%sp
    movew %a4@,%sp@-
    clrw %sp@-
    _GetMCEntry
    movel %sp@+,%d0
    jbeq rsrc_MBDF_0_2AC_E2
    moveal %d0,%a0
    tstw %fp@(-28)
    jbeq rsrc_MBDF_0_2AC_D8
    pea %a0@(4)
    pea %a0@(22)
    jbra rsrc_MBDF_0_2AC_110
rsrc_MBDF_0_2AC_D8:     /* from here: pea %a0@(4) */
    pea %a0@(4)
    pea %a0@(10)
    jbra rsrc_MBDF_0_2AC_110
rsrc_MBDF_0_2AC_E2:     /* set up and call _GetMCEntry */
    subqw #4,%sp
    clrl %sp@-
    _GetMCEntry
    movel %sp@+,%d0
    jbeq rsrc_MBDF_0_2AC_108
    moveal %d0,%a0
    tstw %fp@(-28)
    jbeq rsrc_MBDF_0_2AC_FE
    pea %a0@(16)
    pea %a0@(10)
    jbra rsrc_MBDF_0_2AC_110
rsrc_MBDF_0_2AC_FE:     /* from here: pea %a0@(4) */
    pea %a0@(4)
    pea %a0@(22)
    jbra rsrc_MBDF_0_2AC_110
rsrc_MBDF_0_2AC_108:    /* from here: pea 0xc10 */
    pea RGBBlack
    pea RGBWhite
rsrc_MBDF_0_2AC_110:    /* test %fp@(-26) */
    tstw %fp@(-26)
    jbeq rsrc_MBDF_0_2AC_120
    moveal %sp@,%a0
    movel %sp@(4),%sp@
    movel %a0,%sp@(4)
rsrc_MBDF_0_2AC_120:    /* _RGBBackColor */
    _RGBBackColor
    _RGBForeColor
    jbra rsrc_MBDF_0_2AC_13E
rsrc_MBDF_0_2AC_126:    /* set %d0 */
    moveq #30,%d0
    movel %d0,%sp@-
    moveq #33,%d0
    movel %d0,%sp@-
    tstw %fp@(-26)
    jbeq rsrc_MBDF_0_2AC_13A
    _BackColor
    _ForeColor
    jbra rsrc_MBDF_0_2AC_13E
rsrc_MBDF_0_2AC_13A:    /* _ForeColor */
    _ForeColor
    _BackColor
rsrc_MBDF_0_2AC_13E:    /* return */
    rts

/* subroutine (14 instructions): traps RGBBackColor, RGBForeColor, BackColor, ForeColor (mechanical summary) */
rsrc_MBDF_0_3EC:
    tstb %fp@(-58)
    jbeq rsrc_MBDF_0_3EC_14
    pea %fp@(-50)
    pea %fp@(-44)
    _RGBBackColor
    _RGBForeColor
    jbra rsrc_MBDF_0_3EC_20
rsrc_MBDF_0_3EC_14:     /* set %d0 */
    moveq #33,%d0
    movel %d0,%sp@-
    moveq #30,%d0
    movel %d0,%sp@-
    _BackColor
    _ForeColor
rsrc_MBDF_0_3EC_20:     /* return */
    rts

/* subroutine (16 instructions): traps GetPenState, PenPat, PenMode, PaintRect, SetPenState; low memory Scratch8 (mechanical summary) */
rsrc_MBDF_0_40E:
    btst #0,%a4@(13)
    jbne rsrc_MBDF_0_40E_2C
    subaw #18,%sp
    movel %sp,%sp@-
    _GetPenState
    moveal %a5@,%a0
    pea %a0@(-24)
    _PenPat
    movew #11,%sp@-
    _PenMode
    pea Scratch8
    _PaintRect
    movel %sp,%sp@-
    _SetPenState
    lea %sp@(18),%sp
rsrc_MBDF_0_40E_2C:     /* return */
    rts

/* subroutine (1 instructions) (mechanical summary) */
rsrc_MBDF_0_40E_2E:
    lea %a2@(16),%a0

/* subroutine (9 instructions): traps GetMaxDevice (mechanical summary) */
rsrc_MBDF_0_440:
    subqw #4,%sp
    movel %a0,%sp@-
    _GetMaxDevice
    moveal %sp@+,%a0
    moveal %a0@,%a1
    moveal %a1@(22),%a1
    moveal %a1@,%a1
    movew %a1@(32),%fp@(-30)
    rts

/*
 Message 1, hit (param: the point): the menu title under it (index into the menu list),
 or -1 when in a menu, 0 outside.
*/
rsrc_MBDF_0_458:
    movel %fp@(8),%d1	| 40878928
    swap %d1	| 4087892C
    movew %a2@(16),%d0	| 4087892E
    cmpw %d0,%d1	| 40878932
    jblt rsrc_MBDF_0_4AA	| 40878934
    addw MBarHeight,%d0	| 40878936
    cmpw %d0,%d1	| 4087893A
    jbge rsrc_MBDF_0_4AA	| 4087893C
    swap %d1	| 4087893E
    movew %a2@(18),%d0	| 40878940
    cmpw %d0,%d1	| 40878944
    jblt rsrc_MBDF_0_4AA	| 40878946
    movew %a2@(22),%d0	| 40878948
    cmpw %d0,%d1	| 4087894C
    jbgt rsrc_MBDF_0_4AA	| 4087894E
    subw %a2@(18),%d1	| 40878950
    cmpw %a3@(2),%d1	| 40878954
    jbgt rsrc_MBDF_0_4A4	| 40878958
    cmpiw #10,%d1	| 4087895A
    jblt rsrc_MBDF_0_4A4	| 4087895E
    moveq #0,%d0	| 40878960
    movew %a3@,%d0	| 40878962
rsrc_MBDF_0_494:        /* loop: cmp */
    cmpw %a3@(4,%d0:w),%d1	| 40878964
    jbge rsrc_MBDF_0_49E	| 40878968
    subqw #6,%d0	| 4087896A
    jbra rsrc_MBDF_0_494	| 4087896C
rsrc_MBDF_0_49E:        /* set %fp@(18) */
    movel %d0,%fp@(18)	| 4087896E
rsrc_MBDF_0_4A2:        /* return */
    rts	| 40878972
rsrc_MBDF_0_4A4:        /* clear %fp@(18) */
    clrl %fp@(18)	| 40878974
    jbra rsrc_MBDF_0_4A2	| 40878978
rsrc_MBDF_0_4AA:        /* set %a0 */
    moveal 0xb5c,%a0	| 4087897A
    moveal %a0@,%a3	| 4087897E
    movew %a3@,%d3	| 40878980
    jbeq rsrc_MBDF_0_4D8	| 40878982
rsrc_MBDF_0_4B4:        /* loop: clr */
    clrw %sp@-	| 40878984
    movel %fp@(8),%sp@-	| 40878986
    pea %a3@(0,%d3:w)	| 4087898A
    _PtInRect	| 4087898E
    tstb %sp@+	| 40878990
    jbne rsrc_MBDF_0_4CC	| 40878992
    subiw #28,%d3	| 40878994
    jbeq rsrc_MBDF_0_4D8	| 40878998
    jbra rsrc_MBDF_0_4B4	| 4087899A
rsrc_MBDF_0_4CC:        /* clear %fp@(18) */
    clrl %fp@(18)	| 4087899C
    movew %a3@(0xe,%d3:w),%fp@(20)	| 408789A0
    jbra rsrc_MBDF_0_4A2	| 408789A6
rsrc_MBDF_0_4D8:        /* set %fp@(18) */
    movel MinusOne,%fp@(18)	| 408789A8
    jbra rsrc_MBDF_0_4A2	| 408789AE

/* Message 2, calculate: the positions of the menu titles (StringWidth of each title). */
rsrc_MBDF_0_4E0:
    tstw %a3@	| 408789B0
    jbeq rsrc_MBDF_0_522	| 408789B2
    movel %fp@(8),%d0	| 408789B4
    tstw %d0	| 408789B8
    jbeq rsrc_MBDF_0_4F6	| 408789BA
    cmpw %a3@,%d0	| 408789BC
    jbgt rsrc_MBDF_0_522	| 408789BE
    movew %a3@(4,%d0:w),%d3	| 408789C0
    jbra rsrc_MBDF_0_4FE	| 408789C4
rsrc_MBDF_0_4F6:        /* set %d3 */
    moveq #10,%d3	| 408789C6
    moveq #6,%d4	| 408789C8
    movew %d3,%a3@(4,%d4:w)	| 408789CA
rsrc_MBDF_0_4FE:        /* loop: movea */
    moveal %a3@(0,%d4:w),%a0	| 408789CE
    moveal %a0@,%a0	| 408789D2
    clrw %sp@-	| 408789D4
    pea %a0@(14)	| 408789D6
    _StringWidth	| 408789DA
    addw %sp@+,%d3	| 408789DC
    addiw #13,%d3	| 408789DE
    addqw #6,%d4	| 408789E2
    cmpw %a3@,%d4	| 408789E4
    jbgt rsrc_MBDF_0_51E	| 408789E6
    movew %d3,%a3@(4,%d4:w)	| 408789E8
    jbra rsrc_MBDF_0_4FE	| 408789EC
rsrc_MBDF_0_51E:        /* set %a3@(2) */
    movew %d3,%a3@(2)	| 408789EE
rsrc_MBDF_0_522:        /* return */
    rts	| 408789F2

/* Message 5, hilite: highlight or unhighlight a menu title (invert or menu colours). */
rsrc_MBDF_0_524:
    jbsr rsrc_MBDF_0_116	| 408789F4
    movew %fp@(10),%d0	| 408789F8
    cmpiw #0,%d0	| 408789FC
    beqw rsrc_MBDF_0_5B2	| 40878A00
    cmpw %a3@(2),%d0	| 40878A04
    jbgt rsrc_MBDF_0_568	| 40878A08
    jbsr rsrc_MBDF_0_62E	| 40878A0A
    moveq #0,%d3	| 40878A0E
    movew %fp@(10),%d3	| 40878A10
    cmpiw #1,%fp@(8)	| 40878A14
    jbgt rsrc_MBDF_0_568	| 40878A1A
    moveal %a3@(0,%d3:w),%a0	| 40878A1C
    _HLock	| 40878A20
    moveal %a0@,%a4	| 40878A22
    cmpiw #1,%fp@(8)	| 40878A24
    jbeq rsrc_MBDF_0_560	| 40878A2A
    jbsr rsrc_MBDF_0_56E	| 40878A2C
    jbra rsrc_MBDF_0_562	| 40878A2E
rsrc_MBDF_0_560:        /* call rsrc_MBDF_0_594 */
    jbsr rsrc_MBDF_0_594	| 40878A30
rsrc_MBDF_0_562:        /* set %a0 */
    moveal %a3@(0,%d3:w),%a0	| 40878A32
    _HUnlock	| 40878A36
rsrc_MBDF_0_568:        /* call rsrc_MBDF_0_B6 (loop) */
    jbsr rsrc_MBDF_0_B6	| 40878A38
    rts	| 40878A3C

/* subroutine (14 instructions): traps DrawMenuBar; calls rsrc_MBDF_0_AFA (mechanical summary) */
rsrc_MBDF_0_56E:
    movew %a3@,%d0	| 40878A3E
    addqw #6,%d0	| 40878A40
    moveal %a3@(2,%d0:w),%a0	| 40878A42
    clrl %a3@(2,%d0:w)	| 40878A46
    movel %a0,%d0	| 40878A4A
    jbne rsrc_MBDF_0_586	| 40878A4C
    clrw TheMenu	| 40878A4E
    _DrawMenuBar	| 40878A52
    jbra rsrc_MBDF_0_58E	| 40878A54
rsrc_MBDF_0_586:        /* set %sp@- */
    movel %a0,%sp@-	| 40878A56
    jbsr rsrc_MBDF_0_AFA	| 40878A58
    addqw #4,%sp	| 40878A5C
rsrc_MBDF_0_58E:        /* clear 0xa28 */
    clrl SavedHandle	| 40878A5E
    rts	| 40878A62

/* Highlight one title rectangle (colour or invert). */
rsrc_MBDF_0_594:
    jbsr rsrc_MBDF_0_96E	| 40878A64
    movew %a3@,%d0	| 40878A68
    addqw #6,%d0	| 40878A6A
    movel SavedHandle,%a3@(2,%d0:w)	| 40878A6C
    clrl SavedHandle	| 40878A72
    movew #1,%fp@(-26)	| 40878A76
    jbsr rsrc_MBDF_0_2AC
    rts
rsrc_MBDF_0_5B2:        /* test %fp@(-58) */
    tstb %fp@(-58)	| 40878A82
    jbeq rsrc_MBDF_0_5F0	| 40878A86
    jbsr rsrc_MBDF_0_2AC_86	| 40878A88
    jbsr rsrc_MBDF_0_40E_2E	| 40878A8C
    cmpiw #2,%fp@(-30)	| 40878A90
    jblt rsrc_MBDF_0_5F0	| 40878A96
    subqw #4,%sp	| 40878A98
    clrl %sp@-	| 40878A9A
    _GetMCEntry	| 40878A9C
    movel %sp@+,%d0	| 40878A9E
    jbeq rsrc_MBDF_0_5DE	| 40878AA0
    moveal %d0,%a0	| 40878AA2
    pea %a0@(4)	| 40878AA4
    pea %a0@(22)	| 40878AA8
    jbra rsrc_MBDF_0_5E6	| 40878AAC
rsrc_MBDF_0_5DE:        /* from here: pea 0xc10 */
    pea RGBBlack	| 40878AAE
    pea RGBWhite	| 40878AB2
rsrc_MBDF_0_5E6:        /* (40878AB6 A-line trap) */
    _RGBBackColor	| 40878AB6
    .short  0xAA22	| _HiliteColor
    bclr #7,HiliteMode	| 40878ABA
rsrc_MBDF_0_5F0:        /* subtract 4 to %sp */
    subqw #4,%sp	| 40878AC0
    _NewRgn	| 40878AC2
    _OpenRgn
    pea %a2@(16)	| 40878AC6
    btst #7,%fp@(-57)	| 40878ACA
    jbeq rsrc_MBDF_0_606	| 40878AD0
    _FrameRect	| 40878AD2
    jbra rsrc_MBDF_0_60E	| 40878AD4
rsrc_MBDF_0_606:        /* set %sp@- */
    movel #1048592,%sp@-	| 40878AD6
    _FrameRoundRect	| 40878ADC
rsrc_MBDF_0_60E:        /* set %sp@- */
    movel %sp@,%sp@-	| 40878ADE
    _CloseRgn	| 40878AE0
    movel %sp@,%sp@-	| 40878AE2
    movel %a2@(28),%sp@-	| 40878AE4
    movel %a2@(28),%sp@-	| 40878AE8
    _SectRgn	| 40878AEC
    _DisposRgn
    pea %a2@(16)	| 40878AF0
    _InverRect	| 40878AF4
    jbsr rsrc_MBDF_0_3EC	| 40878AF6
    jbra rsrc_MBDF_0_568	| 40878AFA

/* subroutine (32 instructions) (mechanical summary) */
rsrc_MBDF_0_62E:
    tstw %d0	| 40878AFE
    jbeq rsrc_MBDF_0_670	| 40878B00
    lea Scratch8,%a0	| 40878B02
    movew %a2@(16),%a0@	| 40878B06
    addqw #1,%a0@+	| 40878B0A
    movew %a3@(4,%d0:w),%a0@	| 40878B0C
    movew %a2@(18),%d1	| 40878B10
    addw %d1,%a0@	| 40878B14
    subqw #1,%a0@+	| 40878B16
    movew %a2@(16),%a0@	| 40878B18
    movew MBarHeight,%d1	| 40878B1C
    addw %d1,%a0@	| 40878B20
    subqw #1,%a0@+	| 40878B22
    movew %a2@(18),%a0@	| 40878B24
    cmpw %a3@,%d0	| 40878B28
    jbeq rsrc_MBDF_0_666	| 40878B2A
    addqw #6,%d0	| 40878B2C
    movew %a3@(4,%d0:w),%d1	| 40878B2E
    addw %d1,%a0@	| 40878B32
    jbra rsrc_MBDF_0_66C	| 40878B34
rsrc_MBDF_0_666:        /* set %d1 */
    movew %a3@(2),%d1	| 40878B36
    addw %d1,%a0@	| 40878B3A
rsrc_MBDF_0_66C:        /* add 4 to %a0@ */
    addqw #4,%a0@	| 40878B3C
rsrc_MBDF_0_66E:        /* return */
    rts	| 40878B3E
rsrc_MBDF_0_670:        /* address 0x9fa */
    lea Scratch8,%a0	| 40878B40
    movew %a2@(16),%a0@+	| 40878B44
    movew %a2@(18),%a0@+	| 40878B48
    movew %a2@(16),%a0@	| 40878B4C
    movew MBarHeight,%d1	| 40878B50
    addw %d1,%a0@+	| 40878B54
    movew %a2@(22),%a0@	| 40878B56
    jbra rsrc_MBDF_0_66E	| 40878B5A

/*
 Message 7, save: save the screen behind a menu (into an off-screen pixel map) and draw
 the menu's frame and shadow.
*/
rsrc_MBDF_0_68C:
    jbsr rsrc_MBDF_0_B6	| 40878B5C
    moveal %fp@(8),%a0	| 40878B60
    lea %fp@(-8),%a1	| 40878B64
    movel %a0@,%a1@	| 40878B68
    movel %a0@(4),%a1@(4)	| 40878B6A
    lea Scratch8,%a0	| 40878B70
    lea %fp@(-8),%a1	| 40878B74
    movel %a0,%sp@-	| 40878B78
    movew %a1@,%a0@	| 40878B7A
    addqw #3,%a0@	| 40878B7C
    movew %a1@(2),%a0@(2)	| 40878B7E
    movel %a1@(4),%a0@(4)	| 40878B84
    movel #-196612,%sp@-	| 40878B8A
    _InsetRect	| 40878B90
    jbsr rsrc_MBDF_0_96E	| 40878B92
    subqw #2,%sp	| 40878B96
    pea %fp@(-8)	| 40878B98
    .short  0xA8AE	| 40878B9C _EmptyRect
    tstb %sp@+	| 40878B9E
    jbne rsrc_MBDF_0_75E	| 40878BA0
    tstb %fp@(-58)	| 40878BA4
    jbeq rsrc_MBDF_0_6F2	| 40878BA8
    movew %fp@(12),%d0	| 40878BAA
    moveal %a3@(0,%d0:w),%a1	| 40878BAE
    moveal %a1@,%a4	| 40878BB2
    movew #1,%fp@(-28)	| 40878BB4
    clrw %fp@(-26)	| 40878BBA
    jbsr rsrc_MBDF_0_2AC_94	| 40878BBE
rsrc_MBDF_0_6F2:        /* address %fp@(-8) */
    lea %fp@(-8),%a4	| 40878BC2
    movel %a4,%sp@-	| 40878BC6
    _EraseRect	| 40878BC8
    tstb %fp@(-58)	| 40878BCA
    jbeq rsrc_MBDF_0_704	| 40878BCE
    jbsr rsrc_MBDF_0_3EC	| 40878BD0
rsrc_MBDF_0_704:        /* (40878BD4 A-line trap) */
    _PenNormal	| 40878BD4
    movew %a4@(2),%sp@-	| 40878BD6
    subqw #1,%sp@	| 40878BDA
    movew %sp@,%sp@-	| 40878BDC
    movew %sp@,%sp@-	| 40878BDE
    movew %a4@,%sp@-	| 40878BE0
    _MoveTo	| 40878BE2
    movew %a4@(4),%sp@-	| 40878BE4
    .short  0xA891	| 40878BE8 _LineTo
    movew %a4@(6),%sp@-	| 40878BEA
    movew %a4@(4),%sp@-	| 40878BEE
    .short  0xA891	| 40878BF2 _LineTo
    movew %a4@(6),%sp@-	| 40878BF4
    movew %a4@,%sp@-	| 40878BF8
    subqw #1,%sp@	| 40878BFA
    .short  0xA891	| 40878BFC _LineTo
    movew %a4@,%sp@-	| 40878BFE
    subqw #1,%sp@	| 40878C00
    .short  0xA891	| 40878C02 _LineTo
    movel #131074,%sp@-	| 40878C04
    _PenSize	| 40878C0A
    movew %a4@(6),%d0	| 40878C0C
    movew %d0,%sp@-	| 40878C10
    movew %a4@,%sp@-	| 40878C12
    addqw #2,%sp@	| 40878C14
    movew %d0,%sp@-	| 40878C16
    movew %a4@(4),%d0	| 40878C18
    movew %d0,%sp@-	| 40878C1C
    movew %a4@(2),%sp@-	| 40878C1E
    addqw #2,%sp@	| 40878C22
    movew %d0,%sp@-	| 40878C24
    _MoveTo	| 40878C26
    .short  0xA891	| _LineTo
    .short  0xA891	| _LineTo
    _PenNormal
rsrc_MBDF_0_75E:        /* clear %fp@(-36) */
    clrw %fp@(-36)	| 40878C2E
    moveal 0xb5c,%a0	| 40878C32
    moveal %a0@,%a0	| 40878C36
    movew %a0@,%d0	| 40878C38
    jbeq rsrc_MBDF_0_77C	| 40878C3A
    movew %a0@(2,%d0:w),%d1	| 40878C3C
    cmpw %fp@(-6),%d1	| 40878C40
    jblt rsrc_MBDF_0_77C	| 40878C44
    movew #1,%fp@(-36)	| 40878C46
rsrc_MBDF_0_77C:        /* from here: addiw #28,%a0@ */
    addiw #28,%a0@	| 40878C4C
    movew %a0@,%d0	| 40878C50
    movel %fp@(-8),%a0@(0,%d0:w)	| 40878C52
    movel %fp@(-4),%a0@(4,%d0:w)	| 40878C58
    movel SavedHandle,%a0@(8,%d0:w)	| 40878C5E
    movew %fp@(-36),%a0@(0xc,%d0:w)	| 40878C64
    movew %fp@(12),%d1	| 40878C6A
    movew %d1,%a0@(0xe,%d0:w)	| 40878C6E
    movel %a3@(0x0,%d1:w),%a0@(0x10,%d0:w)
    rts	| 40878C78

/* subroutine (15 instructions): traps CalcMenuSize; calls rsrc_MBDF_0_7D6 (mechanical summary) */
rsrc_MBDF_0_7AA:
    movel %fp@(8),%d0
    movew %fp@(8),%fp@(-38)
    moveal %a3@(0x0,%d0:w),%a1
    movew %a3@(0x4,%d0:w),%d3
    addw %a2@(18),%d3
    moveal %a1@,%a0
    tstl %a0@(2)
    jbpl rsrc_MBDF_0_7AA_28
    movel %a1,%sp@-
    movel %a1,%sp@-
    _CalcMenuSize
    moveal %sp@+,%a0
    moveal %a0@,%a0
rsrc_MBDF_0_7AA_28:     /* call rsrc_MBDF_0_7D6 */
    jbsr rsrc_MBDF_0_7D6
    rts

/* subroutine (101 instructions): calls rsrc_MBDF_0_940, rsrc_MBDF_0_AD0, rsrc_MBDF_0_910, rsrc_MBDF_0_95A; low memory MBarHeight (mechanical summary) */
rsrc_MBDF_0_7D6:
    movew %fp@(-38),%d1
    jbne rsrc_MBDF_0_81C
    clrw %fp@(-36)
    movew %a2@(16),%d1
    addw MBarHeight,%d1
    movew %d3,%d0
    addw %a0@(2),%d0
    addqw #8,%d0
    cmpw %a2@(22),%d0
    jble rsrc_MBDF_0_7D6_30
    movew #1,%fp@(-36)
    movew %a2@(22),%d3
    subqw #8,%d3
    subw %a0@(2),%d3
rsrc_MBDF_0_7D6_30:     /* loop: lea */
    lea %fp@(-8),%a1
    movew %d1,%a1@+
    movew %d3,%a1@+
    addw %a0@(4),%d1
    movew %d1,%a1@+
    addw %a0@(2),%d3
    movew %d3,%a1@
    rts

rsrc_MBDF_0_81C:        /* save registers */
    moveml %d2-%d5/%a0-%a3,%sp@-
    movel %d1,%d5
    jbsr rsrc_MBDF_0_940
    jbsr rsrc_MBDF_0_AD0
    movew %a1@(20),%d2
    moveal %a1@(16),%a3
    moveal %a3@,%a3
    moveq #1,%d4
rsrc_MBDF_0_81C_1A:     /* loop: move */
    movew %d4,%d0
    moveal %a3,%a0
    jbsr rsrc_MBDF_0_910
    jbsr rsrc_MBDF_0_95A
    addw %d0,%d2
    cmpw %d5,%d2
    jbgt rsrc_MBDF_0_81C_30
    addqw #1,%d4
    jbra rsrc_MBDF_0_81C_1A
rsrc_MBDF_0_81C_30:     /* from here: subw %d0,%d2 */
    subw %d0,%d2
    movew %d2,%d1
    moveml %sp@+,%d2-%d5/%a0-%a3
    subqw #7,%d1
    cmpw MBarHeight,%d1
    jbge rsrc_MBDF_0_81C_44
    movew MBarHeight,%d1
rsrc_MBDF_0_81C_44:     /* add 7 to %d1 */
    addqw #7,%d1
    movew %d1,%d0
    addw %a0@(4),%d0
    addiw #12,%d0
    cmpw %a2@(20),%d0
    jbls rsrc_MBDF_0_81C_64
    movew %a2@(20),%d0
    subiw #12,%d0
    subw %a0@(4),%d0
    movew %d0,%d1
rsrc_MBDF_0_81C_64:     /* call rsrc_MBDF_0_AD0 */
    jbsr rsrc_MBDF_0_AD0
    movew %a1@(12),%fp@(-36)
    cmpiw #1,%fp@(-36)
    jbeq rsrc_MBDF_0_81C_B2
    movew %a1@(6),%d0
    subqw #4,%d0
    movew %d0,%d3
    addw %a0@(2),%d0
    addqw #8,%d0
    cmpw %a2@(22),%d0
    jble rsrc_MBDF_0_81C_F0
    movew #1,%fp@(-36)
    movew %a1@(2),%d0
    subw %a0@(2),%d0
    addqw #8,%d0
    movew %d0,%d3
    subqw #8,%d0
    cmpw %a2@(18),%d0
    jbge rsrc_MBDF_0_81C_F0
    movew %a2@(18),%d0
    addqw #8,%d0
    movew %d0,%d3
    clrw %fp@(-36)
    jbra rsrc_MBDF_0_81C_F0
rsrc_MBDF_0_81C_B2:     /* set %d0 */
    movew %a1@(2),%d0
    addqw #8,%d0
    subw %a0@(2),%d0
    movew %d0,%d3
    subqw #8,%d0
    cmpw %a2@(18),%d0
    jbgt rsrc_MBDF_0_81C_F0
    clrw %fp@(-36)
    movew %a1@(6),%d0
    subqw #4,%d0
    movew %d0,%d3
    addw %a0@(2),%d0
    addqw #8,%d0
    cmpw %a2@(22),%d0
    jble rsrc_MBDF_0_81C_F0
    movew %a2@(22),%d0
    subw %a0@(2),%d0
    subqw #8,%d0
    movew %d0,%d3
    movew #1,%fp@(-36)
rsrc_MBDF_0_81C_F0:     /* continue at rsrc_MBDF_0_7D6_30 */
    jbra rsrc_MBDF_0_7D6_30

/* subroutine (23 instructions) (mechanical summary) */
rsrc_MBDF_0_910:
    tstw %d0
    jble rsrc_MBDF_0_910_1C
    moveq #0,%d1
    lea %a0@(14),%a1
    moveb %a1@+,%d1
    addaw %d1,%a1
rsrc_MBDF_0_910_E:      /* loop: subq */
    subqw #1,%d0
    jbeq rsrc_MBDF_0_910_24
    moveb %a1@+,%d1
    jbeq rsrc_MBDF_0_910_1C
    addqw #4,%d1
    addaw %d1,%a1
    jbra rsrc_MBDF_0_910_E
rsrc_MBDF_0_910_1C:     /* loop: suba */
    subal %a0,%a0
    moveal %a0,%a1
    movel %a0,%d0
    rts
rsrc_MBDF_0_910_24:     /* test %a1@ */
    tstb %a1@
    jbeq rsrc_MBDF_0_910_1C
    moveal %a1,%a0
    moveb %a1@+,%d1
    addaw %d1,%a1
    rts

/* subroutine (11 instructions): traps GetFontInfo (mechanical summary) */
rsrc_MBDF_0_940:
    lea %fp@(-66),%a2
    movel %a2,%sp@-
    _GetFontInfo
    movew %a2@+,%d0
    addw %a2@+,%d0
    cmpiw #14,%a2@
    jbne rsrc_MBDF_0_940_14
    subqw #2,%a2@
rsrc_MBDF_0_940_14:     /* add 2 to %a2 */
    addqw #2,%a2
    addw %d0,%a2@
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_MBDF_0_95A:
    movew %fp@(-60),%d0
    cmpib #28,%a1@(1)
    jbeq rsrc_MBDF_0_95A_12
    tstb %a1@
    jbeq rsrc_MBDF_0_95A_12
    moveq #36,%d0
rsrc_MBDF_0_95A_12:     /* return */
    rts

/* subroutine (114 instructions): traps NewPixMap, HLock, DisposHandle, NewHandle, GetTrapAddress, OSDispatch, HUnlock; calls rsrc_MBDF_0_440, rsrc_MBDF_0_96E_146; low memory Scratch8, SavedHandle (mechanical summary) */
rsrc_MBDF_0_96E:
    moveml %d3-%d4/%a3-%a4,%sp@-
    tstb %fp@(-58)
    jbeq rsrc_MBDF_0_96E_4A
    lea Scratch8,%a0
    jbsr rsrc_MBDF_0_440
    moveal %a1,%a4
    movel TheGDevice,%sp@-
    movel %a0,TheGDevice
    subql #4,%sp
    _NewPixMap
    movel %sp@+,%d0
    movel %sp@+,TheGDevice
    tstl %d0
    jbeq rsrc_MBDF_0_96E_DE
    moveal %a4,%a1
    moveal %d0,%a0
    _HLock
    movel %a0,SavedHandle
    moveal %a0@,%a4
    moveal %a4@(42),%a0
    _DisposHandle
    movel %a1@(42),%a4@(42)
    movew %fp@(-30),%d3
    jbra rsrc_MBDF_0_96E_5C
rsrc_MBDF_0_96E_4A:     /* set up and call _HLock */
    moveq #14,%d0
    .short  0xA322	| 40878E8A _NewHandle (flags 0x0300)
    jbne rsrc_MBDF_0_96E_DE
    _HLock
    movel %a0,SavedHandle
    moveal %a0@,%a4
    moveq #1,%d3
rsrc_MBDF_0_96E_5C:     /* set %d1 */
    movew scratch8_6,%d1
    subw scratch8_2,%d1
    muluw %d1,%d3
    addiw #15,%d3
    lsrw #4,%d3
    addw %d3,%d3
    movew %a4@(4),%d1
    andiw #-16384,%d1
    orw %d3,%d1
    movew %d1,%a4@(4)
    movew scratch8_4,%d4
    subw Scratch8,%d4
    muluw %d4,%d3
    addql #4,%d3
    movew #143,%d0
    .short  0xA746	| 40878ECA _GetTrapAddress (flags 0x0700)
    moveal %a0,%a1
    movew #159,%d0
    .short  0xA746	| 40878ED2 _GetTrapAddress (flags 0x0700)
    cmpal %a0,%a1
    jbeq rsrc_MBDF_0_96E_E4
    subql #8,%sp
    pea %sp@(4)
    movew #21,%sp@-
    _OSDispatch
    movel %sp@+,%d0
    addql #4,%sp
    cmpl %d3,%d0
    jbcs rsrc_MBDF_0_96E_E4
    subql #6,%sp
    movel %d3,%sp@-
    pea %sp@(8)
    movew #29,%sp@-
    _OSDispatch
    moveal %sp@+,%a3
    tstw %sp@+
    jbne rsrc_MBDF_0_96E_E4
    subql #2,%sp
    movel %a3,%sp@-
    pea %sp@(4)
    movew #30,%sp@-
    _OSDispatch
    addql #2,%sp
    moveal %a3@,%a0
    st %a0@
    jbra rsrc_MBDF_0_96E_F2
rsrc_MBDF_0_96E_D8:     /* set up and call _DisposHandle (loop) */
    moveal SavedHandle,%a0
    _DisposHandle
rsrc_MBDF_0_96E_DE:     /* clear SavedHandle */
    clrl SavedHandle
    jbra rsrc_MBDF_0_96E_140
rsrc_MBDF_0_96E_E4:     /* set up and call _HLock */
    movel %d3,%d0
    .short  0xA122	| 40878F24 _NewHandle (flags 0x0100)
    jbne rsrc_MBDF_0_96E_D8
    _HLock
    moveal %a0,%a3
    moveal %a3@,%a0
    sf %a0@
rsrc_MBDF_0_96E_F2:     /* set %a4@(6) */
    movel Scratch8,%a4@(6)
    movel scratch8_4,%a4@(10)
    addql #4,%a0
    movel %a0,%a4@
    moveal %a4,%a0
    movel %a2@(80),%sp@-
    moveq #-1,%d0
    movel %d0,%a2@(80)
    pea %a2@(2)
    movel %a0,%sp@-
    jbsr rsrc_MBDF_0_96E_146
    movel %sp@+,%a2@(80)
    moveal SavedHandle,%a0
    _HUnlock
    moveal %a0@,%a4
    movel %a3,%a4@
    moveal %a3@,%a0
    tstb %a0@
    jbeq rsrc_MBDF_0_96E_13C
    subql #2,%sp
    movel %a3,%sp@-
    pea %sp@(4)
    movew #31,%sp@-
    _OSDispatch
    addql #2,%sp
    jbra rsrc_MBDF_0_96E_140
rsrc_MBDF_0_96E_13C:    /* set up and call _HUnlock */
    moveal %a3,%a0
    _HUnlock
rsrc_MBDF_0_96E_140:    /* restore registers, return */
    moveml %sp@+,%d3-%d4/%a3-%a4
    rts

/* subroutine (8 instructions): traps CopyBits (mechanical summary) */
rsrc_MBDF_0_96E_146:
    movel %sp@+,%d4
    pea %a0@(6)
    movel %sp@,%sp@-
    clrw %sp@-
    clrl %sp@-
    _CopyBits
    movel %d4,%sp@-
    rts

/* subroutine (4 instructions) (mechanical summary) */
rsrc_MBDF_0_AC6:
    moveal 0xb5c,%a0	| 40878F96
    moveal %a0@,%a0	| 40878F9A
    addaw %a0@,%a0	| 40878F9C
    rts	| 40878F9E

/* subroutine (4 instructions) (mechanical summary) */
rsrc_MBDF_0_AD0:
    moveal 0xb5c,%a1
    moveal %a1@,%a1
    addaw %a1@,%a1
    rts

/* Message 8, restore: put back the screen saved behind the topmost menu. */
rsrc_MBDF_0_ADA:
    jbsr rsrc_MBDF_0_B6	| 40878FAA
    jbsr rsrc_MBDF_0_AC6	| 40878FAE
    moveal %a0@(8),%a0	| 40878FB0
    movel %a0,%d0	| 40878FB4
    jbeq rsrc_MBDF_0_B58	| 40878FB6
    movel %a0,%sp@-	| 40878FB8
    jbsr rsrc_MBDF_0_AFA	| 40878FBA
    addqw #4,%sp	| 40878FBC
    moveal 0xb5c,%a0	| 40878FBE
    moveal %a0@,%a0	| 40878FC2
    subiw #28,%a0@	| 40878FC4
    rts	| 40878FC8

/* subroutine (64 instructions): traps HLock, OSDispatch, DisposHandle, NewRgn, RectRgn, FrontWindow, PaintBehind, DisposRgn; calls rsrc_MBDF_0_96E_146 (mechanical summary) */
rsrc_MBDF_0_AFA:
    moveml %a3-%a4,%sp@-
    moveal %a0,%a4
    _HLock
    moveal %a4@,%a0
    moveal %a0@,%a3
    moveal %a3@,%a1
    tstb %a1@
    jbeq rsrc_MBDF_0_AFA_24
    subql #2,%sp
    movel %a3,%sp@-
    pea %sp@(4)
    movew #30,%sp@-
    _OSDispatch
    addql #2,%sp
    jbra rsrc_MBDF_0_AFA_28
rsrc_MBDF_0_AFA_24:     /* set up and call _HLock */
    moveal %a3,%a0
    _HLock
rsrc_MBDF_0_AFA_28:     /* set %a0 */
    moveal %a4@,%a0
    moveal %a3@,%a1
    addql #4,%a1
    movel %a1,%a0@
    movel %a0,%sp@-
    pea %a2@(2)
    jbsr rsrc_MBDF_0_96E_146
    moveal %a4,%a0
    _DisposHandle
    moveal %a3@,%a0
    tstb %a0@
    jbeq rsrc_MBDF_0_AFA_54
    subql #2,%sp
    movel %a3,%sp@-
    pea %sp@(4)
    movew #32,%sp@-
    _OSDispatch
    addql #2,%sp
    jbra rsrc_MBDF_0_AFA_58
rsrc_MBDF_0_AFA_54:     /* set up and call _DisposHandle */
    moveal %a3,%a0
    _DisposHandle
rsrc_MBDF_0_AFA_58:     /* restore registers, return */
    moveml %sp@+,%a3-%a4
    rts
rsrc_MBDF_0_B58:        /* address %fp@(-8) */
    lea %fp@(-8),%a1	| 40879028
    moveal 0xb5c,%a0	| 4087902C
    moveal %a0@,%a0	| 40879030
    movew %a0@,%d0	| 40879032
    movel %a0@(0,%d0:w),%a1@+	| 40879034
    movel %a0@(4,%d0:w),%a1@+	| 40879038
    addqw #2,%a1@-	| 4087903C
    addqw #2,%a1@-	| 4087903E
    subqw #1,%a1@-	| 40879040
    subqw #1,%a1@-	| 40879042
    subqw #4,%sp	| 40879044
    _NewRgn	| 40879046
    movel %sp@,%sp@-	| 40879048
    pea %fp@(-8)	| 4087904A
    _RectRgn	| 4087904E
    subqw #4,%sp	| 40879050
    _FrontWindow	| 40879052
    movel %sp@(4),%sp@-	| 40879054
    _PaintBehind	| 40879058
    _DisposRgn
    moveal 0xb5c,%a0	| 4087905C
    moveal %a0@,%a0	| 40879060
    subiw #28,%a0@	| 40879062
    rts	| 40879066

/*
 Message 9, rectangle: the rectangle of a menu (below its title, or of a hierarchical menu
 beside its parent item), kept on the screen.
*/
rsrc_MBDF_0_B98:
    movel %fp@(8),%d0	| 40879068
    moveal 0xb5c,%a0
    moveal %a0@,%a0
    movew %a0@,%d1
    jbeq rsrc_MBDF_0_AFA_C4
rsrc_MBDF_0_AFA_AC:     /* loop: cmp */
    cmpw %a0@(0xe,%d1:w),%d0
    jbeq rsrc_MBDF_0_AFA_BA
    subiw #28,%d1
    jbeq rsrc_MBDF_0_AFA_C4
    jbra rsrc_MBDF_0_AFA_AC
rsrc_MBDF_0_AFA_BA:     /* address %a0@(0x0 */
    lea %a0@(0x0,%d1:w),%a1
    movel %a1,%fp@(18)
rsrc_MBDF_0_AFA_C2:     /* return */
    rts
rsrc_MBDF_0_AFA_C4:     /* call rsrc_MBDF_0_7AA */
    jbsr rsrc_MBDF_0_7AA
    lea Scratch8,%a0
    lea %fp@(-8),%a1
    movel %a1@,%a0@
    movel %a1@(4),%a0@(4)
    movel %a0,%fp@(18)
    jbra rsrc_MBDF_0_AFA_C2

/* Message 10, save alternate. */
rsrc_MBDF_0_BD8:
    movel %fp@(8),%d0	| 408790A8
    moveal 0xb5c,%a0	| 408790AC
    moveal %a0@,%a0	| 408790B0
    movew %a0@,%d1	| 408790B2
    jbeq rsrc_MBDF_0_C00	| 408790B4
rsrc_MBDF_0_BE6:        /* (408790B6 cmpw %a0@(e,%d1:w),%d0) */
    cmpw %a0@(0xe,%d1:w),%d0	| 408790B6
    jbeq rsrc_MBDF_0_BF4	| 408790BA
    subiw #28,%d1	| 408790BC
    jbeq rsrc_MBDF_0_C00	| 408790C0
    jbra rsrc_MBDF_0_BE6	| 408790C2
rsrc_MBDF_0_BF4:        /* (408790C4 movew 0xa0a,%a0@(14,%d1:w)) */
    movew TopMenuItem,%a0@(0x14,%d1:w)	| 408790C4
    movew AtMenuBottom,%a0@(0x16,%d1:w)
rsrc_MBDF_0_C00:        /* return */
    rts	| 408790D0

/* Message 11, reset alternate. */
rsrc_MBDF_0_C02:
    movel %fp@(8),%d0	| 408790D2
    moveal 0xb5c,%a0	| 408790D6
    moveal %a0@,%a0	| 408790DA
    movew %a0@,%d1	| 408790DC
    jbeq rsrc_MBDF_0_C2A	| 408790DE
rsrc_MBDF_0_C10:        /* (408790E0 cmpw %a0@(e,%d1:w),%d0) */
    cmpw %a0@(0xe,%d1:w),%d0	| 408790E0
    jbeq rsrc_MBDF_0_C1E	| 408790E4
    subiw #28,%d1	| 408790E6
    jbeq rsrc_MBDF_0_C2A	| 408790EA
    jbra rsrc_MBDF_0_C10	| 408790EC
rsrc_MBDF_0_C1E:        /* (408790EE movew %a0@(14,%d1:w),0xa0a) */
    movew %a0@(0x14,%d1:w),TopMenuItem	| 408790EE
    movew %a0@(0x16,%d1:w),AtMenuBottom
rsrc_MBDF_0_C2A:        /* return */
    rts	| 408790FA

/* Message 12, menu bar region (the bar with its rounded corners). */
rsrc_MBDF_0_C2C:
    movel %fp@(8),%sp@-	| 408790FC
    movew %a2@(18),%sp@-	| 40879100
    movew %a2@(16),%sp@-	| 40879104
    movew %a2@(22),%sp@-	| 40879108
    movew %a2@(16),%sp@-	| 4087910C
    movew MBarHeight,%d0	| 40879110
    addw %d0,%sp@	| 40879114
    _SetRecRgn	| 40879116
    movel %fp@(8),%fp@(18)	| 40879118
    rts	| 4087911E

/* Message 13 (a later addition). */
rsrc_MBDF_0_C50:
    clrl %fp@(18)	| 40879120
    moveq #6,%d3	| 40879124
    cmpw %a3@,%d3	| 40879126
    jbgt rsrc_MBDF_0_D72	| 40879128
    movew %a3@,%d0	| 4087912C
    addqw #6,%d0	| 4087912E
    tstl %a3@(2,%d0:w)	| 40879130
    jbne rsrc_MBDF_0_D72	| 40879134
    moveal %a3@(0,%d3:w),%a0	| 40879138
    moveal %a0@,%a4	| 4087913C
    cmpiw #276,%a4@(14)	| 4087913E
    jbne rsrc_MBDF_0_D72	| 40879144
    _HLock	| 40879148
    jbsr rsrc_MBDF_0_116	| 4087914A
    clrw %fp@(-26)	| 4087914E
    clrw %fp@(-28)	| 40879152
    jbsr rsrc_MBDF_0_2AC_94	| 40879156
    movel %d3,%d0	| 4087915A
    jbsr rsrc_MBDF_0_62E	| 4087915C
    moveq #16,%d1	| 40879160
    movew scratch8_6,%d0	| 40879162
    subw scratch8_2,%d0	| 40879166
    subw %d1,%d0	| 4087916A
    cmpw %d1,%d0	| 4087916C
    jbge rsrc_MBDF_0_CA2	| 4087916E
    movew %d0,%d1	| 40879170
rsrc_MBDF_0_CA2:        /* from here: pea 0x9fa */
    pea Scratch8	| 40879172
    asrw #1,%d1	| 40879176
    movel %d1,%sp@-	| 40879178
    _InsetRect	| 4087917A
    movew %fp@(12),%d4	| 4087917C
    jbeq rsrc_MBDF_0_CCE	| 40879180
    subql #4,%sp	| 40879182
    _NewRgn	| 40879184
    movel %sp@+,%d5	| 40879186
    pea Scratch8	| 40879188
    movew %d4,%sp@-	| 4087918C
    clrw %sp@-	| 4087918E
    movel %d5,%sp@-	| 40879190
    _ScrollRect	| 40879192
    movel %d5,%sp@-	| 40879194
    _SetClip	| 40879196
    movel %d5,%sp@-	| 40879198
    _DisposRgn	| 4087919A
    jbra rsrc_MBDF_0_CD4	| 4087919C
rsrc_MBDF_0_CCE:        /* from here: pea 0x9fa */
    pea Scratch8	| 4087919E
    _EraseRect	| 408791A2
rsrc_MBDF_0_CD4:        /* set %a0 */
    moveal 0xb5c,%a0	| 408791A4
    moveal %a0@,%a0	| 408791A8
    movew %a0@(18),%d5	| 408791AA
    jbgt rsrc_MBDF_0_CE8	| 408791AE
    movew scratch8_6,%d5	| 408791B0
    subw scratch8_2,%d5	| 408791B4
rsrc_MBDF_0_CE8:        /* set %d1 */
    movew scratch8_2,%d1	| 408791B8
    tstl %fp@(8)	| 408791BC
    jbne rsrc_MBDF_0_CFC	| 408791C0
    movew %a3@(4,%d3:w),%d1	| 408791C2
    addw %a2@(18),%d1	| 408791C6
    addqw #8,%d1	| 408791CA
rsrc_MBDF_0_CFC:        /* set %d0 */
    movew %d4,%d0	| 408791CC
    jblt rsrc_MBDF_0_D06	| 408791CE
    jbgt rsrc_MBDF_0_D0C	| 408791D0
    moveq #0,%d5	| 408791D2
    jbra rsrc_MBDF_0_D10	| 408791D4
rsrc_MBDF_0_D06:        /* from here: addw %d0,%d5 */
    addw %d0,%d5	| 408791D6
    addw %d5,%d1	| 408791D8
    jbra rsrc_MBDF_0_D10	| 408791DA
rsrc_MBDF_0_D0C:        /* from here: subw %d0,%d5 */
    subw %d0,%d5	| 408791DC
    subw %d5,%d1	| 408791DE
rsrc_MBDF_0_D10:        /* set %a0 */
    moveal %a2@(28),%a0	| 408791E0
    moveal %a0@,%a0	| 408791E4
    movew %d1,%sp@-	| 408791E6
    jbsr rsrc_MBDF_0_108	| 408791E8
    movew %d4,%sp@-	| 408791EC
    _MoveTo	| 408791EE
    movel %fp@(8),%d0	| 408791F0
    jbeq rsrc_MBDF_0_D4C	| 408791F4
    movel #-786432,%fp@(-20)	| 408791F6
    movel #262160,%fp@(-16)	| 408791FE
    pea %fp@(-20)	| 40879206
    movel %d0,%sp@-	| 4087920A
    pea %fp@(-20)	| 4087920C
    subql #4,%sp@-	| 40879210
    movel %sp,%sp@-	| 40879212
    _GetPen	| 40879214
    _OffsetRect
    jbsr rsrc_MBDF_0_D74	| 40879218
    jbra rsrc_MBDF_0_D50	| 4087921A
rsrc_MBDF_0_D4C:        /* call rsrc_MBDF_0_2CC */
    jbsr rsrc_MBDF_0_2CC	| 4087921C
rsrc_MBDF_0_D50:        /* clear %d0 */
    moveq #0,%d0	| 40879220
    moveal 0xb5c,%a0	| 40879222
    moveal %a0@,%a0	| 40879226
    movew %d5,%a0@(18)	| 40879228
    jbgt rsrc_MBDF_0_D60	| 4087922C
    moveq #-1,%d0	| 4087922E
rsrc_MBDF_0_D60:        /* set %fp@(18) */
    movel %d0,%fp@(18)	| 40879230
    jbsr rsrc_MBDF_0_3EC	| 40879234
    jbsr rsrc_MBDF_0_B6	| 40879238
    moveal %a3@(0,%d3:w),%a0	| 4087923C
    _HUnlock	| 40879240
rsrc_MBDF_0_D72:        /* return */
    rts	| 40879242

/* subroutine (21 instructions): traps CopyBits (mechanical summary) */
rsrc_MBDF_0_D74:
    lea IconBitmap,%a1	| 40879244
    movel %sp@(4),%d0	| 40879248
    jbeq rsrc_MBDF_0_DAC	| 4087924C
    moveal %d0,%a0	| 4087924E
    movel %a0@,%a1@+	| 40879250
    movew #2,%a1@+	| 40879252
    clrl %a1@+	| 40879256
    movel #1048592,%a1@	| 40879258
    movel %sp@(8),%d1	| 4087925E
    lea IconBitmap,%a1	| 40879262
    movel %a1,%sp@-	| 40879266
    moveal %a5@,%a0	| 40879268
    moveal %a0@,%a0	| 4087926A
    pea %a0@(2)	| 4087926C
    pea %a1@(6)	| 40879270
    movel %d1,%sp@-	| 40879274
    clrw %sp@-	| 40879276
    clrl %sp@-	| 40879278
    _CopyBits	| 4087927A
rsrc_MBDF_0_DAC:        /* set %a0 */
    moveal %sp@+,%a0	| 4087927C
    addql #8,%sp	| 4087927E
    jmp %a0@	| 40879280
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40879282
