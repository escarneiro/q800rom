/* ROM resource 'enet' 46: map entry at 0x408D5AD0, data at 0x408D5B00, 6096 bytes

 The Ethernet driver for the built-in Ethernet ("Macintosh LC Ethernet Driver v1.0.4d2",
 (c) Apple 1990-1992; an 'enet' resource): loaded by the .ENET shell (DRVR 127) and installed
 in its place. It reads the machine's Ethernet configuration ('ecfg' resources: chip and DMA
 addresses) and drives the Ethernet controller (on the Quadras the built-in SONIC). Comments inferred; routines summarised
 mechanically.
*/

rsrc_enet_46_entry:     /* map entry */
    .long   0x38000000, 0x00000000	| 408D5AD0
    .long   rsrc_ecfg_19_MacLC_LCII_entry-rom_start	| 408D5AD8
    .long   rsrc_enet_46-rom_start	| 408D5ADC
    .ascii  "enet"	| 408D5AE0
    .byte   0x00, 0x2E, 0x58, 0x00	| 408D5AE4
    FILL_408D5AE8
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x17, 0xDC, 0x00, 0x00, 0x03, 0x24	| 408D5AF4

/* subroutine (0 instructions): low memory ENET, Ethernet, Driver (mechanical summary) */
rsrc_enet_46:
    .byte   0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408D5B00
rsrc_enet_46_8:         /* (data) */
    .short  rsrc_enet_46_open-rsrc_enet_46	| 408D5B08
    .short  rsrc_enet_46_prime-rsrc_enet_46	| 408D5B0A
    .short  rsrc_enet_46_ctl-rsrc_enet_46	| 408D5B0C
    .short  rsrc_enet_46_prime-rsrc_enet_46	| 408D5B0E
    .short  rsrc_enet_46_close-rsrc_enet_46	| 408D5B10
    .byte   5	/* 408D5B12 Pascal string length */
    .ascii  ".ENET"	| 408D5B13
rsrc_enet_46_18:        /* (data) */
    .byte   0x01, 0x04, 0x20, 0x02, 0x00, 0x00, 0x07	| 408D5B18
    .ascii  "1.0.4d2GMacintosh LC Ethernet Driver v1.0.4d2; "	| 408D5B1F
    .byte   0xA9, 0x20	| 408D5B4E
    .long   0x4170706C, 0x6520436F, 0x6D707574, 0x65722C20	| 408D5B50
    .short  0x496E, 0x632E, 0x2031, 0x3939, 0x302D, 0x3139, 0x3932	| 408D5B60

/* subroutine (281 instructions): traps Gestalt, NewPtr, StripAddress, GetTrapAddress, GetResource, BlockMove, ReleaseResource, MemoryDispatch; calls rsrc_enet_46_42A, rsrc_enet_46_B4A_3C, rsrc_enet_46_40E, rsrc_enet_46_B8C, rsrc_enet_46_B0E ...; low memory ROMMapInsert (mechanical summary) */
rsrc_enet_46_open:
    linkw %fp,#0
    movel %a1,%sp@-
    movel #1986863136,%d0
    .short  0xA1AD	| 408D5B7A _Gestalt (flags 0x0100)
    jbne rsrc_enet_46_open_20
    movel %a0,%d0
    jbeq rsrc_enet_46_open_20
    bset #5,%a1@(20)
    bset #0,%a1@(5)
rsrc_enet_46_open_20:   /* address %pc@(rsrc_enet_46_BA4) */
    lea %pc@(rsrc_enet_46_BA4),%a3
    movel #590,%d0
    btst #5,%a1@(20)
    jbne rsrc_enet_46_open_38
    subil #160,%d0
rsrc_enet_46_open_38:   /* (_NewPtr (flags 0x0700)) */
    .short  0xA71E	| 408D5BA6 _NewPtr (flags 0x0700)
    jbne rsrc_enet_46_open_37A
    movel %a0,%a3@
    moveal %a0,%a2
    moveb %pc@(rsrc_enet_46_18),%a1@(7)
    movel %a1,%d0
    _StripAddress
    movel %d0,%a2@
    movew #-24530,%d0
    .short  0xA146	| 408D5BC0 _GetTrapAddress (flags 0x0100)
    movel %a0,%a2@(362)
    movew #1500,%a2@(22)
    movel #1835098984,%d0
    .short  0xA1AD	| 408D5BD2 _Gestalt (flags 0x0100)
    movel %a0,%d0
    movew %d0,%a2@(384)
    subqw #4,%sp
    movel #1701013095,%sp@-
    movew %d0,%sp@-
    _GetResource
    movel %sp@+,%d0
    jbne rsrc_enet_46_open_9A
    subqw #4,%sp
    movel #1701013095,%sp@-
    movew %a2@(384),%sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@+,%d0
    jbne rsrc_enet_46_open_9A
    moveq #-1,%d0
    jbra rsrc_enet_46_open_37A
rsrc_enet_46_open_9A:   /* set %a3 */
    moveal %d0,%a3
    moveal %a3@,%a0
    lea %a2@(394),%a1
    moveq #36,%d0
    _BlockMove
    movel %a3,%sp@-
    _ReleaseResource
    lea %a2@(420),%a0
    tstl %a0@
    jbne rsrc_enet_46_open_B8
    tstw %a0@(4)
    jbeq rsrc_enet_46_open_C6
rsrc_enet_46_open_B8:   /* test bit 0 of %a0@ */
    btst #0,%a0@
    jbne rsrc_enet_46_open_C6
    movel %a0@+,%a2@(4)
    movew %a0@+,%a2@(8)
rsrc_enet_46_open_C6:   /* set %d2 */
    moveq #8,%d2
    movel %d2,%d3
    movew %a2@(428),%d0
    jbeq rsrc_enet_46_open_D2
    movew %d0,%d2
rsrc_enet_46_open_D2:   /* (btst #5,%a2@(0x0)@(0x14)) */
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    btst #5,%a2@(0,%za0)@(0x14)	| 408D5C40
    jbne rsrc_enet_46_open_E4
    movew %a2@(426),%d0
    jbeq rsrc_enet_46_open_E4
    movew %d0,%d3
rsrc_enet_46_open_E4:   /* loop: cmpi */
    cmpiw #2,%d3
    jbcs rsrc_enet_46_open_11C
    movel #1748,%d0
    moveq #16,%d1
    muluw %d3,%d1
    addl %d1,%d0
    lsll #1,%d0
    movel #1518,%d1
    muluw %d3,%d1
    addl %d1,%d0
    movel %d0,%d4
    movel %d2,%d1
    muluw #1536,%d1
    addl %d1,%d0
    movel %d0,%d5
    .short  0xA71E	| 408D5C7C _NewPtr (flags 0x0700)
    jbeq rsrc_enet_46_open_124
    subql #1,%d2
    jbhi rsrc_enet_46_open_E4
    moveq #1,%d2
    subql #1,%d3
    jbhi rsrc_enet_46_open_E4
rsrc_enet_46_open_11C:  /* set %d0 */
    movew #-41,%d0
    jbra rsrc_enet_46_open_37A
rsrc_enet_46_open_124:  /* (btst #5,%a2@(0x0)@(0x14)) */
    btst #5,%a2@(0,%za0)@(0x14)	| 408D5C92
    jbne rsrc_enet_46_open_134
    tstb %a2@(419)
    jbeq rsrc_enet_46_open_142
rsrc_enet_46_open_134:  /* set up and call _MemoryDispatch */
    movel %a1,%sp@-
    moveal %d5,%a1
    moveq #4,%d0
    _MemoryDispatch
    moveal %sp@+,%a1
    jbne rsrc_enet_46_open_37A
rsrc_enet_46_open_142:  /* set up and call _StripAddress */
    movel %d2,%a2@(376)
    movel %d1,%d5
    movel %a0,%d0
    _StripAddress
    moveal %d0,%a0
    movel %d0,%a2@(338)
    movel %a0,%a2@(370)
    movel %d2,%d0
    subqw #1,%d0
    jbra rsrc_enet_46_open_164
rsrc_enet_46_open_15C:  /* loop: pea */
    pea %a0@(1526)
    movel %sp@,%a0@
    moveal %sp@+,%a0
rsrc_enet_46_open_164:  /* count down */
    dbf %d0,rsrc_enet_46_open_15C
    clrl %a0@
    lea %a0@(1526),%a0
    movel %a0,%a2@(380)
    moveal %a2@(370),%a1
    movel %d2,%d1
    jbra rsrc_enet_46_open_1A4
rsrc_enet_46_open_17A:  /* save registers */
    moveml %d1/%a0,%sp@-
    movel #1526,%sp@-
    movel %a1,%sp@-
    jbsr rsrc_enet_46_42A
    moveal %sp@+,%a1
    addqw #4,%sp
    moveml %sp@+,%d1/%a0
    movel %a1,%a0@(4)
    movel %d0,%a0@
    movel %d0,%a1@(1520)
    lea %a0@(8),%a0
    lea %a1@(1526),%a1
rsrc_enet_46_open_1A4:  /* count down */
    dbf %d1,rsrc_enet_46_open_17A
    lea %a2@(4),%a1
    tstl %a1@
    jbne rsrc_enet_46_open_1F6
    tstw %a1@(4)
    jbne rsrc_enet_46_open_1F6
    moveq #1,%d0
    _SwapMMUMode
    moveb %d0,%sp@-
    jbsr rsrc_enet_46_B4A_3C
    moveq #0,%d1
    moveq #7,%d0
rsrc_enet_46_open_1C4:  /* loop: move */
    moveb %a0@+,%d2
    eorb %d2,%d1
    dbf %d0,rsrc_enet_46_open_1C4
    subib #0xff,%d1
    jbeq rsrc_enet_46_open_1DC
    moveb %sp@+,%d0
    _SwapMMUMode
    moveq #-1,%d0
    jbra rsrc_enet_46_open_37A
rsrc_enet_46_open_1DC:  /* add 6 to %a1 */
    addqw #6,%a1
    jbsr rsrc_enet_46_B4A_3C
    moveq #5,%d2
rsrc_enet_46_open_1E4:  /* loop: move */
    moveb %a0@(0x0,%d2:w),%d0
    jbsr rsrc_enet_46_40E
    moveb %d0,%a1@-
    dbf %d2,rsrc_enet_46_open_1E4
    moveb %sp@+,%d0
    _SwapMMUMode
rsrc_enet_46_open_1F6:  /* set up and call _StripAddress */
    moveq #-1,%d0
    _StripAddress
    movel %d0,%a2@(358)
    subaw #56,%sp
    pea %pc@(rsrc_enet_46_42A)
    movel %sp@+,%sp@(52)
    jbsr rsrc_enet_46_B8C
    movel %a2@(414),%d0
    movew %d0,%a0@(250)
    movel %a2@(406),%d0
    movel %d0,%sp@(48)
    pea %a2@(278)
    movel %sp@+,%sp@(44)
    pea %pc@(rsrc_enet_46_470)
    movel %sp@+,%sp@(40)
    pea %pc@(rsrc_enet_46_468)
    movel %sp@+,%sp@(36)
    movel %d3,%sp@(32)
    movel %d4,%sp@(28)
    movel %a2@(338),%sp@(24)
    addl %d5,%sp@(24)
    movel %a2,%sp@(20)
    pea %pc@(rsrc_enet_46_77A)
    movel %sp@+,%sp@(16)
    movel %a2@,%sp@(12)
    pea %pc@(rsrc_enet_46_916)
    movel %sp@+,%sp@(8)
    pea %pc@(rsrc_enet_46_476)
    movel %sp@+,%sp@(4)
    jbsr rsrc_enet_46_B8C
    movel %a0,%sp@
    jbsr rsrc_enet_46_B0E
    jbsr rsrc_enet_46_103C
    lea %sp@(56),%sp
    jbsr rsrc_enet_46_B4A
    jblt rsrc_enet_46_open_37A
    jbeq rsrc_enet_46_open_292
    negl %d0
    movel %d0,%sp@-
    moveal %a2@(338),%a0
    .short  0xA421	| 408D5DFA _GetPtrSize (flags 0x0400)
    addl %sp@+,%d0
    .short  0xA420	| 408D5DFE _SetPtrSize (flags 0x0400)
