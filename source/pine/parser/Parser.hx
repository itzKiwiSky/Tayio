package pine.parser;

import pine.parser.Node.UsesDecl;
import pine.lexer.Token;
import pine.lexer.Token.TokenType;
import pine.lexer.LangError;

class Parser
{
    static var tokens:Array<Token> = [];
    static var index:Int = 0;
    static var current:Token;
    
    // ── helpers ───────────────────────────────────────────────────────────────
    
    static function advance():Void
    {
        index++;
        current = index < tokens.length ? tokens[index] : tokens[tokens.length - 1];
    }
    
    // eat o token atual se for do tipo esperado, senão retorna erro
    static function expect(type:TokenType, ?value:String):Null<LangError>
    {
        if (current.type != type || (value != null && current.value != value))
            return new LangError(null, null, InvalidSyntax, 'Expected $type${value != null ? ' "$value"' : ""}, got ${current.type} "${current.value}"');
            
        advance();
        return null;
    }
    
    static function skipNewlines():Void
    {
        while (current.type == TokenType.NEWLINE)
            advance();
    }
    
    // ── entry point ───────────────────────────────────────────────────────────
    
    public static function parse(tkns:Array<Token>):ParseResult
    {
        tokens = tkns;
        index = 0;
        current = tokens[0];
        
        var statements:Array<Node> = [];
        
        skipNewlines();
        
        while (current.type != TokenType.EOF)
        {
            switch (parseStatement())
            {
                case Ok(node):
                    statements.push(node);
                case Err(e):
                    return Err(e);
            }
            skipNewlines();
        }
        
        return Ok(BlockNode(statements));
    }
    
    // ── statements ────────────────────────────────────────────────────────────
    
    static function parseStatement():ParseResult
    {
        // local / global
        if (current.type == TokenType.KEYWORD && (current.value == "local" || current.value == "global"))
            return parseVarDecl();
            
        // func
        if (current.type == TokenType.KEYWORD && current.value == "func")
            return parseFuncDecl();
            
        // if
        if (current.type == TokenType.KEYWORD && current.value == "if")
            return parseIf();
            
        // while
        if (current.type == TokenType.KEYWORD && current.value == "while")
            return parseWhile();
            
        // for
        if (current.type == TokenType.KEYWORD && current.value == "for")
            return parseFor();
            
        // return
        if (current.type == TokenType.KEYWORD && current.value == "return")
            return parseReturn();
            
        if (current.type == TokenType.KEYWORD && current.value == "break")
        {
            advance();
            return Ok(BreakNode);
        }
        
        if (current.type == TokenType.KEYWORD && current.value == "continue")
        {
            advance();
            return Ok(ContinueNode);
        }
        
        // module terminal
        if (current.type == TokenType.KEYWORD && current.value == "module")
        {
            advance();
            if (current.type != TokenType.IDENTIFIER)
                return Err(new LangError(null, null, InvalidSyntax, 'Expected module name'));
            var name = current.value;
            advance();
            return Ok(ModuleNode(name));
        }
        
        // export func ... ou export local ...
        if (current.type == TokenType.KEYWORD && current.value == "export")
        {
            advance();
            switch (parseStatement())
            {
                case Ok(node):
                    return Ok(ExportNode(node));
                case other:
                    return other;
            }
        }
        
        if (current.type == TokenType.KEYWORD && current.value == "use")
        {
            advance(); // consome "use"
            if (current.type != TokenType.IDENTIFIER)
                return Err(new LangError(null, null, InvalidSyntax, 'Expected module name after "use"'));
                
            var name = current.value;
            advance();
            
            // acumula segmentos: std.io
            while (current.type == TokenType.DOT)
            {
                advance(); // consome "."
                if (current.type != TokenType.IDENTIFIER)
                    return Err(new LangError(null, null, InvalidSyntax, 'Expected identifier after "." in module name'));
                name += "." + current.value;
                advance();
            }
            
            return Ok(UseNode(name));
        }
        
        // expressão (assignment ou call)
        return parseExpression();
    }
    
