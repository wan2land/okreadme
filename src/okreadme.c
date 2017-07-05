
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include "okreadme_lib.h"

typedef char* string;

int main(int argc, string argv[])
{
    bool isDebug = false;
    string filename = "README.ok.md";
    if (argc >= 2) {
        if (strcmp(argv[1], "-v") == 0) {
            printf("OK Readme 0.2.0\nIs Your Readme OK? :-)\n");
            return 0;
        }
        int i;
        for (i = 1; i < argc; i++) {
            if (strcmp(argv[i], "--debug") == 0) {
                isDebug = true;
            } else {
                filename = argv[i];
            }
        }
    }
    char path[255];
    getcwd(path, 255);
    strcat(path, "/");
    strcat(path, filename);
    char *result = okmd_scan_file(path, isDebug);
    if (result == NULL) {
        fputs(okmd_last_error_message(), stderr);
        return 1;
    }
    printf("%s", result);
    return 0;
}
