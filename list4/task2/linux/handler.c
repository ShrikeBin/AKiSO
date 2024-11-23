#define _GNU_SOURCE
#include <stdio.h>
#include <signal.h>
#include <stdlib.h>
#include <signal.h>
#include <string.h>
#include <unistd.h>

// invokes when process recieves a signal
void signal_handler(int signum) 
{
    printf(" Recieved/Handled a signal, id: %d\n", signum);
}

int main() 
{
    for (int i = 1; i < NSIG; i++) 
    {
        // Cannot be caught by a process
        
        if (i != SIGKILL && i != SIGSTOP)
        {
            //register signal handler function

            if (signal(i, signal_handler) == SIG_ERR)
            {
                printf("Unable to register signal handling for signal id: %d\n", i);
            }
        }
    }

    printf("Waiting for signals...\n");

    while (1) 
    {
        pause();
    }
    
    return 0;
}