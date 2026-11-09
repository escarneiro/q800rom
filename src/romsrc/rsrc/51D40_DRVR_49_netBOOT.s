/* ROM resource 'DRVR' 49 ".netBOOT": map entry at 0x40851D40, data at 0x40851D70, 1984 bytes

 The .netBOOT driver ('DRVR' 49): network booting. It installs itself as a disk drive
 (AddDrive) so the start-up code can boot from it, keeps its settings in extended PRAM,
 and loads the boot protocol driver for the network (.ATBOOT, 'DRVR' 50, for AppleTalk)
 by name, to which it hands the reads of the boot blocks and image. Comments inferred
 from the code (traps used and strings), not verified in depth.
*/

rsrc_DRVR_49__netBOOT_entry:  /* map entry */
    .long   0x18000000, 0x00000000	| 40851D40
    .long   rsrc_PACK_5_entry_408EDC70-rom_start	| 40851D48
    .long   rsrc_DRVR_49__netBOOT-rom_start	| 40851D4C
    .ascii  "DRVR"	| 40851D50
    .byte   0x00, 0x31, 0x58, 0x08	| 40851D54
    .ascii  ".netBOOT\000\000\000\000"
    .long   0xC0A00000, 0x000007CC, 0x0000026C	| 40851D64

/* subroutine (0 instructions) (mechanical summary) */
rsrc_DRVR_49__netBOOT:
    .byte   0x45, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40851D70
rsrc_DRVR_49__netBOOT_8:  /* (data) */
    .short  rsrc_DRVR_49__netBOOT_open-rsrc_DRVR_49__netBOOT	| 40851D78
    .short  rsrc_DRVR_49__netBOOT_prime-rsrc_DRVR_49__netBOOT	| 40851D7A
    .short  rsrc_DRVR_49__netBOOT_ctl-rsrc_DRVR_49__netBOOT	| 40851D7C
    .short  rsrc_DRVR_49__netBOOT_status-rsrc_DRVR_49__netBOOT	| 40851D7E
    .short  rsrc_DRVR_49__netBOOT_close-rsrc_DRVR_49__netBOOT	| 40851D80
    .byte   0x08	| 40851D82
    .ascii  ".netBOOT\000"
    .short  0x0200	| 40851D8C

/*
 Open: allocate the driver's variables, find and install the boot protocol driver
 (GetNamedResource 'DRVR', DrvrInstall), add the network drive.
*/
rsrc_DRVR_49__netBOOT_open:
    movel %a1,%sp@-
    movel %a1@(20),%d1
    jbne rsrc_DRVR_49__netBOOT_open_5C
    moveal %a0,%a2
    movel #222,%d0
    .short  0xA71E	| 40851D9E _NewPtr (flags 0x0700)
    jbne rsrc_DRVR_49__netBOOT_open_64
    movel %a0,%d1
    moveal %sp@,%a1
    movel %a0,%a1@(20)
    moveq #0,%d0
    movew %a2@(24),%d0
    movew %d0,%sp@-
    movel %a0,%sp@-
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_534)
    addql #8,%sp
    subqw #4,%sp
    movel #1146246738,%sp@-
    pea %pc@(rsrc_DRVR_49__netBOOT_94)
    _GetNamedResource
    movel %sp@+,%d0
    jbeq rsrc_DRVR_49__netBOOT_open_5C
    moveal %d0,%a1
    movel %a3,%sp@-
    moveal %a1@,%a3
    movew %sp@(4),%d0
    moveal %a1,%a3
    subqw #1,%d0
    .short  0xA53D	| 40851DDC _DrvrInstall (flags 0x0500)
    jbne rsrc_DRVR_49__netBOOT_open_5C
    _HLock
    moveal %a0@,%a0
    movel %a3,%a0@+
    movew %a3@,%a0@+
    moveal %sp@+,%a3
rsrc_DRVR_49__netBOOT_open_5C:  /* add 2 to %sp */
    addqw #2,%sp
    moveq #0,%d0
    addql #4,%sp
    rts
rsrc_DRVR_49__netBOOT_open_64:  /* set %a1 */
    moveal %sp@+,%a1
    movel %a1@(20),%d1
    jbeq rsrc_DRVR_49__netBOOT_open_70
    moveal %d1,%a0
    _DisposPtr
rsrc_DRVR_49__netBOOT_open_70:  /* set %d0 */
    movew #-23,%d0
    rts

/* subroutine (0 instructions) (mechanical summary) */
rsrc_DRVR_49__netBOOT_94:
    .byte   0x07	| 40851E04
    .byte   7	/* 40851E05 Pascal string length */
    .ascii  ".atBoot"	| 40851E06
    .byte   0x00	| 40851E0D

