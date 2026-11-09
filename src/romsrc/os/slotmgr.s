/*
 os/slotmgr.s - Slot Manager and Slot Declaration Manager, slot interrupts
 From READSLOTBYTE (0x40805890). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the Slot Manager chapter of Designing Cards
 and Drivers / Inside Macintosh V), not taken from Apple.

 What it does: at start-up (STARTSDECLMGR) every NuBus slot the machine has (its
 NuBus info table; the Quadra 800 has three, $C-$E) and slot 0 (the motherboard, whose declaration ROM is the end of this ROM: see
 declrom/) is probed. A card's declaration ROM sits at the top of its slot space,
 using 1, 2 or 4 of the 4 byte lanes of the 32-bit bus; its format header (VERIFYSLOT)
 points to the sResource directory. Every sResource of every card goes into the slot
 resource table (SRT, INITSRSRC), which the calls then search: by slot and ID, by
 type, or the next one. The cards' PrimaryInit code runs at start-up, SecondaryInit
 after the System is loaded. Slot interrupts (from VIA 2 here) go to per-slot queues
 of handlers (_SIntInstall).

 _SlotManager (A06E, SLOTMANAGER): d0 = selector, a0 = SpBlock. Selector n is entry n
 of the vector table at 0xDB8 (INITJMPTBL), which internal routines also use:
 "moveq #n,d0 / _SlotManager", or "pea return / move.l (0xDB8)@(4n),-(sp) / rts"
 (the source names the selector or routine on each such line).

 SpBlock (56 bytes): +0 spResult, +4 spsPointer, +8 spSize, +12 spOffsetData,
 +16 spIOFileName, +20 spsExecPBlk, +24 spParamData (sGetsRsrc flags in its last byte,
 +27: bit 0 fall = disabled ones too, bit 1 foneslot = this slot only, bit 2 fnext =
 the next one), +28 spMisc, +32 spReserved, +36 spIOReserved, +38 spRefNum,
 +40 spCategory, +42 spCType, +44 spDrvrSW, +46 spDrvrHW, +48 spTBMask, +49 spSlot,
 +50 spID, +51 spExtDev, +52 spHWDev, +53 spByteLanes, +54 spFlags (bit 0 fCkForNext,
 bit 1 fCkReserved, bit 2 fWarmStart, bit 5 fConsecBytes), +55 spKey.

 sInfo record (24 bytes, one per slot, pointers at 0xCBC): +0 siDirPtr, +4
 siInitStatusA (0 or the error found), +6 siInitStatusV, +8 siState (2 PRAM done, 3
 PrimaryInit done), +9 siCPUByteLanes, +10 siTopOfROM, +11 siStatusFlags (bit 1
 fCardIsChanged), +12 siTOConst, +16 siROMAddr (the top byte of the declaration ROM),
 +20 siSlot. Slots without a card share one of three records: disabled (-305),
 reserved (-318) or empty (-300).

 Format header (20 bytes, the last bytes of the declaration ROM): +0 fhDirOffset (24
 bits, to the directory), +4 fhLength, +8 fhCRC, +12 fhROMRev, +13 fhFormat (1),
 +14 fhTstPat (0x5A932BC7), +18 fhReserved, +19 fhByteLanes.

 SRT entry (24 bytes; blocks of 8, chained, the first at 0xD24): +0 slot (-255: free,
 -1: end of block, link at +2), +1 ID, +2 ExtDev, +3 HWDev, +4 refNum, +6 IOReserved,
 +8 type (category, cType, DrvrSW, DrvrHW), +16 the sResource, +20 flags (bit 0 of
 +23: disabled).

 Globals before the sInfo table (0xCBC-n): -4 the MMU mode and -8 the bus error vector
 saved by PINSTALLBUS, -16 the next free SRT entry, -18 the number of SRT entries.
 Slot Manager errors are -300 (smEmptySlot) to -351 (smRecNotFnd); each is named
 where it is set.
*/

/*
 READSLOTBYTE (sReadByte, 0): spResult = the byte held in the offset field of entry spID
 of the list at spsPointer (an entry is ID byte + 3-byte offset; for a byte or word
 value the value is stored in the offset field itself). sOffsetData finds the entry,
 whose 3-byte field it leaves in spOffsetData. spsPointer is kept.
*/
READSLOTBYTE:
    movel %a0@(4),%sp@-
    clrb %a0@(3)	/* spResult byte = 0 */
    moveq #36,%d0	/* _SlotManager 36: OFFSETDATA, sOffsetData */
    _SlotManager
    jbne READSLOTBYTE_16
    moveb %a0@(15),%a0@(3)	/* the low byte of spOffsetData */
    moveq #0,%d0
READSLOTBYTE_16:        /* restore spsPointer, return */
    movel %sp@+,%a0@(4)
    rts
    .long   0x00000000	| 408058AC

/*
 READSLOTWORD (sReadWord, 1): spResult = the word held in the offset field of entry spID
 (as READSLOTBYTE).
*/
READSLOTWORD:
    movel %a0@(4),%sp@-
    clrw %a0@(2)
    moveq #36,%d0	/* _SlotManager 36: OFFSETDATA, sOffsetData */
    _SlotManager
    jbne READSLOTWORD_16
    movew %a0@(14),%a0@(2)	/* the low word of spOffsetData */
    moveq #0,%d0
READSLOTWORD_16:        /* restore spsPointer, return */
    movel %sp@+,%a0@(4)
    rts
    .long   0x00000000	| 408058CC

/*
 READSLOTLONG (sReadLong, 2): spResult = the long that entry spID points to.
 sReadPBSize with fCkReserved clear (spFlags bit 1) reads the 4 bytes at the entry's
 offset, the same way a block's size is read; they are left in spSize.
*/
READSLOTLONG:
    movel %a0@(4),%sp@-
    clrl %a0@
    bclr #1,%a0@(54)	/* spFlags.fCkReserved = 0: the high byte is data */
    moveq #38,%d0	/* _SlotManager 38: READPBSIZE, sReadPBSize */
    _SlotManager
    jbne READSLOTLONG_18
    movel %a0@(8),%a0@	/* spResult = spSize */
    moveq #0,%d0
READSLOTLONG_18:        /* restore spsPointer, return */
    movel %sp@+,%a0@(4)
    rts
    .short  0x0000	| 408058EE

/*
 GETCSTRING (sGetcString, 3): copy the C string of entry spID into a new pointer
 (spResult). It finds the string (sFindStruct), counts its bytes up to the 0 by
 stepping through the card's byte lanes (sCalcStep with fConsecBytes), allocates
 that many bytes and reads them (sReadStruct). A bus error while counting ends at
 GETCSTRING_82 with the error set by PINSTALLBUS's handler.
*/
GETCSTRING:
    moveml %a2-%a3,%sp@-
    movel %a0@(4),%sp@-
    moveb %a0@(49),%sp@-	/* spSlot, kept */
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne GETCSTRING_82
    moveal %a0@(4),%a3	/* a3 = the string on the card */
    bset #5,%a0@(54)	/* spFlags.fConsecBytes: steps between consecutive bytes */
    moveq #40,%d0	/* _SlotManager 40: CALCSTEP, sCalcStep */
    _SlotManager
    jbne GETCSTRING_82
    movel %a0@,%d1	/* d1 = the steps, one byte per lane, used in rotation */
    moveq #0,%d0
    moveq #0,%d2
    moveal %a3,%a1
    lea %pc@(GETCSTRING_82),%a2	/* bus error recovery address */
    pea %pc@(GETCSTRING_3C)
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    movel @(SDMJmpTblPtr,%za0)@(0xe8),%sp@-	| 40805922 call PINSTALLBUS
    rts
GETCSTRING_3C:          /* count the bytes up to and including the 0 */
    addql #1,%d0
    moveb %a1@,%d2
    jbeq GETCSTRING_4E
    moveb %d1,%d2
    addaw %d2,%a1
GETCSTRING_46:          /* next lane with a non-zero step (rotate the step bytes) */
    rorl #8,%d1
    tstb %d1
    jbeq GETCSTRING_46
    jbra GETCSTRING_3C
GETCSTRING_4E:          /* spSize = length; end bus error protection */
    movel %d0,%a0@(8)
    pea %pc@(GETCSTRING_60)
    movel @(SDMJmpTblPtr,%za0)@(0xec),%sp@-	| 40805946 call PRESTOREBUS
    rts
GETCSTRING_60:          /* allocate spSize bytes, read the string into it (sReadStruct) */
    moveal %a0,%a2
    .short  0xA11E	| 40805952 _NewPtr (flags 0x0100)
    jbne GETCSTRING_82
    movel %a0,%a2@
    moveal %a2,%a0
    movel %a3,%a0@(4)
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */
    _SlotManager
    jbeq GETCSTRING_82	/* read: done; else free the pointer, keep the error */
    movel %d0,%d1
    moveal %a0,%a1
    moveal %a1@(4),%a0
    _DisposPtr
    moveal %a1,%a0
    movel %d1,%d0
GETCSTRING_82:          /* restore spSlot, spsPointer, return */
    moveb %sp@+,%a0@(49)
    movel %sp@+,%a0@(4)
    moveml %sp@+,%a2-%a3
    rts

/*
 GETSLOTBLOCK (sGetBlock, 5): copy the sBlock of entry spID (a long with the size,
 including the long itself, then the data) into a new system-heap pointer (spResult).
 sReadPBSize with fCkReserved checks the reserved high byte of the size. Error -336
 (smNilsBlockErr) if the block is empty.
*/
GETSLOTBLOCK:
    movel %a0@(4),%sp@-
    bset #1,%a0@(54)	/* spFlags.fCkReserved: the size's high byte must be 0 */
    moveq #38,%d0	/* _SlotManager 38: READPBSIZE, sReadPBSize */
    _SlotManager
    jbne GETSLOTBLOCK_40
    movel %a0@(8),%d0
    subql #4,%d0	/* without the size long */
    jbgt GETSLOTBLOCK_1E
    movew #-336,%d0
    jbra GETSLOTBLOCK_40
GETSLOTBLOCK_1E:        /* allocate the data size in the system heap, read the data (sReadStruct) */
    movel %d0,%a0@(8)
    moveal %a0,%a1
    .short  0xA51E	| 408059A4 _NewPtr (flags 0x0500)
    jbne GETSLOTBLOCK_40
    movel %a0,%a1@
    moveal %a1,%a0
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */
    _SlotManager
    jbeq GETSLOTBLOCK_40	/* read: done; else free the pointer, keep the error */
    movel %d0,%d1
    moveal %a0,%a1
    moveal %a1@(4),%a0
    _DisposPtr
    moveal %a1,%a0
    movel %d1,%d0
GETSLOTBLOCK_40:        /* restore spsPointer, return */
    movel %sp@+,%a0@(4)
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408059C6

/*
 FINDSLOTSTRUCT (sFindStruct, 6): spsPointer = the address on the card of the data of
 entry spID: sOffsetData for the entry's offset, then sCalcsPointer to add it, counted
 in the card's byte lanes.
*/
FINDSLOTSTRUCT:
    moveq #36,%d0	/* _SlotManager 36: OFFSETDATA, sOffsetData */
    _SlotManager
    jbne FINDSLOTSTRUCT_A
    moveq #44,%d0	/* _SlotManager 44: CALCSPOINTER, sCalcsPointer */
    _SlotManager
FINDSLOTSTRUCT_A:       /* return */
    rts
    .long   0x00000000	| 408059DC

/*
 READSLOTSTRUCT (sReadStruct, 7): read spSize bytes at spsPointer on the card into
 spResult (a buffer in RAM), one byte per used byte lane. The slot is found from the
 address (sPtrToSlot), its byte lanes from its sInfo record. Error -308
 (smUnExBusErr) if the card bus-errors.
*/
READSLOTSTRUCT:
    moveml %d1-%d3/%a1-%a3,%sp@-
    moveb %a0@(49),%sp@-
    moveal %a0@(4),%a3	/* a3 = card address */
    movel %a3,%sp@-
    movel %a0@,%d0
    _StripAddress	/* the buffer, as a 32-bit address */
    movel %d0,%sp@-
    moveal %d0,%a1
    moveq #46,%d0	/* _SlotManager 46: PTRTOSLOT, sPtrToSlot */
    _SlotManager
    jbne READSLOTSTRUCT_76
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */
    _SlotManager
    jbne READSLOTSTRUCT_76
    moveal %a0@,%a2
    moveb %a2@(9),%a0@(53)	/* spByteLanes = siCPUByteLanes */
    bset #5,%a0@(54)	/* fConsecBytes */
    moveq #40,%d0	/* _SlotManager 40: CALCSTEP, sCalcStep */
    _SlotManager
    jbne READSLOTSTRUCT_76
    movel %a0@,%d1
    pea %pc@(READSLOTSTRUCT_46)
    movel @(SDMJmpTblPtr,%za0)@(0xe8),%sp@-	| 40805A1C call PINSTALLBUS
    rts
READSLOTSTRUCT_46:      /* d2 = count - 1, a2 = bus error recovery, d0 = -308 if it is taken */
    moveq #0,%d3
    movel %a0@(8),%d2
    subql #1,%d2
    lea %pc@(READSLOTSTRUCT_68),%a2
    movew #-308,%d0	/* the result if a bus error ends the copy (smUnExBusErr) */
READSLOTSTRUCT_56:      /* copy one byte, advance by the step of this lane */
    moveb %a3@,%a1@+
    moveb %d1,%d3
    addaw %d3,%a3
READSLOTSTRUCT_5C:      /* rotate to the next lane with a non-zero step */
    rorl #8,%d1
    tstb %d1
    jbeq READSLOTSTRUCT_5C
    dbf %d2,READSLOTSTRUCT_56
    moveq #0,%d0
READSLOTSTRUCT_68:      /* end bus error protection */
    pea %pc@(READSLOTSTRUCT_76)
    movel @(SDMJmpTblPtr,%za0)@(0xec),%sp@-	| 40805A4C call PRESTOREBUS
    rts
READSLOTSTRUCT_76:      /* restore spResult, spsPointer, spSlot, return (d0 tested) */
    movel %sp@+,%a0@
    movel %sp@+,%a0@(4)
    moveb %sp@+,%a0@(49)
    moveml %sp@+,%d1-%d3/%a1-%a3
    tstw %d0
    rts
    .long   0x00000000, 0x00000000	| 40805A68

/*
 READSLOTINFO (sReadInfo, 16): copy the slot's sInfo record (16 of its 24 bytes) to the
 buffer at spResult.
*/
READSLOTINFO:
    moveml %a2,%sp@-	| 40805A70
    moveal %a0@,%a2	| 40805A74
    movel %a2,%sp@-	| 40805A76
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */	| 40805A78
    _SlotManager	| 40805A7A
    bnew READSLOTINFO_1C	| 40805A7C
    moveal %a0@,%a1	| 40805A80
    moveq #15,%d2	| 40805A82
