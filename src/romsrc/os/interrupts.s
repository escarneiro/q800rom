/*
 os/interrupts.s - interrupt handlers, power off, interrupt sources
 From INTHND (0x40809B00). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 Interrupt dispatch tables in low memory: Lvl1DT (0x192, VIA 1, 8 entries), Lvl2DT
 (0x1B2, SCC), VIA2DT (0xD70, VIA 2 / slots). 0xD74 the slot interrupt handler.
*/

/*
 INTHND: interrupt handlers for the autovectors (raw words partly): rte for unused
 levels, and for each level: save d0-d3/a0-a3, a3 = the handler for the interrupt
 source, then the common code below (INTHND_68).
*/
INTHND:
    rte	| 40809B00
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40809B02
INTHND_10:              /* (level handler, other configuration) */
    moveml %d0-%d3/%a0-%a3,%sp@-	| 40809B10
    lea %pc@(SCCIOPBYPASSINT_60),%a3	| 40809B14
    jbra INTHND_68	| 40809B18
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40809B1A
INTHND_20:              /* (level handler) */
    moveml %d0-%d3/%a0-%a3,%sp@-	| 40809B20
    lea %pc@(SCCIOPBYPASSINT),%a3	| 40809B24
    jbra INTHND_68	| 40809B28
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40809B2A
INTHND_30:              /* (level handler) */
    moveml %d0-%d3/%a0-%a3,%sp@-	| 40809B30
    lea %pc@(SCCIOPBYPASSINT_B0),%a3	| 40809B34
    jbra INTHND_68	| 40809B38
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40809B3A
INTHND_40:              /* level 2: VIA 2 interrupts (INTHND_E0) */
    moveml %d0-%d3/%a0-%a3,%sp@-
    lea %pc@(INTHND_E0),%a3
    jbra INTHND_68
    .short  0x0000, 0x0000, 0x0000	| 40809B4A
INTHND_50:              /* (level handler, other configuration) */
    moveml %d0-%d3/%a0-%a3,%sp@-	| 40809B50
    lea %pc@(SCCIOPBYPASSINT_80),%a3	| 40809B54
    jbra INTHND_68	| 40809B58
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40809B5A
INTHND_60:              /* level 1: VIA 1 interrupts (INTHND_C0) */
    moveml %d0-%d3/%a0-%a3,%sp@-
    lea %pc@(INTHND_C0),%a3
INTHND_68:              /* common: in 24-bit mode with 0xB73 bit 0, switch to 32-bit around the handler */
    tstb MMU32Bit
    jbne INTHND_8A
INTHND_6E:              /* call the handler, then the deferred tasks if returning to level 0 */
    jsr %a3@
    tstl DTskQHdr
    jbeq INTHND_84
    moveq #7,%d0
    andb %sp@(32),%d0
    jbne INTHND_84
    moveal 0x6e4,%a0
    jsr %a0@
INTHND_84:              /* return from the interrupt */
    moveml %sp@+,%d0-%d3/%a0-%a3
    rte
INTHND_8A:              /* (32-bit around the handler) */
    btst #0,0xb73
    jbeq INTHND_6E
    moveq #0,%d0
    moveal JSwapMMU,%a0
    jsr %a0@
    jsr %a3@
    tstl DTskQHdr
    jbeq INTHND_B0
    moveq #7,%d0
    andb %sp@(32),%d0
    jbne INTHND_B0
    moveal 0x6e4,%a0
    jsr %a0@
INTHND_B0:              /* back to 24-bit mode */
    moveq #1,%d0
    moveal JSwapMMU,%a0
    jsr %a0@
    moveml %sp@+,%d0-%d3/%a0-%a3
    rte
    .short  0x0000	| 40809BBE
INTHND_C0:              /* VIA 1: highest pending enabled interrupt (IFR & IER) through the priority table to its Lvl1DT entry */
    moveal VIA,%a1
    moveq #127,%d0
    andb %a1@(6656),%d0
    andb %a1@(7168),%d0
    moveaw %pc@(INTHND_FA,%d0:w:2),%a0
    moveal %a0@,%a0
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40809BD6

