package taiyo.runtime.packages.std;

import taiyo.runtime.INativePackage.IPackage;

class Stdio implements IPackage
{
    public function new() {}
    
    public function getModule()
    {
        var module:Map<String, Value> = [];
        
        module.set("print", NativeFuncVal(args ->
        {
            for (arg in args)
                Sys.print(Utils.valueToString(arg));
            return Ok(NullVal);
        }));
        
        module.set("println", NativeFuncVal(args ->
        {
            for (arg in args)
                Sys.println(Utils.valueToString(arg));
            return Ok(NullVal);
        }));
        
        return module;
    }
}
