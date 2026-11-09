/* ROM resource 'CDEF' 1: map entry at 0x40879290, data at 0x408792C0, 1488 bytes

 Control definition 1: the scroll bar (control definition ID 16, scrollBarProc), arrows,
 track and thumb, in the control's colours ('cctb') on Color QuickDraw. Messages 0-6
 index the table rsrc_CDEF_1_C6 directly, 10 and 11 as entries 7 and 8. Comments inferred
 from the code (and the control definition messages in Inside Macintosh).
*/

rsrc_CDEF_1_entry:      /* map entry */
    .long   0x78000000, 0x00000000	| 40879290
    .long   rsrc_MBDF_0_entry-rom_start	| 40879298
    .long   rsrc_CDEF_1-rom_start	| 4087929C
    .ascii  "CDEF"	| 408792A0
    .byte   0x00, 0x01, 0x58, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408792A4
    .long   0x00000000, 0xC0A00000, 0x000005DC, 0x000000F4	| 408792B0

/* Entry: a branch over the standard header ('CDEF', ID 1). */
rsrc_CDEF_1:
    jbra rsrc_CDEF_1_C
    .short  0x0000, 0x4344, 0x4546, 0x0001, 0x000A	| 408792C2

rsrc_CDEF_1_C:          /* from here: linkw %fp,#-50 */
    linkw %fp,#-50
    moveml %d3-%d6/%a1-%a4,%sp@-
    cmpiw #6,%fp@(12)
    jbls rsrc_CDEF_1_C_22
    cmpiw #10,%fp@(12)
    jbeq rsrc_CDEF_1_C_22
    cmpiw #11,%fp@(12)
    jbne rsrc_CDEF_1_C_AC
rsrc_CDEF_1_C_22:       /* set up and call _GetPenState */
    pea %fp@(-20)
    _GetPenState
    _PenNormal
    cmpiw #16383,ROM85
    sls %fp@(-22)
    jbhi rsrc_CDEF_1_C_68
    moveal %a5@,%a0
    moveal %a0@,%a0
    pea %fp@(-44)
    _GetForeColor
    pea %fp@(-50)
    _GetBackColor
    clrl %sp@-
    clrb %sp@-
    movel %fp@(14),%sp@-
    pea %sp@(6)
    _GetAuxCtl
    addqw #2,%sp
    moveal %sp@+,%a0
    moveal %a0@,%a0
    moveal %a0@(8),%a0
    movel %a0,%fp@(-34)
    _HLock
    movel %a0@,%fp@(-38)
rsrc_CDEF_1_C_68:       /* address %fp@(8) */
    lea %fp@(8),%a0
    movel %a0@+,%d3
    movew %a0@+,%d0
    moveal %a0@+,%a3
    movew %a0@+,%d6
    clrl %a0@
    moveal %a3@,%a0
    cmpiw #6,%d0
    blsw rsrc_CDEF_1_C_82
    subqw #3,%d0
rsrc_CDEF_1_C_82:       /* from here: addw %d0,%d0 */
    addw %d0,%d0
    lea %pc@(rsrc_CDEF_1_C6),%a1
    addaw %a1@(0x0,%d0:w),%a1
    jsr %a1@
    pea %fp@(-20)
    _SetPenState
    tstb %fp@(-22)
    jbeq rsrc_CDEF_1_C_AC
    moveal %fp@(-34),%a0
    _HUnlock
    pea %fp@(-44)
    _RGBForeColor
    pea %fp@(-50)
    _RGBBackColor
rsrc_CDEF_1_C_AC:       /* restore registers, return */
    moveml %sp@+,%d3-%d6/%a1-%a4
    unlk %fp
    moveal %sp@+,%a0
    lea %sp@(12),%sp
    jmp %a0@
