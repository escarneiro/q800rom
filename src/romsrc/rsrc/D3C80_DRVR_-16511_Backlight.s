/* ROM resource 'DRVR' -16511 ".Backlight": map entry at 0x408D3C80, data at 0x408D3CB0, 5190 bytes

 The .Backlight driver ('DRVR' -16511): screen backlight brightness on the PowerBooks
 (the brightness slider and keys, the dimming when idle), through the Power Manager.
 Its Control and Status calls dispatch through csCode tables (offsets read with movew
 %pc@(TABLE,%d0:w)). Not used on the Quadra 800. Comments inferred; routines summarised
 mechanically.
*/

rsrc_DRVR_m16511__Backlight_entry:  /* map entry */
    .long   0x78000000, 0x00000000, 0x00000000	| 408D3C80
    .long   rsrc_DRVR_m16511__Backlight-rom_start	| 408D3C8C
    .ascii  "DRVR"	| 408D3C90
    .byte   0xBF, 0x81, 0x58	| 408D3C94
    .byte   10	/* 408D3C97 Pascal string length */
    .ascii  ".Backlight"	| 408D3C98
    .byte   0x44, 0x43, 0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x14, 0x52, 0x00, 0x00, 0x04, 0x14	| 408D3CA2

/* subroutine (0 instructions): low memory Backlight (mechanical summary) */
rsrc_DRVR_m16511__Backlight:
    .byte   0x4C, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408D3CB0
rsrc_DRVR_m16511__Backlight_8:  /* (data) */
    .short  rsrc_DRVR_m16511__Backlight_open-rsrc_DRVR_m16511__Backlight	| 408D3CB8
    .short  rsrc_DRVR_m16511__Backlight_prime-rsrc_DRVR_m16511__Backlight	| 408D3CBA
    .short  rsrc_DRVR_m16511__Backlight_ctl-rsrc_DRVR_m16511__Backlight	| 408D3CBC
    .short  rsrc_DRVR_m16511__Backlight_status-rsrc_DRVR_m16511__Backlight	| 408D3CBE
    .short  rsrc_DRVR_m16511__Backlight_close-rsrc_DRVR_m16511__Backlight	| 408D3CC0
    .byte   10	/* 408D3CC2 Pascal string length */
    .ascii  ".Backlight\000\000\000"
    .long   0x00000000, 0x00000000, 0x00000000, 0x00000000	| 408D3CD0
    .short  0x0000	| 408D3CE0

/* Open, Prime, Control, Status: each a branch into the driver's common code. */
rsrc_DRVR_m16511__Backlight_open:
    braw rsrc_DRVR_m16511__Backlight_46

/* subroutine (1 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_prime:
    braw rsrc_DRVR_m16511__Backlight_4C

/* subroutine (1 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_ctl:
    braw rsrc_DRVR_m16511__Backlight_52

/* subroutine (1 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_status:
    braw rsrc_DRVR_m16511__Backlight_58

/* Close: a branch into the common code, like the other four entries. */
rsrc_DRVR_m16511__Backlight_close:
    braw rsrc_DRVR_m16511__Backlight_5E

rsrc_DRVR_m16511__Backlight_46:  /* from here: pea %pc@(rsrc_DRVR_m16511__Backlight_CA) */
    pea %pc@(rsrc_DRVR_m16511__Backlight_CA)
    jbra rsrc_DRVR_m16511__Backlight_5E_6

rsrc_DRVR_m16511__Backlight_4C:  /* from here: pea %pc@(rsrc_DRVR_m16511__Backlight_22C_4A) */
    pea %pc@(rsrc_DRVR_m16511__Backlight_22C_4A)
    jbra rsrc_DRVR_m16511__Backlight_5E_6

rsrc_DRVR_m16511__Backlight_52:  /* from here: pea %pc@(rsrc_DRVR_m16511__Backlight_22C_56) */
    pea %pc@(rsrc_DRVR_m16511__Backlight_22C_56)
    jbra rsrc_DRVR_m16511__Backlight_5E_6

rsrc_DRVR_m16511__Backlight_58:  /* from here: pea %pc@(rsrc_DRVR_m16511__Backlight_39A) */
    pea %pc@(rsrc_DRVR_m16511__Backlight_39A)
    jbra rsrc_DRVR_m16511__Backlight_5E_6

rsrc_DRVR_m16511__Backlight_5E:  /* from here: pea %pc@(rsrc_DRVR_m16511__Backlight_22C) */
    pea %pc@(rsrc_DRVR_m16511__Backlight_22C)
    nop
rsrc_DRVR_m16511__Backlight_5E_6:  /* save registers */
    moveml %a0-%a1,%sp@-
    clrw %sp@-
    movel %a0,%sp@-
    movel %a1,%sp@-
    moveal %sp@(18),%a0
    jsr %a0@
    movew %sp@+,%d0
    moveml %sp@+,%a0-%a1
    addqw #4,%sp
    btst #1,%a0@(6)
    jbne rsrc_DRVR_m16511__Backlight_5E_2A
    movel JIODone,%sp@-
rsrc_DRVR_m16511__Backlight_5E_2A:  /* return */
    rts

/* subroutine (25 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_8A:
    moveml %d7/%a3-%a4,%sp@-
    moveq #0,%d0
    moveb 0xcb3,%d0
    movew %d0,%d7
    lea %pc@(rsrc_DRVR_m16511__Backlight_84C),%a3
    jbra rsrc_DRVR_m16511__Backlight_8A_2E
rsrc_DRVR_m16511__Backlight_8A_12:  /* loop: moveq */
    moveq #0,%d0
    movew %a3@,%d0
    extl %d7
    cmpl %d0,%d7
    jbne rsrc_DRVR_m16511__Backlight_8A_2A
    lea %pc@(rsrc_DRVR_m16511__Backlight_84C),%a0
    moveal %a3@(2),%a4
rsrc_DRVR_m16511__Backlight_8A_24:  /* from here: addal %a0,%a4 */
    addal %a0,%a4
    movel %a4,%d0
    jbra rsrc_DRVR_m16511__Backlight_8A_3A
rsrc_DRVR_m16511__Backlight_8A_2A:  /* from here: addaw #6,%a3 */
    addaw #6,%a3
rsrc_DRVR_m16511__Backlight_8A_2E:  /* clear %d0 */
    moveq #0,%d0
    movew %a3@,%d0
    moveq #-1,%d1
    cmpl %d0,%d1
    jbne rsrc_DRVR_m16511__Backlight_8A_12
    moveq #0,%d0
rsrc_DRVR_m16511__Backlight_8A_3A:  /* restore registers, return */
    moveml %sp@+,%d7/%a3-%a4
    rts

/* subroutine (103 instructions): calls rsrc_DRVR_m16511__Backlight_8A, rsrc_DRVR_m16511__Backlight_141C, rsrc_DRVR_m16511__Backlight_1428, rsrc_DRVR_m16511__Backlight_1432 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_CA:
    linkw %fp,#-8
    moveml %d7/%a3-%a4,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_8A)
    moveal %d0,%a4
    movel %a4,%d0
    jbne rsrc_DRVR_m16511__Backlight_CA_1C
    movew #-23,%fp@(16)
    jbra rsrc_DRVR_m16511__Backlight_CA_154
rsrc_DRVR_m16511__Backlight_CA_1C:  /* subtract 4 to %sp */
    subql #4,%sp
    moveq #104,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_141C)
    moveal %sp@+,%a3
    movel %a3,%d0
    jbne rsrc_DRVR_m16511__Backlight_CA_36
    movew #-23,%fp@(16)
    jbra rsrc_DRVR_m16511__Backlight_CA_154
rsrc_DRVR_m16511__Backlight_CA_36:  /* set %fp@(-8) */
    movel #3352,%fp@(-8)
    moveal %fp@(8),%a0
    movel %a3,%a0@(20)
    movew #257,%a3@(30)
    movel %a4@,%a3@(32)
    movew %a4@(50),%a3@(62)
    movew %a4@(52),%a3@(64)
    movew %a4@(48),%a3@(88)
    moveal %fp@(-8),%a0
    moveal %a0@,%a0
    moveb %a0@(13),%d0
    extw %d0
    movew %d0,%a3@(82)
    cmpw %a3@(86),%d0
    jble rsrc_DRVR_m16511__Backlight_CA_80
    movew %a3@(82),%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_CA_86
rsrc_DRVR_m16511__Backlight_CA_80:  /* set %d0 */
    movew %a3@(86),%d0
    extl %d0
rsrc_DRVR_m16511__Backlight_CA_86:  /* set %a3@(84) */
    movew %d0,%a3@(84)
    movel %a4@(32),%d0
    addl %a4,%d0
    movel %d0,%a3@(78)
    movel %a4@(36),%d0
    addl %a4,%d0
    movel %d0,%a3@(70)
    movel %a4@(40),%d0
    addl %a4,%d0
    movel %d0,%a3@(74)
    movel %a3@(74),%a3@(66)
    movel %a4@(4),%d0
    addl %a4,%d0
    movel %d0,%a3@(36)
    movel %a4@(8),%d0
    addl %a4,%d0
    movel %d0,%a3@(40)
    movel %a4@(12),%d0
    addl %a4,%d0
    movel %d0,%fp@(-4)
    movel %a4@(16),%d0
    addl %a4,%d0
    movel %d0,%a3@(52)
    movel %a4@(20),%d0
    addl %a4,%d0
    movel %d0,%a3@(44)
    movel %a4@(24),%d0
    addl %a4,%d0
    movel %d0,%a3@(48)
    movel %a4@(44),%d0
    addl %a4,%d0
    movel %d0,%a3@(100)
    movel %a4@(28),%d0
    addl %a4,%d0
    movel %d0,%a3@(56)
    tstl %fp@(-4)
    jbeq rsrc_DRVR_m16511__Backlight_CA_128
    movel %a3,%sp@-
    moveal %fp@(-4),%a0
    jsr %a0@
    movew %d0,%d7
    addql #4,%sp
    jbeq rsrc_DRVR_m16511__Backlight_CA_128
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_1428)
    moveal %fp@(8),%a0
    moveq #0,%d0
    movel %d0,%a0@(20)
    movew %d7,%fp@(16)
    jbra rsrc_DRVR_m16511__Backlight_CA_154