READSLOTINFO_14:        /* copy 16 bytes */
    moveb %a1@+,%a2@+	| 40805A84
    dbf %d2,READSLOTINFO_14	| 40805A86
    moveq #0,%d0	| 40805A8A
READSLOTINFO_1C:        /* restore spResult, return */
    movel %sp@+,%a0@	| 40805A8C
    moveml %sp@+,%a2	| 40805A8E
    rts	| 40805A92
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40805A94

/* SLOTDISPOSPTR (sDisposePtr, 23): DisposPtr(spsPointer). Error -312 (smDisposePErr). */
SLOTDISPOSPTR:
    movel %a0,%sp@-
    moveal %a0@(4),%a0
    _DisposPtr
    jbeq SLOTDISPOSPTR_10
    movel #-312,%d0
SLOTDISPOSPTR_10:       /* return */
    moveal %sp@+,%a0
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40805AB4

/*
 READSLOTDRVRNAME (sReadDrvrName, 25): the driver name of sResource spSlot/spID: its
 sRsrcName (entry 2) with a '.' in front, as a Pascal string at spResult (".Display_
 Video_Apple_DAFB"). Error -342 (smGetDrvrNamErr) if there is no such sResource or the
 name is longer than 254 bytes.
*/
READSLOTDRVRNAME:
    moveml %a2-%a3,%sp@-
    moveb %a0@(50),%d2	/* d2 = spID, restored at the end */
    moveal %a0@,%a3
    movel %a3,%sp@-
    clrb %a0@(51)	/* spExtDev = 0 */
    clrl %a0@(24)	/* spParamData = 0: enabled sResources only */
    moveq #29,%d0	/* _SlotManager 29: GETSRSRCPTR, sGetsRsrcPtr */
    _SlotManager
    jbne READSLOTDRVRNAME_60
    moveb #2,%a0@(50)	/* sRsrcName (2) */
    moveq #3,%d0	/* _SlotManager 3: GETCSTRING, sGetcString */
    _SlotManager
    jbne READSLOTDRVRNAME_60
    moveal %a0@,%a2
    movel %a0@(8),%d1
    subqb #1,%d1	/* d1 = length without the 0 */
    cmpil #254,%d1
    jbhi READSLOTDRVRNAME_5A
    moveb %a0@(11),%a3@+	/* length byte: the low byte of spSize (string + 0 = name + '.') */
    moveb #46,%a3@+	/* '.' */
    moveml %a0-%a1,%sp@-
    moveal %a2,%a0
    moveal %a3,%a1
    movel %d1,%d0
    _BlockMove
    moveml %sp@+,%a0-%a1
    jbne READSLOTDRVRNAME_5A
    exg %a2,%a0	/* free the C string */
    _DisposPtr
    moveal %a2,%a0
    moveq #0,%d0
    jbra READSLOTDRVRNAME_66
READSLOTDRVRNAME_5A:    /* too long or BlockMove failed: free the C string */
    exg %a2,%a0
    _DisposPtr
    moveal %a2,%a0
READSLOTDRVRNAME_60:    /* error -342 (smGetDrvrNamErr) */
    movel #-342,%d0
READSLOTDRVRNAME_66:    /* restore spResult, spID, return */
    movel %sp@+,%a0@
    moveb %d2,%a0@(50)
    moveml %sp@+,%a2-%a3
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40805B32

/*
 FINDDEVBASE (sFindDevBase, 27, and sFindBigDevBase, 28): spResult = the device base
 address of sResource spSlot/spID: its MinorBaseOS entry (10, a 24-bit offset in the
 slot's 16 MB minor space Fs000000) or else its MajorBaseOS entry (12, a 28-bit offset
 in the 256 MB super slot space s0000000). A minor base is Fss00000 + the offset's low
 20 bits, an address that also works in 24-bit mode (ssxxxxx); with sRsrcFlags (7)
 bit 2 (f32BitMode) set, FINDDEVBASEPATCH (OVERPATCH) makes it Fs000000 + the whole
 24-bit offset. Slot 0 (the motherboard) has no slot space: FINDDEVBASESLOT0 gives
 the built-in video's base from the universal info.
*/
FINDDEVBASE:
    movel %a1,%sp@-
    moveb %a0@(50),%sp@-
    movel %a0@(24),%sp@-
    clrl %a0@(24)	/* spParamData = 0 ... */
    bset #1,%a0@(27)	/* ... with foneslot (bit 1): this slot only; GETSRSRC: spsPointer = the sResource */
    pea %pc@(FINDDEVBASE_22)
    movel @(SDMJmpTblPtr,%za0)@(0x2c),%sp@-	| 40805B58 call GETSRSRC
    rts
FINDDEVBASE_22:         /* minor base offset (MinorBaseOS, 10)? */
    jbne FINDDEVBASE_90
    moveq #0,%d2
    moveb %a0@(49),%d2	/* d2 = spSlot */
    moveb #10,%a0@(50)	/* MinorBaseOS (10) */
    moveq #2,%d0	/* _SlotManager 2: READSLOTLONG, sReadLong */
    _SlotManager
    jbne FINDDEVBASE_46
    movel %a0@,%d1
    andil #16777215,%d1	/* a 24-bit offset */
    tstb %a0@(49)
    jbeq FINDDEVBASE_9E
    jbra FINDDEVBASE_66
FINDDEVBASE_46:         /* no: major base offset (MajorBaseOS, 12), the low 28 bits */
    moveb #12,%a0@(50)
    moveq #2,%d0	/* _SlotManager 2: READSLOTLONG, sReadLong */
    _SlotManager
    jbne FINDDEVBASE_90
    movel %a0@,%d1
    andil #268435455,%d1	/* a 28-bit offset */
    tstb %a0@(49)
    jbeq FINDDEVBASE_9E
    rorl #4,%d2	/* slot in the top nibble: s0000000 + offset */
    orl %d1,%d2
    jbra FINDDEVBASE_8C
FINDDEVBASE_66:         /* minor space: F, s, s, then the offset's low 20 bits */
    movel #-268435456,%d0
    orl %d1,%d0
    bfins %d2,%d0,4,4
    bfins %d2,%d0,8,4	/* Fss00000 + offset: valid in 24- and 32-bit mode */
    movel %d0,%d2
    moveb #7,%a0@(50)	/* sRsrcFlags (7) */
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    jbne FINDDEVBASE_8C
    jbsr OVERPATCH	/* FINDDEVBASEPATCH: f32BitMode: Fs000000 + the 24-bit offset */
    nop
FINDDEVBASE_8C:         /* spResult = the address */
    movel %d2,%a0@
    moveq #0,%d0
FINDDEVBASE_90:         /* restore spParamData, spID, a1, return */
    movel %sp@+,%a0@(24)
    moveb %sp@+,%a0@(50)
    moveml %sp@+,%a1
    rts
FINDDEVBASE_9E:         /* slot 0: the built-in video's base (FINDDEVBASESLOT0) */
    jbsr FINDDEVBASESLOT0
    jbra FINDDEVBASE_8C
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40805BE6
FINDDEVBASE_AE:         /* (padding) */
    .byte   0x00, 0x00	| 40805BEE
FINDDEVBASE_B0:         /* sCardChanged (34): spResult = siStatusFlags.fCardIsChanged (bit 1) of the slot's sInfo record */
    clrb %a0@(3)	| 40805BF0
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */	| 40805BF4
    _SlotManager	| 40805BF6
    jbne FINDDEVBASE_C8	| 40805BF8
    moveal %a0@,%a1	| 40805BFA
    btst #1,%a1@(11)	| 40805BFC
    sne %a0@(3)	| 40805C02
    moveq #0,%d0	| 40805C06
FINDDEVBASE_C8:         /* return */
    rts	| 40805C08
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40805C0A

/*
 SLOTEXEC (sExec, 35): run the sExec block of entry spID: load it (sGetBlock), check
 its header (SLOTEXEC_2), call its code with a0 = spsExecPBlk (through SLOTMGRPATCH),
 free the block. The block: revision byte (2 = sCodeRev), CPU byte (1 = 68000,
 2 = 68020; anything higher is refused: -334 smCPUErr), a word, then a long offset to
 the code. A wrong revision gives -333 (smCodeRevErr).
*/
SLOTEXEC:
    jbra SLOTEXEC_2A

SLOTEXEC_2:             /* revision 2 (sCodeRev)? a2 = the block */
    cmpib #2,%a2@
    jbeq SLOTEXEC_10
    movel #-333,%d0
    jbra SLOTEXEC_28
SLOTEXEC_10:            /* CPU type at most 2 (68020) */
    cmpib #2,%a2@(1)
    jbls SLOTEXEC_20
    movel #-334,%d0
    jbra SLOTEXEC_28
SLOTEXEC_20:            /* a2 = the code: the long at +4 is its offset from there */
    addql #4,%a2
    moveal %a2@,%a1
    addal %a1,%a2
    moveq #0,%d0
SLOTEXEC_28:            /* return (d0 = 0, or the error) */
    rts

SLOTEXEC_2A:            /* get the block into RAM, check it, run it */
    moveml %d3-%d4/%a2-%a3,%sp@-
    movel %a0@(4),%sp@-
    moveq #5,%d0	/* _SlotManager 5: GETSLOTBLOCK, sGetBlock */
    _SlotManager
    jbne SLOTEXEC_5A
    moveal %a0@,%a2	/* a2/a3 = the block in RAM */
    moveal %a2,%a3
    jbsr SLOTEXEC_2
    jbne SLOTEXEC_50
    jbsr SLOTMGRPATCH	/* run it with a0 = spsExecPBlk */
    jbra SLOTEXEC_50
    .long   0x00000000, 0x00000000	| 40805C58
SLOTEXEC_50:            /* free the block (keep the result in d0) */
    exg %d0,%d2
    exg %a3,%a0
    _DisposPtr
    moveal %a3,%a0
    exg %d2,%d0
SLOTEXEC_5A:            /* restore spsPointer, return */
    movel %sp@+,%a0@(4)
    moveml %sp@+,%d3-%d4/%a2-%a3
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40805C74

/*
 CALCSPOINTER (sCalcsPointer, 44): spsPointer += spOffsetData, where the offset counts
 bytes of the declaration ROM, not addresses: a card that uses fewer than 4 byte lanes
 has its bytes spread over more addresses. The offset (24-bit, signed) is divided by
 the number of lanes in use: whole groups of 4 addresses, then the remainder stepped
 one used lane at a time, forwards or backwards. Errors -346 (smBadsPtrErr:
 spsPointer is not on a lane the card uses), -347 (smByteLanesErr: no lanes).
*/
CALCSPOINTER:
    moveml %d3-%d6,%sp@-
    moveal %a0@(4),%a1
    moveq #0,%d1
    movew %a1,%d1
    andib #3,%d1	/* d1 = the lane of spsPointer (address bits 0-1) */
    btst %d1,%a0@(53)	/* is that lane in spByteLanes? */
    jbne CALCSPOINTER_1E
    movel #-346,%d0
    jbra CALCSPOINTER_8A
CALCSPOINTER_1E:        /* d2 = the number of lanes in use */
    moveq #0,%d2
    moveq #3,%d3
CALCSPOINTER_22:        /* count the bits of spByteLanes 3..0 */
    btst %d3,%a0@(53)
    jbeq CALCSPOINTER_2A
    addqw #1,%d2
CALCSPOINTER_2A:        /* next lane */
    dbf %d3,CALCSPOINTER_22
    tstb %d2
    jbne CALCSPOINTER_3A
    movel #-347,%d0
    jbra CALCSPOINTER_8A
CALCSPOINTER_3A:        /* d4 = spOffsetData, sign-extended from 24 bits */
    movel %a0@(12),%d4
    btst #23,%d4	/* sign-extend the 24-bit offset */
    jbeq CALCSPOINTER_4A
    oril #-16777216,%d4
CALCSPOINTER_4A:        /* d5 = (offset / lanes) * 4 addresses, d6 = the remainder */
    movel %d4,%d5
    divsll %d2,%d6,%d5	/* d5 = offset / lanes, d6 = remainder */
    lsll #2,%d5	/* whole groups of 4 addresses */
    tstb %d6
    jbeq CALCSPOINTER_84
    jbpl CALCSPOINTER_70
    negw %d6
    subqw #1,%d6
CALCSPOINTER_5C:        /* negative remainder: step back one used lane at a time */
    subqb #1,%d1
    andib #3,%d1
    subql #1,%d5
    btst %d1,%a0@(53)
    jbeq CALCSPOINTER_5C
    dbf %d6,CALCSPOINTER_5C
    jbra CALCSPOINTER_84
CALCSPOINTER_70:        /* positive remainder: step forward */
    subqw #1,%d6
CALCSPOINTER_72:        /* next address; count it if its lane is used */
    addqb #1,%d1
    andib #3,%d1
    addql #1,%d5
    btst %d1,%a0@(53)
    jbeq CALCSPOINTER_72
    dbf %d6,CALCSPOINTER_72
CALCSPOINTER_84:        /* spsPointer += the address difference */
    addl %d5,%a0@(4)
    moveq #0,%d0
CALCSPOINTER_8A:        /* restore registers, return */
    moveml %sp@+,%d3-%d6
    rts

/*
 GETSLOTDRVR (sGetDriver, 45): load the driver of sResource spSlot/spID into a new handle
 (spResult). Goes through SLOTGETDRIVERPATCH, which calls ORIGGETSLOTDRVR: first the
 sResource's sRsrcLoadRec (sExec block, ID 5), whose code loads the driver itself;
 else the sRsrcDrvrDir (ID 4) entry for the 68020 (sMacOS68020, 2) or 68000
 (sMacOS68000, 1), an sBlock read into a handle; STATLOADPATCH then lets the System
 patch the loaded driver. Error -345 (smsGetDrvrErr).
*/
GETSLOTDRVR:
    jbra thunk_FUN_4088beae

GETSLOTDRVR_4:          /* the sResource's load record (sRsrcLoadRec, 5): run it (sExec) */
    clrl %a0@(24)
    moveq #29,%d0	/* _SlotManager 29: GETSRSRCPTR, sGetsRsrcPtr; spsPointer = the sResource */
    _SlotManager
    jbne GETSLOTDRVR_32
    moveb #5,%a0@(50)
    moveq #35,%d0	/* _SlotManager 35: SLOTEXEC, sExec */
    _SlotManager
    jbne GETSLOTDRVR_32
    moveal %a0@(20),%a2	/* a2 = spsExecPBlk */
    tstw %a2@(2)	/* seStatus 0? */
    jbne GETSLOTDRVR_32
    movel %a2@(8),%a0@	/* spResult = the driver handle it loaded (seResult) */
    moveb %a2@(4),%a0@(54)	/* spFlags = seFlags */
    moveq #0,%d0
    jbra GETSLOTDRVR_38
GETSLOTDRVR_32:         /* error -345 (smsGetDrvrErr) */
    movel #-345,%d0
GETSLOTDRVR_38:         /* return */
    rts

