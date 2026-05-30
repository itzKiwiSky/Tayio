package pine.runtime;

import pine.runtime.packages.Stdlib;
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
    static var globalEnv:Environment = new Environment();
    
    public static function run(ast:Node):RuntimeResult
    {
        // or (node in ast) {}
        Stdlib.register(globalEnv);
        return evaluate(ast, globalEnv);
    }
    
    static function evaluate(node:Node, env:Environment):RuntimeResult
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
            case VarDeclNode(scope, name, value):
                switch (scope)
                {
                    case "global":
                        switch (evaluate(value, env))
                        {
                            case Ok(value):
                                globalEnv.createVar(name, value);
                            case Err(e): return Err(e);
                            case Signal(s): return Signal(s);
                        }
                    case "local":
                        switch (evaluate(value, env))
                        {
                            case Ok(value):
                                env.createVar(name, value);
                            case Err(e): return Err(e);
                            case Signal(s): return Signal(s);
                        }
                }
                
                return Ok(NullVal);
            case VarAccessNode(name):
                var v = env.getVar(name);
                if (v == null)
                    return Err(new LangError(null, null, RuntimeError, 'Variable "$name" is not defined'));
                return Ok(v);
            case AssignNode(name, value):
                switch (evaluate(value, env))
                {
                    case Ok(value):
                        // @formatter:off
                        if (!env.assign(name,value) && !globalEnv.assign(name, value)) 
                            return Err(new LangError(null, null, RuntimeError, 'Variable "$name" is not defined'));
                            
                        // @formatter:on
                    case Err(e): return Err(e);
                    case Signal(s): return Signal(s);
                }
                return Ok(NullVal);
            case UnaryOpNode(op, node):
                var val:Value = NullVal;
                switch (evaluate(node, env))
                {
                    case Ok(value): val = value;
                    case Err(e): return Err(e);
                    case Signal(s): return Signal(s);
                }
                
                return applyUnary(op, val);
            case IfNode(condition, body, elseIfs, elseBody):
                switch (evaluate(condition, env))
                {
                    case Ok(condVal):
                        if (isTruthy(condVal))
                        {
                            return executeBlock(body, new Environment(env));
                        }
                        else
                        {
                            for (ei in elseIfs)
                            {
                                switch (evaluate(ei.cond, env))
                                {
                                    case Ok(elseIfCondVal):
                                        if (isTruthy(elseIfCondVal))
                                        {
                                            return executeBlock(ei.body, new Environment(env));
                                        }
                                    case Err(e): return Err(e);
                                    case Signal(s): return Signal(s);
                                }
                            }
                        }
                        
                        if (elseBody != null) return executeBlock(elseBody, new Environment(env));
                    case Err(e): return Err(e);
                    case Signal(s): return Signal(s);
                }
                
                return Ok(NullVal);
            case WhileNode(condition, body):
                while (true)
                {
                    switch (evaluate(condition, env))
                    {
                        case Ok(condVal):
                            if (!isTruthy(condVal))
                                break;
                            switch (executeBlock(body, new Environment(env)))
                            {
                                case Signal(SBreak): break; // ← captura e para o loop
                                case Signal(SContinue): continue; // ← captura e pula pra próxima iteração
                                case Err(e): return Err(e);
                                case _:
                            }
                        case Err(e):
                            return Err(e);
                        case Signal(s): return Signal(s);
                    }
                }
                
                return Ok(NullVal);
            case ForRangeNode(varName, from, to, body):
                switch (evaluate(from, env))
                {
                    case Ok(IntVal(from)):
                        switch (evaluate(to, env))
                        {
                            case Ok(IntVal(to)):
                                for (i in from...to)
                                {
                                    var loopEnv = new Environment(env);
                                    loopEnv.createVar(varName, IntVal(i)); // contador disponível no body
                                    switch (executeBlock(body, loopEnv))
                                    {
                                        case Err(e): return Err(e);
                                        case Signal(s): return Signal(s);
                                        case _:
                                    }
                                }
                                return Ok(NullVal);
                            case Ok(_):
                                return Err(new LangError(null, null, RuntimeError, 'For range expects integers'));
                            case other: return other;
                        }
                    case Ok(_):
                        return Err(new LangError(null, null, RuntimeError, 'For range expects integers'));
                    case other: return other;
                }
            case ArrayNode(elements):
                var result:Array<Value> = [];
                
                for (node in elements)
                {
                    switch (evaluate(node, env))
                    {
                        case Ok(value):
                            result.push(value);
                        case Err(e): return Err(e);
                        case Signal(s): return Signal(s);
                    }
                }
                
                return Ok(ArrayVal(result));
            case ForInNode(varName, iterable, body):
                switch (evaluate(iterable, env))
                {
                    case Ok(ArrayVal(arr)):
                        for (element in arr)
                        {
                            var loopEnv = new Environment(env);
                            loopEnv.createVar(varName, element); // "item" = valor atual do array
                            switch (executeBlock(body, loopEnv))
                            {
                                case Err(e): return Err(e);
                                case Signal(s): return Signal(s);
                                case _:
                            }
                        }
                    case Ok(_):
                        return Err(new LangError(null, null, RuntimeError, 'Expected array in for in'));
                    case Err(e): return Err(e);
                    case Signal(s): return Signal(s);
                }
                
                return Ok(NullVal);
            case FuncDeclNode(name, params, uses, body):
                env.createVar(name, FuncVal(params, body, env));
                return Ok(NullVal);
            case CallNode(name, args):
                var funcDec:Value = env.getVar(name);
                var evaledArgs:Array<Value> = [];
                
                for (arg in args)
                {
                    switch (evaluate(arg, env))
                    {
                        case Ok(v): evaledArgs.push(v);
                        case Err(e): return Err(e);
                        case Signal(s): return Signal(s);
                    }
                }
                
                switch (funcDec)
                {
                    case FuncVal(params, body, env):
                        var callEnv:Environment = new Environment(env);
                        for (i in 0...params.length)
                        {
                            callEnv.createVar(params[i], evaledArgs[i]);
                        }
                        
                        for (stmt in body)
                        {
                            switch (evaluate(stmt, callEnv))
                            {
                                case Ok(value):
                                case Err(e): return Err(e);
                                case Signal(SReturn(value)): return Ok(value); // ← captura o return
                                case Signal(s): return Signal(s); // break/continue propagam
                            }
                        }
                    case NativeFuncVal(func):
                        return func(evaledArgs);
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Unknown value type: $funcDec'));
                }
                return Ok(NullVal);
            case ReturnNode(value):
                if (value == null)
                    return Signal(SReturn(NullVal));
                    
                switch (evaluate(value, env))
                {
                    case Ok(v): return Signal(SReturn(v));
                    case other: return other;
                }
            case BreakNode:
                return Signal(SBreak);
                
            case ContinueNode:
                return Signal(SContinue);
            case DictNode(entries):
                var result:Map<String, Value> = [];
                for (entry in entries)
                {
                    switch (evaluate(entry.value, env))
                    {
                        case Ok(value):
                            result.set(entry.key, value);
                        case Err(e): return Err(e);
                        case Signal(s): return Signal(s);
                    }
                }
                
                return Ok(DictVal(result));
            case FieldAccessNode(target, field):
                switch (evaluate(target, env))
                {
                    case Ok(DictVal(entries)):
                        var f:Value = entries.get(field);
                        if (f == null)
                            return Err(new LangError(null, null, RuntimeError, 'Field "$field" does not exist'));
                        return Ok(f);
                    case Ok(_):
                        return Err(new LangError(null, null, RuntimeError, 'Cannot access field "$field" on a non-dict value'));
                    case Err(e): return Err(e);
                    case Signal(s): return Signal(s);
                }
                
                return Ok(NullVal);
            case FuncExprNode(params, uses, body):
                return Ok(FuncVal(params, body, env));
            case FieldCallNode(target, field, args):
                trace("target node: " + target);
                switch (evaluate(target, env))
                {
                    case Ok(DictVal(entries)):
                        var funcVal = entries.get(field);
                        if (funcVal == null)
                            return Err(new LangError(null, null, RuntimeError, 'Field "$field" does not exist'));
                            
                        var evaledArgs:Array<Value> = [];
                        for (arg in args)
                        {
                            switch (evaluate(arg, env))
                            {
                                case Ok(v): evaledArgs.push(v);
                                case other: return other;
                            }
                        }
                        
                        switch (funcVal)
                        {
                            case FuncVal(params, body, funcEnv):
                                var callEnv = new Environment(funcEnv);
                                for (i in 0...params.length)
                                    callEnv.createVar(params[i], evaledArgs[i]);
                                    
                                switch (executeBlock(body, callEnv))
                                {
                                    case Signal(SReturn(v)): return Ok(v);
                                    case Err(e): return Err(e);
                                    case Signal(s): return Signal(s);
                                    case _: return Ok(NullVal);
                                }
                                
                            case _:
                                return Err(new LangError(null, null, RuntimeError, '"$field" is not a function'));
                        }
                        
                    case Ok(_):
                        return Err(new LangError(null, null, RuntimeError, 'Cannot call field "$field" on a non-dict value'));
                    case other: return other;
                }
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
            case EQ_EQUAL:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(BoolVal(a == b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(BoolVal(a == b));
                    case [StringVal(a), StringVal(b)]: return Ok(BoolVal(a == b));
                    case [BoolVal(a), BoolVal(b)]: return Ok(BoolVal(a == b));
                    case [NullVal, NullVal]: return Ok(BoolVal(false));
                    case _: return Ok(BoolVal(false));
                }
            case NOT_EQUAL:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(BoolVal(a != b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(BoolVal(a != b));
                    case [StringVal(a), StringVal(b)]: return Ok(BoolVal(a != b));
                    case [BoolVal(a), BoolVal(b)]: return Ok(BoolVal(a != b));
                    case [NullVal, NullVal]: return Ok(BoolVal(false));
                    case _: return Ok(BoolVal(false));
                }
            case GT:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]:
                        return Ok(BoolVal(a > b));
                    case [FloatVal(a), FloatVal(b)]:
                        return Ok(BoolVal(a > b));
                    case [IntVal(a), FloatVal(b)]:
                        return Ok(BoolVal(a > b));
                    case [FloatVal(a), IntVal(b)]:
                        return Ok(BoolVal(a > b));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot compare $left and $right'));
                }
            case GT_OR_EQUAL:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]:
                        return Ok(BoolVal(a >= b));
                    case [FloatVal(a), FloatVal(b)]:
                        return Ok(BoolVal(a >= b));
                    case [IntVal(a), FloatVal(b)]:
                        return Ok(BoolVal(a >= b));
                    case [FloatVal(a), IntVal(b)]:
                        return Ok(BoolVal(a >= b));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot compare $left and $right'));
                }
            case LW:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]:
                        return Ok(BoolVal(a < b));
                    case [FloatVal(a), FloatVal(b)]:
                        return Ok(BoolVal(a < b));
                    case [IntVal(a), FloatVal(b)]:
                        return Ok(BoolVal(a < b));
                    case [FloatVal(a), IntVal(b)]:
                        return Ok(BoolVal(a < b));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot compare $left and $right'));
                }
            case LW_OR_EQUAL:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]:
                        return Ok(BoolVal(a <= b));
                    case [FloatVal(a), FloatVal(b)]:
                        return Ok(BoolVal(a <= b));
                    case [IntVal(a), FloatVal(b)]:
                        return Ok(BoolVal(a <= b));
                    case [FloatVal(a), IntVal(b)]:
                        return Ok(BoolVal(a <= b));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot compare $left and $right'));
                }
            case _:
                return Err(new LangError(null, null, RuntimeError, 'Unknown operator ${op.type}'));
        }
        
        return Ok(NullVal);
    }
    
    static function applyUnary(op:Token, value:Value):RuntimeResult
    {
        switch (op.type)
        {
            case SUB:
                switch (value)
                {
                    case IntVal(v):
                        return Ok(IntVal(-v));
                    case FloatVal(v):
                        return Ok(FloatVal(-v));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot invert signal for $value'));
                }
                
            case KEYWORD if (op.value == "not"):
                switch (value)
                {
                    case BoolVal(v): return Ok(BoolVal(!v));
                    case _:
                        return Err(new LangError(null, null, RuntimeError, 'Cannot apply "not" to $value'));
                }
            case _:
                return Err(new LangError(null, null, RuntimeError, 'Unknown unary operator ${op.type}'));
        }
    }
    
    static function isTruthy(value:Value):Bool
    {
        return switch (value)
        {
            case BoolVal(v): v;
            case _: false;
        }
    }
    
    static function executeBlock(body:Array<Node>, env:Environment):RuntimeResult
    {
        var last:Value = NullVal;
        for (stmt in body)
        {
            switch (evaluate(stmt, env))
            {
                case Ok(v):
                    last = v;
                case other:
                    return other;
            }
        }
        return Ok(last);
    }
}
