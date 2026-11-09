/*
 os/hwpriv.s - HWPriv, external cache, MemoryDispatch
 From HWPRIVPROC (0x40805430). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
*/

/* HWPRIVPROC: offsets of the _HWPriv selectors 0..10. */
HWPRIVPROC:
    .short  HWPRIV_16-HWPRIVPROC	| 40805430
    .short  HWPRIV_34-HWPRIVPROC	| 40805432
    .short  HWPRIV_44-HWPRIVPROC	| 40805434
    .short  HWPRIV_62-HWPRIVPROC	| 40805436
    .short  ENABLEEXTCACHE-HWPRIVPROC	| 40805438
    .short  caseD_5-HWPRIVPROC	| 4080543A
    .short  ENABLEEXTCACHE_54-HWPRIVPROC	| 4080543C
    .short  HWPRIVPROC-HWPRIVPROC	| 4080543E
    .short  HWPRIV_1C-HWPRIVPROC	| 40805440
    .short  HWPRIV_3E-HWPRIVPROC	| 40805442
    .short  WAITFORSCSIDEVSNUB-HWPRIVPROC	| 40805444
    .byte   0x00, 0x00	| 40805446

/*
 _HWPriv(d0 = selector): 0 SwapInstructionCache, 1 FlushInstructionCache, 2
 SwapDataCache, 3 FlushDataCache, 4 EnableExtCache, 5 DisableExtCache, 6 FlushExtCache,
 and further selectors for EDiskProtect and FlushCodeCacheRange (through the table's
 other entries). Out of range: -502.
*/
trap_HWPriv:
HWPRIV:
    cmpiw #10,%d0
    jbhi HWPRIV_E
    movew %pc@(HWPRIVPROC,%d0:w:2),%d0
    jmp %pc@(HWPRIVPROC,%d0:w)
HWPRIV_E:               /* bad selector: -502 (hwParamErr) */
    movel #-502,%d0
    rts
HWPRIV_16:              /* selector 0, then a jump to EDiskProtect (another selector) */
    jbra HWPRIVPATCH
HWPRIV_1C:              /* continue at EDISKPROTECT */
    jbra EDISKPROTECT
    .short  0x0000, 0x0000, 0x0000	| 4080546A
    .long   0x00000000, 0x00000000, 0x00000000	| 40805470
HWPRIV_34:              /* selector 1, then a jump to FlushCodeCacheRange (another selector) */
    jbra FLUSHICACHEPATCH
    .short  0x0000, 0x0000	| 40805482
HWPRIV_3E:              /* continue at FLUSHCRANGE */
    jbra FLUSHCRANGE
HWPRIV_44:              /* selector 2 */
    jbra SWAPDCACHEPATCH
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40805492
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408054A0
HWPRIV_62:              /* selector 3 */
    jbra FLUSHDCACHEPATCH
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408054B0

/*
 ENABLEEXTCACHE: HWPriv 4: turn the external (board) cache on, on machines with
 decoder kind 5, through a VIA 2 bit pulse sequence.
*/
caseD_4:
ENABLEEXTCACHE:
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal 0xdd8,%a0
    cmpib #5,%a0@(19)
    jbne ENABLEEXTCACHE_34
    moveal ghost_VIA2,%a0
    lea %a0@,%a0
    moveq #-9,%d0
    andb %a0@,%d0
    btst #0,%d0
    jbeq ENABLEEXTCACHE_34
    moveb %d0,%a0@
    bset #3,%d0
ENABLEEXTCACHE_28:      /* pulse */
    moveb %d0,%a0@
    moveb %a0@,%a0@
    moveb %a0@,%a0@
    bclr #0,%d0
    jbne ENABLEEXTCACHE_28
ENABLEEXTCACHE_34:      /* result 0 */
    movew %sp@+,%sr
    moveq #0,%d0
    rts

/* caseD_5: HWPriv 5: external cache off (VIA 2 bit 0 set). */
caseD_5:
    moveal 0xdd8,%a0
    cmpib #5,%a0@(19)
    jbne ENABLEEXTCACHE_50
    moveal ghost_VIA2,%a0
    lea %a0@,%a0
    orib #1,%a0@
ENABLEEXTCACHE_50:      /* result 0 */
    moveq #0,%d0
    rts
