/* ROM resource 'DRVR' 3 ".Sound": map entry at 0x408E59C0, data at 0x408E59F0, 2432 bytes

 The .Sound driver ('DRVR' 3): the original Sound Driver (square-wave, four-tone and
 free-form synthesizers, StartSound/StopSound through the driver), kept for old
 applications; the Sound Manager (sound/) is the current interface. Sound is played by a
 vertical-blanking task (VInstall) that feeds the sound hardware. Comments inferred from
 the code (traps used), not verified in depth.
*/

rsrc_DRVR_3__Sound_entry:  /* map entry */
    .long   0x78000000, 0x00000000	| 408E59C0
    .long   rsrc_DRVR_9__MPP_entry-rom_start	| 408E59C8
    .long   rsrc_DRVR_3__Sound-rom_start	| 408E59CC
    .ascii  "DRVR"	| 408E59D0
    .byte   0x00, 0x03, 0x58	| 408E59D4
    .byte   6	/* 408E59D7 Pascal string length */
    .ascii  ".Sound"	| 408E59D8
    FILL_408E59DE
    .byte   0xC0, 0xA0, 0x00, 0x00, 0x00, 0x00, 0x09, 0x8C, 0x00, 0x00, 0x02, 0x9C	| 408E59E4

/* subroutine (0 instructions) (mechanical summary) */
rsrc_DRVR_3__Sound:
    .byte   0x4E, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408E59F0
rsrc_DRVR_3__Sound_8:   /* (data) */
    .short  rsrc_DRVR_3__Sound_open-rsrc_DRVR_3__Sound	| 408E59F8
    .short  rsrc_DRVR_3__Sound_prime-rsrc_DRVR_3__Sound	| 408E59FA
    .short  rsrc_DRVR_3__Sound_ctl-rsrc_DRVR_3__Sound	| 408E59FC
    .short  rsrc_DRVR_3__Sound_status-rsrc_DRVR_3__Sound	| 408E59FE
    .short  rsrc_DRVR_3__Sound_close-rsrc_DRVR_3__Sound	| 408E5A00
    .byte   0x06, 0x2E, 0x53, 0x6F, 0x75, 0x6E, 0x64, 0x20	| 408E5A02

/* Open, Prime, Control, Close: all go through rsrc_DRVR_3__Sound_40. */
rsrc_DRVR_3__Sound_open:
    jbsr rsrc_DRVR_3__Sound_40
    jbeq rsrc_DRVR_3__Sound_40_12
    jbra rsrc_DRVR_3__Sound_4BE

/* subroutine (3 instructions): calls rsrc_DRVR_3__Sound_40 (mechanical summary) */
rsrc_DRVR_3__Sound_prime:
    jbsr rsrc_DRVR_3__Sound_40
    jbeq rsrc_DRVR_3__Sound_status_C
    jbra rsrc_DRVR_3__Sound_596

/* subroutine (3 instructions): calls rsrc_DRVR_3__Sound_40 (mechanical summary) */
rsrc_DRVR_3__Sound_ctl:
    jbsr rsrc_DRVR_3__Sound_40
    jbeq rsrc_DRVR_3__Sound_110_28
    jbra rsrc_DRVR_3__Sound_548

/* subroutine (3 instructions): calls rsrc_DRVR_3__Sound_40 (mechanical summary) */
rsrc_DRVR_3__Sound_close:
    jbsr rsrc_DRVR_3__Sound_40
    beqw rsrc_DRVR_3__Sound_A0_10
    jbra rsrc_DRVR_3__Sound_4BE_34

/*
 Common entry: start the request (rsrc_DRVR_3__Sound_62) or stop the current sound
 (rsrc_DRVR_3__Sound_110).
*/
rsrc_DRVR_3__Sound_40:
    movel %a2,%d2
    moveal ASCBase,%a2
    moveb %a2@(2048),%d1
    andib #0xf0,%d1
    moveal %d2,%a2
    rts
rsrc_DRVR_3__Sound_40_12:  /* set SoundDCE */
    movel %a1,SoundDCE
    moveb SPVolCtl,%d0
    jbsr rsrc_DRVR_3__Sound_110
    jbsr rsrc_DRVR_3__Sound_62
    rts

/* Start playing: buffer (NewPtr) and the VBL task that drives the synthesizer. */
rsrc_DRVR_3__Sound_62:
    clrb SoundActive
    tstl SoundBase
    jbeq rsrc_DRVR_3__Sound_A0_8
    moveq #16,%d0
    .short  0xA51E	| 408E5A5E _NewPtr (flags 0x0500)
    tstw %d0
    jbne rsrc_DRVR_3__Sound_A0_8
    clrl %a0@
    movew #1,%a0@(4)
    lea %pc@(rsrc_DRVR_3__Sound_46A),%a1
    movel %a1,%a0@(6)
    movew #61,%a0@(10)
    movew #9,%a0@(12)
    moveal VIA,%a1
    bset #7,%a1@
    movew #128,%a0@(14)
    _VInstall

rsrc_DRVR_3__Sound_A0:  /* loop: movea */
    moveal ASCBase,%a0
    movel %a0,SoundBase
