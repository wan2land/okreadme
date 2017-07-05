
#include <stdio.h>
#include <stdlib.h>
#include "okreadme_type.h"

struct okmd_val* okmd_val_create_int(int value) {
    struct okmd_val* result = (struct okmd_val*) malloc(sizeof(struct okmd_val));
    result->type = t_int;
    result->value.ival = value;
    result->next = NULL;
    return result;
}

struct okmd_val* okmd_val_create_string(char* value) {
    struct okmd_val* result = (struct okmd_val*) malloc(sizeof(struct okmd_val));
    result->type = t_string;
    result->value.sval = value;
    result->next = NULL;
    return result;
}

struct okmd_val_list* okmd_val_list_create() {
    struct okmd_val_list* result = (struct okmd_val_list*) malloc(sizeof(struct okmd_val_list));
    result->count = 0;
    result->first = NULL;
    return result;
}

void okmd_val_list_push(struct okmd_val_list *list, struct okmd_val *item) {
    if (list->count == 0) {
        list->first = item;
    } else {
        struct okmd_val* pivot = list->first;
        while (pivot->next) {
            printf("while\n");
            pivot = pivot->next;
        }
        pivot->next = item;
    }
    list->count++;
}
