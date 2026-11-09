/*
 toolbox/scriptmgr.s - Script Manager, Roman script system, international utilities
 From CODEENTRY (0x4081D910). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code and the Script Manager / International Utilities chapters of Inside Macintosh, not taken from Apple. Routine headers name the selector or job of each routine; labels inside say what that part does.
*/

/* CODEENTRY: Script Manager code entry. */
CODEENTRY:
VERSIONADDRESS:
    .short  0x0215	| 4081D910

/* PATCHSTART: start of the Script Manager patches. */
PATCHSTART:
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 4081D912

/* ROMANPRINT: Roman script system: print action. */
ROMANPRINT:
    rts	| 4081D920

/* ROMANNAME: Roman script name. */
ROMANNAME:
    .byte   0x05	| 4081D922
    .ascii  "Roman"

/* ROMANSCRIPT: the Roman script system. */
ROMANSCRIPT:
    movel %sp@(4),%d0	| 4081D928
    moveal IntlSpec,%a0
    moveal %a0@(114),%a0
    cmpw %a0@(70),%d0
    jbhi BITBUCKET
    subw %a0@(68),%d0
    addw %d0,%d0
    moveal %a0@(64),%a0
    moveal %a0@(0x0,%d0:w),%a0
    jmp %a0@

/* ROMANDISPTABLE: Roman script dispatch table. */
ROMANDISPTABLE:
    .short  GETSCRIPT-ROMANDISPTABLE	| 4081D94C
    .short  GETSCRIPT-ROMANDISPTABLE	| 4081D94E
    .short  CHARBYTE-ROMANDISPTABLE	| 4081D950
    .short  CHARTYPE-ROMANDISPTABLE	| 4081D952
    .short  PIXEL2CHAR-ROMANDISPTABLE	| 4081D954
    .short  CHAR2PIXEL-ROMANDISPTABLE	| 4081D956
    .short  TRANSLIT-ROMANDISPTABLE	| 4081D958
    .short  FINDWORD-ROMANDISPTABLE	| 4081D95A
    .short  HILITETEXT-ROMANDISPTABLE	| 4081D95C
    .short  DRAWJUST-ROMANDISPTABLE	| 4081D95E
    .short  MEASUREJUST-ROMANDISPTABLE	| 4081D960
    .short  PARSETABLE-ROMANDISPTABLE	| 4081D962
    .short  FIXSPEXTRA_5E-ROMANDISPTABLE	| 4081D964
    .short  FIXSPEXTRA_50-ROMANDISPTABLE	| 4081D966
    .short  FIXSPEXTRA_AC-ROMANDISPTABLE	| 4081D968
SETSCRIPT:
GETSCRIPT:              /* the Roman script has no script variables: no-op */
    jbra BITBUCKET	| 4081D96A

/* CHARBYTE: _CharByte: single or part of a double byte character. */
CHARBYTE:
    clrw %sp@(14)
    movew #10,%d0
    jbra STDEXIT

/* CHARTYPE: _CharType: character class, case, direction. */
CHARTYPE:
    clrl %sp@-	| 4081D97A
    movew #2,%sp@-	| 4081D97C
    movew #6,%sp@-	| 4081D980
    _Pack6	| 4081D984
    movel %sp@+,%d0	| 4081D986
    moveal %sp@+,%a0	| 4081D988
    tstl %sp@+	| 4081D98A
    movew %sp@+,%d1	| 4081D98C
    moveal %sp@+,%a1	| 4081D98E
    moveml %a2-%a3,%sp@-	| 4081D990
    tstl %d0	| 4081D994
    jbeq CHARTYPE_5C	| 4081D996
    moveal %d0,%a2	| 4081D998
    moveq #0,%d0	| 4081D99A
    moveal %a2@,%a2	| 4081D99C
    btst #0,%a2@(9)	| 4081D99E
    jbeq CHARTYPE_5C	| 4081D9A4
    moveal %a2,%a3	| 4081D9A6
    movew %a2@(14),%d0	| 4081D9A8
    addal %d0,%a2	| 4081D9AC
    movew %a3@(12),%d0	| 4081D9AE
    addal %d0,%a3	| 4081D9B2
    moveq #0,%d0	| 4081D9B4
    moveb %a1@(0,%d1:w),%d0	| 4081D9B6
    moveb %a2@(0,%d0:w),%d0	| 4081D9BA
    moveb %a3@(0,%d0:w),%d0	| 4081D9BE
    moveb %d0,%d1	| 4081D9C2
    jbpl CHARTYPE_50	| 4081D9C4
    bset #14,%d0	| 4081D9C6
CHARTYPE_50:            /* class in the low nibble, the subclass/direction bits shifted into place */
    andib #15,%d0	| 4081D9CA
    andib #112,%d1	| 4081D9CE
    lslw #4,%d1	| 4081D9D2
    orw %d1,%d0	| 4081D9D4
CHARTYPE_5C:            /* restore registers */
    moveml %sp@+,%a2-%a3	| 4081D9D6
    movew %d0,%sp@	| 4081D9DA
    jmp %a0@	| 4081D9DC

/* PIXEL2CHAR: _Pixel2Char: offset at a pixel position. */
PIXEL2CHAR:
    linkw %fp,#0	| 4081D9DE
    moveml %d3-%d7/%a2-%a4,%sp@-	| 4081D9E2
    moveal %fp@(12),%a2	| 4081D9E6
    moveal %fp@(22),%a3	| 4081D9EA
    subql #4,%sp	| 4081D9EE
    movel %a3,%sp@-	| 4081D9F0
    movew %fp@(20),%sp@-	| 4081D9F2
    movew %fp@(18),%sp@-	| 4081D9F6
    jbsr FIXSPEXTRA	| 4081D9FA
    clrb %a2@	| 4081D9FE
    moveq #0,%d4	| 4081DA00
    movew %fp@(16),%d3	| 4081DA02
    jble PIXEL2CHAR_9E	| 4081DA06
    addqb #1,%a2@	| 4081DA08
    movew %fp@(20),%d4	| 4081DA0A
    clrw %sp@-	| 4081DA0E
    movel %a3,%sp@-	| 4081DA10
    clrw %sp@-	| 4081DA12
    movew %d4,%sp@-	| 4081DA14
    _TextWidth	| 4081DA16
    cmpw %sp@+,%d3	| 4081DA18
    jbhi PIXEL2CHAR_9E	| 4081DA1A
    movel %d4,%d7	| 4081DA1C
    addl %d7,%d7	| 4081DA1E
    addql #2,%d7	| 4081DA20
    movel %sp,%d0	| 4081DA22
    subl ApplLimit,%d0	| 4081DA24
    subl %d7,%d0	| 4081DA28
    cmpil #1024,%d0	| 4081DA2A
    jblt PIXEL2CHAR_76	| 4081DA30
    subal %d7,%sp	| 4081DA32
    moveal %sp,%a4	| 4081DA34
    movew %d4,%sp@-	| 4081DA36
    movel %a3,%sp@-	| 4081DA38
    movel %a4,%sp@-	| 4081DA3A
    _MeasureText	| 4081DA3C
    movew %d4,%d0	| 4081DA3E
PIXEL2CHAR_62:          /* search the width table for the first edge at or beyond the pixel offset */
    cmpw %a4@+,%d3	| 4081DA40
    dbls %d0,PIXEL2CHAR_62	| 4081DA42
    subw %d0,%d4	| 4081DA46
    movew %a4@(-2),%d5	| 4081DA48
    movew %a4@(-4),%d6	| 4081DA4C
    addal %d7,%sp	| 4081DA50
    jbra PIXEL2CHAR_8E	| 4081DA52
PIXEL2CHAR_76:          /* no width table: measure one more character at a time with _TextWidth */
    moveq #0,%d4	| 4081DA54
    movel %d4,%d5	| 4081DA56
PIXEL2CHAR_7A:          /* next character, until its right edge passes the offset */
    clrw %sp@-	| 4081DA58
    movel %a3,%sp@-	| 4081DA5A
    clrw %sp@-	| 4081DA5C
    addqw #1,%d4	| 4081DA5E
    movew %d4,%sp@-	| 4081DA60
    _TextWidth	| 4081DA62
    movew %d5,%d6	| 4081DA64
    movew %sp@+,%d5	| 4081DA66
    cmpw %d5,%d3	| 4081DA68
    jbhi PIXEL2CHAR_7A	| 4081DA6A
PIXEL2CHAR_8E:          /* leading edge if the offset is in the left half of the character, else the trailing one */
    clrb %a2@	| 4081DA6C
    addw %d3,%d3	| 4081DA6E
    addw %d5,%d6	| 4081DA70
    cmpw %d6,%d3	| 4081DA72
    jbhi PIXEL2CHAR_9E	| 4081DA74
    moveb #1,%a2@	| 4081DA76
    subqw #1,%d4	| 4081DA7A
PIXEL2CHAR_9E:          /* restore the space extra; return the offset */
    _SpaceExtra	| 4081DA7C
    movew %d4,%fp@(26)	| 4081DA7E
    moveml %sp@+,%d3-%d7/%a2-%a4	| 4081DA82
    movew #18,%d0	| 4081DA86
    jbra STDUNLINK	| 4081DA8A

/* CHAR2PIXEL: _Char2Pixel: pixel position of an offset. */
CHAR2PIXEL:
    linkw %fp,#0
    subql #4,%sp
    movel %fp@(20),%sp@-
    movew %fp@(18),%sp@-
    movew %fp@(16),%sp@-
    jbsr FIXSPEXTRA
    movew %fp@(14),%d0
    jbpl CHAR2PIXEL_1E
    clrw %d0
CHAR2PIXEL_1E:          /* pin the offset to the text length */
    cmpw %fp@(18),%d0
    jble CHAR2PIXEL_28
    movew %fp@(18),%d0
CHAR2PIXEL_28:          /* width of the text up to the offset; restore the space extra */
    subql #2,%sp
    movel %fp@(20),%sp@-
    clrw %sp@-
    movew %d0,%sp@-
    _TextWidth
    movew %sp@+,%fp@(24)
    _SpaceExtra
    movew #16,%d0
    jbra STDUNLINK

/* TRANSLIT: _Transliterate: change the case or script of text. */
TRANSLIT:
    linkw %fp,#0
    moveml %d3/%a2-%a4,%sp@-
    moveq #-1,%d0
    movel %fp@(12),%d1
    andiw #3,%d1
    jbeq TRANSLIT_C4
    movew %fp@(16),%d1
    movew %d1,%d2
    subqb #1,%d1
    jbgt TRANSLIT_C4
    addqb #3,%d1
    nop
    jblt TRANSLIT_C4
    movew #-16384,%d3
    andw %d3,%d2
    cmpw %d3,%d2
    jbeq TRANSLIT_C4
    moveal %fp@(22),%a1
    moveal %fp@(18),%a2
    moveal %a1,%a0
    _GetHandleSize
    tstl %d0
    jblt TRANSLIT_C4
    movel %d0,%d1
    moveal %a2,%a0
    _SetHandleSize
    tstw %d0
    jblt TRANSLIT_C4
    moveal %a1@,%a1
    moveal %a2@,%a2
    moveml %d1-%d2/%a1,%sp@-
    clrl %sp@-
    movew #2,%sp@-
    movew #6,%sp@-
    _Pack6
    moveal %sp@+,%a4
    moveml %sp@+,%d1-%d2/%a1
    moveq #-1,%d0
    movel %a4,%d3
    beqw TRANSLIT_C4
    moveal %a4@,%a4
    btst #0,%a4@(9)
    jbeq TRANSLIT_C4
    moveq #0,%d3
    moveal %a4,%a0
    moveq #0,%d0
    movew %a4@(14),%d0
    addal %d0,%a0
    moveal %a4,%a3
    movew %a4@(16),%d0
    addal %d0,%a3
    moveq #0,%d0
    cmpiw #-32768,%d2
    jbeq TRANSLIT_BE
    moveal %a4,%a3
    movew %a4@(18),%d0
    addal %d0,%a3
    moveq #0,%d0
    cmpiw #16384,%d2
    jbeq TRANSLIT_BE
    moveal %a1,%a0
    moveal %a2,%a1
    movel %d1,%d0
    _BlockMove
    jbra TRANSLIT_C2
TRANSLIT_B2:            /* per character: its class from the table, the case offset added */
    moveb %a1@+,%d0
    moveb %a0@(0x0,%d0:w),%d3
    addb %a3@(0x0,%d3:w),%d0
    moveb %d0,%a2@+
TRANSLIT_BE:            /* next character */
    dbf %d1,TRANSLIT_B2
TRANSLIT_C2:            /* noErr */
    moveq #0,%d0
TRANSLIT_C4:            /* return the result */
    movew %d0,%fp@(26)
    moveml %sp@+,%d3/%a2-%a4
    movew #18,%d0
    jbra STDUNLINK

/* FINDWORD: _FindWord: word boundaries (break tables). */
FINDWORD:
    linkw %fp,#0
    moveml %d3-%d7/%a2-%a4,%sp@-
    moveal %fp@(12),%a2
    moveal %fp@(26),%a3
    movew %fp@(22),%d4
    movew %fp@(24),%d7
    tstb %fp@(20)
    jbne FINDWORD_20
    subqw #1,%d4
FINDWORD_20:            /* no 'itl2' or no break tables: empty; breaks nil: table +22, -1: table +24, else the caller's */
    moveq #0,%d3
    movel %d3,%d5
    tstw %d4
    jblt FINDWORD_9E
    movel %d7,%d3
    movel %d7,%d5
    cmpw %d7,%d4
    jbge FINDWORD_9E
    clrl %sp@-
    movew #2,%sp@-
    movew #6,%sp@-
    _Pack6
    moveal %sp@+,%a0
    movel %a0,%d0
    jbeq FINDWORD_9E
    moveal %a0@,%a0
    btst #0,%a0@(9)
    jbeq FINDWORD_9E
    moveal %a0,%a1
    moveq #0,%d0
    movew %a0@(22),%d0
    addal %d0,%a1
    movel %fp@(16),%d0
    jbeq FINDWORD_72
    moveal %a0,%a1
    moveq #0,%d0
    movew %a0@(24),%d0
    addal %d0,%a1
    movel %fp@(16),%d0
    cmpl MinusOne,%d0
    jbeq FINDWORD_72
    moveal %d0,%a1
FINDWORD_72:            /* scan from the offset: three characters of context, then the start of the word */
    lea %a1@(256),%a4
    movew %d4,%d3
    movew %d4,%d5
    subqw #2,%d5
    moveq #0,%d6
    jbsr FINDWORD_B2
    jbsr FINDWORD_B2
    jbsr FINDWORD_B2
    jbsr FINDWORD_EC
    jbne FINDWORD_9E
    movew %d6,%sp@-
FINDWORD_8A:            /* extend right while the pair is part of a word */
    jbsr FINDWORD_B2
    jbsr FINDWORD_F4
    jbeq FINDWORD_8A
    movew %sp@+,%d6
    subqw #1,%d3
FINDWORD_94:            /* extend left while the pair is part of a word */
    jbsr FINDWORD_CE
    jbsr FINDWORD_10C
    jbeq FINDWORD_94
    subqw #1,%d5
    addqw #2,%d3
FINDWORD_9E:            /* store the word's start and end in the offset table, clear the rest; return */
    movew %d3,%a2@+
    movew %d5,%a2@+
    clrl %a2@+
    clrl %a2@
    moveml %sp@+,%d3-%d7/%a2-%a4
    movew #22,%d0
    jbra STDUNLINK

FINDWORD_B2:            /* next character to the right: its class into the low 5 bits of the window in %d6 */
    moveq #0,%d0
    addqw #1,%d5
    jblt FINDWORD_C4
    cmpw %d7,%d5
    jbge FINDWORD_C4
    moveb %a3@(0x0,%d5:w),%d0
    moveb %a1@(0x0,%d0:w),%d0
FINDWORD_C4:            /* shift it in */
    lslw #5,%d6
    andiw #32767,%d6
    orb %d0,%d6
    rts

FINDWORD_CE:            /* next character to the left: its class into the window */
    moveq #0,%d0
    subqw #1,%d3
    jblt FINDWORD_E0
    cmpw %d7,%d3
    jbge FINDWORD_E0
    moveb %a3@(0x0,%d3:w),%d0
    moveb %a1@(0x0,%d0:w),%d0
FINDWORD_E0:            /* shift it in (rotate right) */
    andiw #-32,%d6
    addw %d6,%d6
    orw %d0,%d6
    rorw #6,%d6
    rts

FINDWORD_EC:            /* is the left pair a break? */
    jbsr FINDWORD_F4
    jbeq FINDWORD_13A
    movew %d6,%d1
    jbra FINDWORD_112

FINDWORD_F4:            /* is the right pair a break? checked against the break table */
    movew %d6,%d1
    jbsr FINDWORD_13C
    jbeq FINDWORD_13A
    andiw #-32,%d1
    jbsr FINDWORD_13C
    jbeq FINDWORD_13A
    andiw #31744,%d1
    cmpiw #1024,%d1
    jbra FINDWORD_122

FINDWORD_10C:           /* same, leftwards */
    movew %d6,%d1
    jbsr FINDWORD_13C
    jbeq FINDWORD_13A
FINDWORD_112:           /* class pair test against the break table */
    andiw #1023,%d1
    jbsr FINDWORD_13C
    jbeq FINDWORD_13A
    andiw #31,%d1
    cmpiw #1,%d1
FINDWORD_122:           /* compare the classes on either side */
    jbne FINDWORD_130
    movew %d6,%d1
    andiw #992,%d1
    seq %d1
    tstb %d1
    rts
FINDWORD_130:           /* class 1 next to class 1 */
    movew %d6,%d1
    andiw #992,%d1
    cmpiw #32,%d1
FINDWORD_13A:           /* return */
    rts

FINDWORD_13C:           /* search the break table (count, then words) for %d1 */
    moveal %a4,%a0
    movew %a0@+,%d0
FINDWORD_140:           /* loop: compare; Z set if found */
    cmpw %a0@+,%d1
    dbeq %d0,FINDWORD_140
    rts

/* HILITETEXT: _HiliteText: ranges to highlight. */
HILITETEXT:
    linkw %fp,#0
    moveal %fp@(12),%a0
    movew %fp@(20),%d1
    movew %fp@(18),%d0
    jbsr HILITETEXT_24
    movew %fp@(16),%d0
    jbsr HILITETEXT_24
    clrl %a0@+
    clrl %a0@+
    movew #18,%d0
    jbra STDUNLINK

HILITETEXT_24:          /* pin %d0 to 0..length and store it in the offset table */
    jbge HILITETEXT_28
    moveq #0,%d0
HILITETEXT_28:          /* pin to the length */
    cmpw %d1,%d0
    jble HILITETEXT_2E
    movew %d1,%d0
HILITETEXT_2E:          /* store it */
    movew %d0,%a0@+
    rts

/* DRAWJUST: _DrawJust: draw justified text. */
DRAWJUST:
    linkw %fp,#0
    subql #4,%sp
    movel %fp@(16),%sp@-
    movew %fp@(14),%sp@-
    movew %fp@(12),%sp@-
    jbsr FIXSPEXTRA
    movel %fp@(16),%sp@-
    clrw %sp@-
    movew %fp@(14),%sp@-
    _DrawText
    _SpaceExtra
    movew #12,%d0
    jbra STDUNLINK

/* MEASUREJUST: _MeasureJust. */
MEASUREJUST:
    linkw %fp,#0
    subql #4,%sp
    movel %fp@(20),%sp@-
    movew %fp@(18),%sp@-
    movew %fp@(16),%sp@-
    jbsr FIXSPEXTRA
    movew %fp@(18),%sp@-
    movel %fp@(20),%sp@-
    movel %fp@(12),%sp@-
    _MeasureText
    _SpaceExtra
    movew #16,%d0
    jbra STDUNLINK

/* PARSETABLE: _ParseTable: double byte character table. */
PARSETABLE:
    linkw %fp,#0
    movew #256,%fp@(16)
    moveal %fp@(12),%a0
    movew #255,%d0
PARSETABLE_12:          /* clear the 256 entries (no double-byte characters in Roman); return 256 */
    clrb %a0@+
    dbf %d0,PARSETABLE_12
    movew #10,%d0
    jbra STDUNLINK

/* FIXSPEXTRA: fix the space extra for justification. */
FIXSPEXTRA:
    linkw %fp,#0
    moveal %fp@(12),%a0
    movew %fp@(10),%d0
    moveq #0,%d1
    movew %fp@(8),%d2
    jbne FIXSPEXTRA_24
    movel %d1,%sp@-
    jbra FIXSPEXTRA_36
FIXSPEXTRA_18:          /* count the spaces in the text */
    cmpib #32,%a0@+
    dbeq %d0,FIXSPEXTRA_18
    jbne FIXSPEXTRA_28
    addql #1,%d1
FIXSPEXTRA_24:          /* next character */
    dbf %d0,FIXSPEXTRA_18
FIXSPEXTRA_28:          /* slop / spaces as a Fixed (_FixRatio), plus one */
    clrl %sp@-
    tstw %d1
    jbeq FIXSPEXTRA_34
    movew %d2,%sp@-
    movew %d1,%sp@-
    _FixRatio
FIXSPEXTRA_34:          /* round up */
    addql #1,%sp@
FIXSPEXTRA_36:          /* add it to the port's spExtra (+76); return the old value */
    moveal %a5@,%a0
    moveal %a0@,%a0
    movel %a0@(76),%d0
    movel %d0,%fp@(16)
    addl %sp@+,%d0
    movel %d0,%a0@(76)
    movew #8,%d0
    jbra STDUNLINK
/* FINDSCRIPTRUN (FIXSPEXTRA_50): Roman FindScriptRun: the whole text is one run, script 0. */
FIXSPEXTRA_50:          /* FindScriptRun */
    moveal %sp@+,%a1	| 4081DDE4
    tstl %sp@+	| 4081DDE6
    moveal %sp@+,%a0	| 4081DDE8
    movel %sp@+,%a0@	| 4081DDEA
    tstl %sp@+	| 4081DDEC
    clrw %sp@	| 4081DDEE
    jmp %a1@	| 4081DDF0
/* PORTIONTEXT (FIXSPEXTRA_5E): Roman PortionText: the share of the slop for a text, as a Fixed:
 (length + 8 per space) times the port's text size (or the system font size, or 12). */
FIXSPEXTRA_5E:          /* PortionText */
    moveal %sp@+,%a1	| 4081DDF2
    tstl %sp@+	| 4081DDF4
    movel %sp@+,%d0	| 4081DDF6
    moveal %sp@+,%a0	| 4081DDF8
    movel %a1,%sp@-	| 4081DDFA
    moveq #0,%d2
    jbra FIXSPEXTRA_76
FIXSPEXTRA_6C:          /* count the characters, 8 extra per space */
    moveb %a0@+,%d1
    cmpib #32,%d1
    jbne FIXSPEXTRA_76
    addql #8,%d2
FIXSPEXTRA_76:          /* next character; then the text size */
    subql #1,%d0
    jbge FIXSPEXTRA_6C
    moveal %a5@,%a0
    moveal %a0@,%a0
    movew %a0@(74),%d0
    jbne FIXSPEXTRA_8E
    movew SysFontSize,%d0
    jbne FIXSPEXTRA_8E
    movew #12,%d0
FIXSPEXTRA_8E:          /* count times size, as a Fixed (shifted left 8) */
    movel %d2,%d1
    swap %d1
    muluw %d0,%d1
    swap %d1
    clrw %d1
    muluw %d0,%d2
    addw %d2,%d1
    lsll #8,%d1
    movel %d1,%sp@(4)
    rts
    .short  0x0000, 0x0000, 0x0000	| 4081DE38
FIXSPEXTRA_AA:          /* (padding) */
    .byte   0x00, 0x00	| 4081DE3E
/* VISIBLELENGTH (FIXSPEXTRA_AC): Roman VisibleLength: the length of a text without its trailing
 white space (space, tab, return, NUL). */
FIXSPEXTRA_AC:          /* VisibleLength */
    linkw %fp,#0	| 4081DE40
    moveal %fp@(16),%a0	| 4081DE44
    movel %a0,%d2	| 4081DE48
    movel %fp@(12),%d0
    jble XVISIBLELENGTH_34
    addal %d0,%a0
XVISIBLELENGTH_12:      /* from the end: skip NUL, space, return, tab */
    moveb %a0@-,%d1
    jbeq XVISIBLELENGTH_2A
    cmpib #32,%d1
    jbhi XVISIBLELENGTH_32
    jbeq XVISIBLELENGTH_2A
    cmpib #13,%d1
    jbeq XVISIBLELENGTH_2A
    cmpib #9,%d1
    jbne XVISIBLELENGTH_32
XVISIBLELENGTH_2A:      /* reached the start: all white space, length 0 */
    cmpw %a0,%d2
    jbne XVISIBLELENGTH_12
    moveq #0,%d2
    jbra XVISIBLELENGTH_38
XVISIBLELENGTH_32:      /* back over the last visible character */
    addql #1,%a0
XVISIBLELENGTH_34:      /* length = end - start */
    subl %a0,%d2
    negl %d2
XVISIBLELENGTH_38:      /* return the length */
    movel %d2,%fp@(20)
    movew #12,%d0
    jbra STDUNLINK
    .long   0x00000000, 0x00000000, 0x00000000	| 4081DE84

/* PRINTACTION: print action of the script. */
PRINTACTION:
    moveml %d0-%fp,%sp@-
    moveal IntlSpec,%a4
    lea %a4@(114),%a4
    movew #65,%d4
    jbra PRINTACTION_30
PRINTACTION_12:         /* per installed script record: call its print action (+32), if enabled */
    movel %a4@+,%d3
    jbeq PRINTACTION_30
    moveal %d3,%a3
    tstb %a3@(4)
    jbeq PRINTACTION_30
    movel %a3@(32),%d3
    jbeq PRINTACTION_30
    moveal %d3,%a3
    moveml %d0-%d4/%a4,%sp@-
    jsr %a3@
    moveml %sp@+,%d0-%d4/%a4
PRINTACTION_30:         /* next script; restore registers */
    dbf %d4,PRINTACTION_12
    moveml %sp@+,%d0-%fp
    rts

/* SWAPICON: keyboard script icon in the menu bar. */
SWAPICON:
    moveal IntlSpec,%a0
    moveal %a0@(500),%a0
    jmp %a0@

/* XSWAPICON: (extended) keyboard icon. */
XSWAPICON:
    linkw %fp,#-8	| 4081DED4
    moveml %a2-%a3,%sp@-	| 4081DED8
    movel MenuList,%d0	| 4081DEDC
    jbeq XSWAPICON_A8	| 4081DEE0
    tstw MBarHeight	| 4081DEE4
    jble XSWAPICON_A8	| 4081DEE8
    moveal IntlSpec,%a3	| 4081DEEC
    movel %a3@(10),%d0	| 4081DEF0
    btst #31,%d0	| 4081DEF4
    jbne XSWAPICON_2E	| 4081DEF8
    cmpib #1,%a3@(4)	| 4081DEFA
    jble XSWAPICON_A8	| 4081DF00
XSWAPICON_2E:           /* draw the new script's icon in the menu bar (the 'SICN' of the key script) through the Window Manager port */
    pea %fp@(-4)	| 4081DF02
    _GetPort	| 4081DF06
    moveal WMgrPort,%a2	| 4081DF08
    movel %a2,%sp@-	| 4081DF0C
    _SetPort	| 4081DF0E
    movel %a2@(28),%fp@(-8)	| 4081DF10
    moveal %a5@,%a0	| 4081DF16
    movel %a0@(-130),%a2@(28)	| 4081DF18
    subqw #4,%sp	| 4081DF1E
    movel #1397310286,%sp@-	| 4081DF20
    movew %a3@(42),%d0	| 4081DF26
    lslw #2,%d0	| 4081DF2A
    moveal %a3@(0x72,%d0:w),%a0	| 4081DF2C
    movew %a0@(30),%sp@-	| 4081DF30
    _GetResource	| 4081DF34
    movel %sp@+,%d0	| 4081DF36
    jbeq XSWAPICON_9C	| 4081DF38
    movel %d0,%sp@-	| 4081DF3A
    moveal %d0,%a0	| 4081DF3C
    _HLock	| 4081DF3E
    lea IconBitmap,%a1	| 4081DF40
    movel %a0@,%a1@	| 4081DF44
    movew #2,%a1@(4)	| 4081DF46
    clrl %a1@(6)	| 4081DF4C
    movel #1048592,%a1@(10)	| 4081DF50
    movel %a1,%sp@-	| 4081DF58
    pea %a2@(2)	| 4081DF5A
    pea %a1@(6)	| 4081DF5E
    pea %a3@(44)	| 4081DF62
    clrw %sp@-	| 4081DF66
    clrl %sp@-	| 4081DF68
    _CopyBits	| 4081DF6A
    moveal %sp@+,%a0	| 4081DF6C
    _HUnlock	| 4081DF6E
XSWAPICON_9C:           /* restore the port's settings */
    movel %fp@(-8),%a2@(28)	| 4081DF70
    movel %fp@(-4),%sp@-	| 4081DF76
    _SetPort	| 4081DF7A
XSWAPICON_A8:           /* restore registers, return */
    moveml %sp@+,%a2-%a3	| 4081DF7C
    unlk %fp	| 4081DF80
    rts	| 4081DF82

/* SWAPKYBD: switch the keyboard script (Command-Space). */
SWAPKYBD:
    moveal IntlSpec,%a0
    moveal %a0@(504),%a0
    jmp %a0@

/* XSWAPKYBD: (extended) keyboard switch. */
XSWAPKYBD:
    linkw %fp,#0	| 4081DF8E
    moveml %d4/%a2-%a3,%sp@-	| 4081DF92
    moveal ExpandMem,%a3	| 4081DF96
    moveal %a3@(14),%a3	| 4081DF9A
    subql #4,%sp	| 4081DF9E
    movel #1262700626,%sp@-	| 4081DFA0
    moveal IntlSpec,%a0	| 4081DFA6
    movew %a0@(42),%d0	| 4081DFAA
    lslw #2,%d0	| 4081DFAE
    moveal %a0@(0x72,%d0:w),%a0	| 4081DFB0
    movew %a0@(28),%sp@-	| 4081DFB4
    movew #-1,ROMMapInsert	| 4081DFB8
    _GetResource	| 4081DFBE
    moveal %sp@+,%a2	| 4081DFC0
    movel %a2,%d0	| 4081DFC2
    jbeq XSWAPKYBD_78	| 4081DFC4
    moveal %a2,%a0
    _HLock
    movel %a2@,%sp@-
    jsr %pc@(XSWAPKYBD_80)
    moveal %a2,%a0
    _GetHandleSize
    movel %d0,%d4
    moveal %a3,%a0
    _GetPtrSize
    cmpl %d0,%d4
    jblt XSWAPKYBD_62
    movel %d4,%d0
    .short  0xA522	| 4081DFE0 _NewHandle (flags 0x0500)
    jbne XSWAPKYBD_6A
    _DisposHandle
    moveal %a3,%a0
    _DisposPtr
    movel %d4,%d0
    .short  0xA71E	| 4081DFEC _NewPtr (flags 0x0700)
    moveal %a0,%a3
XSWAPKYBD_62:           /* copy the new 'KCHR' into the system's keyboard buffer */
    moveal %a2@,%a0
    moveal %a3,%a1
    movel %d4,%d0
    _BlockMove
XSWAPKYBD_6A:           /* point the ADB keyboards at it, unlock, flush keyboard events */
    movel %a3,%sp@-
    jsr %pc@(XSWAPKYBD_80)
    moveal %a2,%a0
    _HUnlock
    moveq #56,%d0
    _FlushEvents
XSWAPKYBD_78:           /* restore registers, return */
    moveml %sp@+,%d4/%a2-%a3
    unlk %fp
    rts

XSWAPKYBD_80:           /* point every ADB keyboard's KCHR at the new table (needs ADB, HWCfgFlags bit 10) */
    linkw %fp,#-14
    moveml %d3,%sp@-
    moveal ExpandMem,%a0
    clrl %a0@(10)
    movel %fp@(8),%a0@(14)
    moveal ROMBase,%a0
    tstb %a0@(8)
    jbeq XSWAPKYBD_F6
    movew HWCfgFlags,%d0
    btst #10,%d0
    jbeq XSWAPKYBD_F6
    _CountADBs
    movew %d0,%d3
    jbra XSWAPKYBD_D6
XSWAPKYBD_B0:           /* per ADB device: a keyboard (type 2): clear +24, point its KCHR pointer (+20) at the new table */
    movew %d3,%d0
    addqw #1,%d0
    lea %fp@(-10),%a0
    _GetIndADB
    cmpib #2,%fp@(-9)
    jbne XSWAPKYBD_D6
    moveal %fp@(-4),%a0
    clrw %a0@(24)
    lea %a0@(20),%a0
    movel %a0@,%fp@(-14)
    movel %fp@(8),%a0@
XSWAPKYBD_D6:           /* next ADB device; first time: dispose of the original KCHR (handle recovered from the old pointer) */
    dbf %d3,XSWAPKYBD_B0
    moveal ExpandMem,%a1
    lea %a1@(22),%a1
    tstb %a1@
    jbne XSWAPKYBD_F6
    st %a1@
    moveal %fp@(-14),%a0
    .short  0xA128	| 4081E07A _RecoverHandle (flags 0x0100)
    tstw MemErr
    jbne XSWAPKYBD_F6
    _DisposHandle