rsrc_CDEF_1_C6:         /* message table (offsets from here): 0 draw, 1 test, 2 calculate regions, 3 init, 4 dispose, 5 position, 6 thumb, 7 (10) control region, 8 (11) thumb region */
    .short  rsrc_CDEF_1_200-rsrc_CDEF_1_C6	| 40879386
    .short  rsrc_CDEF_1_3EC-rsrc_CDEF_1_C6	| 40879388
    .short  rsrc_CDEF_1_48E-rsrc_CDEF_1_C6	| 4087938A
    .short  rsrc_CDEF_1_52A-rsrc_CDEF_1_C6	| 4087938C
    .short  rsrc_CDEF_1_536-rsrc_CDEF_1_C6	| 4087938E
    .short  rsrc_CDEF_1_4D8-rsrc_CDEF_1_C6	| 40879390
    .short  rsrc_CDEF_1_556-rsrc_CDEF_1_C6	| 40879392
    .short  rsrc_CDEF_1_4B2-rsrc_CDEF_1_C6	| 40879394
    .short  rsrc_CDEF_1_4C2-rsrc_CDEF_1_C6	| 40879396
rsrc_CDEF_1_D8:         /* (data) */
    .byte   0xFF, 0xFF, 0x80, 0x81, 0x80, 0xC1, 0x80, 0xA1, 0x8F, 0x91, 0x88, 0x09, 0x88, 0x05, 0x88, 0x03	| 40879398
    .byte   0x88, 0x05, 0x88, 0x09, 0x8F, 0x91, 0x80, 0xA1, 0x80, 0xC1, 0x80, 0x81, 0x80, 0x01, 0xFF, 0xFF	| 408793A8
    .byte   0xFF, 0xFF, 0x80, 0x81, 0x80, 0xC1, 0x80, 0xE1, 0x8F, 0xF1, 0x8F, 0xF9, 0x8F, 0xFD, 0x8F, 0xFF	| 408793B8
    .byte   0x8F, 0xFD, 0x8F, 0xF9, 0x8F, 0xF1, 0x80, 0xE1, 0x80, 0xC1, 0x80, 0x81, 0x80, 0x01, 0xFF, 0xFF	| 408793C8
rsrc_CDEF_1_118:        /* (data) */
    .byte   0xFF, 0xFF, 0x81, 0x01, 0x83, 0x01, 0x85, 0x01, 0x89, 0xF1, 0x90, 0x11, 0xA0, 0x11, 0xC0, 0x11	| 408793D8
    .byte   0xA0, 0x11, 0x90, 0x11, 0x89, 0xF1, 0x85, 0x01, 0x83, 0x01, 0x81, 0x01, 0x80, 0x01, 0xFF, 0xFF	| 408793E8
    .byte   0xFF, 0xFF, 0x81, 0x01, 0x83, 0x01, 0x87, 0x01, 0x8F, 0xF1, 0x9F, 0xF1, 0xBF, 0xF1, 0xFF, 0xF1	| 408793F8
    .byte   0xBF, 0xF1, 0x9F, 0xF1, 0x8F, 0xF1, 0x87, 0x01, 0x83, 0x01, 0x81, 0x01, 0x80, 0x01, 0xFF, 0xFF	| 40879408
    .byte   0xFF, 0xFF, 0x80, 0x01, 0x80, 0x01, 0x8F, 0xE1, 0x88, 0x21, 0x88, 0x21, 0x88, 0x21, 0xF8, 0x3D	| 40879418
    .byte   0xA0, 0x09, 0x90, 0x11, 0x88, 0x21, 0x84, 0x41, 0x82, 0x81, 0x81, 0x01, 0x80, 0x01, 0xFF, 0xFF	| 40879428
    .byte   0xFF, 0xFF, 0x80, 0x01, 0x80, 0x01, 0x8F, 0xE1, 0x8F, 0xE1, 0x8F, 0xE1, 0x8F, 0xE1, 0xFF, 0xFD	| 40879438
    .byte   0xBF, 0xF9, 0x9F, 0xF1, 0x8F, 0xE1, 0x87, 0xC1, 0x83, 0x81, 0x81, 0x01, 0x80, 0x01, 0xFF, 0xFF	| 40879448
    .byte   0xFF, 0xFF, 0x80, 0x01, 0x81, 0x01, 0x82, 0x81, 0x84, 0x41, 0x88, 0x21, 0x90, 0x11, 0xA0, 0x09	| 40879458
    .byte   0xF8, 0x3D, 0x88, 0x21, 0x88, 0x21, 0x88, 0x21, 0x8F, 0xE1, 0x80, 0x01, 0x80, 0x01, 0xFF, 0xFF	| 40879468
    .byte   0xFF, 0xFF, 0x80, 0x01, 0x81, 0x01, 0x83, 0x81, 0x87, 0xC1, 0x8F, 0xE1, 0x9F, 0xF1, 0xBF, 0xF9	| 40879478
    .byte   0xFF, 0xFD, 0x8F, 0xE1, 0x8F, 0xE1, 0x8F, 0xE1, 0x8F, 0xE1, 0x80, 0x01, 0x80, 0x01, 0xFF, 0xFF	| 40879488

