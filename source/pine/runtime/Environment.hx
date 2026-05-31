package pine.runtime;

class Environment
{
    public var variables:Map<String, Value> = [];
    
    var parent:Null<Environment>;
    
    public var exports:Array<String> = [];
    
    public function new(?parent:Environment)
    {
        this.parent = parent;
    }
    
    public function markExport(name:String):Void
    {
        if (!exports.contains(name))
            exports.push(name);
    }
    
    public function getVar(name:String):Null<Value>
    {
        if (variables.exists(name))
            return variables.get(name);
            
        if (parent != null)
            return parent.getVar(name);
            
        return null;
    }
    
    public function createVar(name:String, value:Value)
    {
        variables.set(name, value);
    }
    
    public function assign(name:String, value:Value):Bool
    {
        if (variables.exists(name))
        {
            variables.set(name, value);
            return true;
        }
        if (parent != null)
            return parent.assign(name, value);
            
        return false;
    }
}
