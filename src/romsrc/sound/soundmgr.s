/*
 sound/soundmgr.s - Sound Manager, MACE
 From MYGETRESOURCE (0x40842130). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the Sound Manager chapter of Inside
 Macintosh VI), not taken from Apple. Most of this is compiled C (Pascal calling
 convention for the traps). Sound Manager globals (52 bytes, pointer through
 SMGlobalLoc): +0 channel list, +4, +6 handle, +10 1 KB buffer, +18, +22 100,
 +26 the 'slod' table, +46/+47 sound chip version nibbles, +48.
 Note: "pea DispatchTab" below is the number 0x400 (1024 bytes) and "pea MemTop"
 elsewhere 0x108: constants that happen to equal low memory addresses.
*/

/*
 MYGETRESOURCE(id, type): the Sound Manager's GetResource: for 'snd ' 5, look first in
 the application's file if it has a 'WILD' resource 0 (else the System file), then
 RGetResource from the current file chain. The current resource file is preserved.
*/
MYGETRESOURCE:
    linkw %fp,#0
    moveml %d4-%d7/%a3,%sp@-
    movew %fp@(8),%d5
    movel %fp@(10),%d6
    subql #2,%sp
    _CurResFile
    movew %sp@+,%d7
    moveq #0,%d0
    moveb ResLoad,%d0
    movew %d0,%d4
    cmpiw #5,%d5
    jbne MYGETRESOURCE_5A
    cmpil #1936618600,%d6
    jbne MYGETRESOURCE_5A
    movew CurApRefNum,%sp@-
    _UseResFile
    moveq #0,%d0
    moveb %d0,%sp@-
    _SetResLoad
    subql #4,%sp
    movel #1464421444,%sp@-
    moveq #0,%d0
    movew %d0,%sp@-
    _Get1Resource
    tstl %sp@+
    jbeq MYGETRESOURCE_52
    movew SysMap,%sp@-
    _UseResFile
    jbra MYGETRESOURCE_56
MYGETRESOURCE_52:       /* no 'WILD': back to the current file */
    movew %d7,%sp@-
    _UseResFile
MYGETRESOURCE_56:       /* restore ResLoad */
    moveb %d4,%sp@-
    _SetResLoad
MYGETRESOURCE_5A:       /* RGetResource(type, id) */
    subql #4,%sp
    movel %d6,%sp@-
    movew %d5,%sp@-
    _RGetResource
    moveal %sp@+,%a3
    movew %d7,%sp@-
    _UseResFile
    movel %a3,%fp@(14)
    moveml %fp@(-20),%d4-%d7/%a3
    unlk %fp
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 408421AA

/* IsAscMac: nonzero if Gestalt 'hdwr' says the machine has an Apple Sound Chip (bit 3). */
IsAscMac:
    linkw %fp,#-4
    movel %d7,%sp@-
    pea %fp@(-4)
    movel #1751414642,%sp@-
    jsr %pc@(GestaltCall)
    movew %d0,%d7
    moveq #8,%d0
    andl %fp@(-4),%d0
    movel %fp@(-8),%d7
    unlk %fp
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408421D4

/*
 INITGLOBALS: create the Sound Manager globals: the 52-byte block, a 1 KB buffer
 filled with 0x80 (silence), the 'slod' table (CPU load per sample rate: from the
 'slod' resource of the machine, or computed from SLODMULTIPLIERS), a 256-byte handle,
 and the sound chip version. Result: 0 or a Memory Manager error.
*/
INITGLOBALS:
    linkw %fp,#-4
    moveml %d3/%d6-%d7/%a3-%a4,%sp@-
    moveal ROMBase,%a0
    tstb %a0@(8)
    jbeq INITGLOBALS_30
    moveq #52,%d0
    movel %d0,%sp@-
    jsr %pc@(NewSysPtr)
    movel %d0,%sp@-
    jsr %pc@(SMGlobalLoc)
    movel %d0,%d1
    movel %sp@+,%d0
    moveal %d1,%a0
    movel %d0,%a0@
    movel %d0,SMGlobals
    addql #4,%sp
    jbra INITGLOBALS_48
INITGLOBALS_30:         /* (ROM version without the 0xCC4 copy) */
    moveq #52,%d0
    movel %d0,%sp@-
    jsr %pc@(NewSysPtr)
    movel %d0,%sp@-
    jsr %pc@(SMGlobalLoc)
    movel %d0,%d1
    movel %sp@+,%d0
    moveal %d1,%a0
    movel %d0,%a0@
    addql #4,%sp
INITGLOBALS_48:         /* allocated? */
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    tstl %a0@
    jbne INITGLOBALS_64
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveq #-1,%d0
    movel %d0,%a0@
    jsr %pc@(MemError)
    jbra INITGLOBALS_206
INITGLOBALS_64:         /* clear the fields, allocate the 1 KB buffer */
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    moveq #0,%d0
    movel %d0,%a0@
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    clrw %a0@(4)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    moveq #0,%d0
    movel %d0,%a0@(48)
    pea DispatchTab
    jsr %pc@(NewSysPtr)
    moveal %d0,%a3
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a3,%a0@(10)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    moveq #0,%d0
    movel %d0,%a0@(18)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movew #100,%a0@(22)
    jsr %pc@(IsAscMac)
    tstw %d0
    addql #4,%sp
    jbeq INITGLOBALS_204
    pea %fp@(-4)
    movel #1835098984,%sp@-
    jsr %pc@(GestaltCall)
    movew %d0,%d6
    subql #4,%sp
    movel #1936486244,%sp@-
    movew %fp@(-2),%sp@-
    _GetResource
    moveal %sp@+,%a4
    movel %a4,%d0
    addql #8,%sp
    jbne INITGLOBALS_132
    moveq #40,%d0
    movel %d0,%sp@-
    jsr %pc@(NewSysHandle)
    moveal %d0,%a4
    clrw %d7
    movel %d7,%d0
    addw %d0,%d0
    lea %pc@(SLODMULTIPLIERS),%a0
    moveal %a4@,%a1
    movew %a0@(0x0,%d0:w),%a1@
    moveq #1,%d7
    addql #4,%sp
INITGLOBALS_10C:        /* compute the 16 'slod' entries */
    movel %d7,%d0
    addw %d0,%d0
    lea %pc@(SLODMULTIPLIERS),%a0
    pea %a0@(0x0,%d0:w)
    jsr %pc@(CALCULATESLOD)
    extl %d7
    movel %d7,%d1
    asll #1,%d1
    addl %a4@,%d1
    moveal %d1,%a0
    movew %d0,%a0@
    addql #4,%sp
    addqw #1,%d7
    cmpiw #17,%d7
    jblt INITGLOBALS_10C
INITGLOBALS_132:        /* lock the table, fill the buffer with 0x80 */
    movel %a4,%sp@-
    jsr %pc@(HLock_408439B0)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a4@,%a0@(26)
    clrw %d7
    movew #1024,%d3
    addql #4,%sp
INITGLOBALS_14C:        /* fill loop */
    extl %d7
    movel %a3,%d0
    addl %d7,%d0
    moveal %d0,%a0
    moveb #0x80,%a0@
    addqw #1,%d7
    cmpw %d7,%d3
    jbgt INITGLOBALS_14C
    pea MonkeyLives
    jsr %pc@(NewSysHandle)
    movel %d0,%sp@-
    jsr %pc@(SMGlobalLoc)
    movel %d0,%d1
    movel %sp@+,%d0
    moveal %d1,%a0
    moveal %a0@,%a0
    movel %d0,%a0@(6)
    addql #4,%sp
    jbne INITGLOBALS_190
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    movel %a0@,%sp@-
    jsr %pc@(DisposPtr_408439A0)
    jsr %pc@(MemError)
    addql #4,%sp
    jbra INITGLOBALS_206
INITGLOBALS_190:        /* sound chip version (0xCC0 +0x800): high and low nibble */
    moveal ASCBase,%a0
    moveb %a0@(2048),%d0
    extw %d0
    extl %d0
    movel #240,%d1
    andl %d0,%d1
    movel %d1,%sp@-
    jsr %pc@(SMGlobalLoc)
    movel %sp@+,%d1
    moveal %d0,%a0
    moveal %a0@,%a0
    moveb %d1,%a0@(46)
    moveal ASCBase,%a0
    moveq #15,%d0
    andb %a0@(2048),%d0
    movel %d0,%sp@-
    jsr %pc@(SMGlobalLoc)
    movel %d0,%d1
    movel %sp@+,%d0
    moveal %d1,%a0
    moveal %a0@,%a0
    moveb %d0,%a0@(47)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    moveq #0,%d0
    moveb %a0@(46),%d0
    cmpil #176,%d0
    jbne INITGLOBALS_204
    moveal ASCBase,%a0
    moveb #1,%a0@(3849)
    moveal ASCBase,%a0
    moveb #1,%a0@(3881)
    moveal ASCBase,%a0
    moveb #1,%a0@(2049)
INITGLOBALS_204:        /* result 0 */
    moveq #0,%d0
INITGLOBALS_206:        /* return */
    moveml %fp@(-24),%d3/%d6-%d7/%a3-%a4
    unlk %fp
    rts

/*
 SetDivTable(handle, n): resize the handle to 256 x n bytes and fill it with the
 division table (each value 0..255 repeated n times). Result: 0 or an error.
*/
SetDivTable:
    moveml %d3-%d7/%a3-%a4,%sp@-
    moveal %sp@(32),%a4
    movew %sp@(38),%d5
    cmpiw #2,%d5
    jbge SetDivTable_16
    moveq #0,%d0
    jbra SetDivTable_70
SetDivTable_16:         /* resize */
    extl %d5
    movel %d5,%d0
    asll #8,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    jsr %pc@(SetHandleSize_40843A20)
    movew %d0,%d4
    addql #8,%sp
    jbeq SetDivTable_2E
    movew %d4,%d0
    jbra SetDivTable_70
SetDivTable_2E:         /* (nil handle) */
    movel %a4,%d0
    jbne SetDivTable_38
    jsr %pc@(MemError)
    jbra SetDivTable_70
SetDivTable_38:         /* lock it, fill */
    movel %a4,%sp@-
    jsr %pc@(HGetState_408439E0)
    moveb %d0,%d4
    movel %a4,%sp@-
    jsr %pc@(HLock_408439B0)
    moveal %a4@,%a3
    addql #8,%sp
    clrw %d6
    movew #256,%d3
SetDivTable_50:         /* next value */
    clrw %d7
    jbra SetDivTable_58
SetDivTable_54:         /* one byte */
    moveb %d6,%a3@+
    addqw #1,%d7
SetDivTable_58:         /* n copies */
    cmpw %d7,%d5
    jbgt SetDivTable_54
    addqw #1,%d6
    cmpw %d6,%d3
    jbgt SetDivTable_50
    extw %d4
    extl %d4
    movel %d4,%sp@-
    movel %a4,%sp@-
    jsr %pc@(HSetState_408439F0)
    addql #8,%sp
SetDivTable_70:         /* return */
    moveml %sp@+,%d3-%d7/%a3-%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40842466

/*
 insertInQueue(chan, cmd): add the 8-byte sound command to the channel's queue
 (interrupts blocked). SndChannel fields used: +4 first modifier, +8 callBack,
 +16 wait, +20 sync command, +28 flags (bit 1 quiet, 2 paused, 3 waiting for sync,
 4 queue empty), +30 queue length, +32 head (-1 = empty), +34 tail, +36 the queue.
 Result: 0, or 1 if the queue is full.
*/
insertInQueue:
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a4
    moveal %sp@(16),%a3
    jsr %pc@(BlockInts)
    movew %d0,%d7
    movew %a3@(32),%d0
    cmpw %a3@(34),%d0
    jbne insertInQueue_2A
    extl %d7
    movel %d7,%sp@-
    jsr %pc@(UnBlockInts)
    moveq #1,%d0
    addql #4,%sp
    jbra insertInQueue_72
insertInQueue_2A:       /* room: first command in an empty queue? */
    movew %a3@(32),%d0
    extl %d0
    moveq #-1,%d1
    cmpl %d0,%d1
    jbne insertInQueue_42
    movew %a3@(34),%a3@(32)
    andiw #-17,%a3@(28)
insertInQueue_42:       /* store it at the tail */
    movew %a3@(34),%d0
    addqw #1,%a3@(34)
    extl %d0
    asll #3,%d0
    lea %a3@(0x24,%d0:l),%a0
    moveal %a4,%a1
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    movew %a3@(34),%d0
    cmpw %a3@(30),%d0
    jbne insertInQueue_66
    clrw %a3@(34)
insertInQueue_66:       /* unblock, 0 */
    extl %d7
    movel %d7,%sp@-
    jsr %pc@(UnBlockInts)
    moveq #0,%d0
    addql #4,%sp
insertInQueue_72:       /* return */
    moveml %sp@+,%d7/%a3-%a4
    rts
    .long   0x00000000, 0x00000000	| 408424E8

/* nextFromQueue(chan, &cmd): take the command at the head. Result: 0, or 1 if empty. */
nextFromQueue:
    moveml %a3-%a4,%sp@-
    moveal %sp@(16),%a4
    moveal %sp@(12),%a3
    movew %a3@(32),%d0
    extl %d0
    moveq #-1,%d1
    cmpl %d0,%d1
    jbne nextFromQueue_1C
    moveq #1,%d0
    jbra nextFromQueue_58
nextFromQueue_1C:       /* copy it out, advance the head */
    movew %a3@(32),%d0
    addqw #1,%a3@(32)
    extl %d0
    asll #3,%d0
    lea %a3@(0x24,%d0:l),%a0
    moveal %a4,%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    movew %a3@(32),%d0
    cmpw %a3@(30),%d0
    jbne nextFromQueue_40
    clrw %a3@(32)
nextFromQueue_40:       /* now empty? head -1, flag bit 4 */
    movew %a3@(32),%d0
    cmpw %a3@(34),%d0
    jbne nextFromQueue_56
    movew #-1,%a3@(32)
    oriw #16,%a3@(28)
nextFromQueue_56:       /* 0 */
    moveq #0,%d0
nextFromQueue_58:       /* return */
    moveml %sp@+,%a3-%a4
    rts
    .short  0x0000	| 4084254E

/*
 ChannelModifier(chan, cmd): what the channel itself does with a command that reached
 the end of the modifier chain: quietCmd (3), flushCmd (4), waitCmd (10), pauseCmd
 (11), resumeCmd (12), callBackCmd (13), syncCmd (14), howOftenCmd (22), wakeUpCmd (23).
*/
ChannelModifier:
    linkw %fp,#0
    moveml %d3/%a3-%a4,%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(4),%a4
    jbra ChannelModifier_14
ChannelModifier_12:     /* find the last modifier of the chain */
    moveal %a4@,%a4
ChannelModifier_14:     /* (end of chain?) */
    tstl %a4@
    jbne ChannelModifier_12
    moveal %fp@(12),%a0
    movew %a0@,%d0
    subqw #3,%d0
    jbeq ChannelModifier_5E
    subqw #1,%d0
    jbeq ChannelModifier_6C
    subqw #6,%d0
    jbeq ChannelModifier_96
    subqw #1,%d0
    jbeq ChannelModifier_DC
    subqw #1,%d0
    jbeq ChannelModifier_EA
    subqw #1,%d0
    jbeq ChannelModifier_136
    subqw #1,%d0
    jbeq ChannelModifier_15A
    subqw #8,%d0
    jbeq ChannelModifier_1D6
    subqw #1,%d0
    jbeq ChannelModifier_21C
    subqw #7,%d0
    jbeq ChannelModifier_25C
    subqw #1,%d0
    jbeq ChannelModifier_25C
    jbra ChannelModifier_25C
ChannelModifier_5E:     /* quietCmd: flag bit 1 */
    moveal %fp@(8),%a0
    oriw #2,%a0@(28)
    jbra ChannelModifier_25C
ChannelModifier_6C:     /* flushCmd: empty the queue, cancel the timer */
    moveal %fp@(8),%a0
    movew #-1,%a0@(32)
    moveal %fp@(8),%a0
    clrw %a0@(34)
    movel %a4@(62),%sp@-
    jsr %pc@(CancelDriftOfTimer)
    moveal %fp@(8),%a0
    oriw #16,%a0@(28)
    addql #4,%sp
    jbra ChannelModifier_25C
ChannelModifier_96:     /* waitCmd: wait param1 half-milliseconds (timer in microseconds) */
    moveal %fp@(12),%a0
    movew %a0@(2),%d0
    extl %d0
    moveal %fp@(8),%a0
    movel %d0,%a0@(16)
    movel %a4@(62),%sp@-
    moveal %fp@(8),%a0
    movel %a0@(16),%d1
    movel %d1,%d0
    muluw #500,%d1
    swap %d0
    muluw #500,%d0
    swap %d0
    clrw %d0
    addl %d0,%d1
    movel %d1,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(SetNextInterrupt)
    lea %sp@(16),%sp
    jbra ChannelModifier_25C
ChannelModifier_DC:     /* pauseCmd: flag bit 2 */
    moveal %fp@(8),%a0
    oriw #4,%a0@(28)
    jbra ChannelModifier_25C
ChannelModifier_EA:     /* resumeCmd: clear pause and sync, run the queue again */
    moveal %fp@(8),%a0
    andiw #-13,%a0@(28)
    moveal %fp@(12),%a0
    moveal %a0@(4),%a4
    moveq #0,%d0
    movel %d0,%a4@(16)
    moveal %fp@(8),%a0
    movel %d0,%a0@(16)
    moveal %fp@(8),%a0
    movew %a0@(32),%d1
    extl %d1
    moveq #-1,%d2
    cmpl %d1,%d2
    jbeq ChannelModifier_25C
    movel %a4@(62),%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movel %d0,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(SetNextInterrupt)
    lea %sp@(16),%sp
    jbra ChannelModifier_25C
ChannelModifier_136:    /* callBackCmd: call the channel's callBack routine */
    moveal %fp@(8),%a0
    tstl %a0@(8)
    jbeq ChannelModifier_25C
    movel %fp@(8),%sp@-
    movel %fp@(12),%sp@-
    moveal %fp@(8),%a0
    movel %a0@(8),%sp@-
    jsr %pc@(CallPascal)
    jbra ChannelModifier_25C
ChannelModifier_15A:    /* syncCmd: keep the command, wait until all channels with the same id reach it */
    moveal %fp@(12),%a0
    moveal %fp@(8),%a1
    lea %a1@(20),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %fp@(8),%a0
    oriw #8,%a0@(28)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    moveal %a0@,%a3
    jbra ChannelModifier_1CE
ChannelModifier_180:    /* other channels waiting with the same id: count down */
    moveq #8,%d0
    andw %a3@(28),%d0
    jbeq ChannelModifier_1CC
    moveal %fp@(12),%a0
    movel %a3@(24),%d0
    cmpl %a0@(4),%d0
    jbne ChannelModifier_1CC
    subqw #1,%a3@(22)
    tstw %a3@(22)
    jbne ChannelModifier_1CC
    andiw #-9,%a3@(28)
    moveal %fp@(8),%a0
    movew %a0@(32),%d0
    extl %d0
    moveq #-1,%d1
    cmpl %d0,%d1
    jbeq ChannelModifier_1CC
    movel %a4@(62),%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movel %d0,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(SetNextInterrupt)
    lea %sp@(16),%sp
ChannelModifier_1CC:    /* next channel */
    moveal %a3@,%a3
ChannelModifier_1CE:    /* (end of the list?) */
    movel %a3,%d0
    jbne ChannelModifier_180
    jbra ChannelModifier_25C
ChannelModifier_1D6:    /* howOftenCmd: a modifier's tickle period (param1), start its timer */
    moveal %fp@(12),%a0
    moveal %a0@(4),%a4
    moveal %fp@(12),%a0
    movew %a0@(2),%d0
    extl %d0
    movel %d0,%a4@(16)
    movel %d0,%a4@(12)
    movel %a4@(58),%sp@-
    movel %a4@(12),%d1
    movel %d1,%d0
    muluw #500,%d1
    swap %d0
    muluw #500,%d0
    swap %d0
    clrw %d0
    addl %d0,%d1
    movel %d1,%sp@-
    movel %a4,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(SetNextInterrupt)
    lea %sp@(16),%sp
    jbra ChannelModifier_25C
ChannelModifier_21C:    /* wakeUpCmd: a modifier's one-time wake-up */
    moveal %fp@(12),%a0
    moveal %a0@(4),%a4
    moveal %fp@(12),%a0
    movew %a0@(2),%d0
    extl %d0
    movel %d0,%a4@(12)
    movel %a4@(58),%sp@-
    movel %a4@(12),%d1
    movel %d1,%d0
    muluw #500,%d1
    swap %d0
    muluw #500,%d0
    swap %d0
    clrw %d0
    addl %d0,%d1
    movel %d1,%sp@-
    movel %a4,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(SetNextInterrupt)
    lea %sp@(16),%sp
ChannelModifier_25C:    /* return */
    moveml %fp@(-12),%d3/%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408427B6

/*
 processCommandFrom(chan, cmd, modifier): send the command through the modifier chain
 from this modifier on (each one's routine is called in Pascal convention; it can
 keep asking for more with requestNextCmd, 21), then ChannelModifier at the end.
*/
processCommandFrom:
    linkw %fp,#0
    moveml %d6-%d7/%a3-%a4,%sp@-
    moveal %fp@(16),%a4
    moveal %fp@(12),%a3
    clrw %d6
