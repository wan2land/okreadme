%{
#include <string.h>
#include <stdio.h>
#include "okreadme_parser.tab.h"

%}

%x ST_IN_SCRIPTING
%x ST_CODE_BLOCK

%%

<INITIAL>[\n] {
    return T_NEWLINE;
}
<INITIAL>([^@\n`][^\n]*) {
    yylval.string = strdup(yytext);
    return T_TEXT;
}
<INITIAL>```[^\n]* {
    yylval.string = strdup(yytext);
    BEGIN(ST_CODE_BLOCK);
    return T_TEXT;
}
<ST_CODE_BLOCK>(`[^\n`]*)|(``[^\n`]*)|([^\n`]*) {
    yylval.string = strdup(yytext);
    return T_TEXT;
}
<ST_CODE_BLOCK>[\n] {
    return T_NEWLINE;
}
<ST_CODE_BLOCK>"```" {
    yylval.string = strdup(yytext);
    BEGIN(INITIAL);
    return T_TEXT;
}

<INITIAL>@ {
    BEGIN(ST_IN_SCRIPTING);
    return T_ATSIGN;
}
<ST_IN_SCRIPTING>@([^\n]*) {
    BEGIN(INITIAL);
    yylval.string = strdup(yytext);
    return T_TEXT;
}

<ST_IN_SCRIPTING>[A-Za-z_][A-Za-z0-9_]*  {
    yylval.string = strdup(yytext);
    return T_FUNC;
}
<ST_IN_SCRIPTING>"(" {
    return T_FUNC_OPEN_BRACKET;
}
<ST_IN_SCRIPTING>")" {
    BEGIN(INITIAL);
    return T_FUNC_CLOSE_BRACKET;
}
<ST_IN_SCRIPTING>(\"(\\.|[^\\"])*\")|(\'(\\.|[^\\'])*\') {
    yylval.string = strdup(yytext) + 1;
    yylval.string[yyleng - 2] = '\0';    
    return T_STRING;
}
<ST_IN_SCRIPTING>[1-9][0-9]*|0 {
    // printf("[L]<ST_IN_SCRIPTING>T_NUMBER(%s)\n", yytext);
    yylval.ival = atoi(yytext);
    return T_NUMBER;
}
<ST_IN_SCRIPTING>"," {
    return T_COMMA;
}
. {
    // printf("[L](%c)\n", yytext[0]);
    return yytext[0];
}

%%
