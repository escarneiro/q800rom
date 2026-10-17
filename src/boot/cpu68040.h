/**
 * @file cpu68040.h
 * @brief Motorola 68040 CPU Initialization and Cache/MMU Management
 */

#ifndef CPU68040_H
#define CPU68040_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    CPU_TYPE_68000 = 0,
    CPU_TYPE_68010 = 1,
    CPU_TYPE_68020 = 2,
    CPU_TYPE_68030 = 3,
    CPU_TYPE_68040 = 4
} MacCpuType;

/**
 * @brief Detects CPU type and configures early 68040 MMU/cache registers.
 * Decompiled from QUADRA800.ROM at 0x40804052.
 */
MacCpuType EarlyCpuDetect(void);

/**
 * @brief Invalidates all lines in both instruction and data caches.
 * Corresponds to 68040 instruction 'cinva bc' (0xF4D8).
 */
void InvalidateAllCaches(void);

/**
 * @brief Pushes dirty data cache lines to memory and invalidates both caches.
 * Corresponds to 68040 instruction 'cpusha bc' (0xF4F8).
 */
void PushAndInvalidateCaches(void);

/**
 * @brief Configures 68040 Transparent Translation registers.
 * Decompiled from QUADRA800.ROM at 0x40804072.
 */
void ConfigureTransparentTranslation(uint32_t dtt0_val, uint32_t dtt1_val);

/**
 * @brief Enables or disables 68040 instruction and data caches.
 */
void SetCacheControl(bool enable_icache, bool enable_dcache);

#ifdef __cplusplus
}
#endif

#endif /* CPU68040_H */
