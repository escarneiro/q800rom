/* ROM resource 'drvr' 9: map entry at 0x408DD380, data at 0x408DD3B0, 14158 bytes

 The AppleTalk driver .MPP ('drvr' 9, ".MPP DRVR v57.0.4", (c) Apple 1984-1992): the
 Datagram Delivery Protocol (DDP sockets), the link access calls and the Name Binding
 Protocol (NBP: register, look up, confirm, remove names), on the link chosen by the LAP
 Manager (LocalTalk, EtherTalk: the 'atlk' and 'ltlk' resources). Installed in place of
 the .MPP stub ('DRVR' 9). Control calls: csCodes 242-249 through MPP_CONTROL_TABLE, 249-264
 through MPP_CONTROL_TABLE2 (names from Inside Macintosh). Comments inferred from the
 code and the documented calls; the inner routines are summarised mechanically.
*/

rsrc_drvr_9_entry:      /* map entry */
    .long   0x38000000, 0x00000000	| 408DD380
    .long   rsrc_ltlk_1_entry-rom_start	| 408DD388
    .long   rsrc_drvr_9-rom_start	| 408DD38C
    .ascii  "drvr"	| 408DD390
    .byte   0x00, 0x09, 0x58, 0x00	| 408DD394
    FILL_408DD398
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x37, 0x5A, 0x00, 0x00, 0x02, 0xCC	| 408DD3A4

/* subroutine (0 instructions) (mechanical summary) */
rsrc_drvr_9:
    .byte   0x7C, 0x00, 0x00, 0x3C, 0x00, 0x00, 0x00, 0x00	| 408DD3B0
rsrc_drvr_9_8:          /* (data) */
    .short  rsrc_drvr_9_open-rsrc_drvr_9	| 408DD3B8
    .short  rsrc_drvr_9_prime-rsrc_drvr_9	| 408DD3BA
    .short  rsrc_drvr_9_ctl-rsrc_drvr_9	| 408DD3BC
    .short  rsrc_drvr_9_status-rsrc_drvr_9	| 408DD3BE
    .short  rsrc_drvr_9_close-rsrc_drvr_9	| 408DD3C0
    .byte   0x04, 0x2E, 0x4D, 0x50, 0x50, 0x20	| 408DD3C2
rsrc_drvr_9_18:         /* (data) */
    .byte   0x39, 0x04, 0x80, 0x00, 0x00, 0x00, 0x08, 0x35, 0x37, 0x2E, 0x30, 0x2E, 0x34, 0x20, 0x20, 0x00	| 408DD3C8
    .byte   0x35, 0x2E, 0x4D, 0x50, 0x50, 0x20, 0x44, 0x52, 0x56, 0x52, 0x20, 0x76, 0x35, 0x37, 0x2E, 0x30	| 408DD3D8
    .byte   0x2E, 0x34, 0x20, 0x20, 0x3B, 0x20, 0xA9, 0x20, 0x41, 0x70, 0x70, 0x6C, 0x65, 0x20, 0x43, 0x6F	| 408DD3E8
    .byte   0x6D, 0x70, 0x75, 0x74, 0x65, 0x72, 0x2C, 0x20, 0x49, 0x6E, 0x63, 0x2E, 0x20, 0x31, 0x39, 0x38	| 408DD3F8
    .byte   0x34, 0x2D, 0x31, 0x39, 0x39, 0x32	| 408DD408

/* subroutine (15 instructions): traps StackSpace (mechanical summary) */
rsrc_drvr_9_5E:
    movew #32767,%a0@(10)	| 408DD40E
    _StackSpace	| 408DD414 408DD414 A-line trap
    tstl %d0	| 408DD416
    jbmi rsrc_drvr_9_72	| 408DD418
    cmpil #512,%d0	| 408DD41A
    jbcc rsrc_drvr_9_7A	| 408DD420
rsrc_drvr_9_72:         /* set %a0@(10) */
    movew #1,%a0@(10)	| 408DD422
rsrc_drvr_9_78:         /* return */
    rts	| 408DD428
rsrc_drvr_9_7A:         /* address %a0@(-658) */
    lea %a0@(-658),%a2	| 408DD42A
    moveb %a2@(718),%d0	| 408DD42E
    clrb %a2@(718)	| 408DD432
    tstb %d0	| 408DD436
    jbeq rsrc_drvr_9_78	| 408DD438
    moveal %a2@(816),%a1	| 408DD43A
    moveal %a1@(8),%a0	| 408DD43E

/* Control: dispatch by csCode through MPP_CONTROL_TABLE / MPP_CONTROL_TABLE2. */
rsrc_drvr_9_ctl:
    moveal %a1@(20),%a2
    movew %a0@(6),%d0
    btst #9,%d0
    jbne rsrc_drvr_9_ctl_4A
    btst #30,%a2@(830)
    jbeq rsrc_drvr_9_ctl_92
    btst #10,%d0
    jbeq rsrc_drvr_9_ctl_92
    moveal %a2@(808),%a2
    cmpaw #0,%a2
    jbeq rsrc_drvr_9_ctl_92
    tstb %a2@(815)
    jbne rsrc_drvr_9_ctl_92
    _StackSpace
    tstl %d0
    jbmi rsrc_drvr_9_ctl_3A
    cmpil #512,%d0
    jbcc rsrc_drvr_9_ctl_92
rsrc_drvr_9_ctl_3A:     /* set %a2 */
    moveal %a1@(20),%a2
    st %a2@(718)
    movew #1,%a2@(668)
    rts
rsrc_drvr_9_ctl_4A:     /* set %sp@- */
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    cmpiw #262,%a0@(26)
    jbne rsrc_drvr_9_ctl_90
    movew #-1021,%d0
    tstl %a1@(8)
    jbne rsrc_drvr_9_ctl_88
    movel %a0,%sp@-
    movel %a1,%sp@-
    lea %a1@(6),%a1
    _Enqueue
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    bset #7,%a1@(5)
    bclr #1,%a0@(6)
    clrl %a0@(12)
    movew %sp@+,%sr
    jbra rsrc_drvr_9_ctl_92
rsrc_drvr_9_ctl_88:     /* set %a0@(16) */
    movew %d0,%a0@(16)
    movew %sp@+,%sr
    rts
rsrc_drvr_9_ctl_90:     /* set %sr */
    movew %sp@+,%sr
rsrc_drvr_9_ctl_92:     /* set %d3 */
    movel AtalkHk1,%d3
    jble rsrc_drvr_9_ctl_9C
    moveal %d3,%a2
    jsr %a2@
rsrc_drvr_9_ctl_9C:     /* set %a2 */
    moveal %a1@(20),%a2
    movew %a0@(26),%d3
    jbmi rsrc_drvr_9_824_48
    cmpiw #2,%d3
    jbeq rsrc_drvr_9_ctl_118
    cmpiw #1,%d3
    jbne rsrc_drvr_9_ctl_B6
    rts
rsrc_drvr_9_ctl_B6:     /* test #65,%d3 */
    cmpiw #65,%d3
    jbne rsrc_drvr_9_ctl_E4
    tstw %a2@(2606)
    jbeq rsrc_drvr_9_ctl_118
    subqw #4,%sp
    movew %a2@(836),%sp@
    movew %a2@(838),%sp@(2)
    moveal %sp,%a1
    movel #1919838053,%sp@-
    movel %a1,%sp@-
    jsr %pc@(rsrc_drvr_9_3306)
    addqw #4,%sp
    clrw %a2@(2606)
    jbra rsrc_drvr_9_ctl_118
rsrc_drvr_9_ctl_E4:     /* set %d0 */
    moveq #-17,%d0
    subiw #242,%d3
    jbcs rsrc_drvr_9_status_3E
    cmpiw #23,%d3
    jbgt rsrc_drvr_9_status_3E
    moveb %a0@(28),%d1
    moveal %a0@(30),%a1
    cmpiw #7,%d3
    jbgt rsrc_drvr_9_898
    lea %pc@(MPP_CONTROL_TABLE),%a3
    addaw %d3,%a3
    addaw %d3,%a3
    moveaw %a3@,%a3
    pea %pc@(rsrc_drvr_9)
    addal %sp@+,%a3
    jmp %a3@
rsrc_drvr_9_ctl_118:    /* result 0 */
    moveq #0,%d0
    rts
MPP_CONTROL_TABLE:  /* csCode 242-249, offsets from rsrc_drvr_9 */
    .short  MPP_cs242-rsrc_drvr_9  /* csCode 242 */
    .short  MPP_WriteLAP-rsrc_drvr_9  /* csCode 243 */
    .short  MPP_DetachPH-rsrc_drvr_9  /* csCode 244 */
    .short  MPP_AttachPH-rsrc_drvr_9  /* csCode 245 */
    .short  MPP_WriteDDP-rsrc_drvr_9  /* csCode 246 */
    .short  MPP_CloseSkt-rsrc_drvr_9  /* csCode 247 */
    .short  MPP_OpenSkt-rsrc_drvr_9  /* csCode 248 */
    .short  MPP_LoadNBP-rsrc_drvr_9  /* csCode 249 */

/* Control csCode 248: OpenSkt. */
MPP_OpenSkt:
    jbsr MPP_OpenSkt_8	| 408DD56E
    moveb %d1,%a0@(28)	| 408DD570
    jbra MPP_CloseSkt_12	| 408DD574

/* subroutine (34 instructions): calls rsrc_drvr_9_242 (mechanical summary) */
MPP_OpenSkt_8:
    moveq #-91,%d0	| 408DD576
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    tstb %d1
    jbeq rsrc_drvr_9_1F8
    jbmi rsrc_drvr_9_1F4
    jbsr rsrc_drvr_9_242
    jbeq rsrc_drvr_9_1F4
    moveq #13,%d2
rsrc_drvr_9_1DE:        /* loop: tst */
    tstb %a2@(0x4c,%d2:w)
    dbeq %d2,rsrc_drvr_9_1DE
    jbne rsrc_drvr_9_1F4
    moveb %d1,%a2@(0x4c,%d2:w)
    lslw #2,%d2
    movel %a1,%a2@(0x5a,%d2:w)
rsrc_drvr_9_1F2:        /* loop: clr */
    clrw %d0
rsrc_drvr_9_1F4:        /* loop: move */
    movew %sp@+,%sr
    rts
rsrc_drvr_9_1F8:        /* set %d2 */
    movew #504,%d2
    movel %a3,%d1
    lea %a2@(658),%a3
rsrc_drvr_9_202:        /* loop: tst */
    tstl %a3@-
    jbeq rsrc_drvr_9_20E
    subqw #4,%d2
    jbpl rsrc_drvr_9_202
    moveal %d1,%a3
    jbra rsrc_drvr_9_1F4
rsrc_drvr_9_20E:        /* set %a3@ */
    movel %a1,%a3@
    moveal %d1,%a3
    lsrw #2,%d2
    addib #0x80,%d2
    moveb %d2,%d1
    jbra rsrc_drvr_9_1F2

/* Control csCode 247: CloseSkt. */
MPP_CloseSkt:
    moveq #-91,%d0	| 408DD5CC
    tstb %d1	| 408DD5CE
    jbeq MPP_CloseSkt_12	| 408DD5D0
    jbmi MPP_CloseSkt_16	| 408DD5D2
    jbsr rsrc_drvr_9_242	| 408DD5D4
    jbne MPP_CloseSkt_12	| 408DD5D6
    clrb %a2@(0x4c,%d2:w)	| 408DD5D8 408DD5D8 clrb %a2@(4c,%d2:w)
MPP_CloseSkt_10:
    clrw %d0	| 408DD5DC
MPP_CloseSkt_12:        /* continue at rsrc_drvr_9_88A */
    jbra rsrc_drvr_9_88A	| 408DD5DE
MPP_CloseSkt_16:        /* call rsrc_drvr_9_24E */
    jbsr rsrc_drvr_9_24E	| 408DD5E2
    tstw %d2	| 408DD5E4
    jbmi MPP_CloseSkt_12	| 408DD5E6
    addaw %d2,%a2	| 408DD5E8
    clrl %a2@(150)	| 408DD5EA
    subaw %d2,%a2	| 408DD5EE
    jbra MPP_CloseSkt_10	| 408DD5F0

/* subroutine (4 instructions) (mechanical summary) */
rsrc_drvr_9_242:
    moveq #13,%d2
rsrc_drvr_9_242_2:      /* loop: cmp */
    cmpb %a2@(0x4c,%d2:w),%d1
    dbeq %d2,rsrc_drvr_9_242_2
    rts

/* subroutine (12 instructions) (mechanical summary) */
rsrc_drvr_9_24E:
    moveq #0,%d2
    moveb %d1,%d2
    cmpiw #254,%d2
    jbhi rsrc_drvr_9_24E_1A
    subiw #128,%d2
    lslw #2,%d2
    addaw %d2,%a2
    tstl %a2@(150)
    subaw %d2,%a2
    jbne rsrc_drvr_9_24E_1C
rsrc_drvr_9_24E_1A:     /* set %d2 */
    moveq #-1,%d2
rsrc_drvr_9_24E_1C:     /* return */
    rts

/* Control csCode 261: csCode 261 (name not known). */
MPP_cs261:
    moveb %a0@(29),%d3	| 408DD61C
    swap %d3	| 408DD620
    st %d3	| 408DD622
    moveal %a1@(2),%a3	| 408DD624
    moveb %a3@(14),%d1	| 408DD628
    jbra MPP_WriteDDP_8	| 408DD62C

/* Control csCode 246: WriteDDP. */
MPP_WriteDDP:
    subl %d3,%d3	| 408DD62E
    moveb %a0@(29),%d3	| 408DD630
    swap %d3	| 408DD634
MPP_WriteDDP_8:         /* set %a3 */
    moveal %a2@(684),%a3	| 408DD636
    jsr %a3@	| 408DD63A
    jbra MPP_CloseSkt_12	| 408DD63C

/* subroutine (6 instructions) (mechanical summary) */
rsrc_drvr_9_28E:
    subqw #1,%d0
rsrc_drvr_9_28E_2:      /* loop: move */
    moveb %a0@+,%d1
    addw %d1,%d3
    rolw #1,%d3
    dbf %d0,rsrc_drvr_9_28E_2
rsrc_drvr_9_28E_C:      /* return */
    rts

/* subroutine (224 instructions): calls rsrc_drvr_9_24E, rsrc_drvr_9_242, rsrc_drvr_9_28E, rsrc_drvr_9_72C, rsrc_drvr_9_5F4 (mechanical summary) */
thunk_FUN_408dd652:
    jbra rsrc_drvr_9_2A2
    .short  0x6000	| 408DD64E
    .short  0xFF26	| 408DD650

rsrc_drvr_9_2A2:        /* test %d3 */
    tstb %d3
    jbne rsrc_drvr_9_2A2_14
    moveq #-91,%d0
    tstb %d1
    jbeq rsrc_drvr_9_28E_C
    jbsr rsrc_drvr_9_24E
    tstw %d2
    jbpl rsrc_drvr_9_2A2_14
    jbsr rsrc_drvr_9_242
    jbne rsrc_drvr_9_28E_C
rsrc_drvr_9_2A2_14:     /* set %d0 */
    movel %a2@(1040),%d0
    jbeq rsrc_drvr_9_2A2_20
    moveal %d0,%a0
    moveq #3,%d0
    jsr %a0@
rsrc_drvr_9_2A2_20:     /* set %sp@- */
    movel %a1,%sp@-
    addqw #2,%a1
    moveal %a1@+,%a3
    addqw #7,%a3
    moveb %d1,%a3@(7)
    clrb %a2@(712)
    moveq #0,%d2
    movew %a2@(26),%d2
    tstw %a2@(832)
    jbmi rsrc_drvr_9_2A2_5E
    tstb %d3
    jbne rsrc_drvr_9_2A2_5E
    movew %a3@,%d0
    jbeq rsrc_drvr_9_2A2_48
    cmpw %d2,%d0
    jbne rsrc_drvr_9_2A2_5E
rsrc_drvr_9_2A2_48:     /* set %a0 */
    moveal %a3,%a0
    addqw #8,%a0
    moveb %a0@,%a3@
    movew %a0@-,%a3@-
    subqw #2,%a0
    lsll #8,%d2
    moveb %a0@,%d2
    moveq #1,%d3
    moveq #8,%d0
    jbra rsrc_drvr_9_2A2_13C
rsrc_drvr_9_2A2_5E:     /* test %d3 */
    tstb %d3
    jbne rsrc_drvr_9_2A2_6A
    movew %d2,%a3@(2)
    moveb %a2@,%a3@(5)
rsrc_drvr_9_2A2_6A:     /* set %d0 */
    moveb %d3,%d0
    swap %d3
    tstb %d0
    jbeq rsrc_drvr_9_2A2_7A
    tstb %d3
    jbne rsrc_drvr_9_2A2_7A
    subqw #2,%a3
    jbra rsrc_drvr_9_2A2_9A
rsrc_drvr_9_2A2_7A:     /* set %a0 */
    moveal %a3,%a0
    clrw %a3@-
    tstb %d3
    jbeq rsrc_drvr_9_2A2_9A
    moveq #9,%d0
    clrw %d3
    clrw %d1
rsrc_drvr_9_2A2_88:     /* call rsrc_drvr_9_28E (loop) */
    jbsr rsrc_drvr_9_28E
    movew %a1@+,%d0
    jbeq rsrc_drvr_9_2A2_94
    moveal %a1@+,%a0
    jbra rsrc_drvr_9_2A2_88
rsrc_drvr_9_2A2_94:     /* set %a3@ */
    movew %d3,%a3@
    jbne rsrc_drvr_9_2A2_9A
    subqw #1,%a3@
rsrc_drvr_9_2A2_9A:     /* set %d1 */
    moveb %a3@(6),%d1
    moveq #2,%d3
    moveq #16,%d0
    tstw %a2@(832)
    jbmi rsrc_drvr_9_2A2_C6
    movew %a3@(2),%d2
    jbeq rsrc_drvr_9_2A2_C0
    tstw %a3@(4)
    jbeq rsrc_drvr_9_2A2_C0
    movew %a2@(26),%d2
    jbeq rsrc_drvr_9_2A2_C0
    cmpw %a3@(2),%d2
    jbne rsrc_drvr_9_2A2_10A
rsrc_drvr_9_2A2_C0:     /* from here: lsll #8,%d2 */
    lsll #8,%d2
    moveb %d1,%d2
    jbra rsrc_drvr_9_2A2_13C
rsrc_drvr_9_2A2_C6:     /* set %d2 */
    movew %a3@(2),%d2
    lsll #8,%d2
    moveb %d1,%d2
    movew %a3@(2),%d1
    jbne rsrc_drvr_9_2A2_F2
    cmpib #0xff,%d2
    jbeq rsrc_drvr_9_2A2_13C
    cmpib #0xfe,%d2
    jbeq rsrc_drvr_9_2A2_10A
    clrw %a3@
    moveq #0,%d1
    movew %a2@(26),%d1
    movew %d1,%a3@(2)
    lsll #8,%d1
    addl %d1,%d2
    jbra rsrc_drvr_9_2A2_13C
rsrc_drvr_9_2A2_F2:     /* test #-256,%d1 */
    cmpiw #-256,%d1
    jbcc rsrc_drvr_9_2A2_13C
    cmpw %a2@(836),%d1
    jbcs rsrc_drvr_9_2A2_11C
    cmpw %a2@(838),%d1
    jbhi rsrc_drvr_9_2A2_11C
    cmpib #0xfe,%d2
    jbne rsrc_drvr_9_2A2_13C
rsrc_drvr_9_2A2_10A:    /* loop: tst */
    tstb %a2@(25)
    jbeq rsrc_drvr_9_2A2_116
    movel %a2@(826),%d2
    jbra rsrc_drvr_9_2A2_13C
rsrc_drvr_9_2A2_116:    /* set %d0 */
    moveq #-93,%d0
    addqw #4,%sp
    rts
rsrc_drvr_9_2A2_11C:    /* test bit 30 of %a2@(830) */
    btst #30,%a2@(830)
    jbne rsrc_drvr_9_2A2_10A
    lea %a2@(908),%a1
    movel %a1,%d2
    cmpw %a2@(914),%d1
    jbeq rsrc_drvr_9_2A2_136
    jbsr rsrc_drvr_9_72C
    jbmi rsrc_drvr_9_2A2_10A
rsrc_drvr_9_2A2_136:    /* set %a2@(712) */
    moveb #1,%a2@(712)
rsrc_drvr_9_2A2_13C:    /* set %a1 */
    moveal %sp@+,%a1
    movew %d0,%a1@
    clrw %d1
    moveal %a1,%a0
rsrc_drvr_9_2A2_144:    /* loop: tst */
    tstw %a0@
    jbeq rsrc_drvr_9_2A2_150
    jbmi rsrc_drvr_9_2A2_16A
    addw %a0@,%d1
    addqw #6,%a0
    jbra rsrc_drvr_9_2A2_144
rsrc_drvr_9_2A2_150:    /* set %a3@- */
    movew %d1,%a3@-
    subqw #3,%a3@
    subw %d0,%d1
    cmpiw #586,%d1
    jbhi rsrc_drvr_9_2A2_16A
    moveb %d3,%a3@-
    subqw #2,%a3
    moveb %d2,%a3@
    movel %a1,%a2@(698)
    jbra rsrc_drvr_9_1770
rsrc_drvr_9_2A2_16A:    /* set %d0 */
    moveq #-92,%d0
rsrc_drvr_9_2A2_16C:    /* continue at rsrc_drvr_9_28E_C */
    jbra rsrc_drvr_9_28E_C
rsrc_drvr_9_412:        /* set %d3 */
    moveq #6,%d3	| 408DD7C2
    jsr %a4@	| 408DD7C4
    jbne rsrc_drvr_9_2A2_16C	| 408DD7C6
    movel %a2@(1040),%d0
    jbeq rsrc_drvr_9_426
    moveal %d0,%a5
    moveq #1,%d0
    jsr %a5@
    jbne rsrc_drvr_9_492
rsrc_drvr_9_426:        /* set %d3 */
    moveq #5,%d3
    jsr %a4@
    jbne rsrc_drvr_9_2A2_16C
    tstb %a2@(821)
    jbeq rsrc_drvr_9_492
    jbra rsrc_drvr_9_448
rsrc_drvr_9_434:        /* loop: tst */
    tstb %a2@(821)
    jbeq rsrc_drvr_9_492
    movel %a2@(1040),%d0
    jbeq rsrc_drvr_9_448
    moveal %d0,%a5
    moveq #1,%d0
    jsr %a5@
    jbne rsrc_drvr_9_492
rsrc_drvr_9_448:        /* set %d2 */
    movew %a2@(8),%d2
    jbne rsrc_drvr_9_456
    tstw %a2@(832)
    jbmi rsrc_drvr_9_468
    jbra rsrc_drvr_9_460
rsrc_drvr_9_456:        /* set %d0 */
    movew %a2@(26),%d0
    jbeq rsrc_drvr_9_460
    cmpw %d2,%d0
    jbne rsrc_drvr_9_470
rsrc_drvr_9_460:        /* set %d0 */
    moveb %a2@(12),%d0
    cmpb %a2@,%d0
    jbeq rsrc_drvr_9_47A
rsrc_drvr_9_468:        /* test #0xff,%a2@(12) */
    cmpib #0xff,%a2@(12)
    jbeq rsrc_drvr_9_4A6
rsrc_drvr_9_470:        /* set %d0 */
    movel %a2@(812),%d0
    jbeq rsrc_drvr_9_492
    moveal %d0,%a5
    jmp %a5@
rsrc_drvr_9_47A:        /* test %d3 */
    tstl %d3
    jbeq rsrc_drvr_9_4A6
    movew %a2@(4),%d2
    andiw #15360,%d2
    jbeq rsrc_drvr_9_4A6
    movew %a2@(10),%d2
    jbsr rsrc_drvr_9_5F4
    jbra rsrc_drvr_9_4A6
rsrc_drvr_9_492:        /* loop: moveq */
    moveq #0,%d3
    jmp %a4@(2)
rsrc_drvr_9_498:        /* set %d3 */
    moveq #3,%d3	| 408DD848
    jsr %a4@	| 408DD84A
    jbne rsrc_drvr_9_2A2_16C	| 408DD84C
    tstb %a2@(821)
    jbeq rsrc_drvr_9_492
rsrc_drvr_9_4A6:        /* set %d2 */
    moveq #13,%d2
    moveb %a3@(-3),%d0
    jbeq rsrc_drvr_9_492
    jbpl rsrc_drvr_9_4CE
    cmpib #0xfe,%d0
    jbhi rsrc_drvr_9_492
    moveq #0,%d2
    moveb %d0,%d2
    subiw #128,%d2
    lslw #2,%d2
    lea %a2@(150),%a5
    movel %a5@(0x0,%d2:w),%d2
    jbeq rsrc_drvr_9_492
    moveal %d2,%a5
    jmp %a5@
rsrc_drvr_9_4CE:        /* loop: cmp */
    cmpb %a2@(0x4c,%d2:w),%d0
    dbeq %d2,rsrc_drvr_9_4CE
    jbne rsrc_drvr_9_492
    lslw #2,%d2
    moveal %a2@(0x5a,%d2:w),%a5
    jmp %a5@

/* subroutine (12 instructions): calls rsrc_drvr_9_1A5A, rsrc_drvr_9_506 (mechanical summary) */
rsrc_drvr_9_4E0:
    jbsr rsrc_drvr_9_1A5A
    moveml %d0-%d2/%a0-%a2,%sp@-
    moveq #40,%d0
    movew #31,%d1
    swap %d1
    movew #30,%d1
    movew #2,%d2
    swap %d2
    movew #6,%d2
    jbsr rsrc_drvr_9_506
    moveml %sp@+,%d0-%d2/%a0-%a2
    rts

/* subroutine (55 instructions): traps NewPtr, VInstall, DisposPtr; low memory ABusVars (mechanical summary) */
rsrc_drvr_9_506:
    movel %d0,%sp@-
    moveq #42,%d0
    .short  0xA71E	| 408DD8BA _NewPtr (flags 0x0700)
    moveml %sp@+,%d0
    jbne rsrc_drvr_9_5B8
    moveal ABusVars,%a2
    movel %a0,%a2@(940)
    moveal %a0,%a2
    movel #2017612372,%a2@
    movew %d0,%a2@(10)
    movew %d1,%a2@(12)
    swap %d1
    movew %d1,%a2@(4)
    movew %d2,%a2@(8)
    swap %d2
    movew %d2,%a2@(6)
    moveq #0,%d0
    movew %a2@(4),%d0
    lsll #2,%d0
    .short  0xA71E	| 408DD8F4 _NewPtr (flags 0x0700)
    jbne rsrc_drvr_9_5B4
    movel %a0,%a2@(20)
    moveq #0,%d0
    movew %a2@(6),%d0
    addw %a2@(8),%d0
    addqw #6,%d0
    movew %d0,%a2@(14)
    muluw %a2@(12),%d0
    .short  0xA71E	| 408DD910 _NewPtr (flags 0x0700)
    jbne rsrc_drvr_9_5AE
    movel %a0,%a2@(24)
    moveq #0,%d1
    movew %a2@(12),%d1
    subqw #1,%d1
rsrc_drvr_9_570:        /* loop: move */
    movel %a2@(16),%a0@
    movel %a0,%a2@(16)
    addaw %a2@(14),%a0
    dbf %d1,rsrc_drvr_9_570
    lea %a2@(28),%a0
    movew #1,%a0@(4)
    lea %pc@(rsrc_drvr_9_78E),%a1
    movel %a1,%a0@(6)
    movew %a2@(10),%d0
    jbeq rsrc_drvr_9_5A6
    muluw #60,%d0
    movew %d0,%a0@(10)
    _VInstall
    tstw %d0
    jbne rsrc_drvr_9_5A8
rsrc_drvr_9_5A6:        /* return */
    rts
rsrc_drvr_9_5A8:        /* set up and call _DisposPtr */
    moveal %a2@(24),%a0
    _DisposPtr
rsrc_drvr_9_5AE:        /* set up and call _DisposPtr */
    moveal %a2@(20),%a0
    _DisposPtr
rsrc_drvr_9_5B4:        /* set up and call _DisposPtr */
    moveal %a2,%a0
    _DisposPtr
rsrc_drvr_9_5B8:        /* set %d0 */
    movew #-1,%d0
    rts

/* subroutine (18 instructions): traps VRemove, DisposPtr; calls rsrc_drvr_9_1A5A; low memory ABusVars (mechanical summary) */
rsrc_drvr_9_5BE:
    jbsr rsrc_drvr_9_1A5A
    moveml %a0-%a1,%sp@-
    moveal ABusVars,%a1
    movel %a1@(940),%d0
    jbeq rsrc_drvr_9_5BE_30
    moveal %d0,%a1
    movew %a1@(10),%d0
    jbeq rsrc_drvr_9_5BE_20
    lea %a1@(28),%a0
    _VRemove
rsrc_drvr_9_5BE_20:     /* set up and call _DisposPtr */
    moveal %a1@(20),%a0
    _DisposPtr
    moveal %a1@(24),%a0
    _DisposPtr
    moveal %a1,%a0
    _DisposPtr
rsrc_drvr_9_5BE_30:     /* restore registers, return */
    moveml %sp@+,%a0-%a1
    rts

/* subroutine (9 instructions): calls rsrc_drvr_9_1A5A, rsrc_drvr_9_60C (mechanical summary) */
rsrc_drvr_9_5F4:
    jbsr rsrc_drvr_9_1A5A
    moveml %d1-%d3/%a0-%a3,%sp@-
    movew %d2,%sp@-
    moveal %sp,%a0
    moveal %d3,%a1
    jbsr rsrc_drvr_9_60C
    addqw #2,%sp
    moveml %sp@+,%d1-%d3/%a0-%a3
    rts

/* subroutine (105 instructions): calls rsrc_drvr_9_7E4, rsrc_drvr_9_824; low memory ABusVars (mechanical summary) */
rsrc_drvr_9_60C:
    moveal ABusVars,%a3
    moveal %a3@(940),%a3
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    jsr %pc@(rsrc_drvr_9_7E4)
    jbne rsrc_drvr_9_60C_3C
    bset #7,%a2@(4)
    movew %a3@(8),%d1
    asrw #1,%d1
    subqw #1,%d1
    addqw #6,%a2
    addaw %a3@(6),%a2
rsrc_drvr_9_60C_2C:     /* loop: move */
    movew %a1@+,%a2@+
    dbf %d1,rsrc_drvr_9_60C_2C
    subaw %a3@(8),%a1
    movew %sp@+,%sr
    clrw %d0
    rts
rsrc_drvr_9_60C_3C:     /* set %d1 */
    movel %a1,%d1
    lea %a3@(16),%a1
    movel %a1@,%d0
    jbeq rsrc_drvr_9_658_42
    moveal %d0,%a2
    movel %a2@,%a1@
    moveal %d1,%a1

