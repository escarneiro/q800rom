/*
 video/tfb.s - TFB video driver
 From TFBDRVR (0x40897B80). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and the video driver interface in Designing Cards
 and Drivers), not taken from Apple.
 Video driver for the Macintosh II Video Card ("TFB"). a1 = the DCE (+40 slot,
 +42 card base address), a2 = csParam, private storage (handle at DCE +20): +4 mode,
 +6 page, +8 base address, +12 slot interrupt block, +16 gamma table, +20 flags (bit 15
 gray, 14 interrupt off), +22 nonzero on the 512 KB card. Modes 128..131 = 1..8 bits.
 Card registers at base +0x80000 (control), +0x90000 (CLUT), +0xA0000 (interrupt),
 +0xD0000 (status).
*/

/*
 TFBDRVR: the 'DRVR' header (Open 0x2E, Control 0x11E, Status 0x58E, Close 0xEA) and its
 name ".Display_Video_Apple_TFB"; the Open and Close routines are still raw words.
*/
TFBDRVR:
    .long   0x4C000000, 0x00000000, 0x002E0000, 0x011E058E	| 40897B80
    .byte   0x00, 0xEA, 0x18	| 40897B90
    .ascii  ".Display_Video_Apple_TFB\000"
    .long   0x00062649	| 40897BAC
    .long   0x7018A440, 0x7018A722, 0x660000AC, 0x27480014	| 40897BB0
    .long   0xA0292250, 0x49FA08EC, 0x7010A71E, 0x66000092	| 40897BC0
    .long   0x2348000C, 0x317C0006, 0x0004214C, 0x0008216B	| 40897BD0
    .long   0x002A000C, 0x7000102B, 0x0028A075, 0x666C7000	| 40897BE0
    .long   0x303C010C, 0xA71E6656, 0x23480010, 0x42987001	| 40897BF0
    .long   0x20C020FC, 0x01000008, 0x303C00FF, 0x12004601	| 40897C00
    .long   0x10C151C8, 0xFFF84269, 0x0014206B, 0x002A223C	| 40897C10
    .long   0x000423FC, 0x21BC4D41, 0x43321800, 0x2F3CFFFF	| 40897C20
    .long   0xFFFF429F, 0x20301800, 0x0C804D41, 0x433256E9	| 40897C30
    .long   0x0016D1FC, 0x000A0003, 0x42107000	| 40897C40
TFBDRVR_CC:             /* Open: return -23 (openErr) */
    rts
    .short  0x2069	| 40897C4E
    .long   0x000C7000, 0x102B0028, 0xA0762069, 0x000CA01F	| 40897C50
    .short  0x206B, 0x0014, 0xA023	| 40897C60
    moveq #-23,%d0
    jbra TFBDRVR_CC
    moveal %a1@(42),%a0
    addal #655367,%a0
    clrb %a0@
    moveal %a1@(20),%a2
    moveal %a2@,%a2
    moveal %a2@(12),%a0
    moveq #0,%d0
    moveb %a1@(40),%d0
    _SIntRemove
    moveal %a2@(12),%a0
    _DisposPtr
    moveal %a2@(16),%a0
    _DisposPtr
    moveal %a1@(20),%a0
    _DisposHandle
    moveq #0,%d0
    rts

TFBDRVR_11E:            /* Control: dispatch on csCode 0..7 */
    moveml %d4/%a0/%a4,%sp@-
    movew %a0@(26),%d0
    moveal %a0@(28),%a2
    cmpiw #7,%d0
    jbhi TFBDRVR_14C
    lslw #1,%d0
    movew %pc@(TFBDRVR_13A,%d0:w),%d0
    jmp %pc@(TFBDRVR_13A,%d0:w)
TFBDRVR_13A:            /* offsets of Reset, KillIO, SetMode, SetEntries, SetGamma, GrayPage, SetGray, SetInterrupt */
    .short  TFBDRVR_15A-TFBDRVR_13A	| 40897CBA
    .short  TFBDRVR_150-TFBDRVR_13A	| 40897CBC
    .short  TFBDRVR_186-TFBDRVR_13A	| 40897CBE
    .short  TFBDRVR_216-TFBDRVR_13A	| 40897CC0
    .short  TFBDRVR_426-TFBDRVR_13A	| 40897CC2
    .short  TFBDRVR_4E2-TFBDRVR_13A	| 40897CC4
    .short  TFBDRVR_508-TFBDRVR_13A	| 40897CC6
    .short  TFBDRVR_520-TFBDRVR_13A	| 40897CC8
TFBDRVR_14A:            /* (drop the saved stack value) */
    addqw #4,%sp
TFBDRVR_14C:            /* controlErr (-17) */
    moveq #-17,%d0
    jbra TFBDRVR_152
