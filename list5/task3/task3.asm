section .data
    number dd 0x12345678
    msg db "Hexadecimal: ", 0
    newline db 10, 0

section .text
    global _start

_start:
    ; Wyświetl "Hexadecimal: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, 13
    int 0x80

    ; Pobierz liczbę
    mov eax, [number]
    call print_hex

    ; Wyświetl nową linię
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Wyjście
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_hex:
    push eax
    mov ecx, 8
hex_loop:
    rol eax, 4
    mov edx, eax
    and edx, 0xF
    add dl, '0'
    cmp dl, '9'
    jbe write_hex
    add dl, 7
write_hex:
    push dx
    loop hex_loop

print_hex_digits:
    pop dx
    mov [buffer], dl
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    loop print_hex_digits
    ret
