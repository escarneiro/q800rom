/*
 toolbox/crsrdev.s - Cursor Device Manager
 From CRSRDEV (0x408B63D0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* CRSRDEV: Cursor Device Manager (mouse and trackball handling, acceleration). */
trap_CursorDeviceDispatch:
CRSRDEV:
CRSRDEVDISPATCH:
    linkw %fp,#0
    moveml %d1-%d3/%a1-%a3,%sp@-
    addw %d0,%d0
    lea %pc@(CRSRDEV_14),%a0
    addaw %a0@(0x0,%d0:w),%a0
    jmp %a0@
CRSRDEV_14:             /* from here: orib #66,%a0@(112) */
    orib #66,%a0@(112)
    oril #11665604,%a4@+
    .long   0x00D600F6	| 408B63F0
    movepw %a2@(288),%d0
    btst %d0,%a4@(0,%zd0)	| 408B63F8
    bchg %d0,0x18c
CRSRDEV_30:             /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a1-%a3
    unlk %fp
    moveal %sp@+,%a0
    addaw %d0,%sp
    jmp %a0@
    movel %fp@(8),%d1
    movel %fp@(12),%d0
    moveal %fp@(16),%a2
    jbsr CRSRDEVDISPATCH_29E
    movew %d0,%fp@(20)
    moveq #12,%d0
    jmp %pc@(CRSRDEV_30)
    moveal %fp@(16),%a2
    moveal %a2@(4),%a1
    moveq #0,%d0
    movel %fp@(8),%d0
    swap %d0
    movel %d0,%a1@(12)
    moveq #0,%d0
    movel %fp@(12),%d0
    swap %d0
    movel %d0,%a1@(8)
    st %a1@(20)
    clrw %fp@(20)
    moveq #12,%d0
    jmp %pc@(CRSRDEV_30)
    moveal %fp@(8),%a2
    movel %a2@(120),%d0
    addl %d0,%a2@(112)
    movel %a2@(124),%d0
    addl %d0,%a2@(116)
    clrl %a2@(120)
    clrl %a2@(124)
    movew #-108,%a2@(128)
    clrw %fp@(12)
    moveq #4,%d0
    jmp %pc@(CRSRDEV_30)
    .long   0x302E0008, 0x246E000A, 0x61000284, 0x3D40000E	| 408B6480
    moveq #6,%d0
    jmp %pc@(CRSRDEV_30)
    .short  0x246E, 0x0008, 0x6100, 0x0328, 0x3D40	| 408B6496
    .short  0x000C	| 408B64A0
    moveq #4,%d0
    jmp %pc@(CRSRDEV_30)
    .long   0x246E0008, 0x61000356	| 408B64A8
    .long   0x3D40000C	| 408B64B0
    moveq #4,%d0
    jmp %pc@(CRSRDEV_30)
    .short  0x302E, 0x000E, 0x246E	| 408B64BA
    .long   0x001015AE, 0x000D001C, 0xE54825AE, 0x00080044	| 408B64C0
    .long   0x426E0014	| 408B64D0
    moveq #12,%d0
    jmp %pc@(CRSRDEV_30)
    .short  0x246E, 0x000A, 0x156E	| 408B64DA
    .long   0x00090019, 0x426E000E	| 408B64E0
    moveq #6,%d0
    jmp %pc@(CRSRDEV_30)
    .short  0x202E	| 408B64EE
    .long   0x0008246E, 0x000C6100, 0x03483D40	| 408B64F0
    .short  0x0010, 0x7008	| orib #8,%a0@
    jmp %pc@(CRSRDEV_30)
    .long   0x246E000C, 0x256E0008, 0x0064426E	| 408B6504
    .short  0x0010	| 408B6510
    moveq #8,%d0
    jmp %pc@(CRSRDEV_30)
    .long   0x246E000C, 0x256E0008	| 408B6518
    .short  0x0014, 0x202A, 0x0068, 0x6100, 0x0318, 0x426E, 0x0010	| 408B6520
    moveq #8,%d0
    jmp %pc@(CRSRDEV_30)
    moveal %fp@(8),%a2
    moveal %a2@,%a2
    movel %a2,%d0
    jbeq CRSRDEV_172
    moveal %a2@,%a2
    jbra CRSRDEV_17C
CRSRDEV_172:            /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(480),%a2
    moveal %a2@,%a2
CRSRDEV_17C:            /* set %a0 */
    moveal %fp@(8),%a0
    movel %a2,%a0@
    clrw %fp@(12)
    moveq #4,%d0
    jmp %pc@(CRSRDEV_30)
    jbsr CRSRDEVHANDLEVBL_218
    moveal %fp@(8),%a0
    movel %a2,%a0@
    movew %d0,%fp@(12)
    moveq #4,%d0
    jmp %pc@(CRSRDEV_30)
    .long   0x246E0008, 0x610007E0, 0x3D40000C	| 408B6570
    moveq #4,%d0
    jmp %pc@(CRSRDEV_30)
CRSRDEV_1B2:            /* set %d2 */
    moveb %d0,%d2
    movel %a2,%d0
    jbeq CRSRDEV_29C
    lea %a0@(1),%a3
    moveq #127,%d0
    andb %a3@(1),%d0
    moveq #127,%d1
    andb %a3@,%d1
    cmpib #3,%a0@
    jbge CRSRDEV_1E6
    btst #6,%d0
    jbeq CRSRDEV_1D8
    oriw #-128,%d0
CRSRDEV_1D8:            /* test bit 6 of %d1 */
    btst #6,%d1
    jbeq CRSRDEV_260
    oriw #-128,%d1
    jbra CRSRDEV_260
CRSRDEV_1E6:            /* set %d2 */
    moveq #7,%d2
    andb %a3@(2),%d2
    lslw #7,%d2
    orw %d2,%d0
    moveq #112,%d2
    andb %a3@(2),%d2
    lslw #3,%d2
    orw %d2,%d1
    cmpib #4,%a0@
    jbge CRSRDEV_216
    btst #9,%d0
    jbeq CRSRDEV_20A
    oriw #-1024,%d0
