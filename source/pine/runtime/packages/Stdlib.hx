package pine.runtime.packages;

class Stdlib
{
    public static function register(env:Environment)
    {
        env.createVar("print", NativeFuncVal(args ->
        {
            for (arg in args)
                Sys.print(valueToString(arg));
            return Ok(NullVal);
        }));
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
