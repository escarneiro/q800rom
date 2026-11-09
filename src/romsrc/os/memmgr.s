/*
 os/memmgr.s - Memory Manager
 From HEAP (0x4080CB20). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the Memory Manager chapter of Inside
 Macintosh, not taken from Apple.

 How a call goes: each trap (NewHandle, DisposPtr...) pushes its selector (4 * n) and
 jumps through a prologue vector in low memory. The prologue saves d3-d7/a2-a6 and the
 mode byte (0x1EFC), finds the zone (a6: from the pointer's block header, the
 handle's master pointer, TheZone or SysZone), checks it, and jumps to entry n of
 that zone's routine table (zone +32: 0x1E00 for 24-bit zones, 0x1F00 for 32-bit
 zones; both copied from HEAP by INITMEMVECT, so patches replace entries there). The
 routine (the _C entry for 24-bit, the second for 32-bit) calls the internals, the
 A24... or A32... version, and leaves through MMEPILOGUE (MemErr, the mode byte back).
 0x1EFC bit 0 is the mode the Memory Manager works in (from XPRAM 0x8A; 1 = 32-bit);
 a zone that does not check out is tried once in the other mode.

 Zone header (52 bytes, a6): +0 bkLim (the trailer block at the end), +4 purgePtr
 (where purging resumes), +8 the free master pointer list, +12 zcbFree, +16 the
 application's grow zone procedure, +20 moreMast, +22 flags (bit 0 read-only, 2/3 grow
 zone choices, 4 compact without measuring first, 5 allocate from the start, 6 purge
 from the start, 15 relocatable blocks high), +30 heap type (0 24-bit, 1 32-bit), +32
 the routine table, +40 purge warning procedure, +44 the standard grow zone procedure
 (STDGZ), +48 the allocation rover, +52 the first block (the master pointers, a
 nonrelocatable block whose header names the zone: the zone check).

 Blocks: 24-bit header (8 bytes): tag in bits 7-6 of the first byte (0 free, 1
 nonrelocatable, 2 relocatable), the size correction in its low nibble, the physical
 size in the low 3 bytes; then the zone (nonrelocatable) or the master pointer's
 offset from the zone (relocatable). A 24-bit master pointer's high byte holds the
 flags (bit 7 locked, 6 purgeable, 5 resource). 32-bit header (12 bytes): tag byte,
 flags byte, a reserved byte, the size correction; the physical size; the zone or the
 relative handle (so the A32 code reads flags at data - 11).

 Errors: -99 memROZErr (read-only zone), -108 memFullErr, -109 nilHandleErr, -111
 memWZErr (a free block), -112 memPurErr (locked), -113 memAZErr (not a zone), -115
 memBCErr (block check), -117 memLockedErr; system error 33 if the free count breaks.
*/

/*
 HEAP: the Memory Manager's routine table: 40 pairs (24-bit routine, 32-bit routine) as
 offsets from the ROM start, one pair per selector (selector = 4 * index: 0
 SetApplBase, 4 InitApplZone, 8 InitZone, 12 GetZone, 16 SetZone, 20 MaxBlock, 24
 PurgeSpace, 28 CompactMem, 32 PurgeMem, 36 FreeMem, 40 ResrvMem, 44 MaxMem, 48
 SetGrowZone, 52 SetApplLimit, 56 StackSpace, 60 MaxApplZone, 64 NewPtr, 68 DisposPtr,
 72 GetPtrSize, 76 SetPtrSize, 80 PtrZone, 84 NewHandle, 88 NewEmptyHandle, 92
 DisposHandle, 96 GetHandleSize, 100 SetHandleSize, 104 HandleZone, 108 RecoverHandle,
 112 EmptyHandle, 116 ReallocHandle, 120 HLock ... 148 HSetState, 152 MoreMasters,
 156 MoveHHi). INITMEMVECT copies them into RAM (0x1E00 and 0x1F00), where patches can
 replace them.
*/
HEAP:
    .long   SETAPPLBASE_8-rom_start	| 4080CB20
    .long   SETAPPLBASE_2E-rom_start	| 4080CB24
    .long   INITAPPLZONE_C-rom_start	| 4080CB28
    .long   INITAPPLZONE_C-rom_start	| 4080CB2C
    .long   INITZONE_C-rom_start	| 4080CB30
    .long   INITZONE_B2-rom_start	| 4080CB34
    .long   GETZONE_C-rom_start	| 4080CB38
    .long   GETZONE_C-rom_start	| 4080CB3C
    .long   SETZONE_C-rom_start	| 4080CB40
    .long   SETZONE_C-rom_start	| 4080CB44
    .long   COMPACTMEM_C-rom_start	| 4080CB48
    .long   COMPACTMEM_3E-rom_start	| 4080CB4C
    .long   PURGESPACE_C-rom_start	| 4080CB50
    .long   PURGESPACE_12-rom_start	| 4080CB54
    .long   COMPACTMEM_10-rom_start	| 4080CB58
    .long   COMPACTMEM_42-rom_start	| 4080CB5C
    .long   PURGEMEM_C-rom_start	| 4080CB60
    .long   PURGEMEM_22-rom_start	| 4080CB64
    .long   FREEMEM_C-rom_start	| 4080CB68
    .long   FREEMEM_C-rom_start	| 4080CB6C
    .long   RESRVMEM_C-rom_start	| 4080CB70
    .long   RESRVMEM_28-rom_start	| 4080CB74
    .long   MAXMEM_C-rom_start	| 4080CB78
    .long   MAXMEM_38-rom_start	| 4080CB7C
    .long   SETGROWZONE_C-rom_start	| 4080CB80
    .long   SETGROWZONE_C-rom_start	| 4080CB84
    .long   SETAPPLLIMIT_C-rom_start	| 4080CB88
    .long   SETAPPLLIMIT_40-rom_start	| 4080CB8C
    .long   STACKSPACE_C-rom_start	| 4080CB90
    .long   STACKSPACE_C-rom_start	| 4080CB94
    .long   MAXAPPLZONE_C-rom_start	| 4080CB98
    .long   MAXAPPLZONE_44-rom_start	| 4080CB9C
    .long   NEWPTR_C-rom_start	| 4080CBA0
    .long   NEWPTR_24-rom_start	| 4080CBA4
    .long   DISPOSEPTR_C-rom_start	| 4080CBA8
    .long   DISPOSEPTR_1A-rom_start	| 4080CBAC
    .long   GETPTRSIZE_C-rom_start	| 4080CBB0
    .long   GETPTRSIZE_12-rom_start	| 4080CBB4
    .long   SETPTRSIZE_C-rom_start	| 4080CBB8
    .long   SETPTRSIZE_12-rom_start	| 4080CBBC
    .long   PTRZONE_C-rom_start	| 4080CBC0
    .long   PTRZONE_C-rom_start	| 4080CBC4
    .long   NWHANDLE_C-rom_start	| 4080CBC8
    .long   NWHANDLE_1C-rom_start	| 4080CBCC
    .long   NEWEMPTYHANDLE_C-rom_start	| 4080CBD0
    .long   NEWEMPTYHANDLE_14-rom_start	| 4080CBD4
    .long   DSPOSEHANDLE_C-rom_start	| 4080CBD8
    .long   DSPOSEHANDLE_12-rom_start	| 4080CBDC
    .long   GETHANDLESIZE_C-rom_start	| 4080CBE0
    .long   GETHANDLESIZE_14-rom_start	| 4080CBE4
    .long   SETHANDLESIZE_C-rom_start	| 4080CBE8
    .long   SETHANDLESIZE_14-rom_start	| 4080CBEC
    .long   HANDLEZONE_C-rom_start	| 4080CBF0
    .long   HANDLEZONE_C-rom_start	| 4080CBF4
    .long   RECOVERHANDLE_C-rom_start	| 4080CBF8
    .long   RECOVERHANDLE_36-rom_start	| 4080CBFC
    .long   EMPTYHANDLE_C-rom_start	| 4080CC00
    .long   EMPTYHANDLE_18-rom_start	| 4080CC04
    .long   REALLOCHANDLE_C-rom_start	| 4080CC08
    .long   REALLOCHANDLE_4A-rom_start	| 4080CC0C
    .long   HLOCK_C-rom_start	| 4080CC10
    .long   HLOCK_18-rom_start	| 4080CC14
    .long   HUNLOCK_C-rom_start	| 4080CC18
    .long   HUNLOCK_18-rom_start	| 4080CC1C
    .long   HPURGE_C-rom_start	| 4080CC20
    .long   HPURGE_14-rom_start	| 4080CC24
    .long   HNOPURGE_C-rom_start	| 4080CC28
    .long   HNOPURGE_14-rom_start	| 4080CC2C
    .long   HRSRC_C-rom_start	| 4080CC30
    .long   HRSRC_14-rom_start	| 4080CC34
    .long   HNORSRC_C-rom_start	| 4080CC38
    .long   HNORSRC_14-rom_start	| 4080CC3C
    .long   HGETFLAGS_C-rom_start	| 4080CC40
    .long   HGETFLAGS_14-rom_start	| 4080CC44
    .long   HSETFLAGS_C-rom_start	| 4080CC48
    .long   HSETFLAGS_12-rom_start	| 4080CC4C
    .long   MOREMASTERS_C-rom_start	| 4080CC50
    .long   MOREMASTERS_1E-rom_start	| 4080CC54
    .long   MOVEHHI_C-rom_start	| 4080CC58
    .long   MOVEHHI_16C-rom_start	| 4080CC5C

/*
 INITMEMVECT: the Memory Manager's vectors in low memory: the 24-bit routines at 0x1E00,
 the 32-bit routines at 0x1F00 (40 each, from HEAP + ROMBase), and the prologue and
 epilogue vectors (0x1EE0 MMNOPROLOGUE, 0x1EE4 MMPPROLOGUE, 0x1EE8 MMPROLOGUE, 0x1EEC
 MMHPROLOGUE, 0x1FE0 MMRHPROLOGUE, 0x1FE4 MMMMPROLOGUE, 0x1FE8 MMEPILOGUE, 0x1FEC
 MMNOERREPILOGUE). XPRAM 0x8A goes to 0x1EFC: its bit 0 is the addressing mode the
 Memory Manager works in (1 = 32-bit). Bits 0 and 2 of it also clear bits 0 and 1 of
 0xB73.
*/
INITMEMVECT:            /* XPRAM 0x8A: the addressing mode */
    moveml %d0-%d1/%a0-%a2,%sp@-
    lea 0x1efc,%a0
    movel #65674,%d0	/* XPRAM 0x8A, 1 byte, to 0x1EFC */
    _ReadXPRam
    btst #0,0x1efc
    jbeq INITMEMVECT_1E
    bclr #0,0xb73
INITMEMVECT_1E:         /* XPRAM 0x8A bit 2? */
    btst #2,0x1efc
    jbeq INITMEMVECT_2C
    bclr #1,0xb73
INITMEMVECT_2C:         /* copy the 40 pairs, adding ROMBase */
    movel ROMBase,%d0
    lea %pc@(HEAP),%a0
    lea 0x1e00,%a1
    lea 0x1f00,%a2
    moveq #39,%d1
INITMEMVECT_3E:         /* one 24-bit and one 32-bit vector */
    movel %a0@+,%a1@
    addl %d0,%a1@+
    movel %a0@+,%a2@
    addl %d0,%a2@+
    dbf %d1,INITMEMVECT_3E
    addil #65536,%d0
    movel %d0,ResetStackPtr	/* (ROMBase + 64 KB into the reset vectors) */
    movel %d0,ResetVector
    lea %pc@(MMNOPROLOGUE),%a0
    movel %a0,0x1ee0
    lea %pc@(MMPPROLOGUE),%a0
    movel %a0,0x1ee4
    lea %pc@(MMPROLOGUE),%a0
    movel %a0,0x1ee8
    lea %pc@(MMHPROLOGUE),%a0
    movel %a0,0x1eec
    lea %pc@(MMRHPROLOGUE),%a0
    movel %a0,0x1fe0
    lea %pc@(MMMMPROLOGUE),%a0
    movel %a0,0x1fe4
    lea %pc@(MMEPILOGUE),%a0
    movel %a0,0x1fe8
    lea %pc@(MMNOERREPILOGUE),%a0
    movel %a0,0x1fec
    moveml %sp@+,%d0-%d1/%a0-%a2
    rts

/* _SetApplBase(a0): move the start of the application heap (the system heap grows up to it), then InitApplZone. */
trap_SetApplBase:
SETAPPLBASE:            /* selector 0 (routine 0 of the table), through MMNOPROLOGUE */
    clrl %sp@-
    movel 0x1ee0,%sp@-
    rts

SETAPPLBASE_8:          /* 24-bit: SETAPPLBASEPATCH may move the base; the system zone's end moves up to it (minus a 12-byte trailer), then InitApplZone */
    moveml %d3/%a2-%fp,%sp@-
    moveal SysZone,%fp
    movel %a0,%d0
    jbsr SETAPPLBASEPATCH
    moveal %d0,%a0
    subaw #12,%a0
    cmpal %fp@,%a0
    jbls SETAPPLBASE_26
    jbsr A24ZONEADJUSTEND
SETAPPLBASE_26:         /* re-create the application zone */
    jbsr INITAPPLZONE_32
    moveml %sp@+,%d3/%a2-%fp
    rts

SETAPPLBASE_2E:         /* 32-bit: the same with a 16-byte trailer */
    moveml %d3/%a2-%fp,%sp@-
    moveal SysZone,%fp
    movel %a0,%d0
    jbsr SETAPPLBASEPATCH
    moveal %d0,%a0
    subaw #16,%a0
    cmpal %fp@,%a0
    jbls SETAPPLBASE_4C
    jbsr A32ZONEADJUSTEND
SETAPPLBASE_4C:         /* re-create the application zone */
    jbsr INITAPPLZONE_32
    moveml %sp@+,%d3/%a2-%fp
    rts

/* _InitApplZone: reinitialise the application heap (from ApplZone to the stack limit), clearing it. */
trap_InitApplZone:
INITAPPLZONE:           /* selector 4 (routine 1 of the table), through MMNOPROLOGUE */
    movel #4,%sp@-
    movel 0x1ee0,%sp@-
    rts
INITAPPLZONE_C:         /* clear 16 bytes of ExpandMem (+24), call the hooks before (0x6E8) and after (0x6EC) the new zone */
    moveal ExpandMem,%a0
    lea %a0@(24),%a0
    moveq #3,%d0
INITAPPLZONE_16:        /* clear four longs */
    clrl %a0@+
    dbf %d0,INITAPPLZONE_16
    moveal 0x6e8,%a0
    jsr %a0@
    jbsr INITAPPLZONE_32
    moveal 0x6ec,%a0
    jsr %a0@
    moveq #0,%d0
    movew %d0,MemErr
    rts

INITAPPLZONE_32:        /* the application zone: RsrcZoneInit (close the application's resource files), ApplLimit = HighHeapMark = stack - DefltStack, the zone right after the system zone, 6 KB long (or up to ApplLimit), 64 master pointers, no grow zone procedure */
    movel %fp,%sp@-
    _RsrcZoneInit
    clrl ApplZone
    movel %sp,%d1
    subl DefltStack,%d1
    movel %d1,ApplLimit
    movel %d1,HighHeapMark
    moveal SysZone,%fp
    moveal %fp@,%a0
    tstb %fp@(30)
    jbne INITAPPLZONE_5A
    lea %a0@(12),%a0
    jbra INITAPPLZONE_5E
INITAPPLZONE_5A:        /* 32-bit system zone: its trailer is 16 bytes */
    lea %a0@(16),%a0
INITAPPLZONE_5E:        /* end = start + 6144, at most ApplLimit */
    moveal %a0,%a1
    lea %a1@(6144),%a1
    cmpal %d1,%a1
    jbcs INITAPPLZONE_6A
    moveal %d1,%a1
INITAPPLZONE_6A:        /* InitZone parameter block on the stack: start, end, 64 masters, no grow zone; HeapEnd = its end */
    clrl %sp@-
    movew #64,%sp@-
    movel %a1,%sp@-
    movel %a0,%sp@-
    movel %a0,ApplZone
    moveal %sp,%a0
    _InitZone
    lea %sp@(14),%sp
    moveal TheZone,%fp
    movel %fp@,HeapEnd
    moveq #0,%d0
    movew %d0,MemErr
    moveal %sp@+,%fp
    rts

/* VIAZINIT: InitApplZone hook: before the zone is set up. */
trap_VIAZINIT:
VIAZINIT:               /* IAZNotify, if set, first */
    movel IAZNotify,%d0
    jble VIAZINIT_A
    moveal %d0,%a0
    jsr %a0@
VIAZINIT_A:             /* before a new application zone: reset the application's globals: WWExist, MenuList, the event mask, hooks */
    movew #-1,WWExist
    st 0xd42
    clrl MenuList
    movel MinusOne,LastSPExtra
    st SEvtEnb
    moveq #31,%d0
VIAZINIT_24:            /* a 64-byte parameter block on the stack */
    clrw %sp@-
    dbf %d0,VIAZINIT_24
    moveal %sp,%a0
    movel VCBQHdr_Head,%d0
VIAZINIT_30:            /* FlushVol every mounted volume (VCB queue) */
    jbeq VIAZINIT_42
    moveal %d0,%a1
    movew %a1@(72),%a0@(22)
    jbeq VIAZINIT_3E
    _FlushVol
VIAZINIT_3E:            /* next volume */
    movel %a1@,%d0
    jbra VIAZINIT_30
VIAZINIT_42:            /* clear the drag, desk, close and resource error hooks, the eject notify; the hook at 0x6E0, the application's VBL tasks and Notification Manager requests; the two tables below; the current graphics device back to the main one */
    lea %sp@(64),%sp
    clrl DragHook
    clrl DeskHook
    lea CloseOrnHook,%a0
    clrl %a0@+
    clrl %a0@+
    clrl %a0@+
    clrw TaskLock
    clrl ResErrProc
    clrl EjectNotify
    moveal 0x6e0,%a0
    jsr %a0@
    jbsr FLUSHAPPLVBLS
    bigjsr FLUSHAPPLNM
    jbsr VIAZINIT_8E
    jbsr VIAZINIT_D2
    moveal MainDevice,%a0
    movel %a0,SrcDevice
    movel %a0,TheGDevice
    movew #8192,%sr
    rts

VIAZINIT_8E:            /* the table at 0xD66: remove entries that point into the application zone (Munger) */
    moveal PortList,%a1
    cmpal MinusOne,%a1
    jbeq VIAZINIT_D0
    moveal %a1@,%a1
    moveal %a1,%a0
    movew %a1@+,%d1
    jbra VIAZINIT_A8
VIAZINIT_A0:            /* next entry: in the application zone (APPZONEADDR)? */
    movel %a1@+,%d0
    jbsr APPZONEADDR
    jbeq VIAZINIT_AE
VIAZINIT_A8:            /* count down */
    dbf %d1,VIAZINIT_A0
    jbra VIAZINIT_D0
VIAZINIT_AE:            /* yes: delete it (Munger, 4 bytes) and start again */
    subqw #1,%a0@
    movel %a1@-,%sp@-
    clrl %sp@-
    movel PortList,%sp@-
    moveq #2,%d0
    movel %d0,%sp@-
    pea %sp@(12)
    moveq #4,%d0
    movel %d0,%sp@-
    pea %pc@(VIAZINIT_D0)
    clrl %sp@-
    _Munger
    addqw #8,%sp
    jbra VIAZINIT_8E
VIAZINIT_D0:            /* return */
    rts

VIAZINIT_D2:            /* the palette table (0xDC8): dispose of the palettes in the application zone */
    moveml %d3/%a2-%a3,%sp@-
    moveal 0xdc8,%a2
    cmpal MinusOne,%a2
    jbeq VIAZINIT_114
    moveal %a2@,%a1
    moveal %a1@(4),%a0
    _HLock
    moveal %a0@,%a3
    movew %a1@(8),%d3
    jbeq VIAZINIT_10C
    addw %a1@(10),%d3
    jbra VIAZINIT_108
VIAZINIT_F6:            /* next entry: a palette in the application zone? DisposePalette */
    movel %a3@,%d1
    jbeq VIAZINIT_106
    movel %d1,%d0
    jbsr APPZONEADDR
    jbne VIAZINIT_106
    movel %d1,%sp@-
    _DisposePalette
VIAZINIT_106:           /* next (8 bytes) */
    addqw #8,%a3
VIAZINIT_108:           /* count down */
    dbf %d3,VIAZINIT_F6
VIAZINIT_10C:           /* unlock the table */
    moveal %a2@,%a1
    moveal %a1@(4),%a0
    _HUnlock
