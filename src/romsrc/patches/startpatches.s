/*
 patches/startpatches.s - start-up patches (CPU, caches, MMU, SCSI timing, system error, memory manager, ...)
 From STARTINITPATCH (0x40804000). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple.
 Most routines here run before RAM is set up and return through fp (or a5/a2).
*/

/*
 WHICHCPUPATCH: identify the CPU from the cache control register: 68040 if CACR bit 31
 (data cache enable) can be set (d7 = 4, caches invalidated); otherwise d7 = 2 or 3
 from which 68020/68030 CACR bits exist.
*/
STARTINITPATCH:
WHICHCPUPATCH:
    subl %d7,%d7
STARTINITPATCH_2:       /* try the 68040 data cache bit */
    bset #31,%d7
    movec %d7,%cacr
    movec %cacr,%d7
    bclr #31,%d7
    movec %d7,%cacr
    jbeq STARTINITPATCH_1E
    cinva %bc
    moveq #4,%d7
    rts
STARTINITPATCH_1E:      /* not a 68040: 68030 cache bits? */
    movew #10249,%d7
    movec %d7,%cacr
    movec %cacr,%d7
    lslw #3,%d7
    moveq #1,%d7
    addxl %d7,%d7
    rts

/*
 ENABLECACHESPATCH: turn the caches on: 68040 instruction and data caches (0x80008000),
 else the 68030 bits (0x3919).
*/
ENABLECACHESPATCH:
    cmpib #4,CPUFlag
    jbne ENABLECACHESPATCH_14
    movel #-2147450880,%d0
    movec %d0,%cacr
    jbra ENABLECACHESPATCH_1E
ENABLECACHESPATCH_14:   /* 68020/68030 */
    movel #14617,%d0
    movec %d0,%cacr
ENABLECACHESPATCH_1E:   /* return */
    rts

/*
 DISABLEMMUPATCH: at reset: caches and MMU off. On a 68040: invalidate the caches, TC
 off, transparent translation for 0x80000000-0xFFFFFFFF and the I/O space
 (DTT0 0x807FC040, DTT1 0x500FC040, cache inhibited). On a 68030: MMU off with pmove
. Returns through fp.
*/
early_cpu_detect:
DISABLEMMUPATCH:
    subl %d0,%d0
    bset #31,%d0
    movec %d0,%cacr
    movec %cacr,%d0
    btst #31,%d0
    jbeq DISABLEMMUPATCH_36
    cinva %bc
    subl %d0,%d0
    movec %d0,%cacr
    movec %d0,%tc
    movel #-2139111360,%d0
    movec %d0,%dtt0
    movel #1343209536,%d0
    movec %d0,%dtt1
    jbra DISABLEMMUPATCH_50
DISABLEMMUPATCH_36:     /* 68030 or older: is there a CACR at all? */
    movel #8192,%d0
    movec %d0,%cacr
    movec %cacr,%d0
    tstl %d0
    jbeq DISABLEMMUPATCH_50
    lea %pc@(DISABLEMMUPATCH_52),%a0
    .short  0xF010	| 4080409E

DISABLEMMUPATCH_4E:     /* (raw words: pmove to TC) */
    negxb %d0
DISABLEMMUPATCH_50:     /* return through fp */
    jmp %fp@
DISABLEMMUPATCH_52:     /* TC value 0 (MMU off) */
    .long   0x00000000	| 408040A4

/*
 SWITCHMMUPATCH: the MMU switch of the header (hdr_switch_mmu) for the
 68040: caches off and flushed, load URP/SRP and TC from the tables at a0, caches back
 on, continue at a1. The 68030 path uses pmove.
*/
SWITCHMMUPATCH:
    movec %cacr,%d1
    subl %d0,%d0
    bset #31,%d0
    movec %d0,%cacr
    movec %cacr,%d0
    bclr #31,%d0
    beqs SWITCHMMUPATCH_30
    movec %d0,%cacr
    movec %d0,%tc
    pflusha	| 408040C8
    moveal %a0@,%a2
    movel %a0@(8),%d0
    movec %d0,%tc
    .short  0xF4F8	| 408040D4 cpusha bc
    bras SWITCHMMUPATCH_58
SWITCHMMUPATCH_30:
    movec %cacr,%d0
    movew %d0,%d1
    andiw #-258,%d0
    movec %d0,%cacr
    lea %pc@(DISABLEMMUPATCH_52),%a2
    .short  0xF012, 0x4000	| 408040EA pmove %a2@,%tc
    .short  0xF000, 0x2400	| 408040EE pflusha
    .short  0xF010, 0x4C00	| 408040F2 pmove %a0@,%crp
    .short  0xF028, 0x4000, 0x0008	| 408040F6 pmove %a0@(8),%tc
    oriw #2056,%d1
SWITCHMMUPATCH_58:
    movec %d1,%cacr
    jmp %a1@

/*
 SETUPMISCSCSI: more hardware base addresses from the decoder's table (d0 = bases valid
 flags): bit 24 the SCSI 96 (53C96) base into ToolDispTable (0xB24 is reused), bit 25
 a second one into 0x1FF0; otherwise SCSIHsk/SCSIDMA copied from each other when
 only one of them exists.
*/
SETUPMISCSCSI:
    btst #24,%d0
    jbeq SETUPMISCSCSI_12
    movew #24,%d3
    lslw #2,%d3
    movel %a0@(0x0,%d3:w),ToolDispTable
