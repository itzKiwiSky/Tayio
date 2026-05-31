package pine.runtime.packages;

import pine.lexer.LangError;

class MathLib implements INativeModule
{
    public function new() {}
    
    public var modname:String = "pine.Math";
    
    static function expectArgs(args:Array<Value>, funcName:String, count:Int):Null<LangError>
    {
        if (args.length != count)
            return new LangError(null, null, RuntimeError, 'Function $funcName expected $count argument(s), got ${args.length}');
        return null;
    }
    
    public function getModule():Map<String, Value>
    {
        var module:Map<String, Value> = [];
        
        module.set("PI", FloatVal(Math.PI));
        
        module.set("floor", NativeFuncVal(args ->
        {
            expectArgs(args, "floor", 1);
            
            switch (args[0])
            {
                case IntVal(v): return Ok(IntVal(v)); // já é int
                case FloatVal(v): return Ok(IntVal(Math.floor(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'floor() expects a number'));
            }
        }));
        
        module.set("ceil", NativeFuncVal(args ->
        {
            expectArgs(args, "ceil", 1);
            
            switch (args[0])
            {
                case IntVal(v): return Ok(IntVal(v)); // já é int
                case FloatVal(v): return Ok(IntVal(Math.ceil(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'ceil() expects a number'));
            }
        }));
        
        module.set("abs", NativeFuncVal(args ->
        {
            expectArgs(args, "ceil", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.abs(v))); // já é int
                case FloatVal(v): return Ok(FloatVal(Math.abs(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'abs() expects a number'));
            }
        }));
        
        // Math
        module.set("sqrt", NativeFuncVal(args ->
        {
            expectArgs(args, "sqrt", 1);
            switch (args[0])
            {
                case IntVal(v): return Ok(FloatVal(Math.sqrt(v))); // já é int
                case FloatVal(v): return Ok(FloatVal(Math.sqrt(v)));
                case _: return Err(new LangError(null, null, RuntimeError, 'sqrt() expects a number'));
            }
        }));
        
        return module;
    }
}
