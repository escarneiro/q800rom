/*
 os/adbmgr.s - ADB Manager and keyboard
 From KBDMNGR (0x4080A360). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments in this file were inferred from the code (and from the ADB documentation in
 Inside Macintosh), not taken from Apple: they are educated guesses.

 ADB Manager globals (NewPtr'd, 440 bytes, pointer in low memory ADBBase), as used here:
   +0..191   device table, 16 entries of 12 bytes:
               +0 device type (handler ID)  +1 original ADB address
               +2 current ADB address (0 = free entry)
               +4 service routine           +8 data area
   +192..303 request queue, 8 entries of 14 bytes:
               +0 command byte  +1 unused  +2 buffer  +6 completion routine  +10 data area
   +304      routine that starts a bus transaction on this machine's ADB hardware
             (d3 command or -1 = auto-poll, d2 bytes to send, a2 data)
   +316      queue start        +320 queue end (+304)
   +324      queue head (next request to run)    +328 queue tail (next free slot)
   +332      device map: bit n set = a device answered at address n
   +334      working copy of the map while addresses are resolved
   +349      flags: bit 2 = queue empty, bit 5 = bus initialisation in progress
   +353      byte offset of the next free device table entry
   +354      address resolution passes left
   +355      command buffer used during initialisation: count, then up to 2 data bytes
             (Talk R3 replies land here: +356 R3 high byte, +357 handler ID)
   +365      free address a device is being moved to
   +367      address being examined
 Low memory used: 0x5F0 = OS trap table entry of _ADBOp (0x400 + 4 * 0x7C),
   0x6B8 = JADBProc, 0xDD8 = UnivInfoPtr (ProductInfo), 0xBA0 = IntlSpec.

*/

/*
 _CountADBs: number of devices in the device table (entries with a nonzero current
 address, at most 16). Out: d0.
*/
trap_CountADBs:
KBDMNGR:
COUNTADBS:
    moveq #16,%d1
    movew %d1,%d0
    moveal ADBBase,%a1
    addqw #2,%a1
    jbra KBDMNGR_10
KBDMNGR_C:              /* next device table entry */
    lea %a1@(12),%a1
KBDMNGR_10:             /* stop at the first free entry (current address 0) */
    tstb %a1@
    dbeq %d1,KBDMNGR_C
    subw %d1,%d0
    rts

/*
 _GetIndADB: information about the d0-th device (1..16). In: a0 = ADBDataBlock.
 Out: d0 = its ADB address (-1 if the index is out of range), the block filled with
 device type, original address, service routine and data area.
*/
trap_GetIndADB:
GETINDADB:
    tstw %d0
    jble ADBNOTFOUND
    cmpiw #16,%d0
    jbgt ADBNOTFOUND
    moveal ADBBase,%a1
    muluw #12,%d0
    lea %a1@(0xfffffffffffffff4,%d0:l),%a1
    moveq #0,%d0
    moveb %a1@(2),%d0
GETINDADB_1C:           /* copy the entry at a1 into the ADBDataBlock at a0 (shared with GetADBInfo) */
    moveb %a1@,%a0@+
    moveb %a1@(1),%a0@+
    movel %a1@(4),%a0@+
    movel %a1@(8),%a0@
    rts

/*
 _GetADBInfo: the same, by ADB address. In: d0 = address, a0 = ADBDataBlock.
 Out: d0 = 0, or -1 if no device has that address.
*/
trap_GetADBInfo:
GETADBINFO:
    jbsr FINDFDBINFO
    jbeq GETINDADB_1C
    rts

/*
 _SetADBInfo: set the service routine and data area of the device at address d0,
 from the 8 bytes at a0. Out: d0 = 0, or -1 if no device has that address.
*/
trap_SetADBInfo:
SETADBINFO:
    jbsr FINDFDBINFO
    jbne DONESET
    movel %a0@+,%a1@(4)
    movel %a0@,%a1@(8)
DONESET:                /* return */
    rts

/*
 FindFDBInfo: find the device table entry for ADB address d0.
 Out: a1 = entry, d0 = 0 and Z set if found, else d0 = -1 (a1 = first free entry).
*/
FINDFDBINFO:
    moveq #16,%d1
    moveal ADBBase,%a1
    jbra FIRSTFIND
FINDFDBLOOP:            /* next entry */
    lea %a1@(12),%a1
FIRSTFIND:              /* this address? stop at the first free entry or after 16 */
    cmpb %a1@(2),%d0
    jbeq DONEFIND
    tstb %a1@(2)
    dbeq %d1,FINDFDBLOOP
ADBNOTFOUND:            /* not found (also: GetIndADB index out of range) */
    moveq #-1,%d0
    rts
DONEFIND:               /* found */
    moveq #0,%d0
    rts

/*
 _ADBOp: queue an ADB command. In: d0 = command byte (address << 4 | command << 2 | reg),
 a0 -> {buffer, completion routine, data area}. If the queue was empty the command is
 started at once. Out: d0 = 0, or -1 if the queue (8 requests) is full.
*/
trap_ADBOp:
ADBOP:
    moveml %d3/%a2-%a3,%sp@-
    moveal ADBBase,%a3
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal %a3@(328),%a1
    btst #2,%a3@(349)
    jbne ADBOP_20
    cmpal %a3@(324),%a1
    jbeq ADBOP_4C
ADBOP_20:               /* store the request in the queue slot at the tail */
    moveb %d0,%a1@+
    addqw #1,%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    cmpal %a3@(320),%a1
    jbcs ADBOP_34
    moveal %a3@(316),%a1
ADBOP_34:               /* new tail (wrapped to the queue start) */
    movel %a1,%a3@(328)
    bclr #2,%a3@(349)
    jbeq ADBOP_42
    jbsr RUNADBREQUEST
