%x ST_IN_SCRIPTING

%{
#include <string.h>
#include <stdio.h>
#include "okreadme_parser.tab.h"

%}

%%

[\n] {
    return T_NEWLINE;
}
<INITIAL>[^@\n][^\n]* {
    yylval.string = strdup(yytext);
    return (T_TEXT);
}
<INITIAL>@[A-Za-z_][A-Za-z0-9_]*  {
    // printf("[L]<ST_IN_SCRIPTING>T_FUNC(%s)\n", yytext);
    yylval.string = strdup(yytext) + 1;
    BEGIN(ST_IN_SCRIPTING);
    return (T_FUNC);
}
<ST_IN_SCRIPTING>"(" {
    return (T_FUNC_OPEN_BRACKET);
}
<ST_IN_SCRIPTING>")" {
    BEGIN(INITIAL);
    return (T_FUNC_CLOSE_BRACKET);
}
<ST_IN_SCRIPTING>(\"(\\.|[^\\"])*\")|(\'(\\.|[^\\'])*\') {
    // printf("[L]<ST_IN_SCRIPTING>string(%s)\n", yytext);
    yylval.string = strdup(yytext) + 1;
    yylval.string[yyleng - 2] = '\0';
    
    return (T_STRING);
}
<ST_IN_SCRIPTING>[1-9][0-9]*|0 {
    // printf("[L]<ST_IN_SCRIPTING>T_NUMBER(%s)\n", yytext);
    yylval.ival = atoi(yytext);
    return (T_NUMBER);
}
<ST_IN_SCRIPTING>"," {
    return (T_COMMA);
}
. {
    // printf("[L](%c)\n", yytext[0]);
    return (yytext[0]);
}

%%