rsrc_drvr_9_658:        /* loop: bset */
    bset #7,%a2@(4)
    addqw #6,%a2
    movew %a3@(6),%d1
    asrw #1,%d1
    subqw #1,%d1
rsrc_drvr_9_658_10:     /* loop: move */
    movew %a0@+,%a2@+
    dbf %d1,rsrc_drvr_9_658_10
    movew %a3@(8),%d1
    asrw #1,%d1
    subqw #1,%d1
rsrc_drvr_9_658_1E:     /* loop: move */
    movew %a1@+,%a2@+
    dbf %d1,rsrc_drvr_9_658_1E
    subaw %a3@(8),%a1
    subaw %a3@(8),%a2
    subaw %a3@(6),%a2
    subaw %a3@(6),%a0
    subqw #6,%a2
    moveal %d2,%a3
    movel %a3@,%a2@
    movel %a2,%a3@
    movew %sp@+,%sr
    clrw %d0
    rts
rsrc_drvr_9_658_42:     /* set %a1 */
    moveal %d1,%a1
    movew %a3@(10),%d0
    jbne rsrc_drvr_9_6AA
    movew %sp@+,%sr
    movew #-1,%d0
    rts

rsrc_drvr_9_6AA:        /* save registers */
    moveml %d2/%a0-%a1,%sp@-
    movew 0x20e,%sp@-
    movew 0x20e,%sp@-
    movew 0x20e,%sp@-
    moveal %sp,%a0
    jsr %pc@(rsrc_drvr_9_824)
    addql #6,%sp
rsrc_drvr_9_6AA_18:     /* loop: movea */
    moveal %a2,%a0
rsrc_drvr_9_6AA_1A:     /* loop: movea */
    moveal %a2,%a1
    moveal %a2@,%a2
    movel %a2,%d1
    jbeq rsrc_drvr_9_6AA_34
    btst #7,%a2@(4)
    jbne rsrc_drvr_9_6AA_1A
    movel %a2@,%a1@
rsrc_drvr_9_6AA_2C:     /* restore registers */
    moveml %sp@+,%d2/%a0-%a1
    jbra rsrc_drvr_9_658
rsrc_drvr_9_6AA_34:     /* set %a2 */
    moveal %a0,%a2
    addql #4,%a2
    cmpal %d2,%a2
    jbne rsrc_drvr_9_6AA_66
rsrc_drvr_9_6AA_3C:     /* loop: movea */
    moveal %a2,%a0
    moveal %a2,%a1
    moveal %a2@,%a2
    movel %a2,%d1
    jbeq rsrc_drvr_9_6AA_4A
    movel %a2@,%a1@
    jbra rsrc_drvr_9_6AA_2C
rsrc_drvr_9_6AA_4A:     /* set %a2 */
    moveal %a0,%a2
    addql #4,%a2
    moveq #0,%d1
    movew %a3@(4),%d1
    lsll #2,%d1
    moveal %a3@(20),%a0
    addal %d1,%a0
    cmpal %a2,%a0
    jbne rsrc_drvr_9_6AA_3C
    moveal %a3@(20),%a2
    jbra rsrc_drvr_9_6AA_3C
rsrc_drvr_9_6AA_66:     /* clear %d1 */
    moveq #0,%d1
    movew %a3@(4),%d1
    lsll #2,%d1
    moveal %a3@(20),%a0
    addal %d1,%a0
    cmpal %a2,%a0
    jbne rsrc_drvr_9_6AA_18
    moveal %a3@(20),%a2
    cmpal %d2,%a2
    jbeq rsrc_drvr_9_6AA_3C
    jbra rsrc_drvr_9_6AA_18

/* subroutine (15 instructions): calls rsrc_drvr_9_1A5A, rsrc_drvr_9_758 (mechanical summary) */
rsrc_drvr_9_72C:
    jbsr rsrc_drvr_9_1A5A
    moveml %d0/%d2/%a0-%a3,%sp@-
    movew %d1,%sp@-
    moveal %sp,%a0
    jbsr rsrc_drvr_9_758
    tstw %d0
    jbeq rsrc_drvr_9_72C_1C
    addqw #2,%sp
    clrw %d1
    movew #8,%ccr
    jbra rsrc_drvr_9_72C_20
rsrc_drvr_9_72C_1C:     /* set %d1 */
    movemw %sp@+,%d1
rsrc_drvr_9_72C_20:     /* restore registers, return */
    moveml %sp@+,%d0/%d2/%a0-%a3
    movemw %d1,%a2@(914)
    rts

/* subroutine (48 instructions): calls rsrc_drvr_9_7E4; low memory ABusVars (mechanical summary) */
rsrc_drvr_9_758:
    moveal ABusVars,%a3
    moveal %a3@(940),%a3
    jsr %pc@(rsrc_drvr_9_7E4)
    jbne rsrc_drvr_9_758_34
    movew %sr,%d0
    oriw #1792,%sr
    andiw #-257,%sr
    addqw #6,%a2
    addaw %a3@(6),%a2
    movew %a3@(8),%d1
    asrw #1,%d1
    subqw #1,%d1
rsrc_drvr_9_758_26:     /* loop: move */
    movew %a2@+,%a1@+
    dbf %d1,rsrc_drvr_9_758_26
    movew %d0,%sr
    subaw %a3@(8),%a1
    clrw %d0
rsrc_drvr_9_758_34:     /* return */
    rts
rsrc_drvr_9_78E:        /* set %a3 */
    moveal ABusVars,%a3	| 408DDB3E
    moveal %a3@(940),%a3	| 408DDB42
    movew %a3@(10),%d0	| 408DDB46
    muluw #60,%d0	| 408DDB4A
    movew %d0,%a0@(10)	| 408DDB4E
    moveal %a3@(20),%a2	| 408DDB52
    movew %a3@(4),%d0	| 408DDB56
    subqw #1,%d0	| 408DDB5A
rsrc_drvr_9_7AC:        /* loop: movea */
    moveal %a2,%a0	| 408DDB5C
    movew %sr,%sp@-	| 408DDB5E
    oriw #1792,%sr	| 408DDB60
    andiw #-257,%sr	| 408DDB64
rsrc_drvr_9_7B8:        /* loop: movea */
    moveal %a2,%a1	| 408DDB68
    moveal %a2@,%a2	| 408DDB6A
    movel %a2,%d1	| 408DDB6C
    jbeq rsrc_drvr_9_7D8	| 408DDB6E
    bclr #7,%a2@(4)	| 408DDB70
    jbne rsrc_drvr_9_7B8	| 408DDB76
    movel %a1,%d2	| 408DDB78
    movel %a2@,%a1@	| 408DDB7A
    lea %a3@(16),%a1	| 408DDB7C
    movel %a1@,%a2@	| 408DDB80
    movel %a2,%a1@	| 408DDB82
    moveal %d2,%a2	| 408DDB84
    jbra rsrc_drvr_9_7B8	| 408DDB86
rsrc_drvr_9_7D8:        /* set %sr */
    movew %sp@+,%sr	| 408DDB88
    moveal %a0,%a2	| 408DDB8A
    addql #4,%a2	| 408DDB8C
    dbf %d0,rsrc_drvr_9_7AC	| 408DDB8E
    rts	| 408DDB92

/* subroutine (26 instructions): calls rsrc_drvr_9_824 (mechanical summary) */
rsrc_drvr_9_7E4:
    jsr %pc@(rsrc_drvr_9_824)
rsrc_drvr_9_7E4_4:      /* loop: movea */
    moveal %a2@,%a2
    movel %a2,%d0
    jbeq rsrc_drvr_9_7E4_3A
    movew %a3@(6),%d0
    asrw #1,%d0
    subqw #1,%d0
    addqw #6,%a2
rsrc_drvr_9_7E4_14:     /* loop: cmpm */
    cmpmw %a0@+,%a2@+
    dbne %d0,rsrc_drvr_9_7E4_14
    jbne rsrc_drvr_9_7E4_2A
    movew %a3@(6),%d0
    subaw %d0,%a2
    subaw %d0,%a0
    subqw #6,%a2
    clrw %d0
    rts
rsrc_drvr_9_7E4_2A:     /* set %d1 */
    movew %a3@(6),%d1
    aslw #1,%d0
    subw %d0,%d1
    subaw %d1,%a0
    subaw %d1,%a2
    subqw #6,%a2
    jbra rsrc_drvr_9_7E4_4
rsrc_drvr_9_7E4_3A:     /* set %d0 */
    movew #-1,%d0
    rts

/* subroutine (32 instructions) (mechanical summary) */
rsrc_drvr_9_824:
    cmpiw #2,%a3@(6)
    jbne rsrc_drvr_9_824_E
    moveq #0,%d0
    movew %a0@,%d0
    jbra rsrc_drvr_9_824_36
rsrc_drvr_9_824_E:      /* from here: addaw %a3@(6),%a0 */
    addaw %a3@(6),%a0
    movel %a0@-,%d0
    jbpl rsrc_drvr_9_824_18
    negl %d0
rsrc_drvr_9_824_18:     /* test #4,%a3@(6) */
    cmpiw #4,%a3@(6)
    jbeq rsrc_drvr_9_824_22
    subqw #2,%a0
rsrc_drvr_9_824_22:     /* clear %d2 */
    moveq #0,%d2
    movew %a3@(4),%d2
    swap %d2
rsrc_drvr_9_824_2A:     /* loop: su */
    subl %d2,%d0
    jbge rsrc_drvr_9_824_2A
    divuw %a3@(4),%d0
    jbvc rsrc_drvr_9_824_3A
    addl %d2,%d0
rsrc_drvr_9_824_36:     /* from here: divuw %a3@(4),%d0 */
    divuw %a3@(4),%d0
rsrc_drvr_9_824_3A:     /* from here: swap %d0 */
    swap %d0
    aslw #2,%d0
    moveal %a3@(20),%a2
    addaw %d0,%a2
    movel %a2,%d2
    rts
rsrc_drvr_9_824_48:     /* set %d1 */
    movel %a2@(692),%d1
    jbeq rsrc_drvr_9_824_56
    moveal %a2@(676),%a3
    jsr %a3@(2)
rsrc_drvr_9_824_56:     /* continue at rsrc_drvr_9_88A */
    jbra rsrc_drvr_9_88A

/* Control csCode 242: csCode 242 (name not known). */
MPP_cs242:
    movel %a2@(692),%d2	| 408DDC2C
    jbeq rsrc_drvr_9_88A	| 408DDC30
    moveal %a2@(676),%a3	| 408DDC32
    jmp %a3@	| 408DDC36

/* Control csCode 249: LoadNBP. */
MPP_LoadNBP:
    moveq #0,%d0	| 408DDC38
rsrc_drvr_9_88A:        /* continue at rsrc_drvr_9_status_3A */
    jbra rsrc_drvr_9_status_3A

/* subroutine (25 instructions): traps VRemove (mechanical summary) */
rsrc_drvr_9_88E:
    lea %pc@(rsrc_drvr_9_898),%a3
    movel %a3,%a2@(672)
    jmp %a3@
rsrc_drvr_9_898:        /* subtract 7 to %d3 */
    subqw #7,%d3
    jbmi rsrc_drvr_9_8DC
    addw %d3,%d3
    lea %pc@(MPP_CONTROL_TABLE2),%a3
    addaw %d3,%a3
    movew %a3@,%d3
    lea %pc@(rsrc_drvr_9_898),%a3
    addaw %d3,%a3
    movel %a3,%sp@-
    moveal %a2@(680),%a3
    rts
MPP_CONTROL_TABLE2:  /* csCode 249-264 (by csCode-249), offsets from rsrc_drvr_9_898 */
    .short  0x0062  /* csCode 249: not reached (handled by MPP_CONTROL_TABLE) */
    .short  MPP_ConfirmName-rsrc_drvr_9_898  /* csCode 250 */
    .short  MPP_LookupName-rsrc_drvr_9_898  /* csCode 251 */
    .short  MPP_RemoveName-rsrc_drvr_9_898  /* csCode 252 */
    .short  MPP_RegisterName-rsrc_drvr_9_898  /* csCode 253 */
    .short  MPP_KillNBP-rsrc_drvr_9_898  /* csCode 254 */
    .short  MPP_UnloadNBP-rsrc_drvr_9_898  /* csCode 255 */
    .short  MPP_cs256-rsrc_drvr_9_898  /* csCode 256 */
    .short  MPP_cs257-rsrc_drvr_9_898  /* csCode 257 */
    .short  MPP_cs258-rsrc_drvr_9_898  /* csCode 258 */
    .short  MPP_cs259-rsrc_drvr_9_898  /* csCode 259 */
    .short  MPP_cs260-rsrc_drvr_9_898  /* csCode 260 */
    .short  MPP_cs261-rsrc_drvr_9_898  /* csCode 261 */
    .short  MPP_cs262-rsrc_drvr_9_898  /* csCode 262 */
    .short  MPP_cs263-rsrc_drvr_9_898  /* csCode 263 */
    .short  MPP_cs264-rsrc_drvr_9_898  /* csCode 264 */
    .short  0x303C, 0xFFEF, 0x6000, 0x00DC	| 408DDC84
rsrc_drvr_9_8DC:        /* set %a3 */
    moveal %a2@(680),%a3
    moveq #9,%d2
rsrc_drvr_9_8E2:        /* loop: tst */
    tstb %a3@(0x2,%d2:w)
    jbeq rsrc_drvr_9_8F4
    movew %d2,%d3
    muluw #18,%d3
    lea %a3@(0x10,%d3:w),%a0
    _VRemove
rsrc_drvr_9_8F4:        /* subtract 1 to %d2 */
    subqw #1,%d2
    jbpl rsrc_drvr_9_8E2
    rts
    .byte   0x20, 0x3C, 0x00, 0x00, 0x01, 0x51, 0xA7, 0x1E, 0x66, 0x1E, 0x43, 0xFA, 0x04, 0xF4, 0x26, 0x6A	| 408DDCAA
    .byte   0x02, 0xAC, 0x42, 0x41, 0x4E, 0xAB, 0x00, 0x02, 0x4A, 0x40, 0x66, 0x0E, 0x11, 0x41, 0x01, 0x24	| 408DDCBA
    .byte   0x10, 0xBC, 0x00, 0x0A, 0x25, 0x48, 0x02, 0xA8, 0x4E, 0x75, 0x32, 0x00, 0xA0, 0x1F, 0x30, 0x01	| 408DDCCA
    .byte   0x4E, 0x75	| 408DDCDA

/* Control csCode 254: KillNBP. */
MPP_KillNBP:
    moveal %a0@(28),%a0	| 408DDCDC
    movew #-1105,%d0	| 408DDCE0
    jbsr rsrc_drvr_9_D4A
    jbra MPP_UnloadNBP_2

/* Control csCode 256: csCode 256 (name not known). */
MPP_cs256:
    moveb %a2@(696),%a0@(29)	| 408DDCEA
    moveb %a0@(28),%a2@(696)	| 408DDCF0
    jbra MPP_UnloadNBP	| 408DDCF6

/* Control csCode 250: ConfirmName. */
MPP_ConfirmName:
    jbra MPP_LookupName_4	| 408DDCF8

/* Control csCode 253: RegisterName. */
MPP_RegisterName:
    movel %a0,%d3	| 408DDCFC
    tstl %a2@(692)	| 408DDCFE
    jbne MPP_RegisterName_4A	| 408DDD02
    movel #152,%d0	| 408DDD04
    .short  0xA71E	| 408DDD0A 408DDD0A A-line trap
    jbne rsrc_drvr_9_9B0	| 408DDD0C
    lea %a0@(26),%a0	| 408DDD0E
    movel %a0,%a2@(692)	| 408DDD12
    btst #30,%a2@(830)	| 408DDD16
    jbne MPP_RegisterName_48	| 408DDD1C
    moveml %d1/%a1/%a3,%sp@-	| 408DDD1E
    moveq #2,%d1	| 408DDD22
    moveal %a2@(676),%a1	| 408DDD24
    addqw #4,%a1	| 408DDD28
    moveal %a2@(684),%a3	| 408DDD2A
    jsr %a3@(2)	| 408DDD2E
    moveml %sp@+,%d1/%a1/%a3	| 408DDD32
    tstw %d0	| 408DDD36
    jbeq MPP_RegisterName_48	| 408DDD38
    clrl %a2@(692)	| 408DDD3A
    movew #-1029,%d0
    jbra rsrc_drvr_9_9B0
MPP_RegisterName_48:    /* set %a0 */
    moveal %d3,%a0	| 408DDD44
MPP_RegisterName_4A:    /* test %a0@(34) */
    tstb %a0@(34)	| 408DDD46
    jbeq rsrc_drvr_9_9B2	| 408DDD4A
    lea %a1@(9),%a1	| 408DDD4C
    jbsr rsrc_drvr_9_A48	| 408DDD50
    jbne MPP_RegisterName_60	| 408DDD54
    jbsr rsrc_drvr_9_A24	| 408DDD56
    jbeq MPP_LookupName_4	| 408DDD58
MPP_RegisterName_60:    /* set %d0 */
    movew #-1027,%d0
rsrc_drvr_9_9B0:        /* continue at MPP_UnloadNBP_2 */
    jbra MPP_UnloadNBP_2
rsrc_drvr_9_9B2:        /* call rsrc_drvr_9_9C0 */
    jbsr rsrc_drvr_9_9C0

/* Control csCode 255: UnloadNBP. */
MPP_UnloadNBP:
    moveq #0,%d0
MPP_UnloadNBP_2:        /* loop: movea */
    moveal ABusVars_dce,%a1
    moveal JIODone,%a0
    jmp %a0@

/* subroutine (23 instructions) (mechanical summary) */
rsrc_drvr_9_9C0:
    clrw %d2
    moveb %a1@(7),%d1
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
rsrc_drvr_9_9C0_10:     /* loop: addq */
    addqw #1,%d2
    lea %a2@(688),%a3
rsrc_drvr_9_9C0_16:     /* loop: tst */
    tstl %a3@
    jbeq rsrc_drvr_9_9C0_2E
    moveal %a3@,%a3
    cmpb %a3@(7),%d1
    jbne rsrc_drvr_9_9C0_16
    tstb %d2
    jbeq rsrc_drvr_9_9C0_16
    cmpb %a3@(8),%d2
    jbeq rsrc_drvr_9_9C0_10
    jbra rsrc_drvr_9_9C0_16
rsrc_drvr_9_9C0_2E:     /* set %a1@(6) */
    moveb %a2@,%a1@(6)
    moveb %d2,%a1@(8)
    clrl %a1@
    movel %a1,%a3@
    movew %sp@+,%sr
    rts

/* Control csCode 252: RemoveName. */
MPP_RemoveName:
    movew #-1028,%d0	| 408DDDAE
    jbsr rsrc_drvr_9_A24
    jbeq MPP_UnloadNBP_2
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    lea %a2@(688),%a0
rsrc_drvr_9_A14:        /* loop: cmp */
    cmpl %a0@,%d3
    jbeq rsrc_drvr_9_A1C
    moveal %a0@,%a0
    jbra rsrc_drvr_9_A14
rsrc_drvr_9_A1C:        /* set %a1 */
    moveal %d3,%a1
    movel %a1@,%a0@
    movew %sp@+,%sr
    jbra MPP_UnloadNBP

/* subroutine (14 instructions): calls rsrc_drvr_9_127C (mechanical summary) */
rsrc_drvr_9_A24:
    moveml %d0-%d1/%a0-%a4,%sp@-
    moveal %a1,%a3
    lea %a2@(688),%a4
    moveq #0,%d3
rsrc_drvr_9_A24_C:      /* loop: tst */
    tstl %a4@
    jbeq rsrc_drvr_9_A24_1E
    moveal %a4@,%a4
    moveal %a4,%a0
    moveal %a3,%a1
    jbsr rsrc_drvr_9_127C
    jbne rsrc_drvr_9_A24_C
    movel %a4,%d3
rsrc_drvr_9_A24_1E:     /* restore registers, return */
    moveml %sp@+,%d0-%d1/%a0-%a4
    rts

/* subroutine (23 instructions): calls rsrc_drvr_9_127C (mechanical summary) */
rsrc_drvr_9_A48:
    moveml %d0-%d2/%a0-%a1,%sp@-
    moveq #0,%d3
    moveq #9,%d2
rsrc_drvr_9_A48_8:      /* loop: tst */
    tstb %a3@(0x2,%d2:w)
    dbne %d2,rsrc_drvr_9_A48_8
    jbeq rsrc_drvr_9_A48_38
    movew %d2,%d1
    muluw #18,%d1
    moveal %a3@(0xc,%d1:w),%a0
    cmpiw #253,%a0@(26)
    jbne rsrc_drvr_9_A48_40
    moveal %a0@(30),%a0
    moveml %d2/%a1,%sp@-
    jbsr rsrc_drvr_9_127C
    moveml %sp@+,%d2/%a1
    jbne rsrc_drvr_9_A48_40
    moveq #-1,%d3
rsrc_drvr_9_A48_38:     /* restore registers, return */
    moveml %sp@+,%d0-%d2/%a0-%a1
    tstw %d3
    rts
rsrc_drvr_9_A48_40:     /* subtract 1 to %d2 */
    subqw #1,%d2
    jbmi rsrc_drvr_9_A48_38
    jbra rsrc_drvr_9_A48_8

/* Control csCode 251: LookupName. */
MPP_LookupName:
    clrw %a0@(42)	| 408DDE3E
MPP_LookupName_4:       /* loop: move */
    movew #-1097,%d0	| 408DDE42
    moveq #9,%d2	| 408DDE46
MPP_LookupName_A:       /* loop: tst */
    tstb %a3@(2,%d2:w)	| 408DDE48
    dbeq %d2,MPP_LookupName_A	| 408DDE4C
    jbne MPP_UnloadNBP_2	| 408DDE50
MPP_LookupName_16:      /* loop: addq */
    addqb #1,%a3@(293)	| 408DDE54
    jbeq MPP_LookupName_16	| 408DDE58
    movew %sr,%sp@-	| 408DDE5A
    oriw #1792,%sr	| 408DDE5C
    andiw #-257,%sr	| 408DDE60
    cmpiw #257,%a0@(26)	| 408DDE64
    jbne MPP_LookupName_3E	| 408DDE6A
    tstl %a2@(930)	| 408DDE6C
    jbeq MPP_LookupName_3A	| 408DDE70
    movew %sp@+,%sr	| 408DDE72
    jbra MPP_UnloadNBP_2	| 408DDE74
MPP_LookupName_3A:      /* set %a2@(930) */
    movel %a0,%a2@(930)	| 408DDE78
MPP_LookupName_3E:      /* set %d2:w) */
    moveb %a3@(293),%a3@(2,%d2:w)	| 408DDE7C
    muluw #18,%d2	| 408DDE82
    lea %a3@(0xc,%d2:w),%a2	| 408DDE86 408DDE86 lea %a3@(c,%d2:w),%a2
    movel %a0,%a2@+	| 408DDE8A
    moveal %a2,%a0	| 408DDE8C
    movew #1,%a0@(4)	| 408DDE8E
    lea %pc@(rsrc_drvr_9_C66),%a2	| 408DDE94
    movel %a2,%a0@(6)	| 408DDE98
    lslw #3,%d1	| 408DDE9C
    andiw #1023,%d1	| 408DDE9E
    movew %d1,%a0@(10)	| 408DDEA2
    lea VBLQueueHdr_Head,%a2	| 408DDEA6
MPP_LookupName_6C:      /* loop: tst */
    tstl %a2@	| 408DDEAA
    jbeq MPP_LookupName_7A	| 408DDEAC
    moveal %a2@,%a2	| 408DDEAE
    cmpal %a2,%a0	| 408DDEB0
    jbne MPP_LookupName_6C	| 408DDEB2
    movew %sp@+,%sr	| 408DDEB4
    jbra MPP_LookupName_7E	| 408DDEB6
MPP_LookupName_7A:      /* set %sr */
    movew %sp@+,%sr	| 408DDEB8
    _VInstall	| 408DDEBA 408DDEBA A-line trap
MPP_LookupName_7E:
    moveal %a0@(-4),%a2	| 408DDEBC
    cmpiw #251,%a2@(26)
    jbne rsrc_drvr_9_B2A
    movew #1,%a0@(10)
    tstb %a2@(29)
    jbeq rsrc_drvr_9_B4A
    addqb #1,%a2@(29)
    jbra rsrc_drvr_9_B4A
rsrc_drvr_9_B2A:        /* test #257,%a2@(26) */
    cmpiw #257,%a2@(26)
    moveal ABusVars,%a2
    jbne rsrc_drvr_9_B3C
    jbsr rsrc_drvr_9_155A
    jbra rsrc_drvr_9_B3E
rsrc_drvr_9_B3C:        /* call rsrc_drvr_9_B9C */
    jbsr rsrc_drvr_9_B9C
rsrc_drvr_9_B3E:        /* address %a3@(294) */
    lea %a3@(294),%a1
    moveal %a2@(684),%a0
    moveq #0,%d3
    jsr %a0@
rsrc_drvr_9_B4A:        /* set %sp@- */
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    moveal ABusVars_dce,%a1
    bclr #7,%a1@(5)
    moveal %a1@(8),%a0
    movel %a0@,%a1@(8)
    jbne rsrc_drvr_9_B6C
    clrl %a1@(12)
rsrc_drvr_9_B6C:        /* test #251,%a0@(26) */
    cmpiw #251,%a0@(26)
    jbne rsrc_drvr_9_B7E
    movel %a0@(34),%a0@
    movew %a0@(38),%a0@(18)
rsrc_drvr_9_B7E:        /* loop: move */
    movel %a1@(8),%d0
    jbeq rsrc_drvr_9_B98
    moveal %d0,%a0
    moveq #0,%d0
    bset #7,%a1@(5)
    movew %sp@+,%sr
    jsr %pc@(rsrc_drvr_9_ctl)
    moveq #0,%d0
    rts
rsrc_drvr_9_B98:        /* set %sr */
    movew %sp@+,%sr
    rts

/* subroutine (46 instructions): calls rsrc_drvr_9_C28 (mechanical summary) */
rsrc_drvr_9_B9C:
    moveal %a3@(0xc,%d2:w),%a0
    divuw #18,%d2
    moveb %a3@(0x2,%d2:w),%a3@(315)
    moveq #33,%d3
    movel %a0@(34),%d2
    lsrl #8,%d2
    cmpiw #250,%a0@(26)
    jbeq rsrc_drvr_9_B9C_38
    moveq #0,%d2
    st %d2
    moveb %a2@(25),%d0
    jbeq rsrc_drvr_9_B9C_38
    moveb %d0,%d2
    tstw %a2@(832)
    jbpl rsrc_drvr_9_B9C_36
    jbsr rsrc_drvr_9_C28
    movel %a2@(826),%d2
rsrc_drvr_9_B9C_36:     /* set %d3 */
    moveq #17,%d3
rsrc_drvr_9_B9C_38:     /* set %d0 */
    movel %a1,%d0
    lea %a3@(296),%a1
    lea %a3@(321),%a0
    movel %a0,%a1@+
    moveb #2,%a0@(13)
    moveb %d2,%a0@(11)
    lsrl #8,%d2
    movew %d2,%a0@(7)
    moveb #2,%a0@(15)
    movew #7,%a1@+
    lea %a3@(314),%a0
    movel %a0,%a1@+
    moveb %d3,%a0@
    addqw #2,%a0
    movew %a2@(26),%a0@+
    moveb %a2@,%a0@+
    moveb %a3@(292),%d1
    moveb %d1,%a0@
    moveal %d0,%a0
    clrw %d2
    moveb %a0@,%d2
    addb %a0@(0x1,%d2:w),%d2
    addb %a0@(0x2,%d2:w),%d2
    addqb #3,%d2
    movew %d2,%a1@+
    movel %a0,%a1@+
    clrw %a1@
    rts

/* subroutine (92 instructions): traps BlockMove; calls rsrc_drvr_9_155A, rsrc_drvr_9_B9C, rsrc_drvr_9_9C0, rsrc_drvr_9_D4A (mechanical summary) */
rsrc_drvr_9_C28:
    moveq #2,%d1
    addb %a1@,%d1
    addb %a1@(0xffffffffffffffff,%d1:w),%d1
    cmpib #1,%a1@(0x0,%d1:w)
    jbne rsrc_drvr_9_C28_3C
    cmpib #42,%a1@(0x1,%d1:w)
    jbne rsrc_drvr_9_C28_3C
    movel %a0,%sp@-
    moveal %a1,%a0
    lea %a3@(192),%a1
    movel %d1,%d0
    _BlockMove
    lea %a2@(854),%a0
    addaw %d1,%a3
    lea %a3@(192),%a1
    subaw %d1,%a3
    moveq #1,%d0
    addb %a0@,%d0
    _BlockMove
    lea %a3@(192),%a1
    moveal %sp@+,%a0
rsrc_drvr_9_C28_3C:     /* return */
    rts
rsrc_drvr_9_C66:        /* set %a2 */
    moveal ABusVars,%a2	| 408DE016
    moveal ABusVars_dce,%a3	| 408DE01A
    lea %a0@(-4),%a1	| 408DE01E
    movel %a1,%d2	| 408DE022
    moveal %a1@,%a1	| 408DE024
    subqb #1,%a1@(29)	| 408DE026
    jbeq rsrc_drvr_9_CF2	| 408DE02A
    bset #7,%a3@(5)	| 408DE02C
    jbeq rsrc_drvr_9_C90	| 408DE032
rsrc_drvr_9_C28_5C:     /* loop: move */
    movew #1,%a0@(10)
    addqb #1,%a1@(29)
    rts
rsrc_drvr_9_C90:        /* set %a3 */
    moveal %a2@(680),%a3	| 408DE040
    moveq #0,%d0
    moveb %a1@(28),%d0
    jbne rsrc_drvr_9_C28_76
    moveq #1,%d0
rsrc_drvr_9_C28_76:     /* from here: lslw #3,%d0 */
    lslw #3,%d0
    movew %d0,%a0@(10)
    movew %a1@(26),%d3
    moveal %a1@(30),%a1
    cmpiw #253,%d3
    jbne rsrc_drvr_9_C28_8E
    lea %a1@(9),%a1
rsrc_drvr_9_C28_8E:     /* address %a3@(12) */
    lea %a3@(12),%a0
    subl %a0,%d2
    extl %d2
    cmpiw #257,%d3
    jbne rsrc_drvr_9_C28_A2
    jbsr rsrc_drvr_9_155A
    jbra rsrc_drvr_9_C28_A6
rsrc_drvr_9_C28_A2:     /* call rsrc_drvr_9_B9C */
    jbsr rsrc_drvr_9_B9C
rsrc_drvr_9_C28_A6:     /* address %a3@(294) */
    lea %a3@(294),%a1
    moveal %a2@(684),%a0
    moveq #0,%d3
    jsr %a0@
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    moveal ABusVars_dce,%a1
    bclr #7,%a1@(5)
    jbra rsrc_drvr_9_B7E
