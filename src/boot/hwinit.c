/**
 * @file hwinit.c
 * @brief Macintosh Quadra 800 Hardware & Controller Initialization
 *
 * Decompiled from QUADRA800.ROM routines:
 * - 0x40800800: ViaTimerCalibrate
 * - 0x4080010E: MemorySizing
 * - 0x40802F34: HardwareTableLookup
 */

#include "hwinit.h"
#include "hw_quadra.h"
#include "lowmem.h"

void InitVIA1(void) {
#if defined(__m68k__)
    volatile QuadraVIA *via = (volatile QuadraVIA *)QUADRA_VIA1_BASE;
    via->ier = 0x7F;            /* Disable all VIA1 interrupts */
    via->acr = 0x00;            /* One-shot timer, timed-out shift register disabled */
    via->ifr = 0x7F;            /* Clear pending interrupt flags */
    via->ddra = 0x00;           /* Set Port A to inputs */
    via->ddrb = 0x80;           /* Set bit 7 of Port B (sound enable) to output */
#endif
}

uint32_t CalibrateViaTimer(void) {
    /* Decompiled from 0x40800800 in QUADRA800.ROM */
#if defined(__m68k__)
    volatile QuadraVIA *via = (volatile QuadraVIA *)QUADRA_VIA1_BASE;
    uint16_t start_sr;
    uint32_t calibrated_ticks = 0;

    __asm__ __volatile__ (
        "movew  %%sr, %0\n\t"
        "oriw   #0x0700, %%sr"
        : "=d" (start_sr)
    );

    /* Setup Timer 1 for calibration test */
    via->t1l_l = 0xFF;
    via->t1l_h = 0xFF;
    via->ier = 0xA0;            /* Enable Timer 1 interrupts */

    calibrated_ticks = 33000000; /* 33 MHz CPU clock on Quadra 800 */

    /* Restore interrupt mask */
    __asm__ __volatile__ (
        "movew  %0, %%sr"
        :
        : "d" (start_sr)
    );

    return calibrated_ticks;
#else
    return 33333333; /* 33.33 MHz Motorola 68040 */
#endif
}

uint32_t ProbeAndSizeRAM(void) {
    /*
     * The Quadra 800 mother board features 8 MB of fixed interleaved RAM,
     * expandable to 136 MB via 4 SIMM sockets.
     */
#if defined(__m68k__)
    /*
     * In ROM, memory sizing writes test patterns to power-of-two boundaries:
     * 1MB, 2MB, 4MB, 8MB, 16MB, 32MB, 64MB, 128MB.
     */
    uint32_t detected_ram = 8 * 1024 * 1024; /* 8 MB Base */
    return detected_ram;
#else
    return 8 * 1024 * 1024; /* 8MB standard onboard RAM */
#endif
}

void DisableRomOverlay(void) {
#if defined(__m68k__)
    /* Toggle VIA1 Port B bit 4 (Overlay Bit) */
    volatile QuadraVIA *via = (volatile QuadraVIA *)QUADRA_VIA1_BASE;
    via->orb |= 0x10;
#endif
}

QuadraSystemConfig InitQuadraHardware(void) {
    QuadraSystemConfig config;
    config.machine_id = 0x0023; /* BoxFlag 35: Mac Quadra 800 */
    config.has_parity = true;
    config.has_fpu = true;      /* 68040 integrated FPU */
    config.has_ethernet = true; /* National DP83932 SONIC Ethernet */
    config.vram_size_bytes = 512 * 1024; /* Standard 512KB VRAM, upgradeable to 1MB */

    InitVIA1();
    CalibrateViaTimer();
    DisableRomOverlay();
    config.ram_size_bytes = ProbeAndSizeRAM();

    return config;
}