TFBDRVR_150:            /* noErr */
    moveq #0,%d0
TFBDRVR_152:            /* done */
    moveml %sp@+,%d4/%a0/%a4
    jbra TFBDRVR_73C
TFBDRVR_15A:            /* Reset (0): default CLUT, mode 128 page 0, gray screen */
    jbsr TFBDRVR_7C6
    movew #128,%a2@
    movew #1,%d1
    moveq #0,%d0
    movew %d0,%a2@(6)
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    jbsr TFBDRVR_7F8
    jbsr TFBDRVR_880
    movel %a3@(8),%a2@(8)
    jbsr TFBDRVR_8C4
    jbra TFBDRVR_150
TFBDRVR_186:            /* SetMode (2): check mode and page, reprogram the card if the mode changes */
    movew %a2@,%d1
    jbsr TFBDRVR_776
    jbne TFBDRVR_14C
    movew %a2@(6),%d0
    jbsr TFBDRVR_7A2
    jbne TFBDRVR_14C
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    movew %a2@,%d2
    cmpw %a3@(4),%d2
    jbeq TFBDRVR_1B2
    jbsr TFBDRVR_1BE
    jbsr TFBDRVR_7F8
    jbsr TFBDRVR_880
    jbra TFBDRVR_1B6
TFBDRVR_1B2:            /* same mode: only the page */
    jbsr TFBDRVR_880
TFBDRVR_1B6:            /* return the base address */
    movel %a3@(8),%a2@(8)
    jbra TFBDRVR_150

TFBDRVR_1BE:            /* gray the CLUT (all entries the middle gamma value) before a mode change */
    moveml %d0-%d1/%a0-%a1,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge TFBDRVR_1D4
    oriw #512,%sr
    andiw #-1281,%sr
TFBDRVR_1D4:            /* wait for blanking, gamma-corrected 50% value */
    jbsr TFBDRVR_704
    moveal %a1@(20),%a0
    moveal %a0@,%a0
    moveal %a0@(16),%a0
    movew %a0@(4),%d0
    lea %a0@(12),%a0
    addaw %d0,%a0
    movew #128,%d1
    moveb %a0@(0x0,%d1:w),%d1
    notb %d1
    moveal %a1@(42),%a0
    addal #589848,%a0
    movew #255,%d0
TFBDRVR_204:            /* write all 256 CLUT entries */
    moveb %d1,%a0@
    moveb %d1,%a0@
    moveb %d1,%a0@
    dbf %d0,TFBDRVR_204
    movew %sp@+,%sr
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts
TFBDRVR_216:            /* SetEntries (3): load color table entries into the CLUT, gamma corrected */
    movel %a2@,%d0
    jbeq TFBDRVR_14C
    moveml %d5-%d7/%a5-%fp,%sp@-
    moveal %a1@(20),%a0
    moveal %a0@,%a0
    movew %a0@(20),%d5
    moveal %a0@(16),%a0
    movew %a0@(4),%d0
    lea %a0@(12),%a4
    addaw %d0,%a4
    moveal %a4,%a5
    moveal %a4,%fp
    cmpiw #1,%a0@(6)
    jbeq TFBDRVR_258
    movew %a0@(8),%d0
    movew %a0@(10),%d1
    addqw #7,%d1
    lsrw #3,%d1
    muluw %d1,%d0
    addaw %d0,%a5
    addaw %d0,%fp
    addaw %d0,%fp
TFBDRVR_258:            /* (gamma table with separate red, green and blue tables) */
    subaw #128,%sp
    jbsr TFBDRVR_74C
    moveal %a2@,%a0
    movew %a2@(4),%d1
    jbmi TFBDRVR_28E
    cmpiw #255,%d6
    jbne TFBDRVR_278
    cmpiw #4,%a2@(6)
    jbgt TFBDRVR_334
TFBDRVR_278:            /* sequence mode: build an indexed copy on the stack */
    moveal %sp,%a3
    movew %a2@(6),%d0
TFBDRVR_27E:            /* copy loop */
    movew %d1,%a3@+
    movel %a0@+,%d2
    movew %d2,%a3@+
    movel %a0@+,%a3@+
    addqw #1,%d1
    dbf %d0,TFBDRVR_27E
    moveal %sp,%a0
TFBDRVR_28E:            /* interrupts at level 2 or more, wait for blanking */
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge TFBDRVR_2A0
    oriw #512,%sr
    andiw #-1281,%sr
TFBDRVR_2A0:            /* CLUT registers */
    jbsr TFBDRVR_704
    movew %a2@(6),%d0
    moveal %a1@(42),%a3
    addal #589848,%a3