rsrc_drvr_9_CF2:        /* test bit 7 of %a3@(5) */
    btst #7,%a3@(5)
    jbeq rsrc_drvr_9_C28_D8
    cmpal %a3@(8),%a1
    jbeq rsrc_drvr_9_C28_5C
rsrc_drvr_9_C28_D8:     /* set %a3 */
    moveal %a2@(680),%a3
    movew %a1@(26),%d0
    moveal %a1,%a0
    moveal %a1@(30),%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    tstw %a0@(16)
    jble rsrc_drvr_9_C28_11C
    cmpiw #257,%d0
    jbne rsrc_drvr_9_C28_102
    movew #-93,%d0
    jbra rsrc_drvr_9_C28_11A
rsrc_drvr_9_C28_102:    /* test #253,%d0 */
    cmpiw #253,%d0
    jbeq rsrc_drvr_9_C28_114
    cmpiw #250,%d0
    jbne rsrc_drvr_9_C28_118
    movew #-1025,%d0
    jbra rsrc_drvr_9_C28_11A
rsrc_drvr_9_C28_114:    /* call rsrc_drvr_9_9C0 */
    jbsr rsrc_drvr_9_9C0
rsrc_drvr_9_C28_118:    /* clear %d0 */
    moveq #0,%d0
rsrc_drvr_9_C28_11A:    /* call rsrc_drvr_9_D4A */
    jbsr rsrc_drvr_9_D4A
rsrc_drvr_9_C28_11C:    /* set %sr */
    movew %sp@+,%sr
    rts
    .short  0x7000	| 408DE0F8

/* subroutine (166 instructions): traps StripAddress, VRemove; calls rsrc_drvr_9_1290, rsrc_drvr_9_12AA, thunk_FUN_408dd652; low memory ABusVars, JIODone (mechanical summary) */
rsrc_drvr_9_D4A:
    moveal %a2@(680),%a3
    moveq #9,%d2
rsrc_drvr_9_D4A_6:      /* loop: tst */
    tstb %a3@(0x2,%d2:w)
    dbne %d2,rsrc_drvr_9_D4A_6
    jbeq rsrc_drvr_9_D4A_64
    movew %d2,%d3
    muluw #18,%d3
    movel %a3@(0xc,%d3:w),%d1
    subl %a0,%d1
    exg %d0,%d1
    _StripAddress
    exg %d0,%d1
    tstl %d1
    jbne rsrc_drvr_9_D4A_60
    movew %d0,%a0@(16)
    lea %a3@(0x10,%d3:w),%a1
    tstw %a1@(10)
    jbeq rsrc_drvr_9_D4A_3E
    exg %a0,%a1
    movew %d0,%d1
    _VRemove
    movew %d1,%d0
    moveal %a1,%a0
rsrc_drvr_9_D4A_3E:     /* clear %a3@(0x2,%d2:w) */
    clrb %a3@(0x2,%d2:w)
    movel %a2@(930),%d1
    jbeq rsrc_drvr_9_D4A_50
    subl %a0,%d1
    jbne rsrc_drvr_9_D4A_50
    clrl %a2@(930)
rsrc_drvr_9_D4A_50:     /* set %d1 */
    movel %a0@(12),%d1
    jbeq rsrc_drvr_9_D4A_5C
    moveal %d1,%a1
    tstw %d0
    jsr %a1@
rsrc_drvr_9_D4A_5C:     /* result 0 */
    moveq #0,%d0
    rts
rsrc_drvr_9_D4A_60:     /* subtract 1 to %d2 */
    subqw #1,%d2
    jbpl rsrc_drvr_9_D4A_6
rsrc_drvr_9_D4A_64:     /* set %d0 */
    movew #-1102,%d0
    rts
    .byte   0x24, 0x0D, 0x0C, 0x6D, 0x00, 0xFD, 0x00, 0x1A, 0x67, 0x24, 0x76, 0x04, 0x4E, 0xAC, 0x00, 0x02	| 408DE164
    .byte   0x66, 0x2C, 0x10, 0x23, 0x26, 0x6A, 0x02, 0xA8, 0x20, 0x42, 0x11, 0x40, 0x00, 0x26, 0xB0, 0x28	| 408DE174
    .byte   0x00, 0x25, 0x67, 0x00, 0xFF, 0x70, 0x30, 0x3C, 0xFB, 0xFE, 0x60, 0x00, 0xFF, 0x6A, 0x4E, 0xAC	| 408DE184
    .byte   0x00, 0x02, 0x66, 0x0A, 0x20, 0x42, 0x30, 0x3C, 0xFB, 0xFD, 0x60, 0x00, 0xFF, 0x5A, 0x4E, 0x75	| 408DE194
    .byte   0x42, 0x43, 0x4E, 0xEC, 0x00, 0x02, 0x76, 0x02, 0x4E, 0x94, 0x66, 0xF2, 0x2A, 0x6A, 0x02, 0xA8	| 408DE1A4
    .byte   0x4B, 0xED, 0x00, 0x0C, 0x74, 0x09, 0x10, 0x23, 0x67, 0xE6, 0xB0, 0x25, 0x57, 0xCA, 0xFF, 0xFC	| 408DE1B4
    .byte   0x66, 0xDE, 0x9A, 0xC2, 0xC4, 0xFC, 0x00, 0x12, 0x4B, 0xED, 0x00, 0x0A, 0x2A, 0x75, 0x20, 0x00	| 408DE1C4
    .byte   0x14, 0x23, 0x0C, 0x6D, 0x00, 0xFB, 0x00, 0x1A, 0x66, 0x86, 0x26, 0x78, 0x02, 0xDC, 0xBB, 0xEB	| 408DE1D4
    .byte   0x00, 0x08, 0x67, 0xBC, 0x26, 0x55, 0x36, 0x2D, 0x00, 0x12, 0x2F, 0x0D, 0x4E, 0xAC, 0x00, 0x02	| 408DE1E4
    .byte   0x22, 0x5F, 0x66, 0xAA, 0x04, 0x02, 0x00, 0x30, 0x6F, 0xA4, 0x0C, 0x02, 0x00, 0x0F, 0x6E, 0x9E	| 408DE1F4
    .byte   0x20, 0x6A, 0x02, 0xA8, 0x41, 0xE8, 0x00, 0xC0, 0x72, 0x09, 0x90, 0xFC, 0x00, 0x12, 0xB3, 0xD0	| 408DE204
    .byte   0x57, 0xC9, 0xFF, 0xF8, 0x66, 0x10, 0x72, 0x00, 0x12, 0x29, 0x00, 0x1C, 0xE7, 0x49, 0x02, 0x41	| 408DE214
    .byte   0x03, 0xFF, 0x31, 0x41, 0x00, 0x0E, 0x22, 0x0B, 0x26, 0x6A, 0x02, 0xA8, 0x42, 0x40, 0x4A, 0x43	| 408DE224
    .byte   0x6A, 0x50, 0x42, 0x42, 0x20, 0x51, 0x5A, 0x48, 0xB2, 0x88, 0x6F, 0x40, 0x10, 0x18, 0x67, 0x00	| 408DE234
    .byte   0xFF, 0x5E, 0x0C, 0x00, 0x00, 0x20, 0x62, 0x00, 0xFF, 0x56, 0xD0, 0xC0, 0xB2, 0x88, 0x6F, 0x2C	| 408DE244
    .byte   0x10, 0x18, 0x67, 0x00, 0xFF, 0x4A, 0x0C, 0x00, 0x00, 0x20, 0x62, 0x00, 0xFF, 0x42, 0xD0, 0xC0	| 408DE254
    .byte   0xB2, 0x88, 0x6F, 0x18, 0x10, 0x18, 0x67, 0x00, 0xFF, 0x36, 0x0C, 0x00, 0x00, 0x20, 0x62, 0x00	| 408DE264
    .byte   0xFF, 0x2E, 0xD0, 0xC0, 0xB2, 0x88, 0x6D, 0x04, 0x52, 0x42, 0x60, 0xBA, 0x4A, 0x42, 0x67, 0x00	| 408DE274
    .byte   0xFF, 0x1E, 0x48, 0xE7, 0x08, 0x2E, 0x42, 0x41, 0x26, 0x29, 0x00, 0x22, 0x2A, 0x51, 0x2C, 0x4D	| 408DE284
    .byte   0x28, 0x0A, 0x28, 0x43, 0xB9, 0xD1, 0x67, 0x00, 0x00, 0xA2, 0x24, 0x44, 0x20, 0x2A, 0x04, 0x10	| 408DE294
    .byte   0x66, 0x2A, 0x20, 0x4C, 0x24, 0x4D, 0x2F, 0x01, 0x70, 0x00, 0x22, 0x00, 0x10, 0x18, 0x48, 0x40	| 408DE2A4
    .byte   0x10, 0x18, 0x12, 0x1A, 0x48, 0x41, 0x12, 0x1A, 0xB2, 0x80, 0x67, 0x0C, 0x4A, 0x81, 0x67, 0x08	| 408DE2B4
    .byte   0x22, 0x1F, 0x4A, 0x80, 0x66, 0x5E, 0x60, 0x4E, 0x22, 0x1F, 0x60, 0x4A, 0x20, 0x4C, 0x48, 0xE7	| 408DE2C4
    .byte   0xF0, 0x00, 0x34, 0x2A, 0x00, 0x1A, 0x24, 0x4D, 0x12, 0x1A, 0xE1, 0x49, 0x12, 0x1A, 0x16, 0x18	| 408DE2D4
    .byte   0xE1, 0x4B, 0x16, 0x18, 0x2F, 0x08, 0x20, 0x44, 0x20, 0x68, 0x04, 0x10, 0x70, 0x07, 0x4E, 0x90	| 408DE2E4
    .byte   0x4A, 0x40, 0x66, 0x14, 0x4A, 0x41, 0x66, 0x04, 0x32, 0x02, 0x67, 0x14, 0x4A, 0x43, 0x66, 0x04	| 408DE2F4
    .byte   0x36, 0x02, 0x67, 0x0C, 0xB2, 0x43, 0x67, 0x08, 0x20, 0x5F, 0x4C, 0xDF, 0x00, 0x0F, 0x60, 0x14	| 408DE304
    .byte   0x20, 0x5F, 0x4C, 0xDF, 0x00, 0x0F, 0xB5, 0x08, 0x66, 0x0A, 0xB5, 0x08, 0x66, 0x06, 0xB5, 0x08	| 408DE314
    .byte   0x67, 0x00, 0x00, 0xB6, 0x5A, 0x4C, 0x70, 0x00, 0x10, 0x14, 0xD0, 0x34, 0x00, 0x01, 0xD0, 0x34	| 408DE324
    .byte   0x00, 0x02, 0x56, 0x40, 0xD8, 0xC0, 0x60, 0x00, 0xFF, 0x5C, 0x4A, 0x2D, 0x00, 0x05, 0x67, 0x00	| 408DE334
    .byte   0x00, 0x92, 0x0C, 0x2D, 0x00, 0x20, 0x00, 0x05, 0x62, 0x00, 0x00, 0x88, 0x10, 0x2D, 0x00, 0x05	| 408DE344
    .byte   0x4A, 0x35, 0x00, 0x06, 0x67, 0x7C, 0x0C, 0x35, 0x00, 0x20, 0x00, 0x06, 0x62, 0x74, 0xD0, 0x35	| 408DE354
    .byte   0x00, 0x06, 0x4A, 0x35, 0x00, 0x07, 0x67, 0x6A, 0x0C, 0x35, 0x00, 0x20, 0x00, 0x07, 0x62, 0x62	| 408DE364
    .byte   0xD0, 0x35, 0x00, 0x07, 0x50, 0x40, 0x20, 0x4D, 0xDA, 0xC0, 0xBD, 0xC8, 0x66, 0x04, 0x2C, 0x4D	| 408DE374
    .byte   0x60, 0x0A, 0x2F, 0x09, 0x22, 0x4E, 0xDC, 0xC0, 0xA0, 0x2E, 0x22, 0x5F, 0x52, 0x41, 0x53, 0x02	| 408DE384
    .byte   0x66, 0x00, 0xFF, 0x00, 0x22, 0x8E, 0x9D, 0xE9, 0x00, 0x22, 0x30, 0x29, 0x00, 0x26, 0x90, 0x4E	| 408DE394
    .byte   0x4C, 0xDF, 0x74, 0x10, 0x20, 0x49, 0xD2, 0x69, 0x00, 0x2A, 0x33, 0x41, 0x00, 0x2A, 0xB2, 0x69	| 408DE3A4
    .byte   0x00, 0x28, 0x6A, 0x06, 0x33, 0x40, 0x00, 0x12, 0x66, 0x16, 0x26, 0x78, 0x02, 0xDC, 0x08, 0x2B	| 408DE3B4
    .byte   0x00, 0x07, 0x00, 0x05, 0x67, 0x00, 0xFD, 0x2E, 0xB3, 0xEB, 0x00, 0x08, 0x66, 0x00, 0xFD, 0x26	| 408DE3C4
    .byte   0x4E, 0x75, 0x4C, 0xDF, 0x74, 0x10, 0x4E, 0x75, 0x5A, 0x4D, 0x4A, 0x15, 0x67, 0xF4, 0x0C, 0x15	| 408DE3D4
    .byte   0x00, 0x20, 0x62, 0xEE, 0x10, 0x15, 0x4A, 0x35, 0x00, 0x01, 0x67, 0xE6, 0x0C, 0x35, 0x00, 0x20	| 408DE3E4
    .byte   0x00, 0x01, 0x62, 0xDE, 0xD0, 0x35, 0x00, 0x01, 0x4A, 0x35, 0x00, 0x02, 0x67, 0xD4, 0x0C, 0x35	| 408DE3F4
    .byte   0x00, 0x20, 0x00, 0x02, 0x62, 0xCC, 0xD0, 0x35, 0x00, 0x02, 0x56, 0x40, 0xDA, 0xC0, 0x60, 0x00	| 408DE404
    .byte   0xFF, 0x7E	| 408DE414
rsrc_drvr_9_1066:       /* continue at rsrc_drvr_9_10D2 */
    jbra rsrc_drvr_9_10D2	| 408DE416
    .byte   0x60, 0x6A, 0x26, 0x6A, 0x02, 0xB4, 0x4A, 0x5B, 0x66, 0x54, 0x76, 0x7C, 0x4E, 0xAC, 0x00, 0x02	| 408DE418
    .byte   0x66, 0x4A, 0x20, 0x6A, 0x02, 0xB4, 0x4A, 0x2A, 0x02, 0xB8, 0x66, 0x12, 0x10, 0x28, 0x00, 0x06	| 408DE428
    .byte   0xB0, 0x12, 0x66, 0x0A, 0x30, 0x28, 0x00, 0x04, 0xB0, 0x6A, 0x00, 0x1A, 0x67, 0x2E, 0x30, 0xBC	| 408DE438
    .byte   0x00, 0xF2, 0x40, 0xC0, 0x02, 0x40, 0xF8, 0xFF, 0x0A, 0x40, 0x20, 0x00, 0x3F, 0x2A, 0x00, 0x1C	| 408DE448
    .byte   0xB1, 0x57, 0x46, 0xDF, 0x90, 0xFC, 0x00, 0x1A, 0x43, 0xFA, 0x00, 0x1A, 0x21, 0x49, 0x00, 0x0C	| 408DE458
    .byte   0x22, 0x78, 0x02, 0xDC, 0x31, 0x69, 0x00, 0x18, 0x00, 0x18, 0xA4, 0x04, 0x4E, 0x75, 0x42, 0x43	| 408DE468
    .byte   0x4E, 0xEC, 0x00, 0x02, 0x42, 0x68, 0x00, 0x1A, 0x4E, 0x75	| 408DE478
rsrc_drvr_9_10D2:       /* continue at rsrc_drvr_9_10FA */
    jbra rsrc_drvr_9_10FA	| 408DE482
    .byte   0x47, 0xEA, 0x02, 0xB0, 0x20, 0x78, 0x02, 0xA6, 0x20, 0x13, 0x67, 0x16, 0xA0, 0x55, 0x22, 0x40	| 408DE484
    .byte   0xB3, 0xD0, 0x65, 0x0A, 0xB3, 0xF8, 0x01, 0x0C, 0x64, 0x04, 0x26, 0x91, 0x60, 0xEA, 0x26, 0x49	| 408DE494
    .byte   0x60, 0xE6, 0x70, 0x00, 0x4E, 0x75	| 408DE4A4
rsrc_drvr_9_10FA:       /* set %d3 */
    movel %a2@(688),%d3	| 408DE4AA
    jbeq rsrc_drvr_9_1258	| 408DE4AE
    movew %sr,%sp@-	| 408DE4B2
    movew %sr,%d0	| 408DE4B4
    andiw #-1793,%d0	| 408DE4B6
    eoriw #8192,%d0	| 408DE4BA
    movew %a2@(28),%sp@-	| 408DE4BE
    eorw %d0,%sp@	| 408DE4C2
    movew %sp@+,%sr	| 408DE4C4
    moveml %a2/%a4-%a5,%sp@-	| 408DE4C6
    moveal %a0,%a4	| 408DE4CA
    tstb %a2@(25)
    jbeq rsrc_drvr_9_1150
    tstw %a2@(832)
    jbpl rsrc_drvr_9_1150
    moveq #0,%d0
    lea %a4@(35),%a0
    moveb %a0@+,%d0
    addaw %d0,%a0
    moveb %a0@+,%d0
    addaw %d0,%a0
    cmpib #1,%a0@
    jbne rsrc_drvr_9_1144
    cmpib #42,%a0@(1)
    jbeq rsrc_drvr_9_1150
rsrc_drvr_9_1144:       /* address %a2@(854) */
    lea %a2@(854),%a1
    jbsr rsrc_drvr_9_1290
    jbne rsrc_drvr_9_1252
rsrc_drvr_9_1150:       /* set %d2 */
    movel %d3,%d2
    clrw %d3
rsrc_drvr_9_1154:       /* loop: movea */
    moveal %d2,%a3
    lea %a3@(9),%a3
    lea %a4@(35),%a5
    moveal %a3,%a1
    moveal %a5,%a0
    jbsr rsrc_drvr_9_12AA
    jbne rsrc_drvr_9_1180
    clrw %d0
    moveb %a5@+,%d0
    addaw %d0,%a5
    moveal %a3,%a1
    moveb %a1@+,%d0
    addaw %d0,%a1
    moveal %a5,%a0
    jbsr rsrc_drvr_9_12AA
    jbne rsrc_drvr_9_1180
    movel %a3,%sp@-
    addqw #1,%d3
rsrc_drvr_9_1180:       /* set %d2 */
    movel %a3@(-9),%d2
    jbne rsrc_drvr_9_1154
    tstw %d3
    jbeq rsrc_drvr_9_1252
    lea %a4@(31),%a1
    lea %a4@(30),%a5
    movew %a5@+,%a1@(7)
    moveb %a5@+,%a1@(11)
    moveb %a5@+,%a1@(13)
    moveb #2,%a1@(15)
    movel %a1,%a4@(50)
    moveal ABusVars,%a2
    moveb %a4@(30),%a4@(38)
    clrw %d2
    clrw %d1
    lea %a4@(54),%a3
    lea %a4@(28),%a1
    movew #2,%a3@+
    movel %a1,%a3@+
rsrc_drvr_9_11C6:       /* loop: movea */
    moveal %sp@,%a5
    clrw %d0
    moveb %a5@,%d0
    addb %a5@(0x1,%d0:w),%d0
    moveb #1,%a5@(0x2,%d0:w)
    moveb #42,%a5@(0x3,%d0:w)
    addiw #9,%d0
    addw %d0,%d2
    cmpiw #584,%d2
    jbgt rsrc_drvr_9_1200
    addqw #4,%sp
    movew %d0,%a3@+
    subqw #5,%a5
    movel %a5,%a3@+
    movew %a2@(26),%a5@
    addqw #1,%d1
    subqw #1,%d3
    jbeq rsrc_drvr_9_1200
    cmpiw #15,%d1
    jbne rsrc_drvr_9_11C6
rsrc_drvr_9_1200:       /* clear %a3@+ */
    clrw %a3@+
    oriw #48,%d1
    moveb %d1,%a1@
    movew %d3,%d2
    jbeq rsrc_drvr_9_123C
    moveal %sp@,%a0
    lea %a0@(-9),%a0
    moveal %a0,%a5
    oriw #1792,%sr
    andiw #-257,%sr
    tstl %a0@
    jbeq rsrc_drvr_9_1238
    movel %a4,%sp@-
    moveal %a2@(688),%a4
    movel %a0@,%a2@(688)
rsrc_drvr_9_122A:       /* loop: tst */
    tstl %a0@
    jbeq rsrc_drvr_9_1232
    moveal %a0@,%a0
    jbra rsrc_drvr_9_122A
rsrc_drvr_9_1232:       /* set %a0@ */
    movel %a4,%a0@
    clrl %a5@
    moveal %sp@+,%a4
rsrc_drvr_9_1238:       /* from here: aslw #2,%d2 */
    aslw #2,%d2
    addaw %d2,%sp
rsrc_drvr_9_123C:       /* address %a4@(48) */
    lea %a4@(48),%a1
    moveml %sp@+,%a2/%a4-%a5
    movew %sp@+,%sr
    moveb #2,%d1
    moveq #0,%d3
    jsr %pc@(thunk_FUN_408dd652)
    jbra rsrc_drvr_9_1258
rsrc_drvr_9_1252:       /* restore registers */
    moveml %sp@+,%a2/%a4-%a5
    movew %sp@+,%sr
rsrc_drvr_9_1258:       /* set %a0 */
    moveal JIODone,%a0
    moveal ABusVars_dce,%a1
    moveq #0,%d0
    jmp %a0@
    moveq #2,%d1
    lea %a4@(48),%a1
    moveal %a2@(684),%a0
    moveq #0,%d3
    jsr %a0@
    moveal %a2@(692),%a0
    st %a0@(21)
    rts

/* subroutine (8 instructions) (mechanical summary) */
rsrc_drvr_9_127C:
    moveq #2,%d0
    addb %a1@,%d0
    addb %a1@(0xffffffffffffffff,%d0:w),%d0
    movew %d0,%d1
    swap %d0
    movew %d1,%d0
    lea %a0@(9),%a0
    jbra rsrc_drvr_9_1298

/* subroutine (4 instructions) (mechanical summary) */
rsrc_drvr_9_1290:
    moveq #0,%d0
    moveb %a0@+,%d0
    swap %d0
    moveb %a1@+,%d0

/* subroutine (4 instructions) (mechanical summary) */
rsrc_drvr_9_1298:
    movew #-24516,%d1
    pea %pc@(rsrc_drvr_9_12A6)
    movel %a2@(904),%sp@-
    rts

/* subroutine (0 instructions) (mechanical summary) */
rsrc_drvr_9_12A6:
    .ascii  "J@Nu"

/* subroutine (58 instructions): calls rsrc_drvr_9_1298 (mechanical summary) */
rsrc_drvr_9_12AA:
    moveq #0,%d0	| 408DE65A
    moveq #0,%d2	| 408DE65C
    movel %a0,%d1	| 408DE65E
    moveb %a0@+,%d0	| 408DE660
    beqw rsrc_drvr_9_1334	| 408DE662
    subqw #1,%d0	| 408DE666
    jbne rsrc_drvr_9_12C0	| 408DE668
    cmpib #61,%a0@	| 408DE66A
    jbeq rsrc_drvr_9_1332	| 408DE66E
rsrc_drvr_9_12C0:       /* loop: addq */
    addqw #1,%d2	| 408DE670
    cmpib #0xc5,%a0@+	| 408DE672 408DE672 cmpib #-59,%a0@+
    dbeq %d0,rsrc_drvr_9_12C0	| 408DE676
    movew %sr,%sp@-	| 408DE67A
    moveal %d1,%a0	| 408DE67C
    moveb %a0@,%d1	| 408DE67E
    movew %sp@+,%sr	| 408DE680
    jbeq rsrc_drvr_9_12DE	| 408DE682
    moveq #0,%d0	| 408DE684
    moveb %a0@+,%d0	| 408DE686
    swap %d0	| 408DE688
    moveb %a1@+,%d0	| 408DE68A
    jbra rsrc_drvr_9_132E	| 408DE68C
rsrc_drvr_9_12DE:       /* (data) */
    cmpib #1,%d2	| 408DE68E
    beqs rsrc_drvr_9_12DE+0x28
    moveq #0,%d0
    moveb %d2,%d0
    swap %d0
    moveb %d2,%d0
    subil #65537,%d0
    addqw #1,%a0
    addqw #1,%a1
    moveml %d1-%d2/%a0-%a1,%sp@-
    jbsr rsrc_drvr_9_1298
    moveml %sp@+,%d1-%d2/%a0-%a1
    jbne rsrc_drvr_9_1332
    subqw #1,%a0
    subqw #1,%a1
    cmpb %d1,%d2
    jbeq rsrc_drvr_9_1332
    moveq #0,%d0
    moveb %d2,%d0
    subqb #1,%d0
    cmpb %a1@,%d0
    jbcc rsrc_drvr_9_1334
    subb %d2,%d1
    moveb %a1@,%d0
    subb %d1,%d0
    jbcs rsrc_drvr_9_1334
    addaw %d0,%a1
    moveb %a0@,%d0
    subb %d1,%d0
    addaw %d0,%a0
    moveb %d1,%d0
    swap %d0
    moveb %d1,%d0
    addqw #1,%a0
    addqw #1,%a1
rsrc_drvr_9_132E:       /* continue at rsrc_drvr_9_1298 */
    jbra rsrc_drvr_9_1298
rsrc_drvr_9_1332:       /* return */
    rts
rsrc_drvr_9_1334:       /* set %ccr */
    movew #0,%ccr
    rts

/* subroutine (11 instructions): traps NewPtr (mechanical summary) */
rsrc_drvr_9_133A:
    movel #130,%d0
    .short  0xA71E	| 408DE6F0 _NewPtr (flags 0x0700)
    jbne rsrc_drvr_9_1366
    movel %a0,%a2@(896)
    lea %a0@(106),%a0
    movel %a0,%a2@(934)
    lea %pc@(rsrc_drvr_9_1388),%a0
    movel %a0,%a2@(134)
    pea %pc@(rsrc_drvr_9_1368)
    movel %sp@+,%a2@(892)
    moveb #6,%a2@(87)
rsrc_drvr_9_1366:       /* return */
    rts

/* subroutine (145 instructions): traps BlockMove, WriteXPRam; calls rsrc_drvr_9_1290, rsrc_drvr_9_2E04 (mechanical summary) */
rsrc_drvr_9_1368:
    movel %a2@(896),%d2	| 408DE718
    jbeq rsrc_drvr_9_1386	| 408DE71C
    tstw %a2@(832)	| 408DE71E
    jbpl rsrc_drvr_9_1386	| 408DE722
    moveal %d2,%a1	| 408DE724
    bset #7,%a2@(900)	| 408DE726
    jbne rsrc_drvr_9_1386	| 408DE72C
    moveq #79,%d0	| 408DE72E
    _BlockMove	| 408DE730 408DE730 A-line trap
    moveal %d2,%a3	| 408DE732
    jbra rsrc_drvr_9_13B2	| 408DE734
rsrc_drvr_9_1386:       /* return */
    rts	| 408DE736
rsrc_drvr_9_1388:       /* subtract 6 to %a3@- */
    subqb #6,%a3@-	| 408DE738
    jbne rsrc_drvr_9_13A0	| 408DE73A
    tstw %a2@(832)	| 408DE73C
    jbpl rsrc_drvr_9_13A0	| 408DE740
    movel %a2@(896),%d2	| 408DE742
    jbeq rsrc_drvr_9_13A0	| 408DE746
    bset #7,%a2@(900)	| 408DE748
    jbeq rsrc_drvr_9_13A4	| 408DE74E
rsrc_drvr_9_13A0:       /* continue at rsrc_drvr_9_492 */
    jbra rsrc_drvr_9_492	| 408DE750
rsrc_drvr_9_13A4:       /* set %a3 */
    moveal %d2,%a3	| 408DE754
    moveq #79,%d3	| 408DE756
    jsr %a4@(2)	| 408DE758
    jbne rsrc_drvr_9_142A	| 408DE75C
    moveal %d2,%a3	| 408DE75E
    subqb #6,%a3@	| 408DE760
rsrc_drvr_9_13B2:       /* set %d3 */
    movel %a2@(830),%d3	| 408DE762
    tstb %a3@	| 408DE766
    jbmi rsrc_drvr_9_142A	| 408DE768
    cmpib #1,%a3@	| 408DE76A
    jbgt rsrc_drvr_9_142A	| 408DE76E
    lea %a3@(6),%a0	| 408DE770
    cmpib #32,%a0@	| 408DE774
    jbhi rsrc_drvr_9_142A	| 408DE778
    movew %a3@(2),%d0	| 408DE77A
    cmpw %a3@(4),%d0	| 408DE77E
    jbhi rsrc_drvr_9_142A	| 408DE782
    cmpiw #-256,%a3@(4)	| 408DE784
    jbcc rsrc_drvr_9_142A	| 408DE78A
    lea %a2@(854),%a1	| 408DE78C
    movel %a2@(930),%d1	| 408DE790
    jbeq rsrc_drvr_9_13EC	| 408DE794
    moveal %d1,%a1	| 408DE796
    moveal %a1@(30),%a1	| 408DE798
rsrc_drvr_9_13EC:       /* call rsrc_drvr_9_1290 */
    jbsr rsrc_drvr_9_1290	| 408DE79C
    jbne rsrc_drvr_9_142A	| 408DE7A0
    movew %a3@(2),%a2@(840)	| 408DE7A2
    movew %a3@(4),%a2@(842)	| 408DE7A8
    btst #13,%d3	| 408DE7AE
    jbeq rsrc_drvr_9_142A	| 408DE7B2
    tstb %a3@	| 408DE7B4
    jbeq rsrc_drvr_9_1412	| 408DE7B6
    btst #4,%a2@(900)	| 408DE7B8
    jbne rsrc_drvr_9_1432	| 408DE7BE
    jbra rsrc_drvr_9_142A	| 408DE7C0
rsrc_drvr_9_1412:       /* clear bit 5 of %a2@(900) */
    bclr #5,%a2@(900)	| 408DE7C2
    jbeq rsrc_drvr_9_1518	| 408DE7C8
    btst #11,%d3	| 408DE7CC
    jbeq rsrc_drvr_9_1432	| 408DE7D0
    cmpiw #-256,%a2@(26)	| 408DE7D2
    jbcs rsrc_drvr_9_1432	| 408DE7D8
rsrc_drvr_9_142A:       /* loop: bclr */
    bclr #7,%a2@(900)	| 408DE7DA
    rts	| 408DE7E0
rsrc_drvr_9_1432:       /* clear bit 6 of %a2@(833) */
    bclr #6,%a2@(833)	| 408DE7E2
    btst #5,%a3@(1)	| 408DE7E8
    jbeq rsrc_drvr_9_1446	| 408DE7EE
    bset #6,%a2@(833)	| 408DE7F0
