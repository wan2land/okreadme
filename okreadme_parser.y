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


    // str added
    char* strconcat(char* self, char* appender);

    // output to output
    char* output;
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
    int issub = 0, line_start = 0, line_end = -1;
    int line_num = 1;

    filename = strdup(file);

    sub = strchr(file, ':');
    if (sub) {
        issub = 1;
        filename[sub - file] = '\0';
        sub = sub + 1; // escape :
        char* pivot = sub;
        for (int i = 0; *pivot != '\0'; i++) {
            if (*pivot == '-') {
                *pivot = '\0';
                if (*(pivot + 1) != '\0') {
                    line_end = atoi(pivot + 1);
                }
                break;
            }
            pivot = pivot + 1;
        }
        line_start = atoi(sub);
        // printf("sub%d ~ %d\n", line_start, line_end);
    }
    if (issub == 0) {
        sub = strchr(file, '@');
        if (sub) {
            issub = 2;
            filename[sub - file] = '\0';
            sub = sub + 1; // escape @
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
    

    char *line = NULL;
    size_t len = 0;
    ssize_t read;

    if (issub == 2) {
        line_num = 1;
        char* section_start = strconcat(strdup("section:"), sub);
        while ((read = getline(&line, &len, fp)) != -1) {
            if (strstr(line, section_start) != NULL) {
                line_start = line_num + 1;
            }
            if (strstr(line, "endsection") != NULL) {
                line_end = line_num - 1;
            }
            line_num++;
        }
        free(section_start);
    }

    char* code = (char*)malloc(1);
    code[0] = '\0';

    rewind(fp);
    line_num = 1;
    while ((read = getline(&line, &len, fp)) != -1) {
        if (line_num >= line_start && (line_end == -1 || line_num <= line_end)) {
            code = strconcat(code, line);
        }
        line_num++;
    }

    int rtrim_len = strlen(code);
    while (rtrim_len-- > 0) {
        if (code[rtrim_len] == 0x00) code[rtrim_len] = '\0';
        else if (code[rtrim_len] == 0x09) code[rtrim_len] = '\0';
        else if (code[rtrim_len] == 0x0a) code[rtrim_len] = '\0';
        else if (code[rtrim_len] == 0x0b) code[rtrim_len] = '\0';
        else if (code[rtrim_len] == 0x0c) code[rtrim_len] = '\0';
        else if (code[rtrim_len] == 0x0d) code[rtrim_len] = '\0';
        else if (code[rtrim_len] == 0x20) code[rtrim_len] = '\0';
        else break;
    }

    _output_write(code);
    _output_write("\n```\n");

    free(code);
    free(filename);
    fclose(fp);
}

char* strconcat(char* self, char* appender) {
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

void _output_write(char *appender) {
    output = strconcat(output, appender);
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