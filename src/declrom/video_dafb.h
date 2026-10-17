/**
 * @file video_dafb.h
 * @brief Macintosh Quadra 800 DAFB Video Controller Driver Interface
 */

#ifndef VIDEO_DAFB_H
#define VIDEO_DAFB_H

#include <stdint.h>
#include <stdbool.h>
#include "mac_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* DAFB Video Registers Base */
#define DAFB_REG_BASE               0x50F16000U
#define DAFB_VRAM_BASE              0xF9000000U

/* DAFB Control Registers */
typedef struct {
    volatile uint32_t reset;        /* 0x00 */
    volatile uint32_t mode;         /* 0x04: Sense lines and resolution mode */
    volatile uint32_t clut_addr;    /* 0x08: CLUT DAC address register */
    volatile uint32_t clut_data;    /* 0x0C: CLUT DAC color data */
    volatile uint32_t int_status;   /* 0x10: Interrupt status & acknowledge */
    volatile uint32_t int_enable;   /* 0x14: VBL Interrupt enable */
} DAFBRegisters;

/**
 * @brief Initializes the DAFB video controller into standard 640x480 8-bit mode.
 */
void DAFB_Init(void);

/**
 * @brief Sets a palette entry in the Color Look-Up Table (CLUT).
 */
void DAFB_SetClutEntry(uint8_t index, uint8_t red, uint8_t green, uint8_t blue);

#ifdef __cplusplus
}
#endif

#endif /* VIDEO_DAFB_H */
