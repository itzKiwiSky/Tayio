package pine.runtime;

import pine.runtime.packages.Stdlib;
import pine.lexer.Token;
import pine.parser.Node;
import pine.lexer.LangError;

enum Signal
{
    SReturn(value:Value);
    SBreak;
    SContinue;
}

enum RuntimeResult
{
    Ok(value:Value);
    Err(error:LangError);
    Signal(s:Signal);
}

class Runtime
{
    static var globalEnv:Environment = new Environment();
    static var _nativeModules:Map<String, Map<String, Value>> = [];
    
    public static inline function addNativeModule(mod:INativeModule):Void
        _nativeModules.set(mod.modname, mod.getModule());
        
    public static function run(ast:Node):RuntimeResult
    {
        addNativeModule(new Stdlib());
        
        switch (evaluate(ast, globalEnv))
        {
            case Err(e):
                return Err(e);
            case _:
        }
        
        var mainFunc = globalEnv.getVar("main");
        if (mainFunc == null)
            return Err(new LangError(null, null, RuntimeError, 'No "main" function defined'));
            
        switch (mainFunc)
        {
            // ← fix: agora tem uses
            case FuncVal(params, uses, body, funcEnv):
                var callEnv = new Environment(funcEnv);
                if (uses != null && _nativeModules.exists(uses))
                    for (k => v in _nativeModules.get(uses))
                        callEnv.createVar(k, v);
                switch (executeBlock(body, callEnv))
                {
                    case Signal(SReturn(v)): return Ok(v);
                    case Err(e): return Err(e);
                    case _: return Ok(NullVal);
                }
            case _:
                return Err(new LangError(null, null, RuntimeError, '"main" must be a function'));
        }
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
                        case other: return other;
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
                    case Ok(v): leftVal = v;
                    case other: return other;
                }
                switch (evaluate(right, env))
                {
                    case Ok(v): rightVal = v;
                    case other: return other;
                }
                return applyBinOp(leftVal, op, rightVal);
                
            case UnaryOpNode(op, node):
                switch (evaluate(node, env))
                {
                    case Ok(v): return applyUnary(op, v);
                    case other: return other;
                }
                
            case VarDeclNode(scope, name, value):
                switch (evaluate(value, env))
                {
                    case Ok(v):
                        if (scope == "global") globalEnv.createVar(name, v); else env.createVar(name, v);
                    case other: return other;
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
                    case Ok(v):
                        if (!env.assign(name,
                            v) && !globalEnv.assign(name, v)) return Err(new LangError(null, null, RuntimeError, 'Variable "$name" is not defined'));
                    case other: return other;
                }
                return Ok(NullVal);
                
