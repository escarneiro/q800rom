/* ROM resource 'SERD' 0: map entry at 0x4086AB60, data at 0x4086AB90, 6176 bytes

 6502 code for the SCC IOP's asynchronous serial driver, 0 (loaded into the IOP; not
 68000 code).
 Before the data: its entry in the ROM resource map and a Memory Manager block header
 (see rsrc/7EC10_resourcemap.s).

 The serial drivers ('SERD' 0): the standard serial port drivers .AIn, .AOut, .BIn,
 .BOut (asynchronous serial on the SCC's ports A and B), installed by the code at the
 start of the resource (DrvrInstall of each driver header it contains). Comments
 inferred; routines summarised mechanically. (On machines with an SCC I/O processor the
 work is done by the IOP's code, 'SERD' 60 and 61.)
*/

rsrc_SERD_0_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 4086AB60
    .long   rsrc_free_2_Main_entry-rom_start	| 4086AB68
    .long   rsrc_SERD_0-rom_start	| 4086AB6C
    .ascii  "SERD"	| 4086AB70
    .byte   0x00, 0x00, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 4086AB74
    .long   0x00000000, 0xC0A00000, 0x0000182C, 0x000001B4	| 4086AB80

/* Entry: install the four serial drivers (DrvrInstall of the headers in this resource). */
rsrc_SERD_0:            /* the resource data */
    jbra rsrc_SERD_0_C
    .short  0x0000, 0x5345, 0x5244, 0x0000, 0x0006	| 4086AB92

rsrc_SERD_0_C:          /* from here: pea %pc@(rsrc_SERD_0_82) */
    pea %pc@(rsrc_SERD_0_82)
    pea %pc@(rsrc_SERD_0_6A)
    pea %pc@(rsrc_SERD_0_52)
    pea %pc@(rsrc_SERD_0_3A)
    moveq #-6,%d3
rsrc_SERD_0_C_12:       /* set up and call _HLock (loop) */
    movew %d3,%d0
    .short  0xA53D	| 4086ABB0 _DrvrInstall (flags 0x0500)
    _HLock
    moveal %a0@,%a0
    moveal %sp@+,%a1
    movel %a1,%a0@+
    movew %a1@,%a0@+
    movew #6,%a0@
    subqw #1,%d3
    cmpiw #-9,%d3
    jbge rsrc_SERD_0_C_12
    rts

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_3A:         /* from here: chkl %d0,%d6 */
    chkl %d0,%d6	| 4086ABCA
    orib #0,%d0	| 4086ABCC
    orib #96,%d0	| 4086ABD0
    .byte   0x06, 0xDE, 0x04, 0x38, 0x03, 0xE2, 0x03, 0xB8, 0x04, 0x2E, 0x41, 0x49, 0x6E, 0x20	| 4086ABD4

/* subroutine (0 instructions) (mechanical summary) */
rsrc_SERD_0_52:         /* (data) */
    .byte   0x4E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x10, 0x06, 0x0A, 0x04, 0x20, 0x03, 0xCA	| 4086ABE2
    .byte   0x03, 0x2C, 0x05, 0x2E, 0x41, 0x4F, 0x75, 0x74	| 4086ABF2

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_6A:         /* from here: chkl %d0,%d6 */
    chkl %d0,%d6	| 4086ABFA
    orib #0,%d0	| 4086ABFC
    orib #54,%d0	| 4086AC00
    .short  0x06B4, 0x040E, 0x03B8, 0x0388	| 4086AC04 addil #68027320,@(0,%d0:w:2)
    .short  0x042E, 0x4249, 0x6E20	| 4086AC0C subib #73,%fp@(28192)

/* subroutine (5 instructions) (mechanical summary) */
rsrc_SERD_0_82:         /* (data) */
    .byte   0x4E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x10, 0x05, 0xE0, 0x03, 0xF6, 0x03, 0xA0	| 4086AC12
    .byte   0x03, 0x10, 0x05, 0x2E, 0x42, 0x4F, 0x75, 0x74	| 4086AC22
    jmp %pc@(rsrc_SERD_0_9CA)
    .short  0x6004	| 4086AC2E
    jmp %pc@(rsrc_SERD_0_9D8)
    moveb #6,%a1@(7)
    moveq #0,%d0
    rts

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_AE:         /* loop: moveq */
    moveq #4,%d1
    moveq #8,%d2
    jbra rsrc_SERD_0_B4_3C

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_B4:         /* loop: pea */
    pea %pc@(rsrc_SERD_0_B4_A)
    movel 0x6f8,%sp@-
    rts

/* subroutine (20 instructions): calls rsrc_SERD_0_14BA; low memory ATalkHk2 (mechanical summary) */
rsrc_SERD_0_B4_A:       /* set %a0 */
    moveal ATalkHk2,%a0
    movel %a0,%d0
    jble rsrc_SERD_0_B4_38
    movew #19,%d0
    jsr %a0@(2)
    tstw %d0
    jbne rsrc_SERD_0_B4_38
    cmpib #2,%d1
    jbeq rsrc_SERD_0_B4_36
    movew #17,%d0
    moveb #2,%d1
    bsrl rsrc_SERD_0_14BA
    jbeq rsrc_SERD_0_B4_36
    addqw #4,%sp
rsrc_SERD_0_B4_36:      /* return */
    rts
rsrc_SERD_0_B4_38:      /* clear %d1 */
    moveq #0,%d1
    moveq #0,%d2
rsrc_SERD_0_B4_3C:      /* from here: pea %pc@(rsrc_SERD_0_B4_46) */
    pea %pc@(rsrc_SERD_0_B4_46)
    movel 0x6f8,%sp@-
    rts

/* subroutine (20 instructions): calls rsrc_SERD_0_14A6; low memory SPConfig, PortAUse (mechanical summary) */
rsrc_SERD_0_B4_46:      /* set %d0 */
    moveb SPConfig,%d0
    lsrb %d1,%d0
    andib #15,%d0
    jbeq rsrc_SERD_0_B4_5C
    subqb #2,%d0
    jbeq rsrc_SERD_0_B4_5C
    moveq #-98,%d0
rsrc_SERD_0_B4_58:      /* loop: addq */
    addqw #4,%sp
    rts
rsrc_SERD_0_B4_5C:      /* set %d0 */
    movew PortAUse,%d0
    rorw %d2,%d0
    bclr #7,%d0
    jbne rsrc_SERD_0_B4_72
    eorib #2,%d0
    jbeq rsrc_SERD_0_B4_7C
    moveq #-97,%d0
    jbra rsrc_SERD_0_B4_58
rsrc_SERD_0_B4_72:      /* call rsrc_SERD_0_14A6 */
    bsrl rsrc_SERD_0_14A6
    movew %d0,PortAUse
rsrc_SERD_0_B4_7C:      /* return */
    rts

/* subroutine (65 instructions): traps ResrvMem, NewHandle, HLock; calls rsrc_SERD_0_14D2, rsrc_SERD_0_14E8, rsrc_SERD_0_14FE, rsrc_SERD_0_52A; low memory ATalkHk2, PortAUse, SPPortA, ExtStsDT, SPPortB (mechanical summary) */
rsrc_SERD_0_132:        /* loop: tst */
    tstw %d3
    jbne rsrc_SERD_0_132_20
    movel ATalkHk2,%d0
    jble rsrc_SERD_0_132_20
    movel %a0,%sp@-
    moveal %d0,%a0
    movew #18,%d0
    moveb #2,%d1
    jsr %a0@(2)
    moveal %sp@+,%a0
    tstw %d0
    jbeq rsrc_SERD_0_132_2E
rsrc_SERD_0_132_20:     /* set %d0 */
    movew PortAUse,%d0
    rorw %d3,%d0
    st %d0
    rorw %d3,%d0
    movew %d0,PortAUse
rsrc_SERD_0_132_2E:     /* return */
    rts
    jmp %pc@(rsrc_SERD_0_9AE)
    .short  0x45F8, 0x02D0, 0x487A, 0x0676, 0x487A	| 4086ACF6
    .long   0x0766487A, 0x06AC487A, 0x056E4878, 0x01C2487A	| 4086AD00
    .short  0x07BA	| 4086AD10
    pea ExtStsDT_A
    bsrl rsrc_SERD_0_14D2
    movew SPPortA,%d4
    jbra rsrc_SERD_0_132_90
    jmp %pc@(rsrc_SERD_0_9BC)
    .short  0x2478, 0x02B6, 0x45EA, 0x0058, 0x42A7	| 4086AD26
    .long   0x487A072A, 0x487A0670, 0x487A0532, 0x487801B2	| 4086AD30
    .long   0x487A077E	| 4086AD40
    pea ExtStsDT
    bsrl rsrc_SERD_0_14E8
    movew SPPortB,%d4
rsrc_SERD_0_132_90:     /* set %d0 */
    moveq #78,%d0
    addl %d0,%d0
    .short  0xA440	| 4086AD56 _ResrvMem (flags 0x0400)
    moveq #78,%d0
    addl %d0,%d0
    .short  0xA722	| 4086AD5C _NewHandle (flags 0x0700)
    jbeq rsrc_SERD_0_132_A4
    lea %sp@(32),%sp
    rts
rsrc_SERD_0_132_A4:     /* set %a1@(20) */
    movel %a0,%a1@(20)
    moveb #6,%a1@(7)
    movel %a0@,%a2@
    moveal %a0@,%a2
    _HLock
    lea %a2@(124),%a3
    bsrl rsrc_SERD_0_14FE
    moveal %sp@+,%a0
    movel %a0@,%a3@+
    movel %sp@+,%a0@+
    addqw #4,%a0
    movel %a0@,%a3@+
    movel %sp@+,%a0@+
    movel %a0@,%a3@+
    movel %sp@+,%a0@+
    movel %sp@+,%d0
    jbeq rsrc_SERD_0_132_D6
    movel %d0,PollProc
rsrc_SERD_0_132_D6:     /* set %a3 */
    moveal %a2,%a3
    movel %a1,%a3@+
    movew %d1,%a3@+
    jbsr rsrc_SERD_0_52A
    st %a2@(20)
    st %a2@(17)
    moveb %d3,%a2@(32)
    moveb %d2,%a2@(41)
    orib #0x80,%a2@(30)
    jbra rsrc_SERD_0_22E
rsrc_SERD_0_22A:        /* (data) */
    .short  0x1F7F, 0x3FFF	| 4086ADBA
rsrc_SERD_0_22E:        /* loop: pea */
    pea %pc@(rsrc_SERD_0_238)
    movel 0x6f8,%sp@-
    rts

/* subroutine (50 instructions): calls rsrc_SERD_0_318 (mechanical summary) */
rsrc_SERD_0_238:        /* set %d0 */
    movew #-16384,%d0
    andw %d4,%d0
    jbne rsrc_SERD_0_244
    movew #-13302,%d4
rsrc_SERD_0_244:        /* set %d0 */
    movew #3072,%d0
    andw %d4,%d0
    rolw #6,%d0
    moveb %pc@(rsrc_SERD_0_22A,%d0:w),%a2@(119)
    lea %a2@(33),%a3
    lea %pc@(rsrc_SERD_0_2CC),%a4
    moveq #7,%d0
rsrc_SERD_0_25C:        /* loop: move */
    moveb %a4@+,%d1
    movew %d4,%d3
    rolw %d1,%d3
    andb %a4@+,%d3
    orb %a4@+,%d3
    moveb %d3,%a3@+
    dbf %d0,rsrc_SERD_0_25C
    moveq #100,%d1
    andb %a3@+,%d1
    moveb %d1,%a2@(34)
    movew %d4,%a3@
    moveb %a2@(30),%d0
    andib #0x80,%d0
    orb %d0,%a2@(36)
    orb %d0,%a2@(40)
    moveb %a2@(40),%d0
    moveb %d0,%a2@(30)
    bclr #7,%d0
    moveb %d0,%a2@(31)
    moveb %a2@(38),%d0
    lslw #8,%d0
    moveb %a2@(37),%d0
    addqw #2,%d0
    movew #-28672,%d1
    muluw %d1,%d0
    divuw #-28829,%d0
    swap %d0
    movew %d0,%d1
    swap %d0
    cmpiw #18353,%d1
    jble rsrc_SERD_0_2BA
    addqw #1,%d0
rsrc_SERD_0_2BA:        /* subtract 2 to %d0 */
    subqw #2,%d0
    moveb %d0,%a2@(37)
    lsrw #8,%d0
    moveb %d0,%a2@(38)
    jbsr rsrc_SERD_0_318
    moveq #0,%d0
    rts
