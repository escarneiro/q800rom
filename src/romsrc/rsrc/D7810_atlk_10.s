/* ROM resource 'atlk' 10: map entry at 0x408D7810, data at 0x408D7840, 4142 bytes

 EtherTalk link code ('atlk' 10, "EtherTalk adev v2.3.1": AppleTalk over Ethernet, with AARP address resolution, through the .ENET driver), (c) Apple 1984-1992.
 Loaded by the LAP Manager (lmgr 0) for the network connection chosen in parameter RAM;
 .MPP sends and receives through it. Comments inferred; routines summarised mechanically.
*/

rsrc_atlk_10_entry:     /* map entry */
    .long   0x38000000, 0x00000000	| 408D7810
    .long   rsrc_DRVR_127__ENET_entry-rom_start	| 408D7818
    .long   rsrc_atlk_10-rom_start	| 408D781C
    .ascii  "atlk"	| 408D7820
    .byte   0x00, 0x0A, 0x58, 0x00	| 408D7824
    FILL_408D7828
    .byte   0xC0, 0xA0, 0x00, 0x00	| 408D7834
    .short  0x0000, 0x103A	| orib #58,%d0
    .short  0x0000, 0x0314	| orib #20,%d0

/* subroutine (5 instructions) (mechanical summary) */
rsrc_atlk_10:
    jbra rsrc_atlk_10_6C
    bras rsrc_atlk_10_8
    .short  0x0000, 0x0098	| orib #-104,%d0
rsrc_atlk_10_8:
    cmpiw #1,%d0
    beqw rsrc_atlk_10_94_4C	| 408D784C
    pea %pc@(rsrc_atlk_10_20)
    moveml %d0/%a0,%sp@-
    movew #8,%d0
    braw rsrc_atlk_10_101A
rsrc_atlk_10_20:
    cmpiw #11,%d0
    beqw rsrc_atlk_10_A0A
    cmpiw #2,%d0
    beqw rsrc_atlk_10_340_14	| 408D786C
    cmpiw #3,%d0
    beqw rsrc_atlk_10_3C8_38_14
    cmpiw #4,%d0
    beqw rsrc_atlk_10_3C8_D2_2	| 408D787C
    cmpiw #5,%d0
    beqw rsrc_atlk_10_3C8_D2_20	| 408D7884
    cmpiw #6,%d0
    beqw rsrc_atlk_10_3C8_D2_36	| 408D788C
    cmpiw #9,%d0
    beqw rsrc_atlk_10_76C
    cmpiw #10,%d0
    beqw rsrc_atlk_10_9DC
    cmpiw #8,%d0
    beqw rsrc_atlk_10_3C8
    moveq #-1,%d0
    rts

rsrc_atlk_10_6C:        /* from here: pea %pc@(rsrc_atlk_10_7A) */
    pea %pc@(rsrc_atlk_10_7A)
    moveml %d0/%a0,%sp@-
    clrw %d0
    jbra rsrc_atlk_10_101A

/* subroutine (293 instructions): traps BlockMove, trap_A404, Control; calls rsrc_atlk_10_C60, rsrc_atlk_10_A2C, rsrc_atlk_10_A62, rsrc_atlk_10_AC6; low memory ENET, ENET0, Ticks (mechanical summary) */
rsrc_atlk_10_7A:
    cmpib #1,%d0	| 408D78BA
    jbeq rsrc_atlk_10_6AC	| 408D78BE
    cmpib #0,%d0	| 408D78C2
    jbeq rsrc_atlk_10_500	| 408D78C6
    cmpib #0xff,%d0	| 408D78CA
    jbeq rsrc_atlk_10_700	| 408D78CE
    jmp %a0@	| 408D78D2
rsrc_atlk_10_94:        /* (data) */
    .byte   0x00, 0x00, 0x00, 0x00, 0x02, 0x31, 0x80, 0x00, 0x00, 0x00, 0x07, 0x32, 0x2E, 0x33, 0x2E, 0x31	| 408D78D4
    .byte   0x20, 0x20, 0x39, 0x45, 0x74, 0x68, 0x65, 0x72, 0x54, 0x61, 0x6C, 0x6B, 0x20, 0x61, 0x64, 0x65	| 408D78E4
    .byte   0x76, 0x20, 0x76, 0x32, 0x2E, 0x33, 0x2E, 0x31, 0x20, 0x20, 0x3B, 0x20, 0xA9, 0x20, 0x41, 0x70	| 408D78F4
    .byte   0x70, 0x6C, 0x65, 0x20, 0x43, 0x6F, 0x6D, 0x70, 0x75, 0x74, 0x65, 0x72, 0x2C, 0x20, 0x49, 0x6E	| 408D7904
    .byte   0x63, 0x2E, 0x20, 0x31, 0x39, 0x38, 0x37, 0x2D, 0x31, 0x39, 0x39, 0x32	| 408D7914
rsrc_atlk_10_94_4C:     /* open: 4082 bytes of globals, their pointer kept at _94; a linked list of 8-byte entries from +2028 */
    moveml %d3/%a3,%sp@-	| 408D7920
    movel #4082,%d0
    .short  0xA71E	| _NewPtr (flags 0x0700)
    bnew rsrc_atlk_10_340
    lea %pc@(rsrc_atlk_10_94),%a3
    movel %a0,%a3@
    moveal %a0,%a3
    lea %a3@(2028),%a0
    movel %a0,%a3@(4076)
    moveal %a0,%a1
    movew #254,%d0
rsrc_atlk_10_94_72:
    addql #8,%a0	| 408D7946
    movel %a0,%a1@
    addql #8,%a1
    dbf %d0,rsrc_atlk_10_94_72
    clrl %a0@
    movel %d1,%sp@-
    movel %d2,%sp@-
    moveq #0,%d2
    moveb #0xff,%d2
    movew #-1,%d1
    bsrw rsrc_atlk_10_A62
    movel %sp@+,%d2
    movel %sp@+,%d1
    /* +328 = 6, or the first word of resource 'aarp' (id from d1) */
    movew #6,%a3@(328)
    subqw #4,%sp
    movel #1633776240,%sp@-
    movel %d1,%d0
    swap %d0
    lsrw #8,%d0
    movew %d0,%sp@-
    _GetResource
    movel %sp@+,%d0
    beqs rsrc_atlk_10_94_BC
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0,%d0
    beqs rsrc_atlk_10_94_BC
    movew %a0@,%a3@(328)
rsrc_atlk_10_94_BC:     /* no slot number (d1 negative) or no Slot Manager: _Open by name (_DC); otherwise with the slot (_F4) */
    bsrw rsrc_atlk_10_C20	| 408D7990
    swap %d1
    movew %d1,%a3@(50)
    blts rsrc_atlk_10_94_DC
    movew %d1,%d2
    movew #-24466,%d0
    .short  0xA346	| _GetTrapAddress (flags 0x0300)
    movel %a0,%sp@-
    movew #-22369,%d0
    .short  0xA746	| _GetTrapAddress (flags 0x0700)
    cmpal %sp@+,%a0
    bnes rsrc_atlk_10_94_F4
rsrc_atlk_10_94_DC:
    lea %a3@(16),%a0	| 408D79B0
    clrb %a0@(35)
    lea %pc@(rsrc_atlk_10_340+0xc),%a1
    movel %a1,%a0@(18)
    _Open
    bnew rsrc_atlk_10_94_29A
    bras rsrc_atlk_10_94_16A
rsrc_atlk_10_94_F4:
    lea %a3@(16),%a0	| 408D79C8
    lea %pc@(rsrc_atlk_10_340+0x6),%a1
    movel %a1,%a0@(18)
    .short  0xA200	| _Open (flags 0x0200)
    beqs rsrc_atlk_10_94_16A
    tstb %a3@(50)
    beqw rsrc_atlk_10_94_29A
    /* open failed: count the network cards (Slot Manager 21, category 4, type 1). Exactly one, other than the slot tried: open that one */
    movel %d0,%sp@-
    moveq #27,%d0
rsrc_atlk_10_94_110:
    clrw %sp@-	| 408D79E4
    dbf %d0,rsrc_atlk_10_94_110
    clrw %d3
    moveal %sp,%a0
    moveb #1,%a0@(49)
