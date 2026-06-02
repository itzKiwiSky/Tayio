package taiyo.runtime;

import taiyo.runtime.Runtime;
import taiyo.parser.Node;
import taiyo.runtime.Runtime.RuntimeResult;
import taiyo.runtime.Environment;
import taiyo.parser.Node;

enum Value
{
    IntVal(v:Int);
    FloatVal(v:Float);
    StringVal(v:String);
    BoolVal(v:Bool);
    NullVal;
    ArrayVal(v:Array<Value>);
    FuncVal(params:Array<String>, uses:Null<UsesDecl>, body:Array<Node>, env:Environment);
    DictVal(entries:Map<String, Value>);
    NativeFuncVal(func:Array<Value>->RuntimeResult);
}
