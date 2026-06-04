package taiyo.runtime.packages.std;

import taiyo.runtime.packages.std.Stdio;
import taiyo.runtime.packages.std.Mathlib;
import taiyo.runtime.packages.std.TaiyoStringTools;
import taiyo.runtime.packages.std.TaiyoArrayTools;
import taiyo.runtime.packages.std.crypto.StdCrypto;

class StdLib extends NativeNamespace
{
    public function new()
    {
        super("taiyo.std");
        add("math", new MathLib());
        add("io", new Stdio());
        add("stringTools", new TaiyoStringTools());
        add("arrayTools", new TaiyoArrayTools());
        
        /* namespace crypto */
        add("crypto", new StdCrypto());
    }
}
