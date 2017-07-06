
#ifndef OKREADME_LIB_H
#define OKREADME_LIB_H

#include <stdio.h>
#include "okreadme_type.h"

#define OKREADME_VERSION "v0.1.0"

#ifdef __cplusplus
extern "C" {
#endif

int okmd_last_error();
char* okmd_last_error_message();

char* okmd_scan_file(char *path, bool isDebug);

#ifdef __cplusplus
}
#endif
#endif
