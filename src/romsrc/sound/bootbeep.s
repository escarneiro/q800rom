/*
 sound/bootbeep.s - boot and error beeps
 From BOOTBEEP6 (0x40845C0A). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the bytes, not taken from Apple. It runs without RAM (register-only, return addresses in a6/a1 etc.), from the
 start-up tests: it plays a beep from BEEPTABLE directly on the sound chip (ASC, or
 the "Batman" sound hardware of some models, checked by the BATMANCHECK patches).
*/

/* BOOTBEEP6: the boot beep (BEEPTABLE entry 0), through BOOTBEEPPATCH. */
BOOTBEEP6:
    jbra BOOTBEEPPATCH
    bnes DOBEEP
BOOTBEEP6_8:
    lea 0xfffc1440,%a0	| 40845C12
    jmp %pc@(BOOTBEEP6_8,%a0:l)

/*
 ERRORBEEP1 .. ERRORBEEP4: the error beeps (entries 1..4): d0 = the entry, then into
 DOBEEP (only when the sound hardware is present).
*/
ERRORBEEP1:
    moveq #1,%d0
    tstb %a3@(2048)
    bnes DOBEEP
ERRORBEEP1_8:
    lea 0xfffc1434,%a0	| 40845C24
    jmp %pc@(ERRORBEEP1_8,%a0:l)
ERRORBEEP2:             /* (data) */
    moveq #2,%d0
    tstb %a3@(2048)
    bnes DOBEEP
ERRORBEEP2_8:
    lea 0xfffc1428,%a0	| 40845C36
    jmp %pc@(ERRORBEEP2_8,%a0:l)
ERRORBEEP3:             /* (data) */
    moveq #3,%d0
    tstb %a3@(2048)
    bnes DOBEEP
ERRORBEEP3_8:
    lea 0xfffc141c,%a0	| 40845C48
    jmp %pc@(ERRORBEEP3_8,%a0:l)
ERRORBEEP4:             /* (data) */
    moveq #4,%d0
    tstb %a3@(2048)
    bnes DOBEEP
ERRORBEEP4_8:
    lea 0xfffc1410,%a0	| 40845C5A
    jmp %pc@(ERRORBEEP4_8,%a0:l)

/*
 DOBEEP: play BEEPTABLE entry d0: set up the sound chip (through the BATMANCHECK patches
 for the Batman hardware), mix the four voices from the triangle wave (BEEPERLOOP) and
 wait for the sound to finish.
*/
DOBEEP:
    moveal %fp,%a2
    moveal %a3,%fp
    lea %pc@(BEEPTABLE),%a4
    addw %d0,%d0
    movew %a4@(0x0,%d0:w),%d0
    lea %a4@(0x0,%d0:w),%a4
    bral BATMANCHECK1
BATMANCHECK1RETURN:     /* (back from the first Batman check: chip set-up) */
    bnes BATMANCHECK1RETURN_14
    moveb #1,%fp@(3849)
    moveb #1,%fp@(3881)
    moveb #2,%fp@(2058)
BATMANCHECK1RETURN_14:
    .short  0x002E, 0x0080, 0x0803	| orib #-128,%fp@(2051)
    andib #127,%fp@(2051)
    moveb #0xe0,%fp@(2054)	| 40845C9C
    moveb #1,%fp@(2049)
    bral BATMANCHECK2
BATMANCHECK2RETURN:     /* (back from the second check: volume and filter registers) */
    beqs BATMANCHECK2RETURN_E
    clrb %fp@(2055)
    moveb #2,%fp@(2050)
    bras BATMANCHECK2RETURN_6E
BATMANCHECK2RETURN_E:
    clrb %fp@(3848)
    clrb %fp@(3880)
    movew #-32465,%fp@(3844)
    movew #-32465,%fp@(3876)
    clrw %fp@(3856)
    movew #60,%fp@(3858)
    movew #-13197,%fp@(3860)
    movew #-13982,%fp@(3862)
    clrw %fp@(3888)
    movew #60,%fp@(3890)
    movew #-13197,%fp@(3892)
    movew #-13982,%fp@(3894)
    moveb #127,%fp@(3846)
    clrb %fp@(3847)
    clrb %fp@(3878)
    moveb #127,%fp@(3879)
    moveb #0x80,%fp@(3848)	| 40845D10
    moveb #0x80,%fp@(3880)
BATMANCHECK2RETURN_6E:
    moveq #0,%d6
    movel %d6,%d3
    moveal %d6,%a3
    moveal %d6,%a0
    movel #65537,%d2
    movel #65537,%d4
    bral BATMANCHECK3
BATMANCHECK3RETURN:     /* (back from the third check: fill the FIFO, play the voices) */
    bnes BATMANCHECK3RETURN_18
    movew #127,%d5
