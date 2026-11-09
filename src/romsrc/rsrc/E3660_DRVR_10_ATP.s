/* ROM resource 'DRVR' 10 ".ATP": map entry at 0x408E3660, data at 0x408E3690, 4042 bytes

 The .ATP driver ('DRVR' 10, ".ATP DRVR v57.0.4", (c) Apple 1984-1992): the AppleTalk
 Transaction Protocol (requests and responses with retries, on top of DDP from .MPP).
 Its Control calls (csCodes 248-259) go through ATP_CONTROL_TABLE; the names are those
 of Inside Macintosh's ATP calls. Comments inferred from the code and the documented calls.
*/

rsrc_DRVR_10__ATP_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408E3660
    .long   rsrc_DRVR_40__XPP_entry-rom_start	| 408E3668
    .long   rsrc_DRVR_10__ATP-rom_start	| 408E366C
    .ascii  "DRVR"	| 408E3670
    .byte   0x00, 0x0A, 0x58	| 408E3674
    .byte   4	/* 408E3677 Pascal string length */
    .ascii  ".ATP"	| 408E3678
    FILL_408E367C
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x0F, 0xD6, 0x00, 0x00, 0x02, 0xAC	| 408E3684

/* subroutine (0 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP:
    .byte   0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408E3690
rsrc_DRVR_10__ATP_8:    /* (data) */
    .short  rsrc_DRVR_10__ATP_open-rsrc_DRVR_10__ATP	| 408E3698
    .short  rsrc_DRVR_10__ATP_prime-rsrc_DRVR_10__ATP	| 408E369A
    .short  rsrc_DRVR_10__ATP_ctl-rsrc_DRVR_10__ATP	| 408E369C
    .short  rsrc_DRVR_10__ATP_prime-rsrc_DRVR_10__ATP	| 408E369E
    .short  rsrc_DRVR_10__ATP_close-rsrc_DRVR_10__ATP	| 408E36A0
    .byte   0x04, 0x2E, 0x41, 0x54, 0x50, 0x20	| 408E36A2
rsrc_DRVR_10__ATP_18:   /* (data) */
    .long   0x39048000, 0x00000835	| 408E36A8
    .long   0x372E302E, 0x34202000, 0x352E4154, 0x50204452	| 408E36B0
    .long   0x56522076, 0x35372E30, 0x2E342020, 0x3B20A920	| 408E36C0
    .long   0x4170706C, 0x6520436F, 0x6D707574, 0x65722C20	| 408E36D0
    .short  0x496E, 0x632E, 0x2031, 0x3938, 0x342D, 0x3139, 0x3932	| 408E36E0

/* Open: nothing to set up beyond .MPP (the AppleTalk variables, ABusVars, are .MPP's). */
rsrc_DRVR_10__ATP_open:
    movel ABusVars,%d1
    jbgt rsrc_DRVR_10__ATP_open_12
    cmpil #-1,%d1
    jbne rsrc_DRVR_10__ATP_open_12
    moveq #-23,%d0
    jbra rsrc_DRVR_10__ATP_open_8C
rsrc_DRVR_10__ATP_open_12:  /* set %a3 */
    moveal %d1,%a3
    moveq #0,%d0
    tstl %a3@(30)
    jbne rsrc_DRVR_10__ATP_open_8C
    movew #3026,%d0
    .short  0xA71E	| 408E370E _NewPtr (flags 0x0700)
    jbne rsrc_DRVR_10__ATP_open_8C
    bset #4,PortBUse
    movel %a0,%a3@(30)
    moveb %pc@(rsrc_DRVR_10__ATP_18),%a1@(7)
    movew #3198,%a0@
    movew #8200,%a0@(2)
    lea %a0@(2162),%a2
    movel %a1,%a2@+
    movew Ticks_LoWord,%a2@+
    moveq #5,%d0
    moveal ROMBase,%a3
    cmpib #118,%a3@(9)
    jbcs rsrc_DRVR_10__ATP_open_5E
    movew TimeDBRA,%d0
    divuw #100,%d0
rsrc_DRVR_10__ATP_open_5E:  /* set %a0@(3019) */
    moveb %d0,%a0@(3019)
    muluw #120,%d0
    subiw #142,%d0
    divuw #48,%d0
    movew %d0,%a0@(3020)
    movel Time,%a0@(2182)
    moveal %a2,%a0
    addqw #4,%a2
    movew #1,%a2@+
    lea %pc@(rsrc_DRVR_10__ATP_830),%a1
    movel %a1,%a2@+
    movew #6,%a2@+
    _VInstall
rsrc_DRVR_10__ATP_open_8C:  /* return */
    rts

/* Control: dispatch csCode 248-259 through ATP_CONTROL_TABLE. */
rsrc_DRVR_10__ATP_ctl:
    moveal ROMBase,%a2
    cmpib #118,%a2@(9)
    jbcs rsrc_DRVR_10__ATP_ctl_22
    moveal AGBHandle,%a2
    movel %a2,%d3
    addql #1,%d3
    jbeq rsrc_DRVR_10__ATP_ctl_22
    moveal %a2@,%a2
    movel %a2@(8),%d3
    jbeq rsrc_DRVR_10__ATP_ctl_22
    moveal %d3,%a2
    jsr %a2@
rsrc_DRVR_10__ATP_ctl_22:  /* test ABusVars */
    tstl ABusVars
    jbne rsrc_DRVR_10__ATP_ctl_2E
    moveq #-17,%d0
rsrc_DRVR_10__ATP_ctl_2A:  /* continue at ATP_CloseATPSkt_34 */
    jbra ATP_CloseATPSkt_34
rsrc_DRVR_10__ATP_ctl_2E:  /* set %d2 */
    movew %a0@(26),%d2
    subqw #1,%d2
    jbne rsrc_DRVR_10__ATP_ctl_38
    rts
rsrc_DRVR_10__ATP_ctl_38:  /* set %d0 */
    moveq #-17,%d0
    subiw #247,%d2
    jblt rsrc_DRVR_10__ATP_ctl_2A
    cmpiw #11,%d2
    jbgt rsrc_DRVR_10__ATP_ctl_2A
    addw %d2,%d2
    lea %pc@(ATP_CONTROL_TABLE),%a3
    addaw %d2,%a3
    moveaw %a3@,%a3
    lea %pc@(rsrc_DRVR_10__ATP),%a2
    addal %a2,%a3
    moveal ABusVars,%a2
    moveal %a2@(30),%a2
    moveb %a0@(28),%d1
    subiw #12,%d2
    jbpl rsrc_DRVR_10__ATP_ctl_80
    movew #-1099,%d0
    tstb %d1
    jbeq ATP_CloseATPSkt_30
    moveq #125,%d2
rsrc_DRVR_10__ATP_ctl_74:  /* loop: cmp */
    cmpb %a2@(0x4c,%d2:w),%d1
    dbeq %d2,rsrc_DRVR_10__ATP_ctl_74
    jbne ATP_CloseATPSkt_30
rsrc_DRVR_10__ATP_ctl_80:  /* set %d3 */
    movel %a0@(30),%d3
    andib #63,%a0@(29)
    jmp %a3@
ATP_CONTROL_TABLE:  /* csCode 248-259, offsets from rsrc_DRVR_10__ATP */
    .short  ATP_cs248-rsrc_DRVR_10__ATP  /* csCode 248 */
    .short  ATP_RelRspCB-rsrc_DRVR_10__ATP  /* csCode 249 */
    .short  ATP_CloseATPSkt-rsrc_DRVR_10__ATP  /* csCode 250 */
    .short  ATP_AddResponse-rsrc_DRVR_10__ATP  /* csCode 251 */
    .short  ATP_SendResponse-rsrc_DRVR_10__ATP  /* csCode 252 */
    .short  ATP_GetRequest-rsrc_DRVR_10__ATP  /* csCode 253 */
    .short  ATP_OpenATPSkt-rsrc_DRVR_10__ATP  /* csCode 254 */
    .short  ATP_SendRequest-rsrc_DRVR_10__ATP  /* csCode 255 */
    .short  ATP_RelTCB-rsrc_DRVR_10__ATP  /* csCode 256 */
    .short  ATP_cs257-rsrc_DRVR_10__ATP  /* csCode 257 */
    .short  ATP_cs258-rsrc_DRVR_10__ATP  /* csCode 258 */
    .short  ATP_cs259-rsrc_DRVR_10__ATP  /* csCode 259 */

/* Close: cancel the outstanding transactions and close the ATP sockets. */
rsrc_DRVR_10__ATP_close:
    moveal ABusVars,%a1
    movel %a1,%d0
    jbeq rsrc_DRVR_10__ATP_close_52
    moveal %a1@(30),%a2
    movel %a1@(830),%d0
    btst #10,%d0
    jbne rsrc_DRVR_10__ATP_close_38
