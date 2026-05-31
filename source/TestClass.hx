package;

import pine.PineEntry;

class TestClass
{
    public static function test()
    {
        var code:String = 'use pine.std.io\nfunc main() do out.println("hello")';
        PineEntry.run(code);
    }
}
