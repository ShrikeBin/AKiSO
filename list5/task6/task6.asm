section .data
    msg db "Factorial: ", 0
    newline db 10, 0

section .bss
    result resb 64      ; Bufor na wynik (wynik silni jako ciąg znaków)

section .text
    global _start

_start:
    ; Pobierz wartość n z argumentów linii poleceń
    mov rsi, [rsp + 8]   ; Argument argv[1] w rejestrze rsi
    mov rbx, 1           ; Domyślnie ustaw wynik na 1

parse_number:
    movzx rdx, byte [rsi] ; Wczytaj znak
    test rdx, rdx         ; Sprawdź, czy nie osiągnięto końca ciągu
    jz compute_factorial

    sub rdx, '0'         ; Konwertuj znak na wartość liczbową
    imul rbx, rbx, 10     ; Przesuń wartość w lewo (mnożenie przez 10)
    add rbx, rdx          ; Dodaj nową cyfrę do wartości liczby

    inc rsi               ; Przejdź do następnego znaku w argv
    jmp parse_number

compute_factorial:
    mov rax, 1

calculate_loop:
    cmp rbx, 1            ; Jeśli n == 1, skończ obliczenia
    jbe display_result

    imul rax, rbx     ; Pomnóż aktualną wartość rbx z rax
    dec rbx                ; zmniejsz o 1 i powtarzaj iterację
    jmp calculate_loop

display_result:
    mov rdi, 1             ; Deskryptor pliku (stdout)
    mov rsi, rax           ; Wynik silni w rsi
    mov rax, 1             ; Wywołanie syscall dla write
    mov rdx, 64
    syscall

exit_program:
    mov rax, 60            ; Exit syscall
    xor rdi, rdi           ; Kod wyjścia 0
    syscall
