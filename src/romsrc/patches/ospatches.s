/*
 patches/ospatches.s - OS patches (SCSI, BlockMove, Device/File/Memory Manager, Gestalt, HWPriv, ...)
 From INITMGR_SCSIDB (0x40884000). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
*/

/*
 INITMGR_SCSIDB: SCSI Manager set-up for machines with two SCSI buses (the "DB"
 variant): vectors for SCSIReset/SCSIGet, the second-bus select routine, the bus
 chip addresses (SCSI 96, DMA, handshake) in the SCSI globals.
*/
SCSIINITDB:
INITMGR_SCSIDB:
    moveml %d0-%a5,%sp@-
    moveq #0,%d7
    moveal SCSIGlobals,%a4
    moveq #1,%d1
    lea %pc@(SCSIDB),%a1
    movel %a1,%d0
    lea %pc@(SCSIINITDB_4C),%a1
    moveal %a4,%a0
SCSIINITDB_18:          /* vector table from offsets */
    moveq #0,%d2
    movew %a1@+,%d2
    addl %d0,%d2
    movel %d2,%a0@+
    dbf %d1,SCSIINITDB_18
    lea %pc@(DOSCSISELECT_DC80),%a1
    movel %a1,%a4@(8)
    movel ToolDispTable,%a4@(268)
    movel SCSIDMA,%a4@(272)
    movel SCSIHsk,%a4@(276)
    clrl %a4@(460)
    clrl %a4@(464)
    moveml %sp@+,%d0-%a5
    rts
SCSIINITDB_4C:          /* offsets of DOSCSIRESET_DB and DOSCSIGET_DB */
    .long   0x00000034	| 4088404C
    .short  0x007C	| 40884050
    .fill   0xAE, 1, 0x00

/* DOSCSIRESET_DB: SCSIReset on both buses (the internal and the external chip). */
SCSIDB:
SCSIMGR_DB:
DOSCSIRESET_DB:
    movel %a0,%sp@-
    moveal %a4@(268),%a3
    moveal %a4@(420),%a0
    jsr %a0@
    jbsr SCSIEXITCLEANUP
    movel %a4@(280),%d0
    jbeq SCSIDB_26
    moveal %d0,%a3
    moveal %a4@(420),%a0
    jsr %a0@
    jbsr SCSIEXITCLEANUP
SCSIDB_26:              /* return 0 */
    moveal %sp@+,%a0
    movew %d7,%fp@(8)
    moveq #0,%d0
    jbra SCSISTDEXIT

/*
 DOSCSIGET_DB: SCSIGet: arbitrate for the bus (wait for the asynchronous manager to be
 idle), unless already busy (7 = scBusy... result).
*/
DOSCSIGET_DB:
    bset #0,%a4@(97)
    jbne DOSCSIGET_DB_1E
    movew %sr,%sp@-
    oriw #1792,%sr
    movew %sp@,%d0
    andiw #1792,%d0
    jbeq DOSCSIGET_DB_22
    tstl %a4@(80)
    jbeq DOSCSIGET_DB_22
    movew %sp@+,%sr
DOSCSIGET_DB_1E:        /* busy: 7 */
    moveq #7,%d0
    jbra DOSCSIGET_DB_3E
DOSCSIGET_DB_22:        /* queue the request, wait for it to start */
    lea %a4@(676),%a1
    moveq #-1,%d0
    moveal %a4@(392),%a0
    jsr %a0@
    movew %sp@+,%sr
DOSCSIGET_DB_30:        /* wait */
    cmpal %a4@(80),%a1
    jbne DOSCSIGET_DB_30
    movel %d7,%d0
    jbsr SCSIGETPATCH
DOSCSIGET_DB_3E:        /* result */
    movew %d0,%fp@(8)
    jbra NOBYTEEXIT

/*
 DOSCSISELECT_DC80: SCSISelect (or SCSISelAtn, d1 = 11) on the bus where the target
 was last found: try the internal bus, then the external one, and remember on which
 bus each ID answered (bit masks at +460 and +464).
*/
DOSCSISELECT_DC80:
    bset #0,%a4@(97)
    moveq #0,%d0
    movew %fp@(8),%d0
    cmpiw #11,%d1
    jbne DOSCSISELECT_DC80_16
    bset #31,%d0
DOSCSISELECT_DC80_16:   /* ID, with ATN flag */
    movel %d0,%a4@(320)
    movel %d0,%d6
    btst %d0,%a4@(464)
    jbne DOSCSISELECT_DC80_66
    moveal %a4@(268),%a3
    movel %a3,%a4@(64)
    movel %a4@(272),%a4@(68)
    movel %a4@(276),%a4@(72)
    jbsr ARBITRATE
    jbeq DOSCSISELECT_DC80_50
    btst %d0,%a4@(460)
    jbeq DOSCSISELECT_DC80_66
    movel %d0,%sp@-
    jbsr SCSIEXITCLEANUP
    movel %sp@+,%d0
    jbra DOSCSISELECT_DC80_AC
DOSCSISELECT_DC80_50:   /* internal bus: select */
    movel %d6,%d0
    jbsr SELECT
    jbne DOSCSISELECT_DC80_60
    bset %d0,%a4@(460)
    jbra DOSCSISELECT_DC80_AC
DOSCSISELECT_DC80_60:   /* failed: was it there before? */
    btst %d0,%a4@(460)
    jbne DOSCSISELECT_DC80_A2
DOSCSISELECT_DC80_66:   /* external bus (if there is one) */
    movel %a4@(280),%d2
    jbeq DOSCSISELECT_DC80_B8
    moveal %d2,%a3
    movel %a3,%a4@(64)
    movel %a4@(284),%a4@(68)
    movel %a4@(288),%a4@(72)
    jbsr ARBITRATE
    jbeq DOSCSISELECT_DC80_92
    movel %d0,%sp@-
    jbsr SCSIEXITCLEANUP
    movel %sp@+,%d0
    jbra DOSCSISELECT_DC80_AC
DOSCSISELECT_DC80_92:   /* select */
    movel %d6,%d0
    jbsr SELECT
    jbne DOSCSISELECT_DC80_A2
    bset %d6,%a4@(464)
    jbra DOSCSISELECT_DC80_AC
DOSCSISELECT_DC80_A2:   /* failed: clean up */
    movel %d0,%sp@-
    jbsr SCSIEXITCLEANUP
    movel %sp@+,%d0
DOSCSISELECT_DC80_AC:   /* result */
    movew %d0,%fp@(10)
    moveq #2,%d0
    jbra SCSISTDEXIT
DOSCSISELECT_DC80_B8:   /* no external bus */
    clrb %a4@(464)
    moveq #2,%d0
    jbra DOSCSISELECT_DC80_A2
    .fill   0x1C4, 1, 0x00

/*
 BLOCKMOVE68040: _BlockMove for the 68040: short moves byte by byte (BMVERYSHORT),
 overlapping ones backwards, others longs, and big aligned ones with move16 (16-byte
 lines). The caches are flushed over the destination afterwards (FLUSHCRANGEFORBM).
*/
trap_BlockMove:
BLOCKMOVEPATCH:
BLOCKMOVE68040:
    moveq #-12,%d1
    addl %d0,%d1
    jbgt BLOCKMOVEPATCH_C
    jbra BMVERYSHORT
BLOCKMOVEPATCH_C:       /* push the flush routine as return address */
    movel %d0,%sp@-
    movel %a1,%sp@-
    biglea FLUSHCRANGEFORBM, a1
    movel %a1,%sp@-
    moveal %sp@(4),%a1
    jbra BLOCKMOVEPATCH_26
    .short  0x2F38, 0x06F4	| 40884422
BLOCKMOVEPATCH_26:      /* overlap? alignment? */
    movel %a1,%d1
    moveq #-4,%d2
    orl %d1,%d2
    subl %a0,%d1
    andl Lo3Bytes,%d1
    cmpl %d0,%d1
    jbcs BLOCKMOVEPATCH_4A
    cmpil #47,%d0
    jbcs BLOCKMOVEPATCH_44
    andib #15,%d1
    jbeq BLOCKMOVEPATCH_50
BLOCKMOVEPATCH_44:      /* misaligned: longs */
    jbra BMMOVELONGS
BLOCKMOVEPATCH_4A:      /* overlap: backwards */
    jbra BMOVERLAP
BLOCKMOVEPATCH_50:      /* align the destination to 16 bytes */
    movel %a1,%d1
    negl %d1
    moveq #15,%d2
    andl %d1,%d2
    jbeq BLOCKMOVEPATCH_76
    subl %d2,%d0
    lsrl #1,%d2
    jbcc BLOCKMOVEPATCH_62
    moveb %a0@+,%a1@+
BLOCKMOVEPATCH_62:      /* word */
    lsrl #1,%d2
    jbcc BLOCKMOVEPATCH_68
    movew %a0@+,%a1@+
BLOCKMOVEPATCH_68:      /* long */
    lsrl #1,%d2
    jbcc BLOCKMOVEPATCH_70
    movel %a0@+,%a1@+
    tstl %d2
BLOCKMOVEPATCH_70:      /* two longs */
    jbeq BLOCKMOVEPATCH_76
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
BLOCKMOVEPATCH_76:      /* move16 loop, 32 bytes per pass */
    moveq #32,%d2
    subl %d2,%d0
    bclr #4,%d0
    nop
    jbeq BLOCKMOVEPATCH_90
    move16 %a0@+,%a1@+
    jbra BLOCKMOVEPATCH_90
    .long   0x00000000, 0x00000000	| 40884488
BLOCKMOVEPATCH_90:      /* two lines */
    move16 %a0@+,%a1@+
    subl %d2,%d0
    move16 %a0@+,%a1@+
    jbge BLOCKMOVEPATCH_90
    jbra BMEXIT16
    .fill   0x75E, 1, 0x00

/* OPENIGNOREPATCH: Slot Manager 43 (moveq #43, _SlotManager), exchange, 0. */
DEVICEMGRPATCH:
OPENIGNOREPATCH:
    moveq #43,%d0
    _SlotManager
    exg %a4,%a0
    moveq #0,%d0
    rts

