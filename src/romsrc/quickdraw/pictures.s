/*
 quickdraw/pictures.s - pictures
 From GETUBYTE (0x40832B60). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the QuickDraw chapters of Inside Macintosh, not taken from Apple. Routine headers name the trap or job of each routine; labels inside say what each step does.
*/

/* GETUBYTE: GetUByte: the next byte of the picture being drawn (GETPICDATA), zero-extended in d0 */
GETUBYTE:
    clrb %sp@-
    movel %sp,%sp@-
    movew #1,%sp@-
    jsr %pc@(GETPICDATA)
    clrw %d0
    moveb %sp@+,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40832B72

/* GETWORD: GetWord: the next word of the picture in d0 */
GETWORD:
    clrw %sp@-
    movel %sp,%sp@-
    movew #2,%sp@-
    jsr %pc@(GETPICDATA)
    movew %sp@+,%d0
    rts

/* GETLONG: GetLong: the next long of the picture in d0 */
GETLONG:
    clrl %sp@-
    movel %sp,%sp@-
    movew #4,%sp@-
    jsr %pc@(GETPICDATA)
    movel %sp@+,%d0
    rts

/* GETPICDATA: GetPicData(ptr, count): read picture data through the port's getPicProc (grafProcs+44) or the default (vector 0x11B8) */
GETPICDATA:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x11b8,%a0
    jbeq GETPICDATA_14
    moveal %d0,%a0
    moveal %a0@(44),%a0
GETPICDATA_14:          /* call it; count the bytes read (QuickDraw globals -180) */
    movel %sp@(6),%sp@-
    movew %sp@(8),%sp@-
    jsr %a0@
    moveal %a5@,%a0
    moveq #0,%d0
    movew %sp@(4),%d0
    addl %d0,%a0@(-180)
    rtd #6
    .short  0x0000	| 40832BCE

/* PUTPICDATA: PutPicData(ptr, count): write picture data through the port's putPicProc (grafProcs+48) or the default (vector 0x11C0) */
PUTPICDATA:
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x11c0,%a0
    jbeq PUTPICDATA_14
    moveal %d0,%a0
    moveal %a0@(48),%a0
PUTPICDATA_14:          /* jump to the proc */
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40832BE6

/* DPUTPICBYTE: DPutPicByte: PutPicByte with the byte in d0 */
trap_DPUTPICBYTE:
DPUTPICBYTE:
    moveal %sp@+,%a0
    moveb %d0,%sp@-
    movel %a0,%sp@-

/* PUTPICBYTE: PutPicByte(byte): one byte to the picture */
PUTPICBYTE:
    pea %sp@(4)
    movew #1,%sp@-
    jsr %pc@(PUTPICDATA)
    moveal %sp@+,%a0
    tstb %sp@+
    jmp %a0@
    .long   0x00000000, 0x00000000	| 40832C08

/* PUTPICWORD: PutPicWord(word): one word to the picture */
PUTPICWORD:
    pea %sp@(4)
    movew #2,%sp@-
    jsr %pc@(PUTPICDATA)
    moveal %sp@+,%a0
    tstw %sp@+
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40832C22

/* PUTPICLONG: PutPicLong(long): one long to the picture */
PUTPICLONG:
    pea %sp@(4)
    movew #4,%sp@-
    jsr %pc@(PUTPICDATA)
    movel %sp@+,%sp@
    rts

/* PUTPICRECT: PutPicRect(opcode, rect): a rectangle opcode; the same rectangle as last time (picture state +74) uses the "same" opcode form */
PUTPICRECT:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    moveq #0,%d0
    moveb %sp@+,%d0
    movel %a0,%sp@-
    movel %a1@,%d2
    movel %a1@(4),%d1
    moveal %a5@,%a0
    moveal %a0@,%a0
    moveal %a0@(92),%a0
    moveal %a0@,%a0
    cmpl %a0@(74),%d2
    jbne PUTPICRECT_2C
    cmpl %a0@(78),%d1
    jbne PUTPICRECT_2C
    addqw #8,%d0
    jmp %pc@(trap_DPUTPICOP)
PUTPICRECT_2C:          /* a new rectangle: remember it, write opcode + verb and the 8 bytes */
    movel %d2,%a0@(74)
    movel %d1,%a0@(78)
    movel %a1,%sp@-
    movew #8,%sp@-
    jsr %pc@(trap_DPUTPICOP)
    jsr %pc@(PUTPICDATA)
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40832C84

/* DPUTPICOP: DPutPicOp: PutPicOp with the opcode in d0 */
trap_DPUTPICOP:
DPUTPICOP:
    moveal %sp@+,%a0
    movew %d0,%sp@-
    movel %a0,%sp@-

/* PUTPICOP: PutPicOp(op): pad to a word (version 2) and write the opcode */
PUTPICOP:
    jsr %pc@(PUTPICPAD)

/* PUTPICOP2: write an opcode: one byte in version 1 pictures, a word in version 2 */
PUTPICOP2:
    moveal %a5@,%a0
    moveal %a0@,%a0
    moveal %a0@(92),%a0
    moveal %a0@,%a0
    moveq #2,%d0
    lea %sp@(4),%a1
    cmpiw #1,%a0@(98)
    jbne PUTPICOP2_1C
    moveq #1,%d0
    addqw #1,%a1
PUTPICOP2_1C:           /* write it */
    movel %a1,%sp@-
    movew %d0,%sp@-
    jsr %pc@(PUTPICDATA)
    moveal %sp@+,%a0
    tstw %sp@+
    jmp %a0@
    .long   0x00000000, 0x00000000, 0x00000000	| 40832CC4

/* PUTPICRGN: PutPicRgn(rgn): the region's data, the handle locked while written */
PUTPICRGN:
    moveal %sp@(4),%a0
    _HLock
    moveal %a0@,%a0
    movel %a0,%sp@-
    movew %a0@,%sp@-
    jsr %pc@(PUTPICDATA)
    moveal %sp@(4),%a0
    _HUnlock
    movel %sp@+,%sp@
    rts
    .short  0x0000, 0x0000, 0x0000	| 40832CEA

/* PUTPICPAD: PutPicPad: version 2 pictures keep opcodes word aligned: write a 0 byte when the picture size is odd */
PUTPICPAD:
    moveal %a5@,%a0
    moveal %a0@,%a0
    moveal %a0@(92),%a0
    moveal %a0@,%a0
    cmpiw #1,%a0@(98)
    jbeq PUTPICPAD_24
    moveal %a0@,%a0
    moveal %a0@,%a0
    movew %a0@,%d0
    btst #0,%d0
    jbeq PUTPICPAD_24
    moveq #0,%d0
    jsr %pc@(trap_DPUTPICBYTE)
PUTPICPAD_24:           /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40832D16

/* PUTPICPAT: PutPicPat(pat): the 8 bytes of a pattern */
PUTPICPAT:
    moveal %sp@+,%a0
    movew #8,%sp@-
    movel %a0,%sp@-
    jmp %pc@(PUTPICDATA)
    .long   0x00000000	| 40832D2C

/* PUTPICVERB: PutPicVerb(verb): before a shape: record the pen, fill or background state the verb uses when it changed (frame: pen size, mode, pattern; paint; erase: background; fill) */
PUTPICVERB:
    linkw %fp,#0
    moveml %d7/%a3-%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a3
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    moveb %fp@(8),%d7
    cmpib #1,%d7
    jblt PUTPICVERB_66
    jbeq PUTPICVERB_86
    cmpib #3,%d7
    jbeq PUTPICVERB_DE
    jblt PUTPICVERB_48
    pea %a3@(40)
    movel %a3@(62),%sp@-
    pea %a4@(66)
    movel %a4@(128),%sp@-
    movew #10,%sp@-
    movew #20,%sp@-
    jsr %pc@(UPDATEPAT)
    jbra PUTPICVERB_DE
PUTPICVERB_48:          /* erase: the background pattern (bkPat / BkPixPat, opcodes 2 / 18) */
    pea %a3@(32)
    movel %a3@(32),%sp@-
    pea %a4@(16)
    movel %a4@(136),%sp@-
    movew #2,%sp@-
    movew #18,%sp@-
    jsr %pc@(UPDATEPAT)
    jbra PUTPICVERB_DE
PUTPICVERB_66:          /* frame: pen size changed? opcode 7 (PnSize) */
    movel %a3@(52),%d7
    cmpl %a4@(52),%d7
    jbeq PUTPICVERB_86
    moveq #7,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %d7,%sp@-
    jsr %pc@(PUTPICLONG)
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %d7,%a4@(52)
PUTPICVERB_86:          /* pen mode changed? opcode 8; version 1 pictures get arithmetic modes mapped to boolean ones (table at E8) */
    movew %a3@(56),%d7
    cmpw %a4@(56),%d7
    jbeq PUTPICVERB_C2
    cmpiw #1,%a4@(98)
    jbne PUTPICVERB_AC
    btst #5,%d7
    jbeq PUTPICVERB_AC
    andiw #7,%d7
    moveb %pc@(PUTPICVERB_E8,%d7:w),%d7
    cmpw %a4@(28),%d7
    jbeq PUTPICVERB_C2
PUTPICVERB_AC:          /* write PnMode */
    moveq #8,%d0
    jsr %pc@(trap_DPUTPICOP)
    movew %d7,%sp@-
    jsr %pc@(PUTPICWORD)
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movew %d7,%a4@(56)
PUTPICVERB_C2:          /* the pen pattern (PnPat / PnPixPat, opcodes 9 / 19) */
    pea %a3@(58)
    movel %a3@(58),%sp@-
    pea %a4@(58)
    movel %a4@(132),%sp@-
    movew #9,%sp@-
    movew #19,%sp@-
    jsr %pc@(UPDATEPAT)
PUTPICVERB_DE:          /* restore registers, return */
    moveml %sp@+,%d7/%a3-%a4
    unlk %fp
    rtd #2
PUTPICVERB_E8:          /* arithmetic to boolean mode map for version 1 (data) */
    .long   0x00030201, 0x01030201	| 40832E18

/* UPDATEPAT: UpdatePat: record a pattern or pixpat change (version 2: PnPixPat/BkPixPat/FillPixPat opcodes) when it differs from the picture's saved one */
UPDATEPAT:
    linkw %fp,#0
    moveml %d5-%d6,%sp@-
    cmpiw #1,%a4@(98)
    jbne UPDATEPAT_40
    moveal %fp@(24),%a0
    movel %a0@+,%d5
    movel %a0@,%d6
UPDATEPAT_18:           /* version 1: same 8 bytes as the saved pattern? nothing to do */
    moveal %fp@(16),%a0
    cmpl %a0@+,%d5
    jbne UPDATEPAT_26
    cmpl %a0@,%d6
    beqw UPDATEPAT_9E
UPDATEPAT_26:           /* remember it, write the opcode and the pattern */
    moveal %fp@(16),%a0
    movel %d5,%a0@+
    movel %d6,%a0@
    movew %fp@(10),%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %fp@(16),%sp@-
    jsr %pc@(PUTPICPAT)
    jbra UPDATEPAT_9E
