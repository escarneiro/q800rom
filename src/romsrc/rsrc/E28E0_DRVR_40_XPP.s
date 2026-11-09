/* ROM resource 'DRVR' 40 ".XPP": map entry at 0x408E28E0, data at 0x408E2910, 3396 bytes

 The .XPP driver ('DRVR' 40, ".XPP DRVR v57.0.4", (c) Apple 1984-1992): the AppleTalk
 Session Protocol (ASP) and the AppleTalk Filing Protocol calls (AFP) used to talk to
 file servers. Control calls (csCodes 246-255) go through XPP_CONTROL_TABLE. Comments
 inferred from the code and the calls documented in Inside Macintosh.
*/

rsrc_DRVR_40__XPP_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408E28E0
    .long   rsrc_INIT_18_entry-rom_start	| 408E28E8
    .long   rsrc_DRVR_40__XPP-rom_start	| 408E28EC
    .ascii  "DRVR"	| 408E28F0
    .byte   0x00, 0x28, 0x58	| 408E28F4
    .byte   4	/* 408E28F7 Pascal string length */
    .ascii  ".XPP"	| 408E28F8
    FILL_408E28FC
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x0D, 0x50, 0x00, 0x00, 0x02, 0xB4	| 408E2904

/* subroutine (0 instructions) (mechanical summary) */
rsrc_DRVR_40__XPP:
    .byte   0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408E2910
rsrc_DRVR_40__XPP_8:    /* (data) */
    .short  rsrc_DRVR_40__XPP_open-rsrc_DRVR_40__XPP	| 408E2918
    .short  rsrc_DRVR_40__XPP_prime-rsrc_DRVR_40__XPP	| 408E291A
    .short  rsrc_DRVR_40__XPP_ctl-rsrc_DRVR_40__XPP	| 408E291C
    .short  rsrc_DRVR_40__XPP_prime-rsrc_DRVR_40__XPP	| 408E291E
    .short  rsrc_DRVR_40__XPP_close-rsrc_DRVR_40__XPP	| 408E2920
    .byte   0x04, 0x2E, 0x58, 0x50, 0x50, 0x00	| 408E2922
rsrc_DRVR_40__XPP_18:   /* (data) */
    .long   0x39048000, 0x00000835	| 408E2928
    .long   0x372E302E, 0x34202000, 0x352E5850, 0x50204452	| 408E2930
    .long   0x56522076, 0x35372E30, 0x2E342020, 0x3B20A920	| 408E2940
    .long   0x4170706C, 0x6520436F, 0x6D707574, 0x65722C20	| 408E2950
    .short  0x496E, 0x632E, 0x2031, 0x3938, 0x342D, 0x3139, 0x3932	| 408E2960

/* Open: needs .MPP and .ATP; sets up the session variables. */
rsrc_DRVR_40__XPP_open:
    moveal ROMBase,%a0
    movew %a0@(8),%d2
    cmpiw #117,%d2
    jbeq rsrc_DRVR_40__XPP_open_2A
    moveal AGBHandle,%a0
    movel %a0,%d1
    addql #1,%d1
    jbne rsrc_DRVR_40__XPP_open_24
    moveq #24,%d0
    .short  0xA722	| 408E2988 _NewHandle (flags 0x0700)
    jbne rsrc_DRVR_40__XPP_open_A4
    movel %a0,AGBHandle
rsrc_DRVR_40__XPP_open_24:  /* set %a2 */
    moveal %a0@,%a2
    tstl %a2@
    jbra rsrc_DRVR_40__XPP_open_2E
rsrc_DRVR_40__XPP_open_2A:  /* set %d0 */
    movel %pc@(rsrc_DRVR_40__XPP_D40),%d0
rsrc_DRVR_40__XPP_open_2E:  /* from here: jbne rsrc_DRVR_40__XPP_open_A2 */
    jbne rsrc_DRVR_40__XPP_open_A2
    moveq #-97,%d0
    moveb PortBUse,%d1
    jbmi rsrc_DRVR_40__XPP_open_A4
    andib #15,%d1
    subqb #1,%d1
    jbne rsrc_DRVR_40__XPP_open_A4
    bset #5,PortBUse
    moveal %a0,%a2
    movel #226,%d0
    .short  0xA71E	| 408E29BC _NewPtr (flags 0x0700)
    jbne rsrc_DRVR_40__XPP_open_A4
    cmpiw #117,%d2
    jbeq rsrc_DRVR_40__XPP_open_5E
    moveal %a2@,%a2
    movel %a0,%a2@
    jbra rsrc_DRVR_40__XPP_open_64
rsrc_DRVR_40__XPP_open_5E:  /* address %pc@(rsrc_DRVR_40__XPP_D40) */
    lea %pc@(rsrc_DRVR_40__XPP_D40),%a2
    movel %a0,%a2@
rsrc_DRVR_40__XPP_open_64:  /* set %a1@(20) */
    movel %a0,%a1@(20)
    moveb %pc@(rsrc_DRVR_40__XPP_18),%a1@(7)
    moveb #20,%d0
    cmpiw #117,%d2
    jbeq rsrc_DRVR_40__XPP_open_7E
    cmpiw #630,%d2
    jbne rsrc_DRVR_40__XPP_open_80
rsrc_DRVR_40__XPP_open_7E:  /* set %d0 */
    moveq #5,%d0
rsrc_DRVR_40__XPP_open_80:  /* set %a0@(6) */
    moveb %d0,%a0@(6)
    movel %a1,%a0@
    lea %pc@(XPP_CloseAll_12),%a2
    movel %a2,%a0@(14)
    moveal ATalkHk2,%a2
    cmpaw #-1,%a2
    jbeq rsrc_DRVR_40__XPP_open_A2
    lea %a0@(8),%a0
    moveq #23,%d0
    jsr %a2@(2)
rsrc_DRVR_40__XPP_open_A2:  /* clear %d0 */
    moveq #0,%d0
rsrc_DRVR_40__XPP_open_A4:  /* return */
    rts

/* Control: dispatch csCode 246-255 through XPP_CONTROL_TABLE. */
rsrc_DRVR_40__XPP_ctl:
    movew %a0@(26),%d2
    subqw #1,%d2
    jbne rsrc_DRVR_40__XPP_ctl_A
    rts
rsrc_DRVR_40__XPP_ctl_A:  /* set %d0 */
    moveq #-17,%d0
    subiw #245,%d2
    jblt XPP_GetParms_32
    cmpiw #9,%d2
    jbgt XPP_GetParms_32
    addw %d2,%d2
    lea %pc@(XPP_CONTROL_TABLE),%a3
    addaw %d2,%a3
    moveaw %a3@,%a3
    lea %pc@(rsrc_DRVR_40__XPP),%a2
    addal %a2,%a3
    jmp %a3@
XPP_CONTROL_TABLE:  /* csCode 246-255, offsets from rsrc_DRVR_40__XPP */
    .short  XPP_cs246-rsrc_DRVR_40__XPP  /* csCode 246 */
    .short  XPP_CloseAll-rsrc_DRVR_40__XPP  /* csCode 247 */
    .short  XPP_AbortOS-rsrc_DRVR_40__XPP  /* csCode 248 */
    .short  XPP_GetParms-rsrc_DRVR_40__XPP  /* csCode 249 */
    .short  XPP_AFPCall-rsrc_DRVR_40__XPP  /* csCode 250 */
    .short  XPP_GetStatus-rsrc_DRVR_40__XPP  /* csCode 251 */
    .short  XPP_UserWrite_UserCommand-rsrc_DRVR_40__XPP  /* csCode 252 */
    .short  XPP_UserWrite_UserCommand-rsrc_DRVR_40__XPP  /* csCode 253 */
    .short  XPP_CloseSess-rsrc_DRVR_40__XPP  /* csCode 254 */
    .short  XPP_OpenSess-rsrc_DRVR_40__XPP  /* csCode 255 */

/* Close: only when no session is open (else closErr); removes its AppleTalk hook. */
rsrc_DRVR_40__XPP_close:
    jbsr rsrc_DRVR_40__XPP_C74
    jbne rsrc_DRVR_40__XPP_close_A
    moveq #-24,%d0
    rts
