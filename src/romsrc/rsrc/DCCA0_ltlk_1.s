/* ROM resource 'ltlk' 1: map entry at 0x408DCCA0, data at 0x408DCCD0, 1708 bytes

 LocalTalk through the SCC I/O processor ('ltlk' 1, "IOP LocalTalk ltlk v57.0.4"), (c) Apple 1984-1992.
 Loaded by the LAP Manager (lmgr 0) for the network connection chosen in parameter RAM;
 .MPP sends and receives through it. Comments inferred; routines summarised mechanically.
*/

rsrc_ltlk_1_entry:      /* map entry */
    .long   0x38000000, 0x00000000	| 408DCCA0
    .long   rsrc_ltlk_0_entry-rom_start	| 408DCCA8
    .long   rsrc_ltlk_1-rom_start	| 408DCCAC
    .ascii  "ltlk"	| 408DCCB0
    .byte   0x00, 0x01, 0x58, 0x00	| 408DCCB4
    FILL_408DCCB8
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x06, 0xB8, 0x00, 0x00, 0x02, 0xD4	| 408DCCC4

/* subroutine (136 instructions): traps IOPMoveData, IOPMsgRequest, RecoverHandle, DetachResource; calls rsrc_ltlk_1_5B6, rsrc_ltlk_1_172_12C, rsrc_ltlk_1_606_7E, rsrc_ltlk_1_556_52; low memory Apple, Computer, ExpandMem, ATalkHk2 (mechanical summary) */
rsrc_ltlk_1:
    jbra rsrc_ltlk_1_58
    braw rsrc_ltlk_1_58_B4_12
    .short  0x0008	| 408DCCD6
    movew %d4,%a4@-
    orb %d0,%d0
    .short  0x0000, 0x0835	| orib #53,%d0
    movew %fp@(12334),%a3@-
    .short  0x3420, 0x2000, 0x3E49, 0x4F50, 0x204C, 0x6F63, 0x616C, 0x5461	| 408DCCE4
    .short  0x6C6B, 0x206C, 0x746C, 0x6B20, 0x7635, 0x372E, 0x302E, 0x3420	| 408DCCF4
    .short  0x203B, 0x20A9	| 408DCD04
    .ascii  " Apple Computer, Inc. 1984-1992\000"

rsrc_ltlk_1_58:         /* set %a3 */
    moveal ExpandMem,%a3
    moveal %a3@(112),%a3
    tstb %d0
    jbne rsrc_ltlk_1_58_7C
    moveml %d2/%a0-%a2,%a3@(750)
    movew %a3@(776),%a3@(1460)
    moveq #0,%d1
rsrc_ltlk_1_58_1A:      /* loop: move */
    movew %a1@+,%d2
    jbeq rsrc_ltlk_1_58_34
    addw %d2,%d1
    movew %d2,%a3@(1454)
    movel %a1@+,%a3@(1456)
    lea %a3@(1452),%a0
    _IOPMoveData
    addw %d2,%a3@(1460)
    jbra rsrc_ltlk_1_58_1A
rsrc_ltlk_1_58_34:      /* set %a3@(1464) */
    moveb #3,%a3@(1464)
    movew %d1,%a3@(1465)
    movew #784,%a3@(1437)
    lea %pc@(rsrc_ltlk_1_58_5A),%a0
    movel %a0,%a3@(1448)
    lea %a3@(1428),%a0
    _IOPMsgRequest
    moveml %a3@(750),%d2/%a0-%a2
    rts
rsrc_ltlk_1_58_5A:      /* set %a3 */
    moveal ExpandMem,%a3
    moveal %a3@(112),%a3
    tstb %a3@(1464)
    jbne rsrc_ltlk_1_58_72
    moveq #0,%d0
    moveml %a3@(750),%d2/%a0-%a2
    jmp %a0@