VIAZINIT_114:           /* restore registers, return */
    moveml %sp@+,%d3/%a2-%a3
    rts

/* VIAZPOSTINIT: InitApplZone hook: after it. */
trap_VIAZPOSTINIT:
VIAZPOSTINIT:           /* (raw trap word A9E6) then CurApRefNum = 0, RDrvrInstall */
    .short  0xA9E6	| .short 0xa9e6
    clrw CurApRefNum
    _RDrvrInstall
    rts

/* _InitZone(a0 = start, limit, master pointer count, grow zone procedure): create a heap zone. */
trap_InitZone:
INITZONE:               /* selector 8 (routine 2 of the table), through MMNOPROLOGUE */
    movel #8,%sp@-
    movel 0x1ee0,%sp@-
    rts

INITZONE_C:             /* 24-bit InitZone(a0 = start, end, master pointer count, grow zone procedure): TheZone = it; the 52-byte zone header cleared */
    moveml %a2-%a3/%fp,%sp@-
    moveal %a0,%a1
    moveal %a1@+,%fp
    movel %fp,TheZone
    moveal %fp,%a0
    moveal %fp,%a2
    moveq #12,%d1
INITZONE_1E:            /* clear 13 longs */
    clrl %a0@+
    dbf %d1,INITZONE_1E
    movel %a1@+,%d1
    andl Lo3Bytes,%d1
    jbsr ALIGN24TRAILER
    cmpal HighHeapMark,%a3
    jblt INITZONE_44
    movel %sp,%d1
    andl Lo3Bytes,%d1
    cmpal %d1,%a3
    jbgt INITZONE_44
    movel %a3,HighHeapMark
INITZONE_44:            /* the 12-byte trailer block at the end; bkLim (+0) = it, purgePtr (+4) = the first block, zcbFree (+12) = the space; the grow zone procedure (+16), STDGZ (+44), moreMast (+20), flags (+22) = MMDefFlags; heap type (+30) 0, routine table (+32) 0x1E00; the free block, the master pointers */
    moveq #12,%d1
    subal %d1,%a3
    movel %d1,%a3@
    movel %a3,%a2@+
    movel %a0,%a2@+
    addqw #4,%a2
    subal %a0,%a3
    movel %a3,%d0
    movel %d0,%a2@+
    movew %a1@+,%d1
    movel %a1@+,%a2@+
    lea %pc@(STDGZ),%a1
    movel %a1,%a2@(24)
    movew %d1,%a2@+
    movew MMDefFlags,%a2@+
    clrb %fp@(30)	/* heap type 0: 24-bit */
    movel #7680,%fp@(32)	/* the 24-bit routine table, 0x1E00 */
    jbsr A24MAKEBKF
    jbsr A24HMAKEMOREMASTERS
    jbsr INIT24ZONEALIGN
    jbra INITZONE_A6
    .long   0x4E714E71	| 4080CF8C
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 4080CF90
    .short  0x4E71, 0x4E71, 0x4E71, 0x4E71, 0x4E71, 0x4E71, 0x4E71	| 4080CFA0
INITZONE_A6:            /* restore registers, no error */
    moveml %sp@+,%a2-%a3/%fp
    moveq #0,%d0
    movew %d0,MemErr
    rts

INITZONE_B2:            /* 32-bit InitZone: the same with 16-byte trailers, heap type 1, routine table 0x1F00 */
    moveml %a2-%a3/%fp,%sp@-
    moveal %a0,%a1
    moveal %a1@+,%fp
    movel %fp,TheZone
    moveal %fp,%a0
    moveal %fp,%a2
    moveq #12,%d1
INITZONE_C4:            /* clear 13 longs */
    clrl %a0@+
    dbf %d1,INITZONE_C4
    movel %a1@+,%d1
    jbsr ALIGN32TRAILER
    cmpal HighHeapMark,%a3
    jblt INITZONE_E2
    movel %sp,%d1
    cmpal %d1,%a3
    jbgt INITZONE_E2
    movel %a3,HighHeapMark
INITZONE_E2:            /* the 16-byte trailer block */
    moveq #16,%d1
    subal %d1,%a3
    clrl %a3@
    movel %d1,%a3@(4)
    movel %a3,%a2@+
    movel %a0,%a2@+
    addqw #4,%a2
    subal %a0,%a3
    movel %a3,%d0
    movel %d0,%a2@+
    movew %a1@+,%d1
    movel %a1@+,%a2@+
    lea %pc@(STDGZ),%a1
    movel %a1,%a2@(24)
    movew %d1,%a2@+
    movew MMDefFlags,%a2@+
    moveb #1,%fp@(30)	/* heap type 1: 32-bit */
    movel #7936,%fp@(32)	/* the 32-bit routine table, 0x1F00 */
    jbsr A32MAKEBKF
    jbsr A32HMAKEMOREMASTERS
    jbsr INIT32ZONEALIGN
    jbra INITZONE_154
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 4080D030
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71, 0x4E714E71	| 4080D040
    .long   0x4E714E71, 0x4E714E71, 0x4E714E71	| 4080D050
INITZONE_154:           /* restore registers */
    moveml %sp@+,%a2-%a3/%fp
INITZONE_158:           /* no error (MemErr = 0) */
    moveq #0,%d0
    movew %d0,MemErr
    rts

/* _GetZone: a0 = TheZone. */
trap_GetZone:
GETZONE:                /* selector 12 (routine 3 of the table), through MMNOPROLOGUE */
    movel #12,%sp@-
    movel 0x1ee0,%sp@-
    rts
GETZONE_C:              /* a0 = TheZone */
    moveal TheZone,%a0
    jbra INITZONE_158

/* _SetZone(a0): TheZone = a0. */
trap_SetZone:
SETZONE:                /* selector 16 (routine 4 of the table), through MMNOPROLOGUE */
    movel #16,%sp@-
    movel 0x1ee0,%sp@-
    rts
SETZONE_C:              /* TheZone = a0 */
    movel %a0,TheZone
    jbra INITZONE_158

/* _MaxBlock: the largest block that could be allocated after compacting (d0). */
trap_MaxBlock:
MAXBLOCK:               /* selector 20 through MMPROLOGUE, d0 = the long at 0x1EF4 (the size asked: as much as possible); then minus a header */
    pea %pc@(MAXBLOCK_14)
    movel 0x1ef4,%d0
    movel #20,%sp@-
    movel 0x1ee8,%sp@-
    rts
MAXBLOCK_14:            /* without the block header (4 more for MaxBlock's own) */
    subql #4,%d0
    jbge MAXBLOCK_1A
    moveq #0,%d0
MAXBLOCK_1A:            /* return */
    rts

/* _CompactMem(d0): compact the zone, return the largest free block. */
trap_CompactMem:
COMPACTMEM:             /* selector 28 (routine 7 of the table), through MMPROLOGUE (TheZone or SysZone) */
    movel #28,%sp@-
    movel 0x1ee8,%sp@-
    rts
COMPACTMEM_C:           /* 24-bit MaxBlock (selector 20, d1 = 1): measure the largest free block that compaction would give, without moving anything (zone flag bit 4 cleared) */
    moveq #1,%d1
    jbra COMPACTMEM_12
COMPACTMEM_10:          /* 24-bit CompactMem (selector 28, d1 = 0): really compact (flag bit 4 set) */
    moveq #0,%d1
COMPACTMEM_12:          /* d0 = the physical size for the request (A24ACTUALS) */
    jbsr thunk_FUN_408878ee
    lea %fp@(22),%a1
    moveb %a1@,%d2
    tstb %d1
    jbne COMPACTMEM_26
    bset #4,%a1@
    jbra COMPACTMEM_2A
COMPACTMEM_26:          /* measure only */
    bclr #4,%a1@
COMPACTMEM_2A:          /* compact (V24CMGUTSPATCH); d0 = the largest free block, logical */
    jbsr V24CMGUTSPATCH
    movel %d1,%d0
    beqw PURGEMEM_20
    subql #8,%d0
    movel %a0,%d1
    jbeq PURGEMEM_20
    jbra PURGEMEM_1E
COMPACTMEM_3E:          /* 32-bit MaxBlock */
    moveq #1,%d1
    jbra COMPACTMEM_44
COMPACTMEM_42:          /* 32-bit CompactMem */
    moveq #0,%d1
COMPACTMEM_44:          /* physical size */
    jbsr thunk_FUN_40887926
    lea %fp@(22),%a1
    moveb %a1@,%d2
    tstb %d1
    jbne COMPACTMEM_58
    bset #4,%a1@
    jbra COMPACTMEM_5C
COMPACTMEM_58:          /* measure only */
    bclr #4,%a1@
COMPACTMEM_5C:          /* compact; the largest free block minus the 12-byte header */
    jbsr V32CMGUTSPATCH
    movel %d1,%d0
    jbeq PURGEMEM_38
    subil #12,%d0
    movel %a0,%d1
    jbeq PURGEMEM_38
    jbra PURGEMEM_34

/* _PurgeMem(d0): purge purgeable blocks until d0 bytes are free. */
trap_PurgeMem:
PURGEMEM:               /* selector 32 (routine 8 of the table), through MMPROLOGUE (TheZone or SysZone) */
    movel #32,%sp@-
    movel 0x1ee8,%sp@-
    rts
PURGEMEM_C:             /* 24-bit PurgeMem: purge until there is a free block of d0 */
    jbsr thunk_FUN_408878ee
    jbsr A24PURGEHEAP

PURGEMEM_14:            /* a0 = the block: none, -108 (memFullErr) */
    movel %a0,%d0
    jbne PURGEMEM_1C
    moveq #-108,%d0
    jbra PURGEMEM_20
PURGEMEM_1C:            /* 0 */
    moveq #0,%d0
PURGEMEM_1E:            /* a0 = the data */
    addql #8,%a0
PURGEMEM_20:            /* exit */
    jbra PURGEMEM_38
PURGEMEM_22:            /* 32-bit PurgeMem */
    jbsr thunk_FUN_40887926
    jbsr A32PURGEHEAP

PURGEMEM_2A:            /* none: -108 */
    movel %a0,%d0
    jbne PURGEMEM_32
    moveq #-108,%d0
    jbra PURGEMEM_38
PURGEMEM_32:            /* 0 */
    moveq #0,%d0
PURGEMEM_34:            /* a0 = the data */
    addaw #12,%a0
PURGEMEM_38:            /* exit (MMEPILOGUE) */
    movel 0x1fe8,%sp@-
    rts

/* _PurgeSpace: total (d0) and contiguous (a0) space if everything purgeable were purged. */
trap_PurgeSpace:
PURGESPACE:             /* selector 24 (routine 6 of the table), through MMPROLOGUE (TheZone or SysZone) */
    movel #24,%sp@-
    movel 0x1ee8,%sp@-
    rts

PURGESPACE_C:           /* 24-bit: total and contiguous purgeable space */
    jbsr A24TOTEPURGEABLES
    jbra PURGESPACE_16
PURGESPACE_12:          /* 32-bit */
    jbsr A32TOTEPURGEABLES
PURGESPACE_16:          /* exit */
    movel 0x1fe8,%sp@-
    rts

/* _FreeMem: total free bytes in the zone (d0). */
trap_FreeMem:
FREEMEM:                /* selector 36 (routine 9 of the table), through MMPROLOGUE (TheZone or SysZone) */
    movel #36,%sp@-
    movel 0x1ee8,%sp@-
    rts
FREEMEM_C:              /* d0 = zcbFree (+12) */
    movel %fp@(12),%d0
    movel 0x1fe8,%sp@-
    rts

/* _ResrvMem(d0): make room for a block of d0 bytes as low as possible in the zone. */
trap_ResrvMem:
RESRVMEM:               /* selector 40 (routine 10 of the table), through MMPROLOGUE (TheZone or SysZone) */
    movel #40,%sp@-
    movel 0x1ee8,%sp@-
    rts
RESRVMEM_C:             /* 24-bit ResrvMem: room for d0 bytes low in the zone; with no free master pointer left, also for a block of moreMast pointers */
    tstl %fp@(8)
    jbne RESRVMEM_1E
    movew %fp@(20),%d2
    extl %d2
    asll #2,%d2
    addql #8,%d2
    addl %d2,%d0
RESRVMEM_1E:            /* make the room (A24MAKEPTRSPC), a0 = it */
    jbsr A24MAKEPTRSPC
    moveal %a2,%a0
    jbra PURGEMEM_14
RESRVMEM_28:            /* 32-bit */
    tstl %fp@(8)
    jbne RESRVMEM_3E
    movew %fp@(20),%d2
    extl %d2
    asll #2,%d2
    addil #12,%d2
    addl %d2,%d0
RESRVMEM_3E:            /* make the room */
    jbsr A32MAKEPTRSPC
    moveal %a2,%a0
    jbra PURGEMEM_2A

/* _MaxMem: purge and compact everything, return the largest block (d0) and the room the application heap can grow (a0). */
trap_MaxMem:
MAXMEM:                 /* selector 44 (routine 11 of the table), through MMPROLOGUE (TheZone or SysZone) */
    movel #44,%sp@-
    movel 0x1ee8,%sp@-
    rts

MAXMEM_C:               /* 24-bit MaxMem: purge and compact everything (V24MAXMEMPATCH), d0 = the largest block */
    movel 0x1ef4,%d0
    jbsr V24MAXMEMPATCH
    movel %d1,%d0
    jbeq MAXMEM_1C
    subql #8,%d0
MAXMEM_1C:              /* a0 = how far the application zone could still grow (to ApplLimit) */
    subal %a0,%a0
    moveal ApplZone,%a1
    cmpal TheZone,%a1
    jbne MAXMEM_36
    movel ApplLimit,%d2
    jbsr thunk_FUN_40887882
    subl HeapEnd,%d1
    moveal %d1,%a0
MAXMEM_36:              /* exit */
    jbra MAXMEM_66
MAXMEM_38:              /* 32-bit */
    movel 0x1ef4,%d0
    jbsr V32MAXMEMPATCH
    movel %d1,%d0
    jbeq MAXMEM_4C
    subil #12,%d0
MAXMEM_4C:              /* a0 = how far it could grow */
    subal %a0,%a0
    moveal ApplZone,%a1
    cmpal TheZone,%a1
    jbne MAXMEM_66
    movel ApplLimit,%d2
    jbsr thunk_FUN_408878c0
    subl HeapEnd,%d1
    moveal %d1,%a0
MAXMEM_66:              /* exit */
    movel 0x1fe8,%sp@-
    rts

/* _SetGrowZone(a0): the zone's grow zone procedure. */
trap_SetGrowZone:
SETGROWZONE:            /* selector 48 (routine 12 of the table), through MMNOPROLOGUE */
    movel #48,%sp@-
    movel 0x1ee0,%sp@-
    rts
SETGROWZONE_C:          /* TheZone's gzProc (+16) = a0 */
    moveal TheZone,%a1
    movel %a0,%a1@(16)
    jbra SETAPPLLIMIT_38

/* _SetApplLimit(a0): the highest address the application heap may grow to. */
trap_SetApplLimit:
SETAPPLLIMIT:           /* selector 52 (routine 13 of the table), through MMNOPROLOGUE */
    movel #52,%sp@-
    movel 0x1ee0,%sp@-
    rts
SETAPPLLIMIT_C:         /* 24-bit: at most the stack - DefltStack */
    movel %a0,%d0
    andl Lo3Bytes,%d0
    moveal %d0,%a0
    movel %sp,%d1
    andl Lo3Bytes,%d1
    subl DefltStack,%d1
    cmpl %d0,%d1
    jbgt SETAPPLLIMIT_24
    moveal %d1,%a0
SETAPPLLIMIT_24:        /* ApplLimit = HighHeapMark = it; -108 if below the zone's end */
    movel %a0,ApplLimit
    movel %a0,HighHeapMark
    moveal ApplZone,%a1
    moveal %a1@,%a1
    moveq #-108,%d0
    cmpal %a0,%a1
    jbhi SETAPPLLIMIT_3A
SETAPPLLIMIT_38:        /* no error */
    moveq #0,%d0
SETAPPLLIMIT_3A:        /* MemErr */
    movew %d0,MemErr
    rts
SETAPPLLIMIT_40:        /* 32-bit: the same without masking the address */
    movel %a0,%d0
    movel %sp,%d1
    subl DefltStack,%d1
    cmpl %d0,%d1
    jbgt SETAPPLLIMIT_4E
    moveal %d1,%a0
SETAPPLLIMIT_4E:        /* ApplLimit = HighHeapMark = it */
    movel %a0,ApplLimit
    movel %a0,HighHeapMark
    moveal ApplZone,%a1
    moveal %a1@,%a1
    moveq #-108,%d0
    cmpal %a0,%a1
    jbhi SETAPPLLIMIT_64
    moveq #0,%d0
SETAPPLLIMIT_64:        /* MemErr */
    movew %d0,MemErr
    rts

/* _StackSpace: bytes left between the stack and the heap (d0). */
trap_StackSpace:
STACKSPACE:             /* selector 56 (routine 14 of the table), through MMNOPROLOGUE */
    movel #56,%sp@-
    movel 0x1ee0,%sp@-
    rts
STACKSPACE_C:           /* d0 = the stack pointer (rounded) - HighHeapMark */
    moveq #20,%d0
    addl %sp,%d0
    andiw #-4,%d0
    subl HighHeapMark,%d0
    clrw MemErr
    rts

/* _MaxApplZone: grow the application heap to its limit. */
trap_MaxApplZone:
MAXAPPLZONE:            /* selector 60 (routine 15 of the table), through MMNOPROLOGUE */
    movel #60,%sp@-
    movel 0x1ee0,%sp@-
    rts

MAXAPPLZONE_C:          /* 24-bit: grow the application zone up to ApplLimit (V24MAXAPPLPATCH gives the new end) */
    movel ApplLimit,%d0
    jbsr V24MAXAPPLPATCH
    lea HeapEnd,%a1
    subl %a1@,%d0
    moveq #12,%d2
    cmpl %d2,%d0
    jbcs MAXAPPLZONE_40
    moveal %a1@,%a0
    movel %d0,%a0@
    movel %d1,%a1@
    moveal %d1,%a0
    cmpal HighHeapMark,%a0
    jbls MAXAPPLZONE_34
    movel %a0,HighHeapMark
MAXAPPLZONE_34:         /* the zone's bkLim = the new trailer, the old trailer becomes free space */
    moveal ApplZone,%a1
    movel %a0,%a1@
    movel %d2,%a0@
    addl %d0,%a1@(12)
MAXAPPLZONE_40:         /* no error */
    jbra SETAPPLLIMIT_38
MAXAPPLZONE_44:         /* 32-bit */
    movel ApplLimit,%d0
    jbsr V32MAXAPPLPATCH
    lea HeapEnd,%a1
    subl %a1@,%d0
    moveq #16,%d2
    cmpl %d2,%d0
    jbcs MAXAPPLZONE_80
    moveal %a1@,%a0
    clrl %a0@
    movel %d0,%a0@(4)
    movel %d1,%a1@
    moveal %d1,%a0
    cmpal HighHeapMark,%a0
    jbls MAXAPPLZONE_70
    movel %a0,HighHeapMark
MAXAPPLZONE_70:         /* the new trailer */
    moveal ApplZone,%a1
    movel %a0,%a1@
    clrl %a0@
    movel %d2,%a0@(4)
    addl %d0,%a1@(12)
MAXAPPLZONE_80:         /* no error */
    jbra SETAPPLLIMIT_38

/* _NewPtr(d0 = size, flags in the trap word: SYS, CLEAR): allocate a nonrelocatable block (a0). */
trap_NewPtr:
NEWPTR:                 /* selector 64 (routine 16 of the table), through MMPROLOGUE (TheZone or SysZone) */
    movel #64,%sp@-
    movel 0x1ee8,%sp@-
    rts
NEWPTR_C:               /* 24-bit NewPtr: room low in the zone (A24MAKEPTRSPC), allocate (a1 = 0: nonrelocatable), clear it if asked */
    subal %a1,%a1
    jbsr A24MAKEPTRSPC
    jbsr A24ALLOCBK
    jbeq NEWPTR_20
    jbsr PTRZONE_10
    moveq #0,%d0
NEWPTR_1E:              /* exit */
    jbra NEWPTR_36
NEWPTR_20:              /* -108 (memFullErr) */
    moveq #-108,%d0
    jbra NEWPTR_1E
NEWPTR_24:              /* 32-bit NewPtr */
    subal %a1,%a1
    jbsr A32MAKEPTRSPC
    jbsr A32ALLOCBK
    jbeq NEWPTR_3C
    bsrw PTRZONE_10