rsrc_DRVR_3__Sound_A0_8:  /* result 0 */
    moveq #0,%d0
    rts
rsrc_DRVR_3__Sound_A0_C:  /* loop: clr */
    clrw CurPitch
rsrc_DRVR_3__Sound_A0_10:  /* set %a0 */
    moveal ASCBase,%a0
    clrb %a0@(2049)
    jbsr rsrc_DRVR_3__Sound_BC
    jbra rsrc_DRVR_3__Sound_A0_8

/* Remove the VBL task (VRemove). */
rsrc_DRVR_3__Sound_BC:
    tstb SoundActive
    jbeq rsrc_DRVR_3__Sound_BC_10
    lea SoundVBL_qLink,%a0
    _VRemove
    clrb SoundActive
rsrc_DRVR_3__Sound_BC_10:  /* return */
    rts

/* subroutine (22 instructions): low memory SoundLevel (mechanical summary) */
rsrc_DRVR_3__Sound_CE:
    moveb %d0,SoundLevel
    moveal ASCBase,%a0
    moveal %d2,%a1
    moveb #0x80,%d2
    lsrb #1,%d0
    tstb %a0@(2048)
    jbne rsrc_DRVR_3__Sound_CE_1C
    moveb #64,%d2
    lsrb #1,%d0
rsrc_DRVR_3__Sound_CE_1C:  /* set %d1 */
    moveb %d2,%d1
    subb %d0,%d1
    addb %d2,%d0
    movew #255,%d3
rsrc_DRVR_3__Sound_CE_26:  /* loop: move */
    moveb %d1,%a0@(1280)
    moveb %d1,%a0@(256)
    moveb %d0,%a0@(1024)
    moveb %d0,%a0@+
    dbf %d3,rsrc_DRVR_3__Sound_CE_26
    moveb %d2,%a0@
    moveb %d2,%a0@(1024)
    movel %a1,%d2
    rts

/* subroutine (20 instructions): calls rsrc_DRVR_3__Sound_CE; low memory SdVolume (mechanical summary) */
rsrc_DRVR_3__Sound_110:
    andiw #7,%d0
    moveb %d0,SdVolume
    moveal 0xdd8,%a0
    movel %a0@(48),%d1
    jbeq rsrc_DRVR_3__Sound_110_1C
    addal %d1,%a0
    addal %a0@(8),%a0
    jsr %a0@
    rts
rsrc_DRVR_3__Sound_110_1C:  /* set %a0 */
    moveal ASCBase,%a0
    lslb #5,%d0
    moveb %d0,%a0@(2054)
    rts
rsrc_DRVR_3__Sound_110_28:  /* set %d0 */
    movew %a0@(26),%d0
    jbeq rsrc_DRVR_3__Sound_status
    subqw #2,%d0
    jbeq rsrc_DRVR_3__Sound_status_4
    jblt rsrc_DRVR_3__Sound_A0_C
    movew %a0@(28),%d0
    jbsr rsrc_DRVR_3__Sound_CE

/* Status (and the request queue): what is playing. */
rsrc_DRVR_3__Sound_status:
    jbra rsrc_DRVR_3__Sound_2D4
rsrc_DRVR_3__Sound_status_4:  /* loop: move */
    movew %a0@(28),%d0
    jbsr rsrc_DRVR_3__Sound_110
    jbra rsrc_DRVR_3__Sound_status
rsrc_DRVR_3__Sound_status_C:  /* set %a1 */
    moveal %a0@(32),%a1
    tstw %a1@+
    jbeq rsrc_DRVR_3__Sound_3A8
    jbpl rsrc_DRVR_3__Sound_2D4_C
    movel %a0,%sp@-
    moveal ASCBase,%a0
    lea %a0@(2048),%a0
    clrb %a0@(7)
    moveb #2,%a0@(2)
    moveml %d0/%a0,%sp@-
    lea %a0@(16),%a0
    movew #31,%d0
rsrc_DRVR_3__Sound_status_3A:  /* loop: clr */
    clrb %a0@+
    dbf %d0,rsrc_DRVR_3__Sound_status_3A
    moveml %sp@+,%d0/%a0
    moveb #0xfe,%a0@(48)
    clrb %a0@(49)
    moveb #0xfe,%a0@(50)
    clrb %a0@(51)
    moveb #0xfe,%a0@(52)
    clrb %a0@(53)
    moveb #0xfe,%a0@(54)
    clrb %a0@(55)
    clrb %a0@(5)
    cmpib #2,%a0@(1)
    jbeq rsrc_DRVR_3__Sound_status_7E
    moveb #2,%a0@(1)
rsrc_DRVR_3__Sound_status_7E:  /* set %a0 */
    moveal %sp@+,%a0
rsrc_DRVR_3__Sound_status_80:  /* loop: movem */
    movemw %a1@+,%d0-%d2
    tstw %d2
    jbeq rsrc_DRVR_3__Sound_230_44
    movel %a0,%sp@-
    movew %d0,CurPitch
    moveq #0,%d3
    tstw %d0
    jbeq rsrc_DRVR_3__Sound_status_A0
    movel #295279001,%d3
    divull %d0,%d3,%d3
