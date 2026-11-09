/*
 os/devicemgr.s - Device Manager I/O core and driver traps
 From IOCORE (0x4080B520). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the Device Manager chapter of Inside
 Macintosh), not taken from Apple. a0 = the I/O parameter block (+6 trap, +12
 completion, +16 ioResult, +18 name, +24 refnum, +26 csCode / permission, +32
 buffer, +36 count, +40 actual count, +44 positioning), a1 = the DCE (+0 driver, +4
 flags, +5 status: bit 5 open, 6 RAM-based / handle, 7 busy, +6 queue, +16 position,
 +24 refnum, +40/+41 slot and ID, +42 device base, +50 ext device).
*/

/* FSIODNETBL: offsets of Fetch, Stash, IODone (copied to JFetch, JStash, JIODone). */
IOCORE:
FSIODNETBL:
    .short  0x0006, 0x004A, 0x0052	| 4080B520

/*
 Fetch / Stash: next byte from (or into) the buffer of the request at the head of the
 driver's queue (a1 = DCE). Out: d0 = byte, bit 15 set when it was the last one.
 No request: system error 14.
*/
FETCH:
    .short  0x0880, 0x000F	| 4080B526
FETCH_4:                /* (common, bit 15 of d0 = stash) */
    moveml %d1/%a2-%a3,%sp@-
    movel %a1@(8),%d1
    jbeq FETCH_40
    moveal %d1,%a3
    movel %a3@(40),%d1
    moveal %a3@(32),%a2
    bclr #15,%d0
    jbne FETCH_24
    moveb %a2@(0x0,%d1:l),%d0
    jbra FETCH_28
FETCH_24:               /* stash */
    moveb %d0,%a2@(0x0,%d1:l)
FETCH_28:               /* count it, last one? */
    addql #1,%d1
    movel %d1,%a3@(40)
    cmpl %a3@(36),%d1
    jblt FETCH_38
    bset #15,%d0
FETCH_38:               /* return */
    extl %d0
    moveml %sp@+,%d1/%a2-%a3
    rts
FETCH_40:               /* no request: system error 14 (dsIOCoreErr) */
    moveq #14,%d0
    _SysError

/* STASH: (see Fetch). */
STASH:
    bset #15,%d0
    jbra FETCH_4
STASH_6:                /* (d0 = 0 then IODone) */
    moveq #0,%d0

/*
 IODone (a1 = DCE, d0 = result): the current request is done: unlock the driver,
 complete it (result, completion routine), and start the next one in the queue.
*/
IODONE:
    movew %d0,%sp@-
    movel %d0,%sp@-
    movel %a1,%d0
    _StripAddress
    moveal %d0,%a1
    movel %sp@+,%d0
    jbsr IODONE_12
    movew %sp@+,%d0
    rts

IODONE_12:              /* complete the request, start the next if any */
    movel %a1@(8),%d1
    jbeq IODONE_38
    movew %sr,%sp@-
    movew %sr,%d1
    oriw #1792,%sr
    jbsr IODONE_32
    jbsr IODONE_50
    oriw #1792,%sr
    tstl %a1@(8)
    jbne IODONE_96
    movew %sp@+,%sr
    rts

IODONE_32:              /* not busy */
    bclr #7,%a1@(5)
IODONE_38:              /* unlock the driver (RAM driver: its code and DCE handles) */
    btst #6,%a1@(4)
    jbne IODONE_4E
    moveal %a1@,%a0
    movel %d0,%sp@-
    _HUnlock
    moveal %a1,%a0
    .short  0xA528	| 4080B5BA _RecoverHandle (flags 0x0500)
    _HUnlock
    movel %sp@+,%d0
IODONE_4E:              /* return */
    rts

IODONE_50:              /* dequeue the request (must be an I/O queue element), result, completion routine */
    moveal %a1@(8),%a0
    cmpiw #2,%a0@(4)
    jbne FETCH_40
    movel %a0@,%a1@(8)
    jbne IODONE_66
    clrl %a1@(12)