ADBOP_42:               /* queued */
    moveq #0,%d0
ADBOP_44:               /* restore the interrupt level and return */
    movew %sp@+,%sr
    moveml %sp@+,%d3/%a2-%a3
    rts
ADBOP_4C:               /* queue full: tail caught up with head */
    moveq #-1,%d0
    jbra ADBOP_44

/*
 RunADBRequest: start the next bus transaction. With a request queued: d3 = its command,
 a2 = its data, d2 = number of bytes to send (the buffer's count byte, Listen only).
 With the queue empty: d3 = -1, d2 = 0, which makes the hardware routine resume
 auto-polling, except during bus initialisation (nothing to do then).
 Jumps to the hardware routine at globals +304.
*/
RUNADBREQUEST:
    btst #2,%a3@(349)
    jbeq RUNADBREQUEST_16
    moveq #0,%d2
    moveq #-1,%d3
    btst #5,%a3@(349)
    jbeq RUNADBREQUEST_2C
    rts
RUNADBREQUEST_16:       /* request at the queue head: command, buffer, count of bytes to send */
    moveal %a3@(324),%a0
    moveq #0,%d3
    moveb %a0@,%d3
    moveal %a0@(2),%a2
    moveq #12,%d2
    andb %d3,%d2
    subqb #8,%d2
    seq %d2
    andb %a2@+,%d2
RUNADBREQUEST_2C:       /* hand over to the machine-specific ADB hardware routine */
    moveal %a3@(304),%a0
    jmp %a0@

/*
 ExplicitRequestDone: called by the hardware layer when a queued command has completed
 (d3 = command, d2 = bytes received, a2 = received data). Removes the request from the
 queue and goes on in the common completion code below.
*/
EXPLICITREQUESTDONE:
    movel %sp,%sp@-
    movew %sr,%d1
    oriw #1792,%sr
    moveal %a3@(324),%a0
    lea %a0@(14),%a0
    moveal %a0,%a1
    cmpal %a3@(320),%a0
    jbcs EXPLICITREQUESTDONE_1C
    moveal %a3@(316),%a0
EXPLICITREQUESTDONE_1C:  /* advance the head, and mark the queue empty if it reached the tail */
    movel %a0,%a3@(324)
    cmpal %a3@(328),%a0
    jbne EXPLICITREQUESTDONE_2C
    bset #2,%a3@(349)
EXPLICITREQUESTDONE_2C:  /* push the request's data area and completion routine, a0 = its buffer */
    movel %a1@-,%sp@-
    movel %a1@-,%sp@-
    moveal %a1@-,%a0
    movew %d1,%sr
    jbra IMPLICITREQUESTDONE_20

/*
 ImplicitRequestDone: called by the hardware layer when auto-polling brought data from a
 device (d3 = command, its address in the high nibble, d2 = bytes, a2 = data). The data
 goes into a 12-byte buffer on the stack and the device's service routine is called.
 IMPLICITREQUESTDONE_20 onwards is shared with ExplicitRequestDone: copy the data to the
 buffer, start the next transaction, then call the completion/service routine with
 d0 = command, a0 = buffer (count byte + data), a2 = data area.
*/
IMPLICITREQUESTDONE:
    tstb %d2
    jbeq RUNADBREQUEST
    moveb %d3,%d0
    lsrb #4,%d0
    jbsr FINDFDBINFO
    jbne RUNADBREQUEST
    subaw #12,%sp
    moveal %sp,%a0
    pea %sp@(12)
    movel %a1@(8),%sp@-
    movel %a1@(4),%sp@-
IMPLICITREQUESTDONE_20:  /* common: copy the received bytes (count first) to the buffer, if any */
    movel %a0,%sp@-
    jbeq IMPLICITREQUESTDONE_30
    moveb %d2,%a0@+
    jbeq IMPLICITREQUESTDONE_30
    subqw #1,%d2
IMPLICITREQUESTDONE_2A:  /* copy loop */
    moveb %a2@+,%a0@+
    dbf %d2,IMPLICITREQUESTDONE_2A
IMPLICITREQUESTDONE_30:  /* start the next transaction before calling the routine, then pop d0/a0-a2 */
    movel %d3,%sp@-
    jbsr RUNADBREQUEST
    moveml %sp@+,%d0/%a0-%a2
    btst #0,0xdd5
    jbeq IMPLICITREQUESTDONE_4A
    movel %d0,%d1
    moveq #1,%d0
    _PowerDispatch
    movel %d1,%d0
IMPLICITREQUESTDONE_4A:  /* Power Manager present (0xDD5 bit 0): _PowerDispatch 1, as for events (user activity, probably) */
    movel %a1,%d1
    jbeq IMPLICITREQUESTDONE_76
    btst #5,%a3@(349)
    jbne IMPLICITREQUESTDONE_72
    moveal 0xdd8,%a1
    addal %a1@(56),%a1
    movel %a1@(20),%d2
    jbeq IMPLICITREQUESTDONE_72
    moveml %d0-%d1/%a0/%a2,%sp@-
    addal %d2,%a1
    jsr %a1@
    moveml %sp@+,%d0-%d1/%a0/%a2
    jbeq IMPLICITREQUESTDONE_76
IMPLICITREQUESTDONE_72:  /* call the completion / service routine */
    moveal %d1,%a1
    jsr %a1@
IMPLICITREQUESTDONE_76:  /* restore the stack saved on entry */
    moveal %sp@,%sp
    rts
    .fill   0x244, 1, 0x00

/*
 _ADBReInit: reset and re-initialise the bus. Calls JADBProc with d0 = 0 before and
 d0 = 1 after, rebuilds the device table and runs the 'ADBS' device drivers again.
*/
trap_ADBReInit:
ADBREINIT:
    moveal 0x6b8,%a0
    moveq #0,%d0
    jsr %a0@
    moveml %d0-%d4/%a0-%a3,%sp@-
    moveal ADBBase,%a3
