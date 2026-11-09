/*
 patches/slotpatches.s - Slot Manager patches
 From SLOTMGRPATCH (0x4088BC00). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the Slot Manager chapter of Designing Cards
 and Drivers), not taken from Apple. a0 is usually a Slot Manager parameter block
 (+4 spsPointer, +12 spOffsetData, +20 spsExecPBlk, +24 spParamData, +40..46 category,
 type, DrSW, DrHW, +48 spTBMask, +49 spSlot, +50 spID, +51 spExtDev, +54 spFlags).
 Low memory 0xDB8 holds the Slot Manager's globals, with its internal vectors at
 +0x3C..+0xEC; 0xCBC the slot information table (one pointer per slot), 0xD04 the
 slot VBL/interrupt queue table.
*/

/*
 SLOTEXECPATCH: sExec: flush the caches (the code was just loaded) and call it with
 a0 = its parameter block, all registers preserved. Result 0.
*/
SLOTMGRPATCH:
SLOTEXECPATCH:
    moveml %d0-%fp,%sp@-
    jbsr CACHEFLUSH
    moveal %a0@(20),%a0
    jsr %a2@
    moveml %sp@+,%d0-%fp
    moveq #0,%d0
    rts

/*
 STATLOADPATCH: after loading a static block of code: store its pointer and flush the
 caches.
*/
STATLOADPATCH:
    movel %a3,%a0@
    jbsr CACHEFLUSH
    rts

/*
 INITSLOTINTSPATCH: choose the slot interrupt handler: without a VIA 2 (0xDD2 bit 3)
 INTHANDLERNOVIA2; with a VIA 2 the one below; with an RBV (0xDD5 bit 5) the other.
*/
INITSLOTINTSPATCH:
    btst #3,0xdd2
    jbeq INTHANDLERNOVIA2
    btst #2,0xdd0
    jbeq INITSLOTINTSPATCH_1E
    lea %pc@(INITSLOTINTSPATCH_34),%a0
    jbra GOTSLOTHANDLER
INITSLOTINTSPATCH_1E:   /* RBV? */
    btst #5,0xdd5
    jbeq GOTSLOTHANDLER
    lea %pc@(INITSLOTINTSPATCH_4A),%a0
    jbra GOTSLOTHANDLER
INITSLOTINTSPATCH_34:   /* VIA 2 slot interrupt: acknowledge, read the slot lines (port A), go to the common handler if any is low */
    moveb #2,%a1@(6656)
    moveq #-128,%d0
    orb %a1@(7680),%d0
    notl %d0
    jbne SLOTINTCOMMON
    rts
INITSLOTINTSPATCH_4A:   /* the same for another interrupt controller (at 0xFEE00000) */
    moveb #2,%a1@(6656)	| 4088BC6C
    lea 0xfee00000,%a0	| 4088BC72
    btst #1,%a0@(3)	| 4088BC78
    jbeq INITSLOTINTSPATCH_72	| 4088BC7E
    moveq #0,%d0	| 4088BC80
    btst #6,%a0@(2)	| 4088BC82
    jbne INITSLOTINTSPATCH_72	| 4088BC88
    orib #32,%d0	| 4088BC8A
    jbra SLOTINTCOMMON	| 4088BC8E
INITSLOTINTSPATCH_72:   /* no slot interrupt pending: return */
    rts	| 4088BC94

/*
 INITJMPTBLPATCH: on a 68040, install a bus error filter in the Slot Manager's vector
 (+0xE4) for NuBus accesses.
*/
INITJMPTBLPATCH:
    cmpib #4,CPUFlag
    jbne INITJMPTBLPATCH_14
    lea %pc@(INITJMPTBLPATCH_1C),%a0
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    movel %a0,@(SDMJmpTblPtr,%za0)@(0xe4)	| 4088BCA2
INITJMPTBLPATCH_14:     /* not a 68040: the standard PBUSEXCEPTION stays; return no error */
    moveml %sp@+,%a0-%a2
    moveq #0,%d0
    rts
