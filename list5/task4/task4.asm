%include    '../functions.asm'


section .bss
    nums resb 100000

section .text
    global _start

_start:
    mov ecx, nums

init:
    mov byte [ecx], 1
    inc ecx
    cmp ecx, nums + 100000
    jl init

    mov byte [nums], 0
    xor ecx, ecx

sieve:
    inc ecx
    cmp ecx, 316        ; 316^2 > 100 000
    je print

    cmp byte [nums + ecx - 1], 0
    je sieve

    mov eax, ecx
    imul eax, eax

nonPrimes:
    mov byte [nums + eax - 1], 0

    add eax, ecx
    cmp eax, 100000
    jl nonPrimes

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