import pine.Lexer;

class Main
{
    static function main()
    {
        var t = Lexer.lex("data");
        trace(t);
    }
}
