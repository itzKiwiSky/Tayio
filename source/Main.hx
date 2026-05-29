import haxe.Json;
import pine.lexer.Lexer;

class Main
{
    static function main()
    {
        switch (Lexer.lex("= == > >= < <="))
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