/* subroutine (14 instructions) (mechanical summary) */
rsrc_CDEF_1_1D8:
    movel %d1,%sp@-	| 40879498
    moveal %fp@(-38),%a0	| 4087949A
    movew %a0@(6),%d1	| 4087949E
    muluw #8,%d1	| 408794A2
rsrc_CDEF_1_1E6:        /* loop: cmp */
    cmpw %a0@(8,%d1:w),%d0	| 408794A6
    jbeq rsrc_CDEF_1_1F2	| 408794AA
    subqw #8,%d1	| 408794AC
    jbge rsrc_CDEF_1_1E6	| 408794AE
    moveq #0,%d1	| 408794B0
rsrc_CDEF_1_1F2:        /* (408794B2 lea %a0@(a,%d1:w),%a0) */
    lea %a0@(0xa,%d1:w),%a0	| 408794B2
    movel %a0,%d0	| 408794B6
    movel %sp@+,%d1	| 408794B8
    moveal %sp@+,%a0	| 408794BA
    movel %d0,%sp@-	| 408794BC
    jmp %a0@	| 408794BE

/*
 Message 0, draw (param: the part to draw, 0 all): arrows (normal or pressed), the
 track pattern and the thumb, dimmed when the control is inactive (hilite 255).
*/
rsrc_CDEF_1_200:
    tstb %fp@(-22)	| 408794C0
    jbeq rsrc_CDEF_1_214	| 408794C4
    moveq #0,%d0	| 408794C6
    jbsr rsrc_CDEF_1_1D8	| 408794C8
    _RGBForeColor	| 408794CA
    moveq #1,%d0	| 408794CC
    jbsr rsrc_CDEF_1_1D8	| 408794CE
    _RGBBackColor	| 408794D0
    moveal %a3@,%a0	| 408794D2
rsrc_CDEF_1_214:        /* test %a0@(16) */
    tstb %a0@(16)	| 408794D4
    jbeq rsrc_CDEF_1_2B8	| 408794D8
    cmpib #0xff,%d3	| 408794DC
    jbne rsrc_CDEF_1_224	| 408794E0
    moveq #0,%d3	| 408794E2
rsrc_CDEF_1_224:        /* set %d4 */
    moveb %a0@(17),%d4	| 408794E4
    jbsr rsrc_CDEF_1_3D8	| 408794E8
    jbsr rsrc_CDEF_1_302	| 408794EC
    movew %a1@(0,%d0:w),%d1	| 408794F0
    addw %d2,%d1	| 408794F4
    movew %d1,%a1@(4,%d0:w)	| 408794F6
    lea %pc@(rsrc_CDEF_1_118),%a1	| 408794FA
    moveq #20,%d1	| 408794FE
    movemw %d0/%d2,%sp@-	| 40879500
    jbsr rsrc_CDEF_1_2B2	| 40879504
    jbne rsrc_CDEF_1_24C	| 40879506
    jbsr rsrc_CDEF_1_320	| 40879508
