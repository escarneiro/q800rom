// Decompiled by Ghidra from QUADRA800.ROM at 408263b0

/* WARNING: Control flow encountered bad instruction data */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

undefined4 TB_InitFonts(void)

{
  undefined1 uVar1;
  int iVar2;
  undefined4 in_D0;
  
  iVar2 = iRam00000ba0;
  if (DAT_00000d42 == '\0') {
    if (iRam00000ba0 != -1) {
      uVar1 = *(undefined1 *)(iRam00000ba0 + 6);
      *(undefined1 *)(iRam00000ba0 + 6) = 0;
      if (*(char *)(iVar2 + 4) != '\0') {
                    /* WARNING: Bad instruction - Truncating control flow here */
        halt_baddata();
      }
      *(undefined1 *)(iVar2 + 6) = uVar1;
    }
    return in_D0;
  }
  _DAT_00000998 = 0;
  func_0x40827216();
  _DAT_0000098e = 0;
  DAT_00000a63 = 0;
  DAT_00000bf4 = 0;
  DAT_0000015e = 0xff;
  _DAT_00000984 = _DAT_00000204 + 1;
  DAT_00000987 = 0xc;
  if (_DAT_00000b2a != 0) {
    _DAT_000008e0 = _DAT_00001204;
    if (_DAT_00000d32 < 1) {
                    /* WARNING: Bad instruction - Truncating control flow here */
      halt_baddata();
    }
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  }
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


