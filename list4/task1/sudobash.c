#include <stdlib.h>
#include <unistd.h>

// sudo chown root:root sudobash
// sudo chmod u+s sudobash

int main() 
{
    setuid(0); //nadaj roota
    execl("/bin/bash", "bash", (char *)NULL);
    return 0;
}