IODONE_66:              /* (result > 0 means 0) */
    movew %d1,%sr
    movew %d0,%a0@(16)
    jble IODONE_72
    clrw %a0@(16)
IODONE_72:              /* call the completion routine (a0 = block, d0 = result) */
    movel %a0@(12),%d1
    jbeq IODONE_82
    movel %a1,%sp@-
    moveal %d1,%a1
    extl %d0
    jsr %a1@
    moveal %sp@+,%a1
IODONE_82:              /* return */
    rts

IODONE_84:              /* queue the request on the driver (interrupts masked), start it if idle */
    movel %a1,%d1
    lea %a1@(6),%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    jsr %pc@(trap_Enqueue)
    moveal %d1,%a1
IODONE_96:              /* driver busy now? */
    bset #7,%a1@(5)
    jbeq IODONE_A4
    moveq #0,%d0
    movew %sp@+,%sr
    rts
IODONE_A4:              /* start the request at the head: Prime (read/write) with positioning, Control or Status */
    movew %sp@+,%sr
    moveal %a1@(8),%a0
IODONE_AA:              /* (csCode: Control 4, Status 5) */
    moveq #12,%d1
    cmpib #4,%a0@(7)
    jbeq IODONE_DE
    moveq #14,%d1
    cmpib #5,%a0@(7)
    jbeq IODONE_DE
    tstl %a0@(36)
    jbeq STASH_6
    movew %a0@(44),%d0
    movel %a0@(46),%d1
    roxrb #2,%d0
    jbpl IODONE_DC
    jbcc IODONE_D8
    addl %a1@(16),%d1
IODONE_D8:              /* (relative positioning) */
    movel %d1,%a1@(16)
IODONE_DC:              /* Prime */
    moveq #10,%d1

IODONE_DE:              /* call the driver routine d1 (through 0x6D4: VGODRIVER) */
    movel 0x6d4,%sp@-
    rts

/*
 VGODRIVER: call the driver routine at offset d1 of the header (8 Open, 10 Prime, 12
 Control, 14 Status, 16 Close); RAM drivers are locked (and loaded) first.
*/
trap_VGODRIVER:
VGODRIVER:
    movel %a1@,%d0
    jbne VGODRIVER_C
    moveq #-22,%d0
    movew %d0,%a0@(16)
    rts
VGODRIVER_C:            /* RAM driver: lock its DCE, load and lock its code */
    moveml %d3-%d7/%a1-%fp,%sp@-
    moveal %d0,%a2
    btst #6,%a1@(5)
    jbeq VGODRIVER_3E
    moveal %a0,%a3
    moveal %a1,%a0
    .short  0xA528	| 4080B674 _RecoverHandle (flags 0x0500)
    _HLock
    exg %a0,%a3
    tstl %a2@
    jbne VGODRIVER_32
    movel %a2,%sp@-
    _LoadResource
    movew ResErr,%d0
    jbne VGODRIVER_4A
VGODRIVER_32:           /* lock the code */
    exg %a0,%a2
    _HLock
    exg %a0,%a2
    movel %a2@,%d0
    _StripAddress
    moveal %d0,%a2
VGODRIVER_3E:           /* call the routine */
    movew %a2@(0x0,%d1:w),%d1
    moveq #0,%d0
    jsr %a2@(0x0,%d1:w)
    jbra VGODRIVER_4E
VGODRIVER_4A:           /* could not load: the error */
    movew %d0,%a0@(16)
VGODRIVER_4E:           /* return */
    extl %d0
    moveml %sp@+,%d3-%d7/%a1-%fp
    rts