rsrc_DRVR_40__XPP_close_A:  /* set %a2 */
    moveal ATalkHk2,%a2
    cmpaw #-1,%a2
    jbeq rsrc_DRVR_40__XPP_close_3C
    moveal ROMBase,%a1
    cmpiw #117,%a1@(8)
    jbne rsrc_DRVR_40__XPP_close_26
    moveal %pc@(rsrc_DRVR_40__XPP_D40),%a1
    jbra rsrc_DRVR_40__XPP_close_2E
rsrc_DRVR_40__XPP_close_26:  /* set %a1 */
    moveal AGBHandle,%a1
    moveal %a1@,%a1
    moveal %a1@,%a1
rsrc_DRVR_40__XPP_close_2E:  /* clear %a1@(20) */
    clrl %a1@(20)
    lea %a1@(8),%a0
    moveq #24,%d0
    jsr %a2@(2)
rsrc_DRVR_40__XPP_close_3C:  /* clear bit 5 of PortBUse */
    bclr #5,PortBUse
    moveal ROMBase,%a2
    cmpiw #117,%a2@(8)
    jbeq rsrc_DRVR_40__XPP_close_5A
    moveal AGBHandle,%a2
    moveal %a2@,%a2
    moveal %a2@,%a0
    clrl %a2@
    jbra rsrc_DRVR_40__XPP_close_62
rsrc_DRVR_40__XPP_close_5A:  /* address %pc@(rsrc_DRVR_40__XPP_D40) */
    lea %pc@(rsrc_DRVR_40__XPP_D40),%a2
    moveal %a2@,%a0
    clrl %a2@
rsrc_DRVR_40__XPP_close_62:  /* _DisposPtr */
    _DisposPtr
    moveq #0,%d0
    rts

/* Control csCode 247: CloseAll. */
XPP_CloseAll:
    jbsr rsrc_DRVR_40__XPP_C74
    jbne XPP_GetParms_30
    moveb #5,%a2@(2)
    jbra rsrc_DRVR_40__XPP_504
XPP_CloseAll_12:        /* set %d0 */
    movel %sp@(4),%d0
    cmpil #5,%d0
    jbne XPP_CloseAll_80
    moveal %sp@(12),%a0
    moveml %d4/%a2-%a4,%sp@-
    moveal %a0,%a4
    jbsr rsrc_DRVR_40__XPP_C22
    movel %d0,%d4
    moveal %a1,%a3
XPP_CloseAll_30:        /* loop: movea */
    moveal %a3@(0x12,%d4:w),%a2
    cmpaw #0,%a2
    jbeq XPP_CloseAll_76
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    cmpib #2,%a2@(2)
    jbne XPP_CloseAll_84
    moveq #0,%d0
    movel %a2@(8),%d0
    clrl %sp@-
    movel %a4,%sp@-
    movel %d0,%sp@-
    moveal %a4@(4),%a0
    jsr %a0@
    tstl %sp@+
    jbne XPP_CloseAll_84
    moveb #6,%a2@(2)
    movew %sp@+,%sr
    moveml %d3/%a3,%sp@-
    jbsr rsrc_DRVR_40__XPP_504
    moveml %sp@+,%d3/%a3
XPP_CloseAll_76:        /* loop: subq */
    subqw #4,%d4
    jbpl XPP_CloseAll_30
    moveml %sp@+,%d4/%a2-%a4
    rts
XPP_CloseAll_80:        /* result 0 */
    moveq #0,%d0
    rts
XPP_CloseAll_84:        /* set %sr */
    movew %sp@+,%sr
    jbra XPP_CloseAll_76

/* subroutine (7 instructions) (mechanical summary) */
rsrc_DRVR_40__XPP_236:
    movel %a3,%sp@-
    moveal ABusVars_dce,%a3
    cmpib #4,%a3@(7)
    jbeq rsrc_DRVR_40__XPP_236_14
    cmpib #45,%a3@(7)
rsrc_DRVR_40__XPP_236_14:  /* set %a3 */
    moveal %sp@+,%a3
    rts

/* Control csCode 248: AbortOS. */
XPP_AbortOS:
    moveal %a0@(28),%a2
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    moveal %a2@(130),%a1
    movel %a1,%d0
    jbeq XPP_AbortOS_8C
    cmpib #0xff,%a1@(27)
    jbne XPP_AbortOS_8C
    lea %a2@(66),%a1
    cmpiw #254,%a1@(26)
    jbeq XPP_AbortOS_8C
    jbsr rsrc_DRVR_40__XPP_236
    jbcc XPP_AbortOS_36
    btst #1,%a1@(29)
    jbeq XPP_AbortOS_8C
XPP_AbortOS_36:         /* set %a2@(2) */
    moveb #3,%a2@(2)
    movew %sp@+,%sr
    lea %a2@(16),%a0
    lea %pc@(XPP_GetParms_30),%a3

/* subroutine (7 instructions): calls rsrc_DRVR_40__XPP_236 (mechanical summary) */
XPP_AbortOS_46:
    movew %a1@(22),%a0@(46)
    movel %a1@(30),%a0@(30)
    movew #256,%d0
    jbsr rsrc_DRVR_40__XPP_236
    jbcs XPP_AbortOS_62
    movel %a1,%a0@(44)
    movew #258,%d0

/* subroutine (16 instructions): traps Control (mechanical summary) */
XPP_AbortOS_62:
    movew %d0,%a0@(26)
XPP_AbortOS_66:         /* loop: move */
    movel %a3,%a0@(12)
    movew #-11,%a0@(24)
    .short  0xA404	| 408E2BCE _Control (flags 0x0400)
    jbeq XPP_AbortOS_80
    cmpiw #-28,%d0
    jbeq XPP_AbortOS_82
    cmpiw #-21,%d0
    jbeq XPP_AbortOS_82
XPP_AbortOS_80:         /* return */
    rts
XPP_AbortOS_82:         /* test %a0@(12) */
    tstl %a0@(12)
    jbeq XPP_AbortOS_80
    tstw %d0
    jmp %a3@
XPP_AbortOS_8C:         /* set %sr */
    movew %sp@+,%sr
    movew #-1102,%d0
    jbra XPP_GetParms_32

/* Control csCode 249: GetParms. */
XPP_GetParms:
    movew #578,%a0@(28)
    movew #4624,%a0@(30)
    moveal ROMBase,%a1
    cmpiw #117,%a1@(8)
    jbne XPP_GetParms_1E
    moveal %pc@(rsrc_DRVR_40__XPP_D40),%a1
    jbra XPP_GetParms_26
XPP_GetParms_1E:        /* set %a1 */
    moveal AGBHandle,%a1
    moveal %a1@,%a1
    moveal %a1@,%a1
XPP_GetParms_26:        /* clear %d0 */
    moveq #0,%d0
    moveb %a1@(6),%d0
    movew %d0,%a0@(32)
XPP_GetParms_30:        /* clear %d0 */
    moveq #0,%d0
XPP_GetParms_32:        /* loop: movea */
    moveal ROMBase,%a1
    cmpiw #117,%a1@(8)
    jbne XPP_GetParms_44
    moveal %pc@(rsrc_DRVR_40__XPP_D40),%a1
    jbra XPP_GetParms_4C
XPP_GetParms_44:        /* set %a1 */
    moveal AGBHandle,%a1
    moveal %a1@,%a1
    moveal %a1@,%a1
XPP_GetParms_4C:        /* set %a1 */
    moveal %a1@,%a1
    moveal JIODone,%a0
    jmp %a0@
XPP_GetParms_54:        /* loop: tst */
    tstb %a0@(26)
    jbpl XPP_GetParms_32
    movew #250,%a0@(26)
    jbra XPP_GetParms_32

/* Control csCode 255: OpenSess. */
XPP_OpenSess:
    moveal %a0@(36),%a2
    movel %a0@(32),%d3
    movel %a0@(40),%d2
