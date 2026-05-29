import haxe.Json;
import pine.lexer.Lexer;

class Main
{
    static function main()
    {
        var code:String = "func main() uses pineStd do end";
        
        switch (Lexer.lex(code))
        {
            case Ok(tokens):
                trace("tokens gerados com sucesso!");
                Sys.print("[\n");
                for (tk in tokens)
                    Sys.print("    " + tk + "\n");
                Sys.print("[\n");
                
            case Err(error):
                Sys.println(error.asString());
        }
    }
}