rsrc_enet_46_open_292:  /* from here: subaw #14,%sp */
    subaw #14,%sp
    movel #-1,%sp@(10)
    movel %a2@(6),%sp@(6)
    movew %a2@(4),%sp@(4)
    jbsr rsrc_enet_46_B8C
    movel %a0,%sp@
    jbsr rsrc_enet_46_B0E
    jbsr rsrc_enet_46_1410
    lea %sp@(14),%sp
    jbsr rsrc_enet_46_B4A
    pea %a2@(4)
    moveal %a2@,%a1
    movew %a1@(24),%d0
    movel %d0,%sp@-
    jbsr rsrc_enet_46_B8C
    moveal %a0,%a3
    movew %a3@(8),%d0
    eoriw #-8192,%d0
    oriw #512,%d0
    movew %d0,%a3@(8)
    jbsr rsrc_enet_46_1548
    jbeq rsrc_enet_46_open_36E
    movew %a3@(8),%d0
    eoriw #512,%d0
    oriw #1024,%d0
    movew %d0,%a3@(8)
    jbsr rsrc_enet_46_1548
    jbeq rsrc_enet_46_open_36E
    movew %a3@(8),%d0
    eoriw #1024,%d0
    oriw #1536,%d0
    movew %d0,%a3@(8)
    jbsr rsrc_enet_46_1548
    jbeq rsrc_enet_46_open_36E
    movew %a3@(8),%d0
    eoriw #1536,%d0
    oriw #-8192,%d0
    movew %d0,%a3@(8)
    exg %a2,%a3
    jbsr rsrc_enet_46_C74
    movew %a2@(4),%d0
    movel %a3@(406),%d1
    andiw #15,%d1
    eorw %d1,%d0
    movel %a3@(410),%d1
    orw %d1,%d0
    movew %d0,%a2@(4)
    jbsr rsrc_enet_46_C44
    exg %a2,%a3
    addqw #8,%sp
    moveal %sp@+,%a1
    lea %a2@(344),%a0
    movew #1,%a0@(4)
    pea %pc@(rsrc_enet_46_4C6)
    movel %sp@+,%a0@(6)
    movew #32767,%a0@(10)
    _VInstall
    moveq #0,%d0
    unlk %fp
    rts
rsrc_enet_46_open_36E:  /* add 8 to %sp */
    addqw #8,%sp
    jbsr rsrc_enet_46_close
    moveal %sp@+,%a1
    moveq #-1,%d0
    jbra rsrc_enet_46_open_392
rsrc_enet_46_open_37A:  /* set %d3 */
    movew %d0,%d3
    moveal %sp@+,%a1
    tstl %a2@(338)
    jbeq rsrc_enet_46_open_38A
    moveal %a2@(338),%a0
    _DisposPtr
rsrc_enet_46_open_38A:  /* address %pc@(rsrc_enet_46_BA4) */
    lea %pc@(rsrc_enet_46_BA4),%a3
    clrl %a3@
    movew %d3,%d0
rsrc_enet_46_open_392:  /* test #-1,%d0 */
    cmpiw #-1,%d0
    jbne rsrc_enet_46_open_39A
    moveq #-23,%d0
rsrc_enet_46_open_39A:  /* test %d0 */
    tstw %d0
    unlk %fp
    rts

/* subroutine (11 instructions) (mechanical summary) */
rsrc_enet_46_40E:
    moveml %d2,%sp@-
    clrb %d1
    moveq #7,%d2
rsrc_enet_46_40E_8:     /* loop: ls */
    lslb #1,%d1
    lsrb #1,%d0
    jbcc rsrc_enet_46_40E_10
    addqb #1,%d1
rsrc_enet_46_40E_10:    /* count down */
    dbf %d2,rsrc_enet_46_40E_8
    moveb %d1,%d0
    moveml %sp@+,%d2
    rts

/* subroutine (15 instructions): traps MemoryDispatch (mechanical summary) */
rsrc_enet_46_42A:
    linkw %fp,#-16
    movel %fp@(8),%fp@(-16)
    movel %fp@(8),%fp@(-8)
    moveal %pc@(rsrc_enet_46_BA4),%a0
    btst #5,%a0@(0,%za0)@(0x14)	| 408D5F3E
    jbne rsrc_enet_46_42A_24
    tstb %a0@(419)
    jbeq rsrc_enet_46_42A_36
rsrc_enet_46_42A_24:    /* set %fp@(-12) */
    movel %fp@(12),%fp@(-12)
    lea %fp@(-16),%a0
    lea 0x1,%a1
    moveq #5,%d0
    _MemoryDispatch
rsrc_enet_46_42A_36:    /* set %d0 */
    movel %fp@(-8),%d0
    unlk %fp
    rts

/* subroutine (3 instructions) (mechanical summary) */
rsrc_enet_46_468:
    movew %sr,%d0	| 408D5F68
    movew #9728,%sr	| 408D5F6A
    rts	| 408D5F6E

/* subroutine (2 instructions) (mechanical summary) */
rsrc_enet_46_470:
    movew %sp@(6),%sr	| 408D5F70
    rts	| 408D5F74

/* subroutine (12 instructions): traps SIntInstall (mechanical summary) */
rsrc_enet_46_476:
    lea %pc@(rsrc_enet_46_BB8),%a0	| 408D5F76
    movel %sp@(4),%a0@	| 408D5F7A
    lea %pc@(rsrc_enet_46_BA8),%a0	| 408D5F7E
    movew #6,%a0@(4)	| 408D5F82
    pea %pc@(rsrc_enet_46_4A4)	| 408D5F88
    movel %sp@+,%a0@(8)	| 408D5F8C
    movew #200,%a0@(6)	| 408D5F90
    moveal %pc@(rsrc_enet_46_BA4),%a1	| 408D5F96
    subl %d0,%d0	| 408D5F9A
    moveb %a1@(418),%d0	| 408D5F9C
    _SIntInstall	| 408D5FA0
    rts	| 408D5FA2

/* subroutine (11 instructions): calls rsrc_enet_46_B8C, rsrc_enet_46_B0E, rsrc_enet_46_B4A (mechanical summary) */
rsrc_enet_46_4A4:
    moveml %d1-%d3/%a0,%sp@-
    jbsr rsrc_enet_46_B8C
    movel %a0,%sp@-
    jbsr rsrc_enet_46_B0E
    moveal %pc@(rsrc_enet_46_BB8),%a1
    jsr %a1@
    addqw #4,%sp
    jbsr rsrc_enet_46_B4A
    moveml %sp@+,%d1-%d3/%a0
    moveq #-1,%d0
    rts

/* subroutine (14 instructions): traps StackSpace (mechanical summary) */
rsrc_enet_46_4C6:
    movew #32767,%a0@(10)	| 408D5FC6
    _StackSpace	| 408D5FCC
    tstl %d0	| 408D5FCE
    jbmi rsrc_enet_46_4DA	| 408D5FD0
    cmpil #512,%d0	| 408D5FD2
    jbcc rsrc_enet_46_4E2	| 408D5FD8
rsrc_enet_46_4DA:       /* set %a0@(10) */
    movew #1,%a0@(10)	| 408D5FDA
rsrc_enet_46_4E0:       /* return */
    rts	| 408D5FE0
rsrc_enet_46_4E2:       /* address %a0@(-344) */
    lea %a0@(-344),%a2	| 408D5FE2
    bclr #0,%a2@(342)	| 408D5FE6
    jbeq rsrc_enet_46_4E0	| 408D5FEC
    moveal %a2@,%a1	| 408D5FEE
    moveal %a1@(8),%a0	| 408D5FF0
    jbra rsrc_enet_46_ctl_2C	| 408D5FF4

/* subroutine (24 instructions): traps StackSpace (mechanical summary) */
rsrc_enet_46_ctl:
    movew %a0@(6),%d0
    btst #10,%d0
    jbeq rsrc_enet_46_ctl_2C
    _StackSpace
    tstl %d0
    jbmi rsrc_enet_46_ctl_18
    cmpil #512,%d0
    jbcc rsrc_enet_46_ctl_2C
rsrc_enet_46_ctl_18:    /* set %a2 */
    moveal %pc@(rsrc_enet_46_BA4),%a2
    bset #0,%a2@(342)
    movew #1,%a2@(354)
rsrc_enet_46_ctl_28:    /* result 0 */
    moveq #0,%d0
    rts
rsrc_enet_46_ctl_2C:    /* set %d2 */
    movew %a0@(26),%d2
    subqw #1,%d2
    jbeq rsrc_enet_46_ctl_28
    moveq #-17,%d0
    moveal %pc@(rsrc_enet_46_BA4),%a2
    subiw #244,%d2
    jblt rsrc_enet_46_608_4C
    cmpiw #8,%d2
    jbgt rsrc_enet_46_608_4C
    movew %a0@(28),%d1
    movel %a0@(30),%d3
    movew %pc@(rsrc_enet_46_554:w,%d2:w:2),%d2	| 408D6048
    jmp %pc@(rsrc_enet_46_554:w,%d2:w)
rsrc_enet_46_554:       /* (data) */
    .short  rsrc_enet_46_5D2-rsrc_enet_46_554	| 408D6054
    .short  rsrc_enet_46_566-rsrc_enet_46_554	| 408D6056
    .short  rsrc_enet_46_608_22-rsrc_enet_46_554	| 408D6058
    .short  rsrc_enet_46_65C_16-rsrc_enet_46_554	| 408D605A
    .short  caseD_408d61a2-rsrc_enet_46_554	| 408D605C
    .short  rsrc_enet_46_800-rsrc_enet_46_554	| 408D605E
    .short  rsrc_enet_46_86E-rsrc_enet_46_554	| 408D6060
    .short  rsrc_enet_46_8BA_1A-rsrc_enet_46_554	| 408D6062
    .short  rsrc_enet_46_608_4A-rsrc_enet_46_554	| 408D6064

/* subroutine (25 instructions): calls rsrc_enet_46_608, rsrc_enet_46_B8C, rsrc_enet_46_B0E, rsrc_enet_46_1410, rsrc_enet_46_B4A (mechanical summary) */
rsrc_enet_46_566:
    moveq #-91,%d0
    btst #8,%d1
    jbeq rsrc_enet_46_608_4C
    jbsr rsrc_enet_46_608
    jbpl rsrc_enet_46_586
    moveq #7,%d2
rsrc_enet_46_578:       /* loop: tst */
    tstb %a2@(0xdc,%d2:w:8)
    dbeq %d2,rsrc_enet_46_578
    jbne rsrc_enet_46_608_4C
rsrc_enet_46_586:       /* set %d2:w:8) */
    movel %d3,%a2@(0xd8,%d2:w:8)
    movew %d1,%a2@(0xd6,%d2:w:8)
    addqb #1,%a2@(0xdc,%d2:w:8)
    cmpib #1,%a2@(0xdc,%d2:w:8)
    jbhi rsrc_enet_46_608_4A
    subaw #14,%sp
    movel #-1,%sp@(10)
    movel %d3,%sp@(6)
    movew %d1,%sp@(4)
    jbsr rsrc_enet_46_B8C
    movel %a0,%sp@
    jbsr rsrc_enet_46_B0E
    jbsr rsrc_enet_46_1410
    lea %sp@(14),%sp
    jbsr rsrc_enet_46_B4A
    jbra rsrc_enet_46_608_4A

/* subroutine (16 instructions): calls rsrc_enet_46_608, rsrc_enet_46_B8C, rsrc_enet_46_B0E, rsrc_enet_46_1410, rsrc_enet_46_B4A (mechanical summary) */
rsrc_enet_46_5D2:
    moveq #-91,%d0
    jbsr rsrc_enet_46_608
    jbmi rsrc_enet_46_608_4C
    subqb #1,%a2@(0xdc,%d2:w:8)
    jbne rsrc_enet_46_608_4A
    subaw #14,%sp
    clrl %sp@(10)
    movel %d3,%sp@(6)
    movew %d1,%sp@(4)
    jbsr rsrc_enet_46_B8C
    movel %a0,%sp@
    jbsr rsrc_enet_46_B0E
    jbsr rsrc_enet_46_1410
    lea %sp@(14),%sp
    jbsr rsrc_enet_46_B4A
    jbra rsrc_enet_46_608_4A