rsrc_CDEF_1_24C:        /* call rsrc_CDEF_1_3D8 */
    jbsr rsrc_CDEF_1_3D8	| 4087950C
    movemw %sp@+,%d0/%d2	| 40879510
    movew %a1@(4,%d0:w),%d1	| 40879514
    subw %d2,%d1	| 40879518
    movew %d1,%a1@(0,%d0:w)	| 4087951A
    lea %pc@(rsrc_CDEF_1_D8),%a1	| 4087951E
    moveq #21,%d1	| 40879522
    jbsr rsrc_CDEF_1_2B2	| 40879524
    jbne rsrc_CDEF_1_26C	| 40879526
    jbsr rsrc_CDEF_1_320	| 40879528
rsrc_CDEF_1_26C:        /* test #1,%d6 */
    cmpiw #1,%d6	| 4087952C
    jbeq rsrc_CDEF_1_2F8	| 40879530
    movew #129,%d1	| 40879534
    jbsr rsrc_CDEF_1_2B2	| 40879538
    jbne rsrc_CDEF_1_2B8	| 4087953A
    jbsr rsrc_CDEF_1_3D8	| 4087953C
    movel %a1,%sp@-	| 40879540
    jbsr rsrc_CDEF_1_4CA	| 40879542
    movel %a0,%sp@-	| 40879546
    jbsr rsrc_CDEF_1_2BA	| 40879548
    jbne rsrc_CDEF_1_294	| 4087954A
    moveal %a5@,%a0	| 4087954C
    lea %a0@(-8),%a0	| 4087954E
    movel %a0,%sp@	| 40879552
rsrc_CDEF_1_294:        /* address 0x9fa */
    lea Scratch8,%a1	| 40879554
    moveal %a1,%a0	| 40879558
    jbsr rsrc_CDEF_1_302	| 4087955A
    swap %d2	| 4087955C
    movew #1,%d2	| 4087955E
    tstw %d0	| 40879562
    jbeq rsrc_CDEF_1_2A8	| 40879564
    swap %d2	| 40879566
rsrc_CDEF_1_2A8:        /* set %sp@- */
    movel %a1,%sp@-	| 40879568
    movel %d2,%sp@-	| 4087956A
    _InsetRect	| 4087956C
    _FillRect
    jbra rsrc_CDEF_1_2D2	| 40879570

/* subroutine (4 instructions) (mechanical summary) */
rsrc_CDEF_1_2B2:
    tstw %d3	| 40879572
    jbeq rsrc_CDEF_1_2B8	| 40879574
    cmpw %d1,%d3	| 40879576
rsrc_CDEF_1_2B8:        /* return */
    rts	| 40879578

/* Frame and fill the thumb (its region). */
rsrc_CDEF_1_2BA:
    moveal %a3@,%a0	| 4087957A
    moveb %a0@(17),%d0	| 4087957C
    addqb #1,%d0	| 40879580
    jbeq rsrc_CDEF_1_2D0	| 40879582
    addqb #1,%d0	| 40879584
    jbeq rsrc_CDEF_1_2D0	| 40879586
    movew %a0@(20),%d0	| 40879588
    cmpw %a0@(22),%d0	| 4087958C
rsrc_CDEF_1_2D0:        /* return */
    rts	| 40879590
rsrc_CDEF_1_2D2:        /* test %fp@(-22) */
    tstb %fp@(-22)	| 40879592
    jbeq rsrc_CDEF_1_2E0	| 40879596
    moveq #3,%d0	| 40879598
    jbsr rsrc_CDEF_1_1D8	| 4087959A
    _RGBBackColor	| 4087959E
rsrc_CDEF_1_2E0:        /* call rsrc_CDEF_1_36A */
    jbsr rsrc_CDEF_1_36A	| 408795A0
    jbsr rsrc_CDEF_1_2BA	| 408795A4
    jbeq rsrc_CDEF_1_2F8	| 408795A6
    movel %a0@(28),%sp@-	| 408795A8
    movel %sp@,%sp@-	| 408795AC
    moveal %a5@,%a0	| 408795AE
    pea %a0@(-8)	| 408795B0
    _FillRgn	| 408795B4
    .short  0xA8D2	| _FrameRgn
