package pine.lexer;

import pine.lexer.Error.LangError;
import haxe.Exception;

using StringTools;

enum LexResult
{
    Ok(tokens:Array<Token>);
    Err(error:LangError);
}

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
        position = new Position("<stdin>", source);
        
        position.advance();
        
        while (position.index < source.length && !errorRaised)
        {
            currentChar = position.currentChar;
            if (~/[ \t]/.match(currentChar))
                position.advance();
            else if (~/[;\n]/.match(currentChar))
            {
                tokens.push(new Token("TT_NEWLINE"));
                position.advance();
                currentChar = position.currentChar;
            }
            else if (currentChar == "+")
            {
                tokens.push(new Token("TT_ADD"));
                position.advance();
                currentChar = position.currentChar;
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
                var posStart = position.copy(); // ← antes de entrar na função
                var result:Null<Token> = createNotEqual();
                
                if (result == null)
                    return Err(new LangError(posStart, position.copy(), ExpectedChar, "Expected '=' after '!'"));
                    
                tokens.push(result);
            }
            else if (currentChar == "=")
            {
                // if cases //
                var posStart = position.copy();
                var result:Null<Token> = createEqualCase();
                
                // if (result == null)
                //    return Err(new LangError(posStart, position.copy(), ExpectedChar, "Expected '=' after '='"));
                
                tokens.push(result);
                position.advance();
            }
            else
            {
                return Err(new LangError(position.copy(), position.copy(), IllegalChar, 'caractere inválido: "$currentChar"'));
            }
        }
        
        tokens.push(new Token("TT_EOF"));
        return Ok(tokens);
    }
    
    static function createIdentifier():Token
    {
        var result = "";
        while (position.currentChar != "" && ~/[a-zA-Z0-9_]/.match(position.currentChar))
        {
            result += position.currentChar;
            position.advance();
            currentChar = position.currentChar;
        }
        
        var tkType = keywords.contains(result) ? "TT_KEYWORD" : "TT_IDENTIFIER";
        return new Token(tkType, result);
    }
    
    static function createNotEqual():Null<Token>
    {
        var posStart:Position = position.copy(); // ← salva antes de avançar
        position.advance();
        currentChar = position.currentChar;
        
        if (currentChar == "=")
        {
            position.advance();
            currentChar = position.currentChar;
            return new Token("TT_NOT_EQ");
        }
        
        return null;
    }
    
    static function createEqualCase():Null<Token>
    {
        var posStart = position.copy(); // ← salva antes de avançar
        position.advance();
        currentChar = position.currentChar;
        
        if (currentChar == "=")
        {
            currentChar = position.currentChar;
            return new Token("TT_EQ_EQUAL");
        }
        else
        {
            currentChar = position.currentChar;
            return new Token("TT_ASSIGN");
        }
        
        return null;
    }
    
    static function raiseError(error:String, message:String)
    {
        Sys.print('$error: $message\n');
        errorRaised = true;
    }
}
