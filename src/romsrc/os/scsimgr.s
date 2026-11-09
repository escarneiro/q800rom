/*
 os/scsimgr.s - SCSI boot loading and SCSI Manager
 From SCSIBOOTS (0x408071F0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the SCSI Manager chapters of Inside
 Macintosh), not taken from Apple.

 What is here:
 - SCSIBOOTS: loads the disk drivers of SCSI devices at start-up (any machine).
 - The original SCSI Manager (_SCSIDispatch, A815; SCSIMGR): 14 selectors, from
   SCSIGet to SCSIMsgOut, which a disk driver uses to arbitrate, select, send a
   command, move the data (described by a transfer instruction block, TIB) and read
   the status and message bytes. The routines here drive the NCR 5380.
 - An asynchronous SCSI Manager (SCSINEW: execute I/O, kill I/O, bus inquiry):
   requests are queued and run by a deferred task (SCSIDT) driven by the chip's
   interrupts, with disconnect/reselect, timeouts and completion routines.
 - SCSIINIT, which sets all of it up.

 Which chip: SCSIINIT builds everything for the 5380, then INITSCSIMGRPATCH2 installs
 the 53C96 code on machines that have one (AddrMapFlags bit 24). The Quadra 800 has
 a 53C96 and no 5380 (AddrMapFlags 0x0580183F), so SCSIINIT96BIOS (os/scsibios.s)
 replaces the 14 selector routines and the chip-level vectors (transfer, reset, bus
 error, cycle phase, read/write/compare routines); machines with AddrMapFlags bit 21
 get the other 53C96 variant, SCSIINIT96 (os/scsi96.s). The 5380 routines below
 (ARBITRATE, SELECT, DATAIO, SCSIINTHND...) are not used on the Quadra 800. In QEMU
 execution traces of the Quadra 800 booting Mac OS 8.1 (analysis/executed_pcs.txt),
 only SCSIBOOTS/SCSILOAD, TSTRETRY, RDDONE, the dispatcher, SCSIINIT, SCSISETFLAGS and
 DISENABLE run in this file.

 SCSI globals (SCSIGlobals = 0xC0C, a4; 1028 bytes): +0 the 14 selector routines,
 +56/+60 free list of private blocks, +64 the chip (from 0xC00, SCSIBase; the source
 calls it ToolDispTable), +68 its pseudo-DMA address (SCSIDMA), +72 SCSIHsk, +80/+84
 request queue head/tail, +88 the active request, +92 the next timeout (Ticks),
 +96 our ID as a bit, +97 old interface busy, +98 select timeout (ms), +100 hardware
 flags (SCSISETFLAGS; +103 is its low byte), +104 a request waiting, +116 busy LUNs
 per ID, +124 IDs with disconnected requests, +125 state (bit 0 request ended, bit 7
 deferred task queued), +132..+512 the 96 vectors (phase routines by the 5380's phase
 bits, transfer routines, message handlers, internal routines, the asynchronous
 selectors at +484), +516 transfer routine offsets, +588 the deferred task, +600
 events for it (bit n = event n, see MESSAGE), +608 the timeout Time Manager task,
 +676 the old interface's own request, +836 the private blocks. Calls through the
 vectors are named in the source ("vector +N: ROUTINE; 53C96 BIOS: ...").

 NCR 5380 registers (a3, 16 bytes apart): +0 data, +16 initiator command (ICR: 7 RST,
 6 arbitration in progress, 5 lost arbitration, 4 ACK, 3 BSY, 2 SEL, 1 ATN, 0 drive
 the data bus), +32 mode (0 arbitrate, 1 DMA), +48 target command (the expected
 phase: 2 MSG, 1 C/D, 0 I/O), +64 current bus status (CSR: 6 BSY, 5 REQ, 4 MSG, 3 C/D,
 2 I/O, 1 SEL) / select enable, +80 bus and status (BSR: 6 DMA request, 4 interrupt,
 3 phase match, 0 ACK), +112 start initiator receive.

 Results of the old interface: 2 scCommErr (timeout), 3 scArbNBErr, 4 scBadParmsErr,
 5 scPhaseErr, 6 scCompareErr, 7 scMgrBusyErr, 10 scComplPhaseErr. The asynchronous
 manager's: -470 bad request, -471 data overrun, -472 wrong direction, -473 DMA error,
 -474 selection timeout, -475 request timeout, -476 bus reset.
*/

/*
 SCSIBOOTS / SCSILOAD (d0 = mask of SCSI IDs, d3 high word = the driver type wanted):
 load the disk drivers of the SCSI devices in the mask, ID 7 down to 0, skipping those
 already loaded (SCSIDrvrs). Only if the machine has SCSI (HWCfgFlags bit 15,
 hwCbSCSI). For each ID (SCSILOAD_34): read block 0, the driver descriptor map
 ('ER': block size +2, driver count +16, then 8-byte entries: start block, block
 count, type); take the entry of our type, read the driver into a system pointer;
 for type 1 with an Apple partition map ('PM' in block 1), the map must have an
 "Apple_Driver" partition named "Maci..." at the driver's start block whose boot
 checksum (pmBootCksum) matches the code (RDDONE_C), and an "Apple_HFS" partition;
 then the driver is called (a0 = the partition map entry, or block 1) to install
 itself. Out: d0 = the IDs that did not load (Z set if all did).
*/
SCSIBOOTS:
SCSILOAD:               /* no SCSI on this machine: none loaded */
    btst #7,HWCfgFlags
    jbne SCSIBOOTS_C
    moveq #0,%d0
    rts
SCSIBOOTS_C:            /* the mask, on the stack */
    moveml %d1-%fp,%sp@-
    moveb %d0,%sp@-
    moveq #7,%d5	/* d5 = SCSI ID */
SCSIBOOTS_14:           /* next ID (7 down to 0): in the mask, driver not loaded yet? */
    btst %d5,%sp@
    jbeq SCSIBOOTS_24
    btst %d5,SCSIDrvrs
    jbne SCSIBOOTS_24
    jbsr SCSILOAD_34
    jbeq SCSIBOOTS_24
    bclr %d5,%sp@
SCSIBOOTS_24:           /* next ID */
    dbf %d5,SCSIBOOTS_14
    moveq #0,%d0
    moveb %sp@+,%d0
    moveml %sp@+,%d1-%fp
    tstw %d0
    rts

SCSILOAD_34:            /* load the driver of ID d5: a 512-byte buffer and 18 bytes of locals (fp-18: block number, -14: map size, -10: type wanted, -8: driver blocks, -4: driver start) */
    movel %d3,%sp@-
    linkw %fp,#-530
    moveal %sp,%a2
    swap %d3
    moveq #0,%d0
    moveb %d3,%d0
    movew %d0,%fp@(-10)	/* the driver type wanted */
    moveq #0,%d3	/* block 0: the driver descriptor map */
    moveq #1,%d2
    movew #512,%d4
    jbsr SCSILOAD_19A
    jbne SCSIBOOTS_DE
    cmpiw #17746,%sp@	/* sbSig 'ER' */
    jbne SCSIBOOTS_E6
    movew %sp@(2),%d4	/* sbBlkSize */
    movew %sp@(16),%d0	/* sbDrvrCount */
    jbeq SCSIBOOTS_E6
    lea %sp@(18),%a0
    movel %sp@(12),%d7
SCSIBOOTS_70:           /* find the descriptor entry of our type (ddType, +6) */
    movew %fp@(-10),%d1
    cmpw %a0@(6),%d1
    jbeq SCSIBOOTS_82
    addql #8,%a0
    subqw #1,%d0
    jbne SCSIBOOTS_70
    jbra SCSIBOOTS_E6
SCSIBOOTS_82:           /* found: mark the ID loaded, read ddSize blocks from ddBlock into a new system pointer */
    bset %d5,SCSIDrvrs
    movel %a0@,%d3	/* ddBlock */
    movel %d3,%fp@(-4)
    moveq #0,%d2
    movew %a0@(4),%d2	/* ddSize (blocks) */
    movel %d2,%fp@(-8)
    movel %d4,%d0
    muluw %d2,%d0
    .short  0xA51E	| 4080728A _NewPtr (flags 0x0500)
    jbne SCSIBOOTS_E6
    moveal %a0,%a3
    moveal %a0,%a2
    jbsr SCSILOAD_19A
    jbne SCSIBOOTS_E2
    moveq #1,%d3	/* then block 1 */
    movel %d3,%fp@(-18)
    moveq #1,%d2
    movew #512,%d4
    moveal %sp,%a2
    jbsr SCSILOAD_19A
    jbne SCSIBOOTS_E2
    cmpiw #1,%fp@(-10)	/* type 1 (Macintosh) only */
    jbne SCSIBOOTS_DA
    cmpiw #21587,%a2@	/* 'TS': the old partition format: no check */
    jbeq SCSIBOOTS_DA
    cmpiw #20557,%a2@	/* 'PM': Apple partition map */
    jbne SCSIBOOTS_DA
    movel %a2@(4),%d0	/* pmMapBlkCnt */
    movel %d0,%fp@(-14)
    jbra SCSIBOOTS_F0
SCSIBOOTS_DA:           /* call the driver (a0 = the partition map entry or block 1); it installs itself */
    moveal %a2,%a0
    jsr %a3@
SCSIBOOTS_DE:           /* done (or block 0 unreadable): 0 */
    moveq #0,%d0
    jbra SCSIBOOTS_E8
SCSIBOOTS_E2:           /* refused or unreadable: free the driver */
    moveal %a3,%a0
    _DisposPtr
SCSIBOOTS_E6:           /* not loaded: -1 */
    moveq #-1,%d0
SCSIBOOTS_E8:           /* return (Z set if loaded) */
    unlk %fp
    movel %sp@+,%d3
    tstw %d0
    rts
SCSIBOOTS_F0:           /* partition map entry: "Apple_Driver" (pmParType +48), named "Maci..." (pmPartName +16), starting at the driver's block (pmPyPartStart +8)? */
    cmpil #1097887852,%a2@(48)	/* 'Appl' */
    jbne SCSIBOOTS_134
    cmpil #1700742258,%a2@(52)	/* 'e_Dr' */
    jbne SCSIBOOTS_134
    cmpil #1769366898,%a2@(56)	/* 'iver' */
    jbne SCSIBOOTS_134
    cmpil #1298228073,%a2@(16)	/* pmPartName 'Maci...' */
    jbne SCSIBOOTS_134
    movel %fp@(-4),%d0
    cmpl %a2@(8),%d0	/* pmPyPartStart = the driver's block? */
    jbne SCSIBOOTS_134
    moveal %a3,%a0
    movel %a2@(96),%d1	/* pmBootSize */
    jbsr RDDONE_C
    cmpl %a2@(116),%d0	/* pmBootCksum */
    jbeq SCSIBOOTS_154
    jbra SCSIBOOTS_E2
SCSIBOOTS_134:          /* next map entry (block 2, 3...) until the map's size (pmMapBlkCnt) */
    addql #1,%fp@(-18)
    movel %fp@(-18),%d3
    cmpl %fp@(-14),%d3
    jbhi SCSIBOOTS_154
    moveq #1,%d2
    movew #512,%d4
    jbsr SCSILOAD_19A
    jbne SCSIBOOTS_134
    cmpiw #20557,%a2@
    jbne SCSIBOOTS_134
    jbra SCSIBOOTS_F0
SCSIBOOTS_154:          /* the checksum matched (or no driver entry): now look for an Apple_HFS partition */
    moveq #0,%d0
    movel %d0,%fp@(-18)
SCSIBOOTS_15A:          /* next map entry: "Apple_HFS"? then call the driver */
    addql #1,%fp@(-18)
    movel %fp@(-18),%d3
    cmpl %fp@(-14),%d3
    jbhi SCSIBOOTS_E2
    moveq #1,%d2
    movew #512,%d4
    jbsr SCSILOAD_19A
    jbne SCSIBOOTS_15A
    cmpiw #20557,%a2@
    jbne SCSIBOOTS_15A
    cmpil #1097887852,%a2@(48)	/* 'Appl' */
    jbne SCSIBOOTS_15A
    cmpil #1700743238,%a2@(52)	/* 'e_HF' */
    jbne SCSIBOOTS_15A
    cmpib #83,%a2@(56)	/* 'S' */
    jbne SCSIBOOTS_15A
    jbra SCSIBOOTS_DA

SCSILOAD_19A:           /* read d2 blocks of d4 bytes from block d3 of ID d5 into a2, with the old SCSI Manager calls: SCSIGet, SCSISelect, SCSICmd (READ(6)), SCSIRead with a TIB (scInc, scStop), SCSIComplete (60 ticks). Out: d7 = 0 or the error */
    movel %d7,%sp@-
    moveq #0,%d7
    swap %d2
    movew %d4,%d2
SCSIBOOTS_1A2:          /* the READ(6) command in Scratch8: 0x08, block (21 bits), count, 0 */
    lea Scratch8,%a0
    moveb #8,%a0@+	/* READ(6) */
    swap %d3
    andib #31,%d3	/* block bits 20-16 (LUN 0) */
    moveb %d3,%a0@+
    swap %d3
    movew %d3,%a0@+
    movel %d2,%d4
    swap %d4
    moveb %d4,%a0@+
    clrb %a0@+
    muluw %d2,%d4
    subaw #20,%sp
    movel %sp,%d6	/* d6 = a TIB on the stack: scInc buffer, count; scStop */
    subql #2,%sp
    movew #1,%sp@-	/* selector 1: SCSIGet */
    _SCSIDispatch
    movew %sp@,%d7
    jbne RDDONE
    movew %d5,%sp@-
    movew #2,%sp@-	/* selector 2: SCSISelect */
    _SCSIDispatch
    movew %sp@,%d7
    jbne RDDONE
    pea Scratch8
    movew #6,%sp@-
    movew #3,%sp@-	/* selector 3: SCSICmd */
    _SCSIDispatch
    movew %sp@,%d7
    jbne SCSIBOOTS_208
    moveal %d6,%a0
    movew #1,%a0@+
    movel %a2,%a0@+
    movel %d4,%a0@+
    movew #7,%a0@
    movel %d6,%sp@-
    movew #5,%sp@-	/* selector 5: SCSIRead */
    _SCSIDispatch
    movew %sp@,%d7
SCSIBOOTS_208:          /* SCSIComplete: status in Scratch8, message in Scratch8+2, 60 ticks */
    pea Scratch8
    pea scratch8_2
    movel #60,%sp@-
    movew #4,%sp@-	/* selector 4: SCSIComplete */
    _SCSIDispatch
    tstw %d7
    jbeq SCSIBOOTS_226
    cmpiw #5,%d7
    jbeq SCSIBOOTS_22E
SCSIBOOTS_226:          /* no read error (or a phase error 5): the SCSIComplete result; 10 (scComplPhaseErr) still looks at the status */
    movew %sp@,%d7
    cmpiw #10,%d7
    jbne RDDONE
SCSIBOOTS_22E:          /* the status byte: 0 is good, else SREADPATCH2 (retry on Check Condition / Busy) */
    movew Scratch8,%d7
    jbeq RDDONE
    jbra SREADPATCH2

/*
 TSTRETRY: retry the read once (d7 bit 31 marks the retry): the device may have been
 spinning up or reporting a unit attention.
*/
TSTRETRY:
    bset #31,%d7
    jbne RDDONE
    lea %sp@(22),%sp
    jbra SCSIBOOTS_1A2

/* RDDONE: end of a read: through SCSIMISCPATCH (cache flush on a 68040), result in d0. */
RDDONE:
    jbra SCSIMISCPATCH
    .short  0x0000	| 4080743E
    .long   0x00000000	| 40807440

RDDONE_C:               /* the boot code checksum (pmBootCksum) of d1 bytes at a0: for each byte add it, rotate left 1 (word); 0 becomes 0xFFFF */
    moveq #0,%d0
    moveq #0,%d7
    jbra RDDONE_18
RDDONE_12:              /* add the byte, rotate */
    moveb %a0@+,%d7
    addw %d7,%d0
    rolw #1,%d0
RDDONE_18:              /* next byte */
    dbf %d1,RDDONE_12
    tstw %d0
    jbne RDDONE_22
    subqw #1,%d0
RDDONE_22:              /* return */
    rts
    .long   0x00000000	| 4080745C

/*
 _SCSIDispatch (A815): the original SCSI Manager interface, selector word on the stack
 (0 SCSIReset, 1 SCSIGet, 2 SCSISelect, 3 SCSICmd, 4 SCSIComplete, 5 SCSIRead,
 6 SCSIWrite, 8 SCSIRBlind, 9 SCSIWBlind, 10 SCSIStat, 11 SCSISelAtn, 12 SCSIMsgIn,
 13 SCSIMsgOut). Each selector routine is entry n of the table at the start of the
 SCSI globals (SCSIGlobals, a4), so the 53C96 code replaces them (SCSIINIT96BIOS on
 the Quadra 800). The routines run with a link frame (fp@(8) = the first parameter),
 a4 = the globals, a3 = the chip (a4+64), d7 = 0. Selector 14 and up: system error 12.
*/
trap_SCSIDispatch:
SCSIOLD:
SCSIMGR:                /* pop the selector, keep the return address */
    moveal %sp@+,%a0
    movew %sp@+,%d0
    movel %a0,%sp@-
    cmpiw #14,%d0	/* selectors 0..13 */
    jbcc UNIMPLEMENTED
    linkw %fp,#-6
    moveml %d2-%d7/%a2-%a5,%sp@-
    moveal SCSIGlobals,%a4	/* a4 = SCSI globals */
    moveal %a4@(64),%a3	/* a3 = the chip */
    moveq #0,%d7
    moveq #0,%d4
    movew %d0,%d1
    moveal %a4@(0x0,%d0:w:4),%a0	/* the selector's routine */
    jmp %a0@

/*
 UNIMPLEMENTED: a selector the SCSI Manager does not have: system error 12
 (dsCoreErr, unimplemented trap).
*/
UNIMPLEMENTED:
    moveq #12,%d0
    _SysError
UNIMPLEMENTED_4:        /* (hang) */
    jbra UNIMPLEMENTED_4