INITJMPTBLPATCH_1C:     /* the filter: a data read fault (68040 frame) on a slot address 0x9x..0xFE: skip it (return to a2), else the normal bus error handler */
    movel %d0,%sp@-
    movew %sp@(16),%d0
    andiw #1304,%d0
    cmpiw #256,%d0
    jbne INITJMPTBLPATCH_56
    moveb %sp@(10),%d0
    lsrb #4,%d0
    cmpib #7,%d0
    jbne INITJMPTBLPATCH_56
    moveb %sp@(24),%d0
    cmpib #0x90,%d0
    jbcs INITJMPTBLPATCH_56
    cmpib #0xff,%d0
    jbeq INITJMPTBLPATCH_56
    cmpib #0xf0,%d0
    jbeq INITJMPTBLPATCH_56
    movel %a2,%sp@(6)
    movel %sp@+,%d0
    rte
INITJMPTBLPATCH_56:     /* not ours: the saved handler */
    movel %sp@+,%d0
    movel @(SInfoPtr,%za0)@(0xfffffffffffffff8),%sp@-	| 4088BCEE
    rts
    .long   0x00000000, 0x00000000	| 4088BCF8
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4088BD00
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4088BD10
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 4088BD20

INITJMPTBLPATCH_9A:     /* find a card in the patch table (STARTSDECLMGRPATCH_AA: category, type, DrSW, DrHW, driver version) for the slot in a0: its index, or -1 */
    moveml %d3-%d4/%a3-%a5,%sp@-
    linkw %fp,#-56
    moveal %a0,%a3
    moveal %sp,%a0
    lea %pc@(STARTSDECLMGRPATCH_AA),%a4
    moveq #0,%d3
INITJMPTBLPATCH_AC:     /* next table entry: sNextTypesRsrc in the slot */
    moveb %a3@(49),%a0@(49)
    clrw %a0@(50)
    clrb %a0@(48)
    movew %a4@,%a0@(40)
    movew %a4@(2),%a0@(42)
    movew %a4@(4),%a0@(44)
    movew %a4@(6),%a0@(46)
    clrl %a0@(24)
    bset #1,%a0@(27)
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */
    _SlotManager
    jbne INITJMPTBLPATCH_116
    moveml %d1-%d2/%a1,%sp@-
    bsrl SLOTGETDRIVERPATCH_E
    tstw %d0
    moveml %sp@+,%d1-%d2/%a1
    jbne INITJMPTBLPATCH_120
    moveal %a0@,%a5
    moveal %a5@,%a0
    lea %a0@(18),%a0
    clrw %d0
    moveb %a0@,%d0
    addqw #2,%d0
    bclr #0,%d0
    movew %a0@(0x0,%d0:w),%d4
    moveal %a5,%a0
    _DisposHandle
    cmpw %a4@(8),%d4
    jbne INITJMPTBLPATCH_116
    movel %d3,%d0
    jbra INITJMPTBLPATCH_122
INITJMPTBLPATCH_116:    /* next entry */
    lea %a4@(10),%a4
    addqw #1,%d3
    tstw %a4@
    jbne INITJMPTBLPATCH_AC
INITJMPTBLPATCH_120:    /* not found: -1 */
    moveq #-1,%d0
INITJMPTBLPATCH_122:    /* return (d0 = the index, or -1) */
    unlk %fp
    moveml %sp@+,%d3-%d4/%a3-%a5
    rts

INITJMPTBLPATCH_12A:    /* run the replacement PrimaryInit of a known card (table STARTSDECLMGRPATCH_DA) instead of the card's */
    moveml %d1/%d3/%a0-%a3,%sp@-
    moveal %a0,%a3
    jbsr INITJMPTBLPATCH_9A
    movel %d0,%d3
    jbmi INITJMPTBLPATCH_156
    lea %pc@(STARTSDECLMGRPATCH_DA),%a1
    lsll #2,%d3
    moveal %a1,%a0
    addal %d3,%a0
    addal %a0@,%a1
    moveal %a3,%a0
    moveb %a0@(49),%a2@
    moveb %a0@(54),%a2@(4)
    moveal %a2,%a0
    jsr %a1@
    movel %d3,%d0
INITJMPTBLPATCH_156:    /* return (d0 = the index, negative if the card is not known) */
    moveml %sp@+,%d1/%d3/%a0-%a3
    rts