rsrc_DRVR_m16511__Backlight_CA_128:  /* set %a3@(12) */
    movel %a3,%a3@(12)
    movew #1,%a3@(20)
    lea %pc@(rsrc_DRVR_m16511__Backlight_678_64),%a0
    movel %a0,%a3@(22)
    movew %a3@(88),%a3@(26)
    clrw %a3@(28)
    subql #2,%sp
    pea %a3@(16)
    jsr %pc@(rsrc_DRVR_m16511__Backlight_1432)
    clrw %fp@(16)
    addql #2,%sp
rsrc_DRVR_m16511__Backlight_CA_154:  /* restore registers, return */
    moveml %fp@(-20),%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* subroutine (24 instructions): calls rsrc_DRVR_m16511__Backlight_143C, rsrc_DRVR_m16511__Backlight_1428 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_22C:
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %a4@(20),%a3
    subql #2,%sp
    pea %a3@(16)
    jsr %pc@(rsrc_DRVR_m16511__Backlight_143C)
    tstl %a3@(52)
    addql #2,%sp
    jbeq rsrc_DRVR_m16511__Backlight_22C_2C
    movel %a3,%sp@-
    moveal %a3@(52),%a0
    jsr %a0@
    addql #4,%sp
rsrc_DRVR_m16511__Backlight_22C_2C:  /* set %sp@- */
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_1428)
    moveq #0,%d0
    movel %d0,%a4@(20)
    clrw %fp@(16)
    moveml %fp@(-8),%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* subroutine (4 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_22C_4A:
    movew #-36,%sp@(12)
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* subroutine (15 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_22C_56:
    linkw %fp,#0
    moveml %d6-%d7/%a3-%a4,%sp@-
    moveal %fp@(12),%a4
    moveal %fp@(8),%a0
    moveal %a0@(20),%a3
    bclr #2,%a3@(35)
    moveq #0,%d6
    movew %a4@(26),%d0
    subiw #17155,%d0
    jbmi rsrc_DRVR_m16511__Backlight_372
    cmpiw #4,%d0
    jbgt rsrc_DRVR_m16511__Backlight_372
    addw %d0,%d0
    movew %pc@(rsrc_DRVR_m16511__Backlight_2BC,%d0:w),%d0
rsrc_DRVR_m16511__Backlight_22C_8C:  /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
rsrc_DRVR_m16511__Backlight_2BC:  /* (data) */
    .short  rsrc_DRVR_m16511__Backlight_2C6-(rsrc_DRVR_m16511__Backlight_22C_8C+2)	| 408D3F6C
    .short  rsrc_DRVR_m16511__Backlight_372-(rsrc_DRVR_m16511__Backlight_22C_8C+2)	| 408D3F6E
    .short  rsrc_DRVR_m16511__Backlight_372-(rsrc_DRVR_m16511__Backlight_22C_8C+2)	| 408D3F70
    .short  rsrc_DRVR_m16511__Backlight_2E4-(rsrc_DRVR_m16511__Backlight_22C_8C+2)	| 408D3F72
    .short  rsrc_DRVR_m16511__Backlight_33A-(rsrc_DRVR_m16511__Backlight_22C_8C+2)	| 408D3F74

/* subroutine (9 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_2C6:
    tstw %a4@(28)	| 408D3F76
    jbeq rsrc_DRVR_m16511__Backlight_2D0	| 408D3F7A
    moveq #1,%d0
    jbra rsrc_DRVR_m16511__Backlight_2D2
rsrc_DRVR_m16511__Backlight_2D0:  /* clear %d0 */
    moveq #0,%d0	| 408D3F80
rsrc_DRVR_m16511__Backlight_2D2:  /* from here: andib #0xfe,%a3@(35) */
    andib #0xfe,%a3@(35)
    andib #1,%d0
    orb %d0,%a3@(35)
    jbra rsrc_DRVR_m16511__Backlight_382

/* subroutine (33 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_2E4:
    movew %a4@(28),%d0	| 408D3F94
    extl %d0	| 408D3F98
    movel %d0,%d7	| 408D3F9A
    moveq #4,%d0	| 408D3F9C
    cmpl %d7,%d0	| 408D3F9E
    jbge rsrc_DRVR_m16511__Backlight_2F6	| 408D3FA0
    moveq #4,%d0
    jbra rsrc_DRVR_m16511__Backlight_300
rsrc_DRVR_m16511__Backlight_2F6:  /* test %d7 */
    tstl %d7	| 408D3FA6
    jbge rsrc_DRVR_m16511__Backlight_2FE	| 408D3FA8
    moveq #0,%d0
    jbra rsrc_DRVR_m16511__Backlight_300
rsrc_DRVR_m16511__Backlight_2FE:  /* set %d0 */
    movel %d7,%d0	| 408D3FAE
rsrc_DRVR_m16511__Backlight_300:  /* set %d7 */
    movel %d0,%d7
    movew %d7,%a3@(86)
    movew %a3@(82),%d0
    cmpw %a3@(86),%d0
    jble rsrc_DRVR_m16511__Backlight_318
    movew %a3@(82),%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_31E
rsrc_DRVR_m16511__Backlight_318:  /* set %d0 */
    movew %a3@(86),%d0
    extl %d0
rsrc_DRVR_m16511__Backlight_31E:  /* set %a3@(84) */
    movew %d0,%a3@(84)
    movel %a3,%sp@-
    movew %a3@(90),%d0
    extl %d0
    movel %d0,%sp@-
    moveal %a3@(36),%a0
    jsr %a0@
    movew %d0,%a3@(90)
    addql #8,%sp
    jbra rsrc_DRVR_m16511__Backlight_382

/* subroutine (19 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_33A:
    btst #5,%a3@(35)	| 408D3FEA
    jbne rsrc_DRVR_m16511__Backlight_346	| 408D3FF0
    moveq #-17,%d6
    jbra rsrc_DRVR_m16511__Backlight_382
rsrc_DRVR_m16511__Backlight_346:  /* test %a4@(28) */
    tstw %a4@(28)	| 408D3FF6
    jbeq rsrc_DRVR_m16511__Backlight_352	| 408D3FFA
    movel %a3@(74),%d0	| 408D3FFC
    jbra rsrc_DRVR_m16511__Backlight_356	| 408D4000
rsrc_DRVR_m16511__Backlight_352:  /* set %d0 */
    movel %a3@(70),%d0	| 408D4002
rsrc_DRVR_m16511__Backlight_356:  /* set %a3@(66) */
    movel %d0,%a3@(66)	| 408D4006
    movel %a3,%sp@-	| 408D400A
    movew %a3@(90),%d0	| 408D400C
    extl %d0	| 408D4010
    movel %d0,%sp@-	| 408D4012
    moveal %a3@(36),%a0	| 408D4014
    jsr %a0@	| 408D4018
    movew %d0,%a3@(90)	| 408D401A
    addql #8,%sp	| 408D401E
    jbra rsrc_DRVR_m16511__Backlight_382	| 408D4020

/* subroutine (14 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_372:
    movel %a3,%sp@-
    movel %a4,%sp@-
    moveal %a3@(44),%a0
    jsr %a0@
    extl %d0
    movel %d0,%d6
    addql #8,%sp
rsrc_DRVR_m16511__Backlight_382:  /* set bit 2 of %a3@(35) */
    bset #2,%a3@(35)
    movew %d6,%fp@(16)
    moveml %fp@(-16),%d6-%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@

/* subroutine (15 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_39A:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveal %fp@(12),%a4
    clrw %d7
    moveal %fp@(8),%a0
    moveal %a0@(20),%a3
    bclr #2,%a3@(35)
    movew %a4@(26),%d0
    subiw #21249,%d0
    jbmi rsrc_DRVR_m16511__Backlight_416
    cmpiw #6,%d0
    jbgt rsrc_DRVR_m16511__Backlight_416
    addw %d0,%d0
    movew %pc@(rsrc_DRVR_m16511__Backlight_3D0,%d0:w),%d0
rsrc_DRVR_m16511__Backlight_3CC:  /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
rsrc_DRVR_m16511__Backlight_3D0:  /* (data) */
    .short  rsrc_DRVR_m16511__Backlight_3E6-(rsrc_DRVR_m16511__Backlight_3CC+2)	| 408D4080
    .short  rsrc_DRVR_m16511__Backlight_416-(rsrc_DRVR_m16511__Backlight_3CC+2)	| 408D4082
    .short  rsrc_DRVR_m16511__Backlight_3EE-(rsrc_DRVR_m16511__Backlight_3CC+2)	| 408D4084
    .short  rsrc_DRVR_m16511__Backlight_416-(rsrc_DRVR_m16511__Backlight_3CC+2)	| 408D4086
    .short  rsrc_DRVR_m16511__Backlight_416-(rsrc_DRVR_m16511__Backlight_3CC+2)	| 408D4088
    .short  rsrc_DRVR_m16511__Backlight_402-(rsrc_DRVR_m16511__Backlight_3CC+2)	| 408D408A
    .short  rsrc_DRVR_m16511__Backlight_3DE-(rsrc_DRVR_m16511__Backlight_3CC+2)	| 408D408C

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_3DE:
    movew %a3@(30),%a4@(28)	| 408D408E
    jbra rsrc_DRVR_m16511__Backlight_424	| 408D4094

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_3E6:
    movew %a3@(90),%a4@(28)	| 408D4096
    jbra rsrc_DRVR_m16511__Backlight_424	| 408D409C

/* subroutine (5 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_3EE:
    moveal %a3@(66),%a0	| 408D409E
    .byte   0x39, 0x68	| 408D40A2
    orib #28,%d2
    moveal %a3@(66),%a0
    movew %a0@,%a4@(30)
    jbra rsrc_DRVR_m16511__Backlight_424

/* subroutine (6 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_402:
    moveal %a3@(78),%a0
    movew %a3@(84),%d0
    extl %d0
    addl %d0,%d0
    movew %a0@(0x0,%d0:l),%a4@(28)
    jbra rsrc_DRVR_m16511__Backlight_424

/* subroutine (13 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_416:
    movel %a3,%sp@-
    movel %a4,%sp@-
    moveal %a3@(48),%a0
    jsr %a0@
    movew %d0,%d7
    addql #8,%sp
rsrc_DRVR_m16511__Backlight_424:  /* set bit 2 of %a3@(35) */
    bset #2,%a3@(35)
    movew %d7,%fp@(16)
    moveml %fp@(-12),%d7/%a3-%a4
    unlk %fp
    moveal %sp@+,%a0
    addqw #8,%sp
    jmp %a0@
    moveq #-18,%d0
    rts

/* subroutine (43 instructions): calls rsrc_DRVR_m16511__Backlight_4BC, rsrc_DRVR_m16511__Backlight_51C (mechanical summary) */
rsrc_DRVR_m16511__Backlight_440:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveaw #3352,%a4
    movel %fp@(8),%d0
    subql #4,%d0
    moveal %d0,%a0
    moveal %a0@,%a3
    movew %a3@(88),%a3@(26)
    btst #2,%a3@(35)
    sne %d0
    andiw #1,%d0
    extl %d0
    jbeq rsrc_DRVR_m16511__Backlight_440_72
    tstl %a3@(56)
    jbeq rsrc_DRVR_m16511__Backlight_440_3C
    movel %a3,%sp@-
    moveal %a3@(56),%a0
    jsr %a0@
    addql #4,%sp
rsrc_DRVR_m16511__Backlight_440_3C:  /* test bit 0 of %a3@(35) */
    btst #0,%a3@(35)
    jbne rsrc_DRVR_m16511__Backlight_440_4C
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_4BC)
    addql #4,%sp
rsrc_DRVR_m16511__Backlight_440_4C:  /* set %a0 */
    moveal %a4@,%a0
    moveb %a0@(13),%d0
    extw %d0
    extl %d0
    movel %d0,%d7
    moveq #2,%d0
    cmpl %d7,%d0
    jbeq rsrc_DRVR_m16511__Backlight_440_72
    movew %a3@(82),%d0
    extl %d0
    cmpl %d0,%d7
    jbeq rsrc_DRVR_m16511__Backlight_440_72
    movel %d7,%sp@-
    movel %a3,%sp@-
rsrc_DRVR_m16511__Backlight_440_6C:  /* call rsrc_DRVR_m16511__Backlight_51C */
    jsr %pc@(rsrc_DRVR_m16511__Backlight_51C)
    addql #8,%sp
rsrc_DRVR_m16511__Backlight_440_72:  /* restore registers, return */
    moveml %fp@(-12),%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (31 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_4BC:
    linkw %fp,#-50
    moveml %d6-%d7/%a3,%sp@-
    moveal %fp@(8),%a3
    movew %a3@(90),%d0
    extl %d0
    movel %d0,%d7
    movel %a3,%sp@-
    moveal %a3@(40),%a0
    jsr %a0@
    movel %d0,%d6
    movel %a3,%sp@-
    movel %d6,%sp@-
    moveal %a3@(36),%a0
    jsr %a0@
    movew %d0,%a3@(90)
    btst #3,%a3@(35)
    lea %sp@(12),%sp
    jbne rsrc_DRVR_m16511__Backlight_4BC_56
    movew %a3@(90),%d0
    extl %d0
    cmpl %d0,%d7
    jbeq rsrc_DRVR_m16511__Backlight_4BC_56
    movew #17154,%fp@(-24)
    movel %a3,%sp@-
    pea %fp@(-50)
    moveal %a3@(44),%a0
    jsr %a0@
    addql #8,%sp
rsrc_DRVR_m16511__Backlight_4BC_56:  /* restore registers, return */
    moveml %fp@(-62),%d6-%d7/%a3
    unlk %fp
    rts

/* subroutine (43 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_51C:
    moveml %d5-%d7/%a3,%sp@-
    movel %sp@(24),%d6
    moveal %sp@(20),%a3
    movew %a3@(82),%d0
    extl %d0
    cmpl %d0,%d6
    sgt %d5
    negb %d5
    movew %d6,%a3@(82)
    movew %a3@(82),%d0
    cmpw %a3@(86),%d0
rsrc_DRVR_m16511__Backlight_51C_24:  /* from here: jble rsrc_DRVR_m16511__Backlight_51C_2E */
    jble rsrc_DRVR_m16511__Backlight_51C_2E
    movew %a3@(82),%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_51C_34
rsrc_DRVR_m16511__Backlight_51C_2E:  /* set %d0 */
    movew %a3@(86),%d0
    extl %d0
rsrc_DRVR_m16511__Backlight_51C_34:  /* set %a3@(84) */
    movew %d0,%a3@(84)
    movel %a3,%sp@-
    moveal %a3@(40),%a0
    jsr %a0@
    movel %d0,%d7
    tstb %d5
    addql #4,%sp
    jbeq rsrc_DRVR_m16511__Backlight_51C_60
    tstl %d6
    jbeq rsrc_DRVR_m16511__Backlight_51C_60
    btst #3,%a3@(35)
    jbne rsrc_DRVR_m16511__Backlight_51C_60
    tstl %d7
    jbeq rsrc_DRVR_m16511__Backlight_51C_60
    asrl #1,%d7
    tstl %d7
    jbne rsrc_DRVR_m16511__Backlight_51C_60
    moveq #1,%d7
rsrc_DRVR_m16511__Backlight_51C_60:  /* set %sp@- */
    movel %a3,%sp@-
    movel %d7,%sp@-
    moveal %a3@(36),%a0
    jsr %a0@
    movew %d0,%a3@(90)
    addql #8,%sp
    moveml %sp@+,%d5-%d7/%a3
    rts

/* subroutine (19 instructions): traps ReadXPRam (mechanical summary) */
rsrc_DRVR_m16511__Backlight_592:
    linkw %fp,#-2
    moveq #116,%d0
    movew %d0,%sp@-
    moveq #1,%d1
    movew %d1,%sp@-
    pea %fp@(-1)
    moveal %sp@+,%a0
    movel %sp@+,%d0
    _ReadXPRam
    moveq #0,%d0
    moveb %fp@(-1),%d0
    movew %fp@(10),%d1
    extl %d1
    andl %d0,%d1
    movew %fp@(14),%d0
    asrl %d0,%d1
    movel %d1,%d0
    unlk %fp
    rts

/* subroutine (34 instructions): traps ReadXPRam, WriteXPRam (mechanical summary) */
rsrc_DRVR_m16511__Backlight_5C2:
    linkw %fp,#-2
    moveml %d6-%d7,%sp@-
    movew %fp@(14),%d6
    moveq #112,%d7
    movel %d7,%d0
    addql #4,%d0
    movew %d0,%sp@-
    moveq #1,%d0
    movew %d0,%sp@-
    pea %fp@(-1)
    moveal %sp@+,%a0
    movel %sp@+,%d0
    _ReadXPRam
    movew %d6,%d0
    notw %d0
    andb %d0,%fp@(-1)
    movew %fp@(18),%d0
    movew %fp@(10),%d1
    lslw %d0,%d1
    movew %d6,%d0
    andw %d1,%d0
    orb %d0,%fp@(-1)
    movel %d7,%d0
    addql #4,%d0
    movew %d0,%sp@-
    moveq #1,%d0
    movew %d0,%sp@-
    pea %fp@(-1)
    moveal %sp@+,%a0
    movel %sp@+,%d0
    _WriteXPRam
    moveml %fp@(-10),%d6-%d7
    unlk %fp
    rts

/* subroutine (256 instructions): traps PMgrOp; calls rsrc_DRVR_m16511__Backlight_61C, rsrc_DRVR_m16511__Backlight_440, rsrc_DRVR_m16511__Backlight_F56, rsrc_DRVR_m16511__Backlight_13E2, rsrc_DRVR_m16511__Backlight_C5C (mechanical summary) */
rsrc_DRVR_m16511__Backlight_61C:
    moveml %d6-%d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a4
    moveaw #3352,%a3
    btst #6,%a4@(35)
    sne %d6
    negb %d6
    clrb %d7
    tstb %d6
    jbeq rsrc_DRVR_m16511__Backlight_61C_2E
    moveal %a3@,%a0
    moveq #0,%d0
    moveb %a0@(82),%d0
    moveq #0,%d1
    movew %a4@(64),%d1
    cmpl %d0,%d1
    jbls rsrc_DRVR_m16511__Backlight_61C_44
rsrc_DRVR_m16511__Backlight_61C_2E:  /* test %d6 */
    tstb %d6
    jbne rsrc_DRVR_m16511__Backlight_61C_4C
    moveal %a3@,%a0
    moveq #0,%d0
    moveb %a0@(82),%d0
    moveq #0,%d1
    movew %a4@(62),%d1
    cmpl %d0,%d1
    jbhi rsrc_DRVR_m16511__Backlight_61C_4C
rsrc_DRVR_m16511__Backlight_61C_44:  /* set %a0 */
    moveal %a3@,%a0
    moveq #1,%d7
    andb %a0@(15),%d7
rsrc_DRVR_m16511__Backlight_61C_4C:  /* test %d7 */
    tstb %d7
    jbeq rsrc_DRVR_m16511__Backlight_61C_54
    moveq #0,%d0
    jbra rsrc_DRVR_m16511__Backlight_61C_56
rsrc_DRVR_m16511__Backlight_61C_54:  /* set %d0 */
    moveq #1,%d0
rsrc_DRVR_m16511__Backlight_61C_56:  /* restore registers, return */
    moveml %sp@+,%d6-%d7/%a3-%a4
    rts

rsrc_DRVR_m16511__Backlight_678:  /* save registers */
    moveml %d7/%a3,%sp@-
    moveal %sp@(12),%a3
    btst #6,%a3@(35)
    sne %d0
    andiw #1,%d0
    extl %d0
    movel %d0,%d7
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_61C)
    andib #0xbf,%a3@(35)
    lslb #6,%d0
    andib #64,%d0
    orb %d0,%a3@(35)
    btst #6,%a3@(35)
    sne %d0
    andiw #1,%d0
    extl %d0
    cmpl %d0,%d7
    addql #4,%sp
    jbeq rsrc_DRVR_m16511__Backlight_678_5E
    bset #7,%a3@(35)
    btst #6,%a3@(35)
    jbeq rsrc_DRVR_m16511__Backlight_678_56
    movel %a3@(70),%d0
    jbra rsrc_DRVR_m16511__Backlight_678_5A
rsrc_DRVR_m16511__Backlight_678_56:  /* set %d0 */
    movel %a3@(74),%d0
rsrc_DRVR_m16511__Backlight_678_5A:  /* set %a3@(66) */
    movel %d0,%a3@(66)
rsrc_DRVR_m16511__Backlight_678_5E:  /* restore registers, return */
    moveml %sp@+,%d7/%a3
    rts
rsrc_DRVR_m16511__Backlight_678_64:  /* set %sp@- */
    movel %a0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_440)
    moveal %sp@+,%a0
    rts

