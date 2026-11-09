/* ROM resource 'atlk' 3: map entry at 0x408D9490, data at 0x408D94C0, 698 bytes

 LocalTalk link code for port A ('atlk' 3, "LocalTalk atlk A v57.0.4"), (c) Apple 1984-1992.
 Loaded by the LAP Manager (lmgr 0) for the network connection chosen in parameter RAM;
 .MPP sends and receives through it. Comments inferred; routines summarised mechanically.
*/

rsrc_atlk_3_entry:      /* map entry */
    .long   0x38000000, 0x00000000	| 408D9490
    .long   rsrc_iopc_128_entry-rom_start	| 408D9498
    .long   rsrc_atlk_3-rom_start	| 408D949C
    .ascii  "atlk"	| 408D94A0
    .byte   0x00, 0x03, 0x58, 0x00	| 408D94A4
    FILL_408D94A8
    .byte   0xC0, 0xA0, 0x00, 0x00	| 408D94B4
    .short  0x0000, 0x02C6	| orib #0xc6,%d0
    .short  0x0000, 0x0304	| orib #4,%d0

/* subroutine (38 instructions): traps Gestalt, StripAddress, DockingDispatch; calls rsrc_atlk_3_204; low memory Apple, Computer, ROMBase (mechanical summary) */
rsrc_atlk_3:
    jbra rsrc_atlk_3_56
    bras rsrc_atlk_3_56_4
    orib #8,%d0
    movew %d4,%a4@-
    orb %d0,%d0
    .short  0x0000, 0x0835	| orib #53,%d0
    movew %fp@(12334),%a3@-
    .short  0x3420, 0x2000, 0x3C4C, 0x6F63, 0x616C, 0x5461, 0x6C6B, 0x2061	| 408D94D4
    .short  0x746C, 0x6B20, 0x4120, 0x7635, 0x372E, 0x302E, 0x3420, 0x203B	| 408D94E4
    .short  0x20A9	| 408D94F4
    .ascii  " Apple Computer, Inc. 1984-1992\000"

rsrc_atlk_3_56:         /* result -95 */
    moveq #-95,%d0
    jmp %a0@
rsrc_atlk_3_56_4:
    moveml %d0-%d7/%a1-%fp,%sp@-
    cmpiw #8,%d0
    bhiw rsrc_atlk_3_56_F6	| 408D9522
    lslw #1,%d0
    movew %pc@(rsrc_atlk_3_56_4_16,%d0:w),%d0	| 408D9528
    jmp %pc@(rsrc_atlk_3_56_4_16,%d0:w)
rsrc_atlk_3_56_4_16:
    .byte   0x00, 0xDC, 0x00, 0x12, 0x00, 0xDC, 0x00, 0xDC, 0x00, 0xDC, 0x00, 0xDC, 0x00, 0xDC, 0x00, 0xDC	| 408D9530
    .byte   0x00, 0xDC, 0x4A, 0x78, 0x02, 0x8E, 0x6B, 0x00, 0x00, 0xC4, 0x20, 0x3C, 0x00, 0x00, 0x08, 0xDA	| 408D9540
    .byte   0xA7, 0x1E	| 408D9550
    bnew rsrc_atlk_3_56_F6
    moveb %d4,%a0@(740)
    moveal ExpandMem,%a2
    movel %a0,%a2@(256)
    moveal %a0,%a2
    movel #1986863136,%d0
    .short  0xA1AD	| 408D956A _Gestalt (flags 0x0100)
    bnes rsrc_atlk_3_56_60
    movel %a0,%d0
    beqs rsrc_atlk_3_56_60
    moveb %d0,%a2@(1735)
rsrc_atlk_3_56_60:
    moveb #0xdd,%a2@(1750)	| 408D9576
    clrb %a2@(1751)
    clrw %a2@(1752)
    clrb %sp@-
    movew #-24442,%sp@-
    pea %pc@(rsrc_atlk_3_56_88)
    movel ATalkHk2,%d0
    addql #2,%d0
    movel %d0,%sp@-
    movel #196637,%d0
    rts
