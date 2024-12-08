section .data
    buffer db 20         ; Bufor na wejście
    buffer_len equ 20
    prompt db "Enter a number: ", 0
    result_msg db "Sum of digits: ", 0
    newline db 10, 0

section .bss
    sum resd 1           ; Przechowywanie sumy cyfr

section .text
    global _start

_start:
    ; Wyświetl prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, 17
    int 0x80

    ; Wczytaj wejście
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, buffer_len
    int 0x80

    ; Inicjalizacja sumy
    xor esi, esi          ; Indeks w buforze
    xor eax, eax          ; Aktualna suma

sum_digits:
    movzx ecx, byte [buffer + esi]
    cmp ecx, 10           ; Sprawdź znak końca wprowadzenia
    je print_result
    sub ecx, '0'          ; Konwertuj ASCII na cyfrę
    add eax, ecx          ; Dodaj cyfrę do sumy
    inc esi               ; Kolejny znak
    jmp sum_digits

print_result:
    mov [sum], eax        ; Zapisz sumę cyfr

    ; Wyświetl wynik
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, 16
    int 0x80

    ; Zamień liczbę na ASCII
    mov eax, [sum]
    call print_number

    ; Wyświetl nową linię
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Wyjście z programu
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_number:
    ; Konwertuj liczbę na ASCII i wyświetl
    push eax
    xor ecx, ecx
print_digit_loop:
    xor edx, edx
    mov ebx, 10
    div ebx
    add dl, '0'
    push dx
    inc ecx
    test eax, eax
    jnz print_digit_loop

print_digits:
    pop dx
    mov [buffer], dl
    mov eax, 4
    mov ebx, 1
    mov ecx, buffer
    mov edx, 1
    int 0x80
    loop print_digits
    ret
