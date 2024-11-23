#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

int main() 
{
    pid_t init_pid = 1;  // PID of init

    if (kill(init_pid, SIGKILL) == -1) 
    {
        perror("Unable to SIGKILL init\n");
    } 
    else 
    {
        printf("Killed init? O_O\n");
    }

    return 0;
}
