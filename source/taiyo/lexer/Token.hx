package taiyo.lexer;

enum TokenType
{
    INTEGER;
    FLOAT;
    STRING;
    BOOLEAN;
    NULL;
    
    // ops //
    ADD;
    SUB;
    MUL;
    DIV;
    MOD;
    POW;
    
    // bin ops //
    EQ_EQUAL;
    GT;
    GT_OR_EQUAL;
    LW;
    LW_OR_EQUAL;
    NOT_EQUAL;
    ASSIGN;
    
    // symbols //
    LEFT_PAREN;
    RIGHT_PAREN;
    LEFT_SQUARE;
    RIGHT_SQUARE;
    LEFT_BRACE;
    RIGHT_BRACE;
    COMMA;
    DOT; // .
    DOT3; // ...
    
    IDENTIFIER;
    KEYWORD;
    NEWLINE;
    EOF;
}

class Token
{
    public var type:TokenType;
    public var value:Dynamic;
    
    public function new(type:TokenType, ?value:Dynamic)
    {
        this.type = type;
        this.value = value;
    }
    
    public function is(type:TokenType, ?value:Dynamic):Bool
        return this.type == type && (value == null || this.value == value);
        
    public function toString()
    {
        var strType:String = Type.enumConstructor(this.type);
        return this.value == null ? 'Token(type = $strType)' : 'Token(type = $strType, value = $value)';
    }
}
