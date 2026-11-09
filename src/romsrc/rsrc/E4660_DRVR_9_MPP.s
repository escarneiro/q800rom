/* ROM resource 'DRVR' 9 ".MPP": map entry at 0x408E4660, data at 0x408E4690, 4906 bytes

 The .MPP stub ('DRVR' 9, ".MPP Stub v57.0.5f1", (c) Apple 1984-1992): a placeholder for
 the AppleTalk driver. It cannot be opened (openErr); Control and Status fail
 (controlErr/statusErr through IODone). The real .MPP (the 'drvr' 9 resource,
 rsrc/DD380_drvr_9.s) is installed in its place when AppleTalk is loaded (the LAP
 Manager, 'lmgr' 0). Comments inferred from the code.
*/

rsrc_DRVR_9__MPP_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408E4660
    .long   rsrc_DRVR_10__ATP_entry-rom_start	| 408E4668
    .long   rsrc_DRVR_9__MPP-rom_start	| 408E466C
    .ascii  "DRVR"	| 408E4670
    .byte   0x00, 0x09, 0x58	| 408E4674
    .byte   4	/* 408E4677 Pascal string length */
    .ascii  ".MPP"	| 408E4678
    FILL_408E467C
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x13, 0x36, 0x00, 0x00, 0x02, 0xA4	| 408E4684

/* subroutine (0 instructions): low memory Apple, Computer (mechanical summary) */
rsrc_DRVR_9__MPP:
    .byte   0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408E4690
rsrc_DRVR_9__MPP_8:     /* (data) */
    .short  rsrc_DRVR_9__MPP_open-rsrc_DRVR_9__MPP	| 408E4698
    .short  rsrc_DRVR_9__MPP_prime-rsrc_DRVR_9__MPP	| 408E469A
    .short  rsrc_DRVR_9__MPP_ctl-rsrc_DRVR_9__MPP	| 408E469C
    .short  rsrc_DRVR_9__MPP_status-rsrc_DRVR_9__MPP	| 408E469E
    .short  rsrc_DRVR_9__MPP_close-rsrc_DRVR_9__MPP	| 408E46A0
    .byte   0x04, 0x2E, 0x4D, 0x50, 0x50, 0x20	| 408E46A2
rsrc_DRVR_9__MPP_8_10:
    .byte   0x39, 0x05, 0x80, 0x01, 0x00, 0x00, 0x08, 0x35, 0x37, 0x2E, 0x30, 0x2E, 0x35, 0x66, 0x31, 0x00	| 408E46A8
    .byte   0x35, 0x2E, 0x4D, 0x50, 0x50, 0x20, 0x53, 0x74, 0x75, 0x62, 0x20, 0x76, 0x35, 0x37, 0x2E, 0x30	| 408E46B8
    .byte   0x2E, 0x35, 0x66, 0x31, 0x3B, 0x20, 0xA9	| 408E46C8
    .ascii  " Apple Computer, Inc. 1984-1992\000"
    .byte   0x90	| 408E46EF

/* Open: openErr (-23). */
rsrc_DRVR_9__MPP_open:
    movew #-23,%d0
    rts
    movew #-19,%d0
    jbra rsrc_DRVR_9__MPP_status_4
    movew #-20,%d0
    jbra rsrc_DRVR_9__MPP_status_4

/* Control: controlErr (-17), Status: statusErr (-18), both completed through JIODone. */
rsrc_DRVR_9__MPP_ctl:
    movew #-17,%d0
    jbra rsrc_DRVR_9__MPP_status_4

/* subroutine (3 instructions): low memory JIODone (mechanical summary) */
rsrc_DRVR_9__MPP_status:
    movew #-18,%d0
rsrc_DRVR_9__MPP_status_4:  /* set %sp@- */
    movel JIODone,%sp@-
    rts

/* Prime: nothing. */
rsrc_DRVR_9__MPP_prime:
    bclr #7,%a1@(5)
    rts

/* subroutine (32 instructions): calls rsrc_DRVR_9__MPP_BF6, rsrc_DRVR_9__MPP_440; low memory ExpandMem, PortBUse, SPATalkB (mechanical summary) */
rsrc_DRVR_9__MPP_close:
    movew 0xffffffe8,%d0
    rts
    .short  0x604E	| bras 408e4770 <rsrc_DRVR_9__MPP_close+0x56>
    .short  0x6052	| bras 408e4776 <rsrc_DRVR_9__MPP_close+0x5c>
    orib #8,%d0
    movew %d5,%a4@-
    orb %d1,%d0
    .short  0x0000, 0x0835	| orib #53,%d0
    movew %fp@(12334),%a3@-
    movew %fp@-,%a2@(12544)
    movew %a4,%a3@(16720)
    moveal %a5,%a0
    .short  0x616E	| bsrs 408e47ae <rsrc_DRVR_9__MPP_10E+0x10>
    .short  0x6167	| bsrs 408e47a9 <rsrc_DRVR_9__MPP_10E+0xb>
    .short  0x6572	| bcss 408e47b6 <rsrc_DRVR_9__MPP_10E+0x18>
    .short  0x2076, 0x3537, 0x2E30, 0x2E35, 0x6631, 0x3B20	| moveal %fp@(2e302e35)@(66313b20,%d3:w:4),%a0
    .short  0xA920	| .short 0xa920
    .short  0x4170	| .short 0x4170
    moveq #108,%d0
    .short  0x6520	| bcss 408e4778 <rsrc_DRVR_9__MPP_close+0x5e>
    .short  0x436F	| .short 0x436f
    .short  0x6D70	| blts 408e47cc <rsrc_DRVR_9__MPP_10E+0x2e>
    .short  0x7574	| .short 0x7574
    .short  0x6572	| bcss 408e47d2 <rsrc_DRVR_9__MPP_10E+0x34>
    movel %a0@-,%d6
    .short  0x496E	| .short 0x496e
    blss rsrc_DRVR_9__MPP_F0_14
    .short  0x2031, 0x3938, 0x342D, 0x3139	| 408E4766 movel %a1@(0x342d3139,%d3:l),%d0
    .short  0x3932, 0x2F2A, 0x0418, 0x4E75	| 408E476E movew %a2@(0x418,%d2:l:8)@(0x4e75),%a4@-
    subqw #1,%d0
    bnes rsrc_DRVR_9__MPP_F0
    movel %a2@(1052),%sp@-
    rts

rsrc_DRVR_9__MPP_F0:    /* set %sp@- */
    movel %a3,%sp@-
    cmpiw #32,%d0
    jbhi rsrc_DRVR_9__MPP_14E
    lea %pc@(rsrc_DRVR_9__MPP_10E),%a3
    addw %d0,%d0
    addaw %a3@(0xfffffffffffffffe,%d0:w),%a3
    movel %a3,%sp@-
rsrc_DRVR_9__MPP_F0_14:
    moveal ExpandMem,%a3
    moveal %a3@(116),%a3
    rts
rsrc_DRVR_9__MPP_10E:   /* (data) */
    .short  0x0044	| 408E479E
    .long   0x0060006A, 0x0080009A, 0x03F00478, 0x00AA00CA	| 408E47A0
    .long   0x03E0008C, 0x00A000B0, 0x00DE0102, 0x01A401EC	| 408E47B0
    .long   0x021C0230, 0x0520068A, 0x02E40316, 0x032A035E	| 408E47C0
    .short  0x03A8, 0x03D2, 0x0A68, 0x0A00, 0x0A10, 0x0A9A, 0x0AAE	| 408E47D0
rsrc_DRVR_9__MPP_14E:   /* result -1 */
    moveq #-1,%d0
    jbra rsrc_DRVR_9__MPP_168_2
    .short  0x6100, 0x0AA2, 0x4AB3, 0x0000, 0x66F2, 0x2788, 0x0000	| 408E47E2
    .long   0x17810006, 0x37820004	| 408E47F0

rsrc_DRVR_9__MPP_168:   /* loop: moveq */
    moveq #0,%d0
rsrc_DRVR_9__MPP_168_2:  /* loop: movea */
    moveal %sp@+,%a3
    rts
    .short  0x6100	| 408E47FE
    .long   0x0A8642B3	| 408E4800
    .short  0x0000, 0x60F0	| orib #0xf0,%d0
    jbsr rsrc_DRVR_9__MPP_BF6
    moveal %a3@(0x0,%d0:w),%a0
    lea PortBUse,%a1
    tstb %d4
    jbeq rsrc_DRVR_9__MPP_168
    lea %a3@(0x7,%d0:w),%a1
    jbra rsrc_DRVR_9__MPP_168
rsrc_DRVR_9__MPP_168_26:  /* loop: eori */
    eorib #0x80,SPATalkB
rsrc_DRVR_9__MPP_168_2C:  /* loop: st */
    st %a2@(711)
    jbra rsrc_DRVR_9__MPP_168
    .short  0x6100, 0x0A5A	| 408E482A
    btst #5,%a3@(0x6,%d0:w)
    jbne rsrc_DRVR_9__MPP_168_2C
    jbra rsrc_DRVR_9__MPP_168_26
    moveb %a2@(696),%d1
    bras rsrc_DRVR_9__MPP_168
    .short  0x322B	| 408E483E
    .short  0x0002, 0x43EB	| orib #0xeb,%d2
    .short  0x0006, 0x60B0	| orib #0xb0,%d6
    jbsr rsrc_DRVR_9__MPP_440
    jbra rsrc_DRVR_9__MPP_168
    cmpib #127,%d1
    beqs rsrc_DRVR_9__MPP_168_2C_3A
    tstw %a3@(2)
    bnes rsrc_DRVR_9__MPP_168_2C_3A
    movel %d1,%a3@(658)
rsrc_DRVR_9__MPP_168_2C_3A:
    movel %d1,%sp@-
    bsrw rsrc_DRVR_9__MPP_1234
    addqw #4,%sp
    bras rsrc_DRVR_9__MPP_168
    cmpb %a3@(1),%d4
    bccw rsrc_DRVR_9__MPP_14E
    bsrw rsrc_DRVR_9__MPP_BF6
    movel %a3@(0x8,%d0:w),%d1
    braw rsrc_DRVR_9__MPP_168
    subaw #50,%sp
    moveal %sp,%a0
    movew %a3@(4),%a0@(24)
    _Close
    movew %a3@(2),%a0@(22)
    moveq #2,%d0
    .short  0xA260	| 408E4892 _FSDispatch (flags 0x0200)
    lea %sp@(50),%sp
    clrw %a3@(2)
    braw rsrc_DRVR_9__MPP_168
    st %a0@(502)
    movel %a0,%sp@-
    movew SysVersion,%d0
    asrw #8,%d0
    cmpib #6,%d0
    bnes rsrc_DRVR_9__MPP_168_2C_A4
    movew #-22112,%d0
    .short  0xA146	| 408E48B6 _GetTrapAddress (flags 0x0100)
    moveal %sp@,%a3
    movel %a0,%a3@(494)
    movew #-22112,%d0
    lea %pc@(rsrc_DRVR_9__MPP_168_2C_AA),%a0
    _SetTrapAddress
