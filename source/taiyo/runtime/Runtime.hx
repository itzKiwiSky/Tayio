package taiyo.runtime;

import haxe.Json;
import taiyo.runtime.INativePackage.INativeModule;
import taiyo.runtime.packages.std.Stdlib.StdLib;
import taiyo.parser.Parser;
import taiyo.lexer.Lexer;
import taiyo.lexer.Token;
import taiyo.parser.Node;
import taiyo.parser.Node.UsesDecl;
import taiyo.lexer.LangError;
import taiyo.runtime.Value;

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
    public var currentFile:String = "";
    
    var globalEnv:Environment;
    var _nativeModules:Map<String, Map<String, Value>>;
    
    public function new()
    {
        this.currentFile = "";
        this.globalEnv = new Environment();
        this._nativeModules = new Map<String, Map<String, Value>>();
    }
    
    public inline function addNativeModule(mod:INativeModule):Void
        _nativeModules.set(mod.modname, mod.getModule());
        
    public inline function get(name:String):Null<Value>
        return globalEnv.getVar(name);
        
    public function getInt(name:String):Null<Int>
    {
        return switch (globalEnv.getVar(name))
        {
            case IntVal(v): v;
            case _: null;
        }
    }
    
    public function getFloat(name:String):Null<Float>
    {
        return switch (globalEnv.getVar(name))
        {
            case FloatVal(v): v;
            case _: null;
        }
    }
    
    public function getBool(name:String):Null<Bool>
    {
        return switch (globalEnv.getVar(name))
        {
            case BoolVal(v): v;
            case _: null;
        }
    }
    
    public function getString(name:String):Null<String>
    {
        return switch (globalEnv.getVar(name))
        {
            case StringVal(v): v;
            case _: null;
        }
    }
    
    function resolveModulePath(module:String):Null<String>
    {
        var baseDir = haxe.io.Path.directory(currentFile);
        var relative = module.split(".").join("/");
        
        var extensions:Array<String> = [".tyo", ".sun"];
        
        for (ext in extensions)
        {
            // arquivo direto
            var filePath = haxe.io.Path.join([baseDir, relative + ext]);
            
            if (sys.FileSystem.exists(filePath) && !sys.FileSystem.isDirectory(filePath))
                return filePath;
                
            // index dentro da pasta
            var indexPath = haxe.io.Path.join([baseDir, relative, "index" + ext]);
            
            if (sys.FileSystem.exists(indexPath) && !sys.FileSystem.isDirectory(indexPath))
                return indexPath;
        }
        
        return null;
    }
    
    public function set(name:String, value:Value):Void
    {
        if (globalEnv.getVar(name) != null)
            globalEnv.assign(name, value);
        else
            globalEnv.createVar(name, value);
    }
    
    // sugars
    public inline function setInt(name:String, v:Int):Void
        set(name, IntVal(v));
        
    public inline function setFloat(name:String, v:Float):Void
        set(name, FloatVal(v));
        
    public inline function setString(name:String, v:String):Void
        set(name, StringVal(v));
        
    public inline function setBool(name:String, v:Bool):Void
        set(name, BoolVal(v));
        
    public inline function register(name:String, func:Array<Value>->RuntimeResult):Void
        globalEnv.createVar(name, NativeFuncVal(func));
        
    public function call(name:String, args:Array<Value>):RuntimeResult
    {
        var funcDec = globalEnv.getVar(name);
        if (funcDec == null)
            return Err(new LangError(null, null, RuntimeError, 'Function "$name" is not defined'));
            
        switch (funcDec)
        {
            case FuncVal(params, uses, body, funcEnv):
                return callFunc(params, uses, body, funcEnv, args);
            case NativeFuncVal(func):
                return func(args);
            case _:
                return Err(new LangError(null, null, RuntimeError, '"$name" is not a function'));
        }
    }
    
    function resolveNativeModule(moduleName:String):Null<Map<String, Value>>
    {
        // direct access
        if (_nativeModules.exists(moduleName))
            return _nativeModules.get(moduleName);
            
        var parts = moduleName.split(".");
        
        // find the longest prefix as key
        for (i in 1...parts.length)
        {
            var prefix = parts.slice(0, i).join(".");
            if (!_nativeModules.exists(prefix))
                continue;
                
            // navigate on da segments
            var current:Map<String, Value> = _nativeModules.get(prefix);
            var remaining = parts.slice(i);
            var found = true;
            
            for (segment in remaining)
            {
                var v = current.get(segment);
                if (v == null)
                {
                    found = false;
                    break;
                }
                switch (v)
                {
                    case DictVal(d):
                        current = d;
                    case _:
                        found = false;
                        break;
                }
            }
            
            if (found)
                return current;
        }
        
        return null;
    }
    
    // inject on callenv
    function injectUses(uses:UsesDecl, callEnv:Environment):Void
    {
        var moduleDict = resolveNativeModule(uses.module);
        if (moduleDict == null)
            return;
            
        if (uses.imports != null)
        {
            for (importName in uses.imports)
            {
                var v = moduleDict.get(importName);
                if (v != null)
                    switch (v)
                    {
                        case DictVal(d):
                            for (k => fv in d)
                                callEnv.createVar(k, fv);
                        case _:
                            callEnv.createVar(importName, v);
                    }
            }
        }
        else
        {
            for (k => v in moduleDict)
                callEnv.createVar(k, v);
        }
    }
    
    // executa uma FuncVal com args já avaliados
    function callFunc(params:Array<String>, uses:Null<UsesDecl>, body:Array<Node>, funcEnv:Environment, evaledArgs:Array<Value>):RuntimeResult
    {
        var callEnv = new Environment(funcEnv);
        if (uses != null)
            injectUses(uses, callEnv);
        for (i in 0...params.length)
            callEnv.createVar(params[i], evaledArgs[i]);
        for (stmt in body)
        {
            switch (evaluate(stmt, callEnv))
            {
                case Ok(_):
                case Signal(SReturn(v)):
                    return Ok(v);
                case other:
                    return other;
            }
        }
        return Ok(NullVal);
    }
    
    public function init()
    {
        globalEnv = new Environment();
        _nativeModules = [];
        addNativeModule(new StdLib());
    }
    
    public inline function dumpNativeModules():Void
        for (k => v in _nativeModules)
        {
            Sys.print('[$k]');
            Sys.print(NativeUtils.dumpDict(v));
        }
        
    public function run(ast:Node):RuntimeResult
    {
        globalEnv = new Environment();
        _nativeModules = [];
        addNativeModule(new StdLib());
        
        switch (evaluate(ast, globalEnv))
        {
            case Err(e):
                return Err(e);
            case _:
        }
        
        // main é opcional — se existir chama, senão retorna Ok
        var mainFunc = globalEnv.getVar("main");
        if (mainFunc == null)
            return Ok(NullVal);
            
        switch (mainFunc)
        {
            case FuncVal(params, uses, body, funcEnv):
                return callFunc(params, uses, body, funcEnv, []);
            case _:
                return Err(new LangError(null, null, RuntimeError, '"main" must be a function'));
        }
    }
    
    function evaluate(node:Node, env:Environment):RuntimeResult
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
                
            case IntNode(v):
                return Ok(IntVal(v));
            case FloatNode(v):
                return Ok(FloatVal(v));
            case StringNode(v):
                return Ok(StringVal(v));
            case BoolNode(v):
                return Ok(BoolVal(v));
            case NullNode:
                return Ok(NullVal);
                
            case BinOpNode(left, op, right):
                var lv:Value = NullVal;
                var rv:Value = NullVal;
                switch (evaluate(left, env))
                {
                    case Ok(v): lv = v;
                    case other: return other;
                }
                switch (evaluate(right, env))
                {
                    case Ok(v): rv = v;
                    case other: return other;
                }
                return applyBinOp(lv, op, rv);
                
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
                                case Ok(cv): if (isTruthy(cv)) return executeBlock(ei.body, new Environment(env));
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
                            case Ok(_): return Err(new LangError(null, null, RuntimeError, 'For range expects integers'));
                            case other: return other;
                        }
                    case Ok(_): return Err(new LangError(null, null, RuntimeError, 'For range expects integers'));
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
                    case Ok(_): return Err(new LangError(null, null, RuntimeError, 'Expected array in for in'));
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
                    case Ok(_): return Err(new LangError(null, null, RuntimeError, 'Cannot access field "$field" on a non-dict value'));
                    case other: return other;
                }
                
            case FuncDeclNode(name, params, uses, body):
                env.createVar(name, FuncVal(params, uses, body, env));
                return Ok(NullVal);
                
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
                    case FuncVal(params, uses, body, funcEnv): return callFunc(params, uses, body, funcEnv, evaledArgs);
                    case NativeFuncVal(func): return func(evaledArgs);
                    case _: return Err(new LangError(null, null, RuntimeError, '"$name" is not a function'));
                }
                
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
                            case FuncVal(params, uses, body, funcEnv): return callFunc(params, uses, body, funcEnv, evaledArgs);
                            case NativeFuncVal(func): return func(evaledArgs);
                            case _: return Err(new LangError(null, null, RuntimeError, '"$field" is not a function'));
                        }
                        
                    case Ok(_): return Err(new LangError(null, null, RuntimeError, 'Cannot call field "$field" on a non-dict value'));
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
                var resolved = resolveNativeModule(module);
                if (resolved != null)
                {
                    var alias = module.split(".").pop();
                    env.createVar(alias, DictVal(resolved));
                    return Ok(NullVal);
                }
                
                // script
                var path = resolveModulePath(module);
                if (path == null)
                    return Err(new LangError(null, null, RuntimeError, 'Module "$module" not found'));
                    
                var source = sys.io.File.getContent(path);
                var tokens = switch (Lexer.lex(source))
                {
                    case Ok(t): t;
                    case Err(e): return Err(e);
                }
                var ast = switch (Parser.parse(tokens))
                {
                    case Ok(n): n;
                    case Err(e): return Err(e);
                }
                
                var moduleEnv = new Environment();
                switch (evaluate(ast, moduleEnv))
                {
                    case Err(e): return Err(e);
                    case _:
                }
                
                var moduleDict:Map<String, Value> = [];
                for (name in moduleEnv.exports)
                {
                    var v = moduleEnv.getVar(name);
                    if (v != null)
                        moduleDict.set(name, v);
                }
                env.createVar(module.split(".").pop(), DictVal(moduleDict));
                return Ok(NullVal);
                
            case _:
                return Err(new LangError(null, null, RuntimeError, 'Unknown node: $node'));
        }
    }
    
    function applyBinOp(left:Value, op:Token, right:Value):RuntimeResult
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
            case KEYWORD if (op.value == "and"):
                switch ([left, right])
                {
                    case [BoolVal(a), BoolVal(b)]: return Ok(BoolVal(a && b));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot apply "and" to $left and $right'));
                }
            case KEYWORD if (op.value == "or"):
                switch ([left, right])
                {
                    case [BoolVal(a), BoolVal(b)]: return Ok(BoolVal(a || b));
                    case _: return Err(new LangError(null, null, RuntimeError, 'Cannot apply "or" to $left and $right'));
                }
            case _:
                return Err(new LangError(null, null, RuntimeError, 'Unknown operator ${op.type}'));
        }
        return Ok(NullVal);
    }
    
    function applyUnary(op:Token, value:Value):RuntimeResult
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
    
    function isTruthy(value:Value):Bool
        return switch (value)
        {
            case BoolVal(v): v;
            case _: false;
        }
        
    function executeBlock(body:Array<Node>, env:Environment):RuntimeResult
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
