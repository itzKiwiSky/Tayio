package taiyo.parser;

import taiyo.lexer.LangError;

enum ParseResult
{
    Ok(node:Node);
    Err(error:LangError);
}
