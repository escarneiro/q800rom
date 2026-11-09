/*
 os/dispatcher.s - cache trap, queue utilities, A-trap dispatcher, trap address traps, INITDISPATCHER
 From CACHEPROC (0x40809830). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 Trap tables: OS traps at 0x400 (256 entries), Toolbox traps at 0xE00 (1024 entries).
*/

/* CACHEPROC: offsets of the File Manager cache control selectors (trap 0xA??? with d0). */
CACHEPROC:
    .short  CACHETRAP_1A-CACHEPROC	| 40809830
    .short  CACHETRAP_32-CACHEPROC	| 40809832
    .short  CACHETRAP_46-CACHEPROC	| 40809834
    .short  CACHETRAP_58-CACHEPROC	| 40809836
    .short  CACHETRAP_6A-CACHEPROC	| 40809838
    .short  CACHETRAP_7C-CACHEPROC	| 4080983A
    .short  CACHETRAP_A4-CACHEPROC	| 4080983C
    .short  CACHETRAP_C8-CACHEPROC	| 4080983E
trap_CACHETRAP:
CACHETRAP:              /* test #8,%d0 */
    cmpiw #8,%d0
    jbcs CACHETRAP_A
    moveq #-50,%d0
    rts
CACHETRAP_A:            /* dispatch */
    lea %pc@(CACHEPROC),%a1
    addw %d0,%d0
    addaw %a1@(0x0,%d0:w),%a1
    jmp %a1@
CACHETRAP_16:           /* done: CMDDONE */
    jmp %pc@(CMDDONE)
CACHETRAP_1A:           /* call FSQUEUESYNC */
    jsr %pc@(FSQUEUESYNC)
    moveal 0x394,%a1
    movel %a1@(4),%d0
    subl %a1@(8),%d0
    movel %d0,%a0@(28)
    moveq #0,%d0
    jbra CACHETRAP_16
CACHETRAP_32:           /* call FSQUEUESYNC */
    jsr %pc@(FSQUEUESYNC)
    movel %a0@(28),%d0
    moveq #15,%d1
    lsrl %d1,%d0
    moveb %d0,SPMisc1
    moveq #0,%d0
    jbra CACHETRAP_16
CACHETRAP_46:           /* call FSQUEUESYNC */
    jsr %pc@(FSQUEUESYNC)
    moveal 0x394,%a1
    movel %a1@(32),%a0@(28)
    moveq #0,%d0
    jbra CACHETRAP_16
CACHETRAP_58:           /* call FSQUEUESYNC */
    jsr %pc@(FSQUEUESYNC)
    moveal 0x394,%a1
    movel %a0@(28),%a1@(32)
    moveq #0,%d0
    jbra CACHETRAP_16
CACHETRAP_6A:           /* call FSQUEUESYNC */
    jsr %pc@(FSQUEUESYNC)
    moveal 0x394,%a1
    movel %a1@(18),%a0@(28)
    moveq #0,%d0
    jbra CACHETRAP_16
CACHETRAP_7C:           /* call FSQUEUESYNC */
    jsr %pc@(FSQUEUESYNC)
    moveal 0x394,%a1
    movel %a1@(4),%d0
    subl %a1@(8),%d0
    movel %a0@(28),%d1
    cmpl %d1,%d0
    jbcc CACHETRAP_9A
    moveq #-50,%d0
    jbra CACHETRAP_16
CACHETRAP_9A:           /* set it */
    movel %d1,%a1@(18)
    moveq #0,%d0
    jbra CACHETRAP_16
CACHETRAP_A4:           /* call FSQUEUESYNC */
    jsr %pc@(FSQUEUESYNC)
    moveal 0x394,%a1
    moveq #0,%d0
    tstb %a1@(17)
    jbeq CACHETRAP_BE
    btst #5,SPMisc2
    jbeq CACHETRAP_BE
    moveq #1,%d0
CACHETRAP_BE:           /* return the flag */
    movel %d0,%a0@(28)
    moveq #0,%d0
    jbra CACHETRAP_16
CACHETRAP_C8:           /* call FSQUEUESYNC */
    jsr %pc@(FSQUEUESYNC)
    tstl %a0@(28)
    jbeq CACHETRAP_DA
    bset #5,SPMisc2
    jbra CACHETRAP_E0
CACHETRAP_DA:           /* clear the flag */
    bclr #5,SPMisc2