CRSRDEV_20A:            /* test bit 9 of %d1 */
    btst #9,%d1
    jbeq CRSRDEV_260
    oriw #-1024,%d1
    jbra CRSRDEV_260
CRSRDEV_216:            /* set %d2 */
    moveq #7,%d2
    andb %a3@(3),%d2
    lslw #8,%d2
    lslw #2,%d2
    orw %d2,%d0
    moveq #112,%d2
    andb %a3@(3),%d2
    lslw #6,%d2
    orw %d2,%d1
    cmpib #5,%a0@
    jbge CRSRDEV_248
    btst #12,%d0
    jbeq CRSRDEV_23C
    oriw #-8192,%d0
CRSRDEV_23C:            /* test bit 12 of %d1 */
    btst #12,%d1
    jbeq CRSRDEV_260
    oriw #-8192,%d1
    jbra CRSRDEV_260
CRSRDEV_248:            /* set %d2 */
    moveq #7,%d2
    andb %a3@(4),%d2
    lslw #8,%d2
    lslw #5,%d2
    orw %d2,%d0
    moveq #112,%d2
    andb %a3@(4),%d2
    lslw #8,%d2
    lslw #1,%d2
    orw %d2,%d1
CRSRDEV_260:            /* from here: extl %d0 */
    extl %d0
    extl %d1
    jbsr CRSRDEVDISPATCH_29E
    moveq #0,%d0
    moveq #0,%d1
    btst #7,%a3@+
    jbne CRSRDEV_272
    bset %d1,%d0
CRSRDEV_272:            /* add 1 to %d1 */
    addqb #1,%d1
    btst #7,%a3@+
    jbne CRSRDEV_27C
    bset %d1,%d0
CRSRDEV_27C:            /* loop: addq */
    addqb #1,%d1
    cmpb %a2@(25),%d1
    jbge CRSRDEV_298
    btst #7,%a3@
    jbne CRSRDEV_28C
    bset %d1,%d0
CRSRDEV_28C:            /* add 1 to %d1 */
    addqb #1,%d1
    btst #3,%a3@+
    jbne CRSRDEV_27C
    bset %d1,%d0
    jbra CRSRDEV_27C
CRSRDEV_298:            /* call CRSRDEVDISPATCH_33E */
    jbsr CRSRDEVDISPATCH_33E
CRSRDEV_29C:            /* return */
    rts

CRSRDEVDISPATCH_29E:    /* entry: stack frame */
    linkw %fp,#-8
    tstl %d0
    jbne CRSRDEV_2AC
    tstl %d1
    jbeq CRSRDEV_338
CRSRDEV_2AC:            /* set %fp@(-8) */
    movel %d0,%fp@(-8)
    movel %d1,%fp@(-4)
    swap %d0
    clrw %d0
    movel %d0,%sp@-
    swap %d1
    clrw %d1
    movel %d1,%sp@-
    tstb %a2@(132)
    jbne CRSRDEV_2D4
    movel %sp@+,%a2@(116)
    movel %sp@+,%a2@(112)
    st %a2@(132)
    jbra CRSRDEV_30C
CRSRDEV_2D4:            /* set %d0 */
    movel %sp@+,%d0
    addl %d0,%a2@(124)
    movel %sp@+,%d0
    addl %d0,%a2@(120)
    movew %a2@(130),%d0
    subw %a2@(128),%d0
    cmpiw #30,%d0
    jbge CRSRDEV_2FA
    addw %d0,%a2@(130)
    addqw #1,%a2@(130)
    lsrw %a2@(130)
CRSRDEV_2FA:            /* set %d0 */
    moveq #8,%d0
    movew %a2@(130),%a2@(128)
    cmpw %a2@(128),%d0
    jbge CRSRDEV_30C
    movew %d0,%a2@(128)
CRSRDEV_30C:            /* set %d0 */
    movel %fp@(-4),%d0
    jbeq CRSRDEV_322
    movel %a2@(124),%d1
    eorl %d1,%d0
    jbpl CRSRDEV_322
    addl %d1,%a2@(116)
    clrl %a2@(124)
CRSRDEV_322:            /* set %d0 */
    movel %fp@(-8),%d0
    jbeq CRSRDEV_338
    movel %a2@(120),%d1
    eorl %d1,%d0
    jbpl CRSRDEV_338
    addl %d1,%a2@(112)
    clrl %a2@(120)
CRSRDEV_338:            /* return */
    unlk %fp
    moveq #0,%d0
    rts

CRSRDEVDISPATCH_33E:    /* set %d1 */
    moveb %d0,%d1
    moveq #7,%d3
CRSRDEV_342:            /* loop: btst */
    btst %d3,%d1
    jbeq CRSRDEV_366
    btst %d3,%a2@(27)
    jbne CRSRDEV_38C
    movel Ticks,%d0
    movew %d3,%d2
    lslw #2,%d2
    subl %a2@(0x24,%d2:w),%d0
    addl %d0,RndSeed
    subql #2,%d0
    jbmi CRSRDEV_38C
    bset %d3,%a2@(27)
    jbra CRSRDEV_37A
CRSRDEV_366:            /* from here: btst %d3,%a2@(27) */
    btst %d3,%a2@(27)
    jbeq CRSRDEV_38C
    movew %d3,%d2
    lslw #2,%d2
    movel Ticks,%a2@(0x24,%d2:w)
    bclr %d3,%a2@(27)
CRSRDEV_37A:            /* set %d0 */
    moveb %a2@(0x1c,%d3:w),%d0
    extw %d0
    addw %d0,%d0
    lea %pc@(CRSRDEVDISPATCH_394),%a0
    addaw %a0@(0x0,%d0:w),%a0
    jsr %a0@
CRSRDEV_38C:            /* count down */
    dbf %d3,CRSRDEV_342
    moveq #0,%d0
    rts