rsrc_CDEF_1_2F8:        /* set %a0 */
    moveal %a3@,%a0	| 408795B8
    pea %a0@(8)	| 408795BA
    _FrameRect	| 408795BE
    rts	| 408795C0

/* subroutine (12 instructions) (mechanical summary) */
rsrc_CDEF_1_302:
    movew %a0@(4),%d0
    subw %a0@,%d0
    movew %a0@(6),%d1
    subw %a0@(2),%d1
    cmpw %d0,%d1
    jbgt rsrc_CDEF_1_302_18
    movew %d1,%d2
    moveq #0,%d0
    rts
rsrc_CDEF_1_302_18:     /* set %d2 */
    movew %d0,%d2
    moveq #2,%d0
    rts

/* subroutine (10 instructions): calls rsrc_CDEF_1_33A (mechanical summary) */
rsrc_CDEF_1_320:
    moveal %a3@,%a0	| 408795E0
    cmpb %a0@(17),%d1	| 408795E2
    jbne rsrc_CDEF_1_32C	| 408795E6
    lea %a1@(32),%a1	| 408795E8
rsrc_CDEF_1_32C:        /* test %d0 */
    tstw %d0	| 408795EC
    jbne rsrc_CDEF_1_334	| 408795EE
    lea %a1@(128),%a1	| 408795F0
rsrc_CDEF_1_334:        /* clear %d0 */
    clrw %d0	| 408795F4
    jbsr rsrc_CDEF_1_33A	| 408795F6
    rts	| 408795F8

/* CopyBits of a 16x16 arrow image. */
rsrc_CDEF_1_33A:
    lea IconBitmap,%a0	| 408795FA
    movel %a1,%a0@+	| 408795FE
    movew #2,%a0@+	| 40879600
    clrl %a0@+	| 40879604
    movel #1048592,%a0@	| 40879606
    pea IconBitmap	| 4087960C
    moveal %sp@,%a0	| 40879610
    moveal %a5@,%a1	| 40879612
    moveal %a1@,%a1	| 40879614
    pea %a1@(2)	| 40879616
    pea %a0@(6)	| 4087961A
    pea Scratch8	| 4087961E
    movew %d0,%sp@-	| 40879622
    clrl %sp@-	| 40879624
    _CopyBits	| 40879626
    rts	| 40879628

/* Thumb region from the control's value, minimum and maximum (position along the track). */
rsrc_CDEF_1_36A:
    movew %d3,%sp@-	| 4087962A
    lea %fp@(-30),%a1	| 4087962C
    jbsr rsrc_CDEF_1_3DC	| 40879630
    moveq #0,%d1	| 40879632
    moveal %a3@,%a0	| 40879634
    lea %a0@(8),%a0	| 40879636
    jbsr rsrc_CDEF_1_302	| 4087963A
    movew %d2,%d3	| 4087963C
    movew %a0@(4,%d0:w),%d1	| 4087963E
    subw %a0@(0,%d0:w),%d1	| 40879642
    subw %d2,%d1	| 40879646
    subw %d2,%d1	| 40879648
    subw %d2,%d1	| 4087964A
    moveal %a3@,%a0	| 4087964C
    movew %a0@(18),%d2	| 4087964E
    subw %a0@(20),%d2	| 40879652
    muluw %d2,%d1	| 40879656
    movew %a0@(22),%d2	| 40879658
    subw %a0@(20),%d2	| 4087965C
    jbeq rsrc_CDEF_1_3D4	| 40879660
    divuw %d2,%d1	| 40879662
    jbsr rsrc_CDEF_1_53E	| 40879664
    addw %d3,%d1	| 40879668
rsrc_CDEF_1_3AA:        /* loop: lea */
    lea %fp@(-30),%a1	| 4087966A
    addw %a1@(0,%d0:w),%d1	| 4087966E
    movew %d1,%a1@(0,%d0:w)	| 40879672
    addw %d3,%d1	| 40879676
    movew %d1,%a1@(4,%d0:w)	| 40879678
    eoriw #2,%d0	| 4087967C
    addqw #1,%a1@(0,%d0:w)	| 40879680
    subqw #1,%a1@(4,%d0:w)	| 40879684
    movel %a0@(28),%sp@-	| 40879688
    movel %a1,%sp@-	| 4087968C
    _RectRgn	| 4087968E
    movew %sp@+,%d3	| 40879690
    rts	| 40879692
