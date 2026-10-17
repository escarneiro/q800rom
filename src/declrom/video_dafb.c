/**
 * @file video_dafb.c
 * @brief Macintosh Quadra 800 DAFB Video Controller Driver Implementation
 *
 * Decompiled from QUADRA800.ROM video driver at offset 0x09A2EA.
 */

#include "video_dafb.h"

void DAFB_Init(void) {
#if defined(__m68k__)
    volatile DAFBRegisters *dafb = (volatile DAFBRegisters *)DAFB_REG_BASE;
    dafb->reset = 0x01;         /* Assert video controller reset */
    dafb->reset = 0x00;         /* Clear reset */
    dafb->mode = 0x03;          /* Standard 640x480 resolution mode */
    dafb->int_enable = 0x01;    /* Enable VBL interrupts */
#endif
}

void DAFB_SetClutEntry(uint8_t index, uint8_t red, uint8_t green, uint8_t blue) {
#if defined(__m68k__)
    volatile DAFBRegisters *dafb = (volatile DAFBRegisters *)DAFB_REG_BASE;
    dafb->clut_addr = index;
    dafb->clut_data = red;
    dafb->clut_data = green;
    dafb->clut_data = blue;
#else
    (void)index;
    (void)red;
    (void)green;
    (void)blue;
#endif
}
