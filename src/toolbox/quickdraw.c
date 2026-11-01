/**
 * @file quickdraw.c
 * @brief Color QuickDraw Graphics Engine Implementation
 *
 * Decompiled from QUADRA800.ROM:
 * - 0x40831530: _InitGraf
 * - 0x408280A0: _InitCursor
 */

#include "quickdraw.h"
#include "lowmem.h"
#include <string.h>

/* Portable / Host Reconstructed QuickDraw Graphics Engine */

static GrafPtr s_current_port = NULL;

void MacInitGraf(Ptr global_ptr) {
    if (!global_ptr) return;
    QDGlobals *qd = (QDGlobals *)global_ptr;
    memset(qd, 0, sizeof(QDGlobals));
    
    /* Standard standard pattern initializers */
    memset(qd->white.pat, 0x00, 8);
    memset(qd->black.pat, 0xFF, 8);
    for (int i = 0; i < 8; i++) {
        qd->gray.pat[i] = (i % 2 == 0) ? 0xAA : 0x55;
        qd->ltGray.pat[i] = (i % 4 == 0) ? 0x88 : 0x22;
        qd->dkGray.pat[i] = (i % 2 == 0) ? 0x77 : 0xDD;
    }
    
    qd->thePort = NULL;
    s_current_port = NULL;
}

void MacInitCursor(void) {
    /* Set arrow cursor active */
}

void MacSetPort(GrafPtr port) {
    s_current_port = port;
}

void MacGetPort(GrafPtr *port) {
    if (port) *port = s_current_port;
}

void MacMoveTo(int16_t h, int16_t v) {
    if (s_current_port) {
        s_current_port->pnLoc.h = h;
        s_current_port->pnLoc.v = v;
    }
}

void MacLineTo(int16_t h, int16_t v) {
    if (s_current_port) {
        s_current_port->pnLoc.h = h;
        s_current_port->pnLoc.v = v;
    }
}

void MacPaintRect(const Rect *r) {
    (void)r;
}

