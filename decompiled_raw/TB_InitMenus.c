// Decompiled by Ghidra from QUADRA800.ROM at 40848b18

void TB_InitMenus(void)

{
  short sVar1;
  short sVar2;
  undefined1 unaff_D4b;
  int in_A0;
  int in_A1;
  undefined1 *unaff_A2;
  int unaff_A3;
  code *UNRECOVERED_JUMPTABLE;
  
  uRam40848b52 = uRam40848b52 & 0x117c;
  sVar1 = 3;
  *unaff_A2 = *unaff_A2;
  do {
    *unaff_A2 = *unaff_A2;
    if ((*(byte *)(unaff_A3 + sVar1) & *(byte *)(in_A0 + 0x1600)) !=
        (*(byte *)(unaff_A3 + sVar1) & *(byte *)(in_A1 + sVar1))) {
      UNRECOVERED_JUMPTABLE = (code *)0x40848d1c;
      goto LAB_40848c22;
    }
    sVar1 = sVar1 + -1;
  } while (sVar1 != -1);
  sVar1 = 0xf;
  do {
    *(undefined1 *)(in_A0 + 0xc00) = 0x38;
    sVar2 = 3;
    do {
      *unaff_A2 = *unaff_A2;
      *(undefined1 *)(in_A0 + 0x600) = *(undefined1 *)(sVar1 + 0x40848da2);
      sVar2 = sVar2 + -1;
    } while (sVar2 != -1);
    *(undefined1 *)(in_A0 + 0xc00) = 0x38;
    sVar2 = 3;
    do {
      *unaff_A2 = *unaff_A2;
      if ((*(byte *)(unaff_A3 + sVar2) & *(byte *)(in_A0 + 0x1600)) !=
          (*(byte *)(unaff_A3 + sVar2) & *(byte *)(sVar1 + 0x40848da2))) {
        UNRECOVERED_JUMPTABLE = (code *)0x40848d1c;
        goto LAB_40848c22;
      }
      sVar2 = sVar2 + -1;
    } while (sVar2 != -1);
    sVar1 = sVar1 + -1;
  } while (sVar1 != -1);
  UNRECOVERED_JUMPTABLE = (code *)0x40848b98;
LAB_40848c22:
  *(undefined1 *)(in_A0 + 0xc00) = 0x38;
  sVar1 = 3;
  do {
    *unaff_A2 = *unaff_A2;
    *(undefined1 *)(in_A0 + 0x600) = (&stack0x00000000)[sVar1];
    sVar1 = sVar1 + -1;
  } while (sVar1 != -1);
  *(undefined1 *)(in_A0 + 0xa00) = unaff_D4b;
                    /* WARNING: Could not recover jumptable at 0x40848c3e. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*UNRECOVERED_JUMPTABLE)();
  return;
}


