// Decompiled by Ghidra from QUADRA800.ROM at 40809a88

/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

void InitTrapDispatcher(void)

{
  byte bVar1;
  int iVar2;
  short sVar3;
  ushort uVar4;
  byte *pbVar5;
  byte *pbVar7;
  int *piVar8;
  int iVar9;
  byte *pbVar6;
  
  iVar2 = _DAT_000002ae;
  piVar8 = (int *)0xe00;
  sVar3 = 0x3ff;
  pbVar6 = (byte *)(*(int *)(_DAT_000002ae + 0x22) + _DAT_000002ae);
  iVar9 = _DAT_000002ae;
  do {
    pbVar5 = pbVar6 + 1;
    bVar1 = *pbVar6;
    if ((char)bVar1 < '\0') {
      uVar4 = bVar1 & 0x7f;
      if ((bVar1 & 0x7f) != 0) {
        pbVar7 = pbVar5;
        if (uVar4 != 0x7f) goto LAB_40809ab8;
        pbVar7 = pbVar6 + 5;
        iVar9 = iVar2 + *(int *)pbVar5;
        goto LAB_40809abe;
      }
      *piVar8 = 0x40809ae6;
    }
    else {
      uVar4 = CONCAT11(bVar1,*pbVar5);
      pbVar7 = pbVar6 + 2;
LAB_40809ab8:
      if ((ushort)(uVar4 * 2) == 0) {
        _DAT_00000028 = TrapDispatcher;
        if (DAT_0000012f == '\x04') {
          _DAT_000006f4 = 0x40885030;
        }
        return;
      }
      iVar9 = (short)(uVar4 * 2) + iVar9;
LAB_40809abe:
      *piVar8 = iVar9;
      pbVar5 = pbVar7;
    }
    piVar8 = piVar8 + 1;
    sVar3 = sVar3 + -1;
    pbVar6 = pbVar5;
    if (sVar3 == -1) {
      piVar8 = (int *)0x400;
    }
  } while( true );
}


