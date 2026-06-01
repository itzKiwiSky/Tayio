package tayio.runtime;

import tayio.runtime.Runtime;
import tayio.parser.Node;
import tayio.runtime.Runtime.RuntimeResult;
import tayio.runtime.Environment;
import tayio.parser.Node;

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