processCommandFrom_12:  /* command still there? next modifier */
    tstw %a3@
    jbeq processCommandFrom_4E
    movel %a4,%d0
    jbeq processCommandFrom_40
    subql #2,%sp
    movel %fp@(8),%sp@-
    movel %a3,%sp@-
    movel %a4,%sp@-
    movel %a4@(4),%sp@-
    jsr %pc@(CallPascal)
    moveb %sp@+,%d7
    movel %a4@,%sp@-
    movel %a3,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(processCommandFrom)
    lea %sp@(12),%sp
    jbra processCommandFrom_4E
processCommandFrom_40:  /* end of the chain: the channel itself */
    clrb %d7
    movel %a3,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(ChannelModifier)
    addql #8,%sp
processCommandFrom_4E:  /* replace it with requestNextCmd (count), again if asked */
    movew #21,%a3@
    addqw #1,%d6
    movew %d6,%a3@(2)
    tstb %d7
    jbne processCommandFrom_12
    moveml %fp@(-16),%d6-%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40842826

/* processCommand(chan, cmd): from the first modifier (a quietCmd clears the quiet flag). */
processCommand:
    moveml %a3-%a4,%sp@-
    moveal %sp@(16),%a4
    moveal %sp@(12),%a3
    moveq #3,%d0
    cmpw %a4@,%d0
    jbne processCommand_18
    andiw #-3,%a3@(28)
processCommand_18:      /* through the chain */
    movel %a3@(4),%sp@-
    movel %a4,%sp@-
    movel %a3,%sp@-
    jsr %pc@(processCommandFrom)
    lea %sp@(12),%sp
    moveml %sp@+,%a3-%a4
    rts
    .short  0x0000	| 4084285E

/*
 processNextCommand(chan): take the next queued command and process it. Result: 1 if
 the queue was empty.
*/
processNextCommand:
    linkw %fp,#-8
    movel %a3,%sp@-
    moveal %fp@(8),%a3
    pea %fp@(-8)
    movel %a3,%sp@-
    jsr %pc@(nextFromQueue)
    tstb %d0
    addql #8,%sp
    jbeq processNextCommand_1E
    moveq #1,%d0
    jbra processNextCommand_2C
processNextCommand_1E:  /* process it */
    pea %fp@(-8)
    movel %a3,%sp@-
    jsr %pc@(processCommand)
    moveq #0,%d0
    addql #8,%sp
processNextCommand_2C:  /* return */
    moveal %fp@(-12),%a3
    unlk %fp
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40842894

/*
 sendEmptyCommand(chan): when the queue has just become empty, send emptyCmd (15) down
 the chain and stop the channel's timer.
*/
sendEmptyCommand:
    linkw %fp,#-8
    moveml %a3-%a4,%sp@-
    moveal %fp@(8),%a4
    moveq #16,%d0
    andw %a4@(28),%d0
    jbeq sendEmptyCommand_42
    movew #15,%fp@(-8)
    pea %fp@(-8)
    movel %a4,%sp@-
    jsr %pc@(processCommand)
    andiw #-17,%a4@(28)
    moveal %a4@(4),%a3
    addql #8,%sp
    jbra sendEmptyCommand_34
sendEmptyCommand_32:    /* find the last modifier */
    moveal %a3@,%a3
sendEmptyCommand_34:    /* (end?) */
    tstl %a3@
    jbne sendEmptyCommand_32
    movel %a3@(62),%sp@-
    jsr %pc@(CancelDriftOfTimer)
    addql #4,%sp
sendEmptyCommand_42:    /* return */
    moveml %fp@(-16),%a3-%a4
    unlk %fp
    rts
    .long   0x00000000	| 408428EC

/* tickleModifier(chan, modifier): send tickleCmd (20) to the modifier (its howOften timer). */
tickleModifier:
    linkw %fp,#-8
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(8),%a3
    movew #20,%fp@(-8)
    movel %a4,%sp@-
    pea %fp@(-8)
    movel %a3,%sp@-
    jsr %pc@(processCommandFrom)
    moveml %fp@(-16),%a3-%a4
    unlk %fp
    rts
    .long   0x00000000	| 4084291C

/*
 findModifier(routine): is a modifier with this routine installed on any channel?
 Result: the modifier, or 0. (Modifier record: +0 next, +4 routine, +12/+16 tickle
 counts, +20 flags, +21 handle state, +58/+62 timer records.)
*/
findModifier:
    linkw %fp,#-4
    moveml %d3/%a3-%a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(StripAddress_40843A40)
    movel %d0,%fp@(-4)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    moveal %a0@,%a4
    addql #4,%sp
    jbra findModifier_44
findModifier_22:        /* next channel: its modifiers */
    moveal %a4@(4),%a3
    jbra findModifier_3E
findModifier_28:        /* same routine? */
    movel %a3@(4),%sp@-
    jsr %pc@(StripAddress_40843A40)
    cmpl %fp@(-4),%d0
    addql #4,%sp
    jbne findModifier_3C
    movel %a3,%d0
    jbra findModifier_4A
findModifier_3C:        /* next modifier */
    moveal %a3@,%a3
findModifier_3E:        /* (end of the modifiers?) */
    movel %a3,%d0
    jbne findModifier_28
    moveal %a4@,%a4
findModifier_44:        /* (end of the channels?) */
    movel %a4,%d0
    jbne findModifier_22
    moveq #0,%d0
findModifier_4A:        /* return */
    moveml %fp@(-16),%d3/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40842974

/*
 disposChannel(chan): unlink the channel from the list, send freeCmd (2) to each
 modifier, release the resources they held (unhold the memory under VM), remove their
 timers, free them, free the channel (or unhold it if it was the caller's), and shrink
 the division table.
*/
disposChannel:
    linkw %fp,#-12
    moveml %d3/%a3-%a4,%sp@-
    movel %fp@(8),%sp@-
    jsr %pc@(StripAddress_40843A40)
    moveal %d0,%a3
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    lea %a0@,%a4
    addql #4,%sp
    jbra disposChannel_38
disposChannel_20:       /* this one? unlink it */
    movel %a4@,%sp@-
    jsr %pc@(StripAddress_40843A40)
    cmpal %d0,%a3
    addql #4,%sp
    jbne disposChannel_34
    moveal %fp@(8),%a0
    movel %a0@,%a4@
    jbra disposChannel_3C
disposChannel_34:       /* next in the list */
    moveal %a4@,%a0
    lea %a0@,%a4
disposChannel_38:       /* (end of the list?) */
    tstl %a4@
    jbne disposChannel_20
disposChannel_3C:       /* then each modifier */
    moveal %fp@(8),%a0
    moveal %a0@(4),%a3
    jbra disposChannel_DE
disposChannel_48:       /* freeCmd to it, release its resource if no other channel uses it */
    movew #2,%fp@(-8)
    movel %a3,%sp@-
    pea %fp@(-8)
    movel %fp@(8),%sp@-
    jsr %pc@(processCommandFrom)
    movel %a3@(4),%sp@-
    jsr %pc@(findModifier)
    tstl %d0
    lea %sp@(16),%sp
    jbne disposChannel_A6
    moveb %a3@(20),%d0
    btst #0,%d0
    jbeq disposChannel_A6
    moveb %a3@(21),%d0
    extw %d0
    extl %d0
    movel %d0,%sp@-
    movel %a3@(4),%sp@-
    jsr %pc@(RecoverHandle)
    moveal %d0,%a4
    addql #4,%sp
    movel %a4,%sp@-
    jsr %pc@(HSetState_408439F0)
    movel %a4,%sp@-
    jsr %pc@(GetHandleSize_40843A00)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a4@,%sp@-
    jsr %pc@(MyUnholdMemory)
    lea %sp@(16),%sp
disposChannel_A6:       /* remove its timers, free it */
    movel %a3@,%fp@(-12)
    movel %a3@(58),%sp@-
    jsr %pc@(RemoveXTimer)
    movel %a3@(58),%sp@-
    jsr %pc@(DisposPtr_408439A0)
    tstl %a3@
    addql #8,%sp
    jbne disposChannel_D2
    movel %a3@(62),%sp@-
    jsr %pc@(RemoveXTimer)
    movel %a3@(62),%sp@-
    jsr %pc@(DisposPtr_408439A0)
    addql #8,%sp
disposChannel_D2:       /* (last one: the channel's timer too) */
    movel %a3,%sp@-
    jsr %pc@(DisposPtr_408439A0)
    addql #4,%sp
    moveal %fp@(-12),%a3
disposChannel_DE:       /* next modifier */
    movel %a3,%d0
    jbne disposChannel_48
    moveal %fp@(8),%a0
    movew %a0@(28),%d0
    btst #0,%d0
    jbeq disposChannel_FE
    movel %fp@(8),%sp@-
    jsr %pc@(DisposPtr_408439A0)
    addql #4,%sp
    jbra disposChannel_10C
disposChannel_FE:       /* the caller's channel: unhold its 0x424 bytes */
    pea 0x424
    movel %fp@(8),%sp@-
    jsr %pc@(MyUnholdMemory)
    addql #8,%sp
disposChannel_10C:      /* one channel less: rebuild the division table */
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    tstw %a0@(4)
    jble disposChannel_148
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    subqw #1,%a0@(4)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %a0@(4),%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@(6),%sp@-
    jsr %pc@(SetDivTable)
    addql #8,%sp
disposChannel_148:      /* return */
    moveml %fp@(-24),%d3/%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40842AD2

/* checkChannel(chan): 1 if nil or its queue has no room (length 0). */
checkChannel:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    movel %a3,%d0
    jbne checkChannel_E
    moveq #1,%d0
    jbra checkChannel_16
checkChannel_E:         /* queue length 0? */
    tstw %a3@(30)
    seq %d0
    negb %d0
checkChannel_16:        /* return */
    moveal %sp@+,%a3
    rts
    .short  0x0000, 0x0000, 0x0000	| 40842AFA

/* MyHoldMemory(ptr, size): HoldMemory if virtual memory is on (Gestalt 'vm  '). */
MyHoldMemory:
    linkw %fp,#-4
    moveml %d7/%a3,%sp@-
    moveal %fp@(8),%a3
    pea %fp@(-4)
    movel #1986863136,%sp@-
    jsr %pc@(GestaltCall)
    tstl %fp@(-4)
    addql #8,%sp
    jbeq MyHoldMemory_30
    subql #2,%sp
    movel %a3,%sp@-
    movel %fp@(12),%sp@-
    jsr %pc@(HOLDMEMORY)
    movew %sp@+,%d7
MyHoldMemory_30:        /* return */
    moveml %fp@(-12),%d7/%a3
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000	| 40842B3A

/* MyUnholdMemory(ptr, size): UnholdMemory if virtual memory is on. */
MyUnholdMemory:
    linkw %fp,#-4
    moveml %d7/%a3,%sp@-
    moveal %fp@(8),%a3
    pea %fp@(-4)
    movel #1986863136,%sp@-
    jsr %pc@(GestaltCall)
    tstl %fp@(-4)
    addql #8,%sp
    jbeq MyUnholdMemory_30
    subql #2,%sp
    movel %a3,%sp@-
    movel %fp@(12),%sp@-
    jsr %pc@(UNHOLDMEMORY)
    movew %sp@+,%d7
MyUnholdMemory_30:      /* return */
    moveml %fp@(-12),%d7/%a3
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000	| 40842B7A

/*
 pumpResource(chan, sndHandle): play a format 1 'snd ' resource: install its modifiers
 (synthesizers) with SndAddModifier, then send each of its commands with SndDoCommand
 (an offset in param2 when bit 15 of the command is set, made an address).
*/
pumpResource:
    linkw %fp,#-12
    moveml %d3/%d6-%d7/%a3-%a4,%sp@-
    moveal %fp@(12),%a0
    moveal %a0@,%a4
    lea %a4@(4),%a3
    movew %a4@(2),%d7
    jbra pumpResource_38
pumpResource_18:        /* next modifier: SndAddModifier */
    subql #2,%sp
    movel %fp@(8),%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movew %a3@,%sp@-
    movel %a3@(2),%sp@-
    _SndAddModifier
    movew %sp@+,%d6
    jbeq pumpResource_32
    movew %d6,%d0
    jbra pumpResource_8E
pumpResource_32:        /* next */
    subqw #1,%d7
    addaw #6,%a3
pumpResource_38:        /* (count) */
    tstw %d7
    jbgt pumpResource_18
    movew %a3@,%d7
    moveal %a3,%a0
    addql #2,%a0
    movel %a0,%fp@(-12)
    jbra pumpResource_88
pumpResource_48:        /* next command: copy it */
    moveal %fp@(-12),%a0
    addql #8,%fp@(-12)
    lea %fp@(-8),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveq #0,%d0
    movew %fp@(-8),%d0
    movel #32768,%d1
    andl %d0,%d1
    jbeq pumpResource_74
    movel %a4,%d0
    addl %d0,%fp@(-4)
    andiw #32767,%fp@(-8)
pumpResource_74:        /* SndDoCommand */
    subql #2,%sp
    movel %fp@(8),%sp@-
    pea %fp@(-8)
    moveq #0,%d0
    moveb %d0,%sp@-
    _SndDoCommand
    addql #2,%sp
    subqw #1,%d7
pumpResource_88:        /* (count) */
    tstw %d7
    jbgt pumpResource_48
    moveq #0,%d0
pumpResource_8E:        /* return */
    moveml %fp@(-32),%d3/%d6-%d7/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000	| 40842C18

/*
 OnHowOften: Time Manager task of a modifier's howOften timer: tickle the modifier and
 start the timer again for its period.
*/
OnHowOften:
    linkw %fp,#-4
    moveml %a3-%a4,%sp@-
    jsr %pc@(GetTMRecordPtr)
    moveal %d0,%a4
    movel %a4@(22),%fp@(-4)
    moveal %a4@(26),%a3
    movel %a3,%sp@-
    movel %fp@(-4),%sp@-
    jsr %pc@(tickleModifier)
    tstl %a3@(16)
    addql #8,%sp
    jble OnHowOften_58
    movel %a3@(16),%a3@(12)
    movel %a4,%sp@-
    movel %a3@(16),%d1
    movel %d1,%d0
    muluw #500,%d1
    swap %d0
    muluw #500,%d0
    swap %d0
    clrw %d0
    addl %d0,%d1
    movel %d1,%sp@-
    movel %a3,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(SetNextInterrupt)
    lea %sp@(16),%sp
OnHowOften_58:          /* return */
    moveml %fp@(-12),%a3-%a4
    unlk %fp
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40842C82

/*
 OnWait: Time Manager task of the channel timer: the wait is over, so process the next
 commands until the queue is empty, paused, waiting or a new wait starts.
*/
OnWait:
    linkw %fp,#-4
    moveml %d7/%a3-%a4,%sp@-
    jsr %pc@(GetTMRecordPtr)
    movel %d0,%fp@(-4)
    moveal %fp@(-4),%a0
    moveal %a0@(22),%a3
    moveal %fp@(-4),%a0
    moveal %a0@(26),%a4
    movel %a3@(16),%d7
    moveq #0,%d0
    movel %d0,%a3@(16)
    tstl %d7
    jbne OnWait_60
    moveal %a3@(4),%a4
    jbra OnWait_36
OnWait_34:              /* find the last modifier */
    moveal %a4@,%a4
OnWait_36:              /* (end?) */
    tstl %a4@
    jbne OnWait_34
    movel %a4@(62),%sp@-
    jsr %pc@(CancelDriftOfTimer)
    addql #4,%sp
    jbra OnWait_60
OnWait_46:              /* next command */
    movel %a3,%sp@-
    jsr %pc@(processNextCommand)
    tstb %d0
    addql #4,%sp
    jbeq OnWait_60
    tstl %d7
    jbeq OnWait_6E
    movel %a3,%sp@-
    jsr %pc@(sendEmptyCommand)
    addql #4,%sp
    jbra OnWait_6E
OnWait_60:              /* go on unless waiting, paused or waiting for a sync */
    tstl %a3@(16)
    jbne OnWait_6E
    moveq #12,%d0
    andw %a3@(28),%d0
    jbeq OnWait_46
OnWait_6E:              /* return */
    moveml %fp@(-16),%d7/%a3-%a4
    unlk %fp
    rts
    .long   0x00000000, 0x00000000	| 40842D08

/*
 SNDAPPDEAD: the application is quitting: dispose of every channel that lives in the
 application heap, then turn all sound off.
*/
trap_SNDAPPDEAD:
SNDAPPDEAD:
    moveml %d3/%a3-%a4,%sp@-
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveq #-1,%d0
    cmpl %a0@,%d0
    jbeq SNDAPPDEAD_38
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    moveal %a0@,%a3
    jbra SNDAPPDEAD_34
SNDAPPDEAD_1C:          /* next channel: in the application heap? */
    moveal %a3@,%a4
    movel %a3,%sp@-
    jsr %pc@(inAppHeap)
    tstb %d0
    addql #4,%sp
    jbeq SNDAPPDEAD_32
    movel %a3,%sp@-
    jsr %pc@(disposChannel)
    addql #4,%sp
SNDAPPDEAD_32:          /* next */
    moveal %a4,%a3
SNDAPPDEAD_34:          /* (end?) */
    movel %a3,%d0
    jbne SNDAPPDEAD_1C
SNDAPPDEAD_38:          /* all sound off */
    jsr %pc@(SndAllOff)
    moveml %sp@+,%d3/%a3-%a4
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40842D52

/*
 ASYNCHCALLBACK(handleInfo, chan): end of an asynchronous SndPlay: restore the sound
 handle's state and mark the channel done (flag bit 5) so it is disposed later.
*/
ASYNCHCALLBACK:
    moveml %a3-%a4,%sp@-
    moveal %sp@(16),%a4
    moveal %sp@(12),%a3
    moveb %a3@(3),%d0
    extw %d0
    extl %d0
    movel %d0,%sp@-
    movel %a3@(4),%sp@-
    jsr %pc@(HSetState_408439F0)
    oriw #32,%a4@(28)
    addql #8,%sp
    moveml %sp@+,%a3-%a4
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/*
 SndDoCommand(chan, cmd, noWait): queue a command. If the queue is full, wait for room
 unless noWait (then queueFull, -203). Starts the channel if it was idle.
 Result: 0, -203 or badChannel (-205).
*/
trap_SndDoCommand:
SNDDOCOMMAND:
    linkw %fp,#0
    moveml %d5-%d7/%a3-%a4,%sp@-
    moveb %fp@(8),%d6
    moveal %fp@(14),%a4
    movel %a4,%sp@-
    jsr %pc@(checkChannel)
    tstb %d0
    addql #4,%sp
    jbeq SNDDOCOMMAND_24
    movew #-205,%fp@(18)
    jbra SNDDOCOMMAND_94
SNDDOCOMMAND_24:        /* find the last modifier (its timer runs the channel) */
    moveal %a4@(4),%a3
    jbra SNDDOCOMMAND_2C
SNDDOCOMMAND_2A:        /* next */
    moveal %a3@,%a3
SNDDOCOMMAND_2C:        /* (end?) */
    tstl %a3@
    jbne SNDDOCOMMAND_2A
SNDDOCOMMAND_30:        /* queue it, again while full unless noWait */
    movel %fp@(10),%sp@-
    movel %a4,%sp@-
    jsr %pc@(insertInQueue)
    moveb %d0,%d7
    addql #8,%sp
    jbeq SNDDOCOMMAND_44
    tstb %d6
    jbeq SNDDOCOMMAND_30
SNDDOCOMMAND_44:        /* idle (no wait, not paused, queue not empty)? start the channel timer now */
    jsr %pc@(BlockInts)
    movew %d0,%d5
    tstl %a4@(16)
    jbgt SNDDOCOMMAND_78
    moveq #12,%d0
    andw %a4@(28),%d0
    jbne SNDDOCOMMAND_78
    movew %a4@(32),%d0
    extl %d0
    moveq #-1,%d1
    cmpl %d0,%d1
    jbeq SNDDOCOMMAND_78
    movel %a3@(62),%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movel %d0,%sp@-
    movel %a4,%sp@-
    jsr %pc@(SetNextInterrupt)
    lea %sp@(16),%sp
SNDDOCOMMAND_78:        /* result */
    extl %d5
    movel %d5,%sp@-
    jsr %pc@(UnBlockInts)
    tstb %d7
    addql #4,%sp
    jbeq SNDDOCOMMAND_8E
    movel #-203,%d0
    jbra SNDDOCOMMAND_90
SNDDOCOMMAND_8E:        /* 0 */
    moveq #0,%d0
SNDDOCOMMAND_90:        /* store the result */
    movew %d0,%fp@(18)
SNDDOCOMMAND_94:        /* return, pop the parameters */
    moveml %fp@(-20),%d5-%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw #10,%sp
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 40842E34

/*
 SndDoImmediate(chan, cmd): process the command now, bypassing the queue
 (freqDurationCmd, 40, also stops the channel timer first). Result: 0 or -205.
*/
trap_SndDoImmediate:
SNDDOIMMEDIATE:
    linkw %fp,#-8
    moveml %a3-%a4,%sp@-
    moveal %fp@(12),%a4
    movel %a4,%sp@-
    jsr %pc@(checkChannel)
    tstb %d0
    addql #4,%sp
    jbeq SNDDOIMMEDIATE_20
    movew #-205,%fp@(16)
    jbra SNDDOIMMEDIATE_5C
