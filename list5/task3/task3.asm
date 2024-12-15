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
    lea edi, [buffer]
    call print_hex

    lea eax, [buffer]          ; Load buffer address into EAX (expected by your function)
    call sprint

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
    mov edx, eax             ; Copy eax to edx
    and edx, 0xF0000000      ; Mask to isolate the top nibble (if edx = 12345678 which is 0000 0000 1011 1100 0110 0001 0100 1110, after it will be [0000] 0000 0000 0000 0000 0000 0000 0000 )
    shr edx, 28              ; Shift it to the top 4 bits

    ; Convert to ASCII
    cmp edx, 10
    jl convert_to_number
    add dl, 'A' - 10
    jmp store_to_buffer

convert_to_number:
    add dl, '0'

store_to_buffer:
    mov [edi], dl            ; Store ASCII in buffer
    inc edi                  ; Increment buffer pointer

    ; Shift EAX left for the next nibble
    shl eax, 4
    loop process_loop        ; Decrement ECX and repeat if not zero

    mov byte [edi], 0        ; Store a null terminator at the end of the buffer
    ret                      ; Return to caller