rsrc_atlk_10_94_120:
    movew #4,%a0@(40)	| 408D79F4
    moveb #3,%a0@(48)
    movew #1,%a0@(42)
    moveq #21,%d0
    _SlotManager
    bnes rsrc_atlk_10_94_148
    movew %a0@(49),%d1
    addqb #1,%a0@(49)
    clrb %a0@(50)
    addqb #1,%d3
    bras rsrc_atlk_10_94_120
rsrc_atlk_10_94_148:
    lea %sp@(56),%sp	| 408D7A1C
    movel %sp@+,%d0
    cmpib #1,%d3
    bnew rsrc_atlk_10_94_29A
    cmpw %d1,%d2
    beqw rsrc_atlk_10_94_29A
    lea %a3@(16),%a0
    movew %d1,%a0@(34)
    .short  0xA200	| _Open (flags 0x0200)
    bnew rsrc_atlk_10_94_29A
rsrc_atlk_10_94_16A:    /* two calls through ATalkHk2 (+2, selector 21), each with a handler pair */
    swap %d1	| 408D7A3E
    moveml %d1/%a0,%sp@-
    movew %a0@(24),%d2
    lea %pc@(rsrc_atlk_10_AC6_52_6),%a0
    lea %pc@(rsrc_atlk_10_C8A_14),%a1
    moveq #21,%d0
    moveal ATalkHk2,%a2
    jsr %a2@(2)
    moveml %sp@+,%d1/%a0
    bnew rsrc_atlk_10_94_29A
    moveml %d1/%a0,%sp@-
    movew %a0@(24),%d2
    lea %pc@(rsrc_atlk_10_76C_C8+0x6),%a0
    lea %pc@(rsrc_atlk_10_C8A_14_9),%a1
    moveq #21,%d0
    moveal ATalkHk2,%a2
    jsr %a2@(2)
    moveml %sp@+,%d1/%a0
    bnew rsrc_atlk_10_94_29A
    /* add the AppleTalk broadcast 09-00-07-FF-FF-FF (ENetAddMulti, 246) */
    movew #246,%a0@(26)
    lea %a0@(28),%a1
    movel #150996736,%a1@
    st %a1@(3)
    st %a1@(4)
    st %a1@(5)
    _Control
    bnew rsrc_atlk_10_94_29A
    /* our Ethernet address into +206 (ENetGetInfo, 252) */
    movew #252,%a0@(26)
    movew #6,%a0@(34)
    lea %a3@(206),%a1
    movel %a1,%a0@(30)
    _Control
    /* an AARP packet template at +226 (ENetWrite, 249): SNAP 0xAAAA, type 0x80F3, hardware 1, protocol 0x809B, sizes 6 and 4, our address */
    movew #249,%a0@(26)
    lea %a3@(226),%a1
    movel #150996736,%a1@
    st %a1@(3)
    st %a1@(4)
    st %a1@(5)
    lea %a1@(12),%a1
    movew #36,%a1@+
    movew #-21846,%a1@+
    moveb #3,%a1@+
    clrb %a1@+
    clrw %a1@+
    movew #-32525,%a1@+
    movew #1,%a1@+
    movew #-32613,%a1@+
    moveb #6,%a1@+
    moveb #4,%a1@+
    addqw #2,%a1
    movel %a3@(206),%a1@+
    movew %a3@(210),%a1@+
    lea %a3@(74),%a1
    moveq #58,%d0
    _BlockMove
    lea %a3@(124),%a0
    movel %a0,%a1@(30)
    movew #50,%a0@+
    /* a second AARP header at +276 */
    lea %a3@(276),%a1
    movel %a1,%a0@
    lea %a1@(12),%a1
    movew #36,%a1@+
    movew #-21846,%a1@+
    moveb #3,%a1@+
    clrb %a1@+
    clrw %a1@+
    movew #-32525,%a1@+
    /* VBL task at +212, every 3600 ticks */
    lea %a3@(212),%a0
    movew #1,%a0@(4)
    lea %pc@(rsrc_atlk_10_5F2_4),%a1
    movel %a1,%a0@(6)
    movew #3600,%a0@(10)
    _VInstall
    /* the last call through ATalkHk2 (selector 2) */
    clrb %d1
    moveq #2,%d0
    movew #-768,%d2
    lea %pc@(rsrc_atlk_10),%a0
    moveal ATalkHk2,%a1
    jsr %a1@(2)
    moveq #0,%d0
    jbra rsrc_atlk_10_340
rsrc_atlk_10_94_29A:    /* failure: undo (_CB6_B0_6), free the globals */
    movel %d0,%sp@-	| 408D7B6E
    bsrw rsrc_atlk_10_CB6_B0_6
    moveal %a3,%a0
    _DisposPtr
    lea %pc@(rsrc_atlk_10_94),%a3
    clrl %a3@
    movel %sp@+,%d0
rsrc_atlk_10_340:       /* restore registers, return */
    moveml %sp@+,%d3/%a3
    rts
    .byte   5	/* 408D7B86 Pascal string length */
    .ascii  ".ENET"	| 408D7B87
    .byte   6	/* 408D7B8C Pascal string length */
    .ascii  ".ENET0"	| 408D7B8D
    .byte   0x00	| 408D7B93
rsrc_atlk_10_340_14:
    moveq #3,%d0	| 408D7B94
    moveal ATalkHk2,%a1
    jsr %a1@(2)
    moveal %pc@(rsrc_atlk_10_94),%a3
    lea %a3@(16),%a0
    movew #245,%a0@(26)
    lea %a0@(28),%a1
    movel #150996736,%a1@
    st %a1@(3)
    st %a1@(4)
    st %a1@(5)
    _Control
    moveml %a2,%sp@-
    movew %a0@(24),%d2
    lea %pc@(rsrc_atlk_10_C8A_14),%a1
    moveq #22,%d0
    moveal ATalkHk2,%a2
    jsr %a2@(2)
    movew %a0@(24),%d2
    lea %pc@(rsrc_atlk_10_C8A_14_9),%a1	| 408D7BDE
    moveq #22,%d0
    moveal ATalkHk2,%a2
    jsr %a2@(2)
    moveml %sp@+,%a2
    lea %a3@(212),%a0
    _VRemove
    bsrw rsrc_atlk_10_CB6_B0_6
    moveal %a3,%a0
    _DisposPtr
    lea %pc@(rsrc_atlk_10_94),%a3
    clrl %a3@
    moveq #0,%d0
    rts

rsrc_atlk_10_3C8:       /* save registers */
    moveml %d1/%a0-%a3,%sp@-
    moveal %pc@(rsrc_atlk_10_94),%a3
    lea %a3@(1004),%a0
    moveq #0,%d0
    movel #255,%d1
    jbra rsrc_atlk_10_3C8_18
rsrc_atlk_10_3C8_16:    /* loop: addq */
    addqw #4,%d0
rsrc_atlk_10_3C8_18:    /* test %a0@(0x0,%d0:w) */
    tstl %a0@(0x0,%d0:w)
    jbeq rsrc_atlk_10_3C8_38
    moveal %a0@(0x0,%d0:w),%a1
    clrl %a0@(0x0,%d0:w)
    moveal %a3@(4076),%a2
    movel %a1,%a3@(4076)
rsrc_atlk_10_3C8_2E:    /* loop: tst */
    tstl %a1@
    jbeq rsrc_atlk_10_3C8_36
    moveal %a1@,%a1
    jbra rsrc_atlk_10_3C8_2E
rsrc_atlk_10_3C8_36:    /* set %a1@ */
    movel %a2,%a1@
rsrc_atlk_10_3C8_38:    /* count down */
    dbf %d1,rsrc_atlk_10_3C8_16
    clrw %a3@(1002)
    clrl %a3@(202)
    moveml %sp@+,%d1/%a0-%a3
    moveq #0,%d0
    rts
rsrc_atlk_10_3C8_38_14:
    movel %pc@(rsrc_atlk_10_94),%d0
    beqs rsrc_atlk_10_3C8_38_14_84
    moveal %d0,%a0
    cmpiw #20,%d1
    blts rsrc_atlk_10_3C8_38_14_84
    cmpiw #22,%d1
    blts rsrc_atlk_10_3C8_38_14_22
    movew #22,%a1@(2)
    movew #253,%a1@(20)
    bras rsrc_atlk_10_3C8_38_14_28
rsrc_atlk_10_3C8_38_14_22:
    movew #20,%a1@(2)
