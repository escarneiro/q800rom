/*
 os/scsibios.s - SCSI 53C96 BIOS
 From SCSIINIT96BIOS (0x408D1540). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the SCSI Manager chapter of Inside
 Macintosh), not taken from Apple.

 This is the SCSI Manager the Quadra 800 runs: the original interface (_SCSIDispatch:
 SCSIGet, SCSISelect, SCSICmd, SCSIRead/Write with a TIB, SCSIComplete, SCSIMsgIn/Out;
 see os/scsimgr.s) on the NCR 53C96. SCSIINIT (os/scsimgr.s) builds the SCSI globals
 for a 5380; on a machine with a 53C96 and without AddrMapFlags bit 21, its
 INITSCSIMGRPATCH2 calls SCSIINIT96BIOS here, which replaces the 14 selector routines
 and the chip-level vectors (transfer, cycle phase, reset, bus error, read/write/
 compare, error) and sets the chip up. The 53C96 runs whole bus phases by itself
 (select, command, status + message), so these routines start a chip command and wait
 for its interrupt instead of handshaking each signal; data goes through the FIFO or
 the pseudo-DMA register, one byte or word per access with the chip's DREQ.

 a3 = the chip, registers 16 bytes apart: +0/+16 transfer count (low/high), +32 FIFO,
 +48 command, +64 status (read: bits 2-0 the phase: 0 data out, 1 data in, 2 command,
 3 status, 6 message out, 7 message in; bit 7 interrupt) / destination ID (write),
 +80 interrupt (bit 0 selected, 3 function complete, 4 bus service, 5 disconnect,
 7 bus reset) / select timeout, +96 sequence step, +112 FIFO flags (bits 4-0 the byte
 count), +128 configuration 1 (bits 2-0 our ID, 6 no interrupt on a bus reset, 7 slow
 cable mode, set while command bytes go out), +256 pseudo-DMA data.
 Commands: 0x00 nop, 0x01 flush FIFO, 0x02 reset chip, 0x03 reset bus, 0x10 transfer
 information, 0x11 initiator command complete (status + message), 0x12 message
 accepted, 0x1A set ATN, 0x41/0x42 select without/with ATN; +0x80 with DMA (0x90,
 0xC1, 0xC2).

 a4 = the SCSI globals (os/scsimgr.s), and here: +68 the address read for the chip's
 DREQ and +352 its bit (INIT96DREQPATCH), +97 bus taken (SCSIGet), +316/+320 the
 selection, +324 the bus status in the 5380's form (what SCSIStat returns), +344 state
 flags (bit 1 selected, ready for the command; 2 with ATN, a message to send; 3
 selection in progress; 4 command sent; 5 finished; 6 a phase is pending; 7 in a
 transfer), +412 the transfer routine, +446/+447 the last interrupt and status
 registers, +452/+456 the chip of the first/second bus. Results are those of the old
 interface (2 timeout, 3 arbitration, 4 bad TIB, 5 phase error, 6 compare error,
 7 busy, 10 complete phase error); ERROR_BIOS records them with d6 = the step.
*/

/*
 INITMGR_SCSI96_BIOS: install this SCSI Manager: the selector routines (table below),
 the transfer, phase, reset, bus error, read/write/compare and error routines, then
 initialise the chip, our ID in the configuration register, the pseudo-DMA address.
*/
SCSIINIT96BIOS:
INITMGR_SCSI96_BIOS:
    moveml %d0-%a5,%sp@-
    moveq #0,%d7
    moveal SCSIGlobals,%a4
    moveq #13,%d1
    lea %pc@(SCSI96BIOS),%a1
    movel %a1,%d0
    lea %pc@(SCSIINIT96BIOS_E4),%a1
    moveal %a4,%a0
SCSIINIT96BIOS_18:      /* selector routines from the offsets */
    moveq #0,%d2
    movew %a1@+,%d2
    addl %d0,%d2
    movel %d2,%a0@+
    dbf %d1,SCSIINIT96BIOS_18
    lea %pc@(TRANSFER_96_BIOS),%a1
    movel %a1,%a4@(412)
    lea %pc@(CYCLEPHASE_96_BIOS),%a1
    movel %a1,%a4@(476)
    lea %pc@(RESETBUS_96_BIOS),%a1
    movel %a1,%a4@(420)
    lea %pc@(BUSERRHANDLER_96_BIOS),%a1
    movel %a1,%a4@(428)
    lea %pc@(SLOWREAD_96_BIOS),%a1
    movel %a1,%a4@(196)
    lea %pc@(SLOWWRITE_96_BIOS),%a1
    movel %a1,%a4@(200)
    lea %pc@(FASTREAD_96_BIOS),%a1
    movel %a1,%a4@(204)
    lea %pc@(FASTWRITE_96_BIOS),%a1
    movel %a1,%a4@(208)
    lea %pc@(SLOWCOMP_96_BIOS),%a1
    movel %a1,%a4@(212)
    lea %pc@(FASTCOMP_96_BIOS),%a1
    movel %a1,%a4@(220)
    lea %pc@(SCSIERR_96_BIOS),%a1
    movel %a1,%a4@(468)
    lea %pc@(UNIMPLEMENTED_96_BIOS),%a1
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
SCSIINIT96BIOS_B8:      /* our SCSI ID (bit number of +96) */
    lslb #1,%d1
    dbeq %d0,SCSIINIT96BIOS_B8
    orib #71,%d0
    moveb %d0,%a3@(128)
    movel ToolDispTable,%a4@(452)
    clrb %a4@(352)
    movel #1357920768,%a4@(68)
    moveb #2,%a4@(126)
    moveml %sp@+,%d0-%a5
    rts
SCSIINIT96BIOS_E4:      /* offsets of the selector routines */
    .long   0x009000F6, 0x01100152, 0x02120182	| 408D1624
    .long   0x017A003A, 0x017E0176, 0x00400110, 0x02B602D4	| 408D1630

/* SCSIMGR_96_BIOS: the selector routines share this exit. */
SCSI96BIOS:
SCSIMGR_96_BIOS:
    moveal %sp@+,%a0	| 408D1640
    movew %sp@+,%d0	| 408D1642
    movel %a0,%sp@-	| 408D1644
    cmpiw #14,%d0	| 408D1646
    jbcc UNIMPLEMENTED_96_BIOS	| 408D164A
    linkw %fp,#-6	| 408D164C
    moveml %d2-%d7/%a2-%a5,%sp@-	| 408D1650
    moveal SCSIGlobals,%a4	| 408D1654
    moveal %a4@(64),%a3	| 408D1658
    moveq #0,%d7	| 408D165C
    moveq #0,%d4	| 408D165E
    movew %d0,%d1	| 408D1660
    moveal %a4@(0,%d0:w:4),%a0	| 408D1662
    jmp %a0@	| 408D1666

SCSIMGR_96_BIOS_28:     /* return, popping d0 bytes of parameters */
    moveml %sp@+,%d2-%d7/%a2-%a5
    unlk %fp
    moveal %sp@+,%a0
    addaw %d0,%sp
    jmp %a0@

SCSIMGR_96_BIOS_34:     /* bus free (+97) */
    moveb %d7,%a4@(97)
    rts

/* UNIMPLEMENTED_96_BIOS: a selector this SCSI Manager does not have: system error 12. */
UNIMPLEMENTED_96_BIOS:
    moveq #12,%d0	| 408D167A
    _SysError	| 408D167C
UNIMPLEMENTED_96_BIOS_4:  /* (hang) */
    jbra UNIMPLEMENTED_96_BIOS_4	| 408D167E

/*
 DOSCSISTAT_96_BIOS (10): SCSIStat: the bus status in the 5380's form (+324, kept up to
 date by the other selectors), with the phase bits from the 53C96 status register of
 each bus; REQ is reported when BSY and SEL say a target is connected. The first two
 instructions clear the phase and REQ bits (+324) and save a3.
*/
DOSCSISTAT_96_BIOS:
    andiw #-30,%a4@(324)	| 408D1680
    movel %a3,%sp@-
    moveq #0,%d1
    moveal %a4@(452),%a3
    moveb %a3@(64),%d1
    btst #1,0xdd0
    jbeq DOSCSISTAT_96_BIOS_22
    moveal %a4@(456),%a3
    orb %a3@(64),%d1
DOSCSISTAT_96_BIOS_22:  /* phase bits */
    moveal %sp@+,%a3
    andib #7,%d1
    lslb #2,%d1
    orw %d1,%a4@(324)
    moveq #66,%d0
    andw %a4@(324),%d0
    cmpiw #64,%d0
    jbne DOSCSISTAT_96_BIOS_42
    oriw #32,%a4@(324)
    jbra DOSCSISTAT_96_BIOS_48
DOSCSISTAT_96_BIOS_42:  /* (no REQ) */
    andiw #-33,%a4@(324)
DOSCSISTAT_96_BIOS_48:  /* result */
    movew %a4@(324),%fp@(8)
    jbra DOSCSIRESET_96_BIOS_42

/* DOSCSIRESET_96_BIOS: SCSIReset: reset the bus (both buses), wait about 512 ms. */
DOSCSIRESET_96_BIOS:
    movel %a3,%sp@-
    moveal %a4@(420),%a0
    moveal %a4@(452),%a3
    jsr %a0@
    btst #1,0xdd0
    jbeq DOSCSIRESET_96_BIOS_1E
    moveal %a4@(420),%a0
    moveal %a4@(456),%a3
    jsr %a0@
DOSCSIRESET_96_BIOS_1E:  /* clear the state */
    moveal %sp@+,%a3
    clrl %a4@(324)
    movew %d7,%fp@(8)
    jbsr SCSIMGR_96_BIOS_34
    moveq #0,%d2
    movew TimeDBRA,%d2
    lsll #8,%d2
    lsll #1,%d2
    movel %d2,%d3
    swap %d3
