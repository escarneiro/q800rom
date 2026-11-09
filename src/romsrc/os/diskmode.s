/*
 os/diskmode.s - SCSI disk mode
 From SCSIDISKMODE (0x408B83D0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple. SCSI disk mode (PowerBooks):
 the Macintosh boots as a SCSI target so another computer can use its internal disk.
 It shows an animated picture of the SCSI ID ('PICT' 95..101 from the ROM) and serves
 the commands in a loop, then powers off. fp frame: -336 the SCSI ID (XPRAM 0x03 bits
 5-7, default 1), -340 state flags, -382/-378 counters, -370 .Backlight refnum.
*/

/*
 SCSIDISKMODE: if disk mode is selected (TESTFORDISKMODE), take over the interrupt
 vectors, show the disk mode screen, set up the SCSI chip as a target with our ID and
 serve the bus until it ends, then power off.
*/
SCSIDISKMODE:
    jbsr TESTFORDISKMODE
    jbeq SCSIDISKMODE_52
    lea %pc@(SCSIDISKMODE_4E),%a0
    movel %a0,0x70
    movel %a0,0x74
    movel %a0,0x78
    movel %a0,0x7c
    moveq #0,%d7
    linkw %fp,#-502
    moveal SCSIGlobals,%a4
    movel %fp,%a4@(264)
    jbsr TESTFORDISKMODE_77A
    jbsr SCSIDISKWAKEALERT_8A
    jbsr SCSIDISKWAKEALERT_108
    jbeq SCSIDISKMODE_4E
    jbsr SCSIDISKWAKEALERT_2D4
    jbsr SCSIDISKWAKEALERT_380
    jbsr TESTFORDISKMODE_42
    jbsr TESTFORDISKMODE_63A
    jbsr SCSIDISKWAKEALERT_78
    jbsr TESTFORDISKMODE_B8
SCSIDISKMODE_4E:        /* power off */
    _PowerOff
SCSIDISKMODE_50:        /* (if it returns) */
    jbra SCSIDISKMODE_50
SCSIDISKMODE_52:        /* not in disk mode */
    rts

/*
 SCSIDISKWAKEALERT: after a wake-up while the disk mode cable is attached: system error
 alert 20010 and wait until it is removed; then refresh the screen.
*/
SCSIDISKWAKEALERT:
    moveml %d0-%d2/%a0-%a1,%sp@-
    jbsr TESTFORDISKMODE
    beqw SCSIDISKWAKEALERT_72
    movew #20010,%d0
    _SysError
SCSIDISKWAKEALERT_12:   /* wait about 160 ms */
    moveal VIA,%a0
    movew #160,%d0
    muluw TimeDBRA,%d0
    jbra SCSIDISKWAKEALERT_22
SCSIDISKWAKEALERT_20:   /* (outer loop) */
    swap %d0
SCSIDISKWAKEALERT_22:   /* delay loop */
    tstb %a0@
    dbf %d0,SCSIDISKWAKEALERT_22
    swap %d0
    dbf %d0,SCSIDISKWAKEALERT_20
    jbsr TESTFORDISKMODE
    jbne SCSIDISKWAKEALERT_12
    clrb DSWndUpdate
    cmpiw #16383,ROM85
    jbhi SCSIDISKWAKEALERT_72
    tstl DeviceList
    jbeq SCSIDISKWAKEALERT_72
    movel MainDevice,%d0
    jbeq SCSIDISKWAKEALERT_72
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %a0@,%d0
    jbeq SCSIDISKWAKEALERT_72
    linkw %fp,#-64
    lea %fp@,%a1
    clrw %a1@(6)
    moveal %sp,%a0
    movew %d0,%a0@(24)
    movew #5,%a0@(26)
    movel %a1,%a0@(28)
    .short  0xA204	| 408B8492 _Control (flags 0x0200)
    unlk %fp
SCSIDISKWAKEALERT_72:   /* return */
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts

SCSIDISKWAKEALERT_78:   /* Power Manager: PowerDispatch 0x1000A (keep awake) */
    btst #0,HWCfgFlags
    jbeq SCSIDISKWAKEALERT_88
    movel #65546,%d0
    _PowerDispatch
SCSIDISKWAKEALERT_88:   /* return */
    rts

SCSIDISKWAKEALERT_8A:   /* our SCSI ID from XPRAM 0x03 (bits 5-7, 0 means 1) */
    movel #65539,%d0
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    addb @(PmgrBase,%za0)@(0x55),%d0	| 408B84B4
    clrw %sp@-
    moveal %sp,%a0
    _ReadXPRam
    moveq #0,%d0
    moveb %sp@+,%d0
    lsrb #5,%d0
    jbne SCSIDISKWAKEALERT_A8
    moveq #1,%d0
SCSIDISKWAKEALERT_A8:   /* store it */
    movew %d0,%fp@(-336)
    rts
SCSIDISKWAKEALERT_AE:   /* QuickDraw bottleneck for the pictures */
    subql #4,%sp	| 408B84D2
    moveml %a0-%a2,%sp@-	| 408B84D4
    moveal SCSIGlobals,%a2	| 408B84D8
    moveal %a2@(264),%a2	| 408B84DC
    pea RGBWhite	| 408B84E0
    pea RGBBlack	| 408B84E4
    _RGBBackColor	| 408B84E8
    _RGBForeColor
    movel %a2@(-270),%sp@(12)	| 408B84EC
    moveml %sp@+,%a0-%a2	| 408B84F2
    rts	| 408B84F6

SCSIDISKWAKEALERT_D4:   /* colors from 0xC10/0xC16, a grafProcs record with our own routine */
    moveml %a0-%a3,%sp@-
    pea RGBWhite
    pea RGBBlack
    _RGBBackColor
    _RGBForeColor
    lea %fp@(-266),%a0
    lea %fp@(-398),%a3
    movel %a0,%a3@
    movel %a0,%sp@-
    _SetStdProcs
    moveal %a3@,%a3
    movel %a3@(32),%fp@(-270)
    lea %pc@(SCSIDISKWAKEALERT_AE),%a2
    movel %a2,%a3@(32)
    moveml %sp@+,%a0-%a3
    rts

SCSIDISKWAKEALERT_108:  /* QuickDraw set-up, the screen erased, the pictures loaded and placed */
    movel CurrentA5,%fp@(-4)
    lea %fp@(-8),%a5
    movel %a5,CurrentA5
    pea %fp@(-12)
    _InitGraf
    pea %fp@(-502)
    _OpenPort
    _HideCursor
    jbsr LCDSCREENCHK
    jbne SCSIDISKWAKEALERT_12E
    jbsr SCSIDISKWAKEALERT_D4
