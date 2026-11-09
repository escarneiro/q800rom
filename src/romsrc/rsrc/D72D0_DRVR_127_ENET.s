/* ROM resource 'DRVR' 127 ".ENET": map entry at 0x408D72D0, data at 0x408D7300, 1292 bytes

 The .ENET driver shell ('DRVR' 127, "Ethernet Shell v127.0.3d2", (c) Apple): not the
 Ethernet driver itself but its loader. Open finds the Ethernet board (built in, or a
 card) with the Slot Manager, loads the matching Ethernet driver (an 'enet' resource:
 from the System file, else from the ROM, e.g. rsrc/D5AD0_enet_46.s), copies it into a
 new handle, calls its Open, lets it take over the device control entry and disposes
 of itself. Prime, Control and Status are the same empty routine; Close fails (closErr).
 Comments inferred from the code.
*/

rsrc_DRVR_127__ENET_entry:  /* map entry */
    .long   0x38000000, 0x00000000	| 408D72D0
    .long   rsrc_enet_46_entry-rom_start	| 408D72D8
    .long   rsrc_DRVR_127__ENET-rom_start	| 408D72DC
    .ascii  "DRVR"	| 408D72E0
    .byte   0x00, 0x7F, 0x58	| 408D72E4
    .byte   5	/* 408D72E7 Pascal string length */
    .ascii  ".ENET"	| 408D72E8
    FILL_408D72ED
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x05, 0x18, 0x00, 0x00, 0x03, 0x1C	| 408D72F4

/* subroutine (0 instructions): low memory ENET (mechanical summary) */
rsrc_DRVR_127__ENET:
    .byte   0x44, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408D7300
rsrc_DRVR_127__ENET_8:  /* (data) */
    .short  rsrc_DRVR_127__ENET_open-rsrc_DRVR_127__ENET	| 408D7308
    .short  rsrc_DRVR_127__ENET_prime-rsrc_DRVR_127__ENET	| 408D730A
    .short  rsrc_DRVR_127__ENET_prime-rsrc_DRVR_127__ENET	| 408D730C
    .short  rsrc_DRVR_127__ENET_prime-rsrc_DRVR_127__ENET	| 408D730E
    .short  rsrc_DRVR_127__ENET_close-rsrc_DRVR_127__ENET	| 408D7310
    .byte   5	/* 408D7312 Pascal string length */
    .ascii  ".ENET"	| 408D7313
    .byte   0x7F, 0x03, 0x20, 0x02, 0x00, 0x00, 0x09, 0x31	| 408D7318
    .long   0x32372E30, 0x2E336432, 0x3B457468, 0x65726E65	| 408D7320
    .long   0x74205368, 0x656C6C20, 0x76313237, 0x2E302E33	| 408D7330
    .long   0x64323B20, 0xA9204170, 0x706C6520, 0x436F6D70	| 408D7340
    .long   0x75746572, 0x2C20496E, 0x632E2031, 0x3939302D	| 408D7350
    .long   0x31393932	| 408D7360

/*
 Open: the board's slot and sResource (Slot Manager), the 'enet' driver for it, copied
 into a locked handle in the system heap; then the real driver's Open is called and the
 shell's own code released. Out: 0, or openErr (-23) when no driver was found.
*/
rsrc_DRVR_127__ENET_open:
    linkw %fp,#-4
    movel %a1,%fp@(-4)
    moveal %a0,%a2
    movew %a2@(6),%d0
    andiw #512,%d0
    jbeq rsrc_DRVR_127__ENET_open_164
    movew #27,%d0
