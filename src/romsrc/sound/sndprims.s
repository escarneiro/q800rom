/*
 sound/sndprims.s - sound hardware primitives
 From SNDPRIM (0x4088C400). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple.
 Sound hardware primitives, one table per machine family (ProductInfo +48, SNDCNTLxxx
 at the end), 11 entries: 0 initialise the sound chips at start-up, 1 write the sound
 control register (DFAC or equivalent), 2 set the playback volume, 3/4/5 enable,
 disable and clear the ASC interrupt, 6 select the sound input, 7 get the input
 selected, 8 play-through on or off, 9 play-through volume, 10 input gain.
 The last value written to the control register is kept at -3 of the sound globals
 (reached through ExpandMem +0x1AA), -4/-5 the play-through and gain bits, and +4 of
 those globals can hold a hook that writes the register on this machine.
*/

/* SNDPRIM: initialise (Egret machines): Egret command 0x0E 01 (sound off, d1 = 0 or -22). */
SNDPRIM:
    moveq #0,%d1
    jbra SNDPRIM_A
SNDPRIM_4:              /* (with d1 = -22) */
    moveq #-22,%d1
    jbra SNDPRIM_A
    .short  0x7200	| 4088C408
SNDPRIM_A:              /* send the Egret command, return through fp */
    moveal %fp,%a3
    movel #917505,%d0
    moveq #1,%d2
    lea %pc@(SNDPRIM_22),%fp
    bigjmp SENDEGRETCMD, a2
SNDPRIM_22:             /* Z = result */
    tstw %d0
    jmp %a3@

SNDPRIM_26:             /* write the sound control register through Egret (bits reversed), remember it */
    moveml %d1-%d3/%a0-%a1,%sp@-
    movel %d0,%d3
    moveq #0,%d1
    moveq #7,%d2
SNDPRIM_30:             /* reverse the bits */
    asrb #1,%d0
    roxlb #1,%d1
    dbf %d2,SNDPRIM_30
    subaw #20,%sp
    moveal %sp,%a0
    moveb #1,%a0@
    moveb #14,%a0@(1)
    movew #1,%a0@(6)
    clrl %a0@(8)
    clrw %a0@(12)
    clrw %a0@(14)
    clrl %a0@(16)
    moveb %d1,%a0@(2)
    _EgretDispatch
    lea %sp@(20),%sp
    jbne SNDPRIM_76
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C46A
    moveb %d3,%a0@(-3)
SNDPRIM_76:             /* done */
    moveml %sp@+,%d1-%d3/%a0-%a1
    rts

/*
 TIMPLAYBACKVOL: set the playback volume d0 (0..7) through the table below, written to
 the left and right volume registers of the sound chip (0xCC0 +0xF06...).
*/
TIMPLAYBACKVOL:
    movel %a0,%sp@-
    andiw #255,%d0
    moveb %pc@(TIMPLAYBACKVOL_2A,%d0:w),%d0
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal ASCBase,%a0
    moveb %d0,%a0@(3846)
    clrb %a0@(3847)
    clrb %a0@(3878)
    moveb %d0,%a0@(3879)
    movew %sp@+,%sr
    moveal %sp@+,%a0
    rts
TIMPLAYBACKVOL_2A:      /* volume levels for 0..7 */
    .short  0x0112, 0x2436, 0x485A, 0x6C7F, 0x0000	| 4088C4A6

TIMPLAYBACKVOL_34:      /* input select: source d0 (0 none), bit 3 for a source */
    tstb %d0
    jbeq TIMPLAYBACKVOL_3C
    orib #8,%d0

TIMPLAYBACKVOL_3C:      /* build the control register value: source, play-through, gain bits */
    moveml %d1/%a0-%a1,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C4BC
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #3,%d2
    andb %a0@(-3),%d2
    moveq #16,%d1
    andb %a0@(-3),%d1
    orb %d0,%d1
    tstb %d0
    jbeq TIMPLAYBACKVOL_6E
    orb %a0@(-4),%d1
    cmpib #1,%d0
    jbne TIMPLAYBACKVOL_6E
    orb %a0@(-5),%d1
