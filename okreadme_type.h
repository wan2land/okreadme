
#ifndef OKREADME_TYPE_H
#define OKREADME_TYPE_H

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {false, true} bool;

enum okmd_error {
    ERROR_NONE = 0,
    ERROR_SYNTAX,
    ERROR_UNDEFINED_FUNCTION,
    ERROR_MORE_PARAMS,
    ERROR_INVALID_PARAMS, // type error
    
    ERROR_FILE_NOT_FOUND,
};
enum okmd_t {
    t_int,
    t_string,
};

struct okmd_val {
    enum okmd_t type;
    union {
        int ival;
        char* sval;
    } value;
    struct okmd_val* next;
};

struct okmd_val_list {
    int count;
    struct okmd_val *first;
};

struct okmd_val* okmd_val_create_int(int value);
struct okmd_val* okmd_val_create_string(char* value);

struct okmd_val_list* okmd_val_list_create();
void okmd_val_list_push(struct okmd_val_list *list, struct okmd_val *item);

#ifdef __cplusplus
}
#endif
#endif
