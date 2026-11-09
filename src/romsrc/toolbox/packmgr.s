/*
 toolbox/packmgr.s - Package Manager and date utilities
 From INITPACK (0x408261C0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* INITPACK: _InitPack. */
trap_InitPack:
PACKDISPATCHER:
INITPACK:
    subql #4,%sp
    movel #1346454347,%sp@-
    movew %sp@(12),%sp@-
    movew #-256,ROMMapInsert
    _GetResource
    movew %sp@(8),%d0
    jbsr PACK5_20
    movel %sp@+,%a0@
    moveal %sp@+,%a0
    addql #2,%sp
    jmp %a0@

/* INITALLPACKS: _InitAllPacks. */
trap_InitAllPacks:
INITALLPACKS:
    moveal %sp@+,%a0
    moveq #15,%d0
INITALLPACKS_4:         /* loop: move */
    movew %d0,%sp@-
    movel %a0,%sp@-
    lea %pc@(trap_InitPack),%a0
    dbf %d0,INITALLPACKS_4
    movel %a0,%sp@-
    clrw FPState
    lea %pc@(INITALLPACKS_20),%a0
    movel %a0,FPHaltVector
    rts
INITALLPACKS_20:        /* (data) */
    moveq #16,%d0	| 40826202
    _SysError	| 40826204

trap_FP68K:
PACK4:                  /* save registers */
    moveml %d0/%a0-%a1,%sp@-
    movel 0xac8,%d0
    jbeq PACK4_18
    moveal %d0,%a0
    movel %a0@,%sp@(8)
    jbeq PACK4_18
    moveml %sp@+,%d0/%a0
    rts
PACK4_18:               /* restore registers */
    moveml %sp@+,%d0/%a0
    addql #4,%sp
    jbra thunk_FUN_4082625c

trap_Elems68K:
PACK5:                  /* save registers */
    moveml %d0/%a0-%a1,%sp@-
    movel AppPacks_5,%d0
    jbeq PACK5_18
    moveal %d0,%a0
    movel %a0@,%sp@(8)
    jbeq PACK5_18
    moveml %sp@+,%d0/%a0
    rts
PACK5_18:               /* restore registers */
    moveml %sp@+,%d0/%a0
    addql #4,%sp
    jbra thunk_FUN_4082625c_408262B0

PACK5_20:               /* loop: lea */
    lea App2Packs,%a0
    subqw #8,%d0
    jbge PACK5_2E
    lea AppPacks,%a0
    addqw #8,%d0
PACK5_2E:               /* from here: lslw #2,%d0 */
    lslw #2,%d0
    addaw %d0,%a0
    rts

PACK5_34:               /* save registers */
    moveml %d0/%a0,%sp@-
    movel %sp@(8),%d0
    lea %pc@(trap_Pack1),%a0
    subl %a0,%d0
    lsrw #1,%d0
    jbsr PACK5_20
    tstl %a0@
    jbeq PACK5_6C
    moveal %a0@,%a0
    tstl %a0@
    jbne PACK5_5E
    movel %a0,%sp@-
    movew #-1,ROMMapInsert
    _LoadResource
    tstl %a0@
    jbeq PACK5_6C
PACK5_5E:               /* set up and call _StripAddress */
    movel %a0@,%d0
    _StripAddress
    movel %d0,%sp@(8)
    moveml %sp@+,%d0/%a0
    rts
PACK5_6C:               /* set %d0 */
    movel %sp@(8),%d0
    lea %pc@(trap_Pack1),%a0
    subl %a0,%d0
    lsrw #1,%d0
    addiw #17,%d0
    _SysError

trap_Pack0:
PACK0:                  /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack1:
PACK1:                  /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack2:
PACK2:                  /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack3:
PACK3:                  /* call PACK5_34 */
    jbsr PACK5_34

thunk_FUN_4082625c:     /* call PACK5_34 */
    jbsr PACK5_34

thunk_FUN_4082625c_408262B0:  /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack6:
PACK6:                  /* call PACK5_34 */
    jbsr PACK5_34

trap_DECSTR68K:
PACK7:                  /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack8:
PACK8:                  /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack9:
PACK9:                  /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack10:
PACK10:                 /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack11:
PACK11:                 /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack12:
PACK12:                 /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack13:
PACK13:                 /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack14:
PACK14:                 /* call PACK5_34 */
    jbsr PACK5_34

trap_Pack15:
PACK15:                 /* call PACK5_34 */
    jbsr PACK5_34

/* PACKMGREND: end of the Package Manager. */
PACKMGREND:
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408262C6

/* SECS2DATE: _Secs2Date. */
trap_Secs2Date:
SEXYDATE:
SECS2DATE:
    moveml %d0-%d4/%a0,%sp@-
    moveq #0,%d1
    lsrl #1,%d0
    roxrl #1,%d1
    divuw #-22336,%d0
    swap %d0
    movew %d0,%d1
    roll #1,%d1
    clrw %d0
    swap %d0
    movel %d0,%d2
    asll #2,%d2
    divuw #1461,%d2
    addiw #1904,%d2
    movew %d2,%a0@+
    moveq #59,%d3
    andiw #3,%d2
    jbne SEXYDATE_30
    addqw #1,%d3
SEXYDATE_30:            /* clear %d2 */
    clrw %d2
    swap %d2
    lsrw #2,%d2
    moveq #1,%d4
    cmpw %d3,%d2
    jblt SEXYDATE_40
    addqw #2,%d4
    subw %d3,%d2
SEXYDATE_40:            /* from here: lsll #7,%d2 */
    lsll #7,%d2
    moveq #71,%d3
    addl %d3,%d2
    divuw #3919,%d2
    addw %d4,%d2
    swap %d2
    lsrw #7,%d2
    addqw #1,%d2
    movel %d2,%a0@+
    divuw #3600,%d1
    movew %d1,%a0@+
    clrw %d1
    swap %d1
    divuw #60,%d1
    swap %d1
    movel %d1,%a0@+
    addqw #5,%d0
    divuw #7,%d0
    swap %d0
    addqw #1,%d0
    movew %d0,%a0@
    moveml %sp@+,%d0-%d4/%a0
    rts

/* DATE2SECS: _Date2Secs. */
trap_Date2Secs:
DATE2SECS:
    moveml %d1-%d4,%sp@-
    moveq #0,%d0
    addql #8,%a0
    movel %a0@,%d1
    movew %d1,%d0
    swap %d1
    movew %a0@-,%d2
    moveq #60,%d3
    muluw %d3,%d2
    addw %d1,%d2
    muluw %d3,%d2
    addl %d2,%d0
    movew %a0@-,%d1
    subqw #1,%d1
    movew %a0@-,%d2
    movew %a0@-,%d3
    movew %d3,%d4
    subiw #1904,%d3
    muluw #1461,%d3
    addql #3,%d3
    lsrl #2,%d3
    addw %d3,%d1
    subqw #1,%d2
    cmpiw #1,%d2
    jble DATE2SECS_48
    subqw #2,%d2
    moveq #59,%d3
    andiw #3,%d4
    jbne DATE2SECS_46
    addqw #1,%d3
DATE2SECS_46:           /* from here: addw %d3,%d1 */
    addw %d3,%d1
DATE2SECS_48:           /* from here: muluw #3917,%d2 */
    muluw #3917,%d2
    addiw #52,%d2
    lsrw #7,%d2
    addw %d2,%d1
    muluw #-22336,%d1
    addl %d1,%d1
    addl %d1,%d0
    moveml %sp@+,%d1-%d4
    rts
    .short  0x0000, 0x0000, 0x0000	| 408263AA
