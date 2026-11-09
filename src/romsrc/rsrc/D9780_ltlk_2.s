/* ROM resource 'ltlk' 2: map entry at 0x408D9780, data at 0x408D97B0, 3880 bytes

 LocalTalk through the SCC directly, port A ('ltlk' 2, "SCC LocalTalk A v57.0.4"), (c) Apple 1984-1992.
 Loaded by the LAP Manager (lmgr 0) for the network connection chosen in parameter RAM;
 .MPP sends and receives through it. Comments inferred; routines summarised mechanically.
*/

rsrc_ltlk_2_entry:      /* map entry */
    .long   0x38000000, 0x00000000	| 408D9780
    .long   rsrc_atlk_3_entry-rom_start	| 408D9788
    .long   rsrc_ltlk_2-rom_start	| 408D978C
    .ascii  "ltlk"	| 408D9790
    .byte   0x00, 0x02, 0x58, 0x00	| 408D9794
    FILL_408D9798
    .byte   0xC0, 0xA0, 0x00, 0x00	| 408D97A4
    .short  0x0000, 0x0F34	| orib #52,%d0
    .short  0x0000, 0x02FC	| orib #0xfc,%d0

/* subroutine (88 instructions): calls rsrc_ltlk_2_22A, rsrc_ltlk_2_D60, rsrc_ltlk_2_5F8, rsrc_ltlk_2_5F0, rsrc_ltlk_2_1D8 ...; low memory ExpandMem, SCCWr, ATalkHk2 (mechanical summary) */
rsrc_ltlk_2:
    jbra rsrc_ltlk_2_3A
    bras rsrc_ltlk_2_E
    .short  0x0008	| .short 0x0008
    .short  0x00EE	| .short 0x00ee
    bset %d1,%d6
    .short  0x0614, 0x0682	| 408D97BA addib #0x82,%a4@
rsrc_ltlk_2_E:
    cmpiw #11,%d0
    bhis rsrc_ltlk_2_36
    lslw #1,%d0
    movew %pc@(rsrc_ltlk_2_1E,%d0:w),%d0
    jmp %pc@(rsrc_ltlk_2_1E,%d0:w)
rsrc_ltlk_2_1E:
    .short  0x0018, 0x011C	| orib #28,%a0@+
    bclr %d0,%a4@+
    bset %d1,%a0@(0x18,%d0:w)
    orib #24,%a0@+
    .short  0x0132, 0x0156, 0x043E	| btst %d0,%a2@(0)@(43e)
    .short  0x04DA	| .short 0x04da
    btst %d6,%d2
rsrc_ltlk_2_36:
    moveq #-1,%d0
    rts

rsrc_ltlk_2_3A:         /* set %a3 */
    moveal ExpandMem,%a3
    moveal %a3@(256),%a3
    moveml %d2/%a0-%a2,%a3@(708)
    exg %a2,%a3
    tstb %d0
    jbeq rsrc_ltlk_2_3A_A8
rsrc_ltlk_2_3A_16:      /* test %a2@(698) */
    tstb %a2@(698)
    jbne rsrc_ltlk_2_3A_38
    movel %a3,%a2@(700)
    movel %a1,%a2@(742)
    jbsr rsrc_ltlk_2_22A
    moveb #0xff,%d0
    movew #-1,%d1
    jbsr rsrc_ltlk_2_D60
    st %a2@(698)
rsrc_ltlk_2_3A_38:      /* from here: st %a2@(1546) */
    st %a2@(1546)
    moveb %a2@,%d0
    clrw %d1
    jbsr rsrc_ltlk_2_D60
    moveb %d2,%a2@
    moveb %d3,%d0
    movew #-32768,%d1
    jbsr rsrc_ltlk_2_D60
    moveal SCCWr,%a1
    addqw #2,%a1
    moveb #6,%a1@
    nop
    moveb %a2@,%a1@
    jbsr rsrc_ltlk_2_5F8
    clrw %d0
    moveb %a2@,%d0
    addw %d0,%d0
    lea %a2@(1754),%a3
    addaw %d0,%a3
    cmpiw #-32767,%a3@
    jbne rsrc_ltlk_2_3A_9C
    moveq #12,%d0
    moveal ATalkHk2,%a3
    moveb %a2@(740),%d4
    movel %a2,%sp@-
    moveal %a2@(700),%a2
    jsr %a3@(2)
    tstw %d0
    jbeq rsrc_ltlk_2_3A_92
    moveq #5,%d0
    jsr %a3@(2)
rsrc_ltlk_2_3A_92:      /* set %a2 */
    moveal %sp@+,%a2
    clrw %a3@
    clrw %a2@(1752)
    jbra rsrc_ltlk_2_3A_AC
rsrc_ltlk_2_3A_9C:      /* set %a3@ */
    movew #-1,%a3@
    movew #1,%a2@(1752)
    jbra rsrc_ltlk_2_3A_AC
rsrc_ltlk_2_3A_A8:      /* call rsrc_ltlk_2_5F0 */
    jbsr rsrc_ltlk_2_5F0
rsrc_ltlk_2_3A_AC:      /* set %d2/%a0-%a2 */
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
    .short  0x6F63	| bles 408d9919 <rsrc_ltlk_2_3A_AC+0x83>
    bsrs rsrc_ltlk_2_3A_138_2
    addqw #2,%a1@-
    .short  0x6C6B	| bges 408d9927 <rsrc_ltlk_2_3A_138+0x5>
    moveal %d1,%a0
    .short  0x2076, 0x3537, 0x2E30, 0x2E34, 0x2020, 0x3B20	| moveal %fp@(2e302e34)@(20203b20,%d3:w:4),%a0
    .short  0xA920	| .short 0xa920
    .short  0x4170	| .short 0x4170
    moveq #108,%d0
    .short  0x6520	| bcss 408d98f2 <rsrc_ltlk_2_3A_AC+0x5c>
    .short  0x436F	| .short 0x436f
    blts rsrc_ltlk_2_3A_138_24
    .short  0x7574	| .short 0x7574
    .short  0x6572	| bcss 408d994c <rsrc_ltlk_2_3A_138_24+0x6>
    movel %a0@-,%d6
    .short  0x496E	| .short 0x496e
    .short  0x632E	| blss 408d990e <rsrc_ltlk_2_3A_AC+0x78>
    .short  0x2031, 0x3938, 0x342D, 0x3139	| movel %a1@(342d3139,%d3:l),%d0
    movew %a2@(-25,%d4:l),%a4@-
    nbcd %d0
    lea %pc@(rsrc_ltlk_2),%a0
    .short  0xA128	| 408D98F2 _RecoverHandle (flags 0x0100)
    movel %a0,%sp@-
    _DetachResource
    moveml %sp@+,%d1/%d4
    clrw %d0
    rts
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    jbsr rsrc_ltlk_2_1D8
    jbne rsrc_ltlk_2_3A_138
    lea %pc@(rsrc_ltlk_2_440),%a0
    movel %a0,%a2@(1746)
    moveal ATalkHk2,%a1
    lea %a2@(1740),%a0
    moveq #23,%d0
    jsr %a1@(2)
rsrc_ltlk_2_3A_138:     /* return */
    rts
rsrc_ltlk_2_3A_138_2:
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    moveml %d1/%a2,%sp@-
    lea %a2@(1740),%a0
    moveal ATalkHk2,%a1
    moveq #24,%d0
    jsr %a1@(2)
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
rsrc_ltlk_2_3A_138_24:
    lea %a2@(1754),%a0
    movel #253,%d0
    addqw #2,%d0
    moveq #0,%d1
rsrc_ltlk_2_3A_16A:     /* loop: clr */
    clrw %a0@(0x0,%d1:w)
    addqw #2,%d1
    dbf %d0,rsrc_ltlk_2_3A_16A
    clrw %a2@(1752)
    moveml %sp@+,%d1/%a2
    jbsr rsrc_ltlk_2_1EC
    rts
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    movel %a2,%sp@-
    bsrs rsrc_ltlk_2_1EC
    moveal %sp@,%a2
    moveal ATalkHk2,%a1
    moveq #3,%d0
    jsr %a1@(2)
    moveal %sp@+,%a0
    _DisposPtr
    rts

