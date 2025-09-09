.386
.model flat, stdcall
.stack 4096
option casemap:none

; ---------------------------------------------------
; Definiciones mínimas para Windows API sin windows.inc
; ---------------------------------------------------

STD_INPUT_HANDLE  equ -10
STD_OUTPUT_HANDLE equ -11

ExitProcess proto :DWORD
GetStdHandle proto :DWORD
ReadConsoleA proto hConsoleInput:DWORD, lpBuffer:PTR BYTE, nNumberOfCharsToRead:DWORD, lpNumberOfCharsRead:PTR DWORD, lpReserved:DWORD
WriteConsoleA proto hConsoleOutput:DWORD, lpBuffer:PTR BYTE, nNumberOfCharsToWrite:DWORD, lpNumberOfCharsWritten:PTR DWORD, lpReserved:DWORD
lstrlenA proto lpString:PTR BYTE

includelib kernel32.lib

; ---------------------------------------------------
.data
prompt      db "Escribe algo y pulsa Enter: ", 0
buffer      db 256 dup(?)           ; búfer de 256 bytes
bytesRead   dd 0
bytesWritten dd 0
nl          db 13,10,0

hIn         dd 0
hOut        dd 0

.code
start:

    ; Obtener handles de entrada y salida estándar
    invoke GetStdHandle, STD_INPUT_HANDLE
    mov hIn, eax
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hOut, eax

    ; Mostrar prompt
    invoke lstrlenA, addr prompt
    invoke WriteConsoleA, hOut, addr prompt, eax, addr bytesWritten, 0

    ; Leer input del usuario (máx 255 caracteres)
    mov eax, 255
    invoke ReadConsoleA, hIn, addr buffer, eax, addr bytesRead, 0

    ; Normalizar: quitar CRLF y terminar en 0
    mov ecx, bytesRead
    cmp ecx, 0
    jle show
    mov edx, ecx
    dec edx
    cmp byte ptr buffer[edx], 10   ; LF
    jne no_lf
    mov byte ptr buffer[edx], 0
    dec ecx
no_lf:
    cmp ecx, 0
    jle show
    mov edx, ecx
    dec edx
    cmp byte ptr buffer[edx], 13   ; CR
    jne no_cr
    mov byte ptr buffer[edx], 0
no_cr:

show:
    ; salto de línea
    invoke lstrlenA, addr nl
    invoke WriteConsoleA, hOut, addr nl, eax, addr bytesWritten, 0

    ; mostrar lo que escribió el usuario
    invoke lstrlenA, addr buffer
    invoke WriteConsoleA, hOut, addr buffer, eax, addr bytesWritten, 0

    ; salto de línea final
    invoke WriteConsoleA, hOut, addr nl, 2, addr bytesWritten, 0
end start