VGODRIVER_56:           /* a1 = DCE of refnum d2 (unit table), a2 = its handle. Bad refnum: -21 to the caller */
    notw %d2
    jbmi VGODRIVER_78
    cmpw UnitTableEntryCount,%d2
    jbge VGODRIVER_78
    aslw #2,%d2
    moveal UTableBase,%a1
    movel %a1@(0x0,%d2:w),%d2
    jbeq VGODRIVER_78
    moveal %d2,%a2
    movel %a2@,%d2
    jbeq FETCH_40
    moveal %d2,%a1
    rts
VGODRIVER_78:           /* bad refnum: -21 (badUnitErr) */
    moveal %d5,%a0
    moveml %sp@+,%d0/%d3-%d5/%a2-%a4
    moveq #-21,%d0
    movew %d0,%a0@(16)
    rts

VGODRIVER_86:           /* slot driver open? (SlotDevParam with ioSlot / a slot SEBlock) Z set if so */
    moveml %d0,%sp@-
    moveal %d5,%a4
    btst #1,%a4@(6)
    beqw VGODRIVER_AA
    btst #0,%a4@(33)
    jbne VGODRIVER_A6
    tstw %a4@(34)
    beqw VGODRIVER_AA
VGODRIVER_A6:           /* yes */
    moveq #0,%d0
    jbra VGODRIVER_AC
VGODRIVER_AA:           /* no */
    moveq #-1,%d0
VGODRIVER_AC:           /* return */
    moveml %sp@+,%d0
    rts

VGODRIVER_B2:           /* slot parameter block for the open: name, slot, ID, ext device */
    moveal %d5,%a0
    movel %a0@(18),%a4@(16)
    movew %a0@(32),%d0
    btst #0,%d0
    jbeq VGODRIVER_E2
    movel %a0,%d0
    moveal %a0@(34),%a0
    movel %a0,%a4@(20)
    moveb %a0@,%a4@(49)
    moveb %a0@(1),%a4@(50)
    moveb %a0@(16),%a4@(51)
    moveal %d0,%a0
    jbra VGODRIVER_F2
VGODRIVER_E2:           /* (from ioSlot/ioID) */
    moveb %a0@(34),%a4@(49)
    moveb %a0@(35),%a4@(50)
    clrb %a4@(51)
VGODRIVER_F2:           /* return */
    rts

VGODRIVER_F4:           /* a file name: the File Manager's open (through OPENPATCH) */
    moveal %d5,%a0
    movew %a0@(6),%d1
    bigjmp OPENPATCH, a1
    nop	| 4080B75A
OPENPATCHRTN:           /* FILEOPEN */
    jmp %pc@(FILEOPEN)
OPENPATCHRTN1:          /* */
    moveq #-23,%d0
    braw OPEN_334_6

/*
 _Open: a file (FILEOPEN), or a driver (name starting with '.'): find it in the unit
 table, or load it ('DRVR' resource, or a slot driver from its card through the Slot
 Manager, the newer version of the two), install it (_DrvrInstall), and call its Open
 routine. Errors -23 (openErr), -29 (unit table full).
*/
trap_Open:
OPEN:
    moveml %d3-%d5/%a2-%a4,%sp@-
    movel %a0,%d5
    movew %d1,%a0@(6)
    movew %a0@(26),%d2
    moveal %a0@(18),%a0
    moveq #0,%d1
    moveb %a0@+,%d1
    cmpib #64,%d2
    jbeq OPEN_162
    cmpib #46,%a0@
    jbne VGODRIVER_F4
    jbsr VGODRIVER_86
    jbne OPEN_162
    subaw #56,%sp
    moveal %sp,%a4
    jbsr VGODRIVER_B2
    movew UnitTableEntryCount,%d2
    subiw #48,%d2
    moveq #-49,%d4
    moveal UTableBase,%a3
    moveq #48,%d0
    lsll #2,%d0
    addal %d0,%a3
OPEN_4A:                /* slot driver: find an open one for the same slot/ID */
    movel %a3@+,%d0
    jbeq OPEN_78
    moveal %d0,%a2
    movel %a2@,%d0
    jbne OPEN_58
    clrl %a3@-
    jbra OPEN_4A
