import pine.parser.Parser;
import haxe.Json;
import pine.lexer.Lexer;

class Main
{
    static function main()
    {
        var code:String = "func main() uses pine.std do end";
        
        switch (Lexer.lex(code))
        {
            case Ok(tokens):
                trace("tokens gerados com sucesso!");
                Sys.print("[\n");
                for (tk in tokens)
                    Sys.print("    " + tk + "\n");
                Sys.print("[\n");
                switch (Parser.parse(tokens))
                {
                    case Ok(node):
                        trace("AST gerada com sucesso!");
                        trace(node); // printa a árvore
                        
                    case Err(error):
                        Sys.println(error.asString());
                }
                
            case Err(error):
                Sys.println(error.asString());
        }
    }
}