CRSRDEVDISPATCH_394:    /* (data) */
    .short  CRSRDEVDISPATCH_3A2-CRSRDEVDISPATCH_394	| 408B6764
    .short  CRSRDEVDISPATCH_3A4-CRSRDEVDISPATCH_394	| 408B6766
    .short  CRSRDEVDISPATCH_3B4-CRSRDEVDISPATCH_394	| 408B6768
    .short  CRSRDEV_3C6-CRSRDEVDISPATCH_394	| 408B676A
    .short  CRSRDEV_3EA-CRSRDEVDISPATCH_394	| 408B676C
    .short  CRSRDEV_3EC-CRSRDEVDISPATCH_394	| 408B676E
    .short  CRSRDEV_3EE-CRSRDEVDISPATCH_394	| 408B6770
CRSRDEVDISPATCH_3A2:    /* return */
    rts	| 408B6772
CRSRDEVDISPATCH_3A4:    /* from here: btst %d3,%a2@(27) */
    btst %d3,%a2@(27)	| 408B6774
    jbeq CRSRDEVDISPATCH_3AE	| 408B6778
    jbsr CRSRDEVDISPATCH_3F4	| 408B677A
    jbra CRSRDEVDISPATCH_3B2	| 408B677C
CRSRDEVDISPATCH_3AE:    /* call CRSRDEVDISPATCH_434 */
    jbsr CRSRDEVDISPATCH_434	| 408B677E
CRSRDEVDISPATCH_3B2:    /* return */
    rts	| 408B6782
CRSRDEVDISPATCH_3B4:    /* from here: btst %d3,%a2@(27) */
    btst %d3,%a2@(27)	| 408B6784
    jbeq CRSRDEVDISPATCH_3C2	| 408B6788
    jbsr CRSRDEVDISPATCH_3F4
    jbsr CRSRDEVDISPATCH_434
    jbsr CRSRDEVDISPATCH_3F4
    jbra CRSRDEV_3C4
CRSRDEVDISPATCH_3C2:    /* call CRSRDEVDISPATCH_434 */
    jbsr CRSRDEVDISPATCH_434	| 408B6792
CRSRDEV_3C4:            /* return */
    rts
CRSRDEV_3C6:            /* (408B6796 tstb %a2@(44,%d3:w)) */
    .short  0x4A32, 0x3044	| 408B6796 tstb %a2@(44,%d3:w)
    jbne CRSRDEV_3DC	| 408B679A
    btst %d3,%a2@(27)	| 408B679C
    jbeq CRSRDEV_3D6	| 408B67A0
    jbsr CRSRDEVDISPATCH_3F4	| 408B67A2
    jbra CRSRDEV_3E8	| 408B67A4
CRSRDEV_3D6:            /* (408B67A6 st %a2@(44,%d3:w)) */
    st %a2@(0x44,%d3:w)	| 408B67A6
    jbra CRSRDEV_3E8	| 408B67AA
CRSRDEV_3DC:            /* from here: btst %d3,%a2@(27) */
    btst %d3,%a2@(27)	| 408B67AC
    jbne CRSRDEV_3E8	| 408B67B0
    jbsr CRSRDEVDISPATCH_434	| 408B67B2
    clrb %a2@(0x44,%d3:w)	| 408B67B4
CRSRDEV_3E8:            /* return */
    rts	| 408B67B8
CRSRDEV_3EA:            /* return */
    rts	| 408B67BA
CRSRDEV_3EC:            /* return */
    rts	| 408B67BC
CRSRDEV_3EE:            /* from here: pea %a2@(68) */
    pea %a2@(68)	| 408B67BE
    rts	| 408B67C2

CRSRDEVDISPATCH_3F4:    /* set %a1 */
    moveal %a2@(4),%a1
    moveal ExpandMem,%a0
    moveal %a0@(480),%a0
    moveal %a0@(4),%a0
    cmpal %a0,%a1
    jbne CRSRDEV_426
    movel %a2@(100),DoubleTime
    tstb %a1@(21)
    jbne CRSRDEV_426
    tstb MBState
    jbpl CRSRDEV_426
    clrb MBState
    moveq #0,%d0
    moveaw #1,%a0
    _PostEvent
CRSRDEV_426:            /* set MBTicks */
    movel Ticks,MBTicks
    addqb #1,%a1@(21)
    moveq #0,%d0
    rts

CRSRDEVDISPATCH_434:    /* set %a1 */
    moveal %a2@(4),%a1
    moveal ExpandMem,%a0
    moveal %a0@(480),%a0
    moveal %a0@(4),%a0
    subqb #1,%a1@(21)
    jbpl CRSRDEV_44E
    clrb %a1@(21)
CRSRDEV_44E:            /* test %a0,%a1 */
    cmpal %a0,%a1
    jbne CRSRDEV_46C
    tstb %a1@(21)
    jbne CRSRDEV_46C
    tstb MBState
    jbmi CRSRDEV_46C
    bset #7,MBState
    moveq #0,%d0
    moveaw #2,%a0
    _PostEvent
CRSRDEV_46C:            /* result 0 */
    moveq #0,%d0
    rts

CRSRDEVDISPATCH_470:    /* loop: move */
    movel %d0,%a2@(104)
    moveml %d2-%d7/%a3-%a4,%sp@-
    movel %a2@(108),%d0
    jbeq CRSRDEV_482
    moveal %d0,%a0
    _DisposPtr
CRSRDEV_482:            /* set up and call _CountResources */
    movew #-1,ROMMapInsert
    clrw %sp@-
    movel #1633903468,%sp@-
    _CountResources
    movew %sp@+,%d3
    jbeq CRSRDEV_4B8
    movel %a2@(16),%d4
    jbeq CRSRDEV_4A2
    jbsr CRSRDEVDISPATCH_62C
    jbeq CRSRDEV_4BA
CRSRDEV_4A2:            /* set %d4 */
    moveb %a2@(24),%d4
    extw %d4
    extl %d4
    jbsr CRSRDEVDISPATCH_62C
    jbeq CRSRDEV_4BA
    moveq #0,%d4
    jbsr CRSRDEVDISPATCH_62C
    jbeq CRSRDEV_4BA