/* subroutine (7 instructions): low memory PortAUse (mechanical summary) */
rsrc_ltlk_2_1D8:
    moveq #-97,%d0
    tstb PortAUse
    jbpl rsrc_ltlk_2_1D8_10
    moveb #1,PortAUse
    moveq #0,%d0
rsrc_ltlk_2_1D8_10:     /* test %d0 */
    tstw %d0
    rts

/* subroutine (18 instructions): traps VRemove, PMgrOp; calls rsrc_ltlk_2_386; low memory HWCfgFlags, PortAUse (mechanical summary) */
rsrc_ltlk_2_1EC:
    tstb %a2@(698)
    jbeq rsrc_ltlk_2_1EC_3C
    lea %pc@(rsrc_ltlk_2_402),%a0
    jbsr rsrc_ltlk_2_386
    lea %a2@(658),%a0
    _VRemove
    lea %a2@(1600),%a0
    lea 0x1ca,%a3
    movel %a0@+,%a3@+
    movel %a0@+,%a3@+
    movel %a0@+,ExtStsDT_A
    clrb %a2@(698)
    btst #8,HWCfgFlags
    jbeq rsrc_ltlk_2_1EC_38
    moveq #4,%d0
    bset #7,%d0
    .short  0xA685	| 408D99D2 _PMgrOp (flags 0x0600)
rsrc_ltlk_2_1EC_38:     /* from here: st PortAUse */
    st PortAUse
rsrc_ltlk_2_1EC_3C:     /* return */
    rts

/* subroutine (60 instructions): traps PMgrOp, SysEnvirons, VInstall; calls rsrc_ltlk_2_304, rsrc_ltlk_2_304_78; low memory HWCfgFlags, ROMBase, SCCRd (mechanical summary) */
rsrc_ltlk_2_22A:
    moveml %d0-%d5/%a0-%fp,%sp@-
    btst #8,HWCfgFlags
    jbeq rsrc_ltlk_2_22A_10
    moveq #5,%d0
    .short  0xA685	| 408D99E8 _PMgrOp (flags 0x0600)
rsrc_ltlk_2_22A_10:     /* set up and call _SysEnvirons */
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
    jbne rsrc_ltlk_2_22A_42
    subaw #7680,%a1
    jbra rsrc_ltlk_2_22A_52
rsrc_ltlk_2_22A_42:     /* test #13,%a2@(1658) */
    cmpiw #13,%a2@(1658)
    jbne rsrc_ltlk_2_22A_52
    moveal SCCRd,%a1
    lea %a1@(-28),%a1
rsrc_ltlk_2_22A_52:     /* set %a2@(1632) */
    movel %a1,%a2@(1632)
    lea %pc@(rsrc_ltlk_2_3BE),%a0
    movel %a0@+,%a2@(1636)
    movew %a0@+,%a2@(1640)
    movew %a0@+,%a2@(28)
    cmpib #117,%a3@(9)
    jbeq rsrc_ltlk_2_22A_84
    cmpib #118,%a3@(9)
    jbeq rsrc_ltlk_2_22A_84
    cmpib #122,%a3@(9)
    jbeq rsrc_ltlk_2_22A_84
    movew #8960,%a2@(28)
rsrc_ltlk_2_22A_84:     /* call rsrc_ltlk_2_304 */
    jbsr rsrc_ltlk_2_304
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    lea 0x1ca,%a3
    lea %a2@(1600),%a1
    lea %pc@(rsrc_ltlk_2_9DA_8),%a0
    movel %a3@,%a1@+
    movel %a0,%a3@+
    lea %pc@(rsrc_ltlk_2_B9E_6),%a0
    movel %a3@,%a1@+
    movel %a0,%a3@+
    lea %pc@(rsrc_ltlk_2_7AC),%a0
    movel ExtStsDT_A,%a1@
    movel %a0,ExtStsDT_A
    lea %a2@(658),%a0
    movew #1,%a0@(4)
    lea %pc@(rsrc_ltlk_2_84A),%a1
    movel %a1,%a0@(6)
    movew #20,%a0@(10)
    _VInstall
    jbsr rsrc_ltlk_2_304_78
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d5/%a0-%fp
    rts

/* subroutine (45 instructions): traps BlockMove; calls rsrc_ltlk_2_D74, rsrc_ltlk_2_E44; low memory ROMBase (mechanical summary) */
rsrc_ltlk_2_304:
    moveml %d3/%d6-%d7,%sp@-
    moveal ROMBase,%a3
    cmpib #117,%a3@(9)
    jbhi rsrc_ltlk_2_304_1E
    moveq #20,%d0
    lea %pc@(rsrc_ltlk_2_3C6),%a0
    lea %a2@(1556),%a1
    _BlockMove
    jbra rsrc_ltlk_2_304_72
rsrc_ltlk_2_304_1E:     /* call rsrc_ltlk_2_D74 */
    jbsr rsrc_ltlk_2_D74
    moveq #0,%d7
    movew %d0,%d7
    jbsr rsrc_ltlk_2_E44
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
    lea %pc@(rsrc_ltlk_2_3DA),%a0
rsrc_ltlk_2_304_4A:     /* loop: move */
    movew %a0@+,%d3
    moveq #0,%d2
    moveb %a0@+,%d2
    divuw %d1,%d2
    subw %d2,%d3
    tstb %a0@+
    jbmi rsrc_ltlk_2_304_6C
    muluw %d7,%d3
rsrc_ltlk_2_304_5A:     /* loop: divu */
    divuw #1000,%d3
    subqw #1,%d3
    jbpl rsrc_ltlk_2_304_64
    moveq #0,%d3
rsrc_ltlk_2_304_64:     /* set %a1@+ */
    movew %d3,%a1@+
    subqw #2,%d0
    jbne rsrc_ltlk_2_304_4A
    jbra rsrc_ltlk_2_304_70
rsrc_ltlk_2_304_6C:     /* from here: muluw %d6,%d3 */
    muluw %d6,%d3
    jbra rsrc_ltlk_2_304_5A
rsrc_ltlk_2_304_70:     /* set %sr */
    movew %sp@+,%sr
rsrc_ltlk_2_304_72:     /* restore registers, return */
    moveml %sp@+,%d3/%d6-%d7
    rts

/* subroutine (3 instructions): calls rsrc_ltlk_2_386 (mechanical summary) */
rsrc_ltlk_2_304_78:
    lea %pc@(rsrc_ltlk_2_39A),%a0
    jbsr rsrc_ltlk_2_386
    lea %pc@(rsrc_ltlk_2_3B6),%a0

/* subroutine (95 instructions): calls rsrc_ltlk_2_304, rsrc_ltlk_2_22A, rsrc_ltlk_2_53A, rsrc_ltlk_2_568, rsrc_ltlk_2_D60 ...; low memory SCCWr, ExpandMem (mechanical summary) */
rsrc_ltlk_2_386:
    moveal SCCWr,%a3
    addqw #2,%a3
rsrc_ltlk_2_386_6:      /* loop: move */
    movew %a0@+,%d0
    jbeq rsrc_ltlk_2_386_12
    moveb %d0,%a3@
    rorw #8,%d0
    moveb %d0,%a3@
    jbra rsrc_ltlk_2_386_6
rsrc_ltlk_2_386_12:     /* return */
    rts
rsrc_ltlk_2_39A:        /* (data) */
    .byte   0x80, 0x09, 0x20, 0x04, 0xE0, 0x0A, 0x00, 0x06, 0x7E, 0x07, 0x06, 0x0C, 0x00, 0x0D, 0xC0, 0x0E	| 408D9B4A
    .byte   0xDD, 0x03, 0x00, 0x02, 0x08, 0x0F, 0x09, 0x01, 0x0A, 0x09, 0x00, 0x00	| 408D9B5A