NEWPTR_34:              /* no error */
    moveq #0,%d0
NEWPTR_36:              /* exit (MMEPILOGUE) */
    movel 0x1fe8,%sp@-
    rts
NEWPTR_3C:              /* -108 */
    moveq #-108,%d0
    jbra NEWPTR_36

/* _DisposPtr(a0): free a nonrelocatable block. */
trap_DisposPtr:
DISPOSEPTR:             /* selector 68 (routine 17 of the table), through MMPPROLOGUE (a pointer) */
    movel #68,%sp@-
    movel 0x1ee4,%sp@-
    rts
DISPOSEPTR_C:           /* 24-bit: not in a read-only zone (flag bit 0); free the block */
    btst #0,%fp@(22)	/* read-only zone? */
    jbne DISPOSEPTR_28
    jbsr A24FREEBK
    jbra NEWPTR_34
DISPOSEPTR_1A:          /* 32-bit */
    btst #0,%fp@(22)
    jbne DISPOSEPTR_28
    jbsr A32FREEBK
    jbra NEWPTR_34
DISPOSEPTR_28:          /* read-only zone: -99 (memROZErr) */
    moveq #-99,%d0
    jbra NEWPTR_36

/* _GetPtrSize(a0): its logical size (d0). */
trap_GetPtrSize:
GETPTRSIZE:             /* selector 72 (routine 18 of the table), through MMPPROLOGUE (a pointer) */
    movel #72,%sp@-
    movel 0x1ee4,%sp@-
    rts

GETPTRSIZE_C:           /* 24-bit */
    jbsr A24GETSIZE
    jbra NEWPTR_36
GETPTRSIZE_12:          /* 32-bit */
    jbsr A32GETSIZE
    jbra NEWPTR_36

/* _SetPtrSize(a0, d0): resize it in place (memFullErr if it cannot grow). */
trap_SetPtrSize:
SETPTRSIZE:             /* selector 76 (routine 19 of the table), through MMPPROLOGUE (a pointer) */
    movel #76,%sp@-
    movel 0x1ee4,%sp@-
    rts

SETPTRSIZE_C:           /* 24-bit */
    jbsr A24SETSIZE
    jbra NEWPTR_36
SETPTRSIZE_12:          /* 32-bit */
    jbsr A32SETSIZE
    jbra NEWPTR_36

/* _PtrZone(a0): the zone it is in. */
trap_PtrZone:
PTRZONE:                /* selector 80 (routine 20 of the table), through MMPPROLOGUE (a pointer) */
    movel #80,%sp@-
    movel 0x1ee4,%sp@-
    rts

PTRZONE_C:              /* a0 = the zone the prologue found */
    moveal %fp,%a0
    jbra NEWPTR_34

PTRZONE_10:             /* clear the new block if the trap word asked (bit 9: CLEAR) */
    btst #9,%d1	/* trap word bit 9: CLEAR */
    jbeq PTRZONE_24
    movel %a0,%sp@-
    addql #1,%d0
    lsrl #1,%d0
PTRZONE_1C:             /* clear a word */
    clrw %a0@+
    subql #1,%d0
    jbgt PTRZONE_1C
    moveal %sp@+,%a0
PTRZONE_24:             /* return */
    rts

/* _NewEmptyHandle: a master pointer with no block (a0). */
trap_NewEmptyHandle:
NEWEMPTYHANDLE:         /* selector 88 (routine 22 of the table), through MMPROLOGUE (TheZone or SysZone) */
    movel #88,%sp@-
    movel 0x1ee8,%sp@-
    rts
NEWEMPTYHANDLE_C:       /* 24-bit: a free master pointer */
    jbsr A24NEXTMASTER
    jbeq NWHANDLE_22
    jbra NEWEMPTYHANDLE_1A
NEWEMPTYHANDLE_14:      /* 32-bit */
    jbsr A32NEXTMASTER
    jbeq NWHANDLE_22
NEWEMPTYHANDLE_1A:      /* a0 = it, pointing nowhere (nil) */
    moveal %a1,%a0
    clrl %a0@
    moveq #0,%d0
    movel 0x1fe8,%sp@-
    rts

/* _NewHandle(d0, flags): allocate a relocatable block (a0 = handle). */
trap_NewHandle:
NWHANDLE:               /* selector 84 (routine 21 of the table), through MMPROLOGUE (TheZone or SysZone) */
    movel #84,%sp@-
    movel 0x1ee8,%sp@-
    rts
NWHANDLE_C:             /* 24-bit NewHandle: a master pointer, then the block (a1 = the master pointer) */
    jbsr A24NEXTMASTER
    jbne NWHANDLE_14
    jbra NWHANDLE_22
NWHANDLE_14:            /* allocate */
    jbsr A24ALLOCBK
    jbeq NWHANDLE_38
    jbra NWHANDLE_2C
NWHANDLE_1C:            /* 32-bit */
    jbsr A32NEXTMASTER
    jbne NWHANDLE_26
NWHANDLE_22:            /* no master pointer: -108 */
    moveq #-108,%d0
    jbra DSPOSEHANDLE_28
NWHANDLE_26:            /* allocate */
    jbsr A32ALLOCBK
    jbeq NWHANDLE_38
NWHANDLE_2C:            /* clear it if asked, a0 = the handle */
    jbsr PTRZONE_10
    moveal %a1,%a0
NWHANDLE_30:            /* no error */
    moveq #0,%d0
NWHANDLE_32:            /* exit (MMEPILOGUE) */
    movel 0x1fe8,%sp@-
    rts
NWHANDLE_38:            /* no room: -108, give the master pointer back */
    moveq #-108,%d0
    jbra DSPOSEHANDLE_24

/* _DisposHandle(a0): free the block and its master pointer. */
trap_DisposHandle:
DSPOSEHANDLE:           /* selector 92 (routine 23 of the table), through MMHPROLOGUE (a handle) */
    movel #92,%sp@-
    movel 0x1eec,%sp@-
    rts
DSPOSEHANDLE_C:         /* 24-bit: a block? free it as a pointer (which frees the master pointer) */
    jbne DISPOSEPTR_C
    jbra DSPOSEHANDLE_16
DSPOSEHANDLE_12:        /* 32-bit */
    jbne DISPOSEPTR_1A
DSPOSEHANDLE_16:        /* an empty handle: just the master pointer (not in a read-only zone) */
    movel %a1,%d0
    jbeq DSPOSEHANDLE_28
    btst #0,%fp@(22)
    jbne DSPOSEHANDLE_2C
    moveq #0,%d0
DSPOSEHANDLE_24:        /* back on the free list */
    jbsr RELEASEMP
DSPOSEHANDLE_28:        /* a0 = 0 */
    subal %a0,%a0
    jbra NWHANDLE_32
DSPOSEHANDLE_2C:        /* read-only zone: only clear it */
    clrl %a1@
    jbra NWHANDLE_30

/* _GetHandleSize(a0): its size (d0, negative = error). */
trap_GetHandleSize:
GETHANDLESIZE:          /* selector 96 (routine 24 of the table), through MMHPROLOGUE (a handle) */
    movel #96,%sp@-
    movel 0x1eec,%sp@-
    rts
GETHANDLESIZE_C:        /* 24-bit: nil or empty: -109 */
    jbeq SETHANDLESIZE_16
    jbsr A24GETSIZE
    jbra SETHANDLESIZE_1E
GETHANDLESIZE_14:       /* 32-bit */
    jbeq SETHANDLESIZE_16
    jbsr A32GETSIZE
    jbra SETHANDLESIZE_1E

/* _SetHandleSize(a0, d0): resize it, moving it (or others) if needed. */
trap_SetHandleSize:
SETHANDLESIZE:          /* selector 100 (routine 25 of the table), through MMHPROLOGUE (a handle) */
    movel #100,%sp@-
    movel 0x1eec,%sp@-
    rts
SETHANDLESIZE_C:        /* 24-bit */
    jbeq SETHANDLESIZE_16
    jbsr A24SETSIZE
    jbra SETHANDLESIZE_1E
SETHANDLESIZE_14:       /* 32-bit */
    jbne SETHANDLESIZE_1A
SETHANDLESIZE_16:       /* -109 (nilHandleErr) */
    moveq #-109,%d0
    jbra SETHANDLESIZE_1E
SETHANDLESIZE_1A:       /* resize */
    jbsr A32SETSIZE
SETHANDLESIZE_1E:       /* a0 = the handle, exit */
    moveal %a1,%a0
    jbra NWHANDLE_32

/* _HandleZone(a0): its zone. */
trap_HandleZone:
HANDLEZONE:             /* selector 104 (routine 26 of the table), through MMHPROLOGUE (a handle) */
    movel #104,%sp@-
    movel 0x1eec,%sp@-
    rts
HANDLEZONE_C:           /* a0 = the zone the prologue found */
    moveal %fp,%a0
    jbra NWHANDLE_30

/* _RecoverHandle(a0 = pointer to the block): its handle. */
trap_RecoverHandle:
RECOVERHANDLE:          /* selector 108 (routine 27 of the table), through MMRHPROLOGUE */
    movel #108,%sp@-
    movel 0x1fe0,%sp@-
    rts
RECOVERHANDLE_C:        /* 24-bit: the block header's relative handle + the zone = the master pointer; it must point to this block, else -115 (memBCErr). Bus errors are caught (RECOVERHANDLE_62) */
    moveal BusErrorVector,%a2
    lea %pc@(RECOVERHANDLE_62),%a3
    movel %a3,BusErrorVector
    moveal %a0@(-4),%a1
    movel %a2,BusErrorVector
    addal %fp,%a1
    movel %a1@,%d2
    andl Lo3Bytes,%d2
    movel %a0,%d1
    andl Lo3Bytes,%d1
    subl %d1,%d2
    jbeq RECOVERHANDLE_34
    moveq #-115,%d2	/* memBCErr */
RECOVERHANDLE_34:       /* exit */
    jbra RECOVERHANDLE_56
RECOVERHANDLE_36:       /* 32-bit */
    moveal BusErrorVector,%a2
    lea %pc@(RECOVERHANDLE_62),%a3
    movel %a3,BusErrorVector
    moveal %a0@(-4),%a1
    movel %a2,BusErrorVector
    addal %fp,%a1
    movel %a1@,%d2
    movel %a0,%d1
    subl %d1,%d2
    jbeq RECOVERHANDLE_56
    moveq #-115,%d2
RECOVERHANDLE_56:       /* MemErr, a0 = the handle, exit without error check */
    movew %d2,MemErr
    moveal %a1,%a0
    movel 0x1fec,%sp@-
    rts
RECOVERHANDLE_62:       /* bus error while reading the header: the read yields ROMBase (frame patched), continue */
    andiw #-257,%sp@(10)
    movel ROMBase,%sp@(44)
    rte

/* _EmptyHandle(a0): purge the block, keep the master pointer. */
trap_EmptyHandle:
EMPTYHANDLE:            /* selector 112 (routine 28 of the table), through MMHPROLOGUE (a handle) */
    movel #112,%sp@-
    movel 0x1eec,%sp@-
    rts

EMPTYHANDLE_C:          /* 24-bit: already empty: nothing to do */
    jbne EMPTYHANDLE_12
    moveq #0,%d0
    jbra EMPTYHANDLE_22
EMPTYHANDLE_12:         /* purge it (A24EH) */
    jbsr A24EH
    jbra EMPTYHANDLE_22
EMPTYHANDLE_18:         /* 32-bit */
    jbne EMPTYHANDLE_1E
    moveq #0,%d0
    jbra EMPTYHANDLE_22
EMPTYHANDLE_1E:         /* purge it */
    jbsr A32EH
EMPTYHANDLE_22:         /* exit */
    jbra SETHANDLESIZE_1E

/* _ReallocHandle(a0, d0): allocate a new block for an empty handle. */
trap_ReallocHandle:
REALLOCHANDLE:          /* selector 116 (routine 29 of the table), through MMHPROLOGUE (a handle) */
    movel #116,%sp@-
    movel 0x1eec,%sp@-
    rts

REALLOCHANDLE_C:        /* 24-bit ReallocHandle: empty it first (unless already empty; not in a read-only zone) */
    jbeq REALLOCHANDLE_20
    btst #0,%fp@(22)
    jbne REALLOCHANDLE_3C
    jbsr A24EH
    jbne SETHANDLESIZE_1E
    movel %d2,%d0
REALLOCHANDLE_20:       /* allocate a new block for the master pointer (the grow zone procedure is told which handle: GZRootHnd) */
    movel %a1,GZRootHnd
    clrl GZRootPtr
    jbsr A24ALLOCBK
    jbsr CLEARGZSTUFF
    movel %a0,%d2
    jbne NWHANDLE_2C
    moveq #-108,%d0
    jbra SETHANDLESIZE_1E
REALLOCHANDLE_3C:       /* read-only zone: only if the new size fits in the old block, else -99 */
    jbsr A24GETSIZE
    cmpl %d0,%d2
    jbhi REALLOCHANDLE_88
    moveq #-99,%d0
    jbra SETHANDLESIZE_1E
REALLOCHANDLE_4A:       /* 32-bit */
    jbeq REALLOCHANDLE_5E
    btst #0,%fp@(22)
    jbne REALLOCHANDLE_7A
    jbsr A32EH
    jbne SETHANDLESIZE_1E
    movel %d2,%d0
REALLOCHANDLE_5E:       /* allocate */
    movel %a1,GZRootHnd
    clrl GZRootPtr
    jbsr A32ALLOCBK
    jbsr CLEARGZSTUFF
    movel %a0,%d2
    jbne NWHANDLE_2C
    moveq #-108,%d0
    jbra SETHANDLESIZE_1E
REALLOCHANDLE_7A:       /* read-only zone */
    jbsr A32GETSIZE
    cmpl %d0,%d2
    jbhi REALLOCHANDLE_88
    moveq #-99,%d0
    jbra SETHANDLESIZE_1E
REALLOCHANDLE_88:       /* -99 (memROZErr) */
    moveq #-99,%d0
    jbra SETHANDLESIZE_1E

/* _HLock(a0): lock the block (it will not move). */
trap_HLock:
HLOCK:                  /* selector 120 (routine 30 of the table), through MMHPROLOGUE (a handle) */
    movel #120,%sp@-
    movel 0x1eec,%sp@-
    rts
HLOCK_C:                /* 24-bit: continues in MEMORYMGRPATCH */
    jbra MEMORYMGRPATCH
    nop
    braw HNOPURGE_1C
HLOCK_18:               /* 32-bit: continues in V32HLOCKPATCH */
    jbra V32HLOCKPATCH
    .short  0x0000, 0x0000	| 4080D646
    braw HNOPURGE_1C

/* _HUnlock(a0): unlock it. */
trap_HUnlock:
HUNLOCK:                /* selector 124 (routine 31 of the table), through MMHPROLOGUE (a handle) */
    movel #124,%sp@-
    movel 0x1eec,%sp@-
    rts
HUNLOCK_C:              /* 24-bit: clear the lock bit (7) of the master pointer's high byte */
    beqw HNOPURGE_20
    bclr #7,%a1@	/* lock bit */
    braw HNOPURGE_1C
HUNLOCK_18:             /* 32-bit: clear it in the block header (+1, a0 - 11) */
    jbeq HNOPURGE_20
    bclr #7,%a0@(-11)
    jbra HNOPURGE_1C

/* _HPurge(a0): mark it purgeable. */
trap_HPurge:
HPURGE:                 /* selector 128 (routine 32 of the table), through MMHPROLOGUE (a handle) */
    movel #128,%sp@-
    movel 0x1eec,%sp@-
    rts

HPURGE_C:               /* 24-bit: purgeable bit (6) */
    jbeq HNOPURGE_20
    bset #6,%a1@	/* purgeable bit */
    jbra HNOPURGE_1C
HPURGE_14:              /* 32-bit */
    jbeq HNOPURGE_20
    bset #6,%a0@(-11)
    jbra HNOPURGE_1C

/* _HNoPurge(a0): mark it not purgeable. */
trap_HNoPurge:
HNOPURGE:               /* selector 132 (routine 33 of the table), through MMHPROLOGUE (a handle) */
    movel #132,%sp@-
    movel 0x1eec,%sp@-
    rts

HNOPURGE_C:             /* 24-bit: clear the purgeable bit */
    jbeq HNOPURGE_20
    bclr #6,%a1@
    jbra HNOPURGE_1C
HNOPURGE_14:            /* 32-bit */
    jbeq HNOPURGE_20
    bclr #6,%a0@(-11)
HNOPURGE_1C:            /* no error */
    moveq #0,%d0
    jbra HNOPURGE_22
HNOPURGE_20:            /* nil or empty handle: -109 (nilHandleErr) */
    moveq #-109,%d0
HNOPURGE_22:            /* exit */
    movel 0x1fe8,%sp@-
    rts

/* _HSetRBit(a0): mark it a resource. */
trap_HSetRBit:
HRSRC:                  /* selector 136 (routine 34 of the table), through MMHPROLOGUE (a handle) */
    movel #136,%sp@-
    movel 0x1eec,%sp@-
    rts

HRSRC_C:                /* 24-bit: resource bit (5) */
    jbeq HNOPURGE_20
    bset #5,%a1@	/* resource bit */
    jbra HNOPURGE_1C
HRSRC_14:               /* 32-bit */
    jbeq HNOPURGE_20
    bset #5,%a0@(-11)
    jbra HNOPURGE_1C

/* _HClrRBit(a0): clear the resource mark. */
trap_HClrRBit:
HNORSRC:                /* selector 140 (routine 35 of the table), through MMHPROLOGUE (a handle) */
    movel #140,%sp@-
    movel 0x1eec,%sp@-
    rts

HNORSRC_C:              /* 24-bit: clear the resource bit */
    jbeq HNOPURGE_20
    bclr #5,%a1@
    jbra HNOPURGE_1C
HNORSRC_14:             /* 32-bit */
    jbeq HNOPURGE_20
    bclr #5,%a0@(-11)
    jbra HNOPURGE_1C

/* _HGetState(a0): its flags byte (lock, purge, resource) in d0. */
trap_HGetState:
HGETFLAGS:              /* selector 144 (routine 36 of the table), through MMHPROLOGUE (a handle) */
    movel #144,%sp@-
    movel 0x1eec,%sp@-
    rts
HGETFLAGS_C:            /* 24-bit: the master pointer's high byte */
    jbeq HNOPURGE_20
    moveq #0,%d0
    moveb %a1@,%d0
    jbra HGETFLAGS_1C
HGETFLAGS_14:           /* 32-bit: the header's flags byte */
    jbeq HNOPURGE_20
    moveq #0,%d0
    moveb %a0@(-11),%d0
HGETFLAGS_1C:           /* exit (d0 is not an error) */
    clrw MemErr
    movel 0x1fec,%sp@-
    rts

/* _HSetState(a0, d0): set them. */
trap_HSetState:
HSETFLAGS:              /* selector 148 (routine 37 of the table), through MMHPROLOGUE (a handle) */
    movel #148,%sp@-
    movel 0x1eec,%sp@-
    rts
HSETFLAGS_C:            /* 24-bit */
    jbeq HNOPURGE_20
    moveb %d0,%a1@
    jbra HNOPURGE_1C
HSETFLAGS_12:           /* 32-bit */
    jbeq HNOPURGE_20
    moveb %d0,%a0@(-11)
    jbra HNOPURGE_1C

/* _MoreMasters: allocate another block of master pointers. */
trap_MoreMasters:
MOREMASTERS:            /* selector 152 (routine 38 of the table), through MMMMPROLOGUE */
    movel #152,%sp@-
    movel 0x1fe4,%sp@-
    rts
MOREMASTERS_C:          /* 24-bit: allocate moreMast master pointers; -108 if not */
    moveq #0,%d0
    jbsr A24HMAKEMOREMASTERS
    jbne MOREMASTERS_16
    moveq #-108,%d0
MOREMASTERS_16:         /* exit (MMMMPROLOGUE kept only a6) */
    moveal %sp@+,%fp
    movew %d0,MemErr
    rts
MOREMASTERS_1E:         /* 32-bit */
    moveq #0,%d0
    jbsr A32HMAKEMOREMASTERS
    jbne MOREMASTERS_28
    moveq #-108,%d0
MOREMASTERS_28:         /* exit */
    moveal %sp@+,%fp
    movew %d0,MemErr
    rts

/* _StripAddress(d0): the address without the flag bits (24-bit mode: low 3 bytes). */
trap_StripAddress:
STRIPADDRESS:           /* 24-bit mode (0x1EFC bit 0 clear): keep the low 3 bytes */
    btst #0,0x1efc
    jbne STRIPADDRESS_C
    andl Lo3Bytes,%d0
