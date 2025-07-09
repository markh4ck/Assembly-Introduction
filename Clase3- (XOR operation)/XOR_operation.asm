.386
.model flat, stdcall
option casemap : none


includelib kernel32.lib
includelib user32.lib

MessageBoxA proto :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess proto :DWORD

.data
    mensaje db "Resultado: ",0
    buffer  db "0000",0         ; buffer para resultado decimal ascii
    divisor dd 10               ; divisor para convertir a decimal

.code
main proc
    ; Calcular XOR
    mov eax, 0F2h
    mov esi, 0FFh

    xor eax, esi          ; eax = 3 decimal

    ; Convertir eax a cadena decimal en buffer (4 dígitos)
    mov ebx, offset buffer + 3  ; Apunta al último dígito
    mov ecx, 4                  ; número de dígitos
convert_loop:
    xor edx, edx
    div dword ptr [divisor]     ; eax / 10, resto en edx
    add dl, '0'                 ; convertir dígito a ASCII
    mov [ebx], dl
    dec ebx
    dec ecx
    cmp eax, 0
    jne convert_loop

    ; Mostrar MessageBox
    mov eax, 0                  ; hWnd = NULL
    lea ebx, mensaje
    push 0                      ; MB_OK
    push 0                      ; lpCaption (NULL)
    lea ecx, buffer             ; lpText = buffer con resultado
    push ecx
    push eax
    call MessageBoxA

    ; Salir
    push 0
    call ExitProcess

main endp
end main
