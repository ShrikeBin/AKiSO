section .data
    buffer db 0          ; Buffer for input
    buffer_len equ 20
    prompt db "Enter a number: ", 0
    result_msg db "Sum of digits: ", 0
    newline db 10, 0

section .bss
    sum resd 1           ; To store the sum of digits

section .text
    global _start

_start:
    ; Display prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, prompt
    mov edx, 17
    int 0x80

    ; Read input
    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, buffer_len
    int 0x80

    ; Null-terminate input to avoid overrun issues
    mov byte [buffer + eax - 1], 0x00

    ; Initialize sum and index
    xor esi, esi          ; Index in buffer
    xor eax, eax          ; Current sum

sum_digits:
    movzx ecx, byte [buffer + esi] ; Load character
    cmp ecx, 0x00         ; Check for null terminator
    je print_result       ; If null, stop
    sub ecx, '0'          ; Convert ASCII to digit
    add eax, ecx          ; Add digit to sum
    inc esi               ; Move to next character
    jmp sum_digits

print_result:
    mov [sum], eax        ; Store sum in memory

    ; Display result message
    mov eax, 4
    mov ebx, 1
    mov ecx, result_msg
    mov edx, 15
    int 0x80

    ; Convert number to ASCII and print
    mov eax, [sum]
    call print_number

    ; Print newline
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; Exit program
    mov eax, 1
    xor ebx, ebx
    int 0x80

print_number:
    ; Convert number to ASCII and display
    xor ecx, ecx          ; Digit counter
print_digit_loop:
    xor edx, edx          ; Clear remainder
    mov ebx, 10           ; Divisor
    div ebx               ; Divide eax by 10
    add dl, '0'           ; Convert remainder to ASCII
    push dx               ; Store on stack
    inc ecx               ; Increment digit counter
    test eax, eax         ; Check if quotient is 0
    jnz print_digit_loop

print_digits:
    push ecx             ; Save loop counter `ecx` on the stack
    pop dx                ; Retrieve digit from stack
    mov [buffer], dl      ; Store digit in buffer
    mov eax, 4            ; sys_write
    mov ebx, 1            ; stdout
    mov ecx, buffer       ; Address of the digit buffer
    mov edx, 1            ; Length = 1 character
    int 0x80              ; Call kernel to print digit
    pop ecx              ; Restore loop counter `ecx`
    dec ecx               ; Decrement loop counter
    jnz print_digits       ; Continue loop until counter reaches 0
    ret