rsrc_drvr_9_1446:       /* clear bit 7 of %a2@(833) */
    bclr #7,%a2@(833)	| 408DE7F6
    btst #7,%a3@(1)	| 408DE7FC
    jbeq rsrc_drvr_9_145A	| 408DE802
    bset #7,%a2@(833)	| 408DE804
rsrc_drvr_9_145A:       /* test bit 6 of %a3@(1) */
    btst #6,%a3@(1)	| 408DE80A
    jbne rsrc_drvr_9_1496	| 408DE810
    moveq #6,%d0	| 408DE812
    lea %a2@(844),%a1	| 408DE814
    moveal %a2@(888),%a0	| 408DE818
    jsr %a0@(2)	| 408DE81C
    moveq #0,%d0	| 408DE820
    lea %a3@(6),%a0	| 408DE822
    moveb %a0@+,%d0	| 408DE826
    addaw %d0,%a0	| 408DE828
    moveb %a0@+,%d0	| 408DE82A
    cmpb %a2@(851),%d0	| 408DE82C
    jbne rsrc_drvr_9_142A	| 408DE830
    lea %a2@(844),%a1	| 408DE832
    _BlockMove	| 408DE836 408DE836 A-line trap
    moveq #5,%d0	| 408DE838
    lea %a2@(844),%a1	| 408DE83A
    moveal %a2@(888),%a0	| 408DE83E
    jsr %a0@(2)	| 408DE842
rsrc_drvr_9_1496:       /* clear %d0 */
    moveq #0,%d0	| 408DE846
    lea %a3@(6),%a0	| 408DE848
    btst #7,%a2@(833)	| 408DE84C
    jbne rsrc_drvr_9_14AE	| 408DE852
    tstl %a2@(930)	| 408DE854
    jbne rsrc_drvr_9_14B6	| 408DE858
    tstb %a3@	| 408DE85A
    jbeq rsrc_drvr_9_14E4	| 408DE85C
rsrc_drvr_9_14AE:       /* set %d0 */
    moveb %a0@+,%d0	| 408DE85E
    addaw %d0,%a0	| 408DE860
    moveb %a0@+,%d0	| 408DE862
    addaw %d0,%a0	| 408DE864
rsrc_drvr_9_14B6:       /* test bit 30 of %d3 */
    btst #30,%d3	| 408DE866
    jbeq rsrc_drvr_9_14C2	| 408DE86A
    btst #11,%d3	| 408DE86C
    jbeq rsrc_drvr_9_14E4	| 408DE870
rsrc_drvr_9_14C2:       /* set %d0 */
    moveb %a0@,%d0	| 408DE872
    addqw #1,%d0	| 408DE874
    lea %a2@(854),%a1	| 408DE876
    _BlockMove	| 408DE87A 408DE87A A-line trap
    lea %a2@(854),%a0	| 408DE87C
    movel %a2@(1040),%d0	| 408DE880
    jbeq rsrc_drvr_9_14DC	| 408DE884
    moveal %d0,%a1	| 408DE886
    moveq #4,%d0	| 408DE888
    jsr %a1@	| 408DE88A
rsrc_drvr_9_14DC:       /* set %d0 */
    movel #2162877,%d0	| 408DE88C
    _WriteXPRam	| 408DE892 408DE892 A-line trap
rsrc_drvr_9_14E4:
    tstb %a3@	| 408DE894
    jbne rsrc_drvr_9_1510	| 408DE896
    btst #30,%d3	| 408DE898
    jbeq rsrc_drvr_9_14F4	| 408DE89C
    btst #11,%d3	| 408DE89E
    jbeq rsrc_drvr_9_1518	| 408DE8A2
rsrc_drvr_9_14F4:       /* clear %d0 */
    moveq #0,%d0	| 408DE8A4
    movew %a2@(10),%d0	| 408DE8A6
    lsll #8,%d0	| 408DE8AA
    moveb %a2@(13),%d0	| 408DE8AC
    movel %d0,%a2@(826)	| 408DE8B0
    moveb #0xfe,%a2@(25)	| 408DE8B4 408DE8B4 moveb #-2,%a2@(25)
    moveb #0x96,%a2@(720)	| 408DE8BA moveb #-106,%a2@(720)
rsrc_drvr_9_1510:
    st %a2@(850)	| 408DE8C0
    jbsr rsrc_drvr_9_2E04	| 408DE8C4
rsrc_drvr_9_1518:       /* clear bit 7 of %a2@(900) */
    bclr #7,%a2@(900)	| 408DE8C8
    movew %sr,%d0	| 408DE8CE
    andiw #-1793,%d0	| 408DE8D0
    eoriw #8192,%d0	| 408DE8D4
    movew %a2@(28),%sp@-	| 408DE8D8
    eorw %d0,%sp@	| 408DE8DC
    movew %sp@+,%sr	| 408DE8DE
    moveq #0,%d0	| 408DE8E0
    movel %a2@(930),%d1	| 408DE8E2
    jbeq rsrc_drvr_9_153E	| 408DE8E6
    moveal %d1,%a0	| 408DE8E8
    jbra rsrc_drvr_9_D4A	| 408DE8EA
rsrc_drvr_9_153E:       /* return */
    rts	| 408DE8EE

/* Control csCode 257: csCode 257 (name not known). */
MPP_cs257:
    moveq #-1,%d0	| 408DE8F0
    moveb %a1@,%d1	| 408DE8F2
    cmpib #33,%d1	| 408DE8F4
    jbcs MPP_cs257_C	| 408DE8F8
    clrb %a1@	| 408DE8FA
MPP_cs257_C:            /* set %d1 */
    moveq #3,%d1	| 408DE8FC
    moveb %d1,%a0@(28)	| 408DE8FE
    moveb %d1,%a0@(29)	| 408DE902
    jbra MPP_LookupName_4	| 408DE906

/* subroutine (24 instructions) (mechanical summary) */
rsrc_drvr_9_155A:
    moveal %a3@(0xc,%d2:w),%a0
    movel %a1,%d0
    lea %a3@(296),%a1
    lea %a3@(321),%a0
    movel %a0,%a1@+
    moveq #6,%d1
    moveb %d1,%a0@(13)
    st %a0@(11)
    clrw %a0@(7)
    moveb %d1,%a0@(15)
    movew #6,%a1@+
    lea %a3@(314),%a0
    movel %a0,%a1@+
    moveb #5,%a0@+
    clrb %a0@+
    clrl %a0@+
    moveal %d0,%a0
    moveq #1,%d0
    addb %a0@,%d0
    movew %d0,%a1@+
    movel %a0,%a1@+
    clrw %a1@
    bset #5,%a2@(900)
    rts

/* subroutine (94 instructions): traps BlockMove, trap_A404; calls rsrc_drvr_9_2508, rsrc_drvr_9_28E (mechanical summary) */
rsrc_drvr_9_15A2:
    moveml %d2-%d7/%a2-%fp,%sp@-
    moveal %sp@(48),%a2
    clrw %sp@-
    subqw #4,%sp
    movew #56,%sp@-
    moveal %sp,%a3
    subaw #56,%sp
    lea %sp@(1),%a1
    movel %a1,%a3@(2)
    st %a1@+
    moveb %a2@,%a1@+
    moveb #2,%a1@+
    moveal %a1,%a4
    movew #53,%a1@+
    clrl %a1@+
    movew %a2@(26),%a1@+
    st %a1@+
    moveb %a2@,%a1@+
    movew #1542,%a1@+
    moveb #6,%a1@+
    moveb #5,%a1@+
    clrw %a1@+
    clrw %a1@+
    clrb %a1@+
    lea %a2@(854),%a0
    moveq #1,%d0
    addb %a0@,%d0
    movew %d0,%d1
    _BlockMove
    moveq #34,%d0
    subw %d1,%d0
    subw %d0,%a3@
    subw %d0,%a4@
    moveal %a3,%a1
    moveq #0,%d2
    st %d2
    bset #5,%a2@(900)	| 408DE9B4
    jbsr rsrc_drvr_9_2508
rsrc_drvr_9_15A2_6C:    /* loop: tst */
    tstb %a2@(712)
    jbeq rsrc_drvr_9_15A2_6C
    lea %sp@(64),%sp
    moveml %sp@+,%d2-%d7/%a2-%fp
    rts
rsrc_drvr_9_161E:       /* test #4,%a3@- */
    cmpib #4,%a3@-	| 408DE9CE
    jbne rsrc_drvr_9_1640	| 408DE9D2
    movel %a3,%d2	| 408DE9D4
    moveal %a2@(146),%a3	| 408DE9D6
    tstw %a3@(16)	| 408DE9DA
    jbgt rsrc_drvr_9_1640	| 408DE9DE
    movew #586,%d3	| 408DE9E0
    lea %a3@(65),%a3	| 408DE9E4
    jsr %a4@(2)	| 408DE9E8
    jbeq rsrc_drvr_9_1646	| 408DE9EC
    rts	| 408DE9EE
rsrc_drvr_9_1640:       /* clear %d3 */
    clrw %d3	| 408DE9F0
    jmp %a4@(2)	| 408DE9F2
rsrc_drvr_9_1646:       /* set %d0 */
    movew #586,%d0	| 408DE9F6
    subw %d3,%d0	| 408DE9FA
    jbeq rsrc_drvr_9_16B8	| 408DE9FC
    moveal %a2@(146),%a0	| 408DE9FE
    cmpib #1,%a0@(65)	| 408DEA02
    jbne rsrc_drvr_9_16B8	| 408DEA08
    movew %d0,%a0@(40)	| 408DEA0A
    moveal %d2,%a3	| 408DEA0E
    moveb %a3@-,%a0@(62)	| 408DEA10
    moveb %a2@(2),%d0	| 408DEA14
    moveq #0,%d1	| 408DEA18
    subqb #1,%a2@(3)	| 408DEA1A
    jbeq rsrc_drvr_9_16AA	| 408DEA1E
    moveal %a0,%a1	| 408DEA20
    lea %a2@(6),%a0	| 408DEA22
    movew %a0@+,%d1	| 408DEA26
    sne %a1@(29)	| 408DEA28
    jbeq rsrc_drvr_9_16A0	| 408DEA2C
    movew %d1,%sp@-	| 408DEA2E
    moveq #9,%d0	| 408DEA30
    clrw %d3	| 408DEA32
    clrw %d1	| 408DEA34
    jbsr rsrc_drvr_9_28E	| 408DEA36
    lea %a1@(65),%a0	| 408DEA3A
    movew %a1@(40),%d0	| 408DEA3E
    jbsr rsrc_drvr_9_28E	| 408DEA42
    tstw %d3	| 408DEA46
    jbne rsrc_drvr_9_169C	| 408DEA48
    subqw #1,%d3	| 408DEA4A
rsrc_drvr_9_169C:       /* test %sp@+,%d3 */
    cmpw %sp@+,%d3	| 408DEA4C
    jbne rsrc_drvr_9_16B8	| 408DEA4E
rsrc_drvr_9_16A0:       /* set %a0 */
    moveal %a1,%a0	| 408DEA50
    moveb %a3@(-2),%d0	| 408DEA52
    movew %a3@(-5),%d1	| 408DEA56
rsrc_drvr_9_16AA:       /* set %a0@(60) */
    moveb %d0,%a0@(60)	| 408DEA5A
    movew %d1,%a0@(56)	| 408DEA5E
    addqb #1,%a0@(65)	| 408DEA62
    .short  0xA404	| 408DEA66 408DEA66 A-line trap
rsrc_drvr_9_16B8:
    rts	| 408DEA68

/* Control csCode 243: WriteLAP. */
MPP_WriteLAP:
    movel %a0@(34),%d3	| 408DEA6A
    moveal %a1@(2),%a0	| 408DEA6E
    moveq #-94,%d0	| 408DEA72
    tstb %a0@(2)	| 408DEA74
    jble rsrc_drvr_9_status_3A	| 408DEA78
    moveq #0,%d2	| 408DEA7A
    moveb %a0@,%d2	| 408DEA7C
    movel %a2@(830),%d1	| 408DEA7E
    btst #15,%d1	| 408DEA82
    jbeq MPP_WriteLAP_28	| 408DEA86
    moveq #-95,%d0	| 408DEA88
    btst #30,%d1	| 408DEA8A
    jbeq rsrc_drvr_9_status_3A	| 408DEA8E
    movel %d3,%d2	| 408DEA90
MPP_WriteLAP_28:        /* call rsrc_drvr_9_1768 */
    jbsr rsrc_drvr_9_1768	| 408DEA92
    jbra rsrc_drvr_9_status_3A	| 408DEA96

/* subroutine (34 instructions): traps DeferUserFn; calls rsrc_drvr_9_1A5A; low memory ABusVars, JIODone (mechanical summary) */
rsrc_drvr_9_status:
    moveal ABusVars,%a2
    btst #30,%a2@(830)
    jbeq rsrc_drvr_9_status_10
    moveq #-18,%d0
    jbra rsrc_drvr_9_status_3A
rsrc_drvr_9_status_10:  /* set %d0 */
    moveq #-18,%d0
    cmpiw #400,%a0@(26)
    jbne rsrc_drvr_9_status_3A
    moveal %a0@(28),%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    lea %a2@(976),%a3
    moveq #15,%d0
    moveq #0,%d1
rsrc_drvr_9_status_30:  /* loop: move */
    movel %a3@,%a1@+
    movel %d1,%a3@+
    dbf %d0,rsrc_drvr_9_status_30
    movew %sp@+,%sr
rsrc_drvr_9_status_3A:  /* loop: movea */
    moveal %a2@(816),%a1
rsrc_drvr_9_status_3E:  /* test %a2@(952) */
    tstw %a2@(952)
    jbeq rsrc_drvr_9_174C
    jbsr rsrc_drvr_9_1A5A
    movew %d0,%a2@(954)
    movel %a1,%d0
    lea %pc@(rsrc_drvr_9_173E),%a0
    _DeferUserFn
    rts
rsrc_drvr_9_173E:       /* call rsrc_drvr_9_1A5A */
    jbsr rsrc_drvr_9_1A5A	| 408DEAEE
    moveal ABusVars,%a1	| 408DEAF2
    movew %a1@(954),%d0	| 408DEAF6
    moveal %a0,%a1	| 408DEAFA
rsrc_drvr_9_174C:       /* set %sp@- */
    movel JIODone,%sp@-
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_drvr_9_prime:
    bclr #7,%a1@(5)
    rts
rsrc_drvr_9_prime_8:    /* loop: tst */
    tstb %a2@(712)
    jbne rsrc_drvr_9_1770_14
rsrc_drvr_9_prime_E:    /* loop: movea */
    moveal %a2@(702),%a0
    moveq #-95,%d0
    jmp %a0@

/* subroutine (2 instructions) (mechanical summary) */
rsrc_drvr_9_1768:
    clrb %a2@(712)
    movel %a1,%a2@(698)

/* subroutine (38 instructions): traps PMgrOp; calls rsrc_drvr_9_17E0; low memory HWCfgFlags, ATalkHk2 (mechanical summary) */
rsrc_drvr_9_1770:
    btst #8,HWCfgFlags
    jbeq rsrc_drvr_9_1770_A
    .short  0xA285	| 408DEB28 _PMgrOp (flags 0x0200)
rsrc_drvr_9_1770_A:     /* set %a2@(702) */
    movel %sp@+,%a2@(702)
    tstb %a2@(821)
    jbeq rsrc_drvr_9_prime_8
rsrc_drvr_9_1770_14:    /* set %d3 */
    movel ATalkHk2,%d3
    jble rsrc_drvr_9_1770_24
    moveal %d3,%a3
    clrw %d3
    moveb %a2@(820),%d3
    jsr %a3@
rsrc_drvr_9_1770_24:    /* loop: cmp */
    cmpb %a2@,%d2
    jbne rsrc_drvr_9_1770_38
    tstw %a2@(832)
    jbpl rsrc_drvr_9_1770_5A
    movel %d2,%d0
    lsrl #8,%d0
    cmpw %a2@(26),%d0
    jbeq rsrc_drvr_9_1770_5A
rsrc_drvr_9_1770_38:    /* test #0xff,%d2 */
    cmpib #0xff,%d2
    jbne rsrc_drvr_9_1770_4C
    tstb %a2@(696)
    jbeq rsrc_drvr_9_1770_46
    jbsr rsrc_drvr_9_17E0
rsrc_drvr_9_1770_46:    /* test %a2@(2596) */
    tstw %a2@(2596)
    jbeq rsrc_drvr_9_1770_62
rsrc_drvr_9_1770_4C:    /* set %a0 */
    moveal %a1@(2),%a0
    orib #0x80,%a0@(2)
    jbsr rsrc_drvr_9_17E0
    jbra rsrc_drvr_9_1770_62
rsrc_drvr_9_1770_5A:    /* test %a2@(696) */
    tstb %a2@(696)
    jbeq rsrc_drvr_9_1770_62
    jbsr rsrc_drvr_9_17E0
rsrc_drvr_9_1770_62:    /* set %a0 */
    moveal %a2@(702),%a0
    moveq #0,%d0
    jmp %a0@
rsrc_drvr_9_1770_6A:    /* loop: moveq */
    moveq #0,%d3
    jmp %a4@(2)

/* subroutine (71 instructions): calls rsrc_drvr_9_18B2 (mechanical summary) */
rsrc_drvr_9_17E0:
    moveml %d2/%a1-%a2/%a4-%a5,%sp@-
    movew %sr,%sp@-
    moveq #5,%d3
    lea %a2@(1),%a3
    subal %a0,%a0
    oriw #1792,%sr
    andiw #-257,%sr
    jbsr rsrc_drvr_9_18B2
    moveb %a2@,%a2@(2)
    moveq #7,%d3
    movew %a2@(2600),%d2
    swap %d2
    moveb %a2@(3),%d0
    jbpl rsrc_drvr_9_17E0_8A
    andib #127,%a2@(3)
    moveb #0x80,%d0
    cmpib #0xff,%a2@(1)
    jbne rsrc_drvr_9_17E0_8A
    movel %a5,%sp@-
    lea %a2@(1056),%a5
    movew %a2@(2592),%d1
    jbeq rsrc_drvr_9_1770_6A
    moveb %a2@(3),%d2
    lea %pc@(rsrc_drvr_9_17E0_B6),%a4
    jbra rsrc_drvr_9_17E0_80
rsrc_drvr_9_17E0_54:    /* loop: tst */
    tstl %a5@
    jbeq rsrc_drvr_9_17E0_80
    moveml %d1-%d2/%a0-%a2/%a4-%a5,%sp@-
    moveal %a5@,%a5
    jsr %a5@
    moveml %sp@+,%d1-%d2/%a0-%a2/%a4-%a5
    moveq #5,%d3
    lea %a2@(1),%a3
    subal %a0,%a0
    oriw #1792,%sr
    andiw #-257,%sr
    jbsr rsrc_drvr_9_18B2
    moveb %a2@,%a2@(2)
    andib #127,%a2@(3)
rsrc_drvr_9_17E0_80:    /* add 6 to %a5 */
    addql #6,%a5
    dbf %d1,rsrc_drvr_9_17E0_54
    moveal %sp@+,%a5
    jbra rsrc_drvr_9_17E0_AE
rsrc_drvr_9_17E0_8A:    /* set %d2 */
    moveb %a2@(3),%d2
    movew %a2@(4),%d1
    andiw #1023,%d1
    subqw #2,%d1
rsrc_drvr_9_17E0_98:    /* loop: cmp */
    cmpb %a2@(0x24,%d3:w),%d0
    dbeq %d3,rsrc_drvr_9_17E0_98
    jbne rsrc_drvr_9_17E0_AE
    lslw #2,%d3
    moveal %a2@(0x2c,%d3:w),%a5
    lea %pc@(rsrc_drvr_9_17E0_B6),%a4
    jsr %a5@
rsrc_drvr_9_17E0_AE:    /* set %sr */
    movew %sp@+,%sr
    moveml %sp@+,%d2/%a1-%a2/%a4-%a5
    rts
rsrc_drvr_9_17E0_B6:    /* continue at rsrc_drvr_9_17E0_C8 */
    jbra rsrc_drvr_9_17E0_C8
    tstw %d3
    jbeq rsrc_drvr_9_17E0_C0
    subw %d3,%d1
    jbsr rsrc_drvr_9_18B2
rsrc_drvr_9_17E0_C0:    /* set %d3 */
    movew %d1,%d3
    negw %d3
    moveq #0,%d0
    rts
rsrc_drvr_9_17E0_C8:    /* from here: subw %d3,%d1 */
    subw %d3,%d1
    jbsr rsrc_drvr_9_18B2
    jbeq rsrc_drvr_9_17E0_D0
    moveq #-4,%d0
rsrc_drvr_9_17E0_D0:    /* return */
    rts

/* subroutine (24 instructions): traps BlockMove; calls rsrc_drvr_9_2E68 (mechanical summary) */
rsrc_drvr_9_18B2:
    moveq #0,%d0
    movew %a1@,%d0
    subw %a0,%d0
    jbne rsrc_drvr_9_18B2_10
    addqw #6,%a1
    subal %a0,%a0
    movew %a1@,%d0
    jbeq rsrc_drvr_9_18B2_2E
rsrc_drvr_9_18B2_10:    /* test %d0,%d3 */
    cmpw %d0,%d3
    jbcc rsrc_drvr_9_18B2_16
    movew %d3,%d0
rsrc_drvr_9_18B2_16:    /* set up and call _BlockMove */
    moveml %d0/%a0-%a1,%sp@-
    addal %a1@(2),%a0
    moveal %a3,%a1
    _BlockMove
    moveml %sp@+,%d0/%a0-%a1
    addaw %d0,%a0
    addaw %d0,%a3
    subw %d0,%d3
    jbne rsrc_drvr_9_18B2
rsrc_drvr_9_18B2_2E:    /* set %d0 */
    movew %d3,%d0
    rts
rsrc_drvr_9_18E4:       /* call rsrc_drvr_9_2E68 */
    jbsr rsrc_drvr_9_2E68	| 408DEC94
    rts	| 408DEC98

/* Control csCode 263: csCode 263 (name not known). */
MPP_cs263:
    movel %a0,%sp@-	| 408DEC9A
    moveml %d4-%d7/%a3-%fp,%sp@-	| 408DEC9C
    moveq #0,%d6	| 408DECA0
    movel %a0@(36),%d6	| 408DECA2
    lsrl #8,%d6	| 408DECA6
    cmpb %a2@,%d6	| 408DECA8
    jbne MPP_cs263_20	| 408DECAA
    movel %a0@(36),%d0	| 408DECAC
    swap %d0	| 408DECB0
    cmpw %a2@(26),%d0	| 408DECB2
    jbne MPP_cs263_20	| 408DECB6
    jbra MPP_cs263_98	| 408DECB8
MPP_cs263_20:           /* set %a4 */
    moveal %a2@(888),%a4	| 408DECBA
    subaw #44,%sp	| 408DECBE
    movel %d6,%sp@(28)	| 408DECC2
    movel %a2,%sp@(34)	| 408DECC6
    moveq #10,%d0	| 408DECCA
    moveal %a0,%fp	| 408DECCC
    moveal %sp,%a0	| 408DECCE
    jsr %a4@(2)	| 408DECD0
    moveq #0,%d6	| 408DECD4
    movew %a0@(42),%d6	| 408DECD6
    moveal %fp,%a0	| 408DECDA
    lea %sp@(44),%sp	| 408DECDC
    tstw %d0	| 408DECE0
    jbne MPP_cs263_98	| 408DECE2
    lea %a2@(1056),%a4	| 408DECE4
    movew %d6,%d0	| 408DECE8
    subqw #1,%a4@(4,%d6:w)	| 408DECEA
    tstw %a4@(4,%d6:w)	| 408DECEE
    jbne MPP_cs263_90	| 408DECF2
    clrl %a4@(0,%d0:w)	| 408DECF4
    cmpiw #1,%a2@(2592)	| 408DECF8
    jbne MPP_cs263_6C	| 408DECFE
    subqw #1,%a2@(2592)	| 408DED00
    jbra MPP_cs263_90	| 408DED04
MPP_cs263_6C:           /* from here: divuw #6,%d6 */
    divuw #6,%d6	| 408DED06
    cmpw %a2@(2592),%d6	| 408DED0A
    jbne MPP_cs263_90	| 408DED0E
    subqw #1,%a2@(2592)	| 408DED10
    movew %a2@(2592),%d6	| 408DED14
    addal %d0,%a4	| 408DED18
    jbra MPP_cs263_8C	| 408DED1A
MPP_cs263_82:           /* loop: subq */
    subqw #6,%a4	| 408DED1C
    tstl %a4@	| 408DED1E
    jbne MPP_cs263_90	| 408DED20
    subqw #1,%a2@(2592)	| 408DED22
MPP_cs263_8C:           /* count down */
    dbf %d6,MPP_cs263_82	| 408DED26
MPP_cs263_90:           /* subtract 1 to %a2@(2596) */
    subqw #1,%a2@(2596)	| 408DED2A
    moveq #0,%d0	| 408DED2E
    jbra MPP_cs263_9A	| 408DED30
MPP_cs263_98:           /* set %d0 */
    moveq #-50,%d0	| 408DED32
MPP_cs263_9A:           /* restore registers */
    moveml %sp@+,%d4-%d7/%a3-%fp	| 408DED34
    moveal %sp@+,%a0	| 408DED38
    jbra rsrc_drvr_9_status_3A	| 408DED3A

/* Control csCode 262: csCode 262 (name not known). */
MPP_cs262:
    movel %a0,%sp@-	| 408DED3E
    linkw %a4,#-52	| 408DED40
    clrw %a4@(-2)	| 408DED44
    moveml %d4-%d7/%a5-%fp,%sp@-	| 408DED48
    subaw #52,%sp	| 408DED4C
    moveal %sp,%a1	| 408DED50
    moveq #51,%d0	| 408DED52
MPP_cs262_16:           /* loop: move */
    moveb %a0@+,%a1@+	| 408DED54
    dbf %d0,MPP_cs262_16	| 408DED56
    moveal %sp,%fp	| 408DED5A
    movel %a2@(830),%d6	| 408DED5C
    subaw #22,%sp	| 408DED60
    moveal %sp,%a1	| 408DED64
    jbsr rsrc_drvr_9_247C	| 408DED66
    tstw %d0	| 408DED6A
    jbne MPP_cs262_3C	| 408DED6C
    cmpiw #3,%a1@	| 408DED6E
    jbcs MPP_cs262_3C	| 408DED72
    movew %a1@(20),%a4@(-2)	| 408DED74
MPP_cs262_3C:           /* address %sp@(22) */
    lea %sp@(22),%sp	| 408DED7A
    movel #-1022,%d0	| 408DED7E
    tstw %a4@(-2)	| 408DED84
    jbeq MPP_cs262_80	| 408DED88
    jbsr PSTR_XPP_408DF8C8_6	| 408DED8A
    lea %sp@(52),%sp	| 408DED8E
    moveml %sp@+,%d4-%d7/%a5-%fp	| 408DED92
    unlk %a4	| 408DED96
    moveal %sp@+,%a0	| 408DED98
    tstl %d0	| 408DED9A
    jbeq MPP_cs262_76	| 408DED9C
    movel %d0,%a0@(40)	| 408DED9E
    jbsr rsrc_drvr_9_2870	| 408DEDA2
    tstw %d0	| 408DEDA6
    jbne MPP_cs262_76	| 408DEDA8
    addqw #1,%a2@(2596)	| 408DEDAA
    moveq #0,%d0	| 408DEDAE
    jbra rsrc_drvr_9_status_3A	| 408DEDB0
MPP_cs262_76:           /* set %d0 */
    movel #-1023,%d0	| 408DEDB4
    jbra rsrc_drvr_9_status_3A	| 408DEDBA
MPP_cs262_80:           /* address %sp@(52) */
    lea %sp@(52),%sp	| 408DEDBE
    moveml %sp@+,%d4-%d7/%a5-%fp	| 408DEDC2
    unlk %a4	| 408DEDC6
    moveal %sp@+,%a0	| 408DEDC8
    jbra rsrc_drvr_9_status_3A	| 408DEDCA

/* Control csCode 264: csCode 264 (name not known). */
MPP_cs264:
    lea %a2@(826),%a1	| 408DEDCE
    movel %a1,%a0@(28)	| 408DEDD2
    lea %a2@(830),%a1	| 408DEDD6
    movel %a1,%a0@(32)	| 408DEDDA
    lea %a2@(854),%a1	| 408DEDDE
    movel %a1,%a0@(36)	| 408DEDE2
    lea %a2@(836),%a1	| 408DEDE6
    movel %a1,%a0@(40)	| 408DEDEA
    lea %a2@(838),%a1	| 408DEDEE
    movel %a1,%a0@(44)	| 408DEDF2
    lea %a2@(1040),%a1	| 408DEDF6
    movel %a1,%a0@(48)	| 408DEDFA
    lea %a2@(1044),%a1	| 408DEDFE
    movel %a1,%a0@(52)	| 408DEE02
    jbra MPP_UnloadNBP	| 408DEE06

/* subroutine (16 instructions): low memory ROMBase, AGBHandle (mechanical summary) */
rsrc_drvr_9_1A5A:
    movel %a0,%sp@-
    moveal ROMBase,%a0
    cmpib #118,%a0@(9)
    jbcs rsrc_drvr_9_1A5A_2C
    moveal AGBHandle,%a0
    cmpaw #-1,%a0
    jbeq rsrc_drvr_9_1A5A_2C
    moveal %a0@,%a0
    tstl %a0@(12)
    jbeq rsrc_drvr_9_1A5A_2C
    movel %a0@(12),%sp@-
    moveal %sp@(4),%a0
    movel %sp@+,%sp@
    rts
rsrc_drvr_9_1A5A_2C:    /* set %a0 */
    moveal %sp@+,%a0
    rts

/* Control csCode 259: csCode 259 (name not known). */
MPP_cs259:
    movel %a0,%sp@-	| 408DEE3A
    moveal ExpandMem,%a1	| 408DEE3C
    moveal %a1@(116),%a1	| 408DEE40
    pea %a0@(28)	| 408DEE44
    jbsr rsrc_drvr_9_325E	| 408DEE48
    addqw #4,%sp	| 408DEE4C
    moveal %sp@+,%a0	| 408DEE4E
    jbne MPP_cs259_20	| 408DEE50
    clrl %a0@(28)	| 408DEE52
    jbra rsrc_drvr_9_status_3A	| 408DEE56
MPP_cs259_20:           /* result -24 */
    moveq #-24,%d0	| 408DEE5A
    jbra rsrc_drvr_9_status_3A	| 408DEE5C

/* Control csCode 260: csCode 260 (name not known). */
MPP_cs260:
    moveal ExpandMem,%a1	| 408DEE60
    moveal %a1@(116),%a1	| 408DEE64
    jbsr rsrc_drvr_9_32CE	| 408DEE68
    moveq #0,%d0	| 408DEE6C
    jbra rsrc_drvr_9_status_3A	| 408DEE6E

