/*
 os/mmutablespad.s - padding after QuickDraw
 From MMUTABLESPAD (0x40840EF0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.
*/

/* QDEXTEND / MMUTABLESPAD: reserved space after QuickDraw (zeros). */
QDEXTEND:
MMUTABLESPAD:
    .fill   0x1240, 1, 0x00
