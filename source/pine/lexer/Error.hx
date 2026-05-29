package pine.lexer;

enum ErrorType
{
    IllegalChar;
    ExpectedChar;
    InvalidSyntax;
    RuntimeError;
}

class LangError
{
    public var posStart:Position;
    public var posEnd:Position;
    public var type:ErrorType;
    public var details:String;
    
    public function new(posStart:Position, posEnd:Position, type:ErrorType, details:String)
    {
        this.posStart = posStart;
        this.posEnd = posEnd;
        this.type = type;
        this.details = details;
    }
    
    public function asString():String
    {
        var name = switch (type)
        {
            case IllegalChar: "Illegal Character";
            case ExpectedChar: "Expected Character";
            case InvalidSyntax: "Invalid Syntax";
            case RuntimeError: "Runtime Error";
        }
        return '$name: $details\nFile ${posStart.fn}, line ${posStart.line + 1}';
    }
}
