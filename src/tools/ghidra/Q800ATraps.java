// Q800ATraps.java - Ghidra headless post-script: follow code across Mac A-line traps.
// Ghidra's 68k language does not decode A-line words ($Axxx, Toolbox/OS trap calls), so
// disassembly stops at every trap. This script finds every A-line word reached by code flow
// (fall-through or branch), records it, and resumes disassembly after it; repeated until
// no new code appears. Arg 0: output file, one "A <addr>" line per trap word.
//@category Q800

import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.TreeSet;

import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.listing.InstructionIterator;
import ghidra.program.model.mem.Memory;

public class Q800ATraps extends GhidraScript {
    // Traps that never return: do not continue after them.
    private static final int[] NO_RETURN = {0xA9F4 /* _ExitToShell */, 0xA9F2 /* _Launch */,
                                            0xA9F3 /* _Chain */};

    private boolean isAWord(Address a) {
        try {
            Memory m = currentProgram.getMemory();
            if (!m.contains(a) || (a.getOffset() & 1) != 0) return false;
            int w = m.getShort(a) & 0xFFFF;
            return (w & 0xF000) == 0xA000;
        } catch (Exception e) {
            return false;
        }
    }

    private boolean noReturn(Address a) throws Exception {
        int w = currentProgram.getMemory().getShort(a) & 0xFFFF;
        for (int n : NO_RETURN) if (w == n) return true;
        return false;
    }

    @Override
    public void run() throws Exception {
        TreeSet<Address> traps = new TreeSet<>();
        for (int pass = 0; pass < 200; pass++) {
            List<Address> found = new ArrayList<>();
            InstructionIterator it = currentProgram.getListing().getInstructions(true);
            while (it.hasNext()) {
                Instruction ins = it.next();
                List<Address> cand = new ArrayList<>();
                Address ft = ins.getFallThrough();
                if (ft != null) cand.add(ft);
                for (Address f : ins.getFlows()) cand.add(f);
                for (Address c : cand) {
                    if (!traps.contains(c) && getInstructionAt(c) == null && isAWord(c)) found.add(c);
                }
            }
            // also A-words directly after a recorded trap (back-to-back trap calls)
            for (Address t : new ArrayList<>(traps)) {
                Address n = t.add(2);
                if (!traps.contains(n) && getInstructionAt(n) == null && isAWord(n) && !noReturn(t))
                    found.add(n);
            }
            if (found.isEmpty()) break;
            int newCode = 0;
            for (Address a : found) {
                if (!traps.add(a)) continue;
                if (noReturn(a)) continue;
                Address n = a.add(2);
                if (getInstructionAt(n) == null && !isAWord(n)) {
                    disassemble(n);
                    newCode++;
                }
            }
            println("Q800ATraps: pass " + pass + ": " + found.size() + " trap words, " + newCode
                    + " new flows");
        }
        try (PrintWriter w = new PrintWriter(getScriptArgs()[0])) {
            for (Address a : traps) w.printf("A %08X%n", a.getOffset());
        }
        println("Q800ATraps: " + traps.size() + " A-line trap calls followed");
    }
}
