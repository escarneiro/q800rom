/*
 os/docking.s - Docking Manager
 From DOCKINGDISPATCH (0x408B73D0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. The Docking Manager
 handles the PowerBook Duo docks; it is installed only when a NuBus slot is marked
 as a docking slot. Globals (236 bytes, 0x1FF8): +0 the selector handler, +4 the dock
 slot, +5 flags, +20/+56/+96 notification records, +148 the machine's handler table
 (from DOCKING_TABLE_*: entries are offsets from the end of each entry, as
 INITDOCKING reads them). _DockingDispatch(selector, parameter): selectors are
 four-character codes ('scc#', 'powr', 'hdwr', 'boot', 'wake', 'gone', 'sltc', ...).
*/

/*
 DOCKINGDISPATCH: _DockingDispatch: the handler for the dock that is
 attached ('slot' answers the dock slot), else the built-in handler DOCKINGMGR_1E.
*/
DOCKINGMGR:
DOCKINGDISPATCH:
    moveal 0x1ff8,%a0
    moveal %a0@,%a1
    cmpil #1936486260,%sp@(8)
    bnes DOCKINGDISPATCH_1C
    moveal %sp@+,%a1
    addqw #8,%sp
    moveq #0,%d0
    moveb %a0@(4),%d0
    movel %d0,%sp@
DOCKINGDISPATCH_1C:
    jmp %a1@
DOCKINGMGR_1E:          /* built-in handler (no dock): 'scc#', 'powr' and 'hdwr' answers, others 0 */
    moveal %sp@+,%a1	| 408B73EE
    addqw #4,%sp	| 408B73F0
    moveq #0,%d0	| 408B73F2
    cmpil #1935893283,%sp@+	| 408B73F4
    jbne DOCKINGMGR_34	| 408B73FA
    moveal 0x1ff8,%a0	| 408B73FC
    movel %a0@(148),%d0	| 408B7400
DOCKINGMGR_34:          /* set %sp@ */
    movel %d0,%sp@	| 408B7404
    jmp %a1@	| 408B7406
DOCKINGMGR_38:          /* (handler table target: the built-in selectors) */
    .byte   0x22, 0x5F, 0x58, 0x4F, 0x22, 0x1F	| 408B7408
    moveq #0,%d0
    moveal 0x1ff8,%a0
    cmpil #1935893283,%d1
    jbne DOCKINGMGR_52
    movel %a0@(148),%d0
    jbra DOCKINGMGR_7A
DOCKINGMGR_52:          /* 'powr': can the dock be powered? (1 if the probe finds it) */
    cmpil #1886353266,%d1
    jbne DOCKINGMGR_62
    jbsr DOCKINGMGR_7E
    jbne DOCKINGMGR_7A
    moveq #1,%d0
    jbra DOCKINGMGR_7A
DOCKINGMGR_62:          /* 'hdwr': hardware attributes (with the dock's bits when present) */
    cmpil #1751414642,%d1
    jbne DOCKINGMGR_7A
    movel #65537,%d0
    jbsr DOCKINGMGR_7E
    jbne DOCKINGMGR_7A
    oril #1048592,%d0
DOCKINGMGR_7A:          /* return the answer */
    movel %d0,%sp@
    jmp %a1@

DOCKINGMGR_7E:          /* probe the dock's hardware: write and read back a register, a bus error means no dock. Out: Z set if present */
    movew %sr,%sp@-
    oriw #1792,%sr
    movel BusErrorVector,%sp@-
    pea %pc@(DOCKINGMGR_B0)
    movel %sp@+,BusErrorVector
    movel %sp,%d2
    moveq #-8,%d1
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveb %d1,@(IWM,%za0)@(0x800)	| 408B7464
    tstb @(ROMBase,%za0)@(4)
    cmpb @(IWM,%za0)@(0x1800),%d1
    jbne DOCKINGMGR_B0
    moveq #0,%d1
DOCKINGMGR_B0:          /* restore the bus error vector */
    moveal %d2,%sp
    movel %sp@+,BusErrorVector
    movew %sp@+,%sr
    tstl %d1
    rts

/*
 INITDOCKING: find the docking slot (NuBus slot info bit 6), allocate the globals,
 install the VBL task and the three notifications, pick the handler table for the
 machine kind (DOCKING_TABLE_*), and initialise. No docking slot: _DockingDispatch
 is made unimplemented.
*/
INITDOCKING:
    moveml %d0-%d2/%a0-%a2,%sp@-
    moveal 0xdd8,%a1
    addal %a1@(12),%a1
    moveq #15,%d1
INITDOCKING_E:          /* find the slot */
    btst #6,%a1@+
    dbne %d1,INITDOCKING_E
    jbeq INITDOCKING_AE
    subiw #15,%d1
    negw %d1
    moveq #118,%d0
    addl %d0,%d0
    .short  0xA71E	| 408B74B0 _NewPtr (flags 0x0700)
    jbne INITDOCKING_AE
    movel %a0,0x1ff8
    moveal %a0,%a2
    lea %pc@(DOCKINGMGR_1E),%a1
    movel %a1,%a0@+
    moveb %d1,%a0@+
    lea %a2@(18),%a0
    movew #120,%a0@-
    lea %pc@(DOCKINGWAKEUPDENIED_66),%a1
    movel %a1,%a0@-
    addqw #1,%a0@-
    subqw #4,%a0
    _VInstall
    lea %a2@(20),%a0
    lea %pc@(DOCKINGWAKEUPDENIED_48),%a1
    jbsr INITDOCKING_9E
    lea %a2@(56),%a0
    lea %pc@(DOCKINGWAKEUPDENIED_36),%a1
    jbsr INITDOCKING_9E
    lea %a2@(96),%a0
    lea %pc@(DOCKINGWAKEUPDENIED_5A),%a1
    jbsr INITDOCKING_9E
    moveal 0xdd8,%a1
    moveb %a1@(19),%d0
    lea %pc@(GRACEFULSHUTDOWN_10A),%a1