rsrc_ltlk_1_58_72:      /* set %d0 */
    moveq #-1,%d0
    moveml %a3@(750),%d2/%a0-%a2
    jmp %a0@
rsrc_ltlk_1_58_7C:      /* set %a3@(750) */
    moveml %d2/%a0-%a2,%a3@(750)
    moveb #2,%a3@(1464)
    moveb %d2,%a3@(1465)
    movew #528,%a3@(1437)
    clrl %a3@(1448)
    lea %a3@(1428),%a0
    _IOPMsgRequest
rsrc_ltlk_1_58_9C:      /* loop: tst */
    tstb %a3@(1439)
    jbne rsrc_ltlk_1_58_9C
    tstb %a3@(1464)
    jbne rsrc_ltlk_1_58_B4
    moveml %a3@(750),%d2/%a0-%a2
    movel %a2,%a3@(746)
    jmp %a0@
rsrc_ltlk_1_58_B4:      /* set %d0 */
    moveq #5,%d0
    moveal ATalkHk2,%a1
    jsr %a1@(2)
    moveml %a3@(750),%d2/%a0-%a2
    jmp %a0@
rsrc_ltlk_1_58_B4_12:
    moveml %d1-%d4/%a1-%a3,%sp@-
    moveal ExpandMem,%a3
    moveal %a3@(112),%a3
    cmpiw #11,%d0
    bhis rsrc_ltlk_1_58_B4_34+0x18	| 408DCDFE
    addw %d0,%d0
    movew %pc@(rsrc_ltlk_1_58_B4_34,%d0:w),%d0
    jsr %pc@(rsrc_ltlk_1_58_B4_34,%d0:w)
    moveml %sp@+,%d1-%d4/%a1-%a3
    rts
rsrc_ltlk_1_58_B4_34:
    orib #28,%a0@+
    bclr %d0,%a4@-
    .short  0x04DC	| .short 0x04dc
    orib #24,%a0@+
    orib #50,%a0@+
    movepw %d0,%a2@(488)
    andil #76706047,%a2@(20085)

rsrc_ltlk_1_15C:        /* save registers */
    moveml %d1/%d4,%sp@-
    lea %pc@(rsrc_ltlk_1),%a0
    .short  0xA128	| 408DCE34 _RecoverHandle (flags 0x0100)
    movel %a0,%sp@-
    _DetachResource
    moveml %sp@+,%d1/%d4
    clrw %d0
    rts

rsrc_ltlk_1_172:        /* save registers */
    moveml %d1-%d3/%a0-%a3,%sp@-
    jbsr rsrc_ltlk_1_5B6
    jbne rsrc_ltlk_1_172_124
    movew #256,%a3@(1452)
    clrw %a3@(1504)
    movel #1296,%a3@(1394)
    lea %a3@(1412),%a0
    movel %a0,%a3@(1404)
    movel %a0,%a3@(1400)
    movel #259,%a3@(1434)
    movel #16843264,%a3@(1464)
    moveb #16,%a3@(1438)
    lea %a3@(1464),%a0
    movel %a0,%a3@(1444)
    movel %a0,%a3@(1440)
    lea %a3@(1428),%a0
    _IOPMsgRequest
rsrc_ltlk_1_172_52:     /* loop: tst */
    tstb %a3@(1439)
    jbne rsrc_ltlk_1_172_52
    tstb %a3@(1464)
    jbne rsrc_ltlk_1_172_120
    movew #127,%d0
    jbsr rsrc_ltlk_1_172_12C
    tstl %a0
    jbeq rsrc_ltlk_1_172_102
    movel %a0,%sp@-
    movew %d1,%a3@(1454)
    movel %a0@,%a3@(1456)
    movew #22186,%a3@(1460)
    lea %a3@(1452),%a0
    _IOPMoveData
    moveal %sp@+,%a0
    jbsr rsrc_ltlk_1_606_7E
    movew #769,%a3@(1464)
    movew #528,%a3@(1437)
    lea %a3@(1428),%a0
    _IOPMsgRequest