INTHND_E0:              /* VIA 2: the same with VIA2DT (0xD70) */
    moveal ghost_VIA2,%a1
    moveq #127,%d0
    andb %a1@(6659),%d0
    lea 0xbde,%a0
    andb %a1@(7187),%d0
    addaw %pc@(INTHND_FA,%d0:w:2),%a0
    moveal %a0@,%a0
    jmp %a0@
INTHND_FA:              /* priority table: for each 7-bit IFR value, the dispatch table entry of its highest bit */
    .short  0x01AE, 0x0192, 0x0196	| 40809BFA
    .long   0x0192019A, 0x01920196, 0x0192019E, 0x01920196	| 40809C00
    .long   0x0192019A, 0x01920196, 0x019201A2, 0x01920196	| 40809C10
    .long   0x0192019A, 0x01920196, 0x0192019E, 0x01920196	| 40809C20
    .long   0x0192019A, 0x01920196, 0x019201A6, 0x01920196	| 40809C30
    .long   0x0192019A, 0x01920196, 0x0192019E, 0x01920196	| 40809C40
    .long   0x0192019A, 0x01920196, 0x019201A2, 0x01920196	| 40809C50
    .long   0x0192019A, 0x01920196, 0x0192019E, 0x01920196	| 40809C60
    .long   0x0192019A, 0x01920196, 0x019201AA, 0x01920196	| 40809C70
    .long   0x0192019A, 0x01920196, 0x0192019E, 0x01920196	| 40809C80
    .long   0x0192019A, 0x01920196, 0x019201A2, 0x01920196	| 40809C90
    .long   0x0192019A, 0x01920196, 0x0192019E, 0x01920196	| 40809CA0
    .long   0x0192019A, 0x01920196, 0x019201A6, 0x01920196	| 40809CB0
    .long   0x0192019A, 0x01920196, 0x0192019E, 0x01920196	| 40809CC0
    .long   0x0192019A, 0x01920196, 0x019201A2, 0x01920196	| 40809CD0
    .long   0x0192019A, 0x01920196, 0x0192019E, 0x01920196	| 40809CE0
    .long   0x0192019A, 0x01920196, 0x01920000, 0x00000000	| 40809CF0

/*
 SCCIOPBYPASSINT: SCC interrupt (SCC IOP in bypass mode): read the SCC's interrupt
 vector (register 2 of channel B) and jump to the Lvl2DT entry for it.
*/
SCCIOPBYPASSINT:
    moveal SCCRd,%a0
    moveb %a0@,%d0
    moveal SCCWr,%a1
    moveb #2,%a1@
    lea Lvl2DT,%a2
    moveq #14,%d0
    andb %a0@,%d0
    cmpib #8,%d0
    jblt SCCIOPBYPASSINT_20
    addqw #2,%a0
    addqw #2,%a1
SCCIOPBYPASSINT_20:     /* (channel A: other registers) */
    moveal %a2@(0x0,%d0:w:2),%a2
    jmp %a2@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40809D26
SCCIOPBYPASSINT_30:     /* external/status interrupt of channel B: status change, ExtStsDT handler */
    moveb %a0@,%d0
    lea SCCBSts,%a3
    lea ExtStsDT,%a2
    jbra SCCIOPBYPASSINT_4A
    .long   0x00000000	| 40809D3C
SCCIOPBYPASSINT_40:     /* the same for channel A */
    moveb %a0@,%d0
    lea SCCASts,%a3
    lea ExtStsDT_A,%a2
SCCIOPBYPASSINT_4A:     /* changed status bits, reset the interrupt, call the handler */
    moveb #15,%a1@
    moveb %a3@,%d1
    moveb %d0,%a3@
    eorb %d0,%d1
    andb %a0@,%d1
    moveb #16,%a1@
    moveal %a2@,%a2
    jmp %a2@
    .short  0x0000	| 40809D5E
SCCIOPBYPASSINT_60:     /* result 0 */
    moveq #0,%d0
    jmp %pc@(IOPINTERRUPT)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40809D66
SCCIOPBYPASSINT_70:     /* SWIM IOP interrupt (acknowledge VIA 2), IOP 1 */
    moveb #1,%a1@(6656)
SCCIOPBYPASSINT_76:     /* IOPINTERRUPT for IOP d0 */
    moveq #1,%d0
    jmp %pc@(IOPINTERRUPT)
    .long   0x00000000	| 40809D7C
