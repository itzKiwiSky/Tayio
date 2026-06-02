package taiyo.runtime.packages.std;

import taiyo.runtime.INativePackage.IPackage;
import taiyo.runtime.NativeUtils;

class Stdio implements IPackage
{
    public function new() {}
    
    public function getModule()
    {
        var module:Map<String, Value> = [];
        
        // Classic print
        module.set("print", NativeFuncVal(args ->
        {
            for (arg in args)
                Sys.print(NativeUtils.valueToString(arg));
            return Ok(NullVal);
        }));
        
        // same as print but with \n lol
        module.set("println", NativeFuncVal(args ->
        {
            for (arg in args)
                Sys.println(NativeUtils.valueToString(arg));
            return Ok(NullVal);
        }));
        
        // read the line and return the string
        module.set("readln", NativeFuncVal(args ->
        {
            return Ok(StringVal(Sys.stdin().readLine()));
        }));
        
        return module;
    }
}
