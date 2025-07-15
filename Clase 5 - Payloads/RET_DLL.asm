; MASM32 - 32-bit Windows, sin includes

.386    
.model flat, stdcall
.stack 4096
option casemap:none

.data
    command db 'calc.exe', 0
    winexec_str db 'WinExec', 0
    exitproc_str db 'ExitProcess', 0

.code
start:

    ; ========================
    ; 1. Obtener dirección del PEB
    ; ========================
    mov eax, fs:[0x30]            ; EAX = PEB
    mov eax, [eax + 0x0C]         ; EAX = PEB->Ldr
    mov esi, [eax + 0x14]         ; ESI = &InMemoryOrderModuleList
    
    ;lista enlazada, pasando de un puntero a otro (no de offset o indice en array)
    
    mov esi, [esi]                ; ESI = primer módulo (normalmente ntdll.dll)
    mov esi, [esi]                ; ESI = segundo módulo (kernel32.dll)

    ; ========================
    ; 2. Obtener base de kernel32.dll
    ; ========================
    mov ebx, [esi + 0x10]         ; EBX = BaseAddress de kernel32.dll

    ; ========================
    ; 3. Obtener dirección de tabla de exportación
    ; ========================
    mov eax, [ebx + 0x3C]         ; EAX = Offset PE Header (e_lfanew)
    add eax, ebx                  ; EAX = RVA PE Header + base
    mov eax, [eax + 0x78]         ; RVA Export Table
    add eax, ebx                  ; EAX = Export Table VA
    mov edi, eax                  ; EDI = Export Directory

    ; ========================
    ; 4. Obtener Name Pointer Table
    ; ========================
    mov ecx, [edi + 0x18]         ; NumberOfNames
    mov edx, [edi + 0x20]         ; AddressOfNames (RVA array de punteros a strings)
    add edx, ebx                  ; EDX = VA de lista de nombres

buscar_winexec:
    ; Bucle que compara cada nombre
    push ecx
    push edx

next_name:
    mov esi, [edx]                ; RVA del nombre
    add esi, ebx                  ; ESI = puntero al nombre
    push ecx

    ; Comparar si es "WinExec"
    push offset winexec_str
    push esi
    call strcmp
    add esp, 8
    test eax, eax
    jz found_winexec

    ; No coincide, probar siguiente
    add edx, 4                    ; siguiente RVA
    pop ecx
    loop next_name

    jmp not_found

found_winexec:
    pop ecx
    pop edx

    ; ========================
    ; 5. Obtener índice del nombre encontrado
    ; ========================
    mov ecx, [edi + 0x24]         ; AddressOfNameOrdinals
    add ecx, ebx
    sub edx, [edi + 0x20]
    shr edx, 2                    ; índice = (posición * 4) / 4
    mov dx, [ecx + edx*2]         ; ordinal (WORD)

    ; ========================
    ; 6. Obtener RVA de la función
    ; ========================
    mov ecx, [edi + 0x1C]         ; AddressOfFunctions
    add ecx, ebx
    mov eax, [ecx + edx*4]        ; RVA de WinExec
    add eax, ebx                  ; EAX = dirección de WinExec

    ; Guardar dirección
    mov edi, eax                  ; EDI = WinExec

    ; ========================
    ; 7. Buscar ExitProcess igual
    ; ========================
    mov ecx, [edi + 0x18]         ; Reusar ExportDirectory
    mov edx, [edi + 0x20]
    add edx, ebx
buscar_exit:
    push ecx
    push edx
next_exit:
    mov esi, [edx]
    add esi, ebx
    push ecx

    push offset exitproc_str
    push esi
    call strcmp
    add esp, 8
    test eax, eax
    jz found_exit

    add edx, 4
    pop ecx
    loop next_exit

    jmp not_found

found_exit:
    pop ecx
    pop edx
    mov ecx, [edi + 0x24]
    add ecx, ebx
    sub edx, [edi + 0x20]
    shr edx, 2
    mov dx, [ecx + edx*2]

    mov ecx, [edi + 0x1C]
    add ecx, ebx
    mov eax, [ecx + edx*4]
    add eax, ebx
    mov esi, eax                 ; ESI = ExitProcess

    ; ========================
    ; 8. Llamar WinExec("calc.exe", 1)
    ; ========================
    push 1
    push offset command
    call edi                     ; call WinExec

    ; ========================
    ; 9. Llamar ExitProcess(0)
    ; ========================
    push 0
    call esi                     ; call ExitProcess

not_found:
    ret

; ========================
; strcmp simple (strcmp(str1, str2))
; ========================
strcmp:
    push ebp
    mov ebp, esp
    mov esi, [ebp + 8]
    mov edi, [ebp + 12]

.loop:
    mov al, [esi]
    mov bl, [edi]
    cmp al, bl
    jne .notequal
    test al, al
    je .equal
    inc esi
    inc edi
    jmp .loop

.equal:
    xor eax, eax
    pop ebp
    ret

.notequal:
    mov eax, 1
    pop ebp
    ret

end start