DOSCSIRESET_96_BIOS_3A:  /* delay */
    dbf %d2,DOSCSIRESET_96_BIOS_3A
    dbf %d3,DOSCSIRESET_96_BIOS_3A
DOSCSIRESET_96_BIOS_42:  /* return 0 */
    moveq #0,%d0
    jbra SCSIMGR_96_BIOS_28
DOSCSIRESET_96_BIOS_48:  /* (select failed: error) */
    clrw %sp@
    movel %d0,%sp@-
    jbsr SCSIMGR_96_BIOS_34
    movel %sp@+,%d0
    moveq #2,%d6
    jbsr ERROR_BIOS
    movew %sp@+,%a4@(324)
    movew %d0,%fp@(10)
    moveq #2,%d0
    jbra SCSIMGR_96_BIOS_28

/* DOSCSIGET_96_BIOS: SCSIGet: the bus is ours unless already busy (7). */
DOSCSIGET_96_BIOS:
    bset #0,%a4@(97)
    jbne DOSCSIGET_96_BIOS_16
    movew #66,%a4@(324)
    moveq #0,%d0
DOSCSIGET_96_BIOS_10:   /* result */
    movew %d0,%fp@(8)
    jbra DOSCSIRESET_96_BIOS_42
DOSCSIGET_96_BIOS_16:   /* busy */
    moveq #7,%d0
    jbra DOSCSIGET_96_BIOS_10

/*
 DOSCSISELECT_S96_BIOS: SCSISelect / SCSISelAtn (d1 = 11): select the target, with ATN
 for a message phase.
*/
DOSCSISELATN_S96_BIOS:
DOSCSISELECT_S96_BIOS:
    bset #0,%a4@(97)
    movew %a4@(324),%sp@-
    movew #64,%sp@
    moveq #0,%d0
    movew %fp@(8),%d0
    cmpiw #11,%d1
    jbne DOSCSISELATN_S96_BIOS_22
    bset #16,%d0
    oriw #512,%sp@
DOSCSISELATN_S96_BIOS_22:  /* start the selection */
    movel %d6,%a4@(320)
    moveal %a4@(68),%a0
    jbsr DOSCSIMSGOUT_96_BIOS_1C
    jbne DOSCSIRESET_96_BIOS_48
    movew %sp@+,%a4@(324)
    movel %a0,%a4@(316)
    movew %d0,%fp@(10)
    moveq #2,%d0
    jbra SCSIMGR_96_BIOS_28

/* DOSCSICMD_96_BIOS: SCSICmd(buffer, count): send the command bytes. */
DOSCSICMD_96_BIOS:
    moveal %fp@(10),%a2
    movew %fp@(8),%d2
    jbsr DOSCSIMSGOUT_96_BIOS_D0
    jbne DOSCSICMD_96_BIOS_18
DOSCSICMD_96_BIOS_E:    /* result */
    movew %d0,%fp@(14)
    moveq #6,%d0
    jbra SCSIMGR_96_BIOS_28
DOSCSICMD_96_BIOS_18:   /* error */
    movel %d0,%sp@-
    movel %sp@+,%d0
    moveq #3,%d6
    jbsr ERROR_BIOS
    jbra DOSCSICMD_96_BIOS_E

/*
 NEWSCSIWBLIND_96_BIOS / WRITE / RBLIND / READ: run a TIB (transfer instruction
 block): d4 = the transfer routine (blind or polled, read or write).
*/
NEWSCSIWBLIND_96_BIOS:
    moveq #44,%d4
    jbra NEWSCSIREAD_96_BIOS_2
NEWSCSIWRITE_96_BIOS:   /* d4 = 36 (write), then the TIB */
    moveq #36,%d4
    bras NEWSCSIREAD_96_BIOS_2

NEWSCSIRBLIND_96_BIOS:  /* d4 = 40: blind read */
    moveq #40,%d4
    jbra NEWSCSIREAD_96_BIOS_2

NEWSCSIREAD_96_BIOS:    /* d4 = 32: read */
    moveq #32,%d4
NEWSCSIREAD_96_BIOS_2:  /* TIB address */
    moveal %fp@(8),%a1
    jbra NEWSCSIREAD_96_BIOS_20
NEWSCSIREAD_96_BIOS_8:  /* scInc...: transfer and add */
    bset #4,%d4
NEWSCSIREAD_96_BIOS_C:  /* transfer (scInc/scNoInc) */
    moveal %a4@(412),%a0	/* vector +412: TRANSFER; 53C96 BIOS: TRANSFER_96_BIOS */
    jsr %a0@
    jbne NEWSCSIREAD_96_BIOS_72
    addl %d1,%a1@(2)
    bclr #4,%d4
NEWSCSIREAD_96_BIOS_1C:  /* next instruction */
    lea %a1@(10),%a1
NEWSCSIREAD_96_BIOS_20:  /* instruction: opcode, address, count */
    movew %a1@,%d1
    moveal %a1@(2),%a2
    movel %a1@(6),%d2
    cmpiw #8,%d1
    jbhi NEWSCSIREAD_96_BIOS_48
    addw %d1,%d1
    jmp %pc@(NEWSCSIREAD_96_BIOS_36,%d1:w)
NEWSCSIREAD_96_BIOS_36:  /* dispatch on the opcode (1..8) */
    bras NEWSCSIREAD_96_BIOS_48
    bras NEWSCSIREAD_96_BIOS_C
    bras NEWSCSIREAD_96_BIOS_4C
    bras NEWSCSIREAD_96_BIOS_56
    bras NEWSCSIREAD_96_BIOS_5A
    bras NEWSCSIREAD_96_BIOS_60
    bras NEWSCSIREAD_96_BIOS_1C
    bras NEWSCSIREAD_96_BIOS_70
    bras NEWSCSIREAD_96_BIOS_8
NEWSCSIREAD_96_BIOS_48:  /* bad opcode: 4 */
    moveq #4,%d0
    jbra NEWSCSIREAD_96_BIOS_72
NEWSCSIREAD_96_BIOS_4C:  /* scNoInc: transfer */
    moveal %a4@(412),%a0	/* vector +412: TRANSFER; 53C96 BIOS: TRANSFER_96_BIOS */
    jsr %a0@
    jbne NEWSCSIREAD_96_BIOS_72
    jbra NEWSCSIREAD_96_BIOS_1C
NEWSCSIREAD_96_BIOS_56:  /* scAdd */
    addl %d2,%a2@
    jbra NEWSCSIREAD_96_BIOS_1C
NEWSCSIREAD_96_BIOS_5A:  /* scMove */
    moveal %d2,%a0
    movel %a2@,%a0@
    jbra NEWSCSIREAD_96_BIOS_1C
NEWSCSIREAD_96_BIOS_60:  /* scLoop */
    tstl %d2
    jbeq NEWSCSIREAD_96_BIOS_1C
    subql #1,%d2
    movel %d2,%a1@(6)
    jbeq NEWSCSIREAD_96_BIOS_1C
    addal %a2,%a1
    jbra NEWSCSIREAD_96_BIOS_20
NEWSCSIREAD_96_BIOS_70:  /* scStop: 0 */
    moveq #0,%d0
NEWSCSIREAD_96_BIOS_72:  /* result */
    moveml %d0-%d2,%sp@-
    moveq #9,%d0
    moveaw #8,%a0
    moveaw #4,%a1
    .short  0xA198	| 408D1842 _HWPriv (flags 0x0100)
    moveml %sp@+,%d0-%d2
    movew %d0,%fp@(12)
    moveq #4,%d0
    jbra SCSIMGR_96_BIOS_28

/*
 DOSCSICOMPLETE_96_BIOS: SCSIComplete(stat, message, wait): wait (up to the ticks
 given) for the status phase, read the status and message bytes, accept the message.
*/
DOSCSICOMPLETE_96_BIOS:
    movew %d7,%sp@-
    bclr #5,%a4@(344)
    jbne DOSCSICOMPLETE_96_BIOS_64
    movel Ticks,%d4
    addl %fp@(8),%d4
    jsr %pc@(HANDLESELINPROG_BIOS)
    bnew DOSCSICOMPLETE_96_BIOS_76
DOSCSICOMPLETE_96_BIOS_1A:  /* status phase? */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #3,%d3
    bnew DOSCSICOMPLETE_96_BIOS_76
DOSCSICOMPLETE_96_BIOS_28:  /* initiator command complete sequence (status, message) */
    moveb #1,%a3@(48)
    moveb #17,%a3@(48)
    jbsr WAITFORSCSIINTRP
    beqw DOSCSICOMPLETE_96_BIOS_96
    moveq #0,%d2
    moveb %a3@(32),%d2
    moveal %fp@(16),%a1
    movew %d2,%a1@
    moveb %a3@(32),%d2
    moveal %fp@(12),%a1
    movew %d2,%a1@
    moveb #18,%a3@(48)
    jbsr WAITFORSCSIINTRP
    beqw DOSCSICOMPLETE_96_BIOS_96
DOSCSICOMPLETE_96_BIOS_64:  /* done */
    clrl %a4@(324)
    movew %sp@+,%fp@(20)
    jbsr SCSIMGR_96_BIOS_34
    moveq #12,%d0
    jbra SCSIMGR_96_BIOS_28
DOSCSICOMPLETE_96_BIOS_76:  /* other phase: bit bucket it */
    movew #5,%sp@
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr %a4@(0x1dc,%za0)@(0)	| 408D18CC
    jbeq DOSCSICOMPLETE_96_BIOS_84
    movew %d0,%sp@