ADBREINIT_10:           /* reset the bus and rebuild the device table, then load the ADBS drivers */
    jbsr INITADB_36
    jbsr INITADBDRVR
    moveml %sp@+,%d0-%d4/%a0-%a3
    moveal 0x6b8,%a0
    moveq #1,%d0
    jsr %a0@
    rts

/*
 Default JADBProc routine (d0 = 0 before ADBReInit, 1 after). Before: through
 ADBPROCPATCH (which re-initialises the cursor devices and returns the device count),
 frees the data area of every keyboard (original address 2), the KCHR/KMAP block
 allocated by RSETKMAP_28C. After: ADBPROCPATCH returns from here directly.
*/
trap_VADBProc:
ADBPROC:
    jbsr ADBPROCPATCH
    movew %d0,%d2
    jbeq ADBPROC_38
    linkw %fp,#-12
    moveq #2,%d1
ADBPROC_10:             /* for each device, from the last: a keyboard (original address 2)? */
    lea %fp@(-12),%a0
    movew %d2,%d0
    _GetIndADB
    jbmi ADBPROC_32
    cmpb %fp@(-11),%d1
    jbne ADBPROC_32
    moveal %fp@(-6),%a1
    clrl %fp@(-6)
    lea %fp@(-10),%a0
    _SetADBInfo
    moveal %a1,%a0
    _DisposPtr
ADBPROC_32:             /* next device */
    subqw #1,%d2
    jbgt ADBPROC_10
    unlk %fp
ADBPROC_38:             /* return */
    rts

/*
 InitADBDrvr: for each device, load resource 'ADBS' with ID = its original address
 (an ADB device driver, from the System file), detach it and call it with
 d0 = the device's ADB address, d1 = its device type.
*/
INITADBDRVR:
    _CountADBs
    movew %d0,%d3
    jbeq INITADBDRVR_50
    moveq #1,%d4
    linkw %fp,#-12
INITADBDRVR_C:          /* next device: GetResource('ADBS', original address) */
    lea %fp@(-12),%a0
    movew %d4,%d0
    _GetIndADB
    moveb %d0,%fp@(-2)
    jbmi INITADBDRVR_48
    subql #4,%sp
    movel #1094992467,%sp@-
    clrw %sp@-
    moveb %fp@(-11),%sp@(1)
    _GetResource
    movel %sp@,%d1
    jbne INITADBDRVR_34
    addqw #4,%sp
    jbra INITADBDRVR_48
INITADBDRVR_34:         /* found: detach it and call it */
    _DetachResource
    moveal %d1,%a0
    movel %a0@,%d0
    _StripAddress
    moveal %d0,%a0
    moveb %fp@(-2),%d0
    moveb %fp@(-12),%d1
    jsr %a0@
INITADBDRVR_48:         /* next index, up to the device count */
    addqw #1,%d4
    cmpw %d4,%d3
    jbge INITADBDRVR_C
    unlk %fp
INITADBDRVR_50:         /* return */
    rts

/*
 InitADB: start the ADB Manager at boot. Allocates the globals (system heap, cleared),
 sets JADBProc, resets the keyboard state, sets JKybdTask to a no-op, calls the
 machine's ADB hardware initialisation (from the ProductInfo table at +56, which also
 sets the hardware routine at globals +304), then falls into INITADB_36.
*/
INITADB:
    movel #440,%d0
    .short  0xA71E	| 4080A808 _NewPtr (flags 0x0700)
    moveal %a0,%a3
    movel %a3,ADBBase
    lea %pc@(trap_VADBProc),%a0
    movel %a0,0x6b8
    clrb KbdType
    jbsr RSETKMAP
    lea %pc@(INITADB_280),%a0
    movel %a0,JKybdTask
    moveal 0xdd8,%a0
    addal %a0@(56),%a0
    movel %a0@,%d0
    jbeq INITADB_36
    addal %d0,%a0
    jsr %a0@

/*
 Reset the bus and build the device table (also used by ADBReInit). Clears the device
 table and the queue, marks the queue empty and initialisation in progress, starts the
 initialisation sequence (INITADB_EE) and waits, with interrupts enabled, until it has
 finished. Then makes sure there is a keyboard entry, loads the keyboard layouts and
 flushes the keyboards.
*/
INITADB_36:
    oriw #1792,%sr
    moveq #75,%d0
    moveal %a3,%a0
INITADB_3E:             /* clear globals +0..303 (device table and queue) */
    clrl %a0@+
    dbf %d0,INITADB_3E
    moveb #36,%a3@(349)
    clrb %a3@(350)
    lea %a3@(192),%a0
    movel %a0,%a3@(316)
    movel %a0,%a3@(324)
    movel %a0,%a3@(328)
    lea %a3@(304),%a0
    movel %a0,%a3@(320)
    jbsr INITADB_EE
    andiw #-1793,%sr
INITADB_6E:             /* wait for the initialisation sequence to finish (bit 5 cleared) */
    btst #5,%a3@(349)
    jbne INITADB_6E
    jbsr RSETKMAP_12
    jbsr RSETKMAP_28C
    jbra RSETKMAP_44
    .fill   0x6C, 1, 0x00

/*
 Bus initialisation, run as a chain of ADB completions: each command helper below queues
 its command with its own caller's return address as the completion routine, and returns
 to the caller's caller, so the code after each "jbsr" runs when that command has
 completed (at interrupt level, registers not preserved: state is kept in the globals).
 1. SendReset. 2. Talk R3 at every address 0..15 to find the devices.
 3. Address resolution (INITADB_178). 4. INITADB_156.
*/
INITADB_EE:
    jbsr INITADB_218
    clrb %a3@(353)
    clrw %a3@(332)
    moveq #0,%d0