rsrc_ltlk_2_3B6:        /* set %d0 */
    moveq #11,%d0	| 408D9B66
    movel %fp,%a0@-	| 408D9B68
    jbra rsrc_ltlk_2_3C1	| 408D9B6A
    .byte   0x00, 0x00	| 408D9B6C
rsrc_ltlk_2_3BE:        /* (data) */
    .byte   0x05, 0x60, 0x0E	| 408D9B6E
rsrc_ltlk_2_3C1:        /* (data) */
    .byte   0x41, 0x03, 0xDD, 0x21, 0x00	| 408D9B71
rsrc_ltlk_2_3C6:        /* (data) */
    .byte   0x00, 0x35, 0x00, 0x14, 0x00, 0x1E, 0x00, 0x82, 0x00, 0x66, 0x00, 0x10, 0x00, 0x00, 0x00, 0x39	| 408D9B76
    .byte   0x00, 0x00, 0x00, 0x00	| 408D9B86
rsrc_ltlk_2_3DA:        /* (data) */
    .byte   0x00, 0x73, 0x3A, 0x00, 0x00, 0x64, 0x00, 0xFF, 0x00, 0xC8, 0x00, 0xFF, 0x01, 0xF4, 0x00, 0xFF	| 408D9B8A
    .byte   0x01, 0x90, 0x72, 0xFF, 0x00, 0x46, 0x2C, 0x00, 0x00, 0x1E, 0x00, 0x00, 0x00, 0x64, 0x5A, 0x00	| 408D9B9A
    .byte   0x00, 0x3C, 0xFF, 0x00, 0x00, 0x0A, 0x40, 0x00	| 408D9BAA
rsrc_ltlk_2_402:        /* (data) */
    .byte   0x8A, 0x09, 0x00, 0x0A, 0x10, 0x00, 0x08, 0x0F, 0x01, 0x01, 0x00, 0x00, 0x0C, 0x41, 0x00, 0x16	| 408D9BB2
    .byte   0x6D, 0x1C, 0x20, 0x09, 0x47, 0xFA, 0x00, 0x1C, 0x22, 0xDB, 0x22, 0xDB, 0x42, 0x99, 0x32, 0xDB	| 408D9BC2
    .byte   0x42, 0x99, 0x42, 0x19, 0x12, 0xD2, 0x32, 0xDB, 0x22, 0x40, 0x42, 0x40, 0x4E, 0x75, 0x70, 0xFF	| 408D9BD2
    .byte   0x4E, 0x75	| 408D9BE2
    orib #22,%d3
    .short  0x0003, 0x9210	| orib #16,%d3
    orib #0xfe,%d1
rsrc_ltlk_2_440:        /* set %d0 */
    movel %sp@(4),%d0
    cmpil #1936745828,%d0
    jbne rsrc_ltlk_2_458
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    jbsr rsrc_ltlk_2_304
rsrc_ltlk_2_458:        /* result 0 */
    moveq #0,%d0
    rts

rsrc_ltlk_2_45C:        /* save registers */
    moveml %d1-%d3/%a0-%a3,%sp@-
    moveal ExpandMem,%a3
    moveal %a3@(256),%a3
    moveml %d2/%a0-%a2,%a3@(708)
    exg %a2,%a3
    movel %a0,%d3
    tstb %a2@(698)
    jbne rsrc_ltlk_2_45C_2A
    movel %a0@(34),%a2@(700)
    jbsr rsrc_ltlk_2_22A
    st %a2@(698)
rsrc_ltlk_2_45C_2A:     /* test #253,%a2@(1752) */
    cmpiw #253,%a2@(1752)
    jbeq rsrc_ltlk_2_45C_94
    moveb %a0@(31),%d2
    moveq #0,%d0
    moveb %d2,%d0
    addw %d0,%d0
    lea %a2@(1754),%a1
    addaw %d0,%a1
    movew %a1@,%d0
    jbne rsrc_ltlk_2_45C_94
    tstw %a2@(1752)
    jbne rsrc_ltlk_2_45C_66
    moveb %d2,%a2@
    movel %a1,%sp@-
    moveal SCCWr,%a1
    addqw #2,%a1
    moveb #6,%a1@
    nop
    moveb %a2@,%a1@
    moveal %sp@+,%a1
    movew #-1,%a0@(42)
rsrc_ltlk_2_45C_66:     /* add 1 to %a2@(1752) */
    addqw #1,%a2@(1752)
    movew #-32768,%a1@
    jbsr rsrc_ltlk_2_53A
    moveb %d2,%d0
    jbsr rsrc_ltlk_2_568
    jbne rsrc_ltlk_2_45C_8C
    movew %a0@(42),%a1@
    moveb #0xff,%d0
    movew #-1,%d1
    jbsr rsrc_ltlk_2_D60
    moveq #0,%d0
    jbra rsrc_ltlk_2_45C_96
rsrc_ltlk_2_45C_8C:     /* clear %a1@ */
    clrw %a1@
    subqw #1,%a2@(1752)
    jbsr rsrc_ltlk_2_53A
rsrc_ltlk_2_45C_94:     /* set %d0 */
    moveq #-50,%d0
rsrc_ltlk_2_45C_96:     /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a0-%a3
    rts

rsrc_ltlk_2_4F8:        /* save registers */
    moveml %d1-%d2/%a2,%sp@-
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    moveb %a0@(31),%d2
    moveb %d2,%d0
    jbeq rsrc_ltlk_2_4F8_3A
    cmpib #0xff,%d2
    jbeq rsrc_ltlk_2_4F8_3A
    cmpb %a2@,%d2
    jbeq rsrc_ltlk_2_4F8_3A
    jbsr rsrc_ltlk_2_D48
    movew %d0,%a0@(42)
    jbeq rsrc_ltlk_2_4F8_3A
    moveb %d2,%d0
    moveq #0,%d1
    jbsr rsrc_ltlk_2_D60
    subqw #1,%a2@(1752)
    jbsr rsrc_ltlk_2_53A
    moveq #0,%d0
    jbra rsrc_ltlk_2_4F8_3C
rsrc_ltlk_2_4F8_3A:     /* set %d0 */
    moveq #-50,%d0
rsrc_ltlk_2_4F8_3C:     /* restore registers, return */
    moveml %sp@+,%d1-%d2/%a2
    rts

/* subroutine (14 instructions): calls rsrc_ltlk_2_C50 (mechanical summary) */
rsrc_ltlk_2_53A:
    movel %a1,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    moveb #0xd9,%d1
    cmpiw #1,%a2@(1752)
    jbgt rsrc_ltlk_2_53A_1C
    moveb #0xdd,%d1
rsrc_ltlk_2_53A_1C:     /* set %a2@(1750) */
    moveb %d1,%a2@(1750)
    moveb %d1,%a2@(1641)
    jbsr rsrc_ltlk_2_C50
    movew %sp@+,%sr
    moveal %sp@+,%a1
    rts

/* subroutine (16 instructions): calls rsrc_ltlk_2_59A (mechanical summary) */
rsrc_ltlk_2_568:
    moveml %d1-%d4/%a2-%a3,%sp@-
    moveb %a0@(31),%d2
    movew %a0@(32),%d4
rsrc_ltlk_2_568_C:      /* save registers */
    moveml %d1-%d4/%a0-%a3,%sp@-
    jbsr rsrc_ltlk_2_59A
    moveml %sp@+,%d1-%d4/%a0-%a3
rsrc_ltlk_2_568_16:     /* loop: tst */
    tstb %a2@(1546)
    jbne rsrc_ltlk_2_568_16
    cmpiw #-32767,%a1@
    dbeq %d4,rsrc_ltlk_2_568_C
    moveml %sp@+,%d1-%d4/%a2-%a3
    jbeq rsrc_ltlk_2_568_2E
    moveq #0,%d0
    rts
