#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char *argv[]) 
{
    if (argc != 2) 
    {
        printf(1, "Usage: test_mem <num_pages>\n");
        exit();
    }

    int num_pages = atoi(argv[1]);
    int total_memory = num_pages * 4096;

    int used_virtual = usedvp();
    int used_physical = usedpp();

    printf(1, "Virtual Pages: %d\n", used_virtual);
    printf(1, "Physical Pages: %d\n", used_physical);

    sbrk(total_memory); // 4kb -> one page

    used_virtual = usedvp();
    used_physical = usedpp();

    printf(1, "After allocating %d pages (%d bytes):\n", num_pages, total_memory);
    printf(1, "Virtual Pages: %d\n", used_virtual);
    printf(1, "Physical Pages: %d\n", used_physical);

    exit();
}
