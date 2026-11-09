/*
 os/timemgr.s - Time Manager, one-second interrupt, parameter RAM I/O
 From TIMEMGR (0x4080AE90). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 The Time Manager uses VIA 1 timer 2. TimeVars (16 bytes): +0 the queue of active
 tasks (each with the time left after the one before it, +10), +4 timer correction,
 +6 24, +8 current time, +12 time not yet accounted. Times are converted between
 microseconds/milliseconds and VIA ticks with INSTIME_16 (a multiply by the constants
 that follow each call).
*/

/*
 _RmvTime(a0 = task): remove it from the active queue and leave the time it had left
 in tmCount (negative = microseconds) for _InsXTime/_PrimeTime.
*/
trap_RmvTime:
TIMEMGR:
RMVTIME:
    movel %d3,%sp@-
    jbsr PRIMETIME_A4
    moveq #0,%d2
    lea %a2@,%a1
TIMEMGR_A:              /* walk the queue, summing the times */
    movel %a1@,%d0
    jbeq TIMEMGR_2A
    exg %d0,%a1
    movel %a1@(10),%d1
    addl %d1,%d2
    cmpal %a0,%a1
    jbne TIMEMGR_A
    moveal %d0,%a1
    movel %a0@,%d0
    movel %d0,%a1@
    jbeq TIMEMGR_28
    moveal %d0,%a1
    addl %d1,%a1@(10)
TIMEMGR_28:             /* (next task gets its time) */
    movel %d2,%d0
TIMEMGR_2A:             /* time left */
    subl %a2@(12),%d0
    jbcc TIMEMGR_32
    moveq #0,%d0
TIMEMGR_32:             /* restart the timer, convert the time back (raw constants follow) */
    jbsr PRIMETIME_138
    moveal %d0,%a1
    jbsr INSTIME_16
    .short  0xA366, 0x10BC, 0xF800	| 4080AECA
    .short  0x0000	| 4080AED0
    roll #5,%d0
    negl %d0
    jbmi TIMEMGR_54
    movel %a1,%d0
    jbsr INSTIME_16
    .long   0x053A8FE6	| 4080AEDC
    .long   0x00000000	| 4080AEE0
TIMEMGR_54:             /* tmCount */
    movel %d0,%a0@(10)
    movel %sp@+,%d3
    moveq #0,%d1

/* _InsTime / _InsXTime: mark the task installed (and extended, flags from d1). */
trap_InsTime:
INSTIME:
    moveq #31,%d0
    andb %a0@(4),%d0
    andiw #1536,%d1
    lsrw #4,%d1
    orb %d1,%d0
    moveb %d0,%a0@(4)
    moveq #0,%d0
    rts

INSTIME_16:             /* d0 = d0 x the 64-bit constant after the call (fixed point), rounded */
    moveal %sp@+,%a2
    movel %a2@+,%d1
    mulul %d0,%d0,%d1
    movel %a2@+,%d2
    jbeq INSTIME_2C
    andl %d2,%d1
    addl %d0,%d2
    subxl %d2,%d2
    orl %d2,%d0
    orl %d1,%d0
INSTIME_2C:             /* return past the constants */
    jmp %a2@

/*
 _PrimeTime(a0 = task, d0 = time: ms, or -us): start the task. Extended tasks keep a
 drift-free schedule (+14 the time it should run). Inserted in the active queue in
 order.
*/
trap_PrimeTime:
PRIMETIME:
    movel %d3,%sp@-
    tstl %d0
    jbpl PRIMETIME_14
    negl %d0
    jbsr INSTIME_16
    .short  0x0C88, 0xA47F, 0x0000, 0x0000, 0x600C	| 4080AF24
