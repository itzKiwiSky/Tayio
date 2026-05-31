package pine.runtime;

import pine.parser.Node;
import pine.runtime.Runtime.RuntimeResult;
import pine.runtime.Environment;

enum Value
{
    IntVal(v:Int);
    FloatVal(v:Float);
    StringVal(v:String);
    BoolVal(v:Bool);
    NullVal;
    ArrayVal(v:Array<Value>);
    FuncVal(params:Array<String>, uses:Null<pine.parser.Node.UsesDecl>, body:Array<pine.parser.Node>, env:Environment);
    DictVal(entries:Map<String, Value>);
    NativeFuncVal(func:Array<Value>->RuntimeResult);
}
