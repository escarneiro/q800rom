/*
 toolbox/printglue.s - Printing Manager glue
 From PRGLUE (0x40825F40). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine, labels inside are commented mechanically from the instruction that follows.
*/

/* PRGLUE: _PrGlue: the Printing Manager calls: load the printer driver ('PDEF') and dispatch. */
trap_PrGlue:
PRGLUE:
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveq #0,%d1
    moveb %fp@(8),%d1
    lsrb #3,%d1
    jbeq PRGLUE_2A
    tstb %fp@(8)
    jbmi PRGLUE_DA
    moveq #0,%d2
    moveb %fp@(9),%d2
    jbne PRGLUE_40
    moveq #3,%d2
    andb ChooserBits,%d2
    jbra PRGLUE_40
PRGLUE_2A:              /* set %a0 */
    moveal %fp@(20),%a0
    moveal %a0@,%a0
    moveq #3,%d2
    andb %a0@(68),%d2
    andib #0xfc,ChooserBits
    orb %d2,ChooserBits
PRGLUE_40:              /* set %a3 */
    moveaw CurMap,%a3
    clrl %sp@-
    movel #1346651462,%sp@-
    movew %d2,%sp@-
    _GetResource
    movel %sp@+,%d0
    tstl %d0
    jbne PRGLUE_A0
    cmpiw #-1,0x952
    jbeq PRGLUE_6A
    movew 0x952,%sp@-
    _UseResFile
    tstw ResErr
    jbeq PRGLUE_80
PRGLUE_6A:              /* call PRGLUE_23A */
    jbsr PRGLUE_23A
    tstw %d0
    jbeq PRGLUE_7A
    movew %d0,PrintErr
    jbra PRGLUE_128
PRGLUE_7A:              /* set up and call _UseResFile */
    movew 0x952,%sp@-
    _UseResFile
PRGLUE_80:              /* set up and call _GetResource */
    clrl %sp@-
    movel #1346651462,%sp@-
    movew %d2,%sp@-
    _GetResource
    movel %sp@+,%d0
    tstl %d0
    jbne PRGLUE_A0
    movew %a3,%sp@-
    _UseResFile
    movew #-192,PrintErr
    jbra PRGLUE_128
PRGLUE_A0:              /* set up and call _HLock */
    moveal %d0,%a4
    moveal %a4,%a0
    _HLock
    movew %a3,%sp@-
    _UseResFile
    lea %fp@(12),%a0
    moveq #7,%d0
    andb %fp@(8),%d0
    addb %fp@(10),%d0
    subaw %d0,%sp
    moveal %sp,%a1
    _BlockMove
    moveb %fp@(11),%d0
    andib #127,%d0
    moveal %a4@,%a0
    jsr %a0@(0x0,%d0:w)
    moveb %fp@(11),%d0
    jbpl PRGLUE_D6
    moveal %a4,%a0
    _HUnlock
PRGLUE_D6:              /* continue at PRGLUE_1F0 */
    jbra PRGLUE_1F0
PRGLUE_DA:              /* from here: subaw #50,%sp */
    subaw #50,%sp
    lea %pc@(PSTR_Print),%a0
    movel %a0,%sp@(18)
    movew #-3,%sp@(24)
    clrb %sp@(27)
    moveal %sp,%a0
    moveq #0,%d0
    bclr #4,%d1
    addw %d1,%d1
    movew %pc@(PRGLUE_102,%d1:w),%d1
    jmp %pc@(PRGLUE_102,%d1:w)
PRGLUE_102:             /* (data) */
    .short  PRGLUE_168-PRGLUE_102	| 40826042
    .short  PRGLUE_16C-PRGLUE_102	| 40826044
    .short  PRGLUE_170-PRGLUE_102	| 40826046
    .short  PRGLUE_17A-PRGLUE_102	| 40826048
    .short  PRGLUE_18C-PRGLUE_102	| 4082604A
    .short  PRGLUE_1A8-PRGLUE_102	| 4082604C
    .short  PRGLUE_1BA-PRGLUE_102	| 4082604E
    .short  PRGLUE_1DA-PRGLUE_102	| 40826050
    .short  PRGLUE_1E4-PRGLUE_102	| 40826052
    .short  PRGLUE_132-PRGLUE_102	| 40826054
    .short  PRGLUE_144-PRGLUE_102	| 40826056
    .short  PRGLUE_122-PRGLUE_102	| 40826058
    .short  PRGLUE_122-PRGLUE_102	| 4082605A
    .short  PRGLUE_122-PRGLUE_102	| 4082605C
    .short  PRGLUE_122-PRGLUE_102	| 4082605E
    .short  PRGLUE_122-PRGLUE_102	| 40826060
PRGLUE_122:             /* set PrintErr */
    movew #-50,PrintErr
PRGLUE_128:             /* clear %d1 */
    moveq #0,%d1
    moveb %fp@(10),%d1
    jbra PRGLUE_20E