SCSIDISKWAKEALERT_12E:  /* (not an LCD: the color set-up) */
    moveal MainDevice,%a0
    moveal %a0@,%a0
    moveal %a0@(22),%a0
    moveal %a0@,%a0
    addqw #6,%a0
    moveq #-32,%d4
    addw %a0@(4),%d4
    subw %a0@,%d4
    movew %a0@(6),%fp@(-332)
    movel %a0,%sp@-
    _EraseRect
    lea %fp@(-294),%a2
    lea %fp@(-326),%a3
    clrl %a3@
    moveq #95,%d0
    jbsr SCSIDISKWAKEALERT_1D4
    jbeq SCSIDISKWAKEALERT_1D2
    moveal %d0,%a0
    moveal %a0@,%a0
    addqw #2,%a0
    subw %a0@(4),%d4
    addw %a0@,%d4
    lsrw #1,%d4
    moveq #20,%d3
    jbsr SCSIDISKWAKEALERT_1E6
    moveq #99,%d0
    jbsr SCSIDISKWAKEALERT_1D4
    jbeq SCSIDISKWAKEALERT_1D2
    moveq #36,%d3
    moveq #62,%d4
    jbsr SCSIDISKWAKEALERT_1E6
    moveq #100,%d0
    addw %fp@(-336),%d0
    jbsr SCSIDISKWAKEALERT_1D4
    jbeq SCSIDISKWAKEALERT_1D2
    moveq #43,%d3
    moveq #53,%d4
    jbsr SCSIDISKWAKEALERT_1E6
    moveq #96,%d0
    jbsr SCSIDISKWAKEALERT_1D4
    jbeq SCSIDISKWAKEALERT_1D2
    moveq #74,%d3
    moveq #60,%d4
    jbsr SCSIDISKWAKEALERT_1E6
    moveq #97,%d0
    jbsr SCSIDISKWAKEALERT_1D4
    jbeq SCSIDISKWAKEALERT_1D2
    moveq #98,%d0
    jbsr SCSIDISKWAKEALERT_1D4
    jbeq SCSIDISKWAKEALERT_1D2
    clrw %fp@(-340)
    clrl %fp@(-382)
    clrl %fp@(-378)
    movew #40,%fp@(-334)
    movel #100,%fp@(-330)
    moveal SCSIGlobals,%a0
    tstl %a0@(280)
    jbeq SCSIDISKWAKEALERT_1D0
    movel #2,%fp@(-330)
SCSIDISKWAKEALERT_1D0:  /* (two SCSI buses: other speed) */
    moveq #1,%d0
SCSIDISKWAKEALERT_1D2:  /* return (Z: a picture is missing) */
    rts

SCSIDISKWAKEALERT_1D4:  /* GetPicture(d0) from the ROM, keep it */
    movew #-1,ROMMapInsert
    subqw #4,%sp
    movew %d0,%sp@-
    _GetPicture
    movel %sp@+,%d0
    movel %d0,%a2@+
    rts

SCSIDISKWAKEALERT_1E6:  /* rectangle of the picture at (d3, d4) */
    addw %fp@(-324),%d3
    addw %fp@(-326),%d4
    moveal %d0,%a0
    moveal %a0@,%a0
    addqw #8,%a0
    movew %a0@,%d0
    movew %a0@-,%d1
    subw %a0@-,%d0
    addw %d3,%d0
    subw %a0@-,%d1
    addw %d4,%d1
    movew %d4,%a3@+
    movew %d3,%a3@+
    movew %d1,%a3@+
    movew %d0,%a3@+
    rts

SCSIDISKWAKEALERT_20A:  /* animation step: move the SCSI picture across the screen, bouncing */
    moveml %d0-%d2/%a0-%a1,%sp@-
    cmpil #3000,%fp@(-382)
    jblt SCSIDISKWAKEALERT_290
    clrl %fp@(-382)
    pea %fp@(-326)
    _EraseRect
    movew %fp@(-334),%d1
    movew %fp@(-324),%d0
    addw %d1,%d0
    jbmi SCSIDISKWAKEALERT_23A
    movew %fp@(-320),%d0
    addw %d1,%d0
    cmpw %fp@(-332),%d0
    jble SCSIDISKWAKEALERT_240
SCSIDISKWAKEALERT_23A:  /* bounce */
    negw %d1
    movew %d1,%fp@(-334)
SCSIDISKWAKEALERT_240:  /* move all the rectangles */
    addw %d1,%fp@(-324)
    addw %d1,%fp@(-320)
    addw %d1,%fp@(-316)
    addw %d1,%fp@(-312)
    addw %d1,%fp@(-308)
    addw %d1,%fp@(-304)
    addw %d1,%fp@(-300)
    addw %d1,%fp@(-296)
    movel %fp@(-294),%sp@-
    pea %fp@(-326)
    _DrawPicture
    btst #2,%fp@(-340)
    jbeq SCSIDISKWAKEALERT_286
    bchg #3,%fp@(-340)
    jbeq SCSIDISKWAKEALERT_286
    movel %fp@(-290),%sp@-
    pea %fp@(-318)
    _DrawPicture
    jbra SCSIDISKWAKEALERT_290
SCSIDISKWAKEALERT_286:  /* (other frame) */
    movel %fp@(-286),%sp@-
    pea %fp@(-310)
    _DrawPicture
SCSIDISKWAKEALERT_290:  /* return */
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts

SCSIDISKWAKEALERT_296:  /* activity indicator: next of three pictures */
    moveml %d0-%d2/%a0-%a1,%sp@-
    movel %fp@(-330),%d0
    cmpl %fp@(-382),%d0
    jbgt SCSIDISKWAKEALERT_2CE
    clrl %fp@(-382)
    moveq #3,%d0
    andb %fp@(-338),%d0
    addqb #1,%d0
    cmpib #2,%d0
    jble SCSIDISKWAKEALERT_2B8
    moveq #0,%d0
SCSIDISKWAKEALERT_2B8:  /* draw it */
    moveb %d0,%fp@(-338)
    lea %fp@(-282),%a0
    movel %a0@(0x0,%d0:w:4),%sp@-
    pea %fp@(-302)
    movel %sp@,%sp@-
    _EraseRect
    _DrawPicture
SCSIDISKWAKEALERT_2CE:  /* return */
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts

SCSIDISKWAKEALERT_2D4:  /* open .Backlight, remember its level, set it */
    clrw %fp@(24)
    lea %sp@(-50),%sp
    moveal %sp,%a0
    lea %pc@(PSTR_Backlight_408B8738),%a1
    movel %a1,%a0@(18)
    clrb %a0@(27)
    _Open
    jbne SCSIDISKWAKEALERT_30E
    movew %a0@(24),%fp@(-370)
    movew #21251,%a0@(26)
    _Status
    movel %a0@(28),%fp@(-374)
    movew #17155,%a0@(26)
    st %a0@(28)
    _Control
SCSIDISKWAKEALERT_30E:  /* (raw bytes) */
    .byte   0x4F, 0xEF, 0x00	| 408B8732
    .ascii  "2Nu"
PSTR_Backlight_408B8738:  /* Pascal string ".Backlight" */
    .byte   10	/* 408B8738 Pascal string length */
    .ascii  ".Backlight"	| 408B8739
    .byte   0x00	| 408B8743

SCSIDISKWAKEALERT_320:  /* backlight dim */
    bset #4,%fp@(-340)
    movew %fp@(-372),%d0
    jbra SCSIDISKWAKEALERT_336

SCSIDISKWAKEALERT_32C:  /* backlight back */
    bclr #4,%fp@(-340)
    movew %fp@(-374),%d0
SCSIDISKWAKEALERT_336:  /* Control to .Backlight */
    movew %fp@(-370),%d1
    jbeq SCSIDISKWAKEALERT_356
    lea %sp@(-50),%sp
    moveal %sp,%a0
    movew %d1,%a0@(24)
    movew #17153,%a0@(26)
    movew %d0,%a0@(28)
    _Control
    lea %sp@(50),%sp
SCSIDISKWAKEALERT_356:  /* return */
    rts

SCSIDISKWAKEALERT_358:  /* on battery power? (Power Manager level) */
    btst #0,HWCfgFlags
    jbeq SCSIDISKWAKEALERT_37A
    moveml %d3/%a0/%a2,%sp@-
    moveal PmgrBase,%a2
    jbsr GETLEVEL
    btst #0,%a2@(15)
    moveml %sp@+,%d3/%a0/%a2
    jbeq SCSIDISKWAKEALERT_37C
SCSIDISKWAKEALERT_37A:  /* (no) */
    moveq #-1,%d0
SCSIDISKWAKEALERT_37C:  /* Z = result */
    tstw %d0
    rts

SCSIDISKWAKEALERT_380:  /* SCSI power on (PMgrOp 0x10, 0x84), reset the SCSI chip(s) as target */
    btst #0,HWCfgFlags
    jbeq SCSIDISKWAKEALERT_3A0
    moveb #0x84,%sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #1,%sp@-
    movew #16,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(14),%sp
SCSIDISKWAKEALERT_3A0:  /* chip registers */
    moveal ToolDispTable,%a1
    moveal 0x1ff0,%a2
    moveal SCSIGlobals,%a4
    bset #0,%a4@(97)
    moveq #0,%d7
    jbsr SCSIDISKWAKEALERT_3D2
    tstl %a4@(280)
    jbeq SCSIDISKWAKEALERT_3D0
    moveb #0x80,%a1@(16)
    movew TimeDBRA,%d0
    lsrw #2,%d0
SCSIDISKWAKEALERT_3C8:  /* reset pulse */
    dbf %d0,SCSIDISKWAKEALERT_3C8
    moveb %d7,%a1@(16)
SCSIDISKWAKEALERT_3D0:  /* return */
    rts

SCSIDISKWAKEALERT_3D2:  /* SCSI chip registers to the target state, our ID */
    moveml %d0-%d1,%sp@-
    moveb %d7,%a1@(32)
    moveb %d7,%a1@(64)
    moveb %d7,%a1@(16)
    moveb %d7,%a1@(48)
    moveb %d7,%a1@
    tstl %a4@(280)
    jbeq SCSIDISKWAKEALERT_40A
    moveb %d7,%a2@(48)
    moveb #64,%a2@(32)
    movew %fp@(-336),%d0
    moveq #1,%d1
    lslb %d0,%d1
    moveb %d1,%a2@(64)
    moveb %d7,%a2@(16)
    moveb %d7,%a2@
SCSIDISKWAKEALERT_40A:  /* return */
    moveml %sp@+,%d0-%d1
    rts

/*
 TESTFORDISKMODE: is the disk mode cable attached? (VIA 1 bit 3 on these machines, or
 the dock's 'sdm ' answer). Out: Z clear if so.
*/
TESTFORDISKMODE:
    btst #5,0xdd5
    jbeq TESTFORDISKMODE_16
    moveal VIA,%a0
    moveq #8,%d0
    andb %a0@,%d0
    eorib #8,%d0
    rts
TESTFORDISKMODE_16:     /* ask the Docking Manager (if implemented) */
    movew #-22369,%d0
    .short  0xA746	| 408B884E _GetTrapAddress (flags 0x0700)
    moveal %a0,%a1
    movew %pc@(TESTFORDISKMODE_32),%d0
    .short  0xA746	| 408B8856 _GetTrapAddress (flags 0x0700)
    cmpal %a0,%a1
    jbeq TESTFORDISKMODE_3A
    subqw #4,%sp
    pea 0x73646d20
    clrl %sp@-
TESTFORDISKMODE_32:     /* _DockingDispatch('sdm ') */
    _DockingDispatch
    moveq #2,%d0
    andl %sp@+,%d0
    rts
TESTFORDISKMODE_3A:     /* no: 0 */
    nop
    nop
    moveq #0,%d0
    rts

TESTFORDISKMODE_42:     /* show the SCSI ID on the HDI connector LEDs... (VIA bits) and pulse the Power Manager */
    btst #5,0xdd5
    jbeq TESTFORDISKMODE_86
    moveal VIA,%a0
    orib #112,%a0@(1024)
    moveq #-113,%d0
    andb %a0@,%d0
    movew %fp@(-336),%d1
    aslb #4,%d1
    notw %d1
    andib #112,%d1
    orb %d1,%d0
    moveb %d0,%a0@
    moveb #4,%d0
    jbsr TESTFORDISKMODE_A0
    movew #250,%d1
TESTFORDISKMODE_72:     /* wait 250 ms */
    movew TimeDBRA,%d0