ENABLEEXTCACHE_54:      /* HWPriv 6: flush it (off, then on) */
    jbsr caseD_5
    jbsr caseD_4
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40805514

/* MEMORYDPROC: offsets of the _MemoryDispatch selectors 0..7. */
MEMORYDPROC:
    .short  MEMORYDISPATCH_16-MEMORYDPROC	| 40805520
    .short  MEMORYDISPATCH_1A-MEMORYDPROC	| 40805522
    .short  MEMORYDISPATCH_1E-MEMORYDPROC	| 40805524
    .short  MEMORYDISPATCH_24-MEMORYDPROC	| 40805526
    .short  MEMORYDISPATCH_2A-MEMORYDPROC	| 40805528
    .short  MEMORYDISPATCH_30-MEMORYDPROC	| 4080552A
    .short  MEMORYDISPATCH_1B0-MEMORYDPROC	| 4080552C
    .short  MEMORYDISPATCH_1B6-MEMORYDPROC	| 4080552E
    .long   0x00000000, 0x00000000	| 40805530

/*
 _MemoryDispatch(d0): 0 HoldMemory, 1 UnholdMemory (nothing without VM), 2
 LockMemory, 3 UnlockMemory, 4 LockMemoryContiguous, 5 GetPhysical, 6 WriteProtect,
 7 UnwriteProtect. Out of range: -502.
*/
trap_MemoryDispatch:
MEMORYDISPATCH:
    cmpiw #7,%d0
    jbhi MEMORYDISPATCH_E
    movew %pc@(MEMORYDPROC,%d0:w:2),%d0
    jmp %pc@(MEMORYDPROC,%d0:w)
MEMORYDISPATCH_E:       /* bad selector */
    movel #-502,%d0
    rts
MEMORYDISPATCH_16:      /* HoldMemory: 0 */
    moveq #0,%d0
    rts
MEMORYDISPATCH_1A:      /* UnholdMemory: 0 */
    moveq #0,%d0
    rts
MEMORYDISPATCH_1E:      /* LockMemory */
    jbra NEWLOCKMEMORY
MEMORYDISPATCH_24:      /* UnlockMemory */
    jbra NEWUNLOCKMEMORY
MEMORYDISPATCH_2A:      /* LockMemoryContiguous */
    jbra NEWLOCKMEMORYCONTIGUOUS
MEMORYDISPATCH_30:      /* GetPhysical(table a0, count a1): logical range to physical ranges */
    moveml %d3/%a3-%a4,%sp@-
    movel %a0,%sp@-
    moveal %a0,%a4
    movel %a1,%d3
    movel %a4@+,%d2
    moveal %d2,%a0
    addl %a4@,%d2
    cmpl 0x1ef4,%d2
    jbhi MEMORYDISPATCH_8A
MEMORYDISPATCH_46:      /* physical address of the first and last byte */
    jbsr GETREALPROC
    tstw %d0
    jbmi MEMORYDISPATCH_8A
    moveal %a0,%a3
    moveal %d2,%a0
    subql #1,%a0
    jbsr GETREALPROC
    tstw %d0
    jbmi MEMORYDISPATCH_8A
    subal %a3,%a0
    addql #1,%a0
    cmpal %a4@,%a0
    jbne MEMORYDISPATCH_92
    tstl %d3
    jbeq MEMORYDISPATCH_7A
    movel %a4@+,%d0
    addl %d0,%a4@(-8)
    clrl %a4@(-4)
    movel %a3,%a4@+
    movel %d0,%a4@
MEMORYDISPATCH_7A:      /* one range: count 1 */
    moveaw #1,%a0
    clrw %d2
MEMORYDISPATCH_80:      /* return */
    movel %d2,%d0
    moveal %sp@+,%a1
    moveml %sp@+,%d3/%a3-%a4
    rts
MEMORYDISPATCH_8A:      /* error: -50 */
    subal %a0,%a0
    movew #-50,%d2
    jbra MEMORYDISPATCH_80
MEMORYDISPATCH_92:      /* not contiguous: split by pages */
    moveal %sp@,%a4
    moveal %a4@,%a0
    addql #8,%a4
    movel %d3,%d1
    bsrw MEMORYDISPATCH_A6
    tstw %d2
    jbmi MEMORYDISPATCH_8A
    moveal %d1,%a0
    jbra MEMORYDISPATCH_80

