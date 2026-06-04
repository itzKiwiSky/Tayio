package taiyo.runtime.packages.std.crypto;

import taiyo.runtime.NativeNamespace;

class StdCrypto extends NativeNamespace
{
    public function new()
    {
        super("taiyo.std.crypto");
        add("hash", new TaiyoCrypto());
    }
}
