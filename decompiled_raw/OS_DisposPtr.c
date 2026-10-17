// Decompiled by Ghidra from QUADRA800.ROM at 4088d3a0

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

undefined8 OS_DisposPtr(void)

{
  undefined4 *unaff_A6;
  bool in_ZF;
  undefined4 in_stack_00000000;
  
  if (in_ZF) {
    func_0x4088d45e();
  }
  else if ((*(ushort *)(unaff_A6 + -0x36) & 0x7fff) == 0x3ffe) {
    func_0x4088d45e();
  }
  else {
    unaff_A6[-0x1f] = unaff_A6[-0x1f] | 0x2080;
    *(byte *)((int)unaff_A6 + -0x7a) = *(byte *)((int)unaff_A6 + -0x7a) & 0xfd;
    *(byte *)((int)unaff_A6 + -0x79) = *(byte *)((int)unaff_A6 + -0x79) & 0xf7;
    if (*(short *)(unaff_A6 + -0x36) < 0) {
      func_0x4088d45e();
    }
    else {
      func_0x4088d45e();
    }
    if ((*(byte *)((int)unaff_A6 + -0x7e) & 0x20) != 0) {
      restoreFPUStateFrame(in_stack_00000000);
      *unaff_A6 = _DAT_00001fd4;
      return *(undefined8 *)(unaff_A6 + -0x30);
    }
  }
  if ((*(byte *)((int)unaff_A6 + -0x7a) & *(byte *)((int)unaff_A6 + -0x7e) & 3) != 0) {
    *(undefined1 *)((int)unaff_A6 + 0xb) = 0xc4;
    unaff_A6[-0x40] = unaff_A6[-0x1f];
    unaff_A6[-0x37] = unaff_A6[-0x37] | 0x1800000;
    restoreFPUStateFrame(in_stack_00000000);
    *unaff_A6 = _DAT_000000c4;
    return *(undefined8 *)(unaff_A6 + -0x30);
  }
  return *(undefined8 *)(unaff_A6 + -0x30);
}


