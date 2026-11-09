/*
 os/scsi96.s - SCSI Manager for the 53C96
 From SCSIMISCPATCH (0x40898620). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. Three parts:
 - SCSI Manager patches (SREADPATCH .. TESTC96DREQPATCH): start-up and boot-time
   additions to os/scsimgr.s: which 53C96 manager to install, the start-up device's
   ID, the retry of SCSILOAD's reads, the DREQ line, and the PowerBook disk power
   handling (sleep queue, spin down). These run on the Quadra 800.
 - SCSI96 .. SCSIINIT96: the 53C96 SCSI Manager for machines with AddrMapFlags bit 21
   set, up to two buses. The Quadra 800 uses the BIOS variant instead
   (os/scsibios.s), whose routines these mirror; of this part only the wait routines
   (WTFORFIFODATA, WAITFORINTNOTIME, WAITFORSCSIINTRP) and INTHND_SCSI96 are shared.
   Register layout and state flags: see os/scsibios.s.
 - CPUDECLDATA to the end: sResource data and code for the built-in CPU and video,
   grouped here only because they follow in the ROM (not SCSI).
 What runs on the Quadra 800 was checked against QEMU execution traces
 (analysis/executed_pcs.txt).
*/

/*
 SREADPATCH / SCSIMISCPATCH (via RDDONE): the end of SCSILOAD's reads: on a 68040 flush
 the caches (code was just read into memory), pop SCSILOAD_19A's frame, d0 = the result
 (d7). Runs on the Quadra 800.
*/
SCSIMISCPATCH:
SREADPATCH:             /* a 68040? */
    cmpib #4,CPUFlag
    jbne SCSIMISCPATCH_E
    jbsr CACHEFLUSH
SCSIMISCPATCH_E:        /* pop the 22 bytes, d0 = result, restore d7 */
    lea %sp@(22),%sp
    movew %d7,%d0
    movel %sp@+,%d7
    tstw %d0
    rts

/*
 INITSCSIHW: initialise the SCSI chip(s): a 53C96 on the first bus (AddrMapFlags bit 24:
 the chip at 0xC00, SCSIBase) through SCSIHW96BIOS or SCSIHW96 (SREADPATCH2_5C), and the
 second bus's (bit 25: the chip address at 0x1FF0) the same way; else a 5380
 (INITHW_SCSI80). a4 = the DREQ register of the non-BIOS variant (0xF9800024/28).
 Runs on the Quadra 800 (one 53C96).
*/
INITSCSIHW:
    moveml %a3-%a4,%sp@-
    moveal ToolDispTable,%a3
    btst #0,0xdd0	/* AddrMapFlags bit 24: a 53C96? */
    jbeq INITSCSIHW_36
    moveal #-109051868,%a4
    bsrl SREADPATCH2_5C
    btst #1,0xdd0	/* bit 25: a second bus? */
    jbeq INITSCSIHW_38
    moveal 0x1ff0,%a3	/* the second chip */
    moveal #-109051864,%a4
    bsrl SREADPATCH2_5C
    jbra INITSCSIHW_38
INITSCSIHW_36:          /* a 5380 */
    jbsr INITHW_SCSI80
INITSCSIHW_38:          /* restore registers, return */
    moveml %sp@+,%a3-%a4
    rts

/*
 INITHW_SCSI80: initialise a 5380: initiator command, mode, target command and select
 enable registers 0.
*/
INITHW_SCSI80:
    clrb %a3@(16)
    clrb %a3@(32)
    clrb %a3@(48)
    clrb %a3@(64)
    rts

/*
 INSTALLSCSIINTHND96 (from SCSIINIT, VIA 2 machines): with a 53C96 (AddrMapFlags bit
 24) the handler is INTHND_SCSI96 instead of the 5380's SCSIINTHND; back in
 SCSIINTHNDRESUME it goes in the VIA 2 SCSI vector (0xD7C). The flags' bit 4 (SCSI DMA
 chip) decides there which way (the Z flag).
*/
INSTALLSCSIINTHND96:
    btst #0,0xdd0
    jbeq INSTALLSCSIINTHND96_C
    lea %pc@(INTHND_SCSI96),%a1
INSTALLSCSIINTHND96_C:  /* Z = no SCSI DMA chip; on to SCSIINTHNDRESUME */
    btst #4,%a4@(103)
    jbra SCSIINTHNDRESUME

/*
 SCSI96BUSERRPATCH: bus error during a pseudo-DMA transfer: d0 = 9, or 5 (a phase
 error) on a 53C96 machine (AddrMapFlags bit 24) when bit 3 of the register at a1 is
 clear.
*/
SCSI96BUSERRPATCH:
    moveq #9,%d0
    btst #0,0xdd0
    beqs SCSI96BUSERRPATCH_C
    rts
SCSI96BUSERRPATCH_C:
    btst #3,%a1@
    bnes SCSI96BUSERRPATCH_14
    moveq #5,%d0
SCSI96BUSERRPATCH_14:
    rts

/*
 INITSCSIMGRPATCH1 (from SCSIINIT): on a Power Manager machine (HWCfgFlags bit 8) a
 14-byte sleep queue element (+108); the hardware flags (+100) from SCSISETFLAGS.
 INITSCSIMGRPATCH2 (from SCSIINIT, d0/d1: the free list of private blocks): link the
 last block, install the 53C96 manager (SREADPATCH2_70) if there is one, and make the
 start-up device's SCSI ID (GetDefaultStartup: refNum -33 - ID) the one SCSIPoll
 looks at first; then SREADPATCH2_16. Both run on the Quadra 800.
*/
INITSCSIMGRPATCH1:
    btst #0,HWCfgFlags	/* Power Manager (HWCfgFlags bit 8)? */
    jbeq INITSCSIMGRPATCH1_18
    moveq #14,%d0
    .short  0xA71E	| 408986C2 _NewPtr (flags 0x0700)
    jbne INITSCSIDONE
    movel %a0,%a4@(108)
    moveal %a4,%a0
INITSCSIMGRPATCH1_18:   /* the hardware flags (+100) */
    jbsr SCSISETFLAGS
    movel %d0,%a4@(100)
    rts

INITSCSIMGRPATCH2:      /* link the last private block; 53C96? install its manager */
    moveal %d0,%a1
    addl %d1,%d0
    movel %d0,%a1@
    btst #0,0xdd0	/* AddrMapFlags bit 24: a 53C96 */
    jbeq INITSCSIMGRPATCH2_14
    bsrl SREADPATCH2_70
INITSCSIMGRPATCH2_14:   /* the default start-up device: a SCSI drive (refNum -33..-40)? */
    subqw #4,%sp
    moveal %sp,%a0
    _GetDefaultStartup	/* the default start-up device */
    movew %sp@+,%d0
    movew %sp@+,%d1
    tstw %d1
    jbge INITSCSIMGRPATCH2_3E
    notw %d1
    subiw #32,%d1	/* refNum -33 - ID: the SCSI ID */
    jblt INITSCSIMGRPATCH2_3E
    cmpiw #7,%d1
    jbgt INITSCSIMGRPATCH2_3E
    moveb SCSIPoll,%d0
    andib #0xf8,%d0
    orb %d1,%d0
    moveb %d0,SCSIPoll	/* its ID in SCSIPoll's low bits */
INITSCSIMGRPATCH2_3E:   /* on to SREADPATCH2_16 (Power Manager sleep, second bus) */
    jbra SREADPATCH2_16
    .short  0x0000	| 4089871E
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40898720
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40898730
    .long   0x00000000, 0x00000000	| 40898740

/*
 SCSISETFLAGSPATCH: the rest of the SCSI Manager's hardware flags: bit 0 Power Manager
 (HWCfgFlags bit 8), bit 8 a 53C96 on the first bus (AddrMapFlags bit 24), bit 9 on the
 second (bit 25), bit 6 a 68000 (CPUFlag 0). The Quadra 800 gets bits 3 (VIA 2) and 8.
*/
SCSISETFLAGSPATCH:
    btst #0,HWCfgFlags
    jbeq SCSISETFLAGSPATCH_C
    bset #0,%d0
SCSISETFLAGSPATCH_C:    /* 53C96 on the first bus? */
    btst #0,0xdd0
    jbeq SCSISETFLAGSPATCH_18
    bset #8,%d0
SCSISETFLAGSPATCH_18:   /* on the second? */
    btst #1,0xdd0
    jbeq SCSISETFLAGSPATCH_24
    bset #9,%d0
SCSISETFLAGSPATCH_24:   /* a 68000? */
    tstb CPUFlag
    jbne SCSISETFLAGSPATCH_2E
    bset #6,%d0
SCSISETFLAGSPATCH_2E:   /* return */
    rts

/*
 DOSPINDOWN: spin the internal hard disk down (PowerBooks): PMgrOp powerCntl (0x10)
 with 0x04 (hard disk, off); then the Power Manager globals (0xD18) record it: last
 access time (+30) 0, disk on (+84 bit 2) cleared.
*/
DOSPINDOWN:
    linkw %fp,#-14
    lea %fp@(-14),%a0
    movew #16,%a0@	/* pmCommand 0x10 (powerCntl) */
    movew #1,%a0@(2)
    movew #1024,%fp@(-2)	/* 0x04: hard disk off */
    pea %fp@(-2)
    movel %sp@+,%a0@(4)
    movel %d7,%a0@(8)
    _PMgrOp
    tstw %d0
    jbne DOSPINDOWN_38
    moveal PmgrBase,%a0
    clrl %a0@(30)
    bclr #2,%a0@(84)
DOSPINDOWN_38:          /* return */
    unlk %fp
    rts

/*
 SLEEPTASK: the SCSI Manager's sleep queue procedure (PowerBooks), d0 = the sleep
 message: a sleep request (1) is refused (d0 non-zero) while asynchronous requests are
 queued; a sleep demand (2), a request granted or a wake-up for sleep (6) spin the
 disk down through the Power Manager's routine (+22: DOSPINDOWN).
*/
SLEEPTASK:
    movel %a1,%sp@-
    cmpiw #2,%d0
    jbeq SLEEPTASK_1E
    cmpiw #6,%d0
    jbeq SLEEPTASK_1E
    cmpiw #1,%d0
    jbne SLEEPTASK_28
    moveal SCSIGlobals,%a1
    tstl %a1@(80)	/* requests queued: refuse */
    jbne SLEEPTASK_2A
SLEEPTASK_1E:           /* spin the disk down (the Power Manager globals' routine) */
    moveal PmgrBase,%a1
    moveal %a1@(22),%a1
    jsr %a1@
SLEEPTASK_28:           /* 0: agreed */
    moveq #0,%d0
SLEEPTASK_2A:           /* return */
    moveal %sp@+,%a1
    rts

/*
 SCSIGETPATCH (from SCSIGet): disable the SCSI interrupt; on a PowerBook whose disk is
 off, power it on (PMgrOp powerCntl 0x84: hard disk, on) and note it on (+84 bit 2),
 last access now.
*/
SCSIGETPATCH:
    moveal %a4@(368),%a0	/* vector +368: DISENABLE */
    jsr %a0@
    btst #0,HWCfgFlags
    jbeq SCSIGETPATCH_46
    moveal PmgrBase,%a0
    movel %d7,%a0@(30)
    bset #2,%a0@(84)	/* disk already on? */
    jbne SCSIGETPATCH_46
    linkw %fp,#-14
    lea %fp@(-14),%a0
    movew #16,%a0@
    movew #1,%a0@(2)
    movew #-31744,%fp@(-2)	/* 0x84: hard disk on */
    pea %fp@(-2)
    movel %sp@+,%a0@(4)
    movel %d7,%a0@(8)
    _PMgrOp
    unlk %fp
SCSIGETPATCH_46:        /* return */
    rts

/*
 SCSIDOCOMPLETEPATCH (end of SCSIComplete): store the result, clean up (SCSIEXITCLEANUP),
 and on a PowerBook note the time of the last disk access (Power Manager globals +30)
 for the spin-down timer.
*/
SCSIDOCOMPLETEPATCH:
    moveal %sp@+,%a2
    movew %sp@+,%fp@(20)
    jbsr SCSIEXITCLEANUP
    btst #0,HWCfgFlags
    jbeq SCSIDOCOMPLETEPATCH_1E
    moveal PmgrBase,%a0
    movel Ticks,%a0@(30)	/* last disk access */
SCSIDOCOMPLETEPATCH_1E: /* return to SCSIComplete's exit */
    jmp %a2@

/*
 SREADPATCH2 (from SCSILOAD_19A, d7 = the status byte): status 2 (Check Condition) or 8
 (Busy): retry once (TSTRETRY); else done (RDDONE). The routines after it are start-up
 patches. Runs on the Quadra 800.
*/
SREADPATCH2:
    cmpiw #2,%d7	/* Check Condition */
    jbeq SREADPATCH2_10
    cmpiw #8,%d7	/* Busy */
    jbne RDDONE
SREADPATCH2_10:         /* retry */
    jbra TSTRETRY

SREADPATCH2_16:         /* Power Manager machine: DOSPINDOWN in the Power Manager globals (+22), the sleep queue element (+108: SLEEPTASK, type 16) installed with _Sleep */
    btst #0,HWCfgFlags
    jbeq SREADPATCH2_42
    lea %pc@(DOSPINDOWN),%a1
    moveal PmgrBase,%a0
    movel %a1,%a0@(22)
    moveal %a4@(108),%a0
    lea %pc@(SLEEPTASK),%a1
    movel %a1,%a0@(6)
    movew #16,%a0@(4)
    clrw %a0@(10)
    .short  0xA28A	| 4089888A _Sleep (flags 0x0200)
SREADPATCH2_42:         /* 0xDD5 bit 4: SCSIINITDB */
    btst #4,0xdd5
    jbeq SREADPATCH2_50
    jbsr SCSIINITDB
SREADPATCH2_50:         /* return */
    rts

SREADPATCH2_52:         /* Z = the BIOS variant: AddrMapFlags bit 21 clear (the Quadra 800); set: SCSI96 */
    btst #5,0xdd1
    rts
    .short  0x1000	| 408988A4

SREADPATCH2_5C:         /* initialise a 53C96: SCSIHW96 or SCSIHW96BIOS */
    jbsr SREADPATCH2_52
    jbeq SREADPATCH2_68
    bsrl SCSIHW96
    jbra SREADPATCH2_6E
SREADPATCH2_68:         /* the BIOS variant (Quadra 800) */
    jbsr SCSIHW96BIOS
SREADPATCH2_6E:         /* return */
    rts

SREADPATCH2_70:         /* install the 53C96 SCSI Manager: SCSIINIT96 or SCSIINIT96BIOS */
    jbsr SREADPATCH2_52
    jbeq SREADPATCH2_7C
    bsrl SCSIINIT96
    jbra SREADPATCH2_82
SREADPATCH2_7C:         /* the BIOS variant (Quadra 800) */
    jbsr SCSIINIT96BIOS
SREADPATCH2_82:         /* return */
    rts

/*
 INIT96DREQPATCH / TESTC96DREQPATCH: where the 53C96's DREQ line is read: on the BIOS
 machines (the Quadra 800) bit 0 of the long at 0x50F03A00, on the others bit 9 of the
 long at 0xF9800024 (+68 the address, +352 the bit). TESTC96DREQPATCH tests it in d5.
*/
INIT96DREQPATCH:
    jbsr SREADPATCH2_52
    jbne INIT96DREQPATCH_12
    clrb %a4@(352)
    movel #1357920768,%a4@(68)	/* 0x50F03A00, bit 0 */
    rts
INIT96DREQPATCH_12:     /* the other variant: bit 9 at 0xF9800024 */
    moveb #9,%a4@(352)
    movel #-109051868,%a4@(68)
    rts
TESTC96DREQPATCH:       /* DREQ bit set in d5? */
    moveb %a4@(352),%d0
    btst %d0,%d5
    rts
    .fill   0x128, 1, 0x00

/*
 SCSI96 / SCSIMGR_96: the selector routines of the other 53C96 variant (SCSIINIT96, on
 machines with AddrMapFlags bit 21; not used on the Quadra 800, which runs the BIOS
 variant in os/scsibios.s). The same structure as SCSIMGR_96_BIOS, with up to two buses
 (the target's bus from the per-ID bits at +460/+464) and four more selectors (14..17,
 from the table at +496). Selector routines and their labels mirror the BIOS ones.
*/
SCSI96:
SCSIMGR_96:             /* pop the selector; 0..13 through the table at +0 */
    moveal %sp@+,%a0	| 40898A20
    movew %sp@+,%d0	| 40898A22
    movel %a0,%sp@-	| 40898A24
    linkw %fp,#-6	| 40898A26
    moveml %d2-%d7/%a2-%a5,%sp@-	| 40898A2A
    moveal SCSIGlobals,%a4	| 40898A2E
    moveal %a4@(64),%a3	| 40898A32
    moveq #0,%d7	| 40898A36
    moveq #0,%d4	| 40898A38
    movew %d0,%d1	| 40898A3A
    cmpiw #14,%d0	| 40898A3C
    jbcc SCSI96_28	| 40898A40
    moveal %a4@(0,%d0:w:4),%a0	| 40898A42
    jmp %a0@	| 40898A46
SCSI96_28:              /* 14..17: the extra selectors (table at +496) */
    cmpiw #18,%d0	| 40898A48
    jbcc UNIMPLEMENTED_96	| 40898A4C
    subiw #14,%d0	| 40898A4E
    lea %a4@(496),%a0	| 40898A52
    moveal %a0@(0,%d0:w:4),%a0	| 40898A56
    jmp %a0@	| 40898A5A

SCSIMGR_96_3C:          /* return, popping d0 bytes of parameters */
    moveml %sp@+,%d2-%d7/%a2-%a5
    unlk %fp
    moveal %sp@+,%a0
    addaw %d0,%sp
    jmp %a0@

SCSIMGR_96_48:          /* bus free (+97) */
    moveb %d7,%a4@(97)
    rts
UNIMPLEMENTED_96:       /* a selector it does not have: system error 12 */
    moveq #12,%d0	| 40898A6E
    _SysError	| 40898A70
UNIMPLEMENTED_96_4:     /* (hang) */
    jbra UNIMPLEMENTED_96_4	| 40898A72
DOSCSISTAT_96:          /* SCSIStat (10): the 5380-style bus status (+324) with the phase from each bus's 53C96; raw words first (clear the phase bits, save a3) */
    .long   0x026CFFF2, 0x01442F0B	| 40898A74
    moveq #0,%d1
    moveal %a4@(452),%a3
    moveb %a3@(64),%d1
    btst #1,0xdd0
    jbeq DOSCSISTAT_96_22
    moveal %a4@(456),%a3
    orb %a3@(64),%d1
DOSCSISTAT_96_22:       /* phase bits, REQ when connected */
    moveal %sp@+,%a3
    andib #7,%d1
    lslb #2,%d1
    orw %d1,%a4@(324)
    movew %a4@(324),%fp@(8)
    jbra DOSCSIRESET_96_40

DOSCSIRESET_96:         /* SCSIReset (0): reset each bus (+420), clear the state, wait about 512 ms */
    movel %a3,%sp@-
    moveal %a4@(420),%a0
    moveal %a4@(452),%a3
    jsr %a0@
    btst #1,0xdd0
    jbeq DOSCSIRESET_96_1E
    moveal %a4@(420),%a0
    moveal %a4@(456),%a3
    jsr %a0@
DOSCSIRESET_96_1E:      /* clear the state, then the delay */
    moveal %sp@+,%a3
    clrl %a4@(324)
    movew %d7,%fp@(8)
    jbsr SCSIMGR_96_48
    moveq #0,%d2
    movew TimeDBRA,%d2
    lsll #8,%d2
    lsll #1,%d2
    movel %d2,%d3
    swap %d3
DOSCSIRESET_96_38:      /* delay */
    dbf %d2,DOSCSIRESET_96_38
    dbf %d3,DOSCSIRESET_96_38
DOSCSIRESET_96_40:      /* return 0 */
    moveq #0,%d0
    jbra SCSIMGR_96_3C

DOSCSIGET_96:           /* SCSIGet (1): the bus is ours unless already busy (7) */
    bset #0,%a4@(97)
    jbne DOSCSIGET_96_16
    movew #66,%a4@(324)
    moveq #0,%d0
DOSCSIGET_96_10:        /* result */
    movew %d0,%fp@(8)
    jbra DOSCSIRESET_96_40
DOSCSIGET_96_16:        /* busy: 7 (scMgrBusyErr) */
    moveq #7,%d0
    jbra DOSCSIGET_96_10
DOSCSISELATN_D96:
DOSCSISELECT_D96:       /* SCSISelect / SCSISelAtn (2, 11) with two buses: the target ID picks the bus, then the selection starts */
    bset #0,%a4@(97)
    movew %a4@(324),%sp@-
    movew #64,%sp@
    moveq #0,%d6
    movew %fp@(8),%d6
    cmpiw #11,%d1
    jbne DOSCSISELATN_D96_22
    bset #16,%d6
    oriw #512,%sp@
DOSCSISELATN_D96_22:    /* which bus has this ID (+464, +460)? */
    movel %d6,%a4@(320)
    btst %d6,%a4@(464)
    jbne DOSCSISELATN_D96_4C
    moveal %a4@(452),%a3
    movel %a3,%a4@(64)
    moveal %a4@(68),%a0
    movel %d6,%d0
    jbsr DOSCSIMSGOUT_96_1C
    jbne DOSCSISELATN_D96_46
    bset %d6,%a4@(460)
    jbra DOSCSISELATN_D96_64
DOSCSISELATN_D96_46:    /* the first bus? */
    btst %d6,%a4@(460)
    jbne DOSCSISELATN_D96_76
DOSCSISELATN_D96_4C:    /* the second bus: its chip (+456) becomes the current one (+64) */
    moveal %a4@(456),%a3
    movel %a3,%a4@(64)
    moveal %a4@(72),%a0
    movel %d6,%d0
    jbsr DOSCSIMSGOUT_96_1C
    jbne DOSCSISELATN_D96_76
    bset %d6,%a4@(464)
DOSCSISELATN_D96_64:    /* selected: keep the state, result */
    movew %sp@+,%a4@(324)
    movel %a0,%a4@(316)
    movew %d0,%fp@(10)
    moveq #2,%d0
    jbra SCSIMGR_96_3C
DOSCSISELATN_D96_76:    /* selection failed: error */
    clrw %sp@
    movel %d0,%sp@-
    jbsr SCSIMGR_96_48
    movel %sp@+,%d0
    moveq #2,%d6
    jbsr ERROR
    movew %sp@+,%a4@(324)
    movew %d0,%fp@(10)
    moveq #2,%d0
    jbra SCSIMGR_96_3C

/* DOSCSISELATN_S96 / DOSCSISELECT_S96: SCSISelAtn / SCSISelect on the 53C96. */
DOSCSISELATN_S96:
DOSCSISELECT_S96:       /* SCSISelect for one bus (raw words; the same as DOSCSISELECT_S96_BIOS) */
    .short  0x08EC	| 40898B9E
    .long   0x00000061, 0x3F2C0144, 0x3EBC0040, 0x7000302E	| 40898BA0
    .long   0x00080C41, 0x000B6608, 0x08C00010, 0x00570200	| 40898BB0
    .long   0x29460140, 0x206C0044	| 40898BC0
    jbsr DOSCSIMSGOUT_96_1C
    jbne DOSCSISELATN_D96_76
    movew %sp@+,%a4@(324)
    movel %a0,%a4@(316)
    movew %d0,%fp@(10)
    moveq #2,%d0
    jbra SCSIMGR_96_3C

DOSCSICMD_96:           /* SCSICmd (3): send the command bytes */
    moveal %fp@(10),%a2
    movew %fp@(8),%d2
    jbsr DOSCSIMSGOUT_96_CE
    jbne DOSCSICMD_96_18
DOSCSICMD_96_E:         /* result */
    movew %d0,%fp@(14)
    moveq #6,%d0
    jbra SCSIMGR_96_3C
DOSCSICMD_96_18:        /* error */
    movel %d0,%sp@-
    jbsr SCSIMGR_96_48
    movel %sp@+,%d0
    moveq #3,%d6
    jbsr ERROR
    jbra DOSCSICMD_96_E

NEWSCSIWBLIND_96:       /* SCSIWBlind (9): d4 = 44 */
    moveq #44,%d4
    jbra NEWSCSIREAD_96_2

NEWSCSIWRITE_96:        /* SCSIWrite (6): d4 = 36 */
    moveq #36,%d4
    jbra NEWSCSIREAD_96_2

NEWSCSIRBLIND_96:       /* SCSIRBlind (8): d4 = 40 */
    moveq #40,%d4
    jbra NEWSCSIREAD_96_2

NEWSCSIREAD_96:         /* SCSIRead (5): d4 = 32 */
    moveq #32,%d4
NEWSCSIREAD_96_2:       /* the TIB */
    moveal %fp@(8),%a1
    jbra NEWSCSIREAD_96_20
NEWSCSIREAD_96_8:       /* scComp: the compare routine */
    bset #4,%d4
NEWSCSIREAD_96_C:       /* scInc: transfer (vector +412), advance the pointer */
    moveal %a4@(412),%a0	/* vector +412: TRANSFER; 53C96 BIOS: TRANSFER_96_BIOS */
    jsr %a0@
    jbne NEWSCSIREAD_96_72
    addl %d1,%a1@(2)
    bclr #4,%d4
NEWSCSIREAD_96_1C:      /* next instruction */
    lea %a1@(10),%a1
NEWSCSIREAD_96_20:      /* opcode, address, count */
    movew %a1@,%d1
    moveal %a1@(2),%a2
    movel %a1@(6),%d2
    cmpiw #8,%d1
    jbhi NEWSCSIREAD_96_48
    addw %d1,%d1
    jmp %pc@(NEWSCSIREAD_96_36,%d1:w)
NEWSCSIREAD_96_36:      /* dispatch on the opcode */
    bras NEWSCSIREAD_96_48
    bras NEWSCSIREAD_96_C
    bras NEWSCSIREAD_96_4C
    bras NEWSCSIREAD_96_56
    bras NEWSCSIREAD_96_5A
    bras NEWSCSIREAD_96_60
    bras NEWSCSIREAD_96_1C
    bras NEWSCSIREAD_96_70
    bras NEWSCSIREAD_96_8
NEWSCSIREAD_96_48:      /* bad opcode: 4 (scBadParmsErr) */
    moveq #4,%d0
    jbra NEWSCSIREAD_96_72
NEWSCSIREAD_96_4C:      /* scNoInc: transfer */
    moveal %a4@(412),%a0	/* vector +412: TRANSFER; 53C96 BIOS: TRANSFER_96_BIOS */
    jsr %a0@
    jbne NEWSCSIREAD_96_72
    jbra NEWSCSIREAD_96_1C
NEWSCSIREAD_96_56:      /* scAdd */
    addl %d2,%a2@
    jbra NEWSCSIREAD_96_1C
NEWSCSIREAD_96_5A:      /* scMove */
    moveal %d2,%a0
    movel %a2@,%a0@
    jbra NEWSCSIREAD_96_1C
NEWSCSIREAD_96_60:      /* scLoop */
    tstl %d2
    jbeq NEWSCSIREAD_96_1C
    subql #1,%d2
    movel %d2,%a1@(6)
    jbeq NEWSCSIREAD_96_1C
    addal %a2,%a1
    jbra NEWSCSIREAD_96_20
NEWSCSIREAD_96_70:      /* scStop: 0 */
    moveq #0,%d0
NEWSCSIREAD_96_72:      /* result */
    movew %d0,%fp@(12)
    moveq #4,%d0
    jbra SCSIMGR_96_3C
DOSCSICOMPLETE_96:      /* SCSIComplete (4): raw words first: d4 = Ticks + the wait */
    .short  0x3F07, 0x2838, 0x016A, 0xD8AE, 0x0008	| 40898C90
DOSCSICOMPLETE_96_A:    /* command sent / selection pending? (state +344) */
    btst #4,%a4@(344)
    jbne DOSCSICOMPLETE_96_AC
    btst #3,%a4@(344)
    jbne DOSCSICOMPLETE_96_6E
DOSCSICOMPLETE_96_1C:   /* status phase? */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #3,%d3
    jbne DOSCSICOMPLETE_96_CE
    moveb #17,%a3@(48)
    jbsr WAITFORSCSIINTRP
    jbeq DOSCSICOMPLETE_96_EE
    moveq #0,%d2
    moveb %a3@(32),%d2
    moveal %fp@(16),%a1
    movew %d2,%a1@
    moveb %a3@(32),%d2
    moveal %fp@(12),%a1
    movew %d2,%a1@
    moveb #18,%a3@(48)
    jbsr WAITFORSCSIINTRP
    jbeq DOSCSICOMPLETE_96_EE
DOSCSICOMPLETE_96_5C:   /* done */
    clrl %a4@(324)
    movew %sp@+,%fp@(20)
    jbsr SCSIMGR_96_48
    moveq #12,%d0
    jbra SCSIMGR_96_3C
DOSCSICOMPLETE_96_6E:   /* another phase: with ATN pending, a message out first */
    moveq #7,%d3
    andb %a3@(64),%d3
    btst #2,%a4@(344)
    jbeq DOSCSICOMPLETE_96_90
    cmpib #6,%d3
    jbeq DOSCSICOMPLETE_96_CE
    bclr #2,%a4@(344)
    bset #4,%a4@(344)
    jbra DOSCSICOMPLETE_96_AC
DOSCSICOMPLETE_96_90:   /* selected but no command sent? */
    btst #1,%a4@(344)
    jbeq DOSCSICOMPLETE_96_CE
    cmpib #2,%d3
    jbeq DOSCSICOMPLETE_96_CE
    bclr #1,%a4@(344)
    bset #4,%a4@(344)
    nop
DOSCSICOMPLETE_96_AC:   /* a pending interrupt: take it */
    btst #7,%a3@(64)
    jbeq DOSCSICOMPLETE_96_DC
    jbsr WAITFORSCSIINTRP
    moveb #1,%a3@(48)
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    jbra DOSCSICOMPLETE_96_1C
DOSCSICOMPLETE_96_CE:   /* other phase: 5, bit-bucket it (CYCLEPHASE) */
    movew #5,%sp@
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr %a4@(0x1dc,%za0)@(0)	| 40898D62
    jbeq DOSCSICOMPLETE_96_DC
    movew %d0,%sp@