TIMPLAYBACKVOL_6E:      /* write it through the hook, if any */
    moveb %d1,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C4EE
    tstl %a0@(4)
    jbeq TIMPLAYBACKVOL_86
    moveal %a0@(4),%a0
    jsr %a0@
TIMPLAYBACKVOL_86:      /* done. d0 = the previous source */
    moveal %sp@+,%a0
    movew %sp@+,%sr
    moveb %d2,%d0
    moveml %sp@+,%d1/%a0-%a1
    rts

/*
 ECLIPSEINPUTSELECT: select the sound input on the Quadra 700/900/950: input bits in
 VIA 2 (via the VIA 2 base at 0xCEC), then the control register.
*/
ECLIPSEINPUTSELECT:
    movew %sr,%sp@-
    oriw #1792,%sr
    moveml %d0-%d1,%sp@-
    moveb @(ghost_VIA2,%za0)@(0),%d1	| 4088C518
    andib #0xb7,%d1
    andiw #255,%d0
    orb %pc@(ECLIPSEINPUTSELECT_38,%d0:w),%d1
    moveb %d1,@(ghost_VIA2,%za0)@(0)	| 4088C52A
    jbsr DARTDFACINIT_236
    moveml %sp@+,%d0-%d1
    movew %sp@+,%sr
    tstb %d0
    jbeq TIMPLAYBACKVOL_3C
    moveq #1,%d0
    jbra TIMPLAYBACKVOL_3C
ECLIPSEINPUTSELECT_38:  /* VIA 2 bits per input */
    .short  0x0040, 0x4808	| 4088C546

ECLIPSEINPUTSELECT_3C:  /* input select without input hardware: only source 1, else -22 */
    cmpib #1,%d0
    jbeq TIMPLAYBACKVOL_3C
    moveml %d1/%a0,%sp@-
    moveq #-22,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C55A
    tstl %a0@(4)
    jbeq ECLIPSEINPUTSELECT_60
    moveal %a0@(4),%a0
    jsr %a0@
ECLIPSEINPUTSELECT_60:  /* done */
    moveal %sp@+,%a0
    moveml %sp@+,%d1/%a0
    rts

/*
 DARTINPUTSELECT: select the sound input on the PowerBook (Dartanian): input bits in the
 machine's I/O register, the sound globals' input count, play-through off for the
 external input.
*/
DARTINPUTSELECT:
    movew %sr,%sp@-
    moveml %d1/%a0,%sp@-
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #91136,%a0
    bclr #6,%a0@
    oriw #1792,%sr
    cmpib #2,%d0
    jbne DARTINPUTSELECT_2A
    bset #7,%a0@
    jbra DARTINPUTSELECT_2E
DARTINPUTSELECT_2A:     /* other input */
    bclr #7,%a0@
DARTINPUTSELECT_2E:     /* update the count of users of the input */
    movel %d0,%d1
    jbsr DARTINPUTSELECT_66
    tstb %d0
    cmpib #1,%d0
    jblt DARTINPUTSELECT_48
    jbgt DARTINPUTSELECT_46
    btst #1,%a0@
    jbeq DARTINPUTSELECT_46
    clrb %d0
    jbsr PLAYTHRUVOL
DARTINPUTSELECT_46:     /* source 1 */
    moveq #1,%d0
DARTINPUTSELECT_48:     /* write the control register */
    jbsr TIMPLAYBACKVOL_34
    movel %d1,%d0
    moveml %sp@+,%d1/%a0
    movew %sp@+,%sr
    rts
DARTINPUTSELECT_56:     /* input select (DBLite): with interrupts masked */
    movew %sr,%sp@-
    oriw #1792,%sr
    jbsr DARTINPUTSELECT_66
    jbsr TIMPLAYBACKVOL_34
    movew %sp@+,%sr
    rts

DARTINPUTSELECT_66:     /* count users of the input (Power Manager globals +248) */
    moveml %d2/%a0-%a1,%sp@-
    moveal PmgrBase,%a1
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C5E4
    moveq #3,%d2
    andb %a0@(-3),%d2
    jbeq DARTINPUTSELECT_88
    tstb %d0
    jbne DARTINPUTSELECT_90
    subqb #1,%a1@(248)
    jbra DARTINPUTSELECT_90
