//
// threadripper.c
//
// Created by SeanIsNotAConstant on 15.10.24
//
 
#include "threadripper.h"

void *threadripper(void *arg) {
    dyargs *data = (dyargs *)arg;
    void *handle = data->handle;

    int (*dylib_main)(int, char**) = dlsym(handle, "main");
    char *error = dlerror();
    if (error != NULL) {
        fprintf(stderr, "[dyexec] error: %s\n", error);
        return NULL;
    }
    printf("[thread] main: %p\n", dylib_main);

    dylib_main(data->argc, data->argv);

    pthread_exit(NULL);

    return NULL;
}