// Decompiled by Ghidra from QUADRA800.ROM at 4080baaa

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void OS_Close(void)

{
  int in_A0;
  int extraout_A1;
  
  if (-1 < *(short *)(in_A0 + 0x18)) {
    return;
  }
  func_0x4080b6ac();
  if ((*(byte *)(extraout_A1 + 5) & 0x20) != 0) {
    return;
  }
  *(undefined2 *)(in_A0 + 0x10) = 0;
  return;
}