DARTINPUTSELECT_88:     /* (none selected before) */
    tstb %d0
    jbeq DARTINPUTSELECT_90
    addqb #1,%a1@(248)
DARTINPUTSELECT_90:     /* done */
    moveml %sp@+,%d2/%a0-%a1
    rts

DARTINPUTSELECT_96:     /* play-through volume (Dartanian): off for the external input */
    moveml %d1/%a0,%sp@-
    movew %d0,%d1
    jbsr DARTDFACINIT_EE
    cmpib #1,%d0
    jbne DARTINPUTSELECT_BE
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #91136,%a0
    btst #1,%a0@
    jbeq DARTINPUTSELECT_BE
    clrb %d1
DARTINPUTSELECT_BE:     /* then PLAYTHRUVOL */
    moveb %d1,%d0
    moveml %sp@+,%d1/%a0

/*
 PLAYTHRUVOL: set the play-through volume d0 (bits 5-7 of the control register), written
 now if an input is active.
*/
PLAYTHRUVOL:
    moveml %d1/%a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C63E
    movew %sr,%sp@-
    oriw #1792,%sr
    aslb #5,%d0
    moveb %d0,%a0@(-4)
    moveq #-4,%d1
    andb %a0@(-3),%d1
    jbeq PLAYTHRUVOL_40
    moveq #31,%d1
    andb %a0@(-3),%d1
    orb %d1,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C664
    tstl %a0@(4)
    jbeq PLAYTHRUVOL_3E
    moveal %a0@(4),%a0
    jsr %a0@
PLAYTHRUVOL_3E:         /* (after the hook) */
    moveal %sp@+,%a0
PLAYTHRUVOL_40:         /* done */
    movew %sp@+,%sr
    moveml %sp@+,%d1/%a0
    rts

PLAYTHRUVOL_48:         /* input gain on or off (bit 2 or 3), written if an input is active */
    moveml %d1/%a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C686
    moveq #4,%d1
    tstb %d0
    jbeq PLAYTHRUVOL_5C
    moveq #8,%d1
PLAYTHRUVOL_5C:         /* remember it, write it */
    movew %sr,%sp@-
    oriw #1792,%sr
    moveb %d1,%a0@(-5)
    moveq #-4,%d0
    andb %a0@(-3),%d0
    jbeq PLAYTHRUVOL_8E
    moveq #-13,%d0
    andb %a0@(-3),%d0
    orb %d1,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C6B2
    tstl %a0@(4)
    jbeq PLAYTHRUVOL_8C
    moveal %a0@(4),%a0
    jsr %a0@
PLAYTHRUVOL_8C:         /* (after the hook) */
    moveal %sp@+,%a0
PLAYTHRUVOL_8E:         /* done */
    movew %sp@+,%sr
    moveml %sp@+,%d1/%a0
    rts

/*
 DARTDFACINIT: initialise the DFAC sound chip at start-up (no RAM: returns through fp):
 shift the value d0 out, bit by bit, through VIA 2 port B (bit 3 data, bit 4 clock,
 bit 0 latch).
*/
DARTDFACINIT:
    moveq #0,%d0
    moveal %a0@(88),%a3
    addal #91136,%a3
    bclr #6,%a3@
    bclr #7,%a3@
    jbra DARTDFACINIT_1C
DARTDFACINIT_16:        /* (other machine: same with 0) */
    moveq #0,%d0
    jbra DARTDFACINIT_1C
DARTDFACINIT_1A:        /* (other machine: same with 0) */
    moveq #0,%d0
DARTDFACINIT_1C:        /* latch low, then 8 bits */
    moveal %a0@(44),%a3
    bset #0,%a3@
    bset #4,%a3@
    bclr #0,%a3@
    moveq #7,%d1
DARTDFACINIT_2E:        /* next bit */
    asrb #1,%d0
    jbcc DARTDFACINIT_38
    bset #3,%a3@
    jbra DARTDFACINIT_3C
DARTDFACINIT_38:        /* 0 bit */
    bclr #3,%a3@
DARTDFACINIT_3C:        /* clock pulse */
    bclr #4,%a3@
    bset #4,%a3@
    dbf %d1,DARTDFACINIT_2E
    bset #0,%a3@
    jmp %fp@