TESTFORDISKMODE_76:     /* delay */
    dbf %d0,TESTFORDISKMODE_76
    dbf %d1,TESTFORDISKMODE_72
    moveb #0x84,%d0
    jbsr TESTFORDISKMODE_A0
    rts
TESTFORDISKMODE_86:     /* (other machines: VIA 2 bits) */
    btst #4,0xdd5
    jbeq TESTFORDISKMODE_9E
    moveal ghost_VIA2,%a0
    moveb #17,%a0@(19)
    moveb #64,%a0@(18)
TESTFORDISKMODE_9E:     /* return */
    rts

TESTFORDISKMODE_A0:     /* PMgrOp 0x10 with one byte d0 */
    moveb %d0,%sp@-
    movel %sp,%sp@-
    movel %sp@,%sp@-
    movew #1,%sp@-
    movew #16,%sp@-
    moveal %sp,%a0
    _PMgrOp
    lea %sp@(14),%sp
    rts

TESTFORDISKMODE_B8:     /* main loop: wait for selection, serve the command, until reset */
    tstl %a4@(280)
    jbne TESTFORDISKMODE_134
    moveal %a1,%a2
TESTFORDISKMODE_C0:     /* idle: animate */
    jbsr TESTFORDISKMODE_D4
TESTFORDISKMODE_C2:     /* until selected */
    jbsr SCSIDISKWAKEALERT_296
    btst #6,%a1@(64)
    jbne TESTFORDISKMODE_C2
    jbsr TESTFORDISKMODE_6CC
    jbra TESTFORDISKMODE_C0

TESTFORDISKMODE_D4:     /* idle step: battery check (backlight), animation, until an interrupt */
    jbsr SCSIDISKWAKEALERT_358
    jble TESTFORDISKMODE_FC
    btst #2,%fp@(-340)
    jbne TESTFORDISKMODE_11C
    addql #1,%fp@(-378)
    cmpil #5000,%fp@(-378)
    jblt TESTFORDISKMODE_120
    bset #2,%fp@(-340)
    jbsr SCSIDISKWAKEALERT_320
    jbra TESTFORDISKMODE_11C
TESTFORDISKMODE_FC:     /* (on mains power) */
    btst #2,%fp@(-340)
    jbeq TESTFORDISKMODE_11C
    addql #1,%fp@(-378)
    cmpil #5000,%fp@(-378)
    jblt TESTFORDISKMODE_120
    bclr #2,%fp@(-340)
    jbsr SCSIDISKWAKEALERT_32C
TESTFORDISKMODE_11C:    /* counter reset */
    clrl %fp@(-378)
TESTFORDISKMODE_120:    /* animate */
    jbsr SCSIDISKWAKEALERT_20A
    btst #6,%fp@(-340)
    jbeq TESTFORDISKMODE_D4
    bclr #6,%fp@(-340)
    rts
TESTFORDISKMODE_134:    /* second bus variant: wait for selection */
    jbsr TESTFORDISKMODE_D4
    movew %sr,%sp@-
    oriw #256,%sr
    jbsr SCSIDISKWAKEALERT_296
    moveb %a2@(80),%d0
    bsrw TESTFORDISKMODE_1AA
    jbne TESTFORDISKMODE_150
    moveb %d7,%a2@(16)
    jbra TESTFORDISKMODE_134
TESTFORDISKMODE_150:    /* selected: stop the timer */
    jbsr TESTFORDISKMODE_7A0
    moveb %d7,%a1@(16)
TESTFORDISKMODE_158:    /* serve the phases */
    btst #5,%a1@(64)
    jbne TESTFORDISKMODE_174
    btst #6,%a1@(64)
    jbne TESTFORDISKMODE_158
    jbsr SCSIDISKWAKEALERT_3D2
    movew %sp@+,%sr
    jbsr TESTFORDISKMODE_77A
    jbra TESTFORDISKMODE_134
TESTFORDISKMODE_174:    /* dispatch on the bus phase (table below) */
    moveb %a1@(64),%d3
    lsrb #2,%d3
    moveq #7,%d0
    andb %d3,%d0
    movew %sr,%fp@(-342)
    oriw #1792,%sr
    bset #5,%fp@(-340)
    movew %pc@(TESTFORDISKMODE_19A,%d0:w:2),%d0
    jsr %pc@(TESTFORDISKMODE_19A,%d0:w)
    movew %fp@(-342),%sr
    jbra TESTFORDISKMODE_158
TESTFORDISKMODE_19A:    /* phase handlers (raw words) */
    .short  TESTFORDISKMODE_232-TESTFORDISKMODE_19A	| 408B89CE
    .short  TESTFORDISKMODE_3AA-TESTFORDISKMODE_19A	| 408B89D0
    .short  TESTFORDISKMODE_4CE-TESTFORDISKMODE_19A	| 408B89D2
    .short  TESTFORDISKMODE_536-TESTFORDISKMODE_19A	| 408B89D4
    .short  TESTFORDISKMODE_57C-TESTFORDISKMODE_19A	| 408B89D6
    .short  TESTFORDISKMODE_57C-TESTFORDISKMODE_19A	| 408B89D8
    .short  TESTFORDISKMODE_580-TESTFORDISKMODE_19A	| 408B89DA
    .short  TESTFORDISKMODE_5DE-TESTFORDISKMODE_19A	| 408B89DC
TESTFORDISKMODE_1AA:    /* arbitration/reselection */
    moveb #0x80,%a1@
TESTFORDISKMODE_1AE:    /* (retry) */
    moveb %d7,%a1@(32)
    moveq #0,%d1
    movew TimeSCSIDB,%d1
    lsll #8,%d1
    movel %d1,%d2
    swap %d2
    moveb #1,%a1@(32)
TESTFORDISKMODE_1C4:    /* wait for the bus (TimeSCSIDB loops) */
    btst #6,%a1@(16)
    dbne %d1,TESTFORDISKMODE_1C4
    dbne %d2,TESTFORDISKMODE_1C4
    jbeq TESTFORDISKMODE_222
    jbsr TESTFORDISKMODE_224
    btst #5,%a1@(16)
    jbne TESTFORDISKMODE_1AE
    moveb %d7,%a1@(48)
    moveb #4,%a1@(16)
    moveb #0x81,%a1@
    moveq #13,%d1
    btst #1,%d0
    jbeq TESTFORDISKMODE_1F6
    moveq #15,%d1