SCCIOPBYPASSINT_80:     /* set %a1 */
    moveal ghost_VIA2,%a1
    movew %a1@(514),%d0
    btst #6,%d0
    jbne SCCIOPBYPASSINT_9E
SCCIOPBYPASSINT_8E:     /* (other interrupt controller: which source?) */
    btst #11,%d0
    jbne INTHND_C0
    btst #10,%d0
    jbne SCCIOPBYPASSINT_F0
    rts
SCCIOPBYPASSINT_9E:     /* (IOP) */
    moveq #7,%d1
    andb %a1@(6),%d1
    jbne SCCIOPBYPASSINT_76
    jbra SCCIOPBYPASSINT_8E
    .long   0x00000000, 0x00000000	| 40809DA8
SCCIOPBYPASSINT_B0:     /* (data) */
    moveal ghost_VIA2,%a1
    movew %a1@(514),%d0
    btst #9,%d0
    bnes SCCIOPBYPASSINT_B0_1A
SCCIOPBYPASSINT_B0_E:
    btst #8,%d0
    bnes SCCIOPBYPASSINT_B0_28
SCCIOPBYPASSINT_B0_14:
    moveal 0xd74,%a0
    jmp %a0@
SCCIOPBYPASSINT_B0_1A:
    moveq #7,%d1
    andb %a1@(9),%d1
    beqs SCCIOPBYPASSINT_B0_E
    moveal 0xd7c,%a0
    jmp %a0@
SCCIOPBYPASSINT_B0_28:
    moveq #7,%d1
    andb %a1@(8),%d1
    beqs SCCIOPBYPASSINT_B0_14
    moveal 0xd80,%a0
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40809DE6
SCCIOPBYPASSINT_F0:     /* (60 Hz from the other controller: VBL handler) */
    lea %a1@(-6137),%a1
    moveal 0x196,%a0
    jmp %a0@
    moveal Lvl1DT_2,%a0
    jmp %a0@
SCCIOPBYPASSINT_100:    /* NMI handler: debugger */
    bset #6,NMIFlag	| 40809E00
    jbne SCCIOPBYPASSINT_114	| 40809E06
    movew %sp@,%sr	| 40809E08
    moveml %d0/%a0,%sp@-	| 40809E0A
    _PowerOff	| 40809E0E
    moveml %sp@+,%d0/%a0	| 40809E10
SCCIOPBYPASSINT_114:    /* return from the exception */
    rte	| 40809E14

/*
 _PowerOff: wait a moment, the Power Manager patch, then the machine-specific power off
 (POWEROFFPATCH).
*/
trap_PowerOff:
POWEROFF:
    bsrw POWEROFFCONT_18
    jbsr PMGRPOWEROFFPATCH
    bigjmp POWEROFFPATCH
POWEROFFCONT:           /* (raw words: the old power off through VIA 2) */
    moveal ghost_VIA2,%a0
    bras POWEROFFCONT_A	| 40809E2E
    .byte   0x00, 0x00, 0x00, 0x00	| 40809E30
POWEROFFCONT_A:
    btst #2,0xdd1	| 40809E34
    jbeq POWEROFFCONT_18
    bset #7,%a0@(516)

POWEROFFCONT_18:        /* delay: about 1500 x TimeDBRA loops */
    movel #-98304000,%d0
POWEROFFCONT_1E:        /* one millisecond */
    movew TimeDBRA,%d0
POWEROFFCONT_22:        /* loop */
    dbf %d0,POWEROFFCONT_22
    addql #1,%d0
    jbne POWEROFFCONT_1E
    rts

/*
 INITINTHANDLER: set up the interrupt dispatch tables: all entries to an rts, VIA 1
 one second (CLOCK) and 60 Hz (VBLINT), SCC status handlers for the SCC IOP bypass
 mode, VIA 2 entries, then the slot interrupt handler and the autovectors for this
 machine's interrupt hardware (VIA 2, RBV or OSS).
*/
INITINTHANDLER:
    lea Lvl1DT,%a0
    lea %pc@(GOTSLOTHANDLER_7A),%a1
    moveq #15,%d0