DARTDFACINIT_4E:        /* write the DFAC register d0 (same, through ghost_VIA2, remembered) */
    moveml %d1-%d2/%a0,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C728
    moveb %d0,%a0@(-3)
    moveal ghost_VIA2,%a0
    bset #0,%a0@
    bset #4,%a0@
    bclr #0,%a0@
    moveq #7,%d1
DARTDFACINIT_76:        /* next bit */
    asrb #1,%d0
    jbcc DARTDFACINIT_80
    bset #3,%a0@
    jbra DARTDFACINIT_84
DARTDFACINIT_80:        /* 0 bit */
    bclr #3,%a0@
DARTDFACINIT_84:        /* clock pulse */
    bclr #4,%a0@
    bset #4,%a0@
    dbf %d1,DARTDFACINIT_76
    bset #0,%a0@
    movew %sp@+,%sr
    moveml %sp@+,%d1-%d2/%a0
    rts
DARTDFACINIT_9C:        /* set the playback volume d0 (sound chip volume register, bits 5-7) */
    movel %a0,%sp@-
    moveal ASCBase,%a0
    lslb #5,%d0
    moveb %d0,%a0@(2054)
    moveal %sp@+,%a0
    rts

DARTDFACINIT_AC:        /* play-through on or off (bit 4 of the control register) */
    moveml %d1/%a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C780
    moveq #0,%d1
    tstb %d0
    jbeq DARTDFACINIT_C0
    moveq #16,%d1
DARTDFACINIT_C0:        /* write it through the hook */
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #-17,%d0
    andb %a0@(-3),%d0
    orb %d1,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C7A0
    tstl %a0@(4)
    jbeq DARTDFACINIT_E4
    moveal %a0@(4),%a0
    jsr %a0@
DARTDFACINIT_E4:        /* done */
    moveal %sp@+,%a0
    movew %sp@+,%sr
    moveml %sp@+,%d1/%a0
    rts

DARTDFACINIT_EE:        /* input selected (Dartanian): 0 none, 1 or 2 by the I/O register bit 7 */
    jbsr DARTDFACINIT_118
    tstb %d0
    jbeq DARTDFACINIT_116
    movel %a0,%sp@-
    moveal 0xdd8,%a0
    addal %a0@,%a0
    moveal %a0@(88),%a0
    addal #91136,%a0
    moveb #2,%d0
    btst #7,%a0@
    jbne DARTDFACINIT_114
    moveb #1,%d0
DARTDFACINIT_114:       /* d0 = input */
    moveal %sp@+,%a0
DARTDFACINIT_116:       /* done */
    rts

DARTDFACINIT_118:       /* input selected: the low 2 bits of the remembered control register */
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C7EA
    moveq #3,%d0
    andb %a0@(-3),%d0
    moveal %sp@+,%a0
    rts

DARTDFACINIT_12C:       /* initialise (DBLite): sound chip set-up through the Power Manager */
    moveq #-30,%d0
    moveal %a0@(8),%a2
    moveal %a0@(44),%a3
    moveq #-111,%d3
    lea %pc@(DARTDFACINIT_146),%a5
    bigjmp USTPMGRSENDBYTE, a4
DARTDFACINIT_146:
    moveb %d0,%d3	| 4088C816
    lea %pc@(DARTDFACINIT_156),%a5	| 4088C818
DARTDFACINIT_14C:       /* address 0xfffbaebe */
    lea 0xfffbaebe,%a4	| 4088C81C
    jmp %pc@(DARTDFACINIT_14C,%a4:l)	| 4088C822
DARTDFACINIT_156:       /* (data) */
    .byte   0x76, 0x00, 0x4B, 0xFA, 0x00, 0x0C, 0x49, 0xF9, 0xFF, 0xFB, 0xAE, 0xAE, 0x4E, 0xFB, 0xC8, 0xF8	| 4088C826
    .byte   0x4E, 0xD6	| 4088C836