/*
 READUPDATE / WRITEUPDATE: file reads and writes count as user activity for the Power
 Manager (PowerDispatch 2, when 0xDD5 bit 0).
*/
READUPDATE:
    btst #0,0xdd5
    jbeq READUPDATE_C
    moveq #2,%d0
    _PowerDispatch
READUPDATE_C:           /* return */
    rts

/*
 WRITEUPDATE: the same, then continue in FILEWRITE (or WRITEUPDATERETURN for a
 negative refnum).
*/
WRITEUPDATE:
    btst #0,0xdd5
    jbeq WRITEUPDATE_C
    moveq #2,%d0
    _PowerDispatch
WRITEUPDATE_C:          /* continue the write */
    movew %a0@(24),%d2
    jbpl FILEWRITE
    jbra WRITEUPDATERETURN
    .fill   0x3CC, 1, 0x00

/*
 SETTRAPADDRESSPATCH: SetTrapAddress: flush the caches (vector 0x6F4) before storing
 the new address.
*/
DISPATCHPATCH:
SETTRAPADDRESSPATCH:
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x6f4,%za0)@(0)	| 40885000
    movel %a0,%a1@
    moveq #0,%d0
    rts

/*
 CACHEVECTORPATCH: the A-line vector to the trap dispatcher, and on a 68040 the cache
 flush vector (0x6F4) to trap_CacheFlush.
*/
CACHEVECTORPATCH:
    biglea trap_dispatcher
    movel %a0,ATrapVector
    cmpib #4,CPUFlag
    jbne CACHEVECTORPATCH_1E
    lea %pc@(trap_CacheFlush),%a1
    movel %a1,0x6f4
CACHEVECTORPATCH_1E:    /* return */
    rts
    .long   0x00000000	| 4088502C

/* trap_CacheFlush: flush both 68040 caches (cpusha). */
trap_CacheFlush:
    nop
    cpusha %bc
    rts
    .fill   0x3CA, 1, 0x00

/*
 EGRETDISPATCHPATCH: Egret packets: remember the completion routine (+48) or the
 handler of unsolicited 0xFE packets (+44).
*/
EGRETPATCHTOO:
EGRETDISPATCHPATCH:
    jbne EGRETPATCHTOO_8
    movel %a0,%a2@(48)
    jbra EGRETPATCHTOO_14
EGRETPATCHTOO_8:        /* 0xFE: packet handler */
    cmpib #0xfe,%a0@
    jbne EGRETPATCHTOO_18
    movel %a0@(2),%a2@(44)
EGRETPATCHTOO_14:       /* done */
    moveq #0,%d0
    addqw #4,%sp
EGRETPATCHTOO_18:       /* not ours */
    rts

/* CHECKPACKETPATCH: 0xFF and 0xFE packets have no data count to check. */
CHECKPACKETPATCH:
    cmpib #0xff,%a0@
    jbeq CHECKPACKETPATCH_C
    cmpib #0xfe,%a0@
    jbne CHECKPACKETPATCH_12
CHECKPACKETPATCH_C:     /* clear it */
    clrw %a0@(14)
    addqw #4,%sp
CHECKPACKETPATCH_12:    /* return */
    rts

/* DELAY100PATCH: a delay of about 100 microseconds (TimeVIADB / 8 + 25 VIA reads). */
DELAY100PATCH:
    movel %d1,%sp@-
    movew TimeVIADB,%d1
    lsrw #3,%d1
    addiw #25,%d1
DELAY100PATCH_C:        /* loop */
    tstb %a1@
    dbf %d1,DELAY100PATCH_C
    movel %sp@+,%d1
    rts

/*
 SHIFTREGIRQPATCH: Egret shift register interrupt: deliver unsolicited packets (type 4)
 to their handler, others normally.
*/
SHIFTREGIRQPATCH:
    jbne SHIFTREGIRQPATCH_C
    cmpib #3,%a1@(3)
    jbne SHIFTREGIRQPATCH_2C
    rts
SHIFTREGIRQPATCH_C:     /* unsolicited packet with a handler: call it */
    cmpib #4,%a1@(1)
    jbne SHIFTREGIRQPATCH_2C
    movel %a2@(44),%d2
    jbeq SHIFTREGIRQPATCH_2C
    moveal %d2,%a3
    moveb %a1@(3),%d0
    jbsr SETRESPONSEPARAMS
    movew %d3,%sr
    jsr %a3@
    jbra SHIFTREGIRQPATCH_3A
SHIFTREGIRQPATCH_2C:    /* normal response */
    jbsr SETRESPONSEPARAMS
    movew %d3,%sr
    jbra SHIFTREGIRQPATCH_3A
    .short  0x0891, 0x0004	| 4088547A
SHIFTREGIRQPATCH_3A:    /* return */
    addqw #4,%sp
    rts

/* SETTRANSFERPARMSPATCH: Egret transfer parameters by packet type: table below. */
SETTRANSFERPARMSPATCH:
    andib #15,%d0
    lea %pc@(SETTRANSFERPARMSPATCH_A),%a1
    rts
SETTRANSFERPARMSPATCH_A:  /* parameters per packet type */
    .long   0x00000000	| 4088548C
    .long   0x00000000, 0x00000000, 0x00000000, 0x80008000	| 40885490
    .long   0x80008000, 0x00080008, 0x00080008	| 408854A0

/*
 ECLIPSEEGRETPATCHES: on the Quadra 900/950 (Egret, 68040): the Egret reliability
 manager, the DFAC set-up and the keyswitch handler.
*/
ECLIPSEEGRETPATCHES:
    jbsr INITRELIABILITY
    moveq #112,%d0
    andl 0xdd4,%d0
    subil #32,%d0
    jbne ECLIPSEEGRETPATCHES_22
    cmpib #4,CPUFlag
    jbne ECLIPSEEGRETPATCHES_22
    jbsr ECLIPSEDFACPATCH
    jbsr ECLIPSEPDMPATCH
ECLIPSEEGRETPATCHES_22:  /* return */
    rts

/*
 ECLIPSEPDMPATCH: install KEYSWITCHHANDLER for Egret's keyswitch packets (0xFE00), and
 a 34-byte block in ExpandMem (+438).
*/
ECLIPSEPDMPATCH:
    moveml %a0-%a1,%sp@-
    subaw #20,%sp
    moveal %sp,%a0
    movew #-512,%a0@
    clrl %a0@(16)
    lea %pc@(KEYSWITCHHANDLER),%a1
    movel %a1,%a0@(2)
    _EgretDispatch
    moveal ExpandMem,%a1
    moveq #34,%d0
    .short  0xA71E	| 408854F2 _NewPtr (flags 0x0700)
    movel %a0,%a1@(438)
    addaw #20,%sp
    moveml %sp@+,%a0-%a1
    rts

/*
 KEYSWITCHHANDLER (raw words partly): the keyswitch was turned off: start a deferred
 task that shuts the machine down (closing the drivers); if that cannot be done,
 power off at once.
*/
KEYSWITCHHANDLER:
    tstb %d0	| 40885502
    jbne KEYSWITCHHANDLER_4C	| 40885504
    moveml %a0-%a1,%sp@-	| 40885506
    moveal ExpandMem,%a1	| 4088550A
    moveal %a1@(438),%a0	| 4088550E
    moveal %a0,%a1	| 40885512
    moveq #16,%d0	| 40885514
KEYSWITCHHANDLER_14:    /* loop: clr */
    clrw %a1@+	| 40885516
    dbf %d0,KEYSWITCHHANDLER_14	| 40885518
    lea %pc@(KEYSWITCHHANDLER_7E),%a1	| 4088551C
    movel %a1,%a0@(6)	| 40885520
    _InsTime	| 40885524
    movel #5000,%d0	| 40885526
    _PrimeTime	| 4088552C
    lea %a0@(14),%a0	| 4088552E
    movew #7,%a0@(4)	| 40885532
    lea %pc@(KEYSWITCHHANDLER_4E),%a1
    movel %a1,%a0@(8)
    jsr @(JDTInstall,%za0)@(0)	| 40885540
    moveml %sp@+,%a0-%a1
    tstw %d0
    jbne KEYSWITCHHANDLER_7E
KEYSWITCHHANDLER_4C:    /* return */
    rts
KEYSWITCHHANDLER_4E:    /* the deferred task */
    moveal VCBQHdr_Head,%a1	| 40885550
    jbra KEYSWITCHHANDLER_7A	| 40885554
KEYSWITCHHANDLER_54:    /* loop: tst */
    tstw %a1@(76)	| 40885556
    jbne KEYSWITCHHANDLER_78	| 4088555A
    subaw #50,%sp	| 4088555C
    moveal %sp,%a0	| 40885560
    movew %a1@(78),%a0@(22)	| 40885562
    clrl %a0@(18)	| 40885568
    clrl %a0@(12)	| 4088556C
    movel %a1,%sp@-	| 40885570
    .short  0xA20E	| 40885572 _UnmountVol (flags 0x0200)
    moveal %sp@+,%a1	| 40885574
    lea %sp@(50),%sp	| 40885576
KEYSWITCHHANDLER_78:    /* set %a1 */
    moveal %a1@,%a1	| 4088557A
KEYSWITCHHANDLER_7A:    /* set %d0 */
    movel %a1,%d0	| 4088557C
    jbne KEYSWITCHHANDLER_54	| 4088557E
KEYSWITCHHANDLER_7E:    /* power off (loop) */
    jbsr EGRETPOWEROFF
    jbra KEYSWITCHHANDLER_7E

/* ECLIPSEDFACPATCH: Egret command 0x0120 with one byte (0x01): the DFAC sound chip set-up. */
ECLIPSEDFACPATCH:
    moveml %a0-%a1,%sp@-
    subaw #20,%sp
    moveal %sp,%a0
    movew #288,%a0@
    clrl %a0@(16)
    movew #256,%sp@-
    movel %sp,%a0@(8)
    movew #2,%a0@(6)
    _EgretDispatch
    addaw #22,%sp
    moveml %sp@+,%a0-%a1
    rts
    .fill   0x59E, 1, 0x00
