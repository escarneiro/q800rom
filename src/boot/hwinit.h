/**
 * @file hwinit.h
 * @brief Macintosh Quadra 800 Hardware & Controller Initialization
 */

#ifndef HWINIT_H
#define HWINIT_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint32_t ram_size_bytes;
    uint32_t vram_size_bytes;
    uint16_t machine_id;
    bool     has_parity;
    bool     has_fpu;
    bool     has_ethernet;
} QuadraSystemConfig;

/**
 * @brief Initializes VIA1 timer, interrupts, and clears shift register.
 * Decompiled from QUADRA800.ROM at 0x40800800.
 */
void InitVIA1(void);

/**
 * @brief Calibrates VIA1 Timer 1 against CPU cycle counts.
 * Decompiled from QUADRA800.ROM at 0x40800800.
 */
uint32_t CalibrateViaTimer(void);

/**
 * @brief Probes physical RAM banks and computes MemTop ($0108).
 * Decompiled from QUADRA800.ROM at 0x4080010E.
 */
uint32_t ProbeAndSizeRAM(void);

/**
 * @brief Disables ROM overlay mapping so RAM sits at 0x00000000.
 */
void DisableRomOverlay(void);

/**
 * @brief Complete Quadra 800 Hardware Subsystems Initialization.
 */
QuadraSystemConfig InitQuadraHardware(void);

#ifdef __cplusplus
}
#endif

#endif /* HWINIT_H */