XSWAPKYBD_F6:           /* restore registers */
    moveml %sp@+,%d3
    movew #4,%d0
    jbra STDUNLINK

/* FIXSMGRWORLD: set up the Script Manager state for the current font. */
FIXSMGRWORLD:
    moveal IntlSpec,%a0
    moveal %a0@(508),%a0
    jmp %a0@

/* XFIXSMGRWORLD: (extended). */
XFIXSMGRWORLD:
    moveml %d3/%a2-%a4,%sp@-	| 4081E09A
    moveal IntlSpec,%a4	| 4081E09E
    subql #4,%sp	| 4081E0A2
    movel #1263753040,%sp@-	| 4081E0A4
    clrw %sp@-	| 4081E0AA
    _GetResource	| 4081E0AC
    movel %sp@+,%a4@(54)	| 4081E0AE
    movew #16383,%d3	| 4081E0B2
    subqw #4,%sp	| 4081E0B6
    movel #1179602500,%sp@-	| 4081E0B8
    movew %d3,%sp@-	| 4081E0BE
    _GetResource	| 4081E0C0
    tstl %sp@+	| 4081E0C2
    jbne XFIXSMGRWORLD_2E	| 4081E0C4
    clrw %d3	| 4081E0C6
XFIXSMGRWORLD_2E:       /* the Roman font family into its record (+8); system and key script from the 'itlc' */
    moveal %a4@(114),%a0	| 4081E0C8
    movew %d3,%a0@(8)	| 4081E0CC
    subqw #4,%sp	| 4081E0D0
    movel #1769237603,%sp@-	| 4081E0D2
    clrw %sp@-	| 4081E0D8
    _GetResource	| 4081E0DA
    movel %sp@+,%d0	| 4081E0DC
    jbeq XFIXSMGRWORLD_58	| 4081E0DE
    moveal %d0,%a0	| 4081E0E0
    moveal %a0@,%a0	| 4081E0E2
    movew %a0@,%d1	| 4081E0E4
    movew %d1,%a4@(38)	| 4081E0E6
    movew %d1,%a4@(42)	| 4081E0EA
    movel %d0,%sp@-	| 4081E0EE
    _ReleaseResource	| 4081E0F0
XFIXSMGRWORLD_58:       /* disable every script, then re-enable each script (64..0) whose 'itlb' is present */
    sf %a4@(4)	| 4081E0F2
    movew #64,%d3	| 4081E0F6
XFIXSMGRWORLD_60:       /* per script: disabled, then enabled if it has an 'itlb' (20 bytes copied to the record +12); count it */
    movew %d3,%d0	| 4081E0FA
    lslw #2,%d0	| 4081E0FC
    movel %a4@(0x72,%d0:w),%d0	| 4081E0FE
    jbeq XFIXSMGRWORLD_98	| 4081E102
    moveal %d0,%a3	| 4081E104
    sf %a3@(4)	| 4081E106
    subql #4,%sp	| 4081E10A
    movel #1769237602,%sp@-	| 4081E10C
    movew %d3,%sp@-	| 4081E112
    _GetResource	| 4081E114
    movel %sp@+,%d0	| 4081E116
    jbeq XFIXSMGRWORLD_98	| 4081E118
    moveal %d0,%a2	| 4081E11A
    moveal %a2@,%a0	| 4081E11C
    lea %a3@(12),%a1	| 4081E11E
    moveq #20,%d0	| 4081E122
    _BlockMove	| 4081E124
    movel %a2,%sp@-	| 4081E126
    _ReleaseResource	| 4081E128
    st %a3@(4)	| 4081E12A
    addqb #1,%a4@(4)	| 4081E12E
XFIXSMGRWORLD_98:       /* next; the system script must be enabled, else fall back to Roman */
    dbf %d3,XFIXSMGRWORLD_60	| 4081E132
    movew %a4@(38),%d3	| 4081E136
    movew %d3,%d0	| 4081E13A
    lslw #2,%d0	| 4081E13C
    movel %a4@(0x72,%d0:w),%d0	| 4081E13E
    jbeq XFIXSMGRWORLD_B2	| 4081E142
    moveal %d0,%a3	| 4081E144
    tstb %a3@(4)	| 4081E146
    jbne XFIXSMGRWORLD_C0	| 4081E14A
XFIXSMGRWORLD_B2:       /* Roman becomes the system script and the key script */
    moveq #0,%d3	| 4081E14C
    moveal %a4@(114),%a3	| 4081E14E
    movew %d3,%a4@(38)	| 4081E152
    movew %d3,%a4@(42)	| 4081E156
XFIXSMGRWORLD_C0:       /* system font not in the system script: take that script's system font */
    moveal IntlSpec,%a0	| 4081E15A
    moveb %a0@(6),%sp@-	| 4081E15E
    sf %a0@(6)	| 4081E162
    clrw %sp@-	| 4081E166
    movew SysFontFam,%sp@-	| 4081E168
    movel #-2113798138,%sp@-	| 4081E16C
    _ScriptUtil	| 4081E172
    cmpw %sp@+,%d3	| 4081E174
    jbeq XFIXSMGRWORLD_EA	| 4081E176
    movew %a3@(8),SysFontFam	| 4081E178
    movew #-2,CurFMFamily	| 4081E17E
XFIXSMGRWORLD_EA:       /* same for the application font */
    clrw %sp@-	| 4081E184
    movew ApFontID,%sp@-	| 4081E186
    movel #-2113798138,%sp@-	| 4081E18A
    _ScriptUtil	| 4081E190
    cmpw %sp@+,%d3	| 4081E192
    jbeq XFIXSMGRWORLD_108	| 4081E194
    movew %a3@(10),ApFontID	| 4081E196
    movew #-2,CurFMFamily	| 4081E19C
XFIXSMGRWORLD_108:      /* switch the keyboard to the key script; remember the boot drive */
    moveal IntlSpec,%a0	| 4081E1A2
    moveb %sp@+,%a0@(6)	| 4081E1A6
    movew %a4@(42),%sp@-	| 4081E1AA
    movel #-2147352572,%sp@-	| 4081E1AE
    _ScriptUtil	| 4081E1B4
    movew BootDrive,%a4@(52)	| 4081E1B6
    moveml %sp@+,%d3/%a2-%a4	| 4081E1BC
    rts	| 4081E1C0

/* SMGRCALCRECT: rectangle of the keyboard icon. */
SMGRCALCRECT:
    moveml %a2,%sp@-
    moveal IntlSpec,%a2
    movew MBarHeight,%d0
    lsrw #1,%d0
    subqw #8,%d0
    movew %d0,%a2@(44)
    addiw #16,%d0
    movew %d0,%a2@(48)
    subqw #4,%sp
    movel %sp,%sp@-
    _GetWMgrPort
    moveal %sp@+,%a0
    tstb %a2@(398)
    jbne SMGRCALCRECT_40
    movew %a0@(22),%d0
    subw %a2@(396),%d0
    movew %d0,%a2@(50)
    subiw #16,%d0
    movew %d0,%a2@(46)
    jbra SMGRCALCRECT_54
SMGRCALCRECT_40:        /* the icon's horizontal position, offset by the Script Manager's adjustment (+396) */
    movew %a0@(18),%d0
    addw %a2@(396),%d0
    movew %d0,%a2@(46)
    addiw #16,%d0
    movew %d0,%a2@(50)
SMGRCALCRECT_54:        /* restore registers, return */
    moveml %sp@+,%a2
    rts

/* SMGRINITFONTS: Script Manager part of InitFonts. */
SMGRINITFONTS:
    moveml %d0/%d3/%a0/%a2-%a3,%sp@-
    moveal IntlSpec,%a2
    cmpaw #-1,%a2
    beqw SMGRINITFONTS_76
    moveb %a2@(6),%sp@-
    sf %a2@(6)
    tstb %a2@(4)
    jbeq SMGRINITFONTS_72
    movew %a2@(38),%d3
    movew %d3,%d0
    lslw #2,%d0
    moveal %a2@(0x72,%d0:w),%a3
    clrw %sp@-
    movew SysFontFam,%sp@-
    movel #-2113798138,%sp@-
    _ScriptUtil
    cmpw %sp@+,%d3
    jbne SMGRINITFONTS_42
    tstb %a2@(9)
    jbeq SMGRINITFONTS_4E
SMGRINITFONTS_42:       /* the script's system font */
    movew %a3@(8),SysFontFam
    movew #-2,CurFMFamily
SMGRINITFONTS_4E:       /* the application font, if it belongs to another script */
    clrw %sp@-
    movew ApFontID,%sp@-
    movel #-2113798138,%sp@-
    _ScriptUtil
    cmpw %sp@+,%d3
    jbne SMGRINITFONTS_66
    tstb %a2@(9)
    jbeq SMGRINITFONTS_72
SMGRINITFONTS_66:       /* the script's application font */
    movew %a3@(10),ApFontID
    movew #-2,CurFMFamily
SMGRINITFONTS_72:       /* restore the font force flag */
    moveb %sp@+,%a2@(6)
SMGRINITFONTS_76:       /* restore registers, return */
    moveml %sp@+,%d0/%d3/%a0/%a2-%a3
    rts

/* SMGRPOSTMUNGING: after GetOSEvent: keyboard script switching keys. */
SMGRPOSTMUNGING:
    moveml %d0-%d2/%a0-%a4,%sp@-
    moveal IntlSpec,%a4
    moveal %a0,%a2
    moveb %a4@(4),%d0
    cmpib #1,%d0
    jble SMGRPOSTMUNGING_6A
    cmpiw #1,%a2@
    jbne SMGRPOSTMUNGING_2E
    subqw #2,%sp
    movel %a2@(10),%sp@-
    pea %a4@(44)
    _PtInRect
    tstb %sp@+
    jbeq SMGRPOSTMUNGING_6A
    moveq #-1,%d0
    jbra SMGRPOSTMUNGING_5A
SMGRPOSTMUNGING_2E:     /* key-down or auto-key events only */
    cmpiw #3,%a2@
    jbeq SMGRPOSTMUNGING_3A
    cmpiw #5,%a2@
    jbne SMGRPOSTMUNGING_6A
SMGRPOSTMUNGING_3A:     /* modifiers and key code: look them up in the keyboard-switch table (+54) */
    movel %a2@(2),%d1
    moveb %a2@(14),%d1
    andiw #-5,%d1
    movel %a4@(54),%d0
    jbeq SMGRPOSTMUNGING_6A
    moveal %d0,%a0
    moveal %a0@,%a0
SMGRPOSTMUNGING_50:     /* next entry; match: the script to switch to */
    movel %a0@+,%d0
    jbeq SMGRPOSTMUNGING_6A
    cmpw %d0,%d1
    jbne SMGRPOSTMUNGING_50
    swap %d0
SMGRPOSTMUNGING_5A:     /* _KeyScript to it; the event becomes a null event */
    movew %d0,%sp@-
    movel #-2147352572,%sp@-
    _ScriptUtil
    clrw %a2@
    movel MinusOne,%sp@
SMGRPOSTMUNGING_6A:     /* restore registers, return */
    moveml %sp@+,%d0-%d2/%a0-%a4
    rts
    .long   0x00000000, 0x00000000	| 4081E308

/* STDUNLINK: standard unlink exit. */
STDUNLINK:
    unlk %fp

/* STDEXIT: standard exit. */
STDEXIT:
    moveal %sp@+,%a0
    addaw %d0,%sp
    jmp %a0@

/* XSCRIPTUTIL: _ScriptUtil: the Script Manager selectors. */
trap_ScriptUtil:
XSCRIPTUTIL:
    movel %sp@(4),%d0
    bclr #31,%d0
    jbne XSCRIPTUTIL_1C
    moveal %sp@+,%a0
    swap %d0
    lsrw #1,%d0
    moveb %pc@(UTILTABLE_10,%d0:w),%d0
    movew %d0,%sp@
    movew %pc@(UTILTABLE_22,%d0:w),%sp@-
    movel %a0,%sp@-
XSCRIPTUTIL_1C:         /* routine selector: through the Script Manager's dispatch table (+82), range checked */
    moveal IntlSpec,%a0
    cmpw %a0@(88),%d0
    jbgt UTILTABLE_44
    cmpw %a0@(86),%d0
    jblt BITBUCKET
    addw %d0,%d0
    moveal %a0@(82),%a0
    moveal %a0@(0x0,%d0:w),%a0
    jmp %a0@

/* UTILTABLEBASE: ScriptUtil selector table. */
UTILTABLEBASE:
    .short  VALIDDATE-UTILTABLE	| 4081E350
    .short  XFORMSTR2X-UTILTABLE	| 4081E352
    .short  APPENDSYMBOL_170-UTILTABLE	| 4081E354
    .short  XFORM2STR-UTILTABLE	| 4081E356
    .short  XSTR2FORM-UTILTABLE	| 4081E358
    .short  TOGGLEDATE-UTILTABLE	| 4081E35A
    .short  LONGSECS2DATE-UTILTABLE	| 4081E35C
    .short  LONGDATE2SECS-UTILTABLE	| 4081E35E
    .short  STRING2TIME-UTILTABLE	| 4081E360
    .short  STRING2DATE-UTILTABLE	| 4081E362
    .short  INITDATECACHE-UTILTABLE	| 4081E364
    .short  INTLTOKENIZE-UTILTABLE	| 4081E366
    .short  FINDCARRIAGE_20-UTILTABLE	| 4081E368
    .short  STYLEDLINEBREAK-UTILTABLE	| 4081E36A
UTILTABLE:              /* the generic ScriptUtil routines (FontScript, IntlScript, KeyScript, Font2Script, Get/SetEnvirons, Get/SetScript) */
    .short  BITBUCKETREG_1A-UTILTABLE	| 4081E36C
    .short  BITBUCKETREG_40-UTILTABLE	| 4081E36E
    .short  BITBUCKETREG_DE-UTILTABLE	| 4081E370
    .short  BITBUCKETREG_6C-UTILTABLE	| 4081E372
    .short  BITBUCKETREG_1B2-UTILTABLE	| 4081E374
    .short  BITBUCKETREG_1F2-UTILTABLE	| 4081E376
    .short  BITBUCKETREG_262-UTILTABLE	| 4081E378
    .short  BITBUCKETREG_2D6-UTILTABLE	| 4081E37A
UTILTABLE_10:           /* per selector: index into the generic table */
    .long   0x10121416	| 4081E37C
    .short  0x181A, 0x1C1E, 0x200C, 0x0E08, 0x0A00, 0x0204, 0x0600	| 4081E380
UTILTABLE_22:           /* per selector: argument bytes and result size */
    .short  0x0200	| 4081E38E
    .long   0x02000002, 0x02020402, 0x02060404, 0x02080206	| 4081E390
    .long   0x0206020E, 0x020C020E, 0x0012000E, 0x0008000C	| 4081E3A0
UTILTABLE_44:           /* script-specific selector: through the current font script's dispatch (+36) */
    subqw #6,%sp
    jbsr BITBUCKETREG_1A
    addqw #2,%sp
    moveal %a0@(36),%a0
    jmp %a0@

/* BITBUCKET: unimplemented selector: no-op. */
BITBUCKET:
    moveal %sp@+,%a0
    movel %sp@+,%d0

/* BITBUCKETREG: unimplemented selector (register based): no-op. */
BITBUCKETREG:
    swap %d0
    moveq #0,%d1
    moveb %d0,%d1
    lsrw #8,%d0
    andiw #127,%d0
    addaw %d1,%sp
    moveal %sp,%a1
    jbra BITBUCKETREG_14
BITBUCKETREG_12:        /* clear the result */
    clrb %a1@+
BITBUCKETREG_14:        /* next byte; return */
    dbf %d0,BITBUCKETREG_12
    jmp %a0@

/* FONTSCRIPT (BITBUCKETREG_1A): _FontScript: the script of the current port's font. */
BITBUCKETREG_1A:        /* FontScript */
    tstb QDExist
    jbeq BITBUCKETREG_24
BITBUCKETREG_20:        /* no QuickDraw or no port: font 0 */
    moveq #0,%d0
    jbra BITBUCKETREG_30
BITBUCKETREG_24:        /* the port's txFont (+68) */
    movel %a5@,%d0
    jble BITBUCKETREG_20
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %a0@(68),%d0
BITBUCKETREG_30:        /* no override (IntlForce ignored) */
    moveal IntlSpec,%a1
    moveq #0,%d1
    moveb %a1@(6),%d1
    movel %sp@+,%d2
    addql #4,%sp
    jbra BITBUCKETREG_7C
/* INTLSCRIPT (BITBUCKETREG_40): _IntlScript: the script of the current font, or the system
 script if IntlForce is set. */
BITBUCKETREG_40:        /* IntlScript */
    tstb QDExist
    jbeq BITBUCKETREG_4A
BITBUCKETREG_46:        /* no port: font 0 */
    moveq #0,%d0
    jbra BITBUCKETREG_56
BITBUCKETREG_4A:        /* the port's txFont */
    movel %a5@,%d0
    jble BITBUCKETREG_46
    moveal %d0,%a0
    moveal %a0@,%a0
    movew %a0@(68),%d0
BITBUCKETREG_56:        /* font force and IntlForce flags */
    moveal IntlSpec,%a1
    moveb %a1@(7),%d1
    extw %d1
    extl %d1
    orb %a1@(6),%d1
    movel %sp@+,%d2
    addql #4,%sp
    jbra BITBUCKETREG_7C
/* FONT2SCRIPT (BITBUCKETREG_6C): _Font2Script: the script of a font number. */
BITBUCKETREG_6C:        /* Font2Script */
    movel %sp@+,%d2	| 4081E42C
    addql #4,%sp	| 4081E42E
    moveal IntlSpec,%a1
    moveq #0,%d1
    moveb %a1@(6),%d1
    movew %sp@+,%d0
BITBUCKETREG_7C:        /* font 0 = system font, 1 = application font */
    clrw %a1@(8)
    cmpiw #1,%d0
    jbhi BITBUCKETREG_92
    jbcs BITBUCKETREG_8E
    movew ApFontID,%d0
    jbra BITBUCKETREG_92
BITBUCKETREG_8E:        /* the system font */
    movew SysFontFam,%d0
BITBUCKETREG_92:        /* font numbers from 0x4000 up: script = ((font - 0x4000) >> 9) + 1 */
    subiw #16384,%d0
    jbmi BITBUCKETREG_AC
    movew #9,%d1
    lsrw %d1,%d0
    addqw #1,%d0
    tstl %d1
    jbpl BITBUCKETREG_BA
    cmpw %a1@(38),%d0
    jbne BITBUCKETREG_B2
    jbra BITBUCKETREG_BA
BITBUCKETREG_AC:        /* Roman font */
    moveq #0,%d0
    tstb %d1
    jbeq BITBUCKETREG_BA
BITBUCKETREG_B2:        /* forced: the system script */
    st %a1@(8)
    movew %a1@(38),%d0
BITBUCKETREG_BA:        /* the script must be installed and enabled */
    movew %d0,%d1
    lslw #2,%d1
    movel %a1@(0x72,%d1:w),%d1
    jbeq BITBUCKETREG_CC
    moveal %d1,%a0
    tstb %a0@(4)
    jbne BITBUCKETREG_D8
BITBUCKETREG_CC:        /* otherwise Roman */
    movew #255,%a1@(8)
    clrw %d0
    moveal %a1@(114),%a0
BITBUCKETREG_D8:        /* return the script */
    movew %d0,%sp@
    moveal %d2,%a1
    jmp %a1@
/* KEYSCRIPT (BITBUCKETREG_DE): _KeyScript: switch the keyboard script.
 -1 = next script, -2 = system script, -3 = last key script (the next one if that is the current); 0..64 by number. */
BITBUCKETREG_DE:        /* KeyScript */
    linkw %fp,#0	| 4081E49E
    movel %a2,%sp@-	| 4081E4A2
    moveal IntlSpec,%a2	| 4081E4A4
    tstb %a2@(4)	| 4081E4A8
    jbeq BITBUCKETREG_1A8	| 4081E4AC
    movel %a2@(374),%d0	| 4081E4B0
    jbeq BITBUCKETREG_100	| 4081E4B4
    moveal %d0,%a0	| 4081E4B6
    _DisposHandle	| 4081E4B8
    lea %a2@(374),%a0	| 4081E4BA
    clrl %a0@	| 4081E4BE
BITBUCKETREG_100:       /* the script's 'itlk' (resource ID from GetScript verb 32, if any) kept at +374 */
    clrl %sp@-	| 4081E4C0
    movew %fp@(12),%sp@-	| 4081E4C2
    movew #32,%sp@-	| 4081E4C6
    movel #-2080112628,%sp@-	| 4081E4CA
    _ScriptUtil	| 4081E4D0
    movel %sp@+,%d0	| 4081E4D2
    jblt BITBUCKETREG_130	| 4081E4D4
    clrl %sp@-	| 4081E4D6
    movel #1769237611,%sp@-	| 4081E4D8
    movew %d0,%sp@-	| 4081E4DE
    _GetResource	| 4081E4E0
    movel %sp@+,%d0	| 4081E4E2
    jbeq BITBUCKETREG_130	| 4081E4E4
    lea %a2@(374),%a0	| 4081E4E6
    movel %d0,%a0@	| 4081E4EA
    movel %d0,%sp@-	| 4081E4EC
    _DetachResource	| 4081E4EE
BITBUCKETREG_130:       /* decode the verb */
    movew %fp@(12),%d1	| 4081E4F0
    cmpiw #65,%d1	| 4081E4F4
    jbge BITBUCKETREG_1A8	| 4081E4F8
    addqw #1,%d1	| 4081E4FA
    jbeq BITBUCKETREG_170	| 4081E4FC
    movew %a2@(38),%d0	| 4081E4FE
    addqw #1,%d1	| 4081E502
    jbeq BITBUCKETREG_15C	| 4081E504
    movew %a2@(40),%d0	| 4081E506
    addqw #1,%d1	| 4081E50A
    jblt BITBUCKETREG_1A8	| 4081E50C
    jbne BITBUCKETREG_158	| 4081E50E
    cmpw %a2@(42),%d0	| 4081E510
    jbeq BITBUCKETREG_170	| 4081E514
    jbra BITBUCKETREG_15C	| 4081E516
BITBUCKETREG_158:       /* an explicit script number */
    movew %fp@(12),%d0	| 4081E518
BITBUCKETREG_15C:       /* must be installed and enabled */
    movew %d0,%d1	| 4081E51C
    lslw #2,%d1	| 4081E51E
    movel %a2@(0x72,%d1:w),%d1	| 4081E520
    jbeq BITBUCKETREG_1A8	| 4081E524
    moveal %d1,%a0	| 4081E526
    tstb %a0@(4)
    jbeq BITBUCKETREG_1A8
    jbra BITBUCKETREG_190
BITBUCKETREG_170:       /* next script after the current key script */
    movew %a2@(42),%d0	| 4081E530
BITBUCKETREG_174:       /* loop: next enabled script, wrapping to 0 */
    addqw #1,%d0
    cmpiw #65,%d0
    jblt BITBUCKETREG_17E
    moveq #0,%d0
BITBUCKETREG_17E:       /* installed and enabled? */
    movew %d0,%d1
    lslw #2,%d1
    movel %a2@(0x72,%d1:w),%d1
    jbeq BITBUCKETREG_174
    moveal %d1,%a0
    tstb %a0@(4)
    jbeq BITBUCKETREG_174
BITBUCKETREG_190:       /* switch: last = old, key = new; new keyboard layout and menu-bar icon */
    movew %a2@(42),%d1
    movew %d1,%a2@(40)
    movew %d0,%a2@(42)
    addqw #1,%a2@(2)
    jbsr SWAPKYBD
    jbsr SWAPICON
BITBUCKETREG_1A8:       /* return */
    moveal %sp@+,%a2
    movew #6,%d0
    jbra STDUNLINK

/* GETENVIRONS (BITBUCKETREG_1B2): _GetEnvirons: a Script Manager variable (verbs 0..34),
 through the offset/size table. */
BITBUCKETREG_1B2:       /* GetEnvirons */
    linkw %fp,#0
    moveq #0,%d0
    moveal IntlSpec,%a1
    movew %fp@(12),%d2
    cmpiw #34,%d2
    jbhi BITBUCKETREG_1E6
    lea %pc@(BITBUCKETREG_23E),%a0
    moveq #0,%d1
    addaw %d2,%a0
    moveb %a0@+,%d1
    lea %a1@(0x0,%d1:w),%a1
    moveb %a0@,%d1
    subqw #2,%d1
    jbmi BITBUCKETREG_1E0
    jbeq BITBUCKETREG_1E4
    movel %a1@,%d0
    jbra BITBUCKETREG_1E6
BITBUCKETREG_1E0:       /* byte value */
    moveb %a1@,%d0
    jbra BITBUCKETREG_1E6
BITBUCKETREG_1E4:       /* word value */
    movew %a1@,%d0
BITBUCKETREG_1E6:       /* return the value */
    movel %d0,%fp@(14)
    movew #6,%d0
    jbra STDUNLINK

/* SETENVIRONS (BITBUCKETREG_1F2): _SetEnvirons: set a Script Manager variable; bumps the
 globals' modification count. */
BITBUCKETREG_1F2:       /* SetEnvirons */
    linkw %fp,#0
    movew #-1,%fp@(18)
    moveal IntlSpec,%a1
    movew %fp@(16),%d2
    cmpiw #34,%d2
    jbhi BITBUCKETREG_236
    addqw #1,%a1@(2)
    lea %pc@(BITBUCKETREG_23E),%a0
    moveq #0,%d1
    addaw %d2,%a0
    moveb %a0@+,%d1
    lea %a1@(0x0,%d1:w),%a1
    moveb %a0@,%d1
    movel %fp@(12),%d0
    subqw #2,%d1
    jbmi BITBUCKETREG_22C
    jbeq BITBUCKETREG_230
    movel %d0,%a1@
    jbra BITBUCKETREG_232
BITBUCKETREG_22C:       /* byte value */
    moveb %d0,%a1@
    jbra BITBUCKETREG_232
BITBUCKETREG_230:       /* word value */
    movew %d0,%a1@
BITBUCKETREG_232:       /* noErr */
    clrw %fp@(18)
BITBUCKETREG_236:       /* return */
    movew #10,%d0
    jbra STDUNLINK
BITBUCKETREG_23E:       /* GetEnvirons/SetEnvirons verbs: offset into the globals and size, per verb */
    .short  0x0002, 0x0202	| 4081E5FE orib #2,%d2
    .short  0x0401, 0x0501	| 4081E602 subib #1,%d1
    .short  0x0601, 0x0701	| 4081E606 addib #1,%d1
    .short  0x0801, 0x0901	| 4081E60A btst #1,%d1
    moveb %d4,%d3	| 4081E60E
    movel %d2,%d3	| 4081E610
    movel %d2,%d4	| 4081E612
    movel %d2,%d5	| 4081E614
    movew %d2,%d2	| 4081E616
    movew %d4,%d6	| 4081E618
    movew %d4,%d3	| 4081E61A
    .short  0x0A04, 0x0E04	| 4081E61C eorib #4,%d4
    movew %d2,%d5	| 4081E620
/* GETSCRIPT (BITBUCKETREG_262): _GetScript: a variable of a script record. Verbs 46..76
 are passed to the script's own routine. */
BITBUCKETREG_262:       /* GetScript */
    linkw %fp,#0	| 4081E622
    movew %fp@(14),%d0	| 4081E626
    cmpiw #64,%d0
    jbhi BITBUCKETREG_292
    moveal IntlSpec,%a0
    lslw #2,%d0
    movel %a0@(0x72,%d0:w),%d0
    jbeq BITBUCKETREG_292
    moveal %d0,%a1
    tstb %a1@(4)
    jbeq BITBUCKETREG_292
    movew %fp@(12),%d2
    jbge BITBUCKETREG_296
BITBUCKETREG_28A:       /* script-specific verb: the script's dispatch (+36) */
    moveal %a1@(36),%a0
    unlk %fp
    jmp %a0@
BITBUCKETREG_292:       /* script not installed: 0 */
    moveq #0,%d0
    jbra BITBUCKETREG_2CA
BITBUCKETREG_296:       /* verbs 46..76 belong to the script */
    cmpiw #46,%d2
    jblt BITBUCKETREG_2A2
    cmpiw #76,%d2
    jble BITBUCKETREG_28A
BITBUCKETREG_2A2:       /* generic verbs up to 84: through the offset/size table */
    cmpiw #84,%d2
    jbhi BITBUCKETREG_2CA
    lea %pc@(BITBUCKETREG_358),%a0
    moveq #0,%d1
    addaw %d2,%a0
    moveb %a0@+,%d1
    lea %a1@(0x0,%d1:w),%a1
    moveb %a0@,%d1
    moveq #0,%d0
    subqw #2,%d1
    jbmi BITBUCKETREG_2C4
    jbeq BITBUCKETREG_2C8
    movel %a1@,%d0
    jbra BITBUCKETREG_2CA
BITBUCKETREG_2C4:       /* byte value */
    moveb %a1@,%d0
    jbra BITBUCKETREG_2CA
BITBUCKETREG_2C8:       /* word value */
    movew %a1@,%d0
BITBUCKETREG_2CA:       /* return the value */
    movel %d0,%fp@(16)
    movew #8,%d0
    jbra STDUNLINK

/* SETSCRIPT (BITBUCKETREG_2D6): _SetScript: set a variable of a script record. */
BITBUCKETREG_2D6:       /* SetScript */
    linkw %fp,#0
    movew %fp@(18),%d0
    cmpiw #64,%d0
    jbhi BITBUCKETREG_34E
    moveal IntlSpec,%a0
    lslw #2,%d0
    movel %a0@(0x72,%d0:w),%d0
    jbeq BITBUCKETREG_34E
    moveal %d0,%a1
    tstb %a1@(4)
    jbeq BITBUCKETREG_34E
    movew %fp@(16),%d2
    jbge BITBUCKETREG_306
BITBUCKETREG_2FE:       /* script-specific verb: the script's dispatch */
    moveal %a1@(36),%a0
    unlk %fp
    jmp %a0@
BITBUCKETREG_306:       /* verbs 46..76 belong to the script */
    cmpiw #46,%d2
    jblt BITBUCKETREG_312
    cmpiw #76,%d2
    jble BITBUCKETREG_2FE
BITBUCKETREG_312:       /* generic verbs up to 84 */
    cmpiw #84,%d2
    jbhi BITBUCKETREG_354
    addqw #1,%a1@(2)
    lea %pc@(BITBUCKETREG_358),%a0
    moveq #0,%d1
    addaw %d2,%a0
    moveb %a0@+,%d1
    lea %a1@(0x0,%d1:w),%a1
    moveb %a0@,%d1
    movel %fp@(12),%d0
    subqw #2,%d1
    jbmi BITBUCKETREG_33A
    jbeq BITBUCKETREG_33E
    movel %d0,%a1@
    jbra BITBUCKETREG_340
BITBUCKETREG_33A:       /* byte value */
    moveb %d0,%a1@
    jbra BITBUCKETREG_340
BITBUCKETREG_33E:       /* word value */
    movew %d0,%a1@
BITBUCKETREG_340:       /* noErr */
    moveq #0,%d0
BITBUCKETREG_342:       /* return the result */
    movew %d0,%fp@(20)
    movew #12,%d0
    jbra STDUNLINK
BITBUCKETREG_34E:       /* smBadScript (-2) */
    movew #-2,%d0
    jbra BITBUCKETREG_342
BITBUCKETREG_354:       /* smBadVerb (-1) */
    moveq #-1,%d0
    jbra BITBUCKETREG_342
BITBUCKETREG_358:       /* GetScript/SetScript verbs: offset into the script record and size, per verb */
    .long   0x00020202, 0x04010501	| 4081E718
    .long   0x06010701, 0x08020A02, 0x0C020E02, 0x10021202	| 4081E720
    .long   0x14021602, 0x18021A02, 0x1C021E02, 0x20042404	| 4081E730
    .long   0x28042C04, 0x30040000, 0x00000000, 0x00000000	| 4081E740

/* MONTHSTARTS: day of the year at the start of each month. */
MONTHSTARTS:
    .long   0x0000001F, 0x003B005A, 0x00780097, 0x00B500D4	| 4081E750
    .short  0x00F3, 0x0111, 0x0130, 0x014E, 0x03E8	| 4081E760

/* LEAPSTARTS: the same for leap years. */
LEAPSTARTS:
    .short  0x0000, 0x001F, 0x003C	| 4081E76A
    .long   0x005B0079, 0x009800B6, 0x00D500F4, 0x01120131	| 4081E770
    .short  0x014F, 0x03E8, 0x400F	| 4081E780

/* SECSINDAYX: seconds in a day. */
SECSINDAYX:
    .short  0x400F, 0xA8C0, 0x0000, 0x0000, 0x0000	| 4081E786
    .short  0x401E	| 4081E790

/* MAXOLDDATE: largest date in the old (32-bit) format. */
MAXOLDDATE:
    .short  0x401E, 0xFFFF, 0xFFFF, 0x0000, 0x0000	| 4081E792

