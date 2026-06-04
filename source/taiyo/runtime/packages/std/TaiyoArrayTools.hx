package taiyo.runtime.packages.std;

import taiyo.lexer.LangError;
import taiyo.runtime.INativePackage.IPackage;
import taiyo.runtime.Value;

class TaiyoArrayTools implements IPackage
{
    public function new() {}
    
    public function getModule()
    {
        var mod:Map<String, Value> = [];
        
        mod.set("add", NativeFuncVal(args ->
        {
            if (args.length < 2 || args.length > 3)
                return Err(new LangError(null, null, RuntimeError, 'add() expects 2 or 3 arguments'));
                
            switch (args[0])
            {
                case ArrayVal(arr):
                    if (args.length == 2)
                    {
                        arr.push(args[1]);
                    }
                    else
                    {
                        var index = NativeUtils.toInt(args[1]);
                        if (index == null)
                            return Err(new LangError(null, null, RuntimeError, 'add() position must be an integer'));
                        arr.insert(index, args[2]);
                    }
                    return Ok(NullVal);
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'add() expects an array as first argument'));
            }
            
            return Ok(NullVal);
        }));
        
        mod.set("remove", NativeFuncVal(args ->
        {
            return Ok(NullVal);
        }));
        
        mod.set("len", NativeFuncVal(args ->
        {
            var num:Int = 0;
            NativeUtils.expectArgs(args, "len", 1);
            switch (args[0])
            {
                case ArrayVal(ar):
                    num = ar.length;
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'len() expects an array as first argument'));
            }
            return Ok(IntVal(num));
        }));
        
        return mod;
    }
}
