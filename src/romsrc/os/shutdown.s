/*
 os/shutdown.s - Shutdown Manager
 From SHUTDOWN (0x4080ED70). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 Shutdown queue at 0xBBC: elements of 10 bytes (link, flags, routine). Flags: bit 0
 before power off, 1 before restart, 2 before unmounting (sdOnUnmount), 3 before
 closing the drivers (sdOnDrivers).
*/

/* SHUTDOWN: an INIT-style header (raw bytes: bra, "INIT", ID), then the dispatcher. */
SHUTDOWN:
    .byte   0x60, 0x00, 0x00	| 4080ED70
    .ascii  "\012INIT\000"
    .byte   0x04, 0x10, 0xA3, 0x60, 0x16	| 4080ED79

/* _ShutDown(selector): 0 initialise, 1 power off, 2 restart, 3 install, 4 remove a procedure. */
trap_ShutDown:
SHUTDOWNDISP:
    movel %sp@+,%d2
    movew %sp@+,%d0
    movel %d2,%sp@-
    subqw #1,%d0
    jbmi SHUTDOWNDISP_16
    jbeq SHUTDOWNDISP_A2
    subqw #2,%d0
    jbmi SHUTDOWNDISP_88
    jbeq SHUTDOWNDISP_34
    jbpl SHUTDOWNDISP_52
SHUTDOWNDISP_16:        /* initialise: the queue, and two procedures: close drivers (4), unmount volumes (3) */
    moveq #10,%d0
    .short  0xA71E	| 4080ED96 _NewPtr (flags 0x0700)
    movel %a0,0xbbc
    pea %pc@(CALLROUTINES_56)
    movew #4,%sp@-
    jbsr SHUTDOWNDISP_34
    pea %pc@(CALLROUTINES_94)
    movew #3,%sp@-
    jbsr SHUTDOWNDISP_34
    rts

SHUTDOWNDISP_34:        /* SDInstall(proc, flags): allocate an element, enqueue it */
    movel %sp@+,%d2
    movew %sp@+,%d1
    moveal %sp@+,%a0
    movel %d2,%sp@-
    moveal %a0,%a1
    moveq #10,%d0
    .short  0xA51E	| 4080EDBE _NewPtr (flags 0x0500)
    movew %d1,%a0@(4)
    movel %a1,%a0@(6)
    moveal 0xbbc,%a1
    _Enqueue
    rts
SHUTDOWNDISP_52:        /* SDRemove(proc): find it, dequeue and free it */
    movel %sp@+,%d2
    moveal %sp@+,%a0
    movel %d2,%sp@-
    movel %a2,%sp@-
    moveal 0xbbc,%a1
    addqw #2,%a1
    moveal %a1@+,%a2
    movel %a1@,%d0
    jbeq SHUTDOWNDISP_74
SHUTDOWNDISP_66:        /* next element */
    cmpal %a2@(6),%a0
    jbeq SHUTDOWNDISP_78
    moveal %a2@,%a1
    cmpl %a2,%d0
    moveal %a1,%a2
    jbne SHUTDOWNDISP_66
SHUTDOWNDISP_74:        /* not found: -1 */
    moveq #-1,%d0
    jbra SHUTDOWNDISP_84
SHUTDOWNDISP_78:        /* dequeue, free */
    moveal 0xbbc,%a1
    moveal %a2,%a0
    _Dequeue
    moveal %a2,%a0
    _DisposPtr
SHUTDOWNDISP_84:        /* return */
    moveal %sp@+,%a2
    rts
SHUTDOWNDISP_88:        /* restart: run the procedures, reset the SCC (docking), jump to the ROM's restart entry (ROMBase + 10) */
    moveq #1,%d0
    bigjsr SHUTRESTARTANNEX
    jbsr DOCKINITSCC
    nop
    lea %a0@(10),%a0
    jmp %a0@
SHUTDOWNDISP_A2:        /* power off: run the procedures, grey screen, PowerOff, else the "you may now switch off" alert (system error 42) */
    moveq #0,%d0
    jbsr CALLROUTINES
    _HideCursor
    subqw #4,%sp
    movel %sp,%sp@-
    _GetWMgrPort
    _SetPort
    moveal %a5@,%a0
    movel %a0@(-130),%sp@-
    moveal ROMBase,%a1
    cmpib #3,%a1@(8)
    jbne SHUTDOWNDISP_C8
    pea %a0@(-8)
    jbra SHUTDOWNDISP_CC