    // ── var decl ─────────────────────────────────────────────────────────────
    // local x = 10
    
    static function parseVarDecl():ParseResult
    {
        var scope = current.value; // "local" ou "global"
        advance(); // eat local/global
        
        if (current.type != TokenType.IDENTIFIER)
            return Err(new LangError(null, null, InvalidSyntax, 'Expected identifier after "$scope"'));
            
        var name = current.value;
        advance(); // eat o nome
        
        var err = expect(TokenType.ASSIGN);
        if (err != null)
            return Err(err);
            
        switch (parseExpression())
        {
            case Ok(value):
                return Ok(VarDeclNode(scope, name, value));
            case Err(e):
                return Err(e);
        }
    }
    
    // ── func decl ─────────────────────────────────────────────────────────────
    // func add(a, b) do ... end
    // func draw() uses Gfx do ... end
    
    static function parseFuncDecl():ParseResult
    {
        advance(); // eat "func"
        
        if (current.type != TokenType.IDENTIFIER)
            return Err(new LangError(null, null, InvalidSyntax, 'Expected function name'));
            
        var name = current.value;
        advance(); // eat nome
        
        var err = expect(TokenType.LEFT_PAREN);
        if (err != null)
            return Err(err);
            
        // params
        var params:Array<String> = [];
        while (current.type != TokenType.RIGHT_PAREN)
        {
            if (current.type != TokenType.IDENTIFIER)
                return Err(new LangError(null, null, InvalidSyntax, 'Expected parameter name'));
                
            params.push(current.value);
            advance();
            
            if (current.type == TokenType.COMMA)
                advance();
        }
        
        err = expect(TokenType.RIGHT_PAREN);
        if (err != null)
            return Err(err);
            
        // uses (opcional)
        var uses:Null<UsesDecl> = null;
        if (current.type == TokenType.KEYWORD && current.value == "uses")
        {
            advance(); // eat "uses"
            if (current.type != TokenType.IDENTIFIER)
                return Err(new LangError(null, null, InvalidSyntax, 'Expected package name after "uses"'));
                
            var usesName = current.value;
            advance();
            
            // acumula segmentos: pine.std.io
            while (current.type == TokenType.DOT)
            {
                advance(); // eat "."
                if (current.type != TokenType.IDENTIFIER)
                    return Err(new LangError(null, null, InvalidSyntax, 'Expected identifier after "." in package name'));
                usesName += "." + current.value;
                advance();
            }
            
            var imports:Null<Array<String>> = null;
            if (current.type == TokenType.LEFT_SQUARE)
            {
                advance(); // eat [
                imports = [];
                
                while (current.type != TokenType.RIGHT_SQUARE)
                {
                    if (current.type != TokenType.IDENTIFIER)
                        return return Err(new LangError(null, null, InvalidSyntax, 'Expected import name'));
                    imports.push(current.value);
                    
                    advance();
                    
                    if (current.type == TokenType.COMMA)
                        advance();
                }
                
                var err = expect(TokenType.RIGHT_SQUARE);
                if (err != null)
                    return Err(err);
            }
            
            uses = {
                module: usesName,
                imports: imports
            };
        }
        
        err = expect(TokenType.KEYWORD, "do");
        if (err != null)
            return Err(err);
            
        // body
        switch (parseBlock())
        {
            case Ok(BlockNode(body)):
                var err = expect(TokenType.KEYWORD, "end");
                if (err != null)
                    return Err(err);
                return Ok(FuncDeclNode(name, params, uses, body));
            case Err(e):
                return Err(e);
            case _:
                return Err(new LangError(null, null, InvalidSyntax, 'Expected block'));
        }
    }
    
    // ── if ────────────────────────────────────────────────────────────────────
    // if (cond) do ... elseif (cond) do ... else do ... end
    
