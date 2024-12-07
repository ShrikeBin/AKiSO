#include "types.h"
#include "stat.h"
#include "user.h"

int main() 
{
    //  hello
    printf(1,"Testing hello syscall:\n");
    hello();

    //  getppid
    printf(1,"Testing getppid syscall:\n");
    int ppid = getppid();
    printf(1,"Parent PID: %d\n", ppid);

    exit();
}