TFBDRVR_2B2:            /* next entry: index in range? gray: luminance of red, green, blue */
    movel %a0@+,%d2
    swap %d2
    moveq #-1,%d1
    movew %d2,%d1
    cmpw %d6,%d1
    jbhi TFBDRVR_322
    roll %d7,%d1
    moveb %d1,%a3@(4)
    swap %d2
    movel %a0@+,%d3
    movel %d3,%d4
    swap %d3
    tstw %d5
    jbpl TFBDRVR_2F8
    muluw #19660,%d2
    muluw #-26870,%d3
    muluw #7208,%d4
    addl %d3,%d2
    addl %d4,%d2
    roll #8,%d2
    andiw #255,%d2
    moveb %a4@(0x0,%d2:w),%d2
    notb %d2
    moveb %d2,%a3@
    moveb %d2,%a3@
    moveb %d2,%a3@
    dbf %d0,TFBDRVR_2B2
    jbra TFBDRVR_326
TFBDRVR_2F8:            /* color: red, green, blue through their gamma tables */
    rorw #8,%d2
    moveq #0,%d1
    moveb %d2,%d1
    moveb %a4@(0x0,%d1:w),%d1
    notb %d1
    moveb %d1,%a3@
    rorw #8,%d3
    moveq #0,%d1
    moveb %d3,%d1
    moveb %a5@(0x0,%d1:w),%d1
    notb %d1
    moveb %d1,%a3@
    rorw #8,%d4
    moveq #0,%d1
    moveb %d4,%d1
    moveb %fp@(0x0,%d1:w),%d1
    notb %d1
    moveb %d1,%a3@
TFBDRVR_322:            /* next */
    dbf %d0,TFBDRVR_2B2
TFBDRVR_326:            /* done */
    movew %sp@+,%sr
    lea %sp@(128),%sp
    moveml %sp@+,%d5-%d7/%a5-%fp
    jbra TFBDRVR_150
TFBDRVR_334:            /* many entries at 8 bits: prepare the whole CLUT on the stack first (needs 1280 bytes) */
    movel %sp,%d1
    movel %d1,%d0
    negw %d0
    andiw #3,%d0
    jbeq TFBDRVR_342
    subaw %d0,%sp
TFBDRVR_342:            /* enough stack? */
    movel %d1,%sp@-
    _StackSpace
    cmpil #1280,%d0
    jblt TFBDRVR_14A
    subaw #1024,%sp
    movew %a2@(4),%d1
    lea %sp@(0x0,%d1:w:4),%a3
    movew %a2@(6),%d0
    moveal %a2@,%a0
TFBDRVR_362:            /* next entry */
    cmpw %d6,%d1
    jbgt TFBDRVR_3C6
    tstw %d5
    jbpl TFBDRVR_39E
    movel %a0@+,%d2
    movew %a0@+,%d3
    movew %a0@+,%d4
    muluw #19660,%d2
    muluw #-26870,%d3
    muluw #7208,%d4
    addl %d3,%d2
    addl %d4,%d2
    roll #8,%d2
    moveq #0,%d3
    moveb %d2,%d3
    moveb %a4@(0x0,%d3:w),%d2
    moveb %d2,%d3
    lsll #8,%d3
    moveb %d2,%d3
    lsll #8,%d3
    moveb %d2,%d3
    movel %d3,%a3@+
    addqw #1,%d1
    dbf %d0,TFBDRVR_362
    jbra TFBDRVR_3C6
TFBDRVR_39E:            /* color entry */
    moveq #0,%d2
    moveb %a0@(6),%d2
    moveb %fp@(0x0,%d2:w),%d3
    lsll #8,%d3
    moveb %a0@(4),%d2
    moveb %a5@(0x0,%d2:w),%d3
    lsll #8,%d3
    moveb %a0@(2),%d2
    moveb %a4@(0x0,%d2:w),%d3
    movel %d3,%a3@+
    addqw #1,%d1
    addqw #8,%a0
    dbf %d0,TFBDRVR_362
TFBDRVR_3C6:            /* then write it in one pass during blanking */
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge TFBDRVR_3D8
    oriw #512,%sr
    andiw #-1281,%sr
TFBDRVR_3D8:            /* CLUT address register */
    moveal %a3,%a0
    jbsr TFBDRVR_704
    moveal %a1@(42),%a3
    addal #589827,%a3
    moveq #0,%d1
    moveb %a2@(5),%d1
    notb %d1
    movew %a2@(6),%d0
    subw %d0,%d1
    notb %d1
    moveb %d1,%a3@(25)
    addaw #21,%a3