INITDOCKING_76:         /* find the machine's table */
    addqw #4,%a1
    movew %a1@+,%d1
    jbmi INITDOCKING_80
    cmpb %d0,%d1
    jbne INITDOCKING_76
INITDOCKING_80:         /* copy the header and resolve the entries */
    addal %a1@,%a1
    lea %a2@(148),%a0
    movel %a1@+,%a0@+
INITDOCKING_88:         /* next entry: address = entry end + offset */
    movel %a1@+,%d1
    jbeq INITDOCKING_92
    addl %a1,%d1
    movel %d1,%a0@+
    jbra INITDOCKING_88
INITDOCKING_92:         /* initialise (handler selector 168) */
    moveq #0,%d1
    jbsr DOCKINITSCC_54
INITDOCKING_98:         /* return */
    moveml %sp@+,%d0-%d2/%a0-%a2
    rts
INITDOCKING_9E:         /* set up a notification record (string, response routine) */
    addqw #8,%a0@(4)
    moveq #-1,%d0
    movel %d0,%a0@(20)
    movel %a1,%a0@(28)
    rts
INITDOCKING_AE:         /* no dock support: _DockingDispatch unimplemented */
    movew #-22369,%d0
    .short  0xA746	| 408B753E _GetTrapAddress (flags 0x0700)
    movew %pc@(DOCKINITSCC_CE),%d0
    .short  0xA647	| 408B7544 _SetTrapAddress (flags 0x0600)
    jbra INITDOCKING_98

/*
 SETUPDOCKBASES: after a dock is attached: its hardware bases ('hdwr'), the SCC and
 SCSI bases from the dock, and 'boot'.
*/
SETUPDOCKBASES:
    jbsr SETUPDOCKBASES_2A
    jbeq DOCKINGWAKEUP_16E
    movel %a2,%sp@-
    moveal 0x1ff8,%a2
    jbsr DOCKINITSCC_9E
    moveal %sp@+,%a2
    movel #1751414642,%d0
    jbsr DOCKINITSCC_C6
    jbsr DOCKINGWAKEUP_E8
    movel #1651470196,%d0
    jbra DOCKINITSCC_C6

SETUPDOCKBASES_2A:      /* is _DockingDispatch implemented? (Z set if not) */
    movew #-22369,%d0
    .short  0xA746	| 408B7576 _GetTrapAddress (flags 0x0700)
    moveal %a0,%a1
    movew %pc@(DOCKINITSCC_CE),%d0
    .short  0xA746	| 408B757E _GetTrapAddress (flags 0x0700)
    cmpal %a0,%a1
    rts

/* DOCKINGSLEEP (raw words): the dock handler's sleep ('slep'). */
DOCKINGSLEEP:
    .short  0x2F30, 0x81E2, 0x1FF8	| 408B7584
DOCKINGSLEEP_6:         /* (raw words) */
    .byte   0x00, 0xA0, 0x4E, 0x75	| 408B758A
DOCKINGSLEEP_A:         /* (handler table target) */
    .byte   0x2F, 0x09	| 408B758E
    movel #1936483696,%d0
    bsrw DOCKINITSCC_C6
    movel %d0,@(0x1ff8,%za0)@(0x5c)	| 408B759A
    moveal %sp@+,%a1
    jmp %a1@

/* DOCKINGWAKEUP (raw words): wake. */
DOCKINGWAKEUP:
    .short  0x2F30	| 408B75A6
DOCKINGWAKEUP_2:        /* (raw words) */
    divsw %a2@-,%d0
    .short  0x1FF8	| .short 0x1ff8
    .short  0x00A4, 0x4E75	| 408B75AC

DOCKINGWAKEUP_A:        /* wake up: if the dock changed, tell the old one 'gone' and reconnect: close the slot drivers, reinitialise the slots, open the new drivers and video */
    moveml %d3-%d4/%a1-%a2,%sp@-
    moveal 0x1ff8,%a2
    bclr #1,%a2@(5)
    jbne DOCKINGWAKEUP_4A
    jbsr DOCKINITSCC_3E
    jbeq DOCKINGWAKEUP_4A
    jbsr DOCKINITSCC_108
    jbne DOCKINGWAKEUP_4A
    movel #2002873189,%d0
    moveal %a2@(92),%a0
    jbsr DOCKINITSCC_C8
    clrl %a2@(92)
    movel #1751414642,%d0
    jbsr DOCKINITSCC_C6
    jbsr DOCKINGWAKEUP_E8
    jbra DOCKINGWAKEUP_CC
DOCKINGWAKEUP_4A:       /* dock gone or changed */
    jbsr DOCKINGWAKEUP_D2
    movel #1735356005,%d0
    jbsr DOCKINITSCC_C6
    movel %a2@(92),%d0
    jbeq DOCKINGWAKEUP_66
    moveal %d0,%a0
    _DisposPtr
    clrl %a2@(92)
DOCKINGWAKEUP_66:       /* close the drivers of each dock slot */
    moveq #15,%d1
DOCKINGWAKEUP_68:       /* (slot d1) */
    btst %d1,%d3
    jbeq DOCKINGWAKEUP_74
    jbsr DOCKINITSCC_2E6
    jbsr DOCKINITSCC_13E