/* Control csCode 258: csCode 258 (name not known). */
MPP_cs258:
    moveq #-50,%d0	| 408DEE72
    cmpiw #1,%a0@(28)	| 408DEE74
    jbhi rsrc_drvr_9_status_3A	| 408DEE7A
    lea %a0@(30),%a3	| 408DEE7E
    moveq #18,%d0	| 408DEE82
MPP_cs258_12:           /* loop: clr */
    clrw %a3@+	| 408DEE84
    dbf %d0,MPP_cs258_12	| 408DEE86
    movel %a2,%a0@(30)	| 408DEE8A
    movel %a2@(816),%a0@(34)	| 408DEE8E
    moveb %a2@(820),%a0@(39)	| 408DEE94
    movel %a2@(830),%a0@(40)	| 408DEE9A
    moveb %a2@(696),%a0@(45)	| 408DEEA0
    movel %a2@(836),%a0@(46)	| 408DEEA6
    moveq #0,%d0	| 408DEEAC
    movew %a2@(26),%d0	| 408DEEAE
    lsll #8,%d0	| 408DEEB2
    moveb %a2@,%d0	| 408DEEB4
    movel %d0,%a0@(50)	| 408DEEB6
    movel %a2@(826),%a0@(54)	| 408DEEBA
    moveb %a2@(34),%a0@(59)	| 408DEEC0
    moveb %a2@(35),%a0@(61)	| 408DEEC6
    movel %a2@(680),%d0	| 408DEECC
    jbeq MPP_cs258_6C	| 408DEED0
    moveal %d0,%a3	| 408DEED2
    moveb %a3@,%a0@(63)	| 408DEED4
    movel %a2@(688),%a0@(64)	| 408DEED8
MPP_cs258_6C:           /* save registers */
    moveml %d4/%d7-%a1,%sp@-	| 408DEEDE
    subaw #22,%sp	| 408DEEE2
    moveal %sp,%a1	| 408DEEE6
    moveb %a2@(820),%d0	| 408DEEE8
    pea %a0@	| 408DEEEC
    jbsr rsrc_drvr_9_247C	| 408DEEEE
    moveal %sp@+,%a0	| 408DEEF2
    tstw %d0	| 408DEEF4
    jbne MPP_cs258_A6	| 408DEEF6
    exg %a0,%a1	| 408DEEF8
    moveq #0,%d0	| 408DEEFA
    movew %a1@(68),%d0	| 408DEEFC
    clrw %a1@(68)	| 408DEF00
    moveb %a0@(13),%a1@(69)	| 408DEF04
    movel %a1@(70),%d1	| 408DEF0A
    jbeq MPP_cs258_A6	| 408DEF0E
    lea %a0@(14),%a0	| 408DEF10
    moveal %d1,%a1	| 408DEF14
    _BlockMove	| 408DEF16 408DEF16 A-line trap
MPP_cs258_A6:
    lea %sp@(22),%sp	| 408DEF18
    moveml %sp@+,%d4/%d7-%a1	| 408DEF1C
    tstl %a0@(74)	| 408DEF20
    jbeq MPP_cs258_C0	| 408DEF24
    moveal %a0@(74),%a1	| 408DEF26
    lea %a2@(854),%a0	| 408DEF2A
    moveq #33,%d0	| 408DEF2E
    _BlockMove	| 408DEF30 408DEF30 A-line trap
MPP_cs258_C0:
    moveq #0,%d0	| 408DEF32
    jbra rsrc_drvr_9_status_3A	| 408DEF34

/* subroutine (10 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_drvr_9_1B88:
    moveml %a1-%a2,%sp@-
    moveq #4,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    movel %a0,%d0
    jbeq rsrc_drvr_9_1B88_18
    moveq #8,%d0
    jsr %a0@(2)
rsrc_drvr_9_1B88_18:    /* restore registers, return */
    moveml %sp@+,%a1-%a2
    rts

/* subroutine (10 instructions): low memory ATalkHk2, PortBUse (mechanical summary) */
rsrc_drvr_9_1BA6:
    movel %a0,%sp@-
    moveq #19,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    moveb %d1,PortBUse
    cmpib #1,%d1
    jbne rsrc_drvr_9_1BA6_1A
    st PortBUse
rsrc_drvr_9_1BA6_1A:    /* set %a0 */
    moveal %sp@+,%a0
    rts

/* subroutine (8 instructions): traps VRemove (mechanical summary) */
rsrc_drvr_9_1BC4:
    tstw %a0@(4)
    jbeq rsrc_drvr_9_1BC4_8
    _VRemove
rsrc_drvr_9_1BC4_8:     /* return */
    rts
rsrc_drvr_9_1BCE:       /* set %a0@(10) */
    movew #1020,%a0@(10)	| 408DEF7E
    lea %a0@(-916),%a2	| 408DEF84
    clrw %a2@(914)	| 408DEF88
    rts	| 408DEF8C

/* subroutine (109 instructions): traps Close, Control, DisposPtr, HPurge; calls rsrc_drvr_9_3234, rsrc_drvr_9_5BE, rsrc_drvr_9_1BC4, rsrc_drvr_9_2F4A, rsrc_drvr_9_1B88 ...; low memory ExpandMem, UTableBase, ABusVars (mechanical summary) */
rsrc_drvr_9_close:
    moveal %a0,%fp
    moveal %a1@(20),%a2
    movel %a2@(830),%d6
    btst #13,%d6
    jbeq rsrc_drvr_9_close_20
    movel %a1,%sp@-
    moveal ExpandMem,%a2
    moveal %a2@(116),%a2
    jbsr rsrc_drvr_9_3234
    moveal %sp@+,%a1
rsrc_drvr_9_close_20:   /* set %a2 */
    moveal %a1@(20),%a2
    movel %a2,%d0
    jbeq rsrc_drvr_9_close_14A
rsrc_drvr_9_close_2A:   /* loop: move */
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    tstl %a1@(8)
    jbeq rsrc_drvr_9_close_3E
    movew %sp@+,%sr
    jbra rsrc_drvr_9_close_2A
rsrc_drvr_9_close_3E:   /* clear bit 5 of %a1@(5) */
    bclr #5,%a1@(5)
    movel %a1,%sp@-
    moveq #126,%d6
    lea %a2@(150),%a1
rsrc_drvr_9_close_4C:   /* loop: clr */
    clrl %a1@+
    dbf %d6,rsrc_drvr_9_close_4C
    moveq #13,%d6
    lea %a2@(76),%a1
rsrc_drvr_9_close_58:   /* loop: clr */
    clrb %a1@+
    dbf %d6,rsrc_drvr_9_close_58
    moveal %sp@+,%a1
    movew %sp@+,%sr
    movel %a2@(830),%d6
    btst #13,%d6
    jbeq rsrc_drvr_9_close_F4
    bset #10,%d6
    orl %d6,%a2@(830)
    subaw #50,%sp
    moveal %sp,%a0
    movew #-11,%a0@(24)
    _Close
    movew #-41,%a0@(24)
    movew #246,%a0@(26)
    movew #1,%a0@(28)
    movew #7,%a0@(30)
    _Control
    movew #6,%a0@(30)
    _Control
    movew #5,%a0@(30)
    _Control
    lea %sp@(50),%sp
    btst #15,%d6
    jbeq rsrc_drvr_9_close_C2
    btst #30,%d6
    jbne rsrc_drvr_9_close_C2
    jbsr rsrc_drvr_9_5BE
rsrc_drvr_9_close_C2:   /* clear %d3 */
    moveq #0,%d3
    moveal %a2@(672),%a0
    cmpaw #0,%a0
    jbeq rsrc_drvr_9_close_D0
    jsr %a0@
rsrc_drvr_9_close_D0:   /* set %sp@- */
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    movel %a2@(680),%d0
    jbeq rsrc_drvr_9_close_E4
    moveal %d0,%a0
    _DisposPtr
rsrc_drvr_9_close_E4:   /* set %d0 */
    movel %a2@(692),%d0
    jbeq rsrc_drvr_9_close_F2
    moveq #26,%d1
    subl %d1,%d0
    moveal %d0,%a0
    _DisposPtr
rsrc_drvr_9_close_F2:   /* set %sr */
    movew %sp@+,%sr
rsrc_drvr_9_close_F4:   /* set up and call _DisposPtr */
    movel %a2@(146),%d0
    jbeq rsrc_drvr_9_close_FE
    moveal %d0,%a0
    _DisposPtr
rsrc_drvr_9_close_FE:   /* set up and call _DisposPtr */
    movel %a2@(896),%d0
    jbeq rsrc_drvr_9_close_108
    moveal %d0,%a0
    _DisposPtr
rsrc_drvr_9_close_108:  /* address %a2@(658) */
    lea %a2@(658),%a0
    jbsr rsrc_drvr_9_1BC4
    lea %a2@(916),%a0
    jbsr rsrc_drvr_9_1BC4
    jbsr rsrc_drvr_9_2F4A
    moveb %a2@(820),%d4
    jbsr rsrc_drvr_9_1B88
    btst #13,%d6
    jbne rsrc_drvr_9_close_142
    moveal UTableBase,%a4
    movew %fp@(24),%d2
    notw %d2
    lslw #2,%d2
    moveal %a4@(0x0,%d2:w),%a0
    _HPurge
    clrl %a4@(0x0,%d2:w)
    jbra rsrc_drvr_9_close_14A
rsrc_drvr_9_close_142:  /* call rsrc_drvr_9_1BA6 */
    jbsr rsrc_drvr_9_1BA6
    clrl ABusVars
rsrc_drvr_9_close_14A:  /* set up and call _DisposPtr */
    moveal %a2,%a0
    cmpaw #0,%a0
    jbeq rsrc_drvr_9_close_154
    _DisposPtr
rsrc_drvr_9_close_154:  /* clear %a1@(20) */
    clrl %a1@(20)
    moveq #0,%d0
rsrc_drvr_9_close_15A:  /* return */
    rts

/* subroutine (444 instructions): traps Control, NewPtr, StripAddress, GetTrapAddress, ReadXPRam, VInstall, WriteXPRam, WriteParam; calls rsrc_drvr_9_247C, rsrc_drvr_9_2ED2, rsrc_drvr_9_3192, rsrc_drvr_9_4E0, rsrc_drvr_9_2622 ...; low memory ATalkHk2, ABusVars, PortBUse, SPConfig, SPATalkB (mechanical summary) */
rsrc_drvr_9_open:
    bset #0,%a1@(5)
    moveq #0,%d6
    moveal %a0,%fp
    moveq #-23,%d0
    movel ATalkHk2,%d1
    jble rsrc_drvr_9_open_14
    jbra rsrc_drvr_9_open_16
rsrc_drvr_9_open_14:    /* return */
    rts
rsrc_drvr_9_open_16:    /* from here: subal %a2,%a2 */
    subal %a2,%a2
    btst #9,%fp@(6)
    jbeq rsrc_drvr_9_open_2A
    movel %fp@(28),%d6
    andil #-536870912,%d6
rsrc_drvr_9_open_2A:    /* from here: linkw %a4,#-52 */
    linkw %a4,#-52
    moveal %a4,%a0
    movew #25,%d0
rsrc_drvr_9_open_34:    /* loop: clr */
    clrw %a0@-
    dbf %d0,rsrc_drvr_9_open_34
    bclr #6,%a1@(5)
    movew %fp@(24),%d0
    cmpiw #-10,%d0
    jbne rsrc_drvr_9_open_5A
    lea %a4@(-52),%a0
    movew #2,%a0@(26)
    movew %d0,%a0@(24)
    .short  0xA404	| 408DF142 _Control (flags 0x0400)
rsrc_drvr_9_open_5A:    /* clear %d0 */
    moveq #0,%d0
    moveq #0,%d2
    btst #30,%d6
    jbeq rsrc_drvr_9_open_6C
    moveb %fp@(26),%d0
    andib #127,%d0
rsrc_drvr_9_open_6C:    /* set %sp@- */
    movel %a1,%sp@-
    subaw #22,%sp
    moveal %sp,%a1
    jbsr rsrc_drvr_9_247C
    tstw %d0
    jbne rsrc_drvr_9_open_98
    moveb %a1@(13),%d2
    btst #7,%a1@(12)
    jbeq rsrc_drvr_9_open_8C
    bset #15,%d6
rsrc_drvr_9_open_8C:    /* test #3,%a1@ */
    cmpiw #3,%a1@
    jbcs rsrc_drvr_9_open_98
    movew %a1@(20),%a4@(-2)
rsrc_drvr_9_open_98:    /* address %sp@(22) */
    lea %sp@(22),%sp
    moveal %sp@+,%a1
    cmpiw #-10,%fp@(24)
    jbne rsrc_drvr_9_open_E0
    bset #13,%d6
    clrl ABusVars
    tstb PortBUse
    jbmi rsrc_drvr_9_open_CC
    movel %a1,%sp@-
    moveq #19,%d0
    moveal ATalkHk2,%a1
    jsr %a1@(2)
    moveal %sp@+,%a1
    moveq #-97,%d0
    cmpb PortBUse,%d1
    jbne rsrc_drvr_9_open_57A
rsrc_drvr_9_open_CC:    /* set %d0 */
    moveq #-98,%d0
    moveb SPConfig,%d1
    andib #15,%d1
    subqb #1,%d1
    jbgt rsrc_drvr_9_open_57A
    st PortBUse
rsrc_drvr_9_open_E0:    /* clear %d4 */
    moveq #0,%d4
    btst #30,%d6
    jbeq rsrc_drvr_9_open_EC
    moveb %fp@(26),%d4
rsrc_drvr_9_open_EC:    /* set %sp@- */
    movel %a2,%sp@-
    movel %a1,%sp@-
    andib #127,%d4
    moveq #4,%d0
    moveal ATalkHk2,%a1
    jsr %a1@(2)
    moveq #7,%d0
    jsr %a0@(2)
    moveal %sp@+,%a1
    moveal %sp@+,%a2
    cmpiw #-97,%d0
    jbeq rsrc_drvr_9_open_57A
    clrl %a1@(20)
    movel #2608,%d0
    .short  0xA71E	| 408DF204 _NewPtr (flags 0x0700)
    jbne rsrc_drvr_9_open_57A
    moveal %a0,%a2
    movel %a2,%a1@(20)
    movel %a1,%a2@(816)
    movel %d7,%a2@(888)
    movel %d6,%a2@(830)
    moveb %pc@(rsrc_drvr_9_18),%a1@(7)
    moveb %d2,%a2@(851)
    lea %pc@(rsrc_drvr_9_2A42),%a0
    movel %a0,%d0
    _StripAddress
    movel %d0,%a2@(1052)
    lea %pc@(rsrc_drvr_9_28FE),%a0
    movel %a0,%d0
    _StripAddress
    movel %d0,%a2@(1048)
    jbsr rsrc_drvr_9_2ED2
    jbne rsrc_drvr_9_open_57A
    moveq #0,%d0
    movew %d0,%a2@(836)
    subqw #2,%d0
    movew %d0,%a2@(838)
    movew #-24530,%d0
    .short  0xA146	| 408DF256 _GetTrapAddress (flags 0x0100)
    movel %a0,%a2@(972)
    btst #13,%d6
    jbeq rsrc_drvr_9_open_180
    movel %a2,ABusVars
    movel %a1,ABusVars_dce
rsrc_drvr_9_open_180:   /* test bit 30 of %d6 */
    btst #30,%d6
    jbne rsrc_drvr_9_open_19A
    btst #15,%d6
    jbeq rsrc_drvr_9_open_1FA
    lea %a2@(834),%a0
    movel #131294,%d0
    _ReadXPRam
    jbra rsrc_drvr_9_open_1D4
rsrc_drvr_9_open_19A:   /* set %d0 */
    movel %fp@(40),%d0
    tstb %d0
    jbne rsrc_drvr_9_open_1AA
    moveb Ticks_LoByte,%d0
    addb 0x20f,%d0
rsrc_drvr_9_open_1AA:   /* set SPATalkB */
    moveb %d0,SPATalkB
    btst #15,%d6
    jbeq rsrc_drvr_9_open_1FA
    lsrl #8,%d0
    movew %d0,%a2@(834)
    movew %fp@(36),%d0
    jbeq rsrc_drvr_9_open_1D4
    swap %d0
    movew %fp@(38),%d0
    jbeq rsrc_drvr_9_open_1D4
    movel %d0,%a2@(836)
    bset #14,%d6
    orl %d6,%a2@(830)
rsrc_drvr_9_open_1D4:   /* test %a2@(834) */
    tstw %a2@(834)
    jbne rsrc_drvr_9_open_1FA
    moveq #0,%d0
    moveb #0xfe,%d0
    movel %d0,%sp@-
    moveb Ticks_LoByte,%d0
    addb 0x20f,%d0
    movel %d0,%sp@-
    jbsr rsrc_drvr_9_3192
    addqw #8,%sp
    addiw #-256,%d0
    movew %d0,%a2@(834)
rsrc_drvr_9_open_1FA:   /* test bit 30 of %d6 */
    btst #30,%d6
    jbeq rsrc_drvr_9_open_20C
    moveb %fp@(26),%d0
    andib #127,%d0
    moveb %d0,%a2@(820)
rsrc_drvr_9_open_20C:   /* from here: st %a2@(821) */
    st %a2@(821)
    movew #2062,%a2@(34)
    moveq #7,%d0
rsrc_drvr_9_open_218:   /* loop: st */
    st %a2@(0x24,%d0:w)
    dbf %d0,rsrc_drvr_9_open_218
    moveal ROMBase,%a3
    movew #8448,%a2@(28)
    cmpib #117,%a3@(9)
    jbeq rsrc_drvr_9_open_248
    cmpib #118,%a3@(9)
    jbeq rsrc_drvr_9_open_248
    cmpib #122,%a3@(9)
    jbeq rsrc_drvr_9_open_248
    movew #8960,%a2@(28)
rsrc_drvr_9_open_248:   /* test bit 13 of %d6 */
    btst #13,%d6
    jbeq rsrc_drvr_9_open_278
    btst #15,%d6
    jbeq rsrc_drvr_9_open_278
    btst #30,%d6
    jbne rsrc_drvr_9_open_278
    jbsr rsrc_drvr_9_4E0
    lea %a2@(916),%a0
    movew #1,%a0@(4)
    lea %pc@(rsrc_drvr_9_1BCE),%a1
    movel %a1,%a0@(6)
    movew #1020,%a0@(10)
    _VInstall
rsrc_drvr_9_open_278:   /* test bit 30 of %d6 */
    btst #30,%d6
    jbne rsrc_drvr_9_open_298
    lea %a2@(658),%a0
    movew #1,%a0@(4)
    lea %pc@(rsrc_drvr_9_18E4),%a1
    movel %a1,%a0@(6)
    movew #20,%a0@(10)
    _VInstall
rsrc_drvr_9_open_298:   /* address %pc@(rsrc_drvr_9_498) */
    lea %pc@(rsrc_drvr_9_498),%a3
    lea %a2@(76),%a0
    movel %a3,%a0@-
    lea %pc@(rsrc_drvr_9_412),%a3
    movel %a3,%a0@-
    lea %pc@(rsrc_drvr_9_2792),%a3
    movel %a3,%a0@-
    lea %a2@(44),%a0
    moveb #1,%a0@-
    moveb #2,%a0@-
    moveb #0x80,%a0@-
    moveb #1,PortBUse
    jbsr rsrc_drvr_9_2622
    jbne rsrc_drvr_9_open_57A
    orib #1,SPConfig
    movew #-24516,%d0
    .short  0xA146	| 408DF3C0 _GetTrapAddress (flags 0x0100)
    movel %a0,%a2@(904)
    btst #15,%d6
    jbeq rsrc_drvr_9_open_3F2
    jbsr rsrc_drvr_9_133A
    btst #13,%d6
    jbeq rsrc_drvr_9_open_306
    lea %a2@(854),%a0
    movel #2162877,%d0
    _ReadXPRam
    cmpib #32,%a2@(854)
    jbls rsrc_drvr_9_open_306
    clrb %a2@(854)
rsrc_drvr_9_open_306:   /* set %sp@- */
    movel %a2,%sp@-
    pea %a2@(842)
    pea %pc@(rsrc_drvr_9_15A2)
    jbsr rsrc_drvr_9_31E8
    lea %sp@(12),%sp
    btst #30,%d6
    jbne rsrc_drvr_9_open_344
    tstw %a2@(842)
    jbeq rsrc_drvr_9_open_3BC
rsrc_drvr_9_open_326:   /* loop: move */
    movew %a2@(840),%a2@(836)
    movew %a2@(842),%a2@(838)
    movew %a2@(26),%d0
    cmpw %a2@(836),%d0
    jbcs rsrc_drvr_9_open_38C
    cmpw %a2@(838),%d0
    jbhi rsrc_drvr_9_open_38C
    jbra rsrc_drvr_9_open_3BC
rsrc_drvr_9_open_344:   /* test bit 14 of %d6 */
    btst #14,%d6
    jbeq rsrc_drvr_9_open_376
    tstw %a2@(842)
    jbeq rsrc_drvr_9_open_36C
    movew #-5002,%d0
    movew %a2@(840),%d1
    cmpw %a2@(836),%d1
    jbne rsrc_drvr_9_open_57A
    movew %a2@(842),%d1
    cmpw %a2@(838),%d1
    jbne rsrc_drvr_9_open_57A
rsrc_drvr_9_open_36C:   /* test #-256,%a2@(26) */
    cmpiw #-256,%a2@(26)
    jbcc rsrc_drvr_9_open_38C
    jbra rsrc_drvr_9_open_3BC
rsrc_drvr_9_open_376:   /* set %d0 */
    movew #-5008,%d0
    tstw %a2@(842)
    jbne rsrc_drvr_9_open_326
    cmpiw #-256,%a2@(26)
    jbcc rsrc_drvr_9_open_57A
    jbra rsrc_drvr_9_open_3BC
rsrc_drvr_9_open_38C:   /* from here: subaw #44,%sp */
    subaw #44,%sp
    moveq #0,%d0
    movew %a2@(26),%d0
    lsll #8,%d0
    moveb %a2@,%d0
    movel %d0,%sp@(28)
    moveal %sp,%a0
    moveal %a2@(888),%a1
    moveq #10,%d0
    jsr %a1@(2)
    lea %sp@(44),%sp
    clrw %a2@(26)
    clrb %a2@
    jbsr rsrc_drvr_9_2672
    jbne rsrc_drvr_9_open_57A
rsrc_drvr_9_open_3BC:   /* test bit 30 of %d6 */
    btst #30,%d6
    jbeq rsrc_drvr_9_open_3CC
    clrb %a2@(87)
    tstb %a2@(820)
    jbne rsrc_drvr_9_open_3F2
rsrc_drvr_9_open_3CC:   /* test #-256,%a2@(26) */
    cmpiw #-256,%a2@(26)
    jbcc rsrc_drvr_9_open_3F2
    lea %a2@(26),%a0
    movel #131294,%d0
    _WriteXPRam
    lea %a2@(854),%a0
    tstb %a2@(850)
    jbeq rsrc_drvr_9_open_3F2
    movel #2162877,%d0
    _WriteXPRam
rsrc_drvr_9_open_3F2:   /* call rsrc_drvr_9_247C_2C */
    jbsr rsrc_drvr_9_247C_2C
    btst #13,%d6
    jbeq rsrc_drvr_9_open_404
    lea SPValid,%a0
    moveq #-1,%d0
    _WriteParam
rsrc_drvr_9_open_404:   /* clear %a2@(821) */
    clrb %a2@(821)
    btst #30,%d6
    jbeq rsrc_drvr_9_open_41C
    lea %pc@(rsrc_drvr_9_33E6),%a0
    movel %a0,%a2@(812)
    tstb %fp@(26)
    jbpl rsrc_drvr_9_open_420
rsrc_drvr_9_open_41C:   /* from here: st %a2@(821) */
    st %a2@(821)
rsrc_drvr_9_open_420:   /* address %pc@(thunk_FUN_408dd652) */
    lea %pc@(thunk_FUN_408dd652),%a0
    movel %a0,%a2@(684)
    movel #651,%d0
    .short  0xA71E	| 408DF518 _NewPtr (flags 0x0700)
    jbne rsrc_drvr_9_open_476
    movel %a0,%a2@(146)
    moveal %a2@(816),%a1
    movew %a1@(24),%a0@(24)
    lea %a0@(26),%a1
    movew #246,%a1@+
    movew #1024,%a1@+
    lea %a0@(34),%a3
    movel %a3,%a1@+
    lea %a0@(49),%a1
    movel %a1,%a3@(2)
    moveb #4,%a1@(15)
    lea %a0@(65),%a1
    movel %a1,%a3@(8)
    lea %pc@(rsrc_drvr_9_161E),%a1
    movel %a1,%a2@(138)
    moveb #4,%a2@(88)
rsrc_drvr_9_open_476:   /* test bit 30 of %d6 */
    btst #30,%d6
    jbeq rsrc_drvr_9_open_488
    st %a2@(696)
    btst #13,%d6
    jbeq rsrc_drvr_9_open_52A
rsrc_drvr_9_open_488:   /* from here: subaw #50,%sp */
    subaw #50,%sp
    lea %pc@(PSTR_ATP),%a0
    movel %a0,%sp@(18)
    moveal %sp,%a0
    clrb %a0@(27)
    _Open
    lea %sp@(50),%sp
    tstw %d0
    jbne rsrc_drvr_9_open_57A
    bset #9,%d6
    orl %d6,%a2@(830)
    subaw #50,%sp
    lea %pc@(PSTR_XPP_408DF8C8),%a0
    movel %a0,%sp@(18)
    moveal %sp,%a0
    clrb %a0@(27)
    _Open
    moveal AGBHandle,%a0
    moveal %a0@,%a0
    moveal %a0@(4),%a1
    cmpaw #0,%a1
    jbne rsrc_drvr_9_open_4D6
    lea %pc@(rsrc_drvr_9_close_15A),%a1
rsrc_drvr_9_open_4D6:   /* set %a0 */
    moveal %sp,%a0
    movew #-41,%a0@(24)
    movew #246,%a0@(26)
    clrw %a0@(28)
    movew #7,%a0@(30)
    lea %pc@(rsrc_drvr_9_2BC2),%a1
    movel %a1,%a0@(32)
    _Control
    movew #6,%a0@(30)
    lea %pc@(rsrc_drvr_9_2BC2),%a1
    movel %a1,%a0@(32)
    _Control
    movew #5,%a0@(30)
    lea %pc@(rsrc_drvr_9_2BC2),%a1
    movel %a1,%a0@(32)
    _Control
    lea %sp@(50),%sp
    lea %pc@(rsrc_drvr_9_1066),%a3
    movel %a3,%a2@(676)
    moveq #7,%d3
    jbsr rsrc_drvr_9_88E
rsrc_drvr_9_open_52A:   /* test bit 30 of %d6 */
    btst #30,%d6
    jbeq rsrc_drvr_9_open_550
    lea %a2@(658),%a0
    movew #1,%a0@(4)
    movew #32767,%a0@(10)
    pea %pc@(rsrc_drvr_9_5E)
    movel %sp@+,%a0@(6)
    _VInstall
    moveal %a2@(816),%a1
    jbra rsrc_drvr_9_open_56A
rsrc_drvr_9_open_550:   /* address %pc@(rsrc_drvr_9) */
    lea %pc@(rsrc_drvr_9),%a0
    jbsr rsrc_drvr_9_3160
    jbeq rsrc_drvr_9_open_56A
    .short  0xA128	| 408DF644 _RecoverHandle (flags 0x0100)
    lea %pc@(rsrc_drvr_9_339E),%a1
    movel %a1,%d0
    lea %pc@(rsrc_drvr_9),%a1
    subl %a1,%d0
    _SetHandleSize
rsrc_drvr_9_open_56A:   /* set bit 11 of %d6 */
    bset #11,%d6
    orl %d6,%a2@(830)
    movel %a2@(830),%fp@(28)
    moveq #0,%d0
rsrc_drvr_9_open_57A:   /* set %sp@- */
    movew %d0,%sp@-
    tstw %d0
    jbne rsrc_drvr_9_open_5B2
    jbsr rsrc_drvr_9_1A5A
    lea %pc@(rsrc_drvr_9_17E0),%a0
    movel %a0,%a2@(1044)
    btst #13,%d6
    jbeq rsrc_drvr_9_open_5B0
    moveml %d0/%a1-%a2,%sp@-
    moveal %a2@(816),%a1
    moveal JIODone,%a0
    jsr %a0@
    moveml %sp@+,%d0/%a1-%a2
    clrl %sp@-
    pea %fp@
    jsr %pc@(rsrc_drvr_9_310C)
    lea %sp@(4),%sp
rsrc_drvr_9_open_5B0:   /* continue at rsrc_drvr_9_open_624 */
    jbra rsrc_drvr_9_open_624
rsrc_drvr_9_open_5B2:   /* test #-10,%fp@(24) */
    cmpiw #-10,%fp@(24)
    jbne rsrc_drvr_9_open_5F0
    moveal UTableBase,%a1
    moveal %a1@(36),%a1
    moveal %a1@,%a1
    moveal %a1@(8),%a0
    movel %a0@,%a1@(8)
    tstl %a0@
    jbne rsrc_drvr_9_open_5D4
    clrl %a1@(12)
rsrc_drvr_9_open_5D4:   /* test #-97,%sp@ */
    cmpiw #-97,%sp@
    jbeq rsrc_drvr_9_open_5F0
    cmpiw #-98,%sp@
    jbeq rsrc_drvr_9_open_5F0
    jbsr rsrc_drvr_9_1BA6
    cmpib #1,PortBUse
    jbne rsrc_drvr_9_open_5F0
    st PortBUse
rsrc_drvr_9_open_5F0:   /* test #0,%a2 */
    cmpaw #0,%a2
    jbeq rsrc_drvr_9_open_624
    moveb %a2@(820),%d4
    jbsr rsrc_drvr_9_1B88
    jbsr rsrc_drvr_9_5BE
    jbsr rsrc_drvr_9_2F4A
    lea %a2@(658),%a0
    jbsr rsrc_drvr_9_1BC4
    lea %a2@(916),%a0
    jbsr rsrc_drvr_9_1BC4
    btst #30,%d6
    jbne rsrc_drvr_9_open_624
    clrl ABusVars
    moveal %a2,%a0
    _DisposPtr
rsrc_drvr_9_open_624:   /* set %d0 */
    movew %sp@+,%d0
    unlk %a4
    rts

/* subroutine (66 instructions): calls rsrc_drvr_9_3192, rsrc_drvr_9_2430; low memory ExpandMem, SPATalkB (mechanical summary) */
rsrc_drvr_9_2364:
    subl %d5,%d5
    moveb %a2@(820),%d5
    muluw #16,%d5
    moveal ExpandMem,%a3
    moveal %a3@(116),%a3
    lea %a3@(0x0,%d5:l),%a3
    lea %a3@(656),%a3
    moveb %d0,%d2
    movew #256,%a2@(852)