rsrc_DRVR_9__MPP_168_2C_A4:
    moveal %sp@+,%a0
    braw rsrc_DRVR_9__MPP_168
rsrc_DRVR_9__MPP_168_2C_AA:
    cmpiw #22,%sp@(4)
    bnes rsrc_DRVR_9__MPP_168_2C_E8
    cmpil #1229867348,%sp@(6)
    bnes rsrc_DRVR_9__MPP_168_2C_E8
    movel %sp@,%sp@(6)
    addqw #6,%sp
    clrl %sp@(4)
    movew #-22112,%d0
    .short  0xA146	| 408E48EE _GetTrapAddress (flags 0x0100)
    lea %pc@(rsrc_DRVR_9__MPP_168_2C_AA),%a1
    cmpal %a0,%a1
    bnes rsrc_DRVR_9__MPP_168_2C_E6
    moveal ExpandMem,%a0
    moveal %a0@(116),%a0
    moveal %a0@(494),%a0
    movew #-22112,%d0
    _SetTrapAddress
rsrc_DRVR_9__MPP_168_2C_E6:
    rts
rsrc_DRVR_9__MPP_168_2C_E8:
    moveal ExpandMem,%a0
    moveal %a0@(116),%a0
    movel %a0@(494),%sp@-
    rts

/* subroutine (52 instructions): traps StripAddress; calls rsrc_DRVR_9__MPP_440, rsrc_DRVR_9__MPP_28A; low memory PortBUse (mechanical summary) */
rsrc_DRVR_9__MPP_28A:
    moveml %d1-%d2/%a0,%sp@-
    moveb PortBUse,%d2
    andib #15,%d2
    cmpib #1,%d2
    jbne rsrc_DRVR_9__MPP_28A_22
    jbsr rsrc_DRVR_9__MPP_440
    tstl %d1
    jbeq rsrc_DRVR_9__MPP_28A_20
    cmpib #1,%d1
    jbne rsrc_DRVR_9__MPP_28A_22
rsrc_DRVR_9__MPP_28A_20:  /* clear %d0 */
    moveq #0,%d0
rsrc_DRVR_9__MPP_28A_22:  /* restore registers, return */
    moveml %sp@+,%d1-%d2/%a0
    rts
    .short  0xB22B, 0x01F6, 0x6700, 0xFEB0, 0x0C01	| 408E4942
    .short  0x0001, 0x6704	| orib #4,%d1
    jbsr rsrc_DRVR_9__MPP_28A
    jbeq rsrc_DRVR_9__MPP_28A_6A
    tstb %a3@(502)
    jbpl rsrc_DRVR_9__MPP_28A_6A
    moveb PortBUse,%d0
    jbmi rsrc_DRVR_9__MPP_28A_50
    andib #15,%d0
    cmpib #1,%d0
    jbne rsrc_DRVR_9__MPP_28A_6A
rsrc_DRVR_9__MPP_28A_50:  /* test %d1 */
    tstb %d1
    jbpl rsrc_DRVR_9__MPP_28A_58
    moveq #-50,%d0
    jbra rsrc_DRVR_9__MPP_28A_6C
rsrc_DRVR_9__MPP_28A_58:  /* set %a3@(502) */
    moveb %d1,%a3@(502)
    tstb %d0
    jbpl rsrc_DRVR_9__MPP_168
    moveb %d1,PortBUse
    jbra rsrc_DRVR_9__MPP_168
rsrc_DRVR_9__MPP_28A_6A:  /* set %d0 */
    moveq #-97,%d0
rsrc_DRVR_9__MPP_28A_6C:  /* continue at rsrc_DRVR_9__MPP_168_2 */
    jbra rsrc_DRVR_9__MPP_168_2
    tstb %a3@(502)
    bmiw rsrc_DRVR_9__MPP_168
    cmpb %a3@(502),%d1
    beqs rsrc_DRVR_9__MPP_28A_6C_18
    moveq #-97,%d0
    braw rsrc_DRVR_9__MPP_168_2
rsrc_DRVR_9__MPP_28A_6C_18:
    st %a3@(502)
    moveb PortBUse,%d0
    andib #15,%d0
    cmpib #1,%d0
    beqw rsrc_DRVR_9__MPP_168
    st PortBUse
    braw rsrc_DRVR_9__MPP_168
    jbsr rsrc_DRVR_9__MPP_28A
    jbne rsrc_DRVR_9__MPP_28A_AC
    moveq #1,%d1
    jbra rsrc_DRVR_9__MPP_168
rsrc_DRVR_9__MPP_28A_AC:  /* set %d1 */
    moveb %a3@(502),%d1
    jbra rsrc_DRVR_9__MPP_168
    moveml %a1,%sp@-
    moveal %a3@(498),%a0
    moveal %a0@,%a0
    movew %a0@+,%d0
    cmpw %d0,%d1
    bgtw rsrc_DRVR_9__MPP_28A_AC_A2
    bset #7,%a3@(628)
    bnew rsrc_DRVR_9__MPP_28A_AC_A2
    movew %d1,%sp@-
    moveq #0,%d0
rsrc_DRVR_9__MPP_28A_AC_28:
    subqw #1,%d1
    beqs rsrc_DRVR_9__MPP_28A_AC_32
    moveb %a0@+,%d0
    addal %d0,%a0
    bras rsrc_DRVR_9__MPP_28A_AC_28
rsrc_DRVR_9__MPP_28A_AC_32:
    moveal %a0,%a1
    lea %a3@(596),%a0
    movew #8,%a0@(4)
    movel %a1,%a0@(24)
    movew %sp@+,%d1
    cmpiw #1,%d1
    bnes rsrc_DRVR_9__MPP_28A_AC_90
    movel %a0,%sp@-
    pea %a1@
    moveal %a1,%a0
    moveal %a3@(632),%a1
    pea %a1@
    moveq #1,%d0
    addb %a0@,%d0
    _BlockMove
    moveal ABusVars,%a3
    lea %a3@(854),%a3
    moveb %a3@,%d0
    addb %d0,%a1@
    moveq #1,%d0
    addb %a0@,%d0
    addaw %d0,%a1
    moveb %a3@+,%d0
    moveal %a3,%a0
    _BlockMove
    moveb %a3@(-1),%d0
    addaw %d0,%a1
    moveal %sp@+,%a3
    moveal %sp@+,%a0
    moveb %a0@,%d0
    lea %a0@(0x1,%d0:w),%a0
    moveb %a0@+,%d0
    addb %d0,%a3@
    _BlockMove
    moveal %sp@+,%a0
    movel %a3,%a0@(24)
rsrc_DRVR_9__MPP_28A_AC_90:
    pea %pc@(rsrc_DRVR_9__MPP_28A_AC_AA)
    movel %sp@+,%a0@(28)
    movel %a5,%sp@-
    moveal CurrentA5,%a5
    _NMInstall
    moveal %sp@+,%a5
rsrc_DRVR_9__MPP_28A_AC_A2:
    moveml %sp@+,%a1
    braw rsrc_DRVR_9__MPP_168
rsrc_DRVR_9__MPP_28A_AC_AA:
    moveal %sp@(4),%a0
    _NMRemove
    moveal %sp@(4),%a0
    movel %sp@+,%sp@
    clrl %a0@(32)
    rts

rsrc_DRVR_9__MPP_3F2:   /* save registers */
    moveml %a1-%a2,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    lea %a3@(636),%a1
    exg %d0,%a0
    _StripAddress
    exg %d0,%a0
    movel %a1@(2),%a0@	| 408E4A9A
    movel %a0,%a1@(2)
    tstl %a0@
    jbne rsrc_DRVR_9__MPP_3F2_28
    movel %a0,%a1@(6)
rsrc_DRVR_9__MPP_3F2_28:  /* set %sr */
    movew %sp@+,%sr
    moveml %sp@+,%a1-%a2
    jbra rsrc_DRVR_9__MPP_168
    movel %a1,%sp@-
    lea %a3@(636),%a1
    exg %d0,%a0
    _StripAddress
    exg %d0,%a0
    _Dequeue
    moveal %sp@+,%a1
    braw rsrc_DRVR_9__MPP_168
    lea %a3@(636),%a1
    braw rsrc_DRVR_9__MPP_168

/* subroutine (125 instructions): traps Control; calls rsrc_DRVR_9__MPP_11D2, rsrc_DRVR_9__MPP_6FE, rsrc_DRVR_9__MPP_728, rsrc_DRVR_9__MPP_760; low memory ExpandMem (mechanical summary) */
rsrc_DRVR_9__MPP_440:
    moveml %d2/%a1-%a2,%sp@-
    jsr %pc@(rsrc_DRVR_9__MPP_11D2)
    movel %d0,%d1
    moveml %sp@+,%d2/%a1-%a2
    rts

rsrc_DRVR_9__MPP_450:   /* save registers */
    moveml %d2-%d4/%a0/%a2-%a3,%sp@-
    moveal %a0,%a3
    moveal %a0@,%a0
    tstw %d4
    jbpl rsrc_DRVR_9__MPP_450_E
    moveq #0,%d4
rsrc_DRVR_9__MPP_450_E:  /* set %d0 */
    moveq #1,%d0
    jsr %a0@(2)
    moveml %sp@+,%d2-%d4/%a0/%a2-%a3
    tstw %d0
    rts
    cmpiw #-1,%d4
    bnes rsrc_DRVR_9__MPP_450_E_16
    moveq #0,%d4
rsrc_DRVR_9__MPP_450_E_16:
    moveq #0,%d2
    subqw #2,%sp
    moveal %sp,%a0
    subqw #4,%sp
    movel %a0,%sp@-
    movew %d1,%sp@-
    andiw #255,%sp@
    bsrw rsrc_DRVR_9__MPP_10E6
    moveal %sp@+,%a0
    movel %a0,%d0
    bnes rsrc_DRVR_9__MPP_450_E_34
    moveq #-3,%d0
    bras rsrc_DRVR_9__MPP_450_E_46
rsrc_DRVR_9__MPP_450_E_34:
    movel %d1,%d3
    bsrs rsrc_DRVR_9__MPP_450
    bnes rsrc_DRVR_9__MPP_450_E_46
    moveb %d3,%d1
    bsrw rsrc_DRVR_9__MPP_BF6
    movel %d1,%a3@(0x8,%d0:w)
    moveq #0,%d0
rsrc_DRVR_9__MPP_450_E_46:
    movew %sp@+,%d3
    beqs rsrc_DRVR_9__MPP_450_E_52
    movel %d0,%sp@-
    movew %d3,%sp@-
    _CloseResFile
    movel %sp@+,%d0