BATMANCHECK3RETURN_6:
    movel #-2139062144,%fp@
    movel #-2139062144,%fp@(1024)
    dbf %d5,BATMANCHECK3RETURN_6
BATMANCHECK3RETURN_18:
    movel #16384,%d5
    movew %a4@(8),%d2
    tstw %a4@
    bnes BATMANCHECK3RETURN_3C
    swap %d2
    movew %a4@(10),%d2
    swap %d2
    movew %a4@(12),%d4
    swap %d4
    movew %a4@(14),%d4
    swap %d4
    bras BATMANCHECK3RETURN_A8
BATMANCHECK3RETURN_3C:
    swap %d5
    movew %a4@(2),%d5
BATMANCHECK3RETURN_42:
    swap %d5
    lea %pc@(BATMANCHECK3RETURN_4C),%a1
    jmp %pc@(BEEP4_10)
BATMANCHECK3RETURN_4C:
    lea %pc@(BATMANCHECK3RETURN_54),%a1
    jmp %pc@(BATMANCHECK5RETURN_10)
BATMANCHECK3RETURN_54:
    swap %d5
    subqw #1,%d5
    bnes BATMANCHECK3RETURN_42
    swap %d2
    movew %a4@(10),%d2
    swap %d2
    movew %a4@(4),%d5
BATMANCHECK3RETURN_66:
    swap %d5
    lea %pc@(BATMANCHECK3RETURN_70),%a1
    jmp %pc@(BEEP4_10)
BATMANCHECK3RETURN_70:
    lea %pc@(BATMANCHECK3RETURN_78),%a1
    jmp %pc@(BATMANCHECK5RETURN_10)
BATMANCHECK3RETURN_78:
    swap %d5
    subqw #1,%d5
    bnes BATMANCHECK3RETURN_66
    movew %a4@(12),%d4
    movew %a4@(6),%d5
BATMANCHECK3RETURN_86:
    swap %d5
    lea %pc@(BATMANCHECK3RETURN_90),%a1
    jmp %pc@(BEEP4_10)
BATMANCHECK3RETURN_90:
    lea %pc@(BATMANCHECK3RETURN_98),%a1
    jmp %pc@(BATMANCHECK5RETURN_10)
BATMANCHECK3RETURN_98:
    swap %d5
    subqw #1,%d5
    bnes BATMANCHECK3RETURN_86
    swap %d4
    movew %a4@(14),%d4
    swap %d4
    bras BATMANCHECK3RETURN_AA
BATMANCHECK3RETURN_A8:
    swap %d5
BATMANCHECK3RETURN_AA:
    movew #33,%d5
BATMANCHECK3RETURN_AE:
    swap %d5
    lea %pc@(BATMANCHECK3RETURN_B8),%a1
    jmp %pc@(BEEP4_10)
BATMANCHECK3RETURN_B8:
    lea %pc@(BATMANCHECK3RETURN_C0),%a1
    jmp %pc@(BATMANCHECK5RETURN_10)
BATMANCHECK3RETURN_C0:
    subiw #512,%d5
    swap %d5
    cmpib #0xb0,%fp@(2048)	| 40845DFC
    nop
    subqw #1,%d5
    bnes BATMANCHECK3RETURN_AE
    bral BATMANCHECK4
BATMANCHECK4RETURN:     /* (back from the fourth check) */
    bnes ISNTBATMAN2
    bral SPINEMPTYPATCH
    nop
SPINEMPTYPATCHRETURN:   /* (back from the wait for the FIFO to empty) */
    cmpib #3,%d0	| 40845E18
    bnes BATMANCHECK4RETURN+0x2
ISNTBATMAN2:            /* (not Batman: plain ASC) */
    clrb %fp@(2049)
    clrb %fp@(2054)
    bral BATMANCHECK5
BATMANCHECK5RETURN:     /* (back from the last check: chip off) */
    bnes BATMANCHECK5RETURN_A
    clrb %fp@(3849)
    clrb %fp@(3881)
BATMANCHECK5RETURN_A:
    moveal %fp,%a3
    moveal %a2,%fp
    jmp %fp@
BATMANCHECK5RETURN_10:
    bral SPINBEEPPATCH
    nop
SPINBEEPPATCHRETURN:    /* (back from the beep wait) */
    beqs BATMANCHECK5RETURN_10	| 40845E44
SPINBEEPRETURN:         /* return (jmp (a1)) */
    jmp %a1@	| 40845E46
    .include "sound/beeptable.s"
BEEP4_10:
    movel #16711680,%d1	| 40845EA2
    lea %pc@(BEEPMIXERDONE+0x2),%a5