UPDATEPAT_40:           /* version 2: an old-style pattern in the port: make the saved one an old-style pixpat */
    moveal %fp@(12),%a1
    moveal %a1@,%a1
    movew %a1@,%d0
    moveal %fp@(20),%a0
    moveal %a0@,%a0
    cmpiw #0,%a0@
    jbne UPDATEPAT_68
    clrw %a1@
    moveal %a0@(6),%a0
    moveal %a0@,%a0
    movel %a0@+,%d5
    movel %a0@,%d6
    cmpiw #0,%d0
    jbne UPDATEPAT_26
    jbra UPDATEPAT_18
UPDATEPAT_68:           /* pixpat: same as the saved one (EQUALPAT)? nothing to do */
    cmpiw #0,%d0
    jbeq UPDATEPAT_80
    clrb %sp@-
    movel %fp@(20),%sp@-
    movel %fp@(12),%sp@-
    jsr %pc@(EQUALPAT)
    tstb %sp@+
    jbne UPDATEPAT_9E
UPDATEPAT_80:           /* copy it (CopyPixPat) and write the opcode and the pixpat */
    movel %fp@(20),%sp@-
    movel %fp@(12),%sp@-
    /* %za0: no index register. It only sets bit 15 of the extension word. */
    jsr @(0x1624,%za0)@(0x0)	| 40832EA8
    movew %fp@(8),%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %fp@(12),%sp@-
    jsr %pc@(PUTPICPIXPAT)
UPDATEPAT_9E:           /* restore registers, return */
    moveml %sp@+,%d5-%d6
    unlk %fp
    rtd #20
    .long   0x00000000, 0x00000000	| 40832EC8

/* EQUALPAT: EqualPat(pp1, pp2): are two pixpats the same (type, data and pattern)? */
EQUALPAT:
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    clrb %fp@(16)
    moveal %fp@(8),%a4
    moveal %a4@,%a0
    moveal %a0@(6),%a0
    moveal %a0@,%a1
    _GetHandleSize
    movel %d0,%d2
    moveal %fp@(12),%a3
    moveal %a3@,%a0
    moveal %a0@(6),%a0
    _GetHandleSize
    cmpl %d0,%d2
    jbne EQUALPAT_92
    lsrl #1,%d0
    subqw #1,%d0
    moveal %a0@,%a0
EQUALPAT_32:            /* compare the pixpat records */
    cmpmw %a0@+,%a1@+
    jbne EQUALPAT_92
    dbf %d0,EQUALPAT_32
    moveal %a3@,%a0
    moveal %a4@,%a1
    cmpmw %a0@+,%a1@+
    jbne EQUALPAT_92
    movel %a0@(18),%d0
    cmpl %a1@(18),%d0
    jbne EQUALPAT_92
    movel %a0@(22),%d1
    cmpw %a1@(22),%d1
    jbne EQUALPAT_92
    moveal %a0@,%a0
    moveal %a0@,%a0
    moveal %a1@,%a1
    moveal %a1@,%a1
    cmpml %a0@+,%a1@+
    movew #18,%d0
EQUALPAT_64:            /* compare the pixmaps */
    cmpmw %a0@+,%a1@+
    jbne EQUALPAT_92
    dbf %d0,EQUALPAT_64
    moveal %a0@,%a0
    moveal %a0@,%a0
    moveal %a1@,%a1
    moveal %a1@,%a1
    cmpml %a0@+,%a1@+
    cmpmw %a0@+,%a1@+
    jbne EQUALPAT_92
    movew %a0@+,%d0
    cmpw %a1@+,%d0
    jbne EQUALPAT_92
EQUALPAT_80:            /* compare the pattern data; equal: true */
    cmpml %a0@+,%a1@+
    jbne EQUALPAT_92
    cmpml %a0@+,%a1@+
    jbne EQUALPAT_92
    dbf %d0,EQUALPAT_80
    moveb #1,%fp@(16)
EQUALPAT_92:            /* restore registers, return */
    moveml %sp@+,%a3-%a4
    unlk %fp
    rtd #8
    .long   0x00000000	| 40832F6C

/* GETPICTABLE: table. */
GETPICTABLE:
    jsr %pc@(GETLONG)
    cmpil #1023,%d0
    jblt GETPICTABLE_16
    clrl %sp@-
    jsr @(0x16a0,%za0)@(0)	| 40832F7E
    movel %sp@+,%d0
GETPICTABLE_16:         /* read a color table: seed, flags/count, then the entries */
    movel %d0,%sp@-
    jsr %pc@(GETLONG)
    movel %d0,%sp@-
    movew %d0,%d2
    addqw #1,%d2
    muluw #8,%d2
    movel %d2,%d0
    addqw #8,%d0
    moveal %sp@(12),%a0
    jsr %pc@(RSETHSIZE)
    _HLock
    moveal %a0@,%a0
    movel %sp@+,%d0
    movel %sp@+,%a0@+
    movel %d0,%a0@+
    movel %a0,%sp@-
    movew %d2,%sp@-
    jsr %pc@(GETPICDATA)
    moveal %sp@(4),%a0
    _HUnlock
    movel %sp@+,%sp@
    rts
    .short  0x0000	| 40832FBE

/* PUTPICTABLE: table. */
PUTPICTABLE:
    moveal %sp@(4),%a0
    _HLock
    moveal %a0@,%a0
    movel %a0,%sp@-
    movew %a0@(6),%d0
    addqw #1,%d0
    muluw #8,%d0
    addqw #8,%d0
    movew %d0,%sp@-
    jsr %pc@(PUTPICDATA)
    moveal %sp@(4),%a0
    _HUnlock
    movel %sp@+,%sp@
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40832FE6

/* GETPICPIXMAP: read a pixel map from a picture. */
GETPICPIXMAP:
    moveal %sp@(4),%a0
    _HLock
    moveal %a0@,%a0
    movel %a0@(42),%sp@-
    clrl %a0@+
    movel %a0,%sp@-
    movew #46,%sp@-
    jsr %pc@(GETPICDATA)
    movel %sp@+,%d0
    moveal %sp@(4),%a0
    moveal %a0@,%a0
    movel %d0,%a0@(42)
    movel %d0,%sp@-
    jsr %pc@(GETPICTABLE)
    moveal %sp@(4),%a0
    _HUnlock
    movel %sp@+,%sp@
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 40833024

/* PUTPICPIXMAP: write a pixel map to a picture. */
PUTPICPIXMAP:
    moveal %sp@(4),%a0
    _HLock
    moveal %a0@,%a0
    pea %a0@(4)
    movew #46,%sp@-
    jsr %pc@(PUTPICDATA)
    moveal %sp@(4),%a0
    moveal %a0@,%a0
    movel %a0@(42),%d0
    jbeq PUTPICPIXMAP_26
    movel %d0,%sp@-
    jsr %pc@(PUTPICTABLE)
PUTPICPIXMAP_26:        /* unlock, return */
    moveal %sp@(4),%a0
    _HUnlock
    movel %sp@+,%sp@
    rts

/* GETPICPIXPAT: GetPicPixPat: read a pixpat from the picture: old pattern, then type 1 (color) or 2 (RGB dither) data */
GETPICPIXPAT:
    moveq #10,%d0
    subaw %d0,%sp
    movel %sp,%sp@-
    movew %d0,%sp@-
    jsr %pc@(GETPICDATA)
    cmpiw #2,%sp@
    jbne PUTGRAY_62
    subqw #6,%sp
    jbsr GETLONG
    movel %d0,%sp@
    jbsr GETWORD
    movew %d0,%sp@(4)
    tstw %a3@(6)
    jbmi PUTGRAY_52
    movel %sp,%sp@-
    movel %sp@(28),%sp@-
    jbsr PUTGRAY
    lea %sp@(16),%sp
    jbra PUTGRAY_A4

/* PUTGRAY: PutGray(rgb): the old-style pattern nearest to an RGB's luminance (0.30 R + 0.59 G + 0.11 B), from 8 shades of gray */
PUTGRAY:
    moveal %sp@(8),%a1
    movew %a1@+,%d0
    muluw #19660,%d0
    movew %a1@+,%d1
    muluw #-26870,%d1
    addl %d1,%d0
    movew %a1@+,%d1
    muluw #7208,%d1
    addl %d1,%d0
    clrw %d0
    roll #3,%d0
    lea %pc@(PUTGRAY_32),%a0
    lea %a0@(0x0,%d0:w:4),%a0
    moveal %sp@(4),%a1
    movel %a0@,%a1@+
    movel %a0@,%a1@
    rtd #8
PUTGRAY_32:             /* the 8 gray patterns (data) */
    .long   0xFFFFFFFF	| 408330CC
    .long   0xDDFF77FF, 0xFF55FF55, 0xEE55BB55, 0xAA55AA55	| 408330D0
    .long   0x88552255, 0x88002200, 0x00000000	| 408330E0
PUTGRAY_52:             /* pattern type 2 (RGB): the RGB, and the nearest gray as the old pattern */
    movel %sp@(20),%sp@-
    pea %sp@(4)
    jsr @(0x1634,%za0)@(0x0)	| 408330F4
    addqw #6,%sp
PUTGRAY_62:             /* (GetPicPixPat) old port: just the old pattern */
    tstw %a3@(6)
    jbmi PUTGRAY_7E
    moveal %sp@(18),%a1
    movew %sp@+,%d0
    movel %sp@+,%a1@+
    movel %sp@+,%a1@+
    moveal %fp@(8),%a2
    movel %a2@(58),%sp@-
    jbsr PUTGRAY_A8
    jbra PUTGRAY_A4
PUTGRAY_7E:             /* color port: type, then the pixpat's data for type 1 */
    moveal %sp@(14),%a0
    moveal %a0@,%a0
    movew %sp@+,%a0@
    movel %sp@+,%a0@(20)
    movel %sp@+,%a0@(24)
    cmpiw #2,%a0@
    jbeq PUTGRAY_9A
    movel %sp@(4),%sp@-
    jbsr PUTGRAY_A8
PUTGRAY_9A:             /* PixPatChanged */
    movel %sp@(4),%sp@-
    jsr @(0x1a4c,%za0)@(0)	| 40833138
PUTGRAY_A4:             /* return */
    rtd #8

PUTGRAY_A8:             /* read a type-1 pixpat's pixmap, color table and data */
    moveal %sp@(4),%a0
    moveal %a0@,%a0
    movel %a0@(2),%sp@-
    jsr %pc@(GETPICPIXMAP)
    moveal %sp@(4),%a0
    moveal %a0@,%a0
    moveal %a0@(2),%a1
    moveal %a1@,%a1
    moveal %a0@(6),%a0
    movew %a1@(10),%d1
    subw %a1@(6),%d1
    movew %a1@(4),%d0
    andiw #32767,%d0
    muluw %d1,%d0
    jsr %pc@(RSETHSIZE)
    moveal %sp@(4),%a0
    moveal %a0@,%a0
    moveal %a0@(6),%a0
    _HLock
    moveal %a0,%a1
    moveal %sp@(4),%a0
    moveal %a0@,%a0
    moveal %a0@(2),%a0
    movel %a0,%sp@-
    movel %a1,%sp@-
    _HLock
    movel %a0@,%sp@-
    movel %a1,%sp@-
    jsr %pc@(GETPMDATA)
    moveal %sp@+,%a0
    _HUnlock
    moveal %sp@+,%a0
    _HUnlock
    rtd #4
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 408331A8