DOSCSICOMPLETE_96_DC:   /* until the timeout */
    cmpl Ticks,%d4
    jbhi DOSCSICOMPLETE_96_A
    btst #4,%a4@(344)
    jbeq DOSCSICOMPLETE_96_5C
DOSCSICOMPLETE_96_EE:   /* timeout: 2 */
    movew #2,%sp@
    movel %sp@,%d0
    moveq #4,%d6
    jbsr ERROR
    jbra DOSCSICOMPLETE_96_5C

DOSCSIMSGIN_96:         /* SCSIMsgIn (12): read a message byte */
    jbsr DOSCSIMSGOUT_96_15C
    jbne DOSCSIMSGIN_96_16
    moveal %fp@(8),%a1
    movew %d2,%a1@
DOSCSIMSGIN_96_C:       /* result */
    movew %d0,%fp@(12)
    moveq #4,%d0
    jbra SCSIMGR_96_3C
DOSCSIMSGIN_96_16:      /* error */
    moveq #12,%d6
    jbsr ERROR
    jbra DOSCSIMSGIN_96_C
DOSCSIMSGOUT_96:        /* SCSIMsgOut (13): send a message byte (raw: d2 = the byte) */
    .long   0x342E0008	| 40898DAC
    jbsr DOSCSIMSGOUT_96_196
    jbne DOSCSIMSGOUT_96_14
DOSCSIMSGOUT_96_A:      /* result */
    movew %d0,%fp@(10)
    moveq #2,%d0
    jbra SCSIMGR_96_3C
DOSCSIMSGOUT_96_14:     /* error */
    moveq #12,%d6
    jbsr ERROR
    jbra DOSCSIMSGOUT_96_A

DOSCSIMSGOUT_96_1C:     /* start a selection (0xC1 without, 0xC2 with ATN) and wait for it */
    moveb %d0,%a3@(64)
    swap %d0
    addib #0xc1,%d0
    moveb #1,%a3@(48)
    moveb %d7,%a3@(16)
    moveb #1,%a3@
    moveb %d0,%a3@(48)
    bset #3,%a4@(344)
    cmpib #0xc1,%d0
    beqw DOSCSIMSGOUT_96_4E
    bset #2,%a4@(344)
    jbra DOSCSIMSGOUT_96_54
DOSCSIMSGOUT_96_4E:     /* without ATN: ready for the command */
    bset #1,%a4@(344)
DOSCSIMSGOUT_96_54:     /* wait for the interrupt (selection timeout) */
    moveq #0,%d1
    movew TimeSCSIDB,%d1
    lsll #8,%d1
    lsll #1,%d1
    movel %d1,%d2
    swap %d2
    moveq #-1,%d3
    moveq #-1,%d4
DOSCSIMSGOUT_96_66:     /* sequence step: how far the selection got */
    lsll #8,%d4
    moveb %a3@(96),%d4
    moveb %d4,%d0
    andib #7,%d0
    jbeq DOSCSIMSGOUT_96_86
    lsll #8,%d3
    moveb %a3@(64),%d3
    moveb %d3,%d0
    andib #7,%d0
    jbeq DOSCSIMSGOUT_96_86
DOSCSIMSGOUT_96_82:     /* selected: 0 */
    moveq #0,%d0
    rts
DOSCSIMSGOUT_96_86:     /* poll the status register */
    lsll #8,%d3
    moveb %a3@(64),%d3
    moveb %d3,%d0
    btst #7,%d0
    dbne %d1,DOSCSIMSGOUT_96_66
    dbne %d2,DOSCSIMSGOUT_96_66
    bnew DOSCSIMSGOUT_96_A4
    moveq #3,%d0
    braw DOSCSIMSGOUT_96_CA
DOSCSIMSGOUT_96_A4:     /* interrupt: keep the status and interrupt registers, clear the state */
    moveb %a3@(64),%d3
    moveb %a3@(80),%d1
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    bclr #2,%a4@(344)
    bclr #1,%a4@(344)
    btst #5,%d1
    jbeq DOSCSIMSGOUT_96_82
DOSCSIMSGOUT_96_CA:     /* timed out: 2 */
    moveq #2,%d0
    rts

DOSCSIMSGOUT_96_CE:     /* send the command bytes (command phase): FIFO, the last one by pseudo-DMA */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #2,%d3
    jbne DOSCSIMSGOUT_96_152
    orib #0x80,%a3@(128)
    subql #1,%d2
    jbra DOSCSIMSGOUT_96_E8
DOSCSIMSGOUT_96_E4:     /* one byte into the FIFO */
    moveb %a2@+,%a3@(32)
DOSCSIMSGOUT_96_E8:     /* next; then in 32-bit mode */
    dbf %d2,DOSCSIMSGOUT_96_E4
    jsr %pc@(SCSIPCTO32BIT)
    moveb MMU32Bit,%sp@-
    moveq #1,%d0
    _SwapMMUMode
    moveal %a4@(316),%a0
DOSCSIMSGOUT_96_FC:     /* wait for DREQ */
    movel %a0@,%d5
    jbsr TESTC96DREQPATCH
    jbeq DOSCSIMSGOUT_96_FC
    moveb %sp@+,%d0
    _SwapMMUMode
    moveb %a2@+,%a3@(256)
    bclr #1,%a4@(344)
    jbeq DOSCSIMSGOUT_96_11A
    bset #4,%a4@(344)
DOSCSIMSGOUT_96_11A:    /* still the command phase? */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #2,%d3
    jbeq DOSCSIMSGOUT_96_132
DOSCSIMSGOUT_96_126:    /* 0 */
    moveq #0,%d0
DOSCSIMSGOUT_96_128:    /* slow cable mode off, return */
    andib #127,%a3@(128)
    tstw %d0
    rts
DOSCSIMSGOUT_96_132:    /* wait for the phase to change */
    movel %d7,%d0
    movew TimeSCSIDB,%d0
    lsll #8,%d0
    movel %d0,%d2
    swap %d2
DOSCSIMSGOUT_96_13E:    /* poll */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #2,%d3
    dbne %d0,DOSCSIMSGOUT_96_13E
    dbne %d2,DOSCSIMSGOUT_96_13E
    jbra DOSCSIMSGOUT_96_126
DOSCSIMSGOUT_96_152:    /* error 5 */
    moveq #5,%d0
    moveq #3,%d6
    jbsr ERROR
    jbra DOSCSIMSGOUT_96_128

DOSCSIMSGOUT_96_15C:    /* message in: read the byte, accept it */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #7,%d3
    jbne DOSCSIMSGOUT_96_18C
    moveb #16,%a3@(48)
    jbsr WAITFORSCSIINTRP
    jbeq DOSCSIMSGOUT_96_188
    moveb %a3@(32),%d2
    moveb #18,%a3@(48)
    jbsr WAITFORSCSIINTRP
    jbeq DOSCSIMSGOUT_96_188
    moveq #0,%d0
    rts
DOSCSIMSGOUT_96_188:    /* 2 */
    moveq #2,%d0
    jbra DOSCSIMSGOUT_96_18E
DOSCSIMSGOUT_96_18C:    /* wrong phase: 5 */
    moveq #5,%d0
DOSCSIMSGOUT_96_18E:    /* return */
    clrl %a4@(324)
    tstl %d0
    rts

DOSCSIMSGOUT_96_196:    /* message out: send the byte (message out phase) */
    moveb %a3@(64),%d3
    andib #7,%d3
    cmpib #6,%d3
    jbeq DOSCSIMSGOUT_96_1DC
    btst #2,%a4@(344)
    jbeq DOSCSIMSGOUT_96_1D8
    moveq #0,%d1
    movew TimeSCSIDB,%d1
    lsll #8,%d1
    movel %d1,%d2
    swap %d2
DOSCSIMSGOUT_96_1B8:    /* an interrupt pending? the sequence step */
    btst #7,%a3@(64)
    bnew DOSCSIMSGOUT_96_1D8
    moveb %a3@(96),%d0
    andib #7,%d0
    jbne DOSCSIMSGOUT_96_1DC
    dbf %d1,DOSCSIMSGOUT_96_1B8
    dbf %d2,DOSCSIMSGOUT_96_1B8
    moveq #2,%d0
    jbra DOSCSIMSGOUT_96_1F0
DOSCSIMSGOUT_96_1D8:    /* error 5 */
    moveq #5,%d0
    jbra DOSCSIMSGOUT_96_1F0
DOSCSIMSGOUT_96_1DC:    /* the byte into the FIFO */
    moveb %d2,%a3@(32)
    bclr #2,%a4@(344)
    jbeq DOSCSIMSGOUT_96_1EE
    bset #1,%a4@(344)
DOSCSIMSGOUT_96_1EE:    /* 0 */
    moveq #0,%d0
DOSCSIMSGOUT_96_1F0:    /* clear ATN (+324), return */
    andiw #-513,%a4@(324)
    tstw %d0
    rts
CYCLEPHASE_96:          /* get the bus to the status phase (CYCLEPHASE_96_BIOS): only while the bus is taken */
    btst #0,%a4@(97)	| 40898FA6
    jbeq CYCLEPHASE_96_3C	| 40898FAC
CYCLEPHASE_96_8:        /* current phase */
    moveq #7,%d0	| 40898FAE
    andb %a3@(64),%d0	| 40898FB0
    cmpiw #1,%d0	| 40898FB4
    jbeq CYCLEPHASE_96_40	| 40898FB8
    cmpiw #0,%d0	| 40898FBA
    jbeq CYCLEPHASE_96_40	| 40898FBE
    cmpiw #2,%d0	| 40898FC0
    jbeq CYCLEPHASE_96_78	| 40898FC4
    cmpiw #6,%d0	| 40898FC6
    jbeq CYCLEPHASE_96_B0	| 40898FCA
    cmpiw #7,%d0	| 40898FCE
    jbeq CYCLEPHASE_96_D0	| 40898FD2
    cmpiw #3,%d0	| 40898FD6
    jbne CYCLEPHASE_96_3C	| 40898FDA
    movew #10,%d0	| 40898FDC
    rts	| 40898FE0
CYCLEPHASE_96_3C:       /* not in use: 0 */
    moveq #0,%d0	| 40898FE2
    rts	| 40898FE4
CYCLEPHASE_96_40:       /* data phase: a pending DMA transfer? */
    moveb %a3@(48),%d1	| 40898FE6
    cmpib #0x90,%d1	| 40898FEA
    jbne CYCLEPHASE_96_58	| 40898FEE
    tstb %a3@	| 40898FF0
    jbne CYCLEPHASE_96_E0	| 40898FF2
    tstb %a3@(16)	| 40898FF6
    jbne CYCLEPHASE_96_E0	| 40898FFA
CYCLEPHASE_96_58:       /* data out: send a byte; data in: read and drop one */
    cmpib #0,%d0	| 40898FFE
    jbeq CYCLEPHASE_96_6A	| 40899002
    jbsr XFER1BYTE	| 40899004
    jbne CYCLEPHASE_96_3C	| 40899008
    moveb %a3@(32),%d0	| 4089900A
    jbra CYCLEPHASE_96_8	| 4089900E
CYCLEPHASE_96_6A:       /* (40899010 moveb #-18,%a3@(32)) */
    moveb #0xee,%a3@(32)	| 40899010
    jbsr XFER1BYTE	| 40899016
    jbne CYCLEPHASE_96_3C	| 4089901A
    jbra CYCLEPHASE_96_8	| 4089901C
CYCLEPHASE_96_78:       /* command phase: 0xEE bytes */
    bclr #1,%a4@(344)	| 4089901E
    jbeq CYCLEPHASE_96_A0	| 40899024
    moveb #0xee,%a3@(256)	| 40899026
    bset #4,%a4@(344)	| 4089902C
    jbsr WAITFORSCSIINTRP	| 40899032
    jbeq CYCLEPHASE_96_9E	| 40899036
    bclr #4,%a4@(344)	| 40899038
    bclr #3,%a4@(344)	| 4089903E
CYCLEPHASE_96_9E:       /* again */
    jbra CYCLEPHASE_96_AC	| 40899044
CYCLEPHASE_96_A0:       /* (40899046 moveb #-18,%a3@(32)) */
    moveb #0xee,%a3@(32)	| 40899046
    jbsr XFER1BYTE	| 4089904C
    jbne CYCLEPHASE_96_3C	| 40899050
CYCLEPHASE_96_AC:       /* again */
    jbra CYCLEPHASE_96_8	| 40899052
CYCLEPHASE_96_B0:       /* message out: a no-operation (8) */
    bclr #2,%a4@(344)	| 40899056
    jbeq CYCLEPHASE_96_BE	| 4089905C
    bset #1,%a4@(344)	| 4089905E
CYCLEPHASE_96_BE:       /* send 8 (no operation) */
    moveb #8,%a3@(32)	| 40899064
    jbsr XFER1BYTE	| 4089906A
    jbne CYCLEPHASE_96_3C	| 4089906E
    jbra CYCLEPHASE_96_8	| 40899072
CYCLEPHASE_96_D0:       /* message in: read it, accept it */
    jbsr XFER1BYTE	| 40899076
    jbne CYCLEPHASE_96_3C	| 4089907A
    moveb %a3@(32),%d0	| 4089907E
    jbra CYCLEPHASE_96_8	| 40899082
CYCLEPHASE_96_E0:       /* in 32-bit mode, wait for DREQ or the interrupt */
    jsr %pc@(SCSIPCTO32BIT)	| 40899086
    moveb MMU32Bit,%sp@-	| 4089908A
    moveq #1,%d0	| 4089908E
    _SwapMMUMode	| 40899090
    moveal %a4@(316),%a0	| 40899092
    moveq #7,%d0	| 40899096
    andb %a3@(64),%d0	| 40899098
    cmpiw #0,%d0	| 4089909C
    jbeq CYCLEPHASE_96_118	| 408990A0
CYCLEPHASE_96_FC:       /* interrupt? */
    btst #7,%a3@(64)	| 408990A2
    jbne CYCLEPHASE_96_112	| 408990A8
    movel %a0@,%d5	| 408990AA
    jbsr TESTC96DREQPATCH	| 408990AC
    jbeq CYCLEPHASE_96_FC	| 408990B0
    movew %a3@(256),%d5	| 408990B2
    jbra CYCLEPHASE_96_FC	| 408990B6
CYCLEPHASE_96_112:      /* take it */
    jbsr WAITFORINTNOTIME	| 408990B8
    jbra CYCLEPHASE_96_134	| 408990BC
CYCLEPHASE_96_118:      /* interrupt? */
    btst #7,%a3@(64)	| 408990BE
    jbne CYCLEPHASE_96_130	| 408990C4
    movel %a0@,%d5	| 408990C6
    jbsr TESTC96DREQPATCH	| 408990C8
    jbeq CYCLEPHASE_96_118	| 408990CC
    movew #-4370,%a3@(256)	| 408990CE
    jbra CYCLEPHASE_96_118	| 408990D4
CYCLEPHASE_96_130:      /* take it */
    jbsr WAITFORINTNOTIME	| 408990D6
CYCLEPHASE_96_134:      /* back to the MMU mode, next phase */
    moveb %sp@+,%d0	| 408990DA
    _SwapMMUMode	| 408990DC
    jbra CYCLEPHASE_96_8	| 408990DE

/* SCSIPCTO32BIT: run the SCSI code in 32-bit mode (convert the PC). */
SCSIPCTO32BIT:
    movel %sp@,%d0
    _Translate24To32
    movel %d0,%sp@
    rts

/* ERROR: report an error through the error routine. */
ERROR:
    moveal %a4@(468),%a0	/* vector +468: SCSIERR; 53C96 BIOS: SCSIERR_96_BIOS */
    jsr %a0@
    rts
SCSIERR_96:             /* SCSIERR (+468): nothing (rts) */
    .short  0x4E75, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408990F2 rts

/* SCSIHW96 / INITHW_SCSI96: reset and configure the 53C96. */
SCSIHW96:
INITHW_SCSI96:          /* initialise the 53C96: reset the chip, nop, flush the FIFO; configuration 1 = 0x47 (ID 7, no bus reset interrupt), 2 = 0, 3 = 4 */
    moveb #2,%a3@(48)
    clrb %a3@(48)
    moveb #1,%a3@(48)
    moveb #71,%a3@(128)
    clrb %a3@(176)
    moveb #4,%a3@(192)
    btst #3,0xdd2
    jbeq SCSIHW96_6E
    btst #2,0xdd0
    jbeq SCSIHW96_6E
    movel %a0,%sp@-
    moveal ghost_VIA2,%a0
    moveb %a0@,%d0
    moveal %sp@+,%a0
    btst #5,%d0
    jbeq SCSIHW96_48
    movel #65,%a4@
    jbra SCSIHW96_4E
SCSIHW96_48:            /* VIA 2 machine with DAFB (AddrMapFlags 11, 26): by VIA 2 PA5, 65 or 492 into the SCSI control register at a4 (0xF9800024) */
    movel #492,%a4@
SCSIHW96_4E:            /* universal info +18 = 16, or PA5 set: the faster settings; else clock factor 4, select timeout 126 */
    moveal 0xdd8,%a0
    cmpib #16,%a0@(18)
    jbeq SCSIHW96_6E
    btst #5,%d0
    jbne SCSIHW96_6E
    moveb #4,%a3@(144)
    moveb #126,%a3@(80)
    jbra SCSIHW96_7A
SCSIHW96_6E:            /* clock conversion factor 5, select timeout 0xA7 */
    moveb #5,%a3@(144)
    moveb #0xa7,%a3@(80)
SCSIHW96_7A:            /* clear the FIFO flags, read the interrupt register (clear it) */
    clrb %a3@(112)
    moveb %a3@(80),%d0
    rts

/*
 INTHND_SCSI96: SCSI interrupt (either bus): save the chip's status, FIFO flags and
 interrupt registers in the globals (+340), count it.
*/
INTHND_SCSI96:
    moveml %d0-%a5,%sp@-
    moveal SCSIGlobals,%a4
    moveq #0,%d5
    addql #1,%a4@(336)
    moveal %a4@(452),%a3
    btst #7,%a3@(64)
    jbne INTHND_SCSI96_26
    moveal %a4@(456),%a3
    btst #7,%a3@(64)
    jbeq INTHND_SCSI96_3C
INTHND_SCSI96_26:       /* keep the status, FIFO flags and interrupt registers in d5 */
    moveb %a3@(64),%d5
    swap %d5
    moveb %a3@(112),%d5
    lslw #8,%d5
    moveb %a3@(80),%d5
    swap %d5
    movel %d5,%a4@(340)
INTHND_SCSI96_3C:       /* restore registers, return */
    moveml %sp@+,%d0-%a5
    rts
CLEARIRQ_96:            /* CLEARIRQ (+364): read the interrupt register (clears it) */
    moveb %a3@(80),%d1
    jbra CLEARSCSIINT
    .short  0x4E75	| 408991D0

TRANSFER_96:            /* TRANSFER (+412): 5 (or 1 on a 68040) for the copy-back cache handling, then the transfer routine */
    linkw %fp,#-6
    moveq #5,%d0
    cmpib #4,CPUFlag
    jbne TRANSFER_96_10
    moveq #1,%d0
TRANSFER_96_10:         /* d1 = the count; the transfer routine with the bus error handler */
    movew %d0,%fp@(-6)
    moveq #0,%d0
    movel %d2,%d1
    jbeq TRANSFER_96_48
    moveml %d2-%d6/%a1-%a5,%sp@-
    moveal %a3,%a1
    addal #262144,%a1
    movel BusErrorVector,%a4@(448)
    movel %a4@(428),BusErrorVector
    lea %a4@(164),%a0
    moveal %a0@(0x0,%d4:l),%a0
    jsr %a0@
    movel %a4@(448),BusErrorVector
    moveml %sp@+,%d2-%d6/%a1-%a5
    tstw %d0
TRANSFER_96_48:         /* return */
    unlk %fp
    rts

/* ONEBYTEREAD / ONEBYTEWRITE / XFER1BYTE: transfer one byte by programmed I/O. */
ONEBYTEREAD:
    moveb #16,%a3@(48)
    jsr %pc@(WAITFORINTNOTIME)
    jbne ONEBYTEWRITE_14
    moveb %a3@(32),%a2@+
    moveb %a3@(80),%d3
    btst #5,%d3
    jbne ONEBYTEWRITE_14
    moveq #0,%d0
    rts
ONEBYTEWRITE:           /* write one byte by programmed I/O (transfer information) */
    moveb %a2@+,%a3@(32)
    moveb #16,%a3@(48)
    jsr %pc@(WAITFORINTNOTIME)
    jbne ONEBYTEWRITE_14
    moveq #0,%d0
    rts
ONEBYTEWRITE_14:        /* error 2 */
    movel #240,%d6
    moveq #2,%d0
    jbra ONEBYTEWRITE_26
ONEBYTEWRITE_1E:        /* error 5 */
    movel #240,%d6
    moveq #5,%d0
ONEBYTEWRITE_26:        /* record it, flush the FIFO */
    jbsr ERROR
    moveq #0,%d1
    moveb #1,%a3@(48)
    rts

XFER1BYTE:              /* transfer information (0x10) for one byte, wait for the interrupt */
    moveb #16,%a3@(48)
    jsr %pc@(WAITFORINTNOTIME)
    rts
SLOWREAD_96:            /* SLOWREAD (+196): polled read; a pending selection first */
    btst #4,%a4@(344)	| 4089927C
    jbne SLOWREAD_96_130	| 40899282
SLOWREAD_96_A:          /* data in phase? */
    moveq #7,%d0	| 40899286
    andb %a3@(64),%d0	| 40899288
    cmpiw #1,%d0	| 4089928C
    jbne ONEBYTEWRITE_1E	| 40899290
    moveq #0,%d6	| 40899292
    movel %d2,%d4	| 40899294
    lsrl #4,%d4	| 40899296
    jbeq SLOWREAD_96_EE	| 40899298
    subql #1,%d4	| 4089929C
    movel %d4,%d6	| 4089929E
    swap %d6	| 408992A0
    jsr %pc@(SCSIPCTO32BIT)	| 408992A2
    moveb MMU32Bit,%sp@-	| 408992A6
    moveq #1,%d0	| 408992AA
    _SwapMMUMode	| 408992AC
    movel %a2,%d0	| 408992AE
    _StripAddress	| 408992B0
    moveal %d0,%a2	| 408992B2
    moveal %a4@(316),%a0	| 408992B4
    moveb #1,%a3@(48)	| 408992B8
    clrb %a3@(16)	| 408992BE
    moveb #16,%a3@	| 408992C2
    andil #15,%d2	| 408992C6
SLOWREAD_96_50:         /* (408992CC moveb #-112,%a3@(48)) */
    moveb #0x90,%a3@(48)	| 408992CC
SLOWREAD_96_56:         /* wait for DREQ or the interrupt */
    btst #4,%a3@(64)	| 408992D2
    jbne SLOWREAD_96_7A	| 408992D8
    btst #7,%a3@(64)	| 408992DA
    jbne SLOWREAD_96_F6	| 408992E0
    moveq #7,%d5	| 408992E4
    andb %a3@(64),%d5	| 408992E6
    cmpib #1,%d5	| 408992EA
    jbeq SLOWREAD_96_56	| 408992EE
    tstb %a3@	| 408992F0
    jbeq SLOWREAD_96_56	| 408992F2
    jbra SLOWREAD_96_F6	| 408992F4
SLOWREAD_96_7A:         /* DREQ? */
    movel %a0@,%d5	| 408992F6
    jbsr TESTC96DREQPATCH	| 408992F8
    jbeq SLOWREAD_96_56	| 408992FC
    nop	| 408992FE
    movew %a1@(256),%a2@+	| 40899300
    movew %a1@(256),%a2@+	| 40899304
    movew %a1@(256),%a2@+	| 40899308
    movew %a1@(256),%a2@+	| 4089930C
    movew %a1@(256),%a2@+	| 40899310
    movew %a1@(256),%a2@+	| 40899314
    movew %a1@(256),%a2@+	| 40899318
    movew %a1@(256),%a2@+	| 4089931C
    nop	| 40899320
SLOWREAD_96_A6:         /* wait for the interrupt */
    btst #7,%a3@(64)	| 40899322
    jbeq SLOWREAD_96_A6	| 40899328
    moveb %a3@(80),%d5	| 4089932A
    btst #5,%d5	| 4089932E
    jbne SLOWREAD_96_116	| 40899332
    dbf %d4,SLOWREAD_96_50	| 40899334
    dbf %d6,SLOWREAD_96_50	| 40899338
    moveb %sp@+,%d0	| 4089933C
    _SwapMMUMode	| 4089933E
    jbra SLOWREAD_96_EE	| 40899340
SLOWREAD_96_C6:         /* still data in? */
    moveq #7,%d5
    andb %a3@(64),%d5
    cmpib #1,%d5
    jbne SLOWREAD_96_12C
    moveb #16,%a3@(48)
SLOWREAD_96_D8:         /* one byte from the FIFO */
    btst #7,%a3@(64)
    jbeq SLOWREAD_96_D8
    moveb %a3@(32),%a2@+
    moveb %a3@(80),%d5
    btst #5,%d5
    jbne SLOWREAD_96_144
SLOWREAD_96_EE:         /* next; 0 */
    dbf %d2,SLOWREAD_96_C6
    moveq #0,%d0
    rts
SLOWREAD_96_F6:         /* the bytes left in the FIFO */
    moveq #31,%d0	| 40899372
    andb %a3@(112),%d0	| 40899374
    jbra SLOWREAD_96_102	| 40899378
SLOWREAD_96_FE:         /* one byte */
    moveb %a3@(32),%a2@+	| 4089937A
SLOWREAD_96_102:        /* next; DREQ? */
    dbf %d0,SLOWREAD_96_FE	| 4089937E
    movel %a0@,%d5	| 40899382
    jbsr TESTC96DREQPATCH	| 40899384
    jbeq SLOWREAD_96_112	| 40899388
    movew %a3@(256),%d5	| 4089938A
SLOWREAD_96_112:        /* wait for the interrupt */
    jbsr WAITFORINTNOTIME	| 4089938E
SLOWREAD_96_116:        /* back to the MMU mode */
    moveb %sp@+,%d0	| 40899392
    _SwapMMUMode	| 40899394
    addqw #1,%d4	| 40899396
    swap %d6	| 40899398
    movew %d4,%d6	| 4089939A
    lsll #4,%d6	| 4089939C
    andib #7,%d5	| 4089939E
    cmpib #1,%d5
    beqs SLOWREAD_96_144
SLOWREAD_96_12C:        /* phase changed: 5 */
    moveq #5,%d0
    jbra SLOWREAD_96_146
SLOWREAD_96_130:        /* a selection was pending: finish it */
    bclr #4,%a4@(344)	| 408993AC
    bclr #3,%a4@(344)	| 408993B2
    jbsr WAITFORINTNOTIME	| 408993B8
    jbeq SLOWREAD_96_A	| 408993BC
SLOWREAD_96_144:        /* 2 */
    moveq #2,%d0
SLOWREAD_96_146:        /* d1 = bytes not transferred */
    addl %d2,%d6
    subl %d6,%d1
    moveq #5,%d6
    jbsr ERROR
    moveb #1,%a3@(48)
    rts
SLOWWRITE_96:           /* SLOWWRITE (+200): polled write; a pending selection first */
    btst #4,%a4@(344)
    jbne SLOWWRITE_96_C2
SLOWWRITE_96_A:         /* data out phase? */
    moveq #7,%d0
    andb %a3@(64),%d0
    jbne ONEBYTEWRITE_1E
    cmpil #1,%d2
    jbeq ONEBYTEWRITE
    movel %d2,%d6
    swap %d6
    andil #65535,%d2
    jbeq SLOWWRITE_96_96
SLOWWRITE_96_2A:        /* the transfer count (up to 64 KB at a time) */
    movel %d2,%d4
    moveb %d4,%a3@
    lsrl #8,%d4
    moveb %d4,%a3@(16)
    moveb #0x90,%a3@(48)
    nop
    movel %d2,%d4
    lsrl #4,%d4
    rorl #1,%d2
    andiw #7,%d2
    negw %d2
    jmp %pc@(SLOWWRITE_96_6E,%d2:w:4)
SLOWWRITE_96_4C:        /* words to the pseudo-DMA register */
    nop
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
SLOWWRITE_96_6E:        /* the FIFO level */
    nop
    moveq #31,%d0
    andb %a3@(112),%d0
    jbeq SLOWWRITE_96_82
    btst #7,%a3@(64)
    jbne SLOWWRITE_96_A4
    jbra SLOWWRITE_96_6E
SLOWWRITE_96_82:        /* next; an odd byte? */
    dbf %d4,SLOWWRITE_96_4C
    btst #31,%d2
    jbeq SLOWWRITE_96_90
    moveb %a2@+,%a3@(256)
SLOWWRITE_96_90:        /* wait for the interrupt */
    jbsr WAITFORINTNOTIME
    jbne SLOWWRITE_96_D6
SLOWWRITE_96_96:        /* next 64 KB */
    movel #65536,%d2
    dbf %d6,SLOWWRITE_96_2A
    moveq #0,%d0
    rts
SLOWWRITE_96_A4:        /* wait for the interrupt */
    jbsr WAITFORINTNOTIME
    btst #4,%d5
    jbne SLOWWRITE_96_96
    moveq #7,%d3
    andb %d5,%d3
    cmpib #0,%d3
    jbeq SLOWWRITE_96_D6
    moveq #5,%d0
    moveq #0,%d1
    clrl %a4@(324)
    jbra SLOWWRITE_96_D8
SLOWWRITE_96_C2:        /* a selection was pending: finish it */
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    jbsr WAITFORINTNOTIME
    jbeq SLOWWRITE_96_A
SLOWWRITE_96_D6:        /* 2 */
    moveq #2,%d0
SLOWWRITE_96_D8:        /* d1 = bytes not transferred */
    lsll #4,%d4
    swap %d6
    movew %d4,%d6
    moveq #31,%d2
    andb %a3@(112),%d2
    addl %d2,%d6
    subl %d6,%d1
    clrl %a4@(324)
    moveq #6,%d6
    jbsr ERROR
    moveb #1,%a3@(48)
    rts
FASTWRITE_96:           /* FASTWRITE (+208): blind write; a pending selection first */
    btst #4,%a4@(344)
    jbne FASTWRITE_96_CA
