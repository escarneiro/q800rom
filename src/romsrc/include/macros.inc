/* macros.inc - assembler macros for the hand-maintained ROM source */

/*
 bigjsr / bigjmp: call or jump to any address in the ROM, position-independent:
     lea  (target-here):l,%reg
     jsr  %pc@(here,%reg:l)        (bigjmp: jmp)
 The offset is a 32-bit constant, so it reaches the whole ROM wherever the code is.
*/
    .macro  bigjsr target, reg=a0
1:  lea     (\target-1b):l,%\reg
    jsr     %pc@(1b,%\reg:l)
    .endm

    .macro  bigjmp target, reg=a0
1:  lea     (\target-1b):l,%\reg
    jmp     %pc@(1b,%\reg:l)
    .endm

/*
 biglea: load the address of any label in the ROM, position-independent:
     lea  (target-here):l,%reg
     lea  %pc@(here,%reg:l),%reg
*/
    .macro  biglea target, reg=a0
1:  lea     (\target-1b):l,%\reg
    lea     %pc@(1b,%\reg:l),%\reg
    .endm
