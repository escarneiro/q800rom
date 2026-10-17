/**
 * @file mac_types.h
 * @brief Standard Macintosh Classic Operating System Data Types
 */

#ifndef MAC_TYPES_H
#define MAC_TYPES_H

#if defined(__STDC_HOSTED__) && __STDC_HOSTED__ == 1
#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#else
typedef signed char        int8_t;
typedef unsigned char      uint8_t;
typedef short              int16_t;
typedef unsigned short     uint16_t;
typedef int                int32_t;
typedef unsigned int       uint32_t;
typedef long long          int64_t;
typedef unsigned long long uint64_t;
#if !defined(__bool_true_false_are_defined) && !defined(__cplusplus)
typedef _Bool              bool;
#define bool bool
#define true 1
#define false 0
#define __bool_true_false_are_defined 1
#endif
typedef unsigned long      size_t;
#ifndef NULL
#define NULL ((void*)0)
#endif
#endif

#ifdef __cplusplus
extern "C" {
#endif

typedef int8_t              SignedByte;
typedef uint8_t             Byte;
typedef uint8_t*            Ptr;
typedef uint8_t**           Handle;
typedef int16_t             OSErr;
typedef uint32_t            OSType;
typedef uint32_t            ResType;
typedef int32_t             Fixed;
typedef int32_t             Fract;
typedef uint32_t            FourCharCode;

#define FOUR_CHAR_CODE(x)   (uint32_t)(x)

/* Basic Geometry */
typedef struct {
    int16_t v;
    int16_t h;
} Point;

typedef struct {
    int16_t top;
    int16_t left;
    int16_t bottom;
    int16_t right;
} Rect;

typedef struct {
    uint8_t pat[8];
} Pattern;

typedef struct {
    uint16_t red;
    uint16_t green;
    uint16_t blue;
} RGBColor;

/* QuickDraw BitMap */
typedef struct {
    Ptr     baseAddr;
    int16_t rowBytes;
    Rect    bounds;
} BitMap;

/* Classic GrafPort */
typedef struct GrafPort {
    int16_t     device;
    BitMap      portBits;
    Rect        portRect;
    Handle      visRgn;
    Handle      clipRgn;
    Pattern     bkPat;
    Pattern     fillPat;
    Point       pnLoc;
    Point       pnSize;
    int16_t     pnMode;
    Pattern     pnPat;
    int16_t     pnVis;
    int16_t     txFont;
    uint8_t     txFace;
    uint8_t     txMode;
    int16_t     txSize;
    Fixed       spExtra;
    int32_t     fgColor;
    int32_t     bkColor;
    int16_t     colrBit;
    int16_t     patStretch;
    Handle      picSave;
    Handle      rgnSave;
    Handle      polySave;
    Ptr         grafProcs;
} GrafPort, *GrafPtr;

/* Color QuickDraw PixMap */
typedef struct {
    Ptr         baseAddr;
    int16_t     rowBytes;
    Rect        bounds;
    int16_t     pmVersion;
    int16_t     packType;
    int32_t     packSize;
    Fixed       hRes;
    Fixed       vRes;
    int16_t     pixelType;
    int16_t     pixelSize;
    int16_t     cmpCount;
    int16_t     cmpSize;
    int32_t     planeBytes;
    Handle      pmTable;
    int32_t     pmReserved;
} PixMap, *PixMapPtr, **PixMapHandle;

/* Memory Manager Zone Header */
typedef struct Zone {
    Ptr         bkLim;
    Ptr         purgePtr;
    Ptr         hFstFree;
    int32_t     zcbFree;
    Ptr         gzProc;
    int16_t     moreMast;
    int16_t     flags;
    int16_t     cntRel;
    int16_t     maxRel;
    int16_t     cntNRel;
    int16_t     maxNRel;
    int16_t     cntEmpty;
    int16_t     cntHandles;
    int16_t     minCBFree;
    Ptr         purgeProc;
    Ptr         sparePtr;
    Ptr         allocPtr;
    int16_t     heapData;
} Zone, *THz;

/* Standard Mac OS Errors */
#define noErr           0
#define memFullErr      (-108)
#define nilHandleErr    (-109)
#define memWZErr        (-111)
#define memPurErr       (-112)
#define resNotFound     (-192)
#define resFNotFound    (-193)
#define addResFailed    (-194)
#define rmvResFailed    (-196)

#ifdef __cplusplus
}
#endif

#endif /* MAC_TYPES_H */
