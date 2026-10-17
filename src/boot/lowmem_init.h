/**
 * @file lowmem_init.h
 * @brief Low-Memory Globals and Exception Vector Table Initialization
 */

#ifndef LOWMEM_INIT_H
#define LOWMEM_INIT_H

#include <stdint.h>
#include "hwinit.h"

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initializes the low-memory globals in RAM according to detected hardware.
 * Decompiled from QUADRA800.ROM at 0x4080010E - 0x40800176.
 */
void InitLowMemoryGlobals(const QuadraSystemConfig *config);

/**
 * @brief Sets up 68000/68040 exception vectors in RAM (0x00000000 - 0x000003FF).
 */
void InitExceptionVectors(uint32_t trap_dispatcher_address);

#ifdef __cplusplus
}
#endif

#endif /* LOWMEM_INIT_H */