TESTFORDISKMODE_1F6:    /* phase registers */
    moveb %d1,%a1@(16)
    moveb %d7,%a1@(32)
    moveb %d7,%a1@(64)
    andib #0xf7,%a1@(16)
    movew %a4@(98),%d1
    muluw TimeSCSIDB,%d1
    movel %d1,%d2
    swap %d2
TESTFORDISKMODE_214:    /* wait */
    btst #6,%a1@(64)
    dbne %d1,TESTFORDISKMODE_214
    dbne %d2,TESTFORDISKMODE_214
TESTFORDISKMODE_222:    /* return */
    rts

TESTFORDISKMODE_224:    /* short delay */
    moveq #0,%d1
    moveb TimeDBRA,%d1
    lsrw #4,%d1
TESTFORDISKMODE_22C:    /* loop */
    dbf %d1,TESTFORDISKMODE_22C
    rts
TESTFORDISKMODE_232:    /* set %sr */
    movew %fp@(-342),%sr	| 408B8A66
    cmpib #10,%fp@(-394)	| 408B8A6A
    jbeq TESTFORDISKMODE_248	| 408B8A70
    cmpib #42,%fp@(-394)	| 408B8A72
    jbne TESTFORDISKMODE_354	| 408B8A78
TESTFORDISKMODE_248:    /* set %a1@(48) */
    moveb %d7,%a1@(48)	| 408B8A7C
    moveb %d7,%a2@(48)	| 408B8A80
    movel BusErrorVector,%a4@(448)	| 408B8A84
    lea %pc@(TESTFORDISKMODE_7CA),%a0	| 408B8A8A
    movel %a0,BusErrorVector	| 408B8A8E
    moveal %a4@(276),%a0	| 408B8A92
    lea %a0@,%a0	| 408B8A96
    moveal %a4@(288),%a3	| 408B8A98
    lea %a3@(96),%a3	| 408B8A9C
    jbsr TESTFORDISKMODE_282	| 408B8AA0
    moveb %d7,%a1@(32)	| 408B8AA2
    moveb #64,%a2@(32)	| 408B8AA6
    movel %a4@(448),BusErrorVector	| 408B8AAC
    jbra TESTFORDISKMODE_62A	| 408B8AB2
TESTFORDISKMODE_282:    /* clear %d1 */
    moveq #0,%d1	| 408B8AB6
    cmpib #10,%fp@(-394)	| 408B8AB8
    jbne TESTFORDISKMODE_296	| 408B8ABE
    moveb %fp@(-390),%d1	| 408B8AC0
    jbeq TESTFORDISKMODE_2A0	| 408B8AC4
    jbra TESTFORDISKMODE_34E	| 408B8AC6
TESTFORDISKMODE_296:    /* set %d1 */
    movew %fp@(-387),%d1	| 408B8ACA
    jbeq TESTFORDISKMODE_2A6	| 408B8ACE
    jbra TESTFORDISKMODE_34E	| 408B8AD0
TESTFORDISKMODE_2A0:    /* set %d1 */
    movew #255,%d1	| 408B8AD4
    jbra TESTFORDISKMODE_2A8	| 408B8AD8
TESTFORDISKMODE_2A6:    /* set %d1 */
    moveq #-1,%d1	| 408B8ADA
TESTFORDISKMODE_2A8:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8ADC
    jbne TESTFORDISKMODE_2A8	| 408B8AE2
TESTFORDISKMODE_2B0:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8AE4
    jbeq TESTFORDISKMODE_2B0	| 408B8AEA
    moveb #8,%a2@(48)	| 408B8AEC
TESTFORDISKMODE_2BE:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8AF2
    jbeq TESTFORDISKMODE_2BE	| 408B8AF8
    moveb %a2@,%a1@	| 408B8AFA
    .byte   0x08, 0xAA	| 408B8AFC
    .long   0x00030030 /* instruction operands (bclr #3,%a2@(48)), not a label difference (was rsrc_PACK_5_B6E-.) */	| 408B8AFE
    .byte   0x08, 0x2A, 0x00, 0x00, 0x00, 0x50, 0x66, 0xF8, 0x13, 0x47, 0x00, 0x30, 0x13, 0x7C, 0x00, 0x11	| 408B8B02
    .byte   0x00, 0x10, 0x08, 0x29, 0x00, 0x05, 0x00, 0x40, 0x66, 0xF8, 0x13, 0x47, 0x00, 0x10, 0x34, 0x3C	| 408B8B12
    .byte   0x01, 0xFD, 0x13, 0x7C, 0x00, 0x02, 0x00, 0x20, 0x00, 0x29, 0x00, 0x01, 0x00, 0x10, 0x13, 0x47	| 408B8B22
    .byte   0x00, 0x50, 0x15, 0x7C, 0x00, 0x42, 0x00, 0x20, 0x15, 0x47, 0x00, 0x60, 0x08, 0x2A, 0x00, 0x06	| 408B8B32
    .byte   0x00, 0x50, 0x67, 0xF8, 0x10, 0x13, 0x08, 0x29, 0x00, 0x06, 0x00, 0x50, 0x67, 0xF8, 0x10, 0x80	| 408B8B42
    .byte   0x51, 0xCA, 0xFF, 0xEA, 0x08, 0x2A, 0x00, 0x06, 0x00, 0x50, 0x67, 0xF8, 0x15, 0x7C, 0x00, 0x40	| 408B8B52
    .byte   0x00, 0x20, 0x10, 0x2A, 0x00, 0x60, 0x08, 0x29, 0x00, 0x06, 0x00, 0x50, 0x67, 0xF8, 0x10, 0x80	| 408B8B62
    .byte   0x08, 0x29, 0x00, 0x06, 0x00, 0x50, 0x67, 0xF8, 0x13, 0x47, 0x00, 0x20, 0x13, 0x47, 0x00, 0x10	| 408B8B72
TESTFORDISKMODE_34E:    /* count down */
    dbf %d1,TESTFORDISKMODE_2A8	| 408B8B82
    rts	| 408B8B86
TESTFORDISKMODE_354:    /* set %sr */
    movew %fp@(-342),%sr	| 408B8B88
    moveb %d7,%a2@(48)	| 408B8B8C
    moveb %d7,%a1@(48)	| 408B8B90
TESTFORDISKMODE_360:    /* loop: move */
    moveb %d3,%a2@(48)	| 408B8B94
TESTFORDISKMODE_364:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8B98
    jbeq TESTFORDISKMODE_364	| 408B8B9E
    moveb %a2@,%a1@	| 408B8BA0
    bclr #3,%a2@(48)	| 408B8BA2