STRIPADDRESS_C:         /* return */
    rts

/*
 _MoveHHi(a0): move a relocatable block as high in its zone as possible, so that it
 can stay locked without fragmenting the heap. The block above it must be free or
 movable; then, using a buffer on the stack (up to 1 KB more than the block, below
 the stack limit), the block's data is copied piece by piece into the highest free
 space while CompactMem makes room under it. Errors: -109 nilHandleErr, -117
 memLockedErr (it is locked).
*/
trap_MoveHHi:
MOVEHHI:                /* selector 156 (routine 39 of the table), through MMHPROLOGUE (a handle) */
    movel #156,%sp@-
    movel 0x1eec,%sp@-
    rts

MOVEHHI_C:              /* 24-bit: nil or empty handle: -109 */
    jbne MOVEHHI_14
    moveq #-109,%d0
MOVEHHI_10:             /* exit */
    jbra MOVEHHI_2E0
MOVEHHI_14:             /* locked: -117 (memLockedErr) */
    moveal %a1,%a4
    tstb %a4@
    jbpl MOVEHHI_1E
    moveq #-117,%d0	/* memLockedErr */
    jbra MOVEHHI_10
MOVEHHI_1E:             /* d7 = its data size; the block above must be free or an unlocked relocatable block; at the end of the zone or otherwise, nothing to do */
    moveal %fp@,%a3
    subql #8,%a0
    movel %a0@,%d1
    andl Lo3Bytes,%d1
    movel %d1,%d7
    subql #8,%d7
    moveq #0,%d0
    addal %d1,%a0
    cmpal %a3,%a0
    jbcc MOVEHHI_2E0
    tstb %a0@
    jbeq MOVEHHI_4A
    jbpl MOVEHHI_2E0
    moveal %a0@(4),%a0
    addal %fp,%a0
    tstb %a0@
    jbmi MOVEHHI_2E0
MOVEHHI_4A:             /* the buffer: as much stack as allowed (block + 1 KB, at least 1 KB) */
    movel %sp,%d1
    andl Lo3Bytes,%d1
    subl HighHeapMark,%d1
    movel #1024,%d2
    movel %d2,%d0
    addl %d7,%d0
    cmpl %d0,%d1
    jblt MOVEHHI_64
    movel %d0,%d1
MOVEHHI_64:             /* too little stack: give up (-1) */
    moveq #-1,%d0
    cmpl %d2,%d1
    jblt MOVEHHI_2E0
    subil #128,%d2
    subl %d2,%d1
    subal %d1,%sp
    subaw #22,%sp
    moveal %sp,%a5
    movel %d1,%a5@(8)
    movel TheZone,%a5@(18)
    movel %fp,TheZone
    moveal %a4@,%a0
    subqw #8,%a0
    movel %a0@,%a5@
    movel %a4@,%d0
    andl Lo3Bytes,%d0
    movel %d0,%a5@(12)
    moveb %a4@,%a5@(16)
    jbsr MOVEHHI_2E6
    tstb %a2@
    jbne MOVEHHI_D0
    movel %a2@,%d1
    movel %d1,%d0
    subql #8,%d0
    cmpl %d0,%d7
    jbhi MOVEHHI_D0
    subl %d7,%d0
    jbeq MOVEHHI_BA
    moveq #12,%d2
    cmpl %d2,%d0
    jbcs MOVEHHI_D0
MOVEHHI_BA:             /* the highest free block is big enough: copy the data there in one go */
    moveal %a4@,%a0
    moveal %a2,%a1
    addal %d1,%a1
MOVEHHI_C0:             /* copy, empty the old block */
    movel %d7,%d0
    subal %d0,%a1
    subl %d0,%fp@(12)
    _BlockMove
    moveal %a4,%a0
    _EmptyHandle
    jbra MOVEHHI_13A
MOVEHHI_D0:             /* else piece by piece: take a piece into the buffer, compact, find the highest free block */
    moveq #0,%d6
    jbsr MOVEHHI_352
    jbsr MOVEHHI_3D6
    jbsr MOVEHHI_2E6
MOVEHHI_DE:             /* copy the buffer to the top of that free block */
    movel %a2@,%d1
    movel %a5@(4),%d0
    lea %a5@(22),%a0
    moveal %a2,%a1
    addal %d1,%a1
    subal %d0,%a1
    addl %d0,%d6
    subl %d0,%fp@(12)
    _BlockMove
    tstl %d7
    jbeq MOVEHHI_13A
    movel %a1,%d0
    subl %a2,%d0
    jbeq MOVEHHI_116
    movel %d0,%d1
    subql #8,%d1
    subl %d7,%d1
    jbcs MOVEHHI_114
    jbeq MOVEHHI_110
    moveq #12,%d2
    cmpl %d1,%d2
    jbcc MOVEHHI_114
MOVEHHI_110:            /* the rest fits: copy it directly */
    moveal %a4@,%a0
    jbra MOVEHHI_C0
MOVEHHI_114:            /* the free space below */
    movel %d0,%a2@
MOVEHHI_116:            /* keep a nonrelocatable placeholder there while the next piece moves */
    moveml %a1@,%d4-%d5
    movel %fp,%a1@(4)
    movel %d6,%a1@
    moveb #64,%a1@
    movel %a1,%sp@-
    jbsr MOVEHHI_352
    jbsr MOVEHHI_3D6
    jbsr MOVEHHI_2E6
    moveal %sp@+,%a1
    moveml %d4-%d5,%a1@
    jbra MOVEHHI_DE
MOVEHHI_13A:            /* done: the moved data becomes the block (header in front) */
    subql #8,%a1
    subql #8,%fp@(12)
    movel %a1,%d0
    subl %a2,%d0
    jbeq MOVEHHI_148
    movel %d0,%a2@
MOVEHHI_148:            /* header, relative handle; the master pointer points to it; TheZone back, free the buffer */
    moveal %a1,%a2
    movel %a5@,%a2@+
    moveal %a4,%a0
    subal %fp,%a0
    movel %a0,%a2@+
    movel %a2,%a4@
    moveb %a5@(16),%a4@
    movel %a5@(18),TheZone
    moveq #0,%d0
    addal %a5@(8),%sp
    lea %sp@(22),%sp
    jbra MOVEHHI_2E0
MOVEHHI_16C:            /* 32-bit: nil or empty: -109 */
    jbne MOVEHHI_174
    moveq #-109,%d0
MOVEHHI_170:            /* exit */
    jbra MOVEHHI_2E0
MOVEHHI_174:            /* locked: -117 */
    moveal %a1,%a4
    tstb %a0@(-11)
    jbpl MOVEHHI_180
    moveq #-117,%d0
    jbra MOVEHHI_170
MOVEHHI_180:            /* the block above */
    moveal %fp@,%a3
    subaw #12,%a0
    movel %a0@(4),%d1
    movel %d1,%d7
    subil #12,%d7
    moveq #0,%d0
    addal %d1,%a0
    cmpal %a3,%a0
    jbcc MOVEHHI_2E0
    tstb %a0@
    jbeq MOVEHHI_1AC
    jbpl MOVEHHI_2E0
    tstb %a0@(1)
    jbmi MOVEHHI_2E0
MOVEHHI_1AC:            /* the buffer */
    movel %sp,%d1
    subl HighHeapMark,%d1
    movel #1024,%d2
    movel %d2,%d0
    addl %d7,%d0
    cmpl %d0,%d1
    jblt MOVEHHI_1C2
    movel %d0,%d1
MOVEHHI_1C2:            /* too little stack */
    moveq #-1,%d0
    cmpl %d2,%d1
    jblt MOVEHHI_2E0
    subil #128,%d2
    subl %d2,%d1
    subal %d1,%sp
    subaw #24,%sp
    moveal %sp,%a5
    movel %d1,%a5@(12)
    movel TheZone,%a5@(20)
    movel %fp,TheZone
    moveal %a4@,%a0
    subaw #12,%a0
    movel %a0@,%a5@
    movel %a4@,%a5@(16)
    movel %a0@(4),%a5@(4)
    jbsr MOVEHHI_320
    tstb %a2@
    jbne MOVEHHI_232
    movel %a2@(4),%d1
    movel %d1,%d0
    subil #12,%d0
    cmpl %d0,%d7
    jbhi MOVEHHI_232
    subl %d7,%d0
    jbeq MOVEHHI_21C
    moveq #16,%d2
    cmpl %d2,%d0
    jbcs MOVEHHI_232
MOVEHHI_21C:            /* room for it all at once */
    moveal %a4@,%a0
    moveal %a2,%a1
    addal %d1,%a1
MOVEHHI_222:            /* copy, empty the old block */
    movel %d7,%d0
    subal %d0,%a1
    subl %d0,%fp@(12)
    _BlockMove
    moveal %a4,%a0
    _EmptyHandle
    jbra MOVEHHI_2A8
MOVEHHI_232:            /* piece by piece */
    moveq #0,%d6
    jbsr MOVEHHI_390
    jbsr MOVEHHI_3D6
    jbsr MOVEHHI_320
MOVEHHI_240:            /* copy the buffer to the top of the free block */
    movel %a2@(4),%d1
    movel %a5@(8),%d0
    lea %a5@(24),%a0
    moveal %a2,%a1
    addal %d1,%a1
    subal %d0,%a1
    addl %d0,%d6
    subl %d0,%fp@(12)
    _BlockMove
    tstl %d7
    jbeq MOVEHHI_2A8
    movel %a1,%d0
    subl %a2,%d0
    jbeq MOVEHHI_282
    movel %d0,%d1
    subil #12,%d1
    subl %d7,%d1
    jbcs MOVEHHI_27C
    jbeq MOVEHHI_278
    moveq #16,%d2
    cmpl %d1,%d2
    jbcc MOVEHHI_27C
MOVEHHI_278:            /* the rest fits */
    moveal %a4@,%a0
    jbra MOVEHHI_222
MOVEHHI_27C:            /* the free space below */
    clrl %a2@
    movel %d0,%a2@(4)
MOVEHHI_282:            /* placeholder block while the next piece moves */
    moveml %a1@,%d3-%d5
    movel %fp,%a1@(8)
    movel %d6,%a1@(4)
    moveb #64,%a1@
    movel %a1,%sp@-
    jbsr MOVEHHI_390
    jbsr MOVEHHI_3D6
    jbsr MOVEHHI_320
    moveal %sp@+,%a1
    moveml %d3-%d5,%a1@
    jbra MOVEHHI_240
MOVEHHI_2A8:            /* done: the new block */
    subaw #12,%a1
    subil #12,%fp@(12)
    movel %a1,%d0
    subl %a2,%d0
    jbeq MOVEHHI_2C0
    clrl %a2@
    movel %d0,%a2@(4)
MOVEHHI_2C0:            /* header, relative handle, master pointer; TheZone back, free the buffer */
    moveal %a1,%a2
    movel %a5@,%a2@+
    movel %a5@(4),%a2@+
    moveal %a4,%a0
    subal %fp,%a0
    movel %a0,%a2@+
    movel %a2,%a4@
    movel %a5@(20),TheZone
    moveq #0,%d0
    addal %a5@(12),%sp
    lea %sp@(24),%sp
MOVEHHI_2E0:            /* exit (MMEPILOGUE) */
    movel 0x1fe8,%sp@-
    rts

MOVEHHI_2E6:            /* 24-bit: a2 = the highest free block above the block (or the zone start), stopping at locked or nonrelocatable blocks */
    movel %a4@,%d0
    jbeq MOVEHHI_2F4
    andl Lo3Bytes,%d0
    moveal %d0,%a0
    subqw #8,%a0
    jbra MOVEHHI_2F8
MOVEHHI_2F4:            /* (empty handle: from the first block) */
    lea %fp@(52),%a0
MOVEHHI_2F8:            /* next block: free or movable? */
    movel %a0@,%d1
    andl Lo3Bytes,%d1
    tstb %a0@
    jbeq MOVEHHI_30E
    jbpl MOVEHHI_318
    moveal %a0@(4),%a1
    addal %fp,%a1
    tstb %a1@
    jbmi MOVEHHI_318
MOVEHHI_30E:            /* remember it, next */
    moveal %a0,%a2
    addal %d1,%a0
    cmpal %a3,%a0
    jbcs MOVEHHI_2F8
    jbra MOVEHHI_31E
MOVEHHI_318:            /* immovable: only those above the block count */
    cmpal %a5@(12),%a0
    jbls MOVEHHI_30E
MOVEHHI_31E:            /* return */
    rts

MOVEHHI_320:            /* 32-bit: the same */
    movel %a4@,%d0
    jbeq MOVEHHI_32C
    moveal %d0,%a0
    subaw #12,%a0
    jbra MOVEHHI_330
MOVEHHI_32C:            /* (from the first block) */
    lea %fp@(52),%a0
MOVEHHI_330:            /* next block */
    movel %a0@(4),%d1
    tstb %a0@
    jbeq MOVEHHI_340
    jbpl MOVEHHI_34A
    tstb %a0@(1)
    jbmi MOVEHHI_34A
MOVEHHI_340:            /* remember it, next */
    moveal %a0,%a2
    addal %d1,%a0
    cmpal %a3,%a0
    jbcs MOVEHHI_330
    jbra MOVEHHI_350
MOVEHHI_34A:            /* immovable */
    cmpal %a5@(16),%a0
    jbls MOVEHHI_340
MOVEHHI_350:            /* return */
    rts

MOVEHHI_352:            /* 24-bit: copy the top piece of the block (at most the buffer) into the buffer and shrink the block by it */
    movel %a5@(8),%d0
    cmpl %d7,%d0
    jblt MOVEHHI_35C
    movel %d7,%d0
MOVEHHI_35C:            /* copy it */
    lea %a5@(22),%a1
    moveal %a4@,%a0
    addal %d7,%a0
    subal %d0,%a0
    subl %d0,%d7
    movel %d0,%a5@(4)
    movel %d0,%d1
    _BlockMove
    moveal %a4,%a0
    movel %d7,%d0
    jbne MOVEHHI_37A
    _EmptyHandle
    rts
MOVEHHI_37A:            /* the block's new size; the rest becomes free */
    moveal %a0@,%a0
    subqw #8,%a0
    moveb %a0@,%d2
    addql #8,%d0
    movel %d0,%a0@
    moveb %d2,%a0@
    addal %d0,%a0
    movel %d1,%a0@
    addl %d1,%fp@(12)
    rts

MOVEHHI_390:            /* 32-bit: the same */
    movel %a5@(12),%d0
    cmpl %d7,%d0
    jblt MOVEHHI_39A
    movel %d7,%d0
MOVEHHI_39A:            /* copy it */
    lea %a5@(24),%a1
    moveal %a4@,%a0
    addal %d7,%a0
    subal %d0,%a0
    subl %d0,%d7
    movel %d0,%a5@(8)
    movel %d0,%d1
    _BlockMove
    moveal %a4,%a0
    movel %d7,%d0
    jbne MOVEHHI_3B8
    _EmptyHandle
    rts
MOVEHHI_3B8:            /* the block's new size; the rest becomes free */
    moveal %a0@,%a0
    subaw #12,%a0
    addil #12,%d0
    movel %d0,%a0@(4)
    addal %d0,%a0
    clrl %a0@
    movel %d1,%a0@(4)
    addl %d1,%fp@(12)
    rts

MOVEHHI_3D6:            /* compact the zone */
    movel 0x1ef4,%d0
    _CompactMem
    rts

/*
 HEAPGUTS: the heap internals. ZCBUSERRHANDLER / DHBUSERRHANDLER: bus error handlers used
 while checking a zone / dereferencing a handle, so that a bad pointer or handle gives
 an error instead of a crash: they patch the exception frame (+10, +44) so that the
 faulting read yields 0 (zone check) or -1 (handle) and execution continues.
*/
HEAPGUTS:
ZCBUSERRHANDLER:        /* zone check: the read yields 0 */
    andiw #-257,%sp@(10)
    clrl %sp@(44)
    rte
DHBUSERRHANDLER:        /* handle: the read yields -1 */
    andiw #-257,%sp@(10)
    moveq #-1,%d0
    movel %d0,%sp@(44)
    rte

DHBUSERRHANDLER_E:      /* dereference handle a0 (bus errors caught by DEREFHANDLEPATCH): a1 = the handle, a0 = the master pointer's value (24-bit: low 3 bytes), d0 = it (Z: nil or empty) */
    jbsr DEREFHANDLEPATCH
    nop
    nop
    nop
    btst #0,0x1efc
    jbne DHBUSERRHANDLER_30
    movel %a0,%d0
    andl Lo3Bytes,%d0
    moveal %d0,%a0
    moveal %d0,%a1
    jbeq DHBUSERRHANDLER_38
    jbra DHBUSERRHANDLER_36
DHBUSERRHANDLER_30:     /* 32-bit: the whole address */
    movel %a0,%d0
    moveal %d0,%a1
    jbeq DHBUSERRHANDLER_38
DHBUSERRHANDLER_36:     /* a0 = *handle */
    moveal %a1@,%a0
DHBUSERRHANDLER_38:     /* bus error handler back */
    movel %a2,BusErrorVector
    movel %a0,%d0
    rts

DHBUSERRHANDLER_40:     /* the zone of block a0 (a pointer to its data): from the 24-bit header (8 bytes before) or the 32-bit one (12); free block: -111 (memWZErr) */
    btst #0,0x1efc
    jbne DHBUSERRHANDLER_74
    movel %a0,%d0
    andl Lo3Bytes,%d0
    moveal %d0,%a0
    subql #8,%a0
    tstb %a0@
    jbeq DHBUSERRHANDLER_70
    jbmi DHBUSERRHANDLER_64
    btst #6,%a0@
    jbeq DHBUSERRHANDLER_70
    moveal %a0@(4),%fp
    jbra DHBUSERRHANDLER_6A
DHBUSERRHANDLER_64:     /* relocatable: zone = master pointer address - the relative handle */
    moveal %a1,%fp
    subal %a0@(4),%fp
DHBUSERRHANDLER_6A:     /* check the zone */
    jbsr DHBUSERRHANDLER_9C
DHBUSERRHANDLER_6C:     /* a0 back to the data */
    addql #8,%a0
    rts
DHBUSERRHANDLER_70:     /* free block: -111 (memWZErr) */
    moveq #-111,%d0
    jbra DHBUSERRHANDLER_6C
DHBUSERRHANDLER_74:     /* 32-bit header */
    subaw #12,%a0
    tstb %a0@
    jbeq DHBUSERRHANDLER_98
    jbmi DHBUSERRHANDLER_8A
    btst #6,%a0@
    jbeq DHBUSERRHANDLER_98
    moveal %a0@(8),%fp
    jbra DHBUSERRHANDLER_90
DHBUSERRHANDLER_8A:     /* relocatable: from the master pointer */
    moveal %a1,%fp
    subal %a0@(8),%fp
DHBUSERRHANDLER_90:     /* check the zone */
    jbsr DHBUSERRHANDLER_9C
DHBUSERRHANDLER_92:     /* a0 back to the data */
    addaw #12,%a0
    rts
DHBUSERRHANDLER_98:     /* free block: -111 */
    moveq #-111,%d0
    jbra DHBUSERRHANDLER_92

DHBUSERRHANDLER_9C:     /* check zone a6: its first block (the master pointers, nonrelocatable) must name it (+56 in a 24-bit zone, +60 in a 32-bit one), else -113 (memAZErr); bus errors caught (ZONECHECKPATCH) */
    jbsr ZONECHECKPATCH
    nop
    nop
    nop
    btst #0,0x1efc
    jbeq DHBUSERRHANDLER_B6
    movel %fp@(60),%d0
    jbra DHBUSERRHANDLER_C6
DHBUSERRHANDLER_B6:     /* 24-bit zone: compare without the high byte */
    movel %fp,%d0
    andl Lo3Bytes,%d0
    moveal %d0,%fp
    movel %fp@(56),%d0
    andl Lo3Bytes,%d0
DHBUSERRHANDLER_C6:     /* bus error handler back; 0 or -113 */
    movel %a2,BusErrorVector
    subl %fp,%d0
    jbeq DHBUSERRHANDLER_D0
    moveq #-113,%d0
DHBUSERRHANDLER_D0:     /* return */
    rts

