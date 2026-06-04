package taiyo.runtime.packages.std;

import taiyo.lexer.LangError;
import cli.Ansi;
import taiyo.runtime.INativePackage.IPackage;
import taiyo.runtime.Value;

class TaiyoAnsi implements IPackage
{
    public function new() {}
    
    public function getModule():Map<String, Value>
    {
        var mod:Map<String, Value> = [];
        
        var f = Type.getClassFields(Ansi);
        
        for (field in f)
        {
            var value = Reflect.field(Ansi, field);
            
            if (!Reflect.isFunction(value))
                mod.set(field, StringVal(value));
        }
        
        mod.set("color256", NativeFuncVal(args ->
        {
            var n = NativeUtils.toInt(args[0]);
            if (n == null)
                return Err(new LangError(null, null, RuntimeError, 'color256() expects an integer'));
            return Ok(StringVal(Ansi.color256(n)));
        }));
        
        mod.set("bgColor256", NativeFuncVal(args ->
        {
            var n = NativeUtils.toInt(args[0]);
            if (n == null)
                return Err(new LangError(null, null, RuntimeError, 'bgColor256() expects an integer'));
            return Ok(StringVal(Ansi.bgColor256(n)));
        }));
        
        mod.set("rgb", NativeFuncVal(args ->
        {
            var r = NativeUtils.toInt(args[0]);
            var g = NativeUtils.toInt(args[1]);
            var b = NativeUtils.toInt(args[2]);
            if (r == null || g == null || b == null)
                return Err(new LangError(null, null, RuntimeError, 'rgb() expects 3 integers'));
            return Ok(StringVal(Ansi.rgb(r, g, b)));
        }));
        
        mod.set("bgRgb", NativeFuncVal(args ->
        {
            var r = NativeUtils.toInt(args[0]);
            var g = NativeUtils.toInt(args[1]);
            var b = NativeUtils.toInt(args[2]);
            if (r == null || g == null || b == null)
                return Err(new LangError(null, null, RuntimeError, 'bgRgb() expects 3 integers'));
            return Ok(StringVal(Ansi.bgRgb(r, g, b)));
        }));
        
        // cursor
        mod.set("up", NativeFuncVal(args ->
        {
            var n = NativeUtils.toInt(args[0]);
            if (n == null)
                return Err(new LangError(null, null, RuntimeError, 'up() expects an integer'));
            return Ok(StringVal(Ansi.up(n)));
        }));
        
        mod.set("down", NativeFuncVal(args ->
        {
            var n = NativeUtils.toInt(args[0]);
            if (n == null)
                return Err(new LangError(null, null, RuntimeError, 'down() expects an integer'));
            return Ok(StringVal(Ansi.down(n)));
        }));
        
        mod.set("right", NativeFuncVal(args ->
        {
            var n = NativeUtils.toInt(args[0]);
            if (n == null)
                return Err(new LangError(null, null, RuntimeError, 'right() expects an integer'));
            return Ok(StringVal(Ansi.right(n)));
        }));
        
        mod.set("left", NativeFuncVal(args ->
        {
            var n = NativeUtils.toInt(args[0]);
            if (n == null)
                return Err(new LangError(null, null, RuntimeError, 'left() expects an integer'));
            return Ok(StringVal(Ansi.left(n)));
        }));
        
        mod.set("goTo", NativeFuncVal(args ->
        {
            var row = NativeUtils.toInt(args[0]);
            var col = NativeUtils.toInt(args[1]);
            if (row == null || col == null)
                return Err(new LangError(null, null, RuntimeError, 'goTo() expects 2 integers'));
            return Ok(StringVal(Ansi.goTo(row, col)));
        }));
        
        return mod;
    }
}