rsrc_ltlk_1_172_9C:     /* loop: tst */
    tstb %a3@(1439)
    jbne rsrc_ltlk_1_172_9C
    tstb %a3@(1464)
    jbne rsrc_ltlk_1_172_102
    moveb #5,%a3@(1436)
    movew #256,%a3@(1464)
    movew #528,%a3@(1437)
    lea %a3@(1428),%a0
    _IOPMsgRequest
rsrc_ltlk_1_172_C0:     /* loop: tst */
    tstb %a3@(1439)
    jbne rsrc_ltlk_1_172_C0
    tstb %a3@(1464)
    jbne rsrc_ltlk_1_172_102
    movew %a3@(1465),%a3@(776)
    movel #132368,%a3@(1486)
    moveb #4,%a3@(1490)
    lea %a3@(1516),%a0
    movel %a0,%a3@(1492)
    movel %a0,%a3@(1496)
    lea %pc@(rsrc_ltlk_1_450),%a0
    movel %a0,%a3@(1500)
    lea %a3@(1480),%a0
    _IOPMsgRequest
    moveml %sp@+,%d1-%d3/%a0-%a3
    clrw %d0
    rts
rsrc_ltlk_1_172_102:    /* set %a3@(1436) */
    movel #16912384,%a3@(1436)
    movew #513,%a3@(1464)
    clrl %a3@(1448)
    lea %a3@(1428),%a0
    _IOPMsgRequest
rsrc_ltlk_1_172_11A:    /* loop: tst */
    tstb %a3@(1439)
    jbne rsrc_ltlk_1_172_11A
rsrc_ltlk_1_172_120:    /* call rsrc_ltlk_1_556_52 */
    jbsr rsrc_ltlk_1_556_52
rsrc_ltlk_1_172_124:    /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a0-%a3
    moveq #-1,%d0
    rts

/* subroutine (9 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_ltlk_1_172_12C:
    subqw #4,%sp
    movel #1768910947,%sp@-
    movew %d0,%sp@-
    pea %pc@(rsrc_ltlk_1_2BC)
    movel ATalkHk2,%d0
    addql #2,%d0
    movel %d0,%sp@-
    movel #131101,%d0
    rts

/* subroutine (34 instructions): traps GetHandleSize; calls rsrc_ltlk_1_5F2, rsrc_ltlk_1_38E, rsrc_ltlk_1_3BC, rsrc_ltlk_1_606 (mechanical summary) */
rsrc_ltlk_1_2BC:
    moveal %sp@,%a0	| 408DCF8C
    movel %a0,%d0	| 408DCF8E
    jbeq rsrc_ltlk_1_2C6	| 408DCF90
    _GetHandleSize	| 408DCF92
    movel %d0,%d1	| 408DCF94