rsrc_DRVR_m16511__Backlight_6E6:  /* save registers */
    moveml %d1/%a1,%sp@-
    lea %pc@(rsrc_DRVR_m16511__Backlight_72A),%a1
    movel %a0,%d1
    tstb %a1@(5)
    jbeq rsrc_DRVR_m16511__Backlight_6E6_36
    cmpiw #3,%d1
    jbeq rsrc_DRVR_m16511__Backlight_6E6_24
    tstb %a1@(4)
    jbeq rsrc_DRVR_m16511__Backlight_6E6_36
    cmpiw #5,%d1
    jbne rsrc_DRVR_m16511__Backlight_6E6_36
    jbra rsrc_DRVR_m16511__Backlight_6E6_3E
rsrc_DRVR_m16511__Backlight_6E6_24:  /* set %d1 */
    movew KeyMap_6,%d1
    rolw #1,%d1
    cmpb %a1@(5),%d1
    jbne rsrc_DRVR_m16511__Backlight_6E6_36
    st %a1@(4)
    jbra rsrc_DRVR_m16511__Backlight_6E6_3E
rsrc_DRVR_m16511__Backlight_6E6_36:  /* from here: sf %a1@(4) */
    sf %a1@(4)
    moveal %a1@,%a1
    jsr %a1@