SETUPMISCSCSI_12:       /* bit 25: second SCSI 96 */
    btst #25,%d0
    jbeq SETUPMISCSCSI_26
    movew #25,%d3
    lslw #2,%d3
    movel %a0@(0x0,%d3:w),0x1ff0
    jbra SETUPMISCSCSI_3E
SETUPMISCSCSI_26:       /* no SCSI DMA: use the handshake address */
    btst #9,%d0
    jbne SETUPMISCSCSI_32
    movel SCSIHsk,SCSIDMA
SETUPMISCSCSI_32:       /* no handshake: use the DMA address */
    btst #10,%d0
    jbne SETUPMISCSCSI_3E
    movel SCSIDMA,SCSIHsk
SETUPMISCSCSI_3E:       /* return */
    rts

/*
 SETUPSCSITIME: timing routine of SETUPTIMEK for TimeSCSIDB: a dbra loop reading the
 SCSI chip (53C96 status at +64, or the older chip), counted until the timer interrupt.
*/
SETUPSCSITIME:
    moveal ToolDispTable,%a0
    btst #0,0xdd0
    jbeq SETUPSCSITIME_20
    moveb %d1,%a1@(4096)
    moveb %d2,%a1@(4608)
SETUPSCSITIME_14:       /* loop (53C96) */
    btst #0,%a0@(64)
    dbf %d0,SETUPSCSITIME_14
    jmp %a2@
SETUPSCSITIME_20:       /* older SCSI chip */
    moveb %d1,%a1@(4096)
    moveb %d2,%a1@(4608)
SETUPSCSITIME_28:       /* loop */
    btst #0,%a0@(64)
    dbf %d0,SETUPSCSITIME_28
    jmp %a2@

/*
 SYSERRINITPATCH: system error handler set-up, then on a 68040 install the Motorola
 floating point software package (INSTALLFPSP).
*/
SYSERRINITPATCH:
    lea %pc@(SYSERRINITPATCH_8),%fp
    jmp %pc@(SYSERRINIT)
SYSERRINITPATCH_8:      /* 68040? */
    cmpib #4,CPUFlag
    jblt SYSERRINITPATCH_16
    jbsr INSTALLFPSP
SYSERRINITPATCH_16:     /* return */
    rts

/* INITMEMMGRPATCH: Memory Manager, then the privileged instruction trap (INSTALLPRIVTRAP). */
INITMEMMGRPATCH:
    jbsr INITMEMMGR
    jbsr INSTALLPRIVTRAP
    rts

/* INITMEMDISPANDSHUTDOWNMGRS: _MemoryDispatch and the Shutdown Manager. */
INITMEMDISPANDSHUTDOWNMGRS:
    jbsr INITMEMORYDISPATCH
    bsrl INITSHUTDOWNMGR
    rts

/*
 DRAWBEEPSCREENPATCH: the start-up screen: on an LCD screen (LCDSCREENCHK) a plain grey
 fill without the rounded corners, else the normal rounded box (DRAWBEEPSCREENRETURN).
*/
DRAWBEEPSCREENPATCH:
    lea %a2@(-116),%a0
    movel %a0,%sp@-
    jbsr LCDSCREENCHK
    jbeq DRAWBEEPSCREENPATCH_18
    pea %a2@(-24)
    _FillRect
    _PenNormal
    rts
DRAWBEEPSCREENPATCH_18:  /* not an LCD: rounded box */
    moveal %sp@,%a0
    bral DRAWBEEPSCREENRETURN
    .long   0x00000000	| 408041CC
    .short  0x0000	| 408041D0

/*
 BOOTBLOCKFLUSHPATCH: read the boot blocks, flush the caches (they are code), check the
 'LK' signature (0x4C4B). Out: Z set if good.
*/
BOOTBLOCKFLUSHPATCH:
    _Read
    jbne BOOTBLOCKFLUSHPATCH_E
    bsrl CACHEFLUSH
    cmpiw #19531,%fp@
BOOTBLOCKFLUSHPATCH_E:  /* back */
    bral BOOTBLOCKFLUSHRETURN

/*
 INSTALLSONYDRIVERPATCH: open the .Sony driver only if there is a floppy controller
 (0xDD3 bit 5) or a SWIM IOP (0xDD1 bit 0).
*/
INSTALLSONYDRIVERPATCH:
    btst #5,0xdd3
    jbne INSTALLSONYDRIVERPATCH_10
    btst #0,0xdd1
    jbeq INSTALLSONYDRIVERPATCH_16
INSTALLSONYDRIVERPATCH_10:  /* open it */
    movel %a1,%a0@(18)
    _Open
INSTALLSONYDRIVERPATCH_16:  /* return */
    rts

/*
 POWERDWNPTCH: on Power Manager machines (HWCfgFlags bit 0): PMgrOp 0x10 (power
 control) with 0x5B, clear a Power Manager flag, then the start-up screen.
*/
POWERDWNPTCH:
    btst #0,HWCfgFlags
    jbeq POWERDWNPTCH_2C
    subqw #4,%sp
    moveb #91,%sp@
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #1,%sp@-
    movew #16,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(16),%sp
    moveal PmgrBase,%a0
    .short  0x08A8	| 40804224
    orib #84,%d2
