/*
 * reset.s - Macintosh Quadra 800 early 68040 CPU detection & MMU/cache setup
 *
 * Decompiled and reconstructed from QUADRA800.ROM (Motorola 68040), ROM offset 0x4052.
 * tools/build_rom.py copies _early_cpu_detect.._cpu_detect_done (exclusive) into the
 * rebuilt ROM at the address of the early_cpu_detect label of the disassembled source.
 * The code after it is kept so that the PC-relative lea of _tc_zero keeps its offset.
 */

    .text
    .globl _early_cpu_detect

/* -------------------------------------------------------------------------
 * 68040 CPU Detection & MMU/Cache Configuration (Offset 0x00004052)
 * Called with the return address in %fp.
 * ------------------------------------------------------------------------- */
_early_cpu_detect:
    sub.l   %d0, %d0
    bset    #31, %d0                /* Set bit 31 of CACR (68040 Instruction Cache) */
    movec   %d0, %cacr
    movec   %cacr, %d0
    btst    #31, %d0                /* Did bit 31 persist? */
    beq.s   _cpu_is_68030           /* If not, fallback to 68030 mode */

    /* CPU is Motorola 68040: */
    .word   0xF4D8                  /* cinva bc: Invalidate both I-cache and D-cache */
    sub.l   %d0, %d0
    movec   %d0, %cacr              /* Disable caches during boot */
    .word   0x4E7B, 0x0003          /* movec %d0, %tc: Disable 68040 MMU Translation Control */

    /* Setup Data Transparent Translation Registers */
    move.l  #0x807FC040, %d0        /* DTT0: $80000000-$FFFFFFFF Serialized Cache-Inhibit */
    .word   0x4E7B, 0x0006          /* movec %d0, %dtt0 */
    move.l  #0x500FC040, %d0        /* DTT1: $50000000-$50FFFFFF I/O Space Cache-Inhibit */
    .word   0x4E7B, 0x0007          /* movec %d0, %dtt1 */
    bra.s   _cpu_detect_done

_cpu_is_68030:
    move.l  #0x00002000, %d0        /* 68030 CACR clear */
    movec   %d0, %cacr
    movec   %cacr, %d0
    tst.l   %d0
    beq.s   _cpu_detect_done
    lea     _tc_zero(%pc), %a0
    .word   0xF010, 0x4000          /* pmove (%a0), %tc: Disable 68030 MMU */

_cpu_detect_done:
    jmp     (%fp)                   /* Return using %fp link register */

_tc_zero:
    .long   0x00000000, 0x00000000