    static function parseIf():ParseResult
    {
        advance(); // eat "if"
        
        var err = expect(TokenType.LEFT_PAREN);
        if (err != null)
            return Err(err);
            
        var cond:Node;
        switch (parseExpression())
        {
            case Ok(n):
                cond = n;
            case Err(e):
                return Err(e);
        }
        
        err = expect(TokenType.RIGHT_PAREN);
        if (err != null)
            return Err(err);
            
        err = expect(TokenType.KEYWORD, "do");
        if (err != null)
            return Err(err);
            
        var body:Array<Node>;
        switch (parseBlock(["elseif", "else", "end"]))
        {
            case Ok(BlockNode(b)):
                body = b;
            case Err(e):
                return Err(e);
            case _:
                return Err(new LangError(null, null, InvalidSyntax, ''));
        }
        
        // elseifs
        var elseIfs:Array<{cond:Node, body:Array<Node>}> = [];
        while (current.type == TokenType.KEYWORD && current.value == "elseif")
        {
            advance(); // eat "elseif"
            
            err = expect(TokenType.LEFT_PAREN);
            if (err != null)
                return Err(err);
                
            var eic:Node;
            switch (parseExpression())
            {
                case Ok(n):
                    eic = n;
                case Err(e):
                    return Err(e);
            }
            
            err = expect(TokenType.RIGHT_PAREN);
            if (err != null)
                return Err(err);
                
            err = expect(TokenType.KEYWORD, "do");
            if (err != null)
                return Err(err);
                
            switch (parseBlock(["elseif", "else", "end"]))
            {
                case Ok(BlockNode(eib)):
                    elseIfs.push({cond: eic, body: eib});
                case Err(e):
                    return Err(e);
                case _:
                    return Err(new LangError(null, null, InvalidSyntax, ''));
            }
        }
        
        // else
        var elseBody:Null<Array<Node>> = null;
        if (current.type == TokenType.KEYWORD && current.value == "else")
        {
            advance(); // eat "else"
            
            err = expect(TokenType.KEYWORD, "do");
            if (err != null)
                return Err(err);
                
            switch (parseBlock())
            {
                case Ok(BlockNode(eb)):
                    elseBody = eb;
                case Err(e):
                    return Err(e);
                case _:
                    return Err(new LangError(null, null, InvalidSyntax, ''));
            }
        }
        
        err = expect(TokenType.KEYWORD, "end");
        if (err != null)
            return Err(err);
            
        return Ok(IfNode(cond, body, elseIfs, elseBody));
    }
    
    // ── while ─────────────────────────────────────────────────────────────────
    
    static function parseWhile():ParseResult
    {
        advance(); // eat "while"
        
        var err = expect(TokenType.LEFT_PAREN);
        if (err != null)
            return Err(err);
            
        var cond:Node;
        switch (parseExpression())
        {
            case Ok(n):
                cond = n;
            case Err(e):
                return Err(e);
        }
        
        err = expect(TokenType.RIGHT_PAREN);
        if (err != null)
            return Err(err);
            
        err = expect(TokenType.KEYWORD, "do");
        if (err != null)
            return Err(err);
            
        switch (parseBlock())
        {
            case Ok(BlockNode(body)):
                var err = expect(TokenType.KEYWORD, "end");
                if (err != null)
                    return Err(err);
                return Ok(WhileNode(cond, body));
            case Err(e):
                return Err(e);
            case _:
                return Err(new LangError(null, null, InvalidSyntax, ''));
        }
    }
    
    // ── for ───────────────────────────────────────────────────────────────────
    // for (i in 0...10) do ... end
    // for (item in myArray) do ... end
    
