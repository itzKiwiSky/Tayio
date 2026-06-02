package taiyo.runtime.packages.std;

import taiyo.runtime.packages.std.Stdio;
import taiyo.runtime.packages.std.Mathlib;

class StdLib extends NativeNamespace
{
    public function new()
    {
        super("taiyo.std");
        add("math", new MathLib());
        add("io", new Stdio());
    }
}