DARTDFACINIT_168:       /* write the control register (DBLite): through PMgrOp 0x91 */
    moveml %d1/%a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C83C
    moveb %d0,%a0@(-3)
    moveq #3,%d1
    andb %d0,%d1
    cmpib #2,%d1
    jbne DARTDFACINIT_198
    moveb %pc@(DARTDFACINIT_1BC,%d1:w),%d1
    moveal ASCBase,%a0
    moveb %a0@(2054),%d0
    andib #0xe0,%d0
    orb %d1,%d0
    moveq #2,%d1
    jbra DARTDFACINIT_19C
DARTDFACINIT_198:       /* (value from the table) */
    moveb %pc@(DARTDFACINIT_1BC,%d1:w),%d0
DARTDFACINIT_19C:       /* PMgrOp 0x91 with 2 bytes */
    lslw #8,%d0
    orb %d1,%d0
    movew %d0,%sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #2,%sp@-
    movew #145,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(14),%sp
    moveml %sp@+,%d1/%a0
    rts
DARTDFACINIT_1BC:       /* register values per input */
    .long   0xE20909E9	| 4088C88C
DARTDFACINIT_1C0:       /* input select (DBLite) */
    movew %sr,%sp@-
    oriw #1792,%sr
    jbsr DARTINPUTSELECT_66
    cmpib #2,%d0
    jbne DARTDFACINIT_1E0
    movel %a0,%sp@-
    moveal ghost_VIA2,%a0
    lea %a0@(34),%a0
    bset #0,%a0@
    moveal %sp@+,%a0
DARTDFACINIT_1E0:       /* write the control register */
    jbsr TIMPLAYBACKVOL_3C
    movew %sp@+,%sr
    rts

DARTDFACINIT_1E8:       /* playback volume (DBLite): volume register, and the control register for input 2 */
    movel %a0,%sp@-
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal ASCBase,%a0
    lslb #5,%d0
    moveb %d0,%a0@(2054)
    moveal PmgrBase,%a0
    tstb %a0@(12)
    jbeq DARTDFACINIT_230
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C8D4
    moveq #3,%d0
    andb %a0@(-3),%d0
    cmpib #2,%d0
    jbne DARTDFACINIT_230
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C8EA
    tstl %a0@(4)
    jbeq DARTDFACINIT_22E
    moveal %a0@(4),%a0
    jsr %a0@
DARTDFACINIT_22E:       /* (after the hook) */
    moveal %sp@+,%a0
DARTDFACINIT_230:       /* done */
    movew %sp@+,%sr
    moveal %sp@+,%a0
    rts

DARTDFACINIT_236:       /* toggle two registers of the sound chip if VIA 2 shows no interrupt pending */
    movel %a1,%sp@-
    moveal ghost_VIA2,%a1
    cmpaw #-1,%a1
    jbeq DARTDFACINIT_280
    btst #4,%a1@(6656)
    jbne DARTDFACINIT_280
    moveal ASCBase,%a1
    cmpaw #-1,%a1
    jbeq DARTDFACINIT_280
    movew %sr,%sp@-
    oriw #1792,%sr
    tstb %a1@(3849)
    jbne DARTDFACINIT_26C
    moveb #1,%a1@(3849)
    nop
    clrb %a1@(3849)
DARTDFACINIT_26C:       /* second register */
    tstb %a1@(3881)
    jbne DARTDFACINIT_27E
    moveb #1,%a1@(3881)
    nop
    clrb %a1@(3881)
DARTDFACINIT_27E:       /* restore the interrupt level */
    movew %sp@+,%sr
DARTDFACINIT_280:       /* done */
    moveal %sp@+,%a1
    rts
DARTDFACINIT_284:                /* input select (Sonora) */
    cmpib #1,%d0
    beqw TIMPLAYBACKVOL_3C
    moveml %d1/%a0,%sp@-
    moveq #-22,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C964
    tstl %a0@(4)
    beqs DARTDFACINIT_284_24
    moveal %a0@(4),%a0
    jsr %a0@
DARTDFACINIT_284_24:
    moveal %sp@+,%a0
    moveml %sp@+,%d1/%a0
    rts

DARTDFACINIT_2B0:       /* input select (Vail): source 1 or none */
    cmpib #1,%d0
    beqw DARTDFACINIT_2E8
    moveml %d1/%a0,%sp@-
    moveq #-22,%d0
    andib #31,%d0
    moveb SdVolume,%d1
    lslb #5,%d1
    orb %d1,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C99C
    tstl %a0@(4)
    jbeq DARTDFACINIT_2E0
    moveal %a0@(4),%a0
    jsr %a0@