XPP_OpenSess_C:         /* call rsrc_DRVR_40__XPP_BEA (loop) */
    jbsr rsrc_DRVR_40__XPP_BEA
    jbne XPP_GetParms_54
    moveb #1,%a2@(2)
    movel %d2,%a2@(184)
    movew %d1,%a0@(28)
    movel %d3,%a2@(8)
    moveb %d3,%a2@(7)
    movel %a0,%a2@(130)
    jbsr rsrc_DRVR_40__XPP_7C6
    lea %a2@(66),%a0
    movew #254,%d0
    lea %pc@(rsrc_DRVR_40__XPP_384),%a3
    jbra XPP_AbortOS_62
rsrc_DRVR_40__XPP_384:  /* address %a0@(-66) */
    lea %a0@(-66),%a2	| 408E2C94
    jbmi rsrc_DRVR_40__XPP_41E	| 408E2C98
    moveb %a0@(28),%a2@(6)	| 408E2C9C
    lea %a0@(28),%a3	| 408E2CA2
    movew #32,%a3@+	| 408E2CA6
    movel %a2@(8),%a3@+	| 408E2CAA
    clrw %a3@+	| 408E2CAE
    clrl %a3@+	| 408E2CB0
    lea %a2@(134),%a1	| 408E2CB2
    movel %a1,%a3@+	| 408E2CB6
    moveb #1,%a3@+	| 408E2CB8
    moveal %a2@(130),%a1	| 408E2CBC
    moveb %a1@(30),%a3@	| 408E2CC0
    addqw #2,%a3	| 408E2CC4
    moveb %a1@(31),%a3@+	| 408E2CC6
    lea %a0@(18),%a1	| 408E2CCA
    moveb #4,%a1@+	| 408E2CCE
    moveb %a2@(6),%a1@+	| 408E2CD2
    movew #256,%a1@+	| 408E2CD6
    lea %pc@(rsrc_DRVR_40__XPP_3D6),%a3	| 408E2CDA
    movew #255,%d0	| 408E2CDE
    jbra XPP_AbortOS_62	| 408E2CE2
rsrc_DRVR_40__XPP_3D6:  /* address %a0@(-66) */
    lea %a0@(-66),%a2	| 408E2CE6
    jbmi rsrc_DRVR_40__XPP_3F6	| 408E2CEA
    movew #-1105,%d0	| 408E2CEC
    cmpib #3,%a2@(2)	| 408E2CF0
    jbeq rsrc_DRVR_40__XPP_3F6	| 408E2CF6
    lea %a2@(146),%a1	| 408E2CF8
    movew %a1@-,%d0	| 408E2CFC
    jbeq rsrc_DRVR_40__XPP_428	| 408E2CFE
    jbmi rsrc_DRVR_40__XPP_3F6	| 408E2D00
    movew #-1070,%d0	| 408E2D02
rsrc_DRVR_40__XPP_3F6:  /* test #-1096,%d0 */
    cmpiw #-1096,%d0	| 408E2D06
    jbne rsrc_DRVR_40__XPP_400	| 408E2D0A
    movew #-1069,%d0	| 408E2D0C
rsrc_DRVR_40__XPP_400:  /* set %a0@(28) */
    moveb %a2@(6),%a0@(28)	| 408E2D10
    movew %d0,%a2@(134)	| 408E2D16
    movew #250,%d0	| 408E2D1A
    lea %pc@(rsrc_DRVR_40__XPP_416),%a3	| 408E2D1E
    jbra XPP_AbortOS_62	| 408E2D22
rsrc_DRVR_40__XPP_416:  /* address %a0@(-66) */
    lea %a0@(-66),%a2	| 408E2D26
    movew %a2@(134),%d0	| 408E2D2A
rsrc_DRVR_40__XPP_41E:  /* set %d1 */
    movew %d0,%d1	| 408E2D2E
    jbsr rsrc_DRVR_40__XPP_C48	| 408E2D30
    movew %d1,%d0	| 408E2D34
    jbra rsrc_DRVR_40__XPP_4A6	| 408E2D36
rsrc_DRVR_40__XPP_428:  /* set %a2@(3) */
    moveb %a1@-,%a2@(3)	| 408E2D38
    movel %a2@(8),%d3	| 408E2D3C
    moveb %a1@-,%a2@(11)	| 408E2D40
    moveb %a2@(6),%a0@(28)	| 408E2D44
    lea %a2@(14),%a3	| 408E2D4A
    movel %a3,%a0@(36)	| 408E2D4E
    jbsr XPP_AFPCall_222	| 408E2D52
    lea %a2@(16),%a0	| 408E2D56
    lea %a0@(28),%a3	| 408E2D5A
    moveb %a2@(6),%a3@+	| 408E2D5E
    clrb %a3@+	| 408E2D62
    movel %d3,%a3@+	| 408E2D64
    clrw %a3@+	| 408E2D66
    clrl %a3@+	| 408E2D68
    clrl %a3@+	| 408E2D6A
    movew #30,%a3@+	| 408E2D6C
    movew #-1,%a3@+	| 408E2D70
    lea %a0@(18),%a3	| 408E2D74
    moveb #5,%a3@+	| 408E2D78
    moveb %a2@(3),%a3@+	| 408E2D7C
    clrw %a3@+	| 408E2D80
    movew #255,%d0	| 408E2D82
    jbsr rsrc_DRVR_40__XPP_236	| 408E2D86
    jbcs rsrc_DRVR_40__XPP_480	| 408E2D8A
    movew #248,%d0	| 408E2D8C
rsrc_DRVR_40__XPP_480:  /* from here: subal %a3,%a3 */
    subal %a3,%a3	| 408E2D90
    jbsr XPP_AbortOS_62	| 408E2D92
    lea %a2@(120),%a0	| 408E2D96
    movew #1,%a0@+	| 408E2D9A
    lea %pc@(XPP_AFPCall_1DE),%a3	| 408E2D9E
    movel %a3,%a0@+	| 408E2DA2
    movew #7200,%a0@	| 408E2DA4
    lea %a2@(116),%a0	| 408E2DA8
    _VInstall	| 408E2DAC 408E2DAC A-line trap
    moveq #0,%d0	| 408E2DAE
    moveb #2,%a2@(2)	| 408E2DB0
rsrc_DRVR_40__XPP_4A6:  /* set %a0 */
    moveal %a2@(130),%a0	| 408E2DB6

/* subroutine (23 instructions) (mechanical summary) */
rsrc_DRVR_40__XPP_4AA:
    movel %a1,%sp@-	| 408E2DBA
    movew %sr,%sp@-	| 408E2DBC
    oriw #1792,%sr	| 408E2DBE
    andiw #-257,%sr	| 408E2DC2
    lea %a2@(130),%a1	| 408E2DC6
rsrc_DRVR_40__XPP_4BA:  /* loop: cmpa */
    cmpal %a1@,%a0	| 408E2DCA
    jbeq rsrc_DRVR_40__XPP_4C2	| 408E2DCC
    moveal %a1@,%a1	| 408E2DCE
    jbra rsrc_DRVR_40__XPP_4BA	| 408E2DD0
rsrc_DRVR_40__XPP_4C2:  /* set %a1@ */
    movel %a0@,%a1@	| 408E2DD2
    movew %sp@+,%sr	| 408E2DD4
    moveal %sp@+,%a1	| 408E2DD6
rsrc_DRVR_40__XPP_4C8:  /* loop: tst */
    tstw %a0@(26)	| 408E2DD8
    jbmi XPP_AFPCall_70	| 408E2DDC
rsrc_DRVR_40__XPP_4D0:  /* save registers */
    moveml %d1-%d3/%a0-%a3,%sp@-
    movew %d0,%a0@(16)
    movel %a0@(12),%d1
    jbeq rsrc_DRVR_40__XPP_4E4
    moveal %d1,%a1
    tstw %d0
    jsr %a1@
rsrc_DRVR_40__XPP_4E4:  /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a0-%a3
    rts

/* Control csCode 254: CloseSess. */
XPP_CloseSess:
    movew %a0@(28),%d1
    jbsr rsrc_DRVR_40__XPP_BAE
    jbne XPP_GetParms_54
    moveb #5,%a2@(2)
    jbsr rsrc_DRVR_40__XPP_7C6
    jbsr rsrc_DRVR_40__XPP_C5E

