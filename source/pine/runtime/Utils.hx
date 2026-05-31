package pine.runtime;

import pine.lexer.LangError;

class Utils
{
    public static function expectArgs(args:Array<Value>, funcName:String, count:Int):Null<LangError>
    {
        if (args.length != count)
            return new LangError(null, null, RuntimeError, 'Function $funcName expected $count argument(s), got ${args.length}');
        return null;
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