TFBDRVR_400:            /* write loop */
    movel %a0@-,%d1
    notl %d1
    moveb %d1,%a3@
    lsrl #8,%d1
    moveb %d1,%a3@
    lsrl #8,%d1
    moveb %d1,%a3@
    dbf %d0,TFBDRVR_400
    movew %sp@+,%sr
    lea %sp@(1024),%sp
    moveal %sp@+,%sp
    lea %sp@(128),%sp
    moveml %sp@+,%d5-%d7/%a5-%fp
    jbra TFBDRVR_150
TFBDRVR_426:            /* SetGamma (4): install a gamma table (8-bit, 256 entries) or a linear one (nil) */
    movel %a1,%sp@-
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    movel %a2@,%d0
    jbeq TFBDRVR_4BC
    moveal %d0,%a1
    tstl %a1@
    jbne TFBDRVR_4B6
    cmpiw #8,%a1@(10)
    jbne TFBDRVR_4B6
    cmpiw #256,%a1@(8)
    jbne TFBDRVR_4B6
    moveal %a3@(16),%a0
    movew %a1@(4),%d0
    cmpw %a0@(4),%d0
    jbne TFBDRVR_46A
    movew %a1@(6),%d0
    cmpw %a0@(6),%d0
    jbeq TFBDRVR_492
    jbgt TFBDRVR_46A
    _DisposPtr
    clrl %a3@(16)
TFBDRVR_46A:            /* (new size: allocate a new table) */
    movew #256,%d0
    muluw %a1@(6),%d0
    addw %a1@(4),%d0
    addiw #12,%d0
    .short  0xA51E	| 40897FFA _NewPtr (flags 0x0500)
    jbne TFBDRVR_4B6
    movel %a3@(16),%d0
    movel %a0,%a3@(16)
    tstl %d0
    jbeq TFBDRVR_492
    moveal %d0,%a0
    _DisposPtr
    moveal %a3@(16),%a0
TFBDRVR_492:            /* copy the table */
    movew %a1@(6),%d0
    movew %a1@(4),%d1
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    movew #256,%d2
    muluw %d0,%d2
    addw %d1,%d2
    subqw #1,%d2
TFBDRVR_4AA:            /* copy loop */
    moveb %a1@+,%a0@+
    dbf %d2,TFBDRVR_4AA
TFBDRVR_4B0:            /* done */
    moveal %sp@+,%a1
    jbra TFBDRVR_150
TFBDRVR_4B6:            /* invalid table: controlErr */
    moveal %sp@+,%a1
    jbra TFBDRVR_14C
TFBDRVR_4BC:            /* nil: linear (inverted) tables */
    moveal %a3@(16),%a0
    movew %a0@(4),%d0
    movew %a0@(6),%d2
    subqw #1,%d2
    lea %a0@(12),%a0
    addaw %d0,%a0
TFBDRVR_4D0:            /* each channel */
    movew #255,%d0
TFBDRVR_4D4:            /* each entry */
    moveb %d0,%a0@
    notb %a0@+
    dbf %d0,TFBDRVR_4D4
    dbf %d2,TFBDRVR_4D0
    jbra TFBDRVR_4B0
TFBDRVR_4E2:            /* GrayPage (5): fill the page with the gray pattern */
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    movew %a3@(4),%d1
    jbsr TFBDRVR_776
    jbne TFBDRVR_14C
    movew %a2@(6),%d0
    jbsr TFBDRVR_7A2
    jbne TFBDRVR_14C
    jbsr TFBDRVR_8C4
    jbra TFBDRVR_150
TFBDRVR_508:            /* SetGray (6): set flag bit (luminance mapping) */
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    movew %a3@(20),%d0
    moveb %a2@,%d1
    bfins %d1,%d0,16,1
    movew %d0,%a3@(20)
    jbra TFBDRVR_150
TFBDRVR_520:            /* SetInterrupt (7): 1 disables the VBL interrupt, 0 enables it */
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    movew %a3@(20),%d0
    moveb %a2@,%d1
    bfins %d1,%d0,17,1
    movew %d0,%a3@(20)
    btst #14,%d0
    jbeq TFBDRVR_55A
    jbsr TFBDRVR_704
    moveal %a1@(42),%a0
    addal #655367,%a0
    clrb %a0@
    moveal %a3@(12),%a0
    moveq #0,%d0
    moveb %a1@(40),%d0
    _SIntRemove
    jbra TFBDRVR_150
TFBDRVR_55A:            /* enable: SIntInstall the handler TFBDRVR_932, card interrupt on */
    moveal %a3@(12),%a0
    lea %pc@(TFBDRVR_932),%a4
    movew #6,%a0@(4)
    movel %a4,%a0@(8)
    movel %a1@(42),%a0@(12)
    moveq #0,%d0
    moveb %a1@(40),%d0
    _SIntInstall
    jbne TFBDRVR_14C
    moveal %a1@(42),%a0
    addal #655363,%a0
    clrb %a0@
    jbra TFBDRVR_150
    .short  0x2F08	| 4089810E
    .long   0x3028001A, 0x2468001C	| 40898110
    cmpiw #8,%d0
    jbhi TFBDRVR_5BA
    lslw #1,%d0
    movew %pc@(TFBDRVR_5A8,%d0:w),%d0
    jmp %pc@(TFBDRVR_5A8,%d0:w)