/* MAXVAL: limit. */
MAXVAL:
    .long   0x00000096	| 4081E79C
    .long   0x000D0023, 0x0018003C, 0x003C0007, 0x0190003C	| 4081E7A0

/* VALIDDATE: _ValidDate: check a date record. */
VALIDDATE:
    linkw %fp,#-28	| 4081E7B0
    moveml %d3/%a2-%a4,%sp@-	| 4081E7B4
    movew #1,%d3	| 4081E7B8
    moveal %fp@(12),%a2	| 4081E7BC
    lea %fp@(-28),%a3	| 4081E7C0
    moveal %fp@(20),%a4	| 4081E7C4
    movel %a4,%sp@-	| 4081E7C8
    movel %a2,%sp@-	| 4081E7CA
    movel #-2146893838,%sp@-	| 4081E7CC
    _ScriptUtil	| 4081E7D2
    movel %fp@(16),%d0	| 4081E7D4
    btst #31,%d0	| 4081E7D8
    jbeq VALIDDATE_4C	| 4081E7DC
    tstl %a2@	| 4081E7DE
    jbne VALIDDATE_7E	| 4081E7E0
    btst #27,%d0	| 4081E7E2
    jbeq VALIDDATE_4C	| 4081E7E6
    cmpil #504921600,%a2@(4)	| 4081E7E8
    jbcs VALIDDATE_7E	| 4081E7F0
    cmpil #-634285703,%a2@(4)	| 4081E7F2
    jbhi VALIDDATE_7E	| 4081E7FA
VALIDDATE_4C:           /* convert back (LongSecs2Date) and compare field by field */
    movel %a2,%sp@-	| 4081E7FC
    movel %a3,%sp@-	| 4081E7FE
    movel #-2146893840,%sp@-	| 4081E800
    _ScriptUtil	| 4081E806
    movel %fp@(16),%d2	| 4081E808
    movew #-1,%d3	| 4081E80C
    addaw #22,%a4	| 4081E810
    addaw #22,%a3	| 4081E814
    moveq #10,%d1	| 4081E818
VALIDDATE_6A:           /* from the last field: the first that changed and is not ignored by the mask */
    movew %a3@-,%d0	| 4081E81A
    cmpw %a4@-,%d0	| 4081E81C
    dbne %d1,VALIDDATE_6A	| 4081E81E
    jbeq VALIDDATE_7E	| 4081E822
    btst %d1,%d2	| 4081E824
    dbne %d1,VALIDDATE_6A	| 4081E826
    jbeq VALIDDATE_7E	| 4081E82A
    movew %d1,%d3	| 4081E82C
VALIDDATE_7E:           /* return the field that was out of range (-1 = valid) */
    movew %d3,%fp@(24)	| 4081E82E
    moveml %sp@+,%d3/%a2-%a4	| 4081E832
    movew #16,%d0	| 4081E836
    jbra STDUNLINK	| 4081E83A
    .byte   0x08	| 4081E83E
    .ascii  "VALIDDAT\000"
    .long   0x00000000, 0x00000000	| 4081E848

/* TOGGLEDATE: _ToggleDate: step a date field (as in the Alarm Clock). */
TOGGLEDATE:
    linkw %fp,#-96	| 4081E850
    moveml %d3-%d7/%a2-%a4,%sp@-	| 4081E854
    moveb %fp@(18),%d3	| 4081E858
    extw %d3	| 4081E85C
    moveq #0,%d4	| 4081E85E
    moveb %fp@(20),%d4	| 4081E860
    movew %d4,%d0	| 4081E864
    addw %d0,%d0	| 4081E866
    lea %fp@(-28,%d0:w),%a2	| 4081E868
    lea %pc@(MAXVAL),%a4	| 4081E86C
    moveal %fp@(12),%a0	| 4081E870
    movel %a0@,%d0	| 4081E874
    andiw #127,%d0	| 4081E876
    btst #28,%d0	| 4081E87A
    jbeq TOGGLEDATE_34	| 4081E87E
    oriw #1024,%d0	| 4081E880
TOGGLEDATE_34:          /* the date as fields; error if it cannot be converted */
    movel %d0,%fp@(-96)	| 4081E884
    movel %fp@(22),%sp@-	| 4081E888
    pea %fp@(-28)	| 4081E88C
    movel #-2146893840,%sp@-	| 4081E890
    _ScriptUtil	| 4081E896
    tstw %fp@(-28)	| 4081E898
    jblt TOGGLEDATE_2DC	| 4081E89C
    movew #7,%fp@(26)	| 4081E8A0
    movel %fp@(-96),%d0	| 4081E8A6
    btst #31,%d0	| 4081E8AA
    jbeq TOGGLEDATE_92	| 4081E8AE
    moveal %fp@(22),%a0	| 4081E8B0
    tstl %a0@	| 4081E8B4
    jbne TOGGLEDATE_2F4	| 4081E8B6
    btst #27,%d0	| 4081E8BA
    jbeq TOGGLEDATE_92	| 4081E8BE
    cmpil #504921600,%a0@(4)	| 4081E8C0
    jbcs TOGGLEDATE_8C	| 4081E8C8
    cmpil #-634285703,%a0@(4)	| 4081E8CA
    jbls TOGGLEDATE_92	| 4081E8D2
    subiw #100,%fp@(-26)	| 4081E8D4
    jbra TOGGLEDATE_92	| 4081E8DA
TOGGLEDATE_8C:          /* two-digit years: add 100 */
    addiw #100,%fp@(-26)	| 4081E8DC
TOGGLEDATE_92:          /* the step must be -1, 0 or +1 (else 3); the AM/PM field goes by character or by toggling */
    movew #3,%fp@(26)	| 4081E8E2
    movew %d3,%d0	| 4081E8E8
    subqw #1,%d0	| 4081E8EA
    jbgt TOGGLEDATE_B6	| 4081E8EC
    addqw #2,%d0	| 4081E8EE
    jblt TOGGLEDATE_B6	| 4081E8F0
    movew #2,%fp@(26)	| 4081E8F2
    cmpiw #10,%d4	| 4081E8F8
    jbne TOGGLEDATE_BA	| 4081E8FC
    tstw %d3	| 4081E8FE
    jbeq TOGGLEDATE_C6	| 4081E900
    jbra TOGGLEDATE_238	| 4081E902
TOGGLEDATE_B6:          /* return */
    jbra TOGGLEDATE_2F4	| 4081E906
TOGGLEDATE_BA:          /* fields 1..6 only */
    cmpiw #1,%d4	| 4081E90A
    jblt TOGGLEDATE_B6	| 4081E90E
    cmpiw #6,%d4	| 4081E910
    jbgt TOGGLEDATE_B6	| 4081E914
TOGGLEDATE_C6:          /* a character: AM/PM strings or a digit */
    tstw %d3	| 4081E916
    jbne TOGGLEDATE_28C	| 4081E918
    movew #4,%fp@(26)	| 4081E91C
    lea %fp@(16),%a0	| 4081E922
    moveq #2,%d0	| 4081E926
    .short  0xA456	| 4081E928 _LwrString (flags 0x0400)
    movew %a0@,%d6	| 4081E92A
    jbeq TOGGLEDATE_B6	| 4081E92C
    cmpiw #10,%d4	| 4081E92E
    jbne TOGGLEDATE_100	| 4081E932
    moveal %fp@(12),%a0	| 4081E934
    addqw #8,%a0	| 4081E938
    cmpiw #12,%fp@(-20)	| 4081E93A
    jblt TOGGLEDATE_F4	| 4081E940
    subqw #4,%a0	| 4081E942
TOGGLEDATE_F4:          /* compare with the AM/PM characters */
    moveq #3,%d1	| 4081E944
TOGGLEDATE_F6:          /* loop: next character */
    cmpb %a0@+,%d6	| 4081E946
    dbeq %d1,TOGGLEDATE_F6	| 4081E948
    jbeq TOGGLEDATE_238	| 4081E94C
TOGGLEDATE_100:         /* a digit: shift it into the field's value */
    movew #6,%fp@(26)	| 4081E950
    cmpiw #255,%d6	| 4081E956
    jbhi TOGGLEDATE_234	| 4081E95A
    andiw #127,%d6	| 4081E95E
    cmpiw #48,%d6	| 4081E962
    jbcs TOGGLEDATE_234	| 4081E966
    cmpiw #57,%d6	| 4081E96A
    jbhi TOGGLEDATE_234	| 4081E96E
    andib #15,%d6	| 4081E972
    movew %a2@,%d5	| 4081E976
    cmpiw #4,%d4	| 4081E978
    bnes TOGGLEDATE_15C
    movel %fp@(-96),%d1
    btst #30,%d1
    jbeq TOGGLEDATE_15C
    btst #29,%d1
    jbeq TOGGLEDATE_14A
    cmpiw #12,%d5
    jblt TOGGLEDATE_15C
    subiw #12,%d5
    jbra TOGGLEDATE_15C
TOGGLEDATE_14A:         /* 12-hour clock: hours 13..23 shown as 1..11 */
    cmpiw #12,%d5
    jble TOGGLEDATE_156
    subiw #12,%d5
    jbra TOGGLEDATE_15C
TOGGLEDATE_156:         /* hour 0 shown as 12 */
    tstw %d5
    jbne TOGGLEDATE_15C
    moveq #12,%d5
TOGGLEDATE_15C:         /* keep the top digits (century), shift in the new digit */
    movew %d5,%d1
    extl %d1
    divsw #100,%d1
    swap %d1
    movew %d5,%d7
    subw %d1,%d7
    subw %d7,%d5
    jbge TOGGLEDATE_170
    negw %d6
TOGGLEDATE_170:         /* times 10, two digits kept */
    mulsw #10,%d5
    cmpiw #100,%d5
    jblt TOGGLEDATE_180
    divsw #100,%d5
    swap %d5
TOGGLEDATE_180:         /* new value; hours: back to 24-hour, with the AM/PM state */
    movew %d7,%d0
    addw %d5,%d0
    addw %d6,%d0
    cmpiw #4,%d4
    jbne TOGGLEDATE_1D6
    movel %fp@(-96),%d1
    btst #30,%d1
    jbeq TOGGLEDATE_1D6
    btst #29,%d1
    jbeq TOGGLEDATE_1AE
    cmpiw #12,%d0
    jbge TOGGLEDATE_1D2
    tstw %fp@(-8)
    jbeq TOGGLEDATE_1D6
    addiw #12,%d0
    jbra TOGGLEDATE_1D6
TOGGLEDATE_1AE:         /* PM */
    tstw %d0
    jbeq TOGGLEDATE_1D2
    tstw %fp@(-8)
    jbeq TOGGLEDATE_1C6
    cmpiw #12,%d0
    jbeq TOGGLEDATE_1D6
    jbgt TOGGLEDATE_1D2
    addiw #12,%d0
    jbra TOGGLEDATE_1D6
TOGGLEDATE_1C6:         /* AM */
    cmpiw #12,%d0
    jbgt TOGGLEDATE_1D2
    jblt TOGGLEDATE_1D6
    clrw %d0
    jbra TOGGLEDATE_1D6
TOGGLEDATE_1D2:         /* invalid */
    movew #-1,%d0
TOGGLEDATE_1D6:         /* store it and validate; a year with the 32-bit limit option: back or forward a century */
    movew %d0,%a2@
    jbsr TOGGLEDATE_25E
    jblt TOGGLEDATE_2E0
    cmpiw #1,%d4
    jbne TOGGLEDATE_222
    movel %fp@(-96),%d0
    btst #31,%d0
    jbeq TOGGLEDATE_222
    btst #27,%d0
    jbeq TOGGLEDATE_222
    tstl %fp@(-92)
    jbmi TOGGLEDATE_218
    jbne TOGGLEDATE_212
    cmpil #504921600,%fp@(-88)
    jbcs TOGGLEDATE_218
    cmpil #-634285703,%fp@(-88)
    jbls TOGGLEDATE_222
TOGGLEDATE_212:         /* down a century */
    subiw #100,%a2@
    jbra TOGGLEDATE_21C
TOGGLEDATE_218:         /* up a century */
    addiw #100,%a2@
TOGGLEDATE_21C:         /* validate */
    jbsr TOGGLEDATE_25E
    jblt TOGGLEDATE_2E0
TOGGLEDATE_222:         /* try with fewer digits */
    tstw %d5
    jbne TOGGLEDATE_170
    tstw %d6
    jbeq TOGGLEDATE_234
    movew %d6,%d5
    clrw %d6
    jbra TOGGLEDATE_170
TOGGLEDATE_234:         /* return */
    jbra TOGGLEDATE_2F4
TOGGLEDATE_238:         /* AM/PM toggled: hour +- 12 */
    movew %fp@(-20),%d0	| 4081EA88
    subiw #12,%d0	| 4081EA8C
    jbge TOGGLEDATE_246	| 4081EA90
    addiw #24,%d0	| 4081EA92
TOGGLEDATE_246:         /* convert back and return */
    movew %d0,%fp@(-20)	| 4081EA96
    pea %fp@(-28)	| 4081EA9A
    movel %fp@(22),%sp@-	| 4081EA9E
    movel #-2146893838,%sp@-	| 4081EAA2
    _ScriptUtil	| 4081EAA8
    jbra TOGGLEDATE_2EE	| 4081EAAA

TOGGLEDATE_25E:         /* ValidDate on the work copy */
    clrw %sp@-
    pea %fp@(-28)
    movel %fp@(-96),%sp@-
    pea %fp@(-92)
    movel #-2113077276,%sp@-
    _ScriptUtil
    movew %sp@+,%d0
    rts
TOGGLEDATE_278:         /* save the work copy */
    lea %fp@(-28),%a0	| 4081EAC8
    lea %fp@(-56),%a1	| 4081EACC
TOGGLEDATE_280:         /* copy 14 words */
    movew #13,%d0	| 4081EAD0

TOGGLEDATE_284:         /* loop */
    movew %a0@+,%a1@+
    dbf %d0,TOGGLEDATE_284
    rts
TOGGLEDATE_28C:         /* add the step; on overflow, carry into the higher fields */
    jbsr TOGGLEDATE_278	| 4081EADC
    addw %d3,%a2@	| 4081EADE
    jbsr TOGGLEDATE_25E	| 4081EAE0
    jblt TOGGLEDATE_2E0	| 4081EAE2
    cmpiw #10,%d0	| 4081EAE4
    jbne TOGGLEDATE_29E	| 4081EAE8
    movew #4,%d0	| 4081EAEA
TOGGLEDATE_29E:         /* wrap: step back by the field's maximum */
    cmpw %d4,%d0	| 4081EAEE
    jble TOGGLEDATE_2B6	| 4081EAF0
    addw %d0,%d0	| 4081EAF2
    lea %fp@(-28,%d0:w),%a3	| 4081EAF4
    movew %a4@(0,%d0:w),%d5	| 4081EAF8
TOGGLEDATE_2AC:         /* loop: decrement until valid */
    subqw #1,%a3@	| 4081EAFC
    jbsr TOGGLEDATE_25E	| 4081EAFE
    dblt %d5,TOGGLEDATE_2AC	| 4081EB00
    jblt TOGGLEDATE_2E0	| 4081EB04
TOGGLEDATE_2B6:         /* restore, wrap the other way */
    lea %fp@(-56),%a0	| 4081EB06
    lea %fp@(-28),%a1	| 4081EB0A
    jbsr TOGGLEDATE_280	| 4081EB0E
    movew %d4,%d0	| 4081EB10
    addw %d0,%d0	| 4081EB12
    movew %a4@(0,%d0:w),%d5	| 4081EB14
    movew %d5,%d0	| 4081EB18
    tstw %d3	| 4081EB1A
    jblt TOGGLEDATE_2D0	| 4081EB1C
    negw %d0	| 4081EB1E
TOGGLEDATE_2D0:         /* apply */
    addw %d0,%a2@	| 4081EB20
TOGGLEDATE_2D2:         /* loop: step until valid */
    addw %d3,%a2@	| 4081EB22
    jbsr TOGGLEDATE_25E	| 4081EB24
    dblt %d5,TOGGLEDATE_2D2	| 4081EB26
    jblt TOGGLEDATE_2E0	| 4081EB2A
TOGGLEDATE_2DC:         /* error: the date could not be converted */
    moveq #5,%d0
    jbra TOGGLEDATE_2F0
TOGGLEDATE_2E0:         /* valid: copy it out */
    lea %fp@(-92),%a0
    moveal %fp@(22),%a1
    movew #4,%d0
    jbsr TOGGLEDATE_284
TOGGLEDATE_2EE:         /* toggle OK */
    moveq #1,%d0
TOGGLEDATE_2F0:         /* the result */
    movew %d0,%fp@(26)
TOGGLEDATE_2F4:         /* restore registers */
    moveml %sp@+,%d3-%d7/%a2-%a4
    movew #18,%d0
    jbra STDUNLINK
    .byte   0x08	| 4081EB50
    .ascii  "TOGGLEDA\000\000\000"
    .long   0x00000000	| 4081EB5C

/* LONGDATE2SECS: _LongDate2Secs: 64-bit date. */
LONGDATE2SECS:
    linkw %fp,#-14	| 4081EB60
    moveml %d3-%d7/%a2,%sp@-	| 4081EB64
    moveal %fp@(16),%a2	| 4081EB68
    lea %a2@,%a0	| 4081EB6C
    movew %a0@+,%d1	| 4081EB6E
    movew %a0@+,%d3	| 4081EB70
    tstw %d1	| 4081EB72
    jbge LONGDATE2SECS_1A	| 4081EB74
    subqw #1,%d3	| 4081EB76
    negw %d3	| 4081EB78
LONGDATE2SECS_1A:       /* years from 2001; month, day, hours, minutes, seconds as seconds of the day */
    subiw #2001,%d3	| 4081EB7A
    movew %a0@+,%d4	| 4081EB7E
    addqw #2,%a0	| 4081EB80
    subqw #1,%d4	| 4081EB82
    moveq #0,%d5	| 4081EB84
    movew %a0@+,%d6	| 4081EB86
    mulsw #60,%d6	| 4081EB88
    addw %a0@+,%d6	| 4081EB8C
    mulsw #60,%d6	| 4081EB8E
    movew %a0@+,%d1	| 4081EB92
    extl %d1	| 4081EB94
    addl %d1,%d6	| 4081EB96
    clrb %fp@(-10)	| 4081EB98
    movew #12,%d7	| 4081EB9C
    cmpw %d7,%d4	| 4081EBA0
    jbcs LONGDATE2SECS_54	| 4081EBA2
    extl %d4	| 4081EBA4
    divsw %d7,%d4	| 4081EBA6
    addw %d4,%d3	| 4081EBA8
    swap %d4	| 4081EBAA
    tstw %d4	| 4081EBAC
    jbge LONGDATE2SECS_54	| 4081EBAE
    subqw #1,%d3	| 4081EBB0
    addw %d7,%d4	| 4081EBB2
LONGDATE2SECS_54:       /* 400-year cycles (146097 days) */
    movew #400,%d7	| 4081EBB4
    cmpw %d7,%d3	| 4081EBB8
    jbcs LONGDATE2SECS_8C	| 4081EBBA
    jbgt LONGDATE2SECS_64	| 4081EBBC
    movew %d7,%d0	| 4081EBBE
    addw %d3,%d0	| 4081EBC0
    jbge LONGDATE2SECS_84	| 4081EBC2
LONGDATE2SECS_64:       /* the cycles, as a 64-bit day count */
    extl %d3	| 4081EBC4
    divsw %d7,%d3	| 4081EBC6
    movew %d3,%d1	| 4081EBC8
    swap %d3	| 4081EBCA
    extl %d1	| 4081EBCC
    movel %d1,%sp@-	| 4081EBCE
    movel #146097,%sp@-	| 4081EBD0
    pea %fp@(-8)	| 4081EBD6
    .short  0xA867	| 4081EBDA _LongMul
    addl %fp@(-4),%d5	| 4081EBDC
    tstw %d3	| 4081EBE0
    jbge LONGDATE2SECS_8C	| 4081EBE2
LONGDATE2SECS_84:       /* negative years: one more cycle back */
    addw %d7,%d3	| 4081EBE4
    subil #146097,%d5	| 4081EBE6
LONGDATE2SECS_8C:       /* last year of a 400-year cycle: leap */
    subqw #1,%d7	| 4081EBEC
    cmpw %d7,%d3	| 4081EBEE
    jbne LONGDATE2SECS_98	| 4081EBF0
    moveb #2,%fp@(-10)	| 4081EBF2
LONGDATE2SECS_98:       /* 100-year periods (36524 days) */
    movew #100,%d7	| 4081EBF8
    cmpw %d7,%d3	| 4081EBFC
    jbcs LONGDATE2SECS_B0	| 4081EBFE
    extl %d3	| 4081EC00
    divuw %d7,%d3	| 4081EC02
    movew %d3,%d1	| 4081EC04
    swap %d3	| 4081EC06
    muluw #18262,%d1	| 4081EC08
    asll #1,%d1	| 4081EC0C
    addl %d1,%d5	| 4081EC0E
LONGDATE2SECS_B0:       /* last year of a century: not leap */
    subqw #1,%d7	| 4081EC10
    cmpw %d7,%d3	| 4081EC12
    jbne LONGDATE2SECS_BA	| 4081EC14
    subqb #1,%fp@(-10)	| 4081EC16
LONGDATE2SECS_BA:       /* 4-year periods (1461 days) */
    moveq #4,%d7	| 4081EC1A
    cmpw %d7,%d3	| 4081EC1C
    jbcs LONGDATE2SECS_CE	| 4081EC1E
    extl %d3	| 4081EC20
    divuw %d7,%d3	| 4081EC22
    movew %d3,%d1	| 4081EC24
    swap %d3	| 4081EC26
    muluw #1461,%d1	| 4081EC28
    addl %d1,%d5	| 4081EC2C
LONGDATE2SECS_CE:       /* last year of 4: leap */
    subqw #1,%d7	| 4081EC2E
    cmpw %d7,%d3	| 4081EC30
    jbne LONGDATE2SECS_D8	| 4081EC32
    addqb #1,%fp@(-10)	| 4081EC34
LONGDATE2SECS_D8:       /* remaining years; month start days (leap table if leap) */
    muluw #365,%d3	| 4081EC38
    addl %d3,%d5	| 4081EC3C
    lea %pc@(MONTHSTARTS),%a0	| 4081EC3E
    tstb %fp@(-10)	| 4081EC42
    jble LONGDATE2SECS_EC	| 4081EC46
    lea %pc@(LEAPSTARTS),%a0	| 4081EC48
LONGDATE2SECS_EC:       /* day of the year from the day of month, or from the week and day of week */
    addw %d4,%d4	| 4081EC4C
    moveq #0,%d0	| 4081EC4E
    movew %a0@(0,%d4:w),%d0	| 4081EC50
    addl %d0,%d5	| 4081EC54
    movew %a2@(6),%d0	| 4081EC56
    jbne LONGDATE2SECS_124	| 4081EC5A
    movew %a2@(16),%d0	| 4081EC5C
    jbne LONGDATE2SECS_124	| 4081EC60
    movew %a2@(18),%d0	| 4081EC62
    subqw #1,%d0	| 4081EC66
    mulsw #7,%d0	| 4081EC68
    movel %d5,%d1	| 4081EC6C
    subql #1,%d1	| 4081EC6E
    divsw #7,%d1	| 4081EC70
    swap %d1	| 4081EC74
    tstw %d1	| 4081EC76
    jbge LONGDATE2SECS_11C	| 4081EC78
    addqw #7,%d1	| 4081EC7A
LONGDATE2SECS_11C:      /* day of week relative to the first day of the year */
    subw %d1,%d0	| 4081EC7C
    addw %a2@(14),%d0	| 4081EC7E
    addqw #1,%d0	| 4081EC82
LONGDATE2SECS_124:      /* days since 1904 (+35429), times 86400, plus the seconds of the day; 64-bit result */
    extl %d0	| 4081EC84
    addil #35429,%d0	| 4081EC86
    addl %d0,%d5	| 4081EC8C
    movel %d5,%sp@-	| 4081EC8E
    movel #86400,%sp@-	| 4081EC90
    movel %fp@(12),%sp@-	| 4081EC96
    .short  0xA867	| 4081EC9A _LongMul
    moveq #0,%d1
    moveal %fp@(12),%a0
    movel %a0@+,%d0
    addl %d6,%a0@
    addxl %d1,%d0
    movel %d0,%a0@-
    moveml %sp@+,%d3-%d7/%a2
    movew #12,%d0
    jbra STDUNLINK
    .byte   8	/* 4081ECB6 Pascal string length */
    .ascii  "LDAT2SEX"	| 4081ECB7
    .byte   0x00	| 4081ECBF

/* LONGSECS2DATE: _LongSecs2Date. */
LONGSECS2DATE:
    linkw %fp,#-24	| 4081ECC0
    moveml %d3-%d7/%a2,%sp@-	| 4081ECC4
    moveal %fp@(12),%a2	| 4081ECC8
    moveq #1,%d4
    moveal %fp@(16),%a0
    movel %a0@+,%d0
    movel %a0@+,%d1
    cmpil #206,%d0
    jbcs LONGSECS2DATE_2C
    jbge LONGSECS2DATE_28
    cmpil #-235,%d0
    jbge LONGSECS2DATE_2C
LONGSECS2DATE_28:       /* out of range: 0 */
    moveq #0,%d0
    moveq #0,%d1
LONGSECS2DATE_2C:       /* days and seconds of the day */
    movel #86400,%d2
    divsl %d2,%d0,%d1
    movel %d1,%d5
    movel %d0,%d6
    jbge LONGSECS2DATE_44
    addil #86400,%d6
    subql #1,%d5
LONGSECS2DATE_44:       /* day of week ((days + 5) mod 7) */
    movel %d5,%d0
    addql #5,%d0
    divsw #7,%d0
    jbvc LONGSECS2DATE_5A
    divsw #16807,%d0
    swap %d0
    extl %d0
    divsw #7,%d0
LONGSECS2DATE_5A:       /* make it positive */
    swap %d0
    tstw %d0
    jbge LONGSECS2DATE_62
    addqw #7,%d0
LONGSECS2DATE_62:       /* day of week 1..7; seconds, minutes, hours */
    addqw #1,%d0
    lea %a2@(14),%a0
    movew %d0,%a0@
    movew #60,%d0
    divuw %d0,%d6
    swap %d6
    movew %d6,%a0@-
    clrw %d6
    swap %d6
    divuw %d0,%d6
    movew %d6,%d0
    swap %d6
    movew %d6,%a0@-
    movew %d0,%a0@-
    lea %a2@(20),%a0
    cmpiw #12,%d0
    sge %d0
    negb %d0
    movew %d0,%a0@+
    clrl %a0@+
    subil #35430,%d5
    moveq #0,%d3
    movel #146097,%d7
    cmpl %d7,%d5
    jbcs LONGSECS2DATE_D0
    jbgt LONGSECS2DATE_AC
    movel %d7,%d0
    addl %d5,%d0
    jbge LONGSECS2DATE_C4
LONGSECS2DATE_AC:       /* 400-year cycles */
    movel %d7,%d2
    movel %d5,%d1
    slt %d0
    extw %d0
    extl %d0
    divsl %d2,%d0,%d1
    mulsw #400,%d1
    addl %d1,%d3
    movel %d0,%d5
    jbge LONGSECS2DATE_D0
LONGSECS2DATE_C4:       /* negative: one more cycle back */
    addil #146097,%d5
    subil #400,%d3
LONGSECS2DATE_D0:       /* centuries */
    clrw %d0
    movel #36524,%d7
    cmpl %d7,%d5
    jblt LONGSECS2DATE_102
    movel %d5,%d1
    divuw #-29012,%d5
    movew %d5,%d0
    clrw %d5
    swap %d5
    muluw #100,%d0
    cmpiw #300,%d0
    jblt LONGSECS2DATE_102
    jbeq LONGSECS2DATE_100
    subil #100,%d0
    addil #36524,%d5
LONGSECS2DATE_100:      /* century year: not leap */
    addqb #2,%d4
LONGSECS2DATE_102:      /* 4-year periods */
    addw %d0,%d3
    divuw #1461,%d5
    movew %d5,%d0
    aslw #2,%d0
    swap %d5
    cmpiw #96,%d0
    jbne LONGSECS2DATE_116
    subqb #1,%d4
LONGSECS2DATE_116:      /* years within the period */
    addl %d0,%d3
    extl %d5
    divuw #365,%d5
    movew %d5,%d0
    swap %d5
    cmpiw #3,%d0
    jblt LONGSECS2DATE_132
    jbeq LONGSECS2DATE_130
    subqw #1,%d0
    addiw #365,%d5
LONGSECS2DATE_130:      /* leap year */
    addqb #4,%d4
LONGSECS2DATE_132:      /* year, day of year; week of year from the day of week */
    addw %d0,%d3
    movew %d5,%d0
    addqw #1,%d0
    movew %d0,%a2@(16)
    movew %d5,%d1
    extl %d1
    divuw #7,%d1
    movew %d1,%d0
    swap %d1
    cmpw %a2@(14),%d1
    jblt LONGSECS2DATE_150
    addqw #1,%d0
LONGSECS2DATE_150:      /* week number; month start table (leap if needed) */
    addqw #1,%d0
    movew %d0,%a2@(18)
    lea %pc@(MONTHSTARTS),%a0
    cmpib #4,%d4
    jble LONGSECS2DATE_164
    lea %pc@(LEAPSTARTS),%a0
LONGSECS2DATE_164:      /* find the month */
    moveq #-1,%d0
LONGSECS2DATE_166:      /* loop: first month start beyond the day; era (BC as negative) and year */
    addqw #1,%d0
    cmpw %a0@+,%d5
    jbge LONGSECS2DATE_166
    lea %a2@,%a1
    clrw %d1
    addiw #2001,%d3
    jbgt LONGSECS2DATE_17C
    moveq #-1,%d1
    negw %d3
    addqw #1,%d3
LONGSECS2DATE_17C:      /* store era, year, month, day; return */
    movew %d1,%a1@+
    movew %d3,%a1@+
    movew %d0,%a1@+
    subw %a0@(-4),%d5
    addqw #1,%d5
    movew %d5,%a1@+
    moveml %sp@+,%d3-%d7/%a2
    movew #12,%d0
    jbra STDUNLINK
    .byte   8	/* 4081EE56 Pascal string length */
    .ascii  "LSEX2DAT"	| 4081EE57
    .byte   0x00	| 4081EE5F

/* VALIDLONG: check a long date. */
VALIDLONG:
    moveml %d3-%d4,%sp@-
    movel #-2147483648,%d0
    moveq #0,%d4
    moveb %a0@+,%d4
    jble VALIDLONG_34
    moveq #0,%d1
    moveb %a0@+,%d1
    subib #48,%d1
    subqb #1,%d4
    movel %d1,%d2
    jbra VALIDLONG_28
VALIDLONG_1E:           /* value = value * 10 + digit */
    addl %d2,%d2
    movel %d2,%d3
    lsll #2,%d2
    addl %d3,%d2
    addl %d1,%d2
VALIDLONG_28:           /* next digit */
    moveb %a0@+,%d1
    subib #48,%d1
    dbf %d4,VALIDLONG_1E
    movel %d2,%d0
VALIDLONG_34:           /* N set if the string was empty */
    tstl %d0
    moveml %sp@+,%d3-%d4
    rts
    .long   0x00000000	| 4081EE9C

/* BLOCK2STRING: copy a block to a Pascal string. */
BLOCK2STRING:
    movel %d3,%sp@-
    movel %a1,%sp@-
    moveb %d2,%d3
    moveb %d1,%d2
    moveq #0,%d1
    tstl %d0
    jble BLOCK2STRING_4A
    notb %d1
    cmpl %d1,%d0
    jble BLOCK2STRING_16
    movel %d1,%d0
BLOCK2STRING_16:        /* copy up to the length, skipping leading spaces and the pad character */
    movel %a1,%sp@-
    movel %d0,%d1
    addql #1,%a1
    tstb %d2
    jbeq BLOCK2STRING_38
    jbra BLOCK2STRING_24
BLOCK2STRING_22:        /* one less */
    subqb #1,%d1
BLOCK2STRING_24:        /* skip a space or pad character */
    moveb %a0@+,%d2
    cmpib #32,%d2
    jbeq BLOCK2STRING_2E
    cmpb %d3,%d2
BLOCK2STRING_2E:        /* next; all padding: empty string */
    dbne %d0,BLOCK2STRING_22
    jbeq BLOCK2STRING_4A
    tstb %d2
    jbne BLOCK2STRING_40
BLOCK2STRING_38:        /* first character */
    moveb %a0@+,%d2
    jbra BLOCK2STRING_40
BLOCK2STRING_3C:        /* copy until a NUL */
    moveb %d2,%a1@+
    moveb %a0@+,%d2
BLOCK2STRING_40:        /* next character; shorten by what was left */
    dbeq %d0,BLOCK2STRING_3C
    jbne BLOCK2STRING_48
    subb %d0,%d1
BLOCK2STRING_48:        /* back to the length byte */
    moveal %sp@+,%a1
