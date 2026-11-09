/* ROM resource 'ltlk' 0: map entry at 0x408DBCC0, data at 0x408DBCF0, 4004 bytes

 LocalTalk through the SCC directly, port B ('ltlk' 0, "SCC LocalTalk B v57.0.4"), (c) Apple 1984-1992.
 Loaded by the LAP Manager (lmgr 0) for the network connection chosen in parameter RAM;
 .MPP sends and receives through it. Comments inferred; routines summarised mechanically.
*/

rsrc_ltlk_0_entry:      /* map entry */
    .long   0x38000000, 0x00000000	| 408DBCC0
    .long   rsrc_atlk_1_entry-rom_start	| 408DBCC8
    .long   rsrc_ltlk_0-rom_start	| 408DBCCC
    .ascii  "ltlk"	| 408DBCD0
    .byte   0x00, 0x00, 0x58, 0x00	| 408DBCD4
    FILL_408DBCD8
    .byte   0xC0, 0xA0, 0x00, 0x00	| 408DBCE4
    .short  0x0000, 0x0FB0	| orib #0xb0,%d0
    .short  0x0000, 0x02DC	| orib #0xdc,%d0

/* subroutine (87 instructions): calls rsrc_ltlk_0_238, rsrc_ltlk_0_DDC, rsrc_ltlk_0_602, rsrc_ltlk_0_5FA, rsrc_ltlk_0_1D6 ...; low memory ExpandMem, SCCWr, ATalkHk2 (mechanical summary) */
rsrc_ltlk_0:
    jbra rsrc_ltlk_0_3A
    bras rsrc_ltlk_0_E
    .short  0x0008	| .short 0x0008
    .short  0x00EC	| .short 0x00ec
    bset %d1,%a2@
    .short  0x0614, 0x0682	| 408DBCFA addib #0x82,%a4@
rsrc_ltlk_0_E:
    cmpiw #11,%d0
    bhis rsrc_ltlk_0_1E_18	| 408DBD02
    lslw #1,%d0
    movew %pc@(rsrc_ltlk_0_1E,%d0:w),%d0
    jmp %pc@(rsrc_ltlk_0_1E,%d0:w)
rsrc_ltlk_0_1E:
    .short  0x0018, 0x011A	| orib #26,%a0@+
    bclr %d0,%a2@+
    .short  0x03FC	| .short 0x03fc
    orib #24,%a0@+
    .short  0x0018, 0x0130	| orib #48,%a0@+
    bchg %d0,%a4@
    .byte   0x04, 0x4A, 0x04, 0xE4, 0x0D, 0x7E	| 408DBD20
rsrc_ltlk_0_1E_18:
    moveq #-1,%d0	| 408DBD26
    rts

rsrc_ltlk_0_3A:         /* set %a3 */
    moveal ExpandMem,%a3
    moveal %a3@(112),%a3
    moveml %d2/%a0-%a2,%a3@(708)
    exg %a2,%a3
    tstb %d0
    jbeq rsrc_ltlk_0_3A_A6
    tstb %a2@(698)
    jbne rsrc_ltlk_0_3A_38
    movel %a3,%a2@(700)
    movel %a1,%a2@(742)
    jbsr rsrc_ltlk_0_238
    moveb #0xff,%d0
    movew #-1,%d1
    jbsr rsrc_ltlk_0_DDC
    st %a2@(698)
rsrc_ltlk_0_3A_38:      /* from here: st %a2@(1546) */
    st %a2@(1546)
    moveb %a2@,%d0
    clrw %d1
    jbsr rsrc_ltlk_0_DDC
    moveb %d2,%a2@
    moveb %d3,%d0
    movew #-32768,%d1
    jbsr rsrc_ltlk_0_DDC
    moveal SCCWr,%a1
    moveb #6,%a1@
    nop
    moveb %a2@,%a1@
    jbsr rsrc_ltlk_0_602
    clrw %d0
    moveb %a2@,%d0
    addw %d0,%d0
    lea %a2@(1754),%a3
    addaw %d0,%a3
    cmpiw #-32767,%a3@
    jbne rsrc_ltlk_0_3A_9A
    moveq #12,%d0
    moveal ATalkHk2,%a3
    moveb %a2@(740),%d4
    movel %a2,%sp@-
    moveal %a2@(700),%a2
    jsr %a3@(2)
    tstw %d0
    jbeq rsrc_ltlk_0_3A_90
    moveq #5,%d0
    jsr %a3@(2)
rsrc_ltlk_0_3A_90:      /* set %a2 */
    moveal %sp@+,%a2
    clrw %a3@
    clrw %a2@(1752)
    jbra rsrc_ltlk_0_3A_AA
rsrc_ltlk_0_3A_9A:      /* set %a3@ */
    movew #-1,%a3@
    movew #1,%a2@(1752)
    jbra rsrc_ltlk_0_3A_AA
rsrc_ltlk_0_3A_A6:      /* call rsrc_ltlk_0_5FA */
    jbsr rsrc_ltlk_0_5FA
rsrc_ltlk_0_3A_AA:      /* set %d2/%a0-%a2 */
    moveml %a2@(708),%d2/%a0-%a2
    jmp %a0@
    movew %d4,%a4@-
    orb %d0,%d0
    .short  0x0000, 0x0835	| orib #53,%d0
    movew %fp@(12334),%a3@-
    movew %a0@-,%d2
    movel %d0,%d0
    movew %a3@,%a5@(17219)
    moveal %a4,%a0
    .short  0x6F63	| bles 408dbe57 <rsrc_ltlk_0_3A_AA+0x83>
    bsrs rsrc_ltlk_0_3A_136_2
    addqw #2,%a1@-
    .short  0x6C6B	| bges 408dbe65 <rsrc_ltlk_0_3A_136+0x5>
    moveal %d2,%a0
    .short  0x2076, 0x3537, 0x2E30, 0x2E34, 0x2020, 0x3B20	| moveal %fp@(2e302e34)@(20203b20,%d3:w:4),%a0
    .short  0xA920	| .short 0xa920
    .short  0x4170	| .short 0x4170
    moveq #108,%d0
    .short  0x6520	| bcss 408dbe30 <rsrc_ltlk_0_3A_AA+0x5c>
    .short  0x436F	| .short 0x436f
    blts rsrc_ltlk_0_3A_136_24
    .short  0x7574	| .short 0x7574
    .short  0x6572	| bcss 408dbe8a <rsrc_ltlk_0_3A_136_24+0x6>
    movel %a0@-,%d6
    .short  0x496E	| .short 0x496e
    .short  0x632E	| blss 408dbe4c <rsrc_ltlk_0_3A_AA+0x78>
    .short  0x2031, 0x3938, 0x342D, 0x3139	| movel %a1@(342d3139,%d3:l),%d0
    movew %a2@(-25,%d4:l),%a4@-
    nbcd %d0
    lea %pc@(rsrc_ltlk_0),%a0
    .short  0xA128	| 408DBE30 _RecoverHandle (flags 0x0100)
    movel %a0,%sp@-
    _DetachResource
    moveml %sp@+,%d1/%d4
    clrw %d0
    rts
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    jbsr rsrc_ltlk_0_1D6
    jbne rsrc_ltlk_0_3A_136
    lea %pc@(rsrc_ltlk_0_44C),%a0
    movel %a0,%a2@(1746)
    moveal ATalkHk2,%a1
    lea %a2@(1740),%a0
    moveq #23,%d0
    jsr %a1@(2)
rsrc_ltlk_0_3A_136:     /* return */
    rts
rsrc_ltlk_0_3A_136_2:
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    moveml %d1/%a2,%sp@-
    lea %a2@(1740),%a0
    moveal ATalkHk2,%a1
    moveq #24,%d0
    jsr %a1@(2)
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
rsrc_ltlk_0_3A_136_24:
    lea %a2@(1754),%a0
    movel #253,%d0
    addqw #2,%d0
    moveq #0,%d1
rsrc_ltlk_0_3A_168:     /* loop: clr */
    clrw %a0@(0x0,%d1:w)
    addqw #2,%d1
    dbf %d0,rsrc_ltlk_0_3A_168
    clrw %a2@(1752)
    moveml %sp@+,%d1/%a2
    jbsr rsrc_ltlk_0_1F2
    rts
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    movel %a2,%sp@-
    bsrs rsrc_ltlk_0_1F2
    moveal %sp@,%a2
    moveal ATalkHk2,%a1
    moveq #3,%d0
    jsr %a1@(2)
    moveal %sp@+,%a0
    _DisposPtr
    rts