rsrc_DRVR_9__MPP_450_E_52:
    tstw %d0
    braw rsrc_DRVR_9__MPP_168_2
    bsrw rsrc_DRVR_9__MPP_BF6
    tstl %a3@(0x0,%d0:w)
    beqs rsrc_DRVR_9__MPP_450_E_7C
    clrl %a3@(0x8,%d0:w)
    moveal %a3@(0x0,%d0:w),%a0
    bsrw rsrc_DRVR_9__MPP_C0A
    movel %a0,%sp@-
    bsrw rsrc_DRVR_9__MPP_115A
    moveal %sp@+,%a0
    beqs rsrc_DRVR_9__MPP_450_E_7C
    .short  0xA528	| 408E4B66 _RecoverHandle (flags 0x0500)
    _DisposHandle
rsrc_DRVR_9__MPP_450_E_7C:
    moveq #0,%d0
    braw rsrc_DRVR_9__MPP_168_2
    bsrw rsrc_DRVR_9__MPP_BF6
    movel %d1,%a3@(0x8,%d0:w)
    moveq #0,%d0
    braw rsrc_DRVR_9__MPP_168_2
    moveml %a0-%a2,%sp@-
    bsrw rsrc_DRVR_9__MPP_103C
    moveml %sp@+,%a0-%a2
    braw rsrc_DRVR_9__MPP_168_2
    lea %a3@(38),%a3
    moveq #6,%d0
rsrc_DRVR_9__MPP_450_E_A6:
    tstb %a3@
    beqs rsrc_DRVR_9__MPP_450_E_B0
    cmpw %a3@(2),%d2
    beqs rsrc_DRVR_9__MPP_450_E_CA
rsrc_DRVR_9__MPP_450_E_B0:
    lea %a3@(12),%a3
    subqw #1,%d0
    bnes rsrc_DRVR_9__MPP_450_E_A6
    subaw #12,%a3
    addqw #1,%d0
    tstb %a3@
    beqs rsrc_DRVR_9__MPP_450_E_CA
    cmpiw #6,%d0	| 408E4BB0
    bcss rsrc_DRVR_9__MPP_450_E_B0+0x8
    jbra rsrc_DRVR_9__MPP_450_F4
rsrc_DRVR_9__MPP_450_E_CA:/* an entry found: +2 = d2. If one of its two longs is already d1, done; otherwise a free one takes it */
    movew %d2,%a3@(2)	| 408E4BB8
    moveq #0,%d2
rsrc_DRVR_9__MPP_450_E_CA_6:
    cmpl %a3@(0x4,%d2:w),%d1	| 408E4BBE
    beqs rsrc_DRVR_9__MPP_450_F4
    subqw #4,%d2
    bpls rsrc_DRVR_9__MPP_450_E_CA_6
    moveq #0,%d2
rsrc_DRVR_9__MPP_450_E_CA_12:
    tstl %a3@(0x4,%d2:w)	| 408E4BCA
    beqs rsrc_DRVR_9__MPP_450_F4+0x4
    subqw #4,%d2
    bpls rsrc_DRVR_9__MPP_450_E_CA_12
rsrc_DRVR_9__MPP_450_F4:  /* continue at rsrc_DRVR_9__MPP_14E */
    jbra rsrc_DRVR_9__MPP_14E
    movel %a0,%a3@(0x8,%d2:w)
    tstb %a3@
    bnes rsrc_DRVR_9__MPP_450_F4_38
    subaw #50,%sp
    moveal %sp,%a0
    movew %a3@(2),%a0@(24)
    movew #247,%a0@(26)
    movew #-32525,%a0@(28)
    pea %pc@(rsrc_DRVR_9__MPP_450_1A6)
    aslw #2,%d0
    subl %d0,%sp@
    movel %sp@+,%a0@(30)
    _Control
    lea %sp@(50),%sp
    bnes rsrc_DRVR_9__MPP_450_F4
rsrc_DRVR_9__MPP_450_F4_38:
    movel %d1,%a3@(0x4,%d2:w)
    addqb #1,%a3@
    braw rsrc_DRVR_9__MPP_168
    lea %a3@(38),%a3
    moveq #6,%d0
rsrc_DRVR_9__MPP_450_F4_48:
    tstb %a3@
    beqs rsrc_DRVR_9__MPP_450_F4_52
    cmpw %a3@(2),%d2
    beqs rsrc_DRVR_9__MPP_450_F4_5E
rsrc_DRVR_9__MPP_450_F4_52:
    lea %a3@(12),%a3
    subqw #1,%d0
    bnes rsrc_DRVR_9__MPP_450_F4_48
rsrc_DRVR_9__MPP_450_F4_5A:
    braw rsrc_DRVR_9__MPP_14E
rsrc_DRVR_9__MPP_450_F4_5E:
    moveq #0,%d2
rsrc_DRVR_9__MPP_450_F4_60:
    cmpl %a3@(0x4,%d2:w),%d1
    beqs rsrc_DRVR_9__MPP_450_F4_6C
    subqw #4,%d2
    bpls rsrc_DRVR_9__MPP_450_F4_60
    bras rsrc_DRVR_9__MPP_450_F4_5A
rsrc_DRVR_9__MPP_450_F4_6C:
    clrl %a3@(0x4,%d2:w)
    subqb #1,%a3@
    bnes rsrc_DRVR_9__MPP_450_F4_96
    movel %a0,%sp@-
    subaw #50,%sp
    moveal %sp,%a0
    movew %a3@(2),%a0@(24)
    movew #248,%a0@(26)
    movew #-32525,%a0@(28)
    _Control
    lea %sp@(50),%sp
    moveal %sp@+,%a0
rsrc_DRVR_9__MPP_450_F4_96:
    braw rsrc_DRVR_9__MPP_168
    moveq #0,%d2
    jbra rsrc_DRVR_9__MPP_450_1A6
    moveq #1,%d2
    jbra rsrc_DRVR_9__MPP_450_1A6
    moveq #2,%d2
    jbra rsrc_DRVR_9__MPP_450_1A6
    moveq #3,%d2
    jbra rsrc_DRVR_9__MPP_450_1A6
    moveq #4,%d2
    jbra rsrc_DRVR_9__MPP_450_1A6
    .short  0x7405, 0x4E71	| 408E4C82
rsrc_DRVR_9__MPP_450_1A6:  /* from here: muluw #12,%d2 */
    muluw #12,%d2
    subqw #4,%sp
    moveal %sp,%a3
    moveq #4,%d3
    jsr %a4@
    jbne rsrc_DRVR_9__MPP_450_1DA
    movel %sp@+,%d0
    jbeq rsrc_DRVR_9__MPP_450_1CE
    moveal ExpandMem,%a5
    moveal %a5@(116),%a5
    addal %d2,%a5
    moveq #0,%d2
rsrc_DRVR_9__MPP_450_1C4:  /* loop: cmp */
    cmpl %a5@(0x2a,%d2:w),%d0
    jbeq rsrc_DRVR_9__MPP_450_1D4
    subqw #4,%d2
    jbpl rsrc_DRVR_9__MPP_450_1C4
rsrc_DRVR_9__MPP_450_1CE:  /* clear %d3 */
    moveq #0,%d3
    jmp %a4@(2)
rsrc_DRVR_9__MPP_450_1D4:  /* set %a5 */
    moveal %a5@(0x2e,%d2:w),%a5
    jmp %a5@
rsrc_DRVR_9__MPP_450_1DA:  /* add 4 to %sp */
    addqw #4,%sp
    rts

rsrc_DRVR_9__MPP_62E:   /* set %sp@- */
    movel %a2,%sp@-
    moveal %a3,%a2
    cmpib #1,%a1@
    jbne rsrc_DRVR_9__MPP_62E_76
    moveb %a1@(1),%d1
    btst #0,%d1
    jbne rsrc_DRVR_9__MPP_62E_76
    addqw #2,%a1
    lea %a2@(110),%a3
    moveq #5,%d0
rsrc_DRVR_9__MPP_62E_1C:  /* loop: cmp */
    cmpw %a3@,%d2
    jbeq rsrc_DRVR_9__MPP_62E_92
    addqw #8,%a3
    dbf %d0,rsrc_DRVR_9__MPP_62E_1C
    lea %a2@(110),%a3
    moveq #1,%d0
rsrc_DRVR_9__MPP_62E_2C:  /* loop: tst */
    tstw %a3@
    jbeq rsrc_DRVR_9__MPP_62E_3C
    addqw #8,%a3
    addqw #1,%d0
    cmpiw #6,%d0
    jble rsrc_DRVR_9__MPP_62E_2C
    jbra rsrc_DRVR_9__MPP_62E_76
rsrc_DRVR_9__MPP_62E_3C:  /* set %a3@ */
    movew %d2,%a3@
    clrw %a3@(2)
    clrw %a3@(4)
    clrw %a3@(6)
    movel %a0,%sp@-
    subaw #50,%sp
    moveal %sp,%a0
    movew %d2,%a0@(24)
    movew #247,%a0@(26)
    clrw %a0@(28)
    pea %pc@(rsrc_DRVR_9__MPP_8B8)
    aslw #2,%d0
    subl %d0,%sp@
    movel %sp@+,%a0@(30)
    _Control
    lea %sp@(50),%sp
    moveal %sp@+,%a0
    jbeq rsrc_DRVR_9__MPP_62E_7E
rsrc_DRVR_9__MPP_62E_76:  /* loop: movea */
    moveal %sp@+,%a2
    moveq #-2,%d0
    jbra rsrc_DRVR_9__MPP_168_2
rsrc_DRVR_9__MPP_62E_7E:  /* save registers */
    moveml %d1/%a0,%sp@-
    lea %pc@(rsrc_DRVR_9__MPP_A84),%a0
    moveb #0xaa,%d1
    jbsr rsrc_DRVR_9__MPP_6FE
    moveml %sp@+,%d1/%a0
    jbmi rsrc_DRVR_9__MPP_62E_76
rsrc_DRVR_9__MPP_62E_92:  /* test #0xaa,%d1 */
    cmpib #0xaa,%d1
    jbeq rsrc_DRVR_9__MPP_62E_A2
    jbsr rsrc_DRVR_9__MPP_6FE
    jbmi rsrc_DRVR_9__MPP_62E_76
    tstb %a1@
    jbne rsrc_DRVR_9__MPP_62E_76
    jbra rsrc_DRVR_9__MPP_62E_CA
rsrc_DRVR_9__MPP_62E_A2:  /* test #5,%a1@ */
    cmpib #5,%a1@
    jbne rsrc_DRVR_9__MPP_62E_76
    cmpib #4,%a1@(6)
    jbeq rsrc_DRVR_9__MPP_62E_B6
    jbsr rsrc_DRVR_9__MPP_728
    jbmi rsrc_DRVR_9__MPP_62E_76
    jbra rsrc_DRVR_9__MPP_62E_CA
