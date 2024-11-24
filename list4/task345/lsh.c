#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <signal.h>

#define MAX_INPUT_SIZE 1024
#define MAX_ARGS 128

// Flaga określająca czy użytkownik nacisnął Ctrl-C
volatile sig_atomic_t ctrl_c_pressed = 0;

// Funkcja obsługi sygnału SIGINT (Ctrl-C)
void handle_sigint(int sig) 
{
    ctrl_c_pressed = 1;
    printf("\n");
}

// Funkcja zmieniająca katalog
void lsh_cd(char **args) 
{
    if (args[1] == NULL) 
    {
        fprintf(stderr, "lsh: expected argument to \"cd\"\n");
    } 
    else 
    {
        if (chdir(args[1]) != 0) 
        {
            perror("lsh");
        }
    }
}

// Funkcja kończąca powłokę
void lsh_exit() 
{
    exit(0);
}

// Funkcja obsługująca procesy w tle
void handle_zombies() 
{
    while (waitpid(-1, NULL, WNOHANG) > 0);
}

// Funkcja do obsługi potoków i przekierowań
void execute_command(char **args) 
{
    int input_fd = -1; 
    int output_fd = -1;
    int error_fd = -1; 
    int pipe_fd[2];
    int has_pipe = 0;
    char *pipe_args[MAX_ARGS];
    pid_t pid;

    // Sprawdzenie, czy w komendzie znajduje się potok '|'
    for (int i = 0; args[i] != NULL; i++) 
    {
        if (strcmp(args[i], "|") == 0) 
        {
            args[i] = NULL;
            has_pipe = 1;

            //copy command after pipe to pipe_args
            memcpy(pipe_args, &args[i + 1], (MAX_ARGS - i - 1) * sizeof(char *));
            break;
        }
    }

    // Handle >, <, 2>, opens the arguments as files
    for (int i = 0; args[i] != NULL; i++) 
    {
        if (strcmp(args[i], "<") == 0) 
        {
            args[i] = NULL;
            input_fd = open(args[i + 1], O_RDONLY);
            if (input_fd == -1) 
            {
                perror("lsh");
                return;
            }
        } 
        else if (strcmp(args[i], ">") == 0) 
        {
            args[i] = NULL;
            output_fd = open(args[i + 1], O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (output_fd == -1) 
            {
                perror("lsh");
                return;
            }
        } 
        else if (strcmp(args[i], "2>") == 0) 
        {
            args[i] = NULL;
            error_fd = open(args[i + 1], O_WRONLY | O_CREAT | O_TRUNC, 0644);
            if (error_fd == -1) 
            {
                perror("lsh");
                return;
            }
        }
    }

    // will save pipe fd read to pipe_fd[0] and fd write to pipe_fd[1]
    if (has_pipe && pipe(pipe_fd) == -1) 
    {
        perror("lsh");
        return;
    }

    // Create child process, 0 - child , > 0 parent process (returns child's pid), <1 error
    // child 1 runs first command and redirects to pipe
    // parent creates child 2 and manages the pipe descriptors
    // child 2 runs second pipe command

    pid = fork();

    if (pid < 0) 
    {
        perror("lsh");
    }
    else if (pid == 0)
    {   
        // redirect all descriptors and close the old ones
        if (input_fd != -1)
        {
            dup2(input_fd, STDIN_FILENO);
            close(input_fd);
        }

        if (output_fd != -1) 
        {
            dup2(output_fd, STDOUT_FILENO);
            close(output_fd);
        }

        if (error_fd != -1) 
        {
            dup2(error_fd, STDERR_FILENO);
            close(error_fd);
        }

        if (has_pipe) 
        {
            close(pipe_fd[0]);
            dup2(pipe_fd[1], STDOUT_FILENO);
            close(pipe_fd[1]);
        }

        //execute execvp
        if (execvp(args[0], args) == -1) 
        {
            perror("lsh");
        }
        exit(EXIT_FAILURE);
    } 
    else 
    {
        if (has_pipe) 
        {
            close(pipe_fd[1]);

            //fork again to handle the pipe as a parent
            pid_t pipe_pid = fork();

            if (pipe_pid == 0) 
            { // Proces do obsługi drugiej komendy
                dup2(pipe_fd[0], STDIN_FILENO);
                close(pipe_fd[0]);

                if (execvp(pipe_args[0], pipe_args) == -1) 
                {
                    perror("lsh");
                }
                exit(EXIT_FAILURE);
            } 
            else if (pipe_pid < 0) 
            {
                perror("lsh");
            } 
            else 
            {
                close(pipe_fd[0]);
                waitpid(pipe_pid, NULL, 0); //wait for child 2
            }
        }
        waitpid(pid, NULL, 0); //wait for child 1
    }
}

// Funkcja parsująca linię wejściową
int lsh_parse_input(char *input, char **args, int *background) 
{
    *background = 0;
    char *token = strtok(input, " \t\n");
    int i = 0;

    while (token != NULL) 
    {
        args[i++] = token;
        token = strtok(NULL, " \t\n");
    }

    if (i > 0 && strcmp(args[i - 1], "&") == 0) 
    {
        *background = 1;
        args[--i] = NULL; // Usuń '&' z argumentów
    }

    args[i] = NULL;
    return i;
}

// Główna funkcja powłoki
void lsh_loop() 
{
    char input[MAX_INPUT_SIZE];
    char *args[MAX_ARGS];
    int background;

    while (1) 
    {
        printf("\033[1;31m$\033[0m\033[1;32mlsh\033[0m \033[1;34m> \033[0m");
        fflush(stdout);

        if (fgets(input, sizeof(input), stdin) == NULL) 
        {
            printf("\n");
            break; // Ctrl+D kończy program
        }

        handle_zombies(); // Obsługa procesów zombie

        if (strlen(input) == 1) continue; // Pusta linia

        lsh_parse_input(input, args, &background);

        if (args[0] == NULL) continue; // Brak komendy

        if (strcmp(args[0], "cd") == 0) 
        {
            lsh_cd(args);
        } 
        else if (strcmp(args[0], "exit") == 0) 
        {
            lsh_exit();
        } 
        else 
        {
            execute_command(args);
        }
    }
}

int main() 
{
    // Ustawienie obsługi Ctrl-C
    signal(SIGINT, handle_sigint);

    lsh_loop();
    return 0;
}
