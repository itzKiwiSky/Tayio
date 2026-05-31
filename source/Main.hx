import Type.ValueType;
import pine.runtime.Runtime;
import prismcli.CLI;
import pine.parser.Parser;
import haxe.Json;
import pine.lexer.Lexer;

class Main
{
    static var isDebug:Bool = false;
    
    static function main()
    {
        var args:Array<String> = Sys.args();
        
        if (args[0] == "repl")
        {
            if (args[1] == "--debug" || args[1] == "-d")
                isDebug = true;
                
            replMode();
        }
        else
        {
            // com argumento → roda o arquivo
            var path = args[0];
            if (!sys.FileSystem.exists(path))
            {
                Sys.println('File "$path" not found');
                Sys.exit(1);
            }
            Runtime.currentFile = path;
            var source:String = sys.io.File.getContent(path);
            run(source);
        }
    }
    
    static function replMode()
    {
        Sys.println("Pine REPL");
        while (true)
        {
            Sys.print("|> ");
            var code:String = Sys.stdin().readLine();
            run(code);
        }
    }
    
    static function run(code:String)
    {
        switch (Lexer.lex(code))
        {
            case Ok(tokens):
                if (isDebug)
                {
                    Sys.println("tokens gerados com sucesso!");
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
                            Sys.println("AST gerada com sucesso!");
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