rsrc_atlk_10_3C8_38_14_28:
    movew #2,%a1@
    movel %a0,%sp@-
    movel #1635019638,%d0
    .short  0xA1AD	| 408D7C88 _Gestalt (flags 0x0100)
    tstw %d0
    bnes rsrc_atlk_10_3C8_38_14_50
    movel %a0,%d0
    swap %d0
    moveal %sp@+,%a0
    movew %d0,%a0@(4080)
    cmpiw #14592,%d0
    blts rsrc_atlk_10_3C8_38_14_58
    movew #3,%a1@
    bras rsrc_atlk_10_3C8_38_14_58
rsrc_atlk_10_3C8_38_14_50:
    moveal %sp@+,%a0
    movew #14336,%a0@(4080)
rsrc_atlk_10_3C8_38_14_58:
    movel #10000000,%a1@(4)
    clrl %a1@(8)
    moveq #0,%d0
    bset #7,%d0
    moveb %d0,%a1@(12)
    moveb #6,%a1@(13)
    movel %a0@(206),%a1@(14)
    movew %a0@(210),%a1@(18)
    moveq #0,%d0
    jbra rsrc_atlk_10_3C8_D2
rsrc_atlk_10_3C8_38_14_84:
    moveq #-1,%d0	| 408D7CD8
rsrc_atlk_10_3C8_D2:    /* return */
    rts
rsrc_atlk_10_3C8_D2_2:  /* the zone multicast address into a1: 09-00-07-00-00-nn, nn = d1 mod 253 */
    movel #150996736,%a1@	| 408D7CDC
    clrb %a1@(4)
    andil #65535,%d1
    divuw #253,%d1
    swap %d1
    moveb %d1,%a1@(5)
    moveq #0,%d0
    rts
rsrc_atlk_10_3C8_D2_20: /* ENetAddMulti (246), parameter block at +132 */
    moveal %pc@(rsrc_atlk_10_94),%a0	| 408D7CFA
    movew %a0@(40),%a0@(156)
    lea %a0@(132),%a0
    movew #246,%a0@(26)
    bras rsrc_atlk_10_3C8_D2_4A
rsrc_atlk_10_3C8_D2_36: /* ENetDelMulti (245), parameter block at +166 */
    moveal %pc@(rsrc_atlk_10_94),%a0	| 408D7D10
    movew %a0@(40),%a0@(190)
    lea %a0@(166),%a0
    movew #245,%a0@(26)
rsrc_atlk_10_3C8_D2_4A: /* only for a group address (bit 8 of the first word), and not while the previous call is running (ioResult > 0): _Control, asynchronous */
    moveq #-1,%d0	| 408D7D24
    movew %a1@,%d1
    btst #8,%d1
    beqs rsrc_atlk_10_3C8_D2_64
    movew %a1@+,%a0@(28)
    movel %a1@+,%a0@(30)
    tstw %a0@(16)
    bgts rsrc_atlk_10_3C8_D2_64
    .short  0xA404	| _Control (flags 0x0400)
rsrc_atlk_10_3C8_D2_64:
    rts	| 408D7D3E
rsrc_atlk_10_500:       /* set %a3 */
    moveal %pc@(rsrc_atlk_10_94),%a3	| 408D7D40
    bset #4,%a3@(200)	| 408D7D44
    movel %a0,%a3@(978)	| 408D7D4A
    movel %a1,%a3@(966)	| 408D7D4E
    moveal %a1@(2),%a0	| 408D7D52
    movel %a0,%a3@(960)	| 408D7D56
    addqw #3,%a1@(2)	| 408D7D5A
    moveq #0,%d0	| 408D7D5E
    movew %a1@,%d0	| 408D7D60
    movew %d0,%a3@(964)	| 408D7D62
    subqw #3,%a1@	| 408D7D66
    movel %a4,%sp@-	| 408D7D68
    lea %a3@(348),%a4	| 408D7D6A
    movew #-21846,%a4@+	| 408D7D6E
    moveb #3,%a4@+	| 408D7D72
    moveb #8,%a4@+	| 408D7D76
    clrb %a4@+	| 408D7D7A
    moveb #7,%a4@+	| 408D7D7C
    movew #-32613,%a4@+	| 408D7D80
    addqw #3,%a0	| 408D7D84
    subqw #3,%d0	| 408D7D86
    moveal %a4,%a1	| 408D7D88
    moveal %sp@+,%a4	| 408D7D8A
    tstw %d0	| 408D7D8C
    jbeq rsrc_atlk_10_552	| 408D7D8E
    _BlockMove	| 408D7D90
rsrc_atlk_10_552:       /* address %a3@(334) */
    lea %a3@(334),%a1	| 408D7D92
    cmpib #0xff,%d2	| 408D7D96
    jbne rsrc_atlk_10_572	| 408D7D9A
    movel #150996736,%a1@	| 408D7D9C
    st %a1@(3)	| 408D7DA2
    st %a1@(4)	| 408D7DA6
    st %a1@(5)	| 408D7DAA
    jbra rsrc_atlk_10_650	| 408D7DAE
rsrc_atlk_10_572:       /* call rsrc_atlk_10_C60 */
    jbsr rsrc_atlk_10_C60	| 408D7DB2
    jbmi rsrc_atlk_10_580	| 408D7DB6
    movew %d1,%a1@+	| 408D7DB8
    movel %d0,%a1@+	| 408D7DBA
    jbra rsrc_atlk_10_650	| 408D7DBC
rsrc_atlk_10_580:       /* clear %d0 */
    moveq #0,%d0	| 408D7DC0
    movew %a1@(28),%d0	| 408D7DC2
    lsll #8,%d0	| 408D7DC6
    moveb %a1@(31),%d0	| 408D7DC8
    moveml %d0/%d2,%sp@-	| 408D7DCC
    jbsr rsrc_atlk_10_A2C	| 408D7DD0
    moveml %sp@+,%d0/%d2	| 408D7DD4
    jbne rsrc_atlk_10_59E	| 408D7DD8
    movel %a3@(202),%d0	| 408D7DDA
rsrc_atlk_10_59E:       /* set %a3@(330) */
    movel %d2,%a3@(330)	| 408D7DDE
    lea %a3@(248),%a1	| 408D7DE2
    movew #1,%a1@(6)	| 408D7DE6
    movel %d0,%a1@(14)	| 408D7DEC
    movel %d2,%a1@(24)	| 408D7DF0
    lea %a3@(16),%a0	| 408D7DF4
    movew #249,%a0@(26)	| 408D7DF8
    lea %a3@(66),%a1	| 408D7DFE
    movel %a1,%a0@(30)	| 408D7E02
    bclr #5,%a3@(200)	| 408D7E06
    movew #10,%a3@(326)	| 408D7E0C
    movew %a3@(328),%a3@(222)	| 408D7E12
    bset #6,%a3@(200)	| 408D7E18
    jbne rsrc_atlk_10_648	| 408D7E1E
    lea %pc@(rsrc_atlk_10_62A),%a1	| 408D7E20
rsrc_atlk_10_5E4:       /* loop: move */
    movel %a1,%a0@(12)	| 408D7E24
    .short  0xA404	| 408D7E28 _Control (flags 0x0400)
    cmpiw #-28,%d0	| 408D7E2A
    jbeq rsrc_atlk_10_5F2	| 408D7E2E
    rts	| 408D7E30
rsrc_atlk_10_5F2:       /* test %d0 */
    tstw %d0	| 408D7E32
    jmp %a1@	| 408D7E34
rsrc_atlk_10_5F2_4:
    .byte   0x31, 0x7C, 0x0E, 0x10, 0x00, 0x0A, 0x26, 0x7A, 0xFA, 0x96, 0x4A, 0x6B, 0x01, 0x46, 0x67, 0x42	| 408D7E36
    .byte   0x53, 0x6B, 0x01, 0x46, 0x67, 0x0C, 0x31, 0x6B, 0x01, 0x48, 0x00, 0x0A, 0x41, 0xEB, 0x00, 0x10	| 408D7E46
    .byte   0x60, 0xC0, 0x08, 0x2B, 0x00, 0x06, 0x00, 0xC8, 0x67, 0x06, 0x52, 0x6B, 0x01, 0x46, 0x60, 0xE6	| 408D7E56
    moveq #-95,%d0
    jbra rsrc_atlk_10_3C8_2C6