FASTWRITE_96_A:         /* data out phase? */
    moveq #7,%d0
    andb %a3@(64),%d0
    jbne ONEBYTEWRITE_1E
    cmpil #1,%d2
    jbeq ONEBYTEWRITE
    movel %d2,%d6
    swap %d6
    andil #65535,%d2
    jbeq FASTWRITE_96_AE
    movel %a2,%d5
    btst #0,%d5
    jbne FASTWRITE_96_BC
FASTWRITE_96_36:        /* the transfer count (up to 64 KB at a time) */
    movel %d2,%d4
    moveb %d4,%a3@
    lsrl #8,%d4
    moveb %d4,%a3@(16)
    moveb #0x90,%a3@(48)
    movew %d2,%d4
    lsrw #5,%d4
    rorl #1,%d2
    andiw #15,%d2
    negw %d2
    nop
    jmp %pc@(FASTWRITE_96_98,%d2:w:4)
FASTWRITE_96_58:        /* words to the pseudo-DMA register, unrolled */
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
    movew %a2@+,%a1@(256)
FASTWRITE_96_98:        /* next; an odd byte? */
    dbf %d4,FASTWRITE_96_58
    nop
    btst #31,%d2
    jbeq FASTWRITE_96_A8
    moveb %a2@+,%a3@(256)
FASTWRITE_96_A8:        /* wait for the interrupt */
    jbsr WAITFORINTNOTIME
    jbne FASTWRITE_96_DE
FASTWRITE_96_AE:        /* next 64 KB */
    movel #65536,%d2
    dbf %d6,FASTWRITE_96_36
    moveq #0,%d0
    rts
FASTWRITE_96_BC:        /* the odd byte through the FIFO */
    subql #1,%d2
    moveb %a2@+,%a3@(32)
    jbra FASTWRITE_96_36
    moveq #5,%d0
    jbra FASTWRITE_96_E0
FASTWRITE_96_CA:        /* a selection was pending: finish it */
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    jbsr WAITFORINTNOTIME
    jbeq FASTWRITE_96_A
FASTWRITE_96_DE:        /* 2 */
    moveq #2,%d0
FASTWRITE_96_E0:        /* d1 = bytes not transferred */
    swap %d6
    movew %d4,%d6
    lsll #5,%d6
    extl %d2
    addql #1,%d2
    addl %d2,%d6
    moveq #31,%d2
    andb %a3@(112),%d2
    addw %d2,%d6
    subl %d6,%d1
    clrl %a4@(324)
    moveq #9,%d6
    jbsr ERROR
    moveb #1,%a3@(48)
    rts
FASTREAD_96:            /* FASTREAD (+204): blind read; a pending selection first */
    btst #4,%a4@(344)
    jbne FASTREAD_96_CE
FASTREAD_96_A:          /* data in phase? */
    moveq #7,%d0
    andb %a3@(64),%d0
    cmpib #1,%d0
    jbne ONEBYTEWRITE_1E
    cmpil #1,%d2
    jbeq ONEBYTEREAD
    movel %d2,%d6
    swap %d6
    andil #65535,%d2
    beqw FASTREAD_96_AE
FASTREAD_96_30:         /* the transfer count (up to 64 KB at a time) */
    movel %d2,%d4
    moveb %d4,%a3@
    lsrl #8,%d4
    moveb %d4,%a3@(16)
    moveb #0x90,%a3@(48)
FASTREAD_96_30_10:
    movew %d2,%d4
    lsrw #5,%d4
    rorl #1,%d2
    andiw #15,%d2
    negw %d2
    nop
    jmp %pc@(FASTREAD_96_92,%d2:w:4)
FASTREAD_96_52:         /* words from the pseudo-DMA register, unrolled */
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
    movew %a1@(256),%a2@+
FASTREAD_96_92:         /* next; wait for the interrupt */
    dbf %d4,FASTREAD_96_52
    nop
    jbsr WAITFORINTNOTIME
    jbne FASTREAD_96_E2
    btst #31,%d2
    jbeq FASTREAD_96_AE
    bsrw WTFORFIFODATA
    jbeq FASTREAD_96_C6
    moveb %a3@(32),%a2@+
FASTREAD_96_AE:         /* next 64 KB */
    movel #65536,%d2
    dbf %d6,FASTREAD_96_30
    moveq #0,%d0
    rts
    subql #1,%d2
    moveb %a3@(32),%a2@+
    braw FASTREAD_96_30_10
FASTREAD_96_C6:         /* 9 / 5 */
    moveq #9,%d0
    jbra FASTREAD_96_E4
    moveq #5,%d0
    jbra FASTREAD_96_E4
FASTREAD_96_CE:         /* a selection was pending: finish it */
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    bsrw WAITFORINTNOTIME
    jbeq FASTREAD_96_A
FASTREAD_96_E2:         /* 2 */
    moveq #2,%d0
FASTREAD_96_E4:         /* d1 = bytes not transferred */
    swap %d6
    movew %d4,%d6
    lsll #5,%d6
    extl %d2
    addql #1,%d2
    addl %d2,%d6
    subl %d6,%d1
    clrl %a4@(324)
    moveq #8,%d6
    jbsr ERROR
    moveb #1,%a3@(48)
    rts

/* WTFORFIFODATA: wait until the FIFO has data (with a timeout). */
WTFORFIFODATA:
    moveml %d1-%d2,%sp@-
    movew TimeSCSIDB,%d1
    lsll #8,%d1
    movel %d1,%d2
    swap %d2
WTFORFIFODATA_E:        /* FIFO count non-zero? */
    moveq #31,%d0
    andb %a3@(112),%d0
    dbne %d1,WTFORFIFODATA_E
    dbne %d2,WTFORFIFODATA_E
    moveml %sp@+,%d1-%d2
    rts
RESETBUS_96:            /* RESETBUS (+420): the chip's reset bus command */
    moveb #3,%a3@(48)
    rts

/* WAITFORINTNOTIME: wait for the chip interrupt (no timeout), read its registers. */
WAITFORINTNOTIME:
    moveq #0,%d5
    moveb %a3@(64),%d5
    btst #7,%d5
    jbeq WAITFORINTNOTIME
    swap %d5
    moveb %a3@(112),%d5
    lslw #8,%d5
    moveb %a3@(80),%d5
    movel %d5,%d0
    swap %d5
    andib #48,%d0
    cmpib #16,%d0
    rts

/* WAITFORSCSIINTRP: wait for the chip interrupt with a timeout (Z set if it timed out). */
WAITFORSCSIINTRP:
    moveq #0,%d5
    moveq #0,%d3
    movew TimeSCSIDB,%d3
    lsll #8,%d3
    movel %d3,%d0
    swap %d0
WAITFORSCSIINTRP_E:     /* interrupt (status bit 7)? */
    moveb %a3@(64),%d5
    btst #7,%d5
    dbne %d3,WAITFORSCSIINTRP_E
    dbne %d0,WAITFORSCSIINTRP_E
    jbeq WAITFORSCSIINTRP_34
    swap %d5
    moveb %a3@(112),%d5
    lslw #8,%d5
    moveb %a3@(80),%d5
WAITFORSCSIINTRP_2C:    /* none: Z set */
    swap %d5
    btst #7,%d5
    rts
WAITFORSCSIINTRP_34:    /* read the interrupt: d5 = status, FIFO flags, interrupt registers */
    swap %d5
    moveb %a3@(112),%d5
    lslw #8,%d5
    clrb %d5
    jbra WAITFORSCSIINTRP_2C
FASTCOMP_96:            /* FASTCOMP (+220): blind compare; a pending selection first */
    btst #4,%a4@(344)	| 4089976A
    bnew FASTCOMP_96_7A	| 40899770
FASTCOMP_96_A:          /* data in phase? */
    moveq #7,%d0	| 40899774
    andb %a3@(64),%d0	| 40899776
    cmpib #1,%d0	| 4089977A
    jbne ONEBYTEWRITE_1E	| 4089977E
    cmpil #1,%d2	| 40899782
    jbeq SLOWCOMP_96	| 40899788
    moveq #0,%d3	| 4089978C
    movel %d2,%d6	| 4089978E
    swap %d6	| 40899790
    andil #65535,%d2	| 40899792
    jbeq FASTCOMP_96_68	| 40899798
FASTCOMP_96_30:         /* the transfer count */
    movel %d2,%d4
    moveb %d4,%a3@
    lsrl #8,%d4
    moveb %d4,%a3@(16)
    moveb #0x90,%a3@(48)
    rorl #1,%d2
    subqw #1,%d2
FASTCOMP_96_44:         /* compare a word from the pseudo-DMA register */
    movew %a3@(256),%d0
    cmpw %a2@+,%d0
    jbeq FASTCOMP_96_4E
    moveq #6,%d3
FASTCOMP_96_4E:         /* next; wait for the interrupt */
    dbf %d2,FASTCOMP_96_44
    jbsr WAITFORINTNOTIME
    jbne FASTCOMP_96_8E
    btst #31,%d2
    jbeq FASTCOMP_96_68
    moveb %a3@(32),%d0
    cmpb %a2@+,%d0
    jbeq FASTCOMP_96_68
    moveq #6,%d3
FASTCOMP_96_68:         /* next 64 KB */
    movel #65536,%d2
    dbf %d6,FASTCOMP_96_30
    movel %d3,%d0
    rts
    moveq #5,%d0
    jbra FASTCOMP_96_90
FASTCOMP_96_7A:         /* a selection was pending: finish it */
    bclr #4,%a4@(344)	| 408997E4
    bclr #3,%a4@(344)	| 408997EA
    jbsr WAITFORINTNOTIME	| 408997F0
    jbeq FASTCOMP_96_A	| 408997F4
FASTCOMP_96_8E:         /* 2 */
    moveq #2,%d0
FASTCOMP_96_90:         /* d1 = bytes not compared */
    swap %d6
    movew %d4,%d6
    lsll #5,%d6
    extl %d2
    addql #1,%d2
    addl %d2,%d6
    subl %d6,%d1
    clrl %a4@(324)
    movel #248,%d6
    jbsr ERROR
    moveb #1,%a3@(48)
    rts
SLOWCOMP_96:            /* SLOWCOMP (+212): polled compare; a pending selection first */
    btst #4,%a4@(344)	| 4089981E
    jbne SLOWCOMP_96_F0	| 40899824
SLOWCOMP_96_A:          /* data in phase? */
    moveq #7,%d0	| 40899828
    andb %a3@(64),%d0	| 4089982A
    cmpiw #1,%d0	| 4089982E
    jbne ONEBYTEWRITE_1E	| 40899832
    moveq #0,%d3	| 40899836
    movel %d2,%d4	| 40899838
    lsrl #4,%d4	| 4089983A
    jbeq SLOWCOMP_96_CA	| 4089983C
    subql #1,%d4	| 40899840
    movel %d4,%d6	| 40899842
    swap %d6	| 40899844
    jsr %pc@(SCSIPCTO32BIT)	| 40899846
    moveb MMU32Bit,%sp@-	| 4089984A
    moveq #1,%d0	| 4089984E
    _SwapMMUMode	| 40899850
    movel %a2,%d0	| 40899852
    _StripAddress	| 40899854
    moveal %d0,%a2	| 40899856
    moveal %a4@(316),%a0	| 40899858
    clrb %a3@(16)	| 4089985C
    moveb #16,%a3@	| 40899860
    andil #15,%d2	| 40899864
SLOWCOMP_96_4C:         /* (4089986A moveb #-112,%a3@(48)) */
    moveb #0x90,%a3@(48)	| 4089986A
SLOWCOMP_96_52:         /* wait for DREQ or the interrupt */
    btst #7,%a3@(64)	| 40899870
    jbne SLOWCOMP_96_D2	| 40899876
    btst #4,%a3@(64)	| 40899878
    jbeq SLOWCOMP_96_52	| 4089987E
    movel %a0@,%d5	| 40899880
    jbsr TESTC96DREQPATCH	| 40899882
    jbeq SLOWCOMP_96_52	| 40899886
    movew #7,%d5	| 40899888
SLOWCOMP_96_6E:         /* compare a word */
    movew %a3@(256),%d0	| 4089988C
    cmpw %a2@+,%d0	| 40899890
    jbeq SLOWCOMP_96_78	| 40899892
    moveq #6,%d3	| 40899894
SLOWCOMP_96_78:         /* next */
    dbf %d5,SLOWCOMP_96_6E	| 40899896
SLOWCOMP_96_7C:         /* wait for the interrupt */
    btst #7,%a3@(64)	| 4089989A
    jbeq SLOWCOMP_96_7C	| 408998A0
    moveb %a3@(80),%d5	| 408998A2
    btst #5,%d5	| 408998A6
    jbne SLOWCOMP_96_D6	| 408998AA
    dbf %d4,SLOWCOMP_96_4C	| 408998AC
    dbf %d6,SLOWCOMP_96_4C	| 408998B0
    moveb %sp@+,%d0	| 408998B4
    _SwapMMUMode	| 408998B6
    jbra SLOWCOMP_96_CA	| 408998B8
SLOWCOMP_96_9C:         /* still data in? */
    moveq #7,%d5
    andb %a3@(64),%d5
    cmpib #1,%d5
    jbne SLOWCOMP_96_EC
    moveb #16,%a3@(48)
SLOWCOMP_96_AE:         /* one byte from the FIFO, compare */
    btst #7,%a3@(64)
    jbeq SLOWCOMP_96_AE
    moveb %a3@(32),%d0
    cmpb %a2@+,%d0
    jbeq SLOWCOMP_96_C0
    moveq #6,%d3
SLOWCOMP_96_C0:         /* disconnected? */
    moveb %a3@(80),%d5
    btst #5,%d5
    jbne SLOWCOMP_96_104
SLOWCOMP_96_CA:         /* next */
    dbf %d2,SLOWCOMP_96_9C
    movel %d3,%d0
    rts
SLOWCOMP_96_D2:         /* wait for the interrupt */
    jbsr WAITFORINTNOTIME	| 408998F0
SLOWCOMP_96_D6:         /* back to the MMU mode */
    moveb %sp@+,%d0	| 408998F4
    _SwapMMUMode	| 408998F6
    addqw #1,%d4	| 408998F8
    swap %d6	| 408998FA
    movew %d4,%d6	| 408998FC
    lsll #4,%d6	| 408998FE
    andib #7,%d5	| 40899900
    cmpib #1,%d5
    beqs SLOWCOMP_96_104
SLOWCOMP_96_EC:         /* phase changed: 5 */
    moveq #5,%d0
    jbra SLOWCOMP_96_106
SLOWCOMP_96_F0:         /* a selection was pending: finish it */
    bclr #4,%a4@(344)	| 4089990E
    bclr #3,%a4@(344)	| 40899914
    jbsr WAITFORINTNOTIME	| 4089991A
    jbeq SLOWCOMP_96_A	| 4089991E
SLOWCOMP_96_104:        /* 2 */
    moveq #2,%d0
SLOWCOMP_96_106:        /* d1 = bytes not compared */
    addl %d2,%d6
    subl %d6,%d1
    movel #245,%d6
    jbsr ERROR
    moveb #1,%a3@(48)
    rts
BUSERRHANDLER_96:       /* BUSERRHANDLER (+428): a fault at either chip's pseudo-DMA register (+256, or +256+0x40000)? retry; any other bus error goes to the saved handler (+448) */
    movel %d0,%sp@-
    movel ToolDispTable,%d0
    addil #256,%d0
    cmpl %sp@(24),%d0
    jbeq BUSERRHANDLER_96_4E
    addil #262144,%d0
    cmpl %sp@(24),%d0
    jbeq BUSERRHANDLER_96_4E
    movel 0x1ff0,%d0
    addil #256,%d0
    cmpl %sp@(24),%d0
    jbeq BUSERRHANDLER_96_4E
    addil #262144,%d0
    cmpl %sp@(24),%d0
    jbeq BUSERRHANDLER_96_4E
    movel %sp@+,%d0
    clrl %sp@-
    movel %a0,%sp@-
    moveal SCSIGlobals,%a0
    movel %a0@(448),%sp@(4)
    moveal %sp@+,%a0
    rts
BUSERRHANDLER_96_4E:    /* retries left? wait and retry (rte) */
    subqw #1,%fp@(-6)
    jbeq BUSERRHANDLER_96_62
    movew TimeDBRA,%d0
    lsrw #4,%d0
BUSERRHANDLER_96_5A:    /* wait */
    dbf %d0,BUSERRHANDLER_96_5A
    movel %sp@+,%d0
    rte
BUSERRHANDLER_96_62:    /* give up: drop the exception frame (format 7: 60 bytes, A: 32, else 92) */
    addql #4,%sp
    movew %sp@,%d0
    bfextu %sp@(6),0,4,%d1
    cmpib #7,%d1
    jbeq BUSERRHANDLER_96_7E
    cmpib #10,%d1
    jbne BUSERRHANDLER_96_84
    lea %sp@(32),%sp
    jbra BUSERRHANDLER_96_88
BUSERRHANDLER_96_7E:    /* format 7 (68040 access error) */
    lea %sp@(60),%sp
    jbra BUSERRHANDLER_96_88
BUSERRHANDLER_96_84:    /* format B */
    lea %sp@(92),%sp
BUSERRHANDLER_96_88:    /* a new short frame: rte to BUSERRHANDLER_96_92 */
    movew %d7,%sp@-
    pea %pc@(BUSERRHANDLER_96_92)
    movew %d0,%sp@-
    rte
BUSERRHANDLER_96_92:    /* 9, or 5 if the chip interrupted for a new phase (bus service) */
    moveq #9,%d0
    btst #7,%a3@(64)
    jbeq BUSERRHANDLER_96_A8
    moveb %a3@(80),%d5
    btst #4,%d5
    jbeq BUSERRHANDLER_96_A8
    moveq #5,%d0
BUSERRHANDLER_96_A8:    /* return */
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408999E4

/* SCSIINIT96 / INITMGR_SCSI96: install the 53C96 SCSI Manager. */
SCSIINIT96:
INITMGR_SCSI96:         /* install this SCSI Manager (as INITMGR_SCSI96_BIOS) */
    moveml %d0-%a5,%sp@-
    moveq #0,%d7
    moveal SCSIGlobals,%a4
    moveq #13,%d1
    lea %pc@(SCSI96),%a1
    movel %a1,%d0
    lea %pc@(SCSIINIT96_10E),%a1
    moveal %a4,%a0
SCSIINIT96_18:          /* selector routines from the offsets */
    moveq #0,%d2
    movew %a1@+,%d2
    addl %d0,%d2
    movel %d2,%a0@+
    dbf %d1,SCSIINIT96_18
    lea %pc@(TRANSFER_96),%a1
    movel %a1,%a4@(412)
    lea %pc@(RESETBUS_96),%a1
    movel %a1,%a4@(420)
    lea %pc@(BUSERRHANDLER_96),%a1
    movel %a1,%a4@(428)
    lea %pc@(SLOWREAD_96),%a1
    movel %a1,%a4@(196)
    lea %pc@(SLOWWRITE_96),%a1
    movel %a1,%a4@(200)
    lea %pc@(FASTREAD_96),%a1
    movel %a1,%a4@(204)
    lea %pc@(FASTWRITE_96),%a1
    movel %a1,%a4@(208)
    lea %pc@(CLEARIRQ_96),%a1
    movel %a1,%a4@(364)
    lea %pc@(SLOWCOMP_96),%a1
    movel %a1,%a4@(212)
    lea %pc@(FASTCOMP_96),%a1
    movel %a1,%a4@(220)
    lea %pc@(SCSIERR_96),%a1
    movel %a1,%a4@(468)
    lea %pc@(CYCLEPHASE_96),%a1
    movel %a1,%a4@(476)
    lea %pc@(UNIMPLEMENTED_96),%a1
    movel %a1,%a4@(500)
    movel %a1,%a4@(504)
    movel %a1,%a4@(508)
    movel %d7,%d0
    moveal %a4@(368),%a0	/* vector +368: DISENABLE */
    jsr %a0@
    clrl %a4@(340)
    clrl %a4@(324)
    clrl %a4@(344)
    clrl %a4@(460)
    clrl %a4@(464)
    clrl %a4@(456)
    clrl %a4@(316)
    moveb %a4@(96),%d1
    moveb #7,%d0
SCSIINIT96_C0:          /* our SCSI ID */
    lslb #1,%d1
    dbeq %d0,SCSIINIT96_C0
    orib #71,%d0
    moveb %d0,%a3@(128)
    movel ToolDispTable,%a4@(452)
    bsrl INIT96DREQPATCH
    nop
    btst #1,0xdd0
    jbeq SCSIINIT96_102
    movel 0x1ff0,%a4@(456)
    movel #-109051864,%a4@(72)
    lea %pc@(DOSCSISELATN_D96),%a1
    movel %a1,%a4@(8)
    lea %pc@(DOSCSISELATN_D96),%a1
    movel %a1,%a4@(44)
SCSIINIT96_102:         /* +126 = 2, return */
    moveb #2,%a4@(126)
    moveml %sp@+,%d0-%a5
    rts
SCSIINIT96_10E:         /* offsets of the selector routines */
    .short  0x008A	| 40899AFE
    .long   0x00D0017E, 0x01C00270, 0x01F401EC, 0x004E01F0	| 40899B00
    .long   0x01E80054, 0x017E036E, 0x038C0000, 0x00000000	| 40899B10

/*
 CPUDECLDATA: sResource data for the built-in CPU and video (directory of 4-byte
 entries: ID and 24-bit offset), with the video names below.
*/
CPUDECLDATA:
    .byte   0x01, 0x00, 0x00, 0x60	| 40899B20 s24 -> CPUDECLDATA_60
CPUDECLDATA_4:          /* (40899B24 s24 -> CPUDECLDATA_290) */
    .byte   0x80, 0x00, 0x02, 0x8C	| 40899B24 s24 -> CPUDECLDATA_290
CPUDECLDATA_8:          /* (40899B28 s24 -> CPUDECLDATA_2C0) */
    .byte   0x81, 0x00, 0x02, 0xB8	| 40899B28 s24 -> CPUDECLDATA_2C0
CPUDECLDATA_C:          /* (40899B2C s24 -> CPUDECLDATA_2F4) */
    .byte   0x82, 0x00, 0x02, 0xE8	| 40899B2C s24 -> CPUDECLDATA_2F4
CPUDECLDATA_10:         /* (40899B30 s24 -> CPUDECLDATA_328) */
    .byte   0x83, 0x00, 0x03, 0x18	| 40899B30 s24 -> CPUDECLDATA_328
CPUDECLDATA_14:         /* (40899B34 s24 -> CPUDECLDATA_360) */
    .byte   0x86, 0x00, 0x03, 0x4C	| 40899B34 s24 -> CPUDECLDATA_360
CPUDECLDATA_18:         /* (40899B38 s24 -> CPUDECLDATA_390) */
    .byte   0x87, 0x00, 0x03, 0x78	| 40899B38 s24 -> CPUDECLDATA_390
CPUDECLDATA_1C:         /* (40899B3C s24 -> CPUDECLDATA_3C4) */
    .byte   0x88, 0x00, 0x03, 0xA8	| 40899B3C s24 -> CPUDECLDATA_3C4
CPUDECLDATA_20:         /* (40899B40 s24 -> CPUDECLDATA_3F8) */
    .byte   0x89, 0x00, 0x03, 0xD8	| 40899B40 s24 -> CPUDECLDATA_3F8
CPUDECLDATA_24:         /* (40899B44 s24 -> CPUDECLDATA_3C4) */
    .byte   0x8A, 0x00, 0x03, 0xA0	| 40899B44 s24 -> CPUDECLDATA_3C4
CPUDECLDATA_28:         /* (40899B48 s24 -> CPUDECLDATA_3F8) */
    .byte   0x8B, 0x00, 0x03, 0xD0	| 40899B48 s24 -> CPUDECLDATA_3F8
CPUDECLDATA_2C:         /* (40899B4C s24 -> CPUDECLDATA_430) */
    .byte   0x8C, 0x00, 0x04, 0x04	| 40899B4C s24 -> CPUDECLDATA_430
CPUDECLDATA_30:         /* (40899B50 s24 -> CPUDECLDATA_464) */
    .byte   0x8D, 0x00, 0x04, 0x34	| 40899B50 s24 -> CPUDECLDATA_464
CPUDECLDATA_34:         /* (40899B54 s24 -> CPUDECLDATA_49C) */
    .byte   0x8E, 0x00, 0x04, 0x68	| 40899B54 s24 -> CPUDECLDATA_49C
CPUDECLDATA_38:         /* (40899B58 s24 -> CPUDECLDATA_4D0) */
    .byte   0x8F, 0x00, 0x04, 0x98	| 40899B58 s24 -> CPUDECLDATA_4D0
CPUDECLDATA_3C:         /* (40899B5C s24 -> CPUDECLDATA_508) */
    .byte   0x90, 0x00, 0x04, 0xCC	| 40899B5C s24 -> CPUDECLDATA_508
CPUDECLDATA_40:         /* (40899B60 s24 -> CPUDECLDATA_53C) */
    .byte   0x91, 0x00, 0x04, 0xFC	| 40899B60 s24 -> CPUDECLDATA_53C
CPUDECLDATA_44:         /* (40899B64 s24 -> CPUDECLDATA_56C) */
    .byte   0x92, 0x00, 0x05, 0x28	| 40899B64 s24 -> CPUDECLDATA_56C
CPUDECLDATA_48:         /* (40899B68 s24 -> CPUDECLDATA_5A0) */
    .byte   0x93, 0x00, 0x05, 0x58	| 40899B68 s24 -> CPUDECLDATA_5A0
CPUDECLDATA_4C:         /* (40899B6C s24 -> CPUDECLDATA_5D0) */
    .byte   0x94, 0x00, 0x05, 0x84	| 40899B6C s24 -> CPUDECLDATA_5D0
CPUDECLDATA_50:         /* (40899B70 s24 -> CPUDECLDATA_604) */
    .byte   0x95, 0x00, 0x05, 0xB4	| 40899B70 s24 -> CPUDECLDATA_604
CPUDECLDATA_54:         /* (40899B74 s24 -> CPUDECLDATA_634) */
    .byte   0x96, 0x00, 0x05, 0xE0	| 40899B74 s24 -> CPUDECLDATA_634
CPUDECLDATA_58:         /* (40899B78 s24 -> CPUDECLDATA_668) */
    .byte   0x97, 0x00, 0x06, 0x10	| 40899B78 s24 -> CPUDECLDATA_668
    .long   0xFF000000	| 40899B7C
CPUDECLDATA_60:         /* (40899B80 s24 -> CPUDECLDATA_21A) */
    .byte   0x01, 0x00, 0x01, 0xBA	| 40899B80 s24 -> CPUDECLDATA_21A
CPUDECLDATA_64:         /* (40899B84 s24 -> STR_Macintosh_A_External_Video) */
    .byte   0x02, 0x00, 0x00, 0x20	| 40899B84 s24 -> STR_Macintosh_A_External_Video
    .long   0x20000046	| 40899B88
CPUDECLDATA_6C:         /* (40899B8C s24 -> CPUDECLDATA_1C32) */
    .byte   0x22, 0x00, 0x1B, 0xC6	| 40899B8C s24 -> CPUDECLDATA_1C32
CPUDECLDATA_70:         /* (40899B90 s24 -> CPUDECLDATA_222) */
    .byte   0x24, 0x00, 0x01, 0xB2	| 40899B90 s24 -> CPUDECLDATA_222
CPUDECLDATA_74:         /* (40899B94 s24 -> CPUDECLDATA_3064) */
    .byte   0x26, 0x00, 0x2F, 0xF0	| 40899B94 s24 -> CPUDECLDATA_3064
CPUDECLDATA_78:         /* (40899B98 s24 -> CPUDECLDATA_A0) */
    .byte   0x41, 0x00, 0x00, 0x28	| 40899B98 s24 -> CPUDECLDATA_A0
CPUDECLDATA_7C:         /* (40899B9C s24 -> CPUDECLDATA_EC0) */
    .byte   0x7E, 0x00, 0x0E, 0x44	| 40899B9C s24 -> CPUDECLDATA_EC0
    .long   0xFF000000	| 40899BA0

/*
 STR_Macintosh_A_External_Video / STR_Dartanian_External_Video /
 STR_Display_Video_Apple_ViSC: video sResource names.
*/
STR_Macintosh_A_External_Video:
    .ascii  "Macintosh A External Video\000\000"
CPUDECLDATA_A0:         /* (data) */
    .long   0x80000058, 0x81000054, 0x82000072, 0x8300006E	| 40899BC0
    .long   0x86000102, 0x870000FE, 0x880000A0, 0x8900009C	| 40899BD0
    .long   0x8A0000B8, 0x8B0000B4, 0x8C00006E, 0x8D00006A	| 40899BE0
    .long   0x8E0000C2, 0x8F0000BE, 0x900000F6, 0x91000106	| 40899BF0
    .long   0x92000102, 0x93000112, 0x9400010E, 0x9500011C	| 40899C00
    .short  0x9600, 0x0118, 0xFF00, 0x0000, 0x0000, 0x0022, 0x0080	| 40899C10
    .ascii  "Macintosh Portrait Display\000\000\000\000"
    .long   0x001C0081	| 40899C3C
    .ascii  "Macintosh RGB Display\000\000\000"
    .long   0x00220083	| 40899C58
    .ascii  "Macintosh 16\" Color Display\000"
    .short  0x0000, 0x0020, 0x0085	| 40899C78
    .ascii  "Macintosh Hi-Res Display\000\000"
    .long   0x0000001A, 0x00863634	| 40899C98
    .long   0x30783438, 0x30205647, 0x41202836, 0x3020487A	| 40899CA0
    .long   0x29000000, 0x00200087	| 40899CB0
    .ascii  "800x600 SuperVGA (56 Hz)\000\000\000\000"
    .long   0x001C0088	| 40899CD4
    .ascii  "RGB Portrait Display\000\000\000\000"
    .long   0x0014008A, 0x35313278, 0x33383420, 0x4E545343	| 40899CF0
    .long   0x00000000, 0x0014008B, 0x36343078, 0x34383020	| 40899D00
    .long   0x4E545343, 0x00000000, 0x0012008C, 0x36343078	| 40899D10
    .long   0x34383020, 0x50414C00, 0x00000012, 0x008D3736	| 40899D20
    .short  0x3878, 0x3537, 0x3620, 0x5041, 0x4C00	| 40899D30