rsrc_DRVR_10__ATP_close_16:  /* call rsrc_DRVR_10__ATP_F88 (loop) */
    jbsr rsrc_DRVR_10__ATP_F88
    jbne rsrc_DRVR_10__ATP_close_16
    moveq #12,%d2
    lea %a2@(4),%a0
    jbsr rsrc_DRVR_10__ATP_1E4
rsrc_DRVR_10__ATP_close_24:  /* loop: tst */
    tstw %a3@(16)
    jbgt rsrc_DRVR_10__ATP_close_24
    moveq #126,%d2
    lea %a2@(76),%a0
    jbsr rsrc_DRVR_10__ATP_1E4
rsrc_DRVR_10__ATP_close_32:  /* loop: tst */
    tstw %a3@(16)
    jbgt rsrc_DRVR_10__ATP_close_32
rsrc_DRVR_10__ATP_close_38:  /* set up and call _StripAddress */
    pea %a2@(2168)
    movel %sp@+,%d0
    _StripAddress
    moveal %d0,%a0
    _VRemove
    moveal %a2,%a0
    _DisposPtr
    clrl %a1@(30)
    bclr #4,PortBUse
rsrc_DRVR_10__ATP_close_52:  /* return */
    rts

/* subroutine (8 instructions): calls rsrc_DRVR_10__ATP_770 (mechanical summary) */
rsrc_DRVR_10__ATP_1E4:
    clrw %a3@(16)
rsrc_DRVR_10__ATP_1E4_4:  /* loop: subq */
    subqw #1,%d2
    jbmi rsrc_DRVR_10__ATP_close_52
    moveb %a0@+,%d1
    jbeq rsrc_DRVR_10__ATP_1E4_4
    movew #247,%d0
    jbsr rsrc_DRVR_10__ATP_770
    jbra rsrc_DRVR_10__ATP_1E4_4

/* Control csCode 254: OpenATPSkt. */
ATP_OpenATPSkt:
    movew #-1098,%d0	| 408E388A
    moveq #125,%d2	| 408E388E
ATP_OpenATPSkt_6:       /* (408E3890 tstb %a2@(4c,%d2:w)) */
    tstb %a2@(0x4c,%d2:w)	| 408E3890 408E3890 tstb %a2@(4c,%d2:w)
    dbeq %d2,ATP_OpenATPSkt_6	| 408E3894
    jbne ATP_CloseATPSkt_30	| 408E3898
    jbsr rsrc_DRVR_10__ATP_F88
    jbne ATP_CloseATPSkt_30
    lea %pc@(rsrc_DRVR_10__ATP_AA4),%a1
    addw %d2,%d2
    addaw %d2,%a1
    addw %d2,%d2
    movel %a1,%a3@(30)
    movew #248,%d0
    jbsr rsrc_DRVR_10__ATP_770
    moveb %a3@(28),%d1
    jbsr rsrc_DRVR_10__ATP_FC4
    tstw %d0
    jbne ATP_CloseATPSkt_30
    addaw %d2,%a2
    clrl %a2@(202)
    clrl %a2@(706)
    movel %d3,%a2@(1210)
    subaw %d2,%a2
    lsrw #2,%d2
    addaw %d2,%a2
    moveb %d1,%a2@(76)
    subaw %d2,%a2
    moveb %d1,%a0@(28)
    jbra ATP_CloseATPSkt_2E

/* Control csCode 250: CloseATPSkt. */
ATP_CloseATPSkt:
    jbsr rsrc_DRVR_10__ATP_F88
    jbne ATP_CloseATPSkt_30
    movew #247,%d0
    jbsr rsrc_DRVR_10__ATP_770
    jbsr rsrc_DRVR_10__ATP_FC4
    tstw %d0
    jbne ATP_CloseATPSkt_30
    clrb %a2@(0x4c,%d2:w)
    lea %a2@(1714),%a1
    moveq #31,%d2
ATP_CloseATPSkt_20:     /* loop: cmp */
    cmpb %a1@,%d1
    jbne ATP_CloseATPSkt_26
    clrb %a1@
ATP_CloseATPSkt_26:     /* address %a1@(14) */
    lea %a1@(14),%a1
    dbf %d2,ATP_CloseATPSkt_20
ATP_CloseATPSkt_2E:     /* loop: moveq */
    moveq #0,%d0
ATP_CloseATPSkt_30:     /* loop: movea */
    moveal %a2@(2162),%a1
ATP_CloseATPSkt_34:     /* loop: movea */
    moveal JIODone,%a0
    jmp %a0@

/* Prime: nothing (ATP is used through Control). */
rsrc_DRVR_10__ATP_prime:
    bclr #7,%a1@(5)
    rts

/* Control csCode 253: GetRequest. */
ATP_GetRequest:
    lslw #2,%d2	| 408E3924
    lea %a2@(202),%a1	| 408E3926
    addaw %d2,%a1	| 408E392A

/* subroutine (27 instructions): calls rsrc_DRVR_10__ATP_ctl (mechanical summary) */
rsrc_DRVR_10__ATP_29C:
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
rsrc_DRVR_10__ATP_29C_A:  /* loop: tst */
    tstl %a1@
    jbeq rsrc_DRVR_10__ATP_29C_12
    moveal %a1@,%a1
    jbra rsrc_DRVR_10__ATP_29C_A
rsrc_DRVR_10__ATP_29C_12:  /* set %a1@ */
    movel %a0,%a1@
rsrc_DRVR_10__ATP_29C_14:  /* loop: movea */
    moveal %a2@(2162),%a1
    bclr #7,%a1@(5)
    movel %a0@,%a1@(8)
    jbne rsrc_DRVR_10__ATP_29C_28
    clrl %a1@(12)
rsrc_DRVR_10__ATP_29C_28:  /* clear %a0@ */
    clrl %a0@
    movel %a1@(8),%d0
    jbeq rsrc_DRVR_10__ATP_29C_4C
    bset #7,%a1@(5)
    movew %sp@+,%sr
    moveml %d1-%d3/%a0/%a2-%a3,%sp@-
    moveal %d0,%a0
    moveq #0,%d0
    jbsr rsrc_DRVR_10__ATP_ctl
    moveml %sp@+,%d1-%d3/%a0/%a2-%a3
    moveq #0,%d0
    rts
rsrc_DRVR_10__ATP_29C_4C:  /* set %sr */
    movew %sp@+,%sr
    rts

/* Control csCode 257: csCode 257 (name not known). */
ATP_cs257:
    moveal %a0@(44),%a1	| 408E397C
    moveb %a1@(28),%d1	| 408E3980
    jbeq ATP_cs257_4C	| 408E3984
    moveq #125,%d2	| 408E3986
ATP_cs257_C:            /* (408E3988 cmpb %a2@(4c,%d2:w),%d1) */
    cmpb %a2@(0x4c,%d2:w),%d1	| 408E3988 408E3988 cmpb %a2@(4c,%d2:w),%d1
    dbeq %d2,ATP_cs257_C	| 408E398C
    jbne ATP_cs257_4C	| 408E3990
    aslw #2,%d2	| 408E3992
    lea %a2@(202),%a3	| 408E3994
    addaw %d2,%a3	| 408E3998
    movew %sr,%sp@-	| 408E399A
    oriw #1792,%sr	| 408E399C
    andiw #-257,%sr	| 408E39A0
ATP_cs257_28:           /* loop: move */
    movel %a3@,%d0	| 408E39A4
    jbeq ATP_cs257_4A	| 408E39A6
    subl %a1,%d0	| 408E39A8
    _StripAddress	| 408E39AA 408E39AA A-line trap
    tstl %d0	| 408E39AC
    jbeq ATP_cs257_38	| 408E39AE
    moveal %a3@,%a3	| 408E39B0
    jbra ATP_cs257_28	| 408E39B2
ATP_cs257_38:           /* set %a3@ */
    movel %a1@,%a3@	| 408E39B4
    movew %sp@+,%sr	| 408E39B6
    moveal %a1,%a0	| 408E39B8
    movew #-1105,%d0	| 408E39BA
    jbsr rsrc_DRVR_10__ATP_96E	| 408E39BE
    jbra ATP_CloseATPSkt_2E	| 408E39C2
ATP_cs257_4A:           /* set %sr */
    movew %sp@+,%sr	| 408E39C6
ATP_cs257_4C:           /* set %d0 */
    movew #-1102,%d0	| 408E39C8
    jbra ATP_CloseATPSkt_30	| 408E39CC

/* Control csCode 259: csCode 259 (name not known). */
ATP_cs259:
    moveb %a0@(28),%d1	| 408E39D0
    jbeq rsrc_DRVR_10__ATP_37E	| 408E39D4
    moveq #125,%d2	| 408E39D6