/* subroutine (10 instructions) (mechanical summary) */
rsrc_enet_46_608:
    moveq #7,%d2
rsrc_enet_46_608_2:     /* loop: tst */
    tstb %a2@(0xdc,%d2:w:8)
    jbeq rsrc_enet_46_608_1A
    cmpw %a2@(0xd6,%d2:w:8),%d1
    jbne rsrc_enet_46_608_1A
    cmpl %a2@(0xd8,%d2:w:8),%d3
    jbeq rsrc_enet_46_608_1E
rsrc_enet_46_608_1A:    /* count down */
    dbf %d2,rsrc_enet_46_608_2
rsrc_enet_46_608_1E:    /* test %d2 */
    tstw %d2
    rts

/* subroutine (12 instructions): calls rsrc_enet_46_65C (mechanical summary) */
rsrc_enet_46_608_22:
    andl %a2@(358),%d3
    moveq #-94,%d0
    jbsr rsrc_enet_46_65C
    jbpl rsrc_enet_46_608_4C
    moveq #15,%d2
rsrc_enet_46_608_2E:    /* loop: tst */
    tstb %a2@(0x26,%d2:w)
    dbeq %d2,rsrc_enet_46_608_2E
    jbne rsrc_enet_46_608_4C
    movel %d3,%a2@(0x56,%d2:w:4)
    clrl %a2@(0x96,%d2:w:4)
    movew %d1,%a2@(0x36,%d2:w:2)
    st %a2@(0x26,%d2:w)

/* subroutine (4 instructions): low memory JIODone (mechanical summary) */
rsrc_enet_46_608_4A:
    clrw %d0
rsrc_enet_46_608_4C:    /* loop: movea */
    moveal %a2@,%a1
    movel JIODone,%sp@-
    rts

/* subroutine (8 instructions) (mechanical summary) */
rsrc_enet_46_65C:
    moveq #15,%d2
rsrc_enet_46_65C_2:     /* loop: tst */
    tstb %a2@(0x26,%d2:w)
    jbeq rsrc_enet_46_65C_E
    cmpw %a2@(0x36,%d2:w:2),%d1
    jbeq rsrc_enet_46_65C_12
rsrc_enet_46_65C_E:     /* count down */
    dbf %d2,rsrc_enet_46_65C_2
rsrc_enet_46_65C_12:    /* test %d2 */
    tstw %d2
    rts

/* subroutine (8 instructions): calls rsrc_enet_46_65C, rsrc_enet_46_686 (mechanical summary) */
rsrc_enet_46_65C_16:
    moveq #-94,%d0
    jbsr rsrc_enet_46_65C
    jbmi rsrc_enet_46_608_4C
    clrb %a2@(0x26,%d2:w)
    tstl %a2@(0x56,%d2:w:4)
    jbne rsrc_enet_46_65C_28
    jbsr rsrc_enet_46_686
rsrc_enet_46_65C_28:    /* continue at rsrc_enet_46_608_4A */
    jbra rsrc_enet_46_608_4A

/* subroutine (8 instructions): calls rsrc_enet_46_8BA (mechanical summary) */
rsrc_enet_46_686:
    movel %a2@(0x96,%d2:w:4),%d1
    jbeq rsrc_enet_46_686_1A
    moveal %d1,%a0
    movel %a0@,%a2@(0x96,%d2:w:4)
    movew #-1105,%d0
    jbsr rsrc_enet_46_8BA
    jbra rsrc_enet_46_686
rsrc_enet_46_686_1A:    /* return */
    rts

/* subroutine (72 instructions): calls rsrc_enet_46_B8C, rsrc_enet_46_B0E, rsrc_enet_46_12F2, rsrc_enet_46_B4A; low memory JIODone (mechanical summary) */
caseD_408d61a2:
    movew %sr,%sp@-
    movew #9216,%sr
    movel %a2@(370),%d2
    jbne caseD_408d61a2_16
    st %a2@(374)
    movew %sp@+,%sr
    moveq #0,%d0
    rts
caseD_408d61a2_16:      /* clear %a2@(374) */
    clrb %a2@(374)
    moveal %d2,%a1
    movel %a1@,%a2@(370)
    movew %sp@+,%sr
    movel %a1,%sp@-
    moveal %d3,%a0
    cmpiw #14,%a0@
    jbcs caseD_408d61a2_74
    moveal %a0@(2),%a0
    movel %a2@(4),%a0@(6)
    movew %a2@(8),%a0@(10)
    movel %a4,%sp@-
    lea %a1@(1518),%a3
    moveq #-14,%d2
    clrw %a3@
    moveal %d3,%a4
caseD_408d61a2_48:      /* loop: moveq */
    moveq #0,%d0
    movew %a4@+,%d0
    jbeq caseD_408d61a2_6E
    jbmi caseD_408d61a2_72
    addw %d0,%d2
    cmpw %a2@(22),%d2
    jbhi caseD_408d61a2_72
    addw %d0,%a3@
    moveal %a4@+,%a0
    moveml %d0/%d2/%a1,%sp@-
    jsr %a2@(0x16a,%za0)@(0)	| 408D6202
    moveml %sp@+,%d0/%d2/%a1
    addal %d0,%a1
    jbra caseD_408d61a2_48
caseD_408d61a2_6E:      /* set %a4 */
    moveal %sp@+,%a4
    jbra caseD_408d61a2_8C
caseD_408d61a2_72:      /* set %a4 */
    moveal %sp@+,%a4
caseD_408d61a2_74:      /* set %a3 */
    moveal %sp@+,%a3
    movew %sr,%sp@-
    movew #9216,%sr
    movel %a2@(370),%a3@
    movel %a3,%a2@(370)
    movew %sp@+,%sr
    moveq #-92,%d0
    jbra rsrc_enet_46_608_4C
caseD_408d61a2_8C:      /* set %sp@- */
    movel %sp@,%sp@-
    addil #1518,%sp@
    jbsr rsrc_enet_46_B8C
    movel %a0,%sp@-
    jbsr rsrc_enet_46_B0E
    jbsr rsrc_enet_46_12F2
    addqw #8,%sp
    jbsr rsrc_enet_46_B4A
    jbeq caseD_408d61a2_CC
    moveal %sp@+,%a3
    movew %sr,%sp@-
    movew #9216,%sr
    movel %a2@(370),%a3@
    movel %a3,%a2@(370)
    movew %sp@+,%sr
caseD_408d61a2_BC:      /* set bit 0 of %a2@(342) */
    bset #0,%a2@(342)
    movew #1,%a2@(354)
    moveq #0,%d0
    rts
caseD_408d61a2_CC:      /* add 4 to %sp */
    addqw #4,%sp
    moveq #0,%d0
    moveal %a2@,%a1
    moveal JIODone,%a0
    jmp %a0@

/* subroutine (35 instructions): traps DeferUserFn; calls rsrc_enet_46_7F2, caseD_408d61a2 (mechanical summary) */
rsrc_enet_46_77A:
    moveal %pc@(rsrc_enet_46_BA4),%a0	| 408D627A
    moveal %a0@,%a1	| 408D627E
    btst #5,%a1@(20)	| 408D6280
    jbeq rsrc_enet_46_7A2	| 408D6286
    moveal %sp@(4),%a1	| 408D6288
    jbsr rsrc_enet_46_7F2	| 408D628C
    lea %pc@(rsrc_enet_46_796),%a0	| 408D628E
    _DeferUserFn	| 408D6292
    rts	| 408D6294
rsrc_enet_46_796:       /* (data) */
    .byte   0x22, 0x48, 0x20, 0x7A, 0x04, 0x0A, 0x48, 0xE7, 0x10, 0x30, 0x60, 0x0C	| 408D6296
rsrc_enet_46_7A2:       /* set %a1 */
    moveal %sp@(4),%a1	| 408D62A2
    moveml %d3/%a2-%a3,%sp@-	| 408D62A6
    jbsr rsrc_enet_46_7F2	| 408D62AA
    moveal %d0,%a1	| 408D62AC
    moveal %a0@(380),%a2
    movel %a0@(376),%d0
    subqw #1,%d0
rsrc_enet_46_7B8:       /* loop: cmpa */
    cmpal %a2@,%a1
    addqw #8,%a2
    dbeq %d0,rsrc_enet_46_7B8
    jbne rsrc_enet_46_7EC
    moveal %a2@(-4),%a1
    movew %sr,%sp@-
    movew #9216,%sr
    movel %a0@(370),%a1@
    movel %a1,%a0@(370)
    movew %sp@+,%sr
    tstb %a0@(374)
    jbeq rsrc_enet_46_7EC
    moveal %a0,%a2
    moveal %a2@,%a1
    moveal %a1@(8),%a0
    movel %a0@(30),%d3
    jbsr caseD_408d61a2
rsrc_enet_46_7EC:       /* restore registers, return */
    moveml %sp@+,%d3/%a2-%a3
    rts

/* subroutine (5 instructions) (mechanical summary) */
rsrc_enet_46_7F2:
    movew %a1@(10),%d0	| 408D62F2
    swap %d0	| 408D62F6
    movew %a1@(8),%d1	| 408D62F8
    movew %d1,%d0	| 408D62FC
    rts	| 408D62FE

/* subroutine (35 instructions): calls rsrc_enet_46_65C, rsrc_enet_46_ctl (mechanical summary) */
rsrc_enet_46_800:
    moveq #-94,%d0
    jbsr rsrc_enet_46_65C
    jbmi rsrc_enet_46_608_4C
    tstl %a2@(0x56,%d2:w:4)
    jbne rsrc_enet_46_608_4C
    movew #-3101,%d0
    cmpiw #14,%a0@(34)
    jbcs rsrc_enet_46_608_4C
    lea %a2@(0x96,%d2:w:4),%a3
    movew %sr,%sp@-
    movew #9216,%sr
rsrc_enet_46_82C:       /* loop: tst */
    tstl %a3@
    jbeq rsrc_enet_46_834
    moveal %a3@,%a3
    jbra rsrc_enet_46_82C
rsrc_enet_46_834:       /* from here: exg %d0,%a0 */
    exg %d0,%a0
    andl %a2@(358),%d0
    exg %d0,%a0
    movel %a0,%a3@
    bclr #7,%a1@(5)
    movel %a0@,%a1@(8)
    jbne rsrc_enet_46_84E
    clrl %a1@(12)
rsrc_enet_46_84E:       /* clear %a0@ */
    clrl %a0@
    movel %a1@(8),%d0
    jbeq rsrc_enet_46_86A
    bset #7,%a1@(5)
    movew %sp@+,%sr
    moveal %d0,%a0
    moveq #0,%d0
    jbsr rsrc_enet_46_ctl
    moveq #0,%d0
    rts
rsrc_enet_46_86A:       /* set %sr */
    movew %sp@+,%sr
    rts

/* subroutine (26 instructions): calls rsrc_enet_46_65C, rsrc_enet_46_8BA (mechanical summary) */
rsrc_enet_46_86E:
    movew #-1102,%d0
    andl %a2@(358),%d3
    moveal %d3,%a1
    movew %a1@(28),%d1
    jbsr rsrc_enet_46_65C
    jbmi rsrc_enet_46_8B6
    tstl %a2@(0x56,%d2:w:4)
    jbne rsrc_enet_46_8B6
    lea %a2@(0x96,%d2:w:4),%a3
    movew %sr,%sp@-
    movew #9216,%sr
rsrc_enet_46_894:       /* loop: move */
    movel %a3@,%d3
    andl %a2@(358),%d3
    jbeq rsrc_enet_46_8B4
    subl %a1,%d3
    jbeq rsrc_enet_46_8A4
    moveal %a3@,%a3
    jbra rsrc_enet_46_894
rsrc_enet_46_8A4:       /* set %a3@ */
    movel %a1@,%a3@
    movew %sp@+,%sr
    moveal %a1,%a0
    movew #-1105,%d0
    jbsr rsrc_enet_46_8BA
    jbra rsrc_enet_46_608_4A
rsrc_enet_46_8B4:       /* set %sr */
    movew %sp@+,%sr
rsrc_enet_46_8B6:       /* continue at rsrc_enet_46_608_4C */
    jbra rsrc_enet_46_608_4C