ECLIPSEDFACPATCH_5CA:   /* (zeros) */
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40885B52
ECLIPSEDFACPATCH_5D4:   /* (zeros) */
    .long   0x00000000	| 40885B5C
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40885B60
ECLIPSEDFACPATCH_5E5:   /* (zeros) */
    .fill   0x93, 1, 0x00

/*
 CMDDONEPATCH: File Manager command done: after a read (type 2) flush the caches (the
 data may be code).
*/
FILEMGRPATCH:
CMDDONEPATCH:
    moveal FSQHdr_Head,%a0
    cmpib #2,%a0@(7)
    jbne FILEMGRPATCH_16
    movel %d1,%sp@-
    jsr @(0x6f4,%za0)@(0)	| 40885C0E
    movel %sp@+,%d1
FILEMGRPATCH_16:        /* clear SysCRefCnt */
    clrb SysCRefCnt
    extl %d0
    rts

/*
 DSHOOKPATCH: before a system error alert, set the trap to retry (TrapAgain), flush the
 caches, and go.
*/
DSHOOKPATCH:
    movew %a0@(6),%d0
    jbgt DSHOOKPATCH_A
    jmp %pc@(DSHOOKPATCH_1A)
DSHOOKPATCH_A:          /* positive error: retry the trap */
    orib #0xa0,TrapAgain
    moveb #96,TrapAgain_1
    andiw #255,%d0
DSHOOKPATCH_1A:         /* flush, jump to TrapAgain */
    movel %d1,%sp@-
    jsr @(0x6f4,%za0)@(0)	| 40885C3A
    movel %sp@+,%d1
    jmp TrapAgain
    .fill   0x7B8, 1, 0x00
DSHOOKPATCH_7E0:        /* Gestalt 'mmu ' / processor details: 68040 MMU page size bits */
    .byte   0x00, 0x00	| 408863FE
    moveq #0,%d0	| 40886400
    cmpib #4,CPUFlag
    jbne GestaltPatch_20
    movec %tc,%d1
    btst #14,%d1
    jbne GestaltPatch_1A
    bset #12,%d0
    jbra GestaltPatch_50
GestaltPatch_1A:        /* 8 KB pages */
    bset #13,%d0
    jbra GestaltPatch_50
GestaltPatch_20:        /* other CPUs */
    cmpib #2,CPUFlag
    bltw GestaltPatch_54
    cmpib #3,MMUType
    jblt GestaltPatch_4A
    moveal ExpandMem,%a0
    moveal %a0@(92),%a0
    lea %a0@(18),%a0
    .short  0xF010, 0x4200	| 4088643E pmove %tc,%a0@
    bfextu %a0@,8,4,%d1
    bset %d1,%d0
    bras GestaltPatch_50
GestaltPatch_4A:        /* answer */
    movel #32768,%d0
GestaltPatch_50:        /* return it */
    braw getAddrModePatch_1E
GestaltPatch_54:        /* no answer: gestaltUnknownErr */
    braw getAddrModePatch_16

/*
 getFPUTypePatch: Gestalt 'fpu ': 3 for the 68040's FPU, else 1 (68881) or 2 (68882)
 from the size of the fsave frame, 0 without an FPU.
*/
getFPUTypePatch:
    btst #4,HWCfgFlags
    jbeq getFPUTypePatch_44
    cmpib #4,CPUFlag
    jbne getFPUTypePatch_14
    moveq #3,%d0
    jbra getFPUTypePatch_46
getFPUTypePatch_14:     /* fsave frame */
    moveal %sp,%a0
    fnop
    fsave %sp@-
    movew %sp@,%d0
    moveal %a0,%sp
    cmpiw #7960,%d0
    jbeq getFPUTypePatch_3C
    cmpiw #16152,%d0
    jbeq getFPUTypePatch_3C
    cmpiw #16184,%d0
    jbeq getFPUTypePatch_40
    cmpiw #7992,%d0
    jbeq getFPUTypePatch_40
    moveq #0,%d0
    jbra getFPUTypePatch_46
getFPUTypePatch_3C:     /* 68881 */
    moveq #1,%d0
    jbra getFPUTypePatch_46
getFPUTypePatch_40:     /* 68882 */
    moveq #2,%d0
    jbra getFPUTypePatch_46
getFPUTypePatch_44:     /* no FPU */
    moveq #0,%d0
getFPUTypePatch_46:     /* return it */
    jbra getAddrModePatch_1E

/* getAddrModePatch: return a Gestalt answer (or the error -5550) to the caller. */
getAddrModePatch:
    moveq #0,%d0
    moveb 0xb73,%d0
    notb %d0
    andil #3,%d0
    bset #2,%d0
    braw getAddrModePatch_1E
getAddrModePatch_16:    /* error -5550 (gestaltUnknownErr) */
    movew #-5550,%sp@(12)
    jbra getAddrModePatch_28
getAddrModePatch_1E:    /* store the answer, result 0 */
    moveal %sp@(4),%a0
    movel %d0,%a0@
    clrw %sp@(12)
getAddrModePatch_28:    /* pop the parameters */
    moveal %sp@+,%a0
    addql #8,%sp
    jmp %a0@
    .fill   0x732, 1, 0x00

/*
 GETREALPROC / GETPAGEDESCPROC: _MemoryDispatch GetPhysical helpers: the physical
 address (6) or the page descriptor (7) of the logical address a0, walking the MMU
 tables (transparent translation first). Result: 0 or -50.
*/
GETREALPROC:
    movew #6,%sp@-
    jbra GETPAGEDESCPROC_4

GETPAGEDESCPROC:        /* loop: move */
    movew #7,%sp@-
GETPAGEDESCPROC_4:      /* (common) */
    moveml %d1-%d4,%sp@-
    linkw %fp,#-26
    cmpib #3,MMUType
    jbge GETPAGEDESCPROC_1A
    movew #-626,%d0
    jbra GETPAGEDESCPROC_58
GETPAGEDESCPROC_1A:     /* MMU info, 32-bit mode */
    movel %a0,%d2
    jsr %pc@(GETMMUINFO)
    moveb MMU32Bit,%sp@-
    jbne GETPAGEDESCPROC_30
    moveq #1,%d0
    _SwapMMUMode
    andl Lo3Bytes,%d2
    jbra GETPAGEDESCPROC_3E
GETPAGEDESCPROC_30:     /* transparently translated? */
    jsr %pc@(CHECKTTREGS)
    jbne GETPAGEDESCPROC_3E
    moveal %d2,%a0
    subal %a2,%a2
    moveq #0,%d3
    jbra GETPAGEDESCPROC_50
GETPAGEDESCPROC_3E:     /* walk the tables (68030 or 68040 format) */
    cmpib #5,MMUType
    jbeq GETPAGEDESCPROC_4C
    jsr %pc@(CHECKTTREGS_50)
    jbra GETPAGEDESCPROC_50
GETPAGEDESCPROC_4C:     /* 68040 tables */
    jsr %pc@(CHECKTTREGS_10A)
GETPAGEDESCPROC_50:     /* back to the previous mode */
    moveb %sp@+,%d0
    jbne GETPAGEDESCPROC_56
    _SwapMMUMode
GETPAGEDESCPROC_56:     /* result */
    movew %d3,%d0
GETPAGEDESCPROC_58:     /* (no MMU: -626) */
    unlk %fp
    moveml %sp@+,%d1-%d4
    cmpiw #7,%sp@+
    jbne GETPAGEDESCPROC_66
    moveal %a2,%a0
GETPAGEDESCPROC_66:     /* return */
    rts

/*
 GETMMUINFO: the 68040 MMU set-up in the frame: root pointer (SRP), TC, the index
 widths (7, 7, 5 or 6 for 4/8 KB pages), the physical ROM offset (0x1EF0) for ROM
 addresses.
*/
GETMMUINFO:
    cmpib #5,MMUType
    jbeq GETMMUINFO_4C
    .short  0xF02E, 0x4E00, 0xFFF0	| 40886C76 pmove %crp,%fp@(-16)
    .short  0xF02E, 0x4200, 0xFFF8	| 40886C7C pmove %tc,%fp@(-8)
    movel %fp@(-8),%d4
    moveq #12,%d3
    bfextu %d4,%d3,4,%d0
    moveb %d0,%fp@(-21)
    addql #4,%d3
    bfextu %d4,%d3,4,%d0
    moveb %d0,%fp@(-25)
    addql #4,%d3
    bfextu %d4,%d3,4,%d0
    moveb %d0,%fp@(-24)
    addql #4,%d3
    bfextu %d4,%d3,4,%d0
    moveb %d0,%fp@(-23)
    addql #4,%d3
    bfextu %d4,%d3,4,%d0
    moveb %d0,%fp@(-22)
    bras GETMMUINFO_7E_8
GETMMUINFO_4C:          /* 68040 */
    movec %srp,%d0
    movel %d0,%fp@(-12)
    clrl %fp@(-16)
    moveb #7,%fp@(-25)
    moveb #7,%fp@(-24)
    moveb #5,%fp@(-23)
    movec %tc,%d0
    movew %d0,%fp@(-8)
    btst #14,%d0
    jbne GETMMUINFO_7E
    moveb #6,%fp@(-23)
GETMMUINFO_7E:          /* 8 KB pages: 5 bits */
    clrb %fp@(-22)
    clrb %fp@(-21)
GETMMUINFO_7E_8:
    clrl %fp@(-20)
    movew #-24484,%d0
    .short  0xA346	| 40886CFC _GetTrapAddress (flags 0x0300)
    movel ROMBase,%d0
    cmpal %d0,%a0
    jbge GETMMUINFO_BC
    jbra GETMMUINFO_C2
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40886D08
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40886D18
    bnes GETMMUINFO_C2	| 40886D28
GETMMUINFO_BC:          /* ROM address */
    movel 0x1ef0,%fp@(-20)
