/**
 * @file traps.h
 * @brief Macintosh Quadra 800 ROM A-Trap Equates and Tables
 *
 * Decompiled and reconstructed from QUADRA800.ROM. Trap names: see trap_table.c.
 */

#ifndef MAC_TRAPS_H
#define MAC_TRAPS_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

#define ROM_UNIMPLEMENTED_TRAP  0x40809AE6U

/* Core OS Trap Equates ($A000 - $A0FF) */
#define TRAP_Open                    0xA000U /* ROM: 0x4080B766 */
#define TRAP_Close                   0xA001U /* ROM: 0x4080BAAA */
#define TRAP_Read                    0xA002U /* ROM: 0x4080BB1C */
#define TRAP_Write                   0xA003U /* ROM: 0x4080BB9A */
#define TRAP_Control                 0xA004U /* ROM: 0x4080BBAE */
#define TRAP_Status                  0xA005U /* ROM: 0x4080BBBE */
#define TRAP_KillIO                  0xA006U /* ROM: 0x4080BBE4 */
#define TRAP_GetVolInfo              0xA007U /* ROM: 0x408100F4 */
#define TRAP_Create                  0xA008U /* ROM: 0x40810AEA */
#define TRAP_Delete                  0xA009U /* ROM: 0x40810D14 */
#define TRAP_OpenRF                  0xA00AU /* ROM: 0x408108EE */
#define TRAP_Rename                  0xA00BU /* ROM: 0x40810D94 */
#define TRAP_GetFileInfo             0xA00CU /* ROM: 0x40811400 */
#define TRAP_SetFileInfo             0xA00DU /* ROM: 0x408111F4 */
#define TRAP_UnmountVol              0xA00EU /* ROM: 0x4080FE18 */
#define TRAP_MountVol                0xA00FU /* ROM: 0x4080F60E */
#define TRAP_Allocate                0xA010U /* ROM: 0x40811DCA */
#define TRAP_GetEOF                  0xA011U /* ROM: 0x40811C74 */
#define TRAP_SetEOF                  0xA012U /* ROM: 0x40811DFA */
#define TRAP_FlushVol                0xA013U /* ROM: 0x4080FEBE */
#define TRAP_GetVol                  0xA014U /* ROM: 0x40810358 */
#define TRAP_SetVol                  0xA015U /* ROM: 0x408103A0 */
#define TRAP_FInitQueue              0xA016U /* ROM: 0x4080F166 */
#define TRAP_Eject                   0xA017U /* ROM: 0x4080FD3E */
#define TRAP_GetFPos                 0xA018U /* ROM: 0x40811834 */
#define TRAP_InitZone                0xA019U /* ROM: 0x4080CF08 */
#define TRAP_GetZone                 0xA01AU /* ROM: 0x4080D068 */
#define TRAP_SetZone                 0xA01BU /* ROM: 0x4080D07A */
#define TRAP_FreeMem                 0xA01CU /* ROM: 0x4080D174 */
#define TRAP_MaxMem                  0xA01DU /* ROM: 0x4080D1D2 */
#define TRAP_NewPtr                  0xA01EU /* ROM: 0x4080D360 */
#define TRAP_DisposPtr               0xA01FU /* ROM: 0x4080D3A0 */
#define TRAP_SetPtrSize              0xA020U /* ROM: 0x4080D3E4 */
#define TRAP_GetPtrSize              0xA021U /* ROM: 0x4080D3CC */
#define TRAP_NewHandle               0xA022U /* ROM: 0x4080D448 */
#define TRAP_DisposHandle            0xA023U /* ROM: 0x4080D484 */
#define TRAP_SetHandleSize           0xA024U /* ROM: 0x4080D4D0 */
#define TRAP_GetHandleSize           0xA025U /* ROM: 0x4080D4B4 */
#define TRAP_HandleZone              0xA026U /* ROM: 0x4080D4F2 */
#define TRAP_ReallocHandle           0xA027U /* ROM: 0x4080D59A */
#define TRAP_RecoverHandle           0xA028U /* ROM: 0x4080D504 */
#define TRAP_HLock                   0xA029U /* ROM: 0x4080D628 */
#define TRAP_HUnlock                 0xA02AU /* ROM: 0x4080D64E */
#define TRAP_EmptyHandle             0xA02BU /* ROM: 0x4080D574 */
#define TRAP_InitApplZone            0xA02CU /* ROM: 0x4080CD52 */
#define TRAP_SetApplLimit            0xA02DU /* ROM: 0x4080D254 */
#define TRAP_BlockMove               0xA02EU /* ROM: 0x40884400 */
#define TRAP_PostEvent               0xA02FU /* ROM: 0x4080B3A0 */
#define TRAP_OSEventAvail            0xA030U /* ROM: 0x4080B418 */
#define TRAP_GetOSEvent              0xA031U /* ROM: 0x4080B4A2 */
#define TRAP_FlushEvents             0xA032U /* ROM: 0x4080B4CC */
#define TRAP_VInstall                0xA033U /* ROM: 0x4080A230 */
#define TRAP_VRemove                 0xA034U /* ROM: 0x4080A280 */
#define TRAP_OffLine                 0xA035U /* ROM: 0x4080FC98 */
#define TRAP_MoreMasters             0xA036U /* ROM: 0x4080D734 */
#define TRAP_READPARAM               0xA037U /* ROM: 0x4080C042 (Apple ROM map name) */
#define TRAP_WriteParam              0xA038U /* ROM: 0x4080C05C */
#define TRAP_ReadDateTime            0xA039U /* ROM: 0x4080C07C */
#define TRAP_SetDateTime             0xA03AU /* ROM: 0x4080C086 */
#define TRAP_Delay                   0xA03BU /* ROM: 0x4080C08E */
#define TRAP_CmpString               0xA03CU /* ROM: 0x4080C11E */
#define TRAP_DrvrInstall             0xA03DU /* ROM: 0x4080BC38 */
#define TRAP_DrvrRemove              0xA03EU /* ROM: 0x4080BC96 */
#define TRAP_InitUtil                0xA03FU /* ROM: 0x4080C5CC */
#define TRAP_ResrvMem                0xA040U /* ROM: 0x4080D18A */
#define TRAP_SetFilLock              0xA041U /* ROM: 0x408111A8 */
#define TRAP_RstFilLock              0xA042U /* ROM: 0x408111B2 */
#define TRAP_SetFilType              0xA043U /* ROM: 0x40811170 */
#define TRAP_SetFPos                 0xA044U /* ROM: 0x40811838 */
#define TRAP_FlushFile               0xA045U /* ROM: 0x40811A78 */
#define TRAP_GetTrapAddress          0xA046U /* ROM: 0x40809A66 */
#define TRAP_SetTrapAddress          0xA047U /* ROM: 0x40809A6E */
#define TRAP_PtrZone                 0xA048U /* ROM: 0x4080D3FC */
#define TRAP_HPurge                  0xA049U /* ROM: 0x4080D670 */
#define TRAP_HNoPurge                0xA04AU /* ROM: 0x4080D68E */
#define TRAP_SetGrowZone             0xA04BU /* ROM: 0x4080D23E */
#define TRAP_CompactMem              0xA04CU /* ROM: 0x4080D0A8 */
#define TRAP_PurgeMem                0xA04DU /* ROM: 0x4080D11A */
#define TRAP_AddDrive                0xA04EU /* ROM: 0x4080BCC6 */
#define TRAP_RDrvrInstall            0xA04FU /* ROM: 0x4080BFDC */
#define TRAP_RelString               0xA050U /* ROM: 0x4080C134 */
#define TRAP_ReadXPRam               0xA051U /* ROM: 0x4080B186 */
#define TRAP_WriteXPRam              0xA052U /* ROM: 0x4080B190 */
#define TRAP_CLKNOMEM                0xA053U /* ROM: 0x408B39B6 (Apple ROM map name) */
#define TRAP_UprString               0xA054U /* ROM: 0x4080C108 */
#define TRAP_StripAddress            0xA055U /* ROM: 0x4080D764 */
#define TRAP_LwrString               0xA056U /* ROM: 0x4080C0A0 */
#define TRAP_SetApplBase             0xA057U /* ROM: 0x4080CCFE */
#define TRAP_InsTime                 0xA058U /* ROM: 0x4080AEEC */
#define TRAP_RmvTime                 0xA059U /* ROM: 0x4080AE90 */
#define TRAP_PrimeTime               0xA05AU /* ROM: 0x4080AF1A */
#define TRAP_PowerOff                0xA05BU /* ROM: 0x40809E16 */
#define TRAP_MemoryDispatch          0xA05CU /* ROM: 0x40805538 */
#define TRAP_SwapMMUMode             0xA05DU /* ROM: 0x40803F30 */
#define TRAP_NMInstall               0xA05EU /* ROM: 0x4081D720 */
#define TRAP_NMRemove                0xA05FU /* ROM: 0x4081D730 */
#define TRAP_FSDispatch              0xA060U /* ROM: 0x4080EF40 */
#define TRAP_MaxBlock                0xA061U /* ROM: 0x4080D08C */
#define TRAP_PurgeSpace              0xA062U /* ROM: 0x4080D158 */
#define TRAP_MaxApplZone             0xA063U /* ROM: 0x4080D2DC */
#define TRAP_MoveHHi                 0xA064U /* ROM: 0x4080D772 */
#define TRAP_StackSpace              0xA065U /* ROM: 0x4080D2BE */
#define TRAP_NewEmptyHandle          0xA066U /* ROM: 0x4080D422 */
#define TRAP_HSetRBit                0xA067U /* ROM: 0x4080D6B6 */
#define TRAP_HClrRBit                0xA068U /* ROM: 0x4080D6D4 */
#define TRAP_HGetState               0xA069U /* ROM: 0x4080D6F2 */
#define TRAP_HSetState               0xA06AU /* ROM: 0x4080D718 */
#define TRAP_USTSTRT1                0xA06BU /* ROM: 0x408B93D0 (Apple ROM map name) */
#define TRAP_InitFS                  0xA06CU /* ROM: 0x4080F368 */
#define TRAP_InitEvents              0xA06DU /* ROM: 0x408022E0 */
#define TRAP_SlotManager             0xA06EU /* ROM: 0x40806E16 */
#define TRAP_SlotVInstall            0xA06FU /* ROM: 0x4080A312 */
#define TRAP_SlotVRemove             0xA070U /* ROM: 0x4080A318 */
#define TRAP_AttachVBL               0xA071U /* ROM: 0x4080A328 */
#define TRAP_DoVBLTask               0xA072U /* ROM: 0x4080A332 */
#define TRAP_OSTrap_A073             0xA073U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_CACHETRAP               0xA074U /* ROM: 0x40809840 (Apple ROM map name) */
#define TRAP_SIntInstall             0xA075U /* ROM: 0x40806E56 */
#define TRAP_SIntRemove              0xA076U /* ROM: 0x40806E7A */
#define TRAP_CountADBs               0xA077U /* ROM: 0x4080A360 */
#define TRAP_GetIndADB               0xA078U /* ROM: 0x4080A37A */
#define TRAP_GetADBInfo              0xA079U /* ROM: 0x4080A3A6 */
#define TRAP_SetADBInfo              0xA07AU /* ROM: 0x4080A3AC */
#define TRAP_ADBReInit               0xA07BU /* ROM: 0x4080A752 */
#define TRAP_ADBOp                   0xA07CU /* ROM: 0x4080A3DC */
#define TRAP_GetDefaultStartup       0xA07DU /* ROM: 0x40801390 */
#define TRAP_SetDefaultStartup       0xA07EU /* ROM: 0x408013A0 */
#define TRAP_InternalWait            0xA07FU /* ROM: 0x40801400 */
#define TRAP_GetVideoDefault         0xA080U /* ROM: 0x408013E0 */
#define TRAP_SetVideoDefault         0xA081U /* ROM: 0x408013F0 */
#define TRAP_DTInstall               0xA082U /* ROM: 0x4080A1D0 */
#define TRAP_SetOSDefault            0xA083U /* ROM: 0x408013C0 */
#define TRAP_GetOSDefault            0xA084U /* ROM: 0x408013B0 */
#define TRAP_PMgrOp                  0xA085U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_IOPInfoAccess           0xA086U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_IOPMsgRequest           0xA087U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_IOPMoveData             0xA088U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_SCSIAtomic              0xA089U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_Sleep                   0xA08AU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_CommToolboxDispatch     0xA08BU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A08C             0xA08CU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DebugUtil               0xA08DU /* ROM: 0x4080A0F0 */
#define TRAP_OSTrap_A08E             0xA08EU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DeferUserFn             0xA08FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_SysEnvirons             0xA090U /* ROM: 0x4080C750 */
#define TRAP_Translate24To32         0xA091U /* ROM: 0x4082F090 */
#define TRAP_EgretDispatch           0xA092U /* ROM: 0x40814800 */
#define TRAP_Microseconds            0xA093U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ServerDispatch          0xA094U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A095             0xA095U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A096             0xA096U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_PRIVTRAP040             0xA097U /* ROM: 0x40895850 (Apple ROM map name) */
#define TRAP_HWPriv                  0xA098U /* ROM: 0x40805448 */
#define TRAP_OSTrap_A099             0xA099U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A09A             0xA09AU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A09B             0xA09BU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A09C             0xA09CU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A09D             0xA09DU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_PowerMgrDispatch        0xA09EU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_PowerDispatch           0xA09FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A0A0             0xA0A0U /* RAM: 0x0086EE0E (installed during boot) */
#define TRAP_OSTrap_A0A1             0xA0A1U /* RAM: 0x0086EED0 (installed during boot) */
#define TRAP_OSTrap_A0A2             0xA0A2U /* RAM: 0x0086EFA6 (installed during boot) */
#define TRAP_OSTrap_A0A3             0xA0A3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_HeapDispatch            0xA0A4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A0A5             0xA0A5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_VRMGRSTDENTRY           0xA0A6U /* ROM: 0x4081B70E (Apple ROM map name) */
#define TRAP_VRMGRSTDEXIT            0xA0A7U /* ROM: 0x4081B7CA (Apple ROM map name) */
#define TRAP_OSTrap_A0A8             0xA0A8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A0A9             0xA0A9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A0AA             0xA0AAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OSTrap_A0AB             0xA0ABU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_FSMDispatch             0xA0ACU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_Gestalt                 0xA0ADU /* ROM: 0x40816500 */
#define TRAP_VADBProc                0xA0AEU /* ROM: 0x4080A776 */
#define TRAP_VMTCHECK                0xA0AFU /* ROM: 0x4080F9AE (Apple ROM map name) */
#define TRAP_VCHECKREMOUNT           0xA0B0U /* ROM: 0x4080F824 (Apple ROM map name) */
#define TRAP_VDTRMV2                 0xA0B1U /* ROM: 0x4081005C (Apple ROM map name) */
#define TRAP_VFINDDRIVE              0xA0B2U /* ROM: 0x4080FC72 (Apple ROM map name) */
#define TRAP_VFCLOSE                 0xA0B3U /* ROM: 0x40811AA8 (Apple ROM map name) */
#define TRAP_VFLUSHMDB               0xA0B4U /* ROM: 0x4080F53A (Apple ROM map name) */
#define TRAP_VGODRIVER               0xA0B5U /* ROM: 0x4080B656 (Apple ROM map name) */
#define TRAP_VWAITUNTIL              0xA0B6U /* ROM: 0x4080BACC (Apple ROM map name) */
#define TRAP_VSYNCWAIT               0xA0B7U /* ROM: 0x4080BB8C (Apple ROM map name) */
#define TRAP_SNDAPPDEAD              0xA0B8U /* ROM: 0x40842D10 (Apple ROM map name) */
#define TRAP_VDISPTCH                0xA0B9U /* ROM: 0x4080A1EE (Apple ROM map name) */
#define TRAP_VIAZINIT                0xA0BAU /* ROM: 0x4080CDE4 (Apple ROM map name) */
#define TRAP_VIAZPOSTINIT            0xA0BBU /* ROM: 0x4080CEFE (Apple ROM map name) */
#define TRAP_VLAUNCHINIT             0xA0BCU /* ROM: 0x4080BF8E (Apple ROM map name) */
#define TRAP_OSTrap_A0BD             0xA0BDU /* ROM: 0x40885030 */
#define TRAP_SYSUTIL                 0xA0BEU /* ROM: 0x4080C040 (Apple ROM map name) */
#define TRAP_VLG2PHYS                0xA0BFU /* ROM: 0x40811F14 (Apple ROM map name) */
#define TRAP_VFLUSHCACHE             0xA0C0U /* ROM: 0x40814140 (Apple ROM map name) */
#define TRAP_VGETBLOCK               0xA0C1U /* ROM: 0x4081422A (Apple ROM map name) */
#define TRAP_VMARKBLOCK              0xA0C2U /* ROM: 0x4081446C (Apple ROM map name) */
#define TRAP_VRELBLOCK               0xA0C3U /* ROM: 0x40814482 (Apple ROM map name) */
#define TRAP_VTRASHBLOCKS            0xA0C4U /* ROM: 0x4081455A (Apple ROM map name) */
#define TRAP_VTRASHVBLKS             0xA0C5U /* ROM: 0x408144D4 (Apple ROM map name) */
#define TRAP_VCACHEWRIP              0xA0C6U /* ROM: 0x408145CE (Apple ROM map name) */
#define TRAP_VCACHERDIP              0xA0C7U /* ROM: 0x408145A2 (Apple ROM map name) */
#define TRAP_VBASICIO                0xA0C8U /* ROM: 0x4081468C (Apple ROM map name) */
#define TRAP_VRDBLOCKS               0xA0C9U /* ROM: 0x40814706 (Apple ROM map name) */
#define TRAP_VWRBLOCKS               0xA0CAU /* ROM: 0x40814754 (Apple ROM map name) */
#define TRAP_VSETUPTAGS              0xA0CBU /* ROM: 0x40814766 (Apple ROM map name) */
#define TRAP_VBTCLOSE                0xA0CCU /* ROM: 0x40813056 (Apple ROM map name) */
#define TRAP_VBTDELETE               0xA0CDU /* ROM: 0x40813096 (Apple ROM map name) */
#define TRAP_VBTFLUSH                0xA0CEU /* ROM: 0x40813248 (Apple ROM map name) */
#define TRAP_VBTGETRECORD            0xA0CFU /* ROM: 0x408132AC (Apple ROM map name) */
#define TRAP_VBTINSERT               0xA0D0U /* ROM: 0x40813364 (Apple ROM map name) */
#define TRAP_VBTOPEN                 0xA0D1U /* ROM: 0x40813604 (Apple ROM map name) */
#define TRAP_VBTSEARCH               0xA0D2U /* ROM: 0x408136BC (Apple ROM map name) */
#define TRAP_VBTUPDATE               0xA0D3U /* ROM: 0x40813746 (Apple ROM map name) */
#define TRAP_VGETNODE                0xA0D4U /* ROM: 0x40813E7E (Apple ROM map name) */
#define TRAP_VRELNODE                0xA0D5U /* ROM: 0x4081404A (Apple ROM map name) */
#define TRAP_VALLOCNODE              0xA0D6U /* ROM: 0x408137B6 (Apple ROM map name) */
#define TRAP_VFREENODE               0xA0D7U /* ROM: 0x4081393A (Apple ROM map name) */
#define TRAP_VEXTBTFILE              0xA0D8U /* ROM: 0x4081384C (Apple ROM map name) */
#define TRAP_VDEALLOCFILE            0xA0D9U /* ROM: 0x408123E6 (Apple ROM map name) */
#define TRAP_VEXTENDFILE             0xA0DAU /* ROM: 0x408124BA (Apple ROM map name) */
#define TRAP_VTRUNCATEFILE           0xA0DBU /* ROM: 0x408126F6 (Apple ROM map name) */
#define TRAP_VCMSETUP                0xA0DCU /* ROM: 0x40812F0C (Apple ROM map name) */
#define TRAP_PPC                     0xA0DDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_VDTRMV1                 0xA0DEU /* ROM: 0x4080FF24 (Apple ROM map name) */
#define TRAP_VBLKALLOC               0xA0DFU /* ROM: 0x40812116 (Apple ROM map name) */
#define TRAP_VBLKDEALLOC             0xA0E0U /* ROM: 0x40812270 (Apple ROM map name) */
#define TRAP_VFILEOPEN               0xA0E1U /* ROM: 0x408108FE (Apple ROM map name) */
#define TRAP_VPERMSSNCHK             0xA0E2U /* ROM: 0x40810A7A (Apple ROM map name) */
#define TRAP_VFNDFILNAME             0xA0E3U /* ROM: 0x408112B4 (Apple ROM map name) */
#define TRAP_VRFNCALL                0xA0E4U /* ROM: 0x40811C8C (Apple ROM map name) */
#define TRAP_VADJEOF                 0xA0E5U /* ROM: 0x40811E6A (Apple ROM map name) */
#define TRAP_VPIXEL2CHAR             0xA0E6U /* ROM: 0x40822696 (Apple ROM map name) */
#define TRAP_VCHAR2PIXEL             0xA0E7U /* ROM: 0x4082389C (Apple ROM map name) */
#define TRAP_OSTrap_A0E8             0xA0E8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_VFILECLOSE              0xA0E9U /* ROM: 0x40811A88 (Apple ROM map name) */
#define TRAP_VFILEREAD               0xA0EAU /* ROM: 0x40811842 (Apple ROM map name) */
#define TRAP_VFILEWRITE              0xA0EBU /* ROM: 0x4081195E (Apple ROM map name) */
#define TRAP_OSTrap_A0EC             0xA0ECU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_VUPDALTMDB              0xA0EDU /* ROM: 0x408139EC (Apple ROM map name) */
#define TRAP_VCKEXTFS                0xA0EEU /* ROM: 0x4080FF00 (Apple ROM map name) */
#define TRAP_VDTRMV3                 0xA0EFU /* ROM: 0x4080FF10 (Apple ROM map name) */
#define TRAP_VBMCHK                  0xA0F0U /* ROM: 0x4080FB8A (Apple ROM map name) */
#define TRAP_VTSTMOD                 0xA0F1U /* ROM: 0x40811CD6 (Apple ROM map name) */
#define TRAP_VLOCCREC                0xA0F2U /* ROM: 0x40813004 (Apple ROM map name) */
#define TRAP_VTREESEARCH             0xA0F3U /* ROM: 0x40813C60 (Apple ROM map name) */
#define TRAP_VMAPFBLOCK              0xA0F4U /* ROM: 0x40812674 (Apple ROM map name) */
#define TRAP_VXFSEARCH               0xA0F5U /* ROM: 0x40812864 (Apple ROM map name) */
#define TRAP_VREADBM                 0xA0F6U /* ROM: 0x4081233E (Apple ROM map name) */
#define TRAP_DOEJECT                 0xA0F7U /* ROM: 0x4080F334 (Apple ROM map name) */
#define TRAP_VSEGSTACK               0xA0F8U /* ROM: 0x4080BF06 (Apple ROM map name) */
#define TRAP_VSUPERLOAD              0xA0F9U /* ROM: 0x4081AC9C (Apple ROM map name) */
#define TRAP_VCMPFRM                 0xA0FAU /* ROM: 0x4081B196 (Apple ROM map name) */
#define TRAP_VNEWMAP                 0xA0FBU /* ROM: 0x4081ADD4 (Apple ROM map name) */
#define TRAP_VCHECKLOAD              0xA0FCU /* ROM: 0x4081B8FA (Apple ROM map name) */
#define TRAP_XTRIMMEASURE            0xA0FDU /* ROM: 0x408237B0 (Apple ROM map name) */
#define TRAP_TEFindWord              0xA0FEU /* ROM: 0x40823F3A */
#define TRAP_TEFindLine              0xA0FFU /* ROM: 0x4082414A */

