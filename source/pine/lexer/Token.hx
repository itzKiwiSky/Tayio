package pine.lexer;

class Token
{
    public var type:String;
    public var value:Dynamic;
    
    public function new(type:String, ?value:Dynamic)
    {
        this.type = type;
        this.value = value;
    }
    
    @:op(A == B)
    public function matches(type:String, ?value:Dynamic):Bool
        return this.type == type && this.value == value;
        
    public function toString()
    {
        return this.value == null ? 'Token[type = $type]' : 'Token[type = $type | value = $value]';
    }
}
