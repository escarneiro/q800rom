// Decompiled by Ghidra from QUADRA800.ROM at 40809ae6

/* WARNING: Control flow encountered bad instruction data */
/* WARNING: Removing unreachable block (ram,0x4080274c) */
/* WARNING: Removing unreachable block (ram,0x40802754) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

undefined8 UnimplementedTrapHandler(void)

{
  undefined4 uVar1;
  undefined4 uVar2;
  undefined1 *puVar3;
  short sVar4;
  undefined4 in_D0;
  undefined4 in_D1;
  undefined4 unaff_D2;
  undefined4 unaff_D3;
  undefined4 unaff_D4;
  undefined4 unaff_D5;
  undefined4 unaff_D6;
  undefined4 unaff_D7;
  undefined4 in_A0;
  code *extraout_A1;
  code *pcVar5;
  undefined4 in_A1;
  undefined4 unaff_A2;
  undefined4 unaff_A3;
  undefined4 unaff_A4;
  undefined4 unaff_A5;
  undefined4 unaff_A6;
  undefined1 *puVar6;
  char in_XF;
  bool bVar7;
  bool bVar8;
  undefined4 in_stack_00000000;
  
  _DAT_00000c74 = (ushort)(byte)(in_XF << 4);
  puVar6 = &stack0x00000004;
  if (DAT_0000012f != '\0') {
    puVar6 = &stack0x00000002;
  }
  _DAT_00000c6c = (undefined1 *)register0x0000003c;
  if (-1 < (char)DAT_00000bff) {
    _DAT_00000c6c = puVar6;
  }
  DAT_00000bff = DAT_00000bff | 0x80;
  _DAT_00000af0 = 0xc;
  bVar7 = false;
  bVar8 = false;
  *(undefined4 *)(puVar6 + -4) = 0x4080278e;
  uRam00000c30 = in_D0;
  uRam00000c34 = in_D1;
  uRam00000c38 = unaff_D2;
  uRam00000c3c = unaff_D3;
  uRam00000c40 = unaff_D4;
  uRam00000c44 = unaff_D5;
  uRam00000c48 = unaff_D6;
  uRam00000c4c = unaff_D7;
  uRam00000c50 = in_A0;
  uRam00000c54 = in_A1;
  uRam00000c58 = unaff_A2;
  uRam00000c5c = unaff_A3;
  uRam00000c60 = unaff_A4;
  uRam00000c64 = unaff_A5;
  uRam00000c68 = unaff_A6;
  _DAT_00000c70 = in_stack_00000000;
  sVar4 = func_0x40802690();
  pcVar5 = extraout_A1;
  if (((!bVar7) || (bVar8)) && (sVar4 != 0xd)) goto LAB_4080279c;
  do {
    if (pcVar5 != (code *)0x0) {
      *(undefined4 *)(puVar6 + -4) = 0x408027a6;
      sVar4 = (*pcVar5)();
      puVar3 = _DAT_00000c6c;
      uVar2 = uRam00000c34;
      uVar1 = uRam00000c30;
      if (sVar4 == 0) {
        DAT_00000bff = DAT_00000bff & 0x7f;
        *(undefined4 *)(_DAT_00000c6c + -4) = _DAT_00000c70;
        *(ushort *)(puVar3 + -6) = _DAT_00000c74;
        return CONCAT44(uVar1,uVar2);
      }
    }
LAB_4080279c:
    pcVar5 = (code *)0x4080280e;
  } while( true );
}