rsrc_DRVR_127__ENET_open_1A:  /* loop: clr */
    clrw %sp@-
    dbf %d0,rsrc_DRVR_127__ENET_open_1A
    moveal %sp,%a0
    moveb #3,%a0@(48)
    moveb %a2@(34),%a0@(49)
    movew #1,%a0@(40)
    clrw %a0@(42)
    moveq #21,%d0	/* _SlotManager 21: NEXTTYPESRSRC, sNextTypesRsrc */
    _SlotManager
    jbne rsrc_DRVR_127__ENET_open_164
    moveb %a0@(49),%d0
    cmpb %a2@(34),%d0
    jbne rsrc_DRVR_127__ENET_open_164
    moveb #32,%a0@(50)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    jbne rsrc_DRVR_127__ENET_open_164
    movel %a0@,%d0
    subqw #4,%sp
    movel #1701733748,%sp@-
    movew %d0,%sp@-
    jbsr rsrc_DRVR_127__ENET_close_4
    moveal %sp@+,%a0
    movel %a0,%d3
    moveal %sp,%a0
    moveb %a2@(35),%a0@(50)
    moveq #45,%d0	/* _SlotManager 45: GETSLOTDRVR, sGetDriver */
    _SlotManager
    jbne rsrc_DRVR_127__ENET_open_80
    movel %a0@,%d4
    jbra rsrc_DRVR_127__ENET_open_88
rsrc_DRVR_127__ENET_open_80:  /* test %d3 */
    tstl %d3
    jbne rsrc_DRVR_127__ENET_open_BA
    jbra rsrc_DRVR_127__ENET_open_164
rsrc_DRVR_127__ENET_open_88:  /* test %d3 */
    tstl %d3
    jbeq rsrc_DRVR_127__ENET_open_104
    moveal %d4,%a3
    moveal %a3@,%a1
    moveq #0,%d0
    moveb %a1@(18),%d0
    addqw #2,%d0
    bclr #0,%d0
    movew %a1@(0x12,%d0:w),%d0
    moveal %d3,%a0
    moveal %a0@,%a0
    moveq #0,%d2
    moveb %a0@(18),%d2
    addqw #2,%d2
    bclr #0,%d2
    cmpw %a0@(0x12,%d2:w),%d0
    jbge rsrc_DRVR_127__ENET_open_100
    moveal %d4,%a0
    _DisposHandle
rsrc_DRVR_127__ENET_open_BA:  /* set up and call _DetachResource */
    movel %d3,%sp@-
    movel %sp@,%sp@-
    _DetachResource
    moveal %d3,%a3
    moveal %a3@,%a3
    moveal ROMBase,%a4
    cmpal %a4,%a3
    jbcs rsrc_DRVR_127__ENET_open_10E
    addal %a4@(64),%a4
    cmpal %a4,%a3
    jbhi rsrc_DRVR_127__ENET_open_10E
    moveal %sp@+,%a3
    moveal %a3,%a0
    _GetHandleSize
    movel %d0,%d5
    jbeq rsrc_DRVR_127__ENET_open_E2
    .short  0xA722	| 408D7442 _NewHandle (flags 0x0700)
    jbeq rsrc_DRVR_127__ENET_open_E8
rsrc_DRVR_127__ENET_open_E2:  /* set up and call _ReleaseResource */
    movel %a3,%sp@-
    _ReleaseResource
    jbra rsrc_DRVR_127__ENET_open_164
rsrc_DRVR_127__ENET_open_E8:  /* set %sp@- */
    movel %a0,%sp@-
    .short  0xA464	| 408D744E _MoveHHi (flags 0x0400)
    moveal %sp@,%a0
    .short  0xA429	| 408D7452 _HLock (flags 0x0400)
    moveal %sp@,%a0
    moveal %a0@,%a1
    moveal %a3@,%a0
    movel %d5,%d0
    _BlockMove
    movel %a3,%sp@-
    _ReleaseResource
    jbra rsrc_DRVR_127__ENET_open_10E
rsrc_DRVR_127__ENET_open_100:  /* set up and call _ReleaseResource */
    movel %d3,%sp@-
    _ReleaseResource
rsrc_DRVR_127__ENET_open_104:  /* set %sp@- */
    movel %d4,%sp@-
    moveal %sp@,%a0
    .short  0xA464	| 408D746C _MoveHHi (flags 0x0400)
    moveal %sp@,%a0
    .short  0xA429	| 408D7470 _HLock (flags 0x0400)