CRSRDEV_4B8:            /* _Debugger */
    _Debugger
CRSRDEV_4BA:            /* set %d3 */
    movel %a2@(104),%d3
    movew %a0@+,%d2
    moveal %a0,%a1
CRSRDEV_4C2:            /* loop: cmp */
    cmpl %a0@,%d3
    jble CRSRDEV_4D2
    moveal %a0,%a1
    addql #4,%a0
    movew %a0@+,%d0
    aslw #3,%d0
    addaw %d0,%a0
    jbra CRSRDEV_4C2
CRSRDEV_4D2:            /* set %a3 */
    moveal %a0,%a3
    cmpal %a1,%a3
    jbne CRSRDEV_4E2
    addqw #4,%a1
    addqw #4,%a3
    moveq #1,%d7
    swap %d7
    jbra CRSRDEV_4F2
CRSRDEV_4E2:            /* clear %sp@- */
    clrl %sp@-
    subl %a1@,%d3
    movel %d3,%sp@-
    movel %a3@+,%d0
    subl %a1@+,%d0
    movel %d0,%sp@-
    _FixDiv
    movel %sp@+,%d7
CRSRDEV_4F2:            /* set %a4 */
    moveal %sp,%a4
    moveq #0,%d3
    moveq #0,%d4
    clrl %sp@-
    clrl %sp@-
    movew %a1@+,%d5
    movew %a3@+,%d6
    cmpal %a1,%a3
    jbne CRSRDEV_506
    moveq #0,%d5
CRSRDEV_506:            /* loop: tst */
    tstw %d5
    jbeq CRSRDEV_534
    tstw %d6
    jbeq CRSRDEV_514
    movel %a1@,%d0
    cmpl %a3@,%d0
    jbgt CRSRDEV_534
CRSRDEV_514:            /* set %sp@- */
    movel %a3@,%sp@-
    movel %a3@(4),%sp@-
    movel %a1@,%sp@-
    movel %a1@(4),%sp@-
    subqw #1,%d5
    jble CRSRDEV_528
    addqw #8,%a1
    jbra CRSRDEV_52A
CRSRDEV_528:            /* clear %d5 */
    moveq #0,%d5
CRSRDEV_52A:            /* set bit 31 of %d7 */
    bset #31,%d7
    jbsr CRSRDEVDISPATCH_654
    jbra CRSRDEV_54E
CRSRDEV_534:            /* set %sp@- */
    movel %a1@,%sp@-
    movel %a1@(4),%sp@-
    movel %a3@,%sp@-
    movel %a3@(4),%sp@-
    subqw #1,%d6
    jble CRSRDEV_548
    addqw #8,%a3
    jbra CRSRDEV_54A
CRSRDEV_548:            /* clear %d6 */
    moveq #0,%d6
CRSRDEV_54A:            /* call CRSRDEVDISPATCH_654 */
    jbsr CRSRDEVDISPATCH_654
CRSRDEV_54E:            /* test %d5 */
    tstw %d5
    jbeq CRSRDEV_56A
    tstw %d6
    jbeq CRSRDEV_56A
    movel %a1@,%d0
    cmpl %a3@,%d0
    jble CRSRDEV_574
    addqw #8,%sp
    movel %sp@(12),%sp@(4)
    movel %sp@(8),%sp@
    jbra CRSRDEV_57C
CRSRDEV_56A:            /* add 8 to %sp */
    addqw #8,%sp
    movel %d3,%sp@(4)
    movel %d4,%sp@
    jbra CRSRDEV_57C
CRSRDEV_574:            /* set %sp@(4) */
    movel %sp@+,%sp@(4)
    movel %sp@+,%sp@(4)
CRSRDEV_57C:            /* set %d3 */
    movel %sp@(12),%d3
    movel %sp@(8),%d4
    movel %d1,%sp@(12)
    movel %d2,%sp@(8)
    movew %d5,%d0
    orw %d6,%d0
    jbne CRSRDEV_506
    addqw #8,%sp
    movel %a4,%d0
    subl %sp,%d0
    lsrl #3,%d0
    muluw #12,%d0
    .short  0xA71E	| 408B6970 _NewPtr (flags 0x0700)
    movel %a0,%a2@(108)
    moveal %a0,%a3
    moveal %a4,%a1
    moveq #0,%d1
    moveq #0,%d2
    clrl %sp@-
    movel %a2@(20),%sp@-
    movel #4390912,%sp@-
    _FixDiv
    movel %sp@+,%d6
    clrl %sp@-
    moveal %a2@(4),%a0
    movel %a0@(22),%sp@-
    movel #4390912,%sp@-
    _FixDiv
    movel %sp@+,%d7
CRSRDEV_5D2:            /* set up and call _FixMul (loop) */
    clrl %sp@-
    movel %a1@-,%sp@-
    movel %d6,%sp@-
    _FixMul
    movel %sp@+,%d3
    movel %d3,%a3@
    clrl %sp@-
    movel %a1@-,%sp@-
    movel %d7,%sp@-
    _FixMul
    movel %sp@+,%d4
    clrl %sp@-
    movel %d4,%d0
    subl %d2,%d0
    movel %d0,%sp@-
    movel %d3,%d0
    subl %d1,%d0
    movel %d0,%sp@-
    _FixDiv
    movel %sp@+,%a3@(4)
    clrl %sp@-
    movel %a3@(4),%sp@-
    movel %d3,%sp@-
    _FixMul
    movel %d4,%d0
    subl %sp@+,%d0
    movel %d0,%a3@(8)
    lea %a3@(12),%a3
    movel %d3,%d1
    movel %d4,%d2
    cmpal %a1,%sp
    jblt CRSRDEV_5D2
    moveal %a4,%sp
    movel #2147483647,%a3@(-12)
    moveml %sp@+,%d2-%d7/%a3-%a4
    moveq #0,%d0
    rts

CRSRDEVDISPATCH_62C:    /* set %d5 */
    movew %d3,%d5
