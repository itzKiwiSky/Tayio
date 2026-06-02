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
            NativeUtils.expectArgs(args, "repeat", 2);
            
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
        
        return mod;
    }
}