rsrc_drvr_9_2364_22:    /* loop: tst */
    tstb %d0
    jbeq rsrc_drvr_9_2364_38
    btst #15,%d6
    jbeq rsrc_drvr_9_2364_32
    cmpib #0xfe,%d0
    jbeq rsrc_drvr_9_2364_38
rsrc_drvr_9_2364_32:    /* test #0xff,%d0 */
    cmpib #0xff,%d0
    jbne rsrc_drvr_9_2364_56
rsrc_drvr_9_2364_38:    /* loop: tst */
    tstw %a2@(852)
    jbeq rsrc_drvr_9_2364_CA
    movel #255,%sp@-
    andiw #255,%d2
    movel %d2,%sp@-
    jbsr rsrc_drvr_9_3192
    addqw #8,%sp
    moveb %d0,%d2
    jbra rsrc_drvr_9_2364_22
rsrc_drvr_9_2364_56:    /* test bit 15 of %d6 */
    btst #15,%d6
    jbne rsrc_drvr_9_2364_72
    btst #5,%a3@
    jbeq rsrc_drvr_9_2364_72
    btst #31,%d6
    jbeq rsrc_drvr_9_2364_6E
    tstb %d0
    jbpl rsrc_drvr_9_2364_38
    jbra rsrc_drvr_9_2364_72
rsrc_drvr_9_2364_6E:    /* test %d0 */
    tstb %d0
    jbmi rsrc_drvr_9_2364_38
rsrc_drvr_9_2364_72:    /* subtract 1 to %a2@(852) */
    subqw #1,%a2@(852)
    moveq #19,%d4
    btst #15,%d6
    jbeq rsrc_drvr_9_2364_82
    asrl #1,%d4
    jbra rsrc_drvr_9_2364_8E
rsrc_drvr_9_2364_82:    /* test %d0 */
    tstb %d0
    jbpl rsrc_drvr_9_2364_8E
    btst #5,%a3@
    jbeq rsrc_drvr_9_2364_8E
    moveq #119,%d4
rsrc_drvr_9_2364_8E:    /* set SPATalkB */
    moveb %d0,SPATalkB
    clrb %a2@(709)
    clrb %a2@(711)
rsrc_drvr_9_2364_9A:    /* loop: st */
    st %a2@(712)
    moveq #0,%d2
    movew %a2@(834),%d2
    lsll #8,%d2
    moveb SPATalkB,%d2
    moveml %d2/%a3/%a5,%sp@-
    jbsr rsrc_drvr_9_2430
    moveml %sp@+,%d2/%a3/%a5
rsrc_drvr_9_2364_B4:    /* loop: tst */
    tstb %a2@(712)
    jbne rsrc_drvr_9_2364_B4
    tstb %a2@(711)
    jbne rsrc_drvr_9_2364_38
    dbf %d4,rsrc_drvr_9_2364_9A
    st %a2@(709)
rsrc_drvr_9_2364_CA:    /* return */
    rts

/* subroutine (21 instructions): calls rsrc_drvr_9_1770 (mechanical summary) */
rsrc_drvr_9_2430:
    tstw %a4@(-2)
    jbeq rsrc_drvr_9_2430_42
    clrb %a2@(712)
    moveal %a2@(888),%a1
    subaw #44,%sp
    clrl %sp@(12)
    movel %d2,%sp@(28)
    movew %d4,%sp@(32)
    movel %a2,%sp@(34)
    movew %a5,%sp@(42)
    movel #657,%sp@(38)
    moveal %sp,%a0
    moveq #9,%d0
    jsr %a1@(2)
    lea %sp@(44),%sp
    clrw %d4
    moveb %d0,%a2@(711)
    jbra rsrc_drvr_9_2430_4A
rsrc_drvr_9_2430_42:    /* call rsrc_drvr_9_1770 */
    jbsr rsrc_drvr_9_1770
    clrb %a2@(712)
rsrc_drvr_9_2430_4A:    /* return */
    rts

/* subroutine (14 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_drvr_9_247C:
    moveb %d0,%d4
    movew #4,%d0
    moveml %a1-%a2,%sp@-
    moveal ATalkHk2,%a1
    jsr %a1@(2)
    moveml %sp@+,%a1-%a2
    jbne rsrc_drvr_9_247C_2A
    moveq #-1,%d0
    movel %a0,%d7
    jbeq rsrc_drvr_9_247C_2A
    movew #3,%d0
    movew #22,%d1
    jmp %a0@(2)
rsrc_drvr_9_247C_2A:    /* return */
    rts

/* subroutine (14 instructions): traps Delay; calls rsrc_drvr_9_247C_58 (mechanical summary) */
rsrc_drvr_9_247C_2C:
    btst #30,%d6
    jbne rsrc_drvr_9_247C_56
    lea %pc@(rsrc_drvr_9_2C7E),%a0
    movel %a0,%a2@(142)
    moveb #1,%a2@(89)
    btst #15,%d6
    jbne rsrc_drvr_9_247C_56
    jbsr rsrc_drvr_9_247C_58
    lea 0x2,%a0
    _Delay
    tstb %a2@(25)
    jbne rsrc_drvr_9_247C_56
    jbsr rsrc_drvr_9_247C_58
rsrc_drvr_9_247C_56:    /* return */
    rts

/* subroutine (14 instructions): calls rsrc_drvr_9_2508 (mechanical summary) */
rsrc_drvr_9_247C_58:
    clrw %sp@-
    subqw #4,%sp
    movew #9,%sp@-
    moveal %sp,%a1
    movew #1281,%sp@-
    movew #257,%sp@-
    movew #6,%sp@-	| 408DF896
    movew #1,%sp@-
    st %d2
    movew %d2,%sp@-
    lea %sp@(1),%a3
    movel %a3,%a3@(11)
    jbsr rsrc_drvr_9_2508
rsrc_drvr_9_247C_80:    /* loop: tst */
    tstb %a2@(712)
    jbeq rsrc_drvr_9_247C_80
    lea %sp@(18),%sp
    rts

/* subroutine (3 instructions): calls rsrc_drvr_9_1768 (mechanical summary) */
rsrc_drvr_9_2508:
    jbsr rsrc_drvr_9_1768
    st %a2@(712)
    rts
PSTR_ATP:               /* (data) */
    .byte   0x04, 0x2E, 0x41, 0x54, 0x50, 0x20	| 408DF8C2
PSTR_XPP_408DF8C8:      /* (data) */
    .byte   0x04, 0x2E, 0x58, 0x50, 0x50, 0x20	| 408DF8C8

/* subroutine (87 instructions): calls rsrc_drvr_9_26D2, rsrc_drvr_9_2364, rsrc_drvr_9_2672; low memory SPATalkB (mechanical summary) */
PSTR_XPP_408DF8C8_6:
    moveq #0,%d0	| 408DF8CE
    movew %a2@(2596),%d0	| 408DF8D0
    cmpw %a4@(-2),%d0	| 408DF8D4
    jbls PSTR_XPP_408DF8C8_16	| 408DF8D8
    jbra rsrc_drvr_9_2620	| 408DF8DA
PSTR_XPP_408DF8C8_16:   /* save registers */
    moveml %d2/%a4-%a5,%sp@-	| 408DF8DE
    lea %a2@(1056),%a5
    moveq #0,%d0
    movel %fp@(44),%d2
    movew #256,%d0
    jbra rsrc_drvr_9_2546
rsrc_drvr_9_2542:       /* loop: cmp */
    cmpl %a5@,%d2
    addqw #6,%a5
rsrc_drvr_9_2546:       /* count down */
    dbeq %d0,rsrc_drvr_9_2542
    jbne rsrc_drvr_9_2556
    subql #6,%a5
    movew #1,%a2@(2594)
    jbra rsrc_drvr_9_257C
rsrc_drvr_9_2556:       /* address %a2@(1056) */
    lea %a2@(1056),%a5
    addql #6,%a5
    moveq #0,%d0
    tstw %a2@(2592)
    jbeq rsrc_drvr_9_257C
    movew %a2@(2592),%d0
    jbra rsrc_drvr_9_256E
rsrc_drvr_9_256A:       /* loop: tst */
    tstl %a5@
    addql #6,%a5
rsrc_drvr_9_256E:       /* count down */
    dbeq %d0,rsrc_drvr_9_256A
    jbne rsrc_drvr_9_257C
    movew #1,%a2@(2594)
    subqw #6,%a5
rsrc_drvr_9_257C:       /* address %a2@(1056) */
    lea %a2@(1056),%a4
    movel %a5,%d0
    subl %a4,%d0
    moveal %d0,%a5
    btst #15,%d6
    jbne rsrc_drvr_9_258E
    jbra rsrc_drvr_9_25A0
rsrc_drvr_9_258E:       /* test #0,%a2@(836) */
    cmpiw #0,%a2@(836)
    jbne rsrc_drvr_9_25A0
    jbsr rsrc_drvr_9_26D2
    jbeq rsrc_drvr_9_25E4
    moveq #0,%d0
    jbra rsrc_drvr_9_261C
rsrc_drvr_9_25A0:       /* test %fp@(36) */
    tstl %fp@(36)
    jbeq rsrc_drvr_9_25DE
    movel %fp@(36),%d5
    movew %d5,%d0
    lsrw #8,%d0
    swap %d5
    btst #15,%d6
    jbne rsrc_drvr_9_25C4
    cmpw %a2@(836),%d5
    jbeq rsrc_drvr_9_25D0
    cmpiw #0,%d5
    jbeq rsrc_drvr_9_25D0
    jbra rsrc_drvr_9_25DE
rsrc_drvr_9_25C4:       /* test %a2@(836),%d5 */
    cmpw %a2@(836),%d5
    jblt rsrc_drvr_9_25DE
    cmpw %a2@(838),%d5
    jbgt rsrc_drvr_9_25DE
rsrc_drvr_9_25D0:       /* set %a2@(834) */
    movew %d5,%a2@(834)
    jbsr rsrc_drvr_9_2364
    tstb %a2@(711)
    jbeq rsrc_drvr_9_25E4
rsrc_drvr_9_25DE:       /* call rsrc_drvr_9_2672 */
    jbsr rsrc_drvr_9_2672
    jbne rsrc_drvr_9_25F0
rsrc_drvr_9_25E4:       /* test %a2@(832) */
    tstw %a2@(832)
    jbmi rsrc_drvr_9_25F4
    movew %a2@(26),%d0
    jbra rsrc_drvr_9_25F8
rsrc_drvr_9_25F0:       /* result 0 */
    moveq #0,%d0
    jbra rsrc_drvr_9_261C
rsrc_drvr_9_25F4:       /* set %d0 */
    movew %a2@(834),%d0
rsrc_drvr_9_25F8:       /* from here: swap %d0 */
    swap %d0
    moveb SPATalkB,%d0
    lslw #8,%d0
    tstw %a2@(2594)
    jbne rsrc_drvr_9_260A
    addqw #1,%a2@(2592)
rsrc_drvr_9_260A:       /* clear %a2@(2594) */
    clrw %a2@(2594)
    lea %a2@(1056),%a1
    addal %a5,%a1
    movel %fp@(44),%a1@
    addqw #1,%a1@(4)
rsrc_drvr_9_261C:       /* restore registers */
    moveml %sp@+,%d2/%a4-%a5
rsrc_drvr_9_2620:       /* return */
    rts

/* subroutine (25 instructions): calls rsrc_drvr_9_2364, rsrc_drvr_9_3192; low memory SPATalkB (mechanical summary) */
rsrc_drvr_9_2622:
    movew #254,%d7
rsrc_drvr_9_2626:       /* loop: moveq */
    moveq #0,%d0
    moveb SPATalkB,%d0
    jbsr rsrc_drvr_9_2364
    tstb %a2@(711)
    jbeq rsrc_drvr_9_2664
    btst #15,%d6
    jbne rsrc_drvr_9_2640
    moveq #-95,%d0
    jbra rsrc_drvr_9_2670
rsrc_drvr_9_2640:       /* from here: pea 0xfe */
    pea 0xfe
    movew %a2@(834),%d0
    subiw #-256,%d0
    movel %d0,%sp@-
    jbsr rsrc_drvr_9_3192
    addqw #8,%sp
    addiw #-256,%d0
    movew %d0,%a2@(834)
    dbf %d7,rsrc_drvr_9_2626
    moveq #-95,%d0
    jbra rsrc_drvr_9_2670
rsrc_drvr_9_2664:       /* set %a2@(26) */
    movew %a2@(834),%a2@(26)
    moveb SPATalkB,%a2@
    moveq #0,%d0
rsrc_drvr_9_2670:       /* return */
    rts

/* subroutine (32 instructions): calls rsrc_drvr_9_3192, rsrc_drvr_9_2364; low memory SPATalkB (mechanical summary) */
rsrc_drvr_9_2672:
    movew %a2@(836),%sp@-
    moveq #0,%d7
    tstw %a2@(832)
    jbpl rsrc_drvr_9_2672_12
    movew %a2@(838),%d7
    subw %sp@,%d7
rsrc_drvr_9_2672_12:    /* clear %d0 */
    moveq #0,%d0
    movew %a2@(838),%d0
    subw %sp@,%d0
    movel %d0,%sp@-
rsrc_drvr_9_2672_1C:    /* loop: move */
    movew %a2@(834),%d0
    subw %sp@(4),%d0
    movel %d0,%sp@-
    jbsr rsrc_drvr_9_3192
    addqw #4,%sp
    addw %sp@(4),%d0
    movew %d0,%a2@(834)
    moveq #0,%d0
    moveb SPATalkB,%d0
    jbsr rsrc_drvr_9_2364
    tstb %a2@(711)
    jbne rsrc_drvr_9_2672_56
    tstb %a2@
    jbne rsrc_drvr_9_2672_52
    movew %a2@(834),%a2@(26)
    moveb SPATalkB,%a2@
rsrc_drvr_9_2672_52:    /* result 0 */
    moveq #0,%d0
    jbra rsrc_drvr_9_2672_5C
rsrc_drvr_9_2672_56:    /* count down */
    dbf %d7,rsrc_drvr_9_2672_1C
    moveq #-95,%d0
rsrc_drvr_9_2672_5C:    /* add 6 to %sp */
    addqw #6,%sp
    rts

/* subroutine (42 instructions): calls rsrc_drvr_9_2364, rsrc_drvr_9_274E; low memory SPATalkB (mechanical summary) */
rsrc_drvr_9_26D2:
    tstl %fp@(36)
    jbeq rsrc_drvr_9_26D2_30
    movel %fp@(36),%d5
    movew %d5,%d0
    lsrw #8,%d0
    swap %d5
    btst #15,%d6
    jbeq rsrc_drvr_9_26D2_22
    cmpiw #0,%d5
    jbeq rsrc_drvr_9_26D2_30
    cmpiw #-1,%d5
    jbeq rsrc_drvr_9_26D2_30
rsrc_drvr_9_26D2_22:    /* set %a2@(834) */
    movew %d5,%a2@(834)
    jbsr rsrc_drvr_9_2364
    tstb %a2@(711)
    jbeq rsrc_drvr_9_26D2_78
rsrc_drvr_9_26D2_30:    /* test %a2@(834) */
    tstw %a2@(834)
    jbeq rsrc_drvr_9_26D2_44
    moveb SPATalkB,%d0
    jbsr rsrc_drvr_9_2364
    tstb %a2@(711)
    jbeq rsrc_drvr_9_26D2_78
rsrc_drvr_9_26D2_44:    /* test %a2@(2602) */
    tstw %a2@(2602)
    jbeq rsrc_drvr_9_26D2_56
    movew %a2@(2602),%d0
    movew %a2@(2604),%d7
    jbsr rsrc_drvr_9_274E
    jbeq rsrc_drvr_9_26D2_78
rsrc_drvr_9_26D2_56:    /* test %fp@(50) */
    tstw %fp@(50)
    jbeq rsrc_drvr_9_26D2_68
    movew %fp@(48),%d0
    movew %fp@(50),%d7
    jbsr rsrc_drvr_9_274E
    jbeq rsrc_drvr_9_26D2_78
rsrc_drvr_9_26D2_68:    /* set %d0 */
    movew #-256,%d0
    movew #-2,%d7
    jbsr rsrc_drvr_9_274E
    jbeq rsrc_drvr_9_26D2_78
    moveq #-50,%d0
    jbra rsrc_drvr_9_26D2_7A
rsrc_drvr_9_26D2_78:    /* clear %d0 */
    moveq #0,%d0
rsrc_drvr_9_26D2_7A:    /* return */
    rts

/* subroutine (103 instructions): calls rsrc_drvr_9_3192, rsrc_drvr_9_2364; low memory SPATalkB (mechanical summary) */
rsrc_drvr_9_274E:
    movew %d0,%sp@-
    moveq #0,%d0
    movew %d7,%d0
    subw %sp@,%d7
    subw %sp@,%d0
    movel %d0,%sp@-
rsrc_drvr_9_274E_C:     /* loop: move */
    movew %a2@(834),%d0
    subw %sp@(4),%d0
    movel %d0,%sp@-
    jbsr rsrc_drvr_9_3192
    addqw #4,%sp
    addw %sp@(4),%d0
    movew %d0,%a2@(834)
    moveq #0,%d0
    moveb SPATalkB,%d0
    jbsr rsrc_drvr_9_2364
    tstb %a2@(711)
    jbeq rsrc_drvr_9_274E_3E
    dbf %d7,rsrc_drvr_9_274E_C
    addqw #6,%sp
    moveq #-50,%d0
    jbra rsrc_drvr_9_274E_42
rsrc_drvr_9_274E_3E:    /* add 6 to %sp */
    addqw #6,%sp
    moveq #0,%d0
rsrc_drvr_9_274E_42:    /* return */
    rts
rsrc_drvr_9_2792:       /* loop: moveq */
    moveq #0,%d3	| 408DFB42
    jmp %a4@(2)	| 408DFB44
rsrc_drvr_9_2798:       /* test %a2@(832) */
    tstw %a2@(832)	| 408DFB48
    jbpl rsrc_drvr_9_27CA	| 408DFB4C
    swap %d2	| 408DFB4E
    cmpiw #-2,%d2	| 408DFB50
    jbeq rsrc_drvr_9_2792	| 408DFB54
    moveml %a3-%a4,%sp@-	| 408DFB56
    lea %a2@(1),%a4	| 408DFB5A
    subaw %a4,%a3	| 408DFB5E
    movew #16,%d0	| 408DFB60
    subw %a3,%d0	| 408DFB64
    moveml %sp@+,%a3-%a4	| 408DFB66
    jble rsrc_drvr_9_27C4	| 408DFB6A
    movew %d0,%d3	| 408DFB6C
    jsr %a4@	| 408DFB6E
    jbeq rsrc_drvr_9_27C4	| 408DFB70
    rts	| 408DFB72
rsrc_drvr_9_27C4:       /* set %d0 */
    moveb %a2@(12),%d0	| 408DFB74
    jbra rsrc_drvr_9_2804	| 408DFB78
rsrc_drvr_9_27CA:       /* set %d2 */
    moveb %a2@(3),%d2	| 408DFB7A
    cmpib #1,%d2	| 408DFB7E
    jbeq rsrc_drvr_9_27FE	| 408DFB82
    cmpib #2,%d2	| 408DFB84
    jbne rsrc_drvr_9_2792	| 408DFB88
    moveq #8,%d3	| 408DFB8A
    jsr %a4@	| 408DFB8C
    jbeq rsrc_drvr_9_27E2	| 408DFB8E
    rts	| 408DFB90
rsrc_drvr_9_27E2:       /* set %d0 */
    moveb %a2@(1),%d0	| 408DFB92
    cmpb %a2@(12),%d0	| 408DFB96
    jbne rsrc_drvr_9_2792	| 408DFB9A
    movew %a2@(8),%d0	| 408DFB9C
    cmpw %a2@(26),%d0	| 408DFBA0
    jbeq rsrc_drvr_9_27FE	| 408DFBA4
    cmpiw #0,%d0	| 408DFBA6
    jbeq rsrc_drvr_9_27FE	| 408DFBAA
    jbra rsrc_drvr_9_2792	| 408DFBAC
rsrc_drvr_9_27FE:       /* from here: swap %d2 */
    swap %d2	| 408DFBAE
    moveb %a2@(1),%d0	| 408DFBB0
rsrc_drvr_9_2804:       /* (408DFBB4 cmpib #-1,%d0) */
    cmpib #0xff,%d0	| 408DFBB4 408DFBB4 cmpib #-1,%d0
    jbne rsrc_drvr_9_285E	| 408DFBB8
    movel %a5,%sp@-	| 408DFBBA
    moveq #0,%d0	| 408DFBBC
    lea %a2@(1),%a5	| 408DFBBE
    movel %a3,%d0	| 408DFBC2
    subl %a5,%d0	| 408DFBC4
    lea %a2@(1056),%a5	| 408DFBC6
    movew %a2@(2592),%d3	| 408DFBCA
    jbeq rsrc_drvr_9_2792	| 408DFBCE
    jbra rsrc_drvr_9_2854	| 408DFBD2
rsrc_drvr_9_2824:       /* loop: tst */
    tstl %a5@	| 408DFBD4
    jbeq rsrc_drvr_9_2854	| 408DFBD6
    movel %d0,%sp@-	| 408DFBD8
    moveml %d1/%d3/%a0/%a2/%a5,%sp@-	| 408DFBDA
    moveal %a5@,%a5	| 408DFBDE
    jsr %a5@	| 408DFBE0
    moveml %sp@+,%d1/%d3/%a0/%a2/%a5	| 408DFBE2
    movel %sp@,%d0	| 408DFBE6
    lea %a2@(1),%a3	| 408DFBE8
    subal %d0,%a0	| 408DFBEC
    oriw #1792,%sr	| 408DFBEE
    andiw #-257,%sr	| 408DFBF2
    jbra rsrc_drvr_9_284A	| 408DFBF6
rsrc_drvr_9_2848:       /* loop: move */
    moveb %a0@+,%a3@+	| 408DFBF8
rsrc_drvr_9_284A:       /* count down */
    dbf %d0,rsrc_drvr_9_2848	| 408DFBFA
    moveb %a2@(3),%d2	| 408DFBFE
    movel %sp@+,%d0	| 408DFC02
rsrc_drvr_9_2854:       /* add 6 to %a5 */
    addql #6,%a5	| 408DFC04
    dbf %d3,rsrc_drvr_9_2824	| 408DFC06
    moveal %sp@+,%a5	| 408DFC0A
    rts	| 408DFC0C
rsrc_drvr_9_285E:       /* address %a2@(1056) */
    lea %a2@(1056),%a5	| 408DFC0E
    addaw %d2,%a5	| 408DFC12
    swap %d2	| 408DFC14
    movel %a5@,%d0	| 408DFC16
    jbeq rsrc_drvr_9_2792	| 408DFC18
    moveal %d0,%a5	| 408DFC1C
    jmp %a5@	| 408DFC1E

/* subroutine (14 instructions) (mechanical summary) */
rsrc_drvr_9_2870:
    moveml %d2/%a1/%a3,%sp@-	| 408DFC20
    moveq #-94,%d0	| 408DFC24
    moveq #7,%d2	| 408DFC26
rsrc_drvr_9_2878:       /* (408DFC28 lea %a2@(24,%d2:w),%a3) */
    lea %a2@(0x24,%d2:w),%a3	| 408DFC28 408DFC28 lea %a2@(24,%d2:w),%a3
    cmpib #0x80,%a3@	| 408DFC2C cmpib #-128,%a3@
    dbeq %d2,rsrc_drvr_9_2878	| 408DFC30
    jbeq rsrc_drvr_9_2894	| 408DFC34
    moveq #7,%d2	| 408DFC36
rsrc_drvr_9_2888:       /* (408DFC38 lea %a2@(24,%d2:w),%a3) */
    lea %a2@(0x24,%d2:w),%a3	| 408DFC38 408DFC38 lea %a2@(24,%d2:w),%a3
    tstb %a3@	| 408DFC3C
    dbmi %d2,rsrc_drvr_9_2888	| 408DFC3E
    jbpl rsrc_drvr_9_28A4	| 408DFC42
rsrc_drvr_9_2894:       /* from here: lslw #2,%d2 */
    lslw #2,%d2	| 408DFC44
    lea %pc@(rsrc_drvr_9_2798),%a1	| 408DFC46
    movel %a1,%a2@(0x2c,%d2:w)	| 408DFC4A 408DFC4A movel %a1,%a2@(2c,%d2:w)
    moveb #0x80,%a3@	| 408DFC4E moveb #-128,%a3@
    moveq #0,%d0	| 408DFC52
rsrc_drvr_9_28A4:       /* restore registers, return */
    moveml %sp@+,%d2/%a1/%a3	| 408DFC54
    rts	| 408DFC58

/* Control csCode 245: AttachPH. */
MPP_AttachPH:
    moveq #-94,%d0	| 408DFC5A
    cmpib #0x80,%d1	| 408DFC5C 408DFC5C cmpib #-128,%d1
    jbeq MPP_AttachPH_C	| 408DFC60
    tstb %d1	| 408DFC62
    jble MPP_AttachPH_2C	| 408DFC64
MPP_AttachPH_C:         /* call MPP_AttachPH_30 */
    jbsr MPP_AttachPH_30	| 408DFC66
    jbeq MPP_AttachPH_2C	| 408DFC68
    moveq #7,%d2	| 408DFC6A
MPP_AttachPH_12:        /* (408DFC6C lea %a2@(24,%d2:w),%a3) */
    lea %a2@(0x24,%d2:w),%a3	| 408DFC6C 408DFC6C lea %a2@(24,%d2:w),%a3
    cmpib #0xff,%a3@	| 408DFC70 cmpib #-1,%a3@
    dbeq %d2,MPP_AttachPH_12	| 408DFC74
    tstw %d2	| 408DFC78
    jbmi MPP_AttachPH_2C	| 408DFC7A
    lslw #2,%d2	| 408DFC7C
    movel %a1,%a2@(0x2c,%d2:w)	| 408DFC7E 408DFC7E movel %a1,%a2@(2c,%d2:w)
    moveb %d1,%a3@	| 408DFC82
    clrw %d0	| 408DFC84
MPP_AttachPH_2C:        /* continue at rsrc_drvr_9_status_3A */
    jbra rsrc_drvr_9_status_3A	| 408DFC86

/* subroutine (3 instructions) (mechanical summary) */
MPP_AttachPH_30:
    moveq #7,%d2	| 408DFC8A
MPP_AttachPH_32:        /* (408DFC8C cmpb %a2@(24,%d2:w),%d1) */
    cmpb %a2@(0x24,%d2:w),%d1	| 408DFC8C 408DFC8C cmpb %a2@(24,%d2:w),%d1
    dbeq %d2,MPP_AttachPH_32	| 408DFC90
    rts	| 408DFC94

/* Control csCode 244: DetachPH. */
MPP_DetachPH:
    moveq #-94,%d0	| 408DFC96
    moveq #7,%d2	| 408DFC98
MPP_DetachPH_4:         /* (408DFC9A cmpb %a2@(24,%d2:w),%d1) */
    cmpb %a2@(0x24,%d2:w),%d1	| 408DFC9A 408DFC9A cmpb %a2@(24,%d2:w),%d1
    dbeq %d2,MPP_DetachPH_4	| 408DFC9E
    jbne MPP_DetachPH_14	| 408DFCA2
    st %a2@(0x24,%d2:w)	| 408DFCA4 408DFCA4 st %a2@(24,%d2:w)
    clrw %d0	| 408DFCA8
MPP_DetachPH_14:        /* continue at rsrc_drvr_9_status_3A */
    jbra rsrc_drvr_9_status_3A	| 408DFCAA
rsrc_drvr_9_28FE:       /* set %a3 */
    moveal ExpandMem,%a3
    moveal %a3@(116),%a3
    cmpw %a3@,%d3
    jbcs rsrc_drvr_9_290C
    moveq #0,%d3
rsrc_drvr_9_290C:       /* from here: lslw #4,%d3 */
    lslw #4,%d3
    addiw #650,%d3
    tstl %a3@(0x0,%d3:w)
    jbne rsrc_drvr_9_291A
    rts
rsrc_drvr_9_291A:       /* address %a3@(0x0 */
    lea %a3@(0x0,%d3:w),%a0
    moveb %a2@(712),%d0
    jbmi rsrc_drvr_9_29F8
    tstw %a2@(952)
    jbeq rsrc_drvr_9_293C
    btst #3,%a0@(6)
    jbeq rsrc_drvr_9_293C
    jbsr rsrc_drvr_9_2F84
    jbne rsrc_drvr_9_prime_E
rsrc_drvr_9_293C:       /* test #1,%d0 */
    cmpib #1,%d0
    jbeq rsrc_drvr_9_29E6
    tstw %a2@(2596)
    jbne rsrc_drvr_9_2972
    tstw %a2@(832)
    jbmi rsrc_drvr_9_2956
    cmpb %a2@,%d2
    jbeq rsrc_drvr_9_29AE
    jbra rsrc_drvr_9_296A
rsrc_drvr_9_2956:       /* set %sp@- */
    movel %d0,%sp@-
    moveq #0,%d0
    movew %a2@(26),%d0
    lsll #8,%d0
    moveb %a2@,%d0
    cmpl %d0,%d2
    moveml %sp@+,%d0
    jbeq rsrc_drvr_9_29AE
rsrc_drvr_9_296A:       /* test #0xff,%d2 */
    cmpib #0xff,%d2
    jbne rsrc_drvr_9_29E6
    jbra rsrc_drvr_9_29CC
rsrc_drvr_9_2972:       /* save registers */
    moveml %d0/%a0-%a1,%sp@-
    moveal %a2@(888),%a1
    subaw #44,%sp
    movel %d2,%sp@(28)
    moveq #11,%d0
    pea PortBUse
    movel %sp@+,%sp@(38)
    moveal %sp,%a0
    jsr %a1@(2)
    tstw %d0
    jbeq rsrc_drvr_9_29A0
    lea %sp@(44),%sp
    moveml %sp@+,%d0/%a0-%a1
    jbra rsrc_drvr_9_29E6
rsrc_drvr_9_29A0:       /* set %a2@(2600) */
    movew %sp@(42),%a2@(2600)
    lea %sp@(44),%sp
    moveml %sp@+,%d0/%a0-%a1
rsrc_drvr_9_29AE:       /* test %a2@(2596) */
    tstw %a2@(2596)
    jbeq rsrc_drvr_9_29CC
    cmpib #0xff,%d2
    jbeq rsrc_drvr_9_29DE
    cmpb %a2@,%d2
    jbne rsrc_drvr_9_29F0
    movel %d2,%sp@-
    lsrl #8,%d2
    cmpw %a2@(26),%d2
    moveml %sp@+,%d2
    jbne rsrc_drvr_9_29F0