SHUTDOWNDISP_C8:        /* (pattern) */
    pea %a0@(-16)
SHUTDOWNDISP_CC:        /* fill the screen */
    movel %a0@(-130),%sp@-
    _SetClip
    _FillRgn
    moveal ROMBase,%a1
    cmpib #3,%a1@(8)
    jbeq SHUTDOWNDISP_E8
    btst #6,ROM85
    jbne SHUTDOWNDISP_EA
SHUTDOWNDISP_E8:        /* power off */
    _PowerOff
SHUTDOWNDISP_EA:        /* could not: system error 42 */
    clrl ResumeProc
    moveq #42,%d0
    _SysError

/*
 CALLROUTINES(d0): run the shutdown procedures: those for the drivers (bit 3), then for
 unmounting (bit 2), then those for d0 (power off or restart). When called from an
 application (0x282 > 0), ExitToShell instead.
*/
CALLROUTINES:
    moveml %d0-%d5/%a1-%a3,%sp@-
    movew %d0,%d4
    tstl 0x282
    jble CALLROUTINES_12
    moveml %sp@+,%d0-%d5/%a1-%a3
    _ExitToShell
CALLROUTINES_12:        /* three passes */
    moveq #3,%d5
    jbsr CALLROUTINES_24
    moveq #2,%d5
    jbsr CALLROUTINES_24
    movew %d4,%d5
    jbsr CALLROUTINES_24
    moveml %sp@+,%d0-%d5/%a1-%a3
    rts

CALLROUTINES_24:        /* run each procedure with flag bit d5, then remove it */
    moveal 0xbbc,%a1
    lea %a1@(2),%a3
    moveal %a3@+,%a2
    movel %a3@,%d3
    jbeq CALLROUTINES_54
CALLROUTINES_32:        /* next element */
    moveal %a2@,%a3
    movew %a2@(4),%d0
    btst %d5,%d0
    jbeq CALLROUTINES_4E
    moveal %a2@(6),%a0
    movew %d5,%d0
    jsr %a0@
    movel %a2@(6),%sp@-
    movew #4,%sp@-
    _ShutDown
CALLROUTINES_4E:        /* (until the last) */
    cmpl %a2,%d3
    moveal %a3,%a2
    jbne CALLROUTINES_32
CALLROUTINES_54:        /* return */
    rts

CALLROUTINES_56:        /* procedure: send the "goodbye" Control (csCode -1) to each driver that wants it (dNeedGoodbye) */
    moveml %d0-%d1/%a0-%a1,%sp@-
    subaw #50,%sp
    movew #-1,%sp@(26)
    moveal UTableBase,%a1
    movew UnitTableEntryCount,%d1
CALLROUTINES_6C:        /* next unit */
    movel %a1@+,%d0
    jbeq CALLROUTINES_86
    moveal %d0,%a0
    moveal %a0@,%a0
    btst #4,%a0@(4)
    jbeq CALLROUTINES_86
    movew %a0@(24),%sp@(24)
    moveal %sp,%a0
    _Control
CALLROUTINES_86:        /* (count) */
    subqw #1,%d1
    jbne CALLROUTINES_6C
    lea %sp@(50),%sp
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts
CALLROUTINES_94:        /* procedure: eject and unmount every volume, the boot volume last */
    subaw #50,%sp
    moveal %sp,%a0
    clrl %a0@(18)
    clrw %a0@(24)
    moveal VCBQHdr_Head,%a1
    movel 0x35c,%d2
    jbeq CALLROUTINES_AE
    jbsr CALLROUTINES_B4
CALLROUTINES_AE:        /* done */
    lea %sp@(50),%sp
    rts

CALLROUTINES_B4:        /* (recursively from the end of the queue): eject and unmount */
    movew %d1,%sp@-
    movew %a1@(78),%d1
    movel %a1@,%sp@-
    cmpal %d2,%a1
    moveal %sp@+,%a1
    jbeq CALLROUTINES_C4
    jbsr CALLROUTINES_B4
CALLROUTINES_C4:        /* eject, unmount */
    movew %d1,%a0@(22)
    _Eject
    .short  0xA20E	| _UnmountVol (flags 0x0200)
    movew %sp@+,%d1
    rts