rsrc_ltlk_2_568_2E:     /* result 1 */
    moveq #1,%d0
    rts

/* subroutine (4 instructions): calls rsrc_ltlk_2_5F8 (mechanical summary) */
rsrc_ltlk_2_59A:
    st %a2@(1546)
    jbsr rsrc_ltlk_2_5F8
    clrb %a2@(1546)
    rts

/* subroutine (11 instructions): calls rsrc_ltlk_2_5C2 (mechanical summary) */
rsrc_ltlk_2_5A6:
    lea %a2@(1549),%a3
    moveb %a3@+,%d3
    moveb %a3@,%d2
    addb %d2,%a3@+
    jbsr rsrc_ltlk_2_5C2
    jble rsrc_ltlk_2_5C2_12
    addb %d3,%d3
    addqb #1,%d3
    andiw #15,%d3
    clrb %a3@(-1)
    jbra rsrc_ltlk_2_5C2_1C

/* subroutine (22 instructions): calls rsrc_ltlk_2_5C2 (mechanical summary) */
rsrc_ltlk_2_5C2:
    moveq #0,%d0
    moveq #7,%d1
rsrc_ltlk_2_5C2_4:      /* loop: btst */
    btst %d1,%d2
    jbeq rsrc_ltlk_2_5C2_A
    addqw #1,%d0
rsrc_ltlk_2_5C2_A:      /* count down */
    dbf %d1,rsrc_ltlk_2_5C2_4
    subqb #2,%d0
    rts
rsrc_ltlk_2_5C2_12:     /* set %d2 */
    moveb %a3@,%d2
    jbsr rsrc_ltlk_2_5C2
    jbge rsrc_ltlk_2_5C2_1C
    lsrb #1,%d3
    st %a3@
rsrc_ltlk_2_5C2_1C:     /* set %d2 */
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
rsrc_ltlk_2_5F0:
    clrb %a2@(1546)
    movel %a1,%a2@(1532)

/* subroutine (80 instructions): calls rsrc_ltlk_2_5A6, rsrc_ltlk_2_8F4, rsrc_ltlk_2_702, rsrc_ltlk_2_984, rsrc_ltlk_2_8D6; low memory SCCRd, SCCWr (mechanical summary) */
rsrc_ltlk_2_5F8:
    movel %sp@+,%a2@(1536)
    bset #2,%a2@(1734)
    moveb %d2,%a2@(1542)
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    btst #1,%a2@(1734)
    jbne rsrc_ltlk_2_5F8_FA
    movew %sp@+,%sr
rsrc_ltlk_2_5F8_24:     /* loop: bclr */
    bclr #2,%a2@(1734)
    jbeq rsrc_ltlk_2_5F8_2E
    jbsr rsrc_ltlk_2_5A6
rsrc_ltlk_2_5F8_2E:     /* set %a0 */
    moveal SCCRd,%a0
    moveal SCCWr,%a1
    addqw #2,%a0
    addqw #2,%a1
    movew %sr,%sp@-
rsrc_ltlk_2_5F8_3C:     /* loop: move */
    movew %d0,%d3
    btst #4,%a0@
    jbeq rsrc_ltlk_2_5F8_86
    jbsr rsrc_ltlk_2_8F4
    andb %a2@(1548),%d0
    andiw #15,%d0
    movew %d0,%d3
    jbeq rsrc_ltlk_2_5F8_5E
rsrc_ltlk_2_5F8_54:     /* call rsrc_ltlk_2_702 (loop) */
    jbsr rsrc_ltlk_2_702
    jbeq rsrc_ltlk_2_5F8_86
    subqw #1,%d0
    jbne rsrc_ltlk_2_5F8_54
rsrc_ltlk_2_5F8_5E:     /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    andiw #-257,%sr
    btst #1,%a2@(1734)
    jbne rsrc_ltlk_2_5F8_FA
    moveq #3,%d0
    addqw #3,%d3
rsrc_ltlk_2_5F8_74:     /* loop: move */
    moveb #14,%a1@
    nop
    moveb #65,%a1@
    jbsr rsrc_ltlk_2_702
    dbeq %d0,rsrc_ltlk_2_5F8_74
rsrc_ltlk_2_5F8_86:     /* from here: jbeq rsrc_ltlk_2_702_62 */
    jbeq rsrc_ltlk_2_702_62
    moveb #10,%a1@
    moveb %a2@(1542),%d2
    tstb %a0@
    jbmi rsrc_ltlk_2_702_62
    moveb #5,%a1@
    moveq #-124,%d0
    moveb #98,%a1@
    tstb %a2@(1546)
    jbeq rsrc_ltlk_2_5F8_AE
    moveq #-127,%d0
    moveb %a2@,%a2@(1738)
rsrc_ltlk_2_5F8_AE:     /* set %a1@ */
    moveb #5,%a1@
    nop
    moveb %a2@(1637),%a1@
    movew %a2@(1574),%d1
rsrc_ltlk_2_5F8_BC:     /* count down (loop) */
    dbf %d1,rsrc_ltlk_2_5F8_BC
    jbsr rsrc_ltlk_2_984
    addqb #1,%d2
    jbeq rsrc_ltlk_2_702_14
    clrb %a2@(1544)
    jbsr rsrc_ltlk_2_8D6
    tstb %a2@(1546)
    jbeq rsrc_ltlk_2_5F8_EE
    moveq #0,%d0
    moveb %a2@(1542),%d0
    addw %d0,%d0
    lea %a2@(1754),%a3
    movew %a3@(0x0,%d0:w),%d0
    cmpiw #-32767,%d0
    jbne rsrc_ltlk_2_702_3E
    jbra rsrc_ltlk_2_702_28
rsrc_ltlk_2_5F8_EE:     /* test %a2@(1544) */
    tstb %a2@(1544)
    st %a2@(1544)
    jbeq rsrc_ltlk_2_702_3E
    jbra rsrc_ltlk_2_702_24
rsrc_ltlk_2_5F8_FA:     /* set bit 0 of %a2@(1734) */
    bset #0,%a2@(1734)
    movew %sp@+,%sr
    moveml %a2@(708),%d2/%a0-%a2
    rts

/* subroutine (136 instructions): traps DeferUserFn; calls rsrc_ltlk_2_702, rsrc_ltlk_2_93E, rsrc_ltlk_2_C02; low memory ExpandMem, SCCRd, SCCWr (mechanical summary) */
rsrc_ltlk_2_702:
    movew %a2@(1570),%d1
    jbra rsrc_ltlk_2_702_C
rsrc_ltlk_2_702_6:      /* count down (loop) */
    dbf %d1,rsrc_ltlk_2_702_6
    jbra rsrc_ltlk_2_702_E
rsrc_ltlk_2_702_C:      /* continue at rsrc_ltlk_2_702_6 */
    jbra rsrc_ltlk_2_702_6
rsrc_ltlk_2_702_E:      /* test bit 4 of %a0@ */
    btst #4,%a0@
    rts
rsrc_ltlk_2_702_14:     /* call rsrc_ltlk_2_702 */
    jbsr rsrc_ltlk_2_702
    jbeq rsrc_ltlk_2_702_3E
    cmpiw #114,%a2@(1570)
    jbcs rsrc_ltlk_2_702_24
    jbsr rsrc_ltlk_2_702
    jbeq rsrc_ltlk_2_702_3E
rsrc_ltlk_2_702_24:     /* call rsrc_ltlk_2_93E */
    jbsr rsrc_ltlk_2_93E
rsrc_ltlk_2_702_28:     /* clear %d0 */
    moveq #0,%d0
    addql #1,%a2@(1674)
rsrc_ltlk_2_702_2E:     /* loop: move */
    movew %sp@+,%sr
    moveal %a2@(1536),%a0
    clrl %a2@(1536)
    clrl %a2@(1532)
    jmp %a0@