DOSCSICOMPLETE_96_BIOS_84:  /* (until the timeout) */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #3,%d3
    jbeq DOSCSICOMPLETE_96_BIOS_28
    cmpl Ticks,%d4
    jbhi DOSCSICOMPLETE_96_BIOS_1A
DOSCSICOMPLETE_96_BIOS_96:  /* timeout: error 2 */
    movew #2,%sp@
    movel %sp@,%d0
    moveq #4,%d6
    jbsr ERROR_BIOS
    jbra DOSCSICOMPLETE_96_BIOS_64

/* DOSCSIMSGIN_96_BIOS: SCSIMsgIn: read a message byte. */
DOSCSIMSGIN_96_BIOS:
    jbsr DOSCSIMSGOUT_96_BIOS_1C4
    jbne DOSCSIMSGIN_96_BIOS_16
    moveal %fp@(8),%a1
    movew %d2,%a1@
DOSCSIMSGIN_96_BIOS_C:  /* result */
    movew %d0,%fp@(12)
    moveq #4,%d0
    jbra SCSIMGR_96_BIOS_28
DOSCSIMSGIN_96_BIOS_16:  /* error */
    moveq #12,%d6
    jbsr ERROR_BIOS
    jbra DOSCSIMSGIN_96_BIOS_C

/* DOSCSIMSGOUT_96_BIOS: SCSIMsgOut: send a message byte. */
DOSCSIMSGOUT_96_BIOS:
    .long   0x342E0008	| 408D1914
    jbsr DOSCSIMSGOUT_96_BIOS_246
    jbne DOSCSIMSGOUT_96_BIOS_14
DOSCSIMSGOUT_96_BIOS_A:  /* result */
    movew %d0,%fp@(10)
    moveq #2,%d0
    jbra SCSIMGR_96_BIOS_28
DOSCSIMSGOUT_96_BIOS_14:  /* error */
    moveq #12,%d6
    jbsr ERROR_BIOS
    jbra DOSCSIMSGOUT_96_BIOS_A

DOSCSIMSGOUT_96_BIOS_1C:  /* start a selection (without or with ATN) and wait for it */
    moveb %d0,%a3@(64)
    moveb #1,%a3@(48)
    btst #16,%d0
    jbne DOSCSIMSGOUT_96_BIOS_42
    moveb %d7,%a3@(16)
    moveb #1,%a3@
    moveb #0xc1,%a3@(48)
    bset #1,%a4@(344)
    jbra DOSCSIMSGOUT_96_BIOS_56
DOSCSIMSGOUT_96_BIOS_42:  /* with ATN */
    moveb %d7,%a3@(16)
    moveb #1,%a3@
    moveb #0xc2,%a3@(48)
    bset #2,%a4@(344)
DOSCSIMSGOUT_96_BIOS_56:  /* wait for the interrupt (selection timeout) */
    bset #3,%a4@(344)
    moveq #0,%d1
    movew TimeSCSIDB,%d1
    lsll #8,%d1
    lsll #1,%d1
    movel %d1,%d2
    swap %d2
    moveq #-1,%d3
    moveq #-1,%d4
DOSCSIMSGOUT_96_BIOS_6E:  /* poll */
    movel %a0@,%d5
    moveb %a4@(352),%d0
    btst %d0,%d5
    jbne DOSCSIMSGOUT_96_BIOS_CA
    lsll #8,%d3
    moveb %a3@(64),%d3
    moveb %d3,%d0
    btst #7,%d0
    dbne %d1,DOSCSIMSGOUT_96_BIOS_6E
    dbne %d2,DOSCSIMSGOUT_96_BIOS_6E
    beqw DOSCSIMSGOUT_96_BIOS_C4
    moveb %a3@(64),%d3
    moveb %a3@(80),%d1
    moveb %d3,%a4@(447)
    moveb %d1,%a4@(446)
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    bclr #2,%a4@(344)
    bclr #1,%a4@(344)
    btst #5,%d1
    beqw DOSCSIMSGOUT_96_BIOS_CA
    moveq #2,%d2
    jbra DOSCSIMSGOUT_96_BIOS_CC
DOSCSIMSGOUT_96_BIOS_C4:  /* timed out: 3 */
    moveq #3,%d2
    braw DOSCSIMSGOUT_96_BIOS_CC
DOSCSIMSGOUT_96_BIOS_CA:  /* selected: 0 */
    moveq #0,%d2
DOSCSIMSGOUT_96_BIOS_CC:  /* return */
    movel %d2,%d0
    rts

DOSCSIMSGOUT_96_BIOS_D0:  /* send the command bytes through the FIFO (command phase) */
    btst #1,%a4@(344)
    jbeq DOSCSIMSGOUT_96_BIOS_1B2
    moveb #2,%d1
    jsr %pc@(WT4DREQORINT_BIOS)
    jbeq DOSCSIMSGOUT_96_BIOS_184
    bclr #6,%a4@(344)
    jbeq DOSCSIMSGOUT_96_BIOS_102
    moveb #1,%a3@(48)
    moveb %d7,%a3@(16)
    moveb #1,%a3@
    moveb #0x90,%a3@(48)
DOSCSIMSGOUT_96_BIOS_102:  /* fill the FIFO */
    orib #0x80,%a3@(128)
    subql #1,%d2
    jbra DOSCSIMSGOUT_96_BIOS_110
DOSCSIMSGOUT_96_BIOS_10C:  /* one byte */
    moveb %a2@+,%a3@(32)
DOSCSIMSGOUT_96_BIOS_110:  /* (count) */
    dbf %d2,DOSCSIMSGOUT_96_BIOS_10C
    btst #1,%a4@(344)
    jbeq DOSCSIMSGOUT_96_BIOS_14C
DOSCSIMSGOUT_96_BIOS_11C:  /* wait until the FIFO empties */
    moveq #31,%d1
    andb %a3@(112),%d1
    jbeq DOSCSIMSGOUT_96_BIOS_130
    moveq #7,%d1
    andb %a3@(64),%d1
    cmpib #2,%d1
    jbeq DOSCSIMSGOUT_96_BIOS_11C
DOSCSIMSGOUT_96_BIOS_130:  /* last byte through the pseudo-DMA register */
    moveq #7,%d1
    andb %a3@(64),%d1
    moveb %a2@+,%a3@(256)
    bclr #1,%a4@(344)
    bset #4,%a4@(344)
    cmpib #2,%d1
    jbne DOSCSIMSGOUT_96_BIOS_1A8
DOSCSIMSGOUT_96_BIOS_14C:  /* still command phase? */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #2,%d3
    jbeq DOSCSIMSGOUT_96_BIOS_164
DOSCSIMSGOUT_96_BIOS_158:  /* 0 */
    moveq #0,%d0
DOSCSIMSGOUT_96_BIOS_15A:  /* return */
    andib #127,%a3@(128)
    tstw %d0
    rts
DOSCSIMSGOUT_96_BIOS_164:  /* wait for the phase to change */
    movel %d7,%d0
    movew TimeSCSIDB,%d0
    lsll #8,%d0
    movel %d0,%d2
    swap %d2
DOSCSIMSGOUT_96_BIOS_170:  /* poll */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #2,%d3
    dbne %d0,DOSCSIMSGOUT_96_BIOS_170
    dbne %d2,DOSCSIMSGOUT_96_BIOS_170
    jbra DOSCSIMSGOUT_96_BIOS_158
DOSCSIMSGOUT_96_BIOS_184:  /* failed: clear the state */
    bclr #6,%a4@(344)
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    bclr #2,%a4@(344)
    bclr #1,%a4@(344)
    moveb #1,%a3@(48)
DOSCSIMSGOUT_96_BIOS_1A8:  /* error 5 */
    moveq #5,%d0
    moveq #3,%d6
    jbsr ERROR_BIOS
    jbra DOSCSIMSGOUT_96_BIOS_15A
DOSCSIMSGOUT_96_BIOS_1B2:  /* (command phase already) */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #2,%d3
    jbne DOSCSIMSGOUT_96_BIOS_1A8
    addql #1,%d2
    jbra DOSCSIMSGOUT_96_BIOS_102

DOSCSIMSGOUT_96_BIOS_1C4:  /* message in: read the byte, accept it (disconnect ends the command) */
    bclr #1,%a4@(344)
    jbeq DOSCSIMSGOUT_96_BIOS_1E0
    bclr #6,%a4@(344)
    jbne DOSCSIMSGOUT_96_BIOS_1DA
    jbsr WAITFORINTNOTIME
DOSCSIMSGOUT_96_BIOS_1DA:  /* flush */
    moveb #1,%a3@(48)
DOSCSIMSGOUT_96_BIOS_1E0:  /* message in phase? */
    moveq #7,%d3
    andb %a3@(64),%d3
    cmpib #7,%d3
    jbne DOSCSIMSGOUT_96_BIOS_23C
    moveb #16,%a3@(48)
    jbsr WAITFORINTNOTIME
    moveb %a3@(32),%d2
    moveb #18,%a3@(48)
    jbsr WAITFORINTNOTIME
    btst #21,%d5
    jbeq DOSCSIMSGOUT_96_BIOS_22E
    bclr #4,%a4@(344)
    bclr #2,%a4@(344)
    bset #5,%a4@(344)
    bclr #1,%a4@(344)
    moveb %d7,%a4@(97)
    movel %d7,%a4@(324)
DOSCSIMSGOUT_96_BIOS_22E:  /* 0 */
    bclr #6,%a4@(344)
    moveq #0,%d0
    rts
    moveq #2,%d0
    jbra DOSCSIMSGOUT_96_BIOS_23E
DOSCSIMSGOUT_96_BIOS_23C:  /* wrong phase: 5 */
    moveq #5,%d0
DOSCSIMSGOUT_96_BIOS_23E:  /* return */
    clrl %a4@(324)
    tstl %d0
    rts