/* PUTPICPIXPAT: PutPicPixPat(pp): write a pixpat: type, old pattern, then the RGB or the pixmap and its data */
PUTPICPIXPAT:
    movel %a2,%sp@-
    moveal %sp@(8),%a0
    _HLock
    moveal %a0@,%a2
    moveal %a2@(2),%a0
    moveal %a0@,%a0
    movew %a2@,%sp@-
    jsr %pc@(PUTPICWORD)
    movel %a2@(20),%sp@-
    jsr %pc@(PUTPICLONG)
    movel %a2@(24),%sp@-
    jsr %pc@(PUTPICLONG)
    cmpiw #2,%a2@
    jbne PUTPICPIXPAT_4E
    moveal %a2@(2),%a0
    moveal %a0@,%a0
    moveal %a0@(42),%a0
    moveal %a0@,%a0
    lea %a0@(40),%a0
    movew %a0@(6),%sp@-
    movel %a0@(2),%sp@-
    jsr %pc@(PUTPICLONG)
    jsr %pc@(PUTPICWORD)
    jbra PUTPICPIXPAT_7A
PUTPICPIXPAT_4E:        /* type 1: its pixmap, color table and packed data */
    movel %a2@(2),%sp@-
    jsr %pc@(PUTPICPIXMAP)
    moveal %a2@(6),%a0
    _HLock
    moveal %a2@(2),%a1
    moveal %a1@,%a1
    movel %a1,%sp@-
    movel %a0@,%sp@-
    movew %a1@(4),%d0
    andiw #32767,%d0
    movew %d0,%sp@-
    jsr %pc@(PUTPMDATA)
    moveal %a2@(6),%a0
    _HUnlock
PUTPICPIXPAT_7A:        /* unlock, return */
    moveal %sp@(8),%a0
    _HUnlock
    moveal %sp@+,%a2
    movel %sp@+,%sp@
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40833236

/* GETDIRECTPMDATA: GetDirectPMData: read the rows of a 16/32-bit pixmap from a picture, unpacking packType 3 (16-bit runs) or 4 (components by plane) */
GETDIRECTPMDATA:
    linkw %fp,#-20
    moveml %d3-%d7/%a2-%a4,%sp@-
    movel %sp,%fp@(-20)
    moveal %fp@(12),%a2
    moveal %fp@(8),%a0
    moveal %a0@,%a3
    moveq #8,%d6
    movew %a2@(10),%d7
    subw %a2@(6),%d7
    movew %a2@(4),%d5
    andiw #32767,%d5
    cmpw %d6,%d5
    jblt GETDIRECTPMDATA_188
    cmpiw #4,%a2@(16)
    jbgt GETDIRECTPMDATA_15C
    jbeq GETDIRECTPMDATA_70
    cmpiw #3,%a2@(16)
    jbeq GETDIRECTPMDATA_11C
    movew %d5,%d0
    muluw %d7,%d0
    lsrl #2,%d0
    movel %d0,%d7
    addl %d0,%d0
    addl %d7,%d0
    movel %a3,%sp@-
    addl %d7,%sp@
    movel %d0,%sp@-
    jsr %pc@(GETBIGPICDATA)
    moveal %a3,%a0
    moveal %a3,%a1
    addal %d7,%a1
GETDIRECTPMDATA_60:     /* 24-bit unpacked rows: pad each pixel to a long */
    clrb %a0@+
    moveb %a1@+,%a0@+
    moveb %a1@+,%a0@+
    moveb %a1@+,%a0@+
    subql #1,%d7
    jbhi GETDIRECTPMDATA_60
    jbra GETDIRECTPMDATA_192
GETDIRECTPMDATA_70:     /* packType 4: buffers for the packed and unpacked row */
    subaw %d5,%sp
    movel %sp,%fp@(-12)
    subaw %d5,%sp
    movew %d5,%d0
    lsrw #7,%d0
    addqw #2,%d0
    bclr #0,%d0
    subaw %d0,%sp
    movel %sp,%fp@(-16)
    cmpiw #4,%a2@(34)
    jbeq GETDIRECTPMDATA_AA
    movew %d5,%d1
    muluw %d7,%d1
    lsrl #2,%d1
    movew %d1,%d2
    swap %d1
    moveq #0,%d3
    moveal %a3,%a0
    jbra GETDIRECTPMDATA_A2
GETDIRECTPMDATA_A0:     /* clear the destination alpha */
    movel %d3,%a0@+
GETDIRECTPMDATA_A2:     /* count down (loop) */
    dbf %d2,GETDIRECTPMDATA_A0
    dbf %d1,GETDIRECTPMDATA_A2
GETDIRECTPMDATA_AA:     /* per row */
    addqw #4,%a3
    subaw %a2@(34),%a3
    movew %d5,%d4
    lsrw #2,%d4
    muluw %a2@(34),%d4
    jbra GETDIRECTPMDATA_116
GETDIRECTPMDATA_BA:     /* row byte count: a byte when rowBytes <= 250, else a word */
    cmpiw #250,%d5
    jbgt GETDIRECTPMDATA_C6
    jsr %pc@(GETUBYTE)
    jbra GETDIRECTPMDATA_CA
GETDIRECTPMDATA_C6:     /* word count */
    jsr %pc@(GETWORD)
GETDIRECTPMDATA_CA:     /* read the packed row, UnpackBits it */
    movel %fp@(-16),%sp@-
    movel %sp@,%fp@(-4)
    movew %d0,%sp@-
    jsr %pc@(GETPICDATA)
    movel %fp@(-12),%fp@(-8)
    pea %fp@(-4)
    pea %fp@(-8)
    movew %d4,%sp@-
    jsr @(0x1140,%za0)@(0x0)	| 40833328
    movew %a2@(34),%d3
    subqw #1,%d3
    moveal %fp@(-12),%a0
    movew %d5,%d0
    lsrw #2,%d0
    subqw #1,%d0
GETDIRECTPMDATA_FE:     /* spread the component planes into the pixels */
    moveal %a3,%a4
    addqw #1,%a3
    movew %d0,%d6
GETDIRECTPMDATA_104:    /* one component */
    moveb %a0@+,%a4@
    addqw #4,%a4
    dbf %d6,GETDIRECTPMDATA_104
    dbf %d3,GETDIRECTPMDATA_FE
    subaw %a2@(34),%a3
    addaw %d5,%a3
GETDIRECTPMDATA_116:    /* next row */
    dbf %d7,GETDIRECTPMDATA_BA
    jbra GETDIRECTPMDATA_192
GETDIRECTPMDATA_11C:    /* packType 3 (16-bit runs): a buffer */
    subaw %d5,%sp
    subaw %d5,%sp
    movel %sp,%fp@(-16)
    movel %a3,%fp@(-8)
    jbra GETDIRECTPMDATA_156
GETDIRECTPMDATA_12A:    /* row byte count */
    cmpiw #250,%d5
    jbgt GETDIRECTPMDATA_136
    jsr %pc@(GETUBYTE)
    jbra GETDIRECTPMDATA_13A
GETDIRECTPMDATA_136:    /* word count */
    jsr %pc@(GETWORD)
GETDIRECTPMDATA_13A:    /* read and UNPACKWORDS */
    movel %fp@(-16),%sp@-
    movel %sp@,%fp@(-4)
    movew %d0,%sp@-
    jsr %pc@(GETPICDATA)
    pea %fp@(-4)
    pea %fp@(-8)
    movew %d5,%sp@-
    jsr %pc@(UNPACKWORDS)
GETDIRECTPMDATA_156:    /* next row */
    dbf %d7,GETDIRECTPMDATA_12A
    jbra GETDIRECTPMDATA_192
GETDIRECTPMDATA_15C:    /* unpacked rows: read each */
    movew %d5,%d6
    muluw %d7,%d6
    jbra GETDIRECTPMDATA_17A
GETDIRECTPMDATA_162:    /* row byte count */
    cmpiw #250,%d5
    jbgt GETDIRECTPMDATA_16E
    jsr %pc@(GETUBYTE)
    jbra GETDIRECTPMDATA_172
GETDIRECTPMDATA_16E:    /* word count */
    jsr %pc@(GETWORD)
GETDIRECTPMDATA_172:    /* read */
    movel %a3,%sp@-
    movew %d0,%sp@-
    jsr %pc@(GETPICDATA)
GETDIRECTPMDATA_17A:    /* next row */
    dbf %d7,GETDIRECTPMDATA_162
    moveal %a3,%a0
GETDIRECTPMDATA_180:    /* clear the padding */
    clrb %a0@+
    subql #1,%d6
    jbhi GETDIRECTPMDATA_180
    jbra GETDIRECTPMDATA_192
GETDIRECTPMDATA_188:    /* rowBytes < 8: the whole image at once */
    muluw %d7,%d5
    movel %a3,%sp@-
    movel %d5,%sp@-
    jsr %pc@(GETBIGPICDATA)
GETDIRECTPMDATA_192:    /* return */
    moveal %fp@(8),%a0
    moveal %fp@(-20),%sp
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #8
    .long   0x00000000, 0x00000000, 0x00000000	| 408333E4

/* PUTDIRECTPMDATA: PutDirectPMData: write the rows of a 16/32-bit pixmap to a picture, packed (packType 3 or 4) when that is smaller */
PUTDIRECTPMDATA:
    linkw %fp,#-20
    moveml %d3-%d7/%a2-%a4,%sp@-
    movel %sp,%fp@(-20)
    moveal %fp@(14),%a2
    moveal %fp@(10),%a3
    movew %fp@(8),%d4
    moveq #8,%d6
    movew %a2@(10),%d7
    subw %a2@(6),%d7
    movel %sp,%d1
    andib #0xfc,%d1
    moveal %d1,%sp
    movew %a2@(4),%d5
    andiw #32767,%d5
    cmpw %d6,%d5
    jblt PUTDIRECTPMDATA_182
    cmpiw #2,%a2@(16)
    jblt PUTDIRECTPMDATA_182
    jbeq PUTDIRECTPMDATA_140
    cmpiw #3,%a2@(16)
    jbeq PUTDIRECTPMDATA_EA
    subaw %d5,%sp
    movel %sp,%fp@(-12)
    subaw %d5,%sp
    movew %d5,%d0
    lsrw #8,%d0
    addqw #1,%d0
    addl %d0,%d0
    subaw %d0,%sp
    movel %sp,%fp@(-16)
    addqw #4,%a3
    subaw %a2@(34),%a3
    jbra PUTDIRECTPMDATA_E2
PUTDIRECTPMDATA_6E:     /* packType 4: gather each component into planes */
    movew %a2@(34),%d3
    subqw #1,%d3
    moveal %fp@(-12),%a0
    movew %d5,%d0
    lsrw #2,%d0
    subqw #1,%d0
PUTDIRECTPMDATA_7E:     /* one component */
    moveal %a3,%a4
    addqw #1,%a3
    movew %d0,%d6
PUTDIRECTPMDATA_84:     /* its bytes */
    moveb %a4@,%a0@+
    addqw #4,%a4
    dbf %d6,PUTDIRECTPMDATA_84
    dbf %d3,PUTDIRECTPMDATA_7E
    subaw %a2@(34),%a3
    movel %fp@(-12),%fp@(-4)
    moveal %fp@(-16),%a0
    movel %a0,%fp@(-8)
    pea %fp@(-4)
    pea %fp@(-8)
    addqw #1,%d0
    muluw %a2@(34),%d0
    movew %d0,%sp@-
    jsr @(0x113c,%za0)@(0)	| 408334A2
    movel %fp@(-8),%d6
    moveal %fp@(-16),%a0
    subl %a0,%d6
    cmpiw #250,%d5
    jbgt PUTDIRECTPMDATA_D0
    moveb %d6,%sp@-
    jsr %pc@(PUTPICBYTE)
    jbra PUTDIRECTPMDATA_D6