rsrc_CDEF_1_3D4:        /* set %d1 */
    movew %d3,%d1	| 40879694
    jbra rsrc_CDEF_1_3AA	| 40879696

/* subroutine (1 instructions) (mechanical summary) */
rsrc_CDEF_1_3D8:
    lea Scratch8,%a1	| 40879698

/* subroutine (5 instructions) (mechanical summary) */
rsrc_CDEF_1_3DC:
    moveal %a3@,%a0	| 4087969C
    lea %a0@(8),%a0	| 4087969E
    movel %a0@,%a1@	| 408796A2
    movel %a0@(4),%a1@(4)	| 408796A4
rsrc_CDEF_1_3EA:        /* return */
    rts	| 408796AA

/*
 Message 1, test (param = the point): the part under it: 20 up arrow, 21 down arrow, 22
 page up, 23 page down, 129 thumb, 0 none (and 0 when inactive).
*/
rsrc_CDEF_1_3EC:
    moveb %a0@(17),%d4	| 408796AC
    cmpib #0xfe,%d4	| 408796B0
    jbeq rsrc_CDEF_1_3FC	| 408796B4
    jbsr rsrc_CDEF_1_2BA	| 408796B6
    jbeq rsrc_CDEF_1_3EA	| 408796BA
rsrc_CDEF_1_3FC:        /* address %a0@(8) */
    lea %a0@(8),%a4	| 408796BC
    clrw %sp@-	| 408796C0
    movel %d3,%sp@-	| 408796C2
    movel %a4,%sp@-	| 408796C4
    _PtInRect	| 408796C6
    tstb %sp@+	| 408796C8
    jbeq rsrc_CDEF_1_3EA	| 408796CA
    addqb #2,%d4	| 408796CC
    jbeq rsrc_CDEF_1_432	| 408796CE
    jbsr rsrc_CDEF_1_482	| 408796D0
    movew %d3,%d1	| 408796D2
    subw %a4@(0,%d0:w),%d1	| 408796D4
    cmpw %d2,%d1	| 408796D8
    jbgt rsrc_CDEF_1_420	| 408796DA
    moveq #20,%d0
    jbra rsrc_CDEF_1_302_12A
rsrc_CDEF_1_420:        /* set %d1 */
    movew %a4@(4,%d0:w),%d1	| 408796E0
    subw %d3,%d1	| 408796E4
    cmpw %d2,%d1	| 408796E6
    jbgt rsrc_CDEF_1_438	| 408796E8
    moveq #21,%d0	| 408796EA
rsrc_CDEF_1_302_12A:    /* loop: move */
    movew %d0,%fp@(22)
    rts
rsrc_CDEF_1_432:        /* set %d0 */
    movew #254,%d0
    jbra rsrc_CDEF_1_302_12A
rsrc_CDEF_1_438:        /* test #1,%d6 */
    cmpiw #1,%d6	| 408796F8
    jbeq rsrc_CDEF_1_3EA	| 408796FC
    jbsr rsrc_CDEF_1_36A	| 408796FE
    jbsr rsrc_CDEF_1_482	| 40879702
    clrw %sp@-	| 40879704
    movel %d3,%sp@-	| 40879706
    moveal %a3@,%a0	| 40879708
    movel %a0@(28),%sp@-	| 4087970A
    _PtInRgn	| 4087970E
    tstb %sp@+	| 40879710
    jbeq rsrc_CDEF_1_45A	| 40879712
    movew #129,%d0
    jbra rsrc_CDEF_1_302_12A