OPEN_58:                /* same slot, ID, device? */
    moveal %d0,%a1
    moveb %a1@(40),%d0
    cmpb %a4@(49),%d0
    jbne OPEN_78
    moveb %a1@(41),%d0
    cmpb %a4@(50),%d0
    jbne OPEN_78
    moveb %a1@(50),%d0
    cmpb %a4@(51),%d0
    jbeq OPEN_80
OPEN_78:                /* next unit */
    subqw #1,%d4
    subqw #1,%d2
    jbgt OPEN_4A
    jbra OPEN_92
OPEN_80:                /* found: still loaded? */
    movel %a1@,%d0
    jbeq OPEN_8C
    moveal %d0,%a1
    movel %a1@,%d0
    jbne OPEN_15A
OPEN_8C:                /* (purged: free the DCE) */
    moveal %a2,%a0
    _DisposPtr
    clrl %a3@-
OPEN_92:                /* load it: 'DRVR' resource and the card's driver (Slot Manager 45), keep the newer */
    subqw #4,%sp
    movel #1146246738,%sp@-
    movel %a4@(16),%sp@-
    movew #-1,ROMMapInsert
    _GetNamedResource
    movel %sp@+,%d3
    moveal %a4,%a0
    moveq #45,%d0	/* _SlotManager 45: GETSLOTDRVR, sGetDriver */
    _SlotManager
    jbeq OPEN_B8
    tstl %d3
OPEN_B2:                /* (only the resource) */
    jbne OPEN_F6
    jbra OPEN_14A
OPEN_B8:                /* compare the versions */
    moveal %a0@,%a3
    moveal %a3@,%a1
    moveq #0,%d0
    moveb %a1@(18),%d0
    addqw #2,%d0
    bclr #0,%d0
    movew %a1@(0x12,%d0:w),%d0
    tstl %d3
    jbeq OPEN_F0
    moveal %d3,%a0
    moveal %a0@,%a0
    moveq #0,%d2
    moveb %a0@(18),%d2
    addqw #2,%d2
    bclr #0,%d2
    cmpw %a0@(0x12,%d2:w),%d0
    jbge OPEN_F0
    moveal %a3,%a0
    _DisposHandle
    movel %d3,%sp@-
    _DetachResource
    jbra OPEN_F6
OPEN_F0:                /* the card's */
    movel %d3,%sp@-
    _ReleaseResource
    movel %a3,%d3
OPEN_F6:                /* find a free unit for it (from 48 up), growing the table up to 128 */
    movel %d0,%sp@-
    movel %d3,%d0
    _StripAddress
    movel %d0,%d3
    movel %sp@+,%d0
    moveq #-49,%d4
    movew UnitTableEntryCount,%d2
    subiw #48,%d2
    moveal UTableBase,%a3
    moveq #48,%d0
    lsll #2,%d0
    addal %d0,%a3
OPEN_114:               /* next unit */
    tstl %a3@+
    beqw OPEN_152
    subqw #1,%d4
    subqw #1,%d2
    jbgt OPEN_114
    cmpiw #128,UnitTableEntryCount
    jbge OPEN_13A
    movew UnitTableEntryCount,%d0
    addqw #4,%d0
    cmpiw #128,%d0
    jbgt OPEN_13A
    movew %d0,UnitTableEntryCount
    jbra OPEN_152
OPEN_13A:               /* no room: -29 */
    moveal %d3,%a0
    _DisposHandle
    movew #-29,%d0
    addaw #56,%sp
    jbra OPEN_334
OPEN_14A:               /* no slot driver: as a file */
    addaw #56,%sp
    jbra VGODRIVER_F4
OPEN_152:               /* install */
    addaw #56,%sp
    jbra OPEN_1F8
OPEN_15A:               /* already open */
    addaw #56,%sp
    jbra OPEN_286