/* subroutine (10 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_ltlk_0_1D6:
    moveml %d1/%a1,%sp@-
    moveal ATalkHk2,%a1
    moveq #17,%d0
    moveq #1,%d1
    jsr %a1@(2)
    moveml %sp@+,%d1/%a1
    jbne rsrc_ltlk_0_1D6_18
    moveq #0,%d0
rsrc_ltlk_0_1D6_18:     /* test %d0 */
    tstw %d0
    rts

/* subroutine (21 instructions): traps VRemove, PMgrOp; calls rsrc_ltlk_0_394; low memory ExtStsDT, HWCfgFlags, ATalkHk2 (mechanical summary) */
rsrc_ltlk_0_1F2:
    tstb %a2@(698)
    jbeq rsrc_ltlk_0_1F2_44
    lea %pc@(rsrc_ltlk_0_40E),%a0
    jbsr rsrc_ltlk_0_394
    lea %a2@(658),%a0
    _VRemove
    lea %a2@(1600),%a0
    lea Lvl2DT_2,%a3
    movel %a0@+,%a3@+
    movel %a0@+,%a3@+
    movel %a0@+,ExtStsDT
    clrb %a2@(698)
    btst #8,HWCfgFlags
    jbeq rsrc_ltlk_0_1F2_38
    moveq #0,%d0
    bset #7,%d0
    .short  0xA685	| 408DBF18 _PMgrOp (flags 0x0600)
rsrc_ltlk_0_1F2_38:     /* set %d0 */
    moveq #18,%d0
    moveq #1,%d1
    moveal ATalkHk2,%a1
    jsr %a1@(2)
rsrc_ltlk_0_1F2_44:     /* return */
    rts

/* subroutine (60 instructions): traps PMgrOp, SysEnvirons, VInstall; calls rsrc_ltlk_0_312, rsrc_ltlk_0_312_78; low memory HWCfgFlags, ROMBase, SCCRd, ExtStsDT (mechanical summary) */
rsrc_ltlk_0_238:
    moveml %d0-%d5/%a0-%fp,%sp@-
    btst #8,HWCfgFlags
    jbeq rsrc_ltlk_0_238_10
    moveq #1,%d0
    .short  0xA685	| 408DBF36 _PMgrOp (flags 0x0600)
rsrc_ltlk_0_238_10:     /* set up and call _SysEnvirons */
    subaw #16,%sp
    moveal %sp,%a0
    moveq #1,%d0
    _SysEnvirons
    movew %a0@(2),%d0
    addqw #2,%d0
    movew %d0,%a2@(1658)
    addaw #16,%sp
    moveal ROMBase,%a3
    moveal VIA,%a1
    lea %a1@(7680),%a1
    cmpib #3,%a3@(8)
    jbne rsrc_ltlk_0_238_42
    subaw #7680,%a1
    jbra rsrc_ltlk_0_238_52
rsrc_ltlk_0_238_42:     /* test #13,%a2@(1658) */
    cmpiw #13,%a2@(1658)
    jbne rsrc_ltlk_0_238_52
    moveal SCCRd,%a1
    lea %a1@(-28),%a1
rsrc_ltlk_0_238_52:     /* set %a2@(1632) */
    movel %a1,%a2@(1632)
    lea %pc@(rsrc_ltlk_0_3CA),%a0
    movel %a0@+,%a2@(1636)
    movew %a0@+,%a2@(1640)
    movew %a0@+,%a2@(28)
    cmpib #117,%a3@(9)
    jbeq rsrc_ltlk_0_238_84
    cmpib #118,%a3@(9)
    jbeq rsrc_ltlk_0_238_84
    cmpib #122,%a3@(9)
    jbeq rsrc_ltlk_0_238_84
    movew #8960,%a2@(28)
rsrc_ltlk_0_238_84:     /* call rsrc_ltlk_0_312 */
    jbsr rsrc_ltlk_0_312
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    lea Lvl2DT_2,%a3
    lea %a2@(1600),%a1
    lea %pc@(rsrc_ltlk_0_A16_8),%a0
    movel %a3@,%a1@+
    movel %a0,%a3@+
    lea %pc@(rsrc_ltlk_0_BD4_6),%a0
    movel %a3@,%a1@+
    movel %a0,%a3@+
    lea %pc@(rsrc_ltlk_0_7B4),%a0
    movel ExtStsDT,%a1@
    movel %a0,ExtStsDT
    lea %a2@(658),%a0
    movew #1,%a0@(4)
    lea %pc@(rsrc_ltlk_0_84E),%a1
    movel %a1,%a0@(6)
    movew #20,%a0@(10)
    _VInstall
    jbsr rsrc_ltlk_0_312_78
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d5/%a0-%fp
    rts

/* subroutine (45 instructions): traps BlockMove; calls rsrc_ltlk_0_DF0, rsrc_ltlk_0_EC0; low memory ROMBase (mechanical summary) */
rsrc_ltlk_0_312:
    moveml %d3/%d6-%d7,%sp@-
    moveal ROMBase,%a3
    cmpib #117,%a3@(9)
    jbhi rsrc_ltlk_0_312_1E
    moveq #20,%d0
    lea %pc@(rsrc_ltlk_0_3D2),%a0
    lea %a2@(1556),%a1
    _BlockMove
    jbra rsrc_ltlk_0_312_72
rsrc_ltlk_0_312_1E:     /* call rsrc_ltlk_0_DF0 */
    jbsr rsrc_ltlk_0_DF0
    moveq #0,%d7
    movew %d0,%d7
    jbsr rsrc_ltlk_0_EC0
    moveq #0,%d6
    movew %d0,%d6
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    moveq #20,%d0
    lea %a2@(1556),%a1
    moveq #0,%d1
    movew %d7,%d1
    divuw #100,%d1
    lea %pc@(rsrc_ltlk_0_3E6),%a0
rsrc_ltlk_0_312_4A:     /* loop: move */
    movew %a0@+,%d3
    moveq #0,%d2
    moveb %a0@+,%d2
    divuw %d1,%d2
    subw %d2,%d3
    tstb %a0@+
    jbmi rsrc_ltlk_0_312_6C
    muluw %d7,%d3
rsrc_ltlk_0_312_5A:     /* loop: divu */
    divuw #1000,%d3
    subqw #1,%d3
    jbpl rsrc_ltlk_0_312_64
    moveq #0,%d3
rsrc_ltlk_0_312_64:     /* set %a1@+ */
    movew %d3,%a1@+
    subqw #2,%d0
    jbne rsrc_ltlk_0_312_4A
    jbra rsrc_ltlk_0_312_70
rsrc_ltlk_0_312_6C:     /* from here: muluw %d6,%d3 */
    muluw %d6,%d3
    jbra rsrc_ltlk_0_312_5A
rsrc_ltlk_0_312_70:     /* set %sr */
    movew %sp@+,%sr
rsrc_ltlk_0_312_72:     /* restore registers, return */
    moveml %sp@+,%d3/%d6-%d7
    rts

/* subroutine (3 instructions): calls rsrc_ltlk_0_394 (mechanical summary) */
rsrc_ltlk_0_312_78:
    lea %pc@(rsrc_ltlk_0_3A6),%a0
    jbsr rsrc_ltlk_0_394
    lea %pc@(rsrc_ltlk_0_3C2),%a0

/* subroutine (93 instructions): calls rsrc_ltlk_0_312, rsrc_ltlk_0_238, rsrc_ltlk_0_544, rsrc_ltlk_0_572, rsrc_ltlk_0_DDC ...; low memory SCCWr, ExpandMem (mechanical summary) */
rsrc_ltlk_0_394:
    moveal SCCWr,%a3
rsrc_ltlk_0_394_4:      /* loop: move */
    movew %a0@+,%d0
    jbeq rsrc_ltlk_0_394_10
    moveb %d0,%a3@
    rorw #8,%d0
    moveb %d0,%a3@
    jbra rsrc_ltlk_0_394_4
rsrc_ltlk_0_394_10:     /* return */
    rts