/*
 DOSCSISTAT (10): SCSIStat: the bus status (5380: current bus status and bus and status
 registers, as one word).
*/
DOSCSISTAT:
    bsrw DMAPENDINGPATCH
    nop
    bnes DOSCSISTAT_16
    moveb %a3@(80),%fp@(8)
    moveb %a3@(64),%fp@(9)
    bras NOBYTEEXIT
DOSCSISTAT_16:
    moveb #8,%fp@(8)
    moveb #68,%fp@(9)
    bras NOBYTEEXIT

/* DOSCSIRESET (0): SCSIReset: reset the bus (vector +420), clean up, no parameters. */
DOSCSIRESET:
    moveal %a4@(420),%a0	/* vector +420: RESETBUS; 53C96 BIOS: RESETBUS_96_BIOS */
    jsr %a0@
    movew %d7,%fp@(8)
    jbsr SCSIEXITCLEANUP

/* NOBYTEEXIT: common exit (no parameters). */
NOBYTEEXIT:
    moveq #0,%d0
    jbra SCSISTDEXIT

/* SCSIEXITCLEANUP: leave the bus in a clean state after an error. */
SCSIEXITCLEANUP:
    moveq #-1,%d0
    moveal %a4@(408),%a0	/* vector +408: CLEARSTATE */
    jsr %a0@
    moveal %a4@(364),%a0	/* vector +364: CLEARIRQ */
    jsr %a0@
    moveq #1,%d0
    moveal %a4@(368),%a0	/* vector +368: DISENABLE */
    jsr %a0@
    rts

/*
 DOSCSIGET (1): SCSIGet: arbitrate for the bus. Fails with 7 (scMgrBusyErr) if the old
 interface is already in use (+97) or, at interrupt level, if asynchronous requests
 are queued. Otherwise it queues the internal request at +676 behind the queued ones
 and waits until it is first, then arbitrates (ARBITRATE).
*/
DOSCSIGET:
    bset #0,%a4@(97)	/* the old interface busy? */
    jbne DOSCSIGET_1E
    movew %sr,%sp@-
    oriw #1792,%sr
    movew %sp@,%d0
    andiw #1792,%d0	/* at interrupt level? */
    jbeq DOSCSIGET_22
    tstl %a4@(80)	/* asynchronous requests queued? */
    jbeq DOSCSIGET_22
    movew %sp@+,%sr
DOSCSIGET_1E:           /* 7 (scMgrBusyErr) */
    moveq #7,%d0
    jbra DOSCSIGET_4A
DOSCSIGET_22:           /* queue the internal request (+676) through ENDEQUEUE (d0 = -1: insert) */
    lea %a4@(676),%a1
    moveq #-1,%d0
    moveal %a4@(392),%a0	/* vector +392: ENDEQUEUE */
    jsr %a0@
    movew %sp@+,%sr
DOSCSIGET_30:           /* wait until it is at the head of the queue (+80) */
    cmpal %a4@(80),%a1
    jbne DOSCSIGET_30
    movel %d7,%d0
    jbsr SCSIGETPATCH
    jbsr ARBITRATE
    jbeq DOSCSIGET_4A
    movel %d0,%sp@-
    jbsr SCSIEXITCLEANUP
    movel %sp@+,%d0
DOSCSIGET_4A:           /* the result word */
    movew %d0,%fp@(8)
    jbra NOBYTEEXIT

/*
 DOSCSISELATN (11) / DOSCSISELECT (2): SCSISelAtn / SCSISelect(target ID): select the
 target (with ATN for SCSISelAtn, so a message can be sent). At the start:
 d0 = the ID, bit 31 set for selector 11.
*/
DOSCSISELATN:
DOSCSISELECT:           /* d0 = fp@(8), the ID; selector 11: bit 31 (with ATN) */
    moveq #0,%d0	| 4080752C
    movew %fp@(8),%d0
    cmpiw #11,%d1
    bnes DOSCSISELATN+0x10
    bset #31,%d0
    jbsr SELECT
    jbeq DOSCSISELATN_1E
    movel %d0,%sp@-
    jbsr SCSIEXITCLEANUP
    movel %sp@+,%d0
DOSCSISELATN_1E:        /* the result word */
    movew %d0,%fp@(10)
    moveq #2,%d0
    jbra SCSISTDEXIT

/* DOSCSICMD (3): SCSICmd(buffer, count): send the command bytes (SELECT_5C). */
DOSCSICMD:
    moveal %fp@(10),%a2
    movew %fp@(8),%d2
    jbsr SELECT_5C
    jbeq DOSCSICMD_16
    movel %d0,%sp@-
    jbsr SCSIEXITCLEANUP
    movel %sp@+,%d0
DOSCSICMD_16:           /* the result word */
    movew %d0,%fp@(14)
    moveq #6,%d0
    jbra SCSISTDEXIT

/*
 NEWSCSIREAD (5) / NEWSCSIWRITE (6) / NEWSCSIRBLIND (8) / NEWSCSIWBLIND (9): run the
 transfer instruction block (TIB) at fp@(8). Each TIB instruction is 10 bytes:
 opcode word, a pointer/address, a count. Opcodes: 1 scInc (transfer, advance the
 buffer), 2 scNoInc (transfer, same buffer), 3 scAdd (add to a long), 4 scMove (copy
 a long), 5 scLoop (repeat the previous instructions), 6 scNop, 7 scStop, 8 scComp
 (compare with the data read). d4 selects the transfer routine in the table at +164
 (read 32, write 36, blind read 40, blind write 44; +16 for compare). Error 4
 (scBadParmsErr) for an unknown opcode.
*/
NEWSCSIWBLIND:
    moveq #44,%d4
    jbra NEWSCSIREAD_22

NEWSCSIWRITE:           /* d4 = 36: write */
    moveq #36,%d4
    jbra NEWSCSIREAD_22

NEWSCSIRBLIND:          /* d4 = 40: blind read */
    moveq #40,%d4
    jbra NEWSCSIREAD_2
NEWSCSIREAD:            /* (moveq #32,d4: read) */
    .short  0x7820	| 40807580
NEWSCSIREAD_2:          /* reads: TCR = data in (I/O), mode = DMA mode; with the SCSI DMA chip its control register too */
    moveb #1,%a3@(48)
    moveb #2,%a3@(32)
    btst #4,%a4@(103)
    jbeq NEWSCSIREAD_1E
    movel #8,%a3@(128)
NEWSCSIREAD_1E:         /* start initiator receive (+112) */
    moveb %d7,%a3@(112)
NEWSCSIREAD_22:         /* a1 = the TIB */
    moveal %fp@(8),%a1
    jbra NEWSCSIREAD_40
NEWSCSIREAD_28:         /* scComp: the compare routine of this direction */
    bset #4,%d4
NEWSCSIREAD_2C:         /* scInc: transfer through vector +412, advance the pointer by the count done */
    moveal %a4@(412),%a0	/* vector +412: TRANSFER; 53C96 BIOS: TRANSFER_96_BIOS */
    jsr %a0@
    jbne NEWSCSIREAD_90
    addl %d1,%a1@(2)
    bclr #4,%d4
NEWSCSIREAD_3C:         /* next instruction (10 bytes) */
    lea %a1@(10),%a1
NEWSCSIREAD_40:         /* d1 = opcode, a2 = pointer, d2 = count; dispatch */
    movew %a1@,%d1
    moveal %a1@(2),%a2
    movel %a1@(6),%d2
    cmpiw #8,%d1
    jbhi NEWSCSIREAD_66
    jmp %pc@(NEWSCSIREAD_54,%d1:w:2)
NEWSCSIREAD_54:         /* the opcode table */
    jbra NEWSCSIREAD_66
    jbra NEWSCSIREAD_2C
    jbra NEWSCSIREAD_6A
    jbra NEWSCSIREAD_74
    jbra NEWSCSIREAD_78
    jbra NEWSCSIREAD_7E
    jbra NEWSCSIREAD_3C
    jbra NEWSCSIREAD_8E
    jbra NEWSCSIREAD_28
NEWSCSIREAD_66:         /* bad opcode: 4 (scBadParmsErr) */
    moveq #4,%d0
    jbra NEWSCSIREAD_90
NEWSCSIREAD_6A:         /* scNoInc: transfer, same buffer */
    moveal %a4@(412),%a0	/* vector +412: TRANSFER; 53C96 BIOS: TRANSFER_96_BIOS */
    jsr %a0@
    jbne NEWSCSIREAD_90
    jbra NEWSCSIREAD_3C
NEWSCSIREAD_74:         /* scAdd: add the count to the long at the pointer */
    addl %d2,%a2@
    jbra NEWSCSIREAD_3C
NEWSCSIREAD_78:         /* scMove: copy the long at the pointer to the address in the count */
    moveal %d2,%a0
    movel %a2@,%a0@
    jbra NEWSCSIREAD_3C
NEWSCSIREAD_7E:         /* scLoop: count down; while not 0, back by the relative offset in the pointer field */
    tstl %d2
    jbeq NEWSCSIREAD_3C
    subql #1,%d2
    movel %d2,%a1@(6)
    jbeq NEWSCSIREAD_3C
    addal %a2,%a1
    jbra NEWSCSIREAD_40
NEWSCSIREAD_8E:         /* scStop: done */
    moveq #0,%d0
NEWSCSIREAD_90:         /* back to normal mode (and the DMA chip) */
    moveb %d7,%a3@(32)
    btst #4,%a4@(103)
    jbeq NEWSCSIREAD_A4
    movel #2,%a3@(128)
NEWSCSIREAD_A4:         /* initiator command register 0; the result word */
    moveb %d7,%a3@(16)
    movew %d0,%fp@(12)
    moveq #4,%d0
    jbra SCSISTDEXIT

/*
 DOSCSICOMPLETE (4): SCSIComplete(stat, message, wait ticks): read the status byte and
 the message byte. Until the time runs out it keeps reading the status phase; a
 phase error (5) gets the bus to the status phase by cycling through the other
 phases (SELECT_1B4). At the start: save d7, clear the mode register.
*/
DOSCSICOMPLETE:
    movew %d7,%sp@-	| 40807632
    moveb %d7,%a3@(32)
    btst #4,%a4@(103)
    jbeq DOSCSICOMPLETE_16
    movel #2,%a3@(128)
DOSCSICOMPLETE_16:      /* d4 = the time limit (Ticks + wait) */
    movel Ticks,%d4
    addl %fp@(8),%d4
DOSCSICOMPLETE_1E:      /* read the status byte (SELECT_B8) */
    moveq #0,%d2
    jbsr SELECT_B8
    jbeq DOSCSICOMPLETE_3C
    cmpib #5,%d0
    jbne DOSCSICOMPLETE_34
    jbsr SELECT_1B4
    jbeq DOSCSICOMPLETE_34
    movew %d0,%sp@
DOSCSICOMPLETE_34:      /* time left? try again */
    cmpl Ticks,%d4
    jbhi DOSCSICOMPLETE_1E
    jbra DOSCSICOMPLETE_48
DOSCSICOMPLETE_3C:      /* status read: store it, read the message byte (SELECT_E0) */
    moveal %fp@(16),%a1
    movew %d2,%a1@
    jbsr SELECT_E0
    jbeq DOSCSICOMPLETE_4C
DOSCSICOMPLETE_48:      /* the error (10 scComplPhaseErr after cycling phases) */
    movew %d0,%sp@
    jbra DOSCSICOMPLETE_52
DOSCSICOMPLETE_4C:      /* store the message byte */
    moveal %fp@(12),%a1
    movew %d2,%a1@
DOSCSICOMPLETE_52:      /* end: SCSIDOCOMPLETEPATCH (frees the bus for the asynchronous requests) */
    jbsr SCSIDOCOMPLETEPATCH
    nop
    moveq #12,%d0
    jbra SCSISTDEXIT

/* DOSCSIMSGIN (12): SCSIMsgIn(message): read one message byte. */
DOSCSIMSGIN:
    jbsr SELECT_E0
    jbne DOSCSIMSGIN_C
    moveal %fp@(8),%a1
    movew %d2,%a1@
DOSCSIMSGIN_C:          /* the result word */
    movew %d0,%fp@(12)
    moveq #4,%d0
    jbra SCSISTDEXIT

/* DOSCSIMSGOUT (13): SCSIMsgOut(message): send one message byte. Raw words. */
DOSCSIMSGOUT:
    .long   0x342E0008, 0x61000180, 0x3D40000A	| 408076A4
    .short  0x7002	| 408076B0

/*
 SCSISTDEXIT: common exit of the selectors: restore registers, pop d0 bytes of
 parameters, return.
*/
SCSISTDEXIT:
    moveml %sp@+,%d2-%d7/%a2-%a5
    unlk %fp
    moveal %sp@+,%a0
    addaw %d0,%sp
    jmp %a0@

/*
 ARBITRATE (5380): put our ID on the bus (output data register) and start arbitration
 (mode register bit 0); wait for "arbitration in progress" (initiator command bit 6),
 up to TimeSCSIDB-based count; after the 2.2 us arbitration delay we have lost if
 "lost arbitration" (bit 5) is set or a higher ID is on the bus. Out: 0, or 3
 (scArbNBErr) if the bus never became free.
*/
ARBITRATE:
    moveb %a4@(96),%a3@	/* output data = our ID bit */
ARBITRATE_4:            /* arbitrate: mode = arbitrate */
    moveb %d7,%a3@(32)
    moveq #0,%d1
    movew TimeSCSIDB,%d1	/* TimeSCSIDB loops per ms */
    lsll #8,%d1
    movel %d1,%d5
    swap %d5
    moveb #1,%a3@(32)	/* mode: arbitrate */
ARBITRATE_1A:           /* wait for arbitration in progress (ICR bit 6) */
    btst #6,%a3@(16)	/* arbitration in progress */
    dbne %d1,ARBITRATE_1A
    dbne %d5,ARBITRATE_1A
    jbne ARBITRATE_32
    moveb %d7,%a3@(32)
    moveq #3,%d0
    rts
ARBITRATE_32:           /* arbitration delay; lost (ICR bit 5)? a higher ID on the bus? then again */
    jbsr SELECT_140
    btst #5,%a3@(16)	/* lost arbitration? */
    jbne ARBITRATE_4
    moveb %a3@,%d0	/* the IDs on the bus: any above ours? */
    moveb %a4@(96),%d2
    eorb %d2,%d0
    cmpb %d0,%d2
    jbcs ARBITRATE_4
    btst #5,%a3@(16)
    jbne ARBITRATE_4
    moveq #0,%d0
    rts

/*
 SELECT (5380): select target d0 (bit 31: with ATN): assert SEL, put our ID and the
 target's on the bus, assert BSY+SEL+data (+ATN), release BSY, wait for the target's
 BSY (timeout +98, 250 ms, in TimeSCSIDB loops), then release SEL and the data bus.
 Out: 0, or 2 (scCommErr) on timeout.
*/
SELECT:
    lea %a3@(16),%a0
    moveq #1,%d1
    lslb %d0,%d1
    movel %d0,%d3
    moveb #4,%a0@	/* ICR: SEL */
    jbsr SELECT_140
    moveb %a4@(96),%d2
    moveb %d7,%a3@(48)
    orb %d2,%d1
    moveb %d1,%a3@	/* our ID and the target's */
    moveb #13,%d4	/* BSY, SEL, data bus */
    tstl %d3
    jbpl SELECT_2A
    orib #2,%d4	/* + ATN */
SELECT_2A:              /* ICR: BSY, SEL, data bus (and ATN) */
    moveb %d4,%a0@
    moveb %d7,%a3@(32)
    moveb %d7,%a3@(64)	/* select enable 0 */
    bclr #3,%d4	/* release BSY */
    moveb %d4,%a0@
    jbsr SELECT_140
    movew %a4@(98),%d1	/* select timeout (ms) */
    jbsr SELECT_14C
    jbne SELECT_56
    jbsr SELECT_140
    andib #10,%d4	/* keep ATN only */
    moveb %d4,%a0@
    moveq #0,%d0
    rts
SELECT_56:              /* timeout: release everything */
    moveb %d7,%a0@
    tstw %d0
    rts

SELECT_5C:              /* SCSICmd: command phase (TCR C/D), each byte with the REQ/ACK handshake; then wait while the target stays in the command phase */
    moveb #2,%a3@(48)	/* TCR: command phase (C/D) */
    jbsr SELECT_190
    jbne SELECT_B6
    jbsr SELECT_21C
    jbne SELECT_B6
    subql #1,%d2
SELECT_70:              /* one command byte: data out, assert ACK, wait for REQ to go, release ACK */
    moveb %a2@+,%a3@
    moveb #1,%a3@(16)	/* ICR: drive the data bus */
    jbsr SELECT_190
    jbne SELECT_B6
    moveb #17,%a3@(16)	/* + ACK */
    jbsr SELECT_16C
    jbne SELECT_B6
    moveb %d7,%a3@(16)	/* release */
    dbf %d2,SELECT_70
    movel %d7,%d0
    movew TimeSCSIDB,%d0
    lsll #8,%d0
    movel %d0,%d2
    swap %d2
SELECT_9E:              /* wait for the phase to change (or bus free) */
    btst #6,%a3@(64)	/* BSY gone: bus free */
    jbeq SELECT_B4
    btst #3,%a3@(80)	/* phase match: still the command phase */
    dbeq %d0,SELECT_9E
    dbeq %d2,SELECT_9E
SELECT_B4:              /* 0 */
    moveq #0,%d0
SELECT_B6:              /* return */
    rts

SELECT_B8:              /* status phase (TCR C/D + I/O): read the status byte (d2) with the handshake */
    moveb #3,%a3@(48)	/* TCR: status phase (C/D, I/O) */
    jbsr SELECT_190
    jbne SELECT_DE
    jbsr SELECT_21C
    jbne SELECT_DE
    moveb %a3@,%d2	/* the status byte */
    moveb #16,%a3@(16)	/* ACK */
    jbsr SELECT_16C
    jbne SELECT_DE
    moveb %d7,%a3@(16)
    moveq #0,%d0