PUTDIRECTPMDATA_D0:     /* count as a word */
    movew %d6,%sp@-
    jsr %pc@(PUTPICWORD)
PUTDIRECTPMDATA_D6:     /* write the packed row */
    movel %fp@(-16),%sp@-
    movew %d6,%sp@-
    jsr %pc@(PUTPICDATA)
    addaw %d4,%a3
PUTDIRECTPMDATA_E2:     /* next row */
    dbf %d7,PUTDIRECTPMDATA_6E
    jbra PUTDIRECTPMDATA_186
PUTDIRECTPMDATA_EA:     /* packType 3: buffer */
    subaw %d5,%sp
    subaw %d5,%sp
    movel %sp,%fp@(-16)
    jbra PUTDIRECTPMDATA_138
PUTDIRECTPMDATA_F4:     /* PACKWORDS the row */
    movel %a3,%fp@(-4)
    moveal %fp@(-16),%a0
    movel %a0,%fp@(-8)
    pea %fp@(-4)
    pea %fp@(-8)
    movew %d5,%sp@-
    jsr %pc@(PACKWORDS)
    movel %fp@(-8),%d6
    moveal %fp@(-16),%a0
    subl %a0,%d6
    cmpiw #250,%d5
    jbgt PUTDIRECTPMDATA_126
    moveb %d6,%sp@-
    jsr %pc@(PUTPICBYTE)
    jbra PUTDIRECTPMDATA_12C
PUTDIRECTPMDATA_126:    /* count as a word */
    movew %d6,%sp@-
    jsr %pc@(PUTPICWORD)
PUTDIRECTPMDATA_12C:    /* write the packed row */
    movel %fp@(-16),%sp@-
    movew %d6,%sp@-
    jsr %pc@(PUTPICDATA)
    addaw %d4,%a3
PUTDIRECTPMDATA_138:    /* next row */
    dbf %d7,PUTDIRECTPMDATA_F4
    braw PUTDIRECTPMDATA_186
PUTDIRECTPMDATA_140:    /* unpacked 24-bit (packType 2): drop the alpha byte */
    subaw %d5,%sp
    movel %sp,%fp@(-12)
    movew %d5,%d6
    lsrw #2,%d6
    subqw #1,%d6
    jbra PUTDIRECTPMDATA_172
PUTDIRECTPMDATA_14E:    /* next row */
    moveal %fp@(-12),%a0
    moveal %a3,%a4
    movew %d6,%d0
PUTDIRECTPMDATA_156:    /* three bytes per pixel; write the row */
    addqw #1,%a4
    moveb %a4@+,%a0@+
    moveb %a4@+,%a0@+
    moveb %a4@+,%a0@+
    dbf %d0,PUTDIRECTPMDATA_156
    subal %fp@(-12),%a0
    movel %fp@(-12),%sp@-
    movew %a0,%sp@-
    jsr %pc@(PUTPICDATA)
    addaw %d4,%a3
PUTDIRECTPMDATA_172:    /* next row */
    dbf %d7,PUTDIRECTPMDATA_14E
    jbra PUTDIRECTPMDATA_186
PUTDIRECTPMDATA_178:    /* unpacked rows as they are */
    movel %a3,%sp@-
    movew %d5,%sp@-
    jsr %pc@(PUTPICDATA)
    addaw %d4,%a3
PUTDIRECTPMDATA_182:    /* next row */
    dbf %d7,PUTDIRECTPMDATA_178
PUTDIRECTPMDATA_186:    /* return */
    moveal %fp@(-20),%sp
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #10
    .long   0x00000000, 0x00000000, 0x00000000	| 40833584

/* GETBIGPICDATA: GetBigPicData(ptr, size): GETPICDATA in 16K pieces for sizes above 32K */
GETBIGPICDATA:
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a3
    moveal %sp@(16),%a4
    movel %a4,%d7
    moveq #14,%d0
    lsrl %d0,%d7
    jbeq GETBIGPICDATA_2A
GETBIGPICDATA_14:       /* 16K pieces */
    movel %a3,%sp@-
    movew #16384,%sp@-
    jsr %pc@(GETPICDATA)
    lea %a3@(16384),%a3
    subaw #16384,%a4
    subql #1,%d7
    jbne GETBIGPICDATA_14
GETBIGPICDATA_2A:       /* the rest */
    movel %a3,%sp@-
    movew %a4,%sp@-
    jsr %pc@(GETPICDATA)
    moveml %sp@+,%d7/%a3-%a4
    rtd #8
    .short  0x0000, 0x0000, 0x0000	| 408335CA

/* PUTBIGPICDATA: PutBigPicData(ptr, size): PUTPICDATA in 16K pieces */
PUTBIGPICDATA:
    moveml %d7/%a3-%a4,%sp@-
    moveal %sp@(20),%a3
    moveal %sp@(16),%a4
    movel %a4,%d7
    moveq #14,%d0
    lsrl %d0,%d7
    jbeq PUTBIGPICDATA_2A
PUTBIGPICDATA_14:       /* 16K pieces */
    movel %a3,%sp@-
    movew #16384,%sp@-
    jsr %pc@(PUTPICDATA)
    lea %a3@(16384),%a3
    subaw #16384,%a4
    subql #1,%d7
    jbne PUTBIGPICDATA_14
PUTBIGPICDATA_2A:       /* the rest */
    movel %a3,%sp@-
    movew %a4,%sp@-
    jsr %pc@(PUTPICDATA)
    moveml %sp@+,%d7/%a2-%a4
    rtd #8
    .short  0x0000, 0x0000, 0x0000	| 4083360A

/* GETPMDATA: GetPMData: read the rows of an indexed pixmap from a picture: rowBytes < 8 unpacked, else PackBits runs with a byte or word count */
GETPMDATA:
    linkw %fp,#-16
    moveml %d4-%d6/%a2-%a3,%sp@-
    movel %sp,%fp@(-16)
    moveal %fp@(12),%a2
    moveal %fp@(8),%a0
    moveal %a0@,%a3
    moveq #8,%d6
    movew %a2@(10),%d4
    subw %a2@(6),%d4
    movew %a2@(4),%d5
    andiw #32767,%d5
    cmpw %d6,%d5
    jblt GETPMDATA_96
    tstw %a2@(4)
    jbpl GETPMDATA_4C
    cmpiw #16,%a2@(30)
    jbne GETPMDATA_4C
    cmpiw #1,%a2@(16)
    jbeq GETPMDATA_96
    moveml %sp@+,%d4-%d6/%a2-%a3
    unlk %fp
    jmp %pc@(GETDIRECTPMDATA)
GETPMDATA_4C:           /* packed rows: a buffer */
    movel %sp,%d1
    andib #0xfc,%d1
    moveal %d1,%sp
    subaw %d5,%sp
    subaw %d5,%sp
    movel %sp,%fp@(-12)
    movel %a3,%fp@(-8)
    jbra GETPMDATA_90
GETPMDATA_62:           /* row byte count */
    cmpiw #250,%d5
    jbgt GETPMDATA_6E
    jsr %pc@(GETUBYTE)
    jbra GETPMDATA_72
GETPMDATA_6E:           /* word count */
    jsr %pc@(GETWORD)
GETPMDATA_72:           /* read and UnpackBits */
    movel %fp@(-12),%sp@-
    movel %sp@,%fp@(-4)
    movew %d0,%sp@-
    jsr %pc@(GETPICDATA)
    pea %fp@(-4)
    pea %fp@(-8)
    movew %d5,%sp@-
    jsr @(0x1140,%za0)@(0x0)	| 4083369A
GETPMDATA_90:           /* next row */
    dbf %d4,GETPMDATA_62
    jbra GETPMDATA_A0
GETPMDATA_96:           /* rowBytes < 8: all at once */
    muluw %d4,%d5
    movel %a3,%sp@-
    movel %d5,%sp@-
    jsr %pc@(GETBIGPICDATA)
GETPMDATA_A0:           /* return */
    moveal %fp@(8),%a0
    moveal %fp@(-16),%sp
    moveml %sp@+,%d4-%d6/%a2-%a3
    unlk %fp
    rtd #8
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408336C2

/* PUTPMDATA: PutPMData: write the rows of an indexed pixmap, PackBits-packed when rowBytes >= 8 */
PUTPMDATA:
    linkw %fp,#-16
    moveml %d4-%d7/%a2-%a3,%sp@-
    movel %sp,%fp@(-16)
    moveal %fp@(14),%a2
    moveal %fp@(10),%a3
    movew %fp@(8),%d4
    moveq #8,%d6
    movew %a2@(10),%d7
    subw %a2@(6),%d7
    movew %a2@(4),%d5
    andiw #32767,%d5
    cmpw %d6,%d5
    jblt PUTPMDATA_96
    movel %sp,%d1
    andib #0xfc,%d1
    moveal %d1,%sp
    subaw %d5,%sp
    subaw %d5,%sp
    movel %sp,%fp@(-12)
    jbra PUTPMDATA_86
PUTPMDATA_40:           /* PackBits the row */
    movel %a3,%fp@(-4)
    moveal %fp@(-12),%a0
    movel %a0,%fp@(-8)
    pea %fp@(-4)
    pea %fp@(-8)
    movew %d5,%sp@-
    jsr @(0x113c,%za0)@(0)	| 40833726
    movel %fp@(-8),%d6
    moveal %fp@(-12),%a0
    subl %a0,%d6
    cmpiw #250,%d5
    jbgt PUTPMDATA_74
    moveb %d6,%sp@-
    jsr %pc@(PUTPICBYTE)
    jbra PUTPMDATA_7A
PUTPMDATA_74:           /* count as a word */
    movew %d6,%sp@-
    jsr %pc@(PUTPICWORD)
PUTPMDATA_7A:           /* write it */
    movel %fp@(-12),%sp@-
    movew %d6,%sp@-
    jsr %pc@(PUTPICDATA)
    addaw %d4,%a3
PUTPMDATA_86:           /* next row */
    dbf %d7,PUTPMDATA_40
    jbra PUTPMDATA_9A
PUTPMDATA_8C:           /* unpacked rows */
    movel %a3,%sp@-
    movew %d5,%sp@-
    jsr %pc@(PUTPICDATA)
    addaw %d4,%a3
PUTPMDATA_96:           /* next row */
    dbf %d7,PUTPMDATA_8C
PUTPMDATA_9A:           /* return */
    moveal %fp@(-16),%sp
    moveml %sp@+,%d4-%d7/%a2-%a3
    unlk %fp
    rtd #10
    .long   0x00000000, 0x00000000	| 40833778

