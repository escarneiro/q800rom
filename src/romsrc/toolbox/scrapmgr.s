/*
 toolbox/scrapmgr.s - Scrap Manager
 From SCRAPMGR (0x40825D50). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* INFOSCRAP: _InfoScrap. */
trap_InfoScrap:
SCRAPMGR:
INFOSCRAP:
    tstw ScrapState
    jbge SCRAPMGR_C
    subqw #4,%sp
    _ZeroScrap
    addqw #4,%sp
SCRAPMGR_C:             /* set %a0 */
    moveal %sp@+,%a0
    lea ScrapSize,%a1
    movel %a1,%sp@
    jmp %a0@

SCRAPMGR_16:            /* loop: movea */
    moveal %sp@+,%a1
    linkw %fp,#-88
    moveml %d2-%d7/%a2-%a4,%sp@-
    movel %a1,%sp@-
SCRAPMGR_22:            /* loop: movem */
    moveml ScrapSize,%d4-%d6/%a2
    lea ScrapHandle,%a4
    lea %fp@(-80),%a0
    moveal %a0,%a3
    movel %a2,%a0@(18)
    movew BootDrive,%a0@(22)
    clrw %a0@(26)
    clrl %a0@(28)
    tstw %d6
    jbne UNLOADSCRAP_32

SCRAPMGR_48:            /* _Open (loop) */
    _Open
    jbeq UNLOADSCRAP_34
    cmpiw #-49,%d0
    jbeq UNLOADSCRAP_32
    cmpiw #-43,%d0
    jbne UNLOADSCRAP_34
    _Create
    jbne UNLOADSCRAP_34
    _GetFileInfo
    movel #1129072976,%a0@(32)
    movel #1296122707,%a0@(36)
    bset #4,%a0@(40)
    _SetFileInfo
    jbne UNLOADSCRAP_34
    jbra SCRAPMGR_48

/* UNLOADSCRAP: _UnloadScrap: write the scrap to the Clipboard file. */
trap_UnlodeScrap:
UNLOADSCRAP:
    jbsr SCRAPMGR_16
    jbne UNLOADSCRAP_1E
    tstw %d6
    jble UNLOADSCRAP_1C
    jbsr SCRAPMGR_48
    jbne UNLOADSCRAP_1E
    movel %d4,%d0
    jbsr LOADSCRAP_1C
    _Write
    jbne UNLOADSCRAP_1E
    moveal %d5,%a0
    _DisposHandle
    clrl %a4@+
    clrl %a4@+
UNLOADSCRAP_1C:         /* loop: moveq */
    moveq #0,%d0
UNLOADSCRAP_1E:         /* loop: ext */
    extl %d0
    movel %d0,%fp@(8)
    moveq #0,%d0
UNLOADSCRAP_26:         /* restore registers, return */
    moveml %sp@+,%d2-%d7/%a2-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw %d0,%sp
    jmp %a0@
UNLOADSCRAP_32:         /* loop: moveq */
    moveq #0,%d0
UNLOADSCRAP_34:         /* return */
    rts

/* LOADSCRAP: _LoadScrap. */
trap_LodeScrap:
LOADSCRAP:
    jbsr SCRAPMGR_16
    jbne UNLOADSCRAP_1E
    tstw %d6
    jbne UNLOADSCRAP_1C
    movel %d4,%d0
    .short  0xA122	| 40825E0C _NewHandle (flags 0x0100)
    jbne UNLOADSCRAP_1E
    movel %a0,%a4@+
    addql #1,%a4@+
    movel %d4,%d0
    jbsr LOADSCRAP_1E
    _Read
    jbra UNLOADSCRAP_1E

LOADSCRAP_1C:           /* loop: movea */
    moveal %d5,%a0
LOADSCRAP_1E:           /* set %a3@(32) */
    movel %a0@,%a3@(32)
    movel %d0,%a3@(36)
    movew #1,%a3@(44)
    clrl %a3@(46)
    moveal %a3,%a0
    rts

/* ZEROSCRAP: _ZeroScrap. */
trap_ZeroScrap:
ZEROSCRAP:
    jbsr SCRAPMGR_16
    jbne UNLOADSCRAP_1E
    movel %d0,ScrapSize
    addqw #8,%a4@(4)
    jbpl ZEROSCRAP_14
    negw %a4@(4)
