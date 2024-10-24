#include <stdio.h>

void setColor(int color)
{
	printf("\033[38;5;%dm", color);
}

void resetColor()
{
	printf("\033[0;0m");
}

int main()
{
	int limit = 0;
	const char* ms = "Hello World!";
	
	printf("Limit:\n");
	scanf("%d", &limit);

	for(int i = 0; i <limit +1; ++i)
	{
		setColor(i);
		printf("%s\n",ms);
		resetColor();
	}
	return 0;
}