SNDDOIMMEDIATE_20:      /* copy the command */
    moveal %fp@(8),%a0
    lea %fp@(-8),%a1
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %fp@(8),%a0
    moveq #40,%d0
    cmpw %a0@,%d0
    jbne SNDDOIMMEDIATE_4C
    moveal %a4@(4),%a3
    jbra SNDDOIMMEDIATE_3E
SNDDOIMMEDIATE_3C:      /* find the last modifier */
    moveal %a3@,%a3
SNDDOIMMEDIATE_3E:      /* (end?) */
    tstl %a3@
    jbne SNDDOIMMEDIATE_3C
    movel %a3@(62),%sp@-
    jsr %pc@(CancelDriftOfTimer)
    addql #4,%sp
SNDDOIMMEDIATE_4C:      /* process it */
    pea %fp@(-8)
    movel %a4,%sp@-
    jsr %pc@(processCommand)
    clrw %fp@(16)
    addql #8,%sp
SNDDOIMMEDIATE_5C:      /* return */
    moveml %fp@(-16),%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 40842EAA

/*
 SndNewChannel(&chan, synth, init, userRoutine): create (or take the caller's) sound
 channel, start the globals on first use, dispose finished asynchronous channels,
 install the synthesizer, link it in the channel list, rebuild the division table.
 Result: 0, badChannel (-205), channel already in use (-209) or a memory error.
*/
trap_SndNewChannel:
SNDNEWCHANNEL:
    linkw %fp,#0
    moveml %d3-%d7/%a3-%a4,%sp@-
    movew %fp@(16),%d5
    moveal %fp@(18),%a4
    movel %a4,%d0
    jbne SNDNEWCHANNEL_1E
    movew #-205,%fp@(22)
    jbra SNDNEWCHANNEL_1A2
SNDNEWCHANNEL_1E:       /* globals not made yet? make them */
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveq #-1,%d0
    cmpl %a0@,%d0
    jbne SNDNEWCHANNEL_3A
    jsr %pc@(INITGLOBALS)
    movew %d0,%d7
    jbeq SNDNEWCHANNEL_3A
    movew %d7,%fp@(22)
    jbra SNDNEWCHANNEL_1A2
SNDNEWCHANNEL_3A:       /* walk the channel list */
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    moveal %a0@,%a3
    jbra SNDNEWCHANNEL_66
SNDNEWCHANNEL_46:       /* the caller's channel is already in the list: -209 */
    cmpal %a4@,%a3
    jbne SNDNEWCHANNEL_54
    movew #-209,%fp@(22)
    jbra SNDNEWCHANNEL_1A2
SNDNEWCHANNEL_54:       /* finished asynchronous channel: dispose of it */
    moveq #32,%d0
    andw %a3@(28),%d0
    jbeq SNDNEWCHANNEL_64
    movel %a3,%sp@-
    jsr %pc@(disposChannel)
    addql #4,%sp
SNDNEWCHANNEL_64:       /* next */
    moveal %a3@,%a3
SNDNEWCHANNEL_66:       /* (end?) then the channel: allocate one if nil (0x424 bytes, 128 commands) */
    movel %a3,%d0
    jbne SNDNEWCHANNEL_46
    clrw %d6
    moveal %a4@,%a3
    movel %a3,%d0
    jbne SNDNEWCHANNEL_A4
    pea 0x424
    jsr %pc@(NewSysPtr)
    movel %d0,%a4@
    moveal %d0,%a3
    movel %a3,%d0
    addql #4,%sp
    jbne SNDNEWCHANNEL_90
    jsr %pc@(MemError)
    movew %d0,%fp@(22)
    jbra SNDNEWCHANNEL_1A2
SNDNEWCHANNEL_90:       /* ours: flag bit 0, queue length 128 */
    moveq #1,%d6
    clrw %a3@(28)
    oriw #1,%a3@(28)
    movew #128,%a3@(30)
    jbra SNDNEWCHANNEL_CA
SNDNEWCHANNEL_A4:       /* the caller's: its queue length must not be 0 */
    tstw %a3@(30)
    jbne SNDNEWCHANNEL_B4
    movew #-205,%fp@(22)
    jbra SNDNEWCHANNEL_1A2
SNDNEWCHANNEL_B4:       /* hold its memory (virtual memory) */
    clrw %a3@(28)
    andiw #-2,%a3@(28)
    pea 0x424
    movel %a3,%sp@-
    jsr %pc@(MyHoldMemory)
    addql #8,%sp
SNDNEWCHANNEL_CA:       /* initialise the fields, link it, one more channel */
    andiw #-31,%a3@(28)
    moveq #0,%d0
    movel %d0,%a3@(4)
    movel %fp@(8),%a3@(8)
    movel %d0,%a3@(12)
    movel %d0,%a3@(16)
    movew #-1,%a3@(32)
    clrw %a3@(34)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@,%a3@
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    addqw #1,%a0@(4)
    tstw %d5
    jbeq SNDNEWCHANNEL_132
    subql #2,%sp
    movel %a3,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    movew %d5,%sp@-
    movel %fp@(12),%sp@-
    _SndAddModifier
    movew %sp@+,%d7
    jbeq SNDNEWCHANNEL_132
    tstw %d6
    jbeq SNDNEWCHANNEL_124
    moveq #0,%d0
    movel %d0,%a4@
SNDNEWCHANNEL_124:      /* failed: dispose of it */
    movel %a3,%sp@-
    jsr %pc@(disposChannel)
    movew %d7,%fp@(22)
    addql #4,%sp
    jbra SNDNEWCHANNEL_1A2
SNDNEWCHANNEL_132:      /* put it at the head of the list, division table for the channel count */
    jsr %pc@(BlockInts)
    movew %d0,%d4
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a3,%a0@
    extl %d4
    movel %d4,%sp@-
    jsr %pc@(UnBlockInts)
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    moveq #1,%d0
    cmpw %a0@(4),%d0
    addql #4,%sp
    jbge SNDNEWCHANNEL_19E
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %a0@(4),%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@(6),%sp@-
    jsr %pc@(SetDivTable)
    tstw %d0
    sne %d7
    andiw #1,%d7
    addql #8,%sp
    jbeq SNDNEWCHANNEL_19E
    tstw %d6
    jbeq SNDNEWCHANNEL_190
    moveq #0,%d0
    movel %d0,%a4@
SNDNEWCHANNEL_190:      /* failed: dispose of it */
    movel %a3,%sp@-
    jsr %pc@(disposChannel)
    movew %d7,%fp@(22)
    addql #4,%sp
    jbra SNDNEWCHANNEL_1A2
SNDNEWCHANNEL_19E:      /* 0 */
    clrw %fp@(22)
SNDNEWCHANNEL_1A2:      /* return, pop the parameters */
    moveml %fp@(-28),%d3-%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw #14,%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843062

/*
 SndDisposeChannel(chan, quietNow): stop the channel (flushCmd and quietCmd now, or
 quietCmd queued and wait for it), then dispose of it. Result: 0 or -205.
*/
trap_SndDisposeChannel:
SNDDISPOSECHANNEL:
    linkw %fp,#-8
    movel %a3,%sp@-
    moveal %fp@(10),%a3
    movel %a3,%sp@-
    jsr %pc@(checkChannel)
    tstb %d0
    addql #4,%sp
    jbeq SNDDISPOSECHANNEL_1E
    movew #-205,%fp@(14)
    jbra SNDDISPOSECHANNEL_80
SNDDISPOSECHANNEL_1E:   /* already quiet? no: stop it */
    moveq #2,%d0
    andw %a3@(28),%d0
    jbne SNDDISPOSECHANNEL_74
    tstb %fp@(8)
    jbeq SNDDISPOSECHANNEL_50
    movew #4,%fp@(-8)
    subql #2,%sp
    movel %a3,%sp@-
    pea %fp@(-8)
    _SndDoImmediate
    movew #3,%fp@(-8)
    subql #2,%sp
    movel %a3,%sp@-
    pea %fp@(-8)
    _SndDoImmediate
    addql #4,%sp
    jbra SNDDISPOSECHANNEL_66
SNDDISPOSECHANNEL_50:   /* not now: queue quietCmd */
    movew #3,%fp@(-8)
    subql #2,%sp
    movel %a3,%sp@-
    pea %fp@(-8)
    moveq #0,%d0
    moveb %d0,%sp@-
    _SndDoCommand
    addql #2,%sp
SNDDISPOSECHANNEL_66:   /* wait for the quiet flag */
    moveq #2,%d0
    movel %d0,%sp@-
    pea %a3@(28)
    jsr %pc@(WaitBit)
    addql #8,%sp
SNDDISPOSECHANNEL_74:   /* dispose of it */
    movel %a3,%sp@-
    jsr %pc@(disposChannel)
    clrw %fp@(14)
    addql #4,%sp
SNDDISPOSECHANNEL_80:   /* return */
    moveal %fp@(-12),%a3
    unlk %fp
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@
    .long   0x00000000	| 408430FC

/*
 SndPlay(chan, sndHandle, async): play a 'snd ' resource. Checks the volume (0:
 -201), the handle (-204) and the format (1 or 2, else -206). Without a channel it makes
 its own (disposed at the end, or by ASYNCHCALLBACK when asynchronous). Format 1: adds
 the note synthesizer if the resource names none, then pumpResource. Format 2: the
 sampled sound synthesizer and a soundCmd (81) with the sound header. Result: 0 or an
 error.
*/
trap_SndPlay:
SNDPLAY:
    linkw %fp,#-12
    moveml %d4-%d7/%a3-%a4,%sp@-
    moveb %fp@(8),%d4
    moveal %fp@(14),%a4
    moveal %fp@(10),%a3
    tstb SdVolume
    jbne SNDPLAY_24
    movew #-201,%fp@(18)
    jbra SNDPLAY_294
SNDPLAY_24:             /* handle and data present? */
    movel %a3,%d0
    jbeq SNDPLAY_2C
    tstl %a3@
    jbne SNDPLAY_36
SNDPLAY_2C:             /* badHandle... -204 (resProblem) */
    movew #-204,%fp@(18)
    jbra SNDPLAY_294
SNDPLAY_36:             /* format 1 or 2? */
    moveal %a3@,%a0
    moveq #2,%d0
    cmpw %a0@,%d0
    jblt SNDPLAY_44
    moveal %a3@,%a0
    tstw %a0@
    jbgt SNDPLAY_4E
SNDPLAY_44:             /* -206 (badFormat) */
    movew #-206,%fp@(18)
    jbra SNDPLAY_294
SNDPLAY_4E:             /* lock it high, own channel needed? */
    movel %a3,%sp@-
    jsr %pc@(HGetState_408439E0)
    moveb %d0,%d6
    movel %a3,%sp@-
    jsr %pc@(MoveHHi)
    movel %a3,%sp@-
    jsr %pc@(HLock_408439B0)
    movel %a4,%d0
    seq %d5
    negb %d5
    lea %sp@(12),%sp
    jbeq SNDPLAY_A0
    moveq #0,%d0
    movel %d0,%fp@(-12)
    subql #2,%sp
    pea %fp@(-12)
    moveq #0,%d1
    movew %d1,%sp@-
    movel %d0,%sp@-
    pea %pc@(ASYNCHCALLBACK)
    _SndNewChannel
    movew %sp@+,%d7
    jbeq SNDPLAY_C8
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a3,%sp@-
    jsr %pc@(HSetState_408439F0)
    movew %d7,%fp@(18)
    addql #8,%sp
    jbra SNDPLAY_294
SNDPLAY_A0:             /* the caller's channel: check it */
    movel %a4,%sp@-
    jsr %pc@(checkChannel)
    tstb %d0
    addql #4,%sp
    jbeq SNDPLAY_C4
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a3,%sp@-
    jsr %pc@(HSetState_408439F0)
    movew #-205,%fp@(18)
    addql #8,%sp
    jbra SNDPLAY_294
SNDPLAY_C4:             /* use it */
    movel %a4,%fp@(-12)
SNDPLAY_C8:             /* format 1: synthesizer from the resource, or the note synthesizer (1) */
    moveal %a3@,%a0
    moveq #1,%d0
    cmpw %a0@,%d0
    jbne SNDPLAY_1BA
    moveal %a3@,%a0
    tstw %a0@(2)
    jbne SNDPLAY_140
    moveal %fp@(-12),%a0
    tstl %a0@(4)
    jbne SNDPLAY_140
    subql #2,%sp
    movel %fp@(-12),%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #1,%d1
    movew %d1,%sp@-
    movel %d0,%sp@-
    _SndAddModifier
    movew %sp@+,%d7
    jbeq SNDPLAY_140
    tstb %d5
    jbeq SNDPLAY_108
    movel %fp@(-12),%sp@-
    jsr %pc@(disposChannel)
    addql #4,%sp
SNDPLAY_108:            /* failed: dispose, restore, return the error */
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %a0@(4),%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movel %a0@(6),%sp@-
    jsr %pc@(SetDivTable)
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a3,%sp@-
    jsr %pc@(HSetState_408439F0)
    movew %d7,%fp@(18)
    lea %sp@(16),%sp
    jbra SNDPLAY_294
SNDPLAY_140:            /* install its modifiers and send its commands */
    movel %a3,%sp@-
    movel %fp@(-12),%sp@-
    jsr %pc@(pumpResource)
    movew %d0,%d7
    addql #8,%sp
    jbeq SNDPLAY_174
    tstb %d5
    jbeq SNDPLAY_15E
    movel %fp@(-12),%sp@-
    jsr %pc@(disposChannel)
    addql #4,%sp
SNDPLAY_15E:            /* failed: restore, return the error */
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a3,%sp@-
    jsr %pc@(HSetState_408439F0)
    movew %d7,%fp@(18)
    addql #8,%sp
    jbra SNDPLAY_294
SNDPLAY_174:            /* asynchronous with our channel: queue callBackCmd (13) to clean up */
    tstb %d4
    jbeq SNDPLAY_1A2
    tstb %d5
    jbeq SNDPLAY_1A2
    movew #13,%fp@(-8)
    extw %d6
    movew %d6,%fp@(-6)
    movel %a3,%fp@(-4)
    subql #2,%sp
    movel %fp@(-12),%sp@-
    pea %fp@(-8)
    moveq #0,%d0
    moveb %d0,%sp@-
    _SndDoCommand
    movew %sp@+,%d7
    jbra SNDPLAY_27E
SNDPLAY_1A2:            /* synchronous with our channel: SndDisposeChannel (waits for the end) */
    tstb %d5
    jbeq SNDPLAY_27E
    subql #2,%sp
    movel %fp@(-12),%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    _SndDisposeChannel
    movew %sp@+,%d7
    jbra SNDPLAY_27E
SNDPLAY_1BA:            /* format 2: the sampled sound synthesizer (5) */
    moveal %a3@,%a0
    moveq #2,%d0
    cmpw %a0@,%d0
    jbne SNDPLAY_27E
    subql #2,%sp
    movel %fp@(-12),%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #5,%d1
    movew %d1,%sp@-
    movel %d0,%sp@-
    _SndAddModifier
    movew %sp@+,%d7
    jbeq SNDPLAY_1FE
    tstb %d5
    jbeq SNDPLAY_1E8
    movel %fp@(-12),%sp@-
    jsr %pc@(disposChannel)
    addql #4,%sp
SNDPLAY_1E8:            /* failed: restore, return the error */
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a3,%sp@-
    jsr %pc@(HSetState_408439F0)
    movew %d7,%fp@(18)
    addql #8,%sp
    jbra SNDPLAY_294
SNDPLAY_1FE:            /* soundCmd (81) with the sound header after the commands */
    movew #81,%fp@(-8)
    clrw %fp@(-6)
    moveal %a3@,%a4
    addql #4,%a4
    movel %a4,%d0
    addql #2,%d0
    movew %a4@,%d1
    extl %d1
    asll #3,%d1
    addl %d0,%d1
    movel %d1,%fp@(-4)
    subql #2,%sp
    movel %fp@(-12),%sp@-
    pea %fp@(-8)
    moveq #0,%d0
    moveb %d0,%sp@-
    _SndDoCommand
    movew %sp@+,%d7
    jbeq SNDPLAY_240
    tstb %d5
    jbeq SNDPLAY_27E
    movel %fp@(-12),%sp@-
    jsr %pc@(disposChannel)
    addql #4,%sp
    jbra SNDPLAY_27E
SNDPLAY_240:            /* asynchronous: callBackCmd */
    tstb %d4
    jbeq SNDPLAY_26C
    tstb %d5
    jbeq SNDPLAY_26C
    movew #13,%fp@(-8)
    extw %d6
    movew %d6,%fp@(-6)
    movel %a3,%fp@(-4)
    subql #2,%sp
    movel %fp@(-12),%sp@-
    pea %fp@(-8)
    moveq #0,%d0
    moveb %d0,%sp@-
    _SndDoCommand
    movew %sp@+,%d7
    jbra SNDPLAY_27E
SNDPLAY_26C:            /* synchronous: SndDisposeChannel */
    tstb %d5
    jbeq SNDPLAY_27E
    subql #2,%sp
    movel %fp@(-12),%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    _SndDisposeChannel
    movew %sp@+,%d7
SNDPLAY_27E:            /* synchronous: restore the handle state */
    tstb %d4
    jbne SNDPLAY_290
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a3,%sp@-
    jsr %pc@(HSetState_408439F0)
    addql #8,%sp
SNDPLAY_290:            /* result */
    movew %d7,%fp@(18)
SNDPLAY_294:            /* return, pop the parameters */
    moveml %fp@(-36),%d4-%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw #10,%sp
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 408433A4

/*
 SndControl(id, cmd): send a command to a synthesizer without a channel: its 'snd '
 resource is looked for by id + 0x800 (ASC machines) or + 0x1000 (others), then by id;
 its code is called with the command. id 0: the channel code itself.
 Result: 0, a resource error or -204.
*/
trap_SndControl:
SNDCONTROL:
    linkw %fp,#-4
    moveml %d4-%d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    movew %fp@(12),%d7
    jbeq SNDCONTROL_FA
    movew %d7,%d5
    cmpiw #2048,%d7
    jbge SNDCONTROL_42
    jsr %pc@(IsAscMac)
    tstw %d0
    jbeq SNDCONTROL_3E
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    tstb %a0@(46)
    jbeq SNDCONTROL_38
    cmpiw #5,%d7
    jbne SNDCONTROL_3E
SNDCONTROL_38:          /* ASC version or id 5: id + 0x800 */
    addiw #2048,%d5
    jbra SNDCONTROL_42
SNDCONTROL_3E:          /* id + 0x1000 */
    addiw #4096,%d5
SNDCONTROL_42:          /* GetResource('snd ', the adjusted id) */
    moveq #0,%d0
    moveb ResLoad,%d0
    movew %d0,%d4
    moveq #1,%d0
    moveb %d0,%sp@-
    _SetResLoad
    subql #4,%sp
    movel #1936618600,%sp@-
    movew %d5,%sp@-
    jsr %pc@(MYGETRESOURCE)
    moveal %sp@+,%a3
    movel %a3,%d0
    jbeq SNDCONTROL_68
    tstl %a3@
    jbne SNDCONTROL_A0
SNDCONTROL_68:          /* not there: by the plain id */
    subql #4,%sp
    movel #1936618600,%sp@-
    movew %d7,%sp@-
    jsr %pc@(MYGETRESOURCE)
    moveal %sp@+,%a3
    movel %a3,%d0
    jbeq SNDCONTROL_80
    tstl %a3@
    jbne SNDCONTROL_A0
SNDCONTROL_80:          /* none: ResError or -204 */
    subql #2,%sp
    _ResError
    movew %sp@+,%d6
    jbeq SNDCONTROL_8E
    extl %d6
    movel %d6,%d0
    jbra SNDCONTROL_94
SNDCONTROL_8E:          /* -204 */
    movel #-204,%d0
SNDCONTROL_94:          /* return the error */
    movew %d0,%d6
    moveb %d4,%sp@-
    _SetResLoad
    movew %d6,%fp@(14)
    jbra SNDCONTROL_10A
SNDCONTROL_A0:          /* lock it, hold its memory, call it, restore */
    moveb %d4,%sp@-
    _SetResLoad
    movel %a3,%sp@-
    jsr %pc@(HGetState_408439E0)
    moveb %d0,%d4
    movel %a3,%sp@-
    jsr %pc@(HLock_408439B0)
    movel %a3,%sp@-
    jsr %pc@(GetHandleSize_40843A00)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a3@,%sp@-
    jsr %pc@(MyHoldMemory)
    movel %a3@,%fp@(-4)
    subql #2,%sp
    moveq #0,%d0
    movel %d0,%sp@-
    movel %a4,%sp@-
    movel %d0,%sp@-
    movel %fp@(-4),%sp@-
    jsr %pc@(CallPascal)
    extw %d4
    extl %d4
    movel %d4,%sp@-
    movel %a3,%sp@-
    jsr %pc@(HSetState_408439F0)
    movel %a3,%sp@-
    jsr %pc@(GetHandleSize_40843A00)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a3@,%sp@-
    jsr %pc@(MyUnholdMemory)
    lea %sp@(34),%sp
    jbra SNDCONTROL_106
SNDCONTROL_FA:          /* id 0: ChannelModifier */
    movel %a4,%sp@-
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(ChannelModifier)
    addql #8,%sp
SNDCONTROL_106:         /* 0 */
    clrw %fp@(14)
SNDCONTROL_10A:         /* return */
    moveml %fp@(-28),%d4-%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addqw #6,%sp
    jmp %a0@
    .long   0x00000000, 0x00000000	| 408434C8

