/*
 * trap_dispatcher.s - Macintosh A-Line Exception & Trap Dispatcher
 *
 * Decompiled from QUADRA800.ROM at address 0x408099B0.
 *
 * Handles Line 1010 Emulator exceptions (Vector 10, Address $00000028).
 * Decodes the 16-bit A-Line trap instruction, determines if it is an
 * Operating System Trap ($A000 - $A7FF) or a Toolbox Trap ($A800 - $AFFF),
 * and dispatches to the corresponding routine in OSTable or ToolboxTable.
 */

    .text
    .globl _trap_dispatcher
    .globl _unimplemented_trap_handler

/* -------------------------------------------------------------------------
 * A-Line Trap Dispatcher Entry Point (0x408099B0)
 * ------------------------------------------------------------------------- */
_trap_dispatcher:
    movel   %a2, -(%sp)             /* Save scratch registers */
    movel   %d2, -(%sp)
    moveal  10(%sp), %a2            /* Load Exception Program Counter from stack */
    movew   (%a2)+, %d2             /* Fetch the A-line trap word and advance PC */
    cmpiw   #0xA800, %d2            /* Is it an OS Trap ($A000-$A7FF) or Toolbox ($A800-$AFFF)? */
    bcs.s   _os_trap                /* If < $A800, branch to OS Trap dispatcher */

/* -------------------------------------------------------------------------
 * Toolbox Trap Dispatching ($A800 - $AFFF)
 * ------------------------------------------------------------------------- */
_toolbox_trap:
    subiw   #0xAC00, %d2            /* Check if trap has auto-pop bit set ($AC00 - $AFFF) */
    bcc.s   _toolbox_autopop

    /* Standard Toolbox Trap ($A800 - $ABFF): */
    /* Target routine address = ToolboxTable[$0E00] + (trap_num & 0x03FF) * 4 */
    movel   0x1E00(,%d2:w:4), 8(%sp)/* Place routine entry address onto stack */
    movel   %a2, 12(%sp)            /* Update return PC on stack */
    movel   (%sp)+, %d2             /* Restore registers */
    moveal  (%sp)+, %a2
    rts                             /* Jump directly into Toolbox routine */

_toolbox_autopop:
    /* Auto-pop Toolbox Trap ($AC00 - $AFFF): */
    movel   0x0E00(,%d2:w:4), 8(%sp)
    movel   (%sp)+, %d2
    moveal  (%sp)+, %a2
    rtd     #4                      /* Pop 4-byte return address from stack */

/* -------------------------------------------------------------------------
 * Operating System Trap Dispatching ($A000 - $A7FF)
 * ------------------------------------------------------------------------- */
_os_trap:
    movel   %d1, -(%sp)             /* Save additional scratch registers */
    movel   %a1, -(%sp)
    movew   %d2, %d1                /* Copy trap word to d1 */
    movel   %a2, 20(%sp)            /* Save updated return PC onto exception frame */
    andiw   #0x0100, %d2            /* Test bit 8 (pass a0 / don't save a0) */
    bne.s   _os_trap_fast

    /* Standard OS Trap with register saving: */
    moveb   %d1, %d2                /* Extract 8-bit trap index */
    movel   %a0, -(%sp)             /* Preserve a0 parameter block pointer */
    jsr     0x0400(,%d2:w:4)        /* Call routine through OSTable ($0400) */
    moveal  (%sp)+, %a0             /* Restore a0 */
    moveal  (%sp)+, %a1             /* Restore a1 */
    movel   (%sp)+, %d1             /* Restore d1 */
    movel   (%sp)+, %d2             /* Restore d2 */
    moveal  (%sp)+, %a2             /* Restore a2 */
    tstw    %d0                     /* Set condition codes based on OSErr in d0 */
    addqw   #4, %sp                 /* Pop exception frame */
    rts

_os_trap_fast:
    moveb   %d1, %d2
    jsr     0x0400(,%d2:w:4)        /* Call routine without saving a0 */
    moveal  (%sp)+, %a1
    movel   (%sp)+, %d1
    movel   (%sp)+, %d2
    moveal  (%sp)+, %a2
    tstw    %d0                     /* Test OSErr result */
    addqw   #4, %sp
    rts

/* -------------------------------------------------------------------------
 * Unimplemented Trap Handler (0x40809AE6)
 * ------------------------------------------------------------------------- */
_unimplemented_trap_handler:
    moveml  %d0-%sp, 0x0C30         /* Save all CPU registers into low-memory DSAlertTab */
    moveq   #12, %d0                /* System Error ID 12: Unimplemented Core Routine */
    jmp     0x40802726              /* Branch to System Error Alert display */