rsrc_CDEF_1_45A:        /* call rsrc_CDEF_1_482 */
    jbsr rsrc_CDEF_1_482	| 4087971A
    moveal %a3@,%a0	| 4087971C
    moveal %a0@(28),%a0
    moveal %a0@,%a0
    lea %a0@(2),%a0
    movew %a0@(0x4,%d0:w),%d1
    subw %a0@(0x0,%d0:w),%d1
    lsrw #1,%d1
    addw %a0@(0x0,%d0:w),%d1
    cmpw %d1,%d3
    jblt rsrc_CDEF_1_302_17C
    moveq #23,%d0
    jbra rsrc_CDEF_1_302_12A
rsrc_CDEF_1_302_17C:    /* result 22 */
    moveq #22,%d0
    jbra rsrc_CDEF_1_302_12A

/* subroutine (5 instructions): calls rsrc_CDEF_1_302 (mechanical summary) */
rsrc_CDEF_1_482:
    moveal %a4,%a0	| 40879742
    jbsr rsrc_CDEF_1_302
    jbne rsrc_CDEF_1_302_18A
    swap %d3
rsrc_CDEF_1_302_18A:    /* return */
    rts

/* Message 2, calculate regions: the control's region (param high bit set: the thumb's). */
rsrc_CDEF_1_48E:
    tstl %d3	| 4087974E
    jbpl rsrc_CDEF_1_4B8	| 40879750
    andil #16777215,%d3	| 40879752
rsrc_CDEF_1_498:        /* call rsrc_CDEF_1_36A (loop) */
    jbsr rsrc_CDEF_1_36A	| 40879758
    moveal %a3@,%a0	| 4087975C
    movel %a0@(28),%sp@-	| 4087975E
    movel %d3,%sp@-	| 40879762
    _CopyRgn	| 40879764
    jbsr rsrc_CDEF_1_4CA	| 40879766
    movel %a0@+,DragPattern	| 40879768
    movel %a0@,DragPattern_1	| 4087976C
    rts	| 40879770

/* Message 10, control region: the control rectangle as a region. */
rsrc_CDEF_1_4B2:
    moveb #1,%fp@(23)	| 40879772
rsrc_CDEF_1_4B8:        /* set %sp@- */
    movel %d3,%sp@-	| 40879778
    pea %a0@(8)	| 4087977A
    _RectRgn	| 4087977E
    rts	| 40879780

/* Message 11, thumb region. */
rsrc_CDEF_1_4C2:
    moveb #1,%fp@(23)	| 40879782
    jbra rsrc_CDEF_1_498	| 40879788

/* subroutine (6 instructions): traps GetPattern (mechanical summary) */
rsrc_CDEF_1_4CA:
    subqw #4,%sp	| 4087978A
    movew #17,%sp@-	| 4087978C
    _GetPattern	| 40879790
    moveal %sp@+,%a0	| 40879792
    moveal %a0@,%a0	| 40879794
    rts	| 40879796

/*
 Message 5, position: after the thumb was dragged by param, compute the new value
 (SetCtlValue).
*/
rsrc_CDEF_1_4D8:
    moveal %a0@(28),%a0	| 40879798
    moveal %a0@,%a0	| 4087979C
    lea %a0@(2),%a4	| 4087979E
    addw %a4@(2),%d3	| 408797A2
    swap %d3	| 408797A6
    addw %a4@,%d3	| 408797A8
    moveal %a3@,%a0	| 408797AA
    lea %a0@(8),%a0	| 408797AC
    jbsr rsrc_CDEF_1_302	| 408797B0
    jbeq rsrc_CDEF_1_4F8	| 408797B4
    swap %d3	| 408797B6
rsrc_CDEF_1_4F8:        /* from here: subw %a0@(0,%d0:w),%d3 */
    subw %a0@(0,%d0:w),%d3	| 408797B8
    subw %d2,%d3	| 408797BC
    movew %a0@(4,%d0:w),%d1	| 408797BE
    subw %a0@(0,%d0:w),%d1	| 408797C2
    subw %d2,%d1	| 408797C6
    subw %d2,%d1	| 408797C8
    subw %d2,%d1	| 408797CA
    movew %d1,%d2	| 408797CC
    moveal %a3@,%a0	| 408797CE
    movew %a0@(22),%d1	| 408797D0
    subw %a0@(20),%d1	| 408797D4
    muluw %d3,%d1	| 408797D8
    divuw %d2,%d1	| 408797DA
    jbsr rsrc_CDEF_1_53E	| 408797DC
    addw %a0@(20),%d1	| 408797DE
    movel %a3,%sp@-	| 408797E2
    movew %d1,%sp@-	| 408797E4
    .short  0xA963	| 408797E6 _SetCtlValue
    rts	| 408797E8

