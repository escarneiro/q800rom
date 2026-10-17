// Decompiled by Ghidra from QUADRA800.ROM at 4080008c

/* WARNING: Control flow encountered bad instruction data */
/* WARNING: This function may have set the stack pointer */
/* WARNING: Removing unreachable block (ram,0x40804ab8) */
/* WARNING: Removing unreachable block (ram,0x40804088) */
/* WARNING: Removing unreachable block (ram,0x4080409a) */
/* WARNING: Switch with 1 destination removed at 0x40804712 */
/* WARNING: Switch with 1 destination removed at 0x40804ba0 */

void ResetStartup(void)

{
  byte bVar1;
  byte bVar2;
  byte *pbVar3;
  uint uVar4;
  uint uVar5;
  uint uVar6;
  undefined3 uVar7;
  undefined4 uVar8;
  undefined4 uVar9;
  char cVar11;
  ushort uVar10;
  ushort uVar12;
  int *piVar13;
  int *piVar14;
  int iVar15;
  code *UNRECOVERED_JUMPTABLE;
  bool bVar16;
  
  invalidateCacheLines(3);
  reset();
  piVar13 = (int *)0x40803d10;
  do {
    piVar13 = piVar13 + -1;
    if (*piVar13 == 0x40803d10) goto code_r0x40802e20;
  } while (*piVar13 != 0);
  uRam00000008 = 0x40803d10;
code_r0x40802e20:
  do {
    uVar12 = 0;
code_r0x40804b80:
    uVar6 = 0;
    do {
      uVar4 = uVar6;
      bVar16 = uRam5ffffffc == uVar4;
      uVar6 = uRam5ffffffc;
      if (!bVar16) goto code_r0x40804ba0;
      uVar6 = ~uVar4;
    } while (~uVar4 != 0);
    uVar6 = uRam5ffffffc >> 0x10;
    bVar16 = false;
    if ((short)(uRam5ffffffc >> 0x10) == -0x5aa6) {
      uVar6 = uRam5ffffffc & 0xffff;
      bVar16 = true;
    }
code_r0x40804ba0:
    uRam5ffffffc = uVar4;
    if (bVar16) {
      piVar13 = (int *)0x408d27fc;
      do {
        piVar13 = piVar13 + 1;
        if (*piVar13 == 0) {
          do {
                    /* WARNING: Do nothing block with infinite loop */
          } while( true );
        }
        piVar14 = (int *)((int)piVar13 + *piVar13);
      } while ((short)uVar6 != *(short *)(piVar14 + 0xf));
      if ((uVar6 & 0x800) == 0) goto code_r0x40802f56;
      iVar15 = *piVar14;
      uVar6 = *(uint *)((int)piVar14 + iVar15 + -0x14);
      uVar10 = 0;
      if ((uVar6 & 4) != 0) {
        pbVar3 = *(byte **)((int)piVar14 + iVar15 + 8);
        bVar1 = pbVar3[0x600];
        pbVar3[0x600] = *(byte *)((int)piVar14 + iVar15 + -0xc) & bVar1;
        bVar2 = pbVar3[0x1e00];
        pbVar3[0x600] = bVar1;
        pbVar3[0x1e00] = pbVar3[0x1e00];
        bVar1 = pbVar3[0x400];
        pbVar3[0x400] = *(byte *)((int)piVar14 + iVar15 + -0xb) & bVar1;
        uVar10 = CONCAT11(bVar2,*pbVar3);
        pbVar3[0x400] = bVar1;
        uVar12 = (ushort)*pbVar3;
        *pbVar3 = *pbVar3;
      }
      uVar4 = (uint)uVar10 << 0x10;
      if ((uVar6 & 0x800) != 0) {
        pbVar3 = *(byte **)((int)piVar14 + iVar15 + 0x2c);
        bVar1 = pbVar3[0x600];
        pbVar3[0x600] = *(byte *)((int)piVar14 + iVar15 + -10) & bVar1;
        bVar2 = pbVar3[0x1e00];
        pbVar3[0x600] = bVar1;
        pbVar3[0x1e00] = pbVar3[0x1e00];
        bVar1 = pbVar3[0x400];
        pbVar3[0x400] = *(byte *)((int)piVar14 + iVar15 + -9) & bVar1;
        uVar4 = CONCAT31(CONCAT21(uVar10,bVar2),*pbVar3);
        pbVar3[0x400] = bVar1;
        uVar12 = (ushort)*pbVar3;
        *pbVar3 = *pbVar3;
      }
      piVar14 = (int *)((int)piVar13 + *piVar13);
      if ((piVar14[8] & uVar4) == piVar14[9]) goto code_r0x40802f56;
      goto code_r0x40804b80;
    }
    if ((char)uVar12 == '\0') goto code_r0x40802f6e;
    piVar13 = (int *)0x4080322c;
    do {
      piVar13 = piVar13 + 1;
      if (*piVar13 == 0) {
code_r0x40802f6e:
                    /* WARNING: Could not recover jumptable at 0x40802f7c. Too many branches */
                    /* WARNING: Treating indirect jump as call */
        (*(code *)(iRam40803210 + 0x40803210 + *(int *)(iRam40803210 + 0x40803208)))();
        return;
      }
      piVar14 = (int *)((int)piVar13 + *piVar13);
    } while (uVar12 != *(ushort *)((int)piVar14 + 0x12));
code_r0x40802f56:
    piVar13 = (int *)((int)piVar14 + *piVar14);
    uVar6 = piVar14[6];
    if (uVar6 == 0) {
      uVar6 = piVar13[-5];
      if ((uVar6 & 0x2000) != 0) {
        pbVar3 = (byte *)(*(int *)((int)piVar14 + *piVar14 + 0x34) + 0x13);
        uVar9 = CONCAT31((uint3)*pbVar3,0xff);
        *pbVar3 = 0xff;
        do {
          cVar11 = (char)uVar9;
          uVar7 = (undefined3)((uint)uVar9 >> 8);
          *pbVar3 = -cVar11;
          uVar12 = (ushort)CONCAT31(uVar7,cVar11 * -2);
          if ((char)(cVar11 * -2) == '\0') break;
          uVar9 = CONCAT31(uVar7,cVar11 * '\x02');
          uVar12 = (ushort)uVar9;
        } while (((cVar11 * '\x02' ^ *pbVar3) & 0x9f) == 0);
        *pbVar3 = 0x7f;
        *pbVar3 = (byte)(uVar12 >> 8);
        if ((uVar12 & 0xff) != 0) {
          uVar6 = uVar6 & 0xffff9fff;
        }
      }
      if ((uVar6 & 0x800) != 0) {
        pbVar3 = (byte *)(*(int *)((int)piVar14 + *piVar14 + 0x2c) + 0x1c00);
        bVar1 = *pbVar3;
        *pbVar3 = 0xff;
        uVar9 = CONCAT31((uint3)bVar1,0xff);
        do {
          uVar8 = uVar9;
          cVar11 = (char)uVar8;
          *pbVar3 = -cVar11;
          if (((char)(cVar11 * -2) == '\0') || ((byte)(cVar11 * '\x02') != *pbVar3)) break;
          uVar9 = CONCAT31((int3)((uint)uVar8 >> 8),cVar11 * '\x02');
        } while ((byte)-*pbVar3 == (byte)(cVar11 * -2));
        *pbVar3 = 0x7f;
        *pbVar3 = (byte)((uint)uVar8 >> 8);
      }
      if ((uVar6 & 0x10000) != 0) {
        iVar15 = *(int *)((int)piVar14 + *piVar14 + 0x40);
        UNRECOVERED_JUMPTABLE = (code *)0x4080300e;
code_r0x4080477c:
        bVar1 = *(byte *)(iVar15 + -0x1c);
        *(byte *)(iVar15 + -0x1c) = bVar1 & 6 | 2;
        *(undefined2 *)(iVar15 + -0x1f) = *(undefined2 *)(iVar15 + -0x1f);
        *(byte *)(iVar15 + -0x1c) = bVar1 & 0xcf;
                    /* WARNING: Could not recover jumptable at 0x408047ae. Too many branches */
                    /* WARNING: Treating indirect jump as call */
        (*UNRECOVERED_JUMPTABLE)();
        return;
      }
      if ((uVar6 & 0x20000) != 0) {
        iVar15 = *(int *)((int)piVar14 + *piVar14 + 0x44);
        UNRECOVERED_JUMPTABLE = (code *)0x4080302c;
        goto code_r0x4080477c;
      }
      uVar4 = uVar6 & 0xfffc77ff;
      if ((uVar6 & 0x8000) != 0) {
        uVar4 = uVar6 & 0xfffc70ff;
      }
      uVar5 = uVar4 & 0xfeffffff;
      if ((uVar4 & 0x1000000) != 0) {
        iVar15 = *(int *)((int)piVar14 + *piVar14 + 0x60);
        while ((*(char *)(iVar15 + 0xc0) == '\x04' &&
               (uVar6 = uVar5 & 0x2000000, uVar5 = uVar5 & 0xfdff78ff, uVar6 != 0))) {
          iVar15 = *(int *)((int)piVar14 + *piVar14 + 100);
        }
      }
      uVar6 = uVar5 & 0xffefffff;
      if ((uVar5 & 0x100000) != 0) {
        pbVar3 = *(byte **)((int)piVar14 + *piVar14 + 0x50);
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
      piVar13 = (int *)(*piVar14 + (int)piVar14);
    }
    if ((uVar6 & 1) != 0) {
                    /* WARNING: Could not recover jumptable at 0x40802e3a. Too many branches */
                    /* WARNING: Treating indirect jump as call */
      (*(code *)(*piVar13 + 0x2e3e))();
      return;
    }
  } while( true );
}