rsrc_ltlk_0_3A6:        /* (data) */
    .byte   0x40, 0x09, 0x20, 0x04, 0xE0, 0x0A, 0x00, 0x06, 0x7E, 0x07, 0x06, 0x0C, 0x00, 0x0D, 0xC0, 0x0E	| 408DC096
    .byte   0xDD, 0x03, 0x00, 0x02, 0x08, 0x0F, 0x09, 0x01, 0x0A, 0x09, 0x00, 0x00	| 408DC0A6
rsrc_ltlk_0_3C2:        /* set %d0 */
    moveq #11,%d0	| 408DC0B2
    movel %fp,%a0@-	| 408DC0B4
    jbra rsrc_ltlk_0_3CD	| 408DC0B6
    .byte   0x00, 0x00	| 408DC0B8
rsrc_ltlk_0_3CA:        /* (data) */
    .byte   0x05, 0x60, 0x0E	| 408DC0BA
rsrc_ltlk_0_3CD:        /* (data) */
    .byte   0x41, 0x03, 0xDD, 0x21, 0x00	| 408DC0BD
rsrc_ltlk_0_3D2:        /* (data) */
    .byte   0x00, 0x35, 0x00, 0x14, 0x00, 0x1E, 0x00, 0x82, 0x00, 0x66, 0x00, 0x10, 0x00, 0x00, 0x00, 0x39	| 408DC0C2
    .byte   0x00, 0x00, 0x00, 0x00	| 408DC0D2
rsrc_ltlk_0_3E6:        /* (data) */
    .byte   0x00, 0x73, 0x3A, 0x00, 0x00, 0x64, 0x00, 0xFF, 0x00, 0xC8, 0x00, 0xFF, 0x01, 0xF4, 0x00, 0xFF	| 408DC0D6
    .byte   0x01, 0x90, 0x72, 0xFF, 0x00, 0x46, 0x2C, 0x00, 0x00, 0x1E, 0x00, 0x00, 0x00, 0x64, 0x5A, 0x00	| 408DC0E6
    .byte   0x00, 0x3C, 0xFF, 0x00, 0x00, 0x0A, 0x40, 0x00	| 408DC0F6
rsrc_ltlk_0_40E:        /* (data) */
    .byte   0x4A, 0x09, 0x00, 0x0A, 0x10, 0x00, 0x08, 0x0F, 0x01, 0x01, 0x00, 0x00, 0x0C, 0x41, 0x00, 0x16	| 408DC0FE
    .byte   0x6D, 0x1C, 0x20, 0x09, 0x47, 0xFA, 0x00, 0x1C, 0x22, 0xDB, 0x22, 0xDB, 0x42, 0x99, 0x32, 0xDB	| 408DC10E
    .byte   0x42, 0x99, 0x42, 0x19, 0x12, 0xD2, 0x32, 0xDB, 0x22, 0x40, 0x42, 0x40, 0x4E, 0x75, 0x70, 0xFF	| 408DC11E
    .byte   0x4E, 0x75	| 408DC12E
    orib #22,%d3
    .short  0x0003, 0x9210	| orib #16,%d3
    orib #0xfe,%d1
rsrc_ltlk_0_44C:        /* set %d0 */
    movel %sp@(4),%d0
    cmpil #1936745828,%d0
    jbne rsrc_ltlk_0_464
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    jbsr rsrc_ltlk_0_312
rsrc_ltlk_0_464:        /* result 0 */
    moveq #0,%d0
    rts

rsrc_ltlk_0_468:        /* save registers */
    moveml %d1-%d3/%a0-%a3,%sp@-
    moveal ExpandMem,%a3
    moveal %a3@(112),%a3
    moveml %d2/%a0-%a2,%a3@(708)
    exg %a2,%a3
    movel %a0,%d3
    tstb %a2@(698)
    jbne rsrc_ltlk_0_468_2A
    movel %a0@(34),%a2@(700)
    jbsr rsrc_ltlk_0_238
    st %a2@(698)
rsrc_ltlk_0_468_2A:     /* test #253,%a2@(1752) */
    cmpiw #253,%a2@(1752)
    jbeq rsrc_ltlk_0_468_92
    moveb %a0@(31),%d2
    moveq #0,%d0
    moveb %d2,%d0
    addw %d0,%d0
    lea %a2@(1754),%a1
    addaw %d0,%a1
    movew %a1@,%d0
    jbne rsrc_ltlk_0_468_92
    tstw %a2@(1752)
    jbne rsrc_ltlk_0_468_64
    moveb %d2,%a2@
    movel %a1,%sp@-
    moveal SCCWr,%a1
    moveb #6,%a1@
    nop
    moveb %a2@,%a1@
    moveal %sp@+,%a1
    movew #-1,%a0@(42)
rsrc_ltlk_0_468_64:     /* add 1 to %a2@(1752) */
    addqw #1,%a2@(1752)
    movew #-32768,%a1@
    jbsr rsrc_ltlk_0_544
    moveb %d2,%d0
    jbsr rsrc_ltlk_0_572
    jbne rsrc_ltlk_0_468_8A
    movew %a0@(42),%a1@
    moveb #0xff,%d0
    movew #-1,%d1
    jbsr rsrc_ltlk_0_DDC
    moveq #0,%d0
    jbra rsrc_ltlk_0_468_94
rsrc_ltlk_0_468_8A:     /* clear %a1@ */
    clrw %a1@
    subqw #1,%a2@(1752)
    jbsr rsrc_ltlk_0_544
rsrc_ltlk_0_468_92:     /* set %d0 */
    moveq #-50,%d0
rsrc_ltlk_0_468_94:     /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a0-%a3
    rts

rsrc_ltlk_0_502:        /* save registers */
    moveml %d1-%d2/%a2,%sp@-
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    moveb %a0@(31),%d2
    moveb %d2,%d0
    jbeq rsrc_ltlk_0_502_3A
    cmpib #0xff,%d2
    jbeq rsrc_ltlk_0_502_3A
    cmpb %a2@,%d2
    jbeq rsrc_ltlk_0_502_3A
    jbsr rsrc_ltlk_0_DC4
    movew %d0,%a0@(42)
    jbeq rsrc_ltlk_0_502_3A
    moveb %d2,%d0
    moveq #0,%d1
    jbsr rsrc_ltlk_0_DDC
    subqw #1,%a2@(1752)
    jbsr rsrc_ltlk_0_544
    moveq #0,%d0
    jbra rsrc_ltlk_0_502_3C
rsrc_ltlk_0_502_3A:     /* set %d0 */
    moveq #-50,%d0
rsrc_ltlk_0_502_3C:     /* restore registers, return */
    moveml %sp@+,%d1-%d2/%a2
    rts

/* subroutine (14 instructions): calls rsrc_ltlk_0_C80 (mechanical summary) */
rsrc_ltlk_0_544:
    movel %a1,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    moveb #0xd9,%d1
    cmpiw #1,%a2@(1752)
    jbgt rsrc_ltlk_0_544_1C
    moveb #0xdd,%d1
rsrc_ltlk_0_544_1C:     /* set %a2@(1750) */
    moveb %d1,%a2@(1750)
    moveb %d1,%a2@(1641)
    jbsr rsrc_ltlk_0_C80
    movew %sp@+,%sr
    moveal %sp@+,%a1
    rts

/* subroutine (16 instructions): calls rsrc_ltlk_0_5A4 (mechanical summary) */
rsrc_ltlk_0_572:
    moveml %d1-%d4/%a2-%a3,%sp@-
    moveb %a0@(31),%d2
    movew %a0@(32),%d4
rsrc_ltlk_0_572_C:      /* save registers */
    moveml %d1-%d4/%a0-%a3,%sp@-
    jbsr rsrc_ltlk_0_5A4
    moveml %sp@+,%d1-%d4/%a0-%a3
rsrc_ltlk_0_572_16:     /* loop: tst */
    tstb %a2@(1546)
    jbne rsrc_ltlk_0_572_16
    cmpiw #-32767,%a1@
    dbeq %d4,rsrc_ltlk_0_572_C
    moveml %sp@+,%d1-%d4/%a2-%a3
    jbeq rsrc_ltlk_0_572_2E
    moveq #0,%d0
    rts
rsrc_ltlk_0_572_2E:     /* result 1 */
    moveq #1,%d0
    rts

/* subroutine (4 instructions): calls rsrc_ltlk_0_602 (mechanical summary) */
rsrc_ltlk_0_5A4:
    st %a2@(1546)
    jbsr rsrc_ltlk_0_602
    clrb %a2@(1546)
    rts

