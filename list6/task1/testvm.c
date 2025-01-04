#include "types.h"
#include "stat.h"
#include "user.h"

#define PAGE_SIZE 4096

int main() 
{
    printf(1, "Allocating 5 pages using sbrk...\n");

    // Zaalokuj 5 stron pamięci
    for (int i = 0; i < 5; i++) 
    {
        if (sbrk(PAGE_SIZE) == (void *)-1) 
        {
            printf(1, "Failed to allocate page %d\n", i);
            exit();
        }
        printf(1, "Allocated page %d\n", i);
    }

    printf(1, "Done allocating pages. Exiting...\n");
    exit();
    
    return 0;
}
