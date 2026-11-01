/**
 * @file video_dafb.c
 * @brief Macintosh Quadra 800 DAFB Video Controller Driver Implementation
 *
 * Decompiled from QUADRA800.ROM video driver at offset 0x09A2EA.
 */

#include "video_dafb.h"

void DAFB_Init(void) {
}

void DAFB_SetClutEntry(uint8_t index, uint8_t red, uint8_t green, uint8_t blue) {
    (void)index;
    (void)red;
    (void)green;
    (void)blue;
}