/* subroutine (11 instructions): calls rsrc_ltlk_0_5CC (mechanical summary) */
rsrc_ltlk_0_5B0:
    lea %a2@(1549),%a3
    moveb %a3@+,%d3
    moveb %a3@,%d2
    addb %d2,%a3@+
    jbsr rsrc_ltlk_0_5CC
    jble rsrc_ltlk_0_5CC_12
    addb %d3,%d3
    addqb #1,%d3
    andiw #15,%d3
    clrb %a3@(-1)
    jbra rsrc_ltlk_0_5CC_1C

/* subroutine (22 instructions): calls rsrc_ltlk_0_5CC (mechanical summary) */
rsrc_ltlk_0_5CC:
    moveq #0,%d0
    moveq #7,%d1
rsrc_ltlk_0_5CC_4:      /* loop: btst */
    btst %d1,%d2
    jbeq rsrc_ltlk_0_5CC_A
    addqw #1,%d0
rsrc_ltlk_0_5CC_A:      /* count down */
    dbf %d1,rsrc_ltlk_0_5CC_4
    subqb #2,%d0
    rts
rsrc_ltlk_0_5CC_12:     /* set %d2 */
    moveb %a3@,%d2
    jbsr rsrc_ltlk_0_5CC
    jbge rsrc_ltlk_0_5CC_1C
    lsrb #1,%d3
    st %a3@
rsrc_ltlk_0_5CC_1C:     /* set %d2 */
    moveb %a3@,%d2
    addb %d2,%a3@+
    moveq #32,%d0
    moveb %d0,%a3@+
    moveb %d0,%a3@
    subqw #5,%a3
    moveb %d3,%a3@+
    moveb %d3,%a3@+
    rts

/* subroutine (2 instructions) (mechanical summary) */
rsrc_ltlk_0_5FA:
    clrb %a2@(1546)
    movel %a1,%a2@(1532)

/* subroutine (79 instructions): calls rsrc_ltlk_0_5B0, rsrc_ltlk_0_8F4, rsrc_ltlk_0_70A, rsrc_ltlk_0_9BE, rsrc_ltlk_0_8D6; low memory SCCRd, SCCWr (mechanical summary) */
rsrc_ltlk_0_602:
    movel %sp@+,%a2@(1536)
    bset #2,%a2@(1734)
    moveb %d2,%a2@(1542)
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    btst #1,%a2@(1734)
    jbne rsrc_ltlk_0_602_F8
    movew %sp@+,%sr
rsrc_ltlk_0_602_24:     /* loop: bclr */
    bclr #2,%a2@(1734)
    jbeq rsrc_ltlk_0_602_2E
    jbsr rsrc_ltlk_0_5B0
rsrc_ltlk_0_602_2E:     /* set %a0 */
    moveal SCCRd,%a0
    moveal SCCWr,%a1
    movew %sr,%sp@-
rsrc_ltlk_0_602_38:     /* loop: move */
    movew %d0,%d3
    btst #4,%a0@
    jbeq rsrc_ltlk_0_602_82
    jbsr rsrc_ltlk_0_8F4
    andb %a2@(1548),%d0
    andiw #15,%d0
    movew %d0,%d3
    jbeq rsrc_ltlk_0_602_5A
rsrc_ltlk_0_602_50:     /* call rsrc_ltlk_0_70A (loop) */
    jbsr rsrc_ltlk_0_70A
    jbeq rsrc_ltlk_0_602_82
    subqw #1,%d0
    jbne rsrc_ltlk_0_602_50
rsrc_ltlk_0_602_5A:     /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    andiw #-257,%sr
    btst #1,%a2@(1734)
    jbne rsrc_ltlk_0_602_F8
    moveq #3,%d0
    addqw #3,%d3
rsrc_ltlk_0_602_70:     /* loop: move */
    moveb #14,%a1@
    nop
    moveb #65,%a1@
    jbsr rsrc_ltlk_0_70A
    dbeq %d0,rsrc_ltlk_0_602_70
rsrc_ltlk_0_602_82:     /* from here: jbeq rsrc_ltlk_0_70A_62 */
    jbeq rsrc_ltlk_0_70A_62
    moveb #10,%a1@
    moveb %a2@(1542),%d2
    tstb %a0@
    jbmi rsrc_ltlk_0_70A_62
    moveb #5,%a1@
    moveq #-124,%d0
    moveb #98,%a1@
    tstb %a2@(1546)
    jbeq rsrc_ltlk_0_602_AA
    moveq #-127,%d0
    moveb %a2@,%a2@(1738)
rsrc_ltlk_0_602_AA:     /* set %a1@ */
    moveb #5,%a1@
    nop
    moveb %a2@(1637),%a1@
    movew %a2@(1574),%d1
    moveal %a0,%a0
rsrc_ltlk_0_602_BA:     /* count down (loop) */
    dbf %d1,rsrc_ltlk_0_602_BA
    jbsr rsrc_ltlk_0_9BE
    addqb #1,%d2
    jbeq rsrc_ltlk_0_70A_14
    clrb %a2@(1544)
    jbsr rsrc_ltlk_0_8D6
    tstb %a2@(1546)
    jbeq rsrc_ltlk_0_602_EC
    moveq #0,%d0
    moveb %a2@(1542),%d0
    addw %d0,%d0
    lea %a2@(1754),%a3
    movew %a3@(0x0,%d0:w),%d0
    cmpiw #-32767,%d0
    jbne rsrc_ltlk_0_70A_3E
    jbra rsrc_ltlk_0_70A_28
rsrc_ltlk_0_602_EC:     /* test %a2@(1544) */
    tstb %a2@(1544)
    st %a2@(1544)
    jbeq rsrc_ltlk_0_70A_3E
    jbra rsrc_ltlk_0_70A_24
rsrc_ltlk_0_602_F8:     /* set bit 0 of %a2@(1734) */
    bset #0,%a2@(1734)
    movew %sp@+,%sr
    moveml %a2@(708),%d2/%a0-%a2
    rts

/* subroutine (132 instructions): traps DeferUserFn; calls rsrc_ltlk_0_70A, rsrc_ltlk_0_93E, rsrc_ltlk_0_C36; low memory ExpandMem, SCCRd, SCCWr (mechanical summary) */
rsrc_ltlk_0_70A:
    movew %a2@(1570),%d1
    jbra rsrc_ltlk_0_70A_C
rsrc_ltlk_0_70A_6:      /* count down (loop) */
    dbf %d1,rsrc_ltlk_0_70A_6
    jbra rsrc_ltlk_0_70A_E
rsrc_ltlk_0_70A_C:      /* continue at rsrc_ltlk_0_70A_6 */
    jbra rsrc_ltlk_0_70A_6
rsrc_ltlk_0_70A_E:      /* test bit 4 of %a0@ */
    btst #4,%a0@
    rts
rsrc_ltlk_0_70A_14:     /* call rsrc_ltlk_0_70A */
    jbsr rsrc_ltlk_0_70A
    jbeq rsrc_ltlk_0_70A_3E
    cmpiw #114,%a2@(1570)
    jbcs rsrc_ltlk_0_70A_24
    jbsr rsrc_ltlk_0_70A
    jbeq rsrc_ltlk_0_70A_3E
rsrc_ltlk_0_70A_24:     /* call rsrc_ltlk_0_93E */
    jbsr rsrc_ltlk_0_93E
rsrc_ltlk_0_70A_28:     /* clear %d0 */
    moveq #0,%d0
    addql #1,%a2@(1674)
rsrc_ltlk_0_70A_2E:     /* loop: move */
    movew %sp@+,%sr
    moveal %a2@(1536),%a0
    clrl %a2@(1536)
    clrl %a2@(1532)
    jmp %a0@
rsrc_ltlk_0_70A_3E:     /* add 1 to %a2@(1702) */
    addql #1,%a2@(1702)
    movew %sp@,%sr
    bset #0,%a2@(1550)
    moveb %a2@(1548),%d0
    addb %d0,%d0
    addqb #1,%d0
    moveb %d0,%a2@(1548)
    moveq #-95,%d0
    subqb #1,%a2@(1553)
    jbeq rsrc_ltlk_0_70A_2E
    jbra rsrc_ltlk_0_602_38