rsrc_ltlk_1_2C6:        /* set %a0 */
    moveal %sp@+,%a0	| 408DCF96
    rts	| 408DCF98
    .byte   0x61, 0x2C, 0x41, 0xEB, 0x06, 0xDA, 0x30, 0x3C, 0x00, 0xFF, 0x42, 0x58, 0x51, 0xC8, 0xFF, 0xFC	| 408DCF9A
    .byte   0x42, 0x2B, 0x06, 0xD7, 0x42, 0x6B, 0x06, 0xD8, 0x4E, 0x75, 0x61, 0x12, 0x70, 0x03, 0x22, 0x78	| 408DCFAA
    .byte   0x0B, 0x18, 0x4E, 0xA9, 0x00, 0x02, 0x20, 0x4B, 0xA0, 0x1F, 0x70, 0x00, 0x4E, 0x75, 0x61, 0x00	| 408DCFBA
    .byte   0x02, 0xAE, 0x17, 0x7C, 0x00, 0x03, 0x05, 0xCF, 0x41, 0xEB, 0x05, 0xC8, 0xA0, 0x87, 0x27, 0x7C	| 408DCFCA
    .byte   0x01, 0x02, 0x10, 0x00, 0x05, 0x9C, 0x37, 0x7C, 0x02, 0x01, 0x05, 0xB8, 0x42, 0xAB, 0x05, 0xA8	| 408DCFDA
    .byte   0x41, 0xEB, 0x05, 0x94, 0xA0, 0x87, 0x4A, 0x2B, 0x05, 0x9F, 0x66, 0xFA, 0x4E, 0x75, 0x38, 0x28	| 408DCFEA
    .byte   0x00, 0x20, 0x70, 0x00, 0x24, 0x28, 0x00, 0x1C, 0x02, 0x82, 0x00, 0x00, 0x00, 0xFF, 0x10, 0x02	| 408DCFFA
    jbsr rsrc_ltlk_1_5F2
    jbne rsrc_ltlk_1_38A
    tstb %a3@(1751)
    jbne rsrc_ltlk_1_352
    movel %a0@(34),%a3@(746)
    jbsr rsrc_ltlk_1_38E
    jbne rsrc_ltlk_1_38A
    jbra rsrc_ltlk_1_356
rsrc_ltlk_1_352:        /* call rsrc_ltlk_1_3BC */
    jbsr rsrc_ltlk_1_3BC
    jbne rsrc_ltlk_1_38A
rsrc_ltlk_1_356:        /* set %d2 */
    movel %a0@(28),%d2
    andil #255,%d2
    movew %a0@(42),%d1
    tstb %a3@(1751)
    jbne rsrc_ltlk_1_37C
    moveb #0xff,%d0
    movew #-1,%d1
    jbsr rsrc_ltlk_1_606
    moveb %d2,%a3@(1751)
    moveq #-1,%d1
rsrc_ltlk_1_37C:        /* set %d0 */
    moveb %d2,%d0
    jbsr rsrc_ltlk_1_606
    addqw #1,%a3@(1752)
    moveq #0,%d0
    rts
rsrc_ltlk_1_38A:        /* result -50 */
    moveq #-50,%d0
    rts

/* subroutine (13 instructions): traps IOPMsgRequest (mechanical summary) */
rsrc_ltlk_1_38E:
    movel %a0,%sp@-
rsrc_ltlk_1_38E_2:      /* loop: move */
    moveb #2,%a3@(1412)
    moveb %d2,%a3@(1413)
    movew #528,%a3@(1397)
    clrl %a3@(1408)
    lea %a3@(1388),%a0
    _IOPMsgRequest
rsrc_ltlk_1_38E_1C:     /* loop: tst */
    tstb %a3@(1399)
    jbne rsrc_ltlk_1_38E_1C
    tstb %a3@(1412)
    dbne %d4,rsrc_ltlk_1_38E_2
    moveal %sp@+,%a0
    rts

/* subroutine (92 instructions): traps IOPMsgRequest, IOPMoveData; low memory ExpandMem (mechanical summary) */
rsrc_ltlk_1_3BC:
    movel %a0,%sp@-
rsrc_ltlk_1_3BC_2:      /* loop: move */
    moveb #5,%a3@(1412)
    moveb %d2,%a3@(1413)
    movew #528,%a3@(1397)
    clrl %a3@(1408)
    lea %a3@(1388),%a0
    _IOPMsgRequest