/* Close: close the protocol driver, remove the drive, free the variables. */
rsrc_DRVR_49__netBOOT_close:
    movel %a1@(20),%d1
    jbeq rsrc_DRVR_49__netBOOT_status
    movel %a1,%sp@-
    movew %a1@(24),%d0
    movel %d0,%sp@-
    movel %d1,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_5D6)
    addql #8,%sp
    moveal %sp@+,%a1
    clrl %a1@(20)
    tstl %d0
    jbeq rsrc_DRVR_49__netBOOT_status
    moveq #-24,%d0

/* Status: nothing (no status calls). */
rsrc_DRVR_49__netBOOT_status:
    rts

/* Control: nothing (no control calls). */
rsrc_DRVR_49__netBOOT_ctl:
    movew #-65,%d0
    jbra rsrc_DRVR_49__netBOOT_prime_46

/* Prime (read): blocks of the boot image, through the protocol driver. */
rsrc_DRVR_49__netBOOT_prime:
    btst #3,KeyMap_7
    beqw rsrc_DRVR_49__netBOOT_prime_12
    movew #-65,%d0
    braw rsrc_DRVR_49__netBOOT_prime_46
rsrc_DRVR_49__netBOOT_prime_12:  /* set %d1 */
    movel %a1@(20),%d1
    jbeq rsrc_DRVR_49__netBOOT_prime_46
    moveml %a0-%a1,%sp@-
    moveal SysZone,%a1
    movel %a1,TheZone
    movel %a1@(16),%sp@-
    lea %pc@(rsrc_DRVR_49__netBOOT_2E0),%a2
    movel %a2,%a1@(16)
    movel %a0,%sp@-
    movel %d1,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_63E)
    addql #8,%sp
    moveal SysZone,%a0
    movel %sp@+,%a0@(16)
    moveml %sp@+,%a0-%a1
rsrc_DRVR_49__netBOOT_prime_46:  /* set %a0@(16) */
    movew %d0,%a0@(16)
    moveal JIODone,%a3
    jmp %a3@

/* Read and update the network boot settings in extended PRAM. */
rsrc_DRVR_49__netBOOT_118:
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
    jbeq rsrc_DRVR_49__netBOOT_118_E
    jbsr rsrc_DRVR_49__netBOOT_13E
    jbra rsrc_DRVR_49__netBOOT_118_10
rsrc_DRVR_49__netBOOT_118_E:  /* call rsrc_DRVR_49__netBOOT_15E */
    jbsr rsrc_DRVR_49__netBOOT_15E
rsrc_DRVR_49__netBOOT_118_10:  /* return */
    rts
rsrc_DRVR_49__netBOOT_12A:  /* from here: orib #4,%d4 */
    orib #4,%d4	| 40851E9A
    .short  0x0003, 0x00AB	| 40851E9E orib #-85,%d3
    .short  0x0001, 0x00BC	| 40851EA2 orib #-68,%d1
    orib #32,%a0@-	| 40851EA6
    .short  0x0020, 0x008B	| 40851EAA orib #-117,%a0@-

/* ReadXPRam of the boot settings. */
rsrc_DRVR_49__netBOOT_13E:
    moveq #0,%d0
    btst #14,HWCfgFlags
    jbeq rsrc_DRVR_49__netBOOT_13E_1E
    lea %pc@(rsrc_DRVR_49__netBOOT_12A),%a1
    moveq #4,%d1
rsrc_DRVR_49__netBOOT_13E_10:  /* set up and call _ReadXPRam (loop) */
    movel %a1@+,%d0
    movel %d0,%d2
    _ReadXPRam
    swap %d2
    addaw %d2,%a0
    dbf %d1,rsrc_DRVR_49__netBOOT_13E_10
rsrc_DRVR_49__netBOOT_13E_1E:  /* return */
    rts

/* WriteXPRam of the boot settings. */
rsrc_DRVR_49__netBOOT_15E:
    moveq #0,%d0
    btst #14,HWCfgFlags
    jbeq rsrc_DRVR_49__netBOOT_15E_1E
    lea %pc@(rsrc_DRVR_49__netBOOT_12A),%a1
    moveq #4,%d1
rsrc_DRVR_49__netBOOT_15E_10:  /* set up and call _WriteXPRam (loop) */
    movel %a1@+,%d0
    movel %d0,%d2
    _WriteXPRam
    swap %d2
    addaw %d2,%a0
    dbf %d1,rsrc_DRVR_49__netBOOT_15E_10
rsrc_DRVR_49__netBOOT_15E_1E:  /* return */
    rts