TFBDRVR_5A8:            /* Status dispatch: csCode 0..8 */
    .short  TFBDRVR_5BA-TFBDRVR_5A8	| 40898128
    .short  TFBDRVR_5BA-TFBDRVR_5A8	| 4089812A
    .short  TFBDRVR_5C6-TFBDRVR_5A8	| 4089812C
    .short  TFBDRVR_5DE-TFBDRVR_5A8	| 4089812E
    .short  TFBDRVR_65E-TFBDRVR_5A8	| 40898130
    .short  TFBDRVR_686-TFBDRVR_5A8	| 40898132
    .short  TFBDRVR_6C4-TFBDRVR_5A8	| 40898134
    .short  TFBDRVR_6DC-TFBDRVR_5A8	| 40898136
    .short  TFBDRVR_6F6-TFBDRVR_5A8	| 40898138
TFBDRVR_5BA:            /* statusErr (-18) */
    moveq #-18,%d0
    jbra TFBDRVR_5C0
TFBDRVR_5BE:            /* noErr */
    moveq #0,%d0
TFBDRVR_5C0:            /* done */
    moveal %sp@+,%a0
    jbra TFBDRVR_73C
TFBDRVR_5C6:            /* GetMode (2): mode, page, base address */
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    movew %a3@(4),%a2@
    movew %a3@(6),%a2@(6)
    movel %a3@(8),%a2@(8)
    jbra TFBDRVR_5BE
TFBDRVR_5DE:            /* GetEntries (3): read back CLUT entries */
    movel %a2@,%d0
    jbeq TFBDRVR_5BA
    moveal %d0,%a0
    movew %a2@(6),%d0
    cmpiw #-1,%a2@(4)
    jbeq TFBDRVR_602
    movew %d0,%d1
    movew %d0,%d2
    addw %a2@(4),%d2
TFBDRVR_5F8:            /* sequence mode: fill in the indexes */
    movew %d2,%a0@(0x0,%d1:w:8)
    subqw #1,%d2
    dbf %d1,TFBDRVR_5F8
TFBDRVR_602:            /* CLUT read register */
    moveml %d6-%d7,%sp@-
    jbsr TFBDRVR_74C
    moveal %a1@(42),%a3
    addal #589827,%a3
TFBDRVR_614:            /* one entry: red, green, blue (inverted, byte doubled) */
    movew %a0@,%d1
    cmpw %d6,%d1
    jbhi TFBDRVR_650
    oril #-65536,%d1
    roll %d7,%d1
    moveb %d1,%a3@(25)
    moveb %a3@(37),%d1
    notw %d1
    moveb %d1,%a0@(2)
    moveb %d1,%a0@(3)
    moveb %a3@(37),%d1
    notw %d1
    moveb %d1,%a0@(4)
    moveb %d1,%a0@(5)
    moveb %a3@(37),%d1
    notw %d1
    moveb %d1,%a0@(6)
    moveb %d1,%a0@(7)
TFBDRVR_650:            /* next */
    addql #8,%a0
    dbf %d0,TFBDRVR_614
    moveml %sp@+,%d6-%d7
    jbra TFBDRVR_5BE
TFBDRVR_65E:            /* GetPageCnt (4): pages = memory / depth */
    movew %a2@,%d1
    jbsr TFBDRVR_776
    jbne TFBDRVR_5BA
    moveal %a1@(20),%a0
    moveal %a0@,%a0
    tstb %a0@(22)
    jbne TFBDRVR_678
    moveq #4,%d0
    jbra TFBDRVR_67A
TFBDRVR_678:            /* (smaller card) */
    moveq #3,%d0
TFBDRVR_67A:            /* count */
    divuw %d1,%d0
    addqw #1,%d0
    movew %d0,%a2@(6)
    jbra TFBDRVR_5BE
TFBDRVR_686:            /* GetBaseAddr (5): base address of a page */
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    movew %a3@(4),%d1
    jbsr TFBDRVR_776
    movew %a2@(6),%d0
    jbsr TFBDRVR_7A2
    jbne TFBDRVR_5BA
    movew %a3@(4),%d1
    subiw #128,%d1
    lea %pc@(TFBDRVR_912),%a0
    muluw %a0@(0x4,%d1:w:8),%d0
    muluw %a0@(0x6,%d1:w:8),%d0
    moveq #32,%d1
    addl %d1,%d0
    addl %a1@(42),%d0
    movel %d0,%a2@(8)
    jbra TFBDRVR_5BE