/* CHECKPIC: check picture recording state. */
trap_CHECKPIC:
CHECKPIC:
    moveml %d6-%d7,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a3
    tstl %a3@(92)
    jbeq CHECKPIC_218
    cmpiw #-1,%a3@(66)
    jblt CHECKPIC_218
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    cmpiw #1,%a4@(98)
    jbeq CHECKPIC_C6
    tstw %a3@(6)
    jbpl CHECKPIC_B8
    moveal %a3@(8),%a0
    moveal %a0@,%a0
    movel %a0@,%d7
    movew %a0@(4),%d6
    cmpl %a4@(116),%d7
    jbne CHECKPIC_4A
    cmpw %a4@(120),%d6
    jbeq CHECKPIC_6A
CHECKPIC_4A:            /* (CheckPic: before each drawing opcode, record what changed in the port) the op color: OpColor (31) */
    moveq #31,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %d7,%sp@-
    jsr %pc@(PUTPICLONG)
    movew %d6,%sp@-
    jsr %pc@(PUTPICWORD)
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %d7,%a4@(116)
    movew %d6,%a4@(120)
CHECKPIC_6A:            /* the hilite color changed? (version 2) */
    moveal %a3@(8),%a0
    moveal %a0@,%a0
    movel %a0@(6),%d7
    movew %a0@(10),%d6
    cmpl %a4@(122),%d7
    jbne CHECKPIC_84
    cmpw %a4@(126),%d6
    jbeq CHECKPIC_B8
CHECKPIC_84:            /* back to the default: DefHilite (30), else HiliteColor (29) */
    cmpl HiliteRGB,%d7
    jbne CHECKPIC_98
    cmpw 0xda4,%d6
    jbne CHECKPIC_98
    moveq #30,%d0
    jsr %pc@(trap_DPUTPICOP)
    jbra CHECKPIC_AA
CHECKPIC_98:            /* HiliteColor */
    moveq #29,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %d7,%sp@-
    jsr %pc@(PUTPICLONG)
    movew %d6,%sp@-
    jsr %pc@(PUTPICWORD)
CHECKPIC_AA:            /* remember it */
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %d7,%a4@(122)
    movew %d6,%a4@(126)
CHECKPIC_B8:            /* hilite mode on: HiliteMode (28) */
    btst #7,HiliteMode
    jbne CHECKPIC_C6
    moveq #28,%d0
    jsr %pc@(trap_DPUTPICOP)
CHECKPIC_C6:            /* the foreground color: old FgColor (14) or RGBFgCol (26) */
    movel %a3@(80),%d7
    tstw %a3@(6)
    jbpl CHECKPIC_F0
    movel %a3@(36),%d7
    movew %a3@(40),%d6
    cmpiw #1,%a4@(98)
    jbne CHECKPIC_10E
    movew %d6,%sp@-
    movel %d7,%sp@-
    moveal %sp,%a1
    jbsr RGB2OLD
    movel %d0,%d7
    addqw #6,%sp
CHECKPIC_F0:            /* FgColor */
    cmpl %a4@(90),%d7
    jbeq CHECKPIC_13A
    moveq #14,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %d7,%sp@-
    jsr %pc@(PUTPICLONG)
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %d7,%a4@(90)
    jbra CHECKPIC_13A
CHECKPIC_10E:           /* RGB foreground changed? */
    cmpl %a4@(100),%d7
    jbne CHECKPIC_11A
    cmpw %a4@(104),%d6
    jbeq CHECKPIC_13A
CHECKPIC_11A:           /* RGBFgCol */
    moveq #26,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %d7,%sp@-
    jsr %pc@(PUTPICLONG)
    movew %d6,%sp@-
    jsr %pc@(PUTPICWORD)
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %d7,%a4@(100)
    movew %d6,%a4@(104)
CHECKPIC_13A:           /* the background color: BkColor (15) or RGBBkCol (27) */
    movel %a3@(84),%d7
    tstw %a3@(6)
    jbpl CHECKPIC_164
    movel %a3@(42),%d7
    movew %a3@(46),%d6
    cmpiw #1,%a4@(98)
    jbne CHECKPIC_182
    movew %d6,%sp@-
    movel %d7,%sp@-
    moveal %sp,%a1
    jbsr RGB2OLD
    movel %d0,%d7
    addqw #6,%sp
CHECKPIC_164:           /* BkColor */
    cmpl %a4@(94),%d7
    jbeq CHECKPIC_1AE
    moveq #15,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %d7,%sp@-
    jsr %pc@(PUTPICLONG)
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %d7,%a4@(94)
    jbra CHECKPIC_1AE
CHECKPIC_182:           /* RGB background changed? */
    cmpl %a4@(106),%d7
    jbne CHECKPIC_18E
    cmpw %a4@(110),%d6
    jbeq CHECKPIC_1AE
CHECKPIC_18E:           /* RGBBkCol */
    moveq #27,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %d7,%sp@-
    jsr %pc@(PUTPICLONG)
    movew %d6,%sp@-
    jsr %pc@(PUTPICWORD)
    moveal %a3@(92),%a4
    moveal %a4@,%a4
    movel %d7,%a4@(106)
    movew %d6,%a4@(110)
CHECKPIC_1AE:           /* the origin moved? Origin opcode */
    movel %a3@(16),%d0
    cmpl %a4@(86),%d0
    jbeq CHECKPIC_1E4
    movew %a3@(18),%d7
    subw %a4@(88),%d7
    addw %d7,%a4@(88)
    swap %d7
    movew %a3@(16),%d7
    subw %a4@(86),%d7
    addw %d7,%a4@(86)
    moveq #12,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %d7,%sp@-
    jsr %pc@(PUTPICLONG)
    moveal %a3@(92),%a4
    moveal %a4@,%a4
CHECKPIC_1E4:           /* the clip region changed? ClipRgn opcode */
    clrb %sp@-
    movel %a3@(28),%sp@-
    movel %a4@(12),%sp@-
    jsr @(0x118c,%za0)@(0)	| 4083396E
    tstb %sp@+
    jbne CHECKPIC_214
    movel %a3@(28),%sp@-
    movel %a4@(12),%sp@-
    moveq #1,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %a3@(28),%sp@-
    jsr %pc@(PUTPICRGN)
    jsr @(0x1170,%za0)@(0x0)	| 4083398E
CHECKPIC_214:           /* a picture is open: true */
    moveal %a5@,%a4
    moveq #1,%d0
CHECKPIC_218:           /* restore registers, return */
    moveml %sp@+,%d6-%d7
    rts
    .short  0x0000	| 4083399E

/* SCALEPT: _ScalePt. */
trap_ScalePt:
SCALEPT:
    linkw %fp,#0
    moveml %d0-%d3/%a0-%a2,%sp@-
    moveal %fp@(16),%a0
    moveal %fp@(12),%a1
    moveal %fp@(8),%a2
    jbsr SCALEPT_28
    addqw #2,%a0
    addqw #2,%a1
    addqw #2,%a2
    jbsr SCALEPT_28
    moveml %sp@+,%d0-%d3/%a0-%a2
    unlk %fp
    rtd #12

SCALEPT_28:             /* scale one coordinate by the ratio of the rectangles' sizes (rounded, at least 1) */
    movew %a1@(4),%d3
    subw %a1@,%d3
    movew %a2@(4),%d2
    subw %a2@,%d2
    cmpw %d2,%d3
    jbeq SCALEPT_52
    movew %d3,%d1
    lsrw #1,%d1
    extl %d1
    movew %a0@,%d0
    jbgt SCALEPT_46
    clrw %a0@
    rts
SCALEPT_46:             /* scale */
    muluw %d2,%d0
    addl %d1,%d0
    divuw %d3,%d0
    jbne SCALEPT_50
    moveq #1,%d0
SCALEPT_50:             /* store */
    movew %d0,%a0@
SCALEPT_52:             /* return */
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 408339F4

/* MAPPT: _MapPt. */
trap_MapPt:
MAPPT:
    linkw %fp,#0
    moveml %d0-%d5/%a0-%a2,%sp@-
    moveal %fp@(16),%a0
    moveal %fp@(12),%a1
    moveal %fp@(8),%a2
    jbsr MAPPT_28
    addqw #2,%a0
    addqw #2,%a1
    addqw #2,%a2
    jbsr MAPPT_28
    moveml %sp@+,%d0-%d5/%a0-%a2
    unlk %fp
    rtd #12

MAPPT_28:               /* map one coordinate from the source to the destination rectangle (rounded) */
    movew %a1@,%d2
    movew %a1@(4),%d3
    subw %d2,%d3
    movew %a2@,%d4
    movew %a2@(4),%d5
    subw %d4,%d5
    movew %a0@,%d0
    subw %d2,%d0
    cmpw %d3,%d5
    jbeq MAPPT_58
    movew %d3,%d1
    lsrw #1,%d1
    extl %d1
    movew %d0,%d2
    jbpl MAPPT_4C
    negw %d0
MAPPT_4C:               /* scale */
    muluw %d5,%d0
    addl %d1,%d0
    divuw %d3,%d0
    tstw %d2
    jbpl MAPPT_58
    negw %d0
MAPPT_58:               /* offset, store */
    addw %d4,%d0
    movew %d0,%a0@
    rts
    .short  0x0000	| 40833A5E

/* MAPFIXPT: MapFixPt(pt, src, dst): MapPt for a fixed-point point */
MAPFIXPT:
    linkw %fp,#0
    moveml %d0-%a2,%sp@-
    moveal %fp@(16),%a0
    moveal %fp@(12),%a1
    moveal %fp@(8),%a2
    jbsr MAPFIXPT_28
    addqw #4,%a0
    addqw #2,%a1
    addqw #2,%a2
    jbsr MAPFIXPT_28
    moveml %sp@+,%d0-%a2
    unlk %fp
    rtd #12

MAPFIXPT_28:            /* the same in fixed point */
    movel %a1@,%d2
    clrw %d2
    movel %a1@(4),%d3
    clrw %d3
    subl %d2,%d3
    movel %a2@,%d4
    clrw %d4
    movel %a2@(4),%d5
    clrw %d5
    subl %d4,%d5
    movel %a0@,%d0
    subl %d2,%d0
    cmpl %d3,%d5
    jbeq MAPFIXPT_50
    mulsl %d5,%d6,%d0
    divsl %d3,%d6,%d0
MAPFIXPT_50:            /* offset, store */
    addl %d4,%d0
    movel %d0,%a0@
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40833AB6

/* MAPRECT: _MapRect. */
trap_MapRect:
MAPRECT:
    movel %sp@(12),%sp@-
    movel %sp@(12),%sp@-
    movel %sp@(12),%sp@-
    jbsr trap_MapPt
    addql #4,%sp@(12)
    jbra trap_MapPt
    .long   0x00000000, 0x00000000	| 40833AD8

/* MAPRATIO: MapRatio: scale a numerator/denominator pair by the ratio of two rectangles */
MAPRATIO:
    linkw %fp,#0
    moveml %d0-%d1/%a0-%a2,%sp@-
    moveal %fp@(16),%a0
    moveal %fp@(12),%a1
    moveal %fp@(8),%a2
    movew %a2@(6),%d0
    subw %a2@(2),%d0
    movew %a0@(2),%d1
    muluw %d0,%d1
    divuw %a1@(2),%d1
    movew %d1,%a0@(2)
    movew %d0,%a1@(2)
    movew %a2@(4),%d0
    subw %a2@,%d0
    movew %a0@,%d1
    muluw %d0,%d1
    divuw %a1@,%d1
    movew %d1,%a0@
    movew %d0,%a1@
    moveml %sp@+,%d0-%d1/%a0-%a2
    unlk %fp
    rtd #12
    .long   0x00000000, 0x00000000	| 40833B28