CRSRDEV_62E:            /* loop: move */
    movew #-1,ROMMapInsert
    clrl %sp@-
    movel #1633903468,%sp@-
    movew %d5,%sp@-
    _GetIndResource
    movel %sp@+,%d0
    jbeq CRSRDEV_64C
    moveal %d0,%a0
    moveal %a0@,%a0
    cmpl %a0@+,%d4
    jbeq CRSRDEV_652
CRSRDEV_64C:            /* subtract 1 to %d5 */
    subqw #1,%d5
    jbne CRSRDEV_62E
    moveq #1,%d0
CRSRDEV_652:            /* return */
    rts

CRSRDEVDISPATCH_654:    /* entry: stack frame */
    linkw %fp,#0
    clrl %sp@-
    movel %fp@(16),%d0
    subl %fp@(24),%d0
    movel %d0,%sp@-
    movel %fp@(20),%d0
    subl %fp@(28),%d0
    movel %d0,%sp@-
    _FixDiv
    clrl %sp@-
    movel %sp@(4),%sp@-
    movel %fp@(28),%sp@-
    _FixMul
    movel %fp@(24),%d1
    subl %sp@+,%d1
    movel %sp@,%sp@-
    movel %fp@(12),%sp@-
    _FixMul
    addl %sp@+,%d1
    clrl %sp@-
    movel %fp@(8),%d0
    subl %d1,%d0
    movel %d0,%sp@-
    movel %d7,%sp@-
    bclr #7,%sp@
    _FixMul
    bclr #31,%d7
    jbne CRSRDEV_6AA
    movel %sp@+,%d2
    addl %d1,%d2
    jbra CRSRDEV_6B0
CRSRDEV_6AA:            /* set %d2 */
    movel %fp@(8),%d2
    subl %sp@+,%d2
CRSRDEV_6B0:            /* set %d1 */
    movel %fp@(12),%d1
    unlk %fp
    rts

/* CRSRDEVHANDLEVBL: VBL task: move the cursor from the accumulated device movement. */
CRSRDEVHANDLEVBL:
    moveml %d1-%d5/%a0-%a4,%sp@-
    moveal ExpandMem,%a3
    moveal %a3@(480),%a3
    movel %a3@,%d0
    jbeq CRSRDEVHANDLEVBL_19A
    moveal %d0,%a2
    tstb CrsrNew
    jbeq CRSRDEVHANDLEVBL_76
    clrb CrsrNew
    moveal %a3@(4),%a4
    tstb %a4@(20)
    jbne CRSRDEVHANDLEVBL_76
    movel MTemp_v,%d0
    cmpl RawMouse_v,%d0
    jbne CRSRDEVHANDLEVBL_46
    movew %d0,%a4@(8)
    clrw %a4@(10)
    swap %d0
    movew %d0,%a4@(12)
    clrw %a4@(14)
    jbra CRSRDEVHANDLEVBL_76
CRSRDEVHANDLEVBL_46:    /* set %d0 */
    movew Mouse_h,%d0
    subw %a4@(18),%d0
    addw MTemp_h,%d0
    subw RawMouse_h,%d0
    swap %d0
    clrw %d0
    addl %d0,%a4@(8)
    movew Mouse_v,%d0
    subw %a4@(16),%d0
    addw MTemp_v,%d0
    subw RawMouse_v,%d0
    swap %d0
    clrw %d0
    addl %d0,%a4@(12)
CRSRDEVHANDLEVBL_76:    /* loop: movea */
    moveal %a2@(4),%a4
    tstb %a4@(20)
    jbeq CRSRDEVHANDLEVBL_9E
    clrl %a2@(112)
    clrl %a2@(116)
    clrl %a2@(120)
    clrl %a2@(124)
    movew #-104,%a2@(128)
    clrb %a2@(132)
    jbra CRSRDEVHANDLEVBL_172
CRSRDEVHANDLEVBL_9E:    /* test %a2@(132) */
    tstb %a2@(132)
    jbeq CRSRDEVHANDLEVBL_FA
    clrb %a2@(132)
    tstw %a2@(128)
    jble CRSRDEVHANDLEVBL_E0
    clrl %sp@-
    movel %a2@(120),%sp@-
    moveq #0,%d0
    movew %a2@(128),%d0
    swap %d0
    movel %d0,%sp@-
    _FixDiv
    movel %sp@+,%d3
    clrl %sp@-
    movel %a2@(124),%sp@-
    moveq #0,%d0
    movew %a2@(128),%d0
    swap %d0
    movel %d0,%sp@-
    _FixDiv
    movel %sp@+,%d4
    subl %d3,%a2@(120)
    subl %d4,%a2@(124)
    jbra CRSRDEVHANDLEVBL_E4
CRSRDEVHANDLEVBL_E0:    /* clear %d3 */
    moveq #0,%d3
    moveq #0,%d4
CRSRDEVHANDLEVBL_E4:    /* from here: addl %a2@(112),%d3 */
    addl %a2@(112),%d3
    addl %a2@(116),%d4
    cmpiw #-100,%a2@(128)
    jble CRSRDEVHANDLEVBL_110
    subqw #1,%a2@(128)
    jbra CRSRDEVHANDLEVBL_110
CRSRDEVHANDLEVBL_FA:    /* set %d3 */
    movel %a2@(120),%d3
    movel %a2@(124),%d4
    clrl %a2@(120)
    clrl %a2@(124)
    movew #-102,%a2@(128)
CRSRDEVHANDLEVBL_110:   /* set %d0 */
    movel %d3,%d0
    jbpl CRSRDEVHANDLEVBL_116
    negl %d0
CRSRDEVHANDLEVBL_116:   /* set %d1 */
    movel %d4,%d1
    jbpl CRSRDEVHANDLEVBL_11C
    negl %d1
CRSRDEVHANDLEVBL_11C:   /* test %d1,%d0 */
    cmpl %d1,%d0
    jbgt CRSRDEVHANDLEVBL_124
    lsrl #1,%d0
    jbra CRSRDEVHANDLEVBL_126
CRSRDEVHANDLEVBL_124:   /* from here: lsrl #1,%d1 */
    lsrl #1,%d1