DOSCSIMSGOUT_96_BIOS_246:  /* message out: send the byte (with ATN) */
    btst #2,%a4@(344)
    jbeq DOSCSIMSGOUT_96_BIOS_2F8
    moveb #6,%d1
    jsr %pc@(WT4DREQORINT_BIOS)
    jbeq DOSCSIMSGOUT_96_BIOS_322
    moveb %a3@(64),%d3
    andib #7,%d3
    cmpib #6,%d3
    jbne DOSCSIMSGOUT_96_BIOS_33A
DOSCSIMSGOUT_96_BIOS_26C:  /* message out phase: send it */
    btst #7,%d2
    jbne DOSCSIMSGOUT_96_BIOS_2AE
    moveb %d2,%a3@(256)
    jbsr WAITFORINTNOTIME
    btst #21,%d5
    jbeq DOSCSIMSGOUT_96_BIOS_2C4
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    bclr #2,%a4@(344)
    bclr #1,%a4@(344)
    bset #5,%a4@(344)
    moveb %d7,%a4@(97)
    movel %d7,%a4@(324)
    moveq #0,%d0
    tstw %d0
    rts
DOSCSIMSGOUT_96_BIOS_2AE:  /* (identify with disconnect: then command) */
    andib #0xbf,%d2
    moveb %d2,%a3@(32)
    bset #1,%a4@(344)
    bclr #5,%a4@(344)
    jbra DOSCSIMSGOUT_96_BIOS_342
DOSCSIMSGOUT_96_BIOS_2C4:  /* next phase */
    bset #6,%a4@(344)
    bclr #2,%a4@(344)
    moveb %d5,%d3
    andib #7,%d3
    cmpib #2,%d3
    jbne DOSCSIMSGOUT_96_BIOS_2EA
    bset #1,%a4@(344)
    bclr #5,%a4@(344)
    jbra DOSCSIMSGOUT_96_BIOS_342
DOSCSIMSGOUT_96_BIOS_2EA:  /* (other) */
    bclr #1,%a4@(344)
    bset #5,%a4@(344)
    jbra DOSCSIMSGOUT_96_BIOS_342
DOSCSIMSGOUT_96_BIOS_2F8:  /* wait for the message out phase */
    jsr %pc@(HANDLESELINPROG_BIOS)
    jbne DOSCSIMSGOUT_96_BIOS_33A
    moveq #0,%d1
    movew TimeSCSIDB,%d1
    lsll #8,%d1
    movel %d1,%d3
    swap %d3
DOSCSIMSGOUT_96_BIOS_30A:  /* poll */
    moveb %a3@(64),%d3
    andib #7,%d3
    cmpib #6,%d3
    jbeq DOSCSIMSGOUT_96_BIOS_26C
    dbf %d1,DOSCSIMSGOUT_96_BIOS_30A
    dbf %d3,DOSCSIMSGOUT_96_BIOS_30A
DOSCSIMSGOUT_96_BIOS_322:  /* failed: clear the state */
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    bclr #2,%a4@(344)
    bclr #1,%a4@(344)
DOSCSIMSGOUT_96_BIOS_33A:  /* error 5 */
    moveq #5,%d0
    jbra DOSCSIMSGOUT_96_BIOS_344
    moveq #2,%d0
    jbra DOSCSIMSGOUT_96_BIOS_344
DOSCSIMSGOUT_96_BIOS_342:  /* 0 */
    moveq #0,%d0
DOSCSIMSGOUT_96_BIOS_344:  /* clear ATN, return */
    andiw #-513,%a4@(324)
    tstw %d0
    rts

/*
 CYCLEPHASE_96_BIOS: get the bus to the status phase by answering whatever the target
 asks: dummy data out (0xEE), data in thrown away, messages accepted. Out: d0 = 10 in
 status phase, 0 otherwise.
*/
CYCLEPHASE_96_BIOS:
    btst #0,%a4@(97)
    jbeq CYCLEPHASE_96_BIOS_3C
CYCLEPHASE_96_BIOS_8:   /* current phase */
    moveq #7,%d0
    andb %a3@(64),%d0
    cmpiw #1,%d0
    jbeq CYCLEPHASE_96_BIOS_40
    cmpiw #0,%d0
    jbeq CYCLEPHASE_96_BIOS_40
    cmpiw #2,%d0
    jbeq CYCLEPHASE_96_BIOS_7C
    cmpiw #6,%d0
    jbeq CYCLEPHASE_96_BIOS_B8
    cmpiw #7,%d0
    jbeq CYCLEPHASE_96_BIOS_DC
    cmpiw #3,%d0
    jbne CYCLEPHASE_96_BIOS_3C
    movew #10,%d0
    rts
CYCLEPHASE_96_BIOS_3C:  /* 0 */
    moveq #0,%d0
    rts
CYCLEPHASE_96_BIOS_40:  /* data phase: (during a DMA transfer: drain it) */
    moveb %a3@(48),%d1
    cmpib #0x90,%d1
    jbne CYCLEPHASE_96_BIOS_58
    tstb %a3@
    jbne CYCLEPHASE_96_BIOS_FA
    tstb %a3@(16)
    jbne CYCLEPHASE_96_BIOS_FA
CYCLEPHASE_96_BIOS_58:  /* data in: read and drop */
    cmpib #0,%d0
    jbeq CYCLEPHASE_96_BIOS_6C
    jbsr XFER1BYTE
    jbne CYCLEPHASE_96_BIOS_3C
    moveb %a3@(32),%d0
    jbra CYCLEPHASE_96_BIOS_8
CYCLEPHASE_96_BIOS_6C:  /* data out: send 0xEE */
    moveb #0xee,%a3@(32)
    jbsr XFER1BYTE
    jbne CYCLEPHASE_96_BIOS_3C
    jbra CYCLEPHASE_96_BIOS_8
CYCLEPHASE_96_BIOS_7C:  /* command phase: 0xEE */
    bclr #1,%a4@(344)
    jbeq CYCLEPHASE_96_BIOS_A6
    moveb #0xee,%a3@(256)
    bset #4,%a4@(344)
    jbsr WAITFORSCSIINTRP
    jbeq CYCLEPHASE_96_BIOS_A4
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
CYCLEPHASE_96_BIOS_A4:  /* next */
    jbra CYCLEPHASE_96_BIOS_B4
CYCLEPHASE_96_BIOS_A6:  /* one byte */
    moveb #0xee,%a3@(32)
    jbsr XFER1BYTE
    jbne CYCLEPHASE_96_BIOS_3C
CYCLEPHASE_96_BIOS_B4:  /* next */
    jbra CYCLEPHASE_96_BIOS_8
CYCLEPHASE_96_BIOS_B8:  /* message out: no-operation (8) */
    moveb #8,%a3@(32)
    bclr #2,%a4@(344)
    jbeq CYCLEPHASE_96_BIOS_CE
    bset #1,%a4@(344)
    jbra CYCLEPHASE_96_BIOS_D8
CYCLEPHASE_96_BIOS_CE:  /* (send it) */
    jbsr XFER1BYTE
    jbne CYCLEPHASE_96_BIOS_3C
CYCLEPHASE_96_BIOS_D8:  /* next */
    jbra CYCLEPHASE_96_BIOS_8
CYCLEPHASE_96_BIOS_DC:  /* message in: read, accept */
    jbsr XFER1BYTE
    jbne CYCLEPHASE_96_BIOS_3C
    moveb %a3@(32),%d0
    moveb #18,%a3@(48)
    jbsr WAITFORSCSIINTRP
    jbra CYCLEPHASE_96_BIOS_8
CYCLEPHASE_96_BIOS_FA:  /* DMA under way: drain or fill until it ends */
    moveal %a4@(316),%a0
    moveq #7,%d0
    andb %a3@(64),%d0
    cmpiw #0,%d0
    jbeq CYCLEPHASE_96_BIOS_12A
CYCLEPHASE_96_BIOS_10A:  /* data in: read words */
    btst #7,%a3@(64)
    jbne CYCLEPHASE_96_BIOS_122
    movel %a0@,%d5
    moveb %a4@(352),%d0
    btst %d0,%d5
    jbeq CYCLEPHASE_96_BIOS_10A
    movew %a3@(256),%d5
    jbra CYCLEPHASE_96_BIOS_10A
CYCLEPHASE_96_BIOS_122:  /* interrupt: done */
    jbsr WAITFORINTNOTIME
    jbra CYCLEPHASE_96_BIOS_14A
CYCLEPHASE_96_BIOS_12A:  /* data out: write 0xEEEE */
    btst #7,%a3@(64)
    jbne CYCLEPHASE_96_BIOS_144
    movel %a0@,%d5
    moveb %a4@(352),%d0
    btst %d0,%d5
    jbeq CYCLEPHASE_96_BIOS_12A
    movew #-4370,%a3@(256)
    jbra CYCLEPHASE_96_BIOS_12A
CYCLEPHASE_96_BIOS_144:  /* done */
    jbsr WAITFORINTNOTIME
CYCLEPHASE_96_BIOS_14A:  /* next phase */
    jbra CYCLEPHASE_96_BIOS_8

/* ERROR_BIOS: report error d6/d0 through the error routine (+468). */
ERROR_BIOS:
    moveal %a4@(468),%a0	/* vector +468: SCSIERR; 53C96 BIOS: SCSIERR_96_BIOS */
    jsr %a0@
    rts

/* SCSIERR_96_BIOS: the default error routine: nothing. */
SCSIERR_96_BIOS:
    rts
    moveal %a4@(316),%a0
    movel %a0@,%d5
    moveb %a4@(352),%d0
    btst %d0,%d5
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 408D1DC8

