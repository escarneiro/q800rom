// Decompiled by Ghidra from QUADRA800.ROM at 40804052

/* WARNING: Control flow encountered bad instruction data */
/* WARNING: Removing unreachable block (ram,0x40804088) */
/* WARNING: Removing unreachable block (ram,0x4080409a) */

void EarlyCpuDetect(void)

{
  code *UNRECOVERED_JUMPTABLE;
  
  invalidateCacheLines(3);
                    /* WARNING: Could not recover jumptable at 0x408040a2. Too many branches */
                    /* WARNING: Treating indirect jump as call */
  (*UNRECOVERED_JUMPTABLE)();
  return;
}