/*
 SLOTPRIMARYINITPATCH: PrimaryInit of a card: the ROM's replacement for a known card,
 else the card's own (sExec). Status and flags recorded in the slot's sInfo record
 (-316: PrimaryInit failed).
*/
SLOTPRIMARYINITPATCH:
    moveal %sp@+,%a2
    jbsr INITJMPTBLPATCH_12A
    tstb %d0
    jbpl SLOTPRIMARYINITPATCH_1A
    movel %a3,%a0@(4)
    moveb %a0@(49),%a2@
    moveb %a0@(54),%a2@(4)
    moveq #35,%d0	/* _SlotManager 35: SLOTEXEC, sExec */
    _SlotManager
SLOTPRIMARYINITPATCH_1A:  /* record the result */
    moveb #3,%a1@(8)	/* siState = statePInit */
    movew %a2@(2),%a1@(6)	/* siInitStatusV = seStatus */
    jbpl SLOTPRIMARYINITPATCH_2E
    movew #-316,%a1@(4)	/* negative: siInitStatusA = -316 (smInitStatVErr) */
SLOTPRIMARYINITPATCH_2E:/* return */
    rts

SLOTPRIMARYINITPATCH_30:  /* replacement driver for a known card (table STARTSDECLMGRPATCH_C2): copy it from the ROM into a new handle. Result 0 or -345 */
    moveml %d3-%d4/%a0/%a3-%a5,%sp@-
    linkw %fp,#-56
    moveal %a0,%a3
    jbsr INITJMPTBLPATCH_9A
    movel %d0,%d3
    jbmi SLOTPRIMARYINITPATCH_B4
    lea %pc@(STARTSDECLMGRPATCH_C2),%a1
    muluw #12,%d3
    moveal %a1,%a0
    moveb %a0@(0x8,%d3:w),%d0
    moveb %a0@(0x9,%d3:w),%d1
    moveq #0,%d4
    moveb %d0,%d4
    swap %d4
    moveb %d1,%d4
    moveal %sp,%a0
    moveb %a3@(49),%a0@(49)
    moveb %a3@(50),%a0@(50)
    moveb %d4,%a0@(51)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    jbne SLOTPRIMARYINITPATCH_AE
    swap %d4
    moveb %d4,%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne SLOTPRIMARYINITPATCH_AE
    moveal %a1,%a4
    addal %a1@(0x0,%d3:w),%a4
    moveal %a1,%a0
    addal %a1@(0x4,%d3:w),%a0
    movel %a0@,%d3
    movel %d3,%d0
    .short  0xA440	| 4088BE82 _ResrvMem (flags 0x0400)
    jbne SLOTPRIMARYINITPATCH_AE
    movel %d3,%d0
    .short  0xA522	| 4088BE88 _NewHandle (flags 0x0500)
    jbne SLOTPRIMARYINITPATCH_AE
    moveal %a0,%a5
    _HNoPurge
    moveal %a4,%a0
    moveal %a5@,%a1
    movel %d3,%d0
    _BlockMove
    moveal %a3,%a0
    movel %a5,%a0@
    moveq #0,%d0
    jbra SLOTPRIMARYINITPATCH_B4
SLOTPRIMARYINITPATCH_AE:  /* failed: -345 (smsGetDrvrErr) */
    movel #-345,%d0
SLOTPRIMARYINITPATCH_B4:/* return (d0 = 0 and spResult = the handle, or the error) */
    unlk %fp
    moveml %sp@+,%d3-%d4/%a0/%a3-%a5
    rts

/*
 SLOTGETDRIVERPATCH: sGetDriver: the ROM's replacement driver for a known card, else the
 card's own.
*/
SLOTGETDRIVERPATCH:
    jbsr SLOTPRIMARYINITPATCH_30
    tstb %d0
    jbmi SLOTGETDRIVERPATCH_E
    jbra ENDGETSLOTDRVR

SLOTGETDRIVERPATCH_E:   /* the original sGetDriver */
    moveml %a2-%a3,%sp@-
    moveal %a0,%a1
    jbra ORIGGETSLOTDRVR

/*
 ADDCARD: add a card at run time (docking, hot plug): initialise its slot
 through the Slot Manager's internal vectors, PrimaryInit, VBL queue.
*/
ADDCARD:
    moveml %d1/%a0/%a2,%sp@-	| 4088BEC8
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */	| 4088BECC
    _SlotManager	| 4088BECE
    jbne ADDCARD_90	| 4088BED0
    moveal %a0@,%a2	| 4088BED4
    movew #-337,%d0	| 4088BED6
    cmpiw #-300,%a2@(4)	| 4088BEDA
    jbne ADDCARD_90	| 4088BEE0
    pea %pc@(ADDCARD_28)	| 4088BEE2
    movel @(SDMJmpTblPtr,%za0)@(0x80),%sp@-	| 4088BEE6 call INITSINFO
    rts	| 4088BEEE