OPEN_162:               /* driver by name: search the unit table */
    moveal UTableBase,%a3
    movew UnitTableEntryCount,%d2
    moveq #-1,%d4
OPEN_16C:               /* next unit: same name? */
    movel %a3@+,%d0
    jbeq OPEN_1A0
    moveal %d0,%a2
    movel %a2@,%d0
    jbeq OPEN_1A0
    moveal %d0,%a1
    btst #6,%a1@(5)
    moveal %a1@,%a1
    jbeq OPEN_188
    movel %a1,%d0
    jbeq OPEN_1A0
    moveal %a1@,%a1
OPEN_188:               /* (compare) */
    movel %a1,%d0
    jbeq OPEN_1A0
    lea %a1@(18),%a1
    movel %d1,%d0
    swap %d0
    moveb %a1@+,%d0
    cmpb %d0,%d1
    jbne OPEN_1A0
    _CmpString
    jbeq OPEN_286
OPEN_1A0:               /* not open: GetNamedResource('DRVR', name) */
    subqw #1,%d4
    subqw #1,%d2
    jbgt OPEN_16C
    subqw #4,%sp
    movel #1146246738,%sp@-
    moveal %d5,%a0
    movel %a0@(18),%sp@-
    movew #-1,ROMMapInsert
    _GetNamedResource
    movel %sp@+,%d3
    jbne OPEN_1D4
    movew ResErr,%d0
    jbeq VGODRIVER_F4
    cmpiw #-192,%d0
    jbeq VGODRIVER_F4
    jbra OPEN_334
OPEN_1D4:               /* its ID = the unit */
    clrw %sp@-
    movel %sp,%d0
    movel %d3,%sp@-
    movel %d0,%sp@-
    clrl %sp@-
    clrl %sp@-
    movew #-1,ROMMapInsert
    _GetResInfo
    movew %sp@+,%d4
    notw %d4
    movew %d4,%d0
    jbsr DRVRINSTALL_3E
    jbmi OPEN_334
    jbne OPEN_20E
OPEN_1F8:               /* install it (_DrvrInstall, locked if the driver asks) */
    movew %d4,%d0
    moveal %d3,%a0
    moveal %a0@,%a0
    btst #6,%a0@
    jbeq OPEN_208
    .short  0xA43D	| 4080B96A _DrvrInstall (flags 0x0400)
    jbra OPEN_20A
OPEN_208:               /* (unlocked) */
    _DrvrInstall
OPEN_20A:               /* error? */
    jbne OPEN_334
OPEN_20E:               /* set up the DCE: driver, flags, delay, mask, menu */
    movew %d4,%d2
    jbsr VGODRIVER_56
    bset #5,%a1@(5)
    bnew OPEN_286
    moveq #64,%d0
    movel %d3,%a1@
    moveal %d3,%a0
    movel %a0@,%d0
    _StripAddress
    movel %d0,%d3
    movel ROMBase,%d0
    _StripAddress
    cmpl %d0,%d3
    jbcs OPEN_23A
    movel %d3,%a1@
    moveq #0,%d0
    jbra OPEN_23C
OPEN_23A:               /* ROM driver: pointer, not a handle */
    moveq #64,%d0
OPEN_23C:               /* copy the header fields */
    moveal %d3,%a0
    movew %a0@+,%a1@(4)
    moveb %d0,%a1@(5)
    movel %a0@+,%a1@(34)
    movew %a0@+,%a1@(38)
    jbsr VGODRIVER_86
    bnew OPEN_286
    subaw #56,%sp
    moveal %sp,%a4
    jbsr VGODRIVER_B2
    moveb %a4@(49),%a1@(40)
    moveb %a4@(50),%a1@(41)
    moveb %a4@(51),%a1@(50)
    clrl %a1@(42)
    moveal %a4,%a0
    moveq #27,%d0	/* _SlotManager 27: FINDDEVBASE, sFindDevBase */
    _SlotManager
    jbne OPEN_282
    movel %a0@,%a1@(42)