/*
 The prologues: each trap pushes its selector (4 * n) and jumps through one of them. They
 save d3-d7/a2-a6 and the mode byte (0x1EFC), find the zone (a6) and check it, then
 jump to the selector's entry in that zone's routine table (zone +32: 0x1E00 24-bit,
 0x1F00 32-bit). If the check fails they flip the mode (0x1EFC bit 0) and try once more
 in the other format; MMEPILOGUE restores it. MMPPROLOGUE: a pointer's zone (from its
 block header). MMHPROLOGUE: a handle's (dereferenced; a7 = the handle). MMNOPROLOGUE:
 no zone, no saved registers (by the mode only). MMMMPROLOGUE: TheZone, a6 saved.
 MMPROLOGUE: TheZone, or SysZone for SYS traps (trap word bit 10). MMRHPROLOGUE
 (RecoverHandle): the zone the pointer is in (system or application zone).
*/
MMPPROLOGUE:
    moveal %sp@+,%a1
    moveml %d3-%d7/%a2-%fp,%sp@-
    moveb 0x1efc,%sp@-
    moveal %a1,%a4
    clrw %sp@-
    movel %d0,%d2
MMPPROLOGUE_10:         /* the block's zone (a1 = 0: no master pointer) */
    subal %a1,%a1
    jbsr DHBUSERRHANDLER_40
    jbmi MMPPROLOGUE_2E
    addql #2,%sp
    movel %d2,%d0
    movel %fp@(32),%d3
    jbne MMPPROLOGUE_28
    movel #7680,%d3
MMPPROLOGUE_28:         /* the zone's routine table (0: 0x1E00) + the selector */
    addal %d3,%a4
    movel %a4@,%sp@-
    rts
MMPPROLOGUE_2E:         /* bad: try the other mode once, then the error */
    tstw %sp@+
    bnew MMHPROLOGUE_72
    bchg #0,0x1efc
    movew #1,%sp@-
    jbra MMPPROLOGUE_10
MMHPROLOGUE:            /* a handle's zone */
    moveal %sp@+,%a1
    moveml %d3-%d7/%a2-%fp,%sp@-
    moveb 0x1efc,%sp@-
    moveal %a1,%a4
    clrw %sp@-
    movel %d0,%d2
MMHPROLOGUE_10:         /* dereference the handle; nil or empty: the zone is found another way */
    moveal TheZone,%fp
    jbsr DHBUSERRHANDLER_E
    jbeq MMHPROLOGUE_3E
    cmpl MinusOne,%d0
    jbeq MMHPROLOGUE_60
    jbsr DHBUSERRHANDLER_40
MMHPROLOGUE_24:         /* bad zone? */
    jbmi MMHPROLOGUE_60
    addql #2,%sp
    movel %d2,%d0
    movel %fp@(32),%d3
    jbne MMHPROLOGUE_36
    movel #7680,%d3
MMHPROLOGUE_36:         /* the routine; d7 = the master pointer's value */
    addal %d3,%a4
    movel %a4@,%sp@-
    movel %a0,%d7
    rts
MMHPROLOGUE_3E:         /* an empty handle: the zone holding the master pointer: the application or system zone, by its address */
    movel %a1,%d0
    jbeq MMHPROLOGUE_5A
    cmpal ApplZone,%fp
    jbeq MMHPROLOGUE_52
    cmpal SysZone,%fp
    jbne MMHPROLOGUE_5A
    moveal ApplZone,%fp
MMHPROLOGUE_52:         /* above the application zone's start: in it, else the system zone */
    cmpl %fp,%d0
    jbhi MMHPROLOGUE_5A
    moveal SysZone,%fp
MMHPROLOGUE_5A:         /* check that zone */
    jbsr DHBUSERRHANDLER_9C
    jbra MMHPROLOGUE_24
MMHPROLOGUE_60:         /* bad: try the other mode once */
    tstw %sp@+
    jbne MMHPROLOGUE_72
    moveal %a1,%a0
    bchg #0,0x1efc
    movew #1,%sp@-
    jbra MMHPROLOGUE_10
MMHPROLOGUE_72:         /* the error (MMEPILOGUE_8) */
    jbra MMEPILOGUE_8
MMNOPROLOGUE:           /* by the mode bit only (no zone, nothing saved) */
    movel %a0,%sp@-
    moveal %sp@(4),%a0
    btst #0,0x1efc
    jbne MMNOPROLOGUE_14
    addaw #7680,%a0
    jbra MMNOPROLOGUE_18
MMNOPROLOGUE_14:        /* 32-bit table */
    addaw #7936,%a0
MMNOPROLOGUE_18:        /* the routine */
    movel %a0@,%sp@(4)
    moveal %sp@+,%a0
    rts
MMMMPROLOGUE:           /* TheZone's table, a6 saved */
    moveal %sp@+,%a1
    movel %fp,%sp@-
    moveal TheZone,%fp
    movel %fp@(32),%d0
    jbne MMMMPROLOGUE_14
    movel #7680,%d0
MMMMPROLOGUE_14:        /* the routine */
    addal %d0,%a1
    movel %a1@,%sp@-
    rts
MMPROLOGUE:             /* TheZone (SysZone for SYS) */
    moveal %sp@+,%a1
    moveml %d3-%d7/%a2-%fp,%sp@-
    moveb 0x1efc,%sp@-
    moveal %a1,%a4
    clrw %sp@-
    movel %d0,%d2
MMPROLOGUE_10:          /* TheZone, or SysZone for a SYS trap (bit 10) */
    moveal TheZone,%fp
    btst #10,%d1	/* SYS trap */
    jbeq MMPROLOGUE_1E
    moveal SysZone,%fp
MMPROLOGUE_1E:          /* check it */
    jbsr DHBUSERRHANDLER_9C
    jbmi MMPROLOGUE_3A
    addql #2,%sp
    movel %d2,%d0
    movel %fp@(32),%d3
    jbne MMPROLOGUE_34
    movel #7680,%d3
MMPROLOGUE_34:          /* the routine */
    addal %d3,%a4
    movel %a4@,%sp@-
    rts
MMPROLOGUE_3A:          /* bad: try the other mode once */
    tstw %sp@+
    jbne MMHPROLOGUE_72
    bchg #0,0x1efc
    movew #1,%sp@-
    jbra MMPROLOGUE_10
MMRHPROLOGUE:           /* RecoverHandle: the zone holding the pointer */
    moveal %sp@+,%a1
    moveml %d3-%d7/%a2-%fp,%sp@-
    moveb 0x1efc,%sp@-
    moveal %a1,%a4
    clrw %sp@-
    movel %d0,%d2
MMRHPROLOGUE_10:        /* which zone holds the pointer? */
    moveal TheZone,%fp
    btst #10,%d1
    jbne MMRHPROLOGUE_26
    cmpal SysZone,%fp
    jbeq MMRHPROLOGUE_2A
    cmpal ApplZone,%fp
    jbne MMRHPROLOGUE_42
MMRHPROLOGUE_26:        /* SYS: the system zone */
    moveal SysZone,%fp
MMRHPROLOGUE_2A:        /* above the application zone's start: the application zone */
    movel %a0,%d0
    btst #0,0x1efc
    jbne MMRHPROLOGUE_38
    andl Lo3Bytes,%d0
MMRHPROLOGUE_38:        /* compare */
    cmpl ApplZone,%d0
    jbls MMRHPROLOGUE_42
    moveal ApplZone,%fp
MMRHPROLOGUE_42:        /* check it */
    jbsr DHBUSERRHANDLER_9C
    jbmi MMRHPROLOGUE_5E
    addql #2,%sp
    movel %d2,%d0
    movel %fp@(32),%d3
    jbne MMRHPROLOGUE_58
    movel #7680,%d3
MMRHPROLOGUE_58:        /* the routine */
    addal %d3,%a4
    movel %a4@,%sp@-
    rts
MMRHPROLOGUE_5E:        /* bad: try the other mode once */
    tstw %sp@+
    jbne MMHPROLOGUE_72
    bchg #0,0x1efc
    movew #1,%sp@-
    jbra MMRHPROLOGUE_10

/* MMEPILOGUE / MMNOERREPILOGUE: common exit: MemErr, d0, restore the registers. */
MMEPILOGUE:
    clrw MemErr
    tstl %d0
    jbge MMNOERREPILOGUE
MMEPILOGUE_8:           /* MemErr = d0 */
    movew %d0,MemErr
MMNOERREPILOGUE:        /* restore the mode byte and registers */
    moveb %sp@+,0x1efc
    moveml %sp@+,%d3-%d7/%a2-%fp
    rts

/*
 A24MAKEBKF / A32MAKEBKF (a0 = block, d0 = size): make a free block: the 24-bit header is
 the size with a zero tag byte; the 32-bit one a zero tag long and the size.
 A32MAKEBKF_8 / _2C: the same merged with the free blocks after it, and made the
 allocation rover (+48).
*/
A24MAKEBKF:
    movel %d0,%a0@
    clrb %a0@
    rts

A32MAKEBKF:             /* 32-bit: a zero tag long, then the size */
    movel %d0,%a0@(4)
    clrl %a0@
    rts

A32MAKEBKF_8:           /* 24-bit: merge with the following free blocks */
    moveml %d0/%a1,%sp@-
    moveal %a0,%a1
    addal %d0,%a1
A32MAKEBKF_10:          /* next block free (and not the end)? add it */
    tstb %a1@
    jbne A32MAKEBKF_1E
    cmpal %fp@,%a1
    jbcc A32MAKEBKF_1E
    addl %a1@,%d0
    addal %a1@,%a1
    jbra A32MAKEBKF_10
A32MAKEBKF_1E:          /* the free block, the rover */
    movel %d0,%a0@
    clrb %a0@
    movel %a0,%fp@(48)
    moveml %sp@+,%d0/%a1
    rts

A32MAKEBKF_2C:          /* 32-bit */
    moveml %d0/%a1,%sp@-
    moveal %a0,%a1
    addal %d0,%a1
A32MAKEBKF_34:          /* next block free? */
    tstb %a1@
    jbne A32MAKEBKF_46
    cmpal %fp@,%a1
    jbcc A32MAKEBKF_46
    addl %a1@(4),%d0
    addal %a1@(4),%a1
    jbra A32MAKEBKF_34
A32MAKEBKF_46:          /* the free block, the rover */
    movel %d0,%a0@(4)
    clrl %a0@
    movel %a0,%fp@(48)
    moveml %sp@+,%d0/%a1
    rts

/*
 A24EH / A32EH (a1 = handle): EmptyHandle: free the block and leave the master pointer
 nil. -112 (memPurErr) if it is locked; in a read-only zone only the master pointer
 is cleared.
*/
A24EH:
    btst #7,%a1@	/* locked? */
    jbne A24EH_18
    btst #0,%fp@(22)
    jbne A24EH_1C
    subql #8,%a0
    jbsr A32EH_44
    addql #8,%a0
A24EH_14:               /* no error */
    moveq #0,%d0
A24EH_16:               /* return */
    rts
A24EH_18:               /* locked: -112 (memPurErr) */
    moveq #-112,%d0
    jbra A24EH_16
A24EH_1C:               /* read-only zone: just clear the master pointer */
    clrl %a1@
    jbra A24EH_14

A32EH:                  /* 32-bit EmptyHandle (lock bit in the header) */
    movel %a2,%sp@-
    moveal %a1@,%a2
    btst #7,%a2@(-11)
    jbne A32EH_24
    btst #0,%fp@(22)
    jbne A32EH_28
    subaw #12,%a0
    jbsr A32EH_5C
    addaw #12,%a0
A32EH_1E:               /* no error */
    moveq #0,%d0
A32EH_20:               /* return */
    moveal %sp@+,%a2
    rts
A32EH_24:               /* locked: -112 */
    moveq #-112,%d0
    jbra A32EH_20
A32EH_28:               /* read-only zone */
    clrl %a1@
    jbra A32EH_1E

A32EH_2C:               /* the zone's purge warning procedure (+40), if any, with a1 = the handle */
    tstl %fp@(40)
    jbeq A32EH_42
    moveml %d0-%d2/%a0-%a1,%sp@-
    movel %a1,%sp@-
    moveal %fp@(40),%a1
    jsr %a1@
    moveml %sp@+,%d0-%d2/%a0-%a1
A32EH_42:               /* return */
    rts

A32EH_44:               /* 24-bit: purge block a0 of handle a1: purge warning, nil master pointer, free block, more free bytes */
    movel %d0,%sp@-
    movel %a0@,%d0
    andl Lo3Bytes,%d0
    jbsr A32EH_2C
    clrl %a1@
    jbsr A24MAKEBKF
    jbsr ADJUSTFREE
    movel %sp@+,%d0
    rts

A32EH_5C:               /* 32-bit */
    movel %d0,%sp@-
    movel %a0@(4),%d0
    jbsr A32EH_2C
    clrl %a1@
    jbsr A32MAKEBKF
    jbsr ADJUSTFREE
    movel %sp@+,%d0
    rts

/*
 A24PURGEHEAP / A32PURGEHEAP (d0 = size): purge purgeable unlocked blocks until a run of
 free and purged space of d0 bytes exists, starting from where the last purge ended
 (purgePtr, +4) and wrapping around once; then compact. Zone flag bit 6: purge
 everything from the start.
*/
A24PURGEHEAP:
    moveml %d2/%a1-%a4,%sp@-
A24PURGEHEAP_4:         /* a3 = the end, a0 = the first block */
    moveal %fp@,%a3
    lea %fp@(52),%a0
    btst #6,%fp@(22)
    jbne A24PURGEHEAP_5C
    moveal %a0,%a2
    moveq #0,%d2
A24PURGEHEAP_16:        /* next block: free, or relocatable unlocked purgeable: part of the run */
    movel %a2@,%d1
    andl Lo3Bytes,%d1
    moveal %a2,%a4
    addal %d1,%a2
    tstb %a4@
    jbeq A24PURGEHEAP_3C
    jbpl A24PURGEHEAP_44
    moveal %a4@(4),%a1
    addal %fp,%a1
    tstb %a1@
    jbmi A24PURGEHEAP_44
    btst #6,%a1@
    jbeq A24PURGEHEAP_48
    cmpal %fp@(4),%a4
    jbcs A24PURGEHEAP_46
A24PURGEHEAP_3C:        /* add it to the run: big enough? */
    addl %d1,%d2
    cmpl %d0,%d2
    jbcs A24PURGEHEAP_48
    jbra A24PURGEHEAP_5E
A24PURGEHEAP_44:        /* immovable: the run starts again after it */
    moveq #0,%d2
A24PURGEHEAP_46:        /* start of the run */
    moveal %a2,%a0
A24PURGEHEAP_48:        /* to the end; then once more from the start */
    cmpal %a3,%a2
    jbcs A24PURGEHEAP_16
    lea %fp@(52),%a0
    cmpal %fp@(4),%a0
    jbeq A24PURGEHEAP_5C
    movel %a0,%fp@(4)
    jbra A24PURGEHEAP_4
A24PURGEHEAP_5C:        /* (everything) */
    moveal %a3,%a2
A24PURGEHEAP_5E:        /* purge the purgeable blocks of the run until there is room */
    movel %a0@,%d1
    andl Lo3Bytes,%d1
    tstb %a0@
    jbpl A24PURGEHEAP_80
    moveal %a0@(4),%a1
    addal %fp,%a1
    tstb %a1@
    jbmi A24PURGEHEAP_80
    btst #6,%a1@
    jbeq A24PURGEHEAP_80
    jbsr A32EH_44
    cmpl %d0,%d1
    jbcc A24PURGEHEAP_8A
A24PURGEHEAP_80:        /* next; purgePtr = here */
    addal %d1,%a0
    movel %a0,%fp@(4)
    cmpal %a2,%a0
    jbcs A24PURGEHEAP_5E
A24PURGEHEAP_8A:        /* compact */
    jbsr A24COMPACTHP
    moveml %sp@+,%d2/%a1-%a4
    rts

A32PURGEHEAP:           /* 32-bit PurgeMem internals */
    moveml %d2/%a1-%a4,%sp@-
A32PURGEHEAP_4:         /* a3 = the end, a0 = the first block */
    moveal %fp@,%a3
    lea %fp@(52),%a0
    btst #6,%fp@(22)
    jbne A32PURGEHEAP_58
    moveal %a0,%a2
    moveq #0,%d2
A32PURGEHEAP_16:        /* next block */
    movel %a2@(4),%d1
    moveal %a2,%a4
    addal %d1,%a2
    tstb %a4@
    jbeq A32PURGEHEAP_38
    jbpl A32PURGEHEAP_40
    tstb %a4@(1)
    jbmi A32PURGEHEAP_40
    btst #6,%a4@(1)
    jbeq A32PURGEHEAP_44
    cmpal %fp@(4),%a4
    jbcs A32PURGEHEAP_42
A32PURGEHEAP_38:        /* add it to the run */
    addl %d1,%d2
    cmpl %d0,%d2
    jbcs A32PURGEHEAP_44
    jbra A32PURGEHEAP_5A
A32PURGEHEAP_40:        /* immovable: start again after it */
    moveq #0,%d2
A32PURGEHEAP_42:        /* start of the run */
    moveal %a2,%a0
A32PURGEHEAP_44:        /* to the end; then once more from the start */
    cmpal %a3,%a2
    jbcs A32PURGEHEAP_16
    lea %fp@(52),%a0
    cmpal %fp@(4),%a0
    jbeq A32PURGEHEAP_58
    movel %a0,%fp@(4)
    jbra A32PURGEHEAP_4
A32PURGEHEAP_58:        /* (everything) */
    moveal %a3,%a2
A32PURGEHEAP_5A:        /* purge the run's purgeable blocks */
    movel %a0@(4),%d1
    tstb %a0@
    jbpl A32PURGEHEAP_7E
    moveal %a0@(8),%a1
    addal %fp,%a1
    tstb %a0@(1)
    jbmi A32PURGEHEAP_7E
    btst #6,%a0@(1)
    jbeq A32PURGEHEAP_7E
    jbsr A32EH_5C
    cmpl %d0,%d1
    jbcc A32PURGEHEAP_88
A32PURGEHEAP_7E:        /* next; purgePtr = here */
    addal %d1,%a0
    movel %a0,%fp@(4)
    cmpal %a2,%a0
    jbcs A32PURGEHEAP_5A
A32PURGEHEAP_88:        /* compact */
    jbsr A32COMPACTHP
    moveml %sp@+,%d2/%a1-%a4
A32PURGEHEAP_90:        /* return */
    rts

/*
 A24TOTEPURGEABLES / A32TOTEPURGEABLES: PurgeSpace: d0 = the free and purgeable bytes in
 all, a0 = the largest such contiguous run (computed by V24PURGESPACEPATCH).
*/
A24TOTEPURGEABLES:
    moveq #0,%d0
    movel %d0,%d1
    moveal %d0,%a0
    lea %fp@(52),%a1
A24TOTEPURGEABLES_A:    /* next block */
    cmpal %fp@,%a1
    jbcc A24TOTEPURGEABLES_34
    movel %a1@,%d2
    andl Lo3Bytes,%d2
    tstb %a1@
    jbeq A24TOTEPURGEABLES_2A
    jbpl A24TOTEPURGEABLES_30
    moveal %a1@(4),%a2
    addal %fp,%a2
    tstb %a2@
    jbmi A24TOTEPURGEABLES_30
    btst #6,%a2@
    jbeq A24TOTEPURGEABLES_2C
A24TOTEPURGEABLES_2A:   /* free or purgeable: count it */
    addl %d2,%d1
A24TOTEPURGEABLES_2C:   /* next */
    addal %d2,%a1
    jbra A24TOTEPURGEABLES_A
A24TOTEPURGEABLES_30:   /* immovable: the end of a run */
    pea %pc@(A24TOTEPURGEABLES_2C)
A24TOTEPURGEABLES_34:   /* the totals */
    jbsr V24PURGESPACEPATCH
    nop
    moveq #0,%d1
    rts

A32TOTEPURGEABLES:      /* 32-bit */
    moveq #0,%d0
    movel %d0,%d1
    moveal %d0,%a0
    lea %fp@(52),%a1
A32TOTEPURGEABLES_A:    /* next block */
    cmpal %fp@,%a1
    jbcc A32TOTEPURGEABLES_30
    movel %a1@(4),%d2
    tstb %a1@
    jbeq A32TOTEPURGEABLES_26
    jbpl A32TOTEPURGEABLES_2C
    tstb %a1@(1)
    jbmi A32TOTEPURGEABLES_2C
    btst #6,%a1@(1)
    jbeq A32TOTEPURGEABLES_28
A32TOTEPURGEABLES_26:   /* free or purgeable: count it */
    addl %d2,%d1
A32TOTEPURGEABLES_28:   /* next */
    addal %d2,%a1
    jbra A32TOTEPURGEABLES_A
