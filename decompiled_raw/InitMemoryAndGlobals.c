// Decompiled by Ghidra from QUADRA800.ROM at 408000f6

/* WARNING: Control flow encountered bad instruction data */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void InitMemoryAndGlobals(undefined4 param_1,undefined4 param_2)

{
  undefined4 uVar1;
  int iVar2;
  ulonglong uVar3;
  undefined4 extraout_A1;
  int unaff_A4;
  undefined1 *puVar4;
  undefined1 uVar5;
  undefined4 in_stack_00000024;
  undefined4 uStack0000002c;
  undefined1 auStack_1c [28];
  
  puVar4 = &stack0x00000030;
  uStack0000002c = 0x40800102;
  func_0x408007c0();
  uStack0000002c = 0x40800106;
  func_0x408007f0();
  uStack0000002c = 0x4080010a;
  func_0x40800a70();
  uStack0000002c = 0x4080010e;
  _DAT_00000dd0 = func_0x40801300();
  uVar1 = *(undefined4 *)(unaff_A4 + -0x14);
  iVar2 = *(int *)(unaff_A4 + -0xc);
  _DAT_00000b22 = (undefined2)((uint)param_2 >> 0x10);
  uStack0000002c = 0x40800130;
  _DAT_00000dd8 = extraout_A1;
  func_0x40800910();
  uStack0000002c = 0x40800136;
  func_0x40804230();
  uVar3 = _DAT_00000dd0;
  uStack0000002c = _DAT_00000cfc;
  func_0x40801292();
  _DAT_00000cfc = uStack0000002c;
  uStack0000002c = 0x40800164;
  _DAT_00000dd0 = uVar3;
  func_0x40800910();
  DAT_0000012f = (undefined1)in_stack_00000024;
  DAT_00000cb3 = (undefined1)((uint)in_stack_00000024 >> 0x10);
  uStack0000002c = 0x4080017e;
  _DAT_00000108 = uVar1;
  _DAT_0000010c = iVar2 + unaff_A4;
  _DAT_00000ddc = unaff_A4;
  func_0x40803e0c();
  uStack0000002c = 0x40800182;
  func_0x4080417a();
  uStack0000002c = 0x4080018a;
  func_0x40804032();
  uStack0000002c = 0x40800194;
  func_0x408054ba();
  uStack0000002c = 0x4080019a;
  func_0x40804414();
  uStack0000002c = 0x408001a6;
  func_0x40800590();
  uVar5 = 0;
  uStack0000002c = 0x408001b2;
  (*_DAT_00000dbc)();
  uStack0000002c = 0x408001b6;
  func_0x40800600();
  uStack0000002c = 0x408001c0;
  (*(code *)0x40809f4c)();
  uStack0000002c = 0x408001ca;
  (*(code *)0x40809e56)();
  uStack0000002c = 0x408001d4;
  (*(code *)0x40809a96)();
  uStack0000002c = 0x408001d8;
  func_0x40803e00();
  uStack0000002c = 0x408012ac;
  func_0x40801324();
  if ((bool)uVar5) {
    puVar4 = auStack_1c;
    (*(code *)0x408147c4)();
  }
  *(undefined4 *)(puVar4 + -4) = 0x408012c2;
  func_0x40800780();
  if ((_DAT_00000dd0 & 0x80) != 0) {
    _DAT_00000644 = 0x4084c118;
  }
  *(undefined4 *)(puVar4 + -4) = 0x408001e0;
  func_0x40804192();
  if ((DAT_00001efc & 1) != 0) {
    _DAT_00000644 = 0x4080047e;
  }
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


