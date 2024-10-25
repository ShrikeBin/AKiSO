// boot.c

void main() 
{
    char *video_memory = (char*) 0xB8000;
    char *message = "Hello, World!";
	
    for(unsigned char bg =0; bg < 256; ++bg)
    {
	    unsigned char color = bg;
	    unsigned char fg = (bg/16);
    	    int offset = (bg * 80 * 2) + (fg*80*2);
	    for (int i = 0; message[i] != '\0'; i++) 
	    {
		    video_memory[offset + i * 2] = message[i];
		    video_memory[offset + i * 2 + 1] = color;
	    }
    }
while(1);
}