TESTFORDISKMODE_374:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8BA8
    jbne TESTFORDISKMODE_374	| 408B8BAE
    moveb %d7,%a1@(48)	| 408B8BB0
    moveb #17,%a1@(16)	| 408B8BB4
TESTFORDISKMODE_386:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8BBA
    jbne TESTFORDISKMODE_386	| 408B8BC0
    moveb %d7,%a1@(16)	| 408B8BC2
TESTFORDISKMODE_392:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8BC6
    jbeq TESTFORDISKMODE_392	| 408B8BCC
    moveb %a1@(64),%d3	| 408B8BCE
    lsrb #2,%d3	| 408B8BD2
    moveq #7,%d0	| 408B8BD4
    andb %d3,%d0	| 408B8BD6
    jbeq TESTFORDISKMODE_360	| 408B8BD8
    jbra TESTFORDISKMODE_62A	| 408B8BDA
TESTFORDISKMODE_3AA:    /* set %sr */
    movew %fp@(-342),%sr	| 408B8BDE
    cmpib #8,%fp@(-394)	| 408B8BE2
    jbeq TESTFORDISKMODE_3C0	| 408B8BE8
    cmpib #40,%fp@(-394)	| 408B8BEA
    jbne TESTFORDISKMODE_476	| 408B8BF0
TESTFORDISKMODE_3C0:    /* set %a1@(48) */
    moveb #1,%a1@(48)	| 408B8BF4
    moveb #2,%a1@(32)	| 408B8BFA
    moveb %d7,%a1@(112)	| 408B8C00
    moveb #1,%a2@(48)	| 408B8C04
    moveb #66,%a2@(32)	| 408B8C0A
    orib #1,%a2@(16)	| 408B8C10
    moveb %d7,%a2@(80)	| 408B8C16
    movel BusErrorVector,%a4@(448)	| 408B8C1A
    lea %pc@(TESTFORDISKMODE_7CA),%a0	| 408B8C20
    movel %a0,BusErrorVector	| 408B8C24
    moveal %a4@(276),%a0	| 408B8C28
    lea %a0@(96),%a0	| 408B8C2C
    moveal %a4@(288),%a3	| 408B8C30
    lea %a3@,%a3	| 408B8C34
    jbsr TESTFORDISKMODE_424	| 408B8C36
    nop	| 408B8C38
    nop	| 408B8C3A
    nop	| 408B8C3C
    moveb %d7,%a1@(32)	| 408B8C3E
    moveb #64,%a2@(32)	| 408B8C42
    eorib #1,%a2@(16)	| 408B8C48
    movel %a4@(448),BusErrorVector	| 408B8C4E
    jbra TESTFORDISKMODE_62A	| 408B8C54
TESTFORDISKMODE_424:    /* test #8,%fp@(-394) */
    cmpib #8,%fp@(-394)	| 408B8C58
    jbne TESTFORDISKMODE_438	| 408B8C5E
    moveb %fp@(-390),%d1	| 408B8C60
    jbne TESTFORDISKMODE_45C	| 408B8C64
    movew #255,%d1	| 408B8C66
    jbra TESTFORDISKMODE_440	| 408B8C6A
TESTFORDISKMODE_438:    /* set %d1 */
    movew %fp@(-387),%d1	| 408B8C6C
    jbne TESTFORDISKMODE_45C	| 408B8C70
    moveq #-1,%d1	| 408B8C72
TESTFORDISKMODE_440:    /* set %d2 */
    movew #511,%d2	| 408B8C74
TESTFORDISKMODE_444:    /* loop: btst */
    btst #6,%a1@(80)	| 408B8C78
    jbeq TESTFORDISKMODE_444	| 408B8C7E
    moveb %a0@,%d0	| 408B8C80
TESTFORDISKMODE_44E:    /* loop: btst */
    btst #6,%a2@(80)	| 408B8C82
    jbeq TESTFORDISKMODE_44E	| 408B8C88
    moveb %d0,%a3@	| 408B8C8A
    dbf %d2,TESTFORDISKMODE_444	| 408B8C8C
TESTFORDISKMODE_45C:    /* set %d2 */
    movew #511,%d2	| 408B8C90
    dbf %d1,TESTFORDISKMODE_444	| 408B8C94
TESTFORDISKMODE_464:    /* loop: btst */
    btst #6,%a2@(80)	| 408B8C98
    jbeq TESTFORDISKMODE_464	| 408B8C9E
TESTFORDISKMODE_46C:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8CA0
    jbne TESTFORDISKMODE_46C	| 408B8CA6
    rts	| 408B8CA8
TESTFORDISKMODE_476:    /* set %d0 */
    moveq #1,%d0	| 408B8CAA
    moveb %d0,%a2@(48)	| 408B8CAC
    moveb %d0,%a1@(48)	| 408B8CB0
TESTFORDISKMODE_480:    /* loop: move */
    moveb %a1@,%a2@	| 408B8CB4
    orib #1,%a2@(16)	| 408B8CB6
    moveb %d3,%a2@(48)	| 408B8CBC
TESTFORDISKMODE_48C:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8CC0
    jbeq TESTFORDISKMODE_48C	| 408B8CC6
    bclr #3,%a2@(48)	| 408B8CC8
TESTFORDISKMODE_49A:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8CCE
    jbne TESTFORDISKMODE_49A	| 408B8CD4
    moveb #16,%a1@(16)	| 408B8CD6
TESTFORDISKMODE_4A8:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8CDC
    jbne TESTFORDISKMODE_4A8	| 408B8CE2
    moveb %d7,%a1@(16)	| 408B8CE4
TESTFORDISKMODE_4B4:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8CE8
    jbeq TESTFORDISKMODE_4B4	| 408B8CEE
    moveb %a1@(64),%d3	| 408B8CF0
    lsrb #2,%d3	| 408B8CF4
    moveq #7,%d0	| 408B8CF6
    andb %d3,%d0	| 408B8CF8
    subqb #1,%d0	| 408B8CFA
    jbeq TESTFORDISKMODE_480	| 408B8CFC
    jbra TESTFORDISKMODE_62A	| 408B8CFE
TESTFORDISKMODE_4CE:    /* set %sr */
    movew %fp@(-342),%sr	| 408B8D02
    moveq #2,%d0	| 408B8D06
    moveb %d0,%a2@(48)	| 408B8D08
    moveb %d0,%a1@(48)	| 408B8D0C
    moveq #0,%d1	| 408B8D10