/*
 SndAddModifier(chan, modifier, id, init): install a modifier (or the synthesizer 'snd '
 resource id when modifier is nil) at the head of the channel's chain. Synthesizer
 availability is checked against SoundActive (-201 if the hardware is busy or the
 synthesizer does not fit). Allocates the modifier record (112 bytes) and its two
 Time Manager records (howOften: OnHowOften, and for the first modifier the channel
 timer: OnWait), sends initCmd (1) and links it. For the sampled synthesizer on ASC
 machines, checks the CPU load (availableCmd 26 / loadCmd 27). Result: 0, -201, -204,
 -205, -108 (initCmd failed: no memory) or a resource error.
*/
trap_SndAddModifier:
SNDADDMODIFIER:
    linkw %fp,#-12
    moveml %d4-%d7/%a3-%a4,%sp@-
    movel %fp@(8),%d4
    movew %fp@(12),%d7
    movel %fp@(18),%sp@-
    jsr %pc@(checkChannel)
    tstb %d0
    addql #4,%sp
    jbeq SNDADDMODIFIER_28
    movew #-205,%fp@(22)
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_28:      /* modifier given? nothing (id 0)? */
    tstl %fp@(14)
    jbne SNDADDMODIFIER_136
    tstw %d7
    jbne SNDADDMODIFIER_3C
    clrw %fp@(22)
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_3C:      /* sound hardware in use (SoundActive)? */
    tstb SoundActive
    jbeq SNDADDMODIFIER_9E
    tstb SoundActive
    jbge SNDADDMODIFIER_52
    movew #-201,%fp@(22)
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_52:      /* note synthesizer (1) not available then */
    cmpiw #1,%d7
    jbne SNDADDMODIFIER_62
    movew #-201,%fp@(22)
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_62:      /* sampled synthesizer (5) needs an ASC */
    cmpiw #5,%d7
    jbne SNDADDMODIFIER_7A
    jsr %pc@(IsAscMac)
    tstl %d0
    jbne SNDADDMODIFIER_7A
    movew #-201,%fp@(22)
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_7A:      /* wave table (3) or sampled (5) must be the one active */
    cmpiw #3,%d7
    jbeq SNDADDMODIFIER_86
    cmpiw #5,%d7
    jbne SNDADDMODIFIER_9E
SNDADDMODIFIER_86:      /* (compare) */
    moveb SoundActive,%d0
    extw %d0
    extl %d0
    extl %d7
    cmpl %d0,%d7
    jbeq SNDADDMODIFIER_9E
    movew #-201,%fp@(22)
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_9E:      /* resource id adjusted for the hardware (+0x800 or +0x1000) */
    movew %d7,%d5
    cmpiw #2048,%d7
    jbge SNDADDMODIFIER_CC
    jsr %pc@(IsAscMac)
    tstl %d0
    jbeq SNDADDMODIFIER_C8
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    tstb %a0@(46)
    jbeq SNDADDMODIFIER_C2
    cmpiw #5,%d7
    jbne SNDADDMODIFIER_C8
SNDADDMODIFIER_C2:      /* ASC: +0x800 */
    addiw #2048,%d5
    jbra SNDADDMODIFIER_CC
SNDADDMODIFIER_C8:      /* +0x1000 */
    addiw #4096,%d5
SNDADDMODIFIER_CC:      /* GetResource('snd ', id) */
    moveq #0,%d0
    moveb ResLoad,%d0
    movew %d0,%d6
    moveq #1,%d0
    moveb %d0,%sp@-
    _SetResLoad
    subql #4,%sp
    movel #1936618600,%sp@-
    movew %d5,%sp@-
    jsr %pc@(MYGETRESOURCE)
    moveal %sp@+,%a4
    movel %a4,%d0
    jbeq SNDADDMODIFIER_F2
    tstl %a4@
    jbne SNDADDMODIFIER_132
SNDADDMODIFIER_F2:      /* not there: the plain id */
    cmpiw #2048,%d7
    jbge SNDADDMODIFIER_108
    subql #4,%sp
    movel #1936618600,%sp@-
    movew %d7,%sp@-
    jsr %pc@(MYGETRESOURCE)
    moveal %sp@+,%a4
SNDADDMODIFIER_108:     /* found? */
    movel %a4,%d0
    jbeq SNDADDMODIFIER_110
    tstl %a4@
    jbne SNDADDMODIFIER_132
SNDADDMODIFIER_110:     /* none: ResError or -204 */
    subql #2,%sp
    _ResError
    movew %sp@+,%d5
    jbeq SNDADDMODIFIER_11E
    extl %d5
    movel %d5,%d0
    jbra SNDADDMODIFIER_124
SNDADDMODIFIER_11E:     /* -204 */
    movel #-204,%d0
SNDADDMODIFIER_124:     /* return the error */
    movew %d0,%d5
    moveb %d6,%sp@-
    _SetResLoad
    movew %d5,%fp@(22)
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_132:     /* restore ResLoad */
    moveb %d6,%sp@-
    _SetResLoad
SNDADDMODIFIER_136:     /* lock the code high and hold it */
    tstl %fp@(14)
    jbne SNDADDMODIFIER_164
    movel %a4,%sp@-
    jsr %pc@(HGetState_408439E0)
    moveb %d0,%d6
    movel %a4,%sp@-
    jsr %pc@(MoveHHi)
    movel %a4,%sp@-
    jsr %pc@(HLock_408439B0)
    movel %a4,%sp@-
    jsr %pc@(GetHandleSize_40843A00)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a4@,%sp@-
    jsr %pc@(MyHoldMemory)
    lea %sp@(20),%sp
SNDADDMODIFIER_164:     /* the modifier record */
    moveq #112,%d0
    movel %d0,%sp@-
    jsr %pc@(NewSysPtr)
    moveal %d0,%a3
    movel %a3,%d0
    addql #4,%sp
    jbne SNDADDMODIFIER_1A6
    tstl %fp@(14)
    jbne SNDADDMODIFIER_19A
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a4,%sp@-
    jsr %pc@(HSetState_408439F0)
    movel %a4,%sp@-
    jsr %pc@(GetHandleSize_40843A00)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a4@,%sp@-
    jsr %pc@(MyUnholdMemory)
    lea %sp@(16),%sp
SNDADDMODIFIER_19A:     /* no memory */
    jsr %pc@(MemError)
    movew %d0,%fp@(22)
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_1A6:     /* its howOften timer record (30 bytes) */
    moveq #0,%d0
    movel %d0,%a3@(12)
    movel %d0,%a3@(16)
    movel %d0,%a3@(8)
    clrb %a3@(20)
    moveq #30,%d1
    movel %d1,%sp@-
    jsr %pc@(NewSysPtr)
    movel %d0,%a3@(58)
    addql #4,%sp
    jbne SNDADDMODIFIER_1FA
    tstl %fp@(14)
    jbne SNDADDMODIFIER_1EE
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a4,%sp@-
    jsr %pc@(HSetState_408439F0)
    movel %a4,%sp@-
    jsr %pc@(GetHandleSize_40843A00)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a4@,%sp@-
    jsr %pc@(MyUnholdMemory)
    lea %sp@(16),%sp
SNDADDMODIFIER_1EE:     /* no memory */
    jsr %pc@(MemError)
    movew %d0,%fp@(22)
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_1FA:     /* OnHowOften, install it. First modifier: the channel timer too */
    moveal %a3@(58),%a0
    moveq #0,%d0
    movel %d0,%a0@(14)
    lea %pc@(OnHowOften),%a0
    moveal %a3@(58),%a1
    movel %a0,%a1@(6)
    moveal %a3@(58),%a0
    movel %fp@(18),%a0@(22)
    moveal %a3@(58),%a0
    movel %a3,%a0@(26)
    movel %a3@(58),%sp@-
    jsr %pc@(InstallXTimer)
    moveal %fp@(18),%a0
    tstl %a0@(4)
    addql #4,%sp
    jbne SNDADDMODIFIER_2AC
    moveq #30,%d0
    movel %d0,%sp@-
    jsr %pc@(NewSysPtr)
    movel %d0,%a3@(62)
    addql #4,%sp
    jbne SNDADDMODIFIER_282
    tstl %fp@(14)
    jbne SNDADDMODIFIER_26C
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a4,%sp@-
    jsr %pc@(HSetState_408439F0)
    movel %a4,%sp@-
    jsr %pc@(GetHandleSize_40843A00)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a4@,%sp@-
    jsr %pc@(MyUnholdMemory)
    lea %sp@(16),%sp
SNDADDMODIFIER_26C:     /* no memory */
    movel %a3@(58),%sp@-
    jsr %pc@(DisposPtr_408439A0)
    jsr %pc@(MemError)
    movew %d0,%fp@(22)
    addql #4,%sp
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_282:     /* OnWait, install it */
    moveal %a3@(62),%a0
    moveq #0,%d0
    movel %d0,%a0@(14)
    lea %pc@(OnWait),%a0
    moveal %a3@(62),%a1
    movel %a0,%a1@(6)
    moveal %a3@(62),%a0
    movel %fp@(18),%a0@(22)
    movel %a3@(62),%sp@-
    jsr %pc@(InstallXTimer)
    addql #4,%sp
SNDADDMODIFIER_2AC:     /* the code: shared state with another user of the same code */
    tstl %fp@(14)
    jbne SNDADDMODIFIER_2DC
    orib #1,%a3@(20)
    movel %a4@,%sp@-
    jsr %pc@(findModifier)
    movel %d0,%fp@(-12)
    addql #4,%sp
    jbeq SNDADDMODIFIER_2D2
    moveal %fp@(-12),%a0
    moveb %a0@(21),%a3@(21)
    jbra SNDADDMODIFIER_2D6
SNDADDMODIFIER_2D2:     /* (first user: the handle state) */
    moveb %d6,%a3@(21)
SNDADDMODIFIER_2D6:     /* routine = the resource's code */
    movel %a4@,%a3@(4)
    jbra SNDADDMODIFIER_2E2
SNDADDMODIFIER_2DC:     /* routine = the caller's modifier */
    movel %fp@(14),%a3@(4)
SNDADDMODIFIER_2E2:     /* sampled synthesizer on an ASC: enough CPU time? (availableCmd) */
    cmpiw #5,%d7
    jbne SNDADDMODIFIER_386
    jsr %pc@(IsAscMac)
    tstl %d0
    jbeq SNDADDMODIFIER_386
    movew #26,%fp@(-8)
    movel %d4,%fp@(-4)
    subql #2,%sp
    moveq #5,%d0
    movew %d0,%sp@-
    pea %fp@(-8)
    _SndControl
    movew %sp@+,%d5
    jsr %pc@(SMGlobalLoc)
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %fp@(-6),%d0
    cmpw %a0@(22),%d0
    jble SNDADDMODIFIER_360
    tstl %fp@(14)
    jbne SNDADDMODIFIER_344
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a4,%sp@-
    jsr %pc@(HSetState_408439F0)
    movel %a4,%sp@-
    jsr %pc@(GetHandleSize_40843A00)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a4@,%sp@-
    jsr %pc@(MyUnholdMemory)
    lea %sp@(16),%sp
SNDADDMODIFIER_344:     /* too much load: -201 */
    movel %a3@(58),%sp@-
    jsr %pc@(DisposPtr_408439A0)
    movel %a3@(62),%sp@-
    jsr %pc@(DisposPtr_408439A0)
    movew #-201,%fp@(22)
    addql #8,%sp
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_360:     /* loadCmd: the load it adds (+96/+100) */
    movew #27,%fp@(-8)
    movel %d4,%fp@(-4)
    subql #2,%sp
    moveq #5,%d0
    movew %d0,%sp@-
    pea %fp@(-8)
    _SndControl
    movew %sp@+,%d5
    movew %fp@(-6),%d0
    extl %d0
    movel %d0,%a3@(100)
    movel %d4,%a3@(96)
SNDADDMODIFIER_386:     /* initCmd through the new modifier */
    jsr %pc@(BlockInts)
    movew %d0,%d5
    movew #1,%fp@(-8)
    movel %d4,%fp@(-4)
    movel %a3,%sp@-
    pea %fp@(-8)
    movel %fp@(18),%sp@-
    jsr %pc@(processCommandFrom)
    moveq #-1,%d0
    cmpl %fp@(-4),%d0
    lea %sp@(12),%sp
    jbne SNDADDMODIFIER_3FA
    tstl %fp@(14)
    jbne SNDADDMODIFIER_3D6
    extw %d6
    extl %d6
    movel %d6,%sp@-
    movel %a4,%sp@-
    jsr %pc@(HSetState_408439F0)
    movel %a4,%sp@-
    jsr %pc@(GetHandleSize_40843A00)
    addql #4,%sp
    movel %d0,%sp@-
    movel %a4@,%sp@-
    jsr %pc@(MyUnholdMemory)
    lea %sp@(16),%sp
SNDADDMODIFIER_3D6:     /* failed: free, -108 */
    movel %a3@(58),%sp@-
    jsr %pc@(DisposPtr_408439A0)
    movel %a3@(62),%sp@-
    jsr %pc@(DisposPtr_408439A0)
    extl %d5
    movel %d5,%sp@-
    jsr %pc@(UnBlockInts)
    movew #-108,%fp@(22)
    lea %sp@(12),%sp
    jbra SNDADDMODIFIER_418
SNDADDMODIFIER_3FA:     /* link it at the head of the chain, 0 */
    moveal %fp@(18),%a0
    movel %a0@(4),%a3@
    moveal %fp@(18),%a0
    movel %a3,%a0@(4)
    extl %d5
    movel %d5,%sp@-
    jsr %pc@(UnBlockInts)
    clrw %fp@(22)
    addql #4,%sp
SNDADDMODIFIER_418:     /* return, pop the parameters */
    moveml %fp@(-36),%d4-%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw #14,%sp
    jmp %a0@
    .long   0x00000000, 0x00000000	| 408438F8

/*
 CallPascal / CALLCALLBACKROUTINE / CALLMODIFIERROUTINE: call the routine passed as the
 last argument, with the Pascal arguments already on the stack.
*/
CallPascal:
CALLCALLBACKROUTINE:
CALLMODIFIERROUTINE:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a0,%sp@-
    jmp %a1@
    .long   0x00000000, 0x00000000	| 40843908

/* InstallXTimer / TimerCode: _InsXTime the Time Manager record (extended: no drift). */
InstallXTimer:
TimerCode:
    moveal %sp@(4),%a0
    .short  0xA458	| 40843914 _InsTime (flags 0x0400)
    rts

/* GetTMRecordPtr: in a Time Manager task, the task record (a1). */
GetTMRecordPtr:
    movel %a1,%d0
    rts

/* CancelDriftOfTimer(tm): stop the timer and install it again (no pending time). */
CancelDriftOfTimer:
    moveal %sp@(4),%a0
    _RmvTime
    clrl %a0@(14)
    .short  0xA458	| 40843926 _InsTime (flags 0x0400)
    rts

/*
 SetNextInterrupt(chan, mod, delay, tm): start the Time Manager task tm for delay
 microseconds (negative to PrimeTime); with mod nil, only if it is not already running.
*/
SetNextInterrupt:
    moveal %sp@(16),%a0
    tstl %sp@(8)
    jbne SetNextInterrupt_1E
    movew %a0@(4),%d0
    btst #15,%d0
    jbne SetNextInterrupt_1C
    movel %sp@(12),%d0
    negl %d0
    _PrimeTime
SetNextInterrupt_1C:    /* already running: leave it */
    rts
SetNextInterrupt_1E:    /* restart it if running */
    movew %a0@(4),%d0
    btst #15,%d0
    jbeq SetNextInterrupt_30
    _RmvTime
    clrl %a0@(14)
    .short  0xA458	| 40843958 _InsTime (flags 0x0400)
SetNextInterrupt_30:    /* PrimeTime */
    movel %sp@(12),%d0
    negl %d0
    _PrimeTime
    rts

/* RemoveXTimer(tm): _RmvTime. */
RemoveXTimer:
    moveal %sp@(4),%a0
    _RmvTime
    rts
    .long   0x00000000	| 4084396C

/* NewPtr(size) (raw words): _NewPtr (current heap, clear). */
NewPtr:
    movel %sp@(4),%d0
    .short  0xA31E	| 40843974 _NewPtr (flags 0x0300)
    movel %a0,%d0
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 4084397E

/* NewSysPtr(size): _NewPtr in the system heap, cleared. Result: the pointer. */
NewSysPtr:
    movel %sp@(4),%d0
    .short  0xA71E	| 40843984 _NewPtr (flags 0x0700)
    movel %a0,%d0
    rts
    .short  0x0000, 0x0000, 0x0000	| 4084398A

/* NewSysHandle(size): _NewHandle in the system heap, cleared. */
NewSysHandle:
    movel %sp@(4),%d0
    .short  0xA722	| 40843994 _NewHandle (flags 0x0700)
    movel %a0,%d0
    rts
    .short  0x0000, 0x0000, 0x0000	| 4084399A

/*
 C glue for the Memory Manager traps (argument on the stack, result in d0):
 DisposPtr, HLock, HUnlock, MoveHHi, HGetState, HSetState, GetHandleSize,
 BlockMove, SetHandleSize, MemError (MemErr), StripAddress, RecoverHandle.
*/
DisposPtr_408439A0:
    moveal %sp@(4),%a0
    _DisposPtr
    rts
    .long   0x00000000, 0x00000000	| 408439A8

HLock_408439B0:         /* set up and call _HLock */
    moveal %sp@(4),%a0
    _HLock
    rts
    .long   0x00000000, 0x00000000	| 408439B8
HUnlock_408439C0:       /* (data) */
    moveal %sp@(4),%a0
    _HUnlock
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 408439C8

MoveHHi:                /* set up and call _MoveHHi */
    moveal %sp@(4),%a0
    _MoveHHi
    rts
    .long   0x00000000, 0x00000000	| 408439D8

HGetState_408439E0:     /* set up and call _HGetState */
    moveal %sp@(4),%a0
    _HGetState
    rts
    .long   0x00000000, 0x00000000	| 408439E8

HSetState_408439F0:     /* set up and call _HSetState */
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
    _HSetState
    rts
    .long   0x00000000	| 408439FC

GetHandleSize_40843A00:  /* set up and call _GetHandleSize */
    moveal %sp@(4),%a0
    _GetHandleSize
    rts
    .long   0x00000000, 0x00000000	| 40843A08
BLOCKMOVE_40843A10:     /* (data) */
    moveal %sp@(12),%a0
    moveal %sp@(8),%a1
    movel %sp@(4),%d0
    _BlockMove
    rts

SetHandleSize_40843A20:  /* set up and call _SetHandleSize */
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
    _SetHandleSize
    rts
    .long   0x00000000	| 40843A2C

MemError:               /* clear %d0 */
    moveq #0,%d0
    movew MemErr,%d0
    rts
    .long   0x00000000, 0x00000000	| 40843A38

StripAddress_40843A40:  /* set up and call _StripAddress */
    movel %sp@(4),%d0
    _StripAddress
    rts
    .long   0x00000000, 0x00000000	| 40843A48

RecoverHandle:          /* set %a0 */
    moveal %sp@(4),%a0
    .short  0xA128	| 40843A54 _RecoverHandle (flags 0x0100)
    movel %a0,%d0
    rts

/*
 SLODMULTIPLIERS: CPU load factors for the 'slod' table when the machine has no 'slod'
 resource (scaled by the machine's speed in CALCULATESLOD).
*/
SLODMULTIPLIERS:
    .short  0x000A, 0x0011, 0x0017	| 40843A5A
    .long   0x00070009, 0x000B0010, 0x0021002E, 0x00220031	| 40843A60
    .long   0x000E0018, 0x0021002C, 0x0010000D, 0x00000000	| 40843A70

/* CALCULATESLOD(&factor): factor x 2656 / TimeDBRA: the load on this CPU. */
CALCULATESLOD:
    moveal %sp@(4),%a0
    moveq #0,%d0
    movew %a0@,%d0
    muluw #2656,%d0
    divuw TimeDBRA,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843A92

/* WaitBit(&word, mask): wait until (word & mask) is nonzero. */
WaitBit:
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
WaitBit_8:              /* poll */
    movew %a0@,%d1
    andw %d0,%d1
    jbeq WaitBit_8
    rts

/* inAppHeap(ptr): 1 if the pointer is inside the application heap. */
inAppHeap:
    movel %sp@(4),%d0
    _StripAddress
    movel %d0,%sp@-
    movel ApplZone,%d0
    _StripAddress
    cmpl %sp@,%d0
    jbhi inAppHeap_24
    moveal ApplZone,%a0
    movel %a0@,%d0
    _StripAddress
    cmpl %sp@,%d0
    jbcs inAppHeap_24
    moveq #1,%d0
    addqw #4,%sp
    rts
inAppHeap_24:           /* 0 */
    moveq #0,%d0
    addqw #4,%sp
    rts
    .short  0x0000, 0x0000, 0x0000	| 40843ADA

/* SndAllOff: sound off (VIA 1 port A bit 7). */
SndAllOff:
    moveal VIA,%a0
    bset #7,%a0@
    rts
    .short  0x0000, 0x0000, 0x0000	| 40843AEA

/* BlockInts: raise the interrupt level to 2 (sound and lower interrupts masked). Result: old sr. */
BlockInts:
    movew %sr,%d0
    oriw #1792,%sr
    andiw #-1281,%sr
    rts
    .long   0x00000000	| 40843AFC

