/*
 os/vbl.s - Deferred Task Manager and VBL Manager
 From DTCORE (0x4080A1D0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 Low memory: 0xD92 the deferred task queue, 0xD04 the slot VBL queue table (one queue
 per slot), 0xD10 the slot whose VBL also runs the cursor task, 0xD28 JVBLTask.
*/

/*
 _DTInstall: add a deferred task (qType 7) to the deferred task queue. Result 0, or -2
 (vTypErr).
*/
trap_DTInstall:
DTCORE:
DTINSTALL:
    cmpiw #7,%a0@(4)
    jbne DTCORE_14
    lea 0xd92,%a1
    jsr %pc@(trap_Enqueue)
    moveq #0,%d0
    rts
DTCORE_14:              /* wrong type: -2 */
    moveq #-2,%d0
    rts
DISPTCHTSK:             /* jump through the dispatch vector at 0x6E4 */
    movel 0x6e4,%sp@-
    rts

/*
 VDISPTCH: run the deferred tasks, at the end of an interrupt, with interrupts enabled,
 unless already running (bit 6 of the queue flags) or inside the VBL handler.
*/
trap_VDISPTCH:
VDISPTCH:
    btst #6,VBLQueue
    jbne VDISPTCH_10
    bset #6,0xd92
    jbeq VDISPTCH_2A
VDISPTCH_10:            /* return */
    rts
VDISPTCH_12:            /* dequeue the first task, call it with a1 = its parameter */
    moveal %d0,%a0
    lea 0xd92,%a1
    jsr %pc@(trap_Dequeue)
    moveal %a0@(8),%a2
    moveal %a0@(12),%a1
    andiw #-1793,%sr
    jsr %a2@
VDISPTCH_2A:            /* next, until the queue is empty */
    oriw #1792,%sr
    movel DTskQHdr,%d0
    jbne VDISPTCH_12
    bclr #6,0xd92
    rts
    .short  0x0000, 0x0000, 0x0000	| 4080A22A

/*
 _VInstall: add a VBL task (qType 1) to the VBL queue; with a phase, its count is
 adjusted so tasks with the same period run in different ticks. Result 0 or -2.
*/
trap_VInstall:
VBLCORE:
VINSTALL:
    lea VBLQueue,%a1
VBLCORE_4:              /* (slot queue in a1) */
    cmpiw #1,%a0@(4)
    jbne VBLCORE_4C
    movew %a0@(10),%d1
    jbeq VBLCORE_44
    tstw %a0@(12)
    jbeq VBLCORE_44
    movew %sr,%sp@-
    oriw #1792,%sr
    movel %a1@(10),%d0
    swap %d0
    moveq #0,%d2
    movew %d0,%d2
    divuw %d1,%d2
    swap %d2
    movew %d2,%d0
    swap %d0
    divuw %d1,%d0
    swap %d0
    subw %a0@(12),%d0
    negw %d0
    jbpl VBLCORE_3E
    addw %d1,%d0
VBLCORE_3E:             /* (phase) */
    addw %d0,%a0@(10)
    movew %sp@+,%sr
VBLCORE_44:             /* enqueue it */
    jsr %pc@(trap_Enqueue)
    moveq #0,%d0
    rts
VBLCORE_4C:             /* wrong type: -2 */
    moveq #-2,%d0
    rts

/* _VRemove: remove a VBL task. */
trap_VRemove:
VREMOVE:
    cmpiw #1,%a0@(4)
    jbne VBLCORE_4C
    movel %a1,%sp@-
    lea VBLQueue,%a1
    jsr %pc@(trap_Dequeue)
    moveal %sp@+,%a1
VREMOVE_14:             /* return */
    rts
VBLINT:                 /* the 60 Hz interrupt: Ticks + 1, acknowledge the VIA, check the stack (system error 28 if it reached the application heap), run the VBL tasks whose count reaches 0, remove those that do not set it again */
    addql #1,Ticks
    moveb #2,%a1@(6656)
    bset #6,VBLQueue
    jbne VREMOVE_14
    movew #8192,%sr
    movel StackLowPoint,%d0
    jbeq VBLINT_30
    cmpal %d0,%sp
    jbcc VBLINT_24
    movel %sp,StackLowPoint
VBLINT_24:              /* stack below the application heap? */
    moveal ApplZone,%a1
    cmpal %a1@,%sp
    jbcc VBLINT_30
    moveq #28,%d0
    _SysError
VBLINT_30:              /* run the VBL queue */
    lea VBLQueue,%a1
VBLINT_34:              /* run the queue at a1 */
    lea %a1@(2),%a0
VBLINT_38:              /* next task: count down, call it when 0 */
    movel %a0@,%d0
    jbeq VBLINT_5E
    moveal %d0,%a0
    subqw #1,%a0@(10)
    jbne VBLINT_38
    movel %a0,%sp@-
    movel %a1,%sp@-
    moveal %a0@(6),%a1
    jsr %a1@
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    tstw %a0@(10)
    jbne VBLINT_38
    jsr %pc@(trap_Dequeue)
    jbra VBLINT_38
VBLINT_5E:              /* done */
    bclr #6,%a1@
    rts

VBLINT_64:              /* a1 = the VBL queue of slot d0 (0..14), else -337 (slot number error) to the caller's caller */
    extw %d0
    cmpiw #14,%d0
    jbgt VBLINT_74
    moveal @(0xd04)@(0x0,%d0:w:4),%a1
    rts
VBLINT_74:              /* bad slot: -337 */
    movew #-337,%d0
    addqw #4,%sp
    rts

/* _SlotVInstall: _VInstall into the queue of slot d0. */
trap_SlotVInstall:
SLOTVINSTALL:
    jbsr VBLINT_64
    jbra VBLCORE_4

/* _SlotVRemove: remove a task from the queue of slot d0. */
trap_SlotVRemove:
SLOTVREMOVE:
    jbsr VBLINT_64
    cmpiw #1,%a0@(4)
    jbne VBLCORE_4C
    jmp %pc@(trap_Dequeue)

/* _AttachVBL: make slot d0 the one whose VBL runs the cursor task. */
trap_AttachVBL:
ATTACHVBL:
    jbsr VBLINT_64
    movel %a1,0xd10
    moveq #0,%d0
    rts

/*
 _DoVBLTask: run the VBL queue of slot d0 (called from the slot's interrupt handler),
 and the cursor task for the attached slot.
*/
trap_DoVBLTask:
DOVBLTASK:
    jbsr VBLINT_64
    addql #1,%a1@(10)
    cmpal 0xd10,%a1
    jbne DOVBLTASK_1A
    movel JCrsrTask,%d0
    jbeq DOVBLTASK_1A
    moveal %d0,%a0
    movel %a1,%sp@-
    jsr %a0@
    moveal %sp@+,%a1
DOVBLTASK_1A:           /* the slot's queue */
    jbra VBLINT_34

/* INITVBLQS: JVBLTask (0xD28) = DoVBLTask, no attached slot. */
INITVBLQS:
    lea %pc@(trap_DoVBLTask),%a0
    movel %a0,JVBLTask
    clrl 0xd10
    rts
    .short  0x0000	| 4080A35E
