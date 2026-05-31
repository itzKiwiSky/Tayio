package pine.runtime;

interface IPackage
{
    public function getModule():Map<String, Value>;
}

interface INativeModule extends IPackage
{
    public var modname:String;
}
