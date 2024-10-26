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
        // Output for debugging purposes
        std::cout << "Registers got:\n"
              << "RAX: " << regs.rax << "\n"
              << "RBX: " << regs.rbx << "\n"
              << "RCX: " << regs.rcx << "\n"
              << "RDX: " << regs.rdx << "\n"
              << "RSI: " << regs.rsi << "\n"
              << "RDI: " << regs.rdi << "\n"
              << "RBP: " << regs.rbp << "\n"
              << "RSP: " << regs.rsp << "\n"
              << "R8 : " << regs.r8 << "\n"
              << "R9 : " << regs.r9 << "\n"
              << "R10: " << regs.r10 << "\n"
              << "R11: " << regs.r11 << "\n"
              << "R12: " << regs.r12 << "\n"
              << "R13: " << regs.r13 << "\n"
              << "R14: " << regs.r14 << "\n"
              << "R15: " << regs.r15 << "\n"
              << "RIP: " << regs.rip << "\n"
              << "ORIG RAX: " << regs.orig_rax << "\n"
              << "EFLAGS: " << regs.eflags << std::endl;

    // Prepare for dup2 syscall
    long orig_rax = regs.orig_rax;   // Save the original syscall number
    regs.orig_rax = SYS_dup2;        // Change syscall to dup2
    regs.rdi = new_fd;               // Set the new file descriptor
    regs.rsi = STDOUT_FILENO;        // Redirect stdout (file descriptor 1)

    // Set modified registers
    if (ptrace(PTRACE_SETREGS, pid, nullptr, &regs) < 0) 
    {
        error("ptrace setregs failed");
    }

    if (ptrace(PTRACE_GETREGS, pid, nullptr, &regs) < 0) 
    {
        error("ptrace getregs failed");
    }
        // Output for debugging purposes
        std::cout << "Registers got after set:\n"
              << "RAX: " << regs.rax << "\n"
              << "RBX: " << regs.rbx << "\n"
              << "RCX: " << regs.rcx << "\n"
              << "RDX: " << regs.rdx << "\n"
              << "RSI: " << regs.rsi << "\n"
              << "RDI: " << regs.rdi << "\n"
              << "RBP: " << regs.rbp << "\n"
              << "RSP: " << regs.rsp << "\n"
              << "R8 : " << regs.r8 << "\n"
              << "R9 : " << regs.r9 << "\n"
              << "R10: " << regs.r10 << "\n"
              << "R11: " << regs.r11 << "\n"
              << "R12: " << regs.r12 << "\n"
              << "R13: " << regs.r13 << "\n"
              << "R14: " << regs.r14 << "\n"
              << "R15: " << regs.r15 << "\n"
              << "RIP: " << regs.rip << "\n"
              << "ORIG RAX: " << regs.orig_rax << "\n"
              << "EFLAGS: " << regs.eflags << std::endl;

    // Allow the process to execute the dup2 syscall
    if (ptrace(PTRACE_SYSCALL, pid, nullptr, nullptr) < 0) 
    {
        error("ptrace syscall failed");
    }

    // Wait for the syscall to complete
    if (waitpid(pid, nullptr, 0) < 0) 
    {
        error("waitpid after syscall failed");
    }

    // Check if dup2 was successful
    if (ptrace(PTRACE_GETREGS, pid, nullptr, &regs) < 0) 
    {
        error("ptrace getregs after syscall failed");
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