rsrc_DRVR_127__ENET_open_10E:  /* set up and call _StripAddress */
    moveal %sp@,%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    moveal %fp@(-4),%a1
    moveal %a1@,%a4
    movew %a1@(4),%d1
    movel %a3,%a1@
    moveb %a3@,%a1@(4)
    bclr #6,%a1@(5)
    moveal %a2,%a0
    movew %a3@(8),%d0
    moveml %d1/%a1/%a4,%sp@-
    jsr %a3@(0x0,%d0:w)
    moveml %sp@+,%d1/%a1/%a4
    movew %d0,%d3
    jbeq rsrc_DRVR_127__ENET_open_150
    moveal %sp@+,%a0
    _DisposHandle
    movel %a4,%a1@
    movew %d1,%a1@(4)	| 408D74AC
    movew %d3,%d0
    jbra rsrc_DRVR_127__ENET_open_166
rsrc_DRVR_127__ENET_open_150:  /* address %pc@(rsrc_DRVR_127__ENET) */
    lea %pc@(rsrc_DRVR_127__ENET),%a0
    .short  0xA128	| 408D74B8 _RecoverHandle (flags 0x0100)
    tstw MemErr
    jbne rsrc_DRVR_127__ENET_open_160
    movel %a0,%sp@-
    _DetachResource
rsrc_DRVR_127__ENET_open_160:  /* result 0 */
    moveq #0,%d0
    jbra rsrc_DRVR_127__ENET_open_166
rsrc_DRVR_127__ENET_open_164:  /* set %d0 */
    moveq #-23,%d0
rsrc_DRVR_127__ENET_open_166:  /* return */
    unlk %fp

/* Prime, Control, Status: nothing (they never reach the shell once the real driver is in). */
rsrc_DRVR_127__ENET_prime:
    rts

/* Close: closErr (-24): the shell cannot be closed. */
rsrc_DRVR_127__ENET_close:
    moveq #-24,%d0
    jbra rsrc_DRVR_127__ENET_prime

/*
 Find the 'enet' resource for the board: Get1Resource in the System file, else
 GetResource in the ROM map (CurMap/ROMMapInsert).
*/
rsrc_DRVR_127__ENET_close_4:
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
    jbeq rsrc_DRVR_127__ENET_close_38
    subal %a2,%a2
rsrc_DRVR_127__ENET_close_38:  /* set CurMap */
    movew SysMap,CurMap
    clrl %sp@-
    movel %fp@(10),%sp@-
    movew %fp@(8),%sp@-
    _Get1Resource
    moveal %sp@+,%a3
    tstw ResErr
    jbeq rsrc_DRVR_127__ENET_close_54
    subal %a3,%a3
rsrc_DRVR_127__ENET_close_54:  /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a2,%sp@-
    movel %a3,%sp@-
    movel %fp@(10),%sp@-
    bsrw rsrc_DRVR_127__ENET_286
    moveal %sp@+,%a2
    movel %d0,%d3
    movew %fp@(-2),CurMap
    clrl %sp@-
    movel %fp@(10),%sp@-
    movew %fp@(8),%sp@-
    _GetResource
    moveal %sp@+,%a3
    tstw ResErr
    jbeq rsrc_DRVR_127__ENET_close_82
    subal %a3,%a3
rsrc_DRVR_127__ENET_close_82:  /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a2,%sp@-
    movel %a3,%sp@-
    movel %fp@(10),%sp@-
    bsrw rsrc_DRVR_127__ENET_286
    moveal %sp@+,%a2
    movel %d0,%d3
    clrw ResErr
    movel %a2,%fp@(14)
    jbne rsrc_DRVR_127__ENET_close_A4
    movew #-192,ResErr
rsrc_DRVR_127__ENET_close_A4:  /* set %a0 */
    moveal %a2,%a0
    movel %d3,%d0
    moveml %sp@+,%d1-%d4/%a1-%a3
    movel %fp@(4),%fp@(10)
    unlk %fp
    addqw #6,%sp
    rts