/*
 INITHW_SCSI96_BIOS: reset the chip, configuration (our ID, parity), clock factor and
 timeout, and the pseudo-DMA timing in the decoder (0x50F18000) by the CPU clock
 read from the VIA (sense bits).
*/
SCSIHW96BIOS:
INITHW_SCSI96_BIOS:
    moveb #2,%a3@(48)
    clrb %a3@(48)
    moveb #1,%a3@(48)
    moveb #71,%a3@(128)
    clrb %a3@(176)
    moveb #4,%a3@(192)
    moveml %d0/%d2-%d3/%a0/%a2,%sp@-
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(8),%a2
    moveq #40,%d3
    moveb %d3,%a2@(1536)
    moveq #20,%d3
    andb %a2@(7680),%d3
    lea 0x50f18000,%a2
    moveb %a2@(512),%d2
    andib #0xc0,%d2
    lsrb #2,%d3
    jbne SCSIHW96BIOS_52
    orib #27,%d2
    jbra SCSIHW96BIOS_68
SCSIHW96BIOS_52:        /* (other clocks) */
    subqb #4,%d3
    jbeq SCSIHW96BIOS_5E
    jbgt SCSIHW96BIOS_64
    orib #63,%d2
    jbra SCSIHW96BIOS_68
SCSIHW96BIOS_5E:        /* (33 MHz) */
    orib #18,%d2
    jbra SCSIHW96BIOS_68
SCSIHW96BIOS_64:        /* (other) */
    orib #0,%d2
SCSIHW96BIOS_68:        /* timing, clock factor, timeout, clear the interrupt */
    moveb %d2,%a2@(512)
    moveb #5,%a3@(144)
    moveb #0xa7,%a3@(80)
    clrb %a3@(112)
    moveb %a3@(80),%d0
    moveml %sp@+,%d0/%d2-%d3/%a0/%a2
    rts
SCSIHW96BIOS_86:        /* read up to 3 bytes one by one (programmed I/O) */
    jbra SCSIHW96BIOS_9C
SCSIHW96BIOS_88:        /* one byte: transfer command, wait, read the FIFO */
    moveb #16,%a3@(48)
    jbsr WAITFORINTNOTIME
    jbne FASTREAD_96_BIOS_140
    moveb %a3@(32),%a2@+
SCSIHW96BIOS_9C:        /* (count) */
    dbf %d2,SCSIHW96BIOS_88
    moveb %a3@(80),%d3
    btst #5,%d3
    jbne FASTREAD_96_BIOS_140
    moveq #0,%d0
    rts
SCSIHW96BIOS_B0:        /* write up to 3 bytes through the FIFO */
    jbra SCSIHW96BIOS_B6
SCSIHW96BIOS_B2:        /* one byte */
    moveb %a2@+,%a3@(32)
SCSIHW96BIOS_B6:        /* (count), then transfer */
    dbf %d2,SCSIHW96BIOS_B2
    moveb #16,%a3@(48)
    jbsr WAITFORINTNOTIME
    jbne FASTREAD_96_BIOS_140
    moveq #0,%d0
    rts

/*
 TRANSFER_96_BIOS: transfer d2 bytes at a2 with the routine selected by d4 (slow or
 fast read/write, compare), with our bus error handler installed for the pseudo-DMA.
 Out: d0 = error, d1 = bytes not transferred.
*/
TRANSFER_96_BIOS:
    linkw %fp,#-8
    moveq #5,%d0
    cmpib #4,CPUFlag
    jbne TRANSFER_96_BIOS_10
    moveq #1,%d0
TRANSFER_96_BIOS_10:    /* (68040) */
    clrl %fp@(-8)
    moveq #0,%d0
    movel %d2,%d1
    beqw TRANSFER_96_BIOS_68
    moveml %d2-%d6/%a1-%a5,%sp@-
    moveal %a3,%a1
    addal #262144,%a1
    jbsr HANDLESELINPROG_BIOS
    bnew TRANSFER_96_BIOS_6C
    moveb #1,%a3@(48)
    movel BusErrorVector,%a4@(448)
    movel %a4@(428),BusErrorVector
    bset #7,%a4@(344)
    movew %d4,%a4@(444)
    lea %a4@(164),%a0
    moveal %a0@(0x0,%d4:l),%a0
    jsr %a0@
TRANSFER_96_BIOS_56:    /* restore the bus error vector */
    bclr #7,%a4@(344)
    movel %a4@(448),BusErrorVector
    moveml %sp@+,%d2-%d6/%a1-%a5
    tstw %d0
TRANSFER_96_BIOS_68:    /* return */
    unlk %fp
    rts
TRANSFER_96_BIOS_6C:    /* selection failed: 5 */
    moveq #5,%d0
    moveq #0,%d1
    jbra TRANSFER_96_BIOS_56
TRANSFER_96_BIOS_72:    /* wrong phase: error 5 (240) */
    movel #240,%d6
    moveq #5,%d0
TRANSFER_96_BIOS_7A:    /* report, flush */
    jsr %pc@(ERROR_BIOS)
    moveq #0,%d1
    moveb #1,%a3@(48)
    rts

/*
 SLOWREAD_96_BIOS: polled read (scInc): 16 bytes at a time by pseudo-DMA when the chip
 has them, the rest byte by byte.
*/
SLOWREAD_96_BIOS:
    jbsr HANDLESELINPROG_BIOS
    jbne SLOWREAD_96_BIOS_11E
    moveq #7,%d0
    andb %a3@(64),%d0
    cmpiw #1,%d0
    jbne TRANSFER_96_BIOS_72
    lea %a1@(256),%a1
    moveq #0,%d6
    movel %d2,%d4
    lsrl #4,%d4
    jbeq SLOWREAD_96_BIOS_DE
    subql #1,%d4
    movel %d4,%d6
    swap %d6
    moveal %a4@(316),%a0
    moveb #1,%a3@(48)
    clrb %a3@(16)
    moveb #16,%a3@
    andil #15,%d2
SLOWREAD_96_BIOS_40:    /* next 16-byte block: still data in? */
    moveq #7,%d5
    andb %a3@(64),%d5
    cmpib #1,%d5
    jbne SLOWREAD_96_BIOS_10C
    moveb #0x90,%a3@(48)
    nop
SLOWREAD_96_BIOS_56:    /* wait for 16 bytes or the end */
    btst #4,%a3@(64)
    jbne SLOWREAD_96_BIOS_7C
    btst #7,%a3@(64)
    bnew SLOWREAD_96_BIOS_E6
    moveq #7,%d5
    andb %a3@(64),%d5
    cmpib #1,%d5
    jbeq SLOWREAD_96_BIOS_56
    tstb %a3@
    jbeq SLOWREAD_96_BIOS_56
    braw SLOWREAD_96_BIOS_E6
SLOWREAD_96_BIOS_7C:    /* data ready: read 4 longs */
    movel %a0@,%d5
    moveb %a4@(352),%d0
    btst %d0,%d5
    jbeq SLOWREAD_96_BIOS_56
    btst #4,%a3@(112)
    jbeq SLOWREAD_96_BIOS_56
    nop
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    nop
SLOWREAD_96_BIOS_9A:    /* wait for the block to complete */
    btst #7,%a3@(64)
    jbeq SLOWREAD_96_BIOS_9A
    moveb %a3@(80),%d5
    btst #5,%d5
    jbne SLOWREAD_96_BIOS_10C
    dbf %d4,SLOWREAD_96_BIOS_40
    dbf %d6,SLOWREAD_96_BIOS_40
    jbra SLOWREAD_96_BIOS_DE
SLOWREAD_96_BIOS_B6:    /* remaining bytes, one at a time */
    moveq #7,%d5
    andb %a3@(64),%d5
    cmpib #1,%d5
    jbne SLOWREAD_96_BIOS_11E
    moveb #16,%a3@(48)
SLOWREAD_96_BIOS_C8:    /* wait */
    btst #7,%a3@(64)
    jbeq SLOWREAD_96_BIOS_C8
    moveb %a3@(32),%a2@+
    moveb %a3@(80),%d5
    btst #5,%d5
    jbne SLOWREAD_96_BIOS_122
SLOWREAD_96_BIOS_DE:    /* (count): 0 */
    dbf %d2,SLOWREAD_96_BIOS_B6
    moveq #0,%d0
    rts
SLOWREAD_96_BIOS_E6:    /* early end: empty the FIFO */
    moveq #31,%d0
    andb %a3@(112),%d0
    jbra SLOWREAD_96_BIOS_F2
SLOWREAD_96_BIOS_EE:    /* one byte */
    moveb %a3@(32),%a2@+
SLOWREAD_96_BIOS_F2:    /* (count) */
    dbf %d0,SLOWREAD_96_BIOS_EE
SLOWREAD_96_BIOS_F6:    /* drain the pseudo-DMA register */
    movel %a0@,%d5
    moveb %a4@(352),%d0
    btst %d0,%d5
    jbeq SLOWREAD_96_BIOS_106
    movew %a3@(256),%d5
    jbra SLOWREAD_96_BIOS_F6
SLOWREAD_96_BIOS_106:   /* wait for the interrupt */
    jbsr WAITFORINTNOTIME
SLOWREAD_96_BIOS_10C:   /* bytes left */
    addqw #1,%d4
    swap %d6
    movew %d4,%d6
    lsll #4,%d6
    andib #7,%d5
    cmpib #1,%d5
    jbeq SLOWREAD_96_BIOS_122
SLOWREAD_96_BIOS_11E:   /* error 5 */
    moveq #5,%d0
    jbra SLOWREAD_96_BIOS_124
SLOWREAD_96_BIOS_122:   /* error 2 */
    moveq #2,%d0
SLOWREAD_96_BIOS_124:   /* report */
    addl %d2,%d6
    subl %d6,%d1
    moveq #5,%d6
    jsr %pc@(ERROR_BIOS)
    moveb #1,%a3@(48)
    rts

