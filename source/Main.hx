import pine.PineEntry;
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
                PineEntry.isDebug = true;
                
            replMode();
        }
        else if (args[0] == "test")
        {
            if (args[1] == "--debug" || args[1] == "-d")
                PineEntry.isDebug = true;
            // run test here //
            
            TestClass.test();
        }
        else
        {
            var path = args[0];
            if (!sys.FileSystem.exists(path))
            {
                Sys.println('File "$path" not found');
                Sys.exit(1);
            }
            PineEntry.setFilename(path);
            PineEntry.setIn(path);
            var source:String = sys.io.File.getContent(path);
            PineEntry.run(source);
        }
    }
    
    static function replMode()
    {
        Sys.println("Pine REPL");
        while (true)
        {
            Sys.print("|> ");
            var code:String = Sys.stdin().readLine();
            PineEntry.setIn("<stdin>");
            PineEntry.run(code);
        }
    }
}