/* AddDrive: a drive queue element for the network volume. */
rsrc_DRVR_49__netBOOT_17E:
    linkw %fp,#-50
    lea DrvQHdr,%a0
    moveq #4,%d0
rsrc_DRVR_49__netBOOT_17E_A:  /* loop: movea */
    moveal %a0@(2),%a1
rsrc_DRVR_49__netBOOT_17E_E:  /* loop: cmp */
    cmpw %a1@(6),%d0
    jbeq rsrc_DRVR_49__netBOOT_17E_1E
    cmpal %a0@(6),%a1
    jbeq rsrc_DRVR_49__netBOOT_17E_22
    moveal %a1@,%a1
    jbra rsrc_DRVR_49__netBOOT_17E_E
rsrc_DRVR_49__netBOOT_17E_1E:  /* add 1 to %d0 */
    addqw #1,%d0
    jbra rsrc_DRVR_49__netBOOT_17E_A
rsrc_DRVR_49__netBOOT_17E_22:  /* set %fp@(18) */
    movew %d0,%fp@(18)
    moveq #26,%d0
    .short  0xA51E	| 40851F16 _NewPtr (flags 0x0500)
    jbeq rsrc_DRVR_49__netBOOT_17E_32
    movew %d0,%fp@(18)
    jbra rsrc_DRVR_49__netBOOT_17E_62
rsrc_DRVR_49__netBOOT_17E_32:  /* set %a0@+ */
    movel #524288,%a0@+
    movew #1,%a0@(4)
    movew #1,%a0@(10)
    movew %fp@(14),%a0@(14)
    movew %fp@(16),%a0@(12)
    movel %fp@(8),%a0@(16)
    movew %fp@(18),%d0
    swap %d0
    movew %fp@(12),%d0
    _AddDrive
rsrc_DRVR_49__netBOOT_17E_62:  /* return */
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(10),%sp
    jmp %a0@

/* subroutine (93 instructions): traps Control, DisposPtr, SetApplBase; low memory DrvQHdr, SysZone, TheZone, DefVCBPtr, WDCBsPtr (mechanical summary) */
rsrc_DRVR_49__netBOOT_1EA:
    moveal %sp@(4),%a0
    movel %sp@(8),%d0
    jble rsrc_DRVR_49__netBOOT_1EA_14
    subql #1,%d0
    moveq #0,%d1
rsrc_DRVR_49__netBOOT_1EA_E:  /* loop: move */
    moveb %d1,%a0@+
    dbf %d0,rsrc_DRVR_49__netBOOT_1EA_E
rsrc_DRVR_49__netBOOT_1EA_14:  /* return */
    rts

rsrc_DRVR_49__netBOOT_200:  /* save registers */
    moveml %d1-%d2/%a0-%a4,%sp@-
    cmpib #15,%a0@(7)
    jbne rsrc_DRVR_49__netBOOT_200_DA
    movew %a0@(22),%d0
    cmpiw #4,%d0
    jbne rsrc_DRVR_49__netBOOT_200_DA
    lea DrvQHdr,%a2
    moveal %a2@(2),%a1
rsrc_DRVR_49__netBOOT_200_22:  /* loop: cmp */
    cmpw %a1@(6),%d0
    jbeq rsrc_DRVR_49__netBOOT_200_34
    cmpal %a2@(6),%a1
    jbeq rsrc_DRVR_49__netBOOT_200_D8
    moveal %a1@,%a1
    jbra rsrc_DRVR_49__netBOOT_200_22
rsrc_DRVR_49__netBOOT_200_34:  /* test #1,%a1@(10) */
    cmpiw #1,%a1@(10)
    jbne rsrc_DRVR_49__netBOOT_200_D8
    movel %a1@(16),%d0
    moveal %a1,%a4
    jbeq rsrc_DRVR_49__netBOOT_200_D8
    moveal %d0,%a2
    moveal SysZone,%a0
    movel %a0,TheZone
    movel %a0@(16),%sp@-
    lea %pc@(rsrc_DRVR_49__netBOOT_2E0),%a1
    movel %a1,%a0@(16)
    subaw #50,%sp
    moveal %sp,%a0
    movew #3,%a0@(26)
    movew %a2@(4),%a0@(24)
    _Control
    jbeq rsrc_DRVR_49__netBOOT_200_84
    lea %sp@(50),%sp
    moveal SysZone,%a0
    movel %sp@+,%a0@(16)
    braw rsrc_DRVR_49__netBOOT_200_DA