/* subroutine (9 instructions) (mechanical summary) */
rsrc_enet_46_8BA:
    movew %d0,%a0@(16)
    moveml %d1-%d3/%a0-%a3,%sp@-
    movel %a0@(12),%d1
    jbeq rsrc_enet_46_8BA_14
    moveal %d1,%a1
    tstw %d0
    jsr %a1@
rsrc_enet_46_8BA_14:    /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a0-%a3
    rts

/* subroutine (22 instructions): traps BlockMove (mechanical summary) */
rsrc_enet_46_8BA_1A:
    andl %a2@(358),%d3
    moveal %a0,%a3
    moveq #0,%d0
    movew %a3@(34),%d0
    cmpiw #18,%d0
    jbls rsrc_enet_46_8BA_2E
    moveq #18,%d0
rsrc_enet_46_8BA_2E:    /* set %a1 */
    moveal %d3,%a1
    lea %a2@(4),%a0
    pea %a1@(0x0,%d0:l)
    movel %d0,%sp@-
    _BlockMove
    movew %a3@(34),%d0
    subl %sp@+,%d0
    moveal %sp@+,%a1
    jbls rsrc_enet_46_608_4A
    cmpil #60,%d0
    jbls rsrc_enet_46_8BA_52
    moveq #60,%d0
rsrc_enet_46_8BA_52:    /* set up and call _BlockMove */
    lea %a2@(278),%a0
    _BlockMove
    jbra rsrc_enet_46_608_4A

/* subroutine (111 instructions): traps BlockMove, DeferUserFn; calls rsrc_enet_46_65C, rsrc_enet_46_CD4, rsrc_enet_46_A7A (mechanical summary) */
rsrc_enet_46_916:
    moveal %pc@(rsrc_enet_46_BA4),%a1	| 408D6416
    moveal %a1@,%a1	| 408D641A
    btst #5,%a1@(20)	| 408D641C
    jbeq rsrc_enet_46_966	| 408D6422
    moveal %pc@(rsrc_enet_46_BA4),%a0	| 408D6424
    lea %a0@(410),%a1	| 408D6428
    moveq #7,%d0	| 408D642C
rsrc_enet_46_92E:       /* loop: lea */
    lea %a1@(20),%a1	| 408D642E
    tstl %a1@	| 408D6432
    dbeq %d0,rsrc_enet_46_92E	| 408D6434
    jbne rsrc_enet_46_966	| 408D6438
    pea %a1@	| 408D643A
    lea %sp@(8),%a0	| 408D643C
    moveq #20,%d0	| 408D6440
    _BlockMove	| 408D6442
    movel %sp@+,%d0	| 408D6444
    lea %pc@(rsrc_enet_46_94E),%a0	| 408D6446
    _DeferUserFn	| 408D644A
    rts	| 408D644C
rsrc_enet_46_94E:       /* (data) */
    .byte   0x2F, 0x08, 0x9E, 0xFC, 0x00, 0x14, 0x22, 0x4F, 0x70, 0x14, 0xA0, 0x2E, 0x61, 0x0A, 0x4F, 0xEF	| 408D644E
    .byte   0x00, 0x14, 0x20, 0x5F, 0x42, 0x90, 0x4E, 0x75	| 408D645E

rsrc_enet_46_966:       /* from here: linkw %fp,#0 */
    linkw %fp,#0
    moveml %d3/%a2-%a5,%sp@-
    moveal %pc@(rsrc_enet_46_BA4),%a2
    movel %fp@(24),%a2@(366)
    moveal %fp@(16),%a0
    movel %fp@(8),%d1
    btst #0,%d1
    jbeq rsrc_enet_46_966_62
    movel %fp@(12),%d1
    subqw #4,%d1
    lea %a2@(24),%a3
    moveq #6,%d0
rsrc_enet_46_966_2C:    /* loop: move */
    movew %a0@+,%a3@+
    dbf %d0,rsrc_enet_46_966_2C
    subiw #14,%d1
    movew %a3@(-2),%d0
    cmpiw #1500,%d0
    jbhi rsrc_enet_46_966_7C
    clrw %d0
    exg %d0,%d1
    jbsr rsrc_enet_46_65C
    exg %d0,%d1
    jbmi rsrc_enet_46_966_62
    movew %a3@(-2),%d0
rsrc_enet_46_966_50:    /* loop: lea */
    lea %pc@(rsrc_enet_46_966_A6),%a4
    lea %pc@(rsrc_enet_46_A2E),%a5
    movel %a2@(0x56,%d2:w:4),%d3
    jbeq rsrc_enet_46_966_60
    moveal %d3,%a5
rsrc_enet_46_966_60:    /* jump through %a5@ */
    jsr %a5@
rsrc_enet_46_966_62:    /* loop: movea */
    moveal %pc@(rsrc_enet_46_BA4),%a2
    movel %a2@(366),%d0
    jbeq rsrc_enet_46_966_74
    movel %d0,%sp@-
    jbsr rsrc_enet_46_CD4
    addqw #4,%sp
rsrc_enet_46_966_74:    /* restore registers, return */
    moveml %sp@+,%d3/%a2-%a5
    unlk %fp
    rts
rsrc_enet_46_966_7C:    /* from here: exg %d0,%d1 */
    exg %d0,%d1
    jbsr rsrc_enet_46_65C
    exg %d0,%d1
    jbmi rsrc_enet_46_966_62
    jbra rsrc_enet_46_966_50
rsrc_enet_46_966_88:    /* save registers */
    moveml %d0-%d2/%a2,%sp@-
    moveal %pc@(rsrc_enet_46_BA4),%a2
    movel %a2@(366),%sp@-
    clrl %a2@(366)
    jbsr rsrc_enet_46_CD4
    addqw #4,%sp
    moveml %sp@+,%d0-%d2/%a2
    tstw %d0
    rts
rsrc_enet_46_966_A6:    /* continue at rsrc_enet_46_966_B8 */
    jbra rsrc_enet_46_966_B8
    .short  0x3003	| 408D650E
    .short  0x9041	| 408D6510
    tstw %d3
    jbeq rsrc_enet_46_966_B2
    jbsr rsrc_enet_46_A7A
rsrc_enet_46_966_B2:    /* set %d3 */
    movew %d0,%d3
    moveq #0,%d0
    jbra rsrc_enet_46_966_88
rsrc_enet_46_966_B8:    /* test %d3,%d1 */
    cmpw %d3,%d1
    jbcs rsrc_enet_46_966_C2
    jbsr rsrc_enet_46_A7A
    tstw %d3
    jbeq rsrc_enet_46_966_C6
rsrc_enet_46_966_C2:    /* result -92 */
    moveq #-92,%d0
    jbra rsrc_enet_46_966_88
rsrc_enet_46_966_C6:    /* return */
    rts

rsrc_enet_46_A2E:       /* set %d0 */
    movel %a2@(0x96,%d2:w:4),%d0
    jbeq rsrc_enet_46_A2E_46
    moveal %d0,%a5
    movel %a5@,%a2@(0x96,%d2:w:4)
    movel %d0,%d2
    moveal %a5@(30),%a3
    movew %a5@(34),%d3
    subiw #14,%d3
    lea %a2@(24),%a5
    movel %a5@+,%a3@+
    movel %a5@+,%a3@+
    movel %a5@+,%a3@+
    movew %a5@+,%a3@+
    jsr %a4@(2)
    moveal %d2,%a0
    movew %a0@(34),%d1
    subw %d3,%d1
    movew %d1,%a0@(36)
    tstw %d3
    jbpl rsrc_enet_46_A2E_42
    movew #-3101,%d0
rsrc_enet_46_A2E_42:    /* continue at rsrc_enet_46_8BA */
    jbra rsrc_enet_46_8BA
rsrc_enet_46_A2E_46:    /* clear %d3 */
    moveq #0,%d3
    jmp %a4@(2)

/* subroutine (22 instructions) (mechanical summary) */
rsrc_enet_46_A7A:
    moveml %d0/%d2/%a1-%a2,%sp@-
    moveal %pc@(rsrc_enet_46_BA4),%a2
    exg %d0,%a3
    andl %a2@(358),%d0
    exg %d0,%a3
    moveal %a3,%a1
    moveq #0,%d0
    movew %d3,%d0
    cmpw %d1,%d3
    jbls rsrc_enet_46_A7A_1C
    movew %d1,%d0
rsrc_enet_46_A7A_1C:    /* from here: subw %d0,%d1 */
    subw %d0,%d1
    subw %d0,%d3
    addaw %d0,%a3
    movel %d1,%sp@-
    movel %a0,%sp@-
    movel %d0,%sp@-
    jsr %a2@(0x16a,%za0)@(0)	| 408D65A2
    moveal %sp@+,%a0
    addal %sp@+,%a0
    movel %sp@+,%d1
    moveml %sp@+,%d0/%d2/%a1-%a2
    rts

/* subroutine (29 instructions): traps DisposPtr, SIntRemove, VRemove; calls rsrc_enet_46_B8C, rsrc_enet_46_B0E, rsrc_enet_46_12B6, rsrc_enet_46_B4A, rsrc_enet_46_686 (mechanical summary) */
rsrc_enet_46_close:
    moveal %pc@(rsrc_enet_46_BA4),%a2
    jbsr rsrc_enet_46_B8C
    movel %a0,%sp@-
    jbsr rsrc_enet_46_B0E
    jbsr rsrc_enet_46_12B6
    addqw #4,%sp
    jbsr rsrc_enet_46_B4A
    moveal %a2@(338),%a0
    _DisposPtr
    moveq #15,%d2
rsrc_enet_46_close_1E:  /* loop: tst */
    tstb %a2@(0x26,%d2:w)
    jbeq rsrc_enet_46_close_2E
    tstl %a2@(0x56,%d2:w:4)
    jbne rsrc_enet_46_close_2E
    jbsr rsrc_enet_46_686
rsrc_enet_46_close_2E:  /* count down */
    dbf %d2,rsrc_enet_46_close_1E
    lea %pc@(rsrc_enet_46_BA8),%a0
    moveq #0,%d0
    moveb %a2@(418),%d0
    _SIntRemove
    lea %a2@(344),%a0
    tstl %a0@(6)
    jbeq rsrc_enet_46_close_4A
    _VRemove
rsrc_enet_46_close_4A:  /* set up and call _DisposPtr */
    moveal %pc@(rsrc_enet_46_BA4),%a0
    _DisposPtr
    lea %pc@(rsrc_enet_46_BA4),%a2
    clrl %a2@
    moveq #0,%d0

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_prime:
    rts

/* subroutine (16 instructions) (mechanical summary) */
rsrc_enet_46_B0E:
    moveal %pc@(rsrc_enet_46_BA4),%a0
    tstb %a0@(419)
    jbne rsrc_enet_46_B0E_3A
    btst #5,%a0@(0,%za0)@(0x14)	| 408D6618
    jbne rsrc_enet_46_B0E_3A
    movew %sr,%sp@-
    movew #9216,%sr
    addql #1,%a0@(390)
    tstl %a0@(386)
    jbne rsrc_enet_46_B0E_38
    movec %cacr,%d0
    movel %d0,%a0@(386)
    bset #11,%d0
    bclr #8,%d0
    movec %d0,%cacr
rsrc_enet_46_B0E_38:    /* set %sr */
    movew %sp@+,%sr
rsrc_enet_46_B0E_3A:    /* return */
    rts

/* subroutine (17 instructions) (mechanical summary) */
rsrc_enet_46_B4A:
    moveml %d0/%a0,%sp@-
    movew %ccr,%sp@-
    moveal %pc@(rsrc_enet_46_BA4),%a0
    tstb %a0@(419)
    jbne rsrc_enet_46_B4A_34
    btst #5,%a0@(0,%za0)@(0x14)	| 408D665A
    jbne rsrc_enet_46_B4A_34
    movew %sr,%sp@-
    movew #9216,%sr
    subql #1,%a0@(390)
    jbne rsrc_enet_46_B4A_32
    movel %a0@(386),%d0
    clrl %a0@(386)
    movec %d0,%cacr
rsrc_enet_46_B4A_32:    /* set %sr */
    movew %sp@+,%sr
rsrc_enet_46_B4A_34:    /* set %ccr */
    movew %sp@+,%ccr
    moveml %sp@+,%d0/%a0
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_enet_46_B4A_3C:
    moveal %a2@(402),%a0
    rts