GETSLOTDRVR_3A:         /* the driver directory (sRsrcDrvrDir, 4) of the sResource (sRsrcInfo first) */
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    jbne GETSLOTDRVR_A0
    moveb #4,%a0@(50)	/* sRsrcDrvrDir (4) */
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne GETSLOTDRVR_A0
    moveb #2,%a0@(50)	/* sMacOS68020 (2): its size, reserved byte checked */
    bset #1,%a0@(54)
    moveq #38,%d0	/* _SlotManager 38: READPBSIZE, sReadPBSize */
    _SlotManager
    jbeq GETSLOTDRVR_70
    moveb #1,%a0@(50)	/* else sMacOS68000 (1) */
    bset #1,%a0@(54)
    moveq #38,%d0	/* _SlotManager 38: READPBSIZE, sReadPBSize */
    _SlotManager
    jbne GETSLOTDRVR_A0
GETSLOTDRVR_70:         /* data size (without the size long); room for it, then the handle */
    subql #4,%a0@(8)	/* without the size long */
    movel %a0@(8),%d0
    .short  0xA440	| 40805D88 _ResrvMem (flags 0x0400)
    jbne GETSLOTDRVR_A0
    movel %a0@(8),%d0
    .short  0xA522	| 40805D90 _NewHandle (flags 0x0500)
    jbne GETSLOTDRVR_A0
    moveal %a0,%a3
    movel %a0@,%d0
    _StripAddress
    movel %d0,%a1@	/* spResult = the master pointer, 32-bit clean */
    moveal %a1,%a0
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */
    _SlotManager
    jbne GETSLOTDRVR_9C
    jbsr STATLOADPATCH	/* loaded: let the System see it */
    jbra GETSLOTDRVR_AA
GETSLOTDRVR_9C:         /* read failed: free the handle */
    moveal %a3,%a0
    _DisposHandle
GETSLOTDRVR_A0:         /* spResult = 0, error -345 (smsGetDrvrErr) */
    moveal %a1,%a0
    clrl %a0@
    movel #-345,%d0
GETSLOTDRVR_AA:         /* return */
    rts

/* GETSLOTDRVR continues in SLOTGETDRIVERPATCH (patches), which ends in ORIGGETSLOTDRVR. */
thunk_FUN_4088beae:
    jbra SLOTGETDRIVERPATCH

/*
 ORIGGETSLOTDRVR: the original sGetDriver, called with a2/a3 saved on the stack by
 SLOTGETDRIVERPATCH: the load record first, then the driver directory; spID is kept.
*/
ORIGGETSLOTDRVR:
    moveb %a0@(50),%d2
    jbsr GETSLOTDRVR_4
    jbeq ORIGGETSLOTDRVR_12
    moveb %d2,%a0@(50)
    jbsr GETSLOTDRVR_3A
ORIGGETSLOTDRVR_12:     /* a0 = the SpBlock again, restore spID and a2-a3 (saved by the patch) */
    moveal %a1,%a0
    moveb %d2,%a0@(50)
    moveml %sp@+,%a2-%a3
ENDGETSLOTDRVR:         /* return */
    rts

/*
 STARTSDECLMGR: start the Slot Declaration Manager (called by the start manager with
 a 56-byte SpBlock on the stack): the vector table (INITJMPTBL), the slot information
 table and the first SRT block (DOZEROFIRST_36), then for each slot 14..0: its sInfo
 record (INITSINFO: is there a card, is its declaration ROM valid?), its sResources
 in the SRT (INITSRSRC) and its PRAM record (INITSPRAM). STARTSDECLMGRPATCH continues
 with DOZEROFIRST (the PrimaryInits).
*/
STARTSDECLMGR:
    subaw #56,%sp
    moveal %sp,%a0
    jsr %pc@(INITJMPTBL)
    jbne DOZEROFIRST_2E
    jbsr DOZEROFIRST_36
    jbne DOZEROFIRST_2E
    moveq #14,%d1
STARTSDECLMGR_12:       /* one slot (14 down to 0) */
    moveb %d1,%a0@(49)
    jbsr INITSINFO
    jbsr INITSRSRC
    jbsr INITSPRAM
    dbf %d1,STARTSDECLMGR_12
    jbra STARTSDECLMGRPATCH

/*
 DOZEROFIRST: run the PrimaryInit code of each card: slot 0 (the motherboard) first,
 then slots 14..1. spFlags bit 2 (fWarmStart) is set if this is a warm start
 (WarmStart = 'WLSC').
*/
DOZEROFIRST:
    clrb %a0@(49)
    moveq #0,%d2
    cmpil #1464619843,WarmStart	/* 'WLSC': a restart, not power-on */
    jbne DOZEROFIRST_14
    bset #2,%d2	/* fWarmStart */
DOZEROFIRST_14:         /* spFlags, slot 0 */
    moveb %d2,%a0@(54)
    jbsr INITPRIMARY
    moveq #14,%d1
DOZEROFIRST_1E:         /* slots 14..1 */
    moveb %d1,%a0@(49)
    moveb %d2,%a0@(54)
    jbsr INITPRIMARY
    subqb #1,%d1
    jbne DOZEROFIRST_1E
DOZEROFIRST_2E:         /* free the SpBlock, return no error */
    lea %sp@(56),%sp
    moveq #0,%d0
    rts

DOZEROFIRST_36:         /* the slot information table (0xCBC, 15 pointers) and the standard sInfo records for slots without a card: disabled (-305), reserved (-318) and empty (-300); then the first SRT block (PALLOCSRTBLK) */
    moveml %a0-%a1,%sp@-
    movel #152,%d0
    .short  0xA71E	| 40805E4C _NewPtr (flags 0x0700)
    jbne DOZEROFIRST_84
    lea %a0@(20),%a0	/* 20 bytes of globals before the table */
    movel %a0,SInfoPtr
    lea %a0@(60),%a0
    movew #-305,%a0@(4)	/* disabled: siInitStatusA = -305 (smDisabledSlot) */
    lea %a0@(24),%a0
    movew #-318,%a0@(4)	/* reserved: -318 (smReservedSlot) */
    lea %a0@(24),%a0
    movew #-300,%a0@(4)	/* empty: -300 (smEmptySlot) */
    pea %pc@(DOZEROFIRST_78)
    movel @(SDMJmpTblPtr,%za0)@(0xf0),%sp@-	| 40805E7A call PALLOCSRTBLK
    rts
DOZEROFIRST_78:         /* 0xD24 = the first SRT block, also the next free entry (0xCBC-16) */
    movel %a1,SRsrcTblPtr
    movel %a1,@(SInfoPtr,%za0)@(0xfffffffffffffff0)	| 40805E88
DOZEROFIRST_84:         /* return (Z set if no error) */
    tstw %d0
    moveml %sp@+,%a0-%a1
    rts

/*
 INITSINFO (32): the sInfo record of slot spSlot. A slot the NuBus info table marks
 as absent (bit 3) gets the shared disabled record, a reserved one (bit 5) the
 reserved record. Otherwise the slot gets the empty record unless a card answers:
 for slot 0 the motherboard's declaration ROM is at the end of the ROM (ROMBase +
 size - 1), for slots 9..14 the top byte of the slot's space (FsFFFFFF) is read, and a
 bus error means no card. A card gets its own record (siTOConst 100, siSlot,
 siROMAddr = the top byte) and VERIFYSLOT finds and checks its format header.
*/
INITSINFO:
    moveml %d1/%a0-%a3,%sp@-
    moveq #0,%d1
    moveb %a0@(49),%d1
    moveal SInfoPtr,%a1
    moveal %a1,%a3
    lea %a3@(60),%a3
    movel %a3,%a1@(0x0,%d1:w:4)	/* first the disabled record */
    moveal 0xdd8,%a2	/* the universal info: NuBus info table (offset 12), one byte per slot */
    addal %a2@(12),%a2
    btst #3,%a2@(0x0,%d1:w)	/* bit 3: no slot here */
    jbne INITSINFO_AE
    lea %a3@(24),%a3
    movel %a3,%a1@(0x0,%d1:w:4)
    btst #5,%a2@(0x0,%d1:w)	/* bit 5: reserved */
    jbne INITSINFO_AE
    lea %a3@(24),%a3
    movel %a3,%a1@(0x0,%d1:w:4)
    tstb %d1
    jbne INITSINFO_52
    moveal ROMBase,%a3	/* slot 0: the top of the ROM (ROMBase + size from the header - 1) */
    addal %a3@(64),%a3
    subql #1,%a3
    jbra INITSINFO_8E
INITSINFO_52:           /* FsFFFFFF: the last byte of the slot's minor space */
    moveq #-1,%d0
    bfins %d1,%d0,4,4	/* FsFFFFFF: the last byte of the slot's minor space */
    moveal %d0,%a3
    lea %pc@(INITSINFO_7E),%a2
    pea %pc@(INITSINFO_6C)
    movel @(SDMJmpTblPtr,%za0)@(0xe8),%sp@-	| 40805EFA call PINSTALLBUS
    rts
INITSINFO_6C:           /* read it */
    moveb %a3@,%d0
    pea %pc@(INITSINFO_7C)
    movel @(SDMJmpTblPtr,%za0)@(0xec),%sp@-	| 40805F0A call PRESTOREBUS
    rts
INITSINFO_7C:           /* a card answered */
    jbra INITSINFO_8E	| 40805F14
INITSINFO_7E:           /* bus error: no card, keep the empty record */
    pea %pc@(INITSINFO_8C)
    movel @(SDMJmpTblPtr,%za0)@(0xec),%sp@-	| 40805F1A call PRESTOREBUS
    rts
INITSINFO_8C:           /* (end bus error protection, then return) */
    jbra INITSINFO_AE
INITSINFO_8E:           /* a card: its own 24-byte sInfo record in the system heap */
    moveal %a0,%a2
    moveq #24,%d0
    .short  0xA71E	| 40805F2A _NewPtr (flags 0x0700)
    jbne INITSINFO_AE
    movel %a0,%a1@(0x0,%d1:w:4)
    moveal %a0,%a1
    moveal %a2,%a0
    movew #100,%a1@(12)	/* siTOConst 100 */
    moveb %d1,%a1@(20)	/* siSlot */
    movel %a3,%a1@(16)	/* siROMAddr = the top byte */
    jbsr VERIFYSLOT
INITSINFO_AE:           /* restore registers, return */
    moveml %sp@+,%d1/%a0-%a3
    rts

/*
 VERIFYSLOT: find and check the card's format header (20 bytes at the top of the
 declaration ROM). Up to 4 times, one address lower each time: the byte lanes byte at
 the top (VERIFYSLOTDONE_E), the header read through those lanes (sReadFHeader), its
 test pattern 0x5A932BC7 (fhTstPat), its format and revision (VERIFYSLOTDONE_6C) and
 the CRC of the ROM (VERIFYSLOTDONE_92). The status goes in siInitStatusA:
 -309 (smBLFieldBad) if no address gives a valid header.
*/
VERIFYSLOT:
    moveml %d1/%a2,%sp@-
    subaw #20,%sp
    moveal %sp,%a2
    movel %a2,%a0@	/* spResult = a 20-byte buffer on the stack */
    moveq #3,%d1
VERIFYSLOT_E:           /* a byte lanes byte at siROMAddr? */
    jbsr VERIFYSLOTDONE_E
    jbne VERIFYSLOTDONE
    moveq #19,%d0	/* _SlotManager 19: READFHEADER, sReadFHeader */
    _SlotManager
    jbne VERIFYSLOT_2E
    cmpil #1519594439,%a2@(14)	/* fhTstPat 0x5A932BC7 */
    jbne VERIFYSLOT_2E
    jbsr VERIFYSLOTDONE_6C
    jbne VERIFYSLOT_2E
    jbsr VERIFYSLOTDONE_92
    jbeq VERIFYSLOT_3C
VERIFYSLOT_2E:          /* try one byte lower */
    subql #1,%a1@(16)
    dbf %d1,VERIFYSLOT_E
    movew #-309,%d0
    jbra VERIFYSLOTDONE
VERIFYSLOT_3C:          /* valid: VERIFYSLOTPATCH (the extended header of slot 0), which ends in VERIFYSLOTDONE */
    jbra VERIFYSLOTPATCH
    .short  0x2152	| 40805F8E
    .long   0x000C06A8, 0xFFFFFFED, 0x000C702C, 0xA06E6604	| 40805F90
    .long   0x22A80004	| 40805FA0

/* VERIFYSLOTDONE: siInitStatusA = d0 (0 or the error), free the buffer, return. */
VERIFYSLOTDONE:
    lea %sp@(20),%sp
    movew %d0,%a1@(4)
    moveml %sp@+,%d1/%a2
    rts

VERIFYSLOTDONE_E:       /* the byte lanes byte (fhByteLanes, the last byte of the ROM): low nibble = the lanes used, high nibble = their complement; it must be on one of the lanes it names */
    moveml %d2/%a0/%a2,%sp@-
    moveal %a1@(16),%a0
    pea %pc@(VERIFYSLOTDONE_24)
    movel @(SDMJmpTblPtr,%za0)@(0xe8),%sp@-	| 40805FBE call PINSTALLBUS
    rts
VERIFYSLOTDONE_24:      /* bus error: -309 */
    lea %pc@(VERIFYSLOTDONE_3C),%a2
VERIFYSLOTDONE_28:      /* read the byte at this address */
    moveb %a0@,%d0
    moveq #15,%d2
    andb %d0,%d2
    jbeq VERIFYSLOTDONE_3C
    notb %d0
    asrw #4,%d0
    cmpb %d0,%d2
    jbne VERIFYSLOTDONE_3C
    btst %d1,%d0
    jbne VERIFYSLOTDONE_48
VERIFYSLOTDONE_3C:      /* not valid: one byte lower */
    subqw #1,%a0
    dbf %d1,VERIFYSLOTDONE_28
    movew #-309,%d0
    jbra VERIFYSLOTDONE_58
VERIFYSLOTDONE_48:      /* found: siCPUByteLanes, siROMAddr = this address, siTopOfROM = its low byte */
    moveb %d0,%a1@(9)
    movel %a0,%a1@(16)
    movel %a0,%d0
    moveb %d0,%a1@(10)
    moveq #0,%d0
VERIFYSLOTDONE_58:      /* end bus error protection */
    pea %pc@(VERIFYSLOTDONE_66)
VERIFYSLOTDONE_5C:      /* (vector call through 0xDB8) */
    movel @(SDMJmpTblPtr,%za0)@(0xec),%sp@-	| 40806000 call PRESTOREBUS
    rts
VERIFYSLOTDONE_66:      /* restore registers, return */
    moveml %sp@+,%d2/%a0/%a2
    rts

VERIFYSLOTDONE_6C:      /* fhFormat 1 (appleFormat), fhROMRev 1..9, fhReserved 0, fhDirOffset non-zero with a zero high byte; else -302 (smFormatErr) */
    cmpib #1,%a2@(13)
    jbne VERIFYSLOTDONE_8C
    cmpib #9,%a2@(12)
    jbhi VERIFYSLOTDONE_8C
    tstb %a2@(18)
    jbne VERIFYSLOTDONE_8C
    movel %a2@,%d0
    jbeq VERIFYSLOTDONE_8C
    roll #8,%d0
    extw %d0
    jbeq VERIFYSLOTDONE_90
