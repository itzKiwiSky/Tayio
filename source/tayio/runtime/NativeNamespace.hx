package tayio.runtime;

import tayio.runtime.INativePackage.INativeModule;
import tayio.runtime.INativePackage.IPackage;

class NativeNamespace implements INativeModule
{
    public var modname:String;
    
    var modules:Map<String, Value> = [];
    
    public function new(namespaceName:String)
    {
        this.modname = namespaceName;
        this.modules = [];
    }
    
    public function add(name:String, pack:IPackage):Void
    {
        modules.set(name, DictVal(pack.getModule()));
    }
    
    public function getModule():Map<String, Value>
    {
        return modules;
    }
}