/* subroutine (6 instructions) (mechanical summary) */
rsrc_enet_46_B8C:
    lea %pc@(rsrc_enet_46_BA4:w,%za0)@(0x18a),%a0	| 408D668C
    tstb MMU32Bit
    jbeq rsrc_enet_46_B8C_14
    moveal %a0@(4),%a0
    rts
rsrc_enet_46_B8C_14:    /* set %a0 */
    moveal %a0@,%a0
    rts
rsrc_enet_46_BA4:       /* (data) */
    .long   0x00000000	| 408D66A4
rsrc_enet_46_BA8:       /* (data) */
    .long   0x00000000, 0x00000000	| 408D66A8
    .long   0x00000000, 0x00000000	| 408D66B0
rsrc_enet_46_BB8:       /* (data) */
    .long   0x00000000	| 408D66B8
rsrc_enet_46_BBC:       /* (data) */
    .long   0x00000000	| 408D66BC
rsrc_enet_46_BC0:       /* (data) */
    .long   0x00000000	| 408D66C0
rsrc_enet_46_BC4:       /* (data) */
    .long   0x00000000	| 408D66C4
rsrc_enet_46_BC8:       /* (data) */
    .long   0x00000000	| 408D66C8
rsrc_enet_46_BCC:       /* (data) */
    .long   0x00000000	| 408D66CC
rsrc_enet_46_BD0:       /* (data) */
    .long   0x00000000	| 408D66D0
rsrc_enet_46_BD4:       /* (data) */
    .long   0x00000000	| 408D66D4
rsrc_enet_46_BD8:       /* (data) */
    .long   0x00000000	| 408D66D8
rsrc_enet_46_BDC:       /* (data) */
    .long   0x00000000	| 408D66DC
rsrc_enet_46_BE0:       /* (data) */
    .long   0x00000000	| 408D66E0
rsrc_enet_46_BE4:       /* (data) */
    .long   0x00000000	| 408D66E4
rsrc_enet_46_BE8:       /* (data) */
    .long   0x00000000	| 408D66E8
rsrc_enet_46_BEC:       /* (data) */
    .long   0x00000000	| 408D66EC
rsrc_enet_46_BF0:       /* (data) */
    .long   0x00000000	| 408D66F0
rsrc_enet_46_BF4:       /* (data) */
    .long   0x00000000	| 408D66F4
rsrc_enet_46_BF8:       /* (data) */
    .long   0x00000000	| 408D66F8
rsrc_enet_46_BFC:       /* (data) */
    .long   0x00000000	| 408D66FC
rsrc_enet_46_C00:       /* (data) */
    .long   0x00000000	| 408D6700
rsrc_enet_46_C04:       /* (data) */
    .long   0x00000000	| 408D6704
rsrc_enet_46_C08:       /* (data) */
    .long   0x00000000	| 408D6708
rsrc_enet_46_C0C:       /* (data) */
    .long   0x00000000	| 408D670C
rsrc_enet_46_C10:       /* (data) */
    .long   0x00000000	| 408D6710
rsrc_enet_46_C14:       /* (data) */
    .long   0x00000000	| 408D6714
rsrc_enet_46_C18:       /* (data) */
    .long   0x00000000	| 408D6718
rsrc_enet_46_C1C:       /* (data) */
    .long   0x00000000	| 408D671C
rsrc_enet_46_C20:       /* (data) */
    .long   0x00000000	| 408D6720
rsrc_enet_46_C24:       /* (data) */
    .long   0x00000000, 0x00000000	| 408D6724

/* subroutine (5 instructions) (mechanical summary) */
rsrc_enet_46_C2C:
    movew #-3968,%a2@(164)
    movew #762,%a2@(168)
    movel #128,%d0
    movew %d0,%a2@(20)
    rts

/* subroutine (15 instructions) (mechanical summary) */
rsrc_enet_46_C44:
    moveq #0,%d0
    movew %d0,%a2@
rsrc_enet_46_C44_4:     /* loop: move */
    movew %a2@,%d0
    btst #7,%d0
    jbne rsrc_enet_46_C44_4
    movew #-3968,%a2@(164)
    movew #762,%a2@(168)
    movel #128,%d0
    movew %d0,%a2@(20)
    moveq #40,%d0
    movew %d0,%a2@
rsrc_enet_46_C44_26:    /* loop: move */
    movew %a2@,%d0
    btst #2,%d0
    jbne rsrc_enet_46_C44_26
    rts

/* subroutine (11 instructions) (mechanical summary) */
rsrc_enet_46_C74:
    moveq #4,%d0
    movew %d0,%a2@
rsrc_enet_46_C74_4:     /* loop: move */
    movew %a2@,%d0
    btst #3,%d0
    jbne rsrc_enet_46_C74_4
rsrc_enet_46_C74_C:     /* loop: move */
    movew %a2@,%d0
    eoriw #36,%d0
    jbne rsrc_enet_46_C74_C
    bset #7,%d0
    movew %d0,%a2@
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_enet_46_C90:
    subl %d1,%d1
    bset %d0,%d1
    movew %d1,%a2@
rsrc_enet_46_C90_6:     /* loop: move */
    movew %a2@,%d1
    btst %d0,%d1
    jbne rsrc_enet_46_C90_6
    rts

/* subroutine (20 instructions) (mechanical summary) */
rsrc_enet_46_C9E:
    movel %a2,%sp@-
    subl %d0,%d0
    movew %d0,%a1@
    moveq #1,%d0
    movew %d0,%a1@(10)
    moveq #-1,%d0
    movew %d0,%a1@(12)
    lea %pc@(rsrc_enet_46_C10),%a0
    moveal %a0@,%a2
    movel %a1,%a0@
    movel %a1,%d0
    subl %pc@(rsrc_enet_46_BEC),%d0
    addl %pc@(rsrc_enet_46_BF0),%d0
    movew %d0,%a2@(10)
    lea %pc@(rsrc_enet_46_C0C),%a0
    tstl %a0@
    jbne rsrc_enet_46_C9E_32
    movel %a1,%a0@
rsrc_enet_46_C9E_32:    /* set %a2 */
    moveal %sp@+,%a2
    rts

/* subroutine (25 instructions): calls rsrc_enet_46_D12 (mechanical summary) */
rsrc_enet_46_CD4:
    moveal %pc@(rsrc_enet_46_C18),%a0
    jsr %a0@
    moveal %sp@(4),%a1
    movel %a2,%sp@-
    movel %d0,%sp@-
    st %a1@(4)
    lea %pc@(rsrc_enet_46_C24),%a2
    cmpal %a2@,%a1
    jbne rsrc_enet_46_CD4_32
rsrc_enet_46_CD4_1A:    /* loop: tst */
    tstb %a1@(4)
    jbeq rsrc_enet_46_CD4_2C
    movel %a1@,%a2@
    jbsr rsrc_enet_46_D12
    movel %a2@,%d0
    jbeq rsrc_enet_46_CD4_2C
    moveal %d0,%a1
    jbra rsrc_enet_46_CD4_1A
rsrc_enet_46_CD4_2C:    /* test %a2@+ */
    tstl %a2@+
    jbne rsrc_enet_46_CD4_32
    clrl %a2@
rsrc_enet_46_CD4_32:    /* set %a0 */
    moveal %pc@(rsrc_enet_46_C1C),%a0
    jsr %a0@
    addqw #4,%sp
    moveal %sp@+,%a2
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_enet_46_D12:
    movew %a1@(12),%d0
    tstw %d0
    beqw rsrc_enet_46_C9E
    lea %pc@(rsrc_enet_46_C14),%a0
    movel %a0@,%a1@
    movel %a1,%a0@
    rts

/* subroutine (34 instructions): calls rsrc_enet_46_F2A, rsrc_enet_46_E00 (mechanical summary) */
rsrc_enet_46_D26:
    linkw %fp,#0
    moveml %a2-%a3,%sp@-
rsrc_enet_46_D26_8:     /* loop: movea */
    moveal %fp@(8),%a2
    movew %a2@(20),%d0
    movew %d0,%d1
    movew #1024,%d2
    andw %d2,%d0
    jbeq rsrc_enet_46_D26_24
    movew %d2,%a2@(20)
    jbsr rsrc_enet_46_F2A
    jbra rsrc_enet_46_D26_8
rsrc_enet_46_D26_24:    /* set %d2 */
    movew #512,%d2
    andw %d2,%d1
    jbeq rsrc_enet_46_D26_36
    movew %d2,%a2@(20)
    jbsr rsrc_enet_46_E00
    jbra rsrc_enet_46_D26_8
rsrc_enet_46_D26_36:    /* set %d0 */
    movew %a2@(20),%d0
    andiw #18097,%d0
    jbeq rsrc_enet_46_D26_5E
    moveq #15,%d1
rsrc_enet_46_D26_42:    /* loop: btst */
    btst %d1,%d0
    dbne %d1,rsrc_enet_46_D26_42
    subl %d2,%d2
    bset %d1,%d2
    addw %d1,%d1
    lea %pc@(rsrc_enet_46_D8C),%a0
    addaw %a0@(0x0,%d1:w),%a0
    movew %d2,%a2@(20)
    jsr %a0@
    jbra rsrc_enet_46_D26_8
rsrc_enet_46_D26_5E:    /* restore registers, return */
    moveml %sp@+,%a2-%a3
    unlk %fp
    rts
rsrc_enet_46_D8C:       /* (data) */
    .short  rsrc_enet_46_DAC-rsrc_enet_46_D8C	| 408D688C
    .short  rsrc_enet_46_DB6-rsrc_enet_46_D8C	| 408D688E
    .short  rsrc_enet_46_DB8-rsrc_enet_46_D8C	| 408D6890
    .short  rsrc_enet_46_DBA-rsrc_enet_46_D8C	| 408D6892
    .short  rsrc_enet_46_DBC-rsrc_enet_46_D8C	| 408D6894
    .short  rsrc_enet_46_DBE-rsrc_enet_46_D8C	| 408D6896
    .short  rsrc_enet_46_DC0-rsrc_enet_46_D8C	| 408D6898
    .short  rsrc_enet_46_DC2-rsrc_enet_46_D8C	| 408D689A
    .short  rsrc_enet_46_DFE-rsrc_enet_46_D8C	| 408D689C
    .short  rsrc_enet_46_E00-rsrc_enet_46_D8C	| 408D689E
    .short  rsrc_enet_46_F2A-rsrc_enet_46_D8C	| 408D68A0
    .short  rsrc_enet_46_1034-rsrc_enet_46_D8C	| 408D68A2
    .short  rsrc_enet_46_1036-rsrc_enet_46_D8C	| 408D68A4
    .short  rsrc_enet_46_1038-rsrc_enet_46_D8C	| 408D68A6
    .short  rsrc_enet_46_103A-rsrc_enet_46_D8C	| 408D68A8
    .short  rsrc_enet_46_103A-rsrc_enet_46_D8C	| 408D68AA

/* subroutine (3 instructions) (mechanical summary) */
rsrc_enet_46_DAC:
    moveal %pc@(rsrc_enet_46_C20),%a0	| 408D68AC
    addql #1,%a0@(56)	| 408D68B0
    rts	| 408D68B4

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_DB6:
    rts	| 408D68B6

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_DB8:
    rts	| 408D68B8

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_DBA:
    rts	| 408D68BA

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_DBC:
    jbra rsrc_enet_46_DAC	| 408D68BC

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_DBE:
    jbra rsrc_enet_46_DAC	| 408D68BE

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_DC0:
    rts	| 408D68C0

/* subroutine (17 instructions): calls rsrc_enet_46_C44 (mechanical summary) */
rsrc_enet_46_DC2:
    movew %a2@(160),%d0	| 408D68C2
    cmpiw #3,%d0
    jbhi rsrc_enet_46_DFC
    movel %pc@(rsrc_enet_46_C0C),%d0
    jbeq rsrc_enet_46_C2C
    movew %a2@(56),%d0
    btst #0,%d0
    jbeq rsrc_enet_46_C2C
    movew %a2@(20),%d0
    btst #10,%d0
    jbne rsrc_enet_46_C2C
    movew %a2@,%sp@-
    movel #128,%d0
    movew %d0,%a2@
    jbsr rsrc_enet_46_C44
    movew %sp@+,%a2@