rsrc_ltlk_2_702_3E:     /* add 1 to %a2@(1702) */
    addql #1,%a2@(1702)
    movew %sp@,%sr
    bset #0,%a2@(1550)
    moveb %a2@(1548),%d0
    addb %d0,%d0
    addqb #1,%d0
    moveb %d0,%a2@(1548)
    moveq #-95,%d0
    subqb #1,%a2@(1553)
    jbeq rsrc_ltlk_2_702_2E
    jbra rsrc_ltlk_2_5F8_3C
rsrc_ltlk_2_702_62:     /* from here: subw %d0,%d3 */
    subw %d0,%d3
    subqw #4,%d3
    jblt rsrc_ltlk_2_702_80
    addql #1,%a2@(1706)
    moveq #-95,%d0
    subqb #1,%a2@(1552)
    jbeq rsrc_ltlk_2_702_2E
    bset #0,%a2@(1548)
    bset #0,%a2@(1551)
rsrc_ltlk_2_702_80:     /* from here: oriw #1792,%sr */
    oriw #1792,%sr
    andiw #-257,%sr
    moveb #15,%a1@
    moveb #0x88,%d0
    moveb %d0,%a1@
    bset #0,%a2@(1734)
    moveb #2,%a2@(1547)
    moveq #0,%d0
    moveml %a2@(708),%d2/%a0-%a2
rsrc_ltlk_2_702_A6:     /* loop: move */
    movew %sp@+,%sr
    rts
rsrc_ltlk_2_7AC:        /* set %a2 */
    moveal ExpandMem,%a2	| 408D9F5C
    moveal %a2@(256),%a2	| 408D9F60
    btst #3,%d1	| 408D9F64
    jbeq rsrc_ltlk_2_7C8	| 408D9F68
    moveb %d1,%sp@-	| 408D9F6A
    moveal 0x2ca,%a3	| 408D9F6C
    addql #1,%a2@(1730)	| 408D9F70
    jsr %a3@	| 408D9F74
    moveb %sp@+,%d1	| 408D9F76
rsrc_ltlk_2_7C8:        /* test bit 7 of %d1 */
    btst #7,%d1	| 408D9F78
    jbeq rsrc_ltlk_2_830	| 408D9F7C
    tstb %a2@(1547)	| 408D9F7E
    jbeq rsrc_ltlk_2_C02	| 408D9F82
    moveb #15,%a1@	| 408D9F86
    moveb #8,%d0	| 408D9F8A
    moveb %d0,%a1@	| 408D9F8E
    clrb %a2@(1547)	| 408D9F90
    bclr #1,%a2@(1734)	| 408D9F94
    bclr #0,%a2@(1734)	| 408D9F9A
    jbeq rsrc_ltlk_2_C02	| 408D9FA0
    movew %sr,%d0	| 408D9FA4
    andiw #-1793,%d0	| 408D9FA6
    eoriw #8192,%d0	| 408D9FAA
    movew %a2@(28),%sp@-	| 408D9FAE
    eorw %d0,%sp@	| 408D9FB2
    movew %sp@+,%sr	| 408D9FB4
    tstb %a2@(1735)	| 408D9FB6
    jbeq rsrc_ltlk_2_846	| 408D9FBA
    lea %pc@(rsrc_ltlk_2_832),%a0	| 408D9FBC
    movel %a2,%d0	| 408D9FC0
    _DeferUserFn	| 408D9FC2
    jbeq rsrc_ltlk_2_830	| 408D9FC4
    oriw #1792,%sr	| 408D9FC6
    andiw #-257,%sr	| 408D9FCA
    tstl %a2@(1532)	| 408D9FCE
    jbeq rsrc_ltlk_2_830	| 408D9FD2
    moveb #1,%a2@(1547)	| 408D9FD4
    bset #0,%a2@(1734)	| 408D9FDA
rsrc_ltlk_2_830:        /* return */
    rts	| 408D9FE0
rsrc_ltlk_2_832:        /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    moveal SCCRd,%a0
    moveal SCCWr,%a1
    addqw #2,%a0
    addqw #2,%a1
rsrc_ltlk_2_846:        /* continue at rsrc_ltlk_2_5F8_24 */
    jbra rsrc_ltlk_2_5F8_24
rsrc_ltlk_2_84A:        /* set %a0@(10) */
    movew #20,%a0@(10)	| 408D9FFA
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    moveal SCCRd,%a0
    moveal SCCWr,%a1
    addqw #2,%a0
    addqw #2,%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    tstb %a2@(1547)
    jbne rsrc_ltlk_2_894
    addqb #1,%a2@(1739)
    cmpib #30,%a2@(1739)
    jbne rsrc_ltlk_2_702_A6
    clrb %a2@(1739)
    moveb #3,%a1@
    nop
    moveb %a2@(1750),%a1@
    jbra rsrc_ltlk_2_702_A6
rsrc_ltlk_2_894:        /* subtract 1 to %a2@(1547) */
    subqb #1,%a2@(1547)
    jbne rsrc_ltlk_2_702_A6
    moveb #15,%a1@
    moveb #8,%d0
    moveb %d0,%a1@
    jbsr rsrc_ltlk_2_C02
    addql #1,%a2@(1710)
    bclr #1,%a2@(1734)
    bclr #0,%a2@(1734)
    jbeq rsrc_ltlk_2_702_A6
    addqw #2,%sp
    movew %sr,%d0
    andiw #-1793,%d0
    eoriw #8192,%d0
    movew %a2@(28),%sp@-
    eorw %d0,%sp@
    movew %sp@+,%sr
    jbra rsrc_ltlk_2_5F8_24

/* subroutine (9 instructions): calls rsrc_ltlk_2_9F0 (mechanical summary) */
rsrc_ltlk_2_8D6:
    moveml %a0-%a3,%sp@-
    movew %a2@(1564),%d1
    moveal %a0,%a0
rsrc_ltlk_2_8D6_A:      /* loop: btst */
    btst #0,%a0@
    dbne %d1,rsrc_ltlk_2_8D6_A
    jbeq rsrc_ltlk_2_8D6_18
    jbsr rsrc_ltlk_2_9F0
rsrc_ltlk_2_8D6_18:     /* restore registers, return */
    moveml %sp@+,%a0-%a3
    rts

/* subroutine (9 instructions) (mechanical summary) */
rsrc_ltlk_2_8F4:
    movew %a2@(1540),%d0
    muluw #773,%d0
    addqw #1,%d0
    movew %d0,%sp@-
    lslw #8,%d0
    moveb %sp@+,%d0
    movew %d0,%a2@(1540)
    rts
rsrc_ltlk_2_90A:        /* from here: bchg %d2,%a3@(976) */
    bchg %d2,%a3@(976)	| 408DA0BA

/* subroutine (8 instructions) (mechanical summary) */
rsrc_ltlk_2_90E:
    movew %a2@(1560),%d1
    moveal %a0,%a0
rsrc_ltlk_2_90E_6:      /* loop: btst */
    btst #2,%a0@
    dbne %d1,rsrc_ltlk_2_90E_6
    jbeq rsrc_ltlk_2_90E_14
    moveb %d3,%a1@(4)
rsrc_ltlk_2_90E_14:     /* test %d1 */
    tstw %d1
    rts

/* subroutine (7 instructions): calls rsrc_ltlk_2_9DA (mechanical summary) */
rsrc_ltlk_2_926:
    lea %pc@(rsrc_ltlk_2_90A),%a3
    moveq #4,%d3
    jbsr rsrc_ltlk_2_9DA
    movew %a2@(1566),%d3
rsrc_ltlk_2_926_E:      /* count down (loop) */
    dbf %d3,rsrc_ltlk_2_926_E
    moveb #0x80,%a1@
    rts

/* subroutine (25 instructions): calls rsrc_ltlk_2_926, rsrc_ltlk_2_9D4, rsrc_ltlk_2_9AE (mechanical summary) */
rsrc_ltlk_2_93E:
    moveml %a0-%a1/%a4-%fp,%a2@(1612)
    moveal %a2@(1532),%a4
    jbsr rsrc_ltlk_2_926
    movew %a4@+,%d3
    moveal %a4@+,%a3
    moveb %a3@+,%a1@(4)
    subqw #1,%d3
    moveb %a2@,%a3@