/* Message 3, init: a region for the thumb. */
rsrc_CDEF_1_52A:
    subqw #4,%sp	| 408797EA
    _NewRgn	| 408797EC
    moveal %a3@,%a0	| 408797EE
    movel %sp@+,%a0@(28)	| 408797F0
    rts	| 408797F4

/* Message 4, dispose: free it. */
rsrc_CDEF_1_536:
    moveal %a0@(28),%a0	| 408797F6
    _DisposHandle	| 408797FA
    rts	| 408797FC

/* subroutine (12 instructions) (mechanical summary) */
rsrc_CDEF_1_53E:
    movew %d0,%sp@-	| 408797FE
    movew %d2,%d0	| 40879800
    lsrw #1,%d0	| 40879802
    swap %d1	| 40879804
    cmpw %d0,%d1	| 40879806
    jble rsrc_CDEF_1_552	| 40879808
    swap %d1	| 4087980A
    addqw #1,%d1	| 4087980C
rsrc_CDEF_1_54E:        /* loop: move */
    movew %sp@+,%d0	| 4087980E
    rts	| 40879810
rsrc_CDEF_1_552:        /* from here: swap %d1 */
    swap %d1	| 40879812
    jbra rsrc_CDEF_1_54E	| 40879814

/* Message 6, thumb: the limits and slop rectangle for dragging the thumb. */
rsrc_CDEF_1_556:
    moveal %d3,%a4	| 40879816
    movel %a4@,%d3	| 40879818
    lea %a4@,%a2	| 4087981A
    moveal %a2,%a1	| 4087981C
    jbsr rsrc_CDEF_1_3DC	| 4087981E
    moveal %a2,%a0	| 40879822
    jbsr rsrc_CDEF_1_302	| 40879824
    movew %d2,%sp@-	| 40879828
    swap %d2	| 4087982A
    movew #-24,%d2	| 4087982C
    movew %d0,%d4	| 40879830
    jbeq rsrc_CDEF_1_578	| 40879832
    swap %d2	| 40879834
    jbra rsrc_CDEF_1_57A	| 40879836
rsrc_CDEF_1_578:        /* from here: swap %d3 */
    swap %d3	| 40879838
rsrc_CDEF_1_57A:        /* set %sp@- */
    movel %a2,%sp@-	| 4087983A
    movel %d2,%sp@-	| 4087983C
    _InsetRect	| 4087983E
    lea %a4@(8),%a0	| 40879840
    movel %a4@,%a0@	| 40879844
    movel %a4@(4),%a0@(4)	| 40879846
    movel #-8388608,%d0	| 4087984C
    tstw %d4	| 40879852
    jbeq rsrc_CDEF_1_598	| 40879854
    swap %d0	| 40879856
rsrc_CDEF_1_598:        /* set %sp@- */
    movel %a0,%sp@-	| 40879858
    movel %d0,%sp@-	| 4087985A
    _InsetRect	| 4087985C
    moveal %a3@,%a0	| 4087985E
    moveal %a0@(28),%a0	| 40879860
    moveal %a0@,%a0	| 40879864
    subw %a0@(2,%d4:w),%d3	| 40879866
    addw %d3,%a2@(0,%d4:w)	| 4087986A
    movew %sp@+,%d2	| 4087986E
    subqw #1,%d2	| 40879870
    subw %d2,%a2@(4,%d4:w)	| 40879872
    addw %d3,%a2@(4,%d4:w)	| 40879876
    lsrw #1,%d4	| 4087987A
    eoriw #1,%d4	| 4087987C
    addqw #1,%d4	| 40879880
    movew %d4,%a4@(16)	| 40879882
    rts	| 40879886
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40879888