rsrc_enet_46_DFC:       /* return */
    rts

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_DFE:
    rts	| 408D68FE

/* subroutine (100 instructions) (mechanical summary) */
rsrc_enet_46_E00:
    lea %pc@(rsrc_enet_46_C04),%a0
    movew %a2@(20),%d0
    andiw #256,%d0
    jbeq rsrc_enet_46_E00_2C
    movew %d0,%a2@(20)
    addql #1,%a0@
    cmpil #4,%a0@
    jbcs rsrc_enet_46_E00_2C
    movew %a2@(28),%d0
    btst #0,%d0
    jbne rsrc_enet_46_E00_2C
    moveq #2,%d0
    movew %d0,%a2@
    rts
rsrc_enet_46_E00_2C:    /* clear %a0@ */
    clrl %a0@
    moveal %pc@(rsrc_enet_46_C18),%a1
    jsr %a1@
    movel %d0,%sp@-
    lea %pc@(rsrc_enet_46_BBC),%a0
    moveal %a0@,%a3
    lea %pc@(rsrc_enet_46_BC8),%a1
    movel %a1@,%a0@
    jbeq rsrc_enet_46_E00_58
    clrl %a1@
    movel %a0@,%d0
    subl %pc@(rsrc_enet_46_BC0),%d0
    addl %pc@(rsrc_enet_46_BC4),%d0
    movew %d0,%a2@(28)
    moveq #2,%d0
    movew %d0,%a2@
rsrc_enet_46_E00_58:    /* set %a0 */
    moveal %pc@(rsrc_enet_46_C1C),%a0
    jsr %a0@
rsrc_enet_46_E00_5E:    /* loop: move */
    movel %pc@(rsrc_enet_46_BFC),%sp@-
    moveml %a3,%sp@-
    moveal %pc@(rsrc_enet_46_C00),%a0
    jsr %a0@
    addqw #8,%sp
    movew %a3@,%d0
    andiw #-2048,%d0
    moveal %pc@(rsrc_enet_46_C20),%a0
    cmpiw #2048,%d0
    jbcs rsrc_enet_46_E00_8E
    jbhi rsrc_enet_46_E00_86
    addql #1,%a0@(4)
    jbra rsrc_enet_46_E00_8A
rsrc_enet_46_E00_86:    /* add 1 to %a0@(8) */
    addql #1,%a0@(8)
rsrc_enet_46_E00_8A:    /* add 1 to %a0@(12) */
    addql #1,%a0@(12)
rsrc_enet_46_E00_8E:    /* set %d1 */
    movew %a3@,%d1
    cmpiw #1,%d1
    jbne rsrc_enet_46_E00_9A
    addql #1,%a0@
    jbra rsrc_enet_46_E00_DA
rsrc_enet_46_E00_9A:    /* test bit 0 of %d1 */
    btst #0,%d1
    jbeq rsrc_enet_46_E00_AC
    addql #1,%a0@
    btst #9,%d1
    jbeq rsrc_enet_46_E00_AC
    addql #1,%a0@(16)
rsrc_enet_46_E00_AC:    /* test bit 5 of %d1 */
    btst #5,%d1
    jbeq rsrc_enet_46_E00_B6
    addql #1,%a0@(20)
rsrc_enet_46_E00_B6:    /* test bit 6 of %d1 */
    btst #6,%d1
    jbeq rsrc_enet_46_E00_C0
    addql #1,%a0@(24)
rsrc_enet_46_E00_C0:    /* test bit 10 of %d1 */
    btst #10,%d1
    jbeq rsrc_enet_46_E00_CA
    addql #1,%a0@(28)
rsrc_enet_46_E00_CA:    /* test bit 2 of %d1 */
    btst #2,%d1
    jbne rsrc_enet_46_E00_D6
    btst #1,%d1
    jbeq rsrc_enet_46_E00_DA
rsrc_enet_46_E00_D6:    /* add 1 to %a0@(32) */
    addql #1,%a0@(32)
rsrc_enet_46_E00_DA:    /* set %a1 */
    moveal %pc@(rsrc_enet_46_C18),%a1
    jsr %a1@
    movew %a3@(6),%d0
    addw %d0,%d0
    movew %d0,%sp@-
    addw %d0,%d0
    addw %sp@+,%d0
    lea %pc@(rsrc_enet_46_BCC),%a0
    movel %a0@,%a3@
    movel %a3,%a0@
    lea %a3@(8),%a3
    lea %a3@(0x0,%d0:w),%a3
    movew %a3@,%d0
    btst #0,%d0
    jbne rsrc_enet_46_E00_120
    movew %a2@(24),%d1
    swap %d1
    movew %d0,%d1
    subl %pc@(rsrc_enet_46_BC4),%d1
    addl %pc@(rsrc_enet_46_BC0),%d1
    moveal %d1,%a3
    moveal %pc@(rsrc_enet_46_C1C),%a1
    jsr %a1@
    jbra rsrc_enet_46_E00_5E
rsrc_enet_46_E00_120:   /* set %a1 */
    moveal %pc@(rsrc_enet_46_C1C),%a1
    jsr %a1@
    addqw #4,%sp
    rts

/* subroutine (88 instructions): calls rsrc_enet_46_C9E (mechanical summary) */
rsrc_enet_46_F2A:
    movel %pc@(rsrc_enet_46_C14),%d0
    jbeq rsrc_enet_46_F2A_26
    lea %pc@(rsrc_enet_46_C14),%a3
    moveal %d0,%a1
rsrc_enet_46_F2A_C:     /* loop: move */
    movel %a1@,%d1
    movew %a1@(12),%d0
    tstw %d0
    jbmi rsrc_enet_46_F2A_1E
    jbsr rsrc_enet_46_C9E
    movel %d1,%a3@
    moveal %a3,%a1
rsrc_enet_46_F2A_1E:    /* set %a3 */
    moveal %a1,%a3
    moveal %d1,%a1
    tstl %d1
    jbne rsrc_enet_46_F2A_C
rsrc_enet_46_F2A_26:    /* loop: move */
    movel %pc@(rsrc_enet_46_C0C),%d0
    jbeq rsrc_enet_46_F2A_F2
    moveal %d0,%a3
    movew %a3@,%d0
    tstw %d0
    jbeq rsrc_enet_46_F2A_F2
    movel %a3,%sp@-
    movel %pc@(rsrc_enet_46_BF4),%sp@-
    movew %a3@(6),%d0
    swap %d0
    movew %a3@(4),%d1
    movew %d1,%d0
    subl %pc@(rsrc_enet_46_BE4),%d0
    addl %pc@(rsrc_enet_46_BE0),%d0
    movel %d0,%sp@-
    subl %d0,%d0
    movew %a3@(2),%d0
    movel %d0,%sp@-
    subl %d0,%d0
    movew %a3@,%d0
    movel %d0,%sp@-
    subl %d1,%d1
    movew %a3@(10),%d2
    btst #0,%d2
    jbne rsrc_enet_46_F2A_7E
    movew %a2@(52),%d1
    swap %d1
    movew %d2,%d1
    subl %pc@(rsrc_enet_46_BF0),%d1
    addl %pc@(rsrc_enet_46_BEC),%d1
rsrc_enet_46_F2A_7E:    /* address %pc@(rsrc_enet_46_C24) */
    lea %pc@(rsrc_enet_46_C24),%a1
    clrl %a3@
    clrb %a3@(4)
    tstl %a1@+
    jbne rsrc_enet_46_F2A_92
    movel %a3,%a1@
    movel %a3,%a1@-
    jbra rsrc_enet_46_F2A_98
rsrc_enet_46_F2A_92:    /* set %a0 */
    moveal %a1@,%a0
    movel %a3,%a0@
    movel %a3,%a1@
rsrc_enet_46_F2A_98:    /* set %a3 */
    moveal %d1,%a3
    lea %pc@(rsrc_enet_46_C0C),%a0
    movel %a3,%a0@
    moveal %pc@(rsrc_enet_46_BF8),%a0
    jsr %a0@
    movel %sp@+,%d1
    lea %sp@(16),%sp
    moveal %pc@(rsrc_enet_46_C20),%a0
    movew #1,%d0
    andw %d1,%d0
    jbeq rsrc_enet_46_F2A_D8
    addql #1,%a0@(36)
    movew #256,%d0
    andw %d1,%d0
    jbeq rsrc_enet_46_F2A_C8
    addql #1,%a0@(40)
rsrc_enet_46_F2A_C8:    /* from here: andiw #128,%d1 */
    andiw #128,%d1
    jbeq rsrc_enet_46_F2A_26
    addql #1,%a0@(44)
    jbra rsrc_enet_46_F2A_26
rsrc_enet_46_F2A_D8:    /* test bit 3 of %d1 */
    btst #3,%d1
    jbeq rsrc_enet_46_F2A_E2
    addql #1,%a0@(48)
rsrc_enet_46_F2A_E2:    /* test bit 2 of %d1 */
    btst #2,%d1
    jbeq rsrc_enet_46_F2A_26
    addql #1,%a0@(52)
    jbra rsrc_enet_46_F2A_26
rsrc_enet_46_F2A_F2:    /* set %a2@(164) */
    movew #-3968,%a2@(164)
    movew #762,%a2@(168)
    movel #128,%d0
    movew %d0,%a2@(20)
    rts

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_1034:
    rts	| 408D6B34

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_1036:
    rts	| 408D6B36

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_1038:
    rts

/* subroutine (1 instructions) (mechanical summary) */
rsrc_enet_46_103A:
    rts

/* subroutine (172 instructions): calls rsrc_enet_46_1294, rsrc_enet_46_C2C, rsrc_enet_46_C90, rsrc_enet_46_C44 (mechanical summary) */
rsrc_enet_46_103C:
    linkw %fp,#0
    movel %a2,%sp@-
    moveq #-1,%d0
    cmpil #4816,%fp@(36)
    jbcs rsrc_enet_46_103C_252
    moveal %fp@(8),%a2
    lea %pc@(rsrc_enet_46_BF8),%a0
    movel %fp@(16),%a0@
    lea %pc@(rsrc_enet_46_BF4),%a0
    movel %fp@(20),%a0@
    lea %pc@(rsrc_enet_46_C00),%a0
    movel %fp@(24),%a0@
    lea %pc@(rsrc_enet_46_BFC),%a0
    movel %fp@(28),%a0@
    lea %pc@(rsrc_enet_46_C18),%a0
    movel %fp@(44),%a0@
    lea %pc@(rsrc_enet_46_C1C),%a0
    movel %fp@(48),%a0@
    lea %pc@(rsrc_enet_46_C20),%a0
    movel %fp@(52),%a0@
    subl %d0,%d0
    movew %d0,%a2@(16)
    bset #7,%d0
    movew %d0,%a2@
    pea %pc@(rsrc_enet_46_D26)
    moveal %fp@(12),%a0
    jsr %a0@
    addqw #4,%sp
    movel %fp@(56),%d0
    movew %d0,%a2@(4)
    subl %d0,%d0
    bset #15,%d0
    movew %a2@(160),%d1
    cmpiw #3,%d1
    jbls rsrc_enet_46_103C_84
    bset #14,%d0
rsrc_enet_46_103C_84:   /* set bit 13 of %d0 */
    bset #13,%d0
    movew %d0,%a2@(8)
    movel %fp@(40),%d0
    muluw #16,%d0
    addil #1748,%d0
    addl %fp@(32),%d0
    subql #1,%d0
    clrw %d0
    movel %fp@(32),%d1
    clrw %d1
    cmpl %d1,%d0
    jbeq rsrc_enet_46_103C_BE
    addil #65536,%d1
    subl %fp@(32),%d1
    addl %d1,%fp@(32)
    subl %d1,%fp@(36)
rsrc_enet_46_103C_BE:   /* set %d0 */
    movel #1728,%d0
    lea %pc@(rsrc_enet_46_BCC),%a1
    movel %fp@(32),%a1@
    lea %pc@(rsrc_enet_46_BBC),%a1
    jbsr rsrc_enet_46_1294
    moveal %fp@(32),%a1
    movel %a1,%d1
    subl %pc@(rsrc_enet_46_BC0),%d1
    addl %pc@(rsrc_enet_46_BC4),%d1
    swap %d1
    movew %d1,%a2@(24)
    addl %d0,%fp@(32)
    subl %d0,%fp@(36)
    moveq #14,%d1