rsrc_DRVR_3__Sound_status_A0:  /* set %a0 */
    moveal ASCBase,%a0
    moveb %d3,%a0@(2071)
    moveb %d3,%a0@(2087)
    rorl #8,%d3
    moveb %d3,%a0@(2070)
    moveb %d3,%a0@(2086)
    rorl #8,%d3
    moveb %d3,%a0@(2069)
    moveb %d3,%a0@(2085)
    rorl #8,%d3
    moveb %d3,%a0@(2068)
    moveb %d3,%a0@(2084)
    movew %d1,%d0
    jbsr rsrc_DRVR_3__Sound_CE
    movew %d2,%d0
    lea %pc@(rsrc_DRVR_3__Sound_230_26),%a1
    jbsr rsrc_DRVR_3__Sound_230
    moveal %sp@+,%a0
    addql #6,%a0@(40)
    jbra rsrc_DRVR_3__Sound_A0_8

/* subroutine (1 instructions) (mechanical summary) */
rsrc_DRVR_3__Sound_22E:
    moveq #1,%d0

/* Install the VBL task (VInstall). */
rsrc_DRVR_3__Sound_230:
    lea SoundVBL_qLink,%a0
    movew %d0,%a0@(10)
    tstb SoundActive
    jbne rsrc_DRVR_3__Sound_230_24
    clrl %a0@
    movew #1,%a0@(4)
    movel %a1,%a0@(6)
    clrw %a0@(12)
    _VInstall
    st SoundActive
rsrc_DRVR_3__Sound_230_24:  /* return */
    rts
rsrc_DRVR_3__Sound_230_26:  /* set %a1 */
    moveal SoundDCE,%a1
    moveal %a1@(8),%a0
    movel %a0@(40),%d0
    moveal %a0@(32),%a1
    addal %d0,%a1
    addql #2,%a1
    addqw #4,%d0
    cmpl %a0@(36),%d0
    jblt rsrc_DRVR_3__Sound_status_80
rsrc_DRVR_3__Sound_230_44:  /* clear CurPitch */
    clrw CurPitch
    moveal ASCBase,%a0
    lea %a0@(2048),%a0
    clrb %a0@(20)
    clrb %a0@(21)
    clrb %a0@(22)
    clrb %a0@(23)
    clrb %a0@(28)
    clrb %a0@(29)
    clrb %a0@(30)
    clrb %a0@(31)
    clrb %a0@(36)
    clrb %a0@(37)
    clrb %a0@(38)
    clrb %a0@(39)
    clrb %a0@(44)
    clrb %a0@(45)
    clrb %a0@(46)
    clrb %a0@(47)
    clrb %a0@(1)
    clrb %a0@(2)
    clrb %a0@(3)
    clrb %a0@(4)

/* subroutine (1 instructions): calls rsrc_DRVR_3__Sound_BC (mechanical summary) */
rsrc_DRVR_3__Sound_2D0:
    jbsr rsrc_DRVR_3__Sound_BC

/* VBL task: a synthesizer step (fills the next part of the sound buffer; which synthesizer
 not determined). */
rsrc_DRVR_3__Sound_2D4:
    moveq #0,%d0
    moveal SoundDCE,%a1
    moveal JIODone,%a0
    jmp %a0@
rsrc_DRVR_3__Sound_2D4_C:  /* set SoundPtr */
    movel %a1@+,SoundPtr
    moveal ASCBase,%a1
    lea %a1@(2048),%a1
    cmpib #1,%a1@(1)
    jbeq rsrc_DRVR_3__Sound_2D4_3A
    clrb %a1@(7)
    clrb %a1@(2)
    moveb #1,%a1@(1)
    bset #7,%a1@(3)
    bclr #7,%a1@(3)
rsrc_DRVR_3__Sound_2D4_3A:  /* address %pc@(rsrc_DRVR_3__Sound_328) */
    lea %pc@(rsrc_DRVR_3__Sound_328),%a1
rsrc_DRVR_3__Sound_2D4_3E:  /* call rsrc_DRVR_3__Sound_22E (loop) */
    jbsr rsrc_DRVR_3__Sound_22E
    jbra rsrc_DRVR_3__Sound_A0_8
rsrc_DRVR_3__Sound_31A:  /* loop: movea */
    moveal ASCBase,%a1	| 408E5D0A
    clrb %a1@(2049)	| 408E5D0E
    moveml %sp@+,%d0-%fp	| 408E5D12
    jbra rsrc_DRVR_3__Sound_2D0	| 408E5D16
rsrc_DRVR_3__Sound_328:  /* save registers */
    moveml %d0-%fp,%sp@-	| 408E5D18
    moveal SoundPtr,%fp	| 408E5D1C
    tstw %fp@	| 408E5D20
    jbeq rsrc_DRVR_3__Sound_31A	| 408E5D22
    lea SoundVBL_qLink,%a0	| 408E5D24
    movew #1,%a0@(10)	| 408E5D28
    subqw #1,%fp@+	| 408E5D2E
    moveml %fp@,%d2-%a5	| 408E5D30
    moveal ASCBase,%fp	| 408E5D34
    movel #16711680,%d1	| 408E5D38
    movew #370,%sp@-	| 408E5D3E