POWERDWNPTCH_2C:        /* start-up screen */
    jbsr DRAWBEEPSCREEN
    rts

/* INITHWROUTINES: SCC, IWM/SWIM, SCSI and sound hardware initialisation. */
INITHWROUTINES:
    bsrl INITSCC
    movew %d2,%sp@-
    bsrl INITIWM
    movew %sp@+,%d2
    bsrl thunk_FUN_4089863a
    jbsr INITSNDHW
    rts

/* INITSNDHW: initialise the sound hardware with the volume from parameter RAM. */
INITSNDHW:
    moveml %d3-%d4/%a0-%fp,%sp@-
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveb SdVolume,%d0
    lea %pc@(INITSNDHW_16),%fp
    jmp %pc@(INITSNDNORAM_76)
INITSNDHW_16:           /* return */
    moveml %sp@+,%d3-%d4/%a0-%fp
    rts

/*
 INITSNDNORAM: initialise the sound hardware without RAM (return through a5): volume
 from XPRAM 0x08 (when XPRAM 0x10 is 0xA8, the PRAM validity mark), default 5.
*/
INITSNDNORAM:
    movel %a5,%d3
    moveq #0,%d2
    lea %pc@(INITSNDNORAM_12),%fp
    bigjmp hardware_table_lookup
INITSNDNORAM_12:        /* read XPRAM 0x10 */
    moveal %a0@(8),%a2
    movew #16,%d1
    lea %pc@(INITSNDNORAM_28),%fp
    bigjmp RDXBYTE
INITSNDNORAM_28:        /* valid PRAM? else volume 5 */
    cmpib #0xa8,%d1
    jbeq INITSNDNORAM_32
    moveq #5,%d1
    jbra INITSNDNORAM_44
INITSNDNORAM_32:        /* read XPRAM 0x08 (sound volume) */
    movew #8,%d1
    lea %pc@(INITSNDNORAM_44),%fp
    bigjmp RDXBYTE
INITSNDNORAM_44:        /* volume 0 on a non-Power Manager machine: 5 */
    andib #7,%d1
    jbne INITSNDNORAM_56
    btst #0,HWCfgFlags
    jbne INITSNDNORAM_56
    moveb #5,%d1
INITSNDNORAM_56:        /* hardware tables again (registers were used) */
    moveb %d1,%d4
    moveq #0,%d2
    lea %pc@(INITSNDNORAM_68),%fp
    bigjmp hardware_table_lookup
INITSNDNORAM_68:        /* set it up */
    moveb %d4,%d0
    lea %pc@(INITSNDNORAM_72),%fp
    jmp %pc@(INITSNDNORAM_76)
INITSNDNORAM_72:        /* return through a5 */
    moveal %d3,%a5
    jmp %a5@
INITSNDNORAM_76:        /* sound chip set-up (a3 = chip base from ProductInfo +48): volume register, then for the 0xB0 chip ("Batman") its registers */
    moveal %a0@(48),%a3
    moveb %d0,%d1
    aslb #5,%d1
    moveb %d1,%a3@(2054)
    moveb %a3@(2048),%d1
    andib #0xf0,%d1
    cmpib #0xb0,%d1
    jbne INITSNDNORAM_154
    movew #32512,%a3@(3846)
    movew #127,%a3@(3878)
    cmpib #9,%a0@(-4)
    jbeq INITSNDNORAM_AE
    cmpib #12,%a0@(-4)
    jbne INITSNDNORAM_C2
INITSNDNORAM_AE:        /* some machines (kinds 9 and 12): volume scaled for the chip */
    muluw #18,%d0
    moveb %d0,%a3@(3846)
INITSNDNORAM_B6:        /* left/right volume registers */
    clrb %a3@(3847)
    clrb %a3@(3878)
    moveb %d0,%a3@(3879)
INITSNDNORAM_C2:        /* machine kind 13: one more device register (0xF9800100), cleared at a warm start ('WLSC') */
    cmpib #13,%a0@(-4)
    jbne INITSNDNORAM_E4
    movel #1,0xf9800100
    cmpil #1464619843,WarmStart
    jbne INITSNDNORAM_E4
    clrb 0x50f14f2f
INITSNDNORAM_E4:        /* FIFO resets, mode */
    moveb #1,%a3@(3849)
    moveb #1,%a3@(3881)
    orib #0x80,%a3@(2051)
INITSNDNORAM_F6:        /* rate, filter coefficients for both channels, enable */
    andib #127,%a3@(2051)
    moveb #2,%a3@(2058)
    moveb #1,%a3@(2049)
    clrb %a3@(3848)
    clrb %a3@(3880)
    movew #-32465,%a3@(3844)
    movew #-32465,%a3@(3876)
    clrw %a3@(3856)
    movew #60,%a3@(3858)
    movew #-13197,%a3@(3860)
    movew #-13982,%a3@(3862)
    clrw %a3@(3888)
    movew #60,%a3@(3890)
    movew #-13197,%a3@(3892)
    movew #-13982,%a3@(3894)
    moveb #0x80,%a3@(3848)
    moveb #0x80,%a3@(3880)
INITSNDNORAM_154:       /* return through fp */
    jmp %fp@