INITADB_FC:             /* Talk R3 to address d0 (continues after the reply) */
    moveb %d0,%a3@(367)
    jbsr INITADB_220
    moveb %a3@(367),%d0
    tstb %a0@+
    jbeq INITADB_140
    moveq #0,%d1
    moveb %a3@(353),%d1
    moveb %a0@(1),%a3@(0x0,%d1:w)
    moveb %d0,%a3@(0x1,%d1:w)
    moveb %d0,%a3@(0x2,%d1:w)
    cmpib #2,%d0
    jbne INITADB_12E
    lea %pc@(KEYTAB),%a0
    movel %a0,%a3@(0x4,%d1:w)
INITADB_12E:            /* device found: entry with handler ID, address, KEYTAB for a keyboard, mark it in the map */
    addib #12,%d1
    moveb %d1,%a3@(353)
    movew %a3@(332),%d2
    bset %d0,%d2
    movew %d2,%a3@(332)
INITADB_140:            /* next address */
    addqb #1,%d0
    cmpib #16,%d0
    jbne INITADB_FC
    moveb #51,%a3@(354)
    movew %a3@(332),%a3@(334)
    jbne INITADB_178
INITADB_156:            /* initialisation done: clear bit 5 and start the queue / auto-polling */
    bclr #5,%a3@(349)
    jsr %pc@(RUNADBREQUEST)
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4080A964
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4080A970
INITADB_178:            /* address resolution: start a pass over the addresses (51 passes in all) */
    st %a3@(367)
    subqb #1,%a3@(354)
    jbeq INITADB_156
INITADB_182:            /* next occupied address: move its device to the highest free address */
    addqb #1,%a3@(367)
    jbsr INITADB_24C
    jbmi INITADB_178
    jbsr INITADB_26E
    jbmi INITADB_156
    moveb %d0,%a3@(365)
    moveb %d0,%d1
    moveb %a3@(367),%d0
    jbsr INITADB_226
    moveb %a3@(367),%d0
    jbsr INITADB_220
    tstb %a0@
    jbeq INITADB_1B4
    jbsr INITADB_1D2
    moveb %a3@(357),%a3@(0x0,%d1:w)
    jbra INITADB_182
INITADB_1B4:            /* nothing left at the old address: one device, move it back from the free address */
    moveb %a3@(367),%d1
    moveb %a3@(365),%d0
    jbsr INITADB_226
    moveb %a3@(365),%d0
    jbsr INITADB_220
    tstb %a0@
    jbeq INITADB_1D0
    jbsr INITADB_1D2
    moveb %a3@(357),%a3@(0xfffffffffffffff4,%d2:w)
INITADB_1D0:            /* a device stayed at the free address: there were two, keep it there as a new entry */
    jbra INITADB_182

/*
 A second device was found behind the address at +367: mark the free address (+365)
 used and add a device table entry for it, copied from the entry of the old address
 (same type, original address and service routine), with the free address as its
 current address. Out: d1 = old entry, d2 = new entry + 12.
*/
INITADB_1D2:
    moveq #0,%d0
    moveq #0,%d1
    moveb %a3@(365),%d0
    movew %a3@(334),%d1
    bset %d0,%d1
    movew %d1,%a3@(334)
    moveq #0,%d1
    moveb %a3@(367),%d0
INITADB_1EA:            /* find the entry whose current address is the old one */
    cmpb %a3@(0x2,%d1:w),%d0
    jbeq INITADB_1F6
    addiw #12,%d1
    jbra INITADB_1EA
INITADB_1F6:            /* copy it into the next free entry, with the new address */
    moveq #0,%d2
    moveb %a3@(353),%d2
    movel %a3@(0x0,%d1:w),%a3@(0x0,%d2:w)
    movel %a3@(0x4,%d1:w),%a3@(0x4,%d2:w)
    moveb %a3@(365),%a3@(0x2,%d2:w)
    addiw #12,%d2
    moveb %d2,%a3@(353)
    rts

/*
 Command helpers for the initialisation chain (see INITADB_EE): set up the command and
 queue it through _ADBOp's trap table entry, with globals +355 as the buffer and the
 caller's return address as the completion routine.
 INITADB_218: SendReset.
*/
INITADB_218:
    moveq #0,%d0
    moveq #0,%d1
    moveq #0,%d2
    jbra INITADB_234

INITADB_220:            /* Talk R3 to address d0 (reply: device address/flags and handler ID) */
    moveq #15,%d1
    moveq #0,%d2
    jbra INITADB_234

INITADB_226:            /* Listen R3 to address d0: move the device to address d1 (handler 0xFE: only if no collision) */
    moveb %d1,%a3@(356)
    moveb #0xfe,%a3@(357)
    moveq #11,%d1
    moveq #2,%d2
INITADB_234:            /* common: command = d0 << 4 | d1, send count d2, queue it, return to the caller's caller */
    lslb #4,%d0
    orb %d1,%d0
    moveb %d2,%a3@(355)
    pea %a3@(355)
    moveal %sp,%a0
    moveal 0x5f0,%a1
    jsr %a1@
    addqw #8,%sp
    rts

/*
 Next occupied address in the working map, from the one at +367 up. Out: d0 = it
 (also stored at +367), or -1 and N set if none.
*/
INITADB_24C:
    moveq #0,%d0
    moveq #0,%d1
    moveb %a3@(367),%d0
    movew %a3@(334),%d1
INITADB_258:            /* loop: btst */
    btst %d0,%d1
    jbne INITADB_268
    addqw #1,%d0
    cmpiw #16,%d0
    jblt INITADB_258
    moveq #-1,%d0
    rts
