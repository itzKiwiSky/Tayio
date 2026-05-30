package pine.runtime;

import haxe.macro.Expr.Case;
import pine.lexer.Token;
import pine.parser.Node;
import pine.lexer.LangError;

enum Signal
{
    SReturn(value:Value); // encontrou um return
    SBreak; // encontrou um break
    SContinue; // encontrou um continue
}

enum RuntimeResult
{
    Ok(value:Value);
    Err(error:LangError);
    Signal(s:Signal); // parou por return/break/continue
}

class Runtime
{
    static var globalEnv:Enviroment = new Enviroment();
    
    public static function run(ast:Node):RuntimeResult
    {
        // or (node in ast) {}
        return evaluate(ast, globalEnv);
    }
    
    static function evaluate(node:Node, env:Enviroment):RuntimeResult
    {
        switch (node)
        {
            case BlockNode(statements):
                var last:Value = NullVal;
                for (stmt in statements)
                {
                    switch (evaluate(stmt, env))
                    {
                        case Ok(v): last = v;
                        case Err(e): return Err(e);
                        case Signal(s): return Signal(s);
                    }
                }
                return Ok(last);
            case IntNode(value):
                return Ok(IntVal(value));
            case FloatNode(value):
                return Ok(FloatVal(value));
            case StringNode(value):
                return Ok(StringVal(value));
            case BoolNode(value):
                return Ok(BoolVal(value));
            case NullNode:
                return Ok(NullVal);
            case BinOpNode(left, op, right):
                var leftVal:Value = NullVal;
                var rightVal:Value = NullVal;
                
                switch (evaluate(left, env))
                {
                    case Ok(value): leftVal = value;
                    case Err(e): return Err(e);
                    case Signal(s): return Signal(s);
                }
                
                switch (evaluate(right, env))
                {
                    case Ok(value): rightVal = value;
                    case Err(e): return Err(e);
                    case Signal(s): return Signal(s);
                }
                
                return applyBinOp(leftVal, op, rightVal);
            case _:
                return Err(new LangError(null, null, RuntimeError, 'Unknown node: $node'));
        }
    }
    
    static function applyBinOp(left:Value, op:Token, right:Value):RuntimeResult
    {
        switch (op.type)
        {
            case ADD:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(IntVal(a + b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(FloatVal(a + b));
                    case [IntVal(a), FloatVal(b)]: return Ok(FloatVal(a + b));
                    case [FloatVal(a), IntVal(b)]: return Ok(FloatVal(a + b));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot add $left and $right'));
                }
            case SUB:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(IntVal(a - b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(FloatVal(a - b));
                    case [IntVal(a), FloatVal(b)]: return Ok(FloatVal(a - b));
                    case [FloatVal(a), IntVal(b)]: return Ok(FloatVal(a - b));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot subtract $left and $right'));
                }
            case MUL:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(IntVal(a * b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(FloatVal(a * b));
                    case [IntVal(a), FloatVal(b)]: return Ok(FloatVal(a * b));
                    case [FloatVal(a), IntVal(b)]: return Ok(FloatVal(a * b));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot multiply $left and $right'));
                }
            case DIV:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]:
                        if (b == 0)
                            return Err(new LangError(null, null, RuntimeError, 'Division by zero'));
                        return Ok(FloatVal(a / b));
                    case [FloatVal(a), FloatVal(b)]:
                        if (b == 0)
                            return Err(new LangError(null, null, RuntimeError, 'Division by zero'));
                        return Ok(FloatVal(a / b));
                    case [IntVal(a), FloatVal(b)]:
                        if (b == 0)
                            return Err(new LangError(null, null, RuntimeError, 'Division by zero'));
                        return Ok(FloatVal(a / b));
                    case [FloatVal(a), IntVal(b)]:
                        if (b == 0)
                            return Err(new LangError(null, null, RuntimeError, 'Division by zero'));
                        return Ok(FloatVal(a / b));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot divide $left and $right'));
                }
            case MOD:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(IntVal(a % b));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot mod $left and $right'));
                }
            case POW:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(FloatVal(Math.pow(a, b)));
                    case [FloatVal(a), FloatVal(b)]: return Ok(FloatVal(Math.pow(a, b)));
                    case [IntVal(a), FloatVal(b)]: return Ok(FloatVal(Math.pow(a, b)));
                    case [FloatVal(a), IntVal(b)]: return Ok(FloatVal(Math.pow(a, b)));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot divide $left and $right'));
                }
            case _:
                return Err(new LangError(null, null, RuntimeError, 'Unknown operator ${op.type}'));
        }
        
        return Ok(NullVal);
    }
}
