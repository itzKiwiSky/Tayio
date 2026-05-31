package pine.runtime.packages.std;

import pine.runtime.packages.std.io.Stdio;
import pine.runtime.packages.std.Mathlib;

class StdLib extends NativeNamespace
{
    public function new()
    {
        super("pine.std");
        add("math", new MathLib()); // add("out", new pine.runtime.packages.std.Mathlib());
        add("io", new Stdio());
    }
}