/* subroutine (49 instructions): traps ReleaseResource; calls rsrc_DRVR_127__ENET_30E (mechanical summary) */
rsrc_DRVR_127__ENET_286:
    linkw %fp,#0
    moveml %d1-%d4/%a1-%a3,%sp@-
    moveal %fp@(16),%a2
    moveal %fp@(12),%a3
    subqw #4,%sp
    movel %a2,%sp@-
    movel %fp@(8),%sp@-
    bsrw rsrc_DRVR_127__ENET_30E
    movel %sp@+,%d3
    cmpiw #-32768,%d3
    jbne rsrc_DRVR_127__ENET_286_28
    moveb #0xff,%d3
rsrc_DRVR_127__ENET_286_28:  /* subtract 4 to %sp */
    subqw #4,%sp
    movel %a3,%sp@-
    movel %fp@(8),%sp@-
    bsrw rsrc_DRVR_127__ENET_30E
    movel %sp@+,%d4
    cmpiw #-32768,%d4
    jbne rsrc_DRVR_127__ENET_286_40
    moveb #0xff,%d4
rsrc_DRVR_127__ENET_286_40:  /* test %d3,%d4 */
    cmpl %d3,%d4
    jbcs rsrc_DRVR_127__ENET_286_58
    jbeq rsrc_DRVR_127__ENET_286_48
    jbra rsrc_DRVR_127__ENET_286_54
rsrc_DRVR_127__ENET_286_48:  /* set %d0 */
    movel %a2,%d0
    jbne rsrc_DRVR_127__ENET_286_4E
    jbra rsrc_DRVR_127__ENET_286_54
rsrc_DRVR_127__ENET_286_4E:  /* set %d0 */
    movel %a3,%d0
    jbeq rsrc_DRVR_127__ENET_286_66
    jbra rsrc_DRVR_127__ENET_286_58
rsrc_DRVR_127__ENET_286_54:  /* from here: exg %a2,%a3 */
    exg %a2,%a3
    exg %d3,%d4
rsrc_DRVR_127__ENET_286_58:  /* test %a2,%a3 */
    cmpal %a2,%a3
    jbeq rsrc_DRVR_127__ENET_286_66
    cmpaw #0,%a3
    jbeq rsrc_DRVR_127__ENET_286_66
    movel %a3,%sp@-
    _ReleaseResource
rsrc_DRVR_127__ENET_286_66:  /* set %fp@(20) */
    movel %a2,%fp@(20)
    moveal %a2,%a0
    cmpiw #-32513,%d3
    jbne rsrc_DRVR_127__ENET_286_74
    clrb %d3
rsrc_DRVR_127__ENET_286_74:  /* set %d0 */
    movel %d3,%d0
    moveml %sp@+,%d1-%d4/%a1-%a3
    movel %fp@(4),%fp@(16)
    unlk %fp
    lea %sp@(12),%sp
    rts

/* subroutine (84 instructions): traps GetHandleSize; calls rsrc_DRVR_127__ENET_414 (mechanical summary) */
rsrc_DRVR_127__ENET_30E:
    linkw %fp,#0
    moveml %d1-%d5/%a1-%a2,%sp@-
    moveq #0,%d4
    tstl %fp@(12)
    jbeq rsrc_DRVR_127__ENET_30E_EE
    moveal %fp@(12),%a0
    movel %a0@,%d5
    jbeq rsrc_DRVR_127__ENET_30E_EE
    moveal %fp@(12),%a0
    _GetHandleSize
    movel %d0,%d2
    jbmi rsrc_DRVR_127__ENET_30E_EE
    moveal %d5,%a2
    cmpil #1146246738,%fp@(8)
    jbeq rsrc_DRVR_127__ENET_30E_9A
    cmpil #1701733748,%fp@(8)
    jbeq rsrc_DRVR_127__ENET_30E_9A
    cmpil #1953459054,%fp@(8)
    jbeq rsrc_DRVR_127__ENET_30E_9A
    cmpil #1717855337,%fp@(8)
    jbeq rsrc_DRVR_127__ENET_30E_9A
    cmpil #1685223026,%fp@(8)
    jbeq rsrc_DRVR_127__ENET_30E_9A
    cmpil #8,%d2
    jbls rsrc_DRVR_127__ENET_30E_EE
    movew %a2@(6),%d4
    addaw %d4,%a2
    addil #11,%d4
    cmpl %d4,%d2
    jbls rsrc_DRVR_127__ENET_30E_EE
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
    bsrw rsrc_DRVR_127__ENET_414
    tstw %sp@+
    jbne rsrc_DRVR_127__ENET_30E_F0
    jbra rsrc_DRVR_127__ENET_30E_EE