            case IfNode(condition, body, elseIfs, elseBody):
                switch (evaluate(condition, env))
                {
                    case Ok(condVal):
                        if (isTruthy(condVal))
                            return executeBlock(body, new Environment(env));
                            
                        for (ei in elseIfs)
                        {
                            switch (evaluate(ei.cond, env))
                            {
                                case Ok(cv):
                                    if (isTruthy(cv)) return executeBlock(ei.body, new Environment(env));
                                case other: return other;
                            }
                        }
                        
                        if (elseBody != null) return executeBlock(elseBody, new Environment(env));
                        
                    case other: return other;
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
                                case Signal(SBreak): break;
                                case Signal(SContinue): continue;
                                case Err(e): return Err(e);
                                case _:
                            }
                        case other: return other;
                    }
                }
                return Ok(NullVal);
                
            case ForRangeNode(varName, from, to, body):
                switch (evaluate(from, env))
                {
                    case Ok(IntVal(f)):
                        switch (evaluate(to, env))
                        {
                            case Ok(IntVal(t)):
                                for (i in f...t)
                                {
                                    var loopEnv = new Environment(env);
                                    loopEnv.createVar(varName, IntVal(i));
                                    switch (executeBlock(body, loopEnv))
                                    {
                                        case Signal(SBreak): break;
                                        case Signal(SContinue): continue;
                                        case Err(e): return Err(e);
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
                
            case ForInNode(varName, iterable, body):
                switch (evaluate(iterable, env))
                {
                    case Ok(ArrayVal(arr)):
                        for (element in arr)
                        {
                            var loopEnv = new Environment(env);
                            loopEnv.createVar(varName, element);
                            switch (executeBlock(body, loopEnv))
                            {
                                case Signal(SBreak): break;
                                case Signal(SContinue): continue;
                                case Err(e): return Err(e);
                                case _:
                            }
                        }
                    case Ok(_):
                        return Err(new LangError(null, null, RuntimeError, 'Expected array in for in'));
                    case other: return other;
                }
                return Ok(NullVal);
                
            case ArrayNode(elements):
                var result:Array<Value> = [];
                for (node in elements)
                {
                    switch (evaluate(node, env))
                    {
                        case Ok(v): result.push(v);
                        case other: return other;
                    }
                }
                return Ok(ArrayVal(result));
                
            case DictNode(entries):
                var result:Map<String, Value> = [];
                for (entry in entries)
                {
                    switch (evaluate(entry.value, env))
                    {
                        case Ok(v): result.set(entry.key, v);
                        case other: return other;
                    }
                }
                return Ok(DictVal(result));
                
            case FieldAccessNode(target, field):
                switch (evaluate(target, env))
                {
                    case Ok(DictVal(entries)):
                        var f = entries.get(field);
                        if (f == null)
                            return Err(new LangError(null, null, RuntimeError, 'Field "$field" does not exist'));
                        return Ok(f);
                    case Ok(_):
                        return Err(new LangError(null, null, RuntimeError, 'Cannot access field "$field" on a non-dict value'));
                    case other: return other;
                }
                
            // ← fix: agora passa uses
            case FuncDeclNode(name, params, uses, body):
                env.createVar(name, FuncVal(params, uses, body, env));
                return Ok(NullVal);
                
            // ← fix: agora passa uses
            case FuncExprNode(params, uses, body):
                return Ok(FuncVal(params, uses, body, env));
                
            case CallNode(name, args):
                var funcDec = env.getVar(name);
                if (funcDec == null)
                    return Err(new LangError(null, null, RuntimeError, 'Function "$name" is not defined'));
                    
                var evaledArgs:Array<Value> = [];
                for (arg in args)
                {
                    switch (evaluate(arg, env))
                    {
                        case Ok(v): evaledArgs.push(v);
                        case other: return other;
                    }
                }
                
                switch (funcDec)
                {
                    // ← fix: agora tem uses, e sem loop duplicado
                    case FuncVal(params, uses, body, funcEnv):
                        var callEnv = new Environment(funcEnv);
                        if (uses != null && _nativeModules.exists(uses))
                            for (k => v in _nativeModules.get(uses))
                                callEnv.createVar(k, v);
                        for (i in 0...params.length)
                            callEnv.createVar(params[i], evaledArgs[i]);
                        for (stmt in body)
                        {
                            switch (evaluate(stmt, callEnv))
                            {
                                case Ok(_):
                                case Signal(SReturn(v)): return Ok(v);
                                case other: return other;
                            }
                        }
                        
                    case NativeFuncVal(func):
                        return func(evaledArgs);
                        
                    case _:
                        return Err(new LangError(null, null, RuntimeError, '"$name" is not a function'));
                }
                return Ok(NullVal);
                
            case FieldCallNode(target, field, args):
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
                            // ← fix: agora tem uses
                            case FuncVal(params, uses, body, funcEnv):
                                var callEnv = new Environment(funcEnv);
                                if (uses != null && _nativeModules.exists(uses))
                                    for (k => v in _nativeModules.get(uses))
                                        callEnv.createVar(k, v);
                                for (i in 0...params.length)
                                    callEnv.createVar(params[i], evaledArgs[i]);
                                switch (executeBlock(body, callEnv))
                                {
                                    case Signal(SReturn(v)): return Ok(v);
                                    case Err(e): return Err(e);
                                    case Signal(s): return Signal(s);
                                    case _: return Ok(NullVal);
                                }
                                
                            case NativeFuncVal(func):
                                return func(evaledArgs);
                                
                            case _:
                                return Err(new LangError(null, null, RuntimeError, '"$field" is not a function'));
                        }
                        
                    case Ok(_):
                        return Err(new LangError(null, null, RuntimeError, 'Cannot call field "$field" on a non-dict value'));
                    case other: return other;
                }
                
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
                
            case UseNode(module):
                if (!_nativeModules.exists(module))
                    return Err(new LangError(null, null, RuntimeError, 'Unknown module "$module"'));
                globalEnv.createVar(module, DictVal(_nativeModules.get(module)));
                return Ok(NullVal);
                
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
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot add $left and $right'));
                }
            case SUB:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(IntVal(a - b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(FloatVal(a - b));
                    case [IntVal(a), FloatVal(b)]: return Ok(FloatVal(a - b));
                    case [FloatVal(a), IntVal(b)]: return Ok(FloatVal(a - b));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot subtract $left and $right'));
                }
            case MUL:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(IntVal(a * b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(FloatVal(a * b));
                    case [IntVal(a), FloatVal(b)]: return Ok(FloatVal(a * b));
                    case [FloatVal(a), IntVal(b)]: return Ok(FloatVal(a * b));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot multiply $left and $right'));
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
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot divide $left and $right'));
                }
            case MOD:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(IntVal(a % b));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot mod $left and $right'));
                }
            case POW:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(FloatVal(Math.pow(a, b)));
                    case [FloatVal(a), FloatVal(b)]: return Ok(FloatVal(Math.pow(a, b)));
                    case [IntVal(a), FloatVal(b)]: return Ok(FloatVal(Math.pow(a, b)));
                    case [FloatVal(a), IntVal(b)]: return Ok(FloatVal(Math.pow(a, b)));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot pow $left and $right'));
                }
            case EQ_EQUAL:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(BoolVal(a == b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(BoolVal(a == b));
                    case [StringVal(a), StringVal(b)]: return Ok(BoolVal(a == b));
                    case [BoolVal(a), BoolVal(b)]: return Ok(BoolVal(a == b));
                    case [NullVal, NullVal]: return Ok(BoolVal(true));
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
                    case _: return Ok(BoolVal(true));
                }
            case GT:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(BoolVal(a > b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(BoolVal(a > b));
                    case [IntVal(a), FloatVal(b)]: return Ok(BoolVal(a > b));
                    case [FloatVal(a), IntVal(b)]: return Ok(BoolVal(a > b));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot compare $left and $right'));
                }
            case GT_OR_EQUAL:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(BoolVal(a >= b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(BoolVal(a >= b));
                    case [IntVal(a), FloatVal(b)]: return Ok(BoolVal(a >= b));
                    case [FloatVal(a), IntVal(b)]: return Ok(BoolVal(a >= b));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot compare $left and $right'));
                }
            case LW:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(BoolVal(a < b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(BoolVal(a < b));
                    case [IntVal(a), FloatVal(b)]: return Ok(BoolVal(a < b));
                    case [FloatVal(a), IntVal(b)]: return Ok(BoolVal(a < b));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot compare $left and $right'));
                }
            case LW_OR_EQUAL:
                switch ([left, right])
                {
                    case [IntVal(a), IntVal(b)]: return Ok(BoolVal(a <= b));
                    case [FloatVal(a), FloatVal(b)]: return Ok(BoolVal(a <= b));
                    case [IntVal(a), FloatVal(b)]: return Ok(BoolVal(a <= b));
                    case [FloatVal(a), IntVal(b)]: return Ok(BoolVal(a <= b));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot compare $left and $right'));
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
                    case IntVal(v): return Ok(IntVal(-v));
                    case FloatVal(v): return Ok(FloatVal(-v));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot negate $value'));
                }
            case KEYWORD if (op.value == "not"):
                switch (value)
                {
                    case BoolVal(v): return Ok(BoolVal(!v));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot apply "not" to $value'));
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