DARTDFACINIT_2E0:       /* done */
    moveal %sp@+,%a0
    moveml %sp@+,%d1/%a0
    rts
DARTDFACINIT_2E8:       /* build and write the control register (Vail) */
    moveml %d1/%a0-%a1,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C9BC
    movew %sr,%sp@-
    oriw #1792,%sr
    moveq #3,%d2
    andb %a0@(-3),%d2
    moveq #16,%d1
    andb %a0@(-3),%d1
    orb %d0,%d1
    tstb %d0
    jbeq DARTDFACINIT_31A
    orb %a0@(-4),%d1
    cmpib #1,%d0
    jbne DARTDFACINIT_31A
    orb %a0@(-5),%d1
DARTDFACINIT_31A:       /* (play-through bit) */
    moveb %d1,%d0
    bset #4,%d0
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088C9F2
    tstl %a0@(4)
    jbeq DARTDFACINIT_336
    moveal %a0@(4),%a0
    jsr %a0@
DARTDFACINIT_336:       /* done */
    moveal %sp@+,%a0
    movew %sp@+,%sr
    moveb %d2,%d0
    moveml %sp@+,%d1/%a0-%a1
    rts

/*
 SONORADFACINIT: initialise (Sonora/Vail): the Egret command with the value 0xEA
 bit-reversed.
*/
SONORADFACINIT:
    moveq #-22,%d0
    moveq #0,%d1
    moveq #7,%d2
SONORADFACINIT_6:       /* reverse the bits */
    asrb #1,%d0
    roxlb #1,%d1
    dbf %d2,SONORADFACINIT_6
    jbra SNDPRIM_A

/*
 VAILSETVOL: set the playback volume (Vail): through the sound chip, keeping the
 control register state.
*/
VAILSETVOL:
    moveml %a0-%a1,%sp@-
    moveal ASCBase,%a0
    moveal ExpandMem,%a1
    cmpaw #-1,%a1
    jbeq VAILSETVOL_62
    moveal %a1@(426),%a1
    cmpaw #0,%a1
    jbeq VAILSETVOL_62
    tstb %a1@(-3)
    jbne VAILSETVOL_28
    moveb #0xea,%a1@(-3)
VAILSETVOL_28:          /* (default value 0xEA) */
    moveb %a1@(-3),%d1
    andib #3,%d1
    cmpib #1,%d1
    jbeq VAILSETVOL_5C
    moveb #0xe0,%a0@(2054)
    moveb %a1@(-4),%sp@-
    movel %a0,%sp@-
    moveal @(ExpandMem,%za0)@(0x1aa),%a0	| 4088CA66
    tstl %a0@(36)
    jbeq VAILSETVOL_56
    moveal %a0@(36),%a0
    jsr %a0@
VAILSETVOL_56:          /* (after the hook) */
    moveal %sp@+,%a0
    moveb %sp@+,%a1@(-4)
VAILSETVOL_5C:          /* done */
    moveml %sp@+,%a0-%a1
    rts
VAILSETVOL_62:          /* no sound globals yet: volume register only */
    lslb #5,%d0
    moveb %d0,%a0@(2054)
    moveml %sp@+,%a0-%a1
    rts
    .short  0x0000, 0x000B	| 4088CA92
SNDCNTLTIM:             /* sound primitives table: PowerBook (TIM) */
    .long   DARTDFACINIT_1A-SNDCNTLTIM	| 4088CA96
    .long   DARTDFACINIT_4E-SNDCNTLTIM	| 4088CA9A
    .long   TIMPLAYBACKVOL-SNDCNTLTIM	| 4088CA9E
    .long   ENABLEASCINTS-SNDCNTLTIM	| 4088CAA2
    .long   DISABLEASCINTS-SNDCNTLTIM	| 4088CAA6
    .long   CLEARASCINT-SNDCNTLTIM	| 4088CAAA
    .long   DARTINPUTSELECT_56-SNDCNTLTIM	| 4088CAAE
    .long   DARTDFACINIT_118-SNDCNTLTIM	| 4088CAB2
    .long   DARTDFACINIT_AC-SNDCNTLTIM	| 4088CAB6
    .long   PLAYTHRUVOL-SNDCNTLTIM	| 4088CABA
    .long   PLAYTHRUVOL_48-SNDCNTLTIM	| 4088CABE
    .short  0x000B	| 4088CAC2