A32TOTEPURGEABLES_2C:   /* immovable: the end of a run */
    pea %pc@(A32TOTEPURGEABLES_28)
A32TOTEPURGEABLES_30:   /* the totals */
    jbsr V32PURGESPACEPATCH
    nop
    moveq #0,%d1
    rts

A32TOTEPURGEABLES_3C:   /* call the zone's grow zone procedure (+44, STDGZ) with the size needed: d2 = the bytes it freed */
    movel %fp@(44),%d2
    jbeq A32TOTEPURGEABLES_56
    moveml %d0-%d1/%d3-%fp,%sp@-
    moveal %fp@(44),%a1
    clrl %sp@-
    movel %d0,%sp@-
    jsr %a1@
    movel %sp@+,%d2
    moveml %sp@+,%d0-%d1/%d3-%fp
A32TOTEPURGEABLES_56:   /* return */
    rts

/*
 A24BKCOMPACTS / A32BKCOMPACTS (d0 = size, d2 = may grow): get a free block of d0 bytes:
 compact; grow the application zone (towards ApplLimit); purge; then ask the grow zone
 procedure for more until it gives nothing. a0 = the block or 0.
 A32BKCOMPACTS_48 / _A4: find a free block of d0 bytes from the rover (+48; from the
 start if zone flag bit 5), merging free neighbours on the way, wrapping once.
*/
A24BKCOMPACTS:
    moveml %d0/%d2,%sp@-
    jbsr A24COMPACTHP
    cmpl %d1,%d0
    jbls A24BKCOMPACTS_3E
    cmpal ApplZone,%fp
    jbne A24BKCOMPACTS_22
    tstl %d2
    jbeq A24BKCOMPACTS_22
    jbsr A32ZONEADJUSTEND_26
    jbsr A24COMPACTHP
    cmpl %d1,%d0
    jbls A24BKCOMPACTS_3E
A24BKCOMPACTS_22:       /* purge */
    jbsr A24PURGEHEAP
    cmpl %d1,%d0
    jbls A24BKCOMPACTS_3E
    tstl %d2
    jbeq A24BKCOMPACTS_3E
A24BKCOMPACTS_2E:       /* the grow zone procedure, compact, again */
    jbsr A32TOTEPURGEABLES_3C
    jbsr A24COMPACTHP
    cmpl %d1,%d0
    jbls A24BKCOMPACTS_3E
    tstl %d2
    jbne A24BKCOMPACTS_2E
    subal %a0,%a0
A24BKCOMPACTS_3E:       /* d2 = the block */
    movel %a0,%d2
    moveml %sp@+,%d0/%d2
    rts

A32BKCOMPACTS:          /* 32-bit */
    moveml %d0/%d2,%sp@-
    jbsr A32COMPACTHP
    cmpl %d1,%d0
    jbls A32BKCOMPACTS_40
    cmpal ApplZone,%fp
    jbne A32BKCOMPACTS_22
    tstl %d2
    jbeq A32BKCOMPACTS_22
    jbsr A32ZONEADJUSTEND_72
    jbsr A32COMPACTHP
    cmpl %d1,%d0
    jbls A32BKCOMPACTS_40
A32BKCOMPACTS_22:       /* purge */
    jbsr A32PURGEHEAP
    cmpl %d1,%d0
    jbls A32BKCOMPACTS_40
    tstl %d2
    jbeq A32BKCOMPACTS_40
A32BKCOMPACTS_2E:       /* the grow zone procedure, compact, again */
    jbsr A32TOTEPURGEABLES_3C
    jbsr A32COMPACTHP
    cmpl %d1,%d0
    jbls A32BKCOMPACTS_40
    tstl %d2
    jbne A32BKCOMPACTS_2E
    subal %a0,%a0
A32BKCOMPACTS_40:       /* d2 = the block */
    movel %a0,%d2
    moveml %sp@+,%d0/%d2
    rts

A32BKCOMPACTS_48:       /* 24-bit: find a free block of d0 bytes from the rover */
    moveml %d1-%d2/%a1-%a2,%sp@-
    movel Lo3Bytes,%d2
    lea %fp@(48),%a2
    btst #5,%fp@(22)
    jbeq A32BKCOMPACTS_5E
    clrl %a2@
A32BKCOMPACTS_5E:       /* from the rover (or the first block) */
    movel %a2@,%d1
    moveal %d1,%a1
    jbne A32BKCOMPACTS_68
    lea %fp@(52),%a1
A32BKCOMPACTS_68:       /* to the end of the zone */
    cmpal %fp@,%a1
    jbcc A32BKCOMPACTS_92
    movel %a1@,%d1
    tstb %a1@
    jbeq A32BKCOMPACTS_78
A32BKCOMPACTS_72:       /* next block */
    andl %d2,%d1
    addal %d1,%a1
    jbra A32BKCOMPACTS_68
A32BKCOMPACTS_78:       /* a free block: merge the free ones after it */
    moveal %a1,%a0
    addal %d1,%a0
    tstb %a0@
    jbne A32BKCOMPACTS_8A
    cmpal %fp@,%a0
    jbcc A32BKCOMPACTS_8A
    addl %a0@,%d1
    movel %d1,%a1@
    jbra A32BKCOMPACTS_78
A32BKCOMPACTS_8A:       /* big enough? */
    cmpl %d0,%d1
    jbcs A32BKCOMPACTS_72
    moveal %a1,%a0
    jbra A32BKCOMPACTS_9C
A32BKCOMPACTS_92:       /* at the end: once more from the start */
    tstl %a2@
    jbeq A32BKCOMPACTS_9A
    clrl %a2@
    jbra A32BKCOMPACTS_5E
A32BKCOMPACTS_9A:       /* none */
    subal %a0,%a0
A32BKCOMPACTS_9C:       /* the rover = it */
    movel %a0,%a2@
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts

A32BKCOMPACTS_A4:       /* 32-bit */
    moveml %d1-%d2/%a1-%a2,%sp@-
    movel Lo3Bytes,%d2
    lea %fp@(48),%a2
    btst #5,%fp@(22)
    jbeq A32BKCOMPACTS_BA
    clrl %a2@
A32BKCOMPACTS_BA:       /* from the rover */
    movel %a2@,%d1
    moveal %d1,%a1
    jbne A32BKCOMPACTS_C4
    lea %fp@(52),%a1
A32BKCOMPACTS_C4:       /* to the end */
    cmpal %fp@,%a1
    jbcc A32BKCOMPACTS_F4
    movel %a1@(4),%d1
    tstb %a1@
    jbeq A32BKCOMPACTS_D4
A32BKCOMPACTS_D0:       /* next block */
    addal %d1,%a1
    jbra A32BKCOMPACTS_C4
A32BKCOMPACTS_D4:       /* merge the free ones after it */
    moveal %a1,%a0
    addal %d1,%a0
    tstb %a0@
    jbne A32BKCOMPACTS_EC
    cmpal %fp@,%a0
    jbcc A32BKCOMPACTS_EC
    addl %a0@(4),%d1
    movel %d1,%a1@(4)
    clrl %a1@
    jbra A32BKCOMPACTS_D4
A32BKCOMPACTS_EC:       /* big enough? */
    cmpl %d0,%d1
    jbcs A32BKCOMPACTS_D0
    moveal %a1,%a0
    jbra A32BKCOMPACTS_FE
A32BKCOMPACTS_F4:       /* once more from the start */
    tstl %a2@
    jbeq A32BKCOMPACTS_FC
    clrl %a2@
    jbra A32BKCOMPACTS_BA
A32BKCOMPACTS_FC:       /* none */
    subal %a0,%a0
A32BKCOMPACTS_FE:       /* the rover = it */
    movel %a0,%a2@
    moveml %sp@+,%d1-%d2/%a1-%a2
    rts

/*
 A24ALLOCBK / A32ALLOCBK (d0 = logical size, a1 = master pointer or 0): allocate a block:
 a free block of the physical size (A32BKCOMPACTS_48, else compact, purge, grow, grow
 zone procedure), split it, write the header (tag: 1 nonrelocatable, 2 relocatable;
 the relative handle or the zone; the size correction), set the master pointer.
 a0 = the data, 0 if no room.
*/
A24ALLOCBK:
    moveml %d0-%d5,%sp@-
    movel %d0,%d4
    jbsr thunk_FUN_408878ee
    jbsr A32BKCOMPACTS_48
    jbne A24ALLOCBK_1C
    moveq #-1,%d2
    jbsr A24BKCOMPACTS
    jbne A24ALLOCBK_1C
    subal %a0,%a0
    jbra A24ALLOCBK_46
A24ALLOCBK_1C:          /* d5 = the relative handle (master pointer - zone), tag 2 */
    movel %d0,%d2
    movel %a0@,%d0
    movel %a1,%d5
    jbeq A24ALLOCBK_2C
    subl %fp,%d5
    moveq #2,%d1
    moveq #-1,%d3
    jbra A24ALLOCBK_32
A24ALLOCBK_2C:          /* nonrelocatable: the zone, tag 1 */
    movel %fp,%d5
    moveq #1,%d1
    moveq #0,%d3
A24ALLOCBK_32:          /* split, header, size correction; the master pointer = the data */
    jbsr A32ALLOCBK_82
    movel %d5,%a0@(4)
    movel %d4,%d0
    jbsr A32ALLOCBK_52
    addql #8,%a0
    movel %a1,%d5
    jbeq A24ALLOCBK_46
    movel %a0,%a1@
A24ALLOCBK_46:          /* d0 = a0 */
    movel %a0,%d0
    moveml %sp@+,%d0-%d5
    rts

A32ALLOCBK:             /* 32-bit: the same with 12-byte headers */
    moveml %d0-%d5,%sp@-
    movel %d0,%d4
    jbsr thunk_FUN_40887926
    jbsr A32BKCOMPACTS_A4
    jbne A32ALLOCBK_1C
    moveq #-1,%d2
    jbsr A32BKCOMPACTS
    jbne A32ALLOCBK_1C
    subal %a0,%a0
    jbra A32ALLOCBK_4A
A32ALLOCBK_1C:          /* relocatable */
    movel %d0,%d2
    movel %a0@(4),%d0
    movel %a1,%d5
    jbeq A32ALLOCBK_2E
    subl %fp,%d5
    moveq #2,%d1
    moveq #-1,%d3
    jbra A32ALLOCBK_34
A32ALLOCBK_2E:          /* nonrelocatable */
    movel %fp,%d5
    moveq #1,%d1
    moveq #0,%d3
A32ALLOCBK_34:          /* split, header, size correction */
    jbsr A32ALLOCBK_C0
    movel %d5,%a0@(8)
    movel %d4,%d0
    jbsr A32ALLOCBK_6C
    addaw #12,%a0
    movel %a1,%d5
    jbeq A32ALLOCBK_4A
    movel %a0,%a1@
A32ALLOCBK_4A:          /* d0 = a0 */
    movel %a0,%d0
    moveml %sp@+,%d0-%d5
    rts

A32ALLOCBK_52:          /* 24-bit size correction: physical - 8 - logical, in the tag byte's low nibble */
    movel %d1,%sp@-
    movel %a0@,%d1
    andl Lo3Bytes,%d1
    subql #8,%d1
    subl %d0,%d1
    andib #15,%d1
    andib #0xc0,%a0@
    orb %d1,%a0@
    movel %sp@+,%d1
    rts

A32ALLOCBK_6C:          /* 32-bit: in the header's byte +3 */
    movel %d1,%sp@-
    movel %a0@(4),%d1
    subil #12,%d1
    subl %d0,%d1
    moveb %d1,%a0@(3)
    movel %sp@+,%d1
    rts

A32ALLOCBK_82:          /* 24-bit: take d2 bytes of free block a0; a rest of 12 bytes or more stays free: above the block, or below it for relocatable blocks when zone flag bit 15 is set; the tag */
    moveml %d0-%d2/%d4/%a1,%sp@-
    movel %d0,%d4
    subl %d2,%d0
    moveal %a0,%a1
    cmpil #12,%d0
    jbcs A32ALLOCBK_AA
    tstw %d3
    jbeq A32ALLOCBK_A2
    tstb %fp@(22)	/* zone flag bit 15: relocatable blocks at the top */
    jbpl A32ALLOCBK_A2
    addal %d0,%a1
    jbra A32ALLOCBK_A4
A32ALLOCBK_A2:          /* the block at the bottom, the rest above */
    addal %d2,%a0
A32ALLOCBK_A4:          /* the rest free */
    jbsr A24MAKEBKF
    jbra A32ALLOCBK_AC
A32ALLOCBK_AA:          /* too small to split: take it all */
    movel %d4,%d2
A32ALLOCBK_AC:          /* fewer free bytes; header = tag << 30 + size */
    movel %d2,%d0
    jbsr ADJUSTFREE_E
    moveal %a1,%a0
    rorl #2,%d1
    addl %d2,%d1
    movel %d1,%a0@
    moveml %sp@+,%d0-%d2/%d4/%a1
    rts

A32ALLOCBK_C0:          /* 32-bit: the same with 16 bytes */
    moveml %d0-%d2/%d4/%a1,%sp@-
    movel %d0,%d4
    subl %d2,%d0
    moveal %a0,%a1
    cmpil #16,%d0
    jbcs A32ALLOCBK_E8
    tstw %d3
    jbeq A32ALLOCBK_E0
    tstb %fp@(22)
    jbpl A32ALLOCBK_E0
    addal %d0,%a1
    jbra A32ALLOCBK_E2
A32ALLOCBK_E0:          /* the block at the bottom */
    addal %d2,%a0
A32ALLOCBK_E2:          /* the rest free */
    jbsr A32MAKEBKF
    jbra A32ALLOCBK_EA
A32ALLOCBK_E8:          /* take it all */
    movel %d4,%d2
A32ALLOCBK_EA:          /* fewer free bytes; the header */
    movel %d2,%d0
    jbsr ADJUSTFREE_E
    moveal %a1,%a0
    rorl #2,%d1
    movel %d2,%a0@(4)
    movel %d1,%a0@
    moveml %sp@+,%d0-%d2/%d4/%a1
    rts

A32ALLOCBK_100:         /* move a block's contents (d0 bytes, a0 to a1) through the vector at 0x4B8 */
    moveml %d0-%d2/%a0-%a2,%sp@-
    moveal 0x4b8,%a2
    jsr %a2@
    moveml %sp@+,%d0-%d2/%a0-%a2
    rts

/*
 A24COMPACTHP / A32COMPACTHP (d0 = size wanted): compact: slide unlocked relocatable
 blocks down over the free space, updating their master pointers. Unless zone flag
 bit 4 is set, a first pass only measures: if a run of free space of d0 bytes already
 exists, nothing moves. d1 = the largest free block, a0 = it (also the rover).
*/
A24COMPACTHP:
    moveml %d0/%d2-%d5/%a1-%a4,%sp@-
    movel %d0,%d3
    moveq #0,%d1
    lea %fp@(52),%a0
    jbra A24COMPACTHP_1A
A24COMPACTHP_E:         /* skip to the first free block */
    movel %a0@,%d4
    andl Lo3Bytes,%d4
    addal %d4,%a0
    cmpal %fp@,%a0
    jbcc A24COMPACTHP_1E
A24COMPACTHP_1A:        /* free? */
    tstb %a0@
    jbne A24COMPACTHP_E
A24COMPACTHP_1E:        /* d5: measure first (flag bit 4 clear) */
    btst #4,%fp@(22)
    seq %d5
    moveal %a0,%a2
A24COMPACTHP_28:        /* a1 = where moved blocks go, d2 = free run */
    moveal %a0,%a1
    moveq #0,%d2
A24COMPACTHP_2C:        /* next block */
    cmpal %fp@,%a0
    jbcc A24COMPACTHP_76
    movel %a0@,%d0
    andl Lo3Bytes,%d0
    tstb %a0@
    jbeq A24COMPACTHP_5A
    jbpl A24COMPACTHP_70
    moveal %a0@(4),%a3	/* relocatable: its master pointer */
    addal %fp,%a3
    tstb %a3@	/* locked? */
    jbmi A24COMPACTHP_70
    tstb %d5
    jbne A24COMPACTHP_6C
    lea %a1@(8),%a4
    moveb %a3@,%d4
    movel %a4,%a3@
    moveb %d4,%a3@
    jbsr A32ALLOCBK_100	/* slide the block down to a1 */
    addal %d0,%a1
    jbra A24COMPACTHP_6C
A24COMPACTHP_5A:        /* free: add to the run; big enough? (measuring: then stop) */
    addl %d0,%d2
    moveal %a1,%a3
    cmpl %d3,%d2
    jbcs A24COMPACTHP_6C
    tstb %d5
    jbeq A24COMPACTHP_78
    clrb %d5
    moveal %a2,%a0
    jbra A24COMPACTHP_28
A24COMPACTHP_6C:        /* next */
    addal %d0,%a0
    jbra A24COMPACTHP_2C
A24COMPACTHP_70:        /* immovable: close the run, skip to the next free block */
    jbsr A32COMPACTHP_82
    jbra A24COMPACTHP_E
A24COMPACTHP_76:        /* end of the zone */
    subal %a3,%a3
A24COMPACTHP_78:        /* close the run; the rover */
    jbsr A32COMPACTHP_82
    moveal %a3,%a0
    movel %a0,%fp@(48)
    moveml %sp@+,%d0/%d2-%d5/%a1-%a4
    rts

A32COMPACTHP:           /* 32-bit */
    moveml %d0/%d2-%d5/%a1-%a4,%sp@-
    movel %d0,%d3
    moveq #0,%d1
    lea %fp@(52),%a0
    jbra A32COMPACTHP_18
A32COMPACTHP_E:         /* skip to the first free block */
    movel %a0@(4),%d4
    addal %d4,%a0
    cmpal %fp@,%a0
    jbcc A32COMPACTHP_1C
A32COMPACTHP_18:        /* free? */
    tstb %a0@
    jbne A32COMPACTHP_E
A32COMPACTHP_1C:        /* measure first? */
    btst #4,%fp@(22)
    seq %d5
    moveal %a0,%a2
A32COMPACTHP_26:        /* a1 = where moved blocks go */
    moveal %a0,%a1
    moveq #0,%d2
A32COMPACTHP_2A:        /* next block */
    cmpal %fp@,%a0
    jbcc A32COMPACTHP_72
    movel %a0@(4),%d0
    tstb %a0@
    jbeq A32COMPACTHP_56
    jbpl A32COMPACTHP_6C
    moveal %a0@(8),%a3
    addal %fp,%a3
    tstb %a0@(1)
    jbmi A32COMPACTHP_6C
    tstb %d5
    jbne A32COMPACTHP_68
    lea %a1@(12),%a4
    movel %a4,%a3@
    jbsr A32ALLOCBK_100
    addal %d0,%a1
    jbra A32COMPACTHP_68
A32COMPACTHP_56:        /* free: add to the run */
    addl %d0,%d2
    moveal %a1,%a3
    cmpl %d3,%d2
    jbcs A32COMPACTHP_68
    tstb %d5
    jbeq A32COMPACTHP_74
    clrb %d5
    moveal %a2,%a0
    jbra A32COMPACTHP_26
A32COMPACTHP_68:        /* next */
    addal %d0,%a0
    jbra A32COMPACTHP_2A
A32COMPACTHP_6C:        /* immovable: close the run */
    bsrw A32COMPACTHP_94
    jbra A32COMPACTHP_E
A32COMPACTHP_72:        /* end of the zone */
    subal %a3,%a3
A32COMPACTHP_74:        /* close the run; the rover */
    jbsr A32COMPACTHP_94
    moveal %a3,%a0
    movel %a0,%fp@(48)
    moveml %sp@+,%d0/%d2-%d5/%a1-%a4
    rts

A32COMPACTHP_82:        /* 24-bit: close a run: a free block of d2 bytes at a1 (when moving); d1 = the largest */
    tstl %d2
    jbeq A32COMPACTHP_92
    tstb %d5
    jbne A32COMPACTHP_8C
    movel %d2,%a1@
A32COMPACTHP_8C:        /* largest? */
    cmpl %d2,%d1
    jbcc A32COMPACTHP_92
    movel %d2,%d1
A32COMPACTHP_92:        /* return */
    rts

A32COMPACTHP_94:        /* 32-bit */
    tstl %d2
    jbeq A32COMPACTHP_A8
    tstb %d5
    jbne A32COMPACTHP_A2
    clrl %a1@
    movel %d2,%a1@(4)
A32COMPACTHP_A2:        /* largest? */
    cmpl %d2,%d1
    jbcc A32COMPACTHP_A8
    movel %d2,%d1
A32COMPACTHP_A8:        /* return */
    rts