rsrc_DRVR_3__Sound_352:  /* loop: clr */
    clrw %d1	| 408E5D42
    addl %d2,%d3	| 408E5D44
    addl %d4,%d5	| 408E5D46
    addl %d6,%d7	| 408E5D48
    addal %a0,%a1	| 408E5D4A
    movel %d3,%d0	| 408E5D4C
    andl %d1,%d0	| 408E5D4E
    swap %d0	| 408E5D50
    moveb %a2@(0,%d0:w),%d1	| 408E5D52
    movel %d5,%d0	| 408E5D56
    andl %d1,%d0	| 408E5D58
    swap %d0	| 408E5D5A
    moveb %a3@(0,%d0:w),%d0	| 408E5D5C
    addw %d0,%d1	| 408E5D60
    movel %d7,%d0	| 408E5D62
    andl %d1,%d0	| 408E5D64
    swap %d0	| 408E5D66
    moveb %a4@(0,%d0:w),%d0	| 408E5D68
    addw %d0,%d1	| 408E5D6C
    movel %a1,%d0	| 408E5D6E
    andl %d1,%d0	| 408E5D70
    swap %d0	| 408E5D72
    moveb %a5@(0,%d0:w),%d0	| 408E5D74
    addw %d0,%d1	| 408E5D78
    lsrw #2,%d1	| 408E5D7A
    moveb %d1,%fp@	| 408E5D7C
    subqw #1,%sp@	| 408E5D7E
    jbne rsrc_DRVR_3__Sound_352	| 408E5D80
    moveb %d1,SoundLevel	| 408E5D82
    addqw #2,%sp	| 408E5D86
    moveal SoundPtr,%fp	| 408E5D88
    addqw #2,%fp	| 408E5D8C
    moveml %d2-%a1,%fp@	| 408E5D8E
    moveml %sp@+,%d0-%fp	| 408E5D92
    rts	| 408E5D96
rsrc_DRVR_3__Sound_3A8:  /* set %a1 */
    moveal ASCBase,%a1
    lea %a1@(2048),%a1
    cmpib #1,%a1@(1)
    jbeq rsrc_DRVR_3__Sound_3D2
    clrb %a1@(7)
    clrb %a1@(2)
    moveb #1,%a1@(1)
    bset #7,%a1@(3)
    bclr #7,%a1@(3)
rsrc_DRVR_3__Sound_3D2:  /* set %a1 */
    moveal SoundDCE,%a1
    clrl %a1@(16)
    lea %pc@(rsrc_DRVR_3__Sound_3E2),%a1
    jbra rsrc_DRVR_3__Sound_2D4_3E
rsrc_DRVR_3__Sound_3E2:  /* loop: movea */
    moveal SoundDCE,%a1
    movel %a1@(8),%d0
    jbne rsrc_DRVR_3__Sound_3FA
    moveal ASCBase,%a1
    clrb %a1@(2049)
    jbsr rsrc_DRVR_3__Sound_BC
    rts
rsrc_DRVR_3__Sound_3FA:  /* set %a0 */
    moveal %d0,%a0
    movel %a0@(40),%d0
    cmpl %a0@(36),%d0
    jblt rsrc_DRVR_3__Sound_40C
    jbsr rsrc_DRVR_3__Sound_2D0
    jbra rsrc_DRVR_3__Sound_3E2
rsrc_DRVR_3__Sound_40C:  /* set %d3 */
    movel %a1@(16),%d3
    lea SoundVBL_qLink,%a3
    movew #1,%a3@(10)
    moveal %a0@(32),%a1
    addqw #2,%a1
    movel %a1@+,%d1
    moveal %a1,%a3
    addal %a0@(36),%a3
    addal %d0,%a1
    moveal ASCBase,%a2
    movew #369,%d2
    moveq #0,%d0
rsrc_DRVR_3__Sound_434:  /* loop: move */
    moveb %a1@,%a2@
    addl %d1,%d3
    swap %d3
    addaw %d3,%a1
    addw %d3,%d0
    clrw %d3
    swap %d3
    cmpal %a1,%a3
    dble %d2,rsrc_DRVR_3__Sound_434
    addl %d0,%a0@(40)
    moveb %a1@(-1),SoundLevel
    moveal SoundDCE,%a1
    movel %d3,%a1@(16)
    movel %a0@(40),%d0
    cmpl %a0@(36),%d0
    jblt rsrc_DRVR_3__Sound_468
    jbsr rsrc_DRVR_3__Sound_2D4
rsrc_DRVR_3__Sound_468:  /* return */
    rts
rsrc_DRVR_3__Sound_46A:  /* set %a0@(10) */
    movew #61,%a0@(10)
    moveal VIA,%a1
    moveb %a1@,%d0
    andib #0x80,%d0
    moveb %a0@(14),%d1
    eorb %d0,%d1
    jbeq rsrc_DRVR_3__Sound_4BC
    moveb %d0,%a0@(14)
    jbeq rsrc_DRVR_3__Sound_492
    moveal ASCBase,%a1
    clrb %a1@(2049)
    rts