CPUDECLDATA_21A:        /* (data) */
    .short  0x0001, 0x0000, 0x0000, 0x0000	| 40899D3A
CPUDECLDATA_222:        /* (data) */
    .short  0x0100, 0x0014, 0x0300, 0x0028, 0x0400, 0x0048, 0x0500, 0x0058	| 40899D42
    .short  0xFF00, 0x0000	| 40899D52
    .ascii  "Apple Computer, Inc.\000\000"
    .short  0x0000	| 40899D6C
    .ascii  "Macintosh External Video Family 4.0\000"
    .ascii  "The VSC Decl ROM\000\000"
    .long   0x00003138, 0x2D4D6179, 0x2D393300	| 40899DA4
CPUDECLDATA_290:        /* (40899DB0 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x04, 0x98	| 40899DB0 s24 -> CPUDECLDATA_728
CPUDECLDATA_294:        /* (40899DB4 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x04, 0x9C	| 40899DB4 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_298:        /* (40899DB8 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x05, 0x32	| 40899DB8 s24 -> CPUDECLDATA_7CA
    .long   0x07000006	| 40899DBC
    .long   0x08000001	| 40899DC0
CPUDECLDATA_2A4:        /* (40899DC4 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x05, 0x2E	| 40899DC4 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_2A8:        /* (40899DC8 s24 -> CPUDECLDATA_7D6) */
    .byte   0x0B, 0x00, 0x05, 0x2E	| 40899DC8 s24 -> CPUDECLDATA_7D6
CPUDECLDATA_2AC:        /* (40899DCC s24 -> CPUDECLDATA_82A) */
    .byte   0x40, 0x00, 0x05, 0x7E	| 40899DCC s24 -> CPUDECLDATA_82A
CPUDECLDATA_2B0:        /* (40899DD0 s24 -> CPUDECLDATA_10A2) */
    .byte   0x80, 0x00, 0x0D, 0xF2	| 40899DD0 s24 -> CPUDECLDATA_10A2
CPUDECLDATA_2B4:        /* (40899DD4 s24 -> CPUDECLDATA_130E) */
    .byte   0x81, 0x00, 0x10, 0x5A	| 40899DD4 s24 -> CPUDECLDATA_130E
CPUDECLDATA_2B8:        /* (40899DD8 s24 -> CPUDECLDATA_157A) */
    .byte   0x82, 0x00, 0x12, 0xC2	| 40899DD8 s24 -> CPUDECLDATA_157A
    .long   0xFF000000	| 40899DDC
CPUDECLDATA_2C0:        /* (40899DE0 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x04, 0x68	| 40899DE0 s24 -> CPUDECLDATA_728
CPUDECLDATA_2C4:        /* (40899DE4 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x04, 0x6C	| 40899DE4 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_2C8:        /* (40899DE8 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x05, 0x02	| 40899DE8 s24 -> CPUDECLDATA_7CA
    .long   0x07000006	| 40899DEC
    .long   0x08000001	| 40899DF0
CPUDECLDATA_2D4:        /* (40899DF4 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x04, 0xFE	| 40899DF4 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_2D8:        /* (40899DF8 s24 -> CPUDECLDATA_7DA) */
    .byte   0x0B, 0x00, 0x05, 0x02	| 40899DF8 s24 -> CPUDECLDATA_7DA
CPUDECLDATA_2DC:        /* (40899DFC s24 -> CPUDECLDATA_82A) */
    .byte   0x40, 0x00, 0x05, 0x4E	| 40899DFC s24 -> CPUDECLDATA_82A
CPUDECLDATA_2E0:        /* (40899E00 s24 -> CPUDECLDATA_10A2) */
    .byte   0x80, 0x00, 0x0D, 0xC2	| 40899E00 s24 -> CPUDECLDATA_10A2
CPUDECLDATA_2E4:        /* (40899E04 s24 -> CPUDECLDATA_130E) */
    .byte   0x81, 0x00, 0x10, 0x2A	| 40899E04 s24 -> CPUDECLDATA_130E
CPUDECLDATA_2E8:        /* (40899E08 s24 -> CPUDECLDATA_157A) */
    .byte   0x82, 0x00, 0x12, 0x92	| 40899E08 s24 -> CPUDECLDATA_157A
CPUDECLDATA_2EC:        /* (40899E0C s24 -> CPUDECLDATA_17E6) */
    .byte   0x83, 0x00, 0x14, 0xFA	| 40899E0C s24 -> CPUDECLDATA_17E6
    .long   0xFF000000	| 40899E10
CPUDECLDATA_2F4:        /* (40899E14 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x04, 0x34	| 40899E14 s24 -> CPUDECLDATA_728
CPUDECLDATA_2F8:        /* (40899E18 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x04, 0x38	| 40899E18 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_2FC:        /* (40899E1C s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x04, 0xCE	| 40899E1C s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 40899E20
CPUDECLDATA_308:        /* (40899E28 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x04, 0xCA	| 40899E28 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_30C:        /* (40899E2C s24 -> CPUDECLDATA_7DE) */
    .byte   0x0B, 0x00, 0x04, 0xD2	| 40899E2C s24 -> CPUDECLDATA_7DE
CPUDECLDATA_310:        /* (40899E30 s24 -> CPUDECLDATA_832) */
    .byte   0x40, 0x00, 0x05, 0x22	| 40899E30 s24 -> CPUDECLDATA_832
CPUDECLDATA_314:        /* (40899E34 s24 -> CPUDECLDATA_10B2) */
    .byte   0x80, 0x00, 0x0D, 0x9E	| 40899E34 s24 -> CPUDECLDATA_10B2
CPUDECLDATA_318:        /* (40899E38 s24 -> CPUDECLDATA_131E) */
    .byte   0x81, 0x00, 0x10, 0x06	| 40899E38 s24 -> CPUDECLDATA_131E
CPUDECLDATA_31C:        /* (40899E3C s24 -> CPUDECLDATA_158A) */
    .byte   0x82, 0x00, 0x12, 0x6E	| 40899E3C s24 -> CPUDECLDATA_158A
CPUDECLDATA_320:        /* (40899E40 s24 -> CPUDECLDATA_17F6) */
    .byte   0x83, 0x00, 0x14, 0xD6	| 40899E40 s24 -> CPUDECLDATA_17F6
    .long   0xFF000000	| 40899E44
CPUDECLDATA_328:        /* (40899E48 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x04, 0x00	| 40899E48 s24 -> CPUDECLDATA_728
CPUDECLDATA_32C:        /* (40899E4C s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x04, 0x04	| 40899E4C s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_330:        /* (40899E50 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x04, 0x9A	| 40899E50 s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 40899E54
CPUDECLDATA_33C:        /* (40899E5C s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x04, 0x96	| 40899E5C s24 -> CPUDECLDATA_7D2
CPUDECLDATA_340:        /* (40899E60 s24 -> CPUDECLDATA_7DE) */
    .byte   0x0B, 0x00, 0x04, 0x9E	| 40899E60 s24 -> CPUDECLDATA_7DE
CPUDECLDATA_344:        /* (40899E64 s24 -> CPUDECLDATA_832) */
    .byte   0x40, 0x00, 0x04, 0xEE	| 40899E64 s24 -> CPUDECLDATA_832
CPUDECLDATA_348:        /* (40899E68 s24 -> CPUDECLDATA_10B2) */
    .byte   0x80, 0x00, 0x0D, 0x6A	| 40899E68 s24 -> CPUDECLDATA_10B2
CPUDECLDATA_34C:        /* (40899E6C s24 -> CPUDECLDATA_131E) */
    .byte   0x81, 0x00, 0x0F, 0xD2	| 40899E6C s24 -> CPUDECLDATA_131E
CPUDECLDATA_350:        /* (40899E70 s24 -> CPUDECLDATA_158A) */
    .byte   0x82, 0x00, 0x12, 0x3A	| 40899E70 s24 -> CPUDECLDATA_158A
CPUDECLDATA_354:        /* (40899E74 s24 -> CPUDECLDATA_17F6) */
    .byte   0x83, 0x00, 0x14, 0xA2	| 40899E74 s24 -> CPUDECLDATA_17F6
CPUDECLDATA_358:        /* (40899E78 s24 -> CPUDECLDATA_1A52) */
    .byte   0x84, 0x00, 0x16, 0xFA	| 40899E78 s24 -> CPUDECLDATA_1A52
    .long   0xFF000000	| 40899E7C
CPUDECLDATA_360:        /* (40899E80 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x03, 0xC8	| 40899E80 s24 -> CPUDECLDATA_728
CPUDECLDATA_364:        /* (40899E84 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x03, 0xCC	| 40899E84 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_368:        /* (40899E88 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x04, 0x62	| 40899E88 s24 -> CPUDECLDATA_7CA
    .long   0x07000006	| 40899E8C
    .long   0x08000001	| 40899E90
CPUDECLDATA_374:        /* (40899E94 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x04, 0x5E	| 40899E94 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_378:        /* (40899E98 s24 -> CPUDECLDATA_7D6) */
    .byte   0x0B, 0x00, 0x04, 0x5E	| 40899E98 s24 -> CPUDECLDATA_7D6
CPUDECLDATA_37C:        /* (40899E9C s24 -> CPUDECLDATA_816) */
    .byte   0x40, 0x00, 0x04, 0x9A	| 40899E9C s24 -> CPUDECLDATA_816
CPUDECLDATA_380:        /* (40899EA0 s24 -> CPUDECLDATA_10A2) */
    .byte   0x80, 0x00, 0x0D, 0x22	| 40899EA0 s24 -> CPUDECLDATA_10A2
CPUDECLDATA_384:        /* (40899EA4 s24 -> CPUDECLDATA_130E) */
    .byte   0x81, 0x00, 0x0F, 0x8A	| 40899EA4 s24 -> CPUDECLDATA_130E
CPUDECLDATA_388:        /* (40899EA8 s24 -> CPUDECLDATA_157A) */
    .byte   0x82, 0x00, 0x11, 0xF2	| 40899EA8 s24 -> CPUDECLDATA_157A
    .long   0xFF000000	| 40899EAC
CPUDECLDATA_390:        /* (40899EB0 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x03, 0x98	| 40899EB0 s24 -> CPUDECLDATA_728
CPUDECLDATA_394:        /* (40899EB4 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x03, 0x9C	| 40899EB4 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_398:        /* (40899EB8 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x04, 0x32	| 40899EB8 s24 -> CPUDECLDATA_7CA
    .long   0x07000006	| 40899EBC
    .long   0x08000001	| 40899EC0
CPUDECLDATA_3A4:        /* (40899EC4 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x04, 0x2E	| 40899EC4 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_3A8:        /* (40899EC8 s24 -> CPUDECLDATA_7DA) */
    .byte   0x0B, 0x00, 0x04, 0x32	| 40899EC8 s24 -> CPUDECLDATA_7DA
CPUDECLDATA_3AC:        /* (40899ECC s24 -> CPUDECLDATA_816) */
    .byte   0x40, 0x00, 0x04, 0x6A	| 40899ECC s24 -> CPUDECLDATA_816
CPUDECLDATA_3B0:        /* (40899ED0 s24 -> CPUDECLDATA_10A2) */
    .byte   0x80, 0x00, 0x0C, 0xF2	| 40899ED0 s24 -> CPUDECLDATA_10A2
CPUDECLDATA_3B4:        /* (40899ED4 s24 -> CPUDECLDATA_130E) */
    .byte   0x81, 0x00, 0x0F, 0x5A	| 40899ED4 s24 -> CPUDECLDATA_130E
CPUDECLDATA_3B8:        /* (40899ED8 s24 -> CPUDECLDATA_157A) */
    .byte   0x82, 0x00, 0x11, 0xC2	| 40899ED8 s24 -> CPUDECLDATA_157A
CPUDECLDATA_3BC:        /* (40899EDC s24 -> CPUDECLDATA_17E6) */
    .byte   0x83, 0x00, 0x14, 0x2A	| 40899EDC s24 -> CPUDECLDATA_17E6
    .long   0xFF000000	| 40899EE0
CPUDECLDATA_3C4:        /* (40899EE4 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x03, 0x64	| 40899EE4 s24 -> CPUDECLDATA_728
CPUDECLDATA_3C8:        /* (40899EE8 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x03, 0x68	| 40899EE8 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_3CC:        /* (40899EEC s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x03, 0xFE	| 40899EEC s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 40899EF0
CPUDECLDATA_3D8:        /* (40899EF8 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x03, 0xFA	| 40899EF8 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_3DC:        /* (40899EFC s24 -> CPUDECLDATA_7E2) */
    .byte   0x0B, 0x00, 0x04, 0x06	| 40899EFC s24 -> CPUDECLDATA_7E2
CPUDECLDATA_3E0:        /* (40899F00 s24 -> CPUDECLDATA_822) */
    .byte   0x40, 0x00, 0x04, 0x42	| 40899F00 s24 -> CPUDECLDATA_822
CPUDECLDATA_3E4:        /* (40899F04 s24 -> CPUDECLDATA_1092) */
    .byte   0x80, 0x00, 0x0C, 0xAE	| 40899F04 s24 -> CPUDECLDATA_1092
CPUDECLDATA_3E8:        /* (40899F08 s24 -> CPUDECLDATA_12FE) */
    .byte   0x81, 0x00, 0x0F, 0x16	| 40899F08 s24 -> CPUDECLDATA_12FE
CPUDECLDATA_3EC:        /* (40899F0C s24 -> CPUDECLDATA_156A) */
    .byte   0x82, 0x00, 0x11, 0x7E	| 40899F0C s24 -> CPUDECLDATA_156A
CPUDECLDATA_3F0:        /* (40899F10 s24 -> CPUDECLDATA_17D6) */
    .byte   0x83, 0x00, 0x13, 0xE6	| 40899F10 s24 -> CPUDECLDATA_17D6
    .long   0xFF000000	| 40899F14
CPUDECLDATA_3F8:        /* (40899F18 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x03, 0x30	| 40899F18 s24 -> CPUDECLDATA_728
CPUDECLDATA_3FC:        /* (40899F1C s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x03, 0x34	| 40899F1C s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_400:        /* (40899F20 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x03, 0xCA	| 40899F20 s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 40899F24
CPUDECLDATA_40C:        /* (40899F2C s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x03, 0xC6	| 40899F2C s24 -> CPUDECLDATA_7D2
CPUDECLDATA_410:        /* (40899F30 s24 -> CPUDECLDATA_7E6) */
    .byte   0x0B, 0x00, 0x03, 0xD6	| 40899F30 s24 -> CPUDECLDATA_7E6
CPUDECLDATA_414:        /* (40899F34 s24 -> CPUDECLDATA_816) */
    .byte   0x40, 0x00, 0x04, 0x02	| 40899F34 s24 -> CPUDECLDATA_816
CPUDECLDATA_418:        /* (40899F38 s24 -> CPUDECLDATA_1092) */
    .byte   0x80, 0x00, 0x0C, 0x7A	| 40899F38 s24 -> CPUDECLDATA_1092
CPUDECLDATA_41C:        /* (40899F3C s24 -> CPUDECLDATA_12FE) */
    .byte   0x81, 0x00, 0x0E, 0xE2	| 40899F3C s24 -> CPUDECLDATA_12FE
CPUDECLDATA_420:        /* (40899F40 s24 -> CPUDECLDATA_156A) */
    .byte   0x82, 0x00, 0x11, 0x4A	| 40899F40 s24 -> CPUDECLDATA_156A
CPUDECLDATA_424:        /* (40899F44 s24 -> CPUDECLDATA_17D6) */
    .byte   0x83, 0x00, 0x13, 0xB2	| 40899F44 s24 -> CPUDECLDATA_17D6
CPUDECLDATA_428:        /* (40899F48 s24 -> CPUDECLDATA_1A42) */
    .byte   0x84, 0x00, 0x16, 0x1A	| 40899F48 s24 -> CPUDECLDATA_1A42
    .long   0xFF000000	| 40899F4C
CPUDECLDATA_430:        /* (40899F50 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x02, 0xF8	| 40899F50 s24 -> CPUDECLDATA_728
CPUDECLDATA_434:        /* (40899F54 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x02, 0xFC	| 40899F54 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_438:        /* (40899F58 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x03, 0x92	| 40899F58 s24 -> CPUDECLDATA_7CA
    .long   0x07000006	| 40899F5C
    .long   0x08000001	| 40899F60
CPUDECLDATA_444:        /* (40899F64 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x03, 0x8E	| 40899F64 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_448:        /* (40899F68 s24 -> CPUDECLDATA_7EA) */
    .byte   0x0B, 0x00, 0x03, 0xA2	| 40899F68 s24 -> CPUDECLDATA_7EA
CPUDECLDATA_44C:        /* (40899F6C s24 -> CPUDECLDATA_816) */
    .byte   0x40, 0x00, 0x03, 0xCA	| 40899F6C s24 -> CPUDECLDATA_816
CPUDECLDATA_450:        /* (40899F70 s24 -> CPUDECLDATA_10D2) */
    .byte   0x80, 0x00, 0x0C, 0x82	| 40899F70 s24 -> CPUDECLDATA_10D2
CPUDECLDATA_454:        /* (40899F74 s24 -> CPUDECLDATA_133E) */
    .byte   0x81, 0x00, 0x0E, 0xEA	| 40899F74 s24 -> CPUDECLDATA_133E
CPUDECLDATA_458:        /* (40899F78 s24 -> CPUDECLDATA_15AA) */
    .byte   0x82, 0x00, 0x11, 0x52	| 40899F78 s24 -> CPUDECLDATA_15AA
CPUDECLDATA_45C:        /* (40899F7C s24 -> CPUDECLDATA_1816) */
    .byte   0x83, 0x00, 0x13, 0xBA	| 40899F7C s24 -> CPUDECLDATA_1816
    .long   0xFF000000	| 40899F80
CPUDECLDATA_464:        /* (40899F84 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x02, 0xC4	| 40899F84 s24 -> CPUDECLDATA_728
CPUDECLDATA_468:        /* (40899F88 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x02, 0xC8	| 40899F88 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_46C:        /* (40899F8C s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x03, 0x5E	| 40899F8C s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 40899F90
CPUDECLDATA_478:        /* (40899F98 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x03, 0x5A	| 40899F98 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_47C:        /* (40899F9C s24 -> CPUDECLDATA_7EE) */
    .byte   0x0B, 0x00, 0x03, 0x72	| 40899F9C s24 -> CPUDECLDATA_7EE
CPUDECLDATA_480:        /* (40899FA0 s24 -> CPUDECLDATA_816) */
    .byte   0x40, 0x00, 0x03, 0x96	| 40899FA0 s24 -> CPUDECLDATA_816
CPUDECLDATA_484:        /* (40899FA4 s24 -> CPUDECLDATA_10D2) */
    .byte   0x80, 0x00, 0x0C, 0x4E	| 40899FA4 s24 -> CPUDECLDATA_10D2
CPUDECLDATA_488:        /* (40899FA8 s24 -> CPUDECLDATA_133E) */
    .byte   0x81, 0x00, 0x0E, 0xB6	| 40899FA8 s24 -> CPUDECLDATA_133E
CPUDECLDATA_48C:        /* (40899FAC s24 -> CPUDECLDATA_15AA) */
    .byte   0x82, 0x00, 0x11, 0x1E	| 40899FAC s24 -> CPUDECLDATA_15AA
CPUDECLDATA_490:        /* (40899FB0 s24 -> CPUDECLDATA_1816) */
    .byte   0x83, 0x00, 0x13, 0x86	| 40899FB0 s24 -> CPUDECLDATA_1816
CPUDECLDATA_494:        /* (40899FB4 s24 -> CPUDECLDATA_1A62) */
    .byte   0x84, 0x00, 0x15, 0xCE	| 40899FB4 s24 -> CPUDECLDATA_1A62
    .long   0xFF000000	| 40899FB8
CPUDECLDATA_49C:        /* (40899FBC s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x02, 0x8C	| 40899FBC s24 -> CPUDECLDATA_728
CPUDECLDATA_4A0:        /* (40899FC0 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x02, 0x90	| 40899FC0 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_4A4:        /* (40899FC4 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x03, 0x26	| 40899FC4 s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 40899FC8
CPUDECLDATA_4B0:        /* (40899FD0 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x03, 0x22	| 40899FD0 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_4B4:        /* (40899FD4 s24 -> CPUDECLDATA_7F2) */
    .byte   0x0B, 0x00, 0x03, 0x3E	| 40899FD4 s24 -> CPUDECLDATA_7F2
CPUDECLDATA_4B8:        /* (40899FD8 s24 -> CPUDECLDATA_822) */
    .byte   0x40, 0x00, 0x03, 0x6A	| 40899FD8 s24 -> CPUDECLDATA_822
CPUDECLDATA_4BC:        /* (40899FDC s24 -> CPUDECLDATA_10E2) */
    .byte   0x80, 0x00, 0x0C, 0x26	| 40899FDC s24 -> CPUDECLDATA_10E2
CPUDECLDATA_4C0:        /* (40899FE0 s24 -> CPUDECLDATA_134E) */
    .byte   0x81, 0x00, 0x0E, 0x8E	| 40899FE0 s24 -> CPUDECLDATA_134E
CPUDECLDATA_4C4:        /* (40899FE4 s24 -> CPUDECLDATA_15BA) */
    .byte   0x82, 0x00, 0x10, 0xF6	| 40899FE4 s24 -> CPUDECLDATA_15BA
CPUDECLDATA_4C8:        /* (40899FE8 s24 -> CPUDECLDATA_1826) */
    .byte   0x83, 0x00, 0x13, 0x5E	| 40899FE8 s24 -> CPUDECLDATA_1826
    .long   0xFF000000	| 40899FEC
CPUDECLDATA_4D0:        /* (40899FF0 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x02, 0x58	| 40899FF0 s24 -> CPUDECLDATA_728
CPUDECLDATA_4D4:        /* (40899FF4 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x02, 0x5C	| 40899FF4 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_4D8:        /* (40899FF8 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x02, 0xF2	| 40899FF8 s24 -> CPUDECLDATA_7CA
    .long   0x07000006	| 40899FFC
    .long   0x08000001	| 4089A000
CPUDECLDATA_4E4:        /* (4089A004 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x02, 0xEE	| 4089A004 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_4E8:        /* (4089A008 s24 -> CPUDECLDATA_7F6) */
    .byte   0x0B, 0x00, 0x03, 0x0E	| 4089A008 s24 -> CPUDECLDATA_7F6
CPUDECLDATA_4EC:        /* (4089A00C s24 -> CPUDECLDATA_822) */
    .byte   0x40, 0x00, 0x03, 0x36	| 4089A00C s24 -> CPUDECLDATA_822
CPUDECLDATA_4F0:        /* (4089A010 s24 -> CPUDECLDATA_10E2) */
    .byte   0x80, 0x00, 0x0B, 0xF2	| 4089A010 s24 -> CPUDECLDATA_10E2
CPUDECLDATA_4F4:        /* (4089A014 s24 -> CPUDECLDATA_134E) */
    .byte   0x81, 0x00, 0x0E, 0x5A	| 4089A014 s24 -> CPUDECLDATA_134E
CPUDECLDATA_4F8:        /* (4089A018 s24 -> CPUDECLDATA_15BA) */
    .byte   0x82, 0x00, 0x10, 0xC2	| 4089A018 s24 -> CPUDECLDATA_15BA
CPUDECLDATA_4FC:        /* (4089A01C s24 -> CPUDECLDATA_1826) */
    .byte   0x83, 0x00, 0x13, 0x2A	| 4089A01C s24 -> CPUDECLDATA_1826
CPUDECLDATA_500:        /* (4089A020 s24 -> CPUDECLDATA_1A72) */
    .byte   0x84, 0x00, 0x15, 0x72	| 4089A020 s24 -> CPUDECLDATA_1A72
    .long   0xFF000000	| 4089A024
CPUDECLDATA_508:        /* (4089A028 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x02, 0x20	| 4089A028 s24 -> CPUDECLDATA_728
CPUDECLDATA_50C:        /* (4089A02C s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x02, 0x24	| 4089A02C s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_510:        /* (4089A030 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x02, 0xBA	| 4089A030 s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 4089A034
CPUDECLDATA_51C:        /* (4089A03C s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x02, 0xB6	| 4089A03C s24 -> CPUDECLDATA_7D2
CPUDECLDATA_520:        /* (4089A040 s24 -> CPUDECLDATA_7FA) */
    .byte   0x0B, 0x00, 0x02, 0xDA	| 4089A040 s24 -> CPUDECLDATA_7FA
CPUDECLDATA_524:        /* (4089A044 s24 -> CPUDECLDATA_10F2) */
    .byte   0x80, 0x00, 0x0B, 0xCE	| 4089A044 s24 -> CPUDECLDATA_10F2
CPUDECLDATA_528:        /* (4089A048 s24 -> CPUDECLDATA_135E) */
    .byte   0x81, 0x00, 0x0E, 0x36	| 4089A048 s24 -> CPUDECLDATA_135E
CPUDECLDATA_52C:        /* (4089A04C s24 -> CPUDECLDATA_15CA) */
    .byte   0x82, 0x00, 0x10, 0x9E	| 4089A04C s24 -> CPUDECLDATA_15CA
CPUDECLDATA_530:        /* (4089A050 s24 -> CPUDECLDATA_1836) */
    .byte   0x83, 0x00, 0x13, 0x06	| 4089A050 s24 -> CPUDECLDATA_1836
CPUDECLDATA_534:        /* (4089A054 s24 -> CPUDECLDATA_1A82) */
    .byte   0x84, 0x00, 0x15, 0x4E	| 4089A054 s24 -> CPUDECLDATA_1A82
    .long   0xFF000000	| 4089A058
CPUDECLDATA_53C:        /* (4089A05C s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x01, 0xEC	| 4089A05C s24 -> CPUDECLDATA_728
CPUDECLDATA_540:        /* (4089A060 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x01, 0xF0	| 4089A060 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_544:        /* (4089A064 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x02, 0x86	| 4089A064 s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 4089A068
CPUDECLDATA_550:        /* (4089A070 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x02, 0x82	| 4089A070 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_554:        /* (4089A074 s24 -> CPUDECLDATA_7FE) */
    .byte   0x0B, 0x00, 0x02, 0xAA	| 4089A074 s24 -> CPUDECLDATA_7FE
CPUDECLDATA_558:        /* (4089A078 s24 -> CPUDECLDATA_1102) */
    .byte   0x80, 0x00, 0x0B, 0xAA	| 4089A078 s24 -> CPUDECLDATA_1102
CPUDECLDATA_55C:        /* (4089A07C s24 -> CPUDECLDATA_136E) */
    .byte   0x81, 0x00, 0x0E, 0x12	| 4089A07C s24 -> CPUDECLDATA_136E
CPUDECLDATA_560:        /* (4089A080 s24 -> CPUDECLDATA_15DA) */
    .byte   0x82, 0x00, 0x10, 0x7A	| 4089A080 s24 -> CPUDECLDATA_15DA
CPUDECLDATA_564:        /* (4089A084 s24 -> CPUDECLDATA_1846) */
    .byte   0x83, 0x00, 0x12, 0xE2	| 4089A084 s24 -> CPUDECLDATA_1846
    .long   0xFF000000	| 4089A088
CPUDECLDATA_56C:        /* (4089A08C s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x01, 0xBC	| 4089A08C s24 -> CPUDECLDATA_728
CPUDECLDATA_570:        /* (4089A090 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x01, 0xC0	| 4089A090 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_574:        /* (4089A094 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x02, 0x56	| 4089A094 s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 4089A098
CPUDECLDATA_580:        /* (4089A0A0 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x02, 0x52	| 4089A0A0 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_584:        /* (4089A0A4 s24 -> CPUDECLDATA_802) */
    .byte   0x0B, 0x00, 0x02, 0x7E	| 4089A0A4 s24 -> CPUDECLDATA_802
CPUDECLDATA_588:        /* (4089A0A8 s24 -> CPUDECLDATA_1102) */
    .byte   0x80, 0x00, 0x0B, 0x7A	| 4089A0A8 s24 -> CPUDECLDATA_1102
CPUDECLDATA_58C:        /* (4089A0AC s24 -> CPUDECLDATA_136E) */
    .byte   0x81, 0x00, 0x0D, 0xE2	| 4089A0AC s24 -> CPUDECLDATA_136E
CPUDECLDATA_590:        /* (4089A0B0 s24 -> CPUDECLDATA_15DA) */
    .byte   0x82, 0x00, 0x10, 0x4A	| 4089A0B0 s24 -> CPUDECLDATA_15DA
CPUDECLDATA_594:        /* (4089A0B4 s24 -> CPUDECLDATA_1846) */
    .byte   0x83, 0x00, 0x12, 0xB2	| 4089A0B4 s24 -> CPUDECLDATA_1846
CPUDECLDATA_598:        /* (4089A0B8 s24 -> CPUDECLDATA_1A92) */
    .byte   0x84, 0x00, 0x14, 0xFA	| 4089A0B8 s24 -> CPUDECLDATA_1A92
    .long   0xFF000000	| 4089A0BC
CPUDECLDATA_5A0:        /* (4089A0C0 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x01, 0x88	| 4089A0C0 s24 -> CPUDECLDATA_728
CPUDECLDATA_5A4:        /* (4089A0C4 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x01, 0x8C	| 4089A0C4 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_5A8:        /* (4089A0C8 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x02, 0x22	| 4089A0C8 s24 -> CPUDECLDATA_7CA
    .long   0x07000006	| 4089A0CC
    .long   0x08000001	| 4089A0D0
CPUDECLDATA_5B4:        /* (4089A0D4 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x02, 0x1E	| 4089A0D4 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_5B8:        /* (4089A0D8 s24 -> CPUDECLDATA_806) */
    .byte   0x0B, 0x00, 0x02, 0x4E	| 4089A0D8 s24 -> CPUDECLDATA_806
CPUDECLDATA_5BC:        /* (4089A0DC s24 -> CPUDECLDATA_1112) */
    .byte   0x80, 0x00, 0x0B, 0x56	| 4089A0DC s24 -> CPUDECLDATA_1112
