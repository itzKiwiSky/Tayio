package taiyo.runtime.packages.std;

import taiyo.runtime.INativePackage.IPackage;
import taiyo.runtime.Value;
import taiyo.runtime.NativeUtils;
import taiyo.lexer.LangError;

class TaiyoDictTools implements IPackage
{
    public function new() {}
    
    public function getModule():Map<String, Value>
    {
        var mod:Map<String, Value> = [];
        
        // dictTools.set(dict, key, value)
        mod.set("set", NativeFuncVal(args ->
        {
            if (args.length != 3)
                return Err(new LangError(null, null, RuntimeError, 'set() expects 3 arguments'));
            switch (args[0])
            {
                case DictVal(d):
                    var key = NativeUtils.toString(args[1]);
                    if (key == null)
                        return Err(new LangError(null, null, RuntimeError, 'set() key must be a string'));
                    d.set(key, args[2]);
                    return Ok(NullVal);
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'set() expects a dict as first argument'));
            }
        }));
        
        // dictTools.get(dict, key)
        mod.set("get", NativeFuncVal(args ->
        {
            if (args.length != 2)
                return Err(new LangError(null, null, RuntimeError, 'get() expects 2 arguments'));
            switch (args[0])
            {
                case DictVal(d):
                    var key = NativeUtils.toString(args[1]);
                    if (key == null)
                        return Err(new LangError(null, null, RuntimeError, 'get() key must be a string'));
                    var v = d.get(key);
                    return Ok(v != null ? v : NullVal);
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'get() expects a dict as first argument'));
            }
        }));
        
        // dictTools.remove(dict, key)
        mod.set("remove", NativeFuncVal(args ->
        {
            if (args.length != 2)
                return Err(new LangError(null, null, RuntimeError, 'remove() expects 2 arguments'));
            switch (args[0])
            {
                case DictVal(d):
                    var key = NativeUtils.toString(args[1]);
                    if (key == null)
                        return Err(new LangError(null, null, RuntimeError, 'remove() key must be a string'));
                    d.remove(key);
                    return Ok(NullVal);
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'remove() expects a dict as first argument'));
            }
        }));
        
        // dictTools.has(dict, key)
        mod.set("has", NativeFuncVal(args ->
        {
            if (args.length != 2)
                return Err(new LangError(null, null, RuntimeError, 'has() expects 2 arguments'));
            switch (args[0])
            {
                case DictVal(d):
                    var key = NativeUtils.toString(args[1]);
                    if (key == null)
                        return Err(new LangError(null, null, RuntimeError, 'has() key must be a string'));
                    return Ok(BoolVal(d.exists(key)));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'has() expects a dict as first argument'));
            }
        }));
        
        // dictTools.keys(dict) -> array de strings
        mod.set("keys", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'keys() expects 1 argument'));
            switch (args[0])
            {
                case DictVal(d):
                    var keys:Array<Value> = [for (k in d.keys()) StringVal(k)];
                    return Ok(ArrayVal(keys));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'keys() expects a dict as first argument'));
            }
        }));
        
        // dictTools.values(dict) -> array de valores
        mod.set("values", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'values() expects 1 argument'));
            switch (args[0])
            {
                case DictVal(d):
                    var vals:Array<Value> = [for (_ => v in d) v];
                    return Ok(ArrayVal(vals));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'values() expects a dict as first argument'));
            }
        }));
        
        // dictTools.len(dict) -> int
        mod.set("len", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'len() expects 1 argument'));
            switch (args[0])
            {
                case DictVal(d):
                    var count = 0;
                    for (_ in d)
                        count++;
                    return Ok(IntVal(count));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'len() expects a dict as first argument'));
            }
        }));
        
        // dictTools.merge(a, b) -> novo dict com tudo de a + b, b sobrescreve
        mod.set("merge", NativeFuncVal(args ->
        {
            if (args.length != 2)
                return Err(new LangError(null, null, RuntimeError, 'merge() expects 2 arguments'));
            switch ([args[0], args[1]])
            {
                case [DictVal(a), DictVal(b)]:
                    var result:Map<String, Value> = [];
                    for (k => v in a)
                        result.set(k, v);
                    for (k => v in b)
                        result.set(k, v);
                    return Ok(DictVal(result));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'merge() expects two dicts'));
            }
        }));
        
        // dictTools.copy(dict) -> copia rasa
        mod.set("copy", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'copy() expects 1 argument'));
            switch (args[0])
            {
                case DictVal(d):
                    var result:Map<String, Value> = [];
                    for (k => v in d)
                        result.set(k, v);
                    return Ok(DictVal(result));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'copy() expects a dict as first argument'));
            }
        }));
        
        return mod;
    }
}
