.386
.model flat, stdcall
option casemap:none

include \masm32\include\kernel32.inc
include \masm32\include\user32.inc

includelib \masm32\lib\kernel32.lib
includelib \masm32\lib\user32.lib
includelib \masm32\lib\msvcrt.lib

ExitProcess PROTO :DWORD
gets PROTO C :DWORD
MessageBoxA PROTO :DWORD, :DWORD, :DWORD, :DWORD

.data
buffer db "000000000000"
canary dd 5

msg db "Stack smashed!", 0
msgg db "Error", 0

.code
main:
    call vulnerable_function
    push 0
    call ExitProcess

vulnerable_function PROC
    push ebp
    mov ebp, esp
    sub esp, 16              ; 12 bytes buffer + 4 canary + 4 extra

    mov dword ptr [ebp-4], 5 ; canary en ebp-8

    lea eax, [ebp-16]        ; buffer en ebp-20
    push eax
    call gets
    add esp, 4

    cmp dword ptr [ebp-4], 5
    jne stack_smashed

    ; continua normal
    mov esp, ebp
    pop ebp
    ret

stack_smashed:
    push 0                  ; MB_OK = 0
    push offset msgg       ; título del MessageBox
    push offset msg         ; mensaje
    push 0                  ; handle ventana padre NULL
    call MessageBoxA

    push 1                  ; código de salida 1
    call ExitProcess

vulnerable_function ENDP

end main
