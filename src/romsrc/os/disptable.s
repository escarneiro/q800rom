/*
 os/disptable.s - packed trap dispatch table
 From DSPTABLE (0x408D3370). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 The format (from INITDISPATCHER in os/dispatcher.s): one entry per trap, 1024 Toolbox
 traps then 256 OS traps, each the offset of the routine from the previous one:
 0x80 = unimplemented, a byte with bit 7 set = short offset (low 7 bits x 2), two
 bytes = 15-bit offset x 2, 0xFF + long = offset from the ROM start. The routine each
 entry gives is in its comment.
*/

/* DSPTABLE / DISPTABLE: the packed trap dispatch table (offset at ROM header +0x22). */
DSPTABLE:
DISPTABLE:
| packed trap dispatch table (decoded by the code at 0x40809A96; re-encoded after linking by tools/rom_postlink.py)
trap_dispatch_table:
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x04, 0x30, 0x70	| l trap_SndDisposeChannel
    .byte   0x02, 0x30	| w trap_SndAddModifier
    .byte   0x7C, 0x60	| w trap_SndDoCommand
    .byte   0xD8	| b trap_SndDoImmediate
    .byte   0x01, 0x60	| w trap_SndPlay
    .byte   0x01, 0x58	| w trap_SndControl
    .byte   0x7D, 0x80	| w trap_SndNewChannel
    .byte   0xFF, 0x00, 0x01, 0x6D, 0x20	| l trap_InitProcMenu
    .byte   0x78, 0xB2	| w trap_GetCVariant
    .byte   0x17, 0xAA	| w trap_GetWVariant
    .byte   0x72, 0x7D	| w trap_PopUpMenuSelect
    .byte   0x26, 0xD6	| w trap_RGetResource
    .byte   0x79, 0xD5	| w trap_Count1Resources
    .byte   0x95	| b trap_Get1IxResource
    .byte   0xF3	| b trap_Get1IxType
    .byte   0x93	| b trap_Unique1ID
    .byte   0xFF, 0x00, 0x02, 0x51, 0xFE	| l trap_TESelView
    .byte   0x7F, 0xBC	| w trap_TEPinScroll
    .byte   0x00, 0x89	| w trap_TEAutoView
    .byte   0x11, 0xB1	| w trap_SetFractEnable
    .byte   0xFF, 0x00, 0x00, 0x74, 0x60	| l trap_SCSIDispatch
    .byte   0xFF, 0x00, 0x02, 0x62, 0xB6	| l trap_Pack8
    .byte   0xFF, 0x00, 0x03, 0x59, 0x12	| l trap_CopyMask
    .byte   0xFF, 0x00, 0x01, 0xC5, 0xBC	| l trap_FixATan2
    .byte   0x7D, 0x91	| w trap_XMunger
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x7A, 0x08	| w trap_Count1Types
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xD7	| b trap_Get1Resource
    .byte   0xA2	| b trap_Get1NamedResource
    .byte   0x05, 0x3F	| w trap_MaxSizeRsrc
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x5E, 0xB4	| w trap_InsMenuItem
    .byte   0x11, 0xDF	| w trap_HideDItem
    .byte   0xAF	| b trap_ShowDItem
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x02, 0x62, 0xB8	| l trap_Pack9
    .byte   0x81	| b trap_Pack10
    .byte   0x81	| b trap_Pack11
    .byte   0x81	| b trap_Pack12
    .byte   0x81	| b trap_Pack13
    .byte   0x81	| b trap_Pack14
    .byte   0x81	| b trap_Pack15
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x02, 0xEA, 0x80	| l trap_ScrnBitMap
    .byte   0x45, 0xAE	| w trap_SetFScaleDisable
    .byte   0x8B	| b trap_FontMetrics
    .byte   0x3A, 0xFF	| w trap_GetMaskTable
    .byte   0x53, 0x98	| w trap_MeasureText
    .byte   0xFF, 0x00, 0x03, 0x59, 0xC8	| l trap_CalcMask
    .byte   0x7F, 0xFC	| w trap_SeedFill
    .byte   0xFF, 0x00, 0x01, 0x8F, 0x36	| l trap_ZoomWindow
    .byte   0xB7	| b trap_TrackBox
    .byte   0xFF, 0x00, 0x02, 0x59, 0x4E	| l trap_TEGetOffset
    .byte   0x71, 0x59	| w trap_TEDispatch
    .byte   0x74, 0x0E	| w trap_TEStyleNew
    .byte   0x51, 0x89	| w trap_Long2Fix
    .byte   0x7F, 0xF0	| w trap_Fix2Long
    .byte   0x92	| b trap_Fix2Frac
    .byte   0x7F, 0xF0	| w trap_Frac2Fix
    .byte   0x7F, 0xB4	| w trap_Fix2X
    .byte   0x99	| b trap_X2Fix
    .byte   0x7F, 0xEA	| w trap_Frac2X
    .byte   0x99	| b trap_X2Frac
    .byte   0x7F, 0x2E	| w trap_FracCos
    .byte   0x84	| b trap_FracSin
    .byte   0x7F, 0xA0	| w trap_FracSqrt
    .byte   0x7F, 0x5B	| w trap_FracMul
    .byte   0xFA	| b trap_FracDiv
    .byte   0x80	| unimplemented
    .byte   0x83	| b trap_FixDiv
    .byte   0x5A, 0xD3	| w trap_GetItemCmd
    .byte   0x82	| b trap_SetItemCmd
    .byte   0xFF, 0x00, 0x02, 0x80, 0xA0	| l trap_InitCursor
    .byte   0x90	| b trap_SetCursor
    .byte   0x98	| b trap_HideCursor
    .byte   0x88	| b trap_ShowCursor
    .byte   0x80	| unimplemented
    .byte   0x88	| b trap_ShieldCursor
    .byte   0x98	| b trap_ObscureCursor
    .byte   0x80	| unimplemented
    .byte   0x34, 0xC0	| w trap_BitAnd
    .byte   0x84	| b trap_BitXOr
    .byte   0x7F, 0xF4	| w trap_BitNot
    .byte   0x91	| b trap_BitOr
    .byte   0x84	| b trap_BitShift
    .byte   0x8B	| b trap_BitTst
    .byte   0x87	| b trap_BitSet
    .byte   0x85	| b trap_BitClr
    .byte   0xFF, 0x00, 0x01, 0x5C, 0xD0	| l trap_WaitNextEvent
    .byte   0xFF, 0x00, 0x02, 0xEB, 0x20	| l trap_Random
    .byte   0xB0	| b trap_ForeColor
    .byte   0xA6	| b trap_BackColor
    .byte   0x88	| b trap_ColorBit
    .byte   0x01, 0xD0	| w trap_GetPixel
    .byte   0x00, 0xAA	| w trap_StuffHex
    .byte   0xFF, 0x00, 0x01, 0xC2, 0xEE	| l trap_LongMul
    .byte   0x92	| b trap_FixMul
    .byte   0x00, 0xBF	| w trap_FixRatio
    .byte   0xAD	| b trap_HiWord
    .byte   0x7F, 0xFC	| w trap_LoWord
    .byte   0x89	| b trap_FixRound
    .byte   0xFF, 0x00, 0x03, 0x16, 0xEE	| l trap_InitPort
    .byte   0x7F, 0x21	| w trap_InitGraf
    .byte   0x00, 0xD8	| w trap_OpenPort
    .byte   0x00, 0x90	| w trap_LocalToGlobal
    .byte   0x84	| b trap_GlobalToLocal
    .byte   0xBC	| b trap_GrafDevice
    .byte   0x7F, 0xF0	| w trap_SetPort
    .byte   0x84	| b trap_GetPort
    .byte   0x94	| b trap_SetPBits
    .byte   0xA8	| b trap_PortSize
    .byte   0x90	| b trap_MovePortTo
    .byte   0x98	| b trap_SetOrigin
    .byte   0xB0	| b trap_SetClip
    .byte   0x86	| b trap_GetClip
    .byte   0x7F, 0xEA	| w trap_ClipRect
    .byte   0x7F, 0x9F	| w trap_BackPat
    .byte   0x74, 0x99	| w trap_ClosePort
    .byte   0x0B, 0x2D	| w trap_AddPt
    .byte   0x84	| b trap_SubPt
    .byte   0x00, 0xB7	| w trap_SetPt
    .byte   0x88	| b trap_EqualPt
    .byte   0xFF, 0x00, 0x02, 0x8E, 0x40	| l trap_StdText
    .byte   0x01, 0x7E	| w trap_DrawChar
    .byte   0xB0	| b trap_DrawString
    .byte   0x89	| b trap_DrawText
    .byte   0x99	| b trap_TextWidth
    .byte   0x7F, 0xC8	| w trap_TextFont
    .byte   0x7F, 0xE0	| w trap_TextFace
    .byte   0xA2	| b trap_TextMode
    .byte   0x82	| b trap_TextSize
    .byte   0x01, 0x54	| w trap_GetFontInfo
    .byte   0x7E, 0xD8	| w trap_StringWidth
    .byte   0x7F, 0xBD	| w trap_CharWidth
    .byte   0xA3	| b trap_SpaceExtra
    .byte   0x80	| unimplemented
    .byte   0x01, 0xF8	| w trap_StdLine
    .byte   0xF8	| b trap_LineTo
    .byte   0x90	| b trap_Line
    .byte   0x90	| b trap_MoveTo
    .byte   0x90	| b trap_Move
    .byte   0xFF, 0x00, 0x00, 0xED, 0x7E	| l trap_ShutDown
    .byte   0xFF, 0x00, 0x02, 0x97, 0x80	| l trap_HidePen
    .byte   0x82	| b trap_ShowPen
    .byte   0x86	| b trap_GetPenState
    .byte   0x9E	| b trap_SetPenState
    .byte   0xA2	| b trap_GetPen
    .byte   0x88	| b trap_PenSize
    .byte   0x88	| b trap_PenMode
    .byte   0x88	| b trap_PenPat
    .byte   0x94	| b trap_PenNormal
    .byte   0x80	| unimplemented
    .byte   0x14, 0x74	| w trap_StdRect
    .byte   0x01, 0x9C	| w trap_FrameRect
    .byte   0x82	| b trap_PaintRect
    .byte   0x82	| b trap_EraseRect
    .byte   0x82	| b trap_InverRect
    .byte   0x7F, 0xEE	| w trap_FillRect
    .byte   0x00, 0xE0	| w trap_EqualRect
    .byte   0x7F, 0xF8	| w trap_SetRect
    .byte   0xA8	| b trap_OffsetRect
    .byte   0x90	| b trap_InsetRect
    .byte   0x90	| b trap_SectRect
    .byte   0xD0	| b trap_UnionRect
    .byte   0x9F	| b trap_Pt2Rect
    .byte   0xA1	| b trap_PtInRect
    .byte   0x7F, 0x40	| w trap_EmptyRect
    .byte   0x3F, 0x90	| w trap_StdRRect
    .byte   0xE0	| b trap_FrameRoundRect
    .byte   0x82	| b trap_PaintRoundRect
    .byte   0x82	| b trap_EraseRoundRect
    .byte   0x82	| b trap_InverRoundRect
    .byte   0x82	| b trap_FillRoundRect
    .byte   0xFF, 0x00, 0x01, 0xE3, 0x18	| l trap_ScriptUtil
    .byte   0xFF, 0x00, 0x03, 0xBA, 0x20	| l trap_StdOval
    .byte   0xE0	| b trap_FrameOval
    .byte   0x82	| b trap_PaintOval
    .byte   0x82	| b trap_EraseOval
    .byte   0x82	| b trap_InvertOval
    .byte   0x82	| b trap_FillOval
    .byte   0x09, 0xB7	| w trap_SlopeFromAngle
    .byte   0x76, 0x69	| w trap_StdArc
    .byte   0xD8	| b trap_FrameArc
    .byte   0x82	| b trap_PaintArc
    .byte   0x82	| b trap_EraseArc
    .byte   0x82	| b trap_InvertArc
    .byte   0x82	| b trap_FillArc
    .byte   0x09, 0xD0	| w trap_PtToAngle
    .byte   0x7F, 0x48	| w trap_AngleFromSlope
    .byte   0xFF, 0x00, 0x03, 0x3B, 0x30	| l trap_StdPoly
    .byte   0xE0	| b trap_FramePoly
    .byte   0x82	| b trap_PaintPoly
    .byte   0x82	| b trap_ErasePoly
    .byte   0x82	| b trap_InvertPoly
    .byte   0x82	| b trap_FillPoly
    .byte   0xA0	| b trap_OpenPoly
    .byte   0xA0	| b trap_ClosePgon
    .byte   0xB8	| b trap_KillPoly
    .byte   0x88	| b trap_OffsetPoly
    .byte   0x0F, 0xB0	| w trap_PackBits
    .byte   0xDA	| b trap_UnpackBits
    .byte   0x00, 0xAE	| w trap_StdRgn
    .byte   0xD0	| b trap_FrameRgn
    .byte   0x82	| b trap_PaintRgn
    .byte   0x82	| b trap_EraseRgn
    .byte   0x82	| b trap_InverRgn
    .byte   0x82	| b trap_FillRgn
    .byte   0x03, 0xE8	| w trap_BitMapRgn
    .byte   0x7C, 0xA8	| w trap_NewRgn
    .byte   0x90	| b trap_DisposRgn
    .byte   0x88	| b trap_OpenRgn
    .byte   0x98	| b trap_CloseRgn
    .byte   0xB8	| b trap_CopyRgn
    .byte   0xA8	| b trap_SetEmptyRgn
    .byte   0x88	| b trap_SetRecRgn
    .byte   0xB0	| b trap_RectRgn
    .byte   0x88	| b trap_OffsetRgn
    .byte   0xA0	| b trap_InsetRgn
    .byte   0xD8	| b trap_EmptyRgn
    .byte   0x90	| b trap_EqualRgn
    .byte   0xA0	| b trap_SectRgn
    .byte   0x82	| b trap_UnionRgn
    .byte   0x82	| b trap_DiffRgn
    .byte   0x82	| b trap_XOrRgn
    .byte   0xFA	| b trap_PtInRgn
    .byte   0xB0	| b trap_RectInRgn
    .byte   0x59, 0x88	| w trap_SetStdProcs
    .byte   0x1B, 0x78	| w trap_StdBits
    .byte   0x04, 0x18	| w trap_CopyBits
    .byte   0xFF, 0x00, 0x02, 0x92, 0x50	| l trap_StdTxMeas
    .byte   0xFF, 0x00, 0x03, 0x1A, 0x90	| l trap_StdGetPic
    .byte   0x20, 0x48	| w trap_ScrollRect
    .byte   0x5F, 0xC8	| w trap_StdPutPic
    .byte   0x7F, 0xC0	| w trap_StdComment
    .byte   0x00, 0xA8	| w trap_PicComment
    .byte   0x98	| b trap_OpenPicture
    .byte   0x00, 0xB8	| w trap_ClosePicture
    .byte   0xB8	| b trap_KillPicture
    .byte   0x88	| b trap_DrawPicture
    .byte   0x80	| unimplemented
    .byte   0x0E, 0x00	| w trap_ScalePt
    .byte   0xB0	| b trap_MapPt
    .byte   0xE0	| b trap_MapRect
    .byte   0x15, 0xB8	| w trap_MapRgn
    .byte   0x6B, 0x78	| w trap_MapPoly
    .byte   0xFF, 0x00, 0x02, 0x5F, 0x40	| l trap_PrGlue
    .byte   0x02, 0x38	| w trap_InitFonts
    .byte   0x08, 0x74	| w trap_GetFName
    .byte   0xEC	| b trap_GetFNum
    .byte   0x77, 0xD2	| w trap_FMSwapFont
    .byte   0x07, 0xF9	| w trap_RealFont
    .byte   0xD7	| b trap_SetFontLock
    .byte   0xFF, 0x00, 0x01, 0x96, 0xCC	| l trap_DrawGrowIcon
    .byte   0x7D, 0xE6	| w trap_DragGrayRgn
    .byte   0x77, 0xCC	| w trap_NewString
    .byte   0x8C	| b trap_SetString
    .byte   0x01, 0x9A	| w trap_ShowHide
    .byte   0x7E, 0xA0	| w trap_CalcVis
    .byte   0xAF	| b trap_CalcVBehind
    .byte   0xA2	| b trap_ClipAbove
    .byte   0x92	| b trap_PaintOne
    .byte   0x00, 0x84	| w trap_PaintBehind
    .byte   0xB2	| b trap_SaveOld
    .byte   0x97	| b trap_DrawNew
    .byte   0xD6	| b trap_GetWMgrPort
    .byte   0x8A	| b trap_CheckUpDate
    .byte   0xCF	| b trap_InitWindows
    .byte   0x00, 0xFB	| w trap_NewWindow
    .byte   0x01, 0x39	| w trap_DisposWindow
    .byte   0x87	| b trap_ShowWindow
    .byte   0x94	| b trap_HideWindow
    .byte   0x95	| b trap_GetWRefCon
    .byte   0x87	| b trap_SetWRefCon
    .byte   0x8E	| b trap_GetWTitle
    .byte   0x8C	| b trap_SetWTitle
    .byte   0xED	| b trap_MoveWindow
    .byte   0x01, 0x20	| w trap_HiliteWindow
    .byte   0xA0	| b trap_SizeWindow
    .byte   0xDF	| b trap_TrackGoAway
    .byte   0xBC	| b trap_SelectWindow
    .byte   0x9A	| b trap_BringToFront
    .byte   0xD1	| b trap_SendBehind
    .byte   0xAB	| b trap_BeginUpDate
    .byte   0xA2	| b trap_EndUpDate
    .byte   0x94	| b trap_FrontWindow
    .byte   0x95	| b trap_DragWindow
    .byte   0xE7	| b trap_DragTheRgn
    .byte   0x01, 0x07	| w trap_InvalRgn
    .byte   0xA3	| b trap_InvalRect
    .byte   0x8F	| b trap_ValidRgn
    .byte   0x82	| b trap_ValidRect
    .byte   0x82	| b trap_GrowWindow
    .byte   0x00, 0x95	| w trap_FindWindow
    .byte   0x79, 0xC7	| w trap_CloseWindow
    .byte   0x00, 0xC5	| w trap_SetWindowPic
    .byte   0x83	| b trap_GetWindowPic
    .byte   0x70, 0xF5	| w trap_InitMenus
    .byte   0x08, 0x0E	| w trap_NewMenu
    .byte   0x7D, 0x85	| w trap_DisposMenu
    .byte   0x02, 0xA4	| w trap_AppendMenu
    .byte   0x78, 0x71	| w trap_ClearMenuBar
    .byte   0x93	| b trap_InsertMenu
    .byte   0xFE	| b trap_DeleteMenu
    .byte   0xFA	| b trap_DrawMenuBar
    .byte   0x8F	| b trap_HiliteMenu
    .byte   0xA9	| b trap_EnableItem
    .byte   0x91	| b trap_DisableItem
    .byte   0x03, 0x68	| w trap_GetMenuBar
    .byte   0x95	| b trap_SetMenuBar
    .byte   0x7C, 0xA6	| w trap_MenuSelect
    .byte   0x04, 0xFF	| w trap_MenuKey
    .byte   0x7F, 0x0C	| w trap_GetItmIcon
    .byte   0x82	| b trap_SetItmIcon
    .byte   0x86	| b trap_GetItmStyle
    .byte   0x82	| b trap_SetItmStyle
    .byte   0x82	| b trap_GetItmMark
    .byte   0x82	| b trap_SetItmMark
    .byte   0x82	| b trap_CheckItem
    .byte   0x01, 0x8C	| w trap_GetItem
    .byte   0x01, 0x75	| w trap_SetItem
    .byte   0x7E, 0xB6	| w trap_CalcMenuSize
    .byte   0x01, 0x13	| w trap_GetMHandle
    .byte   0xDA	| b trap_SetMFlash
    .byte   0x00, 0xC6	| w trap_PlotIcon
    .byte   0x7B, 0x80	| w trap_FlashMenuBar
    .byte   0x03, 0xBF	| w trap_AddResMenu
    .byte   0xFF, 0x00, 0x02, 0xE2, 0x00	| l trap_PinRect
    .byte   0xFF, 0x00, 0x01, 0x8C, 0x02	| l trap_DeltaPoint
    .byte   0x7A, 0xBD	| w trap_CountMItems
    .byte   0x7F, 0x51	| w trap_InsertResMenu
    .byte   0x7F, 0xB1	| w trap_DelMenuItem
    .byte   0x71, 0xD2	| w trap_UpdtControl
    .byte   0x7D, 0x16	| w trap_NewControl
    .byte   0x00, 0xD4	| w trap_DisposControl
    .byte   0xC0	| b trap_KillControls
    .byte   0x91	| b trap_ShowControl
    .byte   0x8F	| b trap_HideControl
    .byte   0x8A	| b trap_MoveControl
    .byte   0x9F	| b trap_GetCRefCon
    .byte   0x87	| b trap_SetCRefCon
    .byte   0x8C	| b trap_SizeControl
    .byte   0x94	| b trap_HiliteControl
    .byte   0x96	| b trap_GetCTitle
    .byte   0x8C	| b trap_SetCTitle
    .byte   0xA1	| b trap_GetCtlValue
    .byte   0x87	| b trap_GetMinCtl
    .byte   0x82	| b trap_GetMaxCtl
    .byte   0x82	| b trap_SetCtlValue
    .byte   0xA1	| b trap_SetMinCtl
    .byte   0x82	| b trap_SetMaxCtl
    .byte   0x82	| b trap_TestControl
    .byte   0x97	| b trap_DragControl
    .byte   0xE5	| b trap_TrackControl
    .byte   0x00, 0x7F	| w trap_DrawControls
    .byte   0x7E, 0x7A	| w trap_GetCtlAction
    .byte   0x82	| b trap_SetCtlAction
    .byte   0x01, 0xC8	| w trap_FindControl
    .byte   0x7D, 0xE7	| w trap_Draw1Control
    .byte   0xFF, 0x00, 0x00, 0x99, 0x56	| l trap_Dequeue
    .byte   0x7F, 0xED	| w trap_Enqueue
    .byte   0xFF, 0x00, 0x01, 0x5A, 0xA0	| l trap_GetNextEvent
    .byte   0x7F, 0xFE	| w trap_EventAvail
    .byte   0x7F, 0xD2	| w trap_GetMouse
    .byte   0x8B	| b trap_StillDown
    .byte   0x7F, 0xCB	| w trap_Button
    .byte   0x89	| b trap_TickCount
    .byte   0x7F, 0xE9	| w trap_GetKeys
    .byte   0xD7	| b trap_WaitMouseUp
    .byte   0x21, 0x94	| w trap_UpdtDialog
    .byte   0x00, 0x90	| w trap_COULDDIALOG
    .byte   0xDD	| b trap_FREEDIALOG
    .byte   0x7C, 0xA5	| w trap_InitDialogs
    .byte   0x01, 0x17	| w trap_GetNewDialog
    .byte   0xCE	| b trap_NewDialog
    .byte   0x02, 0xCA	| w trap_SelIText
    .byte   0x7D, 0x9F	| w trap_IsDialogEvent
    .byte   0x9E	| b trap_DialogSelect
    .byte   0xF6	| b trap_DrawDialog
    .byte   0xA0	| b trap_CloseDialog
    .byte   0xC2	| b trap_DisposDialog
    .byte   0x02, 0x02	| w trap_FindDItem
    .byte   0x7B, 0x9B	| w trap_Alert
    .byte   0x7F, 0xFA	| w trap_StopAlert
    .byte   0x82	| b trap_NoteAlert
    .byte   0x82	| b trap_CautionAlert
    .byte   0x02, 0xA6	| w trap_COULDALERT
    .byte   0xDD	| b trap_FREEALERT
    .byte   0xB2	| b trap_ParamText
    .byte   0x92	| b trap_ErrorSound
    .byte   0x84	| b trap_GetDItem
    .byte   0xA3	| b trap_SetDItem
    .byte   0xAC	| b trap_SetIText
    .byte   0x7F, 0xF0	| w trap_GetIText
    .byte   0x7E, 0x24	| w trap_ModalDialog
    .byte   0x0F, 0x91	| w trap_DetachResource
    .byte   0xDC	| b trap_SetResPurge
    .byte   0x95	| b trap_CurResFile
    .byte   0x76, 0xA5	| w trap_InitResources
    .byte   0x02, 0x47	| w trap_RsrcZoneInit
    .byte   0xEF	| b trap_OpenResFile
    .byte   0xA2	| b trap_UseResFile
    .byte   0xE6	| b trap_UpdateResFile
    .byte   0x01, 0x6D	| w trap_CloseResFile
    .byte   0x04, 0xAB	| w trap_SetResLoad
    .byte   0x7B, 0xA7	| w trap_CountResources
    .byte   0x95	| b trap_GetIndResource
    .byte   0xCE	| b trap_CountTypes
    .byte   0xA5	| b trap_GetIndType
    .byte   0xB2	| b trap_GetResource
    .byte   0xA2	| b trap_GetNamedResource
    .byte   0x02, 0xDD	| w trap_LoadResource
    .byte   0x9F	| b trap_ReleaseResource
    .byte   0xDC	| b trap_HomeResFile
    .byte   0x01, 0xD4	| w trap_SizeRsrc
    .byte   0x7E, 0x6B	| w trap_GetResAttrs
    .byte   0x8A	| b trap_SetResAttrs
    .byte   0x99	| b trap_GetResInfo
    .byte   0xA3	| b trap_SetResInfo
    .byte   0x7F, 0x40	| w trap_ChangedResource
    .byte   0x00, 0xE5	| w trap_AddResource
    .byte   0x7F, 0x88	| w trap_AddReference
    .byte   0x00, 0xE4	| w trap_RmveResource
    .byte   0x7F, 0x24	| w trap_RmveReference
    .byte   0x7F, 0xF4	| w trap_ResError
    .byte   0x7F, 0xB5	| w trap_WriteResource
    .byte   0x79, 0x7D	| w trap_CreateResFile
    .byte   0x0B, 0xFE	| w trap_SystemEvent
    .byte   0xEE	| b trap_SystemClick
    .byte   0xEA	| b trap_SystemTask
    .byte   0xC0	| b trap_SystemMenu
    .byte   0xBB	| b trap_OpenDeskAcc
    .byte   0xA7	| b trap_CloseDeskAcc
    .byte   0x29, 0x06	| w trap_GetPattern
    .byte   0x8D	| b trap_GetCursor
    .byte   0x87	| b trap_GetString
    .byte   0x84	| b trap_GetIcon
    .byte   0x84	| b trap_GetPicture
    .byte   0x8A	| b trap_GetNewWindow
    .byte   0xD4	| b trap_GetNewControl
    .byte   0xC1	| b trap_GetRMenu
    .byte   0xDD	| b trap_GetNewMBar
    .byte   0x4B, 0x71	| w trap_UniqueID
    .byte   0x0A, 0x33	| w trap_SysEdit
    .byte   0xFF, 0x00, 0x00, 0xAD, 0x7A	| l trap_KeyTrans
    .byte   0xFF, 0x00, 0x01, 0xAF, 0xCE	| l trap_OpenRFPerm
    .byte   0x08, 0x52	| w trap_RsrcMapEntry
    .byte   0xFF, 0x00, 0x02, 0x62, 0xD0	| l trap_Secs2Date
    .byte   0xBC	| b trap_Date2Secs
    .byte   0xFF, 0x00, 0x00, 0x6F, 0xC0	| l trap_SysBeep
    .byte   0x5B, 0xB0	| w trap_SysError
    .byte   0x7F, 0x02	| w trap_PutIcon
    .byte   0xFF, 0x00, 0x02, 0x20, 0x38	| l trap_TEGetText
    .byte   0x7F, 0xAD	| w trap_TEInit
    .byte   0xD9	| b trap_TEDispose
    .byte   0xAF	| b trap_TextBox
    .byte   0xF0	| b trap_TESetText
    .byte   0x00, 0x8C	| w trap_TECalText
    .byte   0xB2	| b trap_TESetSelect
    .byte   0xA3	| b trap_TENew
    .byte   0x00, 0xF9	| w trap_TEUpdate
    .byte   0x97	| b trap_TEClick
    .byte   0x0B, 0x5A	| w trap_TECopy
    .byte   0xEC	| b trap_TECut
    .byte   0x88	| b trap_TEDelete
    .byte   0x05, 0x0F	| w trap_TEActivate
    .byte   0x91	| b trap_TEDeactivate
    .byte   0x8C	| b trap_TEIdle
    .byte   0x9F	| b trap_TEPaste
    .byte   0x01, 0xD6	| w trap_TEKey
    .byte   0x02, 0xEF	| w trap_TEScroll
    .byte   0x7C, 0xFA	| w trap_TEInsert
    .byte   0x02, 0xF2	| w trap_TESetJust
    .byte   0xFF, 0x00, 0x01, 0xC0, 0xB0	| l trap_Munger
    .byte   0x00, 0xB2	| w trap_HandToHand
    .byte   0x94	| b trap_PtrToXHand
    .byte   0x84	| b trap_PtrToHand
    .byte   0x8D	| b trap_HandAndHand
    .byte   0xFF, 0x00, 0x02, 0x61, 0xC0	| l trap_InitPack
    .byte   0x91	| b trap_InitAllPacks
    .byte   0xE2	| b trap_Pack0
    .byte   0x81	| b trap_Pack1
    .byte   0x81	| b trap_Pack2
    .byte   0x81	| b trap_Pack3
    .byte   0x7F, 0xAD	| w trap_FP68K
    .byte   0x91	| b trap_Elems68K
    .byte   0xC5	| b trap_Pack6
    .byte   0x81	| b trap_DECSTR68K
    .byte   0xFF, 0x00, 0x01, 0xC2, 0x82	| l trap_PtrAndHand
    .byte   0xFF, 0x00, 0x00, 0xBC, 0xE0	| l trap_LoadSeg
    .byte   0xC9	| b trap_UnLoadSeg
    .byte   0xCC	| b trap_Launch
    .byte   0x7F, 0xFD	| w trap_Chain
    .byte   0x00, 0xA8	| w trap_ExitToShell
    .byte   0xB6	| b trap_GetAppParms
    .byte   0xFF, 0x00, 0x01, 0xAF, 0xEC	| l trap_GetResFileAttrs
    .byte   0x86	| b trap_SetResFileAttrs
    .byte   0x09, 0x4D	| w trap_MethodDispatch
    .byte   0xFF, 0x00, 0x02, 0x5D, 0x50	| l trap_InfoScrap
    .byte   0xBD	| b trap_UnlodeScrap
    .byte   0x9B	| b trap_LodeScrap
    .byte   0x9A	| b trap_ZeroScrap
    .byte   0xA6	| b trap_GetScrap
    .byte   0xB8	| b trap_PutScrap
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x03, 0x00, 0xF0	| l trap_OpenCPort
    .byte   0x9B	| b trap_InitCPort
    .byte   0xDD	| b trap_ClosePort
    .byte   0x00, 0x88	| w trap_NewPixMap
    .byte   0x88	| b trap_DisposPixMap
    .byte   0xB0	| b trap_CopyPixMap
    .byte   0x7F, 0x80	| w trap_SetPortPix
    .byte   0x02, 0x18	| w trap_NewPixPat
    .byte   0xB8	| b trap_DisposPixPat
    .byte   0x00, 0xA0	| w trap_CopyPixPat
    .byte   0x7F, 0xC0	| w trap_PenPixPat
    .byte   0x86	| b trap_BackPixPat
    .byte   0x7E, 0xDA	| w trap_GetPixPat
    .byte   0x05, 0xD0	| w trap_MakeRGBPat
    .byte   0x59, 0xAA	| w trap_FillCRect
    .byte   0xFF, 0x00, 0x03, 0xBA, 0xF4	| l trap_FillCOval
    .byte   0x45, 0xA8	| w trap_FillCRoundRect
    .byte   0x3A, 0xD8	| w trap_FillCArc
    .byte   0x51, 0x98	| w trap_FillCRgn
    .byte   0x6E, 0x70	| w trap_FillCPoly
    .byte   0xFF, 0x00, 0x03, 0xC5, 0x50	| l trap_RGBForeColor
    .byte   0xCB	| b trap_RGBBackColor
    .byte   0xFF, 0x00, 0x03, 0x04, 0xE0	| l trap_SetCPixel
    .byte   0x75, 0x48	| w trap_GetCPixel
    .byte   0xFF, 0x00, 0x03, 0xCD, 0x86	| l trap_GetCTable
    .byte   0x7C, 0x35	| w trap_GetForeColor
    .byte   0xA1	| b trap_GetBackColor
    .byte   0xFF, 0x00, 0x03, 0x05, 0x70	| l trap_GetCCursor
    .byte   0xFF, 0x00, 0x02, 0x80, 0xE0	| l trap_SetCCursor
    .byte   0x7F, 0xD8	| w trap_AllocCursor
    .byte   0xFF, 0x00, 0x03, 0x11, 0xE0	| l trap_GetCIcon
    .byte   0xE0	| b trap_PlotCIcon
    .byte   0x04, 0x80	| w trap_OpenCPicture
    .byte   0x74, 0xD8	| w trap_OpColor
    .byte   0x7F, 0xF8	| w trap_HiliteColor
    .byte   0x47, 0xF8	| w trap_CharExtra
    .byte   0x36, 0xB0	| w trap_DisposCTable
    .byte   0x08, 0xB8	| w trap_DisposCIcon
    .byte   0x79, 0x80	| w trap_DisposPixPat
    .byte   0xFF, 0x00, 0x02, 0x80, 0x20	| l trap_GetMaxDevice
    .byte   0xFF, 0x00, 0x03, 0x02, 0xA0	| l trap_GetCTSeed
    .byte   0xFF, 0x00, 0x02, 0x7F, 0xB0	| l trap_GetDeviceList
    .byte   0x88	| b trap_GetMainDevice
    .byte   0x88	| b trap_GetNextDevice
    .byte   0x88	| b trap_TestDeviceAttribute
    .byte   0x90	| b trap_SetDeviceAttribute
    .byte   0x7C, 0x68	| w trap_InitGDevice
    .byte   0x7F, 0x88	| w trap_NewGDevice
    .byte   0xD0	| b trap_DisposGDevice
    .byte   0x03, 0x90	| w trap_SetGDevice
    .byte   0x7F, 0xF8	| w trap_GetGDevice
    .byte   0xFF, 0x00, 0x03, 0xC3, 0xC8	| l trap_Color2Index
    .byte   0xCC	| b trap_Index2Color
    .byte   0xD0	| b trap_InvertColor
    .byte   0x00, 0xA0	| w trap_RealColor
    .byte   0x02, 0x70	| w trap_GetSubTable
    .byte   0x79, 0x48	| w trap_UpdatePixMap
    .byte   0x88	| b trap_MakeITable
    .byte   0x06, 0x48	| w trap_AddSearch
    .byte   0x9D	| b trap_AddComp
    .byte   0x7F, 0xDB	| w trap_SetClientID
    .byte   0x7F, 0xC0	| w trap_ProtectEntry
    .byte   0xA9	| b trap_ReserveEntry
    .byte   0x7E, 0x57	| w trap_SetEntries
    .byte   0x02, 0x90	| w trap_QDError
    .byte   0xFF, 0x00, 0x01, 0x97, 0x36	| l trap_SetWinColor
    .byte   0x00, 0xA4	| w trap_GetAuxWin
    .byte   0x7F, 0x88	| w trap_SetCtlColor
    .byte   0xFB	| b trap_GetAuxCtl
    .byte   0x77, 0xED	| w trap_NewCWindow
    .byte   0xFF, 0x00, 0x02, 0x1C, 0x90	| l trap_GetNewCWindow
    .byte   0xFF, 0x00, 0x01, 0x96, 0xEA	| l trap_SetDeskCPat
    .byte   0x77, 0x74	| w trap_GetCWMgrPort
    .byte   0xFF, 0x00, 0x03, 0xC9, 0x20	| l trap_SaveEntries
    .byte   0x7F, 0x70	| w trap_RestoreEntries
    .byte   0xFF, 0x00, 0x01, 0x9B, 0x90	| l trap_NewCDialog
    .byte   0xFF, 0x00, 0x03, 0xCA, 0xC0	| l trap_DelSearch
    .byte   0x98	| b trap_DelComp
    .byte   0xFF, 0x00, 0x03, 0x17, 0xE0	| l trap_SetStdCProcs
    .byte   0xFF, 0x00, 0x03, 0xD5, 0x5A	| l trap_CalcCMask
    .byte   0x7F, 0xF3	| w trap_SeedCFill
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x0B, 0x73, 0xD0	| l DOCKINGMGR
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x01, 0x70, 0x32	| l trap_DelMCEntries
    .byte   0x04, 0x00	| w trap_GetMCInfo
    .byte   0x94	| b trap_SetMCInfo
    .byte   0x9A	| b trap_DispMCInfo
    .byte   0x01, 0x68	| w trap_GetMCEntry
    .byte   0x7F, 0x43	| w trap_SetMCEntries
    .byte   0x7F, 0x16	| w trap_MenuChoice
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x03, 0xE1, 0xF0	| l trap_InitPalettes
    .byte   0x7C, 0xF0	| w trap_NewPalette
    .byte   0xD8	| b trap_GetNewPalette
    .byte   0x02, 0x30	| w trap_DisposePalette
    .byte   0x7B, 0x6C	| w trap_ActivatePalette
    .byte   0x07, 0x7C	| w trap_SetPalette
    .byte   0xF8	| b trap_GetPalette
    .byte   0x01, 0x40	| w trap_PmForeColor
    .byte   0x82	| b trap_PmBackColor
    .byte   0xB6	| b trap_AnimateEntry
    .byte   0x00, 0x98	| w trap_AnimatePalette
    .byte   0x00, 0xD0	| w trap_GetEntryColor
    .byte   0x01, 0x08	| w trap_SetEntryColor
    .byte   0xA8	| b trap_GetEntryUsage
    .byte   0xA0	| b trap_SetEntryUsage
    .byte   0xD0	| b trap_CTab2Palette
    .byte   0xD0	| b trap_Palette2CTab
    .byte   0xE8	| b trap_CopyPalette
    .byte   0x04, 0x13	| w trap_PaletteDispatch
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x0B, 0x63, 0xD0	| l trap_CursorDeviceDispatch
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x02, 0xC8, 0x70	| l trap_BITBLT
    .byte   0x1C, 0x31	| w trap_BITSTOMAP
    .byte   0x01, 0x5F	| w trap_BITSTOPIX
    .byte   0x08, 0x55	| w trap_JACKSONPOLLOCK
    .byte   0x6C, 0x2B	| w trap_COLORMAP
    .byte   0x09, 0xE8	| w trap_COPYHANDLE
    .byte   0xFF, 0x00, 0x03, 0xBC, 0xC0	| l trap_CULLPOINTS
    .byte   0xFF, 0x00, 0x03, 0x2B, 0xF0	| l trap_DPUTPICBYTE
    .byte   0xD0	| b trap_DPUTPICOP
    .byte   0x0C, 0xF8	| w trap_DRAWARC
    .byte   0xFF, 0x00, 0x02, 0x99, 0xA0	| l trap_DRAWLINE
    .byte   0x2B, 0xE0	| w trap_DRAWSLAB
    .byte   0x07, 0x70	| w trap_FASTSLABMODE
    .byte   0xFF, 0x00, 0x03, 0xAF, 0x40	| l trap_GETSEEK
    .byte   0xFF, 0x00, 0x03, 0x0E, 0x50	| l trap_MAKESCALETBL
    .byte   0x14, 0x98	| w trap_CHECKPIC
    .byte   0xFF, 0x00, 0x02, 0x96, 0xF0	| l trap_DOLINE
    .byte   0x38, 0xD0	| w trap_OLDPATTONEW
    .byte   0xFF, 0x00, 0x03, 0xD1, 0x80	| l trap_PACKRGN
    .byte   0xFF, 0x00, 0x03, 0x0C, 0x20	| l trap_PATCONVERT
    .byte   0x01, 0xC8	| w trap_PATDITHER
    .byte   0x7C, 0xB8	| w trap_PATEXPAND
    .byte   0x5D, 0x68	| w trap_PINIT
    .byte   0x1E, 0x70	| w trap_PORTTOMAP
    .byte   0x61, 0xA0	| w trap_PUSHVERB
    .byte   0x6A, 0x40	| w trap_PUTLINE
    .byte   0xFF, 0x00, 0x03, 0xD0, 0x30	| l trap_PUTOVAL
    .byte   0x76, 0x70	| w trap_PUTRGN
    .byte   0xFF, 0x00, 0x03, 0x14, 0xA0	| l trap_NEWTEMPBUFFER
    .byte   0xFF, 0x00, 0x03, 0xFA, 0x60	| l trap_QDExtensions
    .byte   0xFF, 0x00, 0x03, 0x15, 0x10	| l trap_DISPOSETEMPBUFFER
    .byte   0x48, 0xE8	| w trap_RGNBLT
    .byte   0xFF, 0x00, 0x03, 0xD2, 0x50	| l trap_RGNOP
    .byte   0xFF, 0x00, 0x02, 0xC6, 0xD4	| l trap_RSECT
    .byte   0xFF, 0x00, 0x03, 0x6A, 0x10	| l trap_SEEKRGN
    .byte   0x4E, 0xB8	| w trap_SETFILLPAT
    .byte   0x3E, 0x60	| w trap_SETUPSTRETCH
    .byte   0xFF, 0x00, 0x02, 0xFE, 0xE0	| l trap_SLABMODE
    .byte   0xFF, 0x00, 0x03, 0xBC, 0x30	| l trap_SORTPOINTS
    .byte   0x57, 0x98	| w trap_STRETCHBITS
    .byte   0xFF, 0x00, 0x02, 0xC1, 0xE0	| l trap_STDDEVLOOP
    .byte   0xFF, 0x00, 0x03, 0x65, 0x20	| l trap_TRIMRECT
    .byte   0x45, 0xF8	| w trap_XORSLAB
    .byte   0xFF, 0x00, 0x03, 0x85, 0x2C	| l trap_EXTBL
    .byte   0x80	| unimplemented
    .byte   0x47, 0x9A	| w trap_NEWTEMPHANDLE
    .byte   0x38, 0x76	| w trap_PATEXTBL
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x02, 0xCE, 0x12	| l trap_BMAIN0
    .byte   0x98	| b trap_BMAIN1
    .byte   0x90	| b trap_BMAIN2
    .byte   0x90	| b trap_BMAIN3
    .byte   0x00, 0x9F	| w trap_BSETUP8
    .byte   0xD1	| b trap_BMAIN9
    .byte   0xA7	| b trap_BSETUP10
    .byte   0xC1	| b trap_BMAIN11
    .byte   0xBF	| b trap_BXMAIN8
    .byte   0xA9	| b trap_BXMAIN9
    .byte   0xB0	| b trap_BXMAIN10
    .byte   0x90	| b trap_BXMAIN11
    .byte   0x7E, 0x10	| w trap_BCMAIN0
    .byte   0x98	| b trap_BCMAIN1
    .byte   0x07, 0x37	| w trap_BHILITE
    .byte   0x78, 0xE1	| w trap_BCMAIN3
    .byte   0x7F, 0x87	| w trap_BEND0
    .byte   0x98	| b trap_BEND1
    .byte   0x90	| b trap_BEND2
    .byte   0x90	| b trap_BEND3
    .byte   0xD8	| b trap_BLONG8
    .byte   0x00, 0x98	| w trap_BEND9
    .byte   0x90	| b trap_BEND10
    .byte   0xD8	| b trap_BEND11
    .byte   0x90	| b trap_BXLONG8
    .byte   0xD8	| b trap_BXEND9
    .byte   0x98	| b trap_BXEND10
    .byte   0xA8	| b trap_BXEND11
    .byte   0x7E, 0x10	| w trap_BCEND0
    .byte   0x98	| b trap_BCEND1
    .byte   0x07, 0xA0	| w trap_BSLOHILITE
    .byte   0x78, 0x78	| w trap_BCEND3
    .byte   0x05, 0xE8	| w trap_BAVG
    .byte   0x7C, 0xC0	| w trap_BADDPIN
    .byte   0x7F, 0x78	| w trap_BADDOVER
    .byte   0x01, 0xD0	| w trap_BSUBPIN
    .byte   0x03, 0xD0	| w trap_BTRANSPARENT
    .byte   0x7C, 0xF8	| w trap_BMAX
    .byte   0x7E, 0xB0	| w trap_BSUBOVER
    .byte   0x01, 0xE8	| w trap_BMIN
    .byte   0x79, 0xF8	| w trap_BSETUP0
    .byte   0x7F, 0xD8	| w trap_BLEFT0
    .byte   0x6F, 0xC0	| w trap_RMASK0
    .byte   0x00, 0xCD	| w trap_RMASK1
    .byte   0xB0	| b trap_RMASK2
    .byte   0xB0	| b trap_RMASK3
    .byte   0x00, 0xE9	| w trap_RMASK8
    .byte   0xC1	| b trap_RMASK9
    .byte   0xB7	| b trap_RMASK10
    .byte   0xA9	| b trap_RMASK11
    .byte   0x99	| b trap_RXMASK8
    .byte   0xB9	| b trap_RXMASK9
    .byte   0xBF	| b trap_RXMASK10
    .byte   0xA0	| b trap_RXMASK11
    .byte   0x04, 0x10	| w trap_RAVG
    .byte   0x7C, 0x88	| w trap_RADDPIN
    .byte   0x7F, 0x70	| w trap_RADDOVER
    .byte   0x01, 0xF8	| w trap_RSUBPIN
    .byte   0x04, 0x68	| w trap_RTRANSPARENT
    .byte   0x7C, 0x68	| w trap_RMAX
    .byte   0x7E, 0x98	| w trap_RSUBOVER
    .byte   0x02, 0x08	| w trap_RMIN
    .byte   0x7A, 0x78	| w trap_RCMASK0
    .byte   0xD5	| b trap_RCMASK1
    .byte   0x07, 0xE3	| w trap_RSLOWHILITE
    .byte   0x78, 0x55	| w trap_RCMASK3
    .byte   0x07, 0x0B	| w trap_RHILITE
    .byte   0xFF, 0x00, 0x03, 0x79, 0xF0	| l trap_STMASK0
    .byte   0x98	| b trap_STMASK1
    .byte   0x90	| b trap_STMASK2
    .byte   0x90	| b trap_STMASK3
    .byte   0x01, 0x30	| w trap_STAVG
    .byte   0x7F, 0x08	| w trap_STADDPIN
    .byte   0x7F, 0xD8	| w trap_STADDOVER
    .byte   0x00, 0x88	| w trap_STSUBPIN
    .byte   0x00, 0xC8	| w trap_STTRANSPARENT
    .byte   0x7F, 0x70	| w trap_STMAX
    .byte   0x7F, 0xA0	| w trap_STSUBOVER
    .byte   0x00, 0x90	| w trap_STMIN
    .byte   0x00, 0x80	| w trap_STHILITE
    .byte   0xFF, 0x00, 0x02, 0xF1, 0xC4	| l trap_SLMASK8
    .byte   0x91	| b trap_SLMASK9
    .byte   0x8B	| b trap_SLMASK10
    .byte   0x95	| b trap_SLMASK11
    .byte   0x85	| b trap_SLXMASK8
    .byte   0xA0	| b trap_SLXMASK9
    .byte   0xA0	| b trap_SLXMASK10
    .byte   0xA0	| b trap_SLXMASK11
    .byte   0x01, 0xC0	| w trap_SLAVG
    .byte   0x7E, 0xB8	| w trap_SLADDPIN
    .byte   0x7F, 0xA8	| w trap_SLADDOVER
    .byte   0x00, 0xD8	| w trap_SLSUBPIN
    .byte   0x01, 0x58	| w trap_SLTRANSPARENT
    .byte   0x7E, 0xF0	| w trap_SLMAX
    .byte   0x7F, 0x80	| w trap_SLSUBOVER
    .byte   0x00, 0xC0	| w trap_SLMIN
    .byte   0x00, 0x98	| w trap_SLHILITE
    .byte   0xFF, 0x00, 0x03, 0xC2, 0x50	| l trap_ITABMATCH
    .byte   0x00, 0xA8	| w trap_COLORTHING2INDEX
    .byte   0x80	| unimplemented
    .byte   0x75, 0xB5	| w trap_ALLOCRUNBUF
    .byte   0x5D, 0x5B	| w trap_INITRGN
    .byte   0x1A, 0x08	| w trap_SCALEBLT
    .byte   0x6D, 0xD8	| w trap_STNOSTACK
    .byte   0x79, 0xD2	| w trap_BLITCASE
    .byte   0x03, 0xD6	| w trap_STSCANLOOP
    .byte   0x55, 0x48	| w trap_PICITEM1
    .byte   0xFF, 0x00, 0x03, 0xC1, 0x44	| l trap_MAKEGRAYITAB
    .byte   0xFF, 0x00, 0x02, 0x9E, 0xA0	| l trap_FASTLINE
    .byte   0x00, 0xF0	| w trap_FASTSLANT
    .byte   0xFF, 0x00, 0x03, 0x52, 0x00	| l trap_BITSDEVLOOP
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x02, 0xAC, 0x5C	| l trap_RARITH16TAB
    .byte   0x92	| b trap_RARITH32TAB
    .byte   0x92	| b trap_RHILITETAB
    .byte   0xFF, 0x00, 0x03, 0xB0, 0x84	| l trap_GSRUNTBL
    .byte   0x8C	| b trap_GSEXPTBL
    .byte   0x8C	| b trap_GSSEEKTBL
    .byte   0x69, 0xA0	| w trap_STARITH16TAB
    .byte   0x92	| b trap_STARITH32TAB
    .byte   0x76, 0x0C	| w trap_STCOLORTAB
    .byte   0x90	| b trap_STGRAYTAB
    .byte   0x90	| b trap_STSEARCHTAB
    .byte   0x11, 0x88	| w trap_SCALEINDEXEDTOINDEXED
    .byte   0x09, 0x4A	| w trap_SCINDTAB1
    .byte   0x88	| b trap_SCINDTAB2
    .byte   0x88	| b trap_SCINDTAB4
    .byte   0x88	| b trap_SCINDTAB8
    .byte   0x88	| b trap_SCINDTAB16
    .byte   0x88	| b trap_SCINDTAB32
    .byte   0x7F, 0x78	| w trap_SCDIRTAB1
    .byte   0x90	| b trap_SCDIRTAB2
    .byte   0x90	| b trap_SCDIRTAB4
    .byte   0x90	| b trap_SCDIRTAB8
    .byte   0x90	| b trap_SCDIRTAB16
    .byte   0x90	| b trap_SCDIRTAB32
    .byte   0xFF, 0x00, 0x02, 0xCC, 0xE0	| l trap_BARITH16TAB
    .byte   0x92	| b trap_BARITH32TAB
    .byte   0x92	| b trap_BHILITETAB
    .byte   0x02, 0xE4	| w trap_BARITH16SETUP
    .byte   0x7F, 0xE0	| w trap_BARITH32SETUP
    .byte   0x16, 0x60	| w trap_SLARITH16TAB
    .byte   0x92	| b trap_SLARITH32TAB
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x0D, 0xCE	| w trap_StdOpcodeProc
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x00, 0xB7, 0x66	| l trap_Open
    .byte   0x01, 0xA2	| w trap_Close
    .byte   0xB9	| b trap_Read
    .byte   0xBF	| b trap_Write
    .byte   0x8A	| b trap_Control
    .byte   0x88	| b trap_Status
    .byte   0x93	| b trap_KillIO
    .byte   0x22, 0x88	| w trap_GetVolInfo
    .byte   0x04, 0xFB	| w trap_Create
    .byte   0x01, 0x15	| w trap_Delete
    .byte   0x7D, 0xED	| w trap_OpenRF
    .byte   0x02, 0x53	| w trap_Rename
    .byte   0x03, 0x36	| w trap_GetFileInfo
    .byte   0x7E, 0xFA	| w trap_SetFileInfo
    .byte   0x76, 0x12	| w trap_UnmountVol
    .byte   0x7B, 0xFB	| w trap_MountVol
    .byte   0x13, 0xDE	| w trap_Allocate
    .byte   0x7F, 0x55	| w trap_GetEOF
    .byte   0x00, 0xC3	| w trap_SetEOF
    .byte   0x70, 0x62	| w trap_FlushVol
    .byte   0x02, 0x4D	| w trap_GetVol
    .byte   0xA4	| b trap_SetVol
    .byte   0x76, 0xE3	| w trap_FInitQueue
    .byte   0x05, 0xEC	| w trap_Eject
    .byte   0x0D, 0x7B	| w trap_GetFPos
    .byte   0x5B, 0x6A	| w trap_InitZone
    .byte   0x00, 0xB0	| w trap_GetZone
    .byte   0x89	| b trap_SetZone
    .byte   0xFD	| b trap_FreeMem
    .byte   0xAF	| b trap_MaxMem
    .byte   0x00, 0xC7	| w trap_NewPtr
    .byte   0xA0	| b trap_DisposPtr
    .byte   0xA2	| b trap_SetPtrSize
    .byte   0x7F, 0xF4	| w trap_GetPtrSize
    .byte   0xBE	| b trap_NewHandle
    .byte   0x9E	| b trap_DisposHandle
    .byte   0xA6	| b trap_SetHandleSize
    .byte   0x7F, 0xF2	| w trap_GetHandleSize
    .byte   0x9F	| b trap_HandleZone
    .byte   0xD4	| b trap_ReallocHandle
    .byte   0x7F, 0xB5	| w trap_RecoverHandle
    .byte   0x00, 0x92	| w trap_HLock
    .byte   0x93	| b trap_HUnlock
    .byte   0x7F, 0x93	| w trap_EmptyHandle
    .byte   0x7B, 0xEF	| w trap_InitApplZone
    .byte   0x02, 0x81	| w trap_SetApplLimit
    .byte   0x7B, 0xDE	| w BLOCKMOVE68020
    .byte   0x74, 0xC8	| w trap_PostEvent
    .byte   0xBC	| b trap_OSEventAvail
    .byte   0xC5	| b trap_GetOSEvent
    .byte   0x95	| b trap_FlushEvents
    .byte   0x76, 0xB2	| w trap_VInstall
    .byte   0xA8	| b trap_VRemove
    .byte   0x2D, 0x0C	| w trap_OffLine
    .byte   0x6D, 0x4E	| w trap_MoreMasters
    .byte   0x74, 0x87	| w trap_READPARAM
    .byte   0x8D	| b trap_WriteParam
    .byte   0x90	| b trap_ReadDateTime
    .byte   0x85	| b trap_SetDateTime
    .byte   0x84	| b trap_Delay
    .byte   0xC8	| b trap_CmpString
    .byte   0x7D, 0x8D	| w trap_DrvrInstall
    .byte   0xAF	| b trap_DrvrRemove
    .byte   0x04, 0x9B	| w trap_InitUtil
    .byte   0x05, 0xDF	| w trap_ResrvMem
    .byte   0x20, 0x0F	| w trap_SetFilLock
    .byte   0x85	| b trap_RstFilLock
    .byte   0x7F, 0xDF	| w trap_SetFilType
    .byte   0x03, 0x64	| w trap_SetFPos
    .byte   0x01, 0x20	| w trap_FlushFile
    .byte   0xFF, 0x00, 0x00, 0x9A, 0x66	| l trap_GetTrapAddress
    .byte   0x84	| b trap_SetTrapAddress
    .byte   0x1C, 0xC7	| w trap_PtrZone
    .byte   0x01, 0x3A	| w trap_HPurge
    .byte   0x8F	| b trap_HNoPurge
    .byte   0x7D, 0xD8	| w trap_SetGrowZone
    .byte   0x7F, 0x35	| w trap_CompactMem
    .byte   0xB9	| b trap_PurgeMem
    .byte   0x75, 0xD6	| w trap_AddDrive
    .byte   0x01, 0x8B	| w trap_RDrvrInstall
    .byte   0x00, 0xAC	| w trap_RelString
    .byte   0x78, 0x29	| w trap_ReadXPRam
    .byte   0x85	| b trap_WriteXPRam
    .byte   0xFF, 0x00, 0x0B, 0x39, 0xB6	| l trap_CLKNOMEM
    .byte   0xFF, 0x00, 0x00, 0xC1, 0x08	| l trap_UprString
    .byte   0x0B, 0x2E	| w trap_StripAddress
    .byte   0x74, 0x9E	| w trap_LwrString
    .byte   0x06, 0x2F	| w trap_SetApplBase
    .byte   0x70, 0xF7	| w trap_InsTime
    .byte   0x7F, 0xD2	| w trap_RmvTime
    .byte   0xC5	| b trap_PrimeTime
    .byte   0x77, 0x7E	| w trap_PowerOff
    .byte   0x5B, 0x91	| w trap_MemoryDispatch
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x01, 0xD7, 0x20	| l trap_NMInstall
    .byte   0x88	| b trap_NMRemove
    .byte   0xFF, 0x00, 0x00, 0xEF, 0x40	| l trap_FSDispatch
    .byte   0x70, 0xA6	| w trap_MaxBlock
    .byte   0xE6	| b trap_PurgeSpace
    .byte   0x00, 0xC2	| w trap_MaxApplZone
    .byte   0x02, 0x4B	| w trap_MoveHHi
    .byte   0x7D, 0xA6	| w trap_StackSpace
    .byte   0x00, 0xB2	| w trap_NewEmptyHandle
    .byte   0x01, 0x4A	| w trap_HSetRBit
    .byte   0x8F	| b trap_HClrRBit
    .byte   0x8F	| b trap_HGetState
    .byte   0x93	| b trap_HSetState
    .byte   0xFF, 0x00, 0x0B, 0x93, 0xD0	| l trap_USTSTRT1
    .byte   0xFF, 0x00, 0x00, 0xF3, 0x68	| l trap_InitFS
    .byte   0xFF, 0x00, 0x00, 0x22, 0xE0	| l trap_InitEvents
    .byte   0x25, 0x9B	| w trap_SlotManager
    .byte   0x1A, 0x7E	| w trap_SlotVInstall
    .byte   0x83	| b trap_SlotVRemove
    .byte   0x88	| b trap_AttachVBL
    .byte   0x85	| b trap_DoVBLTask
    .byte   0x80	| unimplemented
    .byte   0x7A, 0x87	| w trap_CACHETRAP
    .byte   0x6B, 0x0B	| w trap_SIntInstall
    .byte   0x92	| b trap_SIntRemove
    .byte   0x1A, 0x73	| w trap_CountADBs
    .byte   0x8D	| b trap_GetIndADB
    .byte   0x96	| b trap_GetADBInfo
    .byte   0x83	| b trap_SetADBInfo
    .byte   0x01, 0xD3	| w trap_ADBReInit
    .byte   0x7E, 0x45	| w trap_ADBOp
    .byte   0xFF, 0x00, 0x00, 0x13, 0x90	| l trap_GetDefaultStartup
    .byte   0x88	| b trap_SetDefaultStartup
    .byte   0xB0	| b trap_InternalWait
    .byte   0x7F, 0xF0	| w trap_GetVideoDefault
    .byte   0x88	| b trap_SetVideoDefault
    .byte   0xFF, 0x00, 0x00, 0xA1, 0xD0	| l trap_DTInstall
    .byte   0xFF, 0x00, 0x00, 0x13, 0xC0	| l trap_SetOSDefault
    .byte   0x7F, 0xF8	| w trap_GetOSDefault
    .byte   0xFF, 0x00, 0x08, 0x88, 0xEC	| l PMGROP
    .byte   0xFF, 0x00, 0x00, 0x4C, 0xC0	| l IOPMGR
    .byte   0x00, 0x92	| w IOPMSGREQUEST
    .byte   0xF7	| b IOPMOVEDATA
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x08, 0x90, 0xF4	| l GOTOSLEEP
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x00, 0xA0, 0xF0	| l trap_DebugUtil
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x13, 0x30	| w trap_SysEnvirons
    .byte   0xFF, 0x00, 0x02, 0xF0, 0x90	| l trap_Translate24To32
    .byte   0xFF, 0x00, 0x01, 0x48, 0x00	| l trap_EgretDispatch
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x00, 0x54, 0x48	| l trap_HWPriv
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x08, 0x88, 0xD8	| l POWERDISPATCH
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x01, 0xB7, 0x0E	| l trap_VRMGRSTDENTRY
    .byte   0xDE	| b trap_VRMGRSTDEXIT
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x80	| unimplemented
    .byte   0x56, 0x9B	| w trap_Gestalt
    .byte   0x80	| unimplemented
    .byte   0x4A, 0x57	| w trap_VMTCHECK
    .byte   0x7F, 0x3B	| w trap_VCHECKREMOUNT
    .byte   0x04, 0x1C	| w trap_VDTRMV2
    .byte   0x7E, 0x0B	| w trap_VFINDDRIVE
    .byte   0x0F, 0x1B	| w trap_VFCLOSE
    .byte   0x6D, 0x49	| w trap_VFLUSHMDB
    .byte   0x60, 0x8E	| w trap_VGODRIVER
    .byte   0x02, 0x3B	| w trap_VWAITUNTIL
    .byte   0xE0	| b trap_VSYNCWAIT
    .byte   0xFF, 0x00, 0x04, 0x2D, 0x10	| l trap_SNDAPPDEAD
    .byte   0xFF, 0x00, 0x00, 0xA1, 0xEE	| l trap_VDISPTCH
    .byte   0x15, 0xFB	| w trap_VIAZINIT
    .byte   0x00, 0x8D	| w trap_VIAZPOSTINIT
    .byte   0x78, 0x48	| w trap_VLAUNCHINIT
    .byte   0x6D, 0x77	| w VCACHEFLUSH
    .byte   0x12, 0xE2	| w trap_SYSUTIL
    .byte   0x2F, 0x6A	| w trap_VLG2PHYS
    .byte   0x11, 0x16	| w trap_VFLUSHCACHE
    .byte   0xF5	| b trap_VGETBLOCK
    .byte   0x01, 0x21	| w trap_VMARKBLOCK
    .byte   0x8B	| b trap_VRELBLOCK
    .byte   0xEC	| b trap_VTRASHBLOCKS
    .byte   0x7F, 0xBD	| w trap_VTRASHVBLKS
    .byte   0xFD	| b trap_VCACHEWRIP
    .byte   0x7F, 0xEA	| w trap_VCACHERDIP
    .byte   0xF5	| b trap_VBASICIO
    .byte   0xBD	| b trap_VRDBLOCKS
    .byte   0xA7	| b trap_VWRBLOCKS
    .byte   0x89	| b trap_VSETUPTAGS
    .byte   0x74, 0x78	| w trap_VBTCLOSE
    .byte   0xA0	| b trap_VBTDELETE
    .byte   0x00, 0xD9	| w trap_VBTFLUSH
    .byte   0xB2	| b trap_VBTGETRECORD
    .byte   0xDC	| b trap_VBTINSERT
    .byte   0x01, 0x50	| w trap_VBTOPEN
    .byte   0xDC	| b trap_VBTSEARCH
    .byte   0xC5	| b trap_VBTUPDATE
    .byte   0x03, 0x9C	| w trap_VGETNODE
    .byte   0x00, 0xE6	| w trap_VRELNODE
    .byte   0x7B, 0xB6	| w trap_VALLOCNODE
    .byte   0x00, 0xC2	| w trap_VFREENODE
    .byte   0x7F, 0x89	| w trap_VEXTBTFILE
    .byte   0x75, 0xCD	| w trap_VDEALLOCFILE
    .byte   0xEA	| b trap_VEXTENDFILE
    .byte   0x01, 0x1E	| w trap_VTRUNCATEFILE
    .byte   0x04, 0x0B	| w trap_VCMSETUP
    .byte   0x80	| unimplemented
    .byte   0x68, 0x0C	| w trap_VDTRMV1
    .byte   0x10, 0xF9	| w trap_VBLKALLOC
    .byte   0x00, 0xAD	| w trap_VBLKDEALLOC
    .byte   0x73, 0x47	| w trap_VFILEOPEN
    .byte   0x00, 0xBE	| w trap_VPERMSSNCHK
    .byte   0x04, 0x1D	| w trap_VFNDFILNAME
    .byte   0x04, 0xEC	| w trap_VRFNCALL
    .byte   0x00, 0xEF	| w trap_VADJEOF
    .byte   0xFF, 0x00, 0x02, 0x26, 0x96	| l trap_VPIXEL2CHAR
    .byte   0x09, 0x03	| w trap_VCHAR2PIXEL
    .byte   0x80	| unimplemented
    .byte   0xFF, 0x00, 0x01, 0x1A, 0x88	| l trap_VFILECLOSE
    .byte   0x7E, 0xDD	| w trap_VFILEREAD
    .byte   0x00, 0x8E	| w trap_VFILEWRITE
    .byte   0x80	| unimplemented
    .byte   0x10, 0x47	| w trap_VUPDALTMDB
    .byte   0x62, 0x8A	| w trap_VCKEXTFS
    .byte   0x88	| b trap_VDTRMV3
    .byte   0x7E, 0x3D	| w trap_VBMCHK
    .byte   0x10, 0xA6	| w trap_VTSTMOD
    .byte   0x09, 0x97	| w trap_VLOCCREC
    .byte   0x06, 0x2E	| w trap_VTREESEARCH
    .byte   0x75, 0x0A	| w trap_VMAPFBLOCK
    .byte   0x00, 0xF8	| w trap_VXFSEARCH
    .byte   0x7D, 0x6D	| w trap_VREADBM
    .byte   0x67, 0xFB	| w trap_DOEJECT
    .byte   0x65, 0xE9	| w trap_VSEGSTACK
    .byte   0xFF, 0x00, 0x01, 0xAC, 0x9C	| l trap_VSUPERLOAD
    .byte   0x02, 0x7D	| w trap_VCMPFRM
    .byte   0x7E, 0x1F	| w trap_VNEWMAP
    .byte   0x05, 0x93	| w trap_VCHECKLOAD
    .byte   0x3F, 0x5B	| w trap_XTRIMMEASURE
    .byte   0x03, 0xC5	| w trap_TEFindWord
    .byte   0x01, 0x08	| w trap_TEFindLine
    .byte   0x00, 0x00	| end
    .byte   0x00, 0x00	| 408D3C26
    FILL_408D3C28