rsrc_ltlk_0_70A_62:     /* from here: subw %d0,%d3 */
    subw %d0,%d3
    subqw #4,%d3
    jblt rsrc_ltlk_0_70A_80
    addql #1,%a2@(1706)
    moveq #-95,%d0
    subqb #1,%a2@(1552)
    jbeq rsrc_ltlk_0_70A_2E
    bset #0,%a2@(1548)
    bset #0,%a2@(1551)
rsrc_ltlk_0_70A_80:     /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    andiw #-257,%sr
    moveb #15,%a1@
    moveb #0x88,%d0
    moveb %d0,%a1@
    bset #0,%a2@(1734)
    moveb #2,%a2@(1547)
    moveq #0,%d0
    moveml %a2@(708),%d2/%a0-%a2
rsrc_ltlk_0_70A_A6:     /* loop: move */
    movew %sp@+,%sr
    rts
rsrc_ltlk_0_7B4:        /* set %a2 */
    moveal ExpandMem,%a2	| 408DC4A4
    moveal %a2@(112),%a2	| 408DC4A8
    btst #3,%d1	| 408DC4AC
    jbeq rsrc_ltlk_0_7D0	| 408DC4B0
    moveb %d1,%sp@-	| 408DC4B2
    moveal 0x2c2,%a3	| 408DC4B4
    addql #1,%a2@(1730)	| 408DC4B8
    jsr %a3@	| 408DC4BC
    moveb %sp@+,%d1	| 408DC4BE
rsrc_ltlk_0_7D0:        /* test bit 7 of %d1 */
    btst #7,%d1	| 408DC4C0
    jbeq rsrc_ltlk_0_838	| 408DC4C4
    tstb %a2@(1547)	| 408DC4C6
    jbeq rsrc_ltlk_0_C36	| 408DC4CA
    moveb #15,%a1@	| 408DC4CE
    moveb #8,%d0	| 408DC4D2
    moveb %d0,%a1@	| 408DC4D6
    clrb %a2@(1547)	| 408DC4D8
    bclr #1,%a2@(1734)	| 408DC4DC
    bclr #0,%a2@(1734)	| 408DC4E2
    jbeq rsrc_ltlk_0_C36	| 408DC4E8
    movew %sr,%d0	| 408DC4EC
    andiw #-1793,%d0	| 408DC4EE
    eoriw #8192,%d0	| 408DC4F2
    movew %a2@(28),%sp@-	| 408DC4F6
    eorw %d0,%sp@	| 408DC4FA
    movew %sp@+,%sr	| 408DC4FC
    tstb %a2@(1735)	| 408DC4FE
    jbeq rsrc_ltlk_0_84A	| 408DC502
    lea %pc@(rsrc_ltlk_0_83A),%a0	| 408DC504
    movel %a2,%d0	| 408DC508
    _DeferUserFn	| 408DC50A
    jbeq rsrc_ltlk_0_838	| 408DC50C
    oriw #1792,%sr	| 408DC50E
    andiw #-257,%sr	| 408DC512
    tstl %a2@(1532)	| 408DC516
    jbeq rsrc_ltlk_0_838	| 408DC51A
    moveb #1,%a2@(1547)	| 408DC51C
    bset #0,%a2@(1734)	| 408DC522
rsrc_ltlk_0_838:        /* return */
    rts	| 408DC528
rsrc_ltlk_0_83A:        /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    moveal SCCRd,%a0
    moveal SCCWr,%a1
rsrc_ltlk_0_84A:        /* continue at rsrc_ltlk_0_602_24 */
    jbra rsrc_ltlk_0_602_24
rsrc_ltlk_0_84E:        /* set %a0@(10) */
    movew #20,%a0@(10)	| 408DC53E
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    moveal SCCRd,%a0
    moveal SCCWr,%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    tstb %a2@(1547)
    jbne rsrc_ltlk_0_894
    addqb #1,%a2@(1739)
    cmpib #30,%a2@(1739)
    jbne rsrc_ltlk_0_70A_A6
    clrb %a2@(1739)
    moveb #3,%a1@
    nop
    moveb %a2@(1750),%a1@
    jbra rsrc_ltlk_0_70A_A6
rsrc_ltlk_0_894:        /* subtract 1 to %a2@(1547) */
    subqb #1,%a2@(1547)
    jbne rsrc_ltlk_0_70A_A6
    moveb #15,%a1@
    moveb #8,%d0
    moveb %d0,%a1@
    jbsr rsrc_ltlk_0_C36
    addql #1,%a2@(1710)
    bclr #1,%a2@(1734)
    bclr #0,%a2@(1734)
    jbeq rsrc_ltlk_0_70A_A6
    addqw #2,%sp
    movew %sr,%d0
    andiw #-1793,%d0
    eoriw #8192,%d0
    movew %a2@(28),%sp@-
    eorw %d0,%sp@
    movew %sp@+,%sr
    jbra rsrc_ltlk_0_602_24

/* subroutine (9 instructions): calls rsrc_ltlk_0_A2C (mechanical summary) */
rsrc_ltlk_0_8D6:
    moveml %a0-%a3,%sp@-
    movew %a2@(1564),%d1
    moveal %a0,%a0
rsrc_ltlk_0_8D6_A:      /* loop: btst */
    btst #0,%a0@
    dbne %d1,rsrc_ltlk_0_8D6_A
    jbeq rsrc_ltlk_0_8D6_18
    jbsr rsrc_ltlk_0_A2C
rsrc_ltlk_0_8D6_18:     /* restore registers, return */
    moveml %sp@+,%a0-%a3
    rts

/* subroutine (9 instructions) (mechanical summary) */
rsrc_ltlk_0_8F4:
    movew %a2@(1540),%d0
    muluw #773,%d0
    addqw #1,%d0
    movew %d0,%sp@-
    lslw #8,%d0
    moveb %sp@+,%d0
    movew %d0,%a2@(1540)
    rts
rsrc_ltlk_0_90A:        /* from here: bchg %d2,%a3@(976) */
    bchg %d2,%a3@(976)	| 408DC5FA

/* subroutine (8 instructions) (mechanical summary) */
rsrc_ltlk_0_90E:
    movew %a2@(1560),%d1
    moveal %a0,%a0
rsrc_ltlk_0_90E_6:      /* loop: btst */
    btst #2,%a0@
    dbne %d1,rsrc_ltlk_0_90E_6
    jbeq rsrc_ltlk_0_90E_14
    moveb %d3,%a1@(4)
rsrc_ltlk_0_90E_14:     /* test %d1 */
    tstw %d1
    rts

/* subroutine (7 instructions): calls rsrc_ltlk_0_A16 (mechanical summary) */
rsrc_ltlk_0_926:
    lea %pc@(rsrc_ltlk_0_90A),%a3
    moveq #4,%d3
    jbsr rsrc_ltlk_0_A16
    movew %a2@(1566),%d3
rsrc_ltlk_0_926_E:      /* count down (loop) */
    dbf %d3,rsrc_ltlk_0_926_E
    moveb #0x80,%a1@
    rts

/* subroutine (42 instructions): calls rsrc_ltlk_0_926, rsrc_ltlk_0_A10, rsrc_ltlk_0_9EA; low memory DskRtnAdr, PollStack, PollProc, ExpandMem (mechanical summary) */
rsrc_ltlk_0_93E:
    moveml %a0-%a1/%a4-%fp,%a2@(1612)
    movel DskRtnAdr,%sp@-
    movel PollStack,%sp@-
    movel %sp,PollStack
    moveal %a2@(1632),%a5
    lea %a0@(6),%fp
    moveal %a2@(1532),%a4
    jbsr rsrc_ltlk_0_926
    movew %a4@+,%d3
    moveal %a4@+,%a3
    moveb %a3@+,%a1@(4)
    subqw #1,%d3
    moveb %a2@,%a3@
rsrc_ltlk_0_93E_2C:     /* loop: move */
    movew %a2@(1560),%d0
    moveal %a0,%a0
rsrc_ltlk_0_93E_32:     /* loop: btst */
    btst #2,%a0@
    dbne %d0,rsrc_ltlk_0_93E_32
    jbne rsrc_ltlk_0_93E_42
    jbsr rsrc_ltlk_0_A10
    jbra rsrc_ltlk_0_93E_5A
rsrc_ltlk_0_93E_42:     /* set %a1@(4) */
    moveb %a3@+,%a1@(4)
    tstb %a5@
    jbmi rsrc_ltlk_0_93E_4C
    moveb %fp@,%sp@-
