package pine.runtime;

interface INativeModule
{
    public function getModule():Map<String, Value>;
    public var modname(default, null):String;
}
