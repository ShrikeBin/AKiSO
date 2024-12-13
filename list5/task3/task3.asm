%include        '../functions.asm'
section .data
    number dd 12345678
    msg db "Hexadecimal: ", 0
    newline db 10, 0
    buffer db 100

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
    call quit
print_hex:
    mov ecx, 8
process_loop:
    mov edx, eax        ; Copy eax to edx
    and edx, 0xF         ; Mask only the lowest 4 bits
    call iprintLF        ; Call the printINT function with this nibble

    ; Shift eax left by 4 bits to remove the processed nibble
    shl eax, 4

    loop process_loop     ; Continue looping until all 8 nibbles are processed