rsrc_atlk_10_62A:       /* (data) */
    .byte   0x26, 0x7A, 0xFA, 0x68, 0x40, 0xE7, 0x00, 0x7C, 0x07, 0x00, 0x02, 0x7C, 0xFE, 0xFF, 0x08, 0xAB	| 408D7E6A
    .byte   0x00, 0x06, 0x00, 0xC8, 0x08, 0x2B, 0x00, 0x05, 0x00, 0xC8, 0x66, 0x04, 0x46, 0xDF	| 408D7E7A
rsrc_atlk_10_648:       /* return */
    rts	| 408D7E88
    .byte   0x46, 0xDF, 0x24, 0x6B, 0x03, 0xCA	| 408D7E8A
rsrc_atlk_10_650:       /* loop: moveq */
    moveq #0,%d0	| 408D7E90
    moveal %a3@(966),%a1	| 408D7E92
    moveal %a1,%a0	| 408D7E96
    tstw %a0@	| 408D7E98
    jbeq rsrc_atlk_10_662	| 408D7E9A
rsrc_atlk_10_65C:       /* loop: move */
    movew %a0@,%d1	| 408D7E9C
    jbeq rsrc_atlk_10_666	| 408D7E9E
    addw %d1,%d0	| 408D7EA0
rsrc_atlk_10_662:       /* add 6 to %a0 */
    addqw #6,%a0	| 408D7EA2
    jbra rsrc_atlk_10_65C	| 408D7EA4
rsrc_atlk_10_666:       /* add 8 to %d0 */
    addqw #8,%d0	| 408D7EA6
    lea %a3@(346),%a0	| 408D7EA8
    movew %d0,%a0@	| 408D7EAC
    lea %a3@(16),%a0	| 408D7EAE
    movew #249,%a0@(26)	| 408D7EB2
    movel %a1,%a0@(30)	| 408D7EB8
    addiw #22,%a1@+	| 408D7EBC
    lea %a3@(334),%a3	| 408D7EC0
    movel %a3,%a1@	| 408D7EC4
    lea %pc@(rsrc_atlk_10_3C8_2C6),%a1	| 408D7EC6
    jbra rsrc_atlk_10_5E4	| 408D7ECA
rsrc_atlk_10_3C8_2C6:   /* set %a3 */
    moveal %pc@(rsrc_atlk_10_94),%a3
    moveal %a3@(970),%a2
    moveal %a3@(966),%a1
    movew %a3@(964),%a1@
    moveal %a3@(960),%a0
    movel %a0,%a1@(2)
    moveal %a3@(978),%a0
    jmp %a0@
rsrc_atlk_10_6AC:       /* set %a3 */
    moveal %pc@(rsrc_atlk_10_94),%a3	| 408D7EEC
    movel %a0,%a3@(978)	| 408D7EF0
    movel %a1,%a3@(966)	| 408D7EF4
    moveal %a1@(2),%a0	| 408D7EF8
    movel %a0,%a3@(960)	| 408D7EFC
    addqw #3,%a1@(2)	| 408D7F00
    addqw #3,%a0	| 408D7F04
    moveq #0,%d0	| 408D7F06
    movew %a1@,%d0	| 408D7F08
    movew %d0,%a3@(964)	| 408D7F0A
    subqw #3,%a1@	| 408D7F0E
    subqw #3,%d0	| 408D7F10
    lea %a3@(348),%a1	| 408D7F12
    movew #-21846,%a1@+	| 408D7F16
    moveb #3,%a1@+	| 408D7F1A
    moveb #8,%a1@+	| 408D7F1E
    clrb %a1@+	| 408D7F22
    moveb #7,%a1@+	| 408D7F24
    movew #-32613,%a1@+	| 408D7F28
    tstw %d0	| 408D7F2C
    jbeq rsrc_atlk_10_6F2	| 408D7F2E
    _BlockMove	| 408D7F30
rsrc_atlk_10_6F2:       /* address %a3@(334) */
    lea %a3@(334),%a1	| 408D7F32
    moveal %d2,%a0	| 408D7F36
    movew %a0@+,%a1@+	| 408D7F38
    movel %a0@+,%a1@+	| 408D7F3A
    jbra rsrc_atlk_10_650	| 408D7F3C
rsrc_atlk_10_700:       /* set %sp@- */
    movel %a0,%sp@-	| 408D7F40
    moveal %pc@(rsrc_atlk_10_94),%a3	| 408D7F42
    movel %a2,%a3@(970)	| 408D7F46
    movel %a1,%a3@(974)	| 408D7F4A
    bclr #4,%a3@(200)	| 408D7F4E
    lea %a3@(66),%a1	| 408D7F54
    movel %a1,%a3@(46)	| 408D7F58
    movew #50,%a1@+	| 408D7F5C
    lea %a3@(226),%a0	| 408D7F60
    movel %a0,%a1@+	| 408D7F64
    clrw %a1@+	| 408D7F66
    movew #3,%a0@(28)	| 408D7F68
    movel %d2,%a3@(202)	| 408D7F6E
    lea %a3@(248),%a1	| 408D7F72
    movel %d2,%a1@(14)	| 408D7F76
    movel %d2,%a1@(24)	| 408D7F7A
    lea %a3@(16),%a0	| 408D7F7E
    movew #249,%a0@(26)	| 408D7F82
    bclr #3,%a3@(200)	| 408D7F88
    _Control	| 408D7F8E
    moveq #0,%d0	| 408D7F90
    movew %a3@(328),%d0	| 408D7F92
    addw %d0,%d0	| 408D7F96
    addl Ticks,%d0	| 408D7F98
rsrc_atlk_10_75C:       /* loop: btst */
    btst #3,%a3@(200)	| 408D7F9C
    jbne rsrc_atlk_10_76A	| 408D7FA2
    cmpl Ticks,%d0	| 408D7FA4
    jbhi rsrc_atlk_10_75C	| 408D7FA8
rsrc_atlk_10_76A:       /* return */
    rts	| 408D7FAA

rsrc_atlk_10_76C:       /* save registers */
    moveml %d1-%d3/%a1,%sp@-
    movel %a0,%sp@-
    moveal %pc@(rsrc_atlk_10_94),%a3
    cmpiw #14592,%a3@(4080)
    jblt rsrc_atlk_10_76C_C4
    tstw %a3@(1002)
    jbne rsrc_atlk_10_76C_2C
    movew #-1,%d1
    movel %a0@(28),%a3@(202)
    bclr #4,%a3@(200)
    jbra rsrc_atlk_10_76C_30
rsrc_atlk_10_76C_2C:    /* set %d1 */
    movew #-32768,%d1
rsrc_atlk_10_76C_30:    /* set %d2 */
    movel %a0@(28),%d2
    movew %a0@(32),%d3
    jbsr rsrc_atlk_10_A62
    jbne rsrc_atlk_10_76C_C4
    movel %a0@(34),%a3@(970)
    movel %a0@(38),%a3@(974)
    lea %a3@(66),%a1
    movel %a1,%a3@(46)
    movew #50,%a1@+
    lea %a3@(226),%a0
    movel %a0,%a1@+
    clrw %a1@+
    movew #3,%a0@(28)
rsrc_atlk_10_76C_66:    /* loop: lea */
    lea %a3@(248),%a1
    movel %d2,%a1@(14)
    movel %d2,%a1@(24)
    lea %a3@(16),%a0
    movew #249,%a0@(26)
    bclr #3,%a3@(200)
    _Control
    moveq #0,%d0
    movew %a3@(328),%d0
    addw %d0,%d0
    addl Ticks,%d0
rsrc_atlk_10_76C_90:    /* loop: btst */
    btst #3,%a3@(200)
    jbne rsrc_atlk_10_76C_C0
    cmpl Ticks,%d0
    jbhi rsrc_atlk_10_76C_90
    dbf %d3,rsrc_atlk_10_76C_66
    moveal %sp@+,%a0
    cmpiw #1,%a3@(1002)
    jbeq rsrc_atlk_10_76C_BC
    jbsr rsrc_atlk_10_AC6
    movel %a0@(28),%d2
    movew %a0@(42),%d1
    jbsr rsrc_atlk_10_A62
rsrc_atlk_10_76C_BC:    /* result 0 */
    moveq #0,%d0
    jbra rsrc_atlk_10_76C_C8
rsrc_atlk_10_76C_C0:    /* call rsrc_atlk_10_AC6 */
    jbsr rsrc_atlk_10_AC6
rsrc_atlk_10_76C_C4:    /* set %d0 */
    moveq #-50,%d0
    moveal %sp@+,%a0
