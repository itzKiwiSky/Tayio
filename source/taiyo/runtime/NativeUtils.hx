package taiyo.runtime;

import taiyo.lexer.LangError;
import taiyo.runtime.Runtime.RuntimeResult;
import taiyo.runtime.Value;

class NativeUtils
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
    
    public static inline function toDict(v:Value):Null<Map<String, Value>>
        return switch (v)
        {
            case DictVal(d): d;
            case _: null;
        };
        
    public static inline function toValueArray(v:Value):Null<Array<Value>>
        return switch (v)
        {
            case ArrayVal(items): items;
            case _: null;
        };
        
    public static inline function toFloat(v:Value):Null<Float>
        return switch (v)
        {
            case IntVal(n): (n : Float);
            case FloatVal(n): n;
            case _: null;
        };
        
    public static inline function toInt(v:Value):Null<Int>
        return switch (v)
        {
            case IntVal(n): n;
            case FloatVal(n): Std.int(n);
            case _: null;
        };
        
    public static inline function toBool(v:Value):Null<Bool>
        return switch (v)
        {
            case BoolVal(b): b;
            case IntVal(n): n != 0;
            case FloatVal(n): n != 0.0;
            case _: null;
        };
        
    public static inline function toString(v:Value):Null<String>
        return switch (v)
        {
            case StringVal(s): s;
            case _: null;
        };
        
    // Versões que retornam RuntimeResult diretamente
    public static inline function expectFloat(v:Value, fn:String):RuntimeResult
    {
        var r = toFloat(v);
        return r != null ? Ok(FloatVal(r)) : Err(new LangError(null, null, RuntimeError, '$fn() expects a number'));
    }
    
    public static inline function expectInt(v:Value, fn:String):RuntimeResult
    {
        var r = toInt(v);
        return r != null ? Ok(IntVal(r)) : Err(new LangError(null, null, RuntimeError, '$fn() expects an integer'));
    }
    
    public static inline function expectBool(v:Value, fn:String):RuntimeResult
    {
        var r = toBool(v);
        return r != null ? Ok(BoolVal(r)) : Err(new LangError(null, null, RuntimeError, '$fn() expects a boolean'));
    }
    
    public static inline function expectString(v:Value, fn:String):RuntimeResult
    {
        var r = toString(v);
        return r != null ? Ok(StringVal(r)) : Err(new LangError(null, null, RuntimeError, '$fn() expects a string'));
    }
    
    // RuntimeResult versions
    public static inline function expectDict(v:Value, fn:String):RuntimeResult
    {
        var r = toDict(v);
        return r != null ? Ok(DictVal(r)) : Err(new LangError(null, null, RuntimeError, '$fn() expects a dict'));
    }
    
    public static inline function expectArray(v:Value, fn:String):RuntimeResult
    {
        var r = toValueArray(v);
        return r != null ? Ok(ArrayVal(r)) : Err(new LangError(null, null, RuntimeError, '$fn() expects an array'));
    }
    
    public static function dumpDict(d:Map<String, Value>, indent:Int = 0):String
    {
        var pad = StringTools.lpad("", " ", indent * 2);
        var lines = ['$pad{'];
        for (k => v in d)
        {
            switch (v)
            {
                case DictVal(inner):
                    lines.push('$pad  $k:');
                    lines.push(dumpDict(inner, indent + 1));
                case FuncVal(_) | NativeFuncVal(_):
                    lines.push('$pad  $k: <function>');
                case _:
                    lines.push('$pad  $k: ${valueToString(v)}');
            }
        }
        lines.push('$pad}');
        return lines.join("\n");
    }
}