PRGLUE_132:             /* set up and call _PrGlue */
    movel #-2147483648,%sp@-
    _PrGlue
    movew PrintErr,%d0
    jbne PRGLUE_164
    moveq #0,%d1
    jbra PRGLUE_146
PRGLUE_144:             /* set %d1 */
    moveq #1,%d1
PRGLUE_146:             /* call PRGLUE_23A */
    jbsr PRGLUE_23A
    tstw %d0
    jbne PRGLUE_164
    movew 0x952,%d0
    tstw ResErr
    jbne PRGLUE_160
    tstw %d1
    jbeq PRGLUE_160
    movew %d0,%sp@-
    _CloseResFile
PRGLUE_160:             /* set %d0 */
    movew ResErr,%d0
PRGLUE_164:             /* continue at PRGLUE_1E8 */
    jbra PRGLUE_1E8
PRGLUE_168:             /* _Open */
    _Open
    jbra PRGLUE_1E8
PRGLUE_16C:             /* _Close */
    _Close
    jbra PRGLUE_1E8
PRGLUE_170:             /* call PRGLUE_1CC */
    jbsr PRGLUE_1CC
    lea %sp@(46),%sp
    movel %a0,%sp@
    jbra PRGLUE_1F0
PRGLUE_17A:             /* call PRGLUE_1CC */
    jbsr PRGLUE_1CC
    moveal %a0@,%a0
    moveq #0,%d0
    moveb %a0@(7),%d0
    lea %sp@(48),%sp
    movew %d0,%sp@
    jbra PRGLUE_1F0
PRGLUE_18C:             /* set %a0@(36) */
    movel %fp@(12),%a0@(36)
    movel %fp@(16),%a0@(32)
    movel %fp@(20),%a0@(28)
    movew %fp@(24),%a0@(26)
    _Control
    jbra PRGLUE_1E8
PRGLUE_1A8:             /* call PRGLUE_1CC */
    jbsr PRGLUE_1CC
    moveal %a0@,%a0
    btst #6,%a0@(5)
    jbeq PRGLUE_1E8
    moveal %a0@,%a0
    _HPurge
    jbra PRGLUE_1E8
PRGLUE_1BA:             /* call PRGLUE_1CC */
    jbsr PRGLUE_1CC
    moveal %a0@,%a0
    btst #6,%a0@(5)
    jbeq PRGLUE_1E8
    moveal %a0@,%a0
    _HNoPurge
    jbra PRGLUE_1E8

PRGLUE_1CC:             /* set up and call _Status */
    movew #1,%a0@(26)
    _Status
    moveal %a0@(28),%a0
    rts
PRGLUE_1DA:             /* address %sp@(48) */
    lea %sp@(48),%sp
    movew PrintErr,%sp@
    jbra PRGLUE_1F0
PRGLUE_1E4:             /* set %d0 */
    movew %fp@(12),%d0
PRGLUE_1E8:             /* address %sp@(50) */
    lea %sp@(50),%sp
    movew %d0,PrintErr
PRGLUE_1F0:             /* clear %d1 */
    moveq #0,%d1
    moveb %fp@(10),%d1
    moveq #7,%d0
    andb %fp@(8),%d0
    jbeq PRGLUE_20E
    moveal %sp,%a0
    lea %fp@(0xc,%d1:w),%a1
    lsrw #1,%d0
    jbra PRGLUE_20A
PRGLUE_208:             /* loop: move */
    movew %sp@+,%a1@+
PRGLUE_20A:             /* count down */
    dbf %d0,PRGLUE_208
PRGLUE_20E:             /* restore registers, return */
    moveml %sp@+,%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addal %d1,%sp
    addqw #4,%sp
    jmp %a0@
PRGLUE_21C:             /* loop: moveq */
    moveq #0,%d0
PRGLUE_21E:             /* loop: suba */
    subaw #64,%sp
    moveal %sp,%a0
    movew %d0,%a0@(22)
    clrl %a0@(18)
    _SetVol
    _GetVol
    movew %a0@(22),%d0
    lea %sp@(64),%sp
    rts

PRGLUE_23A:             /* set up and call _GetString */
    subqw #4,%sp
    movew #-8192,%sp@-
    _GetString
    movel %sp@+,%d0
    jbne PRGLUE_24C
    movew #-192,%d0
    jbra PRGLUE_274
PRGLUE_24C:             /* set %a1 */
    moveal %d0,%a1
    jbsr PRGLUE_21C
    swap %d1
    movew %d0,%d1
    subqw #2,%sp
    moveal %a1,%a0
    _HLock
    movel %a1@,%sp@-
    clrw %sp@-
    clrb %sp@-
    _OpenRFPerm
    movew %sp@+,0x952
    moveal %a1,%a0
    _HUnlock
    movew %d1,%d0
    swap %d1
    jbsr PRGLUE_21E
    movew ResErr,%d0
PRGLUE_274:             /* return */
    rts

/* PSTR_Print: Pascal string (printer resource file name). */
PSTR_Print:
    .byte   0x06	| 408261B6
    .ascii  ".Print \000\000"
