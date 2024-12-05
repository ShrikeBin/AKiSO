#include <unistd.h>

int main()
{
    char c = 0;
    int sum = 0;
    
    while(read(0, &c, 1) > 0 && c != '\n')
    {
        sum += c -'0';
    }

    char buffer[10];
    int index = 9;

    do
    {
        buffer[index--] = (sum %10) + '0';
        sum /= 10;
    }
    while(sum >0);    

    write(1, &buffer[index+1], 9-index);
    write(1, "\n", 1);
    

    return 0;
}