DOCKINGWAKEUP_74:       /* next slot */
    dbf %d1,DOCKINGWAKEUP_68
    moveb %a2@(4),%d1
    jbsr DOCKINITSCC_124
    bset #0,%a2@(5)
    moveq #1,%d1
    jbsr DOCKINITSCC_54
    btst #1,%d0
    jbne DOCKINGWAKEUP_CC
    movel #1751414642,%d0
    jbsr DOCKINITSCC_C6
    swap %d0
    movew %d0,%d4
    tstb %d4
    jbpl DOCKINGWAKEUP_C4
    jbsr DOCKINGWAKEUP_D2
    moveq #15,%d1
DOCKINGWAKEUP_A8:       /* open the slots again (and the video) */
    btst %d1,%d3
    jbeq DOCKINGWAKEUP_C0
    cmpb %a2@(4),%d1
    jbeq DOCKINGWAKEUP_B6
    jbsr DOCKINITSCC_124
DOCKINGWAKEUP_B6:       /* (video slot) */
    jbsr DOCKINITSCC_1A8
    jbeq DOCKINGWAKEUP_C0
    jbsr DOCKINITSCC_2DE
DOCKINGWAKEUP_C0:       /* next */
    dbf %d1,DOCKINGWAKEUP_A8
DOCKINGWAKEUP_C4:       /* answer */
    movew %d4,%d0
DOCKINGWAKEUP_C6:       /* hardware bases, done */
    jbsr DOCKINGWAKEUP_E8
    jbsr DOCKINITSCC_2EE
DOCKINGWAKEUP_CC:       /* return through a1 */
    moveml %sp@+,%d3-%d4/%a1-%a2
    jmp %a1@

DOCKINGWAKEUP_D2:       /* the dock's slots ('sltc'), with the dock slot itself */
    movel #1936487523,%d0
    jbsr DOCKINITSCC_C6
    movel %d0,%d3
    moveq #0,%d0
DOCKINGWAKEUP_E0:       /* (bit for the dock slot) */
    moveb %a2@(4),%d0
    bset %d0,%d3
    rts

DOCKINGWAKEUP_E8:       /* handler +0xAC */
    movel @(0x1ff8,%za0)@(0xac),%sp@-	| 408B768E
    rts

DOCKINGWAKEUP_F2:       /* SCC and SCSI bases from the dock ('scc#'...) */
    moveml %a2-%a4,%sp@-
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveml %a0@(12),%a0-%a1
    moveml %a0-%a1,SCCRd
    btst #5,%d0
    jbeq DOCKINGWAKEUP_132
    movel #1935893362,%d0
    jbsr DOCKINITSCC_C6
    jbeq DOCKINGWAKEUP_132
    moveal %d0,%a3
    movel #1935893367,%d0
    jbsr DOCKINITSCC_C6
    jbeq DOCKINGWAKEUP_132
    moveal %d0,%a4
    jbsr DOCKINITSCC
    moveml %a3-%a4,SCCRd
DOCKINGWAKEUP_132:      /* reset the SCC, then the SCSI bases ('scsi', 'sdma', 'shsk') */
    jbsr DOCKINITSCC
    moveal SCSIGlobals,%a2
    movel #1935897449,%d0
    jbsr DOCKINITSCC_C6
DOCKINGWAKEUP_142:      /* (external SCSI bus) */
    movel %d0,%a2@(280)
    jbne DOCKINGWAKEUP_14A
    moveq #-1,%d0
DOCKINGWAKEUP_14A:      /* (none: -1) */
    movel %d0,0x1ff0
    movel #1935961441,%d0
    jbsr DOCKINITSCC_C6
    movel %d0,%a2@(284)
    movel #1936225131,%d0
    jbsr DOCKINITSCC_C6
    movel %d0,%a2@(288)
    moveml %sp@+,%a2-%a4
DOCKINGWAKEUP_16E:      /* return */
    rts

/*
 DOCKINITSCC: reset the SCC after the dock changed: SCC power off and on through the
 Power Manager (PowerBooks), INITSCC.
*/
DOCKINITSCC:
    moveml %d0-%d2/%a0-%a2,%sp@-
    jbsr SETUPDOCKBASES_2A
    jbeq DOCKINITSCC_18
    moveq #-126,%d0
    jbsr DOCKINITSCC_1E
    jbsr INITSCC
DOCKINITSCC_14:         /* power on */
    moveq #2,%d0
    jbsr DOCKINITSCC_1E
DOCKINITSCC_18:         /* return */
    moveml %sp@+,%d0-%d2/%a0-%a2
    rts

DOCKINITSCC_1E:         /* Power Manager command 0x10 with d0 (SCC power) */
    btst #0,HWCfgFlags
    jbeq DOCKINITSCC_3C
    moveb %d0,%sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #1,%sp@-
    movew #16,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(14),%sp
DOCKINITSCC_3C:         /* return */
    rts

DOCKINITSCC_3E:         /* handler +176 */
    movel %a2@(176),%sp@-
    rts
DOCKINITSCC_44:         /* (handler table target) */
    moveq #0,%d0
    rts
    movel %a2@(196),%sp@-
    rts
DOCKINITSCC_4E:         /* (handler table target) */
    movel %a2@(200),%sp@-
    rts

DOCKINITSCC_54:         /* handler +168 */
    movel %a2@(168),%sp@-
    rts
DOCKINITSCC_5A:         /* (handler table target) */
    .long   0x226A0098, 0x61E861DC, 0x670C61E8, 0x610000F0	| 408B7770
    .long   0x6704226A, 0x009C2052, 0x2489B1EA, 0x00986708	| 408B7780
    .long   0xB1EA009C, 0x6702A01F, 0x203C696E, 0x69742041	| 408B7790
    .long   0x613C7007, 0xA09F48C0, 0x6B0A2040, 0x203C6D68	| 408B77A0
    moveq #32,%d5
    jbsr DOCKINITSCC_C8

