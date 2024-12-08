section .text

main:
    mov ebx, 0xA0000         ; Adres segmentowy dla trybu 320x200 VGA
    mov ecx, 200             ; Wysokość ekranu

    ; Offset dla Re i Im
    mov edx, -15000          ; Offset dla Re (w skali 10000)
    mov esi, -10000          ; Offset dla Im (w skali 10000)

outer_loop:
    push ecx                   ; Zapisz wartość licznika wysokości

inner_loop:
    mov eax, esi               ; Re
    mov ebx, edx               ; Im

    ; Maksymalna liczba iteracji
    mov edi, 50
    xor ecx, ecx

mandelbrot_iter:
    mov ebx, eax               ; Temporary Re
    imul ebx, ebx               ; Re^2
    imul edx, edx               ; Im^2

    add ebx, edx                ; Re^2 + Im^2
    cmp ebx, 256                 ; Jeśli przekracza próg 256
    jae pixel_black

    add ecx, 1
    jmp mandelbrot_iter

pixel_black:
    mov byte [ebx], 0x20         ; Kolor dla pikseli przekroczonych progiem

    loop inner_loop
    loop outer_loop

halt:
    cli
    hlt