TFBDRVR_6C4:            /* GetGray (6) */
    clrw %a2@
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    tstw %a3@(20)
    jbpl TFBDRVR_5BE
    moveb #1,%a2@
    jbra TFBDRVR_5BE
TFBDRVR_6DC:            /* GetInterrupt (7) */
    clrw %a2@
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    btst #14,%a3@(20)
    jbeq TFBDRVR_5BE
    moveb #1,%a2@
    jbra TFBDRVR_5BE
TFBDRVR_6F6:            /* GetGamma (8) */
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    movel %a3@(16),%a2@
    jbra TFBDRVR_5BE

TFBDRVR_704:            /* wait for the start of vertical blanking (status register bit 0) */
    movel %a0,%sp@-
    movel %d0,%sp@-
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    jbge TFBDRVR_71A
    oriw #512,%sr
    andiw #-1281,%sr
TFBDRVR_71A:            /* status register */
    moveal %a1@(42),%a0
    addal #851971,%a0
TFBDRVR_724:            /* wait while set */
    moveb %a0@,%d0
    btst #0,%d0
    jbne TFBDRVR_724
TFBDRVR_72C:            /* then until set */
    moveb %a0@,%d0
    btst #0,%d0
    jbeq TFBDRVR_72C
    movew %sp@+,%sr
    movel %sp@+,%d0
    moveal %sp@+,%a0
    rts

TFBDRVR_73C:            /* return from the driver: rts if immediate, else IODone */
    btst #9,%a0@(6)
    jbeq TFBDRVR_746
    rts
TFBDRVR_746:            /* IODone */
    moveal JIODone,%a0
    jmp %a0@

TFBDRVR_74C:            /* d6 = highest CLUT index for the mode, d7 = rotation for the index */
    moveml %d0/%d4/%a3,%sp@-
    moveal %a1@(20),%a3
    moveal %a3@,%a3
    movew %a3@(4),%d7
    subiw #128,%d7
    moveq #1,%d4
    lslw %d7,%d4
    movew %d4,%d0
    subqw #1,%d0
    moveq #2,%d6
    lslw %d0,%d6
    subqw #1,%d6
    moveq #8,%d7
    subw %d4,%d7
    moveml %sp@+,%d0/%d4/%a3
    rts

TFBDRVR_776:            /* check mode d1 (and 8 bits only on the 1 MB card). Out: d1 = depth, Z = valid */
    subiw #128,%d1
    jbmi TFBDRVR_7A0
    cmpiw #3,%d1
    jbgt TFBDRVR_7A0
    moveq #1,%d0
    lslw %d1,%d0
    movew %d0,%d1
    cmpiw #8,%d1
    jbne TFBDRVR_79E
    movel %a0,%sp@-
    moveal %a1@(20),%a0
    moveal %a0@,%a0
    tstb %a0@(22)
    moveal %sp@+,%a0
    jbne TFBDRVR_7A0
TFBDRVR_79E:            /* valid */
    cmpw %d1,%d1
TFBDRVR_7A0:            /* return */
    rts

TFBDRVR_7A2:            /* check page d0 for depth d1. Out: Z set if valid */
    moveml %d2/%a0,%sp@-
    moveal %a1@(20),%a0
    moveal %a0@,%a0
    tstb %a0@(22)
    jbne TFBDRVR_7B6
    moveq #4,%d2
    jbra TFBDRVR_7B8
TFBDRVR_7B6:            /* (smaller card: 3 pages / depth) */
    moveq #3,%d2
TFBDRVR_7B8:            /* compare */
    divuw %d1,%d2
    cmpw %d2,%d0
    sgt %d2
    tstb %d2
    moveml %sp@+,%d2/%a0
    rts

TFBDRVR_7C6:            /* load the card's timing registers from the table TFBDRVR_7E8 */
    moveml %d0/%a0-%a1,%sp@-
    moveal %a1@(42),%a0
    addal #589823,%a0
    lea %pc@(TFBDRVR_7E8),%a1
    moveq #15,%d0
TFBDRVR_7DA:            /* 16 registers, 4 bytes apart (downwards) */
    moveb %a1@+,%a0@
    subqw #4,%a0
    dbf %d0,TFBDRVR_7DA
    moveml %sp@+,%d0/%a0-%a1
    rts
TFBDRVR_7E8:            /* timing register values */
    .long   0xDFB8FFFF, 0xE11A88B9	| 40898368
    .long   0xFAFDFDFE, 0xF0BEFA37	| 40898370

