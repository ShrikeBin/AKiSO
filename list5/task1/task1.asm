 %include        'functions.asm'

SECTION .text
global  _start
 
_start:
 
    pop     ecx             ; first value on the stack is the number of arguments
    cmp     ecx, 2          ; check to see if we have 2 arguments
    jne     noMoreArgs      ; jne - jump if not equal, if argc != 2 then jump to noMoreArgs

    pop     eax             ; pop the name of the program (first argument)
    pop     eax             ; take (pop) the second argument (which interests us)

    mov edx, 0              ; making register 0 
    mov ebx, 0

                            ; ebx -> our sum
                            ; ecx -> each digit
sum:
    movzx ecx, byte [eax]   ; eax points on one char/digit from an argument, get it and set to ecx
    cmp ecx, 0              ; check if '\0'
    je done                 ; if jest end a loop

    sub ecx, '0'            ; ASCII to integer (np. '3'->3)
    add ebx, ecx            ; add this digit to sum

    inc eax                 ; next digit
    jmp sum                 ; again 


done:
    mov eax, ebx            ; sum from ebx goes to eax (because function iprintLF reads from eax and then converts this)
    call iprintLF
    
 
noMoreArgs:
    call    quit