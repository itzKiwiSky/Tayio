package pine.runtime.packages;

class Stdlib implements INativeModule
{
    public var modname:String = "pine.std";
    
    public function new() {}
    
    public function getModule():Map<String, Value>
    {
        var module:Map<String, Value> = [];
        
        module.set("print", NativeFuncVal(args ->
        {
            for (arg in args)
                Sys.print(valueToString(arg));
            return Ok(NullVal);
        }));
        
        module.set("println", NativeFuncVal(args ->
        {
            for (arg in args)
                Sys.println(valueToString(arg));
            return Ok(NullVal);
        }));
        
        return module;
    }
    
    public static function valueToString(v:Value):String
    {
        return switch (v)
        {
            case IntVal(v): std.Std.string(v);
            case FloatVal(v): std.Std.string(v);
            case StringVal(v): v;
            case BoolVal(v): v ? "true" : "false";
            case NullVal: "null";
            case ArrayVal(a): "[" + a.map(valueToString).join(", ") + "]";
            case DictVal(d): "{" + [for (k => v in d) '$k = ${valueToString(v)}'].join(", ") + "}";
            case FuncVal(_) | NativeFuncVal(_): "<function>";
        }
    }
}
