#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>


volatile sig_atomic_t signal_count = 0;

void signal_handler(int signum) 
{
    signal_count++;
}

int main() 
{

    if (signal(SIGUSR1, signal_handler) == SIG_ERR) 
    {
        perror("Unable to register SIGUSR1\n");
        exit(1);
    }

    pid_t pid = getpid();
    printf("PID of this process: %d\n", pid);

    for (int i = 0; i < 20; i++) 
    {
        if (kill(pid, SIGUSR1) == -1) 
        {
            perror("Couldn't send signal\n");
        }
    }

    sleep(1);  // Wait to receive signals

    // Check signals received (if more than 1 OS queue'd the signals)
    printf("Number of received signals: %d\n", signal_count);

    return 0;
}