    static function parseFor():ParseResult
    {
        advance(); // eat "for"
        
        var err = expect(TokenType.LEFT_PAREN);
        if (err != null)
            return Err(err);
            
        if (current.type != TokenType.IDENTIFIER)
            return Err(new LangError(null, null, InvalidSyntax, 'Expected identifier in for'));
            
        var varName = current.value;
        advance();
        
        err = expect(TokenType.KEYWORD, "in");
        if (err != null)
            return Err(err);
            
        var from:Node;
        switch (parseExpression())
        {
            case Ok(n):
                from = n;
            case Err(e):
                return Err(e);
        }
        
        // checa se é range (0...10) ou iteração simples (item in array)
        var isRange = (current.type == TokenType.DOT3);
        var to:Null<Node> = null;
        
        if (isRange)
        {
            advance(); // eat "..."
            switch (parseExpression())
            {
                case Ok(n):
                    to = n;
                case Err(e):
                    return Err(e);
            }
        }
        
        err = expect(TokenType.RIGHT_PAREN);
        if (err != null)
            return Err(err);
            
        err = expect(TokenType.KEYWORD, "do");
        if (err != null)
            return Err(err);
            
        switch (parseBlock())
        {
            case Ok(BlockNode(body)):
                var err = expect(TokenType.KEYWORD, "end");
                if (err != null)
                    return Err(err);
                if (isRange)
                    return Ok(ForRangeNode(varName, from, to, body));
                else
                    return Ok(ForInNode(varName, from, body));
                    
            case Err(e):
                return Err(e);
            case _:
                return Err(new LangError(null, null, InvalidSyntax, ''));
        }
    }
    
    // ── return ────────────────────────────────────────────────────────────────
    
    static function parseReturn():ParseResult
    {
        advance(); // eat "return"
        
        // return sem valor
        if (current.type == TokenType.NEWLINE || current.type == TokenType.EOF)
            return Ok(ReturnNode(null));
            
        switch (parseExpression())
        {
            case Ok(n):
                return Ok(ReturnNode(n));
            case Err(e):
                return Err(e);
        }
    }
    
    // ── block ─────────────────────────────────────────────────────────────────
    // para quando achar uma das stopWords ou EOF
    
    static function parseBlock(?stopWords:Array<String>):ParseResult
    {
        var stops = stopWords ?? ["end"];
        var body:Array<Node> = [];
        
        skipNewlines();
        
        while (current.type != TokenType.EOF)
        {
            // checa se chegou numa stopWord
            if (current.type == TokenType.KEYWORD && stops.contains(current.value))
                break;
                
            switch (parseStatement())
            {
                case Ok(node):
                    body.push(node);
                case Err(e):
                    return Err(e);
            }
            skipNewlines();
        }
        
        return Ok(BlockNode(body));
    }
    
    // ── expressões ────────────────────────────────────────────────────────────
    // segue a precedência: expr → comparison → term → factor → unary → primary
    
    static function parseExpression():ParseResult
        return parseComparison();
        
    static function parseComparison():ParseResult
    {
        var left:Node;
        switch (parseAddSub())
        {
            case Ok(n):
                left = n;
            case Err(e):
                return Err(e);
        }
        
        while (true)
        {
            var op = current;
            switch (current.type)
            {
                case EQ_EQUAL | NOT_EQUAL | GT | GT_OR_EQUAL | LW | LW_OR_EQUAL:
                    advance();
                    switch (parseAddSub())
                    {
                        case Ok(right): left = BinOpNode(left, op, right);
                        case Err(e): return Err(e);
                    }
                case _:
                    break;
            }
        }
        
        return Ok(left);
    }
    
    static function parseAddSub():ParseResult
    {
        var left:Node;
        switch (parseMulDiv())
        {
            case Ok(n):
                left = n;
            case Err(e):
                return Err(e);
        }
        
        while (current.type == TokenType.ADD || current.type == TokenType.SUB)
        {
            var op = current;
            advance();
            switch (parseMulDiv())
            {
                case Ok(right):
                    left = BinOpNode(left, op, right);
                case Err(e):
                    return Err(e);
            }
        }
        
        return Ok(left);
    }
    