OPEN_282:               /* slot driver: slot, ID, device base */
    addaw #56,%sp
OPEN_286:               /* lock it, check the permission against the driver's capabilities */
    moveal %a2@,%a1
    btst #6,%a1@(4)
    jbeq OPEN_2A0
    moveal %a1@,%a0
    btst #6,%a1@(5)
    jbeq OPEN_29C
    _HLock
OPEN_29C:               /* (handle) */
    moveal %a2,%a0
    _HLock
OPEN_2A0:               /* permission allowed? */
    moveal %d5,%a0
    movew %d4,%a0@(24)
    moveq #-23,%d0
    moveb %a1@(4),%d1
    movew %d1,%d2
    orb %a0@(27),%d1
    eorb %d2,%d1
    andib #3,%d1
    bnew OPEN_334
    bset #5,%a1@(5)
    jbeq OPEN_2CE
    cmpib #64,%a0@(27)
    bnew OPEN_340
OPEN_2CE:               /* call Open */
    moveq #8,%d1
    jbsr IODONE_DE
    jbpl OPEN_2E4
    moveal %d5,%a0
    clrw %a0@(24)
    bclr #5,%a1@(5)
    jbra OPEN_314
OPEN_2E4:               /* opened: tell the Slot Manager (43) */
    nop
    jbsr VGODRIVER_86
    bnew OPEN_30C
    subaw #56,%sp
    moveal %sp,%a4
    jbsr VGODRIVER_B2
    movew %d4,%a4@(38)
    clrw %a4@(36)
    exg %a0,%a4
    moveq #43,%d0	/* _SlotManager 43: UPDATESRT, sUpdateSRT */
    _SlotManager
    exg %a4,%a0
    addaw #56,%sp
OPEN_30C:               /* unlock */
    btst #6,%a1@(4)
    jbne OPEN_334
OPEN_314:               /* (RAM driver) */
    moveal %a1@,%a0
    btst #6,%a1@(5)
    jbeq OPEN_334
    exg %d0,%d3
    _HUnlock
    exg %d0,%d3
    btst #6,%a1@(4)
    jbne OPEN_334
    moveal %a2,%a0
    exg %d0,%d3
    _HUnlock
    exg %d0,%d3

OPEN_334:               /* return the result */
    moveal %d5,%a0
    moveml %sp@+,%d3-%d5/%a2-%a4
OPEN_334_6:
    movew %d0,%a0@(16)
    rts

OPEN_340:               /* 0 */
    moveq #0,%d0
    jbra OPEN_334

/* _Close: a file (FILECLOSE) or a driver: call its Close through 0x6D8 (VWAITUNTIL). */
trap_Close:
CLOSE:
    movew %a0@(24),%d2
    jbmi CLOSE_A
    jmp %pc@(FILECLOSE)
CLOSE_A:                /* driver */
    moveml %d3-%d5/%a2-%a4,%sp@-
    movel %a0,%d5
    jbsr VGODRIVER_56
    btst #5,%a1@(5)
    jbeq OPEN_340
    movel 0x6d8,%sp@-
    rts

/*
 VWAITUNTIL: wait until the driver is idle, call its Close; if it does not refuse
 (-24), mark it closed and tell the Slot Manager.
*/
trap_VWAITUNTIL:
VWAITUNTIL:
    btst #7,%a1@(5)
    jbne trap_VWAITUNTIL
    moveq #16,%d1
    jbsr IODONE_DE
    cmpiw #-24,%d0
    jbeq OPEN_30C
    bclr #5,%a1@(5)
    tstb %a1@(40)
    jbeq VWAITUNTIL_4C
    subaw #56,%sp
    moveal %sp,%a4
    moveb %a1@(40),%a4@(49)
    moveb %a1@(41),%a4@(50)
    moveb %a1@(50),%a4@(51)
    clrw %a4@(38)
    clrw %a4@(36)
    exg %a0,%a4
    moveq #43,%d0	/* _SlotManager 43: UPDATESRT, sUpdateSRT */
    _SlotManager
    exg %a4,%a0
    addaw #56,%sp
