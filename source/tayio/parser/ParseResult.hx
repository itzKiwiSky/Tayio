package tayio.parser;

import tayio.lexer.LangError;

enum ParseResult
{
    Ok(node:Node);
    Err(error:LangError);
}