INITADB_268:            /* set %a3@(367) */
    moveb %d0,%a3@(367)
    rts

/* Highest free address in the working map. Out: d0 = it, or -1 (N set) if all are used. */
INITADB_26E:
    moveq #0,%d1
    moveq #15,%d0
    movew %a3@(334),%d1
INITADB_276:            /* loop: btst */
    btst %d0,%d1
    dbeq %d0,INITADB_276
    tstw %d0
    rts
INITADB_280:            /* rts: the no-op JKybdTask installed by InitADB */
    rts	| 4080AA82

/* RsetKMap: clear the keyboard state: KeyMap (and the 2 bytes after it) and KbdVers. */
RSETKMAP:
    lea KeyMap,%a0
    moveq #8,%d0
RSETKMAP_6:             /* loop: clr */
    clrw %a0@+
    dbf %d0,RSETKMAP_6
    clrw KbdVers
    rts

/*
 If no device answered at address 2, add a keyboard entry anyway (type 1, address 2,
 service routine KEYTAB) and mark address 2 in the map. Then re-initialise the cursor
 devices (CRSRDEVREINIT, d0 = 1).
*/
RSETKMAP_12:
    moveq #2,%d0
    jbsr FINDFDBINFO
    tstb %d0
    jbeq RSETKMAP_3A
    moveb #1,%a1@
    moveb #2,%a1@(1)
    moveb #2,%a1@(2)
    lea %pc@(KEYTAB),%a0
    movel %a0,%a1@(4)
    bset #2,%a3@(335)
RSETKMAP_3A:            /* set %d0 */
    moveq #1,%d0
    jbsr CRSRDEVREINIT
    rts

/* Send Flush to every keyboard (original address 2), then wait 8 ticks. */
RSETKMAP_44:
    moveml %d0-%d1/%a0,%sp@-
    subaw #10,%sp
    moveq #0,%d1
RSETKMAP_4E:            /* next device */
    addql #1,%d1
    moveal %sp,%a0
    moveb %d1,%d0
    _GetIndADB
    tstb %d0
    jble RSETKMAP_66
    cmpib #2,%a0@(1)
    jbne RSETKMAP_4E
    jbsr RSETKMAP_76
    jbra RSETKMAP_4E
RSETKMAP_66:            /* no more devices: _Delay 8 ticks */
    moveaw #8,%a0
    _Delay
    addaw #10,%sp
    moveml %sp@+,%d0-%d1/%a0
    rts

/*
 Send Flush to ADB address d0 and wait for it to complete: a request block on the stack,
 completion routine RSETKMAP_B8 sets a flag word that this routine polls.
*/
RSETKMAP_76:
    moveml %d0-%d1/%a0,%sp@-
    moveb %d0,%d1
RSETKMAP_7C:            /* from here: subaw #14,%sp */
    subaw #14,%sp
RSETKMAP_80:            /* queue Flush (address << 4 | 1), again while the queue is full */
    moveb %d1,%d0
    aslb #4,%d0
    orib #1,%d0
    clrl %sp@
    lea %pc@(RSETKMAP_B8),%a0
    movel %a0,%sp@(4)
    lea %sp@(12),%a0
    movel %a0,%sp@(8)
    clrw %sp@(12)
    moveal %sp,%a0
    _ADBOp
    tstb %d0
    jbmi RSETKMAP_80
    moveal %sp@(8),%a0
RSETKMAP_AA:            /* wait for the completion flag */
    tstw %a0@
    jbeq RSETKMAP_AA
    addaw #14,%sp
    moveml %sp@+,%d0-%d1/%a0
    rts
RSETKMAP_B8:            /* completion routine: set the flag word (data area) */
    movew #1,%a2@
    rts
    .short  0x0000, 0x0000	| 4080AB42

/*
 KEYTAB: the default keyboard service routine (installed in the device table entry of
 every keyboard). Called with the reply to an auto-poll Talk R0: d0 = command (ADB
 address in the high nibble), a0 = buffer (count, key byte 1, key byte 2), a2 = the
 keyboard's data area (allocated by RSETKMAP_28C):
   +0  KMAP          +4..19 this keyboard's own KeyMap (16 bytes)
   +20 KCHR          +24 KeyTranslate dead-key state       +28 nonzero: no KMAP commands
   +29 number of command slots (2), then the slots, 10 bytes each:
       flag byte (nonzero = in use, bit 7 = OR, else AND NOT), count + 8 data bytes
 Each key byte (bit 7 = key up, 0x7F: raw key code, 0xFF = none) is turned into a virtual
 key code with the KMAP, recorded in KeyMap, translated with the KCHR and posted as a
 keyDown or keyUp event. KMAP exceptions can also send an ADB command to the keyboard
 (to switch the Caps Lock LED, for instance).
*/
KEYTAB:                 /* no data area: ignore. d0 = the ADB address, a1 = the buffer */
    movel %a2,%d3	| 4080AB46
    jbeq KEYTAB_E4	| 4080AB48
    moveal %a0,%a1	| 4080AB4C
    lsrw #4,%d0	| 4080AB4E
    moveq #15,%d1	| 4080AB50
    andl %d1,%d0	| 4080AB52
    movel %d0,%d3	| 4080AB54
    lea %sp@(-10),%sp	| 4080AB56
    moveal %sp,%a0	| 4080AB5A
    _GetADBInfo	| 4080AB5C
    rorl #8,%d3	| 4080AB5E
    movew %sp@+,%d3	| 4080AB60
    addql #8,%sp	| 4080AB62
    swap %d3	| 4080AB64
    moveb %a1@(1),%d0	| 4080AB66
    moveb %a1@(2),%sp@-	| 4080AB6A
    jbsr KEYTAB_2C	| 4080AB6E
    moveb %sp@+,%d0	| 4080AB70