CPUDECLDATA_5C0:        /* (4089A0E0 s24 -> CPUDECLDATA_137E) */
    .byte   0x81, 0x00, 0x0D, 0xBE	| 4089A0E0 s24 -> CPUDECLDATA_137E
CPUDECLDATA_5C4:        /* (4089A0E4 s24 -> CPUDECLDATA_15EA) */
    .byte   0x82, 0x00, 0x10, 0x26	| 4089A0E4 s24 -> CPUDECLDATA_15EA
CPUDECLDATA_5C8:        /* (4089A0E8 s24 -> CPUDECLDATA_1856) */
    .byte   0x83, 0x00, 0x12, 0x8E	| 4089A0E8 s24 -> CPUDECLDATA_1856
    .long   0xFF000000	| 4089A0EC
CPUDECLDATA_5D0:        /* (4089A0F0 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x01, 0x58	| 4089A0F0 s24 -> CPUDECLDATA_728
CPUDECLDATA_5D4:        /* (4089A0F4 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x01, 0x5C	| 4089A0F4 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_5D8:        /* (4089A0F8 s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x01, 0xF2	| 4089A0F8 s24 -> CPUDECLDATA_7CA
    .long   0x07000006	| 4089A0FC
    .long   0x08000001	| 4089A100
CPUDECLDATA_5E4:        /* (4089A104 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x01, 0xEE	| 4089A104 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_5E8:        /* (4089A108 s24 -> CPUDECLDATA_80A) */
    .byte   0x0B, 0x00, 0x02, 0x22	| 4089A108 s24 -> CPUDECLDATA_80A
CPUDECLDATA_5EC:        /* (4089A10C s24 -> CPUDECLDATA_1112) */
    .byte   0x80, 0x00, 0x0B, 0x26	| 4089A10C s24 -> CPUDECLDATA_1112
CPUDECLDATA_5F0:        /* (4089A110 s24 -> CPUDECLDATA_137E) */
    .byte   0x81, 0x00, 0x0D, 0x8E	| 4089A110 s24 -> CPUDECLDATA_137E
CPUDECLDATA_5F4:        /* (4089A114 s24 -> CPUDECLDATA_15EA) */
    .byte   0x82, 0x00, 0x0F, 0xF6	| 4089A114 s24 -> CPUDECLDATA_15EA
CPUDECLDATA_5F8:        /* (4089A118 s24 -> CPUDECLDATA_1856) */
    .byte   0x83, 0x00, 0x12, 0x5E	| 4089A118 s24 -> CPUDECLDATA_1856
CPUDECLDATA_5FC:        /* (4089A11C s24 -> CPUDECLDATA_1AA2) */
    .byte   0x84, 0x00, 0x14, 0xA6	| 4089A11C s24 -> CPUDECLDATA_1AA2
    .long   0xFF000000	| 4089A120
CPUDECLDATA_604:        /* (4089A124 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x01, 0x24	| 4089A124 s24 -> CPUDECLDATA_728
CPUDECLDATA_608:        /* (4089A128 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x01, 0x28	| 4089A128 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_60C:        /* (4089A12C s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x01, 0xBE	| 4089A12C s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 4089A130
CPUDECLDATA_618:        /* (4089A138 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x01, 0xBA	| 4089A138 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_61C:        /* (4089A13C s24 -> CPUDECLDATA_80E) */
    .byte   0x0B, 0x00, 0x01, 0xF2	| 4089A13C s24 -> CPUDECLDATA_80E
CPUDECLDATA_620:        /* (4089A140 s24 -> CPUDECLDATA_1122) */
    .byte   0x80, 0x00, 0x0B, 0x02	| 4089A140 s24 -> CPUDECLDATA_1122
CPUDECLDATA_624:        /* (4089A144 s24 -> CPUDECLDATA_138E) */
    .byte   0x81, 0x00, 0x0D, 0x6A	| 4089A144 s24 -> CPUDECLDATA_138E
CPUDECLDATA_628:        /* (4089A148 s24 -> CPUDECLDATA_15FA) */
    .byte   0x82, 0x00, 0x0F, 0xD2	| 4089A148 s24 -> CPUDECLDATA_15FA
CPUDECLDATA_62C:        /* (4089A14C s24 -> CPUDECLDATA_1866) */
    .byte   0x83, 0x00, 0x12, 0x3A	| 4089A14C s24 -> CPUDECLDATA_1866
    .long   0xFF000000	| 4089A150
CPUDECLDATA_634:        /* (4089A154 s24 -> CPUDECLDATA_728) */
    .byte   0x01, 0x00, 0x00, 0xF4	| 4089A154 s24 -> CPUDECLDATA_728
CPUDECLDATA_638:        /* (4089A158 s24 -> STR_Display_Video_Apple_ViSC) */
    .byte   0x02, 0x00, 0x00, 0xF8	| 4089A158 s24 -> STR_Display_Video_Apple_ViSC
CPUDECLDATA_63C:        /* (4089A15C s24 -> CPUDECLDATA_7CA) */
    .byte   0x04, 0x00, 0x01, 0x8E	| 4089A15C s24 -> CPUDECLDATA_7CA
    .long   0x07000006, 0x08000001	| 4089A160
CPUDECLDATA_648:        /* (4089A168 s24 -> CPUDECLDATA_7D2) */
    .byte   0x0A, 0x00, 0x01, 0x8A	| 4089A168 s24 -> CPUDECLDATA_7D2
CPUDECLDATA_64C:        /* (4089A16C s24 -> CPUDECLDATA_812) */
    .byte   0x0B, 0x00, 0x01, 0xC6	| 4089A16C s24 -> CPUDECLDATA_812
CPUDECLDATA_650:        /* (4089A170 s24 -> CPUDECLDATA_1122) */
    .byte   0x80, 0x00, 0x0A, 0xD2	| 4089A170 s24 -> CPUDECLDATA_1122
CPUDECLDATA_654:        /* (4089A174 s24 -> CPUDECLDATA_138E) */
    .byte   0x81, 0x00, 0x0D, 0x3A	| 4089A174 s24 -> CPUDECLDATA_138E
CPUDECLDATA_658:        /* (4089A178 s24 -> CPUDECLDATA_15FA) */
    .byte   0x82, 0x00, 0x0F, 0xA2	| 4089A178 s24 -> CPUDECLDATA_15FA
CPUDECLDATA_65C:        /* (4089A17C s24 -> CPUDECLDATA_1866) */
    .byte   0x83, 0x00, 0x12, 0x0A	| 4089A17C s24 -> CPUDECLDATA_1866
CPUDECLDATA_660:        /* (4089A180 s24 -> CPUDECLDATA_1AB2) */
    .byte   0x84, 0x00, 0x14, 0x52	| 4089A180 s24 -> CPUDECLDATA_1AB2
    .long   0xFF000000	| 4089A184
CPUDECLDATA_668:        /* (4089A188 s24 -> CPUDECLDATA_678) */
    .byte   0x01, 0x00, 0x00, 0x10	| 4089A188 s24 -> CPUDECLDATA_678
CPUDECLDATA_66C:        /* (4089A18C s24 -> STR_Dartanian_External_Video) */
    .byte   0x02, 0x00, 0x00, 0x14	| 4089A18C s24 -> STR_Dartanian_External_Video
CPUDECLDATA_670:        /* (4089A190 s24 -> CPUDECLDATA_69C) */
    .byte   0x50, 0x00, 0x00, 0x2C	| 4089A190 s24 -> CPUDECLDATA_69C
    .long   0xFF000000	| 4089A194
CPUDECLDATA_678:        /* (data) */
    .long   0x00200001, 0x00010001	| 4089A198
STR_Dartanian_External_Video:  /* string "Dartanian_External_Video\000\000\000\00 */
    .ascii  "Dartanian_External_Video\000\000\000\000"
CPUDECLDATA_69C:        /* (data) */
    .long   0x0000008C	| 4089A1BC
    moveal %sp@+,%a1
    movel %sp@+,%d2
    movel %sp@+,%d1
    cmpil #1751414642,%d1
    jbne CPUDECLDATA_6BC
    moveq #0,%d0
    jbsr CPUDECLDATA_6FE
    jbne CPUDECLDATA_6FA
    movel #8388736,%d0
    jbra CPUDECLDATA_6FA
CPUDECLDATA_6BC:        /* test #1685021547,%d1 */
    cmpil #1685021547,%d1
    jbne CPUDECLDATA_6CE
    moveq #0,%d0
    jbsr CPUDECLDATA_6FE
    jbne CPUDECLDATA_6FA
    moveq #1,%d0
    jbra CPUDECLDATA_6FA
CPUDECLDATA_6CE:        /* test #1935961376,%d1 */
    cmpil #1935961376,%d1
    jbne CPUDECLDATA_6EA
    moveq #1,%d0
    moveal VIA,%a0
    moveq #8,%d1
    andb %a0@,%d1
    btst #3,%d1
    jbne CPUDECLDATA_6FA
    addqb #2,%d0
    jbra CPUDECLDATA_6FA
CPUDECLDATA_6EA:        /* address %pc@(CPUDECLDATA_710) */
    lea %pc@(CPUDECLDATA_710),%a0
CPUDECLDATA_6EE:        /* loop: addq */
    addqw #4,%a0
    movel %a0@+,%d0
    jbeq CPUDECLDATA_6FA
    cmpl %d1,%d0
    jbne CPUDECLDATA_6EE
    movel %a0@+,%d0
CPUDECLDATA_6FA:        /* set %sp@ */
    movel %d0,%sp@
    jmp %a1@

CPUDECLDATA_6FE:        /* set %a0 */
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #212992,%a0
CPUDECLDATA_70E:        /* test bit 1 of %a0@ */
    btst #1,%a0@
    rts
    .long   0x73636323, 0x00000003, 0x76657273	| 4089A234
    .long   0x01002001, 0x00000000	| 4089A240
CPUDECLDATA_728:        /* (data) */
    .byte   0x00, 0x03, 0x00, 0x01, 0x00, 0x01, 0x00	| 4089A248
    .ascii  " "
STR_Display_Video_Apple_ViSC:  /* (data) */
    .long   0x44697370, 0x6C61795F, 0x56696465, 0x6F5F4170	| 4089A250
    .long   0x706C655F, 0x56695343, 0x00003FFF, 0xE0004000	| 4089A260
    .long   0x10004FFF, 0x90005000, 0x50005550, 0x50005000	| 4089A270
    .long   0x50005500, 0x50005000, 0x7FFC5400, 0x40025000	| 4089A280
    .long   0x4FF25000, 0x500A5000, 0x554A4FFF, 0xD00A4000	| 4089A290
    .long   0x550A3FFF, 0xD00A0800, 0x540A3BFF, 0x500A2000	| 4089A2A0
    .long   0x540A3FFF, 0xD00A0000, 0x500A3FFE, 0x500A4001	| 4089A2B0
    .long   0x4FF24FF9, 0x40025005, 0x3FFC5505, 0x08105005	| 4089A2C0
    .long   0x7BDE5405, 0x40025005, 0x7FFE5005, 0x00004FF9	| 4089A2D0
    .short  0x0000, 0x4001, 0x0000, 0x3FFE, 0x0000	| 4089A2E0
CPUDECLDATA_7CA:        /* (4089A2EA s24 -> CPUDECLDATA_21A0) */
    .byte   0x02, 0x00, 0x19, 0xD6	| 4089A2EA s24 -> CPUDECLDATA_21A0
    .short  0xFF00, 0x0000	| 4089A2EE
CPUDECLDATA_7D2:        /* (data) */
    .short  0x0000, 0x0000	| 4089A2F2
CPUDECLDATA_7D6:        /* (data) */
    .short  0x0004, 0x3F80	| 4089A2F6
CPUDECLDATA_7DA:        /* (data) */
    .short  0x0008, 0x7F00	| 4089A2FA
CPUDECLDATA_7DE:        /* (data) */
    .short  0x0006, 0x0000	| 4089A2FE
CPUDECLDATA_7E2:        /* (data) */
    .short  0x0004, 0xB000	| 4089A302
CPUDECLDATA_7E6:        /* (data) */
    .short  0x0009, 0x6000	| 4089A306
CPUDECLDATA_7EA:        /* (data) */
    .short  0x0007, 0xEC00	| 4089A30A
CPUDECLDATA_7EE:        /* (data) */
    .short  0x000F, 0xD800	| 4089A30E
CPUDECLDATA_7F2:        /* (data) */
    .short  0x0007, 0x5300	| 4089A312
CPUDECLDATA_7F6:        /* (data) */
    .short  0x000E, 0xA600	| 4089A316
CPUDECLDATA_7FA:        /* (data) */
    .short  0x0006, 0x0000	| 4089A31A
CPUDECLDATA_7FE:        /* (data) */
    .short  0x0004, 0xB000	| 4089A31E
CPUDECLDATA_802:        /* (data) */
    .short  0x0009, 0x6000	| 4089A322
CPUDECLDATA_806:        /* (data) */
    .short  0x0004, 0x52E0	| 4089A326
CPUDECLDATA_80A:        /* (data) */
    .short  0x0008, 0xA5C0	| 4089A32A
CPUDECLDATA_80E:        /* (data) */
    .short  0x0006, 0xC000	| 4089A32E
CPUDECLDATA_812:        /* (data) */
    .short  0x000D, 0x8000	| 4089A332
CPUDECLDATA_816:        /* (4089A336 s24 -> CPUDECLDATA_B5E) */
    .byte   0x80, 0x00, 0x03, 0x48	| 4089A336 s24 -> CPUDECLDATA_B5E
CPUDECLDATA_81A:        /* (4089A33A s24 -> CPUDECLDATA_83A) */
    .byte   0x81, 0x00, 0x00, 0x20	| 4089A33A s24 -> CPUDECLDATA_83A
    .short  0xFF00, 0x0000	| 4089A33E
CPUDECLDATA_822:        /* (4089A342 s24 -> CPUDECLDATA_B5E) */
    .byte   0x80, 0x00, 0x03, 0x3C	| 4089A342 s24 -> CPUDECLDATA_B5E
    .short  0xFF00, 0x0000	| 4089A346
CPUDECLDATA_82A:        /* (4089A34A s24 -> CPUDECLDATA_C7E) */
    .byte   0x80, 0x00, 0x04, 0x54	| 4089A34A s24 -> CPUDECLDATA_C7E
    .short  0xFF00, 0x0000	| 4089A34E
CPUDECLDATA_832:        /* (4089A352 s24 -> CPUDECLDATA_DA0) */
    .byte   0x80, 0x00, 0x05, 0x6E	| 4089A352 s24 -> CPUDECLDATA_DA0
    .short  0xFF00, 0x0000	| 4089A356
CPUDECLDATA_83A:        /* (data) */
    .short  0x0000, 0x0324, 0x07D0	| 4089A35A
    .ascii  "Page-White Gamma\000\000\000\000"
    .long   0x00000000, 0x00030100, 0x00080003	| 4089A374
    .long   0x06090C10, 0x10121315, 0x1616181B, 0x1C1E1F22	| 4089A380
    .long   0x2326282B, 0x2C2F3234, 0x373A3C3F, 0x40414243	| 4089A390
    .long   0x44454647, 0x47494A4B, 0x4C4D4E4F, 0x50515253	| 4089A3A0
    .long   0x54545656, 0x5758595A, 0x5B5C5D5E, 0x5F606162	| 4089A3B0
    .long   0x63646566, 0x6768696A, 0x6B6C6D6E, 0x6F707172	| 4089A3C0
    .long   0x72737475, 0x76777879, 0x7A7A7B7C, 0x7D7E7F81	| 4089A3D0
    .long   0x82838384, 0x85868788, 0x898A8A8B, 0x8C8D8E8F	| 4089A3E0
    .long   0x90919293, 0x93949596, 0x97989899, 0x9A9B9C9D	| 4089A3F0
    .long   0x9E9FA0A1, 0xA1A2A3A4, 0xA4A5A6A7, 0xA8A8A9AA	| 4089A400
    .long   0xABACADAD, 0xAEAFB0B1, 0xB2B2B3B4, 0xB5B5B6B7	| 4089A410
    .long   0xB8B8B9BA, 0xBBBCBCBD, 0xBEBFC0C0, 0xC1C2C3C3	| 4089A420
    .long   0xC4C5C6C6, 0xC7C8C9C9, 0xCACBCCCD, 0xCDCECFD0	| 4089A430
    .long   0xD1D1D2D3, 0xD4D4D5D6, 0xD7D7D8D9, 0xDADADBDC	| 4089A440
    .long   0xDDDEDEDF, 0xE0E1E1E2, 0xE3E4E4E5, 0xE6E7E7E8	| 4089A450
    .long   0xE9EAEAEB, 0xECEDEEEE, 0xEFF0F1F1, 0xF2F3F4F4	| 4089A460
    .long   0xF5F6F7F8, 0xF8F9FAFB, 0xFBFCFDFE, 0xFFFF0003	| 4089A470
    .long   0x06090C10, 0x10182020, 0x22232425, 0x2728292C	| 4089A480
    .long   0x2D2E3032, 0x3437383A, 0x3D3F4041, 0x42424344	| 4089A490
    .long   0x44454647, 0x48494A4A, 0x4B4C4D4E, 0x4F505152	| 4089A4A0
    .long   0x53545556, 0x5758595B, 0x5C5D5E5F, 0x60616263	| 4089A4B0
    .long   0x64656566, 0x6768696A, 0x6B6C6D6E, 0x6F707171	| 4089A4C0
    .long   0x72737474, 0x75767778, 0x79797A7B, 0x7C7D7E7F	| 4089A4D0
    .long   0x80818283, 0x84848586, 0x87888889, 0x8A8B8C8D	| 4089A4E0
    .long   0x8E8E8F90, 0x91929393, 0x94959696, 0x9798999A	| 4089A4F0
    .long   0x9A9B9C9D, 0x9E9E9FA0, 0xA1A2A2A3, 0xA4A5A5A6	| 4089A500
    .long   0xA7A8A8A9, 0xAAABABAC, 0xADAEAFAF, 0xB0B1B2B2	| 4089A510
    .long   0xB3B4B5B5, 0xB6B7B7B8, 0xB9BABABB, 0xBCBDBDBE	| 4089A520
    .long   0xBFC0C1C1, 0xC2C3C3C4, 0xC5C6C6C7, 0xC8C9C9CA	| 4089A530
    .long   0xCBCCCCCD, 0xCECFCFD0, 0xD1D2D2D3, 0xD4D4D5D6	| 4089A540
    .long   0xD6D7D8D9, 0xD9DADBDC, 0xDCDDDEDE, 0xDFE0E1E1	| 4089A550
    .long   0xE2E3E4E4, 0xE5E6E6E7, 0xE8E9E9EA, 0xEBECECED	| 4089A560
    .long   0xEEEFEFF0, 0xF1F2F2F3, 0xF4F4F5F6, 0xF7F70002	| 4089A570
    .long   0x05080A0D, 0x10101020, 0x20222323, 0x24252527	| 4089A580
    .long   0x28292A2C, 0x2D2E2F30, 0x32333436, 0x37383A3C	| 4089A590
    .long   0x3D3F4041, 0x41424243, 0x44444545, 0x46474748	| 4089A5A0
    .long   0x494A4A4B, 0x4C4D4D4E, 0x4F4F5151, 0x52535455	| 4089A5B0
    .long   0x56565758, 0x595A5B5C, 0x5D5E5F60, 0x60616262	| 4089A5C0
    .long   0x63646465, 0x66666768, 0x69696A6B, 0x6C6C6D6E	| 4089A5D0
    .long   0x6F6F7071, 0x72727374, 0x74757677, 0x77787979	| 4089A5E0
    .long   0x7A7B7C7C, 0x7D7E7F80, 0x81828283, 0x84848586	| 4089A5F0
    .long   0x86878888, 0x898A8A8B, 0x8C8D8D8E, 0x8F909091	| 4089A600
    .long   0x91929393, 0x94959596, 0x97979899, 0x999A9B9B	| 4089A610
    .long   0x9C9D9D9E, 0x9FA0A0A1, 0xA1A2A3A3, 0xA4A4A5A6	| 4089A620
    .long   0xA6A7A7A8, 0xA9A9AAAB, 0xABACADAD, 0xAEAFAFB0	| 4089A630
    .long   0xB0B1B2B2, 0xB3B3B4B5, 0xB5B6B6B7, 0xB8B8B9BA	| 4089A640
    .long   0xBABBBBBC, 0xBDBDBEBF, 0xBFC0C0C1, 0xC2C2C3C3	| 4089A650
    .long   0xC4C5C5C6, 0xC6C7C8C8, 0xC9C9CACB, 0xCBCCCCCD	| 4089A660
    .short  0xCECE, 0xCFD0, 0xD0D1, 0xD1D2, 0xD3D3, 0xD4D4, 0xD5D6	| 4089A670
CPUDECLDATA_B5E:        /* (data) */
    .short  0x0000	| 4089A67E
    .long   0x012007D1	| 4089A680
    .ascii  "Mac Std Gamma\000\000\000"
    .long   0x00000000, 0x00010100, 0x00080005	| 4089A694
    .long   0x090B0E10, 0x13151719, 0x1B1D1E20, 0x22242527	| 4089A6A0
    .long   0x282A2C2D, 0x2F303133, 0x34363738, 0x3A3B3C3E	| 4089A6B0
    .long   0x3F404243, 0x44454748, 0x494A4B4D, 0x4E4F5051	| 4089A6C0
    .long   0x52545556, 0x5758595A, 0x5B5C5E5F, 0x60616263	| 4089A6D0
    .long   0x64656667, 0x68696A6B, 0x6C6D6E6F, 0x70717273	| 4089A6E0
    .long   0x74757677, 0x78797A7B, 0x7C7D7E7F, 0x80818182	| 4089A6F0
    .long   0x83848586, 0x8788898A, 0x8B8C8C8D, 0x8E8F9091	| 4089A700
    .long   0x92939495, 0x95969798, 0x999A9B9B, 0x9C9D9E9F	| 4089A710
    .long   0xA0A1A1A2, 0xA3A4A5A6, 0xA6A7A8A9, 0xAAABABAC	| 4089A720
    .long   0xADAEAFB0, 0xB0B1B2B3, 0xB4B4B5B6, 0xB7B8B8B9	| 4089A730
    .long   0xBABBBCBC, 0xBDBEBFC0, 0xC0C1C2C3, 0xC3C4C5C6	| 4089A740
    .long   0xC7C7C8C9, 0xCACACBCC, 0xCDCDCECF, 0xD0D0D1D2	| 4089A750
    .long   0xD3D3D4D5, 0xD6D6D7D8, 0xD9D9DADB, 0xDCDCDDDE	| 4089A760
    .long   0xDFDFE0E1, 0xE1E2E3E4, 0xE4E5E6E7, 0xE7E8E9E9	| 4089A770
    .long   0xEAEBECEC, 0xEDEEEEEF, 0xF0F1F1F2, 0xF3F3F4F5	| 4089A780
    .short  0xF5F6, 0xF7F8, 0xF8F9, 0xFAFA, 0xFBFC, 0xFCFD, 0xFEFF	| 4089A790
CPUDECLDATA_C7E:        /* (data) */
    .short  0x0000	| 4089A79E
    .long   0x012207D2	| 4089A7A0
    .ascii  "Mac Gray Gamma\000\000"
    .long   0x00000000, 0x00000001, 0x01000008	| 4089A7B4
    .long   0x000A141D, 0x23262B2E, 0x30323437, 0x393B3C3E	| 4089A7C0
    .long   0x40414244, 0x4547484A, 0x4B4D4E4F, 0x50515254	| 4089A7D0
    .long   0x55565758, 0x5A5B5C5D, 0x5E5F6061, 0x63646566	| 4089A7E0
    .long   0x6768696A, 0x6B6C6D6E, 0x6F707171, 0x72737475	| 4089A7F0
    .long   0x76777879, 0x7A7B7C7D, 0x7E7F8080, 0x81828384	| 4089A800
    .long   0x84858687, 0x88898A8A, 0x8B8C8D8E, 0x8F909091	| 4089A810
    .long   0x92929394, 0x95969797, 0x98999A9A, 0x9B9C9D9E	| 4089A820
    .long   0x9E9FA0A1, 0xA1A2A3A3, 0xA4A5A6A7, 0xA7A8A9AA	| 4089A830
    .long   0xAAABACAD, 0xADAEAFAF, 0xB0B1B2B2, 0xB3B4B4B5	| 4089A840
    .long   0xB6B6B7B7, 0xB8B9B9BA, 0xBBBCBCBD, 0xBEBEBFC0	| 4089A850
    .long   0xC0C1C2C2, 0xC3C4C5C5, 0xC6C6C7C8, 0xC8C9CACB	| 4089A860
    .long   0xCCCDCDCE, 0xCFCFD0D0, 0xD1D2D2D3, 0xD3D4D5D6	| 4089A870
    .long   0xD6D7D7D8, 0xD9D9DADA, 0xDBDCDDDD, 0xDEDFDFE0	| 4089A880
    .long   0xE0E1E2E3, 0xE3E4E5E5, 0xE6E6E7E7, 0xE8E8E9EA	| 4089A890
    .long   0xEAEBEBEC, 0xEDEDEEEF, 0xF0F0F1F2, 0xF2F3F4F4	| 4089A8A0
    .long   0xF5F5F6F7, 0xF7F8F9FA, 0xFAFBFCFC, 0xFDFEFEFF	| 4089A8B0
CPUDECLDATA_DA0:        /* (data) */
    .short  0x0000, 0x0120, 0x07D3	| 4089A8C0
    .ascii  "Mac RGB Gamma\000"
    .long   0x00000000, 0x00000001, 0x01000008	| 4089A8D4
    .long   0x05070809, 0x0B0C0D0F, 0x10111214, 0x15161819	| 4089A8E0
    .long   0x1A1C1D1E, 0x20212223, 0x24262829, 0x2A2C2D2F	| 4089A8F0
    .long   0x30313334, 0x36373839, 0x3A3C3D3E, 0x40414243	| 4089A900
    .long   0x44454648, 0x494B4C4D, 0x4E4F5051, 0x52535455	| 4089A910
    .long   0x5758595A, 0x5B5C5D5E, 0x5F606163, 0x63656567	| 4089A920
    .long   0x67696A6B, 0x6C6D6E6F, 0x70717273, 0x74757677	| 4089A930
    .long   0x78797A7A, 0x7B7C7D7E, 0x7F818283, 0x83848586	| 4089A940
    .long   0x8788898A, 0x8B8C8D8E, 0x8E909091, 0x92939394	| 4089A950
    .long   0x95969798, 0x999A9B9C, 0x9D9E9FA0, 0xA0A1A2A3	| 4089A960
    .long   0xA4A4A5A6, 0xA7A8A9AA, 0xAAACADAD, 0xAEAEB0B1	| 4089A970
    .long   0xB2B3B3B4, 0xB5B6B7B8, 0xB9B9BABB, 0xBCBDBEBF	| 4089A980
    .long   0xBFC0C1C2, 0xC2C3C4C5, 0xC6C7C8C9, 0xCACBCCCD	| 4089A990
    .long   0xCDCECECF, 0xD0D1D2D3, 0xD3D4D5D6, 0xD6D7D8D8	| 4089A9A0
    .long   0xD9DADBDC, 0xDDDEDEDF, 0xE0E1E1E2, 0xE3E4E4E5	| 4089A9B0
    .long   0xE6E7E7E8, 0xE9EAEBEC, 0xEDEEEEEF, 0xEFF0F1F2	| 4089A9C0
    .long   0xF3F3F4F5, 0xF6F7F8F8, 0xF9F9FAFB, 0xFCFDFEFF	| 4089A9D0
CPUDECLDATA_EC0:        /* (data) */
    .long   0x80000058, 0x81000054, 0x82000074, 0x83000070	| 4089A9E0
    .long   0x86000048, 0x87000044, 0x8800008A, 0x89000086	| 4089A9F0
    .long   0x8A0000A8, 0x8B0000A4, 0x8C0000C6, 0x8D0000C2	| 4089AA00
    .long   0x8E0000E4, 0x8F0000E0, 0x90000102, 0x91000124	| 4089AA10
    .long   0x92000120, 0x93000142, 0x9400013E, 0x95000160	| 4089AA20
    .long   0x9600015C, 0xFF000000, 0x00000024, 0x001C8170	| 4089AA30
    .long   0x00170405, 0x0328A603, 0x0003002A, 0x00660382	| 4089AA40
    .long   0x83000365, 0x005000A0, 0x01400280, 0x00000026	| 4089AA50
    .long   0x00000000, 0x00000302, 0x0320A001, 0x00030013	| 4089AA60
    .long   0x00800183, 0x8400017F, 0x00400080, 0x01000200	| 4089AA70
    .long   0x04000000, 0x00260028, 0x4A900015, 0x06040428	| 4089AA80
    .long   0xA8030003, 0x002700E0, 0x01838400, 0x01DF0050	| 4089AA90
    .long   0x00A00140, 0x02800500, 0x00000026, 0x001549A0	| 4089AAA0
    .long   0x00150306, 0x0128A40A, 0x00020021, 0x00E00183	| 4089AAB0
    .long   0x840001DF, 0x005000A0, 0x01400280, 0x05000000	| 4089AAC0
    .long   0x0026001C, 0x81700017, 0x04040C34, 0xB3010003	| 4089AAD0
    .long   0x00270070, 0x02838400, 0x026F0068, 0x00D001A0	| 4089AAE0
    .long   0x03400680, 0x00000026, 0x00294A30, 0x00150404	| 4089AAF0
    .long   0x0632B301, 0x00020016, 0x00580283, 0x84000257	| 4089AB00
    .long   0x006400C8, 0x01900320, 0x06400000, 0x0026002C	| 4089AB10
    .long   0xA1C00016, 0x08040520, 0x04030003, 0x00100080	| 4089AB20
    .long   0x01848400, 0x017F0040, 0x00800100, 0x02000400	| 4089AB30
    .long   0x00000026, 0x002CA1C0, 0x00160304, 0x0228A603	| 4089AB40
    .long   0x00030010, 0x00E00183, 0x840001DF, 0x005000A0	| 4089AB50
    .long   0x01400280, 0x05000000, 0x0026002E, 0xD2000016	| 4089AB60
    .long   0x08040520, 0x04030003, 0x00160080, 0x01838400	| 4089AB70
    .long   0x01CB004D, 0x009A0134, 0x026804D0, 0x00000026	| 4089AB80
    .long   0x002ED200, 0x00160304, 0x0228A603, 0x00030010	| 4089AB90
    .long   0x00E00183, 0x8400023F, 0x006000C0, 0x01800300	| 4089ABA0
    .short  0x0600	| 4089ABB0