DOCKINITSCC_9E:         /* 'dock' attributes, Power Manager flag */
    movel #1685021547,%d0
    jbsr DOCKINITSCC_C6
    btst #0,%a2@(5)
    jbne DOCKINITSCC_B2
    bclr #1,%d0
DOCKINITSCC_B2:         /* (handler +228) */
    jbsr DOCKINITSCC_D4
    btst #0,HWCfgFlags
    jbeq DOCKINITSCC_C4
    moveal PmgrBase,%a1
    moveb %d0,%a1@(249)
DOCKINITSCC_C4:         /* return */
    rts

DOCKINITSCC_C6:         /* _DockingDispatch(selector d0, nil). Out: d0 */
    subal %a0,%a0

DOCKINITSCC_C8:         /* _DockingDispatch(selector d0, parameter a0) */
    subqw #4,%sp
    movel %d0,%sp@-
    movel %a0,%sp@-
DOCKINITSCC_CE:         /* the trap */
    _DockingDispatch
    movel %sp@+,%d0
DOCKINITSCC_D2:         /* return */
    rts

DOCKINITSCC_D4:         /* handler +228 */
    movel %a2@(228),%sp@-
    rts
DOCKINITSCC_DA:         /* (handler table target) */
    .long   0x2F00203C, 0x68647772, 0x61E22200, 0x201F082A	| 408B77F0
    .long   0x00000005, 0x670C4841	| 408B7800
DOCKINITSCC_F2:         /* (handler table target) */
    btst #3,%d0
    beqs DOCKINITSCC_F2_A
    bset #1,%d0
DOCKINITSCC_F2_A:
    andiw #136,%d1
    beqs DOCKINITSCC_F2_14
    bset #0,%d0
DOCKINITSCC_F2_14:
    rts

DOCKINITSCC_108:        /* handler +180 */
    movel %a2@(180),%sp@-
    rts

DOCKINITSCC_10E:        /* Slot Manager 39 for the dock slot (handler table target) */
    lea %sp@(-56),%sp
    moveal %sp,%a0
    moveb %a2@(4),%a0@(49)
    moveq #39,%d0	/* _SlotManager 39: CHECKSLOT */
    _SlotManager
    lea %sp@(56),%sp
    rts

DOCKINITSCC_124:        /* handler +184 */
    movel %a2@(184),%sp@-
    rts

DOCKINITSCC_12A:        /* Slot Manager 30 for slot d1 (handler table target) */
    lea %sp@(-56),%sp
    moveal %sp,%a0
    moveb %d1,%a0@(49)
    moveq #30,%d0	/* _SlotManager 30: ADDCARD */
    _SlotManager
    lea %sp@(56),%sp
    rts

DOCKINITSCC_13E:        /* handler +188 */
    movel %a2@(188),%sp@-
    rts

DOCKINITSCC_144:        /* Slot Manager 31 for slot d1 (handler table target) */
    lea %sp@(-56),%sp
    moveal %sp,%a0
    moveb %d1,%a0@(49)
    moveq #31,%d0	/* _SlotManager 31: REMOVECARD */
    _SlotManager
    lea %sp@(56),%sp
    rts
    movel %a2@(192),%sp@-
    rts

DOCKINITSCC_15E:        /* the dock's sResource (category 32): its block ID 80 (handler table target) */
    lea %sp@(-56),%sp
    moveal %sp,%a0
    movew #32,%a0@(40)
    clrw %a0@(42)
    clrw %a0@(44)
    clrw %a0@(46)
    moveb #7,%a0@(48)
DOCKINITSCC_17C:        /* (search) */
    moveb %a2@(4),%a0@(49)
    clrb %a0@(50)
    clrb %a0@(51)
    clrw %a0@(52)
    moveq #21,%d0	/* _SlotManager 21: NEXTTYPESRSRC, sNextTypesRsrc */
    _SlotManager
    jbne DOCKINITSCC_1A2
    moveb #80,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    jbne DOCKINITSCC_1A2
    moveal %a0@,%a1
DOCKINITSCC_1A2:        /* return */
    lea %sp@(56),%sp
    rts

DOCKINITSCC_1A8:        /* handler +204 */
    movel %a2@(204),%sp@-
    rts

DOCKINITSCC_1AE:        /* open the video of slot d1 and add its gDevice to the right of the others (handler table target) */
    moveml %d1/%d3/%a2-%a3,%sp@-
    clrw %sp@-
    linkw %fp,#-336
    moveal %sp,%a0
    moveq #2,%d0
    movel %d0,%a0@(24)
    movew #3,%a0@(40)
    movew #1,%a0@(42)
    movew #1,%a0@(44)
    clrw %a0@(46)
    moveb #1,%a0@(48)
    moveb %d1,%a0@(49)
    clrb %a0@(50)
    clrb %a0@(51)
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */
    _SlotManager
    jbne DOCKINITSCC_2D4
    moveal %a0@(4),%a2
    lea %fp@(-256),%a1
    movel %a1,%a0@
    moveq #25,%d0	/* _SlotManager 25: READSLOTDRVRNAME, sReadDrvrName */
    _SlotManager
    jbne DOCKINITSCC_2D4
    movew %a0@(49),%fp@(-280)
    movel %a1,%fp@(-268)
    moveb %a0@(51),%fp@(-264)
    lea %sp@(-50),%sp
    movel %a0@,%sp@(18)
    clrb %sp@(27)
    clrl %sp@(28)
    moveq #1,%d0
    movew %d0,%sp@(32)
    lea %fp@(-280),%a1
    movel %a1,%sp@(34)
    moveal %a0,%a1
    moveal %sp,%a0
    .short  0xA200	| 408B794A _Open (flags 0x0200)
    moveq #0,%d3
    movew %a0@(24),%d3
    moveal %a1,%sp
    moveal %a1,%a0
    lea %sp@(-8),%sp
    movel %sp,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    moveq #0,%d0
    moveb %sp@(2),%d0
    lea %sp@(8),%sp
    movel %d0,%sp@-
    moveb #7,%a0@(50)
    movel %a2,%a0@(4)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    jbne DOCKINITSCC_270
    moveq #4,%d0
    andl %a0@,%d0
    jbeq DOCKINITSCC_270
    bset #31,%d3