GETMMUINFO_C2:          /* return */
    rts

/*
 CHECKTTREGS: is the address d2 covered by a transparent translation register (DTT0
 or DTT1)? Out: Z set if so.
*/
CHECKTTREGS:
    cmpib #5,MMUType
    jbeq CHECKTTREGS_1A
    subqw #4,%sp
    .long   0xF0170A00	| 40886D3C
    .long   0x2017F017, 0x0E002217, 0x584F6008	| 40886D40
CHECKTTREGS_1A:         /* DTT0 enabled? address in its range? */
    movec %dtt0,%d0
    movec %dtt1,%d1
    btst #15,%d0
    jbeq CHECKTTREGS_36
    movel %d2,%d3
    eorl %d0,%d3
    roll #8,%d3
    swap %d0
    notb %d0
    andb %d0,%d3
    jbeq CHECKTTREGS_4E
CHECKTTREGS_36:         /* DTT1 */
    btst #15,%d1
    jbeq CHECKTTREGS_4A
    movel %d2,%d3
    eorl %d1,%d3
    roll #8,%d3
    swap %d1
    notb %d1
    andb %d1,%d3
    jbra CHECKTTREGS_4E
CHECKTTREGS_4A:         /* no: Z clear */
    andiw #-5,%sr
CHECKTTREGS_4E:         /* return */
    rts

CHECKTTREGS_50:         /* walk the 68030 tables (TC from the frame) to the page of d2 */
    moveml %d4-%d7,%sp@-
    movel %fp@(-12),%d1
    movel %fp@(-16),%d7
    moveb %d7,%d3
    andib #3,%d3
    movel %fp@(-8),%d0
    btst #25,%d0
    jbne CHECKTTREGS_104
    btst #24,%d0
    jbne CHECKTTREGS_104
    btst #31,%d0
    jbne CHECKTTREGS_84
    moveal %d2,%a1
    moveq #0,%d1
    moveq #0,%d3
    jbra CHECKTTREGS_FE
CHECKTTREGS_84:         /* MMU enabled: walk each level */
    moveq #0,%d4
    moveb %fp@(-21),%d4
    lea %fp@(-25),%a1
    moveq #0,%d5
    moveb %a1@+,%d5
CHECKTTREGS_92:         /* next level: page descriptor reached? */
    cmpib #1,%d3
    jbeq CHECKTTREGS_E6
    bfextu %d2,%d4,%d5,%d6
    tstl %d7
    jbeq CHECKTTREGS_A6
    jsr %pc@(CHECKTTREGS_1A0)
    jbcs CHECKTTREGS_104
CHECKTTREGS_A6:         /* short descriptor */
    andil #-16,%d1
    cmpib #2,%d3
    jbne CHECKTTREGS_C4
    addl %fp@(-20),%d1
    moveal %d1,%a2
    lslw #2,%d6
    addal %d6,%a2
    movel %a2@,%d1
    moveq #0,%d7
    moveb %d1,%d3
    jbra CHECKTTREGS_DC
CHECKTTREGS_C4:         /* long descriptor */
    cmpib #3,%d3
    jbne CHECKTTREGS_104
    addl %fp@(-20),%d1
    moveal %d1,%a2
    lslw #3,%d6
    addal %d6,%a2
    movel %a2@(4),%d1
    movel %a2@,%d7
    moveb %d7,%d3
CHECKTTREGS_DC:         /* next level */
    addl %d5,%d4
    moveb %a1@+,%d5
    andib #3,%d3
    jbra CHECKTTREGS_92
CHECKTTREGS_E6:         /* page found: physical address */
    moveq #32,%d5
    subl %d4,%d5
    bfextu %d1,0,%d4,%d0
    bfextu %d2,%d4,%d5,%d6
    lsll %d5,%d0
    addl %d6,%d0
    moveal %d0,%a0
    nop
    nop
    moveq #0,%d3
CHECKTTREGS_FE:         /* return */
    moveml %sp@+,%d4-%d7
    rts
CHECKTTREGS_104:        /* invalid: -50 */
    movew #-50,%d3
    jbra CHECKTTREGS_FE

CHECKTTREGS_10A:        /* walk the 68040 tables (root, pointer, page) */
    moveml %d4-%d7,%sp@-
    movel %fp@(-12),%d1
    movew %fp@(-8),%d0
    btst #15,%d0
    jbne CHECKTTREGS_124
    moveal %d2,%a1
    moveq #0,%d1
    moveq #0,%d3
    jbra CHECKTTREGS_194
CHECKTTREGS_124:        /* MMU enabled */
    moveq #0,%d4
    clrw %d3
    moveq #0,%d5
    lea %fp@(-25),%a1
CHECKTTREGS_12E:        /* next level */
    moveb %a1@+,%d5
    moveq #30,%d0
    subl %d5,%d0
    bfextu %d1,0,%d0,%d1
    lsll %d5,%d1
    lsll #2,%d1
    bfextu %d2,%d4,%d5,%d6
    lslw #2,%d6
    addl %d6,%d1
    addl %fp@(-20),%d1
    moveal %d1,%a2
    movel %a2@,%d1
    cmpiw #2,%d3
    jbeq CHECKTTREGS_15E
    btst #1,%d1
    jbeq CHECKTTREGS_19A
    addl %d5,%d4
    addqw #1,%d3
    jbra CHECKTTREGS_12E
CHECKTTREGS_15E:        /* page level: resident or indirect */
    moveb %d1,%d0
    andib #3,%d0
    cmpib #1,%d0
    jbeq CHECKTTREGS_17E
    cmpib #2,%d0
    jbne CHECKTTREGS_19A
    andil #-4,%d1
    addl %fp@(-20),%d1
    moveal %d1,%a2
    movel %a2@,%d1
CHECKTTREGS_17E:        /* physical address */
    addl %d5,%d4
    moveq #32,%d5
    subl %d4,%d5
    bfextu %d1,0,%d4,%d0
    bfextu %d2,%d4,%d5,%d6
    lsll %d5,%d0
    addl %d6,%d0
    moveal %d0,%a0
    moveq #0,%d3
CHECKTTREGS_194:        /* return */
    moveml %sp@+,%d4-%d7
    rts
CHECKTTREGS_19A:        /* invalid: -50 */
    movew #-50,%d3
    jbra CHECKTTREGS_194

CHECKTTREGS_1A0:        /* limit check of a 68030 long descriptor */
    swap %d7
    btst #15,%d7
    jbne CHECKTTREGS_1AC
    cmpw %d6,%d7
    jbra CHECKTTREGS_1B2
CHECKTTREGS_1AC:        /* (lower limit) */
    andiw #32767,%d7
    cmpw %d7,%d6
CHECKTTREGS_1B2:        /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40886EE6

/*
 EDISKPROTECT: write protect (a1 nonzero) or unprotect the RAM disk page at a0 by its
 68040 page descriptor (WP bit), then flush the address translation cache.
*/
EDISKPROTECT:
    moveml %d2-%d4/%a2,%sp@-
    linkw %fp,#-26
    movel %a0,%d2
    moveaw %a1,%a2
    movew %sr,%d0
    btst #13,%d0
    jbne EDISKPROTECT_18
    moveq #8,%d0
    _DebugUtil
EDISKPROTECT_18:        /* (supervisor mode through the debugger utility) */
    movew %d0,%sp@-
    moveb MMU32Bit,%sp@-
    jbne EDISKPROTECT_26
    moveq #1,%d0
    _SwapMMUMode
    jbra EDISKPROTECT_32
EDISKPROTECT_26:        /* transparently translated: cannot, -50 */
    jsr %pc@(CHECKTTREGS)
    jbne EDISKPROTECT_32
    moveal %d2,%a0
    moveq #-50,%d3
    jbra EDISKPROTECT_84
EDISKPROTECT_32:        /* find its page descriptor */
    jsr %pc@(GETMMUINFO)
    moveq #0,%d0
    moveq #0,%d1
    moveb %fp@(-21),%d0
    moveb %fp@(-25),%d1
    bfextu %d2,%d0,%d1,%d0
    lsll #2,%d0
    btst #0,%fp@(-13)
    jbeq EDISKPROTECT_52
    lsll #1,%d0
EDISKPROTECT_52:        /* (8 KB pages) */
    addl %fp@(-12),%d0
    addl %fp@(-20),%d0
    moveal %d0,%a0
    clrw %d3
    bset #2,%a0@(3)
    tstw %a2
    jbne EDISKPROTECT_6E
    bclr #2,%a0@(3)
EDISKPROTECT_6E:        /* pflusha (68040) */
    cmpib #4,CPUFlag
    jbne EDISKPROTECT_7A
    pflusha
    jbra EDISKPROTECT_84
EDISKPROTECT_7A:        /* (68030) */
    jsr @(0x6f4,%za0)@(0)	| 40886F6A
    .short  0xF000, 0x2400	| 40886F70 pflusha
EDISKPROTECT_84:        /* restore the mode */
    moveb %sp@+,%d0
    jbne EDISKPROTECT_8A
    _SwapMMUMode
EDISKPROTECT_8A:        /* restore sr, result */
    movew %sp@+,%d0
    movew %d0,%sr
    movew %d3,%d0
    unlk %fp
    moveml %sp@+,%d2-%d4/%a2
    rts
    .fill   0x78, 1, 0x00

/*
 SWAPICACHEPATCH: HWPriv 0: instruction cache on (a0 nonzero) or off; old state in a0
 (68030 and 68040 CACR bits).
*/
HWPRIVPATCH:
SWAPICACHEPATCH:
    cmpib #4,CPUFlag
    jbge HWPRIVPATCH_1E
    movec %cacr,%d0
    bfextu %d0,31,1,%d1
    bclr #0,%d0
    movel %a0,%d2
    jbeq HWPRIVPATCH_1C
    orib #9,%d0
HWPRIVPATCH_1C:         /* (68030) */
    jbra HWPRIVPATCH_38