rsrc_ltlk_0_93E_4C:     /* subtract 1 to %d3 */
    subqw #1,%d3
    jbgt rsrc_ltlk_0_93E_2C
    movew %a4@+,%d3
    jbeq rsrc_ltlk_0_93E_58
    moveal %a4@+,%a3
    jbra rsrc_ltlk_0_93E_2C
rsrc_ltlk_0_93E_58:     /* call rsrc_ltlk_0_9EA */
    jbsr rsrc_ltlk_0_9EA
rsrc_ltlk_0_93E_5A:     /* set %d3 */
    movel PollProc,%d3
    jbeq rsrc_ltlk_0_93E_6C
    moveal %d3,%a4
    jsr %a4@
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
rsrc_ltlk_0_93E_6C:     /* set %a0-%a1/%a4-%fp */
    moveml %a2@(1612),%a0-%a1/%a4-%fp
    moveal PollStack,%sp
    movel %sp@+,PollStack
    movel %sp@+,DskRtnAdr
    rts

/* subroutine (14 instructions): calls rsrc_ltlk_0_926, rsrc_ltlk_0_90E (mechanical summary) */
rsrc_ltlk_0_9BE:
    jbsr rsrc_ltlk_0_926
    moveb %d2,%a1@(4)
    moveb %d2,%d3
    cmpib #0x82,%d0
    jbeq rsrc_ltlk_0_9BE_1E
    cmpib #0x81,%d0
    jbeq rsrc_ltlk_0_9BE_1E
    moveb %a2@(1738),%d3
    moveb %a2@,%a2@(1738)
rsrc_ltlk_0_9BE_1E:     /* call rsrc_ltlk_0_90E */
    jbsr rsrc_ltlk_0_90E
    jbmi rsrc_ltlk_0_A10
    moveb %d0,%d3
    jbsr rsrc_ltlk_0_90E
    jbmi rsrc_ltlk_0_A10

/* subroutine (12 instructions) (mechanical summary) */
rsrc_ltlk_0_9EA:
    moveb #0xc0,%a1@
    lslw #1,%d3
rsrc_ltlk_0_9EA_6:      /* loop: btst */
    btst #6,%a0@
    jbeq rsrc_ltlk_0_9EA_6
rsrc_ltlk_0_9EA_C:      /* loop: btst */
    btst #2,%a0@
    jbeq rsrc_ltlk_0_9EA_C
    moveb #5,%a1@
    moveq #0,%d3
    moveb #98,%a1@
    movew %a2@(1556),%d3
    moveal %a0,%a0
rsrc_ltlk_0_9EA_22:     /* count down (loop) */
    dbf %d3,rsrc_ltlk_0_9EA_22

/* subroutine (2 instructions) (mechanical summary) */
rsrc_ltlk_0_A10:
    lea %a2@(1636),%a3
    moveq #6,%d3

/* subroutine (8 instructions): low memory ExpandMem (mechanical summary) */
rsrc_ltlk_0_A16:
    moveb %a3@+,%a1@
    subqw #1,%d3
    jbne rsrc_ltlk_0_A16
    rts
rsrc_ltlk_0_A16_8:      /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    addql #1,%a2@(1666)
    jbra rsrc_ltlk_0_A2C_C

/* subroutine (62 instructions): calls rsrc_ltlk_0_AF6; low memory ExpandMem, SCCRd, SCCWr, ATalkHk2 (mechanical summary) */
rsrc_ltlk_0_A2C:
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    moveal SCCRd,%a0
rsrc_ltlk_0_A2C_C:      /* clear %d1 */
    moveq #0,%d1
    moveb %a0@(4),%d1
    moveal %a2@(700),%a3
    lea %a3@(1),%a3
    moveb %d1,%a3@+
    moveb %d1,%a2@(1)
    movew %a2@(1558),%d0
    addw %d0,%d0
    moveal %a0,%a0
rsrc_ltlk_0_A2C_28:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_0_A2C_28
    jbeq rsrc_ltlk_0_A2C_44
    moveb %a0@(4),%a3@
    moveb %a3@+,%a2@(2)
    moveal %a0,%a0
rsrc_ltlk_0_A2C_3C:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_0_A2C_3C
rsrc_ltlk_0_A2C_44:     /* from here: jbeq rsrc_ltlk_0_BD4 */
    jbeq rsrc_ltlk_0_BD4
    moveb %a0@(4),%d0
    addw %d1,%d1
    lea %a2@(1754),%a1
    movew %a1@(0x0,%d1:w),%d2
    jbeq rsrc_ltlk_0_B9A_8
    moveal SCCWr,%a1
    moveb %d0,%a3@+
    jbmi rsrc_ltlk_0_AF6_1C
    swap %d2
    moveb %d0,%d2
    movew %a2@(1558),%d0
    addw %d0,%d0
    moveml %a4-%a5,%a2@(766)
    moveal %a2@(700),%a2
    moveal ATalkHk2,%a5
    lea %pc@(rsrc_ltlk_0_CBE),%a4
rsrc_ltlk_0_A2C_80:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_0_A2C_80
    jbeq rsrc_ltlk_0_AF6_16
    moveb %a0@(4),%a3@
    moveq #3,%d1
    andb %a3@+,%d1
    lslw #8,%d1
rsrc_ltlk_0_A2C_94:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_0_A2C_94
    jbeq rsrc_ltlk_0_AF6_16
    moveb %a0@(4),%d1
    moveb %d1,%a3@+
    cmpiw #600,%d1
    jbgt rsrc_ltlk_0_AF6_10
    subqw #2,%d1
    moveq #1,%d0
    jsr %a5@(2)
    jbsr rsrc_ltlk_0_AF6
    moveb #1,%a1@
    moveq #-96,%d0
    andb %a0@,%d0
    jbne rsrc_ltlk_0_C80_E
    addql #1,%a2@(1690)
    clrw %d3
    jbra rsrc_ltlk_0_CC0

/* subroutine (54 instructions): calls rsrc_ltlk_0_AF6, rsrc_ltlk_0_BEA, rsrc_ltlk_0_B9A; low memory ExpandMem (mechanical summary) */
rsrc_ltlk_0_AF6:
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    moveml %a2@(766),%a4-%a5
    rts
rsrc_ltlk_0_AF6_10:     /* call rsrc_ltlk_0_AF6 */
    jbsr rsrc_ltlk_0_AF6
    jbra rsrc_ltlk_0_C80_18
rsrc_ltlk_0_AF6_16:     /* call rsrc_ltlk_0_AF6 */
    jbsr rsrc_ltlk_0_AF6
    jbra rsrc_ltlk_0_BD4
rsrc_ltlk_0_AF6_1C:     /* set %d2 */
    moveq #127,%d2
    andb %d0,%d2
    cmpib #5,%d2
    jbgt rsrc_ltlk_0_B9A_34
    jbsr rsrc_ltlk_0_BEA
    jbne rsrc_ltlk_0_AF6_4E
    moveq #0,%d0
    moveb %a2@(1),%d0
    cmpib #0xff,%d0
    seq %d1
    jbeq rsrc_ltlk_0_AF6_50
    addw %d0,%d0
    lea %a2@(1754),%a3
    addaw %d0,%a3
    cmpiw #-32768,%a3@
    jbne rsrc_ltlk_0_AF6_50
    movew #-32767,%a3@
rsrc_ltlk_0_AF6_4E:     /* return */
    rts
rsrc_ltlk_0_AF6_50:     /* subtract 1 to %d2 */
    subqb #1,%d2
    jbeq rsrc_ltlk_0_AF6_98
    subqb #3,%d2
    jbeq rsrc_ltlk_0_AF6_6A
    tstb %a2@(1544)
    jbeq rsrc_ltlk_0_AF6_62
    addql #1,%a2@(1722)
rsrc_ltlk_0_AF6_62:     /* subtract 1 to %d2 */
    subqb #1,%d2
    seq %a2@(1544)
    rts
rsrc_ltlk_0_AF6_6A:     /* test %d1 */
    tstb %d1
    jbne rsrc_ltlk_0_AF6_80
    movew %a2@(1568),%d0
rsrc_ltlk_0_AF6_72:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_0_AF6_72
    moveq #-123,%d0
    moveb %a2@(1),%a2@(1738)
    jbsr rsrc_ltlk_0_B9A