/* Core Toolbox Trap Equates ($A800 - $ABFF) */
#define TRAP_SoundDispatch           0xA800U /* ROM: 0x40843E9E */
#define TRAP_SndDisposeChannel       0xA801U /* ROM: 0x40843070 */
#define TRAP_SndAddModifier          0xA802U /* ROM: 0x408434D0 */
#define TRAP_SndDoCommand            0xA803U /* ROM: 0x40842D90 */
#define TRAP_SndDoImmediate          0xA804U /* ROM: 0x40842E40 */
#define TRAP_SndPlay                 0xA805U /* ROM: 0x40843100 */
#define TRAP_SndControl              0xA806U /* ROM: 0x408433B0 */
#define TRAP_SndNewChannel           0xA807U /* ROM: 0x40842EB0 */
#define TRAP_InitProcMenu            0xA808U /* ROM: 0x40816D20 */
#define TRAP_GetCVariant             0xA809U /* ROM: 0x40815E84 */
#define TRAP_GetWVariant             0xA80AU /* ROM: 0x40818DD8 */
#define TRAP_PopUpMenuSelect         0xA80BU /* ROM: 0x408172D2 */
#define TRAP_RGetResource            0xA80CU /* ROM: 0x4081C07E */
#define TRAP_Count1Resources         0xA80DU /* ROM: 0x4081B428 */
#define TRAP_Get1IxResource          0xA80EU /* ROM: 0x4081B452 */
#define TRAP_Get1IxType              0xA80FU /* ROM: 0x4081B538 */
#define TRAP_Unique1ID               0xA810U /* ROM: 0x4081B55E */
#define TRAP_TESelView               0xA811U /* ROM: 0x408251FE */
#define TRAP_TEPinScroll             0xA812U /* ROM: 0x40825176 */
#define TRAP_TEAutoView              0xA813U /* ROM: 0x40825288 */
#define TRAP_SetFractEnable          0xA814U /* ROM: 0x408275EA */
#define TRAP_SCSIDispatch            0xA815U /* ROM: 0x40807460 */
#define TRAP_Pack8                   0xA816U /* ROM: 0x408262B6 */
#define TRAP_CopyMask                0xA817U /* ROM: 0x40835912 */
#define TRAP_FixATan2                0xA818U /* ROM: 0x4081C5BC */
#define TRAP_XMunger                 0xA819U /* ROM: 0x4081C0DE */
#define TRAP_HOpenResFile            0xA81AU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_HCreateResFile          0xA81BU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_Count1Types             0xA81CU /* ROM: 0x4081B4EE */
#define TRAP_InvalMenuBar            0xA81DU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_A81E        0xA81EU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_Get1Resource            0xA81FU /* ROM: 0x4081B59C */
#define TRAP_Get1NamedResource       0xA820U /* ROM: 0x4081B5E0 */
#define TRAP_MaxSizeRsrc             0xA821U /* ROM: 0x4081C05E */
#define TRAP_ResourceDispatch        0xA822U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_AliasDispatch           0xA823U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_HFSUtilDispatch         0xA824U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_MenuDispatch            0xA825U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_InsMenuItem             0xA826U /* ROM: 0x40817DC6 */
#define TRAP_HideDItem               0xA827U /* ROM: 0x4081A184 */
#define TRAP_ShowDItem               0xA828U /* ROM: 0x4081A1E2 */
#define TRAP_ToolboxTrap_A829        0xA829U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ComponentDispatch       0xA82AU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_Pack9                   0xA82BU /* ROM: 0x408262B8 */
#define TRAP_Pack10                  0xA82CU /* ROM: 0x408262BA */
#define TRAP_Pack11                  0xA82DU /* ROM: 0x408262BC */
#define TRAP_Pack12                  0xA82EU /* ROM: 0x408262BE */
#define TRAP_Pack13                  0xA82FU /* ROM: 0x408262C0 */
#define TRAP_Pack14                  0xA830U /* ROM: 0x408262C2 */
#define TRAP_Pack15                  0xA831U /* ROM: 0x408262C4 */
#define TRAP_ToolboxTrap_A832        0xA832U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ScrnBitMap              0xA833U /* ROM: 0x4082EA80 */
#define TRAP_SetFScaleDisable        0xA834U /* ROM: 0x408275DC */
#define TRAP_FontMetrics             0xA835U /* ROM: 0x408275F2 */
#define TRAP_GetMaskTable            0xA836U /* ROM: 0x4082EBF0 */
#define TRAP_MeasureText             0xA837U /* ROM: 0x40829320 */
#define TRAP_CalcMask                0xA838U /* ROM: 0x408359C8 */
#define TRAP_SeedFill                0xA839U /* ROM: 0x408359C0 */
#define TRAP_ZoomWindow              0xA83AU /* ROM: 0x40818F36 */
#define TRAP_TrackBox                0xA83BU /* ROM: 0x40818FA4 */
#define TRAP_TEGetOffset             0xA83CU /* ROM: 0x4082594E */
#define TRAP_TEDispatch              0xA83DU /* ROM: 0x40823C00 */
#define TRAP_TEStyleNew              0xA83EU /* ROM: 0x4082241C */
#define TRAP_Long2Fix                0xA83FU /* ROM: 0x4081C72E */
#define TRAP_Fix2Long                0xA840U /* ROM: 0x4081C70E */
#define TRAP_Fix2Frac                0xA841U /* ROM: 0x4081C732 */
#define TRAP_Frac2Fix                0xA842U /* ROM: 0x4081C712 */
#define TRAP_Fix2X                   0xA843U /* ROM: 0x4081C67A */
#define TRAP_X2Fix                   0xA844U /* ROM: 0x4081C6AC */
#define TRAP_Frac2X                  0xA845U /* ROM: 0x4081C680 */
#define TRAP_X2Frac                  0xA846U /* ROM: 0x4081C6B2 */
#define TRAP_FracCos                 0xA847U /* ROM: 0x4081C50E */
#define TRAP_FracSin                 0xA848U /* ROM: 0x4081C516 */
#define TRAP_FracSqrt                0xA849U /* ROM: 0x4081C456 */
#define TRAP_FracMul                 0xA84AU /* ROM: 0x4081C30C */
#define TRAP_FracDiv                 0xA84BU /* ROM: 0x4081C400 */
#define TRAP_ToolboxTrap_A84C        0xA84CU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_FixDiv                  0xA84DU /* ROM: 0x4081C406 */
#define TRAP_GetItemCmd              0xA84EU /* ROM: 0x408179AC */
#define TRAP_SetItemCmd              0xA84FU /* ROM: 0x408179B0 */
#define TRAP_InitCursor              0xA850U /* ROM: 0x408280A0 */
#define TRAP_SetCursor               0xA851U /* ROM: 0x408280C0 */
#define TRAP_HideCursor              0xA852U /* ROM: 0x408280F0 */
#define TRAP_ShowCursor              0xA853U /* ROM: 0x40828100 */
#define TRAP_FontDispatch            0xA854U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ShieldCursor            0xA855U /* ROM: 0x40828110 */
#define TRAP_ObscureCursor           0xA856U /* ROM: 0x40828140 */
#define TRAP_ToolboxTrap_A857        0xA857U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_BitAnd                  0xA858U /* ROM: 0x4082EAC0 */
#define TRAP_BitXOr                  0xA859U /* ROM: 0x4082EAC8 */
#define TRAP_BitNot                  0xA85AU /* ROM: 0x4082EAB0 */
#define TRAP_BitOr                   0xA85BU /* ROM: 0x4082EAD2 */
#define TRAP_BitShift                0xA85CU /* ROM: 0x4082EADA */
#define TRAP_BitTst                  0xA85DU /* ROM: 0x4082EAF0 */
#define TRAP_BitSet                  0xA85EU /* ROM: 0x4082EAFE */
#define TRAP_BitClr                  0xA85FU /* ROM: 0x4082EB08 */
#define TRAP_WaitNextEvent           0xA860U /* ROM: 0x40815CD0 */
#define TRAP_Random                  0xA861U /* ROM: 0x4082EB20 */
#define TRAP_ForeColor               0xA862U /* ROM: 0x4082EB80 */
#define TRAP_BackColor               0xA863U /* ROM: 0x4082EBCC */
#define TRAP_ColorBit                0xA864U /* ROM: 0x4082EBDC */
#define TRAP_GetPixel                0xA865U /* ROM: 0x4082EF7C */
#define TRAP_StuffHex                0xA866U /* ROM: 0x4082F0D0 */
#define TRAP_LongMul                 0xA867U /* ROM: 0x4081C2EE */
#define TRAP_FixMul                  0xA868U /* ROM: 0x4081C312 */
#define TRAP_FixRatio                0xA869U /* ROM: 0x4081C490 */
#define TRAP_HiWord                  0xA86AU /* ROM: 0x4081C4EA */
#define TRAP_LoWord                  0xA86BU /* ROM: 0x4081C4E2 */
#define TRAP_FixRound                0xA86CU /* ROM: 0x4081C4F4 */
#define TRAP_InitPort                0xA86DU /* ROM: 0x408316EE */
#define TRAP_InitGraf                0xA86EU /* ROM: 0x40831530 */
#define TRAP_OpenPort                0xA86FU /* ROM: 0x408316E0 */
#define TRAP_LocalToGlobal           0xA870U /* ROM: 0x40831800 */
#define TRAP_GlobalToLocal           0xA871U /* ROM: 0x40831808 */
#define TRAP_GrafDevice              0xA872U /* ROM: 0x40831880 */
#define TRAP_SetPort                 0xA873U /* ROM: 0x40831860 */
#define TRAP_GetPort                 0xA874U /* ROM: 0x40831868 */
#define TRAP_SetPBits                0xA875U /* ROM: 0x40831890 */
#define TRAP_PortSize                0xA876U /* ROM: 0x408318E0 */
#define TRAP_MovePortTo              0xA877U /* ROM: 0x40831900 */
#define TRAP_SetOrigin               0xA878U /* ROM: 0x40831930 */
#define TRAP_SetClip                 0xA879U /* ROM: 0x40831990 */
#define TRAP_GetClip                 0xA87AU /* ROM: 0x4083199C */
#define TRAP_ClipRect                0xA87BU /* ROM: 0x40831970 */
#define TRAP_BackPat                 0xA87CU /* ROM: 0x408318AE */
#define TRAP_ClosePort               0xA87DU /* ROM: 0x408301E0 */
#define TRAP_AddPt                   0xA87EU /* ROM: 0x4083183A */
#define TRAP_SubPt                   0xA87FU /* ROM: 0x40831842 */
#define TRAP_SetPt                   0xA880U /* ROM: 0x408319B0 */
#define TRAP_EqualPt                 0xA881U /* ROM: 0x408319C0 */
#define TRAP_StdText                 0xA882U /* ROM: 0x40828E40 */
#define TRAP_DrawChar                0xA883U /* ROM: 0x4082913C */
#define TRAP_DrawString              0xA884U /* ROM: 0x4082919C */
#define TRAP_DrawText                0xA885U /* ROM: 0x408291AE */
#define TRAP_TextWidth               0xA886U /* ROM: 0x408291E0 */
#define TRAP_TextFont                0xA887U /* ROM: 0x40829170 */
#define TRAP_TextFace                0xA888U /* ROM: 0x40829130 */
#define TRAP_TextMode                0xA889U /* ROM: 0x40829174 */
#define TRAP_TextSize                0xA88AU /* ROM: 0x40829178 */
#define TRAP_GetFontInfo             0xA88BU /* ROM: 0x40829420 */
#define TRAP_StringWidth             0xA88CU /* ROM: 0x408291D0 */
#define TRAP_CharWidth               0xA88DU /* ROM: 0x4082914A */
#define TRAP_SpaceExtra              0xA88EU /* ROM: 0x40829190 */
#define TRAP_OSDispatch              0xA88FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_StdLine                 0xA890U /* ROM: 0x40829580 */
#define TRAP_LineTo                  0xA891U /* ROM: 0x40829670 */
#define TRAP_Line                    0xA892U /* ROM: 0x40829690 */
#define TRAP_MoveTo                  0xA893U /* ROM: 0x408296B0 */
#define TRAP_Move                    0xA894U /* ROM: 0x408296D0 */
#define TRAP_ShutDown                0xA895U /* ROM: 0x4080ED7E */
#define TRAP_HidePen                 0xA896U /* ROM: 0x40829780 */
#define TRAP_ShowPen                 0xA897U /* ROM: 0x40829784 */
#define TRAP_GetPenState             0xA898U /* ROM: 0x40829790 */
#define TRAP_SetPenState             0xA899U /* ROM: 0x408297CC */
#define TRAP_GetPen                  0xA89AU /* ROM: 0x40829810 */
#define TRAP_PenSize                 0xA89BU /* ROM: 0x40829820 */
#define TRAP_PenMode                 0xA89CU /* ROM: 0x40829830 */
#define TRAP_PenPat                  0xA89DU /* ROM: 0x40829840 */
#define TRAP_PenNormal               0xA89EU /* ROM: 0x40829868 */
#define TRAP_Unimplemented           0xA89FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_StdRect                 0xA8A0U /* ROM: 0x4082C150 */
#define TRAP_FrameRect               0xA8A1U /* ROM: 0x4082C488 */
#define TRAP_PaintRect               0xA8A2U /* ROM: 0x4082C48C */
#define TRAP_EraseRect               0xA8A3U /* ROM: 0x4082C490 */
#define TRAP_InverRect               0xA8A4U /* ROM: 0x4082C494 */
#define TRAP_FillRect                0xA8A5U /* ROM: 0x4082C470 */
#define TRAP_EqualRect               0xA8A6U /* ROM: 0x4082C630 */
#define TRAP_SetRect                 0xA8A7U /* ROM: 0x4082C620 */
#define TRAP_OffsetRect              0xA8A8U /* ROM: 0x4082C670 */
#define TRAP_InsetRect               0xA8A9U /* ROM: 0x4082C690 */
#define TRAP_SectRect                0xA8AAU /* ROM: 0x4082C6B0 */
#define TRAP_UnionRect               0xA8ABU /* ROM: 0x4082C750 */
#define TRAP_Pt2Rect                 0xA8ACU /* ROM: 0x4082C78E */
#define TRAP_PtInRect                0xA8ADU /* ROM: 0x4082C7D0 */
#define TRAP_EmptyRect               0xA8AEU /* ROM: 0x4082C650 */
#define TRAP_StdRRect                0xA8AFU /* ROM: 0x40834570 */
#define TRAP_FrameRoundRect          0xA8B0U /* ROM: 0x40834630 */
#define TRAP_PaintRoundRect          0xA8B1U /* ROM: 0x40834634 */
#define TRAP_EraseRoundRect          0xA8B2U /* ROM: 0x40834638 */
#define TRAP_InverRoundRect          0xA8B3U /* ROM: 0x4083463C */
#define TRAP_FillRoundRect           0xA8B4U /* ROM: 0x40834640 */
#define TRAP_ScriptUtil              0xA8B5U /* ROM: 0x4081E318 */
#define TRAP_StdOval                 0xA8B6U /* ROM: 0x4083BA20 */
#define TRAP_FrameOval               0xA8B7U /* ROM: 0x4083BAE0 */
#define TRAP_PaintOval               0xA8B8U /* ROM: 0x4083BAE4 */
#define TRAP_EraseOval               0xA8B9U /* ROM: 0x4083BAE8 */
#define TRAP_InvertOval              0xA8BAU /* ROM: 0x4083BAEC */
#define TRAP_FillOval                0xA8BBU /* ROM: 0x4083BAF0 */
#define TRAP_SlopeFromAngle          0xA8BCU /* ROM: 0x4083CE5E */
#define TRAP_StdArc                  0xA8BDU /* ROM: 0x4083BB30 */
#define TRAP_FrameArc                0xA8BEU /* ROM: 0x4083BBE0 */
#define TRAP_PaintArc                0xA8BFU /* ROM: 0x4083BBE4 */
#define TRAP_EraseArc                0xA8C0U /* ROM: 0x4083BBE8 */
#define TRAP_InvertArc               0xA8C1U /* ROM: 0x4083BBEC */
#define TRAP_FillArc                 0xA8C2U /* ROM: 0x4083BBF0 */
#define TRAP_PtToAngle               0xA8C3U /* ROM: 0x4083CF90 */
#define TRAP_AngleFromSlope          0xA8C4U /* ROM: 0x4083CE20 */
#define TRAP_StdPoly                 0xA8C5U /* ROM: 0x40833B30 */
#define TRAP_FramePoly               0xA8C6U /* ROM: 0x40833BF0 */
#define TRAP_PaintPoly               0xA8C7U /* ROM: 0x40833BF4 */
#define TRAP_ErasePoly               0xA8C8U /* ROM: 0x40833BF8 */
#define TRAP_InvertPoly              0xA8C9U /* ROM: 0x40833BFC */
#define TRAP_FillPoly                0xA8CAU /* ROM: 0x40833C00 */
#define TRAP_OpenPoly                0xA8CBU /* ROM: 0x40833C40 */
#define TRAP_ClosePgon               0xA8CCU /* ROM: 0x40833C80 */
#define TRAP_KillPoly                0xA8CDU /* ROM: 0x40833CF0 */
#define TRAP_OffsetPoly              0xA8CEU /* ROM: 0x40833D00 */
#define TRAP_PackBits                0xA8CFU /* ROM: 0x40835C60 */
#define TRAP_UnpackBits              0xA8D0U /* ROM: 0x40835D14 */
#define TRAP_StdRgn                  0xA8D1U /* ROM: 0x40835E70 */
#define TRAP_FrameRgn                0xA8D2U /* ROM: 0x40835F10 */
#define TRAP_PaintRgn                0xA8D3U /* ROM: 0x40835F14 */
#define TRAP_EraseRgn                0xA8D4U /* ROM: 0x40835F18 */
#define TRAP_InverRgn                0xA8D5U /* ROM: 0x40835F1C */
#define TRAP_FillRgn                 0xA8D6U /* ROM: 0x40835F20 */
#define TRAP_BitMapRgn               0xA8D7U /* ROM: 0x408366F0 */
#define TRAP_NewRgn                  0xA8D8U /* ROM: 0x40836040 */
#define TRAP_DisposRgn               0xA8D9U /* ROM: 0x40836060 */
#define TRAP_OpenRgn                 0xA8DAU /* ROM: 0x40836070 */
#define TRAP_CloseRgn                0xA8DBU /* ROM: 0x408360A0 */
#define TRAP_CopyRgn                 0xA8DCU /* ROM: 0x40836110 */
#define TRAP_SetEmptyRgn             0xA8DDU /* ROM: 0x40836160 */
#define TRAP_SetRecRgn               0xA8DEU /* ROM: 0x40836170 */
#define TRAP_RectRgn                 0xA8DFU /* ROM: 0x408361D0 */
#define TRAP_OffsetRgn               0xA8E0U /* ROM: 0x408361E0 */
#define TRAP_InsetRgn                0xA8E1U /* ROM: 0x40836220 */
#define TRAP_EmptyRgn                0xA8E2U /* ROM: 0x408362D0 */
#define TRAP_EqualRgn                0xA8E3U /* ROM: 0x408362F0 */
#define TRAP_SectRgn                 0xA8E4U /* ROM: 0x40836330 */
#define TRAP_UnionRgn                0xA8E5U /* ROM: 0x40836334 */
#define TRAP_DiffRgn                 0xA8E6U /* ROM: 0x40836338 */
#define TRAP_XOrRgn                  0xA8E7U /* ROM: 0x4083633C */
#define TRAP_PtInRgn                 0xA8E8U /* ROM: 0x40836430 */
#define TRAP_RectInRgn               0xA8E9U /* ROM: 0x40836490 */
#define TRAP_SetStdProcs             0xA8EAU /* ROM: 0x408317A0 */
#define TRAP_StdBits                 0xA8EBU /* ROM: 0x40834E90 */
#define TRAP_CopyBits                0xA8ECU /* ROM: 0x408356C0 */
#define TRAP_StdTxMeas               0xA8EDU /* ROM: 0x40829250 */
#define TRAP_StdGetPic               0xA8EEU /* ROM: 0x40831A90 */
#define TRAP_ScrollRect              0xA8EFU /* ROM: 0x40835B20 */
#define TRAP_StdPutPic               0xA8F0U /* ROM: 0x40831AB0 */
#define TRAP_StdComment              0xA8F1U /* ROM: 0x40831A30 */
#define TRAP_PicComment              0xA8F2U /* ROM: 0x40831B80 */
#define TRAP_OpenPicture             0xA8F3U /* ROM: 0x40831BB0 */
#define TRAP_ClosePicture            0xA8F4U /* ROM: 0x40831D20 */
#define TRAP_KillPicture             0xA8F5U /* ROM: 0x40831D90 */
#define TRAP_DrawPicture             0xA8F6U /* ROM: 0x40831DA0 */
#define TRAP_Layout                  0xA8F7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ScalePt                 0xA8F8U /* ROM: 0x408339A0 */
#define TRAP_MapPt                   0xA8F9U /* ROM: 0x40833A00 */
#define TRAP_MapRect                 0xA8FAU /* ROM: 0x40833AC0 */
#define TRAP_MapRgn                  0xA8FBU /* ROM: 0x40836630 */
#define TRAP_MapPoly                 0xA8FCU /* ROM: 0x40833D20 */
#define TRAP_PrGlue                  0xA8FDU /* ROM: 0x40825F40 */
#define TRAP_InitFonts               0xA8FEU /* ROM: 0x408263B0 */
#define TRAP_GetFName                0xA8FFU /* ROM: 0x40827498 */
#define TRAP_GetFNum                 0xA900U /* ROM: 0x40827570 */
#define TRAP_FMSwapFont              0xA901U /* ROM: 0x40826514 */
#define TRAP_RealFont                0xA902U /* ROM: 0x40827506 */
#define TRAP_SetFontLock             0xA903U /* ROM: 0x408275B4 */
#define TRAP_DrawGrowIcon            0xA904U /* ROM: 0x408196CC */
#define TRAP_DragGrayRgn             0xA905U /* ROM: 0x40819298 */
#define TRAP_NewString               0xA906U /* ROM: 0x40818230 */
#define TRAP_SetString               0xA907U /* ROM: 0x40818248 */
#define TRAP_ShowHide                0xA908U /* ROM: 0x4081857C */
#define TRAP_CalcVis                 0xA909U /* ROM: 0x408182BC */
#define TRAP_CalcVBehind             0xA90AU /* ROM: 0x4081831A */
#define TRAP_ClipAbove               0xA90BU /* ROM: 0x4081835E */
#define TRAP_PaintOne                0xA90CU /* ROM: 0x40818382 */
#define TRAP_PaintBehind             0xA90DU /* ROM: 0x4081848A */
#define TRAP_SaveOld                 0xA90EU /* ROM: 0x408184EE */
#define TRAP_DrawNew                 0xA90FU /* ROM: 0x4081851C */
#define TRAP_GetWMgrPort             0xA910U /* ROM: 0x408185C8 */
#define TRAP_CheckUpDate             0xA911U /* ROM: 0x408185DC */
#define TRAP_InitWindows             0xA912U /* ROM: 0x4081867A */
#define TRAP_NewWindow               0xA913U /* ROM: 0x40818870 */
#define TRAP_DisposWindow            0xA914U /* ROM: 0x40818AE2 */
#define TRAP_ShowWindow              0xA915U /* ROM: 0x40818AF0 */
#define TRAP_HideWindow              0xA916U /* ROM: 0x40818B18 */
#define TRAP_GetWRefCon              0xA917U /* ROM: 0x40818B42 */
#define TRAP_SetWRefCon              0xA918U /* ROM: 0x40818B50 */
#define TRAP_GetWTitle               0xA919U /* ROM: 0x40818B6C */
#define TRAP_SetWTitle               0xA91AU /* ROM: 0x40818B84 */
#define TRAP_MoveWindow              0xA91BU /* ROM: 0x40818C5E */
#define TRAP_HiliteWindow            0xA91CU /* ROM: 0x40818E9E */
#define TRAP_SizeWindow              0xA91DU /* ROM: 0x40818EDE */
#define TRAP_TrackGoAway             0xA91EU /* ROM: 0x40818F9C */
#define TRAP_SelectWindow            0xA91FU /* ROM: 0x40819014 */
#define TRAP_BringToFront            0xA920U /* ROM: 0x40819048 */
#define TRAP_SendBehind              0xA921U /* ROM: 0x408190EA */
#define TRAP_BeginUpDate             0xA922U /* ROM: 0x40819140 */
#define TRAP_EndUpDate               0xA923U /* ROM: 0x40819184 */
#define TRAP_FrontWindow             0xA924U /* ROM: 0x408191AC */
#define TRAP_DragWindow              0xA925U /* ROM: 0x408191D6 */
#define TRAP_DragTheRgn              0xA926U /* ROM: 0x408192A4 */
#define TRAP_InvalRgn                0xA927U /* ROM: 0x408194B2 */
#define TRAP_InvalRect               0xA928U /* ROM: 0x408194F8 */
#define TRAP_ValidRgn                0xA929U /* ROM: 0x40819516 */
#define TRAP_ValidRect               0xA92AU /* ROM: 0x4081951A */
#define TRAP_GrowWindow              0xA92BU /* ROM: 0x4081951E */
#define TRAP_FindWindow              0xA92CU /* ROM: 0x40819648 */
#define TRAP_CloseWindow             0xA92DU /* ROM: 0x408189D6 */
#define TRAP_SetWindowPic            0xA92EU /* ROM: 0x40818B60 */
#define TRAP_GetWindowPic            0xA92FU /* ROM: 0x40818B66 */
#define TRAP_InitMenus               0xA930U /* ROM: 0x40816D50 */
#define TRAP_NewMenu                 0xA931U /* ROM: 0x40817D6C */
#define TRAP_DisposMenu              0xA932U /* ROM: 0x40817876 */
#define TRAP_AppendMenu              0xA933U /* ROM: 0x40817DBE */
#define TRAP_ClearMenuBar            0xA934U /* ROM: 0x40816EA0 */
#define TRAP_InsertMenu              0xA935U /* ROM: 0x40816EC6 */
#define TRAP_DeleteMenu              0xA936U /* ROM: 0x40816FC2 */
#define TRAP_DrawMenuBar             0xA937U /* ROM: 0x408170B6 */
#define TRAP_HiliteMenu              0xA938U /* ROM: 0x408170D4 */
#define TRAP_EnableItem              0xA939U /* ROM: 0x40817126 */
#define TRAP_DisableItem             0xA93AU /* ROM: 0x40817148 */
#define TRAP_GetMenuBar              0xA93BU /* ROM: 0x40817818 */
#define TRAP_SetMenuBar              0xA93CU /* ROM: 0x40817842 */
#define TRAP_MenuSelect              0xA93DU /* ROM: 0x4081718E */
#define TRAP_MenuKey                 0xA93EU /* ROM: 0x40817B8C */
#define TRAP_GetItmIcon              0xA93FU /* ROM: 0x408179A4 */
#define TRAP_SetItmIcon              0xA940U /* ROM: 0x408179A8 */
#define TRAP_GetItmStyle             0xA941U /* ROM: 0x408179B4 */
#define TRAP_SetItmStyle             0xA942U /* ROM: 0x408179B8 */
#define TRAP_GetItmMark              0xA943U /* ROM: 0x408179BC */
#define TRAP_SetItmMark              0xA944U /* ROM: 0x408179C0 */
#define TRAP_CheckItem               0xA945U /* ROM: 0x408179C4 */
#define TRAP_GetItem                 0xA946U /* ROM: 0x40817CDC */
#define TRAP_SetItem                 0xA947U /* ROM: 0x40817FC6 */
#define TRAP_CalcMenuSize            0xA948U /* ROM: 0x40817D32 */
#define TRAP_GetMHandle              0xA949U /* ROM: 0x40817F58 */
#define TRAP_SetMFlash               0xA94AU /* ROM: 0x4081800C */
#define TRAP_PlotIcon                0xA94BU /* ROM: 0x40818198 */
#define TRAP_FlashMenuBar            0xA94CU /* ROM: 0x40817898 */
#define TRAP_AddResMenu              0xA94DU /* ROM: 0x40818016 */
#define TRAP_PinRect                 0xA94EU /* ROM: 0x4082E200 */
#define TRAP_DeltaPoint              0xA94FU /* ROM: 0x40818C02 */
#define TRAP_CountMItems             0xA950U /* ROM: 0x4081817C */
#define TRAP_InsertResMenu           0xA951U /* ROM: 0x4081801E */
#define TRAP_DelMenuItem             0xA952U /* ROM: 0x40817F80 */
#define TRAP_UpdtControl             0xA953U /* ROM: 0x40816324 */
#define TRAP_NewControl              0xA954U /* ROM: 0x40815D50 */
#define TRAP_DisposControl           0xA955U /* ROM: 0x40815EF8 */
#define TRAP_KillControls            0xA956U /* ROM: 0x40815F78 */
#define TRAP_ShowControl             0xA957U /* ROM: 0x40815F9A */
#define TRAP_HideControl             0xA958U /* ROM: 0x40815FB8 */
#define TRAP_MoveControl             0xA959U /* ROM: 0x40815FCC */
#define TRAP_GetCRefCon              0xA95AU /* ROM: 0x4081600A */
#define TRAP_SetCRefCon              0xA95BU /* ROM: 0x40816018 */
#define TRAP_SizeControl             0xA95CU /* ROM: 0x40816030 */
#define TRAP_HiliteControl           0xA95DU /* ROM: 0x40816058 */
#define TRAP_GetCTitle               0xA95EU /* ROM: 0x40816084 */
#define TRAP_SetCTitle               0xA95FU /* ROM: 0x4081609C */
#define TRAP_GetCtlValue             0xA960U /* ROM: 0x408160DE */
#define TRAP_GetMinCtl               0xA961U /* ROM: 0x408160EC */
#define TRAP_GetMaxCtl               0xA962U /* ROM: 0x408160F0 */
#define TRAP_SetCtlValue             0xA963U /* ROM: 0x408160F4 */
#define TRAP_SetMinCtl               0xA964U /* ROM: 0x40816136 */
#define TRAP_SetMaxCtl               0xA965U /* ROM: 0x4081613A */
#define TRAP_TestControl             0xA966U /* ROM: 0x4081613E */
#define TRAP_DragControl             0xA967U /* ROM: 0x4081616C */
#define TRAP_TrackControl            0xA968U /* ROM: 0x40816236 */
#define TRAP_DrawControls            0xA969U /* ROM: 0x40816334 */
#define TRAP_GetCtlAction            0xA96AU /* ROM: 0x40816028 */
#define TRAP_SetCtlAction            0xA96BU /* ROM: 0x4081602C */
#define TRAP_FindControl             0xA96CU /* ROM: 0x408163BC */
#define TRAP_Draw1Control            0xA96DU /* ROM: 0x40815F8A */
#define TRAP_Dequeue                 0xA96EU /* ROM: 0x40809956 */
#define TRAP_Enqueue                 0xA96FU /* ROM: 0x40809930 */
#define TRAP_GetNextEvent            0xA970U /* ROM: 0x40815AA0 */
#define TRAP_EventAvail              0xA971U /* ROM: 0x40815A9C */
#define TRAP_GetMouse                0xA972U /* ROM: 0x40815A40 */
#define TRAP_StillDown               0xA973U /* ROM: 0x40815A56 */
#define TRAP_Button                  0xA974U /* ROM: 0x408159EC */
#define TRAP_TickCount               0xA975U /* ROM: 0x408159FE */
#define TRAP_GetKeys                 0xA976U /* ROM: 0x408159D0 */
#define TRAP_WaitMouseUp             0xA977U /* ROM: 0x40815A7E */
#define TRAP_UpdtDialog              0xA978U /* ROM: 0x40819DA6 */
#define TRAP_COULDDIALOG             0xA979U /* ROM: 0x40819EC6 (Apple ROM map name) */
#define TRAP_FREEDIALOG              0xA97AU /* ROM: 0x40819F80 (Apple ROM map name) */
#define TRAP_InitDialogs             0xA97BU /* ROM: 0x408198CA */
#define TRAP_GetNewDialog            0xA97CU /* ROM: 0x40819AF8 */
#define TRAP_NewDialog               0xA97DU /* ROM: 0x40819B94 */
#define TRAP_SelIText                0xA97EU /* ROM: 0x4081A128 */
#define TRAP_IsDialogEvent           0xA97FU /* ROM: 0x40819C66 */
#define TRAP_DialogSelect            0xA980U /* ROM: 0x40819CA2 */
#define TRAP_DrawDialog              0xA981U /* ROM: 0x40819D8E */
#define TRAP_CloseDialog             0xA982U /* ROM: 0x40819DCE */
#define TRAP_DisposDialog            0xA983U /* ROM: 0x40819E52 */
#define TRAP_FindDItem               0xA984U /* ROM: 0x4081A256 */
#define TRAP_Alert                   0xA985U /* ROM: 0x4081998C */
#define TRAP_StopAlert               0xA986U /* ROM: 0x40819980 */
#define TRAP_NoteAlert               0xA987U /* ROM: 0x40819984 */
#define TRAP_CautionAlert            0xA988U /* ROM: 0x40819988 */
#define TRAP_COULDALERT              0xA989U /* ROM: 0x40819ED4 (Apple ROM map name) */
#define TRAP_FREEALERT               0xA98AU /* ROM: 0x40819F8E (Apple ROM map name) */
#define TRAP_ParamText               0xA98BU /* ROM: 0x40819FF2 */
#define TRAP_ErrorSound              0xA98CU /* ROM: 0x4081A016 */
#define TRAP_GetDItem                0xA98DU /* ROM: 0x4081A01E */
#define TRAP_SetDItem                0xA98EU /* ROM: 0x4081A064 */
#define TRAP_SetIText                0xA98FU /* ROM: 0x4081A0BC */
#define TRAP_GetIText                0xA990U /* ROM: 0x4081A09C */
#define TRAP_ModalDialog             0xA991U /* ROM: 0x40819CE4 */
#define TRAP_DetachResource          0xA992U /* ROM: 0x4081BC06 */
#define TRAP_SetResPurge             0xA993U /* ROM: 0x4081BCBE */
#define TRAP_CurResFile              0xA994U /* ROM: 0x4081BCE8 */
#define TRAP_InitResources           0xA995U /* ROM: 0x4081AA32 */
#define TRAP_RsrcZoneInit            0xA996U /* ROM: 0x4081AEC0 */
#define TRAP_OpenResFile             0xA997U /* ROM: 0x4081AF9E */
#define TRAP_UseResFile              0xA998U /* ROM: 0x4081AFE2 */
#define TRAP_UpdateResFile           0xA999U /* ROM: 0x4081B0AE */
#define TRAP_CloseResFile            0xA99AU /* ROM: 0x4081B388 */
#define TRAP_SetResLoad              0xA99BU /* ROM: 0x4081BCDE */
#define TRAP_CountResources          0xA99CU /* ROM: 0x4081B42C */
#define TRAP_GetIndResource          0xA99DU /* ROM: 0x4081B456 */
#define TRAP_CountTypes              0xA99EU /* ROM: 0x4081B4F2 */
#define TRAP_GetIndType              0xA99FU /* ROM: 0x4081B53C */
#define TRAP_GetResource             0xA9A0U /* ROM: 0x4081B5A0 */
#define TRAP_GetNamedResource        0xA9A1U /* ROM: 0x4081B5E4 */
#define TRAP_LoadResource            0xA9A2U /* ROM: 0x4081BB9E */
#define TRAP_ReleaseResource         0xA9A3U /* ROM: 0x4081BBDC */
#define TRAP_HomeResFile             0xA9A4U /* ROM: 0x4081BC94 */
#define TRAP_SizeRsrc                0xA9A5U /* ROM: 0x4081C03C */
#define TRAP_GetResAttrs             0xA9A6U /* ROM: 0x4081BD12 */
#define TRAP_SetResAttrs             0xA9A7U /* ROM: 0x4081BD26 */
#define TRAP_GetResInfo              0xA9A8U /* ROM: 0x4081BD58 */
#define TRAP_SetResInfo              0xA9A9U /* ROM: 0x4081BD9E */
#define TRAP_ChangedResource         0xA9AAU /* ROM: 0x4081BC1E */
#define TRAP_AddResource             0xA9ABU /* ROM: 0x4081BDE8 */
#define TRAP_AddReference            0xA9ACU /* ROM: 0x4081BCF8 */
#define TRAP_RmveResource            0xA9ADU /* ROM: 0x4081BEC0 */
#define TRAP_RmveReference           0xA9AEU /* ROM: 0x4081BD08 */
#define TRAP_ResError                0xA9AFU /* ROM: 0x4081BCF0 */
#define TRAP_WriteResource           0xA9B0U /* ROM: 0x4081BC5A */
#define TRAP_CreateResFile           0xA9B1U /* ROM: 0x4081AF54 */
#define TRAP_SystemEvent             0xA9B2U /* ROM: 0x4081C750 */
#define TRAP_SystemClick             0xA9B3U /* ROM: 0x4081C82C */
#define TRAP_SystemTask              0xA9B4U /* ROM: 0x4081C900 */
#define TRAP_SystemMenu              0xA9B5U /* ROM: 0x4081C980 */
#define TRAP_OpenDeskAcc             0xA9B6U /* ROM: 0x4081C9F6 */
#define TRAP_CloseDeskAcc            0xA9B7U /* ROM: 0x4081CA44 */
#define TRAP_GetPattern              0xA9B8U /* ROM: 0x40821C50 */
#define TRAP_GetCursor               0xA9B9U /* ROM: 0x40821C6A */
#define TRAP_GetString               0xA9BAU /* ROM: 0x40821C78 */
#define TRAP_GetIcon                 0xA9BBU /* ROM: 0x40821C80 */
#define TRAP_GetPicture              0xA9BCU /* ROM: 0x40821C88 */
#define TRAP_GetNewWindow            0xA9BDU /* ROM: 0x40821C9C */
#define TRAP_GetNewControl           0xA9BEU /* ROM: 0x40821D44 */
#define TRAP_GetRMenu                0xA9BFU /* ROM: 0x40821DC6 */
#define TRAP_GetNewMBar              0xA9C0U /* ROM: 0x40821E80 */
#define TRAP_UniqueID                0xA9C1U /* ROM: 0x4081B562 */
#define TRAP_SysEdit                 0xA9C2U /* ROM: 0x4081C9C8 */
#define TRAP_KeyTrans                0xA9C3U /* ROM: 0x4080AD7A */
#define TRAP_OpenRFPerm              0xA9C4U /* ROM: 0x4081AFCE */
#define TRAP_RsrcMapEntry            0xA9C5U /* ROM: 0x4081C072 */
#define TRAP_Secs2Date               0xA9C6U /* ROM: 0x408262D0 */
#define TRAP_Date2Secs               0xA9C7U /* ROM: 0x40826348 */
#define TRAP_SysBeep                 0xA9C8U /* ROM: 0x40806FC0 */
#define TRAP_SysError                0xA9C9U /* ROM: 0x40802720 */
#define TRAP_PutIcon                 0xA9CAU /* ROM: 0x40802524 */
#define TRAP_TEGetText               0xA9CBU /* ROM: 0x40822038 */
#define TRAP_TEInit                  0xA9CCU /* ROM: 0x40821F92 */
#define TRAP_TEDispose               0xA9CDU /* ROM: 0x40822044 */
#define TRAP_TextBox                 0xA9CEU /* ROM: 0x408220A2 */
#define TRAP_TESetText               0xA9CFU /* ROM: 0x40822182 */
#define TRAP_TECalText               0xA9D0U /* ROM: 0x4082229A */
#define TRAP_TESetSelect             0xA9D1U /* ROM: 0x408222FE */
#define TRAP_TENew                   0xA9D2U /* ROM: 0x40822344 */
#define TRAP_TEUpdate                0xA9D3U /* ROM: 0x40822536 */
#define TRAP_TEClick                 0xA9D4U /* ROM: 0x40822564 */
#define TRAP_TECopy                  0xA9D5U /* ROM: 0x40823C18 */
#define TRAP_TECut                   0xA9D6U /* ROM: 0x40823CF0 */
#define TRAP_TEDelete                0xA9D7U /* ROM: 0x40823D00 */
#define TRAP_TEActivate              0xA9D8U /* ROM: 0x4082471E */
#define TRAP_TEDeactivate            0xA9D9U /* ROM: 0x40824740 */
#define TRAP_TEIdle                  0xA9DAU /* ROM: 0x40824758 */
#define TRAP_TEPaste                 0xA9DBU /* ROM: 0x40824796 */
#define TRAP_TEKey                   0xA9DCU /* ROM: 0x40824B42 */
#define TRAP_TEScroll                0xA9DDU /* ROM: 0x40825120 */
#define TRAP_TEInsert                0xA9DEU /* ROM: 0x40824B14 */
#define TRAP_TESetJust               0xA9DFU /* ROM: 0x408250F8 */
#define TRAP_Munger                  0xA9E0U /* ROM: 0x4081C0B0 */
#define TRAP_HandToHand              0xA9E1U /* ROM: 0x4081C214 */
#define TRAP_PtrToXHand              0xA9E2U /* ROM: 0x4081C23C */
#define TRAP_PtrToHand               0xA9E3U /* ROM: 0x4081C244 */
#define TRAP_HandAndHand             0xA9E4U /* ROM: 0x4081C25E */
#define TRAP_InitPack                0xA9E5U /* ROM: 0x408261C0 */
#define TRAP_InitAllPacks            0xA9E6U /* ROM: 0x408261E2 */
#define TRAP_Pack0                   0xA9E7U /* ROM: 0x408262A6 */
#define TRAP_Pack1                   0xA9E8U /* ROM: 0x408262A8 */
#define TRAP_Pack2                   0xA9E9U /* ROM: 0x408262AA */
#define TRAP_Pack3                   0xA9EAU /* ROM: 0x408262AC */
#define TRAP_FP68K                   0xA9EBU /* ROM: 0x40826206 */
#define TRAP_Elems68K                0xA9ECU /* ROM: 0x40826228 */
#define TRAP_Pack6                   0xA9EDU /* ROM: 0x408262B2 */
#define TRAP_DECSTR68K               0xA9EEU /* ROM: 0x408262B4 */
#define TRAP_PtrAndHand              0xA9EFU /* ROM: 0x4081C282 */
#define TRAP_LoadSeg                 0xA9F0U /* ROM: 0x4080BCE0 */
#define TRAP_UnLoadSeg               0xA9F1U /* ROM: 0x4080BD72 */
#define TRAP_Launch                  0xA9F2U /* ROM: 0x4080BE0A */
#define TRAP_Chain                   0xA9F3U /* ROM: 0x4080BE04 */
#define TRAP_ExitToShell             0xA9F4U /* ROM: 0x4080BF54 */
#define TRAP_GetAppParms             0xA9F5U /* ROM: 0x4080BFC0 */
#define TRAP_GetResFileAttrs         0xA9F6U /* ROM: 0x4081AFEC */
#define TRAP_SetResFileAttrs         0xA9F7U /* ROM: 0x4081AFF8 */
#define TRAP_MethodDispatch          0xA9F8U /* ROM: 0x4081C292 */
#define TRAP_InfoScrap               0xA9F9U /* ROM: 0x40825D50 */
#define TRAP_UnlodeScrap             0xA9FAU /* ROM: 0x40825DCA */
#define TRAP_LodeScrap               0xA9FBU /* ROM: 0x40825E00 */
#define TRAP_ZeroScrap               0xA9FCU /* ROM: 0x40825E34 */
#define TRAP_GetScrap                0xA9FDU /* ROM: 0x40825E80 */
#define TRAP_PutScrap                0xA9FEU /* ROM: 0x40825EF0 */
#define TRAP_Debugger                0xA9FFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OpenCPort               0xAA00U /* ROM: 0x408300F0 */
#define TRAP_InitCPort               0xAA01U /* ROM: 0x40830126 */
#define TRAP_CloseCPort              0xAA02U /* ROM: 0x408301E0 */
#define TRAP_NewPixMap               0xAA03U /* ROM: 0x408302F0 */
#define TRAP_DisposPixMap            0xAA04U /* ROM: 0x40830300 */
#define TRAP_CopyPixMap              0xAA05U /* ROM: 0x40830360 */
#define TRAP_SetPortPix              0xAA06U /* ROM: 0x40830260 */
#define TRAP_NewPixPat               0xAA07U /* ROM: 0x40830690 */
#define TRAP_DisposPixPat            0xAA08U /* ROM: 0x40830700 */
#define TRAP_CopyPixPat              0xAA09U /* ROM: 0x40830840 */
#define TRAP_PenPixPat               0xAA0AU /* ROM: 0x408307C0 */
#define TRAP_BackPixPat              0xAA0BU /* ROM: 0x408307CC */
#define TRAP_GetPixPat               0xAA0CU /* ROM: 0x40830580 */
#define TRAP_MakeRGBPat              0xAA0DU /* ROM: 0x40831120 */
#define TRAP_FillCRect               0xAA0EU /* ROM: 0x4082C474 */
#define TRAP_FillCOval               0xAA0FU /* ROM: 0x4083BAF4 */
#define TRAP_FillCRoundRect          0xAA10U /* ROM: 0x40834644 */
#define TRAP_FillCArc                0xAA11U /* ROM: 0x4083BBF4 */
#define TRAP_FillCRgn                0xAA12U /* ROM: 0x40835F24 */
#define TRAP_FillCPoly               0xAA13U /* ROM: 0x40833C04 */
#define TRAP_RGBForeColor            0xAA14U /* ROM: 0x4083C550 */
#define TRAP_RGBBackColor            0xAA15U /* ROM: 0x4083C5E6 */
#define TRAP_SetCPixel               0xAA16U /* ROM: 0x408304E0 */
#define TRAP_GetCPixel               0xAA17U /* ROM: 0x4082EF70 */
#define TRAP_GetCTable               0xAA18U /* ROM: 0x4083CD86 */
#define TRAP_GetForeColor            0xAA19U /* ROM: 0x4083C5F0 */
#define TRAP_GetBackColor            0xAA1AU /* ROM: 0x4083C632 */
#define TRAP_GetCCursor              0xAA1BU /* ROM: 0x40830570 */
#define TRAP_SetCCursor              0xAA1CU /* ROM: 0x408280E0 */
#define TRAP_AllocCursor             0xAA1DU /* ROM: 0x40828090 */
#define TRAP_GetCIcon                0xAA1EU /* ROM: 0x408311E0 */
#define TRAP_PlotCIcon               0xAA1FU /* ROM: 0x408312A0 */
#define TRAP_OpenCPicture            0xAA20U /* ROM: 0x40831BA0 */
#define TRAP_OpColor                 0xAA21U /* ROM: 0x40830550 */
#define TRAP_HiliteColor             0xAA22U /* ROM: 0x40830540 */
#define TRAP_CharExtra               0xAA23U /* ROM: 0x40829530 */
#define TRAP_DisposCTable            0xAA24U /* ROM: 0x40830290 */
#define TRAP_DisposCIcon             0xAA25U /* ROM: 0x40831400 */
#define TRAP_DisposCCursor           0xAA26U /* ROM: 0x40830700 */
#define TRAP_GetMaxDevice            0xAA27U /* ROM: 0x40828020 */
#define TRAP_GetCTSeed               0xAA28U /* ROM: 0x408302A0 */
#define TRAP_GetDeviceList           0xAA29U /* ROM: 0x40827FB0 */
#define TRAP_GetMainDevice           0xAA2AU /* ROM: 0x40827FC0 */
#define TRAP_GetNextDevice           0xAA2BU /* ROM: 0x40827FD0 */
#define TRAP_TestDeviceAttribute     0xAA2CU /* ROM: 0x40827FE0 */
#define TRAP_SetDeviceAttribute      0xAA2DU /* ROM: 0x40828000 */
#define TRAP_InitGDevice             0xAA2EU /* ROM: 0x408278D0 */
#define TRAP_NewGDevice              0xAA2FU /* ROM: 0x408277E0 */
#define TRAP_DisposGDevice           0xAA30U /* ROM: 0x40827880 */
#define TRAP_SetGDevice              0xAA31U /* ROM: 0x40827FA0 */
#define TRAP_GetGDevice              0xAA32U /* ROM: 0x40827F90 */
#define TRAP_Color2Index             0xAA33U /* ROM: 0x4083C3C8 */
#define TRAP_Index2Color             0xAA34U /* ROM: 0x4083C460 */
#define TRAP_InvertColor             0xAA35U /* ROM: 0x4083C500 */
#define TRAP_RealColor               0xAA36U /* ROM: 0x4083C640 */
#define TRAP_GetSubTable             0xAA37U /* ROM: 0x4083CB20 */
#define TRAP_UpdatePixMap            0xAA38U /* ROM: 0x4083BDB0 */
#define TRAP_MakeITable              0xAA39U /* ROM: 0x4083BDC0 */
#define TRAP_AddSearch               0xAA3AU /* ROM: 0x4083CA50 */
#define TRAP_AddComp                 0xAA3BU /* ROM: 0x4083CA8A */
#define TRAP_SetClientID             0xAA3CU /* ROM: 0x4083CA40 */
#define TRAP_ProtectEntry            0xAA3DU /* ROM: 0x4083C9C0 */
#define TRAP_ReserveEntry            0xAA3EU /* ROM: 0x4083CA12 */
#define TRAP_SetEntries              0xAA3FU /* ROM: 0x4083C6C0 */
#define TRAP_QDError                 0xAA40U /* ROM: 0x4083CBE0 */
#define TRAP_SetWinColor             0xAA41U /* ROM: 0x40819736 */
#define TRAP_GetAuxWin               0xAA42U /* ROM: 0x4081987E */
#define TRAP_SetCtlColor             0xAA43U /* ROM: 0x4081978E */
#define TRAP_GetAuxCtl               0xAA44U /* ROM: 0x40819884 */
#define TRAP_NewCWindow              0xAA45U /* ROM: 0x4081885E */
#define TRAP_GetNewCWindow           0xAA46U /* ROM: 0x40821C90 */
#define TRAP_SetDeskCPat             0xAA47U /* ROM: 0x408196EA */
#define TRAP_GetCWMgrPort            0xAA48U /* ROM: 0x408185D2 */
#define TRAP_SaveEntries             0xAA49U /* ROM: 0x4083C920 */
#define TRAP_RestoreEntries          0xAA4AU /* ROM: 0x4083C800 */
#define TRAP_NewCDialog              0xAA4BU /* ROM: 0x40819B90 */
#define TRAP_DelSearch               0xAA4CU /* ROM: 0x4083CAC0 */
#define TRAP_DelComp                 0xAA4DU /* ROM: 0x4083CAF0 */
#define TRAP_SetStdCProcs            0xAA4EU /* ROM: 0x408317E0 */
#define TRAP_CalcCMask               0xAA4FU /* ROM: 0x4083D55A */
#define TRAP_SeedCFill               0xAA50U /* ROM: 0x4083D540 */
#define TRAP_CopyDeepMask            0xAA51U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_HighLevelFSDispatch     0xAA52U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DictionaryDispatch      0xAA53U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_TextServicesDispatch    0xAA54U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA55        0xAA55U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_SpeechRecognitionDispatch 0xAA56U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DockingDispatch         0xAA57U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA58        0xAA58U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_MixedModeDispatch       0xAA59U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_CodeFragmentDispatch    0xAA5AU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA5B        0xAA5BU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_OCEUtils                0xAA5CU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DigitalSignature        0xAA5DU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_TBDispatch              0xAA5EU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA5F        0xAA5FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DelMCEntries            0xAA60U /* ROM: 0x40817032 */
#define TRAP_GetMCInfo               0xAA61U /* ROM: 0x40817832 */
#define TRAP_SetMCInfo               0xAA62U /* ROM: 0x4081785A */
#define TRAP_DispMCInfo              0xAA63U /* ROM: 0x4081788E */
#define TRAP_GetMCEntry              0xAA64U /* ROM: 0x40817B5E */
#define TRAP_SetMCEntries            0xAA65U /* ROM: 0x408179E4 */
#define TRAP_MenuChoice              0xAA66U /* ROM: 0x40817810 */
#define TRAP_ModalDialogMenuSetup    0xAA67U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DialogDispatch          0xAA68U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA69        0xAA69U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA6A        0xAA6AU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA6B        0xAA6BU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA6C        0xAA6CU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA6D        0xAA6DU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA6E        0xAA6EU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA6F        0xAA6FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA70        0xAA70U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA71        0xAA71U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA72        0xAA72U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ControlDispatch         0xAA73U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_AppearanceDispatch      0xAA74U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA75        0xAA75U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA76        0xAA76U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA77        0xAA77U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA78        0xAA78U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA79        0xAA79U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA7A        0xAA7AU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA7B        0xAA7BU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA7C        0xAA7CU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA7D        0xAA7DU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_SysDebugDispatch        0xAA7EU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA7F        0xAA7FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_AVLTreeDispatch         0xAA80U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_FileMappingDispatch     0xAA81U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA82        0xAA82U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA83        0xAA83U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA84        0xAA84U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA85        0xAA85U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA86        0xAA86U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA87        0xAA87U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA88        0xAA88U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA89        0xAA89U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA8A        0xAA8AU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA8B        0xAA8BU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA8C        0xAA8CU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA8D        0xAA8DU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA8E        0xAA8EU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AA8F        0xAA8FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_InitPalettes            0xAA90U /* ROM: 0x4083E1F0 */
#define TRAP_NewPalette              0xAA91U /* ROM: 0x4083DBD0 */
#define TRAP_GetNewPalette           0xAA92U /* ROM: 0x4083DC80 */
#define TRAP_DisposePalette          0xAA93U /* ROM: 0x4083E0E0 */
#define TRAP_ActivatePalette         0xAA94U /* ROM: 0x4083D7B8 */
#define TRAP_SetPalette              0xAA95U /* ROM: 0x4083E6B0 */
#define TRAP_GetPalette              0xAA96U /* ROM: 0x4083E7A0 */
#define TRAP_PmForeColor             0xAA97U /* ROM: 0x4083EA20 */
#define TRAP_PmBackColor             0xAA98U /* ROM: 0x4083EA24 */
#define TRAP_AnimateEntry            0xAA99U /* ROM: 0x4083EA90 */
#define TRAP_AnimatePalette          0xAA9AU /* ROM: 0x4083EBC0 */
#define TRAP_GetEntryColor           0xAA9BU /* ROM: 0x4083ED60 */
#define TRAP_SetEntryColor           0xAA9CU /* ROM: 0x4083EF70 */
#define TRAP_GetEntryUsage           0xAA9DU /* ROM: 0x4083EFC0 */
#define TRAP_SetEntryUsage           0xAA9EU /* ROM: 0x4083F000 */
#define TRAP_CTab2Palette            0xAA9FU /* ROM: 0x4083F0A0 */
#define TRAP_Palette2CTab            0xAAA0U /* ROM: 0x4083F140 */
#define TRAP_CopyPalette             0xAAA1U /* ROM: 0x4083F210 */
#define TRAP_PaletteDispatch         0xAAA2U /* ROM: 0x4083FA36 */
#define TRAP_CodecDispatch           0xAAA3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ALMDispatch             0xAAA4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAA5        0xAAA5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAA6        0xAAA6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAA7        0xAAA7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAA8        0xAAA8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAA9        0xAAA9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAAA        0xAAAAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAAB        0xAAABU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAAC        0xAAACU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAAD        0xAAADU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAAE        0xAAAEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAAF        0xAAAFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB0        0xAAB0U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB1        0xAAB1U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB2        0xAAB2U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB3        0xAAB3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB4        0xAAB4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB5        0xAAB5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB6        0xAAB6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB7        0xAAB7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB8        0xAAB8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAB9        0xAAB9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AABA        0xAABAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AABB        0xAABBU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AABC        0xAABCU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AABD        0xAABDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AABE        0xAABEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AABF        0xAABFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC0        0xAAC0U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC1        0xAAC1U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC2        0xAAC2U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC3        0xAAC3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC4        0xAAC4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC5        0xAAC5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC6        0xAAC6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC7        0xAAC7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC8        0xAAC8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAC9        0xAAC9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AACA        0xAACAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AACB        0xAACBU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AACC        0xAACCU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AACD        0xAACDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AACE        0xAACEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AACF        0xAACFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD0        0xAAD0U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD1        0xAAD1U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD2        0xAAD2U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD3        0xAAD3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD4        0xAAD4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD5        0xAAD5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD6        0xAAD6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD7        0xAAD7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD8        0xAAD8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAD9        0xAAD9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AADA        0xAADAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_CursorDeviceDispatch    0xAADBU /* ROM: 0x408B63D0 */
#define TRAP_ToolboxTrap_AADC        0xAADCU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AADD        0xAADDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AADE        0xAADEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AADF        0xAADFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE0        0xAAE0U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE1        0xAAE1U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE2        0xAAE2U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE3        0xAAE3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE4        0xAAE4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE5        0xAAE5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE6        0xAAE6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE7        0xAAE7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE8        0xAAE8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAE9        0xAAE9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAEA        0xAAEAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAEB        0xAAEBU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAEC        0xAAECU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAED        0xAAEDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAEE        0xAAEEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAEF        0xAAEFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAF0        0xAAF0U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAF1        0xAAF1U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ControlStripDispatch    0xAAF2U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ExpansionManager        0xAAF3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAF4        0xAAF4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAF5        0xAAF5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAF6        0xAAF6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAF7        0xAAF7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAF8        0xAAF8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAF9        0xAAF9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAFA        0xAAFAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAFB        0xAAFBU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAFC        0xAAFCU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAFD        0xAAFDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAFE        0xAAFEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_AAFF        0xAAFFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_BITBLT                  0xAB00U /* ROM: 0x4082C870 (Apple ROM map name) */
#define TRAP_BITSTOMAP               0xAB01U /* ROM: 0x408300D2 (Apple ROM map name) */
#define TRAP_BITSTOPIX               0xAB02U /* ROM: 0x40830390 (Apple ROM map name) */
#define TRAP_JACKSONPOLLOCK          0xAB03U /* ROM: 0x4083143A (Apple ROM map name) */
#define TRAP_COLORMAP                0xAB04U /* ROM: 0x4082EC90 (Apple ROM map name) */
#define TRAP_COPYHANDLE              0xAB05U /* ROM: 0x40830060 (Apple ROM map name) */
#define TRAP_CULLPOINTS              0xAB06U /* ROM: 0x4083BCC0 (Apple ROM map name) */
#define TRAP_DPUTPICBYTE             0xAB07U /* ROM: 0x40832BF0 (Apple ROM map name) */
#define TRAP_DPUTPICOP               0xAB08U /* ROM: 0x40832C90 (Apple ROM map name) */
#define TRAP_DRAWARC                 0xAB09U /* ROM: 0x40834680 (Apple ROM map name) */
#define TRAP_DRAWLINE                0xAB0AU /* ROM: 0x408299A0 (Apple ROM map name) */
#define TRAP_DRAWSLAB                0xAB0BU /* ROM: 0x4082F160 (Apple ROM map name) */
#define TRAP_FASTSLABMODE            0xAB0CU /* ROM: 0x40830040 (Apple ROM map name) */
#define TRAP_GETSEEK                 0xAB0DU /* ROM: 0x4083AF40 (Apple ROM map name) */
#define TRAP_MAKESCALETBL            0xAB0EU /* ROM: 0x40830E50 (Apple ROM map name) */
#define TRAP_CHECKPIC                0xAB0FU /* ROM: 0x40833780 (Apple ROM map name) */
#define TRAP_DOLINE                  0xAB10U /* ROM: 0x408296F0 (Apple ROM map name) */
#define TRAP_OLDPATTONEW             0xAB11U /* ROM: 0x40830890 (Apple ROM map name) */
#define TRAP_PACKRGN                 0xAB12U /* ROM: 0x4083D180 (Apple ROM map name) */
#define TRAP_PATCONVERT              0xAB13U /* ROM: 0x40830C20 (Apple ROM map name) */
#define TRAP_PATDITHER               0xAB14U /* ROM: 0x40830FB0 (Apple ROM map name) */
#define TRAP_PATEXPAND               0xAB15U /* ROM: 0x40830920 (Apple ROM map name) */
#define TRAP_PINIT                   0xAB16U /* ROM: 0x4082C3F0 (Apple ROM map name) */
#define TRAP_PORTTOMAP               0xAB17U /* ROM: 0x408300D0 (Apple ROM map name) */
#define TRAP_PUSHVERB                0xAB18U /* ROM: 0x4082C410 (Apple ROM map name) */
#define TRAP_PUTLINE                 0xAB19U /* ROM: 0x40829890 (Apple ROM map name) */
#define TRAP_PUTOVAL                 0xAB1AU /* ROM: 0x4083D030 (Apple ROM map name) */
#define TRAP_PUTRGN                  0xAB1BU /* ROM: 0x4083BD10 (Apple ROM map name) */
#define TRAP_NEWTEMPBUFFER           0xAB1CU /* ROM: 0x408314A0 (Apple ROM map name) */
#define TRAP_QDExtensions            0xAB1DU /* ROM: 0x4083FA60 */
#define TRAP_DISPOSETEMPBUFFER       0xAB1EU /* ROM: 0x40831510 (Apple ROM map name) */
#define TRAP_RGNBLT                  0xAB1FU /* ROM: 0x4082A6E0 (Apple ROM map name) */
#define TRAP_RGNOP                   0xAB20U /* ROM: 0x4083D250 (Apple ROM map name) */
#define TRAP_RSECT                   0xAB21U /* ROM: 0x4082C6D4 (Apple ROM map name) */
#define TRAP_SEEKRGN                 0xAB22U /* ROM: 0x40836A10 (Apple ROM map name) */
#define TRAP_SETFILLPAT              0xAB23U /* ROM: 0x40830780 (Apple ROM map name) */
#define TRAP_SETUPSTRETCH            0xAB24U /* ROM: 0x40838440 (Apple ROM map name) */
#define TRAP_SLABMODE                0xAB25U /* ROM: 0x4082FEE0 (Apple ROM map name) */
#define TRAP_SORTPOINTS              0xAB26U /* ROM: 0x4083BC30 (Apple ROM map name) */
#define TRAP_STRETCHBITS             0xAB27U /* ROM: 0x40836B60 (Apple ROM map name) */
#define TRAP_STDDEVLOOP              0xAB28U /* ROM: 0x4082C1E0 (Apple ROM map name) */
#define TRAP_TRIMRECT                0xAB29U /* ROM: 0x40836520 (Apple ROM map name) */
#define TRAP_XORSLAB                 0xAB2AU /* ROM: 0x4082F110 (Apple ROM map name) */
#define TRAP_EXTBL                   0xAB2BU /* ROM: 0x4083852C (Apple ROM map name) */
#define TRAP_ToolboxTrap_AB2C        0xAB2CU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_NEWTEMPHANDLE           0xAB2DU /* ROM: 0x40831460 (Apple ROM map name) */
#define TRAP_PATEXTBL                0xAB2EU /* ROM: 0x4083854C (Apple ROM map name) */
#define TRAP_ToolboxTrap_AB2F        0xAB2FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_BMAIN0                  0xAB30U /* ROM: 0x4082CE12 (Apple ROM map name) */
#define TRAP_BMAIN1                  0xAB31U /* ROM: 0x4082CE42 (Apple ROM map name) */
#define TRAP_BMAIN2                  0xAB32U /* ROM: 0x4082CE62 (Apple ROM map name) */
#define TRAP_BMAIN3                  0xAB33U /* ROM: 0x4082CE82 (Apple ROM map name) */
#define TRAP_BSETUP8                 0xAB34U /* ROM: 0x4082CFC0 (Apple ROM map name) */
#define TRAP_BMAIN9                  0xAB35U /* ROM: 0x4082D062 (Apple ROM map name) */
#define TRAP_BSETUP10                0xAB36U /* ROM: 0x4082D0B0 (Apple ROM map name) */
#define TRAP_BMAIN11                 0xAB37U /* ROM: 0x4082D132 (Apple ROM map name) */
#define TRAP_BXMAIN8                 0xAB38U /* ROM: 0x4082D1B0 (Apple ROM map name) */
#define TRAP_BXMAIN9                 0xAB39U /* ROM: 0x4082D202 (Apple ROM map name) */
#define TRAP_BXMAIN10                0xAB3AU /* ROM: 0x4082D262 (Apple ROM map name) */
#define TRAP_BXMAIN11                0xAB3BU /* ROM: 0x4082D282 (Apple ROM map name) */
#define TRAP_BCMAIN0                 0xAB3CU /* ROM: 0x4082CEA2 (Apple ROM map name) */
#define TRAP_BCMAIN1                 0xAB3DU /* ROM: 0x4082CED2 (Apple ROM map name) */
#define TRAP_BHILITE                 0xAB3EU /* ROM: 0x4082DD40 (Apple ROM map name) */
#define TRAP_BCMAIN3                 0xAB3FU /* ROM: 0x4082CF02 (Apple ROM map name) */
#define TRAP_BEND0                   0xAB40U /* ROM: 0x4082CE10 (Apple ROM map name) */
#define TRAP_BEND1                   0xAB41U /* ROM: 0x4082CE40 (Apple ROM map name) */
#define TRAP_BEND2                   0xAB42U /* ROM: 0x4082CE60 (Apple ROM map name) */
#define TRAP_BEND3                   0xAB43U /* ROM: 0x4082CE80 (Apple ROM map name) */
#define TRAP_BLONG8                  0xAB44U /* ROM: 0x4082CF30 (Apple ROM map name) */
#define TRAP_BEND9                   0xAB45U /* ROM: 0x4082D060 (Apple ROM map name) */
#define TRAP_BEND10                  0xAB46U /* ROM: 0x4082D080 (Apple ROM map name) */
#define TRAP_BEND11                  0xAB47U /* ROM: 0x4082D130 (Apple ROM map name) */
#define TRAP_BXLONG8                 0xAB48U /* ROM: 0x4082D150 (Apple ROM map name) */
#define TRAP_BXEND9                  0xAB49U /* ROM: 0x4082D200 (Apple ROM map name) */
#define TRAP_BXEND10                 0xAB4AU /* ROM: 0x4082D230 (Apple ROM map name) */
#define TRAP_BXEND11                 0xAB4BU /* ROM: 0x4082D280 (Apple ROM map name) */
#define TRAP_BCEND0                  0xAB4CU /* ROM: 0x4082CEA0 (Apple ROM map name) */
#define TRAP_BCEND1                  0xAB4DU /* ROM: 0x4082CED0 (Apple ROM map name) */
#define TRAP_BSLOHILITE              0xAB4EU /* ROM: 0x4082DE10 (Apple ROM map name) */
#define TRAP_BCEND3                  0xAB4FU /* ROM: 0x4082CF00 (Apple ROM map name) */
#define TRAP_BAVG                    0xAB50U /* ROM: 0x4082DAD0 (Apple ROM map name) */
#define TRAP_BADDPIN                 0xAB51U /* ROM: 0x4082D450 (Apple ROM map name) */
#define TRAP_BADDOVER                0xAB52U /* ROM: 0x4082D340 (Apple ROM map name) */
#define TRAP_BSUBPIN                 0xAB53U /* ROM: 0x4082D6E0 (Apple ROM map name) */
#define TRAP_BTRANSPARENT            0xAB54U /* ROM: 0x4082DE80 (Apple ROM map name) */
#define TRAP_BMAX                    0xAB55U /* ROM: 0x4082D870 (Apple ROM map name) */
#define TRAP_BSUBOVER                0xAB56U /* ROM: 0x4082D5D0 (Apple ROM map name) */
#define TRAP_BMIN                    0xAB57U /* ROM: 0x4082D9A0 (Apple ROM map name) */
#define TRAP_BSETUP0                 0xAB58U /* ROM: 0x4082CD90 (Apple ROM map name) */
#define TRAP_BLEFT0                  0xAB59U /* ROM: 0x4082CD40 (Apple ROM map name) */
#define TRAP_RMASK0                  0xAB5AU /* ROM: 0x4082ACC0 (Apple ROM map name) */
#define TRAP_RMASK1                  0xAB5BU /* ROM: 0x4082AE5A (Apple ROM map name) */
#define TRAP_RMASK2                  0xAB5CU /* ROM: 0x4082AEBA (Apple ROM map name) */
#define TRAP_RMASK3                  0xAB5DU /* ROM: 0x4082AF1A (Apple ROM map name) */
#define TRAP_RMASK8                  0xAB5EU /* ROM: 0x4082B0EC (Apple ROM map name) */
#define TRAP_RMASK9                  0xAB5FU /* ROM: 0x4082B16E (Apple ROM map name) */
#define TRAP_RMASK10                 0xAB60U /* ROM: 0x4082B1DC (Apple ROM map name) */
#define TRAP_RMASK11                 0xAB61U /* ROM: 0x4082B22E (Apple ROM map name) */
#define TRAP_RXMASK8                 0xAB62U /* ROM: 0x4082B260 (Apple ROM map name) */
#define TRAP_RXMASK9                 0xAB63U /* ROM: 0x4082B2D2 (Apple ROM map name) */
#define TRAP_RXMASK10                0xAB64U /* ROM: 0x4082B350 (Apple ROM map name) */
#define TRAP_RXMASK11                0xAB65U /* ROM: 0x4082B390 (Apple ROM map name) */
#define TRAP_RAVG                    0xAB66U /* ROM: 0x4082BBB0 (Apple ROM map name) */
#define TRAP_RADDPIN                 0xAB67U /* ROM: 0x4082B4C0 (Apple ROM map name) */
#define TRAP_RADDOVER                0xAB68U /* ROM: 0x4082B3A0 (Apple ROM map name) */
#define TRAP_RSUBPIN                 0xAB69U /* ROM: 0x4082B790 (Apple ROM map name) */
#define TRAP_RTRANSPARENT            0xAB6AU /* ROM: 0x4082C060 (Apple ROM map name) */
#define TRAP_RMAX                    0xAB6BU /* ROM: 0x4082B930 (Apple ROM map name) */
#define TRAP_RSUBOVER                0xAB6CU /* ROM: 0x4082B660 (Apple ROM map name) */
#define TRAP_RMIN                    0xAB6DU /* ROM: 0x4082BA70 (Apple ROM map name) */
#define TRAP_RCMASK0                 0xAB6EU /* ROM: 0x4082AF60 (Apple ROM map name) */
#define TRAP_RCMASK1                 0xAB6FU /* ROM: 0x4082B00A (Apple ROM map name) */
#define TRAP_RSLOWHILITE             0xAB70U /* ROM: 0x4082BFD0 (Apple ROM map name) */
#define TRAP_RCMASK3                 0xAB71U /* ROM: 0x4082B07A (Apple ROM map name) */
#define TRAP_RHILITE                 0xAB72U /* ROM: 0x4082BE90 (Apple ROM map name) */
#define TRAP_STMASK0                 0xAB73U /* ROM: 0x408379F0 (Apple ROM map name) */
#define TRAP_STMASK1                 0xAB74U /* ROM: 0x40837A20 (Apple ROM map name) */
#define TRAP_STMASK2                 0xAB75U /* ROM: 0x40837A40 (Apple ROM map name) */
#define TRAP_STMASK3                 0xAB76U /* ROM: 0x40837A60 (Apple ROM map name) */
#define TRAP_STAVG                   0xAB77U /* ROM: 0x40837CC0 (Apple ROM map name) */
#define TRAP_STADDPIN                0xAB78U /* ROM: 0x40837AD0 (Apple ROM map name) */
#define TRAP_STADDOVER               0xAB79U /* ROM: 0x40837A80 (Apple ROM map name) */
#define TRAP_STSUBPIN                0xAB7AU /* ROM: 0x40837B90 (Apple ROM map name) */
#define TRAP_STTRANSPARENT           0xAB7BU /* ROM: 0x40837D20 (Apple ROM map name) */
#define TRAP_STMAX                   0xAB7CU /* ROM: 0x40837C00 (Apple ROM map name) */
#define TRAP_STSUBOVER               0xAB7DU /* ROM: 0x40837B40 (Apple ROM map name) */
#define TRAP_STMIN                   0xAB7EU /* ROM: 0x40837C60 (Apple ROM map name) */
#define TRAP_STHILITE                0xAB7FU /* ROM: 0x40837D60 (Apple ROM map name) */
#define TRAP_SLMASK8                 0xAB80U /* ROM: 0x4082F1C4 (Apple ROM map name) */
#define TRAP_SLMASK9                 0xAB81U /* ROM: 0x4082F1E6 (Apple ROM map name) */
#define TRAP_SLMASK10                0xAB82U /* ROM: 0x4082F1FC (Apple ROM map name) */
#define TRAP_SLMASK11                0xAB83U /* ROM: 0x4082F226 (Apple ROM map name) */
#define TRAP_SLXMASK8                0xAB84U /* ROM: 0x4082F230 (Apple ROM map name) */
#define TRAP_SLXMASK9                0xAB85U /* ROM: 0x4082F270 (Apple ROM map name) */
#define TRAP_SLXMASK10               0xAB86U /* ROM: 0x4082F2B0 (Apple ROM map name) */
#define TRAP_SLXMASK11               0xAB87U /* ROM: 0x4082F2F0 (Apple ROM map name) */
#define TRAP_SLAVG                   0xAB88U /* ROM: 0x4082F670 (Apple ROM map name) */
#define TRAP_SLADDPIN                0xAB89U /* ROM: 0x4082F3E0 (Apple ROM map name) */
#define TRAP_SLADDOVER               0xAB8AU /* ROM: 0x4082F330 (Apple ROM map name) */
#define TRAP_SLSUBPIN                0xAB8BU /* ROM: 0x4082F4E0 (Apple ROM map name) */
#define TRAP_SLTRANSPARENT           0xAB8CU /* ROM: 0x4082F790 (Apple ROM map name) */
#define TRAP_SLMAX                   0xAB8DU /* ROM: 0x4082F570 (Apple ROM map name) */
#define TRAP_SLSUBOVER               0xAB8EU /* ROM: 0x4082F470 (Apple ROM map name) */
#define TRAP_SLMIN                   0xAB8FU /* ROM: 0x4082F5F0 (Apple ROM map name) */
#define TRAP_SLHILITE                0xAB90U /* ROM: 0x4082F720 (Apple ROM map name) */
#define TRAP_ITABMATCH               0xAB91U /* ROM: 0x4083C250 (Apple ROM map name) */
#define TRAP_COLORTHING2INDEX        0xAB92U /* ROM: 0x4083C3A0 (Apple ROM map name) */
#define TRAP_ToolboxTrap_AB93        0xAB93U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ALLOCRUNBUF             0xAB94U /* ROM: 0x4083AF0A (Apple ROM map name) */
#define TRAP_INITRGN                 0xAB95U /* ROM: 0x408369C0 (Apple ROM map name) */
#define TRAP_SCALEBLT                0xAB96U /* ROM: 0x40839DD0 (Apple ROM map name) */
#define TRAP_STNOSTACK               0xAB97U /* ROM: 0x40837980 (Apple ROM map name) */
#define TRAP_BLITCASE                0xAB98U /* ROM: 0x40836D24 (Apple ROM map name) */
#define TRAP_STSCANLOOP              0xAB99U /* ROM: 0x408374D0 (Apple ROM map name) */
#define TRAP_PICITEM1                0xAB9AU /* ROM: 0x40831F60 (Apple ROM map name) */
#define TRAP_MAKEGRAYITAB            0xAB9BU /* ROM: 0x4083C144 (Apple ROM map name) */
#define TRAP_FASTLINE                0xAB9CU /* ROM: 0x40829EA0 (Apple ROM map name) */
#define TRAP_FASTSLANT               0xAB9DU /* ROM: 0x4082A080 (Apple ROM map name) */
#define TRAP_BITSDEVLOOP             0xAB9EU /* ROM: 0x40835200 (Apple ROM map name) */
#define TRAP_ToolboxTrap_AB9F        0xAB9FU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_RARITH16TAB             0xABA0U /* ROM: 0x4082AC5C (Apple ROM map name) */
#define TRAP_RARITH32TAB             0xABA1U /* ROM: 0x4082AC80 (Apple ROM map name) */
#define TRAP_RHILITETAB              0xABA2U /* ROM: 0x4082ACA4 (Apple ROM map name) */
#define TRAP_GSRUNTBL                0xABA3U /* ROM: 0x4083B084 (Apple ROM map name) */
#define TRAP_GSEXPTBL                0xABA4U /* ROM: 0x4083B09C (Apple ROM map name) */
#define TRAP_GSSEEKTBL               0xABA5U /* ROM: 0x4083B0B4 (Apple ROM map name) */
#define TRAP_STARITH16TAB            0xABA6U /* ROM: 0x408383F4 (Apple ROM map name) */
#define TRAP_STARITH32TAB            0xABA7U /* ROM: 0x40838418 (Apple ROM map name) */
#define TRAP_STCOLORTAB              0xABA8U /* ROM: 0x40837030 (Apple ROM map name) */
#define TRAP_STGRAYTAB               0xABA9U /* ROM: 0x40837050 (Apple ROM map name) */
#define TRAP_STSEARCHTAB             0xABAAU /* ROM: 0x40837070 (Apple ROM map name) */
#define TRAP_SCALEINDEXEDTOINDEXED   0xABABU /* ROM: 0x40839380 (Apple ROM map name) */
#define TRAP_SCINDTAB1               0xABACU /* ROM: 0x4083A614 (Apple ROM map name) */
#define TRAP_SCINDTAB2               0xABADU /* ROM: 0x4083A624 (Apple ROM map name) */
#define TRAP_SCINDTAB4               0xABAEU /* ROM: 0x4083A634 (Apple ROM map name) */
#define TRAP_SCINDTAB8               0xABAFU /* ROM: 0x4083A644 (Apple ROM map name) */
#define TRAP_SCINDTAB16              0xABB0U /* ROM: 0x4083A654 (Apple ROM map name) */
#define TRAP_SCINDTAB32              0xABB1U /* ROM: 0x4083A664 (Apple ROM map name) */
#define TRAP_SCDIRTAB1               0xABB2U /* ROM: 0x4083A554 (Apple ROM map name) */
#define TRAP_SCDIRTAB2               0xABB3U /* ROM: 0x4083A574 (Apple ROM map name) */
#define TRAP_SCDIRTAB4               0xABB4U /* ROM: 0x4083A594 (Apple ROM map name) */
#define TRAP_SCDIRTAB8               0xABB5U /* ROM: 0x4083A5B4 (Apple ROM map name) */
#define TRAP_SCDIRTAB16              0xABB6U /* ROM: 0x4083A5D4 (Apple ROM map name) */
#define TRAP_SCDIRTAB32              0xABB7U /* ROM: 0x4083A5F4 (Apple ROM map name) */
#define TRAP_BARITH16TAB             0xABB8U /* ROM: 0x4082CCE0 (Apple ROM map name) */
#define TRAP_BARITH32TAB             0xABB9U /* ROM: 0x4082CD04 (Apple ROM map name) */
#define TRAP_BHILITETAB              0xABBAU /* ROM: 0x4082CD28 (Apple ROM map name) */
#define TRAP_BARITH16SETUP           0xABBBU /* ROM: 0x4082D2F0 (Apple ROM map name) */
#define TRAP_BARITH32SETUP           0xABBCU /* ROM: 0x4082D2B0 (Apple ROM map name) */
#define TRAP_SLARITH16TAB            0xABBDU /* ROM: 0x4082FF70 (Apple ROM map name) */
#define TRAP_SLARITH32TAB            0xABBEU /* ROM: 0x4082FF94 (Apple ROM map name) */
#define TRAP_ToolboxTrap_ABBF        0xABBFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABC0        0xABC0U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABC1        0xABC1U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABC2        0xABC2U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_NQDMisc                 0xABC3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABC4        0xABC4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABC5        0xABC5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABC6        0xABC6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABC7        0xABC7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABC8        0xABC8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_IconDispatch            0xABC9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DeviceLoop              0xABCAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABCB        0xABCBU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABCC        0xABCCU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABCD        0xABCDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABCE        0xABCEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABCF        0xABCFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD0        0xABD0U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD1        0xABD1U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD2        0xABD2U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD3        0xABD3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD4        0xABD4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD5        0xABD5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD6        0xABD6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD7        0xABD7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD8        0xABD8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABD9        0xABD9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABDA        0xABDAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABDB        0xABDBU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABDC        0xABDCU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABDD        0xABDDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABDE        0xABDEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABDF        0xABDFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_QDExtensions2           0xABE0U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABE1        0xABE1U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABE2        0xABE2U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABE3        0xABE3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABE4        0xABE4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABE5        0xABE5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABE6        0xABE6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABE7        0xABE7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABE8        0xABE8U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABE9        0xABE9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABEA        0xABEAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DisplayDispatch         0xABEBU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABEC        0xABECU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DragDispatch            0xABEDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABEE        0xABEEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABEF        0xABEFU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABF0        0xABF0U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_GestaltValueDispatch    0xABF1U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ThreadDispatch          0xABF2U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABF3        0xABF3U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABF4        0xABF4U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABF5        0xABF5U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_CollectionMgr           0xABF6U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABF7        0xABF7U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_StdOpcodeProc           0xABF8U /* ROM: 0x40831B30 */
#define TRAP_ToolboxTrap_ABF9        0xABF9U /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABFA        0xABFAU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABFB        0xABFBU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_TranslationDispatch     0xABFCU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABFD        0xABFDU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_ToolboxTrap_ABFE        0xABFEU /* ROM: 0x40809AE6 (unimplemented) */
#define TRAP_DebugStr                0xABFFU /* ROM: 0x40809AE6 (unimplemented) */

typedef struct {
    uint16_t trap_num;
    const char *name;
    uint32_t rom_address;
    bool is_implemented;
    bool is_toolbox;
} MacTrapEntry;

extern const MacTrapEntry g_mac_os_traps[256];
extern const MacTrapEntry g_mac_toolbox_traps[1024];

const MacTrapEntry* LookupTrapByNum(uint16_t trap_num);
const MacTrapEntry* LookupTrapByName(const char *name);

#ifdef __cplusplus
}
#endif

#endif /* MAC_TRAPS_H */
