/*
 os/sysbeep.s - SysBeep and the original boot/error beeps
 From SYSTEMBEEP (0x40806FC0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple.
*/

/*
 _SysBeep(duration): play the alert sound chosen in the Sound control panel (XPRAM
 0x7C): its 'snd ' from the System file (or the ROM, 'snd ' 1) through SndPlay;
 without sound (or if that fails) flash the menu bar. Nothing at interrupt level or
 while the Sound Manager is busy.
*/
trap_SysBeep:
SYSTEMBEEP:
    moveml %d0-%d7/%a1-%fp,%sp@-
    movew %sr,%d0
    andiw #1792,%d0
    jbne SYSTEMBEEP_76
    moveal SMGlobals,%a0
    tstw %a0@(24)
    jbeq SYSTEMBEEP_2C
    jbra SYSTEMBEEP_76
SYSTEMBEEP_18:          /* no sound: flash the menu bar (if there are windows) */
    tstb WWExist
    jbne SYSTEMBEEP_76
    clrl %sp@-
    _FlashMenuBar
    subal %a0,%a0
    addqw #8,%a0
    _Delay
    _FlashMenuBar
    jbra SYSTEMBEEP_76
SYSTEMBEEP_2C:          /* the sound's ID from XPRAM 0x7C */
    clrw %sp@-
    moveal %sp,%a0
    movel #131196,%d0
    _ReadXPRam
    movew %sp@,%d0

SYSTEMBEEP_3A:          /* RGetResource('snd ', id) (the type is in the raw long) */
    clrl %sp@-
    .long   0x2F3C736E	| 40806FFC

SYSTEMBEEP_40:          /* found? SndPlay it */
    jbcc SYSTEMBEEP_62
    movew %d0,%sp@-
    moveb ResLoad,%d4
    moveb #1,ResLoad
    _RGetResource
    moveb %d4,ResLoad
    moveal %sp@+,%a0
    clrw %sp@-
    clrl %sp@-
    movel %a0,%sp@-
    clrw %sp@-
    _SndPlay
    movew %sp@+,%d0
SYSTEMBEEP_62:          /* failed: try 'snd ' 1, then flash */
    movew %sp@+,%d1
    tstw %d0
    jbeq SYSTEMBEEP_76
    cmpiw #1,%d1
    jbeq SYSTEMBEEP_18
    movew #1,%d0
    movew %d0,%sp@-
    jbra SYSTEMBEEP_3A

SYSTEMBEEP_76:          /* return, pop the parameter */
    moveml %sp@+,%d0-%d7/%a1-%fp
    moveal %sp@+,%a0
    addqw #2,%sp
    jmp %a0@

/*
 ORIGBOOTBEEP / ORIGBOOTBEEP6 / ORIGERRORBEEP1..4: the beeps of machines
 without the newer sound chip: a square-ish wave built in the ASC's wave table, played
 for the durations in the table at ORIGERRORBEEP4_EE. Run without RAM (return
 through fp).
*/
ORIGBOOTBEEP:
    moveal %fp,%a2
    lea %pc@(ORIGERRORBEEP4_EE),%a4
    lea %pc@(ORIGBOOTBEEP_E),%fp
    jmp %pc@(ORIGERRORBEEP4_4)
ORIGBOOTBEEP_E:
    moveal %a2,%fp
    rts
ORIGBOOTBEEP6:          /* boot beep */
    lea %pc@(ORIGERRORBEEP4_EE),%a4
    jbra ORIGERRORBEEP4_4
ORIGERRORBEEP1:         /* error beep 1 (raw words: its table, then the common code) */
    .short  0x49FA, 0x011E	| lea %pc@(40807178 <ORIGERRORBEEP4_EE+0x20>),%a4
    bras ORIGERRORBEEP4_4
ORIGERRORBEEP2:         /* error beep 2 */
    .short  0x49FA, 0x0138	| lea %pc@(40807198 <ORIGERRORBEEP4_EE+0x40>),%a4
    bras ORIGERRORBEEP4_4
ORIGERRORBEEP3:         /* error beep 3 */
    .short  0x49FA, 0x0146	| lea %pc@(408071ac <ORIGERRORBEEP4_EE+0x54>),%a4
    bras ORIGERRORBEEP4_4
ORIGERRORBEEP4:         /* error beep 4 */
    .short  0x49FA, 0x0158	| 4080706A
ORIGERRORBEEP4_4:       /* common: ASC off, volume, mode */
    clrb %a3@(2049)
    clrb %a3@(2055)
    movew %a4@+,%d0
    lslw #2,%d0
    tstb %a3@(2048)
    jbne ORIGERRORBEEP4_18
    lsrw #5,%d0
ORIGERRORBEEP4_18:      /* (old sound chip: shift the volume) */
    moveb %d0,%a3@(2054)
    moveq #1,%d0
    tstb %a3@(2048)
    jbne ORIGERRORBEEP4_26
    moveq #0,%d0
ORIGERRORBEEP4_26:      /* wave table mode or FIFO mode */
    moveb %d0,%a3@(2050)
    lea %a3@(2064),%a0
    moveq #31,%d0