rsrc_DRVR_49__netBOOT_200_84:  /* set %a1 */
    moveal %a0@(28),%a1
    movel %a1,DefVCBPtr
    moveal WDCBsPtr,%a3
    movel %a1,%a3@(2)
    moveq #2,%d0
    movel %d0,%a3@(6)
    clrl %a3@(10)
    clrl %a3@(14)
    moveal %a0@(32),%a1
    movew %a1@(10),%a4@(10)
    movew %a1@(8),%a4@(8)
    moveb %a1@(-3),%a4@(-3)
    subqw #4,%a1
    moveal %a1,%a0
    _DisposPtr
    clrl %a4@(16)
    movel %a2@(8),ToExtFS
    lea %sp@(50),%sp
    moveal SysZone,%a0
    movel %sp@+,%a0@(16)
    moveq #0,%d0
    jbra rsrc_DRVR_49__netBOOT_200_DA
rsrc_DRVR_49__netBOOT_200_D8:  /* set %d0 */
    moveq #-1,%d0
rsrc_DRVR_49__netBOOT_200_DA:  /* restore registers, return */
    moveml %sp@+,%d1-%d2/%a0-%a4
    rts

rsrc_DRVR_49__netBOOT_2E0:  /* set %d0 */
    movel %sp@(4),%d0
    movel %a2,%sp@-
    moveal SysZone,%a1
    moveal %a1@,%a0
    moveal %a0,%a2
    addil #16384,%d0
    lea %a0@(0x0,%d0:l),%a0
    movel %d0,%d1
    moveal BufPtr,%a1
    subaw #8192,%a1
    cmpal %a1,%a0
    jbls rsrc_DRVR_49__netBOOT_2E0_2C
    movel %a1,%d1
    subl %a2,%d1
    moveal %a1,%a0
rsrc_DRVR_49__netBOOT_2E0_2C:  /* _SetApplBase */
    _SetApplBase
    moveal SysZone,%a1
    movel %a1,TheZone
    movel %a1,ApplZone
    movel %a1@,HeapEnd
    moveal %sp@+,%a2
    moveal %sp@+,%a0
    movel %sp@+,%d0
    movel %d1,%sp@
    jmp %a0@

/* subroutine (12 instructions): traps GetNamedResource, Open (mechanical summary) */
rsrc_DRVR_49__netBOOT_328:
    moveal %sp@(4),%a0
    clrl %sp@-
    movel #1146246738,%sp@-
    movel %a0@(18),%sp@-
    _GetNamedResource
    clrw %d0
    tstl %sp@+
    jbeq rsrc_DRVR_49__netBOOT_328_22
    moveal %sp@(4),%a0
    _Open
    movew %a0@(24),%d0
rsrc_DRVR_49__netBOOT_328_22:  /* return */
    rts

/* subroutine (12 instructions): calls rsrc_DRVR_49__netBOOT_118 (mechanical summary) */
rsrc_DRVR_49__netBOOT_34C:
    linkw %fp,#0
    movel %a3,%sp@-
    moveal %fp@(8),%a3
    movew %fp@(14),%d0
    extl %d0
    movel %d0,%sp@-
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_118)
    moveq #0,%d0
    moveal %fp@(-4),%a3
    unlk %fp
    rts

/* subroutine (20 instructions): calls rsrc_DRVR_49__netBOOT_726, rsrc_DRVR_49__netBOOT_34C; low memory MemErr (mechanical summary) */
rsrc_DRVR_49__netBOOT_36E:
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    subql #4,%sp
    moveq #72,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_726)
    movel %sp@+,%a3@
    jbne rsrc_DRVR_49__netBOOT_36E_1E
    subql #2,%sp
    movew MemErr,%sp@
    movew %sp@+,%d0
    jbra rsrc_DRVR_49__netBOOT_36E_2C
rsrc_DRVR_49__netBOOT_36E_1E:  /* set %d0 */
    moveq #1,%d0
    movel %d0,%sp@-
    movel %a3@,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_34C)
    moveq #0,%d0
    addql #8,%sp
rsrc_DRVR_49__netBOOT_36E_2C:  /* set %a3 */
    moveal %sp@+,%a3
    rts

/* subroutine (34 instructions): calls rsrc_DRVR_49__netBOOT_1EA, rsrc_DRVR_49__netBOOT_796, rsrc_DRVR_49__netBOOT_7A2 (mechanical summary) */
rsrc_DRVR_49__netBOOT_39E:
    linkw %fp,#-56
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(16),%a4
    moveal %fp@(12),%a3
    moveq #56,%d0
    movel %d0,%sp@-
    pea %fp@(-56)
    jsr %pc@(rsrc_DRVR_49__netBOOT_1EA)
    movew #40,%fp@(-16)
    movew #1,%fp@(-14)
    moveq #0,%d0
    moveb %fp@(11),%d0
    movew %d0,%fp@(-12)
    moveb #1,%fp@(-8)
    subql #2,%sp
    pea %fp@(-56)
    jsr %pc@(rsrc_DRVR_49__netBOOT_796)
    movew %sp@+,%d7
    jbeq rsrc_DRVR_49__netBOOT_39E_4A
    movew %d7,%d0
    jbra rsrc_DRVR_49__netBOOT_39E_6E
