
#ifndef OKREADME_LIB_H
#define OKREADME_LIB_H

#include <stdio.h>
#include "okreadme_type.h"

#ifdef __cplusplus
extern "C" {
#endif

char* okreadme_parse_file(FILE *fp, bool isDebug);

#ifdef __cplusplus
}
#endif
#endif