ATP_cs259_8:            /* (408E39D8 cmpb %a2@(4c,%d2:w),%d1) */
    cmpb %a2@(0x4c,%d2:w),%d1	| 408E39D8 408E39D8 cmpb %a2@(4c,%d2:w),%d1
    dbeq %d2,ATP_cs259_8	| 408E39DC
    jbne rsrc_DRVR_10__ATP_37E	| 408E39E0
    aslw #2,%d2	| 408E39E2
rsrc_DRVR_10__ATP_354:  /* loop: lea */
    lea %a2@(202),%a3
    addaw %d2,%a3
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    movel %a3@,%d0
    jbeq rsrc_DRVR_10__ATP_378
    moveal %d0,%a0
    movel %a0@,%a3@
    movew %sp@+,%sr
    movew #-1105,%d0
    jbsr rsrc_DRVR_10__ATP_96E
    jbra rsrc_DRVR_10__ATP_354
rsrc_DRVR_10__ATP_378:  /* set %sr */
    movew %sp@+,%sr
    jbra ATP_CloseATPSkt_2E
rsrc_DRVR_10__ATP_37E:  /* set %d0 */
    movew #-1102,%d0	| 408E3A0E
    jbra ATP_CloseATPSkt_30	| 408E3A12

/* Control csCode 252: SendResponse. */
ATP_SendResponse:
    moveal %a0@(40),%a1	| 408E3A16
    swap %d1	| 408E3A1A
    movew #-1100,%d0	| 408E3A1C
    moveb %a0@(44),%d1	| 408E3A20
    jbeq rsrc_DRVR_10__ATP_3E4	| 408E3A24
    cmpib #8,%d1	| 408E3A26
    jbhi rsrc_DRVR_10__ATP_426	| 408E3A2A
    jbsr rsrc_DRVR_10__ATP_F88	| 408E3A2E
    jbne rsrc_DRVR_10__ATP_426	| 408E3A32
    st %a3@(97)	| 408E3A36
rsrc_DRVR_10__ATP_3AA:  /* loop: lea */
    lea %a3@(96),%a3
    moveq #-128,%d0
    subqb #1,%d1
    jbne rsrc_DRVR_10__ATP_3B8
    orb %a0@(29),%d0
rsrc_DRVR_10__ATP_3B8:  /* set %a3@+ */
    moveb %d0,%a3@+
    addqb #1,%a3@+
    movew %a0@(46),%a3@+
    movew %a1@+,%d0
    movel %a1@+,%d2
    movew #-1,%a1@+
    movel %a1@+,%a3@+
    lea %a3@(-104),%a3
    swap %d1
    jbsr rsrc_DRVR_10__ATP_704
    cmpiw #-92,%d0
    jbeq rsrc_DRVR_10__ATP_422
    swap %d1
    tstb %d1
    jbne rsrc_DRVR_10__ATP_3AA
    jbsr rsrc_DRVR_10__ATP_FC4
rsrc_DRVR_10__ATP_3E4:  /* from here: swap %d1 */
    swap %d1
    moveb %a0@(45),%d2
    subb %a0@(44),%d2
    jbeq rsrc_DRVR_10__ATP_3FC
rsrc_DRVR_10__ATP_3F0:  /* loop: clr */
    clrw %a1@(6)
    lea %a1@(12),%a1
    subqb #1,%d2
    jbne rsrc_DRVR_10__ATP_3F0
rsrc_DRVR_10__ATP_3FC:  /* set %d0 */
    movew %a0@(46),%d0
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    jbsr rsrc_DRVR_10__ATP_42A
    jbne rsrc_DRVR_10__ATP_4FA
    movel %a0,%a1@(8)
    clrb %a1@(1)
    moveb %a1@(12),%a1@(13)
    jbra rsrc_DRVR_10__ATP_29C_14
rsrc_DRVR_10__ATP_422:  /* call rsrc_DRVR_10__ATP_FC4 */
    jbsr rsrc_DRVR_10__ATP_FC4
rsrc_DRVR_10__ATP_426:  /* continue at ATP_CloseATPSkt_30 */
    jbra ATP_CloseATPSkt_30

/* subroutine (13 instructions): calls rsrc_DRVR_10__ATP_44C (mechanical summary) */
rsrc_DRVR_10__ATP_42A:
    lea %a2@(1714),%a1
    moveq #31,%d2
rsrc_DRVR_10__ATP_42A_6:  /* loop: cmp */
    cmpb %a1@,%d1
    jbne rsrc_DRVR_10__ATP_42A_18
    addqw #2,%a1
    jbsr rsrc_DRVR_10__ATP_44C
    subqw #2,%a1
    jbne rsrc_DRVR_10__ATP_42A_18
    cmpw %a1@(6),%d0
    jbeq rsrc_DRVR_10__ATP_42A_20
rsrc_DRVR_10__ATP_42A_18:  /* address %a1@(14) */
    lea %a1@(14),%a1
    dbf %d2,rsrc_DRVR_10__ATP_42A_6
rsrc_DRVR_10__ATP_42A_20:  /* return */
    rts

/* subroutine (10 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_44C:
    cmpl %a1@,%d3
    jbeq rsrc_DRVR_10__ATP_44C_14
    cmpw %a1@(2),%d3
    jbne rsrc_DRVR_10__ATP_44C_14
    tstw %a1@
    jbeq rsrc_DRVR_10__ATP_44C_14
    movel %d3,%sp@-
    tstw %sp@+
    addqw #2,%sp
rsrc_DRVR_10__ATP_44C_14:  /* return */
    rts

/* Control csCode 251: AddResponse. */
ATP_AddResponse:
    movew #-1100,%d0	| 408E3AF2
    moveb %a0@(44),%d2	| 408E3AF6
    cmpib #8,%d2	| 408E3AFA
    jbcc rsrc_DRVR_10__ATP_426	| 408E3AFE
    jbsr rsrc_DRVR_10__ATP_F88
    jbne rsrc_DRVR_10__ATP_426
    moveq #-92,%d0
    cmpiw #578,%a0@(34)
    jbhi rsrc_DRVR_10__ATP_426
    lea %a3@(96),%a3
    moveq #-128,%d0
    orb %a0@(29),%d0
    moveb %d0,%a3@+
    moveb %d2,%a3@+
    movew %a0@(46),%a3@+
    jbsr rsrc_DRVR_10__ATP_7C6
    jbsr rsrc_DRVR_10__ATP_704
    jbsr rsrc_DRVR_10__ATP_FC4
    movew %a0@(46),%d0
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    jbsr rsrc_DRVR_10__ATP_42A
    jbne rsrc_DRVR_10__ATP_4FA
    moveal %a1@(8),%a3
    movew #-1103,%d0
    movel %a3,%d2
    jbeq rsrc_DRVR_10__ATP_4FC
    moveb %a0@(29),%d2
    orb %d2,%a3@(29)
    clrw %d2
    moveb %a0@(44),%d2
    lea %a3@(44),%a3
    cmpb %a3@,%d2
    jblt rsrc_DRVR_10__ATP_4D8
    moveb %d2,%a3@
    addqb #1,%a3@
rsrc_DRVR_10__ATP_4D8:  /* set %a3 */
    moveal %a3@-,%a3
    muluw #12,%d2
    addaw %d2,%a3
    movew %a0@(34),%a3@+
    movel %a0@(36),%a3@+
    movew #-1,%a3@+
    movel %a0@(18),%a3@
    clrb %a1@(1)
    moveb %a1@(12),%a1@(13)
rsrc_DRVR_10__ATP_4FA:  /* clear %d0 */
    clrw %d0
rsrc_DRVR_10__ATP_4FC:  /* set %sr */
    movew %sp@+,%sr
rsrc_DRVR_10__ATP_4FE:  /* continue at ATP_CloseATPSkt_30 */
    jbra ATP_CloseATPSkt_30

/* Control csCode 255: SendRequest. */
ATP_SendRequest:
    jbsr rsrc_DRVR_10__ATP_668	| 408E3B92
    movew #-1097,%d0	| 408E3B96
    moveq #11,%d2	| 408E3B9A
ATP_SendRequest_A:      /* loop: tst */
    tstb %a2@(4,%d2:w)	| 408E3B9C
    dbeq %d2,ATP_SendRequest_A	| 408E3BA0
    jbne rsrc_DRVR_10__ATP_4FE	| 408E3BA4
    jbsr rsrc_DRVR_10__ATP_5FE
    jbne rsrc_DRVR_10__ATP_4FE
    clrb %d1
    lea %pc@(rsrc_DRVR_10__ATP_C26),%a1
    movel %a1,%a3@(30)
    movew #248,%d0
    jbsr rsrc_DRVR_10__ATP_770
    jbeq rsrc_DRVR_10__ATP_536
    jbsr rsrc_DRVR_10__ATP_FC4
    jbra rsrc_DRVR_10__ATP_4FE