rsrc_SERD_0_2CC:        /* (data) */
    .long   0x040F4000	| 4086AE5C
    .long   0x00000CC0, 0x000B6002, 0x00FF0008, 0x03000CC0	| 4086AE60
    .long   0x010B600A	| 4086AE70
rsrc_SERD_0_2E4:        /* (data) */
    .long   0x020904FF, 0x01FF03FF, 0x05FF0002	| 4086AE74
    .long   0x000A500B, 0x0CFF0DFF, 0x03FF05FF, 0x010EA00F	| 4086AE80
    .long   0x10001000, 0x01FF0A09	| 4086AE90

/* subroutine (4 instructions): low memory SCCRd (mechanical summary) */
rsrc_SERD_0_308:        /* loop: movem */
    moveml SCCRd,%a0-%a1
    addaw %a2@(4),%a0
    addaw %a2@(4),%a1
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_SERD_0_318:        /* loop: lea */
    lea %pc@(rsrc_SERD_0_2E4),%a3
    moveq #36,%d1

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_31E:        /* loop: pea */
    pea %pc@(rsrc_SERD_0_31E_A)
    movel 0x6f8,%sp@-
    rts

/* subroutine (41 instructions): calls rsrc_SERD_0_308; low memory SCCBSts, SCCASts, PollProc, Lvl2DT, ExtStsDT (mechanical summary) */
rsrc_SERD_0_31E_A:      /* set %sp@- */
    movew %sr,%sp@-
    moveml %a0-%a2,%sp@-
    jbsr rsrc_SERD_0_308
    oriw #1792,%sr
    moveb %a0@,%d2
    lea %a2@(33),%a2
rsrc_SERD_0_31E_1C:     /* loop: move */
    movew %a3@+,%d0
    tstb %d0
    jbpl rsrc_SERD_0_31E_26
    moveb %a2@+,%d0
    rorw #8,%d0
rsrc_SERD_0_31E_26:     /* set %a1@ */
    moveb %d0,%a1@
    rorw #8,%d0
    moveb %d0,%a1@
    subqw #2,%d1
    jbgt rsrc_SERD_0_31E_1C
    moveb %a0@,%d2
    moveml %sp@+,%a0-%a2
    cmpal SerialVars_a,%a2
    jbeq rsrc_SERD_0_31E_42
    moveb %d2,SCCBSts
    jbra rsrc_SERD_0_31E_46
rsrc_SERD_0_31E_42:     /* set SCCASts */
    moveb %d2,SCCASts
rsrc_SERD_0_31E_46:     /* from here: lslb #2,%d2 */
    lslb #2,%d2
    smi %a2@(28)
    movew %sp@+,%sr
    rts
rsrc_SERD_0_36E:        /* (data) */
    .short  0x0209	| 4086AEFE
    .short  0x04FF, 0x01FF, 0x03FF, 0x05FF, 0x080F, 0x0101, 0x0A09	| 4086AF00
    clrl PollProc
    lea Lvl2DT_4,%a4
    lea ExtStsDT_A,%a5
    lea SerialVars_a,%fp
    moveq #8,%d3
    jbra rsrc_SERD_0_3A4
    lea Lvl2DT,%a4
    lea ExtStsDT,%a5
    moveal ExpandMem,%fp
    lea %fp@(88),%fp
    moveq #0,%d3
rsrc_SERD_0_3A4:        /* from here: pea %pc@(rsrc_SERD_0_3AE) */
    pea %pc@(rsrc_SERD_0_3AE)
    movel 0x6f8,%sp@-
    rts

/* subroutine (21 instructions): calls rsrc_SERD_0_3F6, rsrc_SERD_0_31E, rsrc_SERD_0_1524, rsrc_SERD_0_132, rsrc_SERD_0_1540 (mechanical summary) */
rsrc_SERD_0_3AE:        /* set %a2 */
    moveal %fp@,%a2	| 4086AF3E
    tstb %a2@(123)	| 4086AF40
    jbmi rsrc_SERD_0_3C2	| 4086AF44
    bclr #7,%a2@(40)	| 4086AF46
    bclr #7,%a2@(36)	| 4086AF4C
rsrc_SERD_0_3C2:        /* (data) */
    .byte   0x08, 0xAA	| 4086AF52
    orib #40,%d3
    jbsr rsrc_SERD_0_3F6
    lea %pc@(rsrc_SERD_0_36E),%a3
    moveq #16,%d1
    jbsr rsrc_SERD_0_31E
    lea %a2@(124),%a3
    movel %a3@+,%a5@
    movel %a3@+,%a4@+
    addql #4,%a4
    movel %a3@+,%a4@+
    movel %a3@,%a4@
    bsrl rsrc_SERD_0_1524
    jbsr rsrc_SERD_0_132
    bsrl rsrc_SERD_0_1540
    moveq #0,%d0
    rts

/* subroutine (20 instructions): calls rsrc_SERD_0_308 (mechanical summary) */
rsrc_SERD_0_3F6:        /* save registers */
    moveml %d0-%d1/%a0-%a1,%sp@-
    jbsr rsrc_SERD_0_308
    moveq #-1,%d1
rsrc_SERD_0_3F6_A:      /* loop: move */
    movew %sr,%sp@-
    oriw #1792,%sr
    moveb %a0@,%d0
    moveb #1,%a1@
    moveb %a0@,%d0
    movew %sp@+,%sr
    lsrb #1,%d0
    dbcs %d1,rsrc_SERD_0_3F6_A
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts
    moveal SerialVars_a,%a2	| 4086AFAC
    jbra rsrc_SERD_0_42A	| 4086AFB0
    moveal ExpandMem,%a2	| 4086AFB2
    moveal %a2@(88),%a2	| 4086AFB6
rsrc_SERD_0_42A:        /* from here: pea %pc@(rsrc_SERD_0_434) */
    pea %pc@(rsrc_SERD_0_434)	| 4086AFBA
    movel 0x6f8,%sp@-	| 4086AFBE
    rts	| 4086AFC2

/* subroutine (29 instructions): calls rsrc_SERD_0_788, rsrc_SERD_0_798; low memory ExpandMem (mechanical summary) */
rsrc_SERD_0_434:        /* set %sp@- */
    movew %a0@(6),%sp@-	| 4086AFC4
    movel %a1,%sp@-	| 4086AFC8
    movew %sr,%sp@-
    oriw #1792,%sr
    lea %a0@(26),%a0
    moveq #-18,%d0
    movel %a2,%d1
    jble rsrc_SERD_0_4D4
    movew %a0@+,%d1
    subqw #2,%d1
    jbne rsrc_SERD_0_3F6_6A
    jbsr rsrc_SERD_0_788
    jbsr rsrc_SERD_0_798
    clrw %a0@+
    movew %d0,%a0@
    jbra rsrc_SERD_0_4D2
rsrc_SERD_0_3F6_6A:     /* subtract 6 to %d1 */
    subqw #6,%d1
    jbne rsrc_SERD_0_4D4
    movew %a2@(24),%a0@+
    clrb %a2@(24)
    movel %a2@(26),%a0@+
    jbra rsrc_SERD_0_4D2
    moveal SerialVars_a,%a2
    jbra rsrc_SERD_0_3F6_8A
    moveal ExpandMem,%a2
    moveal %a2@(88),%a2
rsrc_SERD_0_3F6_8A:     /* from here: pea %pc@(rsrc_SERD_0_48A) */
    pea %pc@(rsrc_SERD_0_48A)
    movel 0x6f8,%sp@-
    rts

/* subroutine (34 instructions): low memory JIODone (mechanical summary) */
rsrc_SERD_0_48A:        /* set %sp@- */
    movew %a0@(6),%sp@-	| 4086B01A
    movel %a1,%sp@-	| 4086B01E
    movew %sr,%sp@-
    oriw #1792,%sr
    lea %a0@(26),%a0
    movew %a0@+,%d1
    subqw #1,%d1
    jbne rsrc_SERD_0_4B2
    movel %a2,%d2
    jble rsrc_SERD_0_4AC
    clrw %a2@(26)
    clrl %a2@(44)
rsrc_SERD_0_4AC:        /* set %sr */
    movew %sp@+,%sr
    addqw #6,%sp
    rts
rsrc_SERD_0_4B2:        /* set %d2 */
    movel %a2,%d2
    jble rsrc_SERD_0_4E0_8
    lea %pc@(rsrc_SERD_0_4EC),%a1
    subqw #7,%d1
    jbmi rsrc_SERD_0_4E0_8
    cmpiw #19,%d1
    jbhi rsrc_SERD_0_4E0_8
    addw %d1,%d1
    movew %a1@(0x0,%d1:w),%d1
    moveb %a2@(30),%d0
    jsr %a1@(0x0,%d1:w)
rsrc_SERD_0_4D2:        /* clear %d0 */
    moveq #0,%d0
rsrc_SERD_0_4D4:        /* loop: move */
    movew %sp@+,%sr
    moveal %sp@+,%a1
    btst #9,%sp@+
    jbeq rsrc_SERD_0_4E0
    rts

rsrc_SERD_0_4E0:        /* loop: move */
    movel JIODone,%sp@-
    rts

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_4E6:        /* add 4 to %sp */
    addqw #4,%sp	| 4086B076
rsrc_SERD_0_4E0_8:      /* result -17 */
    moveq #-17,%d0
    jbra rsrc_SERD_0_4D4
rsrc_SERD_0_4EC:        /* (data) */
    .short  rsrc_SERD_0_514-rsrc_SERD_0_4EC	| 4086B07C
    .short  rsrc_SERD_0_520-rsrc_SERD_0_4EC	| 4086B07E
    .short  rsrc_SERD_0_546-rsrc_SERD_0_4EC	| 4086B080
    .short  rsrc_SERD_0_594_C-rsrc_SERD_0_4EC	| 4086B082
    .short  rsrc_SERD_0_5A6-rsrc_SERD_0_4EC	| 4086B084
    .short  rsrc_SERD_0_5C6-rsrc_SERD_0_4EC	| 4086B086
    .short  rsrc_SERD_0_540-rsrc_SERD_0_4EC	| 4086B088
    .short  rsrc_SERD_0_4E6-rsrc_SERD_0_4EC	| 4086B08A
    .short  rsrc_SERD_0_580-rsrc_SERD_0_4EC	| 4086B08C
    .short  rsrc_SERD_0_594-rsrc_SERD_0_4EC	| 4086B08E
    .short  rsrc_SERD_0_586-rsrc_SERD_0_4EC	| 4086B090
    .short  rsrc_SERD_0_64C-rsrc_SERD_0_4EC	| 4086B092
    .short  rsrc_SERD_0_646-rsrc_SERD_0_4EC	| 4086B094
    .short  rsrc_SERD_0_612-rsrc_SERD_0_4EC	| 4086B096
    .short  rsrc_SERD_0_6BC_4C-rsrc_SERD_0_4EC	| 4086B098
    .short  rsrc_SERD_0_7BA-rsrc_SERD_0_4EC	| 4086B09A
    .short  rsrc_SERD_0_618-rsrc_SERD_0_4EC	| 4086B09C
    .short  rsrc_SERD_0_7C6_F4-rsrc_SERD_0_4EC	| 4086B09E
    .short  rsrc_SERD_0_62C-rsrc_SERD_0_4EC	| 4086B0A0
    .short  rsrc_SERD_0_63C-rsrc_SERD_0_4EC	| 4086B0A2

/* subroutine (4 instructions) (mechanical summary) */
rsrc_SERD_0_514:        /* set %d4 */
    movew %a0@+,%d4	| 4086B0A4
    cmpw %a2@(42),%d4	| 4086B0A6
    jbeq rsrc_SERD_0_53E	| 4086B0AA
    jbra rsrc_SERD_0_22E	| 4086B0AC

/* subroutine (4 instructions) (mechanical summary) */
rsrc_SERD_0_520:        /* clear %a2@(44) */
    clrl %a2@(44)	| 4086B0B0
    moveal %a0@+,%a4	| 4086B0B4
    movew %a0@,%d1	| 4086B0B6
    jbne rsrc_SERD_0_530	| 4086B0B8

/* subroutine (9 instructions) (mechanical summary) */
rsrc_SERD_0_52A:        /* address %a2@(48) */
    lea %a2@(48),%a4
    moveq #64,%d1
rsrc_SERD_0_530:        /* address %a2@(6) */
    lea %a2@(6),%a3
    movel %a4,%a3@+
    movew %d1,%a3@+
    lsrw #2,%d1
    movew %d1,%a3@+
    movew %d1,%a3@+