HWPRIVPATCH_1E:         /* 68040: bit 15 */
    movec %cacr,%d0
    bfextu %d0,16,1,%d1
    bclr #15,%d0
    movel %a0,%d2
    jbeq HWPRIVPATCH_38
    jsr @(0x6f4,%za0)@(0)	| 4088702E
    bset #15,%d0
HWPRIVPATCH_38:         /* write CACR, result 0 */
    moveal %d1,%a0
    movec %d0,%cacr
    moveq #0,%d0
    rts

/* FLUSHICACHEPATCH: HWPriv 1: nothing (result 0). */
FLUSHICACHEPATCH:
    jsr @(0x6f4,%za0)@(0)	| 40887042
    moveq #0,%d0
    rts

/* SWAPDCACHEPATCH: HWPriv 2: data cache on or off (flushed before off on the 68040). */
SWAPDCACHEPATCH:
    cmpib #4,CPUFlag
    jbge SWAPDCACHEPATCH_1E
    movec %cacr,%d0
    bfextu %d0,23,1,%d1
    bclr #8,%d0
    movel %a0,%d2
    jbeq SWAPDCACHEPATCH_1C
    oriw #2304,%d0
SWAPDCACHEPATCH_1C:     /* (68030) */
    jbra SWAPDCACHEPATCH_36
SWAPDCACHEPATCH_1E:     /* 68040: bit 31 */
    movec %cacr,%d0
    bfextu %d0,0,1,%d1
    bset #31,%d0
    movel %a0,%d2
    jbne SWAPDCACHEPATCH_36
    nop
    cpusha %dc
    bclr #31,%d0
SWAPDCACHEPATCH_36:     /* write CACR, result 0 */
    moveal %d1,%a0
    movec %d0,%cacr
    moveq #0,%d0
    rts

/* FLUSHDCACHEPATCH: HWPriv 3: flush the data cache. */
FLUSHDCACHEPATCH:
    cmpib #4,CPUFlag
    jbge FLUSHDCACHEPATCH_16
    movec %cacr,%d0
    bset #11,%d0
    movec %d0,%cacr
    jbra FLUSHDCACHEPATCH_1A
FLUSHDCACHEPATCH_16:    /* 68040: cpusha dc */
    nop
    cpusha %dc
FLUSHDCACHEPATCH_1A:    /* result 0 */
    moveq #0,%d0
    rts

/* FLUSHCRANGEFORBM: BlockMove's return: flush the destination range, from the stack. */
FLUSHCRANGEFORBM:
    moveal %sp@+,%a0
    moveal %sp@+,%a1

/*
 FLUSHCRANGE: flush the caches over a0..a0+a1 (68040: line by line with cpushl or by
 page with cpushp, through ptestr for the physical page; everything above 3 KB; on a
 68030 the whole instruction cache).
*/
FLUSHCRANGE:
    cmpib #4,CPUFlag
    jblt FLUSHCRANGE_90
    lea %a1@(15),%a1
    movel %a1,%d1
    andiw #-16,%d1
    movew %sr,%d0
    btst #13,%d0
    jbne FLUSHCRANGE_20
    moveq #8,%d0
    _DebugUtil
FLUSHCRANGE_20:         /* big: everything */
    cmpil #3072,%d1
    jblt FLUSHCRANGE_2E
    nop
    cpusha %bc
    jbra FLUSHCRANGE_8A
FLUSHCRANGE_2E:         /* page by page */
    moveml %d3-%d5/%a0-%a1,%sp@-
    oriw #1792,%sr
    moveq #5,%d2
    movec %d2,%dfc
    movew #-12288,%d4
    movec %tc,%d2
    lsrw #2,%d2
    eorw %d2,%d4
    movew %d4,%d5
    notw %d5
FLUSHCRANGE_4C:         /* physical page of the logical address */
    moveal %a0,%a1
    ptestr %a1@
    movec %mmusr,%d3
    andw %d4,%d3
    movew %a1,%d2
    andw %d5,%d2
    orw %d2,%d3
    moveal %d3,%a1
    eorw %d5,%d2
    addqw #1,%d2
    subw %d2,%d1
    jbpl FLUSHCRANGE_68
    addw %d1,%d2
FLUSHCRANGE_68:         /* bytes in this page */
    addaw %d2,%a0
    asrw #4,%d2
    cmpiw #16,%d2
    jblt FLUSHCRANGE_78
    nop
    cpushp %bc,%a1@
    jbra FLUSHCRANGE_82
FLUSHCRANGE_78:         /* line by line */
    cpushl %bc,%a1@
    lea %a1@(16),%a1
    dbf %d2,FLUSHCRANGE_78
FLUSHCRANGE_82:         /* next page */
    tstw %d1
    jbgt FLUSHCRANGE_4C
    moveml %sp@+,%d3-%d5/%a0-%a1
FLUSHCRANGE_8A:         /* restore sr, 0 */
    movew %d0,%sr
    moveq #0,%d0
    rts
FLUSHCRANGE_90:         /* 68030: flush the instruction cache */
    movec %cacr,%d0
    bset #3,%d0
    movec %d0,%cacr
    moveq #0,%d0
    rts

/*
 WRITEPROTECTPROC / UNWRITEPROTECTPROC: _MemoryDispatch write protect: mark the pages
 of a page-aligned range (virtual memory page table at 0x1FF4) protected or not.
 Result: 0 or -50.
*/
WRITEPROTECTPROC:
    moveml %d1-%d2/%a0-%a2,%sp@-
    moveal 0x1ff4,%a2
    moveq #-50,%d0
    movel %a2@(4),%d2
    subql #1,%d2
    movel %a0,%d1
    andl %d2,%d1
    jbne WRITEPROTECTPROC_44
    movel %a1,%d1
    andl %d2,%d1
    jbne WRITEPROTECTPROC_44
    jbsr NEWLOCKMEMORYCONTIGUOUS_5E
    jbne WRITEPROTECTPROC_44
    moveq #3,%d0
    .short  0xA198	| 40887172 _HWPriv (flags 0x0100)
    moveq #1,%d0
    .short  0xA198	| 40887176 _HWPriv (flags 0x0100)
    jbsr NEWLOCKMEMORYCONTIGUOUS_182
    lea %a2@(0x1c,%d1:w:2),%a1
    moveq #4,%d0
WRITEPROTECTPROC_34:    /* each page */
    oriw #-32768,%a1@+
    jbsr NEWLOCKMEMORYCONTIGUOUS_9A
    addql #1,%d1
    subql #1,%d2
    jbhi WRITEPROTECTPROC_34
    moveq #0,%d0
WRITEPROTECTPROC_44:    /* return */
    moveml %sp@+,%d1-%d2/%a0-%a2
    rts

UNWRITEPROTECTPROC:     /* save registers */
    moveml %d1-%d2/%a0-%a2,%sp@-
    moveal 0x1ff4,%a2
    moveq #-50,%d0
    movel %a2@(4),%d2
    subql #1,%d2
    movel %a0,%d1
    andl %d2,%d1
    jbne UNWRITEPROTECTPROC_3C
    movel %a1,%d1
    andl %d2,%d1
    jbne UNWRITEPROTECTPROC_3C
    jbsr NEWLOCKMEMORYCONTIGUOUS_5E
    jbne UNWRITEPROTECTPROC_3C
    lea %a2@(0x1c,%d1:w:2),%a1
    moveq #0,%d0
UNWRITEPROTECTPROC_28:  /* each page */
    andiw #32767,%a1@+
    jbsr NEWLOCKMEMORYCONTIGUOUS_9A
    addql #1,%d1
    subql #1,%d2
    jbhi UNWRITEPROTECTPROC_28
    jbsr NEWLOCKMEMORYCONTIGUOUS_182
    moveq #0,%d0
UNWRITEPROTECTPROC_3C:  /* return */
    moveml %sp@+,%d1-%d2/%a0-%a2
    rts

/* NEWLOCKMEMORY: LockMemory under virtual memory: count up the lock count of each page. */
NEWLOCKMEMORY:
    moveml %d1-%d4/%a0-%a2,%sp@-
    moveal 0x1ff4,%a2
    jbsr NEWLOCKMEMORYCONTIGUOUS_5E
    jbne NEWLOCKMEMORY_2A
    subqw #4,%sp
    jbsr WAITFORSCSIDEVS_5E
NEWLOCKMEMORY_14:       /* each page */
    addqw #1,%a1@+
    jbsr NEWLOCKMEMORYCONTIGUOUS_FC
    addql #1,%d1
    subql #1,%d2
    jbhi NEWLOCKMEMORY_14
    jbsr NEWLOCKMEMORYCONTIGUOUS_182
    jbsr WAITFORSCSIDEVS_7C
    nop
NEWLOCKMEMORY_2A:       /* return */
    moveml %sp@+,%d1-%d4/%a0-%a2
    rts

/* NEWUNLOCKMEMORY: UnlockMemory: all pages must be locked (else -623), count down. */
NEWUNLOCKMEMORY:
    moveml %d1-%d4/%a0-%a2,%sp@-
    moveal 0x1ff4,%a2
    jbsr NEWLOCKMEMORYCONTIGUOUS_5E
    jbne NEWUNLOCKMEMORY_44
    lea %a2@(0x1c,%d1:w:2),%a1
    movel %d2,%d3
    movew #-623,%d0
NEWUNLOCKMEMORY_18:     /* check each page */
    tstw %a1@+
    jbeq NEWUNLOCKMEMORY_44
    subql #1,%d3
    jbhi NEWUNLOCKMEMORY_18
    lea %a2@(0x1c,%d1:w:2),%a1
    movel %d2,%d3
    moveq #0,%d0
    moveq #0,%d4
NEWUNLOCKMEMORY_2A:     /* count down */
    subqw #1,%a1@+
    jbne NEWUNLOCKMEMORY_34
    jbsr NEWLOCKMEMORYCONTIGUOUS_FC
    moveq #1,%d4
NEWUNLOCKMEMORY_34:     /* next */
    addql #1,%d1
    subql #1,%d3
    jbhi NEWUNLOCKMEMORY_2A
    tstl %d4
    jbeq NEWUNLOCKMEMORY_42
    jbsr NEWLOCKMEMORYCONTIGUOUS_182