VERIFYSLOTDONE_8C:      /* -302 (smFormatErr) */
    movew #-302,%d0
VERIFYSLOTDONE_90:      /* return */
    rts

VERIFYSLOTDONE_92:      /* the CRC (fhCRC) over fhLength bytes, from the start of the ROM (top - length + 1): rotate left 1, add the byte; the 4 bytes of the CRC field itself are skipped. -301 (smCRCFail) if it differs */
    moveml %d1-%d4/%a2-%a4,%sp@-
    moveal %a2,%a4
    movel %a4@(4),%d2
    jbeq VERIFYSLOTDONE_118
    moveq #1,%d1
    subl %d2,%d1
    movel %a1@(16),%a0@(4)	/* spsPointer = the top, spOffsetData = 1 - length */
    movel %d1,%a0@(12)
    moveq #44,%d0	/* _SlotManager 44: CALCSPOINTER, sCalcsPointer */
    _SlotManager
    jbne VERIFYSLOTDONE_118
    moveal %a0@(4),%a3
    bset #5,%a0@(54)
    moveq #40,%d0	/* _SlotManager 40: CALCSTEP, sCalcStep */
    _SlotManager
    jbne VERIFYSLOTDONE_118
    movel %a0@,%d4
    moveq #0,%d1
    moveq #0,%d3
    pea %pc@(VERIFYSLOTDONE_D6)
    movel @(SDMJmpTblPtr,%za0)@(0xe8),%sp@-	| 40806070 call PINSTALLBUS
    rts
VERIFYSLOTDONE_D6:      /* d0 = -301 until it matches; a2 = bus error recovery */
    movew #-301,%d0	/* smCRCFail until it matches */	| 4080607A
    lea %pc@(VERIFYSLOTDONE_10A),%a2	| 4080607E
VERIFYSLOTDONE_DE:      /* next byte: rotate the sum */
    roll #1,%d1	| 40806082
    cmpil #12,%d2	| 40806084
    jbhi VERIFYSLOTDONE_F0	| 4080608A
    cmpil #8,%d2	| 4080608C
    jbhi VERIFYSLOTDONE_F4	| 40806092
VERIFYSLOTDONE_F0:      /* add the byte (except the CRC field: 12..9 bytes before the end) */
    moveb %a3@,%d3	| 40806094
    addl %d3,%d1	| 40806096
VERIFYSLOTDONE_F4:      /* next address for this lane */
    moveb %d4,%d3	| 40806098
    addaw %d3,%a3	| 4080609A
VERIFYSLOTDONE_F8:      /* rotate to the next used lane */
    rorl #8,%d4	| 4080609C
    tstb %d4	| 4080609E
    jbeq VERIFYSLOTDONE_F8	| 408060A0
    subql #1,%d2	| 408060A2
    jbne VERIFYSLOTDONE_DE	| 408060A4
    cmpl %a4@(8),%d1	| 408060A6
    jbne VERIFYSLOTDONE_10A	| 408060AA
    moveq #0,%d0	| 408060AC
VERIFYSLOTDONE_10A:     /* end bus error protection */
    pea %pc@(VERIFYSLOTDONE_118)	| 408060AE
    movel @(SDMJmpTblPtr,%za0)@(0xec),%sp@-	| 408060B2 call PRESTOREBUS
    rts	| 408060BA
VERIFYSLOTDONE_118:     /* restore registers, return */
    moveml %sp@+,%d1-%d4/%a2-%a4
    rts

/*
 INITSRSRC (InitsRsrcTable, 41): add the sResources of the slot's card to the SRT. The
 sResource directory (fhDirOffset) is a list of ID + offset entries ending with ID
 0xFF; the IDs must increase. Each entry is read with PREAD4BYTES and added with
 INSERTSRT. Nothing for a slot whose status is an error.
*/
INITSRSRC:
    moveml %d1-%d3/%a1-%a2,%sp@-
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */
    _SlotManager
    jbne INITSRSRC_7E
    moveal %a0@,%a2
    tstw %a2@(4)	/* siInitStatusA < 0: no valid card */
    jbmi INITSRSRC_7E
    movel %a2@,%a0@(4)	/* spsPointer = the directory (siDirPtr) */
    moveb %a2@(9),%a0@(53)	/* spByteLanes */
    bset #5,%a0@(54)
    moveq #40,%d0	/* _SlotManager 40: CALCSTEP, sCalcStep */
    _SlotManager
    jbne INITSRSRC_7E
    movel %a0@,%a0@(24)	/* spParamData = the lane steps for PREAD4BYTES */
    movel %a2@,%d2
    moveq #0,%d1
INITSRSRC_30:           /* next directory entry: read 4 bytes, advancing d2 */
    movel %d2,%a0@(4)
    pea %pc@(INITSRSRC_42)
    movel @(SDMJmpTblPtr,%za0)@(0xdc),%sp@-	| 408060FA call PREAD4BYTES
    rts
INITSRSRC_42:           /* d3 = the address after the entry */
    jbne INITSRSRC_7E
    movel %a0@(4),%d3
    movel %d2,%a0@(4)
    movel %d3,%d2
    moveb %a0@,%d3
    cmpib #0xff,%d3	/* ID 0xFF ends the list */
    jbeq INITSRSRC_7E
    cmpb %d1,%d3	/* IDs must increase */
    jbls INITSRSRC_7E
    moveb %d3,%d1
    moveb %d3,%a0@(50)	/* spID; the other fields 0, spsPointer 0: looked up */
    clrl %a0@(4)
    clrw %a0@(36)
    clrw %a0@(38)
    clrb %a0@(51)
    clrb %a0@(52)
    clrl %a0@(24)
    moveq #10,%d0	/* _SlotManager 10: INSERTSRT, sInsertSRTRec */
    _SlotManager
    jbeq INITSRSRC_30
INITSRSRC_7E:           /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a1-%a2
    rts

/*
 INITSPRAM (InitPRAMRecs, 37): the slot's PRAM record (8 bytes in parameter RAM: the
 board ID word, then 6 bytes for the card). If the card's board ID (sResource entry
 32 of the board sResource) differs from the one saved in PRAM, the PRAM record is
 initialised from the board's PRAMInitData (entry 33) and siStatusFlags gets
 fCardIsChanged. Only before PrimaryInit (siState below 2) and for slots with a card
 or whose PRAM status is to be cleared.
*/
INITSPRAM:
    moveml %d1-%d3/%a1-%a2,%sp@-
    subqw #8,%sp
    moveal %sp,%a1
    clrl %a1@
    clrl %a1@(4)
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */
    _SlotManager
    jbne INITSPRAM_A2
    moveal %a0@,%a2
    cmpib #2,%a2@(8)	/* siState >= statePRAMInit: already done */
    jbge INITSPRAM_A2
    tstw %a2@(4)	/* siInitStatusA 0: a valid card */
    jbeq INITSPRAM_3A
    cmpiw #-305,%a2@(4)	/* disabled slot: leave its PRAM */
    jbeq INITSPRAM_A2
    cmpiw #-318,%a2@(4)	/* reserved slot: leave its PRAM */
    jbeq INITSPRAM_A2
    jbra INITSPRAM_9A	/* other errors: write the cleared record */
INITSPRAM_3A:           /* d3 = the board ID saved in PRAM */
    movel %a1,%a0@
    moveq #17,%d0	/* _SlotManager 17: READSLOTPRAM, sReadPRAMRec */
    _SlotManager
    movew %a1@,%d3	/* d3 = the board ID saved in PRAM */
    clrl %a1@
    clrl %a1@(4)
    moveq #0,%d1
INITSPRAM_4A:           /* the board sResource (GETBOARD), starting after spID d1 */
    moveb %d1,%a0@(50)
    jbsr GETBOARD
    jbne INITSPRAM_9A
    moveb %a0@(50),%d1
    moveb #32,%a0@(50)	/* sRsrcBoardId (32) */
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    jbeq INITSPRAM_6C
    movew #-315,%a2@(4)	/* siInitStatusA = -315 (smNoBoardId) */
    jbra INITSPRAM_9A
INITSPRAM_6C:           /* d2 = the board ID; the same as in PRAM: nothing to do */
    movew %a0@(2),%d2
    cmpw %d3,%d2	/* the same board as last time: nothing to do */
    jbeq INITSPRAM_A2
    tstb %a0@(49)	/* slot 0: look for another board sResource */
    jbeq INITSPRAM_4A
    moveb #33,%a0@(50)	/* PRAMInitData (33) */
    moveq #38,%d0	/* _SlotManager 38: READPBSIZE, sReadPBSize */
    _SlotManager
    jbne INITSPRAM_98
    subql #4,%a0@(8)	/* its 6 bytes, read after the board ID */
    movel %a1,%a0@
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */
    _SlotManager
    jbne INITSPRAM_98
    bset #1,%a2@(11)	/* siStatusFlags.fCardIsChanged */
INITSPRAM_98:           /* the new board ID at the start of the record */
    movew %d2,%a1@
INITSPRAM_9A:           /* write the record (INITSLOTPRAM) */
    movel %a1,%a0@(4)
    moveq #51,%d0	/* _SlotManager 51: INITSLOTPRAM */
    _SlotManager
INITSPRAM_A2:           /* free it, restore registers, return */
    addqw #8,%sp
    moveml %sp@+,%d1-%d3/%a1-%a2
    rts

/*
 INITPRIMARY (sPrimaryInit, 33): run the PrimaryInit code (entry 34 of the board
 sResource) of slot spSlot, in 32-bit mode, with a 24-byte sExec parameter block on
 the stack (seSlot, seCategoryReg = 32... from spsExecPBlk). Only for a valid card that
 has not reached statePInit (3).
*/
INITPRIMARY:
    moveml %d1-%d3/%a1-%a3,%sp@-
    subaw #24,%sp
    moveal %sp,%a2
    movel %a2,%a0@(20)	/* spsExecPBlk = a 24-byte sExec block on the stack */
    moveb #32,%a2@(1)
    moveq #0,%d0	/* 32-bit addressing */
    _SwapMMUMode
    moveb %d0,%sp@-
    jbsr INITPRIMARY_2A
    moveb %sp@+,%d0
    _SwapMMUMode
    lea %sp@(24),%sp
    moveml %sp@+,%d1-%d3/%a1-%a3
    rts

INITPRIMARY_2A:         /* the board sResource (GETBOARD, from spID 0) */
    clrb %a0@(50)
    jbsr GETBOARD
    bnew INITPRIMARY_6A
    moveal %a0@(4),%a3	/* a3 = the board sResource */
    moveal %a0@,%a1
    tstw %a1@(4)	/* a valid card? */
    jbmi INITPRIMARY_6A
    cmpib #3,%a1@(8)	/* siState < statePInit (3)? */
    jbcc INITPRIMARY_6A
    moveb #34,%a0@(50)	/* PrimaryInit (34) */
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne INITPRIMARY_6A
    movel %a2,%sp@-
    bigjmp SLOTPRIMARYINITPATCH, a2	/* run it (sExec), siState = statePInit */
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40806252
INITPRIMARY_6A:         /* return */
    rts

/*
 STUBCHECKSLOT / STUBADDCARD / STUBREMOVECARD (39, 30, 31): jumps to the docking
 routines CHECKSLOT, ADDCARD and REMOVECARD (os/docking.s), which handle cards that
 come and go (PowerBook docks).
*/
STUBCHECKSLOT:
    .short  0x60FF	| 4080625C
    .long   CHECKSLOT-.	| 4080625E
STUBADDCARD:            /* to ADDCARD */
    jbra ADDCARD	| 40806262
STUBREMOVECARD:         /* to REMOVECARD */
    .short  0x60FF	| 40806268
    .long   REMOVECARD-.	| 4080626A
    .fill   0x4E, 1, 0x00

/*
 INITSECONDARY (50): run the SecondaryInit code (entry 38 of the board sResource) of
 slots 14..0, after the System is loaded (from the start manager), with an sExec
 block on the stack; DOSECONDARYINIT does each slot.
*/
INITSECONDARY:
    moveml %d1-%d2/%a1-%a3,%sp@-
    subaw #24,%sp
    moveal %sp,%a2
    movel %a2,%a0@(20)
    moveb #32,%a2@(1)
    moveq #14,%d1
INITSECONDARY_16:       /* slot d1 */
    moveb %d1,%a0@(49)
    jbsr thunk_FUN_4088c17c
    dbf %d1,INITSECONDARY_16
    cmpib #14,%d1
    jbls INITSECONDARY_16
    lea %sp@(24),%sp
    moveml %sp@+,%d1-%d2/%a1-%a3
    rts

/* STUBDOSECONDARY (15): the SecondaryInit of one slot, in DOSECONDARYINIT. */
thunk_FUN_4088c17c:
STUBDOSECONDARY:        /* continue at DOSECONDARYINIT */
    jbra DOSECONDARYINIT
    .fill   0x7C, 1, 0x00

/*
 GETBOARD: the board sResource of slot spSlot: the next sResource after spID of
 category 1 (catBoard), type 0, enabled or not, in this slot only (sGetTypesRsrc
 with fall and foneslot). Error -313 (smNoBoardSRsrc).
*/
GETBOARD:
    movel %a1,%sp@-
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */
    _SlotManager
GETBOARD_6:             /* a1 = the sInfo record */
    moveal %a0@,%a1
    movel #65536,%a0@(40)	/* spCategory 1 (catBoard), spCType 0 */
    clrl %a0@(44)	/* spDrvrSW, spDrvrHW 0 */
    clrb %a0@(48)	/* spTBMask 0: compare all four */
    clrb %a0@(51)
    clrl %a0@(24)
    orib #3,%a0@(27)	/* fall | foneslot */
    moveq #12,%d0	/* _SlotManager 12: GETTYPESRSRC, sGetTypesRsrc */
    _SlotManager
    jbeq GETBOARD_30
    movew #-313,%d0	/* smNoBoardSRsrc */
GETBOARD_30:            /* spResult = the sInfo record, return (d0 tested) */
    movel %a1,%a0@
    moveal %sp@+,%a1
    tstw %d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408063A6

/*
 READSLOTPRAM (sReadPRAMRec, 17), PUTSLOTPRAM (sPutPRAMRec, 18) and INITSLOTPRAM (51):
 the 8-byte PRAM record of slot spSlot, at XPRAM 70 + 8 * (slot - 9) (slots 9..14;
 slot 0 uses the slot number given in the machine's universal info, the built-in
 video's). Reading copies all 8 bytes to spResult. PUTSLOTPRAM writes 6 bytes from
 spsPointer + 2 at +2, keeping the board ID word; INITSLOTPRAM writes all 8 bytes from
 spsPointer. Error -337 (smSlotOOBErr) for slots above 14 or below 9 (except 0).
*/
SLOTPRAM:
READSLOTPRAM:
    moveq #0,%d0
    movel %a0@,%a0@(24)
    jbra INITSLOTPRAM_8

