.386
.model flat, stdcall
.stack 2096

includelib kernel32.lib
includelib user32.lib
ExitProcess proto :DWORD
.data
    mensaje db "Volviendo de la funcion", 0

.code

main:
    call mi_funcion       ; Llama a la función (guarda dirección de retorno)
    ; Aquí se vuelve después del RET

    push 0                ; código de salida
    call ExitProcess

; ---------------------------------------------------
; Función con stack frame, variables locales, etc.
; ---------------------------------------------------
mi_funcion:
    push ebp              ; Guarda el viejo EBP
    mov ebp, esp          ; EBP apunta al inicio del frame actual
    sub esp, 8            ; Reservamos 8 bytes para variables locales

    ; Ahora:
    ; EBP       -> viejo EBP
    ; EBP-4     -> variable local 1
    ; EBP-8     -> variable local 2

    mov dword ptr [ebp-4], 1234h   ; Guardamos valor en la variable local 1
    mov dword ptr [ebp-8], 5678h   ; Guardamos valor en la variable local 2

    ; Simular retorno de función con valor en eax
    mov eax, [ebp-4]               ; Devuelve el valor de la variable 1

    ; Deshacer el stack frame
    mov esp, ebp
    pop ebp
    ret                            ; Vuelve a la dirección guardada en la pila

end main