BLOCK2STRING_4A:        /* store the length; lower-case the string (_LwrString, strip diacriticals) */
    moveb %d1,%a1@
    moveal %sp@+,%a0
    moveq #0,%d0
    moveb %a0@+,%d0
    .short  0xA456	| 4081EEF2 _LwrString (flags 0x0400)
    movel %sp@+,%d3
    rts
    .long   0x00000000, 0x00000000	| 4081EEF8

/* COMPARE: compare two strings (Intl Utilities). */
COMPARE:
    .long   0xB0416E0C, 0x5340B308, 0x56C8FFFC	| 4081EF00
    moveq #0,%d0
    jbra COMPARE_12
    .short  0x70FF	| 4081EF10
COMPARE_12:             /* return */
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4081EF14

/* MATCHSTRING: match a string against a list (month names...). */
MATCHSTRING:
    linkw %fp,#0
    moveml %d3-%d5/%a2-%a4,%sp@-
    moveal %fp@(20),%a3
    movew %fp@(18),%d3
    moveal %fp@(12),%a4
    movew %fp@(10),%d4
    movew %fp@(8),%d5
    jbra MATCHSTRING_42
MATCHSTRING_1E:         /* compare the key with this list entry (exact, or a prefix of at least the minimum length) */
    moveal %a3,%a0
    movel %d3,%d0
    moveq #0,%d1
    moveb %a4@+,%d1
    moveal %a4,%a1
    cmpw %d1,%d0
    jbgt MATCHSTRING_40
    jbeq MATCHSTRING_34
    cmpw %fp@(16),%d0
    jblt MATCHSTRING_40
MATCHSTRING_34:         /* compare the characters */
    subqw #1,%d0
    jblt MATCHSTRING_40
MATCHSTRING_38:         /* loop: next character; all equal: found */
    cmpmb %a0@+,%a1@+
    dbne %d0,MATCHSTRING_38
    jbeq MATCHSTRING_48
MATCHSTRING_40:         /* next entry */
    addaw %d4,%a4
MATCHSTRING_42:         /* loop over the entries; none: return the count */
    dbf %d5,MATCHSTRING_1E
    jbra MATCHSTRING_4E
MATCHSTRING_48:         /* found: its index */
    subw %fp@(8),%d5
    negw %d5
MATCHSTRING_4E:         /* return the index */
    movew %d5,%fp@(24)
    moveml %sp@+,%d3-%d5/%a2-%a4
    movew #16,%d0
    jbra STDUNLINK
    .short  0x0000	| 4081EF7E

/* INITDATECACHE: _InitDateCache: tables for String2Date. */
INITDATECACHE:
    linkw %fp,#-46	| 4081EF80
    moveml %d3-%d4/%a2-%a4,%sp@-	| 4081EF84
    clrw %fp@(16)	| 4081EF88
    moveal %fp@(12),%a2	| 4081EF8C
    moveb #32,%fp@(-38)	| 4081EF90
    subql #6,%sp	| 4081EF96
    movel #-2113929214,%sp@-	| 4081EF98
    _ScriptUtil	| 4081EF9E
    movew #6,%sp@-	| 4081EFA0
    movel #-2080112628,%sp@-	| 4081EFA4
    _ScriptUtil	| 4081EFAA
    tstl %sp@+	| 4081EFAC
    jbeq INITDATECACHE_36	| 4081EFAE
    moveb #0xa0,%fp@(-38)	| 4081EFB0
INITDATECACHE_36:       /* the current date and date 0 as date records; the 'itl0' */
    lea %fp@(-46),%a0	| 4081EFB6
    clrl %a0@+	| 4081EFBA
    movel Time,%a0@+	| 4081EFBC
    pea %fp@(-46)	| 4081EFC0
    pea %a2@(2)	| 4081EFC4
    movel #-2146893840,%sp@-	| 4081EFC8
    _ScriptUtil	| 4081EFCE
    lea %fp@(-46),%a0	| 4081EFD0
    clrl %a0@+	| 4081EFD4
    clrl %a0@+	| 4081EFD6
    pea %fp@(-46)	| 4081EFD8
    pea %a2@(30)	| 4081EFDC
    movel #-2146893840,%sp@-	| 4081EFE0
    _ScriptUtil	| 4081EFE6
    clrl %sp@-	| 4081EFE8
    clrw %sp@-	| 4081EFEA
    movew #6,%sp@-	| 4081EFEC
    _Pack6	| 4081EFF0
    movel %sp@+,%fp@(-32)	| 4081EFF2
    movew ResErr,%d0	| 4081EFF6
    jbeq INITDATECACHE_84	| 4081EFFA
    movew %d0,%fp@(16)	| 4081EFFC
    jbra INITDATECACHE_1E0	| 4081F000
INITDATECACHE_84:       /* load the 'itl1' (month and day names) */
    clrl %sp@-	| 4081F004
    movew #1,%sp@-	| 4081F006
    movew #6,%sp@-	| 4081F00A
    _Pack6	| 4081F00E
    movel %sp@+,%fp@(-36)	| 4081F010
    tstw ResErr	| 4081F014
    jbeq INITDATECACHE_A4	| 4081F018
    movew ResErr,%fp@(16)	| 4081F01A
    jbra INITDATECACHE_1E0	| 4081F020
INITDATECACHE_A4:       /* from the 'itl0': PM and AM strings, time suffix, time and date separators, date order; then the 'itl1' long date format */
    moveal %fp@(-32),%a3	| 4081F024
    moveal %a3,%a0	| 4081F028
    _MoveHHi	| 4081F02A
    moveal %a3,%a0	| 4081F02C
    _HLock	| 4081F02E
    moveal %a3@,%a3	| 4081F030
    lea %a3@(16),%a0	| 4081F032
    lea %a2@(362),%a1	| 4081F036
    moveq #4,%d0	| 4081F03A
    moveb #1,%d1	| 4081F03C
    moveb %fp@(-38),%d2	| 4081F040
    jsr %pc@(BLOCK2STRING)	| 4081F044
    lea %a3@(12),%a0	| 4081F048
    lea %a2@(378),%a1	| 4081F04C
    moveq #4,%d0	| 4081F050
    moveb #1,%d1	| 4081F052
    moveb %fp@(-38),%d2	| 4081F056
    jsr %pc@(BLOCK2STRING)	| 4081F05A
    lea %a3@(21),%a0	| 4081F05E
    lea %a2@(394),%a1	| 4081F062
    moveq #1,%d0	| 4081F066
    moveb #1,%d1	| 4081F068
    moveb %fp@(-38),%d2	| 4081F06C
    jsr %pc@(BLOCK2STRING)	| 4081F070
    moveb %a3@(20),%a2@(410)	| 4081F074
    moveb %a3@(7),%a2@(414)	| 4081F07A
    moveb %a3@(9),%a2@(411)	| 4081F080
    moveal %fp@(-32),%a0	| 4081F086
    _HUnlock	| 4081F08A
    moveal %fp@(-36),%a3	| 4081F08C
    moveal %a3,%a0	| 4081F090
    _MoveHHi	| 4081F092
    moveal %a3,%a0	| 4081F094
    _HLock	| 4081F096
    moveal %a3@,%a3	| 4081F098
    moveq #0,%d1	| 4081F09A
    clrw %d0	| 4081F09C
    moveb %a3@(305),%d0	| 4081F09E
    jbeq INITDATECACHE_144	| 4081F0A2
    moveq #1,%d1	| 4081F0A4
    cmpib #0xff,%d0	| 4081F0A6
    jbeq INITDATECACHE_144	| 4081F0AA
INITDATECACHE_12C:      /* custom long date format: does day (1) or year (2) come first? */
    moveb %d0,%d2	| 4081F0AC
    andib #3,%d2	| 4081F0AE
    cmpib #0,%d2	| 4081F0B2
    jbeq INITDATECACHE_144	| 4081F0B6
    cmpib #3,%d2	| 4081F0B8
    jbeq INITDATECACHE_142	| 4081F0BC
    lsrb #2,%d0	| 4081F0BE
    jbne INITDATECACHE_12C	| 4081F0C0
INITDATECACHE_142:      /* year first */
    moveq #2,%d1	| 4081F0C2
INITDATECACHE_144:      /* that code and the abbreviation length; the 19 day and month names, lower case, into the cache */
    moveb %d1,%a2@(415)	| 4081F0C4
    moveb %a3@(307),%a2@(416)	| 4081F0C8
    lea %a3@(112),%a4	| 4081F0CE
    lea %a2@(58),%a1	| 4081F0D2
    moveq #11,%d3	| 4081F0D6
    jsr %pc@(INITDATECACHE_1EC)	| 4081F0D8
    lea %a3@,%a4	| 4081F0DC
    lea %a2@(250),%a1	| 4081F0DE
    moveq #6,%d3	| 4081F0E2
    jsr %pc@(INITDATECACHE_1EC)	| 4081F0E4
    moveal %fp@(-36),%a0	| 4081F0E8
    _HUnlock	| 4081F0EC
    lea %fp@(-28),%a0	| 4081F0EE
    movel %a0,%a2@(426)	| 4081F0F2
    moveq #2,%d0	| 4081F0F6
    movel %d0,%a2@(430)	| 4081F0F8
    clrl %a2@(434)	| 4081F0FC
    clrl %a2@(450)	| 4081F100
    lea %a2@(454),%a0	| 4081F104
    movew #13,%d0	| 4081F108
INITDATECACHE_18C:      /* clear the token buffer; the 'itl4' tokenizer */
    movew #127,%a0@+	| 4081F10C
    dbf %d0,INITDATECACHE_18C	| 4081F110
    clrl %sp@-	| 4081F114
    movew #4,%sp@-	| 4081F116
    movew #6,%sp@-	| 4081F11A
    _Pack6	| 4081F11E
    movel %sp@+,%a2@(482)	| 4081F120
    lea %a2@(410),%a0	| 4081F124
    movel %a0,%a2@(418)	| 4081F128
    moveq #2,%d0	| 4081F12C
    movel %d0,%a2@(422)	| 4081F12E
    clrb %sp@-	| 4081F132
    pea %a2@(418)	| 4081F134
    movel #-2113601542,%sp@-	| 4081F138
    _ScriptUtil	| 4081F13E
    tstb %sp@+	| 4081F140
    jbeq INITDATECACHE_1CC	| 4081F142
    movew #-32768,%fp@(16)	| 4081F144
    jbra INITDATECACHE_1E0	| 4081F14A
INITDATECACHE_1CC:      /* time separators and AM/PM strings */
    movew %fp@(-28),%a2@(410)	| 4081F14C
    movew %fp@(-14),%a2@(412)	| 4081F152
    movel #32,%a2@(430)	| 4081F158
INITDATECACHE_1E0:      /* restore registers */
    moveml %sp@+,%d3-%d4/%a2-%a4	| 4081F160
    movew #8,%d0	| 4081F164
    jbra STDUNLINK	| 4081F168
INITDATECACHE_1EC:      /* copy %d3+1 names (16 bytes each) as lower-case strings */
    movel %a1,%d4	| 4081F16C
INITDATECACHE_1EE:      /* loop: next name */
    moveal %a3,%a0
    moveal %d4,%a1
    moveb %a0@+,%d0
    moveq #1,%d1
    moveb %fp@(-38),%d2
    jsr %pc@(BLOCK2STRING)
    addil #16,%d4
    lea %a3@(16),%a3
    dbf %d3,INITDATECACHE_1EE
    rts
    .short  0x0000	| 4081F18E

/* STRING2DATE: _String2Date: parse a date. */
STRING2DATE:
    linkw %fp,#-804
    moveml %d3-%d7/%a2-%a4,%sp@-
    jbsr STRING2DATE_2EE
    tstw %fp@(32)
    jbne STRING2DATE_296
    moveq #-1,%d4
    clrw %fp@(-486)
    lea %a4@(2),%a1
    lea %fp@(-476),%a0
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    movel %a1@+,%a0@+
    movew %a1@+,%a0@+
    clrw %a0@+
    moveb %a4@(416),%d6
STRING2DATE_30:         /* per token: classify it */
    movew %a3@,%d1
    cmpiw #16,%d1
    jbge STRING2DATE_4E
    subqw #1,%d1
    jbeq STRING2DATE_134
    subqw #3,%d1
    jbeq STRING2DATE_B6
    subqw #1,%d1
    jbeq STRING2DATE_7C
    subqw #6,%d1
    jbeq STRING2DATE_7C
    jbra STRING2DATE_134
STRING2DATE_4E:         /* a separator: two in a row is an error */
    tstb %d7
    jbeq STRING2DATE_58
    oriw #32,%fp@(32)
STRING2DATE_58:         /* the first separator fixes the separator for the rest */
    addqb #1,%d7
    tstw %d5
    jbmi STRING2DATE_134
    jbne STRING2DATE_6A
    movew %d1,%fp@(-488)
    jbra STRING2DATE_134
STRING2DATE_6A:         /* a different separator: warn */
    cmpw %fp@(-488),%d1
    jbeq STRING2DATE_134
    oriw #68,%fp@(32)
    jbra STRING2DATE_134
STRING2DATE_7C:         /* white space separator */
    tstw %d7
    jbne STRING2DATE_9C
    tstw %d5
    jblt STRING2DATE_9C
    jbne STRING2DATE_8E
    movew #1,%fp@(-488)
    jbra STRING2DATE_9C
STRING2DATE_8E:         /* different from the first: warn */
    cmpiw #1,%fp@(-488)
    jbeq STRING2DATE_9C
    oriw #68,%fp@(32)
STRING2DATE_9C:         /* a number: store it as the next field */
    moveq #0,%d7
    cmpiw #2,%d5
    jbge STRING2DATE_120
    moveal %a3@(10),%a0
    jsr %pc@(VALIDLONG)
    jbmi STRING2DATE_296
    jbsr STRING2DATE_2DE
    jbra STRING2DATE_12C
STRING2DATE_B6:         /* a word: a month or day name? */
    moveq #0,%d7
    moveal %a3@(10),%a2
    addql #1,%a2
    moveal %a2,%a0
    movel %a3@(6),%d0
    .short  0xA456	| 4081F254 _LwrString (flags 0x0400)
    tstw %d4
    jbpl STRING2DATE_104
    clrw %sp@-
    movel %a2,%sp@-
    movew %a3@(8),%sp@-
    movew %d6,%sp@-
    pea %a4@(58)
    movew #15,%sp@-
    movew #19,%sp@-
    jsr %pc@(MATCHSTRING)
    movew %sp@+,%d2
    jble STRING2DATE_120
    subqw #7,%d2
    jble STRING2DATE_104
    cmpiw #2,%d5
    jbge STRING2DATE_120
    addqw #1,%d5
    movew %d5,%d1
    addw %d1,%d1
    lea %fp@(-482),%a1
    movew %d2,%a1@(0x0,%d1:w)
    movew %d5,%d4
    jbra STRING2DATE_12C
STRING2DATE_104:        /* a day name (only one is allowed): the day of week; a warning if fields came before it */
    tstb %fp@(-486)
    jbne STRING2DATE_120
    sle %fp@(-486)
    addqw #7,%d2
    movew %d2,%fp@(-462)
    tstw %d5
    jbmi STRING2DATE_11E
    oriw #8,%fp@(32)
STRING2DATE_11E:        /* next token */
    jbra STRING2DATE_12C
STRING2DATE_120:        /* unexpected token: remember where */
    tstw %fp@(-496)
    jbpl STRING2DATE_134
    movew %d3,%fp@(-496)
    jbra STRING2DATE_134
STRING2DATE_12C:        /* remember the last useful token */
    movew %d3,%fp@(-490)
    movel %a3,%fp@(-494)
STRING2DATE_134:        /* next token, until three fields or the end */
    addaw #14,%a3
    cmpiw #2,%d5
    sge %d0
    andb %fp@(-486),%d0
    dbne %d3,STRING2DATE_30
    tstw %d5
    jbpl STRING2DATE_154
    oriw #-31744,%fp@(32)
    jbra STRING2DATE_296
STRING2DATE_154:        /* check what is left; order the fields by the 'itl0' date order */
    jbsr STRING2DATE_2A4
    lea %pc@(STRING2DATE_38E),%a0
    lea %fp@(-482),%a1
    moveb %a4@(415),%d2
    tstw %d4
    jbpl STRING2DATE_182
    moveb %a4@(414),%d2
    tstw %d5
    jbeq STRING2DATE_1A6
    movew %fp@(-488),%d0
    cmpw %a4@(412),%d0
    jbeq STRING2DATE_1A6
    oriw #4,%fp@(32)
    jbra STRING2DATE_1A6
STRING2DATE_182:        /* with a month name: the order table for named months */
    oriw #1,%fp@(32)
    andiw #-77,%fp@(32)
    tstw %d5
    jbne STRING2DATE_19A
    moveq #1,%d5
    movew #1,%a1@(2)
STRING2DATE_19A:        /* index into the order table */
    movew %d4,%d0
    muluw #6,%d0
    addb %d2,%d0
    moveb %a0@(0x0,%d0:w),%d2
STRING2DATE_1A6:        /* fields to year, month, day per the order */
    moveq #0,%d1
    lea %fp@(-476),%a2
    movew %d5,%d0
    muluw #24,%d0
    addb %d2,%d2
    addb %d2,%d2
    addb %d2,%d0
    moveb %a0@(0x12,%d0:w),%d1
    jbmi STRING2DATE_1C6
    addw %d1,%d1
    movew %a1@(0x0,%d1:w),%fp@(-474)
STRING2DATE_1C6:        /* month */
    moveb %a0@(0x13,%d0:w),%d1
    jbmi STRING2DATE_1D4
    addw %d1,%d1
    movew %a1@(0x0,%d1:w),%fp@(-472)
STRING2DATE_1D4:        /* day; two-digit years: add the century */
    moveb %a0@(0x14,%d0:w),%d1
    addw %d1,%d1
    movew %a1@(0x0,%d1:w),%fp@(-470)
    cmpiw #1,%d5
    jble STRING2DATE_252
    movew %a4@(32),%d0
    movew %fp@(-474),%d1
    cmpw %d1,%d0
    jble STRING2DATE_252
    cmpiw #100,%d1
    jbge STRING2DATE_23C
    movew %a4@(4),%d0
    divuw #100,%d0
    muluw #100,%d0
    movew %d0,%d1
    movew %a4@(4),%d0
    subw %d1,%d0
    movew %fp@(-474),%d1
    cmpiw #90,%d0
    jbls STRING2DATE_224
    cmpiw #10,%d1
    jbgt STRING2DATE_236
    addiw #100,%fp@(-474)
    jbra STRING2DATE_236
STRING2DATE_224:        /* near the century boundary: the previous century */
    cmpiw #10,%d0
    jbgt STRING2DATE_236
    cmpiw #90,%d1
    jbls STRING2DATE_236
    subiw #100,%fp@(-474)
STRING2DATE_236:        /* century */
    movew #100,%d0
    jbra STRING2DATE_246
STRING2DATE_23C:        /* three-digit year: the millennium */
    cmpiw #1000,%d1
    jbge STRING2DATE_252
    movew #1000,%d0
STRING2DATE_246:        /* add the current century/millennium */
    movew %a4@(4),%d1
    divuw %d0,%d1
    muluw %d0,%d1
    addw %d1,%fp@(-474)
STRING2DATE_252:        /* validate (ValidDate) */
    moveq #14,%d0
    tstw %fp@(-462)
    jbeq STRING2DATE_260
    oril #128,%d0
STRING2DATE_260:        /* out of range: error */
    jbsr STRING2DATE_376
    jblt STRING2DATE_26E
    oriw #-30720,%fp@(32)
    jbra STRING2DATE_296
STRING2DATE_26E:        /* copy the date into the result record */
    moveal %fp@(12),%a1
    lea %fp@(-476),%a0
    movew %a0@(14),%a1@(14)
    movel %a0@+,%a1@+
    movel %a0@+,%a1@+
    moveal %fp@(16),%a0
STRING2DATE_284:        /* the number of characters used */
    moveal %fp@(-494),%a1
    movel %a1@(2),%a0@
    movel %fp@(28),%d0
    subl %a1@(6),%d0
    subl %d0,%a0@
STRING2DATE_296:        /* restore registers, return */
    moveml %sp@+,%d3-%d7/%a2-%a4
    unlk %fp
    moveal %sp@+,%a0
    addaw #24,%sp
    jmp %a0@

STRING2DATE_2A4:        /* anything after the last token used: warn */
    moveal %fp@(-494),%a3
    addaw #14,%a3
    movew %fp@(-490),%d3
    tstw %fp@(-496)
    jbmi STRING2DATE_2C2
    cmpw %fp@(-496),%d3
    jbgt STRING2DATE_2C2
    oriw #16,%fp@(32)
STRING2DATE_2C2:        /* skip the remaining tokens */
    moveq #0,%d1
    jbra STRING2DATE_2CE
STRING2DATE_2C6:        /* loop */
    movew %a3@,%d1
    subqw #1,%d1
    addaw #14,%a3
STRING2DATE_2CE:        /* non-separator tokens left: warn */
    dbne %d3,STRING2DATE_2C6
    tstb %d3
    jbmi STRING2DATE_2DC
    oriw #2,%fp@(32)
STRING2DATE_2DC:        /* return */
    rts

STRING2DATE_2DE:        /* store a number field */
    addqw #1,%d5
    movew %d5,%d1
    addw %d1,%d1
    lea %fp@(-482),%a1
    movew %d0,%a1@(0x0,%d1:w)
    rts

STRING2DATE_2EE:        /* shared setup: tokenize the text with the 'itl4' tokenizer */
    movew #-31744,%fp@(32)
    tstl %fp@(24)
    jble STRING2DATE_374
    clrw %fp@(32)
    moveal %fp@(20),%a4
    moveq #0,%d7
    moveq #0,%d6
    moveq #-1,%d5
    clrw %fp@(-488)
    clrw %fp@(-490)
    movew #-1,%fp@(-496)
    moveal %fp@(16),%a0
    clrl %a0@
    lea %fp@(-482),%a0
    clrl %a0@+
    clrw %a0@+
    lea %fp@(-448),%a0
    movel %a0,%a4@(426)
    st %a4@(450)
    lea %fp@(-804),%a0
    movel %a0,%a4@(438)
    movel #300,%a4@(442)
    movel %fp@(28),%a4@(418)
    movel %fp@(24),%a4@(422)
    lea %fp@(-448),%a3
    clrb %sp@-
    pea %a4@(418)
    movel #-2113601542,%sp@-
    _ScriptUtil
    tstb %sp@+
    jbeq STRING2DATE_36A
    oriw #-32768,%fp@(32)
    jbra STRING2DATE_374
STRING2DATE_36A:        /* the token count */
    movel %a4@(434),%d3
    subqw #1,%d3
    clrw %fp@(32)
STRING2DATE_374:        /* return */
    rts

STRING2DATE_376:        /* ValidDate on the work date */
    clrw %sp@-
    pea %fp@(-476)
    movel %d0,%sp@-
    pea %fp@(-504)
    movel #-2113077276,%sp@-
    _ScriptUtil
    tstw %sp@+
    rts
STRING2DATE_38E:        /* field order tables: per date order and field count */
    .short  0x0000	| 4081F51E
    .long   0x03030003, 0x01010202, 0x01020404, 0x05050405	| 4081F520
    .long   0xFFFF0000	| 4081F530
    .long   0xFFFF0000 /* number, not a label difference (was FLUSHMDB-.) */	| 4081F534
    .long   0xFFFF0000, 0xFFFF0000	| 4081F538
    .long   0xFFFF0000, 0xFFFF0000, 0xFF000100, 0xFF010000	| 4081F540
    .long   0xFF000100, 0xFF000100, 0xFF010000, 0xFF010000	| 4081F550
    .long   0x02000100, 0x02010000, 0x00010200, 0x01000200	| 4081F560
    .long   0x01020000, 0x00020100	| 4081F570

/* STRING2TIME: _String2Time: parse a time. */
STRING2TIME:
    linkw %fp,#-804	| 4081F578
    moveml %d3-%d7/%a2-%a4,%sp@-	| 4081F57C
    jbsr STRING2DATE_2EE	| 4081F580
    tstw %fp@(32)	| 4081F584
    jbne STRING2DATE_296	| 4081F588
    clrw %d4	| 4081F58C
    lea %fp@(-476),%a0	| 4081F58E
    lea %a4@(30),%a1	| 4081F592
    movew %a1@(14),%a0@(14)	| 4081F596
    movel %a1@+,%a0@+	| 4081F59C
    movel %a1@+,%a0@+	| 4081F59E
STRING2TIME_28:         /* per token: classify it */
    movew %a3@,%d1	| 4081F5A0
    cmpiw #16,%d1	| 4081F5A2
    jbge STRING2TIME_48	| 4081F5A6
    subqw #1,%d1	| 4081F5A8
    jbeq STRING2TIME_126	| 4081F5AA
    subqw #3,%d1	| 4081F5AE
    jbeq STRING2TIME_C2	| 4081F5B0
    subqw #1,%d1	| 4081F5B4
    jbeq STRING2TIME_7E	| 4081F5B6
    subqw #6,%d1	| 4081F5B8
    jbeq STRING2TIME_7E	| 4081F5BA
    jbra STRING2TIME_126	| 4081F5BC
STRING2TIME_48:         /* a separator: two in a row is an error */
    tstb %d7	| 4081F5C0
    jbeq STRING2TIME_52	| 4081F5C2
    oriw #32,%fp@(32)	| 4081F5C4
STRING2TIME_52:         /* the first separator fixes it */
    addqb #1,%d7	| 4081F5CA
    tstw %d5	| 4081F5CC
    jbeq STRING2TIME_64	| 4081F5CE
    jbpl STRING2TIME_6C	| 4081F5D0
    oriw #16,%fp@(32)	| 4081F5D2
    jbra STRING2TIME_126	| 4081F5D8
STRING2TIME_64:         /* remember it */
    movew %d1,%fp@(-488)	| 4081F5DC
    jbra STRING2TIME_126	| 4081F5E0
STRING2TIME_6C:         /* a different separator: warn */
    cmpw %fp@(-488),%d1	| 4081F5E4
    jbeq STRING2TIME_126	| 4081F5E8
    oriw #68,%fp@(32)	| 4081F5EC
    jbra STRING2TIME_126	| 4081F5F2
STRING2TIME_7E:         /* white space separator */
    tstw %d7	| 4081F5F6
    jbne STRING2TIME_9E	| 4081F5F8
    tstw %d5	| 4081F5FA
    jblt STRING2TIME_9E	| 4081F5FC
    jbne STRING2TIME_90	| 4081F5FE
    movew #1,%fp@(-488)	| 4081F600
    jbra STRING2TIME_9E	| 4081F606
STRING2TIME_90:         /* different: warn */
    cmpiw #1,%fp@(-488)	| 4081F608
    jbeq STRING2TIME_9E	| 4081F60E
    oriw #68,%fp@(32)	| 4081F610
STRING2TIME_9E:         /* a number: next field (after AM/PM: warn) */
    moveq #0,%d7	| 4081F616
    cmpiw #2,%d5	| 4081F618
    jbge STRING2TIME_112	| 4081F61C
    moveal %a3@(10),%a0	| 4081F61E
    jsr %pc@(VALIDLONG)	| 4081F622
    jbmi STRING2DATE_296	| 4081F626
    tstb %d6	| 4081F62A
    jbeq STRING2TIME_BC	| 4081F62C
    oriw #8,%fp@(32)	| 4081F62E
STRING2TIME_BC:         /* store it */
    jbsr STRING2DATE_2DE	| 4081F634
    jbra STRING2TIME_11E	| 4081F638
STRING2TIME_C2:         /* a word: AM or PM? */
    tstb %d6	| 4081F63A
    jbne STRING2TIME_112	| 4081F63C
    moveal %a3@(10),%a2	| 4081F63E
    addql #1,%a2	| 4081F642
    moveal %a2,%a0	| 4081F644
    movel %a3@(6),%d0	| 4081F646
    .short  0xA456	| 4081F64A _LwrString (flags 0x0400)
    clrw %sp@-	| 4081F64C
    movel %a2,%sp@-	| 4081F64E
    movew %a3@(8),%sp@-	| 4081F650
    movew #2,%sp@-	| 4081F654
    pea %a4@(362)	| 4081F658
    movew #15,%sp@-	| 4081F65C
    movew #3,%sp@-	| 4081F660
    jsr %pc@(MATCHSTRING)	| 4081F664
    movew %sp@+,%d2	| 4081F668
    jble STRING2TIME_10C	| 4081F66A
    cmpiw #2,%d2	| 4081F66C
    jbgt STRING2TIME_100	| 4081F670
    st %d4	| 4081F672
    jblt STRING2TIME_100	| 4081F674
    negb %d4	| 4081F676
STRING2TIME_100:        /* found: stop */
    st %d6	| 4081F678
    tstb %d7	| 4081F67A
    jbeq STRING2TIME_10C	| 4081F67C
    oriw #32,%fp@(32)	| 4081F67E
STRING2TIME_10C:        /* AM/PM seen */
    moveq #0,%d7	| 4081F684
    tstb %d6	| 4081F686
    jbne STRING2TIME_11E	| 4081F688
STRING2TIME_112:        /* unexpected token: remember where */
    tstw %fp@(-496)	| 4081F68A
    jbpl STRING2TIME_126	| 4081F68E
    movew %d3,%fp@(-496)	| 4081F690
    jbra STRING2TIME_126	| 4081F694
STRING2TIME_11E:        /* remember the last useful token */
    movew %d3,%fp@(-490)	| 4081F696
    movel %a3,%fp@(-494)	| 4081F69A
STRING2TIME_126:        /* next token */
    addaw #14,%a3	| 4081F69E
    tstb %d6	| 4081F6A2
    dbne %d3,STRING2TIME_28	| 4081F6A4
    tstw %d5
    jbpl STRING2TIME_13E
    oriw #-31744,%fp@(32)
    jbra STRING2DATE_296
STRING2TIME_13E:        /* check what is left; the separator must be the time separator */
    jbsr STRING2DATE_2A4
    tstw %d5
    jbeq STRING2TIME_156
    movew %fp@(-488),%d0
    cmpw %a4@(410),%d0
    jbeq STRING2TIME_156
    oriw #4,%fp@(32)
STRING2TIME_156:        /* AM/PM: adjust the hour to 24-hour time */
    moveq #12,%d0
    tstb %d4
    jbeq STRING2TIME_176
    jblt STRING2TIME_16C
    subw %fp@(-482),%d0
    jbgt STRING2TIME_176
    negw %d0
    movew %d0,%fp@(-482)
    jbra STRING2TIME_176
STRING2TIME_16C:        /* PM: add 12 */
    cmpw %fp@(-482),%d0
    jble STRING2TIME_176
    addw %d0,%fp@(-482)
STRING2TIME_176:        /* 24:00 is 0:00 */
    cmpiw #24,%fp@(-482)
    jbne STRING2TIME_182
    clrw %fp@(-482)
STRING2TIME_182:        /* validate the hour, minute, second */
    lea %fp@(-482),%a2
    lea %fp@(-468),%a3
    movel %a2@+,%a3@+
    movew %a2@+,%a3@+
    moveq #112,%d0
    jbsr STRING2DATE_376
    jblt STRING2TIME_1A0
    oriw #-30720,%fp@(32)
    jbra STRING2DATE_296
STRING2TIME_1A0:        /* copy into the result record */
    moveal %fp@(12),%a1
    addql #8,%a1
    lea %fp@(-468),%a0
    movel %a0@+,%a1@+
    movew %a0@+,%a1@+
    moveal %fp@(16),%a0
    jbra STRING2DATE_284
    .short  0x0000	| 4081F72E

/* STYLEDLINEBREAK: _StyledLineBreak: where to break a line of styled text. */
STYLEDLINEBREAK:
    linkw %fp,#-18	| 4081F730
    moveml %d4-%d6/%a2-%a3,%sp@-	| 4081F734
    moveal %fp@(16),%a3	| 4081F738
    movel %fp@(36),%d5	| 4081F73C
    addl %fp@(28),%d5	| 4081F740
    movew TESysJust,%fp@(-16)	| 4081F744
    clrw TESysJust	| 4081F74A
    clrw %sp@-	| 4081F74E
    movel #-2113929216,%sp@-	| 4081F750
    _ScriptUtil	| 4081F756
    movew %sp@+,%d0	| 4081F758
    lslw #2,%d0	| 4081F75A
    moveal IntlSpec,%a2	| 4081F75C
    moveal %a2@(0x72,%d0:w),%a2	| 4081F760
    moveb %a2@(18),%fp@(-18)	| 4081F764
    bclr #15,%a2@(18)	| 4081F76A
    movel %fp@(24),%d4	| 4081F770
    subl %fp@(28),%d4	| 4081F774
    jble STYLEDLINEBREAK_100	| 4081F778
    tstl %a3@	| 4081F77C
    jbmi STYLEDLINEBREAK_14E	| 4081F77E
    clrw %sp@-	| 4081F782
    movel %d5,%sp@-	| 4081F784
    movew %d4,%sp@-	| 4081F786
    clrw %sp@-	| 4081F788
    movew %a3@,%sp@-	| 4081F78A
    pea %fp@(-13)	| 4081F78C
    movel #-2113011692,%sp@-	| 4081F790
    _ScriptUtil	| 4081F796
    moveq #0,%d6	| 4081F798
    movew %sp@+,%d6	| 4081F79A
    tstl %a3@	| 4081F79C
    jbne STYLEDLINEBREAK_74	| 4081F79E
    st %fp@(-13)	| 4081F7A0