rsrc_atlk_3_56_88:
    tstb %sp@+
    beqs rsrc_atlk_3_56_9E
    moveb 0xbfe,%d0
    btst #0,%d0
    bnes rsrc_atlk_3_56_9E
    movew #3,%d0
    bsrs rsrc_atlk_3_56_100
    bras rsrc_atlk_3_56_BE
rsrc_atlk_3_56_9E:
    bsrw rsrc_atlk_3_1D6
    btst #0,%d0
    bnes rsrc_atlk_3_56_B8
rsrc_atlk_3_56_A8:
    moveal ExpandMem,%a2
    lea %a2@(256),%a1
    moveal %a1@,%a0
    clrl %a1@
    _DisposPtr
    bras rsrc_atlk_3_56_F6
rsrc_atlk_3_56_B8:
    movew #2,%d0
    bsrs rsrc_atlk_3_56_100
rsrc_atlk_3_56_BE:
    movel %a0,%d0
    beqs rsrc_atlk_3_56_A8
    movel %a0@,%d0
    _StripAddress
    movel %d0,%sp@-
    lea %pc@(rsrc_atlk_3),%a0
    moveal ATalkHk2,%a1
    moveq #3,%d0
    jsr %a1@(2)
    moveal %sp@,%a0
    moveq #2,%d0
    moveq #56,%d1
    clrw %d2
    jsr %a1@(2)
    moveal %sp@+,%a0
    moveml %sp@+,%d0-%d7/%a1-%fp
    jsr %a0@(2)
    moveq #3,%d1
    lea %pc@(rsrc_atlk_3),%a0
    jmp %pc@(rsrc_atlk_3_17C_2A_8)
rsrc_atlk_3_56_F6:
    moveml %sp@+,%d0-%d7/%a1-%fp
    movew #-1,%d0
    rts
rsrc_atlk_3_56_100:
    movew %d0,%sp@-
    subqw #4,%sp
    movel #1819569259,%sp@-
    movew %d0,%sp@-
    pea %pc@(rsrc_atlk_3_56_120)
    movel ATalkHk2,%d0
    addql #2,%d0
    movel %d0,%sp@-
    movel #131101,%d0
    rts
rsrc_atlk_3_56_120:
    moveal %sp@+,%a0
    addqw #2,%sp
    rts

rsrc_atlk_3_17C:        /* save registers */
    moveml %d1/%a1,%sp@-
    moveal %a0,%a1
    movel #1919905056,%d0
    .short  0xA1AD	| 408D9648 _Gestalt (flags 0x0100)
    movel %a0,%d1
    movel %a1,%d0
    _StripAddress
    moveal %d0,%a0
    movel ROMBase,%d0
    _StripAddress
    cmpal %d0,%a0
    jbcs rsrc_atlk_3_17C_28
    addl %d0,%d1
    moveq #0,%d0
    cmpal %d1,%a0
    jbcs rsrc_atlk_3_17C_2A
rsrc_atlk_3_17C_28:     /* set %d0 */
    moveq #-1,%d0
rsrc_atlk_3_17C_2A:     /* test %d0 */
    tstl %d0
    moveml %sp@+,%d1/%a1
    rts
rsrc_atlk_3_17C_2A_8:
    bsrw rsrc_atlk_3_17C
    beqs rsrc_atlk_3_17C_2A_2E
    .short  0xA128	| 408D9674 _RecoverHandle (flags 0x0100)
    tstw MemErr
    bnes rsrc_atlk_3_17C_2A_2E
    movel %a0,%sp@-
    movel %a0,%sp@-
    _DetachResource
    moveal %sp@+,%a1
    tstw ResErr
    bnes rsrc_atlk_3_17C_2A_2E
    movew #-24541,%d0
    .short  0xA146	| 408D968E _GetTrapAddress (flags 0x0100)
    exg %a0,%a1
    jmp %a1@