rsrc_DRVR_49__netBOOT_39E_4A:  /* set %fp@(-56) */
    movel %fp@(24),%fp@(-56)
    subql #2,%sp
    pea %fp@(-56)
    jsr %pc@(rsrc_DRVR_49__netBOOT_7A2)
    movew %sp@+,%d7
    moveb %fp@(-7),%a3@
    moveb %fp@(-6),%a4@
    moveal %fp@(20),%a0
    moveb %fp@(-5),%a0@
    movew %d7,%d0
rsrc_DRVR_49__netBOOT_39E_6E:  /* restore registers, return */
    moveml %fp@(-68),%d7/%a3-%a4
    unlk %fp
    rts

/* Start the boot protocol (.ATBOOT): open it, pass it the settings, get the boot image. */
rsrc_DRVR_49__netBOOT_416:
    linkw %fp,#-122
    moveml %d7/%a3-%a4,%sp@-
    lea %fp@(-34),%a4
    moveal %fp@(8),%a3
    moveq #0,%d0
    movel %d0,%fp@(-122)
    pea %fp@(-122)
    jsr %pc@(rsrc_DRVR_49__netBOOT_36E)
    moveal %fp@(-122),%a0
    moveq #1,%d0
    cmpb %a0@(1),%d0
    addql #4,%sp
    jbne rsrc_DRVR_49__netBOOT_416_54
    moveq #80,%d0
    movel %d0,%sp@-
    pea %fp@(-114)
    jsr %pc@(rsrc_DRVR_49__netBOOT_1EA)
    lea %pc@(PSTR_ATBOOT),%a0
    movel %a0,%fp@(-96)
    pea %fp@(-114)
    jsr %pc@(rsrc_DRVR_49__netBOOT_328)
    movew %d0,%fp@(-90)
    lea %sp@(12),%sp
    jbra rsrc_DRVR_49__netBOOT_416_DA
rsrc_DRVR_49__netBOOT_416_54:  /* subtract 4 to %sp */
    subql #4,%sp
    movew #-24466,%sp@-
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_746)
    subql #4,%sp
    movew #-22369,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_73C)
    movel %sp@+,%d0
    cmpl %sp@+,%d0
    jbeq rsrc_DRVR_49__netBOOT_416_D6
    movel %a4,%sp@-
    pea %fp@(-115)
    pea %fp@(-116)
    pea %fp@(-117)
    moveal %fp@(-122),%a0
    moveb %a0@(1),%d0
    extw %d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_39E)
    movew %d0,%d7
    lea %sp@(20),%sp
    jbne rsrc_DRVR_49__netBOOT_416_FA
    moveq #36,%d0
    movel %d0,%sp@-
    pea %fp@(-114)
    jsr %pc@(rsrc_DRVR_49__netBOOT_1EA)
    moveb %fp@(-117),%fp@(-80)
    moveb %fp@(-116),%fp@(-79)
    movel %a4,%fp@(-96)
    subql #2,%sp
    pea %fp@(-114)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_7AE)
    movew %sp@+,%d7
    moveb %fp@(-117),%a3@(1)
    moveb %fp@(-116),%a3@(2)
    addql #8,%sp
    jbra rsrc_DRVR_49__netBOOT_416_DA
rsrc_DRVR_49__netBOOT_416_D6:  /* set %d7 */
    moveq #-10,%d7
    jbra rsrc_DRVR_49__netBOOT_416_FA
rsrc_DRVR_49__netBOOT_416_DA:  /* test %d7 */
    tstw %d7
    jbne rsrc_DRVR_49__netBOOT_416_E4
    tstw %fp@(-90)
    jbne rsrc_DRVR_49__netBOOT_416_EC
rsrc_DRVR_49__netBOOT_416_E4:  /* test %d7 */
    tstw %d7
    jbne rsrc_DRVR_49__netBOOT_416_FA
    moveq #-23,%d7
    jbra rsrc_DRVR_49__netBOOT_416_FA
rsrc_DRVR_49__netBOOT_416_EC:  /* set %a0 */
    moveal %fp@(-122),%a0
    moveb %a0@(1),%a3@
    movew %fp@(-90),%a3@(4)
