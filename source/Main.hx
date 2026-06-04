import taiyo.TaiyoMachine;

class Main
{
    static var isDebug:Bool = false;
    static var machine:TaiyoMachine;
    
    static function main()
    {
        var args:Array<String> = Sys.args();
        
        machine = new TaiyoMachine();
        
        if (args[0] == "repl")
        {
            if (args[1] == "--debug" || args[1] == "-d")
                machine.isDebug = true;
                
            replMode();
        }
        else if (args[0] == "test")
        {
            if (args[1] == "--debug" || args[1] == "-d")
                machine.isDebug = true;
            // run test here //
            
            TestClass.test();
        }
        else
        {
            if (args[1] == "--debug" || args[1] == "-d")
                machine.isDebug = true;
                
            var path = args[0];
            if (!sys.FileSystem.exists(path))
            {
                Sys.println('File "$path" not found');
                Sys.exit(1);
            }
            machine.setFilename(path);
            machine.setIn(path);
            
            var source:String = sys.io.File.getContent(path);
            machine.run(source);
        }
    }
    
    static function replMode()
    {
        Sys.println("taiyo REPL");
        while (true)
        {
            Sys.print("|> ");
            var code:String = Sys.stdin().readLine();
            machine.setIn("<stdin>");
            machine.run(code);
        }
    }
}