/*
 INITSWIM2: initialise the SWIM floppy controller (a0 = its base): a bus error while
 probing means none. Put it in ISM mode (writes, check the mode register) or leave it in
 IWM mode and continue at INITIWMRETURN.
*/
INITSWIM2:
    movel BusErrorVector,%sp@-
    pea %pc@(INITSWIM2_16)
    movel %sp@+,BusErrorVector
    movel %sp,%d2
    moveq #-64,%d0
    tstb %a0@(6144)
    moveq #0,%d0
INITSWIM2_16:           /* bus error handler restored */
    moveal %d2,%sp
    movel %sp@+,BusErrorVector
    tstw %d0
    jbne INITSWIM2_56
    moveb #0xf8,%a0@(3072)
    moveq #-11,%d2
    moveb %d2,%a0@(2048)
    moveb %d0,%a0@(6144)
    cmpb %a0@(6144),%d2
    jbeq INITSWIM2_56
    tstb %a0@(7168)
    tstb %a0@(6144)
    moveb %d0,%a0@(7680)
    moveq #63,%d2
    andb %a0@(6144),%d2
    tstb %a0@(7168)
    cmpib #63,%d2
    beql INITIWMRETURN
INITSWIM2_56:           /* return */
    rts

/*
 SETUPTIMEKPATCH: disable the interrupt sources, then on a 68040 turn the caches off if
 bit 7 of XPRAM 0x8A is set, then calibrate the timing loops (SETUPTIMEK).
*/
cache_flush_setup:
SETUPTIMEKPATCH:
    lea (DISABLEINTSOURCES-cache_flush_setup):l,%a0
    jsr %pc@(cache_flush_setup,%a0:l)
    cmpib #4,CPUFlag
    jblt SETUPTIMEKPATCH_34
    clrw %sp@-
    moveal %sp,%a0
    movel #65674,%d0
    movew #4096,%d1
    bsrl trap_ReadXPRam
    movew %sp@+,%d0
    tstw %d0
    jbpl SETUPTIMEKPATCH_34
    cpusha %bc
    moveq #0,%d0
    movec %d0,%cacr
SETUPTIMEKPATCH_34:     /* calibrate */
    bral via_timer_calibrate
    .fill   0x1C6, 1, 0x00
SETUPTIMEKPATCH_200:    /* TESTFORFPU: an FPU? (temporary line-F vector, fnop) Out: Z clear if one */
    .long   0x00000000, 0x00000000, 0x00000000	| 40804614
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40804620
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40804630
UNIVERSALPATCH:
TESTFORFPU:             /* set %d1 */
    movec %vbr,%d1
    subil #36,%d1
    movec %d1,%vbr
    moveq #1,%d1
    lea %pc@(UNIVERSALPATCH_1A),%fp
    fnop
    moveq #0,%d1
UNIVERSALPATCH_1A:      /* d1 = 1 if fnop raised a line-F exception (no FPU)... restore the VBR */
    moveal %d1,%fp
    movec %vbr,%d1
    addil #36,%d1
    movec %d1,%vbr
    movel %fp,%d1
    tstb %d1
    jbra OPTIONALSPATCH_50

/*
 TESTFORRPU: is there an RPU (RAM parity unit) at a2? Its parity bit toggles. Return
 through fp, Z clear if found.
*/
TESTFORRPU:
    tstb %a2@
    tstb %a2@
    tstb %a2@
    tstb %a2@
    st %a2@(16)
    moveb %a2@,%d2
    st %a2@(16)
    st %a2@
    clrb %a2@(16)
    moveq #1,%d1
    andb %a2@,%d1
    seq %d1
    jbeq TESTFORRPU_2E
    st %a2@(16)
    clrb %a2@
    st %a2@(16)
    moveq #1,%d1
    andb %a2@,%d1
TESTFORRPU_2E:          /* restore, return */
    st %a2@(16)
    moveb %d2,%a2@
    tstb %d1
    jmp %fp@

/*
 TESTFORVIER / TESTVIERWRAP: is there a VIA at a2 (its interrupt enable register keeps
 the bits written; with d2, also that a2+d2 is a different register, not a wrap of the
 address space)? Return through fp, Z set if found.
*/
TESTFORVIER:
    moveq #0,%d2
TESTVIERWRAP:           /* (with the wrap check at a2+d2) */
    tstb %a2@(0x0,%d2:l)
    moveb %a2@,%d1
    rolw #8,%d1
    st %d1
    moveb %d1,%a2@
TESTVIERWRAP_C:         /* write/read patterns */
    negb %d1
    moveb %d1,%a2@
    addb %d1,%d1
    jbeq TESTVIERWRAP_20
    negb %d1
    cmpb %a2@(0x0,%d2:l),%d1
    jbne TESTVIERWRAP_20
    cmpb %a2@,%d1
    jbeq TESTVIERWRAP_C
TESTVIERWRAP_20:        /* restore, return */
    rorw #8,%d1
    moveb #127,%a2@
    moveb %d1,%a2@
    lsrw #8,%d1
    jmp %fp@

/* TESTFORRVIER: is there an RBV (the VIA 2 replacement) at a2? (its bits 5-6 always read 0). */
TESTFORRVIER:
    moveb %a2@,%d1
    rolw #8,%d1
    st %d1
    moveb %d1,%a2@
TESTFORRVIER_8:         /* write/read patterns */
    negb %d1
    moveb %d1,%a2@
    addb %d1,%d1
    jbeq TESTFORRVIER_1C
    negb %d1
    moveb %a2@,%d2
    eorb %d1,%d2
    andib #0x9f,%d2
    jbeq TESTFORRVIER_8
