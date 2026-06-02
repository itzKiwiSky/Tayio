package;

import taiyo.TaiyoMachine;

class TestClass
{
    static var machine:TaiyoMachine;
    
    public static function test()
    {
        machine = new TaiyoMachine();
        
        var code:String = 'use taiyo.std.io\nfunc test() do out.println("hello test") end';
        machine.autoInitRuntime = false;
        machine.runtime.init();
        machine.run(code);
        machine.runtime.call("test", []);
    }
}