rsrc_DRVR_127__ENET_30E_9A:  /* set %d4 */
    movew #18,%d4
    cmpl %d4,%d2
    jbls rsrc_DRVR_127__ENET_30E_EE
    moveq #0,%d0
    moveb %a2@(0x0,%d4:w),%d0
    addqw #1,%d0
    btst #0,%d0
    jbeq rsrc_DRVR_127__ENET_30E_B2
    addqw #1,%d0
rsrc_DRVR_127__ENET_30E_B2:  /* from here: addw %d0,%d4 */
    addw %d0,%d4
    addaw %d4,%a2
    addil #11,%d4
    cmpl %d4,%d2
    jbls rsrc_DRVR_127__ENET_30E_EE
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
    bsrw rsrc_DRVR_127__ENET_414
    tstw %sp@+
    jbne rsrc_DRVR_127__ENET_30E_EC
    movew %a2@,%d3
    clrb %d3
    swap %d3
    movew #-32768,%d3
rsrc_DRVR_127__ENET_30E_EC:  /* continue at rsrc_DRVR_127__ENET_30E_F0 */
    jbra rsrc_DRVR_127__ENET_30E_F0
rsrc_DRVR_127__ENET_30E_EE:  /* clear %d3 */
    moveq #0,%d3
rsrc_DRVR_127__ENET_30E_F0:  /* set %fp@(16) */
    movel %d3,%fp@(16)
    movel %d3,%d0
    moveml %sp@+,%d1-%d5/%a1-%a2
    movel %fp@(4),%fp@(12)
    unlk %fp
    addqw #8,%sp
    rts

/* subroutine (52 instructions): calls rsrc_DRVR_127__ENET_4B2 (mechanical summary) */
rsrc_DRVR_127__ENET_414:
    linkw %fp,#-16
    moveml %d1-%d4/%a1-%a2,%sp@-
    tstl %fp@(8)
    jbeq rsrc_DRVR_127__ENET_414_84
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
    bsrw rsrc_DRVR_127__ENET_4B2
    moveq #0,%d0
    moveb %a0@+,%d0
    addaw %d0,%a0
    movel %d3,%d0
    swap %d0
    lsrw #4,%d0
    andil #15,%d0
    bsrw rsrc_DRVR_127__ENET_4B2
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
    jbeq rsrc_DRVR_127__ENET_414_88
rsrc_DRVR_127__ENET_414_84:  /* result 0 */
    moveq #0,%d0
    jbra rsrc_DRVR_127__ENET_414_8A
rsrc_DRVR_127__ENET_414_88:  /* set %d0 */
    moveq #1,%d0
rsrc_DRVR_127__ENET_414_8A:  /* set %fp@(12) */
    movew %d0,%fp@(12)
    moveml %sp@+,%d1-%d4/%a1-%a2
    movel %fp@(4),%fp@(8)
    unlk %fp
    addqw #4,%sp
    rts

/* subroutine (25 instructions) (mechanical summary) */
rsrc_DRVR_127__ENET_4B2:
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
    jbne rsrc_DRVR_127__ENET_4B2_56
    moveb #2,%a0@
    moveb %a0@(2),%a0@(1)
    moveb %a0@(3),%a0@(2)
    cmpib #48,%a0@(1)
    jbne rsrc_DRVR_127__ENET_4B2_56
    moveb #1,%a0@
    moveb %a0@(2),%a0@(1)
rsrc_DRVR_127__ENET_4B2_56:  /* set %d0 */
    movel %sp@+,%d0
    rts
    FILL_408D780C