rsrc_enet_46_103C_F2:   /* loop: pea */
    pea %a1@(108)
    movel %sp@,%a1@
    moveal %sp@+,%a1
    dbf %d1,rsrc_enet_46_103C_F2
    moveq #20,%d0
    lea %pc@(rsrc_enet_46_BD0),%a1
    movel %fp@(32),%a1@
    jbsr rsrc_enet_46_1294
    movel %fp@(32),%d1
    subl %pc@(rsrc_enet_46_BD4),%d1
    addl %pc@(rsrc_enet_46_BD8),%d1
    swap %d1
    movew %d1,%a2@(80)
    addl %d0,%fp@(32)
    subl %d0,%fp@(36)
    movel %fp@(36),%d0
    divuw #1534,%d0
    extl %d0
    cmpl %fp@(40),%d0
    jbls rsrc_enet_46_103C_13A
    movel %fp@(40),%d0
rsrc_enet_46_103C_13A:  /* address %pc@(rsrc_enet_46_C08) */
    lea %pc@(rsrc_enet_46_C08),%a1
    movel %d0,%a1@
    lea %pc@(rsrc_enet_46_BE8),%a1
    movel %fp@(32),%a1@
    jbsr rsrc_enet_46_1294
    lea %pc@(rsrc_enet_46_C0C),%a1
    movel %fp@(32),%a1@
    movel %pc@(rsrc_enet_46_C08),%d0
    movel %d0,%d1
    muluw #16,%d1
    addl %d1,%fp@(32)
    subl %d1,%fp@(36)
    subql #1,%d0
    moveal %pc@(rsrc_enet_46_BE8),%a0
rsrc_enet_46_103C_16C:  /* loop: tst */
    tstl %d0
    jbne rsrc_enet_46_103C_178
    subl %d1,%d1
    bset #0,%d1
    jbra rsrc_enet_46_103C_186
rsrc_enet_46_103C_178:  /* from here: pea %a0@(16) */
    pea %a0@(16)
    movel %sp@+,%d1
    subl %pc@(rsrc_enet_46_BEC),%d1
    addl %pc@(rsrc_enet_46_BF0),%d1
rsrc_enet_46_103C_186:  /* set %a0@(10) */
    movew %d1,%a0@(10)
    moveq #-1,%d1
    movew %d1,%a0@(12)
    lea %a0@(16),%a0
    dbf %d0,rsrc_enet_46_103C_16C
    pea %a0@(-16)
    lea %pc@(rsrc_enet_46_C10),%a1
    movel %sp@+,%a1@
    movel %pc@(rsrc_enet_46_C08),%d0
    muluw #1518,%d0
    lea %pc@(rsrc_enet_46_BDC),%a1
    movel %fp@(32),%a1@
    jbsr rsrc_enet_46_1294
    addl %d0,%fp@(32)
    subl %d0,%fp@(36)
    moveal %pc@(rsrc_enet_46_BD0),%a0
    lea %a0@(12),%a1
    pea %a1@
    movel %a1,%d0
    subl %pc@(rsrc_enet_46_BD4),%d0
    addl %pc@(rsrc_enet_46_BD8),%d0
    movew %d0,%a2@(92)
    movew %d0,%a2@(84)
    addqw #8,%d0
    movew %d0,%a2@(88)
    subl %d0,%d0
    movew %d0,%a2@(96)
    movel %pc@(rsrc_enet_46_BDC),%d0
    subl %pc@(rsrc_enet_46_BE0),%d0
    addl %pc@(rsrc_enet_46_BE4),%d0
    moveal %sp@+,%a1
    movew %d0,%a1@
    swap %d0
    movew %d0,%a1@(2)
    movel %pc@(rsrc_enet_46_C08),%d1
    muluw #759,%d1
    movew %d1,%a1@(4)
    swap %d1
    movew %d1,%a1@(6)
    moveq #-1,%d0
    movew %d0,%a2@(20)
    jbsr rsrc_enet_46_C2C
    subl %d0,%d0
    movew %d0,%a2@
rsrc_enet_46_103C_21C:  /* loop: move */
    movew %a2@,%d0
    btst #7,%d0
    jbne rsrc_enet_46_103C_21C
    moveq #8,%d0
    jbsr rsrc_enet_46_C90
    movel %pc@(rsrc_enet_46_BE8),%d0
    subl %pc@(rsrc_enet_46_BEC),%d0
    addl %pc@(rsrc_enet_46_BF0),%d0
    movew %d0,%a2@(56)
    swap %d0
    movew %d0,%a2@(52)
    jbsr rsrc_enet_46_C44
    movel #18097,%d0
    movew %d0,%a2@(16)
    movel %fp@(36),%d0
rsrc_enet_46_103C_252:  /* set %a2 */
    moveal %sp@+,%a2
    unlk %fp
    rts

/* subroutine (12 instructions) (mechanical summary) */
rsrc_enet_46_1294:
    movel %d0,%sp@-
    movel %a1,%sp@-
    movel %d0,%sp@-
    movel %fp@(32),%sp@-
    moveal %fp@(60),%a0
    jsr %a0@
    addqw #8,%sp
    moveal %sp@+,%a1
    movel %d0,%a1@(8)
    movel %fp@(32),%a1@(4)
    movel %sp@+,%d0
    rts

/* subroutine (22 instructions): calls rsrc_enet_46_C74 (mechanical summary) */
rsrc_enet_46_12B6:
    linkw %fp,#0
    movel %a2,%sp@-
    moveal %pc@(rsrc_enet_46_C18),%a0
    jsr %a0@
    movel %d0,%sp@-
    moveal %fp@(8),%a2
    jbsr rsrc_enet_46_C74
    subl %d0,%d0
    movew %d0,%a2@(16)
    movew %d0,%a2@(148)
    moveal %pc@(rsrc_enet_46_C1C),%a0
    jsr %a0@
    addqw #4,%sp
    moveal %sp@+,%a2
    unlk %fp
    rts
rsrc_enet_46_12B6_2E:   /* loop: movea */
    moveal %pc@(rsrc_enet_46_C1C),%a0
    movel %d0,%sp@-
    jsr %a0@
    moveq #-1,%d0
    unlk %fp
    rts

/* subroutine (102 instructions) (mechanical summary) */
rsrc_enet_46_12F2:
    linkw %fp,#-4
    moveal %pc@(rsrc_enet_46_C18),%a0
    jsr %a0@
    movel %pc@(rsrc_enet_46_BCC),%d1
    jbeq rsrc_enet_46_12B6_2E
    movel %a2,%fp@(-4)
    movel %d0,%sp@-
    lea %pc@(rsrc_enet_46_BCC),%a0
    moveal %a0@,%a1
    movel %a1@,%a0@
    exg %a1,%a2
    moveal %pc@(rsrc_enet_46_C1C),%a0
    jsr %a0@
    exg %a1,%a2
    moveal %fp@(12),%a2
    subl %d0,%d0
    movew %d0,%a1@(6)
    movew %d0,%a1@(4)
    movew %d0,%a1@
    movew %d0,%a1@(2)
    lea %a1@(8),%a0
rsrc_enet_46_12F2_40:   /* loop: su */
    subl %d0,%d0
    movew %a2@+,%d0
    jbeq rsrc_enet_46_12F2_5E
    addqw #1,%a1@(6)
    addw %d0,%a1@(4)
    movel %d0,%sp@-
    movel %a2@+,%d0
    movew %d0,%a0@+
    swap %d0
    movew %d0,%a0@+
    movel %sp@+,%d0
    movew %d0,%a0@+
    jbra rsrc_enet_46_12F2_40
rsrc_enet_46_12F2_5E:   /* set %d0 */
    movew %a1@(4),%d0
    extl %d0
    subil #60,%d0
    jbcc rsrc_enet_46_12F2_8A
    negl %d0
    addqw #1,%a1@(6)
    addw %d0,%a1@(4)
    movel %pc@(rsrc_enet_46_BDC),%d1
    subl %pc@(rsrc_enet_46_BE0),%d1
    addl %pc@(rsrc_enet_46_BE4),%d1
    movew %d1,%a0@+
    swap %d1
    movew %d1,%a0@+
    movew %d0,%a0@+
rsrc_enet_46_12F2_8A:   /* set %d0 */
    moveq #1,%d0
    movew %d0,%a0@
    exg %a1,%a2
    moveal %pc@(rsrc_enet_46_C18),%a0
    jsr %a0@
    exg %a1,%a2
    moveal %fp@(8),%a2
    movel %pc@(rsrc_enet_46_BC8),%d0
    jbne rsrc_enet_46_12F2_AA
    lea %pc@(rsrc_enet_46_BC8),%a0
    movel %a1,%a0@
    jbra rsrc_enet_46_12F2_E8
rsrc_enet_46_12F2_AA:   /* set %a0 */
    moveal %d0,%a0
    movew %a2@(24),%d1
    swap %d1
rsrc_enet_46_12F2_B2:   /* loop: move */
    movew %a0@(6),%d0
    addw %d0,%d0
    movew %d0,%sp@-
    addw %d0,%d0
    addw %sp@+,%d0
    lea %a0@(8),%a0
    lea %a0@(0x0,%d0:w),%a0
    movew %a0@,%d0
    btst #0,%d0
    jbne rsrc_enet_46_12F2_DC
    movew %d0,%d1
    subl %pc@(rsrc_enet_46_BC4),%d1
    addl %pc@(rsrc_enet_46_BC0),%d1
    moveal %d1,%a0
    jbra rsrc_enet_46_12F2_B2
rsrc_enet_46_12F2_DC:   /* set %d0 */
    movel %a1,%d0
    subl %pc@(rsrc_enet_46_BC0),%d0
    addl %pc@(rsrc_enet_46_BC4),%d0
    movew %d0,%a0@
rsrc_enet_46_12F2_E8:   /* address %pc@(rsrc_enet_46_BBC) */
    lea %pc@(rsrc_enet_46_BBC),%a0
    tstl %a0@
    jbne rsrc_enet_46_12F2_10C
    lea %pc@(rsrc_enet_46_BC8),%a1
    movel %a1@,%a0@
    moveq #0,%d0
    movel %d0,%a1@
    movel %a0@,%d0
    subl %pc@(rsrc_enet_46_BC0),%d0
    addl %pc@(rsrc_enet_46_BC4),%d0
    movew %d0,%a2@(28)
    moveq #2,%d0
    movew %d0,%a2@
rsrc_enet_46_12F2_10C:  /* set %a0 */
    moveal %pc@(rsrc_enet_46_C1C),%a0
    jsr %a0@
    addqw #4,%sp
    moveal %fp@(-4),%a2
    unlk %fp
    subl %d0,%d0
    rts

/* subroutine (78 instructions): calls rsrc_enet_46_14F0, rsrc_enet_46_C74, rsrc_enet_46_C44 (mechanical summary) */
rsrc_enet_46_1410:
    linkw %fp,#0
    moveml %d3-%d4/%a2,%sp@-
    moveal %pc@(rsrc_enet_46_C18),%a0
    jsr %a0@
    movel %d0,%sp@-
    moveal %fp@(8),%a2
    movel %fp@(12),%d1
    movew %fp@(16),%d2
    tstl %fp@(18)
    jbeq rsrc_enet_46_1410_68
rsrc_enet_46_1410_22:   /* loop: move */
    movew %a2@,%d0
    eoriw #40,%d0
    jbne rsrc_enet_46_1410_22
    movew %a2@(148),%d0
    moveq #15,%d3
rsrc_enet_46_1410_30:   /* loop: as */
    aslw #1,%d0
    dbcc %d3,rsrc_enet_46_1410_30
    jbcc rsrc_enet_46_1410_40
    movew %d3,%d0
    extl %d0
    jbra rsrc_enet_46_1410_D0
rsrc_enet_46_1410_40:   /* set %a0 */
    moveal %pc@(rsrc_enet_46_BD0),%a0
    rorw #8,%d2
    movew %d2,%a0@(6)
    rorw #8,%d1
    movew %d1,%a0@(4)
    swap %d1
    rorw #8,%d1
    movew %d1,%a0@(2)
    movew %a2@(148),%d0
    bset %d3,%d0
    movew %d0,%a0@(8)
    jbsr rsrc_enet_46_14F0
    movel %d3,%d0
    jbra rsrc_enet_46_1410_D0