DOCKINITSCC_270:        /* NewGDevice */
    movel %sp@+,%d0
    subqw #4,%sp
    movew %d3,%sp@-
    movel %d0,%sp@-
    _NewGDevice
    movel %sp@+,%d0
    jbeq DOCKINITSCC_2D4
    moveal %d0,%a3
    lea 0x88a,%a0
    moveq #0,%d1
    jbra DOCKINITSCC_296
DOCKINITSCC_288:        /* find the rightmost device */
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %a0@(40),%d0
    cmpw %d0,%d1
    jbge DOCKINITSCC_296
    movew %d0,%d1
DOCKINITSCC_296:        /* next device */
    movel %a0@(30),%d0
    jbne DOCKINITSCC_288
    movel %a3,%a0@(30)
    moveal %a3@,%a0
    bset #5,%a0@(20)
    tstl %d3
    jbpl DOCKINITSCC_2B2
DOCKINITSCC_2AC:        /* (main screen flag) */
    bset #0,%a0@(20)
DOCKINITSCC_2B2:        /* move it right of the others, default gamma */
    pea %a0@(34)
    movel %d1,%sp@-
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    pea %a0@(6)
    movel %d1,%sp@-
    _OffsetRect
    _OffsetRect
    moveal %a3,%a0
    jbsr INITDEFGAMMA
    movew %d3,%fp@(4)
DOCKINITSCC_2D4:        /* return */
    unlk %fp
    movew %sp@+,%d0
    moveml %sp@+,%d1/%d3/%a2-%a3
    rts

DOCKINITSCC_2DE:        /* handler +208 */
    movel %a2@(208),%sp@-
    rts
DOCKINITSCC_2E4:        /* (handler table target) */
    .short  0x4E75	| 408B79FA

DOCKINITSCC_2E6:        /* handler +212 */
    movel %a2@(212),%sp@-
    rts
DOCKINITSCC_2EC:        /* (handler table target) */
    .short  0x4E75	| 408B7A02

DOCKINITSCC_2EE:        /* handler +216 */
    movel %a2@(216),%sp@-
    rts
DOCKINITSCC_2F4:        /* (handler table target) */
    movew #-32512,%sp@-
    movew #1320,%sp@-
    moveal %sp,%a0
    .short  0xA08B	| 408B7A14 _CommToolboxDispatch (flags 0x0000)
    addqw #4,%sp
    movew #-32511,%sp@-
    movew #1320,%sp@-
    moveal %sp,%a0
    .short  0xA08B	| 408B7A22 _CommToolboxDispatch (flags 0x0000)
    addqw #4,%sp
    movew #-32512,%sp@-
    movew #1319,%sp@-
    moveal %sp,%a0
    .short  0xA08B	| 408B7A30 _CommToolboxDispatch (flags 0x0000)
    addqw #4,%sp
    movew #-32511,%sp@-
    movew #1319,%sp@-
    moveal %sp,%a0
    .short  0xA08B	| 408B7A3E _CommToolboxDispatch (flags 0x0000)
    addqw #4,%sp
    rts

/* DOCKINGSLEEPDENIED: sleep refused by the dock: post the notification. */
DOCKINGSLEEPDENIED:
    movel @(0x1ff8,%za0)@(0xdc),%sp@-	| 408B7A44
    rts

DOCKINGSLEEPDENIED_A:   /* post the "cannot sleep" notification */
    moveml %d0-%d2/%a0-%a1,%sp@-
    jbsr SETUPDOCKBASES_2A
    jbeq DOCKINGSLEEPDENIED_20
    moveal 0x1ff8,%a0
    lea %a0@(56),%a0
    jbsr DOCKINGWAKEUPDENIED_F2
DOCKINGSLEEPDENIED_20:  /* return */
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts

/* DOCKINGWAKEUPDENIED: wake-up refused ('ejct'... notification). */
DOCKINGWAKEUPDENIED:
    .byte   0x2F, 0x30, 0x81, 0xE2, 0x1F, 0xF8	| 408B7A6A
DOCKINGWAKEUPDENIED_6:  /* (handler table entry) */
    .byte   0x00, 0xE0	| 408B7A70
    rts	| 408B7A72

DOCKINGWAKEUPDENIED_A:  /* post the notification, flag it */
    moveml %d0-%d2/%a0-%a1,%sp@-
    jbsr SETUPDOCKBASES_2A
    jbeq DOCKINGWAKEUPDENIED_30
    movel #1701471092,%d0
    jbsr DOCKINITSCC_C6
    moveal 0x1ff8,%a0
    bset #1,%a0@(5)
    lea %a0@(96),%a0
    jbsr DOCKINGWAKEUPDENIED_F2
DOCKINGWAKEUPDENIED_30:  /* return */
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts
DOCKINGWAKEUPDENIED_36:  /* notification response routines */
    moveal PmgrBase,%a1	| 408B7AA0
    bclr #0,%a1@(84)	| 408B7AA4
    bclr #6,%a1@(84)	| 408B7AAA
    jbra DOCKINGWAKEUPDENIED_5A	| 408B7AB0
