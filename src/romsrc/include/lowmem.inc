/*
 lowmem.inc - Macintosh low-memory globals used by the ROM source

 Names come from published sources only: Apple's names for the Plus/SE ROMs as
 reconstructed in jonathanschilling/mac_rom (include/lowmem.inc, lowmem_se.inc;
 entries marked 'mac_rom'), Inside Macintosh, and the headers of MPW Golden Master
 (LowMemEqu.a, ToolUtils.a, LowMem.h; entries marked 'MPW', with Apple's description).
 Names found only in Apple's private files are not used. Apple kept these globals at the same
 addresses on later machines, but a few may serve a different purpose on the Quadra.
 Addresses without a published name stay numeric in the source.
*/

    .equ    ResetStackPtr,           0x0000     /* mac_rom */
    .equ    ResetVector,             0x0004     /* mac_rom */
    .equ    BusErrorVector,          0x0008     /* mac_rom */
    .equ    ATrapVector,             0x0028     /* mac_rom */
    .equ    Lev1AutoVector,          0x0064     /* mac_rom */
    .equ    MonkeyLives,             0x0100     /* monkey lives if >= 0 [word] (MPW LowMemEqu.a) */
    .equ    ScrVRes,                 0x0102     /* mac_rom */
    .equ    ScrHRes,                 0x0104     /* screen horizontal dots/inch [word] (MPW LowMemEqu.a) */
    .equ    ScreenRow,               0x0106     /* mac_rom */
    .equ    MemTop,                  0x0108     /* address of the end of RAM */
    .equ    BufPtr,                  0x010C     /* address of the end of the application heap area */
    .equ    StackLowPoint,           0x0110     /* lowest stack address seen (stack sniffer) */
    .equ    HeapEnd,                 0x0114     /* end of the current application heap zone */
    .equ    TheZone,                 0x0118     /* current heap zone */
    .equ    UTableBase,              0x011C     /* mac_rom */
    .equ    MacJmp,                  0x0120     /* mac_rom */
    .equ    DskRtnAdr,               0x0124     /* mac_rom */
    .equ    DskVerify,               0x012C     /* disk driver: verify after write */
    .equ    LoadTrap,                0x012D     /* trap before launch */
    .equ    MmInOK,                  0x012E     /* initial memory mgr checks ok? [byte] (MPW LowMemEqu.a) */
    .equ    CPUFlag,                 0x012F     /* processor type (4 = 68040) */
    .equ    ApplLimit,               0x0130     /* mac_rom */
    .equ    SonyVars,                0x0134     /* mac_rom */
    .equ    PWMValue,                0x0138     /* current PWM value */
    .equ    PollStack,               0x013A     /* mac_rom */
    .equ    PollProc,                0x013E     /* SCC poll data procedure */
    .equ    DskErr,                  0x0142     /* mac_rom */
    .equ    SysEvtMask,              0x0144     /* system event mask */
    .equ    SysEvtBuf,               0x0146     /* mac_rom */
    .equ    EventQueue,              0x014A     /* mac_rom */
    .equ    EvtBufCnt,               0x0154     /* mac_rom */
    .equ    RndSeed,                 0x0156     /* mac_rom */
    .equ    SysVersion,              0x015A     /* system version */
    .equ    SEvtEnb,                 0x015C     /* mac_rom */
    .equ    DSWndUpdate,             0x015D     /* mac_rom */
    .equ    FontFlag,                0x015E     /* mac_rom */
    .equ    IntFlag,                 0x015F     /* mac_rom */
    .equ    VBLQueue,                0x0160     /* vertical blanking queue header */
    .equ    VBLQueueHdr_Head,        0x0162     /* mac_rom */
    .equ    Ticks,                   0x016A     /* tick count since start-up */
    .equ    Ticks_LoWord,            0x016C     /* mac_rom */
    .equ    Ticks_LoByte,            0x016D     /* mac_rom */
    .equ    MBTicks,                 0x016E     /* tick count at the last mouse button change */
    .equ    MBState,                 0x0172     /* current mouse button state */
    .equ    KeyMap,                  0x0174     /* keyboard state, one bit per key code (16 bytes) */
    .equ    KeyMap_6,                0x017A     /* mac_rom */
    .equ    KeyMap_7,                0x017B     /* mac_rom */
    .equ    KeyLast,                 0x0184     /* mac_rom */
    .equ    KeyTime,                 0x0186     /* mac_rom */
    .equ    KeyRepTime,              0x018A     /* mac_rom */
    .equ    KeyThresh,               0x018E     /* auto-key threshold */
    .equ    KeyRepThresh,            0x0190     /* auto-key rate */
    .equ    Lvl1DT,                  0x0192     /* mac_rom */
    .equ    Lvl1DT_2,                0x019A     /* mac_rom */
    .equ    Lvl1DT_5,                0x01A6     /* mac_rom */
    .equ    Lvl2DT,                  0x01B2     /* mac_rom */
    .equ    Lvl2DT_1,                0x01B6     /* mac_rom */
    .equ    Lvl2DT_2,                0x01BA     /* mac_rom */
    .equ    Lvl2DT_4,                0x01C2     /* mac_rom */
    .equ    UnitTableEntryCount,     0x01D2     /* mac_rom */
    .equ    VIA,                     0x01D4     /* mac_rom */
    .equ    SCCRd,                   0x01D8     /* mac_rom */
    .equ    SCCWr,                   0x01DC     /* mac_rom */
    .equ    IWM,                     0x01E0     /* mac_rom */
    .equ    Scratch20,               0x01E4     /* mac_rom */
    .equ    SPValid,                 0x01F8     /* parameter RAM copy: validity byte (start of SysParam) */
    .equ    SPATalkB,                0x01FA     /* mac_rom */
    .equ    SPConfig,                0x01FB     /* mac_rom */
    .equ    SPPortA,                 0x01FC     /* mac_rom */
    .equ    SPPortB,                 0x01FE     /* mac_rom */
    .equ    SPAlarm,                 0x0200     /* mac_rom */
    .equ    SPFont,                  0x0204     /* mac_rom */
    .equ    SPKbd,                   0x0206     /* parameter RAM copy: keyboard repeat rate and delay */
    .equ    SPVolCtl,                0x0208     /* mac_rom */
    .equ    SPClikCaret,             0x0209     /* parameter RAM copy: double-click and caret-blink times */
    .equ    SPMisc1,                 0x020A     /* miscellaneous [1 byte] (MPW LowMemEqu.a) */
    .equ    SPMisc2,                 0x020B     /* mac_rom */
    .equ    Time,                    0x020C     /* mac_rom */
    .equ    BootDrive,               0x0210     /* mac_rom */
    .equ    KbdVers,                 0x0216     /* mac_rom */
    .equ    KbdLast,                 0x0218     /* mac_rom */
    .equ    JKybdTask,               0x021A     /* keyboard VBL task hook */
    .equ    KbdType,                 0x021E     /* mac_rom */
    .equ    AlarmState,              0x021F     /* alarm state bits */
    .equ    MemErr,                  0x0220     /* mac_rom */
    .equ    DiskVars_JFigTrkSpd,     0x0222     /* mac_rom */
    .equ    DiskVars_JDiskPrime,     0x0226     /* mac_rom */
    .equ    DiskVars_JRdAddr,        0x022A     /* mac_rom */
    .equ    DiskVars_JRdData,        0x022E     /* mac_rom */
    .equ    DiskVars_JSeek,          0x0236     /* mac_rom */
    .equ    DiskVars_JSetUpPoll,     0x023A     /* mac_rom */
    .equ    DiskVars_JRecal,         0x023E     /* mac_rom */
    .equ    DiskVars_JControl,       0x0242     /* mac_rom */
    .equ    DiskVars_JWakeUp,        0x0246     /* mac_rom */
    .equ    DiskVars_JReSeek,        0x024A     /* mac_rom */
    .equ    DiskVars_NiblTbl,        0x025A     /* mac_rom */
    .equ    FlEvtMask,               0x025E     /* flushed-event mask */
    .equ    SdVolume,                0x0260     /* mac_rom */
    .equ    SoundPtr,                0x0262     /* mac_rom */
    .equ    SoundBase,               0x0266     /* sound buffer address */
    .equ    SoundVBL_qLink,          0x026A     /* mac_rom */
    .equ    SoundDCE,                0x027A     /* mac_rom */
    .equ    SoundActive,             0x027E     /* mac_rom */
    .equ    SoundLevel,              0x027F     /* mac_rom */
    .equ    CurPitch,                0x0280     /* mac_rom */
    .equ    SwitcherTPtr,            0x0286     /* Switcher's table of low-memory ranges to swap */
    .equ    ROM85,                   0x028E     /* ROM version flags word */
    .equ    PortAUse,                0x0290     /* mac_rom */
    .equ    PortBUse,                0x0291     /* mac_rom */
    .equ    GNEFilter,               0x029A     /* GetNextEvent filter procedure */
    .equ    SysZone,                 0x02A6     /* system heap zone */
    .equ    ApplZone,                0x02AA     /* application heap zone */
    .equ    ROMBase,                 0x02AE     /* base address of the ROM */
    .equ    RAMBase,                 0x02B2     /* RAM base address (also the system heap) */
    .equ    ExpandMem,               0x02B6     /* expanded low-memory record (Apple technical notes) */
    .equ    DSAlertTab,              0x02BA     /* system error alert table */
    .equ    ExtStsDT,                0x02BE     /* mac_rom */
    .equ    ExtStsDT_A,              0x02C6     /* mac_rom */
    .equ    SCCASts,                 0x02CE     /* mac_rom */
    .equ    SCCBSts,                 0x02CF     /* mac_rom */
    .equ    SerialVars_a,            0x02D0     /* mac_rom */
    .equ    ABusVars,                0x02D8     /* mac_rom */
    .equ    ABusVars_dce,            0x02DC     /* mac_rom */
    .equ    FinderName,              0x02E0     /* mac_rom */
    .equ    DoubleTime,              0x02F0     /* double-click interval in ticks */
    .equ    CaretTime,               0x02F4     /* caret-blink interval in ticks */
    .equ    TagData,                 0x02FA     /* sector tag info for disk drivers [14 bytes] (MPW LowMemEqu.a) */
    .equ    TagData_1,               0x02FB     /* mac_rom */
    .equ    BufTgFNum,               0x02FC     /* mac_rom */
    .equ    BufTgFFlg,               0x0300     /* mac_rom */
    .equ    BufTgFBkNum,             0x0302     /* logical block number [word] (MPW LowMemEqu.a) */
    .equ    BufTgDate,               0x0304     /* mac_rom */
    .equ    DrvQHdr,                 0x0308     /* drive queue header */
    .equ    DrvQHdr_Head,            0x030A     /* mac_rom */
    .equ    PWMBuf2,                 0x0312     /* PWM buffer 2 */
    .equ    Lo3Bytes,                0x031A     /* mac_rom */
    .equ    MinStack,                0x031E     /* mac_rom */
    .equ    DefltStack,              0x0322     /* mac_rom */
    .equ    MMDefFlags,              0x0326     /* mac_rom */
    .equ    GZRootHnd,               0x0328     /* mac_rom */
    .equ    GZRootPtr,               0x032C     /* mac_rom */
    .equ    GZMoveHnd,               0x0330     /* mac_rom */
    .equ    DSDrawProc,              0x0334     /* mac_rom */
    .equ    EjectNotify,             0x0338     /* mac_rom */
    .equ    IAZNotify,               0x033C     /* world-swap notification procedure */
    .equ    CkdDB,                   0x0340     /* mac_rom */
    .equ    NxtDB,                   0x0342     /* mac_rom */
    .equ    MaxDB,                   0x0344     /* mac_rom */
    .equ    FlushOnly,               0x0346     /* mac_rom */
    .equ    RegRsrc,                 0x0347     /* mac_rom */
    .equ    FLckUnlck,               0x0348     /* mac_rom */
    .equ    FrcSync,                 0x0349     /* mac_rom */
    .equ    NewMount,                0x034A     /* mac_rom */
    .equ    NoEject,                 0x034B     /* mac_rom */
    .equ    DrMstrBlk,               0x034C     /* mac_rom */
    .equ    FCBSPtr,                 0x034E     /* mac_rom */
    .equ    DefVCBPtr,               0x0352     /* mac_rom */
    .equ    VCBQHdr_Flags,           0x0356     /* mac_rom */
    .equ    VCBQHdr_Head,            0x0358     /* mac_rom */
    .equ    FSQHdr_Flags,            0x0360     /* mac_rom */
    .equ    FSQHdr_Head,             0x0362     /* mac_rom */
    .equ    FSQHdr_Tail,             0x0366     /* mac_rom */
    .equ    HFSVars_HFSStkTop,       0x036A     /* mac_rom */
    .equ    HFSStkPtr,               0x036E     /* mac_rom */
    .equ    WDCBsPtr,                0x0372     /* mac_rom */
    .equ    HFSFlags,                0x0376     /* mac_rom */
    .equ    SysCRefCnt,              0x0377     /* mac_rom */
    .equ    SysBMCPtr,               0x0378     /* mac_rom */
    .equ    SysVolCPtr,              0x037C     /* mac_rom */
    .equ    SysCtlCPtr,              0x0380     /* mac_rom */
    .equ    DefVRefNum,              0x0384     /* mac_rom */
    .equ    PMSPPtr,                 0x0386     /* mac_rom */
    .equ    BufTgHD20,               0x038A     /* mac_rom */
    .equ    BufTgHD20_1,             0x038E     /* mac_rom */
    .equ    HFSDSErr,                0x0392     /* mac_rom */
    .equ    Params,                  0x03A4     /* mac_rom */
    .equ    FSTemp8,                 0x03D6     /* mac_rom */
    .equ    FSTemp4,                 0x03DE     /* mac_rom */
    .equ    FSQueueHook,             0x03E2     /* mac_rom */
    .equ    ExtFSHook,               0x03E6     /* mac_rom */
    .equ    DskSwtchHook,            0x03EA     /* mac_rom */
    .equ    ReqstVol,                0x03EE     /* mac_rom */
    .equ    ToExtFS,                 0x03F2     /* mac_rom */
    .equ    FSFCBLen,                0x03F6     /* file control block length (-1: MFS only) */
    .equ    DSAlertRect,             0x03F8     /* mac_rom */
    .equ    DSAlertRect_botRight,    0x03FC     /* mac_rom */
    .equ    DispatchTab,             0x0400     /* mac_rom */
    .equ    TEFindWord,              0x07F8     /* low-memory hook for TextEdit's FindWord routine (Inside Macintosh VI) */
    .equ    GrafBegin_JHideCursor,   0x0800     /* mac_rom */
    .equ    JShowCursor,             0x0804     /* mac_rom */
    .equ    JShieldCursor,           0x0808     /* mac_rom */
    .equ    JInitCrsr,               0x0814     /* mac_rom */
    .equ    JSetCrsr,                0x0818     /* mac_rom */
    .equ    JCrsrObscure,            0x081C     /* mac_rom */
    .equ    ScrnBase,                0x0824     /* mac_rom */
    .equ    MTemp_v,                 0x0828     /* mac_rom */
    .equ    MTemp_h,                 0x082A     /* mac_rom */
    .equ    RawMouse_v,              0x082C     /* mac_rom */
    .equ    RawMouse_h,              0x082E     /* mac_rom */
    .equ    Mouse_v,                 0x0830     /* mac_rom */
    .equ    Mouse_h,                 0x0832     /* mac_rom */
    .equ    CrsrPin,                 0x0834     /* mac_rom */
    .equ    CrsrRect,                0x083C     /* mac_rom */
    .equ    TheCrsr_data,            0x0844     /* mac_rom */
    .equ    TheCrsr_mask,            0x0864     /* mac_rom */
    .equ    TheCrsr_hotspot_v,       0x0884     /* mac_rom */
    .equ    TheCrsr_hotspot_h,       0x0886     /* mac_rom */
    .equ    CrsrSave,                0x088C     /* mac_rom */
    .equ    JSetCCrsr,               0x0890     /* (long) vector to routine that sets color cursor (MPW LowMemEqu.a) */
    .equ    CrsrBase,                0x0898     /* (long) scrnBase for cursor (MPW LowMemEqu.a) */
    .equ    CrsrDevice,              0x089C     /* (long) current cursor device (MPW LowMemEqu.a) */
    .equ    SrcDevice,               0x08A0     /* (LONG) Src device for Stretchbits (MPW LowMemEqu.a) */
    .equ    MainDevice,              0x08A4     /* (long) the main screen device (MPW LowMemEqu.a) */
    .equ    DeviceList,              0x08A8     /* (long) list of display devices (MPW LowMemEqu.a) */
    .equ    CrsrRow,                 0x08AC     /* (word) rowbytes for current cursor screen (MPW LowMemEqu.a) */
    .equ    QDColors,                0x08B0     /* (long) handle to default colors (MPW LowMemEqu.a) */
    .equ    CrsrVis,                 0x08CC     /* mac_rom */
    .equ    CrsrBusy,                0x08CD     /* mac_rom */
    .equ    CrsrNew,                 0x08CE     /* mac_rom */
    .equ    CrsrCouple,              0x08CF     /* mac_rom */
    .equ    CrsrState,               0x08D0     /* mac_rom */
    .equ    CrsrObscure,             0x08D2     /* mac_rom */
    .equ    MouseMask,               0x08D6     /* mac_rom */
    .equ    MouseOffset,             0x08DA     /* mac_rom */
    .equ    JournalFlag,             0x08DE     /* mac_rom */
    .equ    JSwapFont,               0x08E0     /* mac_rom */
    .equ    WidthListHand,           0x08E4     /* mac_rom */
    .equ    JournalRef,              0x08E8     /* mac_rom */
    .equ    JCrsrTask,               0x08EE     /* mac_rom */
    .equ    WWExist,                 0x08F2     /* mac_rom */
    .equ    QDExist,                 0x08F3     /* mac_rom */
    .equ    JFetch,                  0x08F4     /* I/O vectors: JFetch, JStash, JIODone */
    .equ    JStash,                  0x08F8     /* mac_rom */
    .equ    JIODone,                 0x08FC     /* mac_rom */
    .equ    CurApRefNum,             0x0900     /* mac_rom */
    .equ    LaunchFlag,              0x0902     /* mac_rom */
    .equ    FondState,               0x0903     /* mac_rom */
    .equ    CurrentA5,               0x0904     /* mac_rom */
    .equ    CurStackBase,            0x0908     /* mac_rom */
    .equ    CurApName,               0x0910     /* mac_rom */
    .equ    SaveSegHandle,           0x0930     /* mac_rom */
    .equ    CurJTOffset,             0x0934     /* mac_rom */
    .equ    CurPageOption,           0x0936     /* mac_rom */
    .equ    HiliteMode,              0x0938     /* used for color highlighting (MPW LowMemEqu.a) */
    .equ    LoaderPBlock,            0x093A     /* mac_rom */
    .equ    PrintErr,                0x0944     /* mac_rom */
    .equ    ChooserBits,             0x0946     /* mac_rom */
    .equ    ScrapSize,               0x0960     /* mac_rom */
    .equ    ScrapHandle,             0x0964     /* mac_rom */
    .equ    ScrapState,              0x096A     /* mac_rom */
    .equ    ScrapName,               0x096C     /* mac_rom */
    .equ    ScrapTag,                0x0970     /* mac_rom */
    .equ    ROMFont0,                0x0980     /* mac_rom */
    .equ    ApFontID,                0x0984     /* mac_rom */
    .equ    GotStrike,               0x0986     /* mac_rom */
    .equ    FMDefaultSize,           0x0987     /* mac_rom */
    .equ    CurFMFamily,             0x0988     /* mac_rom */
    .equ    CurFMDevice,             0x098E     /* mac_rom */
    .equ    FOutError,               0x0998     /* mac_rom */
    .equ    FOutFontHandle,          0x099A     /* mac_rom */
    .equ    FOutBold,                0x099E     /* mac_rom */
    .equ    FOutULOffset,            0x09A0     /* mac_rom */
    .equ    FOutShadow,              0x09A3     /* mac_rom */
    .equ    FOutExtra,               0x09A4     /* mac_rom */
    .equ    FOutAscent,              0x09A5     /* mac_rom */
    .equ    FOutUnused,              0x09A9     /* mac_rom */
    .equ    FOutNumer_h,             0x09AA     /* mac_rom */
    .equ    FOutNumer_v,             0x09AC     /* mac_rom */
    .equ    FOutDenom_v,             0x09B0     /* mac_rom */
    .equ    FMDotsPerInch_h,         0x09B2     /* mac_rom */
    .equ    FMDotsPerInch_v,         0x09B4     /* mac_rom */
    .equ    FMStyleTab,              0x09B6     /* mac_rom */
    .equ    ToolScratch,             0x09CE     /* mac_rom */
    .equ    WindowList,              0x09D6     /* mac_rom */
    .equ    SaveUpdate,              0x09DA     /* mac_rom */
    .equ    PaintWhite,              0x09DC     /* erase newly drawn windows? [word] (MPW LowMemEqu.a) */
    .equ    WMgrPort,                0x09DE     /* mac_rom */
    .equ    OldStructure,            0x09E6     /* mac_rom */
    .equ    GrayRgn,                 0x09EE     /* mac_rom */
    .equ    SaveVisRgn,              0x09F2     /* mac_rom */
    .equ    DragHook,                0x09F6     /* mac_rom */
    .equ    Scratch8,                0x09FA     /* 8-byte scratch area */
    .equ    scratch8_2,              0x09FC     /* mac_rom */
    .equ    scratch8_4,              0x09FE     /* mac_rom */
    .equ    scratch8_6,              0x0A00     /* mac_rom */
    .equ    OneOne,                  0x0A02     /* constant 0x00010001 */
    .equ    MinusOne,                0x0A06     /* constant 0xFFFFFFFF */
    .equ    TopMenuItem,             0x0A0A     /* pixel value of top of scrollable menu (MPW LowMemEqu.a) */
    .equ    AtMenuBottom,            0x0A0C     /* pixel value of bottom of scrollable menu (MPW LowMemEqu.a) */
    .equ    IconBitmap,              0x0A0E     /* mac_rom */
    .equ    MenuList,                0x0A1C     /* mac_rom */
    .equ    MBarEnable,              0x0A20     /* mac_rom */
    .equ    CurDeKind,               0x0A22     /* mac_rom */
    .equ    MenuFlash,               0x0A24     /* mac_rom */
    .equ    TheMenu,                 0x0A26     /* mac_rom */
    .equ    SavedHandle,             0x0A28     /* mac_rom */
    .equ    MBarHook,                0x0A2C     /* mac_rom */
    .equ    MenuHook,                0x0A30     /* mac_rom */
    .equ    DragPattern,             0x0A34     /* mac_rom */
    .equ    DragPattern_1,           0x0A38     /* mac_rom */
    .equ    DeskPattern,             0x0A3C     /* mac_rom */
    .equ    DeskPattern_1,           0x0A40     /* mac_rom */
    .equ    DragFlag,                0x0A44     /* mac_rom */
    .equ    CurDragAction,           0x0A46     /* mac_rom */
    .equ    FPState,                 0x0A4A     /* mac_rom */
    .equ    FPHaltVector,            0x0A4C     /* mac_rom */
    .equ    TopMapHndl,              0x0A50     /* mac_rom */
    .equ    SysMapHndl,              0x0A54     /* mac_rom */
    .equ    SysMap,                  0x0A58     /* mac_rom */
    .equ    CurMap,                  0x0A5A     /* mac_rom */
    .equ    ResLoad,                 0x0A5E     /* mac_rom */
    .equ    ResErr,                  0x0A60     /* mac_rom */
    .equ    TaskLock,                0x0A62     /* mac_rom */
    .equ    FScaleDisable,           0x0A63     /* mac_rom */
    .equ    CurActivate,             0x0A64     /* mac_rom */
    .equ    CurDeactive,             0x0A68     /* mac_rom */
    .equ    DeskHook,                0x0A6C     /* mac_rom */
    .equ    TEDoText,                0x0A70     /* mac_rom */
    .equ    TERecal,                 0x0A74     /* mac_rom */
    .equ    GhostWindow,             0x0A84     /* mac_rom */
    .equ    CloseOrnHook,            0x0A88     /* mac_rom */
    .equ    ResumeProc,              0x0A8C     /* mac_rom */
    .equ    ACount,                  0x0A9A     /* mac_rom */
    .equ    DABeeper,                0x0A9C     /* mac_rom */
    .equ    TEScrpLength,            0x0AB0     /* mac_rom */
    .equ    TEScrpHandle,            0x0AB4     /* mac_rom */
    .equ    AppPacks,                0x0AB8     /* mac_rom */
    .equ    AppPacks_5,              0x0ACC     /* mac_rom */
    .equ    SysResName,              0x0AD8     /* mac_rom */
    .equ    AppParmHandle,           0x0AEC     /* mac_rom */
    .equ    DSErrCode,               0x0AF0     /* mac_rom */
    .equ    ResErrProc,              0x0AF2     /* mac_rom */
    .equ    TEWdBreak,               0x0AF6     /* mac_rom */
    .equ    DlgFont,                 0x0AFA     /* default dialog font ID [word] (MPW LowMemEqu.a) */
    .equ    TrapAgain,               0x0B00     /* mac_rom */
    .equ    TrapAgain_1,             0x0B01     /* mac_rom */
    .equ    ROMMapHandle,            0x0B06     /* mac_rom */
    .equ    PWMBuf1,                 0x0B0A     /* PWM buffer 1 */
    .equ    BootMask,                0x0B0E     /* mac_rom */
    .equ    WidthPtr,                0x0B10     /* mac_rom */
    .equ    AtalkHk1,                0x0B14     /* mac_rom */
    .equ    ATalkHk2,                0x0B18     /* mac_rom */
    .equ    HWCfgFlags,              0x0B22     /* hardware configuration flags */
    .equ    TimeSCSIDB,              0x0B24     /* DBRAs and SCSI access per millisecond (MPW LowMemEqu.a) */
    .equ    WidthTabHandle,          0x0B2A     /* font width table handle */
    .equ    SCSIDrvrs,               0x0B2E     /* mac_rom */
    .equ    TimeVars,                0x0B30     /* mac_rom */
    .equ    BtDskRfn,                0x0B34     /* mac_rom */
    .equ    BootTmp8,                0x0B36     /* mac_rom */
    .equ    NTSC,                    0x0B3E     /* A byte (MPW LowMemEqu.a) */
    .equ    T1Arbitrate,             0x0B3F     /* mac_rom */
    .equ    JDiskSel,                0x0B40     /* mac_rom */
    .equ    JSendCmd,                0x0B44     /* mac_rom */
    .equ    JDCDReset,               0x0B48     /* mac_rom */
    .equ    LastSPExtra,             0x0B4C     /* mac_rom */
    .equ    MenuDisable,             0x0B54     /* menuID and Item when disabled item selected (MPW LowMemEqu.a) */
    .equ    BNMQHd,                  0x0B60     /* head of background notification Q (MPW LowMemEqu.a) */
    .equ    RMgrHiVars_LastResType,  0x0B80     /* mac_rom */
    .equ    RMgrLastResHand,         0x0B84     /* mac_rom */
    .equ    RMgrLastResFile,         0x0B98     /* mac_rom */
    .equ    RMgrCurOnly,             0x0B9A     /* mac_rom */
    .equ    RMgrLastCurOnly,         0x0B9B     /* mac_rom */
    .equ    RMgrNextResIndex,        0x0B9C     /* mac_rom */
    .equ    ROMMapInsert,            0x0B9E     /* mac_rom */
    .equ    TmpResLoad,              0x0B9F     /* mac_rom */
    .equ    IntlSpec,                0x0BA0     /* (long) - ptr to extra Intl data (MPW LowMemEqu.a) */
    .equ    RMgrPerm,                0x0BA4     /* mac_rom */
    .equ    WordRedraw,              0x0BA5     /* TextEdit redraw flag */
    .equ    SysFontFam,              0x0BA6     /* system font family */
    .equ    SysFontSize,             0x0BA8     /* mac_rom */
    .equ    MBarHeight,              0x0BAA     /* mac_rom */
    .equ    TESysJust,               0x0BAC     /* system text justification */
    .equ    TESysJust_1,             0x0BAD     /* mac_rom */
    .equ    HighHeapMark,            0x0BAE     /* mac_rom */
    .equ    SegHiEnable,             0x0BB2     /* mac_rom */
    .equ    FDevDisable,             0x0BB3     /* mac_rom */
    .equ    LastFOND,                0x0BC2     /* mac_rom */
    .equ    FONDID,                  0x0BC6     /* mac_rom */
    .equ    App2Packs,               0x0BC8     /* mac_rom */
    .equ    MAErrProc,               0x0BE8     /* mac_rom */
    .equ    MASuperTab,              0x0BEC     /* mac_rom */
    .equ    FractEnable,             0x0BF4     /* mac_rom */
    .equ    UsedFWidth,              0x0BF5     /* mac_rom */
    .equ    FScaleHFact,             0x0BF6     /* mac_rom */
    .equ    FScaleVFact,             0x0BFA     /* mac_rom */
    .equ    ToolDispTable,           0x0C00     /* mac_rom */
    .equ    SCSIDMA,                 0x0C04     /* mac_rom */
    .equ    SCSIHsk,                 0x0C08     /* mac_rom */
    .equ    SCSIGlobals,             0x0C0C     /* mac_rom */
    .equ    RGBBlack,                0x0C10     /* (6 bytes) the black field for color (MPW LowMemEqu.a) */
    .equ    RGBWhite,                0x0C16     /* (6 bytes) the white field for color (MPW LowMemEqu.a) */
    .equ    RowBits,                 0x0C20     /* (word) screen horizontal pixels (MPW LowMemEqu.a) */
    .equ    ColLines,                0x0C22     /* (word) screen vertical pixels (MPW LowMemEqu.a) */
    .equ    ScreenBytes,             0x0C24     /* (long) total screen bytes (MPW LowMemEqu.a) */
    .equ    NMIFlag,                 0x0C2C     /* (byte) flag for NMI debounce (MPW LowMemEqu.a) */
    .equ    SCSIPoll,                0x0C2F     /* mac_rom */
    .equ    SEVarBase,               0x0C30     /* ($0C30-0CB0) 128 bytes for sys err data (MPW LowMemEqu.a) */
    .equ    MMUFlags,                0x0CB0     /* (byte) cleared to zero (reserved for future use) (MPW LowMemEqu.a) */
    .equ    MMUType,                 0x0CB1     /* (byte) kind of MMU present (MPW LowMemEqu.a) */
    .equ    MMU32Bit,                0x0CB2     /* (byte) boolean reflecting current machine MMU mode (MPW LowMemEqu.a) */
    .equ    SInfoPtr,                0x0CBC     /* (long) pointer to Slot manager information (MPW LowMemEqu.a) */
    .equ    ASCBase,                 0x0CC0     /* (long) pointer to Sound Chip (MPW LowMemEqu.a) */
    .equ    SMGlobals,               0x0CC4     /* (long) pointer to Sound Manager Globals (MPW LowMemEqu.a) */
    .equ    TheGDevice,              0x0CC8     /* (long) the current graphics device (MPW LowMemEqu.a) */
    .equ    ghost_AuxWinHead,        0x0CD0     /* mac_rom */
    .equ    ghost_AuxCtlHead,        0x0CD4     /* mac_rom */
    .equ    DeskCPat,                0x0CD8     /* [PixPatHandle] Handle to desk pixPat (MPW LowMemEqu.a) */
    .equ    TimeVIADB,               0x0CEA     /* (word) number of iter's of VIA access & DBRA. (MPW LowMemEqu.a) */
    .equ    ghost_VIA2,              0x0CEC     /* mac_rom */
    .equ    ADBBase,                 0x0CF8     /* mac_rom */
    .equ    WarmStart,               0x0CFC     /* 'WLSC' when the system has been started once */
    .equ    TimeDBRA,                0x0D00     /* mac_rom */
    .equ    TimeSCCDB,               0x0D02     /* mac_rom */
    .equ    PmgrBase,                0x0D18     /* Lomem pointer to power manager vars (MPW LowMemEqu.a) */
    .equ    AGBHandle,               0x0D1C     /* mac_rom */
    .equ    TableSeed,               0x0D20     /* (long) seed value for color table ID's (MPW LowMemEqu.a) */
    .equ    SRsrcTblPtr,             0x0D24     /* (long) pointer to slot resource table. (MPW LowMemEqu.a) */
    .equ    JVBLTask,                0x0D28     /* vector to slot VBL task interrupt handler (MPW LowMemEqu.a) */
    .equ    ghost_WMgrCPort,         0x0D2C     /* mac_rom */
    .equ    SynListHandle,           0x0D32     /* handle to synthetic font list (Inside Macintosh V, MPW LowMem.h) */
    .equ    MenuCInfo,               0x0D50     /* hanel to menu color information table (MPW LowMemEqu.a) */
    .equ    ChunkyDepth,             0x0D60     /* depth of the pixels (MPW LowMemEqu.a) */
    .equ    CrsrPtr,                 0x0D62     /* pointer to cursor save area (MPW LowMemEqu.a) */
    .equ    PortList,                0x0D66     /* list of grafports (MPW LowMemEqu.a) */
    .equ    MickeyBytes,             0x0D6A     /* mac_rom */
    .equ    QDErr,                   0x0D6E     /* QuickDraw error code [word] (MPW LowMemEqu.a) */
    .equ    VIA2DT,                  0x0D70     /* 32 bytes for VIA2 dispatch table for NuMac (MPW LowMemEqu.a) */
    .equ    DTskQHdr,                0x0D94     /* ptr to head of queue (MPW LowMemEqu.a) */
    .equ    JDTInstall,              0x0D9C     /* (long) ptr to deferred task install routine (MPW LowMemEqu.a) */
    .equ    HiliteRGB,               0x0DA0     /* 6 bytes: rgb of hilite color (MPW LowMemEqu.a) */
    .equ    DSCtrAdj,                0x0DA8     /* (long) Center adjust for DS rect. (MPW LowMemEqu.a) */
    .equ    IconTLAddr,              0x0DAC     /* (long) pointer to where start icons are to be put. (MPW LowMemEqu.a) */
    .equ    VideoInfoOK,             0x0DB0     /* (long) Signals to CritErr that the Video card is ok (MPW LowMemEqu.a) */
    .equ    SDMJmpTblPtr,            0x0DB8     /* (long) Pointer to the SDM jump table (MPW LowMemEqu.a) */
    .equ    JSwapMMU,                0x0DBC     /* (long) jump vector to SwapMMU routine (MPW LowMemEqu.a) */
    .equ    LastTxGDevice,           0x0DC4     /* (long) copy of TheGDevice set up for fast text measure (MPW LowMemEqu.a) */
