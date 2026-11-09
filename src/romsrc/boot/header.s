/*
 boot/header.s - Quadra 800 ROM header, 0x40800000..0x4080008B

 Names in upper case are Apple's (MPW ROM map); hdr_* names
 are this project's. Offsets are relative to the start of the ROM (ROMBase 0x40800000).
*/

MYFIRSTPROC:            /* start of the ROM (also BASEOFROM, MYROM) */
BASEOFROM:              /* (same address: start of the ROM) */
MYROM:                  /* (data) */
/*
 +0x00: 32-bit ROM checksum: sum of all 16-bit words from offset 4 to the end of the
 ROM. Verified at every boot by STARTUPROMTEST; tools/rom_postlink.py recomputes it.
 At reset the 68040 also loads this long as its initial supervisor stack pointer.
*/
    .long   0xF1ACAD13
/* +0x04: initial program counter at reset (ROM overlaid at address 0): hdr_jmp_reset */
    .long   hdr_jmp_reset-MYFIRSTPROC
/* +0x08: ROM version word */
    .short  0x067C

/* +0x0A, +0x0E: entry points, both enter the cold start code */
hdr_jmp_startboot:      /* +0x0A: start-boot entry */
    jmp     %pc@(reset_startup)
hdr_jmp_baddisk:        /* +0x0E: bad-disk entry (restarts too) */
    jmp     %pc@(reset_startup)

/* +0x12: release information (meaning not established) */
    .short  0x23F2, 0x0100
/* +0x16: offset of the header vector table (hdr_vectors, +0x44) */
    .long   hdr_vectors-rom_start
/* +0x1A: offset of the ROM resource map */
    .long   rsrc_CURS_1_50-rom_start

/* +0x1E: entry point: eject a floppy disk (DOEJECT, the handler of OS trap $A0F7) */
hdr_jmp_eject:
    jmp     %pc@(trap_OSTrap_A0F7)

DISPOFF:                /* offset of the packed trap table */
/*
 +0x22: offset of the packed trap dispatch table (DSPTABLE), decoded at boot by
 INITDISPATCHER and re-encoded after linking by tools/rom_postlink.py
*/
    .long   DSPTABLE-rom_start

CRITICAL:               /* critical error entry */
/* +0x26: entry point: critical error */
    jmp     %pc@(CRITERR)

/* +0x2A: reset entry (the initial PC above points here) */
hdr_jmp_reset:
    jmp     %pc@(reset_startup)

ROMLOC:                 /* unused word */
/* +0x2E */
    .short  0x0000

/*
 +0x30: byte-lane sums, one long per byte lane (offset mod 4), over all bytes except
 0x00..0x03 and 0x30..0x3F. Checked by the diagnostic ROMTEST; recomputed by
 tools/rom_postlink.py.
*/
    .long   0x00F7CDF2, 0x0116B243, 0x00F7B3BC, 0x01118A65

/* +0x40: ROM size in bytes (used by STARTUPROMTEST and ROMTEST) */
    .long   0x00100000

/* +0x44: header vector table: offsets from the ROM start */
hdr_vectors:
    .long   init_trap_dispatcher-rom_start  /* INITDISPATCHER: build the trap tables */
    .long   trap_dispatcher-rom_start       /* DISPATCHER: A-line trap dispatcher */
    .long   UnimplementedTrap-rom_start     /* BADTRAP: unimplemented trap */
    .long   STARTSDECLMGR-rom_start         /* start the Slot Declaration Manager */
    .long   INITMEMVECT-rom_start           /* initialize the Memory Manager vectors */
    .long   hdr_switch_mmu-rom_start        /* hdr_switch_mmu below */

/*
 +0x5C: switch the 68030 MMU to the tables described at (%a0), then continue at %a1:
 caches and MMU off, flush the address translation cache, load the CPU root pointer
 from (%a0) and the translation control register from 8(%a0), turn the caches back on
 as they were (and clear them).
*/
hdr_switch_mmu:
    movec   %cacr,%d0
    movew   %d0,%d1
    andiw   #0xFEFE,%d0             /* clear the cache enable bits */
    movec   %d0,%cacr
    lea     %pc@(hdr_tc_off),%a2
    .short  0xF012, 0x4000	| 4080006E pmove  %a2@,%tc (68030): MMU off
    .short  0xF000, 0x2400	| 40800072 pflusha
    .short  0xF010, 0x4C00	| 40800076 pmove  %a0@,%crp
    .short  0xF028, 0x4000, 0x0008	| 4080007A pmove  %a0@(8),%tc
    oriw    #0x0808,%d1             /* CD|CI: clear both caches */
    movec   %d1,%cacr
    jmp     %a1@

/*
 TC value for "MMU off": only the enable bit (bit 31) matters, so the two zero bytes
 here and the first word of the cold start code that follows form the long.
*/
hdr_tc_off:
    .short  0x0000