STYLEDLINEBREAK_74:     /* a return before the width is used up ends the line */
    moveal %d5,%a0	| 4081F7A4
    movew %d6,%d0	| 4081F7A6
    jbsr FINDCARRIAGE	| 4081F7A8
    addw %fp@(30),%d1	| 4081F7AC
    tstb %d0	| 4081F7B0
    jbne STYLEDLINEBREAK_176	| 4081F7B2
    movel %d6,%d0	| 4081F7B6
    addl %fp@(28),%d6	| 4081F7B8
    cmpl %d4,%d0	| 4081F7BC
    jblt STYLEDLINEBREAK_96	| 4081F7BE
    tstb %fp@(-13)	| 4081F7C0
    jbne STYLEDLINEBREAK_100	| 4081F7C4
STYLEDLINEBREAK_96:     /* find the character at the remaining width (_Pixel2Char) */
    movel %fp@(36),%sp@-	| 4081F7C6
    movew %fp@(34),%sp@-	| 4081F7CA
    movew %d6,%sp@-	| 4081F7CE
    moveb %fp@(-13),%sp@-	| 4081F7D0
    movel MinusOne,%sp@-	| 4081F7D4
    pea %fp@(-12)	| 4081F7D8
    movel #-2146303974,%sp@-	| 4081F7DC
    _ScriptUtil	| 4081F7E2
    clrw %sp@-	| 4081F7E4
    movel %fp@(36),%sp@-	| 4081F7E6
    movew %fp@(-12),%sp@-	| 4081F7EA
    movel #-2113535982,%sp@-	| 4081F7EE
    _ScriptUtil	| 4081F7F4
    movew %sp@+,%d0	| 4081F7F6
    moveq #0,%d1	| 4081F7F8
    movew %fp@(-12),%d1	| 4081F7FA
    .byte   0x02, 0x40	| 4081F7FE

STYLEDLINEBREAK_D0:     /* at the limit: a blank word (by its CharType) stays on this line, up to any return in it */
    movepw %sp@(3136),%d7
    btst %d1,%d0
    jbne STYLEDLINEBREAK_11A
    btst #15,%fp@(-18)
    sne %d0
    cmpb %fp@(-15),%d0
    jbne STYLEDLINEBREAK_11A
    moveal %fp@(36),%a0
    moveq #0,%d6
    movew %fp@(-12),%d6
    addal %d6,%a0
    movew %fp@(-10),%d0
    subw %d6,%d0
    jbsr FINDCARRIAGE
    addw %d6,%d1
    jbra STYLEDLINEBREAK_176
STYLEDLINEBREAK_100:    /* the whole run fits: its width off the remaining width; smBreakOverflow (2) */
    clrw %sp@-	| 4081F830
    movel %d5,%sp@-	| 4081F832
    clrw %sp@-	| 4081F834
    movew %d4,%sp@-	| 4081F836
    _TextWidth	| 4081F838
    movew %sp@+,%d0	| 4081F83A
    swap %d0	| 4081F83C
    clrw %d0	| 4081F83E
    subl %d0,%a3@	| 4081F840
    movel %fp@(24),%d6	| 4081F842
    moveq #2,%d0
    jbra STYLEDLINEBREAK_17C
STYLEDLINEBREAK_11A:    /* first run of the line and no word fits: break inside the word */
    tstl %d1
    jbne STYLEDLINEBREAK_176
    moveal %fp@(12),%a0
    tstl %a0@
    jbeq STYLEDLINEBREAK_176
    tstb %fp@(-13)
    jbne STYLEDLINEBREAK_148
    subql #1,%d6
    clrw %sp@-
    movel %d5,%sp@-
    movel %d6,%d0
    subl %fp@(28),%d0
    movew %d0,%sp@-
    movel #-2113535984,%sp@-
    _ScriptUtil
    tstw %sp@+
    jble STYLEDLINEBREAK_148
    subql #1,%d6
STYLEDLINEBREAK_148:    /* something fits: break there */
    tstl %d6
    jbgt STYLEDLINEBREAK_172
    jbra STYLEDLINEBREAK_15A
STYLEDLINEBREAK_14E:    /* nothing fits yet */
    moveal %fp@(12),%a0	| 4081F87E
    tstl %a0@	| 4081F882
    jbne STYLEDLINEBREAK_15A	| 4081F884
    moveq #0,%d1
    jbra STYLEDLINEBREAK_176
STYLEDLINEBREAK_15A:    /* at least one character (two for a double-byte character) */
    moveq #1,%d6
    clrw %sp@-
    movel %d5,%sp@-
    movew #1,%sp@-
    movel #-2113535984,%sp@-
    _ScriptUtil
    tstw %sp@+
    jble STYLEDLINEBREAK_172
    addql #1,%d6
STYLEDLINEBREAK_172:    /* smBreakChar (1) */
    moveq #1,%d0
    jbra STYLEDLINEBREAK_17C
STYLEDLINEBREAK_176:    /* smBreakWord (0): break at %d1 */
    moveq #0,%d6
    movew %d1,%d6
    moveq #0,%d0
STYLEDLINEBREAK_17C:    /* return the offset and code; restore TESysJust */
    moveal %fp@(12),%a0
    movel %d6,%a0@
    moveb %d0,%fp@(40)
    moveb %fp@(-18),%a2@(18)
    movew %fp@(-16),TESysJust
    moveml %sp@+,%d4-%d6/%a2-%a3
    movew #32,%d0
    jbra STDUNLINK
    .short  0x0000	| 4081F8CE

/* FINDCARRIAGE: find a carriage return. */
FINDCARRIAGE:
    movew %d0,%d1
    moveb #13,%d2
    jbra FINDCARRIAGE_A
FINDCARRIAGE_8:         /* search for a return */
    cmpb %a0@+,%d2
FINDCARRIAGE_A:         /* loop; not found: false */
    dbeq %d0,FINDCARRIAGE_8
    jbeq FINDCARRIAGE_14
    sf %d0
    jbra FINDCARRIAGE_18
FINDCARRIAGE_14:        /* found: its offset, true */
    subw %d0,%d1
    st %d0
FINDCARRIAGE_18:        /* return */
    rts
    .short  0x0000, 0x0000	| 4081F8EA
FINDCARRIAGE_1E:        /* (padding) */
    .byte   0x00, 0x00	| 4081F8EE
/* FORMATORDER (FINDCARRIAGE_20): _FormatOrder: the display order of style runs: each run's
 direction from the caller's DirProc, then the runs that go against the line direction reversed. */
FINDCARRIAGE_20:        /* FormatOrder */
    linkw %fp,#0	| 4081F8F0
    moveml %d4-%d6/%a2-%a3,%sp@-	| 4081F8F4
    moveal %fp@(26),%a2
    movew %fp@(24),%d3
    movew %fp@(22),%d4
    cmpw %d3,%d4
    jble FORMATORDER_78
    moveal %fp@(16),%a3
    moveq #2,%d5
    moveb %fp@(20),%d6
    jbeq FORMATORDER_2E
    movew %d4,%d0
    subw %d3,%d0
    addw %d0,%d0
    addaw %d0,%a2
    negw %d5
FORMATORDER_2E:         /* per run: its direction; against the line direction: complemented index */
    clrb %sp@-
    movew %d3,%sp@-
    movel %fp@(12),%sp@-
    jsr %a3@
    movew %d3,%d1
    cmpb %sp@+,%d6
    jbeq FORMATORDER_40
    notw %d1
FORMATORDER_40:         /* next run; then find the reversed stretches */
    movew %d1,%a2@
    addaw %d5,%a2
    addqw #1,%d3
    cmpw %d3,%d4
    jbge FORMATORDER_2E
    subw %fp@(24),%d4
    moveq #-1,%d5
    clrw %d3
    moveal %fp@(26),%a2
    moveal %a2,%a3
FORMATORDER_58:         /* complemented: start of a stretch */
    tstw %a3@+
    jbge FORMATORDER_64
    tstw %d5
    jbge FORMATORDER_6C
    movew %d3,%d5
    jbra FORMATORDER_6C
FORMATORDER_64:         /* end of a stretch: reverse it */
    tstw %d5
    jblt FORMATORDER_6C
    jbsr FINDCARRIAGE_A4
    moveq #-1,%d5
FORMATORDER_6C:         /* next entry; the last stretch */
    addqw #1,%d3
    cmpw %d3,%d4
    jbge FORMATORDER_58
    tstw %d5
    jblt FORMATORDER_78
    jbsr FINDCARRIAGE_A4
FORMATORDER_78:         /* restore registers */
    moveml %sp@+,%d4-%d6/%a2-%a3
    movew #22,%d0
    jbra STDUNLINK

FINDCARRIAGE_A4:        /* reverse the entries %d5..%d3 in the order array, uncomplementing them */
    movew %d3,%d2
    subw %d5,%d2
    subqw #1,%d2
    asrw #1,%d2
    movew %d5,%d0
    addw %d0,%d0
    lea %a2@(0x0,%d0:w),%a0
    movew %d3,%d0
    addw %d0,%d0
    lea %a2@(0x0,%d0:w),%a1
FORMATORDER_9C:         /* loop: swap from both ends */
    movew %a0@,%d0
    notw %d0
    movew %a1@-,%d1
    notw %d1
    movew %d0,%a1@
    movew %d1,%a0@+
    dbf %d2,FORMATORDER_9C
    rts
    .short  0x0000	| 4081F99E

/* INTLTOKENIZE: _IntlTokenize: split text into tokens. */
INTLTOKENIZE:
    linkw %fp,#0
    moveml %d2-%d7/%a2-%fp,%sp@-
    moveal %fp@(12),%a5
    moveal %a5@(64),%a4
    movel %a4@,%d6
    jbne INTLTOKENIZE_1A
    movel %a4,%sp@-
    _LoadResource
    movel %a4@,%d6
INTLTOKENIZE_1A:        /* source, length, token list; doAppend: after the existing tokens */
    moveal %d6,%a4
    moveal %a5@,%a0
    movel %a5@(4),%d0
    moveal %a5@(8),%a1
    tstb %a5@(33)
    jbeq INTLTOKENIZE_36
    movel %a5@(16),%d6
    muluw #14,%d6
    addal %d6,%a1
INTLTOKENIZE_36:        /* delimiters and comments into registers; the class table in the itl4; clear the class bitmap */
    movel %a1,%sp@-
    movel %a5@(12),%d1
    movel %a5@(36),%d3
    movel %a5@(44),%d4
    movel %a5@(48),%d5
    movel %a4@(20),%d6
    lea %a4@(0x0,%d6:w),%a4
    lea %pc@(INTLTOKENIZE_6B0),%fp
    movel %fp,%a4@(-8)
    moveal IntlSpec,%fp
    lea %fp@(380),%fp
    lea %fp@(-2),%a2
    clrw %a2@+
    clrl %a2@+
    clrl %a2@+
    clrl %a2@+
    clrl %a2@+
    moveal %a0,%a2
    clrw %d6
    moveb %d3,%d6
    jbmi INTLTOKENIZE_7C
    asrw #3,%d6
    bset %d3,%fp@(0x0,%d6:w)
INTLTOKENIZE_7C:        /* mark the delimiter and comment token classes in the class bitmap */
    swap %d3
    clrw %d6
    moveb %d3,%d6
    jbmi INTLTOKENIZE_8A
    asrw #3,%d6
    bset %d3,%fp@(0x0,%d6:w)
INTLTOKENIZE_8A:        /* second delimiter */
    swap %d3
    clrw %d6
    moveb %d4,%d6
    jbmi INTLTOKENIZE_98
    asrw #3,%d6
    bset %d4,%fp@(0x0,%d6:w)
INTLTOKENIZE_98:        /* comment */
    clrw %d6
    moveb %d5,%d6
    jbmi INTLTOKENIZE_A4
    asrw #3,%d6
    bset %d5,%fp@(0x0,%d6:w)
INTLTOKENIZE_A4:        /* first character: its class from the 'itl4' table */
    moveq #0,%d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_B4
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_B8
INTLTOKENIZE_B4:        /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_B8:        /* start the first token */
    swap %d2
    jbra INTLTOKENIZE_CE

INTLTOKENIZE_BC:        /* emit the token (class, position, length) */
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew %d2,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
INTLTOKENIZE_CE:        /* next character: its class */
    moveal %a3,%a2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_DE
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_E2
INTLTOKENIZE_DE:        /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_E2:        /* a marked class (delimiter or comment): handle it */
    swap %d2
    movew %d2,%d6
    asrw #3,%d6
    btst %d2,%fp@(0x0,%d6:w)
    jbne INTLTOKENIZE_654
INTLTOKENIZE_F0:        /* by class: alpha, white, punctuation, numeric, new line ... */
    cmpiw #4,%d2
    beqw INTLTOKENIZE_176
    cmpiw #1,%d2
    jbeq INTLTOKENIZE_126
    cmpiw #16,%d2
    jbge INTLTOKENIZE_510
    cmpiw #5,%d2
    jbeq INTLTOKENIZE_14A
    cmpiw #6,%d2
    jbeq INTLTOKENIZE_BC
    cmpiw #11,%d2
    jbeq INTLTOKENIZE_472
    tstw %d2
    jbeq INTLTOKENIZE_BC
    jbmi INTLTOKENIZE_6AE
    jbra INTLTOKENIZE_6E6
INTLTOKENIZE_126:       /* white space (tokenWhite) */
    swap %d2
INTLTOKENIZE_128:       /* loop: more white space */
    cmpiw #1,%d2
    jbne INTLTOKENIZE_144
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_13E
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_142
INTLTOKENIZE_13E:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_142:       /* continue */
    jbra INTLTOKENIZE_128
INTLTOKENIZE_144:       /* emit it */
    swap %d2
    jbra INTLTOKENIZE_BC
INTLTOKENIZE_14A:       /* numeric (tokenNumeric) */
    swap %d2
    moveq #5,%d7
INTLTOKENIZE_14E:       /* loop: more digits */
    cmpw %d7,%d2
    jbne INTLTOKENIZE_168
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_162
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_166
INTLTOKENIZE_162:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_166:       /* continue */
    jbra INTLTOKENIZE_14E
INTLTOKENIZE_168:       /* a decimal point: a real number */
    cmpw %a5@(62),%d2
    jbeq INTLTOKENIZE_49C
    swap %d2
    jbra INTLTOKENIZE_BC
INTLTOKENIZE_176:       /* alpha (tokenAlpha); with doAlphanumeric, digits too */
    swap %d2
    moveq #4,%d7
    tstb %a5@(34)
    jbeq INTLTOKENIZE_1A6
INTLTOKENIZE_180:       /* alphanumeric: letters and digits */
    cmpw %d7,%d2
    jbeq INTLTOKENIZE_190
    cmpiw #5,%d2
    jbeq INTLTOKENIZE_190
    cmpiw #11,%d2
    jbne INTLTOKENIZE_1C0
INTLTOKENIZE_190:       /* next character */
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_1A0
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_1A4
INTLTOKENIZE_1A0:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_1A4:       /* continue */
    jbra INTLTOKENIZE_180
INTLTOKENIZE_1A6:       /* letters only */
    cmpw %d7,%d2
    jbne INTLTOKENIZE_1C0
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_1BA
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_1BE
INTLTOKENIZE_1BA:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_1BE:       /* continue */
    jbra INTLTOKENIZE_1A6
INTLTOKENIZE_1C0:       /* emit the alpha token */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #4,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    jbra INTLTOKENIZE_CE
INTLTOKENIZE_1DA:       /* second left delimiter */
    movel %a5@(40),%d3
    swap %d3
    jbra INTLTOKENIZE_1E6
INTLTOKENIZE_1E2:       /* first left delimiter */
    movel %a5@(40),%d3
INTLTOKENIZE_1E6:       /* emit tokenLeftLit; scan the literal up to the right delimiter */
    movew %a5@(60),%d4
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #2,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %a3,%a2
    swap %d2
INTLTOKENIZE_202:       /* right delimiter: end; escape: the next character is literal */
    cmpw %d2,%d3
    jbeq INTLTOKENIZE_29A
    cmpw %d2,%d4
    jbne INTLTOKENIZE_27C
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #9,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %a3,%a2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_230
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_234
INTLTOKENIZE_230:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_234:       /* emit tokenEscape and the escaped character */
    jbmi INTLTOKENIZE_6E0
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #10,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %a3,%a2
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_25E
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_262
INTLTOKENIZE_25E:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_262:       /* emit it */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew %d2,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %a3,%a2
    swap %d2
    jbra INTLTOKENIZE_202
INTLTOKENIZE_27C:       /* end of text inside the literal: badEnding */
    tstw %d2
    jbmi INTLTOKENIZE_6E0
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_292
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_296
INTLTOKENIZE_292:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_296:       /* continue */
    jbra INTLTOKENIZE_202
INTLTOKENIZE_29A:       /* emit tokenLiteral, then tokenRightLit */
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #9,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    movel %a5@(36),%d3
    movel %a5@(44),%d4
    moveal %a3,%a2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_2C6
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_2CA
INTLTOKENIZE_2C6:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_2CA:       /* emit tokenRightLit */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #3,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    jbra INTLTOKENIZE_CE
INTLTOKENIZE_2E4:       /* second left comment */
    movel %a5@(56),%d3
    moveaw #1,%fp
    jbra INTLTOKENIZE_2F8
INTLTOKENIZE_2EE:       /* first left comment */
    movel %d4,%d5
    moveaw #1,%fp
    movel %a5@(52),%d3
INTLTOKENIZE_2F8:       /* next character */
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_306
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_30A
INTLTOKENIZE_306:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_30A:       /* emit tokenLeftComment; scan the comment */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #7,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %a3,%a2
    tstl %d3
    jbmi INTLTOKENIZE_354
    jbra INTLTOKENIZE_3C8
INTLTOKENIZE_32A:       /* second (one-character) left comment */
    movel %a5@(56),%d3
    jbra INTLTOKENIZE_334

INTLTOKENIZE_330:       /* first (one-character) left comment */
    movel %a5@(52),%d3
INTLTOKENIZE_334:       /* emit tokenLeftComment */
    moveaw #1,%fp
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #7,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %a3,%a2
    tstl %d3
    jbmi INTLTOKENIZE_354
    jbra INTLTOKENIZE_3C8
INTLTOKENIZE_354:       /* scan to the right comment */
    swap %d2
INTLTOKENIZE_356:       /* loop: next character until the right comment; end of text: badDelim */
    cmpw %d2,%d3
    jbeq INTLTOKENIZE_374
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_36A
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_36E
INTLTOKENIZE_36A:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_36E:       /* continue */
    jbpl INTLTOKENIZE_356
    jbra INTLTOKENIZE_6E0
INTLTOKENIZE_374:       /* emit the comment body (tokenLiteral), then tokenRightComment */
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #9,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %a3,%a2
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_39A
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_39E
INTLTOKENIZE_39A:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_39E:       /* emit tokenRightComment */
    swap %d2
    movel %a5@(36),%d3
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #8,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    movel %a5@(48),%d5
    moveal IntlSpec,%fp
    lea %fp@(380),%fp
    jbra INTLTOKENIZE_CE

INTLTOKENIZE_3C8:       /* two-character comments: next character */
    movel %a3,%d7
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_3D8
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_3DC
INTLTOKENIZE_3D8:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_3DC:       /* a nested left comment? */
    swap %d2
    cmpl %d2,%d5
    jbeq INTLTOKENIZE_3EE
INTLTOKENIZE_3E2:       /* the right comment ends it; end of text: badDelim */
    cmpl %d2,%d3
    jbeq INTLTOKENIZE_412
    tstw %d2
    jbpl INTLTOKENIZE_3C8
    jbra INTLTOKENIZE_6E0
INTLTOKENIZE_3EE:       /* nesting allowed (doNest): emit what came before */
    tstb %a5@(35)
    jbeq INTLTOKENIZE_3E2
    moveal %d7,%a3
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #9,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %d7,%a2
    addqw #1,%fp
    jbra INTLTOKENIZE_2F8
INTLTOKENIZE_412:       /* emit the body, then the right comment */
    moveal %d7,%a3
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #9,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %d7,%a2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_438
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_43C
INTLTOKENIZE_438:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_43C:       /* emit tokenRightComment */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #8,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    moveal %a3,%a2
    subqw #1,%fp
    cmpaw #0,%fp
    jbne INTLTOKENIZE_3C8
    movel %a5@(36),%d3
    movel %a5@(48),%d5
    moveal IntlSpec,%fp
    lea %fp@(380),%fp
    jbra INTLTOKENIZE_CE
INTLTOKENIZE_472:       /* alternate digits (tokenAltNum) */
    swap %d2
    moveq #11,%d7
INTLTOKENIZE_476:       /* loop: more alternate digits */
    cmpw %d7,%d2
    jbne INTLTOKENIZE_490
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_48A
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_48E
INTLTOKENIZE_48A:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_48E:       /* continue */
    jbra INTLTOKENIZE_476
INTLTOKENIZE_490:       /* a decimal point: an alternate real */
    cmpw %a5@(62),%d2
    jbeq INTLTOKENIZE_4D6
    swap %d2
    jbra INTLTOKENIZE_BC
INTLTOKENIZE_49C:       /* real number: the fraction */
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_4AC
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_4B0
INTLTOKENIZE_4AC:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_4B0:       /* digits */
    moveq #5,%d7
INTLTOKENIZE_4B2:       /* loop: more digits */
    cmpw %d7,%d2
    jbne INTLTOKENIZE_4CC
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_4C6
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_4CA
INTLTOKENIZE_4C6:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_4CA:       /* continue */
    jbra INTLTOKENIZE_4B2
INTLTOKENIZE_4CC:       /* emit tokenRealNum (12) */
    swap %d2
    movew #12,%d2
    jbra INTLTOKENIZE_BC
INTLTOKENIZE_4D6:       /* alternate real: the fraction */
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_4E6
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_4EA
INTLTOKENIZE_4E6:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_4EA:       /* alternate digits */
    moveq #11,%d7
INTLTOKENIZE_4EC:       /* loop */
    cmpw %d7,%d2
    jbne INTLTOKENIZE_506
    swap %d2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_500
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_504
INTLTOKENIZE_500:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_504:       /* continue */
    jbra INTLTOKENIZE_4EC
INTLTOKENIZE_506:       /* emit tokenAltReal (13) */
    swap %d2
    movew #13,%d2
    jbra INTLTOKENIZE_BC
INTLTOKENIZE_510:       /* punctuation that may pair with the next character into a two-character token */
    swap %d2
    cmpiw #33,%d2
    jbne INTLTOKENIZE_616
    swap %d2
    cmpiw #31,%d2
    jbne INTLTOKENIZE_54E
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_530
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_534
INTLTOKENIZE_530:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_534:       /* emit the pair (34) */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #34,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    jbra INTLTOKENIZE_CE
INTLTOKENIZE_54E:       /* second kind of pair */
    cmpiw #32,%d2
    jbne INTLTOKENIZE_580
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_562
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_566
INTLTOKENIZE_562:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_566:       /* emit the pair (36) */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #36,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    jbra INTLTOKENIZE_CE
INTLTOKENIZE_580:       /* third kind of pair */
    cmpiw #68,%d2
    jbne INTLTOKENIZE_5B2
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_594
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_598
INTLTOKENIZE_594:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_598:       /* emit the pair (39) */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #39,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    jbra INTLTOKENIZE_CE
INTLTOKENIZE_5B2:       /* fourth kind of pair */
    cmpiw #33,%d2
    jbne INTLTOKENIZE_5E4
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_5C6
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_5CA
INTLTOKENIZE_5C6:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_5CA:       /* emit the pair (38) */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #38,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    jbra INTLTOKENIZE_CE
INTLTOKENIZE_5E4:       /* fifth kind of pair */
    cmpiw #43,%d2
    jbne INTLTOKENIZE_64C
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_5F8
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_5FC
INTLTOKENIZE_5F8:       /* end of text or double-byte character */
    jbsr INTLTOKENIZE_68E
INTLTOKENIZE_5FC:       /* emit the pair (42) */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #42,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    jbra INTLTOKENIZE_CE
INTLTOKENIZE_616:       /* sixth kind of pair */
    swap %d2
    cmpil #2031648,%d2
    jbne INTLTOKENIZE_64C
    moveal %a0,%a3
    moveb %a0@+,%d2
    subql #1,%d0
    jbmi INTLTOKENIZE_62E
    moveb %a4@(0x0,%d2:w),%d2
    jbpl INTLTOKENIZE_632
INTLTOKENIZE_62E:       /* end of text or double-byte character */
    bsrw INTLTOKENIZE_68E
INTLTOKENIZE_632:       /* emit the pair (41) */
    swap %d2
    movel %a3,%d6
    subl %a2,%d6
    subql #1,%d1
    jbmi INTLTOKENIZE_6DA
    movew #41,%a1@+
    movel %a2,%a1@+
    movel %d6,%a1@+
    clrl %a1@+
    jbra INTLTOKENIZE_CE
INTLTOKENIZE_64C:       /* a single-character token of its own class */
    movel %a3,%d7
    subl %a2,%d7
    jbra INTLTOKENIZE_BC
INTLTOKENIZE_654:       /* a marked class: which delimiter or comment? */
    cmpw %d2,%d3
    jbeq INTLTOKENIZE_1E2
    swap %d3
    cmpw %d2,%d3
INTLTOKENIZE_65E:       /* second left delimiter; comments (one or two characters) */
    jbeq INTLTOKENIZE_1DA

    swap %d3
    tstl %d4
    jbpl INTLTOKENIZE_670
    cmpw %d2,%d4
    jbne INTLTOKENIZE_676
    jbra INTLTOKENIZE_330
INTLTOKENIZE_670:       /* two-character left comment */
    cmpl %d2,%d4
    jbeq INTLTOKENIZE_2EE
INTLTOKENIZE_676:       /* second left comment */
    tstl %d5
    jbpl INTLTOKENIZE_684
    cmpw %d2,%d5
    jbeq INTLTOKENIZE_32A
    jbra INTLTOKENIZE_F0
INTLTOKENIZE_684:       /* two-character second left comment; else an ordinary class */
    cmpl %d2,%d5
    jbeq INTLTOKENIZE_2E4
    jbra INTLTOKENIZE_F0

INTLTOKENIZE_68E:       /* end of text: class -1; else a double-byte character: the script's handler (-4 in the table) */
    tstl %d0
    jbpl INTLTOKENIZE_698
    movew #-1,%d2
    rts
INTLTOKENIZE_698:       /* jump to the handler */
    movel %a4@(-4),%d6
    jmp %a4@(0x0,%d6:l)

INTLTOKENIZE_6A0:       /* doString: build the token strings through the 'itl4' string routine */
    moveal %a5@(64),%fp
    moveal %fp@,%fp
    movel %fp@(24),%d6
    jmp %fp@(0x0,%d6:l)
INTLTOKENIZE_6AE:       /* tokenOK (0) */
    moveq #0,%d6
INTLTOKENIZE_6B0:       /* common exit: store the token count; build the strings if asked */
    movew %d6,%sp@-
    movel %a1,%d6
    subl %a5@(8),%d6
    divsw #14,%d6
    movel %d6,%a5@(16)
    tstb %a5@(32)
    jbeq INTLTOKENIZE_6C8
    jbsr INTLTOKENIZE_6A0
INTLTOKENIZE_6C8:       /* return the result */
    movew %sp@+,%d0
    addql #4,%sp
    moveml %sp@+,%d2-%d7/%a2-%fp
    unlk %fp
    moveal %sp@+,%a0
    addql #8,%sp
    moveb %d0,%sp@
    jmp %a0@
INTLTOKENIZE_6DA:       /* tokenOverflow (1) */
    movew #1,%d6
    jbra INTLTOKENIZE_6B0

INTLTOKENIZE_6E0:       /* badDelim (3) */
    movew #3,%d6
    jbra INTLTOKENIZE_6B0

INTLTOKENIZE_6E6:       /* crash (5) */
    movew #5,%d6
    jbra INTLTOKENIZE_6B0
    .long   0x00000000	| 4082008C

/* CHARCOMP: compare characters. */
CHARCOMP:
    linkw %fp,#0
    lea %fp@(10),%a0
    movew #2,%d0
    .short  0xA456	| 4082009C _LwrString (flags 0x0400)
    movew %a0@,%d1
    lea %fp@(8),%a0
    movew #2,%d0
    .short  0xA456	| 408200A8 _LwrString (flags 0x0400)
    cmpw %a0@,%d1
    seq %fp@(12)
    movew #4,%d0
    jbra STDUNLINK
    .long   0x00000000, 0x00000000	| 408200B8

/* NEXTFORMATCLASS: number format parser: next character class. */
NEXTFORMATCLASS:
    extw %d0
    addqw #1,%d0
    cmpiw #3,%d0
    jbne NEXTFORMATCLASS_C
    moveq #0,%d0
NEXTFORMATCLASS_C:      /* return */
    rts
    .short  0x0000	| 408200CE

/* GETSANECLASS: the SANE class of a number. */
GETSANECLASS:
    clrw %sp@-
    moveal %sp,%a0
    movel %a1,%sp@-
    movel %a0,%sp@-
    movew #28,%sp@-
    _FP68K
    movew %sp@+,%d0
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408200E2

/* SENDBYTE: output a byte (number formatting). */
SENDBYTE:
    moveb %d0,%d1
    jbeq SENDBYTE_12
    moveq #8,%d0
    movew %a1@,%d2
SENDBYTE_8:             /* room left in the output string? */
    cmpb %a0@,%d2
    jbcc SENDBYTE_14
SENDBYTE_C:             /* append the byte */
    moveb %d1,%a0@(0x0,%d2:w)
    addqw #1,%a1@
SENDBYTE_12:            /* OK */
    moveq #0,%d0
SENDBYTE_14:            /* return */
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40820106

/* SENDCHARREV0: output a character backwards. */
SENDCHARREV0:
    .short  0xE058	| 40820110

/* SENDCHAR0: output a character. */
SENDCHAR0:
    movew %d0,%sp@-
    moveb %sp@,%d0
    jbsr SENDBYTE
    movew %sp@+,%d0
    jbsr SENDBYTE
    rts
    .short  0x0000	| 4082011E

/* SENDCHARREV: output a character backwards. */
SENDCHARREV:
    moveb %sp@(12),%d0
    moveb %sp@(13),%sp@(12)
    moveb %d0,%sp@(13)

/* SENDCHAR: output a character. */
SENDCHAR:
    movel %sp@+,%d2
    moveal %sp@+,%a1
    moveal %sp@+,%a0
    movew %sp@+,%d0
    movel %d2,%sp@-
    jbsr SENDCHAR0
    movew %d0,%sp@(4)
    rts

/* INUNQUOTEDS: inside an unquoted part of a format?. */
INUNQUOTEDS:
RETRIEVECHAR:
    linkw %fp,#-2
    moveml %d7/%a2-%a4,%sp@-
    moveal %fp@(12),%a3
    moveal %fp@(8),%a4
    clrw %fp@(16)
    moveal %a4@(20),%a2
    clrw %d0
    moveb %a2@,%d0
    cmpw %a3@,%d0
    jblt INUNQUOTEDS_66
    clrw %sp@-
    pea %a2@(1)
    movew %a3@,%d0
    subqw #1,%d0
    movew %d0,%sp@-
    movel #-2113535984,%sp@-
    _ScriptUtil
    movew %sp@+,%d7
    jbne INUNQUOTEDS_48
    movew %a3@,%d0
    clrw %d1
    moveb %a2@(0x0,%d0:w),%d1
    movew %d1,%fp@(16)
    addqw #1,%a3@
    jbra INUNQUOTEDS_66
INUNQUOTEDS_48:         /* a two-byte character, if it fits */
    jbpl INUNQUOTEDS_60
    movew %a3@,%d0
    cmpb %a2@,%d0
    jbge INUNQUOTEDS_60
    moveb %a2@(0x0,%d0:w),%fp@(16)
    moveb %a2@(0x1,%d0:w),%fp@(17)
    addqw #2,%a3@
    jbra INUNQUOTEDS_66
INUNQUOTEDS_60:         /* past the end: error */
    movew #2,%a4@(24)
INUNQUOTEDS_66:         /* restore registers */
    moveml %sp@+,%d7/%a2-%a4
    movew #8,%d0
    jbra STDUNLINK
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408201B2

/* CHECKEXP: exponent part. */
CHECKEXP:
    linkw %fp,#-4
    moveml %d6-%d7/%a2-%a4,%sp@-
    moveal %fp@(8),%a2
    moveal %a2@(8),%a3
    moveal %a3@(16),%a4
    addqw #2,%a4
    moveal %fp@(12),%a0
    tstw %a0@
    jblt CHECKEXP_34
    movew %a0@(2),%d6
    jbeq CHECKEXP_34
    movew #30,%d7
CHECKEXP_28:            /* the exponent's first character must not also be a format character */
    cmpw %a4@+,%d6
    dbeq %d7,CHECKEXP_28
    jbne CHECKEXP_34
    clrb %a2@(12)
