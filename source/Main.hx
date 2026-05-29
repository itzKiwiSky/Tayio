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
                trace("\n" + Json.stringify(tokens, "    "));
                
            case Err(error):
                Sys.println(error.asString());
        }
    }
}