rsrc_DRVR_10__ATP_536:  /* set %d1 */
    moveb %a3@(28),%d1
    jbsr rsrc_DRVR_10__ATP_648
    movel %a0,%a2@(0x10,%d2:w)
    lea %a2@(2166),%a1
    movew %a1@,%a0@(22)
    bset #1,%a0@(29)
    addqw #1,%a1@
    lsrw #2,%d2
    moveb %d1,%a2@(0x4,%d2:w)
    lea %a2@(0x40,%d2:w),%a1
    clrb %a1@
    movel %a1,%sp@-
    jbsr rsrc_DRVR_10__ATP_578
    moveal %sp@+,%a1
    jbsr rsrc_DRVR_10__ATP_7AA
    jbsr rsrc_DRVR_10__ATP_704
    jbsr rsrc_DRVR_10__ATP_FC4
    moveb %a0@(45),%a1@
    moveq #0,%d0
    rts

/* subroutine (4 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_578:
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    jbra rsrc_DRVR_10__ATP_29C_14

/* Control csCode 248: csCode 248 (name not known). */
ATP_cs248:
    jbsr rsrc_DRVR_10__ATP_668
    jbsr rsrc_DRVR_10__ATP_5FE
    jbne ATP_CloseATPSkt_30
    jbsr rsrc_DRVR_10__ATP_648
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
ATP_cs248_18:           /* loop: lea */
    lea %a2@(706),%a1
    addaw %d2,%a1
    movew %a2@(2166),%d3
    moveq #0,%d0
ATP_cs248_24:           /* loop: tst */
    tstl %a1@
    jbeq ATP_cs248_38
    addqw #1,%d0
    moveal %a1@,%a1
    cmpw %a1@(22),%d3
    jbne ATP_cs248_24
    addqw #1,%a2@(2166)
    jbra ATP_cs248_18
ATP_cs248_38:           /* set %sr */
    movew %sp@+,%sr
    cmpw %a2@(3020),%d0
    jbcs ATP_cs248_4C
    jbsr rsrc_DRVR_10__ATP_FC4
    movew #-1097,%d0
    jbra ATP_CloseATPSkt_30
ATP_cs248_4C:           /* set %a0@(22) */
    movew %d3,%a0@(22)
    bset #1,%a0@(29)
    addqw #1,%a2@(2166)
    moveb %a0@(45),%a0@(48)
    lea %a2@(706),%a1
    addaw %d2,%a1
    jbsr rsrc_DRVR_10__ATP_29C
    jbsr rsrc_DRVR_10__ATP_7AA
    jbsr rsrc_DRVR_10__ATP_704
    moveq #0,%d0
    jbra rsrc_DRVR_10__ATP_FC4

/* subroutine (21 instructions): calls rsrc_DRVR_10__ATP_F88; low memory ABusVars (mechanical summary) */
rsrc_DRVR_10__ATP_5FE:
    moveal ABusVars,%a1
    tstw %a1@(832)
    jbpl rsrc_DRVR_10__ATP_5FE_38
    cmpib #6,%a0@(33)
    jbne rsrc_DRVR_10__ATP_5FE_38
    cmpib #0xfe,%a0@(32)
    jbne rsrc_DRVR_10__ATP_5FE_38
    cmpiw #1,%a0@(20)
    jbne rsrc_DRVR_10__ATP_5FE_30
rsrc_DRVR_10__ATP_5FE_22:  /* loop: move */
    movel %a1@(826),%d0
    lsll #8,%d0
    moveb #6,%d0
    movel %d0,%a2@(3022)
rsrc_DRVR_10__ATP_5FE_30:  /* set %a0@(30) */
    movel %a2@(3022),%a0@(30)
    jbeq rsrc_DRVR_10__ATP_5FE_22
rsrc_DRVR_10__ATP_5FE_38:  /* set %d0 */
    moveq #-92,%d0
    cmpiw #578,%a0@(34)
    jbhi rsrc_DRVR_10__ATP_5FE_46
    jbsr rsrc_DRVR_10__ATP_F88
rsrc_DRVR_10__ATP_5FE_46:  /* test %d0 */
    tstw %d0
    rts

/* subroutine (12 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_648:
    lea %a0@(29),%a1
    bclr #4,%a1@
    clrb %a1@-
    moveb %a0@(44),%d0
    jbeq rsrc_DRVR_10__ATP_648_18
    subqb #1,%d0
rsrc_DRVR_10__ATP_648_12:  /* loop: bset */
    bset %d0,%a1@
    subqb #1,%d0
    jbpl rsrc_DRVR_10__ATP_648_12
rsrc_DRVR_10__ATP_648_18:  /* clear %a0@(46) */
    clrb %a0@(46)
    lslw #2,%d2
    rts

/* subroutine (45 instructions): traps BlockMove; low memory ABusVars (mechanical summary) */
rsrc_DRVR_10__ATP_668:
    moveml %a0-%a2,%sp@-
    moveal ABusVars,%a2
    tstw %a2@(832)
    jbpl rsrc_DRVR_10__ATP_668_96
    movel %a2@(1040),%d0
    jbeq rsrc_DRVR_10__ATP_668_20
    moveal %d0,%a1
    movew #6,%d0
    jsr %a1@
    jbne rsrc_DRVR_10__ATP_668_96
rsrc_DRVR_10__ATP_668_20:  /* test #6,%a0@(33) */
    cmpib #6,%a0@(33)
    jbne rsrc_DRVR_10__ATP_668_96
    cmpib #7,%a0@(18)
    jbne rsrc_DRVR_10__ATP_668_96
    movew %a0@(30),%d0
    jbeq rsrc_DRVR_10__ATP_668_42
    cmpw %a2@(836),%d0
    jbcs rsrc_DRVR_10__ATP_668_96
    cmpw %a2@(838),%d0
    jbhi rsrc_DRVR_10__ATP_668_96
rsrc_DRVR_10__ATP_668_42:  /* clear %a0@(28) */
    clrb %a0@(28)
    moveb #16,%a0@(29)
    moveb #1,%a0@(46)
    moveal %a0@(40),%a1
    lea %a2@(854),%a0
    moveq #1,%d0
    addb %a0@,%d0
    tstb %a2@(850)
    jbeq rsrc_DRVR_10__ATP_668_7E
    cmpw %a1@,%d0
    jbgt rsrc_DRVR_10__ATP_668_7E
    movel #1,%a1@(8)
    movew %d0,%a1@(6)
    moveal %a1@(2),%a1
    _BlockMove
    moveq #0,%d0
    jbra rsrc_DRVR_10__ATP_668_8C
rsrc_DRVR_10__ATP_668_7E:  /* clear %a0@(46) */
    clrw %a0@(46)
    moveb #1,%a0@(28)
    movew #-1096,%d0
rsrc_DRVR_10__ATP_668_8C:  /* restore registers */
    moveml %sp@+,%a0-%a2
    addqw #4,%sp
    jbra ATP_CloseATPSkt_34
rsrc_DRVR_10__ATP_668_96:  /* restore registers, return */
    moveml %sp@+,%a0-%a2
    rts

/* subroutine (32 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_704:
    moveml %a0-%a1,%sp@-
    btst #0,%a0@(29)
    sne %a3@(29)
    andib #0xf8,%a3@(96)
    jbmi rsrc_DRVR_10__ATP_704_36
    btst #5,%a0@(29)
    jbeq rsrc_DRVR_10__ATP_704_36
    btst #2,%a0@(29)
    jbeq rsrc_DRVR_10__ATP_704_36
    movew %d0,%sp@-
    moveb %a0@(50),%d0
    andib #7,%d0
    orb %d0,%a3@(96)
    movew %sp@+,%d0
rsrc_DRVR_10__ATP_704_36:  /* address %a3@(58) */
    lea %a3@(58),%a1
    movel %a1,%a3@(30)
    addqw #2,%a1
    lea %a3@(79),%a0
    movel %a0,%a1@+
    moveb #3,%a0@(15)
    addqw #7,%a0
    movel %d3,%a0@+
    movew %d3,%a0@+
    moveb %d3,%a0@
    movew #8,%a1@+
    lea %a3@(96),%a0
    movel %a0,%a1@+
    movew %d0,%a1@+
    movel %d2,%a1@+
    clrw %a1@+
    moveml %sp@+,%a0-%a1
    movew #246,%d0

/* subroutine (16 instructions): traps Control; low memory ABusVars (mechanical summary) */
rsrc_DRVR_10__ATP_770:
    moveml %d1-%d3/%a0-%a1,%a3@(34)
    movel %sp@+,%a3@(54)
    lea %pc@(rsrc_DRVR_10__ATP_770_22),%a0
    movel %a0,%a3@(12)
    moveal %a3,%a0
    moveb %d1,%a0@(28)
    movew %d0,%a0@(26)
    .short  0xA404	| 408E3E1C _Control (flags 0x0400)
    moveq #0,%d0
    rts
