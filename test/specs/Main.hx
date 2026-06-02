package test.specs;

import taiyo.lexer.Lexer;
import taiyo.lexer.Token;

class Main
{
    static function main()
    {
        trace("========================================");
        trace("BASIC TESTS");
        trace("========================================\n");
        
        trace("\nTest 1: Keywords\n");
        
        var stringedKeywords:String = Lexer.keywords.join(" ");
        
        var result:Array<Token> = Lexer.lex(stringedKeywords);
        
        for (i in 0...result.length - 1)
        {
            var tk:Token = result[i];
            var curKeyword:String = Lexer.keywords[i];
            // Assert.equals(tk.type, "TT_KEYWORD");
            // Assert.equals(tk.value, keywords[i]);
            
            assert(tk.type == "TT_KEYWORD", "Token type check" + i);
            assert(tk.value == Lexer.keywords[i], 'Token value check $i $curKeyword');
        }
        
        assert(result[result.length - 1].type == "TT_EOF", "Token type check for End of file token");
        
        trace("\nTest 2: Identifiers\n");
        
        result = result.splice(0, result.length);
        
        var myStringTest:String = "id identifier a b c d e";
        result = Lexer.lex(myStringTest);
        
        assert(result.length == 8, "Expect 7 identifiers + 1 eof token"); // we expect 7 identifiers and eof
        
        for (i in 0...result.length - 1)
        {
            var tk:Token = result[i];
            assert(tk.type == "TT_IDENTIFIER", "Expect each token on the range to be a Identifier");
        }
        
        trace("\nTest 3: Symbols\n");
        result = result.splice(0, result.length);
        
        myStringTest = "+-*/ %^ ( ) [],\n;";
        
        result = Lexer.lex(myStringTest);
        
        var expectedTokens:Array<String> = [
            "TT_ADD",
            "TT_SUB",
            "TT_MUL",
            "TT_DIV",
            "TT_MOD",
            "TT_POW",
            "TT_LEFT_PAREN",
            "TT_RIGHT_PAREN",
            "TT_LEFT_SQUARE",
            "TT_RIGHT_SQUARE",
            "TT_COMMA",
            "TT_NEWLINE",
            "TT_NEWLINE",
        ];
        
        for (i in 0...expectedTokens.length) // we expect 11 chars to be tokens ignoring eof
        {
            var tk:Token = result[i];
            
            var curSym:String = expectedTokens[i];
            
            assert(tk.type == expectedTokens[i], 'Check token type for symbol $curSym');
        }
        
        trace("========================================");
        trace("ALL BASIC TESTS PASSED!");
        trace("========================================");
        
        Sys.exit(0);
    }
    
    static function assert(condition:Bool, message:String)
    {
        if (!condition)
        {
            throw '[.] Assertion failed: $message';
        }
        trace('[X] $message');
    }
}
