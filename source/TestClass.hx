package;

import tayio.TaiyoMachine;

class TestClass
{
    static var machine:TayioMachine;
    
    public static function test()
    {
        machine = new TayioMachine();
        
        var code:String = 'use tayio.std.io\nfunc test() do out.println("hello test") end';
        machine.autoInitRuntime = false;
        machine.runtime.init();
        machine.run(code);
        machine.runtime.call("test", []);
    }
}
