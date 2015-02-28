package org.jruby.java.invokers;

import java.lang.reflect.Method;
import java.util.List;

import org.jruby.Ruby;
import org.jruby.RubyModule;
import org.jruby.RubyProc;
import org.jruby.java.proxies.JavaProxy;
import org.jruby.javasupport.JavaMethod;
import org.jruby.runtime.Block;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

public class InstanceMethodInvoker extends MethodInvoker {
    public InstanceMethodInvoker(RubyModule host, List<Method> methods) {
        super(host, methods);
    }

    public InstanceMethodInvoker(RubyModule host, Method method) {
        super(host, method);
    }

    @Override
    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name, IRubyObject[] args) {
        JavaProxy proxy = castJavaProxy(self);

        int len = args.length;
        Object[] convertedArgs = new Object[len];
        JavaMethod method = (JavaMethod)findCallable(self, name, args, len);
        if (method.isVarArgs()) {
            len = method.getParameterTypes().length - 1;
            convertedArgs = new Object[len + 1];
            for (int i = 0; i < len && i < args.length; i++) {
                convertedArgs[i] = convertArg(args[i], method, i);
            }
            convertedArgs[len] = convertVarargs(args, method);
        } else {
            convertedArgs = new Object[len];
            for (int i = 0; i < len && i < args.length; i++) {
                convertedArgs[i] = convertArg(args[i], method, i);
            }
        }
        return method.invokeDirect(context, proxy.getObject(), convertedArgs);
    }

    @Override
    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name) {
        if (javaVarargsCallables != null) return call(context, self, clazz, name, IRubyObject.NULL_ARRAY);
        JavaProxy proxy = castJavaProxy(self);
        JavaMethod method = (JavaMethod)findCallableArityZero(self, name);
        return method.invokeDirect(context, proxy.getObject());
    }

    @Override
    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name, IRubyObject arg0) {
        if (javaVarargsCallables != null) return call(context, self, clazz, name, new IRubyObject[] {arg0});
        JavaProxy proxy = castJavaProxy(self);
        JavaMethod method = (JavaMethod)findCallableArityOne(self, name, arg0);
        Object cArg0 = convertArg(arg0, method, 0);
        return method.invokeDirect(context, proxy.getObject(), cArg0);
    }

    @Override
    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name, IRubyObject arg0, IRubyObject arg1) {
        if (javaVarargsCallables != null) return call(context, self, clazz, name, new IRubyObject[] {arg0, arg1});
        JavaProxy proxy = castJavaProxy(self);
        JavaMethod method = (JavaMethod)findCallableArityTwo(self, name, arg0, arg1);
        Object cArg0 = convertArg(arg0, method, 0);
        Object cArg1 = convertArg(arg1, method, 1);
        return method.invokeDirect(context, proxy.getObject(), cArg0, cArg1);
    }

    @Override
    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name, IRubyObject arg0, IRubyObject arg1, IRubyObject arg2) {
        if (javaVarargsCallables != null) return call(context, self, clazz, name, new IRubyObject[] {arg0, arg1, arg2});
        JavaProxy proxy = castJavaProxy(self);
        JavaMethod method = (JavaMethod)findCallableArityThree(self, name, arg0, arg1, arg2);
        Object cArg0 = convertArg(arg0, method, 0);
        Object cArg1 = convertArg(arg1, method, 1);
        Object cArg2 = convertArg(arg2, method, 2);
        return method.invokeDirect(context, proxy.getObject(), cArg0, cArg1, cArg2);
    }

    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name, IRubyObject[] args, Block block) {
        if (block.isGiven()) {
            JavaProxy proxy = castJavaProxy(self);
            int len = args.length;
            // these extra arrays are really unfortunate; split some of these paths out to eliminate?
            Object[] convertedArgs = new Object[len + 1];
            IRubyObject[] intermediate = new IRubyObject[len + 1];
            System.arraycopy(args, 0, intermediate, 0, len);
            intermediate[len] = RubyProc.newProc(context.runtime, block, block.type);
            JavaMethod method = (JavaMethod)findCallable(self, name, intermediate, len + 1);
            for (int i = 0; i < len + 1; i++) {
                convertedArgs[i] = convertArg(intermediate[i], method, i);
            }
            return method.invokeDirect(context, proxy.getObject(), convertedArgs);
        } else {
            return call(context, self, clazz, name, args);
        }
    }

    @Override
    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name, Block block) {
        if (block.isGiven()) {
            JavaProxy proxy = castJavaProxy(self);
            RubyProc proc = RubyProc.newProc(context.runtime, block, block.type);
            JavaMethod method = (JavaMethod)findCallableArityOne(self, name, proc);
            Object cArg0 = convertArg(proc, method, 0);
            return method.invokeDirect(context, proxy.getObject(), cArg0);
        } else {
            return call(context, self, clazz, name);
        }
    }

    @Override
    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name, IRubyObject arg0, Block block) {
        if (block.isGiven()) {
            JavaProxy proxy = castJavaProxy(self);
            RubyProc proc = RubyProc.newProc(context.runtime, block, block.type);
            JavaMethod method = (JavaMethod)findCallableArityTwo(self, name, arg0, proc);
            Object cArg0 = convertArg(arg0, method, 0);
            Object cArg1 = convertArg(proc, method, 1);
            return method.invokeDirect(context, proxy.getObject(), cArg0, cArg1);
        } else {
            return call(context, self, clazz, name, arg0);
        }
    }

    @Override
    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name, IRubyObject arg0, IRubyObject arg1, Block block) {
        if (block.isGiven()) {
            JavaProxy proxy = castJavaProxy(self);
            RubyProc proc = RubyProc.newProc(context.runtime, block, block.type);
            JavaMethod method = (JavaMethod)findCallableArityThree(self, name, arg0, arg1, proc);
            Object cArg0 = convertArg(arg0, method, 0);
            Object cArg1 = convertArg(arg1, method, 1);
            Object cArg2 = convertArg(proc, method, 2);
            return method.invokeDirect(context, proxy.getObject(), cArg0, cArg1, cArg2);
        } else {
            return call(context, self, clazz, name, arg0, arg1);
        }
    }

    @Override
    public IRubyObject call(ThreadContext context, IRubyObject self, RubyModule clazz, String name, IRubyObject arg0, IRubyObject arg1, IRubyObject arg2, Block block) {
        if (block.isGiven()) {
            JavaProxy proxy = castJavaProxy(self);
            RubyProc proc = RubyProc.newProc(context.runtime, block, block.type);
            JavaMethod method = (JavaMethod)findCallableArityFour(self, name, arg0, arg1, arg2, proc);
            Object cArg0 = convertArg(arg0, method, 0);
            Object cArg1 = convertArg(arg1, method, 1);
            Object cArg2 = convertArg(arg2, method, 2);
            Object cArg3 = convertArg(proc, method, 3);
            return method.invokeDirect(context, proxy.getObject(), cArg0, cArg1, cArg2, cArg3);
        } else {
            return call(context, self, clazz, name, arg0, arg1, arg2);
        }
    }
}
