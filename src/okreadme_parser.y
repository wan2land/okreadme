%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <string.h>
    #include <ctype.h>
    #include <libgen.h>
    #include <unistd.h>
    #include "okreadme_type.h"

    #define RTRIM(__str) {\
        long rtrim_len = strlen(__str);\
        while (rtrim_len-- > 0) {\
            if (isspace(__str[rtrim_len])) __str[rtrim_len] = '\0';\
            else break;\
        }\
    }

    extern FILE *yyin;

    int yylex();
    void yyerror(const char *s);

    typedef char* string;

    enum okmd_error okmd_error_type = 0;
    char okmd_error_message[100];


    // str added
    int intersect_lines(char* lines);
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

%token T_NEWLINE T_FUNC_OPEN_BRACKET T_FUNC_CLOSE_BRACKET T_COMMA T_ATSIGN
%token <string> T_TEXT T_FUNC T_IDENT T_STRING
%token <ival> T_NUMBER

%%

okreadme: /* nothing */
    | lines
    ;

lines: line
    | lines T_NEWLINE line;

line: plain {
        _output_write("\n");
    }
    | function_call {
        _output_write("\n");
    }
    ;

plain: /* nothing */
    | T_TEXT {
        _output_write($1);
    }
    | T_ATSIGN T_TEXT {
        _output_write($2);
    }
    ;

function_call: T_ATSIGN function_name function_param {
        if (strcmp($2, "code") == 0) {
            if ($3->count > 0) {
                struct okmd_val *param1 = $3->first;
                struct okmd_val *param2 = param1->next;
                if (param1->type != t_string) {
                    okmd_error_type = ERROR_INVALID_PARAMS;
                    sprintf(okmd_error_message, "parameters 1 passed to @%s() must be be of the type string.\n", $2);
                    // "called in blabla.md on line 30" will added
                } else if (param2 != NULL && param2->type != t_string) {
                    okmd_error_type = ERROR_INVALID_PARAMS;
                    sprintf(okmd_error_message, "parameters 2 passed to @%s() must be be of the type string or null.\n", $2);
                    // "called in blabla.md on line 30" will added
                } else {
                    _call_code(param1->value.sval, param2 ? param2->value.sval : NULL);
                }
            } else {
                okmd_error_type = ERROR_MORE_PARAMS;
                sprintf(okmd_error_message, "@%s() expects at least 1 parameters, %d given.\n", $2, $3->count);
                // "in blabla.md on line 30" will added
            }
        } else {
            okmd_error_type = ERROR_UNDEFINED_FUNCTION;
            sprintf(okmd_error_message, "call to undefined function @%s().\n", $2);
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
        char *ext = strrchr(filename, '.');
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
        int is_start = 0;
        line_num = 1;
        char* section_start = strconcat(strdup("section:"), sub);

        while ((read = getline(&line, &len, fp)) != -1) {
            if (strstr(line, section_start) != NULL) {
                line_start = line_num + 1;
                is_start = 1;
            }
            if (is_start && strstr(line, "endsection") != NULL) {
                line_end = line_num - 1;
                break;
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
    RTRIM(code);

    char* code_dup = strdup(code);
    int intersect_p = intersect_lines(code_dup);
    free(code_dup);

    // result
    {
        char *line;
        while ((line = strsep(&code, "\n")) != NULL) {
            if (strlen(line) > intersect_p) {
                _output_write(line + intersect_p);
            }
            _output_write("\n");
        }
    }
    RTRIM(output);
    _output_write("\n```");

    free(code);
    free(filename);
    fclose(fp);
}

int intersect_lines(char* lines) {
    char buff[100];
    int buff_p = 0;
    int is_first = 1;
    
    char* line = strtok(lines, "\n");
    while (line != NULL) {
        char* line_dup = strdup(line);
        RTRIM(line_dup);
        if (strlen(line_dup)) {
            if (is_first) {
                int ilen = strlen(line);
                for (int i = 0; i < ilen; i++) {
                    if (line[i] == ' ' || line[i] == '\t') {
                        buff_p = i + 1;
                        buff[i] = line[i];
                    } else {
                        break;
                    }
                }
                is_first = 0;
            } else {
                int ilen = buff_p;
                buff_p = 0;
                for (int i = 0; i < ilen; i++) {
                    if ((line[i] == ' ' || line[i] == '\t') && buff[i] == line[i]) {
                        buff_p = i + 1;
                        buff[i] = line[i];
                    } else {
                        break;
                    }
                }
            }
        }
        free(line_dup);
        line = strtok(NULL, "\n");
    }

    return buff_p;
}

char* strconcat(char* self, char* appender) {
    int self_size = strlen(self);
    int appender_size = strlen(appender);
    int i;
    self = (char *)realloc(self, (self_size + appender_size + 1) * sizeof(char));
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

void yyerror(const char *s) {
    okmd_error_type = ERROR_SYNTAX;
    sprintf(okmd_error_message, "syntax error.\n");
}

char* okmd_scan_file(char *path, bool isDebug) {
    // printf("%s\n", path);
    FILE* fp = fopen(path, "r");
    chdir(dirname(path));
    if (!fp) {
        okmd_error_type = ERROR_FILE_NOT_FOUND;
        sprintf(okmd_error_message, "file %s does not found.\n", path);
        return NULL;
    }

    yyin = fp;
    output = (char *)malloc(1);
    *output = '\0';
    do {
        yyparse();
    } while(!feof(yyin));
    if (okmd_error_type != ERROR_NONE) {
        fclose(fp);
        return NULL;
    }

    int output_len = strlen(output);
    if (output_len > 1) {
        output[strlen(output) - 1] = '\0';
    }
    fclose(fp);
    return output;
}

int okmd_last_error() {
    return okmd_error_type;
}
char* okmd_last_error_message() {
    return okmd_error_message;
}