TESTFORRVIER_1C:        /* restore, return */
    rorw #8,%d1
    moveb #127,%a2@
    moveb %d1,%a2@
    lsrw #8,%d1
    jmp %fp@

/* TESTFORSCSIDMA: SCSI DMA hardware at a2? (a bus error means no). Z set if found. */
TESTFORSCSIDMA:
    tstl %a2@(128)
    cmpb %d1,%d1
    jmp %fp@

/* TESTFORSCSI96: a 53C96 SCSI chip at a2? (register +192 reads 4). */
TESTFORSCSI96:
    tstb %a2@(192)
    cmpib #4,%a2@(192)
    jmp %fp@

/*
 TESTFORSCC: an SCC at a2? (write registers 12/13 through the control port, read them
 back, and restore them). Z set if found.
*/
TESTFORSCC:
    tstb %a2@(0x0,%d2:l)
    rorb #8,%d1
    moveb #13,%a2@
TESTFORSCC_A:           /* (registers 12 and 13) */
    rorb #8,%d1
    moveb %a2@(0x0,%d2:l),%d1
    rorb #8,%d1
    moveb #12,%a2@
    lsll #8,%d1
    moveb %a2@(0x0,%d2:l),%d1
    rorb #8,%d1
    moveb #13,%a2@
    rorb #8,%d1
    moveb #71,%a2@
    rorb #8,%d1
    moveb #12,%a2@
    rorb #8,%d1
    moveb #68,%a2@
    rorb #8,%d1
    moveb #13,%a2@
    lsll #8,%d1
    moveb %a2@(0x0,%d2:l),%d1
    rorb #8,%d1
    moveb #12,%a2@
    lsll #8,%d1
    moveb %a2@(0x0,%d2:l),%d1
    subiw #18244,%d1
    rorl #8,%d1
    moveb #12,%a2@
    rorl #8,%d1
    moveb %d1,%a2@
    rorb #8,%d1
    moveb #13,%a2@
    lsrl #8,%d1
    moveb %d1,%a2@
    lsrl #8,%d1
    jmp %fp@

/* TESTFORIOP: an IOP at a2? (its address register increments as it is read). */
TESTFORIOP:
    moveb %a2@(-28),%d1
    moveq #6,%d2
    andb %d1,%d2
    swap %d1
    movew %a2@(-31),%d1
    orib #2,%d2
    moveb %d2,%a2@(-28)
    tstl %a2@(-24)
    movew %a2@(-31),%d2
    movew %d1,%a2@(-31)
    subqw #4,%d2
    subw %d1,%d2
    swap %d1
    andib #0xcf,%d1
    moveb %d1,%a2@(-28)
    tstw %d2
    jmp %fp@

/* TESTFORSONIC: a SONIC Ethernet chip at a1? (no bus error). */
TESTFORSONIC:
    tstb %a1@
    cmpw %d1,%d1
    jmp %fp@

/* TESTFORPATCHROM: a patch ROM at a1? (its second long is 'romp'). */
TESTFORPATCHROM:
    tstb %a1@
    moveal %a1@(4),%a1
    exg %d1,%a1
    cmpil #1919905136,%d1
    exg %d1,%a1
    jmp %fp@

/*
 GETVIAINPUTS: read the machine identification inputs of VIA 1 and VIA 2 (port A and B
 pins set to inputs for the masks of the decoder info, read, restored). Out: d1.
*/
GETVIAINPUTS:
    moveq #0,%d1
    btst #2,%d0
    jbeq GETVIAINPUTS_4C
    moveal %a0@(8),%a1
    moveb %a1@(7680),%d2
    lslw #8,%d2
    moveb %a1@(1536),%d2
    moveb %d2,%d1
    andb %a0@(-12),%d1
    moveb %d1,%a1@(1536)
    moveb %a1@(7680),%d1
    moveb %d2,%a1@(1536)
    lsrw #8,%d2
    moveb %d2,%a1@(7680)
    lslw #8,%d1
    moveb %a1@,%d2
    lslw #8,%d2
    moveb %a1@(1024),%d2
    moveb %d2,%d1
    andb %a0@(-11),%d1
    moveb %d1,%a1@(1024)
    moveb %a1@,%d1
    moveb %d2,%a1@(1024)
    lsrw #8,%d2
    moveb %d2,%a1@
GETVIAINPUTS_4C:        /* VIA 2 */
    swap %d1
    btst #11,%d0
    jbeq GETVIAINPUTS_98
    moveal %a0@(44),%a1
    moveb %a1@(7680),%d2
    lslw #8,%d2
    moveb %a1@(1536),%d2
    moveb %d2,%d1
    andb %a0@(-10),%d1
    moveb %d1,%a1@(1536)
    moveb %a1@(7680),%d1
    moveb %d2,%a1@(1536)
    lsrw #8,%d2
    moveb %d2,%a1@(7680)
    lslw #8,%d1
    moveb %a1@,%d2
    lslw #8,%d2
    moveb %a1@(1024),%d2
    moveb %d2,%d1
    andb %a0@(-9),%d1
    moveb %d1,%a1@(1024)
    moveb %a1@,%d1
    moveb %d2,%a1@(1024)
    lsrw #8,%d2
    moveb %d2,%a1@
