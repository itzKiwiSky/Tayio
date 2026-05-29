import haxe.Json;
import pine.lexer.Lexer;

class Main
{
    static function main()
    {
        var t = Lexer.lex("!=");
        trace("\n" + Json.stringify(t, "    "));
    }
}