rsrc_DRVR_49__netBOOT_416_FA:  /* test %fp@(-122) */
    tstl %fp@(-122)
    jbeq rsrc_DRVR_49__netBOOT_416_108
    movel %fp@(-122),%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_732)
rsrc_DRVR_49__netBOOT_416_108:  /* set %d0 */
    movew %d7,%d0
    moveml %fp@(-134),%d7/%a3-%a4
    unlk %fp
    rts
PSTR_ATBOOT:            /* (4085229A Pascal string length) */
    .byte   7	/* 4085229A Pascal string length */
    .ascii  ".ATBOOT"	| 4085229B
    .byte   0x00, 0x00	| 408522A2

/* subroutine (33 instructions): calls rsrc_DRVR_49__netBOOT_36E, rsrc_DRVR_49__netBOOT_732, rsrc_DRVR_49__netBOOT_17E (mechanical summary) */
rsrc_DRVR_49__netBOOT_534:
    linkw %fp,#-4
    moveml %d6-%d7/%a3,%sp@-
    moveal %fp@(12),%a3
    pea %fp@(-4)
    jsr %pc@(rsrc_DRVR_49__netBOOT_36E)
    tstw %d0
    addql #4,%sp
    jbne rsrc_DRVR_49__netBOOT_554
    tstl %fp@(-4)
    jbne rsrc_DRVR_49__netBOOT_558
rsrc_DRVR_49__netBOOT_554:  /* result -23 */
    moveq #-23,%d0
    jbra rsrc_DRVR_49__netBOOT_58E
rsrc_DRVR_49__netBOOT_558:  /* set %a0 */
    moveal %fp@(-4),%a0
    moveb %a0@(3),%d7
    movel %fp@(-4),%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_732)
    extw %d7
    extl %d7
    movel #128,%d0
    andl %d7,%d0
    jbne rsrc_DRVR_49__netBOOT_57A
    moveq #-23,%d0
    jbra rsrc_DRVR_49__netBOOT_58E
rsrc_DRVR_49__netBOOT_57A:  /* subtract 2 to %sp */
    subql #2,%sp
    pea 0x4000
    movew %fp@(10),%sp@-
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_17E)
    movew %sp@+,%d6
    moveq #0,%d0
rsrc_DRVR_49__netBOOT_58E:  /* restore registers, return */
    moveml %fp@(-16),%d6-%d7/%a3
    unlk %fp
    rts

/* subroutine (21 instructions): calls rsrc_DRVR_49__netBOOT_75E, rsrc_DRVR_49__netBOOT_732 (mechanical summary) */
rsrc_DRVR_49__netBOOT_598:
    moveml %d7/%a3-%a4,%sp@-
    movew %sp@(18),%d7
    moveaw #776,%a4
    moveal %a4@(2),%a3
    jbra rsrc_DRVR_49__netBOOT_598_14
rsrc_DRVR_49__netBOOT_598_12:  /* loop: movea */
    moveal %a3@,%a3
rsrc_DRVR_49__netBOOT_598_14:  /* test %a4@(6),%a3 */
    cmpal %a4@(6),%a3
    jbeq rsrc_DRVR_49__netBOOT_598_20
    cmpw %a3@(8),%d7
    jbne rsrc_DRVR_49__netBOOT_598_12
rsrc_DRVR_49__netBOOT_598_20:  /* test %a3@(8),%d7 */
    cmpw %a3@(8),%d7
    jbne rsrc_DRVR_49__netBOOT_598_38
    subql #2,%sp
    movel %a3,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_75E)
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_732)
    addql #2,%sp
rsrc_DRVR_49__netBOOT_598_38:  /* restore registers, return */
    moveml %sp@+,%d7/%a3-%a4
    rts

/* subroutine (33 instructions): traps ClosePort; calls rsrc_DRVR_49__netBOOT_598, rsrc_DRVR_49__netBOOT_772, rsrc_DRVR_49__netBOOT_732 (mechanical summary) */
rsrc_DRVR_49__netBOOT_5D6:
    linkw %fp,#-80
    moveml %d7/%a3,%sp@-
    moveal %fp@(8),%a3
    movew %fp@(14),%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_598)
    tstw %a3@(4)
    addql #4,%sp
    jbeq rsrc_DRVR_49__netBOOT_5D6_3C
    moveq #0,%d0
    movel %d0,%fp@(-68)
    movew %a3@(4),%fp@(-56)
    subql #2,%sp
    pea %fp@(-80)
    moveq #0,%d1
    moveb %d1,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_772)
    movew %sp@+,%d7