ADDCARD_28:             /* then its sResources into the SRT (INITSRSRC); the raw words after it: its PRAM (INITSPRAM), the PrimaryInit (INITPRIMARY, fWarmStart if 'WLSC') with interrupts at level 7, the SecondaryInit (vector 0x3C) */
    pea %pc@(ADDCARD_36)	| 4088BEF0
    movel @(SDMJmpTblPtr,%za0)@(0xa4),%sp@-	| 4088BEF4 call INITSRSRC
    rts	| 4088BEFC
ADDCARD_36:             /* (data) */
    .byte   0x48, 0x7A, 0x00, 0x0C, 0x2F, 0x30, 0x81, 0xE2, 0x0D, 0xB8, 0x00, 0x94, 0x4E, 0x75, 0x42, 0x28	| 4088BEFE
    .byte   0x00, 0x36, 0x0C, 0xB8, 0x57, 0x4C, 0x53, 0x43, 0x0C, 0xFC, 0x66, 0x06, 0x08, 0xE8, 0x00, 0x02	| 4088BF0E
    .byte   0x00, 0x36, 0x40, 0xE7, 0x00, 0x7C, 0x07, 0x00, 0x48, 0x7A, 0x00, 0x0C, 0x2F, 0x30, 0x81, 0xE2	| 4088BF1E
    .byte   0x0D, 0xB8, 0x00, 0x84, 0x4E, 0x75, 0x46, 0xDF, 0x4F, 0xEF, 0xFF, 0xE8, 0x24, 0x4F, 0x21, 0x4A	| 4088BF2E
    .byte   0x00, 0x14, 0x15, 0x7C, 0x00, 0x20, 0x00, 0x01, 0x48, 0x7A, 0x00, 0x0C, 0x2F, 0x30, 0x81, 0xE2	| 4088BF3E
    .byte   0x0D, 0xB8, 0x00, 0x3C, 0x4E, 0x75, 0x4F, 0xEF, 0x00, 0x18	| 4088BF4E
ADDCARD_90:             /* restore registers, return */
    moveml %sp@+,%d1/%a0/%a2	| 4088BF58
    rts	| 4088BF5C

/*
 REMOVECARD: remove the card in slot a0@(49): close its drivers (each sResource with a
 driver), then mark the slot empty and clear its interrupt queue.
*/
REMOVECARD:
    moveml %d1-%d3/%a1-%a2,%sp@-
    lea %sp@(-50),%sp
    moveal %sp,%a2
    clrl %a2@(12)
    moveq #0,%d1
    moveb %a0@(49),%d1
    moveal SRsrcTblPtr,%a1
    subaw #24,%a1
REMOVECARD_1C:          /* next SRT entry (fall: disabled ones too) */
    lea %a1@(24),%a1
    bset #0,%a0@(27)
    pea %pc@(REMOVECARD_34)
    movel @(SDMJmpTblPtr,%za0)@(0xe0),%sp@-	| 4088BF88 call GETSRTENTRY
    rts
REMOVECARD_34:          /* next sResource of the slot */
    jbne REMOVECARD_6E
    pea %pc@(REMOVECARD_44)
    movel @(SDMJmpTblPtr,%za0)@(0xd8),%sp@-	| 4088BF98 call PSRTOSPBLOCK
    rts
REMOVECARD_44:          /* close the driver of the sResource, next */
    cmpb %a0@(49),%d1	| 4088BFA2
    jbne REMOVECARD_1C	| 4088BFA6
    tstw %a0@(38)	| 4088BFA8
    jbpl REMOVECARD_5E	| 4088BFAC
    movew %a0@(38),%a2@(24)	| 4088BFAE
    movel %a0,%sp@-	| 4088BFB4
    moveal %a2,%a0	| 4088BFB6
    _Close	| 4088BFB8
    moveal %sp@+,%a0	| 4088BFBA
REMOVECARD_5E:          /* remove the entry (DELETESRTREC), then the next */
    pea %pc@(REMOVECARD_6C)	| 4088BFBC
    movel @(SDMJmpTblPtr,%za0)@(0xc4),%sp@-	| 4088BFC0 call DELETESRTREC
    rts	| 4088BFC8
