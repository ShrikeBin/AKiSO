%include        '../functions.asm'

section .data
    matrix dd 1, 2, 3, 4, 5, 6, 7, 8, 9
    result_msg_total db "Sum of elements: ", 0
    result_msg_diag db "Sum of diagonal: ", 0
    newline db 10, 0

section .bss
    total_sum resd 1
    diagonal_sum resd 1

section .text
    global _start

_start:
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx

    ; Licz sumę wszystkich elementów i przekątnej
    mov esi, matrix
    xor edi, edi
matrix_loop:
    mov edx, [esi + edi*4]
    add eax, edx
    cmp edi, 8             ; Check if `edi` is 0 (first diagonal element).
    je store_sums
    test edi, 3
    jnz next_element
    add ebx, edx

next_element:
    inc edi
    jmp matrix_loop

store_sums:
    add ebx, edx            ; STUPID BUT WORKS LMAO
    mov [total_sum], eax
    mov [diagonal_sum], ebx

    ; Wyświetl wyniki
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg_total
    mov edx, 18
    int 0x80

    mov eax, [total_sum]
    call iprintLF

    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg_diag
    mov edx, 18
    int 0x80

    mov eax, [diagonal_sum]
    call iprintLF

    ; Wyjście
    call quit
