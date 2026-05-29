package pine.lexer;

import haxe.Exception;

using StringTools;

class Lexer
{
    static var line:Int = 0;
    static var cursor:Int = 0; // col
    static var position:Position;
    static var currentChar:String = "";
    static var source:String = "";
    static var tokens:Array<Token> = [];
    
    static var letterTest:EReg = ~/[aA-zZ]/i;
    
    public static var keywords:Array<String> = [
        "scoped",
        "global",
        "if",
        "else",
        "elseif",
        "while",
        "for",
        "in",
        "continue",
        "break",
        "return",
        "func",
        "do",
        "end",
        "use",
        "implements",
        "extends",
        "export",
        "module",
    ];
    
    static var errorRaised:Bool = false;
    
    public static function lex(src:String)
    {
        source = src;
        position = new Position("", source);
        
        position.advance();
        
        while (position.index < source.length && !errorRaised)
        {
            if (~/[ \t]/.match(currentChar))
                position.advance();
            else if (~/[;\n]/.match(currentChar))
            {
                tokens.push(new Token("TT_NEWLINE"));
                position.advance();
            }
            else if (currentChar == "+")
            {
                tokens.push(new Token("TT_ADD"));
                position.advance();
            }
            else if (currentChar == "-")
            {
                tokens.push(new Token("TT_SUB"));
                position.advance();
            }
            else if (currentChar == "*")
            {
                tokens.push(new Token("TT_MUL"));
                position.advance();
            }
            else if (currentChar == "/")
            {
                tokens.push(new Token("TT_DIV"));
                position.advance();
            }
            else if (currentChar == "%")
            {
                tokens.push(new Token("TT_MOD"));
                position.advance();
            }
            else if (currentChar == "^")
            {
                tokens.push(new Token("TT_POW"));
                position.advance();
            }
            else if (currentChar == "(")
            {
                tokens.push(new Token("TT_LEFT_PAREN"));
                position.advance();
            }
            else if (currentChar == ")")
            {
                tokens.push(new Token("TT_RIGHT_PAREN"));
                position.advance();
            }
            else if (currentChar == "[")
            {
                tokens.push(new Token("TT_LEFT_SQUARE"));
                position.advance();
            }
            else if (currentChar == "]")
            {
                tokens.push(new Token("TT_RIGHT_SQUARE"));
                position.advance();
            }
            else if (currentChar == ",")
            {
                tokens.push(new Token("TT_COMMA"));
                position.advance();
            }
            else if (letterTest.match(currentChar))
                tokens.push(createIdentifier());
            else if (currentChar == "!")
            {
                var result:Null<Token> = createNotEqual();
                
                if (result == null)
                {
                    raiseError('SyntaxError:', 'Expected "=" at col: $position\n');
                    return [];
                }
                
                tokens.push(createNotEqual());
            }
            else
            {
                var start:Int = position.index;
                var char:String = currentChar;
                position.advance();
                // new Exception('SyntaxError: Invalid char $char at $position');
                raiseError('SyntaxError', 'Invalid char $char at col: $position\n');
                return [];
            }
        }
        
        tokens.push(new Token("TT_EOF"));
        return tokens;
    }
    
    static function createIdentifier():Token
    {
        var result:String = "";
        var tkType:String = "";
        
        while (currentChar != null && ~/[a-zA-Z_]/.match(currentChar))
        {
            result += currentChar;
            position.advance();
        }
        
        if (keywords.contains(result))
            tkType = "TT_KEYWORD";
        else
            tkType = "TT_IDENTIFIER";
            
        return new Token(tkType, result);
    }
    
    static function createNotEqual():Null<Token>
    {
        var start:Int = position.index;
        position.advance();
        if (currentChar == "=")
        {
            position.advance();
            return new Token("TT_NOT_EQ");
        }
        
        return null;
    }
    
    static function raiseError(error:String, message:String)
    {
        Sys.print('$error: $message\n');
        errorRaised = true;
    }
}