    static function parseMulDiv():ParseResult
    {
        var left:Node;
        switch (parseUnary())
        {
            case Ok(n):
                left = n;
            case Err(e):
                return Err(e);
        }
        
        while (current.type == TokenType.MUL || current.type == TokenType.DIV || current.type == TokenType.MOD)
        {
            var op = current;
            advance();
            switch (parseUnary())
            {
                case Ok(right):
                    left = BinOpNode(left, op, right);
                case Err(e):
                    return Err(e);
            }
        }
        
        return Ok(left);
    }
    
    static function parseUnary():ParseResult
    {
        // -x  ou  not x
        if (current.type == TokenType.SUB || (current.type == TokenType.KEYWORD && current.value == "not"))
        {
            var op = current;
            advance();
            switch (parseUnary())
            {
                case Ok(n):
                    return Ok(UnaryOpNode(op, n));
                case Err(e):
                    return Err(e);
            }
        }
        
        return parsePrimary();
    }
    
    static function parsePrimary():ParseResult
    {
        var tk = current;
        
        switch (tk.type)
        {
            case TokenType.INTEGER:
                advance();
                return Ok(IntNode(tk.value));
            case TokenType.FLOAT:
                advance();
                return Ok(FloatNode(tk.value));
                
            case TokenType.STRING:
                advance();
                return Ok(StringNode(tk.value));
                
            case TokenType.BOOLEAN:
                advance();
                return Ok(BoolNode(tk.value == "true"));
                
            case TokenType.NULL:
                advance();
                return Ok(NullNode);
                
            case TokenType.LEFT_PAREN:
                advance();
                switch (parseExpression())
                {
                    case Ok(n):
                        var err = expect(TokenType.RIGHT_PAREN);
                        if (err != null)
                            return Err(err);
                        return Ok(n);
                    case Err(e): return Err(e);
                }
                
            case TokenType.LEFT_SQUARE:
                return parseArray();
                
            case TokenType.IDENTIFIER:
                var name = tk.value;
                advance();
                
                // call: foo(...)
                if (current.type == TokenType.LEFT_PAREN)
                    return parseCall(name);
                    
                // field access: foo.bar
                
                if (current.type == TokenType.DOT)
                {
                    var fieldTarget:Node = VarAccessNode(name);
                    
                    // acumula fields encadeados: io.out.println
                    while (current.type == TokenType.DOT)
                    {
                        advance(); // consome "."
                        var field = current.value;
                        advance(); // consome o field
                        
                        if (current.type == TokenType.LEFT_PAREN)
                            return parseFieldCall(fieldTarget, field);
                            
                        fieldTarget = FieldAccessNode(fieldTarget, field);
                    }
                    
                    return Ok(fieldTarget);
                }
                
                // assignment: x = ...
                if (current.type == TokenType.ASSIGN)
                {
                    advance();
                    switch (parseExpression())
                    {
                        case Ok(val): return Ok(AssignNode(name, val));
                        case Err(e): return Err(e);
                    }
                }
                
                return Ok(VarAccessNode(name));
                
            case TokenType.LEFT_BRACE:
                return parseDict();
                
            case TokenType.KEYWORD if (current.value == "func"):
                return parseFuncExpr();
                
            case _:
                return Err(new LangError(null, null, InvalidSyntax, 'Unexpected token: ${tk.type} "${tk.value}"'));
        }
    }
    
    static function parseCall(name:String):ParseResult
    {
        advance(); // eat "("
        var args:Array<Node> = [];
        
        while (current.type != TokenType.RIGHT_PAREN)
        {
            switch (parseExpression())
            {
                case Ok(n):
                    args.push(n);
                case Err(e):
                    return Err(e);
            }
            if (current.type == TokenType.COMMA)
                advance();
        }
        
        var err = expect(TokenType.RIGHT_PAREN);
        if (err != null)
            return Err(err);
            
        return Ok(CallNode(name, args));
    }
    