/* STDPOLY: StdPoly: the polygon bottleneck. */
trap_StdPoly:
STDPOLY:
    linkw %fp,#-8
    moveml %d5-%d7/%a2-%a4,%sp@-
    moveq #0,%d7
    moveb %fp@(12),%d7
    jsr @(0x1a3c,%za0)@(0)	| 40833B3E
    jble STDPOLY_2C
    moveb %d7,%sp@-
    jsr %pc@(PUTPICVERB)
    moveq #112,%d0
    addw %d7,%d0
    jsr %pc@(trap_DPUTPICOP)
    movel %fp@(8),%sp@-
    jsr %pc@(PUTPICRGN)
STDPOLY_2C:             /* draw on each screen */
    pea %pc@(STDPOLY_72)
    pea %pc@(STDPOLY_44)
    jsr @(0x1aa0,%za0)@(0)	| 40833B64
    moveml %sp@+,%d5-%d7/%a2-%a4
    unlk %fp
    rtd #6
STDPOLY_44:             /* rectangle proc: the polygon's box */
    movel %sp@+,%d0
    moveal %sp@+,%a1
    movel %d0,%sp@-
    moveal %fp@(8),%a0
    moveal %a0@,%a0
    lea %a0@(2),%a0
    movel %a0@+,%a1@+
    movel %a0@,%a1@
    pea %a1@(-4)
    movel %a3@(52),%d0
    negw %d0
    movew %d0,%sp@-
    swap %d0
    negw %d0
    movew %d0,%sp@-
    jsr @(0x10a4,%za0)@(0)	| 40833B9A
    rts
STDPOLY_72:             /* draw proc: frame (FRPOLY) or fill through the edge vectors */
    moveal %fp@(8),%a2
    tstb %d7
    jbne STDPOLY_82
    movel %a2,%sp@-
    jsr %pc@(FRPOLY)
    jbra STDPOLY_B8
STDPOLY_82:             /* clip to the visRgn and clipRgn, paint the polygon (PAINTVECTOR) */
    moveal %a2@,%a0
    pea %a0@(2)
    moveal %a3@(24),%a0
    moveal %a0@,%a0
    pea %a0@(2)
    moveal %a3@(28),%a0
    moveal %a0@,%a0
    pea %a0@(2)
    movew #3,%sp@-
    pea %fp@(-8)
    jsr @(0x1a84,%za0)@(0)	| 40833BD4
    jbeq STDPOLY_B8
    movel %a2,%sp@-
    jsr @(0x1a60,%za0)@(0)	| 40833BDE
    jsr %pc@(DRAWPOLY)
STDPOLY_B8:             /* return */
    rts
    .short  0x0000, 0x0000, 0x0000	| 40833BEA

/* FRAMEPOLY: _FramePoly: frame (outline with the pen) the polygon. */
trap_FramePoly:
FRAMEPOLY:
    moveq #0,%d0
    jbra CALLPOLY

/* PAINTPOLY: _PaintPoly: paint (fill with the pen pattern) the polygon. */
trap_PaintPoly:
PAINTPOLY:
    moveq #1,%d0
    jbra CALLPOLY

/* ERASEPOLY: _ErasePoly: erase (fill with the background) the polygon. */
trap_ErasePoly:
ERASEPOLY:
    moveq #2,%d0
    jbra CALLPOLY

/* INVERTPOLY: _InvertPoly: invert the polygon. */
trap_InvertPoly:
INVERTPOLY:
    moveq #3,%d0
    jbra CALLPOLY

/* FILLPOLY: _FillPoly: fill with a pattern the polygon. */
trap_FillPoly:
FILLPOLY:
    moveq #0,%d0
    jbra FILLCPOLY_2

/* FILLCPOLY: _FillCpoly: fill with a pattern the polygon with a pixel pattern. */
trap_FillCPoly:
FILLCPOLY:
    moveq #1,%d0
FILLCPOLY_2:            /* the pixpat, then CALLPOLY with verb 4 */
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    movel %a0,%sp@-
    movel %a1,%sp@-
    jsr @(0x1a8c,%za0)@(0)	| 40833C0E
    moveq #4,%d0

/* CALLPOLY: call the port's poly bottleneck (grafProcs) or the standard one. */
CALLPOLY:
    moveal %sp@+,%a0
    moveal %sp@+,%a1
    moveb %d0,%sp@-
    movel %a1,%sp@-
    movel %a0,%sp@-
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(104),%d0
    moveal 0x1114,%a0
    jbeq CALLPOLY_1E
    moveal %d0,%a0
    moveal %a0@(24),%a0
CALLPOLY_1E:            /* through the port's polyProc or StdPoly */
    jmp %a0@
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40833C36

/* OPENPOLY: _OpenPoly. */
trap_OpenPoly:
OPENPOLY:
    jsr @(0x1058,%za0)@(0x0)	| 40833C40
    clrl %sp@-
    movew #138,%sp@-
    jsr %pc@(NEWHANDLE)
    moveal %sp@+,%a1
    movel %a1,%sp@(4)
    moveal %a5@,%a0
    movel %a1,%a0@(-162)
    movew #138,%a0@(-164)
    moveal %a0@,%a0
    moveq #1,%d0
    movel %d0,%a0@(100)
    moveal %a1@,%a1
    movew #10,%a1@+
    clrl %a1@+
    clrl %a1@+
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40833C76

/* CLOSEPOLY: _ClosePoly. */
trap_ClosePgon:
CLOSEPOLY:
    moveml %d3-%d7/%a4,%sp@-
    moveal %a5@,%a4
    moveal %a4@,%a0
    clrl %a0@(100)
    moveal %a4@(-162),%a4
    moveal %a4@,%a0
    movew %a0@+,%d7
    clrl %a0@+
    clrl %a0@+
    movew %d7,%d6
    subiw #10,%d6
    lsrw #2,%d6
    jbeq CLOSEPOLY_5C
    movew %a0@+,%d1
    movew %d1,%d2
    movew %a0@+,%d3
    movew %d3,%d4
    subqw #1,%d6
    jbra CLOSEPOLY_4A
CLOSEPOLY_2E:           /* the bounding box of the points */
    movew %a0@+,%d0
    cmpw %d1,%d0
    jbge CLOSEPOLY_36
    movew %d0,%d1
CLOSEPOLY_36:           /* right */
    cmpw %d2,%d0
    jble CLOSEPOLY_3C
    movew %d0,%d2
CLOSEPOLY_3C:           /* top */
    movew %a0@+,%d0
    cmpw %d3,%d0
    jbge CLOSEPOLY_44
    movew %d0,%d3
CLOSEPOLY_44:           /* bottom */
    cmpw %d4,%d0
    jble CLOSEPOLY_4A
    movew %d0,%d4
CLOSEPOLY_4A:           /* next point; store polyBBox */
    dbf %d6,CLOSEPOLY_2E
    moveal %a4@,%a0
    lea %a0@(2),%a0
    movew %d1,%a0@+
    movew %d3,%a0@+
    movew %d2,%a0@+
    movew %d4,%a0@+
CLOSEPOLY_5C:           /* trim the handle, show the pen */
    movel %a4,%sp@-
    movew %d7,%sp@-
    jsr %pc@(SETHSIZE)
    jsr @(0x105c,%za0)@(0)	| 40833CE4
    moveml %sp@+,%d3-%d7/%a4
    rts

/* KILLPOLY: _KillPoly. */
trap_KillPoly:
KILLPOLY:
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    _DisposHandle
    jmp %a1@
    .long   0x00000000, 0x00000000	| 40833CF8

/* OFFSETPOLY: _OffsetPoly. */
trap_OffsetPoly:
OFFSETPOLY:
    moveal %sp@+,%a0
    movew %sp@+,%d0
    movew %sp@+,%d1
    moveal %sp@+,%a1
    moveal %a1@,%a1
    movew %a1@+,%d2
    subqw #2,%d2
    lsrw #2,%d2
    subqw #1,%d2
OFFSETPOLY_12:          /* offset every point */
    addw %d0,%a1@+
    addw %d1,%a1@+
    dbf %d2,OFFSETPOLY_12
    jmp %a0@
    .long   0x00000000	| 40833D1C

/* MAPPOLY: _MapPoly. */
trap_MapPoly:
MAPPOLY:
    linkw %fp,#0
    moveml %d7/%a2-%a4,%sp@-
    moveal %fp@(12),%a2
    moveal %fp@(8),%a3
    movel %a2@,%d0
    cmpl %a3@,%d0
    jbne MAPPOLY_20
    movel %a2@(4),%d0
    cmpl %a3@(4),%d0
    jbeq MAPPOLY_52
MAPPOLY_20:             /* map the box, then each point */
    moveal %fp@(16),%a4
    moveal %a4@,%a4
    pea %a4@(2)
    movel %a2,%sp@-
    movel %a3,%sp@-
    jsr @(0x11e8,%za0)@(0)	| 40833D4E
    moveq #10,%d0
    movew %a4@,%d7
    subw %d0,%d7
    lsrw #2,%d7
    addaw %d0,%a4
    jbra MAPPOLY_4E
MAPPOLY_40:             /* MapPt */
    movel %a4,%sp@-
    movel %a2,%sp@-
    movel %a3,%sp@-
    jsr @(0x11e4,%za0)@(0)	| 40833D66
    addqw #4,%a4
MAPPOLY_4E:             /* next point */
    dbf %d7,MAPPOLY_40
MAPPOLY_52:             /* restore registers, return */
    moveml %sp@+,%d7/%a2-%a4
    unlk %fp
    rtd #12
    .long   0x00000000	| 40833D7C

/* FRPOLY: FrPoly(poly): frame a polygon: a line to each point */
FRPOLY:
    linkw %fp,#0
    moveml %d6-%d7/%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %a4@,%a0
    movew %a0@,%d7
    subiw #10,%d7
    lsrw #2,%d7
    jbeq FRPOLY_42
    movel %a0@(10),%sp@-
    jsr @(0x104c,%za0)@(0)	| 40833D9C
    moveq #14,%d6
    subqw #1,%d7
    jbra FRPOLY_3E
FRPOLY_28:              /* LineTo each point (hilite mode kept between lines) */
    moveb HiliteMode,%sp@-
    moveal %a4@,%a0
    movel %a0@(0x0,%d6:w),%sp@-
    addqw #4,%d6
    jsr @(0x1a40,%za0)@(0)	| 40833DB4
    moveb %sp@+,HiliteMode
FRPOLY_3E:              /* next point */
    dbf %d7,FRPOLY_28
FRPOLY_42:              /* restore registers, return */
    moveml %sp@+,%d6-%d7/%a4
    bset #7,HiliteMode
    unlk %fp
    rtd #4
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40833DD2
/* SORTVECTORS: SortVectors(count, vectors) (XDRAWPOLY is the same address): quicksort the
   polygon's 8-byte edge records by their first point (v, then h) */
XDRAWPOLY:
SORTVECTORS:
    linkw %fp,#0
    moveml %d3-%d4/%a2-%a4,%sp@-
    moveal %fp@(10),%a3
    movew %a3,%d3
    andiw #7,%d3
    moveq #0,%d0
    movew %fp@(8),%d0
    jble XDRAWPOLY_96
    lsll #3,%d0
    moveal %a3,%a4
    addal %d0,%a4
    subql #8,%a4
    movel %sp,%d4
    moveml %a3-%a4,%sp@-