CHECKEXP_34:            /* restore registers */
    moveml %sp@+,%d6-%d7/%a2-%a4
    movew #8,%d0
    jbra STDUNLINK

/* CHECKPARTSINTEGRITY: consistency of the format parts. */
CHECKPARTSINTEGRITY:
    linkw %fp,#-6
    moveml %d5-%d7/%a4,%sp@-
    moveal %fp@(8),%a0
    moveal %a0@(16),%a4
    st %fp@(12)
    cmpiw #1,%a4@
    jbne CHECKPARTSINTEGRITY_9E
    moveq #1,%d7
    jbra CHECKPARTSINTEGRITY_64
CHECKPARTSINTEGRITY_20: /* per parts table entry 1..30: no other entry may be the same character */
    movew %d7,%d0
    addw %d0,%d0
    movew %a4@(0x0,%d0:w),%d5
    jbeq CHECKPARTSINTEGRITY_62
    movew %d7,%d6
    addqw #1,%d6
    jbra CHECKPARTSINTEGRITY_5C
CHECKPARTSINTEGRITY_30: /* compare with each later entry; only the quotes (1, 2) and lead placer/leader (3, 4) may match */
    movew %d6,%d0
    addw %d0,%d0
    cmpw %a4@(0x0,%d0:w),%d5
    jbne CHECKPARTSINTEGRITY_5A
    cmpiw #3,%d7
    seq %d0
    cmpiw #4,%d6
    seq %d1
    andb %d1,%d0
    cmpiw #1,%d7
    seq %d1
    cmpiw #2,%d6
    seq %d2
    andb %d2,%d1
    orb %d1,%d0
    jbeq CHECKPARTSINTEGRITY_9E
CHECKPARTSINTEGRITY_5A: /* next */
    addqw #1,%d6
CHECKPARTSINTEGRITY_5C: /* up to entry 31 */
    cmpiw #31,%d6
    jble CHECKPARTSINTEGRITY_30
CHECKPARTSINTEGRITY_62: /* next entry */
    addqw #1,%d7
CHECKPARTSINTEGRITY_64: /* the E+ and E- strings; then no control characters in the table */
    cmpiw #30,%d7
    jble CHECKPARTSINTEGRITY_20
    pea %a4@(64)
    movel %fp,%sp@-
    jsr %pc@(CHECKEXP)
    pea %a4@(86)
    movel %fp,%sp@-
    jsr %pc@(CHECKEXP)
    lea %a4@(2),%a0
    movew #31,%d7
CHECKPARTSINTEGRITY_86: /* loop over the 31 entries */
    subqw #1,%d7
    jblt CHECKPARTSINTEGRITY_96
    movew %a0@+,%d0
    jbeq CHECKPARTSINTEGRITY_86
    cmpib #32,%d0
    jbcc CHECKPARTSINTEGRITY_86
    jbra CHECKPARTSINTEGRITY_9E
CHECKPARTSINTEGRITY_96: /* the alternate digit table (+130) must hold 10 entries (size 9) */
    cmpiw #9,%a4@(130)
    jbeq CHECKPARTSINTEGRITY_A2
CHECKPARTSINTEGRITY_9E: /* bad parts table: false */
    sf %fp@(12)
CHECKPARTSINTEGRITY_A2:  /* restore registers, return */
    moveml %sp@+,%d5-%d7/%a4
    unlk %fp
    movel %sp@+,%sp@
    rts
    .long   0x00000000	| 408202AC

/* ISSUBSTRING: is a string a substring of another?. */
ISSUBSTRING:
    linkw %fp,#-6	| 408202B0
    moveml %d7/%a3-%a4,%sp@-	| 408202B4
    moveal %fp@(8),%a3	| 408202B8
    moveal %a3@(8),%a4	| 408202BC
    moveq #1,%d7	| 408202C0
    movew %a4@(-8),%fp@(-6)	| 408202C2
    sf %fp@(12)	| 408202C8
    moveal %a3@(16),%a0	| 408202CC
    jbra ISSUBSTRING_5E	| 408202D0
ISSUBSTRING_22:         /* compare at the next position through the script's compare routine */
    moveal %a4@(20),%a0	| 408202D2
    clrw %d0	| 408202D6
    moveb %a0@,%d0	| 408202D8
    cmpw %fp@(-6),%d0	| 408202DA
    jblt ISSUBSTRING_6C	| 408202DE
    clrw %sp@-	| 408202E0
    pea %fp@(-6)	| 408202E2
    movel %a4,%sp@-	| 408202E6
    moveal IntlSpec,%a0	| 408202E8
    moveal %a0@(492),%a0	| 408202EC
    jsr %a0@	| 408202F0
    movew %sp@+,%a4@(-4)	| 408202F2
    moveal %a3@(16),%a0	| 408202F6
    movew %d7,%d0	| 408202FA
    addw %d0,%d0	| 408202FC
    movew %a4@(-4),%d1	| 408202FE
    cmpw %a0@(2,%d0:w),%d1	| 40820302
    jbne ISSUBSTRING_6C	| 40820306
    addqw #1,%d7	| 40820308
    moveal %a3@(16),%a0	| 4082030A
ISSUBSTRING_5E:         /* loop; found: advance past it, true */
    cmpw %a0@,%d7	| 4082030E
    jble ISSUBSTRING_22	| 40820310
    movew %fp@(-6),%a4@(-8)	| 40820312
    st %fp@(12)	| 40820318
ISSUBSTRING_6C:         /* restore registers, return */
    moveml %sp@+,%d7/%a3-%a4	| 4082031C
    unlk %fp	| 40820320
    movel %sp@+,%sp@	| 40820322
    rts	| 40820324
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40820326

/* MAKEEXP: build the exponent. */
MAKEEXP:
    linkw %fp,#0
    moveml %a3-%a4,%sp@-
    moveal %fp@(8),%a4
    moveal %a4@(12),%a3
    sf %fp@(20)
    clrw %sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(496),%a0
    jsr %a0@
    moveb %sp@+,%d0
    jbeq MAKEEXP_6E
    movew %a4@(-16),%d0
    andil #1536,%d0
    jbeq MAKEEXP_3A
    movew #7,%a4@(24)
    jbra MAKEEXP_6A
MAKEEXP_3A:             /* first exponent of the part: remember where it starts */
    btst #4,%a4@(-16)
    jbne MAKEEXP_50
    moveb %a4@(-1),%d0
    extw %d0
    addw %d0,%d0
    movew %a4@(-6),%a3@(0x2,%d0:w)
MAKEEXP_50:             /* mark the exponent as seen, store its token */
    movew %fp@(14),%d0
    movew %d0,%d1
    asrw #3,%d0
    bset %d1,%a4@(0xfffffffffffffff0,%d0:w)
    movew %a4@(-6),%d0
    moveb %fp@(13),%a3@(0x2c,%d0:w)
    addqw #1,%a4@(-6)
MAKEEXP_6A:             /* true */
    st %fp@(20)
MAKEEXP_6E:             /* restore registers */
    moveml %sp@+,%a3-%a4
    movew #12,%d0
    jbra STDUNLINK
    .short  0x0000, 0x0000, 0x0000	| 408203AA

/* PROCESSLEAD: leading part of a format. */
PROCESSLEAD:
    moveal %fp@(12),%a0
    movew %fp@(-6),%d1
    moveb %d0,%a0@(0x2c,%d1:w)
    addqw #1,%fp@(-6)
    movew %fp@(-16),%d0
    andil #1536,%d0
    jbne PROCESSLEAD_36
    moveb %fp@(-1),%d0
    extw %d0
    addw %d0,%d0
    btst #4,%fp@(-16)
    jbeq PROCESSLEAD_32
    addqw #1,%a0@(0x14,%d0:w)
    jbra PROCESSLEAD_36
PROCESSLEAD_32:         /* count the digit placeholder */
    addqw #1,%a0@(0xe,%d0:w)
PROCESSLEAD_36:         /* return */
    rts
    .long   0x00000000, 0x00000000	| 408203E8

/* GETC: next character. */
GETC:
    clrw %sp@-
    pea %fp@(-8)
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(492),%a0
    jsr %a0@
    movew %sp@+,%fp@(-4)
    rts
    .long   0x00000000, 0x00000000	| 40820408

/* XSTR2FORM: _Str2Format: compile a number format string. */
XSTR2FORM:
    linkw %fp,#-16
    moveml %d3-%d7/%a3-%a4,%sp@-
    clrw %fp@(24)
    moveq #0,%d6
    clrw %sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(488),%a0
    jsr %a0@
    moveb %sp@+,%d0
    jbne XSTR2FORM_2A
    movew #10,%fp@(24)
    jbra XSTR2FORM_3C4
XSTR2FORM_2A:           /* clear the three parts (positive, negative, zero) */
    moveal %fp@(12),%a4
    moveal %fp@(16),%a3
    moveq #4,%d3
XSTR2FORM_34:           /* loop over the parts */
    clrw %a4@(0x1a,%d3:w)
    clrw %a4@(0x2,%d3:w)
    movew #1,%a4@(0x8,%d3:w)
    clrw %a4@(0xe,%d3:w)
    clrw %a4@(0x14,%d3:w)
    subqb #2,%d3
    jbpl XSTR2FORM_34
    clrb %fp@(-1)
    cmpiw #35,%a3@(10)
    sne %d4
    jbeq XSTR2FORM_64
    movew #8448,%fp@(-16)
    jbra XSTR2FORM_6A
XSTR2FORM_64:           /* initial flags */
    movew #256,%fp@(-16)
XSTR2FORM_6A:           /* start of the compiled form; empty format string: fEmptyFormatString */
    moveq #1,%d0
    movew %d0,%fp@(-8)
    movew %d0,%fp@(-6)
    moveb #0xd3,%a4@(44)
    moveal %fp@(20),%a0
    moveb %a0@,%d0
    jbeq XSTR2FORM_336
    st %d5
XSTR2FORM_86:           /* per character: room left? else fFormatOverflow */
    moveb %d5,%d0
    jbeq XSTR2FORM_340
    clrw %d0
    moveb %a4@(44),%d0
    cmpw %fp@(-6),%d0
    jbge XSTR2FORM_A2
    movew #8,%fp@(24)
    jbra XSTR2FORM_3C4
XSTR2FORM_A2:           /* next character; which token is it in the parts table? */
    jsr %pc@(GETC)
    clrw %d7
XSTR2FORM_A8:           /* loop over the tokens 1..15 */
    addqw #1,%d7
    cmpiw #14,%d7
    jbgt XSTR2FORM_BE
    movew %d7,%d1
    addw %d1,%d1
    movew %fp@(-4),%d2
    cmpw %a3@(0x0,%d1:w),%d2
    jbne XSTR2FORM_A8
XSTR2FORM_BE:           /* dispatch on the token; not a token: a literal character */
    movew %d7,%d0
    subqw #1,%d0
    jbmi XSTR2FORM_322
    cmpiw #14,%d0
    jbgt XSTR2FORM_322
    addw %d0,%d0
    movew %pc@(XSTR2FORM_D8,%d0:w),%d0
XSTR2FORM_D4:           /* jump through the table */
    jmp %pc@(0,%d0:w)
XSTR2FORM_D8:           /* per token: left quote, right quote, lead placer, leader, ..., decimal point, exponent */
    .short  XSTR2FORM_F6-XSTR2FORM_D6	| 408204E8
    .short  XSTR2FORM_14C-XSTR2FORM_D6	| 408204EA
    .short  XSTR2FORM_160-XSTR2FORM_D6	| 408204EC
    .short  XSTR2FORM_25A-XSTR2FORM_D6	| 408204EE
    .short  XSTR2FORM_156-XSTR2FORM_D6	| 408204F0
    .short  XSTR2FORM_156-XSTR2FORM_D6	| 408204F2
    .short  XSTR2FORM_1A2-XSTR2FORM_D6	| 408204F4
    .short  XSTR2FORM_24A-XSTR2FORM_D6	| 408204F6
    .short  XSTR2FORM_24A-XSTR2FORM_D6	| 408204F8
    .short  XSTR2FORM_24A-XSTR2FORM_D6	| 408204FA
    .short  XSTR2FORM_25A-XSTR2FORM_D6	| 408204FC
    .short  XSTR2FORM_1C8-XSTR2FORM_D6	| 408204FE
    .short  XSTR2FORM_25A-XSTR2FORM_D6	| 40820500
    .short  XSTR2FORM_16C-XSTR2FORM_D6	| 40820502
    .short  XSTR2FORM_264-XSTR2FORM_D6	| 40820504
XSTR2FORM_F6:           /* left quote: copy the literal up to the right quote */
    jsr %pc@(GETC)
    movew %fp@(-4),%d0
    cmpw %a3@(26),%d0
    jbne XSTR2FORM_11E
    jsr %pc@(GETC)
    clrw %sp@-
    movew %fp@(-4),%sp@-
    pea %a4@(44)
    pea %fp@(-6)
    jsr %pc@(SENDCHAR)
    orw %sp@+,%d6
    jbra XSTR2FORM_F6
XSTR2FORM_11E:          /* literal character */
    movew %fp@(-4),%d0
    jbeq XSTR2FORM_142
    cmpw %a3@(4),%d0
    jbeq XSTR2FORM_322
    clrw %sp@-
    movew %fp@(-4),%sp@-
    pea %a4@(44)
    pea %fp@(-6)
    jsr %pc@(SENDCHAR)
    orw %sp@+,%d6
    jbra XSTR2FORM_F6
XSTR2FORM_142:          /* no right quote: fMissingLiteral */
    movew #6,%fp@(24)
    jbra XSTR2FORM_322
XSTR2FORM_14C:          /* right quote without left: fMissingDelimiter */
    movew #4,%fp@(24)
    jbra XSTR2FORM_322
XSTR2FORM_156:          /* a digit placeholder */
    movew %d7,%d0
    jsr %pc@(PROCESSLEAD)
    jbra XSTR2FORM_322
XSTR2FORM_160:          /* lead placer */
    movew #4,%d0
    jsr %pc@(PROCESSLEAD)
    jbra XSTR2FORM_322
XSTR2FORM_16C:          /* decimal point: a second one is fExtraDecimal */
    btst #4,%fp@(-16)
    jbeq XSTR2FORM_17C
    movew #5,%fp@(24)
    jbra XSTR2FORM_19E
XSTR2FORM_17C:          /* emit it, remember its position */
    movew %fp@(-6),%d0
    moveb #14,%a4@(0x2c,%d0:w)
    moveb %fp@(-1),%d0
    extw %d0
    addw %d0,%d0
    movew %fp@(-6),%a4@(0x2,%d0:w)
    addqw #1,%fp@(-6)
    bset #4,%fp@(-16)
XSTR2FORM_19E:          /* next */
    jbra XSTR2FORM_322
XSTR2FORM_1A2:          /* percent: a second one is fExtraPercent */
    btst #3,%fp@(-16)
    jbeq XSTR2FORM_1B2
    movew #11,%fp@(24)
    jbra XSTR2FORM_1C4
XSTR2FORM_1B2:          /* emit it */
    bset #3,%fp@(-16)
    movew %fp@(-6),%d0
    moveb %d7,%a4@(0x2c,%d0:w)
    addqw #1,%fp@(-6)
XSTR2FORM_1C4:          /* next */
    jbra XSTR2FORM_322
XSTR2FORM_1C8:          /* separator: a third part is fExtraSeparator */
    cmpib #2,%fp@(-1)
    jbne XSTR2FORM_1D8
    movew #12,%fp@(24)
    jbra XSTR2FORM_246
XSTR2FORM_1D8:          /* close the current part */
    moveb %fp@(-1),%d1
    extw %d1
    addw %d1,%d1
    movew %fp@(-16),%d0
    andil #5632,%d0
    jbne XSTR2FORM_1F2
    movew %fp@(-6),%a4@(0x2,%d1:w)
XSTR2FORM_1F2:          /* a part with no digits: empty */
    movew %a4@(0xe,%d1:w),%d0
    addw %a4@(0x14,%d1:w),%d0
    jbne XSTR2FORM_21C
    movew %fp@(-6),%d0
    cmpw %a4@(0x8,%d1:w),%d0
    jble XSTR2FORM_210
    movew %fp@(-16),%d0
    andiw #7680,%d0
    jbeq XSTR2FORM_21C
XSTR2FORM_210:          /* empty part */
    clrw %a4@(0x1a,%d1:w)
    movew #13,%d6
    jbra XSTR2FORM_388
XSTR2FORM_21C:          /* store its flags, start the next part */
    movew %fp@(-16),%a4@(0x1a,%d1:w)
    addqb #1,%fp@(-1)
    moveb %d4,%d0
    jbeq XSTR2FORM_232
    movew #8448,%fp@(-16)
    jbra XSTR2FORM_238
XSTR2FORM_232:          /* default flags */
    movew #256,%fp@(-16)
XSTR2FORM_238:          /* its start */
    moveb %fp@(-1),%d0
    extw %d0
    addw %d0,%d0
    movew %fp@(-6),%a4@(0x8,%d0:w)
XSTR2FORM_246:          /* next */
    jbra XSTR2FORM_322
XSTR2FORM_24A:          /* plus, minus, thousands: emit the token */
    movew %fp@(-6),%d0
    moveb %d7,%a4@(0x2c,%d0:w)
    addqw #1,%fp@(-6)
    jbra XSTR2FORM_322
XSTR2FORM_25A:          /* fSpuriousChars */
    movew #3,%fp@(24)
    jbra XSTR2FORM_322
XSTR2FORM_264:          /* exponent strings (E+, E-) */
    clrw %sp@-
    movew %fp@(-4),%sp@-
    movew %a3@(66),%sp@-
    jsr %pc@(CHARCOMP)
    tstb %sp@+
    jbeq XSTR2FORM_2BA
    clrw %sp@-
    pea %a3@(64)
    movew #1,%sp@-
    movew #15,%sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(484),%a0
    jsr %a0@
    moveb %sp@+,%d0
    jbne XSTR2FORM_2B8
    clrw %sp@-
    pea %a3@(86)
    movew #2,%sp@-
    movew #16,%sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(484),%a0
    jsr %a0@
    moveb %sp@+,%d0
    jbne XSTR2FORM_2B8
    movew #3,%fp@(24)
XSTR2FORM_2B8:          /* next */
    jbra XSTR2FORM_322
XSTR2FORM_2BA:          /* E- */
    clrw %sp@-
    movew %fp@(-4),%sp@-
    movew %a3@(88),%sp@-
    jsr %pc@(CHARCOMP)
    tstb %sp@+
    jbeq XSTR2FORM_2F2
    clrw %sp@-
    pea %a3@(86)
    movew #2,%sp@-
    moveq #16,%d0
    movew %d0,%sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(484),%a0
    jsr %a0@
    moveb %sp@+,%d0
    jbne XSTR2FORM_2F0
    movew #3,%fp@(24)
XSTR2FORM_2F0:          /* next */
    jbra XSTR2FORM_322
XSTR2FORM_2F2:          /* other characters: allowed as literals? */
    lea %a3@(60),%a1
XSTR2FORM_2F6:          /* search the literal characters list */
    movew %fp@(-4),%d1
    jbeq XSTR2FORM_31C
    moveq #15,%d2
XSTR2FORM_2FE:          /* loop; found: emit it */
    cmpw %a1@-,%d1
    dbeq %d2,XSTR2FORM_2FE
    jbne XSTR2FORM_31C
    clrw %sp@-
    movew %fp@(-4),%sp@-
    pea %a4@(44)
    pea %fp@(-6)
    jsr %pc@(SENDCHAR)
    orw %sp@+,%d6
    jbra XSTR2FORM_322
XSTR2FORM_31C:          /* fSpuriousChars */
    movew #3,%fp@(24)
XSTR2FORM_322:          /* end of the format string? */
    moveal %fp@(20),%a0
    clrw %d0
    moveb %a0@,%d0
    cmpw %fp@(-8),%d0
    jbge XSTR2FORM_332
    sf %d5
XSTR2FORM_332:          /* next character */
    jbra XSTR2FORM_86
XSTR2FORM_336:          /* empty: fEmptyFormatString */
    movew #13,%d6
    bclr #0,%fp@(-16)
XSTR2FORM_340:          /* close the last part */
    moveb %fp@(-1),%d1
    extw %d1
    addw %d1,%d1
    movew %a4@(0xe,%d1:w),%d0
    addw %a4@(0x14,%d1:w),%d0
    jbne XSTR2FORM_36E
    movew %fp@(-6),%d0
    cmpw %a4@(0x8,%d1:w),%d0
    jble XSTR2FORM_366
    movew %fp@(-16),%d0
    andiw #7680,%d0
    jbeq XSTR2FORM_36E
XSTR2FORM_366:          /* empty part */
    clrw %fp@(-16)
    movew #13,%d6
XSTR2FORM_36E:          /* store its flags */
    movew %fp@(-16),%a4@(0x1a,%d1:w)
    moveq #0,%d0
    movew %fp@(-16),%d0
    andil #5632,%d0
    jbne XSTR2FORM_388
    movew %fp@(-6),%a4@(0x2,%d1:w)
XSTR2FORM_388:          /* one part only: it is also the negative and zero format */
    cmpib #0,%fp@(-1)
    jbne XSTR2FORM_39E
    movew %fp@(-6),%a4@(10)
XSTR2FORM_396:          /* zero format */
    movew %fp@(-6),%a4@(12)
    jbra XSTR2FORM_3A6
XSTR2FORM_39E:          /* two parts: the zero format is the positive one */
    cmpib #1,%fp@(-1)
    jbeq XSTR2FORM_396
XSTR2FORM_3A6:          /* total length; the result */
    movew %fp@(-6),%a4@(8)
    movew %fp@(-6),%d0
    subqw #1,%d0
    moveb %d0,%a4@(44)
    addib #44,%d0
    moveb %d0,%a4@
    tstw %d6
    jbeq XSTR2FORM_3C4
    movew %d6,%fp@(24)
XSTR2FORM_3C4:          /* return */
    clrb %a4@(1)
    moveml %sp@+,%d3-%d7/%a3-%a4
    movew #16,%d0
    jbra STDUNLINK
    .long   0x00000000, 0x00000000, 0x00000000	| 408207E4

/* TACKONEXP: append the exponent. */
TACKONEXP:
    linkw %fp,#-4	| 408207F0
    moveml %d7/%a2-%a4,%sp@-	| 408207F4
    moveal %fp@(8),%a3
    moveal %a3@(8),%a4
    moveal %fp@(12),%a2
    movew %a2@,%fp@(-4)
    lea %a2@(2),%a2
    clrw %d7
    jbra TACKONEXP_36
TACKONEXP_20:           /* append each character of the exponent string */
    clrw %sp@-
    movew %a2@+,%sp@-
    pea %a3@(-50)
    pea %a3@(-52)
    jsr %pc@(SENDCHAR)
    movew %sp@+,%a4@(-2)
    addqw #1,%d7
TACKONEXP_36:           /* loop */
    cmpw %fp@(-4),%d7
    jble TACKONEXP_20
    moveml %sp@+,%d7/%a2-%a4
    movew #8,%d0
    jbra STDUNLINK
    .long   0x00000000, 0x00000000	| 40820838

/* TRANSLATETOTEXT: translate a compiled format back to text. */
TRANSLATETOTEXT:
    linkw %fp,#-54
    moveml %d7/%a3-%a4,%sp@-
    movew %fp@(12),%d7
    moveal %fp@(8),%a4
    moveal %a4@(20),%a3
    movew #1,%fp@(-52)
    moveb #49,%fp@(-50)
    cmpiw #32,%d7
    jbge TRANSLATETOTEXT_AE
    tstb %a4@(-13)
    jbeq TRANSLATETOTEXT_48
    sf %a4@(-13)
    clrw %sp@-
    movew %a3@(2),%sp@-
    pea %fp@(-50)
    pea %fp@(-52)
    jsr %pc@(SENDCHAR)
    movew %sp@+,%a4@(-2)
TRANSLATETOTEXT_48:     /* tokens that are printed as their parts table character */
    movel #18416,%d0
    btst %d7,%d0
    jbne TRANSLATETOTEXT_60
    cmpiw #15,%d7
    jbeq TRANSLATETOTEXT_96
    cmpiw #16,%d7
    jbeq TRANSLATETOTEXT_9C
    jbra TRANSLATETOTEXT_86
TRANSLATETOTEXT_60:     /* the token's character (leader for lead placer) */
    clrw %sp@-
    movew #6,%d0
    cmpiw #4,%d7
    jbeq TRANSLATETOTEXT_70
    movew %d7,%d0
    addw %d0,%d0
TRANSLATETOTEXT_70:     /* append it */
    movew %a3@(0x0,%d0:w),%sp@-
    pea %fp@(-50)
    pea %fp@(-52)
    jsr %pc@(SENDCHAR)
    movew %sp@+,%a4@(-2)
    jbra TRANSLATETOTEXT_104
TRANSLATETOTEXT_86:     /* unknown: '???' */
    movel #54476607,%fp@(-50)
    movew #4,%fp@(-52)
    jbra TRANSLATETOTEXT_104
TRANSLATETOTEXT_96:     /* E+ */
    pea %a3@(64)
    jbra TRANSLATETOTEXT_A0
TRANSLATETOTEXT_9C:     /* E- */
    pea %a3@(86)
TRANSLATETOTEXT_A0:     /* append the exponent string */
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(480),%a0
    jsr %a0@
    jbra TRANSLATETOTEXT_104
TRANSLATETOTEXT_AE:     /* a literal character: open the quote first */
    tstb %a4@(-13)
    jbne TRANSLATETOTEXT_CE
    clrw %sp@-
    movew %a3@(2),%sp@-
    pea %fp@(-50)
    pea %fp@(-52)
    jsr %pc@(SENDCHAR)
    movew %sp@+,%a4@(-2)
    st %a4@(-13)
TRANSLATETOTEXT_CE:     /* quote characters inside a literal are escaped */
    movew %a3@(26),%d0
    cmpw %d0,%d7
    jbeq TRANSLATETOTEXT_DC
    cmpw %a3@(4),%d7
    jbne TRANSLATETOTEXT_F0
TRANSLATETOTEXT_DC:     /* append the escape */
    clrw %sp@-
    movew %d0,%sp@-
    pea %fp@(-50)
    pea %fp@(-52)
    jsr %pc@(SENDCHAR)
    movew %sp@+,%a4@(-2)
TRANSLATETOTEXT_F0:     /* append the character */
    clrw %sp@-
    movew %d7,%sp@-
    pea %fp@(-50)
    pea %fp@(-52)
    jsr %pc@(SENDCHAR)
    movew %sp@+,%a4@(-2)
TRANSLATETOTEXT_104:    /* copy the text to the output string */
    movew %fp@(-52),%d0
    subqw #1,%d0
    moveb %d0,%fp@(-50)
    clrw %d0
    moveb %fp@(-50),%d0
    movew %d0,%fp@(-54)
    movew #1,%fp@(-52)
    jbra TRANSLATETOTEXT_140
TRANSLATETOTEXT_120:    /* one character */
    moveal %a4@(16),%a0
    movew %a4@(-4),%d0
    movew %fp@(-52),%d1
    clrw %d2
    lea %fp@(-50),%a1
    moveb %a1@(0x0,%d1:w),%a0@(0x0,%d0:w)
    addqw #1,%a4@(-4)
    addqw #1,%fp@(-52)
TRANSLATETOTEXT_140:    /* loop */
    movew %fp@(-52),%d0
    cmpw %fp@(-54),%d0
    jble TRANSLATETOTEXT_120
    moveml %sp@+,%d7/%a3-%a4
    movew #6,%d0
    jbra STDUNLINK
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40820996

/* CHECKFORM: check a format. */
CHECKFORM:
    linkw %fp,#-6	| 408209A0
    moveml %d3-%d7/%a2-%a4,%sp@-	| 408209A4
    moveb %fp@(12),%d7	| 408209A8
    moveal %fp@(8),%a4	| 408209AC
    moveal %a4@(24),%a3	| 408209B0
    moveal %a4@(20),%a0	| 408209B4
    movel %a0,%fp@(-4)	| 408209B8
    clrw %d5	| 408209BC
    moveb %d7,%d3	| 408209BE
    extw %d3	| 408209C0
    addw %d3,%d3	| 408209C2
    moveb %d7,%d0	| 408209C4
    jsr %pc@(NEXTFORMATCLASS)	| 408209C6
    addw %d0,%d0	| 408209CA
    movew %a3@(8,%d0:w),%d2	| 408209CC
    subqw #1,%d2	| 408209D0
    movew %d2,%fp@(-6)	| 408209D2
    moveq #1,%d6	| 408209D6
    tstw %d7	| 408209D8
    jbeq CHECKFORM_5A	| 408209DA
    movew %a3@(8,%d3:w),%d6	| 408209DC
    cmpw %d6,%d2	| 408209E0
    jblt CHECKFORM_B4	| 408209E2
    movew #24,%d0	| 408209E4
    jbsr CHECKFORM_C0	| 408209E8
    moveal %a4@(12),%a0	| 408209EA
    moveb %d7,%d0	| 408209EE
    extw %d0	| 408209F0
    aslw #2,%d0	| 408209F2
    movew %a4@(-4),%a0@(0,%d0:w)	| 408209F4
CHECKFORM_5A:           /* per token of the part */
    jbra CHECKFORM_88	| 408209FA
CHECKFORM_5C:           /* a token (two bytes for a double-byte character) */
    clrw %d1	| 408209FC
    lea %a3@(0x2c,%d6:w),%a0	| 408209FE
    moveb %a0@+,%d5	| 40820A02
    clrw %sp@-	| 40820A04
    movel %a0,%sp@-	| 40820A06
    clrw %sp@-	| 40820A08
    movel #-2113535984,%sp@-	| 40820A0A
    _ScriptUtil	| 40820A10
    tstw %sp@+	| 40820A12
    jbeq CHECKFORM_7C	| 40820A14
    aslw #8,%d5	| 40820A16
    moveb %a0@,%d5	| 40820A18
    addqw #1,%d6	| 40820A1A
CHECKFORM_7C:           /* translate it */
    movew %d5,%sp@-	| 40820A1C
    movel %fp@(8),%sp@-	| 40820A1E
    jsr %pc@(TRANSLATETOTEXT)	| 40820A22
    addqw #1,%d6	| 40820A26
CHECKFORM_88:           /* loop; close an open quote */
    cmpw %fp@(-6),%d6	| 40820A28
    jble CHECKFORM_5C	| 40820A2C
    tstb %a4@(-13)
    jbeq CHECKFORM_9E
    sf %a4@(-13)
    movew #4,%d0
    jbsr CHECKFORM_C0
CHECKFORM_9E:           /* the part's length */
    moveal %a4@(12),%a0
    moveb %d7,%d0
    extw %d0
    aslw #2,%d0
    movew %a4@(-4),%d1
    subw %a0@(0x0,%d0:w),%d1
    movew %d1,%a0@(0x2,%d0:w)
CHECKFORM_B4:           /* restore registers */
    moveml %sp@+,%d3-%d7/%a2-%a4
    movew #6,%d0
    jbra STDUNLINK

CHECKFORM_C0:           /* append the parts table character %d0 */
    clrw %sp@-
    moveal %fp@(-4),%a0
    movew %a0@(0x0,%d0:w),%sp@-
    movel %a4@(16),%sp@-
    pea %a4@(-4)
    jsr %pc@(SENDCHAR)
    movew %sp@+,%a4@(-2)
    rts
    .long   0x00000000	| 40820A7C

/* XFORM2STR: _Format2Str: the format back to a string. */
XFORM2STR:
    linkw %fp,#-14
    moveml %d6-%d7/%a3-%a4,%sp@-
    clrw %fp@(28)
    clrw %fp@(-2)
    moveal %fp@(16),%a0
    moveb #0xff,%a0@
    moveal %fp@(12),%a0
    moveq #8,%d7
XFORM2STR_1E:           /* clear the three part positions in the result */
    clrw %a0@(0x0,%d7:w)
    clrw %a0@(0x2,%d7:w)
    subqb #4,%d7
    jbpl XFORM2STR_1E
    moveal %fp@(24),%a4
    tstb %a4@(44)
    jbeq XFORM2STR_82
    moveal %fp@(20),%a0
    movel %a0,%fp@(-10)
    movew #1,%fp@(-4)
    moveal %fp@(12),%a0
    movew #1,%a0@
    sf %fp@(-13)
    clrb %sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a3
    moveal %a3@(476),%a3
    jsr %a3@
    sf %fp@(-13)
    moveb #1,%sp@-
    movel %fp,%sp@-
    jsr %a3@
    sf %fp@(-13)
    moveb #2,%sp@-
    movel %fp,%sp@-
    jsr %a3@
    moveal %fp@(16),%a0
    movew %fp@(-4),%d0
    subqw #1,%d0
    moveb %d0,%a0@
    jbra XFORM2STR_8E
XFORM2STR_82:           /* empty format: fEmptyFormatString, empty string */
    movew #13,%fp@(-2)
    moveal %fp@(16),%a0
    clrb %a0@
XFORM2STR_8E:           /* return the result */
    tstw %fp@(-2)
    jbeq XFORM2STR_9A
    movew %fp@(-2),%fp@(28)