rsrc_DRVR_9__MPP_62E_B6:  /* set %sp@- */
    movel %a0,%sp@-
    lea %pc@(rsrc_DRVR_9__MPP_ACE),%a0
    jbsr rsrc_DRVR_9__MPP_728
    moveal %sp@+,%a0
    jbmi rsrc_DRVR_9__MPP_62E_76
    tstb %a1@
    jbeq rsrc_DRVR_9__MPP_62E_CA
    jbsr rsrc_DRVR_9__MPP_760
    jbmi rsrc_DRVR_9__MPP_62E_76
rsrc_DRVR_9__MPP_62E_CA:  /* set %a2 */
    moveal %sp@+,%a2
    jbra rsrc_DRVR_9__MPP_168

/* subroutine (15 instructions) (mechanical summary) */
rsrc_DRVR_9__MPP_6FE:
    movel %a1,%sp@-
    lea %a2@(158),%a1
    moveq #7,%d0
rsrc_DRVR_9__MPP_6FE_8:  /* loop: tst */
    tstw %a1@(4)
    jbeq rsrc_DRVR_9__MPP_6FE_16
    addqw #8,%a1
    dbf %d0,rsrc_DRVR_9__MPP_6FE_8
    jbra rsrc_DRVR_9__MPP_6FE_24
rsrc_DRVR_9__MPP_6FE_16:  /* set %a1@ */
    movel %a0,%a1@
    movew %d2,%a1@(4)
    moveb %d1,%a1@(6)
    addqb #1,%a3@(2)
rsrc_DRVR_9__MPP_6FE_24:  /* test %d0 */
    tstw %d0
    moveal %sp@+,%a1
    rts

/* subroutine (20 instructions) (mechanical summary) */
rsrc_DRVR_9__MPP_728:
    movel %a2,%sp@-
    lea %a2@(222),%a2
    moveq #15,%d0
rsrc_DRVR_9__MPP_728_8:  /* loop: tst */
    tstw %a2@(4)
    jbeq rsrc_DRVR_9__MPP_728_18
    lea %a2@(12),%a2
    dbf %d0,rsrc_DRVR_9__MPP_728_8
    jbra rsrc_DRVR_9__MPP_728_32
rsrc_DRVR_9__MPP_728_18:  /* set %a2@ */
    movel %a0,%a2@
    movew %d2,%a2@(4)
    lea %a2@(6),%a2
    moveb %a1@+,%d0
    subqw #1,%d0
rsrc_DRVR_9__MPP_728_26:  /* loop: move */
    moveb %a1@+,%a2@+
    dbf %d0,rsrc_DRVR_9__MPP_728_26
    addqb #1,%a3@(4)
    addqw #1,%d0
rsrc_DRVR_9__MPP_728_32:  /* test %d0 */
    tstw %d0
    moveal %sp@+,%a2
    rts

/* subroutine (96 instructions): traps Control; calls rsrc_DRVR_9__MPP_86C (mechanical summary) */
rsrc_DRVR_9__MPP_760:
    movel %a2,%sp@-
    lea %a2@(414),%a2
    moveq #7,%d0
rsrc_DRVR_9__MPP_760_8:  /* loop: tst */
    tstw %a2@(4)
    jbeq rsrc_DRVR_9__MPP_760_18
    lea %a2@(10),%a2
    dbf %d0,rsrc_DRVR_9__MPP_760_8
    jbra rsrc_DRVR_9__MPP_760_32
rsrc_DRVR_9__MPP_760_18:  /* set %a2@ */
    movel %a0,%a2@
    movew %d2,%a2@(4)
    lea %a2@(6),%a2
    moveb %a1@+,%d0
    subqw #1,%d0
rsrc_DRVR_9__MPP_760_26:  /* loop: move */
    moveb %a1@+,%a2@+
    dbf %d0,rsrc_DRVR_9__MPP_760_26
    addqb #1,%a3@(6)
    addqw #1,%d0
rsrc_DRVR_9__MPP_760_32:  /* test %d0 */
    tstw %d0
    moveal %sp@+,%a2
    rts

rsrc_DRVR_9__MPP_798:   /* set %sp@- */
    movel %a2,%sp@-
    moveal %a3,%a2
    lea %a2@(110),%a3
    moveq #5,%d0
rsrc_DRVR_9__MPP_798_A:  /* loop: cmp */
    cmpw %a3@,%d2
    jbeq rsrc_DRVR_9__MPP_798_1C
    addqw #8,%a3
    dbf %d0,rsrc_DRVR_9__MPP_798_A
rsrc_DRVR_9__MPP_798_14:  /* loop: movea */
    moveal %sp@+,%a2
    moveq #-3,%d0
    jbra rsrc_DRVR_9__MPP_168_2
rsrc_DRVR_9__MPP_798_1C:  /* clear %d0 */
    moveq #0,%d0
    moveq #0,%d1
rsrc_DRVR_9__MPP_798_20:  /* loop: move */
    moveb %a1@,%d1
    jbeq rsrc_DRVR_9__MPP_798_32
    movel %a1,%sp@-
    addqw #1,%d1
    addaw %d1,%a1
    addqw #1,%d0
    cmpiw #3,%d0
    jblt rsrc_DRVR_9__MPP_798_20
rsrc_DRVR_9__MPP_798_32:  /* test #3,%d0 */
    cmpiw #3,%d0
    jbeq rsrc_DRVR_9__MPP_798_4A
    cmpiw #2,%d0
    jbeq rsrc_DRVR_9__MPP_798_6C
    cmpiw #1,%d0
    jbeq rsrc_DRVR_9__MPP_798_8E
    cmpiw #0,%d0
    jbeq rsrc_DRVR_9__MPP_798_14
rsrc_DRVR_9__MPP_798_4A:  /* set %a1 */
    moveal %sp@+,%a1
    moveml %a2-%a3,%sp@-
    lea %a2@(414),%a2
    lea %a3@(6),%a3
    moveq #7,%d0
    moveq #10,%d3
    jbsr rsrc_DRVR_9__MPP_86C
    moveml %sp@+,%a2-%a3
    tstb %a3@(6)
    jbeq rsrc_DRVR_9__MPP_798_6C
    addqw #8,%sp
    jbra rsrc_DRVR_9__MPP_798_CE
rsrc_DRVR_9__MPP_798_6C:  /* set %a1 */
    moveal %sp@+,%a1
    moveml %a2-%a3,%sp@-
    lea %a2@(222),%a2
    lea %a3@(4),%a3
    moveq #15,%d0
    moveq #12,%d3
    jbsr rsrc_DRVR_9__MPP_86C
    moveml %sp@+,%a2-%a3
    tstb %a3@(4)
    jbeq rsrc_DRVR_9__MPP_798_8E
    addqw #4,%sp
    jbra rsrc_DRVR_9__MPP_798_CE
rsrc_DRVR_9__MPP_798_8E:  /* set %a1 */
    moveal %sp@+,%a1
    moveml %a2-%a3,%sp@-
    lea %a2@(158),%a2
    lea %a3@(2),%a3
    moveq #7,%d0
    moveq #8,%d3
    jbsr rsrc_DRVR_9__MPP_86C
    moveml %sp@+,%a2-%a3
    tstb %a3@(2)
    jbeq rsrc_DRVR_9__MPP_798_AE
    jbra rsrc_DRVR_9__MPP_798_CE
rsrc_DRVR_9__MPP_798_AE:  /* clear %a3@ */
    clrw %a3@
    movel %a0,%sp@-
    subaw #50,%sp
    moveal %sp,%a0
    movew %d2,%a0@(24)
    movew #248,%a0@(26)
    clrw %a0@(28)
    _Control
    lea %sp@(50),%sp
    moveal %sp@+,%a0
rsrc_DRVR_9__MPP_798_CE:  /* set %a2 */
    moveal %sp@+,%a2
    jbra rsrc_DRVR_9__MPP_168

/* subroutine (19 instructions) (mechanical summary) */
rsrc_DRVR_9__MPP_86C:
    cmpw %a2@(4),%d2
    jbeq rsrc_DRVR_9__MPP_86C_E
rsrc_DRVR_9__MPP_86C_6:  /* loop: adda */
    addaw %d3,%a2
    dbf %d0,rsrc_DRVR_9__MPP_86C
    jbra rsrc_DRVR_9__MPP_86C_30
rsrc_DRVR_9__MPP_86C_E:  /* save registers */
    moveml %d0/%a1-%a2,%sp@-
    lea %a2@(6),%a2
    moveb %a1@+,%d0
    subqw #1,%d0
rsrc_DRVR_9__MPP_86C_1A:  /* loop: cmpm */
    cmpmb %a1@+,%a2@+
    dbne %d0,rsrc_DRVR_9__MPP_86C_1A
    moveml %sp@+,%d0/%a1-%a2
    jbne rsrc_DRVR_9__MPP_86C_6
    clrw %a2@(4)
    clrl %a2@
    subqb #1,%a3@
    addqw #1,%d0
rsrc_DRVR_9__MPP_86C_30:  /* test %d0 */
    tstw %d0
    rts
    .byte   0x74, 0x05, 0x60, 0x14, 0x74, 0x04, 0x60, 0x10, 0x74, 0x03, 0x60, 0x0C, 0x74, 0x02, 0x60, 0x08	| 408E4F30
    .byte   0x74, 0x01, 0x60, 0x04, 0x74, 0x00, 0x4E, 0x71	| 408E4F40

/* subroutine (100 instructions): traps trap_A404; calls rsrc_DRVR_9__MPP_A42, rsrc_DRVR_9__MPP_A0A (mechanical summary) */
rsrc_DRVR_9__MPP_8B8:
    moveal ExpandMem,%a2	| 408E4F48
    moveal %a2@(116),%a2	| 408E4F4C
    moveq #14,%d0	| 408E4F50
    subaw %d0,%a3	| 408E4F52
    lea %a2@(510),%a5	| 408E4F54
    moveq #6,%d0	| 408E4F58
rsrc_DRVR_9__MPP_8CA:   /* loop: move */
    movew %a3@+,%a5@+	| 408E4F5A
    dbf %d0,rsrc_DRVR_9__MPP_8CA	| 408E4F5C
    moveal %a5,%a3	| 408E4F60
    movew %a3@(-2),%d0	| 408E4F62
    cmpw %d1,%d0	| 408E4F66
    jbge rsrc_DRVR_9__MPP_8DC	| 408E4F68
    movew %d0,%d1	| 408E4F6A