/*
 SLOWWRITE_96_BIOS: polled write: longs to the pseudo-DMA register (16 bytes per check),
 in 64 KB pieces.
*/
SLOWWRITE_96_BIOS:
    jbsr HANDLESELINPROG_BIOS	| 408D205C
    jbne SLOWWRITE_96_BIOS_E2	| 408D2060
    lea %a1@(256),%a1
    moveq #7,%d0
    andb %a3@(64),%d0
    jbne TRANSFER_96_BIOS_72
    cmpil #3,%d2
    jbgt SLOWWRITE_96_BIOS_22
    jbra SCSIHW96BIOS_B0
SLOWWRITE_96_BIOS_22:   /* misaligned start: bytes first */
    movel %a2,%d6
    andil #3,%d6
    jbne SLOWWRITE_96_BIOS_C4
SLOWWRITE_96_BIOS_2E:   /* 64 KB pieces */
    movel %d2,%d6
    swap %d6
    andil #65535,%d2
    jbeq SLOWWRITE_96_BIOS_B0
SLOWWRITE_96_BIOS_3A:   /* still data out? count, DMA transfer command */
    moveq #7,%d3
    andb %a3@(64),%d3
    jbne SLOWWRITE_96_BIOS_E2
    movel %d2,%d4
    moveb %d4,%a3@
    lsrl #8,%d4
    moveb %d4,%a3@(16)
    moveb #0x90,%a3@(48)
    nop
    movel %d2,%d4
    lsrl #4,%d4
    andil #15,%d2
    rorl #1,%d2
    movel %d2,%d5
    rorl #1,%d5
    negw %d5
    jmp %pc@(SLOWWRITE_96_BIOS_76,%d5:w:2)
SLOWWRITE_96_BIOS_6C:   /* 4 longs */
    nop
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
SLOWWRITE_96_BIOS_76:   /* interrupt (early end)? */
    nop
    btst #7,%a3@(64)
    jbne SLOWWRITE_96_BIOS_CC
    moveq #7,%d3
    andb %a3@(64),%d3
    jbne SLOWWRITE_96_BIOS_CC
    moveq #31,%d0
    andb %a3@(112),%d0
    jbne SLOWWRITE_96_BIOS_76
    dbf %d4,SLOWWRITE_96_BIOS_6C
    btst #31,%d5
    jbeq SLOWWRITE_96_BIOS_9E
    movew %a2@+,%a3@(256)
SLOWWRITE_96_BIOS_9E:   /* odd word */
    btst #31,%d2
    jbeq SLOWWRITE_96_BIOS_A8
    moveb %a2@+,%a3@(256)
SLOWWRITE_96_BIOS_A8:   /* wait for the end */
    jbsr WAITFORINTNOTIME
    jbne SLOWWRITE_96_BIOS_EC
SLOWWRITE_96_BIOS_B0:   /* next piece: 0 */
    movel #65536,%d2
    dbf %d6,SLOWWRITE_96_BIOS_3A
    moveq #0,%d0
    rts
SLOWWRITE_96_BIOS_BE:   /* one byte through the FIFO */
    subql #1,%d2
    moveb %a2@+,%a3@(32)
SLOWWRITE_96_BIOS_C4:   /* (alignment bytes) */
    dbf %d6,SLOWWRITE_96_BIOS_BE
    jbra SLOWWRITE_96_BIOS_2E
SLOWWRITE_96_BIOS_CC:   /* early interrupt: phase? */
    jbsr WAITFORINTNOTIME
    btst #4,%d5
    jbne SLOWWRITE_96_BIOS_B0
    moveq #7,%d3
    andb %d5,%d3
    cmpib #0,%d3
    jbeq SLOWWRITE_96_BIOS_EC
SLOWWRITE_96_BIOS_E2:   /* error 5 */
    moveq #5,%d0
    moveq #0,%d1
    clrl %a4@(324)
    jbra SLOWWRITE_96_BIOS_EE
SLOWWRITE_96_BIOS_EC:   /* error 2 */
    moveq #2,%d0
SLOWWRITE_96_BIOS_EE:   /* bytes left, report */
    lsll #4,%d4
    swap %d6
    movew %d4,%d6
    moveq #31,%d2
    andb %a3@(112),%d2
    addl %d2,%d6
    subl %d6,%d1
    clrl %a4@(324)
    moveq #6,%d6
    jsr %pc@(ERROR_BIOS)
    moveb #1,%a3@(48)
    rts

/*
 FASTWRITE_96_BIOS: blind write: 32 longs per pass to the pseudo-DMA register (the
 decoder holds the bus until the chip is ready, a bus error on a timeout).
*/
FASTWRITE_96_BIOS:
    jbsr HANDLESELINPROG_BIOS
    jbne FASTWRITE_96_BIOS_F4
    lea %a1@(256),%a1
    moveb #1,%a3@(48)
    moveq #7,%d0
    andb %a3@(64),%d0
    jbne TRANSFER_96_BIOS_72
    cmpil #3,%d2
    jbgt FASTWRITE_96_BIOS_28
    jbra SCSIHW96BIOS_B0
FASTWRITE_96_BIOS_28:   /* misaligned start */
    movel %a2,%d6
    andil #3,%d6
    jbne FASTWRITE_96_BIOS_EC
FASTWRITE_96_BIOS_34:   /* 64 KB pieces */
    movel %d2,%d6
    swap %d6
    andil #65535,%d2
    jbeq FASTWRITE_96_BIOS_CC
FASTWRITE_96_BIOS_42:   /* count, DMA transfer command */
    movel %d2,%d4
    moveb %d4,%a3@
    lsrl #8,%d4
    moveb %d4,%a3@(16)
    moveb #0x90,%a3@(48)
    movel %d2,%d4
    lsrl #7,%d4
    andil #127,%d2
    rorl #1,%d2
    movel %d2,%d3
    rorl #1,%d3
    negw %d3
    nop
    jmp %pc@(FASTWRITE_96_BIOS_AA,%d3:w:2)
FASTWRITE_96_BIOS_6A:   /* 32 longs */
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
    movel %a2@+,%a1@
FASTWRITE_96_BIOS_AA:   /* (count) */
    dbf %d4,FASTWRITE_96_BIOS_6A
    nop
    btst #31,%d3
    jbeq FASTWRITE_96_BIOS_BA
    movew %a2@+,%a3@(256)
FASTWRITE_96_BIOS_BA:   /* odd word */
    btst #31,%d2
    jbeq FASTWRITE_96_BIOS_C4
    moveb %a2@+,%a3@(256)
FASTWRITE_96_BIOS_C4:   /* wait for the end */
    jbsr WAITFORINTNOTIME
    jbne FASTWRITE_96_BIOS_F8
FASTWRITE_96_BIOS_CC:   /* next piece, FIFO empty? */
    movel #65536,%d2
    dbf %d6,FASTWRITE_96_BIOS_42
    moveq #31,%d2
    andb %a3@(112),%d2
    jbeq FASTWRITE_96_BIOS_E2
    moveq #5,%d0
    jbra FASTWRITE_96_BIOS_110
FASTWRITE_96_BIOS_E2:   /* 0 */
    moveq #0,%d0
    rts
FASTWRITE_96_BIOS_E6:   /* alignment byte */
    subql #1,%d2
    moveb %a2@+,%a3@(32)
FASTWRITE_96_BIOS_EC:   /* (count) */
    dbf %d6,FASTWRITE_96_BIOS_E6
    jbra FASTWRITE_96_BIOS_34
FASTWRITE_96_BIOS_F4:   /* error 5 */
    moveq #5,%d0
    jbra FASTWRITE_96_BIOS_FA
FASTWRITE_96_BIOS_F8:   /* error 2 */
    moveq #2,%d0
FASTWRITE_96_BIOS_FA:   /* bytes left */
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
FASTWRITE_96_BIOS_110:  /* report */
    clrl %a4@(324)
    moveq #9,%d6
    jsr %pc@(ERROR_BIOS)
    moveb #1,%a3@(48)
    rts

/* FASTREAD_96_BIOS: blind read: 32 longs per pass from the pseudo-DMA register. */
FASTREAD_96_BIOS:
    jbsr HANDLESELINPROG_BIOS
    jbne FASTREAD_96_BIOS_11A
    lea %a1@(256),%a1
    moveb #1,%a3@(48)
    moveq #7,%d0
    andb %a3@(64),%d0
    cmpib #1,%d0
    jbne TRANSFER_96_BIOS_72
    cmpil #3,%d2
    jbgt FASTREAD_96_BIOS_2C
    jbra SCSIHW96BIOS_86
FASTREAD_96_BIOS_2C:    /* misaligned start */
    movel %a2,%d6
    andil #3,%d6
    jbne FASTREAD_96_BIOS_10E
FASTREAD_96_BIOS_38:    /* 64 KB pieces */
    movel %d2,%d6
    swap %d6
    andil #65535,%d2
    jbeq FASTREAD_96_BIOS_DE
FASTREAD_96_BIOS_46:    /* count, DMA transfer command */
    movel %d2,%d4
    moveb %d4,%a3@
    lsrl #8,%d4
    moveb %d4,%a3@(16)
    moveb #0x90,%a3@(48)
    movel %d2,%d4
    lsrl #7,%d4
    andil #127,%d2
    rorl #1,%d2
    movel %d2,%d3
    rorl #1,%d3
    negw %d3
    nop
    jmp %pc@(FASTREAD_96_BIOS_AE,%d3:w:2)
FASTREAD_96_BIOS_6E:    /* 32 longs */
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
    movel %a1@,%a2@+