KEYTAB_2C:              /* process the key byte in d0: key byte 1 by this bsr, key byte 2 falling through */
    cmpib #0xff,%d0	| 4080AB72 4080AB72 cmpib #-1,%d0: no key (0xFF)?
    jbeq KEYTAB_E4	| 4080AB76
    clrw KeyLast	| 4080AB7A
    clrw KbdVers	| 4080AB7E
    moveq #127,%d1	| 4080AB82
    andb %d0,%d1	| 4080AB84
    moveal %a2@,%a1	| 4080AB86
    moveb %a1@(4,%d1:w),%d3	| 4080AB88
    jbpl KEYTAB_68	| 4080AB8C
    bclr #7,%d3	| 4080AB8E
    lea %a1@(132),%a0	| 4080AB92
    movew %a0@+,%d2	| 4080AB96
    jbeq KEYTAB_68	| 4080AB98
    subqw #1,%d2	| 4080AB9A
KEYTAB_56:              /* the key has KMAP exceptions: look for its entry (key, op, Pascal string) */
    cmpb %a0@+,%d0	| 4080AB9C
    jbeq KEYTAB_F2	| 4080AB9E
    moveb %a0@(1),%d1	| 4080ABA2
    lea %a0@(2,%d1:w),%a0	| 4080ABA6
    dbf %d2,KEYTAB_56	| 4080ABAA
KEYTAB_68:              /* set or clear the key in the keyboard's KeyMap (d3 bit 7 = key up) */
    moveq #0,%d2	| 4080ABAE
    moveb %d3,%d2	| 4080ABB0
    lsrw #3,%d2	| 4080ABB2
    tstb %d0	| 4080ABB4
    jbmi KEYTAB_78	| 4080ABB6
    bset %d3,%a2@(4,%d2:w)	| 4080ABB8
    jbra KEYTAB_80	| 4080ABBC
KEYTAB_78:              /* key up */
    bclr %d3,%a2@(4,%d2:w)	| 4080ABBE
    bset #7,%d3	| 4080ABC2
KEYTAB_80:              /* copy it to KeyMap, set KbdLast and KbdType, KeyTranslate with the modifiers */
    moveml %a2@(4),%d0-%d2/%a0	| 4080ABC6
    moveml %d0-%d2/%a0,KeyMap	| 4080ABCC
    movel %d3,%d0	| 4080ABD2
    lsrl #8,%d0	| 4080ABD4
    moveb %d0,KbdLast	| 4080ABD6
    swap %d0	| 4080ABDA
    moveb %d0,KbdType	| 4080ABDC
    movew %a2@(10),%d0	| 4080ABE0
    rolw #1,%d0	| 4080ABE4
    subql #4,%sp	| 4080ABE6
    movel %a2@(20),%sp@-	| 4080ABE8
    movew %d3,%sp@-	| 4080ABEC
    moveb %d0,%sp@	| 4080ABEE
    pea %a2@(24)	| 4080ABF0
    .short  0xA9C3	| 4080ABF4 4080ABF4 _KeyTranslate (no macro)
    movew %sp@+,%d0	| 4080ABF6
    jbeq KEYTAB_B6	| 4080ABF8
    jbsr KEYTAB_BA	| 4080ABFA
KEYTAB_B6:              /* post an event for each nonzero character returned (high word, then low) */
    movew %sp@+,%d0	| 4080ABFC
    jbeq KEYTAB_E4	| 4080ABFE
KEYTAB_BA:              /* post one event: message = char, key code, ADB address and keyboard type */
    rorw #8,%d0	| 4080AC00
    swap %d0	| 4080AC02
    movew %d3,%d0	| 4080AC04
    roll #8,%d0	| 4080AC06
    tstb %d3	| 4080AC08
    jbmi KEYTAB_E6	| 4080AC0A
    movel Ticks,%d1	| 4080AC0C
    movel %d1,KeyTime	| 4080AC10
    movel %d1,KeyRepTime	| 4080AC14
    movew %d0,KeyLast	| 4080AC18
    swap %d0	| 4080AC1C
    movew %d0,KbdVers	| 4080AC1E
    swap %d0	| 4080AC22
    moveaw #3,%a0	| 4080AC24
    _PostEvent	| 4080AC28
KEYTAB_E4:              /* return */
    rts	| 4080AC2A
KEYTAB_E6:              /* key up: _PostEvent(keyUp) */
    moveaw #4,%a0	| 4080AC2C
    bclr #15,%d0	| 4080AC30
    _PostEvent	| 4080AC34
    rts	| 4080AC36
KEYTAB_F2:              /* KMAP exception: op bit 7 = XOR (the key toggles: up/down from its KeyMap bit) */
    moveb %a0@+,%d1	| 4080AC38
    jbpl KEYTAB_102	| 4080AC3A
    moveq #0,%d2	| 4080AC3C
    moveb %d3,%d2	| 4080AC3E
    lsrw #3,%d2	| 4080AC40
    btst %d3,%a2@(4,%d2:w)	| 4080AC42
    seq %d0	| 4080AC46
KEYTAB_102:             /* op low nibble = ADB command to send (0: key ignored). +28 set: treat as normal */
    moveq #15,%d2	| 4080AC48
    andb %d1,%d2	| 4080AC4A
    jbeq KEYTAB_E4	| 4080AC4C
    tstb %a2@(28)	| 4080AC4E
    jbne KEYTAB_68	| 4080AC52
    moveml %d0/%a1,%sp@-	| 4080AC56
    movel %a0,%sp@-	| 4080AC5A
    cmpib #12,%d2	| 4080AC5C
    jbge KEYTAB_122	| 4080AC60
    pea %pc@(KEYTAB_1C4)	| 4080AC62
    jbra KEYTAB_126	| 4080AC66