/* (sPutPRAMRec, 18) d1 = 1: write 6 bytes, keep the board ID. */
PUTSLOTPRAM:
    moveq #1,%d0
    movel %a0@(4),%a0@(24)
    jbra INITSLOTPRAM_8

/* (INITSLOTPRAM, 51) d1 = 2: write all 8 bytes, the board ID included. */
INITSLOTPRAM:
    moveq #2,%d0
    movel %a0@(4),%a0@(24)
INITSLOTPRAM_8:         /* d1 = 0 read, 1 put, 2 init; d3 = spSlot */
    moveml %d1/%d3/%a0-%a1,%sp@-
    clrw %d3
    movel %d0,%d1
    moveb %a0@(49),%d3
    jbne INITSLOTPRAM_2A
    nop
    nop
    nop
    nop
    moveal 0xdd8,%a1	/* slot 0: the built-in video's slot number (universal info) */
    addal %a1@(8),%a1
    moveb %a1@(12),%d3
INITSLOTPRAM_2A:        /* a1 = the buffer */
    moveal %a0@(24),%a1
    movew #-337,%d0	/* smSlotOOBErr */
    cmpib #14,%d3
    jbhi INITSLOTPRAM_76
    cmpib #9,%d3	/* slots 1..8 have no PRAM record */
    jbge INITSLOTPRAM_4A
    tstw @(SInfoPtr,%za0)@(0xffffffffffffffed)	| 40806400
    jbeq INITSLOTPRAM_76
    jbra INITSLOTPRAM_76
INITSLOTPRAM_4A:        /* XPRAM address 70 + 8 * (slot - 9), 8 bytes */
    subib #9,%d3
    muluw #8,%d3
    addiw #70,%d3	/* XPRAM 70 + 8 * (slot - 9) */
    movel #524288,%d0	/* 8 bytes */
    movew %d3,%d0
    moveal %a1,%a0
    tstb %d1
    jbne INITSLOTPRAM_68
    _ReadXPRam
    jbra INITSLOTPRAM_76
INITSLOTPRAM_68:        /* put: 6 bytes from buffer + 2, at address + 2 */
    subql #2,%d1
    jbeq INITSLOTPRAM_74
    addql #2,%a0
    subil #131070,%d0	/* put: 6 bytes at +2 */
INITSLOTPRAM_74:        /* write */
    _WriteXPRam
INITSLOTPRAM_76:        /* restore registers, return */
    moveml %sp@+,%d1/%d3/%a0-%a1
    rts
    .short  0x0000	| 4080643E

/*
 FINDSINFORECPTR (sFindsInfoRecPtr, 47): spResult = the sInfo record of spSlot. Error
 -337 (smSlotOOBErr) for slots above 14.
*/
FINDSINFORECPTR:
    moveq #0,%d0
    moveb %a0@(49),%d0
    cmpib #14,%d0
    jbhi FINDSINFORECPTR_16
    movel @(0xcbc)@(0x0,%d0:w:4),%a0@
    moveq #0,%d0
    jbra FINDSINFORECPTR_1A
FINDSINFORECPTR_16:     /* -337 (smSlotOOBErr) */
    movew #-337,%d0
FINDSINFORECPTR_1A:     /* return */
    rts
    .long   0x00000000	| 4080645C

/*
 FINDSRSRCPTR (sFindsRsrcPtr, 48): spsPointer = the sResource spSlot/spID (spExtDev 0),
 enabled ones only (spParamData 0).
*/
FINDSRSRCPTR:
    clrb %a0@(51)	| 40806460
    clrl %a0@(24)	| 40806464

/*
 GETSRSRCPTR (sGetsRsrcPtr, 29): the same with the caller's spExtDev and spParamData
 flags (fall: disabled ones too): spsPointer = srrsRsrcPtr of the SRT entry found by
 FINDSRTREC.
*/
GETSRSRCPTR:
    movel %a1,%sp@-
    moveq #26,%d0	/* _SlotManager 26: FINDSRTREC, sFindSRTRec */
    _SlotManager
    jbne GETSRSRCPTR_12
    moveal %a0@(4),%a1
    movel %a1@(16),%a0@(4)
GETSRSRCPTR_12:         /* return */
    moveal %sp@+,%a1
    rts
    .short  0x0000	| 4080647E

/*
 PTRTOSLOT (sPtrToSlot, 46): spSlot = the slot of the address in spsPointer: Fsxxxxxx
 (minor slot space) gives s, sxxxxxxx (super slot space) gives s, and an address
 below ROMBase's top nibble (or in it) is slot 0, the motherboard. Errors -335
 (smsPointerNil), -337 (smSlotOOBErr).
*/
PTRTOSLOT:
    moveml %d1-%d2,%sp@-
    movew #-335,%d0
    movel %a0@(4),%d1
    jbeq PTRTOSLOT_3A
    clrb %d1
    roll #4,%d1	/* d1 = the top nibble */
    cmpib #15,%d1	/* F: minor slot space Fsxxxxxx */
    jbeq PTRTOSLOT_26
    moveb ROMBase,%d2	/* super slot space above the ROM's nibble: slot = nibble */
    lsrb #4,%d2
    cmpb %d2,%d1
    jbhi PTRTOSLOT_2A
    moveq #0,%d1	/* else slot 0 */
    jbra PTRTOSLOT_2A
PTRTOSLOT_26:           /* Fs: slot = the second nibble */
    clrb %d1
    roll #4,%d1
PTRTOSLOT_2A:           /* slot 0..14? */
    movew #-337,%d0
    cmpib #14,%d1
    jbhi PTRTOSLOT_3A
    moveb %d1,%a0@(49)
    moveq #0,%d0
PTRTOSLOT_3A:           /* return (d0 tested) */
    tstw %d0
    moveml %sp@+,%d1-%d2
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408064C2

/*
 READFHEADER (sReadFHeader, 19): read the slot's 20-byte format header into the buffer
 at spResult: 19 bytes back from siROMAddr (sCalcsPointer), then sReadStruct.
*/
READFHEADER:
    moveml %a1-%a2,%sp@-
    moveal %a0@,%a2
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */
    _SlotManager
    jbne READFHEADER_3C
    moveal %a0@,%a1
    movew %a1@(4),%d0
    jbmi READFHEADER_3C	/* no valid card */
    movel %a1@(16),%a0@(4)	/* spsPointer = siROMAddr (the top) */
    movel #-19,%a0@(12)	/* 19 bytes back */
    moveb %a1@(9),%a0@(53)
    moveq #44,%d0	/* _SlotManager 44: CALCSPOINTER, sCalcsPointer */
    _SlotManager
    jbne READFHEADER_3C
    movel %a2,%a0@
    movel #20,%a0@(8)	/* 20 bytes into the caller's buffer */
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */
    _SlotManager
READFHEADER_3C:         /* restore registers, return */
    moveml %sp@+,%a1-%a2
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40806512

/*
 CKCARDSTAT (sCkCardStatus, 24): error -341 (smCkStatusErr) if the slot's
 siInitStatusA is negative (no card, or a card that failed its checks).
*/
CKCARDSTAT:
    movel %a2,%sp@-	| 40806520
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */	| 40806522
    _SlotManager	| 40806524
    jbne CKCARDSTAT_14	| 40806526
    moveal %a0@,%a2	| 40806528
    tstw %a2@(4)	| 4080652A
    jbmi CKCARDSTAT_14	| 4080652E
    moveq #0,%d0
    jbra CKCARDSTAT_1A
CKCARDSTAT_14:          /* -341 (smCkStatusErr) */
    movel #-341,%d0	| 40806534
CKCARDSTAT_1A:          /* return */
    moveal %sp@+,%a2
    rts
    .short  0x0000	| 4080653E

/* SLOTVERSION (sVersion, 8): spResult = 2 (the Slot Manager version), spsPointer = 0. */
SLOTVERSION:
    movel #2,%a0@	| 40806540
    clrl %a0@(4)	| 40806546
    moveq #0,%d0	| 4080654A
    rts	| 4080654C
    .byte   0x00, 0x00	| 4080654E

/*
 NEXTSRSRC (sNextsRsrc, 20): the next enabled sResource after spSlot/spID in the SRT
 (fnext). GETSRSRC (sGetsRsrc, 11) uses the caller's spParamData flags (fall,
 foneslot, fnext). The entry found is copied into the SpBlock (PSRTOSPBLOCK).
 Error -344 (smNoMoresRsrcs).
*/
NEXTSRSRC:
    clrl %a0@(24)
    bset #2,%a0@(27)	/* fnext: the entry after spSlot/spID */

GETSRSRC:               /* find the SRT entry, copy it to the SpBlock */
    movel %a1,%sp@-
    moveq #26,%d0	/* _SlotManager 26: FINDSRTREC, sFindSRTRec */
    _SlotManager
    jbne GETSRSRC_1C
    moveal %a0@(4),%a1
    pea %pc@(GETSRSRC_1A)
    movel @(SDMJmpTblPtr,%za0)@(0xd8),%sp@-	| 4080656A call PSRTOSPBLOCK
    rts
GETSRSRC_1A:            /* done */
    jbra GETSRSRC_20
GETSRSRC_1C:            /* -344 (smNoMoresRsrcs) */
    movew #-344,%d0
GETSRSRC_20:            /* return (d0 tested) */
    moveal %sp@+,%a1
    tstw %d0
    rts

/*
 NEXTTYPESRSRC (sNextTypesRsrc, 21) / GETTYPESRSRC (sGetTypesRsrc, 12): the next
 sResource after spSlot/spID whose type (category, cType, DrvrSW, DrvrHW) matches the
 SpBlock's. spTBMask bits 3..0 leave out category, cType, DrvrSW, DrvrHW from the
 comparison (a set bit is "any").
*/
NEXTTYPESRSRC:
    clrl %a0@(24)

GETTYPESRSRC:           /* d1 = mask for category:cType, d2 = for DrvrSW:DrvrHW (from spTBMask) */
    moveml %d1-%d6/%a1,%sp@-
    moveq #0,%d0
    moveb %a0@(48),%d0
    lea %pc@(GETTYPESRSRC_6C),%a1
    lsrb #2,%d0
    movel %a1@(0x0,%d0:w:4),%d1
    moveb %a0@(48),%d0
    andib #3,%d0
    movel %a1@(0x0,%d0:w:4),%d2
    movel %a0@(40),%d3
    movel %a0@(44),%d4
    andl %d1,%d3	/* d3/d4 = the wanted type, masked */
    andl %d2,%d4
GETTYPESRSRC_2C:        /* next SRT entry (fnext): spSlot..spExtDev from it */
    bset #2,%a0@(27)
    moveq #26,%d0	/* _SlotManager 26: FINDSRTREC, sFindSRTRec */
    _SlotManager
    jbne GETTYPESRSRC_66
    moveal %a0@(4),%a1
    movel %a1@,%a0@(49)	/* spSlot, spID, spExtDev, spHWDev from the entry */
    movel %d1,%d5
    andl %a1@(8),%d5	/* category:cType */
    cmpl %d3,%d5
    jbne GETTYPESRSRC_2C
    movel %d2,%d6
    andl %a1@(12),%d6	/* DrvrSW:DrvrHW */
    cmpl %d4,%d6
    jbne GETTYPESRSRC_2C
    pea %pc@(GETTYPESRSRC_62)
    movel @(SDMJmpTblPtr,%za0)@(0xd8),%sp@-	| 408065DC call PSRTOSPBLOCK
    rts
GETTYPESRSRC_62:        /* found */
    moveq #0,%d0
    nop
GETTYPESRSRC_66:        /* restore registers, return (d0 tested) */
    moveml %sp@+,%d1-%d6/%a1
    rts
GETTYPESRSRC_6C:        /* the masks for 2 bits of spTBMask: 00 both words, 01 the high, 10 the low, 11 none */
    .long   0xFFFFFFFF, 0xFFFF0000, 0x0000FFFF, 0x00000000	| 408065F0

/*
 INSERTSRT (sInsertSRTRec, 10) / UPDATESRT (sUpdateSRT, 43): the slot resource table
 (SRT) holds one 24-byte entry per sResource: slot, ID, ExtDev, HWDev, refNum,
 IOReserved, type (8 bytes), pointer to the sResource, flags (bit 0 of the last byte:
 disabled). INSERTSRT adds the entry for spSlot/spID/spExtDev: PNEWSRTENTRY with the
 sResource at spsPointer (0: look it up) and spParamData (non-zero: disabled). If it
 is already in the table it is left as is (no error unless updating). UPDATESRT only
 updates an existing enabled entry's refNum and IOReserved from spRefNum and
 spIOReserved.
*/
UPDATESRT:
    moveq #1,%d0
    clrl %a0@(4)
    clrl %a0@(24)
    jbra INSERTSRT_2

INSERTSRT:              /* d1 = 0 insert */
    moveq #0,%d0
INSERTSRT_2:            /* d1: 1 update; a2 = spsPointer, d2 = spParamData (kept) */
    moveml %d1-%d2/%a1-%a2,%sp@-
    movel %d0,%d1
    moveal %a0@(4),%a2
    movel %a0@(24),%d2
    clrl %a0@(24)
    bset #0,%a0@(27)	/* fall: find it even if disabled */
    moveq #26,%d0	/* _SlotManager 26: FINDSRTREC, sFindSRTRec */
    _SlotManager
    jbeq INSERTSRT_38
    movel %a2,%a0@(4)
    movel %d2,%a0@(24)
    pea %pc@(INSERTSRT_36)
    movel @(SDMJmpTblPtr,%za0)@(0xd0),%sp@-	| 40806638 call PNEWSRTENTRY
    rts
INSERTSRT_36:           /* done */
    jbra INSERTSRT_78
INSERTSRT_38:           /* found: insert does nothing more */
    moveal %a0@(4),%a1
    tstw %d1
    jbeq INSERTSRT_5C
    movew #-344,%d0
    btst #0,%a1@(23)	/* update: not a disabled one */
    jbne INSERTSRT_78
    movew %a0@(36),%a1@(6)	/* srrIOReserved */
    movew %a0@(38),%a1@(4)	/* srrRefNum */
    moveq #0,%d0
    jbra INSERTSRT_78
INSERTSRT_5C:           /* insert of an existing entry with a new sResource pointer: re-initialise it (PINITENTRY) */
    movel %a2,%d0
    jbeq INSERTSRT_78
    movel %a2,%a0@(4)
    movel %d2,%a0@(24)
    pea %pc@(INSERTSRT_76)
    movel @(SDMJmpTblPtr,%za0)@(0xd4),%sp@-	| 40806678 call PINITENTRY
    rts
INSERTSRT_76:           /* done */
    nop	| 40806682
INSERTSRT_78:           /* restore registers, return */
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts

