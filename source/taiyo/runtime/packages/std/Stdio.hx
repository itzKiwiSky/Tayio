package taiyo.runtime.packages.std;

import taiyo.runtime.INativePackage.IPackage;
import taiyo.runtime.NativeUtils;

class Stdio implements IPackage
{
    public function new() {}
    
    public function getModule()
    {
        var module:Map<String, Value> = [];
        
        module.set("print", NativeFuncVal(args ->
        {
            for (arg in args)
                Sys.print(NativeUtils.valueToString(arg));
            return Ok(NullVal);
        }));
        
        module.set("println", NativeFuncVal(args ->
        {
            for (arg in args)
                Sys.println(NativeUtils.valueToString(arg));
            return Ok(NullVal);
        }));
        
        return module;
    }
}
