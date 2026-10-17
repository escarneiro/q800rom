/**
 * @file string.h
 * @brief Freestanding string and memory operations for bare-metal m68k and hosted builds
 */

#ifndef MAC_STRING_H
#define MAC_STRING_H

#if defined(__STDC_HOSTED__) && __STDC_HOSTED__ == 1
#include_next <string.h>
#else
#include "mac_types.h"

static inline void *memset(void *dest, int c, size_t n) {
    uint8_t *d = (uint8_t *)dest;
    while (n--) *d++ = (uint8_t)c;
    return dest;
}

static inline void *memcpy(void *dest, const void *src, size_t n) {
    uint8_t *d = (uint8_t *)dest;
    const uint8_t *s = (const uint8_t *)src;
    while (n--) *d++ = *s++;
    return dest;
}

static inline int memcmp(const void *s1, const void *s2, size_t n) {
    const uint8_t *p1 = (const uint8_t *)s1;
    const uint8_t *p2 = (const uint8_t *)s2;
    while (n--) {
        if (*p1 != *p2) return *p1 - *p2;
        p1++; p2++;
    }
    return 0;
}

static inline size_t strlen(const char *s) {
    size_t len = 0;
    while (*s++) len++;
    return len;
}

static inline int strcmp(const char *s1, const char *s2) {
    while (*s1 && (*s1 == *s2)) {
        s1++;
        s2++;
    }
    return *(const unsigned char *)s1 - *(const unsigned char *)s2;
}

#endif /* __STDC_HOSTED__ */

#endif /* MAC_STRING_H */