SELECT_DE:              /* return */
    rts

SELECT_E0:              /* message in phase (TCR MSG + C/D + I/O): read the message byte (d2) */
    moveb #7,%a3@(48)	/* TCR: message in (MSG, C/D, I/O) */
    jbsr SELECT_190
    jbne SELECT_114
SELECT_EC:              /* phase match? read the byte, ACK, wait, release ACK */
    jbsr SELECT_21C
    jbne SELECT_114
    moveq #0,%d2
    moveb %a3@,%d2	/* the message byte */
    moveb %a3@(16),%d0
    bset #4,%d0
    moveb %d0,%a3@(16)
    jbsr SELECT_16C
    jbne SELECT_114
    moveb %a3@(16),%d0
    bclr #4,%d0
    moveb %d0,%a3@(16)
    moveq #0,%d0
SELECT_114:             /* return */
    rts
    .short  0x177C	| 4080782A
    orib #48,%d6
    jbsr SELECT_190
    jbne SELECT_13E
    jbsr SELECT_21C
    jbne SELECT_13E
    moveb #1,%a3@(16)
    moveb %d2,%a3@
    moveb #17,%a3@(16)
    jbsr SELECT_16C
    jbne SELECT_13E
    moveb %d7,%a3@(16)
    moveq #0,%d0
SELECT_13E:             /* return (message out: the same with one byte written) */
    rts

SELECT_140:             /* a short delay (TimeDBRA / 128 loops) */
    movew TimeDBRA,%d0	/* TimeDBRA / 128 */
    lsrw #7,%d0
SELECT_146:             /* delay loop */
    dbf %d0,SELECT_146
    rts

SELECT_14C:             /* wait for BSY (CSR bit 6), d1 ms: 2 (scCommErr) if it never comes */
    muluw TimeSCSIDB,%d1	/* ms * TimeSCSIDB */
    movel %d1,%d5
    swap %d5
    moveq #0,%d0
SELECT_156:             /* BSY? */
    btst #6,%a3@(64)	/* BSY */
    dbne %d1,SELECT_156
    dbne %d5,SELECT_156
    jbne SELECT_168
    moveq #2,%d0
SELECT_168:             /* return (Z set if it came) */
    tstw %d0
    rts

SELECT_16C:             /* wait for REQ to be released (CSR bit 5 clear): 2 if it stays */
    moveq #0,%d1
    movew TimeSCSIDB,%d1
    lsll #8,%d1
    movel %d1,%d5
    swap %d5
    moveq #0,%d0
SELECT_17A:             /* REQ still set? */
    btst #5,%a3@(64)	/* REQ */
    dbeq %d1,SELECT_17A
    dbeq %d5,SELECT_17A
    jbeq SELECT_18C
    moveq #2,%d0
SELECT_18C:             /* return */
    tstw %d0
    rts

SELECT_190:             /* wait for REQ (CSR bit 5): 2 (scCommErr) on timeout */
    moveq #0,%d1
    movew TimeSCSIDB,%d1
    lsll #8,%d1
    movel %d1,%d5
    swap %d5
    moveq #0,%d0
SELECT_19E:             /* REQ? */
    btst #5,%a3@(64)	/* REQ */
    dbne %d1,SELECT_19E
    dbne %d5,SELECT_19E
    jbne SELECT_1B0
    moveq #2,%d0
SELECT_1B0:             /* return */
    tstw %d0
    rts

SELECT_1B4:             /* get the bus to the status phase: answer each other phase (read and drop a data byte, or send 0xEE) until it matches; result 10 (scComplPhaseErr) */
    movew %d7,%sp@-
SELECT_1B6:             /* wait for REQ */
    jbsr SELECT_190
    jbeq SELECT_1BE
    movew %d0,%sp@
    jbra SELECT_218
SELECT_1BE:             /* phase match (BSR bit 3)? done */
    btst #3,%a3@(80)
    jbne SELECT_218
    moveb %a3@(48),%d3
    moveb %a3@(64),%d2	/* the current phase (CSR bits 4-2) ... */
    asrl #2,%d2
    andib #7,%d2
    moveb %d2,%a3@(48)	/* ... into the TCR */
    btst #2,%a3@(64)	/* I/O: an input phase */
    jbeq SELECT_1EA
    moveb %a3@,%d2	/* read and drop the byte */
    moveb #16,%a3@(16)
    jbra SELECT_1FA
SELECT_1EA:             /* an output phase: send a 0xEE byte */
    moveb #1,%a3@(16)
    moveb #0xee,%a3@	/* send 0xEE */
    moveb #17,%a3@(16)
SELECT_1FA:             /* result 10 (scComplPhaseErr); finish the handshake, back to the status phase */
    movew #10,%sp@
    jbsr SELECT_16C
    jbne SELECT_218
    moveb %d7,%a3@(16)
    moveb %d3,%a3@(48)
    jbsr SELECT_140
    btst #3,%a3@(80)
    jbeq SELECT_1B6
SELECT_218:             /* return the result */
    movew %sp@+,%d0
    rts

SELECT_21C:             /* phase match (BSR bit 3)? else 5 (scPhaseErr) */
    moveq #0,%d0
    btst #3,%a3@(80)	/* phase match */
    jbne SELECT_228
    moveq #5,%d0
SELECT_228:             /* return */
    tstw %d0
    rts

/*
 SCSINEW / NEWSCSITRAP (d0 = selector, a0 = request): the asynchronous interface:
 0 execute I/O (DOREQUESTIO), 1 kill I/O (DOKILLIO), 2 bus inquiry (DOBUSINFO), from
 the table at +484. A request for another bus (+10 non-zero) goes to that bus's driver
 (ALTBUSCALL). Bad selector: -470.
*/
SCSINEW:
NEWSCSITRAP:            /* a5 = the request, a4 = globals, a3 = chip */
    moveml %d1-%a5,%sp@-
    moveal SCSIGlobals,%a4
    moveal %a0,%a5
    moveal %a4@(64),%a3
    moveq #0,%d7
    tstw %a5@(10)	/* another bus? */
    jbeq SCSINEW_1E
    moveal %a4@(512),%a0	/* vector +512: ALTBUSCALL */
    jsr %a0@
    jbra SCSINEW_34
SCSINEW_1E:             /* selector 0..2? */
    cmpiw #2,%d0
    jbls SCSINEW_2A
    movew #-470,%d0	/* bad selector */
    jbra SCSINEW_34
SCSINEW_2A:             /* call it */
    lea %a4@(484),%a0
    moveal %a0@(0x0,%d0:w:4),%a0
    jsr %a0@
SCSINEW_34:             /* restore registers, return */
    moveml %sp@+,%d1-%a5
    rts

/*
 ALTBUSCALL: pass the request to the driver of another SCSI bus: _Control with refNum
 = the request's bus (+10), csCode = d0, csParam = the request. -470 on error.
*/
ALTBUSCALL:
    lea %sp@(-50),%sp
    moveal %sp,%a0
    movew %a5@(10),%a0@(24)
    movew %d0,%a0@(26)
    movel %a5,%a0@(32)
    _Control
    lea %sp@(52),%sp
    jbeq ALTBUSCALL_20
    movew #-470,%d0
ALTBUSCALL_20:          /* return */
    rts

/*
 DOREQUESTIO: execute I/O: check the request (PREFLIGHT), queue it (ENDEQUEUE, as event
 1 for the deferred task) and, for a synchronous request, wait until its result word
 (+14) is no longer positive.
*/
DOREQUESTIO:
    moveal %a4@(388),%a0
    jsr %a0@
    bnes DOREQUESTIO_24
    moveq #1,%d0
    movel %a5,%d1
    moveal %a4@(360),%a0
    jsr %a0@
    moveq #0,%d0
    movel %a5@(32),%d1
    btst #5,%d1
    bnes DOREQUESTIO_24
DOREQUESTIO_1E:
    tstw %a5@(14)
    bgts DOREQUESTIO_1E
DOREQUESTIO_24:
    rts

/*
 DOKILLIO: kill I/O: reset the bus (vector +420, RESETBUS: every queued request fails),
 result 0.
*/
DOKILLIO:
    moveal %a4@(420),%a0
    jsr %a0@
    moveq #0,%d0
    rts

/*
 DOBUSINFO: bus inquiry, by the request's info code (+8), the answer in its first
 long: 0 the byte at +126 (1; 2 once the 53C96 BIOS is installed), 1 the long at +128
 (a transfer rate), 2 whether the bus has the SCSI DMA chip (flags bit 4); else -470.
*/
DOBUSINFO:
    moveq #0,%d0
    movew %a5@(8),%d1
    bnes DOBUSINFO_12
    movel %d7,%d1
    moveb %a4@(126),%d1
    movel %d1,%a5@
    rts
DOBUSINFO_12:
    subql #1,%d1
    bnes DOBUSINFO_1C
    movel %a4@(128),%a5@
    rts
DOBUSINFO_1C:
    subql #1,%d1
    bnes DOBUSINFO_32
    movel %a4@(100),%d1
    andil #16,%d1
    beqs DOBUSINFO_2E
    moveq #1,%d1
DOBUSINFO_2E:
    movel %d1,%a5@
    rts
DOBUSINFO_32:
    movew #-470,%d0
    rts

/*
 RESETBUS: reset the SCSI bus: assert RST (ICR bit 7) with interrupts off, fail every
 queued request with -476, wait, release RST, clear the chip interrupt, wait 500 ms
 (TimeDBRA), restore the DMA chip.
*/
RESETBUS:
    movew %sr,%sp@-
    oriw #1792,%sr
    moveb #0x80,%a3@(16)	| 40807A0A
    lea %a4@(80),%a5
    lea %a4@(676),%a1
    movew #-476,%d0
    moveal %a4@(408),%a0
RESETBUS_1C:
    moveal %a5@,%a5
    cmpl %a5,%d7
    beqs RESETBUS_34
    cmpal %a1,%a5
    beqs RESETBUS_2A
    jsr %a0@
    bras RESETBUS_1C
RESETBUS_2A:
    moveq #-1,%d1
    exg %d0,%d1
    jsr %a0@
    exg %d0,%d1
    bras RESETBUS_1C
RESETBUS_34:
    movew TimeDBRA,%d0
    lsrw #2,%d0
RESETBUS_3A:
    dbf %d0,RESETBUS_3A
    moveb %d7,%a3@(16)
    moveal %a4@(364),%a0
    jsr %a0@
    movew %sp@+,%sr
    movew TimeDBRA,%d0
    muluw #500,%d0
    movel %d0,%d1
    swap %d1
RESETBUS_56:
    dbf %d0,RESETBUS_56
    dbf %d1,RESETBUS_56
    btst #4,%a4@(103)
    beqs RESETBUS_6E
    movel #2,%a3@(128)
RESETBUS_6E:
    moveb %d7,%a3@(32)
    rts

/*
 ENDEQUEUE (d0 = -1: add request a1, 1: remove it): the request queue (+80 head, +84
 tail), with interrupts off.
*/
ENDEQUEUE:
    movew %sr,%sp@-
    oriw #1792,%sr
    btst #31,%d0
    bnes ENDEQUEUE_4A
    moveml %a2-%a3,%sp@-
    moveal %a4@(80),%a2
    moveal %a2,%a3
ENDEQUEUE_16:
    cmpal %a3,%a1
    beqs ENDEQUEUE_26
    moveal %a3,%a2
    moveal %a2@,%a3
    cmpal %a4@(84),%a2
    bnes ENDEQUEUE_16
    bras ENDEQUEUE_44
ENDEQUEUE_26:
    cmpal %a2,%a3
    bnes ENDEQUEUE_36
    movel %a2@,%a4@(80)
    bnes ENDEQUEUE_42
    clrl %a4@(84)
    bras ENDEQUEUE_42
ENDEQUEUE_36:
    movel %a3@,%a2@
    cmpal %a4@(84),%a1
    bnes ENDEQUEUE_42
    movel %a2,%a4@(84)
ENDEQUEUE_42:
    clrl %a1@
ENDEQUEUE_44:
    moveml %sp@+,%a2-%a3
    bras ENDEQUEUE_88
ENDEQUEUE_4A:
    moveml %d1/%a2-%a3,%sp@-
    moveal %a1,%a3
ENDEQUEUE_50:
    movel %a3@(36),%d1
    beqs ENDEQUEUE_5C
    movel %d1,%a3@
    moveal %d1,%a3
    bras ENDEQUEUE_50
ENDEQUEUE_5C:
    movel %a4@(80),%d1
    bnes ENDEQUEUE_6C
    movel %a1,%a4@(80)
    movel %a3,%a4@(84)
    bras ENDEQUEUE_84
ENDEQUEUE_6C:
    cmpiw #-1,%d0
    bnes ENDEQUEUE_7E
    moveal %a4@(84),%a2
    movel %a1,%a2@
    movel %a3,%a4@(84)
    bras ENDEQUEUE_84
ENDEQUEUE_7E:
    movel %d1,%a3@
    movel %a1,%a4@(80)
ENDEQUEUE_84:
    moveml %sp@+,%d1/%a2-%a3
ENDEQUEUE_88:
    movew %sp@+,%sr
    moveq #0,%d0
    rts

/*
 LOGERROR: store error d0 in the active request's private block (+16), unless one is
 already there.
*/
LOGERROR:
    cmpl %a5,%d7
    beqs LOGERROR_16
    moveal %a5@(4),%a0
    cmpl %a0,%d7
    beqs LOGERROR_16
    tstw %a0@(16)
    bnes LOGERROR_16
    movew %d0,%a0@(16)
LOGERROR_16:
    rts

/*
 CLEARSTATE (d0 = result, or -1): finish the active request (a5) with result d0: it is
 no longer active (+88), leaves the queue, its private block goes back to the free
 list (+60), its target/LUN is no longer busy (+116 per ID, +124 per ID with any),
 and its completion routine (+16) is called if the request asked for one (flags
 +32 bit 5). Then the next timeout (+92) is the earliest deadline of the queued
 requests. d0 = -1: only the old interface's request (+676) and the busy flag (+97)
 are cleared; reselection is re-enabled if a target is disconnected.
*/
CLEARSTATE:
    moveml %d0-%a5,%sp@-
    cmpiw #-1,%d0	/* -1: the old interface only */
    jbne CLEARSTATE_32
    movel %a4@(80),%d1
    jbeq CLEARSTATE_1C
    moveq #1,%d0
    lea %a4@(676),%a1
    moveal %a4@(392),%a0	/* vector +392: ENDEQUEUE */
    jsr %a0@
CLEARSTATE_1C:          /* SCSIGet no longer active; targets disconnected? allow reselection (select enable = our ID) */
    moveb %d7,%a4@(97)
    tstb %a4@(124)
    jbeq CLEARSTATE_F8
    moveb %a4@(96),%a3@(64)
    jbra CLEARSTATE_F8
CLEARSTATE_32:          /* finish the active request: remove it from the queue (ENDEQUEUE 1) */
    movel %d7,%a4@(88)	/* no active request */
    moveal %a5,%a1
    movel %d0,%d2
    moveq #1,%d0
    moveal %a4@(392),%a0	/* vector +392: ENDEQUEUE */
    jsr %a0@
    movel %a5@(4),%d0
    jbeq CLEARSTATE_7C
    moveal %d0,%a0
    movew %a0@(16),%d0
    jbeq CLEARSTATE_52
    movew %d0,%d2
CLEARSTATE_52:          /* free its private block (48 bytes): clear it, back on the free list if that was empty */
    movel %d7,%a5@(4)
    movel %d7,%a0@(4)
    movel %d7,%a0@(8)
    movel %d7,%a0@(12)
    movel %d7,%a0@(16)
    movel %d7,%a0@(20)
    movel %d7,%a0@(24)
    movel %d7,%a0@(28)
    tstl %a4@(60)
    jbne CLEARSTATE_7C
    movel %a0,%a4@(60)
CLEARSTATE_7C:          /* result word (+14); clear the LUN's busy bit, and the ID's if no LUN left */
    movew %d2,%a5@(14)	/* result */
    lea %a4@(116),%a1
    movel %d7,%d2
    moveb %a5@(12),%d2
    moveb %a5@(13),%d1
    bclr %d1,%a1@(0x0,%d2:l)	/* LUN no longer busy */
    tstb %a1@(0x0,%d2:l)
    jbne CLEARSTATE_9C
    bclr %d2,%a4@(124)	/* ID: no LUN busy */
CLEARSTATE_9C:          /* flags bit 7: it was the request waiting at +104 */
    movel %a5@(32),%d0
    btst #7,%d0
    jbeq CLEARSTATE_AA
    movel %d7,%a4@(104)
CLEARSTATE_AA:          /* flags bit 5: call the completion routine (+16) with a0 = the request */
    btst #5,%d0
    jbeq CLEARSTATE_D4
    movel %a5@(16),%d0
    jbeq CLEARSTATE_D4
    moveml %d0-%a5,%sp@-
    btst #7,%a4@(103)
    jbne CLEARSTATE_CA
    moveal %d0,%a1
    moveal %a5,%a0
    jsr %a1@
    jbra CLEARSTATE_D0
CLEARSTATE_CA:          /* (flag +103 bit 7: the call is skipped, nop) */
    moveal %d0,%a0
    movel %a5,%d0
    nop
CLEARSTATE_D0:          /* restore registers */
    moveml %sp@+,%d0-%a5
CLEARSTATE_D4:          /* the next timeout: the earliest deadline (+8 of each private block) */
    moveq #-1,%d0
    lea %a4@(80),%a1
CLEARSTATE_DA:          /* next queued request */
    moveal %a1@,%a1
    cmpl %a1,%d7
    jbeq CLEARSTATE_F4
    movel %a1@(4),%d1
    jbeq CLEARSTATE_DA
    moveal %d1,%a0
    cmpl %a0@(8),%d0
    jbcs CLEARSTATE_DA
    movel %a0@(8),%d0
    jbra CLEARSTATE_DA
CLEARSTATE_F4:          /* +92 = it (-1: none) */
    movel %d0,%a4@(92)
CLEARSTATE_F8:          /* restore registers, return */
    moveml %sp@+,%d0-%a5
    rts