rsrc_DRVR_3__Sound_492:  /* set %a0 */
    moveal ASCBase,%a0
    lea %a0@(2048),%a0
    cmpib #1,%a0@(1)
    jbeq rsrc_DRVR_3__Sound_4BC
    clrb %a0@(7)
    clrb %a0@(2)
    moveb #1,%a0@(1)
    bset #7,%a0@(3)
    bclr #7,%a0@(3)
rsrc_DRVR_3__Sound_4BC:  /* return */
    rts

rsrc_DRVR_3__Sound_4BE:  /* set %d2 */
    movel %d1,%d2
    movel %a1,SoundDCE
    jbsr rsrc_DRVR_3__Sound_4FC
    moveb SPVolCtl,%d0
    jbsr rsrc_DRVR_3__Sound_110
    clrb SoundActive
    moveq #12,%d0
    .short  0xA51E	| 408E5EC4 _NewPtr (flags 0x0500)
    movel %a0,%d0
    jbeq rsrc_DRVR_3__Sound_4BE_24
    moveal SoundDCE,%a1
    movel %a0,%a1@(20)
rsrc_DRVR_3__Sound_4BE_24:  /* test #0xb0,%d2 */
    cmpib #0xb0,%d2
    jbeq rsrc_DRVR_3__Sound_62
    jbra rsrc_DRVR_3__Sound_A0
rsrc_DRVR_3__Sound_4BE_30:  /* loop: clr */
    clrw CurPitch
rsrc_DRVR_3__Sound_4BE_34:  /* call rsrc_DRVR_3__Sound_BC */
    jbsr rsrc_DRVR_3__Sound_BC
    jbsr rsrc_DRVR_3__Sound_4FC
    jbra rsrc_DRVR_3__Sound_A0_8

/* subroutine (2 instructions): calls rsrc_DRVR_3__Sound_51C (mechanical summary) */
rsrc_DRVR_3__Sound_4FC:
    moveb #0x80,%d0
    jbsr rsrc_DRVR_3__Sound_51C

/* subroutine (6 instructions): low memory T1Arbitrate (mechanical summary) */
rsrc_DRVR_3__Sound_502:
    moveal VIA,%a0
    tstb T1Arbitrate
    jbne rsrc_DRVR_3__Sound_502_14
    andib #63,%a0@(5632)
    st T1Arbitrate
rsrc_DRVR_3__Sound_502_14:  /* return */
    rts

/* subroutine (1 instructions): low memory SoundLevel (mechanical summary) */
rsrc_DRVR_3__Sound_518:
    moveb SoundLevel,%d0

/* subroutine (76 instructions): calls rsrc_DRVR_3__Sound_40, rsrc_DRVR_3__Sound_51C, rsrc_DRVR_3__Sound_618; low memory SoundLevel, SoundBase, SoundDCE, T1Arbitrate, CurPitch (mechanical summary) */
rsrc_DRVR_3__Sound_51C:
    moveb %d0,SoundLevel
    moveb %d0,%d1
    lslw #8,%d0
    moveb %d1,%d0
    movew %d0,%d1
    swap %d0
    movew %d1,%d0
    moveal SoundBase,%a0
    moveq #45,%d1
rsrc_DRVR_3__Sound_51C_16:  /* loop: movep */
    movepl %d0,%a0@(0)
    movepl %d0,%a0@(8)
    lea %a0@(16),%a0
    dbf %d1,rsrc_DRVR_3__Sound_51C_16
    movepw %d0,%a0@(0)
    rts

rsrc_DRVR_3__Sound_548:  /* set %d0 */
    movew %a0@(26),%d0
    jbeq rsrc_DRVR_3__Sound_status
    subqw #2,%d0
    jbeq rsrc_DRVR_3__Sound_status_4
    jblt rsrc_DRVR_3__Sound_4BE_30
    movew %a0@(28),%d0
    jbsr rsrc_DRVR_3__Sound_40
    cmpib #0xe0,%d1
    jbeq rsrc_DRVR_3__Sound_548_2A
    cmpib #0xb0,%d1
    jbeq rsrc_DRVR_3__Sound_548_2A
    jbsr rsrc_DRVR_3__Sound_51C
    jbra rsrc_DRVR_3__Sound_status
rsrc_DRVR_3__Sound_548_2A:  /* set %a1 */
    moveal SoundDCE,%a1
    moveal %a1@(20),%a1
    moveb %d0,SoundLevel
    moveb #0x80,%d1
    lsrb #1,%d0
    moveb %d1,%d2
    subb %d0,%d2
    addb %d1,%d0
    moveb %d2,%a1@(8)
    moveb %d0,%a1@(9)
    jbra rsrc_DRVR_3__Sound_status

rsrc_DRVR_3__Sound_596:  /* set %a1 */
    moveal VIA,%a1
    bclr #7,%a1@
    moveal %a0@(32),%a1
    tstw %a1@+
    jbeq rsrc_DRVR_3__Sound_8AA
    jbpl rsrc_DRVR_3__Sound_664_122
    jbsr rsrc_DRVR_3__Sound_40
    cmpib #0xe0,%d1
    jbeq rsrc_DRVR_3__Sound_664_C
    cmpib #0xb0,%d1
    jbeq rsrc_DRVR_3__Sound_664_C
