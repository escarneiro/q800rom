// Decompiled by Ghidra from QUADRA800.ROM at 40802f34

/* WARNING: Removing unreachable block (ram,0x40804ab8) */
/* WARNING: Switch with 1 destination removed at 0x40804712 */
/* WARNING: Switch with 1 destination removed at 0x40804ba0 */

void thunk_FUN_40804b08(void)

{
  byte bVar1;
  byte bVar2;
  byte *pbVar3;
  uint uVar4;
  uint uVar5;
  undefined3 uVar6;
  undefined4 uVar7;
  undefined4 uVar8;
  char cVar10;
  ushort uVar9;
  ushort unaff_D2w;
  int *piVar11;
  int *piVar12;
  int iVar13;
  code *UNRECOVERED_JUMPTABLE_00;
  code *UNRECOVERED_JUMPTABLE;
  bool bVar14;
  
LAB_40804b80:
  uVar5 = 0;
  do {
    uVar4 = uVar5;
    bVar14 = uRam5ffffffc == uVar4;
    uVar5 = uRam5ffffffc;
    if (!bVar14) goto LAB_40804ba0;
    uVar5 = ~uVar4;
  } while (~uVar4 != 0);
  uVar5 = uRam5ffffffc >> 0x10;
  bVar14 = false;
  if ((short)(uRam5ffffffc >> 0x10) == -0x5aa6) {
    uVar5 = uRam5ffffffc & 0xffff;
    bVar14 = true;
  }
LAB_40804ba0:
  uRam5ffffffc = uVar4;
  if (bVar14) {
    piVar11 = (int *)0x408d27fc;
    do {
      piVar11 = piVar11 + 1;
      if (*piVar11 == 0) {
        do {
                    /* WARNING: Do nothing block with infinite loop */
        } while( true );
      }
      piVar12 = (int *)((int)piVar11 + *piVar11);
    } while ((short)uVar5 != *(short *)(piVar12 + 0xf));
    if ((uVar5 & 0x800) == 0) goto code_r0x40802f56;
    iVar13 = *piVar12;
    uVar5 = *(uint *)((int)piVar12 + iVar13 + -0x14);
    uVar9 = 0;
    if ((uVar5 & 4) != 0) {
      pbVar3 = *(byte **)((int)piVar12 + iVar13 + 8);
      bVar1 = pbVar3[0x600];
      pbVar3[0x600] = *(byte *)((int)piVar12 + iVar13 + -0xc) & bVar1;
      bVar2 = pbVar3[0x1e00];
      pbVar3[0x600] = bVar1;
      pbVar3[0x1e00] = pbVar3[0x1e00];
      bVar1 = pbVar3[0x400];
      pbVar3[0x400] = *(byte *)((int)piVar12 + iVar13 + -0xb) & bVar1;
      uVar9 = CONCAT11(bVar2,*pbVar3);
      pbVar3[0x400] = bVar1;
      unaff_D2w = (ushort)*pbVar3;
      *pbVar3 = *pbVar3;
    }
    uVar4 = (uint)uVar9 << 0x10;
    if ((uVar5 & 0x800) != 0) {
      pbVar3 = *(byte **)((int)piVar12 + iVar13 + 0x2c);
      bVar1 = pbVar3[0x600];
      pbVar3[0x600] = *(byte *)((int)piVar12 + iVar13 + -10) & bVar1;
      bVar2 = pbVar3[0x1e00];
      pbVar3[0x600] = bVar1;
      pbVar3[0x1e00] = pbVar3[0x1e00];
      bVar1 = pbVar3[0x400];
      pbVar3[0x400] = *(byte *)((int)piVar12 + iVar13 + -9) & bVar1;
      uVar4 = CONCAT31(CONCAT21(uVar9,bVar2),*pbVar3);
      pbVar3[0x400] = bVar1;
      unaff_D2w = (ushort)*pbVar3;
      *pbVar3 = *pbVar3;
    }
    piVar12 = (int *)((int)piVar11 + *piVar11);
    if ((piVar12[8] & uVar4) == piVar12[9]) goto code_r0x40802f56;
    goto LAB_40804b80;
  }
  if ((char)unaff_D2w == '\0') goto code_r0x40802f6e;
  piVar11 = (int *)0x4080322c;
  do {
    piVar11 = piVar11 + 1;
    if (*piVar11 == 0) {
code_r0x40802f6e:
                    /* WARNING: Could not recover jumptable at 0x40802f7c. Too many branches */
                    /* WARNING: Treating indirect jump as call */
      (*(code *)(iRam40803210 + 0x40803210 + *(int *)(iRam40803210 + 0x40803208)))();
      return;
    }
    piVar12 = (int *)((int)piVar11 + *piVar11);
  } while (unaff_D2w != *(ushort *)((int)piVar12 + 0x12));
code_r0x40802f56:
  if (piVar12[6] == 0) {
    uVar5 = *(uint *)((int)piVar12 + *piVar12 + -0x14);
    if ((uVar5 & 0x2000) != 0) {
      pbVar3 = (byte *)(*(int *)((int)piVar12 + *piVar12 + 0x34) + 0x13);
      uVar8 = CONCAT31((uint3)*pbVar3,0xff);
      *pbVar3 = 0xff;
      do {
        cVar10 = (char)uVar8;
        uVar6 = (undefined3)((uint)uVar8 >> 8);
        *pbVar3 = -cVar10;
        uVar9 = (ushort)CONCAT31(uVar6,cVar10 * -2);
        if ((char)(cVar10 * -2) == '\0') break;
        uVar8 = CONCAT31(uVar6,cVar10 * '\x02');
        uVar9 = (ushort)uVar8;
      } while (((cVar10 * '\x02' ^ *pbVar3) & 0x9f) == 0);
      *pbVar3 = 0x7f;
      *pbVar3 = (byte)(uVar9 >> 8);
      if ((uVar9 & 0xff) != 0) {
        uVar5 = uVar5 & 0xffff9fff;
      }
    }
    if ((uVar5 & 0x800) != 0) {
      pbVar3 = (byte *)(*(int *)((int)piVar12 + *piVar12 + 0x2c) + 0x1c00);
      bVar1 = *pbVar3;
      *pbVar3 = 0xff;
      uVar8 = CONCAT31((uint3)bVar1,0xff);
      do {
        uVar7 = uVar8;
        cVar10 = (char)uVar7;
        *pbVar3 = -cVar10;
        if (((char)(cVar10 * -2) == '\0') || ((byte)(cVar10 * '\x02') != *pbVar3)) break;
        uVar8 = CONCAT31((int3)((uint)uVar7 >> 8),cVar10 * '\x02');
      } while ((byte)-*pbVar3 == (byte)(cVar10 * -2));
      *pbVar3 = 0x7f;
      *pbVar3 = (byte)((uint)uVar7 >> 8);
    }
    if ((uVar5 & 0x10000) == 0) {
      if ((uVar5 & 0x20000) == 0) {
        uVar4 = uVar5 & 0xfffc77ff;
        if ((uVar5 & 0x8000) != 0) {
          uVar4 = uVar5 & 0xfffc70ff;
        }
        uVar5 = uVar4 & 0xfeffffff;
        if ((uVar4 & 0x1000000) != 0) {
          iVar13 = *(int *)((int)piVar12 + *piVar12 + 0x60);
          while ((*(char *)(iVar13 + 0xc0) == '\x04' &&
                 (uVar4 = uVar5 & 0x2000000, uVar5 = uVar5 & 0xfdff78ff, uVar4 != 0))) {
            iVar13 = *(int *)((int)piVar12 + *piVar12 + 100);
          }
        }
        if ((uVar5 & 0x100000) != 0) {
          pbVar3 = *(byte **)((int)piVar12 + *piVar12 + 0x50);
          pbVar3[0x10] = 0xff;
          bVar1 = *pbVar3;
          pbVar3[0x10] = 0xff;
          *pbVar3 = 0xff;
          pbVar3[0x10] = 0;
          if ((*pbVar3 & 1) != 0) {
            pbVar3[0x10] = 0xff;
            *pbVar3 = 0;
            pbVar3[0x10] = 0xff;
          }
          pbVar3[0x10] = 0xff;
          *pbVar3 = bVar1;
        }
        goto code_r0x40802f60;
      }
      iVar13 = *(int *)((int)piVar12 + *piVar12 + 0x44);
      UNRECOVERED_JUMPTABLE = (code *)0x4080302c;
    }
    else {
      iVar13 = *(int *)((int)piVar12 + *piVar12 + 0x40);
      UNRECOVERED_JUMPTABLE = (code *)0x4080300e;
    }
    bVar1 = *(byte *)(iVar13 + -0x1c);
    *(byte *)(iVar13 + -0x1c) = bVar1 & 6 | 2;
    *(undefined2 *)(iVar13 + -0x1f) = *(undefined2 *)(iVar13 + -0x1f);
    *(byte *)(iVar13 + -0x1c) = bVar1 & 0xcf;
                    /* WARNING: Could not recover jumptable at 0x408047ae. Too many branches */
                    /* WARNING: Treating indirect jump as call */
    (*UNRECOVERED_JUMPTABLE)();
    return;
  }
code_r0x40802f60:
                    /* WARNING: Could not recover jumptable at 0x4080307a. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*UNRECOVERED_JUMPTABLE_00)();
  return;
}


