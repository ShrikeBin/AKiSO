#include <iostream>
#include <cstdlib>
#include <sys/ptrace.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/stat.h>
#include <errno.h>
#include <syscall.h>
#include <sys/user.h>
#include <sys/reg.h>
#include <cstring> 

void error(const std::string &msg) 
{
    perror(msg.c_str());
    exit(EXIT_FAILURE);
}

void redirect_stdout(pid_t pid, const std::string &new_file) 
{
    // Open the new file for writing (creates or truncates the file)
    int new_fd = open(new_file.c_str(), O_WRONLY | O_CREAT | O_TRUNC, 0666);
    if (new_fd < 0) 
    {
        error("Opening output file failed");
    }



//maybe i need to execute open() in the opened process to create a new descriptor for him? how to inject all of that code into the attached process???




    

    // Attach to the target process
    if (ptrace(PTRACE_ATTACH, pid, nullptr, nullptr) < 0) 
    {
        error("ptrace attach failed");
    }

    // Wait for the process to stop
    if (waitpid(pid, nullptr, 0) < 0) 
    {
        error("waitpid failed");
    }

    // Get current registers
    struct user_regs_struct regs;
    if (ptrace(PTRACE_GETREGS, pid, nullptr, &regs) < 0) 
    {
        error("ptrace getregs failed");
    }   

    // Prepare for dup2 syscall
    long orig_rax = regs.orig_rax;   // Save the original syscall number
    regs.orig_rax = SYS_close;        // Change syscall to dup2
    regs.rdi = 1; //old_fd;

    // Set modified registers
    if (ptrace(PTRACE_SETREGS, pid, nullptr, &regs) < 0) 
    {
        error("ptrace setregs failed");
    }

    // Allow the process to execute the close syscall
    if (ptrace(PTRACE_SYSCALL, pid, nullptr, nullptr) < 0) 
    {
        error("ptrace syscall failed");
    }

    // Wait for the syscall to complete
    if (waitpid(pid, nullptr, 0) < 0) 
    {
        error("waitpid after syscall failed");
    }

    // Get regs again
    if (ptrace(PTRACE_GETREGS, pid, nullptr, &regs) < 0) 
    {
        error("ptrace getregs after syscall failed");
    }

    regs.orig_rax = SYS_dup2;        // Set to execute dup2
    regs.rdi = new_fd;               // Set the new file descriptor
    regs.rsi = 1;//old_fd; 

    // Set modified registers
    if (ptrace(PTRACE_SETREGS, pid, nullptr, &regs) < 0) 
    {
        error("ptrace setregs failed");
    }

    // Allow the process to execute the dup2 syscall
    if (ptrace(PTRACE_SYSCALL, pid, nullptr, nullptr) < 0) 
    {
        error("ptrace syscall failed");
    }

    if (regs.rax < 0) 
    {
        std::cerr << "dup2 failed in target process, errno: " << errno << std::endl;
    } 
    else 
    {
        std::cout << "dup2 succeeded, new stdout fd: " << regs.rax << std::endl;
    }

    // Restore the original syscall number
    regs.orig_rax = orig_rax;

    if (ptrace(PTRACE_SETREGS, pid, nullptr, &regs) < 0) 
    {
        error("ptrace reset regs failed");
    }

    // Detach from the process
    if (ptrace(PTRACE_DETACH, pid, nullptr, nullptr) < 0) 
    {
        error("ptrace detach failed");
    }

    // Close the new file descriptor
    close(new_fd);
}

int main(int argc, char *argv[]) 
{
    if (argc != 3) 
    {
        std::cerr << "Usage: " << argv[0] << " <process-id> <output_file>" << std::endl;
        return EXIT_FAILURE;
    }

    pid_t pid = std::stoi(argv[1]);
    std::string new_file = argv[2];
    redirect_stdout(pid, new_file);

    std::cout << "Successfully redirected stdout of process " << pid << " to " << new_file << std::endl;
    return EXIT_SUCCESS;
}
