package tayio.runtime.packages.std;

import tayio.runtime.INativePackage.IPackage;
import tayio.lexer.LangError;

class MathLib implements IPackage
{
    public function new() {}
    
    public function getModule():Map<String, Value>
    {
        var mod:Map<String, Value> = [];
        
        mod.set("PI", FloatVal(Math.PI));
        
        mod.set("floor", NativeFuncVal(args ->
        {
            Utils.expectArgs(args, "floor", 1);
            
            switch (args[0])
            {
                case IntVal(v): return Ok(IntVal(v)); // já é int
                case FloatVal(v): return Ok(IntVal(Math.floor(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'floor() expects a number'));
            }
        }));
        
        mod.set("ceil", NativeFuncVal(args ->
        {
            Utils.expectArgs(args, "ceil", 1);
            
            switch (args[0])
            {
                case IntVal(v): return Ok(IntVal(v)); // já é int
                case FloatVal(v): return Ok(IntVal(Math.ceil(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'ceil() expects a number'));
            }
        }));
        
        mod.set("abs", NativeFuncVal(args ->
        {
            Utils.expectArgs(args, "ceil", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.abs(v))); // já é int
                case FloatVal(v): return Ok(FloatVal(Math.abs(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'abs() expects a number'));
            }
        }));
        
        // Math
        mod.set("sqrt", NativeFuncVal(args ->
        {
            Utils.expectArgs(args, "sqrt", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.sqrt(v))); // já é int
                case FloatVal(v): return Ok(FloatVal(Math.sqrt(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'sqrt() expects a number'));
            }
        }));
        
        return mod;
    }
}