rsrc_drvr_9_29CC:       /* test %a0@(6) */
    tstb %a0@(6)
    jbmi rsrc_drvr_9_29E6
    tstb %a2@(696)
    jbeq rsrc_drvr_9_29E6
    cmpib #0xff,%d2
    jbne rsrc_drvr_9_29F0
rsrc_drvr_9_29DE:       /* set %a3 */
    moveal %a0,%a3
    lea %pc@(rsrc_drvr_9_29F2),%a0
    jbra rsrc_drvr_9_29EC
rsrc_drvr_9_29E6:       /* loop: movea */
    moveal %a0,%a3
    moveal %a2@(702),%a0
rsrc_drvr_9_29EC:       /* set %d1 */
    movel %sp@+,%d1
    movel %a3@,%sp@-
rsrc_drvr_9_29F0:       /* return */
    rts
rsrc_drvr_9_29F2:       /* set %d2 */
    moveq #-1,%d2	| 408DFDA2
    jbra rsrc_drvr_9_1770_24	| 408DFDA4
rsrc_drvr_9_29F8:       /* address PortBUse */
    lea PortBUse,%a1
    cmpal ABusVars,%a2
    jbeq rsrc_drvr_9_2A0A
    lea %a0@(7),%a1
    moveb #1,%a1@
rsrc_drvr_9_2A0A:       /* from here: st %d0 */
    st %d0
    jbra rsrc_drvr_9_29E6
    .byte   0x4A, 0x6A, 0x03, 0xB8, 0x67, 0x2E	| 408DFDBE
rsrc_drvr_9_2A14:       /* save registers */
    moveml %d0/%d4/%a3,%sp@-	| 408DFDC4
    moveal ExpandMem,%a3	| 408DFDC8
    moveal %a3@(116),%a3	| 408DFDCC
    moveb %a2@(820),%d4	| 408DFDD0
    jbsr rsrc_drvr_9_32F2	| 408DFDD4
    btst #4,%a3@(6,%d0:w)	| 408DFDD8
    moveml %sp@+,%d0/%d4/%a3	| 408DFDDE
    jbeq rsrc_drvr_9_2A42	| 408DFDE2
    lea %pc@(rsrc_drvr_9_2A3E),%a5	| 408DFDE4
    addqw #4,%sp	| 408DFDE8
    jbra rsrc_drvr_9_30F8	| 408DFDEA
rsrc_drvr_9_2A3E:       /* call rsrc_drvr_9_2A42 */
    jbsr rsrc_drvr_9_2A42	| 408DFDEE
    rts	| 408DFDF0

/* subroutine (58 instructions): calls rsrc_drvr_9_3074, rsrc_drvr_9_300C, rsrc_drvr_9_304C, rsrc_drvr_9_2B00 (mechanical summary) */
rsrc_drvr_9_2A42:
    tstw %a2@(832)
    jbpl rsrc_drvr_9_2AC2
    btst #30,%a2@(830)
    jbeq rsrc_drvr_9_2A52
    moveq #0,%d3
rsrc_drvr_9_2A52:       /* add 4 to %sp */
    addqw #4,%sp
    subl %d0,%d0
    movew %a2@(26),%d0
    lsll #8,%d0
    moveb %a2@,%d0
    movel %d0,%sp@-
    subl %d0,%d0
    movew %a2@(8),%d0
    lsll #8,%d0
    moveb %a2@(12),%d0
    cmpl %sp@+,%d0
    jbeq rsrc_drvr_9_434
    cmpib #0xff,%d0
    jbne rsrc_drvr_9_2AAC
    tstw %a2@(2596)
    jbeq rsrc_drvr_9_434
    lea %pc@(rsrc_drvr_9_434),%a5
    jbsr rsrc_drvr_9_3074
    cmpaw #0,%a3
    jbeq rsrc_drvr_9_2AC0
    moveal %a3,%a0
    jbsr rsrc_drvr_9_300C
    movew #128,%a0@(16)
    pea %pc@(rsrc_drvr_9_2AFC)
    movel %sp@+,%a0@(4)
    jbsr rsrc_drvr_9_300C
    jbsr rsrc_drvr_9_304C
    jbra rsrc_drvr_9_2AC0
rsrc_drvr_9_2AAC:       /* from here: lsrl #8,%d0 */
    lsrl #8,%d0
    cmpw %a2@(836),%d0
    jbcs rsrc_drvr_9_434
    cmpw %a2@(838),%d0
    jbhi rsrc_drvr_9_434
    jbsr rsrc_drvr_9_2B00
rsrc_drvr_9_2AC0:       /* return */
    rts
rsrc_drvr_9_2AC2:       /* set %d0 */
    moveb %a2@(1),%d0
    cmpb %a2@,%d0
    jbeq rsrc_drvr_9_2B04
    cmpib #0xff,%d0
    jbne rsrc_drvr_9_2B00
    tstw %a2@(2596)
    jbeq rsrc_drvr_9_2B04
    lea %pc@(rsrc_drvr_9_2AFC),%a5
    jbsr rsrc_drvr_9_3074
    cmpaw #0,%a3
    jbeq rsrc_drvr_9_2AF8
    moveal %a3,%a0
    jbsr rsrc_drvr_9_300C
    movew #128,%a0@(16)
    jbsr rsrc_drvr_9_300C
    jbsr rsrc_drvr_9_304C
rsrc_drvr_9_2AF8:       /* add 4 to %sp */
    addqw #4,%sp
    jbra rsrc_drvr_9_2B04_42

/* subroutine (2 instructions): calls rsrc_drvr_9_2B04 (mechanical summary) */
rsrc_drvr_9_2AFC:
    jbsr rsrc_drvr_9_2B04
    rts

/* subroutine (1 instructions) (mechanical summary) */
rsrc_drvr_9_2B00:
    moveb #0x80,%d2

/* subroutine (24 instructions) (mechanical summary) */
rsrc_drvr_9_2B04:
    cmpib #1,%d2
    jbne rsrc_drvr_9_2B04_C
    movel %a2@(72),%sp@
    rts
rsrc_drvr_9_2B04_C:     /* test #2,%d2 */
    cmpib #2,%d2
    jbne rsrc_drvr_9_2B04_18
    movel %a2@(68),%sp@
    rts
rsrc_drvr_9_2B04_18:    /* test #0x80,%d2 */
    cmpib #0x80,%d2
    jbne rsrc_drvr_9_2B04_24
    movel %a2@(64),%sp@
    rts
rsrc_drvr_9_2B04_24:    /* clear %d0 */
    moveq #0,%d0
    moveb %a2@(34),%d0
    movew %d0,%d3
    subqw #3,%d0
    jbra rsrc_drvr_9_2B04_34
rsrc_drvr_9_2B04_30:    /* loop: cmp */
    cmpb %a2@(0x24,%d0:w),%d2
rsrc_drvr_9_2B04_34:    /* count down */
    dbeq %d0,rsrc_drvr_9_2B04_30
    jbne rsrc_drvr_9_2B04_42
    lslw #2,%d0
    addw %d3,%d0
    movel %a2@(0x24,%d0:w),%sp@
rsrc_drvr_9_2B04_42:    /* return */
    rts

/* subroutine (191 instructions): traps trap_A404; calls rsrc_drvr_9_2DB0, rsrc_drvr_9_2E04; low memory ExpandMem (mechanical summary) */
rsrc_drvr_9_2B48:
    linkw %fp,#0
    movel %a2,%sp@-
    moveal ExpandMem,%a1
    moveal %a1@(116),%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    lea %a1@(636),%a2
    moveal %fp@(8),%a0
    tstl %a0@
    jbne rsrc_drvr_9_2B48_2E
rsrc_drvr_9_2B48_24:    /* loop: move */
    movel %a2@(2),%d0
    jbeq rsrc_drvr_9_2B48_44
    moveal %d0,%a2
    jbra rsrc_drvr_9_2B48_4A
rsrc_drvr_9_2B48_2E:    /* address %a2@(2) */
    lea %a2@(2),%a2
    jbra rsrc_drvr_9_2B48_3A
rsrc_drvr_9_2B48_34:    /* loop: movea */
    moveal %d0,%a2
    cmpal %a0@,%a2
    jbeq rsrc_drvr_9_2B48_4A
rsrc_drvr_9_2B48_3A:    /* set %d0 */
    movel %a2@,%d0
    jbne rsrc_drvr_9_2B48_34
    lea %a1@(636),%a2
    jbra rsrc_drvr_9_2B48_24
rsrc_drvr_9_2B48_44:    /* set %sr */
    movew %sp@+,%sr
    moveq #0,%d0
    jbra rsrc_drvr_9_2B48_62
rsrc_drvr_9_2B48_4A:    /* set %a0@ */
    movel %a2@,%a0@
    moveal %a2@(6),%a0
    movew %sp@+,%sr
    movel %fp@(16),%sp@-
    movel %a2,%sp@-
    movel %fp@(12),%sp@-
    jsr %a0@
    lea %sp@(12),%sp
rsrc_drvr_9_2B48_62:    /* set %a2 */
    moveal %sp@+,%a2
    unlk %fp
    rts
rsrc_drvr_9_2BB0:       /* loop: move */
    movew %d0,%a0@(16)	| 408DFF60
    movel %a0@(12),%d1	| 408DFF64
    jbeq rsrc_drvr_9_2BC0	| 408DFF68
    moveal %d1,%a1	| 408DFF6A
    tstw %d0	| 408DFF6C
    jsr %a1@	| 408DFF6E
rsrc_drvr_9_2BC0:       /* return */
    rts	| 408DFF70
rsrc_drvr_9_2BC2:       /* set %a2 */
    moveal ABusVars,%a2	| 408DFF72
    moveq #-93,%d0	| 408DFF76
    tstb %a2@(25)	| 408DFF78
    jbeq rsrc_drvr_9_2BB0	| 408DFF7C
    lea %a0@(50),%a1	| 408DFF7E
    tstw %a0@(42)	| 408DFF82
    jbne rsrc_drvr_9_2C0C	| 408DFF86
    movew %a0@(28),%d0	| 408DFF88
    movel %a2@(826),%d1	| 408DFF8C
    lsll #8,%d1	| 408DFF90
    moveb #6,%d1	| 408DFF92
    movel %d1,%a1@(30)	| 408DFF96
    movew #1792,%a1@(18)	| 408DFF9A
    cmpiw #7,%d0	| 408DFFA0
    jbeq rsrc_drvr_9_2C0C	| 408DFFA4
    addqw #1,%a0@(42)	| 408DFFA6
    movew #2304,%a1@(18)	| 408DFFAA
    cmpiw #5,%d0	| 408DFFB0
    jbeq rsrc_drvr_9_2C0C	| 408DFFB4
    movew #2048,%a1@(18)	| 408DFFB6
rsrc_drvr_9_2C0C:       /* set %a1@(20) */
    movew %a0@(42),%a1@(20)	| 408DFFBC
    clrb %a1@(29)	| 408DFFC2
    clrw %a1@(34)	| 408DFFC6
    lea %a0@(100),%a2	| 408DFFCA
    movew #578,%a2@	| 408DFFCE
    movel %a0@(34),%a2@(2)	| 408DFFD2
    movel %a2,%a1@(40)	| 408DFFD8
    moveb #1,%a1@(44)	| 408DFFDC
    moveb %a0@(30),%a1@(45)	| 408DFFE2
    moveb %a0@(31),%a1@(47)	| 408DFFE8
    moveal %a1,%a0	| 408DFFEE
    lea %pc@(rsrc_drvr_9_2C5A),%a3	| 408DFFF0
    movel %a3,%a0@(12)	| 408DFFF4
    movew #-11,%a0@(24)	| 408DFFF8
    .byte   0x31, 0x7C	| 408DFFFE

    .byte   0x00, 0xFF, 0x00, 0x1A	| 408E0000
    .short 0xA404	/* 408E0004 A-line trap */
    moveq #0,%d0	| 408E0006
    rts	| 408E0008
rsrc_drvr_9_2C5A:       /* address %a0@(-50) */
    lea %a0@(-50),%a1	| 408E000A
    jbne rsrc_drvr_9_2C78	| 408E000E
    moveal %a0@(40),%a2	| 408E0010
    moveb %a2@(8),%a1@(40)	| 408E0014
    movew %a2@(10),%d0	| 408E001A
    movew %d0,%a1@(38)	| 408E001E
    addw %d0,%a1@(42)	| 408E0022
    moveq #0,%d0	| 408E0026
rsrc_drvr_9_2C78:       /* set %a0 */
    moveal %a1,%a0	| 408E0028
    jbra rsrc_drvr_9_2BB0	| 408E002A
rsrc_drvr_9_2C7E:       /* subtract 1 to %a3@- */
    subqb #1,%a3@-	| 408E002E
    jbeq rsrc_drvr_9_2C88	| 408E0030
    clrw %d3	| 408E0032
    jmp %a4@(2)	| 408E0034
rsrc_drvr_9_2C88:       /* (data) */
    lea %a2@(2),%a3	| 408E0038
    moveq #4,%d3
    jsr %a4@
    jbne rsrc_drvr_9_2D02
    movew %d1,%d3
    jbne rsrc_drvr_9_2CA0
    jsr %a4@(2)
    jbne rsrc_drvr_9_2D02
    moveq #1,%d3
    jbra rsrc_drvr_9_2CC4
rsrc_drvr_9_2CA0:       /* set %d3 */
    movew #6,%d3
    cmpw %d3,%d1
    jbls rsrc_drvr_9_2CBE
    jsr %a4@
    jbne rsrc_drvr_9_2D02
    movel %a2@(1040),%d0
    jbeq rsrc_drvr_9_2CBC
    moveal %d0,%a5
    moveq #2,%d0
    jsr %a5@
    jbeq rsrc_drvr_9_2CC4
    jbra rsrc_drvr_9_2D02
rsrc_drvr_9_2CBC:       /* clear %d3 */
    moveq #0,%d3
rsrc_drvr_9_2CBE:       /* jump through %a4@(2) */
    jsr %a4@(2)
    jbne rsrc_drvr_9_2D02
rsrc_drvr_9_2CC4:       /* address %a2@(2) */
    lea %a2@(2),%a3
    moveb %a3@(3),%d2
    jbeq rsrc_drvr_9_2D02
    cmpib #8,%a3@(2)
    jbne rsrc_drvr_9_2D02
    swap %d2
    movew %a3@,%d2
    jbeq rsrc_drvr_9_2D02
    tstw %a2@(832)
    jbmi rsrc_drvr_9_2D04
    movew %d2,%a2@(26)
    movew %d2,%a2@(836)
    movew %d2,%a2@(838)
    swap %d2
    moveb %d2,%a2@(25)
rsrc_drvr_9_2CF4:       /* loop: as */
    aslw #8,%d2
    rorl #8,%d2
    movel %d2,%a2@(826)
    moveb #0x96,%a2@(720)
rsrc_drvr_9_2D02:       /* return */
    rts
rsrc_drvr_9_2D04:       /* test %d3 */
    tstw %d3
    jbgt rsrc_drvr_9_2D02
    moveb %a3@(7),%d0
    lslw #8,%d0
    moveb %a3@(8),%d0
    tstw %d0
    jbeq rsrc_drvr_9_2D02
    cmpiw #-256,%d0
    jbcc rsrc_drvr_9_2D02
    tstw %a3@(4)
    jbeq rsrc_drvr_9_2D02
    cmpw %a3@(4),%d0
    jbcs rsrc_drvr_9_2D02
    cmpw %d0,%d2
    jbhi rsrc_drvr_9_2D02
    cmpw %a3@(4),%d2
    jbcs rsrc_drvr_9_2D02
    cmpiw #-256,%a2@(26)
    jbcc rsrc_drvr_9_2D9E
    movew %a2@(836),%d1
    jbeq rsrc_drvr_9_2D54
    cmpw %a3@(4),%d1
    jbne rsrc_drvr_9_2D02
    cmpw %a2@(838),%d0
    jbne rsrc_drvr_9_2D02
    tstb %a2@(850)
    jbeq rsrc_drvr_9_2D7E
    jbra rsrc_drvr_9_2D92
rsrc_drvr_9_2D54:       /* set %d1 */
    movew %a2@(26),%d1
    cmpw %a3@(4),%d1
    jbcs rsrc_drvr_9_2DA6
    cmpw %d0,%d1
    jbhi rsrc_drvr_9_2DA6
    movew %a2@(836),%a2@(2602)
    movew %a2@(838),%a2@(2604)
    movew %a3@(4),%a2@(836)
    movew %d0,%a2@(838)
    movew #1,%a2@(2606)
rsrc_drvr_9_2D7E:       /* set %d0 */
    movew %sr,%d0
    andiw #-1793,%d0
    eoriw #8192,%d0
    movew %a2@(28),%sp@-
    eorw %d0,%sp@
    movew %sp@+,%sr
    jbsr rsrc_drvr_9_2DB0
rsrc_drvr_9_2D92:       /* set %a2@(25) */
    moveb #0xfe,%a2@(25)
    swap %d2
    jbra rsrc_drvr_9_2CF4
rsrc_drvr_9_2D9E:       /* set bit 4 of %a2@(833) */
    bset #4,%a2@(833)
    jbra rsrc_drvr_9_2DAC
rsrc_drvr_9_2DA6:       /* set bit 5 of %a2@(833) */
    bset #5,%a2@(833)
rsrc_drvr_9_2DAC:       /* call rsrc_drvr_9_2E04 */
    jbsr rsrc_drvr_9_2E04
    rts

/* subroutine (25 instructions): traps Control; low memory ABusVars (mechanical summary) */
rsrc_drvr_9_2DB0:
    moveal ABusVars,%a2
    btst #11,%a2@(832)
    jbeq rsrc_drvr_9_2DB0_4C
    movel %a2@(934),%d0
    jbeq rsrc_drvr_9_2DB0_4C
    moveal %d0,%a0
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    tstw %a0@
    jbeq rsrc_drvr_9_2DB0_26
    movew %sp@+,%sr
    jbra rsrc_drvr_9_2DB0_4C
rsrc_drvr_9_2DB0_26:    /* set %a0@ */
    movew #257,%a0@
    movew %sp@+,%sr
    subaw #26,%a0
    lea %pc@(rsrc_drvr_9_2DB0_4E),%a1
    movel %a1,%a0@(12)
    lea %a2@(854),%a1
    movel %a1,%a0@(30)
    moveal %a2@(816),%a1
    movew %a1@(24),%a0@(24)
    .short  0xA404	| 408E01AA _Control (flags 0x0400)
rsrc_drvr_9_2DB0_4C:    /* return */
    rts
rsrc_drvr_9_2DB0_4E:    /* clear %a0@(26) */
    clrw %a0@(26)
    rts

/* subroutine (27 instructions): calls rsrc_drvr_9_2E52 (mechanical summary) */
rsrc_drvr_9_2E04:
    movel %a2@(830),%d0
    btst #11,%d0
    jbeq rsrc_drvr_9_2E04_16
    btst #4,%d0
    jbne rsrc_drvr_9_2E04_34
    btst #5,%d0
    jbne rsrc_drvr_9_2E04_34
rsrc_drvr_9_2E04_16:    /* test bit 7 of %d0 */
    btst #7,%d0
    jbeq rsrc_drvr_9_2E04_4C
    btst #6,%d0
    jbne rsrc_drvr_9_2E04_4C
    btst #29,%d0
    jbeq rsrc_drvr_9_2E04_2E
    btst #11,%d0
    jbeq rsrc_drvr_9_2E04_4C
rsrc_drvr_9_2E04_2E:    /* set %d1 */
    moveq #1,%d1
    jbsr rsrc_drvr_9_2E52
    jbra rsrc_drvr_9_2E04_4C
rsrc_drvr_9_2E04_34:    /* test bit 28 of %d0 */
    btst #28,%d0
    jbne rsrc_drvr_9_2E04_4C
    moveq #3,%d1
    btst #4,%d0
    jbne rsrc_drvr_9_2E04_44
    moveq #4,%d1
rsrc_drvr_9_2E04_44:    /* call rsrc_drvr_9_2E52 */
    jbsr rsrc_drvr_9_2E52
    bset #28,%a2@(830)
rsrc_drvr_9_2E04_4C:    /* return */
    rts

/* subroutine (7 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_drvr_9_2E52:
    movel %a2@(830),%d0
    btst #13,%d0
    jbne rsrc_drvr_9_2E52_C
    rts
rsrc_drvr_9_2E52_C:     /* set %a0 */
    moveal ATalkHk2,%a0
    moveq #20,%d0
    jmp %a0@(2)

/* subroutine (30 instructions) (mechanical summary) */
rsrc_drvr_9_2E68:
    movew #20,%a0@(10)	| 408E0218
    moveal ABusVars,%a2	| 408E021E
    tstb %a2@(720)	| 408E0222
    jbeq rsrc_drvr_9_2ED0	| 408E0226
    subqb #1,%a2@(720)	| 408E0228
    jbne rsrc_drvr_9_2ED0	| 408E022C
    movel %a2@(1040),%d0	| 408E022E
    jbeq rsrc_drvr_9_2E8C	| 408E0232
    moveal %d0,%a1	| 408E0234
    moveq #5,%d0	| 408E0236
    jsr %a1@	| 408E0238
    jbne rsrc_drvr_9_2E96	| 408E023A
rsrc_drvr_9_2E8C:       /* clear %d0 */
    moveq #0,%d0	| 408E023C
    moveb %d0,%a2@(25)	| 408E023E
    movel %d0,%a2@(826)	| 408E0242
rsrc_drvr_9_2E96:       /* set %a2@(2602) */
    movew %a2@(836),%a2@(2602)	| 408E0246
    movew %a2@(838),%a2@(2604)	| 408E024C
    moveq #0,%d0	| 408E0252
    movel %d0,%a2@(836)	| 408E0254
    subqw #2,%a2@(838)	| 408E0258
    tstw %a2@(832)	| 408E025C
    jbpl rsrc_drvr_9_2ED0	| 408E0260
    clrb %a2@(850)	| 408E0262
    moveq #6,%d0	| 408E0266
    lea %a2@(844),%a1	| 408E0268
    moveal %a2@(888),%a0	| 408E026C
    jsr %a0@(2)	| 408E0270
    bclr #28,%a2@(830)	| 408E0274
    movew #1,%a2@(2606)	| 408E027A
rsrc_drvr_9_2ED0:       /* return */
    rts	| 408E0280

/* subroutine (36 instructions): traps NewPtr, Gestalt, StripAddress, DisposPtr; calls rsrc_drvr_9_2F4A_24 (mechanical summary) */
rsrc_drvr_9_2ED2:
    moveml %d1/%a0-%a1,%sp@-
    movew #9,%d1
rsrc_drvr_9_2ED2_8:     /* loop: move */
    movel #627,%d0
    .short  0xA71E	| 408E0290 _NewPtr (flags 0x0700)
    jbne rsrc_drvr_9_2ED2_60
    movel %a2@(944),%a0@
    movel %a0,%a2@(944)
    dbf %d1,rsrc_drvr_9_2ED2_8
    movel #1986863136,%d0
    .short  0xA1AD	| 408E02A6 _Gestalt (flags 0x0100)
    jbne rsrc_drvr_9_2ED2_58
    movel %a0,%d0
    jbeq rsrc_drvr_9_2ED2_58
    movew #1,%a2@(952)
    movel #611,%d0
    .short  0xA71E	| 408E02BA _NewPtr (flags 0x0700)
    jbne rsrc_drvr_9_2ED2_70
    movel %a0,%a2@(948)
    movew #40,%d0
    jbsr rsrc_drvr_9_2F4A_24
    movew #160,%d0
    jbsr rsrc_drvr_9_2F4A_24
    lea %pc@(rsrc_drvr_9_2A14),%a0
    movel %a0,%d0
    _StripAddress
    movel %d0,%a2@(1052)
rsrc_drvr_9_2ED2_58:    /* restore registers, return */
    moveml %sp@+,%d1/%a0-%a1
    moveq #0,%d0
    rts
rsrc_drvr_9_2ED2_60:    /* loop: lea */
    lea %a2@(944),%a1
    movel %a1@,%d0
    jbeq rsrc_drvr_9_2ED2_70
    moveal %d0,%a0
    movel %a0@,%a1@
    _DisposPtr
    jbra rsrc_drvr_9_2ED2_60
rsrc_drvr_9_2ED2_70:    /* restore registers, return */
    moveml %sp@+,%d1/%a0-%a1
    moveq #-108,%d0
    rts

/* subroutine (14 instructions): traps DisposPtr (mechanical summary) */
rsrc_drvr_9_2F4A:
    moveml %d0/%a0-%a1,%sp@-
    movel %a2@(948),%d0
    jbeq rsrc_drvr_9_2F4A_E
    moveal %d0,%a0
    _DisposPtr
rsrc_drvr_9_2F4A_E:     /* loop: lea */
    lea %a2@(944),%a1
    movel %a1@,%d0
    jbeq rsrc_drvr_9_2F4A_1E
    moveal %d0,%a0
    movel %a0@,%a1@
    _DisposPtr
    jbra rsrc_drvr_9_2F4A_E
rsrc_drvr_9_2F4A_1E:    /* restore registers, return */
    moveml %sp@+,%d0/%a0-%a1
    rts

/* subroutine (7 instructions): low memory UTableBase (mechanical summary) */
rsrc_drvr_9_2F4A_24:
    moveal UTableBase,%a0
    movel %a0@(0x0,%d0:w),%d0
    jbeq rsrc_drvr_9_2F4A_38
    moveal %d0,%a0
    moveal %a0@,%a0
    bset #0,%a0@(5)
rsrc_drvr_9_2F4A_38:    /* return */
    rts

/* subroutine (41 instructions): traps BlockMove; low memory ABusVars (mechanical summary) */
rsrc_drvr_9_2F84:
    moveml %d0/%d3/%a0/%a2,%sp@-
    moveal %a2@(948),%a0
    lea %a0@(8),%a0
    moveq #0,%d0
rsrc_drvr_9_2F84_E:     /* loop: move */
    movew %a1@+,%d3
    jbeq rsrc_drvr_9_2F84_26
    addw %d3,%d0
    cmpiw #603,%d0
    jbhi rsrc_drvr_9_2F84_42
    moveal %a1@+,%a2
    subqw #1,%d3
rsrc_drvr_9_2F84_1E:    /* loop: move */
    moveb %a2@+,%a0@+
    dbf %d3,rsrc_drvr_9_2F84_1E
    jbra rsrc_drvr_9_2F84_E
rsrc_drvr_9_2F84_26:    /* set %a1 */
    moveal ABusVars,%a1
    moveal %a1@(948),%a1
    movew %d0,%a1@
    movel %a1,%a1@(2)
    addql #8,%a1@(2)
    moveml %sp@+,%d0/%d3/%a0/%a2
    clrw %a1@(6)
    rts
rsrc_drvr_9_2F84_42:    /* restore registers, return */
    moveml %sp@+,%d0/%d3/%a0/%a2
    moveq #-95,%d0
    rts
rsrc_drvr_9_2FCE:       /* continue at rsrc_drvr_9_2FEE */
    jbra rsrc_drvr_9_2FEE	| 408E037E
    .byte   0xB2, 0x43, 0x6F, 0x08, 0x3F, 0x03, 0x96, 0x41, 0x32, 0x1F, 0x60, 0x02, 0x96, 0x41, 0x70, 0x00	| 408E0380
    .byte   0x30, 0x01, 0x22, 0x4B, 0xA0, 0x2E, 0xD0, 0xC1, 0xD6, 0xC1, 0x70, 0x00, 0x4E, 0x75	| 408E0390
rsrc_drvr_9_2FEE:       /* test %d3,%d1 */
    cmpw %d3,%d1	| 408E039E
    jbge rsrc_drvr_9_2FF8	| 408E03A0
    subw %d1,%d3	| 408E03A2
    moveq #-4,%d0	| 408E03A4
    rts	| 408E03A6
rsrc_drvr_9_2FF8:       /* from here: subw %d3,%d1 */
    subw %d3,%d1	| 408E03A8
    moveq #0,%d0	| 408E03AA
    movew %d3,%d0	| 408E03AC
    moveal %a3,%a1	| 408E03AE
    _BlockMove	| 408E03B0
    addaw %d3,%a0	| 408E03B2
    addaw %d3,%a3	| 408E03B4
    moveq #0,%d3	| 408E03B6
    moveq #0,%d0	| 408E03B8
    rts	| 408E03BA

/* subroutine (18 instructions) (mechanical summary) */
rsrc_drvr_9_300C:
    moveml %a0/%a4-%a5,%sp@-
    moveal %a0,%a1
    lea %a1@(24),%a0
    movew %a1@(22),%d1
    moveal %a1@(8),%a2
    lea %a2@(1),%a3
    oriw #1792,%sr
    andiw #-257,%sr
    movew %a1@(12),%d0
rsrc_drvr_9_300C_22:    /* loop: move */
    moveb %a0@+,%a3@+
    dbf %d0,rsrc_drvr_9_300C_22
    movel %a1@(14),%d2
    movel %a1@(18),%d3
    lea %pc@(rsrc_drvr_9_2FCE),%a4
    moveal %a1@(4),%a5
    jsr %a5@
    moveml %sp@+,%a0/%a4-%a5
    rts

/* subroutine (12 instructions): calls rsrc_drvr_9_300C, rsrc_drvr_9_304C; low memory ABusVars (mechanical summary) */
rsrc_drvr_9_304C:
    movew %sr,%sp@-
    clrw %a0@(22)
    moveal ABusVars,%a2
    oriw #1792,%sr
    andiw #-257,%sr
    movel %a2@(944),%a0@
    movel %a0,%a2@(944)
    movew %sp@+,%sr
    rts
rsrc_drvr_9_306A:       /* call rsrc_drvr_9_300C */
    bsrw rsrc_drvr_9_300C
    bsrw rsrc_drvr_9_304C
    rts

/* subroutine (51 instructions): traps DeferUserFn; calls rsrc_drvr_9_3074 (mechanical summary) */
rsrc_drvr_9_3074:
    movel %a5,%sp@-
    lea %a2@(1),%a5
    movel %a3,%d0
    subl %a5,%d0
    moveml %d0-%d3,%sp@-
    cmpiw #5,%d0
    jblt rsrc_drvr_9_3074_78
    movel %a2@(944),%d3
    jbeq rsrc_drvr_9_3074_78
    moveal %d3,%a5
    lea %a5@(0x18,%d0:w),%a3
    negw %d0
    addiw #603,%d0
    cmpw %d0,%d1
    jbhi rsrc_drvr_9_3074_78
    movew %d1,%d3
    jsr %a4@(2)
    moveaw %d3,%a1
    moveml %sp@+,%d0-%d3
    moveml %sp@+,%a0
    jbne rsrc_drvr_9_3074_74
    movew %a1,%sp@-
    moveal %a2@(944),%a3
    movel %d3,%a3@(18)
    movel %d2,%a3@(14)
    movew %d1,%a3@(22)
    subqw #1,%d0
    movew %d0,%a3@(12)
    movel %a0,%a3@(4)
    movel %a2,%a3@(8)
    tstw %sp@+
    jbne rsrc_drvr_9_3074_74
    movel %a3@,%a2@(944)
    lea %a3@(24),%a0
    lea %a2@(1),%a1
