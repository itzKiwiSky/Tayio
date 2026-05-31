package pine;

import pine.runtime.Runtime;
import pine.parser.Parser;
import pine.lexer.Lexer;

class PineEntry
{
    public static var isDebug:Bool = false;
    
    public static function setFilename(fn:String)
    {
        Runtime.currentFile = fn;
    }
    
    public static function setIn(fn:String)
    {
        Lexer.filename = fn;
    }
    
    public static function run(code:String)
    {
        switch (Lexer.lex(code))
        {
            case Ok(tokens):
                if (isDebug)
                {
                    Sys.println("Tokens created with sucess");
                    Sys.print("[\n");
                    for (tk in tokens)
                        Sys.print("    " + tk + "\n");
                    Sys.print("[\n");
                }
                switch (Parser.parse(tokens))
                {
                    case Ok(ast):
                        if (isDebug)
                        {
                            Sys.println("AST generated with sucess!");
                            Sys.println(ast); // printa a árvore
                        }
                        switch (Runtime.run(ast))
                        {
                            case Ok(value):
                                if (isDebug) Sys.println(value);
                                
                            case Err(error):
                                Sys.println(error.asString());
                                
                            case Signal(signal):
                                Sys.println('Signal triggered $signal');
                        }
                        
                    case Err(error):
                        Sys.println(error.asString());
                }
                
            case Err(error):
                Sys.println(error.asString());
        }
    }
}