rsrc_SERD_0_53E:        /* return */
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_SERD_0_540:        /* set %sp@- */
    moveb %a0@(7),%sp@-	| 4086B0D0
    jbra rsrc_SERD_0_54A	| 4086B0D4

/* subroutine (18 instructions): calls rsrc_SERD_0_7BA, rsrc_SERD_0_70C (mechanical summary) */
rsrc_SERD_0_546:        /* set %sp@- */
    moveb %a2@(23),%sp@-	| 4086B0D6
rsrc_SERD_0_54A:        /* test %a2@(16) */
    tstb %a2@(16)	| 4086B0DA
    jbne rsrc_SERD_0_554	| 4086B0DE
    clrb %a2@(29)	| 4086B0E0
rsrc_SERD_0_554:        /* set %a2@(16) */
    movel %a0@+,%a2@(16)	| 4086B0E4
    movew %a0@+,%a2@(20)	| 4086B0E8
    moveb %a0@+,%d0	| 4086B0EC
    moveb %d0,%a2@(22)	| 4086B0EE
    moveb %d0,%a2@(122)	| 4086B0F2
    jbne rsrc_SERD_0_56C	| 4086B0F6
    jbsr rsrc_SERD_0_7BA
rsrc_SERD_0_56C:        /* call rsrc_SERD_0_70C */
    jbsr rsrc_SERD_0_70C
    moveb %sp@+,%d0
    cmpb %a2@(23),%d0
    jbeq rsrc_SERD_0_52A_54
    moveb %d0,%a2@(23)
    jbeq rsrc_SERD_0_594
rsrc_SERD_0_52A_54:     /* return */
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_SERD_0_580:        /* set %a2@(123) */
    moveb %a0@,%a2@(123)	| 4086B110
    rts	| 4086B114

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_586:        /* loop: bclr */
    bclr #7,%a2@(30)
    bset #6,%a2@(25)
    jbra rsrc_SERD_0_594_C

/* subroutine (2 instructions) (mechanical summary) */
rsrc_SERD_0_594:        /* loop: bset */
    bset #7,%a2@(30)
    bclr #6,%a2@(25)

/* subroutine (2 instructions) (mechanical summary) */
rsrc_SERD_0_594_C:      /* set %d0 */
    moveb %a2@(30),%d0
    jbra rsrc_SERD_0_594_26

/* subroutine (6 instructions): calls rsrc_SERD_0_3F6 (mechanical summary) */
rsrc_SERD_0_5A6:        /* set %sr */
    movew %sp@(4),%sr	| 4086B136
    jbsr rsrc_SERD_0_3F6	| 4086B13A
    oriw #1792,%sr	| 4086B13E
    moveb %a2@(30),%d0	| 4086B142
    bset #4,%d0	| 4086B146
rsrc_SERD_0_594_26:     /* set %d1 */
    moveq #5,%d1

/* subroutine (4 instructions): calls rsrc_SERD_0_6AA (mechanical summary) */
rsrc_SERD_0_5BC:        /* call rsrc_SERD_0_6AA (loop) */
    jbsr rsrc_SERD_0_6AA
    moveb %d1,%a3@
    moveb %d0,%a3@
    rts

/* subroutine (27 instructions): calls rsrc_SERD_0_318 (mechanical summary) */
rsrc_SERD_0_5C6:        /* set %d2 */
    movel #115200,%d2	| 4086B156
    movel %d2,%d3	| 4086B15C
    moveq #0,%d0	| 4086B15E
    movew %a0@,%d0	| 4086B160
    movel %d0,%d1	| 4086B162
    lsrw #1,%d1	| 4086B164
    addl %d1,%d2	| 4086B166
    divuw %d0,%d2	| 4086B168
    movew %d2,%d1	| 4086B16A
    subqw #2,%d2	| 4086B16C
    divuw %d1,%d3	| 4086B16E
    movew %d3,%a0@	| 4086B170
    movew #1023,%d0	| 4086B172
    cmpw %d0,%d2	| 4086B176
    jbls rsrc_SERD_0_5F0	| 4086B178
    clrw %a2@(42)	| 4086B17A
    jbra rsrc_SERD_0_602	| 4086B17E
rsrc_SERD_0_5F0:        /* from here: andw %a2@(42),%d0 */
    andw %a2@(42),%d0	| 4086B180
    cmpw %d0,%d2	| 4086B184
    jbeq rsrc_SERD_0_610	| 4086B186
    andiw #-1024,%a2@(42)	| 4086B188
    orw %d2,%a2@(42)	| 4086B18E
rsrc_SERD_0_602:        /* set %a2@(37) */
    moveb %d2,%a2@(37)	| 4086B192
    lsrw #8,%d2	| 4086B196
    moveb %d2,%a2@(38)	| 4086B198
    jbsr rsrc_SERD_0_318	| 4086B19C
rsrc_SERD_0_610:        /* return */
    rts	| 4086B1A0

/* subroutine (2 instructions) (mechanical summary) */
rsrc_SERD_0_612:        /* from here: st %a2@(29) */
    st %a2@(29)	| 4086B1A2
    rts	| 4086B1A6

/* subroutine (4 instructions) (mechanical summary) */
rsrc_SERD_0_618:        /* clear bit 7 of %a2@(25) */
    bclr #7,%a2@(25)	| 4086B1A8
    moveb %a2@(122),%a2@(22)	| 4086B1AE
    moveb %a2@(18),%d0	| 4086B1B4
rsrc_SERD_0_628:        /* continue at rsrc_SERD_0_7C6_C */
    jbra rsrc_SERD_0_7C6_C	| 4086B1B8

/* subroutine (4 instructions) (mechanical summary) */
rsrc_SERD_0_62C:        /* set bit 7 of %a2@(25) */
    bset #7,%a2@(25)	| 4086B1BC
    clrb %a2@(22)	| 4086B1C2
    moveb %a2@(19),%d0	| 4086B1C6
    jbra rsrc_SERD_0_628	| 4086B1CA

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_63C:        /* set %d0 */
    moveb %a2@(32),%d0	| 4086B1CC
    moveq #9,%d1	| 4086B1D0
    jbra rsrc_SERD_0_5BC	| 4086B1D2

/* subroutine (2 instructions) (mechanical summary) */
rsrc_SERD_0_646:        /* set %a2@(120) */
    movew %a0@,%a2@(120)	| 4086B1D6
    rts	| 4086B1DA

/* subroutine (31 instructions): calls rsrc_SERD_0_6BC, rsrc_SERD_0_6AA; low memory ExpandMem, JFetch (mechanical summary) */
rsrc_SERD_0_64C:        /* set %a2@(120) */
    moveb %a0@,%a2@(120)	| 4086B1DC
    moveb %a0@,%a2@(121)	| 4086B1E0
    bclr #7,%a2@(121)	| 4086B1E4
    rts	| 4086B1EA
    moveal SerialVars_a,%a2	| 4086B1EC
    jbra rsrc_SERD_0_66A	| 4086B1F0
    moveal ExpandMem,%a2
    moveal %a2@(88),%a2
rsrc_SERD_0_66A:        /* set %sp@- */
    movew %sr,%sp@-
    oriw #1792,%sr
    st %a2@(27)
    jbsr rsrc_SERD_0_6BC
    jbne rsrc_SERD_0_678_20

rsrc_SERD_0_678:        /* call rsrc_SERD_0_6AA (loop) */
    jbsr rsrc_SERD_0_6AA
    jbeq rsrc_SERD_0_678_20
    moveb %a2@(118),%d0
    clrb %a2@(118)
    andiw #255,%d0
    jbne rsrc_SERD_0_678_18
    moveal JFetch,%a0
    jsr %a0@
rsrc_SERD_0_678_18:     /* set %a3@(4) */
    moveb %d0,%a3@(4)
    tstw %d0
    jbmi rsrc_SERD_0_678_26
rsrc_SERD_0_678_20:     /* clear %d0 */
    moveq #0,%d0
    movew %sp@+,%sr
    rts
rsrc_SERD_0_678_26:     /* clear %a2@(27) */
    clrb %a2@(27)
    movew %sp@+,%sr
rsrc_SERD_0_678_2C:     /* result 0 */
    moveq #0,%d0
    jbra rsrc_SERD_0_4E0

/* subroutine (6 instructions): low memory SCCRd (mechanical summary) */
rsrc_SERD_0_6AA:        /* loop: movea */
    moveal SCCRd,%a3
    addaw %a2@(4),%a3
    tstb %a3@
    movew %sp@,%sp@
    btst #2,%a3@
    rts

/* subroutine (27 instructions): calls rsrc_SERD_0_6BC; low memory ExpandMem (mechanical summary) */
rsrc_SERD_0_6BC:        /* loop: tst */
    tstb %a2@(16)
    jbeq rsrc_SERD_0_6BC_C
    tstb %a2@(29)
    jbne rsrc_SERD_0_6BC_18
rsrc_SERD_0_6BC_C:      /* test %a2@(17) */
    tstb %a2@(17)
    jbeq rsrc_SERD_0_6BC_1C
    tstb %a2@(28)
    jbeq rsrc_SERD_0_6BC_1C
rsrc_SERD_0_6BC_18:     /* result 1 */
    moveq #1,%d0
    rts
rsrc_SERD_0_6BC_1C:     /* result 0 */
    moveq #0,%d0
    rts
    moveal ExpandMem,%a2
    moveal %a2@(88),%a2
    jbra rsrc_SERD_0_6BC_2E
    moveal SerialVars_a,%a2
rsrc_SERD_0_6BC_2E:     /* test %a2@(118) */
    tstb %a2@(118)
    jbne rsrc_SERD_0_6BC_3E
    tstb %a2@(27)
    jbeq rsrc_SERD_0_6BC_46
    jbsr rsrc_SERD_0_6BC
    jbne rsrc_SERD_0_6BC_46
rsrc_SERD_0_6BC_3E:     /* loop: movea */
    moveal %a2@,%a1
    movew %sr,%sp@-
    jbra rsrc_SERD_0_678
rsrc_SERD_0_6BC_46:     /* set %a1@ */
    moveb #40,%a1@
    rts

/* subroutine (1 instructions) (mechanical summary) */
rsrc_SERD_0_6BC_4C:     /* loop: clr */
    clrb %a2@(29)

/* subroutine (32 instructions): calls rsrc_SERD_0_6BC, rsrc_SERD_0_788, rsrc_SERD_0_782, rsrc_SERD_0_764; low memory ExpandMem (mechanical summary) */
rsrc_SERD_0_70C:        /* call rsrc_SERD_0_6BC (loop) */
    jbsr rsrc_SERD_0_6BC
    jbne rsrc_SERD_0_70C_A
    tstb %a2@(27)
    jbne rsrc_SERD_0_6BC_3E
rsrc_SERD_0_70C_A:      /* return */
    rts
    moveal SerialVars_a,%a2	| 4086B2A8
    jbra rsrc_SERD_0_726	| 4086B2AC
    moveal ExpandMem,%a2
    moveal %a2@(88),%a2
rsrc_SERD_0_726:        /* set %d0 */
    moveq #-19,%d0
    movel %a2,%d1
    jble rsrc_SERD_0_4E0
    movel %a1,%a2@(140)
    jbsr rsrc_SERD_0_788
rsrc_SERD_0_70C_28:     /* loop: move */
    movew %sr,%sp@-
    oriw #1792,%sr
    cmpw %a2@(44),%d2
    jbeq rsrc_SERD_0_70C_52
    moveb %a3@(0x0,%d2:w),%d0
    addqw #1,%d2
    cmpw %d3,%d2
    jbne rsrc_SERD_0_70C_40
    moveq #0,%d2
rsrc_SERD_0_70C_40:     /* set %a2@(46) */
    movew %d2,%a2@(46)
    jbsr rsrc_SERD_0_782
    movew %sp@+,%sr
    tstw %d0
    jbpl rsrc_SERD_0_70C_28
    jbsr rsrc_SERD_0_764
    jbra rsrc_SERD_0_678_2C
rsrc_SERD_0_70C_52:     /* from here: st %a2@(26) */
    st %a2@(26)
    jbra rsrc_SERD_0_764_6

/* subroutine (12 instructions): calls rsrc_SERD_0_788, rsrc_SERD_0_798, rsrc_SERD_0_7A2 (mechanical summary) */
rsrc_SERD_0_764:        /* set %sp@- */
    movew %sr,%sp@-
    oriw #1792,%sr
rsrc_SERD_0_764_6:      /* test %a2@(22) */
    tstw %a2@(22)
    jbeq rsrc_SERD_0_764_18
    jbsr rsrc_SERD_0_788
    jbsr rsrc_SERD_0_798
    cmpw %a2@(12),%d0
    jbhi rsrc_SERD_0_764_18
    jbsr rsrc_SERD_0_7A2