CACHETRAP_E0:           /* done */
    moveq #0,%d0
    jbra CACHETRAP_16
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40809926

/* _Enqueue(a0 = element, a1 = queue header): add at the end (interrupts masked). */
trap_Enqueue:
QSTUFF:
ENQUEUE:
    movew %sr,%sp@-
    addqw #2,%a1
    oriw #1792,%sr
    clrl %a0@
    tstl %a1@+
    jbne QSTUFF_14
    movel %a0,%a1@
    movel %a0,%a1@-
    jbra QSTUFF_20
QSTUFF_14:              /* not empty: after the last */
    movel %a2,%sp@-
    moveal %a1@,%a2
    movel %a0,%a2@
    movel %a0,%a1@
    moveal %sp@+,%a2
    subqw #4,%a1
QSTUFF_20:              /* return */
    subqw #2,%a1
    movew %sp@+,%sr
    rts

/* _Dequeue(a0 = element, a1 = queue header): remove it. Result 0, or -1 (qErr). */
trap_Dequeue:
DEQUEUE:
    movew %sr,%sp@-
    moveml %a2-%a3,%sp@-
    oriw #1792,%sr
    moveal %a1@(2),%a2
    moveal %a2,%a3
DEQUEUE_10:             /* find it */
    cmpal %a3,%a0
    jbeq DEQUEUE_22
    moveal %a3,%a2
    moveal %a2@,%a3
    cmpal %a1@(6),%a2
    jbne DEQUEUE_10
    moveq #-1,%d0
    jbra DEQUEUE_32
DEQUEUE_22:             /* found: first one? */
    cmpal %a2,%a3
    jbne DEQUEUE_3A
    movel %a2@,%a1@(2)
    jbne DEQUEUE_30
    clrl %a1@(6)
DEQUEUE_30:             /* 0 */
    moveq #0,%d0
DEQUEUE_32:             /* return */
    moveml %sp@+,%a2-%a3
    movew %sp@+,%sr
    rts
DEQUEUE_3A:             /* unlink it from the previous one */
    movel %a3@,%a2@
    cmpal %a1@(6),%a3
    jbne DEQUEUE_30
    movel %a2,%a1@(6)
    jbra DEQUEUE_30

/* INITQUEUE: empty queue header at a1. */
INITQUEUE:
    clrw %a1@+
    clrl %a1@+
    clrl %a1@
    subqw #6,%a1
    rts
    .long   0x00000000, 0x00000000	| 408099A8

/*
 DISPATCHER (EMT1010): the A-line trap dispatcher. Toolbox traps (0xA800-0xAFFF) jump
 to their table entry (auto-pop bit: return to the caller's caller). OS traps (0xA000-
 0xA7FF) save d1-d2/a1-a2 (and a0 unless bit 8 is set), call the routine with d1 =
 the trap word, then test d0.
*/
trap_dispatcher:
DISPATCHER:
EMT1010:
    movel %a2,%sp@-
    movel %d2,%sp@-
    moveal %sp@(10),%a2
    movew %a2@+,%d2
    cmpiw #-22528,%d2
    jbcs DISPATCHER_40
    subiw #-21504,%d2
    jbcc DISPATCHER_30
    movel @(0x1e00,%d2:w:4),%sp@(8)
    movel %a2,%sp@(12)
    movel %sp@+,%d2
    moveal %sp@+,%a2
    rts
    .long   0x00000000, 0x00000000	| 408099D8
DISPATCHER_30:          /* Toolbox trap: jump through 0xE00 */
    movel @(0xe00,%d2:w:4),%sp@(8)
    movel %sp@+,%d2
    moveal %sp@+,%a2
    rtd #4
DISPATCHER_40:          /* OS trap */
    movel %d1,%sp@-
    movel %a1,%sp@-
    movew %d2,%d1
    movel %a2,%sp@(20)
    andiw #256,%d2
    jbne DISPATCHER_70
    moveb %d1,%d2
    movel %a0,%sp@-
    jsr @(0x400,%d2:w:4)@(0x0)
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %sp@+,%d1
    movel %sp@+,%d2
    moveal %sp@+,%a2
    tstw %d0
    addqw #4,%sp
    rts
    .short  0x0000, 0x0000, 0x0000	| 40809A1A