rsrc_DRVR_9__MPP_8DC:   /* address %a2@(110) */
    lea %a2@(110),%a5	| 408E4F6C
    muluw #8,%d2	| 408E4F70
    addaw %d2,%a5	| 408E4F74
    movew %a5@,%d2	| 408E4F76
    moveq #3,%d3	| 408E4F78
    jsr %a4@	| 408E4F7A
    jbeq rsrc_DRVR_9__MPP_8F0	| 408E4F7C
    rts	| 408E4F7E
rsrc_DRVR_9__MPP_8F0:   /* set %d0 */
    moveb %a3@(-1),%d0	| 408E4F80
    btst #0,%a3@(-2)	| 408E4F84
    jbne rsrc_DRVR_9__MPP_904	| 408E4F8A
    cmpib #3,%d0	| 408E4F8C
    jbeq rsrc_DRVR_9__MPP_914	| 408E4F90
    jbra rsrc_DRVR_9__MPP_940	| 408E4F92
rsrc_DRVR_9__MPP_904:   /* clear bit 4 of %d0 */
    bclr #4,%d0	| 408E4F94
    cmpib #0xe3,%d0	| 408E4F98 408E4F98 cmpib #-29,%d0
    jbeq rsrc_DRVR_9__MPP_914	| 408E4F9C
    cmpib #0xaf,%d0	| 408E4F9E 408E4F9E cmpib #-81,%d0
    jbne rsrc_DRVR_9__MPP_93C	| 408E4FA2
rsrc_DRVR_9__MPP_914:   /* address %a2@(158) */
    lea %a2@(158),%a5	| 408E4FA4
    lea %a2@(222),%a2	| 408E4FA8
    moveb %a3@(-3),%d0	| 408E4FAC
    moveq #8,%d3	| 408E4FB0
rsrc_DRVR_9__MPP_922:   /* loop: cmp */
    cmpw %a5@(4),%d2	| 408E4FB2
    jbne rsrc_DRVR_9__MPP_936	| 408E4FB6
    cmpb %a5@(6),%d0	| 408E4FB8
    jbne rsrc_DRVR_9__MPP_936	| 408E4FBC
    tstl %a5@	| 408E4FBE
    jbeq rsrc_DRVR_9__MPP_93C	| 408E4FC0
    moveal %a5@,%a5	| 408E4FC2
    jmp %a5@	| 408E4FC4
rsrc_DRVR_9__MPP_936:   /* from here: addal %d3,%a5 */
    addal %d3,%a5	| 408E4FC6
    cmpal %a2,%a5	| 408E4FC8
    jblt rsrc_DRVR_9__MPP_922	| 408E4FCA
rsrc_DRVR_9__MPP_93C:   /* continue at rsrc_DRVR_9__MPP_A0A */
    jbra rsrc_DRVR_9__MPP_A0A	| 408E4FCC
rsrc_DRVR_9__MPP_940:   /* clear bit 4 of %d0 */
    bclr #4,%d0	| 408E4FD0
    cmpib #0xe3,%d0	| 408E4FD4 408E4FD4 cmpib #-29,%d0
    jbeq rsrc_DRVR_9__MPP_950	| 408E4FD8
    cmpib #0xaf,%d0	| 408E4FDA 408E4FDA cmpib #-81,%d0
    jbne rsrc_DRVR_9__MPP_93C	| 408E4FDE
rsrc_DRVR_9__MPP_950:   /* test %a2@(558) */
    tstw %a2@(558)	| 408E4FE0
    jbne rsrc_DRVR_9__MPP_93C	| 408E4FE4
    lea %pc@(rsrc_DRVR_9__MPP_A3C),%a3	| 408E4FE6
    movel %a3,%a2@(544)	| 408E4FEA
    moveb %a2@(524),%d3	| 408E4FEE
    jbeq rsrc_DRVR_9__MPP_980	| 408E4FF2
    btst #0,%d3	| 408E4FF4
    jbeq rsrc_DRVR_9__MPP_978	| 408E4FF8
    cmpib #0xff,%d3	| 408E4FFA 408E4FFA cmpib #-1,%d3
    jbne rsrc_DRVR_9__MPP_93C	| 408E4FFE
    lea %pc@(rsrc_DRVR_9__MPP_A10),%a3	| 408E5000
    movel %a3,%a2@(544)	| 408E5004
rsrc_DRVR_9__MPP_978:   /* call rsrc_DRVR_9__MPP_A42 */
    jbsr rsrc_DRVR_9__MPP_A42	| 408E5008
    tstw %d3	| 408E500C
    jbeq rsrc_DRVR_9__MPP_93C	| 408E500E
rsrc_DRVR_9__MPP_980:   /* address %a2@(516) */
    lea %a2@(516),%a5	| 408E5010
    lea %a2@(504),%a3	| 408E5014
    movel %a3,%a2@(584)	| 408E5018
    movew #17,%a2@(582)	| 408E501C
    movel %a5@+,%a3@+	| 408E5022
    movew %a5@+,%a3@+	| 408E5024
    lea %a2@(522),%a5	| 408E5026
    lea %a2@(516),%a3	| 408E502A
    movew %a5@+,%a3@+	| 408E502E
    moveb %a5@(1),%a3@+	| 408E5030
    bset #0,%d3	| 408E5034
    moveb %d3,%a3@+	| 408E5038
    moveb %a5@(2),%d0	| 408E503A
    moveb %d0,%a3@+	| 408E503E
    bclr #4,%d0	| 408E5040
    cmpib #0xe3,%d0	| 408E5044 408E5044 cmpib #-29,%d0
    jbne rsrc_DRVR_9__MPP_9D4	| 408E5048
    movew %d1,%d3	| 408E504A
    cmpiw #10,%d1	| 408E504C
    jble rsrc_DRVR_9__MPP_9CA	| 408E5050
    movew #3,%a2@(516)	| 408E5052
    moveq #0,%d3	| 408E5058
rsrc_DRVR_9__MPP_9CA:   /* from here: addw %d3,%a2@(582) */
    addw %d3,%a2@(582)	| 408E505A
    jsr %a4@(2)	| 408E505E
    jbra rsrc_DRVR_9__MPP_9F0	| 408E5062
rsrc_DRVR_9__MPP_9D4:   /* (408E5064 cmpib #-81,%d0) */
    cmpib #0xaf,%d0	| 408E5064 408E5064 cmpib #-81,%d0
    jbne rsrc_DRVR_9__MPP_A0A	| 408E5068
    movew #6,%a2@(516)	| 408E506A
    addqw #3,%a2@(582)	| 408E5070
    moveb #0x81,%a3@+	| 408E5074 408E5074 moveb #-127,%a3@+
    moveb #1,%a3@+	| 408E5078
    clrb %a3@+	| 408E507C
    jbsr rsrc_DRVR_9__MPP_A0A	| 408E507E
rsrc_DRVR_9__MPP_9F0:   /* address %a2@(532) */
    lea %a2@(532),%a0	| 408E5080
    lea %a2@(582),%a1	| 408E5084
    movew %d2,%a0@(24)	| 408E5088
    movew #249,%a0@(26)	| 408E508C
    movel %a1,%a0@(30)	| 408E5092
    .short  0xA404	| 408E5096 408E5096 A-line trap
    rts	| 408E5098

/* subroutine (17 instructions): traps trap_A404; calls rsrc_DRVR_9__MPP_A4E (mechanical summary) */
rsrc_DRVR_9__MPP_A0A:
    moveq #0,%d3	| 408E509A
    jmp %a4@(2)	| 408E509C
rsrc_DRVR_9__MPP_A10:   /* set %a2 */
    moveal ExpandMem,%a2	| 408E50A0
    moveal %a2@(116),%a2	| 408E50A4
    moveb #0xff,%d3	| 408E50A8 408E50A8 moveb #-1,%d3
    movew %a2@(594),%d2	| 408E50AC
    moveq #8,%d0	| 408E50B0
    moveal %a2@(590),%a3	| 408E50B2
    lea %a2@(222),%a2	| 408E50B6
    jbsr rsrc_DRVR_9__MPP_A4E	| 408E50BA
    tstb %d3	| 408E50BC
    jbeq rsrc_DRVR_9__MPP_A3C	| 408E50BE
    bset #0,%d3	| 408E50C0
    moveb %d3,%a2@(519)	| 408E50C4
    .short  0xA404	| 408E50C8 408E50C8 A-line trap
    rts	| 408E50CA
rsrc_DRVR_9__MPP_A3C:   /* clear %a0@(26) */
    clrw %a0@(26)	| 408E50CC
    rts	| 408E50D0

/* subroutine (4 instructions) (mechanical summary) */
rsrc_DRVR_9__MPP_A42:
    lea %a2@(158),%a3	| 408E50D2
    lea %a2@(222),%a2	| 408E50D6
    moveq #8,%d0	| 408E50DA
    subaw %d0,%a3	| 408E50DC

/* subroutine (35 instructions): calls rsrc_DRVR_9__MPP_118C (mechanical summary) */
rsrc_DRVR_9__MPP_A4E:
    addaw %d0,%a3	| 408E50DE
    cmpal %a2,%a3	| 408E50E0
    jbge rsrc_DRVR_9__MPP_A70	| 408E50E2
    cmpw %a3@(4),%d2	| 408E50E4
    jbne rsrc_DRVR_9__MPP_A4E	| 408E50E8
    tstl %a3@	| 408E50EA
    jbeq rsrc_DRVR_9__MPP_A4E	| 408E50EC
    cmpib #0xff,%d3	| 408E50EE 408E50EE cmpib #-1,%d3
    jbeq rsrc_DRVR_9__MPP_A6A	| 408E50F2
    cmpb %a3@(6),%d3	| 408E50F4
    jbne rsrc_DRVR_9__MPP_A4E	| 408E50F8
rsrc_DRVR_9__MPP_A6A:   /* set %d3 */
    moveb %a3@(6),%d3	| 408E50FA
    jbne rsrc_DRVR_9__MPP_A72	| 408E50FE
rsrc_DRVR_9__MPP_A70:   /* clear %d3 */
    clrb %d3	| 408E5100
rsrc_DRVR_9__MPP_A72:   /* set %a2 */
    moveal ExpandMem,%a2	| 408E5102
    moveal %a2@(116),%a2	| 408E5106
    movel %a3,%a2@(590)	| 408E510A
    movew %d2,%a2@(594)	| 408E510E
rsrc_DRVR_9__MPP_A82:   /* return */
    rts	| 408E5112
rsrc_DRVR_9__MPP_A84:   /* set %d3 */
    moveq #5,%d3	| 408E5114
    jsr %a4@	| 408E5116
    jbne rsrc_DRVR_9__MPP_A82	| 408E5118
    moveal ExpandMem,%a2	| 408E511A
    moveal %a2@(116),%a2	| 408E511E
    lea %a2@(222),%a5	| 408E5122
    lea %a2@(414),%a2	| 408E5126
    .byte   0x20, 0x2B	| 408E512A
    .long   0xFFFAE188 /* number, not a label difference (was fpsp_LP1CONT2-.) */	| 408E512C
    moveb %a3@(-2),%d0
    moveb %a3@(-1),%d3