TFBDRVR_7F8:            /* set the depth: control registers from the table for the depth */
    moveml %d0-%d2/%a0-%a1,%sp@-
    movew %a2@,%a3@(4)
    jbsr TFBDRVR_704
    moveal %a1@(42),%a0
    addal #524291,%a0
    cmpiw #8,%d1
    jbgt TFBDRVR_83A
    moveq #0,%d0
TFBDRVR_816:            /* log2 of the depth */
    lsrw #1,%d1
    jbcs TFBDRVR_81E
    addqw #1,%d0
    jbra TFBDRVR_816
TFBDRVR_81E:            /* write the 16 control register values for it */
    moveb #0xb7,%a0@(60)
    lea %pc@(TFBDRVR_840),%a1
    lslw #4,%d0
    addaw %d0,%a1
    moveq #15,%d0
TFBDRVR_82E:            /* one register (inverted) */
    moveb %a1@+,%d1
    notb %d1
    moveb %d1,%a0@
    addqw #4,%a0
    dbf %d0,TFBDRVR_82E
TFBDRVR_83A:            /* return */
    moveml %sp@+,%d0-%d2/%a0-%a1
    rts
TFBDRVR_840:            /* control register values, 16 per depth */
    .long   0x20470008, 0x1EE57746, 0x05020201, 0x0F4105C8	| 408983C0
    .long   0x40470008, 0x3CE57746, 0x05060604, 0x20040BD8	| 408983D0
    .long   0x80470008, 0x78E57746, 0x050E0E0A, 0x428A16E8	| 408983E0
    .long   0x00470008, 0xF0E57746, 0x051E1E16, 0x86962DF9	| 408983F0

TFBDRVR_880:            /* set the page: base address = card + 32 + page x size, video start register */
    moveml %d0-%d1/%a0-%a1,%sp@-
    movew %d0,%a3@(6)
    movew %a2@,%d1
    subiw #128,%d1
    lea %pc@(TFBDRVR_912),%a0
    muluw %a0@(0x4,%d1:w:8),%d0
    muluw %a0@(0x6,%d1:w:8),%d0
    moveq #32,%d1
    addl %d1,%d0
    movel %d0,%d1
    moveal %a1@(42),%a0
    addl %a0,%d0
    movel %d0,%a3@(8)
    lsrl #2,%d1
    addal #524291,%a0
    notw %d1
    moveb %d1,%a0@(12)
    lsrw #8,%d1
    moveb %d1,%a0@(8)
    moveml %sp@+,%d0-%d1/%a0-%a1
    rts

TFBDRVR_8C4:            /* fill the page with the 50% gray pattern (not at 8 bits on the small card) */
    moveml %d0-%d4/%a0-%a1,%sp@-
    movew %a3@(4),%d1
    subiw #128,%d1
    cmpiw #3,%d1
    jbne TFBDRVR_8DC
    tstb %a3@(22)
    jbne TFBDRVR_90C
TFBDRVR_8DC:            /* pattern and size for the depth (TFBDRVR_912) */
    lea %pc@(TFBDRVR_912),%a1
    movel %a1@(0x0,%d1:w:8),%d0
    movew %a1@(0x4,%d1:w:8),%d4
    movew %a1@(0x6,%d1:w:8),%d3
    subqw #1,%d3
    movel %d0,%d1
    notl %d1
    moveal %a3@(8),%a1
TFBDRVR_8F6:            /* each row, pattern inverted on the next row */
    moveal %a1,%a0
    movew %d4,%d2
    lsrw #2,%d2
    subqw #1,%d2
TFBDRVR_8FE:            /* one row */
    movel %d0,%a0@+
    dbf %d2,TFBDRVR_8FE
    exg %d0,%d1
    addaw %d4,%a1
    dbf %d3,TFBDRVR_8F6
TFBDRVR_90C:            /* return */
    moveml %sp@+,%d0-%d4/%a0-%a1
    rts
TFBDRVR_912:            /* per depth: gray pattern, row bytes, rows */
    .short  0xAAAA, 0xAAAA, 0x0080, 0x01E0, 0xCCCC, 0xCCCC, 0x0100	| 40898492
    .long   0x01E0F0F0, 0xF0F00200, 0x01E0FF00, 0xFF000400	| 408984A0
    .short  0x01E0	| 408984B0
TFBDRVR_932:            /* VBL interrupt handler: clear the card's interrupt, run the slot's VBL tasks (JVBLTask 0xD28) */
    moveal %a1,%a0
    movel %a1,%d0
    addal #655363,%a0
    clrb %a0@
    roll #8,%d0
    andiw #15,%d0
    moveal JVBLTask,%a0
    jsr %a0@
    moveq #1,%d0
    rts