XFORM2STR_9A:           /* restore registers */
    moveml %sp@+,%d6-%d7/%a3-%a4
    movew #20,%d0
    jbra STDUNLINK
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40820B26
XFORM2STR_AE:           /* (padding) */
    .byte   0x00, 0x00	| 40820B2E
/* MATCHINGSUBSTRING (XFORM2STR_B0): does the number text at the current position match a
 character (exactly, or through CHARCOMP when the flag is set)? Advances past it if so. */
XFORM2STR_B0:           /* MatchingSubstring */
    linkw %fp,#0	| 40820B30
    moveml %d3/%a3-%a4,%sp@-	| 40820B34
    moveal %fp@(14),%a3
    moveal %fp@(8),%a4
    movew %a3@,%d2
    moveal %a4@(24),%a0
    addaw %d2,%a0
    sf %fp@(20)
    movew %fp@(18),%d0
    jbeq MATCHINGSUBSTRING_62
    cmpiw #255,%d0
    jbls MATCHINGSUBSTRING_38
    cmpw %a4@(-14),%d2
    jbge MATCHINGSUBSTRING_62
    moveq #2,%d3
    moveb %a0@+,%d1
    lslw #8,%d1
    moveb %a0@,%d1
    jbra MATCHINGSUBSTRING_44
MATCHINGSUBSTRING_38:   /* within the text: compare one character */
    cmpw %a4@(-14),%d2
    jbgt MATCHINGSUBSTRING_62
    clrw %d1
    moveb %a0@,%d1
    moveq #1,%d3
MATCHINGSUBSTRING_44:   /* case/diacritical insensitive compare */
    tstw %fp@(12)
    jbeq MATCHINGSUBSTRING_58
    clrw %sp@-
    movew %d0,%sp@-
    movew %d1,%sp@-
    jsr %pc@(CHARCOMP)
    notb %sp@+
    jbra MATCHINGSUBSTRING_5A
MATCHINGSUBSTRING_58:   /* exact compare */
    cmpw %d0,%d1
MATCHINGSUBSTRING_5A:   /* match: advance, true */
    jbne MATCHINGSUBSTRING_62
    addw %d3,%a3@
    st %fp@(20)
MATCHINGSUBSTRING_62:   /* restore registers */
    moveml %sp@+,%d3/%a3-%a4
    movew #12,%d0
    jbra STDUNLINK
    .short  0x0000	| 40820B9E

/* MATCHINGBLOCKS: match the blocks of a number with the format. */
MATCHINGBLOCKS:
    linkw %fp,#-6
    moveml %d7/%a2-%a4,%sp@-
    moveal %fp@(8),%a3
    moveal %fp@(12),%a4
    movew %a3@(-18),%fp@(-2)
    sf %fp@(16)
    movew %a4@,%d7
    jblt MATCHINGBLOCKS_4C
    lea %a4@(2),%a4
    moveal IntlSpec,%a2
    moveal %a2@(468),%a2
MATCHINGBLOCKS_2A:      /* try each string of the list at the current position */
    clrw %sp@-
    movew %a4@+,%sp@-
    pea %fp@(-2)
    movew #1,%sp@-
    movel %a3,%sp@-
    jsr %a2@
    moveb %sp@+,%d0
    dbeq %d7,MATCHINGBLOCKS_2A
    jbeq MATCHINGBLOCKS_4C
    st %fp@(16)
    movew %fp@(-2),%a3@(-18)
MATCHINGBLOCKS_4C:      /* restore registers */
    moveml %sp@+,%d7/%a2-%a4
    movew #8,%d0
    jbra STDUNLINK
    .long   0x00000000, 0x00000000	| 40820BF8

/* CHECKFORDIGITS: digits?. */
CHECKFORDIGITS:
    linkw %fp,#-14	| 40820C00
    moveml %d5-%d7/%a2-%a4,%sp@-	| 40820C04
    moveal %fp@(8),%a4	| 40820C08
    sf %d5	| 40820C0C
    moveal %a4@(20),%a1	| 40820C0E
    moveal %a4@(16),%a3	| 40820C12
    lea %a4@(-276),%a2	| 40820C16
    addaw %a4@(-16),%a2	| 40820C1A
    moveal %a4@(24),%a0	| 40820C1E
    movew %a4@(-18),%d0	| 40820C22
    moveb %a0@(0,%d0:w),%d1	| 40820C26
    cmpib #48,%d1	| 40820C2A
    jblt CHECKFORDIGITS_4E	| 40820C2E
    cmpib #57,%d1	| 40820C30
    jbgt CHECKFORDIGITS_4E	| 40820C34
    moveb %d1,%a2@	| 40820C36
    addqw #1,%a4@(-16)	| 40820C38
    addqw #1,%a4@(-18)	| 40820C3C
    st %d5	| 40820C40
    cmpib #48,%d1	| 40820C42
    jbeq CHECKFORDIGITS_4C	| 40820C46
    moveb #127,%d5	| 40820C48
CHECKFORDIGITS_4C:      /* a digit at the current position? */
    jbra CHECKFORDIGITS_9C	| 40820C4C
CHECKFORDIGITS_4E:      /* try the ten alternate digits of the parts table (+132) */
    moveb %a4@(-8),%d0	| 40820C4E
    extw %d0	| 40820C52
    addw %d0,%d0	| 40820C54
    btst #5,%a1@(0x1a,%d0:w)	| 40820C56
    jbeq CHECKFORDIGITS_9C	| 40820C5C
    sf %d6	| 40820C5E
    movew #9,%d7	| 40820C60
    lea %a3@(132),%a3	| 40820C64
    moveal IntlSpec,%a1	| 40820C68
    moveal %a1@(468),%a1	| 40820C6C
CHECKFORDIGITS_70:      /* loop: compare; found: store its ASCII digit */
    clrw %sp@-	| 40820C70
    movew %a3@+,%sp@-	| 40820C72
    pea %a4@(-18)	| 40820C74
    clrw %sp@-	| 40820C78
    movel %a4,%sp@-	| 40820C7A
    jsr %a1@	| 40820C7C
    moveb %sp@+,%d6	| 40820C7E
    dbne %d7,CHECKFORDIGITS_70	| 40820C80
    jbeq CHECKFORDIGITS_9C	| 40820C84
    moveq #57,%d0	| 40820C86
    subb %d7,%d0	| 40820C88
    moveb %d0,%a2@	| 40820C8A
    addqw #1,%a4@(-16)	| 40820C8C
    st %d5	| 40820C90
    cmpib #48,%d0	| 40820C92
    jbeq CHECKFORDIGITS_9C	| 40820C96
    moveb #127,%d5	| 40820C98
CHECKFORDIGITS_9C:      /* return found */
    moveb %d5,%fp@(12)	| 40820C9C
    moveml %sp@+,%d5-%d7/%a2-%a4	| 40820CA0
    unlk %fp	| 40820CA4
    movel %sp@+,%sp@	| 40820CA6
    rts	| 40820CA8
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40820CAA

/* COND: condition helper. */
COND:
    linkw %fp,#0	| 40820CB0
    moveml %d3-%d5/%a2-%a4,%sp@-	| 40820CB4
    moveal %fp@(8),%a4
    moveal %a4@(8),%a3
    sf %a4@(16)
    lea %a3@(-276),%a2
    addaw %a3@(-16),%a2
    moveb %fp@(15),%d3
    movel %fp@(20),%d4
    moveq #1,%d5
COND_26:                /* match the first list; if not, the second */
    clrw %sp@-
    movel %d4,%sp@-
    movel %a3,%sp@-
    jsr %pc@(MATCHINGBLOCKS)
    moveb %sp@+,%d0
    jbne COND_46
    tstl %d5
    beqw COND_54
    moveb %fp@(13),%d3
    movel %fp@(16),%d4
    moveq #0,%d5
    jbra COND_26
COND_46:                /* matched: append 'E' and the sign to the digit string */
    moveb #69,%a2@+
    moveb %d3,%a2@
    addqw #2,%a3@(-16)
    st %a4@(16)
COND_54:                /* restore registers */
    moveml %sp@+,%d3-%d5/%a2-%a4
    movew #16,%d0
    jbra STDUNLINK

/* EXPMATCHING: exponent matching. */
EXPMATCHING:
    linkw %fp,#-4
    moveml %a3-%a4,%sp@-
    moveal %fp@(8),%a3
    moveal %a3@(16),%a4
    lea %a4@(86),%a1
    moveal IntlSpec,%a4
    moveal %a4@(472),%a4
    moveal %fp@(12),%a0
    movew %a0@,%d0
    cmpw %a1@,%d0
    jblt EXPMATCHING_36
    movel %a0,%sp@-
    movel %a1,%sp@-
    movel #2949163,%sp@-
    movel %fp,%sp@-
    jsr %a4@
    jbra EXPMATCHING_44
EXPMATCHING_36:         /* compare through the script's routine */
    movel %a1,%sp@-
    movel %a0,%sp@-
    movel #2818093,%sp@-
    movel %fp,%sp@-
    jsr %a4@
EXPMATCHING_44:         /* restore registers */
    moveml %sp@+,%a3-%a4
    movew #8,%d0
    jbra STDUNLINK

/* XFORMSTR2X: _FormStr2X: number string to extended with a format. */
XFORMSTR2X:
    linkw %fp,#-324
    moveml %d3-%d7/%a2-%a5,%sp@-
    sf %fp@(-6)
    moveal %fp@(24),%a0
    clrw %d0
    moveb %a0@,%d0
    movew %d0,%fp@(-14)
    moveb #49,%fp@(-275)
    moveal %fp@(20),%a3
    moveal %fp@(16),%a4
    lea %fp@(-8),%a2
    clrw %d0
    moveb %a3@(44),%d0
    movew %d0,%fp@(-10)
    sf %d5
    sf %fp@(-3)
    sf %fp@(-2)
    st %fp@(-4)
    clrw %a2@
    btst #0,%a3@(26)
    jbeq XFORMSTR2X_32C
    clrw %fp@(28)
    moveq #1,%d0
    movew %d0,%fp@(-18)
    movel %d0,%d7
    movew %d0,%fp@(-16)
    sf %fp@(-283)
    st %fp@(-323)
    clrw %d3
    movew %a4@(18),%d0
    jbsr XFORMSTR2X_15C
    moveb %d0,%fp@(-5)
    movew %fp@(-10),%d0
    jbeq XFORMSTR2X_43C
    cmpw %d0,%d7
    sle %d5
    movew %fp@(-18),%d1
    cmpw %fp@(-14),%d1
    sle %d1
    andb %d1,%d5
XFORMSTR2X_8C:          /* per format token, while text and format remain */
    moveb %d5,%d0
    jbeq XFORMSTR2X_310
    clrw %d4
    moveb %a3@(0x2c,%d7:w),%d4
    cmpiw #32,%d4
    jbge XFORMSTR2X_1AA
    movew %d4,%d0
    subqw #4,%d0
    jbmi XFORMSTR2X_15A
    cmpiw #12,%d0
    jbgt XFORMSTR2X_15A
    addw %d0,%d0
    movew %pc@(XFORMSTR2X_BA,%d0:w),%d0
XFORMSTR2X_B6:          /* jump through the table */
    jmp %pc@(0,%d0:w)
XFORMSTR2X_BA:          /* per format token class 4..16 */
    .short  XFORMSTR2X_D4-XFORMSTR2X_B8	| 40820E1A
    .short  XFORMSTR2X_EC-XFORMSTR2X_B8	| 40820E1C
    .short  XFORMSTR2X_D4-XFORMSTR2X_B8	| 40820E1E
    .short  XFORMSTR2X_12C-XFORMSTR2X_B8	| 40820E20
    .short  XFORMSTR2X_12C-XFORMSTR2X_B8	| 40820E22
    .short  XFORMSTR2X_12C-XFORMSTR2X_B8	| 40820E24
    .short  XFORMSTR2X_12C-XFORMSTR2X_B8	| 40820E26
    .short  XFORMSTR2X_15A-XFORMSTR2X_B8	| 40820E28
    .short  XFORMSTR2X_15A-XFORMSTR2X_B8	| 40820E2A
    .short  XFORMSTR2X_15A-XFORMSTR2X_B8	| 40820E2C
    .short  XFORMSTR2X_108-XFORMSTR2X_B8	| 40820E2E
    .short  XFORMSTR2X_13C-XFORMSTR2X_B8	| 40820E30
    .short  XFORMSTR2X_146-XFORMSTR2X_B8	| 40820E32
XFORMSTR2X_D4:          /* digit placeholder: a digit, else the placeholder character itself */
    jbsr XFORMSTR2X_176
    jbne XFORMSTR2X_E8
    movew %d4,%d0
    addw %d0,%d0
    movew %a4@(0x0,%d0:w),%d0
    jbsr XFORMSTR2X_15C
    jbeq XFORMSTR2X_1A0
XFORMSTR2X_E8:          /* next */
    jbra XFORMSTR2X_1C6
XFORMSTR2X_EC:          /* non-leader placeholder: remember where the optional digits start */
    tstw %d3
    jbne XFORMSTR2X_FE
    movew %d7,%d3
    movew %fp@(-16),%fp@(-280)
    movew %fp@(-18),%fp@(-278)
XFORMSTR2X_FE:          /* a digit */
    jbsr XFORMSTR2X_176
    jbeq XFORMSTR2X_1A0
    jbra XFORMSTR2X_1C6
XFORMSTR2X_108:         /* decimal point: '.' into the digit string */
    st %fp@(-283)
    clrw %d3
    movew %a4@(28),%d0
    jbsr XFORMSTR2X_15C
    jbeq XFORMSTR2X_1A0
    movew %fp@(-16),%d0
    lea %fp@(-276),%a0
    moveb #46,%a0@(0x0,%d0:w)
    addqw #1,%fp@(-16)
    jbra XFORMSTR2X_15A
XFORMSTR2X_12C:         /* other tokens: their parts table character */
    movew %d4,%d0
    addw %d0,%d0
    movew %a4@(0x0,%d0:w),%d0
    jbsr XFORMSTR2X_15C
    jbeq XFORMSTR2X_1A0
    jbra XFORMSTR2X_1C6
XFORMSTR2X_13C:         /* E+ */
    lea %a4@(64),%a0
    jbsr XFORMSTR2X_18C
    jbeq XFORMSTR2X_1A0
    jbra XFORMSTR2X_150
XFORMSTR2X_146:         /* E- */
    lea %a4@(108),%a0
    jsr %pc@(XFORMSTR2X_18C)
    jbeq XFORMSTR2X_1A0
XFORMSTR2X_150:         /* exponent: digits start again */
    moveq #0,%d3
    clrb %fp@(-283)
    st %fp@(-323)
XFORMSTR2X_15A:         /* next */
    jbra XFORMSTR2X_1C6

XFORMSTR2X_15C:         /* does the text match parts table character %d0? (through the script's routine) */
    clrw %sp@-
    movew %d0,%sp@-
    pea %fp@(-18)
    clrw %sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(468),%a0
    jsr %a0@
    moveb %sp@+,%d0
    rts

XFORMSTR2X_176:         /* a digit at the current position? */
    clrw %sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(464),%a0
    jsr %a0@
    moveb %sp@+,%d0
    andb %fp@(-323),%d0
    rts

XFORMSTR2X_18C:         /* does the text match the string at %a0? */
    clrw %sp@-
    movel %a0,%sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(460),%a0
    jsr %a0@
    moveb %sp@+,%d0
    rts
XFORMSTR2X_1A0:         /* mismatch: this part does not fit */
    moveb %a2@,%d0
    extw %d0
    clrb %fp@(0xfffffffffffffffc,%d0:w)
    jbra XFORMSTR2X_1C6
XFORMSTR2X_1AA:         /* literal: compare it with the text */
    clrw %sp@-
    movew %d4,%sp@-
    moveal %fp@(24),%a0
    addaw %fp@(-18),%a0
    moveb %a0@,%d0
    movew %d0,%sp@-
    jsr %pc@(CHARCOMP)
    tstb %sp@+
    jbeq XFORMSTR2X_1A0
    addqw #1,%fp@(-18)
XFORMSTR2X_1C6:         /* end of the part or the text? */
    moveb %a2@,%d0
    jsr %pc@(NEXTFORMATCLASS)
    addw %d0,%d0
    movew %a3@(0x8,%d0:w),%d6
    moveb %a2@,%d1
    extw %d1
    movew %fp@(-18),%d0
    cmpw %fp@(-14),%d0
    jble XFORMSTR2X_1EC
    movew %d6,%d0
    subqw #1,%d0
    cmpw %d7,%d0
    jble XFORMSTR2X_1EC
    sf %fp@(0xfffffffffffffffc,%d1:w)
XFORMSTR2X_1EC:         /* part still possible: keep going */
    tstb %fp@(0xfffffffffffffffc,%d1:w)
    jbne XFORMSTR2X_284
    tstb %fp@(-283)
    jbne XFORMSTR2X_202
    tstw %d3
    jbne XFORMSTR2X_246
    jbra XFORMSTR2X_284
XFORMSTR2X_202:         /* skip the rest of the integer placeholders */
    movew %d6,%d3
    clrb %fp@(-284)
XFORMSTR2X_208:         /* loop over the remaining tokens */
    cmpw %d6,%d7
    jbge XFORMSTR2X_260
    movew %d7,%d1
    addqw #1,%d1
    cmpib #5,%a3@(0x2c,%d7:w)
    jbne XFORMSTR2X_22A
    moveb %a2@,%d0
    extw %d0
    st %fp@(0xfffffffffffffffc,%d0:w)
    tstb %fp@(-284)
    jbne XFORMSTR2X_242
    movew %d1,%d3
    jbra XFORMSTR2X_242
XFORMSTR2X_22A:         /* an exponent token */
    cmpib #15,%a3@(0x2c,%d7:w)
    jbeq XFORMSTR2X_23A
    cmpib #16,%a3@(0x2c,%d7:w)
    jbne XFORMSTR2X_242
XFORMSTR2X_23A:         /* exponent seen */
    st %fp@(-284)
    st %fp@(-323)
XFORMSTR2X_242:         /* next */
    movew %d1,%d7
    jbra XFORMSTR2X_208
XFORMSTR2X_246:         /* find the next digit-type token */
    addqw #1,%d3
    cmpw %d6,%d3
    jbge XFORMSTR2X_260
    moveb %a3@(0x2c,%d3:w),%d0
    cmpib #31,%d0
    jbgt XFORMSTR2X_246
    movel #115568,%d1
    btst %d0,%d1
    jbeq XFORMSTR2X_246
XFORMSTR2X_260:         /* back-track to it */
    cmpw %d3,%d6
    jble XFORMSTR2X_286
    movew %d3,%d7
    moveb %a2@,%d0
    extw %d0
    st %fp@(0xfffffffffffffffc,%d0:w)
    tstb %fp@(-283)
    jbne XFORMSTR2X_286
    clrw %d3
    movew %fp@(-278),%fp@(-18)
    movew %fp@(-280),%fp@(-16)
    jbra XFORMSTR2X_286
XFORMSTR2X_284:         /* next token */
    addqw #1,%d7
XFORMSTR2X_286:         /* whole part and text used: the part matches */
    moveb %a2@,%d0
    extw %d0
    cmpw %d7,%d6
    jbgt XFORMSTR2X_29C
    movew %fp@(-18),%d1
    cmpw %fp@(-14),%d1
    jbgt XFORMSTR2X_29C
    sf %fp@(0xfffffffffffffffc,%d0:w)
XFORMSTR2X_29C:         /* this part failed: try the next one (negative, then zero) */
    moveb %fp@(0xfffffffffffffffc,%d0:w),%d1
    jbne XFORMSTR2X_2F8
    cmpib #2,%a2@
    jbne XFORMSTR2X_2AC
    sf %d5
    jbra XFORMSTR2X_2F8
XFORMSTR2X_2AC:         /* next part: restart at its first token */
    clrb %fp@(-5)
    moveb %a2@,%d0
    extw %d0
    addqw #1,%d0
    moveb %d0,%a2@
    movew %d0,%d1
    addw %d0,%d0
    btst #0,%a3@(0x1a,%d0:w)
    jbeq XFORMSTR2X_2F6
    moveq #1,%d2
    cmpiw #2,%d1
    jbne XFORMSTR2X_2D4
    moveb #0x80,%fp@(-323)
    jbra XFORMSTR2X_2D8
XFORMSTR2X_2D4:         /* exponent allowed */
    st %fp@(-323)
XFORMSTR2X_2D8:         /* restart the scan */
    moveb #49,%fp@(-275)
    sf %fp@(-283)
    clrw %d3
    moveb %d2,%fp@(0xfffffffffffffffc,%d1:w)
    movew %d2,%fp@(-18)
    movew %a3@(0x8,%d0:w),%d7
    movew %d2,%fp@(-16)
    jbra XFORMSTR2X_2F8
XFORMSTR2X_2F6:         /* no more parts */
    clrb %d5
XFORMSTR2X_2F8:         /* continue while tokens and text remain */
    cmpw %fp@(-10),%d7
    sle %d0
    movew %fp@(-18),%d1
    cmpw %fp@(-14),%d1
    sle %d1
    andb %d1,%d0
    andb %d0,%d5
    jbra XFORMSTR2X_8C
XFORMSTR2X_310:         /* a part matched: percent flag */
    moveb %a2@,%d0
    extw %d0
    moveb %fp@(0xfffffffffffffffc,%d0:w),%d1
    jbeq XFORMSTR2X_32C
    addw %d0,%d0
    btst #3,%a3@(0x1a,%d0:w)
    sne %d0
    moveb %d0,%fp@(-6)
    jbra XFORMSTR2X_45A
XFORMSTR2X_32C:         /* no part matched: best guess (fBestGuess), take the digits as they come */
    movew #1,%fp@(28)
    sf %fp@(-6)
    sf %fp@(-5)
    sf %fp@(-283)
    st %fp@(-323)
    clrw %a2@
    movew #1,%fp@(-18)
    movew #1,%fp@(-16)
XFORMSTR2X_350:         /* per character of the text */
    movew %fp@(-18),%d0
    cmpw %fp@(-14),%d0
    jbgt XFORMSTR2X_45A
    jbsr XFORMSTR2X_176
    jbne XFORMSTR2X_438
    clrw %d6
XFORMSTR2X_366:         /* which token is it? */
    addqw #1,%d6
    cmpiw #14,%d6
    jbgt XFORMSTR2X_37C
    movew %d6,%d1
    addw %d1,%d1
    movew %a4@(0x0,%d1:w),%d0
    jbsr XFORMSTR2X_15C
    jbeq XFORMSTR2X_366
XFORMSTR2X_37C:         /* percent, minus, decimal point, E */
    movew %d6,%d0
    subqw #7,%d0
    jbeq XFORMSTR2X_3C2
    subqw #2,%d0
    jbeq XFORMSTR2X_3B4
    subqw #5,%d0
    jbeq XFORMSTR2X_392
    subqw #1,%d0
    jbeq XFORMSTR2X_3CE
    jbra XFORMSTR2X_438
XFORMSTR2X_392:         /* decimal point: only one */
    tstb %fp@(-283)
    jbne XFORMSTR2X_44C
    st %fp@(-283)
    movew %fp@(-16),%d0
    lea %fp@(-276),%a0
    moveb #46,%a0@(0x0,%d0:w)
    addqw #1,%fp@(-16)
    jbra XFORMSTR2X_438
XFORMSTR2X_3B4:         /* minus: only one */
    tstb %fp@(-5)
    jbne XFORMSTR2X_454
    st %fp@(-5)
    jbra XFORMSTR2X_438
XFORMSTR2X_3C2:         /* percent: only one */
    tstb %fp@(-6)
    jbne XFORMSTR2X_444
    st %fp@(-6)
    jbra XFORMSTR2X_438
XFORMSTR2X_3CE:         /* exponent strings, or other allowed characters */
    lea %a4@(64),%a0
    jbsr XFORMSTR2X_18C
    jbne XFORMSTR2X_438
    lea %a4@(108),%a0
    jsr %pc@(XFORMSTR2X_18C)
    jbne XFORMSTR2X_438
    clrw %sp@-
    movel %fp@(24),%sp@-
    movew %fp@(-18),%sp@-
    movel #-2113535984,%sp@-
    _ScriptUtil
    moveal %fp@(24),%a0
    movew %fp@(-18),%d0
    addaw %d0,%a0
    moveb %a0@+,%d0
    tstw %sp@+
    jbeq XFORMSTR2X_408
    lslw #8,%d0
    moveb %a0@+,%d0
XFORMSTR2X_408:         /* search the literal list */
    lea %a4@(60),%a0
    moveq #15,%d1
XFORMSTR2X_40E:         /* loop; not found: fSpuriousChars */
    cmpw %a0@-,%d0
    dbeq %d1,XFORMSTR2X_40E
    jbne XFORMSTR2X_454
XFORMSTR2X_416:         /* skip it (two bytes for a double-byte character) */
    addqw #1,%fp@(-18)
    clrw %sp@-
    movel %fp@(24),%d0
    addqw #1,%d0
    movel %d0,%sp@-
    movew %fp@(-18),%d0
    subqw #1,%d0
    movew %d0,%sp@-
    movel #-2113535984,%sp@-
    _ScriptUtil
    tstw %sp@+
    jbgt XFORMSTR2X_416
XFORMSTR2X_438:         /* next character */
    jbra XFORMSTR2X_350
XFORMSTR2X_43C:         /* fEmptyFormatString */
    movew #13,%fp@(28)
    jbra XFORMSTR2X_45A
XFORMSTR2X_444:         /* fExtraPercent */
    movew #11,%fp@(28)
    jbra XFORMSTR2X_45A
XFORMSTR2X_44C:         /* fExtraDecimal */
    movew #5,%fp@(28)
    jbra XFORMSTR2X_45A
XFORMSTR2X_454:         /* fSpuriousChars */
    movew #3,%fp@(28)
XFORMSTR2X_45A:         /* no digits: NaN */
    movew %fp@(-16),%d0
    subqw #1,%d0
    jbne XFORMSTR2X_474
    moveq #1,%d0
    tstw %fp@(-14)
    jbeq XFORMSTR2X_48C
    moveb %a2@,%d1
    extw %d1
    tstb %fp@(0xfffffffffffffffc,%d1:w)
    jbeq XFORMSTR2X_48C
XFORMSTR2X_474:         /* zero part: result 0 */
    moveb %d0,%fp@(-276)
    cmpib #2,%a2@
    jbne XFORMSTR2X_492
    moveal %fp@(12),%a0
    clrl %a0@+
    clrl %a0@+
    clrw %a0@
    jbra XFORMSTR2X_524
XFORMSTR2X_48C:         /* NaN(17) */
    pea %pc@(XFORMSTR2X_53A)
    jbra XFORMSTR2X_496
XFORMSTR2X_492:         /* the digit string */
    pea %fp@(-276)
XFORMSTR2X_496:         /* decimal string to extended (_DECSTR68K, _FP68K); percent: divide by 100 */
    movew #1,%fp@(-288)
    pea %fp@(-288)
    pea %fp@(-316)
    pea %fp@(-290)
    movew #2,%sp@-
    _DECSTR68K
    pea %fp@(-316)
    movel %fp@(12),%sp@-
    movew #9,%sp@-
    _FP68K
    moveal %fp@(12),%a1
    jbsr GETSANECLASS
    cmpiw #2,%d0
    jbeq XFORMSTR2X_516
    cmpiw #-2,%d0
    jbeq XFORMSTR2X_516
    cmpiw #1,%d0
    jbeq XFORMSTR2X_516
    cmpiw #-1,%d0
    jbeq XFORMSTR2X_516
    cmpiw #3,%d0
    jbeq XFORMSTR2X_51E
    cmpiw #-3,%d0
    jbeq XFORMSTR2X_51E
    moveb %fp@(-6),%d0
    jbeq XFORMSTR2X_4FC
    pea %pc@(XFORMSTR2X_530)
    movel %fp@(12),%sp@-
    movew #6,%sp@-
    _FP68K
XFORMSTR2X_4FC:         /* negative part or minus seen: negate */
    cmpib #1,%a2@
    jbeq XFORMSTR2X_508
    tstb %fp@(-5)
    jbeq XFORMSTR2X_524
XFORMSTR2X_508:         /* flip the sign bit */
    moveal %fp@(12),%a0
    tstl %a0@
    jbeq XFORMSTR2X_524
    eorib #0x80,%a0@
    jbra XFORMSTR2X_524
XFORMSTR2X_516:         /* fFormStrIsNAN */
    movew #9,%fp@(28)
    jbra XFORMSTR2X_524
XFORMSTR2X_51E:         /* fFormatOverflow */
    movew #8,%fp@(28)
XFORMSTR2X_524:         /* restore registers */
    moveml %sp@+,%d3-%d7/%a2-%a5
    movew #20,%d0
    jbra STDUNLINK
XFORMSTR2X_530:         /* extended 100.0 (percent) */
    .short  0x4005, 0xC800, 0x0000, 0x0000, 0x0000	| 40821290
XFORMSTR2X_53A:         /* string "nan(17)\000" */
    .ascii  "nan(17)\000"
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408212A2

/* NUM2DEC: number to decimal record. */
NUM2DEC:
    pea %fp@(-4)	| 408212B0
    movel %fp@(18),%sp@-	| 408212B4
    pea %fp@(-30)	| 408212B8
    movew #11,%sp@-	| 408212BC
    _FP68K	| 408212C0
    rts
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 408212C4

/* INT2STRING: integer to string. */
INT2STRING:
    extl %d0
    moveal %a0,%a1
    moveb #1,%a0@+
    movel %a0,%d1
INT2STRING_A:           /* loop: divide by 10, store the digits (reversed) */
    divuw #10,%d0
    swap %d0
    addib #48,%d0
    moveb %d0,%a0@+
    swap %d0
    extl %d0
    bnes INT2STRING_A
    subl %a0,%d1
    negw %d1
    moveb %d1,%a1@
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 408212F4

/* CONVERTTOSTRING: an extended to integer and fraction digit strings, for FormatX2Str. */
CONVERTTOSTRING:
    linkw %fp,#-34	| 40821300
    moveml %d4-%d7/%a2-%a4,%sp@-	| 40821304
    movew %fp@(12),%d6	| 40821308
    movew %fp@(14),%d4	| 4082130C
    moveal %fp@(8),%a4	| 40821310
    moveb %d6,%a4@(-114)	| 40821314
    moveb %d4,%a4@(-164)	| 40821318
    movew %d6,%a4@(-340)	| 4082131C
    moveb %fp@(16),%d0	| 40821320
    jbeq CONVERTTOSTRING_B4	| 40821324
    lea %fp@(-28),%a2	| 40821328
    clrb %fp@(-4)	| 4082132C
    movew %d4,%d0	| 40821330
    addw %d6,%d0	| 40821332
    .byte   0x3D, 0x40	| 40821334
    .long   0xFFFE4EBA /* number, not a label difference (was INITPRIMARY-.) */	| 40821336
    .byte   0xFF, 0x76, 0x0C, 0x2E, 0x00, 0x30, 0xFF, 0xE7, 0x66, 0x2C, 0x10, 0x3C, 0x00, 0x30, 0x41, 0xEC	| 4082133A
    .byte   0xFF, 0x5D, 0x3E, 0x04, 0x53, 0x47, 0x6D, 0x06, 0x10, 0xC0, 0x51, 0xCF, 0xFF, 0xFC, 0x41, 0xEC	| 4082134A
    .byte   0xFF, 0x8F, 0x3E, 0x06, 0x53, 0x47, 0x6D, 0x06, 0x10, 0xC0, 0x51, 0xCF, 0xFF, 0xFC, 0x42, 0x52	| 4082135A
    .byte   0x42, 0x2C, 0xFF, 0xF4, 0x60, 0x38, 0x72, 0x00, 0x30, 0x12, 0xD0, 0x46, 0x6A, 0x04, 0x44, 0x40	| 4082136A
    .byte   0x50, 0xC1, 0x19, 0x41, 0xFF, 0xF4, 0x34, 0x80, 0x41, 0xEC, 0xFF, 0x5D, 0x43, 0xF6, 0x40, 0xE7	| 4082137A
    .byte   0x26, 0x49, 0x3E, 0x04, 0x53, 0x47, 0x6D, 0x06, 0x10, 0xE3, 0x51, 0xCF, 0xFF, 0xFC, 0x41, 0xEC	| 4082138A
    .byte   0xFF, 0x8F, 0x3E, 0x06, 0x53, 0x47, 0x6D, 0x06, 0x10, 0xD9, 0x51, 0xCF, 0xFF, 0xFC, 0x30, 0x12	| 4082139A
    .byte   0x41, 0xEC, 0xFF, 0xC0, 0x4E, 0xBA, 0xFF, 0x20, 0x60, 0x5E	| 408213AA
CONVERTTOSTRING_B4:     /* extended to decimal digits (NUM2DEC) */
    sf %a4@(-12)	| 408213B4
    clrb %a4@(-64)	| 408213B8
    moveb #1,%fp@(-4)	| 408213BC
    movew %d6,%fp@(-2)	| 408213C2
    jsr %pc@(NUM2DEC)	| 408213C6
    lea %a4@(-113),%a0	| 408213CA
    clrw %d0	| 408213CE
    lea %fp@(-26),%a3	| 408213D0
    moveb %a3@+,%d0	| 408213D4
    movew %d6,%d7	| 408213D6
    subqw #1,%d7	| 408213D8
    jblt CONVERTTOSTRING_F6	| 408213DA
    subw %d6,%d0	| 408213DC
    jbge CONVERTTOSTRING_EE	| 408213DE