rsrc_DRVR_3__Sound_596_2A:  /* loop: movem */
    movemw %a1@+,%d0-%d2
    tstw %d2
    jbeq rsrc_DRVR_3__Sound_618_44
    movel %a0,%sp@-
    tstb T1Arbitrate
    jbeq rsrc_DRVR_3__Sound_596_48
    bclr #7,T1Arbitrate
    jbeq rsrc_DRVR_3__Sound_596_64
    clrb T1Arbitrate
rsrc_DRVR_3__Sound_596_48:  /* set %a0 */
    moveal VIA,%a0
    orib #0xc0,%a0@(5632)
    cmpw CurPitch,%d0
    jbeq rsrc_DRVR_3__Sound_596_64
    moveb %d0,%a0@(2048)
    rorw #8,%d0
    moveb %d0,%a0@(2560)
    rorw #8,%d0
rsrc_DRVR_3__Sound_596_64:  /* set CurPitch */
    movew %d0,CurPitch
    movew %d1,%d0
    jbsr rsrc_DRVR_3__Sound_51C
    movew %d2,%d0
    lea %pc@(rsrc_DRVR_3__Sound_618_26),%a1
    jbsr rsrc_DRVR_3__Sound_618
    moveal %sp@+,%a0
    addql #6,%a0@(40)
    jbra rsrc_DRVR_3__Sound_A0_8

/* subroutine (1 instructions) (mechanical summary) */
rsrc_DRVR_3__Sound_616:
    moveq #1,%d0

/* subroutine (22 instructions): traps VInstall; calls rsrc_DRVR_3__Sound_502; low memory SoundActive, SoundDCE, CurPitch (mechanical summary) */
rsrc_DRVR_3__Sound_618:
    lea SoundVBL_qLink,%a0
    movew %d0,%a0@(10)
    tstb SoundActive
    jbne rsrc_DRVR_3__Sound_618_24
    clrl %a0@
    movew #1,%a0@(4)
    movel %a1,%a0@(6)
    clrw %a0@(12)
    _VInstall
    st SoundActive
rsrc_DRVR_3__Sound_618_24:  /* return */
    rts
rsrc_DRVR_3__Sound_618_26:  /* set %a1 */
    moveal SoundDCE,%a1
    moveal %a1@(8),%a0
    movel %a0@(40),%d0
    moveal %a0@(32),%a1
    addal %d0,%a1
    addql #2,%a1
    addqw #4,%d0
    cmpl %a0@(36),%d0
    jblt rsrc_DRVR_3__Sound_596_2A
rsrc_DRVR_3__Sound_618_44:  /* call rsrc_DRVR_3__Sound_502 */
    jbsr rsrc_DRVR_3__Sound_502
    clrw CurPitch

/* VBL task: another synthesizer step (which synthesizer not determined). */
rsrc_DRVR_3__Sound_664:
    jbsr rsrc_DRVR_3__Sound_BC
    jbsr rsrc_DRVR_3__Sound_518
    jbra rsrc_DRVR_3__Sound_2D4
rsrc_DRVR_3__Sound_664_C:  /* set %a0 */
    moveal ASCBase,%a0
    lea %a0@(2048),%a0
    cmpib #1,%a0@(1)
    jbeq rsrc_DRVR_3__Sound_664_36
    clrb %a0@(7)
    clrb %a0@(2)
    moveb #1,%a0@(1)
    bset #7,%a0@(3)
    bclr #7,%a0@(3)
rsrc_DRVR_3__Sound_664_36:  /* set %a1 */
    moveal SoundDCE,%a1
    moveal %a1@(20),%a2
    clrl %a2@
    clrw %a2@(10)
    lea %pc@(rsrc_DRVR_3__Sound_664_50),%a1
    jbsr rsrc_DRVR_3__Sound_22E
    jbra rsrc_DRVR_3__Sound_A0_8
rsrc_DRVR_3__Sound_664_50:  /* save registers */
    moveml %d4-%d6,%sp@-
    movew #1,%a0@(10)
    moveal SoundDCE,%a1
    moveal %a1@(20),%a2
    tstw %a2@(10)
    bnew rsrc_DRVR_3__Sound_664_E0
    moveal SoundDCE,%a1
    moveal %a1@(8),%a0
    movel %a0@(40),%d0
    moveal %a0@(32),%a1
    addal %d0,%a1
    addql #2,%a1
    addqw #4,%d0
    cmpl %a0@(36),%d0
    bltw rsrc_DRVR_3__Sound_664_A0
rsrc_DRVR_3__Sound_664_88:  /* loop: clr */
    clrw CurPitch
    moveal ASCBase,%a0
    clrb %a0@(2049)
    jbsr rsrc_DRVR_3__Sound_BC
    moveml %sp@+,%d4-%d6
    jbra rsrc_DRVR_3__Sound_2D4