NEWUNLOCKMEMORY_42:     /* flush the ATC, 0 */
    moveq #0,%d0
NEWUNLOCKMEMORY_44:     /* return */
    moveml %sp@+,%d1-%d4/%a0-%a2
    rts

/*
 NEWLOCKMEMORYCONTIGUOUS: LockMemoryContiguous: lock the range if it is physically
 contiguous (else -622).
*/
NEWLOCKMEMORYCONTIGUOUS:
    moveml %d1-%d4/%a0-%a3,%sp@-
    moveal 0x1ff4,%a2
    bsrw NEWLOCKMEMORYCONTIGUOUS_5E
    jbne NEWLOCKMEMORYCONTIGUOUS_52
    moveal %a0,%a3
    moveml %d1/%a1-%a2,%sp@-
    jbsr GETREALPROC
    moveml %sp@+,%d1/%a1-%a2
    exg %a0,%a3
    addal %a1,%a0
    subql #1,%a0
    moveml %d1/%a1-%a2,%sp@-
    jbsr GETREALPROC
    moveml %sp@+,%d1/%a1-%a2
    subal %a3,%a0
    addql #1,%a0
    cmpal %a1,%a0
    jbne NEWLOCKMEMORYCONTIGUOUS_58
    subqw #4,%sp
    jbsr WAITFORSCSIDEVS_5E
NEWLOCKMEMORYCONTIGUOUS_3C:  /* lock each page */
    addqw #1,%a1@+
    jbsr NEWLOCKMEMORYCONTIGUOUS_FC
    addql #1,%d1
    subql #1,%d2
    jbhi NEWLOCKMEMORYCONTIGUOUS_3C
    jbsr NEWLOCKMEMORYCONTIGUOUS_182
    jbsr WAITFORSCSIDEVS_7C
    nop
NEWLOCKMEMORYCONTIGUOUS_52:  /* return */
    moveml %sp@+,%d1-%d4/%a0-%a3
    rts
NEWLOCKMEMORYCONTIGUOUS_58:  /* not contiguous: -622 */
    movew #-622,%d0
    jbra NEWLOCKMEMORYCONTIGUOUS_52

NEWLOCKMEMORYCONTIGUOUS_5E:  /* range a0, a1 to page numbers d1, count d2 (below the RAM end at 0x1EF4). Result 0 or -50 */
    moveml %a1-%a2,%sp@-
    movel %a0,%d0
    tstb MMU32Bit
    jbne NEWLOCKMEMORYCONTIGUOUS_6C
    _StripAddress
NEWLOCKMEMORYCONTIGUOUS_6C:  /* count 0 or past the RAM: -50 */
    moveal %d0,%a0
    cmpaw #0,%a1
    jbeq NEWLOCKMEMORYCONTIGUOUS_96
    movel %d0,%d1
    movel %d0,%d2
    addl %a1,%d2
    subql #1,%d2
    cmpl 0x1ef4,%d2
    jbcc NEWLOCKMEMORYCONTIGUOUS_96
    movel %a2@(8),%d0
    lsrl %d0,%d1
    lsrl %d0,%d2
    subl %d1,%d2
    addql #1,%d2
    moveq #0,%d0
NEWLOCKMEMORYCONTIGUOUS_90:  /* return */
    moveml %sp@+,%a1-%a2
    rts
NEWLOCKMEMORYCONTIGUOUS_96:  /* -50 */
    moveq #-50,%d0
    jbra NEWLOCKMEMORYCONTIGUOUS_90

NEWLOCKMEMORYCONTIGUOUS_9A:  /* set the page's write-protect state in its descriptors (24 and 32-bit tables) */
    cmpib #3,MMUType
    bcsw NEWLOCKMEMORYCONTIGUOUS_FA
    moveml %d0-%d4/%a0-%a1,%sp@-
    movel %d0,%d4
    cmpl %a2@(12),%d1
    scs %d3
    movel %a2@(8),%d0
    asll %d0,%d1
    moveq #0,%d0
    _SwapMMUMode
    movel %d0,%d2
    moveal %d1,%a0
    moveml %d1/%a1-%a2,%sp@-
    jbsr GETPAGEDESCPROC
    moveml %sp@+,%d1/%a1-%a2
    moveal %a0,%a1
    moveq #1,%d0
    _SwapMMUMode
    moveal %d1,%a0
    moveml %d1/%a1-%a2,%sp@-
    jbsr GETPAGEDESCPROC
    moveml %sp@+,%d1/%a1-%a2
    bclr #2,%a0@(3)
    orl %d4,%a0@
    tstb %d3
    jbeq NEWLOCKMEMORYCONTIGUOUS_F2
    bclr #2,%a1@(3)
    orl %d4,%a1@
NEWLOCKMEMORYCONTIGUOUS_F2:  /* (both tables) */
    movel %d2,%d0
    _SwapMMUMode
    moveml %sp@+,%d0-%d4/%a0-%a1
NEWLOCKMEMORYCONTIGUOUS_FA:  /* return */
    rts

NEWLOCKMEMORYCONTIGUOUS_FC:  /* set the page's cache mode in its descriptors (locked pages non-cached... d4) */
    cmpib #3,MMUType
    bcsw NEWLOCKMEMORYCONTIGUOUS_152
    moveml %d0-%d4/%a0-%a1,%sp@-
    movel %d0,%d4
    cmpl %a2@(12),%d1
    scs %d3
    movel %a2@(8),%d0
    asll %d0,%d1
    moveq #0,%d0
    _SwapMMUMode
    movel %d0,%d2
    moveal %d1,%a0
    moveml %d1/%a1-%a2,%sp@-
    jbsr GETPAGEDESCPROC
    moveml %sp@+,%d1/%a1-%a2
    moveal %a0,%a1
    moveq #1,%d0
    _SwapMMUMode
    moveal %d1,%a0
    moveml %d1/%a1-%a2,%sp@-
    jbsr GETPAGEDESCPROC
    moveml %sp@+,%d1/%a1-%a2
    jbsr NEWLOCKMEMORYCONTIGUOUS_154
    tstb %d3
    jbeq NEWLOCKMEMORYCONTIGUOUS_14A
    moveal %a1,%a0
    jbsr NEWLOCKMEMORYCONTIGUOUS_154
NEWLOCKMEMORYCONTIGUOUS_14A:  /* (both tables) */
    movel %d2,%d0
    _SwapMMUMode
    moveml %sp@+,%d0-%d4/%a0-%a1
NEWLOCKMEMORYCONTIGUOUS_152:  /* return */
    rts

NEWLOCKMEMORYCONTIGUOUS_154:  /* cache mode bits of the descriptor at a0 */
    moveml %d0-%d1,%sp@-
    tstb %d4
    jbeq NEWLOCKMEMORYCONTIGUOUS_16A
    movel %a0@,%d1
    bset #6,%d1
    bclr #5,%d1
    movel %d1,%a0@
    jbra NEWLOCKMEMORYCONTIGUOUS_17C
NEWLOCKMEMORYCONTIGUOUS_16A:  /* back to the default cache mode (from 0xB72) */
    moveq #0,%d1
    bfextu 0xb72,24,1,%d1
    lsll #5,%d1
    orl %a0@,%d1
    bclr #6,%d1
    movel %d1,%a0@
NEWLOCKMEMORYCONTIGUOUS_17C:  /* return */
    moveml %sp@+,%d0-%d1
    rts

NEWLOCKMEMORYCONTIGUOUS_182:  /* 68040 MMU: pflusha */
    cmpib #3,MMUType
    jbcs NEWLOCKMEMORYCONTIGUOUS_196
    cmpib #5,MMUType
    jbeq NEWLOCKMEMORYCONTIGUOUS_198
    .short  0xF000, 0x2400	| 408873E6 pflusha
NEWLOCKMEMORYCONTIGUOUS_196:  /* return */
    rts
NEWLOCKMEMORYCONTIGUOUS_198:  /* pflusha */
    pflusha
    rts

/*
 INITMEMORYDISPATCH: set up the page table used by _MemoryDispatch (pointer at 0x1FF4):
 page size (4 or 8 KB on the 68040), number of pages of RAM (0x1EF8), the part below
 8 MB.
*/
INITMEMORYDISPATCH:
    linkw %fp,#-4
    moveml %d0-%d4/%a0-%a3,%sp@-
    clrl 0x1ff4
    moveb CPUFlag,%d1
    moveq #0,%d2
    movel 0x1ef8,%d3
    cmpib #4,%d1
    jbne INITMEMORYDISPATCH_2C
    moveq #12,%d1
    movec %tc,%d0
    btst #14,%d0
    jbeq INITMEMORYDISPATCH_46
    addql #1,%d1
    jbra INITMEMORYDISPATCH_46
INITMEMORYDISPATCH_2C:  /* 68030 with an MMU */
    cmpib #2,%d1
    jblt INITMEMORYDISPATCH_86
    cmpib #3,MMUType
    jblt INITMEMORYDISPATCH_86
    .short  0xF02E, 0x4200, 0xFFFC	| 4088742A pmove %tc,%fp@(-4)
    bfextu %fp@(-4),8,4,%d1
INITMEMORYDISPATCH_46:  /* page shift, table size (2 bytes per page + 28) */
    bset %d1,%d2
    lsrl %d1,%d3
    movel %d3,%d4
    movel %d3,%d0
    asll #1,%d0
    addiw #28,%d0
    movel %d0,%d3
    .short  0xA71E	| 40887446 _NewPtr (flags 0x0700)
    jbne INITMEMORYDISPATCH_86
    movel %a0,0x1ff4
    movel %d3,%a0@
    movel %d2,%a0@(4)
    movel %d1,%a0@(8)
    movel %d4,%a0@(16)
    movel %d4,%a0@(24)
    movel #8388608,%d3
    cmpl 0x1ef8,%d3
    jbcs INITMEMORYDISPATCH_80
    movel 0x1ef8,%d3