rsrc_DRVR_9__MPP_A84_24:
    cmpw %a5@(4),%d2
    bnes rsrc_DRVR_9__MPP_A84_3E
    cmpl %a5@(6),%d0
    bnes rsrc_DRVR_9__MPP_A84_3E
    cmpb %a5@(10),%d3
    bnes rsrc_DRVR_9__MPP_A84_3E
    tstl %a5@
    beqs rsrc_DRVR_9__MPP_A84_46
    moveal %a5@,%a5
    jmp %a5@
rsrc_DRVR_9__MPP_A84_3E:
    lea %a5@(12),%a5
    cmpal %a2,%a5
    blts rsrc_DRVR_9__MPP_A84_24
rsrc_DRVR_9__MPP_A84_46:
    braw rsrc_DRVR_9__MPP_A0A
rsrc_DRVR_9__MPP_ACE:   /* string "YO&O6<\000" */
    .ascii  "YO&O6<\000"
    .byte   0x04, 0x4E, 0x94, 0x4C, 0xDF, 0x00, 0x01, 0x66, 0xA4, 0x24, 0x78	| 408E5165
    .long   0x02B6246A, 0x00744BEA, 0x019E45EA, 0x01EEB46D	| 408E5170
    .long   0x0004660E, 0xB0AD0006, 0x66084A95, 0x670C2A55	| 408E5180
    .long   0x4ED54BED, 0x000ABBCA, 0x6DE46000, 0xFEFE2741	| 408E5190
    .long   0x028600AB, 0x00008000, 0x02866000, 0xF64C222B	| 408E51A0
    .long   0x02864A81, 0x6B409EFC, 0x007A204F, 0x43EB0006	| 408E51B0
    .long   0x21490012, 0x4268001C, 0x31780210, 0x0016A00C	| 408E51C0
    .long   0x4FEF007A, 0x662A6100, 0xF8F81001, 0x72000C00	| 408E51D0
    .short  0x007F, 0x6604, 0x0041	| 408E51E0
    .short  0x0001, 0x4A6B	| orib #107,%d1
    .short  0x0002, 0x6704	| orib #4,%d2
    oriw #2,%d1
    oriw #4,%d1
    andil #2147483647,%d1
    jbra rsrc_DRVR_9__MPP_168
    moveq #0,%d0
    braw rsrc_DRVR_9__MPP_168
    swap %d0
    lea %pc@(rsrc_DRVR_9__MPP_ACE_BC),%a3
    addw %d0,%d0
    addaw %a3@(-2,%d0:w),%a3
    movel %a3,%d0
    moveal %sp@+,%a3
    movel %d0,%sp@-
    rts
rsrc_DRVR_9__MPP_ACE_BC:
    .short  0x0006, 0x0138	| orib #56,%d6
    .short  0x06EA	| .short 0x06ea
    moveq #0,%d0
    cmpib #6,SysVersion
    beqs rsrc_DRVR_9__MPP_ACE_D6
    btst #5,0xb20
    bnes rsrc_DRVR_9__MPP_ACE_D6
    addql #1,%d0
rsrc_DRVR_9__MPP_ACE_D6:
    tstl %d0
    rts
    jbsr rsrc_DRVR_9__MPP_118C
    moveq #1,%d1
    btst #1,%d0
    jbne rsrc_DRVR_9__MPP_168
    moveq #3,%d1
    jbra rsrc_DRVR_9__MPP_168
    lea %pc@(rsrc_DRVR_9__MPP_ACE_D6_28),%a0
    movel #1635019638,%d0
    .short  0xA3AD	| 408E5256 _Gestalt (flags 0x0300)
    braw rsrc_DRVR_9__MPP_168
rsrc_DRVR_9__MPP_ACE_D6_28:
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
    cmpil #1635019638,%d0
    beqs rsrc_DRVR_9__MPP_ACE_D6_42
    clrl %a0@
    movew #-5551,%sp@(12)
    bras rsrc_DRVR_9__MPP_ACE_D6_4C
rsrc_DRVR_9__MPP_ACE_D6_42:
    moveq #0,%d0
    movel %pc@(rsrc_DRVR_9__MPP_8_10),%a0@	| 408E5278
    clrw %sp@(12)
rsrc_DRVR_9__MPP_ACE_D6_4C:
    moveal %sp@+,%a0
    addql #8,%sp
    jmp %a0@

/* subroutine (12 instructions) (mechanical summary) */
rsrc_DRVR_9__MPP_BF6:
    moveq #0,%d0
    cmpb %a3@(1),%d4
    jbcc rsrc_DRVR_9__MPP_BF6_A
    moveb %d4,%d0
rsrc_DRVR_9__MPP_BF6_A:  /* from here: muluw #16,%d0 */
    muluw #16,%d0
    addiw #650,%d0
    rts

rsrc_DRVR_9__MPP_C0A:   /* save registers */
    moveml %d0-%d3/%a0-%a3,%sp@-
    moveq #2,%d0
    jsr %a0@(2)
    moveml %sp@+,%d0-%d3/%a0-%a3
    rts

/* subroutine (35 instructions): traps SysEnvirons, AliasDispatch, FSDispatch (mechanical summary) */
rsrc_DRVR_9__MPP_C1A:
    linkw %fp,#-74
    lea %fp@(-68),%a0
    movew #1,%d0
    _SysEnvirons
    movew %fp@(-64),%d1
    cmpiw #1792,%d1
    jbcs rsrc_DRVR_9__MPP_C1A_66
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
    jbne rsrc_DRVR_9__MPP_C1A_6A
    lea %fp@(-52),%a0
    movew %fp@(-70),%a0@(22)
    movel %fp@(-74),%a0@(48)
    clrl %a0@(18)
    movel #1635019883,%a0@(28)
    moveq #1,%d0
    .short  0xA260	| 408E5300 _FSDispatch (flags 0x0200)
    movew %a0@(16),%d0
    moveq #0,%d0
    jbne rsrc_DRVR_9__MPP_C1A_6A
    movew %a0@(22),%d0
    jbra rsrc_DRVR_9__MPP_C1A_6A
rsrc_DRVR_9__MPP_C1A_66:  /* set %d0 */
    movew %fp@(-54),%d0
rsrc_DRVR_9__MPP_C1A_6A:  /* return */
    unlk %fp
    moveal %sp@+,%a0
    addqw #4,%sp
    movew %d0,%sp@
    jmp %a0@

/* subroutine (17 instructions): traps SysEnvirons, FSDispatch (mechanical summary) */
rsrc_DRVR_9__MPP_C1A_74:
    linkw %fp,#-68
    moveq #0,%d0
    lea %fp@(-68),%a0
    movew #1,%d0
    _SysEnvirons
    movew %fp@(8),%d1
    cmpw %fp@(-54),%d1
    jbeq rsrc_DRVR_9__MPP_C1A_9E
    lea %fp@(-52),%a0
    movew %d1,%a0@(22)
    moveq #2,%d0
    .short  0xA260	| 408E5342 _FSDispatch (flags 0x0200)
    movew %a0@(16),%d0
rsrc_DRVR_9__MPP_C1A_9E:  /* return */
    unlk %fp
    moveal %sp@+,%a0
    addqw #2,%sp
    movew %d0,%sp@
    jmp %a0@

/* subroutine (58 instructions): traps Get1Resource, GetResource; calls rsrc_DRVR_9__MPP_D76; low memory CurMap, ROMMapInsert, ResErr, SysMap (mechanical summary) */
rsrc_DRVR_9__MPP_CC2:
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
    jbeq rsrc_DRVR_9__MPP_CC2_34
    subal %a2,%a2
rsrc_DRVR_9__MPP_CC2_34:  /* set CurMap */
    movew SysMap,CurMap
    clrl %sp@-
    movel %fp@(10),%sp@-
    movew %fp@(8),%sp@-
    _Get1Resource
    moveal %sp@+,%a3
    tstw ResErr
    jbeq rsrc_DRVR_9__MPP_CC2_50
    subal %a3,%a3
rsrc_DRVR_9__MPP_CC2_50:  /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a2,%sp@-
    movel %a3,%sp@-
    movel %fp@(10),%sp@-
    bsrw rsrc_DRVR_9__MPP_D76
    moveal %sp@+,%a2
    movel %d0,%d3
    movew %fp@(-2),CurMap
    clrl %sp@-
    movel %fp@(10),%sp@-
    movew %fp@(8),%sp@-
    _GetResource
    moveal %sp@+,%a3
    tstw ResErr
    jbeq rsrc_DRVR_9__MPP_CC2_7E
    subal %a3,%a3
rsrc_DRVR_9__MPP_CC2_7E:  /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a2,%sp@-
    movel %a3,%sp@-
    movel %fp@(10),%sp@-
    bsrw rsrc_DRVR_9__MPP_D76
    moveal %sp@+,%a2
    movel %d0,%d3
    clrw ResErr
    movel %a2,%fp@(14)
    jbne rsrc_DRVR_9__MPP_CC2_A0
    movew #-192,ResErr
rsrc_DRVR_9__MPP_CC2_A0:  /* set %a0 */
    moveal %a2,%a0
    movel %d3,%d0
    moveml %sp@+,%d1-%d4/%a1-%a3
    movel %fp@(4),%fp@(10)
    unlk %fp
    addqw #6,%sp
    rts

/* subroutine (49 instructions): traps ReleaseResource; calls rsrc_DRVR_9__MPP_DFE (mechanical summary) */
rsrc_DRVR_9__MPP_D76:
    linkw %fp,#0
    moveml %d1-%d4/%a1-%a3,%sp@-
    moveal %fp@(16),%a2
    moveal %fp@(12),%a3
    subqw #4,%sp
    movel %a2,%sp@-
    movel %fp@(8),%sp@-
    bsrw rsrc_DRVR_9__MPP_DFE
    movel %sp@+,%d3
    cmpiw #-32768,%d3
    jbne rsrc_DRVR_9__MPP_D76_28
    moveb #0xff,%d3
rsrc_DRVR_9__MPP_D76_28:  /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a3,%sp@-
    movel %fp@(8),%sp@-
    bsrw rsrc_DRVR_9__MPP_DFE
    movel %sp@+,%d4
    cmpiw #-32768,%d4
    jbne rsrc_DRVR_9__MPP_D76_40
    moveb #0xff,%d4
rsrc_DRVR_9__MPP_D76_40:  /* test %d3,%d4 */
    cmpl %d3,%d4
    jbcs rsrc_DRVR_9__MPP_D76_58
    jbeq rsrc_DRVR_9__MPP_D76_48
    jbra rsrc_DRVR_9__MPP_D76_54