/* subroutine (75 instructions): traps VRemove; calls XPP_AFPCall_2E6, rsrc_DRVR_40__XPP_C48 (mechanical summary) */
rsrc_DRVR_40__XPP_504:
    lea %a2@(116),%a0
    _VRemove
rsrc_DRVR_40__XPP_50A:  /* loop: lea */
    lea %pc@(rsrc_DRVR_40__XPP_51A),%a3
    lea %a2@(134),%a0
    lea %a2@(16),%a1
    jbra XPP_AbortOS_46
rsrc_DRVR_40__XPP_51A:  /* address %a0@(-134) */
    lea %a0@(-134),%a2	| 408E2E2A
    moveal %a0,%a1	| 408E2E2E
    lea %a2@(16),%a0	| 408E2E30
    cmpib #6,%a2@(2)	| 408E2E34
    jbeq rsrc_DRVR_40__XPP_566	| 408E2E3A
    lea %a0@(28),%a3	| 408E2E3C
    clrw %a3@+	| 408E2E40
    movel %a2@(8),%a3@+	| 408E2E42
    clrw %a3@+	| 408E2E46
    clrl %a3@+	| 408E2E48
    movel %a1,%a3@+	| 408E2E4A
    clrw %a1@+	| 408E2E4C
    clrl %a1@+	| 408E2E4E
    moveb #1,%a3@+	| 408E2E50
    moveb #1,%a3@+	| 408E2E54
    movew #1,%a3@+	| 408E2E58
    lea %a0@(18),%a3	| 408E2E5C
    moveb #1,%a3@+	| 408E2E60
    moveb %a2@(3),%a3@+	| 408E2E64
    clrw %a3@+	| 408E2E68
    movew #255,%d0	| 408E2E6A
    lea %pc@(rsrc_DRVR_40__XPP_566),%a3	| 408E2E6E
    jbra XPP_AbortOS_62	| 408E2E72
rsrc_DRVR_40__XPP_566:  /* loop: lea */
    lea %a0@(-16),%a2	| 408E2E76
    lea %a2@(130),%a1	| 408E2E7A
rsrc_DRVR_40__XPP_56E:  /* loop: move */
    movel %a1@,%d1	| 408E2E7E
    jbeq rsrc_DRVR_40__XPP_5C2	| 408E2E80
    moveal %d1,%a1	| 408E2E82
    cmpib #0xfe,%a1@(27)	| 408E2E84 408E2E84 cmpib #-2,%a1@(27)
    jbeq rsrc_DRVR_40__XPP_56E	| 408E2E8A
    cmpib #0xfc,%a1@(27)	| 408E2E8C 408E2E8C cmpib #-4,%a1@(27)
    jbne rsrc_DRVR_40__XPP_5B6	| 408E2E92
    movel %a0,%d2	| 408E2E94
    moveal %a1,%a0	| 408E2E96
    moveal %a1,%a3	| 408E2E98
    jbsr XPP_AFPCall_2E6	| 408E2E9A
    exg %a1,%a3	| 408E2E9E
    moveal %d2,%a0	| 408E2EA0
    tstw %a3@(16)	| 408E2EA2
    jble rsrc_DRVR_40__XPP_5B6	| 408E2EA6
    moveb %a3@(28),%a0@(28)	| 408E2EA8
    movel %a3@(30),%a0@(30)	| 408E2EAE
    movew %a3@(46),%a0@(46)	| 408E2EB4
    movew #249,%d0	| 408E2EBA
    lea %pc@(rsrc_DRVR_40__XPP_566),%a3	| 408E2EBE
    jbra XPP_AbortOS_62	| 408E2EC2
rsrc_DRVR_40__XPP_5B6:  /* address %a1@(50) */
    lea %a1@(50),%a1	| 408E2EC6
    lea %pc@(rsrc_DRVR_40__XPP_prime_8),%a3	| 408E2ECA
    jbra XPP_AbortOS_46	| 408E2ECE
rsrc_DRVR_40__XPP_5C2:  /* loop: move */
    moveb %a2@(6),%a0@(28)	| 408E2ED2
    movew #250,%d0	| 408E2ED8
    lea %pc@(rsrc_DRVR_40__XPP_5D4),%a3	| 408E2EDC
    jbra XPP_AbortOS_62	| 408E2EE0
rsrc_DRVR_40__XPP_5D4:  /* address %a0@(-16) */
    lea %a0@(-16),%a2	| 408E2EE4
    moveal %a2@(130),%a0	| 408E2EE8
    moveb %a2@(2),%d2	| 408E2EEC
    movew %a2@(4),%d1	| 408E2EF0
    moveal %a2@(184),%a3	| 408E2EF4
    jbsr rsrc_DRVR_40__XPP_C48	| 408E2EF8
    movel %a3,%d3	| 408E2EFC
    jbeq rsrc_DRVR_40__XPP_5FE	| 408E2EFE
    exg %d0,%d1	| 408E2F00
    moveml %d2/%a0/%a2,%sp@-	| 408E2F02
    jsr %a3@	| 408E2F06
    moveml %sp@+,%d2/%a0/%a2	| 408E2F08
    clrw %d0	| 408E2F0C
rsrc_DRVR_40__XPP_5FE:  /* subtract 6 to %d2 */
    subqb #6,%d2	| 408E2F0E
    jbeq rsrc_DRVR_40__XPP_prime_6	| 408E2F10
    movel %a0,%d1	| 408E2F12
    jbeq XPP_CloseAll	| 408E2F14
    jbra rsrc_DRVR_40__XPP_4C8	| 408E2F18

/* Prime: nothing. */
rsrc_DRVR_40__XPP_prime:
    bclr #7,%a1@(5)
rsrc_DRVR_40__XPP_prime_6:  /* return */
    rts
rsrc_DRVR_40__XPP_prime_8:  /* from here: jbpl rsrc_DRVR_40__XPP_566 */
    jbpl rsrc_DRVR_40__XPP_566	| 408E2F24
    lea %a0@(-16),%a2	| 408E2F28
    lea %a2@(130),%a1	| 408E2F2C
    movel %a1@,%d1	| 408E2F30
    jbeq rsrc_DRVR_40__XPP_5C2	| 408E2F32
    movel %a0,%sp@-	| 408E2F34
    moveal %d1,%a0	| 408E2F36
    movew #-1072,%d0	| 408E2F38
    jbsr rsrc_DRVR_40__XPP_4AA	| 408E2F3C
    moveal %sp@+,%a0	| 408E2F40
    jbra rsrc_DRVR_40__XPP_566	| 408E2F42

/* Control csCode 252, 253: UserWrite / UserCommand. */
XPP_UserWrite_UserCommand:
    clrb %a0@(31)
    lea %a0@(28),%a3
    movew %a3@,%d1
    jbsr rsrc_DRVR_40__XPP_BAE
    jbne XPP_GetParms_54
    addqw #4,%a3
    movew #-1073,%d0
    cmpiw #578,%a3@
    jbhi XPP_GetParms_54
    movew %a2@(12),%d1
    addqw #1,%a2@(12)
    jbsr rsrc_DRVR_40__XPP_7C6
    movew %d1,%d0
    lea %a0@(78),%a1
    moveb %a2@(6),%a1@+
    moveb #32,%a1@+
    movel %a2@(8),%a1@+
    movew %a3@+,%a1@+
    movel %a3@+,%a1@+
    movel %a4,%sp@-
    lea %a0@(100),%a4
    movel %a4,%a1@+
    movew %a3@+,%d3
    movel %a3@+,%d2
    jbsr rsrc_DRVR_40__XPP_78A
    moveq #2,%d2
    cmpib #0xfc,%a0@(27)
    jbne XPP_UserWrite_UserCommand_7C
    movew %a3@,%d3
    movew %d3,%a4@(34)
    clrw %a3@+
    movel %a3@+,%d2
    clrw %a4@(16)
    movel %a0,%a4@(36)
    lea %a4@(50),%a4
    swap %d1
    jbsr rsrc_DRVR_40__XPP_78A
    swap %d1
    moveq #6,%d2