rsrc_DRVR_m16511__Backlight_6E6_3E:  /* restore registers, return */
    moveml %sp@+,%d1/%a1
    rts
rsrc_DRVR_m16511__Backlight_72A:  /* (data) */
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 408D43DA
rsrc_DRVR_m16511__Backlight_732:  /* set %sp@- */
    movel %d0,%sp@-
    movel %a0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_F56)
    moveal %sp@+,%a0
    movel %sp@+,%d0
    moveq #0,%d0
    rts
    .short  0x0000, 0x001E, 0x0001, 0x0203, 0x0405, 0x0607, 0x0809	| 408D43F2
    .long   0x0A0B0C0D, 0x0E0F1011, 0x12131415, 0x1617191C	| 408D4400
    .short  0x2024, 0x282D, 0x3200	| 408D4410
rsrc_DRVR_m16511__Backlight_766:  /* (data) */
    .short  0x0000, 0x001E, 0x0002, 0x0507, 0x090B	| 408D4416
    .long   0x0D0F1113, 0x1517191B, 0x1D1F2123, 0x25272A2D	| 408D4420
    .long   0x3033363A, 0x3E42464B, 0x50000000, 0x001F0001	| 408D4430
    .long   0x02030405, 0x06070809, 0x0A0B0C0D, 0x0E0F1011	| 408D4440
    .long   0x12131415, 0x16171819, 0x1A1B1C1D, 0x1E1F0000	| 408D4450
    .long   0x001F1F1E, 0x1D1C1B1A, 0x19181716, 0x15141312	| 408D4460
    .long   0x11100F0E, 0x0D0C0B0A, 0x09080706, 0x05040302	| 408D4470
    .long   0x01000000, 0x001F1F1E, 0x1E1D1C1C, 0x1B1A1919	| 408D4480
    .long   0x18171616, 0x15141413, 0x12111110, 0x0F0E0E0D	| 408D4490
    .long   0x0C0B0B0B, 0x0A0A001E, 0x000F000F, 0x00070003	| 408D44A0
    .short  0x001F, 0x000F, 0x000F, 0x0007, 0x0003	| 408D44B0
rsrc_DRVR_m16511__Backlight_80A:  /* (data) */
    orib #1,%d0
    orib #2,%d1
    .short  0x0003, 0x0000	| orib #0,%d3
    .short  0x001F, 0x7F59	| orib #89,%sp@+
    subqw #3,%fp@
    addqw #2,%a2@
    subqw #8,%sp
    .short  0x4D4C	| .short 0x4d4c
    tstw %d7
    .short  0x4543	| .short 0x4543
    clrw %d0
    .short  0x3E3D, 0x3B39, 0x3836, 0x3433, 0x312F, 0x2E2C, 0x2A29, 0x2726	| 408D44D8
    .short  0x0000, 0x0003, 0x0302, 0x0100, 0x0003, 0x0002, 0x0002, 0x0001	| 408D44E8
    .short  0x0000, 0x4E75	| 408D44F8
rsrc_DRVR_m16511__Backlight_84C:  /* (data) */
    .long   0x00040000	| 408D44FC
    .long   0x003E0012, 0x00000074, 0x00200000, 0x014C0021	| 408D4500
    .long   0x0000014C, 0x00170000, 0x014C001A, 0x0000014C	| 408D4510
    .long   0x00130000, 0x00AA000F, 0x000000AA, 0x001B0000	| 408D4520
    .long   0x00E0001C, 0x000000E0, 0xFFFF0000, 0x00040000	| 408D4530
    .long   0x075E0000, 0x08EE0000, 0x05AA0000, 0x09CC0000	| 408D4540
    .long   0x0A0A0000, 0x0AB6FFFF, 0xFFC0FFFF, 0xFF6CFFFF	| 408D4550
    .long   0xFEB8FFFF, 0xFEB80000, 0x02A60001, 0x00000000	| 408D4560
    .long   0x0000000C, 0x00000460, 0x000001EC, 0x0000039C	| 408D4570
    .long   0x000003E6, 0x00000406, 0xFFFFFB7C, 0xFFFFFF8A	| 408D4580
    .long   0xFFFFFF40, 0xFFFFFECA, 0xFFFFFECA, 0x00000242	| 408D4590
    .long   0x000A0000, 0x00000000, 0x001C0000, 0x042A0000	| 408D45A0
    .long   0x01B60000, 0x02180000, 0x03B00000, 0x03D0FFFF	| 408D45B0
    .long   0xFB46FFFF, 0xFD82FFFF, 0xFF0AFFFF, 0xFEDCFFFF	| 408D45C0
    .long   0xFEB80000, 0x023A000A, 0x00A300AD, 0x0000003C	| 408D45D0
    .long   0x000003F4, 0x00000180, 0x00000330, 0x0000037A	| 408D45E0
    .long   0x0000039A, 0xFFFFFB10, 0xFFFFFD4C, 0xFFFFFED4	| 408D45F0
    .long   0xFFFFFEA6, 0xFFFFFE82, 0x00000204, 0x000A00A3	| 408D4600
    .long   0x00AD0000, 0x001C0000, 0x03F40000, 0x01800000	| 408D4610
    .long   0x02F00000, 0x037A0000, 0x039AFFFF, 0xFB100000	| 408D4620
    .long   0x0000FFFF, 0xFF14FFFF, 0xFF0CFFFF, 0xFF0C0000	| 408D4630
    .long   0x0204000A, 0x00000000, 0x0000001C	| 408D4640
    .long   0x00000388 /* number, not an address (F1) */	| 408D464C
    .long   0x00000114 /* number, not an address (F1) */	| 408D4650
    .long   0x000002C4 /* number, not an address (F1) */	| 408D4654
    .long   0x0000030E /* number, not an address (F1) */	| 408D4658
    .long   0x0000032E /* number, not an address (F1) */	| 408D465C
    .byte   0xFF, 0xFF, 0xFA, 0xA4, 0xFF, 0xFF, 0xFE, 0xB2, 0xFF, 0xFF, 0xFE, 0x68, 0xFF, 0xFF, 0xFE, 0x7C	| 408D4660
    .byte   0xFF, 0xFF, 0xFE, 0x7C, 0x00, 0x00, 0x01, 0xA4, 0x00, 0x0A, 0x00, 0x00, 0x00, 0x00	| 408D4670
rsrc_DRVR_m16511__Backlight_84C_182:/* Power Manager command 216: one byte out (fp-2), one byte back (fp-1); d0 = that byte, 0 on error */
    linkw %fp,#-14	| 408D467E
    movel %d7,%sp@-
    moveb %fp@(11),%fp@(-2)
    movew #216,%fp@(-14)
    movew #1,%fp@(-12)
    lea %fp@(-2),%a0
    movel %a0,%fp@(-10)
    lea %fp@(-1),%a0
    movel %a0,%fp@(-6)
    subql #2,%sp
    pea %fp@(-14)
    moveal %sp@+,%a0
    _PMgrOp
    movew %d0,%sp@
    movew %sp@+,%d7
    beqs rsrc_DRVR_m16511__Backlight_84C_1BE
    moveq #0,%d0
    jbra rsrc_DRVR_m16511__Backlight_A10
rsrc_DRVR_m16511__Backlight_84C_1BE:
    moveq #0,%d0	| 408D46BA
    moveb %fp@(-1),%d0
rsrc_DRVR_m16511__Backlight_A10:  /* set %d7 */
    movel %fp@(-18),%d7
    unlk %fp
    rts

rsrc_DRVR_m16511__Backlight_A18:  /* from here: linkw %fp,#-14 */
    linkw %fp,#-14
    movel %d7,%sp@-
    moveb %fp@(11),%fp@(-2)
    movew #217,%fp@(-14)
    movew #1,%fp@(-12)
    lea %fp@(-2),%a0
    movel %a0,%fp@(-10)
    lea %fp@(-1),%a0
    movel %a0,%fp@(-6)
    subql #2,%sp
    pea %fp@(-14)
    moveal %sp@+,%a0
    _PMgrOp
    movew %d0,%sp@
    movew %sp@+,%d7
    jbeq rsrc_DRVR_m16511__Backlight_A18_3C
    moveq #0,%d0
    jbra rsrc_DRVR_m16511__Backlight_A18_42
rsrc_DRVR_m16511__Backlight_A18_3C:  /* clear %d0 */
    moveq #0,%d0
    moveb %fp@(-1),%d0
rsrc_DRVR_m16511__Backlight_A18_42:  /* set %d7 */
    movel %fp@(-18),%d7
    unlk %fp
    rts

rsrc_DRVR_m16511__Backlight_A62:  /* from here: linkw %fp,#-16 */
    linkw %fp,#-16
    moveml %d7/%a3,%sp@-
    lea %fp@(-4),%a3
    movew #105,%fp@(-16)
    clrw %fp@(-14)
    moveq #0,%d0
    movel %d0,%fp@(-12)
    movel %a3,%fp@(-8)
    subql #2,%sp
    pea %fp@(-16)
    moveal %sp@+,%a0
    _PMgrOp
    movew %d0,%sp@
    movew %sp@+,%d7
    jbeq rsrc_DRVR_m16511__Backlight_A62_34
    moveq #0,%d0
    jbra rsrc_DRVR_m16511__Backlight_A62_40
rsrc_DRVR_m16511__Backlight_A62_34:  /* set %d0 */
    movew %fp@(10),%d0
    moveq #0,%d1
    moveb %a3@(0x0,%d0:w),%d1
    movel %d1,%d0
