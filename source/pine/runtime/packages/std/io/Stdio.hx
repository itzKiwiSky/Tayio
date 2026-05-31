package pine.runtime.packages.std.io;

import pine.runtime.packages.std.Math.MathLib;

class Stdio extends NativeNamespace
{
    public function new()
    {
        super("pine.std.io");
        add("out", new Stdout());
        add("math", new MathLib());
    }
}