rsrc_SERD_0_764_18:     /* clear %d0 */
    moveq #0,%d0
    movew %sp@+,%sr
    rts

/* subroutine (2 instructions): low memory JStash (mechanical summary) */
rsrc_SERD_0_782:        /* loop: move */
    movel JStash,%sp@-
rsrc_SERD_0_782_4:      /* return */
    rts

/* subroutine (4 instructions) (mechanical summary) */
rsrc_SERD_0_788:        /* loop: movea */
    moveal %a2@(6),%a3
    movew %a2@(10),%d3
    movemw %a2@(44),%d1-%d2
    rts

/* subroutine (5 instructions) (mechanical summary) */
rsrc_SERD_0_798:        /* loop: move */
    movew %d1,%d0
    subw %d2,%d0
    jbcc rsrc_SERD_0_798_8
    addw %d3,%d0
rsrc_SERD_0_798_8:      /* return */
    rts

/* subroutine (7 instructions): calls rsrc_SERD_0_594 (mechanical summary) */
rsrc_SERD_0_7A2:        /* test %a2@(23) */
    tstb %a2@(23)
    jbeq rsrc_SERD_0_7A2_12
    bclr #6,%a2@(25)
    jbeq rsrc_SERD_0_7A2_12
    jbsr rsrc_SERD_0_594
rsrc_SERD_0_7A2_12:     /* test %a2@(22) */
    tstb %a2@(22)
    jbeq rsrc_SERD_0_782_4

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_7BA:        /* clear bit 7 of %a2@(25) */
    bclr #7,%a2@(25)
    jbeq rsrc_SERD_0_782_4
    moveb %a2@(18),%d0

/* subroutine (27 instructions): calls rsrc_SERD_0_6AA, rsrc_SERD_0_1416, rsrc_SERD_0_828 (mechanical summary) */
rsrc_SERD_0_7C6:        /* loop: tst */
    tstb %a2@(118)
    jbeq rsrc_SERD_0_7C6_C
rsrc_SERD_0_7C6_6:      /* loop: clr */
    clrb %a2@(118)
rsrc_SERD_0_7C6_A:      /* return */
    rts
rsrc_SERD_0_7C6_C:      /* set %a2@(118) */
    moveb %d0,%a2@(118)
    jbsr rsrc_SERD_0_6AA
    jbeq rsrc_SERD_0_7C6_A
    moveb %d0,%a3@(4)
    jbra rsrc_SERD_0_7C6_6
    moveal PollStack,%a4	| 4086B372
    movel %sp@+,0x128	| 4086B376
    nop	| 4086B37A
    nop	| 4086B37C
rsrc_SERD_0_7EE:        /* call rsrc_SERD_0_1416 (loop) */
    jbsr rsrc_SERD_0_1416	| 4086B37E
    cmpal %sp,%a4	| 4086B382
    jbeq rsrc_SERD_0_80C	| 4086B384
    subqw #2,%a4	| 4086B386
    moveb %a4@,%d0	| 4086B388
    lea SerialVars_a,%a3	| 4086B38A
    moveml SCCRd,%a0-%a1	| 4086B38E
    addqw #2,%a0	| 4086B394
    addqw #2,%a1	| 4086B396
    jbsr rsrc_SERD_0_828	| 4086B398
    jbra rsrc_SERD_0_7EE	| 4086B39A
rsrc_SERD_0_80C:        /* set %sp */
    moveal PollStack,%sp	| 4086B39C
    movel 0x128,%sp@-	| 4086B3A0
    rts	| 4086B3A4
    .byte   0x26, 0x78, 0x02, 0xB6, 0x47, 0xEB, 0x00, 0x58, 0x60, 0x04, 0x47, 0xF8, 0x02, 0xD0, 0x10, 0x28	| 4086B3A6
    .byte   0x00, 0x04	| 4086B3B6

/* subroutine (47 instructions): calls rsrc_SERD_0_782, rsrc_SERD_0_788, rsrc_SERD_0_798, rsrc_SERD_0_586 (mechanical summary) */
rsrc_SERD_0_828:        /* set %a2 */
    moveal %a3@+,%a2	| 4086B3B8
    moveal %a2@(140),%a3
    andb %a2@(119),%d0
    moveb %a2@(120),%d1
    jbeq rsrc_SERD_0_7C6_7A
    cmpb %d1,%d0
    jbne rsrc_SERD_0_7C6_7A
    moveb %a2@(121),%d0
rsrc_SERD_0_7C6_7A:     /* test %a2@(16) */
    tstb %a2@(16)
    jbeq rsrc_SERD_0_7C6_94
    cmpb %a2@(18),%d0
    jbeq rsrc_SERD_0_6BC_4C
    cmpb %a2@(19),%d0
    jbne rsrc_SERD_0_7C6_94
    st %a2@(29)
    jbra rsrc_SERD_0_7C6_104
rsrc_SERD_0_7C6_94:     /* loop: tst */
    tstb %a2@(26)
    jbeq rsrc_SERD_0_7C6_AA
    moveal %a3,%a1
    jbsr rsrc_SERD_0_782
    jbpl rsrc_SERD_0_7C6_104
    clrb %a2@(26)
    jbra rsrc_SERD_0_678_2C
rsrc_SERD_0_7C6_AA:     /* call rsrc_SERD_0_788 */
    jbsr rsrc_SERD_0_788
    moveb %d0,%a3@(0x0,%d1:w)
    addqw #1,%d1
    cmpw %d3,%d1
    jbne rsrc_SERD_0_7C6_BA
    moveq #0,%d1
rsrc_SERD_0_7C6_BA:     /* test %d2,%d1 */
    cmpw %d2,%d1
    jbne rsrc_SERD_0_7C6_C6
    bset #0,%a2@(24)
    jbra rsrc_SERD_0_7C6_104
rsrc_SERD_0_7C6_C6:     /* set %a2@(44) */
    movew %d1,%a2@(44)
    tstw %a2@(22)
    jbeq rsrc_SERD_0_7C6_104
    jbsr rsrc_SERD_0_798
    subw %d0,%d3
    cmpw %a2@(14),%d3
    jbcc rsrc_SERD_0_7C6_104
    tstb %a2@(23)
    jbeq rsrc_SERD_0_7C6_F4
    bset #6,%a2@(25)
    jbne rsrc_SERD_0_7C6_EE
    jbsr rsrc_SERD_0_586
rsrc_SERD_0_7C6_EE:     /* test %a2@(22) */
    tstb %a2@(22)
    jbeq rsrc_SERD_0_7C6_104

/* subroutine (319 instructions): traps RGetResource, ResError, trap_A440, trap_A722, ReleaseResource, HLock, IOPMsgRequest, DisposHandle; calls rsrc_SERD_0_7C6, rsrc_SERD_0_5BC, rsrc_SERD_0_AE, rsrc_SERD_0_B4, rsrc_SERD_0_132 ...; low memory Ticks (mechanical summary) */
rsrc_SERD_0_7C6_F4:     /* set bit 7 of %a2@(25) */
    bset #7,%a2@(25)
    jbne rsrc_SERD_0_7C6_104
    moveb %a2@(19),%d0
    jbsr rsrc_SERD_0_7C6
rsrc_SERD_0_7C6_104:    /* return */
    rts
    .long   0x267802B6	| 4086B45C
    .long   0x47EB0058, 0x600447F8, 0x02D012BC	| 4086B460
    .short  0x0001, 0x245B	| orib #91,%d1
    moveal %a2@(140),%a3
    moveb %a0@,%d1
    moveq #112,%d3
    andb %d3,%d1
    orb %d1,%a2@(24)
    moveb %a0@(4),%d0
    andb %a2@(119),%d0
    moveb %a2@(20),%d2
    andb %d1,%d2
    moveb #48,%a1@
    andb %d3,%d2
    jbne rsrc_SERD_0_7C6_158
    moveb %a2@(120),%d3
    jbeq rsrc_SERD_0_7C6_154
    cmpb %d0,%d3
    jbne rsrc_SERD_0_7C6_14C
    moveb %a2@(121),%d0
rsrc_SERD_0_7C6_14C:    /* test bit 4 of %d1 */
    btst #4,%d1
    jbeq rsrc_SERD_0_7C6_154
    moveb %d3,%d0
rsrc_SERD_0_7C6_154:    /* continue at rsrc_SERD_0_7C6_94 */
    jbra rsrc_SERD_0_7C6_94
rsrc_SERD_0_7C6_158:    /* test %a2@(26) */
    tstb %a2@(26)
    jbeq rsrc_SERD_0_7C6_104
    moveq #-89,%d0
rsrc_SERD_0_7C6_160:    /* loop: movea */
    moveal %a3,%a1
    clrb %a2@(26)
    jbra rsrc_SERD_0_4E0
    moveal ExpandMem,%a3
    lea %a3@(88),%a3
    bras rsrc_SERD_0_7C6_160_18
    lea SerialVars_a,%a3
rsrc_SERD_0_7C6_160_18:
    moveal %a3@+,%a2
    movel %a2@,%d2
    moveb %d1,%d2
    andb %a2@(21),%d2
    beqs rsrc_SERD_0_7C6_160_3E
    moveml %d0/%a0,%sp@-
    moveaw #11,%a0
    aslw #8,%d0
    moveb %d1,%d0
    swap %d0
    movew %a3@(24),%d0
    addqw #1,%d0
    _PostEvent
    moveml %sp@+,%d0/%a0
rsrc_SERD_0_7C6_160_3E:
    tstb %d1
    bmis rsrc_SERD_0_7C6_1CA_8
    lslb #2,%d0
    smi %a2@(28)
    cmpiw #80,%a2@(112)
    bcss rsrc_SERD_0_7C6_160_58
    moveq #-128,%d0
    moveq #15,%d1
    jbsr rsrc_SERD_0_5BC
rsrc_SERD_0_7C6_160_58:
    movel Ticks,%d2
    cmpl %a2@(114),%d2
    jbeq rsrc_SERD_0_7C6_1CA
    movel %d2,%a2@(114)
    clrw %a2@(112)
rsrc_SERD_0_7C6_1CA:    /* add 1 to %a2@(112) */
    addqw #1,%a2@(112)
    jbra rsrc_SERD_0_70C
rsrc_SERD_0_7C6_1CA_8:
    tstb %d0	| 4086B528
    bmis rsrc_SERD_0_7C6_1CA_8+0xa
    moveb %a0@(4),%d0
    rts
    moveq #-90,%d0
    tstb %a2@(26)
    jbne rsrc_SERD_0_7C6_160
    rts

rsrc_SERD_0_9AE:        /* call rsrc_SERD_0_AE */
    jbsr rsrc_SERD_0_AE
    lea %pc@(rsrc_SERD_0_52),%a2
    lea %pc@(rsrc_SERD_0_A28),%a3
    jbra rsrc_SERD_0_9D8_C

rsrc_SERD_0_9BC:        /* call rsrc_SERD_0_B4 */
    jbsr rsrc_SERD_0_B4
    lea %pc@(rsrc_SERD_0_82),%a2
    lea %pc@(rsrc_SERD_0_A58),%a3
    jbra rsrc_SERD_0_9D8_C

rsrc_SERD_0_9CA:        /* call rsrc_SERD_0_AE */
    jbsr rsrc_SERD_0_AE
    lea %pc@(rsrc_SERD_0_3A),%a2
    lea %pc@(rsrc_SERD_0_A10),%a3
    jbra rsrc_SERD_0_9D8_C

rsrc_SERD_0_9D8:        /* call rsrc_SERD_0_B4 */
    jbsr rsrc_SERD_0_B4
    lea %pc@(rsrc_SERD_0_6A),%a2
    lea %pc@(rsrc_SERD_0_A40),%a3
rsrc_SERD_0_9D8_C:      /* set %a4 */
    moveal %a0,%a4
    btst #1,0xdd1
    jbeq rsrc_SERD_0_9D8_2C
    movel #65673,%d0
    tstw %sp@-
    moveal %sp,%a0
    moveb %sp@+,%d0
    btst #0,0xbfe
    jbne rsrc_SERD_0_9D8_2C
    moveal %a3,%a2
rsrc_SERD_0_9D8_2C:     /* set %a1@ */
    movel %a2,%a1@
    movew %a2@(8),%d0
    moveal %a4,%a0
    jmp %a2@(0x4,%d0:w)