rsrc_DRVR_m16511__Backlight_A62_40:  /* restore registers, return */
    moveml %fp@(-24),%d7/%a3
    unlk %fp
    rts

rsrc_DRVR_m16511__Backlight_AAC:  /* save registers */
    moveml %d7/%a3,%sp@-
    moveal %sp@(12),%a3
    moveal %a3@(100),%a0
    jsr %a0@
    movel %d0,%d7
    movew %a3@(98),%d0
    extl %d0
    subl %d7,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_13E2)
    moveq #5,%d1
    cmpl %d0,%d1
    addql #4,%sp
    jblt rsrc_DRVR_m16511__Backlight_AAC_2E
    movew %a3@(98),%d0
    extl %d0
    movel %d0,%d7
rsrc_DRVR_m16511__Backlight_AAC_2E:  /* set %a3@(98) */
    movew %d7,%a3@(98)
    lsrl #3,%d7
    tstl %d7
    jbeq rsrc_DRVR_m16511__Backlight_AAC_4E
    movew %a3@(84),%d0
    addw %d0,%d0
    lea %pc@(rsrc_DRVR_m16511__Backlight_80A),%a0
    movew %a0@(0x0,%d0:w),%d0
    lsrl %d0,%d7
    tstl %d7
    jbne rsrc_DRVR_m16511__Backlight_AAC_4E
    moveq #1,%d7
rsrc_DRVR_m16511__Backlight_AAC_4E:  /* set %d0 */
    movel %d7,%d0
    moveml %sp@+,%d7/%a3
    rts
    moveq #2,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_A62)
    addql #4,%sp
    rts

rsrc_DRVR_m16511__Backlight_B0E:  /* set %sp@- */
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    moveq #2,%d0
    andb 0x50fb4000,%d0
    jbne rsrc_DRVR_m16511__Backlight_B0E_16
    bset #5,%a3@(35)
rsrc_DRVR_m16511__Backlight_B0E_16:  /* set %sp@- */
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_C5C)
    addql #4,%sp
    moveal %sp@+,%a3
    rts
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_84C_182)	| 408D47E4
    addql #4,%sp
    rts
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_A18)
    addql #4,%sp
    rts

rsrc_DRVR_m16511__Backlight_B48:  /* save registers */
    moveml %d5-%d7/%a3,%sp@-
    movel %sp@(20),%d7
    moveal %sp@(24),%a3
    moveal %a3@(78),%a0
    movew %a3@(84),%d0
    extl %d0
    addl %d0,%d0
    movew %a0@(0x0,%d0:l),%d0
    extl %d0
    cmpl %d7,%d0
    jbge rsrc_DRVR_m16511__Backlight_B48_36
    moveal %a3@(78),%a0
    movew %a3@(84),%d0
    extl %d0
    addl %d0,%d0
    movew %a0@(0x0,%d0:l),%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_B48_4E
rsrc_DRVR_m16511__Backlight_B48_36:  /* set %a0 */
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    cmpl %d7,%d0
    jble rsrc_DRVR_m16511__Backlight_B48_4C
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_B48_4E
rsrc_DRVR_m16511__Backlight_B48_4C:  /* set %d0 */
    movel %d7,%d0
rsrc_DRVR_m16511__Backlight_B48_4E:  /* set %d7 */
    movel %d0,%d7
    moveal %a3@(66),%a0
    moveb %a0@(0x4,%d7:l),%d6
    moveq #0,%d0
    moveb %d6,%d0
    movew %a3@(92),%d1
    extl %d1
    cmpl %d1,%d0
    jbne rsrc_DRVR_m16511__Backlight_B48_6A
    movel %d7,%d0
    jbra rsrc_DRVR_m16511__Backlight_B48_90
rsrc_DRVR_m16511__Backlight_B48_6A:  /* clear %d0 */
    moveq #0,%d0
    moveb %d6,%d0
    movew %d0,%a3@(92)
    lslb #2,%d6
    moveb 0x50f96c00,%d5
    andib #0xf2,%d5
    orb %d5,%d6
    tstl %d7
    jbeq rsrc_DRVR_m16511__Backlight_B48_88
    orib #1,%d6
rsrc_DRVR_m16511__Backlight_B48_88:  /* set 0x50f96c00 */
    moveb %d6,0x50f96c00
    movel %d7,%d0
rsrc_DRVR_m16511__Backlight_B48_90:  /* restore registers, return */
    moveml %sp@+,%d5-%d7/%a3
    rts

rsrc_DRVR_m16511__Backlight_BDE:  /* save registers */
    moveml %d7/%a3,%sp@-
    moveal %sp@(12),%a3
    movew %a3@(84),%d0
    subqw #1,%d0
    jbmi rsrc_DRVR_m16511__Backlight_C12
    cmpiw #3,%d0
    jbgt rsrc_DRVR_m16511__Backlight_C12
    addw %d0,%d0
    movew %pc@(rsrc_DRVR_m16511__Backlight_BFE,%d0:w),%d0
rsrc_DRVR_m16511__Backlight_BDE_1C:  /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
rsrc_DRVR_m16511__Backlight_BFE:  /* (data) */
    .short  rsrc_DRVR_m16511__Backlight_C06-DSPTABLE_153C	| 408D48AE
    .short  rsrc_DRVR_m16511__Backlight_C06-DSPTABLE_153C	| 408D48B0
    .short  rsrc_DRVR_m16511__Backlight_C0A-DSPTABLE_153C	| 408D48B2
    .short  rsrc_DRVR_m16511__Backlight_C0E-DSPTABLE_153C	| 408D48B4

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_C06:
    moveq #2,%d7
    jbra rsrc_DRVR_m16511__Backlight_C14

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_C0A:
    moveq #1,%d7
    jbra rsrc_DRVR_m16511__Backlight_C14

/* subroutine (26 instructions): calls rsrc_DRVR_m16511__Backlight_D20, rsrc_DRVR_m16511__Backlight_C5C (mechanical summary) */
rsrc_DRVR_m16511__Backlight_C0E:
    moveq #0,%d7
    jbra rsrc_DRVR_m16511__Backlight_C14
rsrc_DRVR_m16511__Backlight_C12:  /* set %d7 */
    moveq #3,%d7
rsrc_DRVR_m16511__Backlight_C14:  /* set %d0 */
    movel %d7,%d0
    moveml %sp@+,%d7/%a3
    rts

rsrc_DRVR_m16511__Backlight_C1C:  /* set %sp@- */
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    orib #1,0x50f96c00
    moveq #2,%d0
    andb 0x50f96c00,%d0
    jbeq rsrc_DRVR_m16511__Backlight_C1C_34
    movel %a3,%sp@-
    moveq #29,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_D20)
    lea %pc@(rsrc_DRVR_m16511__Backlight_B48),%a0
    movel %a0,%a3@(36)
    lea %pc@(rsrc_DRVR_m16511__Backlight_BDE),%a0
    movel %a0,%a3@(40)
    addql #8,%sp
rsrc_DRVR_m16511__Backlight_C1C_34:  /* set %sp@- */
    movel %a3,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_C5C)
    addql #4,%sp
    moveal %sp@+,%a3
    rts

/* subroutine (52 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_C5C:
    moveml %d7/%a3,%sp@-
    moveal %sp@(12),%a3
    btst #5,%a3@(35)
    jbeq rsrc_DRVR_m16511__Backlight_C5C_20
    movew #1,%a3@(60)
    movel %a3,%sp@-
    moveal %a3@(56),%a0
    jsr %a0@
    addql #4,%sp
rsrc_DRVR_m16511__Backlight_C5C_20:  /* set %sp@- */
    movel %a3,%sp@-
    moveal %a3@(40),%a0
    jsr %a0@
    movel %d0,%d7
    movew #-1,%a3@(90)
    movel %a3,%sp@-
    movel %d7,%sp@-
    moveal %a3@(36),%a0
    jsr %a0@
    movew %d0,%a3@(90)
    moveq #0,%d0
    lea %sp@(12),%sp
    moveml %sp@+,%d7/%a3
    rts

rsrc_DRVR_m16511__Backlight_CA6:  /* set %sp@- */
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    movel %a3,%sp@-
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    movel %d0,%sp@-
    moveal %a3@(36),%a0
    jsr %a0@
    moveq #0,%d0
    addql #8,%sp
    moveal %sp@+,%a3
    rts

rsrc_DRVR_m16511__Backlight_CC6:  /* save registers */
    moveml %d6-%d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a4
    moveal %sp@(24),%a3
    moveq #0,%d7
    btst #0,%a3@(35)
    jbne rsrc_DRVR_m16511__Backlight_CC6_1A
    moveq #-17,%d7
    jbra rsrc_DRVR_m16511__Backlight_D18
rsrc_DRVR_m16511__Backlight_CC6_1A:  /* set %d0 */
    movew %a4@(26),%d0
    subiw #17153,%d0
    jbmi rsrc_DRVR_m16511__Backlight_D16
    cmpiw #0,%d0
    jbgt rsrc_DRVR_m16511__Backlight_D16
    addw %d0,%d0
    movew %pc@(rsrc_DRVR_m16511__Backlight_CFA,%d0:w),%d0
rsrc_DRVR_m16511__Backlight_CC6_30:  /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
rsrc_DRVR_m16511__Backlight_CFA:  /* (data) */
    .short  rsrc_DRVR_m16511__Backlight_CFC-DSPTABLE_1638	| 408D49AA

/* subroutine (14 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_CFC:
    movew %a4@(28),%d0
    extl %d0
    movel %d0,%d6
    movel %a3,%sp@-
    movel %d6,%sp@-
    moveal %a3@(36),%a0
    jsr %a0@
    movew %d0,%a3@(90)
    addql #8,%sp
    jbra rsrc_DRVR_m16511__Backlight_D18
rsrc_DRVR_m16511__Backlight_D16:  /* set %d7 */
    moveq #-17,%d7
rsrc_DRVR_m16511__Backlight_D18:  /* set %d0 */
    movew %d7,%d0
    moveml %sp@+,%d6-%d7/%a3-%a4
    rts