rsrc_ltlk_2_93E_18:     /* loop: move */
    movew %a2@(1560),%d0
    moveal %a0,%a0
rsrc_ltlk_2_93E_1E:     /* loop: btst */
    btst #2,%a0@
    dbne %d0,rsrc_ltlk_2_93E_1E
    jbne rsrc_ltlk_2_93E_2C
    jbsr rsrc_ltlk_2_9D4
    jbra rsrc_ltlk_2_93E_3E
rsrc_ltlk_2_93E_2C:     /* set %a1@(4) */
    moveb %a3@+,%a1@(4)
    subqw #1,%d3
    jbgt rsrc_ltlk_2_93E_18
    movew %a4@+,%d3
    jbeq rsrc_ltlk_2_93E_3C
    moveal %a4@+,%a3
    jbra rsrc_ltlk_2_93E_18
rsrc_ltlk_2_93E_3C:     /* call rsrc_ltlk_2_9AE */
    jbsr rsrc_ltlk_2_9AE
rsrc_ltlk_2_93E_3E:     /* set %a0-%a1/%a4-%fp */
    moveml %a2@(1612),%a0-%a1/%a4-%fp
    rts

/* subroutine (14 instructions): calls rsrc_ltlk_2_926, rsrc_ltlk_2_90E (mechanical summary) */
rsrc_ltlk_2_984:
    jbsr rsrc_ltlk_2_926
    moveb %d2,%a1@(4)
    moveb %d2,%d3
    cmpib #0x82,%d0
    jbeq rsrc_ltlk_2_984_1C
    cmpib #0x81,%d0
    jbeq rsrc_ltlk_2_984_1C
    moveb %a2@(1738),%d3
    moveb %a2@,%a2@(1738)
rsrc_ltlk_2_984_1C:     /* call rsrc_ltlk_2_90E */
    jbsr rsrc_ltlk_2_90E
    jbmi rsrc_ltlk_2_9D4
    moveb %d0,%d3
    jbsr rsrc_ltlk_2_90E
    jbmi rsrc_ltlk_2_9D4

/* subroutine (12 instructions) (mechanical summary) */
rsrc_ltlk_2_9AE:
    moveb #0xc0,%a1@
    lslw #1,%d3
rsrc_ltlk_2_9AE_6:      /* loop: btst */
    btst #6,%a0@
    jbeq rsrc_ltlk_2_9AE_6
rsrc_ltlk_2_9AE_C:      /* loop: btst */
    btst #2,%a0@
    jbeq rsrc_ltlk_2_9AE_C
    moveb #5,%a1@
    moveq #0,%d3
    moveb #98,%a1@
    movew %a2@(1556),%d3
    moveal %a0,%a0
rsrc_ltlk_2_9AE_22:     /* count down (loop) */
    dbf %d3,rsrc_ltlk_2_9AE_22

/* subroutine (2 instructions) (mechanical summary) */
rsrc_ltlk_2_9D4:
    lea %a2@(1636),%a3
    moveq #6,%d3

/* subroutine (8 instructions): low memory ExpandMem (mechanical summary) */
rsrc_ltlk_2_9DA:
    moveb %a3@+,%a1@
    subqw #1,%d3
    jbne rsrc_ltlk_2_9DA
    rts
rsrc_ltlk_2_9DA_8:      /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    addql #1,%a2@(1666)
    jbra rsrc_ltlk_2_9F0_E

/* subroutine (64 instructions): calls rsrc_ltlk_2_ABE; low memory ExpandMem, SCCRd, SCCWr, ATalkHk2 (mechanical summary) */
rsrc_ltlk_2_9F0:
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    moveal SCCRd,%a0
    addqw #2,%a0
rsrc_ltlk_2_9F0_E:      /* clear %d1 */
    moveq #0,%d1
    moveb %a0@(4),%d1
    moveal %a2@(700),%a3
    lea %a3@(1),%a3
    moveb %d1,%a3@+
    moveb %d1,%a2@(1)
    movew %a2@(1558),%d0
    addw %d0,%d0
rsrc_ltlk_2_9F0_28:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_2_9F0_28
    jbeq rsrc_ltlk_2_9F0_44
    moveb %a0@(4),%a3@
    moveb %a3@+,%a2@(2)
    moveal %a0,%a0
rsrc_ltlk_2_9F0_3C:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_2_9F0_3C
rsrc_ltlk_2_9F0_44:     /* from here: jbeq rsrc_ltlk_2_B9E */
    jbeq rsrc_ltlk_2_B9E
    moveb %a0@(4),%d0
    addw %d1,%d1
    lea %a2@(1754),%a1
    movew %a1@(0x0,%d1:w),%d2
    jbeq rsrc_ltlk_2_B62_8
    moveal SCCWr,%a1
    addqw #2,%a1
    moveb %d0,%a3@+
    jbmi rsrc_ltlk_2_ABE_1C
    swap %d2
    moveb %d0,%d2
    movew %a2@(1558),%d0
    addw %d0,%d0
    moveml %a4-%a5,%a2@(766)
    moveal %a2@(700),%a2
    moveal ATalkHk2,%a5
    lea %pc@(rsrc_ltlk_2_C90),%a4
    moveal %a0,%a0
rsrc_ltlk_2_9F0_84:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_2_9F0_84
    jbeq rsrc_ltlk_2_ABE_16
    moveb %a0@(4),%a3@
    moveq #3,%d1
    andb %a3@+,%d1
    lslw #8,%d1
rsrc_ltlk_2_9F0_98:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_2_9F0_98
    jbeq rsrc_ltlk_2_ABE_16
    moveb %a0@(4),%d1
    moveb %d1,%a3@+
    cmpiw #600,%d1
    jbgt rsrc_ltlk_2_ABE_10
    subqw #2,%d1
    moveq #1,%d0
    jsr %a5@(2)
    jbsr rsrc_ltlk_2_ABE
    moveb #1,%a1@
    moveq #-96,%d0
    andb %a0@,%d0
    jbne rsrc_ltlk_2_C50_10
    addql #1,%a2@(1690)
    clrw %d3
    jbra rsrc_ltlk_2_C92

/* subroutine (54 instructions): calls rsrc_ltlk_2_ABE, rsrc_ltlk_2_BB4, rsrc_ltlk_2_B62; low memory ExpandMem (mechanical summary) */
rsrc_ltlk_2_ABE:
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    moveml %a2@(766),%a4-%a5
    rts
rsrc_ltlk_2_ABE_10:     /* call rsrc_ltlk_2_ABE */
    jbsr rsrc_ltlk_2_ABE
    jbra rsrc_ltlk_2_C50_1A
rsrc_ltlk_2_ABE_16:     /* call rsrc_ltlk_2_ABE */
    jbsr rsrc_ltlk_2_ABE
    jbra rsrc_ltlk_2_B9E
rsrc_ltlk_2_ABE_1C:     /* set %d2 */
    moveq #127,%d2
    andb %d0,%d2
    cmpib #5,%d2
    jbgt rsrc_ltlk_2_B62_36
    jbsr rsrc_ltlk_2_BB4
    jbne rsrc_ltlk_2_ABE_4E
    moveq #0,%d0
    moveb %a2@(1),%d0
    cmpib #0xff,%d0
    seq %d1
    jbeq rsrc_ltlk_2_ABE_50
    addw %d0,%d0
    lea %a2@(1754),%a3
    addaw %d0,%a3
    cmpiw #-32768,%a3@
    jbne rsrc_ltlk_2_ABE_50
    movew #-32767,%a3@
rsrc_ltlk_2_ABE_4E:     /* return */
    rts