KEYTAB_122:             /* Talk (12..15): read, modify, write back. Else: send it as it is */
    pea %pc@(KEYTAB_17C)	| 4080AC68
KEYTAB_126:             /* find a free command slot (none: just process the key) */
    lea %a2@(29),%a1	| 4080AC6C
    moveb %a1@+,%d1	| 4080AC70
    jbeq KEYTAB_16A	| 4080AC72
    subqw #1,%d1	| 4080AC74
KEYTAB_130:             /* loop: tst */
    tstb %a1@+	| 4080AC76
    jbeq KEYTAB_13E	| 4080AC78
    lea %a1@(9),%a1	| 4080AC7A
    dbf %d1,KEYTAB_130	| 4080AC7E
    jbra KEYTAB_16A	| 4080AC82
KEYTAB_13E:             /* take the slot, copy the exception's string (at most 8 bytes) as the data */
    moveb %d0,%a1@(-1)	| 4080AC84
    bset #1,%a1@(-1)	| 4080AC88
    movel %a1,%sp@-	| 4080AC8E
    moveb %a0@,%d1	| 4080AC90
    cmpib #8,%d1	| 4080AC92
    jbls KEYTAB_154	| 4080AC96
    moveq #8,%d1	| 4080AC98
KEYTAB_154:             /* loop: move */
    moveb %a0@+,%a1@+	| 4080AC9A
    dbf %d1,KEYTAB_154	| 4080AC9C
    movew %d3,%d0	| 4080ACA0
    clrb %d0	| 4080ACA2
    lsrw #4,%d0	| 4080ACA4
    orb %d2,%d0	| 4080ACA6
    moveal %sp,%a0	| 4080ACA8
    _ADBOp	| 4080ACAA
    jbne KEYTAB_174	| 4080ACAC
    addql #4,%sp	| 4080ACAE
KEYTAB_16A:             /* then process the key as usual */
    addql #8,%sp	| 4080ACB0
    moveml %sp@+,%d0/%a1	| 4080ACB2
    jbra KEYTAB_68	| 4080ACB6
KEYTAB_174:             /* queue full: free the slot */
    moveal %sp@+,%a1	| 4080ACBA
    clrb %a1@(-1)	| 4080ACBC
    jbra KEYTAB_16A	| 4080ACC0
KEYTAB_17C:             /* completion of the Talk: OR (or AND NOT) the string's bytes into the reply */
    moveal %a0,%a1	| 4080ACC2
    moveq #0,%d1	| 4080ACC4
    moveb %a1@+,%d1	| 4080ACC6
    moveb %a2@+,%d2	| 4080ACC8
    cmpb %d2,%d1	| 4080ACCA
    jbls KEYTAB_18A	| 4080ACCC
    moveb %d2,%d1	| 4080ACCE
KEYTAB_18A:             /* test %a0@(-1) */
    tstb %a0@(-1)	| 4080ACD0
    jbpl KEYTAB_1A2	| 4080ACD4
    jbra KEYTAB_196	| 4080ACD6
KEYTAB_192:             /* OR loop */
    moveb %a2@+,%d2	| 4080ACD8
    orb %d2,%a1@+	| 4080ACDA
KEYTAB_196:             /* count down */
    dbf %d1,KEYTAB_192	| 4080ACDC
    jbra KEYTAB_1A6	| 4080ACE0
KEYTAB_19C:             /* AND NOT loop */
    moveb %a2@+,%d2	| 4080ACE2
    notb %d2	| 4080ACE4
    andb %d2,%a1@+	| 4080ACE6
KEYTAB_1A2:             /* count down */
    dbf %d1,KEYTAB_19C	| 4080ACE8
KEYTAB_1A6:             /* and send it back with Listen (same register), completion KEYTAB_1C4 */
    clrl %sp@-	| 4080ACEC
    pea %pc@(KEYTAB_1C4)	| 4080ACEE
    movel %a0,%sp@-	| 4080ACF2
    moveal %sp,%a0	| 4080ACF4
    bclr #2,%d0	| 4080ACF6
    _ADBOp	| 4080ACFA
    jbne KEYTAB_1BE	| 4080ACFC
    moveal %sp@,%a0	| 4080ACFE
    clrb %a0@(-1)	| 4080AD00
KEYTAB_1BE:             /* address %sp@(12) */
    lea %sp@(12),%sp	| 4080AD04
    rts	| 4080AD08
KEYTAB_1C4:             /* completion: free the command slot */
    clrb %a0@(-1)	| 4080AD0A
    rts	| 4080AD0E

/*
 For each keyboard (original address 2): allocate its 50-byte data block, get KMAP 0
 and KCHR 0 from the ROM resources, store their pointers in it (+0 KMAP, +20 KCHR) and
 make it the device's data area. KbdType and KbdLast are set from the last keyboard.
*/
RSETKMAP_28C:
    moveq #16,%d1
    moveal ADBBase,%a1
    jbra RSETKMAP_298
RSETKMAP_294:           /* next entry */
    lea %a1@(12),%a1
RSETKMAP_298:           /* a keyboard? */
    moveq #2,%d0
    cmpb %a1@(1),%d0
    jbne RSETKMAP_2F0
    moveq #50,%d0
    .short  0xA71E	| 4080AD26 _NewPtr (flags 0x0700)
    moveal %a0,%a2
    moveb #2,%a2@(29)
    subql #4,%sp
    movel #1262700626,%sp@-
    clrw %sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@+,%d0
    jbeq RSETKMAP_2F0
    moveal %d0,%a0
    movel %a0@,%a2@(20)
    subql #4,%sp
    movel #1263354192,%sp@-
    clrw %sp@-
    movew #-1,ROMMapInsert
    _GetResource
    movel %sp@+,%d0
    jbeq RSETKMAP_2F0
    moveal %d0,%a0
    movel %a0@,%a2@
    movel %a2,%a1@(8)
    moveb %a1@,KbdType
    moveb %a1@(2),KbdLast