DISPATCHER_70:          /* OS trap that returns a0 */
    moveb %d1,%d2
    jsr @(0x0,%d2:w:4)@(0x0)
    moveal %sp@+,%a1
    movel %sp@+,%d1
    movel %sp@+,%d2
    moveal %sp@+,%a2
    tstw %d0
    addqw #4,%sp
    rts

EMT1010_84:             /* a1 = the table entry of trap d0 (d1 = the trap word from Get/SetTrapAddress: new/old style, OS or Toolbox) */
    lslw #6,%d1
    jbpl DISPATCHER_96
    jbcc DISPATCHER_AA
DISPATCHER_8A:          /* Toolbox entry */
    andiw #1023,%d0
    lea @(0xe00,%d0:w:4),%a1
    rts
DISPATCHER_96:          /* old-style number: OS or Toolbox by range */
    andiw #511,%d0
    moveq #-87,%d1
    addw %d0,%d1
    jbgt DISPATCHER_8A
    jbeq DISPATCHER_AA
    addqw #8,%d1
    jble DISPATCHER_AA
    subqw #5,%d1
    jbne DISPATCHER_8A
DISPATCHER_AA:          /* OS entry */
    andiw #255,%d0
    lea @(0x400,%d0:w:4),%a1
    rts

/* _GetTrapAddress: a0 = the routine of trap d0. */
trap_GetTrapAddress:
GETTRAPADDRESS:
    jbsr EMT1010_84
    moveal %a1@,%a0
    moveq #0,%d0
    rts

/* _SetTrapAddress: set it (through DISPATCHPATCH, which flushes the caches). */
trap_SetTrapAddress:
SETTRAPADDRESS:
    jbsr EMT1010_84
    jbra DISPATCHPATCH

/* CACHEFLUSH: flush the caches through the vector at 0x6F4. */
CACHEFLUSH:
    movel 0x6f4,%sp@-
    rts

/*
 VCACHEFLUSH: the 68020/68030 version (set the clear bits in CACR), and its
 installation.
*/
VCACHEFLUSH:
    movec %cacr,%d1
    addqw #8,%d1
    movec %d1,%cacr
    rts
    lea %pc@(DISPATCHER),%a0
    beqs VCACHEFLUSH_16
    lea %pc@(DISPATCHER),%a0
VCACHEFLUSH_16:
    movel %a0,ATrapVector

/*
 INITDISPATCHER: build the trap tables from the packed table in the ROM (header +34):
 each entry is a 1-byte or 2-byte offset from the previous routine, 0x80 for
 "unimplemented", 0xFF followed by a full long offset. First the 1024 Toolbox
 entries at 0xE00, then the 256 OS entries at 0x400.
*/
init_trap_dispatcher:
INITDISPATCHER:
    lea %pc@(UnimplementedTrap),%a4
    moveal ROMBase,%a3
    moveal %a3,%a2
    lea 0xe00,%a1
    moveal %a3,%a0
    addal %a0@(34),%a0
    moveq #127,%d2
    movew #1023,%d0
INITDISPATCHER_1A:      /* next entry: 1-byte or 2-byte offset */
    moveb %a0@+,%d1
    jbmi INITDISPATCHER_34
    lslw #8,%d1
    moveb %a0@+,%d1
INITDISPATCHER_22:      /* offset 0: done */
    addw %d1,%d1
    jbeq INITDISPATCHER_46
    addaw %d1,%a2
INITDISPATCHER_28:      /* store the address */
    movel %a2,%a1@+
INITDISPATCHER_2A:      /* then the OS table (DispatchTab) */
    dbf %d0,INITDISPATCHER_1A
    lea DispatchTab,%a1
    jbra INITDISPATCHER_1A
INITDISPATCHER_34:      /* special codes */
    andw %d2,%d1
    jbeq INITDISPATCHER_42
    cmpw %d2,%d1
    jbne INITDISPATCHER_22
    moveal %a0@+,%a2
    addal %a3,%a2
    jbra INITDISPATCHER_28
INITDISPATCHER_42:      | unimplemented
    movel %a4,%a1@+
    jbra INITDISPATCHER_2A
INITDISPATCHER_46:      /* done: A-line vector and cache flush vector */
    jbra CACHEVECTORPATCH
    .short  0x0000, 0x0000	| 40809AE2

/* BADTRAP: unimplemented trap: save the registers at 0xC30, system error 12. */
UnimplementedTrap:
BADTRAP:
    moveml %d0-%sp,SEVarBase
    moveq #12,%d0
    jmp %pc@(SYSERR1)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40809AF2