rsrc_atlk_10_76C_C8:    /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a1
    rts
    pea %pc@(rsrc_atlk_10_76C_C8_16)
    moveml %d0/%a0,%sp@-
    movew #12,%d0
    braw rsrc_atlk_10_101A
rsrc_atlk_10_76C_C8_16:
    moveal %pc@(rsrc_atlk_10_94),%a2
    bset #7,%a2@(200)
    bnew rsrc_atlk_10_76C_C8_BC
    lea %a2@(298),%a3
    movel %d0,%a3@+
    movew #24,%d3
    jsr %a4@(2)
    moveal %a2,%a3
    bnes rsrc_atlk_10_76C_C8_6E
    moveal %a3@(970),%a2
    lea %a3@(298),%a1
    lea %a1@(4),%a0
    cmpiw #1540,%a0@+
    bnes rsrc_atlk_10_76C_C8_6E
    cmpiw #2,%a0@
    bnes rsrc_atlk_10_76C_C8_C2
    bsrw rsrc_atlk_10_76C_C8_162_10	| 408D80C2
    bnes rsrc_atlk_10_76C_C8_6E
    cmpiw #-32768,%d0
    beqs rsrc_atlk_10_76C_C8_6A
    cmpiw #1,%a3@(1002)
    bgts rsrc_atlk_10_76C_C8_76
    btst #4,%a3@(200)
    bnes rsrc_atlk_10_76C_C8_76
rsrc_atlk_10_76C_C8_6A:
    bsrw rsrc_atlk_10_76C_C8_162
rsrc_atlk_10_76C_C8_6E:
    bclr #7,%a3@(200)
rsrc_atlk_10_76C_C8_74:
    rts
rsrc_atlk_10_76C_C8_76:
    movel %a1@(14),%d2
    movew %a1@(8),%d1
    movel %a1@(10),%d0
    bsrw rsrc_atlk_10_C42
    cmpl %a3@(330),%d2
    bnes rsrc_atlk_10_76C_C8_6E
    tstw %a3@(326)
    beqs rsrc_atlk_10_76C_C8_6E
    clrw %a3@(326)
    movew #3600,%a3@(222)
    movew %d1,%a3@(334)
    movel %d0,%a3@(336)
    bclr #7,%a3@(200)
    bset #5,%a3@(200)
    btst #6,%a3@(200)
    bnes rsrc_atlk_10_76C_C8_74
    braw rsrc_atlk_10_650
rsrc_atlk_10_76C_C8_BC:
    moveq #0,%d3
    jmp %a4@(2)
rsrc_atlk_10_76C_C8_C2:
    cmpiw #3,%a0@
    bnes rsrc_atlk_10_76C_C8_F2
    bsrw rsrc_atlk_10_C8A
    bsrw rsrc_atlk_10_76C_C8_162_10	| 408D8140
    bnes rsrc_atlk_10_76C_C8_EA
    cmpiw #-32768,%d0
    beqs rsrc_atlk_10_76C_C8_E8
    cmpiw #1,%a3@(1002)
    bgts rsrc_atlk_10_76C_C8_112
    btst #4,%a3@(200)
    bnes rsrc_atlk_10_76C_C8_112
rsrc_atlk_10_76C_C8_E8:
    bsrs rsrc_atlk_10_76C_C8_162
rsrc_atlk_10_76C_C8_EA:
    bclr #7,%a3@(200)
    rts
rsrc_atlk_10_76C_C8_F2:
    cmpiw #1,%a0@
    bnes rsrc_atlk_10_76C_C8_EA
    bsrs rsrc_atlk_10_76C_C8_162_10	| 408D816C
    bnes rsrc_atlk_10_76C_C8_EA
    cmpiw #-32768,%d0
    beqs rsrc_atlk_10_76C_C8_EA
    cmpiw #1,%a3@(1002)
    bgts rsrc_atlk_10_76C_C8_112
    btst #4,%a3@(200)
    beqs rsrc_atlk_10_76C_C8_EA
rsrc_atlk_10_76C_C8_112:
    movel %a1@(8),%d1
    movel %d1,%a1@(-22)
    movel %d1,%a1@(18)
    movew %a1@(12),%d1
    movew %d1,%a1@(-18)
    movew %d1,%a1@(22)
    movel %a1@(14),%d1
    movel %a1@(24),%a1@(14)
    movel %d1,%a1@(24)
    movel %a3@(206),%a1@(8)
    movew %a3@(210),%a1@(12)
    movew #2,%a1@(6)
    lea %a3@(74),%a0
    lea %pc@(rsrc_atlk_10_76C_C8_156),%a1
    braw rsrc_atlk_10_5E4
rsrc_atlk_10_76C_C8_156:
    moveal %pc@(rsrc_atlk_10_94),%a3
    bclr #7,%a3@(200)
    rts
rsrc_atlk_10_76C_C8_162:
    bset #3,%a3@(200)
    moveq #5,%d0
    moveal ATalkHk2,%a0
    jmp %a0@(2)	| 408D81E2
rsrc_atlk_10_76C_C8_162_10:
    .byte   0x48, 0xE7	| 408D81E6
    moveq #-128,%d0
    movel %a3@(974),%d3
    jbeq rsrc_atlk_10_76C_24E
    moveal %d3,%a0
    moveb %a0@,%d3
    jbmi rsrc_atlk_10_76C_26A
    andib #15,%d3
rsrc_atlk_10_76C_24E:   /* subtract 1 to %d3 */
    subqb #1,%d3
    jbne rsrc_atlk_10_76C_26A
    movel %a1@(24),%d2
    tstw %a3@(1002)
    jbne rsrc_atlk_10_76C_25E
    jbra rsrc_atlk_10_76C_266
rsrc_atlk_10_76C_25E:   /* call rsrc_atlk_10_A2C */
    jbsr rsrc_atlk_10_A2C
    eorib #4,%ccr
    jbra rsrc_atlk_10_76C_26A
rsrc_atlk_10_76C_266:   /* test %a3@(202),%d2 */
    cmpl %a3@(202),%d2
rsrc_atlk_10_76C_26A:   /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a0
    rts

rsrc_atlk_10_9DC:       /* save registers */
    moveml %d2-%d3/%a0-%a3,%sp@-
    moveal %pc@(rsrc_atlk_10_94),%a3
    cmpiw #14592,%a3@(4080)
    jblt rsrc_atlk_10_9DC_24
    movel %a0@(28),%d2
    jbsr rsrc_atlk_10_AC6
    tstw %d0
    jbeq rsrc_atlk_10_9DC_24
    movew %d0,%a0@(42)
    moveq #0,%d0
    jbra rsrc_atlk_10_9DC_28
rsrc_atlk_10_9DC_24:    /* set %d0 */
    movew #-50,%d0
rsrc_atlk_10_9DC_28:    /* restore registers, return */
    moveml %sp@+,%d2-%d3/%a0-%a3
    rts

rsrc_atlk_10_A0A:       /* save registers */
    moveml %d2/%a3,%sp@-
    moveal %pc@(rsrc_atlk_10_94),%a3
    movel %a0@(28),%d2
    jbsr rsrc_atlk_10_A2C
    jbeq rsrc_atlk_10_A0A_18
    movew %d0,%a0@(42)
    moveq #0,%d0
    jbra rsrc_atlk_10_A0A_1C
rsrc_atlk_10_A0A_18:    /* set %d0 */
    movew #-50,%d0
rsrc_atlk_10_A0A_1C:    /* restore registers, return */
    moveml %sp@+,%d2/%a3
    rts

/* subroutine (20 instructions) (mechanical summary) */
rsrc_atlk_10_A2C:
    moveml %d1/%d3/%a0,%sp@-
    moveq #0,%d0
    moveq #0,%d3
    moveb %d2,%d3
    lsll #2,%d3
    lea %a3@(1004),%a0
    tstl %a0@(0x0,%d3:w)
    jbeq rsrc_atlk_10_A2C_30
    moveal %a0@(0x0,%d3:w),%a0
    movel %d2,%d1
    lsrl #8,%d1
rsrc_atlk_10_A2C_1E:    /* loop: cmp */
    cmpw %a0@(4),%d1
    jbeq rsrc_atlk_10_A2C_2C
    tstl %a0@
    jbeq rsrc_atlk_10_A2C_30
    moveal %a0@,%a0
    jbra rsrc_atlk_10_A2C_1E
