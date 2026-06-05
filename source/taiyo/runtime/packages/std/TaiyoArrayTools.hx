package taiyo.runtime.packages.std;

import taiyo.runtime.INativePackage.IPackage;
import taiyo.runtime.Value;
import taiyo.runtime.NativeUtils;
import taiyo.lexer.LangError;

class TaiyoArrayTools implements IPackage
{
    public function new() {}
    
    public function getModule():Map<String, Value>
    {
        var mod:Map<String, Value> = [];
        
        // add(arr, item) ou add(arr, index, item)
        mod.set("add", NativeFuncVal(args ->
        {
            if (args.length < 2 || args.length > 3)
                return Err(new LangError(null, null, RuntimeError, 'add() expects 2 or 3 arguments'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    if (args.length == 2)
                        arr.push(args[1]);
                    else
                    {
                        var index = NativeUtils.toInt(args[1]);
                        if (index == null)
                            return Err(new LangError(null, null, RuntimeError, 'add() index must be an integer'));
                        arr.insert(index, args[2]);
                    }
                    return Ok(NullVal);
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'add() expects an array as first argument'));
            }
        }));
        
        // remove(arr, index)
        mod.set("remove", NativeFuncVal(args ->
        {
            if (args.length != 2)
                return Err(new LangError(null, null, RuntimeError, 'remove() expects 2 arguments'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    var index = NativeUtils.toInt(args[1]);
                    if (index == null)
                        return Err(new LangError(null, null, RuntimeError, 'remove() index must be an integer'));
                    if (index < 0 || index >= arr.length)
                        return Err(new LangError(null, null, RuntimeError, 'remove() index out of bounds'));
                    arr.splice(index, 1);
                    return Ok(NullVal);
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'remove() expects an array as first argument'));
            }
        }));
        
        // get(arr, index)
        mod.set("get", NativeFuncVal(args ->
        {
            if (args.length != 2)
                return Err(new LangError(null, null, RuntimeError, 'get() expects 2 arguments'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    var index = NativeUtils.toInt(args[1]);
                    if (index == null)
                        return Err(new LangError(null, null, RuntimeError, 'get() index must be an integer'));
                    if (index < 0 || index >= arr.length)
                        return Err(new LangError(null, null, RuntimeError, 'get() index out of bounds'));
                    return Ok(arr[index]);
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'get() expects an array as first argument'));
            }
        }));
        
        // set(arr, index, value)
        mod.set("set", NativeFuncVal(args ->
        {
            if (args.length != 3)
                return Err(new LangError(null, null, RuntimeError, 'set() expects 3 arguments'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    var index = NativeUtils.toInt(args[1]);
                    if (index == null)
                        return Err(new LangError(null, null, RuntimeError, 'set() index must be an integer'));
                    if (index < 0 || index >= arr.length)
                        return Err(new LangError(null, null, RuntimeError, 'set() index out of bounds'));
                    arr[index] = args[2];
                    return Ok(NullVal);
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'set() expects an array as first argument'));
            }
        }));
        
        // len(arr)
        mod.set("len", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'len() expects 1 argument'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    return Ok(IntVal(arr.length));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'len() expects an array as first argument'));
            }
        }));
        
        // contains(arr, value)
        mod.set("contains", NativeFuncVal(args ->
        {
            if (args.length != 2)
                return Err(new LangError(null, null, RuntimeError, 'contains() expects 2 arguments'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    for (item in arr)
                        if (valueEquals(item, args[1]))
                            return Ok(BoolVal(true));
                    return Ok(BoolVal(false));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'contains() expects an array as first argument'));
            }
        }));
        
        // indexOf(arr, value) -> int ou -1
        mod.set("indexOf", NativeFuncVal(args ->
        {
            if (args.length != 2)
                return Err(new LangError(null, null, RuntimeError, 'indexOf() expects 2 arguments'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    for (i in 0...arr.length)
                        if (valueEquals(arr[i], args[1]))
                            return Ok(IntVal(i));
                    return Ok(IntVal(-1));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'indexOf() expects an array as first argument'));
            }
        }));
        
        // slice(arr, from, to)
        mod.set("slice", NativeFuncVal(args ->
        {
            if (args.length != 3)
                return Err(new LangError(null, null, RuntimeError, 'slice() expects 3 arguments'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    var from = NativeUtils.toInt(args[1]);
                    var to = NativeUtils.toInt(args[2]);
                    if (from == null || to == null)
                        return Err(new LangError(null, null, RuntimeError, 'slice() indexes must be integers'));
                    return Ok(ArrayVal(arr.slice(from, to)));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'slice() expects an array as first argument'));
            }
        }));
        
        // concat(a, b) -> novo array
        mod.set("concat", NativeFuncVal(args ->
        {
            if (args.length != 2)
                return Err(new LangError(null, null, RuntimeError, 'concat() expects 2 arguments'));
            switch ([args[0], args[1]])
            {
                case [ArrayVal(a), ArrayVal(b)]:
                    return Ok(ArrayVal(a.concat(b)));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'concat() expects two arrays'));
            }
        }));
        
        // reverse(arr) -> modifica in-place
        mod.set("reverse", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'reverse() expects 1 argument'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    arr.reverse();
                    return Ok(NullVal);
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'reverse() expects an array as first argument'));
            }
        }));
        
        // copy(arr) -> copia rasa
        mod.set("copy", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'copy() expects 1 argument'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    return Ok(ArrayVal(arr.copy()));
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'copy() expects an array as first argument'));
            }
        }));
        
        // pop(arr) -> remove e retorna o ultimo
        mod.set("pop", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'pop() expects 1 argument'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    if (arr.length == 0)
                        return Err(new LangError(null, null, RuntimeError, 'pop() called on empty array'));
                    return Ok(arr.pop());
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'pop() expects an array as first argument'));
            }
        }));
        
        // shift(arr) -> remove e retorna o primeiro
        mod.set("shift", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'shift() expects 1 argument'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    if (arr.length == 0)
                        return Err(new LangError(null, null, RuntimeError, 'shift() called on empty array'));
                    return Ok(arr.shift());
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'shift() expects an array as first argument'));
            }
        }));
        
        mod.set("create", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'shift() expects 1 argument'));
            switch (args[0])
            {
                case ArrayVal(arr):
                    if (arr.length == 0)
                        return Err(new LangError(null, null, RuntimeError, 'shift() called on empty array'));
                    return Ok(arr.shift());
                case _:
                    return Err(new LangError(null, null, RuntimeError, 'shift() expects an array as first argument'));
            }
        }));
        
        mod.set("create", NativeFuncVal(args ->
        {
            if (args.length != 1)
                return Err(new LangError(null, null, RuntimeError, 'create() expects 1 argument'));
            var size = NativeUtils.toInt(args[0]);
            if (size == null || size < 0)
                return Err(new LangError(null, null, RuntimeError, 'create() expects a positive integer'));
            return Ok(ArrayVal([for (_ in 0...size) NullVal]));
        }));
        
        return mod;
    }
    
    static function valueEquals(a:Value, b:Value):Bool
    {
        return switch ([a, b])
        {
            case [IntVal(x), IntVal(y)]: x == y;
            case [FloatVal(x), FloatVal(y)]: x == y;
            case [StringVal(x), StringVal(y)]: x == y;
            case [BoolVal(x), BoolVal(y)]: x == y;
            case [NullVal, NullVal]: true;
            case _: false;
        }
    }
}