INITINTHANDLER_A:       /* fill Lvl1DT */
    movel %a1,%a0@+
    dbf %d0,INITINTHANDLER_A
    lea %pc@(CLOCK),%a0
    movel %a0,Lvl1DT
    lea %pc@(VBLINT),%a0
    movel %a0,0x196
    btst #2,HWCfgFlags
    jbeq INITINTHANDLER_4A
    lea Lvl2DT_1,%a2
    lea %pc@(SCCIOPBYPASSINT_30),%a0
    movel %a0,%a2@
    lea %pc@(SCCIOPBYPASSINT_40),%a0
    movel %a0,%a2@(16)
    lea ExtStsDT,%a2
    lea %pc@(GOTSLOTHANDLER_7A),%a0
    movel %a0,%a2@+
    movel %a0,%a2@+
    movel %a0,%a2@+
    movel %a0,%a2@+
INITINTHANDLER_4A:      /* VIA2DT */
    lea VIA2DT,%a2
    moveq #7,%d0
INITINTHANDLER_50:      /* fill */
    movel %a0,%a2@+
    dbf %d0,INITINTHANDLER_50
    lea %pc@(VIA2SLOTINT),%a0
    jbra INITSLOTINTSPATCH
    .short  0x0000	| 40809EB6
INTHANDLERNOVIA2:       /* no VIA 2: the RBV or OSS slot interrupt handler */
    lea %pc@(RBVSLOTINT),%a0
    btst #5,0xdd2
    jbne GOTSLOTHANDLER
    lea %pc@(OSSSLOTINT),%a0
    btst #2,0xdd1
    nop
GOTSLOTHANDLER:         /* set it, then the autovectors */
    movel %a0,0xd74
    lea Lev1AutoVector,%a2
    btst #2,0xdd1
    jbeq GOTSLOTHANDLER_1C
    lea %pc@(INTHND_50),%a0
    movel %a0,%a2@+
    lea %pc@(INTHND_30),%a0
    movel %a0,%a2@+
GOTSLOTHANDLER_1C:      /* VIA 1 and VIA 2 handlers (no OSS) */
    btst #2,0xdd1
    jbne GOTSLOTHANDLER_40
    lea %pc@(INTHND_60),%a0
    movel %a0,%a2@+
    lea %pc@(INTHND_40),%a0
    movel %a0,%a2@+
    btst #0,0xdd1
    jbeq GOTSLOTHANDLER_40
    lea %pc@(SCCIOPBYPASSINT_70),%a0
    movel %a0,VIA2DT
GOTSLOTHANDLER_40:      /* level 3 (Ethernet/parity) */
    lea %pc@(ENABLEPARITYINTS_2E),%a0
    movel %a0,%a2@+
    btst #1,0xdd1
    jbeq GOTSLOTHANDLER_54
    lea %pc@(INTHND_10),%a0
    movel %a0,%a2@+
GOTSLOTHANDLER_54:      /* SCC level handler */
    btst #1,0xdd1
    jbne GOTSLOTHANDLER_62
    lea %pc@(INTHND_20),%a0
    movel %a0,%a2@+
GOTSLOTHANDLER_62:      /* levels 5 and 6 */
    lea %pc@(INTHND),%a0
    movel %a0,%a2@+
    lea %pc@(INTHND),%a0
    cmpib #0,0xcb3
    jbne GOTSLOTHANDLER_78
    lea %pc@(SCCIOPBYPASSINT_100),%a0
GOTSLOTHANDLER_78:      /* level 7 (NMI: debugger on most machines) */
    movel %a0,%a2@+
GOTSLOTHANDLER_7A:      /* return (also the "no handler" entry) */
    rts

/* DISABLEINTSOURCES: disable all VIA 1, VIA 2/RBV and OSS interrupt sources. */
DISABLEINTSOURCES:
    moveal VIA,%a0
    moveb #127,%a0@(7168)
    moveal ghost_VIA2,%a0
    btst #3,0xdd2
    jbne DISABLEINTSOURCES_1E
    btst #5,0xdd2
    jbeq DISABLEINTSOURCES_24
DISABLEINTSOURCES_1E:   /* VIA 2 or RBV */
    moveb #127,%a0@(7187)
DISABLEINTSOURCES_24:   /* OSS: all levels 0 */
    btst #2,0xdd1
    jbeq DISABLEINTSOURCES_4C
    moveal ghost_VIA2,%a0
    lea %a0@(0:w),%a0	| 40809F7C
    moveq #14,%d0
