package org.jruby.ir.passes;

import org.jruby.ir.IRClosure;
import org.jruby.ir.IRScope;
import org.jruby.ir.IRFlags;
import org.jruby.ir.instructions.*;
import org.jruby.ir.operands.Operand;
import org.jruby.ir.operands.Variable;
import org.jruby.ir.representations.BasicBlock;

import java.util.*;

public class OptimizeDelegationPass extends CompilerPass {
    public static List<Class<? extends CompilerPass>> DEPENDENCIES = Arrays.<Class<? extends CompilerPass>>asList(CFGBuilder.class);

    @Override
    public String getLabel() {
        return "Delegated Variable Removal";
    }

    @Override
    public List<Class<? extends CompilerPass>> getDependencies() {
        return DEPENDENCIES;
    }

    @Override
    public Object execute(IRScope s, Object... data) {
        for (IRClosure c: s.getClosures()) {
            run(c, false, true);
        }

        s.computeScopeFlags();

        if (s.getFlags().contains(IRFlags.BINDING_HAS_ESCAPED))
            return null;

        if (!s.getFlags().contains(IRFlags.RECEIVES_CLOSURE_ARG))
            return null;

        optimizeDelegatedVars(s);

        return true;
    }

    @Override
    public boolean invalidate(IRScope s) {
        // Not reversible right now
        return false;
    }

    private static void optimizeDelegatedVars(IRScope s) {
        Map<Operand, Operand> unusedExplicitBlocks = new HashMap<Operand, Operand>();

        for (BasicBlock bb: s.cfg().getBasicBlocks()) {
            for (Instr i: bb.getInstrs()) {
                if (i instanceof ReifyClosureInstr) {
                    ReifyClosureInstr ri = (ReifyClosureInstr) i;
                    unusedExplicitBlocks.put(ri.getResult(), ri.getSource());
                } else {
                    Iterator<Operand> it = unusedExplicitBlocks.keySet().iterator();
                    while (it.hasNext()) {
                        Variable explicitBlock = (Variable) it.next();
                        if (usesVariableAsNonClosureArg(i, explicitBlock)) {
                            it.remove();
                        }
                    }
                }
            }
        }

        for (BasicBlock bb: s.cfg().getBasicBlocks()) {
            ListIterator<Instr> instrs = bb.getInstrs().listIterator();
            while (instrs.hasNext()) {
                Instr i = instrs.next();
                if (i instanceof ReifyClosureInstr) {
                    ReifyClosureInstr ri = (ReifyClosureInstr) i;
                    Variable procVar = ri.getResult();
                    Operand blockVar = unusedExplicitBlocks.get(procVar);

                    if (blockVar != null) {
                        ri.markDead();
                        instrs.set(new CopyInstr(procVar, blockVar));
                    }
                }
            }
        }
    }

    private static boolean usesVariableAsNonClosureArg(Instr i, Variable v) {
        List<Variable> usedVariables = i.getUsedVariables();
        if (usedVariables.contains(v)) {
            if (i instanceof ClosureAcceptingInstr) {
                return usedVariables.indexOf(v) != usedVariables.lastIndexOf(v) ||
                    v != ((ClosureAcceptingInstr) i).getClosureArg();
            } else
                return true;
        }
        return false;
    }
}
