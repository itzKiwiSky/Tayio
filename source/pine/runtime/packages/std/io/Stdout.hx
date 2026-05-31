package pine.runtime.packages.std.io;

class Stdout implements INativeModule
{
    public var modname:String = "out";
    
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