TFBDRVRSIZE:            /* size of the driver */
    .short  0x0000	| 408984CE
    .long   0x094E0000, 0x00000000, 0x00000000, 0x00000000	| 408984D0

/* TFBPRIMARYINIT: the card's PrimaryInit code (raw words): set up the card at start-up. */
TFBPRIMARYINIT:
    .short  0x6020	| bras 40898502 <TFBPRIMARYINIT+0x22>
TFBPRIMARYINIT_2:
    .short  0xDFB8, 0xFFFF	| addl %d7,ffffffff <__bss_start+0xbf6fffff>
    rolb #8,%d2
    .short  0x88B9, 0xFAFD, 0xFDFE	| orl fafdfdfe <__bss_start+0xba6dfdfe>,%d4
    .short  0xF0BE	| .short 0xf0be
    .short  0xFA37	| .short 0xfa37
TFBPRIMARYINIT_12:
    moveal %d7,%a0
    .short  0x0008	| .short 0x0008
    moveb %a5@-,%sp@+
    .short  0x7746	| .short 0x7746
    btst %d2,%d2
    .short  0x0201, 0x0F41	| 408984FC andib #65,%d1
    movepl %d2,%a0@(18663)
    .short  0xF0E0	| .short 0xf0e0
    movew #1,%a0@(2)
    moveal %a0,%a3
    moveq #0,%d0
    moveb %a0@,%d0
    lslw #4,%d0
    orb %a0@,%d0
    oriw #3840,%d0
    swap %d0
    lsll #4,%d0
    moveal %d0,%a2
    moveal %a2,%a0
    addal #589823,%a0
    lea %pc@(TFBPRIMARYINIT_2),%a1
    moveq #15,%d0
TFBPRIMARYINIT_4E:
    moveb %a1@+,%a0@
    subqw #4,%a0
    dbf %d0,TFBPRIMARYINIT_4E
    moveal %a2,%a0
    addal #524291,%a0
    lea %pc@(TFBPRIMARYINIT_12),%a1
    moveq #15,%d0
TFBPRIMARYINIT_64:
    moveb %a1@+,%d1
    notb %d1
    moveb %d1,%a0@
    addqw #4,%a0
    dbf %d0,TFBPRIMARYINIT_64
    moveal %a2,%a0
    addal #655367,%a0
    clrb %a0@
    movew %sr,%sp@-
    moveq #7,%d0
    andb %sp@,%d0
    subqb #2,%d0
    bges TFBPRIMARYINIT_8C
    oriw #512,%sr
    andiw #-1281,%sr
TFBPRIMARYINIT_8C:
    moveal %a2,%a0
    addal #589827,%a0
    moveq #0,%d0
    notb %d0
    moveb %d0,%a0@(25)
    addaw #21,%a0
    moveq #-1,%d1
    movew #383,%d0
TFBPRIMARYINIT_A6:
    moveb %d1,%a0@
    dbf %d0,TFBPRIMARYINIT_A6
    moveq #0,%d1
    movew #383,%d0
TFBPRIMARYINIT_B2:
    moveb %d1,%a0@
    dbf %d0,TFBPRIMARYINIT_B2
    movew %sp@+,%sr
    subaw #56,%sp
    moveal %sp,%a0
    moveb %a3@,%a0@(49)
    clrb %a0@(51)
    movel #271356,%d1
    movel #1296122674,%a2@(0x0,%d1:l)
    movel #-1,%sp@-
    addqw #4,%sp
    movel %a2@(0x0,%d1:l),%d0
    cmpil #1296122674,%d0
    beqs TFBPRIMARYINIT_F2
    moveb #0x80,%a0@(50)	| 408985CA
    bras TFBPRIMARYINIT_FC
TFBPRIMARYINIT_F2:
    clrb %a2@(0x0,%d1:l)
    moveb #0x81,%a0@(50)	| 408985D6
TFBPRIMARYINIT_FC:
    moveq #49,%d0
    _SlotManager
    bnes TFBPRIMARYINIT_108
    movew #2,%a3@(2)
TFBPRIMARYINIT_108:
    lea %sp@(56),%sp
    movel #-1431655766,%d0
    movel %d0,%d1
    notl %d1
    movew #128,%d4
    movew #2047,%d3
    moveal %a2,%a1
TFBPRIMARYINIT_120:
    moveal %a1,%a0
    movew #31,%d2
TFBPRIMARYINIT_126:
    movel %d0,%a0@+
    dbf %d2,TFBPRIMARYINIT_126
    exg %d0,%d1
    addaw %d4,%a1
    dbf %d3,TFBPRIMARYINIT_120
    moveml %sp@+,%d0-%d3/%a0-%a2
    rts
    .short  0x0000, 0x0000	| orib #0,%d0
    .short  0x0000	| 4089861E