/* subroutine (168 instructions): traps PMgrOp, Sleep, ShutDown; calls rsrc_DRVR_m16511__Backlight_13E2, rsrc_DRVR_m16511__Backlight_592, rsrc_DRVR_m16511__Backlight_13AC, rsrc_DRVR_m16511__Backlight_5C2, rsrc_DRVR_m16511__Backlight_FE8 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_D20:
    linkw %fp,#-14
    moveml %d7/%a3,%sp@-
    movel %fp@(8),%d7
    moveal %fp@(12),%a3
    moveal %a3@(78),%a0
    movew %a3@(84),%d0
    extl %d0
    addl %d0,%d0
    movew %a0@(0x0,%d0:l),%d0
    extl %d0
    cmpl %d7,%d0
    jbge rsrc_DRVR_m16511__Backlight_D20_3A
    moveal %a3@(78),%a0
    movew %a3@(84),%d0
    extl %d0
    addl %d0,%d0
    movew %a0@(0x0,%d0:l),%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_D20_52
rsrc_DRVR_m16511__Backlight_D20_3A:  /* set %a0 */
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    cmpl %d7,%d0
    jble rsrc_DRVR_m16511__Backlight_D20_50
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_D20_52
rsrc_DRVR_m16511__Backlight_D20_50:  /* set %d0 */
    movel %d7,%d0
rsrc_DRVR_m16511__Backlight_D20_52:  /* set %d7 */
    movel %d0,%d7
    moveal %a3@(66),%a0
    moveb %a0@(0x4,%d7:l),%fp@(-1)
    tstw %a3@(90)
    jblt rsrc_DRVR_m16511__Backlight_D20_7A
    moveq #0,%d0
    moveb %fp@(-1),%d0
    movew %a3@(92),%d1
    extl %d1
    cmpl %d0,%d1
    jbne rsrc_DRVR_m16511__Backlight_D20_7A
    movel %d7,%d0
    jbra rsrc_DRVR_m16511__Backlight_D20_10A
rsrc_DRVR_m16511__Backlight_D20_7A:  /* test bit 7 of %a3@(35) */
    btst #7,%a3@(35)
    jbeq rsrc_DRVR_m16511__Backlight_D20_D6
    movew %a3@(92),%d0
    extl %d0
    moveq #0,%d1
    moveb %fp@(-1),%d1
    subl %d1,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_13E2)
    movew %a3@(60),%d1
    extl %d1
    cmpl %d0,%d1
    addql #4,%sp
    jbge rsrc_DRVR_m16511__Backlight_D20_D0
    movew %a3@(92),%d0
    extl %d0
    moveq #0,%d1
    moveb %fp@(-1),%d1
    movew %a3@(92),%d2
    extl %d2
    cmpl %d2,%d1
    jbge rsrc_DRVR_m16511__Backlight_D20_C2
    movew %a3@(60),%d1
    negw %d1
    extl %d1
    jbra rsrc_DRVR_m16511__Backlight_D20_C8
rsrc_DRVR_m16511__Backlight_D20_C2:  /* set %d1 */
    movew %a3@(60),%d1
    extl %d1
rsrc_DRVR_m16511__Backlight_D20_C8:  /* from here: addl %d0,%d1 */
    addl %d0,%d1
    moveb %d1,%fp@(-1)
    jbra rsrc_DRVR_m16511__Backlight_D20_D6
rsrc_DRVR_m16511__Backlight_D20_D0:  /* clear bit 7 of %a3@(35) */
    bclr #7,%a3@(35)
rsrc_DRVR_m16511__Backlight_D20_D6:  /* clear %d0 */
    moveq #0,%d0
    moveb %fp@(-1),%d0
    movew %d0,%a3@(92)
    movew #65,%fp@(-14)
    movew #1,%fp@(-12)
    lea %fp@(-1),%a0
    movel %a0,%fp@(-10)
    moveq #0,%d0
    movel %d0,%fp@(-6)
    subql #2,%sp
    pea %fp@(-14)
    moveal %sp@+,%a0
    _PMgrOp
    movew %d0,%sp@
    movel %d7,%d0
    addql #2,%sp
rsrc_DRVR_m16511__Backlight_D20_10A:  /* restore registers, return */
    moveml %fp@(-22),%d7/%a3
    unlk %fp
    rts

rsrc_DRVR_m16511__Backlight_E34:  /* save registers */
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(16),%a3
    lea %pc@(rsrc_DRVR_m16511__Backlight_72A),%a4
    clrb %a4@(4)
    clrb %a4@(5)
    moveq #2,%d0
    andb 0xfc0200,%d0
    jbeq rsrc_DRVR_m16511__Backlight_E34_26
    lea %pc@(rsrc_DRVR_m16511__Backlight_766),%a0
    movel %a0,%a3@(66)
rsrc_DRVR_m16511__Backlight_E34_26:  /* set %d0 */
    moveq #5,%d0
    movel %d0,%sp@-
    pea 0xe0
    jsr %pc@(rsrc_DRVR_m16511__Backlight_592)
    movew %d0,%a3@(96)
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #31,%d1
    movel %d1,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_592)
    movel %d0,%d7
    subql #1,%d7
    movew %a3@(96),%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_13AC)
    tstl %d7
    lea %sp@(20),%sp
    jbcc rsrc_DRVR_m16511__Backlight_E34_82
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    movel %d0,%d7
    addql #1,%d7
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #31,%d1
    movel %d1,%sp@-
    moveal %a3@(66),%a0
    movew %a0@,%d2
    extl %d2
    addql #2,%d2
    movel %d2,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_5C2)
    lea %sp@(12),%sp
rsrc_DRVR_m16511__Backlight_E34_82:  /* set %a0 */
    moveal %a3@(66),%a0
    movew %a0@(2),%a3@(90)
    movel %a3,%sp@-
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_FE8)
    movew %d0,%a3@(90)
    movel %a3,%sp@-
    movel %d7,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_FE8)
    movew %d0,%a3@(90)
    cmpib #0xa3,0xfc0200
    lea %sp@(16),%sp
    jbne rsrc_DRVR_m16511__Backlight_E34_D0
    movew #16,%a3@(4)
    lea %pc@(rsrc_DRVR_m16511__Backlight_732),%a0
    movel %a0,%a3@(6)
    movel %a3,%sp@-
    moveal %sp@+,%a0
    .short  0xA28A	| 408D4BB0 _Sleep (flags 0x0200)
    addql #4,%sp
rsrc_DRVR_m16511__Backlight_E34_D0:  /* from here: pea %pc@(rsrc_DRVR_m16511__Backlight_F1A_30) */
    pea %pc@(rsrc_DRVR_m16511__Backlight_F1A_30)
    moveq #3,%d0
    movew %d0,%sp@-
    movew #3,%sp@-
    _ShutDown
    moveq #0,%d0
    moveml %sp@+,%d7/%a3-%a4
    rts

/* subroutine (17 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_F1A:
    moveml %d5-%d7/%a3,%sp@-
    moveal %sp@(20),%a3
    movel %sp@(24),%d5
    moveb %sp@(31),%d6
    tstl %d5
    jbeq rsrc_DRVR_m16511__Backlight_F1A_2A
    orib #0x80,%d6
    movel %d5,%d7
    lsll #1,%d7
    jbra rsrc_DRVR_m16511__Backlight_F1A_26
rsrc_DRVR_m16511__Backlight_F1A_1E:  /* loop: eori */
    eorib #0x80,%d6
    moveb %d6,%a3@
    subql #1,%d7
rsrc_DRVR_m16511__Backlight_F1A_26:  /* test %d7 */
    tstl %d7
    jbne rsrc_DRVR_m16511__Backlight_F1A_1E
rsrc_DRVR_m16511__Backlight_F1A_2A:  /* restore registers, return */
    moveml %sp@+,%d5-%d7/%a3
    rts

/* subroutine (5 instructions): calls rsrc_DRVR_m16511__Backlight_FB2 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_F1A_30:
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_FB2)
    addql #4,%sp
    rts

/* subroutine (11 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_F56:
    linkw %fp,#0
    movel %a3,%sp@-
    moveal %fp@(8),%a3
    movel %fp@(12),%d0
    subql #1,%d0
    jbmi rsrc_DRVR_m16511__Backlight_FAA
    cmpil #3,%d0
    jbgt rsrc_DRVR_m16511__Backlight_FAA
    addl %d0,%d0
    movew %pc@(rsrc_DRVR_m16511__Backlight_F7A,%d0:l),%d0
rsrc_DRVR_m16511__Backlight_F56_20:  /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
rsrc_DRVR_m16511__Backlight_F7A:  /* (data) */
    .short  rsrc_DRVR_m16511__Backlight_FAA-(rsrc_DRVR_m16511__Backlight_F56_20+2)	| 408D4C2A
    .short  rsrc_DRVR_m16511__Backlight_F82-(rsrc_DRVR_m16511__Backlight_F56_20+2)	| 408D4C2C
    .short  rsrc_DRVR_m16511__Backlight_F94-(rsrc_DRVR_m16511__Backlight_F56_20+2)	| 408D4C2E
    .short  rsrc_DRVR_m16511__Backlight_FAA-(rsrc_DRVR_m16511__Backlight_F56_20+2)	| 408D4C30

/* subroutine (6 instructions): calls rsrc_DRVR_m16511__Backlight_FB2 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_F82:
    bclr #2,%a3@(35)
    moveq #0,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_FB2)
    addql #4,%sp
    jbra rsrc_DRVR_m16511__Backlight_FAA

/* subroutine (7 instructions): calls rsrc_DRVR_m16511__Backlight_FB2 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_F94:
    tstw %a3@(90)
    jbeq rsrc_DRVR_m16511__Backlight_FA4
    moveq #1,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_FB2)
    addql #4,%sp
rsrc_DRVR_m16511__Backlight_FA4:  /* set bit 2 of %a3@(35) */
    bset #2,%a3@(35)

/* subroutine (3 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_FAA:
    moveal %fp@(-4),%a3
    unlk %fp
    rts

/* subroutine (18 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_FB2:
    moveml %d5-%d7/%a3,%sp@-
    moveb %sp@(23),%d5
    moveal #16515586,%a3
    moveq #4,%d7
    andb 0xfc0200,%d7
    moveb #0xa0,%d6
    tstb %d7
    jbeq rsrc_DRVR_m16511__Backlight_FB2_22
    tstb %d5
    jbne rsrc_DRVR_m16511__Backlight_FB2_2A
rsrc_DRVR_m16511__Backlight_FB2_22:  /* test %d7 */
    tstb %d7
    jbne rsrc_DRVR_m16511__Backlight_FB2_2E
    tstb %d5
    jbne rsrc_DRVR_m16511__Backlight_FB2_2E
rsrc_DRVR_m16511__Backlight_FB2_2A:  /* from here: orib #2,%d6 */
    orib #2,%d6