REMOVECARD_6C:          /* (data) */
    .byte   0x60, 0xAE	| 4088BFCA
REMOVECARD_6E:          /* slot empty: sInfo pointer to the empty record, interrupt queue cleared */
    lea @(SInfoPtr,%za0)@(0x6c),%a1	| 4088BFCC
    movel %a1,@(0xcbc)@(0x0,%d1:w:4)
    lea @(0xd04)@(0x40,%d1:w:4),%a1
    clrl %a1@
    lea %sp@(50),%sp
    moveml %sp@+,%d1-%d3/%a1-%a2
    rts

/*
 CHECKSLOT: has the card in slot a0@(49) changed (docking)? Read its declaration ROM
 header again and compare with the recorded one. Result: -1 (Z clear) if it changed.
*/
CHECKSLOT:
    moveml %d1-%d3/%a1-%a4,%sp@-
    moveq #0,%d3
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */
    _SlotManager
    jbne CHECKSLOT_DC
    moveal %a0@,%a4
CHECKSLOT_10:           /* slot empty or failed before: nothing to compare */
    cmpiw #-305,%a4@(4)
    jbeq CHECKSLOT_DC
    cmpiw #-318,%a4@(4)
    jbeq CHECKSLOT_DC
    moveq #0,%d1
    moveb %a0@(49),%d1
    lea %sp@(-24),%sp
    movew %d3,%sp@(4)
    moveb %d3,%sp@(8)
    movew %a4@(12),%sp@(12)
    moveb %d1,%sp@(20)
    movel %d3,%sp@(16)
    moveal %sp,%a1
    movel %a1,@(0xcbc)@(0x0,%d1:w:4)
    moveq #-1,%d0
    bfins %d1,%d0,4,4
    moveal %d0,%a3
    lea %pc@(CHECKSLOT_7C),%a2
    pea %pc@(CHECKSLOT_66)
    movel @(SDMJmpTblPtr,%za0)@(0xe8),%sp@-	| 4088C04A call PINSTALLBUS
    rts
CHECKSLOT_66:
    moveb %a3@,%d0	| 4088C054
    pea %pc@(CHECKSLOT_76)	| 4088C056
    movel @(SDMJmpTblPtr,%za0)@(0xec),%sp@-	| 4088C05A call PRESTOREBUS
    rts
CHECKSLOT_76:           /* (data) */
    movel %a3,%sp@(16)
    bras CHECKSLOT_8A_8	| 4088C068
CHECKSLOT_7C:           /* read the format header, VERIFYSLOT */
    pea %pc@(CHECKSLOT_8A)	| 4088C06A
    movel @(SDMJmpTblPtr,%za0)@(0xec),%sp@-	| 4088C06E call PRESTOREBUS
    rts	| 4088C076
CHECKSLOT_8A:           /* (data) */
    .byte   0x33, 0x7C, 0xFE, 0xD4, 0x00, 0x04, 0x60, 0x34	| 4088C078
CHECKSLOT_8A_8:
    .byte   0x61, 0xFF	| 4088C080
    .long   VERIFYSLOT-.	| 4088C082
    .short  0x4A69	| 4088C086
    .short  0x0004, 0x6628	| orib #40,%d4
    bsrw CHECKSLOT_E4
    jbeq CHECKSLOT_D0
    movew %d0,%d2
    lea %sp@(-8),%sp
    movel %sp,%a0@
    pea %pc@(CHECKSLOT_BA)
    movel @(SDMJmpTblPtr,%za0)@(0x44),%sp@-	| 4088C09E call READSLOTPRAM
    rts
CHECKSLOT_BA:           /* compare CRC and length */
    jbne CHECKSLOT_D0	| 4088C0A8
    cmpw %sp@,%d2	| 4088C0AA
    lea %sp@(8),%sp	| 4088C0AC
    jbeq CHECKSLOT_D2	| 4088C0B0
    jbra CHECKSLOT_D0	| 4088C0B2
    .byte   0x30, 0x2C, 0x00, 0x04, 0xB0, 0x69, 0x00, 0x04, 0x67, 0x02	| 4088C0B4
CHECKSLOT_D0:           /* changed: -1, restore the sInfo pointer */
    moveq #-1,%d3