/* TOMAXLIMIT / A24MAXLIMIT / A32MAXLIMIT: grow the application zone to its limit. */
TOMAXLIMIT:             /* (raw words: d2 = the long at 0x10C minus the long at 0x322) */
    .short  0x2438, 0x010C, 0x94B8, 0x0322	| 4080E476

thunk_FUN_40887882:
A24MAXLIMIT:            /* 24-bit: in A24MAXLIMITPATCH (d1 = how far the zone may grow) */
    jbra A24MAXLIMITPATCH
    .long   0x00000000, 0x00000000, 0x00000000	| 4080E484
    .long   0x00000000, 0x00000000	| 4080E490

thunk_FUN_408878c0:
A32MAXLIMIT:            /* 32-bit: in A32MAXLIMITPATCH */
    jbra A32MAXLIMITPATCH
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4080E49E

/*
 A24ZONEADJUSTEND / A32ZONEADJUSTEND (a0 = new end): move the zone's end: a new trailer
 block there, the space between the old and new end a free block. A32ZONEADJUSTEND_26
 / _72: grow the application zone for d0 more bytes (in 1 KB steps) up to the limit.
*/
A24ZONEADJUSTEND:
    moveml %d0/%a0/%a2-%a3,%sp@-
    moveal %a0,%a3
    moveal %fp@,%a0
    movel %a3,%d0
    subl %a0,%d0
    movel #12,%a3@
    jbsr A24MAKEBKF
    jbsr ADJUSTFREE
    movel %a3,%fp@
    moveml %sp@+,%d0/%a0/%a2-%a3
    rts

A32ZONEADJUSTEND:       /* 32-bit: a 16-byte trailer */
    moveml %d0/%a0/%a2-%a3,%sp@-
    moveal %a0,%a3
    moveal %fp@,%a0
    movel %a3,%d0
    subl %a0,%d0
    clrl %a3@
    movel #16,%a3@(4)
    jbsr A32MAKEBKF
    jbsr ADJUSTFREE
    movel %a3,%fp@
    moveml %sp@+,%d0/%a0/%a2-%a3
    rts

A32ZONEADJUSTEND_26:    /* 24-bit: the new HeapEnd (at most ApplLimit's) */
    moveml %d0-%d3/%a0-%a2,%sp@-
    addil #1024,%d0
    andiw #-1024,%d0
    movel %d0,%d3
    movel ApplLimit,%d2
    jbsr thunk_FUN_40887882
    movel HeapEnd,%d2
    cmpl %d2,%d1
    jbls A32ZONEADJUSTEND_6C
    addl %d0,%d2
    jbcs A32ZONEADJUSTEND_6C
    cmpl %d2,%d1
    jbcs A32ZONEADJUSTEND_54
    movel %d2,%d1
    moveq #0,%d3
    jbra A32ZONEADJUSTEND_62
A32ZONEADJUSTEND_54:    /* only what is left */
    movel %d1,%d0
    subl HeapEnd,%d0
    cmpil #12,%d0
    jbcs A32ZONEADJUSTEND_6C
A32ZONEADJUSTEND_62:    /* HeapEnd = it, move the end */
    movel %d1,HeapEnd
    moveal %d1,%a0
    jbsr A24ZONEADJUSTEND
A32ZONEADJUSTEND_6C:    /* restore registers, return */
    moveml %sp@+,%d0-%d3/%a0-%a2
    rts

A32ZONEADJUSTEND_72:    /* 32-bit */
    moveml %d0-%d3/%a0-%a2,%sp@-
    addil #1024,%d0
    andiw #-1024,%d0
    movel %d0,%d3
    movel ApplLimit,%d2
    jbsr thunk_FUN_408878c0
    movel HeapEnd,%d2
    cmpl %d2,%d1
    jbls A32ZONEADJUSTEND_B8
    addl %d0,%d2
    jbcs A32ZONEADJUSTEND_B8
    cmpl %d2,%d1
    jbcs A32ZONEADJUSTEND_A0
    movel %d2,%d1
    moveq #0,%d3
    jbra A32ZONEADJUSTEND_AE
A32ZONEADJUSTEND_A0:    /* only what is left */
    movel %d1,%d0
    subl HeapEnd,%d0
    cmpil #16,%d0
    jbcs A32ZONEADJUSTEND_B8
A32ZONEADJUSTEND_AE:    /* HeapEnd = it, move the end */
    movel %d1,HeapEnd
    moveal %d1,%a0
    jbsr A32ZONEADJUSTEND
A32ZONEADJUSTEND_B8:    /* restore registers, return */
    moveml %sp@+,%d0-%d3/%a0-%a2
    rts

/* A24ACTUALS / A32ACTUALS: physical block size for a logical size (header, alignment). */
thunk_FUN_408878ee:
A24ACTUALS:
    jbra A24ACTUALSPATCH
    .long   0x00000000, 0x00000000, 0x00000000	| 4080E594
    .short  0x0000	| 4080E5A0

thunk_FUN_40887926:
A32ACTUALS:             /* 32-bit: in A32ACTUALSPATCH */
    jbra A32ACTUALSPATCH
    .long   0x00000000, 0x00000000	| 4080E5A8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4080E5B0

/*
 A24GETSIZE / A32GETSIZE (a0 = data): d0 = the logical size: physical size - header -
 size correction.
*/
A24GETSIZE:
    movel %d1,%sp@-
    subql #8,%a0
    moveq #15,%d1
    andb %a0@,%d1
    movel %a0@,%d0
    andl Lo3Bytes,%d0
    subql #8,%d0
    subl %d1,%d0
    addql #8,%a0
    movel %sp@+,%d1
    rts

A32GETSIZE:             /* 32-bit: size (+4) - 12 - the correction (+3) */
    movel %d1,%sp@-
    subaw #12,%a0
    moveq #0,%d1
    moveb %a0@(3),%d1
    movel %a0@(4),%d0
    subil #12,%d0
    subl %d1,%d0
    addaw #12,%a0
    movel %sp@+,%d1
    rts

/* CLEARGZSTUFF: clear the grow zone state. */
CLEARGZSTUFF:
    clrl GZRootHnd
    clrl GZRootPtr
    rts

/*
 A24SETSIZE / A32SETSIZE (a0 = data, a1 = handle or 0, d0 = new size): resize a block.
 Smaller: the rest becomes free (not in a read-only zone). Larger: use the free blocks
 after it; a relocatable block may also take free space before it (sliding down) or
 the space MakePtrSpc clears above it (moving or purging blocks); else a relocatable
 block is moved to a new place (A32MAKEPTRSPC_1AC). -108 if impossible. The grow zone
 procedure sees the block (GZRootHnd, GZRootPtr).
*/
A24SETSIZE:
    moveml %d1-%d6/%a0-%a3,%sp@-
    moveb %a1@,%sp@-
    jbsr A24SETSIZEPATCH
    jbsr A24GETSIZE
    cmpl %d0,%d1
    jbeq A24SETSIZE_16E
    moveal %a0,%a2
    subql #8,%a2
    movel %a2@,%d2
    andl Lo3Bytes,%d2
    movel %d2,%d4
    cmpl %d2,%d3
    jbeq A24SETSIZE_166
    jbcs A24SETSIZE_140
    movel %d3,%d5
    subl %d2,%d5
    movel %a1,GZRootHnd
    movel %a0,GZRootPtr
    moveal %a2,%a3
    addal %d4,%a3
    moveq #0,%d6
A24SETSIZE_3C:          /* the free blocks right after it */
    cmpal %fp@,%a3
    jbcc A24SETSIZE_4A
    tstb %a3@
    jbne A24SETSIZE_4A
    addl %a3@,%d6
    addal %a3@,%a3
    jbra A24SETSIZE_3C
A24SETSIZE_4A:          /* not enough after it: relocatable and unlocked? look below */
    subl %d6,%d5
    jbls A24SETSIZE_F0
    movel %a1,%d0
    jbeq A24SETSIZE_F0
    tstb %sp@
    jbmi A24SETSIZE_F0
    lea %fp@(52),%a3
A24SETSIZE_60:          /* the free blocks just before it (merged) */
    cmpal %a2,%a3
    jbcc A24SETSIZE_8E
    movel %a3@,%d0
    tstb %a3@
    jbeq A24SETSIZE_74
    andl Lo3Bytes,%d0
    addal %d0,%a3
    moveq #0,%d0
    jbra A24SETSIZE_60
A24SETSIZE_74:          /* a free block */
    moveal %a3,%a0
    moveq #0,%d0
A24SETSIZE_78:          /* merge the free blocks after it (keep the rover valid) */
    cmpal %fp@(48),%a3
    jbne A24SETSIZE_82
    movel %a0,%fp@(48)
A24SETSIZE_82:          /* add */
    addl %a3@,%d0
    addal %a3@,%a3
    tstb %a3@
    jbeq A24SETSIZE_78
    movel %d0,%a0@
    jbra A24SETSIZE_60
A24SETSIZE_8E:          /* enough below (more than a quarter of the need)? slide the block down */
    movel %d5,%d6
    lsrl #2,%d6
    cmpl %d6,%d0
    jbls A24SETSIZE_DE
    moveq #12,%d6
    cmpl %d5,%d6
    jbls A24SETSIZE_9E
    movel %d6,%d5
A24SETSIZE_9E:          /* keep a free block below if it is big */
    moveq #24,%d6
    addl %d5,%d6
    cmpl %d6,%d0
    jbcs A24SETSIZE_AE
    subl %d5,%d0
    movel %d0,%a0@
    addal %d0,%a0
    movel %d5,%d0
A24SETSIZE_AE:          /* the new place: master pointer, flags */
    movel %a0,%a1@
    addql #8,%a1@
    moveb %sp@,%a1@
    moveml %d0/%a1,%sp@-
    cmpal %fp@(48),%a2
    jbne A24SETSIZE_C2
    movel %a0,%fp@(48)
A24SETSIZE_C2:          /* move the data down */
    exg %a0,%a2
    moveal %a2,%a1
    movel %d4,%d0
    jbsr A32ALLOCBK_100
    moveal %a2,%a0
    addal %d4,%a0
    movel %sp@+,%a0@
    moveal %sp@+,%a1
    lea %a2@(8),%a0
    movel %a0,GZRootPtr
    jbra A24SETSIZE_F0
A24SETSIZE_DE:          /* the block after it is too small and not free? */
    moveal %a2,%a0
    addal %d4,%a0
    movel %a0@,%d0
    andl Lo3Bytes,%d0
    cmpl %d0,%d3
    jbcc A24SETSIZE_F0
    tstb %a0@
    jbne A24SETSIZE_108
A24SETSIZE_F0:          /* make room above (A32MAKEPTRSPC_7C), the block locked meanwhile */
    moveal %a2,%a0
    movel %d3,%d0
    subl %d2,%d0
    addal %d2,%a2
    bset #7,%a1@
    jbsr A32MAKEPTRSPC_7C
    bclr #7,%a1@
    movel %a2,%d4
    jbne A24SETSIZE_12A
A24SETSIZE_108:         /* no room: move the whole block elsewhere (relocatable, unlocked) */
    movel %a1,%d4
    jbeq A24SETSIZE_122
    tstb %sp@
    jbmi A24SETSIZE_122
    movel %d1,%d0
    bclr #6,%a1@
    jbsr A32MAKEPTRSPC_1AC
    moveb %sp@,%a1@
    jbsr CLEARGZSTUFF
    jbra A24SETSIZE_170
A24SETSIZE_122:         /* -108 */
    jbsr CLEARGZSTUFF
    moveq #-108,%d0
    jbra A24SETSIZE_170
A24SETSIZE_12A:         /* room: the block takes it */
    jbsr CLEARGZSTUFF
    movel %a2@,%d0
    movel %d0,%d4
    addl %d2,%d4
    moveal %a0,%a2
    moveb %a2@,%d5
    movel %d4,%a2@
    moveb %d5,%a2@
    jbsr ADJUSTFREE_E
A24SETSIZE_140:         /* the rest (12 bytes or more) becomes free */
    subl %d3,%d4
    cmpil #12,%d4
    jbcs A24SETSIZE_166
    btst #0,%fp@(22)
    jbne A24SETSIZE_178
    moveal %a2,%a0
    addal %d3,%a0
    moveb %a2@,%d5
    movel %d3,%a2@
    moveb %d5,%a2@
    movel %d4,%d0
    jbsr A24MAKEBKF
    jbsr ADJUSTFREE
A24SETSIZE_166:         /* the size correction */
    moveal %a2,%a0
    movel %d1,%d0
    jbsr A32ALLOCBK_52
A24SETSIZE_16E:         /* no error */
    moveq #0,%d0
A24SETSIZE_170:         /* the master pointer's flags back, return */
    moveb %sp@+,%a1@
    moveml %sp@+,%d1-%d6/%a0-%a3
    rts
A24SETSIZE_178:         /* read-only zone: -99 */
    moveq #-99,%d0
    jbra A24SETSIZE_170

A32SETSIZE:             /* 32-bit (flags kept from the header, +1) */
    moveml %d1-%d6/%a0-%a3,%sp@-
    moveal %a0,%a2
    moveb %a2@(-11),%sp@-
    jbsr A32SETSIZEPATCH
    nop
    jbsr A32GETSIZE
    cmpl %d0,%d1
    jbeq A32SETSIZE_192
    moveal %a0,%a2
    subaw #12,%a2
    movel %a2@(4),%d2
    movel %d2,%d4
    cmpl %d2,%d3
    jbeq A32SETSIZE_18A
    jbcs A32SETSIZE_168
    movel %d3,%d5
    subl %d2,%d5
    movel %a1,GZRootHnd
    movel %a0,GZRootPtr
    moveal %a2,%a3
    addal %d4,%a3
    moveq #0,%d6
A32SETSIZE_44:          /* the free blocks after it */
    cmpal %fp@,%a3
    jbcc A32SETSIZE_56
    tstb %a3@
    jbne A32SETSIZE_56
    addl %a3@(4),%d6
    addal %a3@(4),%a3
    jbra A32SETSIZE_44
A32SETSIZE_56:          /* look below */
    subl %d6,%d5
    jbls A32SETSIZE_10E
    movel %a1,%d0
    jbeq A32SETSIZE_10E
    tstb %sp@
    jbmi A32SETSIZE_10E
    lea %fp@(52),%a3
A32SETSIZE_6C:          /* the free blocks before it */
    cmpal %a2,%a3
    jbcc A32SETSIZE_A0
    tstb %a3@
    jbeq A32SETSIZE_7E
    movel %a3@(4),%d0
    addal %d0,%a3
    moveq #0,%d0
    jbra A32SETSIZE_6C
A32SETSIZE_7E:          /* a free block */
    moveal %a3,%a0
    moveq #0,%d0
A32SETSIZE_82:          /* merge */
    cmpal %fp@(48),%a3
    jbne A32SETSIZE_8C
    movel %a0,%fp@(48)
A32SETSIZE_8C:          /* add */
    addl %a3@(4),%d0
    addal %a3@(4),%a3
    tstb %a3@
    jbeq A32SETSIZE_82
    clrl %a0@
    movel %d0,%a0@(4)
    jbra A32SETSIZE_6C
A32SETSIZE_A0:          /* enough below? slide it down */
    movel %d5,%d6
    lsrl #2,%d6
    cmpl %d6,%d0
    jbls A32SETSIZE_FE
    moveq #16,%d6
    cmpl %d5,%d6
    jbls A32SETSIZE_B0
    movel %d6,%d5
A32SETSIZE_B0:          /* keep a free block below if big */
    moveq #32,%d6
    addl %d5,%d6
    cmpl %d6,%d0
    jbcs A32SETSIZE_C4
    subl %d5,%d0
    clrl %a0@
    movel %d0,%a0@(4)
    addal %d0,%a0
    movel %d5,%d0
A32SETSIZE_C4:          /* the new place */
    movel %a0,%a1@
    addil #12,%a1@
    moveb %sp@,%a0@(1)
    moveml %d0/%a1,%sp@-
    cmpal %fp@(48),%a2
    jbne A32SETSIZE_DE
    movel %a0,%fp@(48)
A32SETSIZE_DE:          /* move the data down */
    exg %a0,%a2
    moveal %a2,%a1
    movel %d4,%d0
    jbsr A32ALLOCBK_100
    moveal %a2,%a0
    addal %d4,%a0
    movel %sp@+,%a0@(4)
    clrl %a0@
    moveal %sp@+,%a1
    lea %a2@(12),%a0
    movel %a0,GZRootPtr
    jbra A32SETSIZE_10E
A32SETSIZE_FE:          /* the block after it too small and not free? */
    moveal %a2,%a0
    addal %d4,%a0
    movel %a0@(4),%d0
    cmpl %d0,%d3
    jbcc A32SETSIZE_10E
    tstb %a0@
    jbne A32SETSIZE_12C
A32SETSIZE_10E:         /* make room above, the block locked meanwhile */
    moveal %a2,%a0
    movel %d3,%d0
    subl %d2,%d0
    addal %d2,%a2
    moveal %a1@,%a3
    bset #7,%a3@(-11)
    jbsr A32MAKEPTRSPC_DE
    bclr #7,%a3@(-11)
    movel %a2,%d4
    jbne A32SETSIZE_154
A32SETSIZE_12C:         /* no room: move the block elsewhere */
    movel %a1,%d4
    jbeq A32SETSIZE_14C
    tstb %sp@
    jbmi A32SETSIZE_14C
    movel %d1,%d0
    moveal %a1@,%a3
    bclr #6,%a3@(-11)
    jbsr A32MAKEPTRSPC_204
    moveb %sp@,%a3@(-11)
    jbsr CLEARGZSTUFF
    jbra A32SETSIZE_194
A32SETSIZE_14C:         /* -108 */
    jbsr CLEARGZSTUFF
    moveq #-108,%d0
    jbra A32SETSIZE_194
A32SETSIZE_154:         /* room: take it */
    jbsr CLEARGZSTUFF
    movel %a2@(4),%d0
    movel %d0,%d4
    addl %d2,%d4
    moveal %a0,%a2
    movel %d4,%a2@(4)
    jbsr ADJUSTFREE_E
A32SETSIZE_168:         /* the rest (16 bytes or more) becomes free */
    subl %d3,%d4
    cmpil #16,%d4
    jbcs A32SETSIZE_18A
    btst #0,%fp@(22)
    jbne A32SETSIZE_1A0
    moveal %a2,%a0
    addal %d3,%a0
    movel %d3,%a2@(4)
    movel %d4,%d0
    jbsr A32MAKEBKF
    jbsr ADJUSTFREE
A32SETSIZE_18A:         /* the size correction */
    moveal %a2,%a0
    movel %d1,%d0
    jbsr A32ALLOCBK_6C
A32SETSIZE_192:         /* no error */
    moveq #0,%d0
A32SETSIZE_194:         /* the flags back, return */
    moveal %a1@,%a3
    moveb %sp@+,%a3@(-11)
    moveml %sp@+,%d1-%d6/%a0-%a3
    rts
A32SETSIZE_1A0:         /* read-only zone: -99 */
    moveq #-99,%d0
    jbra A32SETSIZE_194

/*
 ADJUSTFREE (d0): zcbFree += d0; ADJUSTFREE_E: -= d0. An overflow is system error 33
 (negZcbFreeErr: the heap is damaged).
*/
ADJUSTFREE:
    addl %d0,%fp@(12)
    jbcs ADJUSTFREE_8
    rts
ADJUSTFREE_8:           /* system error 33 (negZcbFreeErr) */
    moveq #33,%d0	/* system error 33 */
    _SysError
    rts

ADJUSTFREE_E:           /* zcbFree -= d0 */
    subl %d0,%fp@(12)
    jbcs ADJUSTFREE_16
    rts
ADJUSTFREE_16:          /* system error 33 (negZcbFreeErr) */
    moveq #33,%d0
    _SysError

/*
 A24NEXTMASTER / A32NEXTMASTER: a1 = a free master pointer from the zone's list (+8),
 making more if the list is empty. Z set if none.
*/
A24NEXTMASTER:
    moveml %d0/%a0,%sp@-
    moveal %fp@(8),%a1
    movel %a1,%d0
    jbne A24NEXTMASTER_10
    jbsr A24HMAKEMOREMASTERS
    jbeq A24NEXTMASTER_16
A24NEXTMASTER_10:       /* take it off the list */
    movel %a1@,%fp@(8)
    movel %a1,%d0
A24NEXTMASTER_16:       /* restore registers, return */
    moveml %sp@+,%d0/%a0
    rts

