/*
 patches/hooks.s - new code in the free space before the fixed region at 0x408F0000
 (0x408EF0BE..0x408EFFFF, 3906 bytes in this layout).

 Every ROM routine stays where it is: Mac OS 8.1 uses about 900 ROM addresses directly
 (docs/macos81_rom_refs.md), so to stay compatible with it nothing before them may
 move. A change to a routine is made as a hook: the first
 instructions of the routine are replaced by "jmp HOOK" (same size, padded with nops)
 and moved here, after the new code, followed by a jump back.
*/