/* CLEARBUS: if BSY or SEL is still on the bus (CSR bits 6, 1), reset the bus (+420). */
CLEARBUS:
    moveml %d0-%a5,%sp@-
    moveq #66,%d0	/* BSY or SEL still asserted? */
    andb %a3@(64),%d0
    jbeq CLEARBUS_12
    moveal %a4@(420),%a0	/* vector +420: RESETBUS; 53C96 BIOS: RESETBUS_96_BIOS */
    jsr %a0@
CLEARBUS_12:            /* restore registers, return */
    moveml %sp@+,%d0-%a5
    rts

/*
 MESSAGE (d0 = event, d1 = data): record an event for the deferred task (bit d0 of
 +600) and install SCSIDT if it is not queued yet (+125 bit 7). Events: 1 new
 request (d1 = it), 2 parity error, 3 bus reset, 4 bus free, 5 phase change, 6 end of
 DMA, 7 reselection (d1 = the IDs on the bus, kept at +603).
*/
MESSAGE:
    moveml %d0-%a5,%sp@-
    bset %d0,%a4@(600)	/* the event bit */
    cmpib #7,%d0
    jbne MESSAGE_14
    moveb %d1,%a4@(603)	/* reselection: the IDs */
    jbra MESSAGE_3E
MESSAGE_14:             /* event 1: queue the new request (ENDEQUEUE -1); one that must wait (flags bit 7) is kept at +104 and the timer started */
    cmpib #1,%d0
    jbne MESSAGE_3E
    moveal %a4@(392),%a0
    moveal %d1,%a1
    movel %a1@(32),%d1
    btst #7,%d1
    jbne MESSAGE_30
    moveq #-1,%d0
    jsr %a0@
    jbra MESSAGE_3E
MESSAGE_30:             /* the request to wait for */
    movel %a1,%a4@(104)
    moveq #-2,%d0
    jsr %a0@
    moveal %a4@(376),%a0	/* vector +376: SCSIDT */
    jsr %a0@
MESSAGE_3E:             /* the deferred task, once */
    bset #7,%a4@(125)
    jbne MESSAGE_4C
    lea %a4@(588),%a0
    _DTInstall
MESSAGE_4C:             /* restore registers, return */
    moveml %sp@+,%d0-%a5
    rts

/*
 PREFLIGHT: check a new request before queueing it: no queue link, no private block,
 a valid selector, buffers and counts consistent with the flags, target ID and LUN
 0..7, not our own ID; -470 if not. Then result = 1 (in progress), the counters
 cleared, and the scatter list's working counts (+12 of each 16-byte entry) set from
 the entries (-1 = the whole count).
*/
PREFLIGHT:
    moveq #0,%d0
    tstl %a5@
    bnew PREFLIGHT_F0_6
    tstl %a5@(4)
    bnew PREFLIGHT_F0_6
    tstw %a5@(8)
    beqw PREFLIGHT_F0_6
    tstl %a5@(36)
    beqs PREFLIGHT_30
    braw PREFLIGHT_F0_6
    moveml %a0/%a5,%sp@-
    moveal %a5@(36),%a5
    jsr %a0@
    moveml %sp@+,%a0/%a5
PREFLIGHT_30:
    tstl %a5@(24)
    beqw PREFLIGHT_F0_6
    tstw %a5@(30)
    beqw PREFLIGHT_F0_6
    cmpiw #1,%a5@(8)
    bnes PREFLIGHT_66
    movel %a5@(32),%d2
    btst #4,%a4@(103)
    beqs PREFLIGHT_5C
    andil #-256,%d2
    bras PREFLIGHT_62
PREFLIGHT_5C:
    andil #-240,%d2
PREFLIGHT_62:
    bnew PREFLIGHT_F0_6
PREFLIGHT_66:
    moveq #7,%d2
    cmpb %a5@(12),%d2
    bcsw PREFLIGHT_F0_6
    cmpb %a5@(13),%d2
    bcsw PREFLIGHT_F0_6
    tstl %a5@(48)
    beqs PREFLIGHT_F0_6
    cmpl %a5@(40),%d7
    beqs PREFLIGHT_8C
    cmpib #4,%a5@(44)
    bcss PREFLIGHT_F0_6
PREFLIGHT_8C:
    cmpl %a5@(56),%d7
    bnes PREFLIGHT_9C
    cmpl %a5@(52),%d7
    bnes PREFLIGHT_F0_6
    moveq #0,%d0
    jbra PREFLIGHT_BA
PREFLIGHT_9C:
    moveal %a5@(52),%a0
    cmpl %a0,%d7
    beqs PREFLIGHT_F0_6
PREFLIGHT_9C_8:
    tstl %a0@
    beqs PREFLIGHT_9C_12
    lea %a0@(16),%a0
    bras PREFLIGHT_9C_8
PREFLIGHT_9C_12:
    tstl %a0@(4)
    bnes PREFLIGHT_F0_6
    tstl %a0@(8)
    bnes PREFLIGHT_F0_6
PREFLIGHT_BA:           /* accepted: result 1 (in progress), counters cleared */
    movew #1,%a5@(14)
    moveb %d7,%a5@(45)
    movel %d7,%a5@(60)
    moveb #0xff,%a5@(46)
    tstl %a5@(56)
    jbeq PREFLIGHT_FA
    moveal %a5@(52),%a0
    moveq #-1,%d2
PREFLIGHT_DA:           /* each scatter entry: working count = its count (or the next long for -1) */
    movel %a0@,%d1
    jbeq PREFLIGHT_F0
    cmpl %d2,%d1
    jbne PREFLIGHT_E6
    movel %a0@(4),%d1
PREFLIGHT_E6:           /* next entry */
    movel %d1,%a0@(12)
    lea %a0@(16),%a0
    jbra PREFLIGHT_DA
PREFLIGHT_F0:           /* end of list */
    movel %d7,%a0@(12)
    jbra PREFLIGHT_FA
PREFLIGHT_F0_6:
    movew #-470,%d0	| 40807D7C
PREFLIGHT_FA:           /* return (d0 tested) */
    tstw %d0
    rts

/*
 SETUP: make a5 the active request (+88): its deadline (Ticks + its timeout) in the
 private block, the next timeout (+92), and start the timer (SETTIMER, +416).
*/
SETUP:
    movel %a5,%a4@(88)
    movel Ticks,%d2
    movel %a5@(24),%d1
    asrl #4,%d1
    moveal %a5@(4),%a0
    movel %a0@(8),%d0
    bnes SETUP_22
    movel %d2,%d0
    addl %d1,%d0
    movel %d0,%a0@(8)
    bras SETUP_2C
SETUP_22:
    subl %d2,%d0
    bcss SETUP_2C
    cmpl %d1,%d0
    blss SETUP_2C
    movel %d0,%d1
SETUP_2C:
    movel %d2,%d0
    addl %d1,%d0
    movel %d0,%a4@(92)
    muluw #17,%d1
    movel %d1,%d0
    moveal %a4@(416),%a0
    jsr %a0@
    rts

/*
 FIND (d0): the next request that can start: d0 bit 31 = a reselection by the IDs in
 d0 (find the request of that ID and LUN that disconnected); else the first queued
 request whose target/LUN is not busy. Not while a request is active (+88). Out: d0 =
 the request, or 0.
*/
FIND:
    moveml %d1-%d2/%a0-%a3,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    tstl %a4@(88)
    jbne FIND_6A
    lea %a4@(116),%a1
    lea %a4@(80),%a0
    movel %d7,%d2
    btst #31,%d0
    jbeq FIND_28
    moveb %a4@(124),%d1
    eorb %d1,%d0
    jbra FIND_30
FIND_28:                /* d1 = IDs to look for */
    moveb %d0,%d1
    jbne FIND_2E
    bset %d7,%d0
FIND_2E:                /* ID mask in the high byte, LUN mask in the low */
    rolw #8,%d0
FIND_30:                /* next queued request: ID (+12) wanted? LUN (+13) not busy? */
    moveal %a0@,%a0
    cmpl %a0,%d7
    jbeq FIND_6A
    btst #31,%d0
    jbne FIND_50
    moveb %a0@(12),%d2
    jblt FIND_6A
    btst %d2,%d0
    jbeq FIND_30
    moveb %a0@(13),%d2
    btst %d2,%d1
    jbeq FIND_30
    jbra FIND_66
FIND_50:                /* reselection: this ID, a LUN that is disconnected (+116) */
    moveb %a0@(12),%d2
    jblt FIND_6A
    btst %d2,%d0
    jbeq FIND_30
    moveb %a1@(0x0,%d2:w),%d1
    moveb %a0@(13),%d2
    btst %d2,%d1
    jbne FIND_30
FIND_66:                /* found */
    movel %a0,%d0
    jbra FIND_6C
FIND_6A:                /* none */
    movel %d7,%d0
FIND_6C:                /* restore, return (d0 tested) */
    movew %sp@+,%sr
    moveml %sp@+,%d1-%d2/%a0-%a3
    tstl %d0
    rts

/*
 SETTIMER (d0 = ms, 0 = stop): the Time Manager task at +608 (TIMETASK): _RmvTime,
 _InsTime, _PrimeTime d0.
*/
SETTIMER:
    lea %a4@(608),%a0
    tstl %d0
    bnes SETTIMER_C
    _RmvTime
    rts
SETTIMER_C:
    movel %d0,%sp@-
    _RmvTime
    _InsTime
    movel %sp@+,%d0
    _PrimeTime
    rts

/*
 TIMETASK: the request timeout task (every 5 s while requests are queued): the active
 request past its deadline is failed with -475 (CLEARSTATE); with none active, every
 queued request past its deadline is.
*/
TIMETASK:               /* any request queued? */
    moveml %d0-%a5,%sp@-
    moveal SCSIGlobals,%a4
    moveal %a4@(64),%a3
    moveq #0,%d7
    movel %a4@(80),%d0
    jbeq TIMETASK_72
    movel Ticks,%d0
    cmpl %a4@(92),%d0	/* before the earliest deadline: nothing to do */
    jbcs TIMETASK_66
    moveal %a4@(88),%a5
    cmpl %a5,%d7
    jbeq TIMETASK_3C
    moveal %a5@(4),%a0
    cmpl %a0@(8),%d0
    jbcs TIMETASK_66
    movew #-475,%d0	/* timeout */
    moveal %a4@(408),%a0	/* vector +408: CLEARSTATE */
    jsr %a0@
    jbra TIMETASK_66
TIMETASK_3C:            /* no request active: fail the queued ones past their deadline */
    movel %d0,%d1
    movew #-475,%d0
    lea %a4@(80),%a5
TIMETASK_46:            /* next queued request: past its deadline? fail it (-475) */
    moveal %a5,%a1
    moveal %a5@,%a5
    cmpl %a5,%d7
    jbeq TIMETASK_66
    moveal %a5@(4),%a0
    cmpl %a0,%d7
    jbeq TIMETASK_46
    cmpl %a0@(8),%d1
    jbcs TIMETASK_46
    moveal %a4@(408),%a0	/* vector +408: CLEARSTATE */
    jsr %a0@
    moveal %a1,%a5
    jbra TIMETASK_46
TIMETASK_66:            /* again in 5000 ms */
    movel %d7,%d0
    movew #5000,%d0
    moveal %a4@(416),%a0	/* vector +416: SETTIMER */
    jsr %a0@
TIMETASK_72:            /* restore registers, return */
    moveml %sp@+,%d0-%a5
    rts

/*
 SCSIDT: the deferred task that runs the asynchronous SCSI Manager: handles the events
 MESSAGE recorded (+600), starts queued requests (FIND, ARB, SETUP, SEL) and then drives
 the bus through its phases: for each REQ the phase bits of the 5380 select a phase
 routine (table at +132: data out, data in, command, status, -, -, message out,
 message in) until the request ends or disconnects. Loops while new events arrive;
 finally sets the timer and re-enables the SCSI interrupt.
*/
SCSIDT:
    moveml %d0-%a5,%sp@-
    moveal SCSIGlobals,%a4
    moveq #0,%d7
    moveal %a4@(64),%a3
    moveal %a4@(88),%a5	/* a5 = the active request */
    movel %d7,%a4@(588)
    bclr #7,%a4@(125)	/* the deferred task may be installed again */
SCSIDT_1C:              /* events pending? with interrupts at level 2 or above, poll the chip: wait for its IRQ (BSR bit 4) and run the interrupt handler */
    tstl %a4@(600)
    jbne SCSIDT_3C
    movew %sr,%d0
    andiw #1792,%d0
    cmpiw #512,%d0
    jbcs SCSIDT_3C
SCSIDT_2E:              /* wait for the chip's interrupt */
    btst #4,%a3@(80)
    jbeq SCSIDT_2E
    moveal %a4@(356),%a0	/* vector +356: SCSIINTHND */
    jsr %a0@
SCSIDT_3C:              /* event 3: bus reset: fail every queued request with -476 (the old interface's with -1) */
    bclr #3,%a4@(600)
    jbeq SCSIDT_BE
    lea %a4@(80),%a5
    lea %a4@(676),%a1
    movew #-476,%d0	/* bus reset */
SCSIDT_50:              /* next queued request: fail it */
    moveal %a4@(408),%a0
    moveal %a5@,%a5
    cmpl %a5,%d7
    jbeq SCSIDT_30A
    cmpal %a1,%a5
    jbeq SCSIDT_64
    jsr %a0@
    jbra SCSIDT_50
SCSIDT_64:              /* the internal SCSIGet request: d0 = -1 */
    moveq #-1,%d1
    exg %d0,%d1
    jsr %a0@
    exg %d0,%d1
    jbra SCSIDT_50
    .short  0x4E71, 0x4E71, 0x4E71	| 40807F3A
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 40807F40
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 40807F50
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 40807F60
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 40807F70
    .short  0x4E71, 0x4E71, 0x4E71, 0x4E71, 0x4E71	| 40807F80
SCSIDT_BE:              /* event 7: reselection: wait for SEL to go (CSR bit 1), release BSY, then the phases */
    bclr #7,%a4@(600)
    jbeq SCSIDT_D6
SCSIDT_C6:              /* SEL still asserted? */
    btst #1,%a3@(64)
    jbne SCSIDT_C6
    moveb %d7,%a3@(16)
    jbra SCSIDT_2BE
SCSIDT_D6:              /* event 6: end of DMA: with the SCSI DMA chip check its status (+128, +192), else the DMA routine (+432) */
    bclr #6,%a4@(600)
    jbeq SCSIDT_166
    btst #4,%a4@(103)
    jbeq SCSIDT_162
    bclr #0,%a4@(125)
    movel %a3@(128),%d0
    btst #8,%d0
    jbne SCSIDT_FE
    movel %a3@(192),%d0
    jbeq SCSIDT_152
SCSIDT_FE:              /* (DMA chip handling, patched out with nop) */
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
SCSIDT_134:             /* then the phases */
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    jbra SCSIDT_2BE
SCSIDT_152:             /* the data DMA routine (+432); the request ended (+125 bit 0)? done */
    moveal %a4@(432),%a0	/* vector +432: DATADMA */
    jsr %a0@
    btst #0,%a4@(125)
    jbne SCSIDT_30A
SCSIDT_162:             /* then the phases */
    jbra SCSIDT_2BE
SCSIDT_166:             /* event 5: phase change: mode register 0 (DMA off), then the phases */
    bclr #5,%a4@(600)
    jbeq SCSIDT_1C6
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
SCSIDT_1B4:             /* mode register 0 */
    nop
    nop
    nop
    nop
    nop
    moveb %d7,%a3@(32)
    jbra SCSIDT_2BE
SCSIDT_1C6:             /* event 1: a new request: start one */
    bclr #1,%a4@(600)
    jbeq SCSIDT_1D0
    jbra SCSIDT_236
SCSIDT_1D0:             /* event 4: bus free: mode 0, start the next request */
    bclr #4,%a4@(600)
    jbeq SCSIDT_1DE
    moveb %d7,%a3@(32)
    jbra SCSIDT_236
SCSIDT_1DE:             /* event 2: parity error */
    bclr #2,%a4@(600)
    jbeq SCSIDT_236
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
SCSIDT_236:             /* start a request (interrupts off): FIND the next one, give it a private block from the free list (+60), arbitrate (+396) */
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #-1,%d0
    moveal %a4@(380),%a0	/* vector +380: FIND */
    jsr %a0@
    beqw SCSIDT_298
    moveal %d0,%a5
    tstl %a5@(4)
    jbne SCSIDT_27A
    movel %a4@(60),%d0
    jbeq SCSIDT_298
    moveal %d0,%a0
    movel %a0,%a5@(4)
    moveb #1,%a0@(4)
    movel %d7,%a4@(60)
    lea %a4@(56),%a1
SCSIDT_26A:             /* the next free block becomes the list head */
    moveal %a1@,%a1
    cmpl %a1,%d7
    jbeq SCSIDT_27A
    tstb %a1@(4)
    jbne SCSIDT_26A
    movel %a1,%a4@(60)
SCSIDT_27A:             /* arbitration lost: give the block back */
    moveal %a4@(396),%a0	/* vector +396: ARB */
    jsr %a0@
    jbeq SCSIDT_29C
    moveal %a5@(4),%a0
    moveb %d7,%a0@(4)
    movel %d7,%a5@(4)
    tstl %a4@(60)
    jbne SCSIDT_298
    movel %a0,%a4@(60)
SCSIDT_298:             /* interrupts back on */
    movew %sp@+,%sr
    jbra SCSIDT_2FE
SCSIDT_29C:             /* won: set it up (+384) and select it (+400); selection failed: log the error (+372) */
    movew %sp@+,%sr
    moveal %a5@(4),%a0
    movel %a5@(48),%a0@(12)
    moveal %a4@(384),%a0	/* vector +384: SETUP */
    jsr %a0@
    moveal %a4@(400),%a0	/* vector +400: SEL */
    jsr %a0@
    jbeq SCSIDT_2BE
    moveal %a4@(372),%a0	/* vector +372: LOGERROR */
    jsr %a0@
    jbra SCSIDT_2FE
