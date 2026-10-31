/*
 * reset.s - Macintosh Quadra 800 ROM Reset Sequence & Early Hardware Setup
 *
 * Decompiled and reconstructed from QUADRA800.ROM (Motorola 68040).
 * Base Address: 0x40800000 (Physical & Virtual ROMBase)
 */

    .text
    .globl _rom_start
    .globl _reset_vector
    .globl _reset_startup
    .globl _early_cpu_detect

/* -------------------------------------------------------------------------
 * ROM Header (0x40800000)
 * ------------------------------------------------------------------------- */
_rom_start:
    .long   0xF1ACAD13              /* 0x0000: 32-bit ROM Checksum */
    .long   0x0000002A              /* 0x0004: Initial Program Counter (Reset Vector) */
    .word   0x067C                  /* 0x0008: ROM Flags / Version info */
    jmp     _reset_startup          /* 0x000A: Early jmp to reset startup */
    jmp     _reset_startup          /* 0x000E: Mirror jump */

    /* Offset 0x0012 - 0x0028: Internal branch & configuration vectors */
    .long   0x23F20100
    .long   0x00000044
    .long   0x0007EC10
    jmp     _hw_lookup              /* 0x001E: Jump to hardware table */
    .word   0x000D                  /* 0x0022: Offset to compressed trap table ($000D3370) */
    .long   0x33704EFA
    .long   0x22E84EFA

/* -------------------------------------------------------------------------
 * Reset Vector Entry Point (Offset 0x0000002A)
 * ------------------------------------------------------------------------- */
_reset_vector:
    bra.s   _reset_startup          /* Branch to power-on reset handler (0x008C) */

    .org    0x0040
    .long   0x00100000              /* 0x0040: Total ROM size (1048576 bytes = 1MB) */
    .long   0x00009A96              /* 0x0044: Entry to Trap Dispatcher init */
    .long   0x000099B0              /* 0x0048: Entry to Trap Dispatcher */
    .long   0x00009AE6              /* 0x004C: Entry to Unimplemented Trap */
    .long   0x00005DE0              /* 0x0050: Entry to Memory Manager init */
    .long   0x0000CC60              /* 0x0054: Entry to Resource Manager init */
    .long   0x0000005C              /* 0x0058: Warm Reset Entry Point offset */

/* -------------------------------------------------------------------------
 * Warm Reset Entry Point (Offset 0x0000005C)
 * ------------------------------------------------------------------------- */
_warm_reset:
    movec   %cacr, %d0              /* Read Cache Control Register */
    move.w  %d0, %d1
    andi.w  #0xFEFE, %d0            /* Clear Cache Enable bits */
    movec   %d0, %cacr
    lea     _tc_disable(%pc), %a2
    .word   0xF012, 0x4000          /* pmove (%a2), %tc: Disable 68030 MMU if present */
    .word   0xF000, 0x2400          /* pflusha */
    ori.w   #0x0808, %d1
    movec   %d1, %cacr
    jmp     (%a1)                   /* Resume execution */

_tc_disable:
    .long   0x00000000, 0x00000000

/* -------------------------------------------------------------------------
 * Power-On Reset Startup Sequence (Offset 0x0000008C)
 * ------------------------------------------------------------------------- */
_reset_startup:
    move.w  #0x2700, %sr            /* Supervisor mode, all interrupts masked */
    lea     _post_cpu_detect(%pc), %fp
    bra.w   _early_cpu_detect       /* Test and initialize 68040 cache/MMU */
    .word   0x0000, 0x0000

_post_cpu_detect:
    reset                           /* Assert external RESET line to clear hardware */
    lea     _post_early_vbr(%pc), %fp
    jmp     _setup_early_vbr        /* Configure temporary VBR and early stack */

_post_early_vbr:
    lea     _post_hw_trampoline(%pc), %fp
    lea     0x4088AB56, %a0
    jmp     (%a0)

_post_hw_trampoline:
    .word   0x6000, 0x082A          /* bra.w 0x408008E0 */

_hw_probe_entry:
    moveq   #0, %d2
    moveml  %d5-%d7/%a5-%fp, -(%sp) /* Save preserved registers across hardware lookup */
    lea     _post_hw_ident(%pc), %fp
    jmp     _hw_lookup              /* Probe machine ID and motherboard hardware */

_post_hw_ident:
    moveal  8(%a0), %a4             /* a4 points to hardware configuration descriptor */
    moveq   #64, %d4
    andb    (%a4), %d4
    lea     _post_diag_check(%pc), %fp
    jmp     0x40802E8C

_post_diag_check:
    cmpib   #5, %d2
    bne.s   _skip_diag_flag
    moveq   #-65, %d3
    andb    (%a4), %d3
    orb     %d4, %d3
    moveb   %d3, (%a4)

_skip_diag_flag:
    moveml  %d0-%d2/%a0-%a3, -(%sp) /* Save registers across memory sizing */
    lea     _post_mem_size(%pc), %fp
    lea     0x4080B190, %a5
    jmp     (%a5)                   /* Execute memory sizing & RAM bank test */

_post_mem_size:
    /* Restore registers after memory sizing */
    moveml  (%sp)+, %d0-%d2/%a0-%a3
    moveml  (%sp)+, %d5-%d7/%a5-%fp

    /* Initialize low memory globals from descriptor */
    .word   0x6100, 0x06C0          /* bsr.w 0x408007C0: Init memory management tables */
    .word   0x6100, 0x06EC          /* bsr.w 0x408007F0: Disable ROM overlay (VIA1 Port B bit 4) */
    .word   0x6100, 0x0968          /* bsr.w 0x40800A70: Calibrate VIA timer */
    .word   0x6100, 0x11F4          /* bsr.w 0x40801300: Set up RAM exception vectors */

    moveal  -20(%a4), %fp           /* Top of RAM (MemTop) */
    moveal  %a4, %a5                /* Usable RAM */
    addal   -12(%a4), %a5           /* BufPtr (bottom of screen/sound buffer) */
    movel   %d0, 0x0DD0             /* System configuration record */
    movel   %d1, 0x0DD4
    movel   %a1, 0x0DD8
    swap    %d2
    move.w  %d2, 0x0B22             /* BoxFlag */
    swap    %d2
    .word   0x6100, 0x07E2          /* bsr.w 0x40800910: Finalize lowmem configuration */
    .word   0x61FF, 0x0000, 0x40FE  /* bsr.l 0x40804230: Launch system bootstrap */
    nop
    nop
    nop
    rts

/* -------------------------------------------------------------------------
 * 68040 CPU Detection & MMU/Cache Configuration (Offset 0x00004052)
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

/* -------------------------------------------------------------------------
 * Early Temporary Vector Table Setup (Offset 0x00002E00)
 * ------------------------------------------------------------------------- */
_setup_early_vbr:
    movea.w #0x2600, %sp            /* Temporary scratch stack before RAM sizing */
    movea.l %fp, %a4                /* Save return link in a4 */
    lea     0x40803D10, %a0         /* Early ROM exception vector table */
    subq.w  #8, %a0
    movec   %a0, %vbr               /* Set VBR to ROM temporary table */
    jmp     (%a4)

/* -------------------------------------------------------------------------
 * Hardware Identification Table Lookup (Offset 0x00002F34)
 * ------------------------------------------------------------------------- */
_hw_lookup:
    lea     0x4080322C, %a0         /* Machine identification table */
    moveq   #0x23, %d2              /* Machine ID for Quadra 800 (BoxFlag 35) */
    jmp     (%fp)

_kernel_launch:
    /* System boot strap */
    rts
