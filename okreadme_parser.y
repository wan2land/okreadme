%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "okreadme_type.h"

    extern FILE *yyin;

    int yylex();
    void yyerror(const char *s);

    typedef char* string;

    char* root;

    char* string_concat(char *self, char *appender);
%}
%union {
    struct okmd_val* value;
    struct okmd_val_list* vallist;
    int ival;
    char* string;
}

%type <string> function_name
%type <vallist> function_param opt_param_list param_list
%type <value> param

%token T_NEWLINE T_FUNC_OPEN_BRACKET T_FUNC_CLOSE_BRACKET T_COMMA
%token <string> T_TEXT T_FUNC T_IDENT T_STRING
%token <ival> T_NUMBER

%%

okreadme: line
    | okreadme line
    ;

line: T_NEWLINE {
        root = string_concat(root, "\n");
    }
    | T_TEXT T_NEWLINE {
        root = string_concat(root, $1);
        root = string_concat(root, "\n");
    }
    | function_call T_NEWLINE
    ;

function_call: function_name function_param {
        printf("  [Y]%s\n", $1);
        int i;
        for (i = 0; i < $2->count; i++) {
            
            printf("    -> %s\n");
        }
        // appendNext($1, $2);
        // appendNext($2, $3);
        // $$ = buildTree(FUNC_HEAD, $1);
    }
    ;

function_name: T_FUNC {
        $$ = $1;
    }
    ;

function_param: T_FUNC_OPEN_BRACKET opt_param_list T_FUNC_CLOSE_BRACKET {
        $$ = $2;
    }
    ;

opt_param_list: param_list {
        $$ = $1;
    }
    | {
        $$ = okmd_val_list_create();
    }
    ;

param_list: param {
        $$ = okmd_val_list_create();
        okmd_val_list_push($$, $1);
    }
    | param_list T_COMMA param {
        okmd_val_list_push($1, $3);
        $$ = $1;
    }
    ;

param: T_STRING {
        $$ = okmd_val_create_string($1);
    }
    | T_NUMBER {
        $$ = okmd_val_create_int($1);
    }
    ;

%%

char* string_concat(char *self, char *appender)
{
    int self_size = strlen(self);
    int appender_size = strlen(appender);
    int i;
    self = (char *) realloc(self, (self_size + appender_size + 1) * sizeof(char));
    if (!self) {
        printf("fuck?!\n");
        exit(1);
    }
    strcat(self, appender);
    return self;
}

char* okreadme_parse_file(FILE *fp, bool isDebug) {
    yyin = fp;
    root = (char *)malloc(1);
    *root = '\0';
    do {
        yyparse();
    } while(!feof(yyin));
    return root;
}
