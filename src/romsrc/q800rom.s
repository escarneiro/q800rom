/*
 q800rom.s - Macintosh Quadra 800 ROM, 68040 GNU as source

 Layout (files are included in ROM order):
   boot/        ROM header, cold start, start-up support, hardware set-up, boot
   os/          Operating System managers, traps and support code
   toolbox/     Toolbox managers
   quickdraw/   Color QuickDraw, Palette Manager, offscreen worlds
   sound/       Sound Manager, sound primitives, beeps
   hw/          universal hardware support and tables, SONIC
   video/       built-in video drivers
   patches/     ROM patch areas
   diag/        diagnostics and the Test Manager
   misc/        unlabeled code and data
   rsrc/        the ROM resources, one file per resource (map entry, header, data)
   declrom/     motherboard declaration ROM and format block
   include/     traps_gas.inc, lowmem.inc, macros.inc
 Code module boundaries follow Apple's routine names (MPW ROM map); Apple's own source
 modules are not known. Comments are C style (slash-star ... star-slash); short notes
 (ROM addresses, instruction forms) start with '|'. Addresses in comments are ROM
 addresses (ROMBase 0x40800000).
*/

    .include "traps_gas.inc"
    .include "lowmem.inc"
    .include "macros.inc"
    .include "romfill.inc"
    .text
