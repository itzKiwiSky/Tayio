package pine.runtime;

import pine.runtime.Enviroment;

enum Value
{
    IntVal(v:Int);
    FloatVal(v:Float);
    StringVal(v:String);
    BoolVal(v:Bool);
    NullVal;
    ArrayVal(v:Array<Value>);
    FuncVal(params:Array<String>, body:Array<pine.parser.Node>, env:Enviroment);
}