/* UnBlockInts(sr): restore the interrupt level. */
UnBlockInts:
    movew %sp@(6),%sr
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843B06

/*
 GestaltCall(selector, &result): Gestalt, if the trap is implemented (its address is
 not that of the unimplemented trap). Result: the error, the answer stored.
*/
GestaltCall:
    movew #-24147,%d0
    .short  0xA346	| 40843B14 _GetTrapAddress (flags 0x0300)
    movel %a0,%d2
    movew #-22369,%d0
    .short  0xA746	| 40843B1C _GetTrapAddress (flags 0x0700)
    cmpl %a0,%d2
    jbne GestaltCall_20
    _Debugger
    cmpiw #32767,ROM85
    jbne GestaltCall_1E
    moveq #0,%d0
GestaltCall_1E:         /* (old ROM: 0) */
    rts
GestaltCall_20:         /* _Gestalt */
    movel %sp@(4),%d0
    .short  0xA1AD	| 40843B34 _Gestalt (flags 0x0100)
    moveal %sp@(8),%a1
    movel %a0,%a1@
    rts
    .short  0x0000	| 40843B3E

/*
 SOUNDINTERRUPTS / INSTALLSOUNDINTHANDLER / SOUNDINTHANDLER: nothing to do on these
 machines (rts). Followed by unused space
 (FILL_40843B42, include/romfill.inc).
*/
SOUNDINTERRUPTS:
INSTALLSOUNDINTHANDLER:
SOUNDINTHANDLER:
    rts
    FILL_40843B42
    .byte   0, 0, 0	| 40843CC9
    .long   0x00000000	| 40843CCC

/* SMGlobalLoc: address of the Sound Manager globals pointer (ExpandMem +272). */
SMGlobalLoc:
    moveal ExpandMem,%a0
    lea %a0@(272),%a0
    movel %a0,%d0
    rts
    .long   0x00000000	| 40843CDC

/*
 IsVMPresent, NewVMPtr, DisposVMPtr (raw words): Gestalt 'vm  ', allocate or free a
 block and hold or unhold it under virtual memory.
*/
IsVMPresent:
    movel #1986863136,%d0
    .short  0xA1AD	| 40843CE6 _Gestalt (flags 0x0100)
    tstw %d0
    beqs IsVMPresent_E
    subal %a0,%a0
IsVMPresent_E:
    movel %a0,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843CF2
NewVMPtr:               /* (data) */
    movel %sp@(4),%d0
    .short  0xA31E	| 40843D04 _NewPtr (flags 0x0300)
    tstw %d0
    bnes NewVMPtr_20
    movel %a0,%sp@-
    jsr %pc@(IsVMPresent)
    tstw %d0
    beqs NewVMPtr_1E
    moveal %sp@,%a0
    moveal %sp@(8),%a1
    moveq #0,%d0
    _MemoryDispatch
NewVMPtr_1E:
    movel %sp@+,%d0
NewVMPtr_20:
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843D22
DisposVMPtr:            /* (data) */
    moveal %sp@(4),%a0
    _GetPtrSize
    movel %d0,%sp@-
    moveal %sp@(8),%a0
    _DisposPtr
    jsr %pc@(IsVMPresent)
    tstw %d0
    beqs DisposVMPtr_20
    moveal %sp@(8),%a0
    moveal %sp@,%a1
    moveq #1,%d0
    _MemoryDispatch
DisposVMPtr_20:
    movel %sp@+,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843D54

/*
 RangeCommon: call _MemoryDispatch with selector d0 for (address, count) on the stack,
 Pascal result. The routines below set d0: HOLDMEMORY 0, UNHOLDMEMORY 1, LOCKMEMORY 2,
 UNLOCKMEMORY 3, LOCKMEMORYCONTIGUOUS 4, GETPHYSICAL 5 (through _GetPhysical),
 GETPAGESTATE 4 and PAGEFAULTFATAL 5 (debugger dispatch), DEBUGGERLOCKMEMORY 6,
 DEBUGGERUNLOCKMEMORY 7, ENTERSUPERVISORMODE 8; DEFERUSERFN (_DeferUserFn).
*/
RangeCommon:
    movel %sp@+,%d1
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _MemoryDispatch
    movew %d0,%sp@
    moveal %d1,%a1
    jmp %a1@
    .short  0x0000	| 40843D6E

/* DebuggerRangeCommon: the same through the debugger's dispatch trap. */
DebuggerRangeCommon:
    movel %sp@+,%d1
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _DebugUtil
    movew %d0,%sp@
    moveal %d1,%a1
    jmp %a1@
    .short  0x0000	| 40843D7E

HOLDMEMORY:             /* result 0 */
    moveq #0,%d0
    jmp %pc@(RangeCommon)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843D86

UNHOLDMEMORY:           /* result 1 */
    moveq #1,%d0
    jmp %pc@(RangeCommon)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843D96
LOCKMEMORY:             /* (data) */
    moveq #2,%d0
    jmp %pc@(RangeCommon)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843DA6
LOCKMEMORYCONTIGUOUS:   /* (data) */
    moveq #4,%d0
    jmp %pc@(RangeCommon)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843DB6
UNLOCKMEMORY:           /* (data) */
    moveq #3,%d0
    jmp %pc@(RangeCommon)
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843DC6
GETPHYSICAL:            /* (data) */
    movel %sp@+,%d1
    movel %sp@+,%d2
    moveal %d2,%a1
    moveal %a1@,%a1
    moveal %sp@+,%a0
    moveq #5,%d0
    .short  0xA15C	| 40843DDC _MemoryDispatch (flags 0x0100)
    movew %d0,%sp@
    moveal %d2,%a1
    movel %a0,%a1@
    moveal %d1,%a1
    jmp %a1@
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40843DE8
DEFERUSERFN:            /* (data) */
    movel %sp@+,%d1
    movel %sp@+,%d0
    moveal %sp@+,%a0
    _DeferUserFn
    movew %d0,%sp@
    moveal %d1,%a1
    jmp %a1@
    .short  0x0000	| 40843DFE
GETPAGESTATE:           /* (data) */
    movel %sp@+,%d1
    moveal %sp@+,%a0
    moveq #4,%d0
    _DebugUtil
    movew %d0,%sp@
    moveal %d1,%a1
    jmp %a1@
    .short  0x0000	| 40843E0E
PAGEFAULTFATAL:         /* (data) */
    moveq #5,%d0
    _DebugUtil
    moveb %d0,%sp@(4)
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 40843E1E
DEBUGGERLOCKMEMORY:     /* (data) */
    moveq #6,%d0
    braw DebuggerRangeCommon
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843E26
DEBUGGERUNLOCKMEMORY:   /* (data) */
    moveq #7,%d0
    braw DebuggerRangeCommon
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843E36
ENTERSUPERVISORMODE:    /* (data) */
    moveq #8,%d0
    _DebugUtil
    movew %d0,%sp@(4)
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 40843E4E

/*
 INITSNDDISPATCH: the _SoundDispatch tables (52 bytes in the Sound Manager globals,
 +42): selectors 0..7 unimplemented, then Version, AddTool, RemoveTool, ToolAddr, and
 install trap_SoundDispatch as _SoundDispatch (0xA800).
*/
INITSNDDISPATCH:
    moveal ExpandMem,%a1
    moveal %a1@(272),%a1
    moveq #52,%d0
    .short  0xA51E	| 40843E5A _NewPtr (flags 0x0500)
    movel %a0,%a1@(42)
    moveal %a0,%a1
    lea %pc@(SOUNDDISPATCHER_14),%a0
    movel %a0,%a1@+
    movew #7,%d1
    lea %pc@(UnimplFunction),%a0
INITSNDDISPATCH_20:     /* fill with UnimplFunction */
    movel %a0,%a1@+
    dbf %d1,INITSNDDISPATCH_20
    lea %pc@(DispVersion),%a0
    movel %a0,%a1@
    lea %pc@(DispAddTool),%a0
    movel %a0,%a1@(4)
    lea %pc@(DispRemTool),%a0
    movel %a0,%a1@(8)
    lea %pc@(DispToolAddr),%a0
    movel %a0,%a1@(12)
    lea %pc@(trap_SoundDispatch),%a0
    moveq #0,%d0
    .short  0xA647	| 40843E9A _SetTrapAddress (flags 0x0600)
    rts

/*
 _SoundDispatch: d0 low word = offset in the table, high word passed on: jump to the
 tool. SOUNDDISPATCHER_14: the second-level dispatch for the tools' own selectors.
*/
trap_SoundDispatch:
SOUNDDISPATCHER:
    moveal ExpandMem,%a0
    moveal %a0@(272),%a0
    moveal %a0@(42),%a0
    moveal %a0@(0x0,%d0:w),%a0
    swap %d0
    jmp %a0@
SOUNDDISPATCHER_14:     /* selector < 16: tool routine at +36 */
    cmpiw #16,%d0
    jbcc UnimplFunction
    moveal ExpandMem,%a0
    moveal %a0@(272),%a0
    moveal %a0@(42),%a0
    moveal %a0@(0x24,%d0:w),%a0
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000	| 40843ECA
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 40843ED0

/* UnimplFunction: unimplemented selector: result 0 (or nothing). */
UnimplFunction:
    tstw %d0
    jbne UnimplFunction_A
    clrl %sp@(4)
    rts
UnimplFunction_A:       /* return */
    rts
    .long   0x00000000	| 40843EEC

/*
 DispVersion(selector): the version of a tool (0x01001001 for selector 0), asked to the
 tool itself for the others below 36.
*/
DispVersion:
    movew %sp@(4),%d0
    jbeq DispVersion_22
    cmpiw #36,%d0
    jbcc DispVersion_1C
    moveal %sp@,%a0
    addql #6,%sp
    movel %a0,%sp@-
    andil #65535,%d0
    jmp %pc@(trap_SoundDispatch)
DispVersion_1C:         /* out of range: 0 */
    clrl %sp@(6)
    jbra DispVersion_2A
DispVersion_22:         /* the dispatcher's own version */
    movel #16785409,%sp@(6)
DispVersion_2A:         /* return */
    moveal %sp@,%a0
    addql #6,%sp
    jmp %a0@
    .long   0x4E750000, 0x00000000, 0x00000000, 0x00000000	| 40843F20

/* DispAddTool(selector, routine): install a tool. Result: 0, or -1 out of range. */
DispAddTool:
    movew %sp@(8),%d0
    cmpiw #36,%d0
    jbge DispAddTool_24
    moveal ExpandMem,%a1
    moveal %a1@(272),%a1
    moveal %a1@(42),%a1
    moveal %sp@(4),%a0
    movel %a0,%a1@(0x0,%d0:w)
    clrw %sp@(10)
    jbra DispAddTool_2A
DispAddTool_24:         /* -1 */
    movew #-1,%sp@(10)
DispAddTool_2A:         /* return */
    moveal %sp@,%a0
    addaw #10,%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40843F62

/*
 DispRemTool(selector): remove a tool (UnimplFunction again). Partly misaligned:
 the instruction boundaries here are not the real ones (bytes are right).
*/
DispRemTool:
    movew %sp@(4),%d0	| 40843F70
    cmpiw #36,%d0	| 40843F74
    jbcc DispRemTool_24	| 40843F78
    moveal ExpandMem,%a1
    .short  0x2269	| 40843F7E

DispRemTool_10:         /* (inside an instruction) */
    btst %d0,%a0@
    moveal %a1@(42),%a1
    lea %pc@(UnimplFunction),%a0
    movel %a0,%a1@(0x0,%d0:w)
    clrw %sp@(6)
    jbra DispRemTool_2A
DispRemTool_24:         /* set %sp@(6) */
    movew #-1,%sp@(6)	| 40843F94
DispRemTool_2A:         /* return */
    moveal %sp@,%a0
    addql #6,%sp
    jmp %a0@

/* DispToolAddr(selector): address of the tool, 0 if none. */
DispToolAddr:
    movew %sp@(4),%d0
    cmpiw #36,%d0
    jbcc DispToolAddr_22
    moveal ExpandMem,%a1
    moveal %a1@(272),%a1
    moveal %a1@(42),%a1
    movel %a1@(0x0,%d0:w),%d0
    lea %pc@(UnimplFunction),%a0
    cmpl %a0,%d0
    jbne DispToolAddr_24
DispToolAddr_22:        /* none: 0 */
    moveq #0,%d0
DispToolAddr_24:        /* return it */
    movel %d0,%sp@(6)
    moveal %sp@,%a0
    addql #6,%sp
    jmp %a0@
    .short  0x0000	| 40843FCE

/*
 INITMACEDISPATCH: install the MACE compression tool (selector 16) with its jump table
 (Comp3to1, Exp1to3, Comp6to1, Exp1to6).
*/
INITMACEDISPATCH:
    clrw %sp@-
    movew #16,%sp@-
    pea %pc@(INITMACEDISPATCH_12)
    jsr %pc@(DispAddTool)
    movew %sp@+,%d0
    rts
INITMACEDISPATCH_12:    /* MACE jump table */
    jmp %pc@(INITMACEDISPATCH_16,%d0:w)	| 40843FE2
INITMACEDISPATCH_16:    /* jump through %pc@(SNDSOUNDMANAGERVERSION_10) */
    jmp %pc@(SNDSOUNDMANAGERVERSION_10)	| 40843FE6
    jmp %pc@(Comp3to1)	| 40843FEA
    jmp %pc@(Exp1to3)	| 40843FEE
    jmp %pc@(Comp6to1)	| 40843FF2
    jmp %pc@(Exp1to6)	| 40843FF6
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40843FFA

/*
 Comp3to1(in, out, count, state, ...): MACE 3:1 compression (the start is the
 C entry and parameter set-up): each output byte packs three 8-bit input samples as
 3 + 2 + 3 bit codes of an adaptive delta coder (prediction in d4, step size in d3,
 both kept in the state record between calls).
*/
Comp3to1:
    linkw %fp,#0
    moveml %d0-%a5,%sp@-
    cmpil #6,%fp@(24)
    bltw Comp3to1_266
    moveal %fp@(20),%a0
    cmpaw #0,%a0
    bnes Comp3to1_28
    clrw %d3
    movew %d3,%d4
    movew %d3,%d5
    movew %d3,%d6
    bras Comp3to1_36
Comp3to1_28:
    movew %a0@,%d3
    movew %a0@(2),%d4
    movew %a0@(4),%d5
    movew %a0@(6),%d6
Comp3to1_36:
    moveal %fp@(32),%a2
    moveal %fp@(28),%a3
    movel %fp@(8),%d0
    subql #1,%d0
    addal %d0,%a2
    moveal %fp@(12),%a5
    subql #1,%a5
Comp3to1_4C:            /* next input sample: 8-bit unsigned to 16-bit signed, error against the prediction */
    moveb %a2@+,%d0
    addal %a5,%a2
    addib #0x80,%d0
    extw %d0
    aslw #8,%d0
    addib #0x80,%d0
    subw %d4,%d0
    jbvc Comp3to1_6C
    jbmi Comp3to1_68
    movew #-32767,%d0
    jbra Comp3to1_6C
Comp3to1_68:            /* overflow: clip to +32767 */
    movew #32767,%d0
Comp3to1_6C:            /* scale the error by the current step size (TABLES) */
    movew %d3,%d1
    asrw #4,%d1
    addw %d1,%d1
    lea %pc@(TABLES),%a4
    addaw %d1,%a4
    mulsw %a4@,%d0
    swap %d0
    orw %d0,%d0
    jbmi Comp3to1_A2
    cmpiw #19,%d0
    jbgt Comp3to1_8A
    moveq #0,%d2
    jbra Comp3to1_C4
Comp3to1_8A:            /* quantize: compare with the thresholds */
    cmpiw #40,%d0
    jbgt Comp3to1_94
    moveq #1,%d2
    jbra Comp3to1_C4
Comp3to1_94:            /* quantize: compare with the thresholds */
    cmpiw #67,%d0
    jbgt Comp3to1_9E
    moveq #2,%d2
    jbra Comp3to1_C4
Comp3to1_9E:            /* code 3 */
    moveq #3,%d2
    jbra Comp3to1_C4
Comp3to1_A2:            /* negative error: magnitude */
    notw %d0
    cmpiw #19,%d0
    jbgt Comp3to1_AE
    moveq #7,%d2
    jbra Comp3to1_C4
Comp3to1_AE:            /* quantize: compare with the thresholds */
    cmpiw #40,%d0
    jbgt Comp3to1_B8
    moveq #6,%d2
    jbra Comp3to1_C4
Comp3to1_B8:            /* quantize: compare with the thresholds */
    cmpiw #67,%d0
    jbgt Comp3to1_C2
    moveq #5,%d2
    jbra Comp3to1_C4
Comp3to1_C2:            /* code 4 */
    moveq #4,%d2
Comp3to1_C4:            /* reconstruct: prediction + the quantized step for the code (IQUADEL table) */
    aslw #3,%d1
    lea %pc@(IQUADEL3_TABLE),%a4
    addw %d2,%d1
    addw %d2,%d1
    addaw %d1,%a4
    movew %a4@,%d6
    addw %d4,%d6
    jbvc Comp3to1_E2
    jbmi Comp3to1_DE
    movew #-32767,%d6
    jbra Comp3to1_E2
Comp3to1_DE:            /* overflow: clip to +32767 */
    movew #32767,%d6
Comp3to1_E2:            /* new prediction (decayed), adapt the step size (MIN table) */
    movew %d6,%d0
    movew %d6,%d4
    asrw #3,%d0
    subw %d0,%d4
    movew %d3,%d0
    asrw #5,%d0
    subw %d0,%d3
    lea %pc@(MIN3_TABLE),%a4
    addaw %d2,%a4
    addaw %d2,%a4
    addw %a4@,%d3
    jbge Comp3to1_FE
    clrw %d3
Comp3to1_FE:            /* first code of the output byte */
    moveb %d2,%d7
    moveb %a2@+,%d0
    addal %a5,%a2
    addib #0x80,%d0
    extw %d0
    aslw #8,%d0
    addib #0x80,%d0
    subw %d4,%d0
    jbvc Comp3to1_120
    jbmi Comp3to1_11C
    movew #-32767,%d0
    jbra Comp3to1_120
Comp3to1_11C:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp3to1_120:           /* scale the error by the current step size (TABLES) */
    movew %d3,%d1
    asrw #4,%d1
    addw %d1,%d1
    lea %pc@(TABLES),%a4
    addaw %d1,%a4
    mulsw %a4@,%d0
    swap %d0
    orw %d0,%d0
    jbmi Comp3to1_142
    cmpiw #35,%d0
    jbgt Comp3to1_13E
    moveq #0,%d2
    jbra Comp3to1_150
Comp3to1_13E:           /* code 1 */
    moveq #1,%d2
    jbra Comp3to1_150
Comp3to1_142:           /* negative error: magnitude */
    notw %d0
    cmpiw #35,%d0
    jbgt Comp3to1_14E
    moveq #3,%d2
    jbra Comp3to1_150
Comp3to1_14E:           /* code 2 */
    moveq #2,%d2
Comp3to1_150:           /* reconstruct: prediction + the quantized step for the code (IQUADEL table) */
    aslw #3,%d1
    lea %pc@(IQUADEL2_TABLE),%a4
    addw %d2,%d1
    addw %d2,%d1
    addaw %d1,%a4
    movew %a4@,%d6
    addw %d4,%d6
    jbvc Comp3to1_16E
    jbmi Comp3to1_16A
    movew #-32767,%d6
    jbra Comp3to1_16E
Comp3to1_16A:           /* overflow: clip to +32767 */
    movew #32767,%d6
Comp3to1_16E:           /* new prediction (decayed), adapt the step size (MIN table) */
    movew %d6,%d0
    movew %d6,%d4
    asrw #3,%d0
    subw %d0,%d4
    movew %d3,%d0
    asrw #5,%d0
    subw %d0,%d3
    lea %pc@(MIN2_TABLE),%a4
    addaw %d2,%a4
    addaw %d2,%a4
    addw %a4@,%d3
    jbge Comp3to1_18A
    clrw %d3
Comp3to1_18A:           /* pack the code into the output byte */
    aslb #3,%d2
    addb %d2,%d7
    moveb %a2@+,%d0
    addal %a5,%a2
    addib #0x80,%d0
    extw %d0
    aslw #8,%d0
    addib #0x80,%d0
    subw %d4,%d0
    jbvc Comp3to1_1AE
    jbmi Comp3to1_1AA
    movew #-32767,%d0
    jbra Comp3to1_1AE
Comp3to1_1AA:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp3to1_1AE:           /* scale the error by the current step size (TABLES) */
    movew %d3,%d1
    asrw #4,%d1
    addw %d1,%d1
    lea %pc@(TABLES),%a4
    addaw %d1,%a4
    mulsw %a4@,%d0
    swap %d0
    orw %d0,%d0
    jbmi Comp3to1_1E4
    cmpiw #19,%d0
    jbgt Comp3to1_1CC
    moveq #0,%d2
    jbra Comp3to1_206
Comp3to1_1CC:           /* quantize: compare with the thresholds */
    cmpiw #40,%d0
    jbgt Comp3to1_1D6
    moveq #1,%d2
    jbra Comp3to1_206
Comp3to1_1D6:           /* quantize: compare with the thresholds */
    cmpiw #67,%d0
    jbgt Comp3to1_1E0
    moveq #2,%d2
    jbra Comp3to1_206