INITMEMORYDISPATCH_80:  /* pages below 8 MB (24-bit tables) */
    lsrl %d1,%d3
    movel %d3,%a0@(12)
INITMEMORYDISPATCH_86:  /* return */
    moveml %sp@+,%d0-%d4/%a0-%a3
    unlk %fp
    rts

/*
 WAITFORSCSIDEVS: wait (up to the start-up timeout, default 20 s) until the SCSI drivers
 of the IDs in the mask a0 are loaded. Out: a0 = 0, or -1 on timeout.
*/
WAITFORSCSIDEVS:
    moveml %d2-%d4,%sp@-
    movel %a0,%d1
    movel %d1,%d2
    swap %d2
    orb %d1,%d2
    subqw #2,%sp
    moveal %sp,%a0
    _GetOSDefault
    subal %a0,%a0
    _InternalWait
    jbne WAITFORSCSIDEVS_1A
    moveq #20,%d0
WAITFORSCSIDEVS_1A:     /* timeout in ticks */
    muluw #60,%d0
    movel %d0,%d4
    movew %sp@+,%d3
    swap %d3
WAITFORSCSIDEVS_24:     /* load the drivers, all there? */
    movel %d2,%d0
    jbsr SCSIBOOTS
    moveb SCSIDrvrs,%d0
    andb %d1,%d0
    cmpb %d1,%d0
    jbeq WAITFORSCSIDEVS_56
    movel Ticks,%d0
    cmpl %d4,%d0
    bhiw WAITFORSCSIDEVS_50
    addil #15,%d0
WAITFORSCSIDEVS_46:     /* wait 15 ticks */
    cmpl Ticks,%d0
    jbhi WAITFORSCSIDEVS_46
    cmpl %d4,%d0
    jbcs WAITFORSCSIDEVS_24
WAITFORSCSIDEVS_50:     /* timed out */
    moveaw #-1,%a0
    jbra WAITFORSCSIDEVS_58
WAITFORSCSIDEVS_56:     /* all loaded */
    subal %a0,%a0
WAITFORSCSIDEVS_58:     /* return */
    moveml %sp@+,%d2-%d4
    rts

WAITFORSCSIDEVS_5E:     /* lock-count helpers: a1 = the page's lock count (page table +28) */
    lea %a2@(0x1c,%d1:w:2),%a1
    movel %a0,%d0
    moveml %d0-%d2,%sp@-
    moveq #2,%d0
    subal %a0,%a0
    .short  0xA198	| 408874EA _HWPriv (flags 0x0100)
    moveml %sp@+,%d0-%d2
    movel %a0,%sp@(4)
    moveal %d0,%a0
    moveq #1,%d0
    rts

WAITFORSCSIDEVS_7C:     /* (end of a lock operation) */
    movel %a0,%d0
    moveal %sp@(4),%a0
    moveml %d0-%d2,%sp@-
    moveq #2,%d0
    .short  0xA198	| 40887506 _HWPriv (flags 0x0100)
    moveml %sp@+,%d0-%d2
    moveal %d0,%a0
    movel %sp@+,%sp@
    moveq #0,%d0
    rts
    .fill   0x2EC, 1, 0x00

/*
 V24HLOCKPATCH / V32HLOCKPATCH: HLock: set the lock bit (24-bit: in the master pointer,
 32-bit: in the block header), result 0, or nilHandleErr (-109).
*/
MEMORYMGRPATCH:
V24HLOCKPATCH:
    beqw V32HLOCKPATCH_1C
    bset #7,%a1@
    braw V32HLOCKPATCH_A

V32HLOCKPATCH:          /* from here: beqw V32HLOCKPATCH_1C */
    beqw V32HLOCKPATCH_1C
    bset #7,%a0@(-11)
V32HLOCKPATCH_A:        /* (68040) */
    cmpib #4,CPUFlag
    jbne V32HLOCKPATCH_18
    jsr @(0x6f4,%za0)@(0)	| 4088781E
V32HLOCKPATCH_18:       /* 0 */
    moveq #0,%d0
    jbra V32HLOCKPATCH_1E
V32HLOCKPATCH_1C:       /* -109 */
    moveq #-109,%d0
V32HLOCKPATCH_1E:       /* return through the vector at 0x1FE8 */
    movel 0x1fe8,%sp@-
    rts

/*
 ZONECHECKPATCH: during heap checks, a bus error handler that returns (68040: the
 instruction is skipped).
*/
ZONECHECKPATCH:
    moveal BusErrorVector,%a2
    biglea HEAPGUTS, a3
    cmpib #4,CPUFlag
    jbne ZONECHECKPATCH_1A
    lea %pc@(DEREFHANDLEPATCH_2A),%a3
ZONECHECKPATCH_1A:      /* install it */
    movel %a3,BusErrorVector
    rts

/* DEREFHANDLEPATCH: the same while dereferencing a handle (result -1 on a bus error). */
DEREFHANDLEPATCH:
    moveal BusErrorVector,%a2
    biglea DHBUSERRHANDLER, a3
    cmpib #4,CPUFlag
    jbne DEREFHANDLEPATCH_1A
    lea %pc@(DEREFHANDLEPATCH_20),%a3
DEREFHANDLEPATCH_1A:    /* install it */
    movel %a3,BusErrorVector
    rts
DEREFHANDLEPATCH_20:    /* 68040 bus error: a0 = -1, skip 2 bytes */
    moveq #-1,%d0
    moveal %d0,%a0
    addql #2,%sp@(2)
    rte
DEREFHANDLEPATCH_2A:    /* 68040 bus error: d0 = 0, skip 4 bytes */
    subl %d0,%d0
    addql #4,%sp@(2)
    rte

/*
 A24MAXLIMITPATCH / A32MAXLIMITPATCH: the highest heap limit below the stack (MinStack
 kept): 16-byte aligned on the 68040 (in 24-bit mode only when 0xB78 says so), else 4.
*/
A24MAXLIMITPATCH:
    andiw #-4,%d2
    cmpib #4,CPUFlag
    jblt A24MAXLIMITPATCH_16
    tstl 0xb78
    jbpl A24MAXLIMITPATCH_16
    andiw #-16,%d2
A24MAXLIMITPATCH_16:    /* below the stack */
    movel %sp,%d1
    andl Lo3Bytes,%d1
    subl MinStack,%d1
    andiw #-4,%d1
    cmpib #4,CPUFlag
    jblt A24MAXLIMITPATCH_36
    tstl 0xb78
    jbpl A24MAXLIMITPATCH_36
    andiw #-16,%d1
A24MAXLIMITPATCH_36:    /* the lower of the two */
    cmpl %d2,%d1
    jbcs A24MAXLIMITPATCH_3C
    movel %d2,%d1
A24MAXLIMITPATCH_3C:    /* return */
    rts

A32MAXLIMITPATCH:       /* from here: andiw #-4,%d2 */
    andiw #-4,%d2
    cmpib #4,CPUFlag
    jblt A32MAXLIMITPATCH_10
    andiw #-16,%d2
A32MAXLIMITPATCH_10:    /* below the stack */
    movel %sp,%d1
    subl MinStack,%d1
    andiw #-4,%d1
    cmpib #4,CPUFlag
    jblt A32MAXLIMITPATCH_26
    andiw #-16,%d1
A32MAXLIMITPATCH_26:    /* the lower of the two */
    cmpl %d2,%d1
    jbcs A32MAXLIMITPATCH_2C
    movel %d2,%d1
A32MAXLIMITPATCH_2C:    /* return */
    rts

/*
 A24ACTUALSPATCH / A32ACTUALSPATCH: block size with its header for a requested size:
 16-byte aligned on the 68040 (minimum 16), else 4 (minimum 12 or 16).
*/
A24ACTUALSPATCH:
    cmpib #4,CPUFlag
    jblt A24ACTUALSPATCH_24
    tstl 0xb78
    jbpl A24ACTUALSPATCH_24
    addil #23,%d0
    andiw #-16,%d0
    cmpil #16,%d0
    jbcc A24ACTUALSPATCH_36
    moveq #16,%d0
    jbra A24ACTUALSPATCH_36
A24ACTUALSPATCH_24:     /* 4-byte alignment */
    addql #8,%d0
    addql #3,%d0
    andiw #-4,%d0
    cmpil #12,%d0
    jbcc A24ACTUALSPATCH_36
    moveq #12,%d0
A24ACTUALSPATCH_36:     /* return */
    rts

A32ACTUALSPATCH:        /* loop: cmpi */
    cmpib #4,CPUFlag
    jblt A32ACTUALSPATCH_1E
    addil #27,%d0
    andiw #-16,%d0
    cmpil #16,%d0
    jbcc A32ACTUALSPATCH_34
    moveq #16,%d0
    jbra A32ACTUALSPATCH_34
A32ACTUALSPATCH_1E:     /* 4-byte alignment */
    addil #12,%d0
    addql #3,%d0
    andiw #-4,%d0
    cmpil #16,%d0
    jbcc A32ACTUALSPATCH_34
    moveq #16,%d0
A32ACTUALSPATCH_34:     /* return */
    rts

/*
 A24SETSIZEPATCH / A32SETSIZEPATCH: new block size for SetPtrSize/SetHandleSize, keeping
 the 16-byte alignment of the next block on the 68040.
*/
A24SETSIZEPATCH:
    movel %d0,%d1
    lea %fp@(60),%a2
    cmpal %a0,%a2
    jbne A24SETSIZEPATCH_32
    cmpib #4,CPUFlag
    jblt A24SETSIZEPATCH_32
    tstl 0xb78
    jbpl A24SETSIZEPATCH_32
    addql #8,%d0
    movel %a2,%d2
    addl %d0,%d2
    andil #15,%d2
    jbeq A24SETSIZEPATCH_36
    notb %d2
    andib #15,%d2
    addqb #1,%d2
    addl %d2,%d0
    jbra A24SETSIZEPATCH_36
A24SETSIZEPATCH_32:     /* normal rounding */
    jbsr A24ACTUALSPATCH
A24SETSIZEPATCH_36:     /* d3 = the size */
    movel %d0,%d3
    rts

