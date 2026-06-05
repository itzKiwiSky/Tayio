package taiyo;

import taiyo.runtime.Runtime;
import taiyo.parser.Parser;
import taiyo.lexer.Lexer;

class TaiyoMachine
{
    public var isDebug:Bool = false;
    public var autoInitRuntime:Bool = true;
    
    public var runtime:Runtime;
    
    public function new()
    {
        this.isDebug = false;
        runtime = new Runtime();
    }
    
    public inline function dumpRuntimeNativeModules()
        runtime.dumpNativeModules();
        
    public inline function setFilename(fn:String)
        runtime.currentFile = fn;
        
    public inline function setIn(fn:String)
        Lexer.filename = fn;
        
    public function run(code:String)
    {
        // static runtime initialization //
        runtime.autoInitialization = autoInitRuntime;
        
        if (isDebug)
            runtime.dumpNativeModules();
            
        switch (Lexer.lex(code))
        {
            case Ok(tokens):
                if (isDebug)
                {
                    Sys.println("Tokens created with sucess");
                    Sys.print("[\n");
                    for (tk in tokens)
                        Sys.print("    " + tk + "\n");
                    Sys.print("]\n");
                }
                switch (Parser.parse(tokens))
                {
                    case Ok(ast):
                        if (isDebug)
                        {
                            Sys.println("AST generated with sucess!");
                            Sys.println(ast); // printa a árvore
                        }
                        switch (runtime.run(ast))
                        {
                            case Ok(value):
                                if (isDebug) Sys.println(value);
                                
                            case Err(error):
                                Sys.println(error.asString());
                                
                            case Signal(signal):
                                if (isDebug) Sys.println('Signal triggered $signal');
                        }
                        
                    case Err(error):
                        Sys.println(error.asString());
                }
                
            case Err(error):
                Sys.println(error.asString());
        }
    }
}