PRIMETIME_14:           /* milliseconds */
    jbsr INSTIME_16
    .long   0xC3D70A3E, 0xFC000000	| 4080AF30
    roll #6,%d0
    jbsr PRIMETIME_A4
    bset #7,%a0@(4)
    jbne PRIMETIME_9A
    btst #6,%a0@(4)
    jbeq PRIMETIME_74
    movel %a2@(8),%d2
    movel %a0@(14),%d1
    jbeq PRIMETIME_6A
    subl %d2,%d1
    jbpl PRIMETIME_68
    addl %d1,%d0
    jbcs PRIMETIME_6A
    addl %d0,%d2
    jbne PRIMETIME_4C
    moveq #1,%d2
PRIMETIME_4C:           /* (extended task already late) */
    movel %d2,%a0@(14)
    movel %d0,%d1
    subl %d0,%a2@(12)
    moveq #0,%d0
    lea %a2@,%a1
    movel %a1@,%d2
    jbeq PRIMETIME_92
    exg %d2,%a1
    subl %d1,%a1@(10)
    exg %d2,%a1
    jbra PRIMETIME_92
PRIMETIME_68:           /* (on schedule) */
    addl %d1,%d0
PRIMETIME_6A:           /* time it should run */
    addl %d0,%d2
    jbne PRIMETIME_70
    moveq #1,%d2
PRIMETIME_70:           /* store it */
    movel %d2,%a0@(14)
PRIMETIME_74:           /* insert in order */
    addl %a2@(12),%d0
    lea %a2@,%a1
PRIMETIME_7A:           /* walk the queue */
    movel %a1@,%d2
    jbeq PRIMETIME_92
    exg %d2,%a1
    movel %a1@(10),%d1
    subl %d1,%d0
    jbcc PRIMETIME_7A
    addl %d1,%d0
    subl %d0,%d1
    movel %d1,%a1@(10)
    exg %d2,%a1
PRIMETIME_92:           /* link it in */
    movel %d2,%a0@
    movel %d0,%a0@(10)
    movel %a0,%a1@
PRIMETIME_9A:           /* restart the timer */
    jbsr PRIMETIME_138
    movel %sp@+,%d3
    moveq #0,%d0
    rts

PRIMETIME_A4:           /* interrupts masked, read the VIA timer: account the time passed */
    movew %sr,%d3
    swap %d3
    movew #240,%d3
    moveal VIA,%a1
    lea %a1@(4608),%a1
    moveal TimeVars,%a2
    oriw #1792,%sr
    moveb %a1@,%d2
    moveq #32,%d1
    andb %a1@(2048),%d1
    negl %d1
    moveb %d2,%d1
    lslw #8,%d1
    moveb %a1@(-512),%d1
    subb %a1@,%d2
    jbeq PRIMETIME_DE
    subxl %d2,%d2
    orl %d2,%d1
    moveb %a1@,%d1
    lslw #8,%d1
    moveb %a1@(-512),%d1
PRIMETIME_DE:           /* (in VIA ticks / 16) */
    moveq #15,%d2
    addl %d2,%d1
    andb %d1,%d3
    asrl #4,%d1
PRIMETIME_E6:           /* count down the first task */
    subl %d1,%a2@(8)
    movel %a2@,%d2
    jbeq PRIMETIME_106
    moveal %d2,%a1
    moveq #0,%d2
    subl %a2@(12),%d1
    jbpl PRIMETIME_10C
    addl %a1@(10),%d1
    jbcs PRIMETIME_102
    subl %d1,%d2
    moveq #0,%d1
PRIMETIME_102:          /* (its time) */
    movel %d1,%a1@(10)
PRIMETIME_106:          /* return */
    movel %d2,%a2@(12)
    rts
PRIMETIME_10C:          /* (overflow) */
    addl %a1@(10),%d1
    jbra PRIMETIME_102
PRIMETIME_112:          /* timer 2 interrupt: run the first task if its time is up */
    jbsr PRIMETIME_A4
    movel %a2@,%d0
    jbeq PRIMETIME_138
    moveal %d0,%a0
    tstl %a0@(10)
    jbne PRIMETIME_138
    movel %a0@,%a2@
    bclr #7,%a0@(4)
    jbsr PRIMETIME_138
    movel %a0@(6),%d0
    jbeq PRIMETIME_136
    moveal %a0,%a1
    moveal %d0,%a0
    jmp %a0@