CONVERTTOSTRING_E0:     /* leading zeros */
    moveb #48,%a0@+	| 408213E0
    subqw #1,%d6	| 408213E4
    addqw #1,%d0	| 408213E6
    dbge %d7,CONVERTTOSTRING_E0	| 408213E8
    subqw #1,%d7	| 408213EC
CONVERTTOSTRING_EE:     /* skip */
    addaw %d0,%a3	| 408213EE
CONVERTTOSTRING_F0:     /* copy the digits */
    moveb %a3@+,%a0@+	| 408213F0
    dbf %d7,CONVERTTOSTRING_F0	| 408213F2
CONVERTTOSTRING_F6:     /* the integer digits, reversed */
    lea %fp@(-26),%a3
    moveq #0,%d5
    moveb %a3@+,%d5
    subw %d6,%d5
    addaw %d5,%a3
    lea %a4@(-164),%a0
    moveb %d5,%a0@+
    subqw #1,%d5
    jblt CONVERTTOSTRING_112
CONVERTTOSTRING_10C:    /* loop */
    moveb %a3@-,%a0@+
    dbf %d5,CONVERTTOSTRING_10C
CONVERTTOSTRING_112:    /* drop trailing zeros of the fraction */
    movew %a4@(-340),%d0
    subiw #113,%d0
    lea %a4@(0x0,%d0:w),%a0
CONVERTTOSTRING_11E:    /* loop */
    cmpib #48,%a0@-
    jbne CONVERTTOSTRING_132
    cmpiw #1,%a4@(-340)
    jbeq CONVERTTOSTRING_132
    subqw #1,%a4@(-340)
    jbra CONVERTTOSTRING_11E
CONVERTTOSTRING_132:    /* restore registers */
    moveml %sp@+,%d4-%d7/%a2-%a4
    movew #14,%d0
    jbra STDUNLINK
    .short  0x0000	| 4082143E

/* EXPHANDLING: exponent output. */
EXPHANDLING:
    linkw %fp,#-8	| 40821440
    moveml %d5-%d7/%a2-%a4,%sp@-	| 40821444
    moveal %fp@(8),%a2
    moveal %a2@(8),%a4
    moveal %a2@(20),%a2
    moveal %a4@(16),%a0
    sf %a4@(-325)
    moveb %a4@(-12),%d0
    jbeq EXPHANDLING_28
    lea %a0@(86),%a3
    jbra EXPHANDLING_2C
EXPHANDLING_28:         /* E+ string */
    moveal %fp@(12),%a3
EXPHANDLING_2C:         /* append the exponent string */
    movew %a3@,%d5
    clrw %d7
    jbra EXPHANDLING_4A
EXPHANDLING_32:         /* one character */
    clrw %sp@-
    movew %d7,%d0
    addw %d0,%d0
    movew %a3@(0x2,%d0:w),%sp@-
    movel %a2,%sp@-
    pea %a4@(-318)
    jsr %pc@(SENDCHAR)
    movew %sp@+,%d6
    addqw #1,%d7
EXPHANDLING_4A:         /* loop */
    cmpw %d5,%d7
    jble EXPHANDLING_32
    moveml %sp@+,%d5-%d7/%a2-%a4
    movew #8,%d0
    jbra STDUNLINK
    .short  0x0000, 0x0000, 0x0000	| 4082149A

/* APPENDSYMBOL: append a format symbol. */
APPENDSYMBOL:
    linkw %fp,#-6
    moveml %d5-%d7/%a2-%a4,%sp@-
    movew %fp@(28),%d6
    movel %fp@(24),%d5
    moveal %fp@(8),%a4
    moveq #0,%d7
    movel %a4@(20),%fp@(-6)
    moveal %a4@(16),%a3
    cmpiw #32,%d6
    jblt APPENDSYMBOL_3E
    moveal %fp@(20),%a0
    movew %a4@(-318),%d0
    moveb %d6,%a0@(0x0,%d0:w)
    addqw #1,%a4@(-318)
    addqw #1,%a4@(-324)
    jbra APPENDSYMBOL_14E
APPENDSYMBOL_3E:        /* by token class 4..16 */
    movew %d6,%d0
    subqw #4,%d0
    jbmi APPENDSYMBOL_14E
    cmpiw #12,%d0
    jbgt APPENDSYMBOL_14E
    addw %d0,%d0
    movew %pc@(APPENDSYMBOL_58,%d0:w),%d0
APPENDSYMBOL_54:        /* jump through the table */
    jmp %pc@(0,%d0:w)
APPENDSYMBOL_58:        /* per token class */
    .short  APPENDSYMBOL_9A-APPENDSYMBOL_56	| 408214F8
    .short  APPENDSYMBOL_9A-APPENDSYMBOL_56	| 408214FA
    .short  APPENDSYMBOL_9A-APPENDSYMBOL_56	| 408214FC
    .short  APPENDSYMBOL_14E-APPENDSYMBOL_56	| 408214FE
    .short  APPENDSYMBOL_14A-APPENDSYMBOL_56	| 40821500
    .short  APPENDSYMBOL_14A-APPENDSYMBOL_56	| 40821502
    .short  APPENDSYMBOL_14A-APPENDSYMBOL_56	| 40821504
    .short  APPENDSYMBOL_14E-APPENDSYMBOL_56	| 40821506
    .short  APPENDSYMBOL_14E-APPENDSYMBOL_56	| 40821508
    .short  APPENDSYMBOL_14E-APPENDSYMBOL_56	| 4082150A
    .short  APPENDSYMBOL_14E-APPENDSYMBOL_56	| 4082150C
    .short  APPENDSYMBOL_72-APPENDSYMBOL_56	| 4082150E
    .short  APPENDSYMBOL_86-APPENDSYMBOL_56	| 40821510
APPENDSYMBOL_72:        /* E+ */
    pea %a3@(64)
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(456),%a0
    jsr %a0@
    jbra APPENDSYMBOL_14E
APPENDSYMBOL_86:        /* E- */
    pea %a3@(108)
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(456),%a0
    jsr %a0@
    jbra APPENDSYMBOL_14E
APPENDSYMBOL_9A:        /* digit placeholder: the next digit, or the placeholder's fill */
    moveal %d5,%a0
    clrw %d0
    moveb %a0@,%d0
    cmpw %a4@(-322),%d0
    jblt APPENDSYMBOL_108
    lea %a4@(-332),%a1
    btst #5,%a1@
    jbeq APPENDSYMBOL_E4
    clrw %sp@-
    movew %a4@(-322),%d0
    clrw %d1
    moveb %a0@(0x0,%d0:w),%d1
    subiw #48,%d1
    addw %d1,%d1
    lea %a3@(132),%a0
    movew %a0@(0x0,%d1:w),%sp@-
    movel %fp@(20),%sp@-
    pea %a4@(-318)
    lea %fp@(12),%a0
    movel %a0@+,%d0
    jbeq APPENDSYMBOL_DC
    movel %d0,%sp@-
APPENDSYMBOL_DC:        /* call the append routine */
    moveal %a0@,%a0
    jsr %a0@
    movew %sp@+,%d7
    jbra APPENDSYMBOL_FC
APPENDSYMBOL_E4:        /* store the digit */
    moveal %fp@(20),%a0
    movew %a4@(-318),%d0
    moveal %d5,%a1
    movew %a4@(-322),%d1
    moveb %a1@(0x0,%d1:w),%a0@(0x0,%d0:w)
    addqw #1,%a4@(-318)
APPENDSYMBOL_FC:        /* next digit */
    addqw #1,%a4@(-322)
    movew %a4@(-318),%a4@(-336)
    jbra APPENDSYMBOL_14E
APPENDSYMBOL_108:       /* no more digits: a non-leader placeholder only marks the position */
    cmpiw #5,%d6
    jbne APPENDSYMBOL_13A
    movew %a4@(-318),%a4@(-334)
    jbra APPENDSYMBOL_14E

APPENDSYMBOL_116:       /* append the parts table character for the token */
    movew %d6,%d0
    addw %d0,%d0
    clrw %sp@-
    movew %a3@(0x0,%d0:w),%sp@-
    movel %fp@(20),%sp@-
    pea %a4@(-318)
    lea %fp@(12),%a0
    movel %a0@+,%d0
    jbeq APPENDSYMBOL_132
    movel %d0,%sp@-
APPENDSYMBOL_132:       /* call the append routine */
    moveal %a0@,%a0
    jsr %a0@
    movew %sp@+,%d7
    rts
APPENDSYMBOL_13A:       /* other placeholders: their fill character */
    jsr %pc@(APPENDSYMBOL_116)
    movew %a4@(-318),%a4@(-336)
    clrw %a4@(-334)
    jbra APPENDSYMBOL_14E
APPENDSYMBOL_14A:       /* other tokens */
    jsr %pc@(APPENDSYMBOL_116)
APPENDSYMBOL_14E:       /* error: store it */
    tstw %d7
    jbeq APPENDSYMBOL_15A
    moveal %fp@(8),%a0
    movew %d7,%a0@(28)
APPENDSYMBOL_15A:       /* restore registers */
    moveml %sp@+,%d5-%d7/%a2-%a4
    movew #22,%d0
    jbra STDUNLINK
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 40821606
APPENDSYMBOL_16E:       /* (padding) */
    .byte   0x00, 0x00	| 4082160E
/* FORMATX2STR (APPENDSYMBOL_170): _FormatX2Str: an extended to a string through a compiled
 format: picks the part by sign, converts the digits, then fills the tokens right to left
 (integer part) and left to right (fraction). */
APPENDSYMBOL_170:       /* FormatX2Str */
    linkw %fp,#-348	| 40821610
    moveml %d4-%d7/%a2-%a5,%sp@-	| 40821614
    moveal %fp@(24),%a0	| 40821618
    lea %fp@(-318),%a5	| 4082161C
    lea %fp@(-10),%a1	| 40821620
    moveal %a1,%a2	| 40821624
    movel %a0@+,%a2@+	| 40821626
    movel %a0@+,%a2@+	| 40821628
    movew %a0@,%a2@	| 4082162A
    moveq #0,%d5	| 4082162C
    clrw %fp@(28)	| 4082162E
    moveal %fp@(20),%a4	| 40821632
    tstb %a4@(44)	| 40821636
    jbeq XFORMX2STR_3B4_18	| 4082163A
    moveal %fp@(16),%a3	| 4082163E
    sf %d4	| 40821642
    st %fp@(-325)	| 40821644
    sf %fp@(-13)	| 40821648
    movew #49,%d0	| 4082164C
    moveb %d0,%fp@(-314)	| 40821650
    moveb %d0,%fp@(-264)	| 40821654
    moveb %d0,%fp@(-214)	| 40821658
    jbsr GETSANECLASS	| 4082165C
    cmpiw #-4,%d0	| 40821660
    jbeq APPENDSYMBOL_20E	| 40821664
    cmpiw #2,%d0	| 40821666
    jbeq XFORMX2STR_3B4_C	| 4082166A
    cmpiw #-2,%d0	| 4082166E
    jbeq XFORMX2STR_3B4_C	| 40821672
    cmpiw #1,%d0	| 40821676
    jbeq XFORMX2STR_3B4_C	| 4082167A
    cmpiw #-1,%d0	| 4082167E
    jbeq XFORMX2STR_3B4_C	| 40821682
    cmpiw #3,%d0	| 40821686
    jbeq XFORMX2STR_3B4_12	| 4082168A
    cmpiw #-3,%d0	| 4082168E
    jbeq XFORMX2STR_3B4_12	| 40821692
    btst #0,%a4@(26)	| 40821696
    jbeq XFORMX2STR_3B4_18	| 4082169C
    tstb %a1@	| 408216A0
    jbpl APPENDSYMBOL_20C	| 408216A2
    moveq #1,%d6	| 408216A4
    eorib #0x80,%a1@	| 408216A6
    jbra APPENDSYMBOL_214	| 408216AA
APPENDSYMBOL_20C:       /* negative */
    jbne APPENDSYMBOL_212	| 408216AC
APPENDSYMBOL_20E:       /* zero part */
    moveq #2,%d6	| 408216AE
    jbra APPENDSYMBOL_214	| 408216B0
APPENDSYMBOL_212:       /* positive part */
    moveq #0,%d6	| 408216B2
APPENDSYMBOL_214:       /* empty part: use the positive one, with a minus sign */
    movew %d6,%d0	| 408216B4
    addw %d0,%d0	| 408216B6
    btst #0,%a4@(0x1a,%d0:w)	| 408216B8
    jbne APPENDSYMBOL_22A	| 408216BE
    cmpib #1,%d6	| 408216C0
    seq %fp@(-13)	| 408216C4
    moveq #0,%d6	| 408216C8
APPENDSYMBOL_22A:       /* the part's flags; percent: multiply by 100 */
    movew %d6,%d0	| 408216CA
    addw %d0,%d0	| 408216CC
    lea %fp@(-332),%a2	| 408216CE
    lea %a4@(0x1a,%d0:w),%a0	| 408216D2
    movew %a0@,%a2@	| 408216D6
    btst #3,%a2@	| 408216D8
    jbeq APPENDSYMBOL_24A	| 408216DC
    pea %pc@(XFORMX2STR_3D8_C)	| 408216DE
    movel %a1,%sp@-	| 408216E2
    movew #4,%sp@-	| 408216E4
    _FP68K	| 408216E8
APPENDSYMBOL_24A:       /* convert the number to digit strings */
    pea %fp@(-10)	| 408216EA
    moveq #0,%d0	| 408216EE
    movew %a2@,%d0	| 408216F0
    andil #1536,%d0	| 408216F2
    sne %d0	| 408216F8
    moveb %d0,%sp@-	| 408216FA
    movew %d6,%d0	| 408216FC
    addw %d0,%d0	| 408216FE
    movew %a4@(0xe,%d0:w),%sp@-	| 40821700
    movew %a4@(0x14,%d0:w),%sp@-
    movel %fp,%sp@-
    moveal IntlSpec,%a0
    moveal %a0@(452),%a0
    jsr %a0@
    movew #1,%a5@
    movew #1,%fp@(-322)
    movew #1,%fp@(-324)
    movew %d6,%d0
    addw %d0,%d0
    movew %a4@(0x2,%d0:w),%d7
    subqw #1,%d7
    cmpib #0,%d6
    jbne XFORMX2STR_12C
    movew #1,%fp@(-316)
    jbra XFORMX2STR_132
XFORMX2STR_12C:         /* the part's end */
    movew %a4@(0x8,%d0:w),%fp@(-316)
XFORMX2STR_132:         /* a decimal point */
    btst #4,%a2@
    jbeq XFORMX2STR_14A
    clrw %sp@-
    movew %a3@(28),%sp@-
    pea %fp@(-314)
    movel %a5,%sp@-
    jsr %pc@(SENDCHARREV)
    movew %sp@+,%d5
XFORMX2STR_14A:         /* integer part, from the last token backwards */
    clrw %fp@(-334)
    movew %a5@,%fp@(-336)
    movel %a2,%sp@-
    moveal IntlSpec,%a2
    moveal %a2@(448),%a2
XFORMX2STR_15C:         /* per token: append its symbol (reversed) */
    cmpw %fp@(-316),%d7
    jblt XFORMX2STR_18E
    clrw %d1
    moveb %a4@(0x2c,%d7:w),%d1
    movew %d1,%sp@-
    pea %fp@(-164)
    pea %fp@(-314)
    pea %pc@(SENDCHARREV)
    clrl %sp@-
    movel %fp,%sp@-
    jsr %a2@
    tstw %fp@(-334)
    jbeq XFORMX2STR_18A
    movew %fp@(-336),%a5@
    clrw %fp@(-334)
XFORMX2STR_18A:         /* previous token */
    subqw #1,%d7
    jbra XFORMX2STR_15C
XFORMX2STR_18E:         /* digits left over: fFormatOverflow */
    moveal %sp@+,%a2
    clrw %d0
    moveb %fp@(-164),%d0
    cmpw %fp@(-322),%d0
    jblt XFORMX2STR_1AE
    movew %fp@(-318),%d0
    cmpw %fp@(-324),%d0
    jbeq XFORMX2STR_1AE
    st %d4
    movew #8,%fp@(28)
XFORMX2STR_1AE:         /* the integer text; fraction tokens next */
    movew %a5@,%d0
    subqw #1,%d0
    moveb %d0,%fp@(-314)
    moveb %d4,%d0
    jbne XFORMX2STR_2FC
    moveb %d6,%d0
    extw %d0
    addw %d0,%d0
    movew %a4@(0x2,%d0:w),%d7
    btst #4,%a2@
    jbeq XFORMX2STR_1CE
    addqw #1,%d7
XFORMX2STR_1CE:         /* fraction part */
    movew #1,%a5@
    movew #1,%fp@(-322)
    clrw %fp@(-338)
    movel %a2,%sp@-
    moveal IntlSpec,%a2
    moveal %a2@(448),%a2
XFORMX2STR_1E6:         /* per fraction token: append its symbol */
    moveb %d6,%d0
    jsr %pc@(NEXTFORMATCLASS)
    addw %d0,%d0
    cmpw %a4@(0x8,%d0:w),%d7
    slt %d0
    andb %fp@(-325),%d0
    jbeq XFORMX2STR_26E
    movew %a5@,%fp@(-342)
    clrw %d1
    moveb %a4@(0x2c,%d7:w),%d1
    movew %d1,%fp@(-344)
    movew %d1,%sp@-
    pea %fp@(-114)
    pea %fp@(-264)
    pea %pc@(SENDCHAR)
    clrl %sp@-
    movel %fp,%sp@-
    jsr %a2@
    movew %fp@(-340),%d0
    cmpw %fp@(-322),%d0
    jbge XFORMX2STR_268
    movew %fp@(-344),%d1
    cmpib #4,%d1
    jbeq XFORMX2STR_236
    cmpib #6,%d1
    jbne XFORMX2STR_23C
XFORMX2STR_236:         /* a digit */
    clrw %fp@(-338)
    jbra XFORMX2STR_268
XFORMX2STR_23C:         /* non-leader placeholder: trailing position */
    cmpib #5,%d1
    jbne XFORMX2STR_25C
    addqw #1,%d0
    cmpw %fp@(-322),%d0
    jbge XFORMX2STR_268
    movew %fp@(-338),%d1
    jbne XFORMX2STR_258
    movew %fp@(-342),%d1
    movew %d1,%fp@(-338)
XFORMX2STR_258:         /* cut there */
    movew %d1,%a5@
    jbra XFORMX2STR_268
XFORMX2STR_25C:         /* first non-digit position */
    tstw %fp@(-338)
    jbne XFORMX2STR_268
    movew %fp@(-342),%fp@(-338)
XFORMX2STR_268:         /* next token */
    addqw #1,%d7
    jbra XFORMX2STR_1E6
XFORMX2STR_26E:         /* the fraction text; then the literals after the number */
    moveal %sp@+,%a2
    movew %a5@,%d0
    subqw #1,%d0
    moveb %d0,%fp@(-264)
    movew %d7,%fp@(-330)
    moveb %d6,%d0
    jsr %pc@(NEXTFORMATCLASS)
    addw %d0,%d0
    movew %a4@(0x8,%d0:w),%d7
    subqw #1,%d7
    movew #1,%a5@
    movew #1,%fp@(-322)
    clrw %fp@(-334)
    clrw %fp@(-336)
    moveb %fp@(-325),%d0
    jbeq XFORMX2STR_2A8
    clrb %fp@(-214)
    jbra XFORMX2STR_2FC
XFORMX2STR_2A8:         /* suffix tokens */
    movel %a2,%sp@-
    moveal IntlSpec,%a2
    moveal %a2@(448),%a2
XFORMX2STR_2B2:         /* per token: append its symbol (reversed) */
    cmpw %fp@(-330),%d7
    jblt XFORMX2STR_2E4
    clrw %d1
    moveb %a4@(0x2c,%d7:w),%d1
    movew %d1,%sp@-
    pea %fp@(-64)
    pea %fp@(-214)
    pea %pc@(SENDCHARREV)
    clrl %sp@-
    movel %fp,%sp@-
    jsr %a2@
    tstw %fp@(-334)
    jbeq XFORMX2STR_2E0
    movew %fp@(-336),%a5@
    clrw %fp@(-334)
XFORMX2STR_2E0:         /* previous token */
    subqw #1,%d7
    jbra XFORMX2STR_2B2
XFORMX2STR_2E4:         /* overflow? */
    moveal %sp@+,%a2
    movew %a5@,%d0
    subqw #1,%d0
    moveb %d0,%fp@(-214)
    clrw %d0
    moveb %fp@(-64),%d0
    cmpw %fp@(-322),%d0
    jblt XFORMX2STR_2FC
    st %d4
XFORMX2STR_2FC:         /* overflow: fFormatOverflow */
    moveb %d4,%d0
    jbeq XFORMX2STR_30A
    movew #8,%fp@(28)
    jbra XFORMX2STR_3D0
XFORMX2STR_30A:         /* assemble the string: minus sign if needed */
    moveal %fp@(12),%a0
    moveb #0xff,%a0@
    movew #1,%a5@
    moveb %fp@(-13),%d0
    jbeq XFORMX2STR_32E
    clrw %sp@-
    movew %a3@(18),%sp@-
    movel %fp@(12),%sp@-
    movel %a5,%sp@-
    jsr %pc@(SENDCHAR)
    movew %sp@+,%d5
XFORMX2STR_32E:         /* the integer text (stored reversed) */
    clrw %d0
    moveb %fp@(-314),%d0
    movew %d0,%d7
    jbra XFORMX2STR_34C
XFORMX2STR_338:         /* copy one character */
    moveal %fp@(12),%a0
    movew %a5@,%d0
    lea %fp@(-314),%a1
    moveb %a1@(0x0,%d7:w),%a0@(0x0,%d0:w)
    addqw #1,%a5@
    subqw #1,%d7
XFORMX2STR_34C:         /* loop */
    cmpiw #1,%d7
    jbge XFORMX2STR_338
    clrw %d0
XFORMX2STR_354:         /* the fraction text */
    moveb %fp@(-264),%d0
    movew %d0,%fp@(-346)
    moveq #1,%d7
    jbra XFORMX2STR_374
XFORMX2STR_360:         /* copy one character */
    moveal %fp@(12),%a0
    movew %a5@,%d0
    lea %fp@(-264),%a1
    moveb %a1@(0x0,%d7:w),%a0@(0x0,%d0:w)
    addqw #1,%a5@
    addqw #1,%d7
XFORMX2STR_374:         /* loop; then the suffix (reversed) */
    cmpw %fp@(-346),%d7
    jble XFORMX2STR_360
    clrw %d0
    moveb %fp@(-214),%d0
    movew %d0,%d7
    jbra XFORMX2STR_398
XFORMX2STR_384:         /* copy one character */
    moveal %fp@(12),%a0
    movew %a5@,%d0
    lea %fp@(-214),%a1
    moveb %a1@(0x0,%d7:w),%a0@(0x0,%d0:w)
    addqw #1,%a5@
    subqw #1,%d7
XFORMX2STR_398:         /* loop; percent sign */
    tstw %d7
    jbgt XFORMX2STR_384
    btst #3,%a2@
    jbeq XFORMX2STR_3B4
    clrw %sp@-
    movew %a3@(14),%sp@-
    movel %fp@(12),%sp@-
    movel %a5,%sp@-
    jsr %pc@(SENDCHAR)
    movew %sp@+,%d5
XFORMX2STR_3B4:         /* the length */
    moveal %fp@(12),%a0
    movew %a5@,%d0
    subqw #1,%d0
    moveb %d0,%a0@
    jbra XFORMX2STR_3D0
XFORMX2STR_3B4_C:       /* fFormStrIsNAN */
    movew #9,%d5	| 408219D0
    jbra XFORMX2STR_3D0	| 408219D4
XFORMX2STR_3B4_12:      /* fFormatOverflow */
    movew #8,%d5	| 408219D6
    jbra XFORMX2STR_3D0	| 408219DA
XFORMX2STR_3B4_18:      /* fEmptyFormatString */
    movew #13,%d5	| 408219DC
XFORMX2STR_3D0:         /* error: store it */
    tstw %d5
    jbeq XFORMX2STR_3D8
    movew %d5,%fp@(28)
XFORMX2STR_3D8:         /* restore registers */
    moveml %sp@+,%d4-%d7/%a2-%a5
    movew #20,%d0
    jbra STDUNLINK
XFORMX2STR_3D8_C:       /* extended 100.0 (percent) */
    .short  0x4005	| 408219F4
    .short  0xC800, 0x0000, 0x0000, 0x0000, 0x0000	| 408219F6 andb %d0,%d4

/* SMGRINITIALIZE: Script Manager start-up. */
SMGRINITIALIZE:
    linkw %fp,#0
    moveml %d0-%a4,%sp@-
    moveal ExpandMem,%a4
    tstw ROM85
    jblt SMGRINITIALIZE_196
    movel #544,%d0
    jbsr SMGRINITIALIZE_19E
    lea %pc@(CODEENTRY),%a1
    movew %a1@,%a0@
    movel %a0,%a4@(6)
    movel %a0,IntlSpec
    moveal %a0,%a4
    moveq #88,%d0
    jbsr SMGRINITIALIZE_19E
    lea %a0@(56),%a1
    movel %a1,%a4@(82)
    movew #-28,%a4@(86)
    movew #14,%a4@(88)
    lea %pc@(UTILTABLEBASE),%a1
    lea %pc@(UTILTABLE),%a3
    movew #21,%d0
SMGRINITIALIZE_54:      /* the generic ScriptUtil routine addresses, from offsets relative to UTILTABLE */
    movew %a1@+,%d1
    lea %a3@(0x0,%d1:w),%a2
    movel %a2,%a0@+
    dbf %d0,SMGRINITIALIZE_54
    lea %pc@(PATCHSTART),%a3
    lea %pc@(SMGRTABLE),%a2
SMGRINITIALIZE_68:      /* patch table: (offset in the Script Manager globals, routine offset from PATCHSTART); 0 ends */
    movel %a2@+,%d0
    jbeq SMGRINITIALIZE_78
    lea %a3@(0x0,%d0:w),%a0
    swap %d0
    movel %a0,%a4@(0x0,%d0:w)
    jbra SMGRINITIALIZE_68
SMGRINITIALIZE_78:      /* 'itlc': system script (+38) and flags; then 'KCHR' 0 if there is no keyboard table yet (ExpandMem +14) */
    subqw #4,%sp
    movel #1769237603,%sp@-
    clrw %sp@-
    _GetResource
    movel %sp@,%d0
    jbeq SMGRINITIALIZE_190
    moveal %d0,%a0
    moveal %a0@,%a0
    moveb %a0@(4),%d0
    moveb %d0,%a4@(6)
    moveb %a0@(5),%d0
    moveb %d0,%a4@(7)
    moveb %a0@(7),%d0
    moveb %d0,%a4@(10)
    movel %a0@(8),%d0
    movel %d0,%a4@(396)
    movew %a0@,%d0
    movew %d0,%a4@(38)
    movew #409,%a4@(58)
    _ReleaseResource
    moveal ExpandMem,%a2
    movel %a2@(14),%d0
    jbne SMGRINITIALIZE_10C
    clrl %sp@-
    movel #1262700626,%sp@-
    clrw %sp@-
    movew #-1,ROMMapInsert
    _GetResource
    moveal %sp@+,%a0
    movel %a0,%d4
    jbeq SMGRINITIALIZE_190
    _GetHandleSize
    cmpil #2048,%d0
    jbge SMGRINITIALIZE_F0
    movel #2048,%d0
SMGRINITIALIZE_F0:      /* copy the 'KCHR' into a new pointer 512 bytes larger, at ExpandMem +14 */
    addil #512,%d0
    movel %d0,%d3
    .short  0xA71E	| 40821AF8 _NewPtr (flags 0x0700)
    jbne SMGRINITIALIZE_190
    movel %a0,%a2@(14)
    moveal %a0,%a1
    moveal %d4,%a0
    moveal %a0@,%a0
    movel %d3,%d0
    _BlockMove
SMGRINITIALIZE_10C:     /* the Roman script record: version, 'ZSYS' and the System file's name (SysResName), ... */
    moveq #116,%d0
    jbsr SMGRINITIALIZE_19E
    moveal %a0,%a2
    movel %a2,%a4@(114)
    movew #257,%a2@
    movel #1515411795,%a2@(40)
    lea SysResName,%a0
    movel %a0,%a2@(44)
    movew #3,%a2@(10)
    moveq #60,%d0
    bsrw SMGRINITIALIZE_19E
    movel %a0,%a2@(64)
    movew #12,%a2@(68)
    movew #40,%a2@(70)
    lea %pc@(ROMANDISPTABLE),%a1
    moveal %a1,%a4
    movew #14,%d0
    movel %a2,%sp@-
SMGRINITIALIZE_154:     /* its routine table */
    movew %a1@+,%d1
    lea %a4@(0x0,%d1:w),%a2
    movel %a2,%a0@+
    dbf %d0,SMGRINITIALIZE_154
    moveal %sp@+,%a2
    movew #16383,%d4
    subqw #4,%sp
    movel #1179602500,%sp@-
    movew %d4,%sp@-
    _GetResource
    tstl %sp@+
    jbne SMGRINITIALIZE_178
    clrw %d4
SMGRINITIALIZE_178:     /* Roman font family; the Roman routine table */
    movew %d4,%a2@(8)
    lea %pc@(ROMANTABLE),%a1
SMGRINITIALIZE_180:     /* loop: (offset, routine) pairs, 0 ends */
    movel %a1@+,%d0
    jbeq SMGRINITIALIZE_196
    lea %a3@(0x0,%d0:w),%a0
    swap %d0
    movel %a0,%a2@(0x0,%d0:w)
    jbra SMGRINITIALIZE_180
SMGRINITIALIZE_190:     /* no memory, 'itlc' or 'KCHR': system error 32767 */
    movew #32767,%d0
    _SysError
SMGRINITIALIZE_196:     /* restore registers, return */
    moveml %sp@+,%d0-%a4
    unlk %fp
    rts

SMGRINITIALIZE_19E:     /* _NewPtr, system heap, cleared; failure: system error 32767 */
    .short  0xA71E	| 40821B9E _NewPtr (flags 0x0700)
    jbeq SMGRINITIALIZE_1A8
    movew #32767,%d0
    _SysError
SMGRINITIALIZE_1A8:     /* return */
    rts
    .short  0x0000, 0x0000, 0x0000	| 40821BAA

/* SMGRTABLE: Script Manager vector table. */
SMGRTABLE:
    .short  0x0016, PRINTACTION-PATCHSTART	| 40821BB0
    .short  0x01C0, APPENDSYMBOL-PATCHSTART	| 40821BB4
    .short  0x01C4, CONVERTTOSTRING-PATCHSTART	| 40821BB8
    .short  0x01C8, EXPHANDLING-PATCHSTART	| 40821BBC
    .short  0x01CC, EXPMATCHING-PATCHSTART	| 40821BC0
    .short  0x01D0, CHECKFORDIGITS-PATCHSTART	| 40821BC4
    .short  0x01D4, XFORM2STR_B0-PATCHSTART	| 40821BC8
    .short  0x01D8, COND-PATCHSTART	| 40821BCC
    .short  0x01DC, CHECKFORM-PATCHSTART	| 40821BD0
    .short  0x01E0, TACKONEXP-PATCHSTART	| 40821BD4
    .short  0x01E4, MAKEEXP-PATCHSTART	| 40821BD8
    .short  0x01E8, CHECKPARTSINTEGRITY-PATCHSTART	| 40821BDC
    .short  0x01EC, INUNQUOTEDS-PATCHSTART	| 40821BE0
    .short  0x01F0, ISSUBSTRING-PATCHSTART	| 40821BE4
    .short  0x01F4, XSWAPICON-PATCHSTART	| 40821BE8
    .short  0x01F8, XSWAPKYBD-PATCHSTART	| 40821BEC
    .short  0x01FC, XFIXSMGRWORLD-PATCHSTART	| 40821BF0
    .byte   0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00	| 40821BF4

/* PATCHTABLE: patch table. */
PATCHTABLE:
    .long   0x00B50190, 0x0A060000, 0x00000000, 0x00000000	| 40821C00

/* ROMANTABLE: Roman script table. */
ROMANTABLE:
    .short  0x0020, ROMANPRINT-PATCHSTART	| 40821C10
    .short  0x0024, ROMANSCRIPT-PATCHSTART	| 40821C14
    .short  0x0030, ROMANNAME-PATCHSTART	| 40821C18
    .byte   0x00, 0x00, 0x00, 0x00	| 40821C1C

/* disable: disable interrupts helper. */
disable:
    moveq #0,%d0
    movew %sr,%d0
    lsrw #8,%d0
    andiw #7,%d0
    oriw #1792,%sr
    rts

/* spl: set the interrupt level helper. */
spl:
    movew %sr,%d0
    movew %sp@(6),%d1
    lslw #8,%d1
    andiw #-1793,%d0
    orw %d1,%d0
    movew %d0,%sr
    rts
    .short  0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000, 0x0000	| 40821C42