DISABLEINTSOURCES_36:   /* clear */
    clrb %a0@+
    dbf %d0,DISABLEINTSOURCES_36
    moveal ghost_VIA2,%a0
    moveb #1,%a0@(11)
    moveb #4,%a0@(7)
DISABLEINTSOURCES_4C:   /* return */
    rts

/* ENABLE60HZINTS: enable the 60 Hz interrupt (VIA 1 CA1, or the OSS). */
ENABLE60HZINTS:
    btst #2,0xdd1
    jbeq ENABLE60HZINTS_14
    moveal ghost_VIA2,%a0
    moveb #1,%a0@(10)
    rts
ENABLE60HZINTS_14:      /* VIA 1 */
    moveal VIA,%a0
    moveb #0x82,%a0@(7168)
    rts
    .short  0x0000, 0x0000, 0x0000	| 40809FBA
ENABLE60HZINTS_26:      /* result 9 */
    moveq #9,%d0
    jmp %pc@(RUNSLOTHANDLERS)

/* ENABLESLOTINTS: enable the slot interrupts (VIA 2 CA1 or the OSS slot levels). */
ENABLESLOTINTS:
    btst #2,0xdd1
    jbeq ENABLESLOTINTS_1C
    moveal ghost_VIA2,%a0
    lea %a0@(0:w),%a0	| 40809FD2
    moveq #5,%d0
ENABLESLOTINTS_12:      /* OSS levels */
    moveb #2,%a0@+
    dbf %d0,ENABLESLOTINTS_12
    rts
ENABLESLOTINTS_1C:      /* VIA 2 */
    moveal ghost_VIA2,%a0
    moveb #0x82,%a0@(7187)
    rts

/* ENABLESWIMIOPINTS: enable the SWIM IOP interrupt. */
ENABLESWIMIOPINTS:
    btst #2,0xdd1
    jbeq ENABLESWIMIOPINTS_14
    moveal ghost_VIA2,%a0
    moveb #1,%a0@(6)
ENABLESWIMIOPINTS_12:   /* return */
    rts
ENABLESWIMIOPINTS_14:   /* VIA 2 */
    moveal ghost_VIA2,%a0
    moveb #0x81,%a0@(7187)
    rts

/*
 ENABLEASCINTS / DISABLEASCINTS / CLEARASCINT: the sound chip interrupt (VIA 2 CB1 or
 the OSS).
*/
ENABLEASCINTS:
    btst #2,0xdd1
    jbeq ENABLEASCINTS_14
    moveal ghost_VIA2,%a0
    moveb #2,%a0@(8)
    rts
ENABLEASCINTS_14:       /* VIA 2 */
    moveal ghost_VIA2,%a0
    moveb #0x90,%a0@(7187)
    rts

DISABLEASCINTS:         /* test bit 2 of 0xdd1 */
    btst #2,0xdd1
    jbeq DISABLEASCINTS_12
    moveal ghost_VIA2,%a0
    clrb %a0@(8)
    rts
DISABLEASCINTS_12:      /* VIA 2 */
    moveal ghost_VIA2,%a0
    moveb #16,%a0@(7187)
    rts

CLEARASCINT:            /* test bit 2 of 0xdd1 */
    btst #2,0xdd1
    jbeq CLEARASCINT_A
    rts
CLEARASCINT_A:          /* VIA 2: clear the flag */
    moveal ghost_VIA2,%a0
    moveb #0x90,%a0@(6659)
    rts

/*
 ENABLESCSIINTS / DISABLESCSIINTS / CLEARSCSIINT: the SCSI interrupt (VIA 2 CB2 or the
 OSS).
*/
ENABLESCSIINTS:
    btst #2,0xdd1
    jbeq ENABLESCSIINTS_14
    moveal ghost_VIA2,%a0
    moveb #2,%a0@(9)
    rts
ENABLESCSIINTS_14:      /* VIA 2 */
    moveal ghost_VIA2,%a0
    btst #7,0xdd2
    jbeq ENABLESCSIINTS_28
    moveb #0x88,%a0@(7187)
    rts
ENABLESCSIINTS_28:      /* (parity machines) */
    jbra ENABLEPARITYINTS_14
    nop
    rts
    rts

DISABLESCSIINTS:        /* test bit 2 of 0xdd1 */
    btst #2,0xdd1
    jbeq DISABLESCSIINTS_12
    moveal ghost_VIA2,%a0
    clrb %a0@(9)
    rts