    static function parseFieldAccess(target:Node):ParseResult
    {
        while (current.type == TokenType.DOT)
        {
            advance(); // eat "."
            if (current.type != TokenType.IDENTIFIER)
                return Err(new LangError(null, null, InvalidSyntax, 'Expected field name after "."'));
                
            var field = current.value;
            advance();
            target = FieldAccessNode(target, field);
        }
        return Ok(target);
    }
    
    static function parseArray():ParseResult
    {
        advance(); // eat "["
        var elements:Array<Node> = [];
        
        while (current.type != TokenType.RIGHT_SQUARE)
        {
            switch (parseExpression())
            {
                case Ok(n):
                    elements.push(n);
                case Err(e):
                    return Err(e);
            }
            if (current.type == TokenType.COMMA)
                advance();
        }
        
        var err = expect(TokenType.RIGHT_SQUARE);
        if (err != null)
            return Err(err);
            
        return Ok(ArrayNode(elements));
    }
    
    static function parseDict():ParseResult
    {
        advance(); // consome "{"
        var entries:Array<{key:String, value:Node}> = [];
        
        while (current.type != TokenType.RIGHT_BRACE)
        {
            if (current.type != TokenType.IDENTIFIER)
                return Err(new LangError(null, null, InvalidSyntax, 'Expected key name in dict'));
                
            var key = current.value;
            advance(); // consome a chave
            
            var err = expect(TokenType.ASSIGN);
            if (err != null)
                return Err(err);
                
            switch (parseExpression())
            {
                case Ok(val):
                    entries.push({key: key, value: val});
                case other:
                    return other;
            }
            
            if (current.type == TokenType.COMMA)
                advance();
        }
        
        var err = expect(TokenType.RIGHT_BRACE);
        if (err != null)
            return Err(err);
            
        return Ok(DictNode(entries));
    }
    
    static function parseFuncExpr():ParseResult
    {
        advance(); // consome "func"
        
        var err = expect(TokenType.LEFT_PAREN);
        if (err != null)
            return Err(err);
            
        var params:Array<String> = [];
        while (current.type != TokenType.RIGHT_PAREN)
        {
            if (current.type != TokenType.IDENTIFIER)
                return Err(new LangError(null, null, InvalidSyntax, 'Expected parameter name'));
                
            params.push(current.value);
            advance();
            
            if (current.type == TokenType.COMMA)
                advance();
        }
        
        err = expect(TokenType.RIGHT_PAREN);
        if (err != null)
            return Err(err);
            
        var uses:Null<UsesDecl> = null;
        if (current.type == TokenType.KEYWORD && current.value == "uses")
        {
            advance();
            if (current.type != TokenType.IDENTIFIER)
                return Err(new LangError(null, null, InvalidSyntax, 'Expected package name after "uses"'));
            uses = current.value;
            advance();
        }
        
        err = expect(TokenType.KEYWORD, "do");
        if (err != null)
            return Err(err);
            
        switch (parseBlock())
        {
            case Ok(BlockNode(body)):
                var err = expect(TokenType.KEYWORD, "end");
                if (err != null)
                    return Err(err);
                return Ok(FuncExprNode(params, uses, body));
            case Err(e):
                return Err(e);
            case _:
                return Err(new LangError(null, null, InvalidSyntax, 'Expected block'));
        }
    }
    
    static function parseFieldCall(target:Node, field:String):ParseResult
    {
        advance(); // consome "("
        var args:Array<Node> = [];
        
        while (current.type != TokenType.RIGHT_PAREN)
        {
            switch (parseExpression())
            {
                case Ok(n):
                    args.push(n);
                case other:
                    return other;
            }
            if (current.type == TokenType.COMMA)
                advance();
        }
        
        var err = expect(TokenType.RIGHT_PAREN);
        if (err != null)
            return Err(err);
            
        return Ok(FieldCallNode(target, field, args));
    }
}
