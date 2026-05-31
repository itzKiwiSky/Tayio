package pine.runtime.packages.std.io;

import pine.runtime.INativePackage.IPackage;

class Stdout implements IPackage
{
    public function new() {}
    
    public function getModule():Map<String, Value>
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