SNDCNTLECLIPSE:         /* sound primitives table: Quadra 700/900/950 and 800 (Eclipse) */
    .long   SNDPRIM-SNDCNTLECLIPSE	| 4088CAC4
    .long   SNDPRIM_26-SNDCNTLECLIPSE	| 4088CAC8
    .long   DARTDFACINIT_9C-SNDCNTLECLIPSE	| 4088CACC
    .long   ENABLEASCINTS-SNDCNTLECLIPSE	| 4088CAD0
    .long   DISABLEASCINTS-SNDCNTLECLIPSE	| 4088CAD4
    .long   CLEARASCINT-SNDCNTLECLIPSE	| 4088CAD8
    .long   ECLIPSEINPUTSELECT-SNDCNTLECLIPSE	| 4088CADC
    .long   DARTDFACINIT_118-SNDCNTLECLIPSE	| 4088CAE0
    .long   DARTDFACINIT_AC-SNDCNTLECLIPSE	| 4088CAE4
    .long   PLAYTHRUVOL-SNDCNTLECLIPSE	| 4088CAE8
    .long   PLAYTHRUVOL_48-SNDCNTLECLIPSE	| 4088CAEC
    .short  0x000B	| 4088CAF0
SNDCNTLSPIKE:           /* sound primitives table: Spike */
    .long   DARTDFACINIT_16-SNDCNTLSPIKE	| 4088CAF2
    .long   DARTDFACINIT_4E-SNDCNTLSPIKE	| 4088CAF6
    .long   DARTDFACINIT_9C-SNDCNTLSPIKE	| 4088CAFA
    .long   ENABLEASCINTS-SNDCNTLSPIKE	| 4088CAFE
    .long   DISABLEASCINTS-SNDCNTLSPIKE	| 4088CB02
    .long   CLEARASCINT-SNDCNTLSPIKE	| 4088CB06
    .long   TIMPLAYBACKVOL_3C-SNDCNTLSPIKE	| 4088CB0A
    .long   DARTDFACINIT_118-SNDCNTLSPIKE	| 4088CB0E
    .long   DARTDFACINIT_AC-SNDCNTLSPIKE	| 4088CB12
    .long   PLAYTHRUVOL-SNDCNTLSPIKE	| 4088CB16
    .long   PLAYTHRUVOL_48-SNDCNTLSPIKE	| 4088CB1A
    .short  0x000B	| 4088CB1E
SNDCNTLELSIE:           /* sound primitives table: Elsie / Apollo */
SNDCNTLAPOLLO:          /* (same table) */
    .long   SNDPRIM_4-SNDCNTLELSIE	| 4088CB20
    .long   SNDPRIM_26-SNDCNTLELSIE	| 4088CB24
    .long   DARTDFACINIT_9C-SNDCNTLELSIE	| 4088CB28
    .long   ENABLEASCINTS-SNDCNTLELSIE	| 4088CB2C
    .long   DISABLEASCINTS-SNDCNTLELSIE	| 4088CB30
    .long   CLEARASCINT-SNDCNTLELSIE	| 4088CB34
    .long   ECLIPSEINPUTSELECT_3C-SNDCNTLELSIE	| 4088CB38
    .long   DARTDFACINIT_118-SNDCNTLELSIE	| 4088CB3C
    .long   DARTDFACINIT_AC-SNDCNTLELSIE	| 4088CB40
    .long   PLAYTHRUVOL-SNDCNTLELSIE	| 4088CB44
    .long   PLAYTHRUVOL_48-SNDCNTLELSIE	| 4088CB48
    .short  0x000B	| 4088CB4C
