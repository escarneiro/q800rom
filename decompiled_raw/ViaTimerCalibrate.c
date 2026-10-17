// Decompiled by Ghidra from QUADRA800.ROM at 40800800

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void ViaTimerCalibrate(void)

{
  int iVar1;
  
  iVar1 = _DAT_000001d4;
  *(byte *)(_DAT_000001d4 + 0x1600) = *(byte *)(_DAT_000001d4 + 0x1600) & 0xdf;
  *(undefined1 *)(iVar1 + 0x1200) = 0xff;
  *(undefined1 *)(iVar1 + 0x1c00) = 0xa0;
  _DAT_00000064 = 0x40800866;
                    /* WARNING: Could not recover jumptable at 0x4080083c. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*(code *)(sRam4080086e + 0x4080086e))();
  return;
}