rsrc_SERD_0_A10:        /* (data) */
    .long   0x4D000000, 0x00000000, 0x006004DC, 0x02D00218	| 4086B5A0
    .long   0x020C042E, 0x41496E20	| 4086B5B0
rsrc_SERD_0_A28:        /* (data) */
    .long   0x4E000000, 0x00000000	| 4086B5B8
    .long   0x005C0424, 0x02B001F8, 0x0174052E, 0x414F7574	| 4086B5C0
rsrc_SERD_0_A40:        /* (data) */
    .long   0x4D000000, 0x00000000, 0x003604B2, 0x02A601EE	| 4086B5D0
    .long   0x01DC042E, 0x42496E20	| 4086B5E0
rsrc_SERD_0_A58:        /* (data) */
    .long   0x4E000000, 0x00000000	| 4086B5E8
    .long   0x005C03F4, 0x028001C8, 0x0144052E, 0x424F7574	| 4086B5F0
rsrc_SERD_0_A70:        /* jump through %pc@(rsrc_SERD_0_9CA) */
    jmp %pc@(rsrc_SERD_0_9CA)
    .byte   0x60, 0x04, 0x4E, 0xFA, 0xFF, 0x60	| 4086B604
    moveb #3,%a1@(7)	| 4086B60A
    moveq #0,%d0	| 4086B610
    rts	| 4086B612
    .byte   0x4E, 0xFA, 0xFF, 0x28	| 4086B614
    linkw %fp,#-64	| 4086B618
    clrw %fp@(-12)	| 4086B61C
    movew #1,%fp@(-10)	| 4086B620
    movew #60,%fp@(-8)	| 4086B626
    movew #-6,%fp@(-32)	| 4086B62C
    movew SPPortA,%fp@(-28)	| 4086B632
    movew #8,%fp@(-30)	| 4086B638
    lea SerialVars_a,%a0	| 4086B63E
    jbra rsrc_SERD_0_AE6	| 4086B642
    .byte   0x4E, 0xFA, 0xFF, 0x06	| 4086B644
    linkw %fp,#-64	| 4086B648
    movew #1,%fp@(-12)	| 4086B64C
    movew #4,%fp@(-10)	| 4086B652
    movew #61,%fp@(-8)	| 4086B658
    movew #-8,%fp@(-32)	| 4086B65E
    movew SPPortB,%fp@(-28)	| 4086B664
    clrw %fp@(-30)	| 4086B66A
    moveal ExpandMem,%a0	| 4086B66E
    lea %a0@(88),%a0	| 4086B672
rsrc_SERD_0_AE6:        /* set %fp@(-24) */
    movel %a0,%fp@(-24)	| 4086B676
    movel %a1,%fp@(-4)	| 4086B67A
    clrl %sp@-	| 4086B67E
    movel #1397051972,%sp@-	| 4086B680
    movew %fp@(-8),%sp@-	| 4086B686
    _RGetResource	| 4086B68A
    clrw %sp@-	| 4086B68C
    _ResError	| 4086B68E
    movew %sp@+,%d0	| 4086B690
    jbeq rsrc_SERD_0_B16	| 4086B692
    tstl %sp@+	| 4086B694
    movew %d0,%sp@-	| 4086B696
    movew %fp@(-30),%d3	| 4086B698
    jbsr rsrc_SERD_0_132	| 4086B69C
    movew %sp@+,%d0	| 4086B6A0
    unlk %fp	| 4086B6A2
    rts	| 4086B6A4
rsrc_SERD_0_B16:        /* set %fp@(-16) */
    movel %sp@+,%fp@(-16)	| 4086B6A6
    moveb #1,%d1	| 4086B6AA
    jbsr rsrc_SERD_0_FAC	| 4086B6AE
    jbne rsrc_SERD_0_B42	| 4086B6B2
    movel #464,%d0	| 4086B6B4
    .short  0xA440	| 4086B6BA _ResrvMem (flags 0x0400)
    movel #464,%d0	| 4086B6BC
    .short  0xA722	| 4086B6C2 _NewHandle (flags 0x0700)
    jbeq rsrc_SERD_0_B58	| 4086B6C4
    moveb #2,%d1	| 4086B6C6
    jbsr rsrc_SERD_0_FAC	| 4086B6CA
    movew #-108,%d0	| 4086B6CE
rsrc_SERD_0_B42:        /* set %sp@- */
    movew %d0,%sp@-	| 4086B6D2
    movel %fp@(-16),%sp@-	| 4086B6D4
    _ReleaseResource	| 4086B6D8
    movew %fp@(-30),%d3	| 4086B6DA
    jbsr rsrc_SERD_0_132	| 4086B6DE
    movew %sp@+,%d0	| 4086B6E2
    unlk %fp	| 4086B6E4
    rts	| 4086B6E6
rsrc_SERD_0_B58:        /* set %fp@(-20) */
    movel %a0,%fp@(-20)	| 4086B6E8
    moveal %a0,%a1	| 4086B6EC
    moveal %a1@,%a2	| 4086B6EE
    _HLock	| 4086B6F0
    moveb %fp@(-11),%a2@(1)	| 4086B6F2
    movew %fp@(-32),%a2@(6)	| 4086B6F8
    movew %fp@(-30),%a2@(8)	| 4086B6FE
    movel %fp@(-24),%a2@(18)	| 4086B704
    jbsr rsrc_SERD_0_100E
    moveal %fp@(-4),%a1
    movel %fp@(-20),%a1@(20)
    moveb #3,%a1@(7)
    st %a2@
    moveal %a2@(18),%a0
    movel %a2,%a0@
    clrw %d0
    unlk %fp
    rts
    .byte   0x2F, 0x09, 0x24, 0x69, 0x00, 0x14, 0x24, 0x52, 0x42, 0x12, 0x9E, 0xFC, 0x00, 0x1C, 0x20, 0x4F	| 4086B72C
    .byte   0x11, 0x7C, 0x00, 0x03, 0x00, 0x07, 0x42, 0x28, 0x00, 0x06, 0x11, 0x6A, 0x00, 0x72, 0x00, 0x08	| 4086B73C
    .byte   0xA0, 0x87, 0x4F, 0xEF, 0x00, 0x1C, 0x15, 0x7C, 0x00, 0x02, 0x01, 0x0F, 0x41, 0xEA, 0x00, 0x16	| 4086B74C
    .byte   0xA0, 0x87, 0x4A, 0x2A, 0x00, 0x21, 0x66, 0xFA	| 4086B75C
    moveb #2,%a2@(312)	| 4086B764
    moveb %a2@(1),%a2@(313)	| 4086B76A
    lea %a2@(134),%a0	| 4086B770
    _IOPMsgRequest	| 4086B774
rsrc_SERD_0_BE6:        /* loop: tst */
    tstb %a2@(145)	| 4086B776
    jbne rsrc_SERD_0_BE6	| 4086B77A
    movel %a2@(10),%d0	| 4086B77C
    jbeq rsrc_SERD_0_C02	| 4086B780
    moveal %d0,%a1	| 4086B782
    movel %a2,%sp@-	| 4086B784
    movew #-19,%d0	| 4086B786
    moveal JIODone,%a0	| 4086B78A
    jsr %a0@	| 4086B78E
    moveal %sp@+,%a2	| 4086B790
rsrc_SERD_0_C02:        /* set %d3 */
    movew %a2@(8),%d3	| 4086B792
    jbsr rsrc_SERD_0_132	| 4086B796
    moveal %a2@(18),%a0	| 4086B79A
    clrl %a0@	| 4086B79E
    moveal %sp@+,%a1	| 4086B7A0
    moveal %a1@(20),%a0	| 4086B7A2
    clrl %a1@(20)	| 4086B7A6
    _DisposHandle	| 4086B7AA
    moveq #0,%d0	| 4086B7AC
    rts	| 4086B7AE
    .byte   0x24, 0x69, 0x00, 0x14, 0x24, 0x52, 0x60, 0x1C, 0x20, 0x38, 0x02, 0xD0, 0x60, 0x08, 0x24, 0x78	| 4086B7B0
    .byte   0x02, 0xB6, 0x20, 0x2A, 0x00, 0x58, 0x24, 0x40, 0x6E, 0x00, 0x00, 0x0A, 0x30, 0x3C, 0xFF, 0xEE	| 4086B7C0
    .byte   0x60, 0x00, 0x00, 0x88, 0x32, 0x28, 0x00, 0x1A	| 4086B7D0
    subqw #2,%d1	| 4086B7D8
    jbne rsrc_SERD_0_C66	| 4086B7DA
    movew %a2@(374),%d0	| 4086B7DC
    subw %a2@(376),%d0	| 4086B7E0
    jbcc rsrc_SERD_0_C5A	| 4086B7E4
    addw %a2@(372),%d0	| 4086B7E6
rsrc_SERD_0_C5A:        /* clear %a0@(28) */
    clrw %a0@(28)	| 4086B7EA
    movew %d0,%a0@(30)	| 4086B7EE
    braw rsrc_SERD_0_CC8	| 4086B7F2
rsrc_SERD_0_C66:        /* subtract 6 to %d1 */
    subqw #6,%d1	| 4086B7F6
    bnew rsrc_SERD_0_CCA	| 4086B7F8
    subaw #19,%sp	| 4086B7FC
    moveml %a0-%a1,%sp@-	| 4086B800
    lea %sp@(8),%a0	| 4086B804
    clrb %a0@	| 4086B808
    clrb %a0@(1)	| 4086B80A
    movew #7,%a0@(2)	| 4086B80E
    movew %a2@(446),%a0@(8)	| 4086B814
    lea %a0@(12),%a1	| 4086B81A
    movel %a1,%a0@(4)	| 4086B81E
    _IOPMoveData	| 4086B822
    tstb %a1@+	| 4086B824
    jbeq rsrc_SERD_0_C9C	| 4086B826
    clrb %a1@	| 4086B828
    jbra rsrc_SERD_0_CB0	| 4086B82A
rsrc_SERD_0_C9C:        /* address %sp@(8) */
    lea %sp@(8),%a0	| 4086B82C
    moveb #1,%a0@	| 4086B830
    movew #1,%a0@(2)	| 4086B834
    st %a0@(12)	| 4086B83A
    _IOPMoveData	| 4086B83E
rsrc_SERD_0_CB0:        /* restore registers */
    moveml %sp@+,%a0-%a1	| 4086B840
    lea %a0@(28),%a2	| 4086B844
    lea %sp@(13),%a3	| 4086B848
    moveq #5,%d0	| 4086B84C
rsrc_SERD_0_CBE:        /* loop: move */
    moveb %a3@+,%a2@+	| 4086B84E
    dbf %d0,rsrc_SERD_0_CBE	| 4086B850
    lea %sp@(19),%sp	| 4086B854
rsrc_SERD_0_CC8:        /* clear %d0 */
    clrw %d0	| 4086B858
rsrc_SERD_0_CCA:        /* test bit 9 of %a0@(6) */
    btst #9,%a0@(6)	| 4086B85A
    jbne rsrc_SERD_0_CD6	| 4086B860
    movel JIODone,%sp@-	| 4086B862
rsrc_SERD_0_CD6:        /* return */
    rts	| 4086B866
    .byte   0x24, 0x69, 0x00, 0x14, 0x24, 0x52, 0x60, 0x24, 0x20, 0x38, 0x02, 0xD0, 0x60, 0x08, 0x24, 0x78	| 4086B868
    .byte   0x02, 0xB6, 0x20, 0x2A, 0x00, 0x58, 0x24, 0x40, 0x6E, 0x00, 0x00, 0x12	| 4086B878
    movew #-17,%d0	| 4086B884
    movew %a0@(26),%d1	| 4086B888
    subqw #1,%d1	| 4086B88C
    jbne rsrc_SERD_0_D44	| 4086B88E
    clrw %d0	| 4086B890
    rts	| 4086B892
    .byte   0x32, 0x28, 0x00, 0x1A	| 4086B894
    subqw #1,%d1	| 4086B898
    jbne rsrc_SERD_0_D20	| 4086B89A
    clrl %a2@(10)	| 4086B89C
    clrl %a2@(14)	| 4086B8A0
    clrw %a2@(374)	| 4086B8A4
    clrw %a2@(376)	| 4086B8A8
    clrw %d0	| 4086B8AC
    rts	| 4086B8AE