DOCKINGWAKEUPDENIED_48:  /* (response routine) */
    moveal 0x1ff8,%a1	| 408B7AB2
    clrb %a1@(53)	| 408B7AB6
    movel #1701475191,%d0	| 408B7ABA
    jbsr DOCKINITSCC_C6	| 408B7AC0
DOCKINGWAKEUPDENIED_5A:  /* (response routine) */
    moveal %sp@+,%a1	| 408B7AC4
    moveal %sp@+,%a0	| 408B7AC6
    clrb %a0@(32)	| 408B7AC8
    _NMRemove	| 408B7ACC
    jmp %a1@	| 408B7ACE
DOCKINGWAKEUPDENIED_66:  /* VBL task (raw bytes) */
    .long   0x2F08303C, 0xA89FA746, 0x2248303C, 0xABF7A746	| 408B7AD0
    .long   0xB3C8671A, 0x24781FF8, 0x2548008C, 0x41FA0084	| 408B7AE0
    .long   0x303CABF7, 0xA64743FA, 0x00082549, 0x000C205F	| 408B7AF0
    .long   0x317C0078, 0x000A2278, 0x0D184A29, 0x000C6760	| 408B7B00
    .long   0x24781FF8, 0x4A2A0035, 0x6B56203C, 0x656A7377	| 408B7B10
    .byte   0x61, 0x00, 0xFC, 0xBA, 0x08, 0x00, 0x00, 0x01, 0x67, 0x46, 0x08, 0xEA, 0x00, 0x07, 0x00	| 408B7B20
    .ascii  "5 <locka\000"
    .short  0xFCA4	| 408B7B38
    btst #1,%d0
    bnes DOCKINGWAKEUPDENIED_66_88
    movel #1701471092,%d0
    bsrw DOCKINITSCC_C6
    tstl %a2@(140)
    bnes DOCKINGWAKEUPDENIED_106
    movew #1,%sp@-
    _ShutDown
DOCKINGWAKEUPDENIED_66_86:
    bras DOCKINGWAKEUPDENIED_66_86
DOCKINGWAKEUPDENIED_66_88:
    lea %a2@(20),%a0

DOCKINGWAKEUPDENIED_F2:  /* post the notification at a0 once */
    tstb %a0@(32)
    jbne DOCKINGWAKEUPDENIED_106
    tstl %a0@(24)
    jbeq DOCKINGWAKEUPDENIED_106
    _NMInstall
    seq %d0
    moveb %d0,%a0@(32)
DOCKINGWAKEUPDENIED_106:  /* return */
    rts
    moveal 0x1ff8,%a1
    tstb %a1@(53)
    jbpl DOCKINGWAKEUPDENIED_140
    tstb %a1@(52)
    jbne DOCKINGWAKEUPDENIED_140
    bset #6,%a1@(53)
    jbne DOCKINGWAKEUPDENIED_140
    moveal %a1@(232),%a0
    jsr %a0@
    jbeq DOCKINGWAKEUPDENIED_140
    bclr #6,%a1@(53)
    tstw %d0
    jbgt DOCKINGWAKEUPDENIED_140
    lea %a1@(20),%a0
    jbsr DOCKINGWAKEUPDENIED_F2
    jbne DOCKINGWAKEUPDENIED_140
DOCKINGWAKEUPDENIED_13A:  /* (flag cleared) */
    bclr #7,%a1@(53)
DOCKINGWAKEUPDENIED_140:  /* continue through the handler (+140) */
    moveal %a1@(140),%a0
    jmp %a0@

/* GRACEFULSHUTDOWN: shut down because the dock asks for it. */
GRACEFULSHUTDOWN:
    moveml %d1-%d2/%a0-%a2,%sp@-
    movew #-22369,%d0
    .short  0xA746	| 408B7BB8 _GetTrapAddress (flags 0x0700)
    moveal %a0,%a1
    movew #-22385,%d0
    .short  0xA746	| 408B7BC0 _GetTrapAddress (flags 0x0700)
    cmpal %a0,%a1
    beqw GRACEFULSHUTDOWN_EC_8
    movew %pc@(GRACEFULSHUTDOWN_2A),%d0
    .short  0xA346	| 408B7BCC _GetTrapAddress (flags 0x0300)
    cmpal %a0,%a1
    beqw GRACEFULSHUTDOWN_EC_8
    movel #1702260340,%d0
GRACEFULSHUTDOWN_2A:
    .short  0xA1AD	| 408B7BDA _Gestalt (flags 0x0100)
    movel %a0,%d0
    btst #0,%d0
    beqw GRACEFULSHUTDOWN_EC_8
    linkw %fp,#-60
    moveq #60,%d0
    movel %d0,%sp@
    clrl %sp@(4)
    clrl %sp@(8)
    clrl %sp@(12)
    clrl %sp@(56)
    moveal %sp,%a2
    subqw #2,%sp
GRACEFULSHUTDOWN_52:
    pea %a2@(8)
    movew #56,%sp@-
    _OSDispatch
    movew %sp@,%d0
    bnew GRACEFULSHUTDOWN_EC
    pea %a2@(8)
    movel %a2,%sp@-
    movew #58,%sp@-
    _OSDispatch
    movew %sp@,%d0
    bnes GRACEFULSHUTDOWN_EC
    cmpil #1179534418,%a2@(16)
    bnes GRACEFULSHUTDOWN_52
    lea %sp@(-10),%sp
    pea %sp@(2)
    pea 0xffffffff	| 408B7C34
    movew #57,%sp@-
    _OSDispatch
    tstw %sp@+
    bnes GRACEFULSHUTDOWN_EC_8
    clrl %sp@-
    pea %a2@(8)
    pea %sp@(8)
    pea %sp@(10)
    movew #61,%sp@-
    _OSDispatch
    tstw %sp@+
    bnes GRACEFULSHUTDOWN_EC_8
    tstb %sp@+
    lea %sp@(8),%sp
    bnes GRACEFULSHUTDOWN_C4
    pea %a2@(8)
    movew #59,%sp@-
    _OSDispatch
    movew %sp@,%d0
    bnes GRACEFULSHUTDOWN_EC
    moveq #1,%d0
    jbra GRACEFULSHUTDOWN_EC