MEMORYDISPATCH_A6:      /* split the range into physically contiguous pieces (page size from Gestalt 'pgsz'), filling up to d1 entries */
    linkw %fp,#-36
    moveml %d3-%d7,%sp@-
    movel %d1,%fp@(-20)
    movel #1,%fp@(-24)
    clrl %fp@(-28)
    movel %a4@(-8),%fp@(-32)
    movel %a4@(-4),%fp@(-36)
    jbsr GETREALPROC
    tstw %d0
    jbmi MEMORYDISPATCH_1AA
    movel %a0,%fp@(-4)
    movel #1885827962,%d0
    .short  0xA1AD	| 40805618 _Gestalt (flags 0x0100)
    movel %a0,%fp@(-12)
    movel %a0,%d2
    subqw #1,%d2
    movel %fp@(-4),%d3
    negl %d3
    andl %d3,%d2
    movel %d2,%fp@(-16)
    moveal %fp@(-32),%a3
    addal %d2,%a3
MEMORYDISPATCH_FC:      /* next page: continues the piece? */
    moveal %a3,%a0
    jbsr GETREALPROC
    tstw %d0
    jbmi MEMORYDISPATCH_1AA
    movel %fp@(-4),%d3
    addl %fp@(-16),%d3
    cmpal %d3,%a0
    jbne MEMORYDISPATCH_12E
    movel %fp@(-16),%d3
MEMORYDISPATCH_11A:     /* grow the piece */
    addl %fp@(-12),%d3
    cmpl %a4@(-4),%d3
    jbcc MEMORYDISPATCH_168
    movel %d3,%fp@(-16)
    addal %fp@(-12),%a3
    jbra MEMORYDISPATCH_FC
MEMORYDISPATCH_12E:     /* new piece: store the previous one */
    tstl %fp@(-20)
    jbeq MEMORYDISPATCH_150
    movel %fp@(-28),%d3
    movel %fp@(-4),%a4@(0x0,%d3:l:8)
    movel %fp@(-16),%a4@(0x4,%d3:l:8)
    addql #1,%d3
    cmpl %fp@(-20),%d3
    jbcc MEMORYDISPATCH_19E
    movel %d3,%fp@(-28)
MEMORYDISPATCH_150:     /* start a new piece */
    addql #1,%fp@(-24)
    movel %fp@(-16),%d3
    addl %d3,%a4@(-8)
    subl %d3,%a4@(-4)
    movel %a0,%fp@(-4)
    moveq #0,%d3
    jbra MEMORYDISPATCH_11A
MEMORYDISPATCH_168:     /* end of the range */
    tstl %fp@(-20)
    jbne MEMORYDISPATCH_180
    movel %fp@(-24),%d1
    movel %fp@(-32),%a4@(-8)
    movel %fp@(-36),%a4@(-4)
    jbra MEMORYDISPATCH_1A0
MEMORYDISPATCH_180:     /* last piece */
    movel %fp@(-28),%d3
    movel %fp@(-4),%a4@(0x0,%d3:l:8)
    movel %a4@(-4),%a4@(0x4,%d3:l:8)
    movel %a4@(-4),%d2
    addl %d2,%a4@(-8)
    clrl %a4@(-4)
    addql #1,%d3
MEMORYDISPATCH_19E:     /* count */
    movel %d3,%d1
MEMORYDISPATCH_1A0:     /* 0 */
    moveq #0,%d2
MEMORYDISPATCH_1A2:     /* return */
    moveml %sp@+,%d3-%d7
    unlk %fp
    rts
MEMORYDISPATCH_1AA:     /* error: -1 */
    movew #-1,%d2
    jbra MEMORYDISPATCH_1A2
MEMORYDISPATCH_1B0:     /* WriteProtect */
    jbra WRITEPROTECTPROC
MEMORYDISPATCH_1B6:     /* UnwriteProtect */
    jbra UNWRITEPROTECTPROC

/* WAITFORSCSIDEVSNUB: jump to WAITFORSCSIDEVS. */
WAITFORSCSIDEVSNUB:
    jbra WAITFORSCSIDEVS
    .fill   0x196, 1, 0x00