rsrc_ltlk_0_AF6_80:     /* set %d1 */
    movew %a2@(1562),%d1
    moveal %a0,%a0
rsrc_ltlk_0_AF6_86:     /* loop: btst */
    btst #0,%a0@
    dbne %d1,rsrc_ltlk_0_AF6_86
    jbne rsrc_ltlk_0_A2C
    addql #1,%a2@(1718)
    rts
rsrc_ltlk_0_AF6_98:     /* set %d0 */
    movew %a2@(1568),%d0
    moveal %a0,%a0
rsrc_ltlk_0_AF6_9E:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_0_AF6_9E
    moveq #-126,%d0

/* subroutine (20 instructions): calls rsrc_ltlk_0_C36; low memory SCCWr, ExpandMem (mechanical summary) */
rsrc_ltlk_0_B9A:
    moveb %a2@(2),%d2
    jbra rsrc_ltlk_0_9BE
rsrc_ltlk_0_B9A_8:      /* test bit 0 of %a2@(1734) */
    btst #0,%a2@(1734)
    jbne rsrc_ltlk_0_C36
    moveal SCCWr,%a1
    moveb #15,%a1@
    moveb #0x88,%d0
    moveb %d0,%a1@
    bset #1,%a2@(1734)
    moveb #2,%a2@(1547)
    jbra rsrc_ltlk_0_C36
    addql #1,%a2@(1690)
    bras rsrc_ltlk_0_C36
rsrc_ltlk_0_B9A_34:     /* add 1 to %a2@(1698) */
    addql #1,%a2@(1698)
    jbra rsrc_ltlk_0_C36

rsrc_ltlk_0_BD4:        /* add 1 to %a2@(1686) */
    addql #1,%a2@(1686)
    jbra rsrc_ltlk_0_C36
rsrc_ltlk_0_BD4_6:      /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    addql #1,%a2@(1726)
    jbsr rsrc_ltlk_0_C36
    jbra rsrc_ltlk_0_C36

/* subroutine (24 instructions) (mechanical summary) */
rsrc_ltlk_0_BEA:
    clrw %d0
    movew %a2@(1558),%d1
rsrc_ltlk_0_BEA_6:      /* loop: btst */
    btst #0,%a0@
    dbne %d1,rsrc_ltlk_0_BEA_6
    jbeq rsrc_ltlk_0_C80_20
    moveb #1,%a1@
    nop
    moveb %a0@,%d1
    jbmi rsrc_ltlk_0_C80_12
    tstb %a0@(4)
    movew %a2@(1558),%d1
rsrc_ltlk_0_BEA_26:     /* loop: btst */
    btst #0,%a0@
    dbne %d1,rsrc_ltlk_0_BEA_26
    jbeq rsrc_ltlk_0_C80_20
    moveb #1,%a1@
    nop
    moveb %a0@,%d1
    jbpl rsrc_ltlk_0_C80_12
    lslb #1,%d1
    jbmi rsrc_ltlk_0_C80_28
    movew %a2@(1572),%d1
    moveal %a0,%a0
rsrc_ltlk_0_BEA_46:     /* count down (loop) */
    dbf %d1,rsrc_ltlk_0_BEA_46
    jbra rsrc_ltlk_0_C36_3C

/* subroutine (23 instructions): low memory SCCRd, SCCWr, IntFlag (mechanical summary) */
rsrc_ltlk_0_C36:
    moveal SCCRd,%a0
    moveal SCCWr,%a1
    clrb %a2@(1739)
    moveb #1,%a1@
    nop
    btst #5,%a0@
    jbeq rsrc_ltlk_0_C36_1E
    bclr #7,IntFlag
rsrc_ltlk_0_C36_1E:     /* set %a1@ */
    moveb #3,%a1@
    nop
    moveb %a2@(1750),%a1@
    nop
    moveq #2,%d1
rsrc_ltlk_0_C36_2C:     /* loop: tst */
    tstb %a0@(4)
    nop
    moveb #48,%a1@
    nop
    dbf %d1,rsrc_ltlk_0_C36_2C
rsrc_ltlk_0_C36_3C:     /* set %a1@ */
    moveb #48,%a1@
    nop
    moveb #32,%a1@
    tstw %d0
    rts

/* subroutine (103 instructions): calls rsrc_ltlk_0_BEA, rsrc_ltlk_0_C36, rsrc_ltlk_0_DC4; low memory SCCWr, ExpandMem, PollStack, PollProc, DskRtnAdr (mechanical summary) */
rsrc_ltlk_0_C80:
    moveal SCCWr,%a1
    moveb #3,%a1@
    nop
    moveb %d1,%a1@
    rts
rsrc_ltlk_0_C80_E:      /* set %d1 */
    moveb %d0,%d1
    moveq #0,%d0
rsrc_ltlk_0_C80_12:     /* test bit 5 of %d1 */
    btst #5,%d1
    jbne rsrc_ltlk_0_C80_30
rsrc_ltlk_0_C80_18:     /* add 1 to %a2@(1694) */
    addql #1,%a2@(1694)
    moveq #-4,%d0
    jbra rsrc_ltlk_0_C36
rsrc_ltlk_0_C80_20:     /* add 1 to %a2@(1686) */
    addql #1,%a2@(1686)
    moveq #-3,%d0
    jbra rsrc_ltlk_0_C36
rsrc_ltlk_0_C80_28:     /* add 1 to %a2@(1678) */
    addql #1,%a2@(1678)
    moveq #-2,%d0
    jbra rsrc_ltlk_0_C36
rsrc_ltlk_0_C80_30:     /* add 1 to %a2@(1682) */
    addql #1,%a2@(1682)
    moveq #-1,%d0
    jbra rsrc_ltlk_0_C36
rsrc_ltlk_0_CBA:        /* continue at rsrc_ltlk_0_D52 */
    jbra rsrc_ltlk_0_D52	| 408DC9AA
rsrc_ltlk_0_CBE:        /* continue at rsrc_ltlk_0_CBA */
    jbra rsrc_ltlk_0_CBA	| 408DC9AE

rsrc_ltlk_0_CC0:        /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    moveal %a2@(1632),%a5
    moveal %sp,%a4
rsrc_ltlk_0_CC0_E:      /* loop: move */
    movew %a2@(1558),%d0
    subqw #1,%d1
    jbmi rsrc_ltlk_0_CC0_36
    moveal %a0,%a0
rsrc_ltlk_0_CC0_18:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_0_CC0_18
    jbeq rsrc_ltlk_0_CC0_36
    moveb %a0@(4),%d0
    tstb %a5@
    jbmi rsrc_ltlk_0_CC0_2E
    moveb %a0@(6),%sp@-
rsrc_ltlk_0_CC0_2E:     /* subtract 1 to %d3 */
    subqw #1,%d3
    jbmi rsrc_ltlk_0_CC0_E
    moveb %d0,%a3@+
    jbra rsrc_ltlk_0_CC0_E
rsrc_ltlk_0_CC0_36:     /* call rsrc_ltlk_0_BEA */
    jbsr rsrc_ltlk_0_BEA
    movel PollStack,%a2@(1588)
    movel %a4,PollStack
    movel PollProc,%d1
    jbeq rsrc_ltlk_0_CC0_72
    moveml %d0/%d2-%d3/%a3/%fp,%a2@(1612)
    lea %a0@(6),%fp
    moveal %d1,%a0
    movel DskRtnAdr,%a2@(1584)
    jsr %a0@
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    movel %a2@(1584),DskRtnAdr
    moveml %a2@(1612),%d0/%d2-%d3/%a3/%fp
rsrc_ltlk_0_CC0_72:     /* set %sp */
    moveal PollStack,%sp
    movel %a2@(1588),PollStack
rsrc_ltlk_0_CC0_7C:     /* loop: movem */
    moveml %a2@(766),%a4-%a5
    tstw %d0
    jbne rsrc_ltlk_0_CC0_8A
    addql #1,%a2@(1670)
rsrc_ltlk_0_CC0_8A:     /* test %d0 */
    tstw %d0
rsrc_ltlk_0_CC0_8C:     /* loop: movea */
    moveal %a2@(700),%a2
    rts
rsrc_ltlk_0_D52:        /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    subw %d3,%d1
rsrc_ltlk_0_CC0_9C:     /* loop: move */
    movew %a2@(1558),%d0