rsrc_ltlk_1_3BC_1C:     /* loop: tst */
    tstb %a3@(1399)
    jbne rsrc_ltlk_1_3BC_1C
    tstb %a3@(1412)
    dbne %d4,rsrc_ltlk_1_3BC_2
    moveal %sp@+,%a0
    rts
    .byte   0x2F, 0x08, 0x70, 0x00, 0x24, 0x28, 0x00, 0x1C, 0x02, 0x82, 0x00, 0x00, 0x00, 0xFF, 0x10, 0x02	| 408DD0BA
    .byte   0x61, 0x00, 0x01, 0xF6, 0x31, 0x40, 0x00, 0x2A, 0x67, 0x42, 0x0C, 0x42, 0x00, 0xFF, 0x67, 0x0A	| 408DD0CA
    .byte   0x0C, 0x40, 0xFF, 0xFF, 0x66, 0x04, 0x42, 0x2B, 0x06, 0xD7, 0x10, 0x02, 0x72, 0x00, 0x61, 0x00	| 408DD0DA
    .byte   0x01, 0xEC, 0x53, 0x6B, 0x06, 0xD8, 0x17, 0x7C, 0x00, 0x05, 0x05, 0x84, 0x17, 0x42, 0x05, 0x85	| 408DD0EA
    .byte   0x37, 0x7C, 0x02, 0x10, 0x05, 0x75, 0x42, 0xAB, 0x05, 0x80, 0x41, 0xEB, 0x05, 0x6C, 0xA0, 0x87	| 408DD0FA
    .byte   0x4A, 0x2B, 0x05, 0x77, 0x66, 0xFA, 0x10, 0x2B, 0x05, 0x84, 0x60, 0x02, 0x70, 0xCE, 0x20, 0x5F	| 408DD10A
    .byte   0x31, 0x40, 0x00, 0x10, 0x4E, 0x75	| 408DD11A
rsrc_ltlk_1_450:        /* set %a3 */
    moveal ExpandMem,%a3	| 408DD120
    moveal %a3@(112),%a3	| 408DD124
    movew %sr,%a3@(704)	| 408DD128
    movew #9728,%sr	| 408DD12C
    moveml %a4-%a5,%a3@(766)	| 408DD130
    movew %a3@(1519),%d0	| 408DD136
    subqw #2,%d0	| 408DD13A
    movew %d0,%a3@(1506)	| 408DD13C
    lea %a3@(782),%a0	| 408DD140
    movel %a0,%a3@(1508)	| 408DD144
    movew %a3@(1517),%a3@(1512)	| 408DD148
    lea %a3@(1504),%a0	| 408DD14E
    _IOPMoveData	| 408DD152
    moveal %a3@(746),%a2	| 408DD154
    lea %a2@(1),%a0	| 408DD158
    lea %a3@(782),%a1	| 408DD15C
    movel %a1@+,%a0@+	| 408DD160
    moveb %a1@+,%a0@+	| 408DD162
    movel %a1,%a3@(778)	| 408DD164
    movew %a3@(1519),%d1	| 408DD168
    subqw #5,%d1	| 408DD16C
    movew %a2@(4),%d2	| 408DD16E
    andiw #1023,%d2	| 408DD172
    cmpw %d2,%d1	| 408DD176
    jbeq rsrc_ltlk_1_4B0	| 408DD178
    addql #1,%a3@(1694)	| 408DD17A
    jbra rsrc_ltlk_1_4EE	| 408DD17E
rsrc_ltlk_1_4B0:        /* clear %d2 */
    moveq #0,%d2	| 408DD180
    movel %a0,%sp@-	| 408DD182
    moveq #0,%d0	| 408DD184
    moveb %a2@(1),%d0	| 408DD186
    addw %d0,%d0	| 408DD18A
    lea %a3@(1754),%a0	| 408DD18C
    movew %a0@(0,%d0:w),%d2	| 408DD190
    swap %d2	| 408DD194
    moveal %sp@+,%a0	| 408DD196
    subqw #2,%d1	| 408DD198
    movew %d1,%a3@(774)	| 408DD19A
    moveal %a0,%a3	| 408DD19E
    lea %pc@(rsrc_ltlk_1_50A),%a4	| 408DD1A0
    moveb %a2@(3),%d2	| 408DD1A4
    moveq #1,%d0	| 408DD1A8
    moveal ATalkHk2,%a1	| 408DD1AA
    jsr %a1@(2)	| 408DD1AE
    moveal ExpandMem,%a3	| 408DD1B2
    moveal %a3@(112),%a3	| 408DD1B6
    addql #1,%a3@(1690)	| 408DD1BA