CHECKSLOT_D2:           /* free the temporary sInfo record, put the slot's own back */
    lea %sp@(24),%sp
    movel %a4,@(0xcbc)@(0x0,%d1:w:4)
CHECKSLOT_DC:           /* return d0 = -1 if the card changed, else 0 */
    movel %d3,%d0
    moveml %sp@+,%d1-%d3/%a1-%a4
    rts

CHECKSLOT_E4:           /* read the board sResource and compare its board ID */
    moveml %d1-%d4/%a1-%a2,%sp@-
    moveq #0,%d4
    movel %a1@,%a0@(4)
    moveb %a1@(9),%a0@(53)
    bset #5,%a0@(54)
    moveq #40,%d0	/* _SlotManager 40: CALCSTEP, sCalcStep */
    _SlotManager
    jbne CHECKSLOT_186
    movel %a0@,%a0@(24)
    movel %a1@,%d2
    moveq #0,%d1
CHECKSLOT_10A:          /* next directory entry (PREAD4BYTES) */
    movel %d2,%a0@(4)
    pea %pc@(CHECKSLOT_11C)
    movel @(SDMJmpTblPtr,%za0)@(0xdc),%sp@-	| 4088C100 call PREAD4BYTES
    rts
CHECKSLOT_11C:          /* */
    jbne CHECKSLOT_186	| 4088C10A
    movel %a0@(4),%d2	| 4088C10C
    moveb %a0@,%d3	| 4088C110
    cmpib #0xff,%d3	| 4088C112
    jbeq CHECKSLOT_186	| 4088C116
    cmpb %d1,%d3	| 4088C118
    jbls CHECKSLOT_186	| 4088C11A
    moveb %d3,%d1	| 4088C11C
    movel %a1@,%a0@(4)	| 4088C11E
    moveb %d1,%a0@(50)	| 4088C122
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 4088C126
    _SlotManager	| 4088C128
    jbne CHECKSLOT_186	| 4088C12A
    moveal %a0@(4),%a2	| 4088C12C
    moveb #1,%a0@(50)	| 4088C130
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */	| 4088C136
    _SlotManager	| 4088C138
    jbne CHECKSLOT_186	| 4088C13A
    lea %sp@(-8),%sp	| 4088C13C
    movel %sp,%a0@	| 4088C140
    movel #8,%a0@(8)	| 4088C142
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */	| 4088C14A
    _SlotManager	| 4088C14C
    jbne CHECKSLOT_186	| 4088C14E
    movel %sp@+,%d0	| 4088C150
    movel %sp@+,%d3	| 4088C152
    cmpil #65536,%d0	/* sRsrcType 0001 0000 0000 0000: the board sResource? */	| 4088C154
    jbne CHECKSLOT_10A	| 4088C15A
    tstl %d3	| 4088C15C
    jbne CHECKSLOT_10A	| 4088C15E
    movel %a2,%a0@(4)	| 4088C160
    moveb #32,%a0@(50)	/* its board ID (sRsrcBoardId, 32) */	| 4088C164
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */	| 4088C16A
    _SlotManager	| 4088C16C
    jbne CHECKSLOT_186	| 4088C16E
    movew %a0@(2),%d4	| 4088C170
CHECKSLOT_186:          /* return d0 = the board ID (0 if none) */
    movew %d4,%d0
    moveml %sp@+,%d1-%d4/%a1-%a2
    rts

/*
 DOSECONDARYINIT: run the card's SecondaryInit (sResource ID 38 of the board sResource)
 if it has one and its PrimaryInit worked (or failed only with -316 and an old version).
*/
DOSECONDARYINIT:
    moveml %d0-%d2/%a1/%a3,%sp@-
    clrb %a0@(50)
    jbsr GETBOARD
    jbne DOSECONDARYINIT_8A
    moveal %a0@(4),%a3
    moveal %a0@,%a1
    cmpib #4,%a1@(8)	/* siState < stateSInit (4)? */
    jbcc DOSECONDARYINIT_8A
    movew %a1@(4),%d0
    jbpl DOSECONDARYINIT_3C
    cmpiw #-316,%d0	/* PrimaryInit failed (smInitStatVErr) ... */
    jbne DOSECONDARYINIT_8A
    cmpiw #-32640,%a1@(6)	/* ... with a status from an old card (-32640 or below) */
    jbgt DOSECONDARYINIT_8A
    clrw %a1@(4)
    bset #2,%a1@(11)	/* retry it: remember the old status */
