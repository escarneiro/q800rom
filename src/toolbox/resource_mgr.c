/**
 * @file resource_mgr.c
 * @brief Macintosh Classic Resource Manager Implementation
 *
 * Decompiled from QUADRA800.ROM:
 * - 0x408DB5A0: _GetResource
 * - 0x408DBBDC: _ReleaseResource
 * - 0x408BBCE8: _CurResFile
 * - 0x408CAF9E: _OpenResFile
 * - 0x408CAFE2: _CloseResFile
 */

#include "resource_mgr.h"
#include "mem_manager.h"
#include "lowmem.h"
#include <string.h>

#if defined(__m68k__)

Handle MacGetResource(ResType the_type, int16_t the_id) {
    register ResType d0_type __asm__("d0") = the_type;
    register int16_t d1_id __asm__("d1") = the_id;
    register Handle a0_res __asm__("a0");
    __asm__ __volatile__ (
        "movel  %1, -(%%sp)\n\t"
        "movew  %2, -(%%sp)\n\t"
        ".short 0xA9A0\n\t" /* _GetResource */
        "movel  (%%sp)+, %0"
        : "=r" (a0_res)
        : "r" (d0_type), "r" (d1_id)
        : "a1", "memory"
    );
    return a0_res;
}

void MacReleaseResource(Handle the_resource) {
    register Handle a0_res __asm__("a0") = the_resource;
    __asm__ __volatile__ (
        "movel  %0, -(%%sp)\n\t"
        ".short 0xA9A3" /* _ReleaseResource */
        :
        : "r" (a0_res)
        : "d0", "d1", "a1", "memory"
    );
}

int16_t MacCurResFile(void) {
    register int16_t d0_ref __asm__("d0");
    __asm__ __volatile__ (
        ".short 0xA994\n\t" /* _CurResFile */
        "movew  (%%sp)+, %0"
        : "=r" (d0_ref)
        :
        : "memory"
    );
    return d0_ref;
}

void MacInitResources(void) {
    /* Sets up ROMMapHndl at 0x0B06 and inserts ROM resource map */
    LM_RomMapInsert = 0xFF; /* Check ROM resources */
}

#else

/* Portable / Host Resource Manager Stub */
static int16_t s_cur_res_file = 0;

void MacInitResources(void) {
    s_cur_res_file = 1;
}

Handle MacGetResource(ResType the_type, int16_t the_id) {
    /* Returns mock resource handle for analysis */
    Handle h = MacNewHandle(64);
    if (h && *h) {
        memset(*h, 0, 64);
    }
    return h;
}

void MacReleaseResource(Handle the_resource) {
    if (the_resource) {
        MacDisposHandle(the_resource);
    }
}

int16_t MacCurResFile(void) {
    return s_cur_res_file;
}

#endif