TESTFORDISKMODE_4DE:    /* loop: move */
    moveb %d3,%a2@(48)	| 408B8D12
TESTFORDISKMODE_4E2:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8D16
    jbeq TESTFORDISKMODE_4E2	| 408B8D1C
    moveb %a2@,%d0	| 408B8D1E
    moveb %d0,%fp@(-394,%d1:w)	| 408B8D20
    addqw #1,%d1	| 408B8D26
    moveb %d0,%a1@	| 408B8D28
    bclr #3,%a2@(48)	| 408B8D2A
TESTFORDISKMODE_4FC:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8D30
    jbne TESTFORDISKMODE_4FC	| 408B8D36
    moveb #17,%a1@(16)	| 408B8D38
TESTFORDISKMODE_50A:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8D3E
    jbne TESTFORDISKMODE_50A	| 408B8D44
    andib #0xef,%a1@(16)	| 408B8D46
TESTFORDISKMODE_518:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8D4C
    jbeq TESTFORDISKMODE_518	| 408B8D52
    moveb %a1@(64),%d3	| 408B8D54
    lsrb #2,%d3	| 408B8D58
    moveq #7,%d0	| 408B8D5A
    andb %d3,%d0	| 408B8D5C
    subqb #2,%d0	| 408B8D5E
    jbeq TESTFORDISKMODE_4DE	| 408B8D60
    moveb %d7,%a2@(48)	| 408B8D62
    jbra TESTFORDISKMODE_62A	| 408B8D66
TESTFORDISKMODE_536:    /* set %sr */
    movew %fp@(-342),%sr	| 408B8D6A
    moveq #3,%d0	| 408B8D6E
    moveb %d0,%a2@(48)	| 408B8D70
    moveb %d0,%a1@(48)	| 408B8D74
    moveb %a1@,%a2@	| 408B8D78
    orib #1,%a2@(16)	| 408B8D7A
    moveb %d3,%a2@(48)	| 408B8D80
TESTFORDISKMODE_550:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8D84
    jbeq TESTFORDISKMODE_550	| 408B8D8A
    bclr #3,%a2@(48)	| 408B8D8C
TESTFORDISKMODE_55E:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8D92
    jbne TESTFORDISKMODE_55E	| 408B8D98
    moveb #16,%a1@(16)	| 408B8D9A
TESTFORDISKMODE_56C:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8DA0
    jbne TESTFORDISKMODE_56C	| 408B8DA6
    moveb %d7,%a1@(16)	| 408B8DA8
    jbra TESTFORDISKMODE_62A	| 408B8DAC
TESTFORDISKMODE_57C:    /* from here: nop */
    nop	| 408B8DB0
    rts	| 408B8DB2
TESTFORDISKMODE_580:    /* set %sr */
    movew %fp@(-342),%sr	| 408B8DB4
    moveq #6,%d0	| 408B8DB8
    moveb %d0,%a2@(48)	| 408B8DBA
    moveb %d0,%a1@(48)	| 408B8DBE
TESTFORDISKMODE_58E:    /* loop: move */
    moveb %d3,%a2@(48)	| 408B8DC2
TESTFORDISKMODE_592:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8DC6
    jbeq TESTFORDISKMODE_592	| 408B8DCC
    moveb %a2@,%a1@	| 408B8DCE
    bclr #3,%a2@(48)	| 408B8DD0
TESTFORDISKMODE_5A2:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8DD6
    jbne TESTFORDISKMODE_5A2	| 408B8DDC
    moveb #17,%a1@(16)	| 408B8DDE
TESTFORDISKMODE_5B0:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8DE4
    jbne TESTFORDISKMODE_5B0	| 408B8DEA
    moveb %d7,%a1@(16)	| 408B8DEC
TESTFORDISKMODE_5BC:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8DF0
    jbne TESTFORDISKMODE_5CE	| 408B8DF6
    btst #6,%a1@(64)	| 408B8DF8
    jbne TESTFORDISKMODE_5BC	| 408B8DFE
    jbra TESTFORDISKMODE_62A	| 408B8E00
TESTFORDISKMODE_5CE:    /* set %d3 */
    moveb %a1@(64),%d3	| 408B8E02
    lsrb #2,%d3	| 408B8E06
    moveq #7,%d0	| 408B8E08
    andb %d3,%d0	| 408B8E0A
    subqb #6,%d0	| 408B8E0C
    jbeq TESTFORDISKMODE_58E	| 408B8E0E
    jbra TESTFORDISKMODE_62A	| 408B8E10
TESTFORDISKMODE_5DE:    /* set %sr */
    movew %fp@(-342),%sr	| 408B8E12
    moveq #7,%d0	| 408B8E16
    moveb %d0,%a2@(48)	| 408B8E18
    moveb %d0,%a1@(48)	| 408B8E1C
    moveb %a1@,%a2@	| 408B8E20
    orib #1,%a2@(16)	| 408B8E22
    moveb %d3,%a2@(48)	| 408B8E28
TESTFORDISKMODE_5F8:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8E2C
    jbne TESTFORDISKMODE_60A	| 408B8E32
    btst #6,%a1@(64)	| 408B8E34
    jbne TESTFORDISKMODE_5F8	| 408B8E3A
    jbra TESTFORDISKMODE_62A	| 408B8E3C
TESTFORDISKMODE_60A:    /* clear bit 3 of %a2@(48) */
    bclr #3,%a2@(48)	| 408B8E3E
TESTFORDISKMODE_610:    /* loop: btst */
    btst #0,%a2@(80)	| 408B8E44
    jbne TESTFORDISKMODE_610	| 408B8E4A
    moveb #16,%a1@(16)	| 408B8E4C
TESTFORDISKMODE_61E:    /* loop: btst */
    btst #5,%a1@(64)	| 408B8E52
    jbne TESTFORDISKMODE_61E	| 408B8E58
    moveb %d7,%a1@(16)	| 408B8E5A
TESTFORDISKMODE_62A:    /* set %fp@(-342) */
    movew %sr,%fp@(-342)	| 408B8E5E
    oriw #1792,%sr	| 408B8E62
    bclr #5,%fp@(-340)	| 408B8E66
    rts	| 408B8E6C

TESTFORDISKMODE_63A:    /* install the SCSI interrupt handler (through the dock, or the level 2 vector) */
    moveml %a0-%a2,%sp@-
    tstl %a4@(280)
    jbeq TESTFORDISKMODE_65A
    subqw #4,%sp
    pea 0x73646d69
    pea %pc@(TESTFORDISKMODE_6F0)
    _DockingDispatch
    addqw #4,%sp
    moveml %sp@+,%a0-%a2