GETVIAINPUTS_98:        /* return through fp */
    jmp %fp@

/*
 MEMORYCTRLINITPATCH: memory controller and video set-up for the newer machines: from
 the CPU ID register (0x5FFFFFFC) the memory controller timing; the DAFB video
 registers (bit 21); a VIA 2 bit; the video clock chip from the monitor sense lines
 (bit 23, tables below).
*/
MEMORYCTRLINITPATCH:
    movel %a1@(28),%d3
    btst #22,%d3
    beqw MEMORYCTRLINITPATCH_50
    lea 0x5ffffffc,%a2
    movel %a2@,%d3
    andil #65280,%d3
    moveal %a0@(52),%a2
    clrb %a2@(4)
    moveb #64,%a2@(1)
    moveb #3,%a2@(5)
    cmpiw #8192,%d3
    jbge MEMORYCTRLINITPATCH_50
    lea 0x5ffffffc,%a2
    movel %a2@,%d3
    andiw #2047,%d3
    cmpiw #3,%d3
    jbeq MEMORYCTRLINITPATCH_50
    moveal %a0@(52),%a2
    moveb #2,%a2@(5)
MEMORYCTRLINITPATCH_50:  /* DAFB present (bit 21): clock values */
    btst #21,%d0
    jbeq MEMORYCTRLINITPATCH_B4
    moveal %a0@(84),%a3
    movel #307169296,%d4
    moveq #31,%d3
    moveal %a0@(44),%a2
    bclr #5,%a2@(1024)
    btst #5,%a2@
    jbeq MEMORYCTRLINITPATCH_78
    movel #327878672,%d4
MEMORYCTRLINITPATCH_78:  /* (other video RAM size) */
    lea %a3@,%a2
MEMORYCTRLINITPATCH_7A:  /* shift the 32 clock bits out */
    movel %d4,%a2@+
    lsrl #1,%d4
    dbf %d3,MEMORYCTRLINITPATCH_7A
    moveq #0,%d4
    movel %d4,%a2@+
    movel %d3,%a3@(160)
    movel %d3,%a3@(164)
    movel %d3,%a3@(168)
    movel %d3,%a3@(172)
    movel %d3,%a3@(176)
    movel %d3,%a3@(180)
    movel %a3@(72),%d4
    btst #0,%d4
    jbeq MEMORYCTRLINITPATCH_AC
    moveq #0,%d4
    jbra MEMORYCTRLINITPATCH_AE
MEMORYCTRLINITPATCH_AC:  /* (bit 0 clear) */
    moveq #1,%d4
MEMORYCTRLINITPATCH_AE:  /* store */
    movel %d4,%a2@
    movel %d3,%a3@(184)
MEMORYCTRLINITPATCH_B4:  /* bit 22: a hardware bit from the I/O space */
    btst #22,%d0
    jbeq MEMORYCTRLINITPATCH_CE
    moveal %a0@(88),%a2
    moveal %a2,%a3
    addal #212992,%a3
    moveb %a3@,%d3
    andib #1,%d3
    moveb %d3,%a2@
MEMORYCTRLINITPATCH_CE:  /* bit 23: monitor sense, video clock */
    movel %a1@(28),%d3
    btst #23,%d3
    jbeq SCSI96ANDRPUPATCH_A
    moveal %a0@(8),%a2
    moveq #40,%d3
    moveb %d3,%a2@(1536)
    moveq #20,%d3
    andb %a2@(7680),%d3
    lsrb #2,%d3
    btst #2,%d3
    jbeq MEMORYCTRLINITPATCH_F6
    bset #1,%d3
MEMORYCTRLINITPATCH_F6:  /* sense code 0..3 */
    andib #3,%d3
    moveq #-1,%d4
MEMORYCTRLINITPATCH_FC:  /* look up the extended sense in the table */
    addql #1,%d4
    tstw %pc@(MEMORYCTRLINITPATCH_17A:w,%d4:w:2)	| 40804960
    jbeq MEMORYCTRLINITPATCH_120
    moveq #86,%d0
    andb %a2@(7680),%d0
    cmpb %pc@(MEMORYCTRLINITPATCH_17B:w,%d4:w:2),%d0	| 4080496E
    jbne MEMORYCTRLINITPATCH_FC
    lea %pc@(MEMORYCTRLINITPATCH_15E),%a3
    moveb %pc@(MEMORYCTRLINITPATCH_17A:w,%d4:w:2),%d0	| 4080497A
    jbeq MEMORYCTRLINITPATCH_124
MEMORYCTRLINITPATCH_120:  /* default timing table */
    lea %pc@(SCSI96ANDRPUPATCH_2),%a3
MEMORYCTRLINITPATCH_124:  /* write the timing registers */
    lea 0x50f0e000,%a2
    movew %a3@(0x0,%d3:w:2),%d0
    movel %d0,%a2@(48)
    movew %pc@(MEMORYCTRLINITPATCH_166:w,%d3:w:2),%d0	| 40804994
    movel %d0,%a2@(52)
    lea 0x50f18000,%a2
    movel %a2@,%d0
    andib #0xf7,%d0
    orb %pc@(MEMORYCTRLINITPATCH_16E:w,%d3:w),%d0	| 408049AA
    movel %d0,%a2@