Comp3to1_1E0:           /* code 3 */
    moveq #3,%d2
    jbra Comp3to1_206
Comp3to1_1E4:           /* negative error: magnitude */
    notw %d0
    cmpiw #19,%d0
    jbgt Comp3to1_1F0
    moveq #7,%d2
    jbra Comp3to1_206
Comp3to1_1F0:           /* quantize: compare with the thresholds */
    cmpiw #40,%d0
    jbgt Comp3to1_1FA
    moveq #6,%d2
    jbra Comp3to1_206
Comp3to1_1FA:           /* quantize: compare with the thresholds */
    cmpiw #67,%d0
    jbgt Comp3to1_204
    moveq #5,%d2
    jbra Comp3to1_206
Comp3to1_204:           /* code 4 */
    moveq #4,%d2
Comp3to1_206:           /* reconstruct: prediction + the quantized step for the code (IQUADEL table) */
    aslw #3,%d1
    lea %pc@(IQUADEL3_TABLE),%a4
    addw %d2,%d1
    addw %d2,%d1
    addaw %d1,%a4
    movew %a4@,%d6
    addw %d4,%d6
    jbvc Comp3to1_224
    jbmi Comp3to1_220
    movew #-32767,%d6
    jbra Comp3to1_224
Comp3to1_220:           /* overflow: clip to +32767 */
    movew #32767,%d6
Comp3to1_224:           /* new prediction (decayed), adapt the step size (MIN table) */
    movew %d6,%d0
    movew %d6,%d4
    asrw #3,%d0
    subw %d0,%d4
    movew %d3,%d0
    asrw #5,%d0
    subw %d0,%d3
    lea %pc@(MIN3_TABLE),%a4
    addaw %d2,%a4
    addaw %d2,%a4
    addw %a4@,%d3
    jbge Comp3to1_240
    clrw %d3
Comp3to1_240:           /* pack the code into the output byte */
    aslb #5,%d2
    addb %d2,%d7
    moveb %d7,%a3@+
    subql #3,%fp@(24)
    jbgt Comp3to1_4C
    moveal %fp@(16),%a0
    cmpaw #0,%a0
    jbeq Comp3to1_266
    movew %d3,%a0@
    movew %d4,%a0@(2)
    movew %d5,%a0@(4)
    movew %d6,%a0@(6)
Comp3to1_266:           /* done: restore the registers, return */
    moveml %sp@+,%d0-%a5
    moveal %fp@(4),%a0
    unlk %fp
    addaw #32,%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40844276

/* Exp1to3: MACE 3:1 expansion. */
Exp1to3:
    linkw %fp,#0
    moveml %d0-%a5,%sp@-
    cmpil #1,%fp@(24)
    bltw Exp1to3_1E8
    moveal %fp@(20),%a0
    cmpaw #0,%a0
    bnes Exp1to3_24
    clrw %d2
    clrw %d3
    bras Exp1to3_2A
Exp1to3_24:
    movew %a0@,%d2
    movew %a0@(2),%d3
Exp1to3_2A:
    moveal %fp@(32),%a2
    moveal %fp@(28),%a3
    movew #2032,%d6
    moveaw #16,%a5
    movew #-32640,%d7
    movel %fp@(8),%d0
    subql #1,%d0
    lsll #1,%d0
    addal %d0,%a2
    moveal %fp@(12),%a1
    subql #1,%a1
    addal %a1,%a1
Exp1to3_50:
    moveb %a2@+,%d4
    moveq #7,%d1
    andb %d4,%d1
    addw %d1,%d1
    lea %pc@(MIN3_TABLE),%a4
    addaw %d1,%a4
    movew %d2,%d1
    movew %d2,%d0
    asrw #5,%d0
    subw %d0,%d2
    addw %a4@,%d2
    bges Exp1to3_6C
    moveq #0,%d2
Exp1to3_6C:
    andw %d6,%d1
    addw %a5,%d1
    addaw %d1,%a4
    addw %a4@,%d3
    bvcs Exp1to3_82
    bmis Exp1to3_7E
    movew #-32767,%d3
    bras Exp1to3_82
Exp1to3_7E:
    movew #32767,%d3
Exp1to3_82:
    movew %d3,%d0
    movew %d0,%d5
    andiw #-256,%d5
    asrw #3,%d0
    subw %d0,%d3
    lsrw #2,%d4
    moveq #6,%d1
    andb %d4,%d1
    lea %pc@(MIN2_TABLE),%a4
    addaw %d1,%a4
    movew %d2,%d1
    movew %d2,%d0
    asrw #5,%d0
    subw %d0,%d2
    addw %a4@,%d2
    bges Exp1to3_A8
    moveq #0,%d2
Exp1to3_A8:
    andw %d6,%d1
    addw %a5,%d1
    addaw %d1,%a4
    addw %a4@,%d3
    bvcs Exp1to3_BE
    bmis Exp1to3_BA
    movew #-32767,%d3
    bras Exp1to3_BE
Exp1to3_BA:
    movew #32767,%d3
Exp1to3_BE:
    movew %d3,%d0
    asrw #3,%d0
    subw %d0,%d3
    lsrw #5,%d0
    andiw #255,%d0
    orw %d0,%d5
    eorw %d7,%d5
    movew %d5,%a3@+
    lsrw #2,%d4
    moveq #14,%d1
    andb %d4,%d1
    lea %pc@(MIN3_TABLE),%a4
    addaw %d1,%a4
    movew %d2,%d1
    movew %d2,%d0
    asrw #5,%d0
    subw %d0,%d2
    addw %a4@,%d2
    bges Exp1to3_EA
    moveq #0,%d2
Exp1to3_EA:
    andw %d6,%d1
    addw %a5,%d1
    addaw %d1,%a4
    addw %a4@,%d3
    bvcs Exp1to3_100
    bmis Exp1to3_FC
    movew #-32767,%d3
    bras Exp1to3_100
Exp1to3_FC:
    movew #32767,%d3
Exp1to3_100:
    movew %d3,%d0
    movew %d0,%d5
    andiw #-256,%d5
    asrw #3,%d0
    subw %d0,%d3
    moveb %a2@+,%d4
    moveq #7,%d1
    andb %d4,%d1
    addw %d1,%d1
    lea %pc@(MIN3_TABLE),%a4
    addaw %d1,%a4
    movew %d2,%d1
    movew %d2,%d0
    asrw #5,%d0
    subw %d0,%d2
    addw %a4@,%d2
    bges Exp1to3_128
    moveq #0,%d2
Exp1to3_128:
    andw %d6,%d1
    addw %a5,%d1
    addaw %d1,%a4
    addw %a4@,%d3
    bvcs Exp1to3_13E
    bmis Exp1to3_13A
    movew #-32767,%d3
    bras Exp1to3_13E
Exp1to3_13A:
    movew #32767,%d3
Exp1to3_13E:
    movew %d3,%d0
    asrw #3,%d0
    subw %d0,%d3
    lsrw #5,%d0
    andiw #255,%d0
    orw %d0,%d5
    eorw %d7,%d5
    movew %d5,%a3@+
    lsrw #2,%d4
    moveq #6,%d1
    andb %d4,%d1
    lea %pc@(MIN2_TABLE),%a4
    addaw %d1,%a4
    movew %d2,%d1
    movew %d2,%d0
    asrw #5,%d0
    subw %d0,%d2
    addw %a4@,%d2
    bges Exp1to3_16A
    moveq #0,%d2
Exp1to3_16A:
    andw %d6,%d1
    addw %a5,%d1
    addaw %d1,%a4
    addw %a4@,%d3
    bvcs Exp1to3_180
    bmis Exp1to3_17C
    movew #-32767,%d3
    bras Exp1to3_180
Exp1to3_17C:
    movew #32767,%d3
Exp1to3_180:
    movew %d3,%d0
    movew %d0,%d5
    andiw #-256,%d5
    asrw #3,%d0
    subw %d0,%d3
    lsrw #2,%d4
    moveq #14,%d1
    andb %d4,%d1
    lea %pc@(MIN3_TABLE),%a4
    addaw %d1,%a4
    movew %d2,%d1
    movew %d2,%d0
    asrw #5,%d0
    subw %d0,%d2
    addw %a4@,%d2
    bges Exp1to3_1A6
    moveq #0,%d2
Exp1to3_1A6:
    andw %d6,%d1
    addw %a5,%d1
    addaw %d1,%a4
    addw %a4@,%d3
    bvcs Exp1to3_1BC
    bmis Exp1to3_1B8
    movew #-32767,%d3
    bras Exp1to3_1BC
Exp1to3_1B8:
    movew #32767,%d3
Exp1to3_1BC:
    movew %d3,%d0
    asrw #3,%d0
    subw %d0,%d3
    lsrw #5,%d0
    andiw #255,%d0
    orw %d0,%d5
    eorw %d7,%d5
    movew %d5,%a3@+
    addal %a1,%a2
    subql #1,%fp@(24)
    bnew Exp1to3_50
    moveal %fp@(16),%a0
    cmpaw #0,%a0
    beqs Exp1to3_1E8
    movew %d2,%a0@
    movew %d3,%a0@(2)
Exp1to3_1E8:
    moveml %sp@+,%d0-%a5
    moveal %fp@(4),%a0
    unlk %fp
    addaw #32,%sp
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40844478

/*
 Comp6to1: MACE 6:1 compression: each output byte packs six samples (the same scheme
 with smaller codes).
*/
Comp6to1:
    linkw %fp,#-4
    moveml %d0-%a5,%sp@-
    cmpil #6,%fp@(24)
    bltw Comp6to1_3DC
    moveal %fp@(20),%a0
    cmpaw #0,%a0
    bnes Comp6to1_38
    movew #-1022,%d6
    moveaw #-1022,%a5
    movew #-8177,%d7
    moveaw #-8177,%a4
    clrw %d3
    clrw %d4
    clrw %d5
    subal %a2,%a2
    bras Comp6to1_56
Comp6to1_38:
    movew %a0@,%d6
    moveaw %a0@(2),%a5
    movew %a0@(4),%d7
    moveaw %a0@(6),%a4
    movew %a0@(8),%d3
    movew %a0@(10),%d4
    movew %a0@(12),%d5
    moveaw %a0@(14),%a2
Comp6to1_56:
    moveal %fp@(32),%a0
    moveal %fp@(28),%a1
    movel %fp@(8),%d0
    subql #1,%d0
    addal %d0,%a0
    movel %fp@(12),%fp@(-4)
    subql #1,%fp@(-4)
Comp6to1_70:            /* next pair of input samples: low-pass filter (decimate by 2) into one value */
    moveq #-128,%d1
    addb %a0@+,%d1
    addal %fp@(-4),%a0
    extw %d1
    aslw #4,%d1
    addw %d6,%d1
    subw %a5,%d1
    asrw #1,%d1
    movew %a5,%d0
    addw %d6,%d0
    addw %d6,%d0
    addw %d1,%d0
    moveaw %d6,%a5
    movew %d1,%d6
    moveaw %d7,%a4
    asrw #1,%d7
    addw %d0,%d7
    moveq #-128,%d0
    addb %a0@+,%d0
    addal %fp@(-4),%a0
    extw %d0
    aslw #4,%d0
    addw %d6,%d0
    subw %a5,%d0
    asrw #1,%d0
    movew %a5,%d1
    addw %d6,%d1
    addw %d6,%d1
    addw %d0,%d1
    moveaw %d6,%a5
    movew %d0,%d6
    movew %a4,%d0
    addw %d7,%d0
    addw %d7,%d0
    moveaw %d7,%a4
    asrw #1,%d7
    addw %d1,%d7
    addw %d7,%d0
    subw %d4,%d0
    jbvc Comp6to1_D0
    jbmi Comp6to1_CC
    movew #-32767,%d0
    jbra Comp6to1_D0
Comp6to1_CC:            /* overflow: clip to +32767 */
    movew #32767,%d0
Comp6to1_D0:            /* scale the error by the current step size (TABLES) */
    movew %d3,%d1
    asrw #4,%d1
    addw %d1,%d1
    lea %pc@(TABLES),%a3
    addaw %d1,%a3
    mulsw %a3@,%d0
    swap %d0
    orw %d0,%d0
    jbmi Comp6to1_106
    cmpiw #21,%d0
    jbgt Comp6to1_EE
    moveq #0,%d2
    jbra Comp6to1_128
Comp6to1_EE:            /* quantize: compare with the thresholds */
    cmpiw #43,%d0
    jbgt Comp6to1_F8
    moveq #1,%d2
    jbra Comp6to1_128
Comp6to1_F8:            /* quantize: compare with the thresholds */
    cmpiw #72,%d0
    jbgt Comp6to1_102
    moveq #2,%d2
    jbra Comp6to1_128
Comp6to1_102:           /* code 3 */
    moveq #3,%d2
    jbra Comp6to1_128
Comp6to1_106:           /* negative error: magnitude */
    notw %d0
    cmpiw #21,%d0
    jbgt Comp6to1_112
    moveq #7,%d2
    jbra Comp6to1_128
Comp6to1_112:           /* quantize: compare with the thresholds */
    cmpiw #43,%d0
    jbgt Comp6to1_11C
    moveq #6,%d2
    jbra Comp6to1_128
Comp6to1_11C:           /* quantize: compare with the thresholds */
    cmpiw #72,%d0
    jbgt Comp6to1_126
    moveq #5,%d2
    jbra Comp6to1_128
Comp6to1_126:           /* code 4 */
    moveq #4,%d2
Comp6to1_128:           /* adapt the step size (MIN3 table) */
    movew %d3,%d0
    asrw #5,%d0
    subw %d0,%d3
    lea %pc@(MIN3_TABLE),%a3
    addaw %d2,%a3
    addaw %d2,%a3
    addw %a3@,%d3
    jbge Comp6to1_13C
    clrw %d3
Comp6to1_13C:           /* reconstruct: prediction + the quantized step for the code (IQUADEL table) */
    aslw #3,%d1
    lea %a3@(16),%a3
    addaw %d1,%a3
    movew %a3@,%d0
    movew %a2,%d1
    eorw %d0,%d1
    jbmi Comp6to1_16A
    addw %d4,%d0
    jbvc Comp6to1_15C
    jbmi Comp6to1_158
    movew #-32767,%d0
    jbra Comp6to1_15C
Comp6to1_158:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp6to1_15C:           /* keep the reconstructed value */
    moveaw %d0,%a2
    addiw #506,%d5
    jbvc Comp6to1_168
    movew #32767,%d5
Comp6to1_168:           /* (sign differs) go on */
    jbra Comp6to1_186
Comp6to1_16A:           /* add to the prediction (same sign: no overflow check) */
    addw %d4,%d0
    jbvc Comp6to1_17A
    jbmi Comp6to1_176
    movew #-32767,%d0
    jbra Comp6to1_17A
Comp6to1_176:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp6to1_17A:           /* keep the reconstructed value */
    moveaw %d0,%a2
    subiw #314,%d5
    jbvc Comp6to1_186
    movew #-32767,%d5
Comp6to1_186:           /* smooth the prediction (multiply by the filter coefficient) */
    mulsw %d5,%d0
    addl %d0,%d0
    swap %d0
    movew %d0,%d4
    aslb #5,%d2
    moveb %d2,%a1@
    moveq #-128,%d1
    addb %a0@+,%d1
    addal %fp@(-4),%a0
    extw %d1
    aslw #4,%d1
    addw %d6,%d1
    subw %a5,%d1
    asrw #1,%d1
    movew %a5,%d0
    addw %d6,%d0
    addw %d6,%d0
    addw %d1,%d0
    moveaw %d6,%a5
    movew %d1,%d6
    moveaw %d7,%a4
    asrw #1,%d7
    addw %d0,%d7
    moveq #-128,%d0
    addb %a0@+,%d0
    addal %fp@(-4),%a0
    extw %d0
    aslw #4,%d0
    addw %d6,%d0
    subw %a5,%d0
    asrw #1,%d0
    movew %a5,%d1
    addw %d6,%d1
    addw %d6,%d1
    addw %d0,%d1
    moveaw %d6,%a5
    movew %d0,%d6
    movew %a4,%d0
    addw %d7,%d0
    addw %d7,%d0
    moveaw %d7,%a4
    asrw #1,%d7
    addw %d1,%d7
    addw %d7,%d0
    subw %d4,%d0
    jbvc Comp6to1_1F2
    jbmi Comp6to1_1EE
    movew #-32767,%d0
    jbra Comp6to1_1F2
Comp6to1_1EE:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp6to1_1F2:           /* scale the error by the current step size (TABLES) */
    movew %d3,%d1
    asrw #4,%d1
    addw %d1,%d1
    lea %pc@(TABLES),%a3
    addaw %d1,%a3
    mulsw %a3@,%d0
    swap %d0
    orw %d0,%d0
    jbmi Comp6to1_214
    cmpiw #37,%d0
    jbgt Comp6to1_210
    moveq #0,%d2
    jbra Comp6to1_222
Comp6to1_210:           /* code 1 */
    moveq #1,%d2
    jbra Comp6to1_222
Comp6to1_214:           /* negative error: magnitude */
    notw %d0
    cmpiw #37,%d0
    jbgt Comp6to1_220
    moveq #3,%d2
    jbra Comp6to1_222
Comp6to1_220:           /* code 2 */
    moveq #2,%d2
Comp6to1_222:           /* adapt the step size (MIN3 table) */
    movew %d3,%d0
    asrw #5,%d0
    subw %d0,%d3
    lea %pc@(MIN2_TABLE),%a3
    addaw %d2,%a3
    addaw %d2,%a3
    addw %a3@,%d3
    jbge Comp6to1_236
    clrw %d3
Comp6to1_236:           /* reconstruct: prediction + the quantized step for the code (IQUADEL table) */
    aslw #3,%d1
    lea %a3@(16),%a3
    addaw %d1,%a3
    movew %a3@,%d0
    movew %a2,%d1
    eorw %d0,%d1
    jbmi Comp6to1_264
    addw %d4,%d0
    jbvc Comp6to1_256
    jbmi Comp6to1_252
    movew #-32767,%d0
    jbra Comp6to1_256
Comp6to1_252:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp6to1_256:           /* keep the reconstructed value */
    moveaw %d0,%a2
    addiw #506,%d5
    jbvc Comp6to1_262
    movew #32767,%d5
Comp6to1_262:           /* (sign differs) go on */
    jbra Comp6to1_280
Comp6to1_264:           /* add to the prediction (same sign: no overflow check) */
    addw %d4,%d0
    jbvc Comp6to1_274
    jbmi Comp6to1_270
    movew #-32767,%d0
    jbra Comp6to1_274
Comp6to1_270:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp6to1_274:           /* keep the reconstructed value */
    moveaw %d0,%a2
    subiw #314,%d5
    jbvc Comp6to1_280
    movew #-32767,%d5
Comp6to1_280:           /* smooth the prediction (multiply by the filter coefficient) */
    mulsw %d5,%d0
    addl %d0,%d0
    swap %d0
    movew %d0,%d4
    aslb #3,%d2
    addb %d2,%a1@
    moveq #-128,%d1
    addb %a0@+,%d1
    addal %fp@(-4),%a0
    extw %d1
    aslw #4,%d1
    addw %d6,%d1
    subw %a5,%d1
    asrw #1,%d1
    movew %a5,%d0
    addw %d6,%d0
    addw %d6,%d0
    addw %d1,%d0
    moveaw %d6,%a5
    movew %d1,%d6
    moveaw %d7,%a4
    asrw #1,%d7
    addw %d0,%d7
    moveq #-128,%d0
    addb %a0@+,%d0
    addal %fp@(-4),%a0
    extw %d0
    aslw #4,%d0
    addw %d6,%d0
    subw %a5,%d0
    asrw #1,%d0
    movew %a5,%d1
    addw %d6,%d1
    addw %d6,%d1
    addw %d0,%d1
    moveaw %d6,%a5
    movew %d0,%d6
    movew %a4,%d0
    addw %d7,%d0
    addw %d7,%d0
    moveaw %d7,%a4
    asrw #1,%d7
    addw %d1,%d7
    addw %d7,%d0
    subw %d4,%d0
    jbvc Comp6to1_2EC
    jbmi Comp6to1_2E8
    movew #-32767,%d0
    jbra Comp6to1_2EC
Comp6to1_2E8:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp6to1_2EC:           /* scale the error by the current step size (TABLES) */
    movew %d3,%d1
    asrw #4,%d1
    addw %d1,%d1
    lea %pc@(TABLES),%a3
    addaw %d1,%a3
    mulsw %a3@,%d0
    swap %d0
    orw %d0,%d0
    jbmi Comp6to1_322
    cmpiw #21,%d0
    jbgt Comp6to1_30A
    moveq #0,%d2
    jbra Comp6to1_344
Comp6to1_30A:           /* quantize: compare with the thresholds */
    cmpiw #43,%d0
    jbgt Comp6to1_314
    moveq #1,%d2
    jbra Comp6to1_344
Comp6to1_314:           /* quantize: compare with the thresholds */
    cmpiw #72,%d0
    jbgt Comp6to1_31E
    moveq #2,%d2
    jbra Comp6to1_344
Comp6to1_31E:           /* code 3 */
    moveq #3,%d2
    jbra Comp6to1_344
Comp6to1_322:           /* negative error: magnitude */
    notw %d0
    cmpiw #21,%d0
    jbgt Comp6to1_32E
    moveq #7,%d2
    jbra Comp6to1_344