rsrc_SERD_0_D20:        /* set %d0 */
    movew #-17,%d0	| 4086B8B0
    subqw #7,%d1	| 4086B8B4
    jbcs rsrc_SERD_0_D44	| 4086B8B6
    cmpiw #19,%d1	| 4086B8B8
    jbhi rsrc_SERD_0_D44	| 4086B8BC
    lea %pc@(rsrc_SERD_0_D52),%a3	| 4086B8BE
    addw %d1,%d1	| 4086B8C2
    movew %a3@(0,%d1:w),%d1	| 4086B8C4
    moveml %a0-%a1,%sp@-	| 4086B8C8
    jsr %a3@(0,%d1:w)	| 4086B8CC
    moveml %sp@+,%a0-%a1	| 4086B8D0
rsrc_SERD_0_D44:        /* test bit 9 of %a0@(6) */
    btst #9,%a0@(6)	| 4086B8D4
    jbne rsrc_SERD_0_D50	| 4086B8DA
    movel JIODone,%sp@-	| 4086B8DC
rsrc_SERD_0_D50:        /* return */
    rts	| 4086B8E0
rsrc_SERD_0_D52:        /* from here: oriw #124,%a4@ */
    oriw #124,%a4@	| 4086B8E2
    orib #42,%a2@(42)	| 4086B8E6
    oril #2752554,%a0@(42)	| 4086B8EC
    orib #42,%a2@(42)	| 4086B8F4
    orib #42,%a2@(42)	| 4086B8FA
    orib #42,%a2@(42)	| 4086B900
    orib #42,%a2@(20085)	| 4086B906
    jbsr rsrc_SERD_0_13FA	| 4086B90C
    jbeq rsrc_SERD_0_DA4	| 4086B910
    moveal %a3@(12),%a1	| 4086B912
    moveb %a0@(27),%a1@(2)	| 4086B916
    lea %a0@(28),%a0	| 4086B91C
    lea %a1@(4),%a1	| 4086B920
    movew #11,%d1	| 4086B924
rsrc_SERD_0_D98:        /* loop: move */
    moveb %a0@+,%a1@+	| 4086B928
    dbf %d1,rsrc_SERD_0_D98	| 4086B92A
    moveal %a3,%a0	| 4086B92E
    _IOPMsgRequest	| 4086B930
    clrw %d0	| 4086B932
rsrc_SERD_0_DA4:        /* return */
    rts	| 4086B934
    .byte   0x61, 0x00, 0x06, 0x52, 0x67, 0x20, 0x22, 0x6B, 0x00, 0x0C, 0x13, 0x7C, 0x00, 0x08, 0x00, 0x02	| 4086B936
    .byte   0x30, 0x28, 0x00, 0x1C, 0x61, 0x00, 0x03, 0xA0, 0x33, 0x40, 0x00, 0x06, 0x33, 0x41, 0x00, 0x04	| 4086B946
    .byte   0x20, 0x4B, 0xA0, 0x87, 0x42, 0x40, 0x4E, 0x75, 0x42, 0x6A, 0x01, 0x76, 0x42, 0x6A, 0x01, 0x78	| 4086B956
    .byte   0x30, 0x28, 0x00, 0x20, 0x67, 0x0C, 0x35, 0x40, 0x01, 0x74, 0x25, 0x68, 0x00, 0x1C, 0x01, 0x70	| 4086B966
    .byte   0x60, 0x0E, 0x41, 0xEA, 0x01, 0x7A, 0x25, 0x48, 0x01, 0x70, 0x35, 0x7C, 0x00, 0x40, 0x01, 0x74	| 4086B976
    .byte   0x42, 0x40, 0x4E, 0x75, 0x61, 0x00, 0x05, 0xFE, 0x67, 0x34, 0x22, 0x6B, 0x00, 0x0C, 0x24, 0x3C	| 4086B986
    .byte   0x00, 0x01, 0xC2, 0x00, 0x26, 0x02, 0x70, 0x00, 0x30, 0x28, 0x00, 0x1C, 0x22, 0x00, 0xE2, 0x49	| 4086B996
    .byte   0xD4, 0x81, 0x84, 0xC0, 0x32, 0x02, 0x55, 0x42, 0x33, 0x42, 0x00, 0x04, 0x86, 0xC1, 0x31, 0x43	| 4086B9A6
    .byte   0x00, 0x1C, 0x13, 0x7C, 0x00, 0x0D, 0x00, 0x02, 0x20, 0x4B, 0xA0, 0x87, 0x42, 0x40, 0x4E, 0x75	| 4086B9B6
    .byte   0x40, 0xE7, 0x00, 0x7C, 0x07, 0x00, 0x22, 0x68, 0x00, 0x18, 0x20, 0xA9, 0x01, 0x6C, 0x23, 0x48	| 4086B9C6
    .byte   0x01, 0x6C, 0x46, 0xDF, 0x4E, 0x75	| 4086B9D6
    moveal %a1@(20),%a2	| 4086B9DC
    moveal %a2@,%a2	| 4086B9E0
    clrl %a0@(40)	| 4086B9E2
    movew %sr,%sp@-	| 4086B9E6
    oriw #1792,%sr	| 4086B9E8
    movel %a1,%a2@(14)	| 4086B9EC
    tas %a2@(3)	| 4086B9F0
    jbeq rsrc_SERD_0_E6A	| 4086B9F4
    movew %sp@+,%sr	| 4086B9F6
    rts	| 4086B9F8
rsrc_SERD_0_E6A:        /* set %sr */
    movew %sp@+,%sr	| 4086B9FA
    lea %a2@(78),%a0	| 4086B9FC
    lea %a0@(-78),%a2	| 4086BA00
    tstb %a2@	| 4086BA04
    jbne rsrc_SERD_0_E7A	| 4086BA06
    rts	| 4086BA08
rsrc_SERD_0_E7A:        /* set %sp@- */
    movew %sr,%sp@-	| 4086BA0A
    oriw #1792,%sr	| 4086BA0C
    movel %a2@(14),%d0	| 4086BA10
    jbne rsrc_SERD_0_E8E	| 4086BA14
    clrb %a2@(3)	| 4086BA16
    movew %sp@+,%sr	| 4086BA1A
    rts	| 4086BA1C
rsrc_SERD_0_E8E:        /* set %sr */
    movew %sp@+,%sr	| 4086BA1E
    moveal %d0,%a1	| 4086BA20
    moveal %a1@(8),%a0	| 4086BA22
    movel %a0@(36),%d0	| 4086BA26
    subl %a0@(40),%d0	| 4086BA2A
    jbeq rsrc_SERD_0_ED8	| 4086BA2E
    moveq #0,%d1	| 4086BA30
    movew %a2@(444),%d1	| 4086BA32
    cmpl %d1,%d0	| 4086BA36
    jbls rsrc_SERD_0_EAC	| 4086BA38
    movel %d1,%d0	| 4086BA3A
rsrc_SERD_0_EAC:        /* set %a2@(304) */
    movew %d0,%a2@(304)	| 4086BA3C
    movew %d0,%a2@(260)	| 4086BA40
    moveal %a0@(32),%a3	| 4086BA44
    addal %a0@(40),%a3	| 4086BA48
    movel %a3,%a2@(262)	| 4086BA4C
    movew %a2@(442),%a2@(266)	| 4086BA50
    addl %d0,%a0@(40)	| 4086BA56
    lea %a2@(258),%a0	| 4086BA5A
    _IOPMoveData	| 4086BA5E
    lea %a2@(78),%a0	| 4086BA60
    _IOPMsgRequest	| 4086BA64
    rts	| 4086BA66
rsrc_SERD_0_ED8:        /* set %a1 */
    moveal %a2@(14),%a1	| 4086BA68
    clrl %a2@(14)	| 4086BA6C
    clrb %a2@(3)	| 4086BA70
    clrw %d0	| 4086BA74
    movel JIODone,%sp@-	| 4086BA76
    rts	| 4086BA7A
    .byte   0x20, 0x38, 0x02, 0xD0, 0x60, 0x08, 0x24, 0x78, 0x02, 0xB6, 0x20, 0x2A, 0x00, 0x58, 0x24, 0x40	| 4086BA7C
    .byte   0x6E, 0x0A, 0x30, 0x3C, 0xFF, 0xED, 0x2F, 0x38, 0x08, 0xFC, 0x4E, 0x75, 0x42, 0xA8, 0x00, 0x28	| 4086BA8C
    .byte   0x25, 0x49, 0x00, 0x0A, 0x60, 0x00, 0x02, 0x7C, 0x45, 0xE8, 0xFF, 0xCE, 0x4A, 0x12, 0x66, 0x02	| 4086BA9C
    .byte   0x4E, 0x75, 0x35, 0x6A, 0x01, 0x28, 0x01, 0xCA, 0x57, 0xEA, 0x01, 0xCE, 0x67, 0x44, 0x30, 0x2A	| 4086BAAC
    .byte   0x01, 0x26, 0x35, 0x40, 0x01, 0xC2, 0x35, 0x6A, 0x01, 0x22, 0x01, 0xC6, 0x32, 0x2A, 0x01, 0x24	| 4086BABC
    .byte   0x92, 0x40, 0x30, 0x2A, 0x01, 0xCA, 0xB0, 0x41, 0x62, 0x0A, 0x35, 0x40, 0x01, 0xC0, 0x42, 0x6A	| 4086BACC
    .byte   0x01, 0xC4, 0x60, 0x0A, 0x35, 0x41, 0x01, 0xC0, 0x90, 0x41, 0x35, 0x40, 0x01, 0xC4, 0x4A, 0x2A	| 4086BADC
    .byte   0x01, 0x1C, 0x56, 0xEA, 0x01, 0xCF, 0x67, 0x0A, 0x35, 0x6A, 0x01, 0x2A, 0x01, 0xCC, 0x57, 0xEA	| 4086BAEC
    .byte   0x01, 0xCE, 0x42, 0x6A, 0x01, 0xC8, 0x42, 0x2A, 0x01, 0x22, 0x42, 0x2A, 0x00, 0x02, 0x60, 0x00	| 4086BAFC
    .byte   0x02, 0x12, 0x45, 0xE8, 0xFF, 0x96, 0x4A, 0x12, 0x66, 0x02, 0x4E, 0x75, 0x30, 0x7C, 0x00, 0x0B	| 4086BB0C
    .byte   0x10, 0x2A, 0x01, 0x36, 0xE1, 0x40, 0x10, 0x2A, 0x01, 0x37, 0x48, 0x40, 0x30, 0x2A, 0x00, 0x06	| 4086BB1C
    .byte   0xA0, 0x2F, 0x41, 0xEA, 0x00, 0x6A, 0x11, 0x7C, 0x00, 0x01, 0x00, 0x07, 0xA0, 0x87, 0x4E, 0x75	| 4086BB2C

/* subroutine (27 instructions): traps IOPMsgRequest (mechanical summary) */
rsrc_SERD_0_FAC:        /* address %fp@(-60) */
    lea %fp@(-60),%a0	| 4086BB3C
    lea %fp@(-64),%a1	| 4086BB40
    moveb %d1,%a1@	| 4086BB44
    moveb %fp@(-11),%a1@(1)	| 4086BB46
    moveb #3,%a1@(2)	| 4086BB4C
    clrb %a0@(6)	| 4086BB52
    clrb %a0@(7)	| 4086BB56
    moveb #1,%a0@(8)	| 4086BB5A
    moveb #4,%a0@(9)	| 4086BB60
    moveb #4,%a0@(10)	| 4086BB66
    movel %a1,%a0@(12)	| 4086BB6C
    movel %a1,%a0@(16)	| 4086BB70
    clrl %a0@(20)	| 4086BB74
    _IOPMsgRequest	| 4086BB78
    jbne rsrc_SERD_0_100A	| 4086BB7A
    lea %fp@(-60),%a0	| 4086BB7C
rsrc_SERD_0_FF0:        /* loop: tst */
    tstb %a0@(11)	| 4086BB80
    jbne rsrc_SERD_0_FF0	| 4086BB84
    movew %a1@(2),%d0	| 4086BB86
    addqw #1,%d0	| 4086BB8A
    movew %d0,%fp@(-26)	| 4086BB8C
    clrw %d0	| 4086BB90
    tstb %a1@	| 4086BB92
    jbeq rsrc_SERD_0_100A	| 4086BB94
    movew #-97,%d0	| 4086BB96
rsrc_SERD_0_100A:       /* test %d0 */
    tstw %d0	| 4086BB9A
    rts	| 4086BB9C

/* subroutine (78 instructions): traps IOPMoveData, ReleaseResource, IOPMsgRequest; calls rsrc_SERD_0_115C (mechanical summary) */
rsrc_SERD_0_100E:       /* address %a2@(378) */
    lea %a2@(378),%a0
    movel %a0,%a2@(368)
    movew #64,%a2@(372)
    moveq #0,%d1
    lea %a2@(22),%a0
    lea %pc@(rsrc_SERD_0_111A),%a1
    movew %a1@+,%d0
    moveb %d1,%a2@(247)
    moveb %d1,%a2@(259)
    clrb %a2@(246)
    moveb #1,%a2@(258)