XPP_UserWrite_UserCommand_7C:  /* set %a4 */
    moveal %sp@+,%a4
    moveb %d1,%a1@+
    moveb %a0@(30),%a1@+
    movew #-1,%a1@+
    jbsr rsrc_DRVR_40__XPP_C5E
    lea %a0@(50),%a0
    lea %a0@(18),%a1
    moveb %d2,%a1@+
    moveb %a2@(3),%a1@+
    movew %d0,%a1@+
    lea %pc@(rsrc_DRVR_40__XPP_6E8),%a3
    movew #255,%d0
    jbsr rsrc_DRVR_40__XPP_236
    jbcs XPP_UserWrite_UserCommand_AE
    movew #248,%d0
XPP_UserWrite_UserCommand_AE:  /* continue at XPP_AbortOS_62 */
    jbra XPP_AbortOS_62
rsrc_DRVR_40__XPP_6E8:  /* call rsrc_DRVR_40__XPP_876 (loop) */
    jbsr rsrc_DRVR_40__XPP_876	| 408E2FF8
    movel %a1@(8),%a0@(18)	| 408E2FFC
    movew %a0@(28),%d1	| 408E3002
    movew %d0,%d2	| 408E3006
    jbsr rsrc_DRVR_40__XPP_BAE	| 408E3008
    cmpiw #-1070,%d0	| 408E300C
    jbeq rsrc_DRVR_40__XPP_742	| 408E3010
    movew %d2,%d0	| 408E3012
    cmpiw #-1105,%d0	| 408E3014
    jbne rsrc_DRVR_40__XPP_712	| 408E3018
    movew #-1072,%d0	| 408E301A
rsrc_DRVR_40__XPP_70E:  /* continue at rsrc_DRVR_40__XPP_4AA */
    jbra rsrc_DRVR_40__XPP_4AA	| 408E301E
rsrc_DRVR_40__XPP_712:  /* test #-91,%d0 */
    cmpiw #-91,%d0	| 408E3022
    jbeq rsrc_DRVR_40__XPP_744	| 408E3026
    movew #7200,%a2@(126)	| 408E3028
    cmpib #0xfc,%a0@(27)	| 408E302E 408E302E cmpib #-4,%a0@(27)
    jbne rsrc_DRVR_40__XPP_70E	| 408E3034
    jbsr XPP_AFPCall_2E6	| 408E3036
    movew %sr,%sp@-	| 408E303A
    oriw #1792,%sr	| 408E303C
    andiw #-257,%sr	| 408E3040
    st %a0@(31)	| 408E3044
    tstw %a1@(16)	| 408E3048
    jble XPP_AFPCall_2DC	| 408E304C
    movew %sp@+,%sr	| 408E3050
rsrc_DRVR_40__XPP_742:  /* return */
    rts	| 408E3052
rsrc_DRVR_40__XPP_744:  /* from here: subal %a3,%a3 */
    subal %a3,%a3	| 408E3054
    movel %a0,%d1	| 408E3056
    lea %a2@(134),%a0	| 408E3058
    lea %a2@(16),%a1	| 408E305C
    jbsr XPP_AbortOS_46	| 408E3060
    moveal %d1,%a0	| 408E3064
    lea %a0@(50),%a0	| 408E3066
    lea %pc@(rsrc_DRVR_40__XPP_762),%a3	| 408E306A
    jbra XPP_AbortOS_66	| 408E306E
rsrc_DRVR_40__XPP_762:  /* save registers */
    moveml %d0/%a0,%sp@-	| 408E3072
    cmpiw #-1105,%d0	| 408E3076
    jbeq rsrc_DRVR_40__XPP_782	| 408E307A
    movew %a0@(-22),%d1	| 408E307C
    jbsr rsrc_DRVR_40__XPP_BAE	| 408E3080
    jbne rsrc_DRVR_40__XPP_782	| 408E3084
    lea %a2@(16),%a0	| 408E3086
    tstw %a0@(16)	| 408E308A
    jbgt rsrc_DRVR_40__XPP_782	| 408E308E
    .short  0xA404	| 408E3090 408E3090 A-line trap
rsrc_DRVR_40__XPP_782:
    moveml %sp@+,%d0/%a0	| 408E3092
    jbra rsrc_DRVR_40__XPP_6E8	| 408E3096

/* subroutine (23 instructions) (mechanical summary) */
rsrc_DRVR_40__XPP_78A:
    cmpiw #4624,%d3
    jbls rsrc_DRVR_40__XPP_78A_A
    movew #4624,%d3
rsrc_DRVR_40__XPP_78A_A:  /* from here: extl %d3 */
    extl %d3
    divsw #578,%d3
    movew %d3,%d1
    jbeq rsrc_DRVR_40__XPP_78A_28
rsrc_DRVR_40__XPP_78A_14:  /* loop: move */
    movew #578,%a4@+
    movel %d2,%a4@+
    addqw #2,%a4
    clrl %a4@+
    addil #578,%d2
    subqw #1,%d3
    jbne rsrc_DRVR_40__XPP_78A_14
rsrc_DRVR_40__XPP_78A_28:  /* test #8,%d1 */
    cmpiw #8,%d1
    jbeq rsrc_DRVR_40__XPP_78A_3A
    addqw #1,%d1
    swap %d3
    movew %d3,%a4@+
    movel %d2,%a4@+
    addqw #2,%a4
    clrl %a4@+
rsrc_DRVR_40__XPP_78A_3A:  /* return */
    rts

/* subroutine (30 instructions): calls rsrc_DRVR_40__XPP_ctl; low memory ROMBase, AGBHandle (mechanical summary) */
rsrc_DRVR_40__XPP_7C6:
    moveal ROMBase,%a1
    cmpiw #117,%a1@(8)
    jbne rsrc_DRVR_40__XPP_7C6_12
    moveal %pc@(rsrc_DRVR_40__XPP_D40),%a1
    jbra rsrc_DRVR_40__XPP_7C6_1A
rsrc_DRVR_40__XPP_7C6_12:  /* set %a1 */
    moveal AGBHandle,%a1
    moveal %a1@,%a1
    moveal %a1@,%a1
rsrc_DRVR_40__XPP_7C6_1A:  /* set %a1 */
    moveal %a1@,%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    bclr #7,%a1@(5)
    movel %a0@,%a1@(8)
    jbne rsrc_DRVR_40__XPP_7C6_36
    clrl %a1@(12)
rsrc_DRVR_40__XPP_7C6_36:  /* clear %a0@ */
    clrl %a0@
    movel %a1@(8),%d0
    jbeq rsrc_DRVR_40__XPP_7C6_5A
    bset #7,%a1@(5)
    movew %sp@+,%sr
    moveml %d1-%d3/%a0/%a2-%a3,%sp@-
    moveal %d0,%a0
    moveq #0,%d0
    jbsr rsrc_DRVR_40__XPP_ctl
    moveml %sp@+,%d1-%d3/%a0/%a2-%a3
    moveq #0,%d0
    rts
rsrc_DRVR_40__XPP_7C6_5A:  /* set %sr */
    movew %sp@+,%sr
    rts

/* Control csCode 251: GetStatus. */
XPP_GetStatus:
    lea %a0@(38),%a3
    jbsr rsrc_DRVR_40__XPP_7C6
    lea %a0@(78),%a1
    clrw %a1@+
    movel %a0@(32),%a1@+
    clrw %a1@+
    clrl %a1@+
    movel %a4,%sp@-
    lea %a0@(100),%a4
    movel %a4,%a1@+
    movew %a3@+,%d3
    movel %a3@+,%d2
    jbsr rsrc_DRVR_40__XPP_78A
    moveal %sp@+,%a4
    moveb %d1,%a1@+
    moveb %a0@(30),%a1@
    addqw #2,%a1
    moveb %a0@(31),%a1@+
    lea %a0@(50),%a0
    lea %a0@(18),%a1
    clrl %a1@
    moveb #3,%a1@+
    movew #255,%d0
    lea %pc@(XPP_GetStatus_4C),%a3
    jbra XPP_AbortOS_62