SCSIDT_2BE:             /* the phase loop: while BSY */
    movel %d7,%d0
SCSIDT_2C0:             /* wait for REQ; phase = CSR bits 4-2 (MSG, C/D, I/O) */
    moveb %a3@(64),%d0
    btst #6,%d0	/* BSY: still connected? */
    jbeq SCSIDT_2FE
    btst #5,%d0	/* REQ */
    jbeq SCSIDT_2C0
    andib #28,%d0	/* the phase (MSG, C/D, I/O) * 4: its vector */
    lea %a4@(132),%a0
    moveal %a0@(0x0,%d0:w),%a0
    lsrb #2,%d0
    moveb %d0,%a3@(48)
    addiw #16,%d0
    cmpl %a5,%d7
    jbeq SCSIDT_2EE
    movew %d0,%a5@(14)
SCSIDT_2EE:             /* TCR = the phase, request state = 16 + phase; call the phase routine */
    jsr %a0@
    btst #0,%a4@(125)
    jbne SCSIDT_2FE
    tstl %a4@(88)
    jbne SCSIDT_2BE
SCSIDT_2FE:             /* disconnected targets? enable reselection (select enable = our ID) */
    tstb %a4@(124)
    jbeq SCSIDT_30A
    moveb %a4@(96),%a3@(64)
SCSIDT_30A:             /* a request waiting at +104 and interrupts at level 2+? loop */
    tstl %a4@(104)
    jbeq SCSIDT_31C
    movew %sr,%d0
    andiw #1792,%d0
    cmpiw #512,%d0
    jbcc SCSIDT_340
SCSIDT_31C:             /* more events, or a request that can start? loop */
    tstl %a4@(600)
    jbne SCSIDT_340
    btst #0,%a4@(125)
    jbne SCSIDT_344
    tstl %a4@(60)
    jbeq SCSIDT_344
    tstl %a4@(80)
    jbeq SCSIDT_344
    moveq #-1,%d0
    moveal %a4@(380),%a0	/* vector +380: FIND */
    jsr %a0@
    jbeq SCSIDT_344
SCSIDT_340:             /* again */
    jbra SCSIDT_1C
SCSIDT_344:             /* no active request: the timer (5000 ms if requests are queued, else off) */
    tstl %a4@(88)
    jbne SCSIDT_35C
    moveal %a4@(416),%a0
    movel %d7,%d0
    tstl %a4@(80)
    jbeq SCSIDT_35A
    movew #5000,%d0
SCSIDT_35A:             /* set the timer */
    jsr %a0@
SCSIDT_35C:             /* re-enable the SCSI interrupt, restore registers, return */
    moveq #1,%d0
    moveal %a4@(368),%a0	/* vector +368: DISENABLE */
    jsr %a0@
    moveml %sp@+,%d0-%a5
    rts

/*
 COMMAND / STATUSPHASE / MSGIN... MSGNOOP: the phase and message routines of the
 asynchronous manager (the vectors at +132 and +228..+312). Parts of their code are
 still raw words.
*/
COMMAND:
    moveal %a5@(4),%a0
    moveal %a0@(12),%a2
    movel %d7,%d2
    moveb %a5@(47),%d2
    subql #1,%d2
COMMAND_10:
    moveb %a3@(64),%d0
    btst #6,%d0
    beqs COMMAND_74
    btst #5,%d0
    beqs COMMAND_10
    btst #3,%a3@(80)
    beqs COMMAND_70
    moveb %a2@+,%a3@
    moveb #1,%a3@(16)
    moveb #17,%a3@(16)
COMMAND_36:
    btst #6,%a3@(64)
    beqs COMMAND_74
    btst #5,%a3@(64)
    bnes COMMAND_36
    moveb %d7,%a3@(16)
    dbf %d2,COMMAND_10
    movel %d7,%d0
    movew TimeSCSIDB,%d0
    lsll #8,%d0
    movel %d0,%d2
    swap %d2
COMMAND_5A:
    btst #6,%a3@(64)
    beqs COMMAND_70
    btst #3,%a3@(80)
    dbeq %d0,COMMAND_5A
    dbeq %d2,COMMAND_5A
COMMAND_70:
    movel %a2,%a0@(12)
COMMAND_74:
    rts

/* STATUSPHASE: status phase. */
STATUSPHASE:
    moveb %a3@(64),%d0
    btst #6,%d0
    beqs STATUSPHASE_4A
    btst #5,%d0
    beqs STATUSPHASE
    btst #3,%a3@(80)
    beqs STATUSPHASE_4A
    moveb %a3@,%d0
    moveb #16,%a3@(16)
STATUSPHASE_20:
    btst #6,%a3@(64)
    beqs STATUSPHASE_4A
    btst #5,%a3@(64)
    bnes STATUSPHASE_20
    moveb %d7,%a3@(16)
    moveb %d0,%a5@(46)
    moveal %a5@(4),%a0
    btst #1,%a0@(4)
    bnes STATUSPHASE_4A
    bset #5,%a0@(4)
STATUSPHASE_4A:
    rts

/* MSGIN: message in phase: dispatch on the message. */
MSGIN:
    movel %d7,%d0
MSGIN_2:
    moveb %a3@(64),%d0
    btst #6,%d0
    beqs MSGIN_5A
    btst #5,%d0
    beqs MSGIN_2
    btst #3,%a3@(80)
    beqs MSGIN_5A
    moveb %a3@,%d0
    moveb #16,%a3@(16)
MSGIN_22:
    btst #5,%a3@(64)
    bnes MSGIN_22
    btst #7,%d0
    beqs MSGIN_3A
    moveb %d0,%d1
    moveal %a4@(232),%a0
    jsr %a0@
    bras MSGIN_52
MSGIN_3A:
    cmpib #35,%d0
    bhis MSGIN_5C
    lea %a4@(516),%a0
    moveb %a0@(0x0,%d0:l),%d0
    lea %a4@(228),%a0
    moveal %a0@(0x0,%d0:l),%a0
    jsr %a0@
MSGIN_52:
    btst #3,%a3@(80)
    bnes MSGIN
MSGIN_5A:
    rts
MSGIN_5C:
    moveal %a4@(228),%a0
    jsr %a0@
    bras MSGIN_52

/* MSGINVALIDIN: unknown message: reject it. */
MSGINVALIDIN:
    moveal %a5@(4),%a0
    moveb #1,%a0@(5)
    moveb #18,%a3@(16)
    moveb #2,%a3@(16)
    rts

/* MSGIDENTIFYIN: identify (reselection). */
MSGIDENTIFYIN:
    movel %d7,%d0
    moveb %a4@(603),%d0
    moveb %d7,%a4@(603)
    rolw #8,%d0
    andib #7,%d1
    bset %d1,%d0
    moveal %a4@(380),%a0
    jsr %a0@
    moveal %d0,%a5
    bnes MSGIDENTIFYIN_24
    moveal %a4@(424),%a0
    jsr %a0@
    rts
MSGIDENTIFYIN_24:
    movel %d7,%d0
    moveb %a5@(12),%d0
    moveb %a5@(13),%d1
    lea %a4@(116),%a0
    bclr %d1,%a0@(0x0,%d0:w)
    tstb %a0@(0x0,%d0:w)
    bnes MSGIDENTIFYIN_40
    bclr %d0,%a4@(124)
MSGIDENTIFYIN_40:
    moveal %a4@(384),%a0
    jsr %a0@
    moveal %a4@(248),%a0
    jmp %a0@

/* MSGCMDCOMPLETE: command complete. */
MSGCMDCOMPLETE:
    moveal %a5@(4),%a0
    btst #1,%a0@(4)
    bnew MSGCMDCOMPLETE_10E
    cmpl %a5@(40),%d7
    beqw MSGCMDCOMPLETE_194
    moveb %a5@(46),%d0
    andib #0x9e,%d0	| 408083DA
    btst #7,%d0
    bnew MSGCMDCOMPLETE_194
    cmpib #2,%d0
    bnew MSGCMDCOMPLETE_194
    lea %a4@(676),%a0
    movel %a5@(16),%a0@(16)
    movel %d7,%a5@(16)
    movel %a5@(32),%a0@(32)
    movel #2,%a5@(32)
    movel %a5@(36),%a0@(36)
    movel %d7,%a5@(36)
    lea %a4@(622),%a1
    moveb %a5@(44),%a1@(4)
    movel %a5@(48),%a0@(48)
    movel %a1,%a5@(48)
    movel %a5@(56),%a0@(56)
    movel %d7,%d0
    moveb %a5@(44),%d0
    movel %d0,%a5@(56)
    movel %a5@(60),%a0@(60)
    movel %d7,%a5@(60)
    lea %a4@(628),%a1
    movel %a5@(52),%a0@(52)
    movel %a1,%a5@(52)
    movel %a5@(40),%d0
    movel %d0,%a1@
    movel %d0,%a1@(12)
    lea %a1@(16),%a1
    movel %a5@(56),%d0
    movel %d0,%a1@(4)
    movel %d0,%a1@(12)
    movel %a5@(40),%a0@(40)
    movel %d7,%a5@(40)
    moveb %a5@(44),%a0@(44)
    moveb %d7,%a5@(44)
    moveb %a5@(46),%a0@(46)
    moveb #0xff,%a5@(46)	| 40808484
    moveal %a5@(4),%a1
    lea %a4@(740),%a0
    bset #1,%a1@(4)
    moveb %a1@(5),%a0@(5)
    clrb %a1@(5)
    movel %a1@(12),%a0@(12)
    movel %a5@(48),%a1@(12)
    movel %a1@(20),%a0@(20)
    movel %d7,%a1@(20)
    movel %a1@(24),%a0@(24)
    movel %d7,%a1@(24)
    movel %d7,%a4@(88)
    moveb %d7,%a3@(16)
    braw MSGCMDCOMPLETE_1C0
MSGCMDCOMPLETE_10E:
    lea %a4@(676),%a0
    movel %a0@(16),%a5@(16)
    movel %a0@(32),%a5@(32)
    movel %a0@(36),%a5@(36)
    movel %a0@(48),%a5@(48)
    movel %a0@(40),%a5@(40)
    moveb %a0@(44),%a5@(44)
    movel %a5@(60),%d0
    moveb %d0,%a5@(45)
    movel %a0@(56),%a5@(56)
    movel %a0@(60),%a5@(60)
    movel %a0@(52),%a5@(52)
    moveb %a5@(46),%d0
    moveb %a0@(46),%a5@(46)
    andib #0x9e,%d0	| 4080851A
    btst #7,%d0
    bnes MSGCMDCOMPLETE_16E
    cmpib #2,%d0
    bnes MSGCMDCOMPLETE_16E
    moveb %d7,%a5@(45)
MSGCMDCOMPLETE_16E:
    moveal %a5@(4),%a1
    lea %a4@(740),%a0
    bclr #1,%a1@(4)
    moveb %a0@(5),%a1@(5)
    movel %a0@(12),%a1@(12)
    movel %a0@(20),%a1@(20)
    movel %a0@(24),%a1@(24)
MSGCMDCOMPLETE_194:
    moveq #0,%d0
    moveal %a5@(4),%a0
    btst #5,%a0@(4)
    bnes MSGCMDCOMPLETE_1A6
    movew #-478,%d0
MSGCMDCOMPLETE_1A6:
    moveb %d7,%a3@(16)
    moveal %a4@(408),%a0
    jsr %a0@
MSGCMDCOMPLETE_1B0:
    movel %a5@(36),%d0
    beqs MSGCMDCOMPLETE_1C0
    moveal %d0,%a5
    movew #-479,%d0
    jsr %a0@
    bras MSGCMDCOMPLETE_1B0
MSGCMDCOMPLETE_1C0:
    rts

/* MSGSAVEDATAPTR: save data pointer. */
MSGSAVEDATAPTR:
    moveal %a5@(52),%a0
    cmpl %a0,%d7
    beqs MSGSAVEDATAPTR_2A
    moveal %a5@(4),%a1
    movel %a1@(24),%a1@(20)
    moveq #-1,%d0
MSGSAVEDATAPTR_14:
    movel %a0@,%d1
    beqs MSGSAVEDATAPTR_2A
    cmpl %d0,%d1
    bnes MSGSAVEDATAPTR_20
    movel %a0@(4),%d1
MSGSAVEDATAPTR_20:
    movel %d1,%a0@(12)
    lea %a0@(16),%a0
    bras MSGSAVEDATAPTR_14
MSGSAVEDATAPTR_2A:
    moveb %d7,%a3@(16)
    rts

/* MSGRESTOREPTRS: restore pointers. */
MSGRESTOREPTRS:
    moveal %a5@(4),%a0
    movel %a5@(48),%a0@(12)
    movel %a0@(20),%a0@(24)
    moveal %a5@(52),%a0
    cmpl %a0,%d7
    beqs MSGRESTOREPTRS_34
    moveq #-1,%d0
MSGRESTOREPTRS_1A:
    movel %a0@(12),%d3
    movel %a0@,%d1
    beqs MSGRESTOREPTRS_34
    cmpl %d0,%d1
    bnes MSGRESTOREPTRS_2C
    movel %d3,%a0@(4)
    bras MSGRESTOREPTRS_2E
MSGRESTOREPTRS_2C:
    movel %d3,%a0@
MSGRESTOREPTRS_2E:
    lea %a0@(16),%a0
    bras MSGRESTOREPTRS_1A
MSGRESTOREPTRS_34:
    moveb %d7,%a3@(16)
    rts

/* MSGDISCONNECT: disconnect. */
MSGDISCONNECT:
    movel %d7,%d1
    moveb %a5@(12),%d1
    moveb %a5@(13),%d0
    bset %d1,%a4@(124)
    lea %a4@(116),%a0
    bset %d0,%a0@(0x0,%d1:w)
    movel %d7,%a4@(88)
    movew #4,%a5@(14)
    moveb %d7,%a3@(16)
    rts

/* MSGMSGREJIN: message reject received. */
MSGMSGREJIN:
    moveb %d7,%a3@(16)
    rts
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

/* MSGLCCF: linked command complete. */
MSGLCCF:
    moveq #0,%d0
    moveal %a5@(4),%a0
    btst #5,%a0@(4)
    bnes MSGLCCF_12
    movew #-478,%d0
MSGLCCF_12:
    moveb %d7,%a3@(16)
    moveal %a4@(408),%a0
    jsr %a0@
    rts
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

/* MSGOUT: message out phase. */
MSGOUT:
    moveq #4,%d0
    tstl %a4@(88)
    beqs MSGOUT_32
MSGOUT_8:
    btst #6,%a3@(64)
    beqs MSGOUT_46
    btst #5,%a3@(64)
    beqs MSGOUT_8
    btst #3,%a3@(80)
    beqs MSGOUT_46
    moveal %a5@(4),%a0
    movel %d7,%d0
    moveb %a0@(5),%d0
    cmpib #35,%d0
    blss MSGOUT_32
    moveq #2,%d0
MSGOUT_32:
    lea %a4@(552),%a0
    moveb %a0@(0x0,%d0:l),%d0
    lea %a4@(228),%a0
    moveal %a0@(0x0,%d0:l),%a0
    jsr %a0@
    bras MSGOUT
MSGOUT_46:
    rts

/* MSGIDENTIFYOUT: send identify. */
MSGIDENTIFYOUT:
    moveb %a5@(13),%d1
    .short  0x0001, 0x00C0	| orib #-64,%d1
    movel %a5@(32),%d0
    btst #7,%d0
    bnes MSGIDENTIFYOUT_18
    btst #1,%d0
    beqs MSGIDENTIFYOUT_1C
MSGIDENTIFYOUT_18:
    bclr #6,%d1
MSGIDENTIFYOUT_1C:
    moveb %d1,%a3@
    moveb %d7,%a3@(16)
    moveb #1,%a3@(16)
    moveb #17,%a3@(16)
MSGIDENTIFYOUT_2E:
    btst #5,%a3@(64)
    bnes MSGIDENTIFYOUT_2E
    moveb %d7,%a3@(16)
    moveal %a5@(4),%a0
    moveb #4,%a0@(5)
    rts

/* MSGMSGREJOUT: send message reject. */
MSGMSGREJOUT:
    moveb #7,%a3@
    moveb %d7,%a3@(16)
    moveb #1,%a3@(16)
    moveb #17,%a3@(16)
MSGMSGREJOUT_14:
    btst #5,%a3@(64)
    bnes MSGMSGREJOUT_14
    moveb %d7,%a3@(16)
    moveal %a5@(4),%a0
    moveb #4,%a0@(5)
    rts

/* MSGINVALIDOUT: nothing to send: no-operation. */
MSGINVALIDOUT:
    rts
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

/* MSGBUSDEVRST: bus device reset. */
MSGBUSDEVRST:
    rts	| 408087E0

/* MSGKILLIO: abort. */
MSGKILLIO:
    moveal %a4@(420),%a0
    jsr %a0@
    rts
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

/* MSGNOOP: no-operation. */
MSGNOOP:
    moveb #8,%a3@
    moveb #1,%a3@(16)
    moveb #17,%a3@(16)
MSGNOOP_10:
    btst #5,%a3@(64)
    bnes MSGNOOP_10
    moveb %d7,%a3@(16)
    rts

/*
 DATAIO: the data phase by programmed I/O for the active request: the direction of the
 phase must agree with the request's flags (-472 if not; -471 if there is no buffer
 or the data would overrun its length). The data goes through the scatter/gather
 list (+52; 16-byte entries: address, count, increment, working count; address -1 =
 a loop entry) and the transfer routine (+412); the position is kept in the private
 block (+24 entry offset, +28 bytes done in it) so a disconnect can resume.
*/
DATAIO:
    movew #-471,%d0	/* no buffer */
    tstl %a5@(56)
    jbeq DATAIO_2A
    moveq #28,%d4	/* the transfer type from the flags */
    andl %a5@(32),%d4
    moveal %a5@(4),%a0
    movel %a0@(24),%d5
    btst #2,%a3@(64)	/* I/O: data in */
    jbne DATAIO_34
    btst #2,%d4
    jbne DATAIO_54
