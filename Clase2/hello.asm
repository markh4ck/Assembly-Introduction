.386    
.model flat, stdcall
option casemap:none

includelib kernel32.lib
includelib user32.lib

MessageBoxA proto :DWORD, :DWORD, :DWORD, :DWORD
ExitProcess proto :DWORD

.data
    mensaje db "¡Hola mundo!", 0

.code
main proc
    ; Cargar los argumentos en registros
    mov eax, 0               ; hWnd = NULL
    mov ebx, OFFSET mensaje  ; lpText
    mov ecx, 0
    mov edx, 0               ; uType = MB_OK

    ; Push de derecha a izquierda
    push edx    ; uType
    push ecx    ; lpCaption
    push ebx    ; lpText
    push eax    ; hWnd

    call MessageBoxA

    ; salida y limpieza de pila
    mov eax, 0
    push eax
    call ExitProcess
main endp
end main
