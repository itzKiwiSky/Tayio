package test.specs;

import cli.Ansi;

class TestRunner
{
    var level:Int = 0;
    var passes:Int = 0;
    var errors:Int = 0;
    
    inline function indent(indLevel:Int = 1)
    {
        indLevel = indLevel ?? level;
        return StringTools.lpad("", "\t", level);
    }
    
    public function describe(name:String, func:(Void) -> Void)
    {
        // Sys.print(StringTools.lpad());
    }
}