rsrc_DRVR_9__MPP_D76_48:  /* set %d0 */
    movel %a2,%d0
    jbne rsrc_DRVR_9__MPP_D76_4E
    jbra rsrc_DRVR_9__MPP_D76_54
rsrc_DRVR_9__MPP_D76_4E:  /* set %d0 */
    movel %a3,%d0
    jbeq rsrc_DRVR_9__MPP_D76_66
    jbra rsrc_DRVR_9__MPP_D76_58
rsrc_DRVR_9__MPP_D76_54:  /* from here: exg %a2,%a3 */
    exg %a2,%a3
    exg %d3,%d4
rsrc_DRVR_9__MPP_D76_58:  /* test %a2,%a3 */
    cmpal %a2,%a3
    jbeq rsrc_DRVR_9__MPP_D76_66
    cmpaw #0,%a3
    jbeq rsrc_DRVR_9__MPP_D76_66
    movel %a3,%sp@-
    _ReleaseResource
rsrc_DRVR_9__MPP_D76_66:  /* set %fp@(20) */
    movel %a2,%fp@(20)
    moveal %a2,%a0
    cmpiw #-32513,%d3
    jbne rsrc_DRVR_9__MPP_D76_74
    clrb %d3
rsrc_DRVR_9__MPP_D76_74:  /* set %d0 */
    movel %d3,%d0
    moveml %sp@+,%d1-%d4/%a1-%a3
    movel %fp@(4),%fp@(16)
    unlk %fp
    lea %sp@(12),%sp
    rts

/* subroutine (84 instructions): traps GetHandleSize; calls rsrc_DRVR_9__MPP_F04 (mechanical summary) */
rsrc_DRVR_9__MPP_DFE:
    linkw %fp,#0
    moveml %d1-%d5/%a1-%a2,%sp@-
    moveq #0,%d4
    tstl %fp@(12)
    jbeq rsrc_DRVR_9__MPP_DFE_EE
    moveal %fp@(12),%a0
    movel %a0@,%d5
    jbeq rsrc_DRVR_9__MPP_DFE_EE
    moveal %fp@(12),%a0
    _GetHandleSize
    movel %d0,%d2
    jbmi rsrc_DRVR_9__MPP_DFE_EE
    moveal %d5,%a2
    cmpil #1146246738,%fp@(8)
    jbeq rsrc_DRVR_9__MPP_DFE_9A
    cmpil #1701733748,%fp@(8)
    jbeq rsrc_DRVR_9__MPP_DFE_9A
    cmpil #1953459054,%fp@(8)
    jbeq rsrc_DRVR_9__MPP_DFE_9A
    cmpil #1717855337,%fp@(8)
    jbeq rsrc_DRVR_9__MPP_DFE_9A
    cmpil #1685223026,%fp@(8)
    jbeq rsrc_DRVR_9__MPP_DFE_9A
    cmpil #8,%d2
    jbls rsrc_DRVR_9__MPP_DFE_EE
    movew %a2@(6),%d4
    addaw %d4,%a2
    addil #11,%d4
    cmpl %d4,%d2
    jbls rsrc_DRVR_9__MPP_DFE_EE
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
    bsrw rsrc_DRVR_9__MPP_F04
    tstw %sp@+
    jbne rsrc_DRVR_9__MPP_DFE_F0
    jbra rsrc_DRVR_9__MPP_DFE_EE
rsrc_DRVR_9__MPP_DFE_9A:  /* set %d4 */
    movew #18,%d4
    cmpl %d4,%d2
    jbls rsrc_DRVR_9__MPP_DFE_EE
    moveq #0,%d0
    moveb %a2@(0x0,%d4:w),%d0
    addqw #1,%d0
    btst #0,%d0
    jbeq rsrc_DRVR_9__MPP_DFE_B2
    addqw #1,%d0
rsrc_DRVR_9__MPP_DFE_B2:  /* from here: addw %d0,%d4 */
    addw %d0,%d4
    addaw %d4,%a2
    addil #11,%d4
    cmpl %d4,%d2
    jbls rsrc_DRVR_9__MPP_DFE_EE
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
    bsrw rsrc_DRVR_9__MPP_F04
    tstw %sp@+
    jbne rsrc_DRVR_9__MPP_DFE_EC
    movew %a2@,%d3
    clrb %d3
    swap %d3
    movew #-32768,%d3
rsrc_DRVR_9__MPP_DFE_EC:  /* continue at rsrc_DRVR_9__MPP_DFE_F0 */
    jbra rsrc_DRVR_9__MPP_DFE_F0
rsrc_DRVR_9__MPP_DFE_EE:  /* clear %d3 */
    moveq #0,%d3
rsrc_DRVR_9__MPP_DFE_F0:  /* set %fp@(16) */
    movel %d3,%fp@(16)
    movel %d3,%d0
    moveml %sp@+,%d1-%d5/%a1-%a2
    movel %fp@(4),%fp@(12)
    unlk %fp
    addqw #8,%sp
    rts

/* subroutine (52 instructions): calls rsrc_DRVR_9__MPP_FA2 (mechanical summary) */
rsrc_DRVR_9__MPP_F04:
    linkw %fp,#-16
    moveml %d1-%d4/%a1-%a2,%sp@-
    tstl %fp@(8)
    jbeq rsrc_DRVR_9__MPP_F04_84
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
    bsrw rsrc_DRVR_9__MPP_FA2
    moveq #0,%d0
    moveb %a0@+,%d0
    addaw %d0,%a0
    movel %d3,%d0
    swap %d0
    lsrw #4,%d0
    andil #15,%d0
    bsrw rsrc_DRVR_9__MPP_FA2
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
    jbeq rsrc_DRVR_9__MPP_F04_88
rsrc_DRVR_9__MPP_F04_84:  /* result 0 */
    moveq #0,%d0
    jbra rsrc_DRVR_9__MPP_F04_8A
rsrc_DRVR_9__MPP_F04_88:  /* set %d0 */
    moveq #1,%d0
rsrc_DRVR_9__MPP_F04_8A:  /* set %fp@(12) */
    movew %d0,%fp@(12)
    moveml %sp@+,%d1-%d4/%a1-%a2
    movel %fp@(4),%fp@(8)
    unlk %fp
    addqw #4,%sp
    rts

/* subroutine (24 instructions) (mechanical summary) */
rsrc_DRVR_9__MPP_FA2:
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
    jbne rsrc_DRVR_9__MPP_FA2_56
    moveb #2,%a0@
    moveb %a0@(2),%a0@(1)
    moveb %a0@(3),%a0@(2)
    cmpib #48,%a0@(1)
    jbne rsrc_DRVR_9__MPP_FA2_56
    moveb #1,%a0@
    moveb %a0@(2),%a0@(1)
rsrc_DRVR_9__MPP_FA2_56:  /* set %d0 */
    movel %sp@+,%d0
    rts

/* subroutine (25 instructions): traps GetResource, DetachResource, CloseResFile; calls rsrc_DRVR_9__MPP_103C (mechanical summary) */
rsrc_DRVR_9__MPP_FFC:
    movew #-1,%sp@-
    clrl %sp@-
    subaw #32,%sp
    moveal %sp,%a1
    jbsr rsrc_DRVR_9__MPP_103C
    lea %sp@(32),%sp
    movew %d0,%sp@(4)
    jbne rsrc_DRVR_9__MPP_FFC_3A
    subqw #4,%sp
    movel #1635019883,%sp@-
    movew %d1,%sp@-
    clrb %sp@
    _GetResource
    movel %sp@+,%d0
    jbeq rsrc_DRVR_9__MPP_FFC_36
    movel %d0,%sp@
    clrw %sp@(4)
    movel %d0,%sp@-
    _DetachResource
    jbra rsrc_DRVR_9__MPP_FFC_3A
rsrc_DRVR_9__MPP_FFC_36:  /* set up and call _CloseResFile */
    movew %d2,%sp@-
    _CloseResFile
rsrc_DRVR_9__MPP_FFC_3A:  /* set %a0 */
    moveal %sp@+,%a0
    movew %sp@+,%d0
    rts

/* subroutine (117 instructions): traps GetFileInfo, OpenRFPerm, Get1Resource, CloseResFile, Gestalt, StripAddress; calls rsrc_DRVR_9__MPP_C1A, rsrc_DRVR_9__MPP_C1A_74, rsrc_DRVR_9__MPP_CC2, rsrc_DRVR_9__MPP_FFC, rsrc_DRVR_9__MPP_D76; low memory ResLoad, ResErr, ROMBase (mechanical summary) */
rsrc_DRVR_9__MPP_103C:
    movew ResLoad,%sp@-
    clrw ResLoad
    moveml %d1/%a1,%sp@-
    subqw #2,%sp
    movel #1702392942,%sp@-
    jbsr rsrc_DRVR_9__MPP_C1A
    movew %sp@+,%d0
    moveml %sp@+,%d1/%a1
    movew %d0,%sp@-
    subaw #122,%sp
    moveal %sp,%a2
    movew %d0,%a2@(22)
    movel %a1,%a2@(18)
    clrw %a2@(28)
    tstb %d1
    jbne rsrc_DRVR_9__MPP_103C_3A
    movew %d3,%a2@(28)
rsrc_DRVR_9__MPP_103C_3A:  /* set up and call _GetFileInfo (loop) */
    moveal %a2,%a0
    clrw %a0@(26)
    addqw #1,%a0@(28)
    _GetFileInfo
    jbne rsrc_DRVR_9__MPP_103C_8A
    movel %a0@(32),%d0
    cmpil #1633969526,%d0
    jbne rsrc_DRVR_9__MPP_103C_3A
    clrw %sp@-
    movel %a1,%sp@-
    movew %a0@(22),%sp@-
    clrb %sp@-
    _OpenRFPerm
    movew %sp@+,%d2
    movew ResErr,%d0
    jbne rsrc_DRVR_9__MPP_103C_3A
    tstb %d1
    jbeq rsrc_DRVR_9__MPP_103C_86
    subqw #4,%sp
    movel #1635019883,%sp@-
    movew %d1,%sp@-
    clrb %sp@
    _Get1Resource
    moveq #0,%d0
    tstl %sp@+
    jbne rsrc_DRVR_9__MPP_103C_8A
    movew %d2,%sp@-
    _CloseResFile
    jbra rsrc_DRVR_9__MPP_103C_3A
rsrc_DRVR_9__MPP_103C_86:  /* set %d3 */
    movew %a2@(28),%d3
rsrc_DRVR_9__MPP_103C_8A:  /* address %sp@(122) */
    lea %sp@(122),%sp
    moveml %d0-%d2,%sp@-
    subqw #2,%sp
    movew %sp@(14),%sp@-
    jbsr rsrc_DRVR_9__MPP_C1A_74
    movew %sp@+,%d0
    moveml %sp@+,%d0-%d2
    addqw #2,%sp
    movew %sp@+,ResLoad
    rts

