%include        '../functions.asm'

section .data
    newline db 10, 0           ; Znak nowej linii (ASCII 0x0A)
    limit dd 100000            ; Górny limit do którego znajdujemy liczby pierwsze

section .bss
    primes resb 100000        ; Bufor na flagi liczb pierwszych (do 100000 / 8 = ~125000 bajtów)

section .text
    global _start

_start:
    ; Inicjalizacja - wypełnienie tablicy liczb flagami (wszystkie liczby oznaczamy jako potencjalne pierwsze)
    mov ecx, 0
    mov eax, 100000
    mov edi, primes

init_loop:
    mov byte [edi + ecx], 1   ; Ustawiamy wszystkie liczby jako potencjalne pierwsze
    inc ecx
    cmp ecx, eax
    jl init_loop

    ; Sito Eratostenesa - eliminujemy liczby złożone
    mov ecx, 2                 ; Pierwsza liczba do sprawdzenia

sieve_loop:
    mov eax, ecx                ; Aktualna liczba `ecx`
    mov edx, ecx                ; Kopia liczby do mnożenia

    ; Oblicz wartość `n^2` i sprawdź, czy mieści się w granicach
    imul edx, ecx
    cmp edx, 100000             ; Jeśli n^2 > 100000, kończ algorytm
    jg finish

    mov ebx, edx
    mov esi, primes

eliminate_loop:
    mov al, byte [esi + ebx]    ; Sprawdzamy wartość flagi w tablicy
    cmp al, 0
    je continue_outer

    mov byte [esi + ebx], 0     ; Wyzerowujemy flagę dla liczb złożonych

continue_outer:
    add ebx, ecx
    cmp ebx, limit
    jl eliminate_loop

    inc ecx
    jmp sieve_loop

finish:
    ; Teraz wypisujemy liczby pierwsze na konsolę
    mov ecx, 2
    mov edi, primes

print_loop:
    mov al, byte [edi + ecx]     ; Sprawdzamy flagę dla liczby
    cmp al, 0
    je not_prime

    mov eax, ecx                  ; Wartość liczb pierwszych
    call iprintLF                 ; Wypisujemy liczbę na konsoli

not_prime:
    add ecx, 1                    ; Przesuwamy po kolejnej liczbie w tablicy
    cmp ecx, 100000
    jl print_loop                 ; Powtarzamy proces, dopóki nie osiągniemy limitu liczb

    call quit