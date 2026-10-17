/**
 * @file mem_manager.c
 * @brief Macintosh Classic Memory Manager Implementation
 *
 * Decompiled from QUADRA800.ROM:
 * - 0x4088D360: _NewPtr
 * - 0x4088D3A0: _DisposPtr
 * - 0x4089D448: _NewHandle
 * - 0x4089D484: _DisposHandle
 * - 0x408BD628: _HLock
 * - 0x408BD64E: _HUnlock
 */

#include "mem_manager.h"
#include "lowmem.h"
#include <stdlib.h>
#include <string.h>

#if defined(__m68k__)

Ptr MacNewPtr(int32_t logical_size) {
    register int32_t d0_size __asm__("d0") = logical_size;
    register Ptr a0_result __asm__("a0");
    __asm__ __volatile__ (
        ".short 0xA11E" /* _NewPtr */
        : "=r" (a0_result), "+r" (d0_size)
        :
        : "d1", "a1", "memory"
    );
    return a0_result;
}

OSErr MacDisposPtr(Ptr p) {
    register Ptr a0_ptr __asm__("a0") = p;
    register int16_t d0_err __asm__("d0");
    __asm__ __volatile__ (
        ".short 0xA01F" /* _DisposPtr */
        : "=r" (d0_err), "+r" (a0_ptr)
        :
        : "d1", "a1", "memory"
    );
    return d0_err;
}

Handle MacNewHandle(int32_t logical_size) {
    register int32_t d0_size __asm__("d0") = logical_size;
    register Handle a0_result __asm__("a0");
    __asm__ __volatile__ (
        ".short 0xA122" /* _NewHandle */
        : "=r" (a0_result), "+r" (d0_size)
        :
        : "d1", "a1", "memory"
    );
    return a0_result;
}

OSErr MacDisposHandle(Handle h) {
    register Handle a0_handle __asm__("a0") = h;
    register int16_t d0_err __asm__("d0");
    __asm__ __volatile__ (
        ".short 0xA023" /* _DisposHandle */
        : "=r" (d0_err), "+r" (a0_handle)
        :
        : "d1", "a1", "memory"
    );
    return d0_err;
}

void MacHLock(Handle h) {
    register Handle a0_handle __asm__("a0") = h;
    __asm__ __volatile__ (
        ".short 0xA029" /* _HLock */
        : "+r" (a0_handle)
        :
        : "d0", "d1", "a1", "memory"
    );
}

void MacHUnlock(Handle h) {
    register Handle a0_handle __asm__("a0") = h;
    __asm__ __volatile__ (
        ".short 0xA02A" /* _HUnlock */
        : "+r" (a0_handle)
        :
        : "d0", "d1", "a1", "memory"
    );
}

void MacInitZone(THz zone, Ptr limit_ptr, int16_t master_count) {
    if (!zone || !limit_ptr) return;
    memset(zone, 0, sizeof(Zone));
    zone->bkLim = limit_ptr;
    zone->hFstFree = (Ptr)(zone + 1);
    zone->zcbFree = (int32_t)(limit_ptr - (Ptr)zone->hFstFree);
    zone->moreMast = master_count;
}

#else

/* Portable / Host Reconstructed Memory Manager Implementation */

Ptr MacNewPtr(int32_t logical_size) {
    if (logical_size <= 0) return NULL;
    /* Physical size = logical size + 8 byte block header */
    uint8_t *raw = (uint8_t *)malloc((size_t)logical_size + 8);
    if (!raw) return NULL;
    BlockHeader *hdr = (BlockHeader *)raw;
    hdr->tag = BLOCK_TAG_NONRELOCATABLE;
    hdr->size_h = (uint8_t)((logical_size + 8) >> 16);
    hdr->size_l = (uint16_t)((logical_size + 8) & 0xFFFF);
    hdr->u.zone_ptr = NULL;
    return (Ptr)(raw + 8);
}

OSErr MacDisposPtr(Ptr p) {
    if (!p) return nilHandleErr;
    uint8_t *raw = (uint8_t *)p - 8;
    free(raw);
    return noErr;
}

Handle MacNewHandle(int32_t logical_size) {
    Ptr p = MacNewPtr(logical_size);
    if (!p) return NULL;
    Handle h = (Handle)malloc(sizeof(Ptr));
    if (!h) {
        MacDisposPtr(p);
        return NULL;
    }
    *h = p;
    BlockHeader *hdr = (BlockHeader *)((uint8_t *)p - 8);
    hdr->tag = BLOCK_TAG_RELOCATABLE;
    hdr->u.master_ptr = h;
    return h;
}

OSErr MacDisposHandle(Handle h) {
    if (!h) return nilHandleErr;
    if (*h) {
        MacDisposPtr(*h);
        *h = NULL;
    }
    free(h);
    return noErr;
}

void MacHLock(Handle h) {
    if (!h || !*h) return;
    BlockHeader *hdr = (BlockHeader *)((uint8_t *)*h - 8);
    hdr->tag |= MP_FLAG_LOCKED;
}

void MacHUnlock(Handle h) {
    if (!h || !*h) return;
    BlockHeader *hdr = (BlockHeader *)((uint8_t *)*h - 8);
    hdr->tag &= ~MP_FLAG_LOCKED;
}

void MacInitZone(THz zone, Ptr limit_ptr, int16_t master_count) {
    if (!zone || !limit_ptr) return;
    memset(zone, 0, sizeof(Zone));
    zone->bkLim = limit_ptr;
    zone->moreMast = master_count;
}

#endif