Comp6to1_32E:           /* quantize: compare with the thresholds */
    cmpiw #43,%d0
    jbgt Comp6to1_338
    moveq #6,%d2
    jbra Comp6to1_344
Comp6to1_338:           /* quantize: compare with the thresholds */
    cmpiw #72,%d0
    jbgt Comp6to1_342
    moveq #5,%d2
    jbra Comp6to1_344
Comp6to1_342:           /* code 4 */
    moveq #4,%d2
Comp6to1_344:           /* adapt the step size (MIN3 table) */
    movew %d3,%d0
    asrw #5,%d0
    subw %d0,%d3
    lea %pc@(MIN3_TABLE),%a3
    addaw %d2,%a3
    addaw %d2,%a3
    addw %a3@,%d3
    jbge Comp6to1_358
    clrw %d3
Comp6to1_358:           /* reconstruct: prediction + the quantized step for the code (IQUADEL table) */
    aslw #3,%d1
    lea %a3@(16),%a3
    addaw %d1,%a3
    movew %a3@,%d0
    movew %a2,%d1
    eorw %d0,%d1
    jbmi Comp6to1_386
    addw %d4,%d0
    jbvc Comp6to1_378
    jbmi Comp6to1_374
    movew #-32767,%d0
    jbra Comp6to1_378
Comp6to1_374:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp6to1_378:           /* keep the reconstructed value */
    moveaw %d0,%a2
    addiw #506,%d5
    jbvc Comp6to1_384
    movew #32767,%d5
Comp6to1_384:           /* (sign differs) go on */
    jbra Comp6to1_3A2
Comp6to1_386:           /* add to the prediction (same sign: no overflow check) */
    addw %d4,%d0
    jbvc Comp6to1_396
    jbmi Comp6to1_392
    movew #-32767,%d0
    jbra Comp6to1_396
Comp6to1_392:           /* overflow: clip to +32767 */
    movew #32767,%d0
Comp6to1_396:           /* keep the reconstructed value */
    moveaw %d0,%a2
    subiw #314,%d5
    jbvc Comp6to1_3A2
    movew #-32767,%d5
Comp6to1_3A2:           /* byte done: store it, count the samples left */
    mulsw %d5,%d0
    addl %d0,%d0
    swap %d0
    movew %d0,%d4
    addb %d2,%a1@+
    subql #6,%fp@(24)
    jbgt Comp6to1_70
    moveal %fp@(16),%a0
    cmpaw #0,%a0
    jbeq Comp6to1_3DC
    movew %d6,%a0@
    movew %a5,%a0@(2)
    movew %d7,%a0@(4)
    movew %a4,%a0@(6)
    movew %d3,%a0@(8)
    movew %d4,%a0@(10)
    movew %d5,%a0@(12)
    movew %a2,%a0@(14)
Comp6to1_3DC:           /* done: restore the registers, return */
    moveml %sp@+,%d0-%a5
    moveal %fp@(4),%a0
    unlk %fp
    addaw #32,%sp
    jmp %a0@
    .long   0x00000000	| 4084486C

/* Exp1to6: MACE 6:1 expansion. */
Exp1to6:
    linkw %fp,#-4
    moveml %d0-%a5,%sp@-
    cmpil #1,%fp@(24)
    bltw Exp1to6_240
    moveal %fp@(20),%a0
    cmpaw #0,%a0
    bnes Exp1to6_2C
    subal %a4,%a4
    movew %a4,%d5
    movew %a4,%d3
    moveaw %a4,%a5
    movew %a4,%d4
    movew %a4,%d2
    bras Exp1to6_42
Exp1to6_2C:
    moveaw %a0@,%a4
    movew %a0@(2),%d5
    movew %a0@(4),%d3
    moveaw %a0@(6),%a5
    movew %a0@(8),%d4
    movew %a0@(10),%d2
Exp1to6_42:
    moveal %fp@(32),%a0
    moveal %fp@(28),%a2
    movew #2032,%d6
    movew #16,%d7
    movel %fp@(8),%d0
    subql #1,%d0
    addal %d0,%a0
    moveal %fp@(12),%a3
    subql #1,%a3
Exp1to6_60:
    moveb %a0@+,%d1
    moveq #7,%d0
    andw %d1,%d0
    addw %d0,%d0
    movew %d0,%fp@(-2)
    lsrw #2,%d1
    moveq #6,%d0
    andw %d1,%d0
    movew %d0,%fp@(-4)
    lsrw #2,%d1
    andiw #14,%d1
    lea %pc@(MIN3_TABLE),%a1
    addaw %d1,%a1
    movew %d3,%d1
    movew %d3,%d0
    asrw #5,%d0
    subw %d0,%d3
    addw %a1@,%d3
    bges Exp1to6_90
    clrw %d3
Exp1to6_90:
    andw %d6,%d1
    addw %d7,%d1
    addaw %d1,%a1
    movew %a1@,%d0
    eorw %d0,%d2
    bmis Exp1to6_BA
    addw %a5,%d0
    bvcs Exp1to6_AC
    bmis Exp1to6_A8
    movew #-32767,%d0
    bras Exp1to6_AC
Exp1to6_A8:
    movew #32767,%d0
Exp1to6_AC:
    movew %d0,%d2
    addiw #506,%d4
    bvcs Exp1to6_B8
    movew #32767,%d4
Exp1to6_B8:
    bras Exp1to6_D6
Exp1to6_BA:
    addw %a5,%d0
    bvcs Exp1to6_CA
    bmis Exp1to6_C6
    movew #-32767,%d0
    bras Exp1to6_CA
Exp1to6_C6:
    movew #32767,%d0
Exp1to6_CA:
    movew %d0,%d2
    subiw #314,%d4
    bvcs Exp1to6_D6
    movew #-32767,%d4
Exp1to6_D6:
    mulsw %d4,%d0
    addl %d0,%d0
    swap %d0
    moveaw %d0,%a5
    asrw #1,%d2
    movew %d5,%d1
    subw %d2,%d1
    asrw #2,%d1
    movew %d5,%d0
    addw %a4,%d0
    subw %d1,%d0
    movew %a4,%d5
    moveaw %d2,%a4
    addw %a4,%d1
    addw %d5,%d1
    andiw #-256,%d0
    lsrw #8,%d1
    orw %d0,%d1
    eoriw #-32640,%d1
    movew %d1,%a2@+
    movew %fp@(-4),%d1
    lea %pc@(MIN2_TABLE),%a1
    addaw %d1,%a1
    movew %d3,%d1
    movew %d3,%d0
    asrw #5,%d0
    subw %d0,%d3
    addw %a1@,%d3
    bges Exp1to6_11A
    clrw %d3
Exp1to6_11A:
    andw %d6,%d1
    addw %d7,%d1
    addaw %d1,%a1
    movew %a1@,%d0
    eorw %d0,%d2
    bmis Exp1to6_144
    addw %a5,%d0
    bvcs Exp1to6_136
    bmis Exp1to6_132
    movew #-32767,%d0
    bras Exp1to6_136
Exp1to6_132:
    movew #32767,%d0
Exp1to6_136:
    movew %d0,%d2
    addiw #506,%d4
    bvcs Exp1to6_142
    movew #32767,%d4
Exp1to6_142:
    bras Exp1to6_160
Exp1to6_144:
    addw %a5,%d0
    bvcs Exp1to6_154
    bmis Exp1to6_150
    movew #-32767,%d0
    bras Exp1to6_154
Exp1to6_150:
    movew #32767,%d0
Exp1to6_154:
    movew %d0,%d2
    subiw #314,%d4
    bvcs Exp1to6_160
    movew #-32767,%d4
Exp1to6_160:
    mulsw %d4,%d0
    addl %d0,%d0
    swap %d0
    moveaw %d0,%a5
    asrw #1,%d2
    movew %d5,%d1
    subw %d2,%d1
    asrw #2,%d1
    movew %d5,%d0
    addw %a4,%d0
    subw %d1,%d0
    movew %a4,%d5
    moveaw %d2,%a4
    addw %a4,%d1
    addw %d5,%d1
    andiw #-256,%d0
    lsrw #8,%d1
    orw %d0,%d1
    eoriw #-32640,%d1
    movew %d1,%a2@+
    movew %fp@(-2),%d1
    lea %pc@(MIN3_TABLE),%a1
    addaw %d1,%a1
    movew %d3,%d1
    movew %d3,%d0
    asrw #5,%d0
    subw %d0,%d3
    addw %a1@,%d3
    bges Exp1to6_1A4
    clrw %d3
Exp1to6_1A4:
    andw %d6,%d1
    addw %d7,%d1
    addaw %d1,%a1
    movew %a1@,%d0
    eorw %d0,%d2
    bmis Exp1to6_1CE
    addw %a5,%d0
    bvcs Exp1to6_1C0
    bmis Exp1to6_1BC
    movew #-32767,%d0
    bras Exp1to6_1C0
Exp1to6_1BC:
    movew #32767,%d0
Exp1to6_1C0:
    movew %d0,%d2
    addiw #506,%d4
    bvcs Exp1to6_1CC
    movew #32767,%d4
Exp1to6_1CC:
    bras Exp1to6_1EA
Exp1to6_1CE:
    addw %a5,%d0
    bvcs Exp1to6_1DE
    bmis Exp1to6_1DA
    movew #-32767,%d0
    bras Exp1to6_1DE
Exp1to6_1DA:
    movew #32767,%d0
Exp1to6_1DE:
    movew %d0,%d2
    subiw #314,%d4
    bvcs Exp1to6_1EA
    movew #-32767,%d4
Exp1to6_1EA:
    mulsw %d4,%d0
    addl %d0,%d0
    swap %d0
    moveaw %d0,%a5
    asrw #1,%d2
    movew %d5,%d1
    subw %d2,%d1
    asrw #2,%d1
    movew %d5,%d0
    addw %a4,%d0
    subw %d1,%d0
    movew %a4,%d5
    moveaw %d2,%a4
    addw %a4,%d1
    addw %d5,%d1
    andiw #-256,%d0
    lsrw #8,%d1
    orw %d0,%d1
    eoriw #-32640,%d1
    movew %d1,%a2@+
    addal %a3,%a0
    subql #1,%fp@(24)
    bnew Exp1to6_60
    moveal %fp@(16),%a0
    cmpaw #0,%a0
    beqs Exp1to6_240
    movew %a4,%a0@
    movew %d5,%a0@(2)
    movew %d3,%a0@(4)
    movew %a5,%a0@(6)
    movew %d4,%a0@(8)
    movew %d2,%a0@(10)
Exp1to6_240:
    moveml %sp@+,%d0-%a5
    moveal %fp@(4),%a0
    unlk %fp
    addaw #32,%sp
    jmp %a0@

/*
 TABLES: MACE tables: step size multipliers (TABLES/DELTA_TABLE), step adaptation
 (MIN2_TABLE, MIN3_TABLE) and reconstruction levels for 2-bit and 3-bit codes
 (IQUADEL2_TABLE, IQUADEL3_TABLE), 8 entries per step size row.
*/
TABLES:
DELTA_TABLE:
    .long   0x40003D44, 0x3AA63825, 0x35BF3373, 0x31402F26	| 40844AC0
    .long   0x2D222B34, 0x295C2797, 0x25E62448, 0x22BB213F	| 40844AD0
    .long   0x1FD41E78, 0x1D2A1BEB, 0x1ABA1996, 0x187E1772	| 40844AE0
    .long   0x1672157C, 0x149113B0, 0x12D9120B, 0x11451089	| 40844AF0
    .long   0x0FD40F27, 0x0E810DE2, 0x0D4B0CB9, 0x0C2E0BA9	| 40844B00
    .long   0x0B290AAF, 0x0A3A09CB, 0x095F08F9, 0x08970839	| 40844B10
    .long   0x07DF0789, 0x073706E8, 0x069C0654, 0x060F05CC	| 40844B20
    .long   0x058D0550, 0x051604DF, 0x04A90476, 0x04460417	| 40844B30
    .long   0x03EA03BF, 0x0396036F, 0x034A0326, 0x030302E2	| 40844B40
    .long   0x02C302A5, 0x0288026C, 0x02520238, 0x02200209	| 40844B50
    .long   0x01F201DD, 0x01C901B5, 0x01A30191, 0x0180016F	| 40844B60
    .long   0x01600151, 0x01420134, 0x0127011B, 0x010F0103	| 40844B70
    .long   0x00F800ED, 0x00E300DA, 0x00D000C7, 0x00BF00B7	| 40844B80
    .long   0x00AF00A7, 0x00A0009A, 0x0093008D, 0x00870081	| 40844B90
    .long   0x007B0076, 0x0071006C, 0x00680063, 0x005F005B	| 40844BA0
    .long   0x00570053, 0x0050004C, 0x00490046, 0x00430040	| 40844BB0
MIN2_TABLE:             /* (data) */
    .long   0xFFEE008C, 0x008CFFEE, 0x00000000, 0x00000000	| 40844BC0
IQUADEL2_TABLE:         /* (data) */
    .long   0x004000D8, 0xFF27FFBF, 0x00000000, 0x00000000	| 40844BD0
    .long   0x004300E2, 0xFF1DFFBC, 0x00000000, 0x00000000	| 40844BE0
    .long   0x004600EC, 0xFF13FFB9, 0x00000000, 0x00000000	| 40844BF0
    .long   0x004A00F6, 0xFF09FFB5, 0x00000000, 0x00000000	| 40844C00
    .long   0x004D0101, 0xFEFEFFB2, 0x00000000, 0x00000000	| 40844C10
    .long   0x0050010C, 0xFEF3FFAF, 0x00000000, 0x00000000	| 40844C20
    .long   0x00540118, 0xFEE7FFAB, 0x00000000, 0x00000000	| 40844C30
    .long   0x00580126, 0xFED9FFA7, 0x00000000, 0x00000000	| 40844C40
    .long   0x005C0133, 0xFECCFFA3, 0x00000000, 0x00000000	| 40844C50
    .long   0x00600141, 0xFEBEFF9F, 0x00000000, 0x00000000	| 40844C60
    .long   0x0064014E, 0xFEB1FF9B, 0x00000000, 0x00000000	| 40844C70
    .long   0x0068015E, 0xFEA1FF97, 0x00000000, 0x00000000	| 40844C80
    .long   0x006D016D, 0xFE92FF92, 0x00000000, 0x00000000	| 40844C90
    .long   0x0072017E, 0xFE81FF8D, 0x00000000, 0x00000000	| 40844CA0
    .long   0x0077018F, 0xFE70FF88, 0x00000000, 0x00000000	| 40844CB0
    .long   0x007C01A0, 0xFE5FFF83, 0x00000000, 0x00000000	| 40844CC0
    .long   0x008201B2, 0xFE4DFF7D, 0x00000000, 0x00000000	| 40844CD0
    .long   0x008801C6, 0xFE39FF77, 0x00000000, 0x00000000	| 40844CE0
    .long   0x008E01DB, 0xFE24FF71, 0x00000000, 0x00000000	| 40844CF0
    .long   0x009401EF, 0xFE10FF6B, 0x00000000, 0x00000000	| 40844D00
    .long   0x009B0207, 0xFDF8FF64, 0x00000000, 0x00000000	| 40844D10
    .long   0x00A2021D, 0xFDE2FF5D, 0x00000000, 0x00000000	| 40844D20
    .long   0x00A90234, 0xFDCBFF56, 0x00000000, 0x00000000	| 40844D30
    .long   0x00B0024E, 0xFDB1FF4F, 0x00000000, 0x00000000	| 40844D40
    .long   0x00B90269, 0xFD96FF46, 0x00000000, 0x00000000	| 40844D50
    .long   0x00C10284, 0xFD7BFF3E, 0x00000000, 0x00000000	| 40844D60
    .long   0x00C902A1, 0xFD5EFF36, 0x00000000, 0x00000000	| 40844D70
    .long   0x00D202BF, 0xFD40FF2D, 0x00000000, 0x00000000	| 40844D80
    .long   0x00DC02DF, 0xFD20FF23, 0x00000000, 0x00000000	| 40844D90
    .long   0x00E602FF, 0xFD00FF19, 0x00000000, 0x00000000	| 40844DA0
    .long   0x00F00321, 0xFCDEFF0F, 0x00000000, 0x00000000	| 40844DB0
    .long   0x00FB0346, 0xFCB9FF04, 0x00000000, 0x00000000	| 40844DC0
    .long   0x0106036C, 0xFC93FEF9, 0x00000000, 0x00000000	| 40844DD0
    .long   0x01120392, 0xFC6DFEED, 0x00000000, 0x00000000	| 40844DE0
    .long   0x011E03BB, 0xFC44FEE1, 0x00000000, 0x00000000	| 40844DF0
    .long   0x012B03E5, 0xFC1AFED4, 0x00000000, 0x00000000	| 40844E00
    .long   0x01380411, 0xFBEEFEC7, 0x00000000, 0x00000000	| 40844E10
    .long   0x01460441, 0xFBBEFEB9, 0x00000000, 0x00000000	| 40844E20
    .long   0x01550472, 0xFB8DFEAA, 0x00000000, 0x00000000	| 40844E30
    .long   0x016404A4, 0xFB5BFE9B, 0x00000000, 0x00000000	| 40844E40
    .long   0x017404D9, 0xFB26FE8B, 0x00000000, 0x00000000	| 40844E50
    .long   0x01840511, 0xFAEEFE7B, 0x00000000, 0x00000000	| 40844E60
    .long   0x0196054A, 0xFAB5FE69, 0x00000000, 0x00000000	| 40844E70
    .long   0x01A80587, 0xFA78FE57, 0x00000000, 0x00000000	| 40844E80
    .long   0x01BB05C6, 0xFA39FE44, 0x00000000, 0x00000000	| 40844E90
    .long   0x01CE0608, 0xF9F7FE31, 0x00000000, 0x00000000	| 40844EA0
    .long   0x01E3064D, 0xF9B2FE1C, 0x00000000, 0x00000000	| 40844EB0
    .long   0x01F90694, 0xF96BFE06, 0x00000000, 0x00000000	| 40844EC0
    .long   0x020F06E0, 0xF91FFDF0, 0x00000000, 0x00000000	| 40844ED0
    .long   0x0227072E, 0xF8D1FDD8, 0x00000000, 0x00000000	| 40844EE0
    .long   0x02400781, 0xF87EFDBF, 0x00000000, 0x00000000	| 40844EF0
    .long   0x025907D7, 0xF828FDA6, 0x00000000, 0x00000000	| 40844F00
    .long   0x02740831, 0xF7CEFD8B, 0x00000000, 0x00000000	| 40844F10
    .long   0x0290088E, 0xF771FD6F, 0x00000000, 0x00000000	| 40844F20
    .long   0x02AE08F0, 0xF70FFD51, 0x00000000, 0x00000000	| 40844F30
    .long   0x02CC0955, 0xF6AAFD33, 0x00000000, 0x00000000	| 40844F40
    .long   0x02EC09C0, 0xF63FFD13, 0x00000000, 0x00000000	| 40844F50
    .long   0x030D0A2F, 0xF5D0FCF2, 0x00000000, 0x00000000	| 40844F60
    .long   0x03300AA4, 0xF55BFCCF, 0x00000000, 0x00000000	| 40844F70
    .long   0x03550B1E, 0xF4E1FCAA, 0x00000000, 0x00000000	| 40844F80
    .long   0x037B0B9D, 0xF462FC84, 0x00000000, 0x00000000	| 40844F90
    .long   0x03A20C20, 0xF3DFFC5D, 0x00000000, 0x00000000	| 40844FA0
    .long   0x03CC0CAB, 0xF354FC33, 0x00000000, 0x00000000	| 40844FB0
    .long   0x03F80D3D, 0xF2C2FC07, 0x00000000, 0x00000000	| 40844FC0
    .long   0x04250DD3, 0xF22CFBDA, 0x00000000, 0x00000000	| 40844FD0
    .long   0x04540E72, 0xF18DFBAB, 0x00000000, 0x00000000	| 40844FE0
    .long   0x04860F16, 0xF0E9FB79, 0x00000000, 0x00000000	| 40844FF0
    .long   0x04B90FC3, 0xF03CFB46, 0x00000000, 0x00000000	| 40845000
    .long   0x04F01078, 0xEF87FB0F, 0x00000000, 0x00000000	| 40845010
    .long   0x05281133, 0xEECCFAD7, 0x00000000, 0x00000000	| 40845020
    .long   0x056311F7, 0xEE08FA9C, 0x00000000, 0x00000000	| 40845030
    .long   0x05A112C6, 0xED39FA5E, 0x00000000, 0x00000000	| 40845040
    .long   0x05E1139B, 0xEC64FA1E, 0x00000000, 0x00000000	| 40845050
    .long   0x0624147C, 0xEB83F9DB, 0x00000000, 0x00000000	| 40845060
    .long   0x066A1565, 0xEA9AF995, 0x00000000, 0x00000000	| 40845070
    .long   0x06B3165A, 0xE9A5F94C, 0x00000000, 0x00000000	| 40845080
    .long   0x0700175A, 0xE8A5F8FF, 0x00000000, 0x00000000	| 40845090
    .long   0x07501865, 0xE79AF8AF, 0x00000000, 0x00000000	| 408450A0
    .long   0x07A3197A, 0xE685F85C, 0x00000000, 0x00000000	| 408450B0
    .long   0x07FB1A9D, 0xE562F804, 0x00000000, 0x00000000	| 408450C0
    .long   0x08561BCE, 0xE431F7A9, 0x00000000, 0x00000000	| 408450D0
    .long   0x08B51D0C, 0xE2F3F74A, 0x00000000, 0x00000000	| 408450E0
    .long   0x09191E57, 0xE1A8F6E6, 0x00000000, 0x00000000	| 408450F0
    .long   0x09801FB2, 0xE04DF67F, 0x00000000, 0x00000000	| 40845100
    .long   0x09ED211D, 0xDEE2F612, 0x00000000, 0x00000000	| 40845110
    .long   0x0A5F2296, 0xDD69F5A0, 0x00000000, 0x00000000	| 40845120
    .long   0x0AD52422, 0xDBDDF52A, 0x00000000, 0x00000000	| 40845130
    .long   0x0B5125BF, 0xDA40F4AE, 0x00000000, 0x00000000	| 40845140
    .long   0x0BD2276E, 0xD891F42D, 0x00000000, 0x00000000	| 40845150
    .long   0x0C5A2932, 0xD6CDF3A5, 0x00000000, 0x00000000	| 40845160
    .long   0x0CE72B08, 0xD4F7F318, 0x00000000, 0x00000000	| 40845170
    .long   0x0D7A2CF4, 0xD30BF285, 0x00000000, 0x00000000	| 40845180
    .long   0x0E142EF4, 0xD10BF1EB, 0x00000000, 0x00000000	| 40845190
    .long   0x0EB5310C, 0xCEF3F14A, 0x00000000, 0x00000000	| 408451A0
    .long   0x0F5D333E, 0xCCC1F0A2, 0x00000000, 0x00000000	| 408451B0
    .long   0x100C3587, 0xCA78EFF3, 0x00000000, 0x00000000	| 408451C0
    .long   0x10C437EB, 0xC814EF3B, 0x00000000, 0x00000000	| 408451D0
    .long   0x11833A69, 0xC596EE7C, 0x00000000, 0x00000000	| 408451E0
    .long   0x124B3D05, 0xC2FAEDB4, 0x00000000, 0x00000000	| 408451F0
    .long   0x131C3FBE, 0xC041ECE3, 0x00000000, 0x00000000	| 40845200
    .long   0x13F74296, 0xBD69EC08, 0x00000000, 0x00000000	| 40845210
    .long   0x14DB458F, 0xBA70EB24, 0x00000000, 0x00000000	| 40845220
    .long   0x15C948AA, 0xB755EA36, 0x00000000, 0x00000000	| 40845230
    .long   0x16C24BE9, 0xB416E93D, 0x00000000, 0x00000000	| 40845240
    .long   0x17C64F4C, 0xB0B3E839, 0x00000000, 0x00000000	| 40845250
    .long   0x18D652D5, 0xAD2AE729, 0x00000000, 0x00000000	| 40845260
    .long   0x19F25688, 0xA977E60D, 0x00000000, 0x00000000	| 40845270
    .long   0x1B1A5A65, 0xA59AE4E5, 0x00000000, 0x00000000	| 40845280
    .long   0x1C505E6D, 0xA192E3AF, 0x00000000, 0x00000000	| 40845290
    .long   0x1D9362A4, 0x9D5BE26C, 0x00000000, 0x00000000	| 408452A0
    .long   0x1EE5670C, 0x98F3E11A, 0x00000000, 0x00000000	| 408452B0
    .long   0x20466BA5, 0x945ADFB9, 0x00000000, 0x00000000	| 408452C0
    .long   0x21B77072, 0x8F8DDE48, 0x00000000, 0x00000000	| 408452D0
    .long   0x23387578, 0x8A87DCC7, 0x00000000, 0x00000000	| 408452E0
    .long   0x24CB7AB5, 0x854ADB34, 0x00000000, 0x00000000	| 408452F0
    .long   0x266F7FFF, 0x8000D990, 0x00000000, 0x00000000	| 40845300
    .long   0x28267FFF, 0x8000D7D9, 0x00000000, 0x00000000	| 40845310
    .long   0x29F17FFF, 0x8000D60E, 0x00000000, 0x00000000	| 40845320
    .long   0x2BD07FFF, 0x8000D42F, 0x00000000, 0x00000000	| 40845330
    .long   0x2DC57FFF, 0x8000D23A, 0x00000000, 0x00000000	| 40845340
    .long   0x2FD07FFF, 0x8000D02F, 0x00000000, 0x00000000	| 40845350
    .long   0x31F27FFF, 0x8000CE0D, 0x00000000, 0x00000000	| 40845360
    .long   0x342C7FFF, 0x8000CBD3, 0x00000000, 0x00000000	| 40845370
    .long   0x36817FFF, 0x8000C97E, 0x00000000, 0x00000000	| 40845380
    .long   0x38F07FFF, 0x8000C70F, 0x00000000, 0x00000000	| 40845390
    .long   0x3B7A7FFF, 0x8000C485, 0x00000000, 0x00000000	| 408453A0
    .long   0x3E227FFF, 0x8000C1DD, 0x00000000, 0x00000000	| 408453B0
    .long   0x40E77FFF, 0x8000BF18, 0x00000000, 0x00000000	| 408453C0