XDRAWPOLY_28:           /* restore registers */
    moveml %sp@+,%a3-%a4
XDRAWPOLY_2C:           /* quicksort: the middle record as pivot */
    moveal %a3,%a1
    moveal %a4,%a2
    movel %a3,%d0
    addl %a4,%d0
    roxrl #1,%d0
    andiw #-8,%d0
    orw %d3,%d0
    moveal %d0,%a0
    movew %a0@(2),%d1
    movew %a0@,%d2
    jbra XDRAWPOLY_48
XDRAWPOLY_46:           /* next */
    addql #8,%a1
XDRAWPOLY_48:           /* scan up */
    cmpw %a1@,%d2
    jbgt XDRAWPOLY_46
    jblt XDRAWPOLY_58
    cmpw %a1@(2),%d1
    jbgt XDRAWPOLY_46
    jbra XDRAWPOLY_58
XDRAWPOLY_56:           /* next */
    subql #8,%a2
XDRAWPOLY_58:           /* scan down */
    cmpw %a2@,%d2
    jblt XDRAWPOLY_56
    jbgt XDRAWPOLY_64
    cmpw %a2@(2),%d1
    jblt XDRAWPOLY_56
XDRAWPOLY_64:           /* swap the two 8-byte records */
    cmpal %a2,%a1
    jbgt XDRAWPOLY_80
    movel %a1@,%d0
    movel %a2@,%a1@
    movel %d0,%a2@
    movel %a1@(4),%d0
    movel %a2@(4),%a1@(4)
    movel %d0,%a2@(4)
    addql #8,%a1
    subql #8,%a2
XDRAWPOLY_80:           /* crossed? push the larger part */
    cmpal %a2,%a1
    jbls XDRAWPOLY_48
    cmpal %a4,%a1
    jbcc XDRAWPOLY_8C
    moveml %a1/%a4,%sp@-
XDRAWPOLY_8C:           /* next part */
    moveal %a2,%a4
    cmpal %a4,%a3
    jbcs XDRAWPOLY_2C
    cmpal %d4,%sp
    jbne XDRAWPOLY_28
XDRAWPOLY_96:           /* restore registers, return */
    moveml %sp@+,%d3-%d4/%a2-%a4
    unlk %fp
    rtd #6
/* PAINTVECTOR: PaintVector: scan-convert the sorted polygon edges into slabs and draw them row by row */
PAINTVECTOR:
    linkw %fp,#-324
    moveml %d3-%d7/%a2-%a4,%sp@-
    movel %sp,%fp@(-324)
    clrl %fp@(-32)
    moveal %a5@,%a0
    moveal %a0@,%a4
    tstw %a4@(66)
    jblt PAINTVECTOR_576
    lea %fp@(-136),%a0
    movel %a0,%a0@
    clrl %fp@(-150)
    clrw %fp@(-138)
    movew #1,%fp@(-142)
    movel %sp,%d1
    andib #0xfc,%d1
    moveal %d1,%sp
    lea %a4@(2),%a1
    lea %fp@(-244),%a2
    jsr @(0x1a08,%za0)@(0)	| 40833EC0
    movel %d1,%fp@(-308)
    moveb %d2,%fp@(-304)
    lea %pc@(SHFTTBL),%a0
    movew %fp@(-212),%d0
    moveq #0,%d1
    moveb %a0@(0x0,%d0:w),%d1
    movew %d1,%fp@(-118)
    movel %fp@(8),%fp@(-156)
    movew %fp@(12),%d0
    bset #3,%d0
    moveq #16,%d1
    btst #5,%d0
    jbeq PAINTVECTOR_7E
    cmpiw #58,%d0
    jbeq PAINTVECTOR_84
    moveq #48,%d1
PAINTVECTOR_7E:         /* empty? nothing to draw */
    cmpw %d1,%d0
    jbgt PAINTVECTOR_576
PAINTVECTOR_84:         /* the mode, the colors (COLORMAP), the destination and clip regions */
    movew %d0,%fp@(-152)
    tstw %a4@(6)
    smi %fp@(-166)
    clrb %fp@(-257)
    jsr @(0x1a10,%za0)@(0)	| 40833F14
    moveal %a4@(28),%a2
    moveal %a2@,%a2
    moveal %a4@(24),%a3
    moveal %a3@,%a3
    movel %fp@(14),%sp@-
    pea %fp@(-238)
    pea %a2@(2)
    pea %a3@(2)
    movew #4,%sp@-
    pea %fp@(-116)
    jsr @(0x1a84,%za0)@(0)	| 40833F3E
    jbeq PAINTVECTOR_576
    clrb %fp@(-302)
    cmpiw #10,%a2@
    jbne PAINTVECTOR_144
    cmpiw #10,%a3@
    jbeq PAINTVECTOR_F0
    movel %a4@(24),%sp@-
    pea %fp@(-116)
    movew #-1,%sp@-
    jsr @(0x1aa4,%za0)@(0)	| 40833F64
    jblt PAINTVECTOR_576
    jbgt PAINTVECTOR_144
PAINTVECTOR_F0:         /* 1-bit: a solid pattern makes the mode simpler */
    btst #5,%fp@(-151)
    jbne PAINTVECTOR_144
    moveal %fp@(-156),%a0
    tstb %fp@(-166)
    jbeq PAINTVECTOR_110
    moveal %a0@,%a0
    moveal %a0@,%a0
    tstw %a0@
    jbne PAINTVECTOR_144
    moveal %a0@(6),%a0
    moveal %a0@,%a0
PAINTVECTOR_110:        /* all ones or all zeros? */
    movel %a0@+,%d0
    cmpl %a0@+,%d0
    jbne PAINTVECTOR_144
    notl %d0
    jbeq PAINTVECTOR_124
    notl %d0
    jbne PAINTVECTOR_144
    eoriw #4,%fp@(-152)
PAINTVECTOR_124:        /* map the mode through the table; a no-op: done */
    st %fp@(-302)
    moveq #7,%d0
    andw %fp@(-152),%d0
    moveb %pc@(PAINTVECTOR_13C,%d0:w),%d0
    jbmi PAINTVECTOR_576
    movew %d0,%fp@(-152)
    jbra PAINTVECTOR_144
PAINTVECTOR_13C:        /* mode map (data) */
    .long   0x00000102	| 40833FBC
    .long   0x02FFFFFF	| 40833FC0
PAINTVECTOR_144:        /* on the screen: shield the cursor */
    tstb %fp@(-304)
    jbeq PAINTVECTOR_158
    pea %fp@(-116)
    movel %fp@(-308),%sp@-
    jsr @(0xf54,%za0)@(0)	| 40833FD2
PAINTVECTOR_158:        /* the destination row geometry; the region mask buffer */
    movew %fp@(-118),%d5
    movew %fp@(-114),%d2
    subw %fp@(-236),%d2
    extl %d2
    lsll %d5,%d2
    andil #-32,%d2
    movel %d2,%d0
    lsrl #3,%d0
    movew %d0,%fp@(-144)
    lsrl %d5,%d2
    addw %fp@(-236),%d2
    movew %d2,%fp@(-14)
    tstb %fp@(-302)
    bnew PAINTVECTOR_1D8
    movew %fp@(-110),%d0
    subw %d2,%d0
    movew %d0,%d1
    extl %d1
    lsll %d5,%d1
    subql #1,%d1
    lsrl #5,%d1
    movew %d1,%fp@(-16)
    lsrw #5,%d0
    addqw #1,%d0
    lslw %d5,%d0
    subqw #1,%d0
PAINTVECTOR_1A4:        /* clear it */
    clrl %sp@-
    dbf %d0,PAINTVECTOR_1A4
    movel %sp,%fp@(-8)
    lea %pc@(PAINTVECTOR_56A),%a0
    movel %a0,%fp@(-128)
    movel Lo3Bytes,%fp@(-132)
    clrl %fp@(-124)
    clrl %fp@(-12)
    movel %a4@(24),%sp@-
    movel %a4@(28),%sp@-
    movel #1,%sp@-
    jsr @(0x1a34,%za0)@(0)	| 40834052
PAINTVECTOR_1D8:        /* the first destination row */
    movew %fp@(-116),%d1
    subw %fp@(-238),%d1
    movew %fp@(-240),%d0
    andiw #32767,%d0
    extl %d0
    movel %d0,%fp@(-124)
    mulsw %d0,%d1
    addl %fp@(-244),%d1
    movew %fp@(-14),%d2
    subw %fp@(-236),%d2
    movew %fp@(-118),%d7
    lslw %d7,%d2
    lsrw #3,%d2
    extl %d2
    addl %d2,%d1
    movel %d1,%fp@(-292)
    movew %fp@(-14),%d1
    subw %d1,%fp@(-114)
    subw %d1,%fp@(-110)
    movew %fp@(-152),%d2
    tstb %fp@(-302)
    jbeq PAINTVECTOR_22E
    jsr @(0x1a30,%za0)@(0)	| 408340A2
    movel %a4,%fp@(-288)
    jbra PAINTVECTOR_28A
PAINTVECTOR_22E:        /* inverting modes: d7 = -1 */
    moveq #0,%d7
    movew %fp@(-152),%d2
    btst #5,%d2
    jbne PAINTVECTOR_242
    bclr #2,%d2
    jbeq PAINTVECTOR_242
    notl %d7
PAINTVECTOR_242:        /* the pattern (PATEXPAND); old patterns: 8 rows of 4 bytes */
    jsr @(0x1a54,%za0)@(0)	| 408340C2
    movew %fp@(-142),%d1
    jbne PAINTVECTOR_264
    moveq #15,%d0
    moveq #4,%d1
    movew %d1,%fp@(-142)
    movew #3,%fp@(-140)
    movew #63,%fp@(-138)
    jbra PAINTVECTOR_272
PAINTVECTOR_264:        /* pixpat: its row count */
    moveq #0,%d0
    movew %fp@(-138),%d0
    addqw #1,%d0
    divuw %fp@(-142),%d0
    subqw #1,%d0
PAINTVECTOR_272:        /* the pattern row for the first line; the slab loop for the mode (SLABMODE) */
    andw %fp@(-116),%d0
    muluw %d1,%d0
    movel %d0,%fp@(-150)
    movew %fp@(-152),%d2
    jsr @(0x1a94,%za0)@(0)	| 40834100
    movel %a4,%fp@(-288)
PAINTVECTOR_28A:        /* 32-bit addressing; the edge record pool from the stack left */
    moveq #1,%d0
    jsr @(0x574,%za0)@(0x0)	| 4083410C
    moveb %d0,%fp@(-258)
    clrl %fp@(-312)
    clrl %fp@(-320)
    _StackSpace
    movel %sp,%d1
    subl %d0,%d1
    addil #1600,%d1
    movel %d1,%fp@(-316)
    movel %fp@(22),%d0
    jsr @(0x644,%za0)@(0x0)	| 40834132
    moveal %d0,%a3
    movew %a3@,%d4
    movew %d4,%fp@(-4)
    movew %fp@(20),%d3