SNDCNTLDBLITE:          /* sound primitives table: PowerBook Duo (DBLite) */
    .long   DARTDFACINIT_12C-SNDCNTLDBLITE	| 4088CB4E
    .long   DARTDFACINIT_168-SNDCNTLDBLITE	| 4088CB52
    .long   DARTDFACINIT_1E8-SNDCNTLDBLITE	| 4088CB56
    .long   ENABLEASCINTS-SNDCNTLDBLITE	| 4088CB5A
    .long   DISABLEASCINTS-SNDCNTLDBLITE	| 4088CB5E
    .long   CLEARASCINT-SNDCNTLDBLITE	| 4088CB62
    .long   DARTDFACINIT_1C0-SNDCNTLDBLITE	| 4088CB66
    .long   DARTDFACINIT_118-SNDCNTLDBLITE	| 4088CB6A
    .long   DARTDFACINIT_AC-SNDCNTLDBLITE	| 4088CB6E
    .long   PLAYTHRUVOL-SNDCNTLDBLITE	| 4088CB72
    .long   PLAYTHRUVOL_48-SNDCNTLDBLITE	| 4088CB76
    .short  0x000B	| 4088CB7A
SNDCNTLSONORA:          /* sound primitives table: Sonora (offsets were plain numbers, now label differences) */
    .long   SONORADFACINIT-SNDCNTLSONORA
    .long   SNDPRIM_26-SNDCNTLSONORA
    .long   DARTDFACINIT_9C-SNDCNTLSONORA
    .long   ENABLEASCINTS-SNDCNTLSONORA
    .long   DISABLEASCINTS-SNDCNTLSONORA
    .long   CLEARASCINT-SNDCNTLSONORA
    .long   DARTDFACINIT_284-SNDCNTLSONORA
    .long   DARTDFACINIT_118-SNDCNTLSONORA
    .long   DARTDFACINIT_AC-SNDCNTLSONORA
    .long   PLAYTHRUVOL-SNDCNTLSONORA
    .long   PLAYTHRUVOL_48-SNDCNTLSONORA
    .short  0x000B
SNDCNTLDARTANIAN:       /* sound primitives table: Dartanian */
    .long   DARTDFACINIT-SNDCNTLDARTANIAN	| 4088CBAA
    .long   DARTDFACINIT_4E-SNDCNTLDARTANIAN	| 4088CBAE
    .long   TIMPLAYBACKVOL-SNDCNTLDARTANIAN	| 4088CBB2
    .long   ENABLEASCINTS-SNDCNTLDARTANIAN	| 4088CBB6
    .long   DISABLEASCINTS-SNDCNTLDARTANIAN	| 4088CBBA
    .long   CLEARASCINT-SNDCNTLDARTANIAN	| 4088CBBE
    .long   DARTINPUTSELECT-SNDCNTLDARTANIAN	| 4088CBC2
    .long   DARTDFACINIT_EE-SNDCNTLDARTANIAN	| 4088CBC6
    .long   DARTDFACINIT_AC-SNDCNTLDARTANIAN	| 4088CBCA
    .long   DARTINPUTSELECT_96-SNDCNTLDARTANIAN	| 4088CBCE
    .long   PLAYTHRUVOL_48-SNDCNTLDARTANIAN	| 4088CBD2
    .short  0x000B	| 4088CBD6
SNDCNTLVAIL:            /* sound primitives table: Vail */
    .long   SONORADFACINIT-SNDCNTLVAIL	| 4088CBD8
    .long   SNDPRIM_26-SNDCNTLVAIL	| 4088CBDC
    .long   VAILSETVOL-SNDCNTLVAIL	| 4088CBE0
    .long   ENABLEASCINTS-SNDCNTLVAIL	| 4088CBE4
    .long   DISABLEASCINTS-SNDCNTLVAIL	| 4088CBE8
    .long   CLEARASCINT-SNDCNTLVAIL	| 4088CBEC
    .long   DARTDFACINIT_2B0-SNDCNTLVAIL	| 4088CBF0
    .long   DARTDFACINIT_118-SNDCNTLVAIL	| 4088CBF4
    .long   DARTDFACINIT_AC-SNDCNTLVAIL	| 4088CBF8
    .long   PLAYTHRUVOL-SNDCNTLVAIL	| 4088CBFC
    .long   PLAYTHRUVOL_48-SNDCNTLVAIL	| 4088CC00
    .fill   0x3FC, 1, 0x00