A32SETSIZEPATCH:        /* set %d1 */
    movel %d0,%d1
    lea %fp@(64),%a2
    cmpal %a0,%a2
    jbne A32SETSIZEPATCH_30
    cmpib #4,CPUFlag
    jblt A32SETSIZEPATCH_30
    addil #12,%d0
    movel %a2,%d2
    addl %d0,%d2
    andil #15,%d2
    jbeq A32SETSIZEPATCH_34
    notb %d2
    andib #15,%d2
    addqb #1,%d2
    addl %d2,%d0
    jbra A32SETSIZEPATCH_34
A32SETSIZEPATCH_30:     /* normal rounding */
    jbsr A32ACTUALSPATCH
A32SETSIZEPATCH_34:     /* d3 = the size */
    movel %d0,%d3
    rts

/* SETAPPLBASEPATCH: application heap base aligned to 16 bytes on the 68040, else 4. */
SETAPPLBASEPATCH:
    cmpib #4,CPUFlag
    jblt SETAPPLBASEPATCH_14
    addil #15,%d0
    andiw #-16,%d0
    rts
SETAPPLBASEPATCH_14:    /* 4 bytes */
    addql #3,%d0
    andiw #-4,%d0
    rts

/*
 INIT24ZONEALIGN / INIT32ZONEALIGN: InitZone: align the first block of the zone to 16
 bytes on the 68040 (else to 4), by shrinking the free block and moving the trailer.
*/
INIT24ZONEALIGN:
    cmpib #4,CPUFlag
    jblt INIT24ZONEALIGN_48
    tstl 0xb78
    jbpl INIT24ZONEALIGN_48
    lea %fp@(52),%a0
    movel %a0,%d0
    addql #8,%d0
    movel %a0@,%d1
    andl Lo3Bytes,%d1
    addl %d1,%d0
    andil #15,%d0
    jbeq INIT24ZONEALIGN_72
    notb %d0
    andib #15,%d0
    addqb #1,%d0
    subl %d0,%fp@(12)
    moveal %a0,%a1
    addal %d1,%a1
    addb %d0,%a0@
    addl %d0,%a0@
    subl %d0,%a1@
    movel %a1@,%a1@(0x0,%d0:w)
    addal %d0,%a1
    movel %a1,%fp@(48)
    jbra INIT24ZONEALIGN_72
INIT24ZONEALIGN_48:     /* 4-byte alignment */
    movel %fp,%d0
    btst #1,%d0
    jbeq INIT24ZONEALIGN_72
    subql #2,%fp@(12)
    lea %fp@(52),%a0
    moveal %a0,%a1
    movel %a0@,%d0
    andl Lo3Bytes,%d0
    addal %d0,%a1
    addqb #2,%a0@
    addql #2,%a0@
    subql #2,%a1@
    movel %a1@,%a1@(2)
    addql #2,%a1
    movel %a1,%fp@(48)
INIT24ZONEALIGN_72:     /* return */
    rts

INIT32ZONEALIGN:        /* test #4,CPUFlag */
    cmpib #4,CPUFlag
    jblt INIT32ZONEALIGN_4E
    lea %fp@(52),%a0
    movel %a0,%d0
    addil #12,%d0
    movel %a0@(4),%d1
    addl %d1,%d0
    andil #15,%d0
    jbeq INIT32ZONEALIGN_82
    notb %d0
    andib #15,%d0
    addqb #1,%d0
    subl %d0,%fp@(12)
    moveal %a0,%a1
    addal %d1,%a1
    addb %d0,%a0@(3)
    addl %d0,%a0@(4)
    subl %d0,%a1@(4)
    movel %a1@(4),%a1@(0x4,%d0:w)
    addal %d0,%a1
    clrl %a1@
    movel %a1,%fp@(48)
    jbra INIT32ZONEALIGN_82
INIT32ZONEALIGN_4E:     /* 4-byte alignment */
    movel %fp,%d0
    btst #1,%d0
    jbeq INIT32ZONEALIGN_82
    subql #2,%fp@(12)
    lea %fp@(52),%a0
    moveal %a0,%a1
    movel %a0@(4),%d0
    addal %d0,%a1
    addqb #2,%a0@(3)
    addql #2,%a0@(4)
    subql #2,%a1@(4)
    movel %a1@(4),%a1@(6)
    movel %a1@,%a1@(2)
    addql #2,%a1
    movel %a1,%fp@(48)
INIT32ZONEALIGN_82:     /* return */
    rts

/*
 ALIGN24TRAILER / ALIGN32TRAILER: the zone trailer address aligned (16 bytes + 4 on
 the 68040).
*/
ALIGN24TRAILER:
    cmpib #4,CPUFlag
    jblt ALIGN24TRAILER_1A
    tstl 0xb78
    jbpl ALIGN24TRAILER_1A
    subql #4,%d1
    andiw #-16,%d1
    addql #4,%d1
    moveal %d1,%a3
    rts
ALIGN24TRAILER_1A:      /* 4 bytes */
    andiw #-4,%d1
    moveal %d1,%a3
    rts

ALIGN32TRAILER:         /* test #4,CPUFlag */
    cmpib #4,CPUFlag
    jblt ALIGN32TRAILER_14
    subql #4,%d1
    andiw #-16,%d1
    addql #4,%d1
    moveal %d1,%a3
    rts
ALIGN32TRAILER_14:      /* 4 bytes */
    andiw #-4,%d1
    moveal %d1,%a3
    rts

/*
 V24CMGUTSPATCH / V32CMGUTSPATCH: compact the heap, result size aligned to 16 bytes on
 the 68040.
*/
V24CMGUTSPATCH:
    jbsr A24COMPACTHP
    moveb %d2,%a1@
    cmpib #4,CPUFlag
    jblt V24CMGUTSPATCH_1A
    tstl 0xb78
    jbpl V24CMGUTSPATCH_1A
    andiw #-16,%d1
V24CMGUTSPATCH_1A:      /* return */
    rts

V32CMGUTSPATCH:         /* call A32COMPACTHP */
    jbsr A32COMPACTHP
    moveb %d2,%a1@
    cmpib #4,CPUFlag
    jblt V32CMGUTSPATCH_14
    andiw #-16,%d1
V32CMGUTSPATCH_14:      /* return */
    rts

/* V24MAXMEMPATCH / V32MAXMEMPATCH: MaxMem: compact and purge, aligned result. */
V24MAXMEMPATCH:
    moveq #0,%d2
    jbsr A24BKCOMPACTS
    cmpib #4,CPUFlag
    jblt V24MAXMEMPATCH_1A
    tstl 0xb78
    jbpl V24MAXMEMPATCH_1A
    andiw #-16,%d1
V24MAXMEMPATCH_1A:      /* return */
    rts

V32MAXMEMPATCH:         /* clear %d2 */
    moveq #0,%d2
    jbsr A32BKCOMPACTS
    cmpib #4,CPUFlag
    jblt V32MAXMEMPATCH_14
    andiw #-16,%d1
V32MAXMEMPATCH_14:      /* return */
    rts

/*
 V24PURGESPACEPATCH / V32PURGESPACEPATCH: PurgeSpace: total and contiguous sizes,
 aligned.
*/
V24PURGESPACEPATCH:
    addl %d1,%d0
    cmpal %d1,%a0
    jbcc V24PURGESPACEPATCH_8
    moveal %d1,%a0
V24PURGESPACEPATCH_8:   /* (largest) */
    cmpib #4,CPUFlag
    jblt V24PURGESPACEPATCH_1E
    tstl 0xb78
    jbpl V24PURGESPACEPATCH_1E
    movel %a0,%d1
    andiw #-16,%d1
    moveal %d1,%a0
V24PURGESPACEPATCH_1E:  /* return */
    rts

V32PURGESPACEPATCH:     /* from here: addl %d1,%d0 */
    addl %d1,%d0
    cmpal %d1,%a0
    jbcc V32PURGESPACEPATCH_8
    moveal %d1,%a0
V32PURGESPACEPATCH_8:   /* (largest) */
    cmpib #4,CPUFlag
    jblt V32PURGESPACEPATCH_18
    movel %a0,%d1
    andiw #-16,%d1
    moveal %d1,%a0
V32PURGESPACEPATCH_18:  /* return */
    rts

/*
 V24MAXAPPLPATCH / V32MAXAPPLPATCH: MaxApplZone: the new zone end aligned so the last
 block stays 16-byte aligned on the 68040.
*/
V24MAXAPPLPATCH:
    cmpib #4,CPUFlag
    jblt V32MAXAPPLPATCH_36
    tstl 0xb78
V24MAXAPPLPATCH_C:      /* (68040, aligned 24-bit heaps) */
    bplw V32MAXAPPLPATCH_36
    moveq #16,%d1
    subqw #8,%d1
    movel #8,%sp@-
    braw V32MAXAPPLPATCH_18

V32MAXAPPLPATCH:        /* test #4,CPUFlag */
    cmpib #4,CPUFlag
    jblt V32MAXAPPLPATCH_36
    moveq #16,%d1
    subiw #12,%d1
    movel #12,%sp@-
    jbra V32MAXAPPLPATCH_18

V32MAXAPPLPATCH_18:     /* align the end unless it is HeapEnd or already aligned */
    cmpl HeapEnd,%d0
    jbeq V32MAXAPPLPATCH_32
    movel %d0,%d2
    andiw #15,%d2
    cmpw %d1,%d2
    jbeq V32MAXAPPLPATCH_32
    movel %sp@+,%d1
    andiw #-16,%d0
    subl %d1,%d0
    jbra V32MAXAPPLPATCH_3A
V32MAXAPPLPATCH_32:     /* (no change) */
    tstl %sp@+
    jbra V32MAXAPPLPATCH_3A
V32MAXAPPLPATCH_36:     /* 4-byte alignment */
    andiw #-4,%d0
V32MAXAPPLPATCH_3A:     /* d1 = the result */
    movel %d0,%d1
    rts
    .fill   0x3E6, 1, 0x00