/*
 SEARCHSRT (sSearchSRT, 42) / FINDSRTREC (sFindSRTRec, 26): spsPointer = the SRT entry
 of spSlot/spID/spExtDev. The table is a chain of blocks of 8 entries (0xD24 is the
 first); entries are kept in no order, so the whole table is searched. spParamData
 flags: fall (bit 0, disabled entries too), foneslot (bit 1, only spSlot), fnext
 (bit 2, the entry with the lowest key above spSlot/spID/spExtDev instead of the
 same one). SEARCHSRT turns spFlags bit 0 (fCkForNext) into fnext. Error -344
 (smNoMoresRsrcs).
*/
SEARCHSRT:
    clrl %a0@(24)	| 4080668A
    btst #0,%a0@(54)	/* spFlags.fCkForNext: the next entry */
    jbeq FINDSRTREC
    bset #2,%a0@(27)
FINDSRTREC:             /* d2 = the key: slot, ID, ExtDev (24 bits, shifted up); d3 = best so far */
    moveml %d2-%d4/%a1-%a3,%sp@-
    moveal SRsrcTblPtr,%a1	/* the first SRT block */
    movel %a0@(49),%d2
    clrb %d2
    moveal %a1,%a2
    moveal %a1,%a3
    movel MinusOne,%d3	/* none above it yet */
FINDSRTREC_16:          /* next entry (GETSRTENTRY skips free and disabled ones) */
    jbsr GETSRTENTRY
    jbne FINDSRTREC_40
    movel %a1@,%d4
    clrb %d4
    cmpl %d2,%d4	/* compare keys */
    jbgt FINDSRTREC_32
    jblt FINDSRTREC_3A
    moveal %a1,%a2
    btst #2,%a0@(27)	/* fnext: not this one, the next */
    jbeq FINDSRTREC_64
    jbra FINDSRTREC_3A
FINDSRTREC_32:          /* above it: the lowest such key so far? */
    cmpl %d3,%d4
    jbhi FINDSRTREC_3A
    moveal %a1,%a3
    movel %d4,%d3
FINDSRTREC_3A:          /* next entry */
    lea %a1@(24),%a1
    jbra FINDSRTREC_16
FINDSRTREC_40:          /* end of the table: an entry above the key (fnext)? */
    tstl %d3	/* an entry above the key? */
    jbmi FINDSRTREC_60
    moveq #0,%d0
    moveal %a3,%a2
    btst #2,%a0@(27)
    jbeq FINDSRTREC_60
    btst #1,%a0@(27)	/* foneslot: must be in the same slot */
    jbeq FINDSRTREC_64
    moveb %a0@(49),%d1
    cmpb %a2@,%d1
    jbeq FINDSRTREC_64
FINDSRTREC_60:          /* -344 (smNoMoresRsrcs) */
    movew #-344,%d0
FINDSRTREC_64:          /* spsPointer = the entry, return (d0 tested) */
    movel %a2,%a0@(4)
    moveml %sp@+,%d2-%d4/%a1-%a3
    tstw %d0
    rts

/*
 DELETESRTREC (sDeleteSRTRec, 49): remove the SRT entry of spSlot/spID/spExtDev: the
 last used entry of the table is moved into its place, the count at 0xCBC-18 goes
 down, and when a block becomes empty (count a multiple of 8) it is freed and
 unlinked from the chain. Error -351 (smRecNotFnd).
*/
DELETESRTREC:
    moveml %a0-%a2,%sp@-
    clrl %a0@(24)
    bset #0,%a0@(27)
    moveq #26,%d0	/* _SlotManager 26: FINDSRTREC, sFindSRTRec */
    _SlotManager
    bnew DELETESRTREC_92
    moveal %a0@(4),%a1
    movew #-255,%a1@	/* mark it free */
    .short  0x2470, 0x81E2, 0x0CBC, 0xFFF0	/* a2 = the last used entry (the next free one - 24) */	| moveal @(0xcbc)@(0xfffffffffffffff0),%a2
    movew #23,%d0
DELETESRTREC_2A:        /* move the last entry into the hole (24 bytes) */
    moveb %a2@+,%a1@+
    dbf %d0,DELETESRTREC_2A
    moveal @(SInfoPtr,%za0)@(0xfffffffffffffff0),%a2	| 4080673C
    movew #-255,%a2@
    .short  0x5370, 0x81E2, 0x0CBC, 0xFFEE	/* one entry less */	| subqw #1,@(0xcbc)@(0xffffffffffffffee)
    .short  0x3030, 0x81E2, 0x0CBC, 0xFFEE	| movew @(0xcbc)@(0xffffffffffffffee),%d0
    divuw #8,%d0	/* a whole block now free? */
    andil #-65536,%d0
    jbne DELETESRTREC_82
    moveb MMU32Bit,%sp@-
    clrb %d0
    _SwapMMUMode	/* free the block in 32-bit mode */
    moveal %a2,%a0
    _DisposPtr
    moveb %sp@+,%d0
    _SwapMMUMode
    moveal SRsrcTblPtr,%a1
DELETESRTREC_6C:        /* find the block that links to it (a block's last entry, +192, holds -1 and the link at +2) */
    lea %a1@(192),%a1
    cmpal %a1@(2),%a2
    jbeq DELETESRTREC_7C
    moveal %a1@(2),%a1
    jbra DELETESRTREC_6C
DELETESRTREC_7C:        /* unlink it */
    clrl %a1@(2)
    moveal %a1,%a2
DELETESRTREC_82:        /* the next free entry is one back */
    subaw #24,%a2
    movel %a2,@(SInfoPtr,%za0)@(0xfffffffffffffff0)	| 40806792
    moveq #0,%d0
    jbra DELETESRTREC_96
DELETESRTREC_92:        /* -351 (smRecNotFnd) */
    movew #-351,%d0
DELETESRTREC_96:        /* restore registers, return */
    moveml %sp@+,%a0-%a2
    rts

/*
 SLOTRSRCINFO (sRsrcInfo, 22) / GETSRSRCINFO: copy the SRT entry of spSlot/spID/spExtDev
 into the SpBlock (spsPointer = the sResource, refNum, IOReserved, type, spParamData =
 1 if disabled). SLOTRSRCINFO takes enabled sResources only.
*/
SLOTRSRCINFO:
    clrl %a0@(24)

GETSRSRCINFO:           /* find it, copy it (PSRTOSPBLOCK) */
    movel %a1,%sp@-
    moveq #26,%d0	/* _SlotManager 26: FINDSRTREC, sFindSRTRec */
    _SlotManager
    jbne GETSRSRCINFO_20
    moveal %a0@(4),%a1
    pea %pc@(GETSRSRCINFO_1A)
    movel @(SDMJmpTblPtr,%za0)@(0xd8),%sp@-	| 408067BC call PSRTOSPBLOCK
    rts
GETSRSRCINFO_1A:        /* done */
    jbra GETSRSRCINFO_20
    .long   0x303CFEA1	| 408067C8
GETSRSRCINFO_20:        /* return */
    moveal %sp@+,%a1
    rts

/*
 SETSRSRCSTATE (sSetsRsrcState, 9): enable (spParamData 0) or disable (non-zero) the
 sResource spSlot/spID/spExtDev: bit 0 of its SRT entry's flags.
*/
SETSRSRCSTATE:
    moveml %d1/%a1,%sp@-
    movel %a0@(24),%d1
    clrl %a0@(24)
    bset #0,%a0@(27)
    moveq #26,%d0	/* _SlotManager 26: FINDSRTREC, sFindSRTRec */
    _SlotManager
    jbne SETSRSRCSTATE_2E
    moveal %a0@(4),%a1
    bclr #0,%a1@(23)	/* enable */
    tstb %d1
    jbeq SETSRSRCSTATE_2E
    bset #0,%a1@(23)	/* disable */
    moveq #0,%d0
SETSRSRCSTATE_2E:       /* restore spParamData, return */
    movel %d1,%a0@(24)
    moveml %sp@+,%d1/%a1
    tstw %d0
    rts

/*
 PNEWSRTENTRY (52): add an SRT entry: the sResource is spsPointer, or (if 0) the one with
 ID spID in the card's directory. It takes the next free entry (0xCBC-16); at the end
 of a block (-1), a new block of 8 entries is chained (PALLOCSRTBLK). PINITENTRY fills
 it, the count (0xCBC-18) goes up.
*/
PNEWSRTENTRY:
    moveml %d1/%a1-%a2,%sp@-
    movel %a0@(4),%d0
    jbne PNEWSRTENTRY_22	/* an sResource pointer given? */
    movel %a0@(24),%d1
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */
    _SlotManager
    moveal %a0@,%a1
    movel %a1@,%a0@(4)	/* spsPointer = siDirPtr */
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne PNEWSRTENTRY_72
    movel %d1,%a0@(24)
PNEWSRTENTRY_22:        /* a1 = the next free entry */
    moveal @(SInfoPtr,%za0)@(0xfffffffffffffff0),%a1	| 4080682C
PNEWSRTENTRY_2A:        /* free (-255)? end of block (-1)? else next */
    cmpiw #-255,%a1@
    jbeq PNEWSRTENTRY_52
    cmpiw #-1,%a1@
    jbeq PNEWSRTENTRY_3C
    lea %a1@(24),%a1
    jbra PNEWSRTENTRY_2A
PNEWSRTENTRY_3C:        /* end of block: a new block (PALLOCSRTBLK), linked at +2 of the end marker */
    moveal %a1,%a2
    pea %pc@(PNEWSRTENTRY_4C)
    movel @(SDMJmpTblPtr,%za0)@(0xf0),%sp@-	| 4080684C call PALLOCSRTBLK
    rts
PNEWSRTENTRY_4C:        /* linked */
    jbne PNEWSRTENTRY_72
    movel %a1,%a2@(2)
PNEWSRTENTRY_52:        /* fill the entry (PINITENTRY) */
    pea %pc@(PNEWSRTENTRY_60)
    movel @(SDMJmpTblPtr,%za0)@(0xd4),%sp@-	| 40806860 call PINITENTRY
    rts
PNEWSRTENTRY_60:        /* one more entry; the next free one is after it */
    jbne PNEWSRTENTRY_72
    addqw #1,@(SInfoPtr,%za0)@(0xffffffffffffffee)	| 4080686C
    movel %a1,@(SInfoPtr,%za0)@(0xfffffffffffffff0)
PNEWSRTENTRY_72:        /* restore registers, return */
    moveml %sp@+,%d1/%a1-%a2
    rts

PINITENTRY:             /* (53) fill SRT entry a1 from the SpBlock and the sResource at spsPointer: slot, ID, ExtDev, refNum, IOReserved, sResource pointer, disabled flag from spParamData; then HWDev (sRsrcHWDevId, 8) and the type (sRsrcType, 1); with a refNum, the driver's device base too */
    moveml %d1/%a2,%sp@-
    subqw #8,%sp
    moveal %sp,%a2
    moveb %a0@(49),%a1@
    moveb %a0@(50),%a1@(1)
    moveb %a0@(51),%a1@(2)
    clrb %a1@(3)	/* srrHWDev 0 for now */
    movew %a0@(38),%a1@(4)
    movew %a0@(36),%a1@(6)
    movel %a0@(4),%a1@(16)	/* srrsRsrcPtr */
    clrl %a1@(20)
    movel %a0@(24),%d0
    jbeq PINITENTRY_3E
    bset #0,%a1@(23)	/* disabled */
PINITENTRY_3E:          /* srrHWDev = sRsrcHWDevId (8), if it has one */
    moveb #8,%a0@(50)	/* sRsrcHWDevId (8) */
    moveq #0,%d0	/* _SlotManager 0: READSLOTBYTE, sReadByte */
    _SlotManager
    jbne PINITENTRY_50
    moveb %a0@(3),%a1@(3)
PINITENTRY_50:          /* srrType = the 8 bytes of sRsrcType (1) */
    moveb #1,%a0@(50)	/* sRsrcType (1): 8 bytes into srrType */
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct */
    _SlotManager
    jbne PINITENTRY_9A
    movel #8,%a0@(8)
    movel %a2,%a0@
    moveq #7,%d0	/* _SlotManager 7: READSLOTSTRUCT, sReadStruct */
    _SlotManager
    jbne PINITENTRY_9A
    movel %a2@,%a1@(8)
    movel %a2@(4),%a1@(12)
    moveq #0,%d0
    movew %a0@(38),%d1	/* a driver open (refNum)? its DCE */
    jbeq PINITENTRY_9E
    jbsr PINITENTRY_AE
    jbne PINITENTRY_9A
    moveq #27,%d0	/* _SlotManager 27: FINDDEVBASE, sFindDevBase */
    _SlotManager
    jbne PINITENTRY_9A
    movel %a0@,%a2@(42)	/* dCtlDevBase */
    moveb %a1@(1),%a2@(41)	/* dCtlSlotId */
    .short  0x1569	/* (raw: moveb %a1@(2),%a2@(50): dCtlExtDev) */	| 40806914
    orib #50,%d2
    jbra PINITENTRY_9E
PINITENTRY_9A:          /* failed: free the entry again (-255) */
    movew #-255,%a1@
PINITENTRY_9E:          /* spsPointer = the sResource, return (d0 tested) */
    movel %a1@(16),%a0@(4)
    addqw #8,%sp
    moveml %sp@+,%d1/%a2
    tstw %d0
    rts

PINITENTRY_AE:          /* the DCE of refNum d1 in the unit table (error -51 badUnitErr if none) */
    movew #-51,%d0	/* badUnitErr */
    notw %d1
    jbmi PINITENTRY_D2
    cmpw UnitTableEntryCount,%d1
    jbge PINITENTRY_D2
    aslw #2,%d1
    moveal UTableBase,%a2
    movel %a2@(0x0,%d1:w),%d1
    jbeq PINITENTRY_D2
    moveal %d1,%a2
    movel %a2@,%d1
    jbeq PINITENTRY_D6
    moveal %d1,%a2
    moveq #0,%d0
PINITENTRY_D2:          /* return (d0 tested) */
    tstw %d0
    rts
PINITENTRY_D6:          /* a unit table entry with a nil handle: system error 14 */
    moveq #14,%d0	/* system error 14 */
    _SysError

PALLOCSRTBLK:           /* (60) a new SRT block: 8 free entries (-255) and an end marker (-1, then a 4-byte link) in a 198-byte system pointer */
    movel %a0,%sp@-
    movel #198,%d0	/* 8 entries of 24, end marker -1 and a link */
    .short  0xA71E	| 40806964 _NewPtr (flags 0x0700)
    jbne PALLOCSRTBLK_24
    moveal %a0,%a1
    movew #7,%d0
PALLOCSRTBLK_12:        /* mark each entry free */
    movew #-255,%a0@
    lea %a0@(24),%a0
    dbf %d0,PALLOCSRTBLK_12
    movew #-1,%a0@
    moveq #0,%d0
PALLOCSRTBLK_24:        /* a1 = the block, return */
    moveal %sp@+,%a0
    rts

GETSRTENTRY:            /* (56) the next used SRT entry from a1, following the block chain: skip free entries (-255) and, unless fall, disabled ones. Error -351 (smRecNotFnd) at the end of the table */
    moveml %d1-%d2/%a0,%sp@-
