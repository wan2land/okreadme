%x ST_IN_SCRIPTING

%{
#include <stdio.h>
#include "okreadme_parser.tab.h"

char* toString(char* string)
{
    char* str;
    str = (char*)malloc(strlen(string) + 1);
    strcpy(str, string);
    str[strlen(string)] = '\0';
    return str;
}

%}

%%

[\n] {
    return T_NEWLINE;
}
<INITIAL>[^@\n][^\n]* {
    yylval.string = toString(yytext);
    return (T_TEXT);
}
<INITIAL>@[A-Za-z_][A-Za-z0-9_]*  {
    // printf("[L]<ST_IN_SCRIPTING>T_FUNC(%s)\n", yytext);
    yylval.string = toString(yytext);
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
<ST_IN_SCRIPTING>\"(\\.|[^\\"])*\" {
    // printf("[L]<ST_IN_SCRIPTING>string(%s)\n", yytext);
    yylval.string = toString(yytext);
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