rsrc_atlk_3_17C_2A_2E:
    rts

rsrc_atlk_3_1D6:        /* save registers */
    moveml %d1-%d2/%a1-%a2,%sp@-
    clrb %sp@-
    movew #-21929,%sp@-
    bsrw rsrc_atlk_3_204
    tstb %sp@+
    jbeq rsrc_atlk_3_1D6_26
    subqw #4,%sp
    movel #1935893283,%sp@-
    clrl %sp@-
    _DockingDispatch
    movel %sp@+,%d0
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts
rsrc_atlk_3_1D6_26:     /* set %d0 */
    moveq #3,%d0
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts

/* subroutine (59 instructions): calls rsrc_atlk_3_2A6 (mechanical summary) */
rsrc_atlk_3_204:
    linkw %fp,#0
    moveml %d6-%d7,%sp@-
    movew %fp@(8),%d7
    movew #2048,%d0
    andw %d7,%d0
    jbeq rsrc_atlk_3_204_18
    moveq #1,%d0
    jbra rsrc_atlk_3_204_1A
rsrc_atlk_3_204_18:     /* clear %d0 */
    moveq #0,%d0
rsrc_atlk_3_204_1A:     /* set %d6 */
    moveb %d0,%d6
    moveq #0,%d0
    moveb %d6,%d0
    cmpiw #1,%d0
    jbne rsrc_atlk_3_204_6C
    movew #2047,%d0
    andw %d7,%d0
    movew %d0,%d7
    extl %d7
    subql #4,%sp
    movew #-22418,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_atlk_3_2A6)
    subql #4,%sp
    movew #-21906,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_atlk_3_2A6)
    movel %sp@+,%d0
    cmpl %sp@+,%d0
    jbne rsrc_atlk_3_204_5A
    movel #512,%d0
    jbra rsrc_atlk_3_204_60
rsrc_atlk_3_204_5A:     /* set %d0 */
    movel #1024,%d0
rsrc_atlk_3_204_60:     /* from here: extl %d0 */
    extl %d0
    cmpw %d7,%d0
    jbgt rsrc_atlk_3_204_6C
    clrb %fp@(10)
    jbra rsrc_atlk_3_204_94
rsrc_atlk_3_204_6C:     /* subtract 4 to %sp */
    subql #4,%sp
    movew %d7,%sp@-
    moveb %d6,%sp@-
    jsr %pc@(rsrc_atlk_3_2A6)
    subql #4,%sp
    movew #-22369,%sp@-
    moveq #1,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_atlk_3_2A6)
    movel %sp@+,%d0
    cmpl %sp@+,%d0
    sne %d0
    andiw #1,%d0
    extl %d0
    moveb %d0,%fp@(10)
rsrc_atlk_3_204_94:     /* restore registers, return */
    moveml %fp@(-8),%d6-%d7
    unlk %fp
    moveal %sp@+,%a0
    addqw #2,%sp
    jmp %a0@

/* subroutine (9 instructions): traps GetTrapAddress (mechanical summary) */
rsrc_atlk_3_2A6:
    moveal %sp@+,%a1
    moveb %sp@+,%d1
    movew %sp@+,%d0
    tstb %d1
    jbeq rsrc_atlk_3_2A6_E
    .short  0xA746	| 408D9770 _GetTrapAddress (flags 0x0700)
    jbra rsrc_atlk_3_2A6_10
rsrc_atlk_3_2A6_E:      /* (_GetTrapAddress (flags 0x0300)) */
    .short  0xA346	| 408D9774 _GetTrapAddress (flags 0x0300)
rsrc_atlk_3_2A6_10:     /* set %sp@ */
    movel %a0,%sp@
    jmp %a1@
    FILL_408D977A
