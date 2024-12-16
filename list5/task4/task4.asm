%include    './../functions.asm'


section .bss
    nums resb 100000

section .text
    global _start

_start:
    mov ecx, nums

initNums:
    mov byte [ecx], 1
    inc ecx
    cmp ecx, nums + 100000
    jl initNums

    mov byte [nums], 0
    xor ecx, ecx

sieve:
    inc ecx
    cmp ecx, 316 ;sqrt(100000)
    je print

    cmp byte [nums + ecx - 1], 0
    je sieve

    mov eax, ecx
    imul eax, eax

setNonPrimes:
    mov byte [nums + eax - 1], 0

    add eax, ecx
    cmp eax, 100000
    jl setNonPrimes

    jmp sieve


print:
    xor ecx, ecx

printNum:
    inc ecx
    cmp ecx, 100000
    je quit

    cmp byte [nums + ecx - 1], 0
    je printNum

    mov eax, ecx
    call iprintLF
   
    jmp printNum


    call quit