XPP_GetStatus_4C:       /* call rsrc_DRVR_40__XPP_876 */
    jbsr rsrc_DRVR_40__XPP_876
    jbra rsrc_DRVR_40__XPP_4D0

/* subroutine (21 instructions) (mechanical summary) */
rsrc_DRVR_40__XPP_876:
    moveal %a0@(40),%a1
    moveb %a0@(46),%d3
    lea %a0@(-50),%a0
    tstw %d0
    jbne rsrc_DRVR_40__XPP_876_36
    extw %d3
    subqw #1,%d3
    movew %d3,%d2
    muluw #12,%d3
    movew %a1@(0x6,%d3:w),%d1
    cmpw %a1@(0x0,%d3:w),%d1
    jbls rsrc_DRVR_40__XPP_876_2C
    movew #-1067,%d0
    movew %a1@(0x0,%d3:w),%d1
rsrc_DRVR_40__XPP_876_2C:  /* from here: muluw #578,%d2 */
    muluw #578,%d2
    addw %d2,%d1
    movew %d1,%a0@(38)
rsrc_DRVR_40__XPP_876_36:  /* test #-1096,%d0 */
    cmpiw #-1096,%d0
    jbne rsrc_DRVR_40__XPP_876_40
    movew #-1069,%d0
rsrc_DRVR_40__XPP_876_40:  /* return */
    rts

/* Control csCode 250: AFPCall. */
XPP_AFPCall:
    tstw %a0@(32)
    jbne XPP_AFPCall_E
XPP_AFPCall_6:          /* loop: move */
    movew #-5019,%d0
    jbra XPP_GetParms_32
XPP_AFPCall_E:          /* from here: st %a0@(26) */
    st %a0@(26)
    clrl %a0@(8)
XPP_AFPCall_16:         /* loop: movea */
    moveal %a0@(34),%a1
    moveb %a1@,%d1
    jbeq XPP_AFPCall_6
    cmpib #15,%d1
    jbeq XPP_AFPCall_6
    cmpib #0xff,%d1
    jbeq XPP_AFPCall_6
    cmpib #18,%d1
    jbeq XPP_AFPCall_A8
    cmpib #20,%d1
    jbeq XPP_AFPCall_9E
    moveb #0xfc,%a0@(27)
    lea %a0@(44),%a3
    cmpib #33,%d1
    jbeq XPP_AFPCall_5A
    cmpib #0xc0,%d1
    jbcc XPP_AFPCall_6C
    moveb #0xfd,%a0@(27)
    cmpib #27,%d1
    jbne XPP_AFPCall_6C
    subqw #6,%a3
XPP_AFPCall_5A:         /* set %d2 */
    movel %a1@(8),%d2
    cmpil #4624,%d2
    jbls XPP_AFPCall_6A
    movew #4624,%d2
XPP_AFPCall_6A:         /* set %a3@ */
    movew %d2,%a3@
XPP_AFPCall_6C:         /* continue at XPP_UserWrite_UserCommand */
    jbra XPP_UserWrite_UserCommand
XPP_AFPCall_70:         /* set %a1 */
    moveal %a0@(34),%a1	| 408E3238
    moveb %a1@,%d1	| 408E323C
    cmpib #18,%d1	| 408E323E
    jbeq XPP_AFPCall_C8	| 408E3242
    cmpib #19,%d1	| 408E3244
    jbeq XPP_AFPCall_C8	| 408E3248
    lea %a0@(44),%a3	| 408E324A
    cmpib #33,%d1	| 408E324E
    jbeq XPP_AFPCall_F8	| 408E3252
    subqw #6,%a3	| 408E3254
    cmpib #27,%d1	| 408E3256
    jbeq XPP_AFPCall_F8	| 408E325A
XPP_AFPCall_94:         /* loop: move */
    movew #250,%a0@(26)	| 408E325C
    jbra rsrc_DRVR_40__XPP_4D0	| 408E3262
XPP_AFPCall_9E:         /* set %a0@(27) */
    moveb #0xfe,%a0@(27)
    jbra XPP_CloseSess
XPP_AFPCall_A8:         /* test #578,%a0@(32) */
    cmpiw #578,%a0@(32)
    jbhi XPP_GetParms_54
    moveb #0xff,%a0@(27)
    moveal %a0@(48),%a2
    movel %a0@(44),%d3
    movel %a0@(52),%d2
    jbra XPP_OpenSess_C
XPP_AFPCall_C8:         /* test %d0 */
    tstw %d0	| 408E3290
    jbne XPP_AFPCall_94	| 408E3292
    lea %a0@(27),%a1	| 408E3294
    cmpib #0xfd,%a1@	| 408E3298 408E3298 cmpib #-3,%a1@
    jbeq XPP_AFPCall_E4	| 408E329C
    cmpib #0xfe,%a1@	| 408E329E 408E329E cmpib #-2,%a1@
    jbeq XPP_AFPCall_94	| 408E32A2
    moveb #0xfd,%a1@	| 408E32A4 408E32A4 moveb #-3,%a1@
    jbra XPP_UserWrite_UserCommand	| 408E32A8
XPP_AFPCall_E4:         /* set %d1 */
    movel %a0@(18),%d1	| 408E32AC
    jbeq XPP_AFPCall_94	| 408E32B0
    cmpiw #-5001,%d1	| 408E32B2
    jbeq XPP_AFPCall_94	| 408E32B6
    moveb #0xfe,%a1@	| 408E32B8 408E32B8 moveb #-2,%a1@
    jbra XPP_CloseSess	| 408E32BC
XPP_AFPCall_F8:         /* test %d0 */
    tstw %d0	| 408E32C0
    jbne XPP_AFPCall_14A	| 408E32C2
    moveq #0,%d3	| 408E32C4
    movew %a3@+,%d3	| 408E32C6
    addl %d3,%a0@(8)	| 408E32C8
    tstl %a0@(18)	| 408E32CC
    jbne XPP_AFPCall_14A	| 408E32D0
    cmpl %a1@(8),%d3	| 408E32D2
    jbcc XPP_AFPCall_14A	| 408E32D6
    cmpib #27,%d1	| 408E32D8
    jbne XPP_AFPCall_136	| 408E32DC
    tstb %a1@(12)	| 408E32DE
    jbpl XPP_AFPCall_128	| 408E32E2
    moveal %a3@,%a2	| 408E32E4
    moveb %a2@(-1,%d3:w),%d1	| 408E32E6 408E32E6 moveb %a2@(ffffffffffffffff,%d3:w),%d1
    cmpb %a1@(13),%d1	| 408E32EA
    jbeq XPP_AFPCall_14A	| 408E32EE
XPP_AFPCall_128:        /* loop: add */
    addl %d3,%a1@(4)	| 408E32F0
XPP_AFPCall_12C:        /* loop: su */
    subl %d3,%a1@(8)	| 408E32F4
    addl %d3,%a3@	| 408E32F8
    jbra XPP_AFPCall_16	| 408E32FA
XPP_AFPCall_136:        /* clear bit 7 of %a1@(1) */
    bclr #7,%a1@(1)	| 408E32FE
    jbeq XPP_AFPCall_128	| 408E3304
    moveal %a0@(40),%a2	| 408E3306
    movel %a2@,%d1	| 408E330A
    movel %d1,%a1@(4)	| 408E330C
    jbra XPP_AFPCall_12C	| 408E3310
XPP_AFPCall_14A:        /* set %a1@(8) */
    movel %a0@(8),%a1@(8)	| 408E3312
    jbra XPP_AFPCall_94	| 408E3318
XPP_AFPCall_154:        /* set %d0 */
    movew %a0@(16),%d0	| 408E331C
    jbne XPP_AFPCall_1A2	| 408E3320
    movew #2,%a0@(34)	| 408E3322
    lea %a0@(-66),%a2	| 408E3328
    moveb %a0@(19),%d1	| 408E332C
    cmpb %a2@(3),%d1	| 408E3330
    jbne XPP_AFPCall_1A0	| 408E3334
    movew %a0@(30),%d2	| 408E3336
    jbeq XPP_AFPCall_17E	| 408E333A
    movew %a2@(8),%d3	| 408E333C
    jbeq XPP_AFPCall_17E	| 408E3340
    cmpw %d2,%d3	| 408E3342
    jbne XPP_AFPCall_1A0	| 408E3344
XPP_AFPCall_17E:        /* set %d2 */
    moveb %a0@(32),%d2	| 408E3346
    cmpb %a2@(10),%d2	| 408E334A
    jbne XPP_AFPCall_1A0	| 408E334E
    movew #7200,%a2@(126)	| 408E3350
    moveb %a0@(18),%d1	| 408E3356
    subqb #1,%d1	| 408E335A
    jbeq XPP_AFPCall_1A4	| 408E335C
    subqb #6,%d1	| 408E335E
    jbeq XPP_AFPCall_234	| 408E3360
    subqb #1,%d1	| 408E3364
    jbeq XPP_AFPCall_1EC	| 408E3366
XPP_AFPCall_1A0:        /* (408E3368 A-line trap) */
    .short  0xA404	| 408E3368 408E3368 A-line trap
XPP_AFPCall_1A2:
    rts	| 408E336A
XPP_AFPCall_1A4:        /* address %a2@(2) */
    lea %a2@(2),%a1	| 408E336C
    cmpib #5,%a1@	| 408E3370
    jbeq XPP_AFPCall_1A2	| 408E3374
    cmpib #6,%a1@	| 408E3376
    jbeq XPP_AFPCall_1A2	| 408E337A
    moveb #5,%a1@	| 408E337C
    lea %a2@(134),%a1	| 408E3380
    movel %a1,%a0@(40)	| 408E3384
    clrl %a1@+	| 408E3388
    clrl %a1@+	| 408E338A
    clrl %a1@+	| 408E338C
    movew #257,%a0@(44)	| 408E338E
    movew #252,%d0	| 408E3394
    lea %pc@(XPP_AFPCall_1D8),%a3	| 408E3398
    jbra XPP_AbortOS_62	| 408E339C
XPP_AFPCall_1D8:        /* address %a0@(50) */
    lea %a0@(50),%a0	| 408E33A0
    _VRemove	| 408E33A4
XPP_AFPCall_1DE:        /* address %a0@(-116) */
    lea %a0@(-116),%a2	| 408E33A6
    moveb #6,%a2@(2)	| 408E33AA
    jbra rsrc_DRVR_40__XPP_50A	| 408E33B0
XPP_AFPCall_1EC:        /* set %d1 */
    movew %a0@(20),%d1	| 408E33B4
    movew %d1,%a2@	| 408E33B8
    moveal %a2@(184),%a1	| 408E33BA
    clrl %a0@(18)	| 408E33BE
    clrw %a0@(34)	| 408E33C2
    clrb %a0@(29)	| 408E33C6
    clrb %a0@(44)	| 408E33CA
    movew #251,%d0	| 408E33CE
    lea %pc@(XPP_AFPCall_222),%a3	| 408E33D2
    jbsr XPP_AbortOS_62	| 408E33D6
    movel %a1,%d0	| 408E33DA
    jbeq XPP_AFPCall_220	| 408E33DC
    tstw %d1	| 408E33DE
    jbeq XPP_AFPCall_220	| 408E33E0
    movew %a2@(4),%d0	| 408E33E2
    jmp %a1@	| 408E33E6
XPP_AFPCall_220:        /* return */
    rts	| 408E33E8

/* subroutine (59 instructions): traps trap_A404; calls XPP_AFPCall_2E6, XPP_AbortOS_62, rsrc_DRVR_40__XPP_BAE (mechanical summary) */
XPP_AFPCall_222:
    movew #2,%a0@(34)	| 408E33EA
    movew #253,%d0	| 408E33F0
    lea %pc@(XPP_AFPCall_154),%a3	| 408E33F4
    jbra XPP_AbortOS_62	| 408E33F8
XPP_AFPCall_234:        /* set %d1 */
    movew %a0@(20),%d1	| 408E33FC
    movew %a2@(14),%d2	| 408E3400
    moveal %a0,%a3	| 408E3404
    lea %a2@(130),%a0	| 408E3406
XPP_AFPCall_242:        /* loop: move */
    movel %a0@,%d0	| 408E340A
    jbeq XPP_AFPCall_2BC	| 408E340C
    moveal %d0,%a0	| 408E340E
    cmpib #0xfc,%a0@(27)	| 408E3410 408E3410 cmpib #-4,%a0@(27)
    jbne XPP_AFPCall_242	| 408E3416
    cmpw %a0@(70),%d1	| 408E3418
    jbne XPP_AFPCall_242	| 408E341C
    jbsr XPP_AFPCall_2E6	| 408E341E
    movew %a1@(34),%d1	| 408E3422
    cmpw %d1,%d2	| 408E3426
    jbcc XPP_AFPCall_264	| 408E3428
    movew %d2,%d1	| 408E342A
XPP_AFPCall_264:        /* set %a0@(44) */
    movew %d1,%a0@(44)	| 408E342C
    moveal %a1,%a0	| 408E3430
    movel %a3@(30),%a0@(30)	| 408E3432
    movew %a3@(46),%a0@(46)	| 408E3438
    moveb %a2@(6),%a0@(28)	| 408E343E
    lea %a0@(50),%a1	| 408E3444
    subqw #1,%d1	| 408E3448
    extl %d1	| 408E344A
    divsw #578,%d1	| 408E344C
    movew %d1,%d2	| 408E3450
    muluw #12,%d2	| 408E3452
    swap %d1	| 408E3456
    addqw #1,%d1	| 408E3458
    movew %d1,%a1@(0,%d2:w)	| 408E345A
    movel %a1,%a0@(40)	| 408E345E
    swap %d1	| 408E3462
    addqw #1,%d1	| 408E3464
    moveb %d1,%a0@(44)	| 408E3466
    moveb %d1,%a0@(45)	| 408E346A
    moveb #16,%a0@(29)	| 408E346E
    moveal %a3,%a1	| 408E3474
    movew #252,%d0	| 408E3476
    lea %pc@(XPP_AFPCall_2C2),%a3	| 408E347A
    jbsr XPP_AbortOS_62	| 408E347E
    moveal %a1,%a3	| 408E3482
XPP_AFPCall_2BC:        /* set %a0 */
    moveal %a3,%a0	| 408E3484
    .short  0xA404	| 408E3486 408E3486 A-line trap
    rts	| 408E3488
XPP_AFPCall_2C2:        /* set %a0 */
    moveal %a0@(36),%a0	| 408E348A
    movew %sr,%sp@-	| 408E348E
    oriw #1792,%sr	| 408E3490
    andiw #-257,%sr	| 408E3494
    tstb %a0@(31)	| 408E3498
    jbeq XPP_AFPCall_2E2	| 408E349C
    movew %a0@(28),%d1	| 408E349E
    jbsr rsrc_DRVR_40__XPP_BAE	| 408E34A2
XPP_AFPCall_2DC:        /* set %sr */
    movew %sp@+,%sr	| 408E34A4
    jbra rsrc_DRVR_40__XPP_4AA	| 408E34A6
XPP_AFPCall_2E2:        /* set %sr */
    movew %sp@+,%sr	| 408E34AA
    rts	| 408E34AC

/* subroutine (4 instructions) (mechanical summary) */
XPP_AFPCall_2E6:
    moveq #0,%d3	| 408E34AE
    moveb %a0@(94),%d3	| 408E34B0
    muluw #12,%d3	| 408E34B4
    lea %a0@(0x64,%d3:w),%a1	| 408E34B8 408E34B8 lea %a0@(64,%d3:w),%a1
    rts	| 408E34BC

/* subroutine (21 instructions): calls rsrc_DRVR_40__XPP_C22 (mechanical summary) */
rsrc_DRVR_40__XPP_BAE:
    movel %a1,%sp@-
    jbsr rsrc_DRVR_40__XPP_C22
    cmpb %d0,%d1
    jbhi rsrc_DRVR_40__XPP_BAE_36
    moveb %d1,%d0
    andiw #252,%d0
    moveal %a1@(0x12,%d0:w),%a2
    movel %a2,%d0
    jbeq rsrc_DRVR_40__XPP_BAE_36
    cmpw %a2@(4),%d1
    jbne rsrc_DRVR_40__XPP_BAE_36
    cmpib #1,%a2@(2)
    jbeq rsrc_DRVR_40__XPP_BAE_36
    movew #-1072,%d0
    cmpib #2,%a2@(2)
    jbne rsrc_DRVR_40__XPP_BAE_32
    clrw %d0
