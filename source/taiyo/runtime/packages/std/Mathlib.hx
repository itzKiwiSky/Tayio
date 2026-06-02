package taiyo.runtime.packages.std;

import taiyo.runtime.INativePackage.IPackage;
import taiyo.lexer.LangError;
import taiyo.runtime.Value;

class MathLib implements IPackage
{
    public function new() {}
    
    public function getModule():Map<String, Value>
    {
        var mod:Map<String, Value> = [];
        
        mod.set("PI", FloatVal(Math.PI));
        
        mod.set("floor", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "floor", 1);
            
            switch (args[0])
            {
                case IntVal(v): return Ok(IntVal(v));
                case FloatVal(v): return Ok(IntVal(Math.floor(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'floor() expects a number'));
            }
        }));
        
        mod.set("ceil", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "ceil", 1);
            
            switch (args[0])
            {
                case IntVal(v): return Ok(IntVal(v));
                case FloatVal(v): return Ok(IntVal(Math.ceil(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'ceil() expects a number'));
            }
        }));
        
        mod.set("abs", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "abs", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.abs(v)));
                case FloatVal(v): return Ok(FloatVal(Math.abs(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'abs() expects a number'));
            }
        }));
        
        mod.set("acos", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "acos", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.acos(v)));
                case FloatVal(v): return Ok(FloatVal(Math.acos(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'acos() expects a number'));
            }
        }));
        
        mod.set("asin", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "asin", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.asin(v)));
                case FloatVal(v): return Ok(FloatVal(Math.asin(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'asin() expects a number'));
            }
        }));
        
        mod.set("atan", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "atan", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.atan(v)));
                case FloatVal(v): return Ok(FloatVal(Math.atan(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'atan() expects a number'));
            }
        }));
        
        mod.set("atan2", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "atan2", 2);
            var y:Null<Float> = NativeUtils.toFloat(args[0]);
            var x:Null<Float> = NativeUtils.toFloat(args[1]);
            if (y == null || x == null)
                return Err(new LangError(null, null, RuntimeError, 'atan2() expects numbers'));
            return Ok(FloatVal(Math.atan2(y, x)));
        }));
        
        mod.set("cos", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "cos", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.cos(v)));
                case FloatVal(v): return Ok(FloatVal(Math.cos(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'cos() expects a number'));
            }
        }));
        
        mod.set("sin", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "sin", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.sin(v)));
                case FloatVal(v): return Ok(FloatVal(Math.sin(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'sin() expects a number'));
            }
        }));
        
        mod.set("isFinite", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "isFinite", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(BoolVal(Math.isFinite(v)));
                case FloatVal(v): return Ok(BoolVal(Math.isFinite(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'isFinite() expects a number'));
            }
        }));
        
        mod.set("max", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "max", 2);
            var y:Null<Float> = NativeUtils.toFloat(args[0]);
            var x:Null<Float> = NativeUtils.toFloat(args[1]);
            if (y == null || x == null)
                return Err(new LangError(null, null, RuntimeError, 'max() expects numbers'));
            return Ok(FloatVal(Math.max(y, x)));
        }));
        
        mod.set("min", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "min", 2);
            var y:Null<Float> = NativeUtils.toFloat(args[0]);
            var x:Null<Float> = NativeUtils.toFloat(args[1]);
            if (y == null || x == null)
                return Err(new LangError(null, null, RuntimeError, 'min() expects numbers'));
            return Ok(FloatVal(Math.min(y, x)));
        }));
        
        mod.set("log", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "log", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.log(v)));
                case FloatVal(v): return Ok(FloatVal(Math.log(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'log() expects a number'));
            }
        }));
        
        mod.set("tan", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "tan", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.tan(v)));
                case FloatVal(v): return Ok(FloatVal(Math.tan(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'tan() expects a number'));
            }
        }));
        
        // Math
        mod.set("sqrt", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "sqrt", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.sqrt(v)));
                case FloatVal(v): return Ok(FloatVal(Math.sqrt(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'sqrt() expects a number'));
            }
        }));
        
        return mod;
    }
}