rsrc_DRVR_10__ATP_770_22:  /* set %a3 */
    moveal %a0,%a3
    movel %a0@(54),%sp@-
    moveml %a0@(34),%d1-%d3/%a0-%a1
    moveal ABusVars,%a2
    moveal %a2@(30),%a2
    tstw %d0
    rts

/* subroutine (8 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_7AA:
    lea %a3@(96),%a3
    moveq #64,%d0
    orb %a0@(29),%d0
    bclr #4,%d0
    moveb %d0,%a3@+
    moveb %a0@(28),%a3@+
    movew %a0@(22),%a3@+
    movel %a0@(30),%d3

/* subroutine (5 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_7C6:
    movel %a0@(18),%a3@
    movew %a0@(34),%d0
    movel %a0@(36),%d2
    subaw #100,%a3
rsrc_DRVR_10__ATP_7D6:  /* return */
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_7D8:
    movew %d2,%d0
    lslw #2,%d0
    addaw %d0,%a2
    moveal %a2@(706),%a0
    subaw %d0,%a2
    movel %a0,%d0
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_7E8:
    movew #-1096,%d0
    jbra rsrc_DRVR_10__ATP_96E

/* subroutine (4 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_7F0:
    cmpib #0xff,%a0@(47)
    jbeq rsrc_DRVR_10__ATP_7F0_C
    subqb #1,%a0@(47)
rsrc_DRVR_10__ATP_7F0_C:  /* return */
    rts

/* subroutine (127 instructions): traps StripAddress; calls rsrc_DRVR_10__ATP_F88, rsrc_DRVR_10__ATP_7F0, rsrc_DRVR_10__ATP_7AA, rsrc_DRVR_10__ATP_704, rsrc_DRVR_10__ATP_770 ... (mechanical summary) */
rsrc_DRVR_10__ATP_7FE:
    movew %d2,%d0
    lslw #2,%d0
    lea %a2@(706),%a1
    addaw %d0,%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
rsrc_DRVR_10__ATP_7FE_14:  /* set up and call _StripAddress (loop) */
    movel %a1@,%d0
    jbeq rsrc_DRVR_10__ATP_7FE_2C
    subl %a0,%d0
    _StripAddress
    tstl %d0
    jbeq rsrc_DRVR_10__ATP_7FE_24
    moveal %a1@,%a1
    jbra rsrc_DRVR_10__ATP_7FE_14
rsrc_DRVR_10__ATP_7FE_24:  /* set %a1@ */
    movel %a0@,%a1@
rsrc_DRVR_10__ATP_7FE_26:  /* loop: move */
    movew %sp@+,%sr
    tstw %d0
    rts
rsrc_DRVR_10__ATP_7FE_2C:  /* set %d0 */
    movew #-1102,%d0
    jbra rsrc_DRVR_10__ATP_7FE_26
rsrc_DRVR_10__ATP_830:  /* address %a0@(-2168) */
    lea %a0@(-2168),%a2	| 408E3EC0
    movew #6,%a0@(10)	| 408E3EC4
    movel Time,%d0	| 408E3ECA
    cmpl %a2@(2182),%d0	| 408E3ECE
    jbeq rsrc_DRVR_10__ATP_7D6	| 408E3ED2
    bset #7,%a2@(3018)	| 408E3ED4
    jbeq rsrc_DRVR_10__ATP_854	| 408E3EDA
    movew #1,%a0@(10)	| 408E3EDC
    rts	| 408E3EE2
rsrc_DRVR_10__ATP_854:  /* set %a2@(2182) */
    movel %d0,%a2@(2182)	| 408E3EE4
    jbsr rsrc_DRVR_10__ATP_F88	| 408E3EE8
    jbne rsrc_DRVR_10__ATP_920	| 408E3EEC
    moveq #12,%d2	| 408E3EF0
rsrc_DRVR_10__ATP_862:  /* loop: move */
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
rsrc_DRVR_10__ATP_86C:  /* loop: subq */
    subqw #1,%d2
    jbmi rsrc_DRVR_10__ATP_8B8
    moveb %a2@(0x4,%d2:w),%d1
    jbeq rsrc_DRVR_10__ATP_86C
    lea %a2@(0x40,%d2:w),%a1
    tstb %a1@
    jbeq rsrc_DRVR_10__ATP_86C
    subqb #1,%a1@
    jbne rsrc_DRVR_10__ATP_86C
    movew %d2,%d3
    lslw #2,%d3
    moveal %a2@(0x10,%d3:w),%a0
    jbsr rsrc_DRVR_10__ATP_7F0
    jbcs rsrc_DRVR_10__ATP_8A4
    moveb %a0@(45),%a1@
    moveaw %d2,%a1
    jbsr rsrc_DRVR_10__ATP_7AA
    movew %sp@+,%sr
    jbsr rsrc_DRVR_10__ATP_704
    movew %a1,%d2
    jbra rsrc_DRVR_10__ATP_862
rsrc_DRVR_10__ATP_8A4:  /* set %sr */
    movew %sp@+,%sr
    clrb %a2@(0x4,%d2:w)
    movew #247,%d0
    jbsr rsrc_DRVR_10__ATP_770
    jbsr rsrc_DRVR_10__ATP_7E8
    jbra rsrc_DRVR_10__ATP_862
rsrc_DRVR_10__ATP_8B8:  /* set %d2 */
    moveq #126,%d2
rsrc_DRVR_10__ATP_8BA:  /* loop: subq */
    subqw #1,%d2
    jbmi rsrc_DRVR_10__ATP_91A
    moveb %a2@(0x4c,%d2:w),%d1
    jbeq rsrc_DRVR_10__ATP_8BA
    jbsr rsrc_DRVR_10__ATP_7D8
    jbeq rsrc_DRVR_10__ATP_8BA
rsrc_DRVR_10__ATP_8CA:  /* loop: subq */
    subqb #1,%a0@(48)
    moveal %a0@,%a0
    movel %a0,%d0
    jbne rsrc_DRVR_10__ATP_8CA
rsrc_DRVR_10__ATP_8D4:  /* call rsrc_DRVR_10__ATP_7D8 (loop) */
    jbsr rsrc_DRVR_10__ATP_7D8
    jbeq rsrc_DRVR_10__ATP_8BA
rsrc_DRVR_10__ATP_8DA:  /* loop: tst */
    tstb %a0@(48)
    jbeq rsrc_DRVR_10__ATP_8E8
    moveal %a0@,%a0
    movel %a0,%d0
    jbne rsrc_DRVR_10__ATP_8DA
    jbra rsrc_DRVR_10__ATP_8BA
rsrc_DRVR_10__ATP_8E8:  /* call rsrc_DRVR_10__ATP_7F0 */
    jbsr rsrc_DRVR_10__ATP_7F0
    jbcs rsrc_DRVR_10__ATP_90E
    moveb %a0@(45),%a0@(48)
    moveaw %d2,%a1
    jbsr rsrc_DRVR_10__ATP_7AA
    movew %sp@+,%sr
    jbsr rsrc_DRVR_10__ATP_704
    movew %a1,%d2
rsrc_DRVR_10__ATP_902:  /* loop: move */
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    jbra rsrc_DRVR_10__ATP_8D4
rsrc_DRVR_10__ATP_90E:  /* call rsrc_DRVR_10__ATP_7FE */
    jbsr rsrc_DRVR_10__ATP_7FE
    movew %sp@+,%sr
    jbsr rsrc_DRVR_10__ATP_7E8
    jbra rsrc_DRVR_10__ATP_902
rsrc_DRVR_10__ATP_91A:  /* set %sr */
    movew %sp@+,%sr
    jbsr rsrc_DRVR_10__ATP_FC4
rsrc_DRVR_10__ATP_920:  /* set %sp@- */
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    moveq #32,%d2
    lea %a2@(1714),%a3
rsrc_DRVR_10__ATP_930:  /* loop: subq */
    subqw #1,%d2
    jbmi rsrc_DRVR_10__ATP_964
    tstb %a3@+
    jbeq rsrc_DRVR_10__ATP_95E
    subqb #1,%a3@(12)
    jbpl rsrc_DRVR_10__ATP_946
    addqb #1,%a3@
    moveb %a3@(11),%a3@(12)
rsrc_DRVR_10__ATP_946:  /* test #30,%a3@ */
    cmpib #30,%a3@
    jbne rsrc_DRVR_10__ATP_95E
    moveal %a3@(7),%a0
    clrb %a3@(-1)
    movel %a0,%d0
    jbeq rsrc_DRVR_10__ATP_95E
    movew #-1101,%d0
    jbsr rsrc_DRVR_10__ATP_96E
rsrc_DRVR_10__ATP_95E:  /* address %a3@(13) */
    lea %a3@(13),%a3
    jbra rsrc_DRVR_10__ATP_930
