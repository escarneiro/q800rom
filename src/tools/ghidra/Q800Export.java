// Q800Export.java - Ghidra headless post-script: export the code/data map of the ROM.
// Arg 0: output file. Lines:
//   I <addr> <len>          instruction
//   F <addr> <name>         function entry
//   S <addr> <len>          defined string data
//   R <from> <to>           code reference from an instruction to an address
//@category Q800

import java.io.PrintWriter;

import ghidra.app.script.GhidraScript;
import ghidra.program.model.listing.Data;
import ghidra.program.model.listing.DataIterator;
import ghidra.program.model.listing.Function;
import ghidra.program.model.listing.Instruction;
import ghidra.program.model.listing.InstructionIterator;

public class Q800Export extends GhidraScript {
    @Override
    public void run() throws Exception {
        String[] args = getScriptArgs();
        int ni = 0, nf = 0, ns = 0;
        try (PrintWriter w = new PrintWriter(args[0])) {
            InstructionIterator it = currentProgram.getListing().getInstructions(true);
            while (it.hasNext()) {
                Instruction ins = it.next();
                w.printf("I %08X %d%n", ins.getAddress().getOffset(), ins.getLength());
                ni++;
            }
            for (Function f : currentProgram.getFunctionManager().getFunctions(true)) {
                w.printf("F %08X %s%n", f.getEntryPoint().getOffset(), f.getName());
                nf++;
            }
            DataIterator di = currentProgram.getListing().getDefinedData(true);
            while (di.hasNext()) {
                Data d = di.next();
                if (d.hasStringValue()) {
                    w.printf("S %08X %d%n", d.getAddress().getOffset(), d.getLength());
                    ns++;
                }
            }
        }
        println("Q800Export: " + ni + " instructions, " + nf + " functions, " + ns + " strings");
    }
}