GETSRTENTRY_4:          /* srrSlot < 0: free (-255) or end of block (-1) */
    movew %a1@,%d1
    jbmi GETSRTENTRY_1A
    btst #0,%a0@(27)
    jbne GETSRTENTRY_38
    btst #0,%a1@(23)
    jbeq GETSRTENTRY_38
    jbra GETSRTENTRY_2C
GETSRTENTRY_1A:         /* end of block: follow the link at +2 */
    cmpiw #-1,%d1
    jbne GETSRTENTRY_2C
    tstl %a1@(2)
    jbeq GETSRTENTRY_32
    moveal %a1@(2),%a1
    jbra GETSRTENTRY_4
GETSRTENTRY_2C:         /* next entry */
    lea %a1@(24),%a1
    jbra GETSRTENTRY_4
GETSRTENTRY_32:         /* end of the table: -351 (smRecNotFnd) */
    movew #-351,%d0
    jbra GETSRTENTRY_3A
GETSRTENTRY_38:         /* found */
    moveq #0,%d0
GETSRTENTRY_3A:         /* restore registers, return */
    moveml %sp@+,%d1-%d2/%a0
    rts

/*
 PSRTOSPBLOCK (54): copy SRT entry a1 into the SpBlock: spSlot, spID, spExtDev, spHWDev,
 spRefNum, spIOReserved, the type, spsPointer = the sResource, spParamData = 1 if
 disabled.
*/
PSRTOSPBLOCK:
    moveb %a1@,%a0@(49)
    moveb %a1@(1),%a0@(50)
    moveb %a1@(2),%a0@(51)
    moveb %a1@(3),%a0@(52)
    movew %a1@(4),%a0@(38)
    movew %a1@(6),%a0@(36)
    movew %a1@(8),%a0@(40)
    movew %a1@(10),%a0@(42)
    movew %a1@(12),%a0@(44)
    movew %a1@(14),%a0@(46)
    movel %a1@(16),%a0@(4)
    clrl %a0@(24)
    btst #0,%a1@(23)
    jbeq PSRTOSPBLOCK_54
    movel #1,%a0@(24)
PSRTOSPBLOCK_54:        /* return */
    rts
    .short  0x0000, 0x0000, 0x0000	| 40806A1A

/*
 CALCSTEP (sCalcStep, 40): spResult = the address steps for reading the card's bytes
 one after another, as 4 bytes used in rotation (one per byte lane; a zero step skips
 the lane), for the lane of spsPointer and the lanes in spByteLanes. With fConsecBytes
 (spFlags bit 5) the steps are for consecutive bytes (CALCSTEP_60, rotated to the
 current lane); without it, for consecutive IDs of a list (4 bytes per entry:
 CALCSTEP_A0, or CALCSTEP_E0 for lane combinations where the step varies). Error
 -346 (smBadsPtrErr) if spsPointer's lane is not in use.
*/
CALCSTEP:
    moveml %d1-%d3/%a1,%sp@-
    movew #-346,%d0
    clrw %d1
    clrw %d2
    moveb %a0@(7),%d1
    andil #3,%d1	/* d1 = the lane of spsPointer */
    moveb %a0@(53),%d2	/* d2 = spByteLanes */
    btst %d1,%d2
    jbeq CALCSTEP_5A
    movel %d2,%d3
    aslw #2,%d3
    btst #5,%a0@(54)	/* fConsecBytes? */
    jbeq CALCSTEP_3C
    lea %pc@(CALCSTEP_60),%a1
    movel %a1@(0x0,%d3:w),%d2
    muluw #8,%d1
    rorl %d1,%d2	/* rotate the steps to start at the current lane */
    movel %d2,%a0@
    jbra CALCSTEP_58
CALCSTEP_3C:            /* steps between list entries; -1: they depend on the lane */
    lea %pc@(CALCSTEP_A0),%a1
    movel %a1@(0x0,%d3:w),%a0@
    jbpl CALCSTEP_58	/* -1: the step depends on the lane */
    lea %pc@(CALCSTEP_E0),%a1
    andib #7,%d2
    subqb #3,%d2
    asll #4,%d2
    addal %d1,%a1
    movel %a1@(0x0,%d2:w),%a0@
CALCSTEP_58:            /* no error */
    clrw %d0
CALCSTEP_5A:            /* restore registers, return */
    moveml %sp@+,%d1-%d3/%a1
    rts
CALCSTEP_60:            /* steps between consecutive bytes, for each spByteLanes value 0..15 */
    .long   0x00000000, 0x04040404, 0x04040404, 0x03010301	| 40806A80
    .long   0x04040404, 0x02020202, 0x03010301, 0x00020101	| 40806A90
    .long   0x04040404, 0x01030103, 0x02020202, 0x00010201	| 40806AA0
    .long   0x03010301, 0x00010102, 0x00020101, 0x01010101	| 40806AB0
CALCSTEP_A0:            /* steps between list entries (4 bytes), for each spByteLanes value; -1 = see CALCSTEP_E0 */
    .long   0x00000000, 0x10101010, 0x10101010, 0x08080808	| 40806AC0
    .long   0x10101010, 0x08080808, 0x08080808, 0xFFFFFFFF	| 40806AD0
    .long   0x10101010, 0x08080808, 0x08080808, 0xFFFFFFFF	| 40806AE0
    .long   0x08080808, 0xFFFFFFFF, 0xFFFFFFFF, 0x04040404	| 40806AF0
CALCSTEP_E0:            /* steps between list entries for the lane combinations marked -1, by lane */
    .long   0x05050505, 0x06060606, 0x00000000, 0x05050505	| 40806B00
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40806B10
    .long   0x06060606, 0x00000000, 0x05050505, 0x05050505	| 40806B20
    .long   0x00000000, 0x05050505, 0x05050505, 0x06060606	| 40806B30
    .long   0x05050505, 0x05050505, 0x06060606, 0x00000000	| 40806B40

/*
 OFFSETDATA (sOffsetData, 36): find entry spID in the list at spsPointer: each entry is
 an ID byte and a 3-byte offset, read 4 bytes at a time through the byte lanes
 (PREAD4BYTES). spOffsetData = the offset of the entry, spsPointer = the address of
 its offset field. Errors -330 (smBadRefId: ID 0xFF, or not found before the end
 of the list), -331 (smBadsList: IDs not increasing).
*/
OFFSETDATA:
    moveml %d1-%d2/%a1,%sp@-
    moveb %a0@(49),%sp@-
    movew #-330,%d0
    cmpib #0xff,%a0@(50)	/* ID 0xFF is the end marker */
    beqw OFFSETDATA_84
    moveq #46,%d0	/* _SlotManager 46: PTRTOSLOT, sPtrToSlot */
    _SlotManager
    bnew OFFSETDATA_84
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */
    _SlotManager
    moveal %a0@,%a1
    movew %a1@(4),%d0
    jbmi OFFSETDATA_84	/* no valid card */
    moveb %a1@(9),%a0@(53)
    bset #5,%a0@(54)
    moveq #40,%d0	/* _SlotManager 40: CALCSTEP, sCalcStep */
    _SlotManager
    jbne OFFSETDATA_84
    movel %a0@,%a0@(24)	/* spParamData = the steps for PREAD4BYTES */
    moveq #0,%d1
OFFSETDATA_42:          /* next entry: d2 = the previous ID, a1 = its address */
    moveb %d1,%d2
    moveal %a0@(4),%a1
    pea %pc@(OFFSETDATA_56)
    movel @(SDMJmpTblPtr,%za0)@(0xdc),%sp@-	| 40806B9C call PREAD4BYTES
    rts
OFFSETDATA_56:          /* d1 = this entry's ID */
    jbne OFFSETDATA_84
    moveb %a0@,%d1
    movew #-331,%d0	/* IDs must increase (smBadsList) */
    cmpb %d2,%d1
    jbcs OFFSETDATA_84
    movew #-330,%d0	/* end of list (smBadRefId) */
    cmpib #0xff,%d1
    jbeq OFFSETDATA_84
    cmpb %a0@(50),%d1
    jbne OFFSETDATA_42
    movel %a0@,%d0
    andil #16777215,%d0	/* spOffsetData = the 24-bit offset */
    movel %d0,%a0@(12)
    movel %a1,%a0@(4)	/* spsPointer = the entry (offsets count from there) */
    moveq #0,%d0
OFFSETDATA_84:          /* restore spSlot, registers, return (d0 tested) */
    moveb %sp@+,%a0@(49)
    moveml %sp@+,%d1-%d2/%a1
    tstw %d0
    rts

/*
 READPBSIZE (sReadPBSize, 38): spSize = the long at entry spID's offset: the size of a
 block (sBlock). With fCkReserved (spFlags bit 1) its high byte, reserved, must be 0,
 else -332 (smReservedErr).
*/
READPBSIZE:
    moveml %d1/%a1,%sp@-
    moveb %a0@(49),%sp@-
    moveq #6,%d0	/* _SlotManager 6: FINDSLOTSTRUCT, sFindStruct; spsPointer = the block */
    _SlotManager
    jbne READPBSIZE_5C
    moveq #46,%d0	/* _SlotManager 46: PTRTOSLOT, sPtrToSlot */
    _SlotManager
    jbne READPBSIZE_5C
    moveq #47,%d0	/* _SlotManager 47: FINDSINFORECPTR, sFindsInfoRecPtr */
    _SlotManager
    moveal %a0@,%a1
    movew %a1@(4),%d0
    jbmi READPBSIZE_5C
    moveb %a1@(9),%a0@(53)
    bset #5,%a0@(54)
    moveq #40,%d0	/* _SlotManager 40: CALCSTEP, sCalcStep */
    _SlotManager
    jbne READPBSIZE_5C
    movel %a0@,%a0@(24)	/* spParamData = the steps */
    pea %pc@(READPBSIZE_44)
    movel @(SDMJmpTblPtr,%za0)@(0xdc),%sp@-	| 40806C1A call PREAD4BYTES
    rts
READPBSIZE_44:          /* spSize = the long */
    jbne READPBSIZE_5C
    movel %a0@,%a0@(8)
    moveq #0,%d0
    btst #1,%a0@(54)	/* fCkReserved: is the high byte 0? */
    jbeq READPBSIZE_5C
    moveb %a0@,%d1
    jbeq READPBSIZE_5C
    movew #-332,%d0	/* smReservedErr */
READPBSIZE_5C:          /* restore spSlot, registers, return (d0 tested) */
    moveb %sp@+,%a0@(49)
    moveml %sp@+,%d1/%a1
    tstw %d0
    rts
    .long   0x00000000, 0x00000000	| 40806C48

/*
 PREAD4BYTES (55): spResult = 4 bytes read from spsPointer through the byte lanes,
 with the steps in spParamData (from sCalcStep); spsPointer advances past them. Bus
 errors give -308 (smUnExBusErr).
*/
PREAD4BYTES:
    moveml %d1-%d4/%a1-%a2,%sp@-
    movel %a0@(24),%d2
    moveal %a0@(4),%a1
    moveq #3,%d3
    moveq #0,%d4
    pea %pc@(PREAD4BYTES_1E)
    movel @(SDMJmpTblPtr,%za0)@(0xe8),%sp@-	| 40806C64 call PINSTALLBUS
    rts
PREAD4BYTES_1E:         /* bus error: -308 */
    lea %pc@(PREAD4BYTES_40),%a2
    movew #-308,%d0	/* if a bus error ends it (smUnExBusErr) */
PREAD4BYTES_26:         /* shift in one byte, step to the next lane */
    asll #8,%d1
    moveb %a1@,%d1
    moveb %d2,%d4
    addaw %d4,%a1
PREAD4BYTES_2E:         /* skip lanes with a step of 0 */
    rorl #8,%d2
    tstb %d2
    jbeq PREAD4BYTES_2E
    dbf %d3,PREAD4BYTES_26
    movel %d1,%a0@
    movel %a1,%a0@(4)
    moveq #0,%d0
PREAD4BYTES_40:         /* end bus error protection */
    pea %pc@(PREAD4BYTES_4E)
    movel @(SDMJmpTblPtr,%za0)@(0xec),%sp@-	| 40806C94 call PRESTOREBUS
    rts
PREAD4BYTES_4E:         /* restore registers, return */
    moveml %sp@+,%d1-%d4/%a1-%a2
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40806CA4

/*
 PBUSEXCEPTION (57), PINSTALLBUS (58), PRESTOREBUS (59): the declaration ROM of a slot
 is read with bus errors caught: an empty slot or a card that does not answer a lane
 gives a bus error instead of data. PINSTALLBUS (interrupts off for the switch)
 saves the MMU mode and the bus error vector (in the globals before 0xCBC, -4 and -8),
 switches to 32-bit mode and installs PBUSEXCEPTION. The caller sets a2 to its
 recovery address beforehand. PBUSEXCEPTION takes only data read faults (68040
 access error frame, format 7: SSW at +12 without other bits, a read) at slot
 addresses (0x90000000 and up, except Fx and FF space and the top 16); it jumps to
 the 68040 recovery code (BUSEXCPT_040 region, PC-relative +0x454F2) that resumes at
 a2. Any other bus error goes to the saved vector. PRESTOREBUS puts both back.
*/
PBUSEXCEPTION:
    movel %d0,%sp@-	| 40806CB0
    movew %sp@(14),%d0	/* the SSW of the access error frame */	| 40806CB2
    andiw #-3648,%d0	| 40806CB6
    cmpiw #320,%d0	/* a plain data read? */	| 40806CBA
    jbne PBUSEXCEPTION_3E	| 40806CBE
    moveb %sp@(10),%d0	| 40806CC0
    lsrb #4,%d0	| 40806CC4
    cmpib #11,%d0	/* frame format 7? */	| 40806CC6
    jbne PBUSEXCEPTION_3E	| 40806CCA
    moveb %sp@(20),%d0	/* the fault address' top byte */	| 40806CCC
    cmpib #0x90,%d0	| 40806CD0
    jbcs PBUSEXCEPTION_3E	| 40806CD4
    cmpib #0xff,%d0	| 40806CD6
    jbeq PBUSEXCEPTION_3E	| 40806CDA
    cmpib #0xf0,%d0	| 40806CDC
    jbeq PBUSEXCEPTION_3E	| 40806CE0
    movel %a0,%sp@-	| 40806CE2
PBUSEXCEPTION_34:       /* ours: recover at a2 (68040 frame cleanup) */
    lea 0x454f2,%a0	| 40806CE4
    jmp %pc@(PBUSEXCEPTION_34,%a0:l)	| 40806CEA
PBUSEXCEPTION_3E:       /* not ours: the saved bus error vector */
    movel %sp@+,%d0	| 40806CEE
    movel @(SInfoPtr,%za0)@(0xfffffffffffffff8),%sp@-	| 40806CF0
    rts	| 40806CF8

