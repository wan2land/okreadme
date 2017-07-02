%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include "okreadme_type.h"

    extern FILE *yyin;

    int yylex();
    void yyerror(const char *s);

    typedef char* string;

    enum okmd_error okmd_error_type = 0;
    char okmd_error_message[100];


    char* output;

    // output to output
    void _output_write(char *appender);

    // function call
    void _call_code(char* file, char* type);
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
        _output_write("\n");
    }
    | T_TEXT T_NEWLINE {
        _output_write($1);
        _output_write("\n");
    }
    | function_call T_NEWLINE
    ;

function_call: function_name function_param {
        if (strcmp($1, "code") == 0) {
            if ($2->count > 0) {
                struct okmd_val *param1 = $2->first;
                struct okmd_val *param2 = param1->next;
                if (param1->type != t_string) {
                    okmd_error_type = ERROR_INVALID_PARAMS;
                    sprintf(okmd_error_message, "parameters 1 passed to @%s() must be be of the type string.\n", $1);
                    // "called in blabla.md on line 30" will added
                } else if (param2 != NULL && param2->type != t_string) {
                    okmd_error_type = ERROR_INVALID_PARAMS;
                    sprintf(okmd_error_message, "parameters 2 passed to @%s() must be be of the type string or null.\n", $1);
                    // "called in blabla.md on line 30" will added
                } else {
                    _call_code(param1->value.sval, param2 ? param2->value.sval : NULL);
                }
            } else {
                okmd_error_type = ERROR_MORE_PARAMS;
                sprintf(okmd_error_message, "@%s() expects at least 1 parameters, %d given.\n", $1, $2->count);
                // "in blabla.md on line 30" will added
            }
        } else {
            okmd_error_type = ERROR_UNDEFINED_FUNCTION;
            sprintf(okmd_error_message, "call to undefined function @%s().\n", $1);
            // "in blabla.md on line 30" will added
        }
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

void _call_code(char* file, char* type) {
    char *filename, *sub;
    int issub = 0;
    
    filename = strdup(file);

    sub = strchr(file, ':');
    if (sub) {
        issub = 1;
        filename[sub - file] = '\0';
    }
    if (issub == 0) {
        sub = strchr(file, '@');
        if (sub) {
            issub = 2;
            filename[sub - file] = '\0';
        }
    }
    FILE* fp = fopen(filename, "r");
    if (!fp) {
        okmd_error_type = ERROR_FILE_NOT_FOUND;
        sprintf(okmd_error_message, "no such file named \"%s\".\n", file);
        free(filename);
        return;
    }
    if (type == NULL) {
        char *ext = strchr(filename, '.');
        if (ext) {
            type = ext + 1;
        }
    }
    _output_write("```");
    if (type) _output_write(type);
    _output_write("\n");
    
    char buff[255];

    if (issub == 0) {
        while (!feof(fp)) {
            if (fgets(buff, sizeof(buff), fp)) {
                _output_write(buff);
            }
        }
        _output_write("\n");
    } else if (issub == 1) {
    } else if (issub == 2) {
    }

    _output_write("```\n");
    free(filename);
    fclose(fp);
}
void _output_write(char *appender)
{
    int self_size = strlen(output);
    int appender_size = strlen(appender);
    int i;
    output = (char *) realloc(output, (self_size + appender_size + 1) * sizeof(char));
    if (!output) {
        printf("fuck?!\n");
        exit(1);
    }
    strcat(output, appender);
}

char* okmd_scan_file(FILE *fp, bool isDebug) {
    yyin = fp;
    output = (char *)malloc(1);
    *output = '\0';
    do {
        yyparse();
    } while(!feof(yyin));
    if (okmd_error_type != ERROR_NONE) {
        return NULL;
    }
    return output;
}

int okmd_last_error() {
    return okmd_error_type;
}
char* okmd_last_error_message() {
    return okmd_error_message;
}