rsrc_ltlk_1_4EE:        /* set %sr */
    movew %a3@(704),%sr	| 408DD1BE
    moveb #1,%a3@(1487)	| 408DD1C2
    clrb %a3@(1516)	| 408DD1C8
    lea %a3@(1480),%a0	| 408DD1CC
    _IOPMsgRequest	| 408DD1D0
    moveml %a3@(766),%a4-%a5	| 408DD1D2
    rts	| 408DD1D8
rsrc_ltlk_1_50A:        /* (data) */
    .byte   0x60, 0x02, 0x60, 0x48, 0x48, 0xE7, 0x00, 0xC0, 0x20, 0x78, 0x02, 0xB6, 0x20, 0x68, 0x00, 0x70	| 408DD1DA
    .byte   0xB6, 0x68, 0x03, 0x06, 0x6E, 0x22, 0x97, 0x68, 0x03, 0x06, 0x22, 0x68, 0x03, 0x0A, 0x60, 0x02	| 408DD1EA
    .byte   0x16, 0xD9, 0x51, 0xCB, 0xFF, 0xFC, 0x21, 0x49, 0x03, 0x0A, 0x32, 0x28, 0x03, 0x06, 0x70, 0x00	| 408DD1FA
    .byte   0x76, 0x00, 0x4C, 0xDF, 0x03, 0x00, 0x4E, 0x75, 0x46, 0xE8, 0x02, 0xC0, 0x4C, 0xE8, 0x30, 0x00	| 408DD20A
    .byte   0x02, 0xFE, 0x4C, 0xDF, 0x03, 0x00, 0x10, 0x3C, 0x00, 0xFF, 0x4E, 0x75	| 408DD21A

rsrc_ltlk_1_556:        /* save registers */
    moveml %a0-%a2,%sp@-
    moveal ExpandMem,%a2
    moveal %a2@(112),%a2
    tstw %d3
    jbeq rsrc_ltlk_1_556_2C
    tstw %a2@(774)
    jbeq rsrc_ltlk_1_556_2C
    moveal %a2@(778),%a1
    movew %a2@(774),%d0
    cmpw %d0,%d3
    jbge rsrc_ltlk_1_556_28
    movew %d3,%d0
    jbra rsrc_ltlk_1_556_28
rsrc_ltlk_1_556_26:     /* loop: move */
    moveb %a1@+,%a3@+
rsrc_ltlk_1_556_28:     /* count down */
    dbf %d0,rsrc_ltlk_1_556_26
rsrc_ltlk_1_556_2C:     /* set %sr */
    movew %a2@(704),%sr
    moveb #1,%a2@(1487)
    clrb %a2@(1516)
    lea %a2@(1480),%a0
    _IOPMsgRequest
    subw %a2@(774),%d3
    moveml %a2@(766),%a4-%a5
    moveml %sp@+,%a0-%a2
    moveq #0,%d0
    rts

/* subroutine (5 instructions): low memory ATalkHk2 (mechanical summary) */
rsrc_ltlk_1_556_52:
    moveq #18,%d0
    moveq #1,%d1
    moveal ATalkHk2,%a1
    jsr %a1@(2)
    rts

/* subroutine (18 instructions): calls rsrc_ltlk_1_5F2; low memory ATalkHk2 (mechanical summary) */
rsrc_ltlk_1_5B6:
    moveml %d1/%a1,%sp@-
    moveal ATalkHk2,%a1
    moveq #17,%d0
    moveq #1,%d1
    jsr %a1@(2)
    moveml %sp@+,%d1/%a1
    jbne rsrc_ltlk_1_5B6_18
    moveq #0,%d0