rsrc_DRVR_9__MPP_10E6:  /* from here: linkw %fp,#0 */
    linkw %fp,#0
    moveml %d1-%d2/%a1,%sp@-
    moveal %fp@(10),%a1
    clrw %a1@
    clrw %d1
    moveb %fp@(9),%d1
    subqw #4,%sp
    movel #1635019883,%sp@-
    movew %d1,%sp@-
    jbsr rsrc_DRVR_9__MPP_CC2
    jbsr rsrc_DRVR_9__MPP_FFC
    tstw %d0
    jbne rsrc_DRVR_9__MPP_10E6_60
    moveal %sp@+,%a1
    movew %d2,%sp@-
    movel %a0,%sp@-
    subqw #4,%sp
    movel %a1,%sp@-
    movel %a0,%sp@-
    movel #1635019883,%sp@-
    jbsr rsrc_DRVR_9__MPP_D76
    movel %sp@+,%d0
    moveal %sp@+,%a0
    movew %sp@+,%d2
    moveal %fp@(10),%a1
    cmpl %a0,%d0
    jbne rsrc_DRVR_9__MPP_10E6_56
    movew %d2,%a1@
rsrc_DRVR_9__MPP_10E6_50:  /* loop: move */
    movel %d0,%fp@(14)
    jbra rsrc_DRVR_9__MPP_10E6_64
rsrc_DRVR_9__MPP_10E6_56:  /* set up and call _CloseResFile */
    movel %d0,%sp@-
    movew %d2,%sp@-
    _CloseResFile
    movel %sp@+,%d0
    jbra rsrc_DRVR_9__MPP_10E6_50
rsrc_DRVR_9__MPP_10E6_60:  /* set %fp@(14) */
    movel %sp@+,%fp@(14)
rsrc_DRVR_9__MPP_10E6_64:  /* restore registers, return */
    moveml %sp@+,%d1-%d2/%a1
    movel %fp@(4),%fp@(10)
    unlk %fp
    addqw #6,%sp
    rts

rsrc_DRVR_9__MPP_115A:  /* save registers */
    moveml %d1/%a1,%sp@-
    moveal %a0,%a1
    movel #1919905056,%d0
    .short  0xA1AD	| 408E57F6 _Gestalt (flags 0x0100)
    movel %a0,%d1
    movel %a1,%d0
    _StripAddress
    moveal %d0,%a0
    movel ROMBase,%d0
    _StripAddress
    cmpal %d0,%a0
    jbcs rsrc_DRVR_9__MPP_115A_28
    addl %d0,%d1
    moveq #0,%d0
    cmpal %d1,%a0
    jbcs rsrc_DRVR_9__MPP_115A_2A
rsrc_DRVR_9__MPP_115A_28:  /* set %d0 */
    moveq #-1,%d0
rsrc_DRVR_9__MPP_115A_2A:  /* test %d0 */
    tstl %d0
    moveml %sp@+,%d1/%a1
    rts

/* subroutine (16 instructions): traps DockingDispatch; calls rsrc_DRVR_9__MPP_1274 (mechanical summary) */
rsrc_DRVR_9__MPP_118C:
    moveml %d1-%d2/%a1-%a2,%sp@-
    clrb %sp@-
    movew #-21929,%sp@-
    jbsr rsrc_DRVR_9__MPP_1274
    tstb %sp@+
    jbeq rsrc_DRVR_9__MPP_118C_26
    subqw #4,%sp
    movel #1935893283,%sp@-
    clrl %sp@-
    _DockingDispatch
    movel %sp@+,%d0
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts
rsrc_DRVR_9__MPP_118C_26:  /* set %d0 */
    moveq #3,%d0
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts

/* subroutine (8 instructions): traps ReadXPRam; low memory HWCfgFlags (mechanical summary) */
rsrc_DRVR_9__MPP_11BA:
    clrl %sp@-
    btst #14,HWCfgFlags
    jbeq rsrc_DRVR_9__MPP_11BA_14
    moveal %sp,%a0
    movel #262368,%d0
    _ReadXPRam
rsrc_DRVR_9__MPP_11BA_14:  /* set %d0 */
    movel %sp@+,%d0
    rts

/* subroutine (26 instructions): calls rsrc_DRVR_9__MPP_11BA, rsrc_DRVR_9__MPP_118C (mechanical summary) */
rsrc_DRVR_9__MPP_11D2:
    bsrw rsrc_DRVR_9__MPP_11BA
    tstl %d0
    jbne rsrc_DRVR_9__MPP_11D2_A
    moveq #1,%d0
rsrc_DRVR_9__MPP_11D2_A:  /* test #1,%d0 */
    cmpib #1,%d0
    jbeq rsrc_DRVR_9__MPP_11D2_16
    cmpib #3,%d0
    jbne rsrc_DRVR_9__MPP_11D2_4A
rsrc_DRVR_9__MPP_11D2_16:  /* save registers */
    moveml %d0-%d2/%a1-%a2,%sp@-
    bsrw rsrc_DRVR_9__MPP_118C
    andiw #3,%d0
    cmpiw #3,%d0
    jbeq rsrc_DRVR_9__MPP_11D2_46
    btst #0,%d0
    moveml %sp@+,%d0-%d2/%a1-%a2
    jbne rsrc_DRVR_9__MPP_11D2_3C
    cmpib #1,%d0
    jbeq rsrc_DRVR_9__MPP_11D2_4A
    moveq #1,%d0
    rts
rsrc_DRVR_9__MPP_11D2_3C:  /* test #3,%d0 */
    cmpib #3,%d0
    jbeq rsrc_DRVR_9__MPP_11D2_4A
    moveq #3,%d0
    rts
rsrc_DRVR_9__MPP_11D2_46:  /* restore registers */
    moveml %sp@+,%d0-%d2/%a1-%a2
rsrc_DRVR_9__MPP_11D2_4A:  /* return */
    rts

/* subroutine (27 instructions): traps WriteXPRam; calls rsrc_DRVR_9__MPP_118C, rsrc_DRVR_9__MPP_121E (mechanical summary) */
rsrc_DRVR_9__MPP_121E:
    movel %d0,%sp@-
    movel %a0,%sp@-
    lea %sp@(12),%a0
    movel #262368,%d0
    _WriteXPRam
    moveal %sp@+,%a0
    movel %sp@+,%d0
    rts

rsrc_DRVR_9__MPP_1234:  /* from here: linkw %fp,#0 */
    linkw %fp,#0
    moveml %d0-%d2/%a0-%a2,%sp@-
    jbsr rsrc_DRVR_9__MPP_118C
    andiw #3,%d0
    cmpiw #3,%d0
    jbeq rsrc_DRVR_9__MPP_1234_2E
    btst #0,%d0
    jbne rsrc_DRVR_9__MPP_1234_26
    cmpib #1,%fp@(11)
    jbeq rsrc_DRVR_9__MPP_1234_38
    jbra rsrc_DRVR_9__MPP_1234_2E
rsrc_DRVR_9__MPP_1234_26:  /* test #3,%fp@(11) */
    cmpib #3,%fp@(11)
    jbeq rsrc_DRVR_9__MPP_1234_38
rsrc_DRVR_9__MPP_1234_2E:  /* set %sp@- */
    movel %fp@(8),%sp@-
    bsrw rsrc_DRVR_9__MPP_121E
    addqw #4,%sp
rsrc_DRVR_9__MPP_1234_38:  /* set %d0-%d2/%a0-%a2 */
    moveml %sp@,%d0-%d2/%a0-%a2
    unlk %fp
    rts

/* subroutine (59 instructions): calls rsrc_DRVR_9__MPP_1316 (mechanical summary) */
rsrc_DRVR_9__MPP_1274:
    linkw %fp,#0
    moveml %d6-%d7,%sp@-
    movew %fp@(8),%d7
    movew #2048,%d0
    andw %d7,%d0
    jbeq rsrc_DRVR_9__MPP_1274_18
    moveq #1,%d0
    jbra rsrc_DRVR_9__MPP_1274_1A
rsrc_DRVR_9__MPP_1274_18:  /* clear %d0 */
    moveq #0,%d0
rsrc_DRVR_9__MPP_1274_1A:  /* set %d6 */
    moveb %d0,%d6
    moveq #0,%d0
    moveb %d6,%d0
    cmpiw #1,%d0
    jbne rsrc_DRVR_9__MPP_1274_6C
    movew #2047,%d0
    andw %d7,%d0
    movew %d0,%d7
    extl %d7
    subql #4,%sp
    movew #-22418,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_DRVR_9__MPP_1316)
    subql #4,%sp
    movew #-21906,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_DRVR_9__MPP_1316)
    movel %sp@+,%d0
    cmpl %sp@+,%d0
    jbne rsrc_DRVR_9__MPP_1274_5A
    movel #512,%d0
    jbra rsrc_DRVR_9__MPP_1274_60
rsrc_DRVR_9__MPP_1274_5A:  /* set %d0 */
    movel #1024,%d0
rsrc_DRVR_9__MPP_1274_60:  /* from here: extl %d0 */
    extl %d0
    cmpw %d7,%d0
    jbgt rsrc_DRVR_9__MPP_1274_6C
    clrb %fp@(10)
    jbra rsrc_DRVR_9__MPP_1274_94
rsrc_DRVR_9__MPP_1274_6C:  /* subtract 4 to %sp */
    subql #4,%sp
    movew %d7,%sp@-
    moveb %d6,%sp@-
    jsr %pc@(rsrc_DRVR_9__MPP_1316)
    subql #4,%sp
    movew #-22369,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_DRVR_9__MPP_1316)
    movel %sp@+,%d0
    cmpl %sp@+,%d0
    sne %d0
    andiw #1,%d0
    extl %d0
    moveb %d0,%fp@(10)
rsrc_DRVR_9__MPP_1274_94:  /* restore registers, return */
    moveml %fp@(-8),%d6-%d7
    unlk %fp
    moveal %sp@+,%a0
    addqw #2,%sp
    jmp %a0@

/* subroutine (9 instructions): traps GetTrapAddress (mechanical summary) */
rsrc_DRVR_9__MPP_1316:
    moveal %sp@+,%a1
    moveb %sp@+,%d1
    movew %sp@+,%d0
    tstb %d1
    jbeq rsrc_DRVR_9__MPP_1316_E
    .short  0xA746	| 408E59B0 _GetTrapAddress (flags 0x0700)
    jbra rsrc_DRVR_9__MPP_1316_10
rsrc_DRVR_9__MPP_1316_E:  /* (_GetTrapAddress (flags 0x0300)) */
    .short  0xA346	| 408E59B4 _GetTrapAddress (flags 0x0300)
rsrc_DRVR_9__MPP_1316_10:  /* set %sp@ */
    movel %a0,%sp@
    jmp %a1@
    FILL_408E59BA