rom_start:
    .include "boot/header.s"
    .include "boot/startinit.s"
    .include "boot/startutil.s"
    .include "boot/hwinit.s"
    .include "boot/patchspace2.s"
    .include "boot/startmgr.s"
    .include "boot/boot.s"
    .include "os/syserr.s"
    .include "hw/universal.s"
    .include "os/mmu.s"
    .include "patches/startpatches.s"
    .include "os/iopmgr.s"
    .include "os/hwpriv.s"
    .include "os/slotmgr.s"
    .include "os/sysbeep.s"
    .include "os/scsimgr.s"
    .include "os/dispatcher.s"
    .include "os/interrupts.s"
    .include "os/vbl.s"
    .include "os/adbmgr.s"
    .include "os/timemgr.s"
    .include "os/osevents.s"
    .include "os/devicemgr.s"
    .include "os/segloader.s"
    .include "os/osutil.s"
    .include "os/memmgr.s"
    .include "os/shutdown.s"
    .include "os/filemgr.s"
    .include "os/egret.s"
    .include "toolbox/miscmgr.s"
    .include "toolbox/controlmgr.s"
    .include "os/gestalt.s"
    .include "toolbox/menumgr.s"
    .include "toolbox/windowmgr.s"
    .include "toolbox/dialogmgr.s"
    .include "toolbox/resourcemgr.s"
    .include "toolbox/toolutil.s"
    .include "toolbox/deskmgr.s"
    .include "toolbox/scriptmgr.s"
    .include "toolbox/getmgr.s"
    .include "toolbox/textedit.s"
    .include "toolbox/scrapmgr.s"
    .include "toolbox/printglue.s"
    .include "toolbox/packmgr.s"
    .include "toolbox/fontmgr.s"
    .include "quickdraw/gdevice.s"
    .include "quickdraw/text.s"
    .include "quickdraw/drawcore.s"
    .include "quickdraw/ports.s"
    .include "quickdraw/pictures.s"
    .include "quickdraw/shapes.s"
    .include "quickdraw/regions.s"
    .include "quickdraw/stretch.s"
    .include "quickdraw/ovals.s"
    .include "quickdraw/colormgr.s"
    .include "quickdraw/rgnops.s"
    .include "quickdraw/palettemgr.s"
    .include "quickdraw/gworld.s"
    .include "os/mmutablespad.s"
    .include "sound/soundmgr.s"
    .include "sound/bootbeep.s"
    .include "diag/tests.s"
    .include "diag/rbi.s"
    .include "patches/overpatches.s"
    .include "misc/restop.s"
    .include "rsrc/51D40_DRVR_49_netBOOT.s"
    .include "rsrc/52530_DRVR_50_ATBOOT.s"
    .include "rsrc/568F0_free_0_Main.s"
    .include "rsrc/56BA0_PICT_106_DiskMode_6.s"
    .include "rsrc/56CA0_PICT_105_DiskMode_5.s"
    .include "rsrc/56DA0_PICT_104_DiskMode_4.s"
    .include "rsrc/56EA0_PICT_103_DiskMode_3.s"
    .include "rsrc/56FA0_PICT_102_DiskMode_2.s"
    .include "rsrc/570A0_PICT_101_DiskMode_1.s"
    .include "rsrc/571A0_PICT_100_DiskMode_0.s"
    .include "rsrc/572A0_PICT_99_DiskMode_Battery.s"
    .include "rsrc/573B0_PICT_98_DiskMode_Arrow3.s"
    .include "rsrc/57520_PICT_97_DiskMode_Arrow2.s"
    .include "rsrc/57690_PICT_96_DiskMode_Arrow1.s"
    .include "rsrc/57800_PICT_95_DiskMode_SCSI.s"
    .include "rsrc/57F80_PICT_501_Decrypt_Data.s"
    .include "rsrc/580D0_attx_1.s"
    .include "rsrc/59500_free_1_Main.s"
    .include "rsrc/5A760_iopc_1.s"
    .include "rsrc/5DB90_SERD_61_IOP_Async_B.s"
    .include "rsrc/5E7E0_SERD_60_IOP_Async_A.s"
    .include "rsrc/5F430_iopc_0.s"
    .include "rsrc/60080_free_2_Main.s"
    .include "rsrc/6AB60_SERD_0.s"
    .include "rsrc/6C3B0_DRVR_4_Sony.s"
    .include "rsrc/72CA0_cctb_0.s"
    .include "rsrc/72D00_wctb_0.s"
    .include "rsrc/72D60_mitq_0.s"
    .include "rsrc/72DA0_gama_0_StdGamma.s"
    .include "rsrc/72EE0_clut_127_DefQDColors.s"
    .include "rsrc/72F60_clut_8_8BitStd.s"
    .include "rsrc/737A0_clut_4_4BitStd.s"
    .include "rsrc/73860_clut_2_2BitStd.s"
    .include "rsrc/738C0_clut_1_1BitStd.s"
    .include "rsrc/73910_PACK_4.s"
    .include "rsrc/764C0_accl_7.s"
    .include "rsrc/76560_accl_6.s"
    .include "rsrc/76600_accl_5.s"
    .include "rsrc/76660_accl_4.s"
    .include "rsrc/766C0_accl_3.s"
    .include "rsrc/76720_accl_2.s"
    .include "rsrc/767C0_accl_1.s"
    .include "rsrc/76860_accl_0.s"
    .include "rsrc/768C0_WDEF_0.s"
    .include "rsrc/77130_WDEF_1.s"
    .include "rsrc/77660_MDEF_0.s"
    .include "rsrc/784A0_MBDF_0.s"
    .include "rsrc/79290_CDEF_1.s"
    .include "rsrc/79890_CDEF_0.s"
    .include "rsrc/79DB0_PACK_7.s"
    .include "rsrc/7A340_snd_1_Brass_Horn.s"
    .include "rsrc/7AE40_KCAP_7.s"
    .include "rsrc/7B0B0_KCAP_6.s"
    .include "rsrc/7B310_KMAP_2.s"
    .include "rsrc/7B3D0_KMAP_0.s"
    .include "rsrc/7B490_KCHR_0.s"
    .include "rsrc/7BA50_FONT_521.s"
    .include "rsrc/7C430_FONT_512_Monaco.s"
    .include "rsrc/7C460_FONT_396.s"
    .include "rsrc/7D100_FONT_393.s"
    .include "rsrc/7DB60_FONT_384_Geneva.s"
    .include "rsrc/7DB90_FONT_12.s"
    .include "rsrc/7E9E0_FONT_0_Chicago.s"
    .include "rsrc/7EA10_CURS_4.s"
    .include "rsrc/7EA90_CURS_3.s"
    .include "rsrc/7EB10_CURS_2.s"
    .include "rsrc/7EB90_CURS_1.s"
    .include "rsrc/7EC10_resourcemap.s"
    .include "os/mmuinit.s"
    .include "patches/ospatches.s"
    .include "os/powermgr.s"
    .include "patches/slotpatches.s"
    .include "sound/sndprims.s"
    .include "patches/windowpatches.s"
    .include "os/fpsp.s"
    .include "os/privtrap.s"
    .include "video/jmfb.s"
    .include "video/tfb.s"
    .include "os/scsi96.s"
    .include "patches/rsrcpatches.s"
    .include "misc/picturedata.s"
    .include "hw/wallyworld.s"
    .include "hw/primitives.s"
    .include "os/postusernm.s"
    .include "toolbox/crsrdev.s"
    .include "os/docking.s"
    .include "os/diskmode.s"
    .include "diag/testmgr.s"
    .include "patches/beeppatches.s"
    .include "sound/bootchime.s"
    .include "diag/dtm.s"
    .include "hw/sonic.s"
    .include "os/scsibios.s"
    .include "hw/univtables.s"
    .include "os/disptable.s"
    .include "rsrc/D3C80_DRVR_-16511_Backlight.s"
    .include "rsrc/D5100_pslt_32.s"
    .include "rsrc/D5140_pslt_29.s"
    .include "rsrc/D5180_pslt_63.s"
    .include "rsrc/D51C0_pslt_58.s"
    .include "rsrc/D5210_pslt_53.s"
    .include "rsrc/D5250_pslt_52.s"
    .include "rsrc/D5290_pslt_59.s"
    .include "rsrc/D52E0_pslt_58.s"
    .include "rsrc/D5330_pslt_51.s"
    .include "rsrc/D5380_pslt_36.s"
    .include "rsrc/D53D0_pslt_35.s"
    .include "rsrc/D5420_pslt_30.s"
    .include "rsrc/D5470_pslt_26.s"
    .include "rsrc/D54C0_ecfg_63_WLCD_33.s"
    .include "rsrc/D5520_ecfg_62_Vail_33.s"
    .include "rsrc/D5580_ecfg_59_Wombat_40F.s"
    .include "rsrc/D55E0_ecfg_58_Wombat_20.s"
    .include "rsrc/D5640_ecfg_57_WLCD_Consumer_1.s"
    .include "rsrc/D56B0_ecfg_53_WLCD_25.s"
    .include "rsrc/D5710_ecfg_52_WLCD_20.s"
    .include "rsrc/D5770_ecfg_51_Wombat_40.s"
    .include "rsrc/D57D0_ecfg_36_Wombat_33.s"
    .include "rsrc/D5830_ecfg_35_Wombat_33F.s"
    .include "rsrc/D5890_ecfg_30_Wombat_25.s"
    .include "rsrc/D58F0_ecfg_27_Vail.s"
    .include "rsrc/D5950_ecfg_26_Quadra950.s"
    .include "rsrc/D59B0_ecfg_22_Quadra700.s"
    .include "rsrc/D5A10_ecfg_20_Quadra900.s"
    .include "rsrc/D5A70_ecfg_19_MacLC_LCII.s"
    .include "rsrc/D5AD0_enet_46.s"
    .include "rsrc/D72D0_DRVR_127_ENET.s"
    .include "rsrc/D7810_atlk_10.s"
    .include "rsrc/D8870_iopc_128.s"
    .include "rsrc/D9490_atlk_3.s"
    .include "rsrc/D9780_ltlk_2.s"
    .include "rsrc/DA6E0_ltlk_3.s"
    .include "rsrc/DADB0_iopc_127.s"
    .include "rsrc/DB9D0_atlk_1.s"
    .include "rsrc/DBCC0_ltlk_0.s"
    .include "rsrc/DCCA0_ltlk_1.s"
    .include "rsrc/DD380_drvr_9.s"
    .include "rsrc/E0B00_lmgr_0.s"
    .include "rsrc/E2720_INIT_18.s"
    .include "rsrc/E28E0_DRVR_40_XPP.s"
    .include "rsrc/E3660_DRVR_10_ATP.s"
    .include "rsrc/E4660_DRVR_9_MPP.s"
    .include "rsrc/E59C0_DRVR_3_Sound.s"
    .include "rsrc/E6370_free_4_Main.s"
    .include "rsrc/E74D0_DRVR_51_EDisk.s"
    .include "rsrc/E7F90_PACK_5.s"
    .include "rsrc/E99F0_PACK_4.s"
    .include "rsrc/EDC70_PACK_5.s"
