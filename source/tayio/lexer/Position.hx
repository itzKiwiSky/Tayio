package tayio.lexer;

class Position
{
    public var fn:String; // nome do arquivo
    public var source:String; // texto completo (pra string_with_arrows futuramente)
    
    public var index:Int;
    public var line:Int;
    public var column:Int;
    public var currentChar:String;
    
    public function new(fn:String, source:String, index:Int = -1, line:Int = 1, column:Int = -1)
    {
        this.fn = fn;
        this.source = source;
        this.index = index;
        this.line = line;
        this.column = column;
        
        this.currentChar = source.charAt(index);
    }
    
    public function advance():Void
    {
        if (~/[\n;]/.match(currentChar))
        {
            line++;
            column = 0;
        }
        
        index++;
        column++;
        currentChar = index < source.length ? source.charAt(index) : "";
    }
    
    public function copy():Position
    {
        return new Position(fn, source, index, line, column);
    }
}