GRACEFULSHUTDOWN_C4:    /* _OSDispatch 64; PostHighLevelEvent (selector 52, posting option 0x8000, receiver at a2+8); _OSDispatch 65 */
    movew #64,%sp@-	| 408B7C74
    _OSDispatch
    pea %pc@(GRACEFULSHUTDOWN_EC_8_8)
    pea %a2@(8)
    clrl %sp@-
    clrl %sp@-
    clrl %sp@-
    movel #32768,%sp@-
    movew #52,%sp@-
    _OSDispatch
    movew #65,%sp@-
    _OSDispatch
    moveq #0,%d0
GRACEFULSHUTDOWN_EC:    /* return */
    unlk %fp
    moveml %sp@+,%d1-%d2/%a0-%a2
    rts
GRACEFULSHUTDOWN_EC_8:
    movew #1,%sp@-	| 408B7CA4
    _ShutDown
GRACEFULSHUTDOWN_EC_8_6:
    bras GRACEFULSHUTDOWN_EC_8_6	| 408B7CAA
GRACEFULSHUTDOWN_EC_8_8:
    .byte   0x00, 0x00, 0x46, 0x4E, 0x44, 0x52, 0x00, 0x00, 0x00, 0x00, 0x73, 0x68, 0x75, 0x74	| 408B7CAC
GRACEFULSHUTDOWN_10A:   /* machine kind -> handler table list (kind, offset), -1 = default */
    .byte   0x42, 0x78, 0x00, 0x00, 0x00, 0x0A, 0x00, 0x00, 0x00, 0xA8, 0x00, 0x0C, 0x00, 0x00, 0x01, 0x3C	| 408B7CBA
    .byte   0xFF, 0xFF, 0x00, 0x00, 0x00, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408B7CCA
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408B7CDA
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408B7CEA
    .byte   0x00, 0x00	| 408B7CFA
GRACEFULSHUTDOWN_14C:   /* (raw data) */
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408B7CFC
DOCKING_TABLE_DEFAULT:  /* handler table for other machines */
    .byte   0x00, 0x00, 0x00, 0x03	| 408B7D0C
    .long   DOCKINGMGR_1E-.-4	/* 408B7D10 routine offset from the next entry */
    .long   DOCKINGMGR_38-.-4	/* 408B7D14 routine offset from the next entry */
    .long   DOCKINGSLEEP_A-.-4	/* 408B7D18 routine offset from the next entry */
    .long   DOCKINGWAKEUP_A-.-4	/* 408B7D1C routine offset from the next entry */
    .long   DOCKINITSCC_5A-.-4	/* 408B7D20 routine offset from the next entry */
    .long   DOCKINGWAKEUP_F2-.-4	/* 408B7D24 routine offset from the next entry */
    .long   DOCKINITSCC_44-.-4	/* 408B7D28 routine offset from the next entry */
    .long   DOCKINITSCC_10E-.-4	/* 408B7D2C routine offset from the next entry */
    .long   DOCKINITSCC_12A-.-4	/* 408B7D30 routine offset from the next entry */
    .long   DOCKINITSCC_144-.-4	/* 408B7D34 routine offset from the next entry */
    .long   DOCKINITSCC_15E-.-4	/* 408B7D38 routine offset from the next entry */
    .long   DOCKINGWAKEUP_16E-.-4	/* 408B7D3C routine offset from the next entry */
    .long   DOCKINGWAKEUP_16E-.-4	/* 408B7D40 routine offset from the next entry */
    .long   DOCKINITSCC_1AE-.-4	/* 408B7D44 routine offset from the next entry */
    .long   DOCKINITSCC_2E4-.-4	/* 408B7D48 routine offset from the next entry */
    .long   DOCKINITSCC_2EC-.-4	/* 408B7D4C routine offset from the next entry */
    .long   DOCKINITSCC_2F4-.-4	/* 408B7D50 routine offset from the next entry */
    .long   DOCKINGSLEEPDENIED_A-.-4	/* 408B7D54 routine offset from the next entry */
GRACEFULSHUTDOWN_1A8:   /* (inside the table) */
    .long   DOCKINGWAKEUPDENIED_A-.-4	/* 408B7D58 routine offset from the next entry */
    .long   DOCKINITSCC_DA-.-4	/* 408B7D5C routine offset from the next entry */
    .long   GRACEFULSHUTDOWN-.-4	/* 408B7D60 routine offset from the next entry */
    .long   0	/* 408B7D64 end of the table */
DOCKING_TABLE_KIND10:   /* handler table for machine kind 10 */
    .long   0x00000001	/* 408B7D68 header (copied to the globals +148) */
    .long   DOCKINGMGR_1E-.-4	/* 408B7D6C routine offset from the next entry */
    .long   DOCKINGMGR_38-.-4	/* 408B7D70 routine offset from the next entry */
    .long   DOCKINGSLEEP_A-.-4	/* 408B7D74 routine offset from the next entry */
    .long   DOCKINGWAKEUP_A-.-4	/* 408B7D78 routine offset from the next entry */
    .long   DOCKINITSCC_5A-.-4	/* 408B7D7C routine offset from the next entry */
    .long   DOCKINGWAKEUP_F2-.-4	/* 408B7D80 routine offset from the next entry */
    .long   GRACEFULSHUTDOWN_214-.-4	/* 408B7D84 routine offset from the next entry */
    .long   DOCKINITSCC_10E-.-4	/* 408B7D88 routine offset from the next entry */
    .long   DOCKINITSCC_12A-.-4	/* 408B7D8C routine offset from the next entry */
    .long   DOCKINITSCC_144-.-4	/* 408B7D90 routine offset from the next entry */