rsrc_atlk_10_A2C_2C:    /* set %d0 */
    movew %a0@(6),%d0
rsrc_atlk_10_A2C_30:    /* restore registers, return */
    moveml %sp@+,%d1/%d3/%a0
    rts

/* subroutine (37 instructions) (mechanical summary) */
rsrc_atlk_10_A62:
    moveml %d3/%a0-%a2,%sp@-
    cmpiw #254,%a3@(1002)
    jbge rsrc_atlk_10_A62_5C
    moveq #0,%d0
    moveb %d2,%d0
    lsll #2,%d0
    lea %a3@(1004),%a0
    addal %d0,%a0
    tstl %a0@
    jbeq rsrc_atlk_10_A62_30
    moveal %a0@,%a0
    movel %d2,%d3
    lsrl #8,%d3
rsrc_atlk_10_A62_22:    /* loop: cmp */
    cmpw %a0@(4),%d3
    jbeq rsrc_atlk_10_A62_5C
    tstl %a0@
    jbeq rsrc_atlk_10_A62_30
    moveal %a0@,%a0
    jbra rsrc_atlk_10_A62_22
rsrc_atlk_10_A62_30:    /* test %a3@(4076) */
    tstl %a3@(4076)
    jbeq rsrc_atlk_10_A62_5C
    moveal %a3@(4076),%a1
    movel %a1@,%a3@(4076)
    movel %a1,%a0@
    movew %d1,%a1@(6)
    clrl %a1@
    movel %d2,%d0
    lsrl #8,%d0
    movew %d0,%a1@(4)
    cmpib #0xff,%d2
    jbeq rsrc_atlk_10_A62_58
    addqw #1,%a3@(1002)
rsrc_atlk_10_A62_58:    /* result 0 */
    moveq #0,%d0
    jbra rsrc_atlk_10_A62_5E
rsrc_atlk_10_A62_5C:    /* set %d0 */
    moveq #-50,%d0
rsrc_atlk_10_A62_5E:    /* restore registers, return */
    moveml %sp@+,%d3/%a0-%a2
    rts

/* subroutine (81 instructions): calls rsrc_atlk_10_C42 (mechanical summary) */
rsrc_atlk_10_AC6:
    moveml %d3/%a0-%a2,%sp@-
    tstw %a3@(1002)
    jbeq rsrc_atlk_10_AC6_50
    moveq #0,%d0
    moveb %d2,%d0
    lsll #2,%d0
    lea %a3@(1004),%a0
    addal %d0,%a0
    tstl %a0@
    jbeq rsrc_atlk_10_AC6_50
    movel %d2,%d3
    lsrl #8,%d3
rsrc_atlk_10_AC6_1E:    /* loop: movea */
    moveal %a0@,%a1
    cmpw %a1@(4),%d3
    jbeq rsrc_atlk_10_AC6_2E
    moveal %a1,%a0
    tstw %a0@
    jbne rsrc_atlk_10_AC6_1E
    jbra rsrc_atlk_10_AC6_50
rsrc_atlk_10_AC6_2E:    /* set %a1 */
    moveal %a0@,%a1
    tstw %a1@
    jbne rsrc_atlk_10_AC6_38
    clrl %a0@
    jbra rsrc_atlk_10_AC6_3A
rsrc_atlk_10_AC6_38:    /* set %a0@ */
    movel %a1@,%a0@
rsrc_atlk_10_AC6_3A:    /* clear %d0 */
    moveq #0,%d0
    movew %a1@(6),%d0
    moveal %a3@(4076),%a0
    movel %a0,%a1@
    movel %a1,%a3@(4076)
    subqw #1,%a3@(1002)
    jbra rsrc_atlk_10_AC6_52
rsrc_atlk_10_AC6_50:    /* clear %d0 */
    moveq #0,%d0
rsrc_atlk_10_AC6_52:    /* restore registers, return */
    moveml %sp@+,%d3/%a0-%a2
    rts
rsrc_atlk_10_AC6_52_6:
    .byte   0x24, 0x7A, 0xF5, 0x74, 0x24, 0x2A, 0x03, 0xCE, 0x67, 0x00, 0x00, 0xF0, 0x2A, 0x42, 0x14, 0x15	| 408D835E
    .byte   0x6B, 0x00, 0x00, 0xE8, 0x02, 0x02, 0x00, 0x0F, 0x53, 0x02, 0x66, 0x00, 0x00, 0xDE, 0x26, 0x01	| 408D836E
    .byte   0x30, 0x2B, 0xFF, 0xF0, 0x22, 0x2B, 0xFF, 0xF2, 0x48, 0xEA, 0x00, 0x03, 0x03, 0xD6, 0x22, 0x03	| 408D837E
    moveal %a2@(970),%a2
    movew %a2@(28),%d3
    addiw #256,%d3
    movew %sr,%sp@-
    andiw #-1793,%sp@
    orw %d3,%sp@
    movew %sp@+,%sr
    lea %a2@(4),%a3
    moveq #13,%d3
    jsr %a4@
    jbne rsrc_atlk_10_AC6_158
    lea %a2@(4),%a3
    movew %a3@,%d0
    andiw #1023,%d0
    subiw #13,%d0
    cmpw %d1,%d0
    jbhi rsrc_atlk_10_AC6_BE
    movew %d0,%d1
rsrc_atlk_10_AC6_BE:    /* set %d0 */
    movew %a3@,%d0
    andiw #15360,%d0
    moveal %pc@(rsrc_atlk_10_94),%a3
    jbeq rsrc_atlk_10_AC6_D2
    lea %a3@(984),%a3
    movel %a3,%d3
    jbra rsrc_atlk_10_AC6_F0
rsrc_atlk_10_AC6_D2:    /* set %d3 */
    movel %d1,%d3
    moveml %a3@(982),%d0-%d1
    exg %d0,%d1
    moveq #0,%d2
    movew %a2@(10),%d2
    lsll #8,%d2
    moveb %a2@(13),%d2
    jbsr rsrc_atlk_10_C42
    movel %d3,%d1
    moveq #0,%d3
rsrc_atlk_10_AC6_F0:    /* set %a2@(1) */
    moveb %a2@(12),%a2@(1)
    moveb %a2@(13),%a2@(2)
    moveb #2,%a2@(3)
    pea %pc@(rsrc_atlk_10_AC6_11E)
    moveml %d0/%a0,%sp@-
    movew #4,%d0
    jbra rsrc_atlk_10_101A
rsrc_atlk_10_AC6_112:   /* restore registers */
    moveml %sp@+,%d2/%a1/%a3
    movew #-2,%d2
    swap %d2
    jbra rsrc_atlk_10_AC6_142

/* subroutine (29 instructions): calls rsrc_atlk_10_A2C, rsrc_atlk_10_CB6; low memory ATalkHk2 (mechanical summary) */
rsrc_atlk_10_AC6_11E:
    lea %a2@(17),%a3
    moveml %d2/%a1/%a3,%sp@-
    movew %a2@(8),%d2
    lsll #8,%d2
    moveb %a2@(12),%d2
    moveal %pc@(rsrc_atlk_10_94),%a3
    jbsr rsrc_atlk_10_A2C
    jbeq rsrc_atlk_10_AC6_112
    moveml %sp@+,%d2/%a1/%a3
    movel %d0,%d2
    swap %d2
rsrc_atlk_10_AC6_142:   /* set %d0 */
    moveq #1,%d0
    moveal ATalkHk2,%a5
    jsr %a5@(2)
    jbra rsrc_atlk_10_AC6_152
    .long   0x4CDF0A04	| 408D8454
rsrc_atlk_10_AC6_152:   /* clear %d3 */
    moveq #0,%d3
    jmp %a4@(2)
rsrc_atlk_10_AC6_158:   /* return */
    rts

rsrc_atlk_10_C20:       /* save registers */
    moveml %d1-%d2/%a1-%a2,%sp@-
    moveq #60,%d0
    movew #253,%d1
    swap %d1
    movew #100,%d1
    movew #4,%d2
    swap %d2
    movew #6,%d2
    jbsr rsrc_atlk_10_CB6
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts

/* subroutine (12 instructions): calls rsrc_atlk_10_D8E (mechanical summary) */
rsrc_atlk_10_C42:
    moveml %a0-%a3,%sp@-
    movel %d2,%sp@-
    moveal %sp,%a0
    movel %d0,%sp@-
    movew %d1,%sp@-
    moveal %sp,%a1
    jbsr rsrc_atlk_10_D8E
    movew %sp@+,%d1
    movel %sp@+,%d0
    movel %sp@+,%d2
    moveml %sp@+,%a0-%a3
    rts

/* subroutine (21 instructions): calls rsrc_atlk_10_EAE, rsrc_atlk_10_EE0 (mechanical summary) */
rsrc_atlk_10_C60:
    moveml %a0-%a3,%sp@-
    movel %d2,%sp@-
    moveal %sp,%a0
    subqw #6,%sp
    moveal %sp,%a1
    jbsr rsrc_atlk_10_EAE
    tstw %d0
    jbeq rsrc_atlk_10_C60_18
    movew #8,%ccr
rsrc_atlk_10_C60_18:    /* set %d1 */
    movemw %sp@+,%d1
    moveml %sp@+,%d0
    moveml %sp@+,%d2
    moveml %sp@+,%a0-%a3
    rts

rsrc_atlk_10_C8A:       /* save registers */
    moveml %d0-%d1/%a0-%a3,%sp@-
    movel %d2,%sp@-
    moveal %sp,%a0
    jbsr rsrc_atlk_10_EE0
    movel %sp@+,%d2
    moveml %sp@+,%d0-%d1/%a0-%a3
    rts
rsrc_atlk_10_C8A_14:
    .byte   0x01, 0xAA, 0x05, 0x08, 0x00, 0x07, 0x80, 0x9B, 0x00	| 408D84DE
rsrc_atlk_10_C8A_14_9:
    .byte   0x01, 0xAA, 0x05, 0x00, 0x00, 0x00, 0x80, 0xF3, 0x04, 0x00, 0x01, 0x80, 0x9B, 0x00, 0x00	| 408D84E7

/* subroutine (55 instructions): traps NewPtr, VInstall, DisposPtr (mechanical summary) */
rsrc_atlk_10_CB6:
    movel %d0,%sp@-
    moveq #42,%d0
    .short  0xA71E	| 408D84FA _NewPtr (flags 0x0700)
    moveml %sp@+,%d0
    jbne rsrc_atlk_10_CB6_B0
    lea %a3@(998),%a2
    movel %a0,%a2@
    moveal %a0,%a2
    movel #2017545556,%a2@
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
    .short  0xA71E	| 408D8532 _NewPtr (flags 0x0700)
    jbne rsrc_atlk_10_CB6_AC
    movel %a0,%a2@(20)
    moveq #0,%d0
    movew %a2@(6),%d0
    addw %a2@(8),%d0
    addqw #6,%d0
    movew %d0,%a2@(14)
    muluw %a2@(12),%d0
    .short  0xA71E	| 408D854E _NewPtr (flags 0x0700)
    jbne rsrc_atlk_10_CB6_A6
    movel %a0,%a2@(24)
    moveq #0,%d1
    movew %a2@(12),%d1
    subqw #1,%d1
rsrc_atlk_10_CB6_68:    /* loop: move */
    movel %a2@(16),%a0@
    movel %a0,%a2@(16)
    addaw %a2@(14),%a0
    dbf %d1,rsrc_atlk_10_CB6_68
    lea %a2@(28),%a0
    movew #1,%a0@(4)
    lea %pc@(rsrc_atlk_10_F3C),%a1
    movel %a1,%a0@(6)
    movew %a2@(10),%d0
    jbeq rsrc_atlk_10_CB6_9E
    muluw #60,%d0
    movew %d0,%a0@(10)
    _VInstall
    tstw %d0
    jbne rsrc_atlk_10_CB6_A0
rsrc_atlk_10_CB6_9E:    /* return */
    rts
rsrc_atlk_10_CB6_A0:    /* set up and call _DisposPtr */
    moveal %a2@(24),%a0
    _DisposPtr
rsrc_atlk_10_CB6_A6:    /* set up and call _DisposPtr */
    moveal %a2@(20),%a0
    _DisposPtr
rsrc_atlk_10_CB6_AC:    /* set up and call _DisposPtr */
    moveal %a2,%a0
    _DisposPtr
rsrc_atlk_10_CB6_B0:    /* set %d0 */
    movew #-1,%d0
    rts
rsrc_atlk_10_CB6_B0_6:
    moveal %a3@(998),%a1
    movew %a1@(10),%d0
    beqs rsrc_atlk_10_CB6_B0_6_10
    lea %a1@(28),%a0
    _VRemove
rsrc_atlk_10_CB6_B0_6_10:
    moveal %a1@(20),%a0
    _DisposPtr
    moveal %a1@(24),%a0
    _DisposPtr
    moveal %a1,%a0
    _DisposPtr
    rts

/* subroutine (105 instructions): calls rsrc_atlk_10_F92, rsrc_atlk_10_FD2 (mechanical summary) */
rsrc_atlk_10_D8E:
    moveal %pc@(rsrc_atlk_10_94),%a3
    moveal %a3@(998),%a3
    movew %sr,%sp@-
    oriw #1792,%sr
    andiw #-257,%sr
    jsr %pc@(rsrc_atlk_10_F92)
    jbne rsrc_atlk_10_D8E_3C
    bset #7,%a2@(4)
    movew %a3@(8),%d1
    asrw #1,%d1
    subqw #1,%d1
    addqw #6,%a2
    addaw %a3@(6),%a2
rsrc_atlk_10_D8E_2C:    /* loop: move */
    movew %a1@+,%a2@+
    dbf %d1,rsrc_atlk_10_D8E_2C
    subaw %a3@(8),%a1
    movew %sp@+,%sr
    clrw %d0
    rts
rsrc_atlk_10_D8E_3C:    /* set %d1 */
    movel %a1,%d1
    lea %a3@(16),%a1
    movel %a1@,%d0
    jbeq rsrc_atlk_10_D8E_8E
    moveal %d0,%a2
    movel %a2@,%a1@
    moveal %d1,%a1
rsrc_atlk_10_D8E_4C:    /* loop: bset */
    bset #7,%a2@(4)
    addqw #6,%a2
    movew %a3@(6),%d1
    asrw #1,%d1
    subqw #1,%d1
rsrc_atlk_10_D8E_5C:    /* loop: move */
    movew %a0@+,%a2@+
    dbf %d1,rsrc_atlk_10_D8E_5C
    movew %a3@(8),%d1
    asrw #1,%d1
    subqw #1,%d1
rsrc_atlk_10_D8E_6A:    /* loop: move */
    movew %a1@+,%a2@+
    dbf %d1,rsrc_atlk_10_D8E_6A
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
rsrc_atlk_10_D8E_8E:    /* set %a1 */
    moveal %d1,%a1
    movew %a3@(10),%d0
    jbne rsrc_atlk_10_E2C
    movew %sp@+,%sr
    movew #-1,%d0
    rts

rsrc_atlk_10_E2C:       /* save registers */
    moveml %d2/%a0-%a1,%sp@-
    movew 0x20e,%sp@-
    movew 0x20e,%sp@-
    movew 0x20e,%sp@-
    moveal %sp,%a0
    jsr %pc@(rsrc_atlk_10_FD2)
    addql #6,%sp
rsrc_atlk_10_E2C_18:    /* loop: movea */
    moveal %a2,%a0
rsrc_atlk_10_E2C_1A:    /* loop: movea */
    moveal %a2,%a1
    moveal %a2@,%a2
    movel %a2,%d1
    jbeq rsrc_atlk_10_E2C_34
    btst #7,%a2@(4)
    jbne rsrc_atlk_10_E2C_1A
    movel %a2@,%a1@
rsrc_atlk_10_E2C_2C:    /* restore registers */
    moveml %sp@+,%d2/%a0-%a1
    jbra rsrc_atlk_10_D8E_4C
rsrc_atlk_10_E2C_34:    /* set %a2 */
    moveal %a0,%a2
    addql #4,%a2
    cmpal %d2,%a2
    jbne rsrc_atlk_10_E2C_66
rsrc_atlk_10_E2C_3C:    /* loop: movea */
    moveal %a2,%a0
    moveal %a2,%a1
    moveal %a2@,%a2
    movel %a2,%d1
    jbeq rsrc_atlk_10_E2C_4A
    movel %a2@,%a1@
    jbra rsrc_atlk_10_E2C_2C