rsrc_drvr_9_3074_6C:    /* loop: move */
    moveb %a1@+,%a0@+
    dbf %d0,rsrc_drvr_9_3074_6C
    rts
rsrc_drvr_9_3074_74:    /* loop: suba */
    subal %a3,%a3
    rts
rsrc_drvr_9_3074_78:    /* address %sp@(20) */
    lea %sp@(20),%sp
    moveq #0,%d3
    jsr %a4@(2)
    jbra rsrc_drvr_9_3074_74
rsrc_drvr_9_30F8:       /* call rsrc_drvr_9_3074 */
    jbsr rsrc_drvr_9_3074	| 408E04A8
    cmpaw #0,%a3	| 408E04AC
    jbeq rsrc_drvr_9_310A	| 408E04B0
    movel %a3,%d0	| 408E04B2
    lea %pc@(rsrc_drvr_9_306A),%a0	| 408E04B4
    _DeferUserFn	| 408E04B8 408E04B8 A-line trap
rsrc_drvr_9_310A:
    rts	| 408E04BA

/* subroutine (31 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_drvr_9_310C:
    linkw %fp,#0
    movel %d3,%sp@-
    movew %sr,%d1
    oriw #1792,%sr
    andiw #-257,%sr
    moveal ATalkHk2,%a1
    moveq #25,%d0
    jsr %a1@(2)
    moveq #0,%d3
    movel %a1@(2),%d0
rsrc_drvr_9_310C_20:    /* loop: jbeq */
    jbeq rsrc_drvr_9_310C_2C
    movel %d0,%sp@-
    addqw #1,%d3
    moveal %d0,%a1
    movel %a1@,%d0
    jbra rsrc_drvr_9_310C_20
rsrc_drvr_9_310C_2C:    /* set %sr */
    movew %d1,%sr
    tstl %d3
    jbeq rsrc_drvr_9_310C_4E
    subqw #1,%d3
rsrc_drvr_9_310C_34:    /* loop: movea */
    moveal %sp@+,%a1
    movel %fp@(8),%sp@-
    movel %a1,%sp@-
    movel %fp@(12),%sp@-
    moveal %a1@(6),%a1
    jsr %a1@
    lea %sp@(12),%sp
    dbf %d3,rsrc_drvr_9_310C_34
rsrc_drvr_9_310C_4E:    /* set %d3 */
    movel %sp@+,%d3
    unlk %fp
    rts

/* subroutine (19 instructions): traps Gestalt, StripAddress; low memory ROMBase (mechanical summary) */
rsrc_drvr_9_3160:
    moveml %d1/%a1,%sp@-
    moveal %a0,%a1
    movel #1919905056,%d0
    .short  0xA1AD	| 408E051C _Gestalt (flags 0x0100)
    movel %a0,%d1
    movel %a1,%d0
    _StripAddress
    moveal %d0,%a0
    movel ROMBase,%d0
    _StripAddress
    cmpal %d0,%a0
    jbcs rsrc_drvr_9_3160_28
    addl %d0,%d1
    moveq #0,%d0
    cmpal %d1,%a0
    jbcs rsrc_drvr_9_3160_2A
rsrc_drvr_9_3160_28:    /* set %d0 */
    moveq #-1,%d0
rsrc_drvr_9_3160_2A:    /* test %d0 */
    tstl %d0
    moveml %sp@+,%d1/%a1
    rts

/* subroutine (34 instructions): calls rsrc_drvr_9_334E (mechanical summary) */
rsrc_drvr_9_3192:
    linkw %fp,#0
    moveml %d5-%d7,%sp@-
    movew %fp@(14),%d5
    moveq #2,%d7
    jbra rsrc_drvr_9_3192_12
rsrc_drvr_9_3192_10:    /* loop: ls */
    lsll #1,%d7
rsrc_drvr_9_3192_12:    /* clear %d0 */
    moveq #0,%d0
    movew %d5,%d0
    cmpl %d7,%d0
    jbcc rsrc_drvr_9_3192_10
    moveq #0,%d6
    movew %fp@(10),%d6
    tstl %d6
rsrc_drvr_9_3192_22:    /* loop: move */
    movel %d6,%d1
    movel %d1,%d0
    muluw #21,%d1
    swap %d0
    muluw #21,%d0
    swap %d0
    clrw %d0
    addl %d0,%d1
    addql #1,%d1
    movel %d1,%d0
    movel %d7,%d1
    jsr %pc@(rsrc_drvr_9_334E)
    movel %d0,%d6
    moveq #0,%d0
    movew %d5,%d0
    cmpl %d6,%d0
    jbcs rsrc_drvr_9_3192_22
    movel %d6,%d0
    moveml %fp@(-12),%d5-%d7
    unlk %fp
    rts

/* subroutine (31 instructions): traps TickCount (mechanical summary) */
rsrc_drvr_9_31E8:
    linkw %fp,#0
    moveml %d5-%d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a3
    moveal %fp@(12),%a4
    moveq #3,%d5
    jbra rsrc_drvr_9_31E8_3A
rsrc_drvr_9_31E8_14:    /* loop: move */
    movel %fp@(16),%sp@-
    moveal %a3,%a0
    jsr %a0@
    subql #4,%sp
    _TickCount
    movel %sp@+,%d7
    addqw #4,%sp
    jbra rsrc_drvr_9_31E8_2A
rsrc_drvr_9_31E8_26:    /* loop: tst */
    tstw %a4@
    jbne rsrc_drvr_9_31E8_42
rsrc_drvr_9_31E8_2A:    /* set up and call _TickCount */
    subql #4,%sp
    _TickCount
    movel %sp@+,%d6
    movel %d6,%d0
    subl %d7,%d0
    moveq #30,%d1
    cmpl %d0,%d1
    jbgt rsrc_drvr_9_31E8_26
rsrc_drvr_9_31E8_3A:    /* set %d0 */
    movel %d5,%d0
    subql #1,%d5
    tstl %d0
    jbne rsrc_drvr_9_31E8_14
rsrc_drvr_9_31E8_42:    /* restore registers, return */
    moveml %fp@(-20),%d5-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (15 instructions): calls rsrc_drvr_9_2B48 (mechanical summary) */
rsrc_drvr_9_3234:
    linkw %fp,#-4
    moveq #0,%d0
    movel %d0,%fp@(-4)
rsrc_drvr_9_3234_A:     /* loop: moveq */
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #2,%d1
    movel %d1,%sp@-
    pea %fp@(-4)
    jsr %pc@(rsrc_drvr_9_2B48)
    lea %sp@(12),%sp
    tstl %fp@(-4)
    jbne rsrc_drvr_9_3234_A
    moveq #0,%d0
    unlk %fp
    rts

/* subroutine (39 instructions): calls rsrc_drvr_9_2B48 (mechanical summary) */
rsrc_drvr_9_325E:
    linkw %fp,#-4
    moveml %a3-%a4,%sp@-
    moveal %fp@(8),%a3
    moveq #0,%d0
    movel %d0,%fp@(-4)
    moveal %d0,%a4
    movel %d0,%a3@
rsrc_drvr_9_325E_16:    /* loop: move */
    movel %a3,%sp@-
    moveq #3,%d0
    movel %d0,%sp@-
    pea %fp@(-4)
    jsr %pc@(rsrc_drvr_9_2B48)
    tstw %d0
    lea %sp@(12),%sp
    jbeq rsrc_drvr_9_325E_5A
    moveq #0,%d0
    movel %d0,%fp@(-4)
    movel %a4,%d1
    jbeq rsrc_drvr_9_325E_56
rsrc_drvr_9_325E_36:    /* loop: moveq */
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #4,%d1
    movel %d1,%sp@-
    pea %fp@(-4)
    jsr %pc@(rsrc_drvr_9_2B48)
    lea %sp@(12),%sp
    cmpal %fp@(-4),%a4
    jbeq rsrc_drvr_9_325E_56
    tstl %fp@(-4)
    jbne rsrc_drvr_9_325E_36
rsrc_drvr_9_325E_56:    /* result -1 */
    moveq #-1,%d0
    jbra rsrc_drvr_9_325E_66
rsrc_drvr_9_325E_5A:    /* set %a4 */
    moveal %fp@(-4),%a4
    tstl %fp@(-4)
    jbne rsrc_drvr_9_325E_16
    moveq #0,%d0
rsrc_drvr_9_325E_66:    /* restore registers, return */
    moveml %fp@(-12),%a3-%a4
    unlk %fp
    rts

/* subroutine (13 instructions): calls rsrc_drvr_9_2B48 (mechanical summary) */
rsrc_drvr_9_32CE:
    linkw %fp,#-4
rsrc_drvr_9_32CE_4:     /* loop: moveq */
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #4,%d1
    movel %d1,%sp@-
    pea %fp@(-4)
    jsr %pc@(rsrc_drvr_9_2B48)
    lea %sp@(12),%sp
    tstl %fp@(-4)
    jbne rsrc_drvr_9_32CE_4
    moveq #0,%d0
    unlk %fp
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_drvr_9_32F2:
    moveq #0,%d0	| 408E06A2
    cmpb %a3@(1),%d4	| 408E06A4
    jbcc rsrc_drvr_9_32FC	| 408E06A8
    moveb %d4,%d0	| 408E06AA
rsrc_drvr_9_32FC:       /* from here: muluw #16,%d0 */
    muluw #16,%d0	| 408E06AC
    addiw #650,%d0	| 408E06B0
    rts	| 408E06B4

/* subroutine (21 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_drvr_9_3306:
    linkw %fp,#-16
    moveq #25,%d0
    moveal ATalkHk2,%a0
    jsr %a0@(2)
    moveal %a1@(2),%a1
rsrc_drvr_9_3306_12:    /* loop: cmpa */
    cmpaw #0,%a1
    jbeq rsrc_drvr_9_3306_38
    movel %a1@,%fp@(-4)
    movel %fp@(8),%fp@(-8)
    movel %a1,%fp@(-12)
    movel %fp@(12),%fp@(-16)
    moveal %a1@(6),%a0
    jsr %a0@
    moveal %fp@(-4),%a1
    jbra rsrc_drvr_9_3306_12
rsrc_drvr_9_3306_38:    /* return */
    unlk %fp
    moveal %sp@+,%a0
    addql #8,%sp
    jmp %a0@
    movel %sp@(4),%d1
    movel %sp@(8),%d0

/* subroutine (37 instructions) (mechanical summary) */
rsrc_drvr_9_334E:
    moveml %d2-%d4,%sp@-
    movel %d1,%d2
    swap %d2
    tstw %d2
    jbne rsrc_drvr_9_334E_28
    movew %d0,%d3
    clrw %d0
    swap %d0
    jbeq rsrc_drvr_9_334E_18
    divuw %d1,%d0
    movew %d0,%d2
rsrc_drvr_9_334E_18:    /* from here: swap %d2 */
    swap %d2
    movew %d3,%d0
    divuw %d1,%d0
    movew %d0,%d2
    movel %d2,%d1
    clrw %d0
    swap %d0
    jbra rsrc_drvr_9_334E_4A
rsrc_drvr_9_334E_28:    /* set %d2 */
    movel %d0,%d2
    clrw %d0
    swap %d0
    swap %d2
    clrw %d2
    movel %d1,%d3
    moveq #0,%d1
    moveq #15,%d4
rsrc_drvr_9_334E_38:    /* loop: add */
    addl %d2,%d2
    addxl %d0,%d0
    addl %d1,%d1
    cmpl %d3,%d0
    jbcs rsrc_drvr_9_334E_46
    subl %d3,%d0
    addqb #1,%d1
rsrc_drvr_9_334E_46:    /* count down */
    dbf %d4,rsrc_drvr_9_334E_38
rsrc_drvr_9_334E_4A:    /* restore registers, return */
    moveml %sp@+,%d2-%d4
    rts

/* subroutine (12 instructions): low memory ABusVars (mechanical summary) */
rsrc_drvr_9_339E:
    movel %a1,%sp@-
    movew %sr,%sp@-
    moveal ABusVars,%a1
    moveal %a1@(808),%a1
    oriw #1792,%sr
    andiw #-257,%sr
    movel %a1@(782),%a0@
    movel %a0,%a1@(782)
    addql #1,%a1@(80)
    movew %sp@+,%sr
    moveal %sp@+,%a1
    rts

/* subroutine (81 instructions): calls rsrc_drvr_9_33C4, rsrc_drvr_9_34C8 (mechanical summary) */
rsrc_drvr_9_33C4:
    moveml %d1/%a0,%sp@-
    moveal %a2@(808),%a0
    lea %a0@(114),%a0
    clrw %d1
    moveb %a2@(820),%d1
    muluw #64,%d1
    addl %d0,%d1
    addql #1,%a0@(0x0,%d1:l)
    moveml %sp@+,%d1/%a0
    rts
rsrc_drvr_9_33E6:       /* continue at rsrc_drvr_9_33FE */
    jbra rsrc_drvr_9_33FE	| 408E0796
    .byte   0x60, 0x00, 0x02, 0xD8	| 408E0798
rsrc_drvr_9_33EC:       /* loop: clr */
    clrw %d3	| 408E079C
    jmp %a4@(2)	| 408E079E
rsrc_drvr_9_33F2:       /* loop: clr */
    clrw %d3	| 408E07A2
    jsr %a4@(2)	| 408E07A4
    moveq #20,%d0	| 408E07A8
    braw rsrc_drvr_9_33C4	| 408E07AA
rsrc_drvr_9_33FE:       /* set %a3 */
    moveal %a2@(808),%a3	| 408E07AE
    movel %a3,%d0	| 408E07B2
    jbeq rsrc_drvr_9_33EC	| 408E07B4
    movel %a3@(80),%d0	| 408E07B6
    subl %a3@(84),%d0	| 408E07BA
    jble rsrc_drvr_9_33F2	| 408E07BE
    oriw #1792,%sr	| 408E07C0
    andiw #-257,%sr	| 408E07C4
    movel %a3@(782),%d2	| 408E07C8
    jbeq rsrc_drvr_9_33F2	| 408E07CC
    moveal %d2,%a5	| 408E07CE
    movel %a5@,%a3@(782)	| 408E07D0
    subql #1,%a3@(80)	| 408E07D4
    lea %a5@(67),%a3	| 408E07D8
    movew #586,%d3	| 408E07DC
    jsr %a4@(2)	| 408E07E0
    moveal %a2@(808),%a3	| 408E07E4
    moveal %d2,%a0	| 408E07E8
    jbeq rsrc_drvr_9_3446	| 408E07EA
    moveq #16,%d0
    bsrw rsrc_drvr_9_33C4
    jbra rsrc_drvr_9_339E
rsrc_drvr_9_3446:       /* (408E07F6 cmpib #-1,%a2@(12)) */
    cmpib #0xff,%a2@(12)	| 408E07F6
    jbne rsrc_drvr_9_3464	| 408E07FC
    movew %a2@(8),%d0	| 408E07FE
    cmpw %a2@(836),%d0	| 408E0802
    jbcs rsrc_drvr_9_3464	| 408E0806
    cmpw %a2@(838),%d0	| 408E0808
    jbhi rsrc_drvr_9_3464	| 408E080C
    moveal %d2,%a0	| 408E080E
    jbra rsrc_drvr_9_339E	| 408E0810
rsrc_drvr_9_3464:       /* address %a3@(114) */
    lea %a3@(114),%a1	| 408E0814
    moveq #0,%d0	| 408E0818
    moveb %a2@(820),%d0	| 408E081A
    jbeq rsrc_drvr_9_3472	| 408E081E
    asll #6,%d0	| 408E0820
rsrc_drvr_9_3472:       /* add 1 to %a1@(0,%d0:l) */
    addql #1,%a1@(0,%d0:l)	| 408E0822
    movew #586,%d0	| 408E0826
    subw %d3,%d0	| 408E082A
    moveq #16,%d1	| 408E082C
    addw %d1,%d0	| 408E082E
    lea %a0@(654),%a1	| 408E0830
    movel %a1,%a0@(30)	| 408E0834
    movew %d0,%a1@+	| 408E0838
    lea %a0@(51),%a0	| 408E083A
    movel %a0,%a1@+	| 408E083E
    clrw %a1@+	| 408E0840
    lea %a2@(1),%a1	| 408E0842
rsrc_drvr_9_3496:       /* loop: move */
    moveb %a1@+,%a0@+	| 408E0846
    subqw #1,%d1	| 408E0848
    jbne rsrc_drvr_9_3496	| 408E084A
    moveal %d2,%a0	| 408E084C
    moveml %d2-%d3/%a0-%a3,%a0@(6)	| 408E084E
    bset #0,%a3@(644)	| 408E0854
    jbne rsrc_drvr_9_34C0	| 408E085A
    movew %sr,%d0	| 408E085C
    andiw #-1793,%d0	| 408E085E
    eoriw #8192,%d0	| 408E0862
    movew %a2@(28),%sp@-	| 408E0866
    eorw %d0,%sp@	| 408E086A
    movew %sp@+,%sr	| 408E086C
    jbra rsrc_drvr_9_34E8	| 408E086E
rsrc_drvr_9_34C0:       /* address %a3@(644) */
    lea %a3@(644),%a1	| 408E0870
    jbsr rsrc_drvr_9_34C8	| 408E0874
    rts	| 408E0876

/* subroutine (109 instructions): traps trap_A404; calls rsrc_drvr_9_3610, rsrc_drvr_9_36C2, rsrc_drvr_9_33C4, rsrc_drvr_9_339E, rsrc_drvr_9_3682 (mechanical summary) */
rsrc_drvr_9_34C8:
    addqw #2,%a1	| 408E0878
    clrl %a0@	| 408E087A
    tstl %a1@+	| 408E087C
    jbne rsrc_drvr_9_34D6	| 408E087E
    movel %a0,%a1@	| 408E0880
    movel %a0,%a1@-	| 408E0882
    jbra rsrc_drvr_9_34E2	| 408E0884
rsrc_drvr_9_34D6:       /* set %sp@- */
    movel %a2,%sp@-	| 408E0886
    moveal %a1@,%a2	| 408E0888
    movel %a0,%a2@	| 408E088A
    movel %a0,%a1@	| 408E088C
    moveal %sp@+,%a2	| 408E088E
    subqw #4,%a1	| 408E0890
rsrc_drvr_9_34E2:       /* subtract 2 to %a1 */
    subqw #2,%a1	| 408E0892
    rts	| 408E0894
rsrc_drvr_9_34E6:       /* loop: move */
    movew %sp@+,%sr	| 408E0896
rsrc_drvr_9_34E8:       /* set %d2-%d3/%a0-%a3 */
    moveml %a0@(6),%d2-%d3/%a0-%a3	| 408E0898
    movel %a2,%d1	| 408E089E
    moveal %d2,%a2	| 408E08A0
    tstb %a2@(62)	| 408E08A2
    jbne rsrc_drvr_9_3532	| 408E08A6
    movel %a2,%sp@-	| 408E08A8
    jbsr rsrc_drvr_9_3610	| 408E08AA
    jbeq rsrc_drvr_9_3504	| 408E08AE
    moveal %sp@+,%a2	| 408E08B0
    jbra rsrc_drvr_9_3532	| 408E08B2
rsrc_drvr_9_3504:       /* set %d3 */
    movew %a2@(26),%d3	| 408E08B4
    subl %d2,%d2	| 408E08B8
    movew %a2@(26),%d2	| 408E08BA
    movew %d2,%d0	| 408E08BE
    lsll #8,%d2	| 408E08C0
    moveb %a2@,%d2	| 408E08C2
    moveal %sp@+,%a2	| 408E08C4
    moveb %d2,%a2@(62)	| 408E08C6
    movew %d0,%a2@(58)	| 408E08CA
    pea %a2@	| 408E08CE
    jbsr rsrc_drvr_9_36C2	| 408E08D0
    moveal %sp@+,%a0	| 408E08D4
    jbeq rsrc_drvr_9_352C	| 408E08D6
    movel %a0,%d2	| 408E08D8
    jbra rsrc_drvr_9_353C	| 408E08DA
rsrc_drvr_9_352C:       /* set %a1 */
    moveal %a2,%a1	| 408E08DC
    moveal %a0,%a2	| 408E08DE
    jbra rsrc_drvr_9_35AE	| 408E08E0
rsrc_drvr_9_3532:       /* set %d3 */
    movew %a2@(58),%d3	| 408E08E2
    jbsr rsrc_drvr_9_36C2	| 408E08E6
    jbeq rsrc_drvr_9_354E	| 408E08EA
rsrc_drvr_9_353C:       /* set %d0 */
    moveq #24,%d0	| 408E08EC
rsrc_drvr_9_353E:       /* loop: movea */
    moveal %d1,%a2	| 408E08EE
    jbsr rsrc_drvr_9_33C4	| 408E08F0
    moveal %d2,%a0	| 408E08F4
    jbsr rsrc_drvr_9_339E	| 408E08F6
    jbra rsrc_drvr_9_35E8	| 408E08FA
rsrc_drvr_9_354E:       /* set %a1 */
    moveal %a2,%a1	| 408E08FE
    moveq #0,%d0	| 408E0900
    moveal %d1,%a2	| 408E0902
    moveb %a2@(820),%d0	| 408E0904
    moveal %d2,%a2	| 408E0908
    moveb %a3@(0x44,%d0:w),%d3	| 408E090A
    andib #15,%d3	| 408E090E
    lslb #2,%d3	| 408E0912
    moveb %d3,%sp@-	| 408E0914
    btst #6,%a3@(0x44,%d0:w)	| 408E0916
    jbeq rsrc_drvr_9_357A	| 408E091C
    moveb %a1@(8),%d0	| 408E091E
    btst #6,%a3@(0x44,%d0:w)	| 408E0922
    jbeq rsrc_drvr_9_357E	| 408E0928
rsrc_drvr_9_357A:       /* set %sp@ */
    moveb #4,%sp@	| 408E092A
rsrc_drvr_9_357E:       /* set %d0 */
    moveb %a2@(54),%d0	| 408E092E
    addb %sp@+,%d0	| 408E0932
    cmpib #64,%d0	| 408E0934
    jbcs rsrc_drvr_9_358E	| 408E0938
    moveq #28,%d0	| 408E093A
    jbra rsrc_drvr_9_353E	| 408E093C
rsrc_drvr_9_358E:       /* set %a2@(54) */
    moveb %d0,%a2@(54)	| 408E093E
    lea %a2@,%a0	| 408E0942
    subl %d2,%d2	| 408E0944
    movew %a1@(4),%d2	| 408E0946
    lsll #8,%d2	| 408E094A
    moveb %a1@(6),%d2	| 408E094C
    jbne rsrc_drvr_9_35AE	| 408E0950
    moveq #0,%d2	| 408E0952
    movew %a2@(58),%d2	| 408E0954
    lsll #8,%d2	| 408E0958
    moveb %a2@(62),%d2	| 408E095A
rsrc_drvr_9_35AE:       /* set %a2@(51) */
    moveb %d2,%a2@(51)	| 408E095E
    movel %d2,%a0@(34)	| 408E0962
    clrw %d0	| 408E0966
    moveb %a1@(8),%d0	| 408E0968
    muluw #96,%d0	| 408E096C
    moveal %a3@(56),%a1	| 408E0970
    movew %a1@(8,%d0:l),%a0@(24)	| 408E0974
    moveal %a1@(0,%d0:l),%a2	| 408E097A
    movew #243,%a0@(26)	| 408E097E
    lea %pc@(rsrc_drvr_9_3668),%a1	| 408E0984
    movel %a1,%a0@(12)	| 408E0988
    movel %a3,%a0@(18)	| 408E098C
    .short  0xA404	| 408E0990 _Control (flags 0x0400)
    moveq #4,%d0	| 408E0992
    jbsr rsrc_drvr_9_33C4	| 408E0994
rsrc_drvr_9_35E8:       /* set %sp@- */
    movew %sr,%sp@-	| 408E0998
    oriw #1792,%sr	| 408E099A
    andiw #-257,%sr	| 408E099E
    moveal %a3@(646),%a0	| 408E09A2
    movel %a0,%d0	| 408E09A6
    jbeq rsrc_drvr_9_3606	| 408E09A8
    lea %a3@(644),%a1	| 408E09AA
    jbsr rsrc_drvr_9_3682	| 408E09AE
    jbra rsrc_drvr_9_34E6	| 408E09B2
rsrc_drvr_9_3606:       /* clear bit 0 of %a3@(644) */
    bclr #0,%a3@(644)	| 408E09B6
    movew %sp@+,%sr	| 408E09BC
    rts	| 408E09BE

/* subroutine (32 instructions): low memory ABusVars (mechanical summary) */
rsrc_drvr_9_3610:
    moveml %d0/%d2-%d3/%a0-%a1/%a5,%sp@-
    movew %a2@(58),%d2
    moveal ABusVars,%a2
    moveal %a2@(808),%a5
    lea %a5@(68),%a1
    moveal %a5@(56),%a5
    moveq #7,%d0
rsrc_drvr_9_3610_1A:    /* loop: move */
    movel %a5@(4),%d3
    btst #6,%a1@+
    jbne rsrc_drvr_9_3610_46
    btst #0,%d3
    jbeq rsrc_drvr_9_3610_46
    btst #1,%d3
    jbne rsrc_drvr_9_3610_46
    moveal %a5@,%a0
    cmpw %a0@(836),%d2
    jbcs rsrc_drvr_9_3610_46
    cmpw %a0@(838),%d2
    jbhi rsrc_drvr_9_3610_46
    moveal %a0,%a2
    movew #4,%ccr
    jbra rsrc_drvr_9_3610_52
rsrc_drvr_9_3610_46:    /* address %a5@(96) */
    lea %a5@(96),%a5
    dbf %d0,rsrc_drvr_9_3610_1A
    movew #0,%ccr
rsrc_drvr_9_3610_52:    /* restore registers, return */
    moveml %sp@+,%d0/%d2-%d3/%a0-%a1/%a5
    rts
rsrc_drvr_9_3668:       /* (data) */
    .long   0x26680012, 0x4AAB0066	| 408E0A18
    .long   0x6700FD2C	| 408E0A20
    movel %a0,%sp@-
    moveal %a3@(102),%a0
    jsr %a0@
    moveal %sp@+,%a0
    jbra rsrc_drvr_9_339E

/* subroutine (24 instructions) (mechanical summary) */
rsrc_drvr_9_3682:
    moveml %a2-%a3,%sp@-	| 408E0A32
    moveal %a1@(2),%a2	| 408E0A36
    moveal %a2,%a3	| 408E0A3A
rsrc_drvr_9_368C:       /* loop: cmpa */
    cmpal %a3,%a0	| 408E0A3C
    jbeq rsrc_drvr_9_369E	| 408E0A3E
    moveal %a3,%a2	| 408E0A40
    moveal %a2@,%a3	| 408E0A42
    cmpal %a1@(6),%a2	| 408E0A44
    jbne rsrc_drvr_9_368C	| 408E0A48
    moveq #-1,%d0
    jbra rsrc_drvr_9_3610_9E
rsrc_drvr_9_369E:       /* test %a2,%a3 */
    cmpal %a2,%a3	| 408E0A4E
    jbne rsrc_drvr_9_36B4	| 408E0A50
    movel %a2@,%a1@(2)	| 408E0A52
    jbne rsrc_drvr_9_36AC	| 408E0A56
    clrl %a1@(6)	| 408E0A58
rsrc_drvr_9_36AC:       /* loop: moveq */
    moveq #0,%d0	| 408E0A5C
rsrc_drvr_9_3610_9E:    /* restore registers, return */
    moveml %sp@+,%a2-%a3
    rts
rsrc_drvr_9_36B4:       /* set %a2@ */
    movel %a3@,%a2@	| 408E0A64
    cmpal %a1@(6),%a3	| 408E0A66
    jbne rsrc_drvr_9_36AC	| 408E0A6A
    movel %a2,%a1@(6)	| 408E0A6C
    jbra rsrc_drvr_9_36AC	| 408E0A70

/* subroutine (46 instructions): calls rsrc_drvr_9_3740 (mechanical summary) */
rsrc_drvr_9_36C2:
    moveml %d0-%d2,%sp@-	| 408E0A72
    moveal %a3@(790),%a0
    moveq #0,%d0
    movel %d0,%d2
    movel %a3@(794),%d1
    jbeq rsrc_drvr_9_3610_104
    subql #4,%d1
rsrc_drvr_9_3610_C6:    /* loop: move */
    movel %d0,%d2
    addl %d1,%d2
    asrl #3,%d2
    asll #2,%d2
    cmpw %a0@(0x2,%d2:l),%d3
    jbeq rsrc_drvr_9_3610_11E
    jbhi rsrc_drvr_9_3610_DC
    movel %d2,%d1
    subql #4,%d1
    jbra rsrc_drvr_9_3610_E0
rsrc_drvr_9_3610_DC:    /* set %d0 */
    movel %d2,%d0
    addql #4,%d0
rsrc_drvr_9_3610_E0:    /* test %d0,%d1 */
    cmpl %d0,%d1
    jbge rsrc_drvr_9_3610_C6
    cmpl %a3@(794),%d0
    jbge rsrc_drvr_9_3610_104
    movel %d0,%d2
    pea %a0@(0x0,%d2:l)
    jbsr rsrc_drvr_9_3740
    tstw %a2@(2)
    jbeq rsrc_drvr_9_3610_102
    cmpw %a2@(2),%d3
    jbcs rsrc_drvr_9_3610_102
    cmpw %a2@,%d3
    jbls rsrc_drvr_9_3610_124
rsrc_drvr_9_3610_102:   /* add 4 to %sp */
    addqw #4,%sp
rsrc_drvr_9_3610_104:   /* set %d1 */
    movel %a3@(798),%d1
    movew %a0@(0x0,%d1:l),%d2
    moveal %a3@(20),%a2
    lea %a2@(0x0,%d2:w),%a2
    lea %a0@(0x0,%d0:l),%a0
    movew #0,%ccr
    jbra rsrc_drvr_9_3610_12A
rsrc_drvr_9_3610_11E:   /* from here: pea %a0@(0x0,%d2:l) */
    pea %a0@(0x0,%d2:l)
    jbsr rsrc_drvr_9_3740
rsrc_drvr_9_3610_124:   /* set %a0 */
    moveal %sp@+,%a0
    orib #4,%ccr
rsrc_drvr_9_3610_12A:   /* restore registers, return */
    moveml %sp@+,%d0-%d2
    rts

/* subroutine (4 instructions) (mechanical summary) */
rsrc_drvr_9_3740:
    movew %a0@(0x0,%d2:l),%d2
    moveal %a3@(20),%a2
    lea %a2@(0x0,%d2:w),%a2
    rts
    .short  0x7075	| 408E0AFE