MEMORYCTRLINITPATCH_150:  /* (last register) */
    movew %pc@(MEMORYCTRLINITPATCH_172:w,%d3:w:2),%d0	| 408049B2
    movel %d0,%a2@(1536)
    jbra SCSI96ANDRPUPATCH_A
    .short  0x0000	| 408049BE
MEMORYCTRLINITPATCH_15E:  /* timing values per sense code */
    .long   0x0101001A, 0x00A302F4	| 408049C0
MEMORYCTRLINITPATCH_166:  /* timing values */
    .long   0x011D016B, 0x01E70255	| 408049C8
MEMORYCTRLINITPATCH_16E:  /* clock register bits */
    .long   0x01010000	| 408049D0
MEMORYCTRLINITPATCH_172:  /* timing values */
    .long   0x028001E0, 0x00D50000	| 408049D4
MEMORYCTRLINITPATCH_17A:  /* extended sense table: (sense, code) pairs, 0 ends */
    .byte   0x00	| 408049DC
MEMORYCTRLINITPATCH_17B:  /* (inside the table) */
    .byte   0x42, 0x01, 0x52	| 408049DD
    .short  0x0040, 0x0042, 0x0144, 0x0046, 0x0150, 0x0154, 0x0156	| 408049E0

/*
 SCSI96ANDRPUPATCH: default timing values (first 4 words), then the continuation of
 the hardware identification: return through a4.
*/
SCSI96ANDRPUPATCH:
    .short  0x0000	| 408049EE
SCSI96ANDRPUPATCH_2:    /* default timing table */
    .long   0x0101001A, 0x00FB02FC	| 408049F0
SCSI96ANDRPUPATCH_A:    /* return through a4 */
    jmp %a4@

SCSI96ANDRPUPATCH_C:    /* (from SAVEPATCHRTN) bus error vector to GOTBUSERROR as in JUMPINTOROM */
    addal %d3,%sp
    lea %pc@(GOTBUSERROR),%a0
    movel %a0,%d0
SCSI96ANDRPUPATCH_14:   /* look back for a long pointing to GOTBUSERROR */
    cmpl %a0@-,%d0
    jbeq SCSI96ANDRPUPATCH_22
    tstl %a0@
    jbne SCSI96ANDRPUPATCH_14
    lea BusErrorVector,%a0
    movel %d0,%a0@
SCSI96ANDRPUPATCH_22:   /* VBR */
    subqw #8,%a0
    movec %a0,%vbr
SCSI96ANDRPUPATCH_28:   /* identify the machine, retry until found */
    moveq #0,%d2
    lea %pc@(SCSI96ANDRPUPATCH_32),%fp
    jmp %pc@(hardware_table_lookup)
SCSI96ANDRPUPATCH_32:   /* then the VIAs */
    btst #0,%d0
    jbeq SCSI96ANDRPUPATCH_28
    lea %pc@(SCSI96ANDRPUPATCH_40),%fp
    jmp %pc@(INITVIAS)
SCSI96ANDRPUPATCH_40:   /* and ROMBERRANDVBRRTN */
    jbra ROMBERRANDVBRRTN

SCSI96ANDRPUPATCH_44:   /* optional hardware: SCSI 96 (bit 24)? */
    bclr #24,%d0
    jbeq OPTIONALSPATCH_12
    moveal %a1@,%a2
    moveal %a1@(0x60,%a2:l),%a2
    lea %pc@(SCSI96ANDRPUPATCH_58),%fp
    jmp %pc@(TESTFORSCSI96)
SCSI96ANDRPUPATCH_58:   /* set bit 24, clear the other SCSI bits */
    jbne OPTIONALSPATCH_12	| 40804A46
    bset #24,%d0	| 40804A48
    bclr #15,%d0	| 40804A4C
    bclr #8,%d0	| 40804A50
    .byte   0x08, 0x80	| 40804A54
SAVEPATCH:              /* (raw words, inside the sequence) */
    .byte   0x00, 0x09	| 40804A56
    bclr #10,%d0	| 40804A58
    bclr #25,%d0
    beqs OPTIONALSPATCH_12
    moveal %a1@,%a2
OPTIONALSPATCH:         /* second SCSI 96, bit 25 */
    moveal %a1@(0x64,%a2:l),%a2
    lea %pc@(OPTIONALSPATCH_C),%fp
    jmp %pc@(TESTFORSCSI96)
OPTIONALSPATCH_C:
    bnes OPTIONALSPATCH_12
    bset #25,%d0
OPTIONALSPATCH_12:      /* RPU (bit 20)? */
    bclr #20,%d0
    jbeq OPTIONALSPATCH_2C
    moveal %a1@,%a2
    moveal %a1@(0x50,%a2:l),%a2
    lea %pc@(OPTIONALSPATCH_26),%fp
    jmp %pc@(TESTFORRPU)
OPTIONALSPATCH_26:      /* found: keep bit 20 */
    jbne OPTIONALSPATCH_2C	| 40804A8A
    bset #20,%d0	| 40804A8C
OPTIONALSPATCH_2C:      /* back to the identification */
    moveal %a0,%fp
    moveal %a1,%a0
    bral SCSI96ANDRPURESUME

OPTIONALSPATCH_36:      /* relocate the table pointers by the ROM's position (a2 = ROM start) */
    movel %a0@,%d3
    subl %a2,%d3
    addal %d3,%a0
    addal %d3,%a1
    bral SAVEPATCHRTN