RSETKMAP_2F0:           /* count down */
    dbf %d1,RSETKMAP_294
    rts

/*
 _KeyTranslate (KeyTrans): KeyTranslate(transData, keycode, VAR state): LONGINT.
 First, if the Script Manager has an 'itlk' remapping table (IntlSpec, +374), the
 keycode word (modifiers + key) is remapped: entries of keyboard type and keycode
 match value, a mask, and a replacement.
 Then the 'KCHR' translation: the modifier byte selects a table (KCHR +2), the key code
 selects the character (tables at +260, 128 bytes each), dead keys handled through
 the dead-key records after the tables and the state variable. Result: up to two
 character codes, in the low and high word.
*/
trap_KeyTrans:
KEYTRANS:
    moveal IntlSpec,%a0
    cmpaw #-1,%a0
    jbeq KEYTRANS_52
    movel %a0@(374),%d0
    jbeq KEYTRANS_52
    linkw %fp,#0
    moveml %d3-%d5,%sp@-
    moveal %d0,%a0
    moveal %a0@,%a0
    moveq #0,%d4
    moveb KbdType,%d4
    swap %d4
    movew %fp@(12),%d4
    movew %a0@+,%d5
    jbra KEYTRANS_48
KEYTRANS_2C:            /* itlk entry: (KbdType, keycode) & mask = match value? replace the masked bits */
    movel %a0@+,%d0
    movew %a0@+,%d1
    movew %a0@+,%d2
    movel %d4,%d3
    andw %d1,%d3
    cmpl %d0,%d3
    jbne KEYTRANS_48
    andw %d1,%d2
    notw %d1
    andw %d1,%d4
    orw %d4,%d2
    movew %d2,%fp@(12)
    jbra KEYTRANS_4C
KEYTRANS_48:            /* next itlk entry */
    dbf %d5,KEYTRANS_2C
KEYTRANS_4C:            /* restore registers, return */
    moveml %sp@+,%d3-%d5
    unlk %fp
KEYTRANS_52:            /* KCHR: pop the arguments, d2 = table number * 128 + key code, d1 bit 31 = key up */
    movel %sp@+,%d0
    moveal %sp@+,%a0
    movew %sp@+,%d1
    moveal %sp@+,%a1
    movel %d0,%sp@-
    moveml %d3/%a2,%sp@-
    movew %d1,%d2
    lsrw #8,%d2
    moveb %a1@(0x2,%d2:w),%d2
    moveq #127,%d0
    andb %d1,%d0
    extw %d1
    extl %d1
    moveb %d2,%d1
    lslw #8,%d1
    moveb %d0,%d1
    lslw #7,%d2
    orb %d1,%d2
    lea %a1@(260),%a1
    moveb %a1@(0x0,%d2:w),%d0
    jbeq KEYTRANS_AE
    tstl %d1
    jbmi KEYTRANS_CE
    movel %a0@,%d3
    jbeq KEYTRANS_CE
    clrl %a0@
    lea %a1@(0x0,%d3:l),%a2
    movew %a2@+,%d2
    jbeq KEYTRANS_A2
    subqw #1,%d2
KEYTRANS_98:            /* dead key pending: look for this character among its completions */
    cmpb %a2@+,%d0
    jbeq KEYTRANS_AA
    addql #1,%a2
    dbf %d2,KEYTRANS_98
KEYTRANS_A2:            /* no completion: the dead key's own character in the high word, then this one */
    swap %d0
    movew %a2@,%d0
    swap %d0
    jbra KEYTRANS_CE
KEYTRANS_AA:            /* completion found: the combined character */
    moveb %a2@,%d0
    jbra KEYTRANS_CE
KEYTRANS_AE:            /* character 0: maybe a dead key, search the dead-key records for table/key */
    movew %a1@(-2),%d3
    lslw #7,%d3
    lea %a1@(0x0,%d3:w),%a2
    movew %a2@+,%d2
    jbeq KEYTRANS_CE
    subqw #1,%d2
KEYTRANS_BE:            /* next dead-key record */
    cmpw %a2@+,%d1
    jbeq KEYTRANS_D8
    movew %a2@+,%d3
    lslw #1,%d3
    lea %a2@(0x2,%d3:w),%a2
    dbf %d2,KEYTRANS_BE
KEYTRANS_CE:            /* return the result */
    moveml %sp@+,%d3/%a2
    movel %d0,%sp@(4)
    rts
KEYTRANS_D8:            /* a dead key (key down): if one was pending, return that one's character */
    tstl %d1
    jbmi KEYTRANS_104
    movel %a0@,%d3
    jbeq KEYTRANS_EE
    moveq #0,%d2
    movew %a1@(0x0,%d3:l),%d2
    lslw #1,%d2
    addl %d2,%d3
    movew %a1@(0x2,%d3:l),%d0
KEYTRANS_EE:            /* has completions: remember it in state, no character yet */
    tstw %a2@
    jbeq KEYTRANS_FA
    movel %a2,%d2
    subl %a1,%d2
    movel %d2,%a0@
    jbra KEYTRANS_CE
KEYTRANS_FA:            /* no completions: return its character */
    clrl %a0@
    swap %d0
    movew %a2@(2),%d0
    jbra KEYTRANS_CE
KEYTRANS_104:           /* dead key released: return its no-completion character */
    movew %a2@+,%d3
    lslw #1,%d3
    movew %a2@(0x0,%d3:w),%d0
    jbra KEYTRANS_CE
    .long   0x00000000, 0x00000000	| 4080AE88