PRIMETIME_136:          /* (no routine) */
    rts

PRIMETIME_138:          /* start the timer for the first task (at most 4095 units), interrupts back */
    movel #4095,%d2
    addb %a2@(4),%d3
    movel %a2@,%d1
    jbeq PRIMETIME_16C
    moveal %d1,%a1
    movel %a1@(10),%d1
    subl %a2@(12),%d1
    jbcc PRIMETIME_15C
    negl %d1
    movel %d1,%a2@(12)
    moveq #0,%d1
    jbra PRIMETIME_160
PRIMETIME_15C:          /* (none pending) */
    clrl %a2@(12)
PRIMETIME_160:          /* limit */
    cmpl %d2,%d1
    jbcc PRIMETIME_166
    movel %d1,%d2
PRIMETIME_166:          /* what is left */
    subl %d2,%d1
    movel %d1,%a1@(10)
PRIMETIME_16C:          /* write the VIA timer */
    moveal VIA,%a1
    lea %a1@(4096),%a1
    movew %d3,%d1
PRIMETIME_176:          /* (adjust for the time it took) */
    addl %d2,%a2@(8)
    lslw #4,%d2
    lea %a1@(512),%a2
    subb %a1@,%d3
    subw %d3,%d2
    jbls PRIMETIME_194
    moveb %d1,%a2@
    moveb %d2,%a1@
    lsrw #8,%d2
    moveb %d2,%a2@
    swap %d3
    movew %d3,%sr
    rts
PRIMETIME_194:          /* (too short: catch up) */
    addw %d2,%d3
    subb %d3,%d1
    negw %d2
    moveal TimeVars,%a2
    addw %a2@(6),%d2
    lsrw #4,%d2
    addl %d2,%a2@(12)
    movew %d1,%d3
    jbra PRIMETIME_176

/*
 INITTIMEMGR: allocate TimeVars, install the timer 2 interrupt handler (level 1
 dispatch, entry 5), set timer 2 to one-shot, measure the overhead of starting it.
*/
INITTIMEMGR:
    moveml %d0-%d5/%a0-%a4,%sp@-
    moveq #16,%d0
    .short  0xA71E	| 4080B0CC _NewPtr (flags 0x0700)
    movel %a0,TimeVars
    moveal %a0,%a2
    movew #24,%a2@(6)
    lea %pc@(PRIMETIME_112),%a1
    movel %a1,Lvl1DT_5
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal VIA,%a4
    lea %a4@(4096),%a1
    lea %a4@(2048),%a3
    lea %a4@(5632),%a4
    moveq #-96,%d1
    moveb %d1,%a1@(3072)
    moveq #-33,%d5
    andb %a4@,%d5
    moveq #63,%d0
    andb %d5,%d0
    moveb %d0,%a4@
    moveq #0,%d3
    movew %sr,%d3
    swap %d3
    moveb %d1,%a3@(512)
    moveb %d1,%a1@(512)
    moveb %a1@,%d0
    subb %a3@,%d0
    jbsr PRIMETIME_138
    moveb %a1@,%d1
    subb %a3@,%d1
    subb %d0,%d1
    subiw #-16,%d1
    moveb %d1,%a0@(4)
    moveb %d5,%a4@
    st %a1@(512)
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d5/%a0-%a4
    rts
    .short  0x0000, 0x0000, 0x0000	| 4080B13A

/*
 ONESECINT: one second interrupt (VIA CA2): Time + 1, alarm check (SPAlarm) when the
 alarm is enabled.
*/
CLOCK:
ONESECINT:
    moveb #1,%a1@(6656)
    addql #1,Time
    bclr #5,AlarmState
    tstb SPVolCtl
    jbpl CLOCK_28
    movel SPAlarm,%d0
    jbeq CLOCK_28
    cmpl Time,%d0
    jbhi CLOCK_28
    bclr #1,AlarmState
