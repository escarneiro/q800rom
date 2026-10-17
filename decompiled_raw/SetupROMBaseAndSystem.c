// Decompiled by Ghidra from QUADRA800.ROM at 40800176

/* WARNING: Control flow encountered bad instruction data */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void SetupROMBaseAndSystem(void)

{
  undefined4 unaff_A4;
  undefined1 uVar1;
  undefined1 auStack_4c [72];
  undefined4 uStack_4;
  
  uStack_4 = 0x4080017e;
  _DAT_00000ddc = unaff_A4;
  func_0x40803e0c();
  uStack_4 = 0x40800182;
  func_0x4080417a();
  uStack_4 = 0x4080018a;
  func_0x40804032();
  uStack_4 = 0x40800194;
  func_0x408054ba();
  uStack_4 = 0x4080019a;
  func_0x40804414();
  uStack_4 = 0x408001a6;
  func_0x40800590();
  uVar1 = 0;
  uStack_4 = 0x408001b2;
  (*_DAT_00000dbc)();
  uStack_4 = 0x408001b6;
  func_0x40800600();
  uStack_4 = 0x408001c0;
  (*(code *)0x40809f4c)();
  uStack_4 = 0x408001ca;
  (*(code *)0x40809e56)();
  uStack_4 = 0x408001d4;
  (*(code *)0x40809a96)();
  uStack_4 = 0x408001d8;
  func_0x40803e00();
  uStack_4 = 0x408012ac;
  func_0x40801324();
  if ((bool)uVar1) {
    register0x0000003c = (BADSPACEBASE *)auStack_4c;
    (*(code *)0x408147c4)();
  }
  *(undefined4 *)((int)register0x0000003c + -4) = 0x408012c2;
  func_0x40800780();
  if ((DAT_00000dd7 & 0x80) != 0) {
    _DAT_00000644 = 0x4084c118;
  }
  *(undefined4 *)((int)register0x0000003c + -4) = 0x408001e0;
  func_0x40804192();
  if ((DAT_00001efc & 1) != 0) {
    _DAT_00000644 = 0x4080047e;
  }
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