CPUDECLDATA_1092:       /* (4089ABB2 s24 -> CPUDECLDATA_1132) */
    .byte   0x01, 0x00, 0x00, 0xA0	| 4089ABB2 s24 -> CPUDECLDATA_1132
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089ABB6
CPUDECLDATA_10A2:       /* (4089ABC2 s24 -> CPUDECLDATA_1160) */
    .byte   0x01, 0x00, 0x00, 0xBE	| 4089ABC2 s24 -> CPUDECLDATA_1160
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089ABC6
CPUDECLDATA_10B2:       /* (4089ABD2 s24 -> CPUDECLDATA_118E) */
    .byte   0x01, 0x00, 0x00, 0xDC	| 4089ABD2 s24 -> CPUDECLDATA_118E
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00	| 4089ABD6
    .long   0x00000100, 0x00FA0300, 0x00010400, 0x0000FF00	| 4089ABE0
    .short  0x0000	| 4089ABF0
CPUDECLDATA_10D2:       /* (4089ABF2 s24 -> CPUDECLDATA_11EA) */
    .byte   0x01, 0x00, 0x01, 0x18	| 4089ABF2 s24 -> CPUDECLDATA_11EA
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089ABF6
CPUDECLDATA_10E2:       /* (4089AC02 s24 -> CPUDECLDATA_1218) */
    .byte   0x01, 0x00, 0x01, 0x36	| 4089AC02 s24 -> CPUDECLDATA_1218
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AC06
CPUDECLDATA_10F2:       /* (4089AC12 s24 -> CPUDECLDATA_1246) */
    .byte   0x01, 0x00, 0x01, 0x54	| 4089AC12 s24 -> CPUDECLDATA_1246
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AC16
CPUDECLDATA_1102:       /* (4089AC22 s24 -> CPUDECLDATA_1274) */
    .byte   0x01, 0x00, 0x01, 0x72	| 4089AC22 s24 -> CPUDECLDATA_1274
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AC26
CPUDECLDATA_1112:       /* (4089AC32 s24 -> CPUDECLDATA_12A2) */
    .byte   0x01, 0x00, 0x01, 0x90	| 4089AC32 s24 -> CPUDECLDATA_12A2
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AC36
CPUDECLDATA_1122:       /* (4089AC42 s24 -> CPUDECLDATA_12D0) */
    .byte   0x01, 0x00, 0x01, 0xAE	| 4089AC42 s24 -> CPUDECLDATA_12D0
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AC46
CPUDECLDATA_1132:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x0050, 0x0000, 0x0000	| 4089AC52
    .long   0x01E00280, 0x00000000, 0x00000000, 0x00480000	| 4089AC60
    .long   0x00480000, 0x00000001, 0x00010001, 0x00000000	| 4089AC70
CPUDECLDATA_1160:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x00500000, 0x00000366	| 4089AC80
    .long   0x02800000, 0x00000000, 0x00000050, 0x00000050	| 4089AC90
    .short  0x0000, 0x0000, 0x0001, 0x0001, 0x0001, 0x0000, 0x0000	| 4089ACA0
CPUDECLDATA_118E:       /* (data) */
    .short  0x0000	| 4089ACAE
    .long   0x002E0010, 0x00000040, 0x00000000, 0x01800200	| 4089ACB0
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 4089ACC0
    .long   0x00000001, 0x00010001, 0x00000000, 0x0000002E	| 4089ACD0
    .long   0x00100000, 0x00460000, 0x00000180, 0x02300000	| 4089ACE0
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 4089ACF0
    .short  0x0001, 0x0001, 0x0001, 0x0000, 0x0000	| 4089AD00
CPUDECLDATA_11EA:       /* (data) */
    .short  0x0000, 0x002E, 0x0010	| 4089AD0A
    .long   0x00000068, 0x00000000, 0x02700340, 0x00000000	| 4089AD10
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000001	| 4089AD20
    .long   0x00010001, 0x00000000	| 4089AD30
CPUDECLDATA_1218:       /* (data) */
    .long   0x0000002E, 0x00100000	| 4089AD38
    .long   0x00640000, 0x00000258, 0x03200000, 0x00000000	| 4089AD40
    .long   0x00000048, 0x00000048, 0x00000000, 0x00010001	| 4089AD50
    .short  0x0001, 0x0000, 0x0000	| 4089AD60
CPUDECLDATA_1246:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x0040	| 4089AD66
    .long   0x00000000, 0x01800200, 0x00000000, 0x00000000	| 4089AD70
    .long   0x00480000, 0x00480000, 0x00000001, 0x00010001	| 4089AD80
    .long   0x00000000	| 4089AD90
CPUDECLDATA_1274:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x00500000	| 4089AD94
    .long   0x000001E0, 0x02800000, 0x00000000, 0x00000048	| 4089ADA0
    .long   0x00000048, 0x00000000, 0x00010001, 0x00010000	| 4089ADB0
    .short  0x0000	| 4089ADC0
CPUDECLDATA_12A2:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x004D, 0x0000, 0x0000	| 4089ADC2
    .long   0x01CC0268, 0x00000000, 0x00000000, 0x00480000	| 4089ADD0
    .long   0x00480000, 0x00000001, 0x00010001, 0x00000000	| 4089ADE0
CPUDECLDATA_12D0:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x00600000, 0x00000240	| 4089ADF0
    .long   0x03000000, 0x00000000, 0x00000048, 0x00000048	| 4089AE00
    .short  0x0000, 0x0000, 0x0001, 0x0001, 0x0001, 0x0000, 0x0000	| 4089AE10
CPUDECLDATA_12FE:       /* (4089AE1E s24 -> CPUDECLDATA_139E) */
    .byte   0x01, 0x00, 0x00, 0xA0	| 4089AE1E s24 -> CPUDECLDATA_139E
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AE22
CPUDECLDATA_130E:       /* (4089AE2E s24 -> CPUDECLDATA_13CC) */
    .byte   0x01, 0x00, 0x00, 0xBE	| 4089AE2E s24 -> CPUDECLDATA_13CC
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AE32
CPUDECLDATA_131E:       /* (4089AE3E s24 -> CPUDECLDATA_13FA) */
    .byte   0x01, 0x00, 0x00, 0xDC	| 4089AE3E s24 -> CPUDECLDATA_13FA
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000, 0x0100, 0x00FA	| 4089AE42
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AE52
CPUDECLDATA_133E:       /* (4089AE5E s24 -> CPUDECLDATA_1456) */
    .byte   0x01, 0x00, 0x01, 0x18	| 4089AE5E s24 -> CPUDECLDATA_1456
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AE62
CPUDECLDATA_134E:       /* (4089AE6E s24 -> CPUDECLDATA_1484) */
    .byte   0x01, 0x00, 0x01, 0x36	| 4089AE6E s24 -> CPUDECLDATA_1484
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AE72
CPUDECLDATA_135E:       /* (4089AE7E s24 -> CPUDECLDATA_14B2) */
    .byte   0x01, 0x00, 0x01, 0x54	| 4089AE7E s24 -> CPUDECLDATA_14B2
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AE82
CPUDECLDATA_136E:       /* (4089AE8E s24 -> CPUDECLDATA_14E0) */
    .byte   0x01, 0x00, 0x01, 0x72	| 4089AE8E s24 -> CPUDECLDATA_14E0
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AE92
CPUDECLDATA_137E:       /* (4089AE9E s24 -> CPUDECLDATA_150E) */
    .byte   0x01, 0x00, 0x01, 0x90	| 4089AE9E s24 -> CPUDECLDATA_150E
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AEA2
CPUDECLDATA_138E:       /* (4089AEAE s24 -> CPUDECLDATA_153C) */
    .byte   0x01, 0x00, 0x01, 0xAE	| 4089AEAE s24 -> CPUDECLDATA_153C
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089AEB2
CPUDECLDATA_139E:       /* (data) */
    .short  0x0000	| 4089AEBE
    .long   0x002E0010, 0x000000A0, 0x00000000, 0x01E00280	| 4089AEC0
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 4089AED0
    .long   0x00000002, 0x00010002, 0x00000000	| 4089AEE0
CPUDECLDATA_13CC:       /* (data) */
    .long   0x0000002E	| 4089AEEC
    .long   0x00100000, 0x00A00000, 0x00000366, 0x02800000	| 4089AEF0
    .long   0x00000000, 0x00000050, 0x00000050, 0x00000000	| 4089AF00
    .long   0x00020001	| 4089AF10
    .long   0x00020000 /* number, not an address (F5) */	| 4089AF14
    .short  0x0000	| 4089AF18
CPUDECLDATA_13FA:       /* (data) */
    .short  0x0000, 0x002E, 0x0010	| 4089AF1A
    .long   0x00000080, 0x00000000, 0x01800200, 0x00000000	| 4089AF20
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000002	| 4089AF30
    .long   0x00010002, 0x00000000, 0x0000002E, 0x00100000	| 4089AF40
    .long   0x008C0000, 0x00000180, 0x02300000, 0x00000000	| 4089AF50
    .long   0x00000048, 0x00000048, 0x00000000, 0x00020001	| 4089AF60
    .long   0x00020000 /* number, not an address (F5) */	| 4089AF70
    .short  0x0000	| 4089AF74
CPUDECLDATA_1456:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x00D0	| 4089AF76
    .long   0x00000000, 0x02700340, 0x00000000, 0x00000000	| 4089AF80
    .long   0x00480000, 0x00480000, 0x00000002, 0x00010002	| 4089AF90
    .long   0x00000000	| 4089AFA0
CPUDECLDATA_1484:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x00C80000	| 4089AFA4
    .long   0x00000258, 0x03200000, 0x00000000, 0x00000048	| 4089AFB0
    .long   0x00000048, 0x00000000, 0x00020001	| 4089AFC0
    .long   0x00020000 /* number, not an address (F5) */	| 4089AFCC
    .short  0x0000	| 4089AFD0
CPUDECLDATA_14B2:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x0080, 0x0000, 0x0000	| 4089AFD2
    .long   0x01800200, 0x00000000, 0x00000000, 0x00480000	| 4089AFE0
    .long   0x00480000, 0x00000002, 0x00010002, 0x00000000	| 4089AFF0
CPUDECLDATA_14E0:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x00A00000, 0x000001E0	| 4089B000
    .long   0x02800000, 0x00000000, 0x00000048, 0x00000048	| 4089B010
    .long   0x00000000, 0x00020001	| 4089B020
    .long   0x00020000 /* number, not an address (F5) */	| 4089B028
    .short  0x0000	| 4089B02C
CPUDECLDATA_150E:       /* (data) */
    .short  0x0000	| 4089B02E
    .long   0x002E0010, 0x0000009A, 0x00000000, 0x01CC0268	| 4089B030
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 4089B040
    .long   0x00000002, 0x00010002, 0x00000000	| 4089B050
CPUDECLDATA_153C:       /* (data) */
    .long   0x0000002E	| 4089B05C
    .long   0x00100000, 0x00C00000, 0x00000240, 0x03000000	| 4089B060
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 4089B070
    .long   0x00020001	| 4089B080
    .long   0x00020000 /* number, not an address (F5) */	| 4089B084
    .short  0x0000	| 4089B088
CPUDECLDATA_156A:       /* (4089B08A s24 -> CPUDECLDATA_160A) */
    .byte   0x01, 0x00, 0x00, 0xA0	| 4089B08A s24 -> CPUDECLDATA_160A
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B08E
CPUDECLDATA_157A:       /* (4089B09A s24 -> CPUDECLDATA_1638) */
    .byte   0x01, 0x00, 0x00, 0xBE	| 4089B09A s24 -> CPUDECLDATA_1638
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B09E
CPUDECLDATA_158A:       /* (4089B0AA s24 -> CPUDECLDATA_1666) */
    .byte   0x01, 0x00, 0x00, 0xDC	| 4089B0AA s24 -> CPUDECLDATA_1666
    .short  0x0300	| 4089B0AE
    .long   0x00010400, 0x0000FF00, 0x00000100, 0x00FA0300	| 4089B0B0
    .short  0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B0C0
CPUDECLDATA_15AA:       /* (4089B0CA s24 -> CPUDECLDATA_16C2) */
    .byte   0x01, 0x00, 0x01, 0x18	| 4089B0CA s24 -> CPUDECLDATA_16C2
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B0CE
CPUDECLDATA_15BA:       /* (4089B0DA s24 -> CPUDECLDATA_16F0) */
    .byte   0x01, 0x00, 0x01, 0x36	| 4089B0DA s24 -> CPUDECLDATA_16F0
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B0DE
CPUDECLDATA_15CA:       /* (4089B0EA s24 -> CPUDECLDATA_171E) */
    .byte   0x01, 0x00, 0x01, 0x54	| 4089B0EA s24 -> CPUDECLDATA_171E
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B0EE
CPUDECLDATA_15DA:       /* (4089B0FA s24 -> CPUDECLDATA_174C) */
    .byte   0x01, 0x00, 0x01, 0x72	| 4089B0FA s24 -> CPUDECLDATA_174C
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B0FE
CPUDECLDATA_15EA:       /* (4089B10A s24 -> CPUDECLDATA_177A) */
    .byte   0x01, 0x00, 0x01, 0x90	| 4089B10A s24 -> CPUDECLDATA_177A
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B10E
CPUDECLDATA_15FA:       /* (4089B11A s24 -> CPUDECLDATA_17A8) */
    .byte   0x01, 0x00, 0x01, 0xAE	| 4089B11A s24 -> CPUDECLDATA_17A8
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B11E
CPUDECLDATA_160A:       /* (data) */
    .short  0x0000, 0x002E, 0x0010	| 4089B12A
    .long   0x00000140, 0x00000000, 0x01E00280, 0x00000000	| 4089B130
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000004	| 4089B140
    .long   0x00010004, 0x00000000	| 4089B150
CPUDECLDATA_1638:       /* (data) */
    .long   0x0000002E, 0x00100000	| 4089B158
    .long   0x01400000, 0x00000366, 0x02800000, 0x00000000	| 4089B160
    .long   0x00000050, 0x00000050, 0x00000000, 0x00040001	| 4089B170
    .short  0x0004, 0x0000, 0x0000	| 4089B180
CPUDECLDATA_1666:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x0100	| 4089B186
    .long   0x00000000, 0x01800200, 0x00000000, 0x00000000	| 4089B190
    .long   0x00480000, 0x00480000, 0x00000004, 0x00010004	| 4089B1A0
    .long   0x00000000, 0x0000002E, 0x00100000, 0x01180000	| 4089B1B0
    .long   0x00000180, 0x02300000, 0x00000000, 0x00000048	| 4089B1C0
    .long   0x00000048, 0x00000000, 0x00040001, 0x00040000	| 4089B1D0
    .short  0x0000	| 4089B1E0
CPUDECLDATA_16C2:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x01A0, 0x0000, 0x0000	| 4089B1E2
    .long   0x02700340, 0x00000000, 0x00000000, 0x00480000	| 4089B1F0
    .long   0x00480000, 0x00000004, 0x00010004, 0x00000000	| 4089B200
CPUDECLDATA_16F0:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x01900000, 0x00000258	| 4089B210
    .long   0x03200000, 0x00000000, 0x00000048, 0x00000048	| 4089B220
    .short  0x0000, 0x0000, 0x0004, 0x0001, 0x0004, 0x0000, 0x0000	| 4089B230
CPUDECLDATA_171E:       /* (data) */
    .short  0x0000	| 4089B23E
    .long   0x002E0010, 0x00000100, 0x00000000, 0x01800200	| 4089B240
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 4089B250
    .long   0x00000004, 0x00010004, 0x00000000	| 4089B260
CPUDECLDATA_174C:       /* (data) */
    .long   0x0000002E	| 4089B26C
    .long   0x00100000, 0x01400000, 0x000001E0, 0x02800000	| 4089B270
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 4089B280
    .short  0x0004, 0x0001, 0x0004, 0x0000, 0x0000	| 4089B290
CPUDECLDATA_177A:       /* (data) */
    .short  0x0000, 0x002E, 0x0010	| 4089B29A
    .long   0x00000134, 0x00000000, 0x01CC0268, 0x00000000	| 4089B2A0
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000004	| 4089B2B0
    .long   0x00010004, 0x00000000	| 4089B2C0
CPUDECLDATA_17A8:       /* (data) */
    .long   0x0000002E, 0x00100000	| 4089B2C8
    .long   0x01800000, 0x00000240, 0x03000000, 0x00000000	| 4089B2D0
    .long   0x00000048, 0x00000048, 0x00000000, 0x00040001	| 4089B2E0
    .short  0x0004, 0x0000, 0x0000	| 4089B2F0
CPUDECLDATA_17D6:       /* (4089B2F6 s24 -> CPUDECLDATA_1876) */
    .byte   0x01, 0x00, 0x00, 0xA0	| 4089B2F6 s24 -> CPUDECLDATA_1876
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B2FA
CPUDECLDATA_17E6:       /* (4089B306 s24 -> CPUDECLDATA_18A4) */
    .byte   0x01, 0x00, 0x00, 0xBE	| 4089B306 s24 -> CPUDECLDATA_18A4
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B30A
CPUDECLDATA_17F6:       /* (4089B316 s24 -> CPUDECLDATA_18D2) */
    .byte   0x01, 0x00, 0x00, 0xDC	| 4089B316 s24 -> CPUDECLDATA_18D2
    .short  0x0300, 0x0001, 0x0400	| 4089B31A
    .long   0x0000FF00, 0x00000100, 0x00FA0300, 0x00010400	| 4089B320
    .short  0x0000, 0xFF00, 0x0000	| 4089B330
CPUDECLDATA_1816:       /* (4089B336 s24 -> CPUDECLDATA_192E) */
    .byte   0x01, 0x00, 0x01, 0x18	| 4089B336 s24 -> CPUDECLDATA_192E
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B33A
CPUDECLDATA_1826:       /* (4089B346 s24 -> CPUDECLDATA_195C) */
    .byte   0x01, 0x00, 0x01, 0x36	| 4089B346 s24 -> CPUDECLDATA_195C
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B34A
CPUDECLDATA_1836:       /* (4089B356 s24 -> CPUDECLDATA_198A) */
    .byte   0x01, 0x00, 0x01, 0x54	| 4089B356 s24 -> CPUDECLDATA_198A
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B35A
CPUDECLDATA_1846:       /* (4089B366 s24 -> CPUDECLDATA_19B8) */
    .byte   0x01, 0x00, 0x01, 0x72	| 4089B366 s24 -> CPUDECLDATA_19B8
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B36A
CPUDECLDATA_1856:       /* (4089B376 s24 -> CPUDECLDATA_19E6) */
    .byte   0x01, 0x00, 0x01, 0x90	| 4089B376 s24 -> CPUDECLDATA_19E6
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B37A
CPUDECLDATA_1866:       /* (4089B386 s24 -> CPUDECLDATA_1A14) */
    .byte   0x01, 0x00, 0x01, 0xAE	| 4089B386 s24 -> CPUDECLDATA_1A14
    .short  0x0300, 0x0001, 0x0400, 0x0000, 0xFF00, 0x0000	| 4089B38A
CPUDECLDATA_1876:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x0280	| 4089B396
    .long   0x00000000, 0x01E00280, 0x00000000, 0x00000000	| 4089B3A0
    .long   0x00480000, 0x00480000, 0x00000008, 0x00010008	| 4089B3B0
    .long   0x00000000	| 4089B3C0
CPUDECLDATA_18A4:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x02800000	| 4089B3C4
    .long   0x00000366, 0x02800000, 0x00000000, 0x00000050	| 4089B3D0
    .long   0x00000050, 0x00000000, 0x00080001, 0x00080000	| 4089B3E0
    .short  0x0000	| 4089B3F0
CPUDECLDATA_18D2:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x0200, 0x0000, 0x0000	| 4089B3F2
    .long   0x01800200, 0x00000000, 0x00000000, 0x00480000	| 4089B400
    .long   0x00480000, 0x00000008, 0x00010008, 0x00000000	| 4089B410
    .long   0x0000002E, 0x00100000, 0x02300000, 0x00000180	| 4089B420
    .long   0x02300000, 0x00000000, 0x00000048, 0x00000048	| 4089B430
    .short  0x0000, 0x0000, 0x0008, 0x0001, 0x0008, 0x0000, 0x0000	| 4089B440
CPUDECLDATA_192E:       /* (data) */
    .short  0x0000	| 4089B44E
    .long   0x002E0010, 0x00000340, 0x00000000, 0x02700340	| 4089B450
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 4089B460
    .long   0x00000008, 0x00010008, 0x00000000	| 4089B470
CPUDECLDATA_195C:       /* (data) */
    .long   0x0000002E	| 4089B47C
    .long   0x00100000, 0x03200000, 0x00000258, 0x03200000	| 4089B480
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000000	| 4089B490
    .short  0x0008, 0x0001, 0x0008, 0x0000, 0x0000	| 4089B4A0
CPUDECLDATA_198A:       /* (data) */
    .short  0x0000, 0x002E, 0x0010	| 4089B4AA
    .long   0x00000200, 0x00000000, 0x01800200, 0x00000000	| 4089B4B0
    .long   0x00000000, 0x00480000, 0x00480000, 0x00000008	| 4089B4C0
    .long   0x00010008, 0x00000000	| 4089B4D0
CPUDECLDATA_19B8:       /* (data) */
    .long   0x0000002E, 0x00100000	| 4089B4D8
    .long   0x02800000, 0x000001E0, 0x02800000, 0x00000000	| 4089B4E0
    .long   0x00000048, 0x00000048, 0x00000000, 0x00080001	| 4089B4F0
    .short  0x0008, 0x0000, 0x0000	| 4089B500
CPUDECLDATA_19E6:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x0268	| 4089B506
    .long   0x00000000, 0x01CC0268, 0x00000000, 0x00000000	| 4089B510
    .long   0x00480000, 0x00480000, 0x00000008, 0x00010008	| 4089B520
    .long   0x00000000	| 4089B530
CPUDECLDATA_1A14:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x03000000	| 4089B534
    .long   0x00000240, 0x03000000, 0x00000000, 0x00000048	| 4089B540
    .long   0x00000048, 0x00000000, 0x00080001, 0x00080000	| 4089B550
    .short  0x0000	| 4089B560
CPUDECLDATA_1A42:       /* (4089B562 s24 -> CPUDECLDATA_1AC2) */
    .byte   0x01, 0x00, 0x00, 0x80	| 4089B562 s24 -> CPUDECLDATA_1AC2
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 4089B566
CPUDECLDATA_1A52:       /* (4089B572 s24 -> CPUDECLDATA_1AF0) */
    .byte   0x01, 0x00, 0x00, 0x9E	| 4089B572 s24 -> CPUDECLDATA_1AF0
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 4089B576
CPUDECLDATA_1A62:       /* (4089B582 s24 -> CPUDECLDATA_1B1E) */
    .byte   0x01, 0x00, 0x00, 0xBC	| 4089B582 s24 -> CPUDECLDATA_1B1E
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 4089B586
CPUDECLDATA_1A72:       /* (4089B592 s24 -> CPUDECLDATA_1B4C) */
    .byte   0x01, 0x00, 0x00, 0xDA	| 4089B592 s24 -> CPUDECLDATA_1B4C
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 4089B596
CPUDECLDATA_1A82:       /* (4089B5A2 s24 -> CPUDECLDATA_1B7A) */
    .byte   0x01, 0x00, 0x00, 0xF8	| 4089B5A2 s24 -> CPUDECLDATA_1B7A
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 4089B5A6
CPUDECLDATA_1A92:       /* (4089B5B2 s24 -> CPUDECLDATA_1BA8) */
    .byte   0x01, 0x00, 0x01, 0x16	| 4089B5B2 s24 -> CPUDECLDATA_1BA8
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 4089B5B6
CPUDECLDATA_1AA2:       /* (4089B5C2 s24 -> CPUDECLDATA_1BD6) */
    .byte   0x01, 0x00, 0x01, 0x34	| 4089B5C2 s24 -> CPUDECLDATA_1BD6
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 4089B5C6
CPUDECLDATA_1AB2:       /* (4089B5D2 s24 -> CPUDECLDATA_1C04) */
    .byte   0x01, 0x00, 0x01, 0x52	| 4089B5D2 s24 -> CPUDECLDATA_1C04
    .short  0x0300, 0x0001, 0x0400, 0x0002, 0xFF00, 0x0000	| 4089B5D6
CPUDECLDATA_1AC2:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x0500, 0x0000, 0x0000	| 4089B5E2
    .long   0x01E00280, 0x00000000, 0x00000000, 0x00480000	| 4089B5F0
    .long   0x00480000, 0x00100010, 0x00030005, 0x00000000	| 4089B600
CPUDECLDATA_1AF0:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x04000000, 0x00000180	| 4089B610
    .long   0x02000000, 0x00000000, 0x00000048, 0x00000048	| 4089B620
    .short  0x0000, 0x0010, 0x0010, 0x0003, 0x0005, 0x0000, 0x0000	| 4089B630
CPUDECLDATA_1B1E:       /* (data) */
    .short  0x0000	| 4089B63E
    .long   0x002E0010, 0x00000680, 0x00000000, 0x02700340	| 4089B640
    .long   0x00000000, 0x00000000, 0x00480000, 0x00480000	| 4089B650
    .long   0x00100010, 0x00030005, 0x00000000	| 4089B660
CPUDECLDATA_1B4C:       /* (data) */
    .long   0x0000002E	| 4089B66C
    .long   0x00100000, 0x06400000, 0x00000258, 0x03200000	| 4089B670
    .long   0x00000000, 0x00000048, 0x00000048, 0x00000010	| 4089B680
    .short  0x0010, 0x0003, 0x0005, 0x0000, 0x0000	| 4089B690
CPUDECLDATA_1B7A:       /* (data) */
    .short  0x0000, 0x002E, 0x0010	| 4089B69A
    .long   0x00000400, 0x00000000, 0x01800200, 0x00000000	| 4089B6A0
    .long   0x00000000, 0x00480000, 0x00480000, 0x00100010	| 4089B6B0
    .long   0x00030005, 0x00000000	| 4089B6C0
CPUDECLDATA_1BA8:       /* (data) */
    .long   0x0000002E, 0x00100000	| 4089B6C8
    .long   0x05000000, 0x000001E0, 0x02800000, 0x00000000	| 4089B6D0
    .long   0x00000048, 0x00000048, 0x00000010, 0x00100003	| 4089B6E0
    .short  0x0005, 0x0000, 0x0000	| 4089B6F0
CPUDECLDATA_1BD6:       /* (data) */
    .short  0x0000, 0x002E, 0x0010, 0x0000, 0x04D0	| 4089B6F6
    .long   0x00000000, 0x01CC0268, 0x00000000, 0x00000000	| 4089B700
    .long   0x00480000, 0x00480000, 0x00100010, 0x00030005	| 4089B710
    .long   0x00000000	| 4089B720
CPUDECLDATA_1C04:       /* (data) */
    .long   0x0000002E, 0x00100000, 0x06000000	| 4089B724
    .long   0x00000240, 0x03000000, 0x00000000, 0x00000048	| 4089B730
    .long   0x00000048, 0x00000010, 0x00100003, 0x00050000	| 4089B740
    .short  0x0000	| 4089B750
CPUDECLDATA_1C32:       /* (data) */
    .short  0x0000, 0x056E, 0x0202, 0x0000	| 4089B752
    .long   CPUDECLDATA_1D0E-.	| 4089B75A
CPUDECLDATA_1C3E:       /* loop: move */
    moveb %d0,%sp@-
    movew %a1@+,%d1
CPUDECLDATA_1C42:       /* loop: move */
    moveb %a1@+,%d0
    cmpb %sp@,%d0
    jbeq CPUDECLDATA_1C60
    moveb %d0,%a0@(50)
    tstb %d3
    jbeq CPUDECLDATA_1C5C
    rolw #8,%d3
    cmpb %d0,%d3
    jbeq CPUDECLDATA_1C66
    rolw #8,%d3
    cmpb %d0,%d3
    jbeq CPUDECLDATA_1C66
CPUDECLDATA_1C5C:       /* set up and call _SlotManager */
    moveq #49,%d0	/* _SlotManager 49: DELETESRTREC, sDeleteSRTRec */
    _SlotManager
CPUDECLDATA_1C60:       /* count down (loop) */
    dbf %d1,CPUDECLDATA_1C42
    jbra CPUDECLDATA_1C78
CPUDECLDATA_1C66:       /* set up and call _SlotManager */
    movel #1,%a0@(24)
    clrl %a0@(4)
    moveq #9,%d0	/* _SlotManager 9: SETSRSRCSTATE, sSetsRsrcState */
    _SlotManager
    jbra CPUDECLDATA_1C60
CPUDECLDATA_1C78:       /* test %sp@+ */
    tstb %sp@+
    rts
CPUDECLDATA_1C7C:       /* loop: move */
    movew TimeVIADB,%d0
    lsrw #3,%d0
CPUDECLDATA_1C82:       /* loop: tst */
    tstb %a0@
    dbf %d0,CPUDECLDATA_1C82
    rts

CPUDECLDATA_1C8A:       /* loop: move */
    movew TimeVIADB,%d0
    lslw #3,%d0
CPUDECLDATA_1C8A_6:     /* loop: tst */
    tstb %a0@
    dbf %d0,CPUDECLDATA_1C8A_6
    rts

CPUDECLDATA_1C98:       /* loop: ro */
    roll #6,%d0
CPUDECLDATA_1C98_2:     /* loop: move */
    movel %d0,%d3
    andib #64,%d3
    moveb %a3@(16),%d2
    andib #1,%d2
    orb %d3,%d2
    moveb %d2,%a3@(16)
    orib #32,%d2
    moveb %d2,%a3@(16)
    rorl #1,%d0
    dbf %d1,CPUDECLDATA_1C98_2
    nop
    rts
CPUDECLDATA_1C98_28:    /* loop: move */
    movel %a0,%sp@-
    moveal VIA,%a0
    movew #7685,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_1C98
    movel %a1@+,%d0
    movew %a1@+,%d1
    jbne CPUDECLDATA_1C98_50
    movew #7684,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_1C98
    jbsr CPUDECLDATA_1C8A
    movew #7684,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_1C98
    jbra CPUDECLDATA_1C98_64
