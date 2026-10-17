// Decompiled by Ghidra from QUADRA800.ROM at 408bd64e

/* WARNING: Control flow encountered bad instruction data */

void OS_HUnlock(void)

{
  int in_A1;
  undefined1 *unaff_A3;
  
  *(undefined1 *)(in_A1 + -2) = *unaff_A3;
                    /* WARNING: Bad instruction - Truncating control flow here */
  halt_baddata();
}