rsrc_ltlk_2_ABE_50:     /* subtract 1 to %d2 */
    subqb #1,%d2
    jbeq rsrc_ltlk_2_ABE_98
    subqb #3,%d2
    jbeq rsrc_ltlk_2_ABE_6A
    tstb %a2@(1544)
    jbeq rsrc_ltlk_2_ABE_62
    addql #1,%a2@(1722)
rsrc_ltlk_2_ABE_62:     /* subtract 1 to %d2 */
    subqb #1,%d2
    seq %a2@(1544)
    rts
rsrc_ltlk_2_ABE_6A:     /* test %d1 */
    tstb %d1
    jbne rsrc_ltlk_2_ABE_80
    movew %a2@(1568),%d0
rsrc_ltlk_2_ABE_72:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_2_ABE_72
    moveq #-123,%d0
    moveb %a2@(1),%a2@(1738)
    jbsr rsrc_ltlk_2_B62
rsrc_ltlk_2_ABE_80:     /* set %d1 */
    movew %a2@(1562),%d1
    moveal %a0,%a0
rsrc_ltlk_2_ABE_86:     /* loop: btst */
    btst #0,%a0@
    dbne %d1,rsrc_ltlk_2_ABE_86
    jbne rsrc_ltlk_2_9F0
    addql #1,%a2@(1718)
    rts
rsrc_ltlk_2_ABE_98:     /* set %d0 */
    movew %a2@(1568),%d0
    moveal %a0,%a0
rsrc_ltlk_2_ABE_9E:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_2_ABE_9E
    moveq #-126,%d0

/* subroutine (21 instructions): calls rsrc_ltlk_2_C02; low memory SCCWr, ExpandMem (mechanical summary) */
rsrc_ltlk_2_B62:
    moveb %a2@(2),%d2
    jbra rsrc_ltlk_2_984
rsrc_ltlk_2_B62_8:      /* test bit 0 of %a2@(1734) */
    btst #0,%a2@(1734)
    jbne rsrc_ltlk_2_C02
    moveal SCCWr,%a1
    addqw #2,%a1
    moveb #15,%a1@
    moveb #0x88,%d0
    moveb %d0,%a1@
    bset #1,%a2@(1734)
    moveb #2,%a2@(1547)
    jbra rsrc_ltlk_2_C02
    addql #1,%a2@(1690)
    bras rsrc_ltlk_2_C02
rsrc_ltlk_2_B62_36:     /* add 1 to %a2@(1698) */
    addql #1,%a2@(1698)
    jbra rsrc_ltlk_2_C02

rsrc_ltlk_2_B9E:        /* add 1 to %a2@(1686) */
    addql #1,%a2@(1686)
    jbra rsrc_ltlk_2_C02
rsrc_ltlk_2_B9E_6:      /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    addql #1,%a2@(1726)
    jbsr rsrc_ltlk_2_C02
    jbra rsrc_ltlk_2_C02

/* subroutine (24 instructions) (mechanical summary) */
rsrc_ltlk_2_BB4:
    clrw %d0
    movew %a2@(1558),%d1
    moveal %a0,%a0
rsrc_ltlk_2_BB4_8:      /* loop: btst */
    btst #0,%a0@
    dbne %d1,rsrc_ltlk_2_BB4_8
    jbeq rsrc_ltlk_2_C50_22
    moveb #1,%a1@
    nop
    moveb %a0@,%d1
    jbmi rsrc_ltlk_2_C50_14
    tstb %a0@(4)
    movew %a2@(1558),%d1
rsrc_ltlk_2_BB4_28:     /* loop: btst */
    btst #0,%a0@
    dbne %d1,rsrc_ltlk_2_BB4_28
    jbeq rsrc_ltlk_2_C50_22
    moveb #1,%a1@
    nop
    moveb %a0@,%d1
    jbpl rsrc_ltlk_2_C50_14
    lslb #1,%d1
    jbmi rsrc_ltlk_2_C50_2A
    movew %a2@(1572),%d1
rsrc_ltlk_2_BB4_48:     /* count down (loop) */
    dbf %d1,rsrc_ltlk_2_BB4_48
    jbra rsrc_ltlk_2_C02_40

/* subroutine (25 instructions): low memory SCCRd, SCCWr, IntFlag (mechanical summary) */
rsrc_ltlk_2_C02:
    moveal SCCRd,%a0
    moveal SCCWr,%a1
    addqw #2,%a0
    addqw #2,%a1
    clrb %a2@(1739)
    moveb #1,%a1@
    nop
    btst #5,%a0@
    jbeq rsrc_ltlk_2_C02_22
    bclr #7,IntFlag
rsrc_ltlk_2_C02_22:     /* set %a1@ */
    moveb #3,%a1@
    nop
    moveb %a2@(1750),%a1@
    nop
    moveq #2,%d1
rsrc_ltlk_2_C02_30:     /* loop: tst */
    tstb %a0@(4)
    nop
    moveb #48,%a1@
    nop
    dbf %d1,rsrc_ltlk_2_C02_30
rsrc_ltlk_2_C02_40:     /* set %a1@ */
    moveb #48,%a1@
    nop
    moveb #32,%a1@
    tstw %d0
    rts

/* subroutine (85 instructions): calls rsrc_ltlk_2_BB4, rsrc_ltlk_2_C02, rsrc_ltlk_2_D48; low memory SCCWr, ExpandMem (mechanical summary) */
rsrc_ltlk_2_C50:
    moveal SCCWr,%a1
    addqw #2,%a1
    moveb #3,%a1@
    nop
    moveb %d1,%a1@
    rts
rsrc_ltlk_2_C50_10:     /* set %d1 */
    moveb %d0,%d1
    moveq #0,%d0
rsrc_ltlk_2_C50_14:     /* test bit 5 of %d1 */
    btst #5,%d1
    jbne rsrc_ltlk_2_C50_32
rsrc_ltlk_2_C50_1A:     /* add 1 to %a2@(1694) */
    addql #1,%a2@(1694)
    moveq #-4,%d0
    jbra rsrc_ltlk_2_C02
rsrc_ltlk_2_C50_22:     /* add 1 to %a2@(1686) */
    addql #1,%a2@(1686)
    moveq #-3,%d0
    jbra rsrc_ltlk_2_C02
rsrc_ltlk_2_C50_2A:     /* add 1 to %a2@(1678) */
    addql #1,%a2@(1678)
    moveq #-2,%d0
    jbra rsrc_ltlk_2_C02
rsrc_ltlk_2_C50_32:     /* add 1 to %a2@(1682) */
    addql #1,%a2@(1682)
    moveq #-1,%d0
    jbra rsrc_ltlk_2_C02
rsrc_ltlk_2_C8C:        /* continue at rsrc_ltlk_2_CD4 */
    jbra rsrc_ltlk_2_CD4	| 408DA43C
    .byte   0x00, 0x00	| 408DA43E
rsrc_ltlk_2_C90:        /* continue at rsrc_ltlk_2_C8C */
    jbra rsrc_ltlk_2_C8C	| 408DA440

rsrc_ltlk_2_C92:        /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    moveal %sp,%a4
rsrc_ltlk_2_C92_A:      /* loop: move */
    movew %a2@(1558),%d0
    subqw #1,%d1
    jbmi rsrc_ltlk_2_C92_28
rsrc_ltlk_2_C92_12:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_2_C92_12
    jbeq rsrc_ltlk_2_C92_28
    moveb %a0@(4),%d0
    subqw #1,%d3
    jbmi rsrc_ltlk_2_C92_A
    moveb %d0,%a3@+
    jbra rsrc_ltlk_2_C92_A
rsrc_ltlk_2_C92_28:     /* call rsrc_ltlk_2_BB4 */
    jbsr rsrc_ltlk_2_BB4
rsrc_ltlk_2_C92_2C:     /* loop: movem */
    moveml %a2@(766),%a4-%a5
    tstw %d0
    jbne rsrc_ltlk_2_C92_3A
    addql #1,%a2@(1670)
rsrc_ltlk_2_C92_3A:     /* test %d0 */
    tstw %d0