rsrc_DRVR_49__netBOOT_5D6_3C:  /* set up and call _ClosePort */
    tstl %a3@(218)
    jbeq rsrc_DRVR_49__netBOOT_5D6_56
    movel %a3@(218),%sp@-
    _ClosePort
    movel %a3@(218),%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_732)
    moveq #0,%d0
    movel %d0,%a3@(218)
rsrc_DRVR_49__netBOOT_5D6_56:  /* set %sp@- */
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_732)
    moveq #0,%d0
    moveml %fp@(-88),%d7/%a3
    unlk %fp
    rts

/* subroutine (66 instructions): calls rsrc_DRVR_49__netBOOT_416, rsrc_DRVR_49__netBOOT_784; low memory ToExtFS, MemErr (mechanical summary) */
rsrc_DRVR_49__netBOOT_63E:
    linkw %fp,#-130
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %fp@(12),%a3
    clrw %d7
    movew #255,%d0
    andw %a3@(6),%d0
    cmpiw #2,%d0
    jbeq rsrc_DRVR_49__netBOOT_63E_26
    moveq #-64,%d0
    jbra rsrc_DRVR_49__netBOOT_63E_C6
rsrc_DRVR_49__netBOOT_63E_26:  /* set %sp@- */
    movel %a4,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_416)
    movew %d0,%d7
    addql #4,%sp
    jbeq rsrc_DRVR_49__netBOOT_63E_38
    moveq #-64,%d0
    jbra rsrc_DRVR_49__netBOOT_63E_C6
rsrc_DRVR_49__netBOOT_63E_38:  /* set %fp@(-56) */
    movew %a4@(4),%fp@(-56)
    jbne rsrc_DRVR_49__netBOOT_63E_46
    moveq #-64,%d0
    jbra rsrc_DRVR_49__netBOOT_63E_C6
rsrc_DRVR_49__netBOOT_63E_46:  /* set %fp@(-54) */
    movew #1,%fp@(-54)
    moveq #0,%d0
    movel %d0,%fp@(-68)
    movel %a3@(36),%fp@(-44)
    movew %a3@(44),%fp@(-36)
    movel %a3@(46),%fp@(-34)
    movel %a3@(32),%fp@(-48)
    movel %a3@(28),%fp@(-52)
    subql #2,%sp
    pea %fp@(-80)
    moveq #0,%d1
    moveb %d1,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_784)
    movew %sp@+,%d7
    jbne rsrc_DRVR_49__netBOOT_63E_AC
    movew #2,%fp@(-104)
    movew %a4@(4),%fp@(-106)
    subql #2,%sp
    pea %fp@(-130)
    moveq #0,%d0
    moveb %d0,%sp@-
    jsr %pc@(rsrc_DRVR_49__netBOOT_784)
    movew %sp@+,%d7
    movel ToExtFS,%a4@(8)
    lea %pc@(rsrc_DRVR_49__netBOOT_200),%a0
    movel %a0,ToExtFS
rsrc_DRVR_49__netBOOT_63E_AC:  /* test %d7 */
    tstw %d7
    jbeq rsrc_DRVR_49__netBOOT_63E_BE
    movew %d7,%a4@(6)
    jble rsrc_DRVR_49__netBOOT_63E_BA
    moveq #-64,%d0
    jbra rsrc_DRVR_49__netBOOT_63E_BC
rsrc_DRVR_49__netBOOT_63E_BA:  /* set %d0 */
    moveq #-65,%d0
rsrc_DRVR_49__netBOOT_63E_BC:  /* set %d7 */
    movew %d0,%d7
rsrc_DRVR_49__netBOOT_63E_BE:  /* set %a3@(40) */
    movel %fp@(-40),%a3@(40)
    movew %d7,%d0
rsrc_DRVR_49__netBOOT_63E_C6:  /* restore registers, return */
    moveml %fp@(-142),%d7/%a3-%a4
    unlk %fp
    rts
    .short  0x225F	| 4085247E
    .short  0x201F, 0xA04C, 0x2E80, 0x4E71, 0x7000	| 40852480
rsrc_DRVR_49__netBOOT_63E_DC:  /* set %sp@- */
    movel %a1,%sp@-
rsrc_DRVR_49__netBOOT_63E_DE:  /* loop: move */
    movew %d0,MemErr
    rts
    moveq #0,%d0
    jbra rsrc_DRVR_49__netBOOT_63E_DE

/* subroutine (4 instructions): traps NewPtr (mechanical summary) */
rsrc_DRVR_49__netBOOT_726:
    moveal %sp@+,%a1
    movel %sp@+,%d0
    .short  0xA71E	| 4085249A _NewPtr (flags 0x0700)
    movel %a0,%sp@
    jmp %pc@(rsrc_DRVR_49__netBOOT_63E_DC)