CRSRDEVHANDLEVBL_126:   /* from here: addl %d0,%d1 */
    addl %d0,%d1
    jbeq CRSRDEVHANDLEVBL_172
    moveal %a2@(108),%a1
    clrw %d0
CRSRDEVHANDLEVBL_130:   /* loop: cmp */
    cmpl %a1@(0x0,%d0:w),%d1
    jble CRSRDEVHANDLEVBL_13C
    addiw #12,%d0
    jbra CRSRDEVHANDLEVBL_130
CRSRDEVHANDLEVBL_13C:   /* set %sp@- */
    movel %a1@(0x8,%d0:w),%sp@-
    clrl %sp@-
    movel %a1@(0x4,%d0:w),%sp@-
    movel %d1,%sp@-
    _FixMul
    movel %sp@+,%d0
    addl %sp@+,%d0
    clrl %sp@-
    movel %d0,%sp@-
    movel %d1,%sp@-
    _FixDiv
    clrl %sp@-
    movel %sp@(4),%sp@-
    movel %d3,%sp@-
    _FixMul
    movel %sp@+,%d0
    addl %d0,%a4@(8)
    movel %sp@,%sp@-
    movel %d4,%sp@-
    _FixMul
    movel %sp@+,%d0
    addl %d0,%a4@(12)
CRSRDEVHANDLEVBL_172:   /* set %a2 */
    moveal %a2@,%a2
    movel %a2,%d0
    jbne CRSRDEVHANDLEVBL_76
    moveal %a3@(4),%a4
CRSRDEVHANDLEVBL_17E:   /* loop: clr */
    clrb %a4@(20)
    movew %a4@(8),%a4@(18)
    movew %a4@(12),%a4@(16)
    moveal %a4@,%a4
    movel %a4,%d0
    jbne CRSRDEVHANDLEVBL_17E
    moveal %a3@(12),%a0
    jsr %a0@
CRSRDEVHANDLEVBL_19A:   /* restore registers, return */
    moveml %sp@+,%d1-%d5/%a0-%a4
    rts
CRSRDEVHANDLEVBL_1A0:   /* set %a4 */
    moveal %a3@(4),%a4
    movel %a4@(16),%d0
    cmpl Mouse_v,%d0
    jbeq CRSRDEVHANDLEVBL_216
    tstb CrsrCouple
    jbeq CRSRDEVHANDLEVBL_216
    tstb CrsrBusy
    jbne CRSRDEVHANDLEVBL_216
    lea CrsrPin,%a0
    jbsr thunk_FUN_4082e0c2
    movel Mouse_v,%d0
    cmpl %a4@(16),%d0
    jbeq CRSRDEVHANDLEVBL_216
    movel %d0,%a4@(16)
    movel MouseMask,%d1
    notl %d1
    tstw %d1
    jbeq CRSRDEVHANDLEVBL_1EC
    movew %a4@(8),%d0
    subw Mouse_h,%d0
    jbpl CRSRDEVHANDLEVBL_1E8
    negw %d0
CRSRDEVHANDLEVBL_1E8:   /* test %d1,%d0 */
    cmpw %d1,%d0
    jble CRSRDEVHANDLEVBL_1F6
CRSRDEVHANDLEVBL_1EC:   /* set %a4@(8) */
    movew RawMouse_h,%a4@(8)
    clrw %a4@(10)
CRSRDEVHANDLEVBL_1F6:   /* from here: swap %d1 */
    swap %d1
    tstw %d1
    jbeq CRSRDEVHANDLEVBL_20C
    movew %a4@(12),%d0
    subw Mouse_v,%d0
    jbpl CRSRDEVHANDLEVBL_208
    negw %d0
CRSRDEVHANDLEVBL_208:   /* test %d1,%d0 */
    cmpw %d1,%d0
    jble CRSRDEVHANDLEVBL_216
CRSRDEVHANDLEVBL_20C:   /* set %a4@(12) */
    movew RawMouse_v,%a4@(12)
    clrw %a4@(14)
CRSRDEVHANDLEVBL_216:   /* return */
    rts

CRSRDEVHANDLEVBL_218:   /* loop: move */
    movel #134,%d0
    .short  0xA71E	| 408B6CA6 _NewPtr (flags 0x0700)
    jbne CRSRDEVHANDLEVBL_29A
    moveal %a0,%a2
    moveal ExpandMem,%a0
    moveal %a0@(480),%a0
    movel %a0@,%a2@
    movel %a2,%a0@
    movel %a0@(4),%a2@(4)
    moveb #1,%a2@(24)
    moveb #1,%a2@(25)
    moveb #1,%a2@(28)
    movel #4718592,%a2@(20)
    subqw #4,%sp
    moveal %sp,%a0
    movel #131080,%d0
    _ReadXPRam
    movel %sp@+,%d1
    movel %d1,%d0
    roll #7,%d0
    andiw #28,%d0
    lea %pc@(CRSRDEVHANDLEVBL_29E),%a0
    movel %a0@(0x0,%d0:w),%a2@(104)
    moveq #12,%d0
    roll %d0,%d1
    andiw #15,%d1
    lea %pc@(CRSRDEVHANDLEVBL_2BE),%a0
    moveq #0,%d0
    moveb %a0@(0x0,%d1:w),%d0
    movel %d0,%a2@(100)
    movel %d0,DoubleTime
    movew #-101,%a2@(128)
    movew #4,%a2@(130)
    moveq #0,%d0
    rts
CRSRDEVHANDLEVBL_29A:   /* result -1 */
    moveq #-1,%d0
    rts
CRSRDEVHANDLEVBL_29E:   /* (data) */
    .short  0x0000, 0x0000	| 408B6D26
    .long   0x00002000 /* number, not an address (F4) */	| 408B6D2A
    .long   0x00005000 /* number, not an address (F4) */	| 408B6D2E
    .long   0x00008000 /* number, not an address (F4) */	| 408B6D32
    .long   0x0000B000 /* number, not an address (F4) */	| 408B6D36
    .long   0x0000E000 /* number, not an address (F4) */	| 408B6D3A
    .long   0x00010000 /* number, not an address (F4) */	| 408B6D3E
    .long   0x00010000 /* number, not an address (F4) */	| 408B6D42