BEEPERLOOP:             /* mix one sample of the four voices: phase += pitch, triangle wave lookup, sum */
    clrw %d1
    moveq #0,%d0
    movew %d2,%d0
    bnes BEEPERLOOP_E
    addil #65536,%d3
BEEPERLOOP_E:
    addl %d0,%d3
    swap %d2
    movew %d2,%d0
    bnes BEEPERLOOP_1C
    addal #65536,%a3
BEEPERLOOP_1C:
    addal %d0,%a3
    swap %d2
    movew %d4,%d0
    bnes BEEPERLOOP_2A
    addal #65536,%a0
BEEPERLOOP_2A:
    addal %d0,%a0
    swap %d4
    movew %d4,%d0
    bnes BEEPERLOOP_38
    addil #65536,%d6
BEEPERLOOP_38:
    addl %d0,%d6
    swap %d4
    movel %d3,%d0
    andl %d1,%d0
    swap %d0
    moveb %a5@(0x0,%d0:w),%d1
    movel %a3,%d0
    andl %d1,%d0
    swap %d0
    moveb %a5@(0x0,%d0:w),%d0
    addw %d0,%d1
    movel %a0,%d0
    andl %d1,%d0
    swap %d0
    moveb %a5@(0x0,%d0:w),%d0
    addw %d0,%d1
    movel %d6,%d0
    andl %d1,%d0
    swap %d0
    moveb %a5@(0x0,%d0:w),%d0
    addw %d0,%d1
    moveq #0,%d0
    movew %d1,%d0
    subiw #512,%d0
    extl %d0
    mulsw %d5,%d0
    swap %d0
    addiw #128,%d0
    moveb %d0,%fp@
    moveb %d0,%fp@(1024)
    bral BEEPMIXERPATCH
    nop
BEEPMIXERPATCHRETURN:   /* (back from the mixer patch: next sample) */
    beqw BEEPERLOOP	| 40845F36
BEEPMIXERDONE:          /* return (jmp (a1)), then the 32-sample triangle wave, repeated */
    jmp %a1@
    orl %a0@,%d0
    .short  0xA0B0	| 40845F3E A-line trap
    muluw %a0@,%d0
    .short  0xE0F0, 0xFFF0, 0xE0D0, 0xC0B0, 0xA090, 0x8070, 0x6050, 0x4030	| 40845F42
    .short  0x2010, 0x0010, 0x2030, 0x4050, 0x6070, 0x8090, 0xA0B0	| 40845F52
    muluw %a0@,%d0
    .short  0xE0F0, 0xFFF0, 0xE0D0, 0xC0B0, 0xA090, 0x8070, 0x6050, 0x4030	| 40845F62
    .short  0x2010, 0x0010, 0x2030, 0x4050, 0x6070, 0x8090, 0xA0B0	| 40845F72
    muluw %a0@,%d0
    .short  0xE0F0, 0xFFF0, 0xE0D0, 0xC0B0, 0xA090, 0x8070, 0x6050, 0x4030	| 40845F82
    .short  0x2010, 0x0010, 0x2030, 0x4050, 0x6070, 0x8090, 0xA0B0	| 40845F92
    muluw %a0@,%d0
    .short  0xE0F0, 0xFFF0, 0xE0D0, 0xC0B0, 0xA090, 0x8070, 0x6050, 0x4030	| 40845FA2
    .short  0x2010, 0x0010, 0x2030, 0x4050, 0x6070, 0x8090, 0xA0B0	| 40845FB2
    muluw %a0@,%d0
    .short  0xE0F0, 0xFFF0, 0xE0D0, 0xC0B0, 0xA090, 0x8070, 0x6050, 0x4030	| 40845FC2
    .short  0x2010, 0x0010, 0x2030, 0x4050, 0x6070, 0x8090, 0xA0B0	| 40845FD2
    muluw %a0@,%d0
    .short  0xE0F0, 0xFFF0, 0xE0D0, 0xC0B0, 0xA090, 0x8070, 0x6050, 0x4030	| 40845FE2
    .short  0x2010, 0x0010, 0x2030, 0x4050, 0x6070, 0x8090, 0xA0B0	| 40845FF2
    muluw %a0@,%d0
    .short  0xE0F0, 0xFFF0, 0xE0D0, 0xC0B0, 0xA090, 0x8070, 0x6050, 0x4030	| 40846002
    .short  0x2010, 0x0010, 0x2030, 0x4050, 0x6070, 0x8090, 0xA0B0	| 40846012
    muluw %a0@,%d0
    .short  0xE0F0, 0xFFF0, 0xE0D0, 0xC0B0, 0xA090, 0x8070, 0x6050, 0x4030	| 40846022
    .short  0x2010, 0x0010, 0x2030, 0x4050, 0x6070, 0x0000, 0x0000	| 40846032