A32NEXTMASTER:          /* 32-bit */
    moveml %d0/%a0,%sp@-
    moveal %fp@(8),%a1
    movel %a1,%d0
    jbne A32NEXTMASTER_10
    jbsr A32HMAKEMOREMASTERS
    jbeq A32NEXTMASTER_16
A32NEXTMASTER_10:       /* take it off the list */
    movel %a1@,%fp@(8)
    movel %a1,%d0
A32NEXTMASTER_16:       /* restore registers, return */
    moveml %sp@+,%d0/%a0
    rts

/*
 A24HMAKEMOREMASTERS / A32HMAKEMOREMASTERS: a nonrelocatable block of moreMast (+20; 32
 if 0) master pointers, low in the zone, all put on the free list. a1 = the last.
*/
A24HMAKEMOREMASTERS:
    moveml %d0-%d1/%a0,%sp@-
    movew %fp@(20),%d0
    extl %d0
    jbgt A24HMAKEMOREMASTERS_E
    moveq #32,%d0
A24HMAKEMOREMASTERS_E:  /* 4 bytes each */
    movel %d0,%d1
    asll #2,%d0
    jbsr A24MAKEPTRSPC
    subal %a1,%a1
    jbsr A24ALLOCBK
    jbeq A24HMAKEMOREMASTERS_28
    moveal %a0,%a1
A24HMAKEMOREMASTERS_1E: /* each on the free list */
    jbsr RELEASEMP
    addql #4,%a1
    subqw #1,%d1
    jbne A24HMAKEMOREMASTERS_1E
    subql #4,%a1
A24HMAKEMOREMASTERS_28: /* d0 = a1 (0: no room) */
    movel %a1,%d0
    moveml %sp@+,%d0-%d1/%a0
    rts

A32HMAKEMOREMASTERS:    /* 32-bit */
    moveml %d0-%d1/%a0,%sp@-
    movew %fp@(20),%d0
    extl %d0
    jbgt A32HMAKEMOREMASTERS_E
    moveq #32,%d0
A32HMAKEMOREMASTERS_E:  /* 4 bytes each */
    movel %d0,%d1
    asll #2,%d0
    jbsr A32MAKEPTRSPC
    subal %a1,%a1
    jbsr A32ALLOCBK
    jbeq A32HMAKEMOREMASTERS_2A
    moveal %a0,%a1
A32HMAKEMOREMASTERS_20: /* each on the free list */
    jbsr RELEASEMP
    addql #4,%a1
    subqw #1,%d1
    jbne A32HMAKEMOREMASTERS_20
    subql #4,%a1
A32HMAKEMOREMASTERS_2A: /* d0 = a1 */
    movel %a1,%d0
    moveml %sp@+,%d0-%d1/%a0
    rts

/* RELEASEMP: return a master pointer to the free list. */
RELEASEMP:
    movel %fp@(8),%a1@
    movel %a1,%fp@(8)
    rts

/*
 A24MAKEPTRSPC / A32MAKEPTRSPC (d0 = size): make room for a nonrelocatable block as low
 as possible: find the lowest run of free, movable or purgeable blocks of d0 bytes and
 clear it (A32MAKEPTRSPC_7C: movable blocks are moved higher, purgeable ones purged if
 they cannot move); in the application zone, grow the zone once if needed. a2 = the
 free block, 0 if none.
*/
A24MAKEPTRSPC:
    moveml %d0-%d4/%a0-%a1/%a3-%a4,%sp@-
    jbsr thunk_FUN_408878ee
    moveal %fp,%a4
    cmpal ApplZone,%fp
    seq %d3
A24MAKEPTRSPC_10:       /* from the first block */
    lea %a4@(52),%a0
    moveal %fp@,%a3
    moveal %a0,%a2
    moveq #0,%d2
A24MAKEPTRSPC_1A:       /* next block: free, or relocatable unlocked? */
    movel %a0@,%d1
    andl Lo3Bytes,%d1
    tstb %a0@
    jbeq A24MAKEPTRSPC_30
    jbpl A24MAKEPTRSPC_6C
    moveal %a0@(4),%a1
    addal %fp,%a1
    tstb %a1@
    jbmi A24MAKEPTRSPC_6C
A24MAKEPTRSPC_30:       /* add to the run: big enough? clear it */
    addl %d1,%d2
    addal %d1,%a0
    cmpl %d0,%d2
    jbcs A24MAKEPTRSPC_72
    jbsr A32MAKEPTRSPC_7C
    movel %a2,%d2
    jbne A24MAKEPTRSPC_66
    lea %a4@(52),%a2
A24MAKEPTRSPC_44:       /* cleared: find the free block now at the run's place */
    movel %a2@,%d1
    andl Lo3Bytes,%d1
    addal %d1,%a2
    tstb %a2@
    jbpl A24MAKEPTRSPC_5A
    moveal %a2@(4),%a1
    addal %fp,%a1
    tstb %a1@
    jbpl A24MAKEPTRSPC_5E
A24MAKEPTRSPC_5A:       /* past it? */
    cmpal %a0,%a2
    jbhi A24MAKEPTRSPC_62
A24MAKEPTRSPC_5E:       /* to the end */
    cmpal %a3,%a2
    jbcs A24MAKEPTRSPC_44
A24MAKEPTRSPC_62:       /* a0 = there, try again from it */
    moveal %a2,%a0
    subal %a2,%a2
A24MAKEPTRSPC_66:       /* done? */
    movel %a2,%d2
    jbne A24MAKEPTRSPC_82
    jbra A24MAKEPTRSPC_6E
A24MAKEPTRSPC_6C:       /* immovable: the run starts after it */
    addal %d1,%a0
A24MAKEPTRSPC_6E:       /* start of a run */
    moveal %a0,%a2
    moveq #0,%d2
A24MAKEPTRSPC_72:       /* to the end; then grow the application zone once */
    cmpal %a3,%a0
    jbcs A24MAKEPTRSPC_1A
    addqb #1,%d3
    jbne A24MAKEPTRSPC_80
    jbsr A32ZONEADJUSTEND_26
    jbra A24MAKEPTRSPC_10
A24MAKEPTRSPC_80:       /* no room: a2 = 0 */
    subal %a2,%a2
A24MAKEPTRSPC_82:       /* restore registers, return */
    moveml %sp@+,%d0-%d4/%a0-%a1/%a3-%a4
    rts

A32MAKEPTRSPC:          /* 32-bit */
    moveml %d0-%d4/%a0-%a1/%a3-%a4,%sp@-
    jbsr thunk_FUN_40887926
    moveal %fp,%a4
    cmpal ApplZone,%fp
    seq %d3
A32MAKEPTRSPC_10:       /* from the first block */
    lea %a4@(52),%a0
    moveal %fp@,%a3
    moveal %a0,%a2
    moveq #0,%d2
A32MAKEPTRSPC_1A:       /* next block */
    movel %a0@(4),%d1
    tstb %a0@
    jbeq A32MAKEPTRSPC_2A
    jbpl A32MAKEPTRSPC_60
    tstb %a0@(1)
    jbmi A32MAKEPTRSPC_60
A32MAKEPTRSPC_2A:       /* add to the run; clear it */
    addl %d1,%d2
    addal %d1,%a0
    cmpl %d0,%d2
    jbcs A32MAKEPTRSPC_66
    jbsr A32MAKEPTRSPC_DE
    movel %a2,%d2
    jbne A32MAKEPTRSPC_5A
    lea %a4@(52),%a2
A32MAKEPTRSPC_3E:       /* find the free block at the run's place */
    movel %a2@(4),%d1
    addal %d1,%a2
    tstb %a2@
    jbpl A32MAKEPTRSPC_4E
    tstb %a2@(1)
    jbpl A32MAKEPTRSPC_52
A32MAKEPTRSPC_4E:       /* past it? */
    cmpal %a0,%a2
    jbhi A32MAKEPTRSPC_56
A32MAKEPTRSPC_52:       /* to the end */
    cmpal %a3,%a2
    jbcs A32MAKEPTRSPC_3E
A32MAKEPTRSPC_56:       /* try again from it */
    moveal %a2,%a0
    subal %a2,%a2
A32MAKEPTRSPC_5A:       /* done? */
    movel %a2,%d2
    jbne A32MAKEPTRSPC_76
    jbra A32MAKEPTRSPC_62
A32MAKEPTRSPC_60:       /* immovable */
    addal %d1,%a0
A32MAKEPTRSPC_62:       /* start of a run */
    moveal %a0,%a2
    moveq #0,%d2
A32MAKEPTRSPC_66:       /* to the end; grow once */
    cmpal %a3,%a0
    jbcs A32MAKEPTRSPC_1A
    addqb #1,%d3
    jbne A32MAKEPTRSPC_74
    jbsr A32ZONEADJUSTEND_72
    jbra A32MAKEPTRSPC_10
A32MAKEPTRSPC_74:       /* no room */
    subal %a2,%a2
A32MAKEPTRSPC_76:       /* restore registers, return */
    moveml %sp@+,%d0-%d4/%a0-%a1/%a3-%a4
    rts

A32MAKEPTRSPC_7C:       /* 24-bit: clear d0 bytes from block a2: move each relocatable unlocked block out (elsewhere in the zone), or purge it if it cannot move and is purgeable; merge into one free block */
    moveml %d0-%d3/%a0-%a1/%a3,%sp@-
    movel %d0,%d1
    moveal %a2,%a3
    moveq #0,%d3
A32MAKEPTRSPC_86:       /* enough? the end? an immovable block? */
    cmpl %d1,%d3
    jbcc A32MAKEPTRSPC_C6
    cmpal %fp@,%a3
    jbcc A32MAKEPTRSPC_C6
    tstb %a3@
    jbeq A32MAKEPTRSPC_B2
    jbpl A32MAKEPTRSPC_C6
    moveal %a3@(4),%a1
    addal %fp,%a1
    moveb %a1@,%d2
    jbmi A32MAKEPTRSPC_C6
    jbsr A32MAKEPTRSPC_146
    jbeq A32MAKEPTRSPC_B2
    btst #6,%d2
    jbeq A32MAKEPTRSPC_C6
    moveal %a1@,%a0
    subql #8,%a0
    jbsr A32EH_44
A32MAKEPTRSPC_B2:       /* free now: add it */
    moveal %a3,%a0
    movel %a0@,%d0
    cmpal %fp@(48),%a0
    jbne A32MAKEPTRSPC_C0
    clrl %fp@(48)
A32MAKEPTRSPC_C0:       /* next */
    addl %d0,%d3
    addal %d0,%a3
    jbra A32MAKEPTRSPC_86
A32MAKEPTRSPC_C6:       /* the free block */
    andl Lo3Bytes,%d3
    jbeq A32MAKEPTRSPC_CE
    movel %d3,%a2@
A32MAKEPTRSPC_CE:       /* not enough: a2 = 0 */
    cmpl %d1,%d3
    jbcc A32MAKEPTRSPC_D4
    subal %a2,%a2
A32MAKEPTRSPC_D4:       /* rover reset */
    clrl %fp@(48)
    moveml %sp@+,%d0-%d3/%a0-%a1/%a3
    rts

A32MAKEPTRSPC_DE:       /* 32-bit */
    moveml %d0-%d3/%a0-%a1/%a3,%sp@-
    movel %d0,%d1
    moveal %a2,%a3
    moveq #0,%d3
A32MAKEPTRSPC_E8:       /* enough? the end? immovable? */
    cmpl %d1,%d3
    jbcc A32MAKEPTRSPC_12C
    cmpal %fp@,%a3
    jbcc A32MAKEPTRSPC_12C
    tstb %a3@
    jbeq A32MAKEPTRSPC_116
    jbpl A32MAKEPTRSPC_12C
    moveal %a3@(8),%a1
    addal %fp,%a1
    moveb %a3@(1),%d2
    jbmi A32MAKEPTRSPC_12C
    jbsr A32MAKEPTRSPC_176
    jbeq A32MAKEPTRSPC_116
    btst #6,%d2
    jbeq A32MAKEPTRSPC_12C
    moveal %a1@,%a0
    subaw #12,%a0
    jbsr A32EH_5C
A32MAKEPTRSPC_116:      /* free now: add it */
    moveal %a3,%a0
    movel %a0@(4),%d0
    cmpal %fp@(48),%a0
    jbne A32MAKEPTRSPC_126
    clrl %fp@(48)
A32MAKEPTRSPC_126:      /* next */
    addl %d0,%d3
    addal %d0,%a3
    jbra A32MAKEPTRSPC_E8
A32MAKEPTRSPC_12C:      /* the free block */
    tstl %d3
    jbeq A32MAKEPTRSPC_136
    clrl %a2@
    movel %d3,%a2@(4)
A32MAKEPTRSPC_136:      /* not enough */
    cmpl %d1,%d3
    jbcc A32MAKEPTRSPC_13C
    subal %a2,%a2
A32MAKEPTRSPC_13C:      /* rover reset */
    clrl %fp@(48)
    moveml %sp@+,%d0-%d3/%a0-%a1/%a3
    rts

A32MAKEPTRSPC_146:      /* 24-bit: move block of handle a1 out of the way: the space gathered so far becomes a temporary nonrelocatable block, so the new copy goes elsewhere */
    movel %a0,%sp@-
    movel %d3,%d0
    jbeq A32MAKEPTRSPC_15C
    movel %d3,%a2@
    oril #1073741824,%a2@
    movel %fp,%a2@(4)
    jbsr ADJUSTFREE_E
A32MAKEPTRSPC_15C:      /* relocate it */
    moveal %a1@,%a0
    jbsr A24GETSIZE
    jbsr A32MAKEPTRSPC_1AC
    moveal %d0,%a0
    movel %d3,%d0
    jbeq A32MAKEPTRSPC_170
    movel %d3,%a2@
    jbsr ADJUSTFREE
A32MAKEPTRSPC_170:      /* d0 = the result */
    movel %a0,%d0
    moveal %sp@+,%a0
    rts

A32MAKEPTRSPC_176:      /* 32-bit */
    movel %a0,%sp@-
    movel %d3,%d0
    jbeq A32MAKEPTRSPC_18E
    movel %d3,%a2@(4)
    movel #1073741824,%a2@
    movel %fp,%a2@(8)
    jbsr ADJUSTFREE_E
A32MAKEPTRSPC_18E:      /* relocate it */
    moveal %a1@,%a0
    jbsr A32GETSIZE
    jbsr A32MAKEPTRSPC_204
    moveal %d0,%a0
    movel %d3,%d0
    jbeq A32MAKEPTRSPC_1A6
    clrl %a2@
    movel %d3,%a2@(4)
    jbsr ADJUSTFREE
A32MAKEPTRSPC_1A6:      /* d0 = the result */
    movel %a0,%d0
    moveal %sp@+,%a0
    rts

A32MAKEPTRSPC_1AC:      /* 24-bit: relocate the block of handle a1: allocate a new block (GZMoveHnd tells the grow zone procedure), copy, swap the two headers' tags (high nibbles), point the master pointer to it, free the old one. -108 if no room */
    moveml %d1-%d2/%a0-%a2,%sp@-
    moveal %a1,%a2
    movel %a1,GZMoveHnd
    moveb %a2@,%d1
    subal %a1,%a1
    jbsr A24ALLOCBK
    jbeq A32MAKEPTRSPC_1FE
    tstl %a2@
    jbeq A32MAKEPTRSPC_1F0
    moveal %a0,%a1
    moveal %a2@,%a0
    jbsr A24GETSIZE
    jbsr A32ALLOCBK_100
    subql #8,%a0
    subql #8,%a1
    moveq #-16,%d0
    andb %a0@,%d0
    eorb %d0,%a0@
    moveq #-16,%d2
    andb %a1@,%d2
    eorb %d2,%a1@
    orb %d0,%a1@
    orb %d2,%a0@
    addql #4,%a0
    addql #4,%a1
    movel %a0@,%a1@+
    movel %a1,%a2@
    moveb %d1,%a2@
    movel %fp,%a0@+
A32MAKEPTRSPC_1F0:      /* free the old block */
    jbsr A24FREEBK
    moveq #0,%d0
A32MAKEPTRSPC_1F4:      /* done */
    clrl GZMoveHnd
    moveml %sp@+,%d1-%d2/%a0-%a2
    rts
A32MAKEPTRSPC_1FE:      /* no room: -108 */
    moveb %d1,%a2@
    moveq #-108,%d0
    jbra A32MAKEPTRSPC_1F4

A32MAKEPTRSPC_204:      /* 32-bit */
    moveml %d1-%d2/%a0-%a2,%sp@-
    moveal %a1,%a2
    movel %a1,GZMoveHnd
    subal %a1,%a1
    jbsr A32ALLOCBK
    jbeq A32MAKEPTRSPC_256
    tstl %a2@
    jbeq A32MAKEPTRSPC_246
    moveal %a0,%a1
    moveal %a2@,%a0
    jbsr A32GETSIZE
    jbsr A32ALLOCBK_100
    subaw #12,%a0
    subaw #12,%a1
    moveb %a0@,%d0
    moveb %a1@,%d2
    moveb %d0,%a1@
    moveb %d2,%a0@
    moveb %a0@(1),%a1@(1)
    addql #8,%a0
    addql #8,%a1
    movel %a0@,%a1@+
    movel %a1,%a2@
    movel %fp,%a0@+
A32MAKEPTRSPC_246:      /* free the old block */
    bsrw A32FREEBK
    moveq #0,%d0
A32MAKEPTRSPC_24C:      /* done */
    clrl GZMoveHnd
    moveml %sp@+,%d1-%d2/%a0-%a2
    rts
A32MAKEPTRSPC_256:      /* no room: -108 */
    moveq #-108,%d0
    jbra A32MAKEPTRSPC_24C

/*
 A24FREEBK / A32FREEBK (a0 = data): free a block: a relocatable one's master pointer goes
 back on the free list; the block merges with the free blocks after it.
*/
A24FREEBK:
    moveml %d0-%d1/%a0-%a1,%sp@-
    subql #8,%a0
    movel %a0@,%d0
    movel %d0,%d1
    andl Lo3Bytes,%d0
    eorl %d0,%d1
    jbeq A24FREEBK_26
    jbpl A24FREEBK_1E
    moveal %a0@(4),%a1
    addal %fp,%a1
    jbsr RELEASEMP
A24FREEBK_1E:           /* free, merged */
    jbsr A32MAKEBKF_8
    jbsr ADJUSTFREE
A24FREEBK_26:           /* restore registers, return */
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts

A32FREEBK:              /* 32-bit */
    moveml %d0-%d1/%a0-%a1,%sp@-
    subaw #12,%a0
    movel %a0@(4),%d0
    tstb %a0@
    jbeq A32FREEBK_24
    jbpl A32FREEBK_1C
    moveal %a0@(8),%a1
    addal %fp,%a1
    jbsr RELEASEMP
A32FREEBK_1C:           /* free, merged */
    jbsr A32MAKEBKF_2C
    jbsr ADJUSTFREE
A32FREEBK_24:           /* restore registers, return */
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts

/*
 STDGZ: the standard grow zone procedure (zone +44), called with the size needed on the
 stack: unless a block is being moved (GZMoveHnd) or flag bit 3 is set, ResrvMem in
 this zone; if that is not enough (or flag bit 2 while moving), the zone's own grow
 zone procedure (+16).
*/
STDGZ:
    moveal %sp@+,%a1
    lea GZRootHnd,%a2	/* d3-d5 = GZRootHnd, GZRootPtr, GZMoveHnd */
    moveml %a2@,%d3-%d5
    tstl %d5
    jbeq STDGZ_12
    cmpl %d3,%d5
    jbne STDGZ_3C
STDGZ_12:               /* ResrvMem(size) in this zone (the GZ globals saved around it) */
    btst #3,%fp@(22)
    jbne STDGZ_48
    movel %sp@,%d0
    clrl %a2@+
    clrl %a2@+
    clrl %a2@+
    movel TheZone,%sp@-
    movel %fp,TheZone
    _ResrvMem
    movel %sp@+,TheZone
    moveml %d3-%d5,%a2@-
    tstl %d0
    jbmi STDGZ_48
    movel %sp@+,%sp@
    jmp %a1@
STDGZ_3C:               /* moving a block: flag bit 2? */
    btst #2,%fp@(22)
    jbne STDGZ_48
STDGZ_44:               /* nothing: return */
    addqw #4,%sp
    jmp %a1@
STDGZ_48:               /* the application's grow zone procedure, if any */
    movel %fp@(16),%d2
    jbeq STDGZ_44
    movel %a1,%sp@-
    movel %d2,%sp@-
    rts

/* MEMMGREND: end of the Memory Manager. */
MEMMGREND:
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4080ED66
