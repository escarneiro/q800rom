| traps_gas.inc - A-line trap macros used by the ROM source

    .macro  _Open
    .short  0xA000
    .endm
    .macro  _Close
    .short  0xA001
    .endm
    .macro  _Read
    .short  0xA002
    .endm
    .macro  _Write
    .short  0xA003
    .endm
    .macro  _Control
    .short  0xA004
    .endm
    .macro  _Status
    .short  0xA005
    .endm
    .macro  _Create
    .short  0xA008
    .endm
    .macro  _OpenRF
    .short  0xA00A
    .endm
    .macro  _GetFileInfo
    .short  0xA00C
    .endm
    .macro  _SetFileInfo
    .short  0xA00D
    .endm
    .macro  _UnmountVol
    .short  0xA00E
    .endm
    .macro  _MountVol
    .short  0xA00F
    .endm
    .macro  _GetEOF
    .short  0xA011
    .endm
    .macro  _SetEOF
    .short  0xA012
    .endm
    .macro  _FlushVol
    .short  0xA013
    .endm
    .macro  _GetVol
    .short  0xA014
    .endm
    .macro  _SetVol
    .short  0xA015
    .endm
    .macro  _Eject
    .short  0xA017
    .endm
    .macro  _InitZone
    .short  0xA019
    .endm
    .macro  _SetZone
    .short  0xA01B
    .endm
    .macro  _DisposPtr
    .short  0xA01F
    .endm
    .macro  _SetPtrSize
    .short  0xA020
    .endm
    .macro  _GetPtrSize
    .short  0xA021
    .endm
    .macro  _DisposHandle
    .short  0xA023
    .endm
    .macro  _SetHandleSize
    .short  0xA024
    .endm
    .macro  _GetHandleSize
    .short  0xA025
    .endm
    .macro  _ReallocHandle
    .short  0xA027
    .endm
    .macro  _HLock
    .short  0xA029
    .endm
    .macro  _HUnlock
    .short  0xA02A
    .endm
    .macro  _EmptyHandle
    .short  0xA02B
    .endm
    .macro  _InitApplZone
    .short  0xA02C
    .endm
    .macro  _SetApplLimit
    .short  0xA02D
    .endm
    .macro  _BlockMove
    .short  0xA02E
    .endm
    .macro  _PostEvent
    .short  0xA02F
    .endm
    .macro  _OSEventAvail
    .short  0xA030
    .endm
    .macro  _GetOSEvent
    .short  0xA031
    .endm
    .macro  _FlushEvents
    .short  0xA032
    .endm
    .macro  _VInstall
    .short  0xA033
    .endm
    .macro  _VRemove
    .short  0xA034
    .endm
    .macro  _OffLine
    .short  0xA035
    .endm
    .macro  _WriteParam
    .short  0xA038
    .endm
    .macro  _Delay
    .short  0xA03B
    .endm
    .macro  _CmpString
    .short  0xA03C
    .endm
    .macro  _DrvrInstall
    .short  0xA03D
    .endm
    .macro  _DrvrRemove
    .short  0xA03E
    .endm
    .macro  _InitUtil
    .short  0xA03F
    .endm
    .macro  _ResrvMem
    .short  0xA040
    .endm
    .macro  _SetTrapAddress
    .short  0xA047
    .endm
    .macro  _HPurge
    .short  0xA049
    .endm
    .macro  _HNoPurge
    .short  0xA04A
    .endm
    .macro  _SetGrowZone
    .short  0xA04B
    .endm
    .macro  _CompactMem
    .short  0xA04C
    .endm
    .macro  _AddDrive
    .short  0xA04E
    .endm
    .macro  _RDrvrInstall
    .short  0xA04F
    .endm
    .macro  _RelString
    .short  0xA050
    .endm
    .macro  _ReadXPRam
    .short  0xA051
    .endm
    .macro  _WriteXPRam
    .short  0xA052
    .endm
    .macro  _StripAddress
    .short  0xA055
    .endm
    .macro  _SetApplBase
    .short  0xA057
    .endm
    .macro  _InsTime
    .short  0xA058
    .endm
    .macro  _RmvTime
    .short  0xA059
    .endm
    .macro  _PrimeTime
    .short  0xA05A
    .endm
    .macro  _PowerOff
    .short  0xA05B
    .endm
    .macro  _MemoryDispatch
    .short  0xA05C
    .endm
    .macro  _SwapMMUMode
    .short  0xA05D
    .endm
    .macro  _NMInstall
    .short  0xA05E
    .endm
    .macro  _NMRemove
    .short  0xA05F
    .endm
    .macro  _MaxBlock
    .short  0xA061
    .endm
    .macro  _MoveHHi
    .short  0xA064
    .endm
    .macro  _StackSpace
    .short  0xA065
    .endm
    .macro  _HSetRBit
    .short  0xA067
    .endm
    .macro  _HClrRBit
    .short  0xA068
    .endm
    .macro  _HGetState
    .short  0xA069
    .endm
    .macro  _HSetState
    .short  0xA06A
    .endm
    .macro  _InitFS
    .short  0xA06C
    .endm
    .macro  _InitEvents
    .short  0xA06D
    .endm
    .macro  _SlotManager
    .short  0xA06E
    .endm
    .macro  _AttachVBL
    .short  0xA071
    .endm
    .macro  _SIntInstall
    .short  0xA075
    .endm
    .macro  _SIntRemove
    .short  0xA076
    .endm
    .macro  _CountADBs
    .short  0xA077
    .endm
    .macro  _GetIndADB
    .short  0xA078
    .endm
    .macro  _GetADBInfo
    .short  0xA079
    .endm
    .macro  _SetADBInfo
    .short  0xA07A
    .endm
    .macro  _ADBOp
    .short  0xA07C
    .endm
    .macro  _GetDefaultStartup
    .short  0xA07D
    .endm
    .macro  _InternalWait
    .short  0xA07F
    .endm
    .macro  _GetVideoDefault
    .short  0xA080
    .endm
    .macro  _DTInstall
    .short  0xA082
    .endm
    .macro  _GetOSDefault
    .short  0xA084
    .endm
    .macro  _PMgrOp
    .short  0xA085
    .endm
    .macro  _IOPInfoAccess
    .short  0xA086
    .endm
    .macro  _IOPMsgRequest
    .short  0xA087
    .endm
    .macro  _IOPMoveData
    .short  0xA088
    .endm
    .macro  _Sleep
    .short  0xA08A
    .endm
    .macro  _DebugUtil
    .short  0xA08D
    .endm
    .macro  _DeferUserFn
    .short  0xA08F
    .endm
    .macro  _SysEnvirons
    .short  0xA090
    .endm
    .macro  _Translate24To32
    .short  0xA091
    .endm
    .macro  _EgretDispatch
    .short  0xA092
    .endm
    .macro  _PRIVTRAP040
    .short  0xA097
    .endm
    .macro  _PowerDispatch
    .short  0xA09F
    .endm
    .macro  _SoundDispatch
    .short  0xA800
    .endm
    .macro  _SndDisposeChannel
    .short  0xA801
    .endm
    .macro  _SndAddModifier
    .short  0xA802
    .endm
    .macro  _SndDoCommand
    .short  0xA803
    .endm
    .macro  _SndDoImmediate
    .short  0xA804
    .endm
    .macro  _SndPlay
    .short  0xA805
    .endm
    .macro  _SndControl
    .short  0xA806
    .endm
    .macro  _SndNewChannel
    .short  0xA807
    .endm
    .macro  _GetWVariant
    .short  0xA80A
    .endm
    .macro  _RGetResource
    .short  0xA80C
    .endm
    .macro  _Get1IxResource
    .short  0xA80E
    .endm
    .macro  _TEPinScroll
    .short  0xA812
    .endm
    .macro  _TEAutoView
    .short  0xA813
    .endm
    .macro  _SCSIDispatch
    .short  0xA815
    .endm
    .macro  _CopyMask
    .short  0xA817
    .endm
    .macro  _Get1Resource
    .short  0xA81F
    .endm
    .macro  _MaxSizeRsrc
    .short  0xA821
    .endm
    .macro  _AliasDispatch
    .short  0xA823
    .endm
    .macro  _ScrnBitMap
    .short  0xA833
    .endm
    .macro  _GetMaskTable
    .short  0xA836
    .endm
    .macro  _MeasureText
    .short  0xA837
    .endm
    .macro  _FracMul
    .short  0xA84A
    .endm
    .macro  _FixDiv
    .short  0xA84D
    .endm
    .macro  _InitCursor
    .short  0xA850
    .endm
    .macro  _SetCursor
    .short  0xA851
    .endm
    .macro  _HideCursor
    .short  0xA852
    .endm
    .macro  _ShowCursor
    .short  0xA853
    .endm
    .macro  _Random
    .short  0xA861
    .endm
    .macro  _ForeColor
    .short  0xA862
    .endm
    .macro  _BackColor
    .short  0xA863
    .endm
    .macro  _FixMul
    .short  0xA868
    .endm
    .macro  _FixRatio
    .short  0xA869
    .endm
    .macro  _FixRound
    .short  0xA86C
    .endm
    .macro  _InitPort
    .short  0xA86D
    .endm
    .macro  _InitGraf
    .short  0xA86E
    .endm
    .macro  _OpenPort
    .short  0xA86F
    .endm
    .macro  _GlobalToLocal
    .short  0xA871
    .endm
    .macro  _SetPort
    .short  0xA873
    .endm
    .macro  _GetPort
    .short  0xA874
    .endm
    .macro  _MovePortTo
    .short  0xA877
    .endm
    .macro  _SetClip
    .short  0xA879
    .endm
    .macro  _GetClip
    .short  0xA87A
    .endm
    .macro  _ClipRect
    .short  0xA87B
    .endm
    .macro  _BackPat
    .short  0xA87C
    .endm
    .macro  _ClosePort
    .short  0xA87D
    .endm
    .macro  _AddPt
    .short  0xA87E
    .endm
    .macro  _SubPt
    .short  0xA87F
    .endm
    .macro  _DrawChar
    .short  0xA883
    .endm
    .macro  _DrawString
    .short  0xA884
    .endm
    .macro  _DrawText
    .short  0xA885
    .endm
    .macro  _TextWidth
    .short  0xA886
    .endm
    .macro  _TextFont
    .short  0xA887
    .endm
    .macro  _TextFace
    .short  0xA888
    .endm
    .macro  _TextMode
    .short  0xA889
    .endm
    .macro  _GetFontInfo
    .short  0xA88B
    .endm
    .macro  _StringWidth
    .short  0xA88C
    .endm
    .macro  _CharWidth
    .short  0xA88D
    .endm
    .macro  _SpaceExtra
    .short  0xA88E
    .endm
    .macro  _OSDispatch
    .short  0xA88F
    .endm
    .macro  _MoveTo
    .short  0xA893
    .endm
    .macro  _Move
    .short  0xA894
    .endm
    .macro  _ShutDown
    .short  0xA895
    .endm
    .macro  _HidePen
    .short  0xA896
    .endm
    .macro  _ShowPen
    .short  0xA897
    .endm
    .macro  _GetPenState
    .short  0xA898
    .endm
    .macro  _SetPenState
    .short  0xA899
    .endm
    .macro  _GetPen
    .short  0xA89A
    .endm
    .macro  _PenSize
    .short  0xA89B
    .endm
    .macro  _PenMode
    .short  0xA89C
    .endm
    .macro  _PenPat
    .short  0xA89D
    .endm
    .macro  _PenNormal
    .short  0xA89E
    .endm
    .macro  _FrameRect
    .short  0xA8A1
    .endm
    .macro  _PaintRect
    .short  0xA8A2
    .endm
    .macro  _EraseRect
    .short  0xA8A3
    .endm
    .macro  _InverRect
    .short  0xA8A4
    .endm
    .macro  _FillRect
    .short  0xA8A5
    .endm
    .macro  _SetRect
    .short  0xA8A7
    .endm
    .macro  _OffsetRect
    .short  0xA8A8
    .endm
    .macro  _InsetRect
    .short  0xA8A9
    .endm
    .macro  _SectRect
    .short  0xA8AA
    .endm
    .macro  _PtInRect
    .short  0xA8AD
    .endm
    .macro  _FrameRoundRect
    .short  0xA8B0
    .endm
    .macro  _InverRoundRect
    .short  0xA8B3
    .endm
    .macro  _FillRoundRect
    .short  0xA8B4
    .endm
    .macro  _ScriptUtil
    .short  0xA8B5
    .endm
    .macro  _AngleFromSlope
    .short  0xA8C4
    .endm
    .macro  _EraseRgn
    .short  0xA8D4
    .endm
    .macro  _FillRgn
    .short  0xA8D6
    .endm
    .macro  _NewRgn
    .short  0xA8D8
    .endm
    .macro  _DisposRgn
    .short  0xA8D9
    .endm
    .macro  _OpenRgn
    .short  0xA8DA
    .endm
    .macro  _CloseRgn
    .short  0xA8DB
    .endm
    .macro  _CopyRgn
    .short  0xA8DC
    .endm
    .macro  _SetEmptyRgn
    .short  0xA8DD
    .endm
    .macro  _SetRecRgn
    .short  0xA8DE
    .endm
    .macro  _RectRgn
    .short  0xA8DF
    .endm
    .macro  _OffsetRgn
    .short  0xA8E0
    .endm
    .macro  _EmptyRgn
    .short  0xA8E2
    .endm
    .macro  _SectRgn
    .short  0xA8E4
    .endm
    .macro  _UnionRgn
    .short  0xA8E5
    .endm
    .macro  _DiffRgn
    .short  0xA8E6
    .endm
    .macro  _XOrRgn
    .short  0xA8E7
    .endm
    .macro  _PtInRgn
    .short  0xA8E8
    .endm
    .macro  _RectInRgn
    .short  0xA8E9
    .endm
    .macro  _SetStdProcs
    .short  0xA8EA
    .endm
    .macro  _CopyBits
    .short  0xA8EC
    .endm
    .macro  _ScrollRect
    .short  0xA8EF
    .endm
    .macro  _KillPicture
    .short  0xA8F5
    .endm
    .macro  _DrawPicture
    .short  0xA8F6
    .endm
    .macro  _PrGlue
    .short  0xA8FD
    .endm
    .macro  _InitFonts
    .short  0xA8FE
    .endm
    .macro  _GetFNum
    .short  0xA900
    .endm
    .macro  _FMSwapFont
    .short  0xA901
    .endm
    .macro  _NewString
    .short  0xA906
    .endm
    .macro  _SetString
    .short  0xA907
    .endm
    .macro  _ShowHide
    .short  0xA908
    .endm
    .macro  _CalcVBehind
    .short  0xA90A
    .endm
    .macro  _ClipAbove
    .short  0xA90B
    .endm
    .macro  _PaintOne
    .short  0xA90C
    .endm
    .macro  _PaintBehind
    .short  0xA90D
    .endm
    .macro  _SaveOld
    .short  0xA90E
    .endm
    .macro  _GetWMgrPort
    .short  0xA910
    .endm
    .macro  _CheckUpDate
    .short  0xA911
    .endm
    .macro  _InitWindows
    .short  0xA912
    .endm
    .macro  _NewWindow
    .short  0xA913
    .endm
    .macro  _ShowWindow
    .short  0xA915
    .endm
    .macro  _MoveWindow
    .short  0xA91B
    .endm
    .macro  _HiliteWindow
    .short  0xA91C
    .endm
    .macro  _TrackGoAway
    .short  0xA91E
    .endm
    .macro  _SelectWindow
    .short  0xA91F
    .endm
    .macro  _BeginUpDate
    .short  0xA922
    .endm
    .macro  _EndUpDate
    .short  0xA923
    .endm
    .macro  _FrontWindow
    .short  0xA924
    .endm
    .macro  _DragWindow
    .short  0xA925
    .endm
    .macro  _DragTheRgn
    .short  0xA926
    .endm
    .macro  _InvalRgn
    .short  0xA927
    .endm
    .macro  _InvalRect
    .short  0xA928
    .endm
    .macro  _ValidRect
    .short  0xA92A
    .endm
    .macro  _CloseWindow
    .short  0xA92D
    .endm
    .macro  _InitMenus
    .short  0xA930
    .endm
    .macro  _ClearMenuBar
    .short  0xA934
    .endm
    .macro  _InsertMenu
    .short  0xA935
    .endm
    .macro  _DrawMenuBar
    .short  0xA937
    .endm
    .macro  _HiliteMenu
    .short  0xA938
    .endm
    .macro  _GetMenuBar
    .short  0xA93B
    .endm
    .macro  _SetMenuBar
    .short  0xA93C
    .endm
    .macro  _GetItmMark
    .short  0xA943
    .endm
    .macro  _SetItmMark
    .short  0xA944
    .endm
    .macro  _GetItem
    .short  0xA946
    .endm
    .macro  _CalcMenuSize
    .short  0xA948
    .endm
    .macro  _PlotIcon
    .short  0xA94B
    .endm
    .macro  _FlashMenuBar
    .short  0xA94C
    .endm
    .macro  _DeltaPoint
    .short  0xA94F
    .endm
    .macro  _CountMItems
    .short  0xA950
    .endm
    .macro  _UpdtControl
    .short  0xA953
    .endm
    .macro  _NewControl
    .short  0xA954
    .endm
    .macro  _DisposControl
    .short  0xA955
    .endm
    .macro  _KillControls
    .short  0xA956
    .endm
    .macro  _ShowControl
    .short  0xA957
    .endm
    .macro  _HideControl
    .short  0xA958
    .endm
    .macro  _MoveControl
    .short  0xA959
    .endm
    .macro  _SetCTitle
    .short  0xA95F
    .endm
    .macro  _TestControl
    .short  0xA966
    .endm
    .macro  _TrackControl
    .short  0xA968
    .endm
    .macro  _DrawControls
    .short  0xA969
    .endm
    .macro  _FindControl
    .short  0xA96C
    .endm
    .macro  _Draw1Control
    .short  0xA96D
    .endm
    .macro  _Dequeue
    .short  0xA96E
    .endm
    .macro  _Enqueue
    .short  0xA96F
    .endm
    .macro  _GetNextEvent
    .short  0xA970
    .endm
    .macro  _EventAvail
    .short  0xA971
    .endm
    .macro  _GetMouse
    .short  0xA972
    .endm
    .macro  _StillDown
    .short  0xA973
    .endm
    .macro  _Button
    .short  0xA974
    .endm
    .macro  _TickCount
    .short  0xA975
    .endm
    .macro  _GetKeys
    .short  0xA976
    .endm
    .macro  _WaitMouseUp
    .short  0xA977
    .endm
    .macro  _InitDialogs
    .short  0xA97B
    .endm
    .macro  _GetNewDialog
    .short  0xA97C
    .endm
    .macro  _DrawDialog
    .short  0xA981
    .endm
    .macro  _CloseDialog
    .short  0xA982
    .endm
    .macro  _DisposDialog
    .short  0xA983
    .endm
    .macro  _Alert
    .short  0xA985
    .endm
    .macro  _CautionAlert
    .short  0xA988
    .endm
    .macro  _ParamText
    .short  0xA98B
    .endm
    .macro  _GetDItem
    .short  0xA98D
    .endm
    .macro  _SetDItem
    .short  0xA98E
    .endm
    .macro  _SetIText
    .short  0xA98F
    .endm
    .macro  _ModalDialog
    .short  0xA991
    .endm
    .macro  _DetachResource
    .short  0xA992
    .endm
    .macro  _CurResFile
    .short  0xA994
    .endm
    .macro  _InitResources
    .short  0xA995
    .endm
    .macro  _RsrcZoneInit
    .short  0xA996
    .endm
    .macro  _OpenResFile
    .short  0xA997
    .endm
    .macro  _UseResFile
    .short  0xA998
    .endm
    .macro  _UpdateResFile
    .short  0xA999
    .endm
    .macro  _CloseResFile
    .short  0xA99A
    .endm
    .macro  _SetResLoad
    .short  0xA99B
    .endm
    .macro  _CountResources
    .short  0xA99C
    .endm
    .macro  _GetIndResource
    .short  0xA99D
    .endm
    .macro  _GetResource
    .short  0xA9A0
    .endm
    .macro  _GetNamedResource
    .short  0xA9A1
    .endm
    .macro  _LoadResource
    .short  0xA9A2
    .endm
    .macro  _ReleaseResource
    .short  0xA9A3
    .endm
    .macro  _GetResAttrs
    .short  0xA9A6
    .endm
    .macro  _GetResInfo
    .short  0xA9A8
    .endm
    .macro  _ResError
    .short  0xA9AF
    .endm
    .macro  _SystemEvent
    .short  0xA9B2
    .endm
    .macro  _SystemTask
    .short  0xA9B4
    .endm
    .macro  _SystemMenu
    .short  0xA9B5
    .endm
    .macro  _CloseDeskAcc
    .short  0xA9B7
    .endm
    .macro  _GetPattern
    .short  0xA9B8
    .endm
    .macro  _GetCursor
    .short  0xA9B9
    .endm
    .macro  _GetString
    .short  0xA9BA
    .endm
    .macro  _GetIcon
    .short  0xA9BB
    .endm
    .macro  _GetPicture
    .short  0xA9BC
    .endm
    .macro  _GetNewControl
    .short  0xA9BE
    .endm
    .macro  _GetRMenu
    .short  0xA9BF
    .endm
    .macro  _OpenRFPerm
    .short  0xA9C4
    .endm
    .macro  _SysBeep
    .short  0xA9C8
    .endm
    .macro  _SysError
    .short  0xA9C9
    .endm
    .macro  _TEInit
    .short  0xA9CC
    .endm
    .macro  _TEDispose
    .short  0xA9CD
    .endm
    .macro  _TextBox
    .short  0xA9CE
    .endm
    .macro  _TESetText
    .short  0xA9CF
    .endm
    .macro  _TECalText
    .short  0xA9D0
    .endm
    .macro  _TENew
    .short  0xA9D2
    .endm
    .macro  _TEUpdate
    .short  0xA9D3
    .endm
    .macro  _TEClick
    .short  0xA9D4
    .endm
    .macro  _TEActivate
    .short  0xA9D8
    .endm
    .macro  _TEDeactivate
    .short  0xA9D9
    .endm
    .macro  _TEIdle
    .short  0xA9DA
    .endm
    .macro  _TEKey
    .short  0xA9DC
    .endm
    .macro  _TEScroll
    .short  0xA9DD
    .endm
    .macro  _Munger
    .short  0xA9E0
    .endm
    .macro  _HandToHand
    .short  0xA9E1
    .endm
    .macro  _PtrToXHand
    .short  0xA9E2
    .endm
    .macro  _PtrToHand
    .short  0xA9E3
    .endm
    .macro  _HandAndHand
    .short  0xA9E4
    .endm
    .macro  _FP68K
    .short  0xA9EB
    .endm
    .macro  _Pack6
    .short  0xA9ED
    .endm
    .macro  _DECSTR68K
    .short  0xA9EE
    .endm
    .macro  _PtrAndHand
    .short  0xA9EF
    .endm
    .macro  _Launch
    .short  0xA9F2
    .endm
    .macro  _ExitToShell
    .short  0xA9F4
    .endm
    .macro  _LodeScrap
    .short  0xA9FB
    .endm
    .macro  _ZeroScrap
    .short  0xA9FC
    .endm
    .macro  _Debugger
    .short  0xA9FF
    .endm
    .macro  _OpenCPort
    .short  0xAA00
    .endm
    .macro  _NewPixMap
    .short  0xAA03
    .endm
    .macro  _DisposPixPat
    .short  0xAA08
    .endm
    .macro  _GetPixPat
    .short  0xAA0C
    .endm
    .macro  _RGBForeColor
    .short  0xAA14
    .endm
    .macro  _RGBBackColor
    .short  0xAA15
    .endm
    .macro  _GetForeColor
    .short  0xAA19
    .endm
    .macro  _GetBackColor
    .short  0xAA1A
    .endm
    .macro  _GetCIcon
    .short  0xAA1E
    .endm
    .macro  _PlotCIcon
    .short  0xAA1F
    .endm
    .macro  _DisposCIcon
    .short  0xAA25
    .endm
    .macro  _GetMaxDevice
    .short  0xAA27
    .endm
    .macro  _GetCTSeed
    .short  0xAA28
    .endm
    .macro  _NewGDevice
    .short  0xAA2F
    .endm
    .macro  _SetWinColor
    .short  0xAA41
    .endm
    .macro  _GetAuxWin
    .short  0xAA42
    .endm
    .macro  _SetCtlColor
    .short  0xAA43
    .endm
    .macro  _GetAuxCtl
    .short  0xAA44
    .endm
    .macro  _NewCWindow
    .short  0xAA45
    .endm
    .macro  _DockingDispatch
    .short  0xAA57
    .endm
    .macro  _DelMCEntries
    .short  0xAA60
    .endm
    .macro  _GetMCEntry
    .short  0xAA64
    .endm
    .macro  _SetMCEntries
    .short  0xAA65
    .endm
    .macro  _DisposePalette
    .short  0xAA93
    .endm
    .macro  _ActivatePalette
    .short  0xAA94
    .endm
    .macro  _PaletteDispatch
    .short  0xAAA2
    .endm