CLOCK_28:               /* return */
    rts

/*
 PRAMIO: read or write parameter RAM before the traps exist: the machine's clock/PRAM
 primitive (ProductInfo +52, entry +20) with d3 = count/address/direction, a3 = buffer.
*/
PRAMIO:
    moveml %d0-%d2/%a0-%a2,%sp@-
    moveal %a1,%a2
    addal %a1@(52),%a2
    movel %a2@(20),%d2
    jbeq PRAMIO_14
    addal %d2,%a2
    jsr %a2@
PRAMIO_14:              /* return */
    moveml %sp@+,%d0-%d2/%a0-%a2
    rts
    .short  0x0000	| 4080B184

/* _ReadXPRam(d0 = count/address, a0 = buffer): through the clock/PRAM primitive (+24). */
trap_ReadXPRam:
READXPRAM:
    moveml %d1-%d3/%a0-%a3,%sp@-
    movew #6112,%d1
    jbra WRITEXPRAM_8

/* _WriteXPRam: the same, writing. */
trap_WriteXPRam:
WRITEXPRAM:
    moveml %d1-%d3/%a0-%a3,%sp@-
    movew #2016,%d1
WRITEXPRAM_8:           /* machine has extended PRAM? (HWCfgFlags bit 6) */
    btst #6,HWCfgFlags
    jbeq WRITEXPRAM_28
    moveal 0xdd8,%a1
    addal %a1@(52),%a1
    movel %a1@(24),%d3
    jbeq WRITEXPRAM_22
    addal %d3,%a1
    jsr %a1@
WRITEXPRAM_22:          /* return */
    moveml %sp@+,%d1-%d3/%a0-%a3
    rts
WRITEXPRAM_28:          /* no: -87 (prWrErr...) */
    moveq #-87,%d0
    jbra WRITEXPRAM_22
    .fill   0xC0, 1, 0x00

/*
 VALIDATEPRAM: at start-up, check parameter RAM: if byte 0x10 is not 0xA8 (valid mark)
 initialise it (PRAMINIT); if XPRAM 0x0C does not hold 'NuMc' (extended PRAM
 valid), clear XPRAM and write the defaults from PRAMINITTBL.
*/
VALIDATEPRAM:
    movel %fp,%sp@-
    movel %d3,%sp@-
    lea %sp@(-256),%sp
    moveal %sp,%a3
    movel #2097152,%d3
    jbsr PRAMIO
    cmpib #0xa8,%sp@(16)
    jbeq VALIDATEPRAM_44
    biglea PRAMINIT, a3
    movel #-2146435056,%d3
    jbsr PRAMIO
    biglea PRAMINIT_10, a3
    movel #-2147221496,%d3
    jbsr PRAMIO
VALIDATEPRAM_44:        /* extended PRAM signature */
    lea %pc@(VALIDATEPRAM_8E),%a3
    movel %sp@(12),%d3
    cmpl %a3@,%d3
    jbeq VALIDATEPRAM_86
    movel #-2147221492,%d3
    jbsr PRAMIO
    moveal %sp,%a3
    moveq #55,%d3
VALIDATEPRAM_5E:        /* clear 256 bytes */
    clrl %a3@+
    dbf %d3,VALIDATEPRAM_5E
    biglea PRAMINITTBL, a2
    lea %sp@(86),%a3
    moveq #19,%d3
VALIDATEPRAM_74:        /* defaults (20 bytes at 86) */
    moveb %a2@+,%a3@+
    dbf %d3,VALIDATEPRAM_74
    moveal %sp,%a3
    movel #-2132803552,%d3
    jbsr PRAMIO
VALIDATEPRAM_86:        /* return */
    lea %sp@(256),%sp
    movel %sp@+,%d3
    rts
VALIDATEPRAM_8E:        /* the signature 'NuMc' */
    rts	| 4080B30A
    .byte   0x4D, 0x63	| 4080B30C
    .fill   0x92, 1, 0x00