ZEROSCRAP_14:           /* test %d6 */
    tstw %d6
    jbeq ZEROSCRAP_28
    jbgt ZEROSCRAP_1E
    .short  0xA122	| 40825E4E _NewHandle (flags 0x0100)
    jbra ZEROSCRAP_22
ZEROSCRAP_1E:           /* set up and call _SetHandleSize */
    moveal %d5,%a0
    _SetHandleSize
ZEROSCRAP_22:           /* set %a4@+ */
    movel %a0,%a4@+
    movew %a4@+,%a4@
    jbra UNLOADSCRAP_1E
ZEROSCRAP_28:           /* set up and call _SetEOF */
    clrl %a0@(28)
    _SetEOF
    jbra UNLOADSCRAP_1E

ZEROSCRAP_30:           /* loop: tst */
    tstw %d6
    jbeq ZEROSCRAP_3E
    moveal %d5,%a2
    moveal %a2@,%a0
    addal %d3,%a0
    _BlockMove
    jbra UNLOADSCRAP_32
ZEROSCRAP_3E:           /* call LOADSCRAP_1C */
    jbsr LOADSCRAP_1C
    movel %d3,%a0@(46)
    movel %a1,%a0@(32)
    _Read
    rts

/* GETSCRAP: _GetScrap. */
trap_GetScrap:
GETSCRAP:
    jbsr SCRAPMGR_16
    jbne GETSCRAP_52
    bsrw GETSCRAP_5E
    jbmi GETSCRAP_52
    moveq #0,%d3
GETSCRAP_E:             /* loop: cmp */
    cmpl %d4,%d3
    jbge GETSCRAP_2E
    moveq #8,%d0
    lea %fp@(-88),%a1
    jbsr ZEROSCRAP_30
    jbne GETSCRAP_52
    addql #8,%d3
    movel %a1@+,%d7
    cmpl %fp@(12),%d7
    jbeq GETSCRAP_32
    addl %a1@+,%d3
    addql #1,%d3
    bclr %d0,%d3
    jbra GETSCRAP_E
GETSCRAP_2E:            /* result -102 */
    moveq #-102,%d0
    jbra GETSCRAP_54
GETSCRAP_32:            /* set %a2 */
    moveal %fp@(8),%a2
    movel %d3,%a2@
    movel %a1@,%d0
    movel %d0,%fp@(20)
    movel %fp@(16),%d1
    jbeq GETSCRAP_58
    moveal %d1,%a0
    _SetHandleSize
    jbne GETSCRAP_52
    movel %a1@,%d0
    moveal %a0@,%a1
    jbsr ZEROSCRAP_30
    jbeq GETSCRAP_58

GETSCRAP_52:            /* loop: ext */
    extl %d0
GETSCRAP_54:            /* set %fp@(20) */
    movel %d0,%fp@(20)
GETSCRAP_58:            /* result 12 */
    moveq #12,%d0
    jbra UNLOADSCRAP_26

GETSCRAP_5E:            /* set up and call _ZeroScrap (loop) */
    tstw %d6
    jbge GETSCRAP_6E
    subqw #4,%sp
    _ZeroScrap
    movel %sp@+,%d0
    jbmi GETSCRAP_52
    jbsr SCRAPMGR_22
GETSCRAP_6E:            /* return */
    rts

/* PUTSCRAP: _PutScrap. */
trap_PutScrap:
PUTSCRAP:
    jbsr SCRAPMGR_16
    jbsr GETSCRAP_5E
    jbmi GETSCRAP_52
    jbsr LOADSCRAP_1C
    moveq #8,%d0
    lea %fp@(12),%a0
    jbsr PUTSCRAP_28
    moveal %fp@(8),%a0
    movel %fp@(16),%d0
    moveq #-2,%d1
    addql #1,%d0
    andl %d1,%d0
    jbsr PUTSCRAP_28
    movel %d4,%a4@-
    jbra GETSCRAP_52

PUTSCRAP_28:            /* set %a3@(46) */
    movel %d4,%a3@(46)
    addl %d0,%d4
    tstw %d6
    jbeq PUTSCRAP_38
    moveal %d5,%a1
    _PtrAndHand
    rts
PUTSCRAP_38:            /* set up and call _Write */
    movel %a0,%a3@(32)
    movel %d0,%a3@(36)
    moveal %a3,%a0
    _Write
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40825F36
