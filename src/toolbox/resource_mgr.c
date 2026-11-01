/**
 * @file resource_mgr.c
 * @brief Macintosh Classic Resource Manager Implementation
 *
 * Decompiled from QUADRA800.ROM:
 * - 0x4081B5A0: _GetResource
 * - 0x4081BBDC: _ReleaseResource
 * - 0x4081BCE8: _CurResFile
 * - 0x4081AF9E: _OpenResFile
 * - 0x4081B388: _CloseResFile
 */

#include "resource_mgr.h"
#include "mem_manager.h"
#include "lowmem.h"
#include <string.h>

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