rsrc_ltlk_1_5B6_18:     /* test %d0 */
    tstw %d0
    rts
    .short  0x7000, 0x2028, 0x001C, 0x0280	| 408DD2A2
    orib #0xff,%d0
    bsrw rsrc_ltlk_1_5F2
    movew %d0,%a0@(42)
    jbne rsrc_ltlk_1_5B6_38
    movew #-50,%d0
    jbra rsrc_ltlk_1_5B6_3A
rsrc_ltlk_1_5B6_38:     /* clear %d0 */
    moveq #0,%d0
rsrc_ltlk_1_5B6_3A:     /* return */
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_ltlk_1_5F2:
    movel %a0,%sp@-
    andiw #255,%d0
    addw %d0,%d0
    lea %a3@(1754),%a0
    movew %a0@(0x0,%d0:w),%d0
    moveal %sp@+,%a0
    rts

/* subroutine (7 instructions) (mechanical summary) */
rsrc_ltlk_1_606:
    movel %a0,%sp@-
    andil #255,%d0
    addw %d0,%d0
    lea %a3@(1754),%a0
    movew %d1,%a0@(0x0,%d0:w)
    moveal %sp@+,%a0
    rts
    cmpiw #22,%d1
    blts rsrc_ltlk_1_606_3C
    movel %a0,%sp@-
    movel %a1,%d0
    lea %pc@(rsrc_ltlk_1_606_40),%a0
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    clrl %a1@+
    movew %a0@+,%a1@+
    clrl %a1@+
    clrb %a1@+
    moveb %a3@,%a1@+
    movew %a0@+,%a1@+
    moveal %d0,%a1
    moveal %sp@+,%a0
    clrw %d0
    rts
rsrc_ltlk_1_606_3C:
    moveq #-1,%d0
    rts
rsrc_ltlk_1_606_40:
    .long   0x00030016 /* number, not an address (F1) */	| 408DD316
    .long   0x00039210 /* number, not an address (F1) */	| 408DD31A
    .long   0x000100FE /* number, not an address (F1) */	| 408DD31E

/* subroutine (19 instructions): traps Gestalt, StripAddress; low memory ROMBase (mechanical summary) */
rsrc_ltlk_1_606_4C:
    moveml %d1/%a1,%sp@-
    moveal %a0,%a1
    movel #1919905056,%d0
    .short  0xA1AD	| 408DD32E _Gestalt (flags 0x0100)
    movel %a0,%d1
    movel %a1,%d0
    _StripAddress
    moveal %d0,%a0
    movel ROMBase,%d0
    _StripAddress
    cmpal %d0,%a0
    jbcs rsrc_ltlk_1_606_74
    addl %d0,%d1
    moveq #0,%d0
    cmpal %d1,%a0
    jbcs rsrc_ltlk_1_606_76
rsrc_ltlk_1_606_74:     /* set %d0 */
    moveq #-1,%d0
rsrc_ltlk_1_606_76:     /* test %d0 */
    tstl %d0
    moveml %sp@+,%d1/%a1
    rts

/* subroutine (15 instructions): traps RecoverHandle, DetachResource, GetTrapAddress; calls rsrc_ltlk_1_606_4C; low memory MemErr, ResErr (mechanical summary) */
rsrc_ltlk_1_606_7E:
    bsrw rsrc_ltlk_1_606_4C
    jbeq rsrc_ltlk_1_606_A4
    .short  0xA128	| 408DD35A _RecoverHandle (flags 0x0100)
    tstw MemErr
    jbne rsrc_ltlk_1_606_A4
    movel %a0,%sp@-
    movel %a0,%sp@-
    _DetachResource
    moveal %sp@+,%a1
    tstw ResErr
    jbne rsrc_ltlk_1_606_A4
    movew #-24541,%d0
    .short  0xA146	| 408DD374 _GetTrapAddress (flags 0x0100)
    exg %a0,%a1
    jmp %a1@
rsrc_ltlk_1_606_A4:     /* return */
    rts
    FILL_408DD37C
