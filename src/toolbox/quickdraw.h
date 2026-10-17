/**
 * @file quickdraw.h
 * @brief Color QuickDraw 2D Graphics Engine
 */

#ifndef QUICKDRAW_H
#define QUICKDRAW_H

#include "mac_types.h"

#ifdef __cplusplus
extern "C" {
#endif

/* QuickDraw Globals Structure (passed to InitGraf) */
typedef struct {
    char        privates[76];
    int32_t     randSeed;
    BitMap      screenBits;
    Pattern     arrow;
    Pattern     dkGray;
    Pattern     ltGray;
    Pattern     gray;
    Pattern     black;
    Pattern     white;
    GrafPtr     thePort;
} QDGlobals;

/**
 * @brief Initializes QuickDraw graphics system and global variables.
 * Decompiled from QUADRA800.ROM at 0x40841530 (_InitGraf / $A86E).
 */
void MacInitGraf(Ptr global_ptr);

/**
 * @brief Sets the standard arrow cursor and makes it visible.
 * Decompiled from QUADRA800.ROM at 0x408280A0 (_InitCursor / $A850).
 */
void MacInitCursor(void);

/**
 * @brief Sets the current drawing port.
 */
void MacSetPort(GrafPtr port);

/**
 * @brief Gets the current drawing port.
 */
void MacGetPort(GrafPtr *port);

/**
 * @brief Moves the current pen location to (h, v).
 */
void MacMoveTo(int16_t h, int16_t v);

/**
 * @brief Draws a line from the current pen location to (h, v).
 */
void MacLineTo(int16_t h, int16_t v);

/**
 * @brief Fills a rectangle with the current pen pattern.
 */
void MacPaintRect(const Rect *r);

#ifdef __cplusplus
}
#endif

#endif /* QUICKDRAW_H */