rsrc_DRVR_40__XPP_BAE_32:  /* loop: movea */
    moveal %sp@+,%a1
    rts
rsrc_DRVR_40__XPP_BAE_36:  /* set %d0 */
    movew #-1070,%d0
    jbra rsrc_DRVR_40__XPP_BAE_32

/* subroutine (22 instructions): calls rsrc_DRVR_40__XPP_C22 (mechanical summary) */
rsrc_DRVR_40__XPP_BEA:
    movel %a1,%sp@-
    jbsr rsrc_DRVR_40__XPP_C22
    moveb %a1@(4),%d1
    addqb #1,%a1@(4)
    aslw #8,%d1
rsrc_DRVR_40__XPP_BEA_E:  /* loop: tst */
    tstl %a1@(0x12,%d0:w)
    jbeq rsrc_DRVR_40__XPP_BEA_1E
    subqw #4,%d0
    jbpl rsrc_DRVR_40__XPP_BEA_E
    movew #-1068,%d0
    jbra rsrc_DRVR_40__XPP_BEA_32
rsrc_DRVR_40__XPP_BEA_1E:  /* set %d0:w) */
    movel %a2,%a1@(0x12,%d0:w)
    moveb %d0,%d1
    moveal %a2,%a1
    moveq #93,%d0
rsrc_DRVR_40__XPP_BEA_28:  /* loop: clr */
    clrw %a1@+
    subqw #1,%d0
    jbne rsrc_DRVR_40__XPP_BEA_28
    movew %d1,%a2@(4)
rsrc_DRVR_40__XPP_BEA_32:  /* set %a1 */
    moveal %sp@+,%a1
    tstw %d0
    rts

/* subroutine (13 instructions): low memory ROMBase, AGBHandle (mechanical summary) */
rsrc_DRVR_40__XPP_C22:
    moveal ROMBase,%a1
    cmpiw #117,%a1@(8)
    jbne rsrc_DRVR_40__XPP_C22_12
    moveal %pc@(rsrc_DRVR_40__XPP_D40),%a1
    jbra rsrc_DRVR_40__XPP_C22_1A
rsrc_DRVR_40__XPP_C22_12:  /* set %a1 */
    moveal AGBHandle,%a1
    moveal %a1@,%a1
    moveal %a1@,%a1
rsrc_DRVR_40__XPP_C22_1A:  /* clear %d0 */
    moveq #0,%d0
    moveb %a1@(6),%d0
    subqw #1,%d0
    aslw #2,%d0
    rts

/* subroutine (7 instructions): calls rsrc_DRVR_40__XPP_C22 (mechanical summary) */
rsrc_DRVR_40__XPP_C48:
    jbsr rsrc_DRVR_40__XPP_C22	| 408E3558
rsrc_DRVR_40__XPP_C4A:  /* (408E355A cmpal %a1@(12,%d0:w),%a2) */
    cmpal %a1@(0x12,%d0:w),%a2	| 408E355A 408E355A cmpal %a1@(12,%d0:w),%a2
    jbeq rsrc_DRVR_40__XPP_C56	| 408E355E
    subqw #4,%d0	| 408E3560
    jbpl rsrc_DRVR_40__XPP_C4A	| 408E3562
    rts	| 408E3564
rsrc_DRVR_40__XPP_C56:  /* (408E3566 clrl %a1@(12,%d0:w)) */
    clrl %a1@(0x12,%d0:w)	| 408E3566 408E3566 clrl %a1@(12,%d0:w)
    moveq #0,%d0	| 408E356A
    rts	| 408E356C

/* subroutine (7 instructions) (mechanical summary) */
rsrc_DRVR_40__XPP_C5E:
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    movel %a2@(130),%a0@
    movel %a0,%a2@(130)
    movew %sp@+,%sr
    rts

/* subroutine (9 instructions): calls rsrc_DRVR_40__XPP_C22 (mechanical summary) */
rsrc_DRVR_40__XPP_C74:
    jbsr rsrc_DRVR_40__XPP_C22
rsrc_DRVR_40__XPP_C74_2:  /* loop: tst */
    tstl %a1@(0x12,%d0:w)
    jbne rsrc_DRVR_40__XPP_C74_E
    subqw #4,%d0
    jbpl rsrc_DRVR_40__XPP_C74_2
    rts
rsrc_DRVR_40__XPP_C74_E:  /* set %a2 */
    moveal %a1@(0x12,%d0:w),%a2
    moveq #0,%d0
    rts

/* Control csCode 246: csCode 246 (name not known). */
XPP_cs246:
    moveal ROMBase,%a2
    cmpiw #117,%a2@(8)
    jbne XPP_cs246_12
    moveal %pc@(rsrc_DRVR_40__XPP_D40),%a2
    jbra XPP_cs246_1A
XPP_cs246_12:           /* set %a2 */
    moveal AGBHandle,%a2
    moveal %a2@,%a2
    moveal %a2@,%a2
XPP_cs246_1A:           /* address %a2@(98) */
    lea %a2@(98),%a2
    movew %a0@(28),%d3
    jbmi XPP_cs246_2A
    cmpiw #31,%d3
    jble XPP_cs246_30
XPP_cs246_2A:           /* result -17 */
    moveq #-17,%d0
    jbra XPP_GetParms_32
XPP_cs246_30:           /* test %a2@ */
    tstl %a2@
    jbne XPP_cs246_42
    movel %a0,%sp@-
    lea %pc@(XPP_cs246_50),%a0
    movel %a0,%a2@
    movel %a0,%a2@(4)
    moveal %sp@+,%a0
XPP_cs246_42:           /* from here: lslw #2,%d3 */
    lslw #2,%d3
    movel %a2@(0x0,%d3:w),%d3
    jbeq XPP_cs246_2A
    movel %d3,%sp@-
    jbra rsrc_DRVR_40__XPP_7C6
XPP_cs246_50:           /* set %d3 */
    movew %a0@(30),%d3
    cmpiw #5,%d3
    jbcs XPP_cs246_9A
    cmpiw #31,%d3
    jbhi XPP_cs246_9A
    moveal ROMBase,%a2
    cmpiw #117,%a2@(8)
    jbne XPP_cs246_72
    moveal %pc@(rsrc_DRVR_40__XPP_D40),%a2
    jbra XPP_cs246_7A
XPP_cs246_72:           /* set %a2 */
    moveal AGBHandle,%a2
    moveal %a2@,%a2
    moveal %a2@,%a2
XPP_cs246_7A:           /* address %a2@(98) */
    lea %a2@(98),%a2
    lslw #2,%d3
    cmpiw #0,%a0@(28)
    jbeq XPP_cs246_8E
    clrl %a2@(0x0,%d3:w)
    jbra XPP_cs246_A2
XPP_cs246_8E:           /* set %d0 */
    movel %a2@(0x0,%d3:w),%d0
    jbne XPP_cs246_9A
    movel %a0@(32),%d0
    jbne XPP_cs246_9E
XPP_cs246_9A:           /* result -1 */
    moveq #-1,%d0
    jbra XPP_cs246_A4
XPP_cs246_9E:           /* set %d3:w) */
    movel %d0,%a2@(0x0,%d3:w)
XPP_cs246_A2:           /* clear %d0 */
    moveq #0,%d0
XPP_cs246_A4:           /* set %a0@(16) */
    movew %d0,%a0@(16)
    movel %a0@(12),%d1
    jbeq XPP_cs246_B4
    moveal %d1,%a1
    tstw %d0
    jsr %a1@
XPP_cs246_B4:           /* return */
    rts
rsrc_DRVR_40__XPP_D40:  /* (data) */
    .long   0x00000000	| 408E3650
    FILL_408E3654