rsrc_ltlk_2_C92_3C:     /* loop: movea */
    moveal %a2@(700),%a2
    rts
rsrc_ltlk_2_CD4:        /* set %a2 */
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    subw %d3,%d1
rsrc_ltlk_2_C92_4C:     /* loop: move */
    movew %a2@(1558),%d0
    moveal %a0,%a0
rsrc_ltlk_2_C92_52:     /* loop: btst */
    btst #0,%a0@
    dbne %d0,rsrc_ltlk_2_C92_52
    jbeq rsrc_ltlk_2_C92_78
    moveb %a0@(4),%a3@+
    subqw #1,%d3
    jbne rsrc_ltlk_2_C92_4C
    moveb #1,%a1@
    moveq #-96,%d0
    andb %a0@,%d0
    jbeq rsrc_ltlk_2_C92_3C
    jbmi rsrc_ltlk_2_C92_80
    addql #1,%a2@(1682)
    moveq #-1,%d0
    jbra rsrc_ltlk_2_C92_86
rsrc_ltlk_2_C92_78:     /* add 1 to %a2@(1686) */
    addql #1,%a2@(1686)
    moveq #-3,%d0
    jbra rsrc_ltlk_2_C92_86
rsrc_ltlk_2_C92_80:     /* add 1 to %a2@(1694) */
    addql #1,%a2@(1694)
    moveq #-4,%d0
rsrc_ltlk_2_C92_86:     /* call rsrc_ltlk_2_C02 */
    jbsr rsrc_ltlk_2_C02
    jbra rsrc_ltlk_2_C92_2C
    .short  0x4E71	| 408DA4CE
    movel %a2,%sp@-
    moveal ExpandMem,%a2
    moveal %a2@(256),%a2
    moveq #0,%d0
    moveb %a0@(31),%d0
    bsrw rsrc_ltlk_2_D48
    movew %d0,%a0@(42)
    jbne rsrc_ltlk_2_C92_AE
    movew #-50,%d0
    jbra rsrc_ltlk_2_C92_B0
rsrc_ltlk_2_C92_AE:     /* clear %d0 */
    moveq #0,%d0
rsrc_ltlk_2_C92_B0:     /* set %a2 */
    moveal %sp@+,%a2
    rts
    .short  0x4E71	| 408DA4F6

/* subroutine (7 instructions) (mechanical summary) */
rsrc_ltlk_2_D48:
    movel %a0,%sp@-
    andil #255,%d0
    addw %d0,%d0
    lea %a2@(1754),%a0
    movew %a0@(0x0,%d0:w),%d0
    moveal %sp@+,%a0
    rts
    .short  0x4E71	| 408DA50E

/* subroutine (7 instructions) (mechanical summary) */
rsrc_ltlk_2_D60:
    movel %a0,%sp@-
    andiw #255,%d0
    addw %d0,%d0
    lea %a2@(1754),%a0
    movew %d1,%a0@(0x0,%d0:w)
    moveal %sp@+,%a0
    rts

/* subroutine (67 instructions): traps InsTime, RmvTime, PrimeTime; low memory ROMBase, TimeDBRA (mechanical summary) */
rsrc_ltlk_2_D74:
    moveal ROMBase,%a0
    cmpib #117,%a0@(9)
    jbcs rsrc_ltlk_2_D74_2A
    subaw #14,%sp
    moveal %sp,%a0
    clrl %a0@(10)
    movew #-1,%a0@(4)
    _InsTime
    moveb %a0@(4),%d0
    jbpl rsrc_ltlk_2_D74_30
    _RmvTime
    addaw #14,%sp
rsrc_ltlk_2_D74_2A:     /* set %d0 */
    movew TimeDBRA,%d0
    rts
rsrc_ltlk_2_D74_30:     /* _RmvTime */
    _RmvTime
    addaw #14,%sp
    moveml %d4-%d7,%sp@-
    moveq #6,%d0
rsrc_ltlk_2_D74_3C:     /* loop: clr */
    clrw %sp@-
    dbf %d0,rsrc_ltlk_2_D74_3C
    moveq #9,%d4
    movel #65535,%d5
rsrc_ltlk_2_D74_4A:     /* loop: move */
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
rsrc_ltlk_2_D74_88:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_2_D74_88
    movew TimeDBRA,%d0
rsrc_ltlk_2_D74_90:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_2_D74_90
    movew TimeDBRA,%d0
rsrc_ltlk_2_D74_98:     /* count down (loop) */
    dbf %d0,rsrc_ltlk_2_D74_98
    movew TimeDBRA,%d0
rsrc_ltlk_2_D74_A0:     /* set up and call _RmvTime (loop) */
    dbf %d0,rsrc_ltlk_2_D74_A0
    _RmvTime
    movew %sp@+,%sr
    addl %a0@(10),%d6
    subl %d7,%d6
    cmpl %d6,%d5
    jbcs rsrc_ltlk_2_D74_B4
    movel %d6,%d5
rsrc_ltlk_2_D74_B4:     /* count down */
    dbf %d4,rsrc_ltlk_2_D74_4A
    movew TimeDBRA,%d1
    muluw #4000,%d1
    divuw %d5,%d1
    movew %d1,%d0
    addaw #14,%sp
    moveml %sp@+,%d4-%d7
    rts
    .short  0x0000	| 408DA5F2

/* subroutine (73 instructions): traps InsTime, RmvTime, PrimeTime; low memory ROMBase, TimeSCCDB, SCCRd (mechanical summary) */
rsrc_ltlk_2_E44:
    moveal ROMBase,%a0
    cmpib #117,%a0@(9)
    jbcs rsrc_ltlk_2_E44_2A
    subaw #14,%sp
    moveal %sp,%a0
    clrl %a0@(10)
    movew #-1,%a0@(4)
    _InsTime
    moveb %a0@(4),%d0
    jbpl rsrc_ltlk_2_E44_30
    _RmvTime
    addaw #14,%sp
rsrc_ltlk_2_E44_2A:     /* set %d0 */
    movew TimeSCCDB,%d0
    rts
rsrc_ltlk_2_E44_30:     /* _RmvTime */
    _RmvTime
    addaw #14,%sp
    moveml %d4-%d7,%sp@-
    moveq #6,%d0
rsrc_ltlk_2_E44_3C:     /* loop: clr */
    clrw %sp@-
    dbf %d0,rsrc_ltlk_2_E44_3C
    moveq #9,%d4
    movel #65535,%d5
rsrc_ltlk_2_E44_4A:     /* loop: move */
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
rsrc_ltlk_2_E44_8C:     /* loop: btst */
    btst #0,%a1@
    dbf %d0,rsrc_ltlk_2_E44_8C
    movew TimeSCCDB,%d0
rsrc_ltlk_2_E44_98:     /* loop: btst */
    btst #0,%a1@
    dbf %d0,rsrc_ltlk_2_E44_98
    movew TimeSCCDB,%d0
rsrc_ltlk_2_E44_A4:     /* loop: btst */
    btst #0,%a1@
    dbf %d0,rsrc_ltlk_2_E44_A4
    movew TimeSCCDB,%d0
rsrc_ltlk_2_E44_B0:     /* set up and call _RmvTime (loop) */
    btst #0,%a1@
    dbf %d0,rsrc_ltlk_2_E44_B0
    _RmvTime
    movew %sp@+,%sr
    addl %a0@(10),%d6
    subl %d7,%d6
    cmpl %d6,%d5
    jbcs rsrc_ltlk_2_E44_C8
    movel %d6,%d5
rsrc_ltlk_2_E44_C8:     /* count down */
    dbf %d4,rsrc_ltlk_2_E44_4A
    movew TimeSCCDB,%d1
    muluw #4000,%d1
    divuw %d5,%d1
    movew %d1,%d0
    addaw #14,%sp
    moveml %sp@+,%d4-%d7
    rts
    .byte   0x00, 0x00	| 408DA6D6
    FILL_408DA6D8
