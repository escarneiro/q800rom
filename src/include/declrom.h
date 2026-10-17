/**
 * @file declrom.h
 * @brief NuBus Declaration ROM and sResource Structures for Macintosh
 *
 * Implements data types and constants according to Apple "Designing Cards
 * and Drivers for the Macintosh Family".
 */

#ifndef DECLROM_H
#define DECLROM_H

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

#define NUBUS_TEST_PATTERN          0x5A932BC7U
#define NUBUS_REVISION_LEVEL        0x01U
#define NUBUS_FORMAT_VERSION        0x01U
#define NUBUS_BYTELANES_32BIT       0x0FU

/* NuBus Card Categories */
#define CatBoard                    0x0001U
#define CatTest                     0x0002U
#define CatDisplay                  0x0003U
#define CatNetwork                  0x0004U
#define CatIntSerial                0x0008U

/* Standard Types */
#define TypBoard                    0x0000U
#define TypVideo                    0x0001U
#define TypEtherNet                 0x0001U

/* Software Interfaces */
#define DrSWBoard                   0x0000U
#define DrSWApple                   0x0001U

/* Hardware Devices */
#define DrHWBoard                   0x0000U
#define DrHWTFB                     0x0001U
#define DrHWViSC                    0x0020U /* Quadra 800 Onboard Video (DAFB) */

/* sResource IDs */
#define sRsrcType                   0x01U
#define sRsrcName                   0x02U
#define sRsrcIcon                   0x03U
#define sRsrcDrvrDir                0x04U
#define sRsrcLoadRec                0x05U
#define sRsrcBootRec                0x06U
#define sRsrcFlags                  0x07U
#define sRsrcHWDevId                0x08U
#define MinorBaseOS                 0x0AU
#define MinorLength                 0x0BU
#define EndOfList                   0xFFU

/* NuBus Declaration ROM Format Block */
typedef struct __attribute__((packed)) {
    int32_t     directoryOffset;    /* 24-bit signed offset to sResource directory */
    uint32_t    length;             /* Size of declaration ROM image */
    uint32_t    crc;                /* ROM CRC checksum */
    uint8_t     revisionLevel;      /* Format block revision (0x01) */
    uint8_t     format;             /* Format version (0x01) */
    uint32_t    testPattern;        /* Must equal 0x5A932BC7 */
    uint8_t     reserved;           /* Reserved (0x00) */
    uint8_t     byteLanes;          /* 0x0F for 32-bit width */
} NuBusFormatBlock;

/* 32-bit sResource Entry */
typedef struct __attribute__((packed)) {
    uint8_t     id;                 /* 8-bit sResource entry ID */
    uint8_t     offset_h;           /* High byte of 24-bit offset */
    uint8_t     offset_m;           /* Mid byte */
    uint8_t     offset_l;           /* Low byte */
} sResourceEntry;

/* sRsrcType Data Structure */
typedef struct __attribute__((packed)) {
    uint16_t    category;
    uint16_t    cType;
    uint16_t    drSW;
    uint16_t    drHW;
} sRsrcTypeRecord;

#ifdef __cplusplus
}
#endif

#endif /* DECLROM_H */