DATAIO_26:              /* -472: wrong direction */
    movew #-472,%d0	/* wrong direction */
DATAIO_2A:              /* log the error, end */
    moveal %a4@(372),%a0	/* vector +372: LOGERROR */
    jsr %a0@
    jbra DATAIO_11C
DATAIO_34:              /* data in: mode = DMA mode, start initiator receive */
    btst #2,%d4
    jbne DATAIO_26
    moveb #2,%a3@(32)
    btst #4,%a4@(103)
    jbeq DATAIO_50
    movel #8,%a3@(128)
DATAIO_50:              /* start initiator receive */
    moveb %d7,%a3@(112)
DATAIO_54:              /* a1 = the scatter list */
    moveal %a5@(52),%a1
DATAIO_58:              /* the current entry: d2 = count, a2 = address (0: end, -1: loop entry) */
    movel %a1@(0x4,%d5:l),%d2
    movel %a1@(0x0,%d5:l),%d0
    jbeq DATAIO_108
    moveal %d0,%a2
    addql #1,%d0
    beqw DATAIO_E8
DATAIO_6C:              /* wait for REQ or DMA request */
    btst #6,%a3@(80)
    jbne DATAIO_7C
    btst #5,%a3@(64)
    jbeq DATAIO_6C
DATAIO_7C:              /* still in the data phase (phase match)? continue in the entry */
    btst #3,%a3@(80)
    jbeq DATAIO_108
    movel %a0@(28),%d0
    jbeq DATAIO_90
    subl %d0,%d2
    addal %d0,%a2
DATAIO_90:              /* would it overrun the request's length? -471 */
    movel %a5@(60),%d0
    addl %d2,%d0
    cmpl %a5@(56),%d0
    jbls DATAIO_A8
    movew #-471,%d0	/* overrun */
    moveal %a4@(372),%a0	/* vector +372: LOGERROR */
    jsr %a0@
    jbra DATAIO_108
DATAIO_A8:              /* transfer (vector +412); count the bytes done */
    moveal %a4@(412),%a0	/* vector +412: TRANSFER; 53C96 BIOS: TRANSFER_96_BIOS */
    jsr %a0@
    tstw %d0
    jbne DATAIO_108
    btst #0,%a4@(125)
    jbne DATAIO_11C
    moveal %a5@(4),%a0
    addl %d1,%a5@(60)
    cmpl %d1,%d2
    jbeq DATAIO_CC
    addl %d1,%a0@(28)
    jbra DATAIO_58
DATAIO_CC:              /* entry done: advance its address by its increment, next entry */
    movel %a1@(0x8,%d5:l),%d0
    addl %d0,%a1@(0x0,%d5:l)
    movel %d7,%a0@(28)
DATAIO_D8:              /* next entry (16 bytes) */
    moveq #16,%d0
    addl %d0,%d5
    moveal %a5@(4),%a0
    movel %d5,%a0@(24)
    jbra DATAIO_58
DATAIO_E8:              /* loop entry: count down, back by its increment */
    tstl %d2
    jbeq DATAIO_D8
    subql #1,%d2
    movel %d2,%a1@(0x4,%d5:l)
    jbeq DATAIO_D8
    movel %a1@(0x8,%d5:l),%d0
    asll #4,%d0
    addl %d0,%d5
    moveal %a5@(4),%a0
    movel %d5,%a0@(24)
    jbra DATAIO_58
DATAIO_108:             /* mode register 0 (and the DMA chip) */
    moveb %d7,%a3@(32)
    btst #4,%a4@(103)
    jbeq DATAIO_11C
    movel #2,%a3@(128)
DATAIO_11C:             /* return 0 */
    moveq #0,%d0
    rts

/* DATADMA: the data phase by DMA (on machines with a SCSI DMA chip). */
DATADMA:
    moveal %a5@(52),%a1
    moveal %a5@(4),%a0
    lea %a0@(32),%a2
    movel %a0@(24),%d5
    movel %a2@(12),%d1
    addl %d1,%a5@(60)
    tstl %a2@(4)
    beqs DATADMA_24
    addl %d1,%a0@(28)
    bras DATADMA_38
DATADMA_24:
    movel %a1@(0x8,%d5:l),%d0
    addl %d0,%a1@(0x0,%d5:l)
    movel %d7,%a0@(28)
DATADMA_30:
    moveq #16,%d0
    addl %d0,%d5
    movel %d5,%a0@(24)
DATADMA_38:
    movel %a1@(0x4,%d5:l),%d2
    movel %a1@(0x0,%d5:l),%d0
    beqw DATADMA_BE
    moveal %d0,%a2
    addql #1,%d0
    beqw DATADMA_9E
DATADMA_4C:
    btst #6,%a3@(80)
    bnes DATADMA_5C
    btst #5,%a3@(64)
    beqs DATADMA_4C
DATADMA_5C:
    btst #3,%a3@(80)
    beqw DATADMA_BE
    movel %a0@(28),%d0
    beqs DATADMA_70
    subl %d0,%d2
    addal %d0,%a2
DATADMA_70:
    movel %a5@(60),%d0
    addl %d2,%d0
    cmpl %a5@(56),%d0
    blss DATADMA_88
    movew #-471,%d0
    moveal %a4@(372),%a0
    jsr %a0@
    bras DATADMA_BE
DATADMA_88:
    moveq #0,%d0
    movel %d2,%d1
    beqs DATADMA_24
    moveq #28,%d4
    andl %a5@(32),%d4
    lea %a4@(164),%a0
    moveal %a0@(0x0,%d4:l),%a0
    jmp %a0@
DATADMA_9E:
    tstl %d2
    beqs DATADMA_30
    subql #1,%d2
    movel %d2,%a1@(0x4,%d5:l)
    beqs DATADMA_30
    movel %a1@(0x8,%d5:l),%d0
    asll #4,%d0
    addl %d0,%d5
    moveal %a5@(4),%a0
    movel %d5,%a0@(24)
    braw DATADMA_38
DATADMA_BE:
    moveb %d7,%a3@(32)
    movel #2,%a3@(128)
    moveq #0,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40808A46

/* SCSIHW / CLEARIRQ: clear the chip's interrupt. */
SCSIHW:
CLEARIRQ:
    moveb %a3@(112),%d1
    braw CLEARSCSIINT

/*
 DISENABLE (d0 = 0 disable, else enable): the SCSI interrupt (ENABLESCSIINTS,
 DISABLESCSIINTS).
*/
DISENABLE:
    tstl %d0
    jbeq DISENABLE_8
    jbra ENABLESCSIINTS
DISENABLE_8:            /* disable */
    jbra DISABLESCSIINTS

/*
 BUSERRHANDLER: bus error during a blind transfer (the chip did not answer the
 handshake in time): wait a moment (TimeDBRA / 16) and retry the access (rte).
*/
BUSERRHANDLER:
    subqw #1,%fp@(-6)	| 40808A64
    beqs BUSERRHANDLER_E_8
    movel %d0,%sp@-
    movew TimeDBRA,%d0	| 40808A6C
    lsrw #4,%d0	| 40808A70
BUSERRHANDLER_E:        /* wait */
    dbf %d0,BUSERRHANDLER_E	| 40808A72
    movel %sp@+,%d0	| 40808A76
    rte	| 40808A78
BUSERRHANDLER_E_8:
    movew %sp@,%d0	| 40808A7A
    bfextu %sp@(6),0,4,%d1
    braw VFASTWRITEOSS_3E_8+0xe
BUSERRHANDLER_E_14:
    bnes BUSERRHANDLER_E_1C	| 40808A86
    lea %sp@(32),%sp
    bras BUSERRHANDLER_E_20
BUSERRHANDLER_E_1C:
    lea %sp@(92),%sp	| 40808A8E
BUSERRHANDLER_E_20:
    movew %d7,%sp@-	| 40808A92
    pea %pc@(BUSERRHANDLER_E_2A)
    movew %d0,%sp@-
    rte
BUSERRHANDLER_E_2A:
    .byte   0x60, 0xFF, 0x00, 0x08, 0xFC, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40808A9C

/*
 ARB: arbitration for the asynchronous manager. With the SCSI DMA chip (flags bits 1 and
 4) the chip arbitrates (control +128, wait, bit 13 = won); else as ARBITRATE: our ID,
 arbitrate, after the arbitration delay (+404) check lost arbitration and higher IDs.
 Out: 0, or 3 (lost: try later).
*/
ARB:
    moveml %d1-%d2/%a0-%a3,%sp@-
    .short  0x3B7C	| 40808AAC
    orib #14,%d2
    moveq #0,%d0
    btst #1,%a4@(103)
    jbeq ARB_5C
    btst #4,%a4@(103)
    jbeq ARB_5C
    movel #-1,%a3@(320)	/* DMA chip: arbitrate */
    movel %a4@(108),%a3@(128)
    moveb #1,%a3@(32)
    movew TimeDBRA,%d2
    lsrw #6,%d2
ARB_36:                 /* arbitration delay (TimeDBRA / 64) */
    dbf %d2,ARB_36
    movel %a3@(128),%d1
    btst #13,%d1
    jbeq ARB_52
    moveb %a3@(112),%d1
    movel #2,%a3@(128)
    jbra ARB_9C
ARB_52:                 /* lost */
    movel #2,%a3@(128)
    jbra ARB_90
ARB_5C:                 /* 5380: our ID on the bus, arbitrate */
    moveb %a4@(96),%a3@
    moveb #1,%a3@(32)
    btst #6,%a3@(16)
    jbeq ARB_90
    moveal %a4@(404),%a0	/* vector +404: DELAY22 */
    jsr %a0@
    btst #5,%a3@(16)
    jbne ARB_90
    moveb %a4@(96),%d2
    moveb %a3@,%d1
    eorb %d2,%d1
    cmpb %d2,%d1
    jbhi ARB_90
    btst #5,%a3@(16)
    jbeq ARB_9C
ARB_90:                 /* lost: mode 0, select enable for reselection, 3 */
    jbsr VFASTWRITEOSS_32
    moveb #4,%a3@(32)
    moveq #3,%d0
ARB_9C:                 /* restore registers, return */
    moveml %sp@+,%d1-%d2/%a0-%a3
    tstl %d0
    rts

/*
 SEL: select the active request's target (+12) with ATN (an identify message follows):
 state 3, BSY+SEL+ATN, our ID and the target's on the bus, release BSY, wait for the
 target's BSY within its select timeout (+30, ms); if it does not come, release SEL
 and wait 1/4 ms once more: -474 (selection timeout).
*/
SEL:
    moveml %d1-%a5,%sp@-
    movew #3,%a5@(14)	/* state 3: selecting */
    moveb #12,%a3@(16)
    moveb %d7,%a3@(32)
    moveal %a4@(404),%a0	/* vector +404: DELAY22 */
    jsr %a0@
    moveb %d7,%a3@(48)
    moveq #1,%d1
    moveb %a5@(12),%d2
    lslb %d2,%d1
    orb %a4@(96),%d1
    moveb %d1,%a3@
    moveb #15,%a3@(16)	/* BSY, SEL, ATN, data bus */
    moveb %d7,%a3@(64)
    movel %d7,%d0
    moveal %a4@(368),%a0	/* vector +368: DISENABLE */
    jsr %a0@
    moveb #7,%a3@(16)	/* release BSY */
    moveal %a4@(404),%a0	/* vector +404: DELAY22 */
    jsr %a0@
    movew %a5@(30),%d2	/* its select timeout (ms) */
    muluw TimeSCSIDB,%d2
    movel %d2,%d0
    swap %d0
SEL_56:                 /* wait for BSY */
    btst #6,%a3@(64)
    dbne %d2,SEL_56
    dbne %d0,SEL_56
    jbne SEL_88
    moveb #4,%a3@(16)	/* release the data bus, keep SEL */
    movew TimeSCSIDB,%d2
    lsrw #2,%d2
SEL_72:                 /* the last wait after releasing SEL */
    dbf %d2,SEL_72
    btst #6,%a3@(64)
    jbne SEL_88
    movew #-474,%d0	/* selection timeout */
    moveb %d7,%a3@(16)
    jbra SEL_96
SEL_88:                 /* selected: keep ATN only */
    moveal %a4@(404),%a0	/* vector +404: DELAY22 */
    jsr %a0@
    moveb #2,%a3@(16)
    moveq #0,%d0
SEL_96:                 /* restore registers, return (d0 tested) */
    moveml %sp@+,%d1-%a5
    tstl %d0
    rts

/* DELAY22: the 2.2 microsecond arbitration delay (TimeSCSIDB loops). */
DELAY22:
    moveal VIA,%a0
    tstb %a0@(6656)
    tstb %a0@(6656)
    tstb %a0@(6656)
    rts

/*
 SCSIINTHND: the SCSI interrupt handler of the asynchronous manager (5380): from the
 bus and status register and the current bus status (d0 = BSR << 8 | CSR) it
 recognises a reselection (7: SEL with our ID on the bus; answered with BSY), the end
 of a DMA (6), a phase change (5), bus free / busy error (4) or a parity error (2),
 and passes it to MESSAGE for the deferred task. With the SCSI DMA chip a DMA error
 fails the request (-473). The interrupt is cleared and re-enabled.
*/
SCSIINTHND:
    moveml %d0-%a5,%sp@-
    moveal SCSIGlobals,%a4
    moveal %a4@(88),%a5
    moveq #0,%d7
    movel %d7,%d0
    moveal %a4@(368),%a0	/* vector +368: DISENABLE */
    jsr %a0@
    moveal %a4@(64),%a3
    movew %sr,%sp@-
    oriw #1792,%sr
    moveb %a3@(80),%d0
    btst #4,%d0	/* BSR: interrupt request? */
    jbeq SCSIINTHND_C6
    lslw #8,%d0
    moveb %a3@(64),%d0
    movew %d0,%d1
    andiw #-2590,%d1
    cmpiw #4098,%d1	/* SEL alone: (re)selection */
    jbne SCSIINTHND_62
    moveb %a3@,%d1
    jbeq SCSIINTHND_C6
    moveb %a4@(96),%d0	/* our ID among those on the bus? */
    eorb %d0,%d1
    beqw SCSIINTHND_C6
    moveb %d7,%a3@(64)
    moveb %a3@(16),%d0
    orib #8,%d0	/* answer with BSY */
    moveb %d0,%a3@(16)
    moveq #7,%d0
    jbra SCSIINTHND_B6
SCSIINTHND_62:          /* end of DMA (BSR end-of-DMA + IRQ, BSY): 6 */
    movew %d0,%d1
    andiw #-2366,%d1
    cmpiw #-28608,%d1
    jbne SCSIINTHND_7A
    moveb %d7,%a3@(32)
    moveb %d7,%a3@(16)
    moveq #6,%d0
    jbra SCSIINTHND_B6
SCSIINTHND_7A:          /* phase change (REQ, no phase match): 5 */
    movew %d0,%d1
    andiw #-16926,%d1
    cmpiw #4192,%d1
    jbne SCSIINTHND_8A
    moveq #5,%d0
    jbra SCSIINTHND_B6
SCSIINTHND_8A:          /* busy error (bus free): 4 */
    movew %d0,%d1
    andiw #-2049,%d1
    cmpiw #5120,%d1
    jbne SCSIINTHND_9A
    moveq #4,%d0
    jbra SCSIINTHND_B6
SCSIINTHND_9A:          /* interrupt with nothing to report */
    movew %d0,%d1
    andiw #-2177,%d1
    cmpiw #4096,%d1
    jbne SCSIINTHND_A8
    jbra SCSIINTHND_C6
SCSIINTHND_A8:          /* parity error: 2 */
    movew %d0,%d1
    andiw #-17214,%d1
    cmpiw #14400,%d1
    jbne SCSIINTHND_C6
    moveq #2,%d0
SCSIINTHND_B6:          /* record the event (+360 MESSAGE), clear the interrupt (+364) */
    moveal %a4@(360),%a0	/* vector +360: MESSAGE */
    jsr %a0@
    moveal %a4@(364),%a0	/* vector +364: CLEARIRQ */
    jsr %a0@
    movew %sp@+,%sr
    jbra SCSIINTHND_F8
SCSIINTHND_C6:          /* nothing for the state machine; DMA chip error? -473 */
    movew %sp@+,%sr
    btst #4,%a4@(103)
    jbeq SCSIINTHND_EA
    movel %a3@(128),%d0
    btst #7,%d0
    jbeq SCSIINTHND_EA
    movew #-473,%d0	/* DMA error */
    moveal %a4@(372),%a0	/* vector +372: LOGERROR */
    jsr %a0@
    moveq #-1,%d0
    movel %d0,%a3@(320)
SCSIINTHND_EA:          /* clear the interrupt, re-enable it */
    moveal %a4@(364),%a0	/* vector +364: CLEARIRQ */
    jsr %a0@
    moveq #1,%d0
    moveal %a4@(368),%a0	/* vector +368: DISENABLE */
    jsr %a0@
SCSIINTHND_F8:          /* restore registers, return */
    moveml %sp@+,%d0-%a5
    rts

/*
 TRANSFER (d2 = count, a2 = buffer, d4 = routine offset): run the transfer routine d4
 of the table at +164 with a1 = the bus and status register (d3 = 6: its DMA request
 bit) and the bus error vector set to +428 (blind transfers whose handshake times
 out). Out: d0 = 0 or the error, d1 = bytes not transferred.
*/
TRANSFER:
    linkw %fp,#-6
    jbsr PFASTWRITEOSS_4E
    nop
    moveq #0,%d0
    movel %d2,%d1
    jbeq TRANSFER_3C
    moveml %d2-%d6/%a1-%a5,%sp@-
    lea %a3@(80),%a1
    moveq #6,%d3	/* BSR bit 6: DMA request */
    movel BusErrorVector,%fp@(-4)
    movel %a4@(428),BusErrorVector	/* blind transfer timeouts */
    lea %a4@(164),%a0
    moveal %a0@(0x0,%d4:l),%a0
    jsr %a0@
    movel %fp@(-4),BusErrorVector
    moveml %sp@+,%d2-%d6/%a1-%a5
    tstw %d0
