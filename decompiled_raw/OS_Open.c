// Decompiled by Ghidra from QUADRA800.ROM at 4080b766

/* WARNING: Control flow encountered bad instruction data */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void OS_Open(void)

{
  int *piVar1;
  int *piVar2;
  byte bVar3;
  short sVar4;
  undefined2 uVar5;
  undefined2 in_D1w;
  char extraout_D1b;
  char cVar6;
  short sVar7;
  short sVar8;
  int in_A0;
  undefined4 *puVar9;
  int extraout_A1;
  int extraout_A1_00;
  int iVar10;
  undefined4 *puVar11;
  bool bVar12;
  undefined1 uVar13;
  char cStack_1f;
  char cStack_1e;
  undefined4 uStack_20;
  char cStack_1d;
  
  *(undefined2 *)(in_A0 + 6) = in_D1w;
  cVar6 = **(char **)(in_A0 + 0x12);
  sVar8 = _DAT_000001d2;
  puVar11 = _DAT_0000011c;
  if ((char)*(undefined2 *)(in_A0 + 0x1a) != '@') {
    bVar12 = (*(char **)(in_A0 + 0x12))[1] == '.';
    if (!bVar12) {
      (*(code *)0x4084bfe2)();
      return;
    }
    func_0x4080b6dc();
    sVar8 = _DAT_000001d2;
    puVar11 = _DAT_0000011c;
    cVar6 = extraout_D1b;
    if (bVar12) {
      func_0x4080b708();
      sVar8 = -0x31;
      sVar7 = _DAT_000001d2 + -0x30;
      puVar11 = _DAT_0000011c + 0x30;
LAB_4080b7b0:
      do {
        piVar2 = (int *)*puVar11;
        if (piVar2 != (int *)0x0) {
          piVar1 = (int *)*piVar2;
          if (piVar1 == (int *)0x0) {
            *puVar11 = 0;
            goto LAB_4080b7b0;
          }
          if (((*(char *)(piVar1 + 10) == cStack_1f) && (*(char *)((int)piVar1 + 0x29) == cStack_1e)
              ) && (*(char *)((int)piVar1 + 0x32) == cStack_1d)) {
            if (((int *)*piVar1 == (int *)0x0) || (*(int *)*piVar1 == 0)) {
                    /* WARNING: Bad instruction - Truncating control flow here */
              halt_baddata();
            }
            iVar10 = *piVar2;
            if ((*(byte *)(iVar10 + 4) & 0x40) != 0) {
              if ((*(byte *)(iVar10 + 5) & 0x40) == 0) {
                    /* WARNING: Bad instruction - Truncating control flow here */
                halt_baddata();
              }
                    /* WARNING: Bad instruction - Truncating control flow here */
              halt_baddata();
            }
            *(short *)(in_A0 + 0x18) = sVar8;
            uVar5 = 0xffe9;
            if (((*(byte *)(iVar10 + 4) ^ (*(byte *)(in_A0 + 0x1b) | *(byte *)(iVar10 + 4))) & 3) ==
                0) {
              bVar3 = *(byte *)(iVar10 + 5);
              *(byte *)(iVar10 + 5) = bVar3 | 0x20;
              if (((bVar3 & 0x20) == 0) || (*(char *)(in_A0 + 0x1b) == '@')) {
                bVar12 = false;
                uVar13 = 0;
                uVar5 = func_0x4080b650();
                if (bVar12) {
                  *(undefined2 *)(in_A0 + 0x18) = 0;
                  *(byte *)(extraout_A1 + 5) = *(byte *)(extraout_A1 + 5) & 0xdf;
                  iVar10 = extraout_A1;
                }
                else {
                  uVar5 = func_0x4080b6dc();
                  if ((bool)uVar13) {
                    func_0x4080b708();
                    /* WARNING: Bad instruction - Truncating control flow here */
                    halt_baddata();
                  }
                  iVar10 = extraout_A1_00;
                  if ((*(byte *)(extraout_A1_00 + 4) & 0x40) != 0) goto LAB_4080ba9a;
                }
                if ((*(byte *)(iVar10 + 5) & 0x40) != 0) {
                    /* WARNING: Bad instruction - Truncating control flow here */
                  halt_baddata();
                }
              }
              else {
                uVar5 = 0;
              }
            }
LAB_4080ba9a:
            *(undefined2 *)(in_A0 + 0x10) = uVar5;
            return;
          }
        }
        sVar8 = sVar8 + -1;
        sVar4 = sVar7 + -1;
        bVar12 = sVar7 < 1;
        sVar7 = sVar4;
        puVar11 = puVar11 + 1;
        if (sVar4 == 0 || bVar12) {
          _DAT_00000b9e = 0xffff;
                    /* WARNING: Bad instruction - Truncating control flow here */
          halt_baddata();
        }
      } while( true );
    }
  }
  do {
    if (((int *)*puVar11 != (int *)0x0) && (piVar2 = *(int **)*puVar11, piVar2 != (int *)0x0)) {
      puVar9 = (undefined4 *)*piVar2;
      if ((*(byte *)((int)piVar2 + 5) & 0x40) != 0) {
        if (puVar9 == (undefined4 *)0x0) goto LAB_4080b906;
        puVar9 = (undefined4 *)*puVar9;
      }
      if ((puVar9 != (undefined4 *)0x0) && (cVar6 == *(char *)((int)puVar9 + 0x12))) {
                    /* WARNING: Bad instruction - Truncating control flow here */
        halt_baddata();
      }
    }
LAB_4080b906:
    sVar7 = sVar8 + -1;
    bVar12 = sVar8 < 1;
    sVar8 = sVar7;
    puVar11 = puVar11 + 1;
    if (sVar7 == 0 || bVar12) {
      _DAT_00000b9e = 0xffff;
                    /* WARNING: Bad instruction - Truncating control flow here */
      halt_baddata();
    }
  } while( true );
}