PAINTVECTOR_2C4:        /* next row: new edges starting on it */
    subal %a0,%a0
    subal %a1,%a1
    tstw %d3
    jbeq PAINTVECTOR_3BC
PAINTVECTOR_2CE:        /* an edge starting here: a record (from the free list or the stack) */
    cmpw %a3@,%d4
    jbne PAINTVECTOR_3BC
    moveal %fp@(-312),%a2
    movel %a2,%d0
    jbne PAINTVECTOR_2F2
    subaw #20,%sp
    moveal %sp,%a2
    cmpal %fp@(-316),%a2
    jbge PAINTVECTOR_2F6
    movew #-144,QDErr
    jbra PAINTVECTOR_560
PAINTVECTOR_2F2:        /* from the free list */
    movel %a2@,%fp@(-312)
PAINTVECTOR_2F6:        /* its slope (FixRatio of dh/dv) and starting h */
    moveml %a0-%a1,%sp@-
    clrl %sp@-
    movel %a3@(4),%sp@-
    jsr @(0xfa4,%za0)@(0)	| 40834180
    movel %sp@+,%d2
    moveml %sp@+,%a0-%a1
    movew %a3@(2),%d1
    subw %fp@(-14),%d1
    swap %d1
    movew #-32768,%d1
    movel %d2,%d0
    asrl #1,%d0
    addl %d0,%d1
    movel #65536,%d0
    tstl %d2
    jbmi PAINTVECTOR_332
    cmpl %d0,%d2
    jbge PAINTVECTOR_33C
    addl %d2,%d1
    jbra PAINTVECTOR_33C
PAINTVECTOR_332:        /* steep: start half a step in */
    cmpil #-65536,%d2
    jbge PAINTVECTOR_33C
    addl %d0,%d1
PAINTVECTOR_33C:        /* h and slope; the end row and direction (+1/-1) */
    movel %d1,%a2@(8)
    movel %d2,%a2@(12)
    moveq #1,%d1
    movew %a3@(4),%d0
    jbpl PAINTVECTOR_350
    negw %d0
    negw %d1
PAINTVECTOR_350:        /* end row */
    addw %d4,%d0
    movew %d0,%a2@(16)
    tstb %fp@(18)
    jbeq PAINTVECTOR_35E
    moveq #0,%d1
PAINTVECTOR_35E:        /* winding direction (0 for even-odd); insert in the new-edge list sorted by h */
    movew %d1,%a2@(18)
    movel %a0,%d0
    jbne PAINTVECTOR_372
    moveal %a2,%a0
    moveal %a2,%a1
    clrl %a2@
    clrl %a2@(4)
    jbra PAINTVECTOR_3B4
PAINTVECTOR_372:        /* find its place */
    moveal %a1,%a4
    movel %a2@(8),%d0
PAINTVECTOR_378:        /* by h */
    cmpl %a4@(8),%d0
    jbge PAINTVECTOR_394
    moveal %a4@(4),%a4
    movel %a4,%d1
    jbne PAINTVECTOR_378
    movel %a0,%a2@
    movel %a2,%a0@(4)
    clrl %a2@(4)
    moveal %a2,%a0
    jbra PAINTVECTOR_3B4
PAINTVECTOR_394:        /* insert before */
    cmpal %a1,%a4
    jbeq PAINTVECTOR_3AA
    movel %a4,%a2@(4)
    movel %a4@,%d0
    movel %a2,%a4@
    movel %d0,%a2@
    moveal %d0,%a4
    movel %a2,%a4@(4)
    jbra PAINTVECTOR_3B4
PAINTVECTOR_3AA:        /* append */
    movel %a2,%a1@
    movel %a1,%a2@(4)
    clrl %a2@
    moveal %a2,%a1
PAINTVECTOR_3B4:        /* next vector */
    addql #8,%a3
    subqw #1,%d3
    jbgt PAINTVECTOR_2CE
PAINTVECTOR_3BC:        /* merge the new edges into the active list (both sorted by h) */
    subal %a1,%a1
    moveal %fp@(-320),%a4
PAINTVECTOR_3C2:        /* one list empty: append the other */
    movel %a4,%d0
    jbne PAINTVECTOR_3DA
    movel %a0,%d0
    jbeq PAINTVECTOR_416
    movel %a1,%a0@(4)
    jbne PAINTVECTOR_3D6
    movel %a0,%fp@(-320)
    jbra PAINTVECTOR_416
PAINTVECTOR_3D6:        /* append */
    movel %a0,%a1@
    jbra PAINTVECTOR_416
PAINTVECTOR_3DA:        /* new list empty */
    movel %a0,%d0
    jbne PAINTVECTOR_3EE
    movel %a1,%a4@(4)
    jbne PAINTVECTOR_3EA
    movel %a4,%fp@(-320)
    jbra PAINTVECTOR_416
PAINTVECTOR_3EA:        /* append */
    movel %a4,%a1@
    jbra PAINTVECTOR_416
PAINTVECTOR_3EE:        /* the smaller h first */
    movel %a4@(8),%d0
    cmpl %a0@(8),%d0
    jble PAINTVECTOR_3FE
    moveal %a0,%a2
    moveal %a2@,%a0
    jbra PAINTVECTOR_402
PAINTVECTOR_3FE:        /* from the active list */
    moveal %a4,%a2
    moveal %a2@,%a4
PAINTVECTOR_402:        /* link it */
    movel %a1,%a2@(4)
    jbne PAINTVECTOR_40E
    movel %a2,%fp@(-320)
    jbra PAINTVECTOR_410
PAINTVECTOR_40E:        /* link */
    movel %a2,%a1@
PAINTVECTOR_410:        /* next */
    clrl %a2@
    moveal %a2,%a1
    jbra PAINTVECTOR_3C2
PAINTVECTOR_416:        /* inside the visible rows: the region mask for this row (seek proc) */
    cmpw %fp@(-116),%d4
    jblt PAINTVECTOR_42C
    tstb %fp@(-302)
    jbne PAINTVECTOR_42C
    movew %d4,%fp@(-4)
    jsr %fp@(0xffffffffffffffe4,%za0)@(0)	| 408342A6
PAINTVECTOR_42C:        /* walk the active edges left to right */
    moveal %fp@(-320),%a4
    moveq #0,%d5
PAINTVECTOR_432:        /* next edge: ended? remove it; winding count */
    moveal %a4,%a1
    moveal %a1@,%a4
    cmpw %a1@(16),%d4
    jbge PAINTVECTOR_500
    movew %a1@(18),%d0
    jbeq PAINTVECTOR_45A
    tstw %d5
    jbne PAINTVECTOR_44C
    movew %a1@(8),%d6
PAINTVECTOR_44C:        /* nonzero winding: inside */
    addw %d0,%d5
    jbne PAINTVECTOR_4AA
PAINTVECTOR_450:        /* a span from d6 to this edge */
    movew %a1@(8),%d0
    cmpw %d6,%d0
    jbgt PAINTVECTOR_466
    jbra PAINTVECTOR_4AA
PAINTVECTOR_45A:        /* even-odd: toggle */
    eoriw #1,%d5
    jbeq PAINTVECTOR_450
    movew %a1@(8),%d6
    jbra PAINTVECTOR_4AA
PAINTVECTOR_466:        /* draw the slab (DRAWSLAB) with the pattern row */
    cmpw %fp@(-116),%d4
    jblt PAINTVECTOR_4AA
    movew %d6,%d1
    movew %d0,%d2
    moveml %d3-%d6/%a1-%a4,%sp@-
    movel %fp@(-150),%d6
    lea %fp@(0xffffffffffffff78)@(0x0,%d6:l),%a0
    movel %a0@,%d6
    moveal %fp@(-292),%a1
    moveal %fp@(-8),%a2
    lea %fp@(-116),%a3
    moveal %fp@(-288),%a4
    movew %fp@(-118),%d0
    movel %fp@(-160),%d4
    movel %fp@(-164),%d5
    jsr @(0x1a2c,%za0)@(0)	| 4083431C
    movel %a4,%fp@(-288)
    moveml %sp@+,%d3-%d6/%a1-%a4
PAINTVECTOR_4AA:        /* step the edge's h by its slope; keep the list sorted */
    movel %a1@(8),%d0
    addl %a1@(12),%d0
    movel %d0,%a1@(8)
    moveal %a1@(4),%a2
    movel %a2,%d1
    jbeq PAINTVECTOR_522
    cmpl %a2@(8),%d0
    jbge PAINTVECTOR_522
    movel %a1@,%a2@
    jbeq PAINTVECTOR_4CE
    moveal %a1@,%a0
    movel %a2,%a0@(4)
PAINTVECTOR_4CE:        /* move it right */
    moveal %a2@(4),%a2
    movel %a2,%d1
    jbne PAINTVECTOR_4EA
    moveal %fp@(-320),%a2
    movel %a2,%a1@
    clrl %a1@(4)
    movel %a1,%a2@(4)
    movel %a1,%fp@(-320)
    jbra PAINTVECTOR_522
PAINTVECTOR_4EA:        /* insert */
    cmpl %a2@(8),%d0
    jblt PAINTVECTOR_4CE
    moveal %a2@,%a0
    movel %a0,%a1@
    movel %a2,%a1@(4)
    movel %a1,%a0@(4)
    movel %a1,%a2@
    jbra PAINTVECTOR_522
PAINTVECTOR_500:        /* an ended edge: unlink it, back to the free list */
    moveal %a1@(4),%a0
    movel %a0,%d0
    jbne PAINTVECTOR_50E
    movel %a1@,%fp@(-320)
    jbra PAINTVECTOR_510
PAINTVECTOR_50E:        /* unlink */
    movel %a1@,%a0@
PAINTVECTOR_510:        /* back link */
    jbeq PAINTVECTOR_518
    moveal %a1@,%a2
    movel %a0,%a2@(4)
PAINTVECTOR_518:        /* to the free list */
    movel %fp@(-312),%a1@
    movel %a1,%fp@(-312)
    moveal %a0,%a1
PAINTVECTOR_522:        /* next edge; next pattern row and destination row */
    movel %a4,%d0
    jbne PAINTVECTOR_432
    cmpw %fp@(-116),%d4
    jblt PAINTVECTOR_546
    movel %fp@(-150),%d0
    addw %fp@(-142),%d0
    andw %fp@(-138),%d0
    movel %d0,%fp@(-150)
    movel %fp@(-124),%d0
    addl %d0,%fp@(-292)
PAINTVECTOR_546:        /* next row; until the bottom or no edges left */
    addqw #1,%d4
    movew %d4,%fp@(-4)
    cmpw %fp@(-112),%d4
    jbge PAINTVECTOR_560
    tstl %fp@(-320)
    jbne PAINTVECTOR_2C4
    tstw %d3
    jbne PAINTVECTOR_2C4
PAINTVECTOR_560:        /* restore the addressing mode */
    moveb %fp@(-258),%d0
    jsr @(0x574,%za0)@(0x0)	| 408343E4
PAINTVECTOR_56A:        /* show the cursor */
    tstb %fp@(-304)
    jbeq PAINTVECTOR_576
    jsr @(0xf4c,%za0)@(0)	| 408343F0
PAINTVECTOR_576:        /* hilite off, return */
    bset #7,HiliteMode
    moveal %fp@(-324),%sp
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    rtd #18
    .short  0x0000, 0x0000, 0x0000	| 4083440A
