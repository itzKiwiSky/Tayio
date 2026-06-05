package taiyo.runtime.packages.std;

import taiyo.lexer.LangError;
import taiyo.runtime.INativePackage.IPackage;

class TaiyoStringTools implements IPackage
{
    public function new() {}
    
    public function getModule()
    {
        var mod:Map<String, Value> = [];
        
        mod.set("repeat", NativeFuncVal(args ->
        {
            var result:String = "";
            NativeUtils.expectArgs(args, "repeat", 2);
            var symbol:Null<String> = NativeUtils.toString(args[0]);
            var count:Null<Int> = NativeUtils.toInt(args[1]);
            
            if (symbol == null)
                return Err(new LangError(null, null, RuntimeError, 'repeat expects a string'));
            if (count == null)
                return Err(new LangError(null, null, RuntimeError, 'repeat expects a number'));
                
            result = StringTools.lpad("", symbol, symbol.length * count);
            
            return Ok(StringVal(result));
        }));
        
        mod.set("split", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "slip", 2);
            
            var str:Null<String> = NativeUtils.toString(args[0]);
            var patt:Null<String> = NativeUtils.toString(args[1]);
            
            if (str == null)
                return Err(new LangError(null, null, RuntimeError, 'split expects a string'));
                
            if (patt == null)
                return Err(new LangError(null, null, RuntimeError, 'split expects a string as pattern'));
                
            var result:Array<Value> = [];
            for (element in str.split(patt))
                result.push(StringVal(element));
                
            return Ok(ArrayVal(result));
        }));
        
        mod.set("align", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "align", 2);
            
            var allowedAligns:Array<String> = ["center", "left", "right"];
            
            var str:Null<String> = NativeUtils.toString(args[0]);
            var width:Null<Int> = NativeUtils.toInt(args[1]);
            var char:Null<String> = NativeUtils.toString(args[2]);
            var align:Null<String> = NativeUtils.toString(args[3]);
            
            if (str == null)
                return Err(new LangError(null, null, RuntimeError, '"Insert" expect a string'));
                
            if (width == null)
                return Err(new LangError(null, null, RuntimeError, '"Insert" expect a int'));
                
            var strLen:Int = str?.length;
            
            var result:String = "";
            
            function rep(s:String, n:Int):String
            {
                var buf = new StringBuf();
                for (_ in 0...n)
                    buf.add(s);
                return buf.toString();
            }
            
            if (width > strLen)
            {
                if (char == null)
                    char = " ";
                    
                var f1:String = "";
                var f2:String = "";
                
                var alignments:Map<String, Void->Void> = [
                    "center" => function()
                    {
                        var rn:Int = Math.ceil((width - strLen) / 2);
                        var ln:Int = width - strLen - rn;
                        
                        f1 = rep(char, ln);
                        f2 = rep(char, rn);
                    },
                    "left" => function()
                    {
                        f1 = rep(char, width - strLen);
                        f2 = "";
                    },
                    "right" => function()
                    {
                        f1 = "";
                        f2 = rep(char, width - strLen);
                    }
                ];
                
                if (alignments.exists(align))
                {
                    alignments.get(align)();
                    result = f1 + str + f2;
                }
                else
                    return Err(new LangError(null, null, RuntimeError, 'Invalid align type'));
            }
            else
                result = str;
                
            return Ok(StringVal(result));
        }));
        
        mod.set("insert", NativeFuncVal(args ->
        {
            NativeUtils.expectArgs(args, "insert", 2);
            
            var s:Null<String> = NativeUtils.toString(args[0]);
            var pos:Null<Int> = NativeUtils.toInt(args[1]);
            var text:Null<String> = NativeUtils.toString(args[2]);
            
            if (s == null)
                return Err(new LangError(null, null, RuntimeError, '"Insert" expect a string'));
                
            if (pos == null)
                return Err(new LangError(null, null, RuntimeError, '"Insert" expect a int'));
                
            if (text == null)
                return Err(new LangError(null, null, RuntimeError, '"Insert" expect a string'));
                
            var result:String = s.substr(0, pos - 1) + text + s.substr(pos - 1);
            
            return Ok(StringVal(result));
        }));
        
        return mod;
    }
}
