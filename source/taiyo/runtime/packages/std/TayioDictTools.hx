package taiyo.runtime.packages.std;

import taiyo.runtime.INativePackage.IPackage;

class TayioDictTools implements IPackage
{
    public function new() {}
    
    public function getModule()
    {
        var mod:Map<String, Value> = [];
        return mod;
    }
}