GRACEFULSHUTDOWN_1E4:   /* (inside the table) */
    .long   DOCKINITSCC_15E-.-4	/* 408B7D94 routine offset from the next entry */
    .long   GRACEFULSHUTDOWN_22E-.-4	/* 408B7D98 routine offset from the next entry */
    .long   GRACEFULSHUTDOWN_240-.-4	/* 408B7D9C routine offset from the next entry */
    .long   DOCKINITSCC_1AE-.-4	/* 408B7DA0 routine offset from the next entry */
    .long   DOCKINITSCC_2E4-.-4	/* 408B7DA4 routine offset from the next entry */
    .long   DOCKINITSCC_2EC-.-4	/* 408B7DA8 routine offset from the next entry */
    .long   DOCKINITSCC_2F4-.-4	/* 408B7DAC routine offset from the next entry */
    .long   DOCKINGSLEEPDENIED_A-.-4	/* 408B7DB0 routine offset from the next entry */
    .long   DOCKINGWAKEUPDENIED_A-.-4	/* 408B7DB4 routine offset from the next entry */
    .long   DOCKINITSCC_DA-.-4	/* 408B7DB8 routine offset from the next entry */
    .long   GRACEFULSHUTDOWN-.-4	/* 408B7DBC routine offset from the next entry */
    .byte   0x00, 0x00, 0x00, 0x00	| 408B7DC0
GRACEFULSHUTDOWN_214:   /* code after the table: a handler */
    clrw %sp@-	| 408B7DC4
    movel %sp,%sp@-
    movel %sp@,%sp@-
    clrw %sp@-
    movew #220,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(12),%sp
    btst #1,%sp@+
    rts
GRACEFULSHUTDOWN_22E:   /* (handler) */
    .byte   0x20, 0x78, 0x0C, 0xEC	| 408B7DDE
    bclr #0,%a0@(33)
    moveb #32,%a0@(18)
    rts
GRACEFULSHUTDOWN_240:   /* (handler) */
    .long   0x20780CEC, 0x08E80000, 0x0021117C, 0x00A00012	| 408B7DF0
    .byte   0x4E, 0x75	| 408B7E00
DOCKING_TABLE_KIND12:   /* handler table for machine kind 12 */
    .long   0x00000003	/* 408B7E02 header (copied to the globals +148) */
    .long   DOCKINGMGR_1E-.-4	/* 408B7E06 routine offset from the next entry */
    .long   DOCKINGMGR_1E-.-4	/* 408B7E0A routine offset from the next entry */
GRACEFULSHUTDOWN_25E:   /* (inside the table) */
    .long   DOCKINGSLEEP_A-.-4	/* 408B7E0E routine offset from the next entry */
    .long   DOCKINGWAKEUP_A-.-4	/* 408B7E12 routine offset from the next entry */
    .long   DOCKINITSCC_5A-.-4	/* 408B7E16 routine offset from the next entry */
    .long   DOCKINGWAKEUP_F2-.-4	/* 408B7E1A routine offset from the next entry */
    .long   GRACEFULSHUTDOWN_2AE-.-4	/* 408B7E1E routine offset from the next entry */
    .long   DOCKINITSCC_10E-.-4	/* 408B7E22 routine offset from the next entry */
    .long   DOCKINITSCC_12A-.-4	/* 408B7E26 routine offset from the next entry */
    .long   DOCKINITSCC_144-.-4	/* 408B7E2A routine offset from the next entry */
    .long   DOCKINITSCC_15E-.-4	/* 408B7E2E routine offset from the next entry */
    .long   DOCKINGWAKEUP_16E-.-4	/* 408B7E32 routine offset from the next entry */
    .long   DOCKINGWAKEUP_16E-.-4	/* 408B7E36 routine offset from the next entry */
    .long   DOCKINITSCC_1AE-.-4	/* 408B7E3A routine offset from the next entry */
    .long   DOCKINITSCC_2E4-.-4	/* 408B7E3E routine offset from the next entry */
    .long   DOCKINITSCC_2EC-.-4	/* 408B7E42 routine offset from the next entry */
    .long   DOCKINGWAKEUP_16E-.-4	/* 408B7E46 routine offset from the next entry */
    .long   DOCKINGSLEEPDENIED_A-.-4	/* 408B7E4A routine offset from the next entry */
    .long   DOCKINGWAKEUPDENIED_A-.-4	/* 408B7E4E routine offset from the next entry */
    .long   DOCKINITSCC_DA-.-4	/* 408B7E52 routine offset from the next entry */
    .long   GRACEFULSHUTDOWN-.-4	/* 408B7E56 routine offset from the next entry */
    .byte   0x00, 0x00, 0x00, 0x00	| 408B7E5A
GRACEFULSHUTDOWN_2AE:   /* (after the table) */
    lea %sp@(-56),%sp	| 408B7E5E
    moveal %sp,%a0
    moveb %a2@(4),%a0@(49)
    moveq #24,%d0
    _SlotManager
    lea %sp@(56),%sp
    seq %d0
    tstb %d0
    rts
    .fill   0x558, 1, 0x00