CRSRDEVHANDLEVBL_2BE:   /* (data) */
    .short  0x0C0C, 0x0C0C, 0x1014, 0x171B, 0x2023	| 408B6D46
    .short  0x262C, 0x3034, 0x383C	| 408B6D50
CRSRDEVHANDLEVBL_2CE:   /* loop: movea */
    moveal ExpandMem,%a0
    moveal %a0@(480),%a0
    moveal %a0@,%a1
    moveq #0,%d1
CRSRDEVHANDLEVBL_2DA:   /* loop: cmpa */
    cmpal %a1,%a2
    jbeq CRSRDEVHANDLEVBL_2E8
    movel %a1,%d1
    movel %a1@,%d0
    jbeq CRSRDEVHANDLEVBL_304
    moveal %d0,%a1
    jbra CRSRDEVHANDLEVBL_2DA
CRSRDEVHANDLEVBL_2E8:   /* set %a1 */
    moveal %a1@,%a1
    tstl %d1
    jbeq CRSRDEVHANDLEVBL_2F4
    moveal %d1,%a2
    movel %a1,%a2@
    jbra CRSRDEVHANDLEVBL_2F6
CRSRDEVHANDLEVBL_2F4:   /* set %a0@ */
    movel %a1,%a0@
CRSRDEVHANDLEVBL_2F6:   /* set up and call _DisposPtr */
    movel %a2@(108),%d0
    jbeq CRSRDEVHANDLEVBL_300
    moveal %d0,%a0
    _DisposPtr
CRSRDEVHANDLEVBL_300:   /* set up and call _DisposPtr */
    moveal %a2,%a0
    _DisposPtr
CRSRDEVHANDLEVBL_304:   /* result 0 */
    moveq #0,%d0
    rts

/* CRSRDEVREINIT: reinitialise the cursor devices (after ADBReInit). */
CRSRDEVREINIT:
    moveml %d0-%d3/%a0-%a3,%sp@-
    linkw %fp,#-10
    jbne CRSRDEVREINIT_46
    _CountADBs
    movew %d0,%d2
    jbeq CRSRDEVREINIT_1C4
CRSRDEVREINIT_12:       /* set up and call _GetIndADB (loop) */
    lea %fp@(-10),%a0
    movew %d2,%d0
    _GetIndADB
    jbmi CRSRDEVREINIT_34
    cmpib #3,%fp@(-9)
    jbne CRSRDEVREINIT_34
    moveal %fp@(-4),%a2
    clrl %fp@(-4)
    lea %fp@(-8),%a0
    _SetADBInfo
    jbsr CRSRDEVHANDLEVBL_2CE
CRSRDEVREINIT_34:       /* subtract 1 to %d2 */
    subqw #1,%d2
    jbgt CRSRDEVREINIT_12
    moveal ExpandMem,%a0
    moveal %a0@(480),%a0
    clrl %a0@
    jbra CRSRDEVREINIT_1C4
CRSRDEVREINIT_46:       /* set up and call _CountADBs */
    bset #7,MBState
    clrl MBTicks
    _CountADBs
    movew %d0,%d2
    subaw #10,%sp
    jbeq CRSRDEVREINIT_17A
CRSRDEVREINIT_5C:       /* set up and call _GetIndADB (loop) */
    lea %fp@(-10),%a0
    movew %d2,%d0
    _GetIndADB
    movew %d0,%d3
    jbmi CRSRDEVREINIT_172
    cmpib #3,%fp@(-9)
    jbne CRSRDEVREINIT_172
    jbsr CRSRDEVHANDLEVBL_218
    moveb %d3,%d0
    lslb #4,%d0
    orib #15,%d0
    moveal %sp,%a0
    jbsr CRSRDEVREINIT_1CC
    tstb %a0@
    jbeq CRSRDEVREINIT_172
    moveb #4,%a0@(2)
    moveb %d3,%d0
    lslb #4,%d0
    orib #11,%d0
    jbsr CRSRDEVREINIT_1EA
    moveb %d3,%d0
    lslb #4,%d0
    orib #15,%d0
    moveal %sp,%a0
    jbsr CRSRDEVREINIT_1CC
    tstb %a0@
    jbeq CRSRDEVREINIT_172
    cmpib #4,%a0@(2)
    jbne CRSRDEVREINIT_108
    moveb %d3,%d0
    lslb #4,%d0
    orib #13,%d0
    jbsr CRSRDEVREINIT_1CC
    cmpib #8,%a0@
    jbne CRSRDEVREINIT_108
    moveb %a0@(1),%a2@(16)
    moveb %a0@(2),%a2@(17)
    moveb %a0@(3),%a2@(18)
    moveb %a0@(4),%a2@(19)
    moveb %a0@(5),%a2@(20)
    moveb %a0@(6),%a2@(21)
    clrw %a2@(22)
    moveb %a0@(7),%a2@(24)
    moveb %a0@(8),%a2@(25)
    moveb #1,%a2@(29)
    jbra CRSRDEVREINIT_156
CRSRDEVREINIT_108:      /* set %a0@(2) */
    moveb #2,%a0@(2)
    moveb %d3,%d0
    lslb #4,%d0
    orib #11,%d0
    jbsr CRSRDEVREINIT_1EA
    moveb %d3,%d0
    lslb #4,%d0
    orib #15,%d0
    moveal %sp,%a0
    jbsr CRSRDEVREINIT_1CC
    tstb %a0@
    jbeq CRSRDEVREINIT_172
    cmpib #2,%a0@(2)
    jbne CRSRDEVREINIT_144
    movel #1077030960,%a2@(16)
    movew #200,%a2@(20)
    jbra CRSRDEVREINIT_156