TESTFORDISKMODE_658:    /* return */
    rts
TESTFORDISKMODE_65A:    /* (no dock): chip reset, VIA 2 interrupts, vector 0x68 */
    movew %sr,%sp@-
    oriw #1792,%sr
    moveal ToolDispTable,%a1
    moveb %d7,%a1@(32)
    moveb %d7,%a1@(16)
    moveb %d7,%a1@(48)
    moveb %d7,%a1@
    moveal ghost_VIA2,%a1
    moveb #127,%a1@(7168)
    moveb #127,%a1@(6656)
    lea %pc@(TESTFORDISKMODE_694),%a1
    movel %a1,0x68
    jbsr TESTFORDISKMODE_6CC
    movew %sp@+,%sr
    moveml %sp@+,%a0-%a2
    rts
TESTFORDISKMODE_694:    /* SCSI interrupt: flag it, acknowledge */
    movew %sr,%sp@-
    oriw #1792,%sr
    movel %a0,%sp@-
    moveal SCSIGlobals,%a0
    moveal %a0@(264),%a0
    bset #6,%a0@(-340)
    moveal ToolDispTable,%a0
    clrb %a0@(64)
    tstb %a0@(112)
    moveal ghost_VIA2,%a0
    moveb #127,%a0@(7168)
    moveb #127,%a0@(6656)
    moveal %sp@+,%a0
    movew %sp@+,%sr
    rte

TESTFORDISKMODE_6CC:    /* enable the selection interrupt for our ID */
    moveml %d0-%d1/%a1,%sp@-
    moveal ToolDispTable,%a1
    movew %fp@(-336),%d0
    moveq #1,%d1
    lslb %d0,%d1
    moveb %d1,%a1@(64)
    moveal ghost_VIA2,%a1
    moveb #0x88,%a1@(7168)
    moveml %sp@+,%d0-%d1/%a1
    rts

TESTFORDISKMODE_6F0:    /* interrupt handler (dock): selection or reset */
    moveml %d0-%d1/%a1-%a2/%fp,%sp@-
    moveal 0x1ff0,%a2
    moveal SCSIGlobals,%fp
    moveal %fp@(264),%fp
    btst #1,%a2@(64)
    jbne TESTFORDISKMODE_75A
    btst #3,%a2@(80)
    jbeq TESTFORDISKMODE_74E
    moveal ToolDispTable,%a1
    moveb #0x80,%a1@(16)
    movew TimeDBRA,%d1
    lsrw #2,%d1
TESTFORDISKMODE_720:    /* reset pulse */
    dbf %d1,TESTFORDISKMODE_720
    clrb %a1@(16)
    movew %fp@(-336),%d0
    moveq #1,%d1
    lslb %d0,%d1
    moveb %d1,%a2@(64)
    moveb %a2@(112),%d1
    bclr #5,%fp@(-340)
    jbeq TESTFORDISKMODE_74E
    clrw %sp@(26)
    lea %pc@(TESTFORDISKMODE_658),%a1
    movel %a1,%sp@(22)
    jbra TESTFORDISKMODE_754
TESTFORDISKMODE_74E:    /* (other bit) */
    eorib #2,%a2@(32)
TESTFORDISKMODE_754:    /* return from the interrupt */
    moveml %sp@+,%d0-%d1/%a1-%a2/%fp
    rte
TESTFORDISKMODE_75A:    /* selected with our ID */
    movew %fp@(-336),%d0
    btst %d0,%a2@
    jbeq TESTFORDISKMODE_754
    bset #6,%fp@(-340)
    moveb #8,%a2@(16)
    moveq #0,%d1
    moveb %d1,%a2@(64)
    moveb %a2@(112),%d1
    jbra TESTFORDISKMODE_754

TESTFORDISKMODE_77A:    /* start the idle timer (500 us Time Manager task) */
    moveml %d0/%a0-%a1,%sp@-
    lea %fp@(-368),%a0
    lea %pc@(TESTFORDISKMODE_7B0),%a1
    movel %a1,%a0@(6)
    .short  0xA458	| 408B8FBE _InsTime (flags 0x0400)
    movel #500,%d0
    negl %d0
    clrl %a0@(14)
    _PrimeTime
    moveml %sp@+,%d0/%a0-%a1
    rts

TESTFORDISKMODE_7A0:    /* stop it */
    moveml %a0,%sp@-
    lea %fp@(-368),%a0
    _RmvTime
    moveml %sp@+,%a0
    rts
TESTFORDISKMODE_7B0:    /* its task */
    moveal SCSIGlobals,%a0	| 408B8FE4
    moveal %a0@(264),%a0	| 408B8FE8
    addql #1,%a0@(-382)	| 408B8FEC
    moveal %a1,%a0	| 408B8FF0
    movel #500,%d0	| 408B8FF2
    negl %d0	| 408B8FF8
    _PrimeTime	| 408B8FFA
    rts	| 408B8FFC

TESTFORDISKMODE_7CA:    /* bus error handler during the transfers (pseudo-DMA) */
    moveml %d0-%d1/%a0,%sp@-
    movel %sp@(28),%d0
    clrb %d0
    cmpl SCSIHsk,%d0
    jbeq TESTFORDISKMODE_7EA
    moveal SCSIGlobals,%a0
    movel %a0@(448),%sp@(12)
    moveml %sp@+,%d0-%d1/%a0
    rts
TESTFORDISKMODE_7EA:    /* (wait for the chip) */
    btst #3,%a1@(80)
    jbeq TESTFORDISKMODE_800
    btst #6,%a1@(80)
    jbeq TESTFORDISKMODE_7EA
    moveml %sp@+,%d0-%d1/%a0
    rte
TESTFORDISKMODE_800:    /* abort: drop the exception frame and return to the loop */
    lea %sp@(12),%sp
    movew %sp@,%d0
    bfextu %sp@(6),0,4,%d1
    cmpib #10,%d1
    jbne TESTFORDISKMODE_818
    lea %sp@(32),%sp
    jbra TESTFORDISKMODE_81C
TESTFORDISKMODE_818:    /* (long frame) */
    lea %sp@(92),%sp
TESTFORDISKMODE_81C:    /* return */
    clrw %sp@-
    pea %pc@(TESTFORDISKMODE_658)
    movew %d0,%sp@-
    rte
    .fill   0x376, 1, 0x00