rsrc_DRVR_10__ATP_964:  /* set %sr */
    movew %sp@+,%sr
    bclr #7,%a2@(3018)
    rts

/* subroutine (9 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_96E:
    movew %d0,%a0@(16)
    moveml %d1-%d3/%a0-%a3,%sp@-
    movel %a0@(12),%d1
    jbeq rsrc_DRVR_10__ATP_96E_14
    moveal %d1,%a1
    tstw %d0
    jsr %a1@
rsrc_DRVR_10__ATP_96E_14:  /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a0-%a3
    rts

/* Control csCode 258: csCode 258 (name not known). */
ATP_cs258:
    moveal %a0@(44),%a0	| 408E4018
    cmpiw #248,%a0@(26)	| 408E401C
    jbne rsrc_DRVR_10__ATP_9AE	| 408E4022
    moveq #125,%d2	| 408E4024
rsrc_DRVR_10__ATP_996:  /* loop: tst */
    tstb %a2@(0x4c,%d2:w)
    jbeq rsrc_DRVR_10__ATP_9A2
    jbsr rsrc_DRVR_10__ATP_7FE
    jbeq rsrc_DRVR_10__ATP_A18
rsrc_DRVR_10__ATP_9A2:  /* count down */
    dbf %d2,rsrc_DRVR_10__ATP_996
rsrc_DRVR_10__ATP_9A6:  /* loop: move */
    movew #-1102,%d0
    jbra ATP_CloseATPSkt_30
rsrc_DRVR_10__ATP_9AE:  /* set %d2 */
    moveq #11,%d2	| 408E403E
rsrc_DRVR_10__ATP_9B0:  /* loop: tst */
    tstb %a2@(4,%d2:w)	| 408E4040
    jbeq rsrc_DRVR_10__ATP_9C6	| 408E4044
    movew %d2,%d0	| 408E4046
    lslw #2,%d0	| 408E4048
    movel %a2@(0x10,%d0:w),%d0	| 408E404A 408E404A movel %a2@(10,%d0:w),%d0
    subl %a0,%d0	| 408E404E
    _StripAddress	| 408E4050 408E4050 A-line trap
    tstl %d0	| 408E4052
    jbeq rsrc_DRVR_10__ATP_9FC	| 408E4054
rsrc_DRVR_10__ATP_9C6:  /* count down */
    dbf %d2,rsrc_DRVR_10__ATP_9B0	| 408E4056
    jbra rsrc_DRVR_10__ATP_9A6	| 408E405A

/* Control csCode 256: RelTCB. */
ATP_RelTCB:
    movew %a0@(46),%d1	| 408E405C
    moveq #11,%d2	| 408E4060
rsrc_DRVR_10__ATP_9D2:  /* loop: tst */
    tstb %a2@(0x4,%d2:w)
    jbeq rsrc_DRVR_10__ATP_9F0
    movew %d2,%d0
    lslw #2,%d0
    moveal %a2@(0x10,%d0:w),%a0
    cmpw %a0@(22),%d1
    jbne rsrc_DRVR_10__ATP_9F0
    lea %a0@(30),%a1
    jbsr rsrc_DRVR_10__ATP_44C
    jbeq rsrc_DRVR_10__ATP_9FC
rsrc_DRVR_10__ATP_9F0:  /* count down */
    dbf %d2,rsrc_DRVR_10__ATP_9D2
rsrc_DRVR_10__ATP_9F4:  /* loop: move */
    movew #-1102,%d0
    jbra ATP_CloseATPSkt_30
rsrc_DRVR_10__ATP_9FC:  /* call rsrc_DRVR_10__ATP_F88 */
    jbsr rsrc_DRVR_10__ATP_F88
    jbne ATP_CloseATPSkt_30
    moveb %a2@(0x4,%d2:w),%d1
    clrb %a2@(0x4,%d2:w)
    movew #247,%d0
    jbsr rsrc_DRVR_10__ATP_770
    jbsr rsrc_DRVR_10__ATP_FC4
rsrc_DRVR_10__ATP_A18:  /* set %d0 */
    movew #-1105,%d0
    jbsr rsrc_DRVR_10__ATP_96E
rsrc_DRVR_10__ATP_A20:  /* continue at ATP_CloseATPSkt_2E */
    jbra ATP_CloseATPSkt_2E

/* Control csCode 249: RelRspCB. */
ATP_RelRspCB:
    movew %a0@(46),%d0	| 408E40B4
    jbsr rsrc_DRVR_10__ATP_42A
    jbne rsrc_DRVR_10__ATP_9F4
    moveal %a1@(8),%a0
    clrb %a1@
    movel %a0,%d0
    jbeq rsrc_DRVR_10__ATP_A3E
    clrw %d0
    jbsr rsrc_DRVR_10__ATP_96E
rsrc_DRVR_10__ATP_A3E:  /* continue at rsrc_DRVR_10__ATP_A20 */
    jbra rsrc_DRVR_10__ATP_A20
rsrc_DRVR_10__ATP_A40:  /* loop: moveq */
    moveq #5,%d3
    jsr %a4@(2)
    jbsr rsrc_DRVR_10__ATP_F10
    jbne rsrc_DRVR_10__ATP_AA2
    movel %d1,%d3
    movew %a3@(-6),%d0
    moveb %a3@(-10),%d1
    moveal %a2@(30),%a2
    jbsr rsrc_DRVR_10__ATP_42A
    jbne rsrc_DRVR_10__ATP_AA2
    clrb %a1@
    movel %a1@(8),%d0
    jbeq rsrc_DRVR_10__ATP_AA2
    moveal %d0,%a0
    movel %a3@-,%a0@(18)
    clrw %d0
    jbra rsrc_DRVR_10__ATP_96E
rsrc_DRVR_10__ATP_A74:  /* loop: add */
    addb %d3,%d3
    jbpl rsrc_DRVR_10__ATP_BE6
    movew #5,%d3
    jsr %a4@
    jbne rsrc_DRVR_10__ATP_AA2
    addaw %d2,%a5
    moveal %a5@(202),%a5
    movel %a5,%d3
    jbeq rsrc_DRVR_10__ATP_D74_1C
    movew %a5@(34),%d3
    moveal %a5@(36),%a3
    jsr %a4@(2)
    jbsr rsrc_DRVR_10__ATP_F10
    jbeq rsrc_DRVR_10__ATP_D74_4E
rsrc_DRVR_10__ATP_AA2:  /* return */
    rts
rsrc_DRVR_10__ATP_AA4:  /* subtract 4 to %a2 */
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    subqw #4,%a2
    movel %a2,%d2
    moveal ABusVars,%a2
    subl %a2,%d2
    addiw #504,%d2
    moveq #3,%d3
    cmpib #3,%a3@-
    jbne rsrc_DRVR_10__ATP_BE6
    jsr %a4@
    jbne rsrc_DRVR_10__ATP_C24
    moveal %a2@(30),%a5
    moveb %a3@(-3),%d3
    jbpl rsrc_DRVR_10__ATP_BEC
    addb %d3,%d3
    jbmi rsrc_DRVR_10__ATP_BF0
    addaw %d2,%a5
    moveal %a5@(706),%a5
    movel %a5,%d0
    jbeq rsrc_DRVR_10__ATP_BE6
    moveq #3,%d3
    jsr %a4@
    jbne rsrc_DRVR_10__ATP_C24
    movew %a3@(-4),%d0
rsrc_DRVR_10__ATP_BDA:  /* loop: cmp */
    cmpw %a5@(22),%d0
    jbeq rsrc_DRVR_10__ATP_BF4
    moveal %a5@,%a5
    movel %a5,%d3
    jbne rsrc_DRVR_10__ATP_BDA
rsrc_DRVR_10__ATP_BE6:  /* loop: clr */
    clrw %d3
    jmp %a4@(2)
rsrc_DRVR_10__ATP_BEC:  /* continue at rsrc_DRVR_10__ATP_A74 */
    jbra rsrc_DRVR_10__ATP_A74
rsrc_DRVR_10__ATP_BF0:  /* continue at rsrc_DRVR_10__ATP_A40 */
    jbra rsrc_DRVR_10__ATP_A40
rsrc_DRVR_10__ATP_BF4:  /* set %d3 */
    moveq #2,%d3
    jsr %a4@
    jbne rsrc_DRVR_10__ATP_C24
rsrc_DRVR_10__ATP_BFA:  /* loop: move */
    moveb %a3@(-7),%d3
    cmpb %a5@(44),%d3
    jbcc rsrc_DRVR_10__ATP_BE6
    aslw #2,%d3
    movew %d3,%d0
    addw %d0,%d3
    addw %d0,%d3
    moveal %a5@(40),%a3
    addaw %d3,%a3
    movew %a3@+,%d3
    moveal %a3@+,%a3
    movel %a5,%sp@-
    jsr %a4@(2)
    jbsr rsrc_DRVR_10__ATP_F10
    moveal %sp@+,%a0
    jbeq rsrc_DRVR_10__ATP_C6A