VWAITUNTIL_4C:          /* unlock */
    jbra OPEN_314

/* _Read: a file (FILEREAD) or a driver: through IORWCS (Prime). */
trap_Read:
READ:
    jbsr READUPDATE
    nop
    movew %a0@(24),%d2
    jbmi READ_12
    jmp %pc@(FILEREAD)
READ_12:                /* driver */
    moveml %d3-%d5/%a2-%a4,%sp@-
    moveq #-19,%d0
    moveq #0,%d4
IORWCS:                 /* common to Read, Write, Control and Status: driver capable and open? asynchronous, immediate or synchronous */
    movel %a0,%d5
    jbsr VGODRIVER_56
    cmpib #3,%d1
    jbgt IORWCS_10
    clrl %a0@(40)
IORWCS_10:              /* (Read/Write: actual count 0) */
    movew #1,%a0@(16)
    movew %d1,%a0@(6)
    movew #2,%a0@(4)
    btst %d4,%a1@(4)
    moveml %sp@+,%d3-%d5/%a2-%a4
    jbeq VSYNCWAIT_8
    moveq #-28,%d0
    btst #5,%a1@(5)
    jbeq VSYNCWAIT_8
    btst #9,%d1
    jbne IODONE_AA
    btst #10,%d1
    jbne IODONE_84
    clrl %a0@(12)
    movel %a0,%sp@-
    jbsr IODONE_84
    moveal %sp@+,%a0
    movel 0x6dc,%sp@-
    rts

/* VSYNCWAIT: wait for a synchronous request to complete (ioResult no longer positive). */
trap_VSYNCWAIT:
VSYNCWAIT:
    movew %a0@(16),%d0
    jbgt trap_VSYNCWAIT
    extl %d0
VSYNCWAIT_8:            /* return the result */
    movew %d0,%a0@(16)
    rts

/* _Write: through WRITEUPDATE. */
trap_Write:
WRITE:
    jbra WRITEUPDATE
    .long   0x4E714E71	| 4080BBA0

WRITEUPDATERETURN:      /* driver write */
    moveml %d3-%d5/%a2-%a4,%sp@-
    moveq #-20,%d0
    moveq #1,%d4
    jbra IORWCS

/* _Control: driver Control. */
trap_Control:
CONTROL:
    moveml %d3-%d5/%a2-%a4,%sp@-
    movew %a0@(24),%d2
    moveq #-17,%d0
    moveq #2,%d4
    jbra IORWCS

/* _Status: driver Status (csCode 1: the DCE handle). */
trap_Status:
STATUS:
    moveml %d3-%d5/%a2-%a4,%sp@-
    movew %a0@(24),%d2
    movel %a0,%d5
    cmpiw #1,%a0@(26)
    jbeq STATUS_1A
    moveq #-18,%d0
    moveq #3,%d4
    jbra IORWCS
STATUS_1A:              /* csCode 1 */
    jbsr VGODRIVER_56
    movel %a2,%a0@(28)
    jbra OPEN_340

/*
 _KillIO: cancel all the driver's requests (Control csCode 1 first, then each one
 completed with -27 abortErr).
*/
trap_KillIO:
KILLIO:
    moveml %d3-%d5/%a2-%a4,%sp@-
    movew %a0@(24),%d2
    movel %a0,%d5
    jbsr VGODRIVER_56
    movew #1,%a0@(26)
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #12,%d1
    moveq #-17,%d0
    moveq #2,%d4
    btst %d4,%a1@(4)
    jbeq KILLIO_4E
    moveq #-28,%d0
    btst #5,%a1@(5)
    jbeq KILLIO_4E
    jbsr IODONE_DE
    jbne KILLIO_4E