DISABLESCSIINTS_12:     /* VIA 2 */
    moveal ghost_VIA2,%a0
    btst #7,0xdd2
    jbeq DISABLESCSIINTS_26
    moveb #8,%a0@(7187)
    rts
DISABLESCSIINTS_26:     /* (same) */
    moveb #8,%a0@(7187)
    rts
    .short  0x4E75	| 4080A0C2

CLEARSCSIINT:           /* test bit 2 of 0xdd1 */
    btst #2,0xdd1
    jbeq CLEARSCSIINT_A
    rts
CLEARSCSIINT_A:         /* VIA 2 */
    moveal ghost_VIA2,%a0
    btst #7,0xdd2
    jbeq CLEARSCSIINT_1E
    moveb #0x88,%a0@(6659)
    rts
CLEARSCSIINT_1E:        /* (same) */
    moveb #0x88,%a0@(6659)
    rts
    .short  0x4E75, 0x0000, 0x0000	| 4080A0EA

/*
 _DebugUtil(d0): 0 version, others through the machine's ADB/debug primitives
 (ProductInfo +56: enter, poll, exit the debugger...). Out of range: -50.
*/
trap_DebugUtil:
DEBUGUTIL:
    lea %pc@(DEBUGUTIL_14),%a0
    cmpl %a0@+,%d0
    jbhi DEBUGUTIL_10
    addw %d0,%d0
    addaw %a0@(0x0,%d0:w),%a0
    jmp %a0@
DEBUGUTIL_10:           /* -50 */
    moveq #-50,%d0
    rts
DEBUGUTIL_14:           /* selector table (and the highest selector) */
    .byte   0x00, 0x00, 0x00, 0x03	| 4080A104
DEBUGUTIL_18:           /* (data) */
    .short  DEBUGUTIL_20-(DEBUGUTIL_14+4)	| 4080A108
    .short  DEBUGUTIL_26-(DEBUGUTIL_14+4)	| 4080A10A
    .short  DEBUGUTIL_2A-(DEBUGUTIL_14+4)	| 4080A10C
    .short  DEBUGUTIL_2E-(DEBUGUTIL_14+4)	| 4080A10E
DEBUGUTIL_20:           /* set %d0 */
    movel %pc@(DEBUGUTIL_14),%d0	| 4080A110
    rts	| 4080A114
DEBUGUTIL_26:           /* result 8 */
    moveq #8,%d0
    jbra DEBUGUTIL_30
DEBUGUTIL_2A:           /* result 12 */
    moveq #12,%d0
    jbra DEBUGUTIL_30
DEBUGUTIL_2E:           /* set %d0 */
    moveq #16,%d0	| 4080A11E
DEBUGUTIL_30:           /* call the primitive */
    moveml %d1-%d3/%a0-%a3,%sp@-
    moveal 0xdd8,%a0
    addal %a0@(56),%a0
    movel %a0@(0x0,%d0:w),%d0
    jbeq DEBUGUTIL_46
    addal %d0,%a0
    jsr %a0@
DEBUGUTIL_46:           /* return 0 */
    moveml %sp@+,%d1-%d3/%a0-%a3
    moveq #0,%d0
    rts
    .fill   0x44, 1, 0x00

/* ENABLEPARITYINTS: enable the parity error interrupt (RPU machines: OSS level 7). */
ENABLEPARITYINTS:
    btst #4,0xdd1
    jbeq ENABLEPARITYINTS_12
    moveal ghost_VIA2,%a0
    moveb #7,%a0@(14)
ENABLEPARITYINTS_12:    /* return */
    rts

ENABLEPARITYINTS_14:    /* SCSI/parity through VIA 2 (unless 0xDD5 bit 4) */
    btst #4,0xdd5
    jbne ENABLEPARITYINTS_22
    moveb #0x88,%a0@(7187)
ENABLEPARITYINTS_22:    /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4080A1A6
ENABLEPARITYINTS_2E:    /* level 3 handler */
    moveml %d0-%d3/%a0-%a3,%sp@-	| 4080A1B0
    lea %pc@(ENABLE60HZINTS_26),%a3	| 4080A1B4
    jbra INTHND_68	| 4080A1B8
    FILL_4080A1BC