MIN3_TABLE:             /* (data) */
    .long   0xFFF30008, 0x004C00DE, 0x00DE004C, 0x0008FFF3	| 408453D0
IQUADEL3_TABLE:         /* (data) */
    .long   0x00250074, 0x00CE014A, 0xFEB5FF31, 0xFF8BFFDA	| 408453E0
    .long   0x00270079, 0x00D8015A, 0xFEA5FF27, 0xFF86FFD8	| 408453F0
    .long   0x0029007F, 0x00E10169, 0xFE96FF1E, 0xFF80FFD6	| 40845400
    .long   0x002A0084, 0x00EB0179, 0xFE86FF14, 0xFF7BFFD5	| 40845410
    .long   0x002C0089, 0x00F50188, 0xFE77FF0A, 0xFF76FFD3	| 40845420
    .long   0x002E0090, 0x0100019A, 0xFE65FEFF, 0xFF6FFFD1	| 40845430
    .long   0x00300096, 0x010B01AC, 0xFE53FEF4, 0xFF69FFCF	| 40845440
    .long   0x0033009D, 0x011801C1, 0xFE3EFEE7, 0xFF62FFCC	| 40845450
    .long   0x003500A5, 0x012501D6, 0xFE29FEDA, 0xFF5AFFCA	| 40845460
    .long   0x003700AC, 0x013201EA, 0xFE15FECD, 0xFF53FFC8	| 40845470
    .long   0x003A00B3, 0x013F01FF, 0xFE00FEC0, 0xFF4CFFC5	| 40845480
    .long   0x003C00BB, 0x014D0216, 0xFDE9FEB2, 0xFF44FFC3	| 40845490
    .long   0x003F00C3, 0x015C022D, 0xFDD2FEA3, 0xFF3CFFC0	| 408454A0
    .long   0x004200CD, 0x016C0247, 0xFDB8FE93, 0xFF32FFBD	| 408454B0
    .long   0x004500D6, 0x017C0261, 0xFD9EFE83, 0xFF29FFBA	| 408454C0
    .long   0x004800DF, 0x018C027B, 0xFD84FE73, 0xFF20FFB7	| 408454D0
    .long   0x004B00E9, 0x019E0297, 0xFD68FE61, 0xFF16FFB4	| 408454E0
    .long   0x004F00F4, 0x01B102B6, 0xFD49FE4E, 0xFF0BFFB0	| 408454F0
    .long   0x005200FE, 0x01C502D5, 0xFD2AFE3A, 0xFF01FFAD	| 40845500
    .long   0x00560109, 0x01D802F4, 0xFD0BFE27, 0xFEF6FFA9	| 40845510
    .long   0x005A0116, 0x01EF0318, 0xFCE7FE10, 0xFEE9FFA5	| 40845520
    .long   0x005E0122, 0x0204033A, 0xFCC5FDFB, 0xFEDDFFA1	| 40845530
    .long   0x0062012F, 0x021A035E, 0xFCA1FDE5, 0xFED0FF9D	| 40845540
    .long   0x0066013C, 0x02320385, 0xFC7AFDCD, 0xFEC3FF99	| 40845550
    .long   0x006B014B, 0x024C03AE, 0xFC51FDB3, 0xFEB4FF94	| 40845560
    .long   0x00700159, 0x026603D7, 0xFC28FD99, 0xFEA6FF8F	| 40845570
    .long   0x00750169, 0x02810403, 0xFBFCFD7E, 0xFE96FF8A	| 40845580
    .long   0x007A0179, 0x029E0432, 0xFBCDFD61, 0xFE86FF85	| 40845590
    .long   0x007F018A, 0x02BD0463, 0xFB9CFD42, 0xFE75FF80	| 408455A0
    .long   0x0085019B, 0x02DC0494, 0xFB6BFD23, 0xFE64FF7A	| 408455B0
    .long   0x008B01AE, 0x02FC04C8, 0xFB37FD03, 0xFE51FF74	| 408455C0
    .long   0x009101C1, 0x031F0500, 0xFAFFFCE0, 0xFE3EFF6E	| 408455D0
    .long   0x009801D5, 0x03430539, 0xFAC6FCBC, 0xFE2AFF67	| 408455E0
    .long   0x009F01EA, 0x03680575, 0xFA8AFC97, 0xFE15FF60	| 408455F0
    .long   0x00A60200, 0x038F05B3, 0xFA4CFC70, 0xFDFFFF59	| 40845600
    .long   0x00AD0217, 0x03B705F3, 0xFA0CFC48, 0xFDE8FF52	| 40845610
    .long   0x00B5022E, 0x03E10636, 0xF9C9FC1E, 0xFDD1FF4A	| 40845620
    .long   0x00BD0248, 0x040E067F, 0xF980FBF1, 0xFDB7FF42	| 40845630
    .long   0x00C50262, 0x043D06CA, 0xF935FBC2, 0xFD9DFF3A	| 40845640
    .long   0x00CE027D, 0x046D0717, 0xF8E8FB92, 0xFD82FF31	| 40845650
    .long   0x00D70299, 0x049F0767, 0xF898FB60, 0xFD66FF28	| 40845660
    .long   0x00E102B7, 0x04D507BC, 0xF843FB2A, 0xFD48FF1E	| 40845670
    .long   0x00EB02D6, 0x050B0814, 0xF7EBFAF4, 0xFD29FF14	| 40845680
    .long   0x00F602F7, 0x05450871, 0xF78EFABA, 0xFD08FF09	| 40845690
    .long   0x01010318, 0x058108D1, 0xF72EFA7E, 0xFCE7FEFE	| 408456A0
    .long   0x010C033C, 0x05C00935, 0xF6CAFA3F, 0xFCC3FEF3	| 408456B0
    .long   0x01180361, 0x0602099F, 0xF660F9FD, 0xFC9EFEE7	| 408456C0
    .long   0x01250387, 0x06460A0C, 0xF5F3F9B9, 0xFC78FEDA	| 408456D0
    .long   0x013203B0, 0x068E0A80, 0xF57FF971, 0xFC4FFECD	| 408456E0
    .long   0x013F03DA, 0x06D90AF7, 0xF508F926, 0xFC25FEC0	| 408456F0
    .long   0x014E0406, 0x07280B75, 0xF48AF8D7, 0xFBF9FEB1	| 40845700
    .long   0x015D0434, 0x077A0BF9, 0xF406F885, 0xFBCBFEA2	| 40845710
    .long   0x016C0464, 0x07CF0C82, 0xF37DF830, 0xFB9BFE93	| 40845720
    .long   0x017C0496, 0x08280D10, 0xF2EFF7D7, 0xFB69FE83	| 40845730
    .long   0x018E04CB, 0x08860DA6, 0xF259F779, 0xFB34FE71	| 40845740
    .long   0x019F0501, 0x08E60E41, 0xF1BEF719, 0xFAFEFE60	| 40845750
    .long   0x01B2053B, 0x094C0EE3, 0xF11CF6B3, 0xFAC4FE4D	| 40845760
    .long   0x01C50576, 0x09B60F8E, 0xF071F649, 0xFA89FE3A	| 40845770
    .long   0x01D905B5, 0x0A261040, 0xEFBFF5D9, 0xFA4AFE26	| 40845780
    .long   0x01EF05F6, 0x0A9A10FA, 0xEF05F565, 0xFA09FE10	| 40845790
    .long   0x0205063A, 0x0B1311BC, 0xEE43F4EC, 0xF9C5FDFA	| 408457A0
    .long   0x021C0681, 0x0B911285, 0xED7AF46E, 0xF97EFDE3	| 408457B0
    .long   0x023406CC, 0x0C151359, 0xECA6F3EA, 0xF933FDCB	| 408457C0
    .long   0x024D071A, 0x0CA01437, 0xEBC8F35F, 0xF8E5FDB2	| 408457D0
    .long   0x0267076A, 0x0D2F151D, 0xEAE2F2D0, 0xF895FD98	| 408457E0
    .long   0x028307C0, 0x0DC7160F, 0xE9F0F238, 0xF83FFD7C	| 408457F0
    .long   0x029F0818, 0x0E63170A, 0xE8F5F19C, 0xF7E7FD60	| 40845800
    .long   0x02BD0874, 0x0F081811, 0xE7EEF0F7, 0xF78BFD42	| 40845810
    .long   0x02DD08D5, 0x0FB41926, 0xE6D9F04B, 0xF72AFD22	| 40845820
    .long   0x02FE093A, 0x10671A44, 0xE5BBEF98, 0xF6C5FD01	| 40845830
    .long   0x032009A3, 0x11221B70, 0xE48FEEDD, 0xF65CFCDF	| 40845840
    .long   0x03440A12, 0x11E71CAB, 0xE354EE18, 0xF5EDFCBB	| 40845850
    .long   0x03690A84, 0x12B21DF0, 0xE20FED4D, 0xF57BFC96	| 40845860
    .long   0x03900AFD, 0x13891F48, 0xE0B7EC76, 0xF502FC6F	| 40845870
    .long   0x03B80B7A, 0x146720AC, 0xDF53EB98, 0xF485FC47	| 40845880
    .long   0x03E30BFE, 0x15512223, 0xDDDCEAAE, 0xF401FC1C	| 40845890
    .long   0x040F0C87, 0x164523A9, 0xDC56E9BA, 0xF378FBF0	| 408458A0
    .long   0x043E0D16, 0x17442541, 0xDABEE8BB, 0xF2E9FBC1	| 408458B0
    .long   0x046E0DAB, 0x184C26E8, 0xD917E7B3, 0xF254FB91	| 408458C0
    .long   0x04A10E47, 0x196128A4, 0xD75BE69E, 0xF1B8FB5E	| 408458D0
    .long   0x04D60EEA, 0x1A842A75, 0xD58AE57B, 0xF115FB29	| 408458E0
    .long   0x050D0F95, 0x1BB32C5B, 0xD3A4E44C, 0xF06AFAF2	| 408458F0
    .long   0x05471046, 0x1CEF2E55, 0xD1AAE310, 0xEFB9FAB8	| 40845900
    .long   0x05831100, 0x1E3A3066, 0xCF99E1C5, 0xEEFFFA7C	| 40845910
    .long   0x05C211C3, 0x1F943292, 0xCD6DE06B, 0xEE3CFA3D	| 40845920
    .long   0x0604128E, 0x20FC34D2, 0xCB2DDF03, 0xED71F9FB	| 40845930
    .long   0x06491362, 0x2275372E, 0xC8D1DD8A, 0xEC9DF9B6	| 40845940
    .long   0x0690143F, 0x23FF39A4, 0xC65BDC00, 0xEBC0F96F	| 40845950
    .long   0x06DC1527, 0x259A3C37, 0xC3C8DA65, 0xEAD8F923	| 40845960
    .long   0x072A1619, 0x27493EE8, 0xC117D8B6, 0xE9E6F8D5	| 40845970
    .long   0x077C1715, 0x290941B6, 0xBE49D6F6, 0xE8EAF883	| 40845980
    .long   0x07D1181D, 0x2ADF44A6, 0xBB59D520, 0xE7E2F82E	| 40845990
    .long   0x082B1930, 0x2CC747B4, 0xB84BD338, 0xE6CFF7D4	| 408459A0
    .long   0x08881A50, 0x2EC64AE7, 0xB518D139, 0xE5AFF777	| 408459B0
    .long   0x08EA1B7D, 0x30DE4E40, 0xB1BFCF21, 0xE482F715	| 408459C0
    .long   0x094F1CB7, 0x330C51BE, 0xAE41CCF3, 0xE348F6B0	| 408459D0
    .long   0x09BA1DFF, 0x35545565, 0xAA9ACAAB, 0xE200F645	| 408459E0
    .long   0x0A291F55, 0x37B45932, 0xA6CDC84B, 0xE0AAF5D6	| 408459F0
    .long   0x0A9D20BC, 0x3A315D2E, 0xA2D1C5CE, 0xDF43F562	| 40845A00
    .long   0x0B162231, 0x3CC96156, 0x9EA9C336, 0xDDCEF4E9	| 40845A10
    .long   0x0B9523B8, 0x3F8065AF, 0x9A50C07F, 0xDC47F46A	| 40845A20
    .long   0x0C192551, 0x42566A39, 0x95C6BDA9, 0xDAAEF3E6	| 40845A30
    .long   0x0CA426FB, 0x454C6EF7, 0x9108BAB3, 0xD904F35B	| 40845A40
    .long   0x0D3428B8, 0x486473EB, 0x8C14B79B, 0xD747F2CB	| 40845A50
    .long   0x0DCB2A8A, 0x4B9F7918, 0x86E7B460, 0xD575F234	| 40845A60
    .long   0x0E682C6F, 0x4EFE7E7E, 0x8181B101, 0xD390F197	| 40845A70
    .long   0x0F0D2E6B, 0x52857FFF, 0x8000AD7A, 0xD194F0F2	| 40845A80
    .long   0x0FB9307E, 0x56357FFF, 0x8000A9CA, 0xCF81F046	| 40845A90
    .long   0x106D32A7, 0x5A0D7FFF, 0x8000A5F2, 0xCD58EF92	| 40845AA0
    .long   0x112834EA, 0x5E127FFF, 0x8000A1ED, 0xCB15EED7	| 40845AB0
    .long   0x11ED3747, 0x62457FFF, 0x80009DBA, 0xC8B8EE12	| 40845AC0
    .long   0x12B939BF, 0x66A87FFF, 0x80009957, 0xC640ED46	| 40845AD0
    .long   0x138F3C52, 0x6B3C7FFF, 0x800094C3, 0xC3ADEC70	| 40845AE0
    .long   0x146F3F04, 0x70067FFF, 0x80008FF9, 0xC0FBEB90	| 40845AF0
    .long   0x155841D3, 0x75057FFF, 0x80008AFA, 0xBE2CEAA7	| 40845B00
    .long   0x164C44C3, 0x7A3E7FFF, 0x800085C1, 0xBB3CE9B3	| 40845B10
    .long   0x174B47D5, 0x7FB37FFF, 0x8000804C, 0xB82AE8B4	| 40845B20
    .long   0x18554B0A, 0x7FFF7FFF, 0x80008000, 0xB4F5E7AA	| 40845B30
    .long   0x196B4E63, 0x7FFF7FFF, 0x80008000, 0xB19CE694	| 40845B40
    .long   0x1A8D51E3, 0x7FFF7FFF, 0x80008000, 0xAE1CE572	| 40845B50
    .long   0x1BBD558B, 0x7FFF7FFF, 0x80008000, 0xAA74E442	| 40845B60
    .long   0x1CFA595C, 0x7FFF7FFF, 0x80008000, 0xA6A3E305	| 40845B70
    .long   0x1E455D59, 0x7FFF7FFF, 0x80008000, 0xA2A6E1BA	| 40845B80
    .long   0x1F9F6184, 0x7FFF7FFF, 0x80008000, 0x9E7BE060	| 40845B90
    .long   0x210865DE, 0x7FFF7FFF, 0x80008000, 0x9A21DEF7	| 40845BA0
    .long   0x22816A6A, 0x7FFF7FFF, 0x80008000, 0x9595DD7E	| 40845BB0
    .long   0x240C6F29, 0x7FFF7FFF, 0x80008000, 0x90D6DBF3	| 40845BC0
    .long   0x25A7741F, 0x7FFF7FFF, 0x80008000, 0x8BE0DA58	| 40845BD0

/*
 SNDSOUNDMANAGERVERSION (still raw words): routines returning the
 Sound Manager version (0x02000000) and similar values, with move.l #...,4(sp), rts.
*/
SNDSOUNDMANAGERVERSION:
    .short  0x2F7C, 0x0200, 0x0000	| 40845BE0
    .short  0x0004, 0x4E75	| orib #117,%d4
    orib #0,%d0
SNDSOUNDMANAGERVERSION_E:  /* (second version routine) */
    .byte   0x00, 0x00	| 40845BEE
SNDSOUNDMANAGERVERSION_10:  /* (data) */
    .byte   0x2F, 0x7C	| 40845BF0
    andib #0,%d0
    .short  0x0004, 0x4E75	| orib #117,%d4
    orib #0,%d0
    .byte   0x00, 0x00	| 40845BFE
    lea %pc@(SNDSOUNDMANAGERVERSION_10_18),%fp	| 40845C00
    jmp %pc@(BOOTBEEP6)
SNDSOUNDMANAGERVERSION_10_18:
    .byte   0x4E, 0x75	| 40845C08