PINSTALLBUS:            /* no interrupts while the vector and the MMU mode change */
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #1,%d0	/* 32-bit addressing; the old mode at 0xCBC-4 */
    _SwapMMUMode
    .short  0x1180, 0x81E2, 0x0CBC, 0xFFFC	| moveb %d0,@(0xcbc)@(0xfffffffffffffffc)
    .short  0x21B8, 0x0008, 0x81E2, 0x0CBC, 0xFFF8	/* save the bus error vector at 0xCBC-8 */	| movel 0x8,@(0xcbc)@(0xfffffffffffffff8)
    .short  0x21F0, 0x81E2, 0x0DB8, 0x00E4, 0x0008	/* install PBUSEXCEPTION */	| movel @(0xdb8)@(0xe4),0x8
    movew %sp@+,%sr
    rts

PRESTOREBUS:            /* keep d0 (the result) */
    movel %d0,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    moveb @(SInfoPtr,%za0)@(0xfffffffffffffffc),%d0	| 40806D2C
    _SwapMMUMode
    .short  0x21F0, 0x81E2, 0x0CBC, 0xFFF8, 0x0008	| movel @(0xcbc)@(0xfffffffffffffff8),0x8
    movew %sp@+,%sr
    movel %sp@+,%d0
    rts

/* PRIMARY_INIT: an unused stub (24-byte sExec block set-up, then zeros). */
PRIMARY_INIT:
    moveml %d1/%a1-%a3,%sp@-
    subaw #24,%sp
    moveal %sp,%a2
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40806D50

/*
 INITJMPTBL: the Slot Manager's vector table (0xDB8, 61 longs, a new system pointer
 each start-up), from the self-relative offsets of INITJMPTBL_38; entry n is selector
 n of _SlotManager, so internal routines are also reached as "pea return / move.l
 (0xDB8)@(4n),-(sp) / rts" and can be patched in RAM. INITJMPTBLPATCH continues.
*/
INITJMPTBL:
    moveml %a0-%a2,%sp@-
    cmpil #-1,SDMJmpTblPtr
    jbeq INITJMPTBL_14
    moveal SDMJmpTblPtr,%a0
    _DisposPtr
INITJMPTBL_14:          /* 244 bytes: 61 entries */
    movel #244,%d0
    .short  0xA71E	| 40806D7A _NewPtr (flags 0x0700)
    movel %a0,SDMJmpTblPtr
    moveq #60,%d0
    lea %pc@(INITJMPTBL_38),%a1
INITJMPTBL_26:          /* entry = address of the offset + the offset */
    moveal %a1,%a2
    addaw %a1@+,%a2
    movel %a2,%a0@+
    dbf %d0,INITJMPTBL_26
    jbra INITJMPTBLPATCH
    .short  0x0000	| 40806D96
INITJMPTBL_38:          /* offsets of selectors 0..60 (bad selectors: SLOTMANAGER_E) */
    .short  READSLOTBYTE-.	| 40806D98
    .short  READSLOTWORD-.	| 40806D9A
    .short  READSLOTLONG-.	| 40806D9C
    .short  GETCSTRING-.	| 40806D9E
    .short  SLOTMANAGER_E-.	| 40806DA0
    .short  GETSLOTBLOCK-.	| 40806DA2
    .short  FINDSLOTSTRUCT-.	| 40806DA4
    .short  READSLOTSTRUCT-.	| 40806DA6
    .short  SLOTVERSION-.	| 40806DA8
    .short  SETSRSRCSTATE-.	| 40806DAA
    .short  INSERTSRT-.	| 40806DAC
    .short  GETSRSRC-.	| 40806DAE
    .short  GETTYPESRSRC-.	| 40806DB0
    .short  SLOTMANAGER_E-.	| 40806DB2
    .short  SLOTMANAGER_E-.	| 40806DB4
    .short  STUBDOSECONDARY-.	| 40806DB6
    .short  READSLOTINFO-.	| 40806DB8
    .short  SLOTPRAM-.	| 40806DBA
    .short  PUTSLOTPRAM-.	| 40806DBC
    .short  READFHEADER-.	| 40806DBE
    .short  NEXTSRSRC-.	| 40806DC0
    .short  NEXTTYPESRSRC-.	| 40806DC2
    .short  SLOTRSRCINFO-.	| 40806DC4
    .short  SLOTDISPOSPTR-.	| 40806DC6
    .short  CKCARDSTAT-.	| 40806DC8
    .short  READSLOTDRVRNAME-.	| 40806DCA
    .short  FINDSRTREC-.	| 40806DCC
    .short  FINDDEVBASE-.	| 40806DCE
    .short  FINDDEVBASE-.	| 40806DD0
    .short  GETSRSRCPTR-.	| 40806DD2
    .short  STUBADDCARD-.	| 40806DD4
    .short  STUBREMOVECARD-.	| 40806DD6
    .short  INITSINFO-.	| 40806DD8
    .short  INITPRIMARY-.	| 40806DDA
    .short  FINDDEVBASE_B0-.	| 40806DDC
    .short  SLOTEXEC-.	| 40806DDE
    .short  OFFSETDATA-.	| 40806DE0
    .short  INITSPRAM-.	| 40806DE2
    .short  READPBSIZE-.	| 40806DE4
    .short  STUBCHECKSLOT-.	| 40806DE6
    .short  CALCSTEP-.	| 40806DE8
    .short  INITSRSRC-.	| 40806DEA
    .short  SEARCHSRT-.	| 40806DEC
    .short  UPDATESRT-.	| 40806DEE
    .short  CALCSPOINTER-.	| 40806DF0
    .short  GETSLOTDRVR-.	| 40806DF2
    .short  PTRTOSLOT-.	| 40806DF4
    .short  FINDSINFORECPTR-.	| 40806DF6
    .short  FINDSRSRCPTR-.	| 40806DF8
    .short  DELETESRTREC-.	| 40806DFA
    .short  INITSECONDARY-.	| 40806DFC
    .short  INITSLOTPRAM-.	| 40806DFE
    .short  PNEWSRTENTRY-.	| 40806E00
    .short  PINITENTRY-.	| 40806E02
    .short  PSRTOSPBLOCK-.	| 40806E04
    .short  PREAD4BYTES-.	| 40806E06
    .short  GETSRTENTRY-.	| 40806E08
    .short  PBUSEXCEPTION-.	| 40806E0A
    .short  PINSTALLBUS-.	| 40806E0C
    .short  PRESTOREBUS-.	| 40806E0E
    .short  PALLOCSRTBLK-.	| 40806E10
    .byte   0x32, 0x2E, 0x31, 0x30	| 40806E12

/*
 _SlotManager (A06E): d0 = selector, a0 = SpBlock; jumps to entry d0 of the vector
 table at 0xDB8 (INITJMPTBL). A selector above 61 returns -338 (smSelOOBErr). (61 is
 accepted though the table has entries 0..60 only; the long after the table is read.)
*/
trap_SlotManager:
SLOTMANAGER:            /* selector 0..61? */
    cmpiw #61,%d0
    jbhi SLOTMANAGER_E
    moveal @(0xdb8)@(0x0,%d0:w:4),%a1
    jmp %a1@
SLOTMANAGER_E:          /* -338 (smSelOOBErr) */
    movew #-338,%d0
    rts
    .short  0x0000, 0x0000, 0x0000	| 40806E2A

/*
 SINTCORE: for _SIntInstall/_SIntRemove: check the element (sqType 6 = sIQType) and the
 slot (d0 up to 14), a1 = the queue head of that slot (in the table at 0xD04, +64).
 On an error it returns to the trap's caller directly (pops its own return address):
 -2 for a bad queue type, -337 (smSlotOOBErr) for a bad slot.
*/
SINTCORE:
    cmpiw #6,%a0@(4)	/* sqType 6 (sIQType)? */
    jbne SINTCORE_1A
    extw %d0
    cmpiw #14,%d0
    jbgt SINTCORE_1E
    lea @(0xd04)@(0x40,%d0:w:4),%a1	/* a1 = the slot's queue head */
    rts
SINTCORE_1A:            /* bad queue type: -2 */
    moveq #-2,%d0
    jbra SINTCORE_22
SINTCORE_1E:            /* bad slot: -337 (smSlotOOBErr) */
    movew #-337,%d0
SINTCORE_22:            /* return to the trap's caller */
    addqw #4,%sp
    rts

/*
 _SIntInstall(a0 = slot interrupt queue element, d0 = slot): insert the element in the
 slot's queue, by priority (sqPrio, +7, higher first), with interrupts off.
*/
trap_SIntInstall:
SINTINSTALL:            /* check the element, a1 = the slot's queue head */
    jbsr SINTCORE
    moveb %a0@(7),%d0	/* d0 = sqPrio */
    movew %sr,%sp@-
    oriw #1792,%sr
SINTINSTALL_C:          /* walk to the first element with a lower priority */
    movel %a1@,%d1
    jbeq SINTINSTALL_1A
    exg %d1,%a1
    cmpb %a1@(7),%d0
    jbls SINTINSTALL_C
    exg %d1,%a1
SINTINSTALL_1A:         /* link it in */
    movel %d1,%a0@
    movel %a0,%a1@
    movew %sp@+,%sr
    moveq #0,%d0
    rts

/*
 _SIntRemove(a0 = element, d0 = slot): unlink the element from the slot's queue. Error
 -1 if it is not there.
*/
trap_SIntRemove:
SINTREMOVE:             /* check the element, a1 = the slot's queue head */
    jbsr SINTCORE
    moveq #-1,%d0
    movew %sr,%sp@-
    oriw #1792,%sr
SINTREMOVE_A:           /* find the element that links to it */
    movel %a1@,%d1
    jbeq SINTREMOVE_1A
    exg %d1,%a1
    cmpal %a0,%a1
    jbne SINTREMOVE_A
    moveal %d1,%a1
    movel %a0@,%a1@
    moveq #0,%d0
SINTREMOVE_1A:          /* return */
    movew %sp@+,%sr
    rts

/*
 VIA2SLOTINT / SLOTINT: slot interrupt handler on VIA 2 (a1 = VIA 2): clear the CA1
 flag (IFR = 2), read port A (one line per slot 9..14, active low) and run the
 handlers of the active slots (SLOTINTCOMMON).
*/
VIA2SLOTINT:
SLOTINT:
    moveb #2,%a1@(6656)	/* clear CA1 in the IFR */	| 40806E98
    moveq #-64,%d0	| 40806E9E
    orb %a1@(7680),%d0	/* port A: slot lines, active low */	| 40806EA0
    notl %d0	| 40806EA4
    jbne SLOTINTCOMMON	| 40806EA6
    rts	| 40806EA8

/*
 RBVSLOTINT: the same for the RBV (Mac IIci/IIsi): clear its slot interrupt flag, read
 the slot lines (+2) masked by the enable register (+18).
*/
RBVSLOTINT:
    moveb #0x82,%a1@(3)	| 40806EAA
    moveq #-128,%d0	| 40806EB0
    orb %a1@(2),%d0	| 40806EB2
    notl %d0	| 40806EB6
    andb %a1@(18),%d0	| 40806EB8
    jbne SLOTINTCOMMON	| 40806EBC
    rts	| 40806EBE

/* OSSSLOTINT: the same for the OSS (Mac IIfx): the slot interrupt pending bits (+515). */
OSSSLOTINT:
    moveq #63,%d0	| 40806EC0
    andb %a1@(515),%d0	/* pending slot interrupts */	| 40806EC2
    jbne SLOTINTCOMMON	| 40806EC6
    rts	| 40806EC8

/*
 SLOTINTCOMMON: for each slot with its line active (highest first), run its queue of
 handlers until one claims the interrupt.
*/
SLOTINTCOMMON:
    subql #4,%sp
    moveb %d0,%sp@
SLOTINTCOMMON_4:        /* highest pending slot (RUNSLOTHANDLERS_28: slot number << 4 | bit, per pattern); clear its bit, run its handlers */
    moveb %pc@(RUNSLOTHANDLERS_28,%d0:w),%d0
    bclr %d0,%sp@
    lsrb #4,%d0
    jbsr RUNSLOTHANDLERS
    jbne SLOTINTCOMMON_20
    moveb %sp@,%d0
    jbne SLOTINTCOMMON_4	/* more slots pending */
    addql #4,%sp
    moveal ghost_VIA2,%a1	/* done: on through the vector at 0xD74 with a1 = VIA 2 */
    moveal 0xd74,%a0
    jmp %a0@
SLOTINTCOMMON_20:       /* no handler claimed it: system error 51 (dsBadSlotInt) */
    _SysError

/*
 RUNSLOTHANDLERS: run the handlers of slot d0 in priority order: each is called with
 a1 = its sqParm (+12) and returns d0 non-zero if it serviced the interrupt. d0 = 0 if
 one did, 51 if none.
*/
RUNSLOTHANDLERS:
    lea @(0xd04)@(0x40,%d0:w:4),%a1
RUNSLOTHANDLERS_8:      /* next handler: call sqAddr (+8) with a1 = sqParm */
    movel %a1@,%d0
    jbeq RUNSLOTHANDLERS_24
    moveal %d0,%a1
    movel %a1,%sp@-
    moveal %a1@(8),%a0
    moveal %a1@(12),%a1
    jsr %a0@
    moveal %sp@+,%a1
    tstw %d0
    jbeq RUNSLOTHANDLERS_8
    moveq #0,%d0
    rts
RUNSLOTHANDLERS_24:     /* none serviced it: 51 */
    moveq #51,%d0
    rts
RUNSLOTHANDLERS_28:     /* for each 6-bit pattern of pending slots (bit 0 = slot 9): the highest slot's bit, and slot number in the high nibble */
    .long   0x0090A190, 0xB290A190, 0xC390A190	| 40806F14
    .long   0xB290A190, 0xD490A190, 0xB290A190, 0xC390A190	| 40806F20
    .long   0xB290A190, 0xE590A190, 0xB290A190, 0xC390A190	| 40806F30
    .long   0xB290A190, 0xD490A190, 0xB290A190, 0xC390A190	| 40806F40
    .long   0xB290A190, 0x0690A190, 0xB290A190, 0xC390A190	| 40806F50
    .long   0xB290A190, 0xD490A190, 0xB290A190, 0xC390A190	| 40806F60
    .long   0xB290A190, 0xE590A190, 0xB290A190, 0xC390A190	| 40806F70
    .long   0xB290A190, 0xD490A190, 0xB290A190, 0xC390A190	| 40806F80
    .long   0xB290A190	| 40806F90

/*
 INITSDTBL: the slot interrupt queue table (0xD04): 368 bytes, with the 15 queue
 headers at +130 (16 bytes apart) and a pointer to each at the start.
*/
INITSDTBL:
    movel #368,%d0
    .short  0xA71E	| 40806F9A _NewPtr (flags 0x0700)
    movel %a0,0xd04
    lea %a0@(130),%a1
    moveq #14,%d0
INITSDTBL_12:           /* one pointer per slot */
    movel %a1,%a0@+
    lea %a1@(16),%a1
    dbf %d0,INITSDTBL_12
    moveq #0,%d0
    rts

/* INITSPTBL: (the slot priority table) */
INITSPTBL:              /* (an empty routine: rts) */
    .long   0x4E750000, 0x00000000, 0x00000000	| 40806FB4
