package taiyo.parser;

import taiyo.lexer.Token;

typedef UsesDecl =
{
    module:String,
    imports:Null<Array<String>>
}

enum Node
{
    // literais
    IntNode(value:Int);
    FloatNode(value:Float);
    StringNode(value:String);
    BoolNode(value:Bool);
    NullNode;
    
    // operações
    BinOpNode(left:Node, op:Token, right:Node);
    UnaryOpNode(op:Token, node:Node);
    
    // variáveis
    VarAccessNode(name:String);
    VarDeclNode(scope:String, name:String, value:Node); // scope = "local" | "global"
    AssignNode(name:String, value:Node);
    
    // coleções
    ArrayNode(elements:Array<Node>);
    DictNode(entries:Array<{key:String, value:Node}>);
    
    // controle de fluxo
    IfNode(condition:Node, body:Array<Node>, elseIfs:Array<{cond:Node, body:Array<Node>}>, elseBody:Null<Array<Node>>);
    WhileNode(condition:Node, body:Array<Node>);
    ForRangeNode(varName:String, from:Node, to:Node, body:Array<Node>);
    ForInNode(varName:String, iterable:Node, body:Array<Node>);
    
    // funções
    FuncDeclNode(name:String, params:Array<String>, uses:Null<UsesDecl>, body:Array<Node>);
    FuncExprNode(params:Array<String>, uses:Null<UsesDecl>, body:Array<Node>);
    CallNode(name:String, args:Array<Node>);
    ReturnNode(value:Null<Node>);
    
    // acesso de campo
    FieldAccessNode(target:Node, field:String);
    
    BlockNode(statements:Array<Node>);
    
    ModuleNode(name:String);
    ExportNode(node:Node); // node = FuncDeclNode ou VarDeclNode
    
    UseNode(module:String);
    
    FieldCallNode(target:Node, field:String, args:Array<Node>);
    
    BreakNode;
    ContinueNode;
}