FASTREAD_96_BIOS_AE:    /* (count), odd word */
    dbf %d4,FASTREAD_96_BIOS_6E
    nop
    btst #31,%d3
    jbeq FASTREAD_96_BIOS_C4
    jbsr WTFORFIFODATA
    jbeq FASTREAD_96_BIOS_116
    movew %a1@,%a2@+
FASTREAD_96_BIOS_C4:    /* wait for the end, odd byte */
    jbsr WAITFORINTNOTIME
    jbne FASTREAD_96_BIOS_11E
    btst #31,%d2
    jbeq FASTREAD_96_BIOS_DE
    jbsr WTFORFIFODATA
    jbeq FASTREAD_96_BIOS_116
    moveb %a3@(32),%a2@+
FASTREAD_96_BIOS_DE:    /* next piece, 0 */
    movel #65536,%d2
    dbf %d6,FASTREAD_96_BIOS_46
    moveq #0,%d0
    rts
FASTREAD_96_BIOS_EC:    /* alignment byte */
    moveb #16,%a3@(48)
    jbsr WAITFORINTNOTIME
    jbne FASTREAD_96_BIOS_11E
    moveb %a3@(32),%a2@+
    moveb %a3@(80),%d3
    btst #5,%d3
    bnel FASTREAD_96_BIOS_11E
    subql #1,%d2
FASTREAD_96_BIOS_10E:   /* (count) */
    dbf %d6,FASTREAD_96_BIOS_EC
    jbra FASTREAD_96_BIOS_38
FASTREAD_96_BIOS_116:   /* FIFO timeout: 9 */
    moveq #9,%d0
    jbra FASTREAD_96_BIOS_120
FASTREAD_96_BIOS_11A:   /* error 5 */
    moveq #5,%d0
    jbra FASTREAD_96_BIOS_120
FASTREAD_96_BIOS_11E:   /* error 2 */
    moveq #2,%d0
FASTREAD_96_BIOS_120:   /* bytes left, report */
    swap %d6
    movew %d4,%d6
    lsll #5,%d6
    extl %d2
    addql #1,%d2
    addl %d2,%d6
    subl %d6,%d1
    clrl %a4@(324)
    moveq #8,%d6
    jsr %pc@(ERROR_BIOS)
    moveb #1,%a3@(48)
    rts
FASTREAD_96_BIOS_140:   /* error 2 (240) */
    movel #240,%d6
    moveq #2,%d0
    jbra TRANSFER_96_BIOS_7A

/* RESETBUS_96_BIOS: chip command 3: reset the SCSI bus. */
RESETBUS_96_BIOS:
    moveb #3,%a3@(48)
    rts

/*
 HANDLESELINPROG_BIOS: finish a selection still in progress (wait for the phase the
 selection leads to). Out: Z set if the bus is in that phase.
*/
HANDLESELINPROG_BIOS:
    btst #3,%a4@(344)
    beqw HANDLESELINPROG_BIOS_42
    btst #2,%a4@(344)
    jbeq HANDLESELINPROG_BIOS_18
    moveb #6,%d1
    jbra HANDLESELINPROG_BIOS_24
HANDLESELINPROG_BIOS_18:  /* (with ATN: message out) */
    btst #1,%a4@(344)
    jbeq HANDLESELINPROG_BIOS_44
    moveb #2,%d1
HANDLESELINPROG_BIOS_24:  /* wait for REQ in the phase, or an interrupt */
    jbsr WT4DREQORINT_BIOS
    jbne HANDLESELINPROG_BIOS_42
HANDLESELINPROG_BIOS_28:  /* clear the selection state */
    bclr #4,%a4@(344)
    bclr #3,%a4@(344)
    bclr #2,%a4@(344)
    bclr #1,%a4@(344)
    tstb %d0
HANDLESELINPROG_BIOS_42:  /* return */
    rts
HANDLESELINPROG_BIOS_44:  /* (selection complete: wait for the interrupt, flush) */
    jbsr WAITFORINTNOTIME
    moveb #1,%a3@(48)
    moveq #0,%d0
    jbra HANDLESELINPROG_BIOS_28

/*
 WT4DREQORINT_BIOS: wait until the chip asserts DREQ in phase d1 (Z clear, d0 = 1),
 or an interrupt (d0 = the interrupt status bytes, Z set).
*/
WT4DREQORINT_BIOS:
    moveq #0,%d5
    moveb %a3@(64),%d5
    btst #7,%d5
    jbne WT4DREQORINT_BIOS_2A
    moveal %a4@(316),%a0
    movel %a0@,%d5
    moveb %a4@(352),%d0
    btst %d0,%d5
    jbeq WT4DREQORINT_BIOS
    moveb %a3@(64),%d3
    andib #7,%d3
    cmpb %d3,%d1
    jbne WT4DREQORINT_BIOS
    moveq #1,%d3
    jbra WT4DREQORINT_BIOS_3C
WT4DREQORINT_BIOS_2A:   /* interrupt */
    swap %d5
    moveb %a3@(112),%d5
    lslw #8,%d5
    moveb %a3@(80),%d5
    movel %d5,%d0
    swap %d5
    moveq #0,%d3
WT4DREQORINT_BIOS_3C:   /* return */
    movel %d3,%d0
    rts

/*
 FASTCOMP_96_BIOS: compare (scComp) blind: read words and compare. Out: 0, 6 if
 different, or an error.
*/
FASTCOMP_96_BIOS:
    jbsr HANDLESELINPROG_BIOS	| 408D2476
    bnew FASTCOMP_96_BIOS_76	| 408D247A
    moveq #7,%d0	| 408D247E
    andb %a3@(64),%d0	| 408D2480
    cmpib #1,%d0	| 408D2484
    jbne TRANSFER_96_BIOS_72	| 408D2488
    cmpil #1,%d2	| 408D248C
    jbeq SLOWCOMP_96_BIOS	| 408D2492
    moveq #0,%d3	| 408D2496
    movel %d2,%d6	| 408D2498
    swap %d6	| 408D249A
    andil #65535,%d2	| 408D249C
    jbeq FASTCOMP_96_BIOS_68	| 408D24A2
FASTCOMP_96_BIOS_2E:    /* 64 KB pieces */
    movel %d2,%d4
    moveb %d4,%a3@
    lsrl #8,%d4
    moveb %d4,%a3@(16)
    moveb #0x90,%a3@(48)
    rorl #1,%d2
    subqw #1,%d2
FASTCOMP_96_BIOS_42:    /* one word */
    movew %a3@(256),%d0
    cmpw %a2@+,%d0
    jbeq FASTCOMP_96_BIOS_4C
    moveq #6,%d3
FASTCOMP_96_BIOS_4C:    /* (count) */
    dbf %d2,FASTCOMP_96_BIOS_42
    jbsr WAITFORINTNOTIME
    jbne FASTCOMP_96_BIOS_7A
    btst #31,%d2
    jbeq FASTCOMP_96_BIOS_68
    moveb %a3@(32),%d0
    cmpb %a2@+,%d0
    jbeq FASTCOMP_96_BIOS_68
    moveq #6,%d3
FASTCOMP_96_BIOS_68:    /* next piece */
    movel #65536,%d2
    dbf %d6,FASTCOMP_96_BIOS_2E
    movel %d3,%d0
    rts
FASTCOMP_96_BIOS_76:    /* phase changed: 5 (scPhaseErr) */
    moveq #5,%d0
    jbra FASTCOMP_96_BIOS_7C
FASTCOMP_96_BIOS_7A:    /* error 2 */
    moveq #2,%d0
FASTCOMP_96_BIOS_7C:    /* report */
    swap %d6
    movew %d4,%d6
    lsll #5,%d6
    extl %d2
    addql #1,%d2
    addl %d2,%d6
    subl %d6,%d1
    clrl %a4@(324)
    movel #248,%d6
    jsr %pc@(ERROR_BIOS)
    moveb #1,%a3@(48)
    rts

/* SLOWCOMP_96_BIOS: compare polled. */
SLOWCOMP_96_BIOS:
    jbsr HANDLESELINPROG_BIOS	| 408D2516
    jbne SLOWCOMP_96_BIOS_D4	| 408D251A
    moveq #7,%d0	| 408D251E
    andb %a3@(64),%d0	| 408D2520
    cmpiw #1,%d0	| 408D2524
    jbne TRANSFER_96_BIOS_72	| 408D2528
    moveq #0,%d3	| 408D252C
    movel %d2,%d4	| 408D252E
    lsrl #4,%d4	| 408D2530
    jbeq SLOWCOMP_96_BIOS_B4	| 408D2532
    subql #1,%d4	| 408D2536
    movel %d4,%d6	| 408D2538
    swap %d6	| 408D253A
    moveal %a4@(316),%a0	| 408D253C
    clrb %a3@(16)	| 408D2540
    moveb #16,%a3@	| 408D2544
    andil #15,%d2	| 408D2548
SLOWCOMP_96_BIOS_38:    /* next block */
    moveb #0x90,%a3@(48)
SLOWCOMP_96_BIOS_3E:    /* wait for 16 bytes */
    btst #7,%a3@(64)
    jbne SLOWCOMP_96_BIOS_BC
    btst #4,%a3@(64)
    jbeq SLOWCOMP_96_BIOS_3E
    movel %a0@,%d5
    moveb %a4@(352),%d0
    btst %d0,%d5
    jbeq SLOWCOMP_96_BIOS_3E
    movew #7,%d5
SLOWCOMP_96_BIOS_5C:    /* 8 words */
    movew %a3@(256),%d0
    cmpw %a2@+,%d0
    jbeq SLOWCOMP_96_BIOS_66
    moveq #6,%d3
SLOWCOMP_96_BIOS_66:    /* (count) */
    dbf %d5,SLOWCOMP_96_BIOS_5C
