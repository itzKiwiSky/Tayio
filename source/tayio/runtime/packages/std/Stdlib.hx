package tayio.runtime.packages.std;

import tayio.runtime.packages.std.Stdio;
import tayio.runtime.packages.std.Mathlib;

class StdLib extends NativeNamespace
{
    public function new()
    {
        super("tayio.std");
        add("math", new MathLib()); // add("out", new tayio.runtime.packages.std.Mathlib());
        add("io", new Stdio());
    }
}