rsrc_enet_46_1410_68:   /* call rsrc_enet_46_C74 */
    jbsr rsrc_enet_46_C74
    moveq #15,%d3
    movew %a2@(148),%d0
rsrc_enet_46_1410_72:   /* loop: as */
    aslw #1,%d0
    dbcs %d3,rsrc_enet_46_1410_72
    jbcs rsrc_enet_46_1410_8A
rsrc_enet_46_1410_7A:   /* call rsrc_enet_46_C44 (loop) */
    jbsr rsrc_enet_46_C44
    movew %d3,%d0
    extl %d0
    jbra rsrc_enet_46_1410_D0
rsrc_enet_46_1410_84:   /* loop: subq */
    subqw #1,%d3
    jbmi rsrc_enet_46_1410_7A
    jbra rsrc_enet_46_1410_72
rsrc_enet_46_1410_8A:   /* set %a2@(132) */
    movew %d3,%a2@(132)
    movew %a2@(140),%d4
    rorw #8,%d4
    movew %d4,%sp@-
    movew %a2@(144),%d4
    rorw #8,%d4
    movew %d4,%sp@-
    cmpl %sp@+,%d1
    jbne rsrc_enet_46_1410_84
    movew %a2@(136),%d4
    rorw #8,%d4
    cmpw %d4,%d2
    jbne rsrc_enet_46_1410_84
    moveal %pc@(rsrc_enet_46_BD0),%a0
    subl %d2,%d2
    movew %d2,%a0@(6)
    movew %d2,%a0@(4)
    movew %d2,%a0@(2)
    movew %a2@(148),%d0
    bclr %d3,%d0
    movew %d0,%a0@(8)
    jbsr rsrc_enet_46_C44
    jbsr rsrc_enet_46_14F0
    subl %d0,%d0
rsrc_enet_46_1410_D0:   /* set %a0 */
    moveal %pc@(rsrc_enet_46_C1C),%a0
    jsr %a0@
    addqw #4,%sp
    moveml %sp@+,%d3-%d4/%a2
    unlk %fp
    rts

/* subroutine (9 instructions) (mechanical summary) */
rsrc_enet_46_14F0:
    movew %d3,%a0@
    movel %a0,%d0
    subl %pc@(rsrc_enet_46_BD4),%d0
    addl %pc@(rsrc_enet_46_BD8),%d0
    movew %d0,%a2@(152)
    moveq #1,%d0
    movew %d0,%a2@(156)
    moveq #9,%d0
    jbra rsrc_enet_46_C90

/* subroutine (19 instructions): calls rsrc_enet_46_16F6 (mechanical summary) */
rsrc_enet_46_150C:
    linkw %fp,#0
    movel %a4,%sp@-
    moveal %fp@(8),%a4
    movew #251,%a4@(26)
    movel %fp@(12),%a4@(30)
    subql #2,%sp
    movel %a4,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_enet_46_16F6)
    movew #248,%a4@(26)
    subql #2,%sp
    movel %a4,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_enet_46_16F6)
    moveal %fp@(-4),%a4
    unlk %fp
    rts

/* subroutine (125 instructions): traps BlockMove; calls rsrc_enet_46_16F6, rsrc_enet_46_150C, rsrc_enet_46_1708; low memory Time, Apple, Computer (mechanical summary) */
rsrc_enet_46_1548:
    linkw %fp,#-320
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a3
    lea %fp@(-56),%a4
    lea %pc@(rsrc_enet_46_16D2),%a0
    lea %fp@(-36),%a1
    moveq #7,%d0
rsrc_enet_46_1548_1A:   /* loop: move */
    movel %a0@+,%a1@+
    dbf %d0,rsrc_enet_46_1548_1A
    movew %a0@+,%a1@+
    moveb %a0@,%a1@
    movew %fp@(10),%fp@(-188)
    moveq #0,%d0
    movel %d0,%fp@(-200)
    movew #247,%fp@(-186)
    movew #-32613,%fp@(-184)
    movel %d0,%fp@(-182)
    subql #2,%sp
    pea %fp@(-212)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_enet_46_16F6)
    tstw %sp@+
    jbeq rsrc_enet_46_1548_58
    moveq #0,%d0
    jbra rsrc_enet_46_1548_180
rsrc_enet_46_1548_58:   /* set %fp@(-186) */
    movew #250,%fp@(-186)
    lea %fp@(-320),%a0
    movel %a0,%fp@(-182)
    movew #54,%fp@(-178)
    subql #2,%sp
    pea %fp@(-212)
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_enet_46_16F6)
    tstw %sp@+
    jbeq rsrc_enet_46_1548_9A
    movew #248,%fp@(-186)
    subql #2,%sp
    pea %fp@(-212)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_enet_46_16F6)
    moveq #0,%d0
    addqw #2,%sp
    jbra rsrc_enet_46_1548_180
rsrc_enet_46_1548_9A:   /* address %fp@(-134) */
    lea %fp@(-134),%a0
    lea %fp@(-212),%a1
    moveq #18,%d0
rsrc_enet_46_1548_A4:   /* loop: move */
    movel %a1@+,%a0@+
    dbf %d0,rsrc_enet_46_1548_A4
    movew %a1@+,%a0@+
    movew #54,%a4@
    lea %fp@(-266),%a0
    movel %a0,%a4@(2)
    clrw %a4@(6)
    lea %fp@(-266),%a0
    moveal %a3,%a1
    movel %a1@+,%a0@+
    movew %a1@+,%a0@+
    lea %fp@(-260),%a0
    moveal %a3,%a1
    movel %a1@+,%a0@+
    movew %a1@+,%a0@+
    movew #-32613,%fp@(-254)
    lea %fp@(-36),%a0
    lea %fp@(-252),%a1
    moveq #35,%d0
    _BlockMove
    movel %a4,%fp@(-104)
    movew #249,%fp@(-108)
    subql #2,%sp
    pea %fp@(-134)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_enet_46_16F6)
    tstw %sp@+
    jbeq rsrc_enet_46_1548_110
    pea %fp@(-212)
    pea %fp@(-134)
    jsr %pc@(rsrc_enet_46_150C)
    moveq #0,%d0
    addqw #8,%sp
    jbra rsrc_enet_46_1548_180
rsrc_enet_46_1548_110:  /* address %fp@(-44) */
    lea %fp@(-44),%a0
    movel Time,%a0@
    jbra rsrc_enet_46_1548_142
rsrc_enet_46_1548_11A:  /* loop: lea */
    lea %fp@(-40),%a0
    movel Time,%a0@
    movel %fp@(-40),%d0
    subl %fp@(-44),%d0
    moveq #3,%d1
    cmpl %d0,%d1
    jbge rsrc_enet_46_1548_142
    pea %fp@(-212)
    pea %fp@(-134)
    jsr %pc@(rsrc_enet_46_150C)
    moveq #0,%d0
    addqw #8,%sp
    jbra rsrc_enet_46_1548_180
rsrc_enet_46_1548_142:  /* set %d0 */
    moveq #1,%d0
    cmpw %fp@(-196),%d0
    jbeq rsrc_enet_46_1548_11A
    movew #248,%fp@(-108)
    subql #2,%sp
    pea %fp@(-134)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_enet_46_16F6)
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #1,%d1
    movel %d1,%sp@-
    pea %fp@(-252)
    pea %fp@(-306)
    jsr %pc@(rsrc_enet_46_1708)
    tstb %d0
    lea %sp@(18),%sp
    jbne rsrc_enet_46_1548_17E
    moveq #0,%d0
    jbra rsrc_enet_46_1548_180
rsrc_enet_46_1548_17E:  /* set %d0 */
    moveq #1,%d0
rsrc_enet_46_1548_180:  /* restore registers, return */
    moveml %fp@(-328),%a3-%a4
    unlk %fp
    rts
rsrc_enet_46_16D2:      /* (data) */
    .short  0x2863, 0x2920, 0x3139, 0x3930, 0x2D31	| 408D71D2
    .ascii  "991 Apple Computer, Inc.\000"
    .byte   0x00	| 408D71F5

/* subroutine (8 instructions): traps Control (mechanical summary) */
rsrc_enet_46_16F6:
    moveal %sp@+,%a1
    moveb %sp@+,%d0
    moveal %sp@+,%a0
    jbne rsrc_enet_46_16F6_C
    _Control
    jbra rsrc_enet_46_16F6_E
rsrc_enet_46_16F6_C:    /* (_Control (flags 0x0400)) */
    .short  0xA404	| 408D7202 _Control (flags 0x0400)
rsrc_enet_46_16F6_E:    /* set %sp@ */
    movew %d0,%sp@
    jmp %a1@

/* subroutine (40 instructions): traps CmpString; calls rsrc_enet_46_17A2, rsrc_enet_46_177E (mechanical summary) */
rsrc_enet_46_1708:
    linkw %fp,#0
    moveq #1,%d0
    moveal %fp@(8),%a0
    cmpal %fp@(12),%a0
    jbeq rsrc_enet_46_1708_72
    movel %a0,%sp@-
    jsr %pc@(rsrc_enet_46_17A2)
    addqw #4,%sp
    movel %fp@(12),%sp@-
    jsr %pc@(rsrc_enet_46_17A2)
    addqw #4,%sp
    moveal %fp@(8),%a0
    moveal %fp@(12),%a1
    moveq #0,%d0
    moveb %a0@+,%d0
    swap %d0
    moveb %a1@+,%d0
    tstl %fp@(20)
    jbeq rsrc_enet_46_1708_46
    tstl %fp@(16)
    jbeq rsrc_enet_46_1708_42
    .short  0xA43C	| 408D7246 _CmpString (flags 0x0400)
    jbra rsrc_enet_46_1708_52
rsrc_enet_46_1708_42:   /* _CmpString */
    _CmpString
    jbra rsrc_enet_46_1708_52
rsrc_enet_46_1708_46:   /* test %fp@(16) */
    tstl %fp@(16)
    jbeq rsrc_enet_46_1708_50
    .short  0xA63C	| 408D7254 _CmpString (flags 0x0600)
    jbra rsrc_enet_46_1708_52
rsrc_enet_46_1708_50:   /* (_CmpString (flags 0x0200)) */
    .short  0xA23C	| 408D7258 _CmpString (flags 0x0200)
rsrc_enet_46_1708_52:   /* set %sp@- */
    movew %d0,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(rsrc_enet_46_177E)
    addqw #4,%sp
    movel %fp@(12),%sp@-
    jsr %pc@(rsrc_enet_46_177E)
    addqw #4,%sp
    movew %sp@+,%d0
    eorib #1,%d0
    extw %d0
    extl %d0
rsrc_enet_46_1708_72:   /* return */
    unlk %fp
    rts

/* subroutine (10 instructions) (mechanical summary) */
rsrc_enet_46_177E:
    movel %sp@(4),%d0
    jbeq rsrc_enet_46_177E_18
    moveal %d0,%a0
    clrw %d1
    moveb %a0@,%d1
    jbra rsrc_enet_46_177E_12
rsrc_enet_46_177E_E:    /* loop: move */
    moveb %a0@(1),%a0@+
rsrc_enet_46_177E_12:   /* count down */
    dbf %d1,rsrc_enet_46_177E_E
    clrb %a0@
rsrc_enet_46_177E_18:   /* return */
    rts
    .long   0x86703263, 0x73747200	| 408D7298
    .short  0x0000	| 408D72A0

/* subroutine (15 instructions) (mechanical summary) */
rsrc_enet_46_17A2:
    movel %sp@(4),%d0
    jbeq rsrc_enet_46_17A2_22
    moveal %d0,%a0
    moveal %d0,%a1
    movew #255,%d2
rsrc_enet_46_17A2_E:    /* loop: move */
    moveb %a0@,%d1
    moveb %d0,%a0@+
    moveb %d1,%d0
    dbeq %d2,rsrc_enet_46_17A2_E
    movel %a0,%d1
    movel %a1,%d0
    subl %d0,%d1
    subqb #1,%d1
    moveb %d1,%a1@
rsrc_enet_46_17A2_22:   /* return */
    rts
    .short  0x8663, 0x3270, 0x7374, 0x7200, 0x0000	| 408D72C6
