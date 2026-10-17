// Decompiled by Ghidra from QUADRA800.ROM at 4088d360

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

undefined8 OS_NewPtr(void)

{
  undefined4 *unaff_A6;
  undefined4 in_stack_00000000;
  
  if ((int)unaff_A6[-0x34] < 0) {
    if (unaff_A6[-0x35] == -1) {
LAB_4088d332:
      func_0x4088d45e();
      goto LAB_4088d4f0;
    }
  }
  else if (unaff_A6[-0x35] == 0) goto LAB_4088d332;
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
LAB_4088d4f0:
  if ((*(byte *)((int)unaff_A6 + -0x7a) & *(byte *)((int)unaff_A6 + -0x7e) & 3) == 0) {
    return *(undefined8 *)(unaff_A6 + -0x30);
  }
  *(undefined1 *)((int)unaff_A6 + 0xb) = 0xc4;
  unaff_A6[-0x40] = unaff_A6[-0x1f];
  unaff_A6[-0x37] = unaff_A6[-0x37] | 0x1800000;
  restoreFPUStateFrame(in_stack_00000000);
  *unaff_A6 = _DAT_000000c4;
  return *(undefined8 *)(unaff_A6 + -0x30);
}


