/**
 * @file declrom_quadra.h
 * @brief Macintosh Quadra 800 Onboard NuBus Declaration ROM Definitions
 */

#ifndef DECLROM_QUADRA_H
#define DECLROM_QUADRA_H

#include "declrom.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef struct {
    uint16_t width;
    uint16_t height;
    uint8_t  depth_bits;
    uint16_t row_bytes;
    uint32_t vram_base;
} QuadraVideoMode;

extern const NuBusFormatBlock g_quadra_motherboard_format_block;
extern const sRsrcTypeRecord g_quadra_video_type;
extern const QuadraVideoMode g_quadra_video_modes[5];

/**
 * @brief Prints decoded declaration ROM information for analysis.
 */
void DumpQuadraDeclRomInfo(void);

#ifdef __cplusplus
}
#endif

#endif /* DECLROM_QUADRA_H */