rsrc_ltlk_0_CC0_A0:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_0_CC0_A0
    jbeq rsrc_ltlk_0_CC0_C6
    moveb %a0@(4),%a3@+
    subqw #1,%d3
    jbne rsrc_ltlk_0_CC0_9C
    moveb #1,%a1@
    moveq #-96,%d0
    andb %a0@,%d0
    jbeq rsrc_ltlk_0_CC0_8C
    jbmi rsrc_ltlk_0_CC0_CE
    addql #1,%a2@(1682)
    moveq #-1,%d0
    jbra rsrc_ltlk_0_CC0_D4
rsrc_ltlk_0_CC0_C6:     /* add 1 to %a2@(1686) */
    addql #1,%a2@(1686)
    moveq #-3,%d0
    jbra rsrc_ltlk_0_CC0_D4
rsrc_ltlk_0_CC0_CE:     /* add 1 to %a2@(1694) */
    addql #1,%a2@(1694)
    moveq #-4,%d0
rsrc_ltlk_0_CC0_D4:     /* call rsrc_ltlk_0_C36 */
    jbsr rsrc_ltlk_0_C36
    jbra rsrc_ltlk_0_CC0_7C
    .short  0x4E71	| 408DCA8A
    movel %a2,%sp@-
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    moveq #0,%d0
    moveb %a0@(31),%d0
    bsrw rsrc_ltlk_0_DC4
    movew %d0,%a0@(42)
    jbne rsrc_ltlk_0_CC0_FC
    movew #-50,%d0
    jbra rsrc_ltlk_0_CC0_FE
rsrc_ltlk_0_CC0_FC:     /* clear %d0 */
    moveq #0,%d0
rsrc_ltlk_0_CC0_FE:     /* set %a2 */
    moveal %sp@+,%a2
    rts
    .short  0x4E71	| 408DCAB2

/* subroutine (7 instructions) (mechanical summary) */
rsrc_ltlk_0_DC4:
    movel %a0,%sp@-
    andil #255,%d0
    addw %d0,%d0
    lea %a2@(1754),%a0
    movew %a0@(0x0,%d0:w),%d0
    moveal %sp@+,%a0
    rts
    .short  0x4E71	| 408DCACA

/* subroutine (7 instructions) (mechanical summary) */
rsrc_ltlk_0_DDC:
    movel %a0,%sp@-
    andiw #255,%d0
    addw %d0,%d0
    lea %a2@(1754),%a0
    movew %d1,%a0@(0x0,%d0:w)
    moveal %sp@+,%a0
    rts

/* subroutine (67 instructions): traps InsTime, RmvTime, PrimeTime; low memory ROMBase, TimeDBRA (mechanical summary) */
rsrc_ltlk_0_DF0:
    moveal ROMBase,%a0
    cmpib #117,%a0@(9)
    jbcs rsrc_ltlk_0_DF0_2A
    subaw #14,%sp
    moveal %sp,%a0
    clrl %a0@(10)
    movew #-1,%a0@(4)
    _InsTime
    moveb %a0@(4),%d0
    jbpl rsrc_ltlk_0_DF0_30
    _RmvTime
    addaw #14,%sp
rsrc_ltlk_0_DF0_2A:     /* set %d0 */
    movew TimeDBRA,%d0
    rts
rsrc_ltlk_0_DF0_30:     /* _RmvTime */
    _RmvTime
    addaw #14,%sp
    moveml %d4-%d7,%sp@-
    moveq #6,%d0
rsrc_ltlk_0_DF0_3C:     /* loop: clr */
    clrw %sp@-
    dbf %d0,rsrc_ltlk_0_DF0_3C
    moveq #9,%d4
    movel #65535,%d5
rsrc_ltlk_0_DF0_4A:     /* loop: move */
    movel #60000000,%d7
    moveal %sp,%a0
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    _InsTime
    movel %d7,%d6
    movel %d7,%d0
    negl %d0
    _PrimeTime
    _RmvTime
    movew %sp@+,%sr
    addl %a0@(10),%d7
    moveal %sp,%a0
    _InsTime
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    movel %d6,%d0
    negl %d0
    _PrimeTime
    moveal %a0,%a0
    movew TimeDBRA,%d0
rsrc_ltlk_0_DF0_88:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_0_DF0_88
    movew TimeDBRA,%d0
rsrc_ltlk_0_DF0_90:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_0_DF0_90
    movew TimeDBRA,%d0
rsrc_ltlk_0_DF0_98:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_0_DF0_98
    movew TimeDBRA,%d0
rsrc_ltlk_0_DF0_A0:     /* set up and call _RmvTime (loop) */
    dbf %d0,rsrc_ltlk_0_DF0_A0
    _RmvTime
    movew %sp@+,%sr
    addl %a0@(10),%d6
    subl %d7,%d6
    cmpl %d6,%d5
    jbcs rsrc_ltlk_0_DF0_B4
    movel %d6,%d5
rsrc_ltlk_0_DF0_B4:     /* count down */
    dbf %d4,rsrc_ltlk_0_DF0_4A
    movew TimeDBRA,%d1
    muluw #4000,%d1
    divuw %d5,%d1
    movew %d1,%d0
    addaw #14,%sp
    moveml %sp@+,%d4-%d7
    rts
    .short  0x0000	| 408DCBAE

/* subroutine (73 instructions): traps InsTime, RmvTime, PrimeTime; low memory ROMBase, TimeSCCDB, SCCRd (mechanical summary) */
rsrc_ltlk_0_EC0:
    moveal ROMBase,%a0
    cmpib #117,%a0@(9)
    jbcs rsrc_ltlk_0_EC0_2A
    subaw #14,%sp
    moveal %sp,%a0
    clrl %a0@(10)
    movew #-1,%a0@(4)
    _InsTime
    moveb %a0@(4),%d0
    jbpl rsrc_ltlk_0_EC0_30
    _RmvTime
    addaw #14,%sp
rsrc_ltlk_0_EC0_2A:     /* set %d0 */
    movew TimeSCCDB,%d0
    rts
rsrc_ltlk_0_EC0_30:     /* _RmvTime */
    _RmvTime
    addaw #14,%sp
    moveml %d4-%d7,%sp@-
    moveq #6,%d0
rsrc_ltlk_0_EC0_3C:     /* loop: clr */
    clrw %sp@-
    dbf %d0,rsrc_ltlk_0_EC0_3C
    moveq #9,%d4
    movel #65535,%d5
rsrc_ltlk_0_EC0_4A:     /* loop: move */
    movel #60000000,%d7
    moveal %sp,%a0
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    _InsTime
    movel %d7,%d6
    movel %d7,%d0
    negl %d0
    _PrimeTime
    _RmvTime
    movew %sp@+,%sr
    addl %a0@(10),%d7
    moveal %sp,%a0
    _InsTime
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    movel %d6,%d0
    negl %d0
    _PrimeTime
    movew TimeSCCDB,%d0
    moveal SCCRd,%a1
    moveal %a0,%a0
rsrc_ltlk_0_EC0_8C:     /* loop: btst */
    btst #0,%a1@
    dbf %d0,rsrc_ltlk_0_EC0_8C
    movew TimeSCCDB,%d0
rsrc_ltlk_0_EC0_98:     /* loop: btst */
    btst #0,%a1@
    dbf %d0,rsrc_ltlk_0_EC0_98
    movew TimeSCCDB,%d0
rsrc_ltlk_0_EC0_A4:     /* loop: btst */
    btst #0,%a1@
    dbf %d0,rsrc_ltlk_0_EC0_A4
    movew TimeSCCDB,%d0
rsrc_ltlk_0_EC0_B0:     /* set up and call _RmvTime (loop) */
    btst #0,%a1@
    dbf %d0,rsrc_ltlk_0_EC0_B0
    _RmvTime
    movew %sp@+,%sr
    addl %a0@(10),%d6
    subl %d7,%d6
    cmpl %d6,%d5
    jbcs rsrc_ltlk_0_EC0_C8
    movel %d6,%d5
rsrc_ltlk_0_EC0_C8:     /* count down */
    dbf %d4,rsrc_ltlk_0_EC0_4A
    movew TimeSCCDB,%d1
    muluw #4000,%d1
    divuw %d5,%d1
    movew %d1,%d0
    addaw #14,%sp
    moveml %sp@+,%d4-%d7
    rts
    .short  0x0000	| 408DCC92
    FILL_408DCC94
