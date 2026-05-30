package pine.parser;

import pine.lexer.LangError;

enum ParseResult
{
    Ok(node:Node);
    Err(error:LangError);
}
