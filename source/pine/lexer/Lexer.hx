package pine.lexer;

import pine.lexer.Token.TokenType;
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
        "not",
        "and",
        "or",
        "uses",
        "extends",
        "export",
        "module",
        "true",
        "false",
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
                tokens.push(new Token(TokenType.NEWLINE));
                position.advance();
                currentChar = position.currentChar;
            }
            else if (currentChar == "+")
            {
                tokens.push(new Token(TokenType.ADD));
                position.advance();
                currentChar = position.currentChar;
            }
            else if (currentChar == "-")
            {
                tokens.push(new Token(TokenType.SUB));
                position.advance();
            }
            else if (currentChar == "*")
            {
                tokens.push(new Token(TokenType.MUL));
                position.advance();
            }
            else if (currentChar == "/")
            {
                tokens.push(new Token(TokenType.DIV));
                position.advance();
            }
            else if (currentChar == "%")
            {
                tokens.push(new Token(TokenType.MOD));
                position.advance();
            }
            else if (currentChar == "^")
            {
                tokens.push(new Token(TokenType.POW));
                position.advance();
            }
            else if (currentChar == "(")
            {
                tokens.push(new Token(TokenType.LEFT_PAREN));
                position.advance();
            }
            else if (currentChar == ")")
            {
                tokens.push(new Token(TokenType.RIGHT_PAREN));
                position.advance();
            }
            else if (currentChar == "[")
            {
                tokens.push(new Token(TokenType.LEFT_SQUARE));
                position.advance();
            }
            else if (currentChar == "]")
            {
                tokens.push(new Token(TokenType.RIGHT_SQUARE));
                position.advance();
            }
            else if (currentChar == ",")
            {
                tokens.push(new Token(TokenType.COMMA));
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
                tokens.push(createEqualCase());
            else if (currentChar == ">")
                tokens.push(createGreaterThanCase());
            else if (currentChar == "<")
                tokens.push(createLowerThanCase());
            else if (~/[0-9]/.match(currentChar))
                tokens.push(createNumber());
            else if (currentChar == '"')
            {
                var posStart = position.copy();
                var result = createString();
                
                if (result == null)
                    return Err(new LangError(posStart, position.copy(), IllegalChar, "Unterminated string"));
                    
                tokens.push(result);
            }
            else if (currentChar == "#")
            {
                while (position.currentChar != "" && !~/[\n;]/.match(position.currentChar))
                {
                    position.advance();
                    currentChar = position.currentChar;
                }
            }
            else
            {
                return Err(new LangError(position.copy(), position.copy(), IllegalChar, 'caractere inválido: "$currentChar"'));
            }
        }
        
        tokens.push(new Token(TokenType.EOF));
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
        
        var tkType = switch (result)
        {
            case "true" | "false": TokenType.BOOLEAN;
            case _ if (keywords.contains(result)): TokenType.KEYWORD;
            case _: TokenType.IDENTIFIER;
        }
        
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
            return new Token(TokenType.NOT_EQUAL);
        }
        
        return null;
    }
    
    static function createEqualCase():Token
    {
        position.advance();
        currentChar = position.currentChar;
        
        if (currentChar == "=")
        {
            position.advance();
            currentChar = position.currentChar;
            return new Token(TokenType.EQ_EQUAL);
        }
        
        return new Token(TokenType.ASSIGN);
    }
    
    static function createGreaterThanCase():Token
    {
        position.advance();
        currentChar = position.currentChar;
        
        if (currentChar == "=")
        {
            position.advance();
            currentChar = position.currentChar;
            return new Token(TokenType.GT_OR_EQUAL);
        }
        
        return new Token(TokenType.GT);
    }
    
    static function createLowerThanCase():Token
    {
        position.advance();
        currentChar = position.currentChar;
        
        if (currentChar == "=")
        {
            position.advance();
            currentChar = position.currentChar;
            return new Token(TokenType.LW_OR_EQUAL);
        }
        
        return new Token(TokenType.LW_OR_EQUAL);
    }
    
    static function createString():Null<Token>
    {
        var result = "";
        var posStart = position.copy();
        var escaped = false;
        
        position.advance();
        currentChar = position.currentChar;
        
        while (position.currentChar != "" && (position.currentChar != '"' || escaped))
        {
            if (escaped)
            {
                result += switch (position.currentChar)
                {
                    case "n": "\n";
                    case "t": "\t";
                    case "\"": "\"";
                    case "\\": "\\";
                    case c: c;
                }
                escaped = false;
            }
            else if (position.currentChar == "\\")
                escaped = true;
            else
                result += position.currentChar;
                
            position.advance();
            currentChar = position.currentChar;
        }
        
        if (position.currentChar == "")
            return null;
            
        position.advance();
        currentChar = position.currentChar;
        
        return new Token(TokenType.STRING, result);
    }
    
    static function createNumber()
    {
        var res:String = "";
        var dotCount:Int = 0;
        
        while (position.currentChar != "" && ~/[0-9.]/.match(position.currentChar))
        {
            if (position.currentChar == ".")
            {
                if (dotCount >= 1)
                    break;
                dotCount++;
            }
            
            res += position.currentChar;
            position.advance();
            currentChar = position.currentChar;
        }
        
        if (dotCount <= 0)
            return new Token(TokenType.INTEGER, Std.parseInt(res));
        else
            return new Token(TokenType.FLOAT, Std.parseFloat(res));
    }
    
    static function raiseError(error:String, message:String)
    {
        Sys.print('$error: $message\n');
        errorRaised = true;
    }
}
