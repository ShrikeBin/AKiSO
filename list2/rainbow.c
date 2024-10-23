#include <stdio.h>

void setColor(int color)
{
	printf("\033[03%dm", color);
}

void resetColor()
{
	printf("\033[0m");
}

int main()
{
	const char* ms = "Hello World!";

	for(int i = 0; i <8; ++i)
	{
		setColor(i);
		printf("%s\n",ms);
		resetColor();
	}
	return 0;
}