KILLIO_36:              /* complete each pending request */
    tstl %a1@(8)
    jbeq KILLIO_48
    moveq #-27,%d0
    movew #9984,%d1
    jbsr IODONE_50
    jbra KILLIO_36
KILLIO_48:              /* not busy, 0 */
    jbsr IODONE_32
    moveq #0,%d0
KILLIO_4E:              /* return */
    movew %sp@+,%sr
    jbra OPEN_334

/*
 _DrvrInstall(d0 = refnum, a0 = driver): create the DCE (52 bytes, locked when
 asked) in the unit table.
*/
trap_DrvrInstall:
DRVRINSTALL:
    moveml %d3-%d5/%a2-%a4,%sp@-
    moveal %a0,%a3
    movel %d0,%d3
    jbsr DRVRINSTALL_3E
    jbmi DRVRINSTALL_38
    jbne DRVRINSTALL_1E
    btst #10,%d1
    jbeq DRVRINSTALL_18
    moveq #52,%d0
    .short  0xA440	| 4080BC4E _ResrvMem (flags 0x0400)
DRVRINSTALL_18:         /* allocate it */
    moveq #52,%d0
    .short  0xA522	| 4080BC52 _NewHandle (flags 0x0500)
    jbne DRVRINSTALL_38
DRVRINSTALL_1E:         /* clear it */
    moveq #51,%d0
    moveal %a0@,%a1
DRVRINSTALL_22:         /* clear loop */
    clrb %a1@+
    dbf %d0,DRVRINSTALL_22
    movel %a0,%a2@
    moveal %a0@,%a3
    bset #6,%a3@(5)
    movew %d3,%a3@(24)
DRVRINSTALL_36:         /* 0 */
    moveq #0,%d0
DRVRINSTALL_38:         /* return */
    moveml %sp@+,%d3-%d5/%a2-%a4
    rts

DRVRINSTALL_3E:         /* unit table entry of refnum d0 (a2). Out: d0 = the DCE handle, -21 if out of range */
    notw %d0
    jbmi DRVRINSTALL_5A
    cmpw UnitTableEntryCount,%d0
    jbge DRVRINSTALL_5A
    aslw #2,%d0
    moveal UTableBase,%a2
    addaw %d0,%a2
    moveal %a2@,%a0
    movel %a0,%d0
    _StripAddress
    tstl %d0
    rts
DRVRINSTALL_5A:         /* -21 */
    moveq #-21,%d0
    rts

/* _DrvrRemove: remove a closed driver (release its resource and DCE). Open: -25. */
trap_DrvrRemove:
DRVRREMOVE:
    moveml %d3-%d5/%a2-%a4,%sp@-
    jbsr DRVRINSTALL_3E
    jbmi DRVRINSTALL_38
    jbeq DRVRINSTALL_36
    moveal %a2,%a3
    moveal %d0,%a2
    moveal %a2@,%a1
    btst #5,%a1@(5)
    jbne DRVRREMOVE_2C
    btst #6,%a1@(5)
    jbeq DRVRREMOVE_24
    movel %a1@,%sp@-
    _ReleaseResource
DRVRREMOVE_24:          /* free the DCE */
    moveal %a2,%a0
    .short  0xA423	| 4080BCBC _DisposHandle (flags 0x0400)
    clrl %a3@
    jbra DRVRINSTALL_36
DRVRREMOVE_2C:          /* still open: -25 (dRemovErr) */
    moveq #-25,%d0
    jbra DRVRINSTALL_38

/* _AddDrive: add a drive queue element (d0 = drive number, refnum). */
trap_AddDrive:
ADDDRIVE:
    movel %d0,%a0@(6)
    lea DrvQHdr,%a1
    jsr %pc@(trap_Enqueue)
    moveq #0,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4080BCD6