rsrc_DRVR_10__ATP_C24:  /* return */
    rts
rsrc_DRVR_10__ATP_C26:  /* set %d3 */
    moveq #8,%d3	| 408E42B6
    cmpib #3,%a3@-	| 408E42B8
    jbne rsrc_DRVR_10__ATP_BE6	| 408E42BC
    jsr %a4@	| 408E42BE
    jbne rsrc_DRVR_10__ATP_C24	| 408E42C0
    moveal %a2@(30),%a5	| 408E42C2
    moveb %a3@(-10),%d0	| 408E42C6
    moveb %a3@(-8),%d2	| 408E42CA
    jbpl rsrc_DRVR_10__ATP_BE6	| 408E42CE
    addb %d2,%d2	| 408E42D0
    jbmi rsrc_DRVR_10__ATP_BE6	| 408E42D2
    moveq #11,%d2	| 408E42D4
    lea %a5@(16),%a5	| 408E42D6
rsrc_DRVR_10__ATP_C4A:  /* loop: cmp */
    cmpb %a5@-,%d0	| 408E42DA
    dbeq %d2,rsrc_DRVR_10__ATP_C4A	| 408E42DC
    jbne rsrc_DRVR_10__ATP_BE6	| 408E42E0
    subaw %d2,%a5	| 408E42E2
    lslw #2,%d2	| 408E42E4
    addaw %d2,%a5	| 408E42E6
    moveal %a5@(12),%a5
    movew %a3@(-6),%d0
    cmpw %a5@(22),%d0
    jbeq rsrc_DRVR_10__ATP_BFA
    jbra rsrc_DRVR_10__ATP_BE6
rsrc_DRVR_10__ATP_C6A:  /* set %a2 */
    moveal %a2@(30),%a2
    lea %a0@(30),%a1
    exg %d1,%d3
    jbsr rsrc_DRVR_10__ATP_44C
    exg %d1,%d3
    jbne rsrc_DRVR_10__ATP_C24
    movel %a3@-,%d1
    movew %a3@-,%d0
    cmpw %a0@(22),%d0
    jbne rsrc_DRVR_10__ATP_C24
    moveb %a3@-,%d0
    cmpib #7,%d0
    jbhi rsrc_DRVR_10__ATP_C24
    extw %d0
    muluw #12,%d0
    moveal %a0@(40),%a1
    addaw %d0,%a1
    movew %a1@,%d0
    addqw #6,%a1
    subw %d3,%d0
    movew %d0,%a1@+
    movel %d1,%a1@+
    lea %a0@(28),%a1
    moveb %a3@,%d3
    swap %d2
    moveb %d3,%d2
    swap %d2
    subqw #1,%a3
    bclr %d3,%a1@
    jbeq rsrc_DRVR_10__ATP_CCE
    addqb #1,%a0@(46)
    moveq #4,%d1
    btst %d1,%a3@
    jbeq rsrc_DRVR_10__ATP_CCE
rsrc_DRVR_10__ATP_CC0:  /* loop: bclr */
    bclr %d3,%a1@
    addqb #1,%d3
    cmpib #8,%d3
    jbne rsrc_DRVR_10__ATP_CC0
    bset %d1,%a0@(29)
rsrc_DRVR_10__ATP_CCE:  /* set %d1 */
    moveb %a3@(-2),%d1
    btst #3,%a3@
    jbeq rsrc_DRVR_10__ATP_CF2
    jbsr rsrc_DRVR_10__ATP_F88
    jbne rsrc_DRVR_10__ATP_CF2
    moveal %d2,%a1
    jbsr rsrc_DRVR_10__ATP_7AA
    jbsr rsrc_DRVR_10__ATP_D74
    jbsr rsrc_DRVR_10__ATP_704
    jbsr rsrc_DRVR_10__ATP_FC4
    movel %a1,%d2
rsrc_DRVR_10__ATP_CF2:  /* test %a0@(28) */
    tstb %a0@(28)
    jbne rsrc_DRVR_10__ATP_D1E
    jbsr rsrc_DRVR_10__ATP_F88
    jbeq rsrc_DRVR_10__ATP_D08
    swap %d2
rsrc_DRVR_10__ATP_D00:  /* from here: bset %d2,%a0@(28) */
    bset %d2,%a0@(28)
    jbra rsrc_DRVR_10__ATP_D74_1A
rsrc_DRVR_10__ATP_D08:  /* set %a3@(98) */
    movew %a0@(22),%a3@(98)
    lsrw #2,%d2
    cmpiw #248,%a0@(26)
    jbne rsrc_DRVR_10__ATP_D38
    jbsr rsrc_DRVR_10__ATP_7FE
    jbra rsrc_DRVR_10__ATP_D3C
rsrc_DRVR_10__ATP_D1E:  /* test #248,%a0@(26) */
    cmpiw #248,%a0@(26)
    jbne rsrc_DRVR_10__ATP_D2E
    moveb %a0@(45),%a0@(48)
    jbra rsrc_DRVR_10__ATP_D74_1A
rsrc_DRVR_10__ATP_D2E:  /* from here: lsrw #2,%d2 */
    lsrw #2,%d2
    moveb %a0@(45),%a2@(0x40,%d2:w)
    jbra rsrc_DRVR_10__ATP_D74_1A
rsrc_DRVR_10__ATP_D38:  /* clear %a2@(0x4,%d2:w) */
    clrb %a2@(0x4,%d2:w)
rsrc_DRVR_10__ATP_D3C:  /* call rsrc_DRVR_10__ATP_D74 */
    jbsr rsrc_DRVR_10__ATP_D74
    btst #5,%a0@(29)
    jbeq rsrc_DRVR_10__ATP_D5A
    movel %a0@(30),%d3
    moveb #0xc0,%a3@(96)
    clrl %a3@(100)
    clrw %d0
    jbsr rsrc_DRVR_10__ATP_704
rsrc_DRVR_10__ATP_D5A:  /* test #248,%a0@(26) */
    cmpiw #248,%a0@(26)
    jbeq rsrc_DRVR_10__ATP_D6A
    movew #247,%d0
    jbsr rsrc_DRVR_10__ATP_770
rsrc_DRVR_10__ATP_D6A:  /* call rsrc_DRVR_10__ATP_FC4 */
    jbsr rsrc_DRVR_10__ATP_FC4
    clrw %d0
    jbra rsrc_DRVR_10__ATP_96E

/* subroutine (140 instructions): calls rsrc_DRVR_10__ATP_F10, rsrc_DRVR_10__ATP_42A, rsrc_DRVR_10__ATP_F88, rsrc_DRVR_10__ATP_D74, rsrc_DRVR_10__ATP_704; low memory ABusVars (mechanical summary) */
rsrc_DRVR_10__ATP_D74:
    movel %a1,%sp@-
    moveal ABusVars,%a1
    movew %sr,%d0
    andiw #-1793,%d0
    eoriw #8192,%d0
    movew %a1@(28),%sp@-
    eorw %d0,%sp@
    movew %sp@+,%sr
    moveal %sp@+,%a1
rsrc_DRVR_10__ATP_D74_1A:  /* return */
    rts
rsrc_DRVR_10__ATP_D74_1C:  /* jump through %a4@(2) */
    jsr %a4@(2)
    jbsr rsrc_DRVR_10__ATP_F10
    jbne rsrc_DRVR_10__ATP_D74_4C
    moveal %a2@(30),%a2
    moveal %a3@-,%a1
    movew %a3@-,%d0
    btst #5,%a3@(-2)
    jbeq rsrc_DRVR_10__ATP_D74_4C
    moveml %d0-%d4/%a1/%a3,%sp@-
    movel %d1,%d3
    moveb %a3@(-4),%d1
    movew %d2,%d4
    jbsr rsrc_DRVR_10__ATP_42A
    jbeq rsrc_DRVR_10__ATP_D74_BE
    moveml %sp@+,%d0-%d4/%a1/%a3
rsrc_DRVR_10__ATP_D74_4C:  /* return */
    rts
rsrc_DRVR_10__ATP_D74_4E:  /* set %a2 */
    moveal %a2@(30),%a2
    moveal %a3@-,%a1
    movew %a3@-,%d0
    btst #5,%a3@(-2)
    jbeq rsrc_DRVR_10__ATP_D74_BA
    moveml %d0-%d4/%a1/%a3,%sp@-
    movel %d1,%d3
    moveb %a3@(-4),%d1
    movew %d2,%d4
    jbsr rsrc_DRVR_10__ATP_42A
    jbeq rsrc_DRVR_10__ATP_D74_BE
    addaw %d4,%a2
    tstl %a2@(202)
    subaw %d4,%a2
    jbeq rsrc_DRVR_10__ATP_D74_B6
    lea %a2@(1714),%a1
    moveq #31,%d2