/* subroutine (4 instructions): traps DisposPtr (mechanical summary) */
rsrc_DRVR_49__netBOOT_732:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _DisposPtr
    jmp %pc@(rsrc_DRVR_49__netBOOT_63E_DC)

/* subroutine (4 instructions): traps GetTrapAddress (mechanical summary) */
rsrc_DRVR_49__netBOOT_73C:
    moveal %sp@+,%a1
    movew %sp@+,%d0
    .short  0xA146	| 408524B0 _GetTrapAddress (flags 0x0100)
    movel %a0,%sp@
    jmp %a1@

/* subroutine (9 instructions): traps GetTrapAddress (mechanical summary) */
rsrc_DRVR_49__netBOOT_746:
    moveal %sp@+,%a1
    moveb %sp@+,%d1
    movew %sp@+,%d0
    movel %a1,%sp@-
    tstb %d1
    jbeq rsrc_DRVR_49__netBOOT_746_10
    .short  0xA746	| 408524C2 _GetTrapAddress (flags 0x0700)
    jbra rsrc_DRVR_49__netBOOT_746_12
rsrc_DRVR_49__netBOOT_746_10:  /* (_GetTrapAddress (flags 0x0300)) */
    .short  0xA346	| 408524C6 _GetTrapAddress (flags 0x0300)
rsrc_DRVR_49__netBOOT_746_12:  /* set %sp@(4) */
    movel %a0,%sp@(4)
    rts

/* subroutine (7 instructions): traps Dequeue (mechanical summary) */
rsrc_DRVR_49__netBOOT_75E:
    moveal %sp@(4),%a1
    moveal %sp@(8),%a0
    _Dequeue
    movew %d0,%sp@(12)
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* subroutine (8 instructions): traps Close (mechanical summary) */
rsrc_DRVR_49__netBOOT_772:
    moveal %sp@+,%a1
    moveb %sp@+,%d0
    moveal %sp@+,%a0
    jbne rsrc_DRVR_49__netBOOT_772_C
    _Close
    jbra rsrc_DRVR_49__netBOOT_772_E
rsrc_DRVR_49__netBOOT_772_C:  /* (_Close (flags 0x0400)) */
    .short  0xA401	| 408524EE _Close (flags 0x0400)
rsrc_DRVR_49__netBOOT_772_E:  /* set %sp@ */
    movew %d0,%sp@
    jmp %a1@

/* subroutine (8 instructions): traps Control (mechanical summary) */
rsrc_DRVR_49__netBOOT_784:
    moveal %sp@+,%a1
    moveb %sp@+,%d0
    moveal %sp@+,%a0
    jbne rsrc_DRVR_49__netBOOT_784_C
    _Control
    jbra rsrc_DRVR_49__netBOOT_784_E
rsrc_DRVR_49__netBOOT_784_C:  /* (_Control (flags 0x0400)) */
    .short  0xA404	| 40852500 _Control (flags 0x0400)
rsrc_DRVR_49__netBOOT_784_E:  /* set %sp@ */
    movew %d0,%sp@
    jmp %a1@

/* subroutine (6 instructions): traps SlotManager (mechanical summary) */
rsrc_DRVR_49__netBOOT_796:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    moveq #21,%d0	/* _SlotManager 21: NEXTTYPESRSRC, sNextTypesRsrc */
    _SlotManager
    movew %d0,%sp@
    jmp %a1@

/* subroutine (6 instructions): traps SlotManager (mechanical summary) */
rsrc_DRVR_49__netBOOT_7A2:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    moveq #25,%d0	/* _SlotManager 25: READSLOTDRVRNAME, sReadDrvrName */
    _SlotManager
    movew %d0,%sp@
    jmp %a1@

/* subroutine (7 instructions): traps Open (mechanical summary) */
rsrc_DRVR_49__netBOOT_7AE:
    moveal %sp@+,%a1
    moveb %sp@+,%d0
    moveal %sp@+,%a0
    jbne rsrc_DRVR_49__netBOOT_7AE_C
    .short  0xA200	| 40852526 _Open (flags 0x0200)
    jbra rsrc_DRVR_49__netBOOT_7AE_E
rsrc_DRVR_49__netBOOT_7AE_C:  /* (_Open (flags 0x0600)) */
    .short  0xA600	| 4085252A _Open (flags 0x0600)
rsrc_DRVR_49__netBOOT_7AE_E:  /* set %sp@ */
    movew %d0,%sp@
    jmp %a1@