TRANSFER_3C:            /* return */
    unlk %fp
    rts

/*
 SLOWREAD / SLOWWRITE: polled transfers: each byte waits for the DMA request (BSR
 bit 6) and checks the phase; a phase change ends the transfer with 5 (scPhaseErr).
*/
SLOWREAD:
    moveal %a4@(68),%a0	| 40808D3A
    addaw #96,%a0
    subql #1,%d2
    movel %d2,%d5
    swap %d5
SLOWREAD_E:             /* wait for DMA request (or REQ without phase match: phase error) */
    btst %d3,%a1@
    jbne SLOWREAD_20
    btst #5,%a3@(64)
    jbeq SLOWREAD_E
    btst #3,%a1@
    jbeq SLOWREAD_36
SLOWREAD_20:            /* read a byte for each DMA request */
    btst %d3,%a1@
    jbeq SLOWREAD_30
    moveb %a0@,%a2@+
    dbf %d2,SLOWREAD_20
    dbf %d5,SLOWREAD_20
    jbra SLOWREAD_3A
SLOWREAD_30:            /* no request: still in the phase? */
    jbsr VFASTWRITEOSS_3E
    jbne SLOWREAD_20
SLOWREAD_36:            /* 5 (scPhaseErr) */
    moveq #5,%d0
    jbra SLOWREAD_50
SLOWREAD_3A:            /* wait for the end of the phase */
    btst #0,%a3@(80)
    jbeq SLOWREAD_50
    btst #5,%a3@(64)
    jbeq SLOWREAD_50
    btst #3,%a1@
    jbne SLOWREAD_3A
SLOWREAD_50:            /* d1 = bytes not transferred */
    swap %d5
    movew %d2,%d5
    addql #1,%d5
    subl %d5,%d1
    rts
SLOWWRITE:              /* (5: phase error exits) */
    .long   0x206C0044, 0xD0EC004C, 0x082B0005	| 40808D94
    .long   0x004067F8, 0x17470030, 0x177C0002, 0x0020177C	| 40808DA0
    .long   0x00010010, 0x082C0004, 0x00676708, 0x277C0000	| 40808DB0
    .short  0x000A, 0x0080, 0x1747, 0x0050, 0x0811, 0x0003, 0x6604	| 40808DC0
    moveq #5,%d0
    jbra SLOWWRITE_60
    movel %d2,%d1
    subql #1,%d2
    movel %d2,%d5
    swap %d5
SLOWWRITE_46:
    btst %d3,%a1@
    beqs SLOWWRITE_46_10	| 40808DDC
    moveb %a2@+,%a0@
    dbf %d2,SLOWWRITE_46
    dbf %d5,SLOWWRITE_46
    bras SLOWWRITE_60
SLOWWRITE_46_10:
    btst #3,%a1@	| 40808DEA
    bnes SLOWWRITE_46
    moveq #5,%d0
    jbra SLOWWRITE_84
SLOWWRITE_60:           /* wait until the last byte is taken */
    btst #4,%a4@(103)
    jbeq SLOWWRITE_76
SLOWWRITE_68:           /* DMA request or phase change */
    btst %d3,%a3@(80)
    jbne SLOWWRITE_84
    btst #3,%a3@(80)
    jbne SLOWWRITE_68
SLOWWRITE_76:           /* (the same without the DMA chip) */
    btst %d3,%a3@(80)
    jbne SLOWWRITE_84
    btst #3,%a3@(80)
    jbne SLOWWRITE_76
SLOWWRITE_84:           /* ICR and mode register 0 (DMA chip back to normal) */
    moveb %d7,%a3@(16)
    moveb %d7,%a3@(32)
    btst #4,%a4@(103)
    jbeq SLOWWRITE_9C
    movel #2,%a3@(128)
SLOWWRITE_9C:           /* d1 = bytes not transferred */
    swap %d5
    movew %d2,%d5
    addql #1,%d5
    subl %d5,%d1
    rts

/*
 VFASTWRITEOSS / PFASTWRITEOSS / PFASTWRITE / VFASTWRITE / FASTWRITE / FASTWRITEOSS:
 blind writes (pseudo-DMA: one write per byte to the DMA data address, without
 checking the handshake; a late byte causes a bus error, BUSERRHANDLER): variants for
 the OSS (IIfx) and for 68040 copy-back caches. Partly raw words.
*/
VFASTWRITEOSS:
    moveal %a5@(4),%a0
    lea %a0@(32),%a0
    movel %a2,%d0
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x554,%za0)@(0x0)	| 40808E44
    movel %d0,%a0@
    movel %d2,%a0@(4)
    moveq #1,%d0
    moveal %d0,%a1
    moveq #5,%d0
    _MemoryDispatch
    bnes VFASTWRITEOSS_30
    moveal %a0@(8),%a2
    movel %a0@(12),%d2
    movel %d2,%d1
    moveal %a4@(192),%a0
    jmp %a0@
VFASTWRITEOSS_30:
    rts

VFASTWRITEOSS_32:       /* end the request (+125 bit 0), mode 0 */
    bset #0,%a4@(125)
    moveb %d7,%a3@(32)
    rts

VFASTWRITEOSS_3E:       /* d6 = BSR phase match and DMA request bits */
    moveq #72,%d6
    andb %a3@(80),%d6
    rts
VFASTWRITEOSS_3E_8:
    bset #1,%a4@(125)
    movel %a4@(104),%a3@(320)
    rts
    cmpib #7,%d1
    beqs VFASTWRITEOSS_3E_8_1C
    cmpib #10,%d1
    braw BUSERRHANDLER_E_14	| 40808E98
VFASTWRITEOSS_3E_8_1C:
    lea %sp@(60),%sp
    braw BUSERRHANDLER_E_20	| 40808EA0
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
PFASTWRITEOSS:          /* the OSS variant for 68040 caches */
    moveq #0,%d0
    moveb %d7,%a3@(48)
    moveb #2,%a3@(32)
    moveb #1,%a3@(16)
    movel #8,%a3@(128)
    moveb %d7,%a3@(80)
    movel #-1,%a3@(320)
    movel #7,%a3@(128)
    movel %a2,%a3@(256)
    movel %d2,%a3@(192)
    moveb #10,%a3@(32)
    moveb #1,%a3@(16)
    moveb %d7,%a3@(80)
    bset #0,%a4@(125)
    rts

PFASTWRITEOSS_4E:       /* fp-6 = 1 on a 68040 (cache flush needed), else 5 */
    moveq #5,%d0
    cmpib #4,CPUFlag
    jbne PFASTWRITEOSS_5A
    moveq #1,%d0
PFASTWRITEOSS_5A:       /* (set) */
    movew %d0,%fp@(-6)
    rts
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71	| 40808F14
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 40808F20
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 40808F30
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 40808F40
    .short  0x4E71	| 40808F50
PFASTWRITE:             /* (68040 variant, shares the code below) */
    .short  0x4E75	| 40808F52
VFASTWRITE:
FASTWRITE:              /* (d6/d5: the counts for the unrolled loops) */
    moveal %a4@(72),%a0
    addaw %a4@(76),%a0
FASTWRITE_8:
    btst #5,%a3@(64)
    beqs FASTWRITE_8
    moveb %d7,%a3@(48)
    moveb #2,%a3@(32)
    moveb #1,%a3@(16)
    btst #4,%a4@(103)
    beqs FASTWRITE_30
    movel #10,%a3@(128)
FASTWRITE_30:
    moveb %d7,%a3@(80)
FASTWRITE_34:
    btst %d3,%a1@
    bnes FASTWRITE_4C
    btst #5,%a3@(64)
    beqs FASTWRITE_34
    btst #3,%a1@
    bnes FASTWRITE_34
    moveq #5,%d0
    braw VFASTWRITE_9C_14
FASTWRITE_4C:
    movel %d2,%d1
    moveq #3,%d4
    cmpl %d4,%d2
    bhis FASTWRITE_5A
    moveq #-1,%d5
    moveq #-1,%d6
    jbra VFASTWRITE_9C
FASTWRITE_5A:
    movel %a2,%d5
    negl %d5
    andl %d4,%d5
    subl %d5,%d2
    bras FASTWRITE_66
FASTWRITE_64:
    moveb %a2@+,%a0@
FASTWRITE_66:
    dbf %d5,FASTWRITE_64
    movel %d2,%d5
    lsrl #5,%d5
    bnes FASTWRITE_76
    moveq #-1,%d5
    moveq #-1,%d6
    jbra VFASTWRITE_9C
FASTWRITE_76:
    subql #1,%d5
    movel %d5,%d6
    swap %d6
    moveq #31,%d4
    andl %d4,%d2
FASTWRITE_80:
    movel %a2@+,%a0@
    movel %a2@+,%a0@
    movel %a2@+,%a0@
    movel %a2@+,%a0@
    movel %a2@+,%a0@
    movel %a2@+,%a0@
    movel %a2@+,%a0@
    movel %a2@+,%a0@
    dbf %d5,FASTWRITE_80
    dbf %d6,FASTWRITE_80
    bras VFASTWRITE_9C
VFASTWRITE_9A:          /* one byte */
    moveb %a2@+,%a0@
VFASTWRITE_9C:          /* next byte; d1 = bytes not transferred */
    dbf %d2,VFASTWRITE_9A
    swap %d6
    movew %d5,%d6
    addql #1,%d6
    lsll #5,%d6
    extl %d2
    addql #1,%d2
    addl %d2,%d6
    subl %d6,%d1
VFASTWRITE_9C_14:
    btst #4,%a4@(103)
    jbeq VFASTWRITE_C6
VFASTWRITE_B8:          /* wait until the chip has taken the last byte (DMA request or phase change) */
    btst %d3,%a3@(80)
    jbne VFASTWRITE_D4
    btst #3,%a3@(80)
    jbne VFASTWRITE_B8
VFASTWRITE_C6:          /* (the same without the DMA chip) */
    btst %d3,%a3@(80)
    jbne VFASTWRITE_D4
    btst #3,%a3@(80)
    jbne VFASTWRITE_C6
VFASTWRITE_D4:          /* mode and ICR 0 */
    moveb %d7,%a3@(32)
    moveb %d7,%a3@(16)
    btst #4,%a4@(103)
    jbeq VFASTWRITE_EC
    movel #2,%a3@(128)
VFASTWRITE_EC:          /* return */
    rts
FASTWRITEOSS:           /* (raw words: the OSS variant) */
    .short  0x200A, 0x4EB0, 0x81E1, 0x0554, 0x2F00, 0x4FEF, 0xFFEC	| 40809042
    .long   0x2E802F42	| 40809050
    .long   0x00046100 /* number, not a label difference (was INITOVERPATCH_24-.) */	| 40809054
    .short  0x00F0	| .short 0x00f0
    bnew FASTWRITEOSS_FC
    moveal %sp,%a0
    moveaw #1,%a1
    moveq #5,%d0
    _MemoryDispatch
    bnew FASTWRITEOSS_FC
FASTWRITEOSS_2A:
    btst #5,%a3@(64)
    beqs FASTWRITEOSS_2A
    moveb %d7,%a3@(48)
    moveb #2,%a3@(32)
    moveb #1,%a3@(16)
    moveq #8,%d5
    movel %d5,%a3@(128)
    moveb %d7,%a3@(80)
FASTWRITEOSS_4C:
    btst %d3,%a3@(80)
    bnes FASTWRITEOSS_68
    btst #5,%a3@(64)
    beqs FASTWRITEOSS_4C
    btst #3,%a3@(80)
    bnes FASTWRITEOSS_4C
    moveq #5,%d0
    braw FASTWRITEOSS_D0
FASTWRITEOSS_68:
    nop
    bsrw VFASTWRITEOSS_3E_8
    moveq #7,%d5
    movel %d5,%a3@(128)
    movel %a0@(8),%a3@(256)
    movel %a0@(12),%a3@(192)
    moveb #10,%a3@(32)
    moveb #1,%a3@(16)
    moveb %d7,%a3@(80)
    movel %a0@(4),%a0@(12)
    beqs FASTWRITEOSS_A4
    moveaw #1,%a1
    moveq #5,%d0
    _MemoryDispatch
    bnew FASTWRITEOSS_FC
FASTWRITEOSS_A4:
    moveal ghost_VIA2,%a1
FASTWRITEOSS_A8:
    btst #1,%a1@(514)
    beqs FASTWRITEOSS_A8
    movel %a3@(128),%d5
    andiw #384,%d5
    bnes FASTWRITEOSS_FC
    tstl %a3@(192)
    bnes FASTWRITEOSS_FC
    moveb %d7,%a3@(32)
    tstb %a3@(112)
    tstl %a0@(12)
    bnes FASTWRITEOSS_68
    movel %d2,%d1
FASTWRITEOSS_D0:
    btst #0,%a3@(80)
    beqs FASTWRITEOSS_E8
    btst #5,%a3@(64)
    beqs FASTWRITEOSS_E8
    btst #3,%a3@(80)
    bnes FASTWRITEOSS_D0
FASTWRITEOSS_E8:
    moveb %d7,%a3@(32)
    moveb %d7,%a3@(16)
    moveq #2,%d5
    movel %d5,%a3@(128)
    lea %sp@(20),%sp
    bras FASTWRITEOSS_102
FASTWRITEOSS_FC:
    moveq #9,%d0
    bras FASTWRITEOSS_E8
    rts
FASTWRITEOSS_102:
    braw VFASTREADOSS_30_2	| 40809144
FASTWRITEOSS_102_4:
    moveal %d0,%a0
    moveal %d2,%a1
    moveq #2,%d0
    _MemoryDispatch
    rts
    nop
    nop

/*
 VFASTREADOSS / PFASTREADOSS / PFASTREAD / VFASTREAD / FASTREAD / FASTREADOSS: blind
 reads, the same way.
*/
VFASTREADOSS:
    moveal %a5@(4),%a0
    lea %a0@(32),%a0
    movel %a2,%d0
    jsr @(0x554,%za0)@(0x0)	| 40809160
    movel %d0,%a0@
    movel %d2,%a0@(4)
    moveq #1,%d0
    moveal %d0,%a1
    moveq #5,%d0
    _MemoryDispatch
    bnes VFASTREADOSS_30
    moveal %a0@(8),%a2
    movel %a0@(12),%d2
    movel %d2,%d1
    moveal %a4@(188),%a0
    jmp %a0@
VFASTREADOSS_30:
    rts
VFASTREADOSS_30_2:
    bclr #1,%a4@(125)
    moveal %sp@+,%a0
    moveal %d2,%a1
    movew %d0,%sp@-
    moveq #3,%d0
    _MemoryDispatch
    movew %sp@+,%d0
    rts

/* DMAPENDINGPATCH: wait for a pending DMA before the next phase. */
DMAPENDINGPATCH:
    btst #7,%a4@(97)
    bnes DMAPENDINGPATCH_E
    btst #1,%a4@(125)
DMAPENDINGPATCH_E:
    rts
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
PFASTREADOSS:           /* the OSS variant for 68040 caches */
    moveq #0,%d0
    movel #-1,%a3@(320)
    movel #7,%a3@(128)
    movel %a2,%a3@(256)
    movel %d2,%a3@(192)
    moveb #10,%a3@(32)
    moveb %d7,%a3@(112)
    bset #0,%a4@(125)
    rts
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
PFASTREAD:              /* (68040 variant, shares the code below) */
    rts	| 4080924C
VFASTREAD:
FASTREAD:               /* (d6/d5: the counts for the unrolled loops) */
    moveal %a4@(72),%a0
    addaw #96,%a0
FASTREAD_8:
    btst %d3,%a1@
    bnes FASTREAD_20
    btst #5,%a3@(64)
    beqs FASTREAD_8
    btst #3,%a1@
    bnes FASTREAD_20
    moveq #5,%d0
    braw VFASTREAD_9A
FASTREAD_20:
    movel %d2,%d1
    moveq #3,%d4
    cmpl %d4,%d2
    bhis FASTREAD_2E
    moveq #-1,%d5
    moveq #-1,%d6
    jbra VFASTREAD_70
FASTREAD_2E:
    movel %a2,%d5
    negl %d5
    andl %d4,%d5
    subl %d5,%d2
    bras FASTREAD_3A
FASTREAD_38:
    moveb %a0@,%a2@+
FASTREAD_3A:
    dbf %d5,FASTREAD_38
    movel %d2,%d5
    lsrl #5,%d5
    bnes FASTREAD_4A
    moveq #-1,%d5
    moveq #-1,%d6
    jbra VFASTREAD_70
FASTREAD_4A:
    subql #1,%d5
    movel %d5,%d6
    swap %d6
    moveq #31,%d4
    andl %d4,%d2
FASTREAD_54:
    movel %a0@,%a2@+
    movel %a0@,%a2@+
    movel %a0@,%a2@+
    movel %a0@,%a2@+
    movel %a0@,%a2@+
    movel %a0@,%a2@+
    movel %a0@,%a2@+
    movel %a0@,%a2@+
    dbf %d5,FASTREAD_54
    dbf %d6,FASTREAD_54
    bras VFASTREAD_70
VFASTREAD_6E:           /* one byte */
    moveb %a0@,%a2@+
VFASTREAD_70:           /* next byte; d1 = bytes not transferred */
    dbf %d2,VFASTREAD_6E
    swap %d6
    movew %d5,%d6
    addql #1,%d6
    lsll #5,%d6
    extl %d2
    addql #1,%d2
    addl %d2,%d6
    subl %d6,%d1
VFASTREAD_84:           /* wait for the end of the data phase */
    btst #0,%a3@(80)
    jbeq VFASTREAD_9A
    btst #5,%a3@(64)
    jbeq VFASTREAD_9A
    btst #3,%a1@
    jbne VFASTREAD_84
VFASTREAD_9A:           /* return */
    rts
FASTREADOSS:            /* the OSS variant */
    movel %a2,%d0
    jsr @(0x554,%za0)@(0x0)	| 408092EC
    movel %d0,%sp@-
    lea %sp@(-20),%sp
    movel %d0,%sp@
    movel %d2,%sp@(4)
    bsrw FASTWRITEOSS_102_4
    bnew FASTREADOSS_D2
    moveal %sp,%a0
    moveaw #1,%a1
    moveq #5,%d0
    _MemoryDispatch
    bnew FASTREADOSS_D2