rsrc_DRVR_10__ATP_D74_80:  /* loop: tst */
    tstb %a1@
    jbeq rsrc_DRVR_10__ATP_D74_92
    lea %a1@(14),%a1
    dbf %d2,rsrc_DRVR_10__ATP_D74_80
    moveml %sp@+,%d0-%d4/%a1/%a3
    rts
rsrc_DRVR_10__ATP_D74_92:  /* set %a1@+ */
    moveb %d1,%a1@+
    clrb %a1@+
    movel %d3,%a1@+
    movew %d0,%a1@+
    clrl %a1@+
    clrw %a1@
    moveb %a3@(-2),%d0
    andib #7,%d0
    cmpib #4,%d0
    jbhi rsrc_DRVR_10__ATP_D74_B6
    moveq #1,%d1
    lslb %d0,%d1
    subqb #1,%d1
    moveb %d1,%a1@+
    moveb %d1,%a1@
rsrc_DRVR_10__ATP_D74_B6:  /* restore registers */
    moveml %sp@+,%d0-%d4/%a1/%a3
rsrc_DRVR_10__ATP_D74_BA:  /* continue at rsrc_DRVR_10__ATP_D74_14E */
    jbra rsrc_DRVR_10__ATP_D74_14E
rsrc_DRVR_10__ATP_D74_BE:  /* set %a0 */
    moveal %a1,%a0
    moveml %sp@+,%d0-%d4/%a1/%a3
    movel %d1,%d3
    moveb %a3@(-4),%d1
    clrb %a0@(1)
    moveb %a0@(12),%a0@(13)
    movel %a0@(8),%d2
    jbeq rsrc_DRVR_10__ATP_D74_14C
    swap %d1
    moveb %a3@-,%d1
    moveal %d2,%a0
    moveal %a0@(40),%a1
    movew %d0,%d2
    jbsr rsrc_DRVR_10__ATP_F88
    jbne rsrc_DRVR_10__ATP_D74_14C
    moveb #0x80,%a3@(96)
    st %a3@(97)
    movew %d2,%a3@(98)
    jbsr rsrc_DRVR_10__ATP_D74
rsrc_DRVR_10__ATP_D74_FE:  /* loop: addq */
    addqb #1,%a3@(97)
    moveb %a3@(97),%d0
    subb %a0@(44),%d0
    jbge rsrc_DRVR_10__ATP_FC4
    addqb #1,%d0
    jbne rsrc_DRVR_10__ATP_D74_11A
    moveb %a0@(29),%d0
    orb %d0,%a3@(96)
rsrc_DRVR_10__ATP_D74_11A:  /* set %d0 */
    movew %a1@+,%d0
    movel %a1@+,%d2
    addqw #2,%a1
    movel %a1@+,%a3@(100)
    lsrw #1,%d1
    jbcc rsrc_DRVR_10__ATP_D74_FE
    tstw %a1@(-6)
    jbeq rsrc_DRVR_10__ATP_D74_FE
    swap %d1
    moveml %d0/%d2/%a1,%sp@-
    movew %a3@(98),%d0
    jbsr rsrc_DRVR_10__ATP_42A
    moveml %sp@+,%d0/%d2/%a1
    jbne rsrc_DRVR_10__ATP_FC4
    jbsr rsrc_DRVR_10__ATP_704
    swap %d1
    jbra rsrc_DRVR_10__ATP_D74_FE
rsrc_DRVR_10__ATP_D74_14C:  /* return */
    rts
rsrc_DRVR_10__ATP_D74_14E:  /* from here: addaw %d2,%a2 */
    addaw %d2,%a2
    movel %a2@(202),%sp@-
    subaw %d2,%a2
    moveal %sp@+,%a0
    jbeq rsrc_DRVR_10__ATP_D74_14C
    movel %a1,%a0@(18)
    moveb %a3@-,%a0@(44)
    movew %d0,%a0@(46)
    lea %a0@(29),%a1
    moveb %a3@-,%a1@+
    movel %d1,%a1@
    lea %a2@(1210),%a3
    addaw %d2,%a3
    cmpmw %a1@+,%a3@+
    jbeq rsrc_DRVR_10__ATP_D74_17E
    tstw %a3@(-2)
    jbne rsrc_DRVR_10__ATP_D74_14C
rsrc_DRVR_10__ATP_D74_17E:  /* set %d0 */
    moveq #2,%d0
rsrc_DRVR_10__ATP_D74_180:  /* loop: cmpm */
    cmpmb %a1@+,%a3@+
    jbeq rsrc_DRVR_10__ATP_D74_18A
    tstb %a3@(-1)
    jbne rsrc_DRVR_10__ATP_D74_14C
rsrc_DRVR_10__ATP_D74_18A:  /* subtract 1 to %d0 */
    subqw #1,%d0
    jbne rsrc_DRVR_10__ATP_D74_180
    subw %d3,%a1@
    addaw %d2,%a2
    movel %a0@,%a2@(202)
    subaw %d2,%a2
    jbra rsrc_DRVR_10__ATP_96E

/* subroutine (43 instructions): calls rsrc_DRVR_10__ATP_F7C (mechanical summary) */
rsrc_DRVR_10__ATP_F10:
    jbne rsrc_DRVR_10__ATP_F10_6A
    moveq #0,%d1
    lea %a2@(2),%a0
    moveb %a2@(7),%d0
    moveb %a0@+,%d1
    subqb #1,%a0@+
    jbeq rsrc_DRVR_10__ATP_F10_60
    moveml %d2-%d4,%sp@-
    movew %a0@+,%d1
    movew %d3,%d4
    jbmi rsrc_DRVR_10__ATP_F10_46
    movew %a0@+,%d4
    jbeq rsrc_DRVR_10__ATP_F10_48
    moveq #8,%d2
    clrw %d3
    jbsr rsrc_DRVR_10__ATP_F7C
    addqw #3,%d3
    rolw #1,%d3
    moveq #8,%d2
    jbsr rsrc_DRVR_10__ATP_F7C
    andiw #1023,%d1
    subiw #21,%d1
    jbeq rsrc_DRVR_10__ATP_F10_40
    moveal %a3,%a0
    subaw %d1,%a0
    movew %d1,%d2
    jbsr rsrc_DRVR_10__ATP_F7C
rsrc_DRVR_10__ATP_F10_40:  /* test %d3 */
    tstw %d3
    jbne rsrc_DRVR_10__ATP_F10_46
    subqw #1,%d3
rsrc_DRVR_10__ATP_F10_46:  /* test %d4,%d3 */
    cmpw %d4,%d3
rsrc_DRVR_10__ATP_F10_48:  /* restore registers */
    moveml %sp@+,%d2-%d4
    jbne rsrc_DRVR_10__ATP_F10_6A
    movel %a2@(10),%d1
    moveb %a2@(13),%d1
    moveb %a2@(15),%d0
    lea %a2@(24),%a3
    jbra rsrc_DRVR_10__ATP_F10_64
rsrc_DRVR_10__ATP_F10_60:  /* address %a2@(16) */
    lea %a2@(16),%a3
rsrc_DRVR_10__ATP_F10_64:  /* from here: lslw #8,%d1 */
    lslw #8,%d1
    moveb %d0,%d1
    clrw %d0
rsrc_DRVR_10__ATP_F10_6A:  /* return */
    rts

/* subroutine (6 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_F7C:
    moveb %a0@+,%d0
    addw %d0,%d3
    rolw #1,%d3
    subqw #1,%d2
    jbne rsrc_DRVR_10__ATP_F7C
    rts

/* subroutine (21 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_F88:
    moveal ABusVars_dce,%a3
    movew %a3@(24),%d0
    lea %a2@(2186),%a3
    movel %d1,%sp@-
    moveq #8,%d1
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
rsrc_DRVR_10__ATP_F88_1A:  /* loop: tst */
    tstw %a3@(24)
    jbeq rsrc_DRVR_10__ATP_F88_34
    lea %a3@(104),%a3
    subqw #1,%d1
    jbne rsrc_DRVR_10__ATP_F88_1A
    movew #-1104,%d0
rsrc_DRVR_10__ATP_F88_2C:  /* loop: move */
    movew %sp@+,%sr
    movel %sp@+,%d1
    tstw %d0
    rts
rsrc_DRVR_10__ATP_F88_34:  /* set %a3@(24) */
    movew %d0,%a3@(24)
    clrw %d0
    jbra rsrc_DRVR_10__ATP_F88_2C

/* subroutine (3 instructions) (mechanical summary) */
rsrc_DRVR_10__ATP_FC4:
    clrw %a3@(24)
    rts
    FILL_408E465A
