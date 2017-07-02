
#ifndef OKREADME_LIB_H
#define OKREADME_LIB_H

#include <stdio.h>
#include "okreadme_type.h"

#ifdef __cplusplus
extern "C" {
#endif

int okmd_last_error();
char* okmd_last_error_message();

char* okmd_scan_file(FILE *fp, bool isDebug);

#ifdef __cplusplus
}
#endif
#endif