ORIGERRORBEEP4_30:      /* clear the voice registers */
    clrb %a0@+
    dbf %d0,ORIGERRORBEEP4_30
    moveq #-2,%d0
    moveb %d0,%a0@+
    moveb %d0,%a0@+
    moveb %d0,%a0@+
    moveb %d0,%a0@+
    moveb %d0,%a0@+
    moveb %d0,%a0@+
    moveb %d0,%a0@+
    moveb %d0,%a0@+
    moveb #2,%a3@(2049)
    clrb %a3@(2051)
    movel #-1073610944,%d0
    tstb %a3@(2048)
    jbne ORIGERRORBEEP4_64
    movel #805388048,%d0
ORIGERRORBEEP4_64:      /* fill the four wave tables (two values alternate) */
    moveal %a3,%a0
    moveq #31,%d1
ORIGERRORBEEP4_68:      /* next wave table */
    moveq #63,%d2
ORIGERRORBEEP4_6A:      /* 64 bytes */
    moveb %d0,%a0@+
    dbf %d2,ORIGERRORBEEP4_6A
    rorl #8,%d0
    dbf %d1,ORIGERRORBEEP4_68
    moveml %a4@+,%d0-%d2
    movew %a4@+,%d3
    moveq #0,%d5
    lea %a5@(7168),%a5
    lea %a3@(2068),%a1
    moveal %a3,%a0
    lea %a3@(512),%a3
    jbra ORIGERRORBEEP4_B2
ORIGERRORBEEP4_8E:      /* one sample: filter with the next, into all four tables */
    moveb %a0@+,%d4
    cmpal %a0,%a3
    jbhi ORIGERRORBEEP4_98
    lea %a0@(-512),%a0
ORIGERRORBEEP4_98:      /* (wrap) */
    addb %a0@,%d4
    roxrb #1,%d4
    moveb %d4,%a0@(1536)
    moveb %d4,%a0@(1024)
    moveb %d4,%a0@(512)
    moveb %d4,%a0@
    movew %d0,%d4
ORIGERRORBEEP4_AC:      /* delay (VIA reads) */
    tstb %a5@
    dbf %d4,ORIGERRORBEEP4_AC
ORIGERRORBEEP4_B2:      /* next note? set the four voice frequencies */
    dbf %d5,ORIGERRORBEEP4_C8
    tstw %d3
    jbeq ORIGERRORBEEP4_C8
    movew %d1,%d5
    moveb %a4@+,%a1@+
    moveb %a4@+,%a1@+
    moveb %a4@+,%a1@+
    moveb %a4@+,%a1@+
    addqw #4,%a1
    subqw #1,%d3
ORIGERRORBEEP4_C8:      /* next sample */
    dbf %d2,ORIGERRORBEEP4_8E
    lea %a3@(-512),%a3
    lea %a5@(-7168),%a5
    lea %a3@(2068),%a0
    moveq #3,%d2
ORIGERRORBEEP4_DA:      /* silence the voices */
    clrb %a0@+
    clrb %a0@+
    clrb %a0@+
    clrb %a0@+
    addqw #4,%a0
    dbf %d2,ORIGERRORBEEP4_DA
    clrb %a3@(2049)
    jmp %fp@
ORIGERRORBEEP4_EE:      /* beep tables (duration, notes) (partly data) */
    .byte   0x02, 0x04, 0x00, 0x00, 0x00, 0x0D, 0x00, 0x00, 0x01, 0x2C, 0x00, 0x00, 0x75, 0x30, 0x00, 0x04	| 40807158
    .byte   0x00, 0x01, 0x80, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x01, 0x81, 0x79, 0x00, 0x03, 0x00, 0x00	| 40807168
    .byte   0x06, 0x07	| 40807178
ORIGERRORBEEP4_EE_22:
    .byte   0x00, 0x00, 0x00, 0x27, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x13, 0x88, 0x00, 0x04, 0x00, 0x00	| 4080717A
    .byte   0xC0, 0x9C, 0x00, 0x00, 0xE0, 0xB6, 0x00, 0x01, 0x20, 0xEA, 0x00, 0x01, 0x82, 0xB1, 0x05, 0x06	| 4080718A
    .byte   0x00, 0x00, 0x00, 0x27, 0x00, 0x00, 0x0B, 0xB8, 0x00, 0x00, 0x4E, 0x20, 0x00, 0x01, 0x00, 0x03	| 4080719A
    .byte   0x02, 0x72, 0x05, 0x06, 0x00, 0x00, 0x00, 0x27, 0x00, 0x00, 0x0B, 0xB8, 0x00, 0x00, 0x4E, 0x20	| 408071AA
    .byte   0x00, 0x02, 0x00, 0x03, 0x02, 0x72, 0x00, 0x04, 0x85, 0x24	| 408071BA
    addib #0,%d7
    orib #0,%a3@(3000)
    .byte   0x00, 0x00	| 408071CE
    bsrs ORIGERRORBEEP4_EE_22	| 408071D0
    orib #1,%d4
    lea %sp@(1),%a1
    subaw %a3@(1),%a2
    roxlw %sp@-
    .short  0x0002, 0x8957	| orib #87,%d2
    .long   0x00000000, 0x00000000, 0x00000000	| 408071E4
