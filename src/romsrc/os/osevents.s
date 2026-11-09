/*
 os/osevents.s - OS Event Manager
 From EVENTS (0x4080B3A0). Grouping inferred from Apple's routine names (MPW ROM map);
 Apple's actual source modules are not known.

 Comments were inferred from the code (and Inside Macintosh), not taken from Apple.
 Event queue elements are 22 bytes: link, type (+4), what (+6), message, when, where,
 modifiers; a free element has what = -1.
*/

/*
 _PostEvent(a0 = what, d0 = message): add an event to the queue if SysEvtMask allows
 it (after the Power Manager activity patch). If the queue is full, the oldest event
 is reused. Result 0, or 1 if masked out.
*/
trap_PostEvent:
EVENTS:
POSTEVENT:
    jbsr OSEVENTMGRPATCH
    btst %d1,%d2
    jbne EVENTS_E
    moveq #1,%d0
    rts
EVENTS_E:               /* find a free element (interrupts off) */
    movew %sr,%sp@-
    movel %d0,%sp@-
    movew %a0,%sp@-
    moveal SysEvtBuf,%a0
    addql #6,%a0
    moveq #22,%d0
    moveq #-1,%d1
    subaw %d0,%a0
    movew EvtBufCnt,%d2
    oriw #1792,%sr
EVENTS_28:              /* next element */
    addaw %d0,%a0
    cmpw %a0@,%d1
    dbeq %d2,EVENTS_28
    lea EventQueue,%a1
    jbeq EVENTS_40
    moveal %a1@(2),%a0
    movel %a0@,%a1@(2)
    addql #6,%a0
EVENTS_40:              /* fill it in, add the time, mouse and modifiers, enqueue it */
    movew %sp@+,%a0@
    movel %sp@+,%a0@(2)
    jbsr POSTEVENT_5A
    subql #6,%a0
    movew #4,%a0@(4)
    jsr %pc@(trap_Enqueue)
    movew %sp@+,%sr
    moveq #0,%d0
    rts

/*
 POSTEVENT_5A: when (Ticks), where (Mouse), modifiers (from KeyMap) and the mouse
 button into the event record at a0.
*/
POSTEVENT_5A:
    movel Ticks,%a0@(6)
    movel Mouse_v,%a0@(10)
    movew KeyMap_6,%d1
    rolw #1,%d1
    moveb %d1,%a0@(14)
    moveb MBState,%a0@(15)
    rts

/*
 _OSEventAvail(d0 = mask, a0 = event record): copy the first matching event (left in
 the queue). Generates auto-key events when a key is held. Result 0, or -1 (null
 event) if none.
*/
trap_OSEventAvail:
OSEVENTAVAIL:
    lea EventQueue,%a1
    movew %sr,%sp@-
    oriw #1792,%sr
    movel %a1@(2),%d1
    jbeq OSEVENTAVAIL_1E
OSEVENTAVAIL_10:        /* next event: in the mask? */
    moveal %d1,%a1
    movew %a1@(6),%d1
    btst %d1,%d0
    jbne OSEVENTAVAIL_64
    movel %a1@,%d1
    jbne OSEVENTAVAIL_10
OSEVENTAVAIL_1E:        /* none: auto-key due? (KeyThresh, KeyRepThresh) */
    andw SysEvtMask,%d0
    btst #5,%d0
    jbeq OSEVENTAVAIL_7A
    movew KbdVers,%d0
    swap %d0
    movew KeyLast,%d0
    tstl %d0
    jbeq OSEVENTAVAIL_7A
    movel Ticks,%d1
    movel %d1,%d2
    subl KeyTime,%d1
    cmpw KeyThresh,%d1
    jblt OSEVENTAVAIL_7A
    subl KeyRepTime,%d2
    cmpw KeyRepThresh,%d2
    jblt OSEVENTAVAIL_7A
    movel Ticks,KeyRepTime
    movel %a0,%sp@-
    moveaw #5,%a0
    jbsr trap_PostEvent
    moveal %a0,%a1
    moveal %sp@+,%a0
OSEVENTAVAIL_64:        /* found: copy it out */
    movew %sp@+,%sr
    moveq #4,%d0
    moveml %a0-%a1,%sp@-
    addql #6,%a1
    jbsr OSEVENTAVAILPATCH
    moveml %sp@+,%a0-%a1
    rts
OSEVENTAVAIL_7A:        /* null event */
    jbsr POSTEVENT_5A
    movew %sp@+,%sr
    clrw %a0@
    clrl %a0@(2)
    moveq #-1,%d0
    rts

/*
 _GetOSEvent: the same, and remove the event from the queue (then the Script Manager's
 post-processing).
*/
trap_GetOSEvent:
GETOSEVENT:
    jbsr trap_OSEventAvail
    jbne GETOSEVENT_14
    movel %a0,%sp@-
    moveal %a1,%a0
    lea EventQueue,%a1
    jbsr GETOSEVENT_1E
    moveal %sp@+,%a0
    moveq #0,%d0
GETOSEVENT_14:          /* Script Manager hook */
    bigjmp SMGRPOSTMUNGING, a1

GETOSEVENT_1E:          /* dequeue the element at a0, mark it free */
    jsr %pc@(trap_Dequeue)
    movew #-1,%a0@(6)
    rts

/*
 _FlushEvents(d0 = remove mask low, stop mask high): remove the matching events up to
 the first stop event. Result: the stop event's type, or 0.
*/
trap_FlushEvents:
FLUSHEVENTS:
    movew %sr,%sp@-
    moveml %d3-%d4,%sp@-
    moveq #-1,%d1
    movel %d1,LastSPExtra
    movel %d0,%d1
    swap %d1
    movew %d0,%d4
    andw FlEvtMask,%d4
    lea EventQueue,%a1
    oriw #1792,%sr
    movel %a1@(2),%d3
    jbeq FLUSHEVENTS_3A
FLUSHEVENTS_24:         /* next event */
    moveal %d3,%a0
    movel %a0@,%d3
    movew %a0@(6),%d2
    btst %d2,%d1
    jbne FLUSHEVENTS_3C
    btst %d2,%d4
    jbeq FLUSHEVENTS_36
    jbsr GETOSEVENT_1E
FLUSHEVENTS_36:         /* (removed) */
    tstl %d3
    jbne FLUSHEVENTS_24
FLUSHEVENTS_3A:         /* none stopped it: 0 */
    moveq #0,%d2
FLUSHEVENTS_3C:         /* return */
    moveml %sp@+,%d3-%d4
    movew %d2,%d0
    extl %d0
    movew %sp@+,%sr
    rts
    .long   0x00000000, 0x00000000, 0x00000000	| 4080B514
