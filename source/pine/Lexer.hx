package pine;

import haxe.Exception;

using StringTools;

class Lexer
{
    static var position:Int = 0;
    static var line:Int = 0;
    static var cursor:Int = 0; // col
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
    
    public static function lex(src:String)
    {
        source = src;
        position = 0;
        
        currentChar = source.charAt(position);
        
        while (position < source.length)
        {
            if (~/[ \t]/.match(currentChar))
                peek();
            else if (~/[;\n]/.match(currentChar))
            {
                tokens.push(new Token("TT_NEWLINE"));
                peek();
            }
            else if (currentChar == "+")
            {
                tokens.push(new Token("TT_ADD"));
                peek();
            }
            else if (currentChar == "-")
            {
                tokens.push(new Token("TT_SUB"));
                peek();
            }
            else if (currentChar == "*")
            {
                tokens.push(new Token("TT_MUL"));
                peek();
            }
            else if (currentChar == "/")
            {
                tokens.push(new Token("TT_DIV"));
                peek();
            }
            else if (currentChar == "%")
            {
                tokens.push(new Token("TT_MOD"));
                peek();
            }
            else if (currentChar == "^")
            {
                tokens.push(new Token("TT_POW"));
                peek();
            }
            else if (currentChar == "(")
            {
                tokens.push(new Token("TT_LEFT_PAREN"));
                peek();
            }
            else if (currentChar == ")")
            {
                tokens.push(new Token("TT_RIGHT_PAREN"));
                peek();
            }
            else if (currentChar == "[")
            {
                tokens.push(new Token("TT_LEFT_SQUARE"));
                peek();
            }
            else if (currentChar == "]")
            {
                tokens.push(new Token("TT_RIGHT_SQUARE"));
                peek();
            }
            else if (currentChar == ",")
            {
                tokens.push(new Token("TT_COMMA"));
                peek();
            }
            else if (letterTest.match(currentChar))
                tokens.push(createIdentifier());
            else if (currentChar == "!")
            {
                var result:Null<Token> = createNotEqual();
                
                if (result == null)
                    tokens.push(createNotEqual());
            }
            else
            {
                var start:Int = position;
                var char:String = currentChar;
                peek();
                // new Exception('SyntaxError: Invalid char $char at $position');
                Sys.print('SyntaxError: Invalid char $char at col: $position\n');
                return [];
            }
        }
        
        tokens.push(new Token("TT_EOF"));
        return tokens;
    }
    
    // move to next position in the source and return the char
    static function peek()
    {
        position++;
        currentChar = source.charAt(position);
    }
    
    // move to previous position and return the char
    
    static function seekChar()
    {
        position--;
        currentChar = source.charAt(position);
    }
    
    static function createIdentifier():Token
    {
        var result:String = "";
        var tkType:String = "";
        
        while (currentChar != null && ~/[a-zA-Z_]/.match(currentChar))
        {
            result += currentChar;
            peek();
        }
        
        if (keywords.contains(result))
            tkType = "TT_KEYWORD";
        else
            tkType = "TT_IDENTIFIER";
            
        return new Token(tkType, result);
    }
    
    static function createNotEqual():Null<Token>
    {
        var start:Int = position;
        peek();
        if (currentChar == "=")
        {
            peek();
            return new Token("TT_NOT_EQ");
        }
        
        return null;
    }
}