OPTIONALSPATCH_44:      /* FPU check needed (bit 28 of d2)? */
    btst #28,%d2
    jbeq OPTIONALSPATCH_58
    moveal %fp,%a2
    jbra UNIVERSALPATCH

OPTIONALSPATCH_50:      /* no FPU: clear bit 28 */
    moveal %a2,%fp
    jbeq OPTIONALSPATCH_58
    bclr #28,%d2
OPTIONALSPATCH_58:      /* bus errors expected from now on (d7 bit 27, sp saved in a5) */
    bset #27,%d7
    moveal %sp,%a5
OPTIONALSPATCH_5E:      /* SONIC (bit 23)? */
    bclr #23,%d0
    jbeq GETHARDWAREINFOPATCH_1E
    movel %a1,%d1
    moveal %a0@(92),%a1
    moveal %fp,%a2
    lea %pc@(GETHARDWAREINFOPATCH_14),%fp
    jmp %pc@(TESTFORSONIC)
GETHARDWAREINFOPATCH_14:  /* not found: clear... (bit set back when found) */
    moveal %a2,%fp
    moveal %d1,%a1
    jbne GETHARDWAREINFOPATCH_1E
    bset #23,%d0
GETHARDWAREINFOPATCH_1E:  /* patch ROM (bit 29)? */
    bclr #29,%d0
    jbeq GETHARDWAREINFOPATCH_3E
    movel %a1,%d1
    moveal %a0@(116),%a1
    moveal %fp,%a2
    lea %pc@(GETHARDWAREINFOPATCH_34),%fp
    jmp %pc@(TESTFORPATCHROM)
GETHARDWAREINFOPATCH_34:  /* (result) */
    moveal %a2,%fp
    moveal %d1,%a1
    jbne GETHARDWAREINFOPATCH_3E
    bset #29,%d0
GETHARDWAREINFOPATCH_3E:  /* then the extended features */
    bral CHECKFEATURES

OPTIONALSPATCH_A4:      /* GETHARDWAREINFO patch: machines with a CPU ID register first */
    bset #27,%d7
    moveal %sp,%a5
    moveal %fp,%a1
    lea %pc@(GETHARDWAREINFOPATCH_54),%fp
    jmp %pc@(GETHARDWAREINFOPATCH_BC)
GETHARDWAREINFOPATCH_54:  /* CPU ID register present? */
    moveal %a1,%fp
    jbeq GETHARDWAREINFOPATCH_5E
GETHARDWAREINFOPATCH_58:  /* no: the old identification */
    bral GETHARDWARECONT
GETHARDWAREINFOPATCH_5E:  /* yes: look for its ProductInfo in CPUIDPRODUCTLOOKUP */
    biglea BUSERRHANDLER_96_BIOS_1F6, a2
GETHARDWAREINFOPATCH_68:  /* next entry: CPU ID match (+60)? */
    addqw #4,%a2
    movel %a2@,%d1
    jbeq GETHARDWAREINFOPATCH_BA
    lea %a2@(0x0,%d1:l),%a1
    cmpw %a1@(60),%d0
    jbne GETHARDWAREINFOPATCH_68
    btst #11,%d0
    jbeq GETHARDWAREINFOPATCH_B4
    moveal %a1@,%a0
    addal %a1,%a0
    movel %a0@(-20),%d0
    moveal %fp,%a3
    lea %pc@(GETHARDWAREINFOPATCH_90),%fp
    jmp %pc@(GETVIAINPUTS)
GETHARDWAREINFOPATCH_90:  /* also check the VIA ID bits */
    moveal %a3,%fp
    movel %a2@,%d0
    lea %a2@(0x0,%d0:l),%a1
    andl %a1@(32),%d1
    cmpl %a1@(36),%d1
    jbeq GETHARDWAREINFOPATCH_B4
    moveal %a2,%a3
    moveal %fp,%a1
    lea %pc@(GETHARDWAREINFOPATCH_AE),%fp
    jmp %pc@(GETHARDWAREINFOPATCH_BC)
GETHARDWAREINFOPATCH_AE:  /* no match: read the CPU ID again, next entry */
    moveal %a1,%fp
    moveal %a3,%a2
    jbra GETHARDWAREINFOPATCH_68
GETHARDWAREINFOPATCH_B4:  /* found */
    bral FOUNDMATCH
GETHARDWAREINFOPATCH_BA:  /* none: hang */
    jbra GETHARDWAREINFOPATCH_BA
GETHARDWAREINFOPATCH_BC:  /* read the CPU ID register: read-only and 0xA55A in its high word? Z set, d0 = the ID */
    lea 0x5ffffffc,%a2
    movel %a2@,%d0
    moveq #0,%d1
GETHARDWAREINFOPATCH_C6:  /* write tests */
    movel %d1,%a2@
    cmpl %a2@,%d0
    jbne GETHARDWAREINFOPATCH_DC
    notl %d1
    jbne GETHARDWAREINFOPATCH_C6
    swap %d0
    cmpiw #-23206,%d0
    jbne GETHARDWAREINFOPATCH_DC
    swap %d0
    cmpw %d0,%d0
GETHARDWAREINFOPATCH_DC:  /* return through fp */
    jmp %fp@
    .fill   0x11E, 1, 0x00
