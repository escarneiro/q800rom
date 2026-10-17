// Decompiled by Ghidra from QUADRA800.ROM at 408099b0

void TrapDispatcher(undefined4 param_1)

{
  ushort uVar1;
  undefined2 in_stack_00000002;
  
  uVar1 = *(ushort *)CONCAT22(in_stack_00000002,param_1._0_2_);
  if (uVar1 < 0xa800) {
    if ((uVar1 & 0x100) == 0) {
      (*(code *)(iRam00000400 + (short)(uVar1 & 0xff) * 4))();
      return;
    }
    (*(code *)(iRam00000000 + CONCAT11((char)((uVar1 & 0x100) >> 8),(char)uVar1) * 4))();
    return;
  }
  if (uVar1 < 0xac00) {
    return;
  }
  return;
}


