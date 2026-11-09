/*
 patches/windowpatches.s - Window Manager patches, LCD screen check
 From WINDOWMGRPATCH (0x4088D000). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code, not taken from Apple.
*/

/*
 INITWINDOWSFRAMEPATCH / INITWINDOWSRGNPATCH: InitWindows patches for LCD
 screens: when LCDSCREENCHK says the main screen is an LCD, the desktop frame and
 region are drawn without the rounded corners (InsetRect -3,-3 / a 16x16 corner).
*/
WINDOWMGRPATCH:
INITWINDOWSFRAMEPATCH:
    bsrs LCDSCREENCHK
    bnel INITWINDOWSLCDRETURN
    movel %a4,%sp@-
    movel #-131075,%sp@-
    _InsetRect
    bral INITWINDOWSCRTRETURN
    .short  0x0000, 0x0000, 0x0000, 0x0000	| 4088D018
INITWINDOWSRGNPATCH:    /* (desktop region patch) */
    bsrs LCDSCREENCHK
    beqs INITWINDOWSRGNPATCH_E
    movel %a4,%sp@-
    _FrameRect
    bral INITWINDOWSRGNRETURN
INITWINDOWSRGNPATCH_E:
    movel %a4,%sp@-
    movel #1048592,%sp@-
    _FrameRoundRect
    bral INITWINDOWSRGNRETURN

/*
 LCDSCREENCHK: nonzero (Z clear) if the main screen is an LCD: on these ROMs (ROM85
 0x3FFF), find the main device's driver slot and sResource, read its sVidAttributes
 (ID 125) and test bit 0.
*/
LCDSCREENCHK:
    cmpiw #16383,ROM85
    jbne LCDSCREENCHK_66
    tstl DeviceList
    jbeq LCDSCREENCHK_64
    tstl MainDevice
    jbeq LCDSCREENCHK_64
    moveq #0,%d0
    moveal MainDevice,%a0
    moveal %a0@,%a0
    movew %a0@,%d0
    jbeq LCDSCREENCHK_64
    notw %d0
    lslw #2,%d0
    addl UTableBase,%d0
    moveal %d0,%a1
    moveal %a1@,%a1
    moveal %a1@,%a1
    lea %sp@(-56),%sp
    moveal %sp,%a0
    moveb %a1@(40),%a0@(49)
    moveb %a1@(41),%a0@(50)
    clrb %a0@(51)
    moveq #22,%d0	/* _SlotManager 22: SLOTRSRCINFO, sRsrcInfo */
    _SlotManager
    jbne LCDSCREENCHK_5E
    moveb #125,%a0@(50)
    moveq #1,%d0	/* _SlotManager 1: READSLOTWORD, sReadWord */
    _SlotManager
    jbne LCDSCREENCHK_5E
    moveq #1,%d0
    andw %a0@(2),%d0
    jbra LCDSCREENCHK_60
LCDSCREENCHK_5E:        /* no information: 0 */
    moveq #0,%d0
LCDSCREENCHK_60:        /* free the parameter block */
    lea %sp@(56),%sp
LCDSCREENCHK_64:        /* return */
    rts
LCDSCREENCHK_66:        /* other ROM: 0 */
    moveq #0,%d0
    rts
    .fill   0x158, 1, 0x00