DOSECONDARYINIT_3C:     /* find the SecondaryInit record */
    movew %d0,%d2
    moveb #38,%a0@(50)	/* SecondaryInit (38) */
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbeq DOSECONDARYINIT_5E
    movew %d2,%a1@(4)
    bclr #2,%a1@(11)
    jbeq DOSECONDARYINIT_8A
    movew #-316,%a1@(4)
    jbra DOSECONDARYINIT_8A
DOSECONDARYINIT_5E:     /* run it (sExec), record the status */
    movel %a3,%a0@(4)
    moveb %a0@(49),%a2@
    moveb %a0@(54),%a2@(4)
    moveq #35,%d0	/* _SlotManager 35: SLOTEXEC, sExec */
    _SlotManager
    bclr #2,%a1@(11)
    moveb #4,%a1@(8)	/* siState = stateSInit */
    movew %a2@(2),%a1@(6)	/* siInitStatusV = seStatus */
    jbpl DOSECONDARYINIT_8A
    movew #-316,%a1@(4)	/* negative: siInitStatusA = -316 (smInitStatVErr) */
DOSECONDARYINIT_8A:     /* return */
    moveml %sp@+,%d0-%d2/%a1/%a3
    rts

/*
 VERIFYSLOTPATCH: find the format header of a slot. For slot 0 (the motherboard), the
 built-in declaration ROM can have a second, machine-specific directory: read the
 extended header 35 bytes below the top (DECL_EXT_HEADER in declrom/declrom.s), check its test pattern and the directory ID
 (the SuperInit sExec chooses it), and use that directory. Otherwise the normal header
 (19 bytes below the top).
*/
VERIFYSLOTPATCH:
    tstb %a0@(49)
    jbne VERIFYSLOTPATCH_B8
    movel %a1@(16),%a0@(4)
    movel #-35,%a0@(12)
    moveb %a1@(9),%a0@(53)
    moveq #44,%d0	/* _SlotManager 44: CALCSPOINTER, sCalcsPointer */
    _SlotManager
    jbne VERIFYSLOTPATCH_B8
    moveml %a3-%a4,%sp@-
    subaw #16,%sp
    moveal %sp,%a3
    subaw #24,%sp
    moveal %sp,%a4
    movel %a3,%a0@
    movel #16,%a0@(8)
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */
    _SlotManager
    jbne VERIFYSLOTPATCH_B0
    cmpil #1519594439,%a3@(12)
    jbne VERIFYSLOTPATCH_B0
    moveb %a2@(13),%d0
    cmpb %a3@,%d0
    jbne VERIFYSLOTPATCH_B0
    moveb %a0@(49),%a4@
    moveb %a3@,%a4@(1)
    moveb %a3@,%a0@(50)
    movel %a4,%a0@(20)
    moveq #35,%d0	/* _SlotManager 35: SLOTEXEC, sExec */
    _SlotManager
    jbne VERIFYSLOTPATCH_B0
    tstb %a4@(2)
    jbne VERIFYSLOTPATCH_B0
    movel %a1@(16),%a0@(4)
    movel %a3@(4),%a0@(12)
    clrb %a0@(12)
    addil #-31,%a0@(12)
    moveb %a1@(9),%a0@(53)
    moveq #44,%d0	/* _SlotManager 44: CALCSPOINTER, sCalcsPointer */
    _SlotManager
    jbne VERIFYSLOTPATCH_B0
    moveb %a4@(3),%a0@(50)
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne VERIFYSLOTPATCH_B0
    movel %a0@(4),%a1@
    addaw #40,%sp
    moveml %sp@+,%a3-%a4
    jbra VERIFYSLOTPATCH_D4
VERIFYSLOTPATCH_B0:     /* no extended header: the normal one */
    addaw #40,%sp
    moveml %sp@+,%a3-%a4
VERIFYSLOTPATCH_B8:     /* the format header at the top of the slot space */
    movel %a1@(16),%a0@(4)
    movel %a2@,%a0@(12)
    addil #-19,%a0@(12)
    moveq #44,%d0	/* _SlotManager 44: CALCSPOINTER, sCalcsPointer */
    _SlotManager
    jbne VERIFYSLOTPATCH_D4
    movel %a0@(4),%a1@