rsrc_atlk_10_E2C_4A:    /* set %a2 */
    moveal %a0,%a2
    addql #4,%a2
    moveq #0,%d1
    movew %a3@(4),%d1
    lsll #2,%d1
    moveal %a3@(20),%a0
    addal %d1,%a0
    cmpal %a2,%a0
    jbne rsrc_atlk_10_E2C_3C
    moveal %a3@(20),%a2
    jbra rsrc_atlk_10_E2C_3C
rsrc_atlk_10_E2C_66:    /* clear %d1 */
    moveq #0,%d1
    movew %a3@(4),%d1
    lsll #2,%d1
    moveal %a3@(20),%a0
    addal %d1,%a0
    cmpal %a2,%a0
    jbne rsrc_atlk_10_E2C_18
    moveal %a3@(20),%a2
    cmpal %d2,%a2
    jbeq rsrc_atlk_10_E2C_3C
    jbra rsrc_atlk_10_E2C_18

/* subroutine (17 instructions): calls rsrc_atlk_10_F92 (mechanical summary) */
rsrc_atlk_10_EAE:
    moveal %a3@(998),%a3
    jsr %pc@(rsrc_atlk_10_F92)
    jbne rsrc_atlk_10_EAE_30
    movew %sr,%d0
    oriw #1792,%sr
    andiw #-257,%sr
    addqw #6,%a2
    addaw %a3@(6),%a2
    movew %a3@(8),%d1
    asrw #1,%d1
    subqw #1,%d1
rsrc_atlk_10_EAE_22:    /* loop: move */
    movew %a2@+,%a1@+
    dbf %d1,rsrc_atlk_10_EAE_22
    movew %d0,%sr
    subaw %a3@(8),%a1
    clrw %d0
rsrc_atlk_10_EAE_30:    /* return */
    rts

/* subroutine (66 instructions): calls rsrc_atlk_10_FD2 (mechanical summary) */
rsrc_atlk_10_EE0:
    moveal %a3@(998),%a3
    jsr %pc@(rsrc_atlk_10_FD2)
rsrc_atlk_10_EE0_8:     /* loop: movea */
    moveal %a2,%a1
    moveal %a2@,%a2
    movel %a2,%d0
    jbeq rsrc_atlk_10_EE0_56
    addqw #6,%a2
    movew %a3@(6),%d0
    asrw #1,%d0
    subqw #1,%d0
rsrc_atlk_10_EE0_1A:    /* loop: cmpm */
    cmpmw %a0@+,%a2@+
    dbne %d0,rsrc_atlk_10_EE0_1A
    jbne rsrc_atlk_10_EE0_46
    movew %a3@(6),%d0
    subaw %d0,%a2
    subaw %d0,%a0
    subqw #6,%a2
    movew %sr,%d0
    oriw #1792,%sr
    andiw #-257,%sr
    movel %a2@,%a1@
    lea %a3@(16),%a1
    movel %a1@,%a2@
    movel %a2,%a1@
    movew %d0,%sr
    clrw %d0
    rts
rsrc_atlk_10_EE0_46:    /* set %d1 */
    movew %a3@(6),%d1
    aslw #1,%d0
    subw %d0,%d1
    subaw %d1,%a0
    subaw %d1,%a2
    subqw #6,%a2
    jbra rsrc_atlk_10_EE0_8
rsrc_atlk_10_EE0_56:    /* set %d0 */
    movew #-1,%d0
    rts
rsrc_atlk_10_F3C:       /* set %a3 */
    moveal %pc@(rsrc_atlk_10_94),%a3	| 408D877C
    moveal %a3@(998),%a3	| 408D8780
    movew %a3@(10),%d0	| 408D8784
    muluw #60,%d0	| 408D8788
    movew %d0,%a0@(10)	| 408D878C
    moveal %a3@(20),%a2	| 408D8790
    movew %a3@(4),%d0	| 408D8794
    subqw #1,%d0	| 408D8798
rsrc_atlk_10_F5A:       /* loop: movea */
    moveal %a2,%a0	| 408D879A
    movew %sr,%sp@-	| 408D879C
    oriw #1792,%sr	| 408D879E
    andiw #-257,%sr	| 408D87A2
rsrc_atlk_10_F66:       /* loop: movea */
    moveal %a2,%a1	| 408D87A6
    moveal %a2@,%a2	| 408D87A8
    movel %a2,%d1	| 408D87AA
    jbeq rsrc_atlk_10_F86	| 408D87AC
    bclr #7,%a2@(4)	| 408D87AE
    jbne rsrc_atlk_10_F66	| 408D87B4
    movel %a1,%d2	| 408D87B6
    movel %a2@,%a1@	| 408D87B8
    lea %a3@(16),%a1	| 408D87BA
    movel %a1@,%a2@	| 408D87BE
    movel %a2,%a1@	| 408D87C0
    moveal %d2,%a2	| 408D87C2
    jbra rsrc_atlk_10_F66	| 408D87C4
rsrc_atlk_10_F86:       /* set %sr */
    movew %sp@+,%sr	| 408D87C6
    moveal %a0,%a2	| 408D87C8
    addql #4,%a2	| 408D87CA
    dbf %d0,rsrc_atlk_10_F5A	| 408D87CC
    rts	| 408D87D0

/* subroutine (26 instructions): calls rsrc_atlk_10_FD2 (mechanical summary) */
rsrc_atlk_10_F92:
    jsr %pc@(rsrc_atlk_10_FD2)
rsrc_atlk_10_F92_4:     /* loop: movea */
    moveal %a2@,%a2
    movel %a2,%d0
    jbeq rsrc_atlk_10_F92_3A
    movew %a3@(6),%d0
    asrw #1,%d0
    subqw #1,%d0
    addqw #6,%a2
rsrc_atlk_10_F92_14:    /* loop: cmpm */
    cmpmw %a0@+,%a2@+
    dbne %d0,rsrc_atlk_10_F92_14
    jbne rsrc_atlk_10_F92_2A
    movew %a3@(6),%d0
    subaw %d0,%a2
    subaw %d0,%a0
    subqw #6,%a2
    clrw %d0
    rts
rsrc_atlk_10_F92_2A:    /* set %d1 */
    movew %a3@(6),%d1
    aslw #1,%d0
    subw %d0,%d1
    subaw %d1,%a0
    subaw %d1,%a2
    subqw #6,%a2
    jbra rsrc_atlk_10_F92_4
rsrc_atlk_10_F92_3A:    /* set %d0 */
    movew #-1,%d0
    rts

/* subroutine (34 instructions) (mechanical summary) */
rsrc_atlk_10_FD2:
    cmpiw #2,%a3@(6)
    jbne rsrc_atlk_10_FD2_E
    moveq #0,%d0
    movew %a0@,%d0
    jbra rsrc_atlk_10_FD2_36
rsrc_atlk_10_FD2_E:     /* from here: addaw %a3@(6),%a0 */
    addaw %a3@(6),%a0
    movel %a0@-,%d0
    jbpl rsrc_atlk_10_FD2_18
    negl %d0
rsrc_atlk_10_FD2_18:    /* test #4,%a3@(6) */
    cmpiw #4,%a3@(6)
    jbeq rsrc_atlk_10_FD2_22
    subqw #2,%a0
rsrc_atlk_10_FD2_22:    /* clear %d2 */
    moveq #0,%d2
    movew %a3@(4),%d2
    swap %d2
rsrc_atlk_10_FD2_2A:    /* loop: su */
    subl %d2,%d0
    jbge rsrc_atlk_10_FD2_2A
    divuw %a3@(4),%d0
    jbvc rsrc_atlk_10_FD2_3A
    addl %d2,%d0
rsrc_atlk_10_FD2_36:    /* from here: divuw %a3@(4),%d0 */
    divuw %a3@(4),%d0
rsrc_atlk_10_FD2_3A:    /* from here: swap %d0 */
    swap %d0
    aslw #2,%d0
    moveal %a3@(20),%a2
    addaw %d0,%a2
    movel %a2,%d2
    rts

rsrc_atlk_10_101A:      /* set %a0 */
    moveal %pc@(rsrc_atlk_10_94),%a0
    movel %a0@(0x0,%d0:w),%d0
    jbeq rsrc_atlk_10_101A_E
    moveal %d0,%a0
    jmp %a0@
rsrc_atlk_10_101A_E:    /* restore registers, return */
    moveml %sp@+,%d0/%a0
    rts
    .short  0x2D31	| 408D886E