CPUDECLDATA_1C98_50:    /* call CPUDECLDATA_1C98 */
    jbsr CPUDECLDATA_1C98
    movew #7684,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_1C98
    jbsr CPUDECLDATA_1C8A
    movew #7680,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_1C98
CPUDECLDATA_1C98_64:    /* set %a0 */
    moveal %sp@+,%a0
    rts
CPUDECLDATA_1C98_68:    /* loop: clr */
    clrb %a4@(20)
CPUDECLDATA_1C98_6C:    /* loop: btst */
    btst #6,%a3@(2)
    jbne CPUDECLDATA_1C98_6C
    rts

CPUDECLDATA_1D0E:       /* from here: linkw %fp,#-82 */
    linkw %fp,#-82
    movel %a0,%fp@(-80)
    movew #1,%a0@(2)
    moveb #14,%fp@(-11)
    clrb %fp@(-9)
    lea %fp@(-60),%a0
    lea %fp@(-68),%a2
    movel %a2,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    tstw %a2@
    jbne CPUDECLDATA_1D0E_4A
    moveb #1,%a0@(50)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    moveb #32,%a0@(50)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    movew %a0@(2),%a2@
    movel %a2,%a0@(4)
    moveq #51,%d0	/* _SlotManager 51: INITSLOTPRAM */
    _SlotManager
CPUDECLDATA_1D0E_4A:    /* address 0xfeefe000 */
    lea 0xfeefe000,%a4
    lea 0xfee00000,%a3
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #212992,%a0
    bclr #1,%a0@
    nop
    nop
    moveb #1,%a3@(33)
    moveb #64,%a3@(18)
    clrb %a4@(16)
    moveq #0,%d6
    movew %d6,%fp@(-82)
    moveb %a4@(4),%d6
    lsrb #4,%d6
    cmpib #7,%d6
    jbne CPUDECLDATA_1D0E_14C
    clrb %d6
    moveal VIA,%a0
    moveb #4,%a4@(4)
    jbsr CPUDECLDATA_1C7C
    moveb %a4@(4),%d0
    lsrb #4,%d0
    moveb %d0,%d6
    lslb #2,%d6
    moveb #2,%a4@(4)
    jbsr CPUDECLDATA_1C7C
    moveb %a4@(4),%d0
    lsrb #4,%d0
    bclr #2,%d0
    jbeq CPUDECLDATA_1D0E_C6
    bset #1,%d0
CPUDECLDATA_1D0E_C6:    /* from here: orb %d0,%d6 */
    orb %d0,%d6
    lslb #2,%d6
    moveb #1,%a4@(4)
    jbsr CPUDECLDATA_1C7C
    moveb %a4@(4),%d0
    lsrb #5,%d0
    orb %d0,%d6
    clrb %a4@(4)
    lea %pc@(CPUDECLDATA_20A8),%a0
    movew %a0@+,%d1
CPUDECLDATA_1D0E_E6:    /* loop: cmp */
    cmpb %a0@+,%d6
    jbne CPUDECLDATA_1D0E_EE
    moveb %a0@+,%d6
    jbra CPUDECLDATA_1D0E_14C
CPUDECLDATA_1D0E_EE:    /* test %a0@+ */
    tstb %a0@+
    dbf %d1,CPUDECLDATA_1D0E_E6
    subqw #4,%sp
    moveal %sp,%a0
    movew #4,%d0
    swap %d0
    movew #252,%d0
    _ReadXPRam
    movel %sp@+,%d0
    cmpil #1380862286,%d0
    jbeq CPUDECLDATA_1D0E_13A
    lea %fp@(-60),%a0
    lea %fp@(-68),%a2
    movel %a2,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    moveb %a2@(7),%d0
    andib #64,%d0
    jbne CPUDECLDATA_1D0E_140
CPUDECLDATA_1D0E_126:   /* loop: move */
    movew #-1,%fp@(-82)
    moveq #0,%d7
    moveb #0xfe,%d5
    moveb #7,%d6
    jbra CPUDECLDATA_1D0E_23E
CPUDECLDATA_1D0E_13A:   /* set %d6 */
    moveb #6,%d6
    jbra CPUDECLDATA_1D0E_14C
CPUDECLDATA_1D0E_140:   /* set %d6 */
    moveb %a2@(7),%d6
    andib #63,%d6
    jbra CPUDECLDATA_1D0E_1E6
CPUDECLDATA_1D0E_14C:   /* clear %a4@(4) */
    clrb %a4@(4)
    moveb %d6,%fp@(-82)
    moveal PmgrBase,%a0
    btst #0,%a0@(15)
    jbne CPUDECLDATA_1D0E_168
    bset #6,%a0@(296)
    jbra CPUDECLDATA_1D0E_126
CPUDECLDATA_1D0E_168:   /* address %pc@(CPUDECLDATA_20D0) */
    lea %pc@(CPUDECLDATA_20D0),%a1
    movew #16,%d0
    muluw %d6,%d0
    addal %d0,%a1
    movel %a1,%fp@(-76)
    addql #8,%a1
    addql #4,%a1
    lea %fp@(-60),%a0
    moveb #1,%a0@(50)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    moveb #126,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    moveb %a1@,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    tstw %d0
    jbne CPUDECLDATA_1D0E_126
    moveal %a0@,%a1
    jbsr CPUDECLDATA_1C98_28
    lea 0xfe100000,%a1
    moveq #1,%d4
    moveq #1,%d0
    _SwapMMUMode
    movel %d0,%fp@(-4)
    moveb #67,%a4@(16)
    jbsr CPUDECLDATA_1C98_68
    movel #1197568633,%a1@
    subql #4,%sp@
    addql #4,%sp@
    movel %a1@,%d1
    cmpil #1197568633,%d1
    jbeq CPUDECLDATA_1D0E_1E0
    moveq #0,%d4
    bclr #1,%a4@(16)
    jbsr CPUDECLDATA_1C98_68
CPUDECLDATA_1D0E_1E0:   /* set up and call _SwapMMUMode */
    movel %fp@(-4),%d0
    _SwapMMUMode
CPUDECLDATA_1D0E_1E6:   /* address %pc@(CPUDECLDATA_20D0) */
    lea %pc@(CPUDECLDATA_20D0),%a1
    movew #16,%d0
    muluw %d6,%d0
    addal %d0,%a1
    movel %a1,%fp@(-76)
    addql #8,%a1
    movew #4,%d0
    muluw %d4,%d0
    addal %d0,%a1
    moveb %a1@(2),%d7
    moveb %a1@,%d5
    movew %a1@,%d3
    moveb %d6,%a2@(5)
    moveb %d4,%a2@(6)
    moveb %a2@(3),%d0
    cmpib #0x80,%d0
    jbcs CPUDECLDATA_1D0E_226
    cmpib #0x96,%d0
    jbhi CPUDECLDATA_1D0E_226
    cmpb %a2@(4),%d5
    jbeq CPUDECLDATA_1D0E_232
CPUDECLDATA_1D0E_226:   /* set %a2@(4) */
    moveb %d5,%a2@(4)
    moveb %d5,%a2@(3)
    moveb %d7,%a2@(2)
CPUDECLDATA_1D0E_232:   /* set up and call _SlotManager */
    movel %a2,%a0@(4)
    moveq #18,%d0	/* _SlotManager 18: PUTSLOTPRAM, sPutPRAMRec */
    _SlotManager
    moveb %a2@(3),%d5
CPUDECLDATA_1D0E_23E:   /* address %pc@(CPUDECLDATA_20B4) */
    lea %pc@(CPUDECLDATA_20B4),%a1
    moveb %d5,%d0
    lea %fp@(-60),%a0
    jbsr CPUDECLDATA_1C3E
    cmpib #0xfe,%d5
    jbeq CPUDECLDATA_1D0E_344
    moveb #1,%a0@(50)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    moveb #126,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    moveb %d5,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    tstw %d0
    jbne CPUDECLDATA_1D0E_344
    moveal %a0@,%a1
    movel %a1,%fp@(-72)
    bset #5,%a4@(112)
    bclr #5,%a4@(112)
    jbsr CPUDECLDATA_1C98_68
    clrb %a4@(8)
    jbsr CPUDECLDATA_1C98_28
    moveb %a1@+,%a4@(64)
    moveb %a1@+,%a4@(68)
    moveb %a1@+,%a4@(72)
    moveb %a1@+,%a4@(76)
    moveb %a1@+,%a4@(80)
    movew %a1@+,%a4@(84)
    movew %a1@+,%a4@(88)
    movew %a1@+,%a4@(92)
    movew %a1@+,%a4@(96)
    lea 0xfee0e000,%a2
    moveb #8,%a2@(2)
    addqw #1,%a2
    moveal %fp@(-76),%a5
    moveb #127,%a2@(-1)
    moveb %a5@(1),%a2@
    moveb %a5@(3),%a2@
    moveb %a5@(5),%a2@
    moveb #0xff,%a2@(-1)
    moveb %a5@,%a2@
    moveb %a5@(2),%a2@
    moveb %a5@(4),%a2@
    moveq #1,%d0
    _SwapMMUMode
    movel %d0,%fp@(-4)
    lea 0xfe100000,%a2
    moveal %fp@(-72),%a1
    movew %a1@(22),%d3
    movel #-1431655766,%d2
CPUDECLDATA_1D0E_308:   /* loop: moveq */
    moveq #0,%d1
    movew %a1@(24),%d1
    movew %d1,%d0
    andiw #3,%d0
    lsrw #2,%d1
    jbra CPUDECLDATA_1D0E_31A
CPUDECLDATA_1D0E_318:   /* loop: move */
    movel %d2,%a2@+
CPUDECLDATA_1D0E_31A:   /* count down */
    dbf %d1,CPUDECLDATA_1D0E_318
    jbra CPUDECLDATA_1D0E_322
CPUDECLDATA_1D0E_320:   /* loop: move */
    moveb %d2,%a2@+
CPUDECLDATA_1D0E_322:   /* count down */
    dbf %d0,CPUDECLDATA_1D0E_320
    notl %d2
    dbf %d3,CPUDECLDATA_1D0E_308
    movel %fp@(-4),%d0
    _SwapMMUMode
    moveb %a4@(16),%d0
    orib #0xbc,%d0
    moveb %d0,%a4@(16)
    moveal %fp@(-72),%a0
    _DisposPtr
CPUDECLDATA_1D0E_344:   /* set %a0 */
    moveal %fp@(-80),%a0
    moveal PmgrBase,%a1
    movew %fp@(-82),%d0
    unlk %fp
    jbmi CPUDECLDATA_1D0E_374
    bset #5,%a1@(296)
    movel #131082,%d0
    _PowerDispatch
    movew %sr,%sp@-
    oriw #1792,%sr
    moveb #20,0xfee00013
    movew %sp@+,%sr
    rts
CPUDECLDATA_1D0E_374:   /* clear bit 5 of %a1@(296) */
    bclr #5,%a1@(296)
    movew #-1,%a0@(2)
    clrb %a3@(33)
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #212992,%a0
    bset #1,%a0@
    rts
CPUDECLDATA_20A8:       /* (data) */
    .long   0x00042D0A, 0x17081404	| 4089BBC8
    .long   0x00093009	| 4089BBD0
CPUDECLDATA_20B4:       /* (data) */
    .long   0x00178081, 0x82838485, 0x86878889	| 4089BBD4
    .long   0x8A8B8C8D, 0x8E8F9090, 0x91929394, 0x95960000	| 4089BBE0
CPUDECLDATA_20D0:       /* (data) */
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4089BBF0
    .long   0x00000000, 0x00FF0000, 0x80008200, 0x81008300	| 4089BC00
    .long   0x05FF05FF, 0x05FF0000, 0x82848300, 0x83858400	| 4089BC10
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4089BC20
    .long   0x00FF00FF, 0x00FF0000, 0x90918300, 0x90928400	| 4089BC30
    .long   0x00FF00FF, 0x00FF0000, 0x86008200, 0x87008300	| 4089BC40
    .long   0x00FF00FF, 0x00FF0000, 0x88008300, 0x89008400	| 4089BC50
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4089BC60
    .long   0x00FF00FF, 0x00FF0000, 0x8A8E8300, 0x8B8F8400	| 4089BC70
    .long   0x00FF00FF, 0x00FF0000, 0x93958300, 0x94968400	| 4089BC80
    .long   0x00FF00FF, 0x00FF0000, 0x8C008300, 0x8D008400	| 4089BC90
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4089BCA0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4089BCB0
CPUDECLDATA_21A0:       /* (data) */
    .long   0x00000EC4, 0x4C000000, 0x00000000, 0x005C0000	| 4089BCC0
    .byte   0x01, 0xE4, 0x07, 0xFE, 0x07, 0xD0, 0x19	| 4089BCD0
    .ascii  ".Display_Video_Apple_ViSC\000"
    .byte   0x00	| 4089BCF1
CPUDECLDATA_21D2:       /* (data) */
    .byte   0x01, 0x7F, 0x00, 0x80, 0x03, 0x3F, 0x00, 0x40, 0x0F, 0x0F, 0x00, 0x10, 0xFF, 0x00, 0x00, 0x01	| 4089BCF2
    .byte   0x1F, 0x00, 0x00, 0x01	| 4089BD02
CPUDECLDATA_21E6:       /* (data) */
    .byte   0xAA, 0xAA, 0xAA, 0xAA, 0xCC, 0xCC, 0xCC, 0xCC, 0xF0, 0xF0, 0xF0, 0xF0, 0xFF, 0x00, 0xFF, 0x00	| 4089BD06
    .byte   0x00, 0x00, 0xFF, 0xFF	| 4089BD16
CPUDECLDATA_21E6_14:
    .byte   0x00, 0x03, 0x02, 0x06, 0x17, 0x2D, 0x70, 0x70, 0xA4, 0x40	| 4089BD1A
    moveq #112,%d0
    .short  0xA722	| 4089BD26 _NewHandle (flags 0x0700)
    bnew CPUDECLDATA_2370_14
    movel %a0,%a1@(20)
    _HLock
    movel %a0@,%d0
    _StripAddress
    moveal %d0,%a3
    movel #-18817024,%a3@(24)
    movel #-18874368,%a3@(28)
    movel #-17833984,%a3@(32)
    movel #-32505856,%a3@(4)
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #212992,%a0
    movel %a0,%a3@(36)
    moveq #16,%d0
    .short  0xA71E	| 4089BD6E _NewPtr (flags 0x0700)
    bnew CPUDECLDATA_2370_2_C
    movel %a0,%a3@(8)
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    moveb %a1@(41),%a0@(50)
    clrb %a0@(51)
    moveq #22,%d0
    _SlotManager
    .short  0x6600, 0x0106	| bnew 4089be9a <CPUDECLDATA_2370+0xa>
    moveb #64,%a0@(50)
    moveq #6,%d0
    _SlotManager
    bnes CPUDECLDATA_21E6_C2
    moveb #0x80,%a0@(50)	| 4089BDA2
    moveq #5,%d0
    _SlotManager
    bnes CPUDECLDATA_21E6_C2
    moveal %a0@,%a0
    movel %a0,%a3@(16)
    addqw #2,%a0
CPUDECLDATA_21E6_B0:
    tstb %a0@+
    bnes CPUDECLDATA_21E6_B0
    movel %a0,%d0
    addqw #1,%d0
    bclr #0,%d0
    movel %d0,%a3@(12)
    bras CPUDECLDATA_21E6_FC
CPUDECLDATA_21E6_C2:
    moveq #12,%d0
    addiw #256,%d0
    .short  0xA71E	| 4089BDCE _NewPtr (flags 0x0700)
    bnew CPUDECLDATA_2370_2_8
    movel %a0,%a3@(16)
    movel %a0,%a3@(12)
    movew #32,%a0@(2)
    movew #1,%a0@(6)
    movew #256,%a0@(8)
    movew #8,%a0@(10)
    lea %a0@(268),%a0
    movew #255,%d0
CPUDECLDATA_21E6_F6:
    moveb %d0,%a0@-
    dbf %d0,CPUDECLDATA_21E6_F6
CPUDECLDATA_21E6_FC:
    moveal %sp,%a0
    moveb #14,%a0@(49)
    moveb #1,%a0@(50)
    clrb %a0@(51)
    moveq #22,%d0
    _SlotManager
    .short  0x6600, 0x007A	| bnew 4089be94 <CPUDECLDATA_2370+0x4>
    moveb #126,%a0@(50)
    moveq #6,%d0
    _SlotManager
    .short  0x6600, 0x006C	| bnew 4089be94 <CPUDECLDATA_2370+0x4>
    moveb %a1@(41),%a0@(50)
    moveq #5,%d0
    _SlotManager
    .short  0x6600, 0x005E	| bnew 4089be94 <CPUDECLDATA_2370+0x4>
    movel %a0@,%a3@(20)
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0
    _SlotManager
    bnew CPUDECLDATA_2370_2
    moveq #0,%d2
    moveb %sp@(5),%d2
    moveb %sp@(6),%d1
    lea %sp@(64),%sp
    movew %d2,%a3@(52)
    moveb %d1,%a3@(55)
    moveb %a1@(41),%a3@(54)
    bsrw CPUDECLDATA_2CE2
    bsrw CPUDECLDATA_277A
    bnew CPUDECLDATA_2370_2_C	| 4089BE74
    cmpiw #1,%a3@(52)
    beqs CPUDECLDATA_21E6_17C
    bras CPUDECLDATA_21E6_188
CPUDECLDATA_21E6_17C:
    bset #13,%a3@(48)
    bset #15,%a3@(48)
CPUDECLDATA_21E6_188:
    moveq #0,%d0
CPUDECLDATA_2370:       /* return */
    rts
CPUDECLDATA_2370_2:
    addqw #8,%sp	| 4089BE92
    moveal %a3@(16),%a0
    _DisposPtr
CPUDECLDATA_2370_2_8:
    lea %sp@(56),%sp	| 4089BE9A
CPUDECLDATA_2370_2_C:
    moveal %a1@(20),%a0	| 4089BE9E
    _DisposHandle
CPUDECLDATA_2370_14:
    moveq #-23,%d0
    jbra CPUDECLDATA_2370
    moveml %a0-%a1,%sp@-
    moveal %a0@(28),%a2
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    movew %a0@(26),%d0
    cmpiw #9,%d0
    bhis CPUDECLDATA_2370_50
    movew %pc@(CPUDECLDATA_2370_3C,%d0:w:2),%d0
    jmp %pc@(CPUDECLDATA_2370_3C,%d0:w)
CPUDECLDATA_2370_3C:
    orib #40,%a2@(0x5a,%d0:w)
    movepw %a2@(630),%d0
    bchg %d1,%fp@
    .short  0x037E	| .short 0x037e
    bclr %d1,%a4@+
    .short  0x0404, 0x0412	| 4089BEDC subib #18,%d4
CPUDECLDATA_2370_50:
    cmpiw #131,%d0
    beqw CPUDECLDATA_277A_34_80
    cmpiw #132,%d0
    beqw CPUDECLDATA_277A_34_FC
CPUDECLDATA_23D0:       /* result -17 */
    moveq #-17,%d0
    jbra CPUDECLDATA_23D4_2

CPUDECLDATA_23D4:       /* loop: moveq */
    moveq #0,%d0
CPUDECLDATA_23D4_2:     /* restore registers */
    moveml %sp@+,%a0-%a1
    jbra CPUDECLDATA_2B6C
    .short  0x34BC	| 4089BEFE
    .long   0x0080377C, 0x00800032	| 4089BF00
    moveq #0,%d1
    moveq #0,%d0
    movew %d0,%a2@(6)
    jbsr CPUDECLDATA_2BD8
    bclr #10,%a3@(48)
    movel %a3@(4),%a2@(8)
    jbsr CPUDECLDATA_2C04
    jbra CPUDECLDATA_23D4
    .short  0x3212	| 4089BF26
    jbsr CPUDECLDATA_2B7C
    jbne CPUDECLDATA_23D0
    tstw %a2@(6)
    jbne CPUDECLDATA_23D0
    movew %a2@,%d2
    cmpw %a3@(50),%d2
    jbeq CPUDECLDATA_23D4_D8
    movew %d2,%a3@(50)
    moveml %a4-%fp,%sp@-
    moveal %a3@(12),%a0
    lea %a0@(12),%a4
    addaw %a0@(4),%a4
    moveal %a4,%a5
    moveal %a4,%fp
    cmpiw #1,%a0@(6)
    jbeq CPUDECLDATA_23D4_7E
    movew %a0@(10),%d2
    movew %a0@(8),%d0
    addqw #7,%d2
    lsrw #3,%d2
    muluw %d2,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
CPUDECLDATA_23D4_7E:    /* set %d3 */
    movew %a0@(8),%d3
    moveal %a3@(24),%a0
    addqw #1,%a0
    clrb %a0@(-1)
    movew %sr,%sp@-
    jbsr CPUDECLDATA_2BA6
    movew %d3,%d0
    subqw #1,%d0
    movew %a3@(48),%d2
    lsrw #1,%d3
CPUDECLDATA_23D4_9C:    /* loop: btst */
    btst #13,%d2
    jbeq CPUDECLDATA_23D4_A8
    clrb %a0@
    clrb %a0@
    jbra CPUDECLDATA_23D4_B0
CPUDECLDATA_23D4_A8:    /* set %a0@ */
    moveb %a4@(0x0,%d3:w),%a0@
    moveb %a5@(0x0,%d3:w),%a0@
CPUDECLDATA_23D4_B0:    /* set %a0@ */
    moveb %fp@(0x0,%d3:w),%a0@
    dbf %d0,CPUDECLDATA_23D4_9C
    movew %sp@+,%sr
    moveml %sp@+,%a4-%fp
    jbsr CPUDECLDATA_2BD8
    cmpiw #132,%a3@(50)
    jblt CPUDECLDATA_23D4_D2
    bset #10,%a3@(48)
    jbra CPUDECLDATA_23D4_D8
CPUDECLDATA_23D4_D2:    /* clear bit 10 of %a3@(48) */
    bclr #10,%a3@(48)
CPUDECLDATA_23D4_D8:    /* set %a2@(8) */
    movel %a3@(4),%a2@(8)
    jbra CPUDECLDATA_23D4
    btst #10,%a3@(48)
    bnew CPUDECLDATA_23D0
CPUDECLDATA_23D4_D8_14:
    tstl %a2@
    beqw CPUDECLDATA_23D0
    moveml %d4-%d7/%a1/%a4-%fp,%sp@-
    movew %a3@(48),%d5
    cmpiw #-1,%a2@(4)
    beqs CPUDECLDATA_23D4_D8_3A
    bset #11,%d5
    cmpiw #131,%a3@(50)
    blts CPUDECLDATA_23D4_D8_3A
    bset #12,%d5
CPUDECLDATA_23D4_D8_3A:
    moveal %a3@(12),%a0
    movew %a0@(4),%d0
    lea %a0@(0xc,%d0:w),%a4
    moveal %a4,%a5
    moveal %a4,%fp
    movew %a0@(10),%d7
    cmpiw #1,%a0@(6)
    jbeq CPUDECLDATA_23D4_140
    movew %a0@(8),%d0
    movew %d7,%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %d1,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
CPUDECLDATA_23D4_140:   /* set %d1 */
    movew %a3@(50),%d1
    subiw #128,%d1
    moveq #0,%d6
    lea %pc@(CPUDECLDATA_21D2),%a0
    lea %a0@(0x0,%d1:w:4),%a0
    moveb %a0@,%d6
    movew %a2@(6),%d3
    cmpw %d6,%d3
    jbhi CPUDECLDATA_23D4_246
    movew %a2@(4),%d0
    addqw #1,%d0
    jbmi CPUDECLDATA_23D4_246
    movel %d3,%d4
    addqw #1,%d4
    btst #12,%d5
    jbeq CPUDECLDATA_23D4_178
    muluw #3,%d4
    jbra CPUDECLDATA_23D4_17A
CPUDECLDATA_23D4_178:   /* from here: aslw #2,%d4 */
    aslw #2,%d4
CPUDECLDATA_23D4_17A:   /* from here: subaw %d4,%sp */
    subaw %d4,%sp
    movel %a3,%d6
    moveal %a0,%a3
    moveal %sp,%a0
    moveal %a2@,%a1
    swap %d4
    movew %a2@(4),%d4
CPUDECLDATA_23D4_18A:   /* loop: move */
    movew %a1@+,%d0
    btst #12,%d5
    jbne CPUDECLDATA_23D4_1A6
    btst #11,%d5
    jbeq CPUDECLDATA_23D4_19C
    movew %d4,%d0
    addqw #1,%d4
CPUDECLDATA_23D4_19C:   /* from here: muluw %a3@(2),%d0 */
    muluw %a3@(2),%d0
    addb %a3@(1),%d0
    moveb %d0,%a0@+
CPUDECLDATA_23D4_1A6:   /* set %d0 */
    movew %a1@+,%d0
    movew %a1@+,%d1
    movew %a1@+,%d2
    tstw %d5
    jbpl CPUDECLDATA_23D4_1D0
    btst #10,%d5
    jbne CPUDECLDATA_23D4_1D0
    muluw #19660,%d0
    muluw #-26870,%d1
    muluw #7209,%d2
    addl %d1,%d0
    addl %d2,%d0
    bfextu %d0,0,%d7,%d0
    movew %d0,%d1
    movew %d0,%d2
    jbra CPUDECLDATA_23D4_1DC
CPUDECLDATA_23D4_1D0:   /* from here: bfextu %d0,16,%d7,%d0 */
    bfextu %d0,16,%d7,%d0
    bfextu %d1,16,%d7,%d1
    bfextu %d2,16,%d7,%d2
CPUDECLDATA_23D4_1DC:   /* test bit 13 of %d5 */
    btst #13,%d5
    jbeq CPUDECLDATA_23D4_1E8
    clrb %a0@+
    clrb %a0@+
    jbra CPUDECLDATA_23D4_1F0
CPUDECLDATA_23D4_1E8:   /* set %a0@+ */
    moveb %a4@(0x0,%d0:w),%a0@+
    moveb %a5@(0x0,%d1:w),%a0@+
CPUDECLDATA_23D4_1F0:   /* set %a0@+ */
    moveb %fp@(0x0,%d2:w),%a0@+
    dbf %d3,CPUDECLDATA_23D4_18A
    swap %d4
    moveal %d6,%a3
    movew %sr,%sp@-
    jbsr CPUDECLDATA_2BA6
    movew %a2@(6),%d3
    moveal %a3@(24),%a3
    lea %a3@(1),%a3
    lea %sp@(2),%a0
    btst #12,%d5
    jbne CPUDECLDATA_23D4_228
CPUDECLDATA_23D4_218:   /* loop: move */
    moveb %a0@+,%a3@(-1)
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    dbf %d3,CPUDECLDATA_23D4_218
    jbra CPUDECLDATA_23D4_23A
CPUDECLDATA_23D4_228:   /* set %d1 */
    movew %a2@(4),%d1
    moveb %d1,%a3@(-1)
CPUDECLDATA_23D4_230:   /* loop: move */
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    moveb %a0@+,%a3@
    dbf %d3,CPUDECLDATA_23D4_230
CPUDECLDATA_23D4_23A:   /* set %sr */
    movew %sp@+,%sr
    addaw %d4,%sp
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    jbra CPUDECLDATA_23D4
CPUDECLDATA_23D4_246:   /* restore registers */
    moveml %sp@+,%d4-%d7/%a1/%a4-%fp
    jbra CPUDECLDATA_23D0
    movel %a2@,%d0
    beqw CPUDECLDATA_23D4_246_B0
    moveal %d0,%a2
    tstw %a2@
    bnew CPUDECLDATA_23D0
    tstw %a2@(2)
    beqs CPUDECLDATA_23D4_246_3C
    cmpiw #32,%a2@(2)
    bnew CPUDECLDATA_23D0
    tstw %a2@(4)
    beqs CPUDECLDATA_23D4_246_3C
    movew %a2@(12),%d0
    cmpw %a3@(52),%d0
    beqs CPUDECLDATA_23D4_246_3C
    addqw #1,%d0
    bnew CPUDECLDATA_23D0
CPUDECLDATA_23D4_246_3C:
    moveal %a3@(12),%a0
    movew %a2@(4),%d0
    cmpw %a0@(4),%d0
    bnes CPUDECLDATA_23D4_246_60
    movew %a2@(6),%d0
    cmpw %a0@(6),%d0
    beqs CPUDECLDATA_23D4_246_8E
    bgts CPUDECLDATA_23D4_246_60
    moveal %a3@(16),%a0
    _DisposPtr
    clrl %a3@(16)
CPUDECLDATA_23D4_246_60:
    movew %a2@(8),%d0
    muluw %a2@(6),%d0
    addw %a2@(4),%d0
    addiw #12,%d0
    .short  0xA51E	| 4089C1AA _NewPtr (flags 0x0500)
    bnew CPUDECLDATA_23D0
    movel %a3@(16),%d0
    movel %a0,%a3@(12)
    tstl %d0
    beqs CPUDECLDATA_23D4_246_8E
    moveal %d0,%a0
    _DisposPtr
    moveal %a3@(12),%a0
    movel %a0,%a3@(16)
CPUDECLDATA_23D4_246_8E:
    movew %a2@(6),%d0
    movew %a2@(4),%d1
    movew %a2@(8),%d2
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    movel %a2@+,%a0@+
    muluw %d0,%d2
    addw %d1,%d2
    subqw #1,%d2
CPUDECLDATA_23D4_246_A6:
    moveb %a2@+,%d0
    moveb %d0,%a0@+
    dbf %d2,CPUDECLDATA_23D4_246_A6
    bras CPUDECLDATA_23D4_312_C
CPUDECLDATA_23D4_246_B0:
    moveal %a3@(12),%a0
    movew %a0@(4),%d0
    movew %a0@(6),%d2
    subqw #1,%d2
    movew %a0@(8),%d3
    subqw #1,%d3
    lea %a0@(12),%a0
    addaw %d0,%a0
CPUDECLDATA_23D4_310:   /* loop: move */
    movew %d3,%d0
CPUDECLDATA_23D4_312:   /* loop: move */
    moveb %d0,%a0@
    notb %a0@+
    dbf %d0,CPUDECLDATA_23D4_312
    dbf %d2,CPUDECLDATA_23D4_310