/* free space before the fixed region: new code (hooks into ROM routines) goes here */
    .include "patches/hooks.s"
    .org    0x0F0000, 0x00	| padding up to a fixed address
    .include "declrom/declrom.s"

| Labels that point inside an instruction
    .set    CHECKFORUNKNOWN_286, CHECKFORUNKNOWN_284 + 2
    .set    MMUCLEANUPFOR8MB_FE, MMUCLEANUPFOR8MB_FC + 2
    .set    INITSNDNORAM_B8, INITSNDNORAM_B6 + 2
    .set    INITSNDNORAM_F8, INITSNDNORAM_F6 + 2
    .set    OPTIONALSPATCH_BA, GETHARDWAREINFOPATCH_58 + 2
    .set    SENDEGRETCMD_152, SENDEGRETCMD_150 + 2
    .set    XSTR2FORM_D6, XSTR2FORM_D4 + 2
    .set    XFORMSTR2X_B8, XFORMSTR2X_B6 + 2
    .set    APPENDSYMBOL_56, APPENDSYMBOL_54 + 2
    .set    XFINDWORD_17C, XFINDWORD_17A + 2
    .set    SLOPEFROMANGLE_13, SLOPEFROMANGLE_10 + 3
    .set    SCCTIMERTEST_D6, SCCTIMERTEST_D4 + 2
    .set    SIZEVRAM_28E, SIZEVRAM_28A + 4
    .set    RESTOP_6C5A, rsrc_DRVR_50__ATBOOT_3AD2_46 + 2
    .set    SETSUPERVISORMODE_6F6, SETSUPERVISORMODE_6F4 + 2
    .set    SETSUPERVISORMODE_760, SETSUPERVISORMODE_75E + 2
    .set    SETSUPERVISORMODE_7B0, SETSUPERVISORMODE_7AE + 2
    .set    fpsp_EM1POLY_A4, fpsp_EM1POLY_A2 + 2
    .set    fpsp_SMALRP_60, fpsp_SMALRP_5E + 2
    .set    fpsp_BIGRZRM_24, fpsp_BIGRZRM_22 + 2
    .set    fpsp_BIGRZRM_E4, fpsp_BIGRZRM_E2 + 2
    .set    CPUDECLDATA_710, CPUDECLDATA_70E + 2
    .set    DOCKINGWAKEUP_E2, DOCKINGWAKEUP_E0 + 2
    .set    DOCKINITSCC_17E, DOCKINITSCC_17C + 2
    .set    DOCKINITSCC_2B0, DOCKINITSCC_2AC + 4
    .set    DOCKINITSCC_2B4, DOCKINITSCC_2B2 + 2
    .set    USTSTRT1_104, USTSTRT1_102 + 2
    .set    DSPTABLE_76, DSPTABLE + 118
    .set    DSPTABLE_176, DSPTABLE + 374
    .set    DSPTABLE_5EE, DSPTABLE + 1518
    .set    DSPTABLE_DEE, rsrc_DRVR_m16511__Backlight_440_6C + 2
    .set    DSPTABLE_153C, rsrc_DRVR_m16511__Backlight_BDE_1C + 2
    .set    DSPTABLE_1638, rsrc_DRVR_m16511__Backlight_CC6_30 + 2
    .set    DSPTABLE_1BFE, rsrc_DRVR_m16511__Backlight_1294_28 + 2
    .set    DSPTABLE_1CA6, rsrc_DRVR_m16511__Backlight_1340_24 + 2
    .set    DSPTABLE_15C50, rsrc_PACK_5_FFE + 2
    .set    DSPTABLE_15C64, rsrc_PACK_5_1012 + 2
    .set    DSPTABLE_15C78, rsrc_PACK_5_1026 + 2
    .set    DECL_SR7F_FE_CPU_AppleII_AppleIIe_FeatureCard_id80_data, DECL_DRVR_Display_Video_Apple_DAFB_GetDefaultMode_268_254 + 1
