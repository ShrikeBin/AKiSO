%include        '../functions.asm'
section .data
    sieve_size equ 100001             ; Rozmiar tablicy (100000 + 1, bo 0 jest ignorowane)
    prime_msg db "Prime: ", 0
    newline db 10, 0

section .bss
    sieve resb sieve_size             ; Tablica do oznaczania liczb (0 = potencjalnie pierwsza, 1 = nie pierwsza)

section .text
    global _start

_start:
    ; Inicjalizacja sita - ustaw wszystkie wartości na 0 (potencjalnie pierwsze)
    mov ecx, sieve_size
    xor eax, eax                      ; Wartość do zapisania (0)
    mov edi, sieve
    rep stosb

    ; Wykonaj sito Eratostenesa
    mov ecx, 2                        ; Pierwsza liczba pierwsza
sieve_loop:
    cmp ecx, sieve_size               ; Czy przekroczyliśmy zakres?
    jge print_primes

    ; Sprawdź, czy aktualna liczba jest oznaczona jako pierwsza
    mov al, byte [sieve + ecx]
    cmp al, 1                         ; Jeśli 1, to liczba jest oznaczona jako nie pierwsza
    je next_number

    ; Zaznacz wielokrotności tej liczby jako nie pierwsze
    mov ebx, ecx                      ; Zapisujemy aktualną liczbę w ebx
    mov edx, ecx                      ; Zaczynamy od kwadratu liczby
    imul edx, edx
mark_multiples:
    cmp edx, sieve_size               ; Czy wielokrotność jest poza zakresem?
    jge next_number
    mov byte [sieve + edx], 1         ; Oznacz wielokrotność jako nie pierwszą
    add edx, ebx                      ; Przejdź do następnej wielokrotności
    jmp mark_multiples

next_number:
    inc ecx                           ; Następna liczba
    jmp sieve_loop

print_primes:
    mov ecx, 2                        ; Zacznij od 2
print_loop:
    cmp ecx, sieve_size               ; Czy przekroczyliśmy zakres?
    jge exit

    ; Sprawdź, czy liczba jest pierwsza
    mov al, byte [sieve + ecx]
    cmp al, 0                         ; Jeśli 0, liczba jest pierwsza
    jne next_print

    ; Wyświetl "Prime: "
    mov eax, 4
    mov ebx, 1
    mov ecx, prime_msg
    mov edx, 7
    int 0x80

    ; Wyświetl liczbę
    mov eax, ecx                      ; Przechowujemy aktualną liczbę w eax
    call iprintLF

    ; Wyświetl nową linię
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

next_print:
    inc ecx                           ; Przejdź do następnej liczby
    jmp print_loop

exit:
    ; Wyjście z programu
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_decimal:
    ; Funkcja pomocnicza do wyświetlania liczby dziesiętnej
    push eax
    xor ecx, ecx
print_digit_loop:
    xor edx, edx
    mov ebx, 10
    div ebx                           ; eax = eax / 10, edx = eax % 10
    add dl, '0'                       ; Zamień cyfrę na ASCII
    push dx
    inc ecx
    test eax, eax
    jnz print_digit_loop

print_digits:
    pop dx
    mov [sieve], dl
    mov eax, 4
    mov ebx, 1
    mov ecx, sieve
    mov edx, 1
    int 0x80
    loop print_digits
    ret