CPUDECLDATA_23D4_312_C:
    btst #10,%a3@(48)
    jbeq CPUDECLDATA_23D4_32A
    jbsr CPUDECLDATA_2C52
CPUDECLDATA_23D4_32A:   /* continue at CPUDECLDATA_23D4 */
    jbra CPUDECLDATA_23D4
    .short  0x322B, 0x0032, 0x6100, 0x0474, 0x6600, 0xFCC4, 0x302A, 0x0006	| 4089C222
    .short  0x6600, 0xFCBC, 0x6100, 0x04EC	| 4089C232
    btst #10,%a3@(48)
    jbeq CPUDECLDATA_23D4_352
    jbsr CPUDECLDATA_2C52
CPUDECLDATA_23D4_352:   /* continue at CPUDECLDATA_23D4 */
    jbra CPUDECLDATA_23D4
    btst #13,%a3@(48)
    jbeq CPUDECLDATA_23D4_362
    moveb #1,%a2@
CPUDECLDATA_23D4_362:   /* clear %d1 */
    moveq #0,%d1
    jbsr CPUDECLDATA_273E
    jbra CPUDECLDATA_23D4

CPUDECLDATA_273E:       /* loop: move */
    moveb %a2@,%d0
    bfins %d0,%a3@(48),%d1,1
    rts
    moveq #1,%d1
    jbsr CPUDECLDATA_273E
    jbne CPUDECLDATA_273E_1A
    jbsr CPUDECLDATA_277A
    jbne CPUDECLDATA_23D0
    jbra CPUDECLDATA_23D4
CPUDECLDATA_273E_1A:    /* call CPUDECLDATA_275E */
    jbsr CPUDECLDATA_275E
    jbra CPUDECLDATA_23D4

CPUDECLDATA_275E:       /* loop: move */
    movew %sr,%sp@-
    jbsr CPUDECLDATA_2BA6
    moveal %a3@(28),%a0
    moveb #64,%a0@(18)
    movew %sp@+,%sr
    clrw %d0
    moveal %a3@(8),%a0
    _SIntRemove
    rts

CPUDECLDATA_277A:       /* loop: movea */
    moveal %a3@(8),%a0
    lea %pc@(CPUDECLDATA_300C_26),%a2
    movew #6,%a0@(4)
    movel %a2,%a0@(8)
    movel %a3,%a0@(12)
    movew #14,%d0
    _SIntInstall
    jbne CPUDECLDATA_277A_34
    movel %a0,%sp@-
    moveal %a3@(28),%a0
    moveb #0xc0,%a0@(18)
    moveb #0x82,%a0@(19)
    moveal %sp@+,%a0
    cmpw %d0,%d0
CPUDECLDATA_277A_34:    /* return */
    rts
    btst #10,%a3@(48)
    beqw CPUDECLDATA_23D0
    braw CPUDECLDATA_23D4_D8_14
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0
    _SlotManager
    moveb %a2@,%a0@(50)
    clrl %a0@(24)
    orib #3,%a0@(27)
    moveq #11,%d0
    _SlotManager
    bnes CPUDECLDATA_277A_34_78
    movew %a0@(40),%d0
    cmpiw #3,%d0
    bnes CPUDECLDATA_277A_34_78
    movew %a0@(42),%d0
    cmpiw #1,%d0
    bnes CPUDECLDATA_277A_34_78
    movew %a0@(44),%d0
    cmpiw #1,%d0
    bnes CPUDECLDATA_277A_34_78
    movew %a0@(46),%d0
    cmpiw #32,%d0
    bnes CPUDECLDATA_277A_34_78
    moveb %a2@,%sp@(3)
    movel %sp,%a0@(4)
    moveq #18,%d0
    _SlotManager
    lea %sp@(64),%sp
    braw CPUDECLDATA_23D4
CPUDECLDATA_277A_34_78:
    lea %sp@(64),%sp
    braw CPUDECLDATA_23D0
CPUDECLDATA_277A_34_80:
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0
    _SlotManager
    moveb %a2@,%d1
    cmpib #7,%d1
    beqs CPUDECLDATA_277A_34_E0
    cmpib #63,%d1
    beqs CPUDECLDATA_277A_34_E0
    lea %pc@(CPUDECLDATA_21E6_14),%a1	| 4089C374
    movew %a1@+,%d0
CPUDECLDATA_277A_34_AC:
    moveb %a1@+,%d1
    cmpb %a2@,%d1
    beqs CPUDECLDATA_277A_34_B8
    dbf %d0,CPUDECLDATA_277A_34_AC
    bras CPUDECLDATA_277A_34_F4
CPUDECLDATA_277A_34_B8:
    tstb %a2@(1)
    beqs CPUDECLDATA_277A_34_D4
    cmpib #23,%d1
    bnes CPUDECLDATA_277A_34_CA
    moveb #8,%d1
    bras CPUDECLDATA_277A_34_D4
CPUDECLDATA_277A_34_CA:
    cmpib #45,%d1
    bnes CPUDECLDATA_277A_34_D4
    moveb #10,%d1
CPUDECLDATA_277A_34_D4:
    moveb %d1,%sp@(7)
    orib #64,%sp@(7)
    bras CPUDECLDATA_277A_34_E4
CPUDECLDATA_277A_34_E0:
    clrb %sp@(7)
CPUDECLDATA_277A_34_E4:
    movel %sp,%a0@(4)
    moveq #18,%d0
    _SlotManager
    lea %sp@(64),%sp
    braw CPUDECLDATA_23D4
CPUDECLDATA_277A_34_F4:
    lea %sp@(64),%sp
    braw CPUDECLDATA_23D0
CPUDECLDATA_277A_34_FC:
    cmpiw #8,%a3@(52)
    beqw CPUDECLDATA_23D0
    moveml %d1/%a0-%a1,%sp@-
    movew %a2@,%d1
    bnew CPUDECLDATA_277A_34_174
    tstb %a3@(59)
    beqw CPUDECLDATA_277A_1F2
    jbsr CPUDECLDATA_300C
    jbsr CPUDECLDATA_2CE2
    moveal %a3@(32),%a1
    lea %a3@(60),%a0
    moveb %a0@+,%a1@(64)
    moveb %a0@+,%a1@(68)
    moveb %a0@+,%a1@(72)
    moveb %a0@+,%a1@(76)
    moveb %a0@+,%a1@(80)
    movew %a0@+,%a1@(84)
    movew %a0@+,%a1@(88)
    movew %a0@+,%a1@(92)
    movew %a0@+,%a1@(96)
    moveb %a0@+,%a1@(12)
    moveb %a0@+,%a1@(16)
    moveal %a3@(28),%a1
    moveb #0xc0,%a1@(18)
    moveb #0x82,%a1@(19)
    jbsr CPUDECLDATA_2F92
    jbsr CPUDECLDATA_277A
    movew #-1,%a3@(50)
    jbra CPUDECLDATA_277A_1F2
CPUDECLDATA_277A_34_174:
    tstb %a3@(59)	| 4089C442
    bnes CPUDECLDATA_277A_1F2
    jbsr CPUDECLDATA_2F6A
    moveal %a3@(32),%a1
    lea %a3@(60),%a0
    moveb %a1@(64),%a0@+
    moveb %a1@(68),%a0@+
    moveb %a1@(72),%a0@+
    moveb %a1@(76),%a0@+
    moveb %a1@(80),%a0@+
    movew %a1@(84),%a0@+
    movew %a1@(88),%a0@+
    movew %a1@(92),%a0@+
    movew %a1@(96),%a0@+
    moveb %a1@(12),%a0@+
    moveb %a1@(16),%a0@+
    jbsr CPUDECLDATA_275E
    jbsr CPUDECLDATA_2F44
    jbsr CPUDECLDATA_2FE2
CPUDECLDATA_277A_1F2:   /* restore registers */
    moveml %sp@+,%d1/%a0-%a1
    jbra CPUDECLDATA_23D4
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    bsrw CPUDECLDATA_275E
    bsrw CPUDECLDATA_2F44
    moveal %a3@(8),%a0
    _DisposPtr
    moveal %a3@(16),%a0
    _DisposPtr
    moveal %a3@(20),%a0
    _DisposPtr
    moveal %a1@(20),%a0
    _DisposHandle
    moveq #0,%d0
    rts

CPUDECLDATA_29A2:       /* save registers */
    moveml %a0-%a1,%sp@-
    moveal %a0@(28),%a2
    moveal %a1@(20),%a3
    movel %a3@,%d0
    _StripAddress
    moveal %d0,%a3
    movew %a0@(26),%d0
    cmpiw #131,%d0
    jbeq CPUDECLDATA_2B12
    cmpiw #9,%d0
    jbhi CPUDECLDATA_29E2
    movew %pc@(CPUDECLDATA_29CE,%d0:w:2),%d0
    jmp %pc@(CPUDECLDATA_29CE,%d0:w)
CPUDECLDATA_29CE:       /* (data) */
    .short  CPUDECLDATA_29E2-CPUDECLDATA_29CE	| 4089C4EE
    .short  CPUDECLDATA_29E2-CPUDECLDATA_29CE	| 4089C4F0
    .short  CPUDECLDATA_29F0-CPUDECLDATA_29CE	| 4089C4F2
    .short  CPUDECLDATA_2A00-CPUDECLDATA_29CE	| 4089C4F4
    .short  CPUDECLDATA_2AAC-CPUDECLDATA_29CE	| 4089C4F6
    .short  CPUDECLDATA_2AC2-CPUDECLDATA_29CE	| 4089C4F8
    .short  CPUDECLDATA_2AD4-CPUDECLDATA_29CE	| 4089C4FA
    .short  CPUDECLDATA_2AE2-CPUDECLDATA_29CE	| 4089C4FC
    .short  CPUDECLDATA_2AE6-CPUDECLDATA_29CE	| 4089C4FE
    .short  CPUDECLDATA_2AEE-CPUDECLDATA_29CE	| 4089C500
CPUDECLDATA_29E2:       /* result -18 */
    moveq #-18,%d0
    jbra CPUDECLDATA_29E8
CPUDECLDATA_29E6:       /* loop: moveq */
    moveq #0,%d0
CPUDECLDATA_29E8:       /* restore registers */
    moveml %sp@+,%a0-%a1
    jbra CPUDECLDATA_2B6C
CPUDECLDATA_29F0:       /* set %a2@ */
    movew %a3@(50),%a2@
    clrw %a2@(6)
    movel %a3@(4),%a2@(8)
    jbra CPUDECLDATA_29E6
CPUDECLDATA_2A00:       /* save registers */
    moveml %d4-%d6,%sp@-
    tstl %sp@-
    movel %a2@,%d0
    jbeq CPUDECLDATA_2AA2
    _StripAddress
    movel %d0,%sp@
    movew %a3@(50),%d1
    subiw #128,%d1
    moveq #0,%d3
    lea %pc@(CPUDECLDATA_21D2),%a0
    lea %a0@(0x0,%d1:w:4),%a0
    moveb %a0@,%d3
    movew %a2@(6),%d4
    bmiw CPUDECLDATA_2AA2
    cmpw %d3,%d4
    bhiw CPUDECLDATA_2AA2
    movew %d4,%d2
    moveb %a0@(1),%d4	| 4089C554
    movew %a0@(2),%d5
    movew %d2,%d6
    cmpiw #-1,%a2@(4)
    jbeq CPUDECLDATA_2A58
    movew %d2,%d1
    addw %a2@(4),%d2
    moveal %sp@,%a0
CPUDECLDATA_2A4E:       /* loop: move */
    movew %d2,%a0@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,CPUDECLDATA_2A4E
CPUDECLDATA_2A58:       /* set %a0 */
    moveal %sp@+,%a0
    moveal %a3@(24),%a2
    addqw #1,%a2
    movew %sr,%sp@-
    jbsr CPUDECLDATA_2BA6
CPUDECLDATA_2A66:       /* loop: move */
    movew %a0@,%d1
    cmpw %d3,%d1
    jbhi CPUDECLDATA_2A92
    muluw %d5,%d1
    addb %d4,%d1
    moveb %d1,%a2@(-1)
    moveb %a2@,%d1
    moveb %d1,%a0@(2)
    moveb %d1,%a0@(3)
    moveb %a2@,%d1
    moveb %d1,%a0@(4)
    moveb %d1,%a0@(5)
    moveb %a2@,%d1
    moveb %d1,%a0@(6)
    moveb %d1,%a0@(7)
CPUDECLDATA_2A92:       /* add 8 to %a0 */
    addqw #8,%a0
    dbf %d6,CPUDECLDATA_2A66
    movew %sp@+,%sr
    moveml %sp@+,%d4-%d6
    jbra CPUDECLDATA_29E6
CPUDECLDATA_2AA2:       /* test %sp@+ */
    tstl %sp@+
    moveml %sp@+,%d4-%d6
    jbra CPUDECLDATA_29E2
CPUDECLDATA_2AAC:       /* set %d1 */
    movew %a2@,%d1
    movew %d1,%d2
    jbsr CPUDECLDATA_2B7C
    jbne CPUDECLDATA_29E2
    movew #1,%a2@(6)
    jbra CPUDECLDATA_29E6
CPUDECLDATA_2AC2:       /* test %a2@(6) */
    tstw %a2@(6)
    jbne CPUDECLDATA_29E2
    movel %a3@(4),%a2@(8)
    jbra CPUDECLDATA_29E6
CPUDECLDATA_2AD4:       /* clear %d1 */
    moveq #0,%d1
CPUDECLDATA_2AD6:       /* loop: bfextu */
    bfextu %a3@(48),%d1,1,%d0
    moveb %d0,%a2@
    jbra CPUDECLDATA_29E6
CPUDECLDATA_2AE2:       /* set %d1 */
    moveq #1,%d1
    jbra CPUDECLDATA_2AD6
CPUDECLDATA_2AE6:       /* set %a2@ */
    movel %a3@(12),%a2@
    jbra CPUDECLDATA_29E6
CPUDECLDATA_2AEE:       /* from here: subaw #56,%sp */
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    moveb %sp@(3),%a2@
    lea %sp@(64),%sp
    jbra CPUDECLDATA_29E6
CPUDECLDATA_2B12:       /* from here: subaw #56,%sp */
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    clrb %a0@(51)
    subqw #8,%sp
    movel %sp,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    .short  0x422A	| 4089C64A
    .short  0x0001, 0x102F	| orib #47,%d1
    .short  0x0007, 0x0200	| orib #0,%d7
    oriw #26118,%d0
    moveb #7,%a2@
    jbra CPUDECLDATA_2B64
    moveb %sp@(7),%d0
    andib #63,%d0
    cmpib #8,%d0
    bnes CPUDECLDATA_2B12_40
    moveb #23,%d0
    bras CPUDECLDATA_2B12_4A
CPUDECLDATA_2B12_40:
    cmpib #10,%d0
    bnes CPUDECLDATA_2B12_50
    moveb #45,%d0
CPUDECLDATA_2B12_4A:
    moveb #1,%a2@(1)
CPUDECLDATA_2B12_50:
    moveb %d0,%a2@
CPUDECLDATA_2B64:       /* address %sp@(64) */
    lea %sp@(64),%sp
    jbra CPUDECLDATA_29E6

CPUDECLDATA_2B6C:       /* test bit 9 of %a0@(6) */
    btst #9,%a0@(6)
    jbeq CPUDECLDATA_2B6C_A
    rts
CPUDECLDATA_2B6C_A:     /* set %sp@- */
    movel JIODone,%sp@-
    rts

CPUDECLDATA_2B7C:       /* save registers */
    moveml %d0/%a0,%sp@-
    subiw #128,%d1
    jblt CPUDECLDATA_2B7C_24
    moveal %a3@(20),%a0
    lea %a0@(19),%a0
    moveb %a3@(55),%d0
    moveb %a0@(0x0,%d0:w),%d0
    subiw #128,%d0
    cmpw %d0,%d1
    jbgt CPUDECLDATA_2B7C_24
    cmpw %d1,%d1
CPUDECLDATA_2B7C_24:    /* restore registers, return */
    moveml %sp@+,%d0/%a0
    rts

CPUDECLDATA_2BA6:       /* loop: move */
    movel %a0,%sp@-
    movel %d0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge CPUDECLDATA_2BA6_16
    oriw #512,%sr
    andiw #-1281,%sr
CPUDECLDATA_2BA6_16:    /* test %sp@+ */
    tstw %sp@+
    moveal %a3@(32),%a0
    clrb %a0@(20)
    moveal %a3@(28),%a0
CPUDECLDATA_2BA6_24:    /* loop: btst */
    btst #6,%a0@(2)
    jbne CPUDECLDATA_2BA6_24
    movel %sp@+,%d0
    moveal %sp@+,%a0
    rts

CPUDECLDATA_2BD8:       /* save registers */
    moveml %d0-%d2/%a0,%sp@-
    movew %sr,%sp@-
    jbsr CPUDECLDATA_2BA6
    moveal %a3@(32),%a0
    moveb %d1,%a0@(8)
    jbsr CPUDECLDATA_2BA6
    moveal %a3@(24),%a0
    moveb %a0@(2),%d0
    andib #0xf8,%d0
    orb %d1,%d0
    moveb %d0,%a0@(2)
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d2/%a0
    rts

CPUDECLDATA_2C04:       /* save registers */
    moveml %d0-%d6/%a1-%a2,%sp@-
    moveal %a3@(4),%a2
    moveal %a3@(20),%a1
    movew %a1@(22),%d4
    lea %a1@(24),%a1
    movew %a1@(0x0,%d1:w:2),%d3
    movew %d3,%d5
    andiw #3,%d5
    lsrw #2,%d3
    lea %pc@(CPUDECLDATA_21E6),%a1
    movel %a1@(0x0,%d1:w:4),%d2
    moveq #1,%d0
    _SwapMMUMode
CPUDECLDATA_2C04_2C:    /* loop: move */
    movel %d3,%d1
    movel %d5,%d6
    jbra CPUDECLDATA_2C04_34
CPUDECLDATA_2C04_32:    /* loop: move */
    movel %d2,%a2@+
CPUDECLDATA_2C04_34:    /* count down */
    dbf %d1,CPUDECLDATA_2C04_32
    jbra CPUDECLDATA_2C04_3C
CPUDECLDATA_2C04_3A:    /* loop: move */
    moveb %d2,%a2@+
CPUDECLDATA_2C04_3C:    /* set up and call _SwapMMUMode */
    dbf %d6,CPUDECLDATA_2C04_3A
    notl %d2
    dbf %d4,CPUDECLDATA_2C04_2C
    _SwapMMUMode
    moveml %sp@+,%d0-%d6/%a1-%a2
    rts

CPUDECLDATA_2C52:       /* save registers */
    moveml %d0-%d2/%a0/%a4-%fp,%sp@-
    moveal %a3@(12),%a0
    movew %a0@(4),%d0
    lea %a0@(12),%a4
    addaw %d0,%a4
    moveal %a4,%a5
    moveal %a4,%fp
    cmpiw #1,%a0@(6)
    jbeq CPUDECLDATA_2C52_30
    movew %a0@(10),%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %a0@(8),%d1
    addaw %d1,%a5
    addaw %d1,%fp
    addaw %d1,%fp
CPUDECLDATA_2C52_30:    /* set %d2 */
    movew %a0@(8),%d2
    subqw #1,%d2
    moveal %a3@(24),%a0
    addqw #1,%a0
    clrb %a0@(-1)
    movew #31,%d2
    movew %sr,%sp@-
    jbsr CPUDECLDATA_2BA6
    moveq #0,%d0
CPUDECLDATA_2C52_4C:    /* loop: move */
    moveb %d0,%d1
    bsrw CPUDECLDATA_2CBE
    moveb %a4@(0x0,%d1:w),%a0@
    moveb %a5@(0x0,%d1:w),%a0@
    moveb %fp@(0x0,%d1:w),%a0@
    addqw #1,%d0
    dbf %d2,CPUDECLDATA_2C52_4C
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d2/%a0/%a4-%fp
    rts

CPUDECLDATA_2CBE:       /* set %sp@- */
    movel %d0,%sp@-
    moveq #0,%d0
    movew %d1,%d0
    lslw #3,%d1
    lsrw #2,%d0
    orw %d0,%d1
    movel %sp@+,%d0
    rts

CPUDECLDATA_2CCE:       /* set up and call _DebugUtil (loop) */
    moveal %sp@+,%a1
    moveq #8,%d0
    _DebugUtil
    cmpiw #-50,%d0
    jbne CPUDECLDATA_2CCE_E
    movew %sr,%d0
CPUDECLDATA_2CCE_E:     /* from here: andiw #-4097,%sr */
    andiw #-4097,%sr
    jmp %a1@

CPUDECLDATA_2CE2:       /* from here: linkw %fp,#-60 */
    linkw %fp,#-60
    moveml %d0-%a5,%sp@-
    moveal PmgrBase,%a1
    bset #5,%a1@(296)
    jbne CPUDECLDATA_2CE2_FA
    moveal %a3@(36),%a1
    bclr #1,%a1@
    nop
    nop
    moveal %a3@(28),%a2
    moveal %a3@(32),%a4
    moveb #1,%a2@(33)
    moveb #64,%a2@(18)
    clrb %a4@(16)
    lea %pc@(CPUDECLDATA_2E72),%a1
    movew #16,%d0
    muluw %a3@(52),%d0
    addal %d0,%a1
    movel %a1,%fp@(-60)
    addql #8,%a1
    moveb %a1@(2),%d7
    moveb %a1@,%d5
    movew %a1@,%d3
    lea %fp@(-56),%a0
    moveb #14,%a0@(49)
    clrb %a0@(51)
    moveb #1,%a0@(50)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    moveb #126,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    moveb %d5,%a0@(50)
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    moveal %a0@,%a1
    bset #5,%a4@(112)
    .short  0x08AC	| 4089C88A
    orib #112,%d5
    bsrw CPUDECLDATA_2DE8
    moveb #65,%a4@(16)
    moveb %a1@+,%a4@(64)
    moveb %a1@+,%a4@(68)
    moveb %a1@+,%a4@(72)
    moveb %a1@+,%a4@(76)
    moveb %a1@+,%a4@(80)
    movew %a1@+,%a4@(84)
    movew %a1@+,%a4@(88)
    movew %a1@+,%a4@(92)
    movew %a1@+,%a4@(96)
    moveal %a3@(24),%a2
    moveb #8,%a2@(2)
    addqw #1,%a2
    moveal %fp@(-60),%a5
    moveb #127,%a2@(-1)
    moveb %a5@(1),%a2@
    moveb %a5@(3),%a2@
    moveb %a5@(5),%a2@
    moveb #0xff,%a2@(-1)
    moveb %a5@,%a2@
    moveb %a5@(2),%a2@
    moveb %a5@(4),%a2@
    moveb %a4@(16),%d0
    orib #0xbc,%d0
    moveb %d0,%a4@(16)
CPUDECLDATA_2CE2_FA:    /* clear %a3@(59) */
    clrb %a3@(59)
    moveml %sp@+,%d0-%a5
    unlk %fp
    rts

CPUDECLDATA_2DE8:       /* save registers */
    moveml %d0-%d3/%a0/%a3,%sp@-
    moveal VIA,%a0
    moveal %a3@(28),%a3
    movew #7685,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_2E34
    movel %a1@+,%d0
    movew %a1@+,%d1
    jbne CPUDECLDATA_2DE8_30
    movew #7684,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_2E34
    bsrw CPUDECLDATA_2E64
    movew #7684,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_2E34
    jbra CPUDECLDATA_2DE8_46
CPUDECLDATA_2DE8_30:    /* call CPUDECLDATA_2E34 */
    jbsr CPUDECLDATA_2E34
    movew #7684,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_2E34
    bsrw CPUDECLDATA_2E64
    movew #7680,%d0
    moveq #13,%d1
    jbsr CPUDECLDATA_2E34
CPUDECLDATA_2DE8_46:    /* restore registers, return */
    moveml %sp@+,%d0-%d3/%a0/%a3
    rts

CPUDECLDATA_2E34:       /* set %sp@- */
    movew %sr,%sp@-
    oriw #1792,%sr
    roll #6,%d0
CPUDECLDATA_2E34_8:     /* loop: move */
    movel %d0,%d3
    andib #64,%d3
    moveb %a3@(16),%d2
    andib #1,%d2
    orb %d3,%d2
    moveb %d2,%a3@(16)
    orib #32,%d2
    moveb %d2,%a3@(16)
    rorl #1,%d0
    dbf %d1,CPUDECLDATA_2E34_8
    nop
    movew %sp@+,%sr
    rts

CPUDECLDATA_2E64:       /* set %d0 */
    movew TimeVIADB,%d0
    lslw #3,%d0
CPUDECLDATA_2E64_6:     /* loop: tst */
    tstb %a0@
    dbf %d0,CPUDECLDATA_2E64_6
    rts
CPUDECLDATA_2E72:       /* (data) */
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4089C992
    .long   0x00000000, 0x000000FF, 0x00008000, 0x82008100	| 4089C9A0
    .long   0x830005FF, 0x05FF05FF, 0x00008284, 0x83008385	| 4089C9B0
    .long   0x84000000, 0x00000000, 0x00000000, 0x00000000	| 4089C9C0
    .long   0x000000FF, 0x00FF00FF, 0x00009091, 0x83009092	| 4089C9D0
    .long   0x840000FF, 0x00FF00FF, 0x00008600, 0x82008700	| 4089C9E0
    .long   0x830000FF, 0x00FF00FF, 0x00008800, 0x83008900	| 4089C9F0
    .long   0x84000000, 0x00000000, 0x00000000, 0x00000000	| 4089CA00
    .long   0x000000FF, 0x00FF00FF, 0x00008A8E, 0x83008B8F	| 4089CA10
    .long   0x840000FF, 0x00FF00FF, 0x00009395, 0x83009496	| 4089CA20
    .long   0x840000FF, 0x00FF00FF, 0x00008C00, 0x83008D00	| 4089CA30
    .long   0x84000000, 0x00000000, 0x00000000, 0x00000000	| 4089CA40
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4089CA50
    .long   0x00000000	| 4089CA60

CPUDECLDATA_2F44:       /* set %sp@- */
    movel %a1,%sp@-
    moveal PmgrBase,%a1
    bclr #5,%a1@(296)
    moveb #0xff,%a3@(59)
    moveal %a3@(28),%a1
    clrb %a1@(33)
    moveal %a3@(36),%a1
    bset #1,%a1@
    moveal %sp@+,%a1
    rts

CPUDECLDATA_2F6A:       /* call CPUDECLDATA_2CCE */
    jbsr CPUDECLDATA_2CCE
    movew %d0,%sp@-
    oriw #1792,%sr
    movec %vbr,%a0
    movel %a0@(8),%a3@(44)
    lea %pc@(CPUDECLDATA_2FDE),%a1
    movel %a0@(8),%a1@
    lea %pc@(CPUDECLDATA_2F92_18),%a1
    movel %a1,%a0@(8)
    movew %sp@+,%sr
    rts

CPUDECLDATA_2F92:       /* call CPUDECLDATA_2CCE */
    jbsr CPUDECLDATA_2CCE
    movew %d0,%sp@-
    oriw #1792,%sr
    movec %vbr,%a0
    movel %a3@(44),%a0@(8)
    movew %sp@+,%sr
    rts
CPUDECLDATA_2F92_18:    /* set %sp@- */
    movel %d0,%sp@-
    movew %sp@(14),%d0
    btst #8,%d0
    jbeq CPUDECLDATA_2F92_44
    moveb %sp@(20),%d0
    cmpib #0xff,%d0
    jbeq CPUDECLDATA_2F92_44
    cmpib #0xfe,%d0
    jbcs CPUDECLDATA_2F92_44
    movew %sp@(14),%d0
    andiw #-12545,%d0
    movew %d0,%sp@(14)
    movel %sp@+,%d0
    rte
CPUDECLDATA_2F92_44:    /* set %d0 */
    movel %sp@+,%d0
    movel %pc@(CPUDECLDATA_2FDE),%sp@-
    rts
CPUDECLDATA_2FDE:       /* (data) */
    orib #1,%d0	| 4089CAFE

CPUDECLDATA_2FE2:       /* address %pc@(CPUDECLDATA_300C_8) */
    lea %pc@(CPUDECLDATA_300C_8),%a0
    movel %a0,%a3@(96)
    lea %a3@(90),%a0
    movel #1700881505,%a0@
    .short  0xA458	| 4089CB14 _InsTime (flags 0x0400)
    movel %a1,%sp@-
    lea %a3@(90),%a0
    movel #-16626,%d0
    moveal 0x568,%a1
    jsr %a1@
    moveal %sp@+,%a1
    rts

CPUDECLDATA_300C:       /* set up and call _RmvTime */
    lea %a3@(90),%a0
    _RmvTime
    rts
CPUDECLDATA_300C_8:     /* set %sp@- */
    movel %a1,%sp@-
    movew #14,%d0
    moveal JVBLTask,%a0
    jsr %a0@
    moveal %sp@+,%a1
    moveal %a1,%a0
    movel #-16626,%d0
    moveal 0x568,%a1
    jsr %a1@
    rts
CPUDECLDATA_300C_26:    /* address 0xfee00000 */
    lea 0xfee00000,%a0
    btst #1,%a0@(3)
    jbne CPUDECLDATA_300C_38
CPUDECLDATA_300C_34:    /* result 0 */
    moveq #0,%d0
    rts
CPUDECLDATA_300C_38:    /* test bit 6 of %a0@(2) */
    btst #6,%a0@(2)
    jbne CPUDECLDATA_300C_34
    lea 0xfeefe000,%a0
    clrb %a0@(20)
    movew #14,%d0
    moveal JVBLTask,%a0
    jsr %a0@
    moveq #1,%d0
    rts
CPUDECLDATA_3064:       /* (data) */
    .long   0x0000001A, 0x02020000, 0x00000004	| 4089CB84

CPUDECLDATA_3070:       /* from here: linkw %fp,#-82 */
    linkw %fp,#-82
    movew #1,%a0@(2)
    unlk %fp
    rts
    .fill   0x344F, 1, 0x00
    .byte   0xFF, 0x9B, 0x34	| 4089FFED
    .long   0x00000000, 0x00000000, 0x01015A93, 0x2BC7000F	| 4089FFF0