VERIFYSLOTPATCH_D4:     /* done */
    jbra VERIFYSLOTDONE

/*
 FINDDEVBASESLOT0: device base address for an sResource in slot 0: with sRsrcFlags
 bit 2 (32-bit base) from the video info (+4), else +8.
*/
FINDDEVBASESLOT0:
    moveal 0xdd8,%a1
    addal %a1@(8),%a1
    moveb #7,%a0@(50)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    jbne FINDDEVBASESLOT0_24
    movew %a0@(2),%d0
    btst #2,%d0
    jbeq FINDDEVBASESLOT0_24
    addl %a1@(4),%d1
    jbra FINDDEVBASESLOT0_28
FINDDEVBASESLOT0_24:    /* the other base */
    addl %a1@(8),%d1
FINDDEVBASESLOT0_28:    /* d2 = it */
    movel %d1,%d2
    rts

/*
 STARTSDECLMGRPATCH: start the Slot Declaration Manager: the docking manager first,
 warm start flag, then PrimaryInit of each slot: the slot holding the built-in
 display (found by sNextTypesRsrc) first, unless XPRAM 0xFC holds 'Skip', then
 slot 0, then 14 down to 1.
*/
STARTSDECLMGRPATCH:
    jbsr INITDOCKING
    moveq #0,%d2
    cmpil #1464619843,WarmStart
    jbne STARTSDECLMGRPATCH_16
    bset #2,%d2
STARTSDECLMGRPATCH_16:  /* find the board with the main display */
    clrb %a0@(49)
    clrb %a0@(50)
    clrb %a0@(51)
    clrb %a0@(48)
    movew #17,%a0@(40)
    movew #256,%a0@(42)
    movew #260,%a0@(44)
    movew #256,%a0@(46)
    clrl %a0@(24)
    orib #4,%a0@(27)
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */
    _SlotManager
    jbne DOZEROFIRST
    moveb %a0@(49),%sp@-
    movel %a0,%sp@-
    subqw #4,%sp
    moveal %sp,%a0
    movel #262396,%d0
    _ReadXPRam
    movel %sp@+,%d0
    moveal %sp@+,%a0
    cmpil #1399548272,%d0
    jbeq STARTSDECLMGRPATCH_7A
    moveb %d2,%a0@(54)
    jbsr INITPRIMARY
STARTSDECLMGRPATCH_7A:  /* slot 0 */
    clrb %a0@(49)
    moveb %d2,%a0@(54)
    jbsr INITPRIMARY
    moveq #14,%d1
STARTSDECLMGRPATCH_8A:  /* slots 14 to 1 (skipping the one done first) */
    moveb %d1,%a0@(49)
    cmpb %sp@,%d1
    jbeq STARTSDECLMGRPATCH_9C
    moveb %d2,%a0@(54)
    jbsr INITPRIMARY
STARTSDECLMGRPATCH_9C:  /* next */
    subqb #1,%d1
    jbne STARTSDECLMGRPATCH_8A
    tstb %sp@+
    lea %sp@(56),%sp
    moveq #0,%d0
    rts
STARTSDECLMGRPATCH_AA:  /* table of known cards (category, type, DrSW, DrHW, version), 10 bytes each */
    .long   0x00030001	| 4088C3BC
    .long   0x00010001, 0x00000003, 0x00010001, 0x00190000	| 4088C3C0
    .long   0x00000000	| 4088C3D0
STARTSDECLMGRPATCH_C2:  /* replacement drivers: offsets of code and size, 12 bytes each */
    .short  0x0000, 0xB7AC	| 4088C3D4 orib #-84,%d0
    .short  0x0000, 0xC0FA	| 4088C3D8 orib #-6,%d0
    subib #0,%d0	| 4088C3DC
    .short  0x0000, 0x958C	| orib #0x8c,%d0
    .short  0x0000, 0xAFAC	| orib #0xac,%d0
    subib #0,%d0
STARTSDECLMGRPATCH_DA:  /* replacement PrimaryInit offsets */
    .short  0x0000, 0xC0F4	| orib #0xf4,%d0
    .short  0x0000, 0xAFA4	| orib #0xa4,%d0
    .long   0x00000000, 0x00000000, 0x00000000	| 4088C3F4