SLOWCOMP_96_BIOS_6A:    /* wait for the block */
    btst #7,%a3@(64)
    jbeq SLOWCOMP_96_BIOS_6A
    moveb %a3@(80),%d5
    btst #5,%d5
    jbne SLOWCOMP_96_BIOS_C2
    dbf %d4,SLOWCOMP_96_BIOS_38
    dbf %d6,SLOWCOMP_96_BIOS_38
    jbra SLOWCOMP_96_BIOS_B4
SLOWCOMP_96_BIOS_86:    /* remaining bytes */
    moveq #7,%d5
    andb %a3@(64),%d5
    cmpib #1,%d5
    jbne SLOWCOMP_96_BIOS_D4
    moveb #16,%a3@(48)
SLOWCOMP_96_BIOS_98:    /* wait */
    btst #7,%a3@(64)
    jbeq SLOWCOMP_96_BIOS_98
    moveb %a3@(32),%d0
    cmpb %a2@+,%d0
    jbeq SLOWCOMP_96_BIOS_AA
    moveq #6,%d3
SLOWCOMP_96_BIOS_AA:    /* (next) */
    moveb %a3@(80),%d5
    btst #5,%d5
    jbne SLOWCOMP_96_BIOS_D8
SLOWCOMP_96_BIOS_B4:    /* (count): result */
    dbf %d2,SLOWCOMP_96_BIOS_86
    movel %d3,%d0
    rts
SLOWCOMP_96_BIOS_BC:    /* early end */
    jbsr WAITFORINTNOTIME
SLOWCOMP_96_BIOS_C2:    /* bytes left */
    addqw #1,%d4
    swap %d6
    movew %d4,%d6
    lsll #4,%d6
    andib #7,%d5
    cmpib #1,%d5
    jbeq SLOWCOMP_96_BIOS_D8
SLOWCOMP_96_BIOS_D4:    /* error 5 */
    moveq #5,%d0
    jbra SLOWCOMP_96_BIOS_DA
SLOWCOMP_96_BIOS_D8:    /* error 2 */
    moveq #2,%d0
SLOWCOMP_96_BIOS_DA:    /* report */
    addl %d2,%d6
    subl %d6,%d1
    movel #245,%d6
    jsr %pc@(ERROR_BIOS)
    moveb #1,%a3@(48)
    rts

/*
 BUSERRHANDLER_96_BIOS: bus error during a pseudo-DMA transfer (the chip was not
 ready in time): if the decoder says so, wait for the chip, redo the faulted writes
 from the 68040 frame (or complete a read) and return to the instruction; if the
 transfer ended, abort it and return error 9 or 5. Otherwise the saved handler.
*/
BUSERRHANDLER_96_BIOS:
    subql #4,%sp
    moveml %d0-%d3/%a0-%a3,%sp@-
    moveal ToolDispTable,%a3
    lea %sp@(36),%a0
    cmpal SCSIGlobals,%a4
    jbne BUSERRHANDLER_96_BIOS_2A
    btst #7,%a4@(344)
    jbeq BUSERRHANDLER_96_BIOS_2A
    lea 0x50f18000,%a1
    btst #0,%a1@(768)
    jbne BUSERRHANDLER_96_BIOS_3A
BUSERRHANDLER_96_BIOS_2A:  /* not ours: the previous handler */
    moveal SCSIGlobals,%a0
    movel %a0@(448),%sp@(32)
    moveml %sp@+,%d0-%d3/%a0-%a3
    rts
BUSERRHANDLER_96_BIOS_3A:  /* wait for DREQ or the end */
    moveal %a4@(316),%a1
    moveb %a4@(352),%d3
BUSERRHANDLER_96_BIOS_42:  /* poll */
    movel %a1@,%d0
    btst %d3,%d0
    jbne BUSERRHANDLER_96_BIOS_54
    btst #7,%a3@(64)
    jbne BUSERRHANDLER_96_BIOS_F6
    jbra BUSERRHANDLER_96_BIOS_42
BUSERRHANDLER_96_BIOS_54:  /* redo the pending writes of the frame */
    movew %a0@(18),%d0
    moveal %a0@(40),%a1
    movel %a0@(44),%d1
    jbsr BUSERRHANDLER_96_BIOS_16C
    movew %a0@(16),%d0
    moveal %a0@(32),%a1
    movel %a0@(36),%d1
    jbsr BUSERRHANDLER_96_BIOS_16C
    movew %a0@(14),%d0
    moveal %a0@(24),%a1
    movel %a0@(28),%d1
    jbsr BUSERRHANDLER_96_BIOS_16C
    lea 0x50f18000,%a1
    cmpiw #40,%a4@(444)
    jbeq BUSERRHANDLER_96_BIOS_BA
    btst #2,%a1@(768)
    jbeq BUSERRHANDLER_96_BIOS_EE
    movel %a0@(2),%d0
    clrw %a0@(58)
    movel %d0,%a0@(54)
    movew %a0@,%a0@(52)
    clrw %a1@(768)
    moveml %sp@+,%d0-%d3/%a0-%a3
    addql #4,%sp
    lea %sp@(52),%sp
    rte
BUSERRHANDLER_96_BIOS_BA:  /* (read: complete it) */
    btst #1,%a1@(768)
    jbeq BUSERRHANDLER_96_BIOS_EE
    movew %a1@(1024),%a2@+
    movew %a3@(256),%a2@+
    movel %a0@(2),%d0
    addqw #2,%d0
    clrw %a0@(58)
    movel %d0,%a0@(54)
    movew %a0@,%a0@(52)
    clrw %a1@(768)
    moveml %sp@+,%d0-%d3/%a0-%a3
    addql #4,%sp
    addql #4,%a2
    lea %sp@(52),%sp
    rte
BUSERRHANDLER_96_BIOS_EE:  /* return to the instruction */
    moveml %sp@+,%d0-%d3/%a0-%a3
    addql #4,%sp
    rte
BUSERRHANDLER_96_BIOS_F6:  /* transfer ended: drain the FIFO, abort */
    moveml %sp@+,%d0-%d3/%a0-%a3
    addql #4,%sp
    cmpiw #40,%a4@(444)
    jbne BUSERRHANDLER_96_BIOS_120
    moveb %a3@(112),%d0
    andiw #31,%d0
    rorl #1,%d0
    jbra BUSERRHANDLER_96_BIOS_114
BUSERRHANDLER_96_BIOS_110:  /* one word */
    movew %a3@(256),%a2@+
BUSERRHANDLER_96_BIOS_114:  /* (count) */
    dbf %d0,BUSERRHANDLER_96_BIOS_110
    tstl %d0
    jbpl BUSERRHANDLER_96_BIOS_120
    moveb %a3@(32),%a2@+
BUSERRHANDLER_96_BIOS_120:  /* flush, drop the frame (by format) */
    moveb #1,%a3@(48)
    movew %sp@,%d0
    bfextu %sp@(6),0,4,%d1
    cmpib #7,%d1
    jbeq BUSERRHANDLER_96_BIOS_140
    cmpib #10,%d1
    jbne BUSERRHANDLER_96_BIOS_146
    lea %sp@(32),%sp
    jbra BUSERRHANDLER_96_BIOS_14A
BUSERRHANDLER_96_BIOS_140:  /* (format 7) */
    lea %sp@(60),%sp
    jbra BUSERRHANDLER_96_BIOS_14A
BUSERRHANDLER_96_BIOS_146:  /* (other format) */
    lea %sp@(92),%sp
BUSERRHANDLER_96_BIOS_14A:  /* return to the abort routine */
    movew %d7,%sp@-
    pea %pc@(BUSERRHANDLER_96_BIOS_154)
    movew %d0,%sp@-
    rte
BUSERRHANDLER_96_BIOS_154:  /* abort: 9, or 5 if the phase changed */
    moveq #9,%d0
    btst #7,%a3@(64)
    jbeq BUSERRHANDLER_96_BIOS_16A
    moveb %a3@(80),%d5
    btst #4,%d5
    jbeq BUSERRHANDLER_96_BIOS_16A
    moveq #5,%d0
BUSERRHANDLER_96_BIOS_16A:  /* return */
    rts

BUSERRHANDLER_96_BIOS_16C:  /* redo one pending write (byte, word or long) from the frame */
    movel %a2,%sp@-
    btst #7,%d0
    jbeq BUSERRHANDLER_96_BIOS_1AA
    andiw #96,%d0
    cmpiw #32,%d0
    jbne BUSERRHANDLER_96_BIOS_182
    moveb %d1,%a1@
    jbra BUSERRHANDLER_96_BIOS_1AA
BUSERRHANDLER_96_BIOS_182:  /* (word) */
    cmpiw #64,%d0
    jbne BUSERRHANDLER_96_BIOS_18C
    movew %d1,%a1@
    jbra BUSERRHANDLER_96_BIOS_1AA
BUSERRHANDLER_96_BIOS_18C:  /* (long) */
    cmpiw #0,%d0
    jbne BUSERRHANDLER_96_BIOS_1AA
    lea 0x50f18000,%a2
    btst #2,%a2@(768)
    jbne BUSERRHANDLER_96_BIOS_1A4
    movel %d1,%a1@
    jbra BUSERRHANDLER_96_BIOS_1AA
BUSERRHANDLER_96_BIOS_1A4:  /* (as two words) */
    movew %d1,%a1@
    clrw %a2@(768)
BUSERRHANDLER_96_BIOS_1AA:  /* return */
    moveal %sp@+,%a2
    rts
    .fill   0x48, 1, 0x00
BUSERRHANDLER_96_BIOS_1F6:  /* 4 bytes before CPUIDPRODUCTLOOKUP: GETHARDWAREINFOPATCH walks that list from here */
    .long   0x00000000	| 408D27FC
