; Macintosh Classic Low-Memory Globals Equates for M68K Assembler

ResetSSP                 EQU $00000  ; Initial Supervisor Stack Pointer
ResetPC                  EQU $00004  ; Initial Program Counter (Reset Vector)
Line1010Vector           EQU $00028  ; Line 1010 Emulator (A-Line Exception)
Level1Int                EQU $00064  ; Level 1 Autovector (VIA1 Interrupt)
Level2Int                EQU $00068  ; Level 2 Autovector (VIA2 / NuBus Slot Interrupt)
Level3Int                EQU $0006C  ; Level 3 Autovector
Level4Int                EQU $00070  ; Level 4 Autovector (SCC Serial Interrupt)
Level5Int                EQU $00074  ; Level 5 Autovector
Level6Int                EQU $00078  ; Level 6 Autovector
Level7Int                EQU $0007C  ; Level 7 Autovector (NMI / Programmer Switch)
SysCom                   EQU $00100  ; Start of System communication area
ScrVRes                  EQU $00102  ; screen vertical dots/inch
ScrHRes                  EQU $00104  ; screen horizontal dots/inch
ScreenRow                EQU $00106  ; rowBytes of screen
MemTop                   EQU $00108  ; Pointer to end of RAM
BufPtr                   EQU $0010C  ; Pointer to bottom of sound/screen buffers (top of app memory)
StkLowPt                 EQU $00110  ; lowest stack pointer value as measured in VBL task
HeapEnd                  EQU $00114  ; Pointer to end of application heap
TheZone                  EQU $00118  ; Pointer to current heap zone
UTableBase               EQU $0011C  ; ptr to unit I/O table
MacJmp                   EQU $00120  ; ptr to jump vector table used by MacsBug
DskRtnAdr                EQU $00124  ; temporary pointer used by Disk Driver
PollRtnAddr              EQU $00128  ; ptr to 'other' driver variables (Lisa 5.25" drive)
CPUFlag                  EQU $0012F  ; CPU identification: 0=68000, 1=68010, 2=68020, 3=68030, 4=68040
SonyVars                 EQU $00134  ; ptr to Mac 3.5" Disk Driver variables
PWMValue                 EQU $00138  ; current PWM value
PollStack                EQU $0013A  ; address of SCC poll data start stack location
PollProc                 EQU $0013E  ; ptr to SCC poll data procedure
DskErr                   EQU $00142  ; disk routine result code
SysEvtMask               EQU $00144  ; system event mask
SysEvtBuf                EQU $00146  ; ptr to system event queue element buffer
EvtBufCnt                EQU $00154  ; maximum #of events in SysEvtBuf minus 1
RndSeed                  EQU $00156  ; random number seed
SysVersion               EQU $0015A  ; System file version number (e.g. System 4.1=$0410)
Ticks                    EQU $0016A  ; Tick count: time since system startup (tick=1/60 sec)
MBTicks                  EQU $0016E  ; tick count when mouse button was last pressed
KeypadMap                EQU $0017C  ; bitmap for numeric keypad (uses 18 bits)
unk_0180                 EQU $00180  ; <unknown location>
KeyLast                  EQU $00184  ; ASCII code for last valid keycode
KeyTime                  EQU $00186  ; tickcount when KEYLAST was received
KeyRepTime               EQU $0018A  ; tick count when key was last repeated
KeyThresh                EQU $0018E  ; threshold for key repeat
KeyRepThresh             EQU $00190  ; key repeat speed
UnitNtryCnt              EQU $001D2  ; count of entries in unit table
VIA                      EQU $001D4  ; Base pointer to VIA1 I/O space
SCCRd                    EQU $001D8  ; address of Z8530 SCC chip (used when reading the chip)
SCCWr                    EQU $001DC  ; address of Z8530 SCC chip (used when writing the chip)
IWM                      EQU $001E0  ; base address of IWM chip (floppy drive controller)
SysParam                 EQU $001F8  ; -System parameter RAM vars (PRAM info)
SPPortA                  EQU $001FC  ; modem port configuration (baud, parity, bits)
SPPortB                  EQU $001FE  ; printer port configuration (baud, parity, bits)
SPAlarm                  EQU $00200  ; alarm clock setting
SPFont                   EQU $00204  ; font number of application font minus 1
Time                     EQU $0020C  ; current date/time (seconds since midnight 1 JAN 1904)
BootDrive                EQU $00210  ; working directory reference number of boot disk
JShell                   EQU $00212  ; journaling shell state
unk_0216                 EQU $00216  ; <unknown location>
JKybdTask                EQU $0021A  ; ptr to keyboard VBL task hook
MemErr                   EQU $00220  ; Memory Manager error code
DiskVars                 EQU $00222  ; -Disk driver variables (60 bytes)
FlEvtMask                EQU $0025E  ; mask of flushable events (FlushEvents)
SoundPtr                 EQU $00262  ; pointer to 4-voice sound definition (SynthRec)
SoundBase                EQU $00266  ; ptr to free-form sound definition (SynthRec)
SoundDCE                 EQU $0027A  ; pointer to Sound Driver's device control entry
CurPitch                 EQU $00280  ; current value of COUNT in square-wave SynthRec
SoundLast                EQU $00282  ; address past last sound variable
unk_0286                 EQU $00286  ; <unknown location>
unk_028A                 EQU $0028A  ; <unknown location>
ROM85                    EQU $0028E  ; holds a positive value if 128K or later ROM in Mac
unk_0292                 EQU $00292  ; <unknown location>
unk_0296                 EQU $00296  ; <unknown location>
JGNEFilter               EQU $0029A  ; ptr to GetNextEvent filter procedure
Key1Trans                EQU $0029E  ; ptr to keyboard translator procedure
Key2Trans                EQU $002A2  ; ptr to numeric keypad translator procedure
SysZone                  EQU $002A6  ; Pointer to system heap zone header
ApplZone                 EQU $002AA  ; Pointer to application heap zone header
ROMBase                  EQU $002AE  ; Base address of ROM (0x40800000 on Quadra 800)
RAMBase                  EQU $002B2  ; Base address of RAM (0x00000000)
BasicGlob                EQU $002B6  ; ptr to BASIC globals
DSAlertTab               EQU $002BA  ; ptr to system error alert table in use
unk_02D0                 EQU $002D0  ; <unknown location>
unk_02D4                 EQU $002D4  ; <unknown location>
ABusVars                 EQU $002D8  ; ptr to AppleTalk variables
unk_02DC                 EQU $002DC  ; <unknown location>
DoubleTime               EQU $002F0  ; double click interval in ticks
CaretTime                EQU $002F4  ; caret blink interval in ticks
unk_02FA                 EQU $002FA  ; <unknown location>
BufTgFNum                EQU $002FC  ; File tags buffer: file number
BufTgFFlg                EQU $00300  ; File tags buffer: flags (bit1=1 if resource fork)
BufTgFBkNum              EQU $00302  ; File tags buffer: logical block number
BufTgDate                EQU $00304  ; File tags buffer: last modification date/time
PWMBuf2                  EQU $00312  ; ptr to PWM buffer 1 (or 2 if sound)
HpChk                    EQU $00316  ; heap check RAM code
Lo3Bytes                 EQU $0031A  ; holds the constant $00FFFFFF
MinStack                 EQU $0031E  ; minimum stack size used in InitApplZone
DefltStack               EQU $00322  ; default size of stack
MMDefFlags               EQU $00326  ; default zone flags
GZRootHnd                EQU $00328  ; root handle for GrowZone
GZRootPtr                EQU $0032C  ; root pointer for GrowZone
GZMoveHnd                EQU $00330  ; moving handle for GrowZone
DSDrawProc               EQU $00334  ; ptr to alternate system error draw procedure
EjectNotify              EQU $00338  ; ptr to eject notify procedure
IAZNotify                EQU $0033C  ; ptr to world swaps notify procedure
FileVars                 EQU $00340  ; -file system vars (184 bytes)
NxtDB                    EQU $00342  ; <no description available>
MaxDB                    EQU $00344  ; <no description available>
FlushOnly                EQU $00346  ; flag used by UnMountVol and FlushVol
RegRsrc                  EQU $00347  ; flag used by OpenRF and FileOpen
FLckUnlck                EQU $00348  ; flag used by SetFilLock and RstFilLock
FrcSync                  EQU $00349  ; when set, all file system calls are synchronized
DrMstrBlk                EQU $0034C  ; master directory block in a volume
FCBSPtr                  EQU $0034E  ; ptr to file control block buffer
DefVCBPtr                EQU $00352  ; ptr to default volume control block
HFSStkTop                EQU $0036A  ; Temp location of stack ptr during async calls
HFSStkPtr                EQU $0036E  ; Temporary location of HFS stack ptr
WDCBsPtr                 EQU $00372  ; Working Directory queue header
HFSFlags                 EQU $00376  ; Internal HFS flags
CacheFlag                EQU $00377  ; system cache usage count now used as cache flag
SysBMCPtr                EQU $00378  ; System-wide bitmap cache pointer
SysVolCPtr               EQU $0037C  ; System-wide volume cache pointer
SysCtlCPtr               EQU $00380  ; System-wide control cache pointer
DefVRefNum               EQU $00384  ; Default volume's VRefNum/WDRefNum
PMSPPtr                  EQU $00386  ; ptr to list of directories on PMSP
HFSDSErr                 EQU $00392  ; Final gasp - error that caused IOErr
HFSVarEnd                EQU $00394  ; -End of HFS variable area
CurDirStore              EQU $00398  ; ID of last directory opened
unk_039A                 EQU $0039A  ; <unknown location>
CacheCom                 EQU $0039C  ; <no description available>
unk_03A0                 EQU $003A0  ; <unknown location>
ErCode                   EQU $003A2  ; report errors here during async routines
Params                   EQU $003A4  ; -File Mgr I/O ParamBlock (50 bytes)
FSTemp8                  EQU $003D6  ; 8used by Rename
FSIOErr                  EQU $003DE  ; last I/O error
unk_03E0                 EQU $003E0  ; <unknown location>
FSQueueHook              EQU $003E2  ; ptr to hook to capture all FS calls
ExtFSHook                EQU $003E6  ; ptr to command done hook
DskSwtchHook             EQU $003EA  ; ptr to hook for disk-switch dialog
ReqstVol                 EQU $003EE  ; ptr to offline or external file system volume
VCBToExtFS               EQU $003F2  ; ptr to external file system
FSFCBLen                 EQU $003F6  ; size of file control block; contains -1 on 64K ROM MacsDSAlertRect$3F88rectangle for system error and disk-switch alerts
OSTable                  EQU $00400  ; Base of OS Trap dispatch table ($A000-$A7FF)
ExtStrap                 EQU $00644  ; External boot strap pointer
JADBProc                 EQU $006B8  ; ptr to ADBReInit pre-/post-processing routine
JHideCursor              EQU $00800  ; <no description available>
JShowCursor              EQU $00804  ; <no description available>
JShieldCursor            EQU $00808  ; <no description available>
JScrnAddr                EQU $0080C  ; <no description available>
JScrnSize                EQU $00810  ; <no description available>
JInitCrsr                EQU $00814  ; <no description available>
JSetCrsr                 EQU $00818  ; <no description available>
JCrsrObscure             EQU $0081C  ; <no description available>
JUpdateProc              EQU $00820  ; <no description available>
ScrnBase                 EQU $00824  ; base address of main screen
MTemp                    EQU $00828  ; low-level interrupt mouse location
RawMouse                 EQU $0082C  ; un-jerked mouse coordinates
NMouse                   EQU $00830  ; processed mouse coordinate
CrsrAddr                 EQU $00888  ; address of data under cursor
CrsrSave                 EQU $0088C  ; ptr to data under the cursor
MainDevice               EQU $008A4  ; handle to current main device
DeviceList               EQU $008A8  ; handle to first element in device list
unk_08AC                 EQU $008AC  ; <unknown location>
CrsrState                EQU $008D0  ; cursor nesting level
unk_08D4                 EQU $008D4  ; <unknown location>
MouseMask                EQU $008D6  ; V-H mask for ANDing with mouse
MouseOffset              EQU $008DA  ; V-H offset for adding after ANDing
JournalFlag              EQU $008DE  ; journaling state
JSwapFont                EQU $008E0  ; jump entry for FMSwapFont
WidthListHand            EQU $008E4  ; handle to a list of handles of recently-used width tablesJournalRef$8E8wordJournalling driver's refnum
unk_08EA                 EQU $008EA  ; <unknown location>
CrsrThresh               EQU $008EC  ; delta threshold for mouse scaling
JCrsrTask                EQU $008EE  ; address of CrsrVBLTask
GRAFEND                  EQU $008F2  ; -End of graphics globals
JFetch                   EQU $008F4  ; ptr to fetch-a-byte routine for drivers
JStash                   EQU $008F8  ; ptr to stash-a-byte routine for drivers
JIODone                  EQU $008FC  ; ptr to IODone routine for drivers
CurApRefNum              EQU $00900  ; refNum of current application's resFile
CurrentA5                EQU $00904  ; current value of register A5
CurStackBase             EQU $00908  ; ptr to the base (beginning) of the stack
unk_090C                 EQU $0090C  ; <unknown location>
SaveSegHandle            EQU $00930  ; handle to segment 0 (CODE 0)
CurJTOffset              EQU $00934  ; current jump table offset from register A5
CurPageOption            EQU $00936  ; current page 2 configuration (screen/sound buffers)
HiliteMode               EQU $00938  ; set to -1 if hilighting mode is on, 0 otherwise
PrintErr                 EQU $00944  ; Print Manager error code
LastPGlobal              EQU $00954  ; address of last printer global
unk_0958                 EQU $00958  ; <unknown location>
unk_095C                 EQU $0095C  ; <unknown location>
scrapSize                EQU $00960  ; scrap length
scrapHandle              EQU $00964  ; handle to RAM scrap
scrapCount               EQU $00968  ; count changed by ZeroScrap
scrapState               EQU $0096A  ; scrap state: tells if scrap exists in RAM or on disk
scrapName                EQU $0096C  ; pointer to scrap file name (normally "Clipboard File")
RomFont0                 EQU $00980  ; handle to system font
ApFontID                 EQU $00984  ; font number of application font
CurFMFamily              EQU $00988  ; current font family
CurFMSize                EQU $0098A  ; current font size
CurFMDevice              EQU $0098E  ; current font device
CurFMNumer               EQU $00990  ; current numerator of scale factor
CurFMDenom               EQU $00994  ; current denominator of scale factor
FOutError                EQU $00998  ; Font Manager error code
TFOutFontHandle          EQU $0099A  ; handle to font bits
FOutNumer                EQU $009AA  ; point for numerators of scale factor
FOutDenom                EQU $009AE  ; point for denominators of scale factor
FMDotsPerInch            EQU $009B2  ; h,v dotsPerInch (resolution) of current device
WindowList               EQU $009D6  ; ptr to Z-ordered linked list of windows
SaveUpdate               EQU $009DA  ; Enable update events?
PaintWhite               EQU $009DC  ; erase windows before update event?
WMgrPort                 EQU $009DE  ; ptr to window manager's grafport
DeskPort                 EQU $009E2  ; ptr to Desk grafPort (Whole screen)
OldStructure             EQU $009E6  ; handle to saved structure region
OldContent               EQU $009EA  ; handle to saved content region
GrayRgn                  EQU $009EE  ; handle to rounded-corner region drawn as the desktop
SaveVisRgn               EQU $009F2  ; handle to temporarily saved visRegion
DragHook                 EQU $009F6  ; ptr to user hook called during dragging
OneOne                   EQU $00A02  ; holds the constant $00010001
MinusOne                 EQU $00A06  ; holds the constant $FFFFFFFF
TopMenuItem              EQU $00A0A  ; pixel value of top of scrollable menu
AtMenuBottom             EQU $00A0C  ; flag for menu scrolling
MenuList                 EQU $00A1C  ; handle to current menuBar list structure
MBarEnable               EQU $00A20  ; menuBar enable for desk acc's that own the menu bar
CurDeKind                EQU $00A22  ; window kind of deactivated window
MenuFlash                EQU $00A24  ; flash feedback count
TheMenu                  EQU $00A26  ; resource ID of hilited menu
SavedHandle              EQU $00A28  ; handle to data under a menu
MBarHook                 EQU $00A2C  ; ptr to MenuSelect hook called before menu is drawn
MenuHook                 EQU $00A30  ; ptr to user hook called during MenuSelect
DragFlag                 EQU $00A44  ; implicit parameter to DragControl
CurDragAction            EQU $00A46  ; ptr to implicit actionProc for dragControl
TopMapHndl               EQU $00A50  ; handle to map of most recently opened resource file
SysMapHndl               EQU $00A54  ; handle to map of System resourc file
SysMap                   EQU $00A58  ; reference number of System resource file
CurMap                   EQU $00A5A  ; reference number of current resource file
ResReadOnly              EQU $00A5C  ; Read-only flag
ResLoad                  EQU $00A5E  ; Auto-load feature
ResErr                   EQU $00A60  ; Resource Manager error code
CurActivate              EQU $00A64  ; ptr to window slated for activate event
CurDeactive              EQU $00A68  ; ptr to window slated for deactivate event
DeskHook                 EQU $00A6C  ; ptr to hook for painting the desk
TEDoText                 EQU $00A70  ; ptr to textEdit doText proc hook
TERecal                  EQU $00A74  ; ptr to textEdit recalText proc hook
GhostWindow              EQU $00A84  ; ptr to window never to be considered frontmost
CloseOrnHook             EQU $00A88  ; ptr to hook for closing desk ornaments
ResumeProc               EQU $00A8C  ; ptr to Resume procedure (System error dialog)
SaveProc                 EQU $00A90  ; address of Save failsafe procedure
SaveSP                   EQU $00A94  ; Safe stack ptr for restart or save
ANumber                  EQU $00A98  ; resID of last alert
ACount                   EQU $00A9A  ; number of times last alert was called (0 through 3)
DABeeper                 EQU $00A9C  ; ptr to current beep routine
EScrpLengt               EQU $00AB0  ; textEdit Scrap Length
TEScrpHandl              EQU $00AB4  ; handle to textEdit Scrap
AppParmHandle            EQU $00AEC  ; handle to hold application parameters
DSErrCode                EQU $00AF0  ; last (or current) system error alert ID
ResErrProc               EQU $00AF2  ; ptr to Resource Manager error procedure
TEWdBreak                EQU $00AF6  ; ptr to default word break routine
DlgFont                  EQU $00AFA  ; current font number for dialogs and alerts
LastTGLobal              EQU $00AFC  ; address of last global
TrapAgain                EQU $00B00  ; use 4 bytes here for another trap
unk_0B04                 EQU $00B04  ; <unknown location>
ROMMapHndl               EQU $00B06  ; Handle to ROM resource map
PWMBuf1                  EQU $00B0A  ; ptr to PWM buffer
BootMask                 EQU $00B0E  ; needed during boot
WidthPtr                 EQU $00B10  ; ptr to global width table
AtalkHk1                 EQU $00B14  ; ptr to Appletalk hook 1
AtalkHk2                 EQU $00B18  ; ptr to Appletalk hook 2
unk_0B1C                 EQU $00B1C  ; <unknown location>
unk_0B20                 EQU $00B20  ; <unknown location>
MachineType              EQU $00B22  ; Macintosh machine hardware type ID
WidthTabHandle           EQU $00B2A  ; handle to global width table
BtDskRfn                 EQU $00B34  ; boot drive driver reference number
BootTmp8                 EQU $00B36  ; 8temporary space needed by StartBoot
T1Arbitrate              EQU $00B3F  ; holds $FF if Timer T1 up for grabs
MenuDisable              EQU $00B54  ; resID and menuItem of last chosen menu item
RMGRHiVars               EQU $00B80  ; -RMGR variables (32 bytes)
RomMapInsert             EQU $00B9E  ; Flag: 0xFF to search ROM resources first
ROMMapInsertIntlSpec     EQU $00BA0  ; international software installed if not -1
unk_0BA4                 EQU $00BA4  ; <unknown location>
SysFontFam               EQU $00BA6  ; if nonzero, the font # for system fontS
ysFontSize               EQU $00BA8  ; if nonzero, the system font size
MBarHeight               EQU $00BAA  ; pixel height of menu bar
unk_0BAC                 EQU $00BAC  ; <unknown location>
NewUnused                EQU $00BC0  ; formerly FlEvtMask
LastFOND                 EQU $00BC2  ; handle to last family record used
MMUFlags                 EQU $00CB3  ; MMU mode flags
TheGDevice               EQU $00CC8  ; handle to current active device
AuxWinHead               EQU $00CD0  ; auxiliary window list header
JVBLTask                 EQU $00D28  ; jump vector to DoVBLTask routine
SynListHandle            EQU $00D32  ; handle to synthetic font list
MenuCInfo                EQU $00D50  ; [??]menu color info table header
JDTInstall               EQU $00D9C  ; jump vector to DTInstall routine
HiliteRGB                EQU $00DA0  ; [??]default hilighting color
BootGlob                 EQU $00DD0  ; Boot global parameter 0
WarmStart                EQU $00DD4  ; Boot global parameter 1
RomUnit                  EQU $00DD8  ; Boot global parameter 2
ROMBaseCopy              EQU $00DDC  ; Shadow copy of ROMBase
ToolboxTable             EQU $00E00  ; Base of 32-bit Toolbox Trap dispatch table ($A800-$AFFF)
DskVerify                EQU $012CB  ; yteused by Mac 3.5" Disk Driver for read/verify
LoadTrap                 EQU $012DB  ; ytetrap before launch?
MmInOK                   EQU $012EB  ; yteInitial Memory Manager checks ok?
CPUFlag_12FB             EQU $012FB  ; ytecode for installed CPU: 0=68000, 1=68010, 2=68020, 3=68030ApplLimit$130longaddress of application heap limit
HeapStart                EQU $01400  ; -start of system heap (Mac Plus & SE)
SEvtEnb                  EQU $015CB  ; yte0 = SysEvent always returns FALSE
DSWndUpdate              EQU $015DB  ; yteGetNextEvent not to paint behind System error dialog?
FontFlag                 EQU $015EB  ; ytefont manager loop flag
Filler3                  EQU $015FB  ; yte1 byte of filler
MBState                  EQU $0172B  ; ytecurrent mouse button state
Tocks                    EQU $0173B  ; yteLisa sub-tick count
HeapStart_1C00           EQU $01C00  ; -start of system heap (Mac II series and SE/30)
SPValid                  EQU $01F8B  ; ytevalidation: $A8 if last write to clock chip was good
SPATalkA                 EQU $01F9B  ; yteAppleTalk node ID for modem port
SPATalkB                 EQU $01FAB  ; yteAppleTalk node ID for printer port
SPConfig                 EQU $01FBB  ; yteserial-port-in-use flags for both ports