rsrc_DRVR_m16511__Backlight_FB2_2E:  /* set %a3@ */
    moveb %d6,%a3@
    moveml %sp@+,%d5-%d7/%a3
    rts

/* subroutine (118 instructions): calls rsrc_DRVR_m16511__Backlight_13E2, rsrc_DRVR_m16511__Backlight_F1A (mechanical summary) */
rsrc_DRVR_m16511__Backlight_FE8:
    linkw %fp,#-6
    moveml %d4-%d7/%a3-%a4,%sp@-
    movel %fp@(8),%d7
    moveal %fp@(12),%a3
    tstw %a3@(90)
    slt %d4
    negb %d4
    moveal %a3@(78),%a0
    movew %a3@(84),%d0
    extl %d0
    addl %d0,%d0
    movew %a0@(0x0,%d0:l),%d0
    extl %d0
    cmpl %d7,%d0
    jbge rsrc_DRVR_m16511__Backlight_FE8_42
    moveal %a3@(78),%a0
    movew %a3@(84),%d0
    extl %d0
    addl %d0,%d0
    movew %a0@(0x0,%d0:l),%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_FE8_5A
rsrc_DRVR_m16511__Backlight_FE8_42:  /* set %a0 */
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    cmpl %d7,%d0
    jble rsrc_DRVR_m16511__Backlight_FE8_58
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_FE8_5A
rsrc_DRVR_m16511__Backlight_FE8_58:  /* set %d0 */
    movel %d7,%d0
rsrc_DRVR_m16511__Backlight_FE8_5A:  /* set %d7 */
    movel %d0,%d7
    tstb %d4
    jbeq rsrc_DRVR_m16511__Backlight_FE8_6A
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    jbra rsrc_DRVR_m16511__Backlight_FE8_70
rsrc_DRVR_m16511__Backlight_FE8_6A:  /* set %d0 */
    movew %a3@(90),%d0
    extl %d0
rsrc_DRVR_m16511__Backlight_FE8_70:  /* set %fp@(-4) */
    movel %d0,%fp@(-4)
    moveal %a3@(66),%a0
    moveb %a0@(0x4,%d7:l),%d5
    tstb %d4
    jbne rsrc_DRVR_m16511__Backlight_FE8_94
    moveq #0,%d0
    moveb %d5,%d0
    movew %a3@(92),%d1
    extl %d1
    cmpl %d0,%d1
    jbne rsrc_DRVR_m16511__Backlight_FE8_94
    movel %d7,%d0
    jbra rsrc_DRVR_m16511__Backlight_FE8_13C
rsrc_DRVR_m16511__Backlight_FE8_94:  /* set %d6 */
    moveb 0xfc0200,%d6
    moveq #4,%d0
    andb %d6,%d0
    moveb %d0,%fp@(-5)
    moveq #1,%d4
    andb %d6,%d4
    moveal #16515586,%a4
    moveb #0xa0,%d6
    tstb %fp@(-5)
    jbeq rsrc_DRVR_m16511__Backlight_FE8_C2
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    cmpl %d7,%d0
    jbne rsrc_DRVR_m16511__Backlight_FE8_D4
rsrc_DRVR_m16511__Backlight_FE8_C2:  /* test %fp@(-5) */
    tstb %fp@(-5)
    jbne rsrc_DRVR_m16511__Backlight_FE8_D8
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    cmpl %d7,%d0
    jbne rsrc_DRVR_m16511__Backlight_FE8_D8
rsrc_DRVR_m16511__Backlight_FE8_D4:  /* from here: orib #2,%d6 */
    orib #2,%d6
rsrc_DRVR_m16511__Backlight_FE8_D8:  /* test %d4 */
    tstb %d4
    jbeq rsrc_DRVR_m16511__Backlight_FE8_E2
    cmpl %fp@(-4),%d7
    jble rsrc_DRVR_m16511__Backlight_FE8_EC
rsrc_DRVR_m16511__Backlight_FE8_E2:  /* test %d4 */
    tstb %d4
    jbne rsrc_DRVR_m16511__Backlight_FE8_F0
    cmpl %fp@(-4),%d7
    jblt rsrc_DRVR_m16511__Backlight_FE8_F0
rsrc_DRVR_m16511__Backlight_FE8_EC:  /* from here: orib #64,%d6 */
    orib #64,%d6
rsrc_DRVR_m16511__Backlight_FE8_F0:  /* set %a0 */
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    cmpl %d7,%d0
    jbne rsrc_DRVR_m16511__Backlight_FE8_104
    movel #256,%d0
    jbra rsrc_DRVR_m16511__Backlight_FE8_116
rsrc_DRVR_m16511__Backlight_FE8_104:  /* set %d0 */
    movew %a3@(92),%d0
    extl %d0
    moveq #0,%d1
    moveb %d5,%d1
    subl %d1,%d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_13E2)
rsrc_DRVR_m16511__Backlight_FE8_116:  /* set %d4 */
    movel %d0,%d4
    andib #0xdf,%d6
    moveb %d6,%a4@
    moveq #0,%d0
    moveb %d6,%d0
    movel %d0,%sp@-
    movel %d4,%sp@-
    movel %a4,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_F1A)
    orib #32,%d6
    moveb %d6,%a4@
    moveq #0,%d0
    moveb %d5,%d0
    movew %d0,%a3@(92)
    movel %d7,%d0
rsrc_DRVR_m16511__Backlight_FE8_13C:  /* restore registers, return */
    moveml %fp@(-30),%d4-%d7/%a3-%a4
    unlk %fp
    rts

/* subroutine (139 instructions): traps GetKeys, Sleep, ShutDown; calls rsrc_DRVR_m16511__Backlight_112E, rsrc_DRVR_m16511__Backlight_FE8 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_112E:
    moveml %d6-%d7/%a3,%sp@-
    movel %sp@(16),%d6
    moveal %sp@(20),%a3
    tstl %d6
    jbne rsrc_DRVR_m16511__Backlight_112E_14
    moveq #0,%d0
    jbra rsrc_DRVR_m16511__Backlight_112E_44
rsrc_DRVR_m16511__Backlight_112E_14:  /* clear %d7 */
    moveq #0,%d7
    moveb %a3@(7),%d0
    extw %d0
    extl %d0
    movel #136,%d1
    andl %d0,%d1
    jbeq rsrc_DRVR_m16511__Backlight_112E_2A
    addql #1,%d7
rsrc_DRVR_m16511__Backlight_112E_2A:  /* set %d0 */
    moveq #17,%d0
    andb %a3@(7),%d0
    jbeq rsrc_DRVR_m16511__Backlight_112E_34
    addql #2,%d7
rsrc_DRVR_m16511__Backlight_112E_34:  /* set %d0 */
    moveq #68,%d0
    andb %a3@(7),%d0
    jbeq rsrc_DRVR_m16511__Backlight_112E_3E
    addql #4,%d7
rsrc_DRVR_m16511__Backlight_112E_3E:  /* test %d7,%d6 */
    cmpl %d7,%d6
    seq %d0
    negb %d0
rsrc_DRVR_m16511__Backlight_112E_44:  /* restore registers, return */
    moveml %sp@+,%d6-%d7/%a3
    rts

rsrc_DRVR_m16511__Backlight_1178:  /* from here: linkw %fp,#-16 */
    linkw %fp,#-16
    moveml %d5-%d7/%a3-%a4,%sp@-
    lea %fp@(-16),%a4
    moveal %fp@(8),%a3
    movew %a3@(90),%d0
    extl %d0
    movel %d0,%d5
    moveal %a3@(78),%a0
    movew %a3@(84),%d0
    extl %d0
    addl %d0,%d0
    movew %a0@(0x0,%d0:l),%d0
    extl %d0
    movel %d0,%d6
    movew %a3@(90),%d0
    extl %d0
    cmpl %d0,%d6
    jbge rsrc_DRVR_m16511__Backlight_1178_3C
    movel %d6,%d0
    jbra rsrc_DRVR_m16511__Backlight_1178_D4
rsrc_DRVR_m16511__Backlight_1178_3C:  /* set up and call _GetKeys */
    movel %a4,%sp@-
    _GetKeys
    movel %a4,%sp@-
    movew %a3@(96),%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_112E)
    tstb %d0
    addql #8,%sp
    jbne rsrc_DRVR_m16511__Backlight_1178_60
    clrw %a3@(94)
    bclr #1,%a3@(35)
    jbra rsrc_DRVR_m16511__Backlight_1178_D2
rsrc_DRVR_m16511__Backlight_1178_60:  /* add 1 to %a3@(94) */
    addqw #1,%a3@(94)
    btst #1,%a3@(35)
    jbeq rsrc_DRVR_m16511__Backlight_1178_70
    moveq #5,%d0
    jbra rsrc_DRVR_m16511__Backlight_1178_72
rsrc_DRVR_m16511__Backlight_1178_70:  /* set %d0 */
    moveq #1,%d0
rsrc_DRVR_m16511__Backlight_1178_72:  /* set %d1 */
    movew %a3@(94),%d1
    extl %d1
    cmpl %d1,%d0
    jbge rsrc_DRVR_m16511__Backlight_1178_D2
    bset #1,%a3@(35)
    movew #1,%a3@(94)
    moveq #0,%d7
    moveq #64,%d0
    andb %a4@(15),%d0
    jbne rsrc_DRVR_m16511__Backlight_1178_9A
    moveq #16,%d0
    andb %a4@(15),%d0
    jbeq rsrc_DRVR_m16511__Backlight_1178_9C
rsrc_DRVR_m16511__Backlight_1178_9A:  /* set %d7 */
    moveq #1,%d7
rsrc_DRVR_m16511__Backlight_1178_9C:  /* set %d0 */
    moveq #32,%d0
    andb %a4@(15),%d0
    jbne rsrc_DRVR_m16511__Backlight_1178_AC
    moveq #8,%d0
    andb %a4@(15),%d0
    jbeq rsrc_DRVR_m16511__Backlight_1178_AE
rsrc_DRVR_m16511__Backlight_1178_AC:  /* set %d7 */
    moveq #-1,%d7
rsrc_DRVR_m16511__Backlight_1178_AE:  /* set %d0 */
    movew %a3@(90),%d0
    extl %d0
    addl %d7,%d0
    cmpl %d0,%d6
    jbge rsrc_DRVR_m16511__Backlight_1178_BC
    moveq #0,%d7
