// Q800Seed.java - Ghidra headless pre-script: seed code entry points for the Quadra 800 ROM.
// Arg 0: seed file from tools/rom_seeds.py, lines "ADDR KIND [name]":
//   C = code entry (disassembled, becomes a function), X = executed PC (disassembled),
//   L = label only (data, e.g. resources).
//@category Q800

import java.io.BufferedReader;
import java.io.FileReader;

import ghidra.app.script.GhidraScript;
import ghidra.program.model.address.Address;
import ghidra.program.model.symbol.SourceType;

public class Q800Seed extends GhidraScript {
    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        if (args.length > 1 && args[1].equals("aggressive")) {
            setAnalysisOption(currentProgram, "Aggressive Instruction Finder", "true");
            println("Q800Seed: Aggressive Instruction Finder enabled");
        }
        int named = 0, plain = 0;
        try (BufferedReader r = new BufferedReader(new FileReader(args[0]))) {
            String line;
            while ((line = r.readLine()) != null) {
                line = line.trim();
                if (line.isEmpty() || line.startsWith("#")) continue;
                String[] p = line.split("\\s+");
                Address a = toAddr(Long.parseLong(p[0], 16));
                String kind = p[1];
                String name = p.length > 2 ? p[2] : null;
                if ((kind.equals("C") || kind.equals("X")) && getInstructionAt(a) == null) disassemble(a);
                if (name != null) createLabel(a, name, true, SourceType.USER_DEFINED);
                if (kind.equals("C")) {
                    if (getFunctionAt(a) == null) createFunction(a, name);
                    named++;
                } else {
                    plain++;
                }
            }
        }
        println("Q800Seed: " + named + " named entry points, " + plain + " traced PCs");
    }
}