rsrc_SERD_0_100E_2C:    /* loop: move */
    moveb %d1,%a0@(6)
    moveb %a1@+,%a0@(7)
    moveq #1,%d2
    clrw %d3
    moveb %a1@+,%d3
    jbeq rsrc_SERD_0_100E_42
    movew %d3,%d2
    addw %fp@(-10),%d2
rsrc_SERD_0_100E_42:    /* set %a0@(8) */
    moveb %d2,%a0@(8)
    movew %a1@+,%d2
    moveb %d2,%a0@(9)
    moveb %d2,%a0@(10)
    subal %a3,%a3
    movew %a1@+,%d2
    jbeq rsrc_SERD_0_100E_5C
    lea %pc@(rsrc_SERD_0_A70),%a3
    addaw %d2,%a3
rsrc_SERD_0_100E_5C:    /* set %a0@(20) */
    movel %a3,%a0@(20)
    moveal %a2,%a3
    addaw %a1@+,%a3
    movel %a3,%a0@(12)
    movel %a3,%a0@(16)
    lea %a0@(28),%a0
    dbf %d0,rsrc_SERD_0_100E_2C
    moveq #2,%d0
    subal %a1,%a1
    lea %a2@(162),%a0
rsrc_SERD_0_100E_7C:    /* loop: move */
    movel %a1,%a0@
    moveal %a0,%a1
    lea %a0@(28),%a0
    dbf %d0,rsrc_SERD_0_100E_7C
    movel %a1,%a2@(364)
    moveal %fp@(-16),%a1
    moveal %a1@,%a1
    movew %a1@+,%d0
    rolw #8,%d0
    movew %d0,%a2@(260)
    movel %a1,%a2@(262)
    movew %fp@(-26),%a2@(266)
    lea %a2@(258),%a0
    _IOPMoveData
    movel %fp@(-16),%sp@-
    _ReleaseResource
    moveb #3,%a2@(312)
    moveb %fp@(-11),%a2@(313)
    lea %a2@(134),%a0
    _IOPMsgRequest
rsrc_SERD_0_100E_C2:    /* loop: tst */
    tstb %a2@(145)
    jbne rsrc_SERD_0_100E_C2
    moveb #1,%a2@(271)
    movew %fp@(-28),%d0
    jbsr rsrc_SERD_0_115C
    movew %d1,%a2@(274)
    movew %d0,%a2@(276)
    lea %a2@(22),%a0
    _IOPMsgRequest
rsrc_SERD_0_100E_E2:    /* loop: tst */
    tstb %a2@(33)
    jbne rsrc_SERD_0_100E_E2
    movew %a2@(278),%a2@(442)
    movew %a2@(280),%a2@(444)
    movew %a2@(282),%a2@(446)
    st %a2@(2)
    lea %a2@(50),%a0
    _IOPMsgRequest
    lea %a2@(106),%a0
    _IOPMsgRequest
    rts
rsrc_SERD_0_111A:       /* (data) */
    .short  0x0007, 0x0003, 0x000E	| 4086BCAA
    .long   0x0000010E, 0x00010010, 0x04A4011C, 0x00020006	| 4086BCB0
    .long   0x0400012C, 0x02020006, 0x050E0132, 0x00000004	| 4086BCC0
    .long   0x00000138, 0x00030010, 0x03C6013C, 0x00030010	| 4086BCD0
    .long   0x03C6014C, 0x00030010, 0x03C6015C	| 4086BCE0

/* subroutine (178 instructions): traps IOPMsgRequest; calls rsrc_SERD_0_1370 (mechanical summary) */
rsrc_SERD_0_115C:       /* set %d1 */
    movew %d0,%d1
    andiw #-16384,%d1
    jbne rsrc_SERD_0_1168
    movew #-13302,%d0
rsrc_SERD_0_1168:       /* set %sp@- */
    movew %d0,%sp@-
    andiw #1023,%d0
    addqw #2,%d0
    movew #-28672,%d1
    muluw %d1,%d0
    divuw #-28829,%d0
    swap %d0
    movew %d0,%d1
    swap %d0
    cmpiw #18353,%d1
    jble rsrc_SERD_0_1188
    addqw #1,%d0
rsrc_SERD_0_1188:       /* subtract 2 to %d0 */
    subqw #2,%d0
    movew %sp@+,%d1
    rts
    movew %sr,%sp@-	| 4086BD1E
    oriw #1792,%sr	| 4086BD20
    tas %a2@(4)	| 4086BD24
    jbeq rsrc_SERD_0_11A2	| 4086BD28
    st %a2@(5)	| 4086BD2A
    movew %sp@+,%sr	| 4086BD2E
    rts	| 4086BD30
rsrc_SERD_0_11A2:       /* clear %a2@(5) */
    clrb %a2@(5)	| 4086BD32
    movew %sp@+,%sr	| 4086BD36
    clrw %sp@-	| 4086BD38
rsrc_SERD_0_11AA:       /* loop: move */
    movel %a2@(10),%d0	| 4086BD3A
    jbeq rsrc_SERD_0_125E	| 4086BD3E
    tstw %sp@	| 4086BD42
    jbne rsrc_SERD_0_125E	| 4086BD44
    tstb %a2@(462)	| 4086BD48
    jbne rsrc_SERD_0_125E	| 4086BD4C
    moveal %d0,%a0	| 4086BD50
    moveal %a0@(8),%a0	| 4086BD52
    movel %a0@(36),%d3	| 4086BD56
    subl %a0@(40),%d3	| 4086BD5A
    seq %sp@	| 4086BD5E
    jbeq rsrc_SERD_0_125E	| 4086BD60
    moveal %a0@(32),%a3	| 4086BD64
    addal %a0@(40),%a3	| 4086BD68
    movew %a2@(374),%d0	| 4086BD6C
    subw %a2@(376),%d0	| 4086BD70
    jbcc rsrc_SERD_0_11EA	| 4086BD74
    addw %a2@(372),%d0	| 4086BD76
rsrc_SERD_0_11EA:       /* from here: jbeq rsrc_SERD_0_121A */
    jbeq rsrc_SERD_0_121A	| 4086BD7A
    cmpw %d3,%d0	| 4086BD7C
    jbls rsrc_SERD_0_11F2	| 4086BD7E
    movew %d3,%d0	| 4086BD80
rsrc_SERD_0_11F2:       /* set %d1 */
    movew %a2@(376),%d1	| 4086BD82
    movew %a2@(372),%d2	| 4086BD86
    moveal %a2@(368),%a1	| 4086BD8A
    subw %d0,%d3	| 4086BD8E
    subqw #1,%d0	| 4086BD90
rsrc_SERD_0_1202:       /* loop: move */
    moveb %a1@(0,%d1:w),%a3@+	| 4086BD92
    addqw #1,%d1	| 4086BD96
    cmpw %d1,%d2	| 4086BD98
    jbne rsrc_SERD_0_120E	| 4086BD9A
    clrw %d1	| 4086BD9C
rsrc_SERD_0_120E:       /* count down */
    dbf %d0,rsrc_SERD_0_1202	| 4086BD9E
    movew %d1,%a2@(376)	| 4086BDA2
    tstw %d3	| 4086BDA6
    jbeq rsrc_SERD_0_1248	| 4086BDA8
rsrc_SERD_0_121A:       /* test %a2@(462) */
    tstb %a2@(462)	| 4086BDAA
    jbne rsrc_SERD_0_1248	| 4086BDAE
    movew %a2@(458),%d0	| 4086BDB0
    jbeq rsrc_SERD_0_1248	| 4086BDB4
    cmpw %d3,%d0	| 4086BDB6
    jbls rsrc_SERD_0_122C	| 4086BDB8
    movew %d3,%d0	| 4086BDBA
rsrc_SERD_0_122C:       /* test %a2@(463) */
    tstb %a2@(463)	| 4086BDBC
    jbeq rsrc_SERD_0_1240	| 4086BDC0
    cmpw %a2@(460),%d0	| 4086BDC2
    jbls rsrc_SERD_0_1240	| 4086BDC6
    movew %a2@(460),%d0	| 4086BDC8
    st %a2@(462)	| 4086BDCC
rsrc_SERD_0_1240:       /* set %a0 */
    moveal %a3,%a0	| 4086BDD0
    jbsr rsrc_SERD_0_1370	| 4086BDD2
    subw %d0,%d3	| 4086BDD6
rsrc_SERD_0_1248:       /* set %a0 */
    moveal %a2@(10),%a0	| 4086BDD8
    moveal %a0@(8),%a0	| 4086BDDC
    movel %a0@(36),%d0	| 4086BDE0
    subl %d3,%d0	| 4086BDE4
    tstl %d3	| 4086BDE6
    seq %sp@	| 4086BDE8
    movel %d0,%a0@(40)	| 4086BDEA
rsrc_SERD_0_125E:       /* test %a2@(2) */
    tstb %a2@(2)	| 4086BDEE
    jbne rsrc_SERD_0_12CC	| 4086BDF2
    tstw %a2@(458)	| 4086BDF4
    jbeq rsrc_SERD_0_12CC	| 4086BDF8
    movew %a2@(374),%d0	| 4086BDFA
    subw %a2@(376),%d0	| 4086BDFE
    jbcc rsrc_SERD_0_1278	| 4086BE02
    addw %a2@(372),%d0	| 4086BE04
rsrc_SERD_0_1278:       /* set %d1 */
    movew %a2@(372),%d1	| 4086BE08
    subw %d0,%d1	| 4086BE0C
    subqw #1,%d1	| 4086BE0E
    jbeq rsrc_SERD_0_12CC	| 4086BE10
    movew %a2@(372),%d0	| 4086BE12
    subw %a2@(374),%d0	| 4086BE16
    cmpw %d1,%d0	| 4086BE1A
    jbls rsrc_SERD_0_1290	| 4086BE1C
    movew %d1,%d0	| 4086BE1E
rsrc_SERD_0_1290:       /* set %a0 */
    moveal %a2@(368),%a0	| 4086BE20
    addaw %a2@(374),%a0	| 4086BE24
    movew %d0,%d2	| 4086BE28
    jbsr rsrc_SERD_0_1370	| 4086BE2A
    jbeq rsrc_SERD_0_12CC	| 4086BE2E
    subw %d0,%d1	| 4086BE30
    subw %d0,%d2	| 4086BE32
    addw %a2@(374),%d0	| 4086BE34
    cmpw %a2@(372),%d0	| 4086BE38
    jbcs rsrc_SERD_0_12B2	| 4086BE3C
    subw %a2@(372),%d0	| 4086BE3E
rsrc_SERD_0_12B2:       /* set %a2@(374) */
    movew %d0,%a2@(374)	| 4086BE42
    tstw %d2	| 4086BE46
    jbne rsrc_SERD_0_12CC	| 4086BE48
    movew %d1,%d0	| 4086BE4A
    jbeq rsrc_SERD_0_12CC	| 4086BE4C
    moveal %a2@(368),%a0	| 4086BE4E
    jbsr rsrc_SERD_0_1370	| 4086BE52
    jbeq rsrc_SERD_0_12CC	| 4086BE56
    movew %d0,%a2@(374)	| 4086BE58
rsrc_SERD_0_12CC:       /* test %a2@(2) */
    tstb %a2@(2)	| 4086BE5C
    jbne rsrc_SERD_0_12F8	| 4086BE60
    tstb %a2@(462)	| 4086BE62
    jbne rsrc_SERD_0_12DE	| 4086BE66
    tstw %a2@(456)	| 4086BE68
    jbeq rsrc_SERD_0_12F8	| 4086BE6C
rsrc_SERD_0_12DE:       /* from here: st %a2@(2) */
    st %a2@(2)	| 4086BE6E
    movew %a2@(456),%a2@(288)	| 4086BE72
    tstb %a2@(462)	| 4086BE78
    jbeq rsrc_SERD_0_12F2	| 4086BE7C
    st %a2@(290)	| 4086BE7E
rsrc_SERD_0_12F2:       /* address %a2@(50) */
    lea %a2@(50),%a0	| 4086BE82
    _IOPMsgRequest	| 4086BE86