rsrc_DRVR_3__Sound_664_A0:  /* set %d0-%d2 */
    movemw %a1@+,%d0-%d2
    tstw %d2
    jbeq rsrc_DRVR_3__Sound_664_88
    moveq #0,%d3
    tstw %d0
    jbeq rsrc_DRVR_3__Sound_664_BC
    movel #295279001,%d3
    divull %d0,%d3,%d3
    movew %d0,CurPitch
rsrc_DRVR_3__Sound_664_BC:  /* set %a2@(4) */
    movel %d3,%a2@(4)
    moveb %d1,SoundLevel
    moveb #0x80,%d0
    lsrb #1,%d1
    moveb %d0,%d3
    subb %d1,%d3
    addb %d0,%d1
    moveb %d3,%a2@(8)
    moveb %d1,%a2@(9)
    movew %d2,%a2@(10)
    addql #6,%a0@(40)
rsrc_DRVR_3__Sound_664_E0:  /* subtract 1 to %a2@(10) */
    subqw #1,%a2@(10)
    movel %a2@,%d0
    movel %a2@(4),%d1
    moveb %a2@(8),%d2
    moveb %a2@(9),%d3
    moveal ASCBase,%a0
    movel #8388608,%d4
    movew #370,%d6
    tstl %d0
    jbne rsrc_DRVR_3__Sound_664_108
    movew #498,%d6
rsrc_DRVR_3__Sound_664_108:  /* loop: add */
    addl %d1,%d0
    movel %d0,%d5
    andl %d4,%d5
    jbne rsrc_DRVR_3__Sound_664_114
    moveb %d3,%a0@
    jbra rsrc_DRVR_3__Sound_664_116
rsrc_DRVR_3__Sound_664_114:  /* set %a0@ */
    moveb %d2,%a0@
rsrc_DRVR_3__Sound_664_116:  /* subtract 1 to %d6 */
    subqw #1,%d6
    jbne rsrc_DRVR_3__Sound_664_108
    movel %d0,%a2@
    moveml %sp@+,%d4-%d6
    rts
rsrc_DRVR_3__Sound_664_122:  /* set SoundPtr */
    movel %a1@+,SoundPtr
    lea %pc@(rsrc_DRVR_3__Sound_79E),%a1
rsrc_DRVR_3__Sound_664_12A:  /* call rsrc_DRVR_3__Sound_616 (loop) */
    jbsr rsrc_DRVR_3__Sound_616
    jbra rsrc_DRVR_3__Sound_A0_8
rsrc_DRVR_3__Sound_796:  /* restore registers */
    moveml %sp@+,%d0-%fp	| 408E6186
    jbra rsrc_DRVR_3__Sound_664	| 408E618A
rsrc_DRVR_3__Sound_79E:  /* save registers */
    moveml %d0-%fp,%sp@-	| 408E618E
    moveal SoundPtr,%fp	| 408E6192
    tstw %fp@	| 408E6196
    jbeq rsrc_DRVR_3__Sound_796	| 408E6198
    lea SoundVBL_qLink,%a0	| 408E619A
    movew #1,%a0@(10)	| 408E619E
    subqw #1,%fp@+	| 408E61A4
    moveml %fp@,%d2-%a5	| 408E61A6
    moveal SoundBase,%fp	| 408E61AA
    .byte   0x22, 0x3C, 0x00, 0xFF	| 408E61AE
    .long   0x00002008 /* number, not a label difference (was rsrc_PACK_5_1FA-.) */	| 408E61B2
    bnes rsrc_DRVR_3__Sound_79E_32
    movel %d6,%d0
    bnes rsrc_DRVR_3__Sound_79E_32
    movel %d4,%d0
    beqs rsrc_DRVR_3__Sound_79E_96
rsrc_DRVR_3__Sound_79E_32:
    lea %fp@(370),%fp
    movew #2,%sp@-
    movew #185,%sp@-
rsrc_DRVR_3__Sound_79E_3E:
    clrw %d1
    addl %d2,%d3
    addl %d4,%d5
    addl %d6,%d7
    addal %a0,%a1
    movel %d3,%d0
    andl %d1,%d0
    swap %d0
    moveb %a2@(0x0,%d0:w),%d1
    movel %d5,%d0
    andl %d1,%d0
    swap %d0
    moveb %a3@(0x0,%d0:w),%d0
    addw %d0,%d1
    movel %d7,%d0
    andl %d1,%d0
    swap %d0
    moveb %a4@(0x0,%d0:w),%d0
    addw %d0,%d1
    movel %a1,%d0
    andl %d1,%d0
    swap %d0
    moveb %a5@(0x0,%d0:w),%d0
    addw %d0,%d1
    lsrw #2,%d1
    moveb %d1,%fp@
    addqw #2,%fp
    subqw #1,%sp@
    bnes rsrc_DRVR_3__Sound_79E_3E
    moveb %a2@(-2),SoundLevel
    moveal SoundBase,%fp
    movew #185,%sp@
    subqw #1,%sp@(2)
    bnes rsrc_DRVR_3__Sound_79E_3E
    bras rsrc_DRVR_3__Sound_79E_FA
