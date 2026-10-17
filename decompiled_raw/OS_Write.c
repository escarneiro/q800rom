// Decompiled by Ghidra from QUADRA800.ROM at 4080bb9a

/* WARNING: Control flow encountered bad instruction data */
/* WARNING: Possible PIC construction at 0x4080bb80: Changing call to branch */
/* WARNING: Removing unreachable block (ram,0x4080bb84) */
/* WARNING: Globals starting with '_' overlap smaller symbols at the same address */

undefined4 thunk_FUN_40884c18(void)

{
  ushort uVar1;
  byte *pbVar2;
  byte bVar3;
  undefined4 uVar4;
  undefined4 in_D0;
  int iVar5;
  int iVar6;
  int extraout_A0;
  int in_A0;
  int extraout_A1;
  undefined8 uVar7;
  ulonglong uVar8;
  
  if ((DAT_00000dd5 & 1) != 0) {
                    /* WARNING: Bad instruction - Truncating control flow here */
    halt_baddata();
  }
  if (-1 < *(short *)(in_A0 + 0x18)) {
    return in_D0;
  }
  uVar8 = func_0x4080b6ac();
  uVar4 = (undefined4)(uVar8 >> 0x20);
  if ((char)(byte)uVar8 < '\x04') {
    *(undefined4 *)(extraout_A0 + 0x28) = 0;
  }
  *(undefined2 *)(extraout_A0 + 0x10) = 1;
  *(short *)(extraout_A0 + 6) = (short)uVar8;
  *(undefined2 *)(extraout_A0 + 4) = 2;
  if ((*(byte *)(extraout_A1 + 4) & 2) != 0) {
    uVar4 = 0xffffffe4;
    uVar7 = CONCAT44(0xffffffe4,extraout_A1);
    if ((*(byte *)(extraout_A1 + 5) & 0x20) != 0) {
      iVar6 = extraout_A0;
      if ((uVar8 & 0x200) == 0) {
        if ((uVar8 & 0x400) == 0) {
          *(undefined4 *)(extraout_A0 + 0xc) = 0;
          register0x0000003c = (BADSPACEBASE *)&stack0xfffffff8;
        }
        *(ushort *)((int)register0x0000003c + -2) =
             (ushort)(byte)(((byte)uVar8 < 3) << 4 | (extraout_A1 < 0) << 3 |
                           (extraout_A1 == 0) << 2);
        *(undefined4 *)((int)register0x0000003c + -6) = 0x4080b606;
        uVar7 = func_0x40809930();
        pbVar2 = (byte *)((int)uVar7 + 5);
        bVar3 = *pbVar2;
        *pbVar2 = bVar3 | 0x80;
        if ((bVar3 & 0x80) != 0) {
          return 0;
        }
        iVar6 = *(int *)((int)uVar7 + 8);
      }
      uVar4 = (undefined4)((ulonglong)uVar7 >> 0x20);
      if ((*(char *)(iVar6 + 7) != '\x04') && (*(byte *)(iVar6 + 7) != 5)) {
        if (*(int *)(iVar6 + 0x24) == 0) {
          *(undefined2 *)((int)register0x0000003c + -2) = 0;
          *(undefined4 *)((int)register0x0000003c + -6) = 0;
                    /* WARNING: Bad instruction - Truncating control flow here */
          halt_baddata();
        }
        uVar1 = *(ushort *)(iVar6 + 0x2c);
        iVar5 = *(int *)(iVar6 + 0x2e);
        bVar3 = (byte)uVar1 << 7;
        uVar4 = CONCAT31((int3)(CONCAT22((short)((ulonglong)uVar7 >> 0x30),uVar1) >> 8),
                         (*(byte *)(iVar6 + 7) < 5) << 6 | (byte)uVar1 >> 2 | bVar3);
        if (bVar3 != 0) {
          if ((uVar1 & 2) != 0) {
            iVar5 = *(int *)((int)uVar7 + 0x10) + iVar5;
          }
          *(int *)((int)uVar7 + 0x10) = iVar5;
        }
      }
      *(undefined4 *)((int)register0x0000003c + -4) = _DAT_000006d4;
      return uVar4;
    }
  }
  *(short *)(extraout_A0 + 0x10) = (short)uVar4;
  return uVar4;
}