rsrc_DRVR_m16511__Backlight_1178_BC:  /* set %d0 */
    movew %a3@(90),%d0
    extl %d0
    addl %d7,%d0
    jbge rsrc_DRVR_m16511__Backlight_1178_C8
    moveq #0,%d7
rsrc_DRVR_m16511__Backlight_1178_C8:  /* set %d0 */
    movew %a3@(90),%d0
    extl %d0
    movel %d0,%d5
    addl %d7,%d5
rsrc_DRVR_m16511__Backlight_1178_D2:  /* set %d0 */
    movel %d5,%d0
rsrc_DRVR_m16511__Backlight_1178_D4:  /* restore registers, return */
    moveml %fp@(-36),%d5-%d7/%a3-%a4
    unlk %fp
    rts

rsrc_DRVR_m16511__Backlight_1256:  /* set %sp@- */
    movel %a3,%sp@-
    moveal %sp@(8),%a3
    moveal %a3@(66),%a0
    movew %a0@(2),%a3@(90)
    movel %a3,%sp@-
    moveal %a3@(66),%a0
    movew %a0@,%d0
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_FE8)
    movew %d0,%a3@(90)
    movel %a3,%sp@-
    moveal %sp@+,%a0
    .short  0xA48A	| 408D4F2E _Sleep (flags 0x0400)
    pea %pc@(rsrc_DRVR_m16511__Backlight_F1A_30)
    movew #4,%sp@-
    _ShutDown
    moveq #0,%d0
    lea %sp@(12),%sp
    moveal %sp@+,%a3
    rts

rsrc_DRVR_m16511__Backlight_1294:  /* save registers */
    moveml %d6-%d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a4
    moveal %sp@(24),%a3
    moveq #0,%d6
    movew %a4@(26),%d0
    subiw #17153,%d0
    jbmi rsrc_DRVR_m16511__Backlight_1336
    cmpiw #4,%d0
    jbgt rsrc_DRVR_m16511__Backlight_1336
    addw %d0,%d0
    movew %pc@(rsrc_DRVR_m16511__Backlight_12C0,%d0:w),%d0
rsrc_DRVR_m16511__Backlight_1294_28:  /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
rsrc_DRVR_m16511__Backlight_12C0:  /* (data) */
    .short  rsrc_DRVR_m16511__Backlight_12CA-DSPTABLE_1BFE	| 408D4F70
    .short  rsrc_DRVR_m16511__Backlight_12E4-DSPTABLE_1BFE	| 408D4F72
    .short  rsrc_DRVR_m16511__Backlight_1336-DSPTABLE_1BFE	| 408D4F74
    .short  rsrc_DRVR_m16511__Backlight_1300-DSPTABLE_1BFE	| 408D4F76
    .short  rsrc_DRVR_m16511__Backlight_131C-DSPTABLE_1BFE	| 408D4F78

/* subroutine (10 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_12CA:
    movew %a4@(28),%d0
    extl %d0
    movel %d0,%d7
    movel %a3,%sp@-
    movel %d7,%sp@-
    moveal %a3@(36),%a0
    jsr %a0@
    movew %d0,%a3@(90)
    addql #8,%sp
    jbra rsrc_DRVR_m16511__Backlight_1338

/* subroutine (11 instructions): calls rsrc_DRVR_m16511__Backlight_5C2 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_12E4:
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #31,%d1
    movel %d1,%sp@-
    movew %a3@(90),%d2
    extl %d2
    addql #1,%d2
    movel %d2,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_5C2)
    lea %sp@(12),%sp
    jbra rsrc_DRVR_m16511__Backlight_1338

/* subroutine (11 instructions): calls rsrc_DRVR_m16511__Backlight_13AC (mechanical summary) */
rsrc_DRVR_m16511__Backlight_1300:
    movew %a4@(28),%d0
    extl %d0
    movel %d0,%d7
    moveq #7,%d0
    andl %d7,%d0
    movew %d0,%a3@(96)
    extl %d0
    movel %d0,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_13AC)
    addql #4,%sp
    jbra rsrc_DRVR_m16511__Backlight_1338

/* subroutine (9 instructions): calls rsrc_DRVR_m16511__Backlight_5C2 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_131C:
    moveq #5,%d0
    movel %d0,%sp@-
    pea 0xe0
    movew %a3@(96),%d1
    extl %d1
    movel %d1,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_5C2)
    lea %sp@(12),%sp
    jbra rsrc_DRVR_m16511__Backlight_1338

/* subroutine (16 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_1336:
    moveq #-17,%d6
rsrc_DRVR_m16511__Backlight_1338:  /* set %d0 */
    movew %d6,%d0
    moveml %sp@+,%d6-%d7/%a3-%a4
    rts

rsrc_DRVR_m16511__Backlight_1340:  /* save registers */
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a4
    moveal %sp@(16),%a3
    clrw %d7
    movew %a3@(26),%d0
    subiw #21250,%d0
    jbmi rsrc_DRVR_m16511__Backlight_13A2
    cmpiw #3,%d0
    jbgt rsrc_DRVR_m16511__Backlight_13A2
    addw %d0,%d0
    movew %pc@(rsrc_DRVR_m16511__Backlight_1368,%d0:w),%d0
rsrc_DRVR_m16511__Backlight_1340_24:  /* jump through %pc@(0,%d0:w) */
    jmp %pc@(0,%d0:w)
rsrc_DRVR_m16511__Backlight_1368:  /* (data) */
    .short  rsrc_DRVR_m16511__Backlight_1370-DSPTABLE_1CA6	| 408D5018
    .short  rsrc_DRVR_m16511__Backlight_13A2-DSPTABLE_1CA6	| 408D501A
    .short  rsrc_DRVR_m16511__Backlight_1378-DSPTABLE_1CA6	| 408D501C
    .short  rsrc_DRVR_m16511__Backlight_138E-DSPTABLE_1CA6	| 408D501E

/* subroutine (2 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_1370:
    movew %a4@(96),%a3@(28)
    jbra rsrc_DRVR_m16511__Backlight_13A4

/* subroutine (9 instructions): calls rsrc_DRVR_m16511__Backlight_592 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_1378:
    moveq #0,%d0
    movel %d0,%sp@-
    moveq #31,%d1
    movel %d1,%sp@-
    jsr %pc@(rsrc_DRVR_m16511__Backlight_592)
    subql #1,%d0
    movew %d0,%a3@(28)
    addql #8,%sp
    jbra rsrc_DRVR_m16511__Backlight_13A4

/* subroutine (7 instructions): calls rsrc_DRVR_m16511__Backlight_592 (mechanical summary) */
rsrc_DRVR_m16511__Backlight_138E:
    moveq #5,%d0
    movel %d0,%sp@-
    pea 0xe0
    jsr %pc@(rsrc_DRVR_m16511__Backlight_592)
    movew %d0,%a3@(28)
    addql #8,%sp
    jbra rsrc_DRVR_m16511__Backlight_13A4

/* subroutine (4 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_13A2:
    moveq #-18,%d7
rsrc_DRVR_m16511__Backlight_13A4:  /* set %d0 */
    movew %d7,%d0
    moveml %sp@+,%d7/%a3-%a4
    rts

/* subroutine (18 instructions) (mechanical summary) */
rsrc_DRVR_m16511__Backlight_13AC:
    moveml %d6-%d7/%a3,%sp@-
    movel %sp@(16),%d6
    clrb %d7
    btst #0,%d6
    jbeq rsrc_DRVR_m16511__Backlight_13AC_14
    orib #16,%d7
rsrc_DRVR_m16511__Backlight_13AC_14:  /* set %d0 */
    moveq #2,%d0
    andl %d6,%d0
    jbeq rsrc_DRVR_m16511__Backlight_13AC_1E
    orib #2,%d7
rsrc_DRVR_m16511__Backlight_13AC_1E:  /* set %d0 */
    moveq #4,%d0
    andl %d6,%d0
    jbeq rsrc_DRVR_m16511__Backlight_13AC_28
    orib #8,%d7
rsrc_DRVR_m16511__Backlight_13AC_28:  /* address %pc@(rsrc_DRVR_m16511__Backlight_72A) */
    lea %pc@(rsrc_DRVR_m16511__Backlight_72A),%a3
    moveb %d7,%a3@(5)
    moveml %sp@+,%d6-%d7/%a3
    rts

/* subroutine (16 instructions): low memory MemErr (mechanical summary) */
rsrc_DRVR_m16511__Backlight_13E2:
    linkw %fp,#0
    movel %d7,%sp@-
    movel %fp@(8),%d7
    jblt rsrc_DRVR_m16511__Backlight_13E2_10
    movel %d7,%d0
    jbra rsrc_DRVR_m16511__Backlight_13E2_14
rsrc_DRVR_m16511__Backlight_13E2_10:  /* set %d0 */
    movel %d7,%d0
    negl %d0
rsrc_DRVR_m16511__Backlight_13E2_14:  /* set %d7 */
    movel %fp@(-4),%d7
    unlk %fp
    rts
    .short  0x8361	| 408D50AE
    .long   0x62730000, 0x225F201F, 0xA04C2E80, 0x4E717000	| 408D50B0
rsrc_DRVR_m16511__Backlight_13E2_2E:  /* set %sp@- */
    movel %a1,%sp@-
rsrc_DRVR_m16511__Backlight_13E2_30:  /* loop: move */
    movew %d0,MemErr
    rts
    moveq #0,%d0
    jbra rsrc_DRVR_m16511__Backlight_13E2_30

/* subroutine (4 instructions): traps NewPtr (mechanical summary) */
rsrc_DRVR_m16511__Backlight_141C:
    moveal %sp@+,%a1
    movel %sp@+,%d0
    .short  0xA71E	| 408D50D0 _NewPtr (flags 0x0700)
    movel %a0,%sp@
    jmp %pc@(rsrc_DRVR_m16511__Backlight_13E2_2E)

/* subroutine (4 instructions): traps DisposPtr (mechanical summary) */
rsrc_DRVR_m16511__Backlight_1428:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _DisposPtr
    jmp %pc@(rsrc_DRVR_m16511__Backlight_13E2_2E)

/* subroutine (5 instructions): traps VInstall (mechanical summary) */
rsrc_DRVR_m16511__Backlight_1432:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _VInstall
    movew %d0,%sp@
    jmp %a1@

/* subroutine (6 instructions): traps VRemove (mechanical summary) */
rsrc_DRVR_m16511__Backlight_143C:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _VRemove
    movew %d0,%sp@
    jmp %a1@
    FILL_408D50F6