CRSRDEVREINIT_144:      /* set %a0@(2) */
    moveb #1,%a0@(2)
    moveb %d3,%d0
    lslb #4,%d0
    orib #11,%d0
    jbsr CRSRDEVREINIT_1EA
CRSRDEVREINIT_156:      /* loop: move */
    movel %a2@(104),%d0
    jbsr CRSRDEVDISPATCH_470
    lea %pc@(CRSRDEV_1B2),%a0
    movel %a0,%fp@(-8)
    movel %a2,%fp@(-4)
    lea %fp@(-8),%a0
    movew %d3,%d0
    _SetADBInfo
CRSRDEVREINIT_172:      /* subtract 1 to %d2 */
    subqw #1,%d2
    jbgt CRSRDEVREINIT_5C
    jbmi CRSRDEVREINIT_1B0
CRSRDEVREINIT_17A:      /* set %d3 */
    moveb #3,%d3
    moveq #16,%d0
    moveal ADBBase,%a3
    moveal %a3,%a1
    jbra CRSRDEVREINIT_18C
CRSRDEVREINIT_188:      /* loop: lea */
    lea %a1@(12),%a1
CRSRDEVREINIT_18C:      /* test %a1@(2),%d3 */
    cmpb %a1@(2),%d3
    jbeq CRSRDEVREINIT_1B0
    tstb %a1@(2)
    dbeq %d0,CRSRDEVREINIT_188
    moveb #1,%a1@
    moveb %d3,%a1@(1)
    moveb %d3,%a1@(2)
    bset %d3,%a3@(335)
    jbsr CRSRDEVHANDLEVBL_218
    jbra CRSRDEVREINIT_156
CRSRDEVREINIT_1B0:      /* address %sp@(10) */
    lea %sp@(10),%sp
    moveal ExpandMem,%a0
    moveal %a0@(480),%a0
    moveal %a0@(4),%a0
    clrb %a0@(21)
CRSRDEVREINIT_1C4:      /* return */
    unlk %fp
    moveml %sp@+,%d0-%d3/%a0-%a3
    rts

CRSRDEVREINIT_1CC:      /* set %sp@- */
    movel %a0,%sp@-
    clrw %sp@-
    moveal %sp,%a1
    movel %sp,%sp@-
    pea %pc@(CRSRDEVREINIT_204)
    movel %a0,%sp@-
    moveal %sp,%a0
    _ADBOp
CRSRDEVREINIT_1DE:      /* loop: tst */
    tstb %a1@
    jbeq CRSRDEVREINIT_1DE
    lea %sp@(14),%sp
    moveal %sp@+,%a0
    rts

CRSRDEVREINIT_1EA:      /* clear %sp@- */
    clrw %sp@-
    moveal %sp,%a1
    movel %sp,%sp@-
    pea %pc@(CRSRDEVREINIT_204)
    movel %a0,%sp@-
    moveal %sp,%a0
    _ADBOp
CRSRDEVREINIT_1FA:      /* loop: tst */
    tstb %a1@
    jbeq CRSRDEVREINIT_1FA
    lea %sp@(14),%sp
    rts
CRSRDEVREINIT_204:      /* from here: st %a2@ */
    st %a2@
    rts

/* INITCRSRDEV: create the Cursor Device Manager globals. */
INITCRSRDEV:
    moveq #20,%d0
    .short  0xA71E	| 408B6F9A _NewPtr (flags 0x0700)
    moveal ExpandMem,%a1
    exg %a0,%a1
    movel %a1,%a0@(480)
    lea %pc@(SETCRSRDELAY_20),%a0
    movel %a0,%a1@(8)
    lea %pc@(CRSRDEVHANDLEVBL_1A0),%a0
    movel %a0,%a1@(12)
    moveq #70,%d0
    .short  0xA71E	| 408B6FB8 _NewPtr (flags 0x0700)
    movel %a0,%a1@(4)
    moveq #16,%d0
    swap %d0
    movel %d0,%a0@(8)
    movel %d0,%a0@(12)
    moveq #72,%d0
    swap %d0
    movel %d0,%a0@(22)
    lea %pc@(VDRAWCURSOR),%a0
    movel %a0,0x1fb8
    lea %pc@(VERASECURSOR),%a0
    movel %a0,0x1fbc
    bigjmp INITADB

/* SETCRSRDELAY: set the delay before the cursor is drawn. */
SETCRSRDELAY:
    moveal ExpandMem,%a0
    cmpaw #-1,%a0
    jbeq SETCRSRDELAY_18
    moveal %a0@(480),%a0
    movel %a0@(8),%d0
    jbeq SETCRSRDELAY_18
    moveal %d0,%a0
    jsr %a0@
SETCRSRDELAY_18:        /* set %a0 */
    moveal CrsrPtr,%a0
    moveal %a0@,%a0
    rts
SETCRSRDELAY_20:        /* return */
    rts

/* VDRAWCURSOR: vectored DrawCursor. */
VDRAWCURSOR:
    moveb #1,CrsrBusy
    tstw CrsrState
    jbmi VDRAWCURSOR_22
    clrw CrsrState
    tstb CrsrVis
    jbne VDRAWCURSOR_22
    tstb CrsrObscure
    jbne VDRAWCURSOR_22
    jbsr BLITCURSOR
VDRAWCURSOR_22:         /* clear CrsrBusy */
    clrb CrsrBusy
    rts

/* VERASECURSOR: vectored EraseCursor. */
VERASECURSOR:
    moveb #1,CrsrBusy
    tstb CrsrVis
    jbeq VERASECURSOR_12
    jbsr UNBLITCURSOR
VERASECURSOR_12:        /* clear CrsrBusy */
    clrb CrsrBusy
    rts

/* ADBPROCPATCH: ADB reinit hook: reinitialise the cursor devices before the ADB reinit, return the device count. */
ADBPROCPATCH:
    tstw %d0
    jbne ADBPROCPATCH_C
    jbsr CRSRDEVREINIT
    _CountADBs
    rts
ADBPROCPATCH_C:         /* add 4 to %sp */
    addqw #4,%sp
    rts
    .fill   0x372, 1, 0x00