FASTREADOSS_2A:
    btst %d3,%a3@(80)
    bnes FASTREADOSS_46
    btst #5,%a3@(64)
    beqs FASTREADOSS_2A
    btst #3,%a3@(80)
    bnes FASTREADOSS_46
    moveq #5,%d0
    braw FASTREADOSS_CA
FASTREADOSS_46:
    nop
    bsrw VFASTWRITEOSS_3E_8
    moveq #7,%d5
    movel %d5,%a3@(128)
    movel %a0@(8),%a3@(256)
    movel %a0@(12),%a3@(192)
    moveb #10,%a3@(32)
    moveb %d7,%a3@(112)
    movel %a0@(4),%a0@(12)
    beqs FASTREADOSS_7C
    moveaw #1,%a1
    moveq #5,%d0
    _MemoryDispatch
    bnew FASTREADOSS_D2
FASTREADOSS_7C:
    moveal ghost_VIA2,%a1
FASTREADOSS_80:
    btst #1,%a1@(514)
    beqs FASTREADOSS_80
    movel %a3@(128),%d5
    andiw #384,%d5
    bnes FASTREADOSS_D2
    tstl %a3@(192)
    bnes FASTREADOSS_D2
    moveb %d7,%a3@(32)
    tstb %a3@(112)
    moveb #2,%a3@(32)
    moveb %d7,%a3@(112)
    tstl %a0@(12)
    bnes FASTREADOSS_46
    movel %d2,%d1
FASTREADOSS_B2:
    btst #0,%a3@(80)
    beqs FASTREADOSS_CA
    btst #5,%a3@(64)
    beqs FASTREADOSS_CA
    btst #3,%a3@(80)
    bnes FASTREADOSS_B2
FASTREADOSS_CA:
    lea %sp@(20),%sp
    braw VFASTREADOSS_30_2
FASTREADOSS_D2:
    moveq #9,%d0
    bras FASTREADOSS_CA
    rts
    nop
    nop
    nop
    nop
    nop
    nop

/*
 SLOWCOMP / FASTCOMP: scComp: read and compare with the buffer, 6 (scCompareErr) on a
 difference.
*/
SLOWCOMP:
    moveal %a4@(68),%a0	| 408093CE
    addaw #96,%a0
    subql #1,%d2
    movel %d2,%d5
    swap %d5
SLOWCOMP_E:             /* wait for DMA request (or a phase error) */
    btst #6,%a1@
    jbne SLOWCOMP_22
    btst #5,%a3@(64)
    jbeq SLOWCOMP_E
    btst #3,%a1@
    jbeq SLOWCOMP_40
SLOWCOMP_22:            /* read a byte, compare */
    btst #6,%a1@
    jbeq SLOWCOMP_3A
    moveb %a0@,%d3
    cmpb %a2@+,%d3
    jbeq SLOWCOMP_30
    moveq #6,%d0
SLOWCOMP_30:            /* next byte */
    dbf %d2,SLOWCOMP_22
    dbf %d5,SLOWCOMP_22
    jbra SLOWCOMP_44
SLOWCOMP_3A:            /* still in the phase? */
    jbsr VFASTWRITEOSS_3E
    jbne SLOWCOMP_22
SLOWCOMP_40:            /* 5 (scPhaseErr) */
    moveq #5,%d0
    jbra SLOWCOMP_5A
SLOWCOMP_44:            /* wait for the end of the phase */
    btst #0,%a3@(80)
    jbeq SLOWCOMP_5A
    btst #5,%a3@(64)
    jbeq SLOWCOMP_5A
    btst #3,%a1@
    jbne SLOWCOMP_44
SLOWCOMP_5A:            /* d1 = bytes not compared, d3 = 6 */
    swap %d5
    movew %d2,%d5
    addql #1,%d5
    subl %d5,%d1
    moveq #6,%d3
    rts
FASTCOMP:               /* (blind; raw words) */
    .long   0x206C0048, 0xD0FC0060, 0x53822A02	| 40809434
    .long   0x48450811, 0x00066612, 0x082B0005, 0x004067F2	| 40809440
    .short  0x0811, 0x0003, 0x6604	| 40809450
    moveq #5,%d0
    jbra FASTCOMP_4C
    .short  0x1610, 0xB61A, 0x6702, 0x7006, 0x51CA, 0xFFF6, 0x51CD, 0xFFF2	| 4080945A
FASTCOMP_36:            /* wait for the end of the phase */
    btst #0,%a3@(80)
    jbeq FASTCOMP_4C
    btst #5,%a3@(64)
    jbeq FASTCOMP_4C
    btst #3,%a1@
    jbne FASTCOMP_36
FASTCOMP_4C:            /* d1 = bytes not compared */
    swap %d5
    movew %d2,%d5
    addql #1,%d5
    subl %d5,%d1
    moveq #6,%d3
    rts
    .long   0x00000000	| 4080948C

/*
 SCSIINIT / INITSCSIMGR: SCSI Manager start-up. Allocates the 1028-byte globals
 (SCSIGlobals, a4), the hardware flags (+100, SCSISETFLAGS), the 14 selector routines
 (+0), the chip addresses (+64 from 0xC00 SCSIBase, +68 SCSIDMA, +72 SCSIHsk), our
 SCSI ID and the polling settings from XPRAM 2 (initialised to 0x4F48 if invalid),
 the select timeout (+98, 250 ms), the 96 vectors (+132..+512: phase, message,
 transfer and internal routines), the deferred task (+588, SCSIDT), the timeout task
 (+608, TIMETASK), the old interface's request (+676) and the free list of private
 blocks (+836, 48 bytes each). INITSCSIMGRPATCH2 then installs the 53C96 manager on
 machines that have one (the Quadra 800: SCSIINIT96BIOS); the interrupt handler goes
 in the VIA 2 SCSI vector (0xD7C), and a SCSIReset is done unless the caller asked
 not to.
*/
SCSIINIT:
INITSCSIMGR:            /* save registers; 1028 bytes of globals in the system heap */
    moveml %d0-%a5,%sp@-
    moveq #0,%d7
    movel #1028,%d0
    .short  0xA71E	| 4080949C _NewPtr (flags 0x0700)
    jbne INITSCSIDONE
    movel %a0,SCSIGlobals
    moveal %a0,%a4
    jbsr INITSCSIMGRPATCH1	/* the flags (SCSISETFLAGS); Power Manager: 14 more bytes */
    nop
    btst #4,%a4@(103)
    jbeq SCSIINIT_34
    moveal ToolDispTable,%a3
    movel #2,%a3@(128)
SCSIINIT_34:            /* the 14 selector routines from the offsets at INITSCSIDONE_6 */
    moveq #13,%d1
    lea %pc@(trap_SCSIDispatch),%a1
    movel %a1,%d0
    lea %pc@(INITSCSIDONE_6),%a1
    moveal %a4,%a0
SCSIINIT_42:            /* entry = trap_SCSIDispatch + offset */
    moveq #0,%d2
    movew %a1@+,%d2
    addl %d0,%d2
    movel %d2,%a0@+
    dbf %d1,SCSIINIT_42
    lea %a4@(64),%a0
    movel ToolDispTable,%a0@+
    movel SCSIDMA,%a0@+
    movel SCSIHsk,%a0@+
    clrw %a0@+
    moveq #-1,%d0
    movel %d0,%a4@(92)
    subql #2,%sp
    moveal %sp,%a0
    movel #131074,%d0
    _ReadXPRam
    movew %sp@,%d0
    andiw #30840,%d0
    cmpiw #18504,%d0
    jbeq SCSIINIT_8C
    movew #20296,%sp@
    moveal %sp,%a0
    movel #131074,%d0
    _WriteXPRam
SCSIINIT_8C:            /* XPRAM 2: our ID (bits 10-8) and the polling bits (bits 2-0, SCSIPoll) */
    movew %sp@,%d0
    andiw #1799,%d0	/* our ID (bits 10-8), polling (2-0) */
    moveb %d0,SCSIPoll
    lsrw #8,%d0
    moveq #1,%d1
    lslb %d0,%d1
    moveb %d1,%a4@(96)	/* our ID as a bit */
    moveb %d1,SCSIDrvrs	/* no driver for our own ID */
    btst #4,%a4@(103)
    jbeq SCSIINIT_C0
    andil #7,%d0
    moveq #9,%d1
    lsll %d1,%d0
    oril #4098,%d0
    movel %d0,%a4@(108)
SCSIINIT_C0:            /* select timeout 250 ms; +126 = 1; transfer rate (+128) */
    movew #250,%a4@(98)	/* select timeout 250 ms */
    moveb #1,%a4@(126)
    movel #4,%a4@(128)
    btst #4,%a4@(103)
    jbeq SCSIINIT_E4
    movel #429496729,%a4@(128)
SCSIINIT_E4:            /* the 96 vectors from the offsets at INITSCSIDONE_22 (0: none) */
    moveq #95,%d1
    lea %pc@(trap_SCSIDispatch),%a1
    movel %a1,%d0
    lea %pc@(INITSCSIDONE_22),%a1
    lea %a4@(132),%a0
SCSIINIT_F4:            /* entry = trap_SCSIDispatch + offset */
    moveq #0,%d2
    movew %a1@+,%d2
    jbeq SCSIINIT_100
    addl %d0,%d2
    movel %d2,%a0@+
    jbra SCSIINIT_102
SCSIINIT_100:           /* no routine */
    movel %d7,%a0@+
SCSIINIT_102:           /* next; then the 72 bytes at INITSCSIDONE_E2 to +516 */
    dbf %d1,SCSIINIT_F4
    moveq #17,%d1
    lea %pc@(INITSCSIDONE_E2),%a1
    lea %a4@(516),%a0
SCSIINIT_110:           /* copy */
    movel %a1@+,%a0@+
    dbf %d1,SCSIINIT_110
    lea %a4@(588),%a1	/* the deferred task: dtQType 7, SCSIDT */
    movew #7,%a1@(4)
    lea %pc@(SCSIDT),%a0
    movel %a0,%a1@(8)
    lea %a4@(608),%a0	/* the Time Manager task: TIMETASK */
    lea %pc@(TIMETASK),%a1
    movel %a1,%a0@(6)
    _InsTime	/* install it */
    movew #768,%a4@(622)
    lea %a4@(628),%a1
    moveq #1,%d0
    movel %d0,%a1@(4)
    movel %d0,%a1@(8)
    lea %a1@(16),%a1
    moveq #-1,%d0
    movel %d0,%a1@
    movel %d0,%a1@(8)
    lea %a4@(676),%a1
    st %a1@(12)
    lea %a4@(740),%a0
    movel %a0,%a1@(4)
    lea %a4@(836),%a1
    movel %a1,%a4@(56)
SCSIINIT_16E:           /* the free list of 48-byte private blocks (+56 first, +60 next free) */
    movel %a1,%a4@(60)
    movel %a1,%d0
    moveq #48,%d1
    addl %d1,%d0
    movel %d0,%a1@
    moveal %d0,%a1
    addl %d1,%d0
    movel %d0,%a1@
    jbsr INITSCSIMGRPATCH2	/* the 53C96 manager, the start-up device's ID */
    btst #4,%a4@(103)
    jbeq SCSIINIT_1C6
    btst #1,%a4@(103)
    jbra SCSIINIT_1C6
    .short  0x41FA, 0xFB2E, 0x2948, 0x00AC, 0x41FA	| 40809626
    .long   0xF80A2948, 0x00B041FA, 0xFB982948, 0x00BC41FA	| 40809630
    .long   0xF8742948, 0x00C041FA, 0xFCA22948, 0x00CC41FA	| 40809640
    .short  0xF9F2, 0x2948, 0x00D0	| 40809650
SCSIINIT_1C6:           /* OSS or RBV machines: the interrupt handler in 0xD7C */
    btst #1,%a4@(103)
    jbne SCSIINIT_1D6
    btst #2,%a4@(103)
    jbeq SCSIINIT_1DE
SCSIINIT_1D6:           /* SCSIINTHND for the VIA 2 SCSI interrupt */
    lea %pc@(SCSIINTHND),%a1
    movel %a1,0xd7c
SCSIINIT_1DE:           /* VIA 2 machines: INSTALLSCSIINTHND96 */
    btst #3,%a4@(103)
    jbeq SCSIINTHNDRESUME_C
    lea %pc@(SCSIINTHND),%a1
    jbra INSTALLSCSIINTHND96

/*
 SCSIINTHNDRESUME: back from INSTALLSCSIINTHND96: the handler in 0xD7C, then SCSIReset
 (selector 0) unless bit 15 of the caller's word on the stack is set.
*/
SCSIINTHNDRESUME:
    jbeq SCSIINTHNDRESUME_8
    movel %a1,0xd7c
    jbra SCSIINTHNDRESUME_C
SCSIINTHNDRESUME_8:     /* the handler */
    movel %a1,0xd7c
SCSIINTHNDRESUME_C:     /* SCSIReset (selector 0) */
    btst #15,%sp@
    jbne SCSIINTHNDRESUME_16
    clrw %sp@-
    _SCSIDispatch
SCSIINTHNDRESUME_16:    /* drop the result */
    addql #2,%sp

/*
 INITSCSIDONE: restore registers, return. The tables after it give the selector
 routines and vectors as offsets from trap_SCSIDispatch.
*/
INITSCSIDONE:
    moveml %sp@+,%d0-%a5
    rts
INITSCSIDONE_6:         /* offsets of selectors 0..13 (+0..+52): DOSCSIRESET, DOSCSIGET, DOSCSISELATN, DOSCSICMD, DOSCSICOMPLETE, NEWSCSIREAD, NEWSCSIWRITE, UNIMPLEMENTED, NEWSCSIRBLIND, NEWSCSIWBLIND, DOSCSISTAT, DOSCSISELATN, DOSCSIMSGIN, DOSCSIMSGOUT */
    .short  0x0052	| 4080969E
    .long   0x007C00CC, 0x00F401D2, 0x01200118, 0x0028011C	| 408096A0
    .short  0x0114, 0x002E, 0x00CC, 0x0230, 0x0244	| 408096B0
INITSCSIDONE_22:        /* offsets of the 96 vectors at +132: phases (+132 data out, +136 data in, +140 command, +144 status, +156 message out, +160 message in), transfers (+164..+220), messages in (+228..+260) and out (+292..+312), internal routines (+356 SCSIINTHND ... +432 DATADMA), new selectors (+484..+512) */
    .short  0x13F8, 0x13F8, 0x0DD6	| 408096BA
    .long   0x0E4C05A4, 0x05A41276, 0x0E9818DA, 0x19341DEE	| 408096C0
    .long   0x1AF40000	| 408096D0
    .long   0x00001DEC /* number, not a label difference (was GETOSEVENT_1E-.) */	| 408096D4
    .long   0x1AF218DA, 0x19341DEE	| 408096D8
    .long   0x1AF41F6E, 0x00001FD4, 0x00000EFC, 0x0F140F60	| 408096E0
    .long   0x00001122, 0x1152118C, 0x11B21208, 0x00000000	| 408096F0
    .long   0x00000000, 0x00000000, 0x000012BE, 0x13041330	| 40809700
    .long   0x138213DA, 0x13800000, 0x00000000, 0x00000000	| 40809710
    .long   0x00000000, 0x00000000, 0x0000179C, 0x07D415F0	| 40809720
    .long   0x15F806A6, 0x0A6C0966, 0x09240826, 0x06181648	| 40809730
    .long   0x16EC178A, 0x06BE189A, 0x09DC05A4, 0x07BC1604	| 40809740
    .long   0x15180000, 0x00000000, 0x00000000, 0x00000000	| 40809750
    .long   0x00000000, 0x00000000, 0x0000053C, 0x0562056C	| 40809760
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x051A	| 40809770
INITSCSIDONE_E2:        /* 72 bytes copied to +516 (transfer routine offsets by transfer type) */
    .short  0x0800, 0x1014, 0x1800	| 4080977A
    .long   0x001C0000, 0x00000000, 0x00000000, 0x00000000	| 40809780
    .long   0x00000000, 0x00000000, 0x00000000, 0x00004044	| 40809790
    .long   0x484C5054, 0x48484848, 0x48484848, 0x48484848	| 408097A0
    .long   0x48484848, 0x48484848, 0x48484848, 0x48484848	| 408097B0
    .long   0x48480000, 0x00000000, 0x00000000, 0x00000000	| 408097C0
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408097D0

/*
 SCSISETFLAGS: the hardware flags of the SCSI Manager (+100, long), from AddrMapFlags
 (0xDD0): bit 1 OSS (AddrMapFlags bit 18), bit 2 RBV (13), bit 3 VIA 2 (11), bit 4 SCSI
 DMA chip (15); SCSISETFLAGSPATCH adds bit 0 (Power Manager, HWCfgFlags bit 8), bits 8
 and 9 (53C96 on the first / second bus: AddrMapFlags bits 24, 25) and the CPU.
*/
SCSISETFLAGS:
    moveml %d1/%a0,%sp@-
    moveq #0,%d0
    btst #3,0xdd2
    jbeq SCSISETFLAGS_12
    bset #3,%d0
SCSISETFLAGS_12:        /* RBV? */
    btst #5,0xdd2
    jbeq SCSISETFLAGS_1E
    bset #2,%d0
SCSISETFLAGS_1E:        /* SCSI DMA chip? */
    btst #7,0xdd2
    jbeq SCSISETFLAGS_2A
    bset #4,%d0
SCSISETFLAGS_2A:        /* OSS? */
    btst #2,0xdd1
    jbeq SCSISETFLAGS_36
    bset #1,%d0
SCSISETFLAGS_36:        /* the 53C96 and Power Manager bits */
    jbsr SCSISETFLAGSPATCH
    nop
    nop
    moveml %sp@+,%d1/%a0
    rts
    .short  0x6040, 0x0808, 0x0808, 0x4104, 0x1812	| 40809826
