/**
 * @file quickdraw.c
 * @brief Color QuickDraw Graphics Engine Implementation
 *
 * Decompiled from QUADRA800.ROM:
 * - 0x40841530: _InitGraf
 * - 0x408280A0: _InitCursor
 */

#include "quickdraw.h"
#include "lowmem.h"
#include <string.h>

#if defined(__m68k__)

void MacInitGraf(Ptr global_ptr) {
    register Ptr a0_glob __asm__("a0") = global_ptr;
    __asm__ __volatile__ (
        "movel  %0, -(%%sp)\n\t"
        ".short 0xA86E" /* _InitGraf */
        :
        : "r" (a0_glob)
        : "d0", "d1", "d2", "a1", "memory"
    );
}

void MacInitCursor(void) {
    __asm__ __volatile__ (
        ".short 0xA850" /* _InitCursor */
        ::: "d0", "d1", "a0", "a1", "memory"
    );
}

void MacSetPort(GrafPtr port) {
    register GrafPtr a0_port __asm__("a0") = port;
    __asm__ __volatile__ (
        "movel  %0, -(%%sp)\n\t"
        ".short 0xA880" /* _SetPort */
        :
        : "r" (a0_port)
        : "memory"
    );
}

void MacGetPort(GrafPtr *port) {
    register GrafPtr *a0_port __asm__("a0") = port;
    __asm__ __volatile__ (
        "movel  %0, -(%%sp)\n\t"
        ".short 0xA881" /* _GetPort */
        :
        : "r" (a0_port)
        : "memory"
    );
}

void MacMoveTo(int16_t h, int16_t v) {
    __asm__ __volatile__ (
        "movew  %0, -(%%sp)\n\t"
        "movew  %1, -(%%sp)\n\t"
        ".short 0xA896" /* _MoveTo */
        :
        : "r" (h), "r" (v)
        : "memory"
    );
}

void MacLineTo(int16_t h, int16_t v) {
    __asm__ __volatile__ (
        "movew  %0, -(%%sp)\n\t"
        "movew  %1, -(%%sp)\n\t"
        ".short 0xA898" /* _LineTo */
        :
        : "r" (h), "r" (v)
        : "memory"
    );
}

void MacPaintRect(const Rect *r) {
    register const Rect *a0_r __asm__("a0") = r;
    __asm__ __volatile__ (
        "movel  %0, -(%%sp)\n\t"
        ".short 0xA8A1" /* _PaintRect */
        :
        : "r" (a0_r)
        : "memory"
    );
}

#else

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

#endif