rsrc_DRVR_3__Sound_79E_96:
    lea %fp@(140),%fp
    movew #2,%sp@-
    movew #300,%sp@-
    movel %d5,%d0
    andl %d1,%d0
    swap %d0
    moveb %a3@(0x0,%d0:w),%d0
    movew %d0,%sp@-
    movel %d7,%d0
    andl %d1,%d0
    swap %d0
    moveb %a4@(0x0,%d0:w),%d0
    addw %d0,%sp@
    movel %a1,%d0
    andl %d1,%d0
    swap %d0
    moveb %a5@(0x0,%d0:w),%d0
    addw %d0,%sp@
rsrc_DRVR_3__Sound_79E_C6:
    clrw %d1
    addl %d2,%d3
    movel %d3,%d0
    andl %d1,%d0
    swap %d0
    moveb %a2@(0x0,%d0:w),%d1
    addw %sp@,%d1
    lsrw #2,%d1
    moveb %d1,%fp@
    addqw #2,%fp
    subqw #1,%sp@(2)
    bnes rsrc_DRVR_3__Sound_79E_C6
    moveb %a2@(-2),SoundLevel
    moveal SoundBase,%fp
    movew #70,%sp@(2)
    subqw #1,%sp@(4)
    bnes rsrc_DRVR_3__Sound_79E_C6
    addqw #2,%sp
rsrc_DRVR_3__Sound_79E_FA:
    addqw #4,%sp
    moveal SoundPtr,%fp
    addqw #2,%fp
    moveml %d2-%a1,%fp@
    moveml %sp@+,%d0-%fp
    rts
rsrc_DRVR_3__Sound_8AA:  /* set %a1 */
    moveal SoundDCE,%a1
    clrl %a1@(16)
    lea %pc@(rsrc_DRVR_3__Sound_8BA),%a1
    jbra rsrc_DRVR_3__Sound_664_12A
rsrc_DRVR_3__Sound_8BA:  /* loop: movea */
    moveal SoundDCE,%a1
    movel %a1@(8),%d0
    jbne rsrc_DRVR_3__Sound_8CE
    jbsr rsrc_DRVR_3__Sound_BC
    jbsr rsrc_DRVR_3__Sound_518
    rts
rsrc_DRVR_3__Sound_8CE:  /* set %a0 */
    moveal %d0,%a0
    movel %a0@(40),%d0
    cmpl %a0@(36),%d0
    jblt rsrc_DRVR_3__Sound_8E0
    jbsr rsrc_DRVR_3__Sound_664
    jbra rsrc_DRVR_3__Sound_8BA
rsrc_DRVR_3__Sound_8E0:  /* set %d3 */
    movel %a1@(16),%d3
    lea SoundVBL_qLink,%a3
    movew #1,%a3@(10)
    movel %a4,%sp@-
    moveal %a0@(32),%a1
    addqw #2,%a1
    movel %a1@+,%d1
    moveal %a1,%a3
    addal %a0@(36),%a3
    addal %d0,%a1
    moveal SoundBase,%a2
    lea %a2@(64),%a2
    lea %a2@(676),%a4
    clrw %sp@-
    movew #337,%d2
rsrc_DRVR_3__Sound_912:  /* loop: moveq */
    moveq #0,%d0
rsrc_DRVR_3__Sound_914:  /* loop: move */
    moveb %a1@,%a2@
    addqw #2,%a2
    addl %d1,%d3
    swap %d3
    addaw %d3,%a1
    addw %d3,%d0
    clrw %d3
    swap %d3
    cmpal %a1,%a3
    dble %d2,rsrc_DRVR_3__Sound_914
    addl %d0,%a0@(40)
    tstw %sp@+
    jbeq rsrc_DRVR_3__Sound_968
    tstw %d2
    jbmi rsrc_DRVR_3__Sound_948
rsrc_DRVR_3__Sound_936:  /* loop: moveq */
    moveq #0,%d0
rsrc_DRVR_3__Sound_938:  /* loop: move */
    moveb %d0,%a2@
    addqw #2,%a2
    cmpal %a2,%a4
    jbgt rsrc_DRVR_3__Sound_944
    moveal SoundBase,%a2
rsrc_DRVR_3__Sound_944:  /* count down */
    dbf %d2,rsrc_DRVR_3__Sound_938
rsrc_DRVR_3__Sound_948:  /* set %a1 */
    moveal SoundDCE,%a1
    movel %d3,%a1@(16)
    moveb %a2@(-2),SoundLevel
    moveal %sp@+,%a4
    movel %a0@(40),%d0
    cmpl %a0@(36),%d0
    jblt rsrc_DRVR_3__Sound_966
    jbsr rsrc_DRVR_3__Sound_2D4
rsrc_DRVR_3__Sound_966:  /* return */
    rts
rsrc_DRVR_3__Sound_968:  /* test %d2 */
    tstw %d2
    jbmi rsrc_DRVR_3__Sound_972
    addiw #32,%d2
    jbra rsrc_DRVR_3__Sound_936
rsrc_DRVR_3__Sound_972:  /* set %sp@- */
    movew #1,%sp@-
    moveal SoundBase,%a2
    moveq #31,%d2
    jbra rsrc_DRVR_3__Sound_912
    .short  0x0000	| 408E636E
