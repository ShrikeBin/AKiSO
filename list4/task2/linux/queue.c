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
    int pid = fork();

    if (pid == 0) 
    {
        signal(10, signal_handler); // SIGUSR1
        printf(1, "Child process PID: %d\n", getpid());
        sleep(100);
        printf(1, "Received %d signals.\n", signal_count);
        exit(0);
    }
    else 
    {
        sleep(10);
        for (int i = 0; i < 10; i++) {
            printf(1, "Sending signal %d to PID %d\n", 10, pid);
            kill(pid, 10); // SIGUSR1
        }
        wait(); // Czekaj na zakończenie procesu potomnego
    }

    exit(0);
}