rsrc_SERD_0_12F8:       /* set %sp@- */
    movew %sr,%sp@-	| 4086BE88
    oriw #1792,%sr	| 4086BE8A
    tstb %a2@(5)	| 4086BE8E
    jbeq rsrc_SERD_0_130E	| 4086BE92
    clrb %a2@(5)	| 4086BE94
    movew %sp@+,%sr	| 4086BE98
    jbra rsrc_SERD_0_11AA	| 4086BE9A
rsrc_SERD_0_130E:       /* set %d0 */
    movel %a2@(10),%d0	| 4086BE9E
    jbeq rsrc_SERD_0_1326	| 4086BEA2
    movew #-27,%d0	| 4086BEA4
    tstb %a2@(462)	| 4086BEA8
    jbne rsrc_SERD_0_1334	| 4086BEAC
    clrw %d0	| 4086BEAE
    tstw %sp@(2)	| 4086BEB0
    jbne rsrc_SERD_0_1334	| 4086BEB4
rsrc_SERD_0_1326:       /* clear %a2@(462) */
    clrb %a2@(462)	| 4086BEB6
    clrb %a2@(4)	| 4086BEBA
    movew %sp@+,%sr	| 4086BEBE
    tstw %sp@+	| 4086BEC0
    rts	| 4086BEC2
rsrc_SERD_0_1334:       /* clear %a2@(462) */
    clrb %a2@(462)	| 4086BEC4
    clrw %sp@(2)	| 4086BEC8
    moveal %a2@(10),%a1	| 4086BECC
    clrl %a2@(10)	| 4086BED0
    movew %sp@+,%sr	| 4086BED4
    movel %a2,%sp@-	| 4086BED6
    moveal JIODone,%a0	| 4086BED8
    jsr %a0@	| 4086BEDC
    moveal %sp@+,%a2	| 4086BEDE
    movew %sr,%sp@-	| 4086BEE0
    oriw #1792,%sr	| 4086BEE2
    tstb %a2@(5)	| 4086BEE6
    jbeq rsrc_SERD_0_1366	| 4086BEEA
    clrb %a2@(5)	| 4086BEEC
    movew %sp@+,%sr	| 4086BEF0
    jbra rsrc_SERD_0_11AA	| 4086BEF2
rsrc_SERD_0_1366:       /* clear %a2@(4) */
    clrb %a2@(4)	| 4086BEF6
    movew %sp@+,%sr	| 4086BEFA
    tstw %sp@+	| 4086BEFC
    rts	| 4086BEFE

/* subroutine (45 instructions): traps IOPMoveData (mechanical summary) */
rsrc_SERD_0_1370:       /* save registers */
    moveml %d1-%d3/%a3,%sp@-
    movew %d0,%d3
    moveal %a0,%a3
    movew %a2@(448),%d2
    jbeq rsrc_SERD_0_1370_38
    cmpw %d3,%d2
    jbls rsrc_SERD_0_1370_14
    movew %d3,%d2
rsrc_SERD_0_1370_14:    /* from here: subw %d2,%d3 */
    subw %d2,%d3
    movel %a3,%a2@(250)
    movew %a2@(450),%a2@(254)
    movew %d2,%a2@(248)
    addaw %d2,%a3
    subw %d2,%a2@(448)
    addw %d2,%a2@(450)
    lea %a2@(246),%a0
    _IOPMoveData
    tstw %d3
    jbeq rsrc_SERD_0_1370_62
rsrc_SERD_0_1370_38:    /* set %d1 */
    movew %a2@(452),%d1
    jbeq rsrc_SERD_0_1370_62
    cmpw %d3,%d1
    jbls rsrc_SERD_0_1370_44
    movew %d3,%d1
rsrc_SERD_0_1370_44:    /* set %a2@(250) */
    movel %a3,%a2@(250)
    movew %a2@(454),%a2@(254)
    movew %d1,%a2@(248)
    subw %d1,%a2@(452)
    addw %d1,%a2@(454)
    addw %d1,%d2
    lea %a2@(246),%a0
    _IOPMoveData
rsrc_SERD_0_1370_62:    /* set %d0 */
    movew %d2,%d0
    jbeq rsrc_SERD_0_1370_82
    addw %d0,%a2@(456)
    subw %d0,%a2@(458)
    tstb %a2@(463)
    jbeq rsrc_SERD_0_1370_82
    subw %d0,%a2@(460)
    jbcc rsrc_SERD_0_1370_82
    clrb %a2@(463)
    st %a2@(290)
rsrc_SERD_0_1370_82:    /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a3
    tstw %d0
    rts

/* subroutine (10 instructions) (mechanical summary) */
rsrc_SERD_0_13FA:       /* set %sp@- */
    movew %sr,%sp@-	| 4086BF8A
    oriw #1792,%sr	| 4086BF8C
    movel %a2@(364),%d0	| 4086BF90
    jbeq rsrc_SERD_0_1410	| 4086BF94
    moveal %d0,%a3	| 4086BF96
    movel %a2,%a3@(24)	| 4086BF98
    movel %a3@,%a2@(364)	| 4086BF9C
rsrc_SERD_0_1410:       /* set %sr */
    movew %sp@+,%sr	| 4086BFA0
    tstl %d0	| 4086BFA2
    rts	| 4086BFA4

/* subroutine (8 instructions) (mechanical summary) */
rsrc_SERD_0_1416:       /* set %a1 */
    moveal %sp@+,%a1	| 4086BFA6
    moveal SCCRd,%a0	| 4086BFA8
    addqw #2,%a0	| 4086BFAC
rsrc_SERD_0_141E:       /* loop: btst */
    btst #0,%a0@	| 4086BFAE
    jbeq rsrc_SERD_0_1428	| 4086BFB2
    moveb %fp@,%sp@-	| 4086BFB4
    jbra rsrc_SERD_0_141E	| 4086BFB6
rsrc_SERD_0_1428:       /* jump through %a1@ */
    jmp %a1@	| 4086BFB8

/* subroutine (3 instructions) (mechanical summary) */
rsrc_SERD_0_142A:       /* set %sp@- */
    movel %d1,%sp@-	| 4086BFBA
    moveq #2,%d1	| 4086BFBC
    jbra rsrc_SERD_0_1434	| 4086BFBE

/* subroutine (17 instructions): traps trap_A685; calls rsrc_SERD_0_145A (mechanical summary) */
rsrc_SERD_0_1430:       /* set %sp@- */
    movel %d1,%sp@-	| 4086BFC0
    moveq #0,%d1	| 4086BFC2
rsrc_SERD_0_1434:       /* test #1,%d0 */
    cmpib #1,%d0	| 4086BFC4
    jbne rsrc_SERD_0_143C	| 4086BFC8
    jbsr rsrc_SERD_0_145A	| 4086BFCA
rsrc_SERD_0_143C:       /* test #2,%d0 */
    cmpib #2,%d0	| 4086BFCC
    jbne rsrc_SERD_0_144C	| 4086BFD0
    movel %d1,%d0	| 4086BFD2
    bset #7,%d0	| 4086BFD4
    .short  0xA685	| 4086BFD8 4086BFD8 A-line trap
    jbra rsrc_SERD_0_1456	| 4086BFDA
rsrc_SERD_0_144C:       /* test #3,%d0 */
    cmpib #3,%d0	| 4086BFDC
    jbne rsrc_SERD_0_1456	| 4086BFE0
    movel %d1,%d0	| 4086BFE2
    .short  0xA685	| 4086BFE4 4086BFE4 A-line trap
rsrc_SERD_0_1456:
    movel %sp@+,%d1	| 4086BFE6
    rts	| 4086BFE8

/* subroutine (24 instructions): traps PMgrOp; low memory PortAUse, PortBUse (mechanical summary) */
rsrc_SERD_0_145A:       /* save registers */
    moveml %d2/%a0,%sp@-
    subaw #16,%sp
    lea %sp@(12),%a0
    movel %a0,%sp@(8)
    movel %a0,%sp@(4)
    moveal %sp,%a0
    moveq #5,%d0
    moveb PortAUse,%d2
    orb PortBUse,%d2
    jbpl rsrc_SERD_0_145A_42
    tstb %d1
    jbeq rsrc_SERD_0_145A_42
    movew #88,%a0@
    clrw %a0@(2)
    _PMgrOp
    moveb %a0@(12),%d2
    moveq #5,%d0
    andib #7,%d2
    cmpib #7,%d2
    jbne rsrc_SERD_0_145A_42
    moveq #0,%d0
rsrc_SERD_0_145A_42:    /* address %sp@(16) */
    lea %sp@(16),%sp
    moveml %sp@+,%d2/%a0
    rts

/* subroutine (6 instructions): traps PMgrOp; low memory HWCfgFlags (mechanical summary) */
rsrc_SERD_0_14A6:       /* test bit 0 of HWCfgFlags */
    btst #0,HWCfgFlags
    jbeq rsrc_SERD_0_14A6_C
    moveb %d1,%d0
    .short  0xA685	| 4086C040 _PMgrOp (flags 0x0600)
rsrc_SERD_0_14A6_C:     /* set %d0 */
    moveb #2,%d0
    rorw %d2,%d0
    rts

/* subroutine (8 instructions): traps PMgrOp; low memory HWCfgFlags (mechanical summary) */
rsrc_SERD_0_14BA:       /* jump through %a0@(2) */
    jsr %a0@(2)
    tstw %d0
    jbne rsrc_SERD_0_14BA_16
    btst #0,HWCfgFlags
    jbeq rsrc_SERD_0_14BA_14
    clrb %d0
    .short  0xA685	| 4086C05C _PMgrOp (flags 0x0600)
rsrc_SERD_0_14BA_14:    /* clear %d0 */
    moveq #0,%d0
rsrc_SERD_0_14BA_16:    /* return */
    rts

/* subroutine (8 instructions): low memory HWCfgFlags (mechanical summary) */
rsrc_SERD_0_14D2:       /* set %a0 */
    moveal %sp@+,%a0
    btst #0,HWCfgFlags
    jbeq rsrc_SERD_0_14D2_E
    pea %pc@(rsrc_SERD_0_142A)
rsrc_SERD_0_14D2_E:     /* set %d1 */
    moveq #2,%d1
    moveq #-9,%d2
    moveq #-126,%d3
    jmp %a0@

/* subroutine (8 instructions): low memory HWCfgFlags (mechanical summary) */
rsrc_SERD_0_14E8:       /* set %a0 */
    moveal %sp@+,%a0
    btst #0,HWCfgFlags
    jbeq rsrc_SERD_0_14E8_E
    pea %pc@(rsrc_SERD_0_1430)
rsrc_SERD_0_14E8_E:     /* clear %d1 */
    moveq #0,%d1
    moveq #23,%d2
    moveq #66,%d3
    jmp %a0@

/* subroutine (11 instructions): traps Sleep; low memory HWCfgFlags (mechanical summary) */
rsrc_SERD_0_14FE:       /* set %a4 */
    moveal %sp@+,%a4
    btst #0,HWCfgFlags
    jbeq rsrc_SERD_0_14FE_1E
    lea %a2@(144),%a0
    movel %sp@+,%a0@(6)
    movew #16,%a0@(4)
    clrw %a0@(10)
    .short  0xA28A	| 4086C0AA _Sleep (flags 0x0200)
rsrc_SERD_0_14FE_1E:    /* set %a0 */
    moveal %sp@+,%a0
    movel %a0@,%a3@+
    movel %sp@+,%a0@
    jmp %a4@

/* subroutine (8 instructions): traps Sleep, DisposHandle; low memory HWCfgFlags (mechanical summary) */
rsrc_SERD_0_1524:       /* test bit 0 of HWCfgFlags */
    btst #0,HWCfgFlags
    jbeq rsrc_SERD_0_1524_E
    lea %a2@(144),%a0
    .short  0xA48A	| 4086C0C0 _Sleep (flags 0x0400)
rsrc_SERD_0_1524_E:     /* set up and call _DisposHandle */
    moveal %a1@(20),%a0
    _DisposHandle
    clrl %a1@(20)
    clrl %fp@
    rts

/* subroutine (8 instructions): traps PMgrOp; low memory HWCfgFlags (mechanical summary) */
rsrc_SERD_0_1540:       /* test bit 0 of HWCfgFlags */
    btst #0,HWCfgFlags
    jbeq rsrc_SERD_0_1540_18
    moveq #0,%d0
    bset #7,%d0
    tstl %d3
    jbeq rsrc_SERD_0_1540_16
    orib #4,%d0
rsrc_SERD_0_1540_16:    /* (_PMgrOp (flags 0x0600)) */
    .short  0xA685	| 4086C0E6 _PMgrOp (flags 0x0600)
rsrc_SERD_0_1540_18:    /* return */
    rts
    .fill   0x2C6, 1, 0x00
