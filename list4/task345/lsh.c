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

typedef struct Job 
{
    pid_t pid;
    char command[MAX_INPUT_SIZE];
    int is_running; // 1 = running, 0 = stopped
} Job;

Job jobs[MAX_ARGS];
int job_count = 0;

volatile pid_t foreground_pid = -1;  // pid of foreground


void add_job(pid_t pid, char *command, int running) 
{
    jobs[job_count].pid = pid;
    char proc_file[256];
    snprintf(proc_file, sizeof(proc_file), "/proc/%d/comm", pid);

    FILE *fp = fopen(proc_file, "r");
    if (fp != NULL) 
    {
        // Zczytaj nazwę procesu
        if (fgets(jobs[job_count].command, MAX_INPUT_SIZE, fp) != NULL) 
        {
            // Usuwamy ewentualny znak nowej linii na końcu
            jobs[job_count].command[strcspn(jobs[job_count].command, "\n")] = 0;
        }
        fclose(fp);
    }
    else 
    {
        // Jeśli nie udało się otworzyć pliku, użyj "Unknown"
        strncpy(jobs[job_count].command, "Unknown", MAX_INPUT_SIZE);
    }

    if (command != NULL) 
    {
        //dodaj komentarz do zczytanej nazwy
        strncat(jobs[job_count].command, " - ", MAX_INPUT_SIZE - strlen(jobs[job_count].command) - 1);
        strncat(jobs[job_count].command, command, MAX_INPUT_SIZE - strlen(jobs[job_count].command) - 1);
    }

    jobs[job_count].is_running = running;  // Oznaczamy, że proces jest w tle i działa
    job_count++;
}

void remove_job(pid_t pid) 
{
    for (int i = 0; i < job_count; i++) 
    {
        if (jobs[i].pid == pid) 
        {
            for (int j = i; j < job_count - 1; j++) 
            {
                jobs[j] = jobs[j + 1];
            }
            job_count--;
            return;
        }
    }
}

void update_job_status(pid_t pid, int is_running) 
{
    for (int i = 0; i < job_count; i++) 
    {
        if (jobs[i].pid == pid) 
        {
            jobs[i].is_running = is_running;
            return;
        }
    }
}

void list_jobs() 
{
    for (int i = 0; i < job_count; i++) 
    {
        printf("[%d] %s %s\n", i + 1, jobs[i].is_running ? "Running: " : "Stopped: ", jobs[i].command);
    }
}

void bg_job(int job_index) 
{
    if (job_index < 0 || job_index >= job_count) 
    {
        fprintf(stderr, "Invalid job index\n");
        return;
    }
    kill(jobs[job_index].pid, SIGCONT);
    jobs[job_index].is_running = 1;
}

void fg_job(int job_index) 
{
    if (job_index < 0 || job_index >= job_count) 
    {
        fprintf(stderr, "Invalid job index\n");
        return;
    }
    pid_t pid = jobs[job_index].pid;
    foreground_pid = pid;
    kill(pid, SIGCONT);
    jobs[job_index].is_running = 1;
    waitpid(pid, NULL, 0);
    remove_job(pid);
}

void handle_sigint(int sig) 
{
    if (foreground_pid > 0) 
    {
        kill(foreground_pid, SIGINT); // kill fg process
        foreground_pid = -1;
    }
}

void handle_sigtstp(int sig) 
{
    if (foreground_pid > 0) 
    {
        kill(foreground_pid, SIGTSTP);
        add_job(foreground_pid, "Moved to Background: ", 0);
        foreground_pid = -1;
    }
}

// "cd" function
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

void lsh_exit() 
{
    exit(0);
}

void handle_zombies() 
{
    while (waitpid(-1, NULL, WNOHANG) > 0);
}

// Main command recognition
void execute_command(char **args)
{
    int input_fd = -1; 
    int output_fd = -1;
    int error_fd = -1; 
    int pipe_fd[2];
    int has_pipe = 0;
    int is_background = 0;
    char *pipe_args[MAX_ARGS];
    pid_t pid;

    // check if "&"
    for (int i = 0; args[i] != NULL; i++) 
    {
        if (strcmp(args[i], "&") == 0) 
        {
            args[i] = NULL;
            is_background = 1;
            break;
        }
    }

    // check if '|'
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
        
        if (has_pipe) 
        {
            close(pipe_fd[0]);
            dup2(pipe_fd[1], STDOUT_FILENO);
            close(pipe_fd[1]);
        }
        
        // redirect all descriptors and close the old ones
        if (input_fd != -1)
        {
            dup2(input_fd, STDIN_FILENO);
            close(input_fd);
        }

        if (!has_pipe && output_fd != -1) 
        {
            dup2(output_fd, STDOUT_FILENO);
            close(output_fd);
        }

        if (error_fd != -1) 
        {
            dup2(error_fd, STDERR_FILENO);
            close(error_fd);
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
            {
                dup2(pipe_fd[0], STDIN_FILENO);
                execvp(pipe_args[0], pipe_args);
                perror("execvp");
                exit(EXIT_FAILURE);
            }
            close(pipe_fd[0]);

            if (is_background) 
            {
                add_job(pipe_pid, pipe_args[0], 1);
                printf("[%d] %d\n", job_count, pipe_pid);
            } 
            else 
            {
                //wait for child 2
                waitpid(pipe_pid, NULL, 0);
            }
        }
        if (is_background) 
        {
            add_job(pid, args[0], 1);
            printf("[%d] %d\n", job_count, pid);
        } 
        else 
        {
            //wait for child 1
            foreground_pid = pid;
            waitpid(pid, NULL, 0);
        }
    }
}

// Funkcja parsująca linię wejściową
int lsh_parse_input(char *input, char **args) 
{

    char *token = strtok(input, " \t\n");
    int i = 0;

    while (token != NULL) 
    {
        args[i++] = token;
        token = strtok(NULL, " \t\n");
    }

    args[i] = NULL;
    return i;
}

// Główna funkcja powłoki
void lsh_loop() 
{
    char input[MAX_INPUT_SIZE];
    char *args[MAX_ARGS];

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

        lsh_parse_input(input, args);

        if (args[0] == NULL) continue; // Brak komendy

        if (strcmp(args[0], "cd") == 0) 
        {
            lsh_cd(args);
        } 
        else if (strcmp(args[0], "exit") == 0) 
        {
            lsh_exit();
        } 
        else if (strcmp(args[0], "jobs") == 0) 
        {
            list_jobs();
        } 
        else if (strcmp(args[0], "bg") == 0) 
        {
            if (args[1] != NULL) bg_job(atoi(args[1]) - 1);
        } 
        else if (strcmp(args[0], "fg") == 0) 
        {
            if (args[1] != NULL) fg_job(atoi(args[1]) - 1);
        } 
        else
        {
            execute_command(args);
        }
    }
}

int main() 
{

    signal(SIGINT, handle_sigint);  // Set SIGINT handler
    
    struct sigaction sa_sigtstp;
    sa_sigtstp.sa_handler = handle_sigtstp;
    sa_sigtstp.sa_flags = 0;
    sigemptyset(&sa_sigtstp.sa_mask);
    sigaction(SIGTSTP, &sa_sigtstp, NULL);

    lsh_loop();
    return 0;
}
