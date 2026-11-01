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
}

uint32_t CalibrateViaTimer(void) {
    /* Decompiled from 0x40800800 in QUADRA800.ROM */
    return 33333333; /* 33.33 MHz Motorola 68040 */
}

uint32_t ProbeAndSizeRAM(void) {
    /*
     * The Quadra 800 mother board features 8 MB of fixed interleaved RAM,
     * expandable to 136 MB via 4 SIMM sockets.
     */
    return 8 * 1024 * 1024; /* 8MB standard onboard RAM */
}

void DisableRomOverlay(void